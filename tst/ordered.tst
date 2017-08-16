gap> ReadPackage("datastructures","tst/ordered.g");
true
gap> osdstest(1000,IsSkipListRep);
true
gap> osdstest(1000, IsBinarySearchTreeRep);
true
gap> osdstest(1000, IsAVLTree);
true
gap> osdstestordered(1000,IsSkipListRep);
true
gap> osdstestordered(100, IsBinarySearchTreeRep);
true
gap> osdstestordered(1000, IsAVLTree);
true
gap> SKIPLISTS.ScanSkipList := SKIPLISTS.ScanSkipListGAP;;
gap> SKIPLISTS.RemoveNode := SKIPLISTS.RemoveNodeGAP;;
gap> BSTS.BSTFind := BSTS.BSTFindGAP;;
gap> AVL.AddSetInner := AVL.AddSetInnerGAP;;
gap> AVL.RemoveSetInner := AVL.RemoveSetInnerGAP;;
gap> osdstest(1000,IsSkipListRep);
true
gap> osdstest(1000, IsBinarySearchTreeRep);
true
gap> osdstest(1000, IsAVLTree);
true
gap> osdstestordered(1000,IsSkipListRep);
true
gap> osdstestordered(100, IsBinarySearchTreeRep);
true
gap> osdstestordered(1000, IsAVLTree);
true
gap> SKIPLISTS.ScanSkipList := DS_Skiplist_Scan;;
gap> SKIPLISTS.RemoveNode := DS_Skiplist_RemoveNode;;
gap> BSTS.BSTFind := DS_BST_FIND;;
gap> AVL.AddSetInner := DS_AVL_ADDSET_INNER;;
gap> AVL.RemoveSetInner := DS_AVL_REMSET_INNER;;
gap> s := OrderedSetDS(IsAVLTree,[1..100]);
<avl tree size 100>
gap> Print(s,"\n");
OrderedSetDS(IsAVLTree, [ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 1\
6, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35,\
 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 5\
5, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74,\
 75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 91, 92, 93, 9\
4, 95, 96, 97, 98, 99, 100 ])
gap> Display(s);
OrderedSetDS(IsAVLTree, [ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 1\
6, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35,\
 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 5\
5, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74,\
 75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 91, 92, 93, 9\
4, 95, 96, 97, 98, 99, 100 ])
gap> AVL.AVLCheck(s);
gap> BSTS.BSTHeight(s);
7
gap> BSTS.CheckSize(s);
true
gap> BSTS.BSTImbalance(s);
1
gap> rs := RandomSource(IsMersenneTwister,1);;
gap> s := OrderedSetDS(IsSkipListRep, [1..100], rs);
<skiplist 100 entries>
gap> Print(s,"\n");
OrderedSetDS(IsSkipListRep, [ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 1\
5, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34,\
 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 5\
4, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73,\
 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 91, 92, 9\
3, 94, 95, 96, 97, 98, 99, 100 ])
gap> Display(s);
->33->67->X
->33->67->X
->33->57->67->68->X
->11->13->14->26->32->33->37->38->56->57->64->67->68->80->87->88->100->X
->5->11->12->13->14->16->22->25->26->28->29->32->33->35->37->38->40->45->50->5\
6->57->59->62->64->66->67->68->71->74->80->81->86->87->88->91->92->96->98->100\
->X
->1->2->3->4->5->6->7->8->9->10->11->12->13->14->15->16->17->18->19->20->21->2\
2->23->24->25->26->27->28->29->30->31->32->33->34->35->36->37->38->39->40->41-\
>42->43->44->45->46->47->48->49->50->51->52->53->54->55->56->57->58->59->60->6\
1->62->63->64->65->66->67->68->69->70->71->72->73->74->75->76->77->78->79->80-\
>81->82->83->84->85->86->87->88->89->90->91->92->93->94->95->96->97->98->99->1\
00->X
gap> SKIPLISTS.CheckSize(s);
true
gap> i := Iterator(s);
Iterator of Skiplist
gap> i2 := ShallowCopy(i);;
gap> NextIterator(i) = NextIterator(i2);
true
gap> s2 := ShallowCopy(s);;
gap> Size(s) = Size(s2);
true
gap> AddSet(s2, 101/2);
gap> 101/2 in s;
false
gap> AsList(s);
[ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 
  22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 
  41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 
  60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 
  79, 80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 91, 92, 93, 94, 95, 96, 97, 
  98, 99, 100 ]
