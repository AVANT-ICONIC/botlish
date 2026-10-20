; source:  examples/stdlib/csv_chunked.bot
; backend: Cranelift (specialize=1), native::object
; object:  ELF64 x86-64, unlinked (Botlish-generated code only; runtime
;          helpers are unresolved imports, so their bodies are not present)
; format:  objdump -dr --no-show-raw-insn -M intel
; total machine code bytes: 7445  (per function: 312 315 1037 1037 504 681 365 309 470 932 311 630 388 154)
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
     239:	mov    r12,rdi
     23c:	mov    QWORD PTR [rsp+0x18],0x0
     245:	mov    QWORD PTR [rsp+0x20],0x0
     24e:	mov    QWORD PTR [rsp],rsi
     252:	mov    QWORD PTR [rsp+0x8],rdx
     257:	mov    r14,rdx
     25a:	mov    rax,QWORD PTR [rsi+0x18]
     25e:	mov    rbx,rsi
     261:	mov    rsi,QWORD PTR [rax+0x10]
     265:	mov    rax,QWORD PTR [rsi+0x8]
     269:	test   rax,rax
     26c:	jne    27f <botlish_fn_2+0x67>
     272:	jmp    528 <botlish_fn_2+0x310>
     277:	mov    rsi,rax
     27a:	jmp    286 <botlish_fn_2+0x6e>
     27f:	mov    rsi,QWORD PTR [rsi+0x10]
     283:	mov    rsi,QWORD PTR [rsi]
     286:	mov    QWORD PTR [rsp+0x10],rsi
     28b:	mov    edx,0x1
     290:	mov    r13,rdx
     293:	test   rsi,0x1
     29a:	mov    r15,rsi
     29d:	jne    2c8 <botlish_fn_2+0xb0>
     2a3:	mov    edx,0x81
     2a8:	mov    rsi,r15
     2ab:	mov    rdi,r12
     2ae:	call   2b3 <botlish_fn_2+0x9b>
			2af: R_X86_64_PLT32	rt_int_cmp-0x4
     2b3:	mov    ecx,0x2
     2b8:	test   rax,rax
     2bb:	cmove  rcx,QWORD PTR [rip+0x2fd]        # 5c0 <botlish_fn_2+0x3a8>
     2c3:	jmp    2df <botlish_fn_2+0xc7>
     2c8:	mov    ecx,0x2
     2cd:	mov    rsi,r15
     2d0:	cmp    rsi,0x81
     2d7:	cmove  rcx,QWORD PTR [rip+0x2e1]        # 5c0 <botlish_fn_2+0x3a8>
     2df:	cmp    rcx,0x6
     2e3:	je     3e6 <botlish_fn_2+0x1ce>
     2e9:	mov    rcx,QWORD PTR [rbx+0x18]
     2ed:	mov    rsi,QWORD PTR [rcx+0x8]
     2f1:	mov    rax,r15
     2f4:	test   rax,0x1
     2fa:	je     543 <botlish_fn_2+0x32b>
     300:	mov    rdx,QWORD PTR [rsi+0x8]
     304:	mov    rax,r15
     307:	mov    rdi,rax
     30a:	sar    rdi,1
     30d:	cmp    rdi,rdx
     310:	jae    54b <botlish_fn_2+0x333>
     316:	mov    rcx,QWORD PTR [rsi+0x18]
     31a:	test   rcx,rcx
     31d:	je     553 <botlish_fn_2+0x33b>
     323:	mov    rcx,r14
     326:	mov    rax,QWORD PTR [rsi+0x10]
     32a:	mov    QWORD PTR [rax+rdi*8],rcx
     32e:	mov    rax,QWORD PTR [rbx+0x18]
     332:	mov    rsi,QWORD PTR [rax+0x10]
     336:	mov    QWORD PTR [rsp+0x8],rsi
     33b:	mov    r14,rsi
     33e:	mov    QWORD PTR [rsp+0x18],0x1
     347:	mov    edx,0x3
     34c:	mov    QWORD PTR [rsp+0x20],0x3
     355:	mov    rsi,r15
     358:	test   rsi,0x1
     35f:	jne    36d <botlish_fn_2+0x155>
     365:	mov    rsi,r15
     368:	jmp    385 <botlish_fn_2+0x16d>
     36d:	mov    rsi,r15
     370:	mov    rcx,rsi
     373:	add    rcx,0x2
     377:	seto   al
     37a:	test   al,al
     37c:	je     390 <botlish_fn_2+0x178>
     382:	mov    rsi,r15
     385:	mov    rdi,r12
     388:	call   38d <botlish_fn_2+0x175>
			389: R_X86_64_PLT32	rt_int_add-0x4
     38d:	mov    rcx,rax
     390:	mov    rsi,r14
     393:	mov    rax,QWORD PTR [rsi+0x8]
     397:	test   rax,rax
     39a:	je     56f <botlish_fn_2+0x357>
     3a0:	mov    rax,QWORD PTR [rsi+0x18]
     3a4:	test   rax,rax
     3a7:	jne    3ba <botlish_fn_2+0x1a2>
     3ad:	jmp    57a <botlish_fn_2+0x362>
     3b2:	mov    rax,rbx
     3b5:	jmp    3c4 <botlish_fn_2+0x1ac>
     3ba:	mov    rax,QWORD PTR [rsi+0x10]
     3be:	mov    QWORD PTR [rax],rcx
     3c1:	mov    rax,rbx
     3c4:	mov    rbx,QWORD PTR [rsp+0x40]
     3c9:	mov    r12,QWORD PTR [rsp+0x48]
     3ce:	mov    r13,QWORD PTR [rsp+0x50]
     3d3:	mov    r14,QWORD PTR [rsp+0x58]
     3d8:	mov    r15,QWORD PTR [rsp+0x60]
     3dd:	add    rsp,0x70
     3e1:	mov    rsp,rbp
     3e4:	pop    rbp
     3e5:	ret
     3e6:	mov    esi,0x81
     3eb:	mov    QWORD PTR [rsp+0x10],0x81
     3f4:	mov    rdi,r12
     3f7:	call   3fc <botlish_fn_2+0x1e4>
			3f8: R_X86_64_PLT32	rt_mutarray_allocate-0x4
     3fc:	mov    rsi,rax
     3ff:	mov    r15,rax
     402:	test   rax,rsi
     405:	je     4b4 <botlish_fn_2+0x29c>
     40b:	mov    rax,r15
     40e:	mov    QWORD PTR [rsp+0x10],rax
     413:	mov    rax,r15
     416:	mov    rcx,QWORD PTR [rax+0x8]
     41a:	test   rcx,rcx
     41d:	je     596 <botlish_fn_2+0x37e>
     423:	mov    rax,r15
     426:	mov    rsi,QWORD PTR [rax+0x18]
     42a:	test   rsi,rsi
     42d:	jne    440 <botlish_fn_2+0x228>
     433:	jmp    5a1 <botlish_fn_2+0x389>
     438:	mov    rax,rbx
     43b:	jmp    450 <botlish_fn_2+0x238>
     440:	mov    rax,r15
     443:	mov    rcx,r14
     446:	mov    r10,QWORD PTR [rax+0x10]
     44a:	mov    QWORD PTR [r10],rcx
     44d:	mov    rax,rbx
     450:	mov    rax,rbx
     453:	mov    rax,QWORD PTR [rax+0x18]
     457:	mov    rsi,QWORD PTR [rax]
     45a:	mov    QWORD PTR [rsp+0x8],rsi
     45f:	mov    rax,rbx
     462:	mov    rax,QWORD PTR [rax+0x18]
     466:	mov    rdx,QWORD PTR [rax+0x8]
     46a:	mov    QWORD PTR [rsp],rdx
     46e:	mov    rdi,r12
     471:	call   476 <botlish_fn_2+0x25e>
			472: R_X86_64_PLT32	rt_list_append-0x4
     476:	test   rax,rax
     479:	je     4b4 <botlish_fn_2+0x29c>
     47f:	mov    QWORD PTR [rsp],rax
     483:	mov    r13,rax
     486:	mov    edx,0x3
     48b:	mov    rbx,rdx
     48e:	mov    QWORD PTR [rsp+0x8],0x3
     497:	mov    QWORD PTR [rsp+0x18],0x3
     4a0:	mov    rsi,rbx
     4a3:	mov    rdi,r12
     4a6:	call   4ab <botlish_fn_2+0x293>
			4a7: R_X86_64_PLT32	rt_mutarray_create-0x4
     4ab:	test   rax,rax
     4ae:	jne    4d9 <botlish_fn_2+0x2c1>
     4b4:	xor    rax,rax
     4b7:	mov    rbx,QWORD PTR [rsp+0x40]
     4bc:	mov    r12,QWORD PTR [rsp+0x48]
     4c1:	mov    r13,QWORD PTR [rsp+0x50]
     4c6:	mov    r14,QWORD PTR [rsp+0x58]
     4cb:	mov    r15,QWORD PTR [rsp+0x60]
     4d0:	add    rsp,0x70
     4d4:	mov    rsp,rbp
     4d7:	pop    rbp
     4d8:	ret
     4d9:	mov    QWORD PTR [rsp+0x8],rax
     4de:	lea    rcx,[rsp+0x28]
     4e3:	mov    rdx,r13
     4e6:	mov    QWORD PTR [rsp+0x28],rdx
     4eb:	mov    rdx,r15
     4ee:	mov    QWORD PTR [rsp+0x30],rdx
     4f3:	mov    QWORD PTR [rsp+0x38],rax
     4f8:	xor    rsi,rsi
     4fb:	mov    rdx,rbx
     4fe:	mov    rdi,r12
     501:	call   506 <botlish_fn_2+0x2ee>
			502: R_X86_64_PLT32	rt_struct_new-0x4
     506:	mov    rbx,QWORD PTR [rsp+0x40]
     50b:	mov    r12,QWORD PTR [rsp+0x48]
     510:	mov    r13,QWORD PTR [rsp+0x50]
     515:	mov    r14,QWORD PTR [rsp+0x58]
     51a:	mov    r15,QWORD PTR [rsp+0x60]
     51f:	add    rsp,0x70
     523:	mov    rsp,rbp
     526:	pop    rbp
     527:	ret
     528:	mov    edx,0x1
     52d:	mov    rdi,r12
     530:	call   535 <botlish_fn_2+0x31d>
			531: R_X86_64_PLT32	rt_mutarray_get-0x4
     535:	test   rax,rax
     538:	jne    277 <botlish_fn_2+0x5f>
     53e:	jmp    4b4 <botlish_fn_2+0x29c>
     543:	mov    rcx,r14
     546:	jmp    556 <botlish_fn_2+0x33e>
     54b:	mov    rcx,r14
     54e:	jmp    556 <botlish_fn_2+0x33e>
     553:	mov    rcx,r14
     556:	mov    rdx,r15
     559:	mov    rdi,r12
     55c:	call   561 <botlish_fn_2+0x349>
			55d: R_X86_64_PLT32	rt_mutarray_set-0x4
     561:	test   rax,rax
     564:	jne    32e <botlish_fn_2+0x116>
     56a:	jmp    4b4 <botlish_fn_2+0x29c>
     56f:	mov    rdx,r13
     572:	mov    rdi,r12
     575:	jmp    580 <botlish_fn_2+0x368>
     57a:	mov    rdx,r13
     57d:	mov    rdi,r12
     580:	mov    rdi,r12
     583:	call   588 <botlish_fn_2+0x370>
			584: R_X86_64_PLT32	rt_mutarray_set-0x4
     588:	test   rax,rax
     58b:	jne    3b2 <botlish_fn_2+0x19a>
     591:	jmp    4b4 <botlish_fn_2+0x29c>
     596:	mov    rcx,r14
     599:	mov    rdx,r13
     59c:	jmp    5a7 <botlish_fn_2+0x38f>
     5a1:	mov    rcx,r14
     5a4:	mov    rdx,r13
     5a7:	mov    rsi,r15
     5aa:	mov    rdi,r12
     5ad:	call   5b2 <botlish_fn_2+0x39a>
			5ae: R_X86_64_PLT32	rt_mutarray_set-0x4
     5b2:	test   rax,rax
     5b5:	jne    438 <botlish_fn_2+0x220>
     5bb:	jmp    4b4 <botlish_fn_2+0x29c>
     5c0:	(bad)
     5c1:	add    BYTE PTR [rax],al
     5c3:	add    BYTE PTR [rax],al
     5c5:	add    BYTE PTR [rax],al
	...

