/*
 * Datastructures: GAP package providing common datastructures.
 * Licensed under the GPL 2 or later.
 */

#ifndef DATASTRUCTURES_H
#define DATASTRUCTURES_H

#include "src/compiled.h" /* GAP headers */

#undef PACKAGE
#undef PACKAGE_BUGREPORT
#undef PACKAGE_NAME
#undef PACKAGE_STRING
#undef PACKAGE_TARNAME
#undef PACKAGE_URL
#undef PACKAGE_VERSION

#include "pkgconfig.h"             /* our own configure results */

/* Note that SIZEOF_VOID_P comes from GAP's config.h whereas
 * SIZEOF_VOID_PP comes from pkgconfig.h! */
#if SIZEOF_VOID_PP != SIZEOF_VOID_P
#error GAPs word size is different from ours, 64bit/32bit mismatch
#endif



// Helper macro to simplify initialization of StructGVarFunc records
#define GVARFUNC(name, nparam, params) \
  {#name, nparam, params, (GVarFuncType)name, __FILE__ ":" #name }

// This typedef is used by the GVARFUNC macro.
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
