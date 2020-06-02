#ifndef _HTC_CPM_H
#define _HTC_CPM_H

/* Header file for CP/M routines for Z-80 C */

/* get basic definitions */

#ifndef	_STDDEF
typedef	int		ptrdiff_t;	/* result type of pointer difference */
typedef	unsigned	size_t;		/* type yielded by sizeof */
#define	_STDDEF

#ifndef	NULL
#define	NULL	((void *)0)
#endif	NULL

extern int	errno;			/* system error number */

#endif	_STDDEF

/*	hitech.h has definitions for uchar, ushort etc */

#include	<hitech.h>

#ifdef	z80
#define	MAXFILE		8	/* max number of files open */
#else
#define	MAXFILE		15	/* max number of files open */
#endif
#define	SECSIZE		128	/* no. of bytes per sector */

extern struct	fcb
{
    uchar	dr;		    /*  0: drive code */
    char	name[8];	/*  1: file name */
    char	ft[3];		/*  9: file type */
    uchar	ex;		    /* 12: file extent */
    char	fil[2];		/* 13: not used */
    char	rc;		    /* 15: number of records in present extent */
    char	dm[16];		/* 16: CP/M disk map */
    char	nr;		    /* 32: next record to read or write */
    uchar	ranrec[3];	/* 35: random record number (24 bit no.) */
    long	rwp;		/* 38: read/write pointer in bytes */
    uchar	use;		/* 42: use flag */
    uchar	uid;		/* 43: user id belonging to this file */
    long	fsize;		/* 44: file length in bytes */
}  _fcb[MAXFILE];


extern short	bdos(int, ...);
#define bdoshl	   bdos
#define bdose	   bdos
extern struct fcb *	getfcb(void);
extern char * fcbname(short i);
extern short	getuid(void);
extern short	setuid(short);
extern uchar	setfcb(struct fcb *, char *);
extern char *   (*_passwd)(struct fcb *);
extern short	bios(short fn, ...);
#define bios3 bios

/*   flag values in fcb use */

#define	U_READ	1		/* file open for reading */
#define	U_WRITE	2		/* file open for writing */
#define	U_RDWR	3		/* open for read and write */
#define	U_CON	4		/* device is console */
#define	U_RDR	5		/* device is reader */
#define	U_PUN	6		/* device is punch */
#define	U_LST	7		/* list device */
#define U_RSX   8       /* PIPEMGR RSX */
#define U_ERR   9       /* PIPEMGR stderr channel */

/*	 special character values */

#define	CPMETX	032		/* ctrl-Z, CP/M end of file for text */
#define	CPMRBT	003		/* ctrl-C, reboot CPM */

/*	operating systems	*/

#define	MPM	    0x100		/* bit to test for MP/M */
#define	CCPM	0x400		/* bit to test for CCP/M */

#define	ISMPM()	(bdoshl(CPMVERS)&MPM)	/* macro to test for MPM */
#define SET_RCODE(a) (bdos(CPMRCODE,(a)))
#define GET_RCODE(a) (bdos(CPMRCODE,0xFFFF))


/*	 what to do after you hit return */

#define	EXIT	(*(int (*)())0)	/* where to go to reboot CP/M */

/*	BDOS calls etc. */

#define	CPMRCON	1		/* read console */
#define	CPMWCON	2		/* write console */
#define	CPMRRDR	3		/* read reader */
#define	CPMWPUN	4		/* write punch */
#define	CPMWLST	5		/* write list */
#define	CPMDCIO	6		/* direct console I/O */
#define	CPMGIOB	7		/* get I/O byte */
#define	CPMSIOB	8		/* set I/O byte */
#define	CPMWCOB	9		/* write console buffered */
#define	CPMRCOB	10		/* read console buffered */
#define	CPMICON	11		/* interrogate console ready */
#define	CPMVERS	12		/* return version number */
#define	CPMRDS	13		/* reset disk system */
#define	CPMLGIN	14		/* log in and select disk */
#define	CPMOPN	15		/* open file */
#define	CPMCLS	16		/* close file */
#define	CPMFFST	17		/* find first */
#define	CPMFNXT	18		/* find next */
#define	CPMDEL	19		/* delete file */
#define	CPMREAD	20		/* read next record */
#define	CPMWRIT	21		/* write next record */
#define	CPMMAKE	22		/* create file */
#define	CPMREN	23		/* rename file */
#define	CPMILOG	24		/* get bit map of logged in disks */
#define	CPMIDRV	25		/* interrogate drive number */
#define	CPMSDMA	26		/* set DMA address for i/o */
#define CPMSATT 30      /* set file attributes */
#define CPMDPB	31		/* get disk parameter block */
#define	CPMSUID	32		/* set/get user id */
#define	CPMRRAN	33		/* read random record */
#define	CPMWRAN	34		/* write random record */
#define	CPMCFS	35		/* compute file size */
#define CPMERRM 45		/* CP/M+ set error mode */
#define CPMSCB  49      /* access CP/M+ system control block */
#define	CPMDSEG	51		/* set DMA segment */
#define	CPMRSX	60		/* call RSX */
#define CPMTRNC  99		/* truncate file */
#define CPMDLD  101		/* get directory label data */
#define CPMGFTS 102     /* get file timestamp and password mode */
#define CPMSDAT 104     /* set date and time */
#define CPMGDAT 105     /* get date and time */
#define CPMRCOD 108     /* get/set return code */
#define CPMCMOD 109     /* get/set console mode */


/* CP/M BIOS functions.  Numbers above 16 pertain to CP/M 3 only.  */

enum BIOSfns
{
    _BOOT	=  0,
    _WBOOT	=  1,

    _CONST	=  2,
    _CONIN	=  3,
    _CONOUT	=  4,
    _LIST	=  5,
    _PUNOUT	=  6,	/* CP/M 2.2 name */
    _AUXOUT	=  6,	/* CP/M 3.1 name */
    _RDRIN	=  7,	/* CP/M 2.2 name */
    _AUXIN	=  7,	/* CP/M 3.1 name */
    _LISTST	= 15,
    _CONOST	= 17,
    _AUXIST	= 18,
    _AUXOST	= 19,

    _DEVTBL	= 20,
    _DEVINI	= 21,
    _DRVTBL	= 22,

    _HOME	=  8,
    _SELDSK	=  9,
    _SETTRK	= 10,
    _SETSEC	= 11,
    _SETDMA	= 12,
    _READ	= 13,
    _WRITE	= 14,
    _SECTRN	= 16,
    _MULTIO	= 23,
    _FLUSH	= 24,

    _MOVE	= 25,
    _SELMEM	= 27,
    _SETBNK	= 28,
    _XMOVE	= 29,

    _TIME	= 26,
    _USERF	= 30
};

#endif