00000000000005c8 <botlish_entry_2: chunked_append<ChunkedBuilder, str>>:
     5c8:	push   rbp
     5c9:	mov    rbp,rsp
     5cc:	mov    rsi,QWORD PTR [rdx]
     5cf:	mov    rdx,QWORD PTR [rdx+0x8]
     5d3:	call   5d8 <botlish_entry_2+0x10>
			5d4: R_X86_64_PLT32	botlish_fn_2-0x4 ; chunked_append<ChunkedBuilder, str>
     5d8:	mov    rsp,rbp
     5db:	pop    rbp
     5dc:	ret
     5dd:	add    BYTE PTR [rax],al
	...

00000000000005e0 <botlish_fn_3: chunked_append<ChunkedBuilder, list>>:
     5e0:	push   rbp
     5e1:	mov    rbp,rsp
     5e4:	sub    rsp,0x70
     5e8:	mov    QWORD PTR [rsp+0x40],rbx
     5ed:	mov    QWORD PTR [rsp+0x48],r12
     5f2:	mov    QWORD PTR [rsp+0x50],r13
     5f7:	mov    QWORD PTR [rsp+0x58],r14
     5fc:	mov    QWORD PTR [rsp+0x60],r15
     601:	mov    r12,rdi
     604:	mov    QWORD PTR [rsp+0x18],0x0
     60d:	mov    QWORD PTR [rsp+0x20],0x0
     616:	mov    QWORD PTR [rsp],rsi
     61a:	mov    QWORD PTR [rsp+0x8],rdx
     61f:	mov    r14,rdx
     622:	mov    rax,QWORD PTR [rsi+0x18]
     626:	mov    rbx,rsi
     629:	mov    rsi,QWORD PTR [rax+0x10]
     62d:	mov    rax,QWORD PTR [rsi+0x8]
     631:	test   rax,rax
     634:	jne    647 <botlish_fn_3+0x67>
     63a:	jmp    8f0 <botlish_fn_3+0x310>
     63f:	mov    rsi,rax
     642:	jmp    64e <botlish_fn_3+0x6e>
     647:	mov    rsi,QWORD PTR [rsi+0x10]
     64b:	mov    rsi,QWORD PTR [rsi]
     64e:	mov    QWORD PTR [rsp+0x10],rsi
     653:	mov    edx,0x1
     658:	mov    r13,rdx
     65b:	test   rsi,0x1
     662:	mov    r15,rsi
     665:	jne    690 <botlish_fn_3+0xb0>
     66b:	mov    edx,0x81
     670:	mov    rsi,r15
     673:	mov    rdi,r12
     676:	call   67b <botlish_fn_3+0x9b>
			677: R_X86_64_PLT32	rt_int_cmp-0x4
     67b:	mov    ecx,0x2
     680:	test   rax,rax
     683:	cmove  rcx,QWORD PTR [rip+0x2fd]        # 988 <botlish_fn_3+0x3a8>
     68b:	jmp    6a7 <botlish_fn_3+0xc7>
     690:	mov    ecx,0x2
     695:	mov    rsi,r15
     698:	cmp    rsi,0x81
     69f:	cmove  rcx,QWORD PTR [rip+0x2e1]        # 988 <botlish_fn_3+0x3a8>
     6a7:	cmp    rcx,0x6
     6ab:	je     7ae <botlish_fn_3+0x1ce>
     6b1:	mov    rcx,QWORD PTR [rbx+0x18]
     6b5:	mov    rsi,QWORD PTR [rcx+0x8]
     6b9:	mov    rax,r15
     6bc:	test   rax,0x1
     6c2:	je     90b <botlish_fn_3+0x32b>
     6c8:	mov    rdx,QWORD PTR [rsi+0x8]
     6cc:	mov    rax,r15
     6cf:	mov    rdi,rax
     6d2:	sar    rdi,1
     6d5:	cmp    rdi,rdx
     6d8:	jae    913 <botlish_fn_3+0x333>
     6de:	mov    rcx,QWORD PTR [rsi+0x18]
     6e2:	test   rcx,rcx
     6e5:	je     91b <botlish_fn_3+0x33b>
     6eb:	mov    rcx,r14
     6ee:	mov    rax,QWORD PTR [rsi+0x10]
     6f2:	mov    QWORD PTR [rax+rdi*8],rcx
     6f6:	mov    rax,QWORD PTR [rbx+0x18]
     6fa:	mov    rsi,QWORD PTR [rax+0x10]
     6fe:	mov    QWORD PTR [rsp+0x8],rsi
     703:	mov    r14,rsi
     706:	mov    QWORD PTR [rsp+0x18],0x1
     70f:	mov    edx,0x3
     714:	mov    QWORD PTR [rsp+0x20],0x3
     71d:	mov    rsi,r15
     720:	test   rsi,0x1
     727:	jne    735 <botlish_fn_3+0x155>
     72d:	mov    rsi,r15
     730:	jmp    74d <botlish_fn_3+0x16d>
     735:	mov    rsi,r15
     738:	mov    rcx,rsi
     73b:	add    rcx,0x2
     73f:	seto   al
     742:	test   al,al
     744:	je     758 <botlish_fn_3+0x178>
     74a:	mov    rsi,r15
     74d:	mov    rdi,r12
     750:	call   755 <botlish_fn_3+0x175>
			751: R_X86_64_PLT32	rt_int_add-0x4
     755:	mov    rcx,rax
     758:	mov    rsi,r14
     75b:	mov    rax,QWORD PTR [rsi+0x8]
     75f:	test   rax,rax
     762:	je     937 <botlish_fn_3+0x357>
     768:	mov    rax,QWORD PTR [rsi+0x18]
     76c:	test   rax,rax
     76f:	jne    782 <botlish_fn_3+0x1a2>
     775:	jmp    942 <botlish_fn_3+0x362>
     77a:	mov    rax,rbx
     77d:	jmp    78c <botlish_fn_3+0x1ac>
     782:	mov    rax,QWORD PTR [rsi+0x10]
     786:	mov    QWORD PTR [rax],rcx
     789:	mov    rax,rbx
     78c:	mov    rbx,QWORD PTR [rsp+0x40]
     791:	mov    r12,QWORD PTR [rsp+0x48]
     796:	mov    r13,QWORD PTR [rsp+0x50]
     79b:	mov    r14,QWORD PTR [rsp+0x58]
     7a0:	mov    r15,QWORD PTR [rsp+0x60]
     7a5:	add    rsp,0x70
     7a9:	mov    rsp,rbp
     7ac:	pop    rbp
     7ad:	ret
     7ae:	mov    esi,0x81
     7b3:	mov    QWORD PTR [rsp+0x10],0x81
     7bc:	mov    rdi,r12
     7bf:	call   7c4 <botlish_fn_3+0x1e4>
			7c0: R_X86_64_PLT32	rt_mutarray_allocate-0x4
     7c4:	mov    rsi,rax
     7c7:	mov    r15,rax
     7ca:	test   rax,rsi
     7cd:	je     87c <botlish_fn_3+0x29c>
     7d3:	mov    rax,r15
     7d6:	mov    QWORD PTR [rsp+0x10],rax
     7db:	mov    rax,r15
     7de:	mov    rcx,QWORD PTR [rax+0x8]
     7e2:	test   rcx,rcx
     7e5:	je     95e <botlish_fn_3+0x37e>
     7eb:	mov    rax,r15
     7ee:	mov    rsi,QWORD PTR [rax+0x18]
     7f2:	test   rsi,rsi
     7f5:	jne    808 <botlish_fn_3+0x228>
     7fb:	jmp    969 <botlish_fn_3+0x389>
     800:	mov    rax,rbx
     803:	jmp    818 <botlish_fn_3+0x238>
     808:	mov    rax,r15
     80b:	mov    rcx,r14
     80e:	mov    r10,QWORD PTR [rax+0x10]
     812:	mov    QWORD PTR [r10],rcx
     815:	mov    rax,rbx
     818:	mov    rax,rbx
     81b:	mov    rax,QWORD PTR [rax+0x18]
     81f:	mov    rsi,QWORD PTR [rax]
     822:	mov    QWORD PTR [rsp+0x8],rsi
     827:	mov    rax,rbx
     82a:	mov    rax,QWORD PTR [rax+0x18]
     82e:	mov    rdx,QWORD PTR [rax+0x8]
     832:	mov    QWORD PTR [rsp],rdx
     836:	mov    rdi,r12
     839:	call   83e <botlish_fn_3+0x25e>
			83a: R_X86_64_PLT32	rt_list_append-0x4
     83e:	test   rax,rax
     841:	je     87c <botlish_fn_3+0x29c>
     847:	mov    QWORD PTR [rsp],rax
     84b:	mov    r13,rax
     84e:	mov    edx,0x3
     853:	mov    rbx,rdx
     856:	mov    QWORD PTR [rsp+0x8],0x3
     85f:	mov    QWORD PTR [rsp+0x18],0x3
     868:	mov    rsi,rbx
     86b:	mov    rdi,r12
     86e:	call   873 <botlish_fn_3+0x293>
			86f: R_X86_64_PLT32	rt_mutarray_create-0x4
     873:	test   rax,rax
     876:	jne    8a1 <botlish_fn_3+0x2c1>
     87c:	xor    rax,rax
     87f:	mov    rbx,QWORD PTR [rsp+0x40]
     884:	mov    r12,QWORD PTR [rsp+0x48]
     889:	mov    r13,QWORD PTR [rsp+0x50]
     88e:	mov    r14,QWORD PTR [rsp+0x58]
     893:	mov    r15,QWORD PTR [rsp+0x60]
     898:	add    rsp,0x70
     89c:	mov    rsp,rbp
     89f:	pop    rbp
     8a0:	ret
     8a1:	mov    QWORD PTR [rsp+0x8],rax
     8a6:	lea    rcx,[rsp+0x28]
     8ab:	mov    rdx,r13
     8ae:	mov    QWORD PTR [rsp+0x28],rdx
     8b3:	mov    rdx,r15
     8b6:	mov    QWORD PTR [rsp+0x30],rdx
     8bb:	mov    QWORD PTR [rsp+0x38],rax
     8c0:	xor    rsi,rsi
     8c3:	mov    rdx,rbx
     8c6:	mov    rdi,r12
     8c9:	call   8ce <botlish_fn_3+0x2ee>
			8ca: R_X86_64_PLT32	rt_struct_new-0x4
     8ce:	mov    rbx,QWORD PTR [rsp+0x40]
     8d3:	mov    r12,QWORD PTR [rsp+0x48]
     8d8:	mov    r13,QWORD PTR [rsp+0x50]
     8dd:	mov    r14,QWORD PTR [rsp+0x58]
     8e2:	mov    r15,QWORD PTR [rsp+0x60]
     8e7:	add    rsp,0x70
     8eb:	mov    rsp,rbp
     8ee:	pop    rbp
     8ef:	ret
     8f0:	mov    edx,0x1
     8f5:	mov    rdi,r12
     8f8:	call   8fd <botlish_fn_3+0x31d>
			8f9: R_X86_64_PLT32	rt_mutarray_get-0x4
     8fd:	test   rax,rax
     900:	jne    63f <botlish_fn_3+0x5f>
     906:	jmp    87c <botlish_fn_3+0x29c>
     90b:	mov    rcx,r14
     90e:	jmp    91e <botlish_fn_3+0x33e>
     913:	mov    rcx,r14
     916:	jmp    91e <botlish_fn_3+0x33e>
     91b:	mov    rcx,r14
     91e:	mov    rdx,r15
     921:	mov    rdi,r12
     924:	call   929 <botlish_fn_3+0x349>
			925: R_X86_64_PLT32	rt_mutarray_set-0x4
     929:	test   rax,rax
     92c:	jne    6f6 <botlish_fn_3+0x116>
     932:	jmp    87c <botlish_fn_3+0x29c>
     937:	mov    rdx,r13
     93a:	mov    rdi,r12
     93d:	jmp    948 <botlish_fn_3+0x368>
     942:	mov    rdx,r13
     945:	mov    rdi,r12
     948:	mov    rdi,r12
     94b:	call   950 <botlish_fn_3+0x370>
			94c: R_X86_64_PLT32	rt_mutarray_set-0x4
     950:	test   rax,rax
     953:	jne    77a <botlish_fn_3+0x19a>
     959:	jmp    87c <botlish_fn_3+0x29c>
     95e:	mov    rcx,r14
     961:	mov    rdx,r13
     964:	jmp    96f <botlish_fn_3+0x38f>
     969:	mov    rcx,r14
     96c:	mov    rdx,r13
     96f:	mov    rsi,r15
     972:	mov    rdi,r12
     975:	call   97a <botlish_fn_3+0x39a>
			976: R_X86_64_PLT32	rt_mutarray_set-0x4
     97a:	test   rax,rax
     97d:	jne    800 <botlish_fn_3+0x220>
     983:	jmp    87c <botlish_fn_3+0x29c>
     988:	(bad)
     989:	add    BYTE PTR [rax],al
     98b:	add    BYTE PTR [rax],al
     98d:	add    BYTE PTR [rax],al
	...

