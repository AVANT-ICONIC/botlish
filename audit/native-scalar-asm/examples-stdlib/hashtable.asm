; source:  examples/stdlib/hashtable.bot
; backend: Cranelift (specialize=1), native::object
; object:  ELF64 x86-64, unlinked (Botlish-generated code only; runtime
;          helpers are unresolved imports, so their bodies are not present)
; format:  objdump -dr --no-show-raw-insn -M intel
; total machine code bytes: 10892  (per function: 45 427 385 70 69 69 46 182 228 636 1040 341 261 388 407 616 654 801 673 920 700 925 862 147)
;
; function symbol -> Botlish label:
;   botlish_fn_0 / botlish_entry_0 -> <program entry>
;   botlish_fn_1 / botlish_entry_1 -> ht_alloc<int>
;   botlish_fn_2 / botlish_entry_2 -> ht_alloc<int>
;   botlish_fn_3 / botlish_entry_3 -> ht_new<generic>
;   botlish_fn_4 / botlish_entry_4 -> ht_size<HashTable>
;   botlish_fn_5 / botlish_entry_5 -> ht_tombstones<HashTable>
;   botlish_fn_6 / botlish_entry_6 -> ht_capacity<HashTable>
;   botlish_fn_7 / botlish_entry_7 -> ht_probe_start<HashTable, str>
;   botlish_fn_8 / botlish_entry_8 -> ht_probe_next<HashTable, int>
;   botlish_fn_9 / botlish_entry_9 -> ht_find_get<HashTable, str, int>
;   botlish_fn_10 / botlish_entry_10 -> ht_find_insert<HashTable, str, int, int>
;   botlish_fn_11 / botlish_entry_11 -> ht_get<HashTable, str>
;   botlish_fn_12 / botlish_entry_12 -> ht_contains<HashTable, str>
;   botlish_fn_13 / botlish_entry_13 -> ht_rehash_probe<mutarray, int, int>
;   botlish_fn_14 / botlish_entry_14 -> ht_rehash_insert<HashTable, int, any, any>
;   botlish_fn_15 / botlish_entry_15 -> ht_rehash_scan<mutarray, mutarray, mutarray, int, int, HashTable, int>
;   botlish_fn_16 / botlish_entry_16 -> ht_rehash<HashTable, int>
;   botlish_fn_17 / botlish_entry_17 -> ht_should_grow<HashTable>
;   botlish_fn_18 / botlish_entry_18 -> ht_grow_or_clean<HashTable>
;   botlish_fn_19 / botlish_entry_19 -> ht_place<HashTable, int, str, str>
;   botlish_fn_20 / botlish_entry_20 -> ht_set<HashTable, str, str>
;   botlish_fn_21 / botlish_entry_21 -> ht_delete<HashTable, str>
;   botlish_fn_22 / botlish_entry_22 -> sample_checks<generic>
;   botlish_fn_23 / botlish_entry_23 -> sample<generic>


hashtable.asm.o:     file format elf64-x86-64


Disassembly of section .text:

0000000000000000 <botlish_fn_0: <program entry>>:
       0:	push   rbp
       1:	mov    rbp,rsp
       4:	call   9 <botlish_fn_0+0x9>
			5: R_X86_64_PLT32	botlish_fn_23-0x4 ; sample<generic>
       9:	test   rax,rax
       c:	jne    1a <botlish_fn_0+0x1a>
      12:	xor    rax,rax
      15:	mov    rsp,rbp
      18:	pop    rbp
      19:	ret
      1a:	mov    rsp,rbp
      1d:	pop    rbp
      1e:	ret

000000000000001f <botlish_entry_0: <program entry>>:
      1f:	push   rbp
      20:	mov    rbp,rsp
      23:	call   28 <botlish_entry_0+0x9>
			24: R_X86_64_PLT32	botlish_fn_0-0x4 ; <program entry>
      28:	mov    rsp,rbp
      2b:	pop    rbp
      2c:	ret

000000000000002d <botlish_fn_1: ht_alloc<int>>:
      2d:	push   rbp
      2e:	mov    rbp,rsp
      31:	sub    rsp,0x70
      35:	mov    QWORD PTR [rsp+0x40],rbx
      3a:	mov    QWORD PTR [rsp+0x48],r12
      3f:	mov    QWORD PTR [rsp+0x50],r13
      44:	mov    QWORD PTR [rsp+0x58],r14
      49:	mov    QWORD PTR [rsp+0x60],r15
      4e:	mov    r12,rdi
      51:	mov    QWORD PTR [rsp+0x10],0x0
      5a:	mov    QWORD PTR [rsp+0x18],0x0
      63:	mov    QWORD PTR [rsp],rsi
      67:	mov    r13,rsi
      6a:	mov    esi,0x5
      6f:	mov    QWORD PTR [rsp+0x8],0x5
      78:	mov    rdi,r12
      7b:	call   80 <botlish_fn_1+0x53>
			7c: R_X86_64_PLT32	rt_mutarray_allocate-0x4
      80:	mov    rcx,rax
      83:	mov    r14,rax
      86:	test   rax,rcx
      89:	je     118 <botlish_fn_1+0xeb>
      8f:	mov    rax,r14
      92:	mov    QWORD PTR [rsp+0x8],rax
      97:	mov    ebx,0x1
      9c:	mov    rcx,rbx
      9f:	mov    rdx,rbx
      a2:	mov    rsi,r14
      a5:	mov    rdi,r12
      a8:	call   ad <botlish_fn_1+0x80>
			a9: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
      ad:	mov    edx,0x3
      b2:	mov    rcx,rbx
      b5:	mov    rsi,r14
      b8:	mov    rdi,r12
      bb:	call   c0 <botlish_fn_1+0x93>
			bc: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
      c0:	mov    QWORD PTR [rsp+0x10],0x1
      c9:	mov    rdx,rbx
      cc:	mov    rsi,r13
      cf:	mov    rdi,r12
      d2:	call   d7 <botlish_fn_1+0xaa>
			d3: R_X86_64_PLT32	rt_mutarray_create-0x4
      d7:	test   rax,rax
      da:	je     118 <botlish_fn_1+0xeb>
      e0:	mov    QWORD PTR [rsp+0x10],rax
      e5:	mov    rbx,rax
      e8:	mov    rsi,r13
      eb:	mov    rdi,r12
      ee:	call   f3 <botlish_fn_1+0xc6>
			ef: R_X86_64_PLT32	rt_mutarray_allocate-0x4
      f3:	test   rax,rax
      f6:	je     118 <botlish_fn_1+0xeb>
      fc:	mov    QWORD PTR [rsp+0x18],rax
     101:	mov    rsi,r13
     104:	mov    r15,rax
     107:	mov    rdi,r12
     10a:	call   10f <botlish_fn_1+0xe2>
			10b: R_X86_64_PLT32	rt_mutarray_allocate-0x4
     10f:	test   rax,rax
     112:	jne    13d <botlish_fn_1+0x110>
     118:	xor    rax,rax
     11b:	mov    rbx,QWORD PTR [rsp+0x40]
     120:	mov    r12,QWORD PTR [rsp+0x48]
     125:	mov    r13,QWORD PTR [rsp+0x50]
     12a:	mov    r14,QWORD PTR [rsp+0x58]
     12f:	mov    r15,QWORD PTR [rsp+0x60]
     134:	add    rsp,0x70
     138:	mov    rsp,rbp
     13b:	pop    rbp
     13c:	ret
     13d:	mov    QWORD PTR [rsp],rax
     141:	lea    rcx,[rsp+0x20]
     146:	mov    rdx,rbx
     149:	mov    QWORD PTR [rsp+0x20],rdx
     14e:	mov    rsi,r15
     151:	mov    QWORD PTR [rsp+0x28],rsi
     156:	mov    QWORD PTR [rsp+0x30],rax
     15b:	mov    rax,r14
     15e:	mov    QWORD PTR [rsp+0x38],rax
     163:	xor    rsi,rsi
     166:	mov    edx,0x4
     16b:	mov    rdi,r12
     16e:	call   173 <botlish_fn_1+0x146>
			16f: R_X86_64_PLT32	rt_struct_new-0x4
     173:	mov    rbx,QWORD PTR [rsp+0x40]
     178:	mov    r12,QWORD PTR [rsp+0x48]
     17d:	mov    r13,QWORD PTR [rsp+0x50]
     182:	mov    r14,QWORD PTR [rsp+0x58]
     187:	mov    r15,QWORD PTR [rsp+0x60]
     18c:	add    rsp,0x70
     190:	mov    rsp,rbp
     193:	pop    rbp
     194:	ret

0000000000000195 <botlish_entry_1: ht_alloc<int>>:
     195:	push   rbp
     196:	mov    rbp,rsp
     199:	mov    rsi,QWORD PTR [rdx]
     19c:	call   1a1 <botlish_entry_1+0xc>
			19d: R_X86_64_PLT32	botlish_fn_1-0x4 ; ht_alloc<int>
     1a1:	mov    rsp,rbp
     1a4:	pop    rbp
     1a5:	ret

00000000000001a6 <botlish_fn_2: ht_alloc<int>>:
     1a6:	push   rbp
     1a7:	mov    rbp,rsp
     1aa:	sub    rsp,0x60
     1ae:	mov    QWORD PTR [rsp+0x30],rbx
     1b3:	mov    QWORD PTR [rsp+0x38],r12
     1b8:	mov    QWORD PTR [rsp+0x40],r13
     1bd:	mov    QWORD PTR [rsp+0x48],r14
     1c2:	mov    QWORD PTR [rsp+0x50],r15
     1c7:	mov    r13,rdi
     1ca:	mov    r15,rdx
     1cd:	mov    QWORD PTR [rsp+0x10],0x0
     1d6:	mov    QWORD PTR [rsp+0x18],0x0
     1df:	mov    QWORD PTR [rsp],rsi
     1e3:	mov    r12,rsi
     1e6:	mov    esi,0x5
     1eb:	mov    QWORD PTR [rsp+0x8],0x5
     1f4:	mov    rdi,r13
     1f7:	call   1fc <botlish_fn_2+0x56>
			1f8: R_X86_64_PLT32	rt_mutarray_allocate-0x4
     1fc:	mov    rcx,rax
     1ff:	mov    r14,rax
     202:	test   rax,rcx
     205:	je     296 <botlish_fn_2+0xf0>
     20b:	mov    rax,r14
     20e:	mov    QWORD PTR [rsp+0x8],rax
     213:	mov    ebx,0x1
     218:	mov    rcx,rbx
     21b:	mov    rdx,rbx
     21e:	mov    rsi,r14
     221:	mov    rdi,r13
     224:	call   229 <botlish_fn_2+0x83>
			225: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
     229:	mov    edx,0x3
     22e:	mov    rcx,rbx
     231:	mov    rsi,r14
     234:	mov    rdi,r13
     237:	call   23c <botlish_fn_2+0x96>
			238: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
     23c:	mov    QWORD PTR [rsp+0x10],0x1
     245:	mov    rdx,rbx
     248:	mov    rsi,r12
     24b:	mov    rdi,r13
     24e:	call   253 <botlish_fn_2+0xad>
			24f: R_X86_64_PLT32	rt_mutarray_create-0x4
     253:	test   rax,rax
     256:	je     296 <botlish_fn_2+0xf0>
     25c:	mov    QWORD PTR [rsp+0x10],rax
     261:	mov    rbx,rax
     264:	mov    rsi,r12
     267:	mov    rdi,r13
     26a:	call   26f <botlish_fn_2+0xc9>
			26b: R_X86_64_PLT32	rt_mutarray_allocate-0x4
     26f:	test   rax,rax
     272:	je     296 <botlish_fn_2+0xf0>
     278:	mov    QWORD PTR [rsp+0x18],rax
     27d:	mov    rsi,r12
     280:	mov    rdi,r13
     283:	mov    QWORD PTR [rsp+0x20],rax
     288:	call   28d <botlish_fn_2+0xe7>
			289: R_X86_64_PLT32	rt_mutarray_allocate-0x4
     28d:	test   rax,rax
     290:	jne    2bb <botlish_fn_2+0x115>
     296:	xor    rax,rax
     299:	mov    rbx,QWORD PTR [rsp+0x30]
     29e:	mov    r12,QWORD PTR [rsp+0x38]
     2a3:	mov    r13,QWORD PTR [rsp+0x40]
     2a8:	mov    r14,QWORD PTR [rsp+0x48]
     2ad:	mov    r15,QWORD PTR [rsp+0x50]
     2b2:	add    rsp,0x60
     2b6:	mov    rsp,rbp
     2b9:	pop    rbp
     2ba:	ret
     2bb:	mov    rcx,QWORD PTR [rsp+0x20]
     2c0:	mov    rdx,r15
     2c3:	mov    QWORD PTR [rdx],rcx
     2c6:	mov    QWORD PTR [rdx+0x8],rax
     2ca:	mov    rax,r14
     2cd:	mov    QWORD PTR [rdx+0x10],rax
     2d1:	mov    rax,rbx
     2d4:	mov    rbx,QWORD PTR [rsp+0x30]
     2d9:	mov    r12,QWORD PTR [rsp+0x38]
     2de:	mov    r13,QWORD PTR [rsp+0x40]
     2e3:	mov    r14,QWORD PTR [rsp+0x48]
     2e8:	mov    r15,QWORD PTR [rsp+0x50]
     2ed:	add    rsp,0x60
     2f1:	mov    rsp,rbp
     2f4:	pop    rbp
     2f5:	ret

00000000000002f6 <botlish_entry_2: ht_alloc<int>>:
     2f6:	push   rbp
     2f7:	mov    rbp,rsp
     2fa:	ud2

00000000000002fc <botlish_fn_3: ht_new<generic>>:
     2fc:	push   rbp
     2fd:	mov    rbp,rsp
     300:	sub    rsp,0x10
     304:	mov    esi,0x11
     309:	mov    QWORD PTR [rsp],0x11
     311:	call   316 <botlish_fn_3+0x1a>
			312: R_X86_64_PLT32	botlish_fn_1-0x4 ; ht_alloc<int>
     316:	test   rax,rax
     319:	jne    32b <botlish_fn_3+0x2f>
     31f:	xor    rax,rax
     322:	add    rsp,0x10
     326:	mov    rsp,rbp
     329:	pop    rbp
     32a:	ret
     32b:	add    rsp,0x10
     32f:	mov    rsp,rbp
     332:	pop    rbp
     333:	ret

0000000000000334 <botlish_entry_3: ht_new<generic>>:
     334:	push   rbp
     335:	mov    rbp,rsp
     338:	call   33d <botlish_entry_3+0x9>
			339: R_X86_64_PLT32	botlish_fn_3-0x4 ; ht_new<generic>
     33d:	mov    rsp,rbp
     340:	pop    rbp
     341:	ret

0000000000000342 <botlish_fn_4: ht_size<HashTable>>:
     342:	push   rbp
     343:	mov    rbp,rsp
     346:	mov    r9,QWORD PTR [rsi+0x18]
     34a:	mov    rsi,QWORD PTR [r9+0x18]
     34e:	mov    edx,0x1
     353:	call   358 <botlish_fn_4+0x16>
			354: R_X86_64_PLT32	rt_mutarray_get-0x4
     358:	test   rax,rax
     35b:	jne    369 <botlish_fn_4+0x27>
     361:	xor    rax,rax
     364:	mov    rsp,rbp
     367:	pop    rbp
     368:	ret
     369:	mov    rsp,rbp
     36c:	pop    rbp
     36d:	ret

000000000000036e <botlish_entry_4: ht_size<HashTable>>:
     36e:	push   rbp
     36f:	mov    rbp,rsp
     372:	mov    rsi,QWORD PTR [rdx]
     375:	call   37a <botlish_entry_4+0xc>
			376: R_X86_64_PLT32	botlish_fn_4-0x4 ; ht_size<HashTable>
     37a:	mov    rsp,rbp
     37d:	pop    rbp
     37e:	ret

000000000000037f <botlish_fn_5: ht_tombstones<HashTable>>:
     37f:	push   rbp
     380:	mov    rbp,rsp
     383:	mov    r9,QWORD PTR [rsi+0x18]
     387:	mov    rsi,QWORD PTR [r9+0x18]
     38b:	mov    edx,0x3
     390:	call   395 <botlish_fn_5+0x16>
			391: R_X86_64_PLT32	rt_mutarray_get-0x4
     395:	test   rax,rax
     398:	jne    3a6 <botlish_fn_5+0x27>
     39e:	xor    rax,rax
     3a1:	mov    rsp,rbp
     3a4:	pop    rbp
     3a5:	ret
     3a6:	mov    rsp,rbp
     3a9:	pop    rbp
     3aa:	ret

00000000000003ab <botlish_entry_5: ht_tombstones<HashTable>>:
     3ab:	push   rbp
     3ac:	mov    rbp,rsp
     3af:	mov    rsi,QWORD PTR [rdx]
     3b2:	call   3b7 <botlish_entry_5+0xc>
			3b3: R_X86_64_PLT32	botlish_fn_5-0x4 ; ht_tombstones<HashTable>
     3b7:	mov    rsp,rbp
     3ba:	pop    rbp
     3bb:	ret

00000000000003bc <botlish_fn_6: ht_capacity<HashTable>>:
     3bc:	push   rbp
     3bd:	mov    rbp,rsp
     3c0:	mov    rsi,QWORD PTR [rsi+0x18]
     3c4:	mov    rsi,QWORD PTR [rsi]
     3c7:	call   3cc <botlish_fn_6+0x10>
			3c8: R_X86_64_PLT32	rt_mutarray_capacity-0x4
     3cc:	mov    rsp,rbp
     3cf:	pop    rbp
     3d0:	ret

00000000000003d1 <botlish_entry_6: ht_capacity<HashTable>>:
     3d1:	push   rbp
     3d2:	mov    rbp,rsp
     3d5:	mov    rsi,QWORD PTR [rdx]
     3d8:	call   3dd <botlish_entry_6+0xc>
			3d9: R_X86_64_PLT32	botlish_fn_6-0x4 ; ht_capacity<HashTable>
     3dd:	mov    rsp,rbp
     3e0:	pop    rbp
     3e1:	ret

