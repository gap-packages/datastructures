##
##  Datastructures: GAP package providing common datastructures.
##
##  Copyright (C) 2015-2017  The datastructures team.
##  For list of the team members, please refer to the COPYRIGHT file.
##
##  This package is licensed under the GPL 2 or later, please refer
##  to the COPYRIGHT.md and LICENSE files for details.
##

InstallGlobalFunction(HashBasic, DATA_HASH_FUNC_RECURSIVE);

InstallGlobalFunction(Hash_PermGroup_Complete,
    {G} -> DATA_HASH_FUNC_RECURSIVE(Set(GeneratorsSmallest(G))));

# This function assumes we have already calculated a stabilizer chain
# We find a small set of properties we can cheaply calculate from the
# stabilizer chain
InstallGlobalFunction(Hash_PermGroup_Fast,
    {G} -> DATA_HASH_FUNC_RECURSIVE([Size(G), Transitivity(G), Set(Orbits(G), Set)]));
