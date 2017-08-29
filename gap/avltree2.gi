#
# Second AVL Tree Implementations
#
# The plan is that these will use bitfields to efficiently implement threading and keep track of subtree size
# so that we can have a fast enumerator. Because of the threading they will not be extensions of BSTs
#
#

#
# The nodes of our Tree are plain lists of length 4. Entry 1 is the left child, or predecessor, 
# entry 2 the data and entry 3 the right child or successor
# entry 4 has four bitfields: imbalance (2 bits), has_leftchild (1), has_rightchild (2) and size (the rest)
# The root of the tree is held in a length 1 plain list, which is then held in a component object.
#

#
# REcord for "local" things
#
AVL2 := rec();


IsAVLTreeRep := NewRepresentation("IsAVLTreeRep", IsComponentObjectRep, []);

AVL2.DefaultType :=  NewType(OrderedSetDSFamily, IsAVLTreeRep and  IsOrderedSetDS and IsMutable);
AVL2.nullIterator := Iterator([]);

AVL2.Bitfields := MakeBitfields(2,1,1,GAPInfo.BytesPerVariable*8-8);
AVL2.getImbalance := AVL2.Bitfields.getters[1];
AVL2.setImbalance := AVL2.Bitfields.setters[1];
AVL2.hasLeft := AVL2.Bitfields.booleanGetters[2];
AVL2.setHasLeft := AVL2.Bitfields.booleanSetters[2];
AVL2.hasRight := AVL2.Bitfields.booleanGetters[3];
AVL2.setHasRight := AVL2.Bitfields.booleanSetters[3];
AVL2.getSize := AVL2.Bitfields.getters[4];
AVL2.setSize := AVL2.Bitfields.setters[4];

#
# Worker function for construction -- relies on the fact that we can make a perfectly balanced BST in linear time 
# from a sorted list of objects.
#

AVL2.NewTree := 
  function(isLess, set)
    if not IsSet(set) or isLess <> \< then
        if not IsMutable(set) then
            set := ShallowCopy(set);
        fi;
        Sort(set, isLess);
    fi;
    return Objectify( AVL2.DefaultType, rec(
                   lists := AVL2.TreeByOrderedList(set),
                   isLess := isLess));
end;

InstallMethod(OrderedSetDS, [IsAVLTreeRep and IsOrderedSetDS and IsMutable, IsFunction],
        function(type, isLess)
    return AVL2.NewTree(isLess, []);
end);

InstallMethod(OrderedSetDS, [IsAVLTreeRep and IsOrderedSetDS and IsMutable],
        function(type)
    return AVL2.NewTree(\<, []);
end);

InstallMethod(OrderedSetDS, [IsAVLTreeRep and IsMutable and IsOrderedSetDS, IsFunction, IsRandomSource],
        function(type, isLess, rs)
    return AVL2.NewTree(isLess, []);
end);

InstallMethod(OrderedSetDS, [IsAVLTreeRep and IsMutable and IsOrderedSetDS, IsListOrCollection],
        function(type, data)
    return AVL2.NewTree(\<, data);
end);

InstallMethod(OrderedSetDS, [IsAVLTreeRep and IsMutable and IsOrderedSetDS, IsListOrCollection, IsRandomSource],
        function(type, data, rs)
    return AVL2.NewTree(\<, data);
end);

InstallMethod(OrderedSetDS, [IsAVLTreeRep and IsMutable and IsOrderedSetDS, IsOrderedSetDS],
        function(type, os)
    return AVL2.NewTree(\<, AsListSorted(os));
end);

InstallMethod(OrderedSetDS, [IsAVLTreeRep and IsMutable and IsOrderedSetDS, IsFunction, IsListOrCollection],
        function(type, isLess, data)
    return AVL2.NewTree(isLess, data);
end);
#
# If we're given an iterator, worth the time to drain and sort
#
InstallMethod(OrderedSetDS, [IsAVLTreeRep and IsMutable and IsOrderedSetDS,  IsIterator],
        function(type, iter)
    local  l, x;
    l := [];
    for x in iter do
        Add(l,x);
    od;
    return AVL2.NewTree(\<, l);
end);

