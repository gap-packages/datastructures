##
#Y  Copyright (C) 2017 The GAP Group
##

#! @Chapter Hashmaps
#!
#! A hashmap stores key-value pairs and allows efficient lookup of keys
#! by using a hash function.
#!


#! @Section API
#!
#! @Description
#! Category of hashmaps
DeclareCategory( "IsHashMap", IsObject);
BindGlobal( "HashMapFamily", NewFamily("HashMapFamily") );

DeclareRepresentation( "IsHashMapRep", IsHashMap and IsPositionalObjectRep, [] );
BindGlobal( "HashMapType", NewType(HashMapFamily, IsHashMapRep and IsMutable) );
