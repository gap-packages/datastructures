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
##  This file defines the interface for heaps.
##

#! @Chapter Heaps
#!
#! @Section Introduction
#! A <E>heap</E > is a tree datastructure  such that for any child $C$ of a node $N$
#! it holds that $C \leq N$, according to some ordering relation $\leq$.
#!
#! The fundamental operations for heaps are Construction, <C>Push</C>ing data
#! onto the heap, <C>Peek</C>ing at the topmost item, and <C>Pop</C>ping the
#! topmost item off of the heap.
#!
#! For a good heap implementation these basic operations should not exceed
#! $O(\log n)$ in runtime where $n$ is the number of items on the heap.
#!
#
# TODO: Give theoretical bounds for our implementations in the documentation,
# and provide some test evidence.
#!
#! We currently provide two types of heaps: Binary Heaps <Ref Sect='Section_BinaryHeap'/> and
#! Pairing Heaps <Ref Sect="Section_PairingHeap" />.<P/>
#!
#! The following code shows how to use a binary heap.
#! @BeginExample
#! gap> h := BinaryHeap();
#! <binary heap with 0 entries>
#! gap> Push(h, 5);
#! gap> Push(h, -10);
#! gap> Peek(h);
#! 5
#! gap> Pop(h);
#! 5
#! gap> Peek(h);
#! -10
#! @EndExample
#!
#! The following code shows how to use a pairing heap.
#! @BeginExample
#! gap> h := PairingHeap( {x,y} -> x.rank > y.rank );
#! <pairing heap with 0 entries>
#! gap> Push(h, rec( rank  := 5 ));
#! gap> Push(h, rec( rank  := 7 ));
#! gap> Push(h, rec( rank  := -15 ));
#! gap> h;
#! <pairing heap with 3 entries>
#! gap> Peek(h);
#! rec( rank := -15 )
#! gap> Pop(h);
#! rec( rank := -15 )
#! @EndExample

#! @Section API
#!
#! For the purposes of the <Package>datastructures</Package>, we provide
#! a category <Ref Filt="IsHeap" Label="for IsObject"/> . Every
#! implementation of a heap in the category <Ref Filt="IsHeap" Label="for IsObject"/>
#! must follow the API described in this section.
#!

#! @Description
#! The category of heaps. Every object in this category promises to
#! support the API described in this section.
DeclareCategory("IsHeap", IsObject);
BindGlobal( "HeapFamily", NewFamily("HeapFamily") );


#! @Description
#! Wrapper function around constructors
DeclareGlobalFunction("Heap");

#! @Description
#! Construct a new heap
#!
#! @Arguments [filter, func, data]
#! @Returns a heap
DeclareConstructor("NewHeap", [IsHeap, IsObject, IsObject]);

#! @Description
#! Puts the object <A>object</A> a new object onto <A>heap</A>.
#!
#! @Arguments heap, object
DeclareOperation("Push", [IsHeap, IsObject]);

#! @Description
#! Inspect the item at the top of <A>heap</A>.
#!
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

# TODO: find out how to properly docuymnt this without a `DeclareOperation`
#! Heaps also support <Ref Filt="IsEmpty" BookName="ref"/> and
#! <Ref Oper="Size" BookName="ref"/>
