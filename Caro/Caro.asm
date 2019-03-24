;Subsystem: window
;Entry point: WinMainCRTStartup

TITLE QUOC-CUONG_12-5-2017

;////////////////////////////Window API///////////////////////////
EXTRN RegisterClassExA:	PROC
EXTRN CreateWindowExA:	PROC
EXTRN ShowWindow:		PROC
EXTRN ExitProcess:		PROC
EXTRN DefWindowProcA:	PROC
EXTRN GetMessageA:		PROC
EXTRN SendMessageA:		PROC
EXTRN DispatchMessageA:	PROC
EXTRN PostQuitMessage:	PROC
EXTRN GetLastError:		PROC
EXTRN MoveToEx:			PROC
EXTRN LineTo:			PROC
EXTRN CreatePen:		PROC
EXTRN SelectObject:		PROC
EXTRN GetStockObject:	PROC
EXTRN Rectangle:		PROC
EXTRN MessageBoxA:		PROC
EXTRN CreateSolidBrush:	PROC
EXTRN Ellipse:			PROC
EXTRN GetDC:			PROC
EXTRN CreateThread:		PROC	
EXTRN SuspendThread:	PROC
EXTRN Sleep:			PROC
EXTRN ResumeThread:		PROC
EXTRN GetSystemTime:	PROC
EXTRN LoadLibraryA:		PROC
EXTRN GetModuleHandleA:	PROC
EXTRN GetProcAddress:	PROC
EXTRN SetWindowTextA:	PROC

;Window class
WNDCLASSEXA STRUCT
	cbSize			DD		?
	cbStyle			DD		?
	lpfWndProc		DQ		?
	cbClsExtra		DD		?
	cbWndExtra		DD		?
	hInstance		DQ		?
	hIcon			DQ		?
	hCursor			DQ		?
	hbrBackground	DQ		?
	lpszMenuName	DQ		?
	lpszClassName	DQ		?
	hIconSm			DQ		?
WNDCLASSEXA ENDS

;Rect window
RECTWND STRUCT
	left		DQ		?
	top			DQ		?
	_dx			DQ		?
	_dy			DQ		?
RECTWND ENDS

;Location
POINT STRUCT
	X		DD		?
	Y		DD		?
POINT ENDS

;Window message
MESSAGE	STRUCT
	hwnd	DQ		?
	message	DD		?
	wParam	DQ		?
	lParam	DQ		?
	time	DD		?
	pt		POINT	<>
MESSAGE	ENDS

;Rect
RECT STRUCT
	left	DD		?
	top		DD		?
RECT ENDS

;Window pen
MYPEN STRUCT
	green	DQ		?
	red		DQ		?
	blue	DQ		?
	yellow	DQ		?
	black	DQ		?
	white	DQ		?
	magenta	DQ		?
MYPEN ENDS

;System time
SYSTEMTIME STRUCT
	year			WORD	?
	month			WORD	?
	dayOfWeek		WORD	?
	day				WORD	?
	hour			WORD	?
	minute			WORD	?
	second			WORD	?
	milliseconds	WORD	?
SYSTEMTIME ENDS

.CONST
	;User controls
	IDB_BTNQUIT			equ		1000
	IDB_BTNNEW			equ		1001
	IDB_BTNCOMPMODE		equ		1002
	ID_PROGRESSBAR		equ		1003

	;Window/Controls styles
	PBS_SMOOTH			equ		1
	PBS_VERTICAL		equ		4
	CS_VREDRAW			equ		1
	CS_HREDRAW			equ		2 
	COLOR_WINDOW		equ		5
	WS_VISIBLE			equ		10000000h
	WS_CHILD			equ		40000000h
	WS_OVERLAPPEDWINDOW equ		0FC0000h
	SW_SHOWNORMAL		equ		1

	;Window messages
	WM_CREATE			equ		1h
	WM_DESTROY			equ		2h
	WM_COMMAND			equ		111h
	WM_LBUTTONUP        equ		202h

	;Others
	MB_CANCEL			equ		2h
	PS_SOLID			equ		0h
	NULL_BRUSH			equ		5h

	;Game
	CHESS_SQUARE		equ		25
	INFINITE_TIME		equ		0FFFFFFFFh
	PLAYER_VS_PLAYER	equ		0
	PLAYER_VS_COMP		equ		1

