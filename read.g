#############################################################################
##
#W    read.g                 The GAPData package              Markus Pfeiffer
##

#############################################################################
##
#R  Read the install files.
##

DeclareInfoClass( "InfoDataStructures" );
SetInfoLevel( InfoDataStructures, 1 );


ReadPackage("datastructures", "gap/lqueue.gi");

ReadPackage("datastructures", "gap/avltree.gi");
ReadPackage("datastructures", "gap/hash.gi");
ReadPackage("datastructures", "gap/cache.gi");
ReadPackage("datastructures", "gap/dllist.gi");

ReadPackage("datastructures", "gap/pairingheap.gi");


# ReadPackage("datastructures", "gap/cache2.gi");

#E  read.g . . . . . . . . . . . . . . . . . . . . . . . . . . . .  ends here

