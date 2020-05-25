#include <string.h>
#include <ctype.h>

int stricmp(char *s1, char *s2)
{
    unsigned char *p1 = (unsigned char *) s1;
    unsigned char *p2 = (unsigned char *) s2;
    int r;

    if (s1 == s2) {
        return 0;
    }

    while (1) {
        unsigned char c1=isupper(*p1)?tolower(*p1):*p1;
        unsigned char c2=isupper(*p2)?tolower(*p2):*p2;
        if((r=c1-c2)!=0) {
            break;
        }
        if(*p1=='\0') {
            break; 
        }
        p2++;p1++;
    }
    return r?(r>0?1:-1):0;
}

int strnicmp(char * s1, char *s2, size_t n)
{
    unsigned char *p1 = (unsigned char *) s1;
    unsigned char *p2 = (unsigned char *) s2;
    unsigned char c1;
    unsigned char c2;
    int r;

    if (s1 == s2) {
        return 0;
    }

    while (1) {
        if(n--==0) {
            break;
        }
        c1=isupper(*p1)?tolower(*p1):*p1;
        c2=isupper(*p2)?tolower(*p2):*p2;
        if((r=c1-c2)!=0) {
            break;
        }
        if(*p1=='\0') {
            break; 
        }
        p2++;p1++;
    }
    return r?(r>0?1:-1):0;
}

