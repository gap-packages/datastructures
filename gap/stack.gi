##
##  Datastructures: GAP package providing common datastructures.
##
##  Copyright (C) 2015-2017  The datastructures team.
##  For list of the team members, please refer to the COPYRIGHT file.
##
##  This package is licensed under the GPL 2 or later, please refer
##  to the COPYRIGHT.md and LICENSE files for details.
##

##
##  This file defines stacks.
##


InstallGlobalFunction(Stack,
function()
    return Objectify(StackTypeMutable, [ [] ]);
end);

InstallMethod(Push
              , "for a stack"
              , [IsStack, IsObject],
function(s,o)
    Add(s![1], o);
end);

InstallMethod(Peek
             , "for a stack"
             , [IsStack],
function(s)
    if Length(s![1]) > 0 then
        return s![1][Length(s![1])];
    else
        return fail;
    fi;
end);

InstallMethod(Pop
             , "for a stack"
             , [IsStack],
function(s)
    if Length(s![1]) > 0 then
        return Remove(s![1]);
    else
        return fail;
    fi;
end);

InstallOtherMethod(Size
              , "for a stack"
              , [IsStack]
              , s -> Length(s![1]));

InstallMethod(ViewString
             , "for a stack"
             , [IsStack],
function(s)
    return STRINGIFY("<stack with ", Length(s![1]), " entries>");
end);

