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
##  - implement tests
##  - do benchmarks and consider more efficient implementations
##  - custom comparison function for priorities
##
InstallGlobalFunction(PairingHeap,
function()
    local h;
    # ![1] node count
    # ![2]
    # ![3]
    # ![4] nodes
    # a node is a list of length 4
    # node[1] priority
    # node[2] number of nodes in the tree
    # node[3] data attached to the node
    # node[4] list of subheaps
    h := [0, 0, 0, [0,0,0,] ];

    return Objectify(PairingHeapTypeMutable, h);
end);

# pairing heap is a list [a, b, c, d] where a is the priority, b is data
# and c is a list of pairing heaps
InstallGlobalFunction(PairingHeapPush,
function(heap, priority, data)
    if heap![1] = 0 then
        heap![4] := [priority, data, 1, []];
        heap![1] := 1;
    elif heap![4][1] < priority then
        Add(heap![4][4], [priority,data,1,[]]);
        heap![4][3] := heap![4][3] + 1;
        heap![1] := heap![4][3];
    else
        heap![4] := [priority, data, heap![4][3] + 1, [heap![4]]];
        heap![1] := heap![4][3];
    fi;
end);

meld := function(x,y)
    if x[1] < y[1] then
        Add(x[4], y);
        x[3] := x[3] + y[3];
        return x;
    else
        Add(y[4], x);
        y[3] := x[3] + y[3];
        return y;
    fi;
end;

merge_pairs := function(heaps)
    local h, res;

    if Length(heaps) = 0 then
        return [0,0,0];
    else
        res := heaps[1];

        for h in heaps{[2..Length(heaps)]} do
            res := meld(res, h);
        od;

        return res;
    fi;
end;

# Returns a new pairing heap which is the meld of heap1 and heap2
InstallGlobalFunction(PairingHeapMeld,
function(heap1, heap2)
    local res;

    res := PairingHeap();
    res![4] := meld(heap1![4], heap2![4]);
    res![1] := heap1![1] + heap2![2];

    return res;
end);

InstallGlobalFunction(PairingHeapPeek,
function(heap)
    return [heap![4][1], heap![4][2]];
end);

InstallGlobalFunction(PairingHeapPop,
function(heap)
    local res;

    if heap![1] = 0 then
        res := fail;
    else
        res := [heap![4][1], heap![4][2]];
        heap![4] := merge_pairs(heap![4][4]);
        heap![1] := heap![4][3];
    fi;

    return res;
end);

InstallMethod(Push
        , "for a pairing heap in plain representation, a priority, and and data"
        , [IsPairingHeapFlatRep, IsObject, IsObject]
        , PairingHeapPush);

InstallMethod(Pop
        , "for a pairing heap in plain representation"
        , [IsPairingHeapFlatRep]
        , PairingHeapPop);

InstallMethod(Peek
        , "for a pairing heap in plain representation"
        , [IsPairingHeapFlatRep]
        , PairingHeapPeek);

InstallMethod( ViewObj,
        "for a pairing heap in flat representation",
        [ IsPairingHeapFlatRep ],
function(h)
    Print("<pairing heap with "
          , h![1]
          , " entries");
    if h![1] > 0 then
        Print(" top ", h![4][1]);
    fi;
    Print(">");
end);

InstallMethod( PrintObj,
        "for a pairing heap in flat representation",
        [ IsPairingHeapFlatRep ],
function(h)
    Print("<pairing heap>");
end);

##
##  This program is free software: you can redistribute it and/or modify
##  it under the terms of the GNU General Public License as published by
##  the Free Software Foundation, either version 3 of the License, or
##  (at your option) any later version.
##
##  This program is distributed in the hope that it will be useful,
##  but WITHOUT ANY WARRANTY; without even the implied warranty of
##  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
##  GNU General Public License for more details.
##
##  You should have received a copy of the GNU General Public License
##  along with this program.  If not, see <http://www.gnu.org/licenses/>.
##
