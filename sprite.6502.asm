#importonce
#import "constants.6502.asm"
#import "output.6502.asm"
//
// title:	bbc micro model b sprite routines
// author:	dean belfield
// created:	27/10/2020
// last updated:	27/10/2020
//
// requires:	output, constants
//
// notes:
//
// the function render_sprite is a slightly modified version of the sprite routine
// published by kevin edwards in the april/may 1985 edition of micro user
//
// modinfo:
//

// get next available sprite slot
// r7: temporary store for x
// returns:
//  x: index into sprite object block or $ff if full
//  z: if sprite slot is free
// nz: if no more sprite slots
//
get_sprite_slot:
 {
			lda	#0
loop_1:		sta	r7
			tax
			lda	sprite_logic + 1, x
			beq	skip_1
			lda	r7
			clc
			adc	#sprite_data_block_size
			cmp	#sprite_data_len
			bcc	loop_1
			ldx	#$ff
skip_1:		rts
}

// render and move all sprites
// r0: width
// r1: height
// r5: temporary storage for x register
// r2/r3: address of the sprite graphics data
// r6/r7: copy of the screen address pointer
//
render_sprites:
 {
			lda	#0
loop_1:		sta r5
			tax
			lda	sprite_logic + 1, x
			beq	skip_1
//
// set up the sprite parameters
//
			sta	mod_1 + 2
			lda	sprite_logic + 0, x
			sta	mod_1 + 1
//
// check whether we need to erase this sprite, i.e. has it been drawn yet?
//
			lda	sprite_flags, x
			and	#$01
			beq	mod_1
//
// erase, move, then draw the sprite
//
			jsr	draw		// erase the old sprite
			ldx	r5		// get the x register
mod_1:		jsr $ffff		// run the sprite logic routine (self-modded)
			ldx	r5		// get the x register 
			lda	sprite_flags, x
			ora	#$01		// set this sprite as drawn for next erase
			sta	sprite_flags, x
			jsr	draw
//
// skip to the next sprite object
//
skip_1:
			lda	r5
			clc
			adc	#sprite_data_block_size
			cmp	#sprite_data_len
			bcc	loop_1
			rts
//
// the draw/erase sprite routine
// falls through to render_sprite
//
draw:
 		    lda	sprite_w, x
            sta r0
			lda	sprite_h, x
            sta r1
			lda	sprite_image + 0, x
            sta r2
			lda	sprite_image + 1, x
            sta r3
			lda	sprite_y, x
            tay
			lda	sprite_x, x
            tax
//			jmp	render_sprite
}

// render a single sprite
//  x: x coordinate
//  y: y coordinate
// r0: width
// r1: height
// r2/r3: address of the sprite graphics data
// r6/r7: copy of the screen address pointer
// 
render_sprite:
 {
			jsr	get_pixel_address	// get the screen address of the sprite
			lda	r2
            sta loop_1+1	// self-mod the sprite data address
			lda	r3
            sta loop_1+2
loop_0:
			lda	sh			// make a copy of the screen pointer in r1/r2
			sta	r7
			lda	sl			// for the low byte, it needs to be anded
			and	#$f8			// to the nearest character
			sta r6	
			lda	sl			// and the y register contains the pixel row
			and #$07			// in the character
			tay				// transfer to y
			ldx	#$00			// pointer into sprite data
loop_1:
			lda	$ffff,x			// get sprite graphic data - self modded address
			eor	(r6),y			// xor with screen
			sta	(r6),y			// write to screen
			inx				// increment graphic pointer
			iny				// incremente screen pointer
			cpx	r1			// check height - have we finished this column?
			beq	skip_1			// if so, then skip
			cpy	#$08			// have we reached the end of this character block?
			bne	loop_1			// no, so just loop
			adci16(r6, $27f)		// add $279 to screen address to move to next character
			ldy	#$00			// reset the screen pointer// clears the z flag
			beq	loop_1			// bra instruction relies upon the z flag being reset by previous
skip_1:		dec	r0			// decrement the width
			beq	skip_2			// if we've reached the end, then skip
			addi16(sl, 8)			// move to the next column
			lda	r1			// get the height
			clc
			adc	loop_1+1		// add to the sprite data low address
			sta	loop_1+1
			bcc	loop_0			// if no carry, then loop
			inc loop_1+2		// increment the high address
			bne	loop_0			// bra instructions relies upon this never being 0
skip_2:
			rts 				
}

.label sprite_data_block_size	= $10	// size of this block
.label sprite_max		= $08	// maximum number of sprites

.label sprite_data_len		= sprite_max * sprite_data_block_size

// reserve some space for the sprite definitions
//
sprite_data:		//skip sprite_data_len

.fill 0, (sprite_max * sprite_data_block_size)
// the sprite definition object structure
// each of these is an offset in the spite data table
// sprite_flags:
// bit 0: set first time sprite is drawn
//
.label sprite_image		= sprite_data + $00	// address of the sprite graphic data
.label sprite_x		= sprite_data + $02	// the sprite x position (pixels)
.label sprite_y		= sprite_data + $03	// the sprite y position (pixels)
.label sprite_w		= sprite_data + $04	// the sprite width (bytes)
.label sprite_h		= sprite_data + $05	// the sprite height (pixels)
.label sprite_logic		= sprite_data + $06	// address of the routine to move the sprite	
.label sprite_flags		= sprite_data + $08	// various flags
.label sprite_data_1		= sprite_data + $09	// sprite-specific data in these 
.label sprite_data_2		= sprite_data + $0a
.label sprite_data_3		= sprite_data + $0b
.label sprite_data_4		= sprite_data + $0c
.label sprite_data_5		= sprite_data + $0d
.label sprite_data_6		= sprite_data + $0e
.label sprite_data_7		= sprite_data + $0f
