##
##  Datastructures: GAP package providing common datastructures.
##
##  Copyright (C) 2015-2017  The datastructures team.
##  For list of the team members, please refer to the COPYRIGHT file.
##
##  This package is licensed under the GPL 2 or later, please refer
##  to the COPYRIGHT.md and LICENSE files for details.
##

##
##  Declarations for pairing heaps in GAP.
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
