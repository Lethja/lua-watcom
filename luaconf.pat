--- luaconf.h
+++ luaconf.h
@@ -79,7 +79,10 @@
 /*
 @@ LUAI_IS32INT is true iff 'int' has (at least) 32 bits.
 */
+/*
+ * TODO: Find a way to determine int size that Watcom respects...
 #define LUAI_IS32INT	((UINT_MAX >> 30) >= 3)
+*/
 
 /* }================================================================== */
 
@@ -742,7 +745,6 @@
 #define LUAI_MAXSTACK		15000
 #endif
 
-
 /*
 @@ LUA_EXTRASPACE defines the size of a raw memory area associated with
 ** a Lua state with very fast access.
