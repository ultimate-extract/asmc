include stdio.inc
include string.inc
include asmc.inc
include token.inc
include hll.inc

SIZE_DATAPTR    equ 0x68

SymLCreate      proto :string_t
GetQualifiedType proto :ptr int_t, :ptr asm_tok, :ptr qualified_type
SetLocalOffsets proto :ptr proc_info

qualified_type  struc
size            sdword ?
symtype         LPASYM ?
mem_type        db ?
is_ptr          db ?
is_far          db ?
Ofssize         db ?
ptr_memtype     db ?
qualified_type  ends

    .code

    assume ebx:ptr asmtok
    tokid macro operator
      ifnb <operator>
        inc i
        add ebx,16
      else
        mov ebx,i
        shl ebx,4
        add ebx,tokenarray
      endif
        retm<ebx>
        endm

AddLocalDir proc uses esi edi ebx i:sdword, tokenarray:ptr asmtok

  local name                :ptr sbyte,
        sym                 :ptr dsym,
        ti                  :qualified_type,
        opndx               :expr,
        constructor[128]    :sbyte ; class_class

    .repeat

        inc i  ; go past directive
        tokid()

        .while 1

            .if ( [ebx].token != T_ID )

                asmerr(2008, [ebx].string_ptr )
                .break(1)
            .endif

            mov name,[ebx].string_ptr

            mov ti.symtype,NULL
            mov ti.is_ptr,0
            mov ti.ptr_memtype,MT_EMPTY

            mov cl,ModuleInfo._model
            mov eax,1
            shl eax,cl
            .if ( eax & SIZE_DATAPTR )
                mov ti.is_far,TRUE
            .else
                mov ti.is_far,FALSE
            .endif

            mov ti.Ofssize,ModuleInfo.Ofssize

            .if !SymFind( name )

                SymLCreate( name )
            .endif
            mov sym,eax

            .if( !eax ) ; if it failed, an error msg has been written already

                mov eax,ERROR
                .break(1)
            .endif

            mov [eax].asym.state,SYM_STACK
            or  [eax].asym.flag,SFL_ISDEFINED
            mov [eax].asym.total_length,1

            .switch ( ti.Ofssize )
            .case USE16
                mov [eax].dsym.sym.mem_type,MT_WORD
                mov ti.size,sizeof( word )
                .endc
            .default
                mov [eax].dsym.sym.mem_type,MT_DWORD
                mov ti.size,sizeof( dword )
                .endc
            .endsw

            tokid(++) ; go past name
            ;
            ; .new name<[xx]>
            ;
            .if( [ebx].token == T_OP_SQ_BRACKET )

                .for ( i++,         ; go past '['
                       ebx += 16,
                       esi = ebx,
                       edi = i : edi < Token_Count: edi++, ebx += 16 )

                    .break .if ( [ebx].token == T_COMMA || [ebx].token == T_COLON )
                .endf
                .break(1) .if EvalOperand( &i, tokenarray, edi, &opndx, 0 ) == ERROR

                .if ( opndx.kind != EXPR_CONST )

                    asmerr( 2026 )
                    mov opndx.value,1
                .endif

                mov ecx,sym
                mov [ecx].asym.total_length,opndx.value
                or  [ecx].asym.flag,SFL_ISARRAY

                .if( [tokid()].token == T_CL_SQ_BRACKET )

                    tokid(++) ; go past ']'
                .else
                    asmerr( 2045 )
                .endif
            .endif

            mov esi,sym
            assume esi:ptr asym
            ;
            ; .new name[xx]:<type>
            ;
            .if( [ebx].token == T_COLON )

                inc i
                .break(1) .if ( GetQualifiedType( &i, tokenarray, &ti ) == ERROR )

                mov [esi].mem_type,ti.mem_type
                .if ( ti.mem_type == MT_TYPE )
                    mov [esi].type,ti.symtype
                .else
                    mov [esi].target_type,ti.symtype
                .endif
            .endif

            mov [esi].is_ptr,ti.is_ptr
            .if ti.is_far
                or [esi].sint_flag,SINT_ISFAR
            .endif
            mov [esi].Ofssize,ti.Ofssize
            mov [esi].ptr_memtype,ti.ptr_memtype
            mov eax,ti.size
            mul [esi].total_length
            mov [esi].total_size,eax

            assume esi:nothing

            .if ( Parse_Pass == PASS_1 )

                mov eax,CurrProc
                mov edx,[eax].dsym.procinfo

                .if( [edx].proc_info.locallist == NULL )

                    mov [edx].proc_info.locallist,esi

                .else
                    .for( ecx = [edx].proc_info.locallist : [ecx].dsym.nextlocal :,
                          ecx = [ecx].dsym.nextlocal )
                    .endf
                    mov [ecx].dsym.nextlocal,esi
                .endif
            .endif

            .if ( [tokid()].token != T_FINAL )

                .if ( [ebx].token == T_COMMA )

                    mov eax,i
                    inc eax
                    .if ( eax < Token_Count )

                        tokid(++)
                    .endif

                .elseif ( [ebx].token == T_OP_BRACKET )

                    lea edi,[ebx-16]
                    mov esi,[ebx-16].string_ptr

                    tokid(++) ; go past '('
                    .for ( eax = 1 : [ebx].token != T_FINAL : ebx += 16, i++ )
                        .if ( [ebx].token == T_OP_BRACKET )
                            inc eax
                        .elseif ( [ebx].token == T_CL_BRACKET )
                            dec eax
                            .break .ifz
                        .endif
                    .endf
                    .if( [ebx].token == T_CL_BRACKET )

                        tokid(++) ; go past ')'
                    .else
                        asmerr( 2045 )
                        .break(1)
                    .endif

                    mov esi,strcat(strcat(strcpy(&constructor, esi), "_"), esi)

                    .if ( Parse_Pass > PASS_1 )

                        .if SymFind( esi )

                            .if ( [eax].asym.state == SYM_UNDEFINED )
                                ;
                                ; x::x proto
                                ;
                                ; undef x_x
                                ; x_x macro this
                                ;
                                mov [eax].asym.state,SYM_MACRO
                            .endif
                        .endif
                    .endif

                    .if ( [ebx-32].token == T_OP_BRACKET )

                        .if ( [edi-16].asmtok.token == T_COLON )

                            AddLineQueueX( "%s(&%s)", esi, name )
                        .else

                            AddLineQueueX( "mov %s,%s(0)", name, esi )
                        .endif
                    .else

                        mov eax,[ebx-16].tokpos
                        mov byte ptr [eax],0

                        .if ( [edi-16].asmtok.token == T_COLON )

                            AddLineQueueX( "%s(&%s, %s)", esi, name, [edi+32].asmtok.tokpos )
                        .else

                            AddLineQueueX( "mov %s,%s(0, %s)", name, esi, [edi+32].asmtok.tokpos )
                        .endif

                        mov eax,[ebx-16].tokpos
                        mov byte ptr [eax],')'
                    .endif

                .else
                    asmerr( 2065, "," )
                    .break(1)
                .endif
            .endif
            mov eax,i
            .break .if !( eax < Token_Count )
        .endw

        .if ( Parse_Pass == PASS_1 )
            mov eax,CurrProc
            SetLocalOffsets([eax].dsym.procinfo)
        .endif
        mov eax,NOT_ERROR
    .until 1
    ret

AddLocalDir endp

NewDirective proc i:int_t, tokenarray:ptr asmtok

  local rc:int_t

    .repeat

        .if( CurrProc == NULL )

            asmerr( 2012 )
            .break
        .endif
        mov rc,AddLocalDir(i, tokenarray)
        .if ModuleInfo.list
            LstWrite( LSTTYPE_DIRECTIVE, GetCurrOffset(), 0 )
        .endif
        .if ModuleInfo.line_queue.head
            RunLineQueue()
        .endif
        mov eax,rc
    .until 1
    ret

NewDirective endp

    END