0000000000000990 <botlish_entry_3: chunked_append<ChunkedBuilder, list>>:
     990:	push   rbp
     991:	mov    rbp,rsp
     994:	mov    rsi,QWORD PTR [rdx]
     997:	mov    rdx,QWORD PTR [rdx+0x8]
     99b:	call   9a0 <botlish_entry_3+0x10>
			99c: R_X86_64_PLT32	botlish_fn_3-0x4 ; chunked_append<ChunkedBuilder, list>
     9a0:	mov    rsp,rbp
     9a3:	pop    rbp
     9a4:	ret

00000000000009a5 <botlish_fn_4: chunked_copy_chunks<list, int, mutarray, int>>:
     9a5:	push   rbp
     9a6:	mov    rbp,rsp
     9a9:	sub    rsp,0x50
     9ad:	mov    QWORD PTR [rsp+0x20],rbx
     9b2:	mov    QWORD PTR [rsp+0x28],r12
     9b7:	mov    QWORD PTR [rsp+0x30],r13
     9bc:	mov    QWORD PTR [rsp+0x38],r14
     9c1:	mov    QWORD PTR [rsp+0x40],r15
     9c6:	mov    r14,rdi
     9c9:	mov    QWORD PTR [rsp],rsi
     9cd:	mov    QWORD PTR [rsp+0x8],rcx
     9d2:	mov    r12,rcx
     9d5:	mov    QWORD PTR [rsp+0x10],r8
     9da:	sar    rdx,1
     9dd:	mov    rbx,rdx
     9e0:	mov    r13,rsi
     9e3:	mov    r15,r8
     9e6:	mov    rsi,r13
     9e9:	mov    rdi,r14
     9ec:	call   9f1 <botlish_fn_4+0x4c>
			9ed: R_X86_64_PLT32	rt_list_len-0x4
     9f1:	sar    rax,1
     9f4:	cmp    rbx,rax
     9f7:	jge    b32 <botlish_fn_4+0x18d>
     9fd:	mov    rdx,QWORD PTR [r13+0x8]
     a01:	mov    rcx,rbx
     a04:	shl    rcx,1
     a07:	or     rcx,0x1
     a0b:	sar    rcx,1
     a0e:	cmp    rcx,rdx
     a11:	jb     a3d <botlish_fn_4+0x98>
     a17:	mov    rdx,rbx
     a1a:	shl    rdx,1
     a1d:	or     rdx,0x1
     a21:	mov    rsi,r13
     a24:	mov    rdi,r14
     a27:	call   a2c <botlish_fn_4+0x87>
			a28: R_X86_64_PLT32	rt_list_get-0x4
     a2c:	test   rax,rax
     a2f:	je     aa8 <botlish_fn_4+0x103>
     a35:	mov    rsi,rax
     a38:	jmp    a48 <botlish_fn_4+0xa3>
     a3d:	mov    rax,QWORD PTR [r13+0x10]
     a41:	mov    rax,QWORD PTR [rax+rcx*8]
     a45:	mov    rsi,rax
     a48:	xor    ecx,ecx
     a4a:	test   rsi,0x7
     a51:	jne    a60 <botlish_fn_4+0xbb>
     a57:	movzx  rax,BYTE PTR [rsi]
     a5b:	cmp    al,0x8
     a5d:	sete   cl
     a60:	test   cl,cl
     a62:	jne    a82 <botlish_fn_4+0xdd>
     a68:	mov    rdi,r14
     a6b:	mov    rax,QWORD PTR [rdi+0x10]
     a6f:	mov    rcx,QWORD PTR [rax+0x8]
     a73:	mov    edx,0x8
     a78:	call   a7d <botlish_fn_4+0xd8>
			a79: R_X86_64_PLT32	rt_type_error-0x4
     a7d:	jmp    aa8 <botlish_fn_4+0x103>
     a82:	mov    rcx,rsi
     a85:	mov    r8d,0x1
     a8b:	mov    r9d,0x81
     a91:	mov    rdx,r15
     a94:	mov    rsi,r12
     a97:	mov    rdi,r14
     a9a:	call   a9f <botlish_fn_4+0xfa>
			a9b: R_X86_64_PLT32	rt_mutarray_copy-0x4
     a9f:	test   rax,rax
     aa2:	jne    acd <botlish_fn_4+0x128>
     aa8:	xor    rax,rax
     aab:	mov    rbx,QWORD PTR [rsp+0x20]
     ab0:	mov    r12,QWORD PTR [rsp+0x28]
     ab5:	mov    r13,QWORD PTR [rsp+0x30]
     aba:	mov    r14,QWORD PTR [rsp+0x38]
     abf:	mov    r15,QWORD PTR [rsp+0x40]
     ac4:	add    rsp,0x50
     ac8:	mov    rsp,rbp
     acb:	pop    rbp
     acc:	ret
     acd:	mov    QWORD PTR [rsp+0x18],0x81
     ad6:	mov    rsi,r15
     ad9:	test   rsi,0x1
     ae0:	je     b05 <botlish_fn_4+0x160>
     ae6:	mov    rdi,rsi
     ae9:	add    rdi,0x80
     af0:	seto   r9b
     af4:	test   r9b,r9b
     af7:	jne    b05 <botlish_fn_4+0x160>
     afd:	mov    rsi,rdi
     b00:	jmp    b15 <botlish_fn_4+0x170>
     b05:	mov    edx,0x81
     b0a:	mov    rdi,r14
     b0d:	call   b12 <botlish_fn_4+0x16d>
			b0e: R_X86_64_PLT32	rt_int_add-0x4
     b12:	mov    rsi,rax
     b15:	mov    QWORD PTR [rsp],r13
     b19:	mov    QWORD PTR [rsp+0x8],r12
     b1e:	mov    QWORD PTR [rsp+0x10],rsi
     b23:	add    rbx,0x1
     b2a:	mov    r15,rsi
     b2d:	jmp    9e6 <botlish_fn_4+0x41>
     b32:	mov    rax,r12
     b35:	mov    rbx,QWORD PTR [rsp+0x20]
     b3a:	mov    r12,QWORD PTR [rsp+0x28]
     b3f:	mov    r13,QWORD PTR [rsp+0x30]
     b44:	mov    r14,QWORD PTR [rsp+0x38]
     b49:	mov    r15,QWORD PTR [rsp+0x40]
     b4e:	add    rsp,0x50
     b52:	mov    rsp,rbp
     b55:	pop    rbp
     b56:	ret

0000000000000b57 <botlish_entry_4: chunked_copy_chunks<list, int, mutarray, int>>:
     b57:	push   rbp
     b58:	mov    rbp,rsp
     b5b:	mov    rsi,QWORD PTR [rdx]
     b5e:	mov    r9,QWORD PTR [rdx+0x8]
     b62:	mov    rcx,QWORD PTR [rdx+0x10]
     b66:	mov    r8,QWORD PTR [rdx+0x18]
     b6a:	mov    rdx,r9
     b6d:	call   b72 <botlish_entry_4+0x1b>
			b6e: R_X86_64_PLT32	botlish_fn_4-0x4 ; chunked_copy_chunks<list, int, mutarray, int>
     b72:	mov    rsp,rbp
     b75:	pop    rbp
     b76:	ret
	...

