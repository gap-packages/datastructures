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
    local l, i;

    l := Length(s![1]);
    Print("<stack:");
    i := 1;
    while (l > 0) and (i < 6) do
        Print(" ", s![1][l]);
        l := l-1;
        i := i+1;
    od;
    Print(">");
end);

