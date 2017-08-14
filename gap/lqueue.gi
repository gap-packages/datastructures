# lqueue.gi

# This file implements double ended queues (deques) using a circular buffer
# stored in a GAP plain list.
#
# The four positions in a queue Q have the following purpose
#
# Q[1] - head, the index in Q[4] of the first element in the queue
# Q[2] - tail, the index in Q[4] of the last element in the queue
# Q[3] - capacity, the allocated capacity in the queue
# Q[4] - GAP plain list with storage for capacity many entries
#
# Global variables QHEAD, QTAIL, QCAPACITY, and QDATA are bound to reflect
# the above.
#
# When a push fills the queue, its capacity is doubled using PlistQueueExpand.
# A new empty plist is allocated and all current entries of the queue are copied
# into the new plist with the head entry at index 1.
#
# The queue is empty if and only if head = tail and the entry that head and tail
# point to in the storage list is unbound.

InstallGlobalFunction(PlistQueue,
function(arg)
    local capacity, factor, result;

    if Length(arg) >= 3 then
        ErrorNoReturn("usage: PlistQueue( [ <capacity>, [ <factor> ] ])");
    fi;

    capacity := 64;
    factor := 2;

    if Length(arg) >= 1 then
        if not IsPosInt(arg[1]) then
            ErrorNoReturn("<capacity> must be a positive integer");
        fi;
        capacity := arg[1];
    fi;
    if Length(arg) >= 2 then
        if not IsRat(arg[2]) or (arg[2] <= 1) then
            ErrorNoReturn("<factor> must be a rational greater than 1");
        fi;
        factor := arg[2];
    fi;

    result := [1, 1, capacity, factor, EmptyPlist(capacity)];
    Objectify(PlistQueueType, result);

    return result;
end);

InstallGlobalFunction(PlistQueuePushBack,
function(queue, item)
    local head, tail, last;

    if item = fail then
        ErrorNoReturn("<item> must not equal 'fail'");
    fi;

    head := queue![QHEAD];
    tail := queue![QTAIL];
    last := queue![QCAPACITY];

    # Special case for empty queue,
    # head = tail and queue![QDATA][tail] is
    # not bound
    if not IsBound(queue![QDATA][tail]) then
        queue![QDATA][tail] := item;
    else
        if tail = last then
            tail := 1;
        else
            tail := tail + 1;
        fi;
        queue![QDATA][tail] := item;
        queue![QTAIL] := tail;

        # If queue is full expand
        if ((head = 1) and (tail = last))
           or (tail + 1 = head) then
            PlistQueueExpand(queue);
        fi;
    fi;
end);

InstallGlobalFunction(PlistQueuePushFront,
function(queue, item)
    local head, tail, last;

    if item = fail then
        ErrorNoReturn("<item> must not equal 'fail'");
    fi;

    head := queue![QHEAD];
    tail := queue![QTAIL];
    last := queue![QCAPACITY];

    # If the queue is empty
    if not IsBound(queue![QDATA][head]) then
        queue![QDATA][head] := item;
    else
        if head = 1 then
            head := last;
        else
            head := head - 1;
        fi;
        queue![QDATA][head] := item;
        queue![QHEAD] := head;

        if (head = 1 and tail = last)
           or (tail + 1 = head) then
            PlistQueueExpand(queue);
        fi;
    fi;
end);

InstallGlobalFunction(PlistQueuePopFront,
function(queue)
    local head, tail, last, result;

    if IsEmpty(queue) then
        return fail;
    fi;

    head := queue![QHEAD];
    tail := queue![QTAIL];
    last := queue![QCAPACITY];

    result := queue![QDATA][head];
    Unbind(queue![QDATA][head]);
    if head <> tail then
        if head = last then
            head := 1;
        else
            head := head + 1;
        fi;
        queue![QHEAD] := head;
    fi;

    return result;
end);

InstallGlobalFunction(PlistQueuePopBack,
function(queue)
    local head, tail, last, result;

    if IsEmpty(queue) then
        return fail;
    fi;

    head := queue![QHEAD];
    tail := queue![QTAIL];
    last := queue![QCAPACITY];

    result := queue![QDATA][tail];
    Unbind(queue![QDATA][tail]);

    if head <> tail then
        if tail = 1 then
            tail := last;
        else
            tail := tail - 1;
        fi;
        queue![QTAIL] := tail;
    fi;

    return result;
end);

InstallGlobalFunction(PlistQueuePeekFront,
function(queue)
    if IsEmpty(queue) then
        return fail;
    fi;
    return queue![QDATA][queue![QHEAD]];
end);

InstallGlobalFunction(PlistQueuePeekBack,
function(queue)
    if IsEmpty(queue) then
        return fail;
    fi;
    return queue![QDATA][queue![QTAIL]];
end);

InstallGlobalFunction(PlistQueueExpand,
function(queue)
    local result, p, head, tail, last, factor;
    head := queue![QHEAD];
    tail := queue![QTAIL];
    last := queue![QCAPACITY];
    factor := queue![QFACTOR];

    queue![QCAPACITY] := Int(factor * last);
    if queue![QCAPACITY] = last then
       # TODO: Maybe display a warning here
       #       might require introducing an
       #       InfoClass
       queue![QCAPACITY] := last + 5;
    fi; 
    result := EmptyPlist(queue![QCAPACITY]);

    # Copy data into new list.
    p := 1;
    while head <> tail do
        result[p] := queue![QDATA][head];
        p := p + 1;
        head := head + 1;
        if head > last then
            head := 1;
        fi;
    od;
    result[p] := queue![QDATA][head];

    queue![QHEAD] := 1;
    queue![QTAIL] := p;
    queue![QDATA] := result;
end);

## method installation

InstallMethod(PushBack,
        "for IsPlistQueue and an object",
        [IsPlistQueueRep, IsObject],
        PlistQueuePushBack);

InstallMethod(PushFront,
        "for IsPlistQueue and an object",
        [IsPlistQueueRep, IsObject],
        PlistQueuePushFront);

InstallMethod(Push,
        "for IsPlistQueue and an object",
        [IsPlistQueueRep, IsObject],
        PlistQueuePushBack);

InstallMethod(PopFront,
        "for IsPlistQueue and an object",
        [IsPlistQueueRep],
        PlistQueuePopFront);

InstallMethod(PopBack,
        "for IsPlistQueue and an object",
        [IsPlistQueueRep],
        PlistQueuePopBack);

InstallMethod(Pop,
        "for IsPlistQueue and an object",
        [IsPlistQueueRep],
        PlistQueuePopFront);

InstallOtherMethod(IsEmpty,
        "for IsPlistQueue",
        [IsPlistQueueRep],
function(queue)
    local head;
    head := queue![QHEAD];
    return not IsBound(queue![QDATA][head]);
end);

InstallOtherMethod(Size,
        "for IsPlistQueue",
        [IsPlistQueueRep],
function(queue)
    local head, tail;
    head := queue![QHEAD];
    tail := queue![QTAIL];

    if not IsBound(queue![QDATA][head]) then
        return 0;
    else
        if tail >= head then
            return tail - head + 1;
        else
            return Capacity(queue) - (head - tail) + 1;
        fi;
    fi;
end);

InstallMethod(Capacity,
        "for IsPlistQueue",
        [IsPlistQueueRep],
function(queue)
    return queue![QCAPACITY];
end);

InstallMethod( ViewObj,
        "for a PlistQueue",
        [ IsPlistQueueRep ],
function(queue)
    Print("<queue with ");
    Print(Size(queue),"/",Capacity(queue));
    Print(" entries>");
end);
