This is a somewhat modified version of PIPEMGR.RSX by John Elliott.

PIPEMGR is an RSX which when attached to suitable programs provides input and
output redirection capability.  One possible use is to capture the output of
a program to a text file.  The DISKINFO tool supplied on Tesseract volume 89
is such a program.  So are pograms compiled with the updated Hi-Tech C from
Tesseract tvolume 91.

The archive contains TEE.COM which has the pipe manager RSX attached and so
behaves like its namesake in the UNIX world.

Jon Saxton

===============================================================================
PIPEMGR v1.02    Pipe manager for CP/M Plus       John Elliott, 3 January 2000.
===============================================================================

Recent changes: PIPEMGR 1.00 contained bugs when the output of one program
               was piped to another. This could result in a "can't open input"
               error. It also overwrote a file when asked to append to it.
               These bugs have been fixed in v1.02.

  This documentation is for programmers who want to use PIPEMGR in their
own programs. Hardly any of the information here need be handed on to the
users of the programs - just the details of the command line syntax (for 
example, see EGDOC.TXT).

  PIPEMGR.RSX (only) is distributed under the GNU Library General Public
License, version 2 (see COPYING.LIB). The accompanying utilities may be 
distributed freely, but no source is provided.

  Those of us who have used DOS or UNIX computers will be familiar with
the idea of the "pipe" - a system by which the output of a program may be
sent directly into the input of another. This functionality is not present in
CP/M, although there have been some program suites (such as the Van Nuys 
Tools) which could simulate it.

  PIPEMGR is another program of this type. It is an RSX module, which should
be attached to suitable programs with GENCOM. When it is attached, it adds 
various system calls designed to make implementation of pipes easier to 
program. It supports three devices: 

 - Standard input (stdin) - input to the program, either from the keyboard or
  from a file.
 - Standard output (stdout) - conventional data output from the program, 
  perhaps to a screen or to a file.
 - Standard error (stderr) - error messages output by the program.

  PIPEMGR requires CP/M-80 version 3 (CP/M Plus) and a Z80 processor.

PIPEMGR API
=========== 

  All calls are made to the BDOS (CALL 5) with C=3Ch and DE pointing to an
area of memory (the RSXPB) whose format is described in each function. Note 
that these functions behave like genuine BDOS functions; they return data in
HL = BA and corrupt C, D, E and the flags. What happens to the Z80 registers 
IX etc. is left to the discretion of the BIOS.

 - Initialise PIPEMGR. This call should always be made before attempting to
  use the features of PIPEMGR.

      RSXPB:    DEFB 79h,1      ;Function code
                DEFW addr       ;Address of authentication string

      addr:     DEFB 'PIPEMGR ' ;authentication string

    This function scans the standard command tail at 80h for any of the 
  following redirection operations:

    <file    - Standard input comes from "file".
    >file    - Standard output is sent to "file". If "file" exists, it is 
              deleted.
   >>file    - Standard output is appended to "file".
   >&file    - Standard output and standard error are sent to "file".
   >>&file   - Standard output and standard error are appended to "file".
   |command  - Standard output is sent into the standard input of "command"
              (which is a standard CP/M command) via a file on the temporary
              file drive (set using SETDEF). 
   |&command - Standard output and standard error are sent into the standard
              input of the next program.

    The filenames can be right up against the redirection symbols, or have
  a space between them (ie,  ">file"  or  " > file"  ).
    Any filename passed to PIPEMGR can include user numbers, for example:

      10A:FILE.TXT
       B5:README.1ST
        0:PROFILE.SUB

    It can also handle four special device names:

    CON: - The current screen/keyboard device(s) as set by DEVICE CON:=xxx
    AUX: - The current auxiliary device(s) as set by DEVICE AUX:=xxx
    LST: - The current printer as set by DEVICE LST:=xxx
    NUL: - Nothing. Inputting from it returns End-Of-File; output to it is 
          lost. 

    Note that unlike DOS, the : at the end of the device name is mandatory,
  and you can't prepend \DEV\ to the device name.

    If any PIPEMGR operator is found, then it will be replaced in the command
  by spaces - so, when your program is called with:

   MYPROG <file1 /G |GREP Fish

  after this call, it will look as if the user had typed:

   MYPROG        /G
        
    Take care of this if you're programming in a language like Hi-Tech C. In 
  the above example, argv[1] to argv[8] will be strings of zero length, and 
  argv[9] will hold the "/G" option.

  This function returns HL=00FFh if PIPEMGR is not present, or 0 if it is.

 - Read a byte from standard input.

      RSXPB:    DEFB 7Ch,0

   Returns H=0 if end-of-file - otherwise H is nonzero and L=the byte read. 
  There are some special considerations to deal with when considering what 
  constitutes an end-of-file; see "File sizes" below.

 - Write a byte to standard output.

      RSXPB:    DEFB 7Dh,1
                DEFB byte,0

    Returns with HL undefined.

 - Write a byte to standard error.

      RSXPB:   DEFB 7Ah,1
               DEFB byte,0

    Returns with HL undefined.

 - Emergency terminate PIPEMGR (pending data not written to disc).

      RSXPB:  DEFB 7Fh,1          ; or 7Eh,1
              DEFW addr           ;address of authentication string

      addr:   DEFB 'PIPEMGR '                                

    Returns with HL undefined. This can be called at any time to force PIPEMGR
   to quit.

 - Return PIPEMGR version.

      RSXPB:  DEFB 7Bh,1
              DEFW addr           ;address of authentication string.

      addr:   DEFB 'PIPEMGR '

    Returns H = major version number (BCD), L = minor version (BCD). Currently
    returns 0100h (1.00). If PIPEMGR is not loaded, returns HL=00FFh.

 - Return PIPEMGR status

      RSXPB:  DEFB 76h,1
              DEFW addr           ;address of authentication string.

      addr:   DEFB 'PIPEMGR '

  Returns B=H=bitmapped flags:

     Bit 0 set if stdin  is redirected
     Bit 1 set if stdout is redirected
     Bit 2 set if stderr is redirected
     Bit 3 set if redirected input is coming from a pipe
     Bit 4 set if redirected input is going to a pipe

  This call can be used (for example) to check whether your program should
 pause after every screen of information. If output is redirected, it will;
 but if not, then the paged screen can be used.

 - There is no need to call any function when your program quits. 

