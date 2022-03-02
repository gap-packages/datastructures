##
##  Datastructures: GAP package providing common datastructures.
##
##  Copyright (C) 2015-2017  The datastructures team.
##  For list of the team members, please refer to the COPYRIGHT file.
##
##  This package is licensed under the GPL 2 or later, please refer
##  to the COPYRIGHT.md and LICENSE files for details.
##

#! @Chapter Queues and Deques
#!
#! <E>Queues</E> are linear data structure that allow adding elements at the end of the queue,
#! and removing elements from the front.
#! A <E>deque</E> is a <E>double-ended queue</E>; a linear data structure that allows access
#! to objects at both ends.<P/>
#!
#! The API that objects that lie in <Ref Filt="IsQueue" Label="for IsObject"/> and
#! <Ref Filt="IsDeque" Label="for IsObject"/> must implement the API set out below.
#!
#! <Package>datastructures</Package> provides
#!
#!
#! @Section API
#!

#! @Description
#! The category of queues.
DeclareCategory("IsQueue", IsObject);

#! @Description
#! The category of deques.
DeclareCategory("IsDeque", IsObject);

##! @Description
## Hack because HPCGAP has a NewQueue
## DeclareConstructor("NewQueue_", [IsQueue, IsObject, IsPosInt]);

#! @Description
# Hack because HPCGAP has a NewQueue
DeclareConstructor("NewDeque", [IsDeque, IsObject, IsPosInt]);

#! @Description
#! Add <A>object</A> to the back of <A>deque</A>.
#! @Arguments deque, object
DeclareOperation("PushBack", [IsDeque, IsObject]);

#! @Description
#! Add <A>object</A> to the front of <A>deque</A>.
#! @Arguments deque, object
DeclareOperation("PushFront", [IsDeque, IsObject]);

#! @Description
#! Remove an element from the back of <A>deque</A> and return it.
#! @Arguments deque
#! @Returns object
DeclareOperation("PopBack", [IsDeque]);

#! @Description
#! Remove an element from the front of <A>deque</A> and return it.
#! @Arguments deque
#! @Returns object
DeclareOperation("PopFront", [IsDeque]);

#! For queues, this is just an alias for PushBack
#! @Description
#! Add <A>object</A> to <A>queue</A>.
#! @Arguments queue, object
DeclareOperation("Enqueue", [IsQueue, IsObject]);

#! @Description
#! Remove an object from the front of <A>queue</A> and return it.
#! @Arguments queue
#! @Returns object
DeclareOperation("Dequeue", [IsQueue, IsObject]);

#! @Description
#! Allocated storage capacity of <A>queue</A>.
DeclareAttribute("Capacity", IsQueue);
#! @Description
#! Allocated storage capacity of <A>deque</A>.
DeclareAttribute("Capacity", IsDeque);

#! @Description
#! Number of elements in <A>queue</A>.
DeclareAttribute("Length", IsQueue);
#! @Description
#! Number of elements in <A>deque</A>.
DeclareAttribute("Length", IsDeque);

