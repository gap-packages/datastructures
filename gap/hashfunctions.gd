##
##  Datastructures: GAP package providing common datastructures.
##
##  Copyright (C) 2015-2017  The datastructures team.
##  For list of the team members, please refer to the COPYRIGHT file.
##
##  This package is licensed under the GPL 2 or later, please refer
##  to the COPYRIGHT.md and LICENSE files for details.
##

#! @Chapter Hash Functions
#!
#! @Section Introduction
#!
#! A hash function in <Package>datastructures</Package> is a
#! function H which maps a value X to a small integer (where
#! a small integer is an integer in the range [-2^28..2^28-1]
#! on a 32-bit system, and [-2^60..2^60-1] on a 64-bit system),
#! under the requirement that if X=Y, then H(X)=H(Y).
#!
#! A variety of hash functions are provided by
#! <Package>datastructures</Package>, with
#! different behaviours. A bad choice of hash function
#! can lead to serious performance problems.
#!

#! @Section Hash Functions

#! @Description
#! Hashes any values built inductively from the basic built-in types
#! of &GAP;, namely integers, booleans, lists, records, permutations,
#! transformations and partial permutations, and lists and records.
#!
#! Also this function will takes a variadic length
#! list of arguments, treating more than one argument
#! as equivalent to a list, so
#! HashBasic(x,y,z) = HashBasic([x,y,z]).
DeclareGlobalFunction("HashBasic");

#! @Description
#! datastructures provides two hash functions for permutation groups.
#! Hash_PermGroup_Fast is faster, but will return the same
#! value for groups with the same size, orbits and degree of
#! transitivity.
DeclareGlobalFunction("Hash_PermGroup_Fast");

#! @Description
#! datastructures provides two hash functions for permutation groups.
#! Hash_PermGroup_Complete is slower, but is extremely unlikely
#! to return the same hash for two different groups.
DeclareGlobalFunction("Hash_PermGroup_Complete");
