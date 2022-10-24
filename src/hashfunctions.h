//
// Datastructures: GAP package providing common datastructures.
//
// Copyright (C) 2015-2017  The datastructures team.
// For list of the team members, please refer to the COPYRIGHT file.
//
// This package is licensed under the GPL 2 or later, please refer
// to the COPYRIGHT.md and LICENSE files for details.
//
//
// hashfunctions: various hash functions
//

#ifndef HASHFUNCTIONS_H
#define HASHFUNCTIONS_H

#include "datastructures.h"
#include "src/intfuncs.h"

extern struct DatastructuresModule HashFunctionsModule;


// Hash two integers together
static inline UInt HashCombine2(UInt hash1, UInt hash2)
{
    return 184950419 * hash1 + hash2;
}

static inline UInt HashCombine3(UInt hash1, UInt hash2, UInt hash3)
{
    return 79504963 * hash1 + 3287951041 * hash2 + hash3;
}

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

#endif
