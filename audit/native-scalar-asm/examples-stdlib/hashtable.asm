; source:  examples/stdlib/hashtable.bot
; backend: Cranelift (specialize=1), native::object
; object:  ELF64 x86-64, unlinked (Botlish-generated code only; runtime
;          helpers are unresolved imports, so their bodies are not present)
; format:  objdump -dr --no-show-raw-insn -M intel
; total machine code bytes: 10804  (per function: 45 427 385 70 69 69 46 182 228 604 984 341 261 388 407 616 654 801 673 920 700 925 862 147)
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
     5b7:	je     6e1 <botlish_fn_9+0x181>
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
     5e4:	cmove  rcx,QWORD PTR [rip+0x184]        # 770 <botlish_fn_9+0x210>
     5ec:	mov    rax,r15
     5ef:	jmp    608 <botlish_fn_9+0xa8>
     5f4:	mov    ecx,0x2
     5f9:	mov    rax,r15
     5fc:	cmp    rax,0x1
     600:	cmove  rcx,QWORD PTR [rip+0x168]        # 770 <botlish_fn_9+0x210>
     608:	cmp    rcx,0x6
     60c:	je     741 <botlish_fn_9+0x1e1>
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
     639:	cmove  rcx,QWORD PTR [rip+0x12f]        # 770 <botlish_fn_9+0x210>
     641:	jmp    65a <botlish_fn_9+0xfa>
     646:	mov    rsi,r15
     649:	mov    ecx,0x2
     64e:	cmp    rsi,0x3
     652:	cmove  rcx,QWORD PTR [rip+0x116]        # 770 <botlish_fn_9+0x210>
     65a:	cmp    rcx,0x6
     65e:	jne    6ca <botlish_fn_9+0x16a>
     664:	mov    rax,QWORD PTR [r12+0x18]
     669:	mov    rsi,QWORD PTR [rax+0x8]
     66d:	mov    rdx,r14
     670:	mov    rdi,r13
     673:	call   678 <botlish_fn_9+0x118>
			674: R_X86_64_PLT32	rt_mutarray_get-0x4
     678:	test   rax,rax
     67b:	je     6e1 <botlish_fn_9+0x181>
     681:	mov    rcx,rax
     684:	and    rcx,rbx
     687:	mov    rsi,rax
     68a:	test   rcx,0x1
     691:	jne    6b0 <botlish_fn_9+0x150>
     697:	mov    rdx,rbx
     69a:	mov    rdi,r13
     69d:	call   6a2 <botlish_fn_9+0x142>
			69e: R_X86_64_PLT32	rt_value_eq-0x4
     6a2:	test   rax,rax
     6a5:	je     6e1 <botlish_fn_9+0x181>
     6ab:	jmp    6c0 <botlish_fn_9+0x160>
     6b0:	mov    eax,0x2
     6b5:	cmp    rsi,rbx
     6b8:	cmove  rax,QWORD PTR [rip+0xb0]        # 770 <botlish_fn_9+0x210>
     6c0:	cmp    rax,0x6
     6c4:	je     71c <botlish_fn_9+0x1bc>
     6ca:	mov    rdx,r14
     6cd:	mov    rsi,r12
     6d0:	mov    rdi,r13
     6d3:	call   6d8 <botlish_fn_9+0x178>
			6d4: R_X86_64_PLT32	botlish_fn_8-0x4 ; ht_probe_next<HashTable, int>
     6d8:	test   rax,rax
     6db:	jne    706 <botlish_fn_9+0x1a6>
     6e1:	xor    rax,rax
     6e4:	mov    rbx,QWORD PTR [rsp+0x20]
     6e9:	mov    r12,QWORD PTR [rsp+0x28]
     6ee:	mov    r13,QWORD PTR [rsp+0x30]
     6f3:	mov    r14,QWORD PTR [rsp+0x38]
     6f8:	mov    r15,QWORD PTR [rsp+0x40]
     6fd:	add    rsp,0x50
     701:	mov    rsp,rbp
     704:	pop    rbp
     705:	ret
     706:	mov    QWORD PTR [rsp],r12
     70a:	mov    QWORD PTR [rsp+0x8],rbx
     70f:	mov    QWORD PTR [rsp+0x10],rax
     714:	mov    r14,rax
     717:	jmp    59b <botlish_fn_9+0x3b>
     71c:	mov    rax,r14
     71f:	mov    rbx,QWORD PTR [rsp+0x20]
     724:	mov    r12,QWORD PTR [rsp+0x28]
     729:	mov    r13,QWORD PTR [rsp+0x30]
     72e:	mov    r14,QWORD PTR [rsp+0x38]
     733:	mov    r15,QWORD PTR [rsp+0x40]
     738:	add    rsp,0x50
     73c:	mov    rsp,rbp
     73f:	pop    rbp
     740:	ret
     741:	mov    rax,0xffffffffffffffff
     748:	mov    rbx,QWORD PTR [rsp+0x20]
     74d:	mov    r12,QWORD PTR [rsp+0x28]
     752:	mov    r13,QWORD PTR [rsp+0x30]
     757:	mov    r14,QWORD PTR [rsp+0x38]
     75c:	mov    r15,QWORD PTR [rsp+0x40]
     761:	add    rsp,0x50
     765:	mov    rsp,rbp
     768:	pop    rbp
     769:	ret
     76a:	add    BYTE PTR [rax],al
     76c:	add    BYTE PTR [rax],al
     76e:	add    BYTE PTR [rax],al
     770:	(bad)
     771:	add    BYTE PTR [rax],al
     773:	add    BYTE PTR [rax],al
     775:	add    BYTE PTR [rax],al
	...

0000000000000778 <botlish_entry_9: ht_find_get<HashTable, str, int>>:
     778:	push   rbp
     779:	mov    rbp,rsp
     77c:	mov    rsi,QWORD PTR [rdx]
     77f:	mov    r8,QWORD PTR [rdx+0x8]
     783:	mov    rcx,QWORD PTR [rdx+0x10]
     787:	mov    rdx,r8
     78a:	call   78f <botlish_entry_9+0x17>
			78b: R_X86_64_PLT32	botlish_fn_9-0x4 ; ht_find_get<HashTable, str, int>
     78f:	mov    rsp,rbp
     792:	pop    rbp
     793:	ret
     794:	add    BYTE PTR [rax],al
	...

0000000000000798 <botlish_fn_10: ht_find_insert<HashTable, str, int, int>>:
     798:	push   rbp
     799:	mov    rbp,rsp
     79c:	sub    rsp,0x60
     7a0:	mov    QWORD PTR [rsp+0x30],rbx
     7a5:	mov    QWORD PTR [rsp+0x38],r12
     7aa:	mov    QWORD PTR [rsp+0x40],r13
     7af:	mov    QWORD PTR [rsp+0x48],r14
     7b4:	mov    QWORD PTR [rsp+0x50],r15
     7b9:	mov    r15,rdi
     7bc:	mov    QWORD PTR [rsp],rsi
     7c0:	mov    QWORD PTR [rsp+0x8],rdx
     7c5:	mov    rbx,rdx
     7c8:	mov    QWORD PTR [rsp+0x10],rcx
     7cd:	mov    rax,rcx
     7d0:	mov    QWORD PTR [rsp+0x18],r8
     7d5:	mov    r13,rsi
     7d8:	mov    QWORD PTR [rsp+0x20],r8
     7dd:	mov    rcx,QWORD PTR [r13+0x18]
     7e1:	mov    rsi,QWORD PTR [rcx]
     7e4:	mov    r12,rax
     7e7:	mov    rdx,r12
     7ea:	mov    rdi,r15
     7ed:	call   7f2 <botlish_fn_10+0x5a>
			7ee: R_X86_64_PLT32	rt_mutarray_get-0x4
     7f2:	mov    rcx,rax
     7f5:	mov    r14,rax
     7f8:	test   rax,rcx
     7fb:	je     a15 <botlish_fn_10+0x27d>
     801:	mov    rax,r14
     804:	test   rax,0x1
     80a:	jne    835 <botlish_fn_10+0x9d>
     810:	mov    edx,0x1
     815:	mov    rsi,r14
     818:	mov    rdi,r15
     81b:	call   820 <botlish_fn_10+0x88>
			81c: R_X86_64_PLT32	rt_int_cmp-0x4
     820:	mov    ecx,0x2
     825:	test   rax,rax
     828:	cmove  rcx,QWORD PTR [rip+0x2d8]        # b08 <botlish_fn_10+0x370>
     830:	jmp    849 <botlish_fn_10+0xb1>
     835:	mov    ecx,0x2
     83a:	mov    rax,r14
     83d:	cmp    rax,0x1
     841:	cmove  rcx,QWORD PTR [rip+0x2bf]        # b08 <botlish_fn_10+0x370>
     849:	cmp    rcx,0x6
     84d:	je     a5f <botlish_fn_10+0x2c7>
     853:	mov    rax,r14
     856:	test   rax,0x1
     85c:	jne    887 <botlish_fn_10+0xef>
     862:	mov    edx,0x3
     867:	mov    rsi,r14
     86a:	mov    rdi,r15
     86d:	call   872 <botlish_fn_10+0xda>
			86e: R_X86_64_PLT32	rt_int_cmp-0x4
     872:	mov    ecx,0x2
     877:	test   rax,rax
     87a:	cmove  rcx,QWORD PTR [rip+0x286]        # b08 <botlish_fn_10+0x370>
     882:	jmp    89b <botlish_fn_10+0x103>
     887:	mov    ecx,0x2
     88c:	mov    rax,r14
     88f:	cmp    rax,0x3
     893:	cmove  rcx,QWORD PTR [rip+0x26d]        # b08 <botlish_fn_10+0x370>
     89b:	cmp    rcx,0x6
     89f:	je     8ad <botlish_fn_10+0x115>
     8a5:	mov    rax,r14
     8a8:	jmp    915 <botlish_fn_10+0x17d>
     8ad:	mov    rax,QWORD PTR [r13+0x18]
     8b1:	mov    rsi,QWORD PTR [rax+0x8]
     8b5:	mov    rdx,r12
     8b8:	mov    rdi,r15
     8bb:	call   8c0 <botlish_fn_10+0x128>
			8bc: R_X86_64_PLT32	rt_mutarray_get-0x4
     8c0:	test   rax,rax
     8c3:	je     a15 <botlish_fn_10+0x27d>
     8c9:	mov    rcx,rax
     8cc:	and    rcx,rbx
     8cf:	mov    rsi,rax
     8d2:	test   rcx,0x1
     8d9:	jne    8f8 <botlish_fn_10+0x160>
     8df:	mov    rdx,rbx
     8e2:	mov    rdi,r15
     8e5:	call   8ea <botlish_fn_10+0x152>
			8e6: R_X86_64_PLT32	rt_value_eq-0x4
     8ea:	test   rax,rax
     8ed:	je     a15 <botlish_fn_10+0x27d>
     8f3:	jmp    908 <botlish_fn_10+0x170>
     8f8:	mov    eax,0x2
     8fd:	cmp    rsi,rbx
     900:	cmove  rax,QWORD PTR [rip+0x200]        # b08 <botlish_fn_10+0x370>
     908:	cmp    rax,0x6
     90c:	je     a57 <botlish_fn_10+0x2bf>
     912:	mov    rax,r14
     915:	test   rax,0x1
     91b:	mov    r14,rax
     91e:	jne    949 <botlish_fn_10+0x1b1>
     924:	mov    edx,0x5
     929:	mov    rsi,r14
     92c:	mov    rdi,r15
     92f:	call   934 <botlish_fn_10+0x19c>
			930: R_X86_64_PLT32	rt_int_cmp-0x4
     934:	mov    ecx,0x2
     939:	test   rax,rax
     93c:	cmove  rcx,QWORD PTR [rip+0x1c4]        # b08 <botlish_fn_10+0x370>
     944:	jmp    95d <botlish_fn_10+0x1c5>
     949:	mov    rsi,r14
     94c:	mov    ecx,0x2
     951:	cmp    rsi,0x5
     955:	cmove  rcx,QWORD PTR [rip+0x1ab]        # b08 <botlish_fn_10+0x370>
     95d:	cmp    rcx,0x6
     961:	je     96f <botlish_fn_10+0x1d7>
     967:	mov    rdx,r12
     96a:	jmp    9cd <botlish_fn_10+0x235>
     96f:	mov    r14,QWORD PTR [rsp+0x20]
     974:	test   r14,0x1
     97b:	jne    9ab <botlish_fn_10+0x213>
     981:	mov    edx,0x1
     986:	mov    rsi,r14
     989:	mov    rdi,r15
     98c:	call   991 <botlish_fn_10+0x1f9>
			98d: R_X86_64_PLT32	rt_int_cmp-0x4
     991:	mov    ecx,0x2
     996:	test   rax,rax
     999:	cmovl  rcx,QWORD PTR [rip+0x167]        # b08 <botlish_fn_10+0x370>
     9a1:	mov    QWORD PTR [rsp+0x20],r14
     9a6:	jmp    9c0 <botlish_fn_10+0x228>
     9ab:	mov    ecx,0x2
     9b0:	test   r14,r14
     9b3:	mov    QWORD PTR [rsp+0x20],r14
     9b8:	cmovle rcx,QWORD PTR [rip+0x148]        # b08 <botlish_fn_10+0x370>
     9c0:	cmp    rcx,0x6
     9c4:	je     9fe <botlish_fn_10+0x266>
     9ca:	mov    rdx,r12
     9cd:	mov    rsi,r13
     9d0:	mov    rdi,r15
     9d3:	call   9d8 <botlish_fn_10+0x240>
			9d4: R_X86_64_PLT32	botlish_fn_8-0x4 ; ht_probe_next<HashTable, int>
     9d8:	test   rax,rax
     9db:	je     a15 <botlish_fn_10+0x27d>
     9e1:	mov    QWORD PTR [rsp],r13
     9e5:	mov    QWORD PTR [rsp+0x8],rbx
     9ea:	mov    QWORD PTR [rsp+0x10],rax
     9ef:	mov    rcx,QWORD PTR [rsp+0x20]
     9f4:	mov    QWORD PTR [rsp+0x18],rcx
     9f9:	jmp    7dd <botlish_fn_10+0x45>
     9fe:	mov    rdx,r12
     a01:	mov    rsi,r13
     a04:	mov    rdi,r15
     a07:	call   a0c <botlish_fn_10+0x274>
			a08: R_X86_64_PLT32	botlish_fn_8-0x4 ; ht_probe_next<HashTable, int>
     a0c:	test   rax,rax
     a0f:	jne    a3a <botlish_fn_10+0x2a2>
     a15:	xor    rax,rax
     a18:	mov    rbx,QWORD PTR [rsp+0x30]
     a1d:	mov    r12,QWORD PTR [rsp+0x38]
     a22:	mov    r13,QWORD PTR [rsp+0x40]
     a27:	mov    r14,QWORD PTR [rsp+0x48]
     a2c:	mov    r15,QWORD PTR [rsp+0x50]
     a31:	add    rsp,0x60
     a35:	mov    rsp,rbp
     a38:	pop    rbp
     a39:	ret
     a3a:	mov    QWORD PTR [rsp],r13
     a3e:	mov    QWORD PTR [rsp+0x8],rbx
     a43:	mov    QWORD PTR [rsp+0x10],rax
     a48:	mov    QWORD PTR [rsp+0x18],r12
     a4d:	mov    QWORD PTR [rsp+0x20],r12
     a52:	jmp    7dd <botlish_fn_10+0x45>
     a57:	mov    rax,r12
     a5a:	jmp    abe <botlish_fn_10+0x326>
     a5f:	mov    rax,QWORD PTR [rsp+0x20]
     a64:	test   rax,0x1
     a6a:	jne    a97 <botlish_fn_10+0x2ff>
     a70:	mov    edx,0x1
     a75:	mov    rdi,r15
     a78:	mov    rsi,QWORD PTR [rsp+0x20]
     a7d:	call   a82 <botlish_fn_10+0x2ea>
			a7e: R_X86_64_PLT32	rt_int_cmp-0x4
     a82:	mov    ecx,0x2
     a87:	test   rax,rax
     a8a:	cmovge rcx,QWORD PTR [rip+0x76]        # b08 <botlish_fn_10+0x370>
     a92:	jmp    ab1 <botlish_fn_10+0x319>
     a97:	mov    ecx,0x2
     a9c:	mov    rax,QWORD PTR [rsp+0x20]
     aa1:	mov    r11,QWORD PTR [rsp+0x20]
     aa6:	test   rax,r11
     aa9:	cmovg  rcx,QWORD PTR [rip+0x57]        # b08 <botlish_fn_10+0x370>
     ab1:	cmp    rcx,0x6
     ab5:	je     ae0 <botlish_fn_10+0x348>
     abb:	mov    rax,r12
     abe:	mov    rbx,QWORD PTR [rsp+0x30]
     ac3:	mov    r12,QWORD PTR [rsp+0x38]
     ac8:	mov    r13,QWORD PTR [rsp+0x40]
     acd:	mov    r14,QWORD PTR [rsp+0x48]
     ad2:	mov    r15,QWORD PTR [rsp+0x50]
     ad7:	add    rsp,0x60
     adb:	mov    rsp,rbp
     ade:	pop    rbp
     adf:	ret
     ae0:	mov    rax,QWORD PTR [rsp+0x20]
     ae5:	mov    rbx,QWORD PTR [rsp+0x30]
     aea:	mov    r12,QWORD PTR [rsp+0x38]
     aef:	mov    r13,QWORD PTR [rsp+0x40]
     af4:	mov    r14,QWORD PTR [rsp+0x48]
     af9:	mov    r15,QWORD PTR [rsp+0x50]
     afe:	add    rsp,0x60
     b02:	mov    rsp,rbp
     b05:	pop    rbp
     b06:	ret
     b07:	add    BYTE PTR [rsi],al
     b09:	add    BYTE PTR [rax],al
     b0b:	add    BYTE PTR [rax],al
     b0d:	add    BYTE PTR [rax],al
	...

