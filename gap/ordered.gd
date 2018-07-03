#############################################################################
##
#W  ordered.gd                    GAPData                     Steve Linton
##
##
#Y  Copyright (C) 2017 The GAP Group
##
##  This file defines the interface for ordered "set datastructures" (not
##  actually GAP sets for because they ignore families and equality is identity
##  rather than extensional)
##
#T will add corresponding "maps" (where the keys are ordered)
##
## Implementations currently available include skip-lists, Binary Search trees
## and AVL trees
##

#! @Chapter Ordered Set Datastructures
#!
#! In this chapter we deal with datastructures designed to represent sets of
#! objects which have an intrinsic ordering. Such datastructures should support
#! fast (possibly amortised) $O(\log n)$ addition, deletion and membership test
#! operations and allow efficient iteration through all the objects in the
#! datastructure in the order determined by the given comparison function. Since
#! they represent a set, adding an object equal to one already present has no
#! effect.
#!
#
# TODO Give theoretical bounds for our implementations in the documentation,
# and provide some test evidence.
#
#!
#! We refer to these as ordered set <E>datastructure</E> because the differ
#! from the &GAP; notion of a set in a number of ways:
#! <List>
#!  <Item> They all lie in a common family <Ref Fam="OrderedSetDSFamily"/>
#!         and pay no attention to the families of the Objects stored in them.
#!  </Item>
#!  <Item> Equality of these structures is by identity, not equality of the represented set
#!  </Item>
#!  <Item> The ordering of the objects in the set does not have to be default &GAP;
#!         ordering "less than", but is determined by the Attribute <C>LessFunction</C>
#!  </Item>
#! </List>
#!
#!
#! Three implementations of ordered set data structures are currently included:
#! skiplists, binary search trees and (as a specialisation of binary search
#! trees) AVL trees. AVL trees seem to be the fastest in general, and memory
#! usage is similar. More details to come

#! @Section Usage
#!
#! @ExampleSession
#! gap> s := OrderedSetDS(IsSkipListRep, {x,y} -> String(x) < String(y));
#! <skiplist 0 entries>
#! gap> Addset(s, 1);
#! gap> AddSet(s, 2);
#! gap> AddSet(s, 10);
#! gap> AddSet(s, (1,2,3));
#! gap> RemoveSet(s, (1,2,3));
#! 1
#! gap> AsListSorted(s);
#! [ 1, 10, 2 ]
#!
#! gap> b := OrderedSetDS(IsBinarySearchTreeRep, Primes);
#! <bst size 168>
#! gap> 91 in b;
#! false
#! gap> 97 in b;
#! true
#! @EndExampleSession


#! @Section API
#!
#! Every implementation of an ordered set datastructure must follow the API set out below
#!

#! @Description
#! Category of Ordererd "sets"
DeclareCategory("IsOrderedSetDS", IsObject);

#! @Description
#! Subcategory of Ordererd "sets" where the ordering is the default &leq;
DeclareCategory("IsStandardOrderedSetDS", IsOrderedSetDS);

BindGlobal( "OrderedSetDSFamily", NewFamily("OrderedSetDSFamily") );

#! @Description
#! Constructors for ordered sets

#! The general form of constructor.
#!
#! @Arguments filter, lessThan, initial entries, randsom source
#! the random source is useful in a number of possible implementations that used randomised methods
#! to achieve good complexity with high probability and simple data structures
#!
#! Apart from the filter most combinations of these have defaults. The default lessThan  is the &GAP;
#! &lt; function. The default initial entries is none and the default random source is the global Mersenne twister
#!


DeclareConstructor("OrderedSetDS", [IsOrderedSetDS, IsFunction, IsListOrCollection, IsRandomSource]);
DeclareConstructor("OrderedSetDS", [IsOrderedSetDS, IsFunction, IsRandomSource]);
DeclareConstructor("OrderedSetDS", [IsOrderedSetDS, IsListOrCollection, IsRandomSource]);
DeclareConstructor("OrderedSetDS", [IsOrderedSetDS, IsFunction, IsListOrCollection]);
DeclareConstructor("OrderedSetDS", [IsOrderedSetDS, IsFunction]);
DeclareConstructor("OrderedSetDS", [IsOrderedSetDS, IsListOrCollection ]);
DeclareConstructor("OrderedSetDS", [IsOrderedSetDS]);
#!
#!
#! Other constructors cover making an ordered set from another ordered set
#! or from an iterator (which is drained)
#!
DeclareConstructor("OrderedSetDS", [IsOrderedSetDS, IsOrderedSetDS]);
DeclareConstructor("OrderedSetDS", [IsOrderedSetDS, IsIterator]);
DeclareConstructor("OrderedSetDS", [IsOrderedSetDS, IsFunction, IsIterator]);
DeclareConstructor("OrderedSetDS", [IsOrderedSetDS, IsFunction, IsIterator, IsRandomSource]);



#! @Description adds an object to set. Noop if it is already there/
#!
#! @Arguments set, object
DeclareOperation("AddSet", [IsOrderedSetDS and IsMutable, IsObject]);

#! @Description Remove an object from the set if present. Returns the number of copies that
#! were present (always 1 or 0, but an integer for consistency with multisets)
#!
#! @Arguments set, object
DeclareOperation("RemoveSet", [IsOrderedSetDS and IsMutable, IsObject]);
#!
#!
#! All Objects in IsOrderedSetDS should implemnent \in
#!
#DeclareOperation("\in", [IsObject, IsOrderedSetDS]);

#! @Description
#! This is usually stored
DeclareAttribute("LessFunction", IsOrderedSetDS);

#! @Description
#! The number of objects in the set
DeclareAttribute("Size", IsOrderedSetDS);

#! @Description
#! FUndamental method for running through the set in order
DeclareOperation("IteratorSorted", [IsOrderedSetDS]);

#!
#! Default methods based on IteratorSorted are given for these, but
#! can be overridden for data structures that support better alfgorithms
#!

#! @Description
DeclareOperation("Iterator", [IsOrderedSetDS]);

#! @Description
DeclareAttribute("AsSSortedList", IsOrderedSetDS);

#! @Description
DeclareAttribute("AsSortedList", IsOrderedSetDS);

#! @Description
DeclareAttribute("AsList", IsOrderedSetDS);

#! @Description
DeclareAttribute("EnumeratorSorted", IsOrderedSetDS);

#! @Description
DeclareAttribute("Enumerator", IsOrderedSetDS);

#! @Description
DeclareProperty ("IsEmpty", IsOrderedSetDS);

#! @Description
DeclareAttribute("Length", IsOrderedSetDS);

DeclareOperation("ELM_LIST", [IsOrderedSetDS, IsPosInt]);

#! @Description
DeclareOperation("Position", [IsOrderedSetDS, IsObject, IsInt]);

#! @Description
DeclareOperation("PositionSortedOp", [IsOrderedSetDS, IsObject]);
#! @Description
DeclareOperation("PositionSortedOp", [IsOrderedSetDS, IsObject, IsFunction]);


# TODO - maps, cursors, Union and Intersection, Reversed

#! @EndSection

