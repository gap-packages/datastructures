
InstallGlobalFunction(TestHeap,
function(con, order)
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
    ord := ShallowCopy(data);
    Sort(ord, order);
    ord := Reversed(ord);

    # Make a heap that just uses \< and has no data

    Print("Creating heap\n");
    heap := con(order);

    Print("Adding some random data\n");
    for d in data do
        Push(heap, d);
    od;
    Assert(0, Peek(heap) = ord[1]);

    Print("After adding ", nrelts, " elements heap has size ", Size(heap), "\n");
    if Size(heap) <> nrelts then
        Error("Heap does not have the correct size.");
    fi;

    Print("Popping all data out of heap\n");
    extract := [];
    while not IsEmpty(heap) do
        Add(extract, Pop(heap));
    od;

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
    heap := con(order);

    Push(heap, true);
    Push(heap, false);
    Assert(0, Size(heap) = 2);

    obj := Peek(heap);
    Assert(0, obj in [true, false]);
    Assert(0, Pop(heap) = obj);
    Assert(0, Size(heap) = 1);

    obj := Peek(heap);
    Assert(0, obj in [true, false]);
    Assert(0, Pop(heap) = obj);
    Assert(0, Size(heap) = 0);

    Assert(0, Peek(heap) = fail);
    Assert(0, Pop(heap) = fail);
    Assert(0, Size(heap) = 0);

    Print("Tests end.\n");
end);
