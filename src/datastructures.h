/*
 * Datastructures: GAP package providing common datastructures.
 * Licensed under the GPL 2 or later.
 */

#ifndef DATASTRUCTURES_H
#define DATASTRUCTURES_H

#include "src/compiled.h" /* GAP headers */

typedef Obj (* GVarFuncType)(/*arguments*/);

#define GVAR_FUNC_TABLE_ENTRY(srcfile, name, nparam, params) \
  {#name, nparam, \
   params, \
   (GVarFuncType)name, \
   srcfile ":Func" #name }

#endif
