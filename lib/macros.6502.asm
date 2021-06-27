//
// title:        macros
// author:       dean belfield
// created:	25/10/2020
// last updated: 25/10/2020
//
// requires:	
//
// modinfo:
//
			.macro	add	(value){
			clc
			adc	value
			}

			.macro	sub	(value){
			sec 
			sbc	value
			}

			.macro	cpl(value){
			eor	#$ff
			}

			.macro	neg(value){
			cpl(value)
			adc	#1
			}

			.macro	stai16	(addr, value){
			lda	#<(value)
			sta	addr
			lda	#>(value)
			sta	addr+1
			}

			.macro	stax16	(addr, value){
			lda	#<(value)
			sta	addr, x
			lda	#>(value)
			sta	addr+1, x
			}

			.macro	adci16	(addr, value){
			lda	addr
			adc	#<(value)
			sta	addr
			lda	addr+1
			adc	#>(value)
			sta	addr+1
			}

			.macro	addi16	(addr, value){
			clc 
			lda	addr
			adc	#<(value)
			sta	addr
			lda	addr+1
			adc	#>(value)
			sta	addr+1
			}

			.macro	adcm16	(addr1, addr2){
			lda	addr1
			adc	addr2
			sta	addr1
			lda	addr1+1
			adc	addr2+1
			sta	addr1+1
			}

			.macro	addm16	(addr1, addr2){
			clc
			lda	addr1
			adc	addr2
			sta	addr1
			lda	addr1+1
			adc	addr2+1
			sta	addr1+1
			}

			.macro	sbci16	(addr, value){
			lda	addr
			sbc	#<(value)
			sta	addr
			lda	addr+1
			sbc	#>(value)
			sta	addr+1
			}

			.macro	subi16	(addr, value){
			sec 
			lda	addr
			sbc	#<(value)
			sta	addr
			lda	addr+1
			sbc	#>(value)
			sta	addr+1
			}

			.macro	sbcm16	(addr1, addr2){
			sec
			lda	addr1
			sbc	addr2
			sta	addr1
			lda	addr1+1
			sbc	addr2+1
			sta	addr1+1
			}

			.macro	subm16	(addr1, addr2){
			sec
			lda	addr1
			sbc	addr2
			sta	addr1
			lda	addr1+1
			sbc	addr2+1
			sta	addr1+1
			}

			.macro	as16l	(addr){
			asl	
			rol	addr
			}