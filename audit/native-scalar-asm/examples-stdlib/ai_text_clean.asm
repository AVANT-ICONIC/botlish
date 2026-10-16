; source:  examples/stdlib/ai_text_clean.bot
; backend: Cranelift (specialize=1), native::object
; object:  ELF64 x86-64, unlinked (Botlish-generated code only; runtime
;          helpers are unresolved imports, so their bodies are not present)
; format:  objdump -dr --no-show-raw-insn -M intel
; total machine code bytes: 2273  (per function: 147 207 558 752 103 506)
;
; function symbol -> Botlish label:
;   botlish_fn_0 / botlish_entry_0 -> <program entry>
;   botlish_fn_1 / botlish_entry_1 -> cleaner_emoji<UnicodeChar>
;   botlish_fn_2 / botlish_entry_2 -> clean_char<str>
;   botlish_fn_3 / botlish_entry_3 -> clean_from<str, int, str>
;   botlish_fn_4 / botlish_entry_4 -> clean_ai_text<str>
;   botlish_fn_5 / botlish_entry_5 -> sample<generic>


ai_text_clean.asm.o:     file format elf64-x86-64


Disassembly of section .text:

0000000000000000 <botlish_fn_0: <program entry>>:
   0:	push   rbp
   1:	mov    rbp,rsp
   4:	sub    rsp,0x10
   8:	mov    QWORD PTR [rsp],r12
   c:	mov    r12,rdi
   f:	mov    rdi,r12
  12:	call   17 <botlish_fn_0+0x17>
			13: R_X86_64_PLT32	botlish_fn_5-0x4 ; sample<generic>
  17:	test   rax,rax
  1a:	jne    63 <botlish_fn_0+0x63>
  20:	mov    rdi,r12
  23:	call   28 <botlish_fn_0+0x28>
			24: R_X86_64_PLT32	rt_declared_error-0x4
  28:	cmp    rax,0x40000002
  2e:	jne    53 <botlish_fn_0+0x53>
  34:	mov    rdi,r12
  37:	call   3c <botlish_fn_0+0x3c>
			38: R_X86_64_PLT32	rt_clear_declared_error-0x4
  3c:	xor    rdx,rdx
  3f:	mov    rdi,r12
  42:	mov    rsi,rdx
  45:	call   4a <botlish_fn_0+0x4a>
			46: R_X86_64_PLT32	rt_list_new-0x4
  4a:	test   rax,rax
  4d:	jne    63 <botlish_fn_0+0x63>
  53:	xor    rax,rax
  56:	mov    r12,QWORD PTR [rsp]
  5a:	add    rsp,0x10
  5e:	mov    rsp,rbp
  61:	pop    rbp
  62:	ret
  63:	mov    r12,QWORD PTR [rsp]
  67:	add    rsp,0x10
  6b:	mov    rsp,rbp
  6e:	pop    rbp
  6f:	ret

0000000000000070 <botlish_entry_0: <program entry>>:
  70:	push   rbp
  71:	mov    rbp,rsp
  74:	call   79 <botlish_entry_0+0x9>
			75: R_X86_64_PLT32	botlish_fn_0-0x4 ; <program entry>
  79:	mov    rsp,rbp
  7c:	pop    rbp
  7d:	ret

