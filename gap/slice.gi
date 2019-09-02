##
##  Datastructures: GAP package providing common datastructures.
##
##  Copyright (C) 2015-2019  The datastructures team.
##  For list of the team members, please refer to the COPYRIGHT file.
##
##  This package is licensed under the GPL 2 or later, please refer
##  to the COPYRIGHT.md and LICENSE files for details.
##

##
##  This file defines slices.
##

#! @Chapter Slices
#! @Section API


InstallGlobalFunction(Slice,
function(list, begin, len)
    local o;
    # begin - 1 because GAP lists are 1 indexed
    if IsSliceRep( list ) then
      # Avoid recursive constructions of slices.
      o:= Objectify( SliceTypeMutable,
                     rec( list:= list!.list,
                          begin:= begin + list!.begin - 1,
                          len:= len ) );
    else
      o := Objectify(SliceTypeMutable, rec(list := list, begin := begin - 1, len := len));
    fi;
    if IsSmallList(list) then
        SetIsSmallList(o, true);
    fi;
    return o;
end);

InstallMethod(ViewString, "for slices",
    [ IsSliceRep ], SUM_FLAGS,
function(slice)
    return STRINGIFY("<slice size=", slice!.len, ">");
end);

InstallMethod(ViewObj, "for slices",
    [ IsSliceRep ], SUM_FLAGS,
function(slice)
    Print("<slice size=", slice!.len, ">");
end);

#! @Description
#! List-style access for slices.
#! @Arguments slice, value
InstallMethod(\[\],
    "for a slice and a positive integer",
    [ IsSliceRep, IsPosInt ],
    function(slice, o)
        if o < 1 or o > slice!.len then
            ErrorNoReturn("Cannot access element ", o, " of a range with ",
                          slice!.len, " elements");
        fi;
        return slice!.list[o + slice!.begin];
    end);

#! @Description
#! List-style assignment for slices.
#! @Arguments slice, value, object
InstallMethod(\[\]\:\=,
    "for a slice, a key and a value",
    [ IsSliceRep and IsMutable, IsPosInt, IsObject ],
    function(slice, o, x)
        if o < 1 or o > slice!.len then
            ErrorNoReturn("Cannot access element ", o, " of a range with ",
                          slice!.len, " elements");
        fi;
        slice!.list[o + slice!.begin] := x;
    end);

#! @Description
#! Test whether a value is stored in the slice.
#! @Arguments object, slice
InstallMethod( \in,
    "for a slice and a key",
    [ IsObject, IsSliceRep ],
    function(o, slice)
        local i;
        for i in [slice!.begin..slice!.begin + slice!.len - 1] do
            if IsBound(slice!.list[i]) and slice!.list[i] = o then
                return true;
            fi;
        od;
        return false;
    end);

#! @Description
#! Test whether a location is bound in a slice.
#! @Arguments slice, value
InstallMethod( IsBound\[\],
    "for a slice and a key",
    [ IsSliceRep, IsPosInt ],
    function(slice, o)
        if o < 1 or o > slice!.len then
            return false;
        fi;
        return IsBound(slice!.list[slice!.begin + o]);
    end);

#! @Description
#! Unbind a value from a slice.
#! @Arguments slice, value
InstallMethod( Unbind\[\],
    "for a slice and a positive integer",
    [ IsSliceRep and IsMutable, IsPosInt ],
    function(slice, o)
        if o >= 1 and o <= slice!.len then
            Unbind(slice!.list[slice!.begin + o]);
        fi;
    end);

#! @Description
#! Determine the length of a slice.
#! @Arguments slice
InstallMethod( Length,
    "for a slice",
    [ IsSliceRep ],
    slice -> slice!.len);