InstallMethod(OrderedSetDS, [IsAVLTreeRep and IsMutable and IsOrderedSetDS, IsFunction, IsIterator],
        function(type, isLess, iter)
    local  l, x;
    l := [];
    for x in iter do
        Add(l,x);
    od;
    return AVL2.NewTree(isLess, l);
end);

InstallMethod(OrderedSetDS, [IsAVLTreeRep and IsMutable and IsOrderedSetDS, IsFunction, IsListOrCollection, IsRandomSource],
        function(type, isLess, data, rs)
    return AVL2.NewTree(isLess, data);
end);

InstallMethod(OrderedSetDS, [IsAVLTreeRep and IsMutable and IsOrderedSetDS, IsFunction, IsIterator, IsRandomSource],
        function(type, isLess, iter, rs)
    local  l, x;
    l := [];
    for x in iter do
        Add(l,x);
    od;
    return AVL2.NewTree(isLess, l);
end);


#
# A worker function used when we are searching the tree, but NOT modifying it
# C version to follow. Returns the node containing val, or fail.
#

AVL2.FindGAP := function(tree, val, less, ghl, ghr)
    local  node, d, flags;
    #
    # node is the current node 
    #
    if not IsBound(tree[1]) then
        return fail;
    fi;
    node := tree[1];
    while true do
        d := node[2];
        
        #
        # Work out which way to go next
        #
        
        if val = d then
            return node;
        fi;
        flags := node[4];
        if less(val,d) then
            if ghl(flags) then
                node := node[1];
            else
                return fail;
            fi;
        elif ghr(flags)  then
            node := node[3];
        else
            return fail;
        fi;
    od;
end;

#
# Prefer the C version
#
if IsBound(DS_AVL2_FIND) then
    AVL2.Find := DS_AVL2_FIND;
else
    AVL2.Find := AVL2.FindGAP;    
fi;

#
# With this worker function \in is really easy
#
    
InstallMethod(\in, [IsAVLTreeRep and IsOrderedSetDS and IsMutable, IsObject],        
function(tree, val)
    return fail <> AVL2.Find(tree!.lists, val, tree!.isLess, AVL2.hasLeft, AVL2.hasRight);
    end);


#
# Some classic utility functions
#
        
AVL2.Height := function(tree)
    local  avlh;
    if not IsBound(tree!.lists[1]) then 
        return 0;
    fi;
    avlh := function(node)
        local  flags, hl, hr;
        flags := node[4];
        if AVL2.hasLeft(flags) then
            hl := avlh(node[1]);
        else
            hl := 0;
        fi;
        if AVL2.hasRight(flags) then
            hr := avlh(node[3]);
        else
            hr := 0;
        fi;
        return 1 + Maximum(hl,hr);
    end;
    return avlh(tree!.lists[1]);
end;


AVL2.CheckSize := function(node)
    local  flags, sl, sr, s;
    flags := node[4];
    if AVL2.hasLeft(flags) then
        sl := AVL2.CheckSize(node[1]);
    else
        sl := 0;
    fi;
    if AVL2.hasRight(flags) then
        sr := AVL2.CheckSize(node[3]);
    else
        sr := 0;
    fi;
    if sl = false or sr = false then
        return false;
    fi;
    s := 1+sl+sr;
    if s <> AVL2.getSize(flags) then
        return false;
    else
        return s;
    fi;
end;
    
           
InstallMethod(Size, [IsAVLTreeRep and IsOrderedSetDS],
function(tree)
    if not IsBound(tree!.lists[1]) then
        return 0;
    else
        return AVL2.getSize(tree!.lists[1][4]);
    fi;
end);

          
#
#  Used in the constructors
#  build tree directly by divide and conquer
#

