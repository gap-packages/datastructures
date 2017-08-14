/*
 * Datastructures: GAP package providing common datastructures.
 * Licensed under the GPL 2 or later.
 */

#include "hashmap.h"

#include "src/debug.h"
#include "src/ariths.h"
#include "src/intfuncs.h"

enum {
    // offsets in the hashmap positional object
    POS_HASHFUNC = 1,
    POS_EQFUNC,
    POS_USED,       // number of used slots
    POS_DELETED,    // number of deleted slots
    POS_KEYS,
    POS_VALUES,

    // various constants used to tweak the hashmap
    PERTURB_SHIFT = 5,
    LOADFACTOR_NUMERATOR = 7,
    LOADFACTOR_DENOMINATOR = 10
};

static Obj HashMapType;    // Imported from the library


static Int _DS_Hash_Lookup_intern(const Obj ht,
                                  const Obj keys,
                                  const Obj key,
                                  const Obj hash,
                                  const Obj eqfun,
                                  const Int mask,
                                  const Int key_is_unique,
                                  const Int create)
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
        }
        else if (!key_is_unique &&
                 (eqfun != EqOper ? (True == CALL_2ARGS(eqfun, tmp, key))
                                  : EQ(tmp, key))) {
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

static Int _DS_Hash_Lookup_MayCreate(Obj ht, Obj key, int create)
{
    if (key == Fail)
        ErrorQuit("<key> must not be equal to 'fail'", 0, 0);

    Obj hashfun = ELM_PLIST(ht, POS_HASHFUNC);
    GAP_ASSERT(hashfun && TNUM_OBJ(hashfun) == T_FUNCTION);

    Obj hash = CALL_1ARGS(hashfun, key);
    if (!IS_INTOBJ(hash))
        ErrorQuit("<hashfun> must return a small int (not a %s)",
                  (Int)TNAM_OBJ(hash), 0L);

    Obj eqfun = ELM_PLIST(ht, POS_EQFUNC);
    GAP_ASSERT(eqfun && TNUM_OBJ(eqfun) == T_FUNCTION);

    Obj keys = ELM_PLIST(ht, POS_KEYS);

    Int capacity = LEN_PLIST(keys);
    GAP_ASSERT(capacity >= 16);
    GAP_ASSERT(0 == (capacity & (capacity - 1)));    // power of 2?

    Int mask = capacity - 1;
    return _DS_Hash_Lookup_intern(ht, keys, key, hash, eqfun, mask, 0,
                                  create);
}

//
// Resize the keys and values stores to a new capacity.
//
// The caller is responsible for checking that the new capacity
// is sufficient to allow all elements to be stored, and that
// it is a power of 2.
//
static void _DS_Hash_Resize_intern(Obj ht, Int new_capacity)
{
    GAP_ASSERT(new_capacity >= 16);
    GAP_ASSERT(0 == (new_capacity & (new_capacity - 1)));    // power of 2?

    Obj old_keys = ELM_PLIST(ht, POS_KEYS);
    Obj old_vals = ELM_PLIST(ht, POS_VALUES);

    Int old_capacity = LEN_PLIST(old_keys);
    Int old_size = INT_INTOBJ(ELM_PLIST(ht, POS_USED));

    GAP_ASSERT(new_capacity >= old_size);

    Obj keys = NEW_PLIST(T_PLIST, new_capacity);
    SET_LEN_PLIST(keys, new_capacity);

    Obj values = NEW_PLIST(T_PLIST, new_capacity + 1);
    SET_LEN_PLIST(values, new_capacity);

    Obj hashfun = ELM_PLIST(ht, POS_HASHFUNC);
    GAP_ASSERT(hashfun && TNUM_OBJ(hashfun) == T_FUNCTION);

    // copy data into new hash
    Int       new_size = 0;
    const Int mask = new_capacity - 1;
    for (Int old_idx = 1; old_idx <= old_capacity; ++old_idx) {
        Obj k = ELM_PLIST(old_keys, old_idx);
        if (k == 0 || k == Fail)
            continue;

        Obj hash = CALL_1ARGS(hashfun, k);
        if (!IS_INTOBJ(hash))
            ErrorQuit("<hashfun> must return a small int (not a %s)",
                      (Int)TNAM_OBJ(hash), 0L);

        // Insert the element from the old table into the new table.
        // Since we know that no key exists twice in the old table, we
        // can do this slightly better than by calling lookup, since we
        // don't have to call _equal().

        Int idx = _DS_Hash_Lookup_intern(ht, keys, k, hash, 0, mask, 1, 1);

        Obj v = ELM_PLIST(old_vals, old_idx);

        SET_ELM_PLIST(keys, idx, k);
        SET_ELM_PLIST(values, idx, v);

        new_size++;
    }

    // Strictly speaking, we should call CHANGED_BAG inside the loop. However,
    // as we copy elements from existing lists, all the objects are already
    // known to GASMAN. So it is safe to delay the notification as no objects
    // can be lost.
    CHANGED_BAG(keys);
    CHANGED_BAG(values);

    if (old_size != new_size)
        ErrorQuit("PANIC: unexpected size change (was %d, now %d)", old_size,
                  new_size);

    // ... and store the result
    SET_ELM_PLIST(ht, POS_USED, INTOBJ_INT(new_size));
    SET_ELM_PLIST(ht, POS_DELETED, INTOBJ_INT(0));
    SET_ELM_PLIST(ht, POS_KEYS, keys);
    SET_ELM_PLIST(ht, POS_VALUES, values);

    CHANGED_BAG(ht);
}

// This helper function check if the table is very full, and if so,
// reallocates it. This may increase the capacity, but not necessarily:
// if the table contains many deleted items, the capacity could stay
// unchanged.
static void _DS_GrowIfNecessary(Obj ht)
{
    Int used = INT_INTOBJ(ELM_PLIST(ht, POS_USED));
    Int deleted = INT_INTOBJ(ELM_PLIST(ht, POS_DELETED));

    Obj keys = ELM_PLIST(ht, POS_KEYS);

    Int capacity = LEN_PLIST(keys);
    if ((used + deleted) * LOADFACTOR_DENOMINATOR >
        capacity * LOADFACTOR_NUMERATOR) {
        while (used * LOADFACTOR_DENOMINATOR >
               capacity * LOADFACTOR_NUMERATOR)
            capacity <<= 1;
        _DS_Hash_Resize_intern(ht, capacity);
    }
}

static Obj _DS_Hash_SetOrAccValue(Obj ht, Obj key, Obj val, Obj accufunc)
{
    if (key == Fail)
        ErrorQuit("<key> must not be equal to 'fail'", 0L, 0L);
    if (val == Fail)
        ErrorQuit("<val> must not be equal to 'fail'", 0L, 0L);

    _DS_GrowIfNecessary(ht);

    Int idx = _DS_Hash_Lookup_MayCreate(ht, key, 1);

    Obj keys = ELM_PLIST(ht, POS_KEYS);
    Obj values = ELM_PLIST(ht, POS_VALUES);

    Obj old_k = ELM_PLIST(keys, idx);
    if (old_k == Fail) {
        // we are filling a 'deleted' slot
        DS_DecrementCounterInPlist(ht, POS_DELETED, INTOBJ_INT(1));
    }

    if (old_k != Fail && old_k != 0) {
        // key is already in the hash, just update the value
        if (accufunc) {
            if (LEN_PLIST(values) < idx)
                ErrorQuit("internal error: hash index out of bounds", 0L, 0L);
            Obj old_v = ELM_PLIST(values, idx);
            if (accufunc == SumOper) {
                Obj new_v;
                if (!ARE_INTOBJS(old_v, val) ||
                    !SUM_INTOBJS(new_v, old_v, val))
                    new_v = SUM(old_v, val);
                val = new_v;
            }
            else {
                val = CALL_2ARGS(accufunc, old_v, val);
            }
        }
        AssPlist(values, idx, val);
        if (accufunc)
            return True;
    }
    else {
        DS_IncrementCounterInPlist(ht, POS_USED, INTOBJ_INT(1));

        SET_ELM_PLIST(keys, idx, key);
        SET_ELM_PLIST(values, idx, val);
        CHANGED_BAG(keys);
        CHANGED_BAG(values);
    }

    return accufunc ? False : INTOBJ_INT(idx);
}

static void DS_RequireHash(Obj ht)
{
    if (TNUM_OBJ(ht) != T_POSOBJ || TYPE_POSOBJ(ht) != HashMapType) {
        ErrorQuit("<ht> must be a hashmap object (not a %s)",
                  (Int)TNAM_OBJ(ht), 0);
    }
}


//
// high-level functions, to be called from GAP
//

Obj DS_Hash_Create(Obj self, Obj hashfunc, Obj eqfunc, Obj capacity)
{
    if (TNUM_OBJ(hashfunc) != T_FUNCTION) {
        ErrorQuit("<hashfunc> must be a function (not a %s)",
                  (Int)TNAM_OBJ(hashfunc), 0);
    }
    if (TNUM_OBJ(eqfunc) != T_FUNCTION) {
        ErrorQuit("<eqfunc> must be a function (not a %s)",
                  (Int)TNAM_OBJ(eqfunc), 0);
    }
    if (!IS_POS_INTOBJ(capacity)) {
        ErrorQuit("<capacity> must be a small positive integer (not a %s)",
                  (Int)TNAM_OBJ(capacity), 0);
    }

    // convert capacity into integer and round up to a power of 2
    Int requestedCapacity = INT_INTOBJ(capacity);
    Int c = 16;
    while (c < requestedCapacity)
        c <<= 1;

    Obj ht = NewBag(T_POSOBJ, sizeof(Obj) * 7);
    TYPE_POSOBJ(ht) = HashMapType;

    SET_ELM_PLIST(ht, POS_HASHFUNC, hashfunc);
    SET_ELM_PLIST(ht, POS_EQFUNC, eqfunc);
    SET_ELM_PLIST(ht, POS_USED, INTOBJ_INT(0));
    SET_ELM_PLIST(ht, POS_DELETED, INTOBJ_INT(0));

    Obj keys = NEW_PLIST(T_PLIST, c);
    SET_ELM_PLIST(ht, POS_KEYS, keys);
    SET_LEN_PLIST(keys, c);
    CHANGED_BAG(ht);

    Obj values = NEW_PLIST(T_PLIST, c);
    SET_ELM_PLIST(ht, POS_VALUES, values);
    SET_LEN_PLIST(values, c);
    CHANGED_BAG(ht);

    return ht;
}

Obj DS_Hash_Capacity(Obj self, Obj ht)
{
    DS_RequireHash(ht);
    Obj keys = ELM_PLIST(ht, POS_KEYS);
    return INTOBJ_INT(LEN_PLIST(keys));
}

Obj DS_Hash_Used(Obj self, Obj ht)
{
    DS_RequireHash(ht);
    return ELM_PLIST(ht, POS_USED);
}

Obj _DS_Hash_Lookup(Obj self, Obj ht, Obj key)
{
    DS_RequireHash(ht);
    return INTOBJ_INT(_DS_Hash_Lookup_MayCreate(ht, key, 0));
}

Obj _DS_Hash_LookupCreate(Obj self, Obj ht, Obj key)
{
    DS_RequireHash(ht);
    return INTOBJ_INT(_DS_Hash_Lookup_MayCreate(ht, key, 1));
}

Obj DS_Hash_Contains(Obj self, Obj ht, Obj key)
{
    DS_RequireHash(ht);
    return _DS_Hash_Lookup_MayCreate(ht, key, 0) != 0 ? True : False;
}

Obj DS_Hash_Value(Obj self, Obj ht, Obj key)
{
    DS_RequireHash(ht);
    Int idx = _DS_Hash_Lookup_MayCreate(ht, key, 0);
    if (idx == 0)
        return Fail;
    Obj values = ELM_PLIST(ht, POS_VALUES);
    return ELM_PLIST(values, idx);
}

Obj DS_Hash_Reserve(Obj self, Obj ht, Obj new_capacity)
{
    DS_RequireHash(ht);
    if (!IS_POS_INTOBJ(new_capacity)) {
        ErrorQuit("<capacity> must be a small positive integer (not a %s)",
                  (Int)TNAM_OBJ(new_capacity), 0);
    }

    Int c = LEN_PLIST(ELM_PLIST(ht, POS_KEYS));
    Int requestedCapacity = INT_INTOBJ(new_capacity);
    if (c >= requestedCapacity)
        return 0;

    // round up to a power of 2
    while (c < requestedCapacity)
        c <<= 1;

    // Make sure capacity is big enough to contain all its elements
    // while staying under the load factor
    Int used = INT_INTOBJ(ELM_PLIST(ht, POS_USED));
    while (used * LOADFACTOR_DENOMINATOR > c * LOADFACTOR_NUMERATOR)
        c <<= 1;

    _DS_Hash_Resize_intern(ht, c);
    return 0;
}

Obj DS_Hash_SetValue(Obj self, Obj ht, Obj key, Obj val)
{
    DS_RequireHash(ht);
    return _DS_Hash_SetOrAccValue(ht, key, val, 0);
}

Obj DS_Hash_AccumulateValue(Obj self, Obj ht, Obj key, Obj val, Obj accufunc)
{
    DS_RequireHash(ht);
    if (TNUM_OBJ(accufunc) != T_FUNCTION) {
        ErrorQuit("<accufunc> must be a function (not a %s)",
                  (Int)TNAM_OBJ(accufunc), 0);
    }
    return _DS_Hash_SetOrAccValue(ht, key, val, accufunc);
}

Obj DS_Hash_Delete(Obj self, Obj ht, Obj key)
{
    DS_RequireHash(ht);
    Int idx = _DS_Hash_Lookup_MayCreate(ht, key, 0);
    if (!idx)
        return Fail;

    Obj keys = ELM_PLIST(ht, POS_KEYS);
    Obj values = ELM_PLIST(ht, POS_VALUES);
    Obj val = ELM_PLIST(values, idx);

    SET_ELM_PLIST(keys, idx, Fail);
    SET_ELM_PLIST(values, idx, 0);

    DS_IncrementCounterInPlist(ht, POS_DELETED, INTOBJ_INT(1));
    DS_DecrementCounterInPlist(ht, POS_USED, INTOBJ_INT(1));

    return val;
}


static StructGVarFunc GVarFuncs[] = {
    GVARFUNC(DS_Hash_Create, 3, "hashfunc, eqfunc, capacity"),

    GVARFUNC(DS_Hash_Capacity, 1, "ht"),
    GVARFUNC(DS_Hash_Used, 1, "ht"),

    GVARFUNC(_DS_Hash_Lookup, 2, "ht, key"),
    GVARFUNC(_DS_Hash_LookupCreate, 2, "ht, key"),
    GVARFUNC(DS_Hash_Contains, 2, "ht, key"),
    GVARFUNC(DS_Hash_Value, 2, "ht, key"),

    GVARFUNC(DS_Hash_Reserve, 2, "ht, capacity"),
    GVARFUNC(DS_Hash_SetValue, 3, "ht, key, val"),
    GVARFUNC(DS_Hash_AccumulateValue, 4, "ht, key, val, accufunc"),

    GVARFUNC(DS_Hash_Delete, 2, "ht, key"),

    { 0 }
};

static Int InitKernel(void)
{
    InitHdlrFuncsFromTable(GVarFuncs);

    ImportGVarFromLibrary("HashMapType", &HashMapType);

    return 0;
}

static Int InitLibrary(void)
{
    InitGVarFuncsFromTable(GVarFuncs);
    return 0;
}

struct DatastructuresModule HashmapModule = {
    .initKernel = InitKernel, .initLibrary = InitLibrary,
};
