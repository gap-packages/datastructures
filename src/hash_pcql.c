/*
 * Datastructures: GAP package providing common datastructures.
 * Licensed under the GPL 2 or later.
 */

#include "hash_pcql.h"

#include "src/intfuncs.h"


#define PERTURB_SHIFT           5
#define LOADFACTOR_NUMERATOR    7
#define LOADFACTOR_DENOMINATOR  10

UInt PCQL_Capacity_RNam = 0;
UInt PCQL_Deleted_RNam = 0;
UInt PCQL_Size_RNam = 0;
UInt PCQL_Keys_RNam = 0;
UInt PCQL_Vals_RNam = 0;
UInt PCQL_HashFun_RNam = 0;
UInt PCQL_EqFun_RNam = 0;


Obj MyHash(Obj op)
{
    Int n = SIZE_OBJ(op);

    if (IS_INTOBJ(op))
        return op;

#ifdef SYS_IS_64_BIT
    UInt8 hashout[2];
    MurmurHash3_x64_128( (const void *)ADDR_OBJ(op), (int)n, 0, (void *)hashout);
    return INTOBJ_INT(hashout[0] % (1UL << 60));
#else
    UInt4 hashout;
    MurmurHash3_x86_32( (const void *)ADDR_OBJ(op), (int)n, 0, (void *)&hashout);
    return INTOBJ_INT(hashout % (1UL << 28));
#endif
}

static Int _PCQL_Hash_Lookup_intern(Obj ht,
                                    Obj keys,
                                    Obj key,
                                    Obj hash,
                                    Obj eqfun,
                                    Int mask,
                                    Int key_is_unique,
                                    Int create)
{
    Obj tmp;
    Int idx, perturb;
    Int first_free = 0;

    perturb = INT_INTOBJ(hash);
    idx = perturb & mask;

    while ((tmp = ELM_PLIST(keys, idx + 1))) {
        if (tmp == Fail) {
            if (first_free == 0)
                first_free = idx + 1;
        } else if (!key_is_unique &&
                (eqfun ? (True == CALL_2ARGS(eqfun, tmp, key)) : EQ(tmp, key)) ) {
            return idx + 1;
        }

        idx = (5 * idx + perturb + 1) & mask;
        perturb >>= PERTURB_SHIFT;
    }

    if (!create)
        return 0;

    if (first_free != 0)
        return first_free;
    return idx + 1;
}

static Obj _PCQL_Hash_Lookup(Obj ht, Obj key, int create)
{
    Obj capacity, hash, keys;
    Int mask;

    if (key == Fail)
        ErrorQuit("<key> must not be equal to 'fail'", 0L, 0L);

    if (!IS_PREC_REP(ht) )
        ErrorQuit("<ht> must be a record", 0L, 0L);

    Obj eqfun = IsbPRec(ht, PCQL_EqFun_RNam) ? ElmPRec(ht, PCQL_EqFun_RNam) : 0;

    if (IsbPRec(ht, PCQL_HashFun_RNam)) {
        Obj hashfun = ElmPRec(ht, PCQL_HashFun_RNam);
        hash = CALL_1ARGS(hashfun, key);
        if (!IS_INTOBJ(hash))
            ErrorQuit("hashfun failed to return a small int", 0L, 0L);
    } else {
        hash = MyHash(key);
    }

    capacity = ElmPRec(ht, PCQL_Capacity_RNam);
    if (!IS_INTOBJ(capacity))
        ErrorQuit("capacity is not a small int", 0L, 0L);
    // TODO: verify capacity is a power of 2?

    keys = ElmPRec(ht, PCQL_Keys_RNam);
    if (!IS_PLIST(keys))
        ErrorQuit("keys is not a plist", 0L, 0L);


    mask = INT_INTOBJ(capacity) - 1;

    Int idx =  _PCQL_Hash_Lookup_intern(ht, keys, key, hash, eqfun, mask, 0, create);
    if (idx == 0)
        return Fail;
    return INTOBJ_INT(idx);
}

Obj _PCQL_Hash_Lookup_C(Obj self, Obj ht, Obj key)
{
    return _PCQL_Hash_Lookup(ht, key, 0);
}

Obj _PCQL_Hash_LookupCreate_C(Obj self, Obj ht, Obj key)
{
    return _PCQL_Hash_Lookup(ht, key, 1);
}

