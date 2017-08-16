#
# Binary Search Trees not automatically balanced. 
#
# These trees only give $O(\log n)$ insert and delete if the objects are passed in more-or-less
# random order. On the other hand they are fast and simple.
#
# AVL trees are a specialisation with different insert and delete methods and a little extra data in each node

#
# The nodes of our BST are plain lists of length 3. Entry 1 is the left child, entry 2 the data and entry 3 the right child.
# The root of the tree is held in a length 1 plain list, which is then held in a component object.
#

#
# REcord for "local" things
#
BSTS := rec();

#
# We have to declare this here because we want to be able to reset it if we update the tree using the non-AVL 
# methods for some reason. 
#

DeclareFilter("IsAVLTree");

IsBinarySearchTreeRep := NewRepresentation("IsBinarySearchTreeRep", IsComponentObjectRep, []);

BSTS.BSTDefaultType :=  NewType(OrderedSetDSFamily, IsBinarySearchTreeRep and  IsOrderedSetDS and IsMutable);
BSTS.nullIterator := Iterator([]);


#
# Worker function for construction -- relies on the fact that we can make a perfectly balanced BST in linear time 
# from a sorted list of objects.
#

BSTS.NewBst := 
  function(isLess, set)
    if not IsSet(set) or isLess <> \< then
        if not IsMutable(set) then
            set := ShallowCopy(set);
        fi;
        Sort(set, isLess);
    fi;
    return Objectify( BSTS.BSTDefaultType, rec(
                   lists := BSTS.BSTByOrderedList(set),
                   isLess := isLess,
                   size := Length(set),
                   nextSide := 1)
                   );
end;

InstallMethod(OrderedSetDS, [IsBinarySearchTreeRep and IsOrderedSetDS and IsMutable, IsFunction],
        function(type, isLess)
    return BSTS.NewBst(isLess, []);
end);

InstallMethod(OrderedSetDS, [IsBinarySearchTreeRep and IsOrderedSetDS and IsMutable],
        function(type)
    return BSTS.NewBst(\<, []);
end);

InstallMethod(OrderedSetDS, [IsBinarySearchTreeRep and IsMutable and IsOrderedSetDS, IsFunction, IsRandomSource],
        function(type, isLess, rs)
    return BSTS.NewBst(isLess, []);
end);

InstallMethod(OrderedSetDS, [IsBinarySearchTreeRep and IsMutable and IsOrderedSetDS, IsListOrCollection],
        function(type, data)
    return BSTS.NewBst(\<, data);
end);

InstallMethod(OrderedSetDS, [IsBinarySearchTreeRep and IsMutable and IsOrderedSetDS, IsListOrCollection, IsRandomSource],
        function(type, data, rs)
    return BSTS.NewBst(\<, data);
end);

InstallMethod(OrderedSetDS, [IsBinarySearchTreeRep and IsMutable and IsOrderedSetDS, IsOrderedSetDS],
        function(type, os)
    return BSTS.NewBst(\<, AsListSorted(os));
end);

InstallMethod(OrderedSetDS, [IsBinarySearchTreeRep and IsMutable and IsOrderedSetDS, IsFunction, IsListOrCollection],
        function(type, isLess, data)
    return BSTS.NewBst(isLess, data);
end);
#
# If we're given an iterator, worth the time to drain and sort
#
InstallMethod(OrderedSetDS, [IsBinarySearchTreeRep and IsMutable and IsOrderedSetDS,  IsIterator],
        function(type, iter)
    local  l, x;
    l := [];
    for x in iter do
        Add(l,x);
    od;
    return BSTS.NewBst(\<, l);
end);

InstallMethod(OrderedSetDS, [IsBinarySearchTreeRep and IsMutable and IsOrderedSetDS, IsFunction, IsIterator],
        function(type, isLess, iter)
    local  l, x;
    l := [];
    for x in iter do
        Add(l,x);
    od;
    return BSTS.NewBst(isLess, l);
end);

InstallMethod(OrderedSetDS, [IsBinarySearchTreeRep and IsMutable and IsOrderedSetDS, IsFunction, IsListOrCollection, IsRandomSource],
        function(type, isLess, data, rs)
    return BSTS.NewBst(isLess, data);
end);

InstallMethod(OrderedSetDS, [IsBinarySearchTreeRep and IsMutable and IsOrderedSetDS, IsFunction, IsIterator, IsRandomSource],
        function(type, isLess, iter, rs)
    local  l, x;
    l := [];
    for x in iter do
        Add(l,x);
    od;
    return BSTS.NewBst(isLess, l);
end);

#
# Worker function used in AddSet, RemoveSet and \in
# returns a length 3 list containing the node of which val is a child, or would be if it were present,
# the index in that node (1 for left, 3 for right) where it is, or would belong
# and a boolean indicating if it was present.
#
# A parallel C implementation is actually used, but this version is kept as a reference implementation
# it is tested.
#

