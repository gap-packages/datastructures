#############################################################################
##
##                             gapdata package
##  cache2.gd
##                                                          Juergen Mueller
##                                                          Max Neunhoeffer
##                                                             Felix Noeske
##
##  Copyright 2005-2013 by the authors.
##  This file is free software, see license information at the end.
##
##  Declaration stuff for caching.
##
#############################################################################
##
##
## This code makes an attempt at implementing a cache without relying on
## weak pointers and providing some index structure into the cache
##
## At the moment this might conflict with the caching code taken from orb
##
########################
# Generic caching code:
########################

BindGlobal( "CacheNodesFamily", NewFamily( "CacheNodesFamily" ) );
BindGlobal( "CachesFamily", CollectionsFamily( CacheNodesFamily ) );

DeclareCategory("IsCache", IsNonAtomicComponentObjectRep);
DeclareCategory("IsCacheNode", IsNonAtomicComponentObjectRep);

# Linked List caches as taken from the orb package
DeclareRepresentation("IsLinkedListCacheRep", IsCache,
        [ "head", "tail"     # doubly linked list of cached objects
          , "nrobs"          # number of objects currently in cache
          , "memory"         # memory used by cached objects (this is really in
                             # in terms of memory units passed to the caching
                             # function
          , "memorylimit"    # maximum number of memory units used before
                             # eviction
        ]);
DeclareRepresentation("IsLinkedListCacheNodeRep", IsCacheNode,
        [ "next", "prev"     # links in the doubly linked list of
                             # cache nodes
          , "ob"             # cached object
          , "mem"            # amount of memory used by object
          ] );
BindGlobal( "LinkedListCacheNodeType",
  NewType( CacheNodesFamily, IsLinkedListCacheNodeRep and IsMutable) );

# Caches With Dictionary Lookup
DeclareRepresentation("IsLinkedListDictionaryCacheRep", IsCache and IsLookupDictionary,
       [ "head", "tail"     # doubly linked list of cached objects
          , "nrobs"          # number of objects currently in cache
          , "memory"         # memory used by cached objects (this is really in
                             # in terms of memory units passed to the caching
                             # function
          , "memorylimit"    # maximum number of memory units used before
                             # eviction
          , "inserter"       # this function inserts a key
          , "finder"         # this function finds a key
          , "deleter"        # this function is called and passed the ob
                             # when eviction happens
       ]);

DeclareRepresentation("IsLinkedListCacheNodeWithKeyRep", IsCacheNode,
        [ "next", "prev"     # links in the doubly linked list of 
                             # cache nodes
          , "key"            # key in the index structure
          , "ob"             # cached object
          , "mem"            # amount of memory used by object
          ] );
BindGlobal( "LinkedListCacheNodeWithKeyType".
  NewType( CacheNodesFamily, IsLinkedListCacheNodeWithKeyRep and IsMutable) );

DeclareRepresenatation("IsListKeyCacheRep", IsCache,
        [ "cache", "indexlist" ]);

# Operations for Caches
DeclareOperation("Cache", [IsInt]);
DeclareOperation("LinkedListCache", [IsInt]);
DeclareOperation("KeyObjectCache", [IsInt, IsFunction, IsFunction, IsFunction]);
DeclareOperation("ListKeyCache", [IsInt]);

DeclareOperation("ClearCache", [IsCache]);
DeclareOperation("CacheObject", [IsCache, IsObject]);
DeclareOperation("UseCacheObject", [IsCache, IsObject]);

# DeclareGlobalFunction("CacheObject");
DeclareGlobalFunction("EnforceCachelimit");
#DeclareGlobalFunction("UseCacheObjectByKey");
#DeclareGlobalFunction("UseCacheObject");

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
