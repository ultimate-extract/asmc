include stdio.inc
include stdlib.inc
include tchar.inc

	.code

_tmain	proc _CDecl argc:SINT, argv:PVOID

	.for RSI = argv, edi = argc, ebx = 0: edi: edi--, ebx++, RSI += size_t

		_tprintf("[%d]: %s\n", ebx, [RSI])
	.endf
	xor	eax,eax
	ret

_tmain	endp

	end	_tstart
