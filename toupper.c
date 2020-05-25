#include <ctype.h>

#undef toupper

int toupper(int c) {
    if(isupper(c)) {
        return toupper(c);
    }
    return c;
}
