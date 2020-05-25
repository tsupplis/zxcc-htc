;	char bdos(func, arg)

	global	csv,cret,_errno

entry	equ	5		; CP/M entry point

arg	equ	8		;argument to call
func	equ	6		;desired function

	global	_bdos,_bdose,__passwd,__dpass,_exit

	psect	data
__passwd:
	defw	__dpass

	psect	text
_bdos:
	call	csv
	ld	e,(ix+arg)
	ld	d,(ix+arg+1)
	ld	c,(ix+func)
	push	ix
	push	iy
	call	entry
	pop	iy
	pop	ix
	ld	l,a
	rla
	sbc	a,a
	ld	h,a
	jp	cret
    ;
__dpass:
	ld	hl,0
	ret
;
_bdose:
	call	csv
	xor	a
	ld	(_errno),a
retry:
	ld	e,(ix+arg)
	ld	d,(ix+arg+1)
	ld	c,(ix+func)
	push	ix
	push	iy
	call	entry
	pop	iy
	pop	ix
	cp	0ffh	;Hardware error?
	jr	nz,bdos2
	ld	a,h
	cp	7	;Password error?
	jr	nz,bdos0
	ld	e,(ix+arg)
	ld	d,(ix+arg+1)	;DE -> FCB
	push	de
	ld	bc,pwret
	push	bc		;Return address
	ld	hl,(__passwd)
	jp	(hl)
;		
pwret:	ld	a,h
	or	l
	ld	a,7
	jr	z,bdos0
	ex	de,hl		;DE=password address
	ld	c,1Ah
	push	ix
	push	iy
	call	entry		;Point DMA at the password
	pop	iy
	pop	ix
	jp	retry
;
bdos0:	add	a,16
bdos1:	ld	(_errno),a
	ld	a,-1
bdos2:	ld	l,a
	rla
	sbc	a,a
	ld	h,a
	jp	cret