BSTS.BSTFindGAP := function(bst, val, less)
    local  ix, child, d;
    #
    # bst is the current node and ix the direction we are about to go in 
    #
    # Since the root is in a length 1 list, we can start
    ix := 1;
    while true do
        #
        # If there is nothing there, then val is not present
        #
        if not IsBound(bst[ix]) then
            return [bst,ix,false];            
        fi;
        #
        # Otherwise take a look at this child
        #
        child := bst[ix];
        d := child[2];
        #
        # Work out which way to go next
        #
        if less(val,d) then
            # left
            bst := child;
            ix := 1;
        elif val <> d then
            # right
            bst := child;
            ix := 3;
        else
            # found it
            return [bst, ix, true];            
        fi;
    od;
end;

#
# Prefer the C version
#
if IsBound(DS_BST_FIND) then
    BSTS.BSTFind := DS_BST_FIND;
else
    BSTS.BSTFind := BSTS.BSTFindGAP;
fi;

#
# With this worker function AddSet and \in are really easy
#
    
InstallMethod(AddSet, [IsBinarySearchTreeRep and IsOrderedSetDS and IsMutable, IsObject],        
function(bst, val)
    local  res;
    res := BSTS.BSTFind(bst!.lists, val, bst!.isLess);
    if res[3] then
        return;
    else
        ResetFilterObj(bst, IsAVLTree);        
        res[1][res[2]] := [,val,];
        bst!.size := bst!.size + 1;        
    fi;
end);

InstallMethod(\in, [IsObject, IsBinarySearchTreeRep and IsOrderedSetDS],
        function(val, bst)
    return BSTS.BSTFind(bst!.lists, val, bst!.isLess)[3];
end);


#
# remove is a little more complicated 
#
InstallMethod(RemoveSet, [IsBinarySearchTreeRep and IsOrderedSetDS and IsMutable, IsObject],
        function(bsttop, val)
    local  res, bst, ix, child, i, j, x, y;
    # Usual find function
    res := BSTS.BSTFind(bsttop!.lists, val, bsttop!.isLess);
    # Maybe it's not there. That makes things easy
    if not res[3] then
        return 0;        
    fi;
    bst := res[1];
    ix := res[2];    
    child := bst[ix];
    #
    # Now child is the node we want to delete.
    # What happens next depends on how many children it has
    # 0 we just delete it
    # 1 we replace it by its only child
    # 2 we have to find it's immediate predecessor or successor 
    #    in the ordering or entries of the BST (we alternate to keep the tree balanced)
    #   we delete that (which can only have one child) and put its value into the current node
    #
    if IsBound(child[1]) then
        if IsBound(child[3]) then 
            #
            # The hard case
            #
            # i is 1 or 3 telling us which side to look on for the element to move in place 
            #
            i :=  bsttop!.nextSide;
            #
            # j is the other side
            #
            j := 4-i;
            #
            # and next time remember to do the opposite
            #
            bsttop!.nextSide := j;            
            #
            # So we go one step in the i direction (which must be possible)
            # and then as many as we can in the j direction (which might be none)
            #
            x := child[i];
            if IsBound(x[j]) then
                # we can go at least one step

                repeat
                    y := x;                        
                    x := x[j];
                until not IsBound(x[j]);
                
                #
                # OK, so we've got where we need to be. x is the predecessor or 
                # successor node we were looking for, y is it's parent
                #
                if IsBound(x[i]) then
                    #
                    # x has a child
                    # replace x with that child
                    #
                    y[j] := x[i];
                else
                    #
                    # x is a leaf, delete it from the tree
                    #
                    Unbind(y[j]);
                fi;
                #
                # x is going to take the place of child
                #
                x[i] := child[i];
            fi;
            #
            # Even if we went no steps in the j direction we still need this
            #
            x[j] := child[j];
            
            #
            # So we've done our job and we glue the replacement for child into the tree
            # where it needs to be
            #
            bst[ix] := x;                
        else
            # child only has a left child, which replaces it
            bst[ix] := child[1];        
        fi;
    else 
        if IsBound(child[3]) then
            # child only has a right child, which replaces it
            bst[ix] := child[3];
        else
            # child is a leaf
            Unbind(bst[ix]);            
        fi;
    fi;
    #
    # book-keeping, we've deleted a node using a non-AVL tree algorithm
    #
    ResetFilterObj(bsttop, IsAVLTree);
    bsttop!.size := bsttop!.size -1;    
    return 1;
end);

#
# Some classic utility functions
#
        
BSTS.BSTHeight := function(bst)
    local  bsth;
    bsth := function(b,ix)
        local  child;
        if not IsBound(b[ix]) then return 0; fi;
        child := b[ix];        
        return 1 + Maximum(bsth(child,1), bsth(child,3));
    end;
    return bsth(bst!.lists,1);
end;


BSTS.CheckSize := 
        function(bst)
    local  bsts, topnode;
    bsts := function(b,ix)
        local  child;
        if not IsBound(b[ix]) then return 0; fi;
        child := b[ix];        
        return 1 + bsts(child,1)+ bsts(child,3);
    end;
    topnode := bst!.lists;
    return bst!.size = bsts(topnode,1);
