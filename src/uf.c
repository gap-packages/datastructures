/*
 * Datastructures: GAP package providing common datastructures.
 * Licensed under the GPL 2 or later.
 */

#include "uf.h"

#include "src/debug.h"

static Obj DS_UF_FIND(Obj self, Obj xo, Obj parents) {
  Int x = INT_INTOBJ(xo);
  Int y;
  Int z;
  Obj *p;
  GAP_ASSERT(IS_PLIST(parents));
  GAP_ASSERT(LEN_PLIST(parents) >= x);
  GAP_ASSERT(x >= 1);
  GAP_ASSERT(ELM_PLIST(parents,x));
  p = ADDR_OBJ(parents);
  while (1) {
    y = INT_INTOBJ(p[x]);
    GAP_ASSERT(0 < y && y <= LEN_PLIST(parents));
    if (y == x)
      return INTOBJ_INT(x);
    z = INT_INTOBJ(p[y]);
    GAP_ASSERT(0 < z && z <= LEN_PLIST(parents));
    if (y == z)
      return INTOBJ_INT(y);
    p[x] = INTOBJ_INT(z);
    x = z;
  }
}

static Obj DS_UF_UNITE(Obj self, Obj xo, Obj yo, Obj rank, Obj parents) {
  Int x = INT_INTOBJ(DS_UF_FIND(0, xo, parents));
  Int y = INT_INTOBJ(DS_UF_FIND(0, yo, parents));
  Int rx, ry;
  if (x == y)
    return False;
  rx = INT_INTOBJ(ELM_PLIST(rank,x));
  ry = INT_INTOBJ(ELM_PLIST(rank,y));
  if (rx > ry)
    SET_ELM_PLIST(parents, y, INTOBJ_INT(x));
  else {
    SET_ELM_PLIST(parents, x, INTOBJ_INT(y));
    if (rx == ry)
      SET_ELM_PLIST(rank, y, INTOBJ_INT(ry+1));
  }
  return True;
}

static Obj DS_UF2_FIND(Obj self, Obj xo, Obj data) {
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
    y >>= 6;
    GAP_ASSERT(0 < y && y <= LEN_PLIST(data));
    if (y == x)
      return INTOBJ_INT(x);
    z = INT_INTOBJ(p[y]);
    z >>= 6;
    GAP_ASSERT(0 < z && z <= LEN_PLIST(data));
    if (y == z)
      return INTOBJ_INT(y);
    p[x] = INTOBJ_INT((z << 6) | (INT_INTOBJ(p[x]) & 0x3FL));
    x = z;
  }
}

static Obj DS_UF2_UNITE(Obj self, Obj xo, Obj yo, Obj data) {
  UInt x = INT_INTOBJ(DS_UF2_FIND(0, xo, data));
  UInt y = INT_INTOBJ(DS_UF2_FIND(0, yo, data));
  UInt rx, ry;
  if (x == y)
    return False;
  rx = INT_INTOBJ(ELM_PLIST(data,x));
  rx &= 0x3FL;
  ry = INT_INTOBJ(ELM_PLIST(data,y));
  ry &= 0x3FL;
  if (rx > ry)
    SET_ELM_PLIST(data, y, INTOBJ_INT((x << 6) | ry));
  else {
    SET_ELM_PLIST(data, x, INTOBJ_INT((y << 6) | rx));
    if (rx == ry)
      SET_ELM_PLIST(data, y, INTOBJ_INT((y << 6) | (ry+1)));
  }
  return True;
}


static StructGVarFunc GVarFuncs[] = {
  GVARFUNC(DS_UF_FIND, 2, "x, parents"),
  GVARFUNC(DS_UF_UNITE, 4, "x, y, rank, parents"),
  GVARFUNC(DS_UF2_FIND, 2, "x, data"),
  GVARFUNC(DS_UF2_UNITE, 3, "x, y, data"),
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
