/*
 * Datastructures: GAP package providing common datastructures.
 * Licensed under the GPL 2 or later.
 *
 * hashfun: various hash functions
 */

#ifndef HASHFUNCTIONS_H
#define HASHFUNCTIONS_H

#include "datastructures.h"
#include "src/intfuncs.h"

extern struct DatastructuresModule HashFunctionsModule;


// Hash two integers together
static inline UInt HashCombine2(UInt hash1, UInt hash2);

// Transform a UInt into a signed GAP intermediate integer, shrinking
// the size of the number as required
static inline Obj HashValueToObjInt(UInt uhash)
{
    Int hash = (Int)uhash;
    // Make sure bottom bits are not lost
    hash += hash << 11;
    hash /= 16;
    return INTOBJ_INT(hash);
}

// Perform a shuffle of a UInt. Ideally, changing any
// bit would have a 50/50 chance of changing every other bit.
// The main purpose of this is to allow adding values when
// we want to hash an unordered list -- while 1+3 = 2+2,
// HashUInt(1) + HashUInt(3) should not be equal to
// HashUInt(2) + HashUInt(2)
// From: http://www.concentric.net/~Ttwang/tech/inthash.htm
static UInt ShuffleUInt(UInt key);

#ifdef SYS_IS_64_BIT

static inline UInt HashCombine2(UInt hash1, UInt hash2)
{
    return 36287171667649 * hash1 + 3287951041 * hash2;
}

static inline UInt HashCombine3(UInt hash1, UInt hash2, UInt hash3)
{
    return 36287171667649 * hash1 + 3287951041 * hash2 + 2827328283 * hash3;
}

static UInt ShuffleUInt(UInt key)
{
    key = (~key) + (key << 21);    // key = (key << 21) - key - 1;
    key = key ^ (key >> 24);
    key = (key + (key << 3)) + (key << 8);    // key * 265
    key = key ^ (key >> 14);
    key = (key + (key << 2)) + (key << 4);    // key * 21
    key = key ^ (key >> 28);
    key = key + (key << 31);
    return key;
}

#else

static inline UInt HashCombine2(UInt hash1, UInt hash2)
{
    return 184950419 * hash1 + 79504963 * hash2;
}

static inline UInt HashCombine3(UInt hash1, UInt hash2, UInt hash3)
{
    return 184950419 * hash1 + 79504963 * hash2 + 293874 * hash3;
}

UInt ShuffleUInt(UInt key)
{
    key = ~key + (key << 15);    // key = (key << 15) - key - 1;
    key = key ^ (key >> 12);
    key = key + (key << 2);
    key = key ^ (key >> 4);
    key = key * 2057;    // key = (key + (key << 3)) + (key << 11);
    key = key ^ (key >> 16);
    return key;
}

#endif


#endif