0000000000000b78 <botlish_fn_5: chunked_finish<ChunkedBuilder>>:
     b78:	push   rbp
     b79:	mov    rbp,rsp
     b7c:	sub    rsp,0x80
     b83:	mov    QWORD PTR [rsp+0x50],rbx
     b88:	mov    QWORD PTR [rsp+0x58],r12
     b8d:	mov    QWORD PTR [rsp+0x60],r13
     b92:	mov    QWORD PTR [rsp+0x68],r14
     b97:	mov    QWORD PTR [rsp+0x70],r15
     b9c:	mov    r14,rdi
     b9f:	mov    QWORD PTR [rsp+0x20],0x0
     ba8:	mov    QWORD PTR [rsp+0x28],0x0
     bb1:	mov    QWORD PTR [rsp+0x30],0x0
     bba:	mov    QWORD PTR [rsp+0x38],0x0
     bc3:	mov    QWORD PTR [rsp],rsi
     bc7:	mov    rax,QWORD PTR [rsi+0x18]
     bcb:	mov    rbx,rsi
     bce:	mov    rsi,QWORD PTR [rax+0x10]
     bd2:	mov    rax,QWORD PTR [rsi+0x8]
     bd6:	test   rax,rax
     bd9:	jne    bec <botlish_fn_5+0x74>
     bdf:	jmp    db3 <botlish_fn_5+0x23b>
     be4:	mov    r9,rax
     be7:	jmp    bf3 <botlish_fn_5+0x7b>
     bec:	mov    rax,QWORD PTR [rsi+0x10]
     bf0:	mov    r9,QWORD PTR [rax]
     bf3:	mov    QWORD PTR [rsp+0x8],r9
     bf8:	mov    r13,rbx
     bfb:	mov    rbx,r9
     bfe:	mov    rax,QWORD PTR [r13+0x18]
     c02:	mov    rsi,QWORD PTR [rax]
     c05:	mov    rdi,r14
     c08:	call   c0d <botlish_fn_5+0x95>
			c09: R_X86_64_PLT32	rt_list_len-0x4
     c0d:	mov    QWORD PTR [rsp+0x10],rax
     c12:	mov    QWORD PTR [rsp+0x18],0x81
     c1b:	mov    r8d,0x1
     c21:	mov    r15,r8
     c24:	test   rax,0x1
     c2a:	mov    rsi,rax
     c2d:	je     c5a <botlish_fn_5+0xe2>
     c33:	mov    rcx,rsi
     c36:	mov    rax,rcx
     c39:	sar    rax,1
     c3c:	imul   QWORD PTR [rip+0x18d]        # dd0 <botlish_fn_5+0x258>
     c43:	seto   cl
     c46:	or     rax,0x1
     c4a:	test   cl,cl
     c4c:	jne    c5a <botlish_fn_5+0xe2>
     c52:	mov    rdx,rax
     c55:	jmp    c6a <botlish_fn_5+0xf2>
     c5a:	mov    edx,0x81
     c5f:	mov    rdi,r14
     c62:	call   c67 <botlish_fn_5+0xef>
			c63: R_X86_64_PLT32	rt_int_mul-0x4
     c67:	mov    rdx,rax
     c6a:	mov    QWORD PTR [rsp+0x10],rdx
     c6f:	mov    rax,rdx
     c72:	and    rax,rbx
     c75:	test   rax,0x1
     c7b:	jne    c8b <botlish_fn_5+0x113>
     c81:	mov    QWORD PTR [rsp+0x40],rdx
     c86:	jmp    ca7 <botlish_fn_5+0x12f>
     c8b:	lea    rsi,[rbx-0x1]
     c8f:	mov    r12,rdx
     c92:	add    r12,rsi
     c95:	mov    QWORD PTR [rsp+0x40],rdx
     c9a:	seto   sil
     c9e:	test   sil,sil
     ca1:	je     cba <botlish_fn_5+0x142>
     ca7:	mov    rdx,rbx
     caa:	mov    rsi,QWORD PTR [rsp+0x40]
     caf:	mov    rdi,r14
     cb2:	call   cb7 <botlish_fn_5+0x13f>
			cb3: R_X86_64_PLT32	rt_int_add-0x4
     cb7:	mov    r12,rax
     cba:	mov    QWORD PTR [rsp+0x18],r12
     cbf:	mov    r9,QWORD PTR [r13+0x18]
     cc3:	mov    rsi,QWORD PTR [r9]
     cc6:	mov    QWORD PTR [rsp+0x20],rsi
     ccb:	mov    QWORD PTR [rsp+0x48],rsi
     cd0:	mov    QWORD PTR [rsp+0x28],0x1
     cd9:	mov    rsi,r12
     cdc:	mov    rdi,r14
     cdf:	call   ce4 <botlish_fn_5+0x16c>
			ce0: R_X86_64_PLT32	rt_mutarray_allocate-0x4
     ce4:	test   rax,rax
     ce7:	je     d66 <botlish_fn_5+0x1ee>
     ced:	mov    QWORD PTR [rsp+0x30],rax
     cf2:	mov    rcx,rax
     cf5:	mov    QWORD PTR [rsp+0x38],0x1
     cfe:	mov    rsi,QWORD PTR [rsp+0x48]
     d03:	mov    rdx,r15
     d06:	mov    rdi,r14
     d09:	mov    r8,r15
     d0c:	call   d11 <botlish_fn_5+0x199>
			d0d: R_X86_64_PLT32	botlish_fn_4-0x4 ; chunked_copy_chunks<list, int, mutarray, int>
     d11:	test   rax,rax
     d14:	je     d66 <botlish_fn_5+0x1ee>
     d1a:	mov    QWORD PTR [rsp+0x20],rax
     d1f:	mov    QWORD PTR [rsp+0x48],rax
     d24:	mov    rcx,QWORD PTR [r13+0x18]
     d28:	mov    rcx,QWORD PTR [rcx+0x8]
     d2c:	mov    rdx,QWORD PTR [rsp+0x40]
     d31:	mov    r8,r15
     d34:	mov    r9,rbx
     d37:	mov    rsi,QWORD PTR [rsp+0x48]
     d3c:	mov    rdi,r14
     d3f:	call   d44 <botlish_fn_5+0x1cc>
			d40: R_X86_64_PLT32	rt_mutarray_copy-0x4
     d44:	test   rax,rax
     d47:	je     d66 <botlish_fn_5+0x1ee>
     d4d:	mov    rdx,r12
     d50:	mov    rsi,QWORD PTR [rsp+0x48]
     d55:	mov    rdi,r14
     d58:	call   d5d <botlish_fn_5+0x1e5>
			d59: R_X86_64_PLT32	rt_mutarray_freeze-0x4
     d5d:	test   rax,rax
     d60:	jne    d8e <botlish_fn_5+0x216>
     d66:	xor    rax,rax
     d69:	mov    rbx,QWORD PTR [rsp+0x50]
     d6e:	mov    r12,QWORD PTR [rsp+0x58]
     d73:	mov    r13,QWORD PTR [rsp+0x60]
     d78:	mov    r14,QWORD PTR [rsp+0x68]
     d7d:	mov    r15,QWORD PTR [rsp+0x70]
     d82:	add    rsp,0x80
     d89:	mov    rsp,rbp
     d8c:	pop    rbp
     d8d:	ret
     d8e:	mov    rbx,QWORD PTR [rsp+0x50]
     d93:	mov    r12,QWORD PTR [rsp+0x58]
     d98:	mov    r13,QWORD PTR [rsp+0x60]
     d9d:	mov    r14,QWORD PTR [rsp+0x68]
     da2:	mov    r15,QWORD PTR [rsp+0x70]
     da7:	add    rsp,0x80
     dae:	mov    rsp,rbp
     db1:	pop    rbp
     db2:	ret
     db3:	mov    edx,0x1
     db8:	mov    rdi,r14
     dbb:	call   dc0 <botlish_fn_5+0x248>
			dbc: R_X86_64_PLT32	rt_mutarray_get-0x4
     dc0:	test   rax,rax
     dc3:	jne    be4 <botlish_fn_5+0x6c>
     dc9:	jmp    d66 <botlish_fn_5+0x1ee>
     dce:	add    BYTE PTR [rax],al
     dd0:	add    BYTE PTR [rax],0x0
     dd3:	add    BYTE PTR [rax],al
     dd5:	add    BYTE PTR [rax],al
	...

0000000000000dd8 <botlish_entry_5: chunked_finish<ChunkedBuilder>>:
     dd8:	push   rbp
     dd9:	mov    rbp,rsp
     ddc:	mov    rsi,QWORD PTR [rdx]
     ddf:	call   de4 <botlish_entry_5+0xc>
			de0: R_X86_64_PLT32	botlish_fn_5-0x4 ; chunked_finish<ChunkedBuilder>
     de4:	mov    rsp,rbp
     de7:	pop    rbp
     de8:	ret
     de9:	add    BYTE PTR [rax],al
     deb:	add    BYTE PTR [rax],al
     ded:	add    BYTE PTR [rax],al
	...

0000000000000df0 <botlish_fn_6: peek<str, int>>:
     df0:	push   rbp
     df1:	mov    rbp,rsp
     df4:	sub    rsp,0x40
     df8:	mov    QWORD PTR [rsp+0x20],rbx
     dfd:	mov    QWORD PTR [rsp+0x28],r12
     e02:	mov    QWORD PTR [rsp+0x30],r13
     e07:	mov    rbx,rdx
     e0a:	mov    r13,rdi
     e0d:	mov    QWORD PTR [rsp],rsi
     e11:	mov    QWORD PTR [rsp+0x8],rdx
     e16:	mov    rdx,QWORD PTR [rsi+0x8]
     e1a:	mov    r12,rsi
     e1d:	shl    rdx,1
     e20:	mov    rax,rdx
     e23:	or     rax,0x1
     e27:	mov    rcx,rbx
     e2a:	and    rcx,rax
     e2d:	test   rcx,0x1
     e34:	jne    e5e <botlish_fn_6+0x6e>
     e3a:	or     rdx,0x1
     e3e:	mov    rsi,rbx
     e41:	mov    rdi,r13
     e44:	call   e49 <botlish_fn_6+0x59>
			e45: R_X86_64_PLT32	rt_int_cmp-0x4
     e49:	mov    ecx,0x2
     e4e:	test   rax,rax
     e51:	cmovge rcx,QWORD PTR [rip+0xd7]        # f30 <botlish_fn_6+0x140>
     e59:	jmp    e72 <botlish_fn_6+0x82>
     e5e:	or     rdx,0x1
     e62:	mov    ecx,0x2
     e67:	cmp    rbx,rdx
     e6a:	cmovge rcx,QWORD PTR [rip+0xbe]        # f30 <botlish_fn_6+0x140>
     e72:	cmp    rcx,0x6
     e76:	je     f06 <botlish_fn_6+0x116>
     e7c:	mov    QWORD PTR [rsp+0x10],0x3
     e85:	test   rbx,0x1
     e8c:	je     ea4 <botlish_fn_6+0xb4>
     e92:	mov    rcx,rbx
     e95:	add    rcx,0x2
     e99:	seto   al
     e9c:	test   al,al
     e9e:	je     eb7 <botlish_fn_6+0xc7>
     ea4:	mov    edx,0x3
     ea9:	mov    rsi,rbx
     eac:	mov    rdi,r13
     eaf:	call   eb4 <botlish_fn_6+0xc4>
			eb0: R_X86_64_PLT32	rt_int_add-0x4
     eb4:	mov    rcx,rax
     eb7:	mov    QWORD PTR [rsp+0x10],rcx
     ebc:	mov    rdx,rbx
     ebf:	mov    rsi,r12
     ec2:	mov    rdi,r13
     ec5:	call   eca <botlish_fn_6+0xda>
			ec6: R_X86_64_PLT32	rt_substr-0x4
     eca:	test   rax,rax
     ecd:	jne    eee <botlish_fn_6+0xfe>
     ed3:	xor    rax,rax
     ed6:	mov    rbx,QWORD PTR [rsp+0x20]
     edb:	mov    r12,QWORD PTR [rsp+0x28]
     ee0:	mov    r13,QWORD PTR [rsp+0x30]
     ee5:	add    rsp,0x40
     ee9:	mov    rsp,rbp
     eec:	pop    rbp
     eed:	ret
     eee:	mov    rbx,QWORD PTR [rsp+0x20]
     ef3:	mov    r12,QWORD PTR [rsp+0x28]
     ef8:	mov    r13,QWORD PTR [rsp+0x30]
     efd:	add    rsp,0x40
     f01:	mov    rsp,rbp
     f04:	pop    rbp
     f05:	ret
     f06:	mov    rdi,r13
     f09:	mov    rax,QWORD PTR [rdi+0x10]
     f0d:	mov    rax,QWORD PTR [rax+0x10]
     f11:	mov    rbx,QWORD PTR [rsp+0x20]
     f16:	mov    r12,QWORD PTR [rsp+0x28]
     f1b:	mov    r13,QWORD PTR [rsp+0x30]
     f20:	add    rsp,0x40
     f24:	mov    rsp,rbp
     f27:	pop    rbp
     f28:	ret
     f29:	add    BYTE PTR [rax],al
     f2b:	add    BYTE PTR [rax],al
     f2d:	add    BYTE PTR [rax],al
     f2f:	add    BYTE PTR [rsi],al
     f31:	add    BYTE PTR [rax],al
     f33:	add    BYTE PTR [rax],al
     f35:	add    BYTE PTR [rax],al
	...

