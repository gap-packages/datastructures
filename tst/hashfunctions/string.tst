gap> ReadPackage("datastructures", "tst/hashfunctions/hashtestfuncs.g");;
gap> cHash := function(x,y) compareHashes(x, y, DATA_HASH_FUNC_FOR_STRING); end;;
gap> cHash(["", "a", "abcdef"],
>          [[], ['a'], ['a', 'b', 'c', 'd', 'e', 'f']]);

# We use 'NormalizeWhitespace' to create strings which are smaller than the memory
# block they are contained in
gap> base := "abc def";;
gap> for i in [2..1000] do
> s := Concatenation("abc", List([1..i], x -> ' '), "def", List([1..i], x -> ' '));
> NormalizeWhitespace(s);
> if SIZE_OBJ(s) = SIZE_OBJ(base) then Print("Misbuilt string"); fi;
> cHash([base], [s]);
> od;
gap> DATA_HASH_FUNC_FOR_STRING(6);
Error, DATA_HASH_FUNC_FOR_STRING: <string> must be a string (not a integer)
