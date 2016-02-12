/*
 * Datastructures: GAP package providing common datastructures.
 * Licensed under the GPL 2 or later.
 *
 * This file contains a (pseudo) hash table based on an AVL tree,
 *  Copyright (C) 2009-2013  Max Neunhoeffer
 */

#ifndef __HASHTABLE_H
#define __HASHTABLE_H

extern Obj HTGrow;

Obj HTAdd_TreeHash_C(Obj self, Obj ht, Obj x, Obj v);
Obj HTValue_TreeHash_C(Obj self, Obj ht, Obj x);
Obj HTDelete_TreeHash_C(Obj self, Obj ht, Obj x);
Obj HTUpdate_TreeHash_C(Obj self, Obj ht, Obj x, Obj v);

#endif
