gap> START_TEST("binaryheap.tst");
gap> ReadPackage("datastructures", "tst/heaptest.g");;

# run heap tests with binary heap constructor
gap> TestHeap(BinaryHeap);

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
