LoadPackage("datastructures", false);
# Takes two lists of objects which should compare equal (but can be different
# actual GAP objects) and a hash function and performs various tests on the
# hash function. 
# The final optional argument denotes if the hash function is 'weak', so we
# should not report any hash collisions
compareHashes := function(list1, list2, hashFunc, weakhash...)
    local hashed1, hashed2, len;
    if  Size(weakhash) > 0 and weakhash <> ["weakhash"] then
        Print("Invalid argument :", weakhash,"\n");
    fi;

    if Length(list1) <> Length(list2) then
        Print("Lists unequal length","\n");
        return;
    fi;
    len := Length(list1);
    hashed1 := List(list1, hashFunc);
    hashed2 := List(list2, hashFunc);
    if list1 <> list2 then
        Print("Lists differ at locations : ", Positions(List([1..len], x -> list1[x] <> list2[x]), true), "\n");
    fi;
    if hashed1 <> hashed2 then
        Print("hashes differ at locations : ", Positions(List([1..len], x -> hashed1[x] <> hashed2[x]), true), "\n");
    fi;
    if Size(weakhash) = 0 and Size(Set(hashed1)) <> Size(hashed1) then
        Print("hash collisions!\n");
    fi;
end;
