#############################################################################
##
#W    init.g                 The GAPData package              Markus Pfeiffer
##

#############################################################################
##
#R  Read the declaration files.
##

# GAPData global declarations
ReadPackage("gapdata", "gap/data.gd");

# Queues
ReadPackage("gapdata", "gap/queue.gd");


ReadPackage("gapdata", "gap/avltree.gd");
ReadPackage("gapdata", "gap/hash.gd");
ReadPackage("gapdata", "gap/cache.gd");
ReadPackage("gapdata", "gap/dllist.gd");

# ReadPackage("gapdata", "gap/cache2.gd");

#E  init.g . . . . . . . . . . . . . . . . . . . . . . . . . . . .  ends here

