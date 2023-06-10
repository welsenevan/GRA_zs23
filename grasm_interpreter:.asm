 grasm_interpreter:

  push rbx
  mov qword ptr [rdi], 0
.main_loop:
   /*
 =======================================================================================
 	CHECK FOR INSTRUCTION, JMP ACCORDINGLY
 =======================================================================================
 */
  mov rax, qword ptr [rdi] 		// load ip
  cmp rax, rsi 					// check if ip >= len
  jae .out_of_bounds
  
  movzx rbx, byte ptr [rdx] //load opcode
  
  cmp rbx, 0x01  
  je .stop
  
  cmp rbx, 0x0f
  je .nop
  
  cmp rbx, 0x10
  je .set
  
  cmp rbx, 0x18
  je .set_rX
  
  cmp rbx, 0x11
  je .cpy_rX
  
  cmp rbx, 0x19
  je .cpy_rX_rY
  
  cmp rbx, 0x20
  je .add
  
  cmp rbx, 0x28
  je .add_rX
  
  cmp rbx, 0x21
  je .add_rX_value
  
  cmp rbx, 0x29
  je .add_rX_rY
  
  cmp rbx, 0x22
  je .sub
  
  cmp rbx, 0x2a
  je .sub_rX
  
  cmp rbx, 0x23
  je .sub_rX_value
  
  cmp rbx, 0x2b
  je .sub_rX_rY
  
  cmp rbx, 0x24
  je .mul
  
  cmp rbx, 0x2c
  je .mul_rX
  
  cmp rbx, 0x25
  je .mul_rX_value
  
  cmp rbx, 0x2d
  je .mul_rX_rY 
  
  cmp rbx, 0x2d
  je .mul_rX_rY
  
  cmp rbx, 0x26
  je .xchg_rX
  
  cmp rbx, 0x2e
  je .xchg_rX_rY
  
  cmp rbx, 0x30
  je .and
  
  cmp rbx, 0x31
  je .and_rX
  
  cmp rbx, 0x32
  je .and_rX_value
  
  cmp rbx, 0x33
  je .and_rX_rY
  
  cmp rbx, 0x34
  je .or
  
  cmp rbx, 0x35
  je .or_rX
  
  cmp rbx, 0x36
  je .or_rX_value
  
  cmp rbx, 0x37
  je .or_rX_rY
  
  cmp rbx, 0x38
  je .xor_imm
  
  cmp rbx, 0x39
  je .xor_rX_imm
  
  cmp rbx, 0x3a
  je .xor_rX_value
  
  cmp rbx, 0x3b
  je .xor_rX_rY
  
  cmp rbx, 0x3c
  je .not_ac
  
  cmp rbx, 0x3d
  je .not_rX
  
  cmp rbx, 0x3e
  je .not_rX_rY
  
  cmp rbx, 0x40
  je .cmp_rX_imm
  
  cmp rbx, 0x41
  je .cmp_rX_rY
  
  cmp rbx, 0x42
  je .tst_rX_imm
  
  cmp rbx, 0x43
  je .tst_rX_rY
  
  cmp rbx, 0x50
  je .shr_imm
  
  cmp rbx, 0x51
  je .shr_rX_imm
  
  cmp rbx, 0x52
  je .shr_rX
  
  cmp rbx, 0x53
  je .shr_rX_rY
  
  cmp rbx, 0x54
  je .shl_imm
  
  cmp rbx, 0x55
  je .shl_rX_imm
  
  cmp rbx, 0x56
  je .shl_rX
  
  cmp rbx, 0x57
  je .shl_rX_rY
  
    cmp rbx, 0x60
  je .ld_imm
  
  cmp rbx, 0x61
  je .ld_rX_imm
  
  cmp rbx, 0x62
  je .ld_rX
  
  cmp rbx, 0x63
  je .ld_rX_rY
  
  cmp rbx, 0x64
  je .st_imm
  
  cmp rbx, 0x65
  je .st_rX_imm
  
  cmp rbx, 0x66
  je .st_rX
  
  cmp rbx, 0x67
  je .st_rX_rY
  
  cmp rbx, 0x70
  je .go_imm
  
  cmp rbx, 0x71
  je .go_rX
  
  cmp rbx, 0x72
  je .gr_imm
  
  cmp rbx, 0x73
  je .jz_imm
  
  cmp rbx, 0x74
  je .jz_rX
  
  cmp rbx, 0x75
  je .jrz_imm
  
  cmp rbx, 0x80
  je .ecall_imm
  
  cmp rbx, 0x81
  je .ecall_rX
  
  // Unknown opcode
  mov rax, -1
  jmp .end
  
 /*
 =======================================================================================
 	IMPLEMENTING HANDLER FOR EVERY INSTRUCTION (RAX = ip)
 =======================================================================================
 */
 
