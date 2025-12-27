--- luac/luac.c
+++ luac/luac.c
@@ -1,5 +1,5 @@
 /*
-** $Id: luac.c,v 1.74 2015/03/12 01:53:53 lhf Exp lhf $
+** $Id: luac.c $
 ** Lua compiler (saves bytecodes to files; also lists bytecodes)
 ** See Copyright Notice in lua.h
 */
@@ -18,7 +18,11 @@
 #include "lua.h"
 #include "lauxlib.h"
 
+#include "lapi.h"
+#include "ldebug.h"
 #include "lobject.h"
+#include "lopcodes.h"
+#include "lopnames.h"
 #include "lstate.h"
 #include "lundump.h"
 
@@ -34,6 +38,7 @@
 static char Output[]={ OUTPUT };	/* default output file name */
 static const char* output=Output;	/* actual output file name */
 static const char* progname=PROGNAME;	/* actual program name */
+static TString **tmname;
 
 static void fatal(const char* message)
 {
@@ -117,9 +122,9 @@
  return i;
 }
 
-#define FUNCTION "(function()end)();"
+#define FUNCTION "(function()end)();\n"
 
-static const char* reader(lua_State *L, void *ud, size_t *size)
+static const char* reader(lua_State* L, void* ud, size_t* size)
 {
  UNUSED(L);
  if ((*(int*)ud)--)
@@ -134,7 +139,7 @@
  }
 }
 
-#define toproto(L,i) getproto(L->top+(i))
+#define toproto(L,i) getproto(s2v(L->top.p+(i)))
 
 static const Proto* combine(lua_State* L, int n)
 {
@@ -151,7 +156,6 @@
    f->p[i]=toproto(L,i-n-1);
    if (f->p[i]->sizeupvalues>0) f->p[i]->upvalues[0].instack=0;
   }
-  f->sizelineinfo=0;
   return f;
  }
 }
@@ -168,6 +172,7 @@
  char** argv=(char**)lua_touserdata(L,2);
  const Proto* f;
  int i;
+ tmname=G(L)->tmname;
  if (!lua_checkstack(L,argc)) fatal("too many input files");
  for (i=0; i<argc; i++)
  {
@@ -206,63 +211,102 @@
 }
 
 /*
-** $Id: luac.c,v 1.74 2015/03/12 01:53:53 lhf Exp lhf $
 ** print bytecodes
-** See Copyright Notice in lua.h
 */
 
