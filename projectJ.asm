[org 0x0100]
jmp main

		; ax,bx,ip,cs,flags storage area
pcb:	dw 0, 0, 0, 0, 0 ; task0 regs[cs:pcb + 0]
		dw 0, 0, 0, 0, 0 ; task1 regs start at [cs:pcb + 10]
		dw 0, 0, 0, 0, 0 ; task2 regs start at [cs:pcb + 20]

current:	db 0 ; index of current task
chars:		db '\|/-' ; shapes to form a bar

music_length: dw 6928
music_data: 
    incbin "FAN.imf"

music:
		; 2) now let's just read "getthem.imf" file content
		;    every 4 bytes. I'll use SI register as index.
		
		;mov si, 0 ; current index for music_data
		
		mov di, 8
		
	.next_note:
	
		; 3) the first byte is the opl2 register
		;    that is selected through port 388h
		mov dx, 388h
		mov al, [cs:si + music_data + 0]
		out dx, al
		
		; 4) the second byte is the data need to
		;    be sent through the port 389h
		mov dx, 389h
		mov al, [cs:si + music_data + 1]
		out dx, al
		
		; 5) the last 2 bytes form a word
		;    and indicate the number of waits (delay)
		mov bx, [cs:si + music_data + 2]
		
		; 6) then we can move to next 4 bytes
		add si, 4
		
		; 7) now let's implement the delay
		
	.repeat_delay:	
		mov cx, 500 ; <- change this value according to the speed
		              ;    of your computer / emulator
	.delay:
	
		; if keypress then exit
		; mov ah, 1
		; int 16h
		; jnz .exit
		
		loop .delay
		
		dec bx
		jg .repeat_delay
		
		cmp si, [cs:music_length]
		je .exit
		
		dec di
		cmp di, 0
		jne .contMus
		
		cmp si, [cs:music_length]
		jb .next_note
		
		mov si, 0
	
	.contMus:
		jmp PlayAnimation
		
		; 8) let's send all content of music_data
		cmp si, [cs:music_length]
		jb .next_note
		
		
	.exit:	
		; return to DOS
		;mov si, 0
		jmp PlayAnimation

QuitPhrase: db 'Quit game? Y/N', '$'

oldisr: dd 0
BirdDirection: dw 0
escapeFlag: dw 0

BirdIndex dw 1620

PillarHeight1: dw 7
PillarUpperIndex1: dw 148
PillarLowerIndex1: dw 3508
CurrentWidth: dw 10
FadeInWidth: dw 2
isDrawn: dw 0
PillarHeightLower1: dw 7

PillarHeight2: dw 11
PillarUpperIndex2: dw 148
PillarLowerIndex2: dw 3508
CurrentWidth2: dw 10
FadeInWidth2: dw 2
isDrawn2: dw 0
Pillar2Drawn: dw 0
distance: dw 0
PillarHeightLower2: dw 3

PillarHeight3: dw 6
PillarUpperIndex3: dw 148
PillarLowerIndex3: dw 3508
CurrentWidth3: dw 10
FadeInWidth3: dw 2
isDrawn3: dw 0
Pillar3Drawn: dw 0
distance2: dw 0
PillarHeightLower3: dw 7

GroundIndex: dw 3520
GroundBuffer: dw 0, 0, 0

CONTINUEPhrase: db 'PRESS ANY KEY TO CONTINUE', '0'
FlappyBird: db ' CHIRI URI', '0'
Mamoon: db 'Mamoon Chishti', '0'
MamoonRollNo: db '23L-6050', '.'
Manahil: db 'Manahil Atif' , '0'
ManahilRollNo: db '23L-0556', '.'
RectangleIndex: dw 520
testing: dw 0

CONTINUEPhrase2: db 'PRESS ANY KEY TO CONTINUE', '0'
InstructionPhrase: db '- Hold the Space Key to Fly', '0'
InstructionPhrase2: db '- Press the Esc Key to Pause', '0'
DialougeBoxIndex: dw 680

ExitPhrase: db 'Exiting...', '0'

score: db 0
ScorePhrase: db 'Score: 0'
GameOverPhrase: db 'Game Over...', '0'

seconds: dw 0
timerflag: dw 0
oldkb: dd 0 

saveBuffer: times 4000 dw 0

randomizeHeight:
    push bx
    mov al, 0
    out 0x70, al        ; Command byte written at first port
    in al, 0x71         ; Read the result of command into AL

    xor ah, ah          ; Clear upper byte of AX
    mov bl, 10          ; Set the range to 0-10 (11 numbers)
    div bl              ; Divide AX by 11, remainder (in AH) is the random number
    mov al, ah          ; Move the remainder (random number) to AL
    add al, 1           ; Shift range to 1-11

    mov ah, 0           ; Ensure AX holds the random number
    pop bx               ; Restore all registers except AX
    ret

randomizeHeight2:
    push bx            ; Save BX register
    mov al, 0
    out 0x70, al       ; Command byte written at first port
    in al, 0x71        ; Read the result of command into AL

    xor ah, ah         ; Clear upper byte of AX
    mov bl, 7          ; Set the range to 0-6 (7 numbers)
    div bl             ; Divide AX by 7, remainder (in AH) is the random number
    mov al, ah         ; Move the remainder (random number) to AL
    add al, 1          ; Shift range to 1-7

    mov ah, 0          ; Ensure AX holds the random number
    pop bx             ; Restore BX register
    ret

