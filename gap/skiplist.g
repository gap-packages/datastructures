#
# Work in progress, not intended to be loaded as part of the package yet
#  Steve Linton
#

#
# Skip Lists as a candidate ordered set/map implementation (this version is sets)
#
#
# Each entry is represented by a plain list whose 1 entry is the value and whose other entries
# are next pointers for all of the linked lists that that entry is in. The end of the lists is 
# represented by unbound. 
#
# The skiplist object itself is a linked list containing fail in position 1 and with the head pointers of all 
# the linked lists in its other entries.
#
#

EmptySkipList := function()
    return [fail];
end;

#
# This is the worker function which finds a value if it is present, and 
# if not finds where it would go. 
#
# Specifically it returns a vector whose l entry is the skiplist entry at level l which 
# immediately precedes the value we are looking for. So if it returns x with an entry in position l
# then x[l][1] < val (or x[1] is the head) and x[l][l] is either unbound or has x[l][l][1] >= val
#
#

ScanSkipList := function(sl, val)
    local  level, ptr, lst, nx;
# start at the highest level    
    level := Length(sl);
# and  at the head node
    ptr := sl;
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
            if nx[1] >= val then
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
# Changing this change the probability of a node also existing at the next higher level
# 1/3 seems to be slightly faster than 1/2 or 1/4.
#

SL_Selector := MakeImmutable([true, true, false]);
    
InsertIntoSkipList := function(sl, val)
    local  lst, new, level, node;    
    #
    # Scan and check
    #
    lst := ScanSkipList(sl,val);
    if IsBound(lst[2]) and lst[2][1] = val then
        Error("Already present");
    fi;
    
    #
    # Add the new value to as many linked lists as our random numbers dictate
    #
    new := EmptyPlist(2);
    new[1] := val;
    level := 2;    
    repeat 
        if not IsBound(lst[level]) then
            #
            # New level
            #
            Add(sl, new);
        else 
            node := lst[level];            
            if IsBound(node[level]) then
                new[level] := node[level];
            fi;
            node[level] := new;
        fi;
        level := level+1;        
    until Random(GlobalMersenneTwister, SL_Selector);
end;


InSkipList := function(sl, val)
    local  lst;
    lst := ScanSkipList(sl, val);
    return IsBound(lst[2]) and IsBound(lst[2][2]) and lst[2][2][1] = val;
end;

DeleteFromSkipList := function(sl, val)
    local  lst, nx, level, node;
    lst := ScanSkipList(sl, val);
    if not IsBound(lst[2]) or not IsBound(lst[2][2]) then
        Error("Not present");
    fi;
    nx := lst[2][2];
    if nx[1] <> val then
        Error("Not present");
    fi;    
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

#
# Show the full structure.
#
DisplaySkipList := function(sl)
    local  l, ptr;
    for l in [Length(sl),Length(sl)-1..2] do
        Print("->");        
        ptr := sl[l];
        while true do
            Print(ptr[1],"->");
            if not IsBound(ptr[l]) then
                Print("X\n");
                break;
            else
                ptr := ptr[l];
            fi;
        od;
    od;
    return;
end;

#
# For inorder access to the skip list we can just ignore all the 
# lists except the one at level 2 which is an in-order SLL containing
# all the elements. Hence the next coupld of functions are pretty simple
#
        

IteratorSortedOfSkipList := function(sl)
    return IteratorByFunctions(rec(
               ptr := sl,
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
    end
    ));
end;

SizeSkipList := function(sl)
    local  count, ptr;
    count := 0;
    ptr := sl;
    while IsBound(ptr[2]) do
        count := count+1;
        ptr := ptr[2];
    od;
    return count;
end;


          
