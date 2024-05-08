; _TCSTRUNC.ASM--
;
; Copyright (c) The Asmc Contributors. All rights reserved.
; Consult your license regarding permissions and restrictions.
;
; int strtrunc(char *);
; int _wstrtrunc(wchar_t *);
;
; Skip space and trunckate end
; Return EAX char count, RCX start, and edx last char
;
include string.inc
include tchar.inc

.code

_tcstrunc proc string:LPTSTR

    ldr rcx,string

    _tcstrim(_tcsstart(rcx))
    ret

_tcstrunc endp

    end
