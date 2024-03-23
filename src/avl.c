/*
 * Datastructures: GAP package providing common datastructures.
 * Licensed under the GPL 2 or later.
 */

#include "avl.h"

enum {
    AVL_LEFT = 1,
    AVL_VAL = 2,
    AVL_RIGHT = 3,
    AVL_FLAGS = 4
};

static Obj FuncDS_AVL_FIND(Obj self, Obj tree, Obj val, Obj less)
{
    const UInt lmask = 0x4;
    const UInt rmask = 0x8;
    Obj        node;
    UInt       flags;
    Obj        d;
    GAP_ASSERT(IS_PLIST(tree));
    if (LEN_PLIST(tree) < 1 || ELM_PLIST(tree, 1) == 0)
        return Fail;
    node = ELM_PLIST(tree, 1);
    while (1) {
        GAP_ASSERT(IS_PLIST(node));
        GAP_ASSERT(LEN_PLIST(node) >= AVL_FLAGS);
        GAP_ASSERT(IS_INTOBJ(ELM_PLIST(node, AVL_FLAGS)));
        d = ELM_PLIST(node, AVL_VAL);
        GAP_ASSERT(d);
        if (EQ(d, val))
            return node;
        flags = INT_INTOBJ(ELM_PLIST(node, AVL_FLAGS));
        if (CALL_2ARGS(less, val, d) == True) {
            if (flags & lmask) {
                node = ELM_PLIST(node, AVL_LEFT);
            }
            else
                return Fail;
        }
        else {
            if (flags & rmask) {
                node = ELM_PLIST(node, AVL_RIGHT);
            }
            else {
                return Fail;
            }
        }
        GAP_ASSERT(node);
    }
}



static Obj
FuncDS_AVL_ADDSET_INNER(Obj self, Obj avl, Obj val, Obj less, Obj trinode)
{
    Obj  child;
    UInt dirn;
    UInt i;
    Obj  deeper;
    UInt maski;
    UInt j;
    UInt flags;
    Obj  d = ELM_PLIST(avl, AVL_VAL);
    if (EQ(val, d))
        return Fail;
    flags = INT_INTOBJ(ELM_PLIST(avl, AVL_FLAGS));
    if (True == CALL_2ARGS(less, val, d)) {
        dirn = 0;
        i = AVL_LEFT;
        j = AVL_RIGHT;
        maski = 0x4;
    }
    else {
        dirn = 2;
        i = AVL_RIGHT;
        j = AVL_LEFT;
        maski = 0x8;
    }
    if (!(maski & flags)) {
        child = NEW_PLIST(T_PLIST, 4);
        SET_LEN_PLIST(child, 4);
        SET_ELM_PLIST(child, AVL_FLAGS, INTOBJ_INT(0x11));
        SET_ELM_PLIST(child, AVL_VAL, val);
        SET_ELM_PLIST(child, j, avl);
        SET_ELM_PLIST(child, i, ELM_PLIST(avl, i));
        CHANGED_BAG(child);
        SET_ELM_PLIST(avl, i, child);
        CHANGED_BAG(avl);
        flags += 0x10;     /* increase size by 1 */
        flags |= maski;    /* node now has a valid i-child */
        flags += dirn - 1; /* imbalance adjusts, but can't overflow */
        SET_ELM_PLIST(avl, AVL_FLAGS, INTOBJ_INT(flags));
        return INTOBJ_INT((flags & 0x3) == 1 ? 0 : 1);
    }
    else {
        child = ELM_PLIST(avl, i);
        deeper = FuncDS_AVL_ADDSET_INNER((Obj)0, child, val, less, trinode);
        if (deeper == INTOBJ_INT(0)) {
            /* we just have to increase the size of subtree */
            SET_ELM_PLIST(avl, AVL_FLAGS, INTOBJ_INT(flags + 0x10));
            return INTOBJ_INT(0);
        }
        if (deeper == Fail)
            return Fail;
        if (deeper == INTOBJ_INT(1)) {
            if ((flags & 0x3) != dirn) {
                flags += dirn - 1;
                flags += 0x10;
                SET_ELM_PLIST(avl, AVL_FLAGS, INTOBJ_INT(flags));
                return INTOBJ_INT((flags & 0x3) != 1 ? 1 : 0);
            }
            else {
                return ELM_PLIST(CALL_1ARGS(trinode, avl), 2);
            }
        }
        SET_ELM_PLIST(avl, i, deeper);
        SET_ELM_PLIST(avl, AVL_FLAGS, INTOBJ_INT(flags + 0x10));
        CHANGED_BAG(avl);
        return INTOBJ_INT(0);
    }
}




