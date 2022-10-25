##
##  Datastructures: GAP package providing common datastructures.
##
##  Copyright (C) 2015-2017  The datastructures team.
##  For list of the team members, please refer to the COPYRIGHT file.
##
##  This package is licensed under the GPL 2 or later, please refer
##  to the COPYRIGHT.md and LICENSE files for details.
##

#! @Chapter Hashmaps
#!
#! A hash map stores key-value pairs and allows efficient lookup of keys
#! by using a hash function.<P/>
#!
#! <Package>datastructures</Package> currently provides a reference implementation
#! of hashmaps using a hashtable stored in a plain &GAP; list.
#!
#! @Section API
#!
#! @Description
#! Category of hash maps
DeclareCategory( "IsHashMap", IsObject and IsFinite );
BindGlobal( "HashMapFamily", NewFamily("HashMapFamily") );

DeclareRepresentation( "IsHashMapRep", IsHashMap and IsPositionalObjectRep, [] );
BindGlobal( "HashMapType", NewType(HashMapFamily, IsHashMapRep and IsMutable) );

#! @Description
#! Create a new hash map. The optional argument <A>values</A> must be a list of
#! key-value pairs which will be inserted into the new hashmap in order.
#! The optional argument <A>hashfunc</A> must be a hash-function, <A>eqfunc</A> must
#! be a binary equality testing function that returns <K>true</K> if the two arguments
#! are considered equal, and <K>false</K> if they are not. Refer to Chapter
#! <Ref Chap="Chapter_HashFunctions"/> about the requirements for hashfunctions and
#! equality testers.
#! The optional argument <A>capacity</A> determines the initial size of the hashmap.
#!
#! @Arguments [values] [hashfunc[, eqfunc]] [capacity]
DeclareGlobalFunction("HashMap");

#! @Description
#! Returns the list of keys of the hashmap <A>h</A>.
#! @Arguments h
#! @Returns a list
DeclareOperation("Keys", [IsHashMap]);
#! @Description
#! Returns the set of values stored in the hashmap <A>h</A>. 
#! @Arguments h
#! @Returns a list
DeclareOperation("Values", [IsHashMap]);

#! @Description
#! Returns an iterator for the keys stored in the hashmap <A>h</A>.
#! @Arguments h
#! @Returns an iterator
DeclareOperation("KeyIterator", [IsHashMap]);
#! @Description
#! Returns an iterator for the values stored in the hashmap <A>h</A>.
#! @Arguments h
#! @Returns an iterator
DeclareOperation("ValueIterator", [IsHashMap]);
#! @Description
#! Returns an iterator for key-value-pairs stored in the hashmap <A>h</A>.
#! @Arguments h
#! @Returns an iterator
DeclareOperation("KeyValueIterator", [IsHashMap]);