bird:
    pusha

    mov ax, 0xB800
    mov es, ax

    mov di, [BirdIndex]
    mov ax, 0x4020
    mov [es:di], ax

    add di, 2
    mov [es:di], ax
    add di, 2
    mov [es:di], ax
    add di, 2
    mov [es:di], ax

    mov ax, 0x7020
    add di, 2
    mov [es:di], ax

    mov al, 0x2A
    add di, 2
    mov [es:di], ax

    add di, 160
    mov ax, 0x4020
    mov [es:di], ax

    sub di, 2
    mov [es:di], ax
    sub di, 2
    mov [es:di], ax

    mov ax, 0x8F2C
    sub di, 2
    mov [es:di], ax

    sub di, 2
    mov [es:di], ax
    sub di, 2
    mov [es:di], ax

    popa
    ret

delay:
    push cx
    mov cx, 0xFFFF
delay_loop1:
    loop delay_loop1
    mov cx, 0xFFFF
delay_loop2:
    loop delay_loop2
	pop cx
	ret

drawBackground:
    push es
    push ax
    push cx
    push di
    push si
    push bx

    mov ax, 0xB800
    mov es, ax

    mov cx, 1760
    mov ax, 0x3020
    mov di, 0

    cld
    rep stosw

    call drawGround

    pop bx
    pop si
    pop di
    pop cx
    pop ax
    pop es
    ret

drawGround:
    mov ax, 6020h
    xor si, si

    Groundloop1:
    mov [es:di], ax
    inc si

    cmp si, 33
    jne nextPebble
    call firstPebble
    xor si, si

    nextPebble:
    cmp si, 13
    jne skipPebble
    call secondPebble

    skipPebble:
    add di, 2
    cmp di, 4000
    jb Groundloop1
    ret

secondPebble:
    push ax
    mov ax, 0x6E2E
    mov [es:di], ax
    pop ax
    ret

firstPebble:
    push ax
    mov ax, 0x6E6F
    mov [es:di], ax
    pop ax
    ret

UpdateDistance:
    mov word[distance], 1
    jmp backHere

UpdateDistance2:
    mov word[distance2], 1
    jmp backHere2

movePillars:
    push es
    push ax
    push si
    push di
    push cx
    push bx
    push dx

    cmp word[PillarUpperIndex1], 105
    jb UpdateDistance
    backHere:
    cmp word[distance], 0
    je skipDrawingPillar2
    call drawPillar2

    cmp word[PillarUpperIndex1], 50
    jb UpdateDistance2
    backHere2:
    cmp word[distance2], 0
    je skipDrawingPillar2
    call drawPillar3

    skipDrawingPillar2:
    cmp word[isDrawn], 1
    je pillarFadeIn

    mov ax, [PillarUpperIndex1]
    cmp ax, 0
    je pillarFadeOut

    mov ax, 0xB800
    mov es, ax

    xor dx, dx
    mov cx, 6

    mov si, [PillarUpperIndex1]
    mov di, si
    sub di, 2

    OuterOneLeft:
        mov bx, 0

        OneLeftLoop:
            mov ax, [es:si]
            mov [es:di], ax
            add si, 2
            add di, 2
            inc bx
            cmp bx, cx
            jne OneLeftLoop

        mov ax, 0x3020
        mov [es:di], ax

        sub si, 12
        sub di, 12
        add si, 160
        add di, 160

        inc dx
        cmp dx, [PillarHeight1]
        jne OuterOneLeft

    sub word [PillarUpperIndex1], 2

    xor dx, dx
    mov cx, 6

    mov si, [PillarLowerIndex1]
    mov di, si
    sub di, 2

    OuterBelow:
        mov bx, 0

        OneLeftBelow:
            mov ax, [es:si]
            mov [es:di], ax
            add si, 2
            add di, 2
            inc bx
            cmp bx, cx
            jne OneLeftBelow

        mov ax, 0x3020
        mov [es:di], ax

        sub si, 12
        sub di, 12
        sub si, 160
        sub di, 160

        inc dx
        cmp dx, [PillarHeightLower1]
        jne OuterBelow

    sub word [PillarLowerIndex1], 2

endMovingPillars:
    pop dx
    pop bx
    pop cx
    pop di
    pop si
    pop ax
    pop es
    ret       

resetCurrentWidth:
    mov word[CurrentWidth], 10
    mov word[PillarUpperIndex1], 148
    mov word[PillarLowerIndex1], 3508
    call drawPillar
    jmp endMovingPillars
        
pillarFadeOut:
    cmp word[CurrentWidth], -2
    je resetCurrentWidth

    mov ax, 0xB800
    mov es, ax

    mov di, [PillarUpperIndex1]
    add di, [CurrentWidth]

    mov cx, [PillarHeight1]
    mov ax, 0x3020

    fadeLoop:
        mov [es:di], ax
        add di, 160
        loop fadeLoop

    mov si, [PillarLowerIndex1]
    add si, [CurrentWidth]

    mov cx, [PillarHeightLower1]
    mov ax, 0x3020

    fadeLoopLower:
        mov [es:si], ax
        sub si, 160
        loop fadeLoopLower

    sub word[CurrentWidth], 2
    jmp endMovingPillars

drawPillar:
    push ax
    push di
    push es
    push cx
    push bx
    push si

    mov ax, 0x2E20
    mov di, 158
    mov si, 0
    mov cx, [PillarHeight1]
    mov bx, 0
    
    OuterPillarLoop:
        xor si, si

        PillarLoop:
            mov [es:di], ax
            add di, 2
            inc si
            cmp si, 1
            jne PillarLoop

        sub di, 2
        add di, 160
        inc bx
        cmp bx, cx
        jne OuterPillarLoop

    mov ax, 0x2E20
    mov di, 3518
    mov si, 0
    mov cx, [PillarHeightLower1]
    mov bx, 0

    OuterPillarLower:
        xor si, si

        PillarLower:
            mov [es:di], ax
            add di, 2
            inc si
            cmp si, 1
            jne PillarLower

        sub di, 2
        sub di, 160
        inc bx
        cmp bx, cx
        jne OuterPillarLower

    mov word[isDrawn], 1

    pop si
    pop bx
    pop cx
    pop es
    pop di
    pop ax
    ret

