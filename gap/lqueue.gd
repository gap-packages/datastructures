#############################################################################
##
#W  lqueue.gd                    GAP library                   Reimer Behrends
##
##
#Y  Copyright (C) 2013 The GAP Group
##
##  This file implements queues. These can be used both as FIFO queues,
##  as deques, and as stacks.
##
###
##
## Imported into GAPdata by Markus Pfeiffer

DeclareRepresentation("IsPlistQueueRep", IsQueue and IsPositionalObjectRep, []);

DeclareGlobalFunction("PlistQueue");


DeclareGlobalFunction("PlistQueuePushFront");
DeclareGlobalFunction("PlistQueuePushBack");
DeclareGlobalFunction("PlistQueuePopFront");
DeclareGlobalFunction("PlistQueuePopBack");

DeclareGlobalFunction("PlistQueueExpand");
DeclareGlobalFunction("PlistQueueHead");
DeclareGlobalFunction("PlistQueueTail");

DeclareGlobalFunction("PlistQueueCapacity");
DeclareGlobalFunction("PlistQueueLength");

BindGlobal("QHEAD", 1);
BindGlobal("QTAIL", 2);
BindGlobal("QCAPACITY", 3);
BindGlobal("QDATA", 4);
