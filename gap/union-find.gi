#
# Each part is represented by a tree, where each member of the part links to a parent.
# At the root of each tree is the canonical representative of the part, which links to itself
# By keeping the trees shallow, we obtain a fast find operation.
#
# This implementation uses linking by rank, and the path-halving path compression technique
# both widely described in the literature
#
# We use two plain lists one containing the parent pointers and one the ranks.
# These together with a couple of utility fields are stored in a component object
#
#

DeclareRepresentation("IsPartitionDSRep", IsComponentObjectRep,[]);
UF := rec();
UF.DefaultType := NewType(PartitionDSFamily, IsPartitionDSRep and IsPartitionDS and IsMutable);


InstallMethod(PartitionDS, [IsPartitionDSRep and IsPartitionDS and IsMutable, IsPosInt],
        function(filt, n)
    local  r;    
    r := rec();
    r.parent := [1..n];    
    Add(r.parent, fail); # A device to turn the range into a plain list for our kernel code    
    r.rank := ListWithIdenticalEntries(n,1); # rank of a singleton is 1
    r.nparts := n;
    Objectify(UF.DefaultType, r);
    return r;
end);


InstallMethod(PartitionDS, [IsPartitionDSRep and IsPartitionDS and IsMutable, IsCyclotomicCollColl],
        function(filt, parts)    
    local  r, n, seen, p, x;
    if not ForAll(parts, IsSet) and 
       ForAll(parts, p->ForAll(p, IsPosInt)) then
        Error("PartitionDS: supplied partition must be a list of disjoint sets of positive integers");
    fi;    
    r := rec();
    n := Maximum(List(parts, Maximum));
    r.parent := [1..n];    
    Add(r.parent, fail); # A device to turn the range into a plain list for our kernel code    
    r.rank := ListWithIdenticalEntries(n,1);
    seen := BlistList([1..n],[]);    
    for p in parts do
        #
        # make all parts of p point to the first one
        #
        for x in p do
            #
            # checking is integrated in the constructions
            #
            if seen[x] then
                Error("PartitionDS: supplied partition must be a list of disjoint sets of positive integers");
            fi;
            seen[x] := true;
            r.parent[x] := p[1];
        od;
        if Length(p > 1) then
            #
            # The first one has rank one children so must be rank 2
            #
            r.rank[p[1]] := 2;
    od;
    r.nparts :=  Length(parts) + n -SizeBlist(seen);
    Objectify(UF.DefaultType, r);
    return r;
end);

#
# This is simple and does full path compression, but the recursion is expensive
#
UF.RepresentativeRecursive := 
        function(uf, x)
    local  foo;
    foo := function(parents, x)
        local  y;
        if parents[x] = x then
            return x;
        else
            y := foo(parents, parents[x]);
            parents[x] := y;
            return y;
        fi;
    end;
    return foo(uf!.parent, x);
end;

#
# This is the path-halving version which can work in one pass
# This is a time critical routine and is overridden by the C
# version if available.
#
# The idea here is that every second point along the path is changed to point to its grandparent. 
# All path lengths are halved, round up and, by making paths tend to "fan in" early, the benefit of
# future compression is maximised.
#
UF.RepresentativeTarjan :=
  function(uf, x)
    local  p, y, z;
    p := uf!.parent;
    while true do
        #
        # Trace up to two steps, checking to see if we have arrived
        # before each step.
        #
        y := p[x];
        if y = x then
            return x;            
        fi;
        z := p[y];
        if y = z then
            return y;
        fi;
        #
        # Otherwise compress and continue
        #
        p[x] := z;
        x := z;
    od;
end;

#
#
#
if IsBound(DS_UF_FIND)  then 
    UF.RepresentativeKernel := function(uf, x)
        return DS_UF_FIND(x, uf!.parent);
    end;
    InstallMethod(Representative, [IsPartitionDSRep and IsPartitionDS, IsPosInt],
            UF.RepresentativeKernel);
else
    InstallMethod(Representative, [IsPartitionDSRep and IsPartitionDS, IsPosInt],
            UF.RepresentativeTarjan);
fi;


