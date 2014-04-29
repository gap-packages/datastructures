/***************************************************************************
**
*A  misc.c               GAPData-package               Markus Pfeiffer
**
**  Copyright (C) 2014  Markus Pfeiffer
**  This file is free software, see license information at the end.
**
**  This code is mostly factored from orb.c of the orb package.
*/

#include <stdlib.h>

#include "src/compiled.h"          /* GAP headers                */
#include "hashtable.h"
#include "misc.h"

Obj FuncPermList(Obj self, Obj list);

Obj FuncPermLeftQuoTransformationNC(Obj self, Obj t1, Obj t2)
{
    Obj l1, l2;
    Int deg;
    Obj pl;
    Int i;
    Int x;

    /* Get the plain lists out: */
    if (IS_POSOBJ(t1)) l1 = ELM_PLIST(t1,1);
    else l1 = t1;
    if (IS_POSOBJ(t2)) l2 = ELM_PLIST(t2,1);
    else l2 = t2;
    deg = LEN_LIST(l1);
    pl = NEW_PLIST(T_PLIST_CYC,deg);
    SET_LEN_PLIST(pl,deg);
    /* From now on no more garbage collections! */
    for (i = 1;i <= deg;i++) {
        x = INT_INTOBJ(ELM_LIST(l1,i));
        if (ELM_PLIST(pl,x) == NULL) {
            SET_ELM_PLIST(pl,x,ELM_LIST(l2,i));
        }
    }
    for (i = 1;i <= deg;i++) {
        if (ELM_PLIST(pl,i) == NULL) {
            SET_ELM_PLIST(pl,i,INTOBJ_INT(i));
        }
    }
    return FuncPermList(self,pl);
}

Obj FuncMappingPermSetSet(Obj self, Obj src, Obj dst)
{
    Int l;
    Int d,dd;
    Obj out;
    Int i = 1;
    Int j = 1;
    Int next = 1;  /* The next candidate, possibly prevented by being in dst */
    Int k;

    l = LEN_LIST(src);
    if (l != LEN_LIST(dst)) {
        ErrorReturnVoid( "both arguments must be sets of equal length", 
                     0L, 0L, "type 'return;' or 'quit;' to exit break loop" );
        return 0L;
    }
    d = INT_INTOBJ(ELM_LIST(src,l));
    dd = INT_INTOBJ(ELM_LIST(dst,l));
    if (dd > d) d = dd;

    out = NEW_PLIST(T_PLIST_CYC,d);
    SET_LEN_PLIST(out,d);
    /* No garbage collection from here on! */

    for (k = 1;k <= d;k++) {
        if (i <= l && k == INT_INTOBJ(ELM_LIST(src,i))) {
            SET_ELM_PLIST(out,k,ELM_LIST(dst,i));
            i++;
        } else {
            /* Skip things in dst: */
            while (j <= l) {
                dd = INT_INTOBJ(ELM_LIST(dst,j));
                if (next < dd) break;
                if (next == dd) next++;
                j++;
            }
            SET_ELM_PLIST(out,k,INTOBJ_INT(next));
            next++;
        }
    }
    return FuncPermList(self,out);
} 
 
#define DEGREELIMITONSTACK 512

