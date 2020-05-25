#include	"cpm.h"

extern int errno;

long
_fsize(fd)
uchar	fd;
{
	register struct fcb *	fc;
	long			tmp;
	uchar			d, luid, buf[SECSIZE];

	if(fd >= MAXFILE)
		return -1;
	fc = &_fcb[fd];
	luid = getuid();
	setuid(fc->uid);
	bdose(CPMCFS, fc);
	tmp = (long)fc->ranrec[0] + ((long)fc->ranrec[1] << 8) + ((long)fc->ranrec[2] << 16);
	tmp *= SECSIZE;
	bdos(CPMSDMA,buf);
	if ((d=bdose(CPMFFST, fc)) < 4)   /* Account for CP/M3 bytewise */
	{
		d=(buf[13+ (d << 5)] & 0x7F);  /* file sizes */
		if (d) d=0x80-d;
                tmp-=d;
	}
	setuid(luid);
	return tmp;
}


open(name, mode)
char *	name;
{
	register struct fcb *	fc;
	uchar			luid;

	if(++mode > U_RDWR)
		mode = U_RDWR;
	if(!(fc = getfcb()))
		return -1;
	if(!setfcb(fc, name)) {
		if(mode == U_READ && bdos(CPMVERS) >= 0x30)
			fc->name[5] |= 0x80;	/* read-only mode */
		luid = getuid();
		setuid(fc->uid);
		if(bdose(CPMOPN, fc) == -1) {
			putfcb(fc);
			setuid(luid);
                        if (errno == 16) errno = 7; /* File not found */
			return -1;
		}
		fc->fsize=_fsize(fc - _fcb);	/* Set file size */
		setuid(luid);
		fc->use = mode;
	}
	return fc - _fcb;
}
