##
##  Datastructures: GAP package providing common datastructures.
##
##  Copyright (C) 2015-2017  The datastructures team.
##  For list of the team members, please refer to the COPYRIGHT file.
##
##  This package is licensed under the GPL 2 or later, please refer
##  to the COPYRIGHT.md and LICENSE files for details.
##

# This file contains a GAP implementation of a binary max-heap.
#
# Some hints for writing efficient binary heap implementations:
# <https://stackoverflow.com/questions/6531543>
#
# Note that while there are other heap datastructures which in
# theory have better asymptotical behavior than binary heaps, in
# real-world applications, a well-tunes binary heap often
# outperforms other heap implementations anyway, due to its
# simplicity, low constant (in O-notation) and cache friendliness.
#

#! @Chapter Heaps
#! @Section Binary Heaps
InstallGlobalFunction(BinaryHeap,
function(arg...)
    local isLess, data, heap, x;

    isLess := \<;
    data := [];

    if Length(arg) = 1 then
        if IsFunction(arg[1]) then
            isLess := arg[1];
        else
            data := arg[1];
        fi;
    elif Length(arg) = 2 then
        isLess := arg[1];
        data := arg[2];
    elif Length(arg) > 2 then
        Error("Wrong number of arguments");
    fi;

    heap := Objectify( BinaryHeapType, [ isLess, [] ] );

    for x in data do
        DS_BinaryHeap_Insert(heap, x);
    od;
    return heap;
end);

InstallMethod(Push,
    "for a binary heap in plain representation",
    [IsBinaryHeapFlatRep, IsObject],
    DS_BinaryHeap_Insert);

InstallMethod(Pop,
    "for a binary heap in plain representation",
    [IsBinaryHeapFlatRep],
function(heap)
    local val, data;
    data := heap![2];

    if Length(data) = 0 then
        return fail; # alternative: error
    elif Length(data) = 1 then
        return Remove(data);
    fi;

    val := data[1];
    DS_BinaryHeap_ReplaceMax(heap, Remove(data));
    return val;
end);

InstallMethod(Peek,
    "for a binary heap in plain representation",
    [IsBinaryHeapFlatRep],
function(heap)
    if Length(heap![2]) = 0 then
        return fail; # alternative: error
    fi;
    return heap![2][1];
end);

InstallOtherMethod(Size,
    "for a binary heap in plain representation",
    [IsBinaryHeapFlatRep],
    heap -> Length(heap![2]));

InstallOtherMethod(IsEmpty,
    "for a binary heap in plain representation",
    [IsBinaryHeapFlatRep],
    heap -> Length(heap![2]) = 0);

InstallMethod(ViewString,
    "for a binary heap in flat representation",
    [IsBinaryHeapFlatRep],
function(heap)
    return STRINGIFY("<binary heap with ", Length(heap![2]), " entries>");
end);

