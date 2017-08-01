#############################################################################
##
##                             orb package
##  avltree.gi
##                                                          Juergen Mueller
##                                                          Max Neunhoeffer
##                                                             Felix Noeske
##
##  Copyright 2009-2009 by the authors.
##  This file is free software, see license information at the end.
##
##  Implementation stuff for AVL trees in GAP.
##
##  adding, removing and finding in O(log n), n is number of nodes
##
##  see Knuth: "The Art of Computer Programming" for algorithms
##
#############################################################################


#
# Conventions:
#
# A balanced binary tree (DS_AVLTree) is a positional object having the
# following entries:
#   ![1]     len: last used entry (never shrinks), always = 3 mod 4
#   ![2]     free: index of first freed entry, if 0, none free
#   ![3]     nodes: number of nodes currently in the tree
#   ![4]     alloc: highest allocated index, always = 3 mod 4
#   ![5]     three-way comparison function
#   ![6]     top: reference to top node
#   ![7]     value: plain list holding the values stored under the keys
#            can be fail, in which case all stored values are "true"
#            will be bound when first value other than true is set
#
# From index 8 on for every position = 0 mod 4:
#   ![4n]    obj: an object
#   ![4n+1]  left: left reference or < 8 (elements there are smaller)
#   ![4n+2]  right: right reference or < 8 (elements there are bigger)
#   ![4n+3]  rank: number of nodes in left subtree plus one
# For freed nodes position ![4n] holds the link to the next one
# For used nodes references are divisible by four, therefore
# the mod 4 value can be used for other information.
# We use left mod 4: 0 - balanced
#                    1 - balance factor +1
#                    2 - balance factor -1
#

DS_AVLCmp_GAP := function(a,b)
  if a = b then
    return 0;
  elif a < b then
    return -1;
  else
    return 1;
  fi;
end;
if IsBound(DS_AVLCmp_C) then
    InstallGlobalFunction(DS_AVLCmp, DS_AVLCmp_C);
else
    InstallGlobalFunction(DS_AVLCmp, DS_AVLCmp_GAP);
fi;

DS_AVLTree_GAP := function(arg)
  # Parameters: options record (optional)
  # Initializes balanced binary tree object, optionally with comparison
  # function. Returns empty tree object.
  # A comparison function takes 2 arguments and returns respectively -1, 0
  # or 1 if the first argument is smaller than, equal to, or bigger than the
  # second argument.
  # A comparison function is NOT necessary for trees where the ordering is
  # only defined by the tree and not by an ordering of the elements. Such
  # trees are managed by the special functions below. Specify nothing
  # for the cmpfunc (or leave the default one).
  local t,cmpfunc,alloc,opt;
  # defaults:
  cmpfunc := DS_AVLCmp;
  alloc := 11;
  if Length(arg) = 1 then
      opt := arg[1];
      if not(IsRecord(opt)) then
          Error("Argument must be an options record!");
          return fail;
      fi;
      if IsBound(opt.cmpfunc) then
          cmpfunc := opt.cmpfunc;
          if not(IsFunction(cmpfunc)) then
              Error("cmdfunc must be a three-way comparison function");
              return fail;
          fi;
      fi;
      if IsBound(opt.allocsize) then
          alloc := opt.allocsize;
          if not(IsInt(alloc)) then
              Error("allocsize must be a positive integer");
          fi;
          alloc := alloc*4+3;
      fi;
  elif Length(arg) <> 0 then
      Error("Usage: DS_AVLTree( [options-record] )");
      return fail;
  fi;
  t := [11,8,0,alloc,cmpfunc,0,fail,0,0,0,0];
  if alloc > 11 then t[alloc] := fail; fi;    # expand object
  Objectify(DS_AVLTreeTypeMutable,t);
  return t;
end;
if IsBound(DS_AVLTree_C) then
    InstallGlobalFunction(DS_AVLTree, DS_AVLTree_C);
else
    InstallGlobalFunction(DS_AVLTree, DS_AVLTree_GAP);
fi;

InstallMethod( ViewObj, "for an avltree object",
  [IsDS_AVLTree and IsDS_AVLTreeFlatRep],
  function( t )
    Print("<avltree nodes=",t![3]," alloc=",t![4],">");
  end );

DS_AVLNewNode_GAP := function(t)
  local n;
  if t![2] > 0 then
      n := t![2];
      t![2] := t![n];
  elif t![1] < t![4] then
      n := t![1]+1;
      t![1] := t![1]+4;
  else
      n := t![4]+1;
      t![4] := t![4] * 2 + 1;    # retain congruent 3 mod 4
      t![1] := n+3;
      t![t![4]] := fail;    # expand allocation
  fi;
  t![n] := 0;
  t![n+1] := 0;
  t![n+2] := 0;
  t![n+3] := 0;
  return n;
end;
if IsBound(DS_AVLNewNode_C) then
    InstallGlobalFunction(DS_AVLNewNode, DS_AVLNewNode_C);
else
    InstallGlobalFunction(DS_AVLNewNode, DS_AVLNewNode_GAP);
fi;


DS_AVLFreeNode_GAP := function(t,n)
  local o;
  t![n] := t![2];
  t![2] := n;
  n := n/4;
  if t![7] <> fail and IsBound(t![7][n]) then
      o := t![7][n];
      Unbind(t![7][n]);
      return o;
  fi;
  return true;
end;
if IsBound(DS_AVLFreeNode_C) then
    InstallGlobalFunction(DS_AVLFreeNode, DS_AVLFreeNode_C);
else
    InstallGlobalFunction(DS_AVLFreeNode, DS_AVLFreeNode_GAP);
fi;


DS_AVLData_GAP := function(t,n)
  return t![n];
end;
if IsBound(DS_AVLData_C) then
    InstallGlobalFunction(DS_AVLData, DS_AVLData_C);
else
    InstallGlobalFunction(DS_AVLData, DS_AVLData_GAP);
fi;


DS_AVLSetData_GAP := function(t,n,d)
  t![n] := d;
end;
if IsBound(DS_AVLSetData_C) then
    InstallGlobalFunction(DS_AVLSetData, DS_AVLSetData_C);
else
    InstallGlobalFunction(DS_AVLSetData, DS_AVLSetData_GAP);
fi;


DS_AVLLeft_GAP := function(t,n)
  return QuoInt(t![n+1],4)*4;
