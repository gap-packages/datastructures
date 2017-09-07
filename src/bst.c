/*
 * Datastructures: GAP package providing common datastructures.
 * Licensed under the GPL 2 or later.
 */

#include "bst.h"

#include "src/debug.h"

enum { BST_LEFT = 1, BST_VAL = 2, BST_RIGHT = 3, AVL_IMBALANCE = 4, AVL2_FLAGS = 4 };

Obj DS_BST_FIND(Obj self, Obj bst, Obj val, Obj less)
{
    UInt ix = 1;
    Obj  child;
    Obj  res = NEW_PLIST(T_PLIST_DENSE, 3);
    Obj  d;
    SET_LEN_PLIST(res, 3);
    while (1) {
        GAP_ASSERT(IS_PLIST(bst));
        if (LEN_PLIST(bst) < ix || !(child = ELM_PLIST(bst, ix))) {
            SET_ELM_PLIST(res, 1, bst);
            SET_ELM_PLIST(res, 2, INTOBJ_INT(ix));
            SET_ELM_PLIST(res, 3, False);
            return res;
        }
        GAP_ASSERT(IS_PLIST(child) && LEN_PLIST(child) >= BST_VAL &&
                   ELM_PLIST(child, BST_VAL));
        d = ELM_PLIST(child, BST_VAL);
        if (True == CALL_2ARGS(less, val, d)) {
            bst = child;
            ix = BST_LEFT;
        }
        else if (!EQ(val, d)) {
            bst = child;
            ix = BST_RIGHT;
        }
        else {
            SET_ELM_PLIST(res, 1, bst);
            SET_ELM_PLIST(res, 2, INTOBJ_INT(ix));
            SET_ELM_PLIST(res, 3, True);
            return res;
        }
    }
}


static Obj DS_AVL_ADDSET_INNER(Obj self, Obj avl, Obj val, Obj less, Obj trinode) {
    Obj  child;
    UInt dirn;
    UInt i;
    UInt x;
    Obj  deeper;
    Obj d = ELM_PLIST(avl, BST_VAL);
    if EQ(val, d)
	   return Fail;
    dirn =  (True == CALL_2ARGS(less, val, d)) ? -1:1;
    i = (dirn == 1) ? BST_RIGHT : BST_LEFT;
    if (!(child = ELM_PLIST(avl, i))) {
        child = NEW_PLIST(T_PLIST, 4);
        SET_LEN_PLIST(child, 4);
        SET_ELM_PLIST(child, AVL_IMBALANCE, INTOBJ_INT(0));
        SET_ELM_PLIST(child, BST_VAL, val);
        SET_ELM_PLIST(child, BST_LEFT, 0);
        SET_ELM_PLIST(child, BST_RIGHT, 0);
        CHANGED_BAG(child);
        SET_ELM_PLIST(avl, i, child);
        CHANGED_BAG(avl);
        x = INT_INTOBJ(ELM_PLIST(avl, AVL_IMBALANCE)) + dirn;
        SET_ELM_PLIST(avl, AVL_IMBALANCE, INTOBJ_INT(x));
        return INTOBJ_INT(x != 0 ? 1 : 0);
    }
    else {
        deeper = DS_AVL_ADDSET_INNER((Obj)0, child, val, less, trinode);
        if (deeper == Fail || deeper == INTOBJ_INT(0)) {
            return deeper;
        }
        else if (deeper == INTOBJ_INT(1)) {
            x = INT_INTOBJ(ELM_PLIST(avl, AVL_IMBALANCE));
            if (x != dirn) {
                x += dirn;
                SET_ELM_PLIST(avl, AVL_IMBALANCE, INTOBJ_INT(x));
                return INTOBJ_INT(x != 0 ? 1 : 0);
            }
            else {
	     return CALL_1ARGS(trinode, avl);
            }
        }
        else {
            SET_ELM_PLIST(avl, i, deeper);
            CHANGED_BAG(avl);
            return INTOBJ_INT(0);
        }
    }
}

