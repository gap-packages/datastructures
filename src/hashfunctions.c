//
// Datastructures: GAP package providing common datastructures.
//
// Copyright (C) 2015-2017  The datastructures team.
// For list of the team members, please refer to the COPYRIGHT file.
//
// This package is licensed under the GPL 2 or later, please refer
// to the COPYRIGHT.md and LICENSE files for details.
//
//
// hashfunctions: various hash functions
//

#include "hashfunctions.h"

#include "src/objects.h"
#include "src/permutat.h"
#include "src/trans.h"
#include "src/pperm.h"

#include <stdlib.h> // for labs


// SquashToPerm2 takes a permutation in PERM4 form, and the largest moved
// point of the permutation (which should be <= 65536), and returns the
// permutation in PERM2 form.
Obj SquashToPerm2(Obj perm, Int n)
{
    Obj     squash;
    UInt2 * ptr;
    UInt4 * ptr_perm;
    GAP_ASSERT(TNUM_OBJ(perm) == T_PERM4);
    GAP_ASSERT(n >= 0 && n <= 65536);

    squash = NEW_PERM2(n);
    ptr = ADDR_PERM2(squash);
    ptr_perm = ADDR_PERM4(perm);

    for (int p = 0; p < n; ++p)
        ptr[p] = ptr_perm[p];

    return squash;
}

// DataHashFuncForPerm cannot simply hash the bag for two reasons:
// 1) Two equal permutations can have different numbers of fixed points
// at the end, so do not hash those.
// 2) A permutation might be a PERM4, but fit in a PERM2. In this case
// we have to turn the permutation into a PERM2, to get a consistent
// hash value. While this is expensive it should not happen too often.
Int DataHashFuncForPerm(Obj perm)
{
    GAP_ASSERT(TNUM_OBJ(perm) == T_PERM2 || TNUM_OBJ(perm) == T_PERM4);
    UInt max_point = LargestMovedPointPerm(perm);

    if (TNUM_OBJ(perm) == T_PERM2) {
        return HASHKEY_MEM_NC((const UChar *)ADDR_PERM2(perm), 1,
                              max_point * 2);
    }
    else if (max_point <= 65536) {
        Obj squash = SquashToPerm2(perm, max_point);
        return HASHKEY_MEM_NC((const UChar *)ADDR_PERM2(squash), 1,
                              max_point * 2);
    }
    else {
        return HASHKEY_MEM_NC((const UChar *)ADDR_PERM4(perm), 1,
                              max_point * 4);
    }
}

Obj DATA_HASH_FUNC_FOR_PERM(Obj self, Obj perm)
{
    if (TNUM_OBJ(perm) != T_PERM2 && TNUM_OBJ(perm) != T_PERM4) {
        ErrorMayQuit("DATA_HASH_FUNC_FOR_PERM: <perm> must be a permutation "
                     "(not a %s)",
                     (Int)TNAM_OBJ(perm), 0L);
    }

    return HashValueToObjInt(DataHashFuncForPerm(perm));
}

Obj DATA_HASH_FUNC_FOR_PPERM(Obj self, Obj pperm)
{
    if (!IS_PPERM(pperm)) {
        ErrorMayQuit("DATA_HASH_FUNC_FOR_PPERM: <pperm> must be a "
                     "partial permutation (not a %s)",
                     (Int)TNAM_OBJ(pperm), 0L);
    }

    return HashValueToObjInt(HashFuncForPPerm(pperm));
}

Obj DATA_HASH_FUNC_FOR_TRANS(Obj self, Obj trans)
{
    if (!IS_TRANS(trans)) {
        ErrorMayQuit("DATA_HASH_FUNC_FOR_TRANS: <trans> must be a "
                     "transformation (not a %s)",
                     (Int)TNAM_OBJ(trans), 0L);
    }

    return HashValueToObjInt(HashFuncForTrans(trans));
}

Obj DATA_HASH_FUNC_FOR_STRING(Obj self, Obj string)
{
    if (!IS_STRING(string)) {
        ErrorMayQuit("DATA_HASH_FUNC_FOR_STRING: <string> must be a "
                     "string (not a %s)",
                     (Int)TNAM_OBJ(string), 0L);
    }

    if (!IS_STRING_REP(string)) {
        string = CopyToStringRep(string);
    }


    UInt    len = GET_LEN_STRING(string);
    UInt1 * ptr = CHARS_STRING(string);

    // 2782 is just a random number which fits in a 32-bit UInt.
    UInt hashval = HASHKEY_MEM_NC(ptr, 2782, len);
    return HashValueToObjInt(hashval);
}

