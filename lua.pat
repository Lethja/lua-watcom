--- lua/lopcodes.h
+++ lua/lopcodes.h
@@ -78,8 +78,9 @@ enum OpMode {iABC, ivABC, iABx, iAsBx, iAx, isJ};
 */
 #define L_INTHASBITS(b)		((UINT_MAX >> (b)) >= 1)
 
-
-#if L_INTHASBITS(SIZE_Bx)
+#if defined(_M_I86)
+#define MAXARG_Bx	INT_MAX
+#elif L_INTHASBITS(SIZE_Bx)
 #define MAXARG_Bx	((1<<SIZE_Bx)-1)
 #else
 #define MAXARG_Bx	INT_MAX
@@ -88,13 +89,17 @@ enum OpMode {iABC, ivABC, iABx, iAsBx, iAx, isJ};
 #define OFFSET_sBx	(MAXARG_Bx>>1)         /* 'sBx' is signed */
 
 
-#if L_INTHASBITS(SIZE_Ax)
+#if defined(_M_I86)
+#define MAXARG_Ax	INT_MAX
+#elif L_INTHASBITS(SIZE_Ax)
 #define MAXARG_Ax	((1<<SIZE_Ax)-1)
 #else
 #define MAXARG_Ax	INT_MAX
 #endif
 
-#if L_INTHASBITS(SIZE_sJ)
+#if defined(_M_I86)
+#define MAXARG_sJ	INT_MAX
+#elif L_INTHASBITS(SIZE_sJ)
 #define MAXARG_sJ	((1 << SIZE_sJ) - 1)
 #else
 #define MAXARG_sJ	INT_MAX
--- lua/luaconf.h
+++ lua/luaconf.h
@@ -95,7 +95,12 @@
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
 
@@ -237,17 +242,43 @@
 		LUA_CDIR"loadall.dll;" ".\\?.dll"
 #endif
 
+#elif defined(_DOS) || defined(__OS2__)
+/*
+** DOS and OS/2 do not have any mechanism to get the running process path.
+** Default to the current directory instead.
+*/
+
+#if !defined(LUA_PATH_DEFAULT)
+#define LUA_PATH_DEFAULT ".\\?.lua;" ".\\?\\init.lua"
+#endif
+
+#if !defined(LUA_CPATH_DEFAULT)
+#define LUA_CPATH_DEFAULT ".\\?.dll"
+#endif
+
 #else			/* }{ */
 
+/*
+** For Linux and (hopefully) compatible with other Unix-like systems
+*/
+
 #define LUA_ROOT	"/usr/local/"
 #define LUA_LDIR	LUA_ROOT "share/lua/" LUA_VDIR "/"
 #define LUA_CDIR	LUA_ROOT "lib/lua/" LUA_VDIR "/"
 
 #if !defined(LUA_PATH_DEFAULT)
+/*
+ * Linux is notorious for case-sensitive filenames.
+ * Check for .LUA in addition to .lua
+ * in case scripts are on a mount that uppercased the all filenames.
+ */
 #define LUA_PATH_DEFAULT  \
 		LUA_LDIR"?.lua;"  LUA_LDIR"?/init.lua;" \
 		LUA_CDIR"?.lua;"  LUA_CDIR"?/init.lua;" \
-		"./?.lua;" "./?/init.lua"
+		"./?.lua;" "./?/init.lua" \
+		LUA_LDIR"?.LUA;"  LUA_LDIR"?/INIT.LUA;" \
+		LUA_CDIR"?.LUA;"  LUA_CDIR"?/INIT.LUA;" \
+		"./?.LUA;" "./?/INIT.LUA"
 #endif
 
 #if !defined(LUA_CPATH_DEFAULT)
@@ -265,7 +296,7 @@
 */
 #if !defined(LUA_DIRSEP)
 
-#if defined(_WIN32)
+#if defined(_WIN32) || defined(_DOS) || defined(__OS2__)
 #define LUA_DIRSEP	"\\"
 #else
 #define LUA_DIRSEP	"/"
