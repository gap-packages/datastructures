#############################################################################
##
#W  pairhppq.gd                    GAPData                   Markus Pfeiffer
##
##
#Y  Copyright (C) 2014 The GAP Group
##
##
##  Implementation of priority queues based on pairing heaps.
##

InstallGlobalFunction(PriorityQueue,
function()
    local h;
    h := PairingHeap();

    return Objectify(PairingHeapPrioQueueTypeMutable, h);
end);

InstallMethod( Push,
        "for a priority queue",
        [IsPrioQPairingHeapFlatRep, IsInt, IsObject],
        PairingHeapPush);

InstallMethod( Pop,
        "for a priority queue",
        [IsPrioQPairingHeapFlatRep],
        PairingHeapPop);

InstallMethod( Peek,
        "for a priority queue",
        [IsPrioQPairingHeapFlatRep],
        PairingHeapPeek);

InstallMethod( ViewObj,
        "for a priority queue",
        [ IsPrioQPairingHeapFlatRep ],
function(h)
    Print("<priority queue of length "
          , h![1]
          , " entries");
    if h![1] > 0 then
        Print(" top ", h![4][1]);
    fi;
    Print(">");
end);
