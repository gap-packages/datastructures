/*
 * Datastructures: GAP package providing common datastructures.
 * Licensed under the GPL 2 or later.
 *
 * This file contains an DS_AVL tree implementation,
 *  Copyright (C) 2009-2013  Max Neunhoeffer
 */

#include "avltree.h"

/* This file corresponds to orb/gap/avltree.gi, it imlements some of
 * its functionality on the C level for better performance. */

Obj DS_AVLTreeType;    /* Imported from the library to be able to check type */
Obj DS_AVLTreeTypeMutable;
                    /* Imported from the library to be able to check type */
Obj DS_AVLTree;        /* Constructor function imported from the library */

/* Conventions:
 *
 * A balanced binary tree (DS_AVLTree) is a positional object having the
 * following entries:
 *   ![1]     len: last used entry, never shrinks), always = 3 mod 4
 *   ![2]     free: index of first freed entry, if 0, none free
 *   ![3]     nodes: number of nodes currently in the tree
 *   ![4]     alloc: highest allocated index, always = 3 mod 4
 *   ![5]     three-way comparison function
 *   ![6]     top: reference to top node
 *   ![7]     vals: stored values
 *
 * From index 8 on for every position = 0 mod 4:
 *   ![4n]    obj: an object
 *   ![4n+1]  left: left reference or < 8 (elements there are smaller)
 *   ![4n+2]  right: right reference or < 8 (elements there are bigger)
 *   ![4n+3]  rank: number of nodes in left subtree plus one
 * For freed nodes position ![4n] holds the link to the next one
 * For used nodes references are divisible by four, therefore
 * the mod 4 value can be used for other information.
 * We use left mod 4: 0 - balanced
 *                    1 - balance factor +1
 *                    2 - balance factor -1     */

/* Note that we have to check the arguments for functions that are called
 * by user programs since we do not go through method selection! */

Obj DS_AVLCmp_C(Obj self, Obj a, Obj b)
/* A very fast three-way comparison function. */
{
    if (EQ(a,b)) return INTOBJ_INT(0);
    else if (LT(a,b)) return INTOBJ_INT(-1);
    else return INTOBJ_INT(1);
}

/* The following are some internal macros to make the code more readable.
 * We always know that these positions are properly initialized! */

/* Last used entry, never shrinks, always = 3 mod 4: */
#define DS_AVLLen(t) INT_INTOBJ(ELM_PLIST(t,1))
#define SetDS_AVLLen(t,i) SET_ELM_PLIST(t,1,INTOBJ_INT(i))
/* Index of first freed entry, if 0, none free: */
#define DS_AVLFree(t) INT_INTOBJ(ELM_PLIST(t,2))
#define DS_AVLFreeObj(t) ELM_PLIST(t,2)
#define SetDS_AVLFree(t,i) SET_ELM_PLIST(t,2,INTOBJ_INT(i))
#define SetDS_AVLFreeObj(t,i) SET_ELM_PLIST(t,2,i)
/* Number of nodes currently in the tree: */
#define DS_AVLNodes(t) INT_INTOBJ(ELM_PLIST(t,3))
#define SetDS_AVLNodes(t,i) SET_ELM_PLIST(t,3,INTOBJ_INT(i))
/* Highest allocated index, always = 3 mod 4: */
#define DS_AVLAlloc(t) INT_INTOBJ(ELM_PLIST(t,4))
#define SetDS_AVLAlloc(t,i) SET_ELM_PLIST(t,4,INTOBJ_INT(i))
/* Three-way-comparison function: */
#define DS_AVL3Comp(t) ELM_PLIST(t,5)
#define SetDS_AVL3Comp(t,f) SET_ELM_PLIST(t,5,f);CHANGED_BAG(t)
/* Reference to the top node: */
#define DS_AVLTop(t) INT_INTOBJ(ELM_PLIST(t,6))
#define SetDS_AVLTop(t,i) SET_ELM_PLIST(t,6,INTOBJ_INT(i))
/* Reference to the value plist: */
#define DS_AVLValues(t) ELM_PLIST(t,7)
#define SetDS_AVLValues(t,l) SET_ELM_PLIST(t,7,l);CHANGED_BAG(t)

#define DS_AVLmask ((unsigned long)(3L))
#define DS_AVLmask2 ((unsigned long)(-4L))
/* Use the following only if you know that the tree object is long enough and
 * something is bound to position i! */
#define DS_AVLData(t,i) ELM_PLIST(t,i)
#define SetDS_AVLData(t,i,d) SET_ELM_PLIST(t,i,d); CHANGED_BAG(t)
#define DS_AVLLeft(t,i) (INT_INTOBJ(ELM_PLIST(t,i+1)) & DS_AVLmask2)
#define SetDS_AVLLeft(t,i,n) SET_ELM_PLIST(t,i+1, \
  INTOBJ_INT( (INT_INTOBJ(ELM_PLIST(t,i+1)) & DS_AVLmask) + n ))
#define DS_AVLRight(t,i) INT_INTOBJ(ELM_PLIST(t,i+2))
#define SetDS_AVLRight(t,i,n) SET_ELM_PLIST(t,i+2,INTOBJ_INT(n))
#define DS_AVLRank(t,i) INT_INTOBJ(ELM_PLIST(t,i+3))
#define SetDS_AVLRank(t,i,r) SET_ELM_PLIST(t,i+3,INTOBJ_INT(r))
#define DS_AVLBalFactor(t,i) (INT_INTOBJ(ELM_PLIST(t,i+1)) & DS_AVLmask)
#define SetDS_AVLBalFactor(t,i,b) SET_ELM_PLIST(t,i+1, \
  INTOBJ_INT( (INT_INTOBJ(ELM_PLIST(t,i+1)) & DS_AVLmask2) + b ))

