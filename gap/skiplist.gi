
#
# Skip Lists as a candidate ordered set/map implementation (this version is sets)
#
#
# Each entry is represented by a plain list whose 1 entry is the value and whose other entries
# are next pointers for all of the linked lists that that entry is in. The end of the lists is 
# represented by unbound. 
#
# The skiplist object itself is a plist containing fail in position 1 and with the head pointers of all 
# the linked lists in its other entries.
#
#

SKIPLISTS := rec();

IsSkipListRep := NewRepresentation("IsSkipListRep", IsComponentObjectRep, []);

SKIPLISTS.SkipListDefaultType :=  NewType(OrderedSetsFamily, IsSkipListRep and IsOrderedSetDS and IsMutable);
SKIPLISTS.nullIterator := Iterator([]);
SKIPLISTS.defaultInvProb := 3;



SKIPLISTS.NewSkipList := 
  function(isLess, iter, rs, invprob)
    local  s, x;
    s :=  Objectify( SKIPLISTS.SkipListDefaultType,     rec(
                  lists := [fail],
                  isLess := isLess,
                  invprob := invprob,
                  size := 0,
                  randomSource := rs) );
    for x in iter do
        AddSet(s,x);
    od;
    return s;
end;


InstallMethod(OrderedSetDS, [IsSkipListRep and IsOrderedSetDS and IsMutable, IsFunction],
        function(type, isLess)
    return SKIPLISTS.NewSkipList(isLess, SKIPLISTS.nullIterator, GlobalMersenneTwister, SKIPLISTS.defaultInvProb);
end);

    

InstallMethod(OrderedSetDS, [IsSkipListRep and IsOrderedSetDS and IsMutable],
        function(type)
    return SKIPLISTS.NewSkipList(\<, SKIPLISTS.nullIterator, GlobalMersenneTwister, SKIPLISTS.defaultInvProb);
end);


InstallMethod(OrderedSetDS, [IsSkipListRep and IsMutable and IsOrderedSetDS, IsFunction, IsRandomSource],
        function(type, isLess, rs)
    return SKIPLISTS.NewSkipList(isLess, SKIPLISTS.nullIterator, rs, SKIPLISTS.defaultInvProb);
end);


InstallMethod(OrderedSetDS, [IsSkipListRep and IsMutable and IsOrderedSetDS, IsSet],
        function(type, data)
    return SKIPLISTS.NewSkipList(\<, IteratorSorted(data), GlobalMersenneTwister, SKIPLISTS.defaultInvProb);
end);

InstallMethod(OrderedSetDS, [IsSkipListRep and IsMutable and IsOrderedSetDS, IsOrderedSetDS],
        function(type, os)
    return SKIPLISTS.NewSkipList(\<, IteratorSorted(os), GlobalMersenneTwister, SKIPLISTS.defaultInvProb);
end);

InstallMethod(OrderedSetDS, [IsSkipListRep and IsMutable and IsOrderedSetDS, IsFunction, IsListOrCollection],
        function(type, isLess, data)
    return SKIPLISTS.NewSkipList(isLess, Iterator(data), GlobalMersenneTwister, SKIPLISTS.defaultInvProb);
end);

InstallMethod(OrderedSetDS, [IsSkipListRep and IsMutable and IsOrderedSetDS, IsFunction, IsIterator],
        function(type, isLess, iter)
    return SKIPLISTS.NewSkipList(isLess, iter, GlobalMersenneTwister, SKIPLISTS.defaultInvProb);
end);

InstallMethod(OrderedSetDS, [IsSkipListRep and IsMutable and IsOrderedSetDS, IsFunction, IsListOrCollection, IsRandomSource],
        function(type, isLess, data, rs)
    return SKIPLISTS.NewSkipList(isLess, Iterator(data), rs, SKIPLISTS.defaultInvProb);
end);

InstallMethod(OrderedSetDS, [IsSkipListRep and IsMutable and IsOrderedSetDS, IsFunction, IsIterator, IsRandomSource],
        function(type, isLess, iter, rs)
    return SKIPLISTS.NewSkipList(isLess, iter, rs, SKIPLISTS.defaultInvProb);
end);

BindGlobal("SetSkipListParameter", function(sl, p) 
    sl!.invprob := p;
end);


#
# This is the worker function which finds a value if it is present, and 
# if not finds where it would go. 
#
# Specifically it returns a vector whose l entry is the skiplist entry at level l which 
# immediately precedes the value we are looking for. So if it returns x with an entry in position l
# then x[l][1] < val (or x[1] is the head) and x[l][l] is either unbound or has x[l][l][1] >= val
#
#
# Prime candidate to be reimplemented in C
#
#


SKIPLISTS.ScanSkipListGAP := function(sl, val, less)
    local  level, ptr, lst, nx;
# and  at the head node
    ptr := sl;
    level := Length(ptr);
    lst := [];    
    while level > 1 do
        if not IsBound(ptr[level]) then
            #
            # end of the list at the current level, drop down
            #
            lst[level] := ptr;            
            level := level -1;
        else
            nx := ptr[level];
            if not less(nx[1],val) then
                #
                # current level overshoots, drop down
                #
                lst[level] := ptr;            
                level := level -1;
            else
                #
                # Move along at current level
                #
                ptr := nx;            
            fi;
        fi;        
    od;
    return lst;
end;

#
# Use the C version if available
#
if IsBound(DS_Skiplist_Scan) then
    SKIPLISTS.ScanSkipList := DS_Skiplist_Scan;
else
    SKIPLISTS.ScanSkipList := SKIPLISTS.ScanSkipListGAP;
fi;

     

