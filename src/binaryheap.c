//
// Datastructures: GAP package providing common datastructures.
//
// Copyright (C) 2015-2017  The datastructures team.
// For list of the team members, please refer to the COPYRIGHT file.
//
// This package is licensed under the GPL 2 or later, please refer
// to the COPYRIGHT.md and LICENSE files for details.
//
// Implementation of a binary heap.
//
// Binary heaps are of course pretty standard data structures.
// However, a few design choices are possible. The implementation
// below has been influenced by this StackOverflow answer:
//   <https://stackoverflow.com/questions/6531543>
//

#include "gap_all.h" // GAP headers
#include "binaryheap.h"

#define DS_BINARYHEAP_ISLESS(heap) ELM_PLIST(heap, 1)
#define DS_BINARYHEAP_DATA(heap) ELM_PLIST(heap, 2)

// "Bubble-up" helper used for insertion: Given a heap <data> (represented by
// a GAP plist), and a comparison operation <isLess>, insert the <elm> at
// position <i>. Then compare it to its parent; if they are in the right
// order,
// stop; otherwise, swap them, and repeat the process, now with the new parent
// of our object, until we reach the root.
//
// In practice, we actually only insert the element as the very last step,
// and don't perform actual swaps. That's a simple optimization.
//
// Note that for normal insertions into the heap, as performed by
// DS_BinaryHeap_Insert(), <i> will be equal to the length of <data> plus 1.
// But in DS_BinaryHeap_ReplaceMax(), it can be less than that.
static void DS_BinaryHeap_BubbleUp(Obj data, Obj isLess, Int i, Obj elm)
{
    const Int useLt = (isLess == LtOper);

    if (LEN_PLIST(data) < i) {
        GROW_PLIST(data, i);
        SET_LEN_PLIST(data, i);
    }

    while (i > 1) {
        Obj parent = ELM_PLIST(data, i >> 1);
        if (useLt) {
            if (0 == LT(parent, elm))
                break;
        }
        else {
            if (False == CALL_2ARGS(isLess, parent, elm))
                break;
        }
        SET_ELM_PLIST(data, i, parent);
        i >>= 1;
    }

    SET_ELM_PLIST(data, i, elm);
    CHANGED_BAG(data);
}

// "Bubble down" helper used for extraction: Given a heap <data> (represented
// by a GAP plist), and a comparison operation <isLess>, start with a "hole"
// or "bubble" at position <i>, and push it down through the heap.
static Int DS_BinaryHeap_BubbleDown(Obj data, Obj isLess, Int i)
{
    const Int useLt = (isLess == LtOper);
    const Int len = LEN_PLIST(data);

    while (2 * i <= len) {
        // get positions of the children of <i>
        Int left = 2 * i;
        Int right = 2 * i + 1;

        // if there is no right child, move the left child up
        // and exit
        if (right > len) {
            SET_ELM_PLIST(data, i, ELM_PLIST(data, left));
            i = left;
            break;    // next iteration would stop anyway
        }

        // otherwise, compare left and right child, and move the larger one up
        Obj leftObj = ELM_PLIST(data, left);
        Obj rightObj = ELM_PLIST(data, right);
        if (useLt ? LT(rightObj, leftObj)
                  : (True == CALL_2ARGS(isLess, rightObj, leftObj))) {
            SET_ELM_PLIST(data, i, leftObj);
            i = left;
        }
        else {
            SET_ELM_PLIST(data, i, rightObj);
            i = right;
        }
    }

    return i;
}

static Obj FuncDS_BinaryHeap_Insert(Obj self, Obj heap, Obj elm)
{
    Obj data = DS_BINARYHEAP_DATA(heap);
    Obj isLess = DS_BINARYHEAP_ISLESS(heap);

    if (!IS_DENSE_PLIST(data))
        ErrorQuit("<data> is not a dense plist", 0L, 0L);

    Int len = LEN_PLIST(data);
    if (len == 0) {
        AssPlist(data, 1, elm);
        RetypeBag(data, T_PLIST_DENSE);
    }
    else {
        DS_BinaryHeap_BubbleUp(data, isLess, len + 1, elm);
    }
    return 0;
}

static Obj FuncDS_BinaryHeap_ReplaceMax(Obj self, Obj heap, Obj elm)
{
    Obj data = DS_BINARYHEAP_DATA(heap);
    Obj isLess = DS_BINARYHEAP_ISLESS(heap);

    if (!IS_DENSE_PLIST(data))
        ErrorQuit("<data> is not a dense plist", 0L, 0L);

    // treat the head slot as a hole that we move down into a leaf
    Int i = DS_BinaryHeap_BubbleDown(data, isLess, 1);

    // insert the new element into the leaf-hole and move it up
    DS_BinaryHeap_BubbleUp(data, isLess, i, elm);

    return 0;
}

static StructGVarFunc GVarFuncs[] = {
    GVAR_FUNC_2ARGS(DS_BinaryHeap_Insert, heap, elm),
    GVAR_FUNC_2ARGS(DS_BinaryHeap_ReplaceMax, heap, elm),
    { 0 }
};

static Int InitKernel(void)
{
    InitHdlrFuncsFromTable(GVarFuncs);
    return 0;
}

static Int InitLibrary(void)
{
    InitGVarFuncsFromTable(GVarFuncs);
    return 0;
}

struct DatastructuresModule BinaryHeapModule = {
    .initKernel = InitKernel, .initLibrary = InitLibrary,
};
