#############################################################################
##
#W  pairhppq.gd                    GAPData                   Markus Pfeiffer
##
##
#Y  Copyright (C) 2014 The GAP Group
##
##  Declaration for priority queues based on pairing heaps.
##

DeclareRepresentation( "IsPrioQPairingHeapRep", IsPriorityQueue and IsHeap, []);
BindGlobal( "PairingHeapPrioQueueType",
        NewType(HeapFamily, IsPrioQPairingHeapFlatRep));
BindGlobal( "PairingHeapPrioQueueTypeMutable",
        NewType(HeapFamily, IsPrioQPairingHeapFlatRep and IsMutable));

