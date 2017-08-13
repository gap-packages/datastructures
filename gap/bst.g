#
# Binary Search Trees not automatically balanced. 
# Even with randomly ordered data these become quite imbalanced while 
# deleting
#

EmptyBST := function()
    return [];
end;

BSTFind := function(bst, val)
    local  ix, child, d;
    ix := 1;
    while true do
        if not IsBound(bst[ix]) then
            return [bst,ix,false];            
        fi;
        child := bst[ix];
        d := child[2];
        if val < d then
            bst := child;
            ix := 1;
        elif val <> d then
            bst := child;
            ix := 3;
        else
            return [bst, ix, true];            
        fi;
    od;
end;
    
        
BSTInsert := function(bst, val)
    local  res;
    res := BSTFind(bst, val);
    if res[3] then
        Error("Already present");
    else
        res[1][res[2]] := [,val,];
    fi;
end;

BSTIn := function(bst, val)
    return BSTFind(bst,val)[3];
end;


BSTDelete := function(bst, val)
    local  res, ix, child, x;
    res := BSTFind(bst, val);
    if not res[3] then
        Error("Not present");
    fi;
    bst := res[1];
    ix := res[2];    
    child := bst[ix];
    if IsBound(child[1]) then
        if IsBound(child[3]) then 
            if Random([true, false]) then
                x := child[1];
                while IsBound(x[3]) do
                    x := x[3];
                od;
                x[3] := child[3];
                bst[ix] := child[1];                
            else
                x := child[3];
                while IsBound(x[1]) do
                    x := x[1];
                od;
                x[1] := child[1];
                bst[ix] := child[3];                
            fi;
        else
            bst[ix] := child[1];        
        fi;
        

    else 
        if IsBound(child[3]) then
            bst[ix] := child[3];
        else
            Unbind(bst[ix]);            
        fi;
    fi;
    return;
end;

        
BSTHeight := function(bst)
    local  bsth;
    bsth := function(b,ix)
        local  child;
        if not IsBound(b[ix]) then return 0; fi;
        child := b[ix];        
        return 1 + Maximum(bsth(child,1), bsth(child,3));
    end;
    return bsth(bst,1);
end;

BSTSize := function(bst)
    local  bsts;
    bsts := function(b,ix)
        local  child;
        if not IsBound(b[ix]) then return 0; fi;
        child := b[ix];        
        return 1 + bsts(child,1)+ bsts(child,3);
    end;
    return bsts(bst,1);
end;

BSTImbalance := function(bst)
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
    return bsthi(bst,1)[2];
end;

    
             

    
            
        
            
          
                    
    
          
