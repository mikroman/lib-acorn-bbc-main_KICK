#importonce
//#import "macros.6502.asm"
#import "constants.6502.asm"
#import "output.6502.asm"
#import "vector.6502.asm"	//###    seems to also require this lib (mikroman)    ###
//
// title:        bbc micro mode 2 filled vector routines
// author:       dean belfield
// started:	20/10/2020
// last updated:	20/10/2020
//
// requires:	output, macros, constants
//
// modinfo:
//

//  x: x1
//  y: y
// px: x2
//  a: pixel colour
//
draw_horz_line:
    	{	sta pc			// store the pixel colour
			txa				// get the x1 position in a
			cmp	px			// compare with x2
			beq	skip_plot		// if x1 = x2, just plot a point!
			bcs	skip_1			// skip if x1 >= x2
			lda	px			// get the x2 position in a
			stx	px			// store the x1 position in px
skip_1:
			sub(px)			// get the line length in a (pixels)
			sta	r6 			// r6 = line length
			ldx	px			// get the x1 position in x
			jsr	get_pixel_address	// get the pixel address
			beq	skip_2			// if we're on left pixel, then skip
							// todo: plot right-hand pixel in byte
			addi16(sl, 8)			// move 1 screen byte to the right
			dec	r6			// decrease line length by 1 pixel
skip_2:
			lda	r6			// get line length
			lsr 			// divide by 2 (pixel units -> byte units)
			tax				// make our loop counter
			ldy	#0			// index into screen memory
loop_1:
			lda	pc			// get the pixel colour
			sta	(sl),y			// write out 2 pixels
			addi16(sl, 8)			// move 1 screen byte to the right
			dex				// decrement loop
			bne	loop_1			// loop until done
			lda	r6			// check the line length
			and	#$01			// if there is a pixel remaining							// todo: plot left-hand pixel in byte
			rts

skip_plot:
		    lda	pc			// get the colour
			jmp	plot
}