##
#Y  Copyright (C) 2017 The GAP Group
##


InstallGlobalFunction(HashBasic, DATA_HASH_FUNC_RECURSIVE);

InstallGlobalFunction(Hash_PermGroup_Complete,
    {G} -> DATA_HASH_FUNC_RECURSIVE(Set(GeneratorsSmallest(G))));

# This function assumes we have already calculated a stabilizer chain
# We find a small set of properties we can cheaply calculate from the
# stabilizer chain
InstallGlobalFunction(Hash_PermGroup_Fast,
    {G} -> DATA_HASH_FUNC_RECURSIVE([Size(G), Transitivity(G), Set(Orbits(G), Set)]));
