gap> START_TEST("uf.tst");

##########################################
#
# Test the union-find data structure
#
#
gap> u := PartitionDS(IsPartitionDS,10);
<union find 10 parts on 10 points>
gap> NumberParts(u);
10
gap> SizeUnderlyingSetDS(u);
10
gap> PartsOfPartitionDS(u);
[ [ 1 ], [ 2 ], [ 3 ], [ 4 ], [ 5 ], [ 6 ], [ 7 ], [ 8 ], [ 9 ], [ 10 ] ]
gap> u = u;
true
gap> Representative(u,7);
7
gap> u2 := ShallowCopy(u);
<union find 10 parts on 10 points>
gap> u = u2;
false
gap> Unite(u,1,2);
gap> NumberParts(u);
9
gap> NumberParts(u2);
10
gap> PartsOfPartitionDS(u);
[ [ 1, 2 ], [ 3 ], [ 4 ], [ 5 ], [ 6 ], [ 7 ], [ 8 ], [ 9 ], [ 10 ] ]
gap> Representative(u,2);
2
gap> Representative(u,1);
2
gap> Unite(u,1,3);
gap> u;
<union find 8 parts on 10 points>
gap> Print(u,"\n");
PartitionDS( IsPartitionDS, [ [ 1, 2, 3 ], [ 4 ], [ 5 ], [ 6 ], [ 7 ], [ 8 ], \
[ 9 ], [ 10 ] ])
gap> PartitionDS( IsPartitionDS, [ [ 1, 2, 3 ], [ 4 ], [ 5 ], [ 6 ], [ 7 ], [ 8 ], 
> [ 9 ], [ 10 ] ]);
<union find 8 parts on 10 points>
gap> i := RootsIteratorOfPartitionDS(u);
<iterator of <union find 8 parts on 10 points>>
gap> IsDoneIterator(i);
false
gap> NextIterator(i);
2
gap> i2 := ShallowCopy(i);
<iterator of <union find 8 parts on 10 points>>
gap> for x in i do Print(x,"\n"); od;
4
5
6
7
8
9
10
gap> for x in i2 do Print(x,"\n"); od;
4
5
6
7
8
9
10
gap> UF.RepresentativeTarjan(u,3);
2
gap> UF.UniteGAP(u,4,5);
gap> u;
<union find 7 parts on 10 points>
gap> PartitionDS(IsPartitionDS,[[2,1]]);
Error, PartitionDS: supplied partition must be a list of disjoint sets of posi\
tive integers
gap> PartitionDS(IsPartitionDS,[[-2,1]]);
Error, PartitionDS: supplied partition must be a list of disjoint sets of posi\
tive integers
gap> PartitionDS(IsPartitionDS,[[1,2,3],[3,4,5]]);
Error, PartitionDS: supplied partition must be a list of disjoint sets of posi\
tive integers
gap> u := PartitionDS(IsPartitionDS, 16);
<union find 16 parts on 16 points>
gap> for i in [1,3..15] do Unite(u,i, i+1); od;
gap> for i in [1,5..13] do Unite(u,i, i+2); od;
gap> for i in [1,9] do Unite(u,i, i+4); od;
gap> Unite(u,1,9);
gap> Representative(u,1);
16
gap> Representative(u,15);
16
gap> u := PartitionDS(IsPartitionDS, 16);
<union find 16 parts on 16 points>
gap> for i in [1,3..15] do UF.UniteGAP(u,i, i+1); od;
gap> for i in [1,5..13] do UF.UniteGAP(u,i, i+2); od;
gap> for i in [1,9] do UF.UniteGAP(u,i, i+4); od;
gap> UF.UniteGAP(u,1,9);
gap> UF.RepresentativeTarjan(u,1);
16
gap> UF.RepresentativeTarjan(u,15);
16
gap> u := PartitionDS(IsPartitionDS, 16);;
gap> Unite(u,1,2);
gap> Unite(u,2,3);
gap> Unite(u,4,2);
gap> Unite(u,5,5);
gap> UF.UniteGAP(u,9,10);
gap> UF.UniteGAP(u,10,11);
gap> UF.UniteGAP(u,12,10);
gap> UF.UniteGAP(u,9,12);
gap> PartsOfPartitionDS(u);
[ [ 1, 2, 3, 4 ], [ 5 ], [ 6 ], [ 7 ], [ 8 ], [ 9, 10, 11, 12 ], [ 13 ], 
  [ 14 ], [ 15 ], [ 16 ] ]

#
gap> STOP_TEST( "uf.tst", 1);