Int DS_AVLNewNode( Obj t )
{
    Int n,a;
    n = DS_AVLFree(t);
    if (n > 0) {
        SetDS_AVLFreeObj(t,ELM_PLIST(t,n));
    } else {
        n = DS_AVLLen(t);
        a = DS_AVLAlloc(t);
        if (n < a) {
            /* There is already enough allocated! */
            SetDS_AVLLen(t,n+4);
            n++;
        } else {
            /* We have to allocate new space! */
            n++;
            a = a*2 + 1;   /* Retain congruent 3 mod 4 */
            SetDS_AVLAlloc(t,a);
            ResizeBag(t,(a+1)*sizeof(Obj));
            SetDS_AVLLen(t,n+3);
        }
    }
    SET_ELM_PLIST(t,n,INTOBJ_INT(0));
    SET_ELM_PLIST(t,n+1,INTOBJ_INT(0));
    SET_ELM_PLIST(t,n+2,INTOBJ_INT(0));
    SET_ELM_PLIST(t,n+3,INTOBJ_INT(0));
    return n;
}

Obj DS_AVLNewNode_C( Obj self, Obj t )
{
    if ( TNUM_OBJ(t) != T_POSOBJ || TYPE_POSOBJ(t) != DS_AVLTreeTypeMutable) {
        ErrorQuit( "Usage: DS_AVLNewNode(avltree)", 0L, 0L );
        return 0L;
    }
    return INTOBJ_INT(DS_AVLNewNode(t));
}

 Obj DS_AVLFreeNode( Obj t, Int n )
{
    Obj v,o;
    SET_ELM_PLIST(t,n,DS_AVLFreeObj(t));
    SetDS_AVLFree(t,n);
    n /= 4;
    v = DS_AVLValues(t);
    if (v != Fail && ISB_LIST(v,n)) {
        o = ELM_PLIST(v,n);
        UNB_LIST(v,n);
        return o;
    }
    return True;
}

Obj DS_AVLFreeNode_C( Obj self, Obj t, Obj n)
{
    if (!IS_INTOBJ(n) ||
        TNUM_OBJ(t) != T_POSOBJ || TYPE_POSOBJ(t) != DS_AVLTreeTypeMutable) {
        ErrorQuit( "Usage: DS_AVLFreeNode(avltree,integer)", 0L, 0L );
        return 0L;
    }
    return DS_AVLFreeNode(t,INT_INTOBJ(n));
}

Obj DS_AVLValue( Obj t, Int n )
{
    Obj vals = DS_AVLValues(t);
    if (vals == Fail) return True;
    n /= 4;
    if (!ISB_LIST(vals,n)) return True;
    return ELM_LIST(vals,n);
}

void SetDS_AVLValue( Obj t, Int n, Obj v )
{
    Obj vals = DS_AVLValues(t);
    n /= 4;
    if (vals == Fail || !IS_LIST(vals)) {
        vals = NEW_PLIST(T_PLIST, n);
        SetDS_AVLValues(t,vals);
    }
    ASS_LIST(vals,n,v);
}

Int DS_AVLFind( Obj t, Obj d )
{
    Obj compare,c;
    Int p;

    compare = DS_AVL3Comp(t);
    p = DS_AVLTop(t);
    while (p >= 8) {
        c = CALL_2ARGS(compare,d,DS_AVLData(t,p));
        if (c == INTOBJ_INT(0))
            return p;
        else if (INT_INTOBJ(c) < 0)   /* d < DS_AVLData(t,p) */
            p = DS_AVLLeft(t,p);
        else                          /* d > DS_AVLData(t,p) */
            p = DS_AVLRight(t,p);
    }
    return 0;
}

 Obj DS_AVLFind_C( Obj self, Obj t, Obj d )
{
    Int tmp;
    if (TNUM_OBJ(t) != T_POSOBJ ||
        (TYPE_POSOBJ(t) != DS_AVLTreeType &&
         TYPE_POSOBJ(t) != DS_AVLTreeTypeMutable)) {
        ErrorQuit( "Usage: DS_AVLFind(avltree, object)", 0L, 0L );
        return 0L;
    }
    tmp = DS_AVLFind(t,d);
    if (tmp == 0)
        return Fail;
    else
        return INTOBJ_INT(tmp);
}

 Int DS_AVLFindIndex( Obj t, Obj d )
{
    Obj compare,c;
    Int p;
    Int offset;

    compare = DS_AVL3Comp(t);
    p = DS_AVLTop(t);
    offset = 0;
    while (p >= 8) {
        c = CALL_2ARGS(compare,d,DS_AVLData(t,p));
        if (c == INTOBJ_INT(0))
            return offset + DS_AVLRank(t,p);
        else if (INT_INTOBJ(c) < 0)   /* d < DS_AVLData(t,p) */
            p = DS_AVLLeft(t,p);
        else {                         /* d > DS_AVLData(t,p) */
            offset += DS_AVLRank(t,p);
            p = DS_AVLRight(t,p);
        }
    }
    return 0;
}

 Obj DS_AVLFindIndex_C( Obj self, Obj t, Obj d )
{
    Int tmp;
    if (TNUM_OBJ(t) != T_POSOBJ ||
        (TYPE_POSOBJ(t) != DS_AVLTreeType &&
         TYPE_POSOBJ(t) != DS_AVLTreeTypeMutable)) {
        ErrorQuit( "Usage: DS_AVLFindIndex(avltree, object)", 0L, 0L );
        return 0L;
    }
    tmp = DS_AVLFindIndex(t,d);
    if (tmp == 0)
        return Fail;
    else
        return INTOBJ_INT(tmp);
}

 Obj DS_AVLLookup_C( Obj self, Obj t, Obj d )
{
    Int p;
    if (TNUM_OBJ(t) != T_POSOBJ ||
        (TYPE_POSOBJ(t) != DS_AVLTreeType &&
         TYPE_POSOBJ(t) != DS_AVLTreeTypeMutable)) {
        ErrorQuit( "Usage: DS_AVLLookup(avltree, object)", 0L, 0L );
        return 0L;
    }
    p = DS_AVLFind(t,d);
    if (p == 0) return Fail;
    return DS_AVLValue(t,p);
}

 Int DS_AVLIndex( Obj t, Int i )
{
    Int p,offset,r;

    if (i < 1 || i > DS_AVLNodes(t)) return 0;
    p = DS_AVLTop(t);
    offset = 0;
    while (1) {   /* will be left by return */
        r = offset + DS_AVLRank(t,p);
        if (i < r)   /* go left: */
            p = DS_AVLLeft(t,p);
        else if (i == r)   /* found! */
            return p;
        else {    /* go right: */
            offset = r;
            p = DS_AVLRight(t,p);
        }
    }
}

 Obj DS_AVLIndex_C( Obj self, Obj t, Obj i )
{
    Int p;
    if (!IS_INTOBJ(i) ||
        TNUM_OBJ(t) != T_POSOBJ ||
        (TYPE_POSOBJ(t) != DS_AVLTreeType &&
         TYPE_POSOBJ(t) != DS_AVLTreeTypeMutable)) {
        ErrorQuit( "Usage: DS_AVLIndex(avltree, integer)", 0L, 0L );
        return 0L;
    }
    p = DS_AVLIndex( t, INT_INTOBJ(i) );
    if (p == 0)
        return Fail;
    else
        return DS_AVLData(t,p);
}

 Obj DS_AVLIndexFind_C( Obj self, Obj t, Obj i )
{
    Int p;
    if (!IS_INTOBJ(i) ||
        TNUM_OBJ(t) != T_POSOBJ ||
        (TYPE_POSOBJ(t) != DS_AVLTreeType &&
         TYPE_POSOBJ(t) != DS_AVLTreeTypeMutable)) {
        ErrorQuit( "Usage: DS_AVLIndexFind(avltree, integer)", 0L, 0L );
        return 0L;
    }
    p = DS_AVLIndex( t, INT_INTOBJ(i) );
    if (p == 0)
        return Fail;
    else
        return INTOBJ_INT(p);
}

 Obj DS_AVLIndexLookup_C( Obj self, Obj t, Obj i )
{
    Int p;
    Obj vals;
    if (!IS_INTOBJ(i) ||
        TNUM_OBJ(t) != T_POSOBJ ||
        (TYPE_POSOBJ(t) != DS_AVLTreeType &&
         TYPE_POSOBJ(t) != DS_AVLTreeTypeMutable)) {
        ErrorQuit( "Usage: DS_AVLIndexLookup(avltree, integer)", 0L, 0L );
        return 0L;
    }
    p = DS_AVLIndex(t,INT_INTOBJ(i));
    if (p == 0) return Fail;
    vals = DS_AVLValues(t);
    p /= 4;
    if (vals == Fail || !ISB_LIST(vals,p))
        return True;
    else
        return ELM_LIST(vals,p);
}

 void DS_AVLRebalance( Obj tree, Int q, Int *newroot, int *shrink )
