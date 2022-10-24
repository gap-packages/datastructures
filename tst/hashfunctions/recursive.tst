gap> ReadPackage("datastructures", "tst/hashfunctions/hashtestfuncs.g");;
gap> cHash := function(x,y) compareHashes(x,y, DATA_HASH_FUNC_RECURSIVE); end;;
gap> cHash([ [] ], [ "" ]);
gap> cHash([ [1, ,2, 3], [1,2,3] ], [ [1, ,2, 3], [1,2,3] ]);
gap> cHash(List([0..255], CHAR_INT), List([0..255], CHAR_INT));
gap> cHash([ ['a', 'b', 'c'] ], [ "abc" ]);
gap> cHash(Concatenation([true,false,fail], [-100..100], List([0..255], CHAR_INT)),
>          Concatenation([true,false,fail], [-100..100], List([0..255], CHAR_INT)));
gap> l := [ [1] ];;
gap> for i in [2..100] do l[i] := [i, l[i-1] ]; od;;
gap> cHash(l, DEEP_COPY_OBJ(l));
gap> cHash([ rec(a := 1, b := 2, c := 3)], [rec(c := 3, b := 2, a := 1)]);
gap> l := [rec()];;
gap> for i in [2..100] do l[i] := rec(a := l[i-1]); od;;
gap> cHash(l, DEEP_COPY_OBJ(l));
gap> l := [rec()];;
gap> for i in [2..100] do l[i] := rec(a := l[i-1]); od;;
gap> cHash(l, DEEP_COPY_OBJ(l));
gap> cHash([-100..100], [-100..100]);
gap> for i in [5..65] do
> l := List([-5..5], x -> 2^i+x);
> cHash(l, DEEP_COPY_OBJ(l));
> od;
gap> for i in [5..65] do
> l := List([-5..5], x -> -(2^i)+x);
> cHash(l, DEEP_COPY_OBJ(l));
> od;
gap> x := [1,2,(1,2), Transformation([1,2],[3,4]), "abc", true, rec(x := (4,5))];;
gap> cHash(x, DEEP_COPY_OBJ(x));
gap> HashBasic(1) <> HashBasic([1]);
true
gap> HashBasic(1,2) = HashBasic([1,2]);
true
gap> HashBasic(1,2,3) = HashBasic([1,2,3]);
true
gap> HashBasic(1,2,3,4) = HashBasic([1,2,3,4]);
true
gap> HashBasic(1,2,3,4,5) = HashBasic([1,2,3,4,5]);
true
gap> HashBasic(1,2,3,4,5,6,7,8,9,10) = HashBasic([1,2,3,4,5,6,7,8,9,10]);
true

# Make two records, one internally sorted, one not.
gap> rec1 := rec(aaax := 1, aaay := 2, aaaz := 3);;
gap> rec2 := rec(aaay := 2, aaaz := 3, aaax := 1);;
gap> rec1;
rec( aaax := 1, aaay := 2, aaaz := 3 )
gap> HashBasic(rec1) = HashBasic(rec2);
true
gap> rec1.aaaq := 9;; rec1.aaap := 8;;
gap> rec2.aaap := 8;; rec2.aaaq := 9;;
gap> HashBasic(rec1) = HashBasic(rec2);
true

# Make sure 'similar' objects have different hashes
gap> Size(Set([rec(), rec(1 := 2), rec(2 := 1), rec(1 := 2, 3 := 4), rec(1 := 4, 3 := 2)], HashBasic));
5
gap> Size(Set([ [], [1], [1,1], [2], [2,1], [2,2]], HashBasic));
6

# Check objects we don't handle
# FIXME: disabled due to differences in printing between GAP 4.10 and 4.11
#gap> HashBasic(SymmetricGroup(3));
#Error, Unable to hash object (component)
