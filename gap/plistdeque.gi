##
##  Datastructures: GAP package providing common datastructures.
##
##  Copyright (C) 2015-2017  The datastructures team.
##  For list of the team members, please refer to the COPYRIGHT file.
##
##  This package is licensed under the GPL 2 or later, please refer
##  to the COPYRIGHT.md and LICENSE files for details.
##

# This file implements double ended queues (deques) using a circular buffer
# stored in a GAP plain list.
#
# The four positions in a deque Q have the following purpose
#
# Q[1] - head, the index in Q[4] of the first element in the deque
# Q[2] - tail, the index in Q[4] of the last element in the deque
# Q[3] - capacity, the allocated capacity in the deque
# Q[4] - factor by which storage is resized if capacity is exceeded
# Q[5] - GAP plain list with storage for capacity many entries
#
# Global constants QHEAD, QTAIL, QCAPACITY, QFACTOR, and QDATA are bound to
# reflect the above.
#
# When a push fills the deque, its capacity is resized by QFACTO R using
# PlistDequeExpand. A new empty plist is allocated and all current entries of
# the deque are copied into the new plist with the head entry at index 1.
#
# The deque is empty if and only if head = tail and the entry that head and tail
# point to in the storage list is unbound.

InstallGlobalFunction(PlistDeque,
function(arg)
    local capacity, factor, result;

    if Length(arg) >= 3 then
        ErrorNoReturn("usage: PlistDeque( [ <capacity>, [ <factor> ] ])");
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
    Objectify(PlistDequeType, result);

    return result;
end);

InstallGlobalFunction(PlistDequePushBack,
function(deque, item)
    local head, tail, last;

    if item = fail then
        ErrorNoReturn("<item> must not equal 'fail'");
    fi;

    head := deque![QHEAD];
    tail := deque![QTAIL];
    last := deque![QCAPACITY];

    # Special case for empty deque,
    # head = tail and deque![QDATA][tail] is
    # not bound
    if not IsBound(deque![QDATA][tail]) then
        deque![QDATA][tail] := item;
    else
        if tail = last then
            tail := 1;
        else
            tail := tail + 1;
        fi;
        deque![QDATA][tail] := item;
        deque![QTAIL] := tail;

        # If deque is full expand
        if ((head = 1) and (tail = last))
           or (tail + 1 = head) then
            PlistDequeExpand(deque);
        fi;
    fi;
end);

InstallGlobalFunction(PlistDequePushFront,
function(deque, item)
    local head, tail, last;

    if item = fail then
        ErrorNoReturn("<item> must not equal 'fail'");
    fi;

    head := deque![QHEAD];
    tail := deque![QTAIL];
    last := deque![QCAPACITY];

    # If the deque is empty
    if not IsBound(deque![QDATA][head]) then
        deque![QDATA][head] := item;
    else
        if head = 1 then
            head := last;
        else
            head := head - 1;
        fi;
        deque![QDATA][head] := item;
        deque![QHEAD] := head;

        if (head = 1 and tail = last)
           or (tail + 1 = head) then
            PlistDequeExpand(deque);
        fi;
    fi;
end);

InstallGlobalFunction(PlistDequePopFront,
function(deque)
    local head, tail, last, result;

    if IsEmpty(deque) then
        return fail;
    fi;

    head := deque![QHEAD];
    tail := deque![QTAIL];
    last := deque![QCAPACITY];

    result := deque![QDATA][head];
    Unbind(deque![QDATA][head]);
    if head <> tail then
        if head = last then
            head := 1;
        else
            head := head + 1;
        fi;
        deque![QHEAD] := head;
    fi;

    return result;
end);

InstallGlobalFunction(PlistDequePopBack,
function(deque)
    local head, tail, last, result;

    if IsEmpty(deque) then
        return fail;
    fi;

    head := deque![QHEAD];
    tail := deque![QTAIL];
    last := deque![QCAPACITY];

    result := deque![QDATA][tail];
    Unbind(deque![QDATA][tail]);

    if head <> tail then
        if tail = 1 then
            tail := last;
        else
            tail := tail - 1;
        fi;
        deque![QTAIL] := tail;
    fi;

    return result;
end);

InstallGlobalFunction(PlistDequePeekFront,
function(deque)
    if IsEmpty(deque) then
        return fail;
    fi;
    return deque![QDATA][deque![QHEAD]];
end);

InstallGlobalFunction(PlistDequePeekBack,
function(deque)
    if IsEmpty(deque) then
        return fail;
    fi;
    return deque![QDATA][deque![QTAIL]];
end);

InstallGlobalFunction(PlistDequeExpand,
function(deque)
    local result, p, head, tail, last, factor;
    head := deque![QHEAD];
    tail := deque![QTAIL];
    last := deque![QCAPACITY];
    factor := deque![QFACTOR];

    deque![QCAPACITY] := Int(factor * last);
    if deque![QCAPACITY] = last then
       # TODO: Maybe display a warning here
       #       might require introducing an
       #       InfoClass
       deque![QCAPACITY] := last + 5;
    fi; 
    result := EmptyPlist(deque![QCAPACITY]);

    # Copy data into new list.
    p := 1;
    while head <> tail do
        result[p] := deque![QDATA][head];
        p := p + 1;
        head := head + 1;
        if head > last then
            head := 1;
        fi;
    od;
    result[p] := deque![QDATA][head];

    deque![QHEAD] := 1;
    deque![QTAIL] := p;
    deque![QDATA] := result;
end);

## method installation

InstallMethod(PushBack,
        "for IsPlistDeque and an object",
        [IsPlistDequeRep, IsObject],
        PlistDequePushBack);

InstallMethod(PushFront,
        "for IsPlistDeque and an object",
        [IsPlistDequeRep, IsObject],
        PlistDequePushFront);

InstallMethod(PopFront,
        "for IsPlistDeque and an object",
        [IsPlistDequeRep],
        PlistDequePopFront);

InstallMethod(PopBack,
        "for IsPlistDeque and an object",
        [IsPlistDequeRep],
        PlistDequePopBack);

InstallOtherMethod(IsEmpty,
        "for IsPlistDeque",
        [IsPlistDequeRep],
function(deque)
    local head;
    head := deque![QHEAD];
    return not IsBound(deque![QDATA][head]);
end);

InstallOtherMethod(Size,
        "for IsPlistDeque",
        [IsPlistDequeRep],
function(deque)
    local head, tail;
    head := deque![QHEAD];
    tail := deque![QTAIL];

    if not IsBound(deque![QDATA][head]) then
        return 0;
    else
        if tail >= head then
            return tail - head + 1;
        else
            return Capacity(deque) - (head - tail) + 1;
        fi;
    fi;
end);

InstallMethod(Capacity,
        "for IsPlistDeque",
        [IsPlistDequeRep],
function(deque)
    return deque![QCAPACITY];
end);

InstallMethod( ViewString,
        "for a PlistDeque",
        [ IsPlistDequeRep ],
function(deque)
    return STRINGIFY("<deque with "
                    , Size(deque), "/", Capacity(deque)
                    , " entries>");
end);