000000000000007e <botlish_fn_1: cleaner_emoji<UnicodeChar>>:
  7e:	push   rbp
  7f:	mov    rbp,rsp
  82:	cmp    rsi,0xfb004
  89:	je     132 <botlish_fn_1+0xb4>
  8f:	cmp    rsi,0xfb014
  96:	je     132 <botlish_fn_1+0xb4>
  9c:	cmp    rsi,0xfb214
  a3:	je     132 <botlish_fn_1+0xb4>
  a9:	cmp    rsi,0xfb06c
  b0:	je     132 <botlish_fn_1+0xb4>
  b6:	cmp    rsi,0xfa92c
  bd:	je     132 <botlish_fn_1+0xb4>
  c3:	cmp    rsi,0xfb404
  ca:	je     132 <botlish_fn_1+0xb4>
  d0:	cmp    rsi,0x1382c
  d7:	je     132 <botlish_fn_1+0xb4>
  dd:	cmp    rsi,0x13a64
  e4:	je     132 <botlish_fn_1+0xb4>
  ea:	cmp    rsi,0xf9c4c
  f1:	je     132 <botlish_fn_1+0xb4>
  f7:	cmp    rsi,0xfc8b4
  fe:	je     132 <botlish_fn_1+0xb4>
 104:	cmp    rsi,0xfa26c
 10b:	je     132 <botlish_fn_1+0xb4>
 111:	cmp    rsi,0xfa50c
 118:	je     128 <botlish_fn_1+0xaa>
 11e:	mov    eax,0x2
 123:	jmp    137 <botlish_fn_1+0xb9>
 128:	mov    eax,0x6
 12d:	jmp    137 <botlish_fn_1+0xb9>
 132:	mov    eax,0x6
 137:	mov    rsp,rbp
 13a:	pop    rbp
 13b:	ret

000000000000013c <botlish_entry_1: cleaner_emoji<UnicodeChar>>:
 13c:	push   rbp
 13d:	mov    rbp,rsp
 140:	mov    rsi,QWORD PTR [rdx]
 143:	call   148 <botlish_entry_1+0xc>
			144: R_X86_64_PLT32	botlish_fn_1-0x4 ; cleaner_emoji<UnicodeChar>
 148:	mov    rsp,rbp
 14b:	pop    rbp
 14c:	ret

