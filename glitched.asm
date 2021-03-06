;================================================================================
; Glitched Mode Fixes
;================================================================================
GetAgahnimPalette:
	LDA $A0 ; get room id
	CMP.b #13 : BNE + ; Agahnim 2 room
		LDA.b #$07 ; Use Agahnim 2
		RTL
	+ ; Elsewhere
		LDA.b #$0b ; Use Agahnim 1
		RTL
;--------------------------------------------------------------------------------
GetAgahnimDeath:
	STA $0BA0, X ; thing we wrote over
	LDA $A0 ; get room id
	CMP.b #13 : BNE + ; Agahnim 2 room
		LDA.l Bugfix_SetWorldOnAgahnimDeath : BEQ ++
			LDA.b #$40 : STA !DARK_WORLD ; Switch to dark world
		++
		LDA.b #$01 ; Use Agahnim 2
		RTL
	+ ; Elsewhere
		LDA.l Bugfix_SetWorldOnAgahnimDeath : BEQ ++
			LDA.b #$00 : STA !DARK_WORLD ; Switch to light world
			; (This will later get flipped to DW when Agahnim 1
			; warps us to the pyramid)
		++
		LDA.b #$00 ; Use Agahnim 1
		RTL
;--------------------------------------------------------------------------------
GetAgahnimType:
	LDA $A0 ; get room id
	CMP.b #13 : BNE + ; Agahnim 2 room
		LDA.b #$0006 ; Use Agahnim 2
		BRA .done
	+ ; Elsewhere
		LDA.b #$0001 ; Use Agahnim 1
	.done
RTL
;--------------------------------------------------------------------------------
GetAgahnimSlot:
	PHX ; thing we wrote over
	LDA $A0 ; get room id
	CMP.b #13 : BNE + ; Agahnim 2 room
		LDA.b #$01 ; Use Agahnim 2
		JML.l GetAgahnimSlotReturn
	+ ; Elsewhere
		LDA.b #$00 ; Use Agahnim 1
		JML.l GetAgahnimSlotReturn
;--------------------------------------------------------------------------------
GetAgahnimLightning:
	INC $0E30, X ; thing we wrote over
	LDA $A0 ; get room id
	CMP.b #13 : BNE + ; Agahnim 2 room
		LDA.b #$01 ; Use Agahnim 2
		RTL
	+ ; Elsewhere
		LDA.b #$00 ; Use Agahnim 1
		RTL
;--------------------------------------------------------------------------------
;0 = Allow
;1 = Forbid
AllowJoypadInput:
	LDA PermitSQFromBosses : BEQ .fullCheck
	LDA $0403 : AND.b #$80 : BEQ .fullCheck
		LDA $0112 : ORA $02E4 ; we have heart container, do short check
RTL
	.fullCheck
	LDA $0112 : ORA $02E4 : ORA $0FFC
RTL
;--------------------------------------------------------------------------------
; add sign to EDM for OWG people to read
;--------------------------------------------------------------------------------
AddSignToEDMBridge:
	LDA $040A : AND #$00FF : CMP #$0005 : BNE .no_changes
		LDA #$0101 : STA $7E2D98 ;#$0101 is the sign tile16 id, $7E2D98 is the position of the tile16 on map
	.no_changes

	LDX.w #$001E ;Restore Previous Code
	LDA.w #$0DBE ;Restore Previous Code
RTL
;--------------------------------------------------------------------------------

