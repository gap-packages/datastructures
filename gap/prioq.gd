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

DeclareOperation("Push", [IsPriorityQueue, IsInt, IsObject]);
DeclareOperation("Pop", [IsPriorityQueue]);
DeclareOperation("Peek", [IsPriorityQueue]);

DeclareProperty("IsEmpty", IsPriorityQueue);
DeclareAttribute("Length", IsPriorityQueue);
