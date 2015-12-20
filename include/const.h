/* const.h: Macros for dealing with constants.  */

#ifndef _CONST_H
#define _CONST_H

#define _AC(X,Y)	X
#define _AT(T,X)	X

#define _BITUL(x)	(_AC(1,UL) << (x))
#define _BITULL(x)	(_AC(1,ULL) << (x))

#endif /* !(_CONST_H) */