.DATA
	;Window/controls text
	szClassName		db		"QuocCuong", 0
	szTitle			db		"Caro - QuocCuong", 0
	szBtnClassName	db		"Button", 0
	szProgbarClassName	db	"msctls_progress32", 0
	szBtnQuit		db		"Quit", 0
	szAskMsg		db		"Are you sure?", 0
	szCompMode		db		"Player Vs Computer", 0
	szNoCompMode	db		"Player Vs Player", 0
	szBtnNew		db		"New Game", 0	
	szWinMsg		db		"We have a winner!!!", 0
	szXWin			db		"X", 0
	szOWin			db		"O", 0

	;Window size - chessboard location
	windowRect		RECTWND	<50, 50, 1120, 670>
	chessBoard		RECT	<100, 50>

	array			DB		400 dup(?)		;store 0 =' ', 1 = 'X', 2 ='0' 
	player			BYTE	1
	CompMode		BYTE	PLAYER_VS_COMP
	time_out		DD		10000

.DATA?
	;Create window/controls
	hInstance		DQ				?
	wcex			WNDCLASSEXA		<>
	hWnd			DQ				?
	msg				MESSAGE			<>
	hWndBtnCompMode	DQ				?
	hProgressBar	DQ				?

	;Drawing
	hdc				DQ				?
	hPen			MYPEN			<>
	lineLength		DD				?

	hTimer			DQ				?
	systime			SYSTEMTIME		<>
	timer			DD				?

.CODE
;/////////////////////////////wWinMain////////////////////////////
WinMainCRTStartup PROC	;(hInstance, hPrevInstance, lpCmdLine, nCmdShow) -> nExitCode
	push rbp
	mov rbp, rsp
	
	;Register new window class
	mov		hInstance, rcx
	Call	RegisterNewClass

	;Init window/controls - first game
	Call	InitWindow
	Call	CreateElementWindow

@MessageLoop:
	sub rsp, 20h
	lea rcx, msg
	mov rdx, 0
	mov r8, 0
	mov r9, 0
	call GetMessageA ;(msg, hWnd, 0, 0) -> (0 = Quit)
	add rsp, 20h

	cmp rax, 0
	je @Quit
	sub rsp, 10h
	lea rcx , msg
	call DispatchMessageA
	add rsp, 10h
	jmp @MessageLoop
@Quit:
	sub rsp, 10h
	xor rcx, rcx
	Call ExitProcess
	add rsp, 10h

	leave
	ret
WinMainCRTStartup ENDP

;////////////////////////REGISTER_CLASS///////////////////////////
RegisterNewClass PROC	;wcex -> void
	push rbp
	mov rbp, rsp

	sub rsp, 50h
	mov wcex.cbSize, sizeof WNDCLASSEXA
	mov	wcex.cbStyle, CS_HREDRAW or CS_VREDRAW
	lea rax, WndProc
	mov wcex.lpfWndProc, rax
	mov wcex.cbClsExtra, 0
	mov wcex.cbWndExtra, 0
	mov wcex.hInstance, rcx
	mov wcex.hIcon, 0
	mov wcex.hCursor, 0
	mov wcex.hbrBackground, COLOR_WINDOW + 3
	mov wcex.lpszMenuName, 0
	lea rax, szClassName
	mov wcex.lpszClassName, rax 
	mov wcex.hIconSm, 0

	lea rcx, wcex
	Call RegisterClassExA
	add rsp, 50h

	leave
	ret
RegisterNewClass ENDP

;/////////////////////////INIT_WINDOW/////////////////////////////
InitWindow PROC		;void -> void
	push rbp
	mov rbp, rsp

	push 0
	push hInstance
	push 0
	push 0
	push windowRect._dy
	push windowRect._dx
	push windowRect.top
	push windowRect.left
	sub rsp, 20h
	mov r9, WS_OVERLAPPEDWINDOW
	lea r8, szTitle
	lea rdx, szClassName
	mov rcx, 0
	
	Call CreateWindowExA
	mov hWnd, rax

	;Show Window
	mov rcx, hWnd
	mov rdx, SW_SHOWNORMAL
	Call ShowWindow		;(hWnd, nCmdShow) -> void
	add rsp, 60h

	leave
	Ret
