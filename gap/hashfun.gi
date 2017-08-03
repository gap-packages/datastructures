#############################################################################
##
##  datastructures package
##
##  Copyright 2016 by the package authors.
##  Licensed under the GPL 2 or later.
##
#############################################################################


#


#
# Fallback method: If no other method matches, return fail.
#
InstallMethod( ChooseHashFunction, "fallback method",
    [IsObject],
function(p)
    return fail;
end );


#
# compressed GF2 vectors
#
InstallGlobalFunction( DATA_HashFunctionForShortGF2Vectors,
function(v)
    return NumberFFVector(v, 2);
end );

InstallGlobalFunction( DATA_HashFunctionForGF2Vectors,
function(v)
    local bytelen;
    bytelen := QuoInt(Length(v), 8);
    return HashKeyBag(v, 101, 2*GAPInfo.BytesPerVariable, bytelen);
end );

InstallMethod( ChooseHashFunction, "for compressed gf2 vectors",
    [IsGF2VectorRep and IsList],
function(p)
    local bytelen;
    bytelen := QuoInt(Length(p), 8);

    # Note: Unfortunately gf2 vectors are not "clean" after their
    # "official" length, therefore we *must not* use the last, half-used
    # byte. This inevitably leads to collisions!
    #
    # Second note: For the following to be correct, you MUST NOT
    # use the returned hash function on shorter or longer
    # vectors than the example vector.

    # TODO: perhaps add an assertion check to verify that?
    
    # TODO: perhaps we can "fix" GAP to clear the bits?
    # but perhaps there is a reason (e.g. performance) why it doesn't do that
    # already.
    if bytelen <= 8 then
        return DATA_HashFunctionForShortGF2Vectors;
    else
        return DATA_HashFunctionForGF2Vectors;
    fi;
end );

#
# compressed vectors over small fields other than GF(2)
#
InstallGlobalFunction( DATA_HashFunctionForShort8BitVectors,
function(v)
    # FIXME: either need data[2], or (better) a native C implementation
    # which also takes care of the trailing "dirty bits"
    #return NumberFFVector(v, data[2]);
    return fail;
end );

InstallGlobalFunction( DATA_HashFunctionFor8BitVectors,
function(v)
    # FIXME: either need data[2], or (better) a native C implementation
    # which also takes care of the trailing "dirty bits"
    #return HashKeyBag(v, 101, 3 * GAPInfo.BytesPerVariable, data[2]);
    return fail;
end );


InstallMethod( ChooseHashFunction, "for compressed 8bit vectors",
    [Is8BitVectorRep and IsList],
function(p)
    local bytelen,i,q,qq;
    q := Q_VEC8BIT(p);
    qq := q;
    i := 0;
    while qq <= 256 do
        qq := qq * q;
        i := i + 1;
    od;
    # Compute i := LogInt(256, q)

    # i is now the number of field elements per byte
    bytelen := QuoInt(Length(p),i);
    # Note that unfortunately 8bit vectors are not "clean" after their
    # "official" length, therefore we *must not* use the last, half-used
    # byte. This inevitably leads to collisions!

# TODO: verify this. possibly work around it in GAP...
    if bytelen <= 8 then
        return rec( func := DATA_HashFunctionForShort8BitVectors,
                    data := [hashlen,q] );
    else
        return rec( func := DATA_HashFunctionFor8BitVectors,
                    data := [hashlen,bytelen] );
    fi;
end );

#
# uncompressed finite field vectors
#
InstallMethod( ChooseHashFunction, "for finite field vectors over big finite fields",
    [IsList],
function(l)
    local f, q;
    if NestingDepthA(l) = 1 and Length(l) > 0 and IsFFE(l[1]) then
        # FIXME: so this assumes the list is homogeneous, and then
        # blindly asks for a list? Perhaps we should at least
        # check for IsHomogeneousList and/or add that to the filters list?
        f := Field(l);
        q := Size(f);
        return rec( func := DATA_HashFunctionForShort8BitVectors,
                    data := [hashlen,q] );
    fi;
    TryNextMethod();
end );


