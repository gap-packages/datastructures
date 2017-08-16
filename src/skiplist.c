/*
 * Datastructures: GAP package providing common datastructures.
 * Licensed under the GPL 2 or later.
 */

#include "skiplist.h"

#include "src/debug.h"


static Obj DS_Skiplist_RemoveNode(Obj self, Obj lst, Obj nx)
{
    UInt level, len;
    Obj  node, x;
    GAP_ASSERT(IS_PLIST(lst));
    len = LEN_PLIST(lst);
    GAP_ASSERT(IS_PLIST(nx));
    GAP_ASSERT(len >= 2 && ELM_PLIST(lst, 2) && IS_PLIST(ELM_PLIST(lst, 2)) &&
               LEN_PLIST(ELM_PLIST(lst, 2)) >= 2 &&
               nx == ELM_PLIST(ELM_PLIST(lst, 2), 2));
    for (level = len; level > 1; level--) {
        node = ELM_PLIST(lst, level);
        GAP_ASSERT(node);
        GAP_ASSERT(IS_PLIST(node));
        if (LEN_PLIST(node) >= level && ELM_PLIST(node, level) == nx) {
            if (LEN_PLIST(nx) < level) {
                SET_ELM_PLIST(node, level, 0);
                SET_LEN_PLIST(node, level - 1);
            }
            else {
                x = ELM_PLIST(nx, level);
                SET_ELM_PLIST(node, level, x);
            }
        }
    }
    return 0;
}


static Obj DS_Skiplist_Scan(Obj self, Obj sl, Obj val, Obj lessFunc)
{
    Obj  ptr;
    UInt level;
    Obj  lst;
    Obj  nx;
    Obj  o;
    ptr = sl;
    GAP_ASSERT(IS_PLIST(ptr));
    level = LEN_PLIST(ptr);
    lst = NEW_PLIST(T_PLIST_DENSE, level);
    SET_LEN_PLIST(lst, level);
    while (level > 1) {
        if (LEN_PLIST(ptr) < level) {
            SET_ELM_PLIST(lst, level, ptr);    // no need for CHANGED_BAG
                                               // calls, ptr is in the
                                               // skiplist
            level--;
        }
        else {
            nx = ELM_PLIST(ptr, level);
            GAP_ASSERT(nx);
            GAP_ASSERT(IS_PLIST(nx));
            GAP_ASSERT(LEN_PLIST(nx) >= 1);
            GAP_ASSERT(ELM_PLIST(nx, 1));
            o = ELM_PLIST(nx, 1);
            if (True != CALL_2ARGS(lessFunc, o, val)) {
                SET_ELM_PLIST(lst, level, ptr);
                level--;
            }
            else {
                ptr = nx;
            }
        }
    }
    CHANGED_BAG(lst);    // just in case
    return lst;
}


static StructGVarFunc GVarFuncs[] = {
    GVARFUNC(DS_Skiplist_Scan, 3, "skiplist, val, lessFunc"),
    GVARFUNC(DS_Skiplist_RemoveNode, 2, "lst, nx"),
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

struct DatastructuresModule SkiplistModule = {
    .initKernel = InitKernel, .initLibrary = InitLibrary,
};
