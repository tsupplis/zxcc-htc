.SUFFIXES: .obj .c .as
LIBR=zxcc libr
AS=zxcc zas
CC=zxcc c
CFLAGS=--o
ASFLAGS=--j

.c.obj:	
	$(CC) $(CFLAGS) --c $*.c

.as.obj: 
	$(AS) $(ASFLAGS) $*.as

TESTS=testver.com testio.com testovr.com testovr1.ovr testovr2.ovr teststr.com \
 testbios.com testbdos.com testtrig.com testftim.com testfile.com testaes.com \
 testuid.com testrc.com

COBJS=getargs.obj assert.obj printf.obj fprintf.obj sprintf.obj  \
doprnt.obj gets.obj puts.obj fwrite.obj getw.obj  \
strtok.obj strdup.obj strstr.obj stristr.obj strnstr.obj strnistr.obj \
putw.obj getenv.obj putchar.obj perror.obj fputc.obj  \
flsbuf.obj fopen.obj freopen.obj fseek.obj fread.obj  \
rewind.obj remove.obj setbuf.obj fscanf.obj ctime.obj  \
cgets.obj cputs.obj sscanf.obj scanf.obj doscan.obj  \
ungetc.obj fgetc.obj filbuf.obj stdclean.obj fclose.obj  \
fflush.obj buf.obj exit.obj start1.obj start2.obj  \
open.obj read.obj write.obj seek.obj stat.obj  \
chmod.obj fcbname.obj rename.obj creat.obj time.obj  \
convtime.obj timezone.obj isatty.obj close.obj unlink.obj  \
dup.obj execl.obj getfcb.obj srand1.obj srand.obj abort.obj  \
getch.obj signal.obj getuid.obj bdos.obj  \
bios.obj cleanup.obj _exit.obj fakeclea.obj fakecpcl.obj  \
sys_err.obj memcpy.obj memcmp.obj memset.obj abs.obj  \
asallsh.obj allsh.obj asalrsh.obj asar.obj asdiv.obj  \
asladd.obj asland.obj asll.obj asllrsh.obj aslmul.obj  \
aslor.obj aslsub.obj aslxor.obj strftime.obj asmod.obj atoi.obj  \
atol.obj blkclr.obj blkcpy.obj calloc.obj asmul.obj  \
bitfield.obj ctype_.obj getsp.obj index.obj strchr.obj  \
inout.obj iregset.obj isalpha.obj isdigit.obj islower.obj  \
isspace.obj isupper.obj ladd.obj land.obj linc.obj  \
llrsh.obj longjmp.obj lor.obj brelop.obj wrelop.obj  \
lrelop.obj frelop.obj lsub.obj lxor.obj malloc.obj  \
max.obj idiv.obj pnum.obj ldiv.obj qsort.obj  \
swap.obj aslr.obj bmove.obj imul.obj rand.obj  \
alrsh.obj lmul.obj rindex.obj strrchr.obj sbrk.obj  \
shar.obj shll.obj shlr.obj strcat.obj strcmp.obj  \
strcpy.obj strlen.obj stricmp.obj stristr.obj strncat.obj \
strncmp.obj strnicmp.obj strncpy.obj csv.obj rcsv.obj tolower.obj toupper.obj xtoi.obj 

FOBJS=printf.obj fprintf.obj sprintf.obj scanf.obj fscanf.obj sscanf.obj fdoprnt.obj \
 fdoscan.obj atof.obj fnum.obj fbcd.obj tan.obj acos.obj asin.obj atan2.obj atan.obj \
 cos.obj sin.obj sinh.obj cosh.obj tanh.obj exp.obj log.obj evalpoly.obj sqrt.obj \
 frexp.obj fabs.obj ceil.obj floor.obj finc.obj asfloat.obj frndint.obj ftol.obj \
 ltof.obj float.obj

DOCS=htc.txt options.txt z80doc.txt readme.txt
HEADERS=assert.h cpm.h exec.h hitech.h math.h setjmp.h stat.h stddef.h stdio.h \
  string.h time.h unixio.h conio.h ctype.h float.h limits.h overlay.h signal.h \
  stdarg.h stdint.h stdlib.h sys.h unistd.h stdio.i
ORIGTOOLS=cgen.com cpp.com cref.com debug.com dehuff.com \
	libr.com link.com objtohex.com optim.com p1.com \
	zas.com

OVROBJS=ovrload.obj ovrbgn.obj
CRTOBJS=crt0.obj rrt0.obj wcr0.obj
ZCRTOBJS=zcrt0.obj zrrt0.obj
TOOLSOBJS=ec.obj symtoas.obj exec.obj
LIBS=libc.lib libovr.lib libf.lib
TOOLS=c.com symtoas.com exec.com

all: $(LIBS) $(CRTOBJS) $(TOOLS)

libovr.lib:	$(OVROBJS)
	rm -f libovr.lib
	for o in $(OVROBJS); do echo $$o;$(LIBR) -r libovr.lib -$$o;done

#libf.lib: libf.org $(FOBJS)
#	rm -f libf.lib
#	cp libf.org libf.lib
#	$(LIBR) -r libf.lib -fprintf.obj
#	$(LIBR) -r libf.lib -fscanf.obj
#	$(LIBR) -r libf.lib -printf.obj
#	$(LIBR) -r libf.lib -scanf.obj

