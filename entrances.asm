;--------------------------------------------------------------------------------
; LockAgahnimDoors:
; Returns: 0=Unlocked - 1=Locked
;--------------------------------------------------------------------------------
LockAgahnimDoors:
	LDA.l AgahnimDoorStyle
	BNE +
		;#$0 = Never Locked
		LDA.w #$0000 : RTL
	+ : CMP.w #$0001 : BNE +
		LDA $7EF3C5 : AND.w #$000F : CMP.w #$0002 : !BGE .unlock ; if we rescued zelda, skip
			JSR.w LockAgahnimDoorsCore : RTL
	+ : CMP.w #$0002 : BNE +
		LDA $7EF37A : AND.w #$007F : CMP.w #$007F : BEQ .unlock
			JSR.w LockAgahnimDoorsCore : RTL
	+
	.unlock
	LDA.w #$0000 ; fallback to never locked
RTL
;--------------------------------------------------------------------------------
LockAgahnimDoorsCore:
	LDA $22 : CMP.w #1992 : !BLT + ; door too far left, skip
			  CMP.w #2088 : !BGE + ; door too rat right, skip
	LDA $20 : CMP.w #1720 : !BGE + ; door too low, skip
		LDA.w #$0001
RTS
	+
	LDA.w #$0000
RTS
;--------------------------------------------------------------------------------
SmithDoorCheck:
	LDA.l SmithTravelsFreely : AND.w #$00FF : BEQ .orig
		;If SmithTravelsFreely is set Frog/Smith can enter multi-entrance overworld doors
		JML.l Overworld_Entrance_BRANCH_RHO

	.orig ; The rest is equivlent to what we overwrote
	CPX.w #$0076 : !BGE +
		JML.l Overworld_Entrance_BRANCH_LAMBDA
	+

JML.l Overworld_Entrance_BRANCH_RHO
;--------------------------------------------------------------------------------
AllowStartFromSingleEntranceCave:
; 16 Bit A, 16 bit XY
; do not need to preserve A or X or Y
	LDA $7EF3C8 : AND.w #$00FF ; What we wrote over
	PHA
		TAX

		LDA.l StartingAreaExitOffset, X

		BNE +
			BRL .done
		+

		DEC
		STA $00
		LSR #2 : !ADD $00 : LSR #2 ; mult by 20
		TAX

		LDA #$0016 : STA $7EC142 ; Cache the main screen designation
		LDA.l StartingAreaExitTable+$05, X : STA $7EC144 ; Cache BG1 V scroll
		LDA.l StartingAreaExitTable+$07, X : STA $7EC146 ; Cache BG1 H scroll
		LDA.l StartingAreaExitTable+$09, X : !ADD.w #$0010 : STA $7EC148 ; Cache Link's Y coordinate
		LDA.l StartingAreaExitTable+$0B, X : STA $7EC14A ; Cache Link's X coordinate
		LDA.l StartingAreaExitTable+$0D, X : STA $7EC150 ; Cache Camera Y coord lower bound.
		LDA.l StartingAreaExitTable+$0F, X : STA $7EC152 ; Cache Camera X coord lower bound.
		LDA.l StartingAreaExitTable+$03, X : STA $7EC14E ; Cache Link VRAM Location

		; Handle the 2 "unknown" bytes, which control what area of the backgound
		; relative to the camera? gets loaded with new tile data as the player moves around
		; (because some overworld areas like Kak are too big for a single VRAM tilemap)

		LDA.l StartingAreaExitTable+$11, X : AND.w #$00FF
		BIT.w #$0080 : BEQ + : ORA #$FF00 : + ; Sign extend
		STA.l $7EC16A

		LDA.l StartingAreaExitTable+$12, X  : AND.w #$00FF
		BIT.w #$0080 : BEQ + : ORA #$FF00 : + ; Sign extend
		STA.l $7EC16E

		LDA.w #$0000 : !SUB.l $7EC16A : STA $7EC16C
		LDA.w #$0000 : !SUB.l $7EC16E : STA $7EC170

		LDA.l StartingAreaExitTable+$02, X : AND.w #$00FF
		STA $7EC14C ; Cache the overworld area number
		STA $7EC140 ; Cache the aux overworld area number

		SEP #$20 ; set 8-bit accumulator
		LDX $00
		LDA.l StartingAreaOverworldDoor, X : STA.l $7F5099 ;Load overworld door
		REP #$20 ; reset 16-bit accumulator

		.done
	PLA
RTL
;--------------------------------------------------------------------------------
CheckHole:
	LDX.w #$0024
	.nextHoleClassic
		LDA.b $00   : CMP.l $1BB800, X
		BNE .wrongMap16Classic
		LDA.w $040A : CMP.l $1BB826, X
		BEQ .matchedHoleClassic
	.wrongMap16Classic
		DEX #2 : BPL .nextHoleClassic

	LDX.w #$001E
	.nextHoleExtra
		LDA.b $00   : CMP.l ExtraHole_Map16, X
		BNE .wrongMap16Extra
		LDA.w $040A : CMP.l ExtraHole_Area, X
		BEQ .matchedHoleExtra
	.wrongMap16Extra
		DEX #2 : BPL .nextHoleExtra
	JML Overworld_Hole_GotoHoulihan

	.matchedHoleClassic
		JML Overworld_Hole_matchedHole
	.matchedHoleExtra
		SEP #$30
		TXA : LSR A : TAX
		LDA.l ExtraHole_Entrance, X : STA.w $010E : STZ.w $010F
JML Overworld_Hole_End
;--------------------------------------------------------------------------------
