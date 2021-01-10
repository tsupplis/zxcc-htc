all: pipemgr.rsx tee.com

pipemgr.rsx: pipemgr.rel
	zxcc drlink -"pipemgr[op nr]"
	mv pipemgr.prl pipemgr.rsx

pipemgr.rel: pipemgr.z80
	zxcc slrasm -pipemgr/m

pipemgr.obj: pipemgr.c
	zxc -c pipemgr.c

tee.obj: tee.c
	zxc -c tee.c

tee.com: tee.obj pipemgr.obj
	zxc -otee.com tee.obj pipemgr.obj

clean:
	rm -f pipemgr.rel
	rm -f pipemgr.obj
	rm -f tee.obj
	rm -f tee.com
