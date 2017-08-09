gap> START_TEST("pairingheap.tst");

# pairing heap with default order
gap> TestHeap(PairingHeap, \<);
Creating heap
Adding some random data
After adding 10000 elements heap has size 10000
Popping all data out of heap
Trying to put booleans into heap
Tests end.

# pairing heap with custom order
gap> TestHeap(PairingHeap, {x,y} -> x > y);
Creating heap
Adding some random data
After adding 10000 elements heap has size 10000
Popping all data out of heap
Trying to put booleans into heap
Tests end.

#
# Test printing
#
gap> heap := PairingHeap();
<pairing heap with 0 entries>
gap> Push(heap, 1);
gap> heap;
<pairing heap with 1 entries>

#
gap> STOP_TEST("pairingheap.tst", 1);
