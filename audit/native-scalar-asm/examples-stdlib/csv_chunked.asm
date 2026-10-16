; source:  examples/stdlib/csv_chunked.bot
; backend: Cranelift (specialize=1), native::object
; object:  ELF64 x86-64, unlinked (Botlish-generated code only; runtime
;          helpers are unresolved imports, so their bodies are not present)
; format:  objdump -dr --no-show-raw-insn -M intel
; total machine code bytes: 6829  (per function: 312 315 757 757 504 625 365 309 470 932 311 630 388 154)
;
; function symbol -> Botlish label:
;   botlish_fn_0 / botlish_entry_0 -> <program entry>
;   botlish_fn_1 / botlish_entry_1 -> chunked_new<generic>
;   botlish_fn_2 / botlish_entry_2 -> chunked_append<ChunkedBuilder, str>
;   botlish_fn_3 / botlish_entry_3 -> chunked_append<ChunkedBuilder, list>
;   botlish_fn_4 / botlish_entry_4 -> chunked_copy_chunks<list, int, mutarray, int>
;   botlish_fn_5 / botlish_entry_5 -> chunked_finish<ChunkedBuilder>
;   botlish_fn_6 / botlish_entry_6 -> peek<str, int>
;   botlish_fn_7 / botlish_entry_7 -> quote_at?<str, int>
;   botlish_fn_8 / botlish_entry_8 -> scan_unquoted<str, int, int>
;   botlish_fn_9 / botlish_entry_9 -> scan_quoted<str, int, str>
;   botlish_fn_10 / botlish_entry_10 -> scan_field<str, int>
;   botlish_fn_11 / botlish_entry_11 -> scan_record<str, int, ChunkedBuilder>
;   botlish_fn_12 / botlish_entry_12 -> scan_records<str, int, ChunkedBuilder>
;   botlish_fn_13 / botlish_entry_13 -> csv_parse<str>


csv_chunked.asm.o:     file format elf64-x86-64


Disassembly of section .text:

0000000000000000 <botlish_fn_0: <program entry>>:
       0:	push   rbp
       1:	mov    rbp,rsp
       4:	sub    rsp,0x20
       8:	mov    QWORD PTR [rsp+0x10],rbx
       d:	mov    rax,QWORD PTR [rdi+0x10]
      11:	mov    rbx,rdi
      14:	mov    rsi,QWORD PTR [rax]
      17:	mov    QWORD PTR [rsp],rsi
      1b:	call   20 <botlish_fn_0+0x20>
			1c: R_X86_64_PLT32	botlish_fn_13-0x4 ; csv_parse<str>
      20:	test   rax,rax
      23:	jne    dd <botlish_fn_0+0xdd>
      29:	mov    rdi,rbx
      2c:	call   31 <botlish_fn_0+0x31>
			2d: R_X86_64_PLT32	rt_declared_error-0x4
      31:	cmp    rax,0x40000001
      37:	je     ad <botlish_fn_0+0xad>
      3d:	mov    rdi,rbx
      40:	call   45 <botlish_fn_0+0x45>
			41: R_X86_64_PLT32	rt_declared_error-0x4
      45:	cmp    rax,0x40000002
      4b:	je     89 <botlish_fn_0+0x89>
      51:	mov    rdi,rbx
      54:	call   59 <botlish_fn_0+0x59>
			55: R_X86_64_PLT32	rt_declared_error-0x4
      59:	cmp    rax,0x40000003
      5f:	jne    cc <botlish_fn_0+0xcc>
      65:	mov    rdi,rbx
      68:	call   6d <botlish_fn_0+0x6d>
			69: R_X86_64_PLT32	rt_clear_declared_error-0x4
      6d:	xor    rdx,rdx
      70:	mov    rdi,rbx
      73:	mov    rsi,rdx
      76:	call   7b <botlish_fn_0+0x7b>
			77: R_X86_64_PLT32	rt_list_new-0x4
      7b:	test   rax,rax
      7e:	je     cc <botlish_fn_0+0xcc>
      84:	jmp    dd <botlish_fn_0+0xdd>
      89:	mov    rdi,rbx
      8c:	call   91 <botlish_fn_0+0x91>
			8d: R_X86_64_PLT32	rt_clear_declared_error-0x4
      91:	xor    rdx,rdx
      94:	mov    rdi,rbx
      97:	mov    rsi,rdx
      9a:	call   9f <botlish_fn_0+0x9f>
			9b: R_X86_64_PLT32	rt_list_new-0x4
      9f:	test   rax,rax
      a2:	je     cc <botlish_fn_0+0xcc>
      a8:	jmp    dd <botlish_fn_0+0xdd>
      ad:	mov    rdi,rbx
      b0:	call   b5 <botlish_fn_0+0xb5>
			b1: R_X86_64_PLT32	rt_clear_declared_error-0x4
      b5:	xor    rdx,rdx
      b8:	mov    rdi,rbx
      bb:	mov    rsi,rdx
      be:	call   c3 <botlish_fn_0+0xc3>
			bf: R_X86_64_PLT32	rt_list_new-0x4
      c3:	test   rax,rax
      c6:	jne    dd <botlish_fn_0+0xdd>
      cc:	xor    rax,rax
      cf:	mov    rbx,QWORD PTR [rsp+0x10]
      d4:	add    rsp,0x20
      d8:	mov    rsp,rbp
      db:	pop    rbp
      dc:	ret
      dd:	mov    rbx,QWORD PTR [rsp+0x10]
      e2:	add    rsp,0x20
      e6:	mov    rsp,rbp
      e9:	pop    rbp
      ea:	ret

00000000000000eb <botlish_entry_0: <program entry>>:
      eb:	push   rbp
      ec:	mov    rbp,rsp
      ef:	call   f4 <botlish_entry_0+0x9>
			f0: R_X86_64_PLT32	botlish_fn_0-0x4 ; <program entry>
      f4:	mov    rsp,rbp
      f7:	pop    rbp
      f8:	ret

00000000000000f9 <botlish_fn_1: chunked_new<generic>>:
      f9:	push   rbp
      fa:	mov    rbp,rsp
      fd:	sub    rsp,0x60
     101:	mov    QWORD PTR [rsp+0x40],rbx
     106:	mov    QWORD PTR [rsp+0x48],r12
     10b:	mov    QWORD PTR [rsp+0x50],r13
     110:	mov    rbx,rdi
     113:	mov    QWORD PTR [rsp],0x0
     11b:	mov    QWORD PTR [rsp+0x8],0x0
     124:	mov    QWORD PTR [rsp+0x10],0x0
     12d:	mov    QWORD PTR [rsp+0x18],0x0
     136:	xor    rdx,rdx
     139:	mov    rdi,rbx
     13c:	mov    rsi,rdx
     13f:	call   144 <botlish_fn_1+0x4b>
			140: R_X86_64_PLT32	rt_list_new-0x4
     144:	test   rax,rax
     147:	je     1a8 <botlish_fn_1+0xaf>
     14d:	mov    QWORD PTR [rsp],rax
     151:	mov    r12,rax
     154:	mov    esi,0x81
     159:	mov    QWORD PTR [rsp+0x8],0x81
     162:	mov    rdi,rbx
     165:	call   16a <botlish_fn_1+0x71>
			166: R_X86_64_PLT32	rt_mutarray_allocate-0x4
     16a:	test   rax,rax
     16d:	je     1a8 <botlish_fn_1+0xaf>
     173:	mov    QWORD PTR [rsp+0x8],rax
     178:	mov    r13,rax
     17b:	mov    esi,0x3
     180:	mov    QWORD PTR [rsp+0x10],0x3
     189:	mov    edx,0x1
     18e:	mov    QWORD PTR [rsp+0x18],0x1
     197:	mov    rdi,rbx
     19a:	call   19f <botlish_fn_1+0xa6>
			19b: R_X86_64_PLT32	rt_mutarray_create-0x4
     19f:	test   rax,rax
     1a2:	jne    1c3 <botlish_fn_1+0xca>
     1a8:	xor    rax,rax
     1ab:	mov    rbx,QWORD PTR [rsp+0x40]
     1b0:	mov    r12,QWORD PTR [rsp+0x48]
     1b5:	mov    r13,QWORD PTR [rsp+0x50]
     1ba:	add    rsp,0x60
     1be:	mov    rsp,rbp
     1c1:	pop    rbp
     1c2:	ret
     1c3:	mov    QWORD PTR [rsp+0x10],rax
     1c8:	lea    rcx,[rsp+0x20]
     1cd:	mov    rdx,r12
     1d0:	mov    QWORD PTR [rsp+0x20],rdx
     1d5:	mov    rdx,r13
     1d8:	mov    QWORD PTR [rsp+0x28],rdx
     1dd:	mov    QWORD PTR [rsp+0x30],rax
     1e2:	xor    rsi,rsi
     1e5:	mov    edx,0x3
     1ea:	mov    rdi,rbx
     1ed:	call   1f2 <botlish_fn_1+0xf9>
			1ee: R_X86_64_PLT32	rt_struct_new-0x4
     1f2:	mov    rbx,QWORD PTR [rsp+0x40]
     1f7:	mov    r12,QWORD PTR [rsp+0x48]
     1fc:	mov    r13,QWORD PTR [rsp+0x50]
     201:	add    rsp,0x60
     205:	mov    rsp,rbp
     208:	pop    rbp
     209:	ret

000000000000020a <botlish_entry_1: chunked_new<generic>>:
     20a:	push   rbp
     20b:	mov    rbp,rsp
     20e:	call   213 <botlish_entry_1+0x9>
			20f: R_X86_64_PLT32	botlish_fn_1-0x4 ; chunked_new<generic>
     213:	mov    rsp,rbp
     216:	pop    rbp
     217:	ret