static Obj FuncDS_AVL_REMSET_INNER(Obj self,
                                Obj node,
                                Obj val,
                                Obj less,
                                Obj remove_extremal,
                                Obj trinode,
                                Obj remove_this)
{
    GAP_ASSERT(IS_PLIST(node));
    GAP_ASSERT(LEN_PLIST(node) >= 4);
    Obj  d = ELM_PLIST(node, 2);
    UInt i;
    UInt flags;
    UInt imask;
    Obj  ret;
    Obj  new_subtree;
    Obj  child;
    Int  depth_change;
    UInt im;
    GAP_ASSERT(d);
    if (EQ(val, d))
        return CALL_3ARGS(remove_this, node, remove_extremal, trinode);
    if (True == CALL_2ARGS(less, val, d)) {
        i = 1;
        imask = 0x4;
    }
    else {
        i = 3;
        imask = 0x8;
    }
    GAP_ASSERT(ELM_PLIST(node, 4));
    GAP_ASSERT(IS_INTOBJ(ELM_PLIST(node, 4)));
    flags = INT_INTOBJ(ELM_PLIST(node, 4));

    if (flags & imask) {
        GAP_ASSERT(ELM_PLIST(node, i));
	child = ELM_PLIST(node, i);
        ret = FuncDS_AVL_REMSET_INNER(0, child, val, less,
                                   remove_extremal, trinode, remove_this);
        if (ret == Fail)
            return Fail;
        GAP_ASSERT(IS_PLIST(ret));
        GAP_ASSERT(LEN_PLIST(ret) == 2);
        new_subtree = ELM_PLIST(ret, 2);
        if (new_subtree != Fail)
            SET_ELM_PLIST(node, i, new_subtree);
        else {
            flags &= ~imask;
            SET_ELM_PLIST(node, i, ELM_PLIST(child, i));
        }
    }
    else {
        return Fail;
    }
    flags -= 0x10;
    depth_change = INT_INTOBJ(ELM_PLIST(ret, 1));
    if (depth_change == 0) {
        SET_ELM_PLIST(node, AVL_FLAGS, INTOBJ_INT(flags));
        SET_ELM_PLIST(ret, 2, node);
        return ret;
    }
    im = flags & 0x3;
    if (im == i - 1) {
        SET_ELM_PLIST(node, AVL_FLAGS, INTOBJ_INT((flags & ~0x3) | 1));
        SET_ELM_PLIST(ret, 2, node);
        return ret;
    }
    else if (im == 1) {
        SET_ELM_PLIST(node, AVL_FLAGS, INTOBJ_INT((flags & ~0x3) | 3 - i));
        SET_ELM_PLIST(ret, 1, INTOBJ_INT(0));
        SET_ELM_PLIST(ret, 2, node);
        return ret;
    }

    SET_ELM_PLIST(node, AVL_FLAGS, INTOBJ_INT(flags));
    return CALL_1ARGS(trinode, node);
}


static StructGVarFunc GVarFuncs[] = {
    GVAR_FUNC_3ARGS(DS_AVL_FIND, avl, val, lessFunc),
    GVAR_FUNC_4ARGS(DS_AVL_ADDSET_INNER, avl, val, lessFunc, trinode),
    GVAR_FUNC_6ARGS(DS_AVL_REMSET_INNER, avl, val, lessFunc, remove_extremal, trinode, remove_this),
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

struct DatastructuresModule AVLModule = {
    .initKernel = InitKernel, .initLibrary = InitLibrary,
};