pillarFadeIn:
    mov ax, 0xB800
    mov es, ax

    mov cx, [FadeInWidth]
    mov si, 160

    mov di, 0
    FadeInLoop:
        sub si, 2
        add di, 2
        cmp di, cx
        jne FadeInLoop
    
    mov cx, [PillarHeight1]
    loop1:
        mov ax, [es:si]
        mov di, si
        sub di, 2
        mov [es:di], ax
        add si, 160
        loop loop1

    ; Lower Pillar
    mov cx, [FadeInWidth]
    mov si, 3520

    mov di, 0
    FadeInLoop2:
        sub si, 2
        add di, 2
        cmp di, cx
        jne FadeInLoop2
    
    mov cx, [PillarHeightLower1]
    loop2:
        mov ax, [es:si]
        mov di, si
        sub di, 2
        mov [es:di], ax
        sub si, 160
        loop loop2

    add word[FadeInWidth], 2
    cmp word[FadeInWidth], 12
    je resetFadeWidth
    jmp endMovingPillars

resetFadeWidth:
    mov word[FadeInWidth], 2
    mov word[isDrawn], 0
    jmp endMovingPillars

drawPillar2:
    push es
    push ax
    push si
    push di
    push cx
    push bx
    push dx

    cmp word[Pillar2Drawn], 1
    je fromDraw2

    mov ax, 0x2E20
    mov di, 158
    mov si, 0
    mov cx, [PillarHeight2]
    mov bx, 0
    
    OuterPillarLoop2:
        xor si, si

        PillarLoop2:
            mov [es:di], ax
            add di, 2
            inc si
            cmp si, 1
            jne PillarLoop2

        sub di, 2
        add di, 160
        inc bx
        cmp bx, cx
        jne OuterPillarLoop2

    mov ax, 0x2E20
    mov di, 3518
    mov si, 0
    mov cx, [PillarHeightLower2]
    mov bx, 0

    OuterPillarLower2:
        xor si, si

        PillarLower2:
            mov [es:di], ax
            add di, 2
            inc si
            cmp si, 1
            jne PillarLower2

        sub di, 2
        sub di, 160
        inc bx
        cmp bx, cx
        jne OuterPillarLower2

    mov word[isDrawn2], 1
    mov word[Pillar2Drawn], 1

    pop dx
    pop bx
    pop cx
    pop di
    pop si
    pop ax
    pop es
    ret 

movePillars2:
    push es
    push ax
    push si
    push di
    push cx
    push bx
    push dx

    fromDraw2:

    cmp word[isDrawn2], 1
    je pillarFadeIn2

    mov ax, [PillarUpperIndex2]
    cmp ax, 0
    je pillarFadeOut2

    mov ax, 0xB800
    mov es, ax

    xor dx, dx
    mov cx, 6

    mov si, [PillarUpperIndex2]
    mov di, si
    sub di, 2

    OuterOneLeft2:
        mov bx, 0

        OneLeftLoop2:
            mov ax, [es:si]
            mov [es:di], ax
            add si, 2
            add di, 2
            inc bx
            cmp bx, cx
            jne OneLeftLoop2

        mov ax, 0x3020
        mov [es:di], ax

        sub si, 12
        sub di, 12
        add si, 160
        add di, 160

        inc dx
        cmp dx, [PillarHeight2]
        jne OuterOneLeft2

    sub word [PillarUpperIndex2], 2

    xor dx, dx
    mov cx, 6

    mov si, [PillarLowerIndex2]
    mov di, si
    sub di, 2

    OuterBelow2:
        mov bx, 0

        OneLeftBelow2:
            mov ax, [es:si]
            mov [es:di], ax
            add si, 2
            add di, 2
            inc bx
            cmp bx, cx
            jne OneLeftBelow2

        mov ax, 0x3020
        mov [es:di], ax

        sub si, 12
        sub di, 12
        sub si, 160
        sub di, 160

        inc dx
        cmp dx, [PillarHeightLower2]
        jne OuterBelow2

    sub word [PillarLowerIndex2], 2

    endMovingPillars2:
    pop dx
    pop bx
    pop cx
    pop di
    pop si
    pop ax
    pop es
    ret       

resetCurrentWidth2:
    mov word[CurrentWidth2], 10
    mov word[PillarUpperIndex2], 148
    mov word[PillarLowerIndex2], 3508
    mov word[Pillar2Drawn], 0
    call drawPillar2
    jmp endMovingPillars2
        
pillarFadeOut2:
    cmp word[CurrentWidth2], -2
    je resetCurrentWidth2

    mov ax, 0xB800
    mov es, ax

    mov di, [PillarUpperIndex2]
    add di, [CurrentWidth2]

    mov cx, [PillarHeight2]
    mov ax, 0x3020

    fadeLoop3:
        mov [es:di], ax
        add di, 160
        loop fadeLoop3

    mov si, [PillarLowerIndex2]
    add si, [CurrentWidth2]

    mov cx, [PillarHeightLower2]
    mov ax, 0x3020

    fadeLoopLower3:
        mov [es:si], ax
        sub si, 160
        loop fadeLoopLower3

    sub word[CurrentWidth2], 2
    jmp endMovingPillars2