.stop:
  mov rax, 0
  jmp .end
 
.nop:
  add rax, 1
  cmp rax, rsi
  jae .out_of_bounds				//only update ip if not out of bounds
  
  add qword ptr [rdi], 1 			
  jmp .main_loop

.set:
  mov rcx, qword ptr [rdx +rax+ 1] 	// load immediate
  bswap rcx
  mov [rdi + 0x8], rcx   			// ac = immediate
  
  add rax, 9
  cmp rax, rsi
  jae .out_of_bounds				//only update ip if not out of bounds
  
  add qword ptr [rdi], 9			
  jmp .main_loop
  
  
//RX = IMM 
.set_rX:
  movzx rcx, byte ptr [rdx + rax+ 1]  	 		// rX
  cmp rcx, 0x8 									// rX valid?
  jae .out_of_bounds
  
  mov r8, qword ptr [rdx + rax + 2] 			// immediate
  bswap r8										// little to big Endian
  mov [rdi + 0x10 + rcx*8], r8 					// rX = imm	
  
  add rax, 10
  cmp rax, rsi
  jae .out_of_bounds
  
  add qword ptr [rdi], 10
  jmp .main_loop
  
  
//AC = RX 
.cpy_rX:
  movzx rcx, byte ptr [rdx + rax + 1] 
  cmp rcx, 0x8 
  jae .out_of_bounds
  
  mov r8, [rdi+0x10+rcx*8] 			// r8 = rX
  bswap r8
  mov [rdi + 0x8], r8 				// ac = rX
  
  add rax, 2
  cmp rax, rsi
  jae .out_of_bounds
  
  add qword ptr [rdi], 2
  jmp .main_loop
  
  
//RX = RY, [rdi + rax + 1] contains both X and Y in a single byte  
.cpy_rX_rY:
  movzx rcx, byte ptr [rdx+rax+1]  		
  movzx r8,  byte ptr [rdx+rax+1] 		// load XY
  
  shr rcx, 4		// extract X
  and r8, 0xf
  
  cmp rcx, 0x8 
  jae .out_of_bounds
  cmp r8, 0x8
  jae .out_of_bounds
  
  mov r9, [rdi+0x10+r8*8] 		// load rY
  mov [rdi+0x10+rcx*8], r9 		// rX = rY
  
  add rax, 2
  cmp rax, rsi
  jae .out_of_bounds				//only update ip if not out of bounds
  
  add qword ptr [rdi], 2
  jmp .main_loop
  
  
//AC += imm  
.add:
  mov rcx, qword ptr [rdx + rax + 1]
  bswap rcx
  add [rdi+0x8], rcx
  
  add rax, 9
  cmp rax, rsi
  jae .out_of_bounds
  
  add qword ptr [rdi], 9 
  jmp .main_loop
  

//RX += imm
.add_rX:
  movzx rcx, byte ptr [rdx+rax+1] 
  cmp rcx, 0x8 
  jae .out_of_bounds
  
  mov r8, qword ptr [rdx+rax+2]
  bswap r8
  add [rdi+0x10+rcx*8], r8
  
  add rax, 10
  cmp rax, rsi
  jae .out_of_bounds
  
  add qword ptr [rdi], 10
  jmp .main_loop
  

//AC += RX
.add_rX_value:
  movzx rcx, byte ptr [rdx+rax+1] 
  cmp rcx, 0x8 
  jae .out_of_bounds
  
  mov r8, [rdi+0x10+rcx*8] 
  add [rdi+0x8], r8 
  
  add rax, 2
  cmp rax, rsi
  jae .out_of_bounds
  
  add qword ptr [rdi], 2
  jmp .main_loop
  
//RX += RY  
.add_rX_rY:
  movzx rcx, byte ptr [rdx+rax+1]  		
  movzx r8,  byte ptr [rdx+rax+1] 		// load XY
  
  shr rcx, 4		// extract X
  and r8, 0xf
  
  cmp rcx, 0x8 
  jae .out_of_bounds
  cmp r8, 0x8
  jae .out_of_bounds
  
  mov r9, [rdi+0x10+r8*8] 	// load rY
  add [rdi+0x10+rcx*8], r9 	
  
  add rax, 2
  cmp rax, rsi
  jae .out_of_bounds
  
  add qword ptr [rdi], 2
  jmp .main_loop
  
  
//AC -= imm  
.sub:
  mov rcx, qword ptr [rdx+rax+1]
  bswap rcx
  
  sub [rdi+0x8], rcx
  
  add rax, 9
  cmp rax, rsi
  jae .out_of_bounds
  
  add qword ptr [rdi], 9
  jmp .main_loop


