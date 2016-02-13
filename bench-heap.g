LoadPackage("datastructures");

# Tests for the heap implementation.
# TODO: Rewrite using the UnitTests package

PCQL_Heap_Create:=function(vals)
    local h, x;
    h := PairingHeap();
    for x in vals do
        # We use -x as key because we want find/remove MAX but
        # datastructures provides find/remove MIN.
        PairingHeapPush(h,-x,x);
    od;
    return h;
end;

PCQL_Heap_IsValid := ReturnTrue;

PCQL_Heap_FindMax := heap -> PairingHeapPeek(heap)[2];

PCQL_Heap_RemoveMax := heap -> PairingHeapPop(heap)[2];

PCQL_Heap_IsEmpty := heap -> heap![1] = 0;

PCQL_Heap_Length := heap -> heap![1];

fails := 0;
successes := 0;

TestHeap := function(vals)
    local heap, x, i;
    Print("Testing heap code with ", Length(vals), " elements\n");
    heap := PCQL_Heap_Create(vals);
    if not PCQL_Heap_IsValid(heap) then
        fails := fails + 1;
        Print("  FAILURE: newly created heap is invalid\n");
        return;
    fi;

    Sort(vals, function(a,b) return a>b; end);
    for i in [1..Length(vals)] do
        x := PCQL_Heap_FindMax(heap);
        if x <> vals[i] then
            fails := fails + 1;
            Print("  FAILURE in FindMax at sorted position ", i,
                " (expected ", vals[i], " but got ", x, ")\n");
            return;
        fi;
        x := PCQL_Heap_RemoveMax(heap);
        if x <> vals[i] then
            fails := fails + 1;
            Print("  FAILURE in RemoveMax at sorted position ", i,
                " (expected ", vals[i], " but got ", x, ")\n");
            return;
        fi;
        if not PCQL_Heap_IsValid(heap) then
            fails := fails + 1;
            Print("  FAILURE: heap invalid\n");
            return;
        fi;
    od;
    if not PCQL_Heap_IsEmpty(heap) then
        fails := fails + 1;
        Print("  FAILURE: heap should be empty but isn't\n");
        return;
    fi;
    successes := successes + 1;
end;

#TestHeap( [ 17, 3, 5 ] );

TestHeap( [] );

for n in [1..20] do
    vals := List([1..n], i -> Random([1..50]));
    TestHeap(vals);
od;

Print("Of ", fails + successes, " tests, ", fails, " failed and ", successes, " succeeded.\n");

GASMAN("collect");
GASMAN("collect");

RunHeapTests := function(len)
    local vals, t, heap, i, x;

    vals := List([1..len], i -> Random([1..2^27]));;
    t := Runtime();;
    heap := PCQL_Heap_Create(vals);;
    Print("Creating heap: ", (Runtime() - t)/1000.0, " seconds\n");
    
    if PCQL_Heap_Length(heap) <> Length(vals) then
        Error("wrong length");
    fi;

    t := Runtime();;
    Sort(vals, function(a,b) return a>b; end);
    Print("Sorting plist: ", (Runtime() - t)/1000.0, " seconds\n");

    t := Runtime();;
    for i in [1..Length(vals)] do
        x := PCQL_Heap_RemoveMax(heap);
        if x <> vals[i] then
            Error("oops");
        fi;
    od;
    Print("Reading heap: ", (Runtime() - t)/1000.0, " seconds\n");
end;

#if false then
#PCQL_Heap_Insert:=_PCQL_Heap_Insert_GAP;
#PCQL_Heap_ReplaceMax:=_PCQL_Heap_ReplaceMax_GAP;
#PCQL_Heap_Insert:=_PCQL_Heap_Insert_C;
#PCQL_Heap_ReplaceMax:=_PCQL_Heap_ReplaceMax_C;

RunHeapTests(2^20);
#fi;
