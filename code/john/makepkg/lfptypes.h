// **************************************************************************
// **************************************************************************
// **                                                                      **
// ** LFPTYPES.H                                                    MODULE **
// **                                                                      **
// ** General type definitions.                                            **
// **                                                                      **
// **************************************************************************
// **************************************************************************

#ifndef __LFPTYPES_H
#define __LFPTYPES_H

//
// DETERMINE TARGET MACHINE BYTE ORDERING ...
//
// either BYTE_ORDER_LO_HI for 80x86 ordering,
// or     BYTE_ORDER_HI_LO for 680x0 ordering.
//

#ifdef PC
 #define BYTE_ORDER_LO_HI    1
 #define BYTE_ORDER_HI_LO    0
#endif

#ifdef PSX
 #define BYTE_ORDER_LO_HI    1
 #define BYTE_ORDER_HI_LO    0
#endif

#ifdef SATURN
 #define BYTE_ORDER_LO_HI    0
 #define BYTE_ORDER_HI_LO    1
#endif

#ifdef THREEDO
 #define BYTE_ORDER_LO_HI    0
 #define BYTE_ORDER_HI_LO    1
#endif

#ifdef SFX
 #define BYTE_ORDER_LO_HI    1
 #define BYTE_ORDER_HI_LO    0
#endif

#ifdef GENESIS
 #define BYTE_ORDER_LO_HI    0
 #define BYTE_ORDER_HI_LO    1
#endif

//
// NAMING CONVENTION FOR VARIABLES
//
//
// 1) Each variable name is preceeded by a character string which shows what type of data
//    that variable is supposed to contain.
//
//    If less than 4 characters are needed to signify the type of data contained, then the
//    string is padded out to 4 characters with the '_' underscore character.
//
//    An extra '_' character is then added to seperate the typing information from the
//    variable's name.
//
// 2) The first 2 characters contain the basic type of the data that the variable contains
//    or points to.
//
//    The basic types are ...
//
//    Short  Long               Source  Contents
//
//    uc     unsigned char      C       8 bits
//    sc     signed char        C       8 bits
//    us     unsigned short     C       16 bits
//    ss     signed short       C       16 bits
//    ui     unsigned int       C       32 bits
//    si     signed int         C       32 bits
//    ul     unsigned long      C       32 or 64 bits
//    sl     signed long        C       32 or 64 bits
//
//    ub     unsigned byte      ASM     8 bits
//    sb     signed byte        ASM     8 bits
//    uw     unsigned word      ASM     16 bits
//    sw     signed word        ASM     16 bits
//    ud     unsigned double    ASM     32 bits
//    sd     signed double      ASM     32 bits
//    uq     unsigned quad      ASM     64 bits
//    sq     signed quad        ASM     64 bits
//
//    fl     boolean flag       -       1 bit, storage size is hardware dependant
//
//    bf     buffer             -       an area of memory (with undefined contents)
//    cl     class/structure    -       an area of memory (containing a structure)
//    un     union              -       an area of memory (containing a union)
//
//    cz     ASCIIZ string      -       a pointer to a character array
//    fn     function           -       a pointer to a function
//
// 3) The remaining characters specify whether any indirection in getting to that basic data
//    type, i.e. is the variable a pointer, or an array, or a pointer to a pointer, or a
//    pointer to an array, etc.
//
//    The types of indirection are ...
//
//    a      array              a pointer to many objects of the basic type
//    p      pointer            a pointer to one object of the basic type
//
// 4) The structure of the variable's name itself gives further clues to its function.
//
//    all lowercase             local variable
//    1st chr lowercase         structure member
//    1st chr uppercase         global
//

//
// Shortcut names for the standard C Types
//

#define FL   signed char
#define UC unsigned char
#define SC   signed char
#define US unsigned short
#define SS   signed short
#define UI unsigned int
#define SI   signed int
#define UL unsigned long
#define SL   signed long

//
// Shortcut names for ASM Types
//

#ifdef PC
 #define UB unsigned char
 #define SB   signed char
 #define UW unsigned short
 #define SW   signed short
 #define UD unsigned int
 #define SD   signed int
#endif

#ifdef PSX
 #define UB unsigned char
 #define SB   signed char
 #define UW unsigned short
 #define SW   signed short
 #define UD unsigned int
 #define SD   signed int
#endif

#ifdef SATURN
 #define UB Uint8
 #define SB Sint8
 #define UW Uint16
 #define SW Sint16
 #define UD Uint32
 #define SD Sint32
#endif

#ifdef THREEDO
 #define UB unsigned char
 #define SB   signed char
 #define UW uint16
 #define SW  int16
 #define UD uint32
 #define SD  int32
#endif

//
// Boolean Types
//

#ifdef PC
 typedef UB      Boolean;
 #define bool    Boolean
 #define FALSE   ((Boolean) 0)
 #define TRUE    ((Boolean) 1)
 #define OFF     ((Boolean) 0)
 #define ON      ((Boolean) 1)
#endif

#ifdef PSX
 typedef UB      Boolean;
 #define bool    Boolean
 #define FALSE   ((Boolean) 0)
 #define TRUE    ((Boolean) 1)
 #define OFF     ((Boolean) 0)
 #define ON      ((Boolean) 1)
#endif

#ifdef SATURN
 typedef UB      Boolean;
 #define bool    Boolean
#endif

#ifdef THREEDO
#endif

//
//
//

