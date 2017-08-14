gap> q := PlistQueue(1000);
<queue with 0/1000 entries>
gap> q := PlistQueue(1000, "haar");
Error, <factor> must be a rational greater than 1
gap> q := PlistQueue((1,2,3));
Error, <capacity> must be a positive integer
gap> q := PlistQueue(1,2,3,4,5);
Error, usage: PlistQueue( [ <capacity>, [ <factor> ] ])
gap> q := PlistQueue();
<queue with 0/64 entries>
gap> PlistQueuePushFront(q, fail);
Error, <item> must not equal 'fail'
gap> PlistQueuePushBack(q, fail);
Error, <item> must not equal 'fail'

#
gap> PlistQueuePeekFront(q);
fail
gap> PlistQueuePeekBack(q);
fail
gap> PlistQueuePopBack(q);
fail
gap> PlistQueuePopFront(q);
fail
gap> PlistQueuePushFront(q, 15);
gap> PlistQueuePeekFront(q);
15
gap> PlistQueuePeekBack(q);
15
gap> PlistQueuePushBack(q,"haar");
gap> PlistQueuePeekBack(q);
"haar"
gap> PlistQueuePopBack(q);
"haar"
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
gap> N := 1000;;
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

# Test Resizing factor
gap> q := PlistQueue(10, 3/2);
<queue with 0/10 entries>
gap> for i in [1..10] do PushBack(q, i); od;;
gap> q;
<queue with 10/15 entries>
gap> for i in [11..20] do PushBack(q, i); od;;
gap> q;
<queue with 20/22 entries>
gap> for i in [21..30] do PushBack(q, i); od;;
gap> q;
<queue with 30/33 entries>
gap> out := [];; r := PopFront(q);; while r <> fail do Add(out, r); r := PopFront(q); od;;
gap> out = [1..30];
true
gap> q := PlistQueue(1, 11/10);
<queue with 0/1 entries>
gap> PushBack(q, 1);
gap> q;
<queue with 1/1 entries>
gap> PushBack(q, 1);
gap> q;
<queue with 1/6 entries>
gap> PlistQueuePeekBack(q);
1
gap> PlistQueuePeekFront(q);
1


