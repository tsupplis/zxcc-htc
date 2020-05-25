#include <ctype.h>

#undef tolower

int tolower(int c) {
    if(isupper(c)) {
        return tolower(c);
    }
    return c;
}
