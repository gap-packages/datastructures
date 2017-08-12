##
##  Datastructures: GAP package providing common datastructures.
##
##  Copyright (C) 2015-2017  The datastructures team.
##  For list of the team members, please refer to the COPYRIGHT file.
##
##  This package is licensed under the GPL 2 or later, please refer
##  to the COPYRIGHT.md and LICENSE files for details.
##

##
##  This file implements queues. These can be used both as FIFO queues,
##  as deques, and as stacks.
##

#! @Chapter Queues
#!
#! A queue only promises access at the front and at the back

#! @Section API
#!

#!
DeclareCategory("IsQueue", IsObject);

# Hack because HPCGAP has a NewQueue
DeclareConstructor("NewQueue_", [IsQueue, IsObject, IsPosInt]);

#!
DeclareOperation("PushBack", [IsQueue, IsObject]);

#!
DeclareOperation("PushFront", [IsQueue, IsObject]);

#! For queues, this is just an alias for PushBack
DeclareOperation("Push", [IsQueue, IsObject]);

#!
DeclareOperation("PopBack", [IsQueue]);

#!
DeclareOperation("PopFront", [IsQueue]);

#! For queues, this is just an alias for PopFront
DeclareOperation("Pop", [IsQueue]);

#!
DeclareAttribute("Capacity", IsQueue);

