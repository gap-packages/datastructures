gap> ReadPackage("datastructures", "tst/hashfunctions/hashtestfuncs.g");;
gap> cHash := function(x,y) compareHashes(x, y, DATA_HASH_FUNC_FOR_PPERM); end;;
gap> cHash([PartialPerm([]), PartialPerm([1,2],[2,1]), PartialPerm([2,3],[1,2])],
>          [PartialPerm([]), PartialPerm([1,2],[2,1]), PartialPerm([2,3],[1,2])]);
gap> l1 := List([65530..65550], x -> PartialPerm([x],[1]));;
gap> l2 := List(l1, x ->  x * (2^20,2^20+1) * (2^20,2^20+1));;

# Check that we have forced everything in l2 to be a PPerm4
gap> ForAll(l2, IsPPerm4Rep);
true
gap> cHash(l1, l2);
gap> DATA_HASH_FUNC_FOR_PPERM(6);
Error, DATA_HASH_FUNC_FOR_PPERM: <pperm> must be a partial permutation (not a \
integer)