000000000000014d <botlish_fn_2: clean_char<str>>:
 14d:	push   rbp
 14e:	mov    rbp,rsp
 151:	sub    rsp,0x20
 155:	mov    QWORD PTR [rsp],rbx
 159:	mov    QWORD PTR [rsp+0x8],r12
 15e:	mov    QWORD PTR [rsp+0x10],r13
 163:	mov    rbx,rdi
 166:	cmp    rsi,0xffffffffffffffff
 16a:	mov    r12,rsi
 16d:	setne  al
 170:	movzx  rax,al
 174:	test   rax,rax
 177:	jg     188 <botlish_fn_2+0x3b>
 17d:	mov    rsi,r12
 180:	mov    rdi,rbx
 183:	jmp    26b <botlish_fn_2+0x11e>
 188:	mov    rsi,r12
 18b:	mov    rdi,rbx
 18e:	call   193 <botlish_fn_2+0x46>
			18f: R_X86_64_PLT32	rt_short_to_str-0x4
 193:	movzx  rcx,BYTE PTR [rax+0x18]
 198:	mov    rsi,rax
 19b:	test   rcx,rcx
 19e:	jne    1b9 <botlish_fn_2+0x6c>
 1a4:	mov    edx,0x1
 1a9:	mov    rdi,rbx
 1ac:	call   1b1 <botlish_fn_2+0x64>
			1ad: R_X86_64_PLT32	rt_str_char_at_proven-0x4
 1b1:	mov    r13,rax
 1b4:	jmp    1c9 <botlish_fn_2+0x7c>
 1b9:	movzx  rax,BYTE PTR [rsi+0x19]
 1be:	shl    rax,0x3
 1c2:	or     rax,0x4
 1c6:	mov    r13,rax
 1c9:	mov    rsi,r13
 1cc:	mov    rdi,rbx
 1cf:	call   1d4 <botlish_fn_2+0x87>
			1d0: R_X86_64_PLT32	botlish_fn_1-0x4 ; cleaner_emoji<UnicodeChar>
 1d4:	cmp    rax,0x6
 1d8:	je     309 <botlish_fn_2+0x1bc>
 1de:	mov    rax,r13
 1e1:	cmp    rax,0x1009c
 1e7:	jne    1f5 <botlish_fn_2+0xa8>
 1ed:	mov    rdi,rbx
 1f0:	jmp    2ea <botlish_fn_2+0x19d>
 1f5:	cmp    rax,0x100a4
 1fb:	jne    209 <botlish_fn_2+0xbc>
 201:	mov    rdi,rbx
 204:	jmp    2ea <botlish_fn_2+0x19d>
 209:	cmp    rax,0x100c4
 20f:	jne    21d <botlish_fn_2+0xd0>
 215:	mov    rdi,rbx
 218:	jmp    2cb <botlish_fn_2+0x17e>
 21d:	cmp    rax,0x100cc
 223:	jne    231 <botlish_fn_2+0xe4>
 229:	mov    rdi,rbx
 22c:	jmp    2cb <botlish_fn_2+0x17e>
 231:	cmp    rax,0x100e4
 237:	jne    245 <botlish_fn_2+0xf8>
 23d:	mov    rdi,rbx
 240:	jmp    2ac <botlish_fn_2+0x15f>
 245:	cmp    rax,0x100ec
 24b:	jne    259 <botlish_fn_2+0x10c>
 251:	mov    rdi,rbx
 254:	jmp    2ac <botlish_fn_2+0x15f>
 259:	cmp    rax,0x10134
 25f:	je     28a <botlish_fn_2+0x13d>
 265:	mov    rsi,r12
 268:	mov    rdi,rbx
 26b:	mov    rdi,rbx
 26e:	call   273 <botlish_fn_2+0x126>
			26f: R_X86_64_PLT32	rt_short_to_str-0x4
 273:	mov    rbx,QWORD PTR [rsp]
 277:	mov    r12,QWORD PTR [rsp+0x8]
 27c:	mov    r13,QWORD PTR [rsp+0x10]
 281:	add    rsp,0x20
 285:	mov    rsp,rbp
 288:	pop    rbp
 289:	ret
 28a:	mov    rdi,rbx
 28d:	mov    rax,QWORD PTR [rdi+0x10]
 291:	mov    rax,QWORD PTR [rax+0x20]
 295:	mov    rbx,QWORD PTR [rsp]
 299:	mov    r12,QWORD PTR [rsp+0x8]
 29e:	mov    r13,QWORD PTR [rsp+0x10]
 2a3:	add    rsp,0x20
 2a7:	mov    rsp,rbp
 2aa:	pop    rbp
 2ab:	ret
 2ac:	mov    rax,QWORD PTR [rdi+0x10]
 2b0:	mov    rax,QWORD PTR [rax+0x18]
 2b4:	mov    rbx,QWORD PTR [rsp]
 2b8:	mov    r12,QWORD PTR [rsp+0x8]
 2bd:	mov    r13,QWORD PTR [rsp+0x10]
 2c2:	add    rsp,0x20
 2c6:	mov    rsp,rbp
 2c9:	pop    rbp
 2ca:	ret
 2cb:	mov    rcx,QWORD PTR [rdi+0x10]
 2cf:	mov    rax,QWORD PTR [rcx+0x10]
 2d3:	mov    rbx,QWORD PTR [rsp]
 2d7:	mov    r12,QWORD PTR [rsp+0x8]
 2dc:	mov    r13,QWORD PTR [rsp+0x10]
 2e1:	add    rsp,0x20
 2e5:	mov    rsp,rbp
 2e8:	pop    rbp
 2e9:	ret
 2ea:	mov    rdx,QWORD PTR [rdi+0x10]
 2ee:	mov    rax,QWORD PTR [rdx+0x8]
 2f2:	mov    rbx,QWORD PTR [rsp]
 2f6:	mov    r12,QWORD PTR [rsp+0x8]
 2fb:	mov    r13,QWORD PTR [rsp+0x10]
 300:	add    rsp,0x20
 304:	mov    rsp,rbp
 307:	pop    rbp
 308:	ret
 309:	mov    rdi,rbx
 30c:	mov    rsi,QWORD PTR [rdi+0x10]
 310:	mov    rax,QWORD PTR [rsi]
 313:	mov    rbx,QWORD PTR [rsp]
 317:	mov    r12,QWORD PTR [rsp+0x8]
 31c:	mov    r13,QWORD PTR [rsp+0x10]
 321:	add    rsp,0x20
 325:	mov    rsp,rbp
 328:	pop    rbp
 329:	ret

