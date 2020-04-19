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
// Helper function for pairing heaps implementation.
//

#include "compiled.h" // GAP headers
#include "pairingheap.h"

enum {
    // the following are indices into a pairing heap object

    HEAP_POS_SIZE = 1,    // node count
    HEAP_POS_ISLESS,      // comparison function
    HEAP_POS_NODES,       // nodes

    // the following are indices into the nodes of our pairing heap

    NODE_POS_DATA = 1,    // value of this node
    NODE_POS_SIZE,        // total number of nodes in the subheaps
    NODE_POS_SUBHEAPS,    // list of subheaps
};

Obj DS_merge_pairs(Obj self, Obj isLess, Obj heaps)
{
    if (!IS_DENSE_PLIST(heaps))
        ErrorQuit("<heaps> is not a dense plist", 0L, 0L);

    const UInt len = LEN_PLIST(heaps);
    Obj res;

    if (len == 0) {
        res = NEW_PLIST(T_PLIST_CYC, 3);
        SET_LEN_PLIST(res, 3);
        SET_ELM_PLIST(res, NODE_POS_DATA, INTOBJ_INT(0));
        SET_ELM_PLIST(res, NODE_POS_SIZE, INTOBJ_INT(0));
        SET_ELM_PLIST(res, NODE_POS_SUBHEAPS, INTOBJ_INT(0));
        return res;
    }

    if (len == 1) {
        return ELM_PLIST(heaps, 1);
    }

    const Int useLt = (isLess == LtOper);
    res = heaps;
    UInt k = len;
    UInt s = 1;
    UInt i;
    while (k > 1) {
        const UInt r = k & 1;
        const UInt old_s = s;
        k >>= 1;
        s <<= 1;
        for (i = s; i <= k * s; i += s) {
            GAP_ASSERT(i <= LEN_PLIST(res));
            Obj x = ELM_PLIST(res, i - old_s);
            Obj y = ELM_PLIST(res, i);
            GAP_ASSERT(IS_DENSE_PLIST(x));
            GAP_ASSERT(IS_DENSE_PLIST(y));

            Obj x_data = ELM_PLIST(x, NODE_POS_DATA);
            Obj y_data = ELM_PLIST(y, NODE_POS_DATA);
            if (useLt ? LT(y_data, x_data)
                      : (True == CALL_2ARGS(isLess, y_data, x_data))) {
                Obj x_subheaps = ELM_PLIST(x, NODE_POS_SUBHEAPS);
                AssPlist(x_subheaps, LEN_PLIST(x_subheaps) + 1, y);
                DS_IncrementCounterInPlist(x, NODE_POS_SIZE,
                                           ELM_PLIST(y, NODE_POS_SIZE));
                AssPlist(res, i, x);
            }
            else {
                Obj y_subheaps = ELM_PLIST(y, NODE_POS_SUBHEAPS);
                AssPlist(y_subheaps, LEN_PLIST(y_subheaps) + 1, x);
                DS_IncrementCounterInPlist(y, NODE_POS_SIZE,
                                           ELM_PLIST(x, NODE_POS_SIZE));
                AssPlist(res, i, y);
            }
        }
        // at this point, i == (k+1)*s
        if (r == 1) {
            k++;
            AssPlist(res, i, ELM_PLIST(res, i - old_s));
        }
    }
    return ELM_PLIST(res, k * s);
}

static StructGVarFunc GVarFuncs[] = {
    GVARFUNC(DS_merge_pairs, 2, "isLess, heaps"),
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

struct DatastructuresModule PairingHeapModule = {
    .initKernel = InitKernel, .initLibrary = InitLibrary,
};