00000000000003e2 <botlish_fn_7: ht_probe_start<HashTable, str>>:
     3e2:	push   rbp
     3e3:	mov    rbp,rsp
     3e6:	sub    rsp,0x30
     3ea:	mov    QWORD PTR [rsp+0x10],r12
     3ef:	mov    QWORD PTR [rsp+0x18],r13
     3f4:	mov    QWORD PTR [rsp+0x20],r14
     3f9:	mov    r12,rdi
     3fc:	mov    r14,rsi
     3ff:	mov    rsi,rdx
     402:	mov    rdi,r12
     405:	call   40a <botlish_fn_7+0x28>
			406: R_X86_64_PLT32	rt_hash-0x4
     40a:	test   rax,rax
     40d:	je     441 <botlish_fn_7+0x5f>
     413:	mov    QWORD PTR [rsp],rax
     417:	mov    rsi,r14
     41a:	mov    r13,rax
     41d:	mov    rdi,r12
     420:	call   425 <botlish_fn_7+0x43>
			421: R_X86_64_PLT32	botlish_fn_6-0x4 ; ht_capacity<HashTable>
     425:	mov    QWORD PTR [rsp+0x8],rax
     42a:	mov    rdx,rax
     42d:	mov    rsi,r13
     430:	mov    rdi,r12
     433:	call   438 <botlish_fn_7+0x56>
			434: R_X86_64_PLT32	rt_int_mod-0x4
     438:	test   rax,rax
     43b:	jne    45c <botlish_fn_7+0x7a>
     441:	xor    rax,rax
     444:	mov    r12,QWORD PTR [rsp+0x10]
     449:	mov    r13,QWORD PTR [rsp+0x18]
     44e:	mov    r14,QWORD PTR [rsp+0x20]
     453:	add    rsp,0x30
     457:	mov    rsp,rbp
     45a:	pop    rbp
     45b:	ret
     45c:	mov    r12,QWORD PTR [rsp+0x10]
     461:	mov    r13,QWORD PTR [rsp+0x18]
     466:	mov    r14,QWORD PTR [rsp+0x20]
     46b:	add    rsp,0x30
     46f:	mov    rsp,rbp
     472:	pop    rbp
     473:	ret

0000000000000474 <botlish_entry_7: ht_probe_start<HashTable, str>>:
     474:	push   rbp
     475:	mov    rbp,rsp
     478:	mov    rsi,QWORD PTR [rdx]
     47b:	mov    rdx,QWORD PTR [rdx+0x8]
     47f:	call   484 <botlish_entry_7+0x10>
			480: R_X86_64_PLT32	botlish_fn_7-0x4 ; ht_probe_start<HashTable, str>
     484:	mov    rsp,rbp
     487:	pop    rbp
     488:	ret

0000000000000489 <botlish_fn_8: ht_probe_next<HashTable, int>>:
     489:	push   rbp
     48a:	mov    rbp,rsp
     48d:	sub    rsp,0x30
     491:	mov    QWORD PTR [rsp+0x20],rbx
     496:	mov    QWORD PTR [rsp+0x28],r14
     49b:	mov    r14,rdi
     49e:	mov    QWORD PTR [rsp],rsi
     4a2:	mov    rbx,rsi
     4a5:	mov    QWORD PTR [rsp+0x8],rdx
     4aa:	mov    QWORD PTR [rsp+0x10],0x3
     4b3:	test   rdx,0x1
     4ba:	jne    4c8 <botlish_fn_8+0x3f>
     4c0:	mov    rcx,rdx
     4c3:	jmp    4dd <botlish_fn_8+0x54>
     4c8:	mov    rsi,rdx
     4cb:	add    rsi,0x2
     4cf:	mov    rcx,rdx
     4d2:	seto   al
     4d5:	test   al,al
     4d7:	je     4f0 <botlish_fn_8+0x67>
     4dd:	mov    edx,0x3
     4e2:	mov    rsi,rcx
     4e5:	mov    rdi,r14
     4e8:	call   4ed <botlish_fn_8+0x64>
			4e9: R_X86_64_PLT32	rt_int_add-0x4
     4ed:	mov    rsi,rax
     4f0:	mov    QWORD PTR [rsp],rsi
     4f4:	mov    rax,rbx
     4f7:	mov    rbx,rsi
     4fa:	mov    rsi,rax
     4fd:	mov    rdi,r14
     500:	call   505 <botlish_fn_8+0x7c>
			501: R_X86_64_PLT32	botlish_fn_6-0x4 ; ht_capacity<HashTable>
     505:	mov    QWORD PTR [rsp+0x8],rax
     50a:	mov    rdx,rax
     50d:	mov    rsi,rbx
     510:	mov    rdi,r14
     513:	call   518 <botlish_fn_8+0x8f>
			514: R_X86_64_PLT32	rt_int_mod-0x4
     518:	test   rax,rax
     51b:	jne    537 <botlish_fn_8+0xae>
     521:	xor    rax,rax
     524:	mov    rbx,QWORD PTR [rsp+0x20]
     529:	mov    r14,QWORD PTR [rsp+0x28]
     52e:	add    rsp,0x30
     532:	mov    rsp,rbp
     535:	pop    rbp
     536:	ret
     537:	mov    rbx,QWORD PTR [rsp+0x20]
     53c:	mov    r14,QWORD PTR [rsp+0x28]
     541:	add    rsp,0x30
     545:	mov    rsp,rbp
     548:	pop    rbp
     549:	ret

000000000000054a <botlish_entry_8: ht_probe_next<HashTable, int>>:
     54a:	push   rbp
     54b:	mov    rbp,rsp
     54e:	mov    rsi,QWORD PTR [rdx]
     551:	mov    rdx,QWORD PTR [rdx+0x8]
     555:	call   55a <botlish_entry_8+0x10>
			556: R_X86_64_PLT32	botlish_fn_8-0x4 ; ht_probe_next<HashTable, int>
     55a:	mov    rsp,rbp
     55d:	pop    rbp
     55e:	ret
	...

0000000000000560 <botlish_fn_9: ht_find_get<HashTable, str, int>>:
     560:	push   rbp
     561:	mov    rbp,rsp
     564:	sub    rsp,0x50
     568:	mov    QWORD PTR [rsp+0x20],rbx
     56d:	mov    QWORD PTR [rsp+0x28],r12
     572:	mov    QWORD PTR [rsp+0x30],r13
     577:	mov    QWORD PTR [rsp+0x38],r14
     57c:	mov    QWORD PTR [rsp+0x40],r15
     581:	mov    r13,rdi
     584:	mov    QWORD PTR [rsp],rsi
     588:	mov    QWORD PTR [rsp+0x8],rdx
     58d:	mov    rbx,rdx
     590:	mov    QWORD PTR [rsp+0x10],rcx
     595:	mov    r12,rsi
     598:	mov    r14,rcx
     59b:	mov    rax,QWORD PTR [r12+0x18]
     5a0:	mov    rsi,QWORD PTR [rax]
     5a3:	mov    rdx,r14
     5a6:	mov    rdi,r13
     5a9:	call   5ae <botlish_fn_9+0x4e>
			5aa: R_X86_64_PLT32	rt_mutarray_get-0x4
     5ae:	mov    rcx,rax
     5b1:	mov    r15,rax
     5b4:	test   rax,rcx
     5b7:	je     707 <botlish_fn_9+0x1a7>
     5bd:	mov    rax,r15
     5c0:	test   rax,0x1
     5c6:	jne    5f4 <botlish_fn_9+0x94>
     5cc:	mov    edx,0x1
     5d1:	mov    rsi,r15
     5d4:	mov    rdi,r13
     5d7:	call   5dc <botlish_fn_9+0x7c>
			5d8: R_X86_64_PLT32	rt_int_cmp-0x4
     5dc:	mov    ecx,0x2
     5e1:	test   rax,rax
     5e4:	cmove  rcx,QWORD PTR [rip+0x1a4]        # 790 <botlish_fn_9+0x230>
     5ec:	mov    rax,r15
     5ef:	jmp    608 <botlish_fn_9+0xa8>
     5f4:	mov    ecx,0x2
     5f9:	mov    rax,r15
     5fc:	cmp    rax,0x1
     600:	cmove  rcx,QWORD PTR [rip+0x188]        # 790 <botlish_fn_9+0x230>
     608:	cmp    rcx,0x6
     60c:	je     767 <botlish_fn_9+0x207>
     612:	test   rax,0x1
     618:	mov    r15,rax
     61b:	jne    646 <botlish_fn_9+0xe6>
     621:	mov    edx,0x3
     626:	mov    rsi,r15
     629:	mov    rdi,r13
     62c:	call   631 <botlish_fn_9+0xd1>
			62d: R_X86_64_PLT32	rt_int_cmp-0x4
     631:	mov    ecx,0x2
     636:	test   rax,rax
     639:	cmove  rcx,QWORD PTR [rip+0x14f]        # 790 <botlish_fn_9+0x230>
     641:	jmp    65a <botlish_fn_9+0xfa>
     646:	mov    rsi,r15
     649:	mov    ecx,0x2
     64e:	cmp    rsi,0x3
     652:	cmove  rcx,QWORD PTR [rip+0x136]        # 790 <botlish_fn_9+0x230>
     65a:	cmp    rcx,0x6
     65e:	je     66e <botlish_fn_9+0x10e>
     664:	mov    eax,0x2
     669:	jmp    6e6 <botlish_fn_9+0x186>
     66e:	mov    rcx,QWORD PTR [r12+0x18]
     673:	mov    rsi,QWORD PTR [rcx+0x8]
     677:	mov    rdx,r14
     67a:	mov    rdi,r13
     67d:	call   682 <botlish_fn_9+0x122>
			67e: R_X86_64_PLT32	rt_mutarray_get-0x4
     682:	test   rax,rax
     685:	je     707 <botlish_fn_9+0x1a7>
     68b:	mov    rsi,rax
     68e:	and    rsi,rbx
     691:	test   rsi,0x1
     698:	jne    6ba <botlish_fn_9+0x15a>
     69e:	mov    rsi,rax
     6a1:	mov    rdx,rbx
     6a4:	mov    rdi,r13
     6a7:	call   6ac <botlish_fn_9+0x14c>
			6a8: R_X86_64_PLT32	rt_value_eq-0x4
     6ac:	test   rax,rax
     6af:	je     707 <botlish_fn_9+0x1a7>
     6b5:	jmp    6cd <botlish_fn_9+0x16d>
     6ba:	mov    rsi,rax
     6bd:	mov    eax,0x2
     6c2:	cmp    rsi,rbx
     6c5:	cmove  rax,QWORD PTR [rip+0xc3]        # 790 <botlish_fn_9+0x230>
     6cd:	cmp    rax,0x6
     6d1:	je     6e1 <botlish_fn_9+0x181>
     6d7:	mov    eax,0x2
     6dc:	jmp    6e6 <botlish_fn_9+0x186>
     6e1:	mov    eax,0x6
     6e6:	cmp    rax,0x6
     6ea:	je     742 <botlish_fn_9+0x1e2>
     6f0:	mov    rdx,r14
     6f3:	mov    rsi,r12
     6f6:	mov    rdi,r13
     6f9:	call   6fe <botlish_fn_9+0x19e>
			6fa: R_X86_64_PLT32	botlish_fn_8-0x4 ; ht_probe_next<HashTable, int>
     6fe:	test   rax,rax
     701:	jne    72c <botlish_fn_9+0x1cc>
     707:	xor    rax,rax
     70a:	mov    rbx,QWORD PTR [rsp+0x20]
     70f:	mov    r12,QWORD PTR [rsp+0x28]
     714:	mov    r13,QWORD PTR [rsp+0x30]
     719:	mov    r14,QWORD PTR [rsp+0x38]
     71e:	mov    r15,QWORD PTR [rsp+0x40]
     723:	add    rsp,0x50
     727:	mov    rsp,rbp
     72a:	pop    rbp
     72b:	ret
     72c:	mov    QWORD PTR [rsp],r12
     730:	mov    QWORD PTR [rsp+0x8],rbx
     735:	mov    QWORD PTR [rsp+0x10],rax
     73a:	mov    r14,rax
     73d:	jmp    59b <botlish_fn_9+0x3b>
     742:	mov    rax,r14
     745:	mov    rbx,QWORD PTR [rsp+0x20]
     74a:	mov    r12,QWORD PTR [rsp+0x28]
     74f:	mov    r13,QWORD PTR [rsp+0x30]
     754:	mov    r14,QWORD PTR [rsp+0x38]
     759:	mov    r15,QWORD PTR [rsp+0x40]
     75e:	add    rsp,0x50
     762:	mov    rsp,rbp
     765:	pop    rbp
     766:	ret
     767:	mov    rax,0xffffffffffffffff
     76e:	mov    rbx,QWORD PTR [rsp+0x20]
     773:	mov    r12,QWORD PTR [rsp+0x28]
     778:	mov    r13,QWORD PTR [rsp+0x30]
     77d:	mov    r14,QWORD PTR [rsp+0x38]
     782:	mov    r15,QWORD PTR [rsp+0x40]
     787:	add    rsp,0x50
     78b:	mov    rsp,rbp
     78e:	pop    rbp
     78f:	ret
     790:	(bad)
     791:	add    BYTE PTR [rax],al
     793:	add    BYTE PTR [rax],al
     795:	add    BYTE PTR [rax],al
	...

0000000000000798 <botlish_entry_9: ht_find_get<HashTable, str, int>>:
     798:	push   rbp
     799:	mov    rbp,rsp
     79c:	mov    rsi,QWORD PTR [rdx]
     79f:	mov    r8,QWORD PTR [rdx+0x8]
     7a3:	mov    rcx,QWORD PTR [rdx+0x10]
     7a7:	mov    rdx,r8
     7aa:	call   7af <botlish_entry_9+0x17>
			7ab: R_X86_64_PLT32	botlish_fn_9-0x4 ; ht_find_get<HashTable, str, int>
     7af:	mov    rsp,rbp
     7b2:	pop    rbp
     7b3:	ret
     7b4:	add    BYTE PTR [rax],al
	...