0000000000000218 <botlish_fn_2: chunked_append<ChunkedBuilder, str>>:
     218:	push   rbp
     219:	mov    rbp,rsp
     21c:	sub    rsp,0x70
     220:	mov    QWORD PTR [rsp+0x40],rbx
     225:	mov    QWORD PTR [rsp+0x48],r12
     22a:	mov    QWORD PTR [rsp+0x50],r13
     22f:	mov    QWORD PTR [rsp+0x58],r14
     234:	mov    QWORD PTR [rsp+0x60],r15
     239:	mov    r13,rdi
     23c:	mov    QWORD PTR [rsp+0x18],0x0
     245:	mov    QWORD PTR [rsp+0x20],0x0
     24e:	mov    QWORD PTR [rsp],rsi
     252:	mov    QWORD PTR [rsp+0x8],rdx
     257:	mov    r15,rdx
     25a:	mov    rax,QWORD PTR [rsi+0x18]
     25e:	mov    r14,rsi
     261:	mov    rsi,QWORD PTR [rax+0x10]
     265:	mov    edx,0x1
     26a:	mov    rdi,r13
     26d:	call   272 <botlish_fn_2+0x5a>
			26e: R_X86_64_PLT32	rt_mutarray_get-0x4
     272:	mov    rcx,rax
     275:	mov    r12,rax
     278:	test   rax,rcx
     27b:	je     436 <botlish_fn_2+0x21e>
     281:	mov    rax,r12
     284:	mov    QWORD PTR [rsp+0x8],rax
     289:	test   rax,0x1
     28f:	jne    2ba <botlish_fn_2+0xa2>
     295:	mov    edx,0x81
     29a:	mov    rsi,r12
     29d:	mov    rdi,r13
     2a0:	call   2a5 <botlish_fn_2+0x8d>
			2a1: R_X86_64_PLT32	rt_int_cmp-0x4
     2a5:	mov    ecx,0x2
     2aa:	test   rax,rax
     2ad:	cmove  rcx,QWORD PTR [rip+0x1fb]        # 4b0 <botlish_fn_2+0x298>
     2b5:	jmp    2ce <botlish_fn_2+0xb6>
     2ba:	mov    ecx,0x2
     2bf:	cmp    r12,0x81
     2c6:	cmove  rcx,QWORD PTR [rip+0x1e2]        # 4b0 <botlish_fn_2+0x298>
     2ce:	cmp    rcx,0x6
     2d2:	je     38e <botlish_fn_2+0x176>
     2d8:	mov    rbx,r14
     2db:	mov    rcx,QWORD PTR [rbx+0x18]
     2df:	mov    rsi,QWORD PTR [rcx+0x8]
     2e3:	mov    rcx,r15
     2e6:	mov    rdx,r12
     2e9:	mov    rdi,r13
     2ec:	call   2f1 <botlish_fn_2+0xd9>
			2ed: R_X86_64_PLT32	rt_mutarray_set-0x4
     2f1:	test   rax,rax
     2f4:	je     436 <botlish_fn_2+0x21e>
     2fa:	mov    rcx,QWORD PTR [rbx+0x18]
     2fe:	mov    r14,rbx
     301:	mov    rbx,QWORD PTR [rcx+0x10]
     305:	mov    QWORD PTR [rsp+0x10],rbx
     30a:	mov    QWORD PTR [rsp+0x18],0x1
     313:	mov    QWORD PTR [rsp+0x20],0x3
     31c:	test   r12,0x1
     323:	je     33d <botlish_fn_2+0x125>
     329:	mov    rcx,r12
     32c:	add    rcx,0x2
     330:	seto   r8b
     334:	test   r8b,r8b
     337:	je     350 <botlish_fn_2+0x138>
     33d:	mov    edx,0x3
     342:	mov    rsi,r12
     345:	mov    rdi,r13
     348:	call   34d <botlish_fn_2+0x135>
			349: R_X86_64_PLT32	rt_int_add-0x4
     34d:	mov    rcx,rax
     350:	mov    edx,0x1
     355:	mov    rsi,rbx
     358:	mov    rdi,r13
     35b:	call   360 <botlish_fn_2+0x148>
			35c: R_X86_64_PLT32	rt_mutarray_set-0x4
     360:	test   rax,rax
     363:	je     436 <botlish_fn_2+0x21e>
     369:	mov    rax,r14
     36c:	mov    rbx,QWORD PTR [rsp+0x40]
     371:	mov    r12,QWORD PTR [rsp+0x48]
     376:	mov    r13,QWORD PTR [rsp+0x50]
     37b:	mov    r14,QWORD PTR [rsp+0x58]
     380:	mov    r15,QWORD PTR [rsp+0x60]
     385:	add    rsp,0x70
     389:	mov    rsp,rbp
     38c:	pop    rbp
     38d:	ret
     38e:	mov    esi,0x81
     393:	mov    QWORD PTR [rsp+0x10],0x81
     39c:	mov    rdi,r13
     39f:	call   3a4 <botlish_fn_2+0x18c>
			3a0: R_X86_64_PLT32	rt_mutarray_allocate-0x4
     3a4:	test   rax,rax
     3a7:	je     436 <botlish_fn_2+0x21e>
     3ad:	mov    QWORD PTR [rsp],rax
     3b1:	mov    r12,rax
     3b4:	mov    edx,0x1
     3b9:	mov    rcx,r15
     3bc:	mov    rsi,r12
     3bf:	mov    rdi,r13
     3c2:	call   3c7 <botlish_fn_2+0x1af>
			3c3: R_X86_64_PLT32	rt_mutarray_set-0x4
     3c7:	test   rax,rax
     3ca:	je     436 <botlish_fn_2+0x21e>
     3d0:	mov    rax,r14
     3d3:	mov    rax,QWORD PTR [rax+0x18]
     3d7:	mov    rsi,QWORD PTR [rax]
     3da:	mov    QWORD PTR [rsp+0x8],rsi
     3df:	mov    rax,r14
     3e2:	mov    rax,QWORD PTR [rax+0x18]
     3e6:	mov    rdx,QWORD PTR [rax+0x8]
     3ea:	mov    QWORD PTR [rsp+0x10],rdx
     3ef:	mov    rdi,r13
     3f2:	call   3f7 <botlish_fn_2+0x1df>
			3f3: R_X86_64_PLT32	rt_list_append-0x4
     3f7:	test   rax,rax
     3fa:	je     436 <botlish_fn_2+0x21e>
     400:	mov    QWORD PTR [rsp+0x8],rax
     405:	mov    r14,rax
     408:	mov    edx,0x3
     40d:	mov    rbx,rdx
     410:	mov    QWORD PTR [rsp+0x10],0x3
     419:	mov    QWORD PTR [rsp+0x18],0x3
     422:	mov    rsi,rbx
     425:	mov    rdi,r13
     428:	call   42d <botlish_fn_2+0x215>
			429: R_X86_64_PLT32	rt_mutarray_create-0x4
     42d:	test   rax,rax
     430:	jne    45b <botlish_fn_2+0x243>
     436:	xor    rax,rax
     439:	mov    rbx,QWORD PTR [rsp+0x40]
     43e:	mov    r12,QWORD PTR [rsp+0x48]
     443:	mov    r13,QWORD PTR [rsp+0x50]
     448:	mov    r14,QWORD PTR [rsp+0x58]
     44d:	mov    r15,QWORD PTR [rsp+0x60]
     452:	add    rsp,0x70
     456:	mov    rsp,rbp
     459:	pop    rbp
     45a:	ret
     45b:	mov    QWORD PTR [rsp+0x10],rax
     460:	lea    rcx,[rsp+0x28]
     465:	mov    rdx,r14
     468:	mov    QWORD PTR [rsp+0x28],rdx
     46d:	mov    rdx,r12
     470:	mov    QWORD PTR [rsp+0x30],rdx
     475:	mov    QWORD PTR [rsp+0x38],rax
     47a:	xor    rsi,rsi
     47d:	mov    rdx,rbx
     480:	mov    rdi,r13
     483:	call   488 <botlish_fn_2+0x270>
			484: R_X86_64_PLT32	rt_struct_new-0x4
     488:	mov    rbx,QWORD PTR [rsp+0x40]
     48d:	mov    r12,QWORD PTR [rsp+0x48]
     492:	mov    r13,QWORD PTR [rsp+0x50]
     497:	mov    r14,QWORD PTR [rsp+0x58]
     49c:	mov    r15,QWORD PTR [rsp+0x60]
     4a1:	add    rsp,0x70
     4a5:	mov    rsp,rbp
     4a8:	pop    rbp
     4a9:	ret
     4aa:	add    BYTE PTR [rax],al
     4ac:	add    BYTE PTR [rax],al
     4ae:	add    BYTE PTR [rax],al
     4b0:	(bad)
     4b1:	add    BYTE PTR [rax],al
     4b3:	add    BYTE PTR [rax],al
     4b5:	add    BYTE PTR [rax],al
	...

00000000000004b8 <botlish_entry_2: chunked_append<ChunkedBuilder, str>>:
     4b8:	push   rbp
     4b9:	mov    rbp,rsp
     4bc:	mov    rsi,QWORD PTR [rdx]
     4bf:	mov    rdx,QWORD PTR [rdx+0x8]
     4c3:	call   4c8 <botlish_entry_2+0x10>
			4c4: R_X86_64_PLT32	botlish_fn_2-0x4 ; chunked_append<ChunkedBuilder, str>
     4c8:	mov    rsp,rbp
     4cb:	pop    rbp
     4cc:	ret
     4cd:	add    BYTE PTR [rax],al
	...