Obj FuncMappingPermListList(Obj self, Obj src, Obj dst)
{
    Int l;
    Int i;
    Int d;
    Int next;
    Obj out;
    Obj tabdst, tabsrc;
    Int x;
    Int mytabs[DEGREELIMITONSTACK];
    Int mytabd[DEGREELIMITONSTACK];

    l = LEN_LIST(src);
    if (l != LEN_LIST(dst)) {
        ErrorReturnVoid( "both arguments must be lists of equal length", 
                     0L, 0L, "type 'return;' or 'quit;' to exit break loop" );
        return 0L;
    }
    d = 0;
    for (i = 1;i <= l;i++) {
        x = INT_INTOBJ(ELM_LIST(src,i));
        if (x > d) d = x;
    }
    for (i = 1;i <= l;i++) {
        x = INT_INTOBJ(ELM_LIST(dst,i));
        if (x > d) d = x;
    }
    if (d <= DEGREELIMITONSTACK) {
        /* Small case where we work on the stack: */
        memset(&mytabs,0,sizeof(mytabs));
        memset(&mytabd,0,sizeof(mytabd));
        for (i = 1;i <= l;i++) {
            mytabs[INT_INTOBJ(ELM_LIST(src,i))] = i;
        }
        for (i = 1;i <= l;i++) {
            mytabd[INT_INTOBJ(ELM_LIST(dst,i))] = i;
        }
        out = NEW_PLIST(T_PLIST_CYC,d);
        SET_LEN_PLIST(out,d);
        /* No garbage collection from here ... */
        next = 1;
        for (i = 1;i <= d;i++) {
            if (mytabs[i]) {   /* if i is in src */
                SET_ELM_PLIST(out,i, ELM_LIST(dst,mytabs[i]));
            } else {
                /* Skip things in dst: */
                while (mytabd[next]) next++;
                SET_ELM_PLIST(out,i,INTOBJ_INT(next));
                next++;
            }
        }
        /* ... to here! No CHANGED_BAG needed since this is a new object! */
    } else {
        /* Version with intermediate objects: */

        tabsrc = NEW_PLIST(T_PLIST,d);
        SET_LEN_PLIST(tabsrc,0);
        /* No garbage collection from here ... */
        for (i = 1;i <= l;i++) {
            SET_ELM_PLIST(tabsrc,INT_INTOBJ(ELM_LIST(src,i)),INTOBJ_INT(i));
        }
        /* ... to here! No CHANGED_BAG needed since this is a new object! */
        tabdst = NEW_PLIST(T_PLIST,d);
        SET_LEN_PLIST(tabdst,0);
        /* No garbage collection from here ... */
        for (i = 1;i <= l;i++) {
            SET_ELM_PLIST(tabdst,INT_INTOBJ(ELM_LIST(dst,i)),INTOBJ_INT(i));
        }
        /* ... to here! No CHANGED_BAG needed since this is a new object! */
        out = NEW_PLIST(T_PLIST_CYC,d);
        SET_LEN_PLIST(out,d);
        /* No garbage collection from here ... */
        next = 1;
        for (i = 1;i <= d;i++) {
            if (ELM_PLIST(tabsrc,i)) {   /* if i is in src */
                SET_ELM_PLIST(out,i,
                    ELM_LIST(dst,INT_INTOBJ(ELM_PLIST(tabsrc,i))));
            } else {
                /* Skip things in dst: */
                while (ELM_PLIST(tabdst,next)) next++;
                SET_ELM_PLIST(out,i,INTOBJ_INT(next));
                next++;
            }
        }
        /* ... to here! No CHANGED_BAG needed since this is a new object! */
    }
    return FuncPermList(self,out);
}

#if 0
/* The version below has better complexity and is only slightly slower
 * for very small transformations. */
