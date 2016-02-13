#
# This file contains a GAP implementation of a binary max-heap.
#
# Currently, a binary heap is a record with the following member:
# - data: the actual heap, represented as a GAP list
# - isLess: a function comparing two heap elements, by default \<
#
# Most functions also have a C implementation. If available, we
# use the C function, otherwise (e.g. if the package has not been
# compiled) we fall back to the GAP implementation.
#
#
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

BinaryHeap_IsEmpty := function(heap)
    return Length(heap.data) = 0;
end;

BinaryHeap_Size := function(heap)
    return Length(heap.data);
end;

# TODO: iterator; view/print; Random; ...
# DecreaseKey ?
# Merge ?


# Alternative name: Peek
BinaryHeap_FindMax := function(heap)
    if Length(heap.data) = 0 then return fail; fi; # alternative: error
    return heap.data[1];
end;

_BinaryHeap_BubbleUp := function(data, isLess, i, elm)
    local parent;
    while i > 1 do
        parent := QuoInt(i, 2);
        if not isLess(data[parent], elm) then
            break;
        fi;
        data[i] := data[parent];
        i := parent;
    od;
    data[i] := elm;
end;

# Alternative name: Push / Add
_BinaryHeap_Insert_GAP := function(heap, elm)
    _BinaryHeap_BubbleUp(heap.data, heap.isLess, Length(heap.data) + 1, elm);
end;

if IsBound(_BinaryHeap_Insert_C) then
	BinaryHeap_Insert := _BinaryHeap_Insert_C;
else
	BinaryHeap_Insert := _BinaryHeap_Insert_GAP;
fi;

_BinaryHeap_ReplaceMax_GAP := function(heap, elm)
    local data, isLess, i, left, right;
    data := heap.data;
    isLess := heap.isLess;
    i := 1;
    # treat the head slot as a hole that we bubble down
    while 2 * i <= Length(data) do
        left := 2 * i;
        right := left + 1;
        if right > Length(data) or isLess(data[right], data[left]) then
            data[i] := data[left];
            i := left;
        else
            data[i] := data[right];
            i := right;
        fi;
    od;

    # Insert the new element into the hole bubble it up.
    _BinaryHeap_BubbleUp(heap.data, heap.isLess, i, elm);
end;

if IsBound(_BinaryHeap_ReplaceMax_C) then
	BinaryHeap_ReplaceMax := _BinaryHeap_ReplaceMax_C;
else
	BinaryHeap_ReplaceMax := _BinaryHeap_ReplaceMax_GAP;
fi;

# Alternative name: Pop / Remove
BinaryHeap_RemoveMax := function(heap)
    local val, data;
    data := heap.data;

    if Length(data) = 0 then
        return fail; # alternative: error
    elif Length(data) = 1 then
        return Remove(data);
    fi;

    val := data[1];
    BinaryHeap_ReplaceMax(heap, Remove(data));
    return val;
end;


BinaryHeap_IsValid := function(heap)
    local data, i, left, right;
    data := heap.data;
    for i in [1..Length(data)] do
        left := 2 * i;
        right := left + 1;
        if left <= Length(data) and heap.isLess(data[i], data[left]) then
            Print("data[",i,"] = ",data[i], " < ",data[left]," = data[",left,"]\n");
            return false;
        fi;
        if right <= Length(data) and heap.isLess(data[i], data[right]) then
            Print("data[",i,"] = ",data[i], " < ",data[right]," = data[",right,"]\n");
            return false;
        fi;
    od;
    return true;
end;

BinaryHeap_Create := function(arg)
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

    heap := rec( isLess := isLess, data := [] );
    for x in data do
        BinaryHeap_Insert(heap, x);
    od;
    return heap;
end;


