#ifndef __HASHTABLE_H
#define __HASHTABLE_H

extern Obj HTGrow;

static Obj HTAdd_TreeHash_C(Obj self, Obj ht, Obj x, Obj v);
static Obj HTValue_TreeHash_C(Obj self, Obj ht, Obj x);
static Obj HTDelete_TreeHash_C(Obj self, Obj ht, Obj x)
static Obj HTUpdate_TreeHash_C(Obj self, Obj ht, Obj x, Obj v)
  
static Obj GenericHashFunc_C(Obj self, Obj x, Obj data)
Obj FuncJenkinsHashInOrb(Obj self, Obj x, Obj offset, Obj bytelen, Obj hashlen);

#endif