Obj FuncImageAndKernelOfTransformation2( Obj self, Obj t )
{
    Int bufstack[DEGREELIMITONSTACK+1];
    Obj bufgap;
    Int *buf;
    Int comps;
    Int i;
    Obj image;
    Int j;
    Obj kernel;
    Obj l;
    Int n;
    Obj tmp;

    l = ELM_PLIST(t,1);
    n = LEN_LIST(l);
    if (n <= DEGREELIMITONSTACK) {
        buf = bufstack;
        for (i = 1;i <= n;i++) buf[i] = 0;
        bufgap = 0L;   /* Just to please the compiler */
    } else{
        bufgap = NEW_PLIST(T_PLIST,n);   /* Only used internally */
        buf = (Int *) (ADDR_OBJ(bufgap));
    }
    /* No garbage collection from here... */
    comps = 0;
    for (j = 1;j <= n;j++) {
        i = INT_INTOBJ(ELM_LIST(l,j));
        if (!buf[i]) comps++;
        buf[i]++;
    }
    /* ...until here. No there could be some, buf might be wrong then! */
    kernel = NEW_PLIST(T_PLIST,comps);
    image = NEW_PLIST(T_PLIST,comps);
    buf = (n <= DEGREELIMITONSTACK) ? bufstack : (Int *) ADDR_OBJ(bufgap);
    j = 1;
    for (i = 1;i <= n;i++) {
        if (buf[i]) {
            SET_ELM_PLIST(image,j,INTOBJ_INT(i));
            SET_LEN_PLIST(image,j);
            tmp = NEW_PLIST(T_PLIST,buf[i]);
            buf = (n <= DEGREELIMITONSTACK) ? bufstack 
                                            : (Int *) ADDR_OBJ(bufgap);
            SET_ELM_PLIST(kernel,j,tmp);
            SET_LEN_PLIST(kernel,j);
            CHANGED_BAG(kernel);
            buf[i] = j++;
        }
    }
    for (i = 1;i <= n;i++) {
        tmp = ELM_PLIST(kernel,buf[INT_INTOBJ(ELM_LIST(l,i))]);
        j = LEN_PLIST(tmp);
        SET_ELM_PLIST(tmp,j+1,INTOBJ_INT(i));
        SET_LEN_PLIST(tmp,j+1);
    }
    /* Now sort it: */
    SortDensePlist(kernel);

    tmp = NEW_PLIST(T_PLIST,2);
    SET_LEN_PLIST(tmp,2);
    SET_ELM_PLIST(tmp,1,image);
    SET_ELM_PLIST(tmp,2,kernel);
    return tmp;
}
#endif

Obj FuncImageAndKernelOfTransformation( Obj self, Obj t )
{
    Int bufstack[DEGREELIMITONSTACK+1];
    Obj bufgap;
    Int *buf;
    Int comps;
    Int i;
    Obj image;
    Int j;
    Int k;
    Obj kernel;
    Obj l;
    Int n;
    Obj tmp;

    if (IS_POSOBJ(t)) l = ELM_PLIST(t,1);
    else l = t;
    n = LEN_LIST(l);
    kernel = NEW_PLIST(T_PLIST,n);   /* Will hold result */
    SET_LEN_PLIST(kernel,n);
    if (n <= DEGREELIMITONSTACK) {
        buf = bufstack;
        for (i = 1;i <= n;i++) buf[i] = 0;
        bufgap = 0L;   /* Just to please the compiler */
    } else{
        bufgap = NewBag(T_DATOBJ,sizeof(Int)*(n+1));/* Only used internally */
        buf = (Int *) (ADDR_OBJ(bufgap));
    }
    
    comps = 0;
    for (i = 1;i <= n;i++) {
        j = INT_INTOBJ(ELM_LIST(l,i));
        if (buf[j] == 0) {
            comps++;
            tmp = NEW_PLIST(T_PLIST,1);
            if (n > DEGREELIMITONSTACK) buf = (Int *) ADDR_OBJ(bufgap);
            SET_LEN_PLIST(tmp,1);
            SET_ELM_PLIST(tmp,1,INTOBJ_INT(i));
            SET_ELM_PLIST(kernel,i,tmp);
            CHANGED_BAG(kernel);
            buf[j] = i;
        } else {
            tmp = ELM_PLIST(kernel,buf[j]);
            k = LEN_PLIST(tmp);
            GROW_PLIST(tmp,k+1);
            if (n > DEGREELIMITONSTACK) buf = (Int *) ADDR_OBJ(bufgap);
            SET_ELM_PLIST(tmp,k+1,INTOBJ_INT(i));
            SET_LEN_PLIST(tmp,k+1);
        }
    }
    image = NEW_PLIST(T_PLIST,comps);
    if (n > DEGREELIMITONSTACK) buf = (Int *) ADDR_OBJ(bufgap);
    SET_LEN_PLIST(image,comps);
    /* No garbage collection from here on ... */
    k = 1;
    for (j = 1;j <= n;j++) {
        i = buf[j];
        if (i) {
            SET_ELM_PLIST(image,k++,INTOBJ_INT(j));
        }
    }
    /* ... until here. We do not need buf any more from here on. */

    /* Now compactify kernel: */
    j = 1;
    for (i = 1;i <= n;i++) {
        tmp = ELM_PLIST(kernel,i);
        if (tmp) SET_ELM_PLIST(kernel,j++,tmp);
    }
    SET_LEN_PLIST(kernel,comps);
    SHRINK_PLIST(kernel,comps);

    tmp = NEW_PLIST(T_PLIST,2);
    SET_LEN_PLIST(tmp,2);
    SET_ELM_PLIST(tmp,1,image);
    SET_ELM_PLIST(tmp,2,kernel);
    MakeImmutable(tmp);
    return tmp;
}

