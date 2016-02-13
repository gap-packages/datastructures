/*
 * Datastructures: GAP package providing common datastructures.
 * Licensed under the GPL 2 or later.
 */

#ifndef DATASTRUCTURES_H
#define DATASTRUCTURES_H

#include "src/compiled.h" /* GAP headers */


// Helper macro for computing the size of a (static!) array
#define ARRAYSIZE(x) ((int)(sizeof(x) / sizeof(x[0])))

// Helper macro to simplify initialization of StructGVarFunc records
#define GVAR_FUNC_TABLE_ENTRY(srcfile, name, nparam, params) \
  {#name, nparam, \
   params, \
   (GVarFuncType)name, \
   srcfile ":Func" #name }

// This typedef is used by the GVAR_FUNC_TABLE_ENTRY macro.
typedef Obj (* GVarFuncType)(/*arguments*/);


// To improve code separation, each data structure implementation can
// provide a DatastructuresModule struct similar to GAP's StructInitInfo.
// It contains functions pointers invoked when the library is loaded.
//
// The functions should return 0 to indicate success, or any other value
// to signal an initialization error.
struct DatastructuresModule {
    Int (* initKernel)(void);       // initialise kernel data structures
    Int (* initLibrary)(void);      // initialise library data structures
    //Int (* preSave)(void);          // function to call before saving workspace
    //Int (* postSave)(void);         // function to call after saving workspace
    Int (* postRestore)(void);      // function to call after restoring workspace
};

#endif