00000000000004d0 <botlish_fn_3: chunked_append<ChunkedBuilder, list>>:
     4d0:	push   rbp
     4d1:	mov    rbp,rsp
     4d4:	sub    rsp,0x70
     4d8:	mov    QWORD PTR [rsp+0x40],rbx
     4dd:	mov    QWORD PTR [rsp+0x48],r12
     4e2:	mov    QWORD PTR [rsp+0x50],r13
     4e7:	mov    QWORD PTR [rsp+0x58],r14
     4ec:	mov    QWORD PTR [rsp+0x60],r15
     4f1:	mov    r13,rdi
     4f4:	mov    QWORD PTR [rsp+0x18],0x0
     4fd:	mov    QWORD PTR [rsp+0x20],0x0
     506:	mov    QWORD PTR [rsp],rsi
     50a:	mov    QWORD PTR [rsp+0x8],rdx
     50f:	mov    r15,rdx
     512:	mov    rax,QWORD PTR [rsi+0x18]
     516:	mov    r14,rsi
     519:	mov    rsi,QWORD PTR [rax+0x10]
     51d:	mov    edx,0x1
     522:	mov    rdi,r13
     525:	call   52a <botlish_fn_3+0x5a>
			526: R_X86_64_PLT32	rt_mutarray_get-0x4
     52a:	mov    rcx,rax
     52d:	mov    r12,rax
     530:	test   rax,rcx
     533:	je     6ee <botlish_fn_3+0x21e>
     539:	mov    rax,r12
     53c:	mov    QWORD PTR [rsp+0x8],rax
     541:	test   rax,0x1
     547:	jne    572 <botlish_fn_3+0xa2>
     54d:	mov    edx,0x81
     552:	mov    rsi,r12
     555:	mov    rdi,r13
     558:	call   55d <botlish_fn_3+0x8d>
			559: R_X86_64_PLT32	rt_int_cmp-0x4
     55d:	mov    ecx,0x2
     562:	test   rax,rax
     565:	cmove  rcx,QWORD PTR [rip+0x1fb]        # 768 <botlish_fn_3+0x298>
     56d:	jmp    586 <botlish_fn_3+0xb6>
     572:	mov    ecx,0x2
     577:	cmp    r12,0x81
     57e:	cmove  rcx,QWORD PTR [rip+0x1e2]        # 768 <botlish_fn_3+0x298>
     586:	cmp    rcx,0x6
     58a:	je     646 <botlish_fn_3+0x176>
     590:	mov    rbx,r14
     593:	mov    rcx,QWORD PTR [rbx+0x18]
     597:	mov    rsi,QWORD PTR [rcx+0x8]
     59b:	mov    rcx,r15
     59e:	mov    rdx,r12
     5a1:	mov    rdi,r13
     5a4:	call   5a9 <botlish_fn_3+0xd9>
			5a5: R_X86_64_PLT32	rt_mutarray_set-0x4
     5a9:	test   rax,rax
     5ac:	je     6ee <botlish_fn_3+0x21e>
     5b2:	mov    rcx,QWORD PTR [rbx+0x18]
     5b6:	mov    r14,rbx
     5b9:	mov    rbx,QWORD PTR [rcx+0x10]
     5bd:	mov    QWORD PTR [rsp+0x10],rbx
     5c2:	mov    QWORD PTR [rsp+0x18],0x1
     5cb:	mov    QWORD PTR [rsp+0x20],0x3
     5d4:	test   r12,0x1
     5db:	je     5f5 <botlish_fn_3+0x125>
     5e1:	mov    rcx,r12
     5e4:	add    rcx,0x2
     5e8:	seto   r8b
     5ec:	test   r8b,r8b
     5ef:	je     608 <botlish_fn_3+0x138>
     5f5:	mov    edx,0x3
     5fa:	mov    rsi,r12
     5fd:	mov    rdi,r13
     600:	call   605 <botlish_fn_3+0x135>
			601: R_X86_64_PLT32	rt_int_add-0x4
     605:	mov    rcx,rax
     608:	mov    edx,0x1
     60d:	mov    rsi,rbx
     610:	mov    rdi,r13
     613:	call   618 <botlish_fn_3+0x148>
			614: R_X86_64_PLT32	rt_mutarray_set-0x4
     618:	test   rax,rax
     61b:	je     6ee <botlish_fn_3+0x21e>
     621:	mov    rax,r14
     624:	mov    rbx,QWORD PTR [rsp+0x40]
     629:	mov    r12,QWORD PTR [rsp+0x48]
     62e:	mov    r13,QWORD PTR [rsp+0x50]
     633:	mov    r14,QWORD PTR [rsp+0x58]
     638:	mov    r15,QWORD PTR [rsp+0x60]
     63d:	add    rsp,0x70
     641:	mov    rsp,rbp
     644:	pop    rbp
     645:	ret
     646:	mov    esi,0x81
     64b:	mov    QWORD PTR [rsp+0x10],0x81
     654:	mov    rdi,r13
     657:	call   65c <botlish_fn_3+0x18c>
			658: R_X86_64_PLT32	rt_mutarray_allocate-0x4
     65c:	test   rax,rax
     65f:	je     6ee <botlish_fn_3+0x21e>
     665:	mov    QWORD PTR [rsp],rax
     669:	mov    r12,rax
     66c:	mov    edx,0x1
     671:	mov    rcx,r15
     674:	mov    rsi,r12
     677:	mov    rdi,r13
     67a:	call   67f <botlish_fn_3+0x1af>
			67b: R_X86_64_PLT32	rt_mutarray_set-0x4
     67f:	test   rax,rax
     682:	je     6ee <botlish_fn_3+0x21e>
     688:	mov    rax,r14
     68b:	mov    rax,QWORD PTR [rax+0x18]
     68f:	mov    rsi,QWORD PTR [rax]
     692:	mov    QWORD PTR [rsp+0x8],rsi
     697:	mov    rax,r14
     69a:	mov    rax,QWORD PTR [rax+0x18]
     69e:	mov    rdx,QWORD PTR [rax+0x8]
     6a2:	mov    QWORD PTR [rsp+0x10],rdx
     6a7:	mov    rdi,r13
     6aa:	call   6af <botlish_fn_3+0x1df>
			6ab: R_X86_64_PLT32	rt_list_append-0x4
     6af:	test   rax,rax
     6b2:	je     6ee <botlish_fn_3+0x21e>
     6b8:	mov    QWORD PTR [rsp+0x8],rax
     6bd:	mov    r14,rax
     6c0:	mov    edx,0x3
     6c5:	mov    rbx,rdx
     6c8:	mov    QWORD PTR [rsp+0x10],0x3
     6d1:	mov    QWORD PTR [rsp+0x18],0x3
     6da:	mov    rsi,rbx
     6dd:	mov    rdi,r13
     6e0:	call   6e5 <botlish_fn_3+0x215>
			6e1: R_X86_64_PLT32	rt_mutarray_create-0x4
     6e5:	test   rax,rax
     6e8:	jne    713 <botlish_fn_3+0x243>
     6ee:	xor    rax,rax
     6f1:	mov    rbx,QWORD PTR [rsp+0x40]
     6f6:	mov    r12,QWORD PTR [rsp+0x48]
     6fb:	mov    r13,QWORD PTR [rsp+0x50]
     700:	mov    r14,QWORD PTR [rsp+0x58]
     705:	mov    r15,QWORD PTR [rsp+0x60]
     70a:	add    rsp,0x70
     70e:	mov    rsp,rbp
     711:	pop    rbp
     712:	ret
     713:	mov    QWORD PTR [rsp+0x10],rax
     718:	lea    rcx,[rsp+0x28]
     71d:	mov    rdx,r14
     720:	mov    QWORD PTR [rsp+0x28],rdx
     725:	mov    rdx,r12
     728:	mov    QWORD PTR [rsp+0x30],rdx
     72d:	mov    QWORD PTR [rsp+0x38],rax
     732:	xor    rsi,rsi
     735:	mov    rdx,rbx
     738:	mov    rdi,r13
     73b:	call   740 <botlish_fn_3+0x270>
			73c: R_X86_64_PLT32	rt_struct_new-0x4
     740:	mov    rbx,QWORD PTR [rsp+0x40]
     745:	mov    r12,QWORD PTR [rsp+0x48]
     74a:	mov    r13,QWORD PTR [rsp+0x50]
     74f:	mov    r14,QWORD PTR [rsp+0x58]
     754:	mov    r15,QWORD PTR [rsp+0x60]
     759:	add    rsp,0x70
     75d:	mov    rsp,rbp
     760:	pop    rbp
     761:	ret
     762:	add    BYTE PTR [rax],al
     764:	add    BYTE PTR [rax],al
     766:	add    BYTE PTR [rax],al
     768:	(bad)
     769:	add    BYTE PTR [rax],al
     76b:	add    BYTE PTR [rax],al
     76d:	add    BYTE PTR [rax],al
	...

0000000000000770 <botlish_entry_3: chunked_append<ChunkedBuilder, list>>:
     770:	push   rbp
     771:	mov    rbp,rsp
     774:	mov    rsi,QWORD PTR [rdx]
     777:	mov    rdx,QWORD PTR [rdx+0x8]
     77b:	call   780 <botlish_entry_3+0x10>
			77c: R_X86_64_PLT32	botlish_fn_3-0x4 ; chunked_append<ChunkedBuilder, list>
     780:	mov    rsp,rbp
     783:	pop    rbp
     784:	ret

0000000000000785 <botlish_fn_4: chunked_copy_chunks<list, int, mutarray, int>>:
     785:	push   rbp
     786:	mov    rbp,rsp
     789:	sub    rsp,0x50
     78d:	mov    QWORD PTR [rsp+0x20],rbx
     792:	mov    QWORD PTR [rsp+0x28],r12
     797:	mov    QWORD PTR [rsp+0x30],r13
     79c:	mov    QWORD PTR [rsp+0x38],r14
     7a1:	mov    QWORD PTR [rsp+0x40],r15
     7a6:	mov    r14,rdi
     7a9:	mov    QWORD PTR [rsp],rsi
     7ad:	mov    QWORD PTR [rsp+0x8],rcx
     7b2:	mov    r12,rcx
     7b5:	mov    QWORD PTR [rsp+0x10],r8
     7ba:	sar    rdx,1
     7bd:	mov    rbx,rdx
     7c0:	mov    r13,rsi
     7c3:	mov    r15,r8
     7c6:	mov    rsi,r13
     7c9:	mov    rdi,r14
     7cc:	call   7d1 <botlish_fn_4+0x4c>
			7cd: R_X86_64_PLT32	rt_list_len-0x4
     7d1:	sar    rax,1
     7d4:	cmp    rbx,rax
     7d7:	jge    912 <botlish_fn_4+0x18d>
     7dd:	mov    rdx,QWORD PTR [r13+0x8]
     7e1:	mov    rcx,rbx
     7e4:	shl    rcx,1
     7e7:	or     rcx,0x1
     7eb:	sar    rcx,1
     7ee:	cmp    rcx,rdx
     7f1:	jb     81d <botlish_fn_4+0x98>
     7f7:	mov    rdx,rbx
     7fa:	shl    rdx,1
     7fd:	or     rdx,0x1
     801:	mov    rsi,r13
     804:	mov    rdi,r14
     807:	call   80c <botlish_fn_4+0x87>
			808: R_X86_64_PLT32	rt_list_get-0x4
     80c:	test   rax,rax
     80f:	je     888 <botlish_fn_4+0x103>
     815:	mov    rsi,rax
     818:	jmp    828 <botlish_fn_4+0xa3>
     81d:	mov    rax,QWORD PTR [r13+0x10]
     821:	mov    rax,QWORD PTR [rax+rcx*8]
     825:	mov    rsi,rax
     828:	xor    ecx,ecx
     82a:	test   rsi,0x7
     831:	jne    840 <botlish_fn_4+0xbb>
     837:	movzx  rax,BYTE PTR [rsi]
     83b:	cmp    al,0x8
     83d:	sete   cl
     840:	test   cl,cl
     842:	jne    862 <botlish_fn_4+0xdd>
     848:	mov    rdi,r14
     84b:	mov    rax,QWORD PTR [rdi+0x10]
     84f:	mov    rcx,QWORD PTR [rax+0x8]
     853:	mov    edx,0x8
     858:	call   85d <botlish_fn_4+0xd8>
			859: R_X86_64_PLT32	rt_type_error-0x4
     85d:	jmp    888 <botlish_fn_4+0x103>
     862:	mov    rcx,rsi
     865:	mov    r8d,0x1
     86b:	mov    r9d,0x81
     871:	mov    rdx,r15
     874:	mov    rsi,r12
     877:	mov    rdi,r14
     87a:	call   87f <botlish_fn_4+0xfa>
			87b: R_X86_64_PLT32	rt_mutarray_copy-0x4
     87f:	test   rax,rax
     882:	jne    8ad <botlish_fn_4+0x128>
     888:	xor    rax,rax
     88b:	mov    rbx,QWORD PTR [rsp+0x20]
     890:	mov    r12,QWORD PTR [rsp+0x28]
     895:	mov    r13,QWORD PTR [rsp+0x30]
     89a:	mov    r14,QWORD PTR [rsp+0x38]
     89f:	mov    r15,QWORD PTR [rsp+0x40]
     8a4:	add    rsp,0x50
     8a8:	mov    rsp,rbp
     8ab:	pop    rbp
     8ac:	ret
     8ad:	mov    QWORD PTR [rsp+0x18],0x81
     8b6:	mov    rsi,r15
     8b9:	test   rsi,0x1
     8c0:	je     8e5 <botlish_fn_4+0x160>
     8c6:	mov    rdi,rsi
     8c9:	add    rdi,0x80
     8d0:	seto   r9b
     8d4:	test   r9b,r9b
     8d7:	jne    8e5 <botlish_fn_4+0x160>
     8dd:	mov    rsi,rdi
     8e0:	jmp    8f5 <botlish_fn_4+0x170>
     8e5:	mov    edx,0x81
     8ea:	mov    rdi,r14
     8ed:	call   8f2 <botlish_fn_4+0x16d>
			8ee: R_X86_64_PLT32	rt_int_add-0x4
     8f2:	mov    rsi,rax
     8f5:	mov    QWORD PTR [rsp],r13
     8f9:	mov    QWORD PTR [rsp+0x8],r12
     8fe:	mov    QWORD PTR [rsp+0x10],rsi
     903:	add    rbx,0x1
     90a:	mov    r15,rsi
     90d:	jmp    7c6 <botlish_fn_4+0x41>
     912:	mov    rax,r12
     915:	mov    rbx,QWORD PTR [rsp+0x20]
     91a:	mov    r12,QWORD PTR [rsp+0x28]
     91f:	mov    r13,QWORD PTR [rsp+0x30]
     924:	mov    r14,QWORD PTR [rsp+0x38]
     929:	mov    r15,QWORD PTR [rsp+0x40]
     92e:	add    rsp,0x50
     932:	mov    rsp,rbp
     935:	pop    rbp
     936:	ret

