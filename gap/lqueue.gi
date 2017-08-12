# lqueue.gi

# Create a Queue based on a Plist.
# Head points to head
# Tail points to tail
#

InstallGlobalFunction(PlistQueue,
function(arg)
  local capacity, filter, result, i, t;

  filter := IsPlistQueueRep;

  if Length(arg) = 0 then
    capacity := 64;
  elif Length(arg) = 1 then
    capacity := arg[1];
  fi;

  result := [1, 1, capacity, EmptyPlist(capacity)];
  t := NewType(CollectionsFamily(FamilyObj(IsObject)),
               filter and IsMutable and IsPositionalObjectRep);

  Objectify(t, result);

  return result;
end);

InstallGlobalFunction(PlistQueuePushBack,
 function(queue,el)
  local head, tail, last;
  head := queue![QHEAD];
  tail := queue![QTAIL];
  last := queue![QCAPACITY];

  # Special case for empty queue,
  # head = tail and queue![QDATA][tail] is
  # not bound
  if not IsBound(queue![QDATA][tail]) then
      queue![QDATA][tail] := el;
  else
      if tail = last then
          tail := 1;
      else
          tail := tail + 1;
      fi;
      queue![QDATA][tail] := el;
      queue![QTAIL] := tail;

      # If queue is full expand
      if ((head = 1) and (tail = last))
         or (tail + 1 = head) then
          PlistQueueExpand(queue);
      fi;
  fi;
end);

InstallGlobalFunction(PlistQueuePushFront,
function(queue, el)
  local head, tail, last;
  head := queue![QHEAD];
  tail := queue![QTAIL];
  last := queue![QCAPACITY];

  if not IsBound(queue![QDATA][head]) then
      queue![QDATA][head] := el;
  else
      if head = 1 then
          head := last;
      else
          head := head - 1;
      fi;
      queue![QDATA][head] := el;
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
  head := queue![QHEAD];
  tail := queue![QTAIL];
  last := queue![QCAPACITY];

  # TODO: What if someone wants to store fails?
  result := fail;

  if IsBound(queue![QDATA][head]) then
      result := queue![QDATA][head];
      Unbind(queue![QDATA][head]);
      if head <> tail then
          if head = last then
              head := 1;
          else
              head := head + 1;
          fi;
      fi;
      queue![QHEAD] := head;
  fi;
  return result;
end);

InstallGlobalFunction(PlistQueuePopBack,
function(queue)
  local head, tail, last, result;
  head := queue![QHEAD];
  tail := queue![QTAIL];
  last := queue![QCAPACITY];

  result := fail;

  if IsBound(queue![QDATA][tail]) then
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
  fi;
  return result;
end);

InstallGlobalFunction(PlistQueueExpand,
function(queue)
  local result, p, head, tail, last;
  head := queue![QHEAD];
  tail := queue![QTAIL];
  last := queue![QCAPACITY];

  # We double the capacity
  # The increase could be a parameter
  # of the queue
  queue![QCAPACITY] := 2 * last;
  result := EmptyPlist(2 * last);

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

########################################################################
##
## method installation
##
InstallMethod(NewQueue_,
        "for IsPlistQueueRep, a sample object, and a positive integer",
        [IsPlistQueueRep, IsObject, IsPosInt],
function(filter, sample, capacity)
  return PlistQueue(capacity);
end);

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

InstallMethod( PrintObj,
        "for a PlistQueue",
        [ IsPlistQueueRep ],
function(queue)
  Print("<queue with ");
  Print(Size(queue),"/",Capacity(queue));
  Print(" entries: \n");
  Print(queue![QDATA]);
  Print(">");
end);

