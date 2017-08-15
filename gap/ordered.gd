#############################################################################
##
#W  ordered.gd                    GAPData                     Steve Linton
##
##
#Y  Copyright (C) 2017 The GAP Group
##
##  This file defines the interface for ordered "sets" (not actually GAP
##  sets because they ignore families) and "maps" (where the keys are ordered)
##
##
## Implementations will be things like skip-lists, AVL trees, ...
##


#! @Section API
#!
#! Every implementation of a heap must follow the API described in this
#! section. This is however temporary pending the discussion oftypes for data structutes
#!

#! @Description
#! Category of Ordererd "sets"

DeclareCategory("IsOrderedSetDS", IsObject);

BindGlobal( "OrderedSetsFamily", NewFamily("OrderedSetsFamily") ); 

#TODO Do we want to use constructors?
# Arguments are a filter, a comparison function. We might add other declarations later
# for other constructors

DeclareConstructor("OrderedSetDS", [IsOrderedSetDS, IsFunction]);

DeclareConstructor("OrderedSetDS", [IsOrderedSetDS]);

DeclareConstructor("OrderedSetDS", [IsOrderedSetDS, IsFunction, IsRandomSource]);

DeclareConstructor("OrderedSetDS", [IsOrderedSetDS, IsSet]);

DeclareConstructor("OrderedSetDS", [IsOrderedSetDS, IsOrderedSetDS]);

DeclareConstructor("OrderedSetDS", [IsOrderedSetDS, IsFunction, IsListOrCollection]);

DeclareConstructor("OrderedSetDS", [IsOrderedSetDS, IsFunction, IsIterator]);
DeclareConstructor("OrderedSetDS", [IsOrderedSetDS, IsFunction, IsListOrCollection, IsRandomSource]);
DeclareConstructor("OrderedSetDS", [IsOrderedSetDS, IsFunction, IsIterator, IsRandomSource]);



#! @Description adds an object to set. Noop if it is already there for set-like datastructures
#! 
#!
#! @Arguments set, object
DeclareOperation("AddSet", [IsOrderedSetDS and IsMutable, IsObject]);

#! @Description Remove an object from the set if present. Returns the number of copies that 
#! were present (always 1 or 0, but an integers for consistency with multisets)
#!
#! @Arguments set, object
DeclareOperation("RemoveSet", [IsOrderedSetDS and IsMutable, IsObject]);

#DeclareOperation("\in", [IsObject, IsOrderedSetDS]);


DeclareAttribute("Size", IsOrderedSetDS);


DeclareOperation("IteratorSorted", [IsOrderedSetDS]);

DeclareOperation("Iterator", [IsOrderedSetDS]);

DeclareAttribute("AsListSorted", IsOrderedSetDS);

DeclareAttribute("AsList", IsOrderedSetDS);

DeclareAttribute("EnumeratorSorted", IsOrderedSetDS);

DeclareProperty ("IsEmpty", IsOrderedSetDS);



# TODO - maps, cursors, Union and Intersection?? 


#! @EndSection
