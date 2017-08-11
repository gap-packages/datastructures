#############################################################################
##
#W  lqueue.gd                    GAP library                   Reimer Behrends
##
##
#Y  Copyright (C) 2013 The GAP Group
##
##  This file implements a deque based on a circular buffer. It can be used
##  to implement FIFO queues as well as stacks.
##
###
##
## Imported into GAPdata by Markus Pfeiffer

DeclareRepresentation("IsPlistQueueRep", IsQueue and IsPositionalObjectRep, []);
BindGlobal( "PlistQueueFamily", NewFamily("PlistQueueFamily") );
BindGlobal( "PlistQueueType", NewType(PlistQueueFamily, IsPlistQueueRep and IsMutable) );

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