InstallMethod(AddSet, [IsSkipListRep and IsOrderedSetDS and IsMutable, IsObject],
        function(sl, val)
    local  lst, new, level, rs, ip, node;
    #
    # Scan and check
    #
    lst := SKIPLISTS.ScanSkipList(sl!.lists,val, sl!.isLess);
    if IsBound(lst[2]) and IsBound(lst[2][2]) and lst[2][2][1] = val then
        #
        # It's there already
        #
        return;        
    fi;
    
    #
    # Add the new value to as many linked lists as our random numbers dictate
    #
    new := EmptyPlist(2);
    new[1] := val;
    level := 2;    
    rs := sl!.randomSource;
    ip := sl!.invprob;    
    repeat 
        if not IsBound(lst[level]) then
            #
            # New level
            #
            Add(sl!.lists, new);
        else 
            node := lst[level];            
            if IsBound(node[level]) then
                new[level] := node[level];
            fi;
            node[level] := new;
        fi;
        level := level+1;        
    until Random(rs, 1, ip) <> 1;
    sl!.size := sl!.size+1;    
end);


InstallMethod(\in, [IsObject, IsSkipListRep and IsOrderedSetDS],
        function(val,sl)
    local  lst;
    lst := SKIPLISTS.ScanSkipList(sl!.lists, val, sl!.isLess);
    return IsBound(lst[2]) and IsBound(lst[2][2]) and lst[2][2][1] = val;
end);


SKIPLISTS.RemoveNodeGAP := function(lst, nx)
    local  level, node;        
    for level in [2..Length(lst)] do
        node := lst[level];        
        if IsBound(node[level]) and IsIdenticalObj(node[level],nx) then
            if IsBound(nx[level]) then
                node[level] := nx[level];
            else
                Unbind(node[level]);
            fi;
        fi;
    od;
end;

if IsBound(DS_Skiplist_RemoveNode) then
    SKIPLISTS.RemoveNode := DS_Skiplist_RemoveNode;
else
    SKIPLISTS.RemoveNode := SKIPLISTS.RemoveNodeGAP;
fi;



InstallMethod(RemoveSet, [IsSkipListRep and IsOrderedSetDS and IsMutable, IsObject],
        function(sl, val)
    local  lst, nx;
    lst := SKIPLISTS.ScanSkipList(sl!.lists, val, sl!.isLess);
    if not IsBound(lst[2]) or not IsBound(lst[2][2]) then
        return 0;        
    fi;
    nx := lst[2][2];
    if nx[1] <> val then
        return 0;        
    fi;    
    SKIPLISTS.RemoveNode(lst, nx);
    sl!.size := sl!.size -1;
    return 1;
end);

#
# Show the full structure.
#
InstallMethod(DisplayString, [IsSkipListRep],
        function(sl)
    local  l, ptr, s;
    s := [];
    sl := sl!.lists;    
    for l in [Length(sl),Length(sl)-1..2] do
        Add(s,"->");        
        ptr := sl[l];
        while true do
            Add(s,String(ptr[1]));
            Add(s,"->");
            if not IsBound(ptr[l]) then
                Add(s,"X\n");
                break;
            else
                ptr := ptr[l];
            fi;
        od;
    od;
    if Length(s) = 0 then
        return "<empty skiplist>";
    else
        return Concatenation(s);
    fi;
    
end);

#
# For inorder access to the skip list we can just ignore all the 
# lists except the one at level 2 which is an in-order SLL containing
# all the elements. Hence the next coupld of functions are pretty simple
#
        

InstallMethod(IteratorSorted, [IsSkipListRep and IsOrderedSetDS],
        function(sl)
    return IteratorByFunctions(rec(
               ptr := sl!.lists,
    IsDoneIterator := function(iter)
        return not IsBound(iter!.ptr[2]);
    end,
    
    NextIterator := function(iter)
        iter!.ptr := iter!.ptr[2];
        return iter!.ptr[1];
    end,
    
    ShallowCopy := function(iter)
        return rec(ptr := iter!.ptr,
                   IsDoneIterator := iter!.IsDoneIterator,
                   NextIterator := iter!.NextIterator,
                   ShallowCopy := iter!.ShallowCopy,
                   PrintObj := iter!.PrintObj);
    end,
    
    PrintObj := function(iter)
        Print("Iterator of Skiplist");
    end ));
end);

SKIPLISTS.CheckSize :=
  function(sl)
    local  count, ptr;
    count := 0;
    ptr := sl!.lists;
    while IsBound(ptr[2]) do
        count := count+1;
        ptr := ptr[2];
    od;
    return count = Size(sl);
end;

InstallMethod(Size, [IsSkipListRep and IsOrderedSetDS],
        sl -> sl!.size);


InstallMethod(IsEmpty, [IsSkipListRep and IsOrderedSetDS],
        sl ->  sl!.size = 0);

        
InstallMethod(ViewString, [IsSkipListRep and IsOrderedSetDS],
        function(sl)
    return Concatenation(["<skiplist ",String(Size(sl))," entries>"]);
end);

InstallMethod(String, [IsSkipListRep and IsOrderedSetDS],
        function(sl)
    local  s, isLess;
    s := [];
    Add(s,"OrderedSetDS(IsSkipListRep");
    isLess := sl!.isLess;
    if isLess <> \< then
        Add(s,", ");
        Add(s,String(isLess));
    fi;
    if not IsEmpty(sl) then
        Add(s, ", ");
        Add(s, String(AsListSorted(sl)));
    fi;
    Add(s,")");
    return Concatenation(s);
end);

#
# Could do this faster, but copying the lists preserving all the structure
# but not copying the entries would be fiddly
#

InstallMethod(ShallowCopy, [IsSkipListRep and IsOrderedSetDS],
        sl -> OrderedSetDS(IsSkipListRep, sl)
        );

          