0000000000000b10 <botlish_entry_10: ht_find_insert<HashTable, str, int, int>>:
     b10:	push   rbp
     b11:	mov    rbp,rsp
     b14:	mov    rsi,QWORD PTR [rdx]
     b17:	mov    r9,QWORD PTR [rdx+0x8]
     b1b:	mov    rcx,QWORD PTR [rdx+0x10]
     b1f:	mov    r8,QWORD PTR [rdx+0x18]
     b23:	mov    rdx,r9
     b26:	call   b2b <botlish_entry_10+0x1b>
			b27: R_X86_64_PLT32	botlish_fn_10-0x4 ; ht_find_insert<HashTable, str, int, int>
     b2b:	mov    rsp,rbp
     b2e:	pop    rbp
     b2f:	ret

0000000000000b30 <botlish_fn_11: ht_get<HashTable, str>>:
     b30:	push   rbp
     b31:	mov    rbp,rsp
     b34:	sub    rsp,0x40
     b38:	mov    QWORD PTR [rsp+0x20],rbx
     b3d:	mov    QWORD PTR [rsp+0x28],r12
     b42:	mov    QWORD PTR [rsp+0x30],r13
     b47:	mov    r12,rdi
     b4a:	mov    QWORD PTR [rsp+0x10],0x0
     b53:	mov    QWORD PTR [rsp],rsi
     b57:	mov    QWORD PTR [rsp+0x8],rdx
     b5c:	mov    r13,rdx
     b5f:	mov    rbx,rsi
     b62:	mov    rdx,r13
     b65:	mov    rdi,r12
     b68:	call   b6d <botlish_fn_11+0x3d>
			b69: R_X86_64_PLT32	botlish_fn_7-0x4 ; ht_probe_start<HashTable, str>
     b6d:	test   rax,rax
     b70:	je     c08 <botlish_fn_11+0xd8>
     b76:	mov    QWORD PTR [rsp+0x10],rax
     b7b:	mov    rcx,rax
     b7e:	mov    rdx,r13
     b81:	mov    rsi,rbx
     b84:	mov    rdi,r12
     b87:	call   b8c <botlish_fn_11+0x5c>
			b88: R_X86_64_PLT32	botlish_fn_9-0x4 ; ht_find_get<HashTable, str, int>
     b8c:	mov    rcx,rax
     b8f:	mov    r13,rax
     b92:	test   rax,rcx
     b95:	je     c08 <botlish_fn_11+0xd8>
     b9b:	mov    rax,r13
     b9e:	test   rax,0x1
     ba4:	jne    bcf <botlish_fn_11+0x9f>
     baa:	mov    edx,0x1
     baf:	mov    rsi,r13
     bb2:	mov    rdi,r12
     bb5:	call   bba <botlish_fn_11+0x8a>
			bb6: R_X86_64_PLT32	rt_int_cmp-0x4
     bba:	mov    ecx,0x2
     bbf:	test   rax,rax
     bc2:	cmovl  rcx,QWORD PTR [rip+0x8e]        # c58 <botlish_fn_11+0x128>
     bca:	jmp    be2 <botlish_fn_11+0xb2>
     bcf:	mov    ecx,0x2
     bd4:	mov    rax,r13
     bd7:	test   rax,rax
     bda:	cmovle rcx,QWORD PTR [rip+0x76]        # c58 <botlish_fn_11+0x128>
     be2:	cmp    rcx,0x6
     be6:	je     c3b <botlish_fn_11+0x10b>
     bec:	mov    rax,QWORD PTR [rbx+0x18]
     bf0:	mov    rsi,QWORD PTR [rax+0x10]
     bf4:	mov    rdx,r13
     bf7:	mov    rdi,r12
     bfa:	call   bff <botlish_fn_11+0xcf>
			bfb: R_X86_64_PLT32	rt_mutarray_get-0x4
     bff:	test   rax,rax
     c02:	jne    c23 <botlish_fn_11+0xf3>
     c08:	xor    rax,rax
     c0b:	mov    rbx,QWORD PTR [rsp+0x20]
     c10:	mov    r12,QWORD PTR [rsp+0x28]
     c15:	mov    r13,QWORD PTR [rsp+0x30]
     c1a:	add    rsp,0x40
     c1e:	mov    rsp,rbp
     c21:	pop    rbp
     c22:	ret
     c23:	mov    rbx,QWORD PTR [rsp+0x20]
     c28:	mov    r12,QWORD PTR [rsp+0x28]
     c2d:	mov    r13,QWORD PTR [rsp+0x30]
     c32:	add    rsp,0x40
     c36:	mov    rsp,rbp
     c39:	pop    rbp
     c3a:	ret
     c3b:	mov    eax,0xa
     c40:	mov    rbx,QWORD PTR [rsp+0x20]
     c45:	mov    r12,QWORD PTR [rsp+0x28]
     c4a:	mov    r13,QWORD PTR [rsp+0x30]
     c4f:	add    rsp,0x40
     c53:	mov    rsp,rbp
     c56:	pop    rbp
     c57:	ret
     c58:	(bad)
     c59:	add    BYTE PTR [rax],al
     c5b:	add    BYTE PTR [rax],al
     c5d:	add    BYTE PTR [rax],al
	...

0000000000000c60 <botlish_entry_11: ht_get<HashTable, str>>:
     c60:	push   rbp
     c61:	mov    rbp,rsp
     c64:	mov    rsi,QWORD PTR [rdx]
     c67:	mov    rdx,QWORD PTR [rdx+0x8]
     c6b:	call   c70 <botlish_entry_11+0x10>
			c6c: R_X86_64_PLT32	botlish_fn_11-0x4 ; ht_get<HashTable, str>
     c70:	mov    rsp,rbp
     c73:	pop    rbp
     c74:	ret
     c75:	add    BYTE PTR [rax],al
	...

0000000000000c78 <botlish_fn_12: ht_contains<HashTable, str>>:
     c78:	push   rbp
     c79:	mov    rbp,rsp
     c7c:	sub    rsp,0x40
     c80:	mov    QWORD PTR [rsp+0x20],rbx
     c85:	mov    QWORD PTR [rsp+0x28],r12
     c8a:	mov    QWORD PTR [rsp+0x30],r15
     c8f:	mov    r15,rdi
     c92:	mov    QWORD PTR [rsp+0x10],0x0
     c9b:	mov    QWORD PTR [rsp],rsi
     c9f:	mov    r12,rsi
     ca2:	mov    QWORD PTR [rsp+0x8],rdx
     ca7:	mov    rbx,rdx
     caa:	mov    rdx,rbx
     cad:	mov    rsi,r12
     cb0:	mov    rdi,r15
     cb3:	call   cb8 <botlish_fn_12+0x40>
			cb4: R_X86_64_PLT32	botlish_fn_7-0x4 ; ht_probe_start<HashTable, str>
     cb8:	test   rax,rax
     cbb:	je     ce0 <botlish_fn_12+0x68>
     cc1:	mov    QWORD PTR [rsp+0x10],rax
     cc6:	mov    rcx,rax
     cc9:	mov    rdx,rbx
     ccc:	mov    rsi,r12
     ccf:	mov    rdi,r15
     cd2:	call   cd7 <botlish_fn_12+0x5f>
			cd3: R_X86_64_PLT32	botlish_fn_9-0x4 ; ht_find_get<HashTable, str, int>
     cd7:	test   rax,rax
     cda:	jne    cfb <botlish_fn_12+0x83>
     ce0:	xor    rax,rax
     ce3:	mov    rbx,QWORD PTR [rsp+0x20]
     ce8:	mov    r12,QWORD PTR [rsp+0x28]
     ced:	mov    r15,QWORD PTR [rsp+0x30]
     cf2:	add    rsp,0x40
     cf6:	mov    rsp,rbp
     cf9:	pop    rbp
     cfa:	ret
     cfb:	test   rax,0x1
     d01:	mov    rsi,rax
     d04:	jne    d2f <botlish_fn_12+0xb7>
     d0a:	mov    edx,0x1
     d0f:	mov    rdi,r15
     d12:	call   d17 <botlish_fn_12+0x9f>
			d13: R_X86_64_PLT32	rt_int_cmp-0x4
     d17:	mov    ecx,0x2
     d1c:	test   rax,rax
     d1f:	mov    rax,rcx
     d22:	cmovge rax,QWORD PTR [rip+0x2e]        # d58 <botlish_fn_12+0xe0>
     d2a:	jmp    d3f <botlish_fn_12+0xc7>
     d2f:	mov    eax,0x2
     d34:	test   rsi,rsi
     d37:	cmovg  rax,QWORD PTR [rip+0x19]        # d58 <botlish_fn_12+0xe0>
     d3f:	mov    rbx,QWORD PTR [rsp+0x20]
     d44:	mov    r12,QWORD PTR [rsp+0x28]
     d49:	mov    r15,QWORD PTR [rsp+0x30]
     d4e:	add    rsp,0x40
     d52:	mov    rsp,rbp
     d55:	pop    rbp
     d56:	ret
     d57:	add    BYTE PTR [rsi],al
     d59:	add    BYTE PTR [rax],al
     d5b:	add    BYTE PTR [rax],al
     d5d:	add    BYTE PTR [rax],al
	...

0000000000000d60 <botlish_entry_12: ht_contains<HashTable, str>>:
     d60:	push   rbp
     d61:	mov    rbp,rsp
     d64:	mov    rsi,QWORD PTR [rdx]
     d67:	mov    rdx,QWORD PTR [rdx+0x8]
     d6b:	call   d70 <botlish_entry_12+0x10>
			d6c: R_X86_64_PLT32	botlish_fn_12-0x4 ; ht_contains<HashTable, str>
     d70:	mov    rsp,rbp
     d73:	pop    rbp
     d74:	ret
     d75:	add    BYTE PTR [rax],al
	...

0000000000000d78 <botlish_fn_13: ht_rehash_probe<mutarray, int, int>>:
     d78:	push   rbp
     d79:	mov    rbp,rsp
     d7c:	sub    rsp,0x40
     d80:	mov    QWORD PTR [rsp+0x20],rbx
     d85:	mov    QWORD PTR [rsp+0x28],r12
     d8a:	mov    QWORD PTR [rsp+0x30],r13
     d8f:	mov    QWORD PTR [rsp+0x38],r14
     d94:	mov    r13,rdi
     d97:	mov    QWORD PTR [rsp],rsi
     d9b:	mov    QWORD PTR [rsp+0x8],rdx
     da0:	mov    QWORD PTR [rsp+0x10],rcx
     da5:	mov    r12,rcx
     da8:	mov    rbx,rsi
     dab:	mov    r14,rdx
     dae:	mov    rdx,r14
     db1:	mov    rsi,rbx
     db4:	mov    rdi,r13
     db7:	call   dbc <botlish_fn_13+0x44>
			db8: R_X86_64_PLT32	rt_mutarray_get-0x4
     dbc:	test   rax,rax
     dbf:	je     e61 <botlish_fn_13+0xe9>
     dc5:	test   rax,0x1
     dcb:	mov    rsi,rax
     dce:	jne    def <botlish_fn_13+0x77>
     dd4:	mov    edx,0x1
     dd9:	mov    rdi,r13
     ddc:	call   de1 <botlish_fn_13+0x69>
			ddd: R_X86_64_PLT32	rt_value_eq-0x4
     de1:	test   rax,rax
     de4:	je     e61 <botlish_fn_13+0xe9>
     dea:	jmp    e00 <botlish_fn_13+0x88>
     def:	mov    eax,0x2
     df4:	cmp    rsi,0x1
     df8:	cmove  rax,QWORD PTR [rip+0xb8]        # eb8 <botlish_fn_13+0x140>
     e00:	cmp    rax,0x6
     e04:	je     e97 <botlish_fn_13+0x11f>
     e0a:	mov    QWORD PTR [rsp+0x18],0x3
     e13:	mov    rsi,r14
     e16:	test   rsi,0x1
     e1d:	je     e35 <botlish_fn_13+0xbd>
     e23:	mov    rsi,r14
     e26:	add    rsi,0x2
     e2a:	seto   al
     e2d:	test   al,al
     e2f:	je     e48 <botlish_fn_13+0xd0>
     e35:	mov    edx,0x3
     e3a:	mov    rsi,r14
     e3d:	mov    rdi,r13
     e40:	call   e45 <botlish_fn_13+0xcd>
			e41: R_X86_64_PLT32	rt_int_add-0x4
     e45:	mov    rsi,rax
     e48:	mov    QWORD PTR [rsp+0x8],rsi
     e4d:	mov    rdx,r12
     e50:	mov    rdi,r13
     e53:	call   e58 <botlish_fn_13+0xe0>
			e54: R_X86_64_PLT32	rt_int_mod-0x4
     e58:	test   rax,rax
     e5b:	jne    e81 <botlish_fn_13+0x109>
     e61:	xor    rax,rax
     e64:	mov    rbx,QWORD PTR [rsp+0x20]
     e69:	mov    r12,QWORD PTR [rsp+0x28]
     e6e:	mov    r13,QWORD PTR [rsp+0x30]
     e73:	mov    r14,QWORD PTR [rsp+0x38]
     e78:	add    rsp,0x40
     e7c:	mov    rsp,rbp
     e7f:	pop    rbp
     e80:	ret
     e81:	mov    QWORD PTR [rsp],rbx
     e85:	mov    QWORD PTR [rsp+0x8],rax
     e8a:	mov    QWORD PTR [rsp+0x10],r12
     e8f:	mov    r14,rax
     e92:	jmp    dae <botlish_fn_13+0x36>
     e97:	mov    rax,r14
     e9a:	mov    rbx,QWORD PTR [rsp+0x20]
     e9f:	mov    r12,QWORD PTR [rsp+0x28]
     ea4:	mov    r13,QWORD PTR [rsp+0x30]
     ea9:	mov    r14,QWORD PTR [rsp+0x38]
     eae:	add    rsp,0x40
     eb2:	mov    rsp,rbp
     eb5:	pop    rbp
     eb6:	ret
     eb7:	add    BYTE PTR [rsi],al
     eb9:	add    BYTE PTR [rax],al
     ebb:	add    BYTE PTR [rax],al
     ebd:	add    BYTE PTR [rax],al
	...