end;


BSTS.BSTImbalance := function(bst)
    local  bsthi;
    bsthi := function(b,ix)
        local  child, r, hl, il, hr, ir, h, im;
        if not IsBound(b[ix]) then return [0,0]; fi;
        child := b[ix];        
        r := bsthi(child,1);
        hl := r[1];
        il := r[2];
        r := bsthi(child,3);
        hr := r[1];
        ir := r[2];
        h := 1 + Maximum(hl,hr);
        im := Maximum(il, ir, AbsInt(hl-hr));
        return [h,im];        
    end;
    return bsthi(bst!.lists,1)[2];
end;
               
    
InstallMethod(Size, [IsBinarySearchTreeRep and IsOrderedSetDS],
        bst -> bst!.size);
          
#
#  Used in the constructors
#  divide and conquer
#

BSTS.BSTByOrderedList := function(l)
    local  foo,x;
    foo := function(l, from, to)
        local  mid, left, right, node;
        #
        # returns a tree representing the section of l from from to to 
        # inclusive or fail if from > to
        #
        if from > to then
            return fail;
        fi;        
        mid := QuoInt(from + to,2);
        left := foo(l,from, mid-1);
        right := foo(l, mid+1, to);
        node := [,l[mid],];
        if left <> fail then
            node[1] := left;
        fi;
        if right <> fail then
            node[3] := right;
        fi;
        return node;
    end;
    x := foo(l, 1, Length(l));
    #
    # wrap result up nicely
    #
    if x = fail then
        return [];
    else
        return [x];
    fi;
    
end;


#
# Since we don't have parent pointers or threading, there is a little work to do here
# the stack list contains all the tree nodes whose left subtree we are currently processing
# or have just processed with the lowest one in the tree at the top of the stack
# So the next item to return is always the top object on the stack
# once we have returned it, we can delete that node from the stack, and move to its right child (if any)
# where we descend to the leftmost node

InstallMethod(IteratorSorted, [IsBinarySearchTreeRep and IsOrderedSetDS],
        function(bst)
    local  stack, node;
    stack := [];    
    #
    # The first element to return will be the bottom left most one
    # so we need to set all its ancestors up on the initial stack
    #
    node := bst!.lists;
    while IsBound(node[1]) do
        Add(stack, node[1]);
        node := node[1];
    od;
    
    return  IteratorByFunctions(rec(
                    stack := stack,
                           
                    IsDoneIterator := function(iter)
        # We'll be when the stack is empty
        return Length(iter!.stack) = 0;
    end,
      
      NextIterator := function(iter)
        local  node, x;
        #
        # Pop a node
        #
        node := Remove(iter!.stack);
        #
        # If it has a right child
        #
        if IsBound(node[3]) then
            x := node[3];
            #
            # descend to its leftmost desendant
            # 
            Add(iter!.stack,x);
            while IsBound(x[1]) do
                Add(iter!.stack,x[1]);
                x := x[1];
            od;
        fi;
        #
        # Now return the data from the node we popped
        #
        return node[2];
    end,
    
    ShallowCopy := function(iter)
        return rec(stack := ShallowCopy(iter!.stack),
                   IsDoneIterator := iter!.IsDoneIterator,
                   NextIterator := iter!.NextIterator,
                   ShallowCopy := iter!.ShallowCopy,
                   PrintObj := iter!.PrintObj);
    end,
    
      PrintObj := function(iter)
        Print("<Iterator of BST>");
    end ));
end);


InstallMethod(ViewString, [IsBinarySearchTreeRep and IsOrderedSetDS], 
        t ->  Concatenation("<bst size ",String(Size(t)),">"));



#
# We copy the tree, but not the data.
#
InstallMethod(ShallowCopy, [IsBinarySearchTreeRep and IsOrderedSetDS],
        function( bst) 
    local  l, copytree;
    l := rec();
    copytree := function(node)
        local  l, x;
        l := [,node[2],];
        for x in [1,3] do
            if IsBound(node[x]) then
                l[x] := copytree(node[x]);
            fi;
        od;
        return l;
    end;
    l.lists := [copytree(bst!.lists[1])];
    l.isLess := bst!.isLess;
    l.size := bst!.size;    
    Objectify(BSTS.BSTDefaultType, l);

    return l;
end);

#
# This is more of less the same method as for Skiplinks -- unify?
#
            
InstallMethod(String, [IsBinarySearchTreeRep and IsOrderedSetDS],
        function(bst)
        local  s, isLess;
    s := [];
    Add(s,"OrderedSetDS(IsBinarySearchTreeRep");
    isLess := bst!.isLess;
    if isLess <> \< then
        Add(s,", ");
        Add(s,String(isLess));
    fi;
    if not IsEmpty(bst) then
        Add(s, ", ");
        Add(s, String(AsListSorted(bst)));
    fi;
    Add(s,")");
    return Concatenation(s);
end);

InstallMethod(LessFunction, [IsBinarySearchTreeRep and IsOrderedSetDS],
        bst -> bst!.isLess);
    

# TODO DisplayString
