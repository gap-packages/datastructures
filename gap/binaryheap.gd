##
##  Datastructures: GAP package providing common datastructures.
##
##  Copyright (C) 2015-2017  The datastructures team.
##  For list of the team members, please refer to the COPYRIGHT file.
##
##  This package is licensed under the GPL 2 or later, please refer
##  to the COPYRIGHT.md and LICENSE files for details.
##

#! @Chapter Heaps
#!
#! @Section Binary heaps
#!
#! A binary heap is a special kind of heap.
#! TODO
#!

DeclareRepresentation( "IsBinaryHeapFlatRep", IsHeap and IsPositionalObjectRep, []);
BindGlobal( "BinaryHeapType", NewType(HeapFamily, IsBinaryHeapFlatRep and IsMutable));

DeclareGlobalFunction("BinaryHeap");
