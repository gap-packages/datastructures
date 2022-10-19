##########################################
#
# Test hash set with integer keys
#

# setup
gap> N := 10000;;
gap> primes := Filtered([1..N], IsPrimeInt);;

# create new empty hash set
gap> hashset := HashSet();
HashSet([])
gap> IsEmpty(hashset);
true

# test conversion to GAP set and iterator
gap> s:=Set(hashset); IsMutable(s);
[  ]
true
gap> s:=AsSet(hashset); IsMutable(s);
[  ]
false
gap> List(Iterator(hashset));
[  ]
gap> Set(HashSet([])) = [];
true
gap> s := Set(HashSet([1,2,3])) = [1,2,3];
true

# printing
gap> HashSet();
HashSet([])
gap> HashSet([]);
HashSet([])
gap> HashSet([2]);
HashSet([2])
gap> String(HashSet([2]));
"HashSet([2])"
gap> String(HashSet([2,3])) in ["HashSet([2, 3])","HashSet([3, 2])"];
true
gap> PrintString(HashSet([2]));
"HashSet([\>\>2\<\<])"
gap> PrintString(HashSet([2,3])) in ["HashSet([\>\>2,\< \>3\<\<])","HashSet([\>\>3,\< \>2\<\<])"];
true

# add stuff
gap> for p in primes do AddSet(hashset, p); od;

# verify
gap> ForAll([1..N], i -> (i in hashset) = (i in primes));
true
gap> Size(hashset) = Length(primes);
true
gap> IsEmpty(hashset);
false
gap> AsSet(hashset) = primes;
true
gap> Set(hashset) = primes;
true
gap> SortedList(List(Iterator(hashset))) = primes;
true

#
gap> 43 in hashset;
true
gap> 42 in hashset;
false

#
# Test deleting entries of the hash set
#

# delete something
gap> RemoveSet(hashset, 43);
gap> 43 in hashset;
false
gap> Size(hashset) = Length(primes) - 1;
true
gap> Size(AsSet(hashset)) = Length(primes) - 1;
true
gap> AsSet(hashset) = Filtered(primes, x -> x<>43);
true
gap> Size(List(Iterator(hashset))) = Length(primes) - 1;
true

# attempt to delete something which never was in the hash set
gap> RemoveSet(hashset, 42);
fail

# attempt to delete something already deleted
gap> RemoveSet(hashset, 43);
fail

# set previously deleted key again
gap> AddSet(hashset, 43);
gap> 43 in hashset;
true

# verify
gap> ForAll([1..N], i -> (i in hashset) = (i in primes));
true
gap> Size(hashset) = Length(primes);
true
gap> IsEmpty(hashset);
false
gap> AsSet(hashset) = primes;
true
gap> Set(hashset) = primes;
true
gap> SortedList(List(Iterator(hashset))) = primes;
true

# remove and verify
gap> for p in primes do RemoveSet(hashset, p); od;
gap> IsEmpty(hashset);
true
gap> AsSet(hashset);
[  ]
gap> Set(hashset);
[  ]
gap> List(Iterator(hashset));
[  ]

# Check different equality and hash functions
gap> h := HashSet([20,11,10,21], x -> x mod 2, {x,y} -> (x mod 10 = y mod 10));;
gap> Set(h);
[ 11, 20 ]

#
# error
#

# exhausting iterators
gap> hashset := HashSet();;
gap> it := Iterator(hashset);; NextIterator(it);
Error, <iter> is exhausted

# mutability
gap> hashset := HashSet();
HashSet([])
gap> AddSet(hashset, 15);
gap> MakeImmutable(hashset);
HashSet([15])
gap> AddSet(hashset, 15);
Error, <ht> must be a mutable hashmap or hashset
gap> RemoveSet(hashset, 20);
Error, <ht> must be a mutable hashmap or hashset