0000000000000ec0 <botlish_entry_13: ht_rehash_probe<mutarray, int, int>>:
     ec0:	push   rbp
     ec1:	mov    rbp,rsp
     ec4:	mov    rsi,QWORD PTR [rdx]
     ec7:	mov    r8,QWORD PTR [rdx+0x8]
     ecb:	mov    rcx,QWORD PTR [rdx+0x10]
     ecf:	mov    rdx,r8
     ed2:	call   ed7 <botlish_entry_13+0x17>
			ed3: R_X86_64_PLT32	botlish_fn_13-0x4 ; ht_rehash_probe<mutarray, int, int>
     ed7:	mov    rsp,rbp
     eda:	pop    rbp
     edb:	ret

0000000000000edc <botlish_fn_14: ht_rehash_insert<HashTable, int, any, any>>:
     edc:	push   rbp
     edd:	mov    rbp,rsp
     ee0:	sub    rsp,0x70
     ee4:	mov    QWORD PTR [rsp+0x40],rbx
     ee9:	mov    QWORD PTR [rsp+0x48],r12
     eee:	mov    QWORD PTR [rsp+0x50],r13
     ef3:	mov    QWORD PTR [rsp+0x58],r14
     ef8:	mov    QWORD PTR [rsp+0x60],r15
     efd:	mov    r13,rdi
     f00:	mov    QWORD PTR [rsp],rsi
     f04:	mov    QWORD PTR [rsp+0x8],rdx
     f09:	mov    r15,rdx
     f0c:	mov    QWORD PTR [rsp+0x10],rcx
     f11:	mov    r14,rcx
     f14:	mov    QWORD PTR [rsp+0x18],r8
     f19:	mov    r12,r8
     f1c:	mov    rax,QWORD PTR [rsi+0x18]
     f20:	mov    rbx,rsi
     f23:	mov    rsi,QWORD PTR [rax]
     f26:	mov    QWORD PTR [rsp+0x20],rsi
     f2b:	mov    QWORD PTR [rsp+0x30],rsi
     f30:	mov    rsi,r14
     f33:	mov    rdi,r13
     f36:	call   f3b <botlish_fn_14+0x5f>
			f37: R_X86_64_PLT32	rt_hash-0x4
     f3b:	test   rax,rax
     f3e:	je     fe5 <botlish_fn_14+0x109>
     f44:	mov    QWORD PTR [rsp+0x28],rax
     f49:	mov    rsi,rax
     f4c:	mov    rdx,r15
     f4f:	mov    rdi,r13
     f52:	call   f57 <botlish_fn_14+0x7b>
			f53: R_X86_64_PLT32	rt_int_mod-0x4
     f57:	test   rax,rax
     f5a:	je     fe5 <botlish_fn_14+0x109>
     f60:	mov    QWORD PTR [rsp+0x28],rax
     f65:	mov    rcx,r15
     f68:	mov    rdx,rax
     f6b:	mov    rsi,QWORD PTR [rsp+0x30]
     f70:	mov    rdi,r13
     f73:	call   f78 <botlish_fn_14+0x9c>
			f74: R_X86_64_PLT32	botlish_fn_13-0x4 ; ht_rehash_probe<mutarray, int, int>
     f78:	mov    rdx,rax
     f7b:	mov    r15,rax
     f7e:	test   rax,rdx
     f81:	je     fe5 <botlish_fn_14+0x109>
     f87:	mov    rcx,QWORD PTR [rbx+0x18]
     f8b:	mov    rsi,QWORD PTR [rcx]
     f8e:	mov    ecx,0x3
     f93:	mov    rdx,r15
     f96:	mov    rdi,r13
     f99:	call   f9e <botlish_fn_14+0xc2>
			f9a: R_X86_64_PLT32	rt_mutarray_set-0x4
     f9e:	test   rax,rax
     fa1:	je     fe5 <botlish_fn_14+0x109>
     fa7:	mov    rax,QWORD PTR [rbx+0x18]
     fab:	mov    rsi,QWORD PTR [rax+0x8]
     faf:	mov    rcx,r14
     fb2:	mov    rdx,r15
     fb5:	mov    rdi,r13
     fb8:	call   fbd <botlish_fn_14+0xe1>
			fb9: R_X86_64_PLT32	rt_mutarray_set-0x4
     fbd:	test   rax,rax
     fc0:	je     fe5 <botlish_fn_14+0x109>
     fc6:	mov    rax,QWORD PTR [rbx+0x18]
     fca:	mov    rsi,QWORD PTR [rax+0x10]
     fce:	mov    rcx,r12
     fd1:	mov    rdx,r15
     fd4:	mov    rdi,r13
     fd7:	call   fdc <botlish_fn_14+0x100>
			fd8: R_X86_64_PLT32	rt_mutarray_set-0x4
     fdc:	test   rax,rax
     fdf:	jne    100a <botlish_fn_14+0x12e>
     fe5:	xor    rax,rax
     fe8:	mov    rbx,QWORD PTR [rsp+0x40]
     fed:	mov    r12,QWORD PTR [rsp+0x48]
     ff2:	mov    r13,QWORD PTR [rsp+0x50]
     ff7:	mov    r14,QWORD PTR [rsp+0x58]
     ffc:	mov    r15,QWORD PTR [rsp+0x60]
    1001:	add    rsp,0x70
    1005:	mov    rsp,rbp
    1008:	pop    rbp
    1009:	ret
    100a:	mov    rax,rbx
    100d:	mov    rbx,QWORD PTR [rsp+0x40]
    1012:	mov    r12,QWORD PTR [rsp+0x48]
    1017:	mov    r13,QWORD PTR [rsp+0x50]
    101c:	mov    r14,QWORD PTR [rsp+0x58]
    1021:	mov    r15,QWORD PTR [rsp+0x60]
    1026:	add    rsp,0x70
    102a:	mov    rsp,rbp
    102d:	pop    rbp
    102e:	ret

000000000000102f <botlish_entry_14: ht_rehash_insert<HashTable, int, any, any>>:
    102f:	push   rbp
    1030:	mov    rbp,rsp
    1033:	mov    rsi,QWORD PTR [rdx]
    1036:	mov    r9,QWORD PTR [rdx+0x8]
    103a:	mov    rcx,QWORD PTR [rdx+0x10]
    103e:	mov    r8,QWORD PTR [rdx+0x18]
    1042:	mov    rdx,r9
    1045:	call   104a <botlish_entry_14+0x1b>
			1046: R_X86_64_PLT32	botlish_fn_14-0x4 ; ht_rehash_insert<HashTable, int, any, any>
    104a:	mov    rsp,rbp
    104d:	pop    rbp
    104e:	ret
	...

0000000000001050 <botlish_fn_15: ht_rehash_scan<mutarray, mutarray, mutarray, int, int, HashTable, int>>:
    1050:	push   rbp
    1051:	mov    rbp,rsp
    1054:	sub    rsp,0x90
    105b:	mov    QWORD PTR [rsp+0x60],rbx
    1060:	mov    QWORD PTR [rsp+0x68],r12
    1065:	mov    QWORD PTR [rsp+0x70],r13
    106a:	mov    QWORD PTR [rsp+0x78],r14
    106f:	mov    QWORD PTR [rsp+0x80],r15
    1077:	mov    QWORD PTR [rsp+0x38],rdi
    107c:	mov    QWORD PTR [rsp+0x40],r9
    1081:	mov    rdi,QWORD PTR [rbp+0x10]
    1085:	mov    rbx,QWORD PTR [rbp+0x18]
    1089:	mov    QWORD PTR [rsp],rsi
    108d:	mov    QWORD PTR [rsp+0x8],rdx
    1092:	mov    r14,rdx
    1095:	mov    QWORD PTR [rsp+0x10],rcx
    109a:	mov    r15,rcx
    109d:	mov    QWORD PTR [rsp+0x18],rdi
    10a2:	mov    QWORD PTR [rsp+0x20],rbx
    10a7:	sar    r8,1
    10aa:	mov    rcx,QWORD PTR [rsp+0x40]
    10af:	mov    r12,r8
    10b2:	mov    QWORD PTR [rsp+0x48],rdi
    10b7:	cmp    r12,rcx
    10ba:	mov    QWORD PTR [rsp+0x40],rcx
    10bf:	jge    1226 <botlish_fn_15+0x1d6>
    10c5:	mov    rdx,r12
    10c8:	shl    rdx,1
    10cb:	or     rdx,0x1
    10cf:	mov    r13,rsi
    10d2:	mov    QWORD PTR [rsp+0x58],rdx
    10d7:	mov    rdi,QWORD PTR [rsp+0x38]
    10dc:	call   10e1 <botlish_fn_15+0x91>
			10dd: R_X86_64_PLT32	rt_mutarray_get-0x4
    10e1:	test   rax,rax
    10e4:	je     11ca <botlish_fn_15+0x17a>
    10ea:	test   rax,0x1
    10f0:	mov    rsi,rax
    10f3:	jne    1116 <botlish_fn_15+0xc6>
    10f9:	mov    edx,0x3
    10fe:	mov    rdi,QWORD PTR [rsp+0x38]
    1103:	call   1108 <botlish_fn_15+0xb8>
			1104: R_X86_64_PLT32	rt_value_eq-0x4
    1108:	test   rax,rax
    110b:	je     11ca <botlish_fn_15+0x17a>
    1111:	jmp    1127 <botlish_fn_15+0xd7>
    1116:	mov    eax,0x2
    111b:	cmp    rsi,0x3
    111f:	cmove  rax,QWORD PTR [rip+0x131]        # 1258 <botlish_fn_15+0x208>
    1127:	cmp    rax,0x6
    112b:	je     1162 <botlish_fn_15+0x112>
    1131:	mov    QWORD PTR [rsp],r13
    1135:	mov    QWORD PTR [rsp+0x8],r14
    113a:	mov    QWORD PTR [rsp+0x10],r15
    113f:	mov    rsi,QWORD PTR [rsp+0x48]
    1144:	mov    QWORD PTR [rsp+0x18],rsi
    1149:	mov    QWORD PTR [rsp+0x20],rbx
    114e:	add    r12,0x1
    1155:	mov    rcx,QWORD PTR [rsp+0x40]
    115a:	mov    rsi,r13
    115d:	jmp    10b7 <botlish_fn_15+0x67>
    1162:	mov    rdx,QWORD PTR [rsp+0x58]
    1167:	mov    rsi,r14
    116a:	mov    rdi,QWORD PTR [rsp+0x38]
    116f:	call   1174 <botlish_fn_15+0x124>
			1170: R_X86_64_PLT32	rt_mutarray_get-0x4
    1174:	test   rax,rax
    1177:	je     11ca <botlish_fn_15+0x17a>
    117d:	mov    QWORD PTR [rsp+0x28],rax
    1182:	mov    rdx,QWORD PTR [rsp+0x58]
    1187:	mov    QWORD PTR [rsp+0x50],rax
    118c:	mov    rsi,r15
    118f:	mov    rdi,QWORD PTR [rsp+0x38]
    1194:	call   1199 <botlish_fn_15+0x149>
			1195: R_X86_64_PLT32	rt_mutarray_get-0x4
    1199:	test   rax,rax
    119c:	je     11ca <botlish_fn_15+0x17a>
    11a2:	mov    QWORD PTR [rsp+0x30],rax
    11a7:	mov    rcx,QWORD PTR [rsp+0x50]
    11ac:	mov    rsi,QWORD PTR [rsp+0x48]
    11b1:	mov    r8,rax
    11b4:	mov    rdx,rbx
    11b7:	mov    rdi,QWORD PTR [rsp+0x38]
    11bc:	call   11c1 <botlish_fn_15+0x171>
			11bd: R_X86_64_PLT32	botlish_fn_14-0x4 ; ht_rehash_insert<HashTable, int, any, any>
    11c1:	test   rax,rax
    11c4:	jne    11f5 <botlish_fn_15+0x1a5>
    11ca:	xor    rax,rax
    11cd:	mov    rbx,QWORD PTR [rsp+0x60]
    11d2:	mov    r12,QWORD PTR [rsp+0x68]
    11d7:	mov    r13,QWORD PTR [rsp+0x70]
    11dc:	mov    r14,QWORD PTR [rsp+0x78]
    11e1:	mov    r15,QWORD PTR [rsp+0x80]
    11e9:	add    rsp,0x90
    11f0:	mov    rsp,rbp
    11f3:	pop    rbp
    11f4:	ret
    11f5:	mov    QWORD PTR [rsp],r13
    11f9:	mov    QWORD PTR [rsp+0x8],r14
    11fe:	mov    QWORD PTR [rsp+0x10],r15
    1203:	mov    QWORD PTR [rsp+0x18],rax
    1208:	mov    QWORD PTR [rsp+0x20],rbx
    120d:	add    r12,0x1
    1214:	mov    rcx,QWORD PTR [rsp+0x40]
    1219:	mov    rsi,r13
    121c:	mov    QWORD PTR [rsp+0x48],rax
    1221:	jmp    10b7 <botlish_fn_15+0x67>
    1226:	mov    rax,QWORD PTR [rsp+0x48]
    122b:	mov    rbx,QWORD PTR [rsp+0x60]
    1230:	mov    r12,QWORD PTR [rsp+0x68]
    1235:	mov    r13,QWORD PTR [rsp+0x70]
    123a:	mov    r14,QWORD PTR [rsp+0x78]
    123f:	mov    r15,QWORD PTR [rsp+0x80]
    1247:	add    rsp,0x90
    124e:	mov    rsp,rbp
    1251:	pop    rbp
    1252:	ret
    1253:	add    BYTE PTR [rax],al
    1255:	add    BYTE PTR [rax],al
    1257:	add    BYTE PTR [rsi],al
    1259:	add    BYTE PTR [rax],al
    125b:	add    BYTE PTR [rax],al
    125d:	add    BYTE PTR [rax],al
	...

0000000000001260 <botlish_entry_15: ht_rehash_scan<mutarray, mutarray, mutarray, int, int, HashTable, int>>:
    1260:	push   rbp
    1261:	mov    rbp,rsp
    1264:	sub    rsp,0x10
    1268:	mov    rsi,QWORD PTR [rdx]
    126b:	mov    r11,QWORD PTR [rdx+0x8]
    126f:	mov    rcx,QWORD PTR [rdx+0x10]
    1273:	mov    r8,QWORD PTR [rdx+0x18]
    1277:	mov    r9,QWORD PTR [rdx+0x20]
    127b:	mov    rax,QWORD PTR [rdx+0x28]
    127f:	mov    rdx,QWORD PTR [rdx+0x30]
    1283:	sar    r9,1
    1286:	mov    QWORD PTR [rsp],rax
    128a:	mov    QWORD PTR [rsp+0x8],rdx
    128f:	mov    rdx,r11
    1292:	call   1297 <botlish_entry_15+0x37>
			1293: R_X86_64_PLT32	botlish_fn_15-0x4 ; ht_rehash_scan<mutarray, mutarray, mutarray, int, int, HashTable, int>
    1297:	add    rsp,0x10
    129b:	mov    rsp,rbp
    129e:	pop    rbp
    129f:	ret

