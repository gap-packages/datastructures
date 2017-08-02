/*
 * Datastructures: GAP package providing common datastructures.
 * Licensed under the GPL 2 or later.
 *
 * Implementation of a binary heap.
 *
 * Binary heaps are of course pretty standard data structures.
 * However, a few design choices are possible. The implementation
 * below has been influenced by this StackOverflow answer:
 *   <https://stackoverflow.com/questions/6531543>
 */

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
// _BinaryHeap_Insert_C(), <i> will be equal to the length of <data> plus 1.
// But in _BinaryHeap_ReplaceMax_C(), it can be less than that.
static void _BinaryHeap_BubbleUp_C(Obj data, Obj isLess, Int i, Obj elm)
{
    if (LEN_PLIST(data) < i) {
        GROW_PLIST(data, i);
        SET_LEN_PLIST(data, i);
    }

    while (i > 1) {
        Obj parent = ELM_PLIST(data, i >> 1);
        if (False == CALL_2ARGS(isLess, parent, elm))
            break;
        SET_ELM_PLIST(data, i, parent);
        i >>= 1;
    }

    SET_ELM_PLIST(data, i, elm);
    CHANGED_BAG(data);
}

// "Bubble down" helper used for extraction: Given a heap <data> (represented
// by a GAP plist), and a comparison operation <isLess>, start with a "hole"
// or "bubble" at position <i>, and push it down through the heap.
static Int _BinaryHeap_BubbleDown_C(Obj data, Obj isLess, Int i)
{
    Int len = LEN_PLIST(data);
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
        if (True == CALL_2ARGS(isLess, rightObj, leftObj)) {
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

Obj _BinaryHeap_Insert_C(Obj self, Obj heap, Obj elm)
{
    Obj data = DS_BINARYHEAP_DATA(heap);
    Obj isLess = DS_BINARYHEAP_ISLESS(heap);

    if (!IS_DENSE_PLIST(data))
        ErrorQuit("<data> is not a dense plist", 0L, 0L);

    Int len = LEN_PLIST(data);
    if (len == 0) {
        AssPlist(data, 1, elm);
        RetypeBag(data, T_PLIST_DENSE);
    } else {
        _BinaryHeap_BubbleUp_C(data, isLess, len + 1, elm);
    }
    return 0;
}

Obj _BinaryHeap_ReplaceMax_C(Obj self, Obj heap, Obj elm)
{
    Obj data = DS_BINARYHEAP_DATA(heap);
    Obj isLess = DS_BINARYHEAP_ISLESS(heap);

    if (!IS_DENSE_PLIST(data))
        ErrorQuit("<data> is not a dense plist", 0L, 0L);

    // treat the head slot as a hole that we move down into a leaf
    Int i = _BinaryHeap_BubbleDown_C(data, isLess, 1);

    // insert the new element into the leaf-hole and move it up
    _BinaryHeap_BubbleUp_C(data, isLess, i, elm);

    return 0;
}

static StructGVarFunc GVarFuncs[] = {
    GVARFUNC(
        "binaryheap.c", _BinaryHeap_Insert_C, 2, "heap, elm"),
    GVARFUNC(
        "binaryheap.c", _BinaryHeap_ReplaceMax_C, 2, "heap, elm"),
    { 0 }
};

static Int InitKernel(void)
{
    InitHdlrFuncsFromTable(GVarFuncs);
    return 0;
}

static Int PostRestore(void)
{
    return 0;
}

static Int InitLibrary(void)
{
    InitGVarFuncsFromTable(GVarFuncs);

    // make sure PostRestore() is always run when we are loaded
    return PostRestore();
}

struct DatastructuresModule BinaryHeapModule = {
    .initKernel = InitKernel,
    .initLibrary = InitLibrary,
    .postRestore = PostRestore,
};