AVL2.TreeByOrderedList := function(l)
    local  foo,x;
    foo := function(l, from, to)
        local  mid, left, right, node, hl, hasl, min, hr, hasr, max;
        #
        # returns a list
        # [height of subtree, root node, min node, max node]
        # representing the section of l from from to to 
        # inclusive or fail if from > to
        #
        if from > to then
            return fail;
        fi;        
        mid := QuoInt(from + to,2);
        left := foo(l,from, mid-1);
        right := foo(l, mid+1, to);
        node := [,l[mid],,];
        #
        # We have a left subtree, note it and link it's rightmost
        # nodes thread pointer to the current node
        #
        if left <> fail then
            node[1] := left[2];
            hl := left[1];            
            hasl := 1;            
            left[4][3] := node;
            min := left[3];
        else
            hasl := 0;
            hl := 0; 
            min := node;            
        fi;
        #
        # and the same on the other side
        #
        if right <> fail then
            node[3] := right[2];
            hr := right[1];            
            hasr := 1;  
            right[3][1] := node;
            max := right[4];            
        else
            hasr := 0;
            hr := 0;        
            max := node;
        fi;
        #
        # Now assemble the bitfield with all the miscellaneous data
        #
        node[4] := AVL2.Bitfields.builder(hr-hl+1, hasl, hasr, to - from + 1);
        return [Maximum(hl,hr)+1, node, min, max];
    end;
    x := foo(l, 1, Length(l));
    #
    # wrap result up nicely
    #
    if x = fail then
        return [];
    else
        return [x[2]];
    fi;
end;


#
# Since we don't have parent pointers or threading, there is a little work to do here

AVL2.MinimalNode := function(rootnode)
    local  x, ghl;
    x := rootnode;
    ghl := AVL2.hasLeft;
    while ghl(x[4]) do
        x := x[1];
    od;
    return x;
end;

AVL2.MaximalNode := function(rootnode)
    local  x, ghr;
    x := rootnode;
    ghr := AVL2.hasRight;
    while ghr(x[4]) do
        x := x[3];
    od;
    return x;
end;


    

InstallMethod(IteratorSorted, [IsAVLTreeRep and IsOrderedSetDS],
        function(tree)
    if not IsBound(tree!.lists[1]) then
        return AVL2.nullIterator;
    fi;
    return  IteratorByFunctions(rec(
                    node := AVL2.MinimalNode(tree!.lists[1]),
                    IsDoneIterator := iter -> iter!.node = fail,
                    NextIterator := function(iter)
        local  toreturn, node;
        toreturn := iter!.node[2];        
        if  AVL2.hasRight(iter!.node[4]) then
            iter!.node :=  AVL2.MinimalNode(iter!.node[3]);
        elif IsBound(iter!.node[3]) then
            iter!.node := iter!.node[3];
        else
            iter!.node := fail;            
        fi;
        return toreturn;
    end,
    
    ShallowCopy := function(iter)
        return rec(node := iter!.node,
                   IsDoneIterator := iter!.IsDoneIterator,
                   NextIterator := iter!.NextIterator,
                   ShallowCopy := iter!.ShallowCopy,
                   PrintObj := iter!.PrintObj);
    end,
    
      PrintObj := function(iter)
        Print("<Iterator of AVL tree>");
    end ));
end);


InstallMethod(ViewString, [IsAVLTreeRep and IsOrderedSetDS], 
        t ->  Concatenation("<avl size ",String(Size(t)),">"));



if false then
#
    # We copy the tree, but not the data.
    #
    # Threading makes this harder -- maybe flattend and rebuild
    #
#
InstallMethod(ShallowCopy, [IsBinarySearchTreeRep and IsOrderedSetDS],
        function( tree) 
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
    l.lists := [copytree(tree!.lists[1])];
    l.isLess := tree!.isLess;
    Objectify(AVL2.DefaultType, l);

    return l;
end);

fi;

#
# This is more of less the same method as for Skiplists -- unify?
#
            
InstallMethod(String, [IsAVLTreeRep and IsOrderedSetDS],
        function(avl)
        local  s, isLess;
    s := [];
    Add(s,"OrderedSetDS(IsAVLTreeRep");
    isLess := avl!.isLess;
    if isLess <> \< then
        Add(s,", ");
        Add(s,String(isLess));
    fi;
    if not IsEmpty(avl) then
        Add(s, ", ");
        Add(s, String(AsListSorted(avl)));
    fi;
    Add(s,")");
    return Concatenation(s);
end);



InstallMethod(LessFunction, [IsAVLTreeRep and IsOrderedSetDS],
        tree -> tree!.isLess);
    



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

