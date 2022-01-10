.SUFFIXES: .obj .c .as
CFLAGS=--o
ASFLAGS=--j
TAG=$(shell ((git describe --exact-match --tags $(git log -n1 --pretty='%h') 2>/dev/null) \
    || (git tag|tail -n 1|sed -e 's/$$/-dev/') || echo "vdev" ) |grep ^v| \
        sed -e 's/\|/-/g' | \
        sed -e 's/^$$/UNKNOWN/g' -e 's/^v//g' )

.c.obj:
	zxcc oc --v $(CFLAGS) --c $*.c

.as.obj: 
	zxcc zas $(ASFLAGS) $*.as

TESTS=testver.com testio.com testovr.com testovr1.ovr testovr2.ovr teststr.com \
 testbios.com testbdos.com testtrig.com testftim.com testfile.com testaes.com \
 testuid.com testrc.com testrel.com testargs.com testfsiz.com testsub.com

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
strncmp.obj strnicmp.obj strncpy.obj csv.obj rcsv.obj tolower.obj \
toupper.obj xtoi.obj newfsiz.obj mktime.obj

FOBJS=printf.obj fprintf.obj sprintf.obj scanf.obj fscanf.obj sscanf.obj fdoprnt.obj \
 fdoscan.obj atof.obj fnum.obj fbcd.obj tan.obj acos.obj asin.obj atan2.obj atan.obj \
 cos.obj sin.obj sinh.obj cosh.obj tanh.obj exp.obj log.obj evalpoly.obj sqrt.obj \
 frexp.obj fabs.obj ceil.obj floor.obj finc.obj asfloat.obj frndint.obj ftol.obj \
 ltof.obj float.obj

DOCS=htc.txt options.txt z80doc.txt readme.txt
HEADERS=assert.h cpm.h exec.h hitech.h math.h setjmp.h stat.h stddef.h stdio.h \
  string.h time.h unixio.h conio.h ctype.h float.h limits.h overlay.h signal.h \
  stdarg.h stdint.h stdlib.h sys.h unistd.h stdio.i
ORIGTOOLS=cgen.com cpp.com cref.com debug.com  \
	libr.com link.com objtohex.com optim.com p1.com \
	zas.com

OVROBJS=ovrload.obj ovrbgn.obj
CRTOBJS=crtcpm.obj rrtcpm.obj wcr.obj
ZCRTOBJS=zcrtcpm.obj zrrtcpm.obj
TOOLSOBJS=ec.obj symtoas.obj exec.obj
LIBS=libc.lib libovr.lib libf.lib
TOOLS=c.com symtoas.com enhuff.com dehuff.com

all: $(LIBS) $(CRTOBJS) $(TOOLS) $$exec.com

libovr.lib:	$(OVROBJS)
	rm -f libovr.lib
	for o in $(OVROBJS); do echo $$o;zxcc libr -r libovr.lib -$$o;done

libf.lib: $(FOBJS)
	rm -f libf.lib
	for o in $(FOBJS); do echo $$o;zxcc libr -r libf.lib -$$o;done

libc.lib: $(COBJS)
	rm -f libc.lib
	for o in $(COBJS); do echo $$o;zxcc libr -r libc.lib -$$o;done

zcrtcpm.obj: zcrtcpm.as
	zxcc zas zcrtcpm.as

wcr.obj: wcr.as
	zxcc zas wcr.as

zrrtcpm.obj: zrrtcpm.as
	zxcc zas zrrtcpm.as

rrtcpm.obj: zrrtcpm.obj
	cp zrrtcpm.obj rrtcpm.obj

crtcpm.obj: zcrtcpm.obj
	cp zcrtcpm.obj crtcpm.obj

clean:
	-rm -f $(TOOLS) '$$exec.com' $(LIBS) $(COBJS) $(CRTOBJS) $(ZCRTOBJS) $(OVROBJS) $(TOOLSOBJS) \
        $(FOBJS) \
        test*.com test*.obj test*.out test*.sta test*.err test*.sym \
        testovrx.* test*.ovr
	-rm -f encode.obj decode.obj enhuff.obj dehuff.obj hmisc.obj
	-rm -f enhuff.com dehuff.com
	-rm -rf libf
	-rm -rf *.dat

$$exec.com: exec.obj
	zxcc link --l --ptext=0,bss exec.obj libc.lib
	zxcc objtohex --R --B100H l.obj exec.com
	mv exec.com '$$exec.com'
	-rm l.obj

symtoas.com: symtoas.obj $(LIBS) $(CRTOBJS) c.com
	zxcc c --v --r symtoas.obj

ec.obj: ec.c
	echo TAG=$(TAG)
	cat ec.c|sed -e 's|@@TAG@@|$(TAG)|' > '$$c.c'
	zxcc oc --DTAG=$(TAG) --v $(CFLAGS) --c '$$c.c'
	rm -f '$$c.c'
	mv '$$c.obj' ec.obj

c.com: ec.obj $(LIBS) $(CRTOBJS) $$exec.com
	zxcc link --z --Ptext=0,data,bss --C100h --oc.com crtcpm.obj ec.obj libc.lib

enhuff.com: enhuff.obj encode.obj hmisc.obj $(LIBS) c.com $(CRTOBJS)
	zxcc c --v --r --of enhuff.obj encode.obj hmisc.obj

