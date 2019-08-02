; __CVTQ_H.ASM--
;
; Copyright (c) The Asmc Contributors. All rights reserved.
; Consult your license regarding permissions and restrictions.
;
; __cvtq_h() - Quad to half
;

include quadmath.inc
include errno.inc

HFLT_MAX equ 0x7BFF
HFLT_MIN equ 0x0001

    .code

__cvtq_h proc x:ptr, q:ptr

    mov r8,rcx
    mov eax,[rdx+10]
    mov cx,[rdx+14]
    .if r8 == rdx
        xor r9d,r9d
        mov [rdx],r9
        mov [rdx+8],r9
    .endif
    shr eax,1
    .if ecx & Q_EXPMASK
        or eax,0x80000000
    .endif

    mov r9d,eax         ; duplicate it
    shl r9d,H_SIGBITS+1 ; get rounding bit
    mov r9d,0xFFE00000  ; get mask of bits to keep

    .ifc                ; if have to round
        .ifz            ; - if half way between
            .if dword ptr [rdx+6] == 0
                shl r9d,1
            .endif
        .endif
        add eax,0x80000000 shr (H_SIGBITS-1)
        .ifc            ; - if exponent needs adjusting
            mov eax,0x80000000
            inc cx
            ;
            ;  check for overflow
            ;
        .endif
    .endif

    mov edx,ecx         ; save exponent and sign
    and cx,Q_EXPMASK    ; if number not 0

    .repeat

        .ifnz
            .if cx == Q_EXPMASK
                .if ( eax & 0x7FFFFFFF )

                    mov eax,-1
                    .break
                .endif
                mov eax,0x7C000000 shl 1
                shl dx,1
                rcr eax,1
                .break
            .endif
            add cx,H_EXPBIAS-Q_EXPBIAS
            .ifs
                ;
                ; underflow
                ;
                mov eax,0x00010000
                _set_errno(ERANGE)
                .break
            .endif

            .if cx >= H_EXPMASK || ( cx == H_EXPMASK-1 && eax > r9d )
                ;
                ; overflow
                ;
                mov eax,0x7BFF0000 shl 1
                shl dx,1
                rcr eax,1
                _set_errno(ERANGE)
                .break

            .endif

            and  eax,r9d ; mask off bottom bits
            shl  eax,1
            shrd eax,ecx,H_EXPBITS
            shl  dx,1
            rcr  eax,1

            .break .ifs cx || eax >= HFLT_MIN

            _set_errno(ERANGE)
            .break

        .endif
        and eax,r9d
    .until 1
    shr eax,16
    mov [r8],ax
    mov rax,r8
    ret

__cvtq_h endp

    end