Int DataHashFuncForInt(Obj i)
{
    // The two constants below are just random seed values
    // They must be different so we hash x and -x to different values.
    GAP_ASSERT(TNUM_OBJ(i) == T_INTPOS || TNUM_OBJ(i) == T_INTNEG);
    if (TNUM_OBJ(i) == T_INTPOS) {
        return HASHKEY_WHOLE_BAG_NC(i, 293479);
    }
    else {
        return HASHKEY_WHOLE_BAG_NC(i, 193492);
    }
}

Obj DATA_HASH_FUNC_FOR_INT(Obj self, Obj i)
{
    if (TNUM_OBJ(i) != T_INT && TNUM_OBJ(i) != T_INTPOS &&
        TNUM_OBJ(i) != T_INTNEG) {
        ErrorMayQuit(
            "DATA_HASH_FUNC_FOR_INT: <i> must be an integer (not a %s)",
            (Int)TNAM_OBJ(i), 0L);
    }

    if (IS_INTOBJ(i))
        return i;
    else
        return HashValueToObjInt(DataHashFuncForInt(i));
}

static inline Int BasicRecursiveHash(Obj obj);

// This is just a random number which fits in a 32-bit UInt.
// It is used the base for hashing of lists
enum { LIST_BASE_HASH = 2195952830L };

Int BasicRecursiveHashForList(Obj obj)
{
    GAP_ASSERT(IS_LIST(obj));
    UInt current_hash = LIST_BASE_HASH;
    Int  len = LEN_LIST(obj);
    for (Int pos = 1; pos <= len; ++pos) {
        Obj val = ELM0_LIST(obj, pos);
        if (val == 0) {
            current_hash = HashCombine2(current_hash, ~(Int)0);
        }
        else {
            current_hash =
                HashCombine2(current_hash, BasicRecursiveHash(val));
        }
    }
    return current_hash;
}

Int BasicRecursiveHashForPRec(Obj obj)
{
    GAP_ASSERT(IS_PREC(obj));

    // This is just a random number which fits in a 32-bit UInt,
    // mainly to give the hash value of an empty record a value which
    // is unlikely to clash with anything else
    UInt current_hash = 1928498392;

    /* hash componentwise                                               */
    for (Int i = 1; i <= LEN_PREC(obj); i++) {
        // labs, as this can be negative in an unsorted record
        UInt recname = labs(GET_RNAM_PREC(obj, i));
        Obj  recnameobj = NAME_RNAM(recname);
        // The '23792' here is just a seed value.
        Int  hashrecname = HASHKEY_WHOLE_BAG_NC(recnameobj, 23792);
        UInt rechash = BasicRecursiveHash(GET_ELM_PREC(obj, i));

        // Use +, because record may be out of order
        current_hash += HashCombine2(hashrecname, rechash);
    }

    return current_hash;
}

static inline Int BasicRecursiveHash(Obj obj)
{
    UInt hashval;
    switch (TNUM_OBJ(obj)){
    case T_INT:
        return (Int)obj;
    case T_CHAR:
        hashval = *(UChar *)ADDR_OBJ(obj);
        // Add a random 32-bit constant, to stop collisions with small ints
        return hashval + 63588327;
    case T_BOOL:
        // These are just a random numbers which fit in a 32-bit UInt,
        // and will not collide with either small integers or chars.
        if (obj == True)
            return 36045033;
        else if (obj == False)
            return 36045034;
        else if (obj == Fail)
            return 3;
        else
            ErrorMayQuit("Invalid Boolean", 0L, 0L);
    case T_INTPOS:
    case T_INTNEG:
        return DataHashFuncForInt(obj);
    case T_PERM2:
    case T_PERM4:
        return DataHashFuncForPerm(obj);
    case T_PPERM2:
    case T_PPERM4:
        return HashFuncForPPerm(obj);
    case T_TRANS2:
    case T_TRANS4:
        return HashFuncForTrans(obj);
    case T_PREC:
    case T_PREC+IMMUTABLE:
        return BasicRecursiveHashForPRec(obj);
    }

    if (IS_LIST(obj)) {
        return BasicRecursiveHashForList(obj);
    }

    ErrorMayQuit("Unable to hash %s", (Int)TNAM_OBJ(obj), 0L);
    return 0;
}

