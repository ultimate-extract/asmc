; CMMKLIST.ASM--
; Copyright (C) 2016 Doszip Developers -- see LICENSE.TXT

include doszip.inc
include string.inc
include io.inc
include iost.inc
include stdio.inc
include progress.inc
include stdlib.inc

; Make List File from selection set

PUBLIC	cp_ziplst
PUBLIC	CRLF$

externdef	format_lu:BYTE
externdef	format_lst:BYTE
externdef	filelist_bat:BYTE

MKLID_APPEND	equ 1*16
MKLID_UNIX	equ 2*16
MKLID_EXLCD	equ 3*16
MKLID_EXLDRV	equ 4*16
MKLID_EXLFILE	equ 5*16
MKLID_LIST	equ 6*16
MKLID_FORMAT	equ 7*16
MKLID_FILTER	equ 10*16

.data

$BACK db '\'		; 5C
BACK$ db '\',0		; '\'
$SIGN db '\'		; 25
SIGN$ db '%',0		; '%'
$TAB9 db '\t',0		; 09
$CRLF db '\n',0		; 0D 0A
TAB9$ db 9,0
CRLF$ db 0Dh,0Ah
NULL$ db 0

$FILE db '%f',0		; File name
$PATH db '%p',0		; Path part of file
$CURD db '%cd',0	; Current directory
$HOME db '%dz',0	; Doszip directory
$name db '%n',0		; Name part of file
$TYPE db '%ext',0	; Extension of file
$SSTR db '%s',0		; Search string
$FCID db '%id',0	; File index or loop counter
$OFFS db '%o',0		; Offset string
$TMP1 db 7,1,0		; unlikely combination 1 '\\'
$TMP2 db 7,2,0		; unlikely combination 2 '\%'

cp_ziplst db	'ziplst',0
$FORSLASH db	'/',0

mklsubcnt dd	0
cp_mklist db	'MKList',0

GCMD_mklist	dd KEY_F3, event_LOAD
		dd 0

	.code

event_LOAD PROC PRIVATE USES esi edi ebx
	local	string[256]:BYTE
	mov	ebx,tdialog
	mov	al,[ebx].S_DOBJ.dl_index
	.if al != 5 && al != 6
		mov	[ebx].S_DOBJ.dl_index,5
	.endif
	tools_idd( 128, addr string, addr cp_mklist )
	mov	esi,eax
	call	msloop
	.if esi && esi != MOUSECMD
		mov	esi,[ebx].S_TOBJ.to_data[MKLID_FORMAT]
		lea	edi,string
		.if strchr( edi, '@' )
			xchg	edi,eax
			mov	BYTE PTR [edi],0
			.if eax != edi
				strcpy( [ebx].S_TOBJ.to_data[MKLID_LIST], eax )
			.endif
			inc	edi
		.endif
		strcpy( esi, edi )
		dlinit( ebx )
	.endif
	mov	eax,_C_NORMAL
	ret
event_LOAD ENDP

mklistidd PROC USES esi edi ebx

	.if rsopen( IDD_DZMKList )
		mov	ebx,eax
		mov	esi,thelp
		mov	thelp,event_help
		tosetbitflag( [ebx].S_DOBJ.dl_object, 5, _O_FLAGB, mklist.mkl_flag )
		mov	[ebx].S_TOBJ.to_proc[MKLID_FILTER],event_filter
		mov	edi,[ebx].S_TOBJ.to_data[MKLID_LIST]
		mov	[ebx].S_TOBJ.to_data[MKLID_APPEND],offset GCMD_mklist
		strcpy( [ebx].S_TOBJ.to_data[MKLID_FORMAT], addr format_lst )
		strcpy( edi, addr filelist_bat )
		xor	eax,eax
		mov	mklist.mkl_offset,eax
		dlinit( ebx )
		.if dlevent( ebx )
			xor	eax,eax
			mov	mklist.mkl_count,eax
			or	mklist.mkl_flag,_MKL_MACRO
			togetbitflag( [ebx].S_DOBJ.dl_object, 5, _O_FLAGB )
			mov	ah,BYTE PTR mklist.mkl_flag
			and	ah,_MKL_MASK
			or	al,ah
			mov	BYTE PTR mklist.mkl_flag,al
			strcpy( addr format_lst,[ebx].S_TOBJ.to_data[MKLID_FORMAT] )
			strcpy( addr filelist_bat,edi )
			.if BYTE PTR mklist.mkl_flag & _MKL_APPEND
				.if filexist( edi )
					cmp eax,1
					mov eax,0
					.if ZERO?
						.if openfile( edi, M_WRONLY, A_OPEN )
							mov	mklist.mkl_handle,eax
							_lseek( eax, 0, SEEK_END )
							mov	eax,1
						.endif
					.endif
				.else
					ogetouth( edi, M_WRONLY )
					mov mklist.mkl_handle,eax
				.endif
			.else
				ogetouth( edi, M_WRONLY )
				mov mklist.mkl_handle,eax
			.endif
		.endif
		mov	thelp,esi
		mov	edi,eax
		dlclose( ebx )
		mov	eax,edi
		test	eax,eax
	.endif
	ret
