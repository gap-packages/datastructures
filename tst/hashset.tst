##########################################
#
# Test hash set with integer keys
#

# setup
gap> N := 10000;;
gap> primes := Filtered([1..N], IsPrimeInt);;

# create new empty hash set
gap> hashset := HashSet();
<hash set obj capacity=16 used=0>
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

#
# error
#

# exhausting iterators
gap> hashset := HashSet();;
gap> it := Iterator(hashset);; NextIterator(it);
Error, <iter> is exhausted

# mutability
gap> hashset := HashSet();
<hash set obj capacity=16 used=0>
gap> AddSet(hashset, 15);
gap> MakeImmutable(hashset);
<hash set obj capacity=16 used=1>
gap> AddSet(hashset, 15);
Error, <ht> must be a mutable hashmap or hashset
gap> RemoveSet(hashset, 20);
Error, <ht> must be a mutable hashmap or hashset