#
# compressed matrices
#
InstallGlobalFunction( DATA_HashFunctionForCompressedMats,
function(mat)
    local i, res;

# FIXME: do not do this. Instead, properly chain
# HashKeyBag invocations, by using the seed argument:
if false then
    # HACKISH prototype; does not take short vectors into account,
    # nor GF(2) vs other fields, etc.
    res := 101;
    offset := 3 * GAPInfo.BytesPerVariable;
TODO
    bytelen := 100;
    for i in [1 .. Length(mat)] do
        HashKeyBag(mat[i], res, offset, bytelen);
    od;

    end
fi;

# Alternatively, compute the separate hashes for each row,
# then compute hash of the resulting vector (but this
# introduces more temporaries, so is not as nice)

  res := 0;
  for i in [1..Length(mat)] do
      res := (res * data[3] + data[2].func(mat[i],data[2].data)) mod data[1];
  od;
  return res + 1;
end );

InstallMethod( ChooseHashFunction, "for compressed gf2 matrices",
    [IsGF2MatrixRep and IsList],
function(p)
    local data;
    data := [hashlen,ChooseHashFunction(p[1],hashlen),
             PowerMod(2,Length(p[1]),hashlen)];
    return rec( func := DATA_HashFunctionForCompressedMats,
                data := data );
  end );

InstallMethod( ChooseHashFunction, "for compressed 8bit matrices",
    [Is8BitMatrixRep and IsList],
function(p)
    local data,q;
    q := Q_VEC8BIT(p[1]);
    data := [hashlen,ChooseHashFunction(p[1],hashlen),
             PowerMod(q,Length(p[1]),hashlen)];
    return rec( func := DATA_HashFunctionForCompressedMats,
                data := data );
  end );


#
# Integers
#
InstallGlobalFunction( DATA_HashFunctionForIntegers,
function(x)
    # TODO: implement this on the C level, to return
    # the integer itself it is a small integer; or else
    # to return the integer mod 2^N so that it fits into
    # a small integer
    return x;
end );

InstallMethod( ChooseHashFunction, "for integers", [IsInt],
  function(p)
    return DATA_HashFunctionForIntegers;
  end );

#
# IsObjWithMemory
#
InstallGlobalFunction( DATA_HashFunctionForMemory,
function(x,data)
  return data[1](x!.el,data[2]);
end );

InstallMethod( ChooseHashFunction, "for memory objects",
  [IsObjWithMemory],
  function(p)
    local hf;
    hf := ChooseHashFunction(p!.el);
    return rec( func := DATA_HashFunctionForMemory, data := hf );
  end );

InstallGlobalFunction( DATA_HashFunctionForPermutations,
function(p,data)
  local l;
  l:=LARGEST_MOVED_POINT_PERM(p);
  if IsPerm4Rep(p) then
    # is it a proper 4byte perm?
    if l>65536 then
      return HashKeyBag(p,255,0,4*l) mod data + 1;
    else
      # the permutation does not require 4 bytes. Trim in two
      # byte representation (we need to do this to get consistent
      # hash keys, regardless of representation.)
      TRIM_PERM(p,l);
    fi;
   fi;
   # now we have a Perm2Rep:
   return HashKeyBag(p,255,0,2*l) mod data + 1;
end );

InstallGlobalFunction( DATA_HashFunctionForPlainFlatList,
  function( x, data )
    return (HashKeyBag( x, 0, 0,
                        GAPInfo.BytesPerVariable*(Length(x)+1)) mod data)+1;
  end );

if IsBound(HASH_FUNC_FOR_TRANS) then
    InstallGlobalFunction( DATA_HashFunctionForTransformations, HASH_FUNC_FOR_TRANS);
