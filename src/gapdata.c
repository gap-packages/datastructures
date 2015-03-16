/***************************************************************************
**
*A  gapdata.c               GAPData-package               Markus Pfeiffer
**
**  Copyright (C) 2014  Markus Pfeiffer
**  This file is free software, see license information at the end.
**
*/

#include <stdlib.h>
#include <stdint.h>

#include "src/compiled.h"          /* GAP headers                */
#include "avltree.h"
#include "hashtable.h"

/*F * * * * * * * * * * * * * initialize package * * * * * * * * * * * * * * */

typedef Obj (* GVarFuncType)(/*arguments*/);

#define GVAR_FUNC_TABLE_ENTRY(srcfile, name, nparam, params) \
  {#name, nparam, \
   params, \
   (GVarFuncType)name, \
   srcfile ":Func" #name }



/******************************************************************************
*V  GVarFuncs . . . . . . . . . . . . . . . . . . list of functions to export
*/
static StructGVarFunc GVarFuncs [] = {

    GVAR_FUNC_TABLE_ENTRY("avltree.c", AVLCmp_C, 2, "a, b"),
    GVAR_FUNC_TABLE_ENTRY("avltree.c", AVLNewNode_C, 1, "t"),
    GVAR_FUNC_TABLE_ENTRY("avltree.c", AVLFreeNode_C, 2, "tree, n"),
    GVAR_FUNC_TABLE_ENTRY("avltree.c", AVLFind_C, 2, "tree, data"),
    GVAR_FUNC_TABLE_ENTRY("avltree.c", AVLIndexFind_C, 2, "tree, i"),
    GVAR_FUNC_TABLE_ENTRY("avltree.c", AVLFindIndex_C, 2, "tree, data"),
    GVAR_FUNC_TABLE_ENTRY("avltree.c", AVLLookup_C, 2, "tree, data"),
    GVAR_FUNC_TABLE_ENTRY("avltree.c", AVLIndex_C, 2, "tree, i"),
    GVAR_FUNC_TABLE_ENTRY("avltree.c", AVLIndexLookup_C, 2, "tree, i"),
    GVAR_FUNC_TABLE_ENTRY("avltree.c", AVLRebalance_C, 2, "tree, q"),
    GVAR_FUNC_TABLE_ENTRY("avltree.c", AVLAdd_C, 3, "tree, data, value"),
    GVAR_FUNC_TABLE_ENTRY("avltree.c", AVLIndexAdd_C, 4, "tree, data, value, index"),
    GVAR_FUNC_TABLE_ENTRY("avltree.c", AVLDelete_C, 2, "tree, data"),
    GVAR_FUNC_TABLE_ENTRY("avltree.c", AVLIndexDelete_C, 2, "tree, index"),

    GVAR_FUNC_TABLE_ENTRY("hashtable.c", HTAdd_TreeHash_C, 3, "treehash, x, v"),
    GVAR_FUNC_TABLE_ENTRY("hashtable.c", HTValue_TreeHash_C, 2, "treehash, x"),
    GVAR_FUNC_TABLE_ENTRY("hashtable.c", HTDelete_TreeHash_C, 2, "treehash, x"),
    GVAR_FUNC_TABLE_ENTRY("hashtable.c", HTUpdate_TreeHash_C, 3, "treehash, x, v"),
    GVAR_FUNC_TABLE_ENTRY("hashtable.c", GenericHashFunc_C, 2, "x, data"),

    { "JENKINS_HASH_IN_ORB", 4, "x, offset, bytelen, hashlen",
      FuncJenkinsHashInOrb,
      "hashtable.c:JENKINS_HASH_IN_ORB" },

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
    gvar = GVarName("__GAPDATA_C"); AssGVar( gvar, tmp ); MakeReadOnlyGVar(gvar);

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
  return &module;
}
#endif

StructInitInfo * Init__orb ( void )
{
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


