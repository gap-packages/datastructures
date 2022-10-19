gap> START_TEST("hashmap.tst");

##########################################
#
# Test hash map with integer keys
#
gap> hashmap := HashMap();
HashMap([])

# keys and values
gap> Keys(hashmap);
[  ]
gap> Values(hashmap);
[  ]

# add stuff
gap> for i in [1..1000] do DS_Hash_SetValue(hashmap, i, i^2); od;

# query it back
gap> ForAll([1..1000], i -> DS_Hash_Value(hashmap, i) = i^2);
true

# check keys and values
gap> keys:=Keys(hashmap);;
gap> IsDenseList(keys) and SortedList(keys) = [1..1000];
true
gap> vals:=Values(hashmap);;
gap> IsDenseList(vals) and SortedList(vals) = List([1..1000], i->i^2);
true

# check key and value iterators
gap> List(ValueIterator(hashmap)) = vals;
true
gap> List(KeyIterator(hashmap)) = keys;
true
gap> Set(List(KeyValueIterator(hashmap))) = List([1..1000],i->[i,i^2]);
true

# Check initial construction
gap> Set(List(KeyValueIterator(HashMap([])))) = [];
true
gap> Set(List(KeyValueIterator(HashMap([[1,2],[3,4]])))) = [[1,2],[3,4]];
true

# printing
gap> HashMap();
HashMap([])
gap> HashMap([]);
HashMap([])
gap> HashMap([[2,3]]);
HashMap([[ 2, 3 ]])
gap> String(HashMap([[2,3]]));
"HashMap([[ 2, 3 ]])"
gap> String(HashMap([[2,3],[3,4]])) in
> ["HashMap([[ 2, 3 ], [ 3, 4 ]])","HashMap([[ 3, 4 ], [ 2, 3 ]])"];
true
gap> PrintString(HashMap([[2,3]]));
"HashMap([\>\>[ 2, 3 ]\<\<])"
gap> PrintString(HashMap([[2,3],[3,4]]))
> in ["HashMap([\>\>[ 2, 3 ],\< \>[ 3, 4 ]\<\<])","HashMap([\>\>[ 3, 4 ],\< \>[ 2, 3 ]\<\<])"];
true

# Check different equality and hash functions
gap> h := HashMap([[20,1],[11,2],[10,3],[21,4]], x -> x mod 2, {x,y} -> (x mod 10 = y mod 10));;
gap> Set(List(KeyValueIterator(h)));
[ [ 11, 4 ], [ 20, 3 ] ]

# check for presence of objects known to be contained in the hash map
gap> DS_Hash_Contains(hashmap, 42);
true
gap> IsBound(hashmap[42]);
true
gap> hashmap[42] = 42^2;
true
gap> 42 in hashmap;
true
gap> ForAll([1..1000], i -> DS_Hash_Contains(hashmap, i));
true

# check for presence of objects known to be NOT contained in the hash map
gap> DS_Hash_Contains(hashmap, 0);
false
gap> IsBound(hashmap[0]);
false
gap> hashmap[0];
fail
gap> 0 in hashmap;
false
gap> ForAny([1001..2000], i -> DS_Hash_Contains(hashmap, i));
false
gap> ForAny([1001..2000], i -> IsBound(hashmap[i]));
false

#
# Test deleting entries of the hash map
#

# delete something via mid-level API and high-level API
gap> DS_Hash_Delete(hashmap, 100);
10000
gap> Unbind(hashmap[567]);

# attempt to delete something which never was in the hash map
gap> DS_Hash_Delete(hashmap, 3000);
fail

# attempt to delete something already deleted
gap> DS_Hash_Delete(hashmap, 100);
fail

# verify
gap> Filtered([1..1000], i -> not DS_Hash_Contains(hashmap, i));
[ 100, 567 ]

#
gap> IsBound(hashmap[100]);
false
gap> IsBound(hashmap[200]);
true
gap> IsBound(hashmap[567]);
false

# check keys and values
gap> keys:=Keys(hashmap);;
gap> IsDenseList(keys);
true
gap> Length(keys);
998
gap> Difference([1..1000], keys);
[ 100, 567 ]
gap> vals:=Values(hashmap);;
gap> IsDenseList(vals);
true
gap> Length(vals);
998
gap> Difference(List([1..1000], i -> i^2), vals);
[ 10000, 321489 ]

# check key and value iterators
gap> List(ValueIterator(hashmap)) = vals;
true
gap> List(KeyIterator(hashmap)) = keys;
true
gap> Difference(List([1..1000],i->[i,i^2]), List(KeyValueIterator(hashmap)));
[ [ 100, 10000 ], [ 567, 321489 ] ]

# set previously deleted key again
gap> hashmap[100] := 42;
42

# also override the value assigned to some still existing key
gap> hashmap[200] := 42;
42

#
gap> IsBound(hashmap[100]);
true
gap> IsBound(hashmap[200]);
true
gap> IsBound(hashmap[567]);
false

# verify
gap> Filtered([1..1000], i -> not DS_Hash_Contains(hashmap, i));
[ 567 ]