end;
if IsBound(DS_AVLLeft_C) then
    InstallGlobalFunction(DS_AVLLeft, DS_AVLLeft_C);
else
    InstallGlobalFunction(DS_AVLLeft, DS_AVLLeft_GAP);
fi;


DS_AVLSetLeft_GAP := function(t,n,m)
  t![n+1] := m + t![n+1] mod 4;
end;
if IsBound(DS_AVLSetLeft_C) then
    InstallGlobalFunction(DS_AVLSetLeft, DS_AVLSetLeft_C);
else
    InstallGlobalFunction(DS_AVLSetLeft, DS_AVLSetLeft_GAP);
fi;


DS_AVLRight_GAP := function(t,n)
  return QuoInt(t![n+2],4)*4;
end;
if IsBound(DS_AVLRight_C) then
    InstallGlobalFunction(DS_AVLRight, DS_AVLRight_C);
else
    InstallGlobalFunction(DS_AVLRight, DS_AVLRight_GAP);
fi;


DS_AVLSetRight_GAP := function(t,n,m)
  t![n+2] := m;
end;
if IsBound(DS_AVLSetRight_C) then
    InstallGlobalFunction(DS_AVLSetRight, DS_AVLSetRight_C);
else
    InstallGlobalFunction(DS_AVLSetRight, DS_AVLSetRight_GAP);
fi;


DS_AVLRank_GAP := function(t,n)
  return t![n+3];
end;
if IsBound(DS_AVLRank_C) then
    InstallGlobalFunction(DS_AVLRank, DS_AVLRank_C);
else
    InstallGlobalFunction(DS_AVLRank, DS_AVLRank_GAP);
fi;


DS_AVLSetRank_GAP := function(t,n,r)
  t![n+3] := r;
end;
if IsBound(DS_AVLSetRank_C) then
    InstallGlobalFunction(DS_AVLSetRank, DS_AVLSetRank_C);
else
    InstallGlobalFunction(DS_AVLSetRank, DS_AVLSetRank_GAP);
fi;


DS_AVLBalFactor_GAP := function(t,n)
  local bf;
  bf := t![n+1] mod 4;    # 0, 1 or 2
  if bf = 2 then
    return -1;
  else
    return bf;
  fi;
end;
if IsBound(DS_AVLBalFactor_C) then
    InstallGlobalFunction(DS_AVLBalFactor, DS_AVLBalFactor_C);
else
    InstallGlobalFunction(DS_AVLBalFactor, DS_AVLBalFactor_GAP);
fi;


DS_AVLSetBalFactor_GAP := function(t,n,bf)
  if bf = -1 then
    t![n+1] := QuoInt(t![n+1],4)*4 + 2;
  else
    t![n+1] := QuoInt(t![n+1],4)*4 + bf;
  fi;
end;
if IsBound(DS_AVLSetBalFactor_C) then
    InstallGlobalFunction(DS_AVLSetBalFactor, DS_AVLSetBalFactor_C);
else
    InstallGlobalFunction(DS_AVLSetBalFactor, DS_AVLSetBalFactor_GAP);
fi;

DS_AVLValue_GAP := function(t,n)
  if t![7] = fail then
      return true;
  elif not(IsBound(t![7][n/4])) then
      return true;
  else
      return t![7][n/4];
  fi;
end;
if IsBound(DS_AVLValue_C) then
    InstallGlobalFunction(DS_AVLValue, DS_AVLValue_C);
else
    InstallGlobalFunction(DS_AVLValue, DS_AVLValue_GAP);
fi;

DS_AVLSetValue_GAP := function(t,n,v)
  n := n/4;
  if t![7] = fail then
      t![7] := EmptyPlist(n);
  fi;
  t![7][n] := v;
end;
if IsBound(DS_AVLSetValue_C) then
    InstallGlobalFunction(DS_AVLSetValue, DS_AVLSetValue_C);
else
    InstallGlobalFunction(DS_AVLSetValue, DS_AVLSetValue_GAP);
fi;

InstallMethod( Display, "for an avltree object",
  [IsDS_AVLTree and IsDS_AVLTreeFlatRep],
  function( t )
    local DoRecursion;
    DoRecursion := function(p,depth,P)
      local i;
      if p = 0 then return; fi;
      for i in [1..depth] do Print(" "); od;
      Print(P,"data=",DS_AVLData(t,p)," rank=",DS_AVLRank(t,p)," pos=",p,
            " bf=",DS_AVLBalFactor(t,p),"\n");
      DoRecursion(DS_AVLLeft(t,p),depth+1,"L:");
      DoRecursion(DS_AVLRight(t,p),depth+1,"R:");
    end;

    Print("<avltree nodes=",t![3]," alloc=",t![4],"\n");
    DoRecursion(t![6],1,"");
    Print(">\n");
  end );

DS_AVLFind_GAP := function(tree,data)
  # Parameters: tree, data
  #  t is a AVL
  #  data is a data structure defined by the user
  # Searches in tree for a node equal to data, returns this node or fail
  # if not found.
  local compare, p, c;
  compare := tree![5];
  p := tree![6];
  while p >= 8 do
    c := compare(data,DS_AVLData(tree,p));
    if c = 0 then
      return p;
    elif c < 0 then    # data < DS_AVLData(tree,p)
      p := DS_AVLLeft(tree,p);
    else               # data > DS_AVLData(tree,p)
      p := DS_AVLRight(tree,p);
    fi;
  od;

  return fail;
end;
if IsBound(DS_AVLFind_C) then
    InstallGlobalFunction(DS_AVLFind, DS_AVLFind_C);
else
    InstallGlobalFunction(DS_AVLFind, DS_AVLFind_GAP);
fi;

DS_AVLLookup_GAP := function(t,d)
  local p;
  p := DS_AVLFind(t,d);
  if p = fail then
      return fail;
  else
      return DS_AVLValue(t,p);
  fi;
end;
if IsBound(DS_AVLLookup_C) then
    InstallGlobalFunction(DS_AVLLookup, DS_AVLLookup_C);
else
    InstallGlobalFunction(DS_AVLLookup, DS_AVLLookup_GAP);
fi;

