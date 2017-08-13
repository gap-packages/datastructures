gap> q := PlistQueue(1000);
<queue with 0/1000 entries>
gap> q := PlistQueue(1000, "mist");
Error, usage: PlistQueue( [ <capacity> ])
gap> q := PlistQueue((1,2,3));
Error, <capacity> must be a positive integer
gap> q := PlistQueue();
<queue with 0/64 entries>
gap> PlistQueuePushFront(q, fail);
Error, <item> must not equal 'fail'
gap> PlistQueuePushBack(q, fail);
Error, <item> must not equal 'fail'

#
gap> PlistQueuePushFront(q, 15);
gap> PlistQueuePeekFront(q);
15
gap> PlistQueuePeekBack(q);
15
gap> PlistQueuePushBack(q,"mist");
gap> PlistQueuePeekBack(q);
"mist"
gap> PlistQueuePopBack(q);
"mist"
gap> PlistQueuePeekBack(q);
15
gap> PlistQueuePopFront(q);
15
gap> PlistQueuePushBack(q, 15);
gap> PlistQueuePopBack(q);
15
gap> Push(q, 15);
gap> Pop(q);
15
gap> IsEmpty(q);
true

# test size, make sure it is bigger than
# initial capacity so that expansion happens
gap> N:=1000;;
gap> q := PlistQueue(QuoInt(N, 3));;

# add at the front, pop at the back
gap> for i in [1..N] do PushFront(q,i); od;
gap> IsEmpty(q);
false
gap> Size(q) = N;
true
gap> out := List([1..N], x -> PopBack(q));;
gap> out = [1..N];
true
gap> IsEmpty(q);
true

# add at the front, pop at the front
gap> for i in [1..N] do PushFront(q,i); od;
gap> IsEmpty(q);
false
gap> Size(q) = N;
true
gap> out := List([1..N], x -> PopFront(q));;
gap> out = [N,N-1..1];
true
gap> IsEmpty(q);
true

# add at the back, pop at the front
gap> for i in [1..N] do PushBack(q,i); od;
gap> IsEmpty(q);
false
gap> Size(q) = N;
true
gap> out := List([1..N], x -> PopFront(q));;
gap> out = [1..N];
true
gap> IsEmpty(q);
true

# add at the back, pop at the back
gap> for i in [1..N] do PushBack(q,i); od;
gap> IsEmpty(q);
false
gap> Size(q) = N;
true
gap> out := List([1..N], x -> PopBack(q));;
gap> out = [N,N-1..1];
true
gap> IsEmpty(q);
true


# do some alternating fron/back pushes/pops
gap> for i in [1..N] do PushBack(q,i); od;
gap> for i in [1..QuoInt(N, 2)] do PushFront(q,i); od;
gap> out1 := List([1..QuoInt(N, 3)], x -> PopBack(q));;
gap> out2 := List([1..QuoInt(N, 3)], x -> PopFront(q));;
gap> for i in [1..N] do PushBack(q,i);; od;
gap> out3 := List([1..QuoInt(N, 3)], x -> PopFront(q));;
gap> while not IsEmpty(q) do PopFront(q); od;
gap> out1 = [N,N-1..N - QuoInt(N, 3) + 1];
true