AVL2.InsertTrinode := function(avl)
    local  gim, sim, gs, ss, dirn, i, j, ghi, shi, ghj, shj, y, sc, 
           totsz, x, iy, totsiz, sa;
    gim := AVL2.getImbalance;    
    sim := AVL2.setImbalance;    
    gs := AVL2.getSize;    
    ss := AVL2.setSize;    
    dirn := gim(avl[4]);
    if dirn = 0 then
        i := 1;
        j := 3;      
        ghi := AVL2.hasLeft;
        shi := AVL2.setHasLeft;
        ghj := AVL2.hasRight;
        shj := AVL2.setHasRight;
    else
        i := 3;
        j := 1;      
        ghi := AVL2.hasRight;
        shi := AVL2.setHasRight;
        ghj := AVL2.hasLeft;
        shj := AVL2.setHasLeft;
    fi;
    
    if gim(avl[i][4]) = dirn then        
        #
        # Same sided case, so the child y is the middle one of the three nodes
        #
        y := avl[i];
        #
        # Transfer y's smaller child to avl in place of y
        # and make avl a child of y
        #
        if ghj(y[4])  then            
            avl[i] := y[j];
            y[j] := avl;
        else
            #
            # No child, so set thread pointer
            # In this case y[j] is already avl, but we need
            # to change the bit that determines the meaning of that field
            #
            avl[i] := y;
            avl[4] := shi(avl[4],false);            
            y[4] := shj(y[4],true);        
        fi;
        #
        # adjust imbalances 
        #
        avl[4] := sim(avl[4],1);
        y[4] := sim(y[4],1);                
        #
        # adjust sizes 
        #
        if ghi(y[4]) then
            sc := gs(y[i][4]);
        else
            sc := 0;
        fi;
        totsz := gs(avl[4]);        
        y[4] := ss(y[4],totsz+1);
        avl[4] := ss(avl[4],totsz-sc);
    else
        #
        # The other case, x is the child and y, the grandchild is the middle one of the three
        #
        x := avl[i];
        y := x[j];
        #
        # y is coming to the top, so we need to rehome both its children
        #
        if  ghi(y[4]) then
            x[j] := y[i];
        else
            #
            # link from x continues to point at y but changes meaning
            #
            x[4] := shj(x[4],false);
        fi;
        if  ghj(y[4]) then
            avl[i] := y[j];            
        else
            #
            # link from avl points back up to y
            #
            avl[i] := y;
            avl[4] := shi(avl[4],false);            
        fi;
        #
        # Now we make y the new top node with x and avl as its children
        #
        y[i] := x;
        y[j] := avl;
        y[4] := shi(shj(y[4],true),true);        
        #
        # The new imbalances of x and avl depend on the old imbalance of y
        #
        iy := gim(y[4]);
        if iy = dirn then
            x[4] := sim(x[4], 1);
            avl[4] := sim(avl[4],2-dirn);
        elif iy = 1 then
            x[4] := sim(x[4],1);
            avl[4] := sim(avl[4],1);
        else
            x[4] := sim(x[4],dirn);
            avl[4] := sim(avl[4],1);
        fi;
        #
        # which always ends up balanced
        #
        y[4] := sim(y[4],1);
        #
        # Finally we need to set all the sizes        
        #
        totsiz := gs(avl[4])+1;        
        y[4] := ss(y[4],totsiz);
        sa := 1;
        if  ghi(avl[4]) then
            sa := sa+gs(avl[i][4]);
        fi;
        if  ghj(avl[4]) then
            sa := sa+gs(avl[j][4]);
        fi;
        avl[4] := ss(avl[4],sa);
        x[4] := ss(x[4], totsiz-sa-1);
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
AVL2.AddSetInnerGAP := 
  function(avl, val, less, trinode) 
    local  d, i, j, ghi, shi, dirn, gim, sim, gs, ss, newnode, im, 
           deeper;
    
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
        i := 1;
        j := 3;      
        ghi := AVL2.hasLeft;
        shi := AVL2.setHasLeft;
        dirn := 0;
    else
        dirn := 2;
        i := 3;
        j := 1;      
        ghi := AVL2.hasRight;
        shi := AVL2.setHasRight;
    fi;
    
    gim := AVL2.getImbalance;    
    sim := AVL2.setImbalance;    
    gs := AVL2.getSize;    
    ss := AVL2.setSize;    
    
    if not ghi(avl[4]) then
        # inserting a new leaf here
        newnode := [,val,,AVL2.Bitfields.builder(1,0,0,1)];
        newnode[j] := avl;
        if IsBound(avl[i]) then           
            newnode[i] := avl[i];
        fi;        
        avl[i] := newnode;
        avl[4] := ss(shi(avl[4], true),gs(avl[4])+1);
        
        # we have tilted over, but can't have become unbalanced by more than 1
        im := gim(avl[4])+dirn-1;        
        avl[4] := sim(avl[4],im);        
                # if we are now unbalanced by 1 then the tree got deeper
        return AbsInt(im-1);
    else
        #
        # recurse into the subtree 
        #
        deeper := AVL2.AddSetInner(avl[i],val,less, trinode);
        #
        # nothing more to do
        #
        if deeper = 0 then
            avl[4] := ss(avl[4],gs(avl[4])+1);
            return 0;
        elif deeper = fail then
            return fail;
        elif deeper = 1 then
            #
            # the subtree got deeper, so we need to adjust imbalance and maybe restructure
            #
            im := gim(avl[4]);
            if im <> dirn then
                # we can do it by adjusting imbalance
                im := im+dirn-1;
                # also update size
                avl[4] := ss(sim(avl[4],im),gs(avl[4])+1);                
                return AbsInt(im-1);                        
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
            avl[4] := ss(avl[4],gs(avl[4])+1);            
            return 0;
        fi;
    fi;