InitWindow ENDP

;/////////////////////CREATE_ELEMENT_WINDOW//////////////////////
CreateElementWindow	PROC	;void -> void
	push rbp
	mov rbp, rsp

	;Create quit button
	push 0
	push 0
	push IDB_BTNQUIT
	push hWnd
	push 35
	push 110
	push 510
	push 900
	sub rsp, 20h
	mov rcx, 0
	lea rdx, szBtnClassName
	lea	r8, szBtnQuit
	mov r9, WS_VISIBLE or WS_CHILD
	call CreateWindowExA
	add rsp, 60h

	;Create button new game
	push 0
	push 0
	push IDB_BTNNEW
	push hWnd
	push 35
	push 110
	push 510
	push 750
	sub rsp, 20h
	mov rcx, 0
	lea rdx, szBtnClassName
	lea	r8, szBtnNew
	mov r9, WS_VISIBLE or WS_CHILD
	call CreateWindowExA
	add rsp, 60h

	;Create button change mode
	push 0
	push 0
	push IDB_BTNCOMPMODE
	push hWnd
	push 40
	push 150
	push 420
	push 800
	sub rsp, 20h
	mov rcx, 0
	lea rdx, szBtnClassName
	lea	r8, szCompMode
	mov r9, WS_VISIBLE or WS_CHILD
	call CreateWindowExA
	mov hWndBtnCompMode, rax
	add rsp, 60h

	;Create progress bar
	push 0
	push hInstance
	push ID_PROGRESSBAR
	push hWnd
	push 500
	push 10
	push 50
	push 650
	sub rsp, 20h
	mov rcx, 0
	lea rdx, szProgbarClassName
	mov	r8, 0
	mov r9, WS_VISIBLE or WS_CHILD or PBS_SMOOTH or PBS_VERTICAL
	call CreateWindowExA
	mov hProgressBar, rax
	add rsp, 60h

	;Init first game
	Call CreateNewPen
	Call CreateTimer
	Call NewGame
	Call LoadModule
	leave
	ret
CreateElementWindow	ENDP

;///////////////////////WINDOW_PROCEDURE//////////////////////////
WndProc PROC	;(hwnd, msg, wParam, lParam) -> 0
	push rbp
	mov rbp, rsp
	push rcx
	push rdx
	push r8
	push r9

;Button click message
@WM_COMMAND:
	cmp rdx, WM_COMMAND
	jne @END_COMMAND

	;Case button quit
		cmp r8d, IDB_BTNQUIT
		jne @NOT_BTNQUIT

		;MessageBox
		mov rcx, hWnd
		lea rdx, szAskMsg
		lea r8, szBtnQuit
		mov r9, 1
		sub rsp, 20h
		call MessageBoxA
		add rsp, 20h

		cmp rax, MB_CANCEL
		je @EXIT_PROC
		call PostQuitMessage
		jmp @EXIT_PROC
	@NOT_BTNQUIT:
		
	;Case button new game
		cmp r8d, IDB_BTNNEW
		jne @NOT_BTNNEW

		;MessageBox
		mov rcx, hWnd
		lea rdx, szAskMsg
		lea r8, szBtnNew
		mov r9, 1

		sub rsp, 20h
		call MessageBoxA
		add rsp, 20h

		cmp rax, MB_CANCEL
		je @EXIT_PROC
		
		call NewGame
		jmp @EXIT_PROC
	@NOT_BTNNEW:

	;Case button change mode
		cmp r8d, IDB_BTNCOMPMODE
		jne @NOT_BTNCOMPMODE
	
		cmp CompMode, PLAYER_VS_COMP
		jne @SET_MODE

		mov CompMode, PLAYER_VS_PLAYER
		sub rsp, 20h
		mov rcx, hWndBtnCompMode
		lea rdx, szNoCompMode
		Call SetWindowTextA
		add rsp, 20h

		jmp @EXIT_PROC
	@SET_MODE:
		mov CompMode, PLAYER_VS_COMP
		sub rsp, 20h
		mov rcx, hWndBtnCompMode
		lea rdx, szCompMode
		Call SetWindowTextA
		add rsp, 20h

		jmp @EXIT_PROC
	@NOT_BTNCOMPMODE:

