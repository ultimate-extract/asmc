
include DirectXMath.inc

    .code

    option win64:rsp nosave noauto

XMVectorGetXPtr proc XM_CALLCONV x:ptr float, V:FXMVECTOR

    inl_XMVectorGetXPtr([rcx], xmm1)
    ret

XMVectorGetXPtr endp

    end
