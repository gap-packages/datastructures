
#
# Skip Lists as an ordered set implementation (this version is sets)
#

# For documentation of the data structure, see Wikipedia. A skip list is
# essentially set of linked lists called levels -- in this implementation levels
# currently start at 2. The list at level 2 contains all the objects in the set
# in order, the lists at higher levels contain progressively fewer of them
# (roughly 1/3 as many as at the level below). each level is a subset of the one
# below. The nodes of the lists are the same objects, so that you can drop down
# from one list to a lower level as you approach the object you want.
#
#
# Each node is represented by a plain list whose 1 entry is the value at the
# node and whose other entries are next pointers for all of the linked lists
# that that entry is in. The end of the lists is represented by unbound. The
# root object contains the head pointers of all the lists (and fail in position
# 1) This object (along with the less than function and other attributes are
# stored in an outer component object


# Record for local functions and constants to avoid cluttering the global
# namespace
SKIPLISTS := rec();

DeclareRepresentation("IsSkipListRep", IsComponentObjectRep, []);

SKIPLISTS.SkipListDefaultType :=  NewType(OrderedSetDSFamily, IsSkipListRep and IsOrderedSetDS and IsMutable);
SKIPLISTS.SkipListStandardType :=  NewType(OrderedSetDSFamily, IsSkipListRep and IsStandardOrderedSetDS and IsMutable);
SKIPLISTS.nullIterator := Iterator([]);

# This controls the relative sizes of the lists (i.e. how likely each entry is
# to be promoted to the next list above the default value is 1/3 represented by
# its inverse here. It is possible that 1/2 might be better choice when
# comparison is very expensive.
SKIPLISTS.defaultInvProb := 3;

