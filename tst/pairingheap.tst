gap> START_TEST("pairingheap.tst");
gap> ReadPackage("datastructures", "tst/heaptest.g");;

# run heap tests with pairing heap constructor
gap> TestHeap(PairingHeap);

#
# Test printing
#
gap> heap := PairingHeap();
<pairing heap with 0 entries>
gap> Push(heap, 1);
gap> heap;
<pairing heap with 1 entries>

# Test invalid input
#gap> PairingHeap(1);       # TODO
#gap> PairingHeap(1, 1);    # TODO
gap> PairingHeap(1, 1, 1);
Error, Wrong number of arguments

#
gap> STOP_TEST("pairingheap.tst", 1);