00000000000007b8 <botlish_fn_10: ht_find_insert<HashTable, str, int, int>>:
     7b8:	push   rbp
     7b9:	mov    rbp,rsp
     7bc:	sub    rsp,0x60
     7c0:	mov    QWORD PTR [rsp+0x30],rbx
     7c5:	mov    QWORD PTR [rsp+0x38],r12
     7ca:	mov    QWORD PTR [rsp+0x40],r13
     7cf:	mov    QWORD PTR [rsp+0x48],r14
     7d4:	mov    QWORD PTR [rsp+0x50],r15
     7d9:	mov    r15,rdi
     7dc:	mov    QWORD PTR [rsp],rsi
     7e0:	mov    QWORD PTR [rsp+0x8],rdx
     7e5:	mov    r12,rdx
     7e8:	mov    QWORD PTR [rsp+0x10],rcx
     7ed:	mov    QWORD PTR [rsp+0x18],r8
     7f2:	mov    rbx,rsi
     7f5:	mov    r14,rcx
     7f8:	mov    QWORD PTR [rsp+0x20],r8
     7fd:	mov    r10,QWORD PTR [rbx+0x18]
     801:	mov    rsi,QWORD PTR [r10]
     804:	mov    rdx,r14
     807:	mov    rdi,r15
     80a:	call   80f <botlish_fn_10+0x57>
			80b: R_X86_64_PLT32	rt_mutarray_get-0x4
     80f:	mov    rcx,rax
     812:	mov    r13,rax
     815:	test   rax,rcx
     818:	je     a68 <botlish_fn_10+0x2b0>
     81e:	mov    rax,r13
     821:	test   rax,0x1
     827:	jne    852 <botlish_fn_10+0x9a>
     82d:	mov    edx,0x1
     832:	mov    rsi,r13
     835:	mov    rdi,r15
     838:	call   83d <botlish_fn_10+0x85>
			839: R_X86_64_PLT32	rt_int_cmp-0x4
     83d:	mov    ecx,0x2
     842:	test   rax,rax
     845:	cmove  rcx,QWORD PTR [rip+0x313]        # b60 <botlish_fn_10+0x3a8>
     84d:	jmp    866 <botlish_fn_10+0xae>
     852:	mov    ecx,0x2
     857:	mov    rax,r13
     85a:	cmp    rax,0x1
     85e:	cmove  rcx,QWORD PTR [rip+0x2fa]        # b60 <botlish_fn_10+0x3a8>
     866:	cmp    rcx,0x6
     86a:	je     ab8 <botlish_fn_10+0x300>
     870:	mov    rax,r13
     873:	test   rax,0x1
     879:	jne    8a4 <botlish_fn_10+0xec>
     87f:	mov    edx,0x3
     884:	mov    rsi,r13
     887:	mov    rdi,r15
     88a:	call   88f <botlish_fn_10+0xd7>
			88b: R_X86_64_PLT32	rt_int_cmp-0x4
     88f:	mov    ecx,0x2
     894:	test   rax,rax
     897:	cmove  rcx,QWORD PTR [rip+0x2c1]        # b60 <botlish_fn_10+0x3a8>
     89f:	jmp    8b8 <botlish_fn_10+0x100>
     8a4:	mov    ecx,0x2
     8a9:	mov    rax,r13
     8ac:	cmp    rax,0x3
     8b0:	cmove  rcx,QWORD PTR [rip+0x2a8]        # b60 <botlish_fn_10+0x3a8>
     8b8:	cmp    rcx,0x6
     8bc:	je     8cc <botlish_fn_10+0x114>
     8c2:	mov    eax,0x2
     8c7:	jmp    940 <botlish_fn_10+0x188>
     8cc:	mov    rax,QWORD PTR [rbx+0x18]
     8d0:	mov    rsi,QWORD PTR [rax+0x8]
     8d4:	mov    rdx,r14
     8d7:	mov    rdi,r15
     8da:	call   8df <botlish_fn_10+0x127>
			8db: R_X86_64_PLT32	rt_mutarray_get-0x4
     8df:	test   rax,rax
     8e2:	je     a68 <botlish_fn_10+0x2b0>
     8e8:	mov    rcx,rax
     8eb:	and    rcx,r12
     8ee:	mov    rsi,rax
     8f1:	test   rcx,0x1
     8f8:	jne    917 <botlish_fn_10+0x15f>
     8fe:	mov    rdx,r12
     901:	mov    rdi,r15
     904:	call   909 <botlish_fn_10+0x151>
			905: R_X86_64_PLT32	rt_value_eq-0x4
     909:	test   rax,rax
     90c:	je     a68 <botlish_fn_10+0x2b0>
     912:	jmp    927 <botlish_fn_10+0x16f>
     917:	mov    eax,0x2
     91c:	cmp    rsi,r12
     91f:	cmove  rax,QWORD PTR [rip+0x239]        # b60 <botlish_fn_10+0x3a8>
     927:	cmp    rax,0x6
     92b:	je     93b <botlish_fn_10+0x183>
     931:	mov    eax,0x2
     936:	jmp    940 <botlish_fn_10+0x188>
     93b:	mov    eax,0x6
     940:	cmp    rax,0x6
     944:	je     ab0 <botlish_fn_10+0x2f8>
     94a:	mov    rax,r13
     94d:	test   rax,0x1
     953:	jne    97e <botlish_fn_10+0x1c6>
     959:	mov    edx,0x5
     95e:	mov    rsi,r13
     961:	mov    rdi,r15
     964:	call   969 <botlish_fn_10+0x1b1>
			965: R_X86_64_PLT32	rt_int_cmp-0x4
     969:	mov    ecx,0x2
     96e:	test   rax,rax
     971:	cmove  rcx,QWORD PTR [rip+0x1e7]        # b60 <botlish_fn_10+0x3a8>
     979:	jmp    992 <botlish_fn_10+0x1da>
     97e:	mov    rsi,r13
     981:	mov    ecx,0x2
     986:	cmp    rsi,0x5
     98a:	cmove  rcx,QWORD PTR [rip+0x1ce]        # b60 <botlish_fn_10+0x3a8>
     992:	cmp    rcx,0x6
     996:	je     9a6 <botlish_fn_10+0x1ee>
     99c:	mov    eax,0x2
     9a1:	jmp    a10 <botlish_fn_10+0x258>
     9a6:	mov    r13,QWORD PTR [rsp+0x20]
     9ab:	test   r13,0x1
     9b2:	jne    9e2 <botlish_fn_10+0x22a>
     9b8:	mov    edx,0x1
     9bd:	mov    rsi,r13
     9c0:	mov    rdi,r15
     9c3:	call   9c8 <botlish_fn_10+0x210>
			9c4: R_X86_64_PLT32	rt_int_cmp-0x4
     9c8:	mov    ecx,0x2
     9cd:	test   rax,rax
     9d0:	cmovl  rcx,QWORD PTR [rip+0x188]        # b60 <botlish_fn_10+0x3a8>
     9d8:	mov    QWORD PTR [rsp+0x20],r13
     9dd:	jmp    9f7 <botlish_fn_10+0x23f>
     9e2:	mov    ecx,0x2
     9e7:	test   r13,r13
     9ea:	mov    QWORD PTR [rsp+0x20],r13
     9ef:	cmovle rcx,QWORD PTR [rip+0x169]        # b60 <botlish_fn_10+0x3a8>
     9f7:	cmp    rcx,0x6
     9fb:	je     a0b <botlish_fn_10+0x253>
     a01:	mov    eax,0x2
     a06:	jmp    a10 <botlish_fn_10+0x258>
     a0b:	mov    eax,0x6
     a10:	cmp    rax,0x6
     a14:	je     a51 <botlish_fn_10+0x299>
     a1a:	mov    rdx,r14
     a1d:	mov    rsi,rbx
     a20:	mov    rdi,r15
     a23:	call   a28 <botlish_fn_10+0x270>
			a24: R_X86_64_PLT32	botlish_fn_8-0x4 ; ht_probe_next<HashTable, int>
     a28:	test   rax,rax
     a2b:	je     a68 <botlish_fn_10+0x2b0>
     a31:	mov    QWORD PTR [rsp],rbx
     a35:	mov    QWORD PTR [rsp+0x8],r12
     a3a:	mov    QWORD PTR [rsp+0x10],rax
     a3f:	mov    r10,QWORD PTR [rsp+0x20]
     a44:	mov    QWORD PTR [rsp+0x18],r10
     a49:	mov    r14,rax
     a4c:	jmp    7fd <botlish_fn_10+0x45>
     a51:	mov    rdx,r14
     a54:	mov    rsi,rbx
     a57:	mov    rdi,r15
     a5a:	call   a5f <botlish_fn_10+0x2a7>
			a5b: R_X86_64_PLT32	botlish_fn_8-0x4 ; ht_probe_next<HashTable, int>
     a5f:	test   rax,rax
     a62:	jne    a8d <botlish_fn_10+0x2d5>
     a68:	xor    rax,rax
     a6b:	mov    rbx,QWORD PTR [rsp+0x30]
     a70:	mov    r12,QWORD PTR [rsp+0x38]
     a75:	mov    r13,QWORD PTR [rsp+0x40]
     a7a:	mov    r14,QWORD PTR [rsp+0x48]
     a7f:	mov    r15,QWORD PTR [rsp+0x50]
     a84:	add    rsp,0x60
     a88:	mov    rsp,rbp
     a8b:	pop    rbp
     a8c:	ret
     a8d:	mov    QWORD PTR [rsp],rbx
     a91:	mov    QWORD PTR [rsp+0x8],r12
     a96:	mov    QWORD PTR [rsp+0x10],rax
     a9b:	mov    rdx,r14
     a9e:	mov    QWORD PTR [rsp+0x18],rdx
     aa3:	mov    QWORD PTR [rsp+0x20],r14
     aa8:	mov    r14,rax
     aab:	jmp    7fd <botlish_fn_10+0x45>
     ab0:	mov    rax,r14
     ab3:	jmp    b17 <botlish_fn_10+0x35f>
     ab8:	mov    rax,QWORD PTR [rsp+0x20]
     abd:	test   rax,0x1
     ac3:	jne    af0 <botlish_fn_10+0x338>
     ac9:	mov    edx,0x1
     ace:	mov    rdi,r15
     ad1:	mov    rsi,QWORD PTR [rsp+0x20]
     ad6:	call   adb <botlish_fn_10+0x323>
			ad7: R_X86_64_PLT32	rt_int_cmp-0x4
     adb:	mov    ecx,0x2
     ae0:	test   rax,rax
     ae3:	cmovge rcx,QWORD PTR [rip+0x75]        # b60 <botlish_fn_10+0x3a8>
     aeb:	jmp    b0a <botlish_fn_10+0x352>
     af0:	mov    ecx,0x2
     af5:	mov    rax,QWORD PTR [rsp+0x20]
     afa:	mov    rdx,QWORD PTR [rsp+0x20]
     aff:	test   rax,rdx
     b02:	cmovg  rcx,QWORD PTR [rip+0x56]        # b60 <botlish_fn_10+0x3a8>
     b0a:	cmp    rcx,0x6
     b0e:	je     b39 <botlish_fn_10+0x381>
     b14:	mov    rax,r14
     b17:	mov    rbx,QWORD PTR [rsp+0x30]
     b1c:	mov    r12,QWORD PTR [rsp+0x38]
     b21:	mov    r13,QWORD PTR [rsp+0x40]
     b26:	mov    r14,QWORD PTR [rsp+0x48]
     b2b:	mov    r15,QWORD PTR [rsp+0x50]
     b30:	add    rsp,0x60
     b34:	mov    rsp,rbp
     b37:	pop    rbp
     b38:	ret
     b39:	mov    rax,QWORD PTR [rsp+0x20]
     b3e:	mov    rbx,QWORD PTR [rsp+0x30]
     b43:	mov    r12,QWORD PTR [rsp+0x38]
     b48:	mov    r13,QWORD PTR [rsp+0x40]
     b4d:	mov    r14,QWORD PTR [rsp+0x48]
     b52:	mov    r15,QWORD PTR [rsp+0x50]
     b57:	add    rsp,0x60
     b5b:	mov    rsp,rbp
     b5e:	pop    rbp
     b5f:	ret
     b60:	(bad)
     b61:	add    BYTE PTR [rax],al
     b63:	add    BYTE PTR [rax],al
     b65:	add    BYTE PTR [rax],al
	...

0000000000000b68 <botlish_entry_10: ht_find_insert<HashTable, str, int, int>>:
     b68:	push   rbp
     b69:	mov    rbp,rsp
     b6c:	mov    rsi,QWORD PTR [rdx]
     b6f:	mov    r9,QWORD PTR [rdx+0x8]
     b73:	mov    rcx,QWORD PTR [rdx+0x10]
     b77:	mov    r8,QWORD PTR [rdx+0x18]
     b7b:	mov    rdx,r9
     b7e:	call   b83 <botlish_entry_10+0x1b>
			b7f: R_X86_64_PLT32	botlish_fn_10-0x4 ; ht_find_insert<HashTable, str, int, int>
     b83:	mov    rsp,rbp
     b86:	pop    rbp
     b87:	ret

0000000000000b88 <botlish_fn_11: ht_get<HashTable, str>>:
     b88:	push   rbp
     b89:	mov    rbp,rsp
     b8c:	sub    rsp,0x40
     b90:	mov    QWORD PTR [rsp+0x20],rbx
     b95:	mov    QWORD PTR [rsp+0x28],r12
     b9a:	mov    QWORD PTR [rsp+0x30],r13
     b9f:	mov    r12,rdi
     ba2:	mov    QWORD PTR [rsp+0x10],0x0
     bab:	mov    QWORD PTR [rsp],rsi
     baf:	mov    QWORD PTR [rsp+0x8],rdx
     bb4:	mov    r13,rdx
     bb7:	mov    rbx,rsi
     bba:	mov    rdx,r13
     bbd:	mov    rdi,r12
     bc0:	call   bc5 <botlish_fn_11+0x3d>
			bc1: R_X86_64_PLT32	botlish_fn_7-0x4 ; ht_probe_start<HashTable, str>
     bc5:	test   rax,rax
     bc8:	je     c60 <botlish_fn_11+0xd8>
     bce:	mov    QWORD PTR [rsp+0x10],rax
     bd3:	mov    rcx,rax
     bd6:	mov    rdx,r13
     bd9:	mov    rsi,rbx
     bdc:	mov    rdi,r12
     bdf:	call   be4 <botlish_fn_11+0x5c>
			be0: R_X86_64_PLT32	botlish_fn_9-0x4 ; ht_find_get<HashTable, str, int>
     be4:	mov    rcx,rax
     be7:	mov    r13,rax
     bea:	test   rax,rcx
     bed:	je     c60 <botlish_fn_11+0xd8>
     bf3:	mov    rax,r13
     bf6:	test   rax,0x1
     bfc:	jne    c27 <botlish_fn_11+0x9f>
     c02:	mov    edx,0x1
     c07:	mov    rsi,r13
     c0a:	mov    rdi,r12
     c0d:	call   c12 <botlish_fn_11+0x8a>
			c0e: R_X86_64_PLT32	rt_int_cmp-0x4
     c12:	mov    ecx,0x2
     c17:	test   rax,rax
     c1a:	cmovl  rcx,QWORD PTR [rip+0x8e]        # cb0 <botlish_fn_11+0x128>
     c22:	jmp    c3a <botlish_fn_11+0xb2>
     c27:	mov    ecx,0x2
     c2c:	mov    rax,r13
     c2f:	test   rax,rax
     c32:	cmovle rcx,QWORD PTR [rip+0x76]        # cb0 <botlish_fn_11+0x128>
     c3a:	cmp    rcx,0x6
     c3e:	je     c93 <botlish_fn_11+0x10b>
     c44:	mov    rax,QWORD PTR [rbx+0x18]
     c48:	mov    rsi,QWORD PTR [rax+0x10]
     c4c:	mov    rdx,r13
     c4f:	mov    rdi,r12
     c52:	call   c57 <botlish_fn_11+0xcf>
			c53: R_X86_64_PLT32	rt_mutarray_get-0x4
     c57:	test   rax,rax
     c5a:	jne    c7b <botlish_fn_11+0xf3>
     c60:	xor    rax,rax
     c63:	mov    rbx,QWORD PTR [rsp+0x20]
     c68:	mov    r12,QWORD PTR [rsp+0x28]
     c6d:	mov    r13,QWORD PTR [rsp+0x30]
     c72:	add    rsp,0x40
     c76:	mov    rsp,rbp
     c79:	pop    rbp
     c7a:	ret
     c7b:	mov    rbx,QWORD PTR [rsp+0x20]
     c80:	mov    r12,QWORD PTR [rsp+0x28]
     c85:	mov    r13,QWORD PTR [rsp+0x30]
     c8a:	add    rsp,0x40
     c8e:	mov    rsp,rbp
     c91:	pop    rbp
     c92:	ret
     c93:	mov    eax,0xa
     c98:	mov    rbx,QWORD PTR [rsp+0x20]
     c9d:	mov    r12,QWORD PTR [rsp+0x28]
     ca2:	mov    r13,QWORD PTR [rsp+0x30]
     ca7:	add    rsp,0x40
     cab:	mov    rsp,rbp
     cae:	pop    rbp
     caf:	ret
     cb0:	(bad)
     cb1:	add    BYTE PTR [rax],al
     cb3:	add    BYTE PTR [rax],al
     cb5:	add    BYTE PTR [rax],al
	...

0000000000000cb8 <botlish_entry_11: ht_get<HashTable, str>>:
     cb8:	push   rbp
     cb9:	mov    rbp,rsp
     cbc:	mov    rsi,QWORD PTR [rdx]
     cbf:	mov    rdx,QWORD PTR [rdx+0x8]
     cc3:	call   cc8 <botlish_entry_11+0x10>
			cc4: R_X86_64_PLT32	botlish_fn_11-0x4 ; ht_get<HashTable, str>
     cc8:	mov    rsp,rbp
     ccb:	pop    rbp
     ccc:	ret
     ccd:	add    BYTE PTR [rax],al
	...

0000000000000cd0 <botlish_fn_12: ht_contains<HashTable, str>>:
     cd0:	push   rbp
     cd1:	mov    rbp,rsp
     cd4:	sub    rsp,0x40
     cd8:	mov    QWORD PTR [rsp+0x20],rbx
     cdd:	mov    QWORD PTR [rsp+0x28],r12
     ce2:	mov    QWORD PTR [rsp+0x30],r15
     ce7:	mov    r15,rdi
     cea:	mov    QWORD PTR [rsp+0x10],0x0
     cf3:	mov    QWORD PTR [rsp],rsi
     cf7:	mov    r12,rsi
     cfa:	mov    QWORD PTR [rsp+0x8],rdx
     cff:	mov    rbx,rdx
     d02:	mov    rdx,rbx
     d05:	mov    rsi,r12
     d08:	mov    rdi,r15
     d0b:	call   d10 <botlish_fn_12+0x40>
			d0c: R_X86_64_PLT32	botlish_fn_7-0x4 ; ht_probe_start<HashTable, str>
     d10:	test   rax,rax
     d13:	je     d38 <botlish_fn_12+0x68>
     d19:	mov    QWORD PTR [rsp+0x10],rax
     d1e:	mov    rcx,rax
     d21:	mov    rdx,rbx
     d24:	mov    rsi,r12
     d27:	mov    rdi,r15
     d2a:	call   d2f <botlish_fn_12+0x5f>
			d2b: R_X86_64_PLT32	botlish_fn_9-0x4 ; ht_find_get<HashTable, str, int>
     d2f:	test   rax,rax
     d32:	jne    d53 <botlish_fn_12+0x83>
     d38:	xor    rax,rax
     d3b:	mov    rbx,QWORD PTR [rsp+0x20]
     d40:	mov    r12,QWORD PTR [rsp+0x28]
     d45:	mov    r15,QWORD PTR [rsp+0x30]
     d4a:	add    rsp,0x40
     d4e:	mov    rsp,rbp
     d51:	pop    rbp
     d52:	ret
     d53:	test   rax,0x1
     d59:	mov    rsi,rax
     d5c:	jne    d87 <botlish_fn_12+0xb7>
     d62:	mov    edx,0x1
     d67:	mov    rdi,r15
     d6a:	call   d6f <botlish_fn_12+0x9f>
			d6b: R_X86_64_PLT32	rt_int_cmp-0x4
     d6f:	mov    ecx,0x2
     d74:	test   rax,rax
     d77:	mov    rax,rcx
     d7a:	cmovge rax,QWORD PTR [rip+0x2e]        # db0 <botlish_fn_12+0xe0>
     d82:	jmp    d97 <botlish_fn_12+0xc7>
     d87:	mov    eax,0x2
     d8c:	test   rsi,rsi
     d8f:	cmovg  rax,QWORD PTR [rip+0x19]        # db0 <botlish_fn_12+0xe0>
     d97:	mov    rbx,QWORD PTR [rsp+0x20]
     d9c:	mov    r12,QWORD PTR [rsp+0x28]
     da1:	mov    r15,QWORD PTR [rsp+0x30]
     da6:	add    rsp,0x40
     daa:	mov    rsp,rbp
     dad:	pop    rbp
     dae:	ret
     daf:	add    BYTE PTR [rsi],al
     db1:	add    BYTE PTR [rax],al
     db3:	add    BYTE PTR [rax],al
     db5:	add    BYTE PTR [rax],al
	...

0000000000000db8 <botlish_entry_12: ht_contains<HashTable, str>>:
     db8:	push   rbp
     db9:	mov    rbp,rsp
     dbc:	mov    rsi,QWORD PTR [rdx]
     dbf:	mov    rdx,QWORD PTR [rdx+0x8]
     dc3:	call   dc8 <botlish_entry_12+0x10>
			dc4: R_X86_64_PLT32	botlish_fn_12-0x4 ; ht_contains<HashTable, str>
     dc8:	mov    rsp,rbp
     dcb:	pop    rbp
     dcc:	ret
     dcd:	add    BYTE PTR [rax],al
	...

0000000000000dd0 <botlish_fn_13: ht_rehash_probe<mutarray, int, int>>:
     dd0:	push   rbp
     dd1:	mov    rbp,rsp
     dd4:	sub    rsp,0x40
     dd8:	mov    QWORD PTR [rsp+0x20],rbx
     ddd:	mov    QWORD PTR [rsp+0x28],r12
     de2:	mov    QWORD PTR [rsp+0x30],r13
     de7:	mov    QWORD PTR [rsp+0x38],r14
     dec:	mov    r13,rdi
     def:	mov    QWORD PTR [rsp],rsi
     df3:	mov    QWORD PTR [rsp+0x8],rdx
     df8:	mov    QWORD PTR [rsp+0x10],rcx
     dfd:	mov    r12,rcx
     e00:	mov    rbx,rsi
     e03:	mov    r14,rdx
     e06:	mov    rdx,r14
     e09:	mov    rsi,rbx
     e0c:	mov    rdi,r13
     e0f:	call   e14 <botlish_fn_13+0x44>
			e10: R_X86_64_PLT32	rt_mutarray_get-0x4
     e14:	test   rax,rax
     e17:	je     eb9 <botlish_fn_13+0xe9>
     e1d:	test   rax,0x1
     e23:	mov    rsi,rax
     e26:	jne    e47 <botlish_fn_13+0x77>
     e2c:	mov    edx,0x1
     e31:	mov    rdi,r13
     e34:	call   e39 <botlish_fn_13+0x69>
			e35: R_X86_64_PLT32	rt_value_eq-0x4
     e39:	test   rax,rax
     e3c:	je     eb9 <botlish_fn_13+0xe9>
     e42:	jmp    e58 <botlish_fn_13+0x88>
     e47:	mov    eax,0x2
     e4c:	cmp    rsi,0x1
     e50:	cmove  rax,QWORD PTR [rip+0xb8]        # f10 <botlish_fn_13+0x140>
     e58:	cmp    rax,0x6
     e5c:	je     eef <botlish_fn_13+0x11f>
     e62:	mov    QWORD PTR [rsp+0x18],0x3
     e6b:	mov    rsi,r14
     e6e:	test   rsi,0x1
     e75:	je     e8d <botlish_fn_13+0xbd>
     e7b:	mov    rsi,r14
     e7e:	add    rsi,0x2
     e82:	seto   al
     e85:	test   al,al
     e87:	je     ea0 <botlish_fn_13+0xd0>
     e8d:	mov    edx,0x3
     e92:	mov    rsi,r14
     e95:	mov    rdi,r13
     e98:	call   e9d <botlish_fn_13+0xcd>
			e99: R_X86_64_PLT32	rt_int_add-0x4
     e9d:	mov    rsi,rax
     ea0:	mov    QWORD PTR [rsp+0x8],rsi
     ea5:	mov    rdx,r12
     ea8:	mov    rdi,r13
     eab:	call   eb0 <botlish_fn_13+0xe0>
			eac: R_X86_64_PLT32	rt_int_mod-0x4
     eb0:	test   rax,rax
     eb3:	jne    ed9 <botlish_fn_13+0x109>
     eb9:	xor    rax,rax
     ebc:	mov    rbx,QWORD PTR [rsp+0x20]
     ec1:	mov    r12,QWORD PTR [rsp+0x28]
     ec6:	mov    r13,QWORD PTR [rsp+0x30]
     ecb:	mov    r14,QWORD PTR [rsp+0x38]
     ed0:	add    rsp,0x40
     ed4:	mov    rsp,rbp
     ed7:	pop    rbp
     ed8:	ret
     ed9:	mov    QWORD PTR [rsp],rbx
     edd:	mov    QWORD PTR [rsp+0x8],rax
     ee2:	mov    QWORD PTR [rsp+0x10],r12
     ee7:	mov    r14,rax
     eea:	jmp    e06 <botlish_fn_13+0x36>
     eef:	mov    rax,r14
     ef2:	mov    rbx,QWORD PTR [rsp+0x20]
     ef7:	mov    r12,QWORD PTR [rsp+0x28]
     efc:	mov    r13,QWORD PTR [rsp+0x30]
     f01:	mov    r14,QWORD PTR [rsp+0x38]
     f06:	add    rsp,0x40
     f0a:	mov    rsp,rbp
     f0d:	pop    rbp
     f0e:	ret
     f0f:	add    BYTE PTR [rsi],al
     f11:	add    BYTE PTR [rax],al
     f13:	add    BYTE PTR [rax],al
     f15:	add    BYTE PTR [rax],al
	...

