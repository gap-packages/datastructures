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
#R  Read the install files.
##

DeclareInfoClass( "InfoDataStructures" );
SetInfoLevel( InfoDataStructures, 1 );


ReadPackage("datastructures", "gap/plistdeque.gi");

ReadPackage("datastructures", "gap/heap.gi");
#ReadPackage("datastructures", "gap/dllist.gi");    # TODO: disabled for now

ReadPackage("datastructures", "gap/binaryheap.gi");
ReadPackage("datastructures", "gap/pairingheap.gi");

ReadPackage("datastructures", "gap/hashmap.gi");

ReadPackage("datastructures", "gap/stack.gi");
ReadPackage("datastructures", "gap/hashfunctions.gi");
