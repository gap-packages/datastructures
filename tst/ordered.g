#
# A workout for any ordered set datastructure implenentation
#

# s in an empty data structure
# l1 and l2 are lists with the same entries but not necessarily in the same order
# 

osdsworkout := function(s, l1, l2)
    local  count, x, iter, sl1;
    if not IsEmpty(s) then
        Print("Initial DS not empty");
        return false;
    fi;   
    if Size(s) <> 0 then
        Print("Initial size not zero");
    fi;
    count := 0;
    for x in l1 do 
        AddSet(s,x);
        if not x in s then
            Print("add didn't add");
            return false;            
        fi;
        count := count+1;
        if Size(s) <> count then
            Error("Wrong size after add");
            return false;
        fi;
    od;
    for x in l1 do 
        AddSet(s,x);
        if not x in s then
            Print("add actually removed");
            return false;            
        fi;
        if Size(s) <> count then
            Error("Wrong size after second add");
            return false;
        fi;
    od;
    iter := IteratorSorted(s);
    sl1 := ShallowCopy(l1);
    Sort(sl1, LessFunction(s));
    count := 1;    
    for x in iter do
        if count > Length(sl1) then
            Print("too many objects");
            return false;
        fi;
        if sl1[count] <> x then
            Print("Wrong object");
            return false;            
        fi;
        count := count+1;        
    od;
    if count <> Length(sl1) + 1 then
        Print("Final count doesn't match");
        return false;
    fi;   
    count := Size(s);    
    for x in l2 do 
        if 1 <> RemoveSet(s,x) then
            Print("missing entry\n");
            return false;            
        fi;
        if 0 <> RemoveSet(s,x) then
            Print("removed twice\n");
            return false;            
        fi;
        if x in s then
            Print("Still there after remove");
            return false;
        fi;
        count := count-1;
        if Size(s) <> count then
            Error("Wrong size after remove ",Size(s), " ",count);
            return false;
        fi;        
    od;
    if not IsEmpty(s) then
        Print("not empty at end");
        return false;        
    fi;
    return true;    
end;

#
# Run those tests with randomly ordered integers 1..n
# and a newly constructed data structure of type type
#
osdstest := function(n,type)
    local  l1, l2, s;
    l1 := ListPerm(Random(SymmetricGroup(n)),n);
    l2 := ListPerm(Random(SymmetricGroup(n)),n);
    s := OrderedSetDS(type);
    if not  osdsworkout(s, l1, l2) then
        return false;
    fi;
    #
    # Again with a non-default comparison
    #
    s := OrderedSetDS(type, function(a,b) return String(a) < String(b); end);
    if not  osdsworkout(s, l1, l2) then
        return false;
    fi;
    #
    # and with non-integer entries
    #
    l1 := List(l1, String);
    l2 := List(l2, String);
    s := OrderedSetDS(type);
    if not  osdsworkout(s, l1, l2) then
        return false;
    fi;
    return true;    
end;

osdstestordered := function(n, type)
    local  s;
    s := OrderedSetDS(type);
    return osdsworkout(s, [1..n], [1..n]) and 
           osdsworkout(s, [1..n], [n,n-1..1]) and
           osdsworkout(s, [n,n-1..1], [1..n]) and 
           osdsworkout(s, [n,n-1..1], [n,n-1..1]);
end;

#
# These match the declarations in ordered.gd
#
  
osdstestconstruct := function(type)
    local s;
    s := OrderedSetDS(type, {a,b} -> b < a, [1..100], GlobalMersenneTwister);
    if AsListSorted(s) <> [100,99..1] then
        Print("Failed fun, data, rs\n");        
        return false;
    fi;
    s := OrderedSetDS(type, {a,b} -> b < a, GlobalMersenneTwister);
    if not IsEmpty(s) then
        Print("Failed fun, rs\n");        
        return false;
    fi;
    s := OrderedSetDS(type, [1..100], GlobalMersenneTwister);
    if AsListSorted(s) <> [1..100] then
        Print("Failed data, rs\n");        
        return false;
    fi;
    s := OrderedSetDS(type, {a,b} -> b < a, [1..100]);
    if AsListSorted(s) <> [100,99..1] then
        Print("Failed fun, data\n");        
        return false;
    fi;
    s := OrderedSetDS(type, {a,b} -> b < a);
    if not IsEmpty(s) then
        Print("Failed fun\n");        
        return false;
    fi;
    s := OrderedSetDS(type, [1..100]);
    if AsListSorted(s) <> [1..100] then
        Print("Failed data\n");        
        return false;
    fi;
    s := OrderedSetDS(type);
    if not IsEmpty(s) then
        Print("Failed no args\n");        
        return false;
    fi;
    s := OrderedSetDS(type, s);
    if not IsEmpty(s) then
        Print("Failed copy\n");        
        return false;
    fi;
    s := OrderedSetDS(type, Iterator(List([1..100],String)));
    if not Size(s) = 100 then
        Print("Failed iter\n");        
        return false;
    fi;
    s := OrderedSetDS(type, {a,b} -> Int(a) < Int(b), Iterator(List([1..100],String)));
    if not AsListSorted(s) = List([1..100],String)  then
        Print("Failed fun, iter\n");        
        return false;
    fi;
    s := OrderedSetDS(type, {a,b} -> Int(a) < Int(b), Iterator(List([1..100],String)), 
                 GlobalMersenneTwister);
    if not AsListSorted(s) = List([1..100],String)  then
        Print("Failed fun, iter, rs\n");        
        return false;
    fi;
    return true;
end;

    
    
    
    
