#############################################################################
##
#W  heap.gd                    GAPData                      Markus Pfeiffer
##
##
#Y  Copyright (C) 2014 The GAP Group
##
##  This file defines the interface for heaps.
##

## Heaps are always max-heaps, but there should be a way
## to pass a comparison function via an options record, which
## in effect enables the making of min heaps
DeclareCategory("IsHeap", IsCollection);
BindGlobal( "HeapFamily", NewFamily("HeapFamily") );

DeclareConstructor("NewHeap", [IsHeap, IsObject, IsObject, IsObject]);

# Inserts a new key into the heap.
DeclareOperation("Push", [IsHeap, IsObject, IsObject]);
# Peek the item with the maximal key
DeclareOperation("Peek", [IsHeap]);
# Get the the item with the maximal key
DeclareOperation("Pop", [IsHeap]);
# Merge two heaps (of the same type)
DeclareOperation("Merge", [IsHeap, IsHeap]);

#
DeclareAttribute("Size", IsHeap);



