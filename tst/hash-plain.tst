# Test the plain hash tables derived from the orb package
gap> START_TEST("datastructures package: hash-plain.tst");

# Compute some test data
gap> G := GL(3,5);; v := One(G)[1];;
gap> orb := Orbit(G,v);;

#
gap> ht := DS_HTCreate(v, rec(hashlen := 1000));
<hash table obj len=1000 used=0 colls=0 accs=0 (can grow)>

#
gap> for i in [1..Length(orb)] do
>     DS_HTAdd(ht, orb[i], i);
> od;

#
gap> for i in [1..Length(orb)] do
>     if DS_HTValue(ht, orb[i]) <> i then
>         Error("lookup in orb failed at ", i);
>     fi;
> od;

#
gap> orb2 := Set(orb);;
gap> for i in [1..Length(orb2)] do
>     DS_HTUpdate(ht, orb2[i], i);
> od;

#
gap> for i in [1..Length(orb2)] do
>     if DS_HTValue(ht, orb2[i]) <> i then
>         Error("lookup in orb2 failed at ", i);
>     fi;
> od;


#
gap> STOP_TEST( "datastructures package: hash-plain.tst", 10000);
