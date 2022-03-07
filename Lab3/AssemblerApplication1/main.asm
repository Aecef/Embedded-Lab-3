;
; AssemblerApplication1.asm
;
; Created: 3/1/2022 2:46:18 PM
; Author : erbrewer
;


sbi DDRB, 0 ; SER as output
sbi DDRB, 1 ; SRCLK as output
sbi DDRB, 2 ; RCLK as output
cbi DDRB, 3 ; Signal A
cbi DDRB, 4 ; Signal B
cbi DDRB, 5 ; Pushbutton



; start main program
.dseg
.org 0x100
LUT: .byte 23 ; Need 1-9 with periods and without, plus the dash for output and a Nothing case (all lights are off)
.cseg


; Display 0.
ldi R16, 0b11101011
sts LUT, R16

; Display 1.
ldi R16, 0b01001000
sts LUT+1, R16

; Display 2.
ldi R16, 0b11010011
sts LUT+2, R16

; Display 3.
ldi R16, 0b11011010
sts LUT+3, R16

; Display 4.
ldi R16, 0b01111000
sts LUT+4, R16

; Display 5.
ldi R16, 0b10111010
sts LUT+5, R16

; Display 6.
ldi R16, 0b00111011
sts LUT+6, R16

; Display 7.
ldi R16, 0b11001000
sts LUT+7, R16

; Display 8.
ldi R16, 0b11111011
sts LUT+8, R16

; Display 9.
ldi R16, 0b11111000
sts LUT+9, R16

; Display Dash
ldi R16, 0b00001000
sts LUT+10, R16

; Display 0
ldi R16, 0b11101111
sts LUT+11, R16

; Display 1
ldi R16, 0b01001100
sts LUT+12, R16

; Display 2
ldi R16, 0b11010111
sts LUT+13, R16

; Display 3
ldi R16, 0b11011110
sts LUT+14, R16

; Display 4
ldi R16, 0b01111100
sts LUT+15, R16

; Display 5
ldi R16, 0b10111110
sts LUT+16, R16

; Display 6
ldi R16, 0b00111111
sts LUT+17, R16

; Display 7
ldi R16, 0b11001100
sts LUT+18, R16

; Display 8
ldi R16, 0b11111111
sts LUT+19, R16

; Display 9
ldi R16, 0b11111100
sts LUT+20, R16

;------------------------------------------------------------------
; Setup MODE A
;------------------------------------------------------------------
setup_f1:
	ldi r31, 0 ; Leftmost digit
	ldi r30, 0 ; Rightmost digit
	rcall count1
	rcall count2
f1:
	sbic PINB, 4
		rjmp t1
	sbis PINB, 4
		rjmp t2
	rjmp f1 ; Otherwise go back to the start of f1
;min_val:
;	cpi r30, 0
;	rjmp d2
;rjmp f1
;max_val:
;	cpse r31, r30
;	rjmp d1
rjmp f1
t1:
	;cpi r31, 9
	;breq max_val
;d1:
	sbis PINB, 3
	breq test1
	rjmp f1
t2:
	;cpi r31, 0
	;breq min_val
;d2:
	sbis PINB, 3
	breq test2
	rjmp f1
test1:
	rcall increment_right
	rcall count1
	rcall count2
	rcall delay_short
C1:	sbic PINB, 3
	rjmp f1
rcall delay_short
rjmp C1

test2:
rcall decrement_right
rcall count1
rcall count2
rcall delay_short
C2: sbic PINB, 4
	rjmp f1
rcall delay_short
rjmp C2

;-----------------------------------------------------------------
; Display Digits
;------------------------------------------------------------------
; to display for two digits, need to run display function twice. The first display call places the rightmost digit, the latter does the leftmost digit. 
display: 
push R16 ; Put R16 on stack
push R18 ; Put R18 on stack
in R18, SREG
push R18

ldi R18, 8 ; Loop --> test all 8 bits
loop:
	rol R16 ; Rotate left through Carry
	brcs set_ser_in_1 ; Branch if Carry is set;
	cbi PORTB, 0 ; Set SER to 0
	rjmp end

set_ser_in_1:
	sbi PORTB, 0 ; Set SER to 1

end:
sbi PORTB, 1 ; Set SRCK to 1
cbi PORTB, 1 ; Set SRCK to 0
dec R18
brne loop

sbi PORTB, 2 ; Set RCLK to 1
cbi PORTB, 2 ; Set RCLE to 0

; restore registers from stack
pop R18
out SREG, R18
pop R18
pop R16
ret

; Increment and Decrement functions for left and right digits
increment_right:
	inc r30
	cpi r30, 10
	breq increment_left
ret
increment_left:
	ldi r30, 0
	inc r31
ret
decrement_right:
	cpi r30, 0
	breq decrement_left
	dec r30
ret
decrement_left:
	ldi r30, 9
	dec r31
ret

;------------------------------------------------------------------
; Count functions decide which digit to display and display it
;------------------------------------------------------------------
d_0:
	lds R16, LUT+11
	rcall display
ret
d_1:
	lds R16, LUT+12
	rcall display
ret
d_2:
	lds R16, LUT+13
	rcall display
ret
d_3:
	lds R16, LUT+14
	rcall display
ret
d_4:
	lds R16, LUT+15
	rcall display
ret
count1:
	cpi r30, 0
	breq d_0
	cpi r30, 1
	breq d_1
	cpi r30, 2
	breq d_2
	cpi r30, 3
	breq d_3
	cpi r30, 4
	breq d_4
	cpi r30, 5
	breq d_5
	cpi r30, 6
	breq d_6
	cpi r30, 7
	breq d_7
	cpi r30, 8
	breq d_8
	cpi r30, 9
	breq d_9
ret
count2:
	cpi r31, 0
	breq d_0
	cpi r31, 1
	breq d_1
	cpi r31, 2
	breq d_2
	cpi r31, 3
	breq d_3
	cpi r31, 4
	breq d_4
	cpi r31, 5
	breq d_5
	cpi r31, 6
	breq d_6
	cpi r31, 7
	breq d_7
	cpi r31, 8
	breq d_8
	cpi r31, 9
	breq d_9
ret
d_5:
	lds R16, LUT+16
	rcall display
ret
d_6:
	lds R16, LUT+17
	rcall display
ret
d_7:
	lds R16, LUT+18
	rcall display
ret
d_8:
	lds R16, LUT+19
	rcall display
ret
d_9:
	lds R16, LUT+20
	rcall display
ret

;------------------------------------------------------------------
;------------------------------------------------------------------
debounce:
	ldi  r19, 0 ;Tracks 1s
    ldi  r20, 0 ;Tracks 0s
    ldi  r23, 10 ;Loop Count
	ldi  r24, 0 
L5: dec  r23
	sbis PINB , 3
	inc r20
	sbic PINB, 3
	inc r19
	;rcall delay_shorter
    brne L5
	cp r19, r20
	;brge pushed_A
ret


delay_short:
  ldi  r26, 7
    ldi  r27, 255
    ldi  r28, 255
L2: dec  r28
    brne L2
    dec  r27
    brne L2
    dec  r26
    brne L2
    nop
ret

