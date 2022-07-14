;
;       	  Real Time Project 4
;
;			Tareq Shannak - 1181404
;		Abdulghaffar Al-Abed - 1180071
;			Waseem Sayara - 1182733
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 

	PROCESSOR	16F877	; Define MCU type 
	#INCLUDE	P16F877A.INC
	ERRORLEVEL	-302 ; Disable Bank Switch Warning
	ERRORLEVEL	-305 ; Disable Default Destination Message
	CBLOCK	0X25
		STEP
		T
		Register1
		Register2
		Register3
		Register4
	ENDC

	__CONFIG	0x3733		; Set Config Fuses

INTCON	EQU	0B	; Interrupt Control Register
OPTREG	EQU	80	; Option Register

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	ORG	000				; Start of Program Memory
    NOP					; For ICD mode
	GOTO	INIT		; Jump to Main Program

	ORG	004				; Interrupt Service Routine (ISR):
    BANKSEL	TRISC 
    BCF		INTCON , 7	; Disable All Interrupts
    BANKSEL	PORTC
Interrupt1 
	BTFSC	PORTB,5		; Check if the button on RB5 is pressed
	GOTO	Interrupt2	; If not, Go to ISR2

	INCF	STEP		; Increment STEP
	BTFSC	STEP,1 		; Check If Step == 6: Step[1] == 0?
	BTFSS	STEP,2		; Step[2] == 1?
	GOTO	RET

RESET_STEP				; If Step == 6, execute the next instructions:
	MOVLW	D'1'		; Step = 1
	MOVWF	STEP
	GOTO	RET

Interrupt2 
	BTFSC	PORTB,4		; Check if the button on RB4 is pressed
	GOTO	RET			; If not, Go to RET
	INCF	T			; Increment T
	BTFSC	T,1			; Check If T == 6: T[1] == 0?
	BTFSS	T,2			; T[2] == 1?
	GOTO	RET

RESET_T					; If T == 6, execute the next instructions:
	MOVLW	D'1'		; T = 1
	MOVWF	T
	GOTO	RET

RET
	MOVWF	TRISD		; Go To Bank0
	BCF		INTCON,0	; Ensure That No Pins Have Changed Its State
	BSF		INTCON,7	; Enable All Unmasked Interrupts  
	RETFIE				; Return From The Interrupt

						; Initialise Port C
INIT	NOP				; BANKSEL Can't Be Labelled
	BANKSEL	TRISC		; Select Bank 1
	MOVLW	b'00000000'	; Port B Direction Code
	MOVWF	TRISC		; Load the DDR code into F86

						; Initialise Timer0
	MOVLW	b'11010000'	; TMR0 initialisation code
	MOVWF	OPTREG		; Int clock, no prescale	
	BANKSEL	TRISC		; Select bank 0
	MOVLW	8B			; INTCON init. code
	MOVWF	INTCON		; Enable TMR0 interrupt


	MOVLW	D'1'		; Initialise The Variables (STEP & T)
	MOVWF	STEP		; STEP = 1
	MOVWF	T			; T = 1

RRESET
	CLRF	PORTC  		; Clear Port C Data 
START   
	MOVF	T,W			; Move Number of Seconds To Delay Into Register4
	MOVWF	Register4  
T_SECONDS				; Delay T Seconds
	CALL	ONE_SECOND
	DECFSZ	Register4,F
	GOTO	T_SECONDS

	MOVF	PORTC,W		; Read Last Output
	ADDWF	STEP,W		; Add Step To The Output
	MOVWF	Register3	; Move It To Variable (For Checking)
	BTFSC	Register3,5	; If Regiter3 >= 32? Go to RRESET
	GOTO	RRESET

	MOVWF	PORTC		; Show Output In LEDs
	GOTO	START       ; Repeat Loop
	

ONE_SECOND				; Delay One Second Function
	MOVLW	d'24' 
	MOVWF	Register3
L1   
	MOVLW	d'200' 
	MOVWF	Register2 
L2	
	MOVLW	D'40'
	MOVWF	Register1	
L3	NOP
	DECFSZ	Register1 ,f
	GOTO	L3

	NOP
	DECFSZ	Register2 ,f
	GOTO	L2

	DECFSZ	Register3 , f
	GOTO	L1 

	RETURN 

	END
