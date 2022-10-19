##
##  Datastructures: GAP package providing common datastructures.
##
##  Copyright (C) 2015-2017  The datastructures team.
##  For list of the team members, please refer to the COPYRIGHT file.
##
##  This package is licensed under the GPL 2 or later, please refer
##  to the COPYRIGHT.md and LICENSE files for details.
##

#! @Chapter Hashsets
#!
#! A hash set stores objects and allows efficient lookup whether an object
#! is already a member of the set.
#!
#! <Package>datastructures</Package> currently provides a reference implementation
#! of hashsets using a hashtable stored in a plain &GAP; list.

#! @Section API
#!
#! @Description
#! Category of hashsets
DeclareCategory( "IsHashSet", IsObject and IsFinite );
BindGlobal( "HashSetFamily", NewFamily("HashSetFamily") );

DeclareRepresentation( "IsHashSetRep", IsHashSet and IsPositionalObjectRep, [] );
BindGlobal( "HashSetType", NewType(HashSetFamily, IsHashSetRep and IsMutable) );

#! @Description
#! Create a new hashset. The optional argument <A>values</A> must be a list of values,
#! which will be inserted into the new hashset in order.
#! The optional argument <A>hashfunc</A> must be a hash-
#! function, <A>eqfunc</A> must
#! be a binary equality testing function that returns <K>true</K> if the two arguments
#! are considered equal, and <K>false</K> if they are not. Refer to Chapter
#! <Ref Chap="Chapter_HashFunctions"/> about the requirements for hashfunctions and
#! equality testers.
#! The optional argument <A>capacity</A> determines the initial size of the hashmap.
#!
#! @Arguments [values] [hashfunc[, eqfunc]] [capacity]
DeclareGlobalFunction("HashSet");
