gap> ReadPackage("datastructures", "tst/hashfunctions/hashtestfuncs.g");;
gap> cHash := function(x,y) compareHashes(x, y, DATA_HASH_FUNC_FOR_TRANS); end;;
gap> cHash([Transformation([]),Transformation([2,1]), Transformation([3,2,1])],
>          [Transformation([]),Transformation([2,1]), Transformation([3,2,1])]);
gap> l1 := List([65530..65550], x -> Transformation([1,x],[x,2]));;
gap> l2 := List(l1, x ->  x * (2^20,2^20+1) * (2^20,2^20+1));;

# Check that we have forced everything in l2 to be a Trans4
gap> ForAll(l2, IsTrans4Rep);
true
gap> cHash(l1, l2);
gap> DATA_HASH_FUNC_FOR_TRANS(6);
Error, DATA_HASH_FUNC_FOR_TRANS: <trans> must be a transformation (not a integ\
er)