/* the tree starting at q has balanced subtrees but is out of balance:
   the depth of the deeper subtree is 2 bigger than the depth of the other
   tree. This function changes this situation following the procedure
   described in Knuth: "The Art of Computer Programming".
   It returns nothing but stores the new start node of the subtree into
   "newroot" and in "shrink" a boolean value which indicates, if the
   depth of the tree was decreased by 1 by this operation. */
{
  Int p, l;

  *shrink = 1;   /* in nearly all cases this happens */
  if (DS_AVLBalFactor(tree,q) == 2)   /* was: < 0 */
      p = DS_AVLLeft(tree,q);
  else
      p = DS_AVLRight(tree,q);
  if (DS_AVLBalFactor(tree,p) == DS_AVLBalFactor(tree,q)) {
      /* we need a single rotation:
             q++             p=           q--          p=
            / \             / \          / \          / \
           a   p+    ==>   q=  c    OR  p-  c   ==>  a   q=
              / \         / \          / \              / \
             b   c       a   b        a   b            b   c      */
      if (DS_AVLBalFactor(tree,q) == 1) {    /* was: > 0 */
          SetDS_AVLRight(tree,q,DS_AVLLeft(tree,p));
          SetDS_AVLLeft(tree,p,q);
          SetDS_AVLBalFactor(tree,q,0);
          SetDS_AVLBalFactor(tree,p,0);
          SetDS_AVLRank(tree,p,DS_AVLRank(tree,p) + DS_AVLRank(tree,q));
      } else {
          SetDS_AVLLeft(tree,q,DS_AVLRight(tree,p));
          SetDS_AVLRight(tree,p,q);
          SetDS_AVLBalFactor(tree,q,0);
          SetDS_AVLBalFactor(tree,p,0);
          SetDS_AVLRank(tree,q,DS_AVLRank(tree,q) - DS_AVLRank(tree,p));
      }
  } else if (DS_AVLBalFactor(tree,p) == 3 - DS_AVLBalFactor(tree,q)) {
              /* was: = - */
       /* we need a double rotation:
             q++                             q--
            / \             c=              / \            c=
           a   p-         /   \            p+  e         /   \
              / \   ==>  q     p    OR    / \      ==>  p     q
             c   e      / \   / \        a   c         / \   / \
            / \        a   b d   e          / \       a   b d   e
           b   d                           b   d                     */
      if (DS_AVLBalFactor(tree,q) == 1) {   /* was: > 0 */
          l = DS_AVLLeft(tree,p);
          SetDS_AVLRight(tree,q,DS_AVLLeft(tree,l));
          SetDS_AVLLeft(tree,p,DS_AVLRight(tree,l));
          SetDS_AVLLeft(tree,l,q);
          SetDS_AVLRight(tree,l,p);
          if (DS_AVLBalFactor(tree,l) == 1) {   /* was: > 0 */
              SetDS_AVLBalFactor(tree,p,0);
              SetDS_AVLBalFactor(tree,q,2);     /* was: -1 */
          } else if (DS_AVLBalFactor(tree,l) == 0) {
              SetDS_AVLBalFactor(tree,p,0);
              SetDS_AVLBalFactor(tree,q,0);
          } else {   /* DS_AVLBalFactor(tree,l) < 0 */
              SetDS_AVLBalFactor(tree,p,1);
              SetDS_AVLBalFactor(tree,q,0);
          }
          SetDS_AVLBalFactor(tree,l,0);
          SetDS_AVLRank(tree,p,DS_AVLRank(tree,p) - DS_AVLRank(tree,l));
          SetDS_AVLRank(tree,l,DS_AVLRank(tree,l) + DS_AVLRank(tree,q));
          p = l;
      } else {
          l = DS_AVLRight(tree,p);
          SetDS_AVLLeft(tree,q,DS_AVLRight(tree,l));
          SetDS_AVLRight(tree,p,DS_AVLLeft(tree,l));
          SetDS_AVLLeft(tree,l,p);
          SetDS_AVLRight(tree,l,q);
          if (DS_AVLBalFactor(tree,l) == 2) {  /* was: < 0 */
              SetDS_AVLBalFactor(tree,p,0);
              SetDS_AVLBalFactor(tree,q,1);
          } else if (DS_AVLBalFactor(tree,l) == 0) {
              SetDS_AVLBalFactor(tree,p,0);
              SetDS_AVLBalFactor(tree,q,0);
          } else {   /* DS_AVLBalFactor(tree,l) > 0 */
              SetDS_AVLBalFactor(tree,p,2);  /* was: -1 */
              SetDS_AVLBalFactor(tree,q,0);
          }
          SetDS_AVLBalFactor(tree,l,0);
          SetDS_AVLRank(tree,l,DS_AVLRank(tree,l) + DS_AVLRank(tree,p));
          SetDS_AVLRank(tree,q,DS_AVLRank(tree,q) - DS_AVLRank(tree,l));
                               /* new value of DS_AVLRank(tree,l)! */
          p = l;
      }
  } else {  /* DS_AVLBalFactor(tree,p) = 0 */
      /* we need a single rotation:
            q++             p-           q--          p+
           / \             / \          / \          / \
          a   p=    ==>   q+  c    OR  p=  c   ==>  a   q-
             / \         / \          / \              / \
            b   c       a   b        a   b            b   c    */
      if (DS_AVLBalFactor(tree,q) == 1) {   /* was: > 0 */
          SetDS_AVLRight(tree,q,DS_AVLLeft(tree,p));
          SetDS_AVLLeft(tree,p,q);
          SetDS_AVLBalFactor(tree,q,1);
          SetDS_AVLBalFactor(tree,p,2);   /* was: -1 */
          SetDS_AVLRank(tree,p,DS_AVLRank(tree,p) + DS_AVLRank(tree,q));
      } else {
          SetDS_AVLLeft(tree,q,DS_AVLRight(tree,p));
          SetDS_AVLRight(tree,p,q);
          SetDS_AVLBalFactor(tree,q,2);  /* was: -1 */
          SetDS_AVLBalFactor(tree,p,1);
          SetDS_AVLRank(tree,q,DS_AVLRank(tree,q) - DS_AVLRank(tree,p));
      }
      *shrink = 0;
  }
  *newroot = p;
}

 Obj DS_AVLRebalance_C( Obj self, Obj tree, Obj q )
{
    Int newroot = 0;
    int shrink;
    Obj tmp;
    DS_AVLRebalance( tree, INT_INTOBJ(q), &newroot, &shrink );
    tmp = NEW_PREC(2);
    AssPRec(tmp,RNamName("newroot"),INTOBJ_INT(newroot));
    AssPRec(tmp,RNamName("shorter"),shrink ? True : False);
    return tmp;
}

 Obj DS_AVLAdd_C( Obj self, Obj tree, Obj data, Obj value )
{
/* Parameters: tree, data, value
    tree is an DS_AVL tree
    data is a data structure defined by the user
    value is the value stored under the key data, if true, nothing is stored
   Tries to add the data as a node in tree. It is an error, if there is
   already a node which is "equal" to data with respect to the comparison
   function. Returns true if everything went well or fail, if an equal
   object is already present. */

  Obj compare;
  Int p, new;
  /* here all steps are recorded: -1:left, +1:right */
  int path[64];   /* Trees will never be deeper than that! */
  Int nodes[64];
  int n;          /* The length of the list nodes */
  Int q;
  Int rankadds[64];
  int rankaddslen;   /* length of list rankadds */
  Int c;
  Int l;
  Int i;
  int shrink;

  if (TNUM_OBJ(tree) != T_POSOBJ || TYPE_POSOBJ(tree) != DS_AVLTreeTypeMutable) {
      ErrorQuit( "Usage: DS_AVLAdd(avltree, object, object)", 0L, 0L );
      return 0L;
  }

  compare = DS_AVL3Comp(tree);
  p = DS_AVLTop(tree);
  if (p == 0) {   /* A new, single node in the tree */
      new = DS_AVLNewNode(tree);
      SetDS_AVLLeft(tree,new,0);
      SetDS_AVLRight(tree,new,0);
      SetDS_AVLBalFactor(tree,new,0);
      SetDS_AVLRank(tree,new,1);
      SetDS_AVLData(tree,new,data);
      if (value != True)
          SetDS_AVLValue(tree,new,value);
      SetDS_AVLNodes(tree,1);
      SetDS_AVLTop(tree,new);
      return True;
  }

  /* let's first find the right position in the tree:
     but: remember the last node on the way with bal. factor <> 0 and the path
          after this node
     and: remember the nodes where the Rank entry is incremented in case we
          find an "equal" element                                           */
  nodes[1] = p;   /* here we store all nodes on our way, nodes[i+1] is reached
                     from nodes[i] by walking one step path[i] */
  n = 1;          /* this is the length of "nodes" */
  q = 0;          /* this is the last node with bal. factor <> 0 */
                  /* index in "nodes" or 0 for no such node */
  rankaddslen = 0;  /* nothing done so far, list of Rank-modified nodes */
  do {
      /* do we have to remember this position? */
      if (DS_AVLBalFactor(tree,p) != 0)
          q = n;       /* forget old last node with balance factor != 0 */

      /* now one step: */
      c = INT_INTOBJ(CALL_2ARGS(compare,data,DS_AVLData(tree,p)));
      if (c == 0) {   /* we did not want this! */
          for (p = 1; p <= rankaddslen; p++) {
            SetDS_AVLRank(tree,p,DS_AVLRank(tree,rankadds[p]) - 1);
          }
          return Fail;    /* tree is unchanged */
      }

      l = p;     /* remember last position */
      if (c < 0) {    /* data < DS_AVLData(tree,p) */
          SetDS_AVLRank(tree,p,DS_AVLRank(tree,p) + 1);
          rankadds[++rankaddslen] = p;
          p = DS_AVLLeft(tree,p);
      } else {        /* data > DS_AVLData(tree,p) */
          p = DS_AVLRight(tree,p);
      }
      path[n] = c > 0 ? 1 : 2;   /* Internal representation! */
      nodes[++n] = p;
  } while (p != 0);
  /* now p is 0 and nodes[n-1] is the node where data must be attached
     the tree must be modified between nodes[q] and nodes[n-1] along path
     Ranks are already done */
  l = nodes[n-1];   /* for easier reference */

  /* a new node: */
  p = DS_AVLNewNode(tree);
  SetDS_AVLLeft(tree,p,0);
  SetDS_AVLRight(tree,p,0);
  SetDS_AVLBalFactor(tree,p,0);
  SetDS_AVLRank(tree,p,1);
  SetDS_AVLData(tree,p,data);
  if (value != True) {
      SetDS_AVLValue(tree,p,value);
  }
  /* insert into tree: */
  if (c < 0) {    /* left */
      SetDS_AVLLeft(tree,l,p);
  } else {
      SetDS_AVLRight(tree,l,p);
  }
  SetDS_AVLNodes(tree,DS_AVLNodes(tree)+1);

  /* modify balance factors between q and l: */
  for (i = q+1;i <= n-1;i++) {
      SetDS_AVLBalFactor(tree,nodes[i],path[i]);
  }

  /* is rebalancing at q necessary? */
  if (q == 0)     /* whole tree has grown one step */
      return True;
  if (DS_AVLBalFactor(tree,nodes[q]) == 3-path[q]) {
      /* the subtree at q has gotten more balanced */
      SetDS_AVLBalFactor(tree,nodes[q],0);
      return True;   /* Success! */
  }

  /* now at last we do have to rebalance at nodes[q] because the tree has
     gotten out of balance: */
  DS_AVLRebalance(tree,nodes[q],&p,&shrink);

  /* finishing touch: link new root of subtree (p) to t: */
  if (q == 1) {    /* q resp. r was First node */
      SetDS_AVLTop(tree,p);
  } else if (path[q-1] == 2) {
      SetDS_AVLLeft(tree,nodes[q-1],p);
  } else {
      SetDS_AVLRight(tree,nodes[q-1],p);
  }

  return True;
}

 Obj DS_AVLIndexAdd_C( Obj self, Obj tree, Obj data, Obj value, Obj ind )
{
/* Parameters: tree, data, value
    tree is an DS_AVL tree
    data is a data structure defined by the user
    value is the value stored under the key data, if true, nothing is stored
    index is the index, where data should be inserted in tree 1 ist at
          first position, NumberOfNodes+1 after the last.
    Tries to add the data as a node in tree. Returns true if everything
    went well or fail, if something went wrong,    */

  Int p, new;
  /* here all steps are recorded: -1:left, +1:right */
  int path[64];   /* Trees will never be deeper than that! */
  Int nodes[64];
  int n;          /* The length of the list nodes */
  Int q;
  Int c;
  Int l;
  Int index;
  Int i;
  Int offset;
  int shrink;

  if (TNUM_OBJ(tree) != T_POSOBJ || TYPE_POSOBJ(tree) != DS_AVLTreeTypeMutable) {
      ErrorQuit( "Usage: DS_AVLAdd(avltree, object, object)", 0L, 0L );
      return 0L;
  }

  index = INT_INTOBJ(ind);
  if (index < 1 || index > DS_AVLNodes(tree)+1) return Fail;

  p = DS_AVLTop(tree);
  if (p == 0) {   /* A new, single node in the tree */
      new = DS_AVLNewNode(tree);
      SetDS_AVLLeft(tree,new,0);
      SetDS_AVLRight(tree,new,0);
      SetDS_AVLBalFactor(tree,new,0);
      SetDS_AVLRank(tree,new,1);
      SetDS_AVLData(tree,new,data);
      if (value != True)
          SetDS_AVLValue(tree,new,value);
      SetDS_AVLNodes(tree,1);
      SetDS_AVLTop(tree,new);
      return True;
  }

  /* let's first find the right position in the tree:
     but: remember the last node on the way with bal. factor <> 0 and the path
          after this node
     and: remember the nodes where the Rank entry is incremented in case we
          find an "equal" element                                           */
  nodes[1] = p;   /* here we store all nodes on our way, nodes[i+1] is reached
                     from nodes[i] by walking one step path[i] */
  n = 1;          /* this is the length of "nodes" */
  q = 0;          /* this is the last node with bal. factor <> 0 */
                  /* index in "nodes" or 0 for no such node */
  offset = 0;   /* number of nodes with smaller index than those in subtree */

  do {
      /* do we have to remember this position? */
      if (DS_AVLBalFactor(tree,p) != 0)
          q = n;       /* forget old last node with balance factor != 0 */

      /* now one step: */
      if (index <= offset+DS_AVLRank(tree,p))
          c = -1;
      else
          c = +1;

      l = p;     /* remember last position */
      if (c < 0) {    /* data < DS_AVLData(tree,p) */
          SetDS_AVLRank(tree,p,DS_AVLRank(tree,p) + 1);
          p = DS_AVLLeft(tree,p);
      } else {        /* data > DS_AVLData(tree,p) */
          offset += DS_AVLRank(tree,p);
          p = DS_AVLRight(tree,p);
      }
      path[n] = c > 0 ? 1 : 2;   /* Internal representation! */
      nodes[++n] = p;
  } while (p != 0);
  /* now p is 0 and nodes[n-1] is the node where data must be attached
     the tree must be modified between nodes[q] and nodes[n-1] along path
     Ranks are already done */
  l = nodes[n-1];   /* for easier reference */

  /* a new node: */
  p = DS_AVLNewNode(tree);
  SetDS_AVLLeft(tree,p,0);
  SetDS_AVLRight(tree,p,0);
  SetDS_AVLBalFactor(tree,p,0);
  SetDS_AVLRank(tree,p,1);
  SetDS_AVLData(tree,p,data);
  if (value != True) {
      SetDS_AVLValue(tree,p,value);
  }
  /* insert into tree: */
  if (c < 0) {    /* left */
      SetDS_AVLLeft(tree,l,p);
  } else {
      SetDS_AVLRight(tree,l,p);
  }
  SetDS_AVLNodes(tree,DS_AVLNodes(tree)+1);

  /* modify balance factors between q and l: */
  for (i = q+1;i <= n-1;i++) {
      SetDS_AVLBalFactor(tree,nodes[i],path[i]);
  }

  /* is rebalancing at q necessary? */
  if (q == 0)     /* whole tree has grown one step */
      return True;
  if (DS_AVLBalFactor(tree,nodes[q]) == 3-path[q]) {
      /* the subtree at q has gotten more balanced */
      SetDS_AVLBalFactor(tree,nodes[q],0);
      return True;   /* Success! */
  }

  /* now at last we do have to rebalance at nodes[q] because the tree has
     gotten out of balance: */
  DS_AVLRebalance(tree,nodes[q],&p,&shrink);

  /* finishing touch: link new root of subtree (p) to t: */
  if (q == 1) {    /* q resp. r was First node */
      SetDS_AVLTop(tree,p);
  } else if (path[q-1] == 2) {
      SetDS_AVLLeft(tree,nodes[q-1],p);
  } else {
      SetDS_AVLRight(tree,nodes[q-1],p);
  }

  return True;
}

 Obj DS_AVLDelete_C( Obj self, Obj tree, Obj data)
  /* Parameters: tree, data
      tree is an DS_AVL tree
      data is a data structure defined by the user
     Tries to find data as a node in the tree. If found, this node is deleted
     and the tree rebalanced. It is an error, of the node is not found.
     Returns fail in this case, and true normally.       */
{
  Obj compare;
  Int p;
  int path[64];   /* Trees will never be deeper than that! */
  Int nodes[64];
  int n;
  int c;
  int m,i;
  Int r,l;
  Int ranksubs[64];
  int ranksubslen;    /* length of list randsubs */
  Obj old;

  if (TNUM_OBJ(tree) != T_POSOBJ || TYPE_POSOBJ(tree) != DS_AVLTreeTypeMutable) {
      ErrorQuit( "Usage: DS_AVLDelete(avltree, object)", 0L, 0L );
      return Fail;
  }

  compare = DS_AVL3Comp(tree);
  p = DS_AVLTop(tree);
  if (p == 0)     /* Nothing to delete or find */
      return Fail;

  if (DS_AVLNodes(tree) == 1) {
      if (INT_INTOBJ(CALL_2ARGS(compare,data,DS_AVLData(tree,p))) == 0) {
          SetDS_AVLNodes(tree,0);
          SetDS_AVLTop(tree,0);
          return DS_AVLFreeNode(tree,p);
      } else {
          return Fail;
      }
  }

  /* let's first find the right position in the tree:
     and: remember the nodes where the Rank entry is decremented in case we
          find an "equal" element */
  nodes[1] = p;   /* here we store all nodes on our way, nodes[i+1] is reached
                     from nodes[i] by walking one step path[i] */
  n = 1;
  ranksubslen = 0; /* nothing done so far, list of Rank-modified nodes */

  do {

      /* what is the next step? */
      c = INT_INTOBJ(CALL_2ARGS(compare,data,DS_AVLData(tree,p)));

      if (c != 0) {    /* only if data not found! */
          if (c < 0) {    /* data < DS_AVLData(tree,p) */
              SetDS_AVLRank(tree,p,DS_AVLRank(tree,p) - 1);
              ranksubs[++ranksubslen] = p;
              p = DS_AVLLeft(tree,p);
          } else {        /* data > DS_AVLData(tree,p) */
              p = DS_AVLRight(tree,p);
          }
          path[n] = c > 0 ? 1 : 2;   /* Internal representation! */
          nodes[++n] = p;
      }

      if (p == 0) {
          /* error, we did not find data */
          for (i = 1; i <= ranksubslen; i++) {
              SetDS_AVLRank(tree,ranksubs[i],DS_AVLRank(tree,ranksubs[i]) + 1);
          }
          return Fail;
      }

  } while (c != 0);   /* until we find the right node */
  /* now data is equal to DS_AVLData(tree,p) so this node p must be removed.
     the tree must be modified between DS_AVLTop(tree) and nodes[n] along path
     Ranks are already done up there. */

  /* now we have to search a neighbour, we modify "nodes" and "path" but
   * not n! */
  m = n;
  if (DS_AVLBalFactor(tree,p) == 2) {   /* (was: < 0) search to the left */
      l = DS_AVLLeft(tree,p);   /* must be a node! */
      SetDS_AVLRank(tree,p,DS_AVLRank(tree,p) - 1);
      /* we will delete in left subtree! */
      path[m] = 2;   /* was: -1 */
      nodes[++m] = l;
      while (DS_AVLRight(tree,l) != 0) {
          l = DS_AVLRight(tree,l);
          path[m] = 1;
          nodes[++m] = l;
      }
      c = -1;       /* we got predecessor */
  } else if (DS_AVLBalFactor(tree,p) > 0) {  /* search to the right */
      l = DS_AVLRight(tree,p);      /* must be a node! */
      path[m] = 1;
      nodes[++m] = l;
      while (DS_AVLLeft(tree,l) != 0) {
          SetDS_AVLRank(tree,l,DS_AVLRank(tree,l) - 1);
          /* we will delete in left subtree! */
          l = DS_AVLLeft(tree,l);
          path[m] = 2;  /* was: -1 */
          nodes[++m] = l;
      }
      c = 1;        /* we got successor */
  } else {   /* equal depths */
      if (DS_AVLLeft(tree,p) != 0) {
          l = DS_AVLLeft(tree,p);
          SetDS_AVLRank(tree,p,DS_AVLRank(tree,p) - 1);
          path[m] = 2;   /* was: -1 */
          nodes[++m] = l;
          while (DS_AVLRight(tree,l) != 0) {
              l = DS_AVLRight(tree,l);
              path[m] = 1;
              nodes[++m] = l;
          }
          c = -1;     /* we got predecessor */
      } else {        /* we got an end node */
          l = p;
          c = 0;
      }
  }
  /* l points now to a neighbour, in case c = -1 to the predecessor, in case
     c = 1 to the successor, or to p itself in case c = 0
     "nodes" and "path" is updated, but n could be < m */

  /* Copy Data from l up to p: order is NOT modified */
  SetDS_AVLData(tree,p,DS_AVLData(tree,l));
     /* works for m = n, i.e. if p is end node */

  /* Delete node at l = nodes[m] by modifying nodes[m-1]:
     Note: nodes[m] has maximal one subtree! */
  if (c <= 0)
      r = DS_AVLLeft(tree,l);
  else    /*  c > 0 */
      r = DS_AVLRight(tree,l);

  if (path[m-1] == 2)    /* was: < 0 */
      SetDS_AVLLeft(tree,nodes[m-1],r);
  else
      SetDS_AVLRight(tree,nodes[m-1],r);
  SetDS_AVLNodes(tree,DS_AVLNodes(tree)-1);
  old = DS_AVLFreeNode(tree,l);

  /* modify balance factors:
     the subtree nodes[m-1] has become shorter at its left (resp. right)
     subtree, if path[m-1]=-1 (resp. +1). We have to react according to
     the BalFactor at this node and then up the tree, if the whole subtree
     has shrunk:
     (we decrement m and work until the corresponding subtree has not shrunk) */
  m--;   /* start work HERE */
  while (m >= 1) {
      if (DS_AVLBalFactor(tree,nodes[m]) == 0) {
          SetDS_AVLBalFactor(tree,nodes[m],3-path[m]); /* we made path[m] shorter*/
          return old;
      } else if (DS_AVLBalFactor(tree,nodes[m]) == path[m]) {
          SetDS_AVLBalFactor(tree,nodes[m],0);     /* we made path[m] shorter */
      } else {   /* tree is out of balance */
          int shorter;
          DS_AVLRebalance(tree,nodes[m],&p,&shorter);
          if (m == 1) {
              SetDS_AVLTop(tree,p);
              return old;               /* everything is done */
          } else if (path[m-1] == 2)   /* was: = -1 */
              SetDS_AVLLeft(tree,nodes[m-1],p);
          else
              SetDS_AVLRight(tree,nodes[m-1],p);
          if (!shorter) return old;    /* nothing happens further up */
      }
      m--;
  }
  return old;
}

 Obj DS_AVLIndexDelete_C( Obj self, Obj tree, Obj index)
  /* Parameters: tree, index
      tree is an DS_AVL tree
      index is the index of the element to be deleted, must be between 1 and
          DS_AVLNodes(tree) inclusively
     returns fail if index is out of range, otherwise the deleted key;  */