In Use
======

  Having created your program, and used GENCOM to combine it with PIPEMGR:

GENCOM myprog PIPEMGR

then the program will be capable of performing the redirections and pipings
listed above. If you are creating a pipe (ie, a series of commands separated
by | symbols) then all the programs in the pipe except possibly the last
must have been written to use the PIPEMGR functions; so:

FOO |BAR |BAZ |TEE PANCAKE |PIP LST:=CON:[N]

is a valid pipe provided that FOO.COM, BAR.COM, BAZ.COM and TEE.COM were all
written to use the PIPEMGR functions. The last program (in this case, 
PIP.COM) does not need to be a PIPEMGR program. For more details on piping
into a non-PIPEMGR program, see below.

File sizes
==========

  Under CP/M versions 1 and 2, file sizes could not be stored exactly, but only
to the nearest 128 bytes. Because of this, text files which were not an exact
multiple of 128 bytes in length would have an End-Of-File marker added (^Z,
ASCII 26). 
  CP/M 3 and its 80x86 successors (DOSPLUS, REAL/32 etc.) can store file sizes
exactly. This feature is used by very few programs, though; most still rely on
the ^Z character.

  PIPEMGR always uses the exact file size, and treats ^Z as just another 
character. This is consistent with the behaviour of UNIX, and allows binary
files to be sent through pipes without being damaged. Thus a program which
wants to read a text file from standard input will have to check two 
conditions:
  1. That on return, H is nonzero.
  2. That if H is nonzero, L is not 26 (1Ah, ^Z). 

  Files created by PIPEMGR always have the exact size set. For compatibility
with programs which do not use exact sizes, any unused bytes in the last 
record are set to ^Z (1Ah). 
  When a pipe is in operation, the number of bytes received by the second 
program is the same as the number sent by the first; no ^Z characters are
appended.
  If you want to be able to preserve exact lengths when copying files, 
use PPIP v1.9 or later.

Piping into a non-PIPEMGR program
=================================

  PIPEMGR can be used to simulate keyboard input into a program even if that
program does not use the PIPEMGR calls. As long as the program uses BDOS calls
to read the keyboard, PIPEMGR can simulate input into it. The following 
BDOS functions are modified only when:
i)   A pipe is in use.
ii)  The currently running program has not used the "Initialise PIPEMGR" call.
iii) Bits 8 and 9 of the console mode word are not both set. Setting both these
    bits is a signal to disable all console redirection.

C=01h: Input character.
    The next character from the pipe is read in. Both carriage returns and 
  line feeds are passed to the program (for compatibility with PIP). When
  no more characters are available, ^Z is returned. The character is not
  echoed to the screen.

C=06h: Direct console I/O (input functions).
  E=0FFh: As C=01h.
  E=0FEh: As C=0Bh.
  E=0FDh: As C=01h.

0Ah: Input line.
  Reads in characters until the buffer is full, or a CR or LF character is
 encountered, or no more characters are available. The characters are not
 echoed. When no more characters are available, it returns a blank line.

0Bh: Console status.
  The exact effect of this command depends on the setting of bits 8 and 9 of
  the console mode word:

bits 9 8
     0 0  - "Compatibility" mode. All calls to this function return 0, unless
           they immediately follow another call to this function. This is the
           same behaviour that SUBMIT and GET exhibit. The second call will 
           return 0FFh.
     0 1  - Always returns 0FFh.
     1 0  - Always returns 0.
     1 1  - Input from PIPEMGR is disabled; the keyboard will be used.

PIPEMGR and other piping systems
================================

  Since PIPEMGR can simulate keyboard input, it can be used with programs
that use other piping systems (such as the DIO library). Here's an example:

PMPROG1 | PMPROG2 | DIOPROG1 | DIOPROG2

The first two '|' symbols are controlled by PIPEMGR; the third one is 
controlled by DIO, and its behaviour has no connection with PIPEMGR. 
  Unfortunately, it is not possible to do this the other way round. DIO
programs cannot cope with CP/M Plus RSX headers, so a pipeline like:

DIOPROG1 | DIOPROG2 | PMPROG1 |PMPROG2 

will not work (PMPROG1 will not execute). You will have to simulate it with:

DIOPROG1 | DIOPROG2 >tmp.$$$ ! PMPROG1 <tmp.$$$ | PMPROG2 ! era tmp.$$$

(commands separated by ! marks and PIPEMGR pipes can apparently be mixed
freely.)

  PIPEMGR versions of the Van Nuys Tools (the major DIO suite) have been 
written by me and should be available wherever you got PIPEMGR. Note that
they include their own versions of LS, CAT and TEE.

Hi-Tech C library
=================

  A modified version of the Hi-Tech C library (LIBC.LIB) is provided. 
See LIBCNEW.DOC for details.


