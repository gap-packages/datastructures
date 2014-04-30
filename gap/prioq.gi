#############################################################################
##
#W  prioq.gi                    GAPData                      Markus Pfeiffer
##
##
#Y  Copyright (C) 2014 The GAP Group
##
##  This file implements priority queues.
##
##
## Implementation of Priority Queues using the AVL trees defined in GAPDataa
##
#T XXX this doesn't work because the AVL trees don't support entries
#T XXX With equal ids  
InstallMethod(NewPriorityQueue,
        "for IsAVLTreePrioQRep and a sample object",
        [ IsAVLTreePrioQRep, IsObject ],
function( filter, sample )
    local result, t;
    
    #T Make a way to pass options records
    #T here. In particular allocation and 
    #T comparison functions
    #T Maybe the Key type should also be sampled? 
    #T Look into AVLTree code how that can be accomplished
    result := [ AVLTree() ];
    
    t := NewType(CollectionsFamily(FamilyObj(sample)), filter and IsPositionalObjectRep);
    
    Objectify(t, result);
    
    return result;
end);


InstallMethod( Push,
        "for IsAVLTreePrioQRep, a priority, and an object",
        [ IsAVLTreePrioQRep, IsInt, IsObject ],
function(queue, prio, obj)
    AVLAdd(queue![1], prio, obj);
end);

InstallMethod( Pop,
        "for IsAVLTreePrioQRep",
        [ IsAVLTreePrioQRep ],
function(queue, prio, obj)
    AVLAdd(queue![1], prio, obj);
end);

InstallMethod( Peek,
        "for IsAVLTreePrioQRep",
        [ IsAVLTreePrioQRep ],
function(queue, prio, obj)
    return AVLIndexLookupAdd(queue![1], prio, obj);
end);
    
InstallMethod( ViewObj,
        "for IsAVLTreePrioQRep",
        [ IsAVLTreePrioQRep ],
function(queue)
    Print("<priority queue with ",
          queue![1]![3], "/", queue![1]![4] );
    Print(" entries>");
end);

InstallMethod( PrintObj,
        "for a PlistQueue",
        [ IsAVLTreePrioQRep ],
function(queue)
  Print("<priority queue>");
end);

       
        