static Obj DS_AVL2_ADDSET_INNER(Obj self, Obj avl, Obj val, Obj less, Obj trinode) {
    Obj  child;
    UInt dirn;
    UInt i;
    UInt x;
    Obj  deeper;
    UInt maski;
    UInt j;
    UInt flags;
    Obj d = ELM_PLIST(avl, BST_VAL);
    if (EQ(val, d))
	   return Fail;
    flags = INT_INTOBJ(ELM_PLIST(avl,AVL2_FLAGS));
    if (True == CALL_2ARGS(less, val, d)) {
      dirn = 0;
      i = BST_LEFT;
      j = BST_RIGHT;
      maski = 0x4;
    } else {
      dirn = 2;
      i = BST_RIGHT;
      j = BST_LEFT;
      maski = 0x8;
    }
    if (!(maski & flags)) {
      child = NEW_PLIST(T_PLIST, 4);
      SET_LEN_PLIST(child, 4);
      SET_ELM_PLIST(child, AVL2_FLAGS, INTOBJ_INT(0x11));
      SET_ELM_PLIST(child, BST_VAL, val);
      SET_ELM_PLIST(child, j, avl);
      SET_ELM_PLIST(child, i, ELM_PLIST(avl,i));
      CHANGED_BAG(child);
      SET_ELM_PLIST(avl, i, child);
      CHANGED_BAG(avl);
      flags += 0x10; /* increase size by 1 */
      flags |= maski; /* node now has a valid i-child */
      flags += dirn-1; /* imbalance adjusts, but can't overflow */
      SET_ELM_PLIST(avl, AVL2_FLAGS, INTOBJ_INT(flags));
      return INTOBJ_INT((flags & 0x3) == 1 ? 0 : 1);
    }
    else {
        child = ELM_PLIST(avl, i);
        deeper = DS_AVL2_ADDSET_INNER((Obj)0, child, val, less, trinode);
	if (deeper == INTOBJ_INT(0)) {
	  /* we just have to increase the size of subtree */
	  SET_ELM_PLIST(avl, AVL2_FLAGS, INTOBJ_INT(flags + 0x10));
	  return INTOBJ_INT(0);
        }
        if (deeper == Fail)
	  return Fail;
        if (deeper == INTOBJ_INT(1)) {
            x = INT_INTOBJ(ELM_PLIST(avl, AVL2_FLAGS));
            if ((x & 0x3) != dirn) {
                x += dirn-1;
		x += 0x10;
                SET_ELM_PLIST(avl, AVL2_FLAGS, INTOBJ_INT(x));
                return INTOBJ_INT((x&0x3) != 1 ? 1 : 0);
            } else {
	      return ELM_PLIST(CALL_1ARGS(trinode, avl),2);
            }
        } 
	SET_ELM_PLIST(avl, i, deeper);
	SET_ELM_PLIST(avl, AVL2_FLAGS, INTOBJ_INT(flags + 0x10));
	CHANGED_BAG(avl);
	return INTOBJ_INT(0);
    }
}


static Obj DS_AVL_REMSET_INNER(Obj self,
                               Obj node,
                               Obj val,
                               Obj less,
                               Obj remove_extremal,
                               Obj trinode,
                               Obj remove_this)
{
    Obj  d = ELM_PLIST(node, BST_VAL);
    Obj  ret;
    UInt i, im;
    Obj  child;
    if (EQ(d, val))
        return CALL_3ARGS(remove_this, node, remove_extremal, trinode);
    i = (True == CALL_2ARGS(less, val, d)) ? BST_LEFT : BST_RIGHT;
    child = ELM_PLIST(node, i);
    if (!child)
        return Fail;
    ret = DS_AVL_REMSET_INNER(0, child, val, less, remove_extremal, trinode,
                              remove_this);
    if (ret == Fail)
        return Fail;
    child = ELM_PLIST(ret, 2);
    if (child != Fail) {
        SET_ELM_PLIST(node, i, child);
        CHANGED_BAG(node);
    }
    else {
        SET_ELM_PLIST(node, i, 0);
    }

    if (ELM_PLIST(ret, 1) == INTOBJ_INT(0)) {
        SET_ELM_PLIST(ret, 2, node);
        CHANGED_BAG(ret);
        return ret;
    }

    im = INT_INTOBJ(ELM_PLIST(node, AVL_IMBALANCE));
    if ((im == -1 && i == BST_LEFT) || (im == 1 && i == BST_RIGHT)) {
        SET_ELM_PLIST(node, AVL_IMBALANCE, INTOBJ_INT(0));
        SET_ELM_PLIST(ret, 1, INTOBJ_INT(-1));
        SET_ELM_PLIST(ret, 2, node);
        CHANGED_BAG(ret);
        return ret;
    }
    else if (!im) {
        SET_ELM_PLIST(node, AVL_IMBALANCE,
                      INTOBJ_INT((i == BST_LEFT) ? 1 : -1));
        SET_ELM_PLIST(ret, 1, INTOBJ_INT(0));
        SET_ELM_PLIST(ret, 2, node);
        CHANGED_BAG(ret);
        return ret;
    }
    return CALL_1ARGS(trinode, node);
}


static StructGVarFunc GVarFuncs[] = {
    GVARFUNC(DS_BST_FIND, 3, "bst, val, lessFunc"),
    GVARFUNC(DS_AVL_ADDSET_INNER, 4, "avl, val, lessFunc, trinode"),
    GVARFUNC(DS_AVL2_ADDSET_INNER, 4, "avl, val, lessFunc, trinode"),
    GVARFUNC(DS_AVL_REMSET_INNER,
             6,
             "avl, val, lessFunc, remove_extremal, trinode, remove_this"),
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

struct DatastructuresModule BSTModule = {
    .initKernel = InitKernel, .initLibrary = InitLibrary,
};
