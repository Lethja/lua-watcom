--- lua/lopcodes.h
+++ lua/lopcodes.h
@@ -67,8 +67,9 @@ enum OpMode {iABC, iABx, iAsBx, iAx, isJ};  /* basic instruction formats */
 /* Check whether type 'int' has at least 'b' bits ('b' < 32) */
 #define L_INTHASBITS(b)		((UINT_MAX >> ((b) - 1)) >= 1)
 
-
-#if L_INTHASBITS(SIZE_Bx)
+#if defined(_M_I86)
+#define MAXARG_Bx	MAX_INT
+#elif L_INTHASBITS(SIZE_Bx)
 #define MAXARG_Bx	((1<<SIZE_Bx)-1)
 #else
 #define MAXARG_Bx	MAX_INT
@@ -76,14 +77,17 @@ enum OpMode {iABC, iABx, iAsBx, iAx, isJ};  /* basic instruction formats */
 
 #define OFFSET_sBx	(MAXARG_Bx>>1)         /* 'sBx' is signed */
 
-
-#if L_INTHASBITS(SIZE_Ax)
+#if defined(_M_I86)
+#define MAXARG_Ax	MAX_INT
+#elif L_INTHASBITS(SIZE_Ax)
 #define MAXARG_Ax	((1<<SIZE_Ax)-1)
 #else
 #define MAXARG_Ax	MAX_INT
 #endif
 
-#if L_INTHASBITS(SIZE_sJ)
+#if defined(_M_I86)
+#define MAXARG_sJ	MAX_INT
+#elif L_INTHASBITS(SIZE_sJ)
 #define MAXARG_sJ	((1 << SIZE_sJ) - 1)
 #else
 #define MAXARG_sJ	MAX_INT
--- lua/luaconf.h
+++ lua/luaconf.h
@@ -79,7 +79,12 @@
 /*
 @@ LUAI_IS32INT is true iff 'int' has (at least) 32 bits.
 */
+#if defined(_M_I86)
+/* Hardcoded due to bugs in some 16-bit compilers */
+#define LUAI_IS32INT 0
+#else
 #define LUAI_IS32INT	((UINT_MAX >> 30) >= 3)
+#endif
 
 /* }================================================================== */
 
@@ -231,7 +236,10 @@
 #define LUA_PATH_DEFAULT  \
 		LUA_LDIR"?.lua;"  LUA_LDIR"?/init.lua;" \
 		LUA_CDIR"?.lua;"  LUA_CDIR"?/init.lua;" \
-		"./?.lua;" "./?/init.lua"
+		"./?.lua;" "./?/init.lua" \
+		LUA_LDIR"?.LUA;"  LUA_LDIR"?/init.LUA;" \
+		LUA_CDIR"?.LUA;"  LUA_CDIR"?/init.LUA;" \
+		"./?.LUA;" "./?/init.LUA"
 #endif
 
 #if !defined(LUA_CPATH_DEFAULT)
--- lua/lutf8lib.c
+++ lua/lutf8lib.c
@@ -31,7 +31,9 @@
 /*
 ** Integer type for decoded UTF-8 values; MAXUTF needs 31 bits.
 */
-#if (UINT_MAX >> 30) >= 1
+#if defined(_M_I86)
+typedef unsigned long utfint;
+#elif (UINT_MAX >> 30) >= 1
 typedef unsigned int utfint;
 #else
 typedef unsigned long utfint;