#
# For Unire we can use the kernel version or a GAP version
#

   
UF.UniteGAP := function(uf, x, y)
    local  r, rx, ry;
    x := Representative(uf, x);
    y := Representative(uf, y);
    if x  = y then
        return;
    fi;
    #
    # We link the lower rank part of the higher
    #
    r := uf!.rank;  
    rx := r[x];
    ry := r[y];
    if rx > ry then
        uf!.parent[y] := x;
    elif ry > rx then
        uf!.parent[x] := y;
    else
        #
        # if both parts have the same rank, we have to bump the rank
        # it's easy to see that the rank cannot exceed log(n).
        #
        uf!.parent[x] := y;
        r[y] := ry+1;
    fi;
    uf!.nparts := uf!.nparts -1;    
    return;    
end;


if IsBound(DS_UF_UNITE) then
    UF.UniteKernel := function(uf, x, y)
        if DS_UF_UNITE(x, y, uf!.rank, uf!.parent) then
            uf!.nparts := uf!.nparts -1;
        fi;    
    end;    
    InstallMethod(Unite, [IsPartitionDSRep and IsMutable and IsPartitionDS, 
            IsPosInt, IsPosInt], UF.UniteKernel);   
else
    InstallMethod(Unite, [IsPartitionDSRep and IsMutable and IsPartitionDS, 
            IsPosInt, IsPosInt],
            UF.UniteGAP);    
fi;

    
InstallMethod(\=, [IsPartitionDSRep and IsPartitionDS, IsPartitionDSRep and IsPartitionDS], IsIdenticalObj);

InstallMethod(ShallowCopy, [IsPartitionDSRep and IsPartitionDS],
        function(uf)
    local  r;
    r := rec(parent := ShallowCopy(uf!.parent),
             rank := ShallowCopy(uf!.rank),
             nparts := uf!.nparts);
    Objectify(UF.DefaultType, r);
    return r;
end);

InstallMethod(NumberParts, [IsPartitionDSRep and IsPartitionDS],
        uf -> uf!.nparts);

InstallMethod(SizeUnderlyingSetDS, [IsPartitionDSRep and IsPartitionDS],
        uf -> Length(uf!.rank));

#
# Iterate over the roots (canonical representatives) of the parts 
# In this iterator, the component pt is the next root to return, 
# or n+1 if the iterator is spent.
#

InstallMethod(RootsIteratorOfPartitionDS, [IsPartitionDSRep and IsPartitionDS],
        function(uf)
    local  i;
    i := 1;
    while i < SizeUnderlyingSetDS(uf) and uf!.parent[i] <> i do
        i := i+1;
    od;
    return IteratorByFunctions(rec(
                   pt := i,
                   n := SizeUnderlyingSetDS(uf),
                   uf := uf,
                 NextIterator := function(iter)
        local  x, y, p, n;
        x := iter!.pt;
        y := x;
        p := iter!.uf!.parent;    
        n := iter!.n;    
        while y <= n and p[y] <> y do
            y := y+1;
        od;
        iter!.pt := y;
        return x;
    end,
      IsDoneIterator := iter -> iter!.pt <= iter!.n,
       ShallowCopy := iter -> 
            rec(pt := iter!.pt,
                        n := iter!.n,
                        uf := iter!.uf,
                        NextIterator := iter!.NextIterator,
                        IsDoneIterator := iter!.IsDoneIterator,
                        ShallowCopy := iter!.ShallowCopy,
                        PrintObj := iter!.PrintObj),
      PrintObj := function(iter)
        Print("<iterator of ",ViewString(iter!.uf), ">");
    end));
end);



                    
InstallMethod(ViewString, [IsPartitionDS],
        uf -> STRINGIFY("<union-find on ",SizeUnderlyingSetDS(uf)," points ",NumberParts(uf)," parts>"));



ufbench := function(n)
    local  u;    
    u := PartitionDS(IsPartitionDSRep, n);
    while NumberParts(u) > 1 do
        Unite(u, Random(GlobalMersenneTwister,1,n),
              Random(GlobalMersenneTwister,1,n));
    od;
    return u;
    
end;

       
              
    
   
