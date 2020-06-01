# zxcc-htc

Extended htc (c driver + libc + libf). expected to work with zxcc. It is in the process
of realigning with the content of https://github.com/agn453/HI-TECH-Z80-C. Differences
and improvement will be submitted up once parity is established.

The HI-TECH Z80 CP/M C compiler V3.09 is provided free of charge for any
use, private or commercial, strictly as-is. No warranty or product
support is offered or implied.

You may use this software for whatever you like, providing you acknowledge
that the copyright to this software remains with HI-TECH Software.

## Features and patches incorporated

- Collection of fixes
- Added bootstrap for dos
- Added overlays
- Extended libraries and headers

The sources of the fixes needs to be documented ... It constantly aligns with (https://github.com/agn453/HI-TECH-Z80-C). Still a few differences but they are going t be cleaned out

## Release 3.09-P005 

- Trigonometry Functions Fixed (https://github.com/agn453/HI-TECH-Z80-C v3.09-1)
- Pipe Manager Integration (http://www.seasip.info/Cpm/software/index.html)
- Changes to memset/bdos/bios (https://github.com/agn453/HI-TECH-Z80-C v3.09-2)
- Further Changes from John Elliot/Jon Saxton (https://github.com/agn453/HI-TECH-Z80-C v3.09-3/4/4b) *** Some more changes ar still on going to be fully inline ***
- Addition of Overlays by Ron Murray
- 

## Interface Changes

### File Changes

- crtcpm.obj has been renamed crt0.obj to win some command line space
- rrtcpm.obj has been renamed rrt0.obj to win some command line space
- rdr0.obj has been added to add expansion of wild card (-R option)
- libovl.lib has been added for overlay support
- stdint.h/unistd.h have been added

### Z80 CP/M C compiler options:

-A      Generate a self-relocating .COM program
-R      Link in command line wild card expansion code
-V      Be verbose during compilation
-S      Generate assembler code in a .AS file; don't assemble or link
-C      Generate object code only; don't link.
-E      Name of the executable output
-O      Invoke the peephole optimizer
-I      Specify an include directory, e.g. -I1:B:
-U      Undefine a predefined symbol, e.g. -UDEBUG
-D      Define a symbol, e.g. -DDEBUG=1
-L      Scan a library, e.g. -LF scans the floating point library
-F      Generate a symbol file suitable for use with debug.com, e.g.
                -Ffile.sym; default file name is L.SYM.
-W      Set warning level, e.g. -w5 or -w-2
-X      Suppress local symbols in symbol tables
-M      Generate a map file, e.g. -Mfile.map
-Y      Compile as Overlay


### Function Change Details


```
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
```

```
Wildcard expansion

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

Filename drive and user number prefixes

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

strcasecmp()

    The case-insensitive string comparison function strcasecmp() has been
    implemented.  Its function prototype is in string.h.  It works just like
    strcmp() except that upper- and lower-case letters are treated as 
    identical.  There is also a strncasecmp() analogue of strncmp() which
    allows one to limit the comparison to a certain number of characters.
    stricmp is also defined as a symbol.

toupper() and tolower()

    The functions toupper() and tolower() were implemented as macros which
    added a case-shift value to the character parameter without checking to
    see if the parameter was a letter.  To use these routines correctly it was
    necessary to do a range check, e.g.

        if (isupper(c))
            c = tolower(c);

    These operations now invoke the correspondingly named routines in LIBC.LIB
    and it is no longer necessary to pre-test the character.

Support for read/write files

    The stdio functions now allow files to be opened in modes "r+" and "w+" - 
    ie, reading and writing are supported on the same file.
    Remember to fflush() or fseek() between a read and a write.
    This code is experimental.

PIPEMGR support (CP/M 3)

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
    
Checks for a ZCPR3 environment

    The variable

        extern void *_z3env;

    is 0 if one is not present, or its address if one is. It also passes it
    as a third parameter to main():

        int main(int argc, char **argv, void *z3env);

    The Z3 environment address must be passed to the program in HL.

Extended getenv()

    Under CP/M 3, getenv() uses the search path set by SETDEF to locate the
    ENVIRON file. So if you like to keep ENVIRON on a drive that isn't A:, 
    programs will still find it.

```



