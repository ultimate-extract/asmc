; XMVECTORNEGATE.ASM--
;
; Copyright (c) The Asmc Contributors. All rights reserved.
; Consult your license regarding permissions and restrictions.
;
include DirectXMath.inc

    .code

XMVectorNegate proc XM_CALLCONV V:FXMVECTOR

    _mm_store_ps(xmm1, xmm0)
    _mm_sub_ps(_mm_setzero_ps(), xmm1)
    ret

XMVectorNegate endp

    end