jmp @EXIT_PROC
@END_COMMAND:

;Left - mouse button up message
@WM_LBUTTONUP:
	cmp rdx, WM_LBUTTONUP
	jne @END_LBUTTONUP

	;If (Comp mode) and (player = comp) then skip this message
	cmp CompMode, PLAYER_VS_PLAYER
	je @PUT_CHESS_PIECE
	cmp player, 2
	je @EXIT_PROC

	@PUT_CHESS_PIECE:
	;Extracting click coord (X, Y) from r9 (LOWORD = X, HIGHTWORD = Y)
	mov rcx, r9
	and rcx, 0FFFFh ;erase hight bit
	
	mov rdx, r9
	shr rdx, 16
	and rdx, 0FFFFh

	;Computing piece location on chessboard
	sub ecx, chessBoard.left
	sub edx, chessBoard.top

	cmp ecx, 0
	jb @EXIT_PROC
	cmp edx, 0
	jb @EXIT_PROC

	push rdx
	xor rdx, rdx
	mov rax, rcx
	mov rcx, 25
	idiv rcx
	mov rcx, rax
	pop rdx

	push rcx
	mov rax, rdx
	xor rdx, rdx
	mov rcx, 25
	idiv rcx
	mov rdx, rax
	pop rcx

	cmp ecx, 19
	ja @EXIT_PROC
	cmp edx, 19
	ja @EXIT_PROC

	call OnClickChessBoard	;(X, Y) -> void

	jmp @EXIT_PROC
@END_LBUTTONUP:

@WM_CREATE:
	cmp rdx, WM_CREATE
	jne @END_CREATE

	jmp @EXIT_PROC
@END_CREATE:

@WM_DESTROY:
	cmp rdx, WM_DESTROY
	jne @END_DESTROY
	xor rcx, rcx
	call PostQuitMessage
@END_DESTROY:

@EXIT_PROC:
	pop r9
	pop r8
	pop rdx
	pop rcx
	sub rsp, 20h
	call DefWindowProcA
	add rsp, 20h

	leave
	Ret
WndProc	ENDP

;///////////////////////////CREATE_PEN//////////////////////////////
CreateNewPen PROC
	push rbp
	mov rbp, rsp

	sub rsp, 20h

	;GetDCWindow, save it!!! 
	mov rcx, hWnd
	Call GetDC
	mov hdc, rax

	;Create black pen
	mov rcx, PS_SOLID
	mov rdx, 3
	mov r8, 0h 
	call CreatePen
	mov hPen.black, rax

	;Create green pen
	mov rcx, PS_SOLID
	mov	rdx, 3
	mov r8, 0FF00h
	call CreatePen
	mov hPen.green, rax

	;Create red pen
	mov rcx, PS_SOLID
	mov	rdx, 1
	mov r8, 080h
	call CreatePen
	mov hPen.red, rax

	;Create blue pen
	mov rcx, PS_SOLID
	mov	rdx, 4
	mov r8, 0FF0000h
	call CreatePen
	mov hPen.blue, rax

	;Create white pen
	mov rcx, PS_SOLID
	mov	rdx, 1
	mov r8, 0AAAAAAh
	call CreatePen
	mov hPen.white, rax

	;Create	magenta pen
	mov rcx, PS_SOLID
	mov	rdx, 3
	mov r8, 0FF00FFh
	call CreatePen
	mov hPen.magenta, rax

	;Create yellow pen
	mov rcx, PS_SOLID
	mov	rdx, 3
	mov r8, 0FFFFh
	call CreatePen
	mov hPen.yellow, rax
	add rsp, 20h
	
	leave
	ret
CreateNewPen ENDP

;//////////////////////////PUT_CHESS_SPIECE///////////////////////
PutXO PROC	;(X, Y, {0 = ' '; 1 = 'X'; 2 = 'O'}) -> void
	push rbp
	mov rbp, rsp
	push r8
	push rdx

	cmp rcx, 0
	jb  @EXIT_PROC
	cmp rdx, 0
	jb  @EXIT_PROC
	cmp rcx, 19
	ja  @EXIT_PROC
	cmp rdx, 19
	ja  @EXIT_PROC

	;Save to array
	lea rbx, array
	mov rax, 20
	mul rdx
	add rax, rcx
	mov BYTE PTR [rbx + rax],  r8b

	;Chess piece coord (left, top) = (r12, r15)
	mov rax, 25
	mul rcx
	mov r12, rax
	add r12d, chessBoard.left

	mov rax, 25
	pop rdx
	mul rdx
	mov r15, rax
	add r15d, chessBoard.top

