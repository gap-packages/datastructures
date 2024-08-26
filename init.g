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
#R  Read the declaration files.
##

if not LoadKernelExtension("datastructures") then
  Error("failed to load the datastructures package kernel extension");
fi;

# interface definitions
ReadPackage("datastructures", "gap/queue.gd");
ReadPackage("datastructures", "gap/heap.gd");
ReadPackage("datastructures", "gap/ordered.gd");


# deque implemented using a circular buffer
ReadPackage("datastructures", "gap/plistdeque.gd");

# doubly linked list
#ReadPackage("datastructures", "gap/dllist.gd");    # TODO: disabled for now

# Binary heap
ReadPackage("datastructures", "gap/binaryheap.gd");

# Pairing heaps
ReadPackage("datastructures", "gap/pairingheap.gd");

# hash maps
ReadPackage("datastructures", "gap/hashmap.gd");

# hash sets
ReadPackage("datastructures", "gap/hashset.gd");

# Slices
ReadPackage("datastructures", "gap/slice.gd");

# Stacks
ReadPackage("datastructures", "gap/stack.gd");

# Hash functions
ReadPackage("datastructures", "gap/hashfunctions.gd");

# Union-find
ReadPackage("datastructures", "gap/union-find.gd");

# Memoising functions
ReadPackage("datastructures", "gap/memoize.gd");
