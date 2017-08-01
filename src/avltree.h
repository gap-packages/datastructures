/*
 * Datastructures: GAP package providing common datastructures.
 * Licensed under the GPL 2 or later.
 *
 * This file contains an AVL tree implementation,
 * Copyright (C) 2009-2013  Max Neunhoeffer
 */

#ifndef DS_AVLTREE_H
#define DS_AVLTREE_H

#include "datastructures.h"

// Submodule declaration
extern struct DatastructuresModule DS_AVLTreeModule;

/* Interface for DS_AVLTrees */
extern Obj DS_AVLTreeType;
extern Obj DS_AVLTreeTypeMutable;
extern Obj DS_AVLTree;

Obj DS_AVLCmp_C(Obj self, Obj a, Obj b);
Obj DS_AVLNewNode_C( Obj self, Obj t );
Obj DS_AVLFreeNode_C( Obj self, Obj t, Obj n);
Obj DS_AVLFind_C( Obj self, Obj t, Obj d );
Obj DS_AVLIndexFind_C( Obj self, Obj t, Obj i );
Obj DS_AVLFindIndex_C( Obj self, Obj t, Obj d );
Obj DS_AVLLookup_C( Obj self, Obj t, Obj d );
Obj DS_AVLIndex_C( Obj self, Obj t, Obj i );
Obj DS_AVLIndexLookup_C( Obj self, Obj t, Obj i );
Obj DS_AVLRebalance_C( Obj self, Obj tree, Obj q );
Obj DS_AVLAdd_C( Obj self, Obj tree, Obj data, Obj value );
Obj DS_AVLIndexAdd_C( Obj self, Obj tree, Obj data, Obj value, Obj ind );
Obj DS_AVLDelete_C( Obj self, Obj tree, Obj data);
Obj DS_AVLIndexDelete_C( Obj self, Obj tree, Obj index);

Int DS_AVLFind( Obj t, Obj d );
Obj DS_AVLValue( Obj t, Int n );
void SetDS_AVLValue( Obj t, Int n, Obj v );

#endif
