	.386
	.model flat, stdcall

	.data

	@CStr( "no return value" )
     dd @CStr( "return offset" )

	.code

	mov	eax,@CStr( "\tCreate a \"C\" string: %s%d\n" )
	mov	ebx,@CStr( "string: %s%d\n" )
	mov	ecx,@CStr( "%s%d\n" )
	mov	edx,@CStr( "%d\n" )
	mov	edi,@CStr( "\n" )

	END
