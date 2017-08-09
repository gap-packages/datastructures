gap> START_TEST("binaryheap.tst");

# binary heap with default order
gap> TestHeap(BinaryHeap, \<);
Creating heap
Adding some random data
After adding 10000 elements heap has size 10000
Popping all data out of heap
Trying to put booleans into heap
Tests end.

# pairing heap with custom order
gap> TestHeap(BinaryHeap, {x,y} -> x > y);
Creating heap
Adding some random data
After adding 10000 elements heap has size 10000
Popping all data out of heap
Trying to put booleans into heap
Tests end.

#
# Test printing
#
gap> heap := BinaryHeap();
<binary heap with 0 entries>
gap> Push(heap, 1);
gap> heap;
<binary heap with 1 entries>

#
gap> STOP_TEST("binaryheap.tst", 1);
