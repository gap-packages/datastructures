/***************************************************************************
**
*A  gapdata.c               GAPData-package               Markus Pfeiffer
**
**  Copyright (C) 2014  Markus Pfeiffer
**  This file is free software, see license information at the end.
**
*/

/*T get this from git */
const char * Revision_gapdata_c =
   "$Id: gapdata.c,v$";

#include <stdlib.h>

#include "src/compiled.h"          /* GAP headers                */
#include "avltree.h"
#include "hashtable.h"
#include "misc.h"

/*F * * * * * * * * * * * * * initialize package * * * * * * * * * * * * * * */

/******************************************************************************
*V  GVarFuncs . . . . . . . . . . . . . . . . . . list of functions to export
*/
static StructGVarFunc GVarFuncs [] = {

  { "AVLCmp_C", 2, "a, b",
    AVLCmp_C,
    "avltree.c:AVLCmp_C" },

  { "AVLNewNode_C", 1, "t",
    AVLNewNode_C,
    "avltree.c:AVLNewNode_C" },

  { "AVLFreeNode_C", 2, "tree, n",
    AVLFreeNode_C,
    "avltree.c:AVLFreeNode_C" },

  { "AVLFind_C", 2, "tree, data",
    AVLFind_C,
    "avltree.c:AVLFind_C" },

  { "AVLIndexFind_C", 2, "tree, i",
    AVLIndexFind_C,
    "avltree.c:AVLIndexFind_C" },

  { "AVLFindIndex_C", 2, "tree, data",
    AVLFindIndex_C,
    "avltree.c:AVLFindIndex_C" },

  { "AVLLookup_C", 2, "tree, data",
    AVLLookup_C,
    "avltree.c:AVLLookup_C" },

  { "AVLIndex_C", 2, "tree, i",
    AVLIndex_C,
    "avltree.c:AVLIndex_C" },

  { "AVLIndexLookup_C", 2, "tree, i",
    AVLIndexLookup_C,
    "avltree.c:AVLIndexLookup_C" },

  { "AVLRebalance_C", 2, "tree, q",
    AVLRebalance_C,
    "avltree.c:AVLRebalance_C" },

  { "AVLAdd_C", 3, "tree, data, value",
    AVLAdd_C,
    "avltree.c:AVLAdd_C" },

  { "AVLIndexAdd_C", 4, "tree, data, value, index",
    AVLIndexAdd_C,
    "avltree.c:AVLIndexAdd_C" },

  { "AVLDelete_C", 2, "tree, data", 
    AVLDelete_C,
    "avltree.c:AVLDelete_C" },

  { "AVLIndexDelete_C", 2, "tree, index", 
    AVLIndexDelete_C,
    "avltree.c:AVLIndexDelete_C" },

  { "HTAdd_TreeHash_C", 3, "treehash, x, v",
    HTAdd_TreeHash_C,
    "hashtable.c:HTAdd_TreeHash_C" },

  { "HTValue_TreeHash_C", 2, "treehash, x",
    HTValue_TreeHash_C,
    "hashtable.c:HTValue_TreeHash_C" },

  { "HTDelete_TreeHash_C", 2, "treehash, x",
    HTDelete_TreeHash_C,
    "hashtable.c:HTDelete_TreeHash_C" },

  { "HTUpdate_TreeHash_C", 3, "treehash, x, v",
    HTUpdate_TreeHash_C,
    "hashtable.c:HTUpdate_TreeHash_C" },

  { "GenericHashFunc_C", 2, "x, data",
    GenericHashFunc_C,
    "hashtable.c:GenericHashFunc_C" }, 

  { "JENKINS_HASH_IN_ORB", 4, "x, offset, bytelen, hashlen",
    FuncJenkinsHashInOrb, 
    "hashtable.c:JENKINS_HASH_IN_ORB" },

  { "PermLeftQuoTransformationNC_C", 2, "t1, t2",
    FuncPermLeftQuoTransformationNC,
    "misc.c:FuncPermLeftQuoTransformationNC" },

  { "MappingPermSetSet_C", 2, "src, dst",
    FuncMappingPermSetSet,
    "misc.c:FuncMappingPermSetSet_C" },

  { "MappingPermListList_C", 2, "src, dst",
    FuncMappingPermListList,
    "misc.c:FuncMappingPermListList" },

#if 0
/* The following one has better complexity and is only slightly slower
 * for very small transformations. */
  { "ImageAndKernelOfTransformation2_C", 1, "t",
    FuncImageAndKernelOfTransformation,
    "misc.c:FuncImageAndKernelOfTransformation" },
#endif

  { "ImageAndKernelOfTransformation_C", 1, "t",
    FuncImageAndKernelOfTransformation,
    "misc.c:FuncImageAndKernelOfTransformation" },

  { "TABLE_OF_TRANS_KERNEL", 2, "k, n",
    FuncTABLE_OF_TRANS_KERNEL,
    "misc.c:FuncTABLE_OF_TRANS_KERNEL" },

  { "CANONICAL_TRANS_SAME_KERNEL", 1, "t",
    FuncCANONICAL_TRANS_SAME_KERNEL,
    "misc.c:FuncCANONICAL_TRANS_SAME_KERNEL" },

  { "IS_INJECTIVE_TRANS_ON_LIST", 2, "t, l",
    FuncIS_INJECTIVE_TRANS_ON_LIST,
    "misc.c:FuncIS_INJECTIVE_TRANS_ON_LIST" },

  { 0 }

};

