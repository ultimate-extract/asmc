include ctype.inc

    .code

    OPTION PROLOGUE:NONE, EPILOGUE:NONE

isprint proc char:SINT

    mov eax,ecx
    .if al < 0x20 || al >= 0x7F
        xor eax,eax
    .endif
    ret

isprint endp

    END