static void _PCQL_Hash_Resize_intern(Obj ht, Int new_capacity)
{
//Pr("_PCQL_Hash_Resize_intern(%d)\n", new_capacity, 0L);

    Int old_capacity = INT_INTOBJ(ElmPRec(ht, PCQL_Capacity_RNam));
    Int old_size = INT_INTOBJ(ElmPRec(ht, PCQL_Size_RNam));
    Obj old_keys = ElmPRec(ht, PCQL_Keys_RNam);
    Obj old_vals = ElmPRec(ht, PCQL_Vals_RNam);

    Obj keys = NEW_PLIST(T_PLIST, new_capacity + 1);
    SET_ELM_PLIST(keys, new_capacity + 1, Fail);
    SET_LEN_PLIST(keys, new_capacity + 1);
    CHANGED_BAG(keys);

    Obj vals = NEW_PLIST(T_PLIST, new_capacity + 1);
    SET_ELM_PLIST(vals, new_capacity + 1, Fail);
    SET_LEN_PLIST(vals, new_capacity + 1);
    CHANGED_BAG(vals);

    //_PCQL_Hash_Reset(ht, new_capacity);

    Obj hashfun = IsbPRec(ht, PCQL_HashFun_RNam) ? ElmPRec(ht, PCQL_HashFun_RNam) : 0;

    // copy data into new hash
    Int new_size = 0;
    Int mask = new_capacity - 1;
	for (Int old_idx = 1; old_idx <= old_capacity; ++old_idx) {
	    Obj k = ELM_PLIST(old_keys, old_idx);
	    if (k == 0 || k == Fail)
	        continue;

        Obj hash = hashfun ? CALL_1ARGS(hashfun, k) : MyHash(k);
        //if (!IS_INTOBJ(hash))
        //    ErrorQuit("hashfun failed to return a small int", 0L, 0L);

		// Insert the element from the old table into the new table.
		// Since we know that no key exists twice in the old table, we
		// can do this slightly better than by calling lookup, since we
		// don't have to call _equal().

        Int idx = _PCQL_Hash_Lookup_intern(ht, keys, k, hash, 0, mask, 1, 1);

        Obj v = ELM_PLIST(old_vals, old_idx);

        SET_ELM_PLIST(keys, idx, k);
        SET_ELM_PLIST(vals, idx, v);

		new_size++;
    }
    // Strictly speaking, we should call CHANGED_BAG inside the loop.
    // However, as we copy elements from existing lists, all the objects
    // are already known to GASMAN. So it is safe to delay the
    // notification as no objects can be lost.
    // FIXME: Verify the above claim!
    CHANGED_BAG(keys);
    CHANGED_BAG(vals);

    if (old_size != new_size)
        ErrorQuit("_PCQL_Hash_Resize_intern: unexpected size change", 0L, 0L);

    // ... and store the result
    AssPRec(ht, PCQL_Capacity_RNam, INTOBJ_INT(new_capacity));
    AssPRec(ht, PCQL_Size_RNam, INTOBJ_INT(new_size));
    AssPRec(ht, PCQL_Deleted_RNam, INTOBJ_INT(0));
    AssPRec(ht, PCQL_Keys_RNam, keys);
    AssPRec(ht, PCQL_Vals_RNam, vals);
}

Obj _PCQL_Hash_Resize_C(Obj self, Obj ht, Obj new_capacity)
{
    // TODO: insert extra checks
/*
    if new_capacity < ht.size * _PCQL_Hash_Loadfactor then
        new_capacity := Int( ht.size * _PCQL_Hash_Loadfactor );
    fi;
    new_capacity := _PCQL_Hash_RoundUpCapacity( new_capacity );
*/
    _PCQL_Hash_Resize_intern(ht, INT_INTOBJ(new_capacity));
    return 0;
}

static void _PCQL_GrowIfNecessary(Obj ht)
{
    Int capacity = INT_INTOBJ(ElmPRec(ht, PCQL_Capacity_RNam));
    Int size = INT_INTOBJ(ElmPRec(ht, PCQL_Size_RNam));
    Int deleted = INT_INTOBJ(ElmPRec(ht, PCQL_Deleted_RNam));

    if ( (size + deleted) * LOADFACTOR_DENOMINATOR > capacity * LOADFACTOR_NUMERATOR) {
        capacity = 16;
        while (capacity < 2*size)
            capacity <<= 1;
        _PCQL_Hash_Resize_intern(ht, capacity);
    }
}

