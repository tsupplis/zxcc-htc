#include "stdio.h"
#include "cpm.h"
#include <stdio.h>

int main(int argc, char ** argv)
{
    int i;
    int minor=0;
    int major=0;
    int machine;
    int system;
    int* bdosaddr=(int*)6;
    int* biosaddr=(int*)1;
    unsigned int tpa;

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
    machine=(i>>12)&0x0F;
    system=(i>>8)&0x0F;
    printf("CP/M BDOS Version (%d.%d)\n",major,minor);
    if(system!=0) {
        printf("Network (%s%s%s)\n",system&0x01?"[MP/M]":"",system&0x02?"[CP/Net]":"",
            system&0x04?"[Multi User]":"");
    }
    switch(machine) {
    case 0:
        printf("Machine (MCS80/Z80)\n",machine);
        break;
    case 1:
        printf("Machine (MCS86)\n");
        break;
    case 2:
        printf("Machine (68000/Z8000)\n");
        break;
    default:
        printf("Machine (?)\n");
        break;
    }
    printf("BDOS Address (0x%04x)\n",*bdosaddr-6);
    printf("BIOS Address (0x%04x)\n",*biosaddr-3);
    tpa=((*bdosaddr-6)-0x100);
    fprintf(stdout,"TPA Size (%u.%uK)\n",tpa/1024,(tpa % 1024)/100);
    return 0;
}

