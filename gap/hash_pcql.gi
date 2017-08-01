
#BindGlobal( "HashTabFamily", NewFamily("HashTabFamily") );
#BindGlobal( "HashTabType", NewType(HashTabFamily,IsPCQLHashTabRep and IsMutable) );

_PCQL_Hash_PERTURB_SHIFT := 5;
_PCQL_Hash_MIN_CAPACITY := 16;
_PCQL_Hash_Loadfactor := 7/10;


PCQL_DefaultHashFunctionForPlainObjs := function( val )
    if IsInt(val) then return val; fi;
    return HashKeyBag( val, 0, 0, -1);
end;

# Round the given up to the next power of 2
_PCQL_Hash_RoundUpCapacity := function( capacity )
    if capacity < _PCQL_Hash_MIN_CAPACITY then
        return _PCQL_Hash_MIN_CAPACITY;
    fi;
    return 2^(LogInt(capacity-1, 2) + 1);
end;

_PCQL_Hash_Reset := function( ht, capacity )
    Assert(0, capacity = _PCQL_Hash_RoundUpCapacity(capacity));
    ht.capacity := capacity;
    ht.size := 0;
    ht.deleted := 0;
    ht.keys := EmptyPlist(ht.capacity + 1);
    ht.keys[ht.capacity + 1] := fail;   # To create proper length!
    ht.vals := EmptyPlist(ht.capacity + 1);
    ht.vals[ht.capacity + 1] := fail;   # To create proper length!
end;

PCQL_Hash_Create := function( opt )
    local ht, capacity;
    ht := rec();

    if IsBound(opt.capacity) then
        capacity := _PCQL_Hash_RoundUpCapacity(opt.capacity);
    else
        capacity := _PCQL_Hash_MIN_CAPACITY;
    fi;
    
    _PCQL_Hash_Reset(ht, capacity);

    if IsBound(opt.hashfun) then
        # Note: hashfun should always return a small int!
        ht.hashfun := opt.hashfun;
    #else
    #    ht.hashfun := PCQL_DefaultHashFunctionForPlainObjs;
    fi;

    if IsBound(opt.eqfun) then
        ht.eqfun := opt.eqfun;
    #else
    #    ht.eqfun := EQ;
    fi;

    #Objectify(HashTabType, ht);

    return ht;
end;


PCQL_Hash_IsEmpty := function(ht);
    return ht.size = 0;
end;

PCQL_Hash_Size := function(ht);
    return ht.size;
end;


# InstallMethod(ViewObj, "for hash tables", 
#     [IsPCQLHashTab and IsPCQLHashTabRep],
# function(ht)
#     Print("<hash table obj capacity=",ht.capacity," used=",ht.size);
#     if IsBound(ht.alert) then
#         Print(" COLLISION ALERT!>");
#     else
#         Print(">");
#     fi;
# end);