#
# Worker function for all the constructors
#
SKIPLISTS.NewSkipList :=
  function(isLess, iter, rs, invprob)
    local  s, x, type;
    if isLess = \< then
        type := SKIPLISTS.SkipListStandardType;
    else
        type := SKIPLISTS.SkipListDefaultType;
    fi;

    s :=  Objectify( type,     rec(
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

#
# Constructors
#

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


InstallMethod(OrderedSetDS, [IsSkipListRep and IsMutable and IsOrderedSetDS, IsListOrCollection],
function(type, data)
    return SKIPLISTS.NewSkipList(\<, Iterator(data), GlobalMersenneTwister, SKIPLISTS.defaultInvProb);
end);

InstallMethod(OrderedSetDS, [IsSkipListRep and IsMutable and IsOrderedSetDS, IsListOrCollection, IsRandomSource],
function(type, data, rs)
    return SKIPLISTS.NewSkipList(\<, Iterator(data), rs, SKIPLISTS.defaultInvProb);
end);

InstallMethod(OrderedSetDS, [IsSkipListRep and IsMutable and IsOrderedSetDS, IsOrderedSetDS],
function(type, os)
    return SKIPLISTS.NewSkipList(\<, Iterator(os), GlobalMersenneTwister, SKIPLISTS.defaultInvProb);
end);

InstallMethod(OrderedSetDS, [IsSkipListRep and IsMutable and IsOrderedSetDS, IsFunction, IsListOrCollection],
function(type, isLess, data)
    return SKIPLISTS.NewSkipList(isLess, Iterator(data), GlobalMersenneTwister, SKIPLISTS.defaultInvProb);
end);

InstallMethod(OrderedSetDS, [IsSkipListRep and IsMutable and IsOrderedSetDS, IsIterator],
function(type, iter)
    return SKIPLISTS.NewSkipList(\<, iter, GlobalMersenneTwister, SKIPLISTS.defaultInvProb);
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

#
# The general API doesn't provide a way to set this tuning parameter.
#
BindGlobal("SetSkipListParameter", function(sl, p)
    sl!.invprob := p;
end);


#
# This is the worker function which finds a value if it is present, and if not
# finds where it would go.
#
# Specifically it returns a vector whose l entry is the skiplist entry at level
# l which immediately precedes the value we are looking for (or would precede it
# if it were present). So if it returns x with an entry in position l then
# x[l][1] < val (or x[1] is the head node) and x[l][l] is either unbound or has
# x[l][l][1] >= val

#
# There is a C version of this function in skiplist.c. This version is retained
# (and tested) as a reference implementation and/or if the kernel code is not
# compiled.
#
# The first argyment is the head node, not the component object
#
SKIPLISTS.ScanSkipListGAP := function(sl, val, less)
    local  level, ptr, lst, nx;
    #
    # We start at the head node and at the top level
    #
    ptr := sl;
    level := Length(ptr);
    #
    # the result will accumulate in lst
    #
    lst := [];
    while level > 1 do
        if not IsBound(ptr[level]) then
            #
            # end of the list at the current level,
            # remember this location and drop down
            #
            lst[level] := ptr;
            level := level -1;
        else
            #
            # Look ahead on current list
            #
            nx := ptr[level];
            if not less(nx[1],val) then
                #
                # the next node at the current level is AFTER  or equal to the value we want
                # remember this location and drop down
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
    #
    # If the object is present, it will be the next item after the node returned by
    # the scan, at the lowest level (level 2)
    #
    # lst[2] unbound implies that the whole skiplist is actually empty
    # lst[2][2] unbound implies that we are about to add at the end of the skiplist
    #
    if IsBound(lst[2]) and IsBound(lst[2][2]) and lst[2][2][1] = val then
        #
        # It's there already
        #
        return;
    fi;

    #
    # Add the new value to as many linked lists as our random numbers dictate
    #
    # We now we'll need 2 entries in the list and 2/3 of the time that will be all, so
    # make a list with room for two entries
    #
    new := EmptyPlist(2);
    new[1] := val;
    level := 2;
    rs := sl!.randomSource;
    ip := sl!.invprob;
    #
    # In this loop we add the new node to the linked list at level level
    # and decide whether to also add it at the next level up.
    # this may involve opening up a whole new level
    #
    repeat
        if not IsBound(lst[level]) then
            #
            # New level
            #
            Add(sl!.lists, new);
        else
            #
            # We're adding after node
            #
            node := lst[level];
            if IsBound(node[level]) then
                new[level] := node[level];
            fi;
            node[level] := new;
        fi;
        level := level+1;
    until Random(rs, 1, ip) <> 1;
    #
    # Keep track of the size
    #
    sl!.size := sl!.size+1;
end);


InstallMethod(\in, [IsObject, IsSkipListRep and IsOrderedSetDS],
        function(val,sl)
    local  lst;
    lst := SKIPLISTS.ScanSkipList(sl!.lists, val, sl!.isLess);
    return IsBound(lst[2]) and IsBound(lst[2][2]) and lst[2][2][1] = val;
end);


#
# This is (profiling showed) the other loop worth moving into C brought
# out a function. It deals with the mechanics of removing a node from all the
# lists it's in
#
# lst is what is returned by the scan function, nx is the node to remove
#

SKIPLISTS.RemoveNodeGAP := function(lst, nx)
    local  level, node;
    for level in [2..Length(lst)] do
        node := lst[level];
        if IsBound(node[level]) and IsIdenticalObj(node[level],nx) then
            if IsBound(nx[level]) then
                node[level] := nx[level];
            else
                #
                # In this case we are removing the last node
                # at this level
                #
                Unbind(node[level]);
            fi;
        fi;
    od;
end;


#
# Prefer the C implemnentation
#
if IsBound(DS_Skiplist_RemoveNode) then
    SKIPLISTS.RemoveNode := DS_Skiplist_RemoveNode;
else
    SKIPLISTS.RemoveNode := SKIPLISTS.RemoveNodeGAP;
fi;


#
# And now what remains of the remove after the worker functions have been split out
#
InstallMethod(RemoveSet, [IsSkipListRep and IsOrderedSetDS and IsMutable, IsObject],
        function(sl, val)
    local  lst, nx;
    lst := SKIPLISTS.ScanSkipList(sl!.lists, val, sl!.isLess);
    if not IsBound(lst[2]) or not IsBound(lst[2][2]) then
        #
        # Wasn't there in the first place
        #
        return 0;
    fi;
    nx := lst[2][2];
    if nx[1] <> val then
        #
        # Wasn't there in the first place
        #
        return 0;
    fi;
    SKIPLISTS.RemoveNode(lst, nx);
    #
    # Book-keeping
    #
    sl!.size := sl!.size -1;
    return 1;
end);

#
# Show the full structure of the skip list in a display
# displays each linked list on a separate line.
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
# all the elements. Hence the next couple of functions are pretty simple
#


InstallMethod(Iterator, [IsSkipListRep and IsOrderedSetDS],
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


#
# A debugging function to actually count the nodes and make
# sure our bookkepping is correct
#
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

#
# Since we keep track of it
#
InstallMethod(Size, [IsSkipListRep and IsOrderedSetDS],
        sl -> sl!.size);

#
# Typical short view
#
InstallMethod(ViewString, [IsSkipListRep and IsOrderedSetDS],
        function(sl)
    return Concatenation(["<skiplist ",String(Size(sl))," entries>"]);
end);

#
# Try and make a string that will return the same object
#

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
        Add(s, String(AsList(sl)));
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


InstallMethod(LessFunction, [IsSkipListRep and IsOrderedSetDS],
        sl -> sl!.isLess);
