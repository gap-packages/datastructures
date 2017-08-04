#
# This file contains a GAP implementation of a binary max-heap.
#
# Some hints for writing efficient binary heap implementations:
# <http://stackoverflow.com/questions/6531543>
#
# Note that while there are other heap datastructures which in
# theory have better asymptotical behavior than binary heaps, in
# real-world applications, a well-tunes binary heap often
# outperforms other heap implementations anyway, due to its
# simplicity, low constant (in O-notation) and cache friendliness.
#

BinaryHeap_IsValid := function(heap)
    local isLess, data, i, left, right;
    isLess := heap![1];
    data := heap![2];
    for i in [1..Length(data)] do
        left := 2 * i;
        right := left + 1;
        if left <= Length(data) and isLess(data[i], data[left]) then
            Print("data[",i,"] = ",data[i], " < ",data[left]," = data[",left,"]\n");
            return false;
        fi;
        if right <= Length(data) and isLess(data[i], data[right]) then
            Print("data[",i,"] = ",data[i], " < ",data[right]," = data[",right,"]\n");
            return false;
        fi;
    od;
    return true;
end;

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

InstallMethod(Size,
    "for a binary heap in plain representation",
    [IsBinaryHeapFlatRep],
function(heap)
    return Length(heap![2]);
end);


InstallMethod(ViewObj,
    "for a binary heap in flat representation",
    [IsBinaryHeapFlatRep],
function(heap)
    Print("<binary heap with ", Length(heap![2]), " entries>");
end);

