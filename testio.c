#include "stdio.h"
#include "cpm.h"
#include <stdio.h>

int main(int argc, char ** argv)
{
    int i;
    int minor=0;
    int major=0;
    extern int _piped_r;
    FILE *f;
    char c=34;

    fprintf(stderr,"%s,%02x\n","hexa",c);
    freopen("testio.err","w",stderr);
    fprintf(stderr,"piped(%c)=%02x\n",_piped_r?'Y':'N',_piped_r);
    fprintf(stderr,"argc=%d\n",argc);
    for(i=0;i<argc;i++) {
        fprintf(stderr,"argv=%s\n",argv[i]);
    }
    f=fopen("testio.sta","w");
    fprintf(f,"stamp\r\n");
    fclose(f);
    i=bdoshl(CPMVERS,0);
    switch(i) {
    case 0x00:
        major=1;
        minor=0;
        break;
    default:
        major=((i>>4)&0x0F);
        minor=(i&0x0F);
        break;
    }
    printf("CP/M BDOS %d.%d\n",major,minor);
    return 0;
}