Obj FuncTABLE_OF_TRANS_KERNEL( Obj self, Obj k, Obj n )
{
    /* k is list of plain lists, such that exactly the numbers [1..n]
     * occur once each (like for example the kernel of a
     * transformation on [1..n]). This function returns a plain list of
     * length n containing in position i the number of list in which i
     * lies. */
    Obj res;
    Obj tmp;
    Int i,j;
    Int l1,l2;
    Int nn;
    nn = INT_INTOBJ(n);
    res = NEW_PLIST(T_PLIST_CYC, nn);
    l1 = LEN_PLIST(k);
    for (i = 1;i <= l1;i++) {
        tmp = ELM_PLIST(k,i);
        l2 = LEN_PLIST(tmp);
        for (j = 1;j <= l2;j++) {
            SET_ELM_PLIST(res,INT_INTOBJ(ELM_PLIST(tmp,j)),INTOBJ_INT(i));
        }
    }
    SET_LEN_PLIST(res,nn);
    return res;
}

Obj FuncCANONICAL_TRANS_SAME_KERNEL( Obj self, Obj t )
{
    /* t is either a transformation or a plain list of integers
     * representing the image list of the transformation.
     * This computes the image list of a canonical transformation
     * with the same kernel. */
    Obj tab,l,res;
    Int i,j,n,next;

    if (IS_POSOBJ(t)) l = ELM_PLIST(t,1);
    else l = t;
    n = LEN_LIST(l);
    tab = NEW_PLIST(T_PLIST_CYC,n);
    SET_LEN_PLIST(tab,0);
    res = NEW_PLIST(T_PLIST_CYC,n);
    SET_LEN_PLIST(res,n);
    /* no garbage collection from here */
    next = 1;
    for (i = 1;i <= n;i++) {
        j = INT_INTOBJ(ELM_LIST(l,i));
        if (ELM_PLIST(tab,j) != 0) {
            SET_ELM_PLIST(res,i,ELM_PLIST(tab,j));
        } else {
            SET_ELM_PLIST(tab,j,INTOBJ_INT(next));
            SET_ELM_PLIST(res,i,INTOBJ_INT(next));
            next++;
        }
    }
    /* finished */
    return res;
}

Obj FuncIS_INJECTIVE_TRANS_ON_LIST( Obj self, Obj t, Obj l )
{
    /* t is either a transformation or a plain list of integers of
     * length n representing the image list of the transformation.
     * l is a list containing positive integers between 1 and n.
     * Returns true if and only if t takes different values on 
     * all elements in l. */
    Obj tab,tt;
    Int i,j,n;

    if (IS_POSOBJ(t)) tt = ELM_PLIST(t,1);
    else tt = t;
    n = LEN_LIST(tt);
    tab = NEW_PLIST(T_PLIST_CYC,n);
    SET_LEN_PLIST(tab,0);
    /* no garbage collection from here! */
    for (i = 1;i <= LEN_LIST(l);i++) {
        j = INT_INTOBJ(ELM_LIST(tt,INT_INTOBJ(ELM_LIST(l,i))));
        if (ELM_PLIST(tab,j) != 0) {
            return False;
        } else {
            SET_ELM_PLIST(tab,j,INTOBJ_INT(1));
        }
    }
    /* finished */
    return True;
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



