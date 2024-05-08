; _TGETFATTR.ASM--
;
; Copyright (c) The Asmc Contributors. All rights reserved.
; Consult your license regarding permissions and restrictions.
;

include io.inc
ifdef __UNIX__
include sys/stat.inc
else
include winbase.inc
endif
include errno.inc
include tchar.inc

    .code

_tgetfattr proc file:LPTSTR

    ldr rcx,file

ifdef __UNIX__

    .new s:_stat32

    .ifd ( _stat(rcx, &s) == 0 )

        mov eax,s.st_mode
else
    .ifd ( GetFileAttributes( rcx ) == -1 )

        _dosmaperr( GetLastError() )
endif
    .endif
    ret

_tgetfattr endp

    end

