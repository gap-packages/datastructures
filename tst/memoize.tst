#
gap> func := function(x) Print("Check:",x,"\n"); return x*x; end;;
gap> f1 := MemoizeFunction(func);;
gap> f1(1);
Check:1
1
gap> f1(2);
Check:2
4
gap> f1(2);
4
gap> f1(6);
Check:6
36

#
gap> func := function(args...) Print("Check:",args,"\n"); return args; end;;
gap> f1 := MemoizeFunction(func);;
gap> f1(1);
Check:[ 1 ]
[ 1 ]
gap> f1(1);
[ 1 ]
gap> f1((1,2,3),(2,3,4));
Check:[ (1,2,3), (2,3,4) ]
[ (1,2,3), (2,3,4) ]
gap> f1(2,3,4);
Check:[ 2, 3, 4 ]
[ 2, 3, 4 ]
gap> f1(1);
[ 1 ]

#
gap> func := function(x) Print("Check:",x,"\n"); return x in SymmetricGroup(15); end;;
gap> f1 := MemoizeFunction(func, rec( contract := IsPerm, errorHandler := function(args...) Error("Not a permutation"); end ) );;
gap> f1(1);
Error, Not a permutation
gap> f1((1,2,3));
Check:(1,2,3)
true
gap> f1((1,2,3,16));
Check:( 1, 2, 3,16)
false
gap> f1((1,2,3));
true

#
gap> func := function(x) Print("Check:",x,"\n"); return x in SymmetricGroup(15); end;;
gap> f1 := MemoizeFunction(func, rec( contract := IsPerm, errorHandler := function(args...) return "follow"; end ) );;
gap> f1(1);
"follow"
gap> f1((1,2,3));
Check:(1,2,3)
true
gap> f1((1,2,3,16));
Check:( 1, 2, 3,16)
false
gap> f1((1,2,3));
true

#
gap> func := function(x) Print("Check:",x,"\n"); return x in SymmetricGroup(15); end;;
gap> f1 := MemoizeFunction(func, rec( contract := IsPerm, errorHandler := function(args...) Print("follow\n"); end ) );;
gap> f1(1);
follow
gap> f1((1,2,3));
Check:(1,2,3)
true
gap> f1((1,2,3,16));
Check:( 1, 2, 3,16)
false
gap> f1((1,2,3));
true

#