libf.lib: $(FOBJS)
	rm -f libf.lib
	for o in $(FOBJS); do echo $$o;$(LIBR) -r libf.lib -$$o;done

libc.lib: $(COBJS)
	rm -f libc.lib
	for o in $(COBJS); do echo $$o;$(LIBR) -r libc.lib -$$o;done

zcrt0.obj: zcrt0.as
	zxcc zas zcrt0.as

zrrt0.obj: zrrt0.as
	zxcc zas zrrt0.as

rrt0.obj: zrrt0.obj
	cp zrrt0.obj rrt0.obj

crt0.obj: zcrt0.obj
	cp zcrt0.obj crt0.obj

clean:
	-rm -f $(TOOLS) $(LIBS) $(COBJS) $(CRTOBJS) $(ZCRTOBJS) $(OVROBJS) $(TOOLSOBJS) \
        $(FOBJS) \
        test*.com test*.obj test*.out test*.sta test*.err test*.sym \
        testovrx.* test*.ovr
	-rm -rf libf

exec.com: exec.obj
	zxcc link --l --ptext=0,bss exec.obj
	zxcc objtohex --R --B100H l.obj exec.com
	-rm l.obj

symtoas.com: symtoas.obj $(LIBS) $(CRTOBJS) c.com
	zxcc c --v --r symtoas.obj

c.com: ec.obj $(LIBS) $(CRTOBJS)
	zxcc link --z --Ptext=0,data,bss --C100h --oc.com crt0.obj ec.obj libc.lib

testfile.com: testfile.c $(LIBS) $(TOOLS) $(CRTOBJS)
	zxcc c --v --r testfile.c --lc

testaes.com: testaes.c $(LIBS) $(TOOLS) $(CRTOBJS)
	zxcc c --v --r testaes.c --lc

teststr.com: teststr.c $(LIBS) $(TOOLS) $(CRTOBJS)
	zxcc c --v --r teststr.c --lc

testver.com: testver.c $(LIBS) $(TOOLS) $(CRTOBJS)
	zxcc c --v --r testver.c --lc

testio.com: testio.c $(LIBS) $(TOOLS) $(CRTOBJS)
	zxcc c --v --r testio.c 

testovr.com testovrx.sym: testovr.c $(LIBS) $(TOOLS) $(CRTOBJS)
	zxcc c --ftestovrx.sym --v --r testovr.c --lovr

testovr2.ovr: testovr2.obj testovrx.sym
	zxcc c --y --r --v testovr2.c testovrx.sym

testovr1.ovr: testovr2.obj testovrx.sym
	zxcc c --y --r --v testovr1.c testovrx.sym
	#o=`grep __ovrbgn testovr.sym |sed -e 's/ .*//g'`;\
	#xcc link --c"$$o"h --ptext=0"$$o"h,data --otestovr1.ovr testovr1.obj testovrx.obj 

testbdos.com: testbdos.c  $(LIBS) $(TOOLS) $(CRTOBJS)
	zxcc c --v --r testbdos.c

testrc.com: testrc.c  $(LIBS) $(TOOLS) $(CRTOBJS)
	zxcc c --v --r testrc.c

testuid.com: testuid.c  $(LIBS) $(TOOLS) $(CRTOBJS)
	zxcc c --v --r testuid.c

testbios.com: testbios.c  $(LIBS) $(TOOLS) $(CRTOBJS)
	zxcc c --v --r testbios.c

testtrig.com: testtrig.c  $(LIBS) $(TOOLS) $(CRTOBJS)
	zxcc c --v --r testtrig.c --lf

testftim.com: testftim.c  $(LIBS) $(TOOLS) $(CRTOBJS)
	zxcc c --v --r testftim.c

test: $(TESTS)
	zxcc testver
	rm -f testio.sta testio.out testio.err
	zxcc testovr
	zxcc teststr
	zxcc testtrig
	zxcc testftim
	zxcc testbdos
	zxcc testfile
	zxcc testaes
	zxcc testuid
	zxcc testrc || echo testrc=$$?

dist: dist/htc-bin.zip dist/htc-test.zip \
 dist/htc-bin.lha dist/htc-test.lha

dist/htc-test.zip dist/htc-test.lha: 
	mkdir -p dist
	rm -rf dist/test dist/htc-test.*
	mkdir -p dist/test
	cp test*.c dist/test
	cp test*.sub dist/test
	(cd dist/test;sh -c 'zip ../htc-test.zip *.*')
	(cd dist/test;sh -c 'lha a ../htc-test.lha *.*')
	rm -rf dist/test

dist/htc-bin.zip dist/htc-bin.lha: all
	mkdir -p dist
	rm -rf dist/htc dist/htc-test.*
	mkdir -p dist/htc
	cp $(LIBS) dist/htc
	cp $(HEADERS) dist/htc
	cp $(ORIGTOOLS) dist/htc
	cp exec.com dist/htc/\$exec.com
	cp symtoas.com dist/htc
	cp c.com dist/htc
	cp $(CRTOBJS) dist/htc
	#cp $(ZCRTOBJS) dist/htc
	cp $(DOCS) dist/htc
	(cd dist/htc;sh -c 'zip ../htc-bin.zip *.*')
	(cd dist/htc;sh -c 'lha a ../htc-bin.lha *.*')
	rm -rf dist/htc

