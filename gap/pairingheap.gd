#############################################################################
##
#W  pairingheap.gd                    GAPData                   Markus Pfeiffer
##
##
#Y  Copyright (C) 2014 The GAP Group
##
##

DeclareRepresentation( "IsPairingHeapFlatRep", IsHeap and IsPositionalObjectRep, []);
BindGlobal( "PairingHeapType", NewType(HeapFamily, IsPairingHeapFlatRep));
BindGlobal( "PairingHeapTypeMutable", NewType(HeapFamily,
        IsPairingHeapFlatRep and IsMutable));

DeclareGlobalFunction("PairingHeap");
DeclareGlobalFunction("PairingHeapPush");
DeclareGlobalFunction("PairingHeapPeek");
DeclareGlobalFunction("PairingHeapPop");
DeclareGlobalFunction("PairingHeapSize");
DeclareGlobalFunction("PairingHeapMergePairs");

DeclareGlobalFunction("PairingHeapMeld");


