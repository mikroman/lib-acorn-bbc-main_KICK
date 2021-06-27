#importonce
//#import "macros.6502.asm"
#import "constants.6502.asm"
#import "output.6502.asm"
//
// title:	bbc micro vector output routines
// author:	dean belfield
// created:	25/10/2020
// last updated:	25/10/2020
//
// requires:	output, macros, constants
//
// modinfo:
//

// plot a pixel
//  x: x coordinate
//  y: y coordinate
//  a: pixel colour (plot only)
// returns:
// sl/sh: screen address 
//
plot:
			sta	pc			// store the pixel colour
plot_pc:
 {
			jsr	get_pixel_address	// get the pixel address
			beq	s1			// skip if left pixel byte
			lda	pc			// get the colour
			and	#%01010101		// mask out the right pixel
			sta	m1+1			// store it back temporarily
			ldy	#0			// clear the index registere
			lda	(sl),y			// get the pixel we're writing to		
			and	#%10101010		// and out any pixel data already there
m1:
			ora	#$ff			// or in the new data
			sta	(sl),y			// store
			rts
s1:
			lda	pc			// get the colour
			and	#%10101010		// mask out the left pixel
			sta	m2+1			// store it back temporarily
			ldy	#0			// clear the index registere
			lda	(sl),y			// get the pixel we're writing to		
			and	#%01010101		// and out any pixel data already there
m2:
			ora	#$ff			// or in the new data
			sta	(sl),y			// store
			rts
}

unplot:
			rts 

//  x: x pixel position of circle centre
//  y: x pixel position of circle centre
//  a: colour (0-15)
// r0: radius
// r2/r3: delta
// r4/r5: d1
// r6/r7: d2
// r8/r9: x/y position in quadrant
//
draw_circle:
 {		
			stx	px			// store the circle centre
			sty	py
			sta	pc			// store the circle colour
			lda	r0			// get the radius
			bne	skip_1 			// if > 0 then draw circle
			jmp	plot_pc
skip_1:
			sta	r9 			// store radius in py
			ldx	#0			// store 0 in px
			stx	r8	
//
// delta and d1 = 1 (delta should be 1-r?)
//
			stx	r3			// high bytes 0 
			stx	r5
			stx	r7			// also high byte of delta
			inx 
			stx	r2
			stx	r4
//
// calculate d2 = 3-(r*2)
//			
			as16l(r7)			// multiply a/r7 by 2
			sta	r6			// r6/r7 = (r*2)
			lda	#3			// now subtract it from 3
			sec 
			sbc 	r6
			sta	r6
			lda	#0
			sbc	r7
			sta	r7			// r6/r7 = 3-(r*2)
//
// the loop
//
loop:		lda	r9			// get y
			cmp	r8			// compare with x
			bcs	skip_4			// end if x > y
			rts
//
// the circle routine calculates 1/8th of a circle// this block of code uses
// symmetry to draw a complete circle
//
skip_4:
			lda	px
            add(r8)
            tax		// plot the first quadrant
			lda	py
            add(r9)
            tay
			jsr	plot_pc
			lda	px
            add(r9)
            tax
			lda	py
            add(r8)
            tay
			jsr plot_pc

			lda	px
            sub(r8)
            tax		// plot the second quadrant
			lda	py
            add(r9)
            tay
			jsr	plot_pc
			lda	px
            sub(r9)
            tax
			lda	py
            add(r8)
            tay
			jsr plot_pc

			lda	px
            add(r8)
            tax		// plot the third quadrant
			lda	py
            sub(r9)
            tay
			jsr	plot_pc
			lda	px
            add(r9)
            tax
			lda	py
            sub(r8)
            tay
			jsr plot_pc

			lda	px
            sub(r8)
            tax		// plot the fourth quadrant
			lda	py
            sub(r9)
            tay
			jsr	plot_pc
			lda	px
            sub(r9)
            tax
			lda	py
            sub(r8)
            tay
			jsr plot_pc
//
// the incremental circle algorithm
//
			lda	r3			// check for delta < 0
			bpl	skip_2
			addm16(r2, r4)			// delta += d1
			jmp	skip_3
skip_2:
			addm16(r2, r6)			// delta += d2
			addi16(r6, 2)			// d2 += 2
			dec	r9			//  y -= 1
skip_3:
			addi16(r6, 2)			// d2 += 2
			addi16(r4, 2)			// d1 += 2
			inc 	r8			//  x += 1
			jmp	loop
}

// draw a line between (x1,y1) and (x2,y2)
//  x: x1
//  y: y1
//  a: colour
// px: x2 
// py: y2
// uses:
// r0, r1: w and h of line
// r2, r3: running parameters for bresenhams
// r4, r5: x and y directions
//
draw_line:
 {		
			sta	pc			// store the pixel colour

			txa				// get x1 in a
			ldx	#$01			// x direction defaults to +1
			sub(px)			// subtract with x2
			bcs	skip_px			// if carry then skip next bit
//			neg				// negate width to make it positive
			eor #$ff
			adc #$01
			ldx #$ff			// change x draw direction to -1
skip_px:
		    stx	r4			// store x direction
			sta	r0			// store width

			tya				// get y1
			ldy #$01			// y direction defauts to +1
			sub(py)			// subtract with y2
			bcs	skip_py			// if positive then skip next bit
//			neg				// negate height to make it positive
			eor #$ff
			adc #$01
			ldy	#$ff			// change y draw direction to -1
skip_py:
    		sty	r5			// store y direction
			sta	r1			// store height

			cmp	r0			// compare height with the width
			bcc	skip_q2			// if no carry, then skip to draw q2
//
// case #1: height >= width
//
			sta	r3			// r3 = height
			lsr				// r2 = height / 2
			sta	r2

loop_q1:
    		ldx	px			// plot the point
			ldy	py
			jsr	plot_pc
			lda	r2			// the brezenham's calculation
			sub(r0)
			sta	r2
			bcs	skip_q1m
			adc	r1
			sta	r2
			lda	r4
			add(px)
			sta	px
skip_q1m:
    		lda	r5
			add(py)
			sta	py
			dec	r3
			bne	loop_q1
			ldx	px
			ldy	py
			jmp	plot_pc
//
// case #2: height < width
//
skip_q2:
    		lda	r0
			sta	r3			// r3 = width
			lsr	
			sta	r2			// r2 = width / 2
loop_q2:
    		ldx	px			// plot the point
			ldy	py
			jsr	plot_pc
			lda	r2			// the brezenham's calculation
			sub(r1)
			sta	r2
			bcs	skip_q2m
			adc	r0
			sta	r2
			lda	r5
			add(py)
			sta	py
skip_q2m:
    		lda	r4
			add(px)
			sta	px
			dec	r3
			bne	loop_q2
			ldx	px
			ldy	py
			jmp	plot_pc			// plot the final point
}