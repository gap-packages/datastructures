#############################################################################
##
##                             orb package
##  cache.gd
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


########################
# Generic caching code:
########################

BindGlobal( "DS_CacheNodesFamily", NewFamily( "DS_CacheNodesFamily" ) );
BindGlobal( "DS_CachesFamily", CollectionsFamily( DS_CacheNodesFamily ) );

DeclareCategory("IsDS_Cache", IsNonAtomicComponentObjectRep);
DeclareRepresentation("IsDS_LinkedListCacheRep", IsDS_Cache,
  [ "head", "tail", "nrobs", "memory", "memorylimit" ]);
DeclareCategory("IsDS_CacheNode", IsNonAtomicComponentObjectRep);
DeclareRepresentation("IsDS_LinkedListCacheNodeRep", IsDS_CacheNode,
  [ "next", "prev", "ob", "mem" ] );
BindGlobal( "DS_LinkedListCacheNodeType",
  NewType( DS_CacheNodesFamily, IsDS_LinkedListCacheNodeRep and IsMutable) );

DeclareOperation("DS_LinkedListCache", [IsInt]);
DeclareOperation("DS_ClearCache", [IsDS_Cache]);
DeclareGlobalFunction("DS_CacheObject");
DeclareGlobalFunction("DS_EnforceCachelimit");
DeclareGlobalFunction("DS_UseCacheObject");


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
