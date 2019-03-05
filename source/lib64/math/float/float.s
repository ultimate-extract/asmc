include math.inc
include intrin.inc

comp32 macro r, p, args:vararg
  local x
    .data
    x dd r
    .code
    p(args)
    movd eax,xmm0
    mov  ebx,x
    exitm<.assert(eax == ebx)>
    endm

comp28 macro r, p, args:vararg
  local x
    .data
    x dd r
    .code
    p(args)
    movd eax,xmm0
    mov ebx,x
    and eax,0xFFFFFFF0
    and ebx,0xFFFFFFF0
    exitm<.assert(eax == ebx)>
    endm

    .code

main proc

    comp32(1.1493775572794240, coshf, -0.54)
    comp32(34.466919, expf, 3.54)
    comp32(2.0, floorf, 2.57)
    comp28(0.3, fmodf, 1.5, 1.2)
    comp32(2.0, sqrtf, 4.0)
    comp32(3.24037034920393, sqrtf, 10.5)
    comp32(12.0, roundf, 12.4)
    comp32(13.0, roundf, 12.5)
    comp32(0.4636476090008061, atan2f, 1.0, 2.0)
    comp32(3.0, ceilf, 2.5)
    comp32(0.46211715726001, tanhf, 0.5)

    xor eax,eax
    ret

main endp

    end
