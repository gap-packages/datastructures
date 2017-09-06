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
AVL2.DefaultTypeStandard :=  NewType(OrderedSetDSFamily, IsAVLTreeRep and  IsStandardOrderedSetDS and IsMutable);
AVL2.nullIterator := Iterator([]);

AVL2.Bitfields := MakeBitfields(2,1,1,GAPInfo.BytesPerVariable*8-8);
AVL2.getImbalance := AVL2.Bitfields.getters[1];
AVL2.setImbalance := AVL2.Bitfields.setters[1];
AVL2.hasLeft := AVL2.Bitfields.booleanGetters[2];
AVL2.setHasLeft := AVL2.Bitfields.booleanSetters[2];
AVL2.hasRight := AVL2.Bitfields.booleanGetters[3];
AVL2.setHasRight := AVL2.Bitfields.booleanSetters[3];
AVL2.getSubtreeSize := AVL2.Bitfields.getters[4];
AVL2.setSubtreeSize := AVL2.Bitfields.setters[4];

#
# Worker function for construction -- relies on the fact that we can make a perfectly balanced BST in linear time 
# from a sorted list of objects.
#

AVL2.NewTree := 
  function(isLess, set)
    local type;    
    if not IsSet(set) or isLess <> \< then
        if not IsMutable(set) then
            set := ShallowCopy(set);
        fi;
        Sort(set, isLess);
    fi;
    if isLess = \< then
        type := AVL2.DefaultTypeStandard;
    else
        type := AVL2.DefaultType;
    fi;
    
    return Objectify( type, rec(
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
    return AVL2.NewTree(\<, AsSortedList(os));
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
    
InstallMethod(\in, [IsObject, IsAVLTreeRep and IsOrderedSetDS],        
function(val, tree)
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
    if s <> AVL2.getSubtreeSize(flags) then
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
        return AVL2.getSubtreeSize(tree!.lists[1][4]);
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


    

AVL2.MakeIterator := 
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
end;


InstallMethod(Iterator, [IsAVLTreeRep and IsOrderedSetDS],
        AVL2.MakeIterator);


InstallMethod(IteratorSorted, [IsStandardOrderedSetDS and IsAVLTreeRep],
        AVL2.MakeIterator);

InstallMethod(ViewString, [IsAVLTreeRep and IsOrderedSetDS], 
        t ->  Concatenation("<avl size ",String(Size(t)),">"));


InstallMethod(AsList, [IsAVLTreeRep and IsOrderedSetDS],
        function(tree)
    if not IsMutable(tree) then
        return tree;
    fi;
    TryNextMethod();
end);

InstallMethod(AsSSortedList, [IsAVLTreeRep and IsStandardOrderedSetDS],
        function(tree)
    if not IsMutable(tree) then
        return tree;
    fi;
    TryNextMethod();
end);
        


#
# We copy the tree, but not the data.
#
# Threading makes this harder -- maybe flattend and rebuild
# means that the copy is not the same shape as the original
#
#
    InstallMethod(ShallowCopy, [IsAVLTreeRep and IsOrderedSetDS],
            tree -> OrderedSetDS(IsAVLTreeRep, tree));



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
        Add(s, String(AsList(avl)));
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


#
# Try and write a single trinode function that will do insert and delete
#

AVL2.Trinode := function(avl)
    local  gim, sim, gs, ss, htchange, aflags, dirn, i, j, ghi, shi, 
           ghj, shj, y, yflags, im, sa, sb, sc, z, zflags, iz, sd;
    gim := AVL2.getImbalance;    
    sim := AVL2.setImbalance;    
    gs := AVL2.getSubtreeSize;    
    ss := AVL2.setSubtreeSize;    
    #
    # We restructure on the taller side
    # i points that way, j the opposite
    # Return value is a length 2 list [<change in height>,<new top node>]
    #
    htchange := -1;    
    aflags := avl[4];    
    dirn := gim(aflags);
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
    
    y := avl[i];
    yflags := y[4];
    
    if gim(yflags) <> 2-dirn then        
        #
        # Same sided case, so the child y is the middle one of the three nodes
        #
        
        #
        # Transfer y's smaller child to avl in place of y
        # and make avl a child of y
        #
        if ghj(yflags)  then            
            avl[i] := y[j];
            y[j] := avl;
        else
            #
            # No child, so set thread pointer
            # In this case y[j] is already avl, but we need
            # to change the bit that determines the meaning of that field
            #
            avl[i] := y;
            aflags := shi(aflags,false);            
            yflags := shj(yflags,true);        
        fi;
        #
        # adjust imbalances 
        #
        #
        # depends on whether y was balanced before
        #
        im := gim(yflags);
        if im = 1 then
            #
            # This can only happen while deleting
            #
            aflags := sim(aflags,dirn);
            yflags := sim(yflags,2-dirn);
            htchange := 0;
            
        else
            aflags := sim(aflags,1);
            yflags := sim(yflags,1);                
        fi;
        
        #
        # adjust sizes 
        #
        # get the sizes of the 3 subtrees below avl and y
        #
        if ghj(aflags) then
            sa := gs(avl[j][4]);
        else
            sa := 0;
        fi;
        if ghi(aflags) then
            sb := gs(avl[i][4]);
        else
            sb := 0;
        fi;        
        if ghi(yflags) then
            sc := gs(y[i][4]);
        else
            sc := 0;
        fi;
        y[4] := ss(yflags,sa+sb+sc+2);
        avl[4] := ss(aflags,sa+sb+1);
        #
        # return value is the new top node
        #
        return [htchange,y];        
    else
        #
        # The other case, y is the child and z, the grandchild is the middle one of the three
        #
        z := y[j];
        zflags := z[4];
        
        #
        # z is coming to the top, so we need to rehome both its children
        #
        if  ghi(zflags) then
            y[j] := z[i];
        else
            #
            # link from y continues to point at z but changes meaning
            #
            yflags := shj(yflags,false);
        fi;
        if  ghj(zflags) then
            avl[i] := z[j];            
        else
            #
            # link from avl points back up to z
            #
            avl[i] := z;
            aflags := shi(aflags,false);            
        fi;
        #
        # Now we make z the new top node with y and avl as its children
        #
        z[i] := y;
        z[j] := avl;
        zflags := shi(shj(zflags,true),true);        
        #
        # The new imbalances of y and avl depend on the old imbalance of z
        #
        iz := gim(zflags);
        if iz = dirn then
            yflags := sim(yflags, 1);
            aflags := sim(aflags,2-dirn);
        elif iz = 1 then
            yflags := sim(yflags,1);
            aflags := sim(aflags,1);
        else
            yflags := sim(yflags,dirn);
            aflags := sim(aflags,1);
        fi;
        #
        # which always ends up balanced
        #
        zflags := sim(zflags,1);
        #
        # Finally we need to set all the sizes        
        #
        if ghj(aflags) then
            sa := gs(avl[j][4]);
        else
            sa := 0;
        fi;
        if ghi(aflags) then
            sb := gs(avl[i][4]);
        else
            sb := 0;
        fi;
        if ghj(yflags) then
            sc := gs(y[j][4]);
        else
            sc := 0;
        fi;
        if ghi(yflags) then
            sd := gs(y[i][4]);
        else
            sd := 0;
        fi;
        
        avl[4] := ss(aflags,sa+sb+1);
        y[4] := ss(yflags,sc+sd+1);
        z[4] := ss(zflags, sa+sb+sc+sd+3);
    fi;
    return [-1,z];
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
    gs := AVL2.getSubtreeSize;    
    ss := AVL2.setSubtreeSize;    
    
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
                return trinode(avl)[2];
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
    res := AVL2.AddSetInner(avl!.lists[1],val,avl!.isLess, AVL2.Trinode);
    if res = fail then
        return;
    fi;
    if not IsInt(res) then
        avl!.lists[1] := res;
    fi;
    return;
end);


InstallMethod(DisplayString, [IsAVLTreeRep],
        function(tree)
    local  nodestring, layer, s, newlayer, node;
    if not IsBound(tree!.lists[1]) then
        return "<empty tree>";
    fi;
    nodestring := function(node)
        local  s;
        s := ["<",ViewString(node[2]),": ",String(AVL2.getSubtreeSize(node[4])), " ",
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


InstallMethod(Length, [IsAVLTreeRep and IsOrderedSetDS], Size);
   
InstallMethod(ELM_LIST, [IsAVLTreeRep and IsOrderedSetDS, IsPosInt],
        function(tree,n)
    local  getNth, node;    
    getNth := function(node,n)
        local  sl;
        if not AVL2.hasLeft(node[4]) then
            sl := 0;
        else
            sl := AVL2.getSubtreeSize(node[1][4]);
        fi;
        if sl >= n then
            return getNth(node[1],n);
        elif n = sl+1 then
            return node[2];
        else
            Assert(2, AVL2.hasRight(node[4]));
            return getNth(node[3],n - sl -1);
        fi;
    end;
    
    node := tree!.lists[1];
    if AVL2.getSubtreeSize(node[4]) < n then
        Error("No entry at position ",n);
    fi;
    return getNth(node,n);
end);

#
# This function returns the position of val in tree or the negative of the position
# it would have, were it to be inserted. It is used for methods for Position and
# related operations
#

AVL2.PositionInner :=  function(tree, val)
    local  posInner;
    if IsEmpty(tree) then
        return -1;
    fi;
    posInner := function(node, offset, val)
        local  sl, d;
        if AVL2.hasLeft(node[4]) then
            sl := AVL2.getSubtreeSize(node[1][4]);
        else
            sl := 0;
        fi;
        d := node[2];
        if d = val then
            return offset+sl+1;
        elif LessFunction(tree)(val,d) then
            if sl = 0 then
                return -offset-1;                
            else
                return posInner(node[1],offset,val);
            fi;
        else
            if AVL2.hasRight(node[4]) then
                return posInner(node[3],offset+sl+1,val);
            else
                return -offset-sl-2;
            fi;
        fi;
    end;
    return posInner(tree!.lists[1], 0, val);
end;

                               
            
InstallMethod(Position, [IsAVLTreeRep and IsOrderedSetDS, IsObject, IsInt],
        function( tree, val, start) 
    local  p;
    p := AVL2.PositionInner(tree, val);
    if p < start then
        return fail;
    fi;    
    return p;
end);

InstallMethod(PositionSortedOp, [IsAVLTreeRep and IsStandardOrderedSetDS, IsObject],
        function( tree, val) 
    return AbsInt(AVL2.PositionInner(tree, val));
end);

InstallMethod(PositionSortedOp, [IsAVLTreeRep and IsOrderedSetDS, IsObject, IsFunction],
        function( tree, val, comp) 
    if comp <> LessFunction(tree) then
        TryNextMethod();
    fi;
    return AbsInt(AVL2.PositionInner(tree, val));
end);


# This routine handles removal of the predecessor or successor of the data item at node l
# This is needed, just as for BSTs when l is to be deleted but has two children
# It's more complicated than for BSTs because we need to rebalance and do bookkeeping as we come up
#
AVL2.Remove_Extremal := function(l, dirn)   
    local  i, j, hi, hj, flags, res, im, res2;
    #
    # This removes the dirn-most node of the tree rooted at l. 
    # it returns a triple [<change in height>, <node removed>, <new root node>]
    # if in fact it deletes the only node in the subtree below l, it returns fail 
    # in the third component
    #
    if dirn = 0 then
        i := 1;
        j := 3;
        hi := AVL2.hasLeft;
        hj := AVL2.hasRight;
    else       
        i := 3;
        j := 1;
        hj := AVL2.hasLeft;
        hi := AVL2.hasRight;
    fi;
    flags := l[4];    
    if not hi(flags) then
        #
        # Found it
        #
        if hj(flags) then
            return [-1,l,l[j]];
        else
            return [-1,l,fail];
        fi;
    fi;
    
    #
    # recurse
    #
    res := AVL2.Remove_Extremal(l[i],dirn);
    
    if res[3] <> fail then
        l[i] := res[3];
    else
        #
        # Thread pointer
        #
        l[i] := res[2][i];           
        if dirn = 0 then
            flags := AVL2.setHasLeft(flags, false);
        else
            flags := AVL2.setHasRight(flags, false);
        fi;
    fi;
    
    
    #
    # Adjust size
    #
    flags := AVL2.setSubtreeSize(flags, AVL2.getSubtreeSize(flags)-1);            
    
    
    #
    # if the subtree got shorter then adjust balance
    #
    
    if res[1] = -1 then
        im := AVL2.getImbalance(flags);
        if im = dirn then
            l[4] := AVL2.setImbalance(flags,1);
            return [-1, res[2], l];
        elif im = 1 then
            l[4] := AVL2.setImbalance(flags,2-dirn);
            return [0, res[2], l];
        else
            l[4] := flags;    
            res2 := AVL2.Trinode(l);            
            return [res2[1],res[2],res2[2]];
        fi;
    else
        l[4] := flags;    
        return [0, res[2],l];                
    fi;   
end;

#
# This function captures the work that must be done when we have found the node we want to delete
#

AVL2.RemoveThisNode := function(node, remove_extremal, trinode)
    local  flags, im, res;
    #
    # Very similar to the BST case. By careful choices we avoid the need to 
    # restructure at this point, but we do need to do book-keeping
    # 
    # returns change in height and new node
    #
    flags := node[4];    
    if AVL2.hasLeft(flags) then
        if AVL2.hasRight(flags) then  
            #
            # Both -- hard case
            #
            # We "steal" a neighbouring value from a subtree
            # if they are of unequal height, choose the higher
            # If equal go left. We don't need to alternate as we do
            # for BSTs because these trees cannot become unbalanced
            #
            im := AVL2.getImbalance(flags);            
            if  im = 2 then
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
                    #
                    # Child was a singleton node, which we have deleted, need 
                    # to link up thread pointer
                    #
                    node[1] := res[2][1];
                    flags := AVL2.setHasLeft(flags, false);                    
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
                if im <> 0 then
                    #
                    # Not balanced before, so now we are
                    #
                    node[4] := AVL2.setSubtreeSize(AVL2.setImbalance(flags,1),AVL2.getSubtreeSize(flags)-1);                    
                    return [-1,node];                            
                else
                    #
                    # If we were balanced before, we went left
                    # 
                    node[4] := AVL2.setSubtreeSize(AVL2.setImbalance(flags,2),AVL2.getSubtreeSize(flags)-1);                    ;
                    return [0,node];
                fi;
            else
                node[4] := AVL2.setSubtreeSize(flags,AVL2.getSubtreeSize(flags)-1);                    ;
                return [0, node];
            fi;                    
        else
            #
            # left only
            #
            return [-1,node[1]];
        fi;
    else                
        if AVL2.hasRight(flags) then
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


AVL2.RemoveSetInnerGAP  := function(node,val, less, remove_extremal, trinode, remove_this)
    local  d, i, hi, shi, ret, flags, im;
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
        hi := AVL2.hasLeft;        
        shi := AVL2.setHasLeft;        
    else
        i := 3;
        hi := AVL2.hasRight;        
        shi := AVL2.setHasRight;        
    fi;
    flags := node[4];
    
    
    if hi(flags) then
        ret := AVL2.RemoveSetInner(node[i],val, less, remove_extremal, trinode, remove_this);            
        if ret = fail then
            return fail;
        fi;                                
        if ret[2] <> fail then
            node[i] := ret[2];
        else
            flags := shi(flags, false);
            if IsBound(node[i][i]) then
                node[i] := node[i][i];            
            else
                Unbind(node[i]);
            fi;
            
        fi;
    else
        return fail;                
    fi;
    #
    # So if we get here we have deleted val somewhere below here, and replaced the subtree that might have been changed
    # by rotations, and ret[1] tells us if that subtree got shorter. If it did, we may have more work to do
    #
    flags := AVL2.setSubtreeSize(flags, AVL2.getSubtreeSize(flags)-1);    
    #
    # We reuse ret for the return from this function to avoid garbage
    #
    if ret[1] = 0 then
        #
        # No more to do
        #
        node[4] := flags;        
        ret[2] := node;        
        return ret;
    fi;
    #
    # or maybe all we need to do is adjust the imbalance at this node
    #
    im := AVL2.getImbalance(flags);    
    if im = i-1 then
        node[4] := AVL2.setImbalance(flags, 1);        
        ret[2] := node;        
        return ret;
    elif im  = 1 then
        node[4] := AVL2.setImbalance(flags, 3-i);
        ret[1] := 0;
        ret[2] := node;        
        return ret; 
    fi;                  
    #
    # Nope. Need to rebalance
    #
    node[4] := flags;    
    return trinode(node);
end;

if IsBound(DS_AVL2_REMSET_INNER) then
    AVL2.RemoveSetInner := DS_AVL2_REMSET_INNER;
else
    AVL2.RemoveSetInner := AVL2.RemoveSetInnerGAP;
fi;

    
#
# This is now just a wrapper around the "Inner" function
#

InstallMethod(RemoveSet, [IsAVLTreeRep and IsOrderedSetDS and IsMutable, IsObject],
        function(avl, val)
    local   ret;
    if not IsBound(avl!.lists[1]) then
        return 0;        
    fi;
    ret := AVL2.RemoveSetInner(avl!.lists[1], val, avl!.isLess, AVL2.Remove_Extremal, AVL2.Trinode, AVL2.RemoveThisNode);
    if ret = fail then
        return 0;
    fi;    
    if ret[2] <> fail then
        avl!.lists[1] := ret[2];
    else
        Unbind(avl!.lists[1]);
    fi;
    return 1;    
end);
            
if false then

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







fi;

