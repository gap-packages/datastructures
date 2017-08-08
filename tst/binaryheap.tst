gap> START_TEST("binaryheap.tst");

# Binary Heap
gap> TestHeap(BinaryHeap);
Creating Heap
Adding some random data
After adding 10000 elements heap has size 10000
Popping all data out of heap
Trying to put booleans into heap
Creating Heap With Comparison
After adding 10000 elements heap has size 10000
Tests end.

#
# Test heap with custom comparison function
#
gap> heap := BinaryHeap( {x,y} -> x > y, [ 1..10 ] );
<binary heap with 10 entries>
gap> list := [];; while not IsEmpty(heap) do
>   Assert(0, BinaryHeap_IsValid(heap));
>   Add(list, Pop(heap));
> od;
gap> list;
[ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 ]

# usual less, but "in disguise"
gap> heap := BinaryHeap( {x,y} -> x < y, [ 1..10 ] );
<binary heap with 10 entries>
gap> list := [];; while not IsEmpty(heap) do
>   Assert(0, BinaryHeap_IsValid(heap));
>   Add(list, Pop(heap));
> od;
gap> list;
[ 10, 9, 8, 7, 6, 5, 4, 3, 2, 1 ]

# standard comparison
gap> heap := BinaryHeap( \<, [ 1..10 ] );
<binary heap with 10 entries>
gap> list := [];; while not IsEmpty(heap) do
>   Assert(0, BinaryHeap_IsValid(heap));
>   Add(list, Pop(heap));
> od;
gap> list;
[ 10, 9, 8, 7, 6, 5, 4, 3, 2, 1 ]

#
gap> STOP_TEST("binaryheap.tst", 1);
