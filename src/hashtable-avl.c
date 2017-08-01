/*
 * Datastructures: GAP package providing common datastructures.
 * Licensed under the GPL 2 or later.
 *
 * This file contains a (pseudo) hash table based on an AVL tree,
 *  Copyright (C) 2009-2013  Max Neunhoeffer
 */

#include "hashtable-avl.h"
#include "avltree.h"

static Obj HTGrow;         /* Operation function imported from the library */

static Int RNam_accesses = 0;
static Int RNam_collisions = 0;
static Int RNam_hfd = 0;
static Int RNam_hf = 0;
static Int RNam_els = 0;
static Int RNam_vals = 0;
static Int RNam_nr = 0;
static Int RNam_cmpfunc = 0;
static Int RNam_allocsize = 0;
static Int RNam_cangrow = 0;
static Int RNam_len = 0;

Obj HTAdd_TreeHash_C(Obj self, Obj ht, Obj x, Obj v)
{
    Obj els;
    Obj vals;
    Obj tmp;
    Obj hfd;
    Int h;
    Obj t;
    Obj r;

    /* Increment accesses entry: */
    tmp = ElmPRec(ht,RNam_accesses);
    tmp = INTOBJ_INT(INT_INTOBJ(tmp)+1);
    AssPRec(ht,RNam_accesses,tmp);

    if (ElmPRec(ht,RNam_cangrow) == True &&
        INT_INTOBJ(ElmPRec(ht,RNam_nr))/10 > INT_INTOBJ(ElmPRec(ht,RNam_len)))
    {
        CALL_2ARGS(HTGrow,ht,x);
    }

    /* Compute hash value: */
    hfd = ElmPRec(ht,RNam_hfd);
    tmp = ElmPRec(ht,RNam_hf);
    h = INT_INTOBJ(CALL_2ARGS(tmp,x,hfd));

    /* Lookup slot: */
    els = ElmPRec(ht,RNam_els);
    vals = ElmPRec(ht,RNam_vals);
    tmp = ELM_PLIST(els,h);    /* Note that hash values are always within
                                  the boundaries of this list */
    if (tmp == 0L) { /* Unbound entry! */
        SET_ELM_PLIST(els,h,x);
        CHANGED_BAG(els);
        if (v != True) ASS_LIST(vals,h,v);
        AssPRec(ht,RNam_nr,INTOBJ_INT(INT_INTOBJ(ElmPRec(ht,RNam_nr))+1));
        return INTOBJ_INT(h);
    }

    /* Count collision: */
    AssPRec(ht,RNam_collisions,
            INTOBJ_INT(INT_INTOBJ(ElmPRec(ht,RNam_collisions))+1));

    /* Now check whether it is an DS_AVLTree or not: */
    if (TNUM_OBJ(tmp) != T_POSOBJ ||
        (TYPE_POSOBJ(tmp) != DS_AVLTreeTypeMutable &&
         TYPE_POSOBJ(tmp) != DS_AVLTreeType)) {
        r = NEW_PREC(2);   /* This might trigger a garbage collection */
        AssPRec(r,RNam_cmpfunc,ElmPRec(ht,RNam_cmpfunc));
        AssPRec(r,RNam_allocsize,INTOBJ_INT(3));
        t = CALL_1ARGS(DS_AVLTree,r);
        if (LEN_PLIST(vals) >= h && ELM_PLIST(vals,h) != 0L) {
            DS_AVLAdd_C(self,t,tmp,ELM_PLIST(vals,h));
            UNB_LIST(vals,h);
        } else {
            DS_AVLAdd_C(self,t,tmp,True);
        }
        SET_ELM_PLIST(els,h,t);
        CHANGED_BAG(els);
    } else t = tmp;

    /* Finally add value into tree: */
    if (v != True) {
        r = DS_AVLAdd_C(self,t,x,v);
    } else {
        r = DS_AVLAdd_C(self,t,x,True);
    }

    if (r != Fail) {
        AssPRec(ht,RNam_nr,INTOBJ_INT(INT_INTOBJ(ElmPRec(ht,RNam_nr))+1));
        return INTOBJ_INT(h);
    } else
        return Fail;
}

Obj HTValue_TreeHash_C(Obj self, Obj ht, Obj x)
{
    Obj els;
    Obj vals;
    Obj hfd;
    Int h;
    Obj t;

    /* Increment accesses entry: */
    t = ElmPRec(ht,RNam_accesses);
    t = INTOBJ_INT(INT_INTOBJ(t)+1);
    AssPRec(ht,RNam_accesses,t);

    /* Compute hash value: */
    hfd = ElmPRec(ht,RNam_hfd);
    t = ElmPRec(ht,RNam_hf);
    h = INT_INTOBJ(CALL_2ARGS(t,x,hfd));

    /* Lookup slot: */
    els = ElmPRec(ht,RNam_els);
    vals = ElmPRec(ht,RNam_vals);
    t = ELM_PLIST(els,h);    /* Note that hash values are always within
                                  the boundaries of this list */
    if (t == 0L)  /* Unbound entry! */
        return Fail;

    /* Now check whether it is an DS_AVLTree or not: */
    if (TNUM_OBJ(t) != T_POSOBJ ||
        (TYPE_POSOBJ(t) != DS_AVLTreeType &&
         TYPE_POSOBJ(t) != DS_AVLTreeTypeMutable)) {
        if (CALL_2ARGS(ElmPRec(ht,RNam_cmpfunc),x,t) == INTOBJ_INT(0)) {
            if (LEN_PLIST(vals) >= h && ELM_PLIST(vals,h) != 0L)
                return ELM_PLIST(vals,h);
            else
                return True;
        }
        return Fail;
    }

    h = DS_AVLFind(t,x);
    if (h == 0) return Fail;
    return DS_AVLValue(t,h);
}

