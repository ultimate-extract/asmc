include ctype.inc

    .code

    OPTION PROLOGUE:NONE, EPILOGUE:NONE

isascii proc char:SINT
    mov eax,ecx
    and eax,80h
    setz al
    ret
isascii endp

    end