00000000000012a0 <botlish_fn_16: ht_rehash<HashTable, int>>:
    12a0:	push   rbp
    12a1:	mov    rbp,rsp
    12a4:	sub    rsp,0xf0
    12ab:	mov    QWORD PTR [rsp+0xc0],rbx
    12b3:	mov    QWORD PTR [rsp+0xc8],r12
    12bb:	mov    QWORD PTR [rsp+0xd0],r13
    12c3:	mov    QWORD PTR [rsp+0xd8],r14
    12cb:	mov    QWORD PTR [rsp+0xe0],r15
    12d3:	mov    QWORD PTR [rsp+0x90],rdi
    12db:	mov    QWORD PTR [rsp+0x20],0x0
    12e4:	mov    QWORD PTR [rsp+0x28],0x0
    12ed:	mov    QWORD PTR [rsp+0x30],0x0
    12f6:	mov    QWORD PTR [rsp+0x38],0x0
    12ff:	mov    QWORD PTR [rsp+0x40],0x0
    1308:	mov    QWORD PTR [rsp+0x48],0x0
    1311:	mov    QWORD PTR [rsp+0x50],0x0
    131a:	mov    QWORD PTR [rsp+0x10],rsi
    131f:	mov    r14,rsi
    1322:	mov    QWORD PTR [rsp+0x18],rdx
    1327:	mov    QWORD PTR [rsp+0x98],rdx
    132f:	lea    rdx,[rsp+0x58]
    1334:	mov    rsi,QWORD PTR [rsp+0x98]
    133c:	mov    rdi,QWORD PTR [rsp+0x90]
    1344:	call   1349 <botlish_fn_16+0xa9>
			1345: R_X86_64_PLT32	botlish_fn_2-0x4 ; ht_alloc<int>
    1349:	test   rax,rax
    134c:	je     14a0 <botlish_fn_16+0x200>
    1352:	mov    QWORD PTR [rsp+0x10],rax
    1357:	mov    QWORD PTR [rsp+0xb8],rax
    135f:	mov    rbx,QWORD PTR [rsp+0x58]
    1364:	mov    QWORD PTR [rsp+0x20],rbx
    1369:	mov    r12,QWORD PTR [rsp+0x60]
    136e:	mov    QWORD PTR [rsp+0x28],r12
    1373:	mov    r13,QWORD PTR [rsp+0x68]
    1378:	mov    QWORD PTR [rsp+0x30],r13
    137d:	mov    rsi,r14
    1380:	mov    rdi,QWORD PTR [rsp+0x90]
    1388:	call   138d <botlish_fn_16+0xed>
			1389: R_X86_64_PLT32	botlish_fn_4-0x4 ; ht_size<HashTable>
    138d:	test   rax,rax
    1390:	mov    rcx,rax
    1393:	je     14a0 <botlish_fn_16+0x200>
    1399:	mov    edx,0x1
    139e:	mov    rsi,r13
    13a1:	mov    rdi,QWORD PTR [rsp+0x90]
    13a9:	call   13ae <botlish_fn_16+0x10e>
			13aa: R_X86_64_PLT32	rt_mutarray_set-0x4
    13ae:	test   rax,rax
    13b1:	je     14a0 <botlish_fn_16+0x200>
    13b7:	mov    rsi,r14
    13ba:	mov    rax,QWORD PTR [rsi+0x18]
    13be:	mov    rcx,QWORD PTR [rax]
    13c1:	mov    QWORD PTR [rsp+0x38],rcx
    13c6:	mov    QWORD PTR [rsp+0xb0],rcx
    13ce:	mov    rax,QWORD PTR [rsi+0x18]
    13d2:	mov    r15,QWORD PTR [rax+0x8]
    13d6:	mov    QWORD PTR [rsp+0x40],r15
    13db:	mov    rax,QWORD PTR [rsi+0x18]
    13df:	mov    r14,QWORD PTR [rax+0x10]
    13e3:	mov    QWORD PTR [rsp+0x48],r14
    13e8:	mov    r8d,0x1
    13ee:	mov    QWORD PTR [rsp+0xa8],r8
    13f6:	mov    QWORD PTR [rsp+0x50],0x1
    13ff:	mov    rdi,QWORD PTR [rsp+0x90]
    1407:	call   140c <botlish_fn_16+0x16c>
			1408: R_X86_64_PLT32	botlish_fn_6-0x4 ; ht_capacity<HashTable>
    140c:	mov    QWORD PTR [rsp+0xa0],rax
    1414:	lea    rcx,[rsp+0x70]
    1419:	mov    rax,QWORD PTR [rsp+0xb8]
    1421:	mov    QWORD PTR [rsp+0x70],rax
    1426:	mov    QWORD PTR [rsp+0x78],rbx
    142b:	mov    QWORD PTR [rsp+0x80],r12
    1433:	mov    QWORD PTR [rsp+0x88],r13
    143b:	xor    rsi,rsi
    143e:	mov    edx,0x4
    1443:	mov    rdi,QWORD PTR [rsp+0x90]
    144b:	call   1450 <botlish_fn_16+0x1b0>
			144c: R_X86_64_PLT32	rt_struct_new-0x4
    1450:	mov    QWORD PTR [rsp+0x10],rax
    1455:	mov    rcx,QWORD PTR [rsp+0xa0]
    145d:	mov    r9,rcx
    1460:	sar    r9,1
    1463:	mov    QWORD PTR [rsp],rax
    1467:	mov    rdx,QWORD PTR [rsp+0x98]
    146f:	mov    QWORD PTR [rsp+0x8],rdx
    1474:	mov    rcx,r14
    1477:	mov    rdx,r15
    147a:	mov    rsi,QWORD PTR [rsp+0xb0]
    1482:	mov    rdi,QWORD PTR [rsp+0x90]
    148a:	mov    r8,QWORD PTR [rsp+0xa8]
    1492:	call   1497 <botlish_fn_16+0x1f7>
			1493: R_X86_64_PLT32	botlish_fn_15-0x4 ; ht_rehash_scan<mutarray, mutarray, mutarray, int, int, HashTable, int>
    1497:	test   rax,rax
    149a:	jne    14d7 <botlish_fn_16+0x237>
    14a0:	xor    rax,rax
    14a3:	mov    rbx,QWORD PTR [rsp+0xc0]
    14ab:	mov    r12,QWORD PTR [rsp+0xc8]
    14b3:	mov    r13,QWORD PTR [rsp+0xd0]
    14bb:	mov    r14,QWORD PTR [rsp+0xd8]
    14c3:	mov    r15,QWORD PTR [rsp+0xe0]
    14cb:	add    rsp,0xf0
    14d2:	mov    rsp,rbp
    14d5:	pop    rbp
    14d6:	ret
    14d7:	mov    rbx,QWORD PTR [rsp+0xc0]
    14df:	mov    r12,QWORD PTR [rsp+0xc8]
    14e7:	mov    r13,QWORD PTR [rsp+0xd0]
    14ef:	mov    r14,QWORD PTR [rsp+0xd8]
    14f7:	mov    r15,QWORD PTR [rsp+0xe0]
    14ff:	add    rsp,0xf0
    1506:	mov    rsp,rbp
    1509:	pop    rbp
    150a:	ret

000000000000150b <botlish_entry_16: ht_rehash<HashTable, int>>:
    150b:	push   rbp
    150c:	mov    rbp,rsp
    150f:	mov    rsi,QWORD PTR [rdx]
    1512:	mov    rdx,QWORD PTR [rdx+0x8]
    1516:	call   151b <botlish_entry_16+0x10>
			1517: R_X86_64_PLT32	botlish_fn_16-0x4 ; ht_rehash<HashTable, int>
    151b:	mov    rsp,rbp
    151e:	pop    rbp
    151f:	ret

0000000000001520 <botlish_fn_17: ht_should_grow<HashTable>>:
    1520:	push   rbp
    1521:	mov    rbp,rsp
    1524:	sub    rsp,0x40
    1528:	mov    QWORD PTR [rsp+0x20],rbx
    152d:	mov    QWORD PTR [rsp+0x28],r12
    1532:	mov    QWORD PTR [rsp+0x30],r13
    1537:	mov    rbx,rdi
    153a:	mov    QWORD PTR [rsp],rsi
    153e:	mov    r12,rsi
    1541:	mov    rsi,r12
    1544:	mov    rdi,rbx
    1547:	call   154c <botlish_fn_17+0x2c>
			1548: R_X86_64_PLT32	botlish_fn_4-0x4 ; ht_size<HashTable>
    154c:	mov    rcx,rax
    154f:	mov    r13,rax
    1552:	test   rax,rcx
    1555:	je     162c <botlish_fn_17+0x10c>
    155b:	mov    rax,r13
    155e:	mov    QWORD PTR [rsp+0x8],rax
    1563:	mov    rsi,r12
    1566:	mov    rdi,rbx
    1569:	call   156e <botlish_fn_17+0x4e>
			156a: R_X86_64_PLT32	botlish_fn_5-0x4 ; ht_tombstones<HashTable>
    156e:	mov    rcx,rax
    1571:	test   rcx,rcx
    1574:	je     162c <botlish_fn_17+0x10c>
    157a:	mov    QWORD PTR [rsp+0x10],rcx
    157f:	mov    edx,0x1
    1584:	mov    rax,r13
    1587:	test   rax,0x1
    158d:	jne    15b0 <botlish_fn_17+0x90>
    1593:	xor    edx,edx
    1595:	mov    rax,r13
    1598:	test   rax,0x7
    159e:	jne    15b0 <botlish_fn_17+0x90>
    15a4:	mov    rax,r13
    15a7:	movzx  rax,BYTE PTR [rax]
    15ab:	cmp    al,0x1
    15ad:	sete   dl
    15b0:	test   dl,dl
    15b2:	jne    15d2 <botlish_fn_17+0xb2>
    15b8:	mov    rdi,rbx
    15bb:	mov    rax,QWORD PTR [rdi+0x10]
    15bf:	mov    rcx,QWORD PTR [rax]
    15c2:	xor    rdx,rdx
    15c5:	mov    rsi,r13
    15c8:	call   15cd <botlish_fn_17+0xad>
			15c9: R_X86_64_PLT32	rt_type_error-0x4
    15cd:	jmp    162c <botlish_fn_17+0x10c>
    15d2:	mov    eax,0x1
    15d7:	test   rcx,0x1
    15de:	je     15ec <botlish_fn_17+0xcc>
    15e4:	mov    r8,rcx
    15e7:	jmp    160f <botlish_fn_17+0xef>
    15ec:	xor    eax,eax
    15ee:	test   rcx,0x7
    15f5:	je     1603 <botlish_fn_17+0xe3>
    15fb:	mov    r8,rcx
    15fe:	jmp    160f <botlish_fn_17+0xef>
    1603:	movzx  rax,BYTE PTR [rcx]
    1607:	mov    r8,rcx
    160a:	cmp    al,0x1
    160c:	sete   al
    160f:	test   al,al
    1611:	jne    1647 <botlish_fn_17+0x127>
    1617:	mov    rdi,rbx
    161a:	mov    rax,QWORD PTR [rdi+0x10]
    161e:	mov    rcx,QWORD PTR [rax]
    1621:	xor    rdx,rdx
    1624:	mov    rsi,r8
    1627:	call   162c <botlish_fn_17+0x10c>
			1628: R_X86_64_PLT32	rt_type_error-0x4
    162c:	xor    rax,rax
    162f:	mov    rbx,QWORD PTR [rsp+0x20]
    1634:	mov    r12,QWORD PTR [rsp+0x28]
    1639:	mov    r13,QWORD PTR [rsp+0x30]
    163e:	add    rsp,0x40
    1642:	mov    rsp,rbp
    1645:	pop    rbp
    1646:	ret
    1647:	mov    rcx,r8
    164a:	mov    rsi,r13
    164d:	mov    rax,rsi
    1650:	and    rax,rcx
    1653:	test   rax,0x1
    1659:	jne    166a <botlish_fn_17+0x14a>
    165f:	mov    rdx,r8
    1662:	mov    rsi,r13
    1665:	jmp    1688 <botlish_fn_17+0x168>
    166a:	mov    rcx,r8
    166d:	lea    rax,[rcx-0x1]
    1671:	mov    rsi,r13
    1674:	add    rsi,rax
    1677:	seto   al
    167a:	test   al,al
    167c:	je     1693 <botlish_fn_17+0x173>
    1682:	mov    rdx,r8
    1685:	mov    rsi,r13
    1688:	mov    rdi,rbx
    168b:	call   1690 <botlish_fn_17+0x170>
			168c: R_X86_64_PLT32	rt_int_add-0x4
    1690:	mov    rsi,rax
    1693:	mov    QWORD PTR [rsp+0x8],rsi
    1698:	mov    QWORD PTR [rsp+0x10],0x3
    16a1:	test   rsi,0x1
    16a8:	je     16cb <botlish_fn_17+0x1ab>
    16ae:	mov    rax,rsi
    16b1:	add    rax,0x2
    16b5:	mov    rcx,rax
    16b8:	seto   al
    16bb:	test   al,al
    16bd:	jne    16cb <botlish_fn_17+0x1ab>
    16c3:	mov    rsi,rcx
    16c6:	jmp    16db <botlish_fn_17+0x1bb>
    16cb:	mov    edx,0x3
    16d0:	mov    rdi,rbx
    16d3:	call   16d8 <botlish_fn_17+0x1b8>
			16d4: R_X86_64_PLT32	rt_int_add-0x4
    16d8:	mov    rsi,rax
    16db:	mov    QWORD PTR [rsp+0x8],rsi
    16e0:	mov    edx,0x7
    16e5:	mov    rdi,rdx
    16e8:	mov    QWORD PTR [rsp+0x10],0x7
    16f1:	test   rsi,0x1
    16f8:	jne    1706 <botlish_fn_17+0x1e6>
    16fe:	mov    rdx,rdi
    1701:	jmp    1732 <botlish_fn_17+0x212>
    1706:	mov    rax,rsi
    1709:	sar    rax,1
    170c:	imul   QWORD PTR [rip+0xf5]        # 1808 <botlish_fn_17+0x2e8>
    1713:	seto   cl
    1716:	or     rax,0x1
    171a:	test   cl,cl
    171c:	je     172a <botlish_fn_17+0x20a>
    1722:	mov    rdx,rdi
    1725:	jmp    1732 <botlish_fn_17+0x212>
    172a:	mov    rsi,rax
    172d:	jmp    173d <botlish_fn_17+0x21d>
    1732:	mov    rdi,rbx
    1735:	call   173a <botlish_fn_17+0x21a>
			1736: R_X86_64_PLT32	rt_int_mul-0x4
    173a:	mov    rsi,rax
    173d:	mov    QWORD PTR [rsp],rsi
    1741:	mov    r13,rsi
    1744:	mov    rsi,r12
    1747:	mov    rdi,rbx
    174a:	call   174f <botlish_fn_17+0x22f>
			174b: R_X86_64_PLT32	botlish_fn_6-0x4 ; ht_capacity<HashTable>
    174f:	mov    QWORD PTR [rsp+0x8],rax
    1754:	mov    QWORD PTR [rsp+0x10],0x5
    175d:	test   rax,0x1
    1763:	mov    rcx,rax
    1766:	je     1795 <botlish_fn_17+0x275>
    176c:	mov    rax,rcx
    176f:	sar    rax,1
    1772:	imul   QWORD PTR [rip+0x97]        # 1810 <botlish_fn_17+0x2f0>
    1779:	seto   sil
    177d:	or     rax,0x1
    1781:	test   sil,sil
    1784:	jne    1795 <botlish_fn_17+0x275>
    178a:	mov    rdx,rax
    178d:	mov    rsi,r13
    1790:	jmp    17ab <botlish_fn_17+0x28b>
    1795:	mov    edx,0x5
    179a:	mov    rsi,rcx
    179d:	mov    rdi,rbx
    17a0:	call   17a5 <botlish_fn_17+0x285>
			17a1: R_X86_64_PLT32	rt_int_mul-0x4
    17a5:	mov    rdx,rax
    17a8:	mov    rsi,r13
    17ab:	mov    rdi,rsi
    17ae:	and    rdi,rdx
    17b1:	test   rdi,0x1
    17b8:	jne    17de <botlish_fn_17+0x2be>
    17be:	mov    rdi,rbx
    17c1:	call   17c6 <botlish_fn_17+0x2a6>
			17c2: R_X86_64_PLT32	rt_int_cmp-0x4
    17c6:	mov    esi,0x2
    17cb:	test   rax,rax
    17ce:	mov    rax,rsi
    17d1:	cmovg  rax,QWORD PTR [rip+0x2f]        # 1808 <botlish_fn_17+0x2e8>
    17d9:	jmp    17ee <botlish_fn_17+0x2ce>
    17de:	mov    eax,0x2
    17e3:	cmp    rsi,rdx
    17e6:	cmovg  rax,QWORD PTR [rip+0x1a]        # 1808 <botlish_fn_17+0x2e8>
    17ee:	mov    rbx,QWORD PTR [rsp+0x20]
    17f3:	mov    r12,QWORD PTR [rsp+0x28]
    17f8:	mov    r13,QWORD PTR [rsp+0x30]
    17fd:	add    rsp,0x40
    1801:	mov    rsp,rbp
    1804:	pop    rbp
    1805:	ret
    1806:	add    BYTE PTR [rax],al
    1808:	(bad)
    1809:	add    BYTE PTR [rax],al
    180b:	add    BYTE PTR [rax],al
    180d:	add    BYTE PTR [rax],al
    180f:	add    BYTE PTR [rax+rax*1],al
    1812:	add    BYTE PTR [rax],al
    1814:	add    BYTE PTR [rax],al
	...