0000000000000f38 <botlish_entry_6: peek<str, int>>:
     f38:	push   rbp
     f39:	mov    rbp,rsp
     f3c:	mov    rsi,QWORD PTR [rdx]
     f3f:	mov    rdx,QWORD PTR [rdx+0x8]
     f43:	call   f48 <botlish_entry_6+0x10>
			f44: R_X86_64_PLT32	botlish_fn_6-0x4 ; peek<str, int>
     f48:	mov    rsp,rbp
     f4b:	pop    rbp
     f4c:	ret
     f4d:	add    BYTE PTR [rax],al
	...

0000000000000f50 <botlish_fn_7: quote_at?<str, int>>:
     f50:	push   rbp
     f51:	mov    rbp,rsp
     f54:	sub    rsp,0x20
     f58:	mov    QWORD PTR [rsp],rbx
     f5c:	mov    QWORD PTR [rsp+0x8],r12
     f61:	mov    QWORD PTR [rsp+0x10],r13
     f66:	mov    rbx,rdx
     f69:	mov    r13,rdi
     f6c:	mov    rdx,QWORD PTR [rsi+0x8]
     f70:	mov    r12,rsi
     f73:	shl    rdx,1
     f76:	mov    rax,rdx
     f79:	or     rax,0x1
     f7d:	mov    rcx,rbx
     f80:	and    rcx,rax
     f83:	test   rcx,0x1
     f8a:	jne    fb4 <botlish_fn_7+0x64>
     f90:	or     rdx,0x1
     f94:	mov    rsi,rbx
     f97:	mov    rdi,r13
     f9a:	call   f9f <botlish_fn_7+0x4f>
			f9b: R_X86_64_PLT32	rt_int_cmp-0x4
     f9f:	mov    ecx,0x2
     fa4:	test   rax,rax
     fa7:	cmovl  rcx,QWORD PTR [rip+0xa1]        # 1050 <botlish_fn_7+0x100>
     faf:	jmp    fcb <botlish_fn_7+0x7b>
     fb4:	or     rdx,0x1
     fb8:	mov    ecx,0x2
     fbd:	mov    rax,rbx
     fc0:	cmp    rax,rdx
     fc3:	cmovl  rcx,QWORD PTR [rip+0x85]        # 1050 <botlish_fn_7+0x100>
     fcb:	mov    eax,0x6
     fd0:	cmp    rcx,0x6
     fd4:	je     fe7 <botlish_fn_7+0x97>
     fda:	mov    eax,0x2
     fdf:	mov    r12,rax
     fe2:	jmp    1034 <botlish_fn_7+0xe4>
     fe7:	mov    rdi,r13
     fea:	mov    rsi,r12
     fed:	mov    r12,rax
     ff0:	mov    rdx,rbx
     ff3:	call   ff8 <botlish_fn_7+0xa8>
			ff4: R_X86_64_PLT32	rt_str_char_at-0x4
     ff8:	test   rax,rax
     ffb:	jne    101b <botlish_fn_7+0xcb>
    1001:	xor    rax,rax
    1004:	mov    rbx,QWORD PTR [rsp]
    1008:	mov    r12,QWORD PTR [rsp+0x8]
    100d:	mov    r13,QWORD PTR [rsp+0x10]
    1012:	add    rsp,0x20
    1016:	mov    rsp,rbp
    1019:	pop    rbp
    101a:	ret
    101b:	cmp    rax,0x114
    1021:	je     1031 <botlish_fn_7+0xe1>
    1027:	mov    eax,0x2
    102c:	jmp    1034 <botlish_fn_7+0xe4>
    1031:	mov    rax,r12
    1034:	mov    rbx,QWORD PTR [rsp]
    1038:	mov    r12,QWORD PTR [rsp+0x8]
    103d:	mov    r13,QWORD PTR [rsp+0x10]
    1042:	add    rsp,0x20
    1046:	mov    rsp,rbp
    1049:	pop    rbp
    104a:	ret
    104b:	add    BYTE PTR [rax],al
    104d:	add    BYTE PTR [rax],al
    104f:	add    BYTE PTR [rsi],al
    1051:	add    BYTE PTR [rax],al
    1053:	add    BYTE PTR [rax],al
    1055:	add    BYTE PTR [rax],al
	...

0000000000001058 <botlish_entry_7: quote_at?<str, int>>:
    1058:	push   rbp
    1059:	mov    rbp,rsp
    105c:	mov    rsi,QWORD PTR [rdx]
    105f:	mov    rdx,QWORD PTR [rdx+0x8]
    1063:	call   1068 <botlish_entry_7+0x10>
			1064: R_X86_64_PLT32	botlish_fn_7-0x4 ; quote_at?<str, int>
    1068:	mov    rsp,rbp
    106b:	pop    rbp
    106c:	ret
    106d:	add    BYTE PTR [rax],al
	...

0000000000001070 <botlish_fn_8: scan_unquoted<str, int, int>>:
    1070:	push   rbp
    1071:	mov    rbp,rsp
    1074:	sub    rsp,0x40
    1078:	mov    QWORD PTR [rsp+0x20],rbx
    107d:	mov    QWORD PTR [rsp+0x28],r12
    1082:	mov    QWORD PTR [rsp+0x30],r13
    1087:	mov    QWORD PTR [rsp+0x38],r14
    108c:	mov    r13,rdi
    108f:	mov    QWORD PTR [rsp+0x18],0x0
    1098:	mov    QWORD PTR [rsp],rsi
    109c:	mov    r12,rsi
    109f:	mov    QWORD PTR [rsp+0x8],rdx
    10a4:	mov    rbx,rdx
    10a7:	mov    QWORD PTR [rsp+0x10],rcx
    10ac:	mov    rax,r12
    10af:	mov    rsi,rcx
    10b2:	mov    rdx,QWORD PTR [rax+0x8]
    10b6:	mov    r12,rax
    10b9:	shl    rdx,1
    10bc:	or     rdx,0x1
    10c0:	mov    rax,rsi
    10c3:	and    rax,rdx
    10c6:	mov    r14,rsi
    10c9:	test   rax,0x1
    10cf:	jne    10f5 <botlish_fn_8+0x85>
    10d5:	mov    rsi,r14
    10d8:	mov    rdi,r13
    10db:	call   10e0 <botlish_fn_8+0x70>
			10dc: R_X86_64_PLT32	rt_int_cmp-0x4
    10e0:	mov    ecx,0x2
    10e5:	test   rax,rax
    10e8:	cmovl  rcx,QWORD PTR [rip+0x138]        # 1228 <botlish_fn_8+0x1b8>
    10f0:	jmp    1108 <botlish_fn_8+0x98>
    10f5:	mov    ecx,0x2
    10fa:	mov    rsi,r14
    10fd:	cmp    rsi,rdx
    1100:	cmovl  rcx,QWORD PTR [rip+0x120]        # 1228 <botlish_fn_8+0x1b8>
    1108:	cmp    rcx,0x6
    110c:	je     1120 <botlish_fn_8+0xb0>
    1112:	mov    rdx,rbx
    1115:	mov    rsi,r12
    1118:	mov    rdi,r13
    111b:	jmp    11cb <botlish_fn_8+0x15b>
    1120:	mov    rdx,r14
    1123:	mov    rsi,r12
    1126:	mov    rdi,r13
    1129:	call   112e <botlish_fn_8+0xbe>
			112a: R_X86_64_PLT32	rt_str_char_at-0x4
    112e:	test   rax,rax
    1131:	je     11e2 <botlish_fn_8+0x172>
    1137:	cmp    rax,0x164
    113d:	jne    114b <botlish_fn_8+0xdb>
    1143:	mov    rdx,rbx
    1146:	jmp    11c5 <botlish_fn_8+0x155>
    114b:	cmp    rax,0x54
    114f:	jne    115d <botlish_fn_8+0xed>
    1155:	mov    rdx,rbx
    1158:	jmp    11c5 <botlish_fn_8+0x155>
    115d:	mov    QWORD PTR [rsp+0x18],0x3
    1166:	mov    rsi,r14
    1169:	test   rsi,0x1
    1170:	je     1193 <botlish_fn_8+0x123>
    1176:	mov    rsi,r14
    1179:	mov    rax,rsi
    117c:	add    rax,0x2
    1180:	seto   cl
    1183:	test   cl,cl
    1185:	jne    1193 <botlish_fn_8+0x123>
    118b:	mov    rsi,r12
    118e:	jmp    11a6 <botlish_fn_8+0x136>
    1193:	mov    edx,0x3
    1198:	mov    rsi,r14
    119b:	mov    rdi,r13
    119e:	call   11a3 <botlish_fn_8+0x133>
			119f: R_X86_64_PLT32	rt_int_add-0x4
    11a3:	mov    rsi,r12
    11a6:	mov    rsi,r12
    11a9:	mov    QWORD PTR [rsp],rsi
    11ad:	mov    rdx,rbx
    11b0:	mov    QWORD PTR [rsp+0x8],rdx
    11b5:	mov    QWORD PTR [rsp+0x10],rax
    11ba:	mov    rsi,rax
    11bd:	mov    rax,r12
    11c0:	jmp    10b2 <botlish_fn_8+0x42>
    11c5:	mov    rsi,r12
    11c8:	mov    rdi,r13
    11cb:	mov    rsi,r12
    11ce:	mov    rdi,r13
    11d1:	mov    rcx,r14
    11d4:	call   11d9 <botlish_fn_8+0x169>
			11d5: R_X86_64_PLT32	rt_substr-0x4
    11d9:	test   rax,rax
    11dc:	jne    1205 <botlish_fn_8+0x195>
    11e2:	xor    rdx,rdx
    11e5:	mov    rax,rdx
    11e8:	mov    rbx,QWORD PTR [rsp+0x20]
    11ed:	mov    r12,QWORD PTR [rsp+0x28]
    11f2:	mov    r13,QWORD PTR [rsp+0x30]
    11f7:	mov    r14,QWORD PTR [rsp+0x38]
    11fc:	add    rsp,0x40
    1200:	mov    rsp,rbp
    1203:	pop    rbp
    1204:	ret
    1205:	mov    rdx,r14
    1208:	mov    rbx,QWORD PTR [rsp+0x20]
    120d:	mov    r12,QWORD PTR [rsp+0x28]
    1212:	mov    r13,QWORD PTR [rsp+0x30]
    1217:	mov    r14,QWORD PTR [rsp+0x38]
    121c:	add    rsp,0x40
    1220:	mov    rsp,rbp
    1223:	pop    rbp
    1224:	ret
    1225:	add    BYTE PTR [rax],al
    1227:	add    BYTE PTR [rsi],al
    1229:	add    BYTE PTR [rax],al
    122b:	add    BYTE PTR [rax],al
    122d:	add    BYTE PTR [rax],al
	...

