##
##  Datastructures: GAP package providing common datastructures.
##
##  Copyright (C) 2015-2017  The datastructures team.
##  For list of the team members, please refer to the COPYRIGHT file.
##
##  This package is licensed under the GPL 2 or later, please refer
##  to the COPYRIGHT.md and LICENSE files for details.
##

##
##  Implementation of a hash set for GAP.
##

InstallGlobalFunction(HashSet,
function(arg...)
    local hashfunc, eqfunc, capacity, res;

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

    res := DS_Hash_Create(hashfunc, eqfunc, capacity, true);
    return res;
end);

InstallMethod(ViewObj, "for hashsets",
    [ IsHashSetRep ],
function(ht)
    Print("<hash set obj capacity=",DS_Hash_Capacity(ht),
            " used=",DS_Hash_Used(ht),">");
end);

InstallOtherMethod(AddSet,
    "for a hash set and a key",
    [ IsHashSetRep, IsObject ],
    DS_Hash_AddSet);

InstallOtherMethod( \in,
    "for a hash set and a key",
    [ IsObject, IsHashSetRep ],
    {key, ht} -> DS_Hash_Contains(ht, key));

InstallOtherMethod( RemoveSet,
    "for a hash set and a key",
    [ IsHashSetRep, IsObject ],
    DS_Hash_Delete);

InstallOtherMethod( Size,
    "for a hash set",
    [ IsHashSetRep ],
    ht -> DS_Hash_Used(ht));

InstallOtherMethod( IsEmpty,
    "for a hash set",
    [ IsHashSetRep ],
    ht -> DS_Hash_Used(ht) = 0);

# TODO: things we could implement (but do we want to?)
# AsSet
# UnitSet
# Union
# Intersection
# ...
#
# But do we really want to???