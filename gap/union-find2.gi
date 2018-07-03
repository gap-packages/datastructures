DeclareRepresentation("IsPartitionDSRep2", IsComponentObjectRep,[]);
UF2 := rec();
UF2.DefaultType := NewType(PartitionDSFamily, IsPartitionDSRep2 and IsPartitionDS and IsMutable);
UF2.Bitfields := MakeBitfields(6,54);
UF2.getRank := UF2.Bitfields.getters[1];
UF2.getParent := UF2.Bitfields.getters[2];
UF2.setRank := UF2.Bitfields.setters[1];
UF2.setParent := UF2.Bitfields.setters[2];


InstallMethod(PartitionDS, [IsPartitionDSRep2 and IsPartitionDS and IsMutable, IsPosInt],
        function(filt, n)
    local  r;
    r := rec();
    r.data := List([1..n], i->BuildBitfields(UF2.Bitfields.widths, 1,i));
    Add(r.data, fail);
    r.nparts := n;
    Objectify(UF2.DefaultType, r);
    return r;
end);


InstallMethod(PartitionDS, [IsPartitionDSRep2 and IsPartitionDS and IsMutable, IsCyclotomicCollColl],
        function(filt, parts)
    local  r, n,, seen, sp, sr, p, x;
    if not ForAll(parts, IsSet) and
       ForAll(parts, p->ForAll(p, IsPosInt)) then
        Error("PartitionDS: supplied partition must be a list of disjoint sets of positive integers");
    fi;
    r := rec();
    n := Maximum(List(parts, Maximum));
    r.data := List([1..n], i->BuildBitfields(UF2.Bitfields.widths,1,i));
    Add(r.data, fail);
    seen := BlistList([1..n],[]);
    sp := UF2.setParent;
    sr := UF2.setRank;
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
    Objectify(UF2.DefaultType, r);
    return r;
end);



UF2.RepresentativeTarjan :=
  function(uf, x)
    local  gp, sp, p, y, z;
    gp := UF2.getParent;
    sp := UF2.setParent;
    p := uf!.data;
    while true do
        y := gp(p[x]);
        if y = x then
            return x;
        fi;
        z := gp(p[y]);
        if y = z then
            return y;
        fi;
        p[x] := sp(p[x],z);
        x := z;
    od;
end;

if IsBound(DS_UF2_FIND)  then
    UF2.RepresentativeKernel := function(uf, x)
        return DS_UF2_FIND(x, uf!.data);
    end;
    InstallMethod(Representative, [IsPartitionDSRep2 and IsPartitionDS, IsPosInt],
            UF2.RepresentativeKernel);
else
    InstallMethod(Representative, [IsPartitionDSRep2 and IsPartitionDS, IsPosInt],
            UF2.RepresentativeTarjan);
fi;



if IsBound(DS_UF2_UNITE) then
    InstallMethod(Unite, [IsPartitionDSRep2 and IsMutable and IsPartitionDS,
            IsPosInt, IsPosInt],
            function(uf, x, y)
        if DS_UF2_UNITE(x, y, uf!.data) then
            uf!.nparts := uf!.nparts -1;
        fi;
    end);
else
    InstallMethod(Unite, [IsPartitionDSRep2 and IsMutable and IsPartitionDS,
            IsPosInt, IsPosInt],
            function(uf, x, y)
        local  r, rx, ry;
        x := Representative(uf, x);
        y := Representative(uf, y);
        if x  = y then
            return;
        fi;
        r := uf!.data;
        rx := UF2.getRank(r[x]);
        ry := UF2.getRank(r[y]);
        if rx > ry then
            r[y] := UF2.setParent(r[y],x);
        elif ry > rx then
            r[x] := UF2.setParent(r[x],y);
        else
            r[x] := UF2.setParent(r[x],y);
            r[y] := UF2.setRank(r[y],ry+1);
        fi;
        uf!.nparts := uf!.nparts -1;
        return;
    end);
fi;


InstallMethod(\=, [IsPartitionDSRep2 and IsPartitionDS, IsPartitionDSRep and IsPartitionDS], IsIdenticalObj);

InstallMethod(ShallowCopy, [IsPartitionDSRep2 and IsPartitionDS],
        function(uf)
    local  r;
    r := rec(data := ShallowCopy(uf!.data),
             nparts := uf!.nparts);
    Objectify(UF2.DefaultType, r);
    return r;
end);

InstallMethod(NumberParts, [IsPartitionDSRep2 and IsPartitionDS],
        uf -> uf!.nparts);

InstallMethod(SizeUnderlyingSetDS, [IsPartitionDSRep2 and IsPartitionDS],
        uf -> Length(uf!.data)-1);

InstallMethod(RootsIteratorOfPartitionDS, [IsPartitionDSRep2 and IsPartitionDS],
        function(uf)
    local  i, gp;
    i := 1;
    gp := UF2.getParent;
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
        y := x;
        p := iter!.uf!.data;
        n := iter!.n;
        while y <= n and gp(p[y]) <> y do
            y := y+1;
        od;
        iter!.pt := y;
        return x;
    end,
      IsDoneIterator := iter -> iter!.pt <= iter!.n,
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






ufbench2 := function(n)
    local  u;
    u := PartitionDS(IsPartitionDSRep2, n);
    while NumberParts(u) > 1 do
        Unite(u, Random(GlobalMersenneTwister,1,n),
              Random(GlobalMersenneTwister,1,n));
    od;
    return u;

end;
