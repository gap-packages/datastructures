#
# AVL trees  -- Same data structure as Binary Search trees, and actually the same for many purposes, but 
# adds a data field at each node recording the imbalance (-1, 0 or 1) and maintains that -- both the data
# and the fact that all nodes are nearly balanced through updates. 
#

AVL := rec();

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


InstallMethod(OrderedSetDS, [IsAVLTree and IsBinarySearchTreeRep and IsMutable and IsOrderedSetDS, IsSet],
        AVL.construct);

InstallMethod(OrderedSetDS, [IsAVLTree and IsBinarySearchTreeRep and IsMutable and IsOrderedSetDS, IsOrderedSetDS],
        AVL.construct);

InstallMethod(OrderedSetDS, [IsAVLTree and IsBinarySearchTreeRep and IsMutable and IsOrderedSetDS, IsFunction, IsListOrCollection],
        AVL.construct);

InstallMethod(OrderedSetDS, [IsAVLTree and IsBinarySearchTreeRep and IsMutable and IsOrderedSetDS, IsFunction, IsIterator],
        AVL.construct);

InstallMethod(OrderedSetDS, [IsAVLTree and IsBinarySearchTreeRep and IsMutable and IsOrderedSetDS, IsFunction, IsListOrCollection, IsRandomSource],
        AVL.construct);

InstallMethod(OrderedSetDS, [IsAVLTree and IsBinarySearchTreeRep and IsMutable and IsOrderedSetDS, IsFunction, IsIterator, IsRandomSource],
        AVL.construct);


AVL.InsertTrinode := function(avl, dirn)
    local  i, j, y, x;
    i := 2 + dirn;
    j := 2 - dirn;        
    if avl[i][4] = dirn then
        y := avl[i];
        if IsBound(y[j]) then
            avl[i] := y[j];
        else
            Unbind(avl[i]);                
        fi;
        y[j] := avl;
        avl[4] := 0;
        y[4] := 0;                
    else
        x := avl[i];
        y := x[j];
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
        y[i] := x;
        y[j] := avl;
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
        y[4] := 0;
    fi;
    return y;
end;

AVL.AddSetInnerGAP := 
  function(avl, val, less, trinode) 
    local  avli2, d;
    avli2 := function(avl, dirn, val, less, trinode )
        local  i, j, deeper;
        i := 2 + dirn;            
        if not IsBound(avl[i]) then
            avl[i] := [,val,,0];
            avl[4] := avl[4]+dirn;
            return AbsInt(avl[4]);
        else
            deeper := AVL.AddSetInner(avl[i],val,less, trinode);
            if deeper = 0 or deeper = fail then
                return deeper;
            elif deeper = 1 then
                if avl[4] <> dirn then
                    avl[4] := avl[4] + dirn;
                    return AbsInt(avl[4]);                        
                else
                    return trinode(avl,dirn);
                fi;
            else
                avl[i] := deeper;
                return 0;
            fi;
        fi;
    end;
    d := avl[2];        
    if val = d then
        return fail;            
    elif less(val, d) then
        return  avli2(avl,-1,val,less, trinode);            
    else
        return avli2(avl,1,val,less, trinode);
    fi;
end;

if IsBound(DS_AVL_ADDSET_INNER) then
    AVL.AddSetInner := DS_AVL_ADDSET_INNER;
else
    AVL.AddSetInner := AVL.AddSetInnerGAP;
fi;

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

        
AVL.DeleteTrinode :=  function(l)
    local  dirn, i, j, y, z, im;
            #
            # restructure the node at l which has become unbalanced because one of 
            # it's children has reduced in height
            #
    dirn := l[4];
    i := 2 - dirn;
    j := 2 + dirn;
    y := l[j];
    if y[4] <> -dirn then
        z := y[j];
        if IsBound(y[i]) then
            l[j] := y[i];
        else 
            Unbind(l[j]);
        fi;
        y[i] := l;
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
 
AVL.Remove_Extremal := function(l, dirn)   
    local  i, j, res, res2;
    #
    # This removes the dirn-most node of the tree rooted at l. 
    # it returns a triple [<change in height>, <node removed>, <new root node>]
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

AVL.RemoveThisNode := function(node, remove_extremal, trinode)
    local  res;
    if IsBound(node[1]) then
        if IsBound(node[3]) then  
            #
            # Both -- hard case
            #
            # We "steal" a neighbouring value from a subtree
            # if they are of unequal height, choose the higher
            #
            if node[4] = 1 then
                res := remove_extremal(node[3],-1);
                if res[3] = fail then
                    Unbind(node[3]);
                else
                    node[3] := res[3];                        
                fi;
                
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
                    node[4] := 0;
                    return [-1,node];                            
                else
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
    if ret[1] = 0 then
        #
        # No more to do
        #
        return [0, node];
    fi;
    
    #
    # or maybe all we need to do is adjust the imbalance at this node
    #
    if node[4] = i-2 then
        node[4] := 0;
        return [-1, node];
    elif node[4]  = 0 then
        node[4] := 2-i;
        return [0,node];
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
            
                    
    
          
AVL.AVLCheck := function(avl)
    local  avlh;
    avlh := function(b,ix)
        local  child, hl, hr;
        if not IsBound(b[ix]) then return 0; fi;
        child := b[ix];        
        hl := avlh(child,1);
        hr := avlh(child,3);
        if child[4] <> hr-hl then
            return fail;            
        fi;
        return 1 + Maximum(hl,hr);
    end;
    avlh(avl!.lists,1);
    return true;
    
end;


#
# Need a shallowcopy that preserves the imbalance data
# and Print and view methods that retain the avl info.
#
