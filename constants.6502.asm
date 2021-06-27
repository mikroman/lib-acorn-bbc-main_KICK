#importonce
//#import "macros.6502.asm"
//
// title:	bbc micro constants
// author:	dean belfield
// created:	29/10/2020
// last updated:	29/10/2020
//
// requires: 	macros
//
// modinfo:
//
.label			oswrch = $ffee
.label			osrdch = $ffe0
.label			osbyte = $fff4
.label			osword = $fff1

.label			screen = $3000
.label			chrset = $c000		// rom character set

.label 			zp = $70		// start of usable zero page

.label			r0 = zp + 0		// general purpose registers
.label			r1 = zp + 1
.label			r2 = zp + 2
.label			r3 = zp + 3
.label			r4 = zp + 4
.label			r5 = zp + 5
.label			r6 = zp + 6
.label			r7 = zp + 7
.label			r8 = zp + 8
.label			r9 = zp + 9
.label			sl = zp + 10		// used to store the screen address only
.label			sh = zp + 11
.label			px = zp + 12		// used to store pixel position only
.label			py = zp + 13
.label			pc = zp + 14		// and pixel colour

