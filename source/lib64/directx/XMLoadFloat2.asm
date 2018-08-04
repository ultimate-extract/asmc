
include DirectXMath.inc

    .code

    option win64:rsp nosave noauto

XMLoadFloat2 proc XM_CALLCONV pSource:ptr XMFLOAT2

    .assert( rcx )

    _mm_load_ss(xmm0, [rcx])
    _mm_load_ss(xmm1, [rcx+4])
    _mm_unpacklo_ps(xmm0, xmm1)
    ret

XMLoadFloat2 endp

    end
