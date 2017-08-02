#############################################################################
##
#W    init.g                 The GAPData package              Markus Pfeiffer
##

#############################################################################
##
#R  Read the declaration files.
##

if (not IsBound(__DATASTRUCTURES_C)) and ("datastructures" in SHOW_STAT()) then
  LoadStaticModule("datastructures");
fi;
if (not IsBound(__DATASTRUCTURES_C)) and
   (Filename(DirectoriesPackagePrograms("datastructures"), "datastructures.so") <> fail) then
  LoadDynamicModule(Filename(DirectoriesPackagePrograms("datastructures"), "datastructures.so"));
fi;

# interface definitions
ReadPackage("datastructures", "gap/queue.gd");
ReadPackage("datastructures", "gap/heap.gd");

# queues implemented by using lists
ReadPackage("datastructures", "gap/lqueue.gd");

ReadPackage("datastructures", "gap/dllist.gd");

# Binary heap
ReadPackage("datastructures", "gap/binaryheap.gd");

# Pairing heaps
ReadPackage("datastructures", "gap/pairingheap.gd");
