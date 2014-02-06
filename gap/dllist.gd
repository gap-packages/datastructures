#############################################################################
##
##                             data package
##  dllist.gd
##                                                           Markus Pfeiffer
##
##  Copyright 2013 by the authors.
##  This file is free software, see license information at the end.
##
##  Doubly linked lists.
##
#############################################################################

BindGlobal( "DoublyLinkedListNodesFamily", NewFamily( "DoublyLinkedListNodesFamily" ) );
BindGlobal( "DoublyLinkedListFamily", CollectionsFamily( DoublyLinkedListNodesFamily ) );

DeclareCategory("IsDoublyLinkedList", IsComponentObjectRep and IsCollection);
DeclareRepresentation("IsDoublyLinkedListRep", IsDoublyLinkedList,
        [ "head", "tail", "nrobs" ]);

DeclareCategory("IsDoublyLinkedListNode", IsComponentObjectRep);
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

