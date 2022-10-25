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
#! @Section Deques implemented using plain lists
#!
#! <Package>datastructures</Package> implements deques
#! using a circular buffer stored in a &GAP; a plain list,
#! wrapped in a positional object (<Ref Sect="Positional Objects" BookName="ref"/>).
#!
#! The five positions in such a deque <C>Q</C> have the following purpose
#!
#! <List>
#! <Item><C>Q![1]</C> - head, the index in <C>Q![5]</C> of the first element in the deque</Item>
#! <Item><C>Q![2]</C> - tail, the index in <C>Q![5]</C> of the last element in the deque</Item>
#! <Item><C>Q![3]</C> - capacity, the allocated capacity in the deque</Item>
#! <Item><C>Q![4]</C> - factor by which storage is increased if capacity is exceeded</Item>
#! <Item><C>Q![5]</C> - GAP plain list with storage for capacity many entries</Item>
#! </List>
#!
#! Global constants <K>QHEAD</K>, <K>QTAIL</K>, <K>QCAPACITY</K>, <K>QFACTOR</K>, and
#! <K>QDATA</K> are bound to reflect the above.
#! <P/>
#! When a push fills the deque, its capacity is resized by a factor of <K>QFACTOR</K> using
#! PlistDequeExpand. A new empty plist is allocated and all current entries of
#! the deque are copied into the new plist with the head entry at index 1.
#! <P/>
#! The deque is empty if and only if head = tail and the entry that head and tail
#! point to in the storage list is unbound.
#

DeclareRepresentation("IsPlistDequeRep",
                      IsDeque and IsPositionalObjectRep,
                      []);
BindGlobal( "PlistDequeFamily", NewFamily("PlistDequeFamily") );
BindGlobal( "PlistDequeType",
            NewType(PlistDequeFamily, IsPlistDequeRep and IsMutable) );

#! @Description
#! Constructor for plist based deques. The optional argument <A>capacity</A> must be
#! a positive integer and is the capacity of the created deque, and the optional
#! argument <A>factor</A> must be a rational number greater than one which is
#! the factor by which the storage of the deque is increased if it runs out of capacity
#! when an object is put on the queue.
#! @Arguments [capacity, [factor]]
#! @Returns a deque
DeclareGlobalFunction("PlistDeque");

#! @Description
#! Push <A>object</A> to the front of <A>deque</A>.
#! @Arguments deque, object
#! @Returns
DeclareGlobalFunction("PlistDequePushFront");
#! @Description
#! Push <A>object</A> to the back of <A>deque</A>.
#! @Arguments deque, object
#! @Returns
DeclareGlobalFunction("PlistDequePushBack");
#! @Description
#! Pop object from the front of <A>deque</A> and return it.
#! If <A>deque</A> is empty, returns <K>fail</K>.
#! @Arguments deque
#! @Returns object or fail
DeclareGlobalFunction("PlistDequePopFront");
#! @Description
#! Pop object from the back of <A>deque</A> and return it.
#! If <A>deque</A> is empty, returns <K>fail</K>.
#! @Arguments deque
#! @Returns object or fail
DeclareGlobalFunction("PlistDequePopBack");
#! @Description
#! Returns the object at the front <A>deque</A> without removing it.
#! If <A>deque</A> is empty, returns <K>fail</K>.
#! @Arguments deque
#! @Returns object or fail
DeclareGlobalFunction("PlistDequePeekFront");
#! @Description
#! Returns the object at the back <A>deque</A> without removing it.
#! If <A>deque</A> is empty, returns <K>fail</K>.
#! @Arguments deque
#! @Returns object or fail
DeclareGlobalFunction("PlistDequePeekBack");

#! @Description
#! Helper function to expand the capacity of <A>deque</A> by the
#! configured factor.
#! @Arguments deque
#! @Returns
DeclareGlobalFunction("PlistDequeExpand");

# TODO: Do we need these? They're not implemented atm.
# DeclareGlobalFunction("PlistDequeHead");
# DeclareGlobalFunction("PlistDequeTail");
# DeclareGlobalFunction("PlistDequeCapacity");
# DeclareGlobalFunction("PlistDequeLength");

BindConstant("QHEAD", 1);
BindConstant("QTAIL", 2);
BindConstant("QCAPACITY", 3);
BindConstant("QFACTOR", 4);
BindConstant("QDATA", 5);
