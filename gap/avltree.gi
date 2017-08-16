#
# AVL trees  -- Same data structure as Binary Search trees, and actually the same for many purposes, but 
# adds a data field at each node in posotion 4 recording the imbalance (-1, 0 or 1) and maintains that -- both the data
# and the fact that all nodes are nearly balanced through updates. 
#

AVL := rec();

#
# This runs through a tree, checks if it is nearly balanced and if so, adds the imbalance records to all
# the nodes and sets the filter
#
AVL.ExtendBSTtoAVLTree := function(bst)
    local  avlh;
    avlh := function(b,ix)
        local  child, hl, hr;
        if not IsBound(b[ix]) then return 0; fi;
        child := b[ix];        
        hl := avlh(child,1);
        hr := avlh(child,3);
        child[4] := hr-hl;
        if child[4] < -1 or child[4] > 1 then
            Error("Not an AVL tree");
        fi;
        return 1 + Maximum(hl,hr);
    end;
    avlh(bst!.lists,1);
    SetFilterObj(bst,IsAVLTree);    
end;

#
# We make an AVL tree by making a BST and then annotating it.
# The BST constructor always makes balanced trees
#
AVL.construct := function( filts, args...)
    local  l, b;
    l := [IsBinarySearchTreeRep and IsOrderedSetDS and IsMutable];
    Append(l, args);    
    b := CallFuncList(OrderedSetDS, l);
    AVL.ExtendBSTtoAVLTree(b);
    return b;
end;


InstallMethod(OrderedSetDS, [IsAVLTree and IsBinarySearchTreeRep and IsOrderedSetDS and IsMutable, IsFunction],
        AVL.construct);

InstallMethod(OrderedSetDS, [IsAVLTree and IsBinarySearchTreeRep and IsOrderedSetDS and IsMutable],
        AVL.construct);

InstallMethod(OrderedSetDS, [IsAVLTree and IsBinarySearchTreeRep and IsMutable and IsOrderedSetDS, IsFunction, IsRandomSource],
        AVL.construct);

InstallMethod(OrderedSetDS, [IsAVLTree and IsBinarySearchTreeRep and IsMutable and IsOrderedSetDS, IsListOrCollection],
        AVL.construct);

InstallMethod(OrderedSetDS, [IsAVLTree and IsBinarySearchTreeRep and IsMutable and IsOrderedSetDS, IsOrderedSetDS],
        AVL.construct);

InstallMethod(OrderedSetDS, [IsAVLTree and IsBinarySearchTreeRep and IsMutable and IsOrderedSetDS, IsFunction, IsListOrCollection],
        AVL.construct);

InstallMethod(OrderedSetDS, [IsAVLTree and IsBinarySearchTreeRep and IsMutable and IsOrderedSetDS, IsFunction, IsIterator],
        AVL.construct);

InstallMethod(OrderedSetDS, [IsAVLTree and IsBinarySearchTreeRep and IsMutable and IsOrderedSetDS, IsIterator],
        AVL.construct);

InstallMethod(OrderedSetDS, [IsAVLTree and IsBinarySearchTreeRep and IsMutable and IsOrderedSetDS, IsListOrCollection, IsRandomSource],
        AVL.construct);

InstallMethod(OrderedSetDS, [IsAVLTree and IsBinarySearchTreeRep and IsMutable and IsOrderedSetDS, IsFunction, IsListOrCollection, IsRandomSource],
        AVL.construct);

InstallMethod(OrderedSetDS, [IsAVLTree and IsBinarySearchTreeRep and IsMutable and IsOrderedSetDS, IsFunction, IsIterator, IsRandomSource],
        AVL.construct);


#
# Now we get into worker routines. There are lots of these, becaus the algorithms are complex
# Some of these will get C implementations, others are there to be passed to the C implementations so that they 
# can call back conveniently
#

#
# Trinode restructuring
# This is called when the node avl has just become unbalanced because one of its subtrees
# has become higher after an insertion. We consider three nodes, avl, its taller child  and its taller child 
# (avls tallest grandchild)
# We reorganise these three so that the middle one in the ordering is at the top with the other two as its children and 
# the remaining subtrees attached in the only way they can be.
# There are two cases, depending on whether the grandchild is on the same side of the child as the child is of avl, or not