-#include <ctype.h>
-#include <stdio.h>
-
-#define luac_c
-#define LUA_CORE
-
-#include "ldebug.h"
-#include "lobject.h"
-#include "lopcodes.h"
-
-#define VOID(p)		((const void*)(p))
+#define UPVALNAME(x) ((f->upvalues[x].name) ? getstr(f->upvalues[x].name) : "-")
+#define VOID(p) ((const void*)(p))
+#define eventname(i) (getstr(tmname[i]))
 
 static void PrintString(const TString* ts)
 {
  const char* s=getstr(ts);
  size_t i,n=tsslen(ts);
- printf("%c",'"');
+ printf("\"");
  for (i=0; i<n; i++)
  {
   int c=(int)(unsigned char)s[i];
   switch (c)
   {
-   case '"':  printf("\\\""); break;
-   case '\\': printf("\\\\"); break;
-   case '\a': printf("\\a"); break;
-   case '\b': printf("\\b"); break;
-   case '\f': printf("\\f"); break;
-   case '\n': printf("\\n"); break;
-   case '\r': printf("\\r"); break;
-   case '\t': printf("\\t"); break;
-   case '\v': printf("\\v"); break;
-   default:	if (isprint(c))
-   			printf("%c",c);
-		else
-			printf("\\%03d",c);
+   case '"':
+	printf("\\\"");
+	break;
+   case '\\':
+	printf("\\\\");
+	break;
+   case '\a':
+	printf("\\a");
+	break;
+   case '\b':
+	printf("\\b");
+	break;
+   case '\f':
+	printf("\\f");
+	break;
+   case '\n':
+	printf("\\n");
+	break;
+   case '\r':
+	printf("\\r");
+	break;
+   case '\t':
+	printf("\\t");
+	break;
+   case '\v':
+	printf("\\v");
+	break;
+   default:
+	if (isprint(c)) printf("%c",c); else printf("\\%03d",c);
+	break;
   }
  }
- printf("%c",'"');
+ printf("\"");
+}
+
+static void PrintType(const Proto* f, int i)
+{
+ const TValue* o=&f->k[i];
+ switch (ttypetag(o))
+ {
+  case LUA_VNIL:
+	printf("N");
+	break;
+  case LUA_VFALSE:
+  case LUA_VTRUE:
+	printf("B");
+	break;
+  case LUA_VNUMFLT:
+	printf("F");
+	break;
+  case LUA_VNUMINT:
+	printf("I");
+	break;
+  case LUA_VSHRSTR:
+  case LUA_VLNGSTR:
+	printf("S");
+	break;
+  default:				/* cannot happen */
+	printf("?%d",ttypetag(o));
+	break;
+ }
+ printf("\t");
 }
 
 static void PrintConstant(const Proto* f, int i)
 {
  const TValue* o=&f->k[i];
- switch (ttype(o))
+ switch (ttypetag(o))
  {
-  case LUA_TNIL:
+  case LUA_VNIL:
 	printf("nil");
 	break;
-  case LUA_TBOOLEAN:
-	printf(bvalue(o) ? "true" : "false");
+  case LUA_VFALSE:
+	printf("false");
+	break;
+  case LUA_VTRUE:
+	printf("true");
 	break;
-  case LUA_TNUMFLT:
+  case LUA_VNUMFLT:
 	{
 	char buff[100];
 	sprintf(buff,LUA_NUMBER_FMT,fltvalue(o));
@@ -270,20 +314,23 @@
 	if (buff[strspn(buff,"-0123456789")]=='\0') printf(".0");
 	break;
 	}
-  case LUA_TNUMINT:
+  case LUA_VNUMINT:
 	printf(LUA_INTEGER_FMT,ivalue(o));
 	break;
-  case LUA_TSHRSTR: case LUA_TLNGSTR:
+  case LUA_VSHRSTR:
+  case LUA_VLNGSTR:
 	PrintString(tsvalue(o));
 	break;
   default:				/* cannot happen */
-	printf("? type=%d",ttype(o));
+	printf("?%d",ttypetag(o));
 	break;
  }
 }
 