pillarFadeIn2:
    mov ax, 0xB800
    mov es, ax

    mov cx, [FadeInWidth2]
    mov si, 160

    mov di, 0
    FadeInLoop3:
        sub si, 2
        add di, 2
        cmp di, cx
        jne FadeInLoop3
    
    mov cx, [PillarHeight2]
    loop3:
        mov ax, [es:si]
        mov di, si
        sub di, 2
        mov [es:di], ax
        add si, 160
        loop loop3

    ; Lower Pillar
    mov cx, [FadeInWidth2]
    mov si, 3520

    mov di, 0
    FadeInLoop4:
        sub si, 2
        add di, 2
        cmp di, cx
        jne FadeInLoop4
    
    mov cx, [PillarHeightLower2]
    loop4:
        mov ax, [es:si]
        mov di, si
        sub di, 2
        mov [es:di], ax
        sub si, 160
        loop loop4

    add word[FadeInWidth2], 2
    cmp word[FadeInWidth2], 12
    je resetFadeWidth2

    jmp endMovingPillars2

resetFadeWidth2:
    mov word[FadeInWidth2], 2
    mov word[isDrawn2], 0
    jmp endMovingPillars2

drawPillar3:
    push es
    push ax
    push si
    push di
    push cx
    push bx
    push dx

    cmp word[Pillar3Drawn], 1
    je fromDraw3

    mov ax, 0x2E20
    mov di, 158
    mov si, 0
    mov cx, [PillarHeight3]
    mov bx, 0
    
    OuterPillarLoop3:
        xor si, si

        PillarLoop3:
            mov [es:di], ax
            add di, 2
            inc si
            cmp si, 1
            jne PillarLoop3

        sub di, 2
        add di, 160
        inc bx
        cmp bx, cx
        jne OuterPillarLoop3

    mov ax, 0x2E20
    mov di, 3518
    mov si, 0
    mov cx, [PillarHeightLower3]
    mov bx, 0

    OuterPillarLower3:
        xor si, si

        PillarLower3:
            mov [es:di], ax
            add di, 2
            inc si
            cmp si, 1
            jne PillarLower3

        sub di, 2
        sub di, 160
        inc bx
        cmp bx, cx
        jne OuterPillarLower3

    mov word[isDrawn3], 1
    mov word[Pillar3Drawn], 1

    pop dx
    pop bx
    pop cx
    pop di
    pop si
    pop ax
    pop es
    ret 

movePillars3:
    push es
    push ax
    push si
    push di
    push cx
    push bx
    push dx

    fromDraw3:

    cmp word[isDrawn3], 1
    je pillarFadeIn3

    mov ax, [PillarUpperIndex3]
    cmp ax, 0
    je pillarFadeOut3

    mov ax, 0xB800
    mov es, ax

    xor dx, dx
    mov cx, 6

    mov si, [PillarUpperIndex3]
    mov di, si
    sub di, 2

    OuterOneLeft3:
        mov bx, 0

        OneLeftLoop3:
            mov ax, [es:si]
            mov [es:di], ax
            add si, 2
            add di, 2
            inc bx
            cmp bx, cx
            jne OneLeftLoop3

        mov ax, 0x3020
        mov [es:di], ax

        sub si, 12
        sub di, 12
        add si, 160
        add di, 160

        inc dx
        cmp dx, [PillarHeight3]
        jne OuterOneLeft3

    sub word [PillarUpperIndex3], 2

    xor dx, dx
    mov cx, 6

    mov si, [PillarLowerIndex3]
    mov di, si
    sub di, 2

    OuterBelow3:
        mov bx, 0

        OneLeftBelow3:
            mov ax, [es:si]
            mov [es:di], ax
            add si, 2
            add di, 2
            inc bx
            cmp bx, cx
            jne OneLeftBelow3

        mov ax, 0x3020
        mov [es:di], ax

        sub si, 12
        sub di, 12
        sub si, 160
        sub di, 160

        inc dx
        cmp dx, [PillarHeightLower3]
        jne OuterBelow3

    sub word [PillarLowerIndex3], 2

    endMovingPillars3:
    pop dx
    pop bx
    pop cx
    pop di
    pop si
    pop ax
    pop es
    ret       

resetCurrentWidth3:
    mov word[CurrentWidth3], 10
    mov word[PillarUpperIndex3], 148
    mov word[PillarLowerIndex3], 3508
    mov word[Pillar3Drawn], 0
    call drawPillar3
    jmp endMovingPillars3
        
pillarFadeOut3:
    cmp word[CurrentWidth3], -2
    je resetCurrentWidth3

    mov ax, 0xB800
    mov es, ax

    mov di, [PillarUpperIndex3]
    add di, [CurrentWidth3]
   
    mov cx, [PillarHeight3]
    mov ax, 0x3020

    fadeLoop5:
        mov [es:di], ax
        add di, 160
        loop fadeLoop5

    mov si, [PillarLowerIndex3]
    add si, [CurrentWidth3]

    mov cx, [PillarHeightLower3]
    mov ax, 0x3020

     fadeLoopLower5:
        mov [es:si], ax
        sub si, 160
        loop fadeLoopLower5

    sub word[CurrentWidth3], 2
    jmp endMovingPillars3

