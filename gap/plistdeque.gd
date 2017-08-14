##
##  Datastructures: GAP package providing common datastructures.
##
##  Copyright (C) 2015-2017  The datastructures team.
##  For list of the team members, please refer to the COPYRIGHT file.
##
##  This package is licensed under the GPL 2 or later, please refer
##  to the COPYRIGHT.md and LICENSE files for details.
##

DeclareRepresentation("IsPlistDequeRep",
                      IsQueue and IsPositionalObjectRep,
                      []);
BindGlobal( "PlistDequeFamily", NewFamily("PlistDequeFamily") );
BindGlobal( "PlistDequeType",
            NewType(PlistDequeFamily, IsPlistDequeRep and IsMutable) );

DeclareGlobalFunction("PlistDeque");

DeclareGlobalFunction("PlistDequePushFront");
DeclareGlobalFunction("PlistDequePushBack");
DeclareGlobalFunction("PlistDequePopFront");
DeclareGlobalFunction("PlistDequePopBack");
DeclareGlobalFunction("PlistDequePeekFront");
DeclareGlobalFunction("PlistDequePeekBack");

DeclareGlobalFunction("PlistDequeExpand");
DeclareGlobalFunction("PlistDequeHead");
DeclareGlobalFunction("PlistDequeTail");

DeclareGlobalFunction("PlistDequeCapacity");
DeclareGlobalFunction("PlistDequeLength");

BindGlobal("QHEAD", 1);
BindGlobal("QTAIL", 2);
BindGlobal("QCAPACITY", 3);
BindGlobal("QFACTOR", 4);
BindGlobal("QDATA", 5);