-#define UPVALNAME(x) ((f->upvalues[x].name) ? getstr(f->upvalues[x].name) : "-")
-#define MYK(x)		(-1-(x))
+#define COMMENT		"\t; "
+#define EXTRAARG	GETARG_Ax(code[pc+1])
+#define EXTRAARGC	(EXTRAARG*(MAXARG_C+1))
+#define ISK		(isk ? "k" : "")
 
 static void PrintCode(const Proto* f)
 {
@@ -298,92 +345,328 @@
   int c=GETARG_C(i);
   int ax=GETARG_Ax(i);
   int bx=GETARG_Bx(i);
+  int sb=GETARG_sB(i);
+  int sc=GETARG_sC(i);
+  int vb=GETARG_vB(i);
+  int vc=GETARG_vC(i);
   int sbx=GETARG_sBx(i);
-  int line=getfuncline(f,pc);
+  int isk=GETARG_k(i);
+  int line=luaG_getfuncline(f,pc);
   printf("\t%d\t",pc+1);
   if (line>0) printf("[%d]\t",line); else printf("[-]\t");
-  printf("%-9s\t",luaP_opnames[o]);
-  switch (getOpMode(o))
-  {
-   case iABC:
-    printf("%d",a);
-    if (getBMode(o)!=OpArgN) printf(" %d",ISK(b) ? (MYK(INDEXK(b))) : b);
-    if (getCMode(o)!=OpArgN) printf(" %d",ISK(c) ? (MYK(INDEXK(c))) : c);
-    break;
-   case iABx:
-    printf("%d",a);
-    if (getBMode(o)==OpArgK) printf(" %d",MYK(bx));
-    if (getBMode(o)==OpArgU) printf(" %d",bx);
-    break;
-   case iAsBx:
-    printf("%d %d",a,sbx);
-    break;
-   case iAx:
-    printf("%d",MYK(ax));
-    break;
-  }
+  printf("%-9s\t",opnames[o]);
   switch (o)
   {
+   case OP_MOVE:
+	printf("%d %d",a,b);
+	break;
+   case OP_LOADI:
+	printf("%d %d",a,sbx);
+	break;
+   case OP_LOADF:
+	printf("%d %d",a,sbx);
+	break;
    case OP_LOADK:
-    printf("\t; "); PrintConstant(f,bx);
-    break;
+	printf("%d %d",a,bx);
+	printf(COMMENT); PrintConstant(f,bx);
+	break;
+   case OP_LOADKX:
+	printf("%d",a);
+	printf(COMMENT); PrintConstant(f,EXTRAARG);
+	break;
+   case OP_LOADFALSE:
+	printf("%d",a);
+	break;
+   case OP_LFALSESKIP:
+	printf("%d",a);
+	break;
+   case OP_LOADTRUE:
+	printf("%d",a);
+	break;
+   case OP_LOADNIL:
+	printf("%d %d",a,b);
+	printf(COMMENT "%d out",b+1);
+	break;
    case OP_GETUPVAL:
+	printf("%d %d",a,b);
+	printf(COMMENT "%s",UPVALNAME(b));
+	break;
    case OP_SETUPVAL:
-    printf("\t; %s",UPVALNAME(b));
-    break;
+	printf("%d %d",a,b);
+	printf(COMMENT "%s",UPVALNAME(b));
+	break;
    case OP_GETTABUP:
-    printf("\t; %s",UPVALNAME(b));
-    if (ISK(c)) { printf(" "); PrintConstant(f,INDEXK(c)); }
-    break;
-   case OP_SETTABUP:
-    printf("\t; %s",UPVALNAME(a));
-    if (ISK(b)) { printf(" "); PrintConstant(f,INDEXK(b)); }
-    if (ISK(c)) { printf(" "); PrintConstant(f,INDEXK(c)); }
-    break;
+	printf("%d %d %d",a,b,c);
+	printf(COMMENT "%s",UPVALNAME(b));
+	printf(" "); PrintConstant(f,c);
+	break;
    case OP_GETTABLE:
-   case OP_SELF:
-    if (ISK(c)) { printf("\t; "); PrintConstant(f,INDEXK(c)); }
-    break;
+	printf("%d %d %d",a,b,c);
+	break;
+   case OP_GETI:
+	printf("%d %d %d",a,b,c);
+	break;
+   case OP_GETFIELD:
+	printf("%d %d %d",a,b,c);
+	printf(COMMENT); PrintConstant(f,c);
+	break;
+   case OP_SETTABUP:
+	printf("%d %d %d%s",a,b,c,ISK);
+	printf(COMMENT "%s",UPVALNAME(a));
+	printf(" "); PrintConstant(f,b);
+	if (isk) { printf(" "); PrintConstant(f,c); }
+	break;
    case OP_SETTABLE:
+	printf("%d %d %d%s",a,b,c,ISK);
+	if (isk) { printf(COMMENT); PrintConstant(f,c); }
+	break;
+   case OP_SETI:
+	printf("%d %d %d%s",a,b,c,ISK);
+	if (isk) { printf(COMMENT); PrintConstant(f,c); }
+	break;
+   case OP_SETFIELD:
+	printf("%d %d %d%s",a,b,c,ISK);
+	printf(COMMENT); PrintConstant(f,b);
+	if (isk) { printf(" "); PrintConstant(f,c); }
+	break;
+   case OP_NEWTABLE:
+	printf("%d %d %d%s",a,vb,vc,ISK);
+	printf(COMMENT "%d",vc+EXTRAARGC);
+	break;
+   case OP_SELF:
+	printf("%d %d %d%s",a,b,c,ISK);
+	if (isk) { printf(COMMENT); PrintConstant(f,c); }
+	break;
+   case OP_ADDI:
+	printf("%d %d %d",a,b,sc);
+	break;
+   case OP_ADDK:
+	printf("%d %d %d",a,b,c);
+	printf(COMMENT); PrintConstant(f,c);
+	break;
+   case OP_SUBK:
+	printf("%d %d %d",a,b,c);
+	printf(COMMENT); PrintConstant(f,c);
+	break;
+   case OP_MULK:
+	printf("%d %d %d",a,b,c);
+	printf(COMMENT); PrintConstant(f,c);
+	break;
+   case OP_MODK:
+	printf("%d %d %d",a,b,c);
+	printf(COMMENT); PrintConstant(f,c);
+	break;
+   case OP_POWK:
+	printf("%d %d %d",a,b,c);
+	printf(COMMENT); PrintConstant(f,c);
+	break;
+   case OP_DIVK:
+	printf("%d %d %d",a,b,c);
+	printf(COMMENT); PrintConstant(f,c);
+	break;
+   case OP_IDIVK:
+	printf("%d %d %d",a,b,c);
+	printf(COMMENT); PrintConstant(f,c);
+	break;
+   case OP_BANDK:
+	printf("%d %d %d",a,b,c);
+	printf(COMMENT); PrintConstant(f,c);
+	break;
+   case OP_BORK:
+	printf("%d %d %d",a,b,c);
+	printf(COMMENT); PrintConstant(f,c);
+	break;
+   case OP_BXORK:
+	printf("%d %d %d",a,b,c);
+	printf(COMMENT); PrintConstant(f,c);
+	break;
+   case OP_SHLI:
+	printf("%d %d %d",a,b,sc);
+	break;
+   case OP_SHRI:
+	printf("%d %d %d",a,b,sc);
+	break;
    case OP_ADD:
+	printf("%d %d %d",a,b,c);
+	break;
    case OP_SUB:
+	printf("%d %d %d",a,b,c);
+	break;
    case OP_MUL:
+	printf("%d %d %d",a,b,c);
+	break;
+   case OP_MOD:
+	printf("%d %d %d",a,b,c);
+	break;
    case OP_POW:
+	printf("%d %d %d",a,b,c);
+	break;
    case OP_DIV:
+	printf("%d %d %d",a,b,c);
+	break;
    case OP_IDIV:
+	printf("%d %d %d",a,b,c);
+	break;
    case OP_BAND:
+	printf("%d %d %d",a,b,c);
+	break;
    case OP_BOR:
+	printf("%d %d %d",a,b,c);
+	break;
    case OP_BXOR:
+	printf("%d %d %d",a,b,c);
+	break;
    case OP_SHL:
+	printf("%d %d %d",a,b,c);
+	break;
    case OP_SHR:
+	printf("%d %d %d",a,b,c);
+	break;
+   case OP_MMBIN:
+	printf("%d %d %d",a,b,c);
+	printf(COMMENT "%s",eventname(c));
+	break;
+   case OP_MMBINI:
+	printf("%d %d %d %d",a,sb,c,isk);
+	printf(COMMENT "%s",eventname(c));
+	if (isk) printf(" flip");
+	break;
+   case OP_MMBINK:
+	printf("%d %d %d %d",a,b,c,isk);
+	printf(COMMENT "%s ",eventname(c)); PrintConstant(f,b);
+	if (isk) printf(" flip");
+	break;
+   case OP_UNM:
+	printf("%d %d",a,b);
+	break;
+   case OP_BNOT:
+	printf("%d %d",a,b);
+	break;
+   case OP_NOT:
+	printf("%d %d",a,b);
+	break;
+   case OP_LEN:
+	printf("%d %d",a,b);
+	break;
+   case OP_CONCAT:
+	printf("%d %d",a,b);
+	break;
+   case OP_CLOSE:
+	printf("%d",a);
+	break;
+   case OP_TBC:
+	printf("%d",a);
+	break;
+   case OP_JMP:
+	printf("%d",GETARG_sJ(i));
+	printf(COMMENT "to %d",GETARG_sJ(i)+pc+2);
+	break;
    case OP_EQ:
+	printf("%d %d %d",a,b,isk);
+	break;
    case OP_LT:
+	printf("%d %d %d",a,b,isk);
+	break;
    case OP_LE:
-    if (ISK(b) || ISK(c))
-    {
-     printf("\t; ");
-     if (ISK(b)) PrintConstant(f,INDEXK(b)); else printf("-");
-     printf(" ");
-     if (ISK(c)) PrintConstant(f,INDEXK(c)); else printf("-");
-    }
-    break;
-   case OP_JMP:
+	printf("%d %d %d",a,b,isk);
+	break;
+   case OP_EQK:
+	printf("%d %d %d",a,b,isk);
+	printf(COMMENT); PrintConstant(f,b);
+	break;
+   case OP_EQI:
+	printf("%d %d %d",a,sb,isk);
+	break;
+   case OP_LTI:
+	printf("%d %d %d",a,sb,isk);
+	break;
+   case OP_LEI:
+	printf("%d %d %d",a,sb,isk);
+	break;
+   case OP_GTI:
+	printf("%d %d %d",a,sb,isk);
+	break;
+   case OP_GEI:
+	printf("%d %d %d",a,sb,isk);
+	break;
+   case OP_TEST:
+	printf("%d %d",a,isk);
+	break;
+   case OP_TESTSET:
+	printf("%d %d %d",a,b,isk);
+	break;
+   case OP_CALL:
+	printf("%d %d %d",a,b,c);
+	printf(COMMENT);
+	if (b==0) printf("all in "); else printf("%d in ",b-1);
+	if (c==0) printf("all out"); else printf("%d out",c-1);
+	break;
+   case OP_TAILCALL:
+	printf("%d %d %d%s",a,b,c,ISK);
+	printf(COMMENT "%d in",b-1);
+	break;
+   case OP_RETURN:
+	printf("%d %d %d%s",a,b,c,ISK);
+	printf(COMMENT);
+	if (b==0) printf("all out"); else printf("%d out",b-1);
+	break;
+   case OP_RETURN0:
+	break;
+   case OP_RETURN1:
+	printf("%d",a);
+	break;
    case OP_FORLOOP:
+	printf("%d %d",a,bx);
+	printf(COMMENT "to %d",pc-bx+2);
+	break;
    case OP_FORPREP:
+	printf("%d %d",a,bx);
+	printf(COMMENT "exit to %d",pc+bx+3);
+	break;
+   case OP_TFORPREP:
+	printf("%d %d",a,bx);
+	printf(COMMENT "to %d",pc+bx+2);
+	break;
+   case OP_TFORCALL:
+	printf("%d %d",a,c);
+	break;
    case OP_TFORLOOP:
-    printf("\t; to %d",sbx+pc+2);
-    break;
-   case OP_CLOSURE:
-    printf("\t; %p",VOID(f->p[bx]));
-    break;
+	printf("%d %d",a,bx);
+	printf(COMMENT "to %d",pc-bx+2);
+	break;
    case OP_SETLIST:
-    if (c==0) printf("\t; %d",(int)code[++pc]); else printf("\t; %d",c);
-    break;
+	printf("%d %d %d%s",a,vb,vc,ISK);
+	if (isk) printf(COMMENT "%d",c+EXTRAARGC);
+	break;
+   case OP_CLOSURE:
+	printf("%d %d",a,bx);
+	printf(COMMENT "%p",VOID(f->p[bx]));
+	break;
+   case OP_VARARG:
+	printf("%d %d %d%s",a,b,c,ISK);
+	printf(COMMENT);
+	if (c==0) printf("all out"); else printf("%d out",c-1);
+	break;
+   case OP_GETVARG:
+	printf("%d %d %d",a,b,c);
+	break;
+   case OP_ERRNNIL:
+	printf("%d %d",a,bx);
+	printf(COMMENT);
+	if (bx==0) printf("?"); else PrintConstant(f,bx-1);
+	break;
+   case OP_VARARGPREP:
+	printf("%d",a);
+	break;
    case OP_EXTRAARG:
-    printf("\t; "); PrintConstant(f,ax);
-    break;
+	printf("%d",ax);
+	break;
+#if 0
    default:
-    break;
+	printf("%d %d %d",a,b,c);
+	printf(COMMENT "not handled");
+	break;
+#endif
   }
   printf("\n");
  }
@@ -402,11 +685,11 @@
  else
   s="(string)";
  printf("\n%s <%s:%d,%d> (%d instruction%s at %p)\n",
- 	(f->linedefined==0)?"main":"function",s,
+	(f->linedefined==0)?"main":"function",s,
 	f->linedefined,f->lastlinedefined,
 	S(f->sizecode),VOID(f));
  printf("%d%s param%s, %d slot%s, %d upvalue%s, ",
-	(int)(f->numparams),f->is_vararg?"+":"",SS(f->numparams),
+	(int)(f->numparams),isvararg(f)?"+":"",SS(f->numparams),
 	S(f->maxstacksize),S(f->sizeupvalues));
  printf("%d local%s, %d constant%s, %d function%s\n",
 	S(f->sizelocvars),S(f->sizek),S(f->sizep));
@@ -419,7 +702,8 @@
  printf("constants (%d) for %p:\n",n,VOID(f));
  for (i=0; i<n; i++)
  {
-  printf("\t%d\t",i+1);
+  printf("\t%d\t",i);
+  PrintType(f,i);
   PrintConstant(f,i);
   printf("\n");
  }