0000000000000f18 <botlish_entry_13: ht_rehash_probe<mutarray, int, int>>:
     f18:	push   rbp
     f19:	mov    rbp,rsp
     f1c:	mov    rsi,QWORD PTR [rdx]
     f1f:	mov    r8,QWORD PTR [rdx+0x8]
     f23:	mov    rcx,QWORD PTR [rdx+0x10]
     f27:	mov    rdx,r8
     f2a:	call   f2f <botlish_entry_13+0x17>
			f2b: R_X86_64_PLT32	botlish_fn_13-0x4 ; ht_rehash_probe<mutarray, int, int>
     f2f:	mov    rsp,rbp
     f32:	pop    rbp
     f33:	ret

0000000000000f34 <botlish_fn_14: ht_rehash_insert<HashTable, int, any, any>>:
     f34:	push   rbp
     f35:	mov    rbp,rsp
     f38:	sub    rsp,0x70
     f3c:	mov    QWORD PTR [rsp+0x40],rbx
     f41:	mov    QWORD PTR [rsp+0x48],r12
     f46:	mov    QWORD PTR [rsp+0x50],r13
     f4b:	mov    QWORD PTR [rsp+0x58],r14
     f50:	mov    QWORD PTR [rsp+0x60],r15
     f55:	mov    r13,rdi
     f58:	mov    QWORD PTR [rsp],rsi
     f5c:	mov    QWORD PTR [rsp+0x8],rdx
     f61:	mov    r15,rdx
     f64:	mov    QWORD PTR [rsp+0x10],rcx
     f69:	mov    r14,rcx
     f6c:	mov    QWORD PTR [rsp+0x18],r8
     f71:	mov    r12,r8
     f74:	mov    rax,QWORD PTR [rsi+0x18]
     f78:	mov    rbx,rsi
     f7b:	mov    rsi,QWORD PTR [rax]
     f7e:	mov    QWORD PTR [rsp+0x20],rsi
     f83:	mov    QWORD PTR [rsp+0x30],rsi
     f88:	mov    rsi,r14
     f8b:	mov    rdi,r13
     f8e:	call   f93 <botlish_fn_14+0x5f>
			f8f: R_X86_64_PLT32	rt_hash-0x4
     f93:	test   rax,rax
     f96:	je     103d <botlish_fn_14+0x109>
     f9c:	mov    QWORD PTR [rsp+0x28],rax
     fa1:	mov    rsi,rax
     fa4:	mov    rdx,r15
     fa7:	mov    rdi,r13
     faa:	call   faf <botlish_fn_14+0x7b>
			fab: R_X86_64_PLT32	rt_int_mod-0x4
     faf:	test   rax,rax
     fb2:	je     103d <botlish_fn_14+0x109>
     fb8:	mov    QWORD PTR [rsp+0x28],rax
     fbd:	mov    rcx,r15
     fc0:	mov    rdx,rax
     fc3:	mov    rsi,QWORD PTR [rsp+0x30]
     fc8:	mov    rdi,r13
     fcb:	call   fd0 <botlish_fn_14+0x9c>
			fcc: R_X86_64_PLT32	botlish_fn_13-0x4 ; ht_rehash_probe<mutarray, int, int>
     fd0:	mov    rdx,rax
     fd3:	mov    r15,rax
     fd6:	test   rax,rdx
     fd9:	je     103d <botlish_fn_14+0x109>
     fdf:	mov    rcx,QWORD PTR [rbx+0x18]
     fe3:	mov    rsi,QWORD PTR [rcx]
     fe6:	mov    ecx,0x3
     feb:	mov    rdx,r15
     fee:	mov    rdi,r13
     ff1:	call   ff6 <botlish_fn_14+0xc2>
			ff2: R_X86_64_PLT32	rt_mutarray_set-0x4
     ff6:	test   rax,rax
     ff9:	je     103d <botlish_fn_14+0x109>
     fff:	mov    rax,QWORD PTR [rbx+0x18]
    1003:	mov    rsi,QWORD PTR [rax+0x8]
    1007:	mov    rcx,r14
    100a:	mov    rdx,r15
    100d:	mov    rdi,r13
    1010:	call   1015 <botlish_fn_14+0xe1>
			1011: R_X86_64_PLT32	rt_mutarray_set-0x4
    1015:	test   rax,rax
    1018:	je     103d <botlish_fn_14+0x109>
    101e:	mov    rax,QWORD PTR [rbx+0x18]
    1022:	mov    rsi,QWORD PTR [rax+0x10]
    1026:	mov    rcx,r12
    1029:	mov    rdx,r15
    102c:	mov    rdi,r13
    102f:	call   1034 <botlish_fn_14+0x100>
			1030: R_X86_64_PLT32	rt_mutarray_set-0x4
    1034:	test   rax,rax
    1037:	jne    1062 <botlish_fn_14+0x12e>
    103d:	xor    rax,rax
    1040:	mov    rbx,QWORD PTR [rsp+0x40]
    1045:	mov    r12,QWORD PTR [rsp+0x48]
    104a:	mov    r13,QWORD PTR [rsp+0x50]
    104f:	mov    r14,QWORD PTR [rsp+0x58]
    1054:	mov    r15,QWORD PTR [rsp+0x60]
    1059:	add    rsp,0x70
    105d:	mov    rsp,rbp
    1060:	pop    rbp
    1061:	ret
    1062:	mov    rax,rbx
    1065:	mov    rbx,QWORD PTR [rsp+0x40]
    106a:	mov    r12,QWORD PTR [rsp+0x48]
    106f:	mov    r13,QWORD PTR [rsp+0x50]
    1074:	mov    r14,QWORD PTR [rsp+0x58]
    1079:	mov    r15,QWORD PTR [rsp+0x60]
    107e:	add    rsp,0x70
    1082:	mov    rsp,rbp
    1085:	pop    rbp
    1086:	ret

0000000000001087 <botlish_entry_14: ht_rehash_insert<HashTable, int, any, any>>:
    1087:	push   rbp
    1088:	mov    rbp,rsp
    108b:	mov    rsi,QWORD PTR [rdx]
    108e:	mov    r9,QWORD PTR [rdx+0x8]
    1092:	mov    rcx,QWORD PTR [rdx+0x10]
    1096:	mov    r8,QWORD PTR [rdx+0x18]
    109a:	mov    rdx,r9
    109d:	call   10a2 <botlish_entry_14+0x1b>
			109e: R_X86_64_PLT32	botlish_fn_14-0x4 ; ht_rehash_insert<HashTable, int, any, any>
    10a2:	mov    rsp,rbp
    10a5:	pop    rbp
    10a6:	ret
	...

00000000000010a8 <botlish_fn_15: ht_rehash_scan<mutarray, mutarray, mutarray, int, int, HashTable, int>>:
    10a8:	push   rbp
    10a9:	mov    rbp,rsp
    10ac:	sub    rsp,0x90
    10b3:	mov    QWORD PTR [rsp+0x60],rbx
    10b8:	mov    QWORD PTR [rsp+0x68],r12
    10bd:	mov    QWORD PTR [rsp+0x70],r13
    10c2:	mov    QWORD PTR [rsp+0x78],r14
    10c7:	mov    QWORD PTR [rsp+0x80],r15
    10cf:	mov    QWORD PTR [rsp+0x38],rdi
    10d4:	mov    QWORD PTR [rsp+0x40],r9
    10d9:	mov    rdi,QWORD PTR [rbp+0x10]
    10dd:	mov    rbx,QWORD PTR [rbp+0x18]
    10e1:	mov    QWORD PTR [rsp],rsi
    10e5:	mov    QWORD PTR [rsp+0x8],rdx
    10ea:	mov    r14,rdx
    10ed:	mov    QWORD PTR [rsp+0x10],rcx
    10f2:	mov    r15,rcx
    10f5:	mov    QWORD PTR [rsp+0x18],rdi
    10fa:	mov    QWORD PTR [rsp+0x20],rbx
    10ff:	sar    r8,1
    1102:	mov    rcx,QWORD PTR [rsp+0x40]
    1107:	mov    r12,r8
    110a:	mov    QWORD PTR [rsp+0x48],rdi
    110f:	cmp    r12,rcx
    1112:	mov    QWORD PTR [rsp+0x40],rcx
    1117:	jge    127e <botlish_fn_15+0x1d6>
    111d:	mov    rdx,r12
    1120:	shl    rdx,1
    1123:	or     rdx,0x1
    1127:	mov    r13,rsi
    112a:	mov    QWORD PTR [rsp+0x58],rdx
    112f:	mov    rdi,QWORD PTR [rsp+0x38]
    1134:	call   1139 <botlish_fn_15+0x91>
			1135: R_X86_64_PLT32	rt_mutarray_get-0x4
    1139:	test   rax,rax
    113c:	je     1222 <botlish_fn_15+0x17a>
    1142:	test   rax,0x1
    1148:	mov    rsi,rax
    114b:	jne    116e <botlish_fn_15+0xc6>
    1151:	mov    edx,0x3
    1156:	mov    rdi,QWORD PTR [rsp+0x38]
    115b:	call   1160 <botlish_fn_15+0xb8>
			115c: R_X86_64_PLT32	rt_value_eq-0x4
    1160:	test   rax,rax
    1163:	je     1222 <botlish_fn_15+0x17a>
    1169:	jmp    117f <botlish_fn_15+0xd7>
    116e:	mov    eax,0x2
    1173:	cmp    rsi,0x3
    1177:	cmove  rax,QWORD PTR [rip+0x131]        # 12b0 <botlish_fn_15+0x208>
    117f:	cmp    rax,0x6
    1183:	je     11ba <botlish_fn_15+0x112>
    1189:	mov    QWORD PTR [rsp],r13
    118d:	mov    QWORD PTR [rsp+0x8],r14
    1192:	mov    QWORD PTR [rsp+0x10],r15
    1197:	mov    rsi,QWORD PTR [rsp+0x48]
    119c:	mov    QWORD PTR [rsp+0x18],rsi
    11a1:	mov    QWORD PTR [rsp+0x20],rbx
    11a6:	add    r12,0x1
    11ad:	mov    rcx,QWORD PTR [rsp+0x40]
    11b2:	mov    rsi,r13
    11b5:	jmp    110f <botlish_fn_15+0x67>
    11ba:	mov    rdx,QWORD PTR [rsp+0x58]
    11bf:	mov    rsi,r14
    11c2:	mov    rdi,QWORD PTR [rsp+0x38]
    11c7:	call   11cc <botlish_fn_15+0x124>
			11c8: R_X86_64_PLT32	rt_mutarray_get-0x4
    11cc:	test   rax,rax
    11cf:	je     1222 <botlish_fn_15+0x17a>
    11d5:	mov    QWORD PTR [rsp+0x28],rax
    11da:	mov    rdx,QWORD PTR [rsp+0x58]
    11df:	mov    QWORD PTR [rsp+0x50],rax
    11e4:	mov    rsi,r15
    11e7:	mov    rdi,QWORD PTR [rsp+0x38]
    11ec:	call   11f1 <botlish_fn_15+0x149>
			11ed: R_X86_64_PLT32	rt_mutarray_get-0x4
    11f1:	test   rax,rax
    11f4:	je     1222 <botlish_fn_15+0x17a>
    11fa:	mov    QWORD PTR [rsp+0x30],rax
    11ff:	mov    rcx,QWORD PTR [rsp+0x50]
    1204:	mov    rsi,QWORD PTR [rsp+0x48]
    1209:	mov    r8,rax
    120c:	mov    rdx,rbx
    120f:	mov    rdi,QWORD PTR [rsp+0x38]
    1214:	call   1219 <botlish_fn_15+0x171>
			1215: R_X86_64_PLT32	botlish_fn_14-0x4 ; ht_rehash_insert<HashTable, int, any, any>
    1219:	test   rax,rax
    121c:	jne    124d <botlish_fn_15+0x1a5>
    1222:	xor    rax,rax
    1225:	mov    rbx,QWORD PTR [rsp+0x60]
    122a:	mov    r12,QWORD PTR [rsp+0x68]
    122f:	mov    r13,QWORD PTR [rsp+0x70]
    1234:	mov    r14,QWORD PTR [rsp+0x78]
    1239:	mov    r15,QWORD PTR [rsp+0x80]
    1241:	add    rsp,0x90
    1248:	mov    rsp,rbp
    124b:	pop    rbp
    124c:	ret
    124d:	mov    QWORD PTR [rsp],r13
    1251:	mov    QWORD PTR [rsp+0x8],r14
    1256:	mov    QWORD PTR [rsp+0x10],r15
    125b:	mov    QWORD PTR [rsp+0x18],rax
    1260:	mov    QWORD PTR [rsp+0x20],rbx
    1265:	add    r12,0x1
    126c:	mov    rcx,QWORD PTR [rsp+0x40]
    1271:	mov    rsi,r13
    1274:	mov    QWORD PTR [rsp+0x48],rax
    1279:	jmp    110f <botlish_fn_15+0x67>
    127e:	mov    rax,QWORD PTR [rsp+0x48]
    1283:	mov    rbx,QWORD PTR [rsp+0x60]
    1288:	mov    r12,QWORD PTR [rsp+0x68]
    128d:	mov    r13,QWORD PTR [rsp+0x70]
    1292:	mov    r14,QWORD PTR [rsp+0x78]
    1297:	mov    r15,QWORD PTR [rsp+0x80]
    129f:	add    rsp,0x90
    12a6:	mov    rsp,rbp
    12a9:	pop    rbp
    12aa:	ret
    12ab:	add    BYTE PTR [rax],al
    12ad:	add    BYTE PTR [rax],al
    12af:	add    BYTE PTR [rsi],al
    12b1:	add    BYTE PTR [rax],al
    12b3:	add    BYTE PTR [rax],al
    12b5:	add    BYTE PTR [rax],al
	...

00000000000012b8 <botlish_entry_15: ht_rehash_scan<mutarray, mutarray, mutarray, int, int, HashTable, int>>:
    12b8:	push   rbp
    12b9:	mov    rbp,rsp
    12bc:	sub    rsp,0x10
    12c0:	mov    rsi,QWORD PTR [rdx]
    12c3:	mov    r11,QWORD PTR [rdx+0x8]
    12c7:	mov    rcx,QWORD PTR [rdx+0x10]
    12cb:	mov    r8,QWORD PTR [rdx+0x18]
    12cf:	mov    r9,QWORD PTR [rdx+0x20]
    12d3:	mov    rax,QWORD PTR [rdx+0x28]
    12d7:	mov    rdx,QWORD PTR [rdx+0x30]
    12db:	sar    r9,1
    12de:	mov    QWORD PTR [rsp],rax
    12e2:	mov    QWORD PTR [rsp+0x8],rdx
    12e7:	mov    rdx,r11
    12ea:	call   12ef <botlish_entry_15+0x37>
			12eb: R_X86_64_PLT32	botlish_fn_15-0x4 ; ht_rehash_scan<mutarray, mutarray, mutarray, int, int, HashTable, int>
    12ef:	add    rsp,0x10
    12f3:	mov    rsp,rbp
    12f6:	pop    rbp
    12f7:	ret