DS_AVLIndex_GAP := function(tree,index)
  # Parameters: tree, index
  #  tree is a AVL
  #  index is an index in the tree
  # Searches in tree for the node with index index, returns the data of
  # this node or fail if not found. Works without comparison function,
  # just by index.
  local p, offset, r;

  if index < 1 or index > tree![3] then
    return fail;
  fi;

  p := tree![6];
  offset := 0;         # Offset of subtree p in tree

  while true do   # will terminate!
    r := offset + DS_AVLRank(tree,p);
    if index < r then
      # go left
      p := DS_AVLLeft(tree,p);
    elif index = r then
      # found!
      return DS_AVLData(tree,p);
    else
      # go right!
      offset := r;
      p := DS_AVLRight(tree,p);
    fi;
  od;
end;
if IsBound(DS_AVLIndex_C) then
    InstallGlobalFunction(DS_AVLIndex, DS_AVLIndex_C);
else
    InstallGlobalFunction(DS_AVLIndex, DS_AVLIndex_GAP);
fi;

DS_AVLIndexFind_GAP := function(tree,index)
  # Parameters: tree, index
  #  tree is a AVL
  #  index is an index in the tree
  # Searches in tree for the node with index index, returns the position of
  # this node or fail if not found. Works without comparison function,
  # just by index.
  local p, offset, r;

  if index < 1 or index > tree![3] then
    return fail;
  fi;

  p := tree![6];
  offset := 0;         # Offset of subtree p in tree

  while true do   # will terminate!
    r := offset + DS_AVLRank(tree,p);
    if index < r then
      # go left
      p := DS_AVLLeft(tree,p);
    elif index = r then
      # found!
      return p;
    else
      # go right!
      offset := r;
      p := DS_AVLRight(tree,p);
    fi;
  od;
end;
if IsBound(DS_AVLIndexFind_C) then
    InstallGlobalFunction(DS_AVLIndexFind, DS_AVLIndexFind_C);
else
    InstallGlobalFunction(DS_AVLIndexFind, DS_AVLIndexFind_GAP);
fi;

DS_AVLIndexLookup_GAP := function(tree,i)
  local p;
  p := DS_AVLIndexFind(tree,i);
  if p = fail then
      return fail;
  else
      return DS_AVLValue(tree,p);
  fi;
end;
if IsBound(DS_AVLIndexLookup_C) then
    InstallGlobalFunction(DS_AVLIndexLookup, DS_AVLIndexLookup_C);
else
    InstallGlobalFunction(DS_AVLIndexLookup, DS_AVLIndexLookup_GAP);
fi;

DS_AVLRebalance_GAP := function(tree,q)
  # the tree starting at q has balanced subtrees but is out of balance:
  # the depth of the deeper subtree is 2 bigger than the depth of the other
  # tree. This function changes this situation following the procedure
  # described in Knuth: "The Art of Computer Programming".
  # It returns a record with the new start node of the subtree as entry
  # "newroot" and in "shorter" a boolean value which indicates, if the
  # depth of the tree was decreased by 1 by this operation.
  local shrink, p, l;

  shrink := true;   # in nearly all cases this happens
  if DS_AVLBalFactor(tree,q) < 0 then
    p := DS_AVLLeft(tree,q);
  else
    p := DS_AVLRight(tree,q);
  fi;
  if DS_AVLBalFactor(tree,p) = DS_AVLBalFactor(tree,q) then
    # we need a single rotation:
    #       q++             p=           q--          p=
    #      / \             / \          / \          / \
    #     a   p+    ==>   q=  c    OR  p-  c   ==>  a   q=
    #        / \         / \          / \              / \
    #       b   c       a   b        a   b            b   c
    if DS_AVLBalFactor(tree,q) > 0 then
      DS_AVLSetRight(tree,q,DS_AVLLeft(tree,p));
      DS_AVLSetLeft(tree,p,q);
      DS_AVLSetBalFactor(tree,q,0);
      DS_AVLSetBalFactor(tree,p,0);
      DS_AVLSetRank(tree,p,DS_AVLRank(tree,p) + DS_AVLRank(tree,q));
    else
      DS_AVLSetLeft(tree,q,DS_AVLRight(tree,p));
      DS_AVLSetRight(tree,p,q);
      DS_AVLSetBalFactor(tree,q,0);
      DS_AVLSetBalFactor(tree,p,0);
      DS_AVLSetRank(tree,q,DS_AVLRank(tree,q) - DS_AVLRank(tree,p));
    fi;
  elif DS_AVLBalFactor(tree,p) = - DS_AVLBalFactor(tree,q) then
    # we need a double rotation:
    #       q++                             q--
    #      / \             c=              / \            c=
    #     a   p-         /   \            p+  e         /   \
    #        / \   ==>  q     p    OR    / \      ==>  p     q
    #       c   e      / \   / \        a   c         / \   / \
    #      / \        a   b d   e          / \       a   b d   e
    #     b   d                           b   d
    if DS_AVLBalFactor(tree,q) > 0 then
      l := DS_AVLLeft(tree,p);
      DS_AVLSetRight(tree,q,DS_AVLLeft(tree,l));
      DS_AVLSetLeft(tree,p,DS_AVLRight(tree,l));
      DS_AVLSetLeft(tree,l,q);
      DS_AVLSetRight(tree,l,p);
      if DS_AVLBalFactor(tree,l) > 0 then
        DS_AVLSetBalFactor(tree,p,0);
        DS_AVLSetBalFactor(tree,q,-1);
      elif DS_AVLBalFactor(tree,l) = 0 then
        DS_AVLSetBalFactor(tree,p,0);
        DS_AVLSetBalFactor(tree,q,0);
      else    # DS_AVLBalFactor(tree,l) < 0
        DS_AVLSetBalFactor(tree,p,1);
        DS_AVLSetBalFactor(tree,q,0);
      fi;
      DS_AVLSetBalFactor(tree,l,0);
      DS_AVLSetRank(tree,p,DS_AVLRank(tree,p) - DS_AVLRank(tree,l));
      DS_AVLSetRank(tree,l,DS_AVLRank(tree,l) + DS_AVLRank(tree,q));
      p := l;
    else
      l := DS_AVLRight(tree,p);
      DS_AVLSetLeft(tree,q,DS_AVLRight(tree,l));
      DS_AVLSetRight(tree,p,DS_AVLLeft(tree,l));
      DS_AVLSetLeft(tree,l,p);
      DS_AVLSetRight(tree,l,q);
      if DS_AVLBalFactor(tree,l) < 0 then
        DS_AVLSetBalFactor(tree,p,0);
        DS_AVLSetBalFactor(tree,q,1);
      elif DS_AVLBalFactor(tree,l) = 0 then
        DS_AVLSetBalFactor(tree,p,0);
        DS_AVLSetBalFactor(tree,q,0);
      else    # DS_AVLBalFactor(tree,l) > 0
        DS_AVLSetBalFactor(tree,p,-1);
        DS_AVLSetBalFactor(tree,q,0);
      fi;
      DS_AVLSetBalFactor(tree,l,0);
      DS_AVLSetRank(tree,l,DS_AVLRank(tree,l) + DS_AVLRank(tree,p));
      DS_AVLSetRank(tree,q,DS_AVLRank(tree,q) - DS_AVLRank(tree,l));
                           # new value of DS_AVLRank(tree,l)!
      p := l;
    fi;
  else   # DS_AVLBalFactor(tree,p) = 0 then
    # we need a single rotation:
    #       q++             p-           q--          p+
    #      / \             / \          / \          / \
    #     a   p=    ==>   q+  c    OR  p=  c   ==>  a   q-
    #        / \         / \          / \              / \
    #       b   c       a   b        a   b            b   c
    if DS_AVLBalFactor(tree,q) > 0 then
      DS_AVLSetRight(tree,q,DS_AVLLeft(tree,p));
      DS_AVLSetLeft(tree,p,q);
      DS_AVLSetBalFactor(tree,q,1);
      DS_AVLSetBalFactor(tree,p,-1);
      DS_AVLSetRank(tree,p,DS_AVLRank(tree,p) + DS_AVLRank(tree,q));
    else
      DS_AVLSetLeft(tree,q,DS_AVLRight(tree,p));
      DS_AVLSetRight(tree,p,q);
      DS_AVLSetBalFactor(tree,q,-1);
      DS_AVLSetBalFactor(tree,p,1);
      DS_AVLSetRank(tree,q,DS_AVLRank(tree,q) - DS_AVLRank(tree,p));
    fi;
    shrink := false;
  fi;
  return rec(newroot := p, shorter := shrink);
