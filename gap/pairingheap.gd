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


#! @Chapter Heaps
#!
#! @Section Pairing Heaps
#! @SectionLabel PairingHeap
#!
#! A pairing heap is a heap datastructure with a very simple implementation in
#! terms of &GAP; lists.
#! <C>Push</C> and <C>Peek</C> have <M>O(1)</M> complexity, and <C>Pop</C> has an amortized
#! amortised O(log n), where <M>n</M> is the number of items on the heap.
#!
#! For a reference see <Cite Key="Fredman1986"/>.
#!

#! @Description
#! Constructor for pairing heaps. The optional argument <A>isLess</A> must be a binary function
#! that performs comparison between two elements on the heap, and returns <K>true</K> if the first
#! argument is less than the second, and <K>false</K> otherwise.
#! Using the optional argument <A>data</A> the user can give a collection of initial values that
#! are pushed on the stack after construction.
#! @Arguments [isLess, [data]]
#! @Returns A pairing heap
DeclareGlobalFunction("PairingHeap");

#! @Section Implementation
DeclareRepresentation( "IsPairingHeapFlatRep", IsHeap and IsPositionalObjectRep, []);
BindGlobal( "PairingHeapType", NewType(HeapFamily, IsPairingHeapFlatRep));
BindGlobal( "PairingHeapTypeMutable", NewType(HeapFamily,
        IsPairingHeapFlatRep and IsMutable));


DeclareGlobalFunction("PairingHeapPush");
DeclareGlobalFunction("PairingHeapPeek");
DeclareGlobalFunction("PairingHeapPop");
DeclareGlobalFunction("PairingHeapSize");
DeclareGlobalFunction("PairingHeapMergePairs");

DeclareGlobalFunction("PairingHeapMeld");