Obj DATA_HASH_FUNC_RECURSIVE1(Obj self, Obj obj)
{
    Int hash = BasicRecursiveHash(obj);
    return HashValueToObjInt(hash);
}

Obj DATA_HASH_FUNC_RECURSIVE2(Obj self, Obj obj1, Obj obj2)
{
    UInt hash1 = BasicRecursiveHash(obj1);
    UInt hash2 = BasicRecursiveHash(obj2);

    UInt listhash1 = HashCombine2(LIST_BASE_HASH, hash1);
    UInt listhash2 = HashCombine2(listhash1, hash2);
    
    return HashValueToObjInt(listhash2);
}

Obj DATA_HASH_FUNC_RECURSIVE3(Obj self, Obj obj1, Obj obj2, Obj obj3)
{
    Int hash1 = BasicRecursiveHash(obj1);
    Int hash2 = BasicRecursiveHash(obj2);
    Int hash3 = BasicRecursiveHash(obj3);

    UInt listhash1 = HashCombine2(LIST_BASE_HASH, hash1);
    UInt listhash2 = HashCombine2(listhash1, hash2);
    UInt listhash3 = HashCombine2(listhash2, hash3);

    return HashValueToObjInt(listhash3);
}

Obj DATA_HASH_FUNC_RECURSIVE4(Obj self, Obj obj1, Obj obj2, Obj obj3, Obj obj4)
{
    Int hash1 = BasicRecursiveHash(obj1);
    Int hash2 = BasicRecursiveHash(obj2);
    Int hash3 = BasicRecursiveHash(obj3);
    Int hash4 = BasicRecursiveHash(obj4);

    UInt listhash1 = HashCombine2(LIST_BASE_HASH, hash1);
    UInt listhash2 = HashCombine2(listhash1, hash2);
    UInt listhash3 = HashCombine2(listhash2, hash3);
    UInt listhash4 = HashCombine2(listhash3, hash4);

    return HashValueToObjInt(listhash4);
}

//
// Submodule declaration
//
static StructGVarFunc GVarFuncs[] = {
    GVARFUNC(DATA_HASH_FUNC_FOR_STRING, 1, "string"),
    GVARFUNC(DATA_HASH_FUNC_FOR_TRANS, 1, "trans"),
    GVARFUNC(DATA_HASH_FUNC_FOR_PPERM, 1, "pperm"),
    GVARFUNC(DATA_HASH_FUNC_FOR_PERM, 1, "perm"),
    GVARFUNC(DATA_HASH_FUNC_FOR_INT, 1, "int"),
    { 0 }
};

static Int InitKernel(void)
{
    InitHdlrFuncsFromTable(GVarFuncs);
    InitHandlerFunc( DATA_HASH_FUNC_RECURSIVE1, __FILE__ ":DATA_HASH_FUNC_RECURSIVE1" );
    InitHandlerFunc( DATA_HASH_FUNC_RECURSIVE2, __FILE__ ":DATA_HASH_FUNC_RECURSIVE2" );
    InitHandlerFunc( DATA_HASH_FUNC_RECURSIVE3, __FILE__ ":DATA_HASH_FUNC_RECURSIVE3" );
    InitHandlerFunc( DATA_HASH_FUNC_RECURSIVE4, __FILE__ ":DATA_HASH_FUNC_RECURSIVE4" );
    return 0;
}

static Int InitLibrary(void)
{
    InitGVarFuncsFromTable(GVarFuncs);

    // We use DATA_HASH_FUNC_RECURSIVE1 both for handling one
    // argument, and five or more arguments (where the arguments will
    // be wrapped in a list by GAP
    Obj gvar = NewFunctionC("DATA_HASH_FUNC_RECURSIVE", -1, "arg",
                            DATA_HASH_FUNC_RECURSIVE1);
    SET_HDLR_FUNC(gvar, 1, DATA_HASH_FUNC_RECURSIVE1);
    SET_HDLR_FUNC(gvar, 2, DATA_HASH_FUNC_RECURSIVE2);
    SET_HDLR_FUNC(gvar, 3, DATA_HASH_FUNC_RECURSIVE3);
    SET_HDLR_FUNC(gvar, 4, DATA_HASH_FUNC_RECURSIVE4);
    AssGVar(GVarName("DATA_HASH_FUNC_RECURSIVE"), gvar);

    return 0;
}

struct DatastructuresModule HashFunctionsModule = {
    .initKernel = InitKernel, .initLibrary = InitLibrary,
};