.sub_rX:
  movzx rcx, byte ptr [rdx+rax+1]
  cmp rcx, 0x8 
  jae .out_of_bounds
  
  mov r8, qword ptr [rdx+rax+2] 	// load immediate
  bswap r8
  
  sub [rdi+0x10+rcx*8], r8 			// rX -= immediate

  add rax, 10
  cmp rax, rsi
  jae .out_of_bounds				//only update ip if not out of bounds
  
  add qword ptr [rdi], 10
  jmp .main_loop


//AC -= RX
.sub_rX_value:
  movzx rcx, byte ptr [rdx+rax+1] 
  cmp rcx, 0x8 
  jae .out_of_bounds
  
  mov r8, [rdi+0x10+rcx*8] 			// load rX
  sub [rdi+0x8], r8 				// ac -= rX
  
  add rax, 2
  cmp rax, rsi
  jae .out_of_bounds				//only update ip if not out of bounds
  
  add qword ptr [rdi], 2 			// increment ip
  jmp .main_loop
  
.sub_rX_rY:
  movzx rcx, byte ptr [rdx+rax+1]  		
  movzx r8,  byte ptr [rdx+rax+1] 		// load XY
  
  shr rcx, 4		// extract X
  and r8, 0xf
  
  cmp rcx, 0x8 
  jae .out_of_bounds
  cmp r8, 0x8
  jae .out_of_bounds
  
  mov r9, [rdi+0x10+r8*8] 			// load rY
  sub [rdi+0x10+rcx*8], r9 			// rX -= rY
  
  add rax, 2
  cmp rax, rsi
  jae .out_of_bounds				//only update ip if not out of bounds
  
  add qword ptr [rdi], 2
  jmp .main_loop
  
 
//AC *= imm 
.mul:
  mov rcx, qword ptr [rdx+rax+1] 	// load immediate
  bswap rcx
  
  mov r8, qword ptr [rdi+0x8]
  imul r8, rcx 				// ac *= immediate
  mov qword ptr [rdi+0x8], r8
  
  add rax, 9
  cmp rax, rsi
  jae .out_of_bounds				//only update ip if not out of bounds
  
  add qword ptr [rdi], 9 
  jmp .main_loop


//RX *= imm
.mul_rX:
  movzx rcx, byte ptr [rdx+rax+1] 	// load X
  cmp rcx, 0x8 						// check if rX is valid
  jae .out_of_bounds
  
  mov r8, qword ptr [rdx+rax+2] 	// load immediate
  bswap r8
  mov r9, [rdi+0x10+rcx*8]
  imul r9, r8
  mov [rdi+0x10+rcx*8], r9 		// rX *= immediate
 
  add rax, 10
  cmp rax, rsi
  jae .out_of_bounds				//only update ip if not out of bounds
  
  add qword ptr [rdi], 10 
  jmp .main_loop
  

//AC *= rX
.mul_rX_value:
  movzx rcx, byte ptr [rdx+rax+1] 	
  cmp rcx, 0x8 
  jae .out_of_bounds
  
  mov r8, [rdi+0x10+rcx*8] 			// load rX
  mov r9, [rdi+0x8]
  imul r9, r8
  mov [rdi+0x8], r9 				// ac *= rX
  
  add rax, 10
  cmp rax, rsi
  jae .out_of_bounds				//only update ip if not out of bounds
  
  add qword ptr[rdi], 2 
  jmp .main_loop
  
  
//RX *= RY
.mul_rX_rY:
  movzx rcx, byte ptr [rdx+rax+1]  		
  movzx r8,  byte ptr [rdx+rax+1] 		// load XY
  
  shr rcx, 4		// extract X
  and r8, 0xf
  
  cmp rcx, 0x8 
  jae .out_of_bounds
  cmp r8, 0x8
  jae .out_of_bounds
  
  mov r9, [rdi+0x10+r8*8] 			// load rY
  mov r10, [rdi+0x10+rcx*8]			// rY
  imul r10, r9
  mov [rdi+0x10+rcx*8], r10 		// rX *= rY
  
  add rax, 10
  cmp rax, rsi
  jae .out_of_bounds				//only update ip if not out of bounds
  
  add qword ptr [rdi], 2
  jmp .main_loop
  

//tmp =ac; ac=rX; rX = tmp
.xchg_rX:
  movzx rcx, byte ptr [rdx+rax+1] 		// load X
  cmp rcx, 0x8 
  jae .out_of_bounds
  
  mov r8, [rdi+0x8] 		 		// tmp = ac
  xchg r8, [rdi+0x10+rcx*8] 		// ac = rX, rX = tmp
  mov [rdi+0x8], r8
  
  add rax, 2
  cmp rax, rsi
  jae .out_of_bounds				//only update ip if not out of bounds
  
  add qword ptr [rdi], 2 
  jmp .main_loop
  