000000000000032a <botlish_entry_2: clean_char<str>>:
 32a:	push   rbp
 32b:	mov    rbp,rsp
 32e:	sub    rsp,0x10
 332:	mov    QWORD PTR [rsp],r12
 336:	mov    r12,rdi
 339:	mov    rsi,QWORD PTR [rdx]
 33c:	mov    r8,QWORD PTR [rip+0x0]        # 343 <botlish_entry_2+0x19>
			33f: R_X86_64_GOTPCREL	rt_str_to_short-0x4
 343:	call   r8
 346:	mov    rsi,rax
 349:	mov    rdi,r12
 34c:	call   351 <botlish_entry_2+0x27>
			34d: R_X86_64_PLT32	botlish_fn_2-0x4 ; clean_char<str>
 351:	mov    r8,QWORD PTR [rip+0x0]        # 358 <botlish_entry_2+0x2e>
			354: R_X86_64_GOTPCREL	rt_plan_materialize-0x4
 358:	mov    rsi,rax
 35b:	mov    rdi,r12
 35e:	call   r8
 361:	mov    r12,QWORD PTR [rsp]
 365:	add    rsp,0x10
 369:	mov    rsp,rbp
 36c:	pop    rbp
 36d:	ret
	...

0000000000000370 <botlish_fn_3: clean_from<str, int, str>>:
 370:	push   rbp
 371:	mov    rbp,rsp
 374:	sub    rsp,0xa0
 37b:	mov    QWORD PTR [rsp+0x70],rbx
 380:	mov    QWORD PTR [rsp+0x78],r12
 385:	mov    QWORD PTR [rsp+0x80],r13
 38d:	mov    QWORD PTR [rsp+0x88],r14
 395:	mov    QWORD PTR [rsp+0x90],r15
 39d:	mov    r14,rdi
 3a0:	mov    QWORD PTR [rsp+0x18],0x0
 3a9:	mov    QWORD PTR [rsp+0x20],0x0
 3b2:	mov    QWORD PTR [rsp],rsi
 3b6:	mov    QWORD PTR [rsp+0x8],rcx
 3bb:	mov    r15,rcx
 3be:	mov    QWORD PTR [rsp+0x10],r8
 3c3:	sar    rdx,1
 3c6:	lea    r13,[rsp+0x38]
 3cb:	mov    rbx,rsi
 3ce:	mov    QWORD PTR [rsp+0x58],r8
 3d3:	mov    rax,QWORD PTR [rbx+0x8]
 3d7:	shl    rax,1
 3da:	or     rax,0x1
 3de:	sar    rax,1
 3e1:	mov    r12,rdx
 3e4:	cmp    r12,rax
 3e7:	jge    57f <botlish_fn_3+0x20f>
 3ed:	mov    rax,QWORD PTR [rbx+0x8]
 3f1:	mov    rcx,r12
 3f4:	shl    rcx,1
 3f7:	or     rcx,0x1
 3fb:	shl    rax,1
 3fe:	or     rax,0x1
 402:	mov    edx,0x2
 407:	cmp    rcx,rax
 40a:	cmovge rdx,QWORD PTR [rip+0x1fe]        # 610 <botlish_fn_3+0x2a0>
 412:	cmp    rdx,0x6
 416:	je     4bf <botlish_fn_3+0x14f>
 41c:	mov    rdx,QWORD PTR [rsp+0x58]
 421:	mov    rsi,rbx
 424:	mov    rdi,r14
 427:	call   42c <botlish_fn_3+0xbc>
			428: R_X86_64_PLT32	rt_str_decode_char_at-0x4
 42c:	mov    QWORD PTR [rsp+0x18],rax
 431:	mov    QWORD PTR [rsp+0x60],rax
 436:	mov    rsi,QWORD PTR [rsp+0x60]
 43b:	mov    rdi,r14
 43e:	call   443 <botlish_fn_3+0xd3>
			43f: R_X86_64_PLT32	rt_str_byte_len-0x4
 443:	mov    QWORD PTR [rsp+0x20],rax
 448:	mov    rsi,QWORD PTR [rsp+0x58]
 44d:	and    rsi,rax
 450:	test   rsi,0x1
 457:	jne    46a <botlish_fn_3+0xfa>
 45d:	mov    rdx,rax
 460:	mov    rsi,QWORD PTR [rsp+0x58]
 465:	jmp    4a0 <botlish_fn_3+0x130>
 46a:	lea    r8,[rax-0x1]
 46e:	mov    rdx,rax
 471:	mov    rsi,QWORD PTR [rsp+0x58]
 476:	mov    rdi,rsi
 479:	add    rdi,r8
 47c:	seto   r9b
 480:	test   r9b,r9b
 483:	je     493 <botlish_fn_3+0x123>
 489:	mov    rsi,QWORD PTR [rsp+0x58]
 48e:	jmp    4a0 <botlish_fn_3+0x130>
 493:	mov    rsi,rdi
 496:	mov    QWORD PTR [rsp+0x58],rdi
 49b:	jmp    4b0 <botlish_fn_3+0x140>
 4a0:	mov    rdi,r14
 4a3:	call   4a8 <botlish_fn_3+0x138>
			4a4: R_X86_64_PLT32	rt_int_add-0x4
 4a8:	mov    rsi,rax
 4ab:	mov    QWORD PTR [rsp+0x58],rax
 4b0:	mov    QWORD PTR [rsp+0x10],rsi
 4b5:	mov    rsi,QWORD PTR [rsp+0x60]
 4ba:	jmp    4d3 <botlish_fn_3+0x163>
 4bf:	mov    rdi,r14
 4c2:	mov    rax,QWORD PTR [rdi+0x10]
 4c6:	mov    rsi,QWORD PTR [rax]
 4c9:	mov    rax,QWORD PTR [rsp+0x58]
 4ce:	mov    QWORD PTR [rsp+0x10],rax
 4d3:	mov    rax,QWORD PTR [rsi+0x8]
 4d7:	mov    rcx,rsi
 4da:	mov    rsi,0xffffffffffffffff
 4e1:	test   rax,rax
 4e4:	je     510 <botlish_fn_3+0x1a0>
 4ea:	mov    rsi,rcx
 4ed:	movzx  rax,BYTE PTR [rsi+0x18]
 4f2:	test   rax,rax
 4f5:	jne    50b <botlish_fn_3+0x19b>
 4fb:	mov    rdi,r14
 4fe:	call   503 <botlish_fn_3+0x193>
			4ff: R_X86_64_PLT32	rt_str_to_short-0x4
 503:	mov    rsi,rax
 506:	jmp    510 <botlish_fn_3+0x1a0>
 50b:	movzx  rsi,BYTE PTR [rsi+0x19]
 510:	mov    rdi,r14
 513:	call   518 <botlish_fn_3+0x1a8>
			514: R_X86_64_PLT32	botlish_fn_2-0x4 ; clean_char<str>
 518:	mov    QWORD PTR [rsp+0x18],rax
 51d:	mov    QWORD PTR [rsp+0x38],0x0
 526:	mov    rcx,r15
 529:	mov    QWORD PTR [rsp+0x40],rcx
 52e:	mov    QWORD PTR [rsp+0x48],0x0
 537:	mov    QWORD PTR [rsp+0x50],rax
 53c:	mov    esi,0x2
 541:	mov    edx,0x4
 546:	mov    rcx,r13
 549:	mov    rdi,r14
 54c:	call   551 <botlish_fn_3+0x1e1>
			54d: R_X86_64_PLT32	rt_construct-0x4
 551:	test   rax,rax
 554:	je     5b1 <botlish_fn_3+0x241>
 55a:	mov    QWORD PTR [rsp],rbx
 55e:	mov    QWORD PTR [rsp+0x8],rax
 563:	mov    rsi,QWORD PTR [rsp+0x58]
 568:	mov    QWORD PTR [rsp+0x10],rsi
 56d:	add    r12,0x1
 574:	mov    rdx,r12
 577:	mov    r15,rax
 57a:	jmp    3d3 <botlish_fn_3+0x63>
 57f:	mov    rcx,r15
 582:	xor    rsi,rsi
 585:	lea    rax,[rsp+0x28]
 58a:	mov    QWORD PTR [rsp+0x28],0x0
 593:	mov    QWORD PTR [rsp+0x30],rcx
 598:	mov    edx,0x2
 59d:	mov    rcx,rax
 5a0:	mov    rdi,r14
 5a3:	call   5a8 <botlish_fn_3+0x238>
			5a4: R_X86_64_PLT32	rt_construct-0x4
 5a8:	test   rax,rax
 5ab:	jne    5e2 <botlish_fn_3+0x272>
 5b1:	xor    rax,rax
 5b4:	mov    rbx,QWORD PTR [rsp+0x70]
 5b9:	mov    r12,QWORD PTR [rsp+0x78]
 5be:	mov    r13,QWORD PTR [rsp+0x80]
 5c6:	mov    r14,QWORD PTR [rsp+0x88]
 5ce:	mov    r15,QWORD PTR [rsp+0x90]
 5d6:	add    rsp,0xa0
 5dd:	mov    rsp,rbp
 5e0:	pop    rbp
 5e1:	ret
 5e2:	mov    rbx,QWORD PTR [rsp+0x70]
 5e7:	mov    r12,QWORD PTR [rsp+0x78]
 5ec:	mov    r13,QWORD PTR [rsp+0x80]
 5f4:	mov    r14,QWORD PTR [rsp+0x88]
 5fc:	mov    r15,QWORD PTR [rsp+0x90]
 604:	add    rsp,0xa0
 60b:	mov    rsp,rbp
 60e:	pop    rbp
 60f:	ret
 610:	(bad)
 611:	add    BYTE PTR [rax],al
 613:	add    BYTE PTR [rax],al
 615:	add    BYTE PTR [rax],al
	...

