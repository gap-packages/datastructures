#############################################################################
##
##                             orb package
##  hash.gd
##                                                          Juergen Mueller
##                                                          Max Neunhoeffer
##                                                             Felix Noeske
##
##  Copyright 2005-2008 by the authors.
##  This file is free software, see license information at the end.
##
##  Declaration stuff for hashing.
##
#############################################################################


########################
# Generic hashing code:
########################

DeclareGlobalFunction( "InitDS_HT" );
DeclareGlobalFunction( "NewDS_HT" );
DeclareGlobalFunction( "AddDS_HT" );
DeclareGlobalFunction( "ValueDS_HT" );
DeclareGlobalFunction( "GrowDS_HT" );

BindGlobal( "DS_HashTabFamily", NewFamily("DS_HashTabFamily") );
DeclareCategory( "IsDS_HashTab", IsNonAtomicComponentObjectRep and
                              IsComponentObjectRep);
DeclareRepresentation( "IsDS_HashTabRep", IsDS_HashTab, [] );
DeclareRepresentation( "IsTreeDS_HashTabRep", IsDS_HashTab, [] );
BindGlobal( "DS_HashTabType", NewType(DS_HashTabFamily,IsDS_HashTabRep and IsMutable) );
BindGlobal( "TreeDS_HashTabType",
  NewType(DS_HashTabFamily,IsTreeDS_HashTabRep and IsMutable) );

DeclareOperation( "DS_HTCreate", [ IsObject, IsRecord ] );
DeclareOperation( "DS_HTCreate", [ IsObject ] );
DeclareOperation( "DS_HTAdd", [ IsDS_HashTab, IsObject, IsObject ] );
DeclareOperation( "DS_HTValue", [ IsDS_HashTab, IsObject ] );
DeclareOperation( "DS_HTDelete", [ IsDS_HashTab, IsObject ] );
DeclareOperation( "DS_HTUpdate", [ IsDS_HashTab, IsObject, IsObject ] );
DeclareOperation( "DS_HTGrow", [ IsDS_HashTab, IsObject ] );


#########################################################################
# Infrastructure for choosing hash functions looking at example objects:
#########################################################################

DeclareOperation( "ChooseHashFunction", [IsObject, IsInt] );

DeclareGlobalFunction( "ORB_HashFunctionReturn1" );
DeclareGlobalFunction( "ORB_HashFunctionForShortGF2Vectors" );
DeclareGlobalFunction( "ORB_HashFunctionForShort8BitVectors" );
DeclareGlobalFunction( "ORB_HashFunctionForGF2Vectors" );
DeclareGlobalFunction( "ORB_HashFunctionFor8BitVectors" );
DeclareGlobalFunction( "ORB_HashFunctionForCompressedMats" );
DeclareGlobalFunction( "ORB_HashFunctionForIntegers" );
DeclareGlobalFunction( "ORB_HashFunctionForMemory" );
DeclareGlobalFunction( "ORB_HashFunctionForPermutations" );
DeclareGlobalFunction( "ORB_HashFunctionForIntList" );
DeclareGlobalFunction( "ORB_HashFunctionForNBitsPcWord" );
DeclareGlobalFunction( "ORB_HashFunctionModWrapper" );
DeclareGlobalFunction( "ORB_HashFunctionForMatList" );
DeclareGlobalFunction( "ORB_HashFunctionForPlainFlatList" );
DeclareGlobalFunction( "ORB_HashFunctionForTransformations" );
DeclareGlobalFunction( "MakeHashFunctionForPlainFlatList" );

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