0000000000001818 <botlish_entry_17: ht_should_grow<HashTable>>:
    1818:	push   rbp
    1819:	mov    rbp,rsp
    181c:	mov    rsi,QWORD PTR [rdx]
    181f:	call   1824 <botlish_entry_17+0xc>
			1820: R_X86_64_PLT32	botlish_fn_17-0x4 ; ht_should_grow<HashTable>
    1824:	mov    rsp,rbp
    1827:	pop    rbp
    1828:	ret
    1829:	add    BYTE PTR [rax],al
    182b:	add    BYTE PTR [rax],al
    182d:	add    BYTE PTR [rax],al
	...

0000000000001830 <botlish_fn_18: ht_grow_or_clean<HashTable>>:
    1830:	push   rbp
    1831:	mov    rbp,rsp
    1834:	sub    rsp,0x40
    1838:	mov    QWORD PTR [rsp+0x20],rbx
    183d:	mov    QWORD PTR [rsp+0x28],r12
    1842:	mov    QWORD PTR [rsp+0x30],r13
    1847:	mov    rbx,rdi
    184a:	mov    QWORD PTR [rsp+0x10],0x0
    1853:	mov    QWORD PTR [rsp],rsi
    1857:	mov    r12,rsi
    185a:	mov    rsi,r12
    185d:	mov    rdi,rbx
    1860:	call   1865 <botlish_fn_18+0x35>
			1861: R_X86_64_PLT32	botlish_fn_5-0x4 ; ht_tombstones<HashTable>
    1865:	test   rax,rax
    1868:	mov    r13,rax
    186b:	je     1a59 <botlish_fn_18+0x229>
    1871:	mov    rsi,r12
    1874:	mov    rdi,rbx
    1877:	call   187c <botlish_fn_18+0x4c>
			1878: R_X86_64_PLT32	botlish_fn_4-0x4 ; ht_size<HashTable>
    187c:	mov    r11,rax
    187f:	test   r11,r11
    1882:	je     1a59 <botlish_fn_18+0x229>
    1888:	mov    ecx,0x1
    188d:	mov    rax,r13
    1890:	test   rax,0x1
    1896:	je     18a4 <botlish_fn_18+0x74>
    189c:	mov    r13,rax
    189f:	jmp    18c8 <botlish_fn_18+0x98>
    18a4:	xor    ecx,ecx
    18a6:	test   rax,0x7
    18ac:	je     18ba <botlish_fn_18+0x8a>
    18b2:	mov    r13,rax
    18b5:	jmp    18c8 <botlish_fn_18+0x98>
    18ba:	movzx  rcx,BYTE PTR [rax]
    18be:	mov    r13,rax
    18c1:	rex cmp cl,0x1
    18c5:	sete   cl
    18c8:	test   cl,cl
    18ca:	jne    18eb <botlish_fn_18+0xbb>
    18d0:	mov    rdi,rbx
    18d3:	mov    rsi,QWORD PTR [rdi+0x10]
    18d7:	mov    rcx,QWORD PTR [rsi+0x8]
    18db:	xor    rdx,rdx
    18de:	mov    rsi,r13
    18e1:	call   18e6 <botlish_fn_18+0xb6>
			18e2: R_X86_64_PLT32	rt_type_error-0x4
    18e6:	jmp    1a59 <botlish_fn_18+0x229>
    18eb:	mov    rsi,r13
    18ee:	mov    eax,0x1
    18f3:	test   r11,0x1
    18fa:	je     1908 <botlish_fn_18+0xd8>
    1900:	mov    r8,r11
    1903:	jmp    192d <botlish_fn_18+0xfd>
    1908:	xor    eax,eax
    190a:	test   r11,0x7
    1911:	je     191f <botlish_fn_18+0xef>
    1917:	mov    r8,r11
    191a:	jmp    192d <botlish_fn_18+0xfd>
    191f:	movzx  r10,BYTE PTR [r11]
    1923:	mov    r8,r11
    1926:	cmp    r10b,0x1
    192a:	sete   al
    192d:	test   al,al
    192f:	jne    1950 <botlish_fn_18+0x120>
    1935:	mov    rdi,rbx
    1938:	mov    rax,QWORD PTR [rdi+0x10]
    193c:	mov    rcx,QWORD PTR [rax+0x8]
    1940:	xor    rdx,rdx
    1943:	mov    rsi,r8
    1946:	call   194b <botlish_fn_18+0x11b>
			1947: R_X86_64_PLT32	rt_type_error-0x4
    194b:	jmp    1a59 <botlish_fn_18+0x229>
    1950:	mov    r11,r8
    1953:	mov    rax,rsi
    1956:	and    rax,r11
    1959:	test   rax,0x1
    195f:	jne    1985 <botlish_fn_18+0x155>
    1965:	mov    rdx,r8
    1968:	mov    rdi,rbx
    196b:	call   1970 <botlish_fn_18+0x140>
			196c: R_X86_64_PLT32	rt_int_cmp-0x4
    1970:	mov    ecx,0x2
    1975:	test   rax,rax
    1978:	cmovg  rcx,QWORD PTR [rip+0x110]        # 1a90 <botlish_fn_18+0x260>
    1980:	jmp    1998 <botlish_fn_18+0x168>
    1985:	mov    ecx,0x2
    198a:	mov    r11,r8
    198d:	cmp    rsi,r11
    1990:	cmovg  rcx,QWORD PTR [rip+0xf8]        # 1a90 <botlish_fn_18+0x260>
    1998:	cmp    rcx,0x6
    199c:	je     1a32 <botlish_fn_18+0x202>
    19a2:	mov    rsi,r12
    19a5:	mov    rdi,rbx
    19a8:	call   19ad <botlish_fn_18+0x17d>
			19a9: R_X86_64_PLT32	botlish_fn_6-0x4 ; ht_capacity<HashTable>
    19ad:	mov    QWORD PTR [rsp+0x8],rax
    19b2:	mov    QWORD PTR [rsp+0x10],0x5
    19bb:	test   rax,0x1
    19c1:	mov    rsi,rax
    19c4:	je     19f1 <botlish_fn_18+0x1c1>
    19ca:	mov    rcx,rsi
    19cd:	mov    rax,rcx
    19d0:	sar    rax,1
    19d3:	imul   QWORD PTR [rip+0xbe]        # 1a98 <botlish_fn_18+0x268>
    19da:	seto   cl
    19dd:	or     rax,0x1
    19e1:	test   cl,cl
    19e3:	jne    19f1 <botlish_fn_18+0x1c1>
    19e9:	mov    rdx,rax
    19ec:	jmp    1a01 <botlish_fn_18+0x1d1>
    19f1:	mov    edx,0x5
    19f6:	mov    rdi,rbx
    19f9:	call   19fe <botlish_fn_18+0x1ce>
			19fa: R_X86_64_PLT32	rt_int_mul-0x4
    19fe:	mov    rdx,rax
    1a01:	mov    QWORD PTR [rsp+0x8],rdx
    1a06:	mov    rsi,r12
    1a09:	mov    rdi,rbx
    1a0c:	call   1a11 <botlish_fn_18+0x1e1>
			1a0d: R_X86_64_PLT32	botlish_fn_16-0x4 ; ht_rehash<HashTable, int>
    1a11:	test   rax,rax
    1a14:	je     1a59 <botlish_fn_18+0x229>
    1a1a:	mov    rbx,QWORD PTR [rsp+0x20]
    1a1f:	mov    r12,QWORD PTR [rsp+0x28]
    1a24:	mov    r13,QWORD PTR [rsp+0x30]
    1a29:	add    rsp,0x40
    1a2d:	mov    rsp,rbp
    1a30:	pop    rbp
    1a31:	ret
    1a32:	mov    rsi,r12
    1a35:	mov    rdi,rbx
    1a38:	call   1a3d <botlish_fn_18+0x20d>
			1a39: R_X86_64_PLT32	botlish_fn_6-0x4 ; ht_capacity<HashTable>
    1a3d:	mov    QWORD PTR [rsp+0x8],rax
    1a42:	mov    rdx,rax
    1a45:	mov    rsi,r12
    1a48:	mov    rdi,rbx
    1a4b:	call   1a50 <botlish_fn_18+0x220>
			1a4c: R_X86_64_PLT32	botlish_fn_16-0x4 ; ht_rehash<HashTable, int>
    1a50:	test   rax,rax
    1a53:	jne    1a74 <botlish_fn_18+0x244>
    1a59:	xor    rax,rax
    1a5c:	mov    rbx,QWORD PTR [rsp+0x20]
    1a61:	mov    r12,QWORD PTR [rsp+0x28]
    1a66:	mov    r13,QWORD PTR [rsp+0x30]
    1a6b:	add    rsp,0x40
    1a6f:	mov    rsp,rbp
    1a72:	pop    rbp
    1a73:	ret
    1a74:	mov    rbx,QWORD PTR [rsp+0x20]
    1a79:	mov    r12,QWORD PTR [rsp+0x28]
    1a7e:	mov    r13,QWORD PTR [rsp+0x30]
    1a83:	add    rsp,0x40
    1a87:	mov    rsp,rbp
    1a8a:	pop    rbp
    1a8b:	ret
    1a8c:	add    BYTE PTR [rax],al
    1a8e:	add    BYTE PTR [rax],al
    1a90:	(bad)
    1a91:	add    BYTE PTR [rax],al
    1a93:	add    BYTE PTR [rax],al
    1a95:	add    BYTE PTR [rax],al
    1a97:	add    BYTE PTR [rax+rax*1],al
    1a9a:	add    BYTE PTR [rax],al
    1a9c:	add    BYTE PTR [rax],al
	...

0000000000001aa0 <botlish_entry_18: ht_grow_or_clean<HashTable>>:
    1aa0:	push   rbp
    1aa1:	mov    rbp,rsp
    1aa4:	mov    rsi,QWORD PTR [rdx]
    1aa7:	call   1aac <botlish_entry_18+0xc>
			1aa8: R_X86_64_PLT32	botlish_fn_18-0x4 ; ht_grow_or_clean<HashTable>
    1aac:	mov    rsp,rbp
    1aaf:	pop    rbp
    1ab0:	ret
    1ab1:	add    BYTE PTR [rax],al
    1ab3:	add    BYTE PTR [rax],al
    1ab5:	add    BYTE PTR [rax],al
	...

