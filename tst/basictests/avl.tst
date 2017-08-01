gap> START_TEST("datastructures package: avl.tst");

#
gap> n := 10000;;
gap> t := DS_AVLTree();;
gap> valList := EmptyPlist(n);;
gap> valSet := EmptyPlist(n);;
gap> missingSet := Set([]);;
gap> for i in [1..n] do
>    repeat
>        x := Random(-10000000,10000000);
>    until not(x in valSet);
>    Add(valList,x);
>    AddSet(valSet,x);
> od;
gap> for i in [1..n] do
>    repeat
>        x := Random(-10000000,10000000);
>    until not(x in valSet) and not(x in missingSet);
>    AddSet(missingSet, x);
> od;
gap> for i in [1..n] do
>    DS_AVLAdd(t,valList[i],i);
> od;
gap> List([1..n], i -> DS_AVLLookup(t, valList[i])) = [1..n];
true
gap> ForAll([1..n], i -> DS_AVLLookup(t, missingSet[i]) = fail);
true
gap> List([1..n], i -> DS_AVLValue(t, DS_AVLFind(t, valList[i]))) = [1..n];
true
gap> ForAll([1..n], i -> DS_AVLFind(t, missingSet[i]) = fail);
true
gap> lll := List([1..n], i -> DS_AVLIndexLookup(t, i));;
gap> lll = List(valSet, x -> Position(valList, x));
true
gap> llll := EmptyPlist(n);;
gap> for i in [n,n-1..1] do
>    llll[i] := DS_AVLIndex(t,i);
> od;;
gap> llll = valSet;
true
gap> for i in [1..n] do
>    DS_AVLDelete(t,valList[i]);
>    DS_AVLAdd(t,valList[i],i);
> od;
gap> DS_AVLTest(t).ok;
true
gap> ss := DS_AVLToList(t);;
gap> List(ss, x -> x[1]) = valSet;
true

#
gap> STOP_TEST( "datastructures package: avl.tst", 10000);