end;
if IsBound(DS_AVLRebalance_C) then
    InstallGlobalFunction(DS_AVLRebalance, DS_AVLRebalance_C);
else
    InstallGlobalFunction(DS_AVLRebalance, DS_AVLRebalance_GAP);
fi;


DS_AVLAdd_GAP := function(tree,data,value)
  # Parameters: tree, data, value
  #  tree is a AVL
  #  data is a data structure defined by the user
  #  value is the value stored under the key data, if true, nothing is stored
  # Tries to add the data as a node in tree. It is an error, if there is
  # already a node which is "equal" to data with respect to the comparison
  # function. Returns true if everything went well or fail, if an equal
  # object is already present.

  local compare, p, new, path, nodes, n, q, rankadds, c, l, i;

  compare := tree![5];

  p := tree![6];
  if p = 0 then   # A new, single node in the tree
    new := DS_AVLNewNode(tree);
    DS_AVLSetLeft(tree,new,0);
    DS_AVLSetRight(tree,new,0);
    DS_AVLSetBalFactor(tree,new,0);
    DS_AVLSetRank(tree,new,1);
    DS_AVLSetData(tree,new,data);
    if value <> true then
        DS_AVLSetValue(tree,new,value);
    fi;
    tree![3] := 1;
    tree![6] := new;
    return true;
  fi;

  # let's first find the right position in the tree:
  # but: remember the last node on the way with bal. factor <> 0 and the path
  #      after this node
  # and: remember the nodes where the Rank entry is incremented in case we
  #      find an "equal" element
  path := EmptyPlist(10);   # here all steps are recorded: -1:left, +1:right
  nodes := EmptyPlist(10);
  nodes[1] := p;   # here we store all nodes on our way, nodes[i+1] is reached
                   # from nodes[i] by walking one step path[i]
  n := 1;          # this is the length of "nodes"
  q := 0;          # this is the last node with bal. factor <> 0
                   # index in "nodes" or 0 for no such node
  rankadds := EmptyPlist(10);# nothing done so far, list of Rank-modified nodes
  repeat

    # do we have to remember this position?
    if DS_AVLBalFactor(tree,p) <> 0 then
      q := n;       # forget old last node with balance factor <> 0
    fi;

    # now one step:
    c := compare(data,DS_AVLData(tree,p));
    if c = 0 then   # we did not want this!
      for p in rankadds do
        DS_AVLSetRank(tree,p,DS_AVLRank(tree,p) - 1);
      od;
      return fail; # tree is unchanged
    fi;

    l := p;     # remember last position
    if c < 0 then   # data < DS_AVLData(tree,p)
      DS_AVLSetRank(tree,p,DS_AVLRank(tree,p) + 1);
      Add(rankadds,p);
      p := DS_AVLLeft(tree,p);
    else            # data > DS_AVLData(tree,p)
      p := DS_AVLRight(tree,p);
    fi;
    Add(nodes,p);
    n := n + 1;
    Add(path,c);

  until p = 0;
  # now p is 0 and nodes[n-1] is the node where data must be attached
  # the tree must be modified between nodes[q] and nodes[n-1] along path
  # Ranks are already done
  l := nodes[n-1];   # for easier reference

  # a new node:
  p := DS_AVLNewNode(tree);
  DS_AVLSetLeft(tree,p,0);
  DS_AVLSetRight(tree,p,0);
  DS_AVLSetBalFactor(tree,p,0);
  DS_AVLSetRank(tree,p,1);
  DS_AVLSetData(tree,p,data);
  if value <> true then
      DS_AVLSetValue(tree,p,value);
  fi;
  # insert into tree:
  if c < 0 then    # left
    DS_AVLSetLeft(tree,l,p);
  else
    DS_AVLSetRight(tree,l,p);
  fi;
  tree![3] := tree![3] + 1;

  # modify balance factors between q and l:
  for i in [q+1..n-1] do
    DS_AVLSetBalFactor(tree,nodes[i],path[i]);
  od;

  # is rebalancing at q necessary?
  if q = 0 then    # whole tree has grown one step
    return true;   # Success!
  fi;
  if DS_AVLBalFactor(tree,nodes[q]) = -path[q] then
    # the subtree at q has gotten more balanced
    DS_AVLSetBalFactor(tree,nodes[q],0);
    return true;   # Success!
  fi;

  # now at last we do have to rebalance at nodes[q] because the tree has
  # gotten out of balance:
  p := DS_AVLRebalance(tree,nodes[q]);
  p := p.newroot;

  # finishing touch: link new root of subtree (p) to t:
  if q = 1 then  # q resp. r was First node
    tree![6] := p;
  elif path[q-1] = -1 then
    DS_AVLSetLeft(tree,nodes[q-1],p);
  else
    DS_AVLSetRight(tree,nodes[q-1],p);
  fi;

  return true;