dehuff.com: dehuff.obj decode.obj hmisc.obj $(LIBS) c.com $(CRTOBJS)
	zxcc c --v --r --of dehuff.obj decode.obj hmisc.obj

testfile.com: testfile.c $(LIBS) $(TOOLS) $(CRTOBJS)
	zxcc c --v --r testfile.c

testfsiz.com: testfsiz.c $(LIBS) $(TOOLS) $(CRTOBJS)
	zxcc c --v --r testfsiz.c

testaes.com: testaes.c $(LIBS) $(TOOLS) $(CRTOBJS)
	zxcc c --v --r testaes.c

teststr.com: teststr.c $(LIBS) $(TOOLS) $(CRTOBJS)
	zxcc c --v --r teststr.c

testver.com: testver.c $(LIBS) $(TOOLS) $(CRTOBJS)
	zxcc c --v --r testver.c

testio.com: testio.c $(LIBS) $(TOOLS) $(CRTOBJS)
	zxcc c --v --r testio.c 

testovr.com testovrx.sym: testovr.c $(LIBS) $(TOOLS) $(CRTOBJS)
	zxcc c --ftestovrx.sym --v --r testovr.c --lovr

testovr2.ovr: testovr2.obj testovrx.sym
	zxcc c --y --r --v testovr2.c testovrx.sym

testovr1.ovr: testovr2.obj testovrx.sym
	zxcc c --y --r --v testovr1.c testovrx.sym

testbdos.com: testbdos.c  $(LIBS) $(TOOLS) $(CRTOBJS)
	zxcc c --v --r testbdos.c

testsub.com: testsub.c  $(LIBS) $(TOOLS) $(CRTOBJS)
	zxcc c --v --r testsub.c

testargs.com: testargs.c  $(LIBS) $(TOOLS) $(CRTOBJS)
	zxcc c --v --r testargs.c

testrel.com: testrel.c  $(LIBS) $(TOOLS) $(CRTOBJS)
	zxcc c --A --v --r testrel.c

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
	zxcc testargs -*.i
	zxcc testfsiz

dist: dist/htc-bin-$(TAG).zip dist/htc-test-$(TAG).zip \
 dist/htc-bin-$(TAG).lbr dist/htc-test-$(TAG).lbr

dist/htc-test-$(TAG).zip dist/htc-test-$(TAG).lbr:
	mkdir -p dist
	rm -rf dist/test dist/htc-test*
	mkdir -p dist/test
	cp test*.c dist/test
	cp test*.sub dist/test
	(cd dist;sh -c 'zip -r htc-test-$(TAG).zip test')
	(cd dist/test; \
        cp ../../empty.lbr temp.lbr ;\
        zxcc lu --O temp.lbr --A 'TEST*.*' --C ;\
        mv temp.lbr ../htc-test-$(TAG).lbr ;\
    )
	rm -rf dist/test

dist/htc-bin-$(TAG).zip dist/htc-bin-$(TAG).lbr: all
	mkdir -p dist
	rm -rf dist/htc dist/htc-bin*
	mkdir -p dist/htc
	cp $(LIBS) dist/htc
	cp $(HEADERS) dist/htc
	cp $(ORIGTOOLS) dist/htc
	cp '$$exec.com' dist/htc/'$$exec.com'
	cp symtoas.com dist/htc
	cp c.com dist/htc
	cp enhuff.com dehuff.com dist/htc
	cp $(CRTOBJS) dist/htc
	cp $(DOCS) dist/htc
	cp options.txt dist/htc/options
	cp pipemgr/pipemgr.rsx pipemgr/tee.com dist/htc
	rm -rf dist/cpm
	mkdir -p dist/cpm/bin80
	mkdir -p dist/cpm/lib80
	mkdir -p dist/cpm/include80
	cp $(LIBS) dist/cpm/lib80
	cp $(HEADERS) dist/cpm/include80
	cp $(ORIGTOOLS) dist/cpm/bin80
	cp '$$exec.com' dist/cpm/bin80/'$$exec.com'
	cp symtoas.com dist/cpm/bin80
	cp options.txt dist/cpm/bin80/options
	cp c.com dist/cpm/bin80
	cp enhuff.com dehuff.com dist/cpm/bin80
	cp $(CRTOBJS) dist/cpm/lib80
	cp $(DOCS) dist/cpm
	cp pipemgr/pipemgr.rsx pipemgr/tee.com dist/cpm/bin80
	(cd dist;sh -c 'zip -r htc-bin-$(TAG).zip cpm')
	(cd dist/htc; \
        cp ../../empty.lbr temp.lbr ;\
        zxcc lu --O temp.lbr --A '*.COM' --C ;\
        zxcc lu --O temp.lbr --A '*.H' --C ;\
        zxcc lu --O temp.lbr --A '*.I' --C ;\
        zxcc lu --O temp.lbr --A '*.LIB' --C ;\
        zxcc lu --O temp.lbr --A '*.OBJ' --C ;\
        zxcc lu --O temp.lbr --A '*.RSX' --C ;\
        zxcc lu --O temp.lbr --A '*.TXT' --C ;\
        mv temp.lbr ../htc-bin-$(TAG).lbr ;\
    )
	rm -rf dist/htc
	rm -rf dist/cpm