/******************************************************************************
*F  InitKernel( <module> )  . . . . . . . . initialise kernel data structures
*/
static Int InitKernel ( StructInitInfo *module )
{
    /* init filters and functions                                          */
    InitHdlrFuncsFromTable( GVarFuncs );

    ImportGVarFromLibrary( "AVLTreeType", &AVLTreeType );
    ImportGVarFromLibrary( "AVLTreeTypeMutable", &AVLTreeTypeMutable );
    ImportFuncFromLibrary( "AVLTree", &AVLTree );
    ImportFuncFromLibrary( "HTGrow", &HTGrow );

    /* return success                                                      */
    return 0;
}

Obj FuncADD_SET(Obj self, Obj set, Obj obj);

/******************************************************************************
*F  InitLibrary( <module> ) . . . . . . .  initialise library data structures
*/
static Int InitLibrary ( StructInitInfo *module )
{
    Int             i, gvar;
    Obj             tmp;

    /* init filters and functions */
    for ( i = 0;  GVarFuncs[i].name != 0;  i++ ) {
      gvar = GVarName(GVarFuncs[i].name);
      AssGVar(gvar,NewFunctionC( GVarFuncs[i].name, GVarFuncs[i].nargs,
                                 GVarFuncs[i].args, GVarFuncs[i].handler ) );
      MakeReadOnlyGVar(gvar);
    }

    tmp = NEW_PREC(0);
    gvar = GVarName("ORBC"); AssGVar( gvar, tmp ); MakeReadOnlyGVar(gvar);

    /* return success                                                      */
    return 0;
}

/******************************************************************************
*F  InitInfopl()  . . . . . . . . . . . . . . . . . table of init functions
*/
static StructInitInfo module = {
#ifdef ORBSTATIC
 /* type        = */ MODULE_STATIC,
#else
 /* type        = */ MODULE_DYNAMIC,
#endif
 /* name        = */ "gapdata",
 /* revision_c  = */ 0,
 /* revision_h  = */ 0,
 /* version     = */ 0,
 /* crc         = */ 0,
 /* initKernel  = */ InitKernel,
 /* initLibrary = */ InitLibrary,
 /* checkInit   = */ 0,
 /* preSave     = */ 0,
 /* postSave    = */ 0,
 /* postRestore = */ 0
};

#ifndef ORBSTATIC
StructInitInfo * Init__Dynamic ( void )
{
  module.revision_c = Revision_gapdata_c;
  return &module;
}
#endif

StructInitInfo * Init__orb ( void )
{
  module.revision_c = Revision_gapdata_c;
  return &module;
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

