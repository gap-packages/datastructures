/*
 * Datastructures: GAP package providing common datastructures.
 * Licensed under the GPL 2 or later.
 */

#include "binaryheap.h"

static UInt s_isLess_RNam = 0;  // FIXME: init these
static UInt s_data_RNam = 0;      // FIXME: init these


static void _BinaryHeap_BubbleUp_C(Obj data, Obj isLess, Int i, Obj elm)
{
    if ( LEN_PLIST( data ) < i ) {
        GROW_PLIST( data, i );
        SET_LEN_PLIST( data, i );
        CHANGED_BAG( data );
    }

    while (i > 1) {
        Obj parent = ELM_PLIST(data, i >> 1);
        if (False == CALL_2ARGS(isLess, parent, elm))
            break;
        SET_ELM_PLIST( data, i, parent );
        CHANGED_BAG( data );
        i >>= 1;
    }

    SET_ELM_PLIST( data, i, elm );
    CHANGED_BAG( data );
}

static Int _BinaryHeap_BubbleDown_C(Obj data, Obj isLess, Int i, Obj elm)
{
    Int len = LEN_PLIST(data);
    while (2 * i <= len) {
        Int left = 2 * i;
        Int right = 2 * i + 1;
        if (right > len || True == CALL_2ARGS(isLess, ELM_PLIST(data, right), ELM_PLIST(data, left))) {
            SET_ELM_PLIST( data, i, ELM_PLIST(data, left) );
            i = left;
        } else {
            SET_ELM_PLIST( data, i, ELM_PLIST(data, right) );
            i = right;
        }
        CHANGED_BAG( data );
    }

    return i;
}

Obj _BinaryHeap_Insert_C(Obj self, Obj heap, Obj elm)
{
    Obj data = ElmPRec(heap, s_data_RNam);
    Obj isLess = ElmPRec(heap, s_isLess_RNam);

    if (!IS_DENSE_PLIST(data))
        ErrorQuit("<data> is not a dense plist", 0L, 0L);

    Int len = LEN_PLIST(data);
    if (len == 0)
        AssPlistEmpty(data, 1, elm);
        // FIXME: or should we really use AssPlist ??
    else
        _BinaryHeap_BubbleUp_C(data, isLess, len + 1, elm);

    return 0;
}

/*
TODO: implement efficient _BinaryHeap_Create_C which runs in O(n) instead
of the native "insert elements using _BinaryHeap_Insert_C" which runs in
O(n*log(n))

Wikipedia:

Build-Max-Heap[4] (A):
 heap_length[A] <- length[A]
   for i <- floor(length[A]/2) downto 1 do
    Max-Heapify(A, i)

from GAP kernel's HEAP_SORT_PLIST:

  UInt len = LEN_LIST(list);
  UInt i;
  for (i = (len/2); i > 0 ; i--)
    BubbleDown(list, i, len);

*/

/* TODO: implement own alternative to HEAP_SORT_PLIST


And while at it:

SORT_LIST
SortDensePlist
SORT_LISTComp
SortDensePlistComp
SORT_PARA_LIST
SortParaDensePlistPara
SORT_PARA_LISTComp
SortParaDensePlistComp

But PLEASE not by doing lots of copy & paste! Either we (ab)use the preprocessor,
or use a C++ template.


*/

Obj _BinaryHeap_ReplaceMax_C(Obj self, Obj heap, Obj elm)
{
    Obj data = ElmPRec(heap, s_data_RNam);
    Obj isLess = ElmPRec(heap, s_isLess_RNam);

    if (!IS_DENSE_PLIST(data))
        ErrorQuit("<data> is not a dense plist", 0L, 0L);

    // treat the head slot as a hole that we move down into a leaf
    Int i = _BinaryHeap_BubbleDown_C(data, isLess, 1, elm);

    // insert the new element into the leaf-hole and move it up
    _BinaryHeap_BubbleUp_C(data, isLess, i, elm);

    // TODO
    return 0;
}


static StructGVarFunc GVarFuncs [] = {
    GVAR_FUNC_TABLE_ENTRY("binaryheap.c", _BinaryHeap_Insert_C, 2, "heap, elm"),
    GVAR_FUNC_TABLE_ENTRY("binaryheap.c", _BinaryHeap_ReplaceMax_C, 2, "heap, elm"),
    { 0 }
};

static Int InitKernel(void)
{
    InitHdlrFuncsFromTable(GVarFuncs);
    return 0;
}

static Int PostRestore( void )
{
    s_isLess_RNam = RNamName("isLess");
    s_data_RNam = RNamName("data");

    return 0;
}

static Int InitLibrary(void)
{
    InitGVarFuncsFromTable(GVarFuncs);
    
    // make sure PostRestore() is always run when we are loaded
    return PostRestore();
}

struct DatastructuresModule BinaryHeapModule = {
    .initKernel  = InitKernel,
    .initLibrary = InitLibrary,
    .postRestore = PostRestore,
};
