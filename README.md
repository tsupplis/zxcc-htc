# HTC 3.09 Patched and Compiled on Unix using ZXCC

Extended htc (c driver + libc + libf). expected to work with zxcc. It is in the process
of realigning with the content of https://github.com/agn453/HI-TECH-Z80-C. Differences
and improvements will be submitted up once parity is established.

The HI-TECH Z80 CP/M C compiler V3.09 is provided free of charge for any
use, private or commercial, strictly as-is. No warranty or product
support is offered or implied.

You may use this software for whatever you like, providing you acknowledge
that the copyright to this software remains with HI-TECH Software.

*Current Version zxcc-htc 3.09-P008 includes all the changes of HI-TECH-Z80-C v3.09-6*

## Features and patches incorporated

- Collection of fixes
- Added bootstrap for dos
- Added overlays
- Extended libraries and headers

The sources of the fixes needs to be documented ... It constantly aligns with (https://github.com/agn453/HI-TECH-Z80-C). Still a few differences but they are going to be cleaned out

# Initial History 

## Extras from Release 3.09-P005 

- Trigonometry Functions Fixed (https://github.com/agn453/HI-TECH-Z80-C v3.09-1)
- Pipe Manager Integration (http://www.seasip.info/Cpm/software/index.html)
- Changes to memset/bdos/bios (https://github.com/agn453/HI-TECH-Z80-C v3.09-2)
- Further Changes from John Elliot/Jon Saxton (https://github.com/agn453/HI-TECH-Z80-C v3.09-3/4/4b) *** Some more changes ar still on going to be fully inline ***
- Addition of Overlays by Ron Murray

## Interface Changes

### File Name Changes

- libovl.lib has been added for overlay support
- stdint.h&unistd.h have been added

### Z80 CP/M C compiler options:

```
-A	Generate a self-relocating .COM program.
-C	Generate object code only; don't link.
-CR     Produce a cross-reference listing e.g. -CRfile.crf
-D	Define a symbol, e.g. -DDEBUG=1
-E	Specify executable output filename, e.g. -Efile.com
-F	Generate a symbol file for use with debug.com or overlay build.
	e.g. -Ffile.sym; default file name is L.SYM.
-H      Output help (the OPTIONS file) and exit.
-I	Specify an include directory, e.g. -I1:B:
-L	Scan a library, e.g. -LF scans the floating point library.
-M	Generate a map file, e.g. -Mfile.map
-O	Invoke the peephole optimizer (reduced code-size)
-OF	Invoke the optimizer for speed (Fast)
-R	Link in command line wild card expansion code.
-S	Generate assembler code in a .AS file; don't assemble or link.
-U	Undefine a predefined symbol, e.g. -UDEBUG
-V	Be verbose during compilation.
-W	Set warning level, e.g. -w5 or -w-2
-X	Suppress local symbols in symbol tables.
-Y	Generate an overlay output file (.OVR file-type)
```

### Miscellaneouse Function Changes


memset()

     The Hi-Tech C implementation of memset() is seriously broken and is
     almost guaranteed to give trouble in any program which uses it.

     The implementation simply does not agree with the function declaration.

bios()

    The original bios() routine used the function number to construct an offset
    into the BIOS jump vector and from that calculated the address of the
    appropriate BDOS routine.  Except for some character I/O routines, that
    method of calling the BIOS is guaranteed to crash CP/M 3.

    A new bios() function has been implemented which checks for CP/M 3 and if
    that is the current operating system then it accesses the BIOS via the
    sanctioned method, i.e. by invoking bdos(50) with an appropriately filled-
    out parameter block.

    The standard bios() routine takes 1, 2 or 3 parameters:

        short bios(int func, int bc, int de)

    and that is good enough for CP/M 2.2.  However CP/M 3 has functions which
    also take inputs in A and/or HL.  The routine is smart enough to figure
    out where to put the parameters.  All the C programmer needs to do is to
    supply the requisite arguments in the right order.

    A bug in the 2.2 bios() routine has been fixed.  The original code would
    always return an 8-bit result even though there are some functions which
    return 16-bit results.

bdos()

    All versions of CP/M 80 return from BDOS calls with BA = HL regardless of
    whether the function is returning an 8-bit or 16-bit result.  Hi-Tech C
    provided a bdos() call for 8-bit results and a bdoshl() call for 16-bit
    results.  John Elliott added a third, bdose(), for disk functions which
    could return extended error codes in H (and B) when running on CP/M 3.

    There is now a single bdos() function.  It always returns a 16-bit result
    in HL.  The bdoshl() routine still exists for compatibility with older
    source files but it is simply an alias for bdos().  John Elliott's
    bdose() routine no longer exists; bdos() also performs its functions.

    Some BDOS functions return 255 as an error flag.  The old bdos() code
    would sign-extend that to -1 (16 bit) but that is no longer done.

        if (bdos(fn, data) == -1)               /* This won't work */

        if (bdos(fn, data) == 255)              /* This works sometimes */

        if ((bdos(fn, data) & 0xFF) == 255)     /* This always works */

    Under CP/M 3 several functions return extended error information in
    the upper 8 bits of the return value.  (Those functions also set the
    standard errno global item.)  Always use the third form when checking
    for an error result.  The compiler is quite clever and doesn't make your
    program work harder ... it just uses the L register.

### Wildcard expansion

    Programs compiled with this update get wildcard expansion of the CP/M
    command line automatically.  There is no longer any need to call
    _getargs() explicitly.

    Enclosing an argument in quote marks (' or ") supresses expansion.
    This can be useful for programs like grep which may use ? and/or * in
    text search patterns or for program options containing a question mark:

        grep 'a.*end' *.h 2d:*.c
        grep "-?"

    The -R option passed to the Hi-Tech C compiler is no longer useful.  (It
    didn't work anyway.)

    Implementing automatic argument expansion meant altering the order of
    modules in LIBC.LIB.  That entailed rebuilding the entire library from
    scratch.  A script to do that is supplied.

### Filename drive and user number prefixes

    The format of file name prefixes indicating drive letter and/or user
    number is now much more liberal.  If a file "sample.txt" is on drive
    E: in user area 12 then depending on the current drive/user the file
    may be accessed as:

        sample.txt              if current DU: is E12:
        12:sample.txt           if current disk is E:
        e:sample.txt            if current user is 12
        e12:sample.txt
        12e:sample.txt
        12:e:sample.txt         (Hi-Tech C format)

    Note that any of these forms is acceptable for program arguments, even
    those containng wildcard characters (?, *).

### strcasecmp()

    The case-insensitive string comparison function strcasecmp() has been
    implemented.  Its function prototype is in string.h.  It works just like
    strcmp() except that upper- and lower-case letters are treated as 
    identical.  There is also a strncasecmp() analogue of strncmp() which
    allows one to limit the comparison to a certain number of characters.
    stricmp is also defined as a symbol.

### toupper() and tolower()

    The functions toupper() and tolower() were implemented as macros which
    added a case-shift value to the character parameter without checking to
    see if the parameter was a letter.  To use these routines correctly it was
    necessary to do a range check, e.g.

        if (isupper(c))
            c = tolower(c);

    These operations now invoke the correspondingly named routines in LIBC.LIB
    and it is no longer necessary to pre-test the character.

### Support for read/write files

    The stdio functions now allow files to be opened in modes "r+" and "w+" - 
    ie, reading and writing are supported on the same file.
    Remember to fflush() or fseek() between a read and a write.
    This code is experimental.

### CP/M 3 compatible error system

    exit(0) and _exit(0) set the CP/M 3 error code to 0.
    exit(n) and _exit(n) for non-zero n set the error code to 0xFF00 | (n&0x7F).

    The practical upshot is that exit(0) translates as "OK"; other values 
    translate as "error". You can use this in conjunction with CP/M 3's
    SUBMIT features.  If the next command in a .SUB file is preceded by
    a : character, it will be ignored:

        CPROG 
        :OTHER

    will only execute OTHER if CPROG exited with the value 0.

### PIPEMGR support (CP/M 3)

    Programs automatically check for PIPEMGR when they load, and if it
    is present the C streams stdin, stdout and stderr are routed to their
    PIPEMGR counterparts - no modification of the source is required.

    The special device files (CON: LST: PUN: and RDR:) are joined by RSX: 
    (PIPEMGR stdin/stdout streams) and ERR: (PIPEMGR stderr stream). If
    PIPEMGR is not present, these files behave like CON:

    The variable:

        extern char _piped;

    is nonzero if PIPEMGR is present.

    The command 

        FOO <CON:

    will behave differently if PIPEMGR is present. If it is not present,
    then you get line-based input from the Hi-Tech C library. If PIPEMGR
    is present then you get character-based input from PIPEMGR.

    The line-based input in the library will now return EOF if a control-Z
    is typed on a line by itself. Previously it would never return EOF on 
    line-based input.

    Unfortunately if you're using Simeon Cran's replacement ZPM3 then it
    does not allow control-Z to be typed on an input line.
    I'm not yet sure how to get round this.
  
    Remember that when PIPEMGR has parsed the command line, you may have a 
    number of blank (zero-length) arguments.
    
### Graceful exits

    Compiled programs exit gracefully if run on an 8080 or 8086 processor,
    or if there is not enough memory for the program and its static data.
    This is done in the CRTCPM.OBJ module.

### Checks for a ZCPR3 environment

    The variable

        extern void *_z3env;

    is 0 if one is not present, or its address if one is. It also passes it
    as a third parameter to main():

        int main(int argc, char **argv, void *z3env);

    The Z3 environment address must be passed to the program in HL.

### Extended getenv()

    Under CP/M 3, getenv() uses the search path set by SETDEF to locate the
    ENVIRON file. So if you like to keep ENVIRON on a drive that isn't A:, 
    programs will still find it.

### STRING.H

    The header file has been changed to reflect the available
    functions in LIBC.LIB.  There are still missing routines -
    namely strcoll() strcspn() strpbrk() and strspn() and these
    have been commented out for now.

strchr() and strrchr()

        char *strchr(char *s, int c)
        char *strrchr(char *s, int c)
    These functions - as well as index() and rindex() (which are identical)
    previously returned a NULL for no match.  The functions now return
    a pointer to the character string's ending NUL character.

stricmp() and strnicmp()

        char stricmp(char *s1, char *s2)
        char strnicmp(char *s1, char *s2, size_t n)
    Case-insensitive versions of strcmp() and strncmp() comparison routines.
    Can also be referenced as strcasecmp() and strncasecmp().

strstr(), strnstr(), stristr() and strnistr()

        char *strstr(char *t, char *s)
        char *strnstr(char *t, char *s, unsigned int n)
        char *strcasestr(char *t, char *s)
        char *strncasestr(char *t, char *s, unsigned int n)
    These extra functions locate the first occurrence of string s in
    string t.  The functions strnstr() and strcasestr() read at most
    n characters from the string t.  The functions strcasestr() and
    strncasestr() use case insensitive comparisons.
    All these functions return a pointer to the first character of
    the first occurence of string s in string t if found, and NULL
    otherwise.

strdup()
   
         char *strdup(char *s)
    Allocates a new buffer for and copies the string pointed to
    by s to it.  Returns a pointer to the copy of the string or NULL
    if the memory allocation failed. The memory block can be released
    using free().

strtok()
   
        char *strtok(char *s, char *tok, size_t toklen, char *brk)
    Copies characters from s to tok until it encounters one of the
    characters in brk or until toklen-1 characters have been copied
    (whichever comes first).  It then adds a NUL character to the
    end of the string.  This is a non-conforming POSIX function.
   

### TIME.H
    Now includes a prototype for strftime() - see below.

strftime()
   
        size_t strftime(char *s, size_t maxs, char *f, struct tm *t)
    Converts a time value t to a string using the format string f
    into the string s of size maxs (including a terminating NUL).
    It acts as a sprintf() function for date/time values. The
    following are valid in the format string -

             %A      full weekday name (Monday)
             %a      abbreviated weekday name (Mon)
             %B      full month name (January)
             %b      abbreviated month name (Jan)
             %c      standard date and time representation
             %d      day-of-month (01-31)
             %H      hour (24 hour clock) (00-23)
             %I      hour (12 hour clock) (01-12)
             %j      day-of-year (001-366)
             %M      minute (00-59)
             %m      month (01-12)
             %p      local equivalent of AM or PM
             %S      second (00-59)
             %U      week-of-year, first day sunday (00-53)
             %W      week-of-year, first day monday (00-53)
             %w      weekday (0-6, sunday is 0)
             %X      standard time representation
             %x      standard date representation
             %Y      year with century
             %y      year without century (00-99)
             %Z      timezone name
             %%      percent sign

    the standard date string is equivalent to:

        %a %b %d %Y

    the standard time string is equivalent to:

        %H:%M:%S

    the standard date and time string is equivalent to:

        %a %b %d %H:%M:%S %Y

    strftime() returns the number of characters placed in the
    buffer, not including the terminating NUL, or zero if more
    than maxs characters were produced.
   

### Fix to Environment Location

    The getenv() function was not correctly looking up the location of
    the environment file under CP/M 3 for the "default" entry in the drive
    search chain.  It will now locate the ENVIRON file if you have set-up
    the default search chain with a default entry. For example

    ; Set search chain to current drive, RAMdisk, C: then A:
    setdef * m: c: a:

    in your CP/M 3 PROFILE.SUB file (or manually entered on the command line).

### Source for DEHUFF and ENHUFF

    Andrey Nikitin has contributed the sources for the DEHUFF and ENHUFF programs 
    that were used by HI-TECH Software to distribute the library source files. I've 
    placed the extracted source files and the resulting binary produced by the latest 
    compiler in the huff folder. Also, the Huffman-encoded archive containing these 
    sources has been placed in the dist folder as HUFF.HUF. 


    These sources may be built using the HI-TECH C compiler or using the gcc 
    compiler under Linux or macOS. I built them natively under CP/M using -

    ```
    c -O -v enhuff.c encode.c misc.c
    c -O -v dehuff.c decode.c misc.c
    ```

### Change supported string length in printf() routine

    Merged a minor change into doprnt.c so that various printf() 
    routines can now output strings greater than 255 characters.

### PIPEMGR sources

    Included Jon Saxton's version of the PIPEMGR RSX for handling pipes 
    under CP/M 3.

    This is a modified version of the original by John Elliot that's detected 
    and used by each of the releases of HI-TECH C available from this repository.


    Also included is the source and executable for TEE which has the PIPEMGR 
    RSX attached and behaves like its namesake in the Unix world, along with 
    missing files from the original Van Nuys tools (PIPEMGR.H and PIPEMGR.C).

    The rest of the Van Nuys tools are available from John Elliot's original 
    PIPEMGR page at

    http://www.seasip.info/Cpm/software/Pipemgr/index.html