//rmp = rX; rX = rY; rY = tmp
.xchg_rX_rY:
  movzx rcx, byte ptr [rdx+rax+1]  		
  movzx r8,  byte ptr [rdx+rax+1] 		// load XY
  
  shr rcx, 4		// extract X
  and r8, 0xf
  
  cmp rcx, 0x8 
  jae .out_of_bounds
  cmp r8, 0x8
  jae .out_of_bounds
  
  mov r9, [rdi+0x10+rcx*8]				// tmp = rX
  xchg r9, [rdi+0x10+r8*8] 				// rX = rY, rY = tmp
  mov [rdi+0x10+rcx*8], r9
  
  add rax, 2
  cmp rax, rsi
  jae .out_of_bounds					//only update ip if not out of bounds
  
  add qword ptr [rdi], 2
  jmp .main_loop
  
  
  
//AC &= imm  
.and:
  mov rcx, qword ptr [rdx+rax+1] 		// load immediate
  bswap rcx
  and [rdi+0x8], rcx 					// ac &= immediate
  
  add rax, 9
  cmp rax, rsi
  jae .out_of_bounds					//only update ip if not out of bounds
  
  add qword ptr [rdi], 9 
  jmp .main_loop
  

//rX &= imm
.and_rX:
  movzx rcx, byte ptr [rdx+rax+1] 		// load X
  cmp rcx, 0x8 
  jae .out_of_bounds
  
  mov r8, qword ptr [rdx+rax+2] 		// load immediate
  bswap r8
  and [rdi+0x10+rcx*8], r8 				// rX &= immediate
  
  add rax, 10
  cmp rax, rsi
  jae .out_of_bounds					//only update ip if not out of bounds
  
  add qword ptr [rdi], 10 
  jmp .main_loop
  


//AC &= rX
.and_rX_value:
  movzx rcx, byte ptr [rdx+rax+1] 		// load X
  cmp rcx, 0x8 
  jae .out_of_bounds
  
  mov r8, [rdi+0x10+rcx*8]
  and [rdi+0x8], r8	 					// ac &= rX
  
  add rax, 2
  cmp rax, rsi
  jae .out_of_bounds					//only update ip if not out of bounds
  
  add qword ptr [rdi], 2 
  jmp .main_loop
  
  
//rX &= rY  
.and_rX_rY:
  movzx rcx, byte ptr [rdx+rax+1]  		
  movzx r8,  byte ptr [rdx+rax+1] 		// load XY
  
  shr rcx, 4		// extract X
  and r8, 0xf
  
  cmp rcx, 0x8 
  jae .out_of_bounds
  cmp r8, 0x8
  jae .out_of_bounds
  
  mov r9, [rdi+0x10+r8*8]
  and [rdi+0x10+rcx*8], r9 // rX &= rY
  
  add rax, 2
  cmp rax, rsi
  jae .out_of_bounds					//only update ip if not out of bounds
  
  add qword ptr[rdi], 2
  jmp .main_loop  
  
  
  
//AC |= imm
.or:
  mov rcx, qword ptr [rdx+rax+1]		// load immediate
  bswap rcx
  or [rdi+0x8], rcx 					// ac |= immediate
  
  add rax, 9
  cmp rax, rsi
  jae .out_of_bounds					//only update ip if not out of bounds
  
  add qword ptr [rdi], 9
  jmp .main_loop
  
  
//RX |= imm 
.or_rX:
  movzx rcx, byte ptr [rdx+rax+1] 		// load X
  cmp rcx, 0x8 
  jae .out_of_bounds
  
  mov r8, qword ptr [rdx+rax+2] 		// load immediate
  cmp rcx, 0x8 
  jae .out_of_bounds
  
  bswap r8
  or [rdi+0x10+rcx*8], r8 				// rX |= immediate
  
  add rax, 10
  cmp rax, rsi
  jae .out_of_bounds					//only update ip if not out of bounds
  
  add qword ptr [rdi], 10 
  jmp .main_loop



//AC |= rX
.or_rX_value:
  movzx rcx, byte ptr [rdx+rax+1] 			// load X
  cmp rcx, 0x8 
  jae .out_of_bounds
  
  mov r8, [rdi+0x10+rcx*8]
  or [rdi+0x8], r8	 	// ac |= rX
  
  add rax, 2
  cmp rax, rsi
  jae .out_of_bounds					//only update ip if not out of bounds
  
  add qword ptr [rdi], 2 
  jmp .main_loop
  


//rX |= rY
.or_rX_rY:
  movzx rcx, byte ptr [rdx+rax+1]  		
  movzx r8,  byte ptr [rdx+rax+1] 		// load XY
  
  shr rcx, 4		// extract X
  and r8, 0xf
  
  cmp rcx, 0x8 
  jae .out_of_bounds
  cmp r8, 0x8
  jae .out_of_bounds
  
  mov r9, [rdi+0x10+rcx*8]
  or [rdi+0x10+rcx*8], r9 				// rX |= rY
  
  add rax, 2
  cmp rax, rsi
  jae .out_of_bounds					//only update ip if not out of bounds
  
  add qword ptr[rdi], 2
  jmp .main_loop  
  
 
 
