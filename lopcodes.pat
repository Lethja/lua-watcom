--- lopcodes.h
+++ lopcodes.h
@@ -65,8 +65,10 @@ enum OpMode {iABC, iABx, iAsBx, iAx, isJ};  /* basic instruction formats */
 */
 
 /* Check whether type 'int' has at least 'b' bits ('b' < 32) */
+/*
+ * TODO: Find a way to determine int size that Watcom respects...
 #define L_INTHASBITS(b)		((UINT_MAX >> ((b) - 1)) >= 1)
-
+*/
 
 #if L_INTHASBITS(SIZE_Bx)
 #define MAXARG_Bx	((1<<SIZE_Bx)-1)
