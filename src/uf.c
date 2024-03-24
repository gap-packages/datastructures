/*
 * Datastructures: GAP package providing common datastructures.
 * Licensed under the GPL 2 or later.
 */

#include "uf.h"

#ifdef SYS_IS_64_BIT
#define RANKBITS 6
#else
#define RANKBITS 5
#endif

#define RANKMASK ((1L << RANKBITS) -1)

static Obj FuncDS_UF_FIND(Obj self, Obj xo, Obj data) {
  UInt x = INT_INTOBJ(xo);
  UInt y;
  UInt z;
  Obj *p;
  GAP_ASSERT(IS_PLIST(data));
  GAP_ASSERT(LEN_PLIST(data) > x);
  GAP_ASSERT(x >= 1);
  GAP_ASSERT(ELM_PLIST(data,x));
  p = ADDR_OBJ(data);
  while (1) {
    y = INT_INTOBJ(p[x]);
    y >>= RANKBITS;
    GAP_ASSERT(0 < y && y <= LEN_PLIST(data));
    if (y == x)
      return INTOBJ_INT(x);
    z = INT_INTOBJ(p[y]);
    z >>= RANKBITS;
    GAP_ASSERT(0 < z && z <= LEN_PLIST(data));
    if (y == z)
      return INTOBJ_INT(y);
    p[x] = INTOBJ_INT((z << RANKBITS) | (INT_INTOBJ(p[x]) & RANKMASK));
    x = z;
  }
}

static Obj FuncDS_UF_UNITE(Obj self, Obj xo, Obj yo, Obj data) {
  UInt x = INT_INTOBJ(FuncDS_UF_FIND(0, xo, data));
  UInt y = INT_INTOBJ(FuncDS_UF_FIND(0, yo, data));
  UInt rx, ry;
  if (x == y)
    return False;
  rx = INT_INTOBJ(ELM_PLIST(data,x));
  rx &= RANKMASK;
  ry = INT_INTOBJ(ELM_PLIST(data,y));
  ry &= RANKMASK;
  if (rx > ry)
    SET_ELM_PLIST(data, y, INTOBJ_INT((x << RANKBITS) | ry));
  else {
    SET_ELM_PLIST(data, x, INTOBJ_INT((y << RANKBITS) | rx));
    if (rx == ry)
      SET_ELM_PLIST(data, y, INTOBJ_INT((y << RANKBITS) | (ry+1)));
  }
  return True;
}


static StructGVarFunc GVarFuncs[] = {
    GVAR_FUNC_2ARGS(DS_UF_FIND, x, data),
    GVAR_FUNC_3ARGS(DS_UF_UNITE, x, y, data),
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

struct DatastructuresModule UFModule = {
    .initKernel = InitKernel, .initLibrary = InitLibrary,
};