0000000000000937 <botlish_entry_4: chunked_copy_chunks<list, int, mutarray, int>>:
     937:	push   rbp
     938:	mov    rbp,rsp
     93b:	mov    rsi,QWORD PTR [rdx]
     93e:	mov    r9,QWORD PTR [rdx+0x8]
     942:	mov    rcx,QWORD PTR [rdx+0x10]
     946:	mov    r8,QWORD PTR [rdx+0x18]
     94a:	mov    rdx,r9
     94d:	call   952 <botlish_entry_4+0x1b>
			94e: R_X86_64_PLT32	botlish_fn_4-0x4 ; chunked_copy_chunks<list, int, mutarray, int>
     952:	mov    rsp,rbp
     955:	pop    rbp
     956:	ret
	...

0000000000000958 <botlish_fn_5: chunked_finish<ChunkedBuilder>>:
     958:	push   rbp
     959:	mov    rbp,rsp
     95c:	sub    rsp,0x80
     963:	mov    QWORD PTR [rsp+0x50],rbx
     968:	mov    QWORD PTR [rsp+0x58],r12
     96d:	mov    QWORD PTR [rsp+0x60],r13
     972:	mov    QWORD PTR [rsp+0x68],r14
     977:	mov    QWORD PTR [rsp+0x70],r15
     97c:	mov    r14,rdi
     97f:	mov    QWORD PTR [rsp+0x20],0x0
     988:	mov    QWORD PTR [rsp+0x28],0x0
     991:	mov    QWORD PTR [rsp+0x30],0x0
     99a:	mov    QWORD PTR [rsp+0x38],0x0
     9a3:	mov    QWORD PTR [rsp],rsi
     9a7:	mov    rax,QWORD PTR [rsi+0x18]
     9ab:	mov    rbx,rsi
     9ae:	mov    rsi,QWORD PTR [rax+0x10]
     9b2:	mov    edx,0x1
     9b7:	mov    rdi,r14
     9ba:	call   9bf <botlish_fn_5+0x67>
			9bb: R_X86_64_PLT32	rt_mutarray_get-0x4
     9bf:	test   rax,rax
     9c2:	je     b2a <botlish_fn_5+0x1d2>
     9c8:	mov    QWORD PTR [rsp+0x8],rax
     9cd:	mov    r13,rax
     9d0:	mov    rax,QWORD PTR [rbx+0x18]
     9d4:	mov    rsi,QWORD PTR [rax]
     9d7:	mov    rdi,r14
     9da:	call   9df <botlish_fn_5+0x87>
			9db: R_X86_64_PLT32	rt_list_len-0x4
     9df:	mov    QWORD PTR [rsp+0x10],rax
     9e4:	mov    QWORD PTR [rsp+0x18],0x81
     9ed:	test   rax,0x1
     9f3:	mov    rsi,rax
     9f6:	je     a23 <botlish_fn_5+0xcb>
     9fc:	mov    rcx,rsi
     9ff:	mov    rax,rcx
     a02:	sar    rax,1
     a05:	imul   QWORD PTR [rip+0x16c]        # b78 <botlish_fn_5+0x220>
     a0c:	seto   cl
     a0f:	or     rax,0x1
     a13:	test   cl,cl
     a15:	jne    a23 <botlish_fn_5+0xcb>
     a1b:	mov    rdx,rax
     a1e:	jmp    a33 <botlish_fn_5+0xdb>
     a23:	mov    edx,0x81
     a28:	mov    rdi,r14
     a2b:	call   a30 <botlish_fn_5+0xd8>
			a2c: R_X86_64_PLT32	rt_int_mul-0x4
     a30:	mov    rdx,rax
     a33:	mov    QWORD PTR [rsp+0x10],rdx
     a38:	mov    rax,rdx
     a3b:	and    rax,r13
     a3e:	test   rax,0x1
     a44:	jne    a52 <botlish_fn_5+0xfa>
     a4a:	mov    r15,rdx
     a4d:	jmp    a6a <botlish_fn_5+0x112>
     a52:	lea    rcx,[r13-0x1]
     a56:	mov    r12,rdx
     a59:	add    r12,rcx
     a5c:	mov    r15,rdx
     a5f:	seto   al
     a62:	test   al,al
     a64:	je     a7b <botlish_fn_5+0x123>
     a6a:	mov    rdx,r13
     a6d:	mov    rsi,r15
     a70:	mov    rdi,r14
     a73:	call   a78 <botlish_fn_5+0x120>
			a74: R_X86_64_PLT32	rt_int_add-0x4
     a78:	mov    r12,rax
     a7b:	mov    QWORD PTR [rsp+0x18],r12
     a80:	mov    rcx,QWORD PTR [rbx+0x18]
     a84:	mov    rsi,QWORD PTR [rcx]
     a87:	mov    QWORD PTR [rsp+0x20],rsi
     a8c:	mov    QWORD PTR [rsp+0x40],rsi
     a91:	mov    QWORD PTR [rsp+0x28],0x1
     a9a:	mov    rsi,r12
     a9d:	mov    rdi,r14
     aa0:	call   aa5 <botlish_fn_5+0x14d>
			aa1: R_X86_64_PLT32	rt_mutarray_allocate-0x4
     aa5:	test   rax,rax
     aa8:	je     b2a <botlish_fn_5+0x1d2>
     aae:	mov    QWORD PTR [rsp+0x30],rax
     ab3:	mov    rcx,rax
     ab6:	mov    r8d,0x1
     abc:	mov    QWORD PTR [rsp+0x38],0x1
     ac5:	mov    rsi,QWORD PTR [rsp+0x40]
     aca:	mov    rdi,r14
     acd:	mov    rdx,r8
     ad0:	call   ad5 <botlish_fn_5+0x17d>
			ad1: R_X86_64_PLT32	botlish_fn_4-0x4 ; chunked_copy_chunks<list, int, mutarray, int>
     ad5:	test   rax,rax
     ad8:	je     b2a <botlish_fn_5+0x1d2>
     ade:	mov    QWORD PTR [rsp],rax
     ae2:	mov    QWORD PTR [rsp+0x40],rax
     ae7:	mov    rcx,QWORD PTR [rbx+0x18]
     aeb:	mov    rcx,QWORD PTR [rcx+0x8]
     aef:	mov    r8d,0x1
     af5:	mov    rdx,r15
     af8:	mov    r9,r13
     afb:	mov    rsi,QWORD PTR [rsp+0x40]
     b00:	mov    rdi,r14
     b03:	call   b08 <botlish_fn_5+0x1b0>
			b04: R_X86_64_PLT32	rt_mutarray_copy-0x4
     b08:	test   rax,rax
     b0b:	je     b2a <botlish_fn_5+0x1d2>
     b11:	mov    rdx,r12
     b14:	mov    rsi,QWORD PTR [rsp+0x40]
     b19:	mov    rdi,r14
     b1c:	call   b21 <botlish_fn_5+0x1c9>
			b1d: R_X86_64_PLT32	rt_mutarray_freeze-0x4
     b21:	test   rax,rax
     b24:	jne    b52 <botlish_fn_5+0x1fa>
     b2a:	xor    rax,rax
     b2d:	mov    rbx,QWORD PTR [rsp+0x50]
     b32:	mov    r12,QWORD PTR [rsp+0x58]
     b37:	mov    r13,QWORD PTR [rsp+0x60]
     b3c:	mov    r14,QWORD PTR [rsp+0x68]
     b41:	mov    r15,QWORD PTR [rsp+0x70]
     b46:	add    rsp,0x80
     b4d:	mov    rsp,rbp
     b50:	pop    rbp
     b51:	ret
     b52:	mov    rbx,QWORD PTR [rsp+0x50]
     b57:	mov    r12,QWORD PTR [rsp+0x58]
     b5c:	mov    r13,QWORD PTR [rsp+0x60]
     b61:	mov    r14,QWORD PTR [rsp+0x68]
     b66:	mov    r15,QWORD PTR [rsp+0x70]
     b6b:	add    rsp,0x80
     b72:	mov    rsp,rbp
     b75:	pop    rbp
     b76:	ret
     b77:	add    BYTE PTR [rax+0x0],al
     b7d:	add    BYTE PTR [rax],al
	...

0000000000000b80 <botlish_entry_5: chunked_finish<ChunkedBuilder>>:
     b80:	push   rbp
     b81:	mov    rbp,rsp
     b84:	mov    rsi,QWORD PTR [rdx]
     b87:	call   b8c <botlish_entry_5+0xc>
			b88: R_X86_64_PLT32	botlish_fn_5-0x4 ; chunked_finish<ChunkedBuilder>
     b8c:	mov    rsp,rbp
     b8f:	pop    rbp
     b90:	ret
     b91:	add    BYTE PTR [rax],al
     b93:	add    BYTE PTR [rax],al
     b95:	add    BYTE PTR [rax],al
	...

