#include	"cpm.h"

close(fd)
uchar	fd;
{
	register struct fcb *	fc;
	uchar		luid;

	if(fd >= MAXFILE)
		return -1;
	fc = &_fcb[fd];
	luid = getuid();
	setuid(fc->uid);
	if(fc->use == U_WRITE || fc->use == U_RDWR || bdoshl(CPMVERS)&(MPM|CCPM) && fc->use == U_READ)
		bdose(CPMCLS, fc);
	fc->nr=(fc->fsize & 0x7f);  /* Set exact file size */
	fc->name[5]|=0x80;
	if(fc->use == U_WRITE || fc->use == U_RDWR)
		bdose(CPMSFAT, fc);
	fc->use = 0;
	setuid(luid);
	return 0;
}