0000000000001ab8 <botlish_fn_19: ht_place<HashTable, int, str, str>>:
    1ab8:	push   rbp
    1ab9:	mov    rbp,rsp
    1abc:	sub    rsp,0x70
    1ac0:	mov    QWORD PTR [rsp+0x40],rbx
    1ac5:	mov    QWORD PTR [rsp+0x48],r12
    1aca:	mov    QWORD PTR [rsp+0x50],r13
    1acf:	mov    QWORD PTR [rsp+0x58],r14
    1ad4:	mov    QWORD PTR [rsp+0x60],r15
    1ad9:	mov    r12,rdi
    1adc:	mov    r14,r8
    1adf:	mov    r15,rdx
    1ae2:	mov    QWORD PTR [rsp+0x30],rcx
    1ae7:	mov    QWORD PTR [rsp],rsi
    1aeb:	mov    r9,QWORD PTR [rsi+0x18]
    1aef:	mov    r13,rsi
    1af2:	mov    rsi,QWORD PTR [r9]
    1af5:	mov    rdx,r15
    1af8:	mov    rdi,r12
    1afb:	call   1b00 <botlish_fn_19+0x48>
			1afc: R_X86_64_PLT32	rt_mutarray_get-0x4
    1b00:	test   rax,rax
    1b03:	je     1d97 <botlish_fn_19+0x2df>
    1b09:	mov    QWORD PTR [rsp+0x8],rax
    1b0e:	mov    rbx,r13
    1b11:	mov    r13,rax
    1b14:	mov    rax,QWORD PTR [rbx+0x18]
    1b18:	mov    rsi,QWORD PTR [rax]
    1b1b:	mov    ecx,0x3
    1b20:	mov    rdx,r15
    1b23:	mov    rdi,r12
    1b26:	call   1b2b <botlish_fn_19+0x73>
			1b27: R_X86_64_PLT32	rt_mutarray_set-0x4
    1b2b:	test   rax,rax
    1b2e:	je     1d97 <botlish_fn_19+0x2df>
    1b34:	mov    rax,QWORD PTR [rbx+0x18]
    1b38:	mov    rsi,QWORD PTR [rax+0x8]
    1b3c:	mov    rcx,QWORD PTR [rsp+0x30]
    1b41:	mov    rdx,r15
    1b44:	mov    rdi,r12
    1b47:	call   1b4c <botlish_fn_19+0x94>
			1b48: R_X86_64_PLT32	rt_mutarray_set-0x4
    1b4c:	test   rax,rax
    1b4f:	je     1d97 <botlish_fn_19+0x2df>
    1b55:	mov    rax,QWORD PTR [rbx+0x18]
    1b59:	mov    rsi,QWORD PTR [rax+0x10]
    1b5d:	mov    rcx,r14
    1b60:	mov    rdx,r15
    1b63:	mov    rdi,r12
    1b66:	call   1b6b <botlish_fn_19+0xb3>
			1b67: R_X86_64_PLT32	rt_mutarray_set-0x4
    1b6b:	test   rax,rax
    1b6e:	je     1d97 <botlish_fn_19+0x2df>
    1b74:	mov    rax,QWORD PTR [rbx+0x18]
    1b78:	mov    rsi,QWORD PTR [rax+0x18]
    1b7c:	mov    QWORD PTR [rsp+0x10],rsi
    1b81:	mov    r14,rsi
    1b84:	mov    QWORD PTR [rsp+0x18],0x1
    1b8d:	mov    rsi,rbx
    1b90:	mov    rdi,r12
    1b93:	call   1b98 <botlish_fn_19+0xe0>
			1b94: R_X86_64_PLT32	botlish_fn_4-0x4 ; ht_size<HashTable>
    1b98:	test   rax,rax
    1b9b:	je     1d97 <botlish_fn_19+0x2df>
    1ba1:	mov    QWORD PTR [rsp+0x20],rax
    1ba6:	mov    QWORD PTR [rsp+0x28],0x3
    1baf:	mov    ecx,0x1
    1bb4:	test   rax,0x1
    1bba:	je     1bc8 <botlish_fn_19+0x110>
    1bc0:	mov    rsi,rax
    1bc3:	jmp    1bec <botlish_fn_19+0x134>
    1bc8:	xor    ecx,ecx
    1bca:	test   rax,0x7
    1bd0:	je     1bde <botlish_fn_19+0x126>
    1bd6:	mov    rsi,rax
    1bd9:	jmp    1bec <botlish_fn_19+0x134>
    1bde:	movzx  rcx,BYTE PTR [rax]
    1be2:	mov    rsi,rax
    1be5:	rex cmp cl,0x1
    1be9:	sete   cl
    1bec:	test   cl,cl
    1bee:	jne    1c0b <botlish_fn_19+0x153>
    1bf4:	mov    rdi,r12
    1bf7:	mov    rax,QWORD PTR [rdi+0x10]
    1bfb:	mov    rcx,QWORD PTR [rax]
    1bfe:	xor    rdx,rdx
    1c01:	call   1c06 <botlish_fn_19+0x14e>
			1c02: R_X86_64_PLT32	rt_type_error-0x4
    1c06:	jmp    1d97 <botlish_fn_19+0x2df>
    1c0b:	test   rsi,0x1
    1c12:	je     1c2a <botlish_fn_19+0x172>
    1c18:	mov    rcx,rsi
    1c1b:	add    rcx,0x2
    1c1f:	seto   al
    1c22:	test   al,al
    1c24:	je     1c3a <botlish_fn_19+0x182>
    1c2a:	mov    edx,0x3
    1c2f:	mov    rdi,r12
    1c32:	call   1c37 <botlish_fn_19+0x17f>
			1c33: R_X86_64_PLT32	rt_int_add-0x4
    1c37:	mov    rcx,rax
    1c3a:	mov    edx,0x1
    1c3f:	mov    rsi,r14
    1c42:	mov    rdi,r12
    1c45:	call   1c4a <botlish_fn_19+0x192>
			1c46: R_X86_64_PLT32	rt_mutarray_set-0x4
    1c4a:	test   rax,rax
    1c4d:	je     1d97 <botlish_fn_19+0x2df>
    1c53:	mov    rax,r13
    1c56:	test   rax,0x1
    1c5c:	jne    1c87 <botlish_fn_19+0x1cf>
    1c62:	mov    edx,0x5
    1c67:	mov    rsi,r13
    1c6a:	mov    rdi,r12
    1c6d:	call   1c72 <botlish_fn_19+0x1ba>
			1c6e: R_X86_64_PLT32	rt_int_cmp-0x4
    1c72:	mov    ecx,0x2
    1c77:	test   rax,rax
    1c7a:	cmove  rcx,QWORD PTR [rip+0x166]        # 1de8 <botlish_fn_19+0x330>
    1c82:	jmp    1c9b <botlish_fn_19+0x1e3>
    1c87:	mov    rsi,r13
    1c8a:	mov    ecx,0x2
    1c8f:	cmp    rsi,0x5
    1c93:	cmove  rcx,QWORD PTR [rip+0x14d]        # 1de8 <botlish_fn_19+0x330>
    1c9b:	cmp    rcx,0x6
    1c9f:	je     1cad <botlish_fn_19+0x1f5>
    1ca5:	mov    rax,rbx
    1ca8:	jmp    1dbf <botlish_fn_19+0x307>
    1cad:	mov    rax,QWORD PTR [rbx+0x18]
    1cb1:	mov    rsi,QWORD PTR [rax+0x18]
    1cb5:	mov    QWORD PTR [rsp+0x8],rsi
    1cba:	mov    r14,rsi
    1cbd:	mov    QWORD PTR [rsp+0x10],0x3
    1cc6:	mov    rsi,rbx
    1cc9:	mov    rdi,r12
    1ccc:	call   1cd1 <botlish_fn_19+0x219>
			1ccd: R_X86_64_PLT32	botlish_fn_5-0x4 ; ht_tombstones<HashTable>
    1cd1:	mov    r13,rbx
    1cd4:	test   rax,rax
    1cd7:	je     1d97 <botlish_fn_19+0x2df>
    1cdd:	mov    QWORD PTR [rsp+0x18],rax
    1ce2:	mov    QWORD PTR [rsp+0x20],0x3
    1ceb:	mov    ecx,0x1
    1cf0:	test   rax,0x1
    1cf6:	je     1d04 <botlish_fn_19+0x24c>
    1cfc:	mov    rsi,rax
    1cff:	jmp    1d28 <botlish_fn_19+0x270>
    1d04:	xor    ecx,ecx
    1d06:	test   rax,0x7
    1d0c:	je     1d1a <botlish_fn_19+0x262>
    1d12:	mov    rsi,rax
    1d15:	jmp    1d28 <botlish_fn_19+0x270>
    1d1a:	movzx  r10,BYTE PTR [rax]
    1d1e:	mov    rsi,rax
    1d21:	cmp    r10b,0x1
    1d25:	sete   cl
    1d28:	test   cl,cl
    1d2a:	jne    1d48 <botlish_fn_19+0x290>
    1d30:	mov    rdi,r12
    1d33:	mov    rax,QWORD PTR [rdi+0x10]
    1d37:	mov    rcx,QWORD PTR [rax+0x10]
    1d3b:	xor    rdx,rdx
    1d3e:	call   1d43 <botlish_fn_19+0x28b>
			1d3f: R_X86_64_PLT32	rt_type_error-0x4
    1d43:	jmp    1d97 <botlish_fn_19+0x2df>
    1d48:	test   rsi,0x1
    1d4f:	je     1d6e <botlish_fn_19+0x2b6>
    1d55:	mov    rcx,rsi
    1d58:	sub    rcx,0x3
    1d5c:	seto   al
    1d5f:	add    rcx,0x1
    1d66:	test   al,al
    1d68:	je     1d7e <botlish_fn_19+0x2c6>
    1d6e:	mov    edx,0x3
    1d73:	mov    rdi,r12
    1d76:	call   1d7b <botlish_fn_19+0x2c3>
			1d77: R_X86_64_PLT32	rt_int_sub-0x4
    1d7b:	mov    rcx,rax
    1d7e:	mov    edx,0x3
    1d83:	mov    rsi,r14
    1d86:	mov    rdi,r12
    1d89:	call   1d8e <botlish_fn_19+0x2d6>
			1d8a: R_X86_64_PLT32	rt_mutarray_set-0x4
    1d8e:	test   rax,rax
    1d91:	jne    1dbc <botlish_fn_19+0x304>
    1d97:	xor    rax,rax
    1d9a:	mov    rbx,QWORD PTR [rsp+0x40]
    1d9f:	mov    r12,QWORD PTR [rsp+0x48]
    1da4:	mov    r13,QWORD PTR [rsp+0x50]
    1da9:	mov    r14,QWORD PTR [rsp+0x58]
    1dae:	mov    r15,QWORD PTR [rsp+0x60]
    1db3:	add    rsp,0x70
    1db7:	mov    rsp,rbp
    1dba:	pop    rbp
    1dbb:	ret
    1dbc:	mov    rax,r13
    1dbf:	mov    rbx,QWORD PTR [rsp+0x40]
    1dc4:	mov    r12,QWORD PTR [rsp+0x48]
    1dc9:	mov    r13,QWORD PTR [rsp+0x50]
    1dce:	mov    r14,QWORD PTR [rsp+0x58]
    1dd3:	mov    r15,QWORD PTR [rsp+0x60]
    1dd8:	add    rsp,0x70
    1ddc:	mov    rsp,rbp
    1ddf:	pop    rbp
    1de0:	ret
    1de1:	add    BYTE PTR [rax],al
    1de3:	add    BYTE PTR [rax],al
    1de5:	add    BYTE PTR [rax],al
    1de7:	add    BYTE PTR [rsi],al
    1de9:	add    BYTE PTR [rax],al
    1deb:	add    BYTE PTR [rax],al
    1ded:	add    BYTE PTR [rax],al
	...

0000000000001df0 <botlish_entry_19: ht_place<HashTable, int, str, str>>:
    1df0:	push   rbp
    1df1:	mov    rbp,rsp
    1df4:	mov    rsi,QWORD PTR [rdx]
    1df7:	mov    r9,QWORD PTR [rdx+0x8]
    1dfb:	mov    rcx,QWORD PTR [rdx+0x10]
    1dff:	mov    r8,QWORD PTR [rdx+0x18]
    1e03:	mov    rdx,r9
    1e06:	call   1e0b <botlish_entry_19+0x1b>
			1e07: R_X86_64_PLT32	botlish_fn_19-0x4 ; ht_place<HashTable, int, str, str>
    1e0b:	mov    rsp,rbp
    1e0e:	pop    rbp
    1e0f:	ret

0000000000001e10 <botlish_fn_20: ht_set<HashTable, str, str>>:
    1e10:	push   rbp
    1e11:	mov    rbp,rsp
    1e14:	sub    rsp,0x60
    1e18:	mov    QWORD PTR [rsp+0x30],rbx
    1e1d:	mov    QWORD PTR [rsp+0x38],r12
    1e22:	mov    QWORD PTR [rsp+0x40],r13
    1e27:	mov    QWORD PTR [rsp+0x48],r14
    1e2c:	mov    QWORD PTR [rsp+0x50],r15
    1e31:	mov    r12,rdi
    1e34:	mov    QWORD PTR [rsp+0x18],0x0
    1e3d:	mov    QWORD PTR [rsp+0x20],0x0
    1e46:	mov    QWORD PTR [rsp],rsi
    1e4a:	mov    r14,rsi
    1e4d:	mov    QWORD PTR [rsp+0x8],rdx
    1e52:	mov    r13,rdx
    1e55:	mov    QWORD PTR [rsp+0x10],rcx
    1e5a:	mov    rbx,rcx
    1e5d:	mov    rdx,r13
    1e60:	mov    rsi,r14
    1e63:	mov    rdi,r12
    1e66:	call   1e6b <botlish_fn_20+0x5b>
			1e67: R_X86_64_PLT32	botlish_fn_7-0x4 ; ht_probe_start<HashTable, str>
    1e6b:	test   rax,rax
    1e6e:	je     2046 <botlish_fn_20+0x236>
    1e74:	mov    QWORD PTR [rsp+0x18],rax
    1e79:	mov    rcx,rax
    1e7c:	mov    r8,0xffffffffffffffff
    1e83:	mov    r15,r8
    1e86:	mov    QWORD PTR [rsp+0x20],0xffffffffffffffff
    1e8f:	mov    rdx,r13
    1e92:	mov    rsi,r14
    1e95:	mov    rdi,r12
    1e98:	call   1e9d <botlish_fn_20+0x8d>
			1e99: R_X86_64_PLT32	botlish_fn_10-0x4 ; ht_find_insert<HashTable, str, int, int>
    1e9d:	test   rax,rax
    1ea0:	je     2046 <botlish_fn_20+0x236>
    1ea6:	mov    QWORD PTR [rsp+0x18],rax
    1eab:	mov    rsi,r14
    1eae:	mov    QWORD PTR [rsp+0x28],rax
    1eb3:	mov    rax,QWORD PTR [rsi+0x18]
    1eb7:	mov    rsi,QWORD PTR [rax]
    1eba:	mov    rdx,QWORD PTR [rsp+0x28]
    1ebf:	mov    rdi,r12
    1ec2:	call   1ec7 <botlish_fn_20+0xb7>
			1ec3: R_X86_64_PLT32	rt_mutarray_get-0x4
    1ec7:	test   rax,rax
    1eca:	je     2046 <botlish_fn_20+0x236>
    1ed0:	test   rax,0x1
    1ed6:	mov    rsi,rax
    1ed9:	jne    1f01 <botlish_fn_20+0xf1>
    1edf:	mov    edx,0x3
    1ee4:	mov    rdi,r12
    1ee7:	call   1eec <botlish_fn_20+0xdc>
			1ee8: R_X86_64_PLT32	rt_int_cmp-0x4
    1eec:	mov    ecx,0x2
    1ef1:	test   rax,rax
    1ef4:	cmove  rcx,QWORD PTR [rip+0x194]        # 2090 <botlish_fn_20+0x280>
    1efc:	jmp    1f12 <botlish_fn_20+0x102>
    1f01:	mov    ecx,0x2
    1f06:	cmp    rsi,0x3
    1f0a:	cmove  rcx,QWORD PTR [rip+0x17e]        # 2090 <botlish_fn_20+0x280>
    1f12:	cmp    rcx,0x6
    1f16:	je     2022 <botlish_fn_20+0x212>
    1f1c:	mov    rsi,r14
    1f1f:	mov    rdi,r12
    1f22:	call   1f27 <botlish_fn_20+0x117>
			1f23: R_X86_64_PLT32	botlish_fn_17-0x4 ; ht_should_grow<HashTable>
    1f27:	test   rax,rax
    1f2a:	je     2046 <botlish_fn_20+0x236>
    1f30:	cmp    rax,0x6
    1f34:	je     1f7b <botlish_fn_20+0x16b>
    1f3a:	mov    rcx,r13
    1f3d:	mov    rdx,QWORD PTR [rsp+0x28]
    1f42:	mov    rsi,r14
    1f45:	mov    rdi,r12
    1f48:	mov    r8,rbx
    1f4b:	call   1f50 <botlish_fn_20+0x140>
			1f4c: R_X86_64_PLT32	botlish_fn_19-0x4 ; ht_place<HashTable, int, str, str>
    1f50:	test   rax,rax
    1f53:	je     2046 <botlish_fn_20+0x236>
    1f59:	mov    rbx,QWORD PTR [rsp+0x30]
    1f5e:	mov    r12,QWORD PTR [rsp+0x38]
    1f63:	mov    r13,QWORD PTR [rsp+0x40]
    1f68:	mov    r14,QWORD PTR [rsp+0x48]
    1f6d:	mov    r15,QWORD PTR [rsp+0x50]
    1f72:	add    rsp,0x60
    1f76:	mov    rsp,rbp
    1f79:	pop    rbp
    1f7a:	ret
    1f7b:	mov    rsi,r14
    1f7e:	mov    rdi,r12
    1f81:	call   1f86 <botlish_fn_20+0x176>
			1f82: R_X86_64_PLT32	botlish_fn_18-0x4 ; ht_grow_or_clean<HashTable>
    1f86:	mov    rcx,rax
    1f89:	mov    r14,rax
    1f8c:	test   rax,rcx
    1f8f:	je     2046 <botlish_fn_20+0x236>
    1f95:	mov    rax,r14
    1f98:	mov    QWORD PTR [rsp],rax
    1f9c:	mov    rdx,r13
    1f9f:	mov    rsi,r14
    1fa2:	mov    rdi,r12
    1fa5:	call   1faa <botlish_fn_20+0x19a>
			1fa6: R_X86_64_PLT32	botlish_fn_7-0x4 ; ht_probe_start<HashTable, str>
    1faa:	test   rax,rax
    1fad:	je     2046 <botlish_fn_20+0x236>
    1fb3:	mov    QWORD PTR [rsp+0x18],rax
    1fb8:	mov    rcx,rax
    1fbb:	mov    QWORD PTR [rsp+0x20],0xffffffffffffffff
    1fc4:	mov    r8,r15
    1fc7:	mov    rdx,r13
    1fca:	mov    rsi,r14
    1fcd:	mov    rdi,r12
    1fd0:	call   1fd5 <botlish_fn_20+0x1c5>
			1fd1: R_X86_64_PLT32	botlish_fn_10-0x4 ; ht_find_insert<HashTable, str, int, int>
    1fd5:	test   rax,rax
    1fd8:	je     2046 <botlish_fn_20+0x236>
    1fde:	mov    QWORD PTR [rsp+0x18],rax
    1fe3:	mov    rcx,r13
    1fe6:	mov    rdx,rax
    1fe9:	mov    rsi,r14
    1fec:	mov    rdi,r12
    1fef:	mov    r8,rbx
    1ff2:	call   1ff7 <botlish_fn_20+0x1e7>
			1ff3: R_X86_64_PLT32	botlish_fn_19-0x4 ; ht_place<HashTable, int, str, str>
    1ff7:	test   rax,rax
    1ffa:	je     2046 <botlish_fn_20+0x236>
    2000:	mov    rbx,QWORD PTR [rsp+0x30]
    2005:	mov    r12,QWORD PTR [rsp+0x38]
    200a:	mov    r13,QWORD PTR [rsp+0x40]
    200f:	mov    r14,QWORD PTR [rsp+0x48]
    2014:	mov    r15,QWORD PTR [rsp+0x50]
    2019:	add    rsp,0x60
    201d:	mov    rsp,rbp
    2020:	pop    rbp
    2021:	ret
    2022:	mov    rdx,QWORD PTR [rsp+0x28]
    2027:	mov    rsi,r14
    202a:	mov    rax,QWORD PTR [rsi+0x18]
    202e:	mov    rsi,QWORD PTR [rax+0x10]
    2032:	mov    rcx,rbx
    2035:	mov    rdi,r12
    2038:	call   203d <botlish_fn_20+0x22d>
			2039: R_X86_64_PLT32	rt_mutarray_set-0x4
    203d:	test   rax,rax
    2040:	jne    206b <botlish_fn_20+0x25b>
    2046:	xor    rax,rax
    2049:	mov    rbx,QWORD PTR [rsp+0x30]
    204e:	mov    r12,QWORD PTR [rsp+0x38]
    2053:	mov    r13,QWORD PTR [rsp+0x40]
    2058:	mov    r14,QWORD PTR [rsp+0x48]
    205d:	mov    r15,QWORD PTR [rsp+0x50]
    2062:	add    rsp,0x60
    2066:	mov    rsp,rbp
    2069:	pop    rbp
    206a:	ret
    206b:	mov    rax,r14
    206e:	mov    rbx,QWORD PTR [rsp+0x30]
    2073:	mov    r12,QWORD PTR [rsp+0x38]
    2078:	mov    r13,QWORD PTR [rsp+0x40]
    207d:	mov    r14,QWORD PTR [rsp+0x48]
    2082:	mov    r15,QWORD PTR [rsp+0x50]
    2087:	add    rsp,0x60
    208b:	mov    rsp,rbp
    208e:	pop    rbp
    208f:	ret
    2090:	(bad)
    2091:	add    BYTE PTR [rax],al
    2093:	add    BYTE PTR [rax],al
    2095:	add    BYTE PTR [rax],al
	...

