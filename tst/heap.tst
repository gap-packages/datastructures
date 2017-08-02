# Test heaps
gap> START_TEST("datastructures package: heap.tst");

# Binary Heap
gap> TestHeap(BinaryHeap);
Creating Heap
Adding some random data
After adding 10000 elements heap has size 10000
Popping all data out of heap
Tests end.

# Pairing Heap
gap> TestHeap(PairingHeap);
Creating Heap
Adding some random data
After adding 10000 elements heap has size 10000
Popping all data out of heap
Tests end.

#
gap> STOP_TEST( "datastructures package: heap.tst", 10000);
