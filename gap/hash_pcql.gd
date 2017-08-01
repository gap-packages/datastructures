#
# DeclareCategory( "IsPCQLHashTab", IsComponentObjectRep);
# DeclareRepresentation( "IsPCQLHashTabRep", IsPCQLHashTab, [] );
# 
# DeclareOperation( "PCQL_Hash_Create", [ IsObject, IsRecord ] );
# DeclareOperation( "PCQL_Hash_Create", [ IsObject ] );
# DeclareOperation( "PCQL_Hash_Add", [ IsPCQLHashTab, IsObject, IsObject ] );
# DeclareOperation( "PCQL_Hash_Value", [ IsPCQLHashTab, IsObject ] );
# DeclareOperation( "PCQL_Hash_Delete", [ IsPCQLHashTab, IsObject ] );
# DeclareOperation( "PCQL_Hash_Update", [ IsPCQLHashTab, IsObject, IsObject ] );
# DeclareOperation( "PCQL_Hash_Grow", [ IsPCQLHashTab, IsObject ] );

# TODO: implement [] and []:= for hash