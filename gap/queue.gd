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
DeclareCategory("IsQueue", IsObject);

# Hack because HPCGAP has a NewQueue
DeclareConstructor("NewQueue_", [IsQueue, IsObject, IsPosInt]);

DeclareOperation("PushBack", [IsQueue, IsObject]);
DeclareOperation("PushFront", [IsQueue, IsObject]);
DeclareOperation("Push", [IsQueue, IsObject]);

DeclareOperation("PopBack", [IsQueue]);
DeclareOperation("PopFront", [IsQueue]);
DeclareOperation("Pop", [IsQueue]);

#DeclareProperty("IsEmpty", IsQueue);
#DeclareAttribute("Size", IsQueue);
DeclareAttribute("Capacity", IsQueue);

