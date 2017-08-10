##
#Y  Copyright (C) 2017 The GAP Group
##

#! @Chapter Stacks
#!
#! A stack is a deque where items can be <C>Push</C>ed onto the stack, and
#! the top item can be <C>Pop</C>ped off the stack.
#!
#! Stacks are wrapped GAP Plain lists.


#! @Section API
#!
#! @Description
#! Category of heaps
DeclareCategory("IsStack", IsObject);
BindGlobal( "StackFamily", NewFamily("StackFamily") );

#! @Description
#! Puts the object <A>object</A> a new object onto <A>stack</A>.
#!
#! @Arguments stack, object
DeclareOperation("Push", [IsStack, IsObject]);

#! @Description
#! Inspect the item at the top of <A>stack</A>.
#! @Arguments stack
DeclareOperation("Peek", [IsStack]);

#! @Description
#! Remove the top item from <A>stack</A> and return it.
#! @Arguments stack
#! @Returns an object
DeclareOperation("Pop", [IsStack]);


#
DeclareRepresentation( "IsStackPlistRep", IsStack and IsPositionalObjectRep, []);
BindGlobal( "StackType", NewType(StackFamily, IsStackPlistRep));
BindGlobal( "StackTypeMutable", NewType(StackFamily,
                                        IsStackPlistRep and IsMutable));


DeclareGlobalFunction("Stack");


