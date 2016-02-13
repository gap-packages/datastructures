/*
 * Datastructures: GAP package providing common datastructures.
 * Licensed under the GPL 2 or later.
 */

#include "datastructures.h"

#include "avltree.h"
#include "hashtable-avl.h"
#include "hashfun.h"


// List of datastructure submodules
static struct DatastructuresModule *submodules[] = {
    &AVLTreeModule,
    &HashTableModule,
    &HashFunModule,
};

#define ITERATE_SUBMODULE(func) \
    for (int i = 0; i < ARRAYSIZE(submodules); ++i) { \
        if (submodules[i]->func) { \
            Int retVal = submodules[i]->func(); \
            if (retVal != 0) \
                return retVal; \
        } \
    }


static Int InitKernel( StructInitInfo *module )
{
    ITERATE_SUBMODULE(initKernel);
    return 0;
}

static Int InitLibrary( StructInitInfo *module )
{
    Int             gvar;
    Obj             tmp;

    ITERATE_SUBMODULE(initLibrary);

    tmp = NEW_PREC(0);
    gvar = GVarName("__DATASTRUCTURES_C");
    AssGVar( gvar, tmp );
    MakeReadOnlyGVar(gvar);

    return 0;
}

static Int PostRestore( StructInitInfo *module )
{
    ITERATE_SUBMODULE(postRestore);
    return 0;
}

/******************************************************************************
*F  InitInfopl()  . . . . . . . . . . . . . . . . . table of init functions
*/
static StructInitInfo module = {
    .type        = MODULE_DYNAMIC,
    .name        = "datastructures",
    .initKernel  = InitKernel,
    .initLibrary = InitLibrary,
    .postRestore = PostRestore,
};

StructInitInfo * Init__Dynamic(void)
{
    return &module;
}