00000000000012f8 <botlish_fn_16: ht_rehash<HashTable, int>>:
    12f8:	push   rbp
    12f9:	mov    rbp,rsp
    12fc:	sub    rsp,0xf0
    1303:	mov    QWORD PTR [rsp+0xc0],rbx
    130b:	mov    QWORD PTR [rsp+0xc8],r12
    1313:	mov    QWORD PTR [rsp+0xd0],r13
    131b:	mov    QWORD PTR [rsp+0xd8],r14
    1323:	mov    QWORD PTR [rsp+0xe0],r15
    132b:	mov    QWORD PTR [rsp+0x90],rdi
    1333:	mov    QWORD PTR [rsp+0x20],0x0
    133c:	mov    QWORD PTR [rsp+0x28],0x0
    1345:	mov    QWORD PTR [rsp+0x30],0x0
    134e:	mov    QWORD PTR [rsp+0x38],0x0
    1357:	mov    QWORD PTR [rsp+0x40],0x0
    1360:	mov    QWORD PTR [rsp+0x48],0x0
    1369:	mov    QWORD PTR [rsp+0x50],0x0
    1372:	mov    QWORD PTR [rsp+0x10],rsi
    1377:	mov    r14,rsi
    137a:	mov    QWORD PTR [rsp+0x18],rdx
    137f:	mov    QWORD PTR [rsp+0x98],rdx
    1387:	lea    rdx,[rsp+0x58]
    138c:	mov    rsi,QWORD PTR [rsp+0x98]
    1394:	mov    rdi,QWORD PTR [rsp+0x90]
    139c:	call   13a1 <botlish_fn_16+0xa9>
			139d: R_X86_64_PLT32	botlish_fn_2-0x4 ; ht_alloc<int>
    13a1:	test   rax,rax
    13a4:	je     14f8 <botlish_fn_16+0x200>
    13aa:	mov    QWORD PTR [rsp+0x10],rax
    13af:	mov    QWORD PTR [rsp+0xb8],rax
    13b7:	mov    rbx,QWORD PTR [rsp+0x58]
    13bc:	mov    QWORD PTR [rsp+0x20],rbx
    13c1:	mov    r12,QWORD PTR [rsp+0x60]
    13c6:	mov    QWORD PTR [rsp+0x28],r12
    13cb:	mov    r13,QWORD PTR [rsp+0x68]
    13d0:	mov    QWORD PTR [rsp+0x30],r13
    13d5:	mov    rsi,r14
    13d8:	mov    rdi,QWORD PTR [rsp+0x90]
    13e0:	call   13e5 <botlish_fn_16+0xed>
			13e1: R_X86_64_PLT32	botlish_fn_4-0x4 ; ht_size<HashTable>
    13e5:	test   rax,rax
    13e8:	mov    rcx,rax
    13eb:	je     14f8 <botlish_fn_16+0x200>
    13f1:	mov    edx,0x1
    13f6:	mov    rsi,r13
    13f9:	mov    rdi,QWORD PTR [rsp+0x90]
    1401:	call   1406 <botlish_fn_16+0x10e>
			1402: R_X86_64_PLT32	rt_mutarray_set-0x4
    1406:	test   rax,rax
    1409:	je     14f8 <botlish_fn_16+0x200>
    140f:	mov    rsi,r14
    1412:	mov    rax,QWORD PTR [rsi+0x18]
    1416:	mov    rcx,QWORD PTR [rax]
    1419:	mov    QWORD PTR [rsp+0x38],rcx
    141e:	mov    QWORD PTR [rsp+0xb0],rcx
    1426:	mov    rax,QWORD PTR [rsi+0x18]
    142a:	mov    r15,QWORD PTR [rax+0x8]
    142e:	mov    QWORD PTR [rsp+0x40],r15
    1433:	mov    rax,QWORD PTR [rsi+0x18]
    1437:	mov    r14,QWORD PTR [rax+0x10]
    143b:	mov    QWORD PTR [rsp+0x48],r14
    1440:	mov    r8d,0x1
    1446:	mov    QWORD PTR [rsp+0xa8],r8
    144e:	mov    QWORD PTR [rsp+0x50],0x1
    1457:	mov    rdi,QWORD PTR [rsp+0x90]
    145f:	call   1464 <botlish_fn_16+0x16c>
			1460: R_X86_64_PLT32	botlish_fn_6-0x4 ; ht_capacity<HashTable>
    1464:	mov    QWORD PTR [rsp+0xa0],rax
    146c:	lea    rcx,[rsp+0x70]
    1471:	mov    rax,QWORD PTR [rsp+0xb8]
    1479:	mov    QWORD PTR [rsp+0x70],rax
    147e:	mov    QWORD PTR [rsp+0x78],rbx
    1483:	mov    QWORD PTR [rsp+0x80],r12
    148b:	mov    QWORD PTR [rsp+0x88],r13
    1493:	xor    rsi,rsi
    1496:	mov    edx,0x4
    149b:	mov    rdi,QWORD PTR [rsp+0x90]
    14a3:	call   14a8 <botlish_fn_16+0x1b0>
			14a4: R_X86_64_PLT32	rt_struct_new-0x4
    14a8:	mov    QWORD PTR [rsp+0x10],rax
    14ad:	mov    rcx,QWORD PTR [rsp+0xa0]
    14b5:	mov    r9,rcx
    14b8:	sar    r9,1
    14bb:	mov    QWORD PTR [rsp],rax
    14bf:	mov    rdx,QWORD PTR [rsp+0x98]
    14c7:	mov    QWORD PTR [rsp+0x8],rdx
    14cc:	mov    rcx,r14
    14cf:	mov    rdx,r15
    14d2:	mov    rsi,QWORD PTR [rsp+0xb0]
    14da:	mov    rdi,QWORD PTR [rsp+0x90]
    14e2:	mov    r8,QWORD PTR [rsp+0xa8]
    14ea:	call   14ef <botlish_fn_16+0x1f7>
			14eb: R_X86_64_PLT32	botlish_fn_15-0x4 ; ht_rehash_scan<mutarray, mutarray, mutarray, int, int, HashTable, int>
    14ef:	test   rax,rax
    14f2:	jne    152f <botlish_fn_16+0x237>
    14f8:	xor    rax,rax
    14fb:	mov    rbx,QWORD PTR [rsp+0xc0]
    1503:	mov    r12,QWORD PTR [rsp+0xc8]
    150b:	mov    r13,QWORD PTR [rsp+0xd0]
    1513:	mov    r14,QWORD PTR [rsp+0xd8]
    151b:	mov    r15,QWORD PTR [rsp+0xe0]
    1523:	add    rsp,0xf0
    152a:	mov    rsp,rbp
    152d:	pop    rbp
    152e:	ret
    152f:	mov    rbx,QWORD PTR [rsp+0xc0]
    1537:	mov    r12,QWORD PTR [rsp+0xc8]
    153f:	mov    r13,QWORD PTR [rsp+0xd0]
    1547:	mov    r14,QWORD PTR [rsp+0xd8]
    154f:	mov    r15,QWORD PTR [rsp+0xe0]
    1557:	add    rsp,0xf0
    155e:	mov    rsp,rbp
    1561:	pop    rbp
    1562:	ret

0000000000001563 <botlish_entry_16: ht_rehash<HashTable, int>>:
    1563:	push   rbp
    1564:	mov    rbp,rsp
    1567:	mov    rsi,QWORD PTR [rdx]
    156a:	mov    rdx,QWORD PTR [rdx+0x8]
    156e:	call   1573 <botlish_entry_16+0x10>
			156f: R_X86_64_PLT32	botlish_fn_16-0x4 ; ht_rehash<HashTable, int>
    1573:	mov    rsp,rbp
    1576:	pop    rbp
    1577:	ret

0000000000001578 <botlish_fn_17: ht_should_grow<HashTable>>:
    1578:	push   rbp
    1579:	mov    rbp,rsp
    157c:	sub    rsp,0x40
    1580:	mov    QWORD PTR [rsp+0x20],rbx
    1585:	mov    QWORD PTR [rsp+0x28],r12
    158a:	mov    QWORD PTR [rsp+0x30],r13
    158f:	mov    rbx,rdi
    1592:	mov    QWORD PTR [rsp],rsi
    1596:	mov    r12,rsi
    1599:	mov    rsi,r12
    159c:	mov    rdi,rbx
    159f:	call   15a4 <botlish_fn_17+0x2c>
			15a0: R_X86_64_PLT32	botlish_fn_4-0x4 ; ht_size<HashTable>
    15a4:	mov    rcx,rax
    15a7:	mov    r13,rax
    15aa:	test   rax,rcx
    15ad:	je     1684 <botlish_fn_17+0x10c>
    15b3:	mov    rax,r13
    15b6:	mov    QWORD PTR [rsp+0x8],rax
    15bb:	mov    rsi,r12
    15be:	mov    rdi,rbx
    15c1:	call   15c6 <botlish_fn_17+0x4e>
			15c2: R_X86_64_PLT32	botlish_fn_5-0x4 ; ht_tombstones<HashTable>
    15c6:	mov    rcx,rax
    15c9:	test   rcx,rcx
    15cc:	je     1684 <botlish_fn_17+0x10c>
    15d2:	mov    QWORD PTR [rsp+0x10],rcx
    15d7:	mov    edx,0x1
    15dc:	mov    rax,r13
    15df:	test   rax,0x1
    15e5:	jne    1608 <botlish_fn_17+0x90>
    15eb:	xor    edx,edx
    15ed:	mov    rax,r13
    15f0:	test   rax,0x7
    15f6:	jne    1608 <botlish_fn_17+0x90>
    15fc:	mov    rax,r13
    15ff:	movzx  rax,BYTE PTR [rax]
    1603:	cmp    al,0x1
    1605:	sete   dl
    1608:	test   dl,dl
    160a:	jne    162a <botlish_fn_17+0xb2>
    1610:	mov    rdi,rbx
    1613:	mov    rax,QWORD PTR [rdi+0x10]
    1617:	mov    rcx,QWORD PTR [rax]
    161a:	xor    rdx,rdx
    161d:	mov    rsi,r13
    1620:	call   1625 <botlish_fn_17+0xad>
			1621: R_X86_64_PLT32	rt_type_error-0x4
    1625:	jmp    1684 <botlish_fn_17+0x10c>
    162a:	mov    eax,0x1
    162f:	test   rcx,0x1
    1636:	je     1644 <botlish_fn_17+0xcc>
    163c:	mov    r8,rcx
    163f:	jmp    1667 <botlish_fn_17+0xef>
    1644:	xor    eax,eax
    1646:	test   rcx,0x7
    164d:	je     165b <botlish_fn_17+0xe3>
    1653:	mov    r8,rcx
    1656:	jmp    1667 <botlish_fn_17+0xef>
    165b:	movzx  rax,BYTE PTR [rcx]
    165f:	mov    r8,rcx
    1662:	cmp    al,0x1
    1664:	sete   al
    1667:	test   al,al
    1669:	jne    169f <botlish_fn_17+0x127>
    166f:	mov    rdi,rbx
    1672:	mov    rax,QWORD PTR [rdi+0x10]
    1676:	mov    rcx,QWORD PTR [rax]
    1679:	xor    rdx,rdx
    167c:	mov    rsi,r8
    167f:	call   1684 <botlish_fn_17+0x10c>
			1680: R_X86_64_PLT32	rt_type_error-0x4
    1684:	xor    rax,rax
    1687:	mov    rbx,QWORD PTR [rsp+0x20]
    168c:	mov    r12,QWORD PTR [rsp+0x28]
    1691:	mov    r13,QWORD PTR [rsp+0x30]
    1696:	add    rsp,0x40
    169a:	mov    rsp,rbp
    169d:	pop    rbp
    169e:	ret
    169f:	mov    rcx,r8
    16a2:	mov    rsi,r13
    16a5:	mov    rax,rsi
    16a8:	and    rax,rcx
    16ab:	test   rax,0x1
    16b1:	jne    16c2 <botlish_fn_17+0x14a>
    16b7:	mov    rdx,r8
    16ba:	mov    rsi,r13
    16bd:	jmp    16e0 <botlish_fn_17+0x168>
    16c2:	mov    rcx,r8
    16c5:	lea    rax,[rcx-0x1]
    16c9:	mov    rsi,r13
    16cc:	add    rsi,rax
    16cf:	seto   al
    16d2:	test   al,al
    16d4:	je     16eb <botlish_fn_17+0x173>
    16da:	mov    rdx,r8
    16dd:	mov    rsi,r13
    16e0:	mov    rdi,rbx
    16e3:	call   16e8 <botlish_fn_17+0x170>
			16e4: R_X86_64_PLT32	rt_int_add-0x4
    16e8:	mov    rsi,rax
    16eb:	mov    QWORD PTR [rsp+0x8],rsi
    16f0:	mov    QWORD PTR [rsp+0x10],0x3
    16f9:	test   rsi,0x1
    1700:	je     1723 <botlish_fn_17+0x1ab>
    1706:	mov    rax,rsi
    1709:	add    rax,0x2
    170d:	mov    rcx,rax
    1710:	seto   al
    1713:	test   al,al
    1715:	jne    1723 <botlish_fn_17+0x1ab>
    171b:	mov    rsi,rcx
    171e:	jmp    1733 <botlish_fn_17+0x1bb>
    1723:	mov    edx,0x3
    1728:	mov    rdi,rbx
    172b:	call   1730 <botlish_fn_17+0x1b8>
			172c: R_X86_64_PLT32	rt_int_add-0x4
    1730:	mov    rsi,rax
    1733:	mov    QWORD PTR [rsp+0x8],rsi
    1738:	mov    edx,0x7
    173d:	mov    rdi,rdx
    1740:	mov    QWORD PTR [rsp+0x10],0x7
    1749:	test   rsi,0x1
    1750:	jne    175e <botlish_fn_17+0x1e6>
    1756:	mov    rdx,rdi
    1759:	jmp    178a <botlish_fn_17+0x212>
    175e:	mov    rax,rsi
    1761:	sar    rax,1
    1764:	imul   QWORD PTR [rip+0xf5]        # 1860 <botlish_fn_17+0x2e8>
    176b:	seto   cl
    176e:	or     rax,0x1
    1772:	test   cl,cl
    1774:	je     1782 <botlish_fn_17+0x20a>
    177a:	mov    rdx,rdi
    177d:	jmp    178a <botlish_fn_17+0x212>
    1782:	mov    rsi,rax
    1785:	jmp    1795 <botlish_fn_17+0x21d>
    178a:	mov    rdi,rbx
    178d:	call   1792 <botlish_fn_17+0x21a>
			178e: R_X86_64_PLT32	rt_int_mul-0x4
    1792:	mov    rsi,rax
    1795:	mov    QWORD PTR [rsp],rsi
    1799:	mov    r13,rsi
    179c:	mov    rsi,r12
    179f:	mov    rdi,rbx
    17a2:	call   17a7 <botlish_fn_17+0x22f>
			17a3: R_X86_64_PLT32	botlish_fn_6-0x4 ; ht_capacity<HashTable>
    17a7:	mov    QWORD PTR [rsp+0x8],rax
    17ac:	mov    QWORD PTR [rsp+0x10],0x5
    17b5:	test   rax,0x1
    17bb:	mov    rcx,rax
    17be:	je     17ed <botlish_fn_17+0x275>
    17c4:	mov    rax,rcx
    17c7:	sar    rax,1
    17ca:	imul   QWORD PTR [rip+0x97]        # 1868 <botlish_fn_17+0x2f0>
    17d1:	seto   sil
    17d5:	or     rax,0x1
    17d9:	test   sil,sil
    17dc:	jne    17ed <botlish_fn_17+0x275>
    17e2:	mov    rdx,rax
    17e5:	mov    rsi,r13
    17e8:	jmp    1803 <botlish_fn_17+0x28b>
    17ed:	mov    edx,0x5
    17f2:	mov    rsi,rcx
    17f5:	mov    rdi,rbx
    17f8:	call   17fd <botlish_fn_17+0x285>
			17f9: R_X86_64_PLT32	rt_int_mul-0x4
    17fd:	mov    rdx,rax
    1800:	mov    rsi,r13
    1803:	mov    rdi,rsi
    1806:	and    rdi,rdx
    1809:	test   rdi,0x1
    1810:	jne    1836 <botlish_fn_17+0x2be>
    1816:	mov    rdi,rbx
    1819:	call   181e <botlish_fn_17+0x2a6>
			181a: R_X86_64_PLT32	rt_int_cmp-0x4
    181e:	mov    esi,0x2
    1823:	test   rax,rax
    1826:	mov    rax,rsi
    1829:	cmovg  rax,QWORD PTR [rip+0x2f]        # 1860 <botlish_fn_17+0x2e8>
    1831:	jmp    1846 <botlish_fn_17+0x2ce>
    1836:	mov    eax,0x2
    183b:	cmp    rsi,rdx
    183e:	cmovg  rax,QWORD PTR [rip+0x1a]        # 1860 <botlish_fn_17+0x2e8>
    1846:	mov    rbx,QWORD PTR [rsp+0x20]
    184b:	mov    r12,QWORD PTR [rsp+0x28]
    1850:	mov    r13,QWORD PTR [rsp+0x30]
    1855:	add    rsp,0x40
    1859:	mov    rsp,rbp
    185c:	pop    rbp
    185d:	ret
    185e:	add    BYTE PTR [rax],al
    1860:	(bad)
    1861:	add    BYTE PTR [rax],al
    1863:	add    BYTE PTR [rax],al
    1865:	add    BYTE PTR [rax],al
    1867:	add    BYTE PTR [rax+rax*1],al
    186a:	add    BYTE PTR [rax],al
    186c:	add    BYTE PTR [rax],al
	...

0000000000001870 <botlish_entry_17: ht_should_grow<HashTable>>:
    1870:	push   rbp
    1871:	mov    rbp,rsp
    1874:	mov    rsi,QWORD PTR [rdx]
    1877:	call   187c <botlish_entry_17+0xc>
			1878: R_X86_64_PLT32	botlish_fn_17-0x4 ; ht_should_grow<HashTable>
    187c:	mov    rsp,rbp
    187f:	pop    rbp
    1880:	ret
    1881:	add    BYTE PTR [rax],al
    1883:	add    BYTE PTR [rax],al
    1885:	add    BYTE PTR [rax],al
	...