AVL.InsertTrinode := function(avl)
    local  i, j, y, x, dirn ;
    dirn := avl[4];
    i := 2 + dirn;
    j := 2 - dirn;        
    if avl[i][4] = dirn then        
        #
        # Same sided case, so the child y is the middle one of the three nodes
        #
        y := avl[i];
        #
        # Transfer y's smaller child to avl in place of y
        #
        if IsBound(y[j]) then            
            avl[i] := y[j];
        else
            Unbind(avl[i]);                
        fi;
        #
        # Make y the parent of avl
        #
        y[j] := avl;
        #
        # adjust imbalances 
        #
        avl[4] := 0;
        y[4] := 0;                
    else
        #
        # The other case, x is the child and y, the grandchild is the middle one of the three
        #
        x := avl[i];
        y := x[j];
        #
        # y is coming to the top, so we need to rehome both its children
        #
        if IsBound(y[i]) then
            x[j] := y[i];
        else
            Unbind(x[j]);                
        fi;
        if  IsBound(y[j]) then
            avl[i] := y[j];
        else
            Unbind(avl[i]);
        fi;
        #
        # Now we make y the new top node with x and avl as its children
        #
        y[i] := x;
        y[j] := avl;
        #
        # The new imbalances of x and avl depend on the old imbalance of y
        #
        if y[4] = dirn then
            x[4] := 0;
            avl[4] := -dirn;
        elif y[4] = 0 then
            x[4] := 0;
            avl[4] := 0;
        else
            x[4] := dirn;
            avl[4] := 0;
        fi;
        #
        # which always ends up balanced
        #
        y[4] := 0;
    fi;
    return y;
end;

#
# Here is the routine we actually plan to move into C
# returns fail if val was already present
#         0 if the subtree ends up the same depth and with the same root
#         1 if the root is the same but the subtree got deeper
#         the new root if the root changed (due to a trinode restructuring
#           in which case the tree did not get deeper      
#
AVL.AddSetInnerGAP := 
  function(avl, val, less, trinode) 
    local   d, dirn, i, j, deeper;
    
    #
    # This recursive routine inserts val into the relevant subtree of avl
    # returns fail if val was already present
    #         0 if the subtree ends up the same depth and with the same root
    #         1 if the root is the same but the subtree got deeper
    #         the new root if the root changed (due to a trinode restructuring
    #           in which case the tree did not get deeper      
    #
    #
    # Work out which subtree to look in
    #
    d := avl[2];        
    if val = d then
        return fail;            
    elif less(val, d) then
        dirn := -1;
    else
        dirn := 1;
    fi;
    
    #
    # and the index for that entry
    #
    i := 2 + dirn;            
    if not IsBound(avl[i]) then
                # inserting a new leaf here
        avl[i] := [,val,,0];
                # we have tilted over, but can't have become unbalanced by more than 1
        avl[4] := avl[4]+dirn;
                # if we are now unbalanced by 1 then the tree got deeper
        return AbsInt(avl[4]);
    else
        #
        # recurse into the subtree 
        #
        deeper := AVL.AddSetInner(avl[i],val,less, trinode);
        #
        # nothing more to do
        #
        if deeper = 0 or deeper = fail then
            return deeper;
        elif deeper = 1 then
            #
            # the subtree got deeper, so we need to adjust imbalance and maybe restructure
            #
            if avl[4] <> dirn then
                # we can do it by adjusting imbalance
                avl[4] := avl[4] + dirn;
                return AbsInt(avl[4]);                        
            else
                #
                # or we can't.
                #
                return trinode(avl);
            fi;
        else
            #
            # restructure happened just beneath our feet. Deal with it and return 
            #
            avl[i] := deeper;
            return 0;
        fi;
    fi;
end;

if IsBound(DS_AVL_ADDSET_INNER) then
    AVL.AddSetInner := DS_AVL_ADDSET_INNER;
else
    AVL.AddSetInner := AVL.AddSetInnerGAP;
fi;

#
# Just bookkeeping here.
#

InstallMethod(AddSet, [IsAVLTree and IsBinarySearchTreeRep and IsOrderedSetDS and IsMutable, IsObject],
        function(avl, val)
    local  res;
    if not IsBound(avl!.lists[1]) then
        avl!.lists[1] := [,val,,0];
        avl!.size := 1;        
        return;
    fi;
    res := AVL.AddSetInner(avl!.lists[1],val,avl!.isLess, AVL.InsertTrinode);
    if res = fail then
        return;
    fi;
    if not IsInt(res) then
        avl!.lists[1] := res;
    fi;
    avl!.size := avl!.size + 1;    
    return;
end);

#
# This is a complement to AVL.InsertTrinode that does the actual work of 
# rebalancing after a node has been deleted. This and the next routine are pulled
# out as they are not performance critical so do not need to be in C
#
        