pillarFadeIn3:
    mov ax, 0xB800
    mov es, ax

    mov cx, [FadeInWidth3]
    mov si, 160

    mov di, 0
    FadeInLoop5:
        sub si, 2
        add di, 2
        cmp di, cx
        jne FadeInLoop5
    
    mov cx, [PillarHeight3]
    loop6:
        mov ax, [es:si]
        mov di, si
        sub di, 2
        mov [es:di], ax
        add si, 160
        loop loop6

    ; Lower Pillar
    mov cx, [FadeInWidth3]
    mov si, 3520

    mov di, 0
    FadeInLoop6:
        sub si, 2
        add di, 2
        cmp di, cx
        jne FadeInLoop6
    
    mov cx, [PillarHeightLower3]
    loop7:
        mov ax, [es:si]
        mov di, si
        sub di, 2
        mov [es:di], ax
        sub si, 160
        loop loop7

    add word[FadeInWidth3], 2
    cmp word[FadeInWidth3], 12
    je resetFadeWidth3

    jmp endMovingPillars3

resetFadeWidth3:
    mov word[FadeInWidth3], 2
    mov word[isDrawn3], 0
    jmp endMovingPillars3

movingGround:
    push ax
    push es
    push di
    push si
    push cx
    push dx

    mov ax, 0xB800
    mov es, ax

    mov cx, 3
    mov si, [GroundIndex]
    mov di, 0

    GroundToBuffer:
        mov ax, [es:si]
        mov [GroundBuffer+di], ax
        add si, 160
        add di, 2
        loop GroundToBuffer

    mov di, [GroundIndex]
    mov si, [GroundIndex]
    add si, 2
    mov dx, 0

    GroundOuter:
        mov cx, 79

        push ds
        mov ax, 0xB800
        mov ds, ax
        cld
        rep movsw
        pop ds

        sub di, 158
        sub si, 158
        add di, 160
        add si, 160
        inc dx
        cmp dx, 3
        jne GroundOuter
    
    mov cx, 3
    mov di, [GroundIndex]
    add di, 158
    mov si, 0

    BufferToGround:
        mov ax, [GroundBuffer+si]
        mov [es:di], ax
        add si, 2
        add di, 160
        loop BufferToGround
       
    pop dx
    pop cx
    pop si
    pop di
    pop es
    pop ax
    ret

MoveBirdUP:
    push es
    push di
    push si
    push ax
    push cx

    mov ax, 0xB800
    mov es, ax

    mov di, [BirdIndex]
    mov ax, 0x3020
    mov si, 0

    birdloop1:
        mov cx, 6

        birdloop2:
            mov [es:di], ax
            add di, 2
            loop birdloop2

        sub di, 12
        add di, 160
        inc si
        cmp si, 2
        jne birdloop1

    cmp word[BirdIndex], 240
    jg BirdOneRowAbove
    BackToBird:
    call bird

    pop cx
    pop ax
    pop si
    pop di
    pop es
    ret

MoveBirdDOWN:
    push es
    push di
    push si
    push ax
    push cx

    mov ax, 0xB800
    mov es, ax

    mov di, [BirdIndex]
    mov ax, 0x3020
    mov si, 0

    birdloop3:
        mov cx, 6

        birdloop4:
            mov [es:di], ax
            add di, 2
            loop birdloop4

        sub di, 12
        add di, 160
        inc si
        cmp si, 2
        jne birdloop3

    mov ax, [GroundIndex]
    sub ax, 320

    cmp word[BirdIndex], ax
    jb BirdOneRowBelow
    BackToBird2:
    call bird

    pop cx
    pop ax
    pop si
    pop di
    pop es
    ret

BirdOneRowBelow:
    add word[BirdIndex], 160
    jmp BackToBird2

BirdOneRowAbove:
    sub word[BirdIndex], 160
    jmp BackToBird

Background:
    call drawBackground
    call bird
    call drawPillar
    ret

checkCollision:
    pusha
    push es

    mov si, [BirdIndex]
    add si, 12

    mov ax, 0xB800
    mov es, ax

    mov dx, [es:si]
    cmp dx, 0x2E20
    je collisionDone

    mov si, [BirdIndex]
    mov cx, 6

    collisionLoop:
        mov di, si
        sub di, 160
        mov dx, [es:di]
        add si, 2
        cmp dx, 0x2E20
        je collisionDone
        loop collisionLoop

    ; Lower Part
    mov si, [BirdIndex]
    add si, 332

    mov dx, [es:si]
    cmp dx, 0x2E20
    je collisionDone

    mov si, [BirdIndex]
    add si, 330
    mov cx, 6
    collisionLoop2:
        mov di, si
        mov dx, [es:di]
        add di, 160
        sub si, 2
        cmp dx, 0x2E20
        je collisionDone
        loop collisionLoop2

    mov ax, [GroundIndex]
    sub ax, 320

    cmp word[BirdIndex], ax
    jg collisionDone  

    endCollision:
    pop es
    popa
    ret

GameOverScreen:
    push es
    push ax
    push di
    push si

    mov ax, 0xb800
    mov es, ax

    mov di, 1984
    mov si, 0
    mov ah, 0x3F

    GameOverloop:
        mov al, [GameOverPhrase+si]
        cmp al, '0'
        je endloopGame
        mov [es:di], ax
        inc si
        add di, 2
        jmp GameOverloop
    
    endloopGame:
    pop si
    pop di
    pop ax
    pop es
    ret

collisionDone:

    pusha
    push es

    mov ax, 0xB800
    mov es, ax

    mov di, [BirdIndex]
    mov ax, 0x3020
    mov si, 0

    birdlooping:
        mov cx, 6

        birdlooping2:
            mov [es:di], ax
            add di, 2
            loop birdlooping2

        sub di, 12
        add di, 160
        inc si
        cmp si, 2
        jne birdlooping

    pop es
    popa

    call save
    mov cx, 21

    gameoverLoop:
    call MoveBirdDOWN
    call restore
    call bird
    call printScore
    call delay
    loop gameoverLoop

    call GameOverScreen

    mov ax, 0x3100 ; terminate and stay resident
    int 0x21

