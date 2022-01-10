	psect	text,global,pure
	psect	data,global
	psect	bss,global

	psect	text
	defs	100h		;Base of CP/M's TPA

    global  __getargs