0000000000000618 <botlish_entry_3: clean_from<str, int, str>>:
 618:	push   rbp
 619:	mov    rbp,rsp
 61c:	mov    rsi,QWORD PTR [rdx]
 61f:	mov    r9,QWORD PTR [rdx+0x8]
 623:	mov    rcx,QWORD PTR [rdx+0x10]
 627:	mov    r8,QWORD PTR [rdx+0x18]
 62b:	mov    rdx,r9
 62e:	call   633 <botlish_entry_3+0x1b>
			62f: R_X86_64_PLT32	botlish_fn_3-0x4 ; clean_from<str, int, str>
 633:	mov    rsp,rbp
 636:	pop    rbp
 637:	ret

0000000000000638 <botlish_fn_4: clean_ai_text<str>>:
 638:	push   rbp
 639:	mov    rbp,rsp
 63c:	sub    rsp,0x20
 640:	mov    QWORD PTR [rsp],rsi
 644:	mov    r8d,0x1
 64a:	mov    QWORD PTR [rsp+0x8],0x1
 653:	mov    r11,QWORD PTR [rdi+0x10]
 657:	mov    rcx,QWORD PTR [r11]
 65a:	mov    QWORD PTR [rsp+0x10],rcx
 65f:	mov    QWORD PTR [rsp+0x18],0x1
 668:	mov    rdx,r8
 66b:	call   670 <botlish_fn_4+0x38>
			66c: R_X86_64_PLT32	botlish_fn_3-0x4 ; clean_from<str, int, str>
 670:	test   rax,rax
 673:	jne    685 <botlish_fn_4+0x4d>
 679:	xor    rax,rax
 67c:	add    rsp,0x20
 680:	mov    rsp,rbp
 683:	pop    rbp
 684:	ret
 685:	add    rsp,0x20
 689:	mov    rsp,rbp
 68c:	pop    rbp
 68d:	ret

