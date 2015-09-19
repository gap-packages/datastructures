gap> LoadPackage("data", false);
true
gap> n := 10000;;
gap> t := AVLTree();;
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
>    AVLAdd(t,valList[i],i);
> od;
gap> List([1..n], i -> AVLLookup(t, valList[i])) = [1..n];
true
gap> ForAll([1..n], i -> AVLLookup(t, missingSet[i]) = fail);
true
gap> List([1..n], i -> AVLValue(t, AVLFind(t, valList[i]))) = [1..n];
true
gap> ForAll([1..n], i -> AVLFind(t, missingSet[i]) = fail);
true
gap> lll := List([1..n], i -> AVLIndexLookup(t, i));;
gap> lll = List(valSet, x -> Position(valList, x));
true
gap> llll := EmptyPlist(n);;
gap> for i in [n,n-1..1] do
>    llll[i] := AVLIndex(t,i);
> od;;
gap> llll = valSet;
true
gap> for i in [1..n] do
>    AVLDelete(t,valList[i]);
>    AVLAdd(t,valList[i],i);
> od;
gap> AVLTest(t).ok;
true
gap> ss := AVLToList(t);;
gap> List(ss, x -> x[1]) = valSet;
true