restore:
    pusha

    mov cx, 2000 ; number of screen locations

    mov ax, 0xb800
    mov es, ax
    push cs
    pop ds
    mov si, saveBuffer
    mov di, 0
    cld 
    rep movsw 

    popa
    ret

save:
    pusha

    mov cx, 2000

    mov ax, 0xb800
    mov ds, ax ;
    push cs
    pop es
    mov si, 0
    mov di, saveBuffer
    cld 
    rep movsw 

    popa
    ret

PlayAnimation:
    cmp word[escapeFlag], 1
    jne skipEscape
    call PauseScreen
    call WaitForYN     ; Wait for Y/N response

    skipEscape:
    call movePillars
    call movingGround
    cmp word[cs:timerflag], 1
    je skippingAnimation
    call MovingBird
    skippingAnimation:
    call checkCollision
    call printScore
    call delay
    jmp music

printScore:
    pusha
    push es

    mov di, 0
    mov ax, 0x0720
    mov cx, 80

    cld
    rep stosw

    mov ax, 0xb800
    mov es, ax

    mov di, 74
    mov si, 0
    mov ah, 0x0F

    PrintScoreLoop:
        mov al, [ScorePhrase+si]
        cmp al, '0'
        je endPrintingScore
        mov [es:di], ax
        inc si
        add di, 2
        jmp PrintScoreLoop    

    endPrintingScore:
    mov ah, 0x07
    mov al, [score]
    sub ax, 1792
    push ax
    call printnum

    pop es
    popa
    ret

;--------------------------------------------------------------------
; subroutine to print a number at top left of screen
; takes the number to be printed as its parameter
;--------------------------------------------------------------------
printnum: push bp
				mov bp, sp
				push es
				push ax
				push bx
				push cx
				push dx
				push di

				mov ax, 0xb800
				mov es, ax			; point es to video base

				mov ax, [bp+4]		; load number in ax= 4529
				mov bx, 10			; use base 10 for division
				mov cx, 0			; initialize count of digits

nextdigit:		mov dx, 0			; zero upper half of dividend
				div bx				; divide by 10 AX/BX --> Quotient --> AX, Remainder --> DX ..... 
				add dl, 0x30		; convert digit into ascii value
				push dx				; save ascii value on stack

				inc cx				; increment count of values
				cmp ax, 0			; is the quotient zero
				jnz nextdigit		; if no divide it again


				mov di, 88			; point di to top left column
nextpos:		pop dx				; remove a digit from the stack
				mov dh, 0x07		; use normal attribute
				mov [es:di], dx		; print char on screen
				add di, 2			; move to next screen location
				loop nextpos		; repeat for all digits on stack

				pop di
				pop dx
				pop cx
				pop bx
				pop ax
				pop es
				pop bp
				ret 2

;--------------------------------------------------------
; timer interrupt service routine
;--------------------------------------------------------
timer:		push si
            push bx

			cmp word [cs:timerflag], 1 ; is the printing flag set
			jne skipall ; no, leave the ISR

			inc word [cs:seconds] ; increment tick count

			cmp word[cs:seconds], 12
			jne skipall
			mov word[cs:seconds], 0
            mov word[BirdDirection], 0
            mov word[cs:timerflag], 0
            add word[score], 1
            
skipall:	mov bl, [cs:current]				; read index of current task ... bl = 0
			mov ax, 10							; space used by one task
			mul bl								; multiply to get start of task.. 10x0 = 0
			mov bx, ax							; load start of task in bx....... bx = 0

			pop ax								; read original value of bx
			mov [cs:pcb+bx+2], ax				; space for current task's BX

			pop ax								; read original value of ax
			mov [cs:pcb+bx+0], ax				; space for current task's AX

			pop ax								; read original value of ip
			mov [cs:pcb+bx+4], ax				; space for current task

			pop ax								; read original value of cs
			mov [cs:pcb+bx+6], ax				; space for current task

			pop ax								; read original value of flags
			mov [cs:pcb+bx+8], ax					; space for current task

			inc byte [cs:current]				; update current task index...1
			cmp byte [cs:current], 2			; is task index out of range
			jne skipreset						; no, proceed
			mov byte [cs:current], 0			; yes, reset to task 0

skipreset:	mov bl, [cs:current]				; read index of current task
			mov ax, 10							; space used by one task
			mul bl								; multiply to get start of task
			mov bx, ax							; load start of task in bx... 10
			
			mov al, 0x20
			out 0x20, al						; send EOI to PIC

			push word [cs:pcb+bx+8]				; flags of new task... pcb+10+8
			push word [cs:pcb+bx+6]				; cs of new task ... pcb+10+6
			push word [cs:pcb+bx+4]				; ip of new task... pcb+10+4
			mov si, [cs:pcb+bx+0]				; ax of new task...pcb+10+0
			mov bx, [cs:pcb+bx+2]				; bx of new task...pcb+10+2

			iret ; return from interrupt
;--------------------------------------------------------

;-------------------------------------------------------------------
; keyboard interrupt service routine
;-------------------------------------------------------------------
kbisr:      
    push ax
    push es

    mov ax, 0xb800
    mov es, ax

    in al, 0x60        ; read scan code

    cmp al, 0x39       ; space key pressed
    jne nextcmp
    mov word[cs:seconds], 0
    mov word[cs:timerflag], 0
    mov word[BirdDirection], 1
    jmp nomatch

nextcmp:    
    cmp al, 0xb9       ; space key released
    jne checkEsc
    mov word [cs:timerflag], 1
    jmp nomatch

