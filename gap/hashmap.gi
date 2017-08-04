#############################################################################
##
##  Implementation of a hashmap for GAP.
##

InstallMethod(ViewObj, "for hashmaps",
    [ IsHashMapRep ],
function(ht)
    Print("<hash map obj capacity=",DS_Hash_Capacity(ht),
            " used=",DS_Hash_Used(ht),">");
end);

InstallOtherMethod(\[\],
    "for a hashmap and a key",
    [ IsHashMapRep, IsObject ],
    DS_Hash_Value); # TODO: raise an error if key is not bound

InstallOtherMethod(\[\]\:\=,
    "for a hashmap, a key and a value",
    [ IsHashMapRep, IsObject, IsObject ],
    DS_Hash_SetValue);

InstallOtherMethod( \in,
    "for a hashmap and a key",
    [ IsObject, IsHashMapRep ],
    {key, ht} -> DS_Hash_Contains(ht, key));

InstallOtherMethod( IsBound\[\],
    "for a hashmap and a key",
    [ IsHashMapRep, IsObject ],
    DS_Hash_Contains);

InstallOtherMethod( Unbind\[\],
    "for a hashmap and a key",
    [ IsHashMapRep, IsObject ],
    DS_Hash_Delete);

InstallOtherMethod( IsEmpty,
    "for a hashmap",
    [ IsHashMapRep ],
    ht -> DS_Hash_Used(ht) = 0);