0000000000000b98 <botlish_fn_6: peek<str, int>>:
     b98:	push   rbp
     b99:	mov    rbp,rsp
     b9c:	sub    rsp,0x40
     ba0:	mov    QWORD PTR [rsp+0x20],rbx
     ba5:	mov    QWORD PTR [rsp+0x28],r12
     baa:	mov    QWORD PTR [rsp+0x30],r13
     baf:	mov    rbx,rdx
     bb2:	mov    r13,rdi
     bb5:	mov    QWORD PTR [rsp],rsi
     bb9:	mov    QWORD PTR [rsp+0x8],rdx
     bbe:	mov    rdx,QWORD PTR [rsi+0x8]
     bc2:	mov    r12,rsi
     bc5:	shl    rdx,1
     bc8:	mov    rax,rdx
     bcb:	or     rax,0x1
     bcf:	mov    rcx,rbx
     bd2:	and    rcx,rax
     bd5:	test   rcx,0x1
     bdc:	jne    c06 <botlish_fn_6+0x6e>
     be2:	or     rdx,0x1
     be6:	mov    rsi,rbx
     be9:	mov    rdi,r13
     bec:	call   bf1 <botlish_fn_6+0x59>
			bed: R_X86_64_PLT32	rt_int_cmp-0x4
     bf1:	mov    ecx,0x2
     bf6:	test   rax,rax
     bf9:	cmovge rcx,QWORD PTR [rip+0xd7]        # cd8 <botlish_fn_6+0x140>
     c01:	jmp    c1a <botlish_fn_6+0x82>
     c06:	or     rdx,0x1
     c0a:	mov    ecx,0x2
     c0f:	cmp    rbx,rdx
     c12:	cmovge rcx,QWORD PTR [rip+0xbe]        # cd8 <botlish_fn_6+0x140>
     c1a:	cmp    rcx,0x6
     c1e:	je     cae <botlish_fn_6+0x116>
     c24:	mov    QWORD PTR [rsp+0x10],0x3
     c2d:	test   rbx,0x1
     c34:	je     c4c <botlish_fn_6+0xb4>
     c3a:	mov    rcx,rbx
     c3d:	add    rcx,0x2
     c41:	seto   al
     c44:	test   al,al
     c46:	je     c5f <botlish_fn_6+0xc7>
     c4c:	mov    edx,0x3
     c51:	mov    rsi,rbx
     c54:	mov    rdi,r13
     c57:	call   c5c <botlish_fn_6+0xc4>
			c58: R_X86_64_PLT32	rt_int_add-0x4
     c5c:	mov    rcx,rax
     c5f:	mov    QWORD PTR [rsp+0x10],rcx
     c64:	mov    rdx,rbx
     c67:	mov    rsi,r12
     c6a:	mov    rdi,r13
     c6d:	call   c72 <botlish_fn_6+0xda>
			c6e: R_X86_64_PLT32	rt_substr-0x4
     c72:	test   rax,rax
     c75:	jne    c96 <botlish_fn_6+0xfe>
     c7b:	xor    rax,rax
     c7e:	mov    rbx,QWORD PTR [rsp+0x20]
     c83:	mov    r12,QWORD PTR [rsp+0x28]
     c88:	mov    r13,QWORD PTR [rsp+0x30]
     c8d:	add    rsp,0x40
     c91:	mov    rsp,rbp
     c94:	pop    rbp
     c95:	ret
     c96:	mov    rbx,QWORD PTR [rsp+0x20]
     c9b:	mov    r12,QWORD PTR [rsp+0x28]
     ca0:	mov    r13,QWORD PTR [rsp+0x30]
     ca5:	add    rsp,0x40
     ca9:	mov    rsp,rbp
     cac:	pop    rbp
     cad:	ret
     cae:	mov    rdi,r13
     cb1:	mov    rax,QWORD PTR [rdi+0x10]
     cb5:	mov    rax,QWORD PTR [rax+0x10]
     cb9:	mov    rbx,QWORD PTR [rsp+0x20]
     cbe:	mov    r12,QWORD PTR [rsp+0x28]
     cc3:	mov    r13,QWORD PTR [rsp+0x30]
     cc8:	add    rsp,0x40
     ccc:	mov    rsp,rbp
     ccf:	pop    rbp
     cd0:	ret
     cd1:	add    BYTE PTR [rax],al
     cd3:	add    BYTE PTR [rax],al
     cd5:	add    BYTE PTR [rax],al
     cd7:	add    BYTE PTR [rsi],al
     cd9:	add    BYTE PTR [rax],al
     cdb:	add    BYTE PTR [rax],al
     cdd:	add    BYTE PTR [rax],al
	...

0000000000000ce0 <botlish_entry_6: peek<str, int>>:
     ce0:	push   rbp
     ce1:	mov    rbp,rsp
     ce4:	mov    rsi,QWORD PTR [rdx]
     ce7:	mov    rdx,QWORD PTR [rdx+0x8]
     ceb:	call   cf0 <botlish_entry_6+0x10>
			cec: R_X86_64_PLT32	botlish_fn_6-0x4 ; peek<str, int>
     cf0:	mov    rsp,rbp
     cf3:	pop    rbp
     cf4:	ret
     cf5:	add    BYTE PTR [rax],al
	...

0000000000000cf8 <botlish_fn_7: quote_at?<str, int>>:
     cf8:	push   rbp
     cf9:	mov    rbp,rsp
     cfc:	sub    rsp,0x20
     d00:	mov    QWORD PTR [rsp],rbx
     d04:	mov    QWORD PTR [rsp+0x8],r12
     d09:	mov    QWORD PTR [rsp+0x10],r13
     d0e:	mov    rbx,rdx
     d11:	mov    r13,rdi
     d14:	mov    rdx,QWORD PTR [rsi+0x8]
     d18:	mov    r12,rsi
     d1b:	shl    rdx,1
     d1e:	mov    rax,rdx
     d21:	or     rax,0x1
     d25:	mov    rcx,rbx
     d28:	and    rcx,rax
     d2b:	test   rcx,0x1
     d32:	jne    d5c <botlish_fn_7+0x64>
     d38:	or     rdx,0x1
     d3c:	mov    rsi,rbx
     d3f:	mov    rdi,r13
     d42:	call   d47 <botlish_fn_7+0x4f>
			d43: R_X86_64_PLT32	rt_int_cmp-0x4
     d47:	mov    ecx,0x2
     d4c:	test   rax,rax
     d4f:	cmovl  rcx,QWORD PTR [rip+0xa1]        # df8 <botlish_fn_7+0x100>
     d57:	jmp    d73 <botlish_fn_7+0x7b>
     d5c:	or     rdx,0x1
     d60:	mov    ecx,0x2
     d65:	mov    rax,rbx
     d68:	cmp    rax,rdx
     d6b:	cmovl  rcx,QWORD PTR [rip+0x85]        # df8 <botlish_fn_7+0x100>
     d73:	mov    eax,0x6
     d78:	cmp    rcx,0x6
     d7c:	je     d8f <botlish_fn_7+0x97>
     d82:	mov    eax,0x2
     d87:	mov    r12,rax
     d8a:	jmp    ddc <botlish_fn_7+0xe4>
     d8f:	mov    rdi,r13
     d92:	mov    rsi,r12
     d95:	mov    r12,rax
     d98:	mov    rdx,rbx
     d9b:	call   da0 <botlish_fn_7+0xa8>
			d9c: R_X86_64_PLT32	rt_str_char_at-0x4
     da0:	test   rax,rax
     da3:	jne    dc3 <botlish_fn_7+0xcb>
     da9:	xor    rax,rax
     dac:	mov    rbx,QWORD PTR [rsp]
     db0:	mov    r12,QWORD PTR [rsp+0x8]
     db5:	mov    r13,QWORD PTR [rsp+0x10]
     dba:	add    rsp,0x20
     dbe:	mov    rsp,rbp
     dc1:	pop    rbp
     dc2:	ret
     dc3:	cmp    rax,0x114
     dc9:	je     dd9 <botlish_fn_7+0xe1>
     dcf:	mov    eax,0x2
     dd4:	jmp    ddc <botlish_fn_7+0xe4>
     dd9:	mov    rax,r12
     ddc:	mov    rbx,QWORD PTR [rsp]
     de0:	mov    r12,QWORD PTR [rsp+0x8]
     de5:	mov    r13,QWORD PTR [rsp+0x10]
     dea:	add    rsp,0x20
     dee:	mov    rsp,rbp
     df1:	pop    rbp
     df2:	ret
     df3:	add    BYTE PTR [rax],al
     df5:	add    BYTE PTR [rax],al
     df7:	add    BYTE PTR [rsi],al
     df9:	add    BYTE PTR [rax],al
     dfb:	add    BYTE PTR [rax],al
     dfd:	add    BYTE PTR [rax],al
	...

0000000000000e00 <botlish_entry_7: quote_at?<str, int>>:
     e00:	push   rbp
     e01:	mov    rbp,rsp
     e04:	mov    rsi,QWORD PTR [rdx]
     e07:	mov    rdx,QWORD PTR [rdx+0x8]
     e0b:	call   e10 <botlish_entry_7+0x10>
			e0c: R_X86_64_PLT32	botlish_fn_7-0x4 ; quote_at?<str, int>
     e10:	mov    rsp,rbp
     e13:	pop    rbp
     e14:	ret
     e15:	add    BYTE PTR [rax],al
	...

0000000000000e18 <botlish_fn_8: scan_unquoted<str, int, int>>:
     e18:	push   rbp
     e19:	mov    rbp,rsp
     e1c:	sub    rsp,0x40
     e20:	mov    QWORD PTR [rsp+0x20],rbx
     e25:	mov    QWORD PTR [rsp+0x28],r12
     e2a:	mov    QWORD PTR [rsp+0x30],r13
     e2f:	mov    QWORD PTR [rsp+0x38],r14
     e34:	mov    r13,rdi
     e37:	mov    QWORD PTR [rsp+0x18],0x0
     e40:	mov    QWORD PTR [rsp],rsi
     e44:	mov    r12,rsi
     e47:	mov    QWORD PTR [rsp+0x8],rdx
     e4c:	mov    rbx,rdx
     e4f:	mov    QWORD PTR [rsp+0x10],rcx
     e54:	mov    rax,r12
     e57:	mov    rsi,rcx
     e5a:	mov    rdx,QWORD PTR [rax+0x8]
     e5e:	mov    r12,rax
     e61:	shl    rdx,1
     e64:	or     rdx,0x1
     e68:	mov    rax,rsi
     e6b:	and    rax,rdx
     e6e:	mov    r14,rsi
     e71:	test   rax,0x1
     e77:	jne    e9d <botlish_fn_8+0x85>
     e7d:	mov    rsi,r14
     e80:	mov    rdi,r13
     e83:	call   e88 <botlish_fn_8+0x70>
			e84: R_X86_64_PLT32	rt_int_cmp-0x4
     e88:	mov    ecx,0x2
     e8d:	test   rax,rax
     e90:	cmovl  rcx,QWORD PTR [rip+0x138]        # fd0 <botlish_fn_8+0x1b8>
     e98:	jmp    eb0 <botlish_fn_8+0x98>
     e9d:	mov    ecx,0x2
     ea2:	mov    rsi,r14
     ea5:	cmp    rsi,rdx
     ea8:	cmovl  rcx,QWORD PTR [rip+0x120]        # fd0 <botlish_fn_8+0x1b8>
     eb0:	cmp    rcx,0x6
     eb4:	je     ec8 <botlish_fn_8+0xb0>
     eba:	mov    rdx,rbx
     ebd:	mov    rsi,r12
     ec0:	mov    rdi,r13
     ec3:	jmp    f73 <botlish_fn_8+0x15b>
     ec8:	mov    rdx,r14
     ecb:	mov    rsi,r12
     ece:	mov    rdi,r13
     ed1:	call   ed6 <botlish_fn_8+0xbe>
			ed2: R_X86_64_PLT32	rt_str_char_at-0x4
     ed6:	test   rax,rax
     ed9:	je     f8a <botlish_fn_8+0x172>
     edf:	cmp    rax,0x164
     ee5:	jne    ef3 <botlish_fn_8+0xdb>
     eeb:	mov    rdx,rbx
     eee:	jmp    f6d <botlish_fn_8+0x155>
     ef3:	cmp    rax,0x54
     ef7:	jne    f05 <botlish_fn_8+0xed>
     efd:	mov    rdx,rbx
     f00:	jmp    f6d <botlish_fn_8+0x155>
     f05:	mov    QWORD PTR [rsp+0x18],0x3
     f0e:	mov    rsi,r14
     f11:	test   rsi,0x1
     f18:	je     f3b <botlish_fn_8+0x123>
     f1e:	mov    rsi,r14
     f21:	mov    rax,rsi
     f24:	add    rax,0x2
     f28:	seto   cl
     f2b:	test   cl,cl
     f2d:	jne    f3b <botlish_fn_8+0x123>
     f33:	mov    rsi,r12
     f36:	jmp    f4e <botlish_fn_8+0x136>
     f3b:	mov    edx,0x3
     f40:	mov    rsi,r14
     f43:	mov    rdi,r13
     f46:	call   f4b <botlish_fn_8+0x133>
			f47: R_X86_64_PLT32	rt_int_add-0x4
     f4b:	mov    rsi,r12
     f4e:	mov    rsi,r12
     f51:	mov    QWORD PTR [rsp],rsi
     f55:	mov    rdx,rbx
     f58:	mov    QWORD PTR [rsp+0x8],rdx
     f5d:	mov    QWORD PTR [rsp+0x10],rax
     f62:	mov    rsi,rax
     f65:	mov    rax,r12
     f68:	jmp    e5a <botlish_fn_8+0x42>
     f6d:	mov    rsi,r12
     f70:	mov    rdi,r13
     f73:	mov    rsi,r12
     f76:	mov    rdi,r13
     f79:	mov    rcx,r14
     f7c:	call   f81 <botlish_fn_8+0x169>
			f7d: R_X86_64_PLT32	rt_substr-0x4
     f81:	test   rax,rax
     f84:	jne    fad <botlish_fn_8+0x195>
     f8a:	xor    rdx,rdx
     f8d:	mov    rax,rdx
     f90:	mov    rbx,QWORD PTR [rsp+0x20]
     f95:	mov    r12,QWORD PTR [rsp+0x28]
     f9a:	mov    r13,QWORD PTR [rsp+0x30]
     f9f:	mov    r14,QWORD PTR [rsp+0x38]
     fa4:	add    rsp,0x40
     fa8:	mov    rsp,rbp
     fab:	pop    rbp
     fac:	ret
     fad:	mov    rdx,r14
     fb0:	mov    rbx,QWORD PTR [rsp+0x20]
     fb5:	mov    r12,QWORD PTR [rsp+0x28]
     fba:	mov    r13,QWORD PTR [rsp+0x30]
     fbf:	mov    r14,QWORD PTR [rsp+0x38]
     fc4:	add    rsp,0x40
     fc8:	mov    rsp,rbp
     fcb:	pop    rbp
     fcc:	ret
     fcd:	add    BYTE PTR [rax],al
     fcf:	add    BYTE PTR [rsi],al
     fd1:	add    BYTE PTR [rax],al
     fd3:	add    BYTE PTR [rax],al
     fd5:	add    BYTE PTR [rax],al
	...

