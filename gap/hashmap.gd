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
#! by using a hash function.
#!


#! @Section API
#!
#! @Description
#! Category of hash maps
DeclareCategory( "IsHashMap", IsObject and IsFinite );
BindGlobal( "HashMapFamily", NewFamily("HashMapFamily") );

DeclareRepresentation( "IsHashMapRep", IsHashMap and IsPositionalObjectRep, [] );
BindGlobal( "HashMapType", NewType(HashMapFamily, IsHashMapRep and IsMutable) );


#! Arguments [hashfunc[, eqfunc]] [capacity]
#! Create a new hash map.
DeclareGlobalFunction("HashMap");
