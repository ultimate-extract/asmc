; STRINGCCHPRINTFEX.ASM--
;
; Copyright (c) The Asmc Contributors. All rights reserved.
; Consult your license regarding permissions and restrictions.
;

include strsafe.inc

.code

StringCchPrintfEx proc _CRTIMP uses rbx pszDest:LPTSTR, cchDest:size_t, ppszDestEnd:ptr LPTSTR,
        pcchRemaining:ptr size_t, dwFlags:DWORD, pszFormat:LPTSTR, argptr:vararg

    local hr:HRESULT

    ldr rbx,pszDest
    mov hr,StringExValidateDest(rbx, cchDest, STRSAFE_MAX_CCH, dwFlags)

    .if ( SUCCEEDED(hr) )

       .new pszDestEnd:LPTSTR = rbx
       .new cchRemaining:size_t = cchDest

        mov hr,StringExValidateSrc(&pszFormat, NULL, STRSAFE_MAX_CCH, dwFlags)

        .if (SUCCEEDED(hr))

            .if ( dwFlags & ( not STRSAFE_VALID_FLAGS ) )

                mov hr,STRSAFE_E_INVALID_PARAMETER

                .if ( cchDest != 0 )

                    mov TCHAR ptr [rbx],0
                .endif

            .elseif ( cchDest == 0 )

                ; only fail if there was actually a non-empty format string

                mov rcx,pszFormat
                .if ( TCHAR ptr [rcx] != 0 )

                    .if ( rbx == NULL )
                        mov hr,STRSAFE_E_INVALID_PARAMETER
                    .else
                        mov hr,STRSAFE_E_INSUFFICIENT_BUFFER
                    .endif
                .endif

            .else

               .new cchNewDestLength:size_t = 0

                mov hr,StringVPrintfWorker(rbx, cchDest, &cchNewDestLength, pszFormat, &argptr)
                mov rcx,cchDest
                mov rax,cchNewDestLength
                sub rcx,rax
                mov cchRemaining,rcx
ifdef _UNICODE
                add rax,rax
endif
                add rax,rbx
                mov pszDestEnd,rax

                .if ( SUCCEEDED(hr) && ( dwFlags & STRSAFE_FILL_BEHIND_NULL ) && rcx > 1 )
ifdef _UNICODE
                    add rcx,rcx
endif
                    ; safe to multiply cchRemaining * TCHAR since cchRemaining < STRSAFE_MAX_CCH
                    ; handle the STRSAFE_FILL_BEHIND_NULL flag

                    StringExHandleFillBehindNull(pszDestEnd, rcx, dwFlags)
                .endif
            .endif

        .elseif ( cchDest != 0 )

            mov TCHAR ptr [rbx],0
        .endif

        .if ( FAILED(hr) &&
              dwFlags & STRSAFE_NO_TRUNCATION or STRSAFE_FILL_ON_FAILURE or STRSAFE_NULL_ON_FAILURE &&
              cchDest != 0 )

            .new cbDest:size_t

            ; safe to multiply cchDest * TCHAR since cchDest < STRSAFE_MAX_CCH
            ; and sizeof(TCHAR) is 2

            imul rax,cchDest,TCHAR
            mov cbDest,rax

            ; handle the STRSAFE_FILL_ON_FAILURE, STRSAFE_NULL_ON_FAILURE,
            ; and STRSAFE_NO_TRUNCATION flags

            StringExHandleOtherFlags(rbx, cbDest, 0, &pszDestEnd, &cchRemaining, dwFlags)
        .endif

        .if ( SUCCEEDED(hr) || ( hr == STRSAFE_E_INSUFFICIENT_BUFFER ) )

            mov rcx,ppszDestEnd
            .if ( rcx )

                mov rax,pszDestEnd
                mov [rcx],rax
            .endif

            mov rcx,pcchRemaining
            .if ( rcx )

                mov rax,cchRemaining
                mov [rcx],rax
            .endif
        .endif
    .endif
    .return( hr )

StringCchPrintfEx endp

    end
