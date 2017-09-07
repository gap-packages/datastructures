
InstallMethod(Push,
        "for a queue and an object",
        [IsQueue and IsMutable, IsObject],
        PushBack);

InstallMethod(Pop,
        "for a queue and an object",
        [IsQueue and IsMutable],
        PopFront);
