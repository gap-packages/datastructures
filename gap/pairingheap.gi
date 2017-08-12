# pairingheap.gi
#
#  A fairly naive implementation of pairing heaps in GAP.
#
#  push and peek is O(1), pop is amortised O(log n), n is number of nodes
#
#  see
#    Fredman, Sedgewick, Sleator, Tarjan (1986),
#          "The pairing heap: a new form of self-adjusting heap"
#          http://www.cs.cmu.edu/afs/cs.cmu.edu/user/sleator/www/papers/pairing-heaps.pdf
#

#
# TODO:
#
#  - implement decrease priority
#  - do benchmarks and consider more efficient implementations
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
    local nl;
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
    local res, merge_pairs, merge_pairs_nr, meld;

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

    # TODO: Find out whether recursive vs non-recursive
    #       has any measurable benefits

    # Non-recursive merge-pairs
    merge_pairs_nr := function(isLess, heaps)
        local l, res, tmp, k, s, i, r;

        l := Length(heaps);

        if l = 0 then
            return [0,0,0];
        elif l = 1 then
            return heaps[1];
        else
            res := heaps;
            k := l;
            s := 1;

            while k > 1 do
                r := RemInt(k, 2);
                k := QuoInt(k, 2);
                s := 2*s;

                for i in [1..k] do
                    res[s*i] := meld(isLess, res[s*i - s/2], res[s*i]);
                od;
                if r = 1 then
                    res[s * (k+1)] := res[s * (k+1) - s/2];
                    k := k + 1;
                fi;
            od;
            return res[s * k];
        fi;
    end;

    # recursive merge-pairs
    merge_pairs := function(isLess, heaps)
        local h, res, i, k, l;

        l := Length(heaps);
        if l = 0 then
            return [0,0,0];
        elif l = 1 then
            return heaps[1];
        else
            res := [];
            k := QuoInt(l,2);
            for i in [1..k] do
                res[i] := meld(isLess, heaps[2*i - 1], heaps[2*i]);
            od;
            if l mod 2 = 1 then
                res[k+1] := heaps[l];
            fi;
            return merge_pairs(isLess, res);
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

InstallOtherMethod(Size
        , "for a pairing heap in plain representation"
        , [IsPairingHeapFlatRep]
        , h -> h![1]);

InstallOtherMethod(IsEmpty
        , "for a pairing heap in plain representation"
        , [IsPairingHeapFlatRep]
        , h -> h![1] = 0);

InstallMethod( ViewObj,
        "for a pairing heap in flat representation",
        [ IsPairingHeapFlatRep ],
function(h)
    Print("<pairing heap with "
          , h![1]
          , " entries>");
end);
