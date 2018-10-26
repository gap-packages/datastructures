##
##  Datastructures: GAP package providing common datastructures.
##
##  Copyright (C) 2015-2019  The datastructures team.
##  For list of the team members, please refer to the COPYRIGHT file.
##
##  This package is licensed under the GPL 2 or later, please refer
##  to the COPYRIGHT.md and LICENSE files for details.
##

#! @Chapter Slices
#!
#! A slice is a sublist of a list. Creating a slice does not copy the
#! original list, and changes to the list also change a slice of the list.


#! @Section API
#!
#! @Description
#! Constructor for slices
#! @Arguments
#! @Returns a slice
DeclareGlobalFunction("Slice");

#! @Description
#! Category of slices
DeclareCategory("IsSlice", IsList);
BindGlobal( "SliceFamily", NewFamily("SliceFamily") );


DeclareRepresentation( "IsSliceRep", IsSlice and IsComponentObjectRep, []);
BindGlobal( "SliceType", NewType(SliceFamily, IsSliceRep));
BindGlobal( "SliceTypeMutable", NewType(SliceFamily,
                                        IsSliceRep and IsMutable));

