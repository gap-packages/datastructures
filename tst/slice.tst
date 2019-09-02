gap> START_TEST("slice.tst");
gap> LoadPackage("datastructures", false);
true
gap> x := [1,5,3,2,4,6,4,3];;
gap> s := Slice(x, 3, 3);
<slice size=3>
gap> List(s);
[ 3, 2, 4 ]
gap> Length(s);
3
gap> 2 in s;
true
gap> 1 in s;
false
gap> ViewString(s);
"<slice size=3>"
gap> s[0];
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 1st choice method found for `[]' on 2 arguments
gap> s[1];
3
gap> s[2];
2
gap> s[3];
4
gap> s[4];
Error, Cannot access element 4 of a range with 3 elements
gap> IsBound(s[1]);
true
gap> IsBound(s[2]);
true
gap> IsBound(s[4]);
false
gap> Unbind(s[2]);
gap> IsBound(s[2]);
false
gap> 6 in s;
false
gap> 1 in s;
false
gap> s[1] := 9;
9
gap> s[5] := 9;
Error, Cannot access element 5 of a range with 3 elements
gap> List(s);
[ 9,, 4 ]
gap> List(x);
[ 1, 5, 9,, 4, 6, 4, 3 ]
gap> s := Slice(x, 3, 0);
<slice size=0>
gap> Length(s);
0
gap> List(s);
[  ]
gap> s[1];
Error, Cannot access element 1 of a range with 0 elements
gap> s := Slice(x, 1, 1);
<slice size=1>
gap> s[0];
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 1st choice method found for `[]' on 2 arguments
gap> s[1];
1
gap> s[2];
Error, Cannot access element 2 of a range with 1 elements
gap> x:= [1,5,3,2,4,,4,3];;
gap> s:= Slice( x, 2, 6 );
<slice size=6>
gap> Slice( s, 2, 4 );
<slice size=4>
gap> STOP_TEST( "slice.tst" );
