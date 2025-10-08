##
##  Datastructures: GAP package providing common datastructures.
##
##  Copyright (C) 2015-2018 The datastructures team.
##  For list of the team members, please refer to the COPYRIGHT file.
##
##  This package is licensed under the GPL 2 or later, please refer
##  to the COPYRIGHT.md and LICENSE files for details.
##

#! @Chapter Union-Find
#! @Section Implementation

DeclareRepresentation("IsPartitionDSRep", IsComponentObjectRep,[]);
UF := rec();
UF.DefaultType := NewType(PartitionDSFamily, IsPartitionDSRep and IsPartitionDS and IsMutable);
if GAPInfo.BytesPerVariable = 8 then
    UF.Bitfields := MakeBitfields(6,54);
else
    UF.Bitfields := MakeBitfields(5,23);
fi;
UF.getRank := UF.Bitfields.getters[1];
UF.getParent := UF.Bitfields.getters[2];
UF.setRank := UF.Bitfields.setters[1];
UF.setParent := UF.Bitfields.setters[2];


InstallMethod(PartitionDSCons, [IsPartitionDSRep and IsPartitionDS and IsMutable, IsPosInt],
        function(filt, n)
    local  r;
    r := rec();
    r.data := List([1..n], i->BuildBitfields(UF.Bitfields.widths, 1,i));
    Add(r.data, fail);
    r.nparts := n;
    Objectify(UF.DefaultType, r);
    return r;
end);


InstallMethod(PartitionDSCons, [IsPartitionDSRep and IsPartitionDS and IsMutable, IsCyclotomicCollColl],
        function(filt, parts)
    local  r, n, seen, sp, sr, p, x;
      if not (ForAll(parts, IsSet) and
       ForAll(parts, p->ForAll(p, IsPosInt))) then
        Error("PartitionDS: supplied partition must be a list of disjoint sets of positive integers");
    fi;
    r := rec();
    n := Maximum(List(parts, Maximum));
    r.data := List([1..n], i->BuildBitfields(UF.Bitfields.widths,1,i));
    Add(r.data, fail);
    seen := BlistList([1..n],[]);
    sp := UF.setParent;
    sr := UF.setRank;
    for p in parts do
        for x in p do
            if seen[x] then
                Error("PartitionDS: supplied partition must be a list of disjoint sets of positive integers");
            fi;
            seen[x] := true;
            r.data[x]  := sp(r.data[x],p[1]);
        od;
        r.data[p[1]] := sr(r.data[p[1]],2);
    od;
    r.nparts :=  Length(parts) + n -SizeBlist(seen);
    Objectify(UF.DefaultType, r);
    return r;
end);

InstallMethod(PartitionDS, [IsPosInt],
n -> PartitionDSCons(IsPartitionDSRep, n));

InstallMethod(PartitionDS, [IsCyclotomicCollColl],
parts -> PartitionDSCons(IsPartitionDSRep, parts));

InstallMethod(PartitionDS, [IsFunction, IsPosInt],
{filt, n} -> PartitionDSCons(filt, n));

InstallMethod(PartitionDS, [IsFunction, IsCyclotomicCollColl],
{filt, parts} -> PartitionDSCons(filt, parts));

UF.RepresentativeKernel := function(uf, x)
    return DS_UF_FIND(x, uf!.data);
end;
InstallMethod(Representative, [IsPartitionDSRep and IsPartitionDS, IsPosInt],
        UF.RepresentativeKernel);

InstallMethod(Unite, [IsPartitionDSRep and IsMutable and IsPartitionDS,
        IsPosInt, IsPosInt],
        function(uf, x, y)
    if DS_UF_UNITE(x, y, uf!.data) then
        uf!.nparts := uf!.nparts -1;
    fi;
end);

InstallMethod(\=, [IsPartitionDSRep and IsPartitionDS, IsPartitionDSRep and IsPartitionDS], IsIdenticalObj);

InstallMethod(ShallowCopy, [IsPartitionDSRep and IsPartitionDS],
        function(uf)
    local  r;
    r := rec(data := ShallowCopy(uf!.data),
             nparts := uf!.nparts);
    Objectify(UF.DefaultType, r);
    return r;
end);

InstallMethod(NumberParts, [IsPartitionDSRep and IsPartitionDS],
        uf -> uf!.nparts);

InstallMethod(SizeUnderlyingSetDS, [IsPartitionDSRep and IsPartitionDS],
        uf -> Length(uf!.data)-1);

InstallMethod(RootsIteratorOfPartitionDS, [IsPartitionDSRep and IsPartitionDS],
        function(uf)
    local  i, gp;
    i := 1;
    gp := UF.getParent;
    while i < SizeUnderlyingSetDS(uf) and gp(uf!.data[i]) <> i do
        i := i+1;
    od;
    return IteratorByFunctions(rec(
                   gp := gp,
                   pt := i,
                   n := SizeUnderlyingSetDS(uf),
                   uf := uf,
                   NextIterator := function(iter)
        local  x, y, p, n;
        x := iter!.pt;
        y := x+1;
        p := iter!.uf!.data;
        n := iter!.n;
        while y <= n and gp(p[y]) <> y do
            y := y+1;
        od;
        iter!.pt := y;
        return x;
    end,
      IsDoneIterator := iter -> iter!.pt > iter!.n,
                        ShallowCopy := iter -> rec(pt := iter!.pt,
                                gp := iter!.gp,
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

InstallMethod(RootsOfPartitionDS, [IsPartitionDSRep and IsPartitionDS],
function(uf)
  local pt, gp, data, n, result;
    pt := 0;
    gp := UF.getParent;
    data := uf!.data;
    n := SizeUnderlyingSetDS(uf);
    result := [];
    while pt <= n do
      pt := pt + 1;
      while pt <= n and gp(data[pt]) <> pt do
        pt := pt + 1;
      od;
      if pt <= n then
        Add(result, pt);
      fi;
    od;
    return result;
end);

InstallMethod(PartsOfPartitionDS, [IsPartitionDS],
        function(u)
    local  p, i, r, x;
    p := [];
    for i in [1..SizeUnderlyingSetDS(u)] do
        r := Representative(u,i);
        if not IsBound(p[r]) then
            p[r] := [];
        fi;
        Add(p[r],i);
    od;
    p := Compacted(p);
    MakeImmutable(p);
    for x in p do
        IsSet(x);
    od;
    return p;
end);

InstallMethod(ViewString, [IsPartitionDS],
        u -> Concatenation("<union find ",String(NumberParts(u))," parts on ",String(SizeUnderlyingSetDS(u))," points>"));

InstallMethod(String, [IsPartitionDS],
        u->Concatenation("PartitionDS( IsPartitionDS, ",String(PartsOfPartitionDS(u)),")"));
