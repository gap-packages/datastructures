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
DeclareRepresentation( "IsDS_TreeHashTabRep", IsDS_HashTab, [] );
BindGlobal( "DS_HashTabType", NewType(DS_HashTabFamily,IsDS_HashTabRep and IsMutable) );
BindGlobal( "DS_TreeHashTabType",
  NewType(DS_HashTabFamily,IsDS_TreeHashTabRep and IsMutable) );

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

# Duplicate in ORB, but probably fine to leave this name
DeclareOperation( "ChooseHashFunction", [IsObject, IsInt] );

DeclareGlobalFunction( "DS_HashFunctionReturn1" );
DeclareGlobalFunction( "DS_HashFunctionForShortGF2Vectors" );
DeclareGlobalFunction( "DS_HashFunctionForShort8BitVectors" );
DeclareGlobalFunction( "DS_HashFunctionForGF2Vectors" );
DeclareGlobalFunction( "DS_HashFunctionFor8BitVectors" );
DeclareGlobalFunction( "DS_HashFunctionForCompressedMats" );
DeclareGlobalFunction( "DS_HashFunctionForIntegers" );
DeclareGlobalFunction( "DS_HashFunctionForMemory" );
DeclareGlobalFunction( "DS_HashFunctionForPermutations" );
DeclareGlobalFunction( "DS_HashFunctionForIntList" );
DeclareGlobalFunction( "DS_HashFunctionForNBitsPcWord" );
DeclareGlobalFunction( "DS_HashFunctionModWrapper" );
DeclareGlobalFunction( "DS_HashFunctionForMatList" );
DeclareGlobalFunction( "DS_HashFunctionForPlainFlatList" );
DeclareGlobalFunction( "DS_HashFunctionForTransformations" );
DeclareGlobalFunction( "DS_MakeHashFunctionForPlainFlatList" );

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