end;
if IsBound(DS_AVLAdd_C) then
    InstallGlobalFunction(DS_AVLAdd, DS_AVLAdd_C);
else
    InstallGlobalFunction(DS_AVLAdd, DS_AVLAdd_GAP);
fi;


DS_AVLIndexAdd_GAP := function(tree,data,value,index)
  # Parameters: index, data, value, tree
  #  tree is a AVL
  #  data is a data structure defined by the user
  #  value is the value to be stored under key data, nothing is stored if true
  #  index is the index, where data should be inserted in tree 1 ist at
  #          first position, NumberOfNodes+1 after the last.
  # Tries to add the data as a node in tree. Returns true if everything
  # went well or fail, if something went wrong,

  local p, path, nodes, n, q, offset, c, l, i;

  if index < 1 or index > tree![3]+1 then
    return fail;
  fi;

  p := tree![6];
  if p = 0 then   # A new, single node in the tree
    # index must be equal to 1
    tree![6] := DS_AVLNewNode(tree);
    DS_AVLSetLeft(tree,tree![6],0);
    DS_AVLSetRight(tree,tree![6],0);
    DS_AVLSetBalFactor(tree,tree![6],0);
    DS_AVLSetRank(tree,tree![6],1);
    DS_AVLSetData(tree,tree![6],data);
    if value <> true then
        DS_AVLSetValue(tree,tree![6],value);
    fi;
    tree![3] := 1;
    return true;
  fi;

  # let's first find the right position in the tree:
  # but: remember the last node on the way with bal. factor <> 0 and the path
  #      after this node
  # and: remember the nodes where the Rank entry is incremented in case we
  #      find an "equal" element
  path := EmptyPlist(10);     # here all steps are recorded: -1:left, +1:right
  nodes := EmptyPlist(10);
  nodes[1] := p;   # here we store all nodes on our way, nodes[i+1] is reached
                   # from nodes[i] by walking one step path[i]
  n := 1;          # this is the length of "nodes"
  q := 0;          # this is the last node with bal. factor <> 0
                   # index in "nodes" or 0 for no such node
  offset := 0;     # number of nodes with smaller index than those in subtree
  repeat

    # do we have to remember this position?
    if DS_AVLBalFactor(tree,p) <> 0 then
      q := n;       # forget old last node with balance factor <> 0
    fi;

    # now one step:
    if index <= offset+DS_AVLRank(tree,p) then
      c := -1;    # we have to descend to left subtree
    else
      c := +1;    # we have to descend to right subtree
    fi;

    l := p;     # remember last position
    if c < 0 then   # data < DS_AVLData(tree,p)
      DS_AVLSetRank(tree,p,DS_AVLRank(tree,p) + 1);
      p := DS_AVLLeft(tree,p);
    else            # data > DS_AVLData(tree,p)
      offset := offset + DS_AVLRank(tree,p);
      p := DS_AVLRight(tree,p);
    fi;
    Add(nodes,p);
    n := n + 1;
    Add(path,c);

  until p = 0;
  # now p is 0 and nodes[n-1] is the node where data must be attached
  # the tree must be modified between nodes[q] and nodes[n-1] along path
  # Ranks are already done
  l := nodes[n-1];   # for easier reference

  # a new node:
  p := DS_AVLNewNode(tree);
  DS_AVLSetLeft(tree,p,0);
  DS_AVLSetRight(tree,p,0);
  DS_AVLSetBalFactor(tree,p,0);
  DS_AVLSetRank(tree,p,1);
  DS_AVLSetData(tree,p,data);
  if value <> true then
      DS_AVLSetValue(tree,p,value);
  fi;
  # insert into tree:
  if c < 0 then    # left
    DS_AVLSetLeft(tree,l,p);
  else
    DS_AVLSetRight(tree,l,p);
  fi;
  tree![3] := tree![3] + 1;

  # modify balance factors between q and l:
  for i in [q+1..n-1] do
    DS_AVLSetBalFactor(tree,nodes[i],path[i]);
  od;

  # is rebalancing at q necessary?
  if q = 0 then    # whole tree has grown one step
    return true;   # Success!
  fi;
  if DS_AVLBalFactor(tree,nodes[q]) = -path[q] then
    # the subtree at q has gotten more balanced
    DS_AVLSetBalFactor(tree,nodes[q],0);
    return true;   # Success!
  fi;

  # now at last we do have to rebalance at nodes[q] because the tree has
  # gotten out of balance:
  p := DS_AVLRebalance(tree,nodes[q]);
  p := p.newroot;

  # finishing touch: link new root of subtree (p) to t:
  if q = 1 then  # q resp. r was First node
    tree![6] := p;
  elif path[q-1] = -1 then
    DS_AVLSetLeft(tree,nodes[q-1],p);
  else
    DS_AVLSetRight(tree,nodes[q-1],p);
  fi;

  return true;
end;
if IsBound(DS_AVLIndexAdd_C) then
    InstallGlobalFunction(DS_AVLIndexAdd, DS_AVLIndexAdd_C);
else
    InstallGlobalFunction(DS_AVLIndexAdd, DS_AVLIndexAdd_GAP);
fi;

