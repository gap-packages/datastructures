#
# AVL trees
#

EmptyAVL := function()
    return [];
end;


AVLInsert := function(avl, val)
    local  avli, res;
    avli := function(avl, val) 
        local  avli2, d;
        avli2 := function(avl, dirn, val )
            local  i, j, deeper, y, x, c, b;
            i := 2 + dirn;
            j := 2 - dirn;
            
            if not IsBound(avl[i]) then
                avl[i] := [,val,,0];
                avl[4] := avl[4]+dirn;
                return AbsInt(avl[4]);
            else
                deeper := avli(avl[i],val);
                if not IsInt(deeper) then
                    avl[i] := deeper;
                    return 0;
                elif deeper = 0 then
                    return 0;
                else
                    if avl[4] <> dirn then
                        avl[4] := avl[4] + dirn;
                        return AbsInt(avl[4]);                        
                    else
                        if avl[i][4] = dirn then
                            y := avl[i];
                            x := y[i];
                            if IsBound(y[j]) then
                                c := y[j];
                            else
                                c := fail;
                            fi;
                            y[i] := x;
                            y[j] := avl;
                            if c <> fail then
                                avl[i] := c;
                            else 
                                Unbind(avl[i]);
                            fi;
                            avl[4] := 0;
                            y[4] := 0;                
                        else
                            x := avl[i];
                            y := x[j];
                            if IsBound(y[i]) then
                                b := y[i];
                            else
                                b := fail;
                            fi;
                            if  IsBound(y[j]) then
                                c := y[j];
                            else
                                c := fail;
                            fi;
                            y[i] := x;
                            y[j] := avl;
                            if b <> fail then
                                x[j] := b;
                            else
                                Unbind(x[j]);
                            fi;
                            if c <> fail then
                                avl[i] := c;
                            else
                                Unbind(avl[i]);
                            fi;
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
                    fi;
                fi;
            fi;
        end;
                    
            
        d := avl[2];        
        if val = d then
            Error("Already Present");
        elif val < d then
            return  avli2(avl,-1,val);            
        else
            return avli2(avl,1,val);
        fi;
    end;
    
    if not IsBound(avl[1]) then
        avl[1] := [,val,,0];
        return;
    fi;
    res := avli(avl[1],val);
    if not IsInt(res) then
        avl[1] := res;
    fi;
    return;
end;

        
 
AVLCheck := function(avl)
    local  avlh;
    avlh := function(b,ix)
        local  child, hl, hr;
        if not IsBound(b[ix]) then return 0; fi;
        child := b[ix];        
        hl := avlh(child,1);
        hr := avlh(child,3);
        if child[4] <> hr-hl then
            Error("mismatch");
        fi;
        return 1 + Maximum(hl,hr);
    end;
    return avlh(avl,1);
end;


avlbench := function(n)
    local  pi, l, t, i;
    pi := Random(SymmetricGroup(n));
    l := ListPerm(pi,n);
    t := EmptyAVL();    
    for i in l do
        AVLInsert(t,i);
    od;
end;

avlbench2 := function(n)
    local  pi, l, t, i;
    pi := Random(SymmetricGroup(n));
    l := ListPerm(pi,n);
    t := EmptyAVL();    
    for i in l do
        AVLInsert(t,i);
    od;
    pi := Random(SymmetricGroup(n));
    l := ListPerm(pi,n);
    for i in l do
#        Print(i," ",t,"\n");        
        AVLDelete(t,i);
#        AVLCheck(t);
        
    od;
        
end;

    
AVLDelete := function(avl, val)
    local  avld, ret;
    avld := function(node)
        local  trinode, remove_extremal, res, dirn, ret;
         #
        # deletes val at or below this node
        # returns a pair [<change in height>, <new node>]
        #
        trinode := function(l)
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
        
                
                

        remove_extremal := function(l, dirn)   
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
            res := remove_extremal(l[i],dirn);
            
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
                    res2 := trinode(l);
                    return [res2[1],res[2],res2[2]];
                fi;
            else
                return [0, res[2],l];                
            fi;
        end;
        
        
        
        if val = node[2] then
            #
            # Found it -- four cases depending on whether, and which children node has
            #
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
                    # Install the stolen cvalue
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
        elif val < node[2] then
            dirn := -1;
            if IsBound(node[1]) then
                ret := avld(node[1]);            
                if ret[2] <> fail then
                    node[1] := ret[2];
                else
                    Unbind(node[1]);
                fi;
            else
                Error("Not present");
            fi;
        else
            dirn := 1;            
            if IsBound(node[3]) then
                ret := avld(node[3]);            
                if ret[2] <> fail then
                    node[3] := ret[2];
                else
                    Unbind(node[3]);
                fi;
            else
                Error("Not present");
            fi;
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
        if node[4] = dirn then
            node[4] := 0;
            return [-1, node];
        elif node[4]  = 0 then
            node[4] := -dirn;
            return [0,node];
        fi;
        
        
        #
        # Nope. Need to rebalance
        #
        
        return trinode(node);
    end;
    
    if not IsBound(avl[1]) then
        Error("Not present");
    fi;
    ret := avld(avl[1]);
    if ret[2] <> fail then
        avl[1] := ret[2];
    else
        Unbind(avl[1]);
    fi;
end;

        
            
            
           
          

    
            
        
            
          
                    
    
          
