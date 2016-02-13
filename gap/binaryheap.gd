# DeclareCategory("IsHeap", IsCollection);
# BindGlobal( "HeapFamily", NewFamily("HeapFamily") );
#
# DeclareConstructor("NewHeap", [IsHeap, IsObject, IsObject, IsObject]);
#
# # Inserts a new key into the heap.
# DeclareOperation("Push", [IsHeap, IsObject, IsObject]);
# # Peek the item with the maximal key
# DeclareOperation("Peek", [IsHeap]);
# # Get the the item with the maximal key
# DeclareOperation("Pop", [IsHeap]);
# # Merge two heaps (of the same type)
# DeclareOperation("Merge", [IsHeap, IsHeap]);
#
# #
# DeclareAttribute("Size", IsHeap);
