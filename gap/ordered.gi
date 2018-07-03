#
# Generic methods for ordered Set Datastructures
#

InstallMethod(IsEmpty, [IsOrderedSetDS], d -> Size(d) = 0);

InstallMethod(AsSortedList, [IsStandardOrderedSetDS],
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


InstallMethod(IteratorSorted, [IsStandardOrderedSetDS], Iterator);

InstallMethod(\=, [IsOrderedSetDS, IsOrderedSetDS],
        IsIdenticalObj);

InstallMethod(Length, [IsOrderedSetDS], Size);

InstallMethod(ELM_LIST, [IsOrderedSetDS, IsPosInt],
        function(os, n)
    return AsList(os)[n];
end);