//AC ^= imm 
.xor_imm:
  mov rcx, qword ptr [rdx+rax+1]		// load immediate
  bswap rcx
  xor [rdi+0x8], rcx 					// ac ^= immediate
  
  add rax, 9
  cmp rax, rsi
  jae .out_of_bounds					//only update ip if not out of bounds
  
  add qword ptr [rdi], 9
  jmp .main_loop



//rX ^= imm
.xor_rX_imm:
  movzx rcx, byte ptr [rdx+rax+1] 		// load X
  cmp rcx, 0x8 
  jae .out_of_bounds
  
  mov r8, qword ptr [rdx+rax+2] 		// load immediate
  cmp rcx, 0x8 
  jae .out_of_bounds
  
  bswap r8
  xor [rdi+0x10+rcx*8], r8 				// rX ^= immediate
  
  add rax, 10
  cmp rax, rsi
  jae .out_of_bounds					//only update ip if not out of bounds
  
  add qword ptr [rdi], 10 
  jmp .main_loop



//AC ^= rX
.xor_rX_value:
  movzx rcx, byte ptr [rdx+rax+1] 		// load X
  cmp rcx, 0x8 
  jae .out_of_bounds
  
  mov r8, [rdi+0x10+rcx*8]
  xor [rdi+0x8], r8	 					// ac ^= rX
  
  add rax, 2
  cmp rax, rsi
  jae .out_of_bounds					//only update ip if not out of bounds
  
  add qword ptr [rdi], 2 
  jmp .main_loop
  


//xR ^= xY
.xor_rX_rY:
  movzx rcx, byte ptr [rdx+rax+1]  		
  movzx r8,  byte ptr [rdx+rax+1] 		// load XY
  
  shr rcx, 4		// extract X
  and r8, 0xf
  
  cmp rcx, 0x8 
  jae .out_of_bounds
  cmp r8, 0x8
  jae .out_of_bounds
  
  mov r9, [rdi+0x10+r8*8]
  xor [rdi+0x10+rcx*8], r9 				// rX ^= rY
  
  add rax, 2
  cmp rax, rsi
  jae .out_of_bounds					//only update ip if not out of bounds
  
  add qword ptr[rdi], 2
  jmp .main_loop 
  
  
  
.not_ac:
  add rax, 1
  cmp rax, rsi
  jae .out_of_bounds					//only update ip if not out of bounds
  
  not qword ptr [rdi+0x8] 
  
  add qword ptr[rdi], 1
  jmp .main_loop 


//AC = not(rX)
.not_rX:
  movzx rcx, byte ptr [rdx+rax+1]
  cmp rcx, 0x8
  jae .out_of_bounds
  
  not rcx
  mov qword ptr [rdi+0x8], rcx
  
  add rax, 2
  cmp rax, rsi
  jae .out_of_bounds					//only update ip if not out of bounds
  
  add qword ptr[rdi], 2
  jmp .main_loop 

  
  

//rX = not(rY)
.not_rX_rY:
  movzx rcx, byte ptr [rdx+rax+1]  		
  movzx r8,  byte ptr [rdx+rax+1] 		// load XY
  
  shr rcx, 4		// extract X
  and r8, 0xf
  
  cmp rcx, 0x8 
  jae .out_of_bounds
  cmp r8, 0x8
  jae .out_of_bounds
  
  mov r9, [rdi+0x10+r8*8]
  not r9
  mov qword ptr [rdi+0x10+rcx*8], r9
  
  add rax, 2
  cmp rax, rsi
  jae .out_of_bounds					//only update ip if not out of bounds
  
  add qword ptr[rdi], 2
  jmp .main_loop 


//ac = rX - imm
.cmp_rX_imm:
  movzx rcx, byte ptr [rdx+rax+1] 				// load X
  cmp rcx, 0x8 
  jae .out_of_bounds
  
  mov r8, qword ptr [rdx+rax+2] 			// load immediate
  bswap r8
  
  mov r9, qword ptr [rdi+0x10+rcx*8] 		// load rX
  sub r9, r8 
  mov qword ptr [rdi+0x8], r9 				// ac = rX - imm
  
  add rax, 10
  cmp rax, rsi
  jae .out_of_bounds					//only update ip if not out of bounds
  
  add qword ptr[rdi], 10
  jmp .main_loop 



