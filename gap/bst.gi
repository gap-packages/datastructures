#
# Binary Search Trees not automatically balanced. 
#
#

BSTS := rec();

DeclareFilter("IsAVLTree");

IsBinarySearchTreeRep := NewRepresentation("IsBinarySearchTreeRep", IsComponentObjectRep, []);

BSTS.BSTDefaultType :=  NewType(OrderedSetsFamily, IsBinarySearchTreeRep and  IsOrderedSetDS and IsMutable);
BSTS.nullIterator := Iterator([]);



BSTS.NewBst := 
  function(isLess, set)
    Sort(set, isLess);
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


InstallMethod(OrderedSetDS, [IsBinarySearchTreeRep and IsMutable and IsOrderedSetDS, IsSet],
        function(type, data)
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



BSTS.BSTFindGAP := function(bst, val, less)
    local  ix, child, d;
    ix := 1;
    while true do
        if not IsBound(bst[ix]) then
            return [bst,ix,false];            
        fi;
        child := bst[ix];
        d := child[2];
        if less(val,d) then
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

if IsBound(DS_BST_FIND) then
    BSTS.BSTFind := DS_BST_FIND;
else
    BSTS.BSTFind := BSTS.BSTFindGAP;
fi;

    
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


InstallMethod(RemoveSet, [IsBinarySearchTreeRep and IsOrderedSetDS and IsMutable, IsObject],
        function(bsttop, val)
    local  res, bst, ix, child, i, j, x, y;
    res := BSTS.BSTFind(bsttop!.lists, val, bsttop!.isLess);
    if not res[3] then
        return 0;        
    fi;
    bst := res[1];
    ix := res[2];    
    child := bst[ix];
    if IsBound(child[1]) then
        if IsBound(child[3]) then 
            i :=  bsttop!.nextSide;
            j := 4-i;
            bsttop!.nextSide := j;            
            x := child[i];
            if IsBound(x[j]) then
                repeat
                    y := x;                        
                    x := x[j];
                until not IsBound(x[j]);
                if IsBound(x[i]) then
                    y[j] := x[i];
                else
                    Unbind(y[j]);
                fi;
                
                x[i] := child[i];
            fi;
            x[j] := child[j];
            bst[ix] := x;                
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
    ResetFilterObj(bsttop, IsAVLTree);
    bsttop!.size := bsttop!.size -1;    
    return 1;
end);

        
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

InstallMethod(Size, [IsBinarySearchTreeRep and IsOrderedSetDS],
        bst -> bst!.size);

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
               
    
          


BSTS.BSTByOrderedList := function(l)
    local  foo,x;
    foo := function(l, from, to)
        local  mid, left, right, node;
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
    if x = fail then
        return [];
    else
        return [x];
    fi;
    
end;


InstallMethod(IsEmpty, [IsBinarySearchTreeRep and IsOrderedSetDS],
        function(bst)
    local  l;
    l := bst!.lists;
    return not IsBound(l[1]);
end);


InstallMethod(IteratorSorted, [IsBinarySearchTreeRep and IsOrderedSetDS],
        function(bst)
    local  stack, node;
    stack := [];    
    node := bst!.lists;
    while IsBound(node[1]) do
        Add(stack, node[1]);
        node := node[1];
    od;
    
    return  IteratorByFunctions(rec(
                   stack := stack,
                           
                    IsDoneIterator := function(iter)
        return Length(iter!.stack) = 0;
    end,
      
      NextIterator := function(iter)
        local  node, x;
        node := Remove(stack);
        if IsBound(node[3]) then
            x := node[3];
            Add(stack,x);
            while IsBound(x[1]) do
                Add(stack,x[1]);
                x := x[1];
            od;
        fi;
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


InstallMethod(ShallowCopy, [IsBinarySearchTreeRep and IsOrderedSetDS],
        function( bst) 
    local  l, copytree;
    l := [];
    copytree := function(tree,ix)
        local  node, l, x;
        if not IsBound(tree[ix]) then
            return;
        else
            node := tree[ix];
            l := [,node[2],];
            x := copytree(node,1);
            x := copytree(node,3);
            tree[ix] := l;
            return;
        fi;
    end;
    l[BSTS.lists] := copytree(bst!.lists, 1);
    l[BSTS.isLess] := bst[BSTS.isLess];
    l[BSTS.nextSide] := bst[BSTS.nextSide];
    return Objectify(BSTS.BSTDefaultType, l);
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

    

# TODO DisplayStrinf