_PCQL_Hash_Lookup_GAP := function(ht, key)
    local hash, idx, perturb;
    if key = fail then
        Error("<key> must not be equal to 'fail'");
    fi;
    if IsBound(ht.hashfun) then
        hash := ht.hashfun(key);
    else
        hash := PCQL_DefaultHashFunctionForPlainObjs(key);
    fi;
    idx := (hash mod ht.capacity);
    perturb := hash;
    while IsBound(ht.keys[idx+1]) do
        if ht.keys[idx+1] = fail then
            # do nothing, skip over the hole
        elif (IsBound(ht.eqfun) and ht.eqfun(ht.keys[idx+1], key))
            or (not IsBound(ht.eqfun) and (ht.keys[idx+1] = key)) then
            return idx;
        fi;
        
        idx := ((5 * (idx + perturb + 1) mod ht.capacity);
        perturb := QuoInt(perturb, 2^_PCQL_Hash_PERTURB_SHIFT);
    od;
    return fail; # FIXME: return idx instead?
end;

if IsBound(_PCQL_Hash_Lookup_C) then
	_PCQL_Hash_Lookup := _PCQL_Hash_Lookup_C;
else
	_PCQL_Hash_Lookup := _PCQL_Hash_Lookup_GAP;
fi;

# like Lookup(), but if no entry is found, then it creates one.
_PCQL_Hash_LookupCreate_GAP := function(ht, key)
    local hash, idx, perturb, first_free;
    if key = fail then
        Error("<key> must not be equal to 'fail'");
    fi;
    if IsBound(ht.hashfun) then
        hash := ht.hashfun(key);
    else
        hash := PCQL_DefaultHashFunctionForPlainObjs(key);
    fi;
    idx := (hash mod ht.capacity)+1;  # FIXME: use fast bit operations instead
    perturb := hash;
    first_free := fail;
    while IsBound(ht.keys[idx]) do
        if ht.keys[idx] = fail then
            if first_free = fail then
                first_free := idx;
            fi;
        elif (IsBound(ht.eqfun) and ht.eqfun(ht.keys[idx], key))
            or (not IsBound(ht.eqfun) and (ht.keys[idx] = key)) then
            return idx;
        fi;
        
        idx := ((5 * idx + perturb + 1) mod ht.capacity)+1;
        perturb := QuoInt(perturb, 2^_PCQL_Hash_PERTURB_SHIFT);
    od;
    if first_free <> fail then
        return first_free;
    fi;
    return idx;
end;

if IsBound(_PCQL_Hash_LookupCreate_C) then
	_PCQL_Hash_LookupCreate := _PCQL_Hash_LookupCreate_C;
else
	_PCQL_Hash_LookupCreate := _PCQL_Hash_LookupCreate_GAP;
fi;

PCQL_Hash_SetValue := fail;

_PCQL_Hash_Resize_GAP := function(ht, new_capacity)
    local i, old_keys, old_capacity, old_vals, old_size;
  
    if new_capacity < ht.size * _PCQL_Hash_Loadfactor then
        new_capacity := Int( ht.size * _PCQL_Hash_Loadfactor );
    fi;
    new_capacity := _PCQL_Hash_RoundUpCapacity( new_capacity );

    old_capacity := ht.capacity;
    old_size := ht.size;
    old_keys := ht.keys;
    old_vals := ht.vals;

    _PCQL_Hash_Reset(ht, new_capacity);
    Info(InfoPCQL,2,"Growing hash table to capacity ",ht.capacity," !!!");

    # Now copy into new hash:
    for i in [1..old_capacity] do
        if IsBound(old_keys[i]) and old_keys[i] <> fail then
            # TODO: we could do better than this, as we can skip the equality tests!
            PCQL_Hash_SetValue(ht, old_keys[i],old_vals[i]);
        fi;
    od;
    Assert(0, ht.size = old_size);
    Info(InfoPCQL,3,"Done.");
end;

if IsBound(_PCQL_Hash_Resize_C) then
	PCQL_Hash_Resize := _PCQL_Hash_Resize_C;
else
	PCQL_Hash_Resize := _PCQL_Hash_Resize_GAP;
fi;

PCQL_Hash_Contains := function(ht, key)
    return _PCQL_Hash_Lookup(ht, key) <> fail;
end;

_PCQL_GrowIfNecessary := function(ht)
    if ht.size + ht.deleted > ht.capacity * _PCQL_Hash_Loadfactor then
        Info(InfoPCQL,3,"Hash table too full, growing...");
        if ht.capacity < 500 then
            PCQL_Hash_Resize(ht, ht.capacity * 4);
        else
            PCQL_Hash_Resize(ht, ht.capacity * 2);
        fi;
    fi;
end;

# PCQL_Hash_Add := function(ht, key, val)
#     local idx;
#     if val = fail or key = fail then
#         Error("<key> and <value> must not be equal to 'fail'");
#     fi;
#     _PCQL_GrowIfNecessary(ht);
#     idx := _PCQL_Hash_LookupCreate(ht, key);
#     if IsBound(ht.keys[idx]) and ht.keys[idx] <> fail then
#         Error("entry already set...");
#     fi;
# 
#     ht.size := ht.size + 1;
#     if IsBound(ht.keys[idx]) and ht.keys[idx] = fail then
#         ht.deleted := ht.deleted - 1;
#     fi;
#     ht.keys[idx] := key;
#     ht.vals[idx] := val;
#     return idx;
# end;

_PCQL_Hash_SetValue_GAP := function(ht, key, val)
    local idx;
    if val = fail or key = fail then
        Error("<key> and <value> must not be equal to 'fail'");
    fi;
    _PCQL_GrowIfNecessary(ht);
    idx := _PCQL_Hash_LookupCreate(ht, key);
    if IsBound(ht.keys[idx]) then
        if ht.keys[idx] = fail then
            ht.deleted := ht.deleted - 1;
        else
            ht.vals[idx] := val;
            return idx;
        fi;
    fi;

    ht.size := ht.size + 1;
    ht.keys[idx] := key;
    ht.vals[idx] := val;
    return idx;
end;

if IsBound(_PCQL_Hash_SetValue_C) then
	PCQL_Hash_SetValue := _PCQL_Hash_SetValue_C;
else
	PCQL_Hash_SetValue := _PCQL_Hash_SetValue_GAP;
fi;

_PCQL_Hash_AccumulateValue_GAP := function(ht, key, val)
    local idx;
    if val = fail or key = fail then
        Error("<key> and <value> must not be equal to 'fail'");
    fi;
    _PCQL_GrowIfNecessary(ht);
    idx := _PCQL_Hash_LookupCreate(ht, key);
    if IsBound(ht.keys[idx]) then
        if ht.keys[idx] = fail then
            ht.deleted := ht.deleted - 1;
        else
            ht.vals[idx] := ht.vals[idx] + val;
            return true;
        fi;
    fi;

    ht.size := ht.size + 1;
    ht.keys[idx] := key;
    ht.vals[idx] := val;
    return false;
end;

if IsBound(_PCQL_Hash_AccumulateValue_C) then
	PCQL_Hash_AccumulateValue := _PCQL_Hash_AccumulateValue_C;
else
	PCQL_Hash_AccumulateValue := _PCQL_Hash_AccumulateValue_GAP;
fi;

PCQL_Hash_Value := function(ht, key)
    local idx;
    idx := _PCQL_Hash_Lookup(ht, key);
    if idx = fail then
        return fail;
    fi;
    return ht.vals[idx];
end;

PCQL_Hash_Delete := function( ht, key )
    local idx, val;
    idx := _PCQL_Hash_Lookup(ht, key);
    if idx = fail then
        return fail;
    fi;

    ht.keys[idx] := fail;
    ht.deleted := ht.deleted + 1;
    ht.size := ht.size - 1;
    val := ht.vals[idx];
    Unbind(ht.vals[idx]);
    return val;
end;