//ac = rX - rY
.cmp_rX_rY:
  movzx rcx, byte ptr [rdx+rax+1]  		
  movzx r8,  byte ptr [rdx+rax+1] 		// XY
  
  shr rcx, 4		// extract X
  and r8, 0xf
  
  cmp rcx, 0x8 
  jae .out_of_bounds
  cmp r8, 0x8
  jae .out_of_bounds
  
  mov r9, qword ptr [rdi+0x10+rcx*8] 		// load rX
  mov r10, qword ptr [rdi+0x10+r8*8]		// load rY
  sub r9, r10
  mov qword ptr [rdi+0x8], r9 				// ac = rX - rY
  
  add rax, 2
  cmp rax, rsi
  jae .out_of_bounds					//only update ip if not out of bounds
  
  add qword ptr[rdi], 2
  jmp .main_loop 
  
  
  
//AC = rX & imm
.tst_rX_imm:
  movzx rcx, byte ptr [rdx+rax+1] 			// load X
  cmp rcx, 0x8 
  jae .out_of_bounds
  
  mov r8, qword ptr [rdx+rax+2] 			// load immediate
  bswap r8
  
  mov r9, qword ptr [rdi+0x10+rcx*8] 		// load rX
  and r9, r8 
  mov qword ptr [rdi+0x8], r9 				// ac = rX & imm
  
  add rax, 10
  cmp rax, rsi
  jae .out_of_bounds					//only update ip if not out of bounds
  
  add qword ptr[rdi], 10
  jmp .main_loop 
  


//AC = rX & rY
.tst_rX_rY:
  movzx rcx, byte ptr [rdx+rax+1]  		
  movzx r8,  byte ptr [rdx+rax+1] 		// XY
  
  shr rcx, 4		// extract X
  and r8, 0xf
  
  cmp rcx, 0x8 
  jae .out_of_bounds
  cmp r8, 0x8
  jae .out_of_bounds
  
  mov r9, qword ptr [rdi+0x10+rcx*8] 		// load rX
  mov r10, qword ptr [rdi+0x10+r8*8]		// load rY
  and r9, r10
  mov qword ptr [rdi+0x8], r9 				// ac = rX & rY
  
  add rax, 2
  cmp rax, rsi
  jae .out_of_bounds					//only update ip if not out of bounds
  
  add qword ptr[rdi], 2
  jmp .main_loop 
  


//AC >>= imm
//can only shifts 63 bits
.shr_imm:
  movzx rcx, byte ptr [rdx+rax+1]
  and rcx,0x3f
  shr qword ptr[rdi+0x8], rcx
  
  add rax, 2
  cmp rax, rsi
  jae .out_of_bounds					//only update ip if not out of bounds
  
  add qword ptr[rdi], 2
  jmp .main_loop 
  
 

//rX >>= imm
.shr_rX_imm:
  movzx r8, byte ptr [rdx+rax+1] 			// load X
  cmp r8, 0x8 
  jae .out_of_bounds
  
  movzx rcx, byte ptr [rdx+rax+2] 				// load immediate 
  and rcx, 0x3f
  shr qword ptr [rdi+0x10+r8*8], rcx
  
  add rax, 3
  cmp rax, rsi
  jae .out_of_bounds						//only update ip if not out of bounds
  
  add qword ptr[rdi], 3
  jmp .main_loop 
  



//AC >>= rX
.shr_rX:
  movzx r8, byte ptr [rdx+rax+1]
  cmp r8, 0x8
  jae .out_of_bounds

  mov rcx, qword ptr [rdi+0x10+r8*8] 		// load rX
  and rcx, 0x3f
  shr qword ptr [rdi+0x8], rcx
  
  add rax, 2
  cmp rax, rsi
  jae .out_of_bounds						//only update ip if not out of bounds
  
  add qword ptr[rdi], 2
  jmp .main_loop 



//rX >>= rY
.shr_rX_rY:
  movzx r8, byte ptr [rdx+rax+1]  		
  movzx r9,  byte ptr [rdx+rax+1] 		// XY
  
  shr r8, 4		// extract X
  and r9, 0xf	// 
  
  cmp r8, 0x8 
  jae .out_of_bounds
  cmp r9, 0x8
  jae .out_of_bounds
  
  movzx rcx, byte ptr [rdi+0x10+r9*8]
  shr qword ptr[rdi+0x10+r8*8], rcx 							
  
  add rax, 2
  cmp rax, rsi
  jae .out_of_bounds						//only update ip if not out of bounds
  
  add qword ptr[rdi], 2
  jmp .main_loop 


//shl analog to shr, copas
//AC <<= imm
//can only shifts 63 bits
.shl_imm:
  movzx rcx, byte ptr [rdx+rax+1]
  and rcx,0x3f
  shr qword ptr[rdi+0x8], rcx
  
  add rax, 2
  cmp rax, rsi
  jae .out_of_bounds					//only update ip if not out of bounds
  
  add qword ptr[rdi], 2
  jmp .main_loop 
  
 

