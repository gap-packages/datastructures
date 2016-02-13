# Test the AVL tree based hash tables derived from the orb package
gap> START_TEST("datastructures package: hash-tree.tst");

# Compute some test data
gap> G := GL(3,5);; v := One(G)[1];;
gap> orb := Orbit(G,v);;

#
gap> ht := HTCreate(v, rec(treehashsize := 1000));
<tree hash table len=1000 used=0 colls=0 accs=0>

#
gap> for i in [1..Length(orb)] do
>     HTAdd(ht, orb[i], i);
> od;

#
gap> for i in [1..Length(orb)] do
>     if HTValue(ht, orb[i]) <> i then
>         Error("lookup failed for ", orb[i]);
>     fi;
> od;

#
gap> orb2 := Set(orb);;
gap> for i in [1..Length(orb2)] do
>     HTUpdate(ht, orb2[i], i);
> od;

#
gap> for i in [1..Length(orb2)] do
>     if HTValue(ht, orb2[i]) <> i then
>         Error("lookup in orb2 failed at ", i);
>     fi;
> od;

#
gap> STOP_TEST( "datastructures package: hash-tree.tst", 10000);
