##
#Y  Copyright (C) 2017 The GAP Group
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
    return s![1][Length(s![1])];
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

InstallMethod(Size
              , "for a stack"
              , [IsStack]
              , s -> Length(s![1]));

InstallMethod(ViewObj
             , "for a stack"
             , [IsStack],
function(s)
    Print("<stack with ", Length(s![1]), " entries>");
end);

