gap> START_TEST("stack.tst");

# Generate some test data
gap> l := List([1..1000], x -> Random([-10000..10000]));;

# Make a stack
gap> s := Stack();
<stack with 0 entries>

# Push
gap> for i in l do Push(s, i); od;
gap> Size(s);
1000
gap> s;
<stack with 1000 entries>

# Pop
gap> l2 := List([1..1000], x -> Pop(s));;
gap> l2 = Reversed(l);
true

# Pop
gap> Pop(s);
fail
gap> Peek(s);
fail

# Push & Peek
gap> Push(s, 15);
gap> Peek(s);
15
gap> Size(s);
1

#
gap> STOP_TEST("stack.tst", 1);
