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

##
## Why doubly linked lists, and not just GAP plain lists:
## Doubly linked lists have better add/remove behaviour than lists
## If things are removed in the middle of a list, you either end up
## with an unbound entry or have to copy entries, both potentially
## expensive operations.
##
## Doubly Linked Lists SHOULD have the following complexity guarantees
## PushFront: O(1)
## PushBack:  O(1)
## Add:       O(n) (O(1) if given a node in the list)
## PopFront:  O(1)
## PopBack:   O(1)
## Remove:    O(n) (O(1) if given a node in the list)
##

InstallGlobalFunction(NewDoublyLinkedListNode,
  function()
    local r;
    r := rec( prev := fail, next := fail, obj := fail );
    return Objectify(DoublyLinkedListNodeType, r);
  end);

InstallGlobalFunction(NewDoublyLinkedList,
  function()
    local l, t;

    l := rec( entry := NewDoublyLinkedListNode(), nrobs := 0 );
    t := NewType(DoublyLinkedListFamily, IsDoublyLinkedListRep and IsMutable);

    l.entry!.next := l.entry;
    l.entry!.prev := l.entry;
    l.entry!.token := true;

    return Objectify(t, l);
  end );

InstallMethod(ViewObj,
  "for doubly linked lists",
  true,
  [IsDoublyLinkedList and IsDoublyLinkedListRep],
  function( dll )
    Print("<doubly linked list with ", dll!.nrobs, " nodes>");
  end );

InstallMethod(InsertBefore,
  "for a doubly linked list, a node, and an object",
  true,
  [ IsDoublyLinkedListRep, IsDoublyLinkedListNode, IsObject ],
  function(dll, nd, obj)
    local newnd;

    newnd := NewDoublyLinkedListNode();
    newnd!.obj := obj;

    newnd!.next := nd;
    newnd!.prev := nd!.prev;

    nd!.prev!.next := newnd;
    nd!.prev := newnd;

    dll!.nrobs :=  dll!.nrobs + 1;
    return newnd;
  end);

InstallMethod(InsertAfter,
  "for a doubly linked list, a node, and an object",
  true,
  [ IsDoublyLinkedListRep, IsDoublyLinkedListNode, IsObject ],
  function(dll, nd, obj)
    local newnd;

    newnd := NewDoublyLinkedListNode();
    newnd!.obj := obj;
    newnd!.next := nd!.next;
    newnd!.prev := nd;

    newnd!.next!.prev := newnd;
    nd!.next := newnd;

    dll!.nrobs :=  dll!.nrobs + 1;
    return newnd;
  end);

InstallMethod(PushFront,
  "for doubly linked lists and an object",
  true,
  [IsDoublyLinkedListRep, IsObject],
  function(dll, obj)
    return InsertAfter(dll, dll!.entry, obj);
  end);

InstallMethod(PushBack,
  "for doubly linked lists and an object",
  true,
  [IsDoublyLinkedListRep, IsObject],
  function(dll, obj)
    return InsertBefore(dll, dll!.entry, obj);
  end);

InstallMethod(Lookup,
  "four doubly linked list and a predicate",
  true,
  [IsDoublyLinkedListRep, IsFunction],
  function(dll, p)
    local nd;

    nd := dll!.entry!.next;

    while not IsBound(nd!.token) do
        if p(nd!.obj) then
            return nd;
        fi;
        nd := nd!.next;
    od;
    return fail;
end);

InstallMethod(Remove,
  "for doubly linked lists and an object",
  true,
  [ IsDoublyLinkedList, IsDoublyLinkedListNode ],
  function(dll, nd)
    if not IsBound(nd!.token) then
      nd!.prev!.next := nd!.next;
      nd!.next!.prev := nd!.prev;
      return nd;
    else
      return fail;
    fi;
  end);


InstallMethod(ViewObj,
  "for doubly linked list nodes",
  true,
  [ IsDoublyLinkedListNodeRep ],
  function(nd)
    Print("<doubly linked list node: ", nd!.obj, ">");
  end);