DS_AVLDelete_GAP := function(tree,data)
  # Parameters: tree, data
  #  tree is a AVL
  #  data is a data structure defined by the user
  # Tries to find data as a node in the tree. If found, this node is deleted
  # and the tree rebalanced. It is an error, if the node is not found.
  # Returns fail in this case, and the stored value normally.
  local compare, p, path, nodes, n, ranksubs, c, m, l, r, i, old;

  compare := tree![5];

  p := tree![6];
  if p = 0 then   # Nothing to delete or find
    return fail;
  fi;
  if tree![3] = 1 then
    if compare(data,DS_AVLData(tree,p)) = 0 then
      tree![3] := 0;
      tree![6] := 0;
      return DS_AVLFreeNode(tree,p);
    else
      return fail;
    fi;
  fi;

  # let's first find the right position in the tree:
  # and: remember the nodes where the Rank entry is decremented in case we
  #      find an "equal" element
  path := EmptyPlist(10);    # here all steps are recorded: -1:left, +1:right
  nodes := EmptyPlist(10);
  nodes[1] := p;   # here we store all nodes on our way, nodes[i+1] is reached
                   # from nodes[i] by walking one step path[i]
  n := 1;          # this is the length of "nodes"
  ranksubs := EmptyPlist(10);# nothing done so far, list of Rank-modified nodes

  repeat

    # what is the next step?
    c := compare(data,DS_AVLData(tree,p));

    if c <> 0 then  # only if data not found!
      if c < 0 then       # data < DS_AVLData(tree,p)
        DS_AVLSetRank(tree,p,DS_AVLRank(tree,p) - 1);
        Add(ranksubs,p);
        p := DS_AVLLeft(tree,p);
      elif c > 0 then     # data > DS_AVLData(tree,p)
        p := DS_AVLRight(tree,p);
      fi;
      Add(nodes,p);
      n := n + 1;
      Add(path,c);
    fi;

    if p = 0 then
      # error, we did not find data
      for i in ranksubs do
        DS_AVLSetRank(tree,i,DS_AVLRank(tree,i) + 1);
      od;
      return fail;
    fi;

  until c = 0;   # until we find the right node
  # now data is equal to DS_AVLData(tree,p,) so this node p must be removed.
  # the tree must be modified between tree![6] and nodes[n] along path
  # Ranks are already done up there

  # now we have to search a neighbour, we modify "nodes" and "path" but not n!
  m := n;
  if DS_AVLBalFactor(tree,p) < 0 then   # search to the left
    l := DS_AVLLeft(tree,p);   # must be a node!
    DS_AVLSetRank(tree,p,DS_AVLRank(tree,p) - 1);
    # we will delete in left subtree!
    Add(nodes,l);
    m := m + 1;
    Add(path,-1);
    while DS_AVLRight(tree,l) <> 0 do
      l := DS_AVLRight(tree,l);
      Add(nodes,l);
      m := m + 1;
      Add(path,1);
    od;
    c := -1;       # we got predecessor
  elif DS_AVLBalFactor(tree,p) > 0 then    # search to the right
    l := DS_AVLRight(tree,p);  # must be a node!
    Add(nodes,l);
    m := m + 1;
    Add(path,1);
    while DS_AVLLeft(tree,l) <> 0 do
      DS_AVLSetRank(tree,l,DS_AVLRank(tree,l) - 1);
      # we will delete in left subtree!
      l := DS_AVLLeft(tree,l);
      Add(nodes,l);
      m := m + 1;
      Add(path,-1);
    od;
    c := 1;        # we got successor
  else   # equal depths
    if DS_AVLLeft(tree,p) <> 0 then
      l := DS_AVLLeft(tree,p);
      DS_AVLSetRank(tree,p,DS_AVLRank(tree,p) - 1);
      Add(nodes,l);
      m := m + 1;
      Add(path,-1);
      while DS_AVLRight(tree,l) <> 0 do
        l := DS_AVLRight(tree,l);
        Add(nodes,l);
        m := m + 1;
        Add(path,1);
      od;
      c := -1;     # we got predecessor
    else           # we got an end node
      l := p;
      c := 0;
    fi;
  fi;
  # l points now to a neighbour, in case c = -1 to the predecessor, in case
  # c = 1 to the successor, or to p itself in case c = 0
  # "nodes" and "path" is updated, but n could be < m

  # Copy Data from l up to p: order is NOT modified
  DS_AVLSetData(tree,p,DS_AVLData(tree,l));
     # works for m = n, i.e. if p is end node

  # Delete node at l = nodes[m] by modifying nodes[m-1]:
  # Note: nodes[m] has maximal one subtree!
  if c <= 0 then
    r := DS_AVLLeft(tree,l);
  else  #  c > 0
    r := DS_AVLRight(tree,l);
  fi;
  if path[m-1] < 0 then
    DS_AVLSetLeft(tree,nodes[m-1],r);
  else
    DS_AVLSetRight(tree,nodes[m-1],r);
  fi;
  tree![3] := tree![3] - 1;
  old := DS_AVLFreeNode(tree,l);

  # modify balance factors:
  # the subtree nodes[m-1] has become shorter at its left (resp. right)
  # subtree, if path[m-1]=-1 (resp. +1). We have to react according to
  # the BalFactor at this node and then up the tree, if the whole subtree
  # has shrunk:
  # (we decrement m and work until the corresponding subtree has not shrunk)
  m := m - 1;  # start work HERE
  while m >= 1 do
    if DS_AVLBalFactor(tree,nodes[m]) = 0 then
      DS_AVLSetBalFactor(tree,nodes[m],-path[m]);  # we made path[m] shorter
      return old;
    elif DS_AVLBalFactor(tree,nodes[m]) = path[m] then
      DS_AVLSetBalFactor(tree,nodes[m],0);         # we made path[m] shorter
    else    # tree is out of balance
      p := DS_AVLRebalance(tree,nodes[m]);
      if m = 1 then
        tree![6] := p.newroot;
        return old;               # everything is done
      elif path[m-1] = -1 then
        DS_AVLSetLeft(tree,nodes[m-1],p.newroot);
      else
        DS_AVLSetRight(tree,nodes[m-1],p.newroot);
      fi;
      if not p.shorter then return old; fi;   # nothing happens further up
    fi;
    m := m - 1;
  od;
  return old;
end;
if IsBound(DS_AVLDelete_C) then
    InstallGlobalFunction(DS_AVLDelete, DS_AVLDelete_C);
else
    InstallGlobalFunction(DS_AVLDelete, DS_AVLDelete_GAP);
fi;

