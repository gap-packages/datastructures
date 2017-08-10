gap> ReadPackage("datastructures", "tst/hashfunctions/hashtestfuncs.g");;
gap> cHash := function(x,y) compareHashes(x, y, DATA_HASH_FUNC_FOR_INT); end;;
gap> cHash([-10,0,10,2^30,2^60,2^100,2^10000], [-10,0,10,2^30,2^60,2^100,2^10000]);
gap> l1 := Set(Flat(List([0..100], x -> List([-5..5], y -> [2^x + y, -(2^x) + y]))));;
gap> l2 := Set(Flat(List([0..100], x -> List([-5..5], y -> [2^x + y, -(2^x) + y]))));;
gap> cHash(l1, l2);
gap> DATA_HASH_FUNC_FOR_INT((1,2,3));
Error, DATA_HASH_FUNC_FOR_INT: <i> must be an integer (not a permutation (smal\
l))
