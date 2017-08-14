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

    
             

    
            
        
            
          
                    
    
          