DS_AVLIndexDelete_GAP := function(tree,index)
  # Parameters: tree, index
  #  index is the index of the element to be deleted, must be between 1 and
  #          tree![3] inclusively
  #  tree is a AVL
  # returns fail if index is out of range, otherwise the deleted key;
  local p, path, nodes, n, offset, c, m, l, r, x;

  if index < 1 or index > tree![3] then
    return fail;
  fi;

  p := tree![6];
  if p = 0 then   # Nothing to delete or find
    return fail;
  fi;
  if tree![3] = 1 then
    # index must be equal to 1
    x := DS_AVLData(tree,tree![6]);
    tree![3] := 0;
    tree![6] := 0;
    DS_AVLFreeNode(tree,p);
    return x;
  fi;

  # let's first find the right position in the tree:
  path := EmptyPlist(10);     # here all steps are recorded: -1:left, +1:right
  nodes := EmptyPlist(10);
  nodes[1] := p;   # here we store all nodes on our way, nodes[i+1] is reached
                   # from nodes[i] by walking one step path[i]
  n := 1;          # this is the length of "nodes"
  offset := 0;     # number of "smaller" nodes than subtree in whole tree

  repeat

    # what is the next step?
    if index = offset+DS_AVLRank(tree,p) then
      c := 0;   # we found our node!
      x := DS_AVLData(tree,p);
    elif index < offset+DS_AVLRank(tree,p) then
      c := -1;  # we have to go left
    else
      c := +1;  # we have to go right
    fi;

    if c <> 0 then  # only if data not found!
      if c < 0 then       # data < DS_AVLData(tree,p)
        DS_AVLSetRank(tree,p,DS_AVLRank(tree,p) - 1);
        p := DS_AVLLeft(tree,p);
      elif c > 0 then     # data > DS_AVLData(tree,p)
        offset := offset + DS_AVLRank(tree,p);
        p := DS_AVLRight(tree,p);
      fi;
      Add(nodes,p);
      n := n + 1;
      Add(path,c);
    fi;

  until c = 0;   # until we find the right node
  # now index is right, so this node p must be removed.
  # the tree must be modified between tree.First and nodes[n] along path
  # Ranks are already done up there

  # now we have to search a neighbour, we modify "nodes" and "path" but not n!
  m := n;
  if DS_AVLBalFactor(tree,p) < 0 then   # search to the left
    l := DS_AVLLeft(tree,p);   # must be a node!
    DS_AVLSetRank(tree,p,DS_AVLRank(tree,p) - 1);
    # we will delete in left subtree!
    Add(nodes,l);
    m := m + 1;
    Add(path,-1);
    while DS_AVLRight(tree,l) <> 0 do
      l := DS_AVLRight(tree,l);
      Add(nodes,l);
      m := m + 1;
      Add(path,1);
    od;
    c := -1;       # we got predecessor
  elif DS_AVLBalFactor(tree,p) > 0 then    # search to the right
    l := DS_AVLRight(tree,p);  # must be a node!
    Add(nodes,l);
    m := m + 1;
    Add(path,1);
    while DS_AVLLeft(tree,l) <> 0 do
      DS_AVLSetRank(tree,l,DS_AVLRank(tree,l) - 1);
      # we will delete in left subtree!
      l := DS_AVLLeft(tree,l);
      Add(nodes,l);
      m := m + 1;
      Add(path,-1);
    od;
    c := 1;        # we got successor
  else   # equal depths
    if DS_AVLLeft(tree,p) <> 0 then
      l := DS_AVLLeft(tree,p);
      DS_AVLSetRank(tree,p,DS_AVLRank(tree,p) - 1);
      # we will delete in left subtree!
      Add(nodes,l);
      m := m + 1;
      Add(path,-1);
      while DS_AVLRight(tree,l) <> 0 do
        l := DS_AVLRight(tree,l);
        Add(nodes,l);
        m := m + 1;
        Add(path,1);
      od;
      c := -1;     # we got predecessor
    else           # we got an end node
      l := p;
      c := 0;
    fi;
  fi;
  # l points now to a neighbour, in case c = -1 to the predecessor, in case
  # c = 1 to the successor, or to p itself in case c = 0
  # "nodes" and "path" is updated, but n could be < m

  # Copy Data from l up to p: order is NOT modified
  DS_AVLSetData(tree,p,DS_AVLData(tree,l));
  # works for m = n, i.e. if p is end node

  # Delete node at l = nodes[m] by modifying nodes[m-1]:
  # Note: nodes[m] has maximal one subtree!
  if c <= 0 then
    r := DS_AVLLeft(tree,l);
  else  #  c > 0
    r := DS_AVLRight(tree,l);
  fi;
  if path[m-1] < 0 then
    DS_AVLSetLeft(tree,nodes[m-1],r);
  else
    DS_AVLSetRight(tree,nodes[m-1],r);
  fi;
  tree![3] := tree![3] - 1;
  DS_AVLFreeNode(tree,l);

  # modify balance factors:
  # the subtree nodes[m-1] has become shorter at its left (resp. right)
  # subtree, if path[m-1]=-1 (resp. +1). We have to react according to
  # the BalFactor at this node and then up the tree, if the whole subtree
  # has shrunk:
  # (we decrement m and work until the corresponding subtree has not shrunk)
  m := m - 1;  # start work HERE
  while m >= 1 do
    if DS_AVLBalFactor(tree,nodes[m]) = 0 then
      DS_AVLSetBalFactor(tree,nodes[m],-path[m]);  # we made path[m] shorter
      return x;
    elif DS_AVLBalFactor(tree,nodes[m]) = path[m] then
      DS_AVLSetBalFactor(tree,nodes[m],0);         # we made path[m] shorter
    else    # tree is out of balance
      p := DS_AVLRebalance(tree,nodes[m]);
      if m = 1 then
        tree![6] := p.newroot;
        return x;               # everything is done
      elif path[m-1] = -1 then
        DS_AVLSetLeft(tree,nodes[m-1],p.newroot);
      else
        DS_AVLSetRight(tree,nodes[m-1],p.newroot);
      fi;
      if not p.shorter then return x; fi;   # nothing happens further up
    fi;
    m := m - 1;
  od;
  return x;
end;
if IsBound(DS_AVLIndexDelete_C) then
    InstallGlobalFunction(DS_AVLIndexDelete, DS_AVLIndexDelete_C);
else
    InstallGlobalFunction(DS_AVLIndexDelete, DS_AVLIndexDelete_GAP);
fi;