0000000000001888 <botlish_fn_18: ht_grow_or_clean<HashTable>>:
    1888:	push   rbp
    1889:	mov    rbp,rsp
    188c:	sub    rsp,0x40
    1890:	mov    QWORD PTR [rsp+0x20],rbx
    1895:	mov    QWORD PTR [rsp+0x28],r12
    189a:	mov    QWORD PTR [rsp+0x30],r13
    189f:	mov    rbx,rdi
    18a2:	mov    QWORD PTR [rsp+0x10],0x0
    18ab:	mov    QWORD PTR [rsp],rsi
    18af:	mov    r12,rsi
    18b2:	mov    rsi,r12
    18b5:	mov    rdi,rbx
    18b8:	call   18bd <botlish_fn_18+0x35>
			18b9: R_X86_64_PLT32	botlish_fn_5-0x4 ; ht_tombstones<HashTable>
    18bd:	test   rax,rax
    18c0:	mov    r13,rax
    18c3:	je     1ab1 <botlish_fn_18+0x229>
    18c9:	mov    rsi,r12
    18cc:	mov    rdi,rbx
    18cf:	call   18d4 <botlish_fn_18+0x4c>
			18d0: R_X86_64_PLT32	botlish_fn_4-0x4 ; ht_size<HashTable>
    18d4:	mov    r11,rax
    18d7:	test   r11,r11
    18da:	je     1ab1 <botlish_fn_18+0x229>
    18e0:	mov    ecx,0x1
    18e5:	mov    rax,r13
    18e8:	test   rax,0x1
    18ee:	je     18fc <botlish_fn_18+0x74>
    18f4:	mov    r13,rax
    18f7:	jmp    1920 <botlish_fn_18+0x98>
    18fc:	xor    ecx,ecx
    18fe:	test   rax,0x7
    1904:	je     1912 <botlish_fn_18+0x8a>
    190a:	mov    r13,rax
    190d:	jmp    1920 <botlish_fn_18+0x98>
    1912:	movzx  rcx,BYTE PTR [rax]
    1916:	mov    r13,rax
    1919:	rex cmp cl,0x1
    191d:	sete   cl
    1920:	test   cl,cl
    1922:	jne    1943 <botlish_fn_18+0xbb>
    1928:	mov    rdi,rbx
    192b:	mov    rsi,QWORD PTR [rdi+0x10]
    192f:	mov    rcx,QWORD PTR [rsi+0x8]
    1933:	xor    rdx,rdx
    1936:	mov    rsi,r13
    1939:	call   193e <botlish_fn_18+0xb6>
			193a: R_X86_64_PLT32	rt_type_error-0x4
    193e:	jmp    1ab1 <botlish_fn_18+0x229>
    1943:	mov    rsi,r13
    1946:	mov    eax,0x1
    194b:	test   r11,0x1
    1952:	je     1960 <botlish_fn_18+0xd8>
    1958:	mov    r8,r11
    195b:	jmp    1985 <botlish_fn_18+0xfd>
    1960:	xor    eax,eax
    1962:	test   r11,0x7
    1969:	je     1977 <botlish_fn_18+0xef>
    196f:	mov    r8,r11
    1972:	jmp    1985 <botlish_fn_18+0xfd>
    1977:	movzx  r10,BYTE PTR [r11]
    197b:	mov    r8,r11
    197e:	cmp    r10b,0x1
    1982:	sete   al
    1985:	test   al,al
    1987:	jne    19a8 <botlish_fn_18+0x120>
    198d:	mov    rdi,rbx
    1990:	mov    rax,QWORD PTR [rdi+0x10]
    1994:	mov    rcx,QWORD PTR [rax+0x8]
    1998:	xor    rdx,rdx
    199b:	mov    rsi,r8
    199e:	call   19a3 <botlish_fn_18+0x11b>
			199f: R_X86_64_PLT32	rt_type_error-0x4
    19a3:	jmp    1ab1 <botlish_fn_18+0x229>
    19a8:	mov    r11,r8
    19ab:	mov    rax,rsi
    19ae:	and    rax,r11
    19b1:	test   rax,0x1
    19b7:	jne    19dd <botlish_fn_18+0x155>
    19bd:	mov    rdx,r8
    19c0:	mov    rdi,rbx
    19c3:	call   19c8 <botlish_fn_18+0x140>
			19c4: R_X86_64_PLT32	rt_int_cmp-0x4
    19c8:	mov    ecx,0x2
    19cd:	test   rax,rax
    19d0:	cmovg  rcx,QWORD PTR [rip+0x110]        # 1ae8 <botlish_fn_18+0x260>
    19d8:	jmp    19f0 <botlish_fn_18+0x168>
    19dd:	mov    ecx,0x2
    19e2:	mov    r11,r8
    19e5:	cmp    rsi,r11
    19e8:	cmovg  rcx,QWORD PTR [rip+0xf8]        # 1ae8 <botlish_fn_18+0x260>
    19f0:	cmp    rcx,0x6
    19f4:	je     1a8a <botlish_fn_18+0x202>
    19fa:	mov    rsi,r12
    19fd:	mov    rdi,rbx
    1a00:	call   1a05 <botlish_fn_18+0x17d>
			1a01: R_X86_64_PLT32	botlish_fn_6-0x4 ; ht_capacity<HashTable>
    1a05:	mov    QWORD PTR [rsp+0x8],rax
    1a0a:	mov    QWORD PTR [rsp+0x10],0x5
    1a13:	test   rax,0x1
    1a19:	mov    rsi,rax
    1a1c:	je     1a49 <botlish_fn_18+0x1c1>
    1a22:	mov    rcx,rsi
    1a25:	mov    rax,rcx
    1a28:	sar    rax,1
    1a2b:	imul   QWORD PTR [rip+0xbe]        # 1af0 <botlish_fn_18+0x268>
    1a32:	seto   cl
    1a35:	or     rax,0x1
    1a39:	test   cl,cl
    1a3b:	jne    1a49 <botlish_fn_18+0x1c1>
    1a41:	mov    rdx,rax
    1a44:	jmp    1a59 <botlish_fn_18+0x1d1>
    1a49:	mov    edx,0x5
    1a4e:	mov    rdi,rbx
    1a51:	call   1a56 <botlish_fn_18+0x1ce>
			1a52: R_X86_64_PLT32	rt_int_mul-0x4
    1a56:	mov    rdx,rax
    1a59:	mov    QWORD PTR [rsp+0x8],rdx
    1a5e:	mov    rsi,r12
    1a61:	mov    rdi,rbx
    1a64:	call   1a69 <botlish_fn_18+0x1e1>
			1a65: R_X86_64_PLT32	botlish_fn_16-0x4 ; ht_rehash<HashTable, int>
    1a69:	test   rax,rax
    1a6c:	je     1ab1 <botlish_fn_18+0x229>
    1a72:	mov    rbx,QWORD PTR [rsp+0x20]
    1a77:	mov    r12,QWORD PTR [rsp+0x28]
    1a7c:	mov    r13,QWORD PTR [rsp+0x30]
    1a81:	add    rsp,0x40
    1a85:	mov    rsp,rbp
    1a88:	pop    rbp
    1a89:	ret
    1a8a:	mov    rsi,r12
    1a8d:	mov    rdi,rbx
    1a90:	call   1a95 <botlish_fn_18+0x20d>
			1a91: R_X86_64_PLT32	botlish_fn_6-0x4 ; ht_capacity<HashTable>
    1a95:	mov    QWORD PTR [rsp+0x8],rax
    1a9a:	mov    rdx,rax
    1a9d:	mov    rsi,r12
    1aa0:	mov    rdi,rbx
    1aa3:	call   1aa8 <botlish_fn_18+0x220>
			1aa4: R_X86_64_PLT32	botlish_fn_16-0x4 ; ht_rehash<HashTable, int>
    1aa8:	test   rax,rax
    1aab:	jne    1acc <botlish_fn_18+0x244>
    1ab1:	xor    rax,rax
    1ab4:	mov    rbx,QWORD PTR [rsp+0x20]
    1ab9:	mov    r12,QWORD PTR [rsp+0x28]
    1abe:	mov    r13,QWORD PTR [rsp+0x30]
    1ac3:	add    rsp,0x40
    1ac7:	mov    rsp,rbp
    1aca:	pop    rbp
    1acb:	ret
    1acc:	mov    rbx,QWORD PTR [rsp+0x20]
    1ad1:	mov    r12,QWORD PTR [rsp+0x28]
    1ad6:	mov    r13,QWORD PTR [rsp+0x30]
    1adb:	add    rsp,0x40
    1adf:	mov    rsp,rbp
    1ae2:	pop    rbp
    1ae3:	ret
    1ae4:	add    BYTE PTR [rax],al
    1ae6:	add    BYTE PTR [rax],al
    1ae8:	(bad)
    1ae9:	add    BYTE PTR [rax],al
    1aeb:	add    BYTE PTR [rax],al
    1aed:	add    BYTE PTR [rax],al
    1aef:	add    BYTE PTR [rax+rax*1],al
    1af2:	add    BYTE PTR [rax],al
    1af4:	add    BYTE PTR [rax],al
	...

0000000000001af8 <botlish_entry_18: ht_grow_or_clean<HashTable>>:
    1af8:	push   rbp
    1af9:	mov    rbp,rsp
    1afc:	mov    rsi,QWORD PTR [rdx]
    1aff:	call   1b04 <botlish_entry_18+0xc>
			1b00: R_X86_64_PLT32	botlish_fn_18-0x4 ; ht_grow_or_clean<HashTable>
    1b04:	mov    rsp,rbp
    1b07:	pop    rbp
    1b08:	ret
    1b09:	add    BYTE PTR [rax],al
    1b0b:	add    BYTE PTR [rax],al
    1b0d:	add    BYTE PTR [rax],al
	...

0000000000001b10 <botlish_fn_19: ht_place<HashTable, int, str, str>>:
    1b10:	push   rbp
    1b11:	mov    rbp,rsp
    1b14:	sub    rsp,0x70
    1b18:	mov    QWORD PTR [rsp+0x40],rbx
    1b1d:	mov    QWORD PTR [rsp+0x48],r12
    1b22:	mov    QWORD PTR [rsp+0x50],r13
    1b27:	mov    QWORD PTR [rsp+0x58],r14
    1b2c:	mov    QWORD PTR [rsp+0x60],r15
    1b31:	mov    r12,rdi
    1b34:	mov    r14,r8
    1b37:	mov    r15,rdx
    1b3a:	mov    QWORD PTR [rsp+0x30],rcx
    1b3f:	mov    QWORD PTR [rsp],rsi
    1b43:	mov    r9,QWORD PTR [rsi+0x18]
    1b47:	mov    r13,rsi
    1b4a:	mov    rsi,QWORD PTR [r9]
    1b4d:	mov    rdx,r15
    1b50:	mov    rdi,r12
    1b53:	call   1b58 <botlish_fn_19+0x48>
			1b54: R_X86_64_PLT32	rt_mutarray_get-0x4
    1b58:	test   rax,rax
    1b5b:	je     1def <botlish_fn_19+0x2df>
    1b61:	mov    QWORD PTR [rsp+0x8],rax
    1b66:	mov    rbx,r13
    1b69:	mov    r13,rax
    1b6c:	mov    rax,QWORD PTR [rbx+0x18]
    1b70:	mov    rsi,QWORD PTR [rax]
    1b73:	mov    ecx,0x3
    1b78:	mov    rdx,r15
    1b7b:	mov    rdi,r12
    1b7e:	call   1b83 <botlish_fn_19+0x73>
			1b7f: R_X86_64_PLT32	rt_mutarray_set-0x4
    1b83:	test   rax,rax
    1b86:	je     1def <botlish_fn_19+0x2df>
    1b8c:	mov    rax,QWORD PTR [rbx+0x18]
    1b90:	mov    rsi,QWORD PTR [rax+0x8]
    1b94:	mov    rcx,QWORD PTR [rsp+0x30]
    1b99:	mov    rdx,r15
    1b9c:	mov    rdi,r12
    1b9f:	call   1ba4 <botlish_fn_19+0x94>
			1ba0: R_X86_64_PLT32	rt_mutarray_set-0x4
    1ba4:	test   rax,rax
    1ba7:	je     1def <botlish_fn_19+0x2df>
    1bad:	mov    rax,QWORD PTR [rbx+0x18]
    1bb1:	mov    rsi,QWORD PTR [rax+0x10]
    1bb5:	mov    rcx,r14
    1bb8:	mov    rdx,r15
    1bbb:	mov    rdi,r12
    1bbe:	call   1bc3 <botlish_fn_19+0xb3>
			1bbf: R_X86_64_PLT32	rt_mutarray_set-0x4
    1bc3:	test   rax,rax
    1bc6:	je     1def <botlish_fn_19+0x2df>
    1bcc:	mov    rax,QWORD PTR [rbx+0x18]
    1bd0:	mov    rsi,QWORD PTR [rax+0x18]
    1bd4:	mov    QWORD PTR [rsp+0x10],rsi
    1bd9:	mov    r14,rsi
    1bdc:	mov    QWORD PTR [rsp+0x18],0x1
    1be5:	mov    rsi,rbx
    1be8:	mov    rdi,r12
    1beb:	call   1bf0 <botlish_fn_19+0xe0>
			1bec: R_X86_64_PLT32	botlish_fn_4-0x4 ; ht_size<HashTable>
    1bf0:	test   rax,rax
    1bf3:	je     1def <botlish_fn_19+0x2df>
    1bf9:	mov    QWORD PTR [rsp+0x20],rax
    1bfe:	mov    QWORD PTR [rsp+0x28],0x3
    1c07:	mov    ecx,0x1
    1c0c:	test   rax,0x1
    1c12:	je     1c20 <botlish_fn_19+0x110>
    1c18:	mov    rsi,rax
    1c1b:	jmp    1c44 <botlish_fn_19+0x134>
    1c20:	xor    ecx,ecx
    1c22:	test   rax,0x7
    1c28:	je     1c36 <botlish_fn_19+0x126>
    1c2e:	mov    rsi,rax
    1c31:	jmp    1c44 <botlish_fn_19+0x134>
    1c36:	movzx  rcx,BYTE PTR [rax]
    1c3a:	mov    rsi,rax
    1c3d:	rex cmp cl,0x1
    1c41:	sete   cl
    1c44:	test   cl,cl
    1c46:	jne    1c63 <botlish_fn_19+0x153>
    1c4c:	mov    rdi,r12
    1c4f:	mov    rax,QWORD PTR [rdi+0x10]
    1c53:	mov    rcx,QWORD PTR [rax]
    1c56:	xor    rdx,rdx
    1c59:	call   1c5e <botlish_fn_19+0x14e>
			1c5a: R_X86_64_PLT32	rt_type_error-0x4
    1c5e:	jmp    1def <botlish_fn_19+0x2df>
    1c63:	test   rsi,0x1
    1c6a:	je     1c82 <botlish_fn_19+0x172>
    1c70:	mov    rcx,rsi
    1c73:	add    rcx,0x2
    1c77:	seto   al
    1c7a:	test   al,al
    1c7c:	je     1c92 <botlish_fn_19+0x182>
    1c82:	mov    edx,0x3
    1c87:	mov    rdi,r12
    1c8a:	call   1c8f <botlish_fn_19+0x17f>
			1c8b: R_X86_64_PLT32	rt_int_add-0x4
    1c8f:	mov    rcx,rax
    1c92:	mov    edx,0x1
    1c97:	mov    rsi,r14
    1c9a:	mov    rdi,r12
    1c9d:	call   1ca2 <botlish_fn_19+0x192>
			1c9e: R_X86_64_PLT32	rt_mutarray_set-0x4
    1ca2:	test   rax,rax
    1ca5:	je     1def <botlish_fn_19+0x2df>
    1cab:	mov    rax,r13
    1cae:	test   rax,0x1
    1cb4:	jne    1cdf <botlish_fn_19+0x1cf>
    1cba:	mov    edx,0x5
    1cbf:	mov    rsi,r13
    1cc2:	mov    rdi,r12
    1cc5:	call   1cca <botlish_fn_19+0x1ba>
			1cc6: R_X86_64_PLT32	rt_int_cmp-0x4
    1cca:	mov    ecx,0x2
    1ccf:	test   rax,rax
    1cd2:	cmove  rcx,QWORD PTR [rip+0x166]        # 1e40 <botlish_fn_19+0x330>
    1cda:	jmp    1cf3 <botlish_fn_19+0x1e3>
    1cdf:	mov    rsi,r13
    1ce2:	mov    ecx,0x2
    1ce7:	cmp    rsi,0x5
    1ceb:	cmove  rcx,QWORD PTR [rip+0x14d]        # 1e40 <botlish_fn_19+0x330>
    1cf3:	cmp    rcx,0x6
    1cf7:	je     1d05 <botlish_fn_19+0x1f5>
    1cfd:	mov    rax,rbx
    1d00:	jmp    1e17 <botlish_fn_19+0x307>
    1d05:	mov    rax,QWORD PTR [rbx+0x18]
    1d09:	mov    rsi,QWORD PTR [rax+0x18]
    1d0d:	mov    QWORD PTR [rsp+0x8],rsi
    1d12:	mov    r14,rsi
    1d15:	mov    QWORD PTR [rsp+0x10],0x3
    1d1e:	mov    rsi,rbx
    1d21:	mov    rdi,r12
    1d24:	call   1d29 <botlish_fn_19+0x219>
			1d25: R_X86_64_PLT32	botlish_fn_5-0x4 ; ht_tombstones<HashTable>
    1d29:	mov    r13,rbx
    1d2c:	test   rax,rax
    1d2f:	je     1def <botlish_fn_19+0x2df>
    1d35:	mov    QWORD PTR [rsp+0x18],rax
    1d3a:	mov    QWORD PTR [rsp+0x20],0x3
    1d43:	mov    ecx,0x1
    1d48:	test   rax,0x1
    1d4e:	je     1d5c <botlish_fn_19+0x24c>
    1d54:	mov    rsi,rax
    1d57:	jmp    1d80 <botlish_fn_19+0x270>
    1d5c:	xor    ecx,ecx
    1d5e:	test   rax,0x7
    1d64:	je     1d72 <botlish_fn_19+0x262>
    1d6a:	mov    rsi,rax
    1d6d:	jmp    1d80 <botlish_fn_19+0x270>
    1d72:	movzx  r10,BYTE PTR [rax]
    1d76:	mov    rsi,rax
    1d79:	cmp    r10b,0x1
    1d7d:	sete   cl
    1d80:	test   cl,cl
    1d82:	jne    1da0 <botlish_fn_19+0x290>
    1d88:	mov    rdi,r12
    1d8b:	mov    rax,QWORD PTR [rdi+0x10]
    1d8f:	mov    rcx,QWORD PTR [rax+0x10]
    1d93:	xor    rdx,rdx
    1d96:	call   1d9b <botlish_fn_19+0x28b>
			1d97: R_X86_64_PLT32	rt_type_error-0x4
    1d9b:	jmp    1def <botlish_fn_19+0x2df>
    1da0:	test   rsi,0x1
    1da7:	je     1dc6 <botlish_fn_19+0x2b6>
    1dad:	mov    rcx,rsi
    1db0:	sub    rcx,0x3
    1db4:	seto   al
    1db7:	add    rcx,0x1
    1dbe:	test   al,al
    1dc0:	je     1dd6 <botlish_fn_19+0x2c6>
    1dc6:	mov    edx,0x3
    1dcb:	mov    rdi,r12
    1dce:	call   1dd3 <botlish_fn_19+0x2c3>
			1dcf: R_X86_64_PLT32	rt_int_sub-0x4
    1dd3:	mov    rcx,rax
    1dd6:	mov    edx,0x3
    1ddb:	mov    rsi,r14
    1dde:	mov    rdi,r12
    1de1:	call   1de6 <botlish_fn_19+0x2d6>
			1de2: R_X86_64_PLT32	rt_mutarray_set-0x4
    1de6:	test   rax,rax
    1de9:	jne    1e14 <botlish_fn_19+0x304>
    1def:	xor    rax,rax
    1df2:	mov    rbx,QWORD PTR [rsp+0x40]
    1df7:	mov    r12,QWORD PTR [rsp+0x48]
    1dfc:	mov    r13,QWORD PTR [rsp+0x50]
    1e01:	mov    r14,QWORD PTR [rsp+0x58]
    1e06:	mov    r15,QWORD PTR [rsp+0x60]
    1e0b:	add    rsp,0x70
    1e0f:	mov    rsp,rbp
    1e12:	pop    rbp
    1e13:	ret
    1e14:	mov    rax,r13
    1e17:	mov    rbx,QWORD PTR [rsp+0x40]
    1e1c:	mov    r12,QWORD PTR [rsp+0x48]
    1e21:	mov    r13,QWORD PTR [rsp+0x50]
    1e26:	mov    r14,QWORD PTR [rsp+0x58]
    1e2b:	mov    r15,QWORD PTR [rsp+0x60]
    1e30:	add    rsp,0x70
    1e34:	mov    rsp,rbp
    1e37:	pop    rbp
    1e38:	ret
    1e39:	add    BYTE PTR [rax],al
    1e3b:	add    BYTE PTR [rax],al
    1e3d:	add    BYTE PTR [rax],al
    1e3f:	add    BYTE PTR [rsi],al
    1e41:	add    BYTE PTR [rax],al
    1e43:	add    BYTE PTR [rax],al
    1e45:	add    BYTE PTR [rax],al
	...

