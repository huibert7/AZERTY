;
; Predefined labels:
KBD            gequ $C000
KBDSTROBE      gequ $C010

               dc  a2'Open'
               dc  a2'Close'
               dc  a2'Action'
               dc  a2'Init'
NDAHeader      dc  i2'$FFFF'            ;Period
               dc  i2'$0143'            ;Event mask
               dc  h'2020'
               dc  c'Azerty\H**'
               dc  h'00'

Open           lda >WinExists
               beq FullOpen
               pea WinPtr|-$10
               pea WinPtr
               _SelectWindow
               rtl
FullOpen       pea $0000
               pea $0000
               pea WinParamLst|-$10
               pea WinParamLst
               _NewWindow
               plx
               pla
               sta $06,s
               sta >WinPtr+2
               txa
               sta $04,s
               sta >WinPtr
               pea $0000
               pea $0000
               lda >WinPtr+2
               pha
               lda >WinPtr
               pha
               pea CtlRect|-$10
               pea CtlRect
               pea CtlTitle|-$10
               pea CtlTitle
               pea $0000                ;Bit flag
               lda >CtlValue            ;Control initial value
               pha
               pea $0000                ;Additional param (view size for scroll b	
               pea $0000                ;Additional param (data size for scroll b
               pea $0200                ;$02000000 for a Check box control
               pea $0000
               pea $0000                ;Reserved for application used
               pea $0000                ;Reserved for application use
               pea $0000                ;NIL (4 bytes) for default color table
               pea $0000
               _NewControl
               pla
               sta >CtlHandle2
               pla
               sta >CtlHandle2+2
               lda >WinPtr+2
               pha
               lda >WinPtr
               pha
               _SetSysWindow
               lda #$FFFF
               sta >WinExists
               rtl

WinParamLst    dc  i2'$004E'            ;paramLength
               dc  i2'$C0A0'            ;Bit flag that defines window frame type
               dc  a4'$010B'            ;wTitle - Pointer to window's title
               dc  i4'$00000000'        ;wRefCon
               dc  i2'$0000,$0000,$0000,$0000'
               dc  i4'$00000000'        ;wColor
               dc  i2'$0000'            ;wYOrigin
               dc  i2'$0000'            ;wXOrigin
               dc  i2'$0000'            ;wDataH
               dc  i2'$0000'            ;wDataW
               dc  i2'$0000'            ;wMaxH
               dc  i2'$0000'            ;wMaxW
               dc  i2'$0000'            ;wScrollVer
               dc  i2'$0000'            ;wScrollHor
               dc  i2'$0000'            ;wPageVer
               dc  i2'$0000'            ;wPageHor
               dc  i4'$00000000'        ;wInfoRefCon
               dc  i2'$0000'            ;wInfoHeight
               dc  i4'$00000000'        ;wFrameDefProc
               dc  i4'$00000000'        ;wInfoDefProc
               dc  i4'$00000000'        ;wContDefProc
               dc  i2'$0032,$0046,$006E,$012C'
               dc  i4'$FFFFFFFF'
               dc  i4'$00000000'
               dw  'AZERTY'

RedrawWin      lda WinPtr+2
               pha
               lda WinPtr
               pha
               _BeginUpdate
               pea ClearRect|-$10
               pea ClearRect
               _EraseRect
               pea $0007
               pea $000A
               _MoveTo
               pea Description|-$10
               pea Description
               _DrawString
               pea $0007
               pea $0016
               _MoveTo
               pea Copyright|-$10
               pea Copyright
               _DrawString
               pea $0007
               pea $0022
               _MoveTo
               pea Author|-$10
               pea Author
               _DrawString
               pea $0000
               pea $002C
               _MoveTo
               pea $00E6
               pea $002C
               _LineTo
               lda WinPtr+2
               pha
               lda WinPtr
               pha
               _DrawControls
               lda WinPtr+2
               pha
               lda WinPtr
               pha
               _EndUpdate
               rtl

PressedAccent  brk $00                  ;If !=0, an accent key has been pressed
WinExists      dc  i2'$0000'
WinPtr         dc  i4'$00000000'
Description    dw  'Clavier Azerty pour le IIgs'
Copyright      dw  '(c) 1988'
Author         dw  'Huibert Aalbers'
CtlTitle       dw  'Accessoire actif'
ClearRect      dc  i2'$0000,$0000,$003C,$00E6'
CtlRect        dc  i2'$002F,$0019,$003B,$00C8'
CtlHandle2     dc  i4'$00000000'
CtlHandle      dc  i4'$00000000'
PointY         dc  i2'$0000'
PointX         dc  i2'$0000'
CtlValue       dc  i2'$0001'

Close          phb
               phk
               plb
               lda >WinExists
               beq skip
               lda WinPtr+2
               pha
               lda WinPtr
               pha
               _CloseWindow
               lda #$0000
               sta >WinExists
skip           plb
               rtl

Action         phb
               phk
               plb
               phy
               phx
               asl a
               tax
               jsr (JmpTable,x)
               pla
               pla
               plb
               rtl

JmpTable       dc  a2'Ignore'           ;Action code 0, never sent
               dc  a2'EventAction'      ;Action code 1, Event (the one we care ab
               dc  a2'Ignore'           ;Action code 2, Run (ignore)
               dc  a2'Ignore'           ;Action code 3, Cursor (ignore)
               dc  a2'Ignore'           ;Action code 4, Reserved (ignore)
               dc  a2'Ignore'           ;Action code 5, Undo (ignore)
               dc  a2'Ignore'           ;Action code 6, Cut (ignore)
               dc  a2'Ignore'           ;Action code 7, Copy (ignore)
               dc  a2'Ignore'           ;Action code 8, Paste (ignore)
               dc  a2'Ignore'           ;Action code 9, Clear (ignore)

Ignore         rts

EventAction    longa on
               longi on
               phd
               tsc
               tcd
               ldy #$000A
               lda [$05],y
               sta PointY
               iny
               iny
               lda [$05],y
               sta PointX
               lda [$05]
               pld
               cmp #$0006
               beq Redraw
               cmp #$0001
               beq HandleClick
               pea $0000
               pea $0000
               _GetPort
               lda WinPtr+2
               pha
               lda WinPtr
               pha
               _SetPort
               lda WinPtr+2
               pha
               lda WinPtr
               pha
               _DrawControls
               _SetPort
               rts
Redraw         jsl >RedrawWin
               rts

HandleClick    pea $0000
               pea CtlHandle|-$10
               pea CtlHandle
               lda PointX
               pha
               lda PointY
               pha
               lda WinPtr+2
               pha
               lda WinPtr
               pha
               _FindControl
               pla
               beq ClickHandled         ;User didn't click on a control
               pea $0000
               lda PointX
               pha
               lda PointY
               pha
               pea $0000
               pea $0000
               lda CtlHandle+2
               pha
               lda CtlHandle
               pha
               _TrackControl
               pla
               beq ClickHandled         ;User released button outside of control
               pea $0000
               lda CtlHandle+2
               pha
               lda CtlHandle
               pha
               _GetCtlValue
               pla
               eor #$0001               ;Toggle control value
               sta CtlValue
               pha
               lda CtlHandle+2
               pha
               lda CtlHandle
               pha
               _SetCtlValue
ClickHandled   rts

Init           longa on
               longi on
               pea $0000
               pea $0000
               pea $000F                ;Keyboard  interrupt handler
               _GetVector
               pla
               sta >$038B
               pla
               sep #$20
               longa off
               sta >$038D
               rep #$20
               longa on
               pea $000F                ;Keyboard  interrupt handler
               pea ProcessInt|-$10
               pea ProcessInt
               _SetVector
               lda #$0000
               sta PressedAccent
               rtl

WeirdRTS       rts

ProcessInt     longa off
               longi off
               phb
               phk
               plb
               lda CtlValue
               beq NDAInactive
               lda >KBD                 ;keyboard latch
               and #$7F
               ldx #$06
L0             cmp SpecChars,x
               beq Remap
               dex
               bpl L0
               ldx #$03
L1             cmp Accents,x
               beq HandleAccent
               dex
               bpl L1
               ldy PressedAccent
               bne ChrAfterAccent
NDAInactive    plb
Jmp2NormalInt  jmp >$000000             ;Code will modify address
HandleAccent   inx                      ;Store accent index+1 for later
               stx PressedAccent        ;processing
               sta >KBDSTROBE           ;turn off keypressed flag
               clc
               plb
               rtl

Remap          sta >KBDSTROBE           ;turn off keypressed flag
               lda AltSpecChars,x       ;Re-map special characters
               sec
               sbc #$40
               ora #$80			;Add appleKey modifier
               sta KeyEvent		;Store keyEvent
               rep #$30
               longa on
               longi on
               pea $0000
               pea $0003
               pea $0000
               lda KeyEvent
               pha
               _PostEvent
               pla
               sep #$30
               longa off
               longi off
               clc
               plb
               rtl

ChrAfterAccent ldx #$09
L2             cmp Vowels,x
               beq AccentedChar
               dex
               bpl L2
               sta KeyEvent             ;Not a vowel
               ldx PressedAccent        ;Print the accent and then the second cha
               dex
               lda Accents,x
               rep #$30
               longa on
               longi on
               and #$00FF
               pea $0000
               pea $0003
               pea $0000
               pha
               _PostEvent
               pla
               pea $0000
               pea $0003
               pea $0000
               lda KeyEvent
               pha
               _PostEvent
               pla
               sep #$30
               longa off
               longi off
               lda #$00
               sta PressedAccent
               sta >KBDSTROBE           ;turn off keypressed flag
               clc
               plb
               rtl

AccentedChar   ldy PressedAccent
               dey
               cpy #$00
               beq HandleCirc
               cpy #$01
               beq HandleGrave
               cpy #$02
               beq HandleAigu
HandleTilde    lda Table4,x
               bra L3
HandleAigu     lda Table3,x
               bra L3
HandleGrave    lda Table2,x
               bra L3
HandleCirc     lda Table1,x
L3             sec
               sbc #$40
               ora #$80                 ;Add appleKey modifier
               sta KeyEvent
               rep #$30
               longa on
               longi on
               pea $0000
               pea $0003
               pea $0000
               lda KeyEvent
               pha
               _PostEvent
               pla
               sep #$30
               longa off
               longi off
               lda #$00
               sta PressedAccent
               sta >KBDSTROBE           ;turn off keypressed flag
               clc
               plb
               rtl

SpecChars      dc  c'@{}]\|#'
AltSpecChars   dc  h'484E4F644D5D63'
Accents        dc  c'^`[~'
Vowels         dc  c'AEIOUaeiou'
Table1         dc  h'25262B2F33495054'
               dc  h'595E'
Table2         dc  h'0B292D3134484F53'
               dc  h'585D'
Table3         dc  h'27432A2E32474E52'
               dc  h'575C'
Table4         dc  h'40282C45464A5155'
               dc  h'5A5F'

KeyEvent       dc  i2'$0000'

               end
