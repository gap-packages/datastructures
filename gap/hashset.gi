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

#! @Chapter Hashsets
#! @Section API
InstallGlobalFunction(HashSet,
function(arg...)
    local hashfunc, eqfunc, capacity, res, values, v;

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

    res := DS_Hash_Create(hashfunc, eqfunc, capacity, true);
    for v in values do
        AddSet(res, v);
    od;
    return res;
end);

InstallMethod(PrintString, "for hashsets",
    [ IsHashSetRep ],
function(ht)
    local v, first, string;
    string := [];
    Add(string, "HashSet([\>\>");
    first := true;
    for v in ht do
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

InstallMethod(String, "for hashsets",
    [ IsHashSetRep ],
function(ht)
    local v, first, string;
    string := [];
    Add(string, "HashSet([");
    first := true;
    for v in ht do
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
#! Add <A>obj</A> to <A>hashset</A>.
#! @Arguments hashset, obj
InstallOtherMethod(AddSet,
    "for a hash set and a key",
    [ IsHashSetRep, IsObject ],
    DS_Hash_AddSet);

#! @Description
#! Test membership of <A>obj</A> in <A>hashset</A>
#! @Arguments obj, hashset
InstallOtherMethod( \in,
    "for a hash set and a key",
    [ IsObject, IsHashSetRep ],
    {key, ht} -> DS_Hash_Contains(ht, key));

#! @Description
#! Remove <A>obj</A> from <A>hashset</A>.
#! @Arguments hashset, obj
InstallOtherMethod( RemoveSet,
    "for a hash set and a key",
    [ IsHashSetRep, IsObject ],
    DS_Hash_Delete);

#! @Description
#! Return the size of a hashset
#! @Arguments hashset
#! Returns an integer
InstallOtherMethod( Size,
    "for a hash set",
    [ IsHashSetRep ],
    ht -> DS_Hash_Used(ht));

#! @Description
#! Test a hashset for emptiness.
#! @Arguments hashset
#! @Returns a boolean
InstallOtherMethod( IsEmpty,
    "for a hash set",
    [ IsHashSetRep ],
    ht -> DS_Hash_Used(ht) = 0);

#! @Description
#! Convert a hashset into a &GAP; set
#! @Arguments hashset
#! @Returns a set
InstallOtherMethod( Set,
    "for a hash set",
    [ IsHashSetRep ],
    ht -> Difference(Set(ht![5]),[fail]));

#! @Description
#! Convert a hashset into a &GAP; set
#! @Arguments hashset
#! @Returns an immutable set
InstallOtherMethod( AsSet,
    "for a hash set",
    [ IsHashSetRep ],
    ht -> MakeImmutable(Set(ht)));


BindGlobal( "NextIterator_HashSet", function(iter)
    local val, idx;
    if iter!.next > Length(iter!.list) then
        Error("<iter> is exhausted");
    fi;
    val := iter!.list[ iter!.next ];
    idx := iter!.next + 1;
    # skip to the next bound entry not equal to 'fail' (which marks deleted entries)
    while idx <= Length(iter!.list) and not
        (IsBound(iter!.list[idx]) and iter!.list[idx] <> fail) do
        idx := idx + 1;
    od;
    iter!.next := idx;
    return val;
end);

#! @Description
#! Create an iterator for the values contained in a hashset.
#! Note that elements added to the hashset after
#! the creation of an iterator are not guaranteed to be returned by that iterator.
#! @Arguments set
#! @Returns an iterator
InstallOtherMethod( Iterator,
    "for a hash set",
    [ IsHashSetRep ],
function(ht)
    local iter;
    iter := rec(list := ht![5], next := PositionProperty(~.list, x -> x <> fail));
    iter.ShallowCopy := iter -> rec(list := iter!.list, next := iter!.next);
    iter.IsDoneIterator := iter -> iter!.next > Length(iter!.list);
    iter.NextIterator   := NextIterator_HashSet;

    return IteratorByFunctions( iter );
end);


# TODO: things we could implement (but do we want to?)
# UnitSet
# Union
# Intersection
# ...
#
# But do we really want to???