#
# Test DS_Hash_AccumulateValue
#
gap> hashmap[567];
fail
gap> DS_Hash_AccumulateValue(hashmap, 567, 1, \+);
false
gap> hashmap[567];
1
gap> DS_Hash_AccumulateValue(hashmap, 567, 1, \+);
true
gap> hashmap[567];
2
gap> DS_Hash_AccumulateValue(hashmap, 567, 5, \*);
true
gap> hashmap[567];
10
gap> DS_Hash_AccumulateValue(hashmap, 567, 2^60-1, \+);
true
gap> hashmap[567] = 2^60 + 9;
true
gap> DS_Hash_AccumulateValue(hashmap, 567, 1/2, \+);
true
gap> hashmap[567] = 2^60 + 9 + 1/2;
true

# verify
gap> Filtered([1..1000], i -> not DS_Hash_Contains(hashmap, i));
[  ]

#
# test (rest of) high-level interface
#
gap> IsEmpty(hashmap);
false
gap> Size(hashmap);
1000

#
# test low-level interface
#
gap> _DS_Hash_Lookup(hashmap, 3000);
0
gap> tmp:=List([1..1000], i->_DS_Hash_Lookup(hashmap,i));;
gap> ForAll([1..1000], i -> hashmap![5][tmp[i]] = i);
true

#
gap> ForAll([1..1000], i -> tmp[i] = _DS_Hash_LookupCreate(hashmap, i));
true
gap> i:=_DS_Hash_LookupCreate(hashmap, 3000);;
gap> IsBound(hashmap![5][i]);
false

#
# Test error handling
#

# test input validation for HashMap
gap> HashMap();
HashMap([])
gap> HashMap(IdFunc);
HashMap([])
gap> HashMap(20);
HashMap([])
gap> HashMap(IdFunc, \=);
HashMap([])
gap> HashMap(IdFunc, 20);
HashMap([])

#
gap> HashMap(fail);
Error, Invalid arguments
gap> HashMap(IdFunc, fail);
Error, Invalid arguments
gap> HashMap(IdFunc, 2, \=);
Error, Invalid arguments
gap> HashMap(IdFunc, fail, 2);
Error, Invalid arguments

# test input validation for DS_Hash_Create
gap> DS_Hash_Create( fail, \=, 5, true );
Error, <hashfunc> must be a function (not a boolean or fail)
gap> DS_Hash_Create( IdFunc, fail, 5, true );
Error, <eqfunc> must be a function (not a boolean or fail)
gap> DS_Hash_Create( IdFunc, \=, fail, true );
Error, <capacity> must be a small positive integer (not a boolean or fail)
gap> DS_Hash_Create( IdFunc, \=, 5, fail );
Error, <novalues> must be true or false (not a boolean or fail)

# test input validation for DS_Hash_Value
gap> DS_Hash_Value(fail, 1);
Error, <ht> must be a hashmap object (not a boolean or fail)
gap> DS_Hash_Value(hashmap, fail);
Error, <key> must not be equal to 'fail'

# to get full test coverage, we also should at least once pass in
# a positional object which isn't a hash map
# FIXME: disabled due to differences in printing between GAP 4.10 and 4.11
#gap> IsPositionalObjectRep(infinity);
#true
#gap> DS_Hash_Value(infinity, 1);
#Error, <ht> must be a hashmap object (not a object (positional))

# test input validation for DS_Hash_Contains
gap> DS_Hash_Contains(fail, 1);
Error, <ht> must be a hashmap or hashset (not a boolean or fail)
gap> DS_Hash_Contains(hashmap, fail);
Error, <key> must not be equal to 'fail'

# test input validation for DS_Hash_SetValue
gap> DS_Hash_SetValue(fail, 0, 0);
Error, <ht> must be a hashmap object (not a boolean or fail)
gap> DS_Hash_SetValue(hashmap, fail, 0);
Error, <key> must not be equal to 'fail'
gap> DS_Hash_SetValue(hashmap, 0, fail);
Error, <val> must not be equal to 'fail'

# test input validation for DS_Hash_SetValue
gap> DS_Hash_Reserve(fail, 100);
Error, <ht> must be a hashmap or hashset (not a boolean or fail)
gap> DS_Hash_Reserve(hashmap, fail);
Error, <capacity> must be a small positive integer (not a boolean or fail)

# test input validation for DS_Hash_AccumulateValue
gap> DS_Hash_AccumulateValue(fail, 567, 1, \+);
Error, <ht> must be a hashmap object (not a boolean or fail)
gap> DS_Hash_AccumulateValue(hashmap, fail, 1, \+);
Error, <key> must not be equal to 'fail'
gap> DS_Hash_AccumulateValue(hashmap, 567, fail, \+);
Error, <val> must not be equal to 'fail'
gap> DS_Hash_AccumulateValue(hashmap, 567, 1, fail);
Error, <accufunc> must be a function (not a boolean or fail)