gap> s := OrderedSetDS(IsBinarySearchTreeRep, [1..100]);
<bst size 100>
gap> i := Iterator(s);
<Iterator of BST>
gap> i2 := ShallowCopy(i);;
gap> NextIterator(i) = NextIterator(i2);
true
gap> s2 := ShallowCopy(s);;
gap> Size(s) = Size(s2);
true
gap> AddSet(s2, 101/2);
gap> 101/2 in s;
false
gap> AsList(s);
[ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 
  22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 
  41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 
  60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 
  79, 80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 91, 92, 93, 94, 95, 96, 97, 
  98, 99, 100 ]
gap> s := OrderedSetDS(IsAVLTree, [1..100]);
<avl tree size 100>
gap> i := Iterator(s);
<Iterator of BST>
gap> i2 := ShallowCopy(i);;
gap> NextIterator(i) = NextIterator(i2);
true
gap> s2 := ShallowCopy(s);;
gap> IsAVLTree(s2);
true
gap> Size(s) = Size(s2);
true
gap> AddSet(s2, 101/2);
gap> 101/2 in s;
false
gap> AsList(s);
[ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 
  22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 
  41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 
  60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 
  79, 80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 91, 92, 93, 94, 95, 96, 97, 
  98, 99, 100 ]
gap> s := OrderedSetDS(IsSkipListRep);;
gap> Display(s); Print("\n");
<empty skiplist>
gap> s := OrderedSetDS(IsBinarySearchTreeRep);;
gap> Print(s,"\n");
OrderedSetDS(IsBinarySearchTreeRep)
gap> AddSet(s, (1,2,3));
gap> Print(s,"\n");
OrderedSetDS(IsBinarySearchTreeRep, [ (1,2,3) ])
gap> s := OrderedSetDS(IsBinarySearchTreeRep);;
gap> AddSet(s,1); AddSet(s,2); AddSet(s, 3);
gap> AVL.ExtendBSTtoAVLTree(s);
Error, Not an AVL tree
gap> b := OrderedSetDS(IsBinarySearchTreeRep, function(a, b) return a[1] > b[1]; end);;
gap> Print(b,"\n");
OrderedSetDS(IsBinarySearchTreeRep, function ( a, b ) return a[1] > b[1]; end)
gap> AddSet(b,[1,2]);;
gap> Print(b,"\n");
OrderedSetDS(IsBinarySearchTreeRep, function ( a, b ) return a[1] > b[1]; end,\
 [ [ 1, 2 ] ])
gap> a := OrderedSetDS(IsAVLTree, function(a, b) return a[1] > b[1]; end);;
gap> Print(a,"\n");
OrderedSetDS(IsAVLTree, function ( a, b ) return a[1] > b[1]; end)
gap> AddSet(a,[1,2]);;
gap> Print(a,"\n");
OrderedSetDS(IsAVLTree, function ( a, b ) return a[1] > b[1]; end, [ [ 1, 2 ] \
])
gap> s := OrderedSetDS(IsSkipListRep, function(a, b) return a[1] > b[1]; end);;
gap> Print(s,"\n");
OrderedSetDS(IsSkipListRep, function ( a, b ) return a[1] > b[1]; end)
gap> AddSet(s,[1,2]);;
gap> Print(s,"\n");
OrderedSetDS(IsSkipListRep, function ( a, b ) return a[1] > b[1]; end, [ [ 1, \
2 ] ])
gap> s := OrderedSetDS( IsSkipListRep );;
gap> SetSkipListParameter(s,2);;
gap> l1 := [1..100];; l2 := [100,99..1];;
gap> osdsworkout(s,l1,l2);
true
gap> osdstestconstruct(IsSkipListRep);
true
gap> osdstestconstruct(IsBinarySearchTreeRep);
true
gap> osdstestconstruct(IsAVLTree);
true
gap> Print(OrderedSetDS(IsBinarySearchTreeRep, MakeImmutable([4,3,2,1])),"\n");
OrderedSetDS(IsBinarySearchTreeRep, [ 1, 2, 3, 4 ])

# TODO test more constructors