0000000000000fd8 <botlish_entry_8: scan_unquoted<str, int, int>>:
     fd8:	push   rbp
     fd9:	mov    rbp,rsp
     fdc:	ud2

0000000000000fde <botlish_fn_9: scan_quoted<str, int, str>>:
     fde:	push   rbp
     fdf:	mov    rbp,rsp
     fe2:	sub    rsp,0xb0
     fe9:	mov    QWORD PTR [rsp+0x80],rbx
     ff1:	mov    QWORD PTR [rsp+0x88],r12
     ff9:	mov    QWORD PTR [rsp+0x90],r13
    1001:	mov    QWORD PTR [rsp+0x98],r14
    1009:	mov    QWORD PTR [rsp+0xa0],r15
    1011:	mov    r15,rdi
    1014:	mov    QWORD PTR [rsp+0x18],0x0
    101d:	mov    QWORD PTR [rsp+0x20],0x0
    1026:	mov    QWORD PTR [rsp],rsi
    102a:	mov    QWORD PTR [rsp+0x8],rdx
    102f:	mov    QWORD PTR [rsp+0x10],rcx
    1034:	mov    r13,rcx
    1037:	lea    r12,[rsp+0x58]
    103c:	mov    rbx,rsi
    103f:	mov    QWORD PTR [rsp+0x78],rdx
    1044:	mov    rdx,QWORD PTR [rsp+0x78]
    1049:	mov    rsi,rbx
    104c:	mov    rdi,r15
    104f:	call   1054 <botlish_fn_9+0x76>
			1050: R_X86_64_PLT32	botlish_fn_6-0x4 ; peek<str, int>
    1054:	test   rax,rax
    1057:	je     12f3 <botlish_fn_9+0x315>
    105d:	mov    QWORD PTR [rsp+0x18],rax
    1062:	mov    r14,rax
    1065:	mov    rdx,QWORD PTR [rsp+0x78]
    106a:	mov    rsi,rbx
    106d:	mov    rdi,r15
    1070:	call   1075 <botlish_fn_9+0x97>
			1071: R_X86_64_PLT32	botlish_fn_7-0x4 ; quote_at?<str, int>
    1075:	test   rax,rax
    1078:	je     12f3 <botlish_fn_9+0x315>
    107e:	cmp    rax,0x6
    1082:	je     113b <botlish_fn_9+0x15d>
    1088:	mov    QWORD PTR [rsp+0x20],0x3
    1091:	mov    rsi,QWORD PTR [rsp+0x78]
    1096:	test   rsi,0x1
    109d:	je     10c7 <botlish_fn_9+0xe9>
    10a3:	mov    rsi,QWORD PTR [rsp+0x78]
    10a8:	mov    rcx,rsi
    10ab:	add    rcx,0x2
    10af:	seto   dl
    10b2:	test   dl,dl
    10b4:	jne    10c7 <botlish_fn_9+0xe9>
    10ba:	mov    rsi,rcx
    10bd:	mov    QWORD PTR [rsp+0x78],rcx
    10c2:	jmp    10e1 <botlish_fn_9+0x103>
    10c7:	mov    edx,0x3
    10cc:	mov    rsi,QWORD PTR [rsp+0x78]
    10d1:	mov    rdi,r15
    10d4:	call   10d9 <botlish_fn_9+0xfb>
			10d5: R_X86_64_PLT32	rt_int_add-0x4
    10d9:	mov    rsi,rax
    10dc:	mov    QWORD PTR [rsp+0x78],rax
    10e1:	mov    QWORD PTR [rsp+0x8],rsi
    10e6:	mov    QWORD PTR [rsp+0x58],0x0
    10ef:	mov    QWORD PTR [rsp+0x60],r13
    10f4:	mov    QWORD PTR [rsp+0x68],0x0
    10fd:	mov    QWORD PTR [rsp+0x70],r14
    1102:	mov    esi,0x2
    1107:	mov    edx,0x4
    110c:	mov    rcx,r12
    110f:	mov    rdi,r15
    1112:	call   1117 <botlish_fn_9+0x139>
			1113: R_X86_64_PLT32	rt_construct-0x4
    1117:	test   rax,rax
    111a:	je     12f3 <botlish_fn_9+0x315>
    1120:	mov    QWORD PTR [rsp],rbx
    1124:	mov    rsi,QWORD PTR [rsp+0x78]
    1129:	mov    QWORD PTR [rsp+0x8],rsi
    112e:	mov    QWORD PTR [rsp+0x10],rax
    1133:	mov    r13,rax
    1136:	jmp    1044 <botlish_fn_9+0x66>
    113b:	mov    QWORD PTR [rsp+0x20],0x3
    1144:	mov    rsi,QWORD PTR [rsp+0x78]
    1149:	test   rsi,0x1
    1150:	je     116d <botlish_fn_9+0x18f>
    1156:	mov    rsi,QWORD PTR [rsp+0x78]
    115b:	mov    rdx,rsi
    115e:	add    rdx,0x2
    1162:	seto   al
    1165:	test   al,al
    1167:	je     1182 <botlish_fn_9+0x1a4>
    116d:	mov    edx,0x3
    1172:	mov    rsi,QWORD PTR [rsp+0x78]
    1177:	mov    rdi,r15
    117a:	call   117f <botlish_fn_9+0x1a1>
			117b: R_X86_64_PLT32	rt_int_add-0x4
    117f:	mov    rdx,rax
    1182:	mov    rsi,rbx
    1185:	mov    rdi,r15
    1188:	call   118d <botlish_fn_9+0x1af>
			1189: R_X86_64_PLT32	botlish_fn_7-0x4 ; quote_at?<str, int>
    118d:	test   rax,rax
    1190:	je     12f3 <botlish_fn_9+0x315>
    1196:	cmp    rax,0x6
    119a:	je     1259 <botlish_fn_9+0x27b>
    11a0:	xor    rsi,rsi
    11a3:	lea    rcx,[rsp+0x48]
    11a8:	mov    QWORD PTR [rsp+0x48],0x0
    11b1:	mov    QWORD PTR [rsp+0x50],r13
    11b6:	mov    edx,0x2
    11bb:	mov    rdi,r15
    11be:	call   11c3 <botlish_fn_9+0x1e5>
			11bf: R_X86_64_PLT32	rt_construct-0x4
    11c3:	test   rax,rax
    11c6:	je     12f3 <botlish_fn_9+0x315>
    11cc:	mov    QWORD PTR [rsp],rax
    11d0:	mov    r12,rax
    11d3:	mov    QWORD PTR [rsp+0x10],0x3
    11dc:	mov    rsi,QWORD PTR [rsp+0x78]
    11e1:	test   rsi,0x1
    11e8:	je     120d <botlish_fn_9+0x22f>
    11ee:	mov    rsi,QWORD PTR [rsp+0x78]
    11f3:	mov    rdx,rsi
    11f6:	add    rdx,0x2
    11fa:	seto   al
    11fd:	test   al,al
    11ff:	jne    120d <botlish_fn_9+0x22f>
    1205:	mov    rax,r12
    1208:	jmp    1225 <botlish_fn_9+0x247>
    120d:	mov    edx,0x3
    1212:	mov    rsi,QWORD PTR [rsp+0x78]
    1217:	mov    rdi,r15
    121a:	call   121f <botlish_fn_9+0x241>
			121b: R_X86_64_PLT32	rt_int_add-0x4
    121f:	mov    rdx,rax
    1222:	mov    rax,r12
    1225:	mov    rbx,QWORD PTR [rsp+0x80]
    122d:	mov    r12,QWORD PTR [rsp+0x88]
    1235:	mov    r13,QWORD PTR [rsp+0x90]
    123d:	mov    r14,QWORD PTR [rsp+0x98]
    1245:	mov    r15,QWORD PTR [rsp+0xa0]
    124d:	add    rsp,0xb0
    1254:	mov    rsp,rbp
    1257:	pop    rbp
    1258:	ret
    1259:	mov    QWORD PTR [rsp+0x20],0x5
    1262:	mov    rsi,QWORD PTR [rsp+0x78]
    1267:	test   rsi,0x1
    126e:	je     1298 <botlish_fn_9+0x2ba>
    1274:	mov    rsi,QWORD PTR [rsp+0x78]
    1279:	mov    rcx,rsi
    127c:	add    rcx,0x4
    1280:	seto   al
    1283:	test   al,al
    1285:	jne    1298 <botlish_fn_9+0x2ba>
    128b:	mov    rsi,rcx
    128e:	mov    QWORD PTR [rsp+0x78],rcx
    1293:	jmp    12b2 <botlish_fn_9+0x2d4>
    1298:	mov    edx,0x5
    129d:	mov    rsi,QWORD PTR [rsp+0x78]
    12a2:	mov    rdi,r15
    12a5:	call   12aa <botlish_fn_9+0x2cc>
			12a6: R_X86_64_PLT32	rt_int_add-0x4
    12aa:	mov    rsi,rax
    12ad:	mov    QWORD PTR [rsp+0x78],rax
    12b2:	mov    QWORD PTR [rsp+0x8],rsi
    12b7:	lea    rcx,[rsp+0x28]
    12bc:	mov    QWORD PTR [rsp+0x28],0x0
    12c5:	mov    QWORD PTR [rsp+0x30],r13
    12ca:	mov    QWORD PTR [rsp+0x38],0x0
    12d3:	mov    QWORD PTR [rsp+0x40],r14
    12d8:	mov    esi,0x2
    12dd:	mov    edx,0x4
    12e2:	mov    rdi,r15
    12e5:	call   12ea <botlish_fn_9+0x30c>
			12e6: R_X86_64_PLT32	rt_construct-0x4
    12ea:	test   rax,rax
    12ed:	jne    132d <botlish_fn_9+0x34f>
    12f3:	xor    rdx,rdx
    12f6:	mov    rax,rdx
    12f9:	mov    rbx,QWORD PTR [rsp+0x80]
    1301:	mov    r12,QWORD PTR [rsp+0x88]
    1309:	mov    r13,QWORD PTR [rsp+0x90]
    1311:	mov    r14,QWORD PTR [rsp+0x98]
    1319:	mov    r15,QWORD PTR [rsp+0xa0]
    1321:	add    rsp,0xb0
    1328:	mov    rsp,rbp
    132b:	pop    rbp
    132c:	ret
    132d:	mov    QWORD PTR [rsp],rbx
    1331:	mov    rsi,QWORD PTR [rsp+0x78]
    1336:	mov    QWORD PTR [rsp+0x8],rsi
    133b:	mov    QWORD PTR [rsp+0x10],rax
    1340:	mov    r13,rax
    1343:	jmp    1044 <botlish_fn_9+0x66>