;Draw sqare around chesspiece 
@DRAW_RECT_CHESS:
	sub rsp, 20h
	mov rcx, hdc

	;Choose pen: red or white
	mov rdx, hPen.white
	cmp r8, 0
	jne @NOT_SPACE
	mov rdx, hPen.red
@NOT_SPACE:
	call SelectObject

	mov rcx, hdc
	mov rdx, r12
	mov r8, r15
	mov r9, 0
	call MoveToEx

	mov rcx, hdc
	mov rdx, r12
	mov r8, r15
	add r8, 25
	call LineTo

	mov rcx, hdc
	mov rdx, r12
	add rdx, 25
	mov r8, r15
	add r8, 25
	call LineTo
	
	mov rcx, hdc
	mov rdx, r12
	add rdx, 25
	mov r8, r15
	call LineTo

	mov rcx, hdc
	mov rdx, r12
	mov r8, r15
	call LineTo 

	add rsp, 20h

	;Switch (r8) case {PUTX, PUTO, PUTSPACE}
	pop r8
	sub rsp, 20h
@PUTX:
	cmp r8, 1
	jne @PUTO

	;Draw symbol X
	mov rcx, hdc
	mov rdx, hPen.blue
	call SelectObject
	
	mov rcx, hdc
	mov rdx, r12
	add rdx, 5
	mov r8, r15
	add r8, 5
	mov r9, 0
	call MoveToEx

	mov rcx, hdc
	mov rdx, r12
	add rdx, 20
	mov r8, r15
	add r8, 20
	mov r9, 0
	call LineTo

	mov rcx, hdc
	mov rdx, r12
	add rdx, 20
	mov r8, r15
	add r8, 5
	mov r9, 0
	call MoveToEx

	mov rcx, hdc
	mov rdx, r12
	add rdx, 5
	mov r8, r15
	add r8, 20
	mov r9, 0
	call LineTo
	jmp  @EXIT_PROC

@PUTO:
	cmp r8, 2
	jne @PUTSPACE

	mov rcx, 0
	call CreateSolidBrush

	mov rcx, hdc
	mov rdx, rax
	call SelectObject

	mov rcx, hdc
	mov rdx, hPen.yellow
	call SelectObject

	mov rax, r15
	add rax, 21
	push rax
	sub rsp, 20h
	mov rcx, hdc
	mov rdx, r12
	add rdx, 5
	mov r8, r15
	add r8, 4
	mov r9, r12
	add r9, 20
	call Ellipse
	pop rax

	jmp  @EXIT_PROC
@PUTSPACE:
	cmp r8, 0
	jne  @EXIT_PROC

	mov rcx, 0
	call CreateSolidBrush

	mov rcx, hdc
	mov rdx, rax
	call SelectObject

	mov rcx, hdc
	mov rdx, hPen.black
	call SelectObject

	mov rax, r15
	add rax, 24
	push rax
	sub rsp, 20h
	mov rcx, hdc
	mov rdx, r12
	add rdx, 2
	mov r8, r15
	add r8, 2
	mov r9, r12
	add r9, 24
	call Rectangle
	pop rax
	add rsp, 28h
@EXIT_PROC:
	add rsp, 20h

	leave
	ret
PutXO ENDP

;////////////////////////CHANG_PLAYER/////////////////////////////
ChangePlayer PROC
	push rbp
	mov rbp, rsp

	cmp player, 1
	je @CHANGE
	mov player, 1
	jmp @EXIT_PROC
@CHANGE:
	mov player, 2

@EXIT_PROC:
	leave
	ret
ChangePlayer ENDP

