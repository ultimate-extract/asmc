include ctype.inc

    .code

    OPTION PROLOGUE:NONE, EPILOGUE:NONE

isdigit proc char:SINT
    lea rax,_ctype
    mov al,[rax+rcx*2+2]
    and eax,_DIGIT
    ret
isdigit endp

    end

