#############################################################################
##
#W  heap.gd                    GAPData                      Markus Pfeiffer
##
##
#Y  Copyright (C) 2017 The GAP Group
##
##  This file defines the interface for heaps.
##

## Heaps are always max-heaps, but there should be a way
## to pass a comparison function via an options record, which
## in effect enables the making of min heaps

#! @Chapter Heaps
#!
#! A heap is a tree datastructure that stores items that can be compared using
#! an ordering relation $\leq$ such that for any child $C$ of a node $N$ it holds
#! that $C \leq N$.
#!
#! The fundamental operations for heaps are Construction, <C>Push</C>ing data
#! onto the heap <C>Peek</C>ing at the topmost item, and <C>Pop</C>ping the
#! topmost item off of the heap.
#!
#! For a good heap implementation these basic operations should not exceed
#! $O(\log n)$ in runtime where $n$ is the number of items on the heap.
#!
#! TODO We give theoretical bounds for our implementations in the documentation,
#! and provide some test evidence.

#! @Section Usage
#!
#! gap> h := BinaryHeap();
#! gap> Push(h, 5);
#! gap> Push(h, -10);
#! gap> Peek(h);
#! gap> Pop(h);
#!
#! gap> h := PairingHeap( {x,y} -> x.rank > y.rank );
#! gap> Push(h, rec( rank  := 5 ));
#! gap> Push(h, rec( rank  := 7 ));
#! gap> Push(h, rec( rank  := -15 ));
#! gap> Pop(h);
#!

#! @Section API
#!
#! Every implementation of a heap must follow the API described in this
#! section.
#!

#! @Description
#! Category of heaps
DeclareCategory("IsHeap", IsObject);
BindGlobal( "HeapFamily", NewFamily("HeapFamily") );

#TODO Do we want to use constructors?
# Arguments are a heap filter, a comparison function, and maybe some data?
DeclareConstructor("NewHeap", [IsHeap, IsObject, IsObject]);

#! @Description
#! Throws the object <A>object</A> a new object onto <A>heap</A>.
#!
#! @Arguments heap, object
DeclareOperation("Push", [IsHeap, IsObject]);

#! @Description
#! Inspect the item at the top of <A>heap</A>.
#! @Arguments heap
DeclareOperation("Peek", [IsHeap]);

#! @Description
#! Remove the top item from <A>heap</A> and return it.
#! @Arguments heap
#! @Returns an object
DeclareOperation("Pop", [IsHeap]);

#! @Description
#! Merge two heaps (of the same type)
#! @Arguments heap1, heap2
DeclareOperation("Merge", [IsHeap, IsHeap]);

#! @Description
#! Calls the function constructor to create a heap and
#! then runs some basic tests on it, such as inserting a number of elements and
#! checking that the same elements can be popped off in the same order.
#! @Arguments constructor
DeclareGlobalFunction("TestHeap");

#! @EndSection