;///////////////////////ON_CLICK_CHESS_BOARD/////////////////////
OnClickChessBoard PROC		;(X, Y, player) -> void
	push rbp
	mov rbp, rsp

	;Search in array
	imul rax, rdx, 20
	add rax, rcx

	lea rbx, array
	add rbx, rax

	xor r9, r9
	mov r9b, BYTE PTR [rbx]
	cmp r9, 0
	jne @EXIT_PROC

	push rcx
	push rdx
	call CreateNewPen

	pop rdx
	pop rcx
	xor r8, r8
	mov r8b, player
	push rcx
	push rdx
	call PutXO
	pop rdx
	pop rcx
	
	call  CheckWin
	cmp rax, 0
	je @NOT_WIN

	Call EndGame
	jmp @EXIT_PROC

@NOT_WIN:
	sub rsp, 10h
	mov eax, time_out
	mov timer, eax
	mov rcx, hTimer
	Call ResumeThread
	add rsp, 10h
	call ChangePlayer

	cmp CompMode, PLAYER_VS_PLAYER
	je @EXIT_PROC

	cmp player, 2
	jne @EXIT_PROC

	call CompPlay
@EXIT_PROC:
	pop rdx
	pop rcx

	leave
	ret
OnClickChessBoard ENDP

;//////////////////////////////NEW_GAME///////////////////////////
NewGame PROC	;void -> void
	push rbp
	mov rbp, rsp

	lea rbx, array
	mov BYTE PTR [rbx], 0
	mov rcx, 399
@CLEAR_ARRAY:
	mov BYTE PTR [rbx + rcx], 0
	mov al, BYTE PTR [rbx + rcx]
	loop @CLEAR_ARRAY

	;Make new chessboard
	call CreateNewPen
	mov rcx, 19
@FOR_EACH_ROW:
	mov rdx, 19
	@FOR_EACH_COL:
		mov r8, 0
		push rcx
		push rdx
		call PutXO
		pop rdx
		pop rcx

		dec rdx
		cmp rdx, 0
		jge @FOR_EACH_COL
	dec rcx
	cmp rcx, 0
	jge @FOR_EACH_ROW
	
	;Restart timer
	sub rsp, 10h
	mov eax, time_out
	mov timer, eax
	mov rcx, hTimer
	call SuspendThread
	add rsp, 10h

	;Set first move is O
	mov player, 2

	cmp CompMode, 1
	jne @SKIP
	mov rcx, 9
	mov rdx, 9
	Call OnClickChessBoard
@SKIP:
	leave
	ret
NewGame	ENDP

;////////////////////////////CREATE_TIMER/////////////////////////
CreateTimer PROC
	push rbp
	mov rbp, rsp

	mov timer, INFINITE_TIME

	;CreateThread
	push 0
	push 0
	mov rcx, 0
	mov rdx, 0
	lea r8, TimerTick
	mov r9, 0
	sub rsp, 20h
	call CreateThread
	mov hTimer, rax

	leave
	ret
CreateTimer ENDP

TimerTick PROC
	push rbp
	mov rbp, rsp

@LOOP:
	;Update progress bar
	sub rsp, 20h
	xor rdx, rdx
	mov ecx, timer
	imul rax, rcx, 101
	mov ecx, time_out
	idiv rcx
	mov r8, rax
	mov rcx, hProgressBar
	mov rdx, 1026	;PBM_SETPOS
	mov r9, 0
	call SendMessageA
	add rsp, 20h

	cmp timer, 0
	je @TIME_OUT

	sub rsp, 10h
	mov rcx, 10
	Call Sleep
	add rsp, 10h
	sub timer, 10
	jmp @LOOP
@TIME_OUT:

	sub rsp, 20h
	;Random click to set chess piece
@TRY: 
	lea rcx, systime
	Call GetSystemTime
	xor rdx, rdx
	mov rcx, 400
	mov ax, systime.milliseconds
	add ax, systime.second
	idiv rcx
	lea rsi, array
	mov al, BYTE PTR [rsi + rdx]
	cmp al, 0
	jne @TRY

	mov rax, rdx
	xor rdx, rdx
	mov rcx, 20
	idiv rcx
	mov rcx, rdx
	mov rdx, rax

	call OnClickChessBoard
	add  rsp, 20h
	
	jmp @LOOP
	leave
	ret
TimerTick ENDP

