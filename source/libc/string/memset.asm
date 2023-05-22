; MEMSET.ASM--
;
; Copyright (c) The Asmc Contributors. All rights reserved.
; Consult your license regarding permissions and restrictions.
;

include string.inc

    .code

memset proc uses rdi dst:ptr, chr:int_t, size:size_t

    ldr     rdi,dst
    ldr     eax,chr
    ldr     rcx,size
    mov     rdx,rdi
    rep     stosb
    mov     rax,rdx
    ret

memset endp

    end
