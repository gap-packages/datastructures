#ifndef __AVLTREE_H
#define __AVLTREE_H

/* Interface for AVLTrees */
extern Obj AVLTreeType;
extern Obj AVLTreeTypeMutable;    
extern Obj AVLTree;

Obj AVLCmp_C(Obj self, Obj a, Obj b);
static Obj AVLNewNode_C( Obj self, Obj t );
static Obj AVLFreeNode_C( Obj self, Obj t, Obj n);
static Obj AVLFind_C( Obj self, Obj t, Obj d );
static Obj AVLIndexFind_C( Obj self, Obj t, Obj i );
static Obj AVLFindIndex_C( Obj self, Obj t, Obj d );
static Obj AVLLookup_C( Obj self, Obj t, Obj d );
static Obj AVLIndex_C( Obj self, Obj t, Obj i );
static Obj AVLIndexLookup_C( Obj self, Obj t, Obj i );
static Obj AVLRebalance_C( Obj self, Obj tree, Obj q );
static Obj AVLAdd_C( Obj self, Obj tree, Obj data, Obj value );
static Obj AVLIndexAdd_C( Obj self, Obj tree, Obj data, Obj value, Obj ind );
static Obj AVLDelete_C( Obj self, Obj tree, Obj data);
static Obj AVLIndexDelete_C( Obj self, Obj tree, Obj index);

static inline Int AVLFind( Obj t, Obj d );
static inline Obj AVLValue( Obj t, Int n );
static inline void SetAVLValue( Obj t, Int n, Obj v );
#endif