AVL.DeleteTrinode :=  function(l)
    local  dirn, i, j, y, z, im;
    #
    # restructure the node at l which has become unbalanced because one of 
    # it's children has reduced in height
    #
    # It must already be imbalanced by 1 in some direction, and the shorter child has
    # just got shorter
    # dirn points to the taller child
    #
    # i is the index in the node for the shorter (recently shortened) child
    # j is the other one
    #
    # return value is a length 2 list. First entry is -1 or 0 the change in height of the 
    # subtree due to the restructuring. Second entry is the new top node of the subtree
    #
    #
    dirn := l[4];
    i := 2 - dirn;
    j := 2 + dirn;
    #
    # so y is the taller child
    #
    y := l[j];
    #
    # There are two cases. If y is balanced or unbalanced the same way as l
    # we have the simpler case. Otherwise a more complex one.
    #
    if y[4] <> -dirn then
        #
        # y "leans" the same way as l
        # a single rotation will do
        #
        z := y[j];
        if IsBound(y[i]) then
            l[j] := y[i];
        else 
            Unbind(l[j]);
        fi;
        y[i] := l;
        #
        # And adjust the imbalances and return
        #
        im := y[4];
        if im = dirn then
            l[4] := 0;
            y[4] := 0;
            return [-1, y];                            
        else
            l[4]  := dirn;
            y[4] := -dirn;
            return [0,y];                                                                       
        fi;
    else
        #
        # Trickier case, y has its taller child z on the "inside"
        # z is going to end up at the top and its children need to
        # be redistributed between l and y
        #
        z := y[i];
        if IsBound(z[j]) then
            y[i] := z[j];
        else
            Unbind(y[i]);
        fi;
        if IsBound(z[i]) then
            l[j] := z[i];
        else
            Unbind(l[j]);
        fi;
        z[j] := y;
        z[i] := l;
        #
        # Now sort out imbalances
        #
        im := z[4];                
        z[4] := 0;
        if im <> -dirn then
            y[4] := 0;
        else
            y[4] := dirn;
        fi;
        if im <> dirn then
            l[4] := 0;
        else
            l[4] := -dirn;
        fi;
        return [-1, z];
    fi;
end;


#
# This routine handles removal of the predecessor or successor of the data item at node l
# This is needed, just as for BSTs when l is to be deleted but has two children
# It's more complicated than for BSTs because we need to rebalance and do bookkeeping as we come up
#
AVL.Remove_Extremal := function(l, dirn)   
    local  i, j, res, res2;
    #
    # This removes the dirn-most node of the tree rooted at l. 
    # it returns a triple [<change in height>, <node removed>, <new root node>]
    # if in fact it deletes the only node in the subtree below l, it returns fail 
    # in the third component
    #
    i := 2+dirn;
    j := 2-dirn;
    if not IsBound(l[i]) then
        #
        # Found it
        #
        if IsBound(l[j]) then
            return [-1,l,l[j]];
        else
            return [-1,l,fail];
        fi;
    fi;
    
    #
    # recurse
    #
    res := AVL.Remove_Extremal(l[i],dirn);
    
    if res[3] <> fail then
        l[i] := res[3];
    else
        Unbind(l[i]);
    fi;
    
    #
    # if the subtree got shorter then adjust balance
    #
    
    if res[1] = -1 then
        if l[4] = dirn then
            l[4] := 0;
            return [-1, res[2], l];
        elif l[4] = 0 then
            l[4] := -dirn;
            return [0, res[2], l];
        else
            res2 := AVL.DeleteTrinode(l);
            return [res2[1],res[2],res2[2]];
        fi;
    else
        return [0, res[2],l];                
    fi;
end;

#
# This function captures the work that must be done when we have found the node we want to delete
#

AVL.RemoveThisNode := function(node, remove_extremal, trinode)
    local  res;
    #
    # Very similar to the BST case. By careful choices we avoid the need to 
    # restructure at this point, but we do need to do book-keeping
    # 
    # returns change in height and new node
    #
    if IsBound(node[1]) then
        if IsBound(node[3]) then  
            #
            # Both -- hard case
            #
            # We "steal" a neighbouring value from a subtree
            # if they are of unequal height, choose the higher
            # If equal go left. We don't need to alternate as we do
            # for BSTs because these trees cannot become unbalanced
            #
            if node[4] = 1 then
                res := remove_extremal(node[3],-1);
                #
                # Since we have two children and we are working on the higher one, it 
                # cannot entirely vanish
                #
                Assert(2, res[3] <> fail);
                node[3] := res[3];                        
            else
                res := remove_extremal(node[1],1);
                if res[3] = fail then
                    Unbind(node[1]);
                else
                    node[1] := res[3];                        
                fi;
                
            fi;
            #
            # Install the stolen value
            #
            node[2] := res[2][2];
            
            
            # Adjust balance
            #
            if res[1] <> 0 then
                if node[4] <> 0 then
                    #
                    # Not balanced, so now we are
                    #
                    node[4] := 0;
                    return [-1,node];                            
                else
                    #
                    # If we were balanced before, we went left
                    # 
                    node[4] := 1;
                    return [0,node];
                fi;
            else
                return [0, node];
            fi;                    
        else
            #
            # left only
            #
            return [-1,node[1]];
        fi;
    else                
        if IsBound(node[3]) then
            #
            # right only
            #
            return [-1, node[3]];                    
        else
            #
            # None
            #
            return [-1, fail];                    
        fi;
    fi;
