gap> ReadPackage("datastructures", "tst/hashfunctions/hashtestfuncs.g");;
gap> cHash := function(x,y) compareHashes(x, y, DATA_HASH_FUNC_FOR_PERM); end;;
gap> cHash([(),(1,2),(1,2,3)],[(),(1,2),(1,2,3)]);
gap> l1 := List([65530..65550], x -> (1,x));;
gap> l2 := List(l1, x ->  x * (2^20,2^20+1) * (2^20,2^20+1));;

# Check that we have forced everything in l2 to be a Perm4
gap> ForAll(l2, IsPerm4Rep);
true
gap> cHash(l1, l2);
gap> DATA_HASH_FUNC_FOR_PERM(6);
Error, DATA_HASH_FUNC_FOR_PERM: <perm> must be a permutation (not a integer)