;/////////////////////////////CHECK_WIN///////////////////////////
CheckWin PROC   ;(X, ) -> bool
	push rbp
	mov rbp, rsp

	xor r14, r14
	call CheckRow
	or r14, rax
	call CheckColumn
	or r14, rax
	call CheckLower
	or r14, rax
	call CheckUpper
	or r14, rax
	mov rax, r14

	leave
	ret
CheckWin ENDP

CheckColumn PROC
	push rbp
	mov rbp, rsp
	push rcx
	push rdx

	xor r10, r10
	lea rsi, array

	imul rbx, rdx, 20
	add rbx, rcx
	inc r10

@LOOP_UP:
	cmp rbx, 20
		jl @BREAK
	sub rbx, 20
	mov al, BYTE PTR [rsi + rbx]

	cmp al, player
	jne @BREAK
	inc r10

	jmp @LOOP_UP
@BREAK:

	imul rbx, rdx, 20
	add rbx, rcx
@LOOP_DOWN:
	cmp rbx, 380
	jg @BREAK_
	add rbx, 20
	mov al, BYTE PTR [rsi + rbx]

	cmp al, player
	jne @BREAK_
	inc r10

	jmp @LOOP_DOWN
@BREAK_:
	
	xor rax, rax
	cmp r10, 5
	jge @WIN
	jmp @ENDPROC
@WIN:
	mov rax, 1
@ENDPROC:
	pop rdx
	pop rcx
	leave
	ret
CheckColumn ENDP

CheckRow PROC
	push rbp
	mov rbp, rsp
	push rdx
	push rcx

	xor r10, r10
	lea rsi, array 
;rbx for address
@LOOP_LEFT:
	cmp rcx, 0
	je @BREAK
	dec rcx

	imul rbx, rdx, 20
	add rbx, rcx
	mov al, BYTE PTR [rsi + rbx]

	cmp al, player
	jne @BREAK
	inc r10

	jmp @LOOP_LEFT
@BREAK:
	
	pop rcx
	push rcx

@LOOP_RIGHT:
	imul rbx, rdx, 20
	add rbx, rcx
	mov al, BYTE PTR [rsi + rbx]

	cmp al, player
	jne @BREAK_
	inc r10	
	inc rcx
	cmp rcx, 20
	jl @LOOP_RIGHT
@BREAK_:

	xor rax, rax
	cmp r10, 5
	jge @WIN
	jmp @ENDPROC
@WIN:
	mov rax, 1
@ENDPROC:
	pop rcx
	pop rdx
	leave
	ret
CheckRow ENDP

CheckLower PROC
	push rbp
	mov rbp, rsp
	push rcx
	push rdx

	xor r10, r10
	lea rsi, array 

@LOOP:
	cmp rcx, 0
	je @BREAK
	cmp rdx,0
	je @BREAK
	dec rcx
	dec rdx

	imul rbx, rdx, 20
	add rbx, rcx
	mov al, BYTE PTR [rsi + rbx]

	cmp al, player
	jne @BREAK
	inc r10

	cmp rdx, 0
	jge @STEP
	jmp @BREAK
@STEP:
	cmp rcx, 0
	jge @LOOP
@BREAK:

	pop rdx
	pop rcx
	push rcx
	push rdx

@LOOP_:
	imul rbx, rdx, 20
	add rbx, rcx
	mov al, BYTE PTR [rsi + rbx]

	cmp al, player
	jne @BREAK_
	inc r10

	inc rcx
	inc rdx
	cmp rdx, 20
	jl @STEP_
	jmp @BREAK_
@STEP_:
	cmp rcx, 20
	jl @LOOP_
@BREAK_:

	xor rax, rax
	cmp r10, 5
	jge @WIN
	jmp @ENDPROC
@WIN:
	mov rax, 1
@ENDPROC:
	pop rdx
	pop rcx
	leave
	ret
CheckLower ENDP

CheckUpper PROC
	push rbp
	mov rbp, rsp
	push rcx
	push rdx

	xor r10, r10
	lea rsi, array 

@LOOP:
	cmp rdx, 0
	jl @BREAK
	cmp rcx, 19
	ja @BREAK
	imul rbx, rdx, 20
	add rbx, rcx
	mov al, BYTE PTR [rsi + rbx]

	cmp al, player
	jne @BREAK
	inc r10

	inc rcx
	dec rdx
	jmp @LOOP
