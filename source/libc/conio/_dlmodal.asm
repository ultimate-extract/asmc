; _DLMODAL.ASM--
;
; Copyright (c) The Asmc Contributors. All rights reserved.
; Consult your license regarding permissions and restrictions.
;
include conio.inc

    .code

    assume rbx:THWND

_dlmodal proc uses rbx hwnd:THWND, wndp:TPROC

    ldr rbx,hwnd
    mov [rbx].winproc,wndp
    or  [rbx].flags,W_WNDPROC

    [rbx].winproc(rbx, WM_CREATE, 0, 0)
    _dlsetfocus(rbx, [rbx].index)

    .new msg:MESSAGE
    .while _getmessage(&msg, NULL)

        .return .if ( eax == -1 )

        _translatemsg(&msg)
        _dispatchmsg(&msg)
    .endw

    _sendmessage(rbx, WM_CLOSE, msg.wParam, msg.lParam)
    .return( msg.wParam )

_dlmodal endp

    end
