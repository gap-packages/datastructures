##
##  Datastructures: GAP package providing common datastructures.
##
##  Copyright (C) 2015-2017  The datastructures team.
##  For list of the team members, please refer to the COPYRIGHT file.
##
##  This package is licensed under the GPL 2 or later, please refer
##  to the COPYRIGHT.md and LICENSE files for details.
##

#! @Chapter Stacks
#!
#! A stack is a deque where items can be <C>Push</C>ed onto the stack, and
#! the top item can be <C>Pop</C>ped off the stack.
#!
#! Stacks are wrapped GAP plain lists.


#! @Section API
#!
#! @Description
#! Constructor for stacks
#! @Arguments
#! @Returns stack
DeclareGlobalFunction("Stack");

#! @Description
#! Category of heaps
DeclareCategory("IsStack", IsObject);
BindGlobal( "StackFamily", NewFamily("StackFamily") );

#! @Description
#! Puts <A>object</A> onto <A>stack</A>.
#!
#! @Arguments stack, object
DeclareOperation("Push", [IsStack, IsObject]);

#! @Description
#! Return the object at the top of <A>stack</A>. If <A>stack</A> is empty,
#! returns <K>fail</K>
#! @Arguments stack
#! @Returns object or <K>fail</K>
DeclareOperation("Peek", [IsStack]);

#! @Description
#! Remove the top item from <A>stack</A> and return it.
#! If <A>stack</A> is empty, this function returns fail.
#! @Arguments stack
#! @Returns object or <K>fail</K>
DeclareOperation("Pop", [IsStack]);

#
DeclareRepresentation( "IsStackPlistRep", IsStack and IsPositionalObjectRep, []);
BindGlobal( "StackType", NewType(StackFamily, IsStackPlistRep));
BindGlobal( "StackTypeMutable", NewType(StackFamily,
                                        IsStackPlistRep and IsMutable));
#! @Description
#! Number of elements on <A>stack</A>
#DeclareAttribute(Size, [IsStack]);

