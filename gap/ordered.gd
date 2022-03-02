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
#T what is the equality used in these datastructures?
#T will add corresponding "maps" (where the keys are ordered)
#
##
## Implementations currently available include skip-lists, Binary Search trees
## and AVL trees
##
#
#

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
#!  <Item> They all lie in a common family <C>OrderedSetDSFamily</C>
#!         and pay no attention to the families of the objects stored in them.
#!  </Item>
#!  <Item> Equality of these structures is by identity, not equality of the represented set
#!  </Item>
#!  <Item> The ordering of the objects in the set does not have to be default &GAP;
#!         ordering "less than", but is determined by the attribute <Ref Attr="LessFunction" Label="for IsOrderedSetDS"/>
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
#! @BeginExample
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
#! @EndExample

#! @Section API
#!
#! Every implementation of an ordered set datastructure must follow the API set out below
#!

#! @Description
#! Category of ordered set.
DeclareCategory("IsOrderedSetDS", IsObject);

#! @Description
#! Subcategory of ordered sets where the ordering is &GAP;'s default <C>&lt;</C>
DeclareCategory("IsStandardOrderedSetDS", IsOrderedSetDS);

#! @Description
#! The family that contains all ordered set datastructures.
BindGlobal( "OrderedSetDSFamily", NewFamily("OrderedSetDSFamily") );

#! @Description
#! Constructors for ordered sets
#!
#! The argument <A>filter</A> is a filter that the resulting ordered set
#! object will have.<P/>
#! The optional argument <A>lessThan</A> must be a binary function that returns <K>true</K> if
#! its first argument is less than its second argument, and <K>false</K> otherwise. The default
#! <A>lessThan</A> is &GAP;'s built in <C>&lt;</C>.<P/>
#! The optional argument <A> initialEntries</A> gives a collection of elements that the ordered
#! set is initialised with, and defaults to the empty set.<P/>
#! The optional argument <A>randomSource</A > is
#! useful in a number of possible implementations that use randomised methods
#! to achieve good amortised complexity with high probability and simple data structures. It defaults
#! to the global Mersenne twister.
#!
#! @Arguments filter, [lessThan, [initialEntries, [randomSource]]]
#! @Returns an ordered set datastructure
#!
DeclareConstructor("OrderedSetDS", [IsOrderedSetDS, IsFunction, IsListOrCollection, IsRandomSource]);
DeclareConstructor("OrderedSetDS", [IsOrderedSetDS, IsFunction, IsRandomSource]);
DeclareConstructor("OrderedSetDS", [IsOrderedSetDS, IsListOrCollection, IsRandomSource]);
DeclareConstructor("OrderedSetDS", [IsOrderedSetDS, IsFunction, IsListOrCollection]);
DeclareConstructor("OrderedSetDS", [IsOrderedSetDS, IsFunction]);
DeclareConstructor("OrderedSetDS", [IsOrderedSetDS, IsListOrCollection ]);
DeclareConstructor("OrderedSetDS", [IsOrderedSetDS]);

#! @Description
#!
#! Other constructors cover making an ordered set from another ordered set,
#! from an iterator, from a function and an iterator, or from a function, an iterator
#! and a random source.
#!
# TODO: Document properly or get Steve to do it.
DeclareConstructor("OrderedSetDS", [IsOrderedSetDS, IsOrderedSetDS]);
DeclareConstructor("OrderedSetDS", [IsOrderedSetDS, IsIterator]);
DeclareConstructor("OrderedSetDS", [IsOrderedSetDS, IsFunction, IsIterator]);
DeclareConstructor("OrderedSetDS", [IsOrderedSetDS, IsFunction, IsIterator, IsRandomSource]);


#! @Description
#! Adds <A>object</A> to <A>set</A>. Does nothing if <A>object</A><C>in</C><A>set</A>set.
#!
#! @Arguments set, object
DeclareOperation("AddSet", [IsOrderedSetDS and IsMutable, IsObject]);

#! @Description
#! Removes <A>object</A> from <A>set</A> if present, and
#! returns the number of copies of <A>object</A> that were in <A>set</A>, that is
#! <K>0</K> or <K>1</K>. This for consistency with multisets.
#! @Returns <K>0</K> or <K>1</K>
#! @Arguments set, object
DeclareOperation("RemoveSet", [IsOrderedSetDS and IsMutable, IsObject]);

#! @Description
#! All objects in IsOrderedSetDS must implement \in, which returns <A>true</A>
#! if <A>object</A> is present in <A>set</A> and <K>false</K> otherwise.
#! @Arguments object, set
#DeclareOperation("\in", [IsObject, IsOrderedSetDS]);

#! @Description
#! The binary function to perform the comparison for elements of the set.
#! @Arguments set
DeclareAttribute("LessFunction", IsOrderedSetDS);

#! @Description
#! The number of objects in the set
#! @Arguments set
DeclareAttribute("Size", IsOrderedSetDS);

#! @Description
#! Returns an iterator of <A>set</A> that can be used to iterate through the elements
#! of <A>set</A> in the order imposed by <Ref Attr="LessFunction" Label="for IsOrderedSetDS"/>.
#! @Returns iterator
#! @Arguments set
DeclareOperation("IteratorSorted", [IsOrderedSetDS]);

#! @Section Default methods
#!
#! Default methods based on <Ref Oper="IteratorSorted" BookName="ref"/> are installed for the following
#! operations and attributes, but can be overridden for data structures that
#! support better algorithms.
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

