#include    <cpm.h>

#ifdef _HTC_PIPEMGR_SUPPORT
extern char _piped;    /* PIPEMGR loaded? */
#endif

#define CPMEOF 0x1A         /* Control-Z */

#ifdef _HTC_PIPEMGR_SUPPORT
static char RSXPB[]={0x7C,0};
#endif

read(fd, buf, nbytes)
uchar    fd;
ushort    nbytes;
char *    buf;
{
    register struct fcb *    fc;
    uchar    size, offs, luid;
    ushort    cnt;
#ifdef _HTC_PIPEMGR_SUPPORT
        ushort  pipev;
#endif
    char    buffer[SECSIZE+2];

    cnt = 0;
    if(fd >= MAXFILE)
        return -1;
    fc = &_fcb[fd];
    switch(fc->use) {

    case U_RDR:
        cnt = nbytes;
        while(nbytes) {
            nbytes--;
            if((*buf++ = (bdos(CPMRRDR) & 0x7f)) == '\n')
                break;
        }
        return cnt - nbytes;
#ifdef _HTC_PIPEMGR_SUPPORT
    case U_RSX:       /* PIPEMGR RSX : input */
        if (_piped)
        {
            cnt = nbytes;
            while(nbytes) {
                pipev = bdoshl(CPMCRSX,&RSXPB);
                if (pipev < 0x100) 
                    break;
                else *buf++ = (pipev & 0xFF);
                    nbytes--; /* Only decrement if the read worked*/
                    if ((pipev & 0xFF) == '\n') 
                            break;
            }
            return cnt - nbytes;
        }
#endif
    case U_CON:
        if(nbytes > SECSIZE)
            nbytes = SECSIZE;
        buffer[0] = nbytes;
        bdos(CPMRCOB, buffer);
        cnt = (uchar)buffer[1];

                /* [JCE] Return EOF for Ctrl-Z on a line by itself. */
                if (cnt == 1 && buffer[2] == CPMEOF) return 0;

        if(cnt < nbytes) {
            bdos(CPMWCON, '\n');
            buffer[cnt+2] = '\n';
            cnt++;
        }
        bmove(&buffer[2], buf, cnt);
        return cnt;

    case U_READ:
    case U_RDWR:
        if (nbytes + fc->rwp > fc->fsize)    /* Limit length */
            nbytes = fc->fsize - fc->rwp;
        luid = getuid();
        cnt = nbytes;
        while(nbytes) {
            _sigchk();
            setuid(fc->uid);
            offs = fc->rwp%SECSIZE;
            if((size = SECSIZE - offs) > nbytes)
                size = nbytes;
            _putrno(fc->ranrec, fc->rwp/SECSIZE);
            if(size == SECSIZE)
             {
                bdos(CPMSDMA, buf);
#ifdef    LARGE_MODEL
                bdos(CPMDSEG, (int)((long)buf >> 16));    /* set DMA segment */
#endif
                if(bdose(CPMRRAN, fc))
                    break;
            }
            else
            {
                bdos(CPMSDMA, buffer);
#ifdef    LARGE_MODEL
                bdos(CPMDSEG, (int)((long)buffer >> 16));    /* set DMA segment */
#endif
                if(bdose(CPMRRAN, fc))
                    break;
                bmove(buffer+offs, buf, size);
            }
            buf += size;
            fc->rwp += size;
            nbytes -= size;
            setuid(luid);
        }
        setuid(luid);
        return cnt - nbytes;

    default:
        return -1;
    }
}
