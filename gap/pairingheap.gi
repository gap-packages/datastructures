#############################################################################
##
#W  pairingheap.gi                    GAPData                   Markus Pfeiffer
##
##
#Y  Copyright (C) 2014 The GAP Group
##
##  This file is free software, see license information at the end.
##
##  A fairly naive implementation of pairing heaps in GAP.
##
##  push and peek is O(1), pop is amortised O(log n), n is number of nodes
##
##  see
##    Fredman, Sedgewick, Sleator, Tarjan (1986),
##          "The pairing heap: a new form of self-adjusting heap"
##          http://www.cs.cmu.edu/afs/cs.cmu.edu/user/sleator/www/papers/pairing-heaps.pdf
##
#############################################################################
##
## TODO:
##
##  - implement decrease priority
##  - do benchmarks and consider more efficient implementations
##
InstallGlobalFunction(PairingHeap,
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

    # ![1] node count
    # ![2] comparison function
    # ![3] nodes
    #
    # a node is a list of length 3
    # node[1] data
    # node[2] number of nodes in the subheap
    # node[3] list of subheaps
    heap := Objectify(PairingHeapTypeMutable, [0, isLess, []]);

    for x in data do
        PairingHeapPush(heap, x);
    od;
    return heap;
end);

# pair ing heap is a list [a, b, c, d] where a some data, b is the number of
# things in the heap and d is a list of pairing heaps

InstallGlobalFunction(PairingHeapPush,
function(heap, data)
    if heap![1] = 0 then
        heap![3] := [data, 1, []];
        heap![1] := 1;
    elif heap![2](data, heap![3][1]) then
        Add(heap![3][3], [data,1,[]]);
        heap![3][2] := heap![3][2] + 1;
        heap![1] := heap![3][2];
    else
        heap![3] := [data, heap![3][2] + 1, [heap![3]]];
        heap![1] := heap![3][2];
    fi;
end);

InstallGlobalFunction(PairingHeapPeek,
function(heap)
    return heap![3][1];
end);

InstallGlobalFunction(PairingHeapPop,
function(heap)
    local res, merge_pairs, meld;

    meld := function(isLess, x, y)
        if isLess(y[1],x[1]) then
            Add(x[3], y);
            x[2] := x[2] + y[2];
            return x;
        else
            Add(y[3], x);
            y[2] := x[2] + y[2];
            return y;
        fi;
    end;

    merge_pairs := function(isLess, heaps)
        local h, res;

        if Length(heaps) = 0 then
            return [0,0,0];
        else
            res := heaps[1];

            for h in heaps{[2..Length(heaps)]} do
                res := meld(isLess, res, h);
            od;

            return res;
        fi;
    end;

    if heap![1] = 0 then
        res := fail;
    else
        res := heap![3][1];
        heap![3] := merge_pairs(heap![2], heap![3][3]);
        heap![1] := heap![3][2];
    fi;

    return res;
end);

InstallMethod(Push
        , "for a pairing heap in plain representation, and data"
        , [IsPairingHeapFlatRep, IsObject]
        , PairingHeapPush);

InstallMethod(Pop
        , "for a pairing heap in plain representation"
        , [IsPairingHeapFlatRep]
        , PairingHeapPop);

InstallMethod(Peek
        , "for a pairing heap in plain representation"
        , [IsPairingHeapFlatRep]
        , PairingHeapPeek);

InstallMethod(Size
        , "for a pairing heap in plain representation"
        , [IsPairingHeapFlatRep]
        , h -> h![1]);

InstallMethod( ViewObj,
        "for a pairing heap in flat representation",
        [ IsPairingHeapFlatRep ],
function(h)
    Print("<pairing heap with "
          , h![1]
          , " entries>");
end);

InstallMethod( PrintObj,
        "for a pairing heap in flat representation",
        [ IsPairingHeapFlatRep ],
function(h)
    Print("<pairing heap>");
end);
