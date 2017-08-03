#############################################################################
##
##  Declarations for the hashmap type
##
DeclareCategory( "IsHashMap", IsPositionalObjectRep);
DeclareRepresentation( "IsHashMapRep", IsHashMap, [] );

BindGlobal( "HashMapFamily", NewFamily("HashMapFamily") );
BindGlobal( "HashMapType", NewType(HashMapFamily, IsHashMapRep and IsMutable) );