event_help:
	mov	eax,HELPID_11
	call	view_readme
	retn
event_filter:
	call	cmfilter
	mov	edx,tdialog
	mov	dx,[edx+4]
	add	dx,0A1Ch
	mov	cl,dh
	mov	eax,' '
	.if filter
		mov al,7
	.endif
	scputw( edx, ecx, 1, eax )
	mov	eax,_C_NORMAL
	retn
mklistidd ENDP

expand_macro PROC PRIVATE
	strxchg( ebp, edx, ecx )
	ret
expand_macro ENDP

mklistadd PROC		; AX=file name
	push	ebp
	sub	esp,_MAX_PATH*3
	mov	ebp,esp
	push	esi
	push	edi
	lea	edi,[ebp+_MAX_PATH*2]
	strcpy( edi,eax )
	mov	edx,eax
	xor	eax,eax
	mov	ecx,eax
	inc	mklist.mkl_count
	.if BYTE PTR mklist.mkl_flag & _MKL_EXCL_DRV && BYTE PTR [edx+1] == ':'
		add	ecx,2
	.endif
	add	edx,ecx
	.if BYTE PTR mklist.mkl_flag & _MKL_EXCL_CD
		add	edx,mklist.mkl_offspath
		sub	edx,ecx
	.endif
	.if BYTE PTR mklist.mkl_flag & _MKL_UNIX
		dostounix( edx )
		mov	edx,eax
	.endif
	.if BYTE PTR mklist.mkl_flag & _MKL_EXCL_FILE
		strpath( edx )
	.endif
	strcpy( edi, edx )
	strcpy( ebp, addr format_lst )

	.if !( mklist.mkl_flag & _MKL_MACRO )
		strcpy( eax, edi )
	.else
		mov	eax,edx
		mov	edx,offset $BACK	; '\\'
		mov	ecx,offset $TMP1	; --> 07 01
		call	expand_macro
		mov	edx,offset $CRLF	; '\n'
		mov	ecx,offset CRLF$	; --> 0D 0A
		call	expand_macro
		mov	edx,offset $TAB9	; '\t'
		mov	ecx,offset TAB9$	; --> 09
		call	expand_macro
		mov	edx,offset $SIGN	; '\%'
		mov	ecx,offset $TMP2	; --> 07 02
		call	expand_macro
		mov	edx,offset $TMP1	; 07 01
		mov	ecx,offset BACK$	; --> '\'
		call	expand_macro
		mov	edx,offset $HOME
		mov	ecx,_pgmpath
		call	expand_macro
		mov	edx,offset $FILE
		mov	ecx,edi
		call	expand_macro
		strfn ( edi )
		mov	esi,eax
		strext( eax )
		mov	edi,eax
		.if ZERO?
			lea eax,NULL$
		.endif
		mov	ecx,eax
		mov	edx,offset $TYPE
		call	expand_macro
		xor	eax,eax
		.if edi
			mov [edi],al
		.endif
		mov	ecx,esi
		mov	edx,offset $name
		call	expand_macro
		lea	edi,[ebp+_MAX_PATH*2]
		.if esi != edi
			mov	ecx,edi
			xor	eax,eax
			mov	[esi-1],al
		.else
			mov	ecx,offset NULL$
		.endif
		mov	edx,offset $PATH
		call	expand_macro
		xor	eax,eax
		mov	ecx,edi
		mov	edx,edi
		add	edx,mklist.mkl_offspath
		.if edx != ecx
			dec	edx
		.endif
		mov	[edx],al
		mov	edx,offset $CURD
		call	expand_macro
		mov	edx,offset $SSTR
		mov	ecx,offset searchstring
		call	expand_macro
		mov	eax,mklist.mkl_count
		dec	eax
		sprintf( edi, "%u", eax )
		mov	edx,offset $FCID
		mov	ecx,edi
		call	expand_macro
		sprintf( edi, addr format_lu, mklist.mkl_offset )
		mov	edx,offset $OFFS
		mov	ecx,edi
		call	expand_macro
		mov	edx,offset $TMP2 ; 07 02 00
		mov	ecx,offset SIGN$ ; --> '%'
		call	expand_macro
	.endif
	.if oswrite( mklist.mkl_handle, ebp, strlen( ebp ) )
		xor	eax,eax
		.if !( mklist.mkl_flag & _MKL_MACRO )
			oswrite( mklist.mkl_handle, addr CRLF$, 2 )
			sub	eax,2
			.if !ZERO?
				inc	eax
			.endif
		.endif
	.else
		inc	eax
	.endif
	pop	edi
	pop	esi
	add	esp,_MAX_PATH*3
	pop	ebp
	test	eax,eax
	ret
