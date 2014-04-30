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
DeclareGlobalFunction("PlistQueueExpand");
DeclareGlobalFunction("PListQueueHead");
DeclareGlobalFunction("PListQueueTail");

BindGlobal("QHEAD", 1);
BindGlobal("QTAIL", 2);
BindGlobal("QCAPACITY", 3);
BindGlobal("QDATA", 4);