0000000000002098 <botlish_entry_20: ht_set<HashTable, str, str>>:
    2098:	push   rbp
    2099:	mov    rbp,rsp
    209c:	mov    rsi,QWORD PTR [rdx]
    209f:	mov    r8,QWORD PTR [rdx+0x8]
    20a3:	mov    rcx,QWORD PTR [rdx+0x10]
    20a7:	mov    rdx,r8
    20aa:	call   20af <botlish_entry_20+0x17>
			20ab: R_X86_64_PLT32	botlish_fn_20-0x4 ; ht_set<HashTable, str, str>
    20af:	mov    rsp,rbp
    20b2:	pop    rbp
    20b3:	ret
    20b4:	add    BYTE PTR [rax],al
	...

00000000000020b8 <botlish_fn_21: ht_delete<HashTable, str>>:
    20b8:	push   rbp
    20b9:	mov    rbp,rsp
    20bc:	sub    rsp,0x50
    20c0:	mov    QWORD PTR [rsp+0x30],rbx
    20c5:	mov    QWORD PTR [rsp+0x38],r12
    20ca:	mov    QWORD PTR [rsp+0x40],r13
    20cf:	mov    QWORD PTR [rsp+0x48],r14
    20d4:	mov    r13,rdi
    20d7:	mov    QWORD PTR [rsp+0x10],0x0
    20e0:	mov    QWORD PTR [rsp+0x18],0x0
    20e9:	mov    QWORD PTR [rsp+0x20],0x0
    20f2:	mov    QWORD PTR [rsp],rsi
    20f6:	mov    r12,rsi
    20f9:	mov    QWORD PTR [rsp+0x8],rdx
    20fe:	mov    r14,rdx
    2101:	mov    rbx,r12
    2104:	mov    rdx,r14
    2107:	mov    rsi,rbx
    210a:	mov    rdi,r13
    210d:	call   2112 <botlish_fn_21+0x5a>
			210e: R_X86_64_PLT32	botlish_fn_7-0x4 ; ht_probe_start<HashTable, str>
    2112:	test   rax,rax
    2115:	je     23c9 <botlish_fn_21+0x311>
    211b:	mov    QWORD PTR [rsp+0x10],rax
    2120:	mov    rcx,rax
    2123:	mov    rdx,r14
    2126:	mov    rsi,rbx
    2129:	mov    rdi,r13
    212c:	call   2131 <botlish_fn_21+0x79>
			212d: R_X86_64_PLT32	botlish_fn_9-0x4 ; ht_find_get<HashTable, str, int>
    2131:	mov    rcx,rax
    2134:	mov    r12,rax
    2137:	test   rax,rcx
    213a:	je     23c9 <botlish_fn_21+0x311>
    2140:	mov    rax,r12
    2143:	test   rax,0x1
    2149:	jne    2174 <botlish_fn_21+0xbc>
    214f:	mov    edx,0x1
    2154:	mov    rsi,r12
    2157:	mov    rdi,r13
    215a:	call   215f <botlish_fn_21+0xa7>
			215b: R_X86_64_PLT32	rt_int_cmp-0x4
    215f:	mov    ecx,0x2
    2164:	test   rax,rax
    2167:	cmovge rcx,QWORD PTR [rip+0x2a1]        # 2410 <botlish_fn_21+0x358>
    216f:	jmp    2184 <botlish_fn_21+0xcc>
    2174:	mov    ecx,0x2
    2179:	test   r12,r12
    217c:	cmovg  rcx,QWORD PTR [rip+0x28c]        # 2410 <botlish_fn_21+0x358>
    2184:	cmp    rcx,0x6
    2188:	je     2196 <botlish_fn_21+0xde>
    218e:	mov    rax,rbx
    2191:	jmp    23ec <botlish_fn_21+0x334>
    2196:	mov    rcx,QWORD PTR [rbx+0x18]
    219a:	mov    rsi,QWORD PTR [rcx]
    219d:	mov    ecx,0x5
    21a2:	mov    rdx,r12
    21a5:	mov    rdi,r13
    21a8:	call   21ad <botlish_fn_21+0xf5>
			21a9: R_X86_64_PLT32	rt_mutarray_set-0x4
    21ad:	test   rax,rax
    21b0:	je     23c9 <botlish_fn_21+0x311>
    21b6:	mov    rax,QWORD PTR [rbx+0x18]
    21ba:	mov    rsi,QWORD PTR [rax+0x8]
    21be:	mov    ecx,0xa
    21c3:	mov    rdx,r12
    21c6:	mov    rdi,r13
    21c9:	call   21ce <botlish_fn_21+0x116>
			21ca: R_X86_64_PLT32	rt_mutarray_set-0x4
    21ce:	test   rax,rax
    21d1:	je     23c9 <botlish_fn_21+0x311>
    21d7:	mov    rax,QWORD PTR [rbx+0x18]
    21db:	mov    rsi,QWORD PTR [rax+0x10]
    21df:	mov    ecx,0xa
    21e4:	mov    rdx,r12
    21e7:	mov    rdi,r13
    21ea:	call   21ef <botlish_fn_21+0x137>
			21eb: R_X86_64_PLT32	rt_mutarray_set-0x4
    21ef:	test   rax,rax
    21f2:	je     23c9 <botlish_fn_21+0x311>
    21f8:	mov    rax,QWORD PTR [rbx+0x18]
    21fc:	mov    rsi,QWORD PTR [rax+0x18]
    2200:	mov    QWORD PTR [rsp+0x8],rsi
    2205:	mov    r12,rsi
    2208:	mov    QWORD PTR [rsp+0x10],0x1
    2211:	mov    rsi,rbx
    2214:	mov    rdi,r13
    2217:	call   221c <botlish_fn_21+0x164>
			2218: R_X86_64_PLT32	botlish_fn_4-0x4 ; ht_size<HashTable>
    221c:	test   rax,rax
    221f:	je     23c9 <botlish_fn_21+0x311>
    2225:	mov    QWORD PTR [rsp+0x18],rax
    222a:	mov    QWORD PTR [rsp+0x20],0x3
    2233:	mov    esi,0x1
    2238:	test   rax,0x1
    223e:	je     224c <botlish_fn_21+0x194>
    2244:	mov    r8,rax
    2247:	jmp    2271 <botlish_fn_21+0x1b9>
    224c:	xor    esi,esi
    224e:	test   rax,0x7
    2254:	je     2262 <botlish_fn_21+0x1aa>
    225a:	mov    r8,rax
    225d:	jmp    2271 <botlish_fn_21+0x1b9>
    2262:	movzx  rcx,BYTE PTR [rax]
    2266:	mov    r8,rax
    2269:	rex cmp cl,0x1
    226d:	sete   sil
    2271:	test   sil,sil
    2274:	jne    2295 <botlish_fn_21+0x1dd>
    227a:	mov    rdi,r13
    227d:	mov    rax,QWORD PTR [rdi+0x10]
    2281:	mov    rcx,QWORD PTR [rax+0x10]
    2285:	xor    rdx,rdx
    2288:	mov    rsi,r8
    228b:	call   2290 <botlish_fn_21+0x1d8>
			228c: R_X86_64_PLT32	rt_type_error-0x4
    2290:	jmp    23c9 <botlish_fn_21+0x311>
    2295:	mov    rsi,r8
    2298:	test   rsi,0x1
    229f:	je     22be <botlish_fn_21+0x206>
    22a5:	mov    rcx,rsi
    22a8:	sub    rcx,0x3
    22ac:	seto   al
    22af:	add    rcx,0x1
    22b6:	test   al,al
    22b8:	je     22ce <botlish_fn_21+0x216>
    22be:	mov    edx,0x3
    22c3:	mov    rdi,r13
    22c6:	call   22cb <botlish_fn_21+0x213>
			22c7: R_X86_64_PLT32	rt_int_sub-0x4
    22cb:	mov    rcx,rax
    22ce:	mov    edx,0x1
    22d3:	mov    rsi,r12
    22d6:	mov    rdi,r13
    22d9:	call   22de <botlish_fn_21+0x226>
			22da: R_X86_64_PLT32	rt_mutarray_set-0x4
    22de:	test   rax,rax
    22e1:	je     23c9 <botlish_fn_21+0x311>
    22e7:	mov    rsi,QWORD PTR [rbx+0x18]
    22eb:	mov    rsi,QWORD PTR [rsi+0x18]
    22ef:	mov    QWORD PTR [rsp+0x8],rsi
    22f4:	mov    r14,rsi
    22f7:	mov    QWORD PTR [rsp+0x10],0x3
    2300:	mov    rsi,rbx
    2303:	mov    rdi,r13
    2306:	call   230b <botlish_fn_21+0x253>
			2307: R_X86_64_PLT32	botlish_fn_5-0x4 ; ht_tombstones<HashTable>
    230b:	mov    r12,rbx
    230e:	test   rax,rax
    2311:	je     23c9 <botlish_fn_21+0x311>
    2317:	mov    QWORD PTR [rsp+0x18],rax
    231c:	mov    QWORD PTR [rsp+0x20],0x3
    2325:	mov    ecx,0x1
    232a:	test   rax,0x1
    2330:	je     233e <botlish_fn_21+0x286>
    2336:	mov    rsi,rax
    2339:	jmp    2362 <botlish_fn_21+0x2aa>
    233e:	xor    ecx,ecx
    2340:	test   rax,0x7
    2346:	je     2354 <botlish_fn_21+0x29c>
    234c:	mov    rsi,rax
    234f:	jmp    2362 <botlish_fn_21+0x2aa>
    2354:	movzx  rcx,BYTE PTR [rax]
    2358:	mov    rsi,rax
    235b:	rex cmp cl,0x1
    235f:	sete   cl
    2362:	test   cl,cl
    2364:	jne    2381 <botlish_fn_21+0x2c9>
    236a:	mov    rdi,r13
    236d:	mov    rax,QWORD PTR [rdi+0x10]
    2371:	mov    rcx,QWORD PTR [rax]
    2374:	xor    rdx,rdx
    2377:	call   237c <botlish_fn_21+0x2c4>
			2378: R_X86_64_PLT32	rt_type_error-0x4
    237c:	jmp    23c9 <botlish_fn_21+0x311>
    2381:	test   rsi,0x1
    2388:	je     23a0 <botlish_fn_21+0x2e8>
    238e:	mov    rcx,rsi
    2391:	add    rcx,0x2
    2395:	seto   al
    2398:	test   al,al
    239a:	je     23b0 <botlish_fn_21+0x2f8>
    23a0:	mov    edx,0x3
    23a5:	mov    rdi,r13
    23a8:	call   23ad <botlish_fn_21+0x2f5>
			23a9: R_X86_64_PLT32	rt_int_add-0x4
    23ad:	mov    rcx,rax
    23b0:	mov    edx,0x3
    23b5:	mov    rsi,r14
    23b8:	mov    rdi,r13
    23bb:	call   23c0 <botlish_fn_21+0x308>
			23bc: R_X86_64_PLT32	rt_mutarray_set-0x4
    23c0:	test   rax,rax
    23c3:	jne    23e9 <botlish_fn_21+0x331>
    23c9:	xor    rax,rax
    23cc:	mov    rbx,QWORD PTR [rsp+0x30]
    23d1:	mov    r12,QWORD PTR [rsp+0x38]
    23d6:	mov    r13,QWORD PTR [rsp+0x40]
    23db:	mov    r14,QWORD PTR [rsp+0x48]
    23e0:	add    rsp,0x50
    23e4:	mov    rsp,rbp
    23e7:	pop    rbp
    23e8:	ret
    23e9:	mov    rax,r12
    23ec:	mov    rbx,QWORD PTR [rsp+0x30]
    23f1:	mov    r12,QWORD PTR [rsp+0x38]
    23f6:	mov    r13,QWORD PTR [rsp+0x40]
    23fb:	mov    r14,QWORD PTR [rsp+0x48]
    2400:	add    rsp,0x50
    2404:	mov    rsp,rbp
    2407:	pop    rbp
    2408:	ret
    2409:	add    BYTE PTR [rax],al
    240b:	add    BYTE PTR [rax],al
    240d:	add    BYTE PTR [rax],al
    240f:	add    BYTE PTR [rsi],al
    2411:	add    BYTE PTR [rax],al
    2413:	add    BYTE PTR [rax],al
    2415:	add    BYTE PTR [rax],al
	...