typedef union AnyPtrU
	{
	void * bfp;
	char * czp;
	UC *   ucp;
	US *   usp;
	UI *   uip;
	UL *   ulp;
	SC *   scp;
	SS *   ssp;
	SI *   sip;
	SL *   slp;
	UB *   ubp;
	UW *   uwp;
	UD *   udp;
	SB *   sbp;
	SW *   swp;
	UD *   sdp;
	} AnyPtrT;

//
// Define 'global' as a complement to 'static' declarations.
//

#define global

//
//
//

extern	char                aub__gError [256];

//
// Debugging Macros (PC)
//

#ifdef PC
 #if DEBUG
  #define DebugCode()
  #define DIAGNOSE(xx)			{ printf(xx);       }
  #define DIAGNOSE2(xx,yy)		{ printf(xx,yy);    }
  #define DIAGNOSE3(xx,yy,zz)	{ printf(xx,yy,zz); }
 #else
  #define DebugCode()
  #if 0
   #define DIAGNOSE(xx)
   #define DIAGNOSE2(xx,yy)
   #define DIAGNOSE3(xx,yy,zz)
  #else
   #define DIAGNOSE(xx)			{ printf(xx);       }
   #define DIAGNOSE2(xx,yy)		{ printf(xx,yy);    }
   #define DIAGNOSE3(xx,yy,zz)	{ printf(xx,yy,zz); }
  #endif
 #endif
#endif

//
// Debugging Macros (PSX)
//

#ifdef PSX
 #if DEBUG
  #define DebugCode()			asm("break 0")
  #define DIAGNOSE(xx)			{ printf(xx);       }
  #define DIAGNOSE2(xx,yy)		{ printf(xx,yy);    }
  #define DIAGNOSE3(xx,yy,zz)	{ printf(xx,yy,zz); }
 #else
  #define DebugCode()
  #if 0
   #define DIAGNOSE(xx)
   #define DIAGNOSE2(xx,yy)
   #define DIAGNOSE3(xx,yy,zz)
  #else
   extern  void                 FatalMessage(void);
   #define DIAGNOSE(xx)			{ sprintf(aub__gError,xx);       FatalMessage(); }
   #define DIAGNOSE2(xx,yy)		{ sprintf(aub__gError,xx,yy);    FatalMessage(); }
   #define DIAGNOSE3(xx,yy,zz)	{ sprintf(aub__gError,xx,yy,zz); FatalMessage(); }
  #endif
 #endif
#endif

//
// Debugging Macros (SATURN)
//

#ifdef SATURN
 #if DEBUG
  #define DebugCode()			asm("trapa #34")
  #define DIAGNOSE(xx)			{ sprintf(aub__gError,xx);       PCwrite(-1,aub__gError,strlen(aub__gError)); }
  #define DIAGNOSE2(xx,yy)		{ sprintf(aub__gError,xx,yy);    PCwrite(-1,aub__gError,strlen(aub__gError)); }
  #define DIAGNOSE3(xx,yy,zz)	{ sprintf(aub__gError,xx,yy,zz); PCwrite(-1,aub__gError,strlen(aub__gError)); }
 #else
  #define DebugCode()
  #if 0
   #define DIAGNOSE(x)
   #define DIAGNOSE2(xx,yy)
   #define DIAGNOSE3(xx,yy,zz)
  #else
   extern  void                 FatalMessage(void);
   #define DIAGNOSE(xx)			{ sprintf(aub__gError,xx);       FatalMessage(); }
   #define DIAGNOSE2(xx,yy)		{ sprintf(aub__gError,xx,yy);    FatalMessage(); }
   #define DIAGNOSE3(xx,yy,zz)	{ sprintf(aub__gError,xx,yy,zz); FatalMessage(); }
  #endif
 #endif
#endif

//
// Debugging Macros (3DO)
//

#ifdef THREEDO
 #define DebugCode()
 #define DIAGNOSE(x)
#endif

//
// Interrupt Control Macros.
//
// Unlike the library routines, these preserve/restore the original irq
// setting into a local variable, and so can safely be called in a nested
// fashion without prematurely reenabling interrupts. This does mean that
// an xei() **MUST** be paired with an earlier xdi() in the same routine.
//

#ifdef PC
 #define xdi(localvar)
 #define xei(localvar)
#endif

#ifdef PSX
 #define xdi(localvar) {__asm__ volatile ("mfc0 %0,$12; addiu $2,$0,-0x402; and $2,$2,%0; mtc0 $2,$12; nop" : "=r" (localvar) : "0" (localvar) : "$2", "cc"); }
 #define xei(localvar) {__asm__ volatile ("mtc0 %0,$12; nop" :: "r" (localvar) : "cc"); }
#endif

#ifdef SATURN
 #define xdi(localvar) {__asm__ volatile ("stc sr,%0; mov #60,r0; shll2 r0; or %0,r0; ldc r0,sr" : "=r" (localvar) : "0" (localvar) : "r0", "cc"); }
 #define xei(localvar) {__asm__ volatile ("ldc %0,sr" :: "r" (localvar) : "cc"); }
 #define di() {__asm__ volatile ("stc sr,r1; mov #60,r0; shll2 r0; or r1,r0; ldc r0,sr" ::: "r0", "r1", "cc"); }
 #define ei() {__asm__ volatile ("stc sr,r1; mov #60,r0; shll2 r0; not r0,r0; and r1,r0; ldc r0,sr" ::: "r0", "r1", "cc"); }
#endif

//
// End Of __LFPTYPES_H
//

#endif