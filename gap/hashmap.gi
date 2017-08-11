#############################################################################
##
##  Implementation of a hash map for GAP.
##

InstallGlobalFunction(HashMap,
function(arg...)
    local hashfunc, eqfunc, capacity;

    hashfunc := HashBasic;
    eqfunc := \=;
    capacity := 16;

    if Length(arg) > 0 and IsFunction(arg[1]) then
        hashfunc := Remove(arg, 1);
    fi;
    if Length(arg) > 0 and IsInt(arg[Length(arg)]) then
        capacity := Remove(arg);
    fi;
    if Length(arg) = 1 and IsFunction(arg[1]) then
        eqfunc := Remove(arg);
    fi;
    if Length(arg) > 0 then
        Error("Invalid arguments");
    fi;

    return DS_Hash_Create(hashfunc, eqfunc, capacity);
end);

InstallMethod(ViewObj, "for hash maps",
    [ IsHashMapRep ],
function(ht)
    Print("<hash map obj capacity=",DS_Hash_Capacity(ht),
            " used=",DS_Hash_Used(ht),">");
end);

InstallOtherMethod(\[\],
    "for a hash map and a key",
    [ IsHashMapRep, IsObject ],
    DS_Hash_Value); # TODO: raise an error if key is not bound

InstallOtherMethod(\[\]\:\=,
    "for a hash map, a key and a value",
    [ IsHashMapRep, IsObject, IsObject ],
    DS_Hash_SetValue);

InstallOtherMethod( \in,
    "for a hash map and a key",
    [ IsObject, IsHashMapRep ],
    {key, ht} -> DS_Hash_Contains(ht, key));

InstallOtherMethod( IsBound\[\],
    "for a hash map and a key",
    [ IsHashMapRep, IsObject ],
    DS_Hash_Contains);

InstallOtherMethod( Unbind\[\],
    "for a hash map and a key",
    [ IsHashMapRep, IsObject ],
    DS_Hash_Delete);

InstallOtherMethod( Size,
    "for a hash map",
    [ IsHashMapRep ],
    ht -> DS_Hash_Used(ht));

InstallOtherMethod( IsEmpty,
    "for a hash map",
    [ IsHashMapRep ],
    ht -> DS_Hash_Used(ht) = 0);