checkEsc:   
    cmp al, 0x01       ; ESC scan code
    jne nomatch
    mov word[escapeFlag], 1
    jmp nomatch

nomatch:    
    pop es
    pop ax
    jmp far [cs:oldisr]

exit:       
    mov al, 0x20
    out 0x20, al
    pop es
    pop ax
    iret
;-------------------------------------------------------------------

PauseScreen:
    pusha
    push es
    push ds

    mov ah, 0x13
		
	mov al, 0
	mov bh, 0
		
	mov bl, 0x3F
	mov cx, 14
	mov dx, 0x0C20

	push ds
	pop es
    push cs
    pop ds
	mov bp, QuitPhrase
		
	INT 0x10

    pop ds
    pop es
    popa
    ret

WaitForYN:
    push ax
checkKey:
    mov ah, 0
    int 16h
    cmp al, 0x79        ; Y key
    je endProgram
    cmp al, 0x6E        ; N key
    je continueGame
    jmp checkKey       ; keep checking if neither Y nor N

continueGame:
    push es
    push cx
    push di

    mov ax, 0xb800
    mov es, ax
    
    mov cx, 14
    mov di, 1984
    mov ax, 0x3020
    EraseLoop:
        mov [es:di], ax
        add di, 2
        loop EraseLoop
    
    pop di
    pop cx
    pop es
    pop ax
    mov word[escapeFlag], 0
    ret

endProgram:
    pop ax
    call ExitWindow

    mov ax, 0x3100 ; terminate and stay resident
    int 0x21

MovingBird:
    pusha

    cmp word[BirdDirection], 1
    jne BirdNextCmp
    call MoveBirdUP
    jmp EndMovingBird

    BirdNextCmp:
    call MoveBirdDOWN

    EndMovingBird:
    popa
    ret

hold:
    push ax
    mov ah, 0
    int 16h
    pop ax
    ret

clearScreen:
    push es
    push ax
    push di
    push cx

    mov ax, 0xb800
    mov es, ax

    mov ax, 0x0720
    mov cx, 2000
    mov di, 0

    cld
    rep stosw

    pop cx
    pop di
    pop ax
    pop es
    ret

IntroPhrase:
    pusha

    mov ax, 0xb800
    mov es, ax

    mov di, 3096
    mov si, 0
    mov ah, 0x8E

    CONTINUEloop2:
        mov al, [CONTINUEPhrase+si]
        cmp al, '0'
        je endCONTINUEloop2
        mov [es:di], ax
        inc si
        add di, 2
        jmp CONTINUEloop2
    
    endCONTINUEloop2:
    popa
    ret

IntroRectangle:
    pusha

    mov ax, 0xb800
    mov es, ax

    mov ah, 0x2E
    mov al, '_'
    mov cx, 40
    mov di, [RectangleIndex]

    cld
    rep stosw

    mov dx, 0
    mov al, '|'
    RectangleLoop1:
        add di, 160
        mov [es:di], ax
        inc dx
        cmp dx, 12
        jne RectangleLoop1


    mov cx, 40
    mov al, '_'

    std
    rep stosw

    mov al, '|'
    mov dx, 0
    RectangleLoop2:
        mov [es:di], ax
        sub di, 160
        inc dx
        cmp dx, 12
        jne RectangleLoop2

    mov si, 0

    FillLoop:

        mov [es:di], di
        add di, 2
        inc si
        cmp si, dx


    mov di, [RectangleIndex]
    add di, 320
    add di, 160
    add di, 30

    mov si, 0
    mov ah, 0x2E

    flappyBirdLoop:
        mov al, [FlappyBird+si]
        cmp al, '0'
        je endFlappyLoop
        mov [es:di], ax
        inc si
        add di, 2
        jmp flappyBirdLoop

    cld
    rep stosw

    endFlappyLoop:
    popa
    ret

NamesAndRollNo:
    pusha

    mov ax, 0xb800
    mov es, ax
    
    fillRect:
        mov ax, 0x2E20
        mov di, [RectangleIndex]
        add di, 162
        mov cx, 39

        mov si, 0
        mov cx, 39
        jmp insidelooper

        outsidelooper:
            mov cx, 39
            sub di, 78
            add di, 160

            insidelooper:
                cld
                rep stosw

            inc si
            cmp si, 11
            jne outsidelooper

        sub di, 80
        add di, 320
        mov cx, 41
        cld
        rep stosw
        sub di, 162
        mov bp, di
        mov al, '|'
        mov [es:di], ax

    mov di, 1818
    mov si, 0
    mov ah, 0x2E

    NameLoop:
        mov al, [Mamoon+si]
        cmp al, '0'
        je nextPrint
        mov [es:di], ax
        inc si
        add di, 2
        jmp NameLoop

    nextPrint:

    mov di, 1846
    mov ax, 0x2E20
    mov [es:di], ax
    mov di, 1848
    mov si, 0

    NameLoop2:
        mov al, [MamoonRollNo+si]
        cmp al, '.'
        je nextPrint2
        mov [es:di], ax
        inc si
        add di, 2
        jmp NameLoop2

    nextPrint2:
    mov di, 1978
    mov si, 0

    NameLoop3:
        mov al, [Manahil+si]
        cmp al, '0'
        je nextPrint3
        mov [es:di], ax
        inc si
        add di, 2
        jmp NameLoop3

    nextPrint3:
    mov di, 2002
    mov ax, 0x2E20
    mov [es:di], ax
    add di, 2
    mov [es:di], ax
    add di, 2
    mov [es:di], ax
    mov di, 2008
    mov si, 0

    NameLoop4:
        mov al, [ManahilRollNo+si]
        cmp al, '.'
        je endFill
        mov [es:di], ax
        inc si
        add di, 2
        jmp NameLoop4
    
    endFill:
        mov ax, 0x2E20
        mov di, [RectangleIndex]
        add di, 80
        mov [es:di], ax
        mov al, '|'
        add di, 1920
        mov [testing], di

    popa
    ret