//rX <<= imm
.shl_rX_imm:
  movzx r8, byte ptr [rdx+rax+1] 			// load X
  cmp r8, 0x8 
  jae .out_of_bounds
  
  movzx rcx, byte ptr [rdx+rax+2] 				// load immediate 
  and rcx, 0x3f
  shl qword ptr [rdi+0x10+r8*8], rcx
  
  add rax, 3
  cmp rax, rsi
  jae .out_of_bounds						//only update ip if not out of bounds
  
  add qword ptr[rdi], 3
  jmp .main_loop 
  



//AC <<= rX
.shl_rX:
  movzx r8, byte ptr [rdx+rax+1]
  cmp r8, 0x8
  jae .out_of_bounds

  mov rcx, qword ptr [rdi+0x10+r8*8] 		// load rX
  and rcx, 0x3f
  shl qword ptr [rdi+0x8], rcx
  
  add rax, 2
  cmp rax, rsi
  jae .out_of_bounds						//only update ip if not out of bounds
  
  add qword ptr[rdi], 2
  jmp .main_loop 



//rX <<= rY
.shl_rX_rY:
  movzx r8, byte ptr [rdx+rax+1]  		
  movzx r9,  byte ptr [rdx+rax+1] 		// XY
  
  shr r8, 4		// extract X
  and r9, 0xf	// 
  
  cmp r8, 0x8 
  jae .out_of_bounds
  cmp r9, 0x8
  jae .out_of_bounds
  
  movzx rcx, byte ptr [rdi+0x10+r9*8]
  shl qword ptr[rdi+0x10+r8*8], rcx 							
  
  add rax, 2
  cmp rax, rsi
  jae .out_of_bounds						//only update ip if not out of bounds
  
  add qword ptr[rdi], 2
  jmp .main_loop 


//ac = [imm]
.ld_imm:
  mov r8, qword ptr [rdx+rax+1] 	//load imm
  bswap r8
  mov r9, qword ptr [r8] 
  
  mov qword ptr [rdi+0x8], r9 			// ac = [imm]
  
  add rax, 9
  cmp rax, rsi
  jae .out_of_bounds						//only update ip if not out of bounds
  
  add qword ptr[rdi], 9
  jmp .main_loop 
  
  
 
 
//rX=[imm] 
.ld_rX_imm:
  movzx r8, byte ptr [rdx+rax+1] 			// load X
  cmp r8, 0x8 
  jae .out_of_bounds

  mov r9, qword ptr [rdx+rax+2] 	//load imm
  bswap r9
  mov r10, qword ptr [r9] 
  
  mov qword ptr [rdi+0x10+r8*8], r10

  add rax, 10
  cmp rax, rsi
  jae .out_of_bounds						//only update ip if not out of bounds
  
  add qword ptr[rdi], 10
  jmp .main_loop 
  


//AC = [rx]
.ld_rX:
  movzx r8, byte ptr [rdx+rax+1] 			// load X
  cmp r8, 0x8 
  jae .out_of_bounds
  
  mov r9, qword ptr [rdi+0x10+r8*8]
  mov r10, [r9]
  
  mov qword ptr[rdi+0x8], r10

  add rax, 2
  cmp rax, rsi
  jae .out_of_bounds						//only update ip if not out of bounds
  
  add qword ptr[rdi], 2
  jmp .main_loop 



//rX = [rY]
.ld_rX_rY:
  movzx r8, byte ptr [rdx+rax+1]  		
  movzx r9,  byte ptr [rdx+rax+1] 		// XY
  
  shr r8, 4		// extract X
  and r9, 0xf	// Y
  
  cmp r8, 0x8 
  jae .out_of_bounds
  cmp r9, 0x8
  jae .out_of_bounds

  mov r10, qword ptr [rdi+0x10+r9*8]	//rY value
  mov rcx, [10]
  mov qword ptr [rdi+0x10+r8*8], rcx
  
  add rax, 2
  cmp rax, rsi
  jae .out_of_bounds						//only update ip if not out of bounds
  
  add qword ptr[rdi], 2
  jmp .main_loop
  


//[imm] = AC
.st_imm:
  mov r8, qword ptr [rdx+rax+1]		//imm
  bswap r8
  mov r9, qword ptr [rdi+0x8]
  
  mov qword ptr [r8], r9
  
  add rax, 9
  cmp rax, rsi
  jae .out_of_bounds						//only update ip if not out of bounds
  
  add qword ptr[rdi], 9
  jmp .main_loop
  
  



