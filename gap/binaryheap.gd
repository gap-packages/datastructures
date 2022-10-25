##
##  Datastructures: GAP package providing common datastructures.
##
##  Copyright (C) 2015-2017  The datastructures team.
##  For list of the team members, please refer to the COPYRIGHT file.
##
##  This package is licensed under the GPL 2 or later, please refer
##  to the COPYRIGHT.md and LICENSE files for details.
##

#! @Chapter Heaps
#!
#! @Section Binary Heaps
#! @SectionLabel BinaryHeap
#!
#! A binary heap employs a binary tree as its underlying tree datastructure.
#! The implemenataion of binary heaps in <Package>datastructures</Package> stores
#! this tree in a flat array which makes it a very good and fast default choice for
#! general purpose use. In particular, even though other heap implementations have
#! better theoretical runtime bounds, well-tuned binary heaps outperform them
#! in many applications.
#!
#! For some reference see <URL>http://stackoverflow.com/questions/6531543</URL>

#! @Description
#! Constructor for binary heaps. The optional argument <A>isLess</A> must be a binary function
#! that performs comparison between two elements on the heap, and returns <K>true</K> if the first
#! argument is less than the second, and <K>false</K> otherwise.
#! Using the optional argument <A>data</A> the user can give a collection of initial values that
#! are pushed on the stack after construction.
#! @Arguments [isLess, [data]]
#! @Returns A binary heap
DeclareGlobalFunction("BinaryHeap");

#! @Section Declarations
DeclareRepresentation( "IsBinaryHeapFlatRep", IsHeap and IsPositionalObjectRep, []);
BindGlobal( "BinaryHeapType", NewType(HeapFamily, IsBinaryHeapFlatRep and IsMutable));


