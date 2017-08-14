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
#! A hash set stores key-value pairs and allows efficient lookup of keys
#! by using a hash function.
#!


#! @Section API
#!
#! @Description
#! Category of hashsets
DeclareCategory( "IsHashSet", IsObject and IsFinite );
BindGlobal( "HashSetFamily", NewFamily("HashSetFamily") );

DeclareRepresentation( "IsHashSetRep", IsHashSet and IsPositionalObjectRep, [] );
BindGlobal( "HashSetType", NewType(HashSetFamily, IsHashSetRep and IsMutable) );


#! Arguments [hashfunc[, eqfunc]] [capacity]
#! Create a new hash set.
DeclareGlobalFunction("HashSet");
