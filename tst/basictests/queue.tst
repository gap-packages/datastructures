#############################################################################
##
#W  queue.tst
#Y  Copyright (C) 2014                               Markus Pfeiffer
##
##  Licensing information can be found in the README file of this package.
##
#############################################################################
##
gap> START_TEST("datastructures package: queue.tst");
gap> LoadPackage( "datastructures", false );;
gap> q := PlistQueue();
<queue with 0/64 entries>
gap> PushFront(q, 15);
gap> PopFront(q);
15
gap> PushBack(q, 15);
gap> PopBack(q);
15
gap> Push(q, 15);
gap> Pop(q);
15
gap> for i in [1..32] do
>       PushFront(q,i);
> od;
gap> for i in [1..32] do
>       Print(PopBack(q)," ");
> od; Print("\n");
1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32
gap> for i in [1..32] do
>       PushFront(q,i);
> od;
gap> for i in [1..32] do
>       Print(PopFront(q)," ");
> od; Print("\n");
32 31 30 29 28 27 26 25 24 23 22 21 20 19 18 17 16 15 14 13 12 11 10 9 8 7 6 5 4 3 2 1
gap> STOP_TEST( "datastructures package: queue.tst", 10000);
