--- lutf8lib.c
+++ lutf8lib.c
@@ -31,12 +31,16 @@
 /*
 ** Integer type for decoded UTF-8 values; MAXUTF needs 31 bits.
 */
+/*
+ * TODO: Find a way to determine int size that Watcom respects...
 #if (UINT_MAX >> 30) >= 1
 typedef unsigned int utfint;
 #else
+*/
 typedef unsigned long utfint;
+/*
 #endif
-
+*/
 
 #define iscont(c)	(((c) & 0xC0) == 0x80)
 #define iscontp(p)	iscont(*(p))