@BREAK:
	
	pop rdx
	pop rcx
	push rcx
	push rdx

@LOOP_:
	inc rdx
	dec rcx
	cmp rcx, 0
	jl @BREAK_
	cmp rdx, 19
	ja @BREAK_
	imul rbx, rdx, 20
	add rbx, rcx
	mov al, BYTE PTR [rsi + rbx]

	cmp al, player
	jne @BREAK_
	inc r10

	jmp @LOOP_
@BREAK_:

	xor rax, rax
	cmp r10, 5
	jge @WIN
	jmp @ENDPROC
@WIN:
	mov rax, 1
@ENDPROC:
	pop rdx
	pop rcx
	leave
	ret
CheckUpper	ENDP

;/////////////////////////////END_GAME////////////////////////////
EndGame PROC
	push rbp
	mov rbp, rsp

	mov timer, INFINITE_TIME

	push rcx
	push rdx

	sub rsp, 20h
	mov rcx, hdc
	mov rdx, hPen.green
	call SelectObject
	mov rcx, NULL_BRUSH
	Call GetStockObject
	mov rdx, rax
	mov rcx, hdc
	Call SelectObject
	add rsp, 20h

	;Draw ellipse
	pop rdx
	pop rcx

	imul r10, rcx, CHESS_SQUARE
	add r10d, chessBoard.left
	add r10, 12
	imul r15, rdx, CHESS_SQUARE
	add r15d, chessBoard.top
	add r15, 12
	mov rax, r15

	push r10
	push r15

	sub rax, 50
	push rax
	sub rsp, 20h
	mov rcx, hdc
	mov rdx, r10
	add rdx, 50
	mov r8, r15
	add r8, 50
	mov r9, r10
	sub r9, 50
	call Ellipse
	add rsp, 28h

	cmp player, 1
	jne @OWIN
	lea rdx, szXWin
	jmp @STEP
@OWIN:
	lea rdx, szOWin
@STEP:
	
	;MessageBox
	mov rcx, hWnd
	lea r8, szWinMsg
	mov r9, 0
	sub rsp, 20h
	call MessageBoxA
	add rsp, 20h

	;Erase ellipse
	sub rsp, 20h
	mov rcx, hdc
	mov rdx, hPen.black
	call SelectObject
	add rsp, 20h

	pop r15
	pop r10

	mov rax, r15
	sub rax, 50
	push rax
	sub rsp, 20h
	mov rcx, hdc
	mov rdx, r10
	add rdx, 50
	mov r8, r15
	add r8, 50
	mov r9, r10
	sub r9, 50
	call Ellipse
	sub rsp, 28h

	Call NewGame
	leave 
	ret
EndGame ENDP

;//////////////////////////////BEGIN_COMP//////////////////////////
.DATA 
	CompName			DB		"Library1", 0
	szAskComputer		DB		"AskComputer", 0
	szComputerAnswer	DB		"ComputerAnswer", 0
.DATA?
	hModule			DQ		?
	lastPosX		WORD	?
	lastPosY		WORD	?

	AskComputer			DQ		?
	ComputerAnswer		DQ		?
.CODE

LoadModule PROC
	push rbp
	mov rbp, rsp

	sub rsp, 20h
@TRY_LOAD:
	lea rcx, Compname
	Call LoadLibraryA
	mov hModule, rax
	cmp rax, 0
	je @TRY_LOAD

	mov rcx, hModule
	lea rdx, szAskComputer
	call GetProcAddress
	mov AskComputer, rax

	mov rcx, hModule
	lea rdx, szComputerAnswer
	call GetProcAddress
	mov ComputerAnswer, rax
	add rsp, 20h

	leave
	ret 
LoadModule ENDP

CompPlay	PROC
	push rbp
	mov rbp, rsp

	lea rcx, [array]
	call [AskComputer]
	call [ComputerAnswer]

	;Extract 'LONG' awnser of Comp from rax 
	mov rcx, rax
	and rcx, 0FFFFh ;LOWORD
	mov rdx, rax
	shr rdx, 16
	and rdx, 0FFFFh ;HIWORD
	call OnClickChessBoard

	leave
	ret
CompPlay	ENDP

END
