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

#include "datastructures.h"
#include "binaryheap.h"
#include "hashmap.h"
#include "pairingheap.h"
#include "skiplist.h"
#include "avl.h"
#include "uf.h"

#include <src/gaputils.h>

#include "hashfunctions.h"

// List of datastructure submodules
static struct DatastructuresModule * submodules[] = {
    &BinaryHeapModule,
    &HashFunctionsModule,
    &HashmapModule,
    &PairingHeapModule,
    &SkiplistModule,
    &AVLModule
    &UFModule
};

#define ITERATE_SUBMODULE(func)                                              \
    for (int i = 0; i < ARRAY_SIZE(submodules); ++i) {                       \
        if (submodules[i]->func) {                                           \
            Int retVal = submodules[i]->func();                              \
            if (retVal != 0)                                                 \
                return retVal;                                               \
        }                                                                    \
    }

void DS_IncrementCounterInPlist(Obj plist, Int pos, Obj inc)
{
    Obj val = ELM_PLIST(plist, pos);
    GAP_ASSERT(IS_INTOBJ(val));
    GAP_ASSERT(IS_INTOBJ(inc));
    GAP_ASSERT(inc >= INTOBJ_INT(0));
    if (!SUM_INTOBJS(val, val, inc))
        ErrorMayQuit("PANIC: counter overflow", 0, 0);
    SET_ELM_PLIST(plist, pos, val);
}

void DS_DecrementCounterInPlist(Obj plist, Int pos, Obj dec)
{
    Obj val = ELM_PLIST(plist, pos);
    GAP_ASSERT(IS_INTOBJ(val));
    GAP_ASSERT(IS_INTOBJ(dec));
    GAP_ASSERT(dec >= INTOBJ_INT(0));
    if (val < dec)
        ErrorMayQuit("PANIC: counter underflow", 0, 0);
    DIFF_INTOBJS(val, val, dec);
    SET_ELM_PLIST(plist, pos, val);
}


static Int InitKernel(StructInitInfo * module)
{
    ITERATE_SUBMODULE(initKernel);
    return 0;
}

static Int InitLibrary(StructInitInfo * module)
{
    Int gvar;
    Obj tmp;

    ITERATE_SUBMODULE(initLibrary);

    tmp = NEW_PREC(0);
    gvar = GVarName("__DATASTRUCTURES_C");
    AssGVar(gvar, tmp);
    MakeReadOnlyGVar(gvar);

    return 0;
}

/******************************************************************************
*F  InitInfopl()  . . . . . . . . . . . . . . . . . table of init functions
*/
static StructInitInfo module = {
    .type = MODULE_DYNAMIC,
    .name = "datastructures",
    .initKernel = InitKernel,
    .initLibrary = InitLibrary,
};

StructInitInfo * Init__Dynamic(void)
{
    return &module;
}
