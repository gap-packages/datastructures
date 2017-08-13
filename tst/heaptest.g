# This helper function uses the function <constructor> passed to it to
# create a heap and then runs some basic tests on it, such as inserting
# a number of elements and checking that the same elements can be popped
# off in the same order.
TestHeap := function(constructor)
    local TestRemove, TestConstructorVariants,
          nrelts, range, data;

    # Given a heap that is supposed to contain <data>, verify that the
    # heap produce the correct output when popping off data. Note: This
    # test assumes that <data> does not contain 'fail'.
    TestRemove := function(heap, data, order)
        local extract, obj_peek, obj_pop, bad;
        if Size(heap) <> Size(data) then
            Error("Heap does not have the correct size.");
        fi;

        data := ShallowCopy(data);
        Sort(data, {x,y} -> order(y,x));

        extract := [];
        while not IsEmpty(heap) do
            obj_peek := Peek(heap);
            obj_pop := Pop(heap);
            if obj_peek <> obj_pop then
                Error("Peek and Pop disagree");
            fi;
            Add(extract, obj_pop);
        od;
        Assert(0, Peek(heap) = fail);
        Assert(0, Pop(heap) = fail);

        if Size(extract) <> Size(data) then
            Error("Heap produced ", Size(extract), " elements, expected ", Size(data));
        fi;

        if extract <> data then
            bad := First([1..Length(data)], i->extract[i] <> data[i]);
            Error("Heap gave bad output, first mismatch at position ",
                bad, ": got ", extract[bad], " but expected ", data[bad]);
        fi;

    end;

    TestConstructorVariants := function(data)
        local heap, d, rev_order;

        rev_order := {x,y} -> x > y;

        # test default constructor
        heap := constructor();
        for d in data do
            Push(heap, d);
        od;
        TestRemove(heap, data, \<);

        # test constructor with initial data
        heap := constructor(data);
        TestRemove(heap, data, \<);

        # test constructor with custom order
        heap := constructor(rev_order);
        for d in data do
            Push(heap, d);
        od;
        TestRemove(heap, data, rev_order);

        # test constructor with initial data and custom order
        heap := constructor(rev_order, data);
        TestRemove(heap, data, rev_order);
    end;

    # Test with a bunch of random integers
    nrelts := 10000;
    range := [-nrelts..nrelts];
    data := List([1..nrelts], x -> Random(range));
    TestConstructorVariants(data);

    # Now test booleans
    TestConstructorVariants([true, false]);
    TestConstructorVariants([true, false, true, false, true]);

    # Test with a bunch of strings
    data := IDENTS_GVAR();
    data := data{[200..1000]};
    TestConstructorVariants(data);
end;