end;


#
# Finally the time-critical recursion to find the node to delete and clean up on the way out
# This is a GAP reference implementation to the C version
#


AVL.RemoveSetInnerGAP  := function(node,val, less, remove_extremal, trinode, remove_this)
    local  d, ret, i;
    #
    # deletes val at or below this node
    # returns a pair [<change in height>, <new node>]
    #    
    
    d := node[2];
    
    if val = d then
        #
        # Found it 
        #
        return remove_this(node, remove_extremal, trinode);
    fi;
    
    if less(val, d) then
        i := 1;
    else
        i := 3;
    fi;
    
    if IsBound(node[i]) then
        ret := AVL.RemoveSetInner(node[i],val, less, remove_extremal, trinode, remove_this);            
        if ret = fail then
            return fail;
        fi;                                
        if ret[2] <> fail then
            node[i] := ret[2];
        else
            Unbind(node[i]);
        fi;
    else
        return fail;                
    fi;
    #
    # So if we get here we have deleted val somewhere below here, and replaced the subtree that might have been changed
    # by rotations, and ret[1] tells us if that subtree got shorter. If it did, we may have more work to do
    #
    #
    # We reuse ret for the return from this function to avoid garbage
    #
    if ret[1] = 0 then
        #
        # No more to do
        #
        ret[2] := node;        
        return ret;
    fi;
    #
    # or maybe all we need to do is adjust the imbalance at this node
    #
    if node[4] = i-2 then
        node[4] := 0;
        ret[2] := node;        
        return ret;
    elif node[4]  = 0 then
        node[4] := 2-i;
        ret[1] := 0;
        ret[2] := node;        
        return ret; 
    fi;                  
    #
    # Nope. Need to rebalance
    #
    return trinode(node);
end;

if IsBound(DS_AVL_REMSET_INNER) then
    AVL.RemoveSetInner := DS_AVL_REMSET_INNER;
else
    AVL.RemoveSetInner := AVL.RemoveSetInnerGAP;
fi;

    
#
# This is now just a wrapper around the "Inner" function
#

InstallMethod(RemoveSet, [IsAVLTree and IsBinarySearchTreeRep and IsOrderedSetDS and IsMutable, IsObject],
        function(avl, val)
    local  avld, ret;
    if not IsBound(avl!.lists[1]) then
        return 0;        
    fi;
    ret := AVL.RemoveSetInner(avl!.lists[1], val, avl!.isLess, AVL.Remove_Extremal, AVL.DeleteTrinode, AVL.RemoveThisNode);
    if ret = fail then
        return 0;
    fi;    
    if ret[2] <> fail then
        avl!.lists[1] := ret[2];
    else
        Unbind(avl!.lists[1]);
    fi;
    avl!.size := avl!.size -1;    
    return 1;    
end);
            
                    
#
# Utility to compute actual imbalances of every node and Assert that the
# stored data is correct
#
          
AVL.AVLCheck := function(avl)
    local  avlh;
    avlh := function(b,ix)
        local  child, hl, hr;
        if not IsBound(b[ix]) then return 0; fi;
        child := b[ix];        
        hl := avlh(child,1);
        hr := avlh(child,3);
        Assert(1,IsBound(child[4]) and child[4] = hr - hl);
        return 1 + Maximum(hl,hr);
    end;
    avlh(avl!.lists,1);
end;

InstallMethod(ViewString, [IsAVLTree  and IsBinarySearchTreeRep and IsOrderedSetDS], 
        t ->  Concatenation("<avl tree size ",String(Size(t)),">"));

#T combine common code between the three String methods in the ordered set stuff

InstallMethod(String, [IsAVLTree and IsBinarySearchTreeRep and IsOrderedSetDS],
        function(bst)
        local  s, isLess;
    s := [];
    Add(s,"OrderedSetDS(IsAVLTree");
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

#
# Copy all the nodes, but don't copy the data
#
InstallMethod(ShallowCopy, [IsAVLTree and IsBinarySearchTreeRep and IsOrderedSetDS],
        function( bst) 
    local  l, copytree;
    l := rec();
    copytree := function(node)
        local  l, x;
        l := [,node[2],,node[4]];
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
    SetFilterObj(l,IsAVLTree);
    
    return l;
    
end);


