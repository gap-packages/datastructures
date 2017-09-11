#############################################################################
##
#W  union-find.gd                    GAPData                     Steve Linton
##
##
#Y  Copyright (C) 2017 The GAP Group
##
##  This file defines the interface for data structures representing mutable 
##  partitions of 1..n. key operations are Unite which fuses two parts of 
##  a partition and Representative which returns a canonical representative
##  of the part containing a given point.
##
##
##

##  Category of datastructures representing partitions.
##  As usual with data structures, equality is identity and family is
##  ignored.

DeclareCategory("IsPartitionDS", IsObject);

##  Family containing all partition data structures
##  May be merged in a general DatastructuresFamily

BindGlobal("PartitionDSFamily", NewFamily(IsPartitionDS));

#
# Constructors. Given an integer return the trivial partittion (n parts of size 1)
# Given a list of disjoint sets, return that partition. Any points up to the maximum
# of any of the sets not included in a set are in singleton parts.
#
DeclareConstructor("PartitionDS",[IsPartitionDS, IsPosInt]);
DeclareConstructor("PartitionDS",[IsPartitionDS, IsCyclotomicCollColl]);

#
# Key operations
#
DeclareOperation("Representative",[IsPartitionDS, IsPosInt]);
DeclareOperation("Unite",[IsPartitionDS and IsMutable, IsPosInt, IsPosInt]);

#
# Runs through all the canonical representatives
#
DeclareOperation("RootsIteratorOfPartitionDS", [IsPartitionDS]);

#
# Basic properties
#
DeclareAttribute("NumberParts", IsPartitionDS);
DeclareAttribute("SizeUnderlyingSetDS", IsPartitionDS);
DeclareAttribute("PartsOfPartitionDS", IsPartitionDS);





