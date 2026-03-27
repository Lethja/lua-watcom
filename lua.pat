--- lua/lauxlib.c
+++ lua/lauxlib.c
@@ -1046,7 +1046,10 @@ LUALIB_API const char *luaL_gsub (lua_State *L, const char *s,
 }
 
 
-void *luaL_alloc (void *ud, void *ptr, size_t osize, size_t nsize) {
+LUALIB_API LUA_HEAP_PTR_T *luaL_alloc (void *ud,
+                                       LUA_HEAP_PTR_T *ptr,
+                                       LUA_HEAP_SIZE_T osize,
+                                       LUA_HEAP_SIZE_T nsize) {
   UNUSED(ud); UNUSED(osize);
   if (nsize == 0) {
     free(ptr);

--- lua/lauxlib.h
+++ lua/lauxlib.h
@@ -81,8 +81,9 @@ LUALIB_API int (luaL_checkoption) (lua_State *L, int arg, const char *def,
 LUALIB_API int (luaL_fileresult) (lua_State *L, int stat, const char *fname);
 LUALIB_API int (luaL_execresult) (lua_State *L, int stat);
 
-LUALIB_API void *luaL_alloc (void *ud, void *ptr, size_t osize,
-                                                  size_t nsize);
+LUALIB_API LUA_HEAP_PTR_T *luaL_alloc (void *ud, LUA_HEAP_PTR_T *ptr,
+                                                 LUA_HEAP_SIZE_T osize,
+                                                 LUA_HEAP_SIZE_T nsize);
 
 
 /* predefined references */
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
--- lua/loslib.c
+++ lua/loslib.c
@@ -134,6 +134,57 @@
 #if defined(LUA_USE_IOS)
 /* Despite claiming to be ISO C, iOS does not implement 'system'. */
 #define l_system(cmd) ((cmd) == NULL ? 0 : -1)
+
+/* DOS interrupt version of 'system' to avoid clib bloat */
+#elif defined(_M_I86) && defined(_DOS)
+
+#include <dos.h>
+
+typedef struct ExecParamRec {
+  unsigned short int envseg; /* Segment address of environment block */
+  char far *cmdline;         /* Pointer to command line string (ES:BX) */
+  unsigned short int fcb1;   /* Reserved */
+  unsigned short int fcb2;
+} ExecParamRec;
+
+static int l_system(const char *str) {
+  size_t l;
+  char *p, command[128];
+  union REGS regs;
+  struct SREGS sregs;
+  ExecParamRec exec;
+
+  if (!str || (l = 4 + strlen(str)) > 127) /* Maximum cmdline under DOS */
+    return -1;
+
+  if (!(p = getenv("COMSPEC")))
+    p = "COMMAND.COM";
+
+/* Copy Lua string onto command.com */
+  command[0] = (unsigned char) l;
+  memcpy(&command[1], " /C ", 4);
+  memcpy(&command[5], str, strlen(str));
+  command[l + 1] = '\r';
+
+/* Clear registers and structures */
+  memset(&exec, 0, sizeof(ExecParamRec)), memset(&regs, 0, sizeof(union REGS)), memset(&sregs, 0, sizeof(struct SREGS));
+  exec.cmdline = command;
+
+  regs.x.ax = 0x4b00;            /* Exec + load */
+  regs.x.dx = FP_OFF(p);         /* Offset of the command path string (DS:DX) */
+  sregs.ds = FP_SEG(p);          /* Segment of the command path string (DS:DX) */
+  regs.x.bx = FP_OFF(&exec);     /* Offset of the ExecParamRec structure (ES:BX) */
+  sregs.es = FP_SEG(&exec);      /* Segment of the ExecParamRec structure (ES:BX) */
+  intdosx(&regs, &regs, &sregs); /* 0x21 Send it! */
+
+  if (regs.x.cflag)
+    return -1;
+
+  regs.x.ax = 0x4D00;
+  intdos(&regs, &regs);
+  return regs.x.ax & 0xFF;
+}
+
 #else
 #define l_system(cmd)	system(cmd)  /* default definition */
 #endif

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
@@ -739,7 +770,18 @@
 ** without modifying the main part of the file.
 */
 
+/*
+** Definitions for unusual types and keywords such as _huge void
+** If not defined by this point then fallback to using Luas defaults
+*/
 
+#ifndef LUA_HEAP_PTR_T
+#define LUA_HEAP_PTR_T void
+#endif
+
+#ifndef LUA_HEAP_SIZE_T
+#define LUA_HEAP_SIZE_T size_t
+#endif
 
 #endif
 