IntroScreen:
    pusha

    call clearScreen
    call NamesAndRollNo
    call IntroRectangle
    call IntroPhrase

    mov ax, 0xb800
    mov es, ax
    mov di, [testing]
    mov ah, 0x2E
    mov al, '|'
    mov [es:di], ax

    popa
    ret

drawRectangle:
    pusha

    mov ax, 0xb800
    mov es, ax

    mov di, [DialougeBoxIndex]
    mov ax, 0x1F20
    mov si, 0

    drawRectangleLoop1:
        mov cx, 40
        drawRectangleLoop2:
        
        cld
        rep stosw

        add di, 160
        sub di, 80
        inc si
        cmp si, 14
        jne drawRectangleLoop1

    popa
    ret

InstructContinuePhrase:
    pusha

    mov ax, 0xb800
    mov es, ax

    mov di, 2454
    mov si, 0
    mov ah, 0x9F

    CONTINUEloop3:
        mov al, [CONTINUEPhrase2+si]
        cmp al, '0'
        je endCONTINUEloop3
        mov [es:di], ax
        inc si
        add di, 2
        jmp CONTINUEloop3
    
    endCONTINUEloop3:
    popa
    ret

InstructionFunction:
    pusha

    mov ax, 0xb800
    mov es, ax

    mov di, 1170
    mov si, 0
    mov ah, 0x1F

    Instructionloop:
        mov al, [InstructionPhrase+si]
        cmp al, '0'
        je nextInstruction
        mov [es:di], ax
        inc si
        add di, 2
        jmp Instructionloop

    nextInstruction:
    mov di, 1490
    mov si, 0
    mov ah, 0x1F

    Instructionloop2:
        mov al, [InstructionPhrase2+si]
        cmp al, '0'
        je InstructionloopEnd
        mov [es:di], ax
        inc si
        add di, 2
        jmp Instructionloop2
    
    InstructionloopEnd:
    popa
    ret

InsturctionScreen2:
    pusha

    call drawRectangle
    call drawRectangleOutline
    call InstructionFunction
    call InstructContinuePhrase

    popa
    ret

drawRectangleOutline:
    pusha

    mov ax, 0xb800
    mov es, ax

    mov di, [DialougeBoxIndex]
    sub di, 162

    mov cx, 42
    mov ax, 0xFF20

    cld
    rep stosw

    mov si, 0
    sub di, 2
    outlineloop1:
        mov [es:di], ax
        add di, 160
        inc si
        cmp si, 15
        jne outlineloop1

    mov cx, 42

    std
    rep stosw

    mov si, 0
    add di, 2
    outlineloop2:
        mov [es:di], ax
        sub di, 160
        inc si
        cmp si, 15
        jne outlineloop2

    popa
    ret

ExitScreen:
pusha
push es

mov ax, 0xb800
mov es, ax

mov di, 1984
mov si, 0
mov ah, 0x07

Exitloop2:
    mov al, [ExitPhrase+si]
    cmp al, '0'
    je Exitendloop2
    mov [es:di], ax
    inc si
    add di, 2
    jmp Exitloop2
    
Exitendloop2:
pop es
popa
ret

PullDownScreen:
    pusha

    mov ax, 0xb800
    mov es, ax

    mov si, 0
    mov di, 0

    ScreenEndLoop:
    mov cx, 80
    mov ax, 0x0720

        ScreenEndInnerLoop:
        cld
        rep stosw

    call delay
    inc si
    cmp si, 25
    jne ScreenEndLoop

    popa
    ret

ExitWindow:
    call PullDownScreen
    call ExitScreen
    ret
    
main:
    call IntroScreen
    call hold
    call Background
    call InsturctionScreen2
    call hold

    ;_______________________________________________________
    xor ax, ax
	mov es, ax ; point es to IVT base
	mov ax, [es:9*4]
	mov [oldisr], ax ; save offset of old routine
	mov ax, [es:9*4+2]
	mov [oldisr+2], ax ; save segment of old routine

	cli ; disable interrupts
	mov word [es:9*4], kbisr ; store offset at n*4
	mov [es:9*4+2], cs ; store segment at n*4+2
    ;mov word [es:8*4], timer ; store offset at n*4
	;mov [es:8*4+2], cs ; store segment at n*4+
	sti ; enable interrupts

	mov dx, main ; end of resident portion
	add dx, 15 ; round up to next para
	mov cl, 4
	shr dx, cl ; number of paras..../2^4
    call Background 

    mov word [pcb+10+4], PlayAnimation		; initialize ip
    mov [pcb+10+6], cs						; initialize cs
    mov word [pcb+10+8], 0x0200				; initialize flags

    mov word [pcb+20+4], music			; initialize ip
    mov [pcb+20+6], cs						; initialize cs
    mov word [pcb+20+8], 0x0200				; initialize flags

    mov word [current], 0						; set current task index
    xor ax, ax
    mov es, ax									; point es to IVT base
    
    cli
    mov word [es:8*4], timer
    mov [es:8*4+2], cs							; hook timer interrupt
    mov ax, 0xb800
    mov es, ax									; point es to video base
    xor bx, bx									; initialize bx for tasks, bx=0
    sti
    
    mov si, 0

    jmp $										; infinite loop ... Task 0
    ;________________________________________________________
	mov ax, 0x4C00
    int 0x21