#importonce
#import "constants.6502.asm"
#import "macros.6502.asm"
//
// title:	bbc micro output routines
// author:	dean belfield
// created:	20/10/2020
// last updated:	20/10/2020
//
// requires: 	macros, constants
//
// notes:
//
// the functions get_pixel_address, pixel_address_down and pixel_address_up are slightly
// modified versions of routines publishd by kevin edwards in the april/may 1985 editions
// of micro user
//
// modinfo:

// lookup table of the 32 character rows in mode 2
//
/* table_x280:
		for	n, 0, 31
			equw	screen + (n * $280)
			next
 */
 table_x280:
		.for (var n=0;n<32;n++){
			.word	screen + (n * $280)
            }

//  x: x coordinate
//  y: y coordinate
// returns:
// sl/sh: screen address 
//  a: position of pixel in byte (0 or 1 for mode 2)
//
get_pixel_address:
    	    lda	#0
            sta sh		// store 0 in sh// used as overflow when calculating x*8
			tya				// transfer y to a
			and	#$07			// and with 7
			sta	sl			// store	in sl (screen low byte)
			tya				// calculate y=(y/8)*2
			lsr
            lsr	    	// actually just divide by 4
			and	#$fe			// and reset the first bit, so we can index into table
			tay 				
			txa				// calculate x*4, using sh as overflow
			and	#$fe			// ignore the first bit of x (the pixel position)
			as16l(sh)			// calculate x=(x*4), with overflow into sh	
			as16l(sh)
			adc	sl			// add to the screen low byte
			adc	table_x280+0, y		// add the low byte of the screen multiplication table
			sta	sl			// store back in the screen low byte
			lda	sh			// get the overflow of x*4 (high byte)
			adc	table_x280+1, y		// add the high byte of the screen multiplication table
			sta	sh			// store in the screen high byte
			txa				// and finally, return the pixel-in-byte position in a
			and	#$01
			rts

// sl/sh: screen address
//
pixel_address_down:
 {
			lda	sl			// get the screen low address
			and	#7			// check whether we're at the bottom of a character
			cmp	#7
			bne	s1			// not at bottom, so skip
			addi16(sl, $279)		// add $279 to screen address
			rts
s1:			inc	sl			// skip down to next pixel line
			rts
}

// sl/sh: screen address
//
pixel_address_up:
 {
			lda	sl			// get the screen low address
			and	#7			// check whether we're at the top of a character row
			bne	s1			// not at top, so skip
			subi16(sl, $279)		// subtract $279 from screen address
			rts
s1:			dec	sl			// skip up to next pixel line
			rts
}

// print a character at a screen position
//  a: character to print
//  x: x position
//  y: y position
//
print_char:
 {
			pha 				// stack the character
			lda #$1f			// move text cursor to x,y
			jsr	oswrch
			txa				// set the x position
			jsr	oswrch
			tya				// set the y position
			jsr	oswrch 
			pla				// pop the character off the stack
			jsr oswrch			// print it
			rts
}

// print a hex byte at a screen position
//  a: byte to print
//  x: x position
//  y: y position
//
print_hex:
 {		pha				// stack the original value
			lsr
			lsr
			lsr
			lsr
			sed
			cmp	#$0a
			adc	#$30
			cld
			jsr	print_char
			inx				// advance x position by 2 characters
			inx
			pla
			and	#$0f			// get the lower nibble
			sed
			cmp	#$0a
			adc	#$30
			cld
			jsr	oswrch
			rts
}