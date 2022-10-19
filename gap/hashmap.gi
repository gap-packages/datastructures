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
##  Implementation of a hash map for GAP.
##

#! @Chapter Hashmaps
#! @Section API

InstallGlobalFunction(HashMap,
function(arg...)
    local hashfunc, eqfunc, capacity, values, v, map;

    values := [];
    hashfunc := HashBasic;
    eqfunc := \=;
    capacity := 16;

    if Length(arg) > 0 and IsList(arg[1]) then
        values := Remove(arg, 1);
        capacity := Maximum(capacity, Length(values));
    fi;
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


    map := DS_Hash_Create(hashfunc, eqfunc, capacity, false);

    for v in values do
        if Length(v) <> 2 then
            Error("Invalid initial values");
        fi;
        map[v[1]] := v[2];
    od;

    return map;
end);

InstallMethod(PrintString, "for hashmaps",
    [ IsHashMapRep ],
function(ht)
    local v, first, string;
    string := [];
    Add(string, "HashMap([\>\>");
    first := true;
    for v in KeyValueIterator(ht) do
        if first then
            first := false;
        else
            Add(string, ",\< \>");
        fi;
        Add(string, PrintString(v));
    od;
    Add(string, "\<\<])");
    return Concatenation(string);
end);

InstallMethod(String, "for hashmaps",
    [ IsHashMapRep ],
function(ht)
    local v, first, string;
    string := [];
    Add(string, "HashMap([");
    first := true;
    for v in KeyValueIterator(ht) do
        if first then
            first := false;
        else
            Add(string, ", ");
        fi;
        Add(string, String(v));
    od;
    Add(string, "])");
    return Concatenation(string);
end);

#! @Description
#! List-style access for hashmaps.
#! @Arguments hashmap, object
InstallOtherMethod(\[\],
    "for a hash map and a key",
    [ IsHashMapRep, IsObject ],
    DS_Hash_Value); # TODO: raise an error if key is not bound

#! @Description
#! List-style assignment for hashmaps.
#! @Arguments hashmap, object, object
InstallOtherMethod(\[\]\:\=,
    "for a hash map, a key and a value",
    [ IsHashMapRep, IsObject, IsObject ],
    DS_Hash_SetValue);

#! @Description
#! Test whether a key is stored in the hashmap.
#! @Arguments object, hashmap
InstallOtherMethod( \in,
    "for a hash map and a key",
    [ IsObject, IsHashMapRep ],
    {key, ht} -> DS_Hash_Contains(ht, key));

#! @Description
#! Test whether a key is stored in the hashmap.
#! @Arguments object, hashmap
InstallOtherMethod( IsBound\[\],
    "for a hash map and a key",
    [ IsHashMapRep, IsObject ],
    DS_Hash_Contains);

#! @Description
#! Delete a key from a hashmap.
#! @Arguments object, hashmap
InstallOtherMethod( Unbind\[\],
    "for a hash map and a key",
    [ IsHashMapRep, IsObject ],
    DS_Hash_Delete);

#! @Description
#! Determine the number of keys stored in a hashmap.
#! @Arguments hashmap
InstallOtherMethod( Size,
    "for a hash map",
    [ IsHashMapRep ],
    ht -> DS_Hash_Used(ht));

#! @Description
#! Test whether a hashmap is empty.
#! @Arguments object, hashmap
InstallOtherMethod( IsEmpty,
    "for a hash map",
    [ IsHashMapRep ],
    ht -> DS_Hash_Used(ht) = 0);


InstallMethod( Keys,
    "for a hash map",
    [ IsHashMapRep ],
function(ht)
    local keys, k;
    keys := [];
    for k in ht![5] do
        if k <> fail then Add(keys, k); fi;
    od;
    return keys;
end);

InstallMethod( Values,
    "for a hash map",
    [ IsHashMapRep ],
    ht -> Compacted(ht![6]));


BindGlobal( "NextIterator_HashMap", function(iter)
    local idx, next;
    if iter!.next > Length(iter!.keys) then
        Error("<iter> is exhausted");
    fi;

    # remember the result index
    idx := iter!.next;

    # find the next iterator
    next := iter!.next + 1;
    # skip to the next entry with a bound value
    while next <= Length(iter!.keys) and not IsBound(iter!.values[next]) do
        Assert(0, not IsBound(iter!.keys[next]) or iter!.keys[next] = fail);
        next := next + 1;
    od;
    iter!.next := next;

    # return value depends on the iterator type
    if iter!.type = 1 then
        return iter!.keys[idx];
    elif iter!.type = 2 then
        return iter!.values[idx];
    else
        return [iter!.keys[idx], iter!.values[idx]];
    fi;
end);

BindGlobal( "MakeIterator_HashMap", function(ht, type)
    local iter;
    iter := rec(keys := ht![5],
                values := ht![6],
                next := PositionBound(~.values),
                type := type);
    iter.ShallowCopy := iter -> rec(keys   := iter!.keys,
                                    values := iter!.values,
                                    next   := iter!.next,
                                    type   := iter!.type);
    iter.IsDoneIterator := iter -> iter!.next > Length(iter!.keys);
    iter.NextIterator   := NextIterator_HashMap;

    return IteratorByFunctions( iter );
end);

InstallMethod( KeyIterator,
    "for a hash set",
    [ IsHashMapRep ],
    ht -> MakeIterator_HashMap(ht, 1));

InstallMethod( ValueIterator,
    "for a hash set",
    [ IsHashMapRep ],
    ht -> MakeIterator_HashMap(ht, 2));

InstallMethod( KeyValueIterator,
    "for a hash set",
    [ IsHashMapRep ],
    ht -> MakeIterator_HashMap(ht, 3));
