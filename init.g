#############################################################################
##
#W    init.g                 The GAPData package              Markus Pfeiffer
##

#############################################################################
##
#R  Read the declaration files.
##

if (not IsBound(__GAPDATA_C)) and ("datastructures" in SHOW_STAT()) then
  LoadStaticModule("datastructures");
fi;
if (not IsBound(__GAPDATA_C)) and
   (Filename(DirectoriesPackagePrograms("datastructures"), "datastructures.so") <> fail) then
  LoadDynamicModule(Filename(DirectoriesPackagePrograms("datastructures"), "datastructures.so"));
fi;

# GAPData global declarations
ReadPackage("datastructures", "gap/data.gd");

# interface definitions
ReadPackage("datastructures", "gap/queue.gd");
ReadPackage("datastructures", "gap/heap.gd");
ReadPackage("datastructures", "gap/prioq.gd");

#ReadPackage("datastructures", "gap/collection.gd");
#ReadPackage("datastructures", "gap/hashtable.gd");
#ReadPackage("datastructures", "gap/cache.gd");
#ReadPackage("datastructures", "gap/dictionary.gd");

# queues implemented by using lists
ReadPackage("datastructures", "gap/lqueue.gd");
# AVL trees
ReadPackage("datastructures", "gap/avltree.gd");
ReadPackage("datastructures", "gap/hash.gd");
ReadPackage("datastructures", "gap/cache.gd");
ReadPackage("datastructures", "gap/dllist.gd");

# Pairing Heaps
ReadPackage("datastructures", "gap/pairingheap.gd");

# ReadPackage("datastructures", "gap/cache2.gd");

#E  init.g . . . . . . . . . . . . . . . . . . . . . . . . . . . .  ends here

