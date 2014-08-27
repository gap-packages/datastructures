#############################################################################
##
#W    init.g                 The GAPData package              Markus Pfeiffer
##

#############################################################################
##
#R  Read the declaration files.
##

if (not IsBound(__GAPDATA_C)) and ("gapdata" in SHOW_STAT()) then
  LoadStaticModule("gapdata");
fi;
if (not IsBound(__GAPDATA_C)) and
   (Filename(DirectoriesPackagePrograms("gapdata"), "gapdata.so") <> fail) then
  LoadDynamicModule(Filename(DirectoriesPackagePrograms("gapdata"), "gapdata.so"));
fi;

# GAPData global declarations
ReadPackage("gapdata", "gap/data.gd");

# interface definitions
ReadPackage("gapdata", "gap/queue.gd");
ReadPackage("gapdata", "gap/heap.gd");
ReadPackage("gapdata", "gap/prioq.gd");

#ReadPackage("gapdata", "gap/collection.gd");
#ReadPackage("gapdata", "gap/hashtable.gd");
#ReadPackage("gapdata", "gap/cache.gd");
#ReadPackage("gapdata", "gap/dictionary.gd");

# queues implemented by using lists
ReadPackage("gapdata", "gap/lqueue.gd");
# AVL trees
ReadPackage("gapdata", "gap/avltree.gd");
ReadPackage("gapdata", "gap/hash.gd");
ReadPackage("gapdata", "gap/cache.gd");
ReadPackage("gapdata", "gap/dllist.gd");

# Pairing Heaps
ReadPackage("gapdata", "gap/pairingheap.gd");

# ReadPackage("gapdata", "gap/cache2.gd");

#E  init.g . . . . . . . . . . . . . . . . . . . . . . . . . . . .  ends here

