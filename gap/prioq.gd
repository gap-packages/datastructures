#############################################################################
##
#W  prioq.gd                    GAPData                      Markus Pfeiffer
##
##
#Y  Copyright (C) 2014 The GAP Group
##
##  This file implements priority queues.
##

#############################################################################
##
## Priority Queue Interface
##
## A priority queue only promises access by pushng with a priority and
## popping
##


DeclareCategory("IsPriorityQueue", IsCollection);

DeclareConstructor("NewPriorityQueue", [IsPriorityQueue, IsObject]);

DeclareOperation("Push", [IsPriorityQueue, IsInt]);
DeclareOperation("Pop", [IsPriorityQueue]);
DeclareOperation("Peek", [IsPriorityQueue]);

DeclareProperty("IsEmpty", IsPriorityQueue);
#DeclareProperty("Capacity", IsPriorityQueue);

#

DeclareRepresentation("IsAVLTreePrioQRep", IsPriorityQueue and IsPositionalObjectRep, []);


