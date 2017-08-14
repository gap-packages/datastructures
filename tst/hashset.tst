##########################################
#
# Test hash set with integer keys
#

# setup
gap> N := 100000;;
gap> primes := Filtered([1..N], IsPrimeInt);;

# create new empty hash set
gap> hashset := HashSet();
<hash set obj capacity=16 used=0>
gap> IsEmpty(hashset);
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

# verify
gap> for p in primes do RemoveSet(hashset, p); od;
gap> IsEmpty(hashset);
true
