gap> q := PlistDeque(1000);
<deque with 0/1000 entries>
gap> q := PlistDeque(1000, "haar");
Error, <factor> must be a rational greater than 1
gap> q := PlistDeque((1,2,3));
Error, <capacity> must be a positive integer
gap> q := PlistDeque(1,2,3,4,5);
Error, usage: PlistDeque( [ <capacity>, [ <factor> ] ])
gap> q := PlistDeque();
<deque with 0/64 entries>
gap> PlistDequePushFront(q, fail);
Error, <item> must not equal 'fail'
gap> PlistDequePushBack(q, fail);
Error, <item> must not equal 'fail'

#
gap> PlistDequePeekFront(q);
fail
gap> PlistDequePeekBack(q);
fail
gap> PlistDequePopBack(q);
fail
gap> PlistDequePopFront(q);
fail
gap> PlistDequePushFront(q, 15);
gap> PlistDequePeekFront(q);
15
gap> PlistDequePeekBack(q);
15
gap> PlistDequePushBack(q,"haar");
gap> PlistDequePeekBack(q);
"haar"
gap> PlistDequePopBack(q);
"haar"
gap> PlistDequePeekBack(q);
15
gap> PlistDequePopFront(q);
15
gap> PlistDequePushBack(q, 15);
gap> PlistDequePopBack(q);
15
gap> IsEmpty(q);
true

# test size, make sure it is bigger than
# initial capacity so that expansion happens
gap> N := 1000;;
gap> q := PlistDeque(QuoInt(N, 3));;

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

# do some alternating front/back pushes/pops
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
gap> q := PlistDeque(10, 3/2);
<deque with 0/10 entries>
gap> for i in [1..10] do PushBack(q, i); od;;
gap> q;
<deque with 10/15 entries>
gap> for i in [11..20] do PushBack(q, i); od;;
gap> q;
<deque with 20/22 entries>
gap> for i in [21..30] do PushBack(q, i); od;;
gap> q;
<deque with 30/33 entries>
gap> out := [];; r := PopFront(q);; while r <> fail do Add(out, r); r := PopFront(q); od;;
gap> out = [1..30];
true
gap> q := PlistDeque(1, 11/10);
<deque with 0/1 entries>
gap> PushBack(q, 1);
gap> q;
<deque with 1/1 entries>
gap> PushBack(q, 1);
gap> q;
<deque with 1/6 entries>
gap> PlistDequePeekBack(q);
1
gap> PlistDequePeekFront(q);
1
