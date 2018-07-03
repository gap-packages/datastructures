##
##  Datastructures: GAP package providing common datastructures.
##
##  Copyright (C) 2015-2017  The datastructures team.
##  For list of the team members, please refer to the COPYRIGHT file.
##
##  This package is licensed under the GPL 2 or later, please refer
##  to the COPYRIGHT.md and LICENSE files for details.
##
#  see
#    Fredman, Sedgewick, Sleator, Tarjan (1986),
#          "The pairing heap: a new form of self-adjusting heap"
#          http://www.cs.cmu.edu/afs/cs.cmu.edu/user/sleator/www/papers/pairing-heaps.pdf
#

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
    if heap![1] = 0 then
        return fail;
    fi;
    return heap![3][1];
end);

InstallGlobalFunction(PairingHeapPop,
function(heap)
    local res;
    if heap![1] = 0 then
        return fail;
    fi;
    res := heap![3][1];
    heap![3] := DS_merge_pairs(heap![2], heap![3][3]);
    heap![1] := heap![3][2];
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

InstallOtherMethod(Size
        , "for a pairing heap in plain representation"
        , [IsPairingHeapFlatRep]
        , h -> h![1]);

InstallOtherMethod(IsEmpty
        , "for a pairing heap in plain representation"
        , [IsPairingHeapFlatRep]
        , h -> h![1] = 0);

InstallMethod( ViewString,
        "for a pairing heap in flat representation",
        [ IsPairingHeapFlatRep ],
function(h)
    return STRINGIFY("<pairing heap with "
                    , h![1]
                    , " entries>");
end);
