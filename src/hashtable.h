#ifndef __HASHTABLE_H
#define __HASHTABLE_H

extern Obj HTGrow;

Obj HTAdd_TreeHash_C(Obj self, Obj ht, Obj x, Obj v);
Obj HTValue_TreeHash_C(Obj self, Obj ht, Obj x);
Obj HTDelete_TreeHash_C(Obj self, Obj ht, Obj x);
Obj HTUpdate_TreeHash_C(Obj self, Obj ht, Obj x, Obj v);
  
Obj GenericHashFunc_C(Obj self, Obj x, Obj data);
Obj FuncJenkinsHashInOrb(Obj self, Obj x, Obj offset, Obj bytelen, Obj hashlen);

#endif
