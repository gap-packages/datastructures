gap> START_TEST("hashmap.tst");

##########################################
#
# Test hashmap with integer keys
#
gap> hashmap := DS_Hash_Create( IdFunc, \=, 5 );
<hash map obj capacity=16 used=0>

# add stuff
gap> for i in [1..1000] do DS_Hash_SetValue(hashmap, i, i^2); od;

# query it back
gap> ForAll([1..1000], i -> DS_Hash_Value(hashmap, i) = i^2);
true

# check for presence of objects known to be contained in the hashmap
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

# check for presence of objects known to be NOT contained in the hashmap
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

# delete something via mid-level API and high-level API
gap> DS_Hash_Delete(hashmap, 100);
10000
gap> Unbind(hashmap[567]);

# attempt to delete something which never was in the hashmap
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

#
gap> hashmap[100] := 42;
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
gap> hashmap[567];
fail
gap> DS_Hash_AccumulateValue(hashmap, 567, 1, SUM);
false
gap> hashmap[567];
1
gap> DS_Hash_AccumulateValue(hashmap, 567, 1, SUM);
true
gap> hashmap[567];
2
gap> DS_Hash_AccumulateValue(hashmap, 567, 5, PROD);
true
gap> hashmap[567];
10
gap> DS_Hash_AccumulateValue(hashmap, 567, 2^60-1, SUM);
true
gap> hashmap[567] = 2^60 + 9;
true
gap> DS_Hash_AccumulateValue(hashmap, 567, 1/2, SUM);
true
gap> hashmap[567] = 2^60 + 9 + 1/2;
true

# verify
gap> Filtered([1..1000], i -> not DS_Hash_Contains(hashmap, i));
[  ]

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

# test input validation for DS_Hash_Create
gap> DS_Hash_Create( fail, \=, 5 );
Error, <hashfunc> must be a function (not a boolean or fail)
gap> DS_Hash_Create( IdFunc, fail, 5 );
Error, <eqfunc> must be a function (not a boolean or fail)
gap> DS_Hash_Create( IdFunc, \=, fail );
Error, <capacity> must be a small positive integer (not a boolean or fail)

# test input validation for DS_Hash_Value
gap> DS_Hash_Value(fail, 1);
Error, <ht> must be a hashmap object (not a boolean or fail)
gap> DS_Hash_Value(hashmap, fail);
Error, <key> must not be equal to 'fail'

# to get full test coverage, we also should at least once pass in
# a positional object which isn't a hashmap
gap> IsPositionalObjectRep(infinity);
true
gap> DS_Hash_Value(infinity, 1);
Error, <ht> must be a hashmap object (not a object (positional))

# test input validation for DS_Hash_Contains
gap> DS_Hash_Contains(fail, 1);
Error, <ht> must be a hashmap object (not a boolean or fail)
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
Error, <ht> must be a hashmap object (not a boolean or fail)
gap> DS_Hash_Reserve(hashmap, fail);
Error, <capacity> must be a small positive integer (not a boolean or fail)

# test input validation for DS_Hash_AccumulateValue
gap> DS_Hash_AccumulateValue(fail, 567, 1, SUM);
Error, <ht> must be a hashmap object (not a boolean or fail)
gap> DS_Hash_AccumulateValue(hashmap, fail, 1, SUM);
Error, <key> must not be equal to 'fail'
gap> DS_Hash_AccumulateValue(hashmap, 567, fail, SUM);
Error, <val> must not be equal to 'fail'
gap> DS_Hash_AccumulateValue(hashmap, 567, 1, fail);
Error, <accufunc> must be a function (not a boolean or fail)

# test input validation for _DS_Hash_Lookup
gap> _DS_Hash_Lookup(hashmap, fail);
Error, <key> must not be equal to 'fail'
gap> _DS_Hash_Lookup(fail, 3000);
Error, <ht> must be a hashmap object (not a boolean or fail)

# test input validation for _DS_Hash_LookupCreate
gap> _DS_Hash_LookupCreate(hashmap, fail);
Error, <key> must not be equal to 'fail'
gap> _DS_Hash_LookupCreate(fail, 3000);
Error, <ht> must be a hashmap object (not a boolean or fail)

#
gap> badHashmap := DS_Hash_Create( x -> "hash", \=, 5 );;
gap> DS_Hash_Contains(badHashmap, 1);
Error, <hashfun> must return a small int (not a list (string))

#
# test reserving capacity
#
gap> hashmap := DS_Hash_Create( IdFunc, \=, 5 );
<hash map obj capacity=16 used=0>
gap> for i in [1..1400] do DS_Hash_SetValue(hashmap, i, i^2); od;
gap> hashmap;
<hash map obj capacity=2048 used=1400>

# delete a few keys to make sure this case is handled, too
gap> for i in [300..499] do DS_Hash_Delete(hashmap, i); od;
gap> hashmap;
<hash map obj capacity=2048 used=1200>

# trying to shrink does nothing
gap> DS_Hash_Reserve(hashmap, 200);
gap> hashmap;
<hash map obj capacity=2048 used=1200>

# reserving more space does something
gap> DS_Hash_Reserve(hashmap, 3000);
gap> hashmap;
<hash map obj capacity=4096 used=1200>

##########################################
#
# Test hashmap with string keys
#
#
gap> hashfun := function(str)
>     Assert(0, IsStringRep(str));
>     return HashKeyBag(str, 0, 0, -1);
> end;;
gap> hashmap := DS_Hash_Create( hashfun, \=, 20 );
<hash map obj capacity=32 used=0>
gap> DS_Hash_Capacity(hashmap);
32

# add stuff
gap> keys := List([1..1000], i -> String(HashKeyBag(2^100+i, 0,0,-1)));;
gap> for i in [1..Length(keys)] do
>     DS_Hash_SetValue(hashmap, keys[i], i^2);
> od;

# query it back
gap> ForAll([1..Length(keys)], i -> DS_Hash_Value(hashmap, keys[i]) = i^2);
true

# check for presence of objects known to be contained in the hashmap
gap> ForAll(keys, key -> DS_Hash_Contains(hashmap, key));
true

# check for presence of objects known to be NOT contained in the hashmap
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
# Test hashmap with non-standard equality,
# namely: identity.
#
gap> hashmap := DS_Hash_Create( HANDLE_OBJ, IsIdenticalObj, 5 );
<hash map obj capacity=16 used=0>
gap> hashmap["foo"] := 1;;
gap> hashmap["foo"] := 2;;
gap> "foo" in hashmap;
false
gap> DS_Hash_Contains(hashmap, "foo");
false
gap> hashmap["foo"];
fail

# now insert a key to which we keep a reference
gap> foo:="foo";;
gap> hashmap[foo] := 3;;
gap> DS_Hash_Contains(hashmap, foo);
true
gap> foo in hashmap;
true
gap> hashmap[foo];
3

#
gap> STOP_TEST( "hashmap.tst", 1);
