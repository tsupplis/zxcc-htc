;	arithmetic long right shift
;	value in HLDE, count in B

	global	alrsh
	psect	text

alrsh:
	ld	a,b		;check for zero shift
	or	a
	ret	z
	cp	33
	jr	c,1f		;limit shift to 32 bits
	ld	b,32
1:
	sra	h
	rr	l
	rr	d
	rr	e
	djnz	1b
	ret
