// **************************************************************************
// **************************************************************************
// **                                                                      **
// ** MEM.H                                                         MODULE **
// **                                                                      **
// ** Replacements for the standard ANSI C memory management functions.    **
// ** These functions have the optional advantage of providing debugging   **
// ** features for detecting errant pointers, memory overruns and memory   **
// ** underruns.                                                           **
// **                                                                      **
// ** Dependencies  :                                                      **
// **                                                                      **
// ** ELMER    .H                                                          **
// ** MEM      .H .C                                                       **
// **                                                                      **
// ** Last modified : 05 Dec 1994 by John Brandwood                        **
// **                                                                      **
// **************************************************************************
// **************************************************************************


#ifndef __MEM_h
#define __MEM_h

#ifndef __ELMER_h
 #include "ELMER.H"
#endif

//
// Control mem package functions ...
// 0 = OFF, 1 = ON.
//

#define	INCL_MEM_STATS      1
#define	INCL_MEM_SUSPICIOUS 0
#define	INCL_MEM_PARANOID   0

//
// Structures
//

typedef struct MEMHEAD_S
	{
	struct MEMHEAD_S *  pcl__mhNextBlock;		// Next block in list.
	struct MEMHEAD_S *  pcl__mhPrevBlock;		// Previous block in list.
	size_t              ul___mhBlockSize;		// Size allocated (incl header).
	#if INCL_MEM_SUSPICIOUS
	UI                  ui___mhMagic;			// Magic number.
	char *              pcz__mhFile;			// File where allocated.
	UI                  ui___mhLine;			// Line where allocated.
	#endif
	#if INCL_MEM_PARANOID
	UD                  ud___mhDataHead;		// Detect underruns.
	#endif
	} MEMHEAD_T;

typedef struct MEMLIST_S
	{
	struct MEMHEAD_S *  pcl__mlNextBlock;		// Next block (always NULL).
	struct MEMHEAD_S *  pcl__mlPrevBlock;		// Previous block.
	size_t              ul___mlBlockSize;		// Size allocated (always zero).
	UI                  ui___mlMagic;			// Magic number.
	char *              pcz__mlFile;			// File where allocated.
	UI                  ui___mlLine;			// Line where allocated.
	struct MEMLIST_S *  pcl__mlNextList;		// Link to next list header.
	struct MEMLIST_S *  pcl__mlPrevList;		// Link to previous list header.
	} MEMLIST_T;

typedef struct MEMTAIL_S
	{
	UD                  ud___mtDataTail;		// Detect overruns.
	} MEMTAIL_T;

#if INCL_MEM_PARANOID
	#define MEMTAIL_SIZE sizeof(MEMTAIL_T)
#else
	#define MEMTAIL_SIZE 0
#endif

//
// Public variables.
//

extern	SL                  sl___CurMemUsed;
extern	SL                  sl___MaxMemUsed;

//
// Interface routines, you may use these calls directly, or use the
// short calls #defined below to allow for different levels of
// debugging.
//

extern	SI                  MemInitPackage      (void);
extern	SI                  MemTermPackage      (void);

extern	MEMLIST_T *         MemCreateList_F     (char *, UI);
extern	SI                  MemKillList_F       (MEMLIST_T *, char *, UI);
extern	SI                  MemFreeList_F       (MEMLIST_T *, char *, UI);

extern	void *              MemAlloc_N          (size_t, UI);
extern	void *              MemAlloc_G          (size_t, UI);
extern	void *              MemAlloc_L          (size_t, UI, MEMLIST_T *);
extern	void *              MemAlloc_GF         (size_t, UI, char *, UI);
extern	void *              MemAlloc_LF         (size_t, UI, MEMLIST_T *, char *, UI);

extern	SI                  MemFree_N           (void *);
extern	SI                  MemFree_PF          (void *, char *, UI);

//
// Use different routines depending upon how much safety you
// want.
//

#define	MemCreateList()              MemCreateList_F(__FILE__,__LINE__)
#define	MemKillList(list)            MemKillList_F(list,__FILE__,__LINE__)
#define	MemFreeList(list)            MemFreeList_F(list,__FILE__,__LINE__)

// No debugging ...

#if MEM_DEBUG==0
	#define	MemAlloc(size,type)          MemAlloc_N(size,type)
	#define	MemAllocList(size,type,list) MemAlloc_L(size,type,list)
	#define MemFree(ptr)                 MemFree_N(ptr)
#endif

// Some debugging ...

#if MEM_DEBUG==1
	#define	MemAlloc(size,type)          MemAlloc_G(size,type)
	#define	MemAllocList(size,type,list) MemAlloc_L(size,type,list)
	#define MemFree(ptr)                 MemFree_N(ptr)
#endif

// Lots of debugging ...

#if MEM_DEBUG==2
	#define	MemAlloc(size,type)          MemAlloc_GF(size,type,__FILE__,__LINE__)
	#define	MemAllocList(size,type,list) MemAlloc_LF(size,type,list,__FILE__,__LINE__)
	#define MemFree(ptr)                 MemFree_PF(ptr,__FILE__,__LINE__)
#endif

//
// End Of __MEM_h
//

#endif
