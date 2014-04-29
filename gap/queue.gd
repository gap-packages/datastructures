#############################################################################
##
#W  queue.gd                    GAP library                   Reimer Behrends
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

#############################################################################
##
## Queue Interface
##
## A queue only promises access at the front and at the back
##
DeclareCategory("IsQueue", IsCollection);

DeclareConstructor("NewQueue", [IsQueue, IsObject, IsPosInt]);

DeclareOperation("PushQueueBack", [IsQueue, IsObject]);
DeclareOperation("PushQueueFront", [IsQueue, IsObject]);
DeclareSynonym("PushQueue", PushQueueBack);

DeclareOperation("PopQueueBack", [IsQueue]);
DeclareOperation("PopQueueFront", [IsQueue]);
DeclareSynonym("PopQueue", PopQueueFront);

DeclareProperty("IsEmpty", IsQueue);
DeclareAttribute("Length", IsQueue);
DeclareAttribute("Capacity", IsQueue);

  
# The implementation we will provide
DeclareRepresentation("IsPlistQueueRep", IsQueue and IsPositionalObjectRep, []);
DeclareGlobalFunction("PlistQueueExpand");
DeclareGlobalFunction("PListQueueHead");
DeclareGlobalFunction("PListQueueTail");

BindGlobal("QHEAD", 1);
BindGlobal("QTAIL", 2);
BindGlobal("QCAPACITY", 3);
BindGlobal("QDATA", 4);
