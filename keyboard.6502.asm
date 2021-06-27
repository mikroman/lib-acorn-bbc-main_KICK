#importonce
#import "constants.6502.asm"
//
// title:	bbc micro keyboard routines
// author:	dean belfield
// created:	29/10/2020
// last updated:	29/10/2020
//
// requires: 	constants
//
// modinfo:
//

// read the keyboard
//  a: key code to be tested
// returns:
//  z: key is not pressed
// nz: key is pressed
//
read_keyboard:
 {
			sta	mod_1 + 1
			stx	mod_2 + 1
			lda	#$81
mod_1:
			ldx	#$ff
			ldy	#$ff
			jsr	osbyte
mod_2:
			ldx	#$ff
			cpy	#$00
			rts
}