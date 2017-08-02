
InstallGlobalFunction(TestHeap,
function(con)
    local d, heap
          , data, ord
          , extract
          , range
          , compare
          , obj
          , nrelts;
    nrelts := 10000;
    range := [-nrelts..nrelts];

    data := List([1..nrelts], x -> Random(range));
    # we expect heaps to be max-heaps
    ord := Reversed(SortedList(data));

    # Make a heap that just uses \< and has no data

    Print("Creating Heap\n");
    heap := con();

    Print("Adding some random data\n");
    for d in data do
        Push(heap, d);
    od;

    Print("After adding ", nrelts, " elements heap has size ", Size(heap), "\n");
    if Size(heap) <> nrelts then
        Error("Heap does not have the correct size.");
    fi;

    Print("Popping all data out of heap\n");
    extract := List([1..nrelts], x -> Pop(heap));

    if Size(heap) <> 0 then
        Error("Heap did not have correct size after popping all data off");
    fi;

    if Position(extract, fail) <> fail then
        Error("Extraction of elements failed\n");
    fi;

    if extract <> ord then
        Error("The data did not come out of the heap in the correct order");
    fi;

    Print("Trying to put booleans into heap\n");
    heap := con();
    Push(heap, true);
    Push(heap, false);
    Pop(heap);
    Pop(heap);

    Print("Creating Heap With Comparison\n");
    compare := function(a,b) return a[15] > b[15]; end; 
   
    range := [-100, 100];
    for d in [1..nrelts] do
       obj := [];
       obj[15] := Random(range);
       Push(heap, obj);
    od;
 
    Print("After adding ", nrelts, " elements heap has size ", Size(heap), "\n");
    if Size(heap) <> nrelts then
        Error("Heap does not have the correct size.");
    fi;

    Print("Tests end.");
end);
