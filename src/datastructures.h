//
// Datastructures: GAP package providing common datastructures.
//
// Copyright (C) 2015-2017  The datastructures team.
// For list of the team members, please refer to the COPYRIGHT file.
//
// This package is licensed under the GPL 2 or later, please refer
// to the COPYRIGHT.md and LICENSE files for details.
//

#ifndef DATASTRUCTURES_H
#define DATASTRUCTURES_H

#include "gap_all.h" // GAP headers


// To improve code separation, each data structure implementation can
// provide a DatastructuresModule struct similar to GAP's StructInitInfo.
// It contains functions pointers invoked when the library is loaded.
//
// The functions should return 0 to indicate success, or any other value
// to signal an initialization error.
struct DatastructuresModule {
    Int (*initKernel)(void);     // initialise kernel data structures
    Int (*initLibrary)(void);    // initialise library data structures
};


// The following two helper functions increment resp. decrement the
// entry <plist> at index <pos> by <inc> resp. <dec>. For this, <inc>
// resp. <dec> as well as the value being modified must be non-negative
// immediate integers. If `plist[pos]` were to become negative, or too
// large to fit into an immediate error, an error is raised.
extern void DS_IncrementCounterInPlist(Obj plist, Int pos, Obj inc);
extern void DS_DecrementCounterInPlist(Obj plist, Int pos, Obj dec);


#endif
