##
#R  Read the install files.
##

DeclareInfoClass( "InfoDataStructures" );
SetInfoLevel( InfoDataStructures, 1 );


ReadPackage("datastructures", "gap/lqueue.gi");

ReadPackage("datastructures", "gap/heap.gi");
#ReadPackage("datastructures", "gap/dllist.gi");    # TODO: disabled for now

ReadPackage("datastructures", "gap/binaryheap.gi");
ReadPackage("datastructures", "gap/pairingheap.gi");

ReadPackage("datastructures", "gap/hashmap.gi");

ReadPackage("datastructures", "gap/stack.gi");
ReadPackage("datastructures", "gap/hashfunctions.gi");