0000000000001348 <botlish_entry_9: scan_quoted<str, int, str>>:
    1348:	push   rbp
    1349:	mov    rbp,rsp
    134c:	ud2

000000000000134e <botlish_fn_10: scan_field<str, int>>:
    134e:	push   rbp
    134f:	mov    rbp,rsp
    1352:	sub    rsp,0x40
    1356:	mov    QWORD PTR [rsp+0x20],rbx
    135b:	mov    QWORD PTR [rsp+0x28],r12
    1360:	mov    QWORD PTR [rsp+0x30],r13
    1365:	mov    r12,rdi
    1368:	mov    r13,rdx
    136b:	mov    QWORD PTR [rsp+0x10],0x0
    1374:	mov    QWORD PTR [rsp],rsi
    1378:	mov    rbx,rsi
    137b:	mov    QWORD PTR [rsp+0x8],rdx
    1380:	mov    rdx,r13
    1383:	mov    rsi,rbx
    1386:	mov    rdi,r12
    1389:	call   138e <botlish_fn_10+0x40>
			138a: R_X86_64_PLT32	botlish_fn_7-0x4 ; quote_at?<str, int>
    138e:	test   rax,rax
    1391:	je     1442 <botlish_fn_10+0xf4>
    1397:	cmp    rax,0x6
    139b:	je     13d3 <botlish_fn_10+0x85>
    13a1:	mov    rcx,r13
    13a4:	mov    rsi,rbx
    13a7:	mov    rdi,r12
    13aa:	mov    rdx,rcx
    13ad:	call   13b2 <botlish_fn_10+0x64>
			13ae: R_X86_64_PLT32	botlish_fn_8-0x4 ; scan_unquoted<str, int, int>
    13b2:	test   rax,rax
    13b5:	je     1442 <botlish_fn_10+0xf4>
    13bb:	mov    rbx,QWORD PTR [rsp+0x20]
    13c0:	mov    r12,QWORD PTR [rsp+0x28]
    13c5:	mov    r13,QWORD PTR [rsp+0x30]
    13ca:	add    rsp,0x40
    13ce:	mov    rsp,rbp
    13d1:	pop    rbp
    13d2:	ret
    13d3:	mov    rcx,r13
    13d6:	mov    QWORD PTR [rsp+0x10],0x3
    13df:	test   rcx,0x1
    13e6:	jne    13f4 <botlish_fn_10+0xa6>
    13ec:	mov    r13,rcx
    13ef:	jmp    1409 <botlish_fn_10+0xbb>
    13f4:	mov    rdx,rcx
    13f7:	add    rdx,0x2
    13fb:	mov    r13,rcx
    13fe:	seto   al
    1401:	test   al,al
    1403:	je     141c <botlish_fn_10+0xce>
    1409:	mov    edx,0x3
    140e:	mov    rsi,r13
    1411:	mov    rdi,r12
    1414:	call   1419 <botlish_fn_10+0xcb>
			1415: R_X86_64_PLT32	rt_int_add-0x4
    1419:	mov    rdx,rax
    141c:	mov    QWORD PTR [rsp+0x8],rdx
    1421:	mov    rdi,r12
    1424:	mov    rax,QWORD PTR [rdi+0x10]
    1428:	mov    rcx,QWORD PTR [rax+0x10]
    142c:	mov    QWORD PTR [rsp+0x10],rcx
    1431:	mov    rsi,rbx
    1434:	call   1439 <botlish_fn_10+0xeb>
			1435: R_X86_64_PLT32	botlish_fn_9-0x4 ; scan_quoted<str, int, str>
    1439:	test   rax,rax
    143c:	jne    1460 <botlish_fn_10+0x112>
    1442:	xor    rdx,rdx
    1445:	mov    rax,rdx
    1448:	mov    rbx,QWORD PTR [rsp+0x20]
    144d:	mov    r12,QWORD PTR [rsp+0x28]
    1452:	mov    r13,QWORD PTR [rsp+0x30]
    1457:	add    rsp,0x40
    145b:	mov    rsp,rbp
    145e:	pop    rbp
    145f:	ret
    1460:	mov    rbx,QWORD PTR [rsp+0x20]
    1465:	mov    r12,QWORD PTR [rsp+0x28]
    146a:	mov    r13,QWORD PTR [rsp+0x30]
    146f:	add    rsp,0x40
    1473:	mov    rsp,rbp
    1476:	pop    rbp
    1477:	ret

0000000000001478 <botlish_entry_10: scan_field<str, int>>:
    1478:	push   rbp
    1479:	mov    rbp,rsp
    147c:	ud2
	...

0000000000001480 <botlish_fn_11: scan_record<str, int, ChunkedBuilder>>:
    1480:	push   rbp
    1481:	mov    rbp,rsp
    1484:	sub    rsp,0x40
    1488:	mov    QWORD PTR [rsp+0x20],rbx
    148d:	mov    QWORD PTR [rsp+0x28],r12
    1492:	mov    QWORD PTR [rsp+0x30],r13
    1497:	mov    QWORD PTR [rsp+0x38],r14
    149c:	mov    r12,rdi
    149f:	mov    QWORD PTR [rsp+0x18],0x0
    14a8:	mov    QWORD PTR [rsp],rsi
    14ac:	mov    QWORD PTR [rsp+0x8],rdx
    14b1:	mov    QWORD PTR [rsp+0x10],rcx
    14b6:	mov    rbx,rsi
    14b9:	mov    r13,rcx
    14bc:	mov    rsi,rbx
    14bf:	mov    rdi,r12
    14c2:	call   14c7 <botlish_fn_11+0x47>
			14c3: R_X86_64_PLT32	botlish_fn_10-0x4 ; scan_field<str, int>
    14c7:	test   rax,rax
    14ca:	je     15dc <botlish_fn_11+0x15c>
    14d0:	mov    QWORD PTR [rsp+0x8],rax
    14d5:	mov    QWORD PTR [rsp+0x18],rdx
    14da:	mov    rsi,r13
    14dd:	mov    r13,rdx
    14e0:	mov    rdx,rax
    14e3:	mov    rdi,r12
    14e6:	call   14eb <botlish_fn_11+0x6b>
			14e7: R_X86_64_PLT32	botlish_fn_2-0x4 ; chunked_append<ChunkedBuilder, str>
    14eb:	test   rax,rax
    14ee:	je     15dc <botlish_fn_11+0x15c>
    14f4:	mov    QWORD PTR [rsp+0x8],rax
    14f9:	mov    r14,rax
    14fc:	mov    rdx,QWORD PTR [rbx+0x8]
    1500:	shl    rdx,1
    1503:	or     rdx,0x1
    1507:	mov    rsi,r13
    150a:	mov    rax,rsi
    150d:	and    rax,rdx
    1510:	test   rax,0x1
    1516:	jne    153c <botlish_fn_11+0xbc>
    151c:	mov    rsi,r13
    151f:	mov    rdi,r12
    1522:	call   1527 <botlish_fn_11+0xa7>
			1523: R_X86_64_PLT32	rt_int_cmp-0x4
    1527:	mov    ecx,0x2
    152c:	test   rax,rax
    152f:	cmovl  rcx,QWORD PTR [rip+0x199]        # 16d0 <botlish_fn_11+0x250>
    1537:	jmp    154f <botlish_fn_11+0xcf>
    153c:	mov    ecx,0x2
    1541:	mov    rax,r13
    1544:	cmp    rax,rdx
    1547:	cmovl  rcx,QWORD PTR [rip+0x181]        # 16d0 <botlish_fn_11+0x250>
    154f:	cmp    rcx,0x6
    1553:	je     1564 <botlish_fn_11+0xe4>
    1559:	mov    rsi,r14
    155c:	mov    rdi,r12
    155f:	jmp    1597 <botlish_fn_11+0x117>
    1564:	mov    rdx,r13
    1567:	mov    rsi,rbx
    156a:	mov    rdi,r12
    156d:	call   1572 <botlish_fn_11+0xf2>
			156e: R_X86_64_PLT32	rt_str_char_at-0x4
    1572:	test   rax,rax
    1575:	je     15dc <botlish_fn_11+0x15c>
    157b:	cmp    rax,0x164
    1581:	je     166c <botlish_fn_11+0x1ec>
    1587:	cmp    rax,0x54
    158b:	je     15c8 <botlish_fn_11+0x148>
    1591:	mov    rsi,r14
    1594:	mov    rdi,r12
    1597:	mov    rdi,r12
    159a:	call   159f <botlish_fn_11+0x11f>
			159b: R_X86_64_PLT32	botlish_fn_5-0x4 ; chunked_finish<ChunkedBuilder>
    159f:	test   rax,rax
    15a2:	je     15dc <botlish_fn_11+0x15c>
    15a8:	mov    rdx,r13
    15ab:	mov    rbx,QWORD PTR [rsp+0x20]
    15b0:	mov    r12,QWORD PTR [rsp+0x28]
    15b5:	mov    r13,QWORD PTR [rsp+0x30]
    15ba:	mov    r14,QWORD PTR [rsp+0x38]
    15bf:	add    rsp,0x40
    15c3:	mov    rsp,rbp
    15c6:	pop    rbp
    15c7:	ret
    15c8:	mov    rsi,r14
    15cb:	mov    rdi,r12
    15ce:	call   15d3 <botlish_fn_11+0x153>
			15cf: R_X86_64_PLT32	botlish_fn_5-0x4 ; chunked_finish<ChunkedBuilder>
    15d3:	test   rax,rax
    15d6:	jne    15ff <botlish_fn_11+0x17f>
    15dc:	xor    rdx,rdx
    15df:	mov    rax,rdx
    15e2:	mov    rbx,QWORD PTR [rsp+0x20]
    15e7:	mov    r12,QWORD PTR [rsp+0x28]
    15ec:	mov    r13,QWORD PTR [rsp+0x30]
    15f1:	mov    r14,QWORD PTR [rsp+0x38]
    15f6:	add    rsp,0x40
    15fa:	mov    rsp,rbp
    15fd:	pop    rbp
    15fe:	ret
    15ff:	mov    QWORD PTR [rsp],rax
    1603:	mov    rbx,rax
    1606:	mov    QWORD PTR [rsp+0x8],0x3
    160f:	mov    rdx,r13
    1612:	test   rdx,0x1
    1619:	je     1639 <botlish_fn_11+0x1b9>
    161f:	mov    rdx,r13
    1622:	add    rdx,0x2
    1626:	seto   al
    1629:	test   al,al
    162b:	jne    1639 <botlish_fn_11+0x1b9>
    1631:	mov    rax,rbx
    1634:	jmp    164f <botlish_fn_11+0x1cf>
    1639:	mov    edx,0x3
    163e:	mov    rsi,r13
    1641:	mov    rdi,r12
    1644:	call   1649 <botlish_fn_11+0x1c9>
			1645: R_X86_64_PLT32	rt_int_add-0x4
    1649:	mov    rdx,rax
    164c:	mov    rax,rbx
    164f:	mov    rbx,QWORD PTR [rsp+0x20]
    1654:	mov    r12,QWORD PTR [rsp+0x28]
    1659:	mov    r13,QWORD PTR [rsp+0x30]
    165e:	mov    r14,QWORD PTR [rsp+0x38]
    1663:	add    rsp,0x40
    1667:	mov    rsp,rbp
    166a:	pop    rbp
    166b:	ret
    166c:	mov    rsi,r13
    166f:	mov    edx,0x3
    1674:	mov    rcx,rdx
    1677:	mov    QWORD PTR [rsp+0x10],0x3
    1680:	test   rsi,0x1
    1687:	jne    1695 <botlish_fn_11+0x215>
    168d:	mov    rdx,rcx
    1690:	jmp    16aa <botlish_fn_11+0x22a>
    1695:	mov    rdx,rsi
    1698:	add    rdx,0x2
    169c:	seto   al
    169f:	test   al,al
    16a1:	je     16b5 <botlish_fn_11+0x235>
    16a7:	mov    rdx,rcx
    16aa:	mov    rdi,r12
    16ad:	call   16b2 <botlish_fn_11+0x232>
			16ae: R_X86_64_PLT32	rt_int_add-0x4
    16b2:	mov    rdx,rax
    16b5:	mov    QWORD PTR [rsp],rbx
    16b9:	mov    QWORD PTR [rsp+0x8],rdx
    16be:	mov    rsi,r14
    16c1:	mov    QWORD PTR [rsp+0x10],rsi
    16c6:	mov    r13,rsi
    16c9:	jmp    14bc <botlish_fn_11+0x3c>
    16ce:	add    BYTE PTR [rax],al
    16d0:	(bad)
    16d1:	add    BYTE PTR [rax],al
    16d3:	add    BYTE PTR [rax],al
    16d5:	add    BYTE PTR [rax],al
	...