{
  Int p;
  int path[64];   /* Trees will never be deeper than that! */
  Int nodes[64];
  int n;
  int c;
  Int offset;
  int m;
  Int r,l;
  Int ind;
  Obj x;

  if (TNUM_OBJ(tree) != T_POSOBJ || TYPE_POSOBJ(tree) != DS_AVLTreeTypeMutable) {
      ErrorQuit( "Usage: DS_AVLIndexDelete(avltree, index)", 0L, 0L );
      return 0L;
  }
  if (!IS_INTOBJ(index)) {
      ErrorQuit( "Usage2: DS_AVLIndexDelete(avltree, index)", 0L, 0L );
      return 0L;
  }

  p = DS_AVLTop(tree);
  if (p == 0)     /* Nothing to delete or find */
      return Fail;

  ind = INT_INTOBJ(index);
  if (ind < 1 || ind > DS_AVLNodes(tree))   /* out of range */
      return Fail;

  if (DS_AVLNodes(tree) == 1) {
      x = DS_AVLData(tree,p);
      SetDS_AVLNodes(tree,0);
      SetDS_AVLTop(tree,0);
      DS_AVLFreeNode(tree,p);
      return x;
  }

  /* let's first find the right position in the tree:
     and: remember the nodes where the Rank entry is decremented in case we
          find an "equal" element */
  nodes[1] = p;   /* here we store all nodes on our way, nodes[i+1] is reached
                     from nodes[i] by walking one step path[i] */
  n = 1;
  offset = 0;     /* number of "smaller" nodes than subtree in whole tree */

  do {

      /* what is the next step? */
      if (ind == offset + DS_AVLRank(tree,p)) {
          c = 0;   /* we found our node! */
          x = DS_AVLData(tree,p);
      } else if (ind < offset + DS_AVLRank(tree,p))
          c = -1;  /* we have to go left */
      else
          c = 1;   /* we have to go right */

      if (c != 0) {    /* only if data not found! */
          if (c < 0) {    /* data < DS_AVLData(tree,p) */
              SetDS_AVLRank(tree,p,DS_AVLRank(tree,p) - 1);
              p = DS_AVLLeft(tree,p);
          } else {        /* data > DS_AVLData(tree,p) */
              offset += DS_AVLRank(tree,p);
              p = DS_AVLRight(tree,p);
          }
          path[n] = c > 0 ? 1 : 2;   /* Internal representation! */
          nodes[++n] = p;
      }

  } while (c != 0);   /* until we find the right node */
  /* now index is right, so this node p must be removed.
     the tree must be modified between DS_AVLTop(tree) and nodes[n] along path
     Ranks are already done up there. */

  /* now we have to search a neighbour, we modify "nodes" and "path" but
   * not n! */
  m = n;
  if (DS_AVLBalFactor(tree,p) == 2) {   /* (was: < 0) search to the left */
      l = DS_AVLLeft(tree,p);   /* must be a node! */
      SetDS_AVLRank(tree,p,DS_AVLRank(tree,p) - 1);
      /* we will delete in left subtree! */
      path[m] = 2;   /* was: -1 */
      nodes[++m] = l;
      while (DS_AVLRight(tree,l) != 0) {
          l = DS_AVLRight(tree,l);
          path[m] = 1;
          nodes[++m] = l;
      }
      c = -1;       /* we got predecessor */
  } else if (DS_AVLBalFactor(tree,p) > 0) {  /* search to the right */
      l = DS_AVLRight(tree,p);      /* must be a node! */
      path[m] = 1;
      nodes[++m] = l;
      while (DS_AVLLeft(tree,l) != 0) {
          SetDS_AVLRank(tree,l,DS_AVLRank(tree,l) - 1);
          /* we will delete in left subtree! */
          l = DS_AVLLeft(tree,l);
          path[m] = 2;  /* was: -1 */
          nodes[++m] = l;
      }
      c = 1;        /* we got successor */
  } else {   /* equal depths */
      if (DS_AVLLeft(tree,p) != 0) {
          l = DS_AVLLeft(tree,p);
          SetDS_AVLRank(tree,p,DS_AVLRank(tree,p) - 1);
          path[m] = 2;   /* was: -1 */
          nodes[++m] = l;
          while (DS_AVLRight(tree,l) != 0) {
              l = DS_AVLRight(tree,l);
              path[m] = 1;
              nodes[++m] = l;
          }
          c = -1;     /* we got predecessor */
      } else {        /* we got an end node */
          l = p;
          c = 0;
      }
  }
  /* l points now to a neighbour, in case c = -1 to the predecessor, in case
     c = 1 to the successor, or to p itself in case c = 0
     "nodes" and "path" is updated, but n could be < m */

  /* Copy Data from l up to p: order is NOT modified */
  SetDS_AVLData(tree,p,DS_AVLData(tree,l));
     /* works for m = n, i.e. if p is end node */

  /* Delete node at l = nodes[m] by modifying nodes[m-1]:
     Note: nodes[m] has maximal one subtree! */
  if (c <= 0)
      r = DS_AVLLeft(tree,l);
  else    /*  c > 0 */
      r = DS_AVLRight(tree,l);

  if (path[m-1] == 2)    /* was: < 0 */
      SetDS_AVLLeft(tree,nodes[m-1],r);
  else
      SetDS_AVLRight(tree,nodes[m-1],r);
  SetDS_AVLNodes(tree,DS_AVLNodes(tree)-1);
  DS_AVLFreeNode(tree,l);

  /* modify balance factors:
     the subtree nodes[m-1] has become shorter at its left (resp. right)
     subtree, if path[m-1]=-1 (resp. +1). We have to react according to
     the BalFactor at this node and then up the tree, if the whole subtree
     has shrunk:
     (we decrement m and work until the corresponding subtree has not shrunk) */
  m--;   /* start work HERE */
  while (m >= 1) {
      if (DS_AVLBalFactor(tree,nodes[m]) == 0) {
          SetDS_AVLBalFactor(tree,nodes[m],3-path[m]); /* we made path[m] shorter*/
          return x;
      } else if (DS_AVLBalFactor(tree,nodes[m]) == path[m]) {
          SetDS_AVLBalFactor(tree,nodes[m],0);     /* we made path[m] shorter */
      } else {   /* tree is out of balance */
          int shorter;
          DS_AVLRebalance(tree,nodes[m],&p,&shorter);
          if (m == 1) {
              SetDS_AVLTop(tree,p);
              return x;               /* everything is done */
          } else if (path[m-1] == 2)   /* was: = -1 */
              SetDS_AVLLeft(tree,nodes[m-1],p);
          else
              SetDS_AVLRight(tree,nodes[m-1],p);
          if (!shorter) return x;    /* nothing happens further up */
      }
      m--;
  }
  return x;
}


