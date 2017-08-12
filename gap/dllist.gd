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
##  Doubly linked lists.
##

BindGlobal( "DoublyLinkedListNodesFamily", NewFamily( "DoublyLinkedListNodesFamily" ) );
BindGlobal( "DoublyLinkedListFamily", CollectionsFamily( DoublyLinkedListNodesFamily ) );

DeclareCategory("IsDoublyLinkedList", IsNonAtomicComponentObjectRep and IsObject);
DeclareRepresentation("IsDoublyLinkedListRep", IsDoublyLinkedList,
        [ "head", "tail", "nrobs" ]);

DeclareCategory("IsDoublyLinkedListNode", IsNonAtomicComponentObjectRep);
DeclareRepresentation("IsDoublyLinkedListNodeRep", IsDoublyLinkedListNode,
        [ "next", "prev", "obj" ]);
BindGlobal( "DoublyLinkedListNodeType",
        NewType( DoublyLinkedListNodesFamily, IsDoublyLinkedListNodeRep and IsMutable ) );

# Constructor
DeclareGlobalFunction("NewDoublyLinkedList");
DeclareGlobalFunction("NewDoublyLinkedListNode");

DeclareOperation("InsertAfter", [IsDoublyLinkedList, IsDoublyLinkedListNode, IsObject]);
DeclareOperation("InsertBefore", [IsDoublyLinkedList, IsDoublyLinkedListNode, IsObject]);

DeclareOperation("PushFront", [IsDoublyLinkedList, IsObject]);
DeclareOperation("PushBack", [IsDoublyLinkedList, IsObject]);

DeclareOperation("Remove", [IsDoublyLinkedList, IsDoublyLinkedListNode]);
DeclareOperation("Lookup", [IsDoublyLinkedList, IsFunction]);

