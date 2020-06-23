#include    <cpm.h>

extern int _new_fsize;

int close(uchar fd)
{
    register struct fcb *fc;
    uchar       luid;

    if (fd >= MAXFILE)
        return -1;
    fc = &_fcb[fd];
    luid = getuid();
    setuid(fc->uid);
    if (fc->use == U_WRITE || fc->use == U_RDWR
                           || bdos(CPMVERS)&(MPM|CCPM) && fc->use == U_READ)
        bdos(CPMCLS, fc);
    if(_new_fsize)
        fc->nr = (-fc->fsize & 0x7f);  /* Set exact file size */
    else
        fc->nr = (fc->fsize & 0x7f);  /* Set exact file size */
    fc->name[5] |= 0x80;
    if (fc->use == U_WRITE || fc->use == U_RDWR)
        bdos(CPMSATT, fc);
    fc->use = 0;
    setuid(luid);
    return 0;
}