DS_AVLToList_GAP := function(tree)
  # walks recursively through the tree and builds a list, where every entry
  # belongs to a node in the order of the tree and each entry is a list,
  # containing the data as first entry, the depth in the tree as second
  # and the balance factor as third. Mainly for test purposes.

  local l, DoRecursion;

  l := EmptyPlist(tree![3]);

  DoRecursion := function(p,depth)
    # does the work
    if DS_AVLLeft(tree,p) <> 0 then
      DoRecursion(DS_AVLLeft(tree,p),depth+1);
    fi;
    Add(l,[DS_AVLData(tree,p),depth,DS_AVLBalFactor(tree,p)]);
    if DS_AVLRight(tree,p) <> 0 then
      DoRecursion(DS_AVLRight(tree,p),depth+1);
    fi;
  end;

  DoRecursion(tree![6],1);
  return l;
end;
if IsBound(DS_AVLToList_C) then
    InstallGlobalFunction(DS_AVLToList, DS_AVLToList_C);
else
    InstallGlobalFunction(DS_AVLToList, DS_AVLToList_GAP);
fi;

BindGlobal( "DS_AVLTest", function(tree)
  # walks recursively through the tree and tests its balancedness. Returns
  # the depth or the subtree where the tree is not balanced. Mainly for test
  # purposes. Returns tree if the NumberOfNodes is not correct.

  local error, DoRecursion, depth;

  error := false;

  DoRecursion := function(p)
    # does the work, returns false, if an error is detected in the subtree
    # and a list with the depth of the tree and the number of nodes in it.
    local ldepth, rdepth;

    if DS_AVLLeft(tree,p) <> 0 then
      ldepth := DoRecursion(DS_AVLLeft(tree,p));
      if ldepth = false then
        return false;
      fi;
    else
      ldepth := [0,0];
    fi;
    if DS_AVLRight(tree,p) <> 0 then
      rdepth := DoRecursion(DS_AVLRight(tree,p));
      if rdepth = false then
        return false;
      fi;
    else
      rdepth := [0,0];
    fi;
    if AbsInt(rdepth[1]-ldepth[1]) > 1 or
       DS_AVLBalFactor(tree,p) <> rdepth[1]-ldepth[1] or
       DS_AVLRank(tree,p) <> ldepth[2] + 1 then
      error := p;
      return false;
    else
      return [Maximum(ldepth[1],rdepth[1])+1,ldepth[2]+rdepth[2]+1];
    fi;
  end;

  if tree![6] = 0 then
    return rec( depth := 0, ok := true );
  else
    depth := DoRecursion(tree![6]);
    if depth = false then
      return rec( badsubtree := error, ok := false );
                                # set from within DoRecursion
    else
      if depth[2] = tree![3] then
        return rec( depth := depth[1], ok := true );
                    # Number of Nodes is correct!
      else
        return rec( badsubtree := tree![6], ok := false);
      fi;
    fi;
  fi;
end);

DS_AVLFindIndex_GAP := function(tree,data)
  # Parameters: tree, data
  #  t is a AVL
  #  data is a data structure defined by the user
  # Searches in tree for a node equal to data, returns its index or fail
  # if not found.
  local compare, p, c, index;
  compare := tree![5];
  p := tree![6];
  index := 0;
  while p >= 8 do
    c := compare(data,DS_AVLData(tree,p));
    if c = 0 then
      return index + DS_AVLRank(tree,p);
    elif c < 0 then    # data < DS_AVLData(tree,p)
      p := DS_AVLLeft(tree,p);
    else               # data > DS_AVLData(tree,p)
      index := index + DS_AVLRank(tree,p);
      p := DS_AVLRight(tree,p);
    fi;
  od;
  return fail;
end ;
if IsBound(DS_AVLFindIndex_C) then
    InstallGlobalFunction(DS_AVLFindIndex, DS_AVLFindIndex_C);
else
    InstallGlobalFunction(DS_AVLFindIndex, DS_AVLFindIndex_GAP);
fi;

InstallOtherMethod( ELM_LIST, "for an avl tree and an index",
  [ IsDS_AVLTree and IsDS_AVLTreeFlatRep, IsPosInt ],
  DS_AVLIndex );

InstallOtherMethod( Position, "for an avl tree, an object, and an index",
  [ IsDS_AVLTree and IsDS_AVLTreeFlatRep, IsObject, IsInt ],
  function( t, x, pos )
    local i,j;
    i := DS_AVLFindIndex(t,x);
    if i = fail or i <= pos then
        return fail;
    else
        return i;
    fi;
  end);

InstallOtherMethod( Remove, "for an avl tree and an index",
  [ IsDS_AVLTree and IsDS_AVLTreeFlatRep and IsMutable, IsPosInt ],
  DS_AVLIndexDelete );

InstallOtherMethod( Remove, "for an avl tree",
  [ IsDS_AVLTree and IsDS_AVLTreeFlatRep and IsMutable ],
  function( t )
    return DS_AVLIndexDelete(t,t![3]);
  end );

InstallOtherMethod( Length, "for an avl tree",
  [ IsDS_AVLTree and IsDS_AVLTreeFlatRep ],
  function( t )
    return t![3];
  end );

InstallOtherMethod( ADD_LIST, "for an avl tree and an object",
  [ IsDS_AVLTree and IsDS_AVLTreeFlatRep and IsMutable, IsObject ],
  function( t, x )
    DS_AVLIndexAdd(t,x,true,t![3]+1);
  end );

InstallOtherMethod( ADD_LIST, "for an avl tree, an object and a position",
  [ IsDS_AVLTree and IsDS_AVLTreeFlatRep and IsMutable, IsObject, IsPosInt ],
  function( t, x, pos )
    DS_AVLIndexAdd(t,x,true,pos);
  end );

InstallOtherMethod( IN, "for an object and an avl tree",
  [ IsObject, IsDS_AVLTree and IsDS_AVLTreeFlatRep ],
  function( x, t )
    return DS_AVLFind(t,x) <> fail;
  end );


##
##  This program is free software: you can redistribute it and/or modify
##  it under the terms of the GNU General Public License as published by
##  the Free Software Foundation, either version 3 of the License, or
##  (at your option) any later version.
##
##  This program is distributed in the hope that it will be useful,
##  but WITHOUT ANY WARRANTY; without even the implied warranty of
##  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
##  GNU General Public License for more details.
##
##  You should have received a copy of the GNU General Public License
##  along with this program.  If not, see <http://www.gnu.org/licenses/>.
##