0000000000001230 <botlish_entry_8: scan_unquoted<str, int, int>>:
    1230:	push   rbp
    1231:	mov    rbp,rsp
    1234:	ud2

0000000000001236 <botlish_fn_9: scan_quoted<str, int, str>>:
    1236:	push   rbp
    1237:	mov    rbp,rsp
    123a:	sub    rsp,0xb0
    1241:	mov    QWORD PTR [rsp+0x80],rbx
    1249:	mov    QWORD PTR [rsp+0x88],r12
    1251:	mov    QWORD PTR [rsp+0x90],r13
    1259:	mov    QWORD PTR [rsp+0x98],r14
    1261:	mov    QWORD PTR [rsp+0xa0],r15
    1269:	mov    r15,rdi
    126c:	mov    QWORD PTR [rsp+0x18],0x0
    1275:	mov    QWORD PTR [rsp+0x20],0x0
    127e:	mov    QWORD PTR [rsp],rsi
    1282:	mov    QWORD PTR [rsp+0x8],rdx
    1287:	mov    QWORD PTR [rsp+0x10],rcx
    128c:	mov    r13,rcx
    128f:	lea    r12,[rsp+0x58]
    1294:	mov    rbx,rsi
    1297:	mov    QWORD PTR [rsp+0x78],rdx
    129c:	mov    rdx,QWORD PTR [rsp+0x78]
    12a1:	mov    rsi,rbx
    12a4:	mov    rdi,r15
    12a7:	call   12ac <botlish_fn_9+0x76>
			12a8: R_X86_64_PLT32	botlish_fn_6-0x4 ; peek<str, int>
    12ac:	test   rax,rax
    12af:	je     154b <botlish_fn_9+0x315>
    12b5:	mov    QWORD PTR [rsp+0x18],rax
    12ba:	mov    r14,rax
    12bd:	mov    rdx,QWORD PTR [rsp+0x78]
    12c2:	mov    rsi,rbx
    12c5:	mov    rdi,r15
    12c8:	call   12cd <botlish_fn_9+0x97>
			12c9: R_X86_64_PLT32	botlish_fn_7-0x4 ; quote_at?<str, int>
    12cd:	test   rax,rax
    12d0:	je     154b <botlish_fn_9+0x315>
    12d6:	cmp    rax,0x6
    12da:	je     1393 <botlish_fn_9+0x15d>
    12e0:	mov    QWORD PTR [rsp+0x20],0x3
    12e9:	mov    rsi,QWORD PTR [rsp+0x78]
    12ee:	test   rsi,0x1
    12f5:	je     131f <botlish_fn_9+0xe9>
    12fb:	mov    rsi,QWORD PTR [rsp+0x78]
    1300:	mov    rcx,rsi
    1303:	add    rcx,0x2
    1307:	seto   dl
    130a:	test   dl,dl
    130c:	jne    131f <botlish_fn_9+0xe9>
    1312:	mov    rsi,rcx
    1315:	mov    QWORD PTR [rsp+0x78],rcx
    131a:	jmp    1339 <botlish_fn_9+0x103>
    131f:	mov    edx,0x3
    1324:	mov    rsi,QWORD PTR [rsp+0x78]
    1329:	mov    rdi,r15
    132c:	call   1331 <botlish_fn_9+0xfb>
			132d: R_X86_64_PLT32	rt_int_add-0x4
    1331:	mov    rsi,rax
    1334:	mov    QWORD PTR [rsp+0x78],rax
    1339:	mov    QWORD PTR [rsp+0x8],rsi
    133e:	mov    QWORD PTR [rsp+0x58],0x0
    1347:	mov    QWORD PTR [rsp+0x60],r13
    134c:	mov    QWORD PTR [rsp+0x68],0x0
    1355:	mov    QWORD PTR [rsp+0x70],r14
    135a:	mov    esi,0x2
    135f:	mov    edx,0x4
    1364:	mov    rcx,r12
    1367:	mov    rdi,r15
    136a:	call   136f <botlish_fn_9+0x139>
			136b: R_X86_64_PLT32	rt_construct-0x4
    136f:	test   rax,rax
    1372:	je     154b <botlish_fn_9+0x315>
    1378:	mov    QWORD PTR [rsp],rbx
    137c:	mov    rsi,QWORD PTR [rsp+0x78]
    1381:	mov    QWORD PTR [rsp+0x8],rsi
    1386:	mov    QWORD PTR [rsp+0x10],rax
    138b:	mov    r13,rax
    138e:	jmp    129c <botlish_fn_9+0x66>
    1393:	mov    QWORD PTR [rsp+0x20],0x3
    139c:	mov    rsi,QWORD PTR [rsp+0x78]
    13a1:	test   rsi,0x1
    13a8:	je     13c5 <botlish_fn_9+0x18f>
    13ae:	mov    rsi,QWORD PTR [rsp+0x78]
    13b3:	mov    rdx,rsi
    13b6:	add    rdx,0x2
    13ba:	seto   al
    13bd:	test   al,al
    13bf:	je     13da <botlish_fn_9+0x1a4>
    13c5:	mov    edx,0x3
    13ca:	mov    rsi,QWORD PTR [rsp+0x78]
    13cf:	mov    rdi,r15
    13d2:	call   13d7 <botlish_fn_9+0x1a1>
			13d3: R_X86_64_PLT32	rt_int_add-0x4
    13d7:	mov    rdx,rax
    13da:	mov    rsi,rbx
    13dd:	mov    rdi,r15
    13e0:	call   13e5 <botlish_fn_9+0x1af>
			13e1: R_X86_64_PLT32	botlish_fn_7-0x4 ; quote_at?<str, int>
    13e5:	test   rax,rax
    13e8:	je     154b <botlish_fn_9+0x315>
    13ee:	cmp    rax,0x6
    13f2:	je     14b1 <botlish_fn_9+0x27b>
    13f8:	xor    rsi,rsi
    13fb:	lea    rcx,[rsp+0x48]
    1400:	mov    QWORD PTR [rsp+0x48],0x0
    1409:	mov    QWORD PTR [rsp+0x50],r13
    140e:	mov    edx,0x2
    1413:	mov    rdi,r15
    1416:	call   141b <botlish_fn_9+0x1e5>
			1417: R_X86_64_PLT32	rt_construct-0x4
    141b:	test   rax,rax
    141e:	je     154b <botlish_fn_9+0x315>
    1424:	mov    QWORD PTR [rsp],rax
    1428:	mov    r12,rax
    142b:	mov    QWORD PTR [rsp+0x10],0x3
    1434:	mov    rsi,QWORD PTR [rsp+0x78]
    1439:	test   rsi,0x1
    1440:	je     1465 <botlish_fn_9+0x22f>
    1446:	mov    rsi,QWORD PTR [rsp+0x78]
    144b:	mov    rdx,rsi
    144e:	add    rdx,0x2
    1452:	seto   al
    1455:	test   al,al
    1457:	jne    1465 <botlish_fn_9+0x22f>
    145d:	mov    rax,r12
    1460:	jmp    147d <botlish_fn_9+0x247>
    1465:	mov    edx,0x3
    146a:	mov    rsi,QWORD PTR [rsp+0x78]
    146f:	mov    rdi,r15
    1472:	call   1477 <botlish_fn_9+0x241>
			1473: R_X86_64_PLT32	rt_int_add-0x4
    1477:	mov    rdx,rax
    147a:	mov    rax,r12
    147d:	mov    rbx,QWORD PTR [rsp+0x80]
    1485:	mov    r12,QWORD PTR [rsp+0x88]
    148d:	mov    r13,QWORD PTR [rsp+0x90]
    1495:	mov    r14,QWORD PTR [rsp+0x98]
    149d:	mov    r15,QWORD PTR [rsp+0xa0]
    14a5:	add    rsp,0xb0
    14ac:	mov    rsp,rbp
    14af:	pop    rbp
    14b0:	ret
    14b1:	mov    QWORD PTR [rsp+0x20],0x5
    14ba:	mov    rsi,QWORD PTR [rsp+0x78]
    14bf:	test   rsi,0x1
    14c6:	je     14f0 <botlish_fn_9+0x2ba>
    14cc:	mov    rsi,QWORD PTR [rsp+0x78]
    14d1:	mov    rcx,rsi
    14d4:	add    rcx,0x4
    14d8:	seto   al
    14db:	test   al,al
    14dd:	jne    14f0 <botlish_fn_9+0x2ba>
    14e3:	mov    rsi,rcx
    14e6:	mov    QWORD PTR [rsp+0x78],rcx
    14eb:	jmp    150a <botlish_fn_9+0x2d4>
    14f0:	mov    edx,0x5
    14f5:	mov    rsi,QWORD PTR [rsp+0x78]
    14fa:	mov    rdi,r15
    14fd:	call   1502 <botlish_fn_9+0x2cc>
			14fe: R_X86_64_PLT32	rt_int_add-0x4
    1502:	mov    rsi,rax
    1505:	mov    QWORD PTR [rsp+0x78],rax
    150a:	mov    QWORD PTR [rsp+0x8],rsi
    150f:	lea    rcx,[rsp+0x28]
    1514:	mov    QWORD PTR [rsp+0x28],0x0
    151d:	mov    QWORD PTR [rsp+0x30],r13
    1522:	mov    QWORD PTR [rsp+0x38],0x0
    152b:	mov    QWORD PTR [rsp+0x40],r14
    1530:	mov    esi,0x2
    1535:	mov    edx,0x4
    153a:	mov    rdi,r15
    153d:	call   1542 <botlish_fn_9+0x30c>
			153e: R_X86_64_PLT32	rt_construct-0x4
    1542:	test   rax,rax
    1545:	jne    1585 <botlish_fn_9+0x34f>
    154b:	xor    rdx,rdx
    154e:	mov    rax,rdx
    1551:	mov    rbx,QWORD PTR [rsp+0x80]
    1559:	mov    r12,QWORD PTR [rsp+0x88]
    1561:	mov    r13,QWORD PTR [rsp+0x90]
    1569:	mov    r14,QWORD PTR [rsp+0x98]
    1571:	mov    r15,QWORD PTR [rsp+0xa0]
    1579:	add    rsp,0xb0
    1580:	mov    rsp,rbp
    1583:	pop    rbp
    1584:	ret
    1585:	mov    QWORD PTR [rsp],rbx
    1589:	mov    rsi,QWORD PTR [rsp+0x78]
    158e:	mov    QWORD PTR [rsp+0x8],rsi
    1593:	mov    QWORD PTR [rsp+0x10],rax
    1598:	mov    r13,rax
    159b:	jmp    129c <botlish_fn_9+0x66>

