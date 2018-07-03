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
#! @ChapterLabel HashFunctions
#!
#! @Section Introduction
#!
#! A hash function in <Package>datastructures</Package> is a
#! function <M>H</M> which maps a value <M>X</M> to a small integer (where
#! a small integer is an integer in the range <C>[-2^28..2^28-1]</C>
#! on a 32-bit system, and <C>[-2^60..2^60-1]</C> on a 64-bit system),
#! under the requirement that if <M>X=Y</M>, then <M>H(X)=H(Y)</M>.
#!
#! A variety of hash functions is provided by <Package>datastructures</Package>,
#! with different behaviours. A bad choice of hash function can lead to serious
#! performance problems.
#!
#! <Package>datastructures</Package> does not guarantee consistency of hash
#! values across release or &GAP; sessions.

#! @Section Hash Functions for Basic Types

#! @Description
#! Hashes any values built inductively from
#! <List>
#! <Item> built-in types, namely integers, booleans,
#!        permutations, transformations, partial permutations, and</Item>
#! <Item> constructors for lists and records. </Item>
#! </List>
#!
#! This function is variadic, treating more than one argument
#! as equivalent to a list containing the arguments, that is
#! <C>HashBasic(x,y,z) = HashBasic([x,y,z])</C>.
#! @Arguments obj...
#! @Returns a small integer
DeclareGlobalFunction("HashBasic");

#! @Section Hash Functions for Permutation Groups
#!
#! <Package>datastructures</Package> provides two hash functions for permutation groups;
#! <Ref Func="Hash_PermGroup_Fast"/> is the faster one, with higher likelihood of collisions
#! and <Ref Func="Hash_PermGroup_Complete"/> is slower but provides a lower
#! likelihood of collisions.

#! @Description
#! <Ref Func="Hash_PermGroup_Fast"/> is faster than <Ref Func="Hash_PermGroup_Complete"/>,
#! but will return the same value for groups with the same size, orbits and degree of
#! transitivity.
#! @Arguments group
#! @Returns a small integer
DeclareGlobalFunction("Hash_PermGroup_Fast");

#! @Description
#! <Ref Func="Hash_PermGroup_Complete"/> is slower than <Ref Func="Hash_PermGroup_Fast"/>,
#! but is extremely unlikely to return the same hash for two different groups.
#! @Arguments group
#! @Returns a small integer
DeclareGlobalFunction("Hash_PermGroup_Complete");
