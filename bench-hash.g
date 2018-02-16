LoadPackage("datastructures");

# mygap4currL -m 500m
LoadPackage("cvec"); # HACK
LoadPackage("atlasrep");
LoadPackage("orb");
gens := AtlasGenerators("HN",8).generators;                         
s := AtlasStraightLineProgram("HN",1).program;
ugens := ResultOfStraightLineProgram(s,gens);
guck := List(ugens,x->x-One(x));
guck := List(guck,NullspaceMat);
v := SumIntersectionMat(guck[1],guck[2])[2][1];
v*ugens[1]=v;
v*ugens[2]=v;
o := Orb(gens,v,OnRight,rec( treehashsize := 2000000, report := 100000,
                             storenumbers := true ));
ti := Runtime();
Enumerate(o);
Print("Time: ",Runtime()-ti,"\n");  # 34 seconds

l := o!.orbit;;  # length: 1140000

#
# Test orb's tree hash table speed
#
Print("Creating tree hash...\n");
t := HTCreate(v,rec(treehashsize := 200000));

GASMAN("collect");
Print("Adding values...\n");
ti := Runtime();
for i in [1..Length(l)] do
    HTAdd(t,l[i],i);
od;
Print("Time: ",Runtime()-ti,"\n");  # 4.128 seconds
#
Print("Lookup...\n");
ti := Runtime();
for i in [1..Length(l)] do
    if HTValue(t,l[i]) <> i then Error(); fi;
od;
Print("Time: ",Runtime()-ti,"\n");  # 1.817 seconds
Print("\n");


#
# Test orb's regular hash table speed
#
Print("Creating regular hash...\n");
t := HTCreate(v,rec(hashlen := 200000));

GASMAN("collect");
Print("Adding values...\n");
ti := Runtime();
for i in [1..Length(l)] do
    HTAdd(t,l[i],i);
od;
Print("Time: ",Runtime()-ti,"\n");  # 3.469, 4.432 seconds
#
Print("Lookup...\n");
ti := Runtime();
for i in [1..Length(l)] do
    if HTValue(t,l[i]) <> i then Error(); fi;
od;
Print("Time: ",Runtime()-ti,"\n");  # 1.845, 1.738 seconds
Print("\n");



#
#
#
sample_vec:=l[1];
q := Q_VEC8BIT(sample_vec);
i := LogInt(256,q);
# i is now the number of field elements per byte
bytelen := QuoInt(Length(sample_vec),i);
#SIZE_OBJ(sample_vec) - 3*GAPInfo.BytesPerVariable;

hashfun := function(vec8bit)
    return HashKeyBag(vec8bit, 101, 3*GAPInfo.BytesPerVariable, bytelen);
end;

Print("Creating hashmap...\n");
dsHashMap := DS_Hash_Create( hashfun, \=, 20000 );;

GASMAN("collect");
Print("Adding values...\n");
ti := Runtime();
for i in [1..Length(l)] do
    DS_Hash_SetValue(dsHashMap, l[i], i);
od;
Print("Time: ",Runtime()-ti,"\n");  # 2.210 seconds;   1.64 with "hardcode EQ"-hack
#
Print("Lookup...\n");
ti := Runtime();
for i in [1..Length(l)] do
    if DS_Hash_Value(dsHashMap,l[i]) <> i then Error(); fi;
od;
Print("Time: ",Runtime()-ti,"\n");  # 0.971 / 0.944 seconds
Print("\n");


#
# HACK
#

# 3.205 / 1.31
for i in [1..Length(l)] do if HTValue(t,l[i]) <> i then Error(); fi; od; time;

# 3.049 / 0.99
for i in [1..Length(l)] do if DS_Hash_Value(dsHashMap,l[i]) <> i then Error(); fi; od; time;

for i in [1..Length(l)] do DS_Hash_Value(dsHashMap,l[i]); od; time;

# 2.674 / 0.69
for i in [1..Length(l)] do  _DS_Hash_Lookup(dsHashMap,l[i]); od; time;
