# lqueue.gd
DeclareRepresentation("IsPlistQueueRep",
                      IsQueue and IsPositionalObjectRep,
                      []);
BindGlobal( "PlistQueueFamily", NewFamily("PlistQueueFamily") );
BindGlobal( "PlistQueueType",
            NewType(PlistQueueFamily, IsPlistQueueRep and IsMutable) );

DeclareGlobalFunction("PlistQueue");

DeclareGlobalFunction("PlistQueuePushFront");
DeclareGlobalFunction("PlistQueuePushBack");
DeclareGlobalFunction("PlistQueuePopFront");
DeclareGlobalFunction("PlistQueuePopBack");
DeclareGlobalFunction("PlistQueuePeekFront");
DeclareGlobalFunction("PlistQueuePeekBack");

DeclareGlobalFunction("PlistQueueExpand");
DeclareGlobalFunction("PlistQueueHead");
DeclareGlobalFunction("PlistQueueTail");

DeclareGlobalFunction("PlistQueueCapacity");
DeclareGlobalFunction("PlistQueueLength");

BindGlobal("QHEAD", 1);
BindGlobal("QTAIL", 2);
BindGlobal("QCAPACITY", 3);
BindGlobal("QFACTOR", 4);
BindGlobal("QDATA", 5);
