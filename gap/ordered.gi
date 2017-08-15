#
# Generic methods
#


InstallMethod(IsEmpty, [IsOrderedSetDS], d -> Size(d) = 0);

InstallMethod(Iterator, [IsOrderedSetDS], IteratorSorted);

InstallMethod(AsListSorted, [IsOrderedSetDS], 
        function(s)
    local  i, l, x;
    i := IteratorSorted(s);
    l := [];
    for x in i do 
        Add(l,x);
    od;
    return MakeImmutable(l);
end);

#
# This one might belong somewhere more generic
#

InstallMethod(AsList, [IsOrderedSetDS], 
        function(s)
    local  i, l, x;
    i := Iterator(s);
    l := [];
    for x in i do 
        Add(l,x);
    od;
    return MakeImmutable(l);
end);


osbench := function(n, type)
    local  l1, l2, t, s, x;
    l1 := ListPerm(Random(SymmetricGroup(n)),n);
    l2 := ListPerm(Random(SymmetricGroup(n)),n);
    t := Runtime();
    s := OrderedSetDS(type);
    for x in l1 do 
        AddSet(s,x);
        if not x in s then
            Error("add didn't add");
        fi;
    od;
    for x in l2 do 
        if 1 <> RemoveSet(s,x) then
            Error("missing entry");
        fi;
    od;
    if not IsEmpty(s) then
        Error("not empty");
    fi;
    return Runtime()-t;
end;
    

InstallMethod(\=, [IsOrderedSetDS, IsOrderedSetDS], 
        IsIdenticalObj);
