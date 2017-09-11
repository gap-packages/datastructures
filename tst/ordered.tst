gap> ReadPackage("datastructures","tst/ordered.g");
true
gap> osdstest(1000,IsSkipListRep);
true
gap> osdstest(1000, IsAVLTreeRep);
true
gap> osdstestordered(1000,IsSkipListRep);
true
gap> osdstestordered(1000, IsAVLTreeRep);
true
gap> SKIPLISTS.ScanSkipList := SKIPLISTS.ScanSkipListGAP;;
gap> SKIPLISTS.RemoveNode := SKIPLISTS.RemoveNodeGAP;;
gap> AVL.Find := AVL.FindGAP;;
gap> AVL.AddSetInner := AVL.AddSetInnerGAP;;
gap> AVL.RemoveSetInner := AVL.RemoveSetInnerGAP;;
gap> osdstest(1000,IsSkipListRep);
true
gap> osdstest(1000, IsAVLTreeRep);
true
gap> osdstestordered(1000,IsSkipListRep);
true
gap> osdstestordered(1000, IsAVLTreeRep);
true
gap> SKIPLISTS.ScanSkipList := DS_Skiplist_Scan;;
gap> SKIPLISTS.RemoveNode := DS_Skiplist_RemoveNode;;
gap> AVL.Find := DS_AVL_FIND;;
gap> AVL.AddSetInner := DS_AVL_ADDSET_INNER;;
gap> AVL.RemoveSetInner := DS_AVL_REMSET_INNER;;
gap> s := OrderedSetDS(IsAVLTreeRep,[1..100]);
<avl tree size 100>
gap> Print(s,"\n");
OrderedSetDS(IsAVLTreeRep, [ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15\
, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, \
35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54\
, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, \
74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 91, 92, 93\
, 94, 95, 96, 97, 98, 99, 100 ])
gap> Display(s);
<50: 100 b <25> <75>> 
<25: 49 b <12> <37>> <75: 50 b <62> <88>> 
<12: 24 b <6> <18>> <37: 24 b <31> <43>> <62: 24 b <56> <68>> 
  <88: 25 b <81> <94>> 
<6: 11 b <3> <9>> <18: 12 b <15> <21>> <31: 11 b <28> <34>> 
  <43: 12 b <40> <46>> <56: 11 b <53> <59>> <68: 12 b <65> <71>> 
  <81: 12 b <78> <84>> <94: 12 b <91> <97>> 
<3: 5 b <1> <4>> <9: 5 b <7> <10>> <15: 5 b <13> <16>> <21: 6 b <19> <23>> 
  <28: 5 b <26> <29>> <34: 5 b <32> <35>> <40: 5 b <38> <41>> 
  <46: 6 b <44> <48>> <53: 5 b <51> <54>> <59: 5 b <57> <60>> 
  <65: 5 b <63> <66>> <71: 6 b <69> <73>> <78: 5 b <76> <79>> 
  <84: 6 b <82> <86>> <91: 5 b <89> <92>> <97: 6 b <95> <99>> 
<1: 2 r . <2>> <4: 2 r (3) <5>> <7: 2 r (6) <8>> <10: 2 r (9) <11>> 
  <13: 2 r (12) <14>> <16: 2 r (15) <17>> <19: 2 r (18) <20>> 
  <23: 3 b <22> <24>> <26: 2 r (25) <27>> <29: 2 r (28) <30>> 
  <32: 2 r (31) <33>> <35: 2 r (34) <36>> <38: 2 r (37) <39>> 
  <41: 2 r (40) <42>> <44: 2 r (43) <45>> <48: 3 b <47> <49>> 
  <51: 2 r (50) <52>> <54: 2 r (53) <55>> <57: 2 r (56) <58>> 
  <60: 2 r (59) <61>> <63: 2 r (62) <64>> <66: 2 r (65) <67>> 
  <69: 2 r (68) <70>> <73: 3 b <72> <74>> <76: 2 r (75) <77>> 
  <79: 2 r (78) <80>> <82: 2 r (81) <83>> <86: 3 b <85> <87>> 
  <89: 2 r (88) <90>> <92: 2 r (91) <93>> <95: 2 r (94) <96>> 
  <99: 3 b <98> <100>> 
<2: 1 b (1) (3)> <5: 1 b (4) (6)> <8: 1 b (7) (9)> <11: 1 b (10) (12)> 
  <14: 1 b (13) (15)> <17: 1 b (16) (18)> <20: 1 b (19) (21)> 
  <22: 1 b (21) (23)> <24: 1 b (23) (25)> <27: 1 b (26) (28)> 
  <30: 1 b (29) (31)> <33: 1 b (32) (34)> <36: 1 b (35) (37)> 
  <39: 1 b (38) (40)> <42: 1 b (41) (43)> <45: 1 b (44) (46)> 
  <47: 1 b (46) (48)> <49: 1 b (48) (50)> <52: 1 b (51) (53)> 
  <55: 1 b (54) (56)> <58: 1 b (57) (59)> <61: 1 b (60) (62)> 
  <64: 1 b (63) (65)> <67: 1 b (66) (68)> <70: 1 b (69) (71)> 
  <72: 1 b (71) (73)> <74: 1 b (73) (75)> <77: 1 b (76) (78)> 
  <80: 1 b (79) (81)> <83: 1 b (82) (84)> <85: 1 b (84) (86)> 
  <87: 1 b (86) (88)> <90: 1 b (89) (91)> <93: 1 b (92) (94)> 
  <96: 1 b (95) (97)> <98: 1 b (97) (99)> <100: 1 b (99) .> 
gap> AVL.AVLCheck(s);
gap> AVL.Height(s);
7
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
gap> AddSet(s2, 101/2);;
gap> 101/2 in s;
false
gap> AsList(s);
[ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 
  22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 
  41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 
  60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 
  79, 80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 91, 92, 93, 94, 95, 96, 97, 
  98, 99, 100 ]
gap> s := OrderedSetDS(IsAVLTreeRep, [1..100]);
<avl tree size 100>
gap> i := Iterator(s);
<Iterator of AVL tree>
gap> i2 := ShallowCopy(i);;
gap> NextIterator(i) = NextIterator(i2);
true
gap> s2 := ShallowCopy(s);;
gap> IsAVLTreeRep(s2);
true
gap> Size(s) = Size(s2);
true
gap> AddSet(s2, 101/2);;
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
gap> a := OrderedSetDS(IsAVLTreeRep, function(a, b) return a[1] > b[1]; end);;
gap> Print(a,"\n");
OrderedSetDS(IsAVLTreeRep, function ( a, b ) return a[1] > b[1]; end)
gap> AddSet(a,[1,2]);;
gap> Print(a,"\n");
OrderedSetDS(IsAVLTreeRep, function ( a, b ) return a[1] > b[1]; end, [ [ 1, 2\
 ] ])
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
gap> osdstestconstruct(IsAVLTreeRep);
true

# TODO test more constructors
