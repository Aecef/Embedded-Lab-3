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

; MODE Td. Functions before Td called on startup and are default calls
ldi r31, 0 ; Leftmost digit
ldi r30, 0 ; Rightmost digit
sbi PORTB, 5 ; Turn on pullup resistor for pushbutton
rcall count1 ; Push rightmost digit
rcall count2 ; Push leftmost digit
setup_td:
;rcall count1
;rcall count2
sbis PINB,5
rjmp setup_td
td:
	sbis PINB, 5
		rjmp check_debounce_pushbutton_td
	sbis PINB, 4
		rjmp check_debounce_A
	sbis PINB, 3
		rjmp check_debounce_B
rjmp td ; Otherwise go back to the start of f1

; Check if button is pressed with debounce
check_debounce_pushbutton_td:
	rcall debounce_pushbutton
	cp r24, r25
	brlo pushbutton_pressed_td
	rjmp td

; Pushbutton is pressed so switch to MODE Tc
pushbutton_pressed_td:
	rjmp setup_tc

; Send to check for debounce for incrementing display
check_debounce_A:
	sbis PINB, 4
	rjmp zero_zero_state
	rjmp td

; Send to check for debounce for decrementing display
check_debounce_B:
	sbis PINB, 3
	rjmp zero_zero_state
	rjmp td

; Find out if the button is in the 00 state with a debounce and determine if display needs to be updated
zero_zero_state:
	rcall debounce_rpg
	cp r24, r25
	brlo rpg_active
	rjmp td

; Determine if the display is incrementing or decrementing, branch to correct function
rpg_active:
	sbic PINB, 4
		rjmp inc_display
	sbic PINB, 3
		rjmp dec_display
	rjmp rpg_active

; Incrementing display code
inc_display:
	cpi r31, 9
	breq check_99
	rcall increment_right
	rcall count1
	rcall count2
	rjmp td

; Checks if display is at 99. If so, don't increment
check_99:
	cpi r30, 9
		breq td
	rcall increment_right
	rcall count1
	rcall count2
	rjmp td

; Decrementing display code
dec_display:
	cpi r31, 0
		breq check_00
	rcall decrement_right
	rcall count1
	rcall count2
	rjmp td

; Checks if display is at 00. If so, don't decrement
check_00:
	cpi r30, 0
		breq td
	rcall decrement_right
	rcall count1
	rcall count2
	rjmp td

; Increments rightmost digit
increment_right:
	inc r30
	cpi r30, 10
	breq increment_left
ret

; Increments leftmost digit
increment_left:
	ldi r30, 0
	inc r31
ret

; Decrements rightmost digit
decrement_right:
	cpi r30, 0
	breq decrement_left
	dec r30
ret

; Decrements leftmost digit
decrement_left:
	ldi r30, 9
	dec r31
ret

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

; Debounce for the rpg
debounce_rpg:
	ldi  r25, 0 ;Tracks 1s
    ldi  r24, 0 ;Tracks 0s
    ldi  r23, 20 ;Loop Count 1.5ms total. Min delay is 2.5ms so this is okay 
D1: dec  r23
	sbis PINB, 3
	inc r25
	sbis PINB, 4
	inc r25
	sbic PINB, 3
	inc r24
	sbic PINB, 4
	inc r24
	rcall delay_shorter
    brne D1
ret

; Debounce for the pushbutton
debounce_pushbutton:
	ldi r25, 0
	ldi r24, 0
	ldi r23, 15
D2: dec r23
	sbis PINB, 5
	inc r25
	sbic PINB, 5
	inc r24
	rcall delay_shorter
	brne D2
ret

; 1 ms delay
delay_short:
  ldi  r26, 7
    ldi  r27, 255
    ldi  r28, 255
L1: dec  r28
    brne L1
    dec  r27
    brne L1
    dec  r26
    brne L1
    nop
ret

; .1 ms delay
delay_shorter:
	ldi  r26, 3
    ldi  r27, 19
L2: dec  r27
    brne L2
    dec  r26
    brne L2
ret

; MODE Tc
setup_tc:
	ldi r22, 0 ; Leftmost digit for tc
	ldi r21, 0 ; Rightmost digit for tc
	rcall count3
	rcall count4
	sbis PINB, 5
	rjmp setup_tc
tc:
	sbis PINB, 5
	rjmp check_debounce_pushbutton_tc

rjmp tc

; Check if button is pressed with debounce
check_debounce_pushbutton_tc:
	rcall debounce_pushbutton
	cp r24, r25
	brlo pushbutton_pressed_tc
	rjmp tc

pushbutton_pressed_tc:
	rcall count1 ; Do this here to prevent lag
	rcall count2
	rjmp setup_td

n_0:
	lds R16, LUT
	rcall display
ret
n_1:
	lds R16, LUT+1
	rcall display
ret
n_2:
	lds R16, LUT+2
	rcall display
ret
n_3:
	lds R16, LUT+3
	rcall display
ret
n_4:
	lds R16, LUT+4
	rcall display
ret

count3:
	cpi r21, 0
	breq n_0
	cpi r21, 1
	breq n_1
	cpi r21, 2
	breq n_2
	cpi r21, 3
	breq n_3
	cpi r21, 4
	breq n_4
	cpi r21, 5
	breq n_5
	cpi r21, 6
	breq n_6
	cpi r21, 7
	breq n_7
	cpi r21, 8
	breq n_8
	cpi r21, 9
	breq n_9
ret
count4:
	cpi r22, 0
	breq n_0
	cpi r22, 1
	breq n_1
	cpi r22, 2
	breq n_2
	cpi r22, 3
	breq n_3
	cpi r22, 4
	breq n_4
	cpi r22, 5
	breq n_5
	cpi r22, 6
	breq n_6
	cpi r22, 7
	breq n_7
	cpi r22, 8
	breq n_8
	cpi r22, 9
	breq n_9
ret
n_5:
	lds R16, LUT+5
	rcall display
ret
n_6:
	lds R16, LUT+6
	rcall display
ret
n_7:
	lds R16, LUT+7
	rcall display
ret
n_8:
	lds R16, LUT+8
	rcall display
ret
n_9:
	lds R16, LUT+9
	rcall display
ret