//
// Submodule declaration
//
static StructGVarFunc GVarFuncs[] = {
    GVARFUNC("avltree.c", DS_AVLCmp_C, 2, "a, b"),
    GVARFUNC("avltree.c", DS_AVLNewNode_C, 1, "t"),
    GVARFUNC("avltree.c", DS_AVLFreeNode_C, 2, "tree, n"),
    GVARFUNC("avltree.c", DS_AVLFind_C, 2, "tree, data"),
    GVARFUNC("avltree.c", DS_AVLIndexFind_C, 2, "tree, i"),
    GVARFUNC("avltree.c", DS_AVLFindIndex_C, 2, "tree, data"),
    GVARFUNC("avltree.c", DS_AVLLookup_C, 2, "tree, data"),
    GVARFUNC("avltree.c", DS_AVLIndex_C, 2, "tree, i"),
    GVARFUNC("avltree.c", DS_AVLIndexLookup_C, 2, "tree, i"),
    GVARFUNC("avltree.c", DS_AVLRebalance_C, 2, "tree, q"),
    GVARFUNC("avltree.c", DS_AVLAdd_C, 3, "tree, data, value"),
    GVARFUNC("avltree.c", DS_AVLIndexAdd_C, 4, "tree, data, value, index"),
    GVARFUNC("avltree.c", DS_AVLDelete_C, 2, "tree, data"),
    GVARFUNC("avltree.c", DS_AVLIndexDelete_C, 2, "tree, index"),

    { 0 }
};

static Int InitKernel(void)
{
    InitHdlrFuncsFromTable( GVarFuncs );

    ImportGVarFromLibrary( "DS_AVLTreeType", &DS_AVLTreeType );
    ImportGVarFromLibrary( "DS_AVLTreeTypeMutable", &DS_AVLTreeTypeMutable );
    ImportFuncFromLibrary( "DS_AVLTree", &DS_AVLTree );
    return 0;
}

static Int InitLibrary(void)
{
    InitGVarFuncsFromTable(GVarFuncs);
    return 0;
}

struct DatastructuresModule DS_AVLTreeModule = {
    .initKernel  = InitKernel,
    .initLibrary = InitLibrary,
};