Obj HTDelete_TreeHash_C(Obj self, Obj ht, Obj x)
{
    Obj els;
    Obj vals;
    Obj hfd;
    Int h;
    Obj t;
    Obj v;

    /* Compute hash value: */
    hfd = ElmPRec(ht,RNam_hfd);
    t = ElmPRec(ht,RNam_hf);
    h = INT_INTOBJ(CALL_2ARGS(t,x,hfd));

    /* Lookup slot: */
    els = ElmPRec(ht,RNam_els);
    vals = ElmPRec(ht,RNam_vals);
    t = ELM_PLIST(els,h);    /* Note that hash values are always within
                                  the boundaries of this list */
    if (t == 0L)  /* Unbound entry! */
        return Fail;

    /* Now check whether it is an DS_AVLTree or not: */
    if (TNUM_OBJ(t) != T_POSOBJ ||
        (TYPE_POSOBJ(t) != DS_AVLTreeType &&
         TYPE_POSOBJ(t) != DS_AVLTreeTypeMutable)) {
        if (CALL_2ARGS(ElmPRec(ht,RNam_cmpfunc),x,t) == INTOBJ_INT(0)) {
            if (LEN_PLIST(vals) >= h && ELM_PLIST(vals,h) != 0L) {
                v = ELM_PLIST(vals,h);
                UNB_LIST(vals,h);
            } else v = True;
            SET_ELM_PLIST(els,h,0L);
            AssPRec(ht,RNam_nr,INTOBJ_INT(INT_INTOBJ(ElmPRec(ht,RNam_nr))-1));
            return v;
        }
        return Fail;
    }

    v = DS_AVLDelete_C(self,t,x);
    if (v != Fail)
        AssPRec(ht,RNam_nr,INTOBJ_INT(INT_INTOBJ(ElmPRec(ht,RNam_nr))-1));

    return v;
}

Obj HTUpdate_TreeHash_C(Obj self, Obj ht, Obj x, Obj v)
{
    Obj els;
    Obj vals;
    Obj hfd;
    Int h;
    Obj t;
    Obj old;

    /* Compute hash value: */
    hfd = ElmPRec(ht,RNam_hfd);
    t = ElmPRec(ht,RNam_hf);
    h = INT_INTOBJ(CALL_2ARGS(t,x,hfd));

    /* Lookup slot: */
    els = ElmPRec(ht,RNam_els);
    vals = ElmPRec(ht,RNam_vals);
    t = ELM_PLIST(els,h);    /* Note that hash values are always within
                                  the boundaries of this list */
    if (t == 0L)  /* Unbound entry! */
        return Fail;

    /* Now check whether it is an DS_AVLTree or not: */
    if (TNUM_OBJ(t) != T_POSOBJ ||
        (TYPE_POSOBJ(t) != DS_AVLTreeType &&
         TYPE_POSOBJ(t) != DS_AVLTreeTypeMutable)) {
        if (CALL_2ARGS(ElmPRec(ht,RNam_cmpfunc),x,t) == INTOBJ_INT(0)) {
            if (LEN_PLIST(vals) >= h && ELM_PLIST(vals,h) != 0L) {
                old = ELM_PLIST(vals,h);
                SET_ELM_PLIST(vals,h,v);
                CHANGED_BAG(vals);
                return old;
            } else return True;
        }
        return Fail;
    }

    h = DS_AVLFind(t,x);
    if (h == 0) return Fail;
    old = DS_AVLValue(t,h);
    SetDS_AVLValue(t,h,v);
    return old;
}


//
// Submodule declaration
//
static StructGVarFunc GVarFuncs[] = {
    GVARFUNC("hashtable.c", HTAdd_TreeHash_C, 3, "treehash, x, v"),
    GVARFUNC("hashtable.c", HTValue_TreeHash_C, 2, "treehash, x"),
    GVARFUNC("hashtable.c", HTDelete_TreeHash_C, 2, "treehash, x"),
    GVARFUNC("hashtable.c", HTUpdate_TreeHash_C, 3, "treehash, x, v"),

    { 0 }
};

static Int InitKernel(void)
{
    InitHdlrFuncsFromTable( GVarFuncs );
    ImportFuncFromLibrary( "HTGrow", &HTGrow );
    return 0;
}

static Int PostRestore(void)
{
    RNam_accesses = RNamName("accesses");
    RNam_collisions = RNamName("collisions");
    RNam_hfd = RNamName("hfd");
    RNam_hf = RNamName("hf");
    RNam_els = RNamName("els");
    RNam_vals = RNamName("vals");
    RNam_nr = RNamName("nr");
    RNam_cmpfunc = RNamName("cmpfunc");
    RNam_allocsize = RNamName("allocsize");
    RNam_cangrow = RNamName("cangrow");
    RNam_len = RNamName("len");

    return 0;
}

static Int InitLibrary(void)
{
    InitGVarFuncsFromTable(GVarFuncs);
    
    // make sure PostRestore() is always run when we are loaded
    return PostRestore();
}

struct DatastructuresModule HashTableModule = {
    .initKernel  = InitKernel,
    .initLibrary = InitLibrary,
    .postRestore = PostRestore,
};