0000000000002418 <botlish_entry_21: ht_delete<HashTable, str>>:
    2418:	push   rbp
    2419:	mov    rbp,rsp
    241c:	mov    rsi,QWORD PTR [rdx]
    241f:	mov    rdx,QWORD PTR [rdx+0x8]
    2423:	call   2428 <botlish_entry_21+0x10>
			2424: R_X86_64_PLT32	botlish_fn_21-0x4 ; ht_delete<HashTable, str>
    2428:	mov    rsp,rbp
    242b:	pop    rbp
    242c:	ret
    242d:	add    BYTE PTR [rax],al
	...

0000000000002430 <botlish_fn_22: sample_checks<generic>>:
    2430:	push   rbp
    2431:	mov    rbp,rsp
    2434:	sub    rsp,0xa0
    243b:	mov    QWORD PTR [rsp+0x70],rbx
    2440:	mov    QWORD PTR [rsp+0x78],r12
    2445:	mov    QWORD PTR [rsp+0x80],r13
    244d:	mov    QWORD PTR [rsp+0x88],r14
    2455:	mov    QWORD PTR [rsp+0x90],r15
    245d:	mov    r13,rdi
    2460:	mov    QWORD PTR [rsp],0x0
    2468:	mov    QWORD PTR [rsp+0x8],0x0
    2471:	mov    QWORD PTR [rsp+0x10],0x0
    247a:	mov    QWORD PTR [rsp+0x18],0x0
    2483:	mov    QWORD PTR [rsp+0x20],0x0
    248c:	mov    QWORD PTR [rsp+0x28],0x0
    2495:	mov    rdi,r13
    2498:	call   249d <botlish_fn_22+0x6d>
			2499: R_X86_64_PLT32	botlish_fn_3-0x4 ; ht_new<generic>
    249d:	test   rax,rax
    24a0:	je     26fc <botlish_fn_22+0x2cc>
    24a6:	mov    QWORD PTR [rsp],rax
    24aa:	mov    rsi,rax
    24ad:	mov    rdi,r13
    24b0:	mov    rax,QWORD PTR [rdi+0x10]
    24b4:	mov    rdx,QWORD PTR [rax+0x18]
    24b8:	mov    QWORD PTR [rsp+0x8],rdx
    24bd:	mov    rax,QWORD PTR [rdi+0x10]
    24c1:	mov    rcx,QWORD PTR [rax+0x20]
    24c5:	mov    QWORD PTR [rsp+0x10],rcx
    24ca:	call   24cf <botlish_fn_22+0x9f>
			24cb: R_X86_64_PLT32	botlish_fn_20-0x4 ; ht_set<HashTable, str, str>
    24cf:	test   rax,rax
    24d2:	je     26fc <botlish_fn_22+0x2cc>
    24d8:	mov    QWORD PTR [rsp],rax
    24dc:	mov    rdi,r13
    24df:	mov    rsi,QWORD PTR [rdi+0x10]
    24e3:	mov    rdx,QWORD PTR [rsi+0x28]
    24e7:	mov    QWORD PTR [rsp+0x8],rdx
    24ec:	mov    rsi,QWORD PTR [rdi+0x10]
    24f0:	mov    rcx,QWORD PTR [rsi+0x30]
    24f4:	mov    QWORD PTR [rsp+0x10],rcx
    24f9:	mov    rsi,rax
    24fc:	call   2501 <botlish_fn_22+0xd1>
			24fd: R_X86_64_PLT32	botlish_fn_20-0x4 ; ht_set<HashTable, str, str>
    2501:	test   rax,rax
    2504:	je     26fc <botlish_fn_22+0x2cc>
    250a:	mov    QWORD PTR [rsp],rax
    250e:	mov    rsi,rax
    2511:	mov    rdi,r13
    2514:	mov    r11,QWORD PTR [rdi+0x10]
    2518:	mov    rdx,QWORD PTR [r11+0x18]
    251c:	mov    QWORD PTR [rsp+0x8],rdx
    2521:	mov    rax,QWORD PTR [rdi+0x10]
    2525:	mov    rcx,QWORD PTR [rax+0x38]
    2529:	mov    QWORD PTR [rsp+0x10],rcx
    252e:	call   2533 <botlish_fn_22+0x103>
			252f: R_X86_64_PLT32	botlish_fn_20-0x4 ; ht_set<HashTable, str, str>
    2533:	test   rax,rax
    2536:	je     26fc <botlish_fn_22+0x2cc>
    253c:	mov    QWORD PTR [rsp],rax
    2540:	mov    rdi,r13
    2543:	mov    r14,rax
    2546:	mov    rax,QWORD PTR [rdi+0x10]
    254a:	mov    rdx,QWORD PTR [rax+0x28]
    254e:	mov    QWORD PTR [rsp+0x8],rdx
    2553:	mov    rsi,r14
    2556:	call   255b <botlish_fn_22+0x12b>
			2557: R_X86_64_PLT32	botlish_fn_12-0x4 ; ht_contains<HashTable, str>
    255b:	test   rax,rax
    255e:	je     26fc <botlish_fn_22+0x2cc>
    2564:	mov    QWORD PTR [rsp+0x8],rax
    2569:	mov    rdi,r13
    256c:	mov    r15,rax
    256f:	mov    rax,QWORD PTR [rdi+0x10]
    2573:	mov    rdx,QWORD PTR [rax+0x28]
    2577:	mov    QWORD PTR [rsp+0x10],rdx
    257c:	mov    rsi,r14
    257f:	call   2584 <botlish_fn_22+0x154>
			2580: R_X86_64_PLT32	botlish_fn_21-0x4 ; ht_delete<HashTable, str>
    2584:	mov    rcx,rax
    2587:	mov    r14,rax
    258a:	test   rax,rcx
    258d:	je     26fc <botlish_fn_22+0x2cc>
    2593:	mov    rax,r14
    2596:	mov    QWORD PTR [rsp],rax
    259a:	mov    rdi,r13
    259d:	mov    rax,QWORD PTR [rdi+0x10]
    25a1:	mov    rdx,QWORD PTR [rax+0x18]
    25a5:	mov    QWORD PTR [rsp+0x10],rdx
    25aa:	mov    rsi,r14
    25ad:	call   25b2 <botlish_fn_22+0x182>
			25ae: R_X86_64_PLT32	botlish_fn_11-0x4 ; ht_get<HashTable, str>
    25b2:	test   rax,rax
    25b5:	je     26fc <botlish_fn_22+0x2cc>
    25bb:	mov    rdi,r13
    25be:	mov    rcx,QWORD PTR [rdi+0x10]
    25c2:	mov    rdx,QWORD PTR [rcx+0x38]
    25c6:	mov    rcx,rax
    25c9:	and    rcx,rdx
    25cc:	mov    rsi,rax
    25cf:	test   rcx,0x1
    25d6:	jne    25f2 <botlish_fn_22+0x1c2>
    25dc:	mov    rdi,r13
    25df:	call   25e4 <botlish_fn_22+0x1b4>
			25e0: R_X86_64_PLT32	rt_value_eq-0x4
    25e4:	test   rax,rax
    25e7:	je     26fc <botlish_fn_22+0x2cc>
    25ed:	jmp    2602 <botlish_fn_22+0x1d2>
    25f2:	mov    eax,0x2
    25f7:	cmp    rsi,rdx
    25fa:	cmove  rax,QWORD PTR [rip+0x15e]        # 2760 <botlish_fn_22+0x330>
    2602:	mov    QWORD PTR [rsp+0x10],rax
    2607:	mov    rdi,r13
    260a:	mov    QWORD PTR [rsp+0x60],rax
    260f:	mov    rax,QWORD PTR [rdi+0x10]
    2613:	mov    rdx,QWORD PTR [rax+0x28]
    2617:	mov    QWORD PTR [rsp+0x18],rdx
    261c:	mov    rsi,r14
    261f:	call   2624 <botlish_fn_22+0x1f4>
			2620: R_X86_64_PLT32	botlish_fn_12-0x4 ; ht_contains<HashTable, str>
    2624:	mov    rbx,rax
    2627:	test   rbx,rbx
    262a:	je     26fc <botlish_fn_22+0x2cc>
    2630:	mov    QWORD PTR [rsp+0x18],rbx
    2635:	mov    rdi,r13
    2638:	mov    rax,QWORD PTR [rdi+0x10]
    263c:	mov    rdx,QWORD PTR [rax+0x40]
    2640:	mov    QWORD PTR [rsp+0x20],rdx
    2645:	mov    rsi,r14
    2648:	call   264d <botlish_fn_22+0x21d>
			2649: R_X86_64_PLT32	botlish_fn_12-0x4 ; ht_contains<HashTable, str>
    264d:	mov    r12,rax
    2650:	test   r12,r12
    2653:	je     26fc <botlish_fn_22+0x2cc>
    2659:	mov    QWORD PTR [rsp+0x20],r12
    265e:	mov    rdi,r13
    2661:	mov    rax,QWORD PTR [rdi+0x10]
    2665:	mov    rdx,QWORD PTR [rax+0x40]
    2669:	mov    QWORD PTR [rsp+0x28],rdx
    266e:	mov    rsi,r14
    2671:	call   2676 <botlish_fn_22+0x246>
			2672: R_X86_64_PLT32	botlish_fn_11-0x4 ; ht_get<HashTable, str>
    2676:	test   rax,rax
    2679:	mov    rsi,rax
    267c:	je     26fc <botlish_fn_22+0x2cc>
    2682:	mov    edx,0xa
    2687:	mov    rdi,r13
    268a:	call   268f <botlish_fn_22+0x25f>
			268b: R_X86_64_PLT32	rt_value_eq-0x4
    268f:	test   rax,rax
    2692:	je     26fc <botlish_fn_22+0x2cc>
    2698:	mov    QWORD PTR [rsp],rax
    269c:	mov    rsi,r14
    269f:	mov    r14,rax
    26a2:	mov    rdi,r13
    26a5:	call   26aa <botlish_fn_22+0x27a>
			26a6: R_X86_64_PLT32	botlish_fn_4-0x4 ; ht_size<HashTable>
    26aa:	test   rax,rax
    26ad:	je     26fc <botlish_fn_22+0x2cc>
    26b3:	mov    QWORD PTR [rsp+0x28],rax
    26b8:	lea    rdx,[rsp+0x30]
    26bd:	mov    r9,QWORD PTR [rsp+0x60]
    26c2:	mov    QWORD PTR [rsp+0x30],r9
    26c7:	mov    rsi,r15
    26ca:	mov    QWORD PTR [rsp+0x38],rsi
    26cf:	mov    QWORD PTR [rsp+0x40],rbx
    26d4:	mov    QWORD PTR [rsp+0x48],r12
    26d9:	mov    rcx,r14
    26dc:	mov    QWORD PTR [rsp+0x50],rcx
    26e1:	mov    QWORD PTR [rsp+0x58],rax
    26e6:	mov    esi,0x6
    26eb:	mov    rdi,r13
    26ee:	call   26f3 <botlish_fn_22+0x2c3>
			26ef: R_X86_64_PLT32	rt_list_new-0x4
    26f3:	test   rax,rax
    26f6:	jne    272d <botlish_fn_22+0x2fd>
    26fc:	xor    rax,rax
    26ff:	mov    rbx,QWORD PTR [rsp+0x70]
    2704:	mov    r12,QWORD PTR [rsp+0x78]
    2709:	mov    r13,QWORD PTR [rsp+0x80]
    2711:	mov    r14,QWORD PTR [rsp+0x88]
    2719:	mov    r15,QWORD PTR [rsp+0x90]
    2721:	add    rsp,0xa0
    2728:	mov    rsp,rbp
    272b:	pop    rbp
    272c:	ret
    272d:	mov    rbx,QWORD PTR [rsp+0x70]
    2732:	mov    r12,QWORD PTR [rsp+0x78]
    2737:	mov    r13,QWORD PTR [rsp+0x80]
    273f:	mov    r14,QWORD PTR [rsp+0x88]
    2747:	mov    r15,QWORD PTR [rsp+0x90]
    274f:	add    rsp,0xa0
    2756:	mov    rsp,rbp
    2759:	pop    rbp
    275a:	ret
    275b:	add    BYTE PTR [rax],al
    275d:	add    BYTE PTR [rax],al
    275f:	add    BYTE PTR [rsi],al
    2761:	add    BYTE PTR [rax],al
    2763:	add    BYTE PTR [rax],al
    2765:	add    BYTE PTR [rax],al
	...

0000000000002768 <botlish_entry_22: sample_checks<generic>>:
    2768:	push   rbp
    2769:	mov    rbp,rsp
    276c:	call   2771 <botlish_entry_22+0x9>
			276d: R_X86_64_PLT32	botlish_fn_22-0x4 ; sample_checks<generic>
    2771:	mov    rsp,rbp
    2774:	pop    rbp
    2775:	ret

0000000000002776 <botlish_fn_23: sample<generic>>:
    2776:	push   rbp
    2777:	mov    rbp,rsp
    277a:	sub    rsp,0x10
    277e:	mov    QWORD PTR [rsp],r12
    2782:	mov    r12,rdi
    2785:	mov    rdi,r12
    2788:	call   278d <botlish_fn_23+0x17>
			2789: R_X86_64_PLT32	botlish_fn_22-0x4 ; sample_checks<generic>
    278d:	test   rax,rax
    2790:	jne    27d9 <botlish_fn_23+0x63>
    2796:	mov    rdi,r12
    2799:	call   279e <botlish_fn_23+0x28>
			279a: R_X86_64_PLT32	rt_declared_error-0x4
    279e:	cmp    rax,0x40000001
    27a4:	jne    27c9 <botlish_fn_23+0x53>
    27aa:	mov    rdi,r12
    27ad:	call   27b2 <botlish_fn_23+0x3c>
			27ae: R_X86_64_PLT32	rt_clear_declared_error-0x4
    27b2:	xor    rdx,rdx
    27b5:	mov    rdi,r12
    27b8:	mov    rsi,rdx
    27bb:	call   27c0 <botlish_fn_23+0x4a>
			27bc: R_X86_64_PLT32	rt_list_new-0x4
    27c0:	test   rax,rax
    27c3:	jne    27d9 <botlish_fn_23+0x63>
    27c9:	xor    rax,rax
    27cc:	mov    r12,QWORD PTR [rsp]
    27d0:	add    rsp,0x10
    27d4:	mov    rsp,rbp
    27d7:	pop    rbp
    27d8:	ret
    27d9:	mov    r12,QWORD PTR [rsp]
    27dd:	add    rsp,0x10
    27e1:	mov    rsp,rbp
    27e4:	pop    rbp
    27e5:	ret

00000000000027e6 <botlish_entry_23: sample<generic>>:
    27e6:	push   rbp
    27e7:	mov    rbp,rsp
    27ea:	call   27ef <botlish_entry_23+0x9>
			27eb: R_X86_64_PLT32	botlish_fn_23-0x4 ; sample<generic>
    27ef:	mov    rsp,rbp
    27f2:	pop    rbp
    27f3:	ret
