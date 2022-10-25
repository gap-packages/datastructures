##
##  Datastructures: GAP package providing common datastructures.
##
##  Copyright (C) 2015-2018 The datastructures team.
##  For list of the team members, please refer to the COPYRIGHT file.
##
##  This package is licensed under the GPL 2 or later, please refer
##  to the COPYRIGHT.md and LICENSE files for details.
##

#! @Chapter Union-Find
#!
#! @Section Introduction
#! <Package>datastructures</Package> defines the interface for mutable data structures
#! representing partitions of <C>[1..n]</C>, commonly known as union-find data structures.
#! Key operations are
#! <Ref Oper="Unite" Label="for IsPartitionDS and IsMutable, IsPosInt, IsPosInt"/>
#! which fuses two parts of a partition and
#! <Ref Oper="Representative" Label="for IsPartitionDS, IsPosInt"/> which
#! returns a canonical representative of the part containing a given point.
#!

#! @Section API
#! @Description
#! Category of datastructures representing partitions.
#! Equality is identity and family is ignored.
DeclareCategory("IsPartitionDS", IsObject);

#! @Description
#! Family containing all partition data structures
BindGlobal("PartitionDSFamily", NewFamily(IsPartitionDS));

#
# Constructors. Given an integer return the trivial partition (n parts of size 1)
# Given a list of disjoint sets, return that partition. Any points up to the maximum
# of any of the sets not included in a set are in singleton parts.
#
#! @Description
#! Returns the trivial partition of the set <C>[1..n]</C>.
#! @Arguments filter, n
DeclareConstructor("PartitionDS",[IsPartitionDS, IsPosInt]);
#! @Description
#! Returns the union find structure of <A>partition</A>.
#! @Arguments filter, partition
DeclareConstructor("PartitionDS",[IsPartitionDS, IsCyclotomicCollColl]);

#
# Key operations
#

#! @Description
#! Returns a canonical representative of the part of the partition that
#! <A>k</A> is contained in.
#! @Arguments unionfind, k
#! @Returns a positive integer
DeclareOperation("Representative",[IsPartitionDS, IsPosInt]);

#! @Description
#! Fuses the parts of the partition <A>unionfind</A> containing <A>k1</A>
#! and <A>k2</A>.
#! @Arguments unionfind, k1, k2
#! @Returns
DeclareOperation("Unite",[IsPartitionDS and IsMutable, IsPosInt, IsPosInt]);

#! @Description
#! Returns an iterator that runs through canonical representatives of parts
#! of the partition <A>unionfind</A>.
#! @Arguments unionfind
#! @Returns an iterator
DeclareOperation("RootsIteratorOfPartitionDS", [IsPartitionDS]);

#! @Description
#! Returns the number of parts of the partition <A>unionfind</A>.
#! @Arguments unionfind
#! @Returns a positive integer
DeclareAttribute("NumberParts", IsPartitionDS);

#! @Description
#! Returns the size of the underlying set of the partition <A>unionfind</A>.
#! @Arguments unionfind
#! @Returns a positive integer
DeclareAttribute("SizeUnderlyingSetDS", IsPartitionDS);

#! @Description
#! Returns the partition <A>unionfind</A> as a list of lists.
#! @Arguments unionfind
#! @Returns a list of lists
DeclareAttribute("PartsOfPartitionDS", IsPartitionDS);
