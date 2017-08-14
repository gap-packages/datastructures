gap> q := PlistQueue();
<queue with 0/64 entries>

#
gap> PushFront(q, 15);
gap> PopFront(q);
15
gap> PushBack(q, 15);
gap> PopBack(q);
15
gap> Push(q, 15);
gap> Pop(q);
15
gap> IsEmpty(q);
true

# test size
gap> N:=32;;

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