00000000000016d8 <botlish_entry_11: scan_record<str, int, ChunkedBuilder>>:
    16d8:	push   rbp
    16d9:	mov    rbp,rsp
    16dc:	ud2
	...

00000000000016e0 <botlish_fn_12: scan_records<str, int, ChunkedBuilder>>:
    16e0:	push   rbp
    16e1:	mov    rbp,rsp
    16e4:	sub    rsp,0x40
    16e8:	mov    QWORD PTR [rsp+0x20],rbx
    16ed:	mov    QWORD PTR [rsp+0x28],r12
    16f2:	mov    QWORD PTR [rsp+0x30],r13
    16f7:	mov    QWORD PTR [rsp+0x38],r14
    16fc:	mov    r13,rdi
    16ff:	mov    QWORD PTR [rsp+0x18],0x0
    1708:	mov    QWORD PTR [rsp],rsi
    170c:	mov    QWORD PTR [rsp+0x8],rdx
    1711:	mov    r12,rdx
    1714:	mov    QWORD PTR [rsp+0x10],rcx
    1719:	mov    rbx,rsi
    171c:	mov    r14,rcx
    171f:	mov    rdx,QWORD PTR [rbx+0x8]
    1723:	shl    rdx,1
    1726:	or     rdx,0x1
    172a:	mov    rax,r12
    172d:	and    rax,rdx
    1730:	test   rax,0x1
    1736:	jne    175c <botlish_fn_12+0x7c>
    173c:	mov    rsi,r12
    173f:	mov    rdi,r13
    1742:	call   1747 <botlish_fn_12+0x67>
			1743: R_X86_64_PLT32	rt_int_cmp-0x4
    1747:	mov    ecx,0x2
    174c:	test   rax,rax
    174f:	cmovge rcx,QWORD PTR [rip+0xe1]        # 1838 <botlish_fn_12+0x158>
    1757:	jmp    176f <botlish_fn_12+0x8f>
    175c:	mov    ecx,0x2
    1761:	mov    rax,r12
    1764:	cmp    rax,rdx
    1767:	cmovge rcx,QWORD PTR [rip+0xc9]        # 1838 <botlish_fn_12+0x158>
    176f:	cmp    rcx,0x6
    1773:	je     17e6 <botlish_fn_12+0x106>
    1779:	mov    rdi,r13
    177c:	call   1781 <botlish_fn_12+0xa1>
			177d: R_X86_64_PLT32	botlish_fn_1-0x4 ; chunked_new<generic>
    1781:	test   rax,rax
    1784:	je     17fa <botlish_fn_12+0x11a>
    178a:	mov    QWORD PTR [rsp+0x18],rax
    178f:	mov    rcx,rax
    1792:	mov    rdx,r12
    1795:	mov    rsi,rbx
    1798:	mov    rdi,r13
    179b:	call   17a0 <botlish_fn_12+0xc0>
			179c: R_X86_64_PLT32	botlish_fn_11-0x4 ; scan_record<str, int, ChunkedBuilder>
    17a0:	test   rax,rax
    17a3:	je     17fa <botlish_fn_12+0x11a>
    17a9:	mov    QWORD PTR [rsp+0x8],rax
    17ae:	mov    QWORD PTR [rsp+0x18],rdx
    17b3:	mov    r12,rdx
    17b6:	mov    rsi,r14
    17b9:	mov    rdx,rax
    17bc:	mov    rdi,r13
    17bf:	call   17c4 <botlish_fn_12+0xe4>
			17c0: R_X86_64_PLT32	botlish_fn_3-0x4 ; chunked_append<ChunkedBuilder, list>
    17c4:	test   rax,rax
    17c7:	je     17fa <botlish_fn_12+0x11a>
    17cd:	mov    QWORD PTR [rsp],rbx
    17d1:	mov    rdx,r12
    17d4:	mov    QWORD PTR [rsp+0x8],rdx
    17d9:	mov    QWORD PTR [rsp+0x10],rax
    17de:	mov    r14,rax
    17e1:	jmp    171f <botlish_fn_12+0x3f>
    17e6:	mov    rsi,r14
    17e9:	mov    rdi,r13
    17ec:	call   17f1 <botlish_fn_12+0x111>
			17ed: R_X86_64_PLT32	botlish_fn_5-0x4 ; chunked_finish<ChunkedBuilder>
    17f1:	test   rax,rax
    17f4:	jne    181a <botlish_fn_12+0x13a>
    17fa:	xor    rax,rax
    17fd:	mov    rbx,QWORD PTR [rsp+0x20]
    1802:	mov    r12,QWORD PTR [rsp+0x28]
    1807:	mov    r13,QWORD PTR [rsp+0x30]
    180c:	mov    r14,QWORD PTR [rsp+0x38]
    1811:	add    rsp,0x40
    1815:	mov    rsp,rbp
    1818:	pop    rbp
    1819:	ret
    181a:	mov    rbx,QWORD PTR [rsp+0x20]
    181f:	mov    r12,QWORD PTR [rsp+0x28]
    1824:	mov    r13,QWORD PTR [rsp+0x30]
    1829:	mov    r14,QWORD PTR [rsp+0x38]
    182e:	add    rsp,0x40
    1832:	mov    rsp,rbp
    1835:	pop    rbp
    1836:	ret
    1837:	add    BYTE PTR [rsi],al
    1839:	add    BYTE PTR [rax],al
    183b:	add    BYTE PTR [rax],al
    183d:	add    BYTE PTR [rax],al
	...

0000000000001840 <botlish_entry_12: scan_records<str, int, ChunkedBuilder>>:
    1840:	push   rbp
    1841:	mov    rbp,rsp
    1844:	mov    rsi,QWORD PTR [rdx]
    1847:	mov    r8,QWORD PTR [rdx+0x8]
    184b:	mov    rcx,QWORD PTR [rdx+0x10]
    184f:	mov    rdx,r8
    1852:	call   1857 <botlish_entry_12+0x17>
			1853: R_X86_64_PLT32	botlish_fn_12-0x4 ; scan_records<str, int, ChunkedBuilder>
    1857:	mov    rsp,rbp
    185a:	pop    rbp
    185b:	ret

000000000000185c <botlish_fn_13: csv_parse<str>>:
    185c:	push   rbp
    185d:	mov    rbp,rsp
    1860:	sub    rsp,0x30
    1864:	mov    QWORD PTR [rsp+0x20],r12
    1869:	mov    QWORD PTR [rsp+0x28],r13
    186e:	mov    r13,rdi
    1871:	mov    QWORD PTR [rsp+0x10],0x0
    187a:	mov    QWORD PTR [rsp],rsi
    187e:	mov    r12,rsi
    1881:	mov    QWORD PTR [rsp+0x8],0x1
    188a:	mov    rdi,r13
    188d:	call   1892 <botlish_fn_13+0x36>
			188e: R_X86_64_PLT32	botlish_fn_1-0x4 ; chunked_new<generic>
    1892:	test   rax,rax
    1895:	je     18bc <botlish_fn_13+0x60>
    189b:	mov    QWORD PTR [rsp+0x10],rax
    18a0:	mov    rcx,rax
    18a3:	mov    edx,0x1
    18a8:	mov    rsi,r12
    18ab:	mov    rdi,r13
    18ae:	call   18b3 <botlish_fn_13+0x57>
			18af: R_X86_64_PLT32	botlish_fn_12-0x4 ; scan_records<str, int, ChunkedBuilder>
    18b3:	test   rax,rax
    18b6:	jne    18d2 <botlish_fn_13+0x76>
    18bc:	xor    rax,rax
    18bf:	mov    r12,QWORD PTR [rsp+0x20]
    18c4:	mov    r13,QWORD PTR [rsp+0x28]
    18c9:	add    rsp,0x30
    18cd:	mov    rsp,rbp
    18d0:	pop    rbp
    18d1:	ret
    18d2:	mov    r12,QWORD PTR [rsp+0x20]
    18d7:	mov    r13,QWORD PTR [rsp+0x28]
    18dc:	add    rsp,0x30
    18e0:	mov    rsp,rbp
    18e3:	pop    rbp
    18e4:	ret

00000000000018e5 <botlish_entry_13: csv_parse<str>>:
    18e5:	push   rbp
    18e6:	mov    rbp,rsp
    18e9:	mov    rsi,QWORD PTR [rdx]
    18ec:	call   18f1 <botlish_entry_13+0xc>
			18ed: R_X86_64_PLT32	botlish_fn_13-0x4 ; csv_parse<str>
    18f1:	mov    rsp,rbp
    18f4:	pop    rbp
    18f5:	ret