# test input validation for _DS_Hash_Lookup
gap> _DS_Hash_Lookup(hashmap, fail);
Error, <key> must not be equal to 'fail'
gap> _DS_Hash_Lookup(fail, 3000);
Error, <ht> must be a hashmap or hashset (not a boolean or fail)

# test input validation for _DS_Hash_LookupCreate
gap> _DS_Hash_LookupCreate(hashmap, fail);
Error, <key> must not be equal to 'fail'
gap> _DS_Hash_LookupCreate(fail, 3000);
Error, <ht> must be a hashmap or hashset (not a boolean or fail)

#
gap> badHashmap := HashMap( x -> "hash" );;
gap> DS_Hash_Contains(badHashmap, 1);
Error, <hashfun> must return a small int (not a list (string))

# exhausting iterators
gap> hashmap := HashMap();;
gap> it := KeyIterator(hashmap);; NextIterator(it);
Error, <iter> is exhausted
gap> it := ValueIterator(hashmap);; NextIterator(it);
Error, <iter> is exhausted
gap> it := KeyValueIterator(hashmap);; NextIterator(it);
Error, <iter> is exhausted

#
# test reserving capacity
#
gap> hashmap := HashMap();
HashMap([])
gap> for i in [1..1400] do DS_Hash_SetValue(hashmap, i, i^2); od;
gap> [Size(hashmap), DS_Hash_Capacity(hashmap)];
[ 1400, 2048 ]

# delete a few keys to make sure this case is handled, too
gap> for i in [300..499] do DS_Hash_Delete(hashmap, i); od;
gap> [Size(hashmap), DS_Hash_Capacity(hashmap)];
[ 1200, 2048 ]

# trying to shrink does nothing
gap> DS_Hash_Reserve(hashmap, 200);
gap> [Size(hashmap), DS_Hash_Capacity(hashmap)];
[ 1200, 2048 ]

# reserving more space does something
gap> DS_Hash_Reserve(hashmap, 3000);
gap> [Size(hashmap), DS_Hash_Capacity(hashmap)];
[ 1200, 4096 ]

##########################################
#
# Test hash map with string keys
#
#
gap> hashmap := HashMap();
HashMap([])

# add stuff
gap> keys := List([1..1000], i -> String(HashKeyBag(2^100+i, 0,0,-1)));;
gap> for i in [1..Length(keys)] do
>     DS_Hash_SetValue(hashmap, keys[i], i^2);
> od;

# query it back
gap> ForAll([1..Length(keys)], i -> DS_Hash_Value(hashmap, keys[i]) = i^2);
true

# check for presence of objects known to be contained in the hash map
gap> ForAll(keys, key -> DS_Hash_Contains(hashmap, key));
true

# check for presence of objects known to be NOT contained in the hash map
gap> DS_Hash_Contains(hashmap, "test");
false
gap> ForAny([1001..2000], i -> DS_Hash_Contains(hashmap, String(i)));
false

# delete something
gap> DS_Hash_Delete(hashmap, keys[100]);
10000
gap> DS_Hash_Delete(hashmap, keys[567]);
321489

# verify
gap> keys{[100,567]} = Filtered(keys, key -> not DS_Hash_Contains(hashmap, key));
true

##########################################
#
# Test hash map with non-standard equality,
# namely: identity.
#
gap> hashmap := HashMap( {x} -> (HANDLE_OBJ(x) mod 2^20), IsIdenticalObj );
HashMap([])
gap> hashmap["foo"] := 1;;
gap> hashmap["foo"] := 2;;
gap> DS_Hash_Contains(hashmap, "foo");
false
gap> "foo" in hashmap;
false
gap> IsBound(hashmap["foo"]);
false
gap> hashmap["foo"];
fail

# now insert a key to which we keep a reference
# must be immutable else an immutable copy will be made on insertion
gap> foo:=Immutable("foo");;
gap> hashmap[foo] := 3;;
gap> DS_Hash_Contains(hashmap, foo);
true
gap> foo in hashmap;
true
gap> IsBound(hashmap[foo]);
true
gap> hashmap[foo];
3

##########################################
#
# Test mutability
#
gap> hashmap := HashMap();
HashMap([])
gap> hashmap[15] := "";
""
gap> MakeImmutable(hashmap);
HashMap([[ 15, "" ]])
gap> IsMutable(hashmap);
false
gap> hashmap[15] := "2";
Error, <ht> must be a mutable hashmap or hashset
gap> hashmap[17] := 7;
Error, <ht> must be a mutable hashmap or hashset
gap> Unbind(hashmap[17]);
Error, <ht> must be a mutable hashmap or hashset
gap> DS_Hash_AccumulateValue(hashmap, 567, 1, \+);
Error, <ht> must be a mutable hashmap or hashset

# Test key mutability
gap> l := [1];;
gap> hashmap := HashMap();;
gap> hashmap[l] := 2;;
gap> Add(l, 2);;
gap> hashmap[l] := 3;;
gap> hashmap[l];
3
gap> hashmap[[1]];
2

#
gap> STOP_TEST( "hashmap.tst", 1);