0000000000001e48 <botlish_entry_19: ht_place<HashTable, int, str, str>>:
    1e48:	push   rbp
    1e49:	mov    rbp,rsp
    1e4c:	mov    rsi,QWORD PTR [rdx]
    1e4f:	mov    r9,QWORD PTR [rdx+0x8]
    1e53:	mov    rcx,QWORD PTR [rdx+0x10]
    1e57:	mov    r8,QWORD PTR [rdx+0x18]
    1e5b:	mov    rdx,r9
    1e5e:	call   1e63 <botlish_entry_19+0x1b>
			1e5f: R_X86_64_PLT32	botlish_fn_19-0x4 ; ht_place<HashTable, int, str, str>
    1e63:	mov    rsp,rbp
    1e66:	pop    rbp
    1e67:	ret

0000000000001e68 <botlish_fn_20: ht_set<HashTable, str, str>>:
    1e68:	push   rbp
    1e69:	mov    rbp,rsp
    1e6c:	sub    rsp,0x60
    1e70:	mov    QWORD PTR [rsp+0x30],rbx
    1e75:	mov    QWORD PTR [rsp+0x38],r12
    1e7a:	mov    QWORD PTR [rsp+0x40],r13
    1e7f:	mov    QWORD PTR [rsp+0x48],r14
    1e84:	mov    QWORD PTR [rsp+0x50],r15
    1e89:	mov    r12,rdi
    1e8c:	mov    QWORD PTR [rsp+0x18],0x0
    1e95:	mov    QWORD PTR [rsp+0x20],0x0
    1e9e:	mov    QWORD PTR [rsp],rsi
    1ea2:	mov    r14,rsi
    1ea5:	mov    QWORD PTR [rsp+0x8],rdx
    1eaa:	mov    r13,rdx
    1ead:	mov    QWORD PTR [rsp+0x10],rcx
    1eb2:	mov    rbx,rcx
    1eb5:	mov    rdx,r13
    1eb8:	mov    rsi,r14
    1ebb:	mov    rdi,r12
    1ebe:	call   1ec3 <botlish_fn_20+0x5b>
			1ebf: R_X86_64_PLT32	botlish_fn_7-0x4 ; ht_probe_start<HashTable, str>
    1ec3:	test   rax,rax
    1ec6:	je     209e <botlish_fn_20+0x236>
    1ecc:	mov    QWORD PTR [rsp+0x18],rax
    1ed1:	mov    rcx,rax
    1ed4:	mov    r8,0xffffffffffffffff
    1edb:	mov    r15,r8
    1ede:	mov    QWORD PTR [rsp+0x20],0xffffffffffffffff
    1ee7:	mov    rdx,r13
    1eea:	mov    rsi,r14
    1eed:	mov    rdi,r12
    1ef0:	call   1ef5 <botlish_fn_20+0x8d>
			1ef1: R_X86_64_PLT32	botlish_fn_10-0x4 ; ht_find_insert<HashTable, str, int, int>
    1ef5:	test   rax,rax
    1ef8:	je     209e <botlish_fn_20+0x236>
    1efe:	mov    QWORD PTR [rsp+0x18],rax
    1f03:	mov    rsi,r14
    1f06:	mov    QWORD PTR [rsp+0x28],rax
    1f0b:	mov    rax,QWORD PTR [rsi+0x18]
    1f0f:	mov    rsi,QWORD PTR [rax]
    1f12:	mov    rdx,QWORD PTR [rsp+0x28]
    1f17:	mov    rdi,r12
    1f1a:	call   1f1f <botlish_fn_20+0xb7>
			1f1b: R_X86_64_PLT32	rt_mutarray_get-0x4
    1f1f:	test   rax,rax
    1f22:	je     209e <botlish_fn_20+0x236>
    1f28:	test   rax,0x1
    1f2e:	mov    rsi,rax
    1f31:	jne    1f59 <botlish_fn_20+0xf1>
    1f37:	mov    edx,0x3
    1f3c:	mov    rdi,r12
    1f3f:	call   1f44 <botlish_fn_20+0xdc>
			1f40: R_X86_64_PLT32	rt_int_cmp-0x4
    1f44:	mov    ecx,0x2
    1f49:	test   rax,rax
    1f4c:	cmove  rcx,QWORD PTR [rip+0x194]        # 20e8 <botlish_fn_20+0x280>
    1f54:	jmp    1f6a <botlish_fn_20+0x102>
    1f59:	mov    ecx,0x2
    1f5e:	cmp    rsi,0x3
    1f62:	cmove  rcx,QWORD PTR [rip+0x17e]        # 20e8 <botlish_fn_20+0x280>
    1f6a:	cmp    rcx,0x6
    1f6e:	je     207a <botlish_fn_20+0x212>
    1f74:	mov    rsi,r14
    1f77:	mov    rdi,r12
    1f7a:	call   1f7f <botlish_fn_20+0x117>
			1f7b: R_X86_64_PLT32	botlish_fn_17-0x4 ; ht_should_grow<HashTable>
    1f7f:	test   rax,rax
    1f82:	je     209e <botlish_fn_20+0x236>
    1f88:	cmp    rax,0x6
    1f8c:	je     1fd3 <botlish_fn_20+0x16b>
    1f92:	mov    rcx,r13
    1f95:	mov    rdx,QWORD PTR [rsp+0x28]
    1f9a:	mov    rsi,r14
    1f9d:	mov    rdi,r12
    1fa0:	mov    r8,rbx
    1fa3:	call   1fa8 <botlish_fn_20+0x140>
			1fa4: R_X86_64_PLT32	botlish_fn_19-0x4 ; ht_place<HashTable, int, str, str>
    1fa8:	test   rax,rax
    1fab:	je     209e <botlish_fn_20+0x236>
    1fb1:	mov    rbx,QWORD PTR [rsp+0x30]
    1fb6:	mov    r12,QWORD PTR [rsp+0x38]
    1fbb:	mov    r13,QWORD PTR [rsp+0x40]
    1fc0:	mov    r14,QWORD PTR [rsp+0x48]
    1fc5:	mov    r15,QWORD PTR [rsp+0x50]
    1fca:	add    rsp,0x60
    1fce:	mov    rsp,rbp
    1fd1:	pop    rbp
    1fd2:	ret
    1fd3:	mov    rsi,r14
    1fd6:	mov    rdi,r12
    1fd9:	call   1fde <botlish_fn_20+0x176>
			1fda: R_X86_64_PLT32	botlish_fn_18-0x4 ; ht_grow_or_clean<HashTable>
    1fde:	mov    rcx,rax
    1fe1:	mov    r14,rax
    1fe4:	test   rax,rcx
    1fe7:	je     209e <botlish_fn_20+0x236>
    1fed:	mov    rax,r14
    1ff0:	mov    QWORD PTR [rsp],rax
    1ff4:	mov    rdx,r13
    1ff7:	mov    rsi,r14
    1ffa:	mov    rdi,r12
    1ffd:	call   2002 <botlish_fn_20+0x19a>
			1ffe: R_X86_64_PLT32	botlish_fn_7-0x4 ; ht_probe_start<HashTable, str>
    2002:	test   rax,rax
    2005:	je     209e <botlish_fn_20+0x236>
    200b:	mov    QWORD PTR [rsp+0x18],rax
    2010:	mov    rcx,rax
    2013:	mov    QWORD PTR [rsp+0x20],0xffffffffffffffff
    201c:	mov    r8,r15
    201f:	mov    rdx,r13
    2022:	mov    rsi,r14
    2025:	mov    rdi,r12
    2028:	call   202d <botlish_fn_20+0x1c5>
			2029: R_X86_64_PLT32	botlish_fn_10-0x4 ; ht_find_insert<HashTable, str, int, int>
    202d:	test   rax,rax
    2030:	je     209e <botlish_fn_20+0x236>
    2036:	mov    QWORD PTR [rsp+0x18],rax
    203b:	mov    rcx,r13
    203e:	mov    rdx,rax
    2041:	mov    rsi,r14
    2044:	mov    rdi,r12
    2047:	mov    r8,rbx
    204a:	call   204f <botlish_fn_20+0x1e7>
			204b: R_X86_64_PLT32	botlish_fn_19-0x4 ; ht_place<HashTable, int, str, str>
    204f:	test   rax,rax
    2052:	je     209e <botlish_fn_20+0x236>
    2058:	mov    rbx,QWORD PTR [rsp+0x30]
    205d:	mov    r12,QWORD PTR [rsp+0x38]
    2062:	mov    r13,QWORD PTR [rsp+0x40]
    2067:	mov    r14,QWORD PTR [rsp+0x48]
    206c:	mov    r15,QWORD PTR [rsp+0x50]
    2071:	add    rsp,0x60
    2075:	mov    rsp,rbp
    2078:	pop    rbp
    2079:	ret
    207a:	mov    rdx,QWORD PTR [rsp+0x28]
    207f:	mov    rsi,r14
    2082:	mov    rax,QWORD PTR [rsi+0x18]
    2086:	mov    rsi,QWORD PTR [rax+0x10]
    208a:	mov    rcx,rbx
    208d:	mov    rdi,r12
    2090:	call   2095 <botlish_fn_20+0x22d>
			2091: R_X86_64_PLT32	rt_mutarray_set-0x4
    2095:	test   rax,rax
    2098:	jne    20c3 <botlish_fn_20+0x25b>
    209e:	xor    rax,rax
    20a1:	mov    rbx,QWORD PTR [rsp+0x30]
    20a6:	mov    r12,QWORD PTR [rsp+0x38]
    20ab:	mov    r13,QWORD PTR [rsp+0x40]
    20b0:	mov    r14,QWORD PTR [rsp+0x48]
    20b5:	mov    r15,QWORD PTR [rsp+0x50]
    20ba:	add    rsp,0x60
    20be:	mov    rsp,rbp
    20c1:	pop    rbp
    20c2:	ret
    20c3:	mov    rax,r14
    20c6:	mov    rbx,QWORD PTR [rsp+0x30]
    20cb:	mov    r12,QWORD PTR [rsp+0x38]
    20d0:	mov    r13,QWORD PTR [rsp+0x40]
    20d5:	mov    r14,QWORD PTR [rsp+0x48]
    20da:	mov    r15,QWORD PTR [rsp+0x50]
    20df:	add    rsp,0x60
    20e3:	mov    rsp,rbp
    20e6:	pop    rbp
    20e7:	ret
    20e8:	(bad)
    20e9:	add    BYTE PTR [rax],al
    20eb:	add    BYTE PTR [rax],al
    20ed:	add    BYTE PTR [rax],al
	...

00000000000020f0 <botlish_entry_20: ht_set<HashTable, str, str>>:
    20f0:	push   rbp
    20f1:	mov    rbp,rsp
    20f4:	mov    rsi,QWORD PTR [rdx]
    20f7:	mov    r8,QWORD PTR [rdx+0x8]
    20fb:	mov    rcx,QWORD PTR [rdx+0x10]
    20ff:	mov    rdx,r8
    2102:	call   2107 <botlish_entry_20+0x17>
			2103: R_X86_64_PLT32	botlish_fn_20-0x4 ; ht_set<HashTable, str, str>
    2107:	mov    rsp,rbp
    210a:	pop    rbp
    210b:	ret
    210c:	add    BYTE PTR [rax],al
	...

0000000000002110 <botlish_fn_21: ht_delete<HashTable, str>>:
    2110:	push   rbp
    2111:	mov    rbp,rsp
    2114:	sub    rsp,0x50
    2118:	mov    QWORD PTR [rsp+0x30],rbx
    211d:	mov    QWORD PTR [rsp+0x38],r12
    2122:	mov    QWORD PTR [rsp+0x40],r13
    2127:	mov    QWORD PTR [rsp+0x48],r14
    212c:	mov    r13,rdi
    212f:	mov    QWORD PTR [rsp+0x10],0x0
    2138:	mov    QWORD PTR [rsp+0x18],0x0
    2141:	mov    QWORD PTR [rsp+0x20],0x0
    214a:	mov    QWORD PTR [rsp],rsi
    214e:	mov    r12,rsi
    2151:	mov    QWORD PTR [rsp+0x8],rdx
    2156:	mov    r14,rdx
    2159:	mov    rbx,r12
    215c:	mov    rdx,r14
    215f:	mov    rsi,rbx
    2162:	mov    rdi,r13
    2165:	call   216a <botlish_fn_21+0x5a>
			2166: R_X86_64_PLT32	botlish_fn_7-0x4 ; ht_probe_start<HashTable, str>
    216a:	test   rax,rax
    216d:	je     2421 <botlish_fn_21+0x311>
    2173:	mov    QWORD PTR [rsp+0x10],rax
    2178:	mov    rcx,rax
    217b:	mov    rdx,r14
    217e:	mov    rsi,rbx
    2181:	mov    rdi,r13
    2184:	call   2189 <botlish_fn_21+0x79>
			2185: R_X86_64_PLT32	botlish_fn_9-0x4 ; ht_find_get<HashTable, str, int>
    2189:	mov    rcx,rax
    218c:	mov    r12,rax
    218f:	test   rax,rcx
    2192:	je     2421 <botlish_fn_21+0x311>
    2198:	mov    rax,r12
    219b:	test   rax,0x1
    21a1:	jne    21cc <botlish_fn_21+0xbc>
    21a7:	mov    edx,0x1
    21ac:	mov    rsi,r12
    21af:	mov    rdi,r13
    21b2:	call   21b7 <botlish_fn_21+0xa7>
			21b3: R_X86_64_PLT32	rt_int_cmp-0x4
    21b7:	mov    ecx,0x2
    21bc:	test   rax,rax
    21bf:	cmovge rcx,QWORD PTR [rip+0x2a1]        # 2468 <botlish_fn_21+0x358>
    21c7:	jmp    21dc <botlish_fn_21+0xcc>
    21cc:	mov    ecx,0x2
    21d1:	test   r12,r12
    21d4:	cmovg  rcx,QWORD PTR [rip+0x28c]        # 2468 <botlish_fn_21+0x358>
    21dc:	cmp    rcx,0x6
    21e0:	je     21ee <botlish_fn_21+0xde>
    21e6:	mov    rax,rbx
    21e9:	jmp    2444 <botlish_fn_21+0x334>
    21ee:	mov    rcx,QWORD PTR [rbx+0x18]
    21f2:	mov    rsi,QWORD PTR [rcx]
    21f5:	mov    ecx,0x5
    21fa:	mov    rdx,r12
    21fd:	mov    rdi,r13
    2200:	call   2205 <botlish_fn_21+0xf5>
			2201: R_X86_64_PLT32	rt_mutarray_set-0x4
    2205:	test   rax,rax
    2208:	je     2421 <botlish_fn_21+0x311>
    220e:	mov    rax,QWORD PTR [rbx+0x18]
    2212:	mov    rsi,QWORD PTR [rax+0x8]
    2216:	mov    ecx,0xa
    221b:	mov    rdx,r12
    221e:	mov    rdi,r13
    2221:	call   2226 <botlish_fn_21+0x116>
			2222: R_X86_64_PLT32	rt_mutarray_set-0x4
    2226:	test   rax,rax
    2229:	je     2421 <botlish_fn_21+0x311>
    222f:	mov    rax,QWORD PTR [rbx+0x18]
    2233:	mov    rsi,QWORD PTR [rax+0x10]
    2237:	mov    ecx,0xa
    223c:	mov    rdx,r12
    223f:	mov    rdi,r13
    2242:	call   2247 <botlish_fn_21+0x137>
			2243: R_X86_64_PLT32	rt_mutarray_set-0x4
    2247:	test   rax,rax
    224a:	je     2421 <botlish_fn_21+0x311>
    2250:	mov    rax,QWORD PTR [rbx+0x18]
    2254:	mov    rsi,QWORD PTR [rax+0x18]
    2258:	mov    QWORD PTR [rsp+0x8],rsi
    225d:	mov    r12,rsi
    2260:	mov    QWORD PTR [rsp+0x10],0x1
    2269:	mov    rsi,rbx
    226c:	mov    rdi,r13
    226f:	call   2274 <botlish_fn_21+0x164>
			2270: R_X86_64_PLT32	botlish_fn_4-0x4 ; ht_size<HashTable>
    2274:	test   rax,rax
    2277:	je     2421 <botlish_fn_21+0x311>
    227d:	mov    QWORD PTR [rsp+0x18],rax
    2282:	mov    QWORD PTR [rsp+0x20],0x3
    228b:	mov    esi,0x1
    2290:	test   rax,0x1
    2296:	je     22a4 <botlish_fn_21+0x194>
    229c:	mov    r8,rax
    229f:	jmp    22c9 <botlish_fn_21+0x1b9>
    22a4:	xor    esi,esi
    22a6:	test   rax,0x7
    22ac:	je     22ba <botlish_fn_21+0x1aa>
    22b2:	mov    r8,rax
    22b5:	jmp    22c9 <botlish_fn_21+0x1b9>
    22ba:	movzx  rcx,BYTE PTR [rax]
    22be:	mov    r8,rax
    22c1:	rex cmp cl,0x1
    22c5:	sete   sil
    22c9:	test   sil,sil
    22cc:	jne    22ed <botlish_fn_21+0x1dd>
    22d2:	mov    rdi,r13
    22d5:	mov    rax,QWORD PTR [rdi+0x10]
    22d9:	mov    rcx,QWORD PTR [rax+0x10]
    22dd:	xor    rdx,rdx
    22e0:	mov    rsi,r8
    22e3:	call   22e8 <botlish_fn_21+0x1d8>
			22e4: R_X86_64_PLT32	rt_type_error-0x4
    22e8:	jmp    2421 <botlish_fn_21+0x311>
    22ed:	mov    rsi,r8
    22f0:	test   rsi,0x1
    22f7:	je     2316 <botlish_fn_21+0x206>
    22fd:	mov    rcx,rsi
    2300:	sub    rcx,0x3
    2304:	seto   al
    2307:	add    rcx,0x1
    230e:	test   al,al
    2310:	je     2326 <botlish_fn_21+0x216>
    2316:	mov    edx,0x3
    231b:	mov    rdi,r13
    231e:	call   2323 <botlish_fn_21+0x213>
			231f: R_X86_64_PLT32	rt_int_sub-0x4
    2323:	mov    rcx,rax
    2326:	mov    edx,0x1
    232b:	mov    rsi,r12
    232e:	mov    rdi,r13
    2331:	call   2336 <botlish_fn_21+0x226>
			2332: R_X86_64_PLT32	rt_mutarray_set-0x4
    2336:	test   rax,rax
    2339:	je     2421 <botlish_fn_21+0x311>
    233f:	mov    rsi,QWORD PTR [rbx+0x18]
    2343:	mov    rsi,QWORD PTR [rsi+0x18]
    2347:	mov    QWORD PTR [rsp+0x8],rsi
    234c:	mov    r14,rsi
    234f:	mov    QWORD PTR [rsp+0x10],0x3
    2358:	mov    rsi,rbx
    235b:	mov    rdi,r13
    235e:	call   2363 <botlish_fn_21+0x253>
			235f: R_X86_64_PLT32	botlish_fn_5-0x4 ; ht_tombstones<HashTable>
    2363:	mov    r12,rbx
    2366:	test   rax,rax
    2369:	je     2421 <botlish_fn_21+0x311>
    236f:	mov    QWORD PTR [rsp+0x18],rax
    2374:	mov    QWORD PTR [rsp+0x20],0x3
    237d:	mov    ecx,0x1
    2382:	test   rax,0x1
    2388:	je     2396 <botlish_fn_21+0x286>
    238e:	mov    rsi,rax
    2391:	jmp    23ba <botlish_fn_21+0x2aa>
    2396:	xor    ecx,ecx
    2398:	test   rax,0x7
    239e:	je     23ac <botlish_fn_21+0x29c>
    23a4:	mov    rsi,rax
    23a7:	jmp    23ba <botlish_fn_21+0x2aa>
    23ac:	movzx  rcx,BYTE PTR [rax]
    23b0:	mov    rsi,rax
    23b3:	rex cmp cl,0x1
    23b7:	sete   cl
    23ba:	test   cl,cl
    23bc:	jne    23d9 <botlish_fn_21+0x2c9>
    23c2:	mov    rdi,r13
    23c5:	mov    rax,QWORD PTR [rdi+0x10]
    23c9:	mov    rcx,QWORD PTR [rax]
    23cc:	xor    rdx,rdx
    23cf:	call   23d4 <botlish_fn_21+0x2c4>
			23d0: R_X86_64_PLT32	rt_type_error-0x4
    23d4:	jmp    2421 <botlish_fn_21+0x311>
    23d9:	test   rsi,0x1
    23e0:	je     23f8 <botlish_fn_21+0x2e8>
    23e6:	mov    rcx,rsi
    23e9:	add    rcx,0x2
    23ed:	seto   al
    23f0:	test   al,al
    23f2:	je     2408 <botlish_fn_21+0x2f8>
    23f8:	mov    edx,0x3
    23fd:	mov    rdi,r13
    2400:	call   2405 <botlish_fn_21+0x2f5>
			2401: R_X86_64_PLT32	rt_int_add-0x4
    2405:	mov    rcx,rax
    2408:	mov    edx,0x3
    240d:	mov    rsi,r14
    2410:	mov    rdi,r13
    2413:	call   2418 <botlish_fn_21+0x308>
			2414: R_X86_64_PLT32	rt_mutarray_set-0x4
    2418:	test   rax,rax
    241b:	jne    2441 <botlish_fn_21+0x331>
    2421:	xor    rax,rax
    2424:	mov    rbx,QWORD PTR [rsp+0x30]
    2429:	mov    r12,QWORD PTR [rsp+0x38]
    242e:	mov    r13,QWORD PTR [rsp+0x40]
    2433:	mov    r14,QWORD PTR [rsp+0x48]
    2438:	add    rsp,0x50
    243c:	mov    rsp,rbp
    243f:	pop    rbp
    2440:	ret
    2441:	mov    rax,r12
    2444:	mov    rbx,QWORD PTR [rsp+0x30]
    2449:	mov    r12,QWORD PTR [rsp+0x38]
    244e:	mov    r13,QWORD PTR [rsp+0x40]
    2453:	mov    r14,QWORD PTR [rsp+0x48]
    2458:	add    rsp,0x50
    245c:	mov    rsp,rbp
    245f:	pop    rbp
    2460:	ret
    2461:	add    BYTE PTR [rax],al
    2463:	add    BYTE PTR [rax],al
    2465:	add    BYTE PTR [rax],al
    2467:	add    BYTE PTR [rsi],al
    2469:	add    BYTE PTR [rax],al
    246b:	add    BYTE PTR [rax],al
    246d:	add    BYTE PTR [rax],al
	...

