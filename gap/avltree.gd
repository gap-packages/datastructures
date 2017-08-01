#############################################################################
##
##                             orb package
##  avltree.gd
##                                                          Juergen Mueller
##                                                          Max Neunhoeffer
##                                                             Felix Noeske
##
##  Copyright 2009-2009 by the authors.
##  This file is free software, see license information at the end.
##
##  Declaration stuff for AVL trees in GAP.
##
##  adding, removing and finding in O(log n), n is number of nodes
##
##  see Knuth: "The Art of Computer Programming" for algorithms
##
#############################################################################

BindGlobal( "DS_AVLTreeFamily", NewFamily("DS_AVLTreeFamily") );
DeclareCategory( "IsDS_AVLTree", IsPositionalObjectRep );
DeclareRepresentation( "IsDS_AVLTreeFlatRep", IsDS_AVLTree, [] );
BindGlobal( "DS_AVLTreeType", NewType(DS_AVLTreeFamily,IsDS_AVLTreeFlatRep) );
BindGlobal( "DS_AVLTreeTypeMutable", NewType(DS_AVLTreeFamily,
                                          IsDS_AVLTreeFlatRep and IsMutable) );

# All of the following functions exist on the GAP level and some of
# them on the C level for speedup. The GAP versions have "_GAP" appended
# to their name, the C versions have "_C" appended. The version with
# nothing appended is the one to be used, it is assigned to the C
# version if it is there and otherwise to the GAP version.

DeclareGlobalFunction( "DS_AVLCmp" );
DeclareGlobalFunction( "DS_AVLTree" );
DeclareGlobalFunction( "DS_AVLNewNode" );
DeclareGlobalFunction( "DS_AVLFreeNode" );
DeclareGlobalFunction( "DS_AVLData" );
DeclareGlobalFunction( "DS_AVLSetData" );
DeclareGlobalFunction( "DS_AVLLeft" );
DeclareGlobalFunction( "DS_AVLSetLeft" );
DeclareGlobalFunction( "DS_AVLRight" );
DeclareGlobalFunction( "DS_AVLSetRight" );
DeclareGlobalFunction( "DS_AVLRank" );
DeclareGlobalFunction( "DS_AVLSetRank" );
DeclareGlobalFunction( "DS_AVLBalFactor" );
DeclareGlobalFunction( "DS_AVLSetBalFactor" );
DeclareGlobalFunction( "DS_AVLValue" );
DeclareGlobalFunction( "DS_AVLSetValue" );
DeclareGlobalFunction( "DS_AVLFind" );
DeclareGlobalFunction( "DS_AVLFindIndex" );
DeclareGlobalFunction( "DS_AVLLookup" );
DeclareGlobalFunction( "DS_AVLIndex" );
DeclareGlobalFunction( "DS_AVLIndexFind" );
DeclareGlobalFunction( "DS_AVLRebalance" );
DeclareGlobalFunction( "DS_AVLIndexLookup" );
DeclareGlobalFunction( "DS_AVLAdd" );
DeclareGlobalFunction( "DS_AVLIndexAdd" );
DeclareGlobalFunction( "DS_AVLDelete" );
DeclareGlobalFunction( "DS_AVLIndexDelete" );
DeclareGlobalFunction( "DS_AVLToList" );