end;

if IsBound(DS_AVL2_ADDSET_INNER) then
    AVL2.AddSetInner := DS_AVL2_ADDSET_INNER;
else
    AVL2.AddSetInner := AVL2.AddSetInnerGAP;
fi;

#
# Just bookkeeping here.
#

InstallMethod(AddSet, [IsAVLTreeRep and IsOrderedSetDS and IsMutable, IsObject],
        function(avl, val)
    local  res;
    if not IsBound(avl!.lists[1]) then
        avl!.lists[1] := [,val,,AVL2.Bitfields.builder(1,0,0,1)];
        return;
    fi;
    res := AVL2.AddSetInner(avl!.lists[1],val,avl!.isLess, AVL2.InsertTrinode);
    if res = fail then
        return;
    fi;
    if not IsInt(res) then
        avl!.lists[1] := res;
    fi;
    return;
end);

#
# This is a complement to AVL.InsertTrinode that does the actual work of 
# rebalancing after a node has been deleted. This and the next routine are pulled
# out as they are not performance critical so do not need to be in C
#

InstallMethod(DisplayString, [IsAVLTreeRep],
        function(tree)
    local  nodestring, layer, s, newlayer, node;
    if not IsBound(tree!.lists[1]) then
        return "<empty tree>";
    fi;
    nodestring := function(node)
        local  s;
        s := ["<",ViewString(node[2]),": ",String(AVL2.getSize(node[4])), " ",
                     ["l","b","r"][AVL2.getImbalance(node[4])+1]," "];
        if not IsBound(node[1]) then 
            Add(s, ". ");
        elif  AVL2.hasLeft(node[4]) then
            Append(s, ["<",ViewString(node[1][2]),"> "]);
        else
            Append(s, ["(",ViewString(node[1][2]),") "]);
        fi;
        if not IsBound(node[3]) then 
            Add(s, ".");
        elif AVL2.hasRight(node[4]) then
            Append(s, ["<",ViewString(node[3][2]),"> "]);
        else
            Append(s, ["(",ViewString(node[3][2]),") "]);
        fi;
        Add(s,">");
        return Concatenation(s);
    end;
    layer := [tree!.lists[1]];
    s := [];    
    while Length(layer) > 0 do
        newlayer := [];
        for node in layer do
            Add(s,nodestring(node));
            Add(s," ");           
            if AVL2.hasLeft(node[4]) then
                Add(newlayer, node[1]);
            fi;
            if AVL2.hasRight(node[4]) then
                Add(newlayer, node[3]);
            fi;
        od;
        Add(s,"\n");
        layer := newlayer;
    od;
    return Concatenation(s);
end);

   
            
        
        

if false then        
AVL.DeleteTrinode :=  function(l)
    local  dirn, i, j, y, z, im;
    #
    # restructure the node at l which has become unbalanced because one of 
    # its children has reduced in height
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



fi;