elif IsBound(IsTrans2Rep) and IsBound(IsTrans4Rep) then
  InstallGlobalFunction( DATA_HashFunctionForTransformations,
  function(t, data)
    local deg;
      deg:=DegreeOfTransformation(t);
      if IsTrans4Rep(t) then
        if deg<=65536 then
          TrimTransformation(t, deg);
        else
          return HashKeyBag(t,255,0,4*deg) mod data + 1;
        fi;
      fi;
      return HashKeyBag(t,255,0,2*deg) mod data + 1;
  end);
else
#XXX Under which circumstances would this even work?
  InstallGlobalFunction( DATA_HashFunctionForTransformations,
    function(t,data)
      return DATA_HashFunctionForPlainFlatList(t![1],data);
    end );
fi;

InstallGlobalFunction( MakeHashFunctionForPlainFlatList,
  function( len )
    return rec( func := DATA_HashFunctionForPlainFlatList,
                data := len );
  end );

InstallMethod( ChooseHashFunction, "for permutations",
  [IsPerm],
  function(p)
    return rec( func := DATA_HashFunctionForPermutations, data := hashlen );
  end );

InstallMethod( ChooseHashFunction, "for transformations",
  [IsTransformation],
  function(t)
    return rec( func := DATA_HashFunctionForTransformations, data := hashlen );
  end );

InstallGlobalFunction( DATA_HashFunctionForIntList,
function(v,data)
  local i,res;
  res := 0;
  for i in v do
      res := (res * data[1] + i) mod data[2];
  od;
  return res+1;
end );

InstallMethod( ChooseHashFunction, "for short int lists",
  [IsList],
  function(p)
    if ForAll(p,IsInt) then
        return rec(func := DATA_HashFunctionForIntList, data := [101,hashlen]);
    fi;
    TryNextMethod();
  end );

InstallGlobalFunction( DATA_HashFunctionForNBitsPcWord,
function(v,data)
  return DATA_HashFunctionForIntList(ExtRepOfObj(v),data);
end );

InstallMethod( ChooseHashFunction, "for N bits Pc word rep",
  [IsNBitsPcWordRep],
  function(p)
    return rec(func := DATA_HashFunctionForNBitsPcWord, data := [101,hashlen]);
  end );

InstallGlobalFunction( DATA_HashFunctionForMatList,
  function(ob,data)
    local i,m,res;
    res := 0;
    for m in ob do
        res := (res * data[1] + data[3].func(m,data[3].data)) mod data[2];
    od;
    return res+1;
  end );

InstallMethod( ChooseHashFunction, "for lists of matrices",
  [IsList],
  function(l)
    # FIXME:
    local r;
    if ForAll(l,IsMatrix) then
        r := ChooseHashFunction( l[1], hashlen );
        return rec( func := DATA_HashFunctionForMatList,
                    data := [101,hashlen,r] );
    fi;
    TryNextMethod();
  end );


#
# partial permutations
#
if IsBound(HASH_FUNC_FOR_PPERM) then
    InstallGlobalFunction( DATA_HashFunctionForPartialPerms,
    DATA_HASH_FUNC_FOR_PPERM);

elif IsBound(IsPPerm2Rep) and IsBound(IsPPerm4Rep) then
    InstallGlobalFunction( DATA_HashFunctionForPartialPerms,
    function(t)
        local codeg;

        if IsPPerm4Rep(t) then
            codeg := CodegreeOfPartialPerm(t);
            if codeg < 65536 then
                TrimPartialPerm(t);
            else
                return HashKeyBag(t, 255, 4, 4 * DegreeOfPartialPerm(t));
            fi;
        fi;
        return HashKeyBag(t, 255, 2, 2 * DegreeOfPartialPerm(t));
    end);
fi;

if IsBound(IsPartialPerm) then
    InstallMethod( ChooseHashFunction, "for partial perms",
        [IsPartialPerm],
    function(t)
        return DATA_HashFunctionForPartialPerms;
    end );
fi;

#
# blists
#
InstallMethod(ChooseHashFunction, "for a blist and pos int",
    [IsBlistRep],
function(x)
    return DATA_HASH_FUNC_FOR_BLIST;
end);
