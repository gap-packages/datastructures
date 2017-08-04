/*
 * Datastructures: GAP package providing common datastructures.
 * Licensed under the GPL 2 or later.
 *
 * hashfunctions: various hash functions
 */

#include "hashfunctions.h"

#include "src/objects.h"
#include "src/permutat.h"
#include "src/trans.h"
#include "src/pperm.h"


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

// We have to handle two interesting cases here:
// 1) Two equal permutations can have different numbers of fixed points
// at the end, so we do not hash these
// 2) A permutation might be a PERM4, but fit in a PERM2. In this case
// we have to turn the permutation into a PERM2, to get a consistent
// hash value
Int DataHashFuncForPerm(Obj perm)
{
    GAP_ASSERT(TNUM_OBJ(perm) == T_PERM2 || TNUM_OBJ(perm) == T_PERM4);
    UInt max_point = LargestMovedPointPerm(perm);

    if (TNUM_OBJ(perm) == T_PERM2) {
        return HASHKEY_BAG_NC(perm, 1, 0, max_point * 2);
    }
    else if (max_point <= 65536) {
        Obj squash = SquashToPerm2(perm, max_point);
        return HASHKEY_BAG_NC(squash, 1, 0, max_point * 2);
    }
    else {
        return HASHKEY_BAG_NC(perm, 1, 0, max_point * 4);
    }
}
Obj DATA_HASH_FUNC_FOR_PERM(Obj self, Obj perm)
{
    /* check the argument                                                  */
    if (TNUM_OBJ(perm) != T_PERM2 && TNUM_OBJ(perm) != T_PERM4) {
        ErrorMayQuit("DATA_HASH_FUNC_FOR_PERM: <perm> must be a permutation "
                     "(not a %s)",
                     (Int)TNAM_OBJ(perm), 0L);
    }

    return HashValueToObjInt(DataHashFuncForPerm(perm));
}

Obj DATA_HASH_FUNC_FOR_PPERM(Obj self, Obj pperm)
{
    /* check the argument                                                  */
    if (!IS_PPERM(pperm)) {
        ErrorMayQuit("DATA_HASH_FUNC_FOR_PPERM: <pperm> must be a "
                     "partial permutation (not a %s)",
                     (Int)TNAM_OBJ(pperm), 0L);
    }

    return HashValueToObjInt(HashFuncForPPerm(pperm));
}

Obj DATA_HASH_FUNC_FOR_TRANS(Obj self, Obj trans)
{
    /* check the argument                                                  */
    if (!IS_TRANS(trans)) {
        ErrorMayQuit("DATA_HASH_FUNC_FOR_TRANS: <trans> must be a "
                     "transformation (not a %s)",
                     (Int)TNAM_OBJ(trans), 0L);
    }

    return HashValueToObjInt(HashFuncForTrans(trans));
}

Obj DATA_HASH_FUNC_FOR_STRING(Obj self, Obj string)
{
    /* check the argument                                                  */
    if (!IS_STRING(string)) {
        ErrorMayQuit("DATA_HASH_FUNC_FOR_STRING: <string> must be a "
                     "string (not a %s)",
                     (Int)TNAM_OBJ(string), 0L);
    }

    if(!IS_STRING_REP(string))
    {
        string = CopyToStringRep(string);
    }


    UInt len = GET_LEN_STRING(string);
    UInt1* ptr = CHARS_STRING(string);

    UInt hashval = HASHKEY_MEM_NC(ptr, 2782, len);
    return HashValueToObjInt(hashval);
}

Int DataHashFuncForInt(Obj i)
{
    GAP_ASSERT(TNUM_OBJ(i) == T_INTPOS || TNUM_OBJ(i) == T_INTNEG);
    if (TNUM_OBJ(i) == T_INTPOS)
    {
        return HASHKEY_WHOLE_BAG_NC(i, 293479);
    }
    else
    {
        return HASHKEY_WHOLE_BAG_NC(i, 193492);
    }
}

Obj DATA_HASH_FUNC_FOR_INT(Obj self, Obj i)
{
    /* check the argument                                                  */
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

Int BasicRecursiveHash(Obj obj);

Int BasicRecursiveHashForList(Obj obj)
{
    GAP_ASSERT(IS_LIST(obj));
    // This is just a randomly chosen number which fits in a 32-bit integer
    UInt current_hash = 2195952830;
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
    GAP_ASSERT(IS_PREC_REP(obj));

    UInt current_hash = 1928498392;

    /* ensure record is sorted */
    SortPRecRNam(obj, 0);

    /* hash componentwise                                               */
    for (Int i = 1; i <= LEN_PREC(obj); i++) {
        UInt recname = GET_RNAM_PREC(obj, i);
        UInt rechash = BasicRecursiveHash(GET_ELM_PREC(obj, i));
        current_hash = HashCombine3(current_hash, recname, rechash);
    }

    return current_hash;
}

Int BasicPrimitiveHash(Obj obj)
{
    if (IS_INTOBJ(obj)) {
        return (Int)obj;
    }
    else if (TNUM_OBJ(obj) == T_CHAR) {
        return *(UChar *)ADDR_OBJ(obj);
    }
    else if (TNUM_OBJ(obj) == T_BOOL) {
        if (obj == True)
            return 1;
        else if (obj == False)
            return 2;
        else if (obj == Fail)
            return 3;
    }
    else if (TNUM_OBJ(obj) == T_INTPOS || TNUM_OBJ(obj) == T_INTNEG) {
        return DataHashFuncForInt(obj);
    }
    else if (IS_PERM2(obj) || IS_PERM4(obj)) {
        return DataHashFuncForPerm(obj);
    }
    else if (IS_PPERM(obj)) {
        return HashFuncForPPerm(obj);
    }
    else if (IS_TRANS(obj)) {
        return HashFuncForTrans(obj);
    }

    ErrorMayQuit("Unable to hash %s", (Int)TNAM_OBJ(obj), 0L);
    return 0;
}


Obj DATA_HASH_FUNC_PRIMITIVE(Obj self, Obj obj)
{
    Int hash = BasicPrimitiveHash(obj);
    return HashValueToObjInt(hash);
}

Int BasicRecursiveHash(Obj obj)
{
    if (IS_LIST(obj)) {
        return BasicRecursiveHashForList(obj);
    }
    else if (IS_PREC_REP(obj)) {
        return BasicRecursiveHashForPRec(obj);
    }

    // This will produce an error if it fails
    return BasicPrimitiveHash(obj);
}

Obj DATA_HASH_FUNC_RECURSIVE(Obj self, Obj obj)
{
    Int hash = BasicRecursiveHash(obj);
    return HashValueToObjInt(hash);
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
    GVARFUNC(DATA_HASH_FUNC_PRIMITIVE, 1, "object"),
    GVARFUNC(DATA_HASH_FUNC_RECURSIVE, 1, "object"),
    { 0 }
};

static Int InitKernel(void)
{
    InitHdlrFuncsFromTable(GVarFuncs);
    return 0;
}

static Int InitLibrary(void)
{
    InitGVarFuncsFromTable(GVarFuncs);
    return 0;
}

struct DatastructuresModule HashFunctionsModule = {
    .initKernel = InitKernel, .initLibrary = InitLibrary,
};