000000000000068e <botlish_entry_4: clean_ai_text<str>>:
 68e:	push   rbp
 68f:	mov    rbp,rsp
 692:	mov    rsi,QWORD PTR [rdx]
 695:	call   69a <botlish_entry_4+0xc>
			696: R_X86_64_PLT32	botlish_fn_4-0x4 ; clean_ai_text<str>
 69a:	mov    rsp,rbp
 69d:	pop    rbp
 69e:	ret

000000000000069f <botlish_fn_5: sample<generic>>:
 69f:	push   rbp
 6a0:	mov    rbp,rsp
 6a3:	sub    rsp,0xa0
 6aa:	mov    QWORD PTR [rsp+0x70],rbx
 6af:	mov    QWORD PTR [rsp+0x78],r12
 6b4:	mov    QWORD PTR [rsp+0x80],r13
 6bc:	mov    QWORD PTR [rsp+0x88],r14
 6c4:	mov    QWORD PTR [rsp+0x90],r15
 6cc:	mov    QWORD PTR [rsp+0x8],0x0
 6d5:	mov    QWORD PTR [rsp+0x10],0x0
 6de:	mov    QWORD PTR [rsp+0x18],0x0
 6e7:	mov    QWORD PTR [rsp+0x20],0x0
 6f0:	mov    QWORD PTR [rsp+0x28],0x0
 6f9:	mov    rax,QWORD PTR [rdi+0x10]
 6fd:	mov    rbx,rdi
 700:	mov    rsi,QWORD PTR [rax+0x28]
 704:	mov    QWORD PTR [rsp],rsi
 708:	call   70d <botlish_fn_5+0x6e>
			709: R_X86_64_PLT32	botlish_fn_4-0x4 ; clean_ai_text<str>
 70d:	test   rax,rax
 710:	je     824 <botlish_fn_5+0x185>
 716:	mov    QWORD PTR [rsp],rax
 71a:	mov    rdi,rbx
 71d:	mov    r12,rax
 720:	mov    rax,QWORD PTR [rdi+0x10]
 724:	mov    rsi,QWORD PTR [rax+0x30]
 728:	mov    QWORD PTR [rsp+0x8],rsi
 72d:	call   732 <botlish_fn_5+0x93>
			72e: R_X86_64_PLT32	botlish_fn_4-0x4 ; clean_ai_text<str>
 732:	test   rax,rax
 735:	je     824 <botlish_fn_5+0x185>
 73b:	mov    QWORD PTR [rsp+0x8],rax
 740:	mov    rdi,rbx
 743:	mov    r13,rax
 746:	mov    rax,QWORD PTR [rdi+0x10]
 74a:	mov    rsi,QWORD PTR [rax+0x38]
 74e:	mov    QWORD PTR [rsp+0x10],rsi
 753:	call   758 <botlish_fn_5+0xb9>
			754: R_X86_64_PLT32	botlish_fn_4-0x4 ; clean_ai_text<str>
 758:	test   rax,rax
 75b:	je     824 <botlish_fn_5+0x185>
 761:	mov    QWORD PTR [rsp+0x10],rax
 766:	mov    rdi,rbx
 769:	mov    r14,rax
 76c:	mov    rax,QWORD PTR [rdi+0x10]
 770:	mov    rsi,QWORD PTR [rax+0x40]
 774:	mov    QWORD PTR [rsp+0x18],rsi
 779:	call   77e <botlish_fn_5+0xdf>
			77a: R_X86_64_PLT32	botlish_fn_4-0x4 ; clean_ai_text<str>
 77e:	test   rax,rax
 781:	je     824 <botlish_fn_5+0x185>
 787:	mov    QWORD PTR [rsp+0x18],rax
 78c:	mov    rdi,rbx
 78f:	mov    r15,rax
 792:	mov    rax,QWORD PTR [rdi+0x10]
 796:	mov    rsi,QWORD PTR [rax+0x48]
 79a:	mov    QWORD PTR [rsp+0x20],rsi
 79f:	call   7a4 <botlish_fn_5+0x105>
			7a0: R_X86_64_PLT32	botlish_fn_4-0x4 ; clean_ai_text<str>
 7a4:	test   rax,rax
 7a7:	je     824 <botlish_fn_5+0x185>
 7ad:	mov    QWORD PTR [rsp+0x20],rax
 7b2:	mov    rdi,rbx
 7b5:	mov    QWORD PTR [rsp+0x60],rax
 7ba:	mov    rax,QWORD PTR [rdi+0x10]
 7be:	mov    rsi,QWORD PTR [rax+0x50]
 7c2:	mov    QWORD PTR [rsp+0x28],rsi
 7c7:	call   7cc <botlish_fn_5+0x12d>
			7c8: R_X86_64_PLT32	botlish_fn_4-0x4 ; clean_ai_text<str>
 7cc:	test   rax,rax
 7cf:	je     824 <botlish_fn_5+0x185>
 7d5:	mov    QWORD PTR [rsp+0x28],rax
 7da:	lea    rdx,[rsp+0x30]
 7df:	mov    rcx,r12
 7e2:	mov    QWORD PTR [rsp+0x30],rcx
 7e7:	mov    rcx,r13
 7ea:	mov    QWORD PTR [rsp+0x38],rcx
 7ef:	mov    rcx,r14
 7f2:	mov    QWORD PTR [rsp+0x40],rcx
 7f7:	mov    rcx,r15
 7fa:	mov    QWORD PTR [rsp+0x48],rcx
 7ff:	mov    rcx,QWORD PTR [rsp+0x60]
 804:	mov    QWORD PTR [rsp+0x50],rcx
 809:	mov    QWORD PTR [rsp+0x58],rax
 80e:	mov    esi,0x6
 813:	mov    rdi,rbx
 816:	call   81b <botlish_fn_5+0x17c>
			817: R_X86_64_PLT32	rt_list_new-0x4
 81b:	test   rax,rax
 81e:	jne    855 <botlish_fn_5+0x1b6>
 824:	xor    rax,rax
 827:	mov    rbx,QWORD PTR [rsp+0x70]
 82c:	mov    r12,QWORD PTR [rsp+0x78]
 831:	mov    r13,QWORD PTR [rsp+0x80]
 839:	mov    r14,QWORD PTR [rsp+0x88]
 841:	mov    r15,QWORD PTR [rsp+0x90]
 849:	add    rsp,0xa0
 850:	mov    rsp,rbp
 853:	pop    rbp
 854:	ret
 855:	mov    rbx,QWORD PTR [rsp+0x70]
 85a:	mov    r12,QWORD PTR [rsp+0x78]
 85f:	mov    r13,QWORD PTR [rsp+0x80]
 867:	mov    r14,QWORD PTR [rsp+0x88]
 86f:	mov    r15,QWORD PTR [rsp+0x90]
 877:	add    rsp,0xa0
 87e:	mov    rsp,rbp
 881:	pop    rbp
 882:	ret

0000000000000883 <botlish_entry_5: sample<generic>>:
 883:	push   rbp
 884:	mov    rbp,rsp
 887:	call   88c <botlish_entry_5+0x9>
			888: R_X86_64_PLT32	botlish_fn_5-0x4 ; sample<generic>
 88c:	mov    rsp,rbp
 88f:	pop    rbp
 890:	ret
