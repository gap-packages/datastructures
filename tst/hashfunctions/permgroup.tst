gap> ReadPackage("datastructures", "tst/hashfunctions/hashtestfuncs.g");;
gap> cHash := function(x,y) 
> compareHashes(x, y, Hash_PermGroup_Complete);
> compareHashes(x, y, Hash_PermGroup_Fast, "weakhash");
> end;;
gap> clean := {G} -> Group(GeneratorsOfGroup(G), ());;
gap> cHash([Group([()]),Group((1,2)),Group((1,2,3))],[SymmetricGroup(1), SymmetricGroup(2), CyclicGroup(IsPermGroup, 3)]);
gap> groups := List([2..20], SymmetricGroup);;
gap> cHash(groups, List(groups, clean));
gap> groups := List([2..20], AlternatingGroup);;
gap> cHash(groups, List(groups, clean));
gap> groups := AllPrimitiveGroups(NrMovedPoints, [2..10]);;
gap> cHash(groups, List(groups, clean));
