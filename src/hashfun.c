/*
 * Datastructures: GAP package providing common datastructures.
 * Licensed under the GPL 2 or later.
 *
 * hashfun: various hash functions
 */

#include "hashfun.h"

#include "src/objects.h"

/* HACK: import various private definitions from GAP's pperm.c
   Ideally, the would be exported by pperm.h
*/
#if !defined(CODEG_PPERM4)

#define DEG_PPERM2(f)  ((UInt)(SIZE_OBJ(f)-sizeof(UInt2)-2*sizeof(Obj))/sizeof(UInt2))
#define CODEG_PPERM4(f)   (*(UInt4*)((Obj*)(ADDR_OBJ(f))+2))
#define DEG_PPERM4(f)     ((UInt)(SIZE_OBJ(f)-sizeof(UInt4)-2*sizeof(Obj))/sizeof(UInt4))

extern Obj FuncTRIM_PPERM (Obj self, Obj f);
#endif

Obj DATA_HASH_FUNC_FOR_PPERM(Obj self, Obj f) {
  UInt codeg;

  if(TNUM_OBJ(f)==T_PPERM4){
    codeg=CODEG_PPERM4(f);
    if(codeg<65536){
      FuncTRIM_PPERM(self, f);
    } else {
      return INTOBJ_INT(HASHKEY_BAG_NC(f, (UInt4) 255,
              2*sizeof(Obj)+sizeof(UInt4), (int) 4*DEG_PPERM4(f))
              );
    }
  }
  return INTOBJ_INT(HASHKEY_BAG_NC(f, (UInt4) 255,
              2*sizeof(Obj)+sizeof(UInt2), (int) 2*DEG_PPERM2(f))
              );
}

Obj DATA_HASH_FUNC_FOR_BLIST (Obj self, Obj blist) {

    size_t res  = 0;
    UInt   nr  = NUMBER_BLOCKS_BLIST(blist);
    UInt*  ptr  = BLOCKS_BLIST(blist);

    while (nr > 0) {
        res = (res * 23) + *(ptr++);
        nr--;
    }
    return INTOBJ_INT(res);
}

//
// Submodule declaration
//
static StructGVarFunc GVarFuncs [] = {
    GVARFUNC("hashfun.c", DATA_HASH_FUNC_FOR_BLIST, 1, "blist"),
    { 0 }
};

static Int InitKernel(void)
{
    InitHdlrFuncsFromTable(GVarFuncs);
    return 0;
}

static Int InitLibrary(void)
{
    InitGVarFuncsFromTable(GVarFuncs);
    return 0;
}

struct DatastructuresModule HashFunModule = {
    .initKernel  = InitKernel,
    .initLibrary = InitLibrary,
};