static Obj _PCQL_Hash_SetOrAccValue_C(Obj ht, Obj key, Obj val, int acc)
{
    if (key == Fail || val == Fail)
        ErrorQuit("<key> and <value> must not be equal to 'fail'", 0L, 0L);

    _PCQL_GrowIfNecessary(ht);

    Int idx = INT_INTOBJ(_PCQL_Hash_Lookup(ht, key, 1));

    Obj keys = ElmPRec(ht, PCQL_Keys_RNam);
    Obj vals = ElmPRec(ht, PCQL_Vals_RNam);

    Obj old_k = ELM_PLIST(keys, idx);
    if (old_k == Fail) {
        // we are filling a 'deleted' slot
        Int deleted = INT_INTOBJ(ElmPRec(ht, PCQL_Deleted_RNam));
        deleted--;
        AssPRec(ht, PCQL_Deleted_RNam, INTOBJ_INT(deleted));
    }

    if (old_k != Fail && old_k != 0) {
        // key is already in the hash, just update the value
        if (acc) {
            if (LEN_PLIST( vals ) < idx)
                ErrorQuit("This should not happen!", 0L, 0L);
            Obj old_v = ELM_PLIST(vals, idx);
            Obj new_v;
            if ( ! ARE_INTOBJS( old_v, val ) ||
                 ! SUM_INTOBJS( new_v, old_v, val ) )
                new_v = SUM( old_v, val );
            val = new_v;
        }
        AssPlist(vals, idx, val);
        if (acc)
            return True;
    } else {
        Int size = INT_INTOBJ(ElmPRec(ht, PCQL_Size_RNam));
        size++;
        AssPRec(ht, PCQL_Size_RNam, INTOBJ_INT(size));

        AssPlist(keys, idx, key);
        AssPlist(vals, idx, val);
    }

    return acc ? False : INTOBJ_INT(idx);
}

Obj _PCQL_Hash_SetValue_C(Obj self, Obj ht, Obj key, Obj val)
{
    return _PCQL_Hash_SetOrAccValue_C(ht, key, val, 0);
}

Obj _PCQL_Hash_AccumulateValue_C(Obj self, Obj ht, Obj key, Obj val)
{
    return _PCQL_Hash_SetOrAccValue_C(ht, key, val, 1);
}


static StructGVarFunc GVarFuncs [] = {
    GVAR_FUNC_TABLE_ENTRY("hash_pcql.c", _PCQL_Hash_Lookup_C, 2, "ht, key"),
    GVAR_FUNC_TABLE_ENTRY("hash_pcql.c", _PCQL_Hash_LookupCreate_C, 2, "ht, key"),
    GVAR_FUNC_TABLE_ENTRY("hash_pcql.c", _PCQL_Hash_Resize_C, 2, "ht, new_capacity"),
    GVAR_FUNC_TABLE_ENTRY("hash_pcql.c", _PCQL_Hash_SetValue_C, 3, "ht, key, val"),
    GVAR_FUNC_TABLE_ENTRY("hash_pcql.c", _PCQL_Hash_AccumulateValue_C, 3, "ht, key, val"),
    { 0 }
};

static Int InitKernel(void)
{
    InitHdlrFuncsFromTable(GVarFuncs);
    return 0;
}

static Int PostRestore( void )
{
    PCQL_Capacity_RNam = RNamName( "capacity" );
    PCQL_Deleted_RNam  = RNamName( "deleted" );
    PCQL_Size_RNam     = RNamName( "size" );
    PCQL_Keys_RNam     = RNamName( "keys" );
    PCQL_Vals_RNam     = RNamName( "vals" );
    PCQL_HashFun_RNam  = RNamName( "hashfun" );
    PCQL_EqFun_RNam    = RNamName( "eqfun" );

    return 0;
}

static Int InitLibrary(void)
{
    InitGVarFuncsFromTable(GVarFuncs);
    
    // make sure PostRestore() is always run when we are loaded
    return PostRestore();
}

struct DatastructuresModule PCQLHashModule = {
    .initKernel  = InitKernel,
    .initLibrary = InitLibrary,
    .postRestore = PostRestore,
};
