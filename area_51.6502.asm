//
// title:        area 51
// author:       dean belfield
// started:	01/04/2020
// last updated:	11/04/2020
//
// requires:	macros, vector, vector_filled, output, keyboard, screen_buffer, sound, sprite, math
//
// modinfo:
//
			* = $2000	//set BuildDisk.asm to $2000

start:
			#import "constants.6502.asm"
			#import	"macros.6502.asm"

main:
			lda #22
			jsr oswrch
			lda #2
			jsr oswrch
			lda	#157
            sta px
			lda	#249
            sta py
			ldx	#5
			ldy	#8
			lda	#%00111100
			jsr	draw_line

			ldy	#100
			ldx	#23
			lda	#155
            sta px
			lda	#%00110011
            sta pc
			jsr	draw_horz_line

			ldx	#80
			ldy	#110
			lda	#60
            sta r0
			lda	#%00111111
			jsr	draw_circle

			jsr	get_sprite_slot
			lda	#$08
            sta sprite_w, x
			lda	#$10
            sta sprite_h, x
			lda	#10
            sta sprite_y, x
			lda	#0
            sta sprite_x, x
			stax16(sprite_image, sprite_graphic)
			stax16(sprite_logic, logic_test_1)

			jsr	get_sprite_slot
			lda	#$08
            sta sprite_w, x
			lda	#$10
            sta sprite_h, x
			lda	#10
            sta sprite_y, x
			lda	#0
            sta sprite_x, x
			stax16(sprite_image, sprite_graphic)
			stax16(sprite_logic, logic_test_2)

loop:
			lda	#19		// wait for horizontal blank
			jsr	osbyte
			jsr	render_sprites	// render the sprites
			jmp loop	
		
logic_test_1:
 {
			lda	#$9d
			jsr	read_keyboard
			beq	skip
			lda	sprite_x, x
			clc
			adc	#1
			and #$7f
			sta	sprite_x, x
			inc	sprite_y, x
skip:
			rts
}

logic_test_2:
 {
			lda	sprite_x, x
			clc
			adc	#1
			and #$7f
			sta	sprite_x, x
			inc	sprite_y, x
skip:
			rts
}

sprite_graphic:
		    .byte	$3f,$3f,$3f,$3f,$3f,$3f,$3f,$3f,$3f,$3f,$3f,$3f,$3f,$3f,$3f,$3f
			.byte	$3f,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$3f
			.byte	$3f,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$3f
			.byte	$3f,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$3f
			.byte	$3f,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$3f
			.byte	$3f,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$3f	
			.byte	$3f,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$3f	
			.byte	$3f,$3f,$3f,$3f,$3f,$3f,$3f,$3f,$3f,$3f,$3f,$3f,$3f,$3f,$3f,$3f	

//end:			save	"area51", start, end, main
			#import	"output.6502.asm"
			#import "vector.6502.asm"
			#import	"vector_filled.6502.asm"
			#import "sprite.6502.asm"
			#import "keyboard.6502.asm"