//[imm] = rX
.st_rX_imm:
  movzx r8, byte ptr [rdx+rax+1] 			// load X
  cmp r8, 0x8 
  jae .out_of_bounds

  mov r9, qword ptr [rdx+rax+2] 	//load imm
  bswap r9
  mov r10, qword ptr [rdi+0x10+r8*8] 
  
  mov [r9], r10

  add rax, 10
  cmp rax, rsi
  jae .out_of_bounds						//only update ip if not out of bounds
  
  add qword ptr[rdi], 10
  jmp .main_loop 
  
  

  

//[rx] = AC
.st_rX:
  movzx r8, byte ptr [rdx+rax+1] 			// load X
  cmp r8, 0x8 
  jae .out_of_bounds
  
  mov r9, qword ptr [rdi+0x10+r8*8]
  mov r10, qword ptr[rdi+0x8]
  
  mov [r9], r10

  add rax, 2
  cmp rax, rsi
  jae .out_of_bounds						//only update ip if not out of bounds
  
  add qword ptr[rdi], 2
  jmp .main_loop 




//[rX] = rY
.st_rX_rY:
  movzx r8, byte ptr [rdx+rax+1]  		
  movzx r9,  byte ptr [rdx+rax+1] 		// XY
  
  shr r8, 4		// extract X
  and r9, 0xf	// Y
  
  cmp r8, 0x8 
  jae .out_of_bounds
  cmp r9, 0x8
  jae .out_of_bounds

  mov rcx, qword ptr [rdi+0x10+r8*8]
  bswap rcx
  mov r10, qword ptr [rdi+0x10+r9*8]	//rY value
  mov [rcx], r10
  
  add rax, 2
  cmp rax, rsi
  jae .out_of_bounds						//only update ip if not out of bounds
  
  add qword ptr[rdi], 2
  jmp .main_loop
  
  
  
  
  
  
  
  
	/*
    	=== GO GO GO ===
    */
  
//ip = <imm>    
.go_imm:
  mov r8, qword ptr [rdx+rax+1] 		// load immediate
  bswap r8
  cmp r8, rsi
  jae .out_of_bounds
  
  mov qword ptr [rdi], r8 				// ip = immediate
  jmp .main_loop
  


//ip = rX
.go_rX:
  movzx rcx, byte ptr [rdx+rax+1] 
  cmp rcx, 0x8
  jae .out_of_bounds
  
  mov r8, qword ptr [rdi+0x10+rcx*8] 
  cmp r8, rsi
  jae .out_of_bounds
  
  mov qword ptr[rdi], r8		 		// ip = rX
  jmp .main_loop
  
  

//ip = ip + <imm>
.gr_imm:
  movzx r8, word ptr [rdx+rax+1] 		// load immediate
  bswap r8
  
  add r8, rax
  cmp r8, rsi
  jae .out_of_bounds
  
  mov qword ptr [rdi], r8
  jmp .main_loop
  



//ip = ac==0? <imm> : ip+sizeof(jz)
.jz_imm:
  mov r8, qword ptr [rdx+rax+1] 			// load immediate
  bswap r8
  cmp r8, rsi
  jae .out_of_bounds
  
  cmp qword ptr [rdi+0x8], 0 				// ac == 0?
  jne .jz_imm_notzero
  mov qword ptr [rdi], r8 					// if yes, ip = immediate
  jmp .main_loop
  
  .jz_imm_notzero:
  add rax, 9
  cmp rax, rsi
  jae .out_of_bounds
  
  add qword ptr [rdi], 9					 	// if not, increment ip
  jmp .main_loop




//ip = ac==0? rx : ip+sizeof(jz)
.jz_rX:
  movzx r8, byte ptr [rdx+rax+1]
  cmp r8, 0x8
  jae .out_of_bounds
  
  mov r9, [rdi+0x10+r8*8]
  cmp qword ptr [rdi+0x8], 0
  jne .jz_rX_notzero
  
  mov qword ptr [rdi], r9
  jmp .main_loop
  
  .jz_rX_notzero:
  add rax, 2
  cmp rax, rsi
  jae .out_of_bounds
  
  add qword ptr [rdi], 2
  jmp .main_loop
  
 


.jrz_imm:
  movzx r8, word ptr [rdx+rax+1] 			// load immediate
  bswap r8
  add r8, rax
  cmp r8, rsi
  jae .out_of_bounds						//if new ip >= len
  
  cmp qword ptr [rdi+0x8], 0
  jne .jrz_imm_notzero
  
  mov qword ptr [rdi], r8
  jmp .main_loop
  
  .jrz_imm_notzero:
  add rax, 3
  cmp rax, rsi
  jae .out_of_bounds
  
  add qword ptr [rdi], 3
  jmp .main_loop
  
.ecall_imm:

.ecall_rX:
  

 /*
 =======================================================================================
 	END
 =======================================================================================
 */
 
.out_of_bounds:
  mov rax, -2
  
.end:
//push all, clear stack? 
//make last
pop rbx
ret