0000000000002470 <botlish_entry_21: ht_delete<HashTable, str>>:
    2470:	push   rbp
    2471:	mov    rbp,rsp
    2474:	mov    rsi,QWORD PTR [rdx]
    2477:	mov    rdx,QWORD PTR [rdx+0x8]
    247b:	call   2480 <botlish_entry_21+0x10>
			247c: R_X86_64_PLT32	botlish_fn_21-0x4 ; ht_delete<HashTable, str>
    2480:	mov    rsp,rbp
    2483:	pop    rbp
    2484:	ret
    2485:	add    BYTE PTR [rax],al
	...

0000000000002488 <botlish_fn_22: sample_checks<generic>>:
    2488:	push   rbp
    2489:	mov    rbp,rsp
    248c:	sub    rsp,0xa0
    2493:	mov    QWORD PTR [rsp+0x70],rbx
    2498:	mov    QWORD PTR [rsp+0x78],r12
    249d:	mov    QWORD PTR [rsp+0x80],r13
    24a5:	mov    QWORD PTR [rsp+0x88],r14
    24ad:	mov    QWORD PTR [rsp+0x90],r15
    24b5:	mov    r13,rdi
    24b8:	mov    QWORD PTR [rsp],0x0
    24c0:	mov    QWORD PTR [rsp+0x8],0x0
    24c9:	mov    QWORD PTR [rsp+0x10],0x0
    24d2:	mov    QWORD PTR [rsp+0x18],0x0
    24db:	mov    QWORD PTR [rsp+0x20],0x0
    24e4:	mov    QWORD PTR [rsp+0x28],0x0
    24ed:	mov    rdi,r13
    24f0:	call   24f5 <botlish_fn_22+0x6d>
			24f1: R_X86_64_PLT32	botlish_fn_3-0x4 ; ht_new<generic>
    24f5:	test   rax,rax
    24f8:	je     2754 <botlish_fn_22+0x2cc>
    24fe:	mov    QWORD PTR [rsp],rax
    2502:	mov    rsi,rax
    2505:	mov    rdi,r13
    2508:	mov    rax,QWORD PTR [rdi+0x10]
    250c:	mov    rdx,QWORD PTR [rax+0x18]
    2510:	mov    QWORD PTR [rsp+0x8],rdx
    2515:	mov    rax,QWORD PTR [rdi+0x10]
    2519:	mov    rcx,QWORD PTR [rax+0x20]
    251d:	mov    QWORD PTR [rsp+0x10],rcx
    2522:	call   2527 <botlish_fn_22+0x9f>
			2523: R_X86_64_PLT32	botlish_fn_20-0x4 ; ht_set<HashTable, str, str>
    2527:	test   rax,rax
    252a:	je     2754 <botlish_fn_22+0x2cc>
    2530:	mov    QWORD PTR [rsp],rax
    2534:	mov    rdi,r13
    2537:	mov    rsi,QWORD PTR [rdi+0x10]
    253b:	mov    rdx,QWORD PTR [rsi+0x28]
    253f:	mov    QWORD PTR [rsp+0x8],rdx
    2544:	mov    rsi,QWORD PTR [rdi+0x10]
    2548:	mov    rcx,QWORD PTR [rsi+0x30]
    254c:	mov    QWORD PTR [rsp+0x10],rcx
    2551:	mov    rsi,rax
    2554:	call   2559 <botlish_fn_22+0xd1>
			2555: R_X86_64_PLT32	botlish_fn_20-0x4 ; ht_set<HashTable, str, str>
    2559:	test   rax,rax
    255c:	je     2754 <botlish_fn_22+0x2cc>
    2562:	mov    QWORD PTR [rsp],rax
    2566:	mov    rsi,rax
    2569:	mov    rdi,r13
    256c:	mov    r11,QWORD PTR [rdi+0x10]
    2570:	mov    rdx,QWORD PTR [r11+0x18]
    2574:	mov    QWORD PTR [rsp+0x8],rdx
    2579:	mov    rax,QWORD PTR [rdi+0x10]
    257d:	mov    rcx,QWORD PTR [rax+0x38]
    2581:	mov    QWORD PTR [rsp+0x10],rcx
    2586:	call   258b <botlish_fn_22+0x103>
			2587: R_X86_64_PLT32	botlish_fn_20-0x4 ; ht_set<HashTable, str, str>
    258b:	test   rax,rax
    258e:	je     2754 <botlish_fn_22+0x2cc>
    2594:	mov    QWORD PTR [rsp],rax
    2598:	mov    rdi,r13
    259b:	mov    r14,rax
    259e:	mov    rax,QWORD PTR [rdi+0x10]
    25a2:	mov    rdx,QWORD PTR [rax+0x28]
    25a6:	mov    QWORD PTR [rsp+0x8],rdx
    25ab:	mov    rsi,r14
    25ae:	call   25b3 <botlish_fn_22+0x12b>
			25af: R_X86_64_PLT32	botlish_fn_12-0x4 ; ht_contains<HashTable, str>
    25b3:	test   rax,rax
    25b6:	je     2754 <botlish_fn_22+0x2cc>
    25bc:	mov    QWORD PTR [rsp+0x8],rax
    25c1:	mov    rdi,r13
    25c4:	mov    r15,rax
    25c7:	mov    rax,QWORD PTR [rdi+0x10]
    25cb:	mov    rdx,QWORD PTR [rax+0x28]
    25cf:	mov    QWORD PTR [rsp+0x10],rdx
    25d4:	mov    rsi,r14
    25d7:	call   25dc <botlish_fn_22+0x154>
			25d8: R_X86_64_PLT32	botlish_fn_21-0x4 ; ht_delete<HashTable, str>
    25dc:	mov    rcx,rax
    25df:	mov    r14,rax
    25e2:	test   rax,rcx
    25e5:	je     2754 <botlish_fn_22+0x2cc>
    25eb:	mov    rax,r14
    25ee:	mov    QWORD PTR [rsp],rax
    25f2:	mov    rdi,r13
    25f5:	mov    rax,QWORD PTR [rdi+0x10]
    25f9:	mov    rdx,QWORD PTR [rax+0x18]
    25fd:	mov    QWORD PTR [rsp+0x10],rdx
    2602:	mov    rsi,r14
    2605:	call   260a <botlish_fn_22+0x182>
			2606: R_X86_64_PLT32	botlish_fn_11-0x4 ; ht_get<HashTable, str>
    260a:	test   rax,rax
    260d:	je     2754 <botlish_fn_22+0x2cc>
    2613:	mov    rdi,r13
    2616:	mov    rcx,QWORD PTR [rdi+0x10]
    261a:	mov    rdx,QWORD PTR [rcx+0x38]
    261e:	mov    rcx,rax
    2621:	and    rcx,rdx
    2624:	mov    rsi,rax
    2627:	test   rcx,0x1
    262e:	jne    264a <botlish_fn_22+0x1c2>
    2634:	mov    rdi,r13
    2637:	call   263c <botlish_fn_22+0x1b4>
			2638: R_X86_64_PLT32	rt_value_eq-0x4
    263c:	test   rax,rax
    263f:	je     2754 <botlish_fn_22+0x2cc>
    2645:	jmp    265a <botlish_fn_22+0x1d2>
    264a:	mov    eax,0x2
    264f:	cmp    rsi,rdx
    2652:	cmove  rax,QWORD PTR [rip+0x15e]        # 27b8 <botlish_fn_22+0x330>
    265a:	mov    QWORD PTR [rsp+0x10],rax
    265f:	mov    rdi,r13
    2662:	mov    QWORD PTR [rsp+0x60],rax
    2667:	mov    rax,QWORD PTR [rdi+0x10]
    266b:	mov    rdx,QWORD PTR [rax+0x28]
    266f:	mov    QWORD PTR [rsp+0x18],rdx
    2674:	mov    rsi,r14
    2677:	call   267c <botlish_fn_22+0x1f4>
			2678: R_X86_64_PLT32	botlish_fn_12-0x4 ; ht_contains<HashTable, str>
    267c:	mov    rbx,rax
    267f:	test   rbx,rbx
    2682:	je     2754 <botlish_fn_22+0x2cc>
    2688:	mov    QWORD PTR [rsp+0x18],rbx
    268d:	mov    rdi,r13
    2690:	mov    rax,QWORD PTR [rdi+0x10]
    2694:	mov    rdx,QWORD PTR [rax+0x40]
    2698:	mov    QWORD PTR [rsp+0x20],rdx
    269d:	mov    rsi,r14
    26a0:	call   26a5 <botlish_fn_22+0x21d>
			26a1: R_X86_64_PLT32	botlish_fn_12-0x4 ; ht_contains<HashTable, str>
    26a5:	mov    r12,rax
    26a8:	test   r12,r12
    26ab:	je     2754 <botlish_fn_22+0x2cc>
    26b1:	mov    QWORD PTR [rsp+0x20],r12
    26b6:	mov    rdi,r13
    26b9:	mov    rax,QWORD PTR [rdi+0x10]
    26bd:	mov    rdx,QWORD PTR [rax+0x40]
    26c1:	mov    QWORD PTR [rsp+0x28],rdx
    26c6:	mov    rsi,r14
    26c9:	call   26ce <botlish_fn_22+0x246>
			26ca: R_X86_64_PLT32	botlish_fn_11-0x4 ; ht_get<HashTable, str>
    26ce:	test   rax,rax
    26d1:	mov    rsi,rax
    26d4:	je     2754 <botlish_fn_22+0x2cc>
    26da:	mov    edx,0xa
    26df:	mov    rdi,r13
    26e2:	call   26e7 <botlish_fn_22+0x25f>
			26e3: R_X86_64_PLT32	rt_value_eq-0x4
    26e7:	test   rax,rax
    26ea:	je     2754 <botlish_fn_22+0x2cc>
    26f0:	mov    QWORD PTR [rsp],rax
    26f4:	mov    rsi,r14
    26f7:	mov    r14,rax
    26fa:	mov    rdi,r13
    26fd:	call   2702 <botlish_fn_22+0x27a>
			26fe: R_X86_64_PLT32	botlish_fn_4-0x4 ; ht_size<HashTable>
    2702:	test   rax,rax
    2705:	je     2754 <botlish_fn_22+0x2cc>
    270b:	mov    QWORD PTR [rsp+0x28],rax
    2710:	lea    rdx,[rsp+0x30]
    2715:	mov    r9,QWORD PTR [rsp+0x60]
    271a:	mov    QWORD PTR [rsp+0x30],r9
    271f:	mov    rsi,r15
    2722:	mov    QWORD PTR [rsp+0x38],rsi
    2727:	mov    QWORD PTR [rsp+0x40],rbx
    272c:	mov    QWORD PTR [rsp+0x48],r12
    2731:	mov    rcx,r14
    2734:	mov    QWORD PTR [rsp+0x50],rcx
    2739:	mov    QWORD PTR [rsp+0x58],rax
    273e:	mov    esi,0x6
    2743:	mov    rdi,r13
    2746:	call   274b <botlish_fn_22+0x2c3>
			2747: R_X86_64_PLT32	rt_list_new-0x4
    274b:	test   rax,rax
    274e:	jne    2785 <botlish_fn_22+0x2fd>
    2754:	xor    rax,rax
    2757:	mov    rbx,QWORD PTR [rsp+0x70]
    275c:	mov    r12,QWORD PTR [rsp+0x78]
    2761:	mov    r13,QWORD PTR [rsp+0x80]
    2769:	mov    r14,QWORD PTR [rsp+0x88]
    2771:	mov    r15,QWORD PTR [rsp+0x90]
    2779:	add    rsp,0xa0
    2780:	mov    rsp,rbp
    2783:	pop    rbp
    2784:	ret
    2785:	mov    rbx,QWORD PTR [rsp+0x70]
    278a:	mov    r12,QWORD PTR [rsp+0x78]
    278f:	mov    r13,QWORD PTR [rsp+0x80]
    2797:	mov    r14,QWORD PTR [rsp+0x88]
    279f:	mov    r15,QWORD PTR [rsp+0x90]
    27a7:	add    rsp,0xa0
    27ae:	mov    rsp,rbp
    27b1:	pop    rbp
    27b2:	ret
    27b3:	add    BYTE PTR [rax],al
    27b5:	add    BYTE PTR [rax],al
    27b7:	add    BYTE PTR [rsi],al
    27b9:	add    BYTE PTR [rax],al
    27bb:	add    BYTE PTR [rax],al
    27bd:	add    BYTE PTR [rax],al
	...

00000000000027c0 <botlish_entry_22: sample_checks<generic>>:
    27c0:	push   rbp
    27c1:	mov    rbp,rsp
    27c4:	call   27c9 <botlish_entry_22+0x9>
			27c5: R_X86_64_PLT32	botlish_fn_22-0x4 ; sample_checks<generic>
    27c9:	mov    rsp,rbp
    27cc:	pop    rbp
    27cd:	ret

00000000000027ce <botlish_fn_23: sample<generic>>:
    27ce:	push   rbp
    27cf:	mov    rbp,rsp
    27d2:	sub    rsp,0x10
    27d6:	mov    QWORD PTR [rsp],r12
    27da:	mov    r12,rdi
    27dd:	mov    rdi,r12
    27e0:	call   27e5 <botlish_fn_23+0x17>
			27e1: R_X86_64_PLT32	botlish_fn_22-0x4 ; sample_checks<generic>
    27e5:	test   rax,rax
    27e8:	jne    2831 <botlish_fn_23+0x63>
    27ee:	mov    rdi,r12
    27f1:	call   27f6 <botlish_fn_23+0x28>
			27f2: R_X86_64_PLT32	rt_declared_error-0x4
    27f6:	cmp    rax,0x40000001
    27fc:	jne    2821 <botlish_fn_23+0x53>
    2802:	mov    rdi,r12
    2805:	call   280a <botlish_fn_23+0x3c>
			2806: R_X86_64_PLT32	rt_clear_declared_error-0x4
    280a:	xor    rdx,rdx
    280d:	mov    rdi,r12
    2810:	mov    rsi,rdx
    2813:	call   2818 <botlish_fn_23+0x4a>
			2814: R_X86_64_PLT32	rt_list_new-0x4
    2818:	test   rax,rax
    281b:	jne    2831 <botlish_fn_23+0x63>
    2821:	xor    rax,rax
    2824:	mov    r12,QWORD PTR [rsp]
    2828:	add    rsp,0x10
    282c:	mov    rsp,rbp
    282f:	pop    rbp
    2830:	ret
    2831:	mov    r12,QWORD PTR [rsp]
    2835:	add    rsp,0x10
    2839:	mov    rsp,rbp
    283c:	pop    rbp
    283d:	ret

000000000000283e <botlish_entry_23: sample<generic>>:
    283e:	push   rbp
    283f:	mov    rbp,rsp
    2842:	call   2847 <botlish_entry_23+0x9>
			2843: R_X86_64_PLT32	botlish_fn_23-0x4 ; sample<generic>
    2847:	mov    rsp,rbp
    284a:	pop    rbp
    284b:	ret
