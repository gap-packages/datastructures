##
#Y  Copyright (C) 2017 The GAP Group
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