mklistadd ENDP

fp_mklist PROC PRIVATE path, wblk
	.if filter_wblk( wblk )
		mov	eax,wblk
		add	eax,S_WFBLK.wf_name
		.if !progress_set( 0, strfcat( __srcfile, path, eax ), 1 )
			mov	eax,__srcfile
			call	mklistadd
		.endif
	.endif
	ret
fp_mklist ENDP

mksublist PROC PRIVATE USES esi edi zip_list, path

	or	mklist.mkl_flag,_MKL_MACRO

	.if zip_list == 1
		or  mklist.mkl_flag,_MKL_EXCL_CD
		lea eax,cp_ziplst
		xor mklist.mkl_flag,_MKL_MACRO
	.else
		mklistidd()
		lea eax,filelist_bat
		jz  toend
	.endif
	progress_open( eax, 0 )
	strlen( path )
	mov edx,path
	add edx,eax
	mov fp_fileblock,offset fp_mklist
	mov fp_directory,offset scan_files

	.if BYTE PTR [edx-1] != '\'

		inc eax
	.endif
	mov mklist.mkl_offspath,eax

	.if cpanel_findfirst()

		.if ecx & _FB_ARCHEXT

			mov mklist.mkl_offspath,0
		.endif

		.repeat

			mov edi,ecx
			mov esi,edx

			.break .if progress_set( 0, strfcat( __outpath, path, eax ), 1 )

			.if edi & _A_SUBDIR

				.if edi & _FB_ARCHIVE

					strcat( __outpath, addr BACK$ )
					.if BYTE PTR mklist.mkl_flag & _MKL_MASK

						mov edx,cpanel
						mov edx,[edx].S_PANEL.pn_wsub
						strcat( eax, [edx].S_WSUB.ws_mask )
					.endif
					mklistadd()
					inc mklsubcnt
				.else
					.break .if scansub( __outpath, addr cp_stdmask, 0 )
				.endif
			.else
				.if filter_fblk( esi )

					mov eax,__outpath
					mklistadd()
				.endif
			.endif
			and [esi].S_FBLK.fb_flag,not _FB_SELECTED
			panel_findnext(cpanel)
		.untilz
	.endif
	push eax
	progress_close()
	_close( mklist.mkl_handle )
	pop eax
toend:
	ret
mksublist ENDP

mkwslist PROC PRIVATE USES esi

	mov	esi,eax

	.if cpanel_findfirst()

		mov	eax,cpanel
		mov	edx,[eax].S_PANEL.pn_wsub
		mov	eax,[edx].S_WSUB.ws_flag

		.if eax & _W_ARCHIVE
			mov edx,[edx].S_WSUB.ws_arch
		.else
			mov edx,[edx].S_WSUB.ws_path
		.endif

		mksublist( esi, edx )
	.endif
	ret
mkwslist ENDP

cmmklist PROC
	sub	eax,eax
	call	mkwslist
	ret
cmmklist ENDP

mkziplst_open PROC
	sub	esp,_MAX_PATH
	mov	eax,esp
	ogetouth( strfcat( eax, envtemp, addr cp_ziplst ), M_WRONLY )
	mov	edx,esp
	add	esp,_MAX_PATH
	mov	mklist.mkl_handle,eax
	.if eax
		inc eax
		.if eax
			or  cflag,_C_DELTEMP
			mov eax,1
		.endif
	.endif
	ret
mkziplst_open ENDP

mkziplst PROC
	xor	eax,eax
	mov	mklsubcnt,eax
	inc	eax
	call	mkwslist
	mov	edx,mklsubcnt
	ret
mkziplst ENDP

	END
