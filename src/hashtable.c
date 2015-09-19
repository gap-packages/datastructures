/***************************************************************************
**
*A  hashtable.c               GAPData-package               Max Neunhoeffer
**
**  Copyright (C) 2009  Max Neunhoeffer
**  This file is free software, see license information at the end.
**
**  Exported to the GAPData package by Markus Pfeiffer 2014
*/

#include <stdlib.h>
#include <stdint.h>

#include "src/compiled.h"          /* GAP headers                */
#include "avltree.h"

#undef PACKAGE
#undef PACKAGE_BUGREPORT
#undef PACKAGE_NAME
#undef PACKAGE_STRING
#undef PACKAGE_TARNAME
#undef PACKAGE_URL
#undef PACKAGE_VERSION

#include "pkgconfig.h"             /* our own configure results */

/* Note that SIZEOF_VOID_P comes from GAP's config.h whereas
 * SIZEOF_VOID_PP comes from pkgconfig.h! */
#if SIZEOF_VOID_PP != SIZEOF_VOID_P
#error GAPs word size is different from ours, 64bit/32bit mismatch
#endif

#include <avltree.h>

Obj HTGrow;         /* Operation function imported from the library */

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

static inline void initRNams(void)
{
    /* Find RNams if not already done: */
    if (!RNam_accesses) {
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
    }
}

Obj HTAdd_TreeHash_C(Obj self, Obj ht, Obj x, Obj v)
{
    Obj els;
    Obj vals;
    Obj tmp;
    Obj hfd;
    Int h;
    Obj t;
    Obj r;

    /* Find RNams if not already done: */
    initRNams();

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

    /* Now check whether it is an AVLTree or not: */
    if (TNUM_OBJ(tmp) != T_POSOBJ ||
        (TYPE_POSOBJ(tmp) != AVLTreeTypeMutable &&
         TYPE_POSOBJ(tmp) != AVLTreeType)) {
        r = NEW_PREC(2);   /* This might trigger a garbage collection */
        AssPRec(r,RNam_cmpfunc,ElmPRec(ht,RNam_cmpfunc));
        AssPRec(r,RNam_allocsize,INTOBJ_INT(3));
        t = CALL_1ARGS(AVLTree,r);
        if (LEN_PLIST(vals) >= h && ELM_PLIST(vals,h) != 0L) {
            AVLAdd_C(self,t,tmp,ELM_PLIST(vals,h));
            UNB_LIST(vals,h);
        } else {
            AVLAdd_C(self,t,tmp,True);
        }
        SET_ELM_PLIST(els,h,t);
        CHANGED_BAG(els);
    } else t = tmp;

    /* Finally add value into tree: */
    if (v != True) {
        r = AVLAdd_C(self,t,x,v);
    } else {
        r = AVLAdd_C(self,t,x,True);
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

    /* Find RNams if not already done: */
    initRNams();

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

    /* Now check whether it is an AVLTree or not: */
    if (TNUM_OBJ(t) != T_POSOBJ ||
        (TYPE_POSOBJ(t) != AVLTreeType &&
         TYPE_POSOBJ(t) != AVLTreeTypeMutable)) {
        if (CALL_2ARGS(ElmPRec(ht,RNam_cmpfunc),x,t) == INTOBJ_INT(0)) {
            if (LEN_PLIST(vals) >= h && ELM_PLIST(vals,h) != 0L)
                return ELM_PLIST(vals,h);
            else
                return True;
        }
        return Fail;
    }

    h = AVLFind(t,x);
    if (h == 0) return Fail;
    return AVLValue(t,h);
}

Obj HTDelete_TreeHash_C(Obj self, Obj ht, Obj x)
{
    Obj els;
    Obj vals;
    Obj hfd;
    Int h;
    Obj t;
    Obj v;

    /* Find RNams if not already done: */
    initRNams();

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

    /* Now check whether it is an AVLTree or not: */
    if (TNUM_OBJ(t) != T_POSOBJ ||
        (TYPE_POSOBJ(t) != AVLTreeType &&
         TYPE_POSOBJ(t) != AVLTreeTypeMutable)) {
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

    v = AVLDelete_C(self,t,x);
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

    /* Find RNams if not already done: */
    initRNams();

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

    /* Now check whether it is an AVLTree or not: */
    if (TNUM_OBJ(t) != T_POSOBJ ||
        (TYPE_POSOBJ(t) != AVLTreeType &&
         TYPE_POSOBJ(t) != AVLTreeTypeMutable)) {
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

    h = AVLFind(t,x);
    if (h == 0) return Fail;
    old = AVLValue(t,h);
    SetAVLValue(t,h,v);
    return old;
}


/*
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; version 2 of the License.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program; if not, write to the Free Software
 *  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 *
 */