00000000000015a0 <botlish_entry_9: scan_quoted<str, int, str>>:
    15a0:	push   rbp
    15a1:	mov    rbp,rsp
    15a4:	ud2

00000000000015a6 <botlish_fn_10: scan_field<str, int>>:
    15a6:	push   rbp
    15a7:	mov    rbp,rsp
    15aa:	sub    rsp,0x40
    15ae:	mov    QWORD PTR [rsp+0x20],rbx
    15b3:	mov    QWORD PTR [rsp+0x28],r12
    15b8:	mov    QWORD PTR [rsp+0x30],r13
    15bd:	mov    r12,rdi
    15c0:	mov    r13,rdx
    15c3:	mov    QWORD PTR [rsp+0x10],0x0
    15cc:	mov    QWORD PTR [rsp],rsi
    15d0:	mov    rbx,rsi
    15d3:	mov    QWORD PTR [rsp+0x8],rdx
    15d8:	mov    rdx,r13
    15db:	mov    rsi,rbx
    15de:	mov    rdi,r12
    15e1:	call   15e6 <botlish_fn_10+0x40>
			15e2: R_X86_64_PLT32	botlish_fn_7-0x4 ; quote_at?<str, int>
    15e6:	test   rax,rax
    15e9:	je     169a <botlish_fn_10+0xf4>
    15ef:	cmp    rax,0x6
    15f3:	je     162b <botlish_fn_10+0x85>
    15f9:	mov    rcx,r13
    15fc:	mov    rsi,rbx
    15ff:	mov    rdi,r12
    1602:	mov    rdx,rcx
    1605:	call   160a <botlish_fn_10+0x64>
			1606: R_X86_64_PLT32	botlish_fn_8-0x4 ; scan_unquoted<str, int, int>
    160a:	test   rax,rax
    160d:	je     169a <botlish_fn_10+0xf4>
    1613:	mov    rbx,QWORD PTR [rsp+0x20]
    1618:	mov    r12,QWORD PTR [rsp+0x28]
    161d:	mov    r13,QWORD PTR [rsp+0x30]
    1622:	add    rsp,0x40
    1626:	mov    rsp,rbp
    1629:	pop    rbp
    162a:	ret
    162b:	mov    rcx,r13
    162e:	mov    QWORD PTR [rsp+0x10],0x3
    1637:	test   rcx,0x1
    163e:	jne    164c <botlish_fn_10+0xa6>
    1644:	mov    r13,rcx
    1647:	jmp    1661 <botlish_fn_10+0xbb>
    164c:	mov    rdx,rcx
    164f:	add    rdx,0x2
    1653:	mov    r13,rcx
    1656:	seto   al
    1659:	test   al,al
    165b:	je     1674 <botlish_fn_10+0xce>
    1661:	mov    edx,0x3
    1666:	mov    rsi,r13
    1669:	mov    rdi,r12
    166c:	call   1671 <botlish_fn_10+0xcb>
			166d: R_X86_64_PLT32	rt_int_add-0x4
    1671:	mov    rdx,rax
    1674:	mov    QWORD PTR [rsp+0x8],rdx
    1679:	mov    rdi,r12
    167c:	mov    rax,QWORD PTR [rdi+0x10]
    1680:	mov    rcx,QWORD PTR [rax+0x10]
    1684:	mov    QWORD PTR [rsp+0x10],rcx
    1689:	mov    rsi,rbx
    168c:	call   1691 <botlish_fn_10+0xeb>
			168d: R_X86_64_PLT32	botlish_fn_9-0x4 ; scan_quoted<str, int, str>
    1691:	test   rax,rax
    1694:	jne    16b8 <botlish_fn_10+0x112>
    169a:	xor    rdx,rdx
    169d:	mov    rax,rdx
    16a0:	mov    rbx,QWORD PTR [rsp+0x20]
    16a5:	mov    r12,QWORD PTR [rsp+0x28]
    16aa:	mov    r13,QWORD PTR [rsp+0x30]
    16af:	add    rsp,0x40
    16b3:	mov    rsp,rbp
    16b6:	pop    rbp
    16b7:	ret
    16b8:	mov    rbx,QWORD PTR [rsp+0x20]
    16bd:	mov    r12,QWORD PTR [rsp+0x28]
    16c2:	mov    r13,QWORD PTR [rsp+0x30]
    16c7:	add    rsp,0x40
    16cb:	mov    rsp,rbp
    16ce:	pop    rbp
    16cf:	ret

00000000000016d0 <botlish_entry_10: scan_field<str, int>>:
    16d0:	push   rbp
    16d1:	mov    rbp,rsp
    16d4:	ud2
	...

00000000000016d8 <botlish_fn_11: scan_record<str, int, ChunkedBuilder>>:
    16d8:	push   rbp
    16d9:	mov    rbp,rsp
    16dc:	sub    rsp,0x40
    16e0:	mov    QWORD PTR [rsp+0x20],rbx
    16e5:	mov    QWORD PTR [rsp+0x28],r12
    16ea:	mov    QWORD PTR [rsp+0x30],r13
    16ef:	mov    QWORD PTR [rsp+0x38],r14
    16f4:	mov    r12,rdi
    16f7:	mov    QWORD PTR [rsp+0x18],0x0
    1700:	mov    QWORD PTR [rsp],rsi
    1704:	mov    QWORD PTR [rsp+0x8],rdx
    1709:	mov    QWORD PTR [rsp+0x10],rcx
    170e:	mov    rbx,rsi
    1711:	mov    r13,rcx
    1714:	mov    rsi,rbx
    1717:	mov    rdi,r12
    171a:	call   171f <botlish_fn_11+0x47>
			171b: R_X86_64_PLT32	botlish_fn_10-0x4 ; scan_field<str, int>
    171f:	test   rax,rax
    1722:	je     1834 <botlish_fn_11+0x15c>
    1728:	mov    QWORD PTR [rsp+0x8],rax
    172d:	mov    QWORD PTR [rsp+0x18],rdx
    1732:	mov    rsi,r13
    1735:	mov    r13,rdx
    1738:	mov    rdx,rax
    173b:	mov    rdi,r12
    173e:	call   1743 <botlish_fn_11+0x6b>
			173f: R_X86_64_PLT32	botlish_fn_2-0x4 ; chunked_append<ChunkedBuilder, str>
    1743:	test   rax,rax
    1746:	je     1834 <botlish_fn_11+0x15c>
    174c:	mov    QWORD PTR [rsp+0x8],rax
    1751:	mov    r14,rax
    1754:	mov    rdx,QWORD PTR [rbx+0x8]
    1758:	shl    rdx,1
    175b:	or     rdx,0x1
    175f:	mov    rsi,r13
    1762:	mov    rax,rsi
    1765:	and    rax,rdx
    1768:	test   rax,0x1
    176e:	jne    1794 <botlish_fn_11+0xbc>
    1774:	mov    rsi,r13
    1777:	mov    rdi,r12
    177a:	call   177f <botlish_fn_11+0xa7>
			177b: R_X86_64_PLT32	rt_int_cmp-0x4
    177f:	mov    ecx,0x2
    1784:	test   rax,rax
    1787:	cmovl  rcx,QWORD PTR [rip+0x199]        # 1928 <botlish_fn_11+0x250>
    178f:	jmp    17a7 <botlish_fn_11+0xcf>
    1794:	mov    ecx,0x2
    1799:	mov    rax,r13
    179c:	cmp    rax,rdx
    179f:	cmovl  rcx,QWORD PTR [rip+0x181]        # 1928 <botlish_fn_11+0x250>
    17a7:	cmp    rcx,0x6
    17ab:	je     17bc <botlish_fn_11+0xe4>
    17b1:	mov    rsi,r14
    17b4:	mov    rdi,r12
    17b7:	jmp    17ef <botlish_fn_11+0x117>
    17bc:	mov    rdx,r13
    17bf:	mov    rsi,rbx
    17c2:	mov    rdi,r12
    17c5:	call   17ca <botlish_fn_11+0xf2>
			17c6: R_X86_64_PLT32	rt_str_char_at-0x4
    17ca:	test   rax,rax
    17cd:	je     1834 <botlish_fn_11+0x15c>
    17d3:	cmp    rax,0x164
    17d9:	je     18c4 <botlish_fn_11+0x1ec>
    17df:	cmp    rax,0x54
    17e3:	je     1820 <botlish_fn_11+0x148>
    17e9:	mov    rsi,r14
    17ec:	mov    rdi,r12
    17ef:	mov    rdi,r12
    17f2:	call   17f7 <botlish_fn_11+0x11f>
			17f3: R_X86_64_PLT32	botlish_fn_5-0x4 ; chunked_finish<ChunkedBuilder>
    17f7:	test   rax,rax
    17fa:	je     1834 <botlish_fn_11+0x15c>
    1800:	mov    rdx,r13
    1803:	mov    rbx,QWORD PTR [rsp+0x20]
    1808:	mov    r12,QWORD PTR [rsp+0x28]
    180d:	mov    r13,QWORD PTR [rsp+0x30]
    1812:	mov    r14,QWORD PTR [rsp+0x38]
    1817:	add    rsp,0x40
    181b:	mov    rsp,rbp
    181e:	pop    rbp
    181f:	ret
    1820:	mov    rsi,r14
    1823:	mov    rdi,r12
    1826:	call   182b <botlish_fn_11+0x153>
			1827: R_X86_64_PLT32	botlish_fn_5-0x4 ; chunked_finish<ChunkedBuilder>
    182b:	test   rax,rax
    182e:	jne    1857 <botlish_fn_11+0x17f>
    1834:	xor    rdx,rdx
    1837:	mov    rax,rdx
    183a:	mov    rbx,QWORD PTR [rsp+0x20]
    183f:	mov    r12,QWORD PTR [rsp+0x28]
    1844:	mov    r13,QWORD PTR [rsp+0x30]
    1849:	mov    r14,QWORD PTR [rsp+0x38]
    184e:	add    rsp,0x40
    1852:	mov    rsp,rbp
    1855:	pop    rbp
    1856:	ret
    1857:	mov    QWORD PTR [rsp],rax
    185b:	mov    rbx,rax
    185e:	mov    QWORD PTR [rsp+0x8],0x3
    1867:	mov    rdx,r13
    186a:	test   rdx,0x1
    1871:	je     1891 <botlish_fn_11+0x1b9>
    1877:	mov    rdx,r13
    187a:	add    rdx,0x2
    187e:	seto   al
    1881:	test   al,al
    1883:	jne    1891 <botlish_fn_11+0x1b9>
    1889:	mov    rax,rbx
    188c:	jmp    18a7 <botlish_fn_11+0x1cf>
    1891:	mov    edx,0x3
    1896:	mov    rsi,r13
    1899:	mov    rdi,r12
    189c:	call   18a1 <botlish_fn_11+0x1c9>
			189d: R_X86_64_PLT32	rt_int_add-0x4
    18a1:	mov    rdx,rax
    18a4:	mov    rax,rbx
    18a7:	mov    rbx,QWORD PTR [rsp+0x20]
    18ac:	mov    r12,QWORD PTR [rsp+0x28]
    18b1:	mov    r13,QWORD PTR [rsp+0x30]
    18b6:	mov    r14,QWORD PTR [rsp+0x38]
    18bb:	add    rsp,0x40
    18bf:	mov    rsp,rbp
    18c2:	pop    rbp
    18c3:	ret
    18c4:	mov    rsi,r13
    18c7:	mov    edx,0x3
    18cc:	mov    rcx,rdx
    18cf:	mov    QWORD PTR [rsp+0x10],0x3
    18d8:	test   rsi,0x1
    18df:	jne    18ed <botlish_fn_11+0x215>
    18e5:	mov    rdx,rcx
    18e8:	jmp    1902 <botlish_fn_11+0x22a>
    18ed:	mov    rdx,rsi
    18f0:	add    rdx,0x2
    18f4:	seto   al
    18f7:	test   al,al
    18f9:	je     190d <botlish_fn_11+0x235>
    18ff:	mov    rdx,rcx
    1902:	mov    rdi,r12
    1905:	call   190a <botlish_fn_11+0x232>
			1906: R_X86_64_PLT32	rt_int_add-0x4
    190a:	mov    rdx,rax
    190d:	mov    QWORD PTR [rsp],rbx
    1911:	mov    QWORD PTR [rsp+0x8],rdx
    1916:	mov    rsi,r14
    1919:	mov    QWORD PTR [rsp+0x10],rsi
    191e:	mov    r13,rsi
    1921:	jmp    1714 <botlish_fn_11+0x3c>
    1926:	add    BYTE PTR [rax],al
    1928:	(bad)
    1929:	add    BYTE PTR [rax],al
    192b:	add    BYTE PTR [rax],al
    192d:	add    BYTE PTR [rax],al
	...

