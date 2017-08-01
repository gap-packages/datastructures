#############################################################################
##
##  datastructures package
##
##  Copyright 2016 by the package authors.
##  Licensed under the GPL 2 or later.
##
#############################################################################


#########################################################################
# Infrastructure for choosing hash functions looking at example objects:
#########################################################################


#
# Approach #1: Provide hash functions as methods for an operation.
#
# FIXME: turn this into an attribute?
# The difference only matters for attribute storing objects. These
# are, however, the ones most likely to be NOT hashable. OTOH, they
# just might be after all, but the hash is expensive (think "IdGroup"
# for small finite groups), and so being able to conveniently cash it
# would be useful
#
DeclareOperation( "HashValue", [IsObject] );

#
# Approach #2: Precompute a hash function, given an "example object",
# then use that.
#
DeclareOperation( "ChooseHashFunction", [IsObject] );

DeclareGlobalFunction( "DATA_HashFunctionForShortGF2Vectors" );
DeclareGlobalFunction( "DATA_HashFunctionForShort8BitVectors" );
DeclareGlobalFunction( "DATA_HashFunctionForGF2Vectors" );
DeclareGlobalFunction( "DATA_HashFunctionFor8BitVectors" );
DeclareGlobalFunction( "DATA_HashFunctionForCompressedMats" );
DeclareGlobalFunction( "DATA_HashFunctionForIntegers" );
DeclareGlobalFunction( "DATA_HashFunctionForMemory" );
DeclareGlobalFunction( "DATA_HashFunctionForPermutations" );
DeclareGlobalFunction( "DATA_HashFunctionForIntList" );
DeclareGlobalFunction( "DATA_HashFunctionForNBitsPcWord" );
DeclareGlobalFunction( "DATA_HashFunctionForMatList" );
DeclareGlobalFunction( "DATA_HashFunctionForPlainFlatList" );
DeclareGlobalFunction( "DATA_HashFunctionForTransformations" );
DeclareGlobalFunction( "DATA_HashFunctionForPartialPerms" );


#DeclareGlobalFunction( "MakeHashFunctionForPlainFlatList" );