0000000000001930 <botlish_entry_11: scan_record<str, int, ChunkedBuilder>>:
    1930:	push   rbp
    1931:	mov    rbp,rsp
    1934:	ud2
	...

0000000000001938 <botlish_fn_12: scan_records<str, int, ChunkedBuilder>>:
    1938:	push   rbp
    1939:	mov    rbp,rsp
    193c:	sub    rsp,0x40
    1940:	mov    QWORD PTR [rsp+0x20],rbx
    1945:	mov    QWORD PTR [rsp+0x28],r12
    194a:	mov    QWORD PTR [rsp+0x30],r13
    194f:	mov    QWORD PTR [rsp+0x38],r14
    1954:	mov    r13,rdi
    1957:	mov    QWORD PTR [rsp+0x18],0x0
    1960:	mov    QWORD PTR [rsp],rsi
    1964:	mov    QWORD PTR [rsp+0x8],rdx
    1969:	mov    r12,rdx
    196c:	mov    QWORD PTR [rsp+0x10],rcx
    1971:	mov    rbx,rsi
    1974:	mov    r14,rcx
    1977:	mov    rdx,QWORD PTR [rbx+0x8]
    197b:	shl    rdx,1
    197e:	or     rdx,0x1
    1982:	mov    rax,r12
    1985:	and    rax,rdx
    1988:	test   rax,0x1
    198e:	jne    19b4 <botlish_fn_12+0x7c>
    1994:	mov    rsi,r12
    1997:	mov    rdi,r13
    199a:	call   199f <botlish_fn_12+0x67>
			199b: R_X86_64_PLT32	rt_int_cmp-0x4
    199f:	mov    ecx,0x2
    19a4:	test   rax,rax
    19a7:	cmovge rcx,QWORD PTR [rip+0xe1]        # 1a90 <botlish_fn_12+0x158>
    19af:	jmp    19c7 <botlish_fn_12+0x8f>
    19b4:	mov    ecx,0x2
    19b9:	mov    rax,r12
    19bc:	cmp    rax,rdx
    19bf:	cmovge rcx,QWORD PTR [rip+0xc9]        # 1a90 <botlish_fn_12+0x158>
    19c7:	cmp    rcx,0x6
    19cb:	je     1a3e <botlish_fn_12+0x106>
    19d1:	mov    rdi,r13
    19d4:	call   19d9 <botlish_fn_12+0xa1>
			19d5: R_X86_64_PLT32	botlish_fn_1-0x4 ; chunked_new<generic>
    19d9:	test   rax,rax
    19dc:	je     1a52 <botlish_fn_12+0x11a>
    19e2:	mov    QWORD PTR [rsp+0x18],rax
    19e7:	mov    rcx,rax
    19ea:	mov    rdx,r12
    19ed:	mov    rsi,rbx
    19f0:	mov    rdi,r13
    19f3:	call   19f8 <botlish_fn_12+0xc0>
			19f4: R_X86_64_PLT32	botlish_fn_11-0x4 ; scan_record<str, int, ChunkedBuilder>
    19f8:	test   rax,rax
    19fb:	je     1a52 <botlish_fn_12+0x11a>
    1a01:	mov    QWORD PTR [rsp+0x8],rax
    1a06:	mov    QWORD PTR [rsp+0x18],rdx
    1a0b:	mov    r12,rdx
    1a0e:	mov    rsi,r14
    1a11:	mov    rdx,rax
    1a14:	mov    rdi,r13
    1a17:	call   1a1c <botlish_fn_12+0xe4>
			1a18: R_X86_64_PLT32	botlish_fn_3-0x4 ; chunked_append<ChunkedBuilder, list>
    1a1c:	test   rax,rax
    1a1f:	je     1a52 <botlish_fn_12+0x11a>
    1a25:	mov    QWORD PTR [rsp],rbx
    1a29:	mov    rdx,r12
    1a2c:	mov    QWORD PTR [rsp+0x8],rdx
    1a31:	mov    QWORD PTR [rsp+0x10],rax
    1a36:	mov    r14,rax
    1a39:	jmp    1977 <botlish_fn_12+0x3f>
    1a3e:	mov    rsi,r14
    1a41:	mov    rdi,r13
    1a44:	call   1a49 <botlish_fn_12+0x111>
			1a45: R_X86_64_PLT32	botlish_fn_5-0x4 ; chunked_finish<ChunkedBuilder>
    1a49:	test   rax,rax
    1a4c:	jne    1a72 <botlish_fn_12+0x13a>
    1a52:	xor    rax,rax
    1a55:	mov    rbx,QWORD PTR [rsp+0x20]
    1a5a:	mov    r12,QWORD PTR [rsp+0x28]
    1a5f:	mov    r13,QWORD PTR [rsp+0x30]
    1a64:	mov    r14,QWORD PTR [rsp+0x38]
    1a69:	add    rsp,0x40
    1a6d:	mov    rsp,rbp
    1a70:	pop    rbp
    1a71:	ret
    1a72:	mov    rbx,QWORD PTR [rsp+0x20]
    1a77:	mov    r12,QWORD PTR [rsp+0x28]
    1a7c:	mov    r13,QWORD PTR [rsp+0x30]
    1a81:	mov    r14,QWORD PTR [rsp+0x38]
    1a86:	add    rsp,0x40
    1a8a:	mov    rsp,rbp
    1a8d:	pop    rbp
    1a8e:	ret
    1a8f:	add    BYTE PTR [rsi],al
    1a91:	add    BYTE PTR [rax],al
    1a93:	add    BYTE PTR [rax],al
    1a95:	add    BYTE PTR [rax],al
	...

0000000000001a98 <botlish_entry_12: scan_records<str, int, ChunkedBuilder>>:
    1a98:	push   rbp
    1a99:	mov    rbp,rsp
    1a9c:	mov    rsi,QWORD PTR [rdx]
    1a9f:	mov    r8,QWORD PTR [rdx+0x8]
    1aa3:	mov    rcx,QWORD PTR [rdx+0x10]
    1aa7:	mov    rdx,r8
    1aaa:	call   1aaf <botlish_entry_12+0x17>
			1aab: R_X86_64_PLT32	botlish_fn_12-0x4 ; scan_records<str, int, ChunkedBuilder>
    1aaf:	mov    rsp,rbp
    1ab2:	pop    rbp
    1ab3:	ret

0000000000001ab4 <botlish_fn_13: csv_parse<str>>:
    1ab4:	push   rbp
    1ab5:	mov    rbp,rsp
    1ab8:	sub    rsp,0x30
    1abc:	mov    QWORD PTR [rsp+0x20],r12
    1ac1:	mov    QWORD PTR [rsp+0x28],r13
    1ac6:	mov    r13,rdi
    1ac9:	mov    QWORD PTR [rsp+0x10],0x0
    1ad2:	mov    QWORD PTR [rsp],rsi
    1ad6:	mov    r12,rsi
    1ad9:	mov    QWORD PTR [rsp+0x8],0x1
    1ae2:	mov    rdi,r13
    1ae5:	call   1aea <botlish_fn_13+0x36>
			1ae6: R_X86_64_PLT32	botlish_fn_1-0x4 ; chunked_new<generic>
    1aea:	test   rax,rax
    1aed:	je     1b14 <botlish_fn_13+0x60>
    1af3:	mov    QWORD PTR [rsp+0x10],rax
    1af8:	mov    rcx,rax
    1afb:	mov    edx,0x1
    1b00:	mov    rsi,r12
    1b03:	mov    rdi,r13
    1b06:	call   1b0b <botlish_fn_13+0x57>
			1b07: R_X86_64_PLT32	botlish_fn_12-0x4 ; scan_records<str, int, ChunkedBuilder>
    1b0b:	test   rax,rax
    1b0e:	jne    1b2a <botlish_fn_13+0x76>
    1b14:	xor    rax,rax
    1b17:	mov    r12,QWORD PTR [rsp+0x20]
    1b1c:	mov    r13,QWORD PTR [rsp+0x28]
    1b21:	add    rsp,0x30
    1b25:	mov    rsp,rbp
    1b28:	pop    rbp
    1b29:	ret
    1b2a:	mov    r12,QWORD PTR [rsp+0x20]
    1b2f:	mov    r13,QWORD PTR [rsp+0x28]
    1b34:	add    rsp,0x30
    1b38:	mov    rsp,rbp
    1b3b:	pop    rbp
    1b3c:	ret

0000000000001b3d <botlish_entry_13: csv_parse<str>>:
    1b3d:	push   rbp
    1b3e:	mov    rbp,rsp
    1b41:	mov    rsi,QWORD PTR [rdx]
    1b44:	call   1b49 <botlish_entry_13+0xc>
			1b45: R_X86_64_PLT32	botlish_fn_13-0x4 ; csv_parse<str>
    1b49:	mov    rsp,rbp
    1b4c:	pop    rbp
    1b4d:	ret
