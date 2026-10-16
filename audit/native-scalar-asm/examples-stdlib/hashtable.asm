; source:  examples/stdlib/hashtable.bot
; backend: Cranelift (specialize=1), native::object
; object:  ELF64 x86-64, unlinked (Botlish-generated code only; runtime
;          helpers are unresolved imports, so their bodies are not present)
; format:  objdump -dr --no-show-raw-insn -M intel
; total machine code bytes: 10826  (per function: 45 427 385 70 69 69 46 182 178 628 1032 341 261 388 407 616 654 801 673 920 700 925 862 147)
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
     48d:	sub    rsp,0x20
     491:	mov    QWORD PTR [rsp+0x10],rbx
     496:	mov    QWORD PTR [rsp+0x18],r14
     49b:	mov    r14,rdi
     49e:	lea    r11,[rdx+0x1]
     4a2:	shl    r11,1
     4a5:	or     r11,0x1
     4a9:	mov    QWORD PTR [rsp],r11
     4ad:	mov    rbx,r11
     4b0:	mov    rdi,r14
     4b3:	call   4b8 <botlish_fn_8+0x2f>
			4b4: R_X86_64_PLT32	botlish_fn_6-0x4 ; ht_capacity<HashTable>
     4b8:	mov    QWORD PTR [rsp+0x8],rax
     4bd:	mov    rdx,rax
     4c0:	mov    rsi,rbx
     4c3:	mov    rdi,r14
     4c6:	call   4cb <botlish_fn_8+0x42>
			4c7: R_X86_64_PLT32	rt_int_mod-0x4
     4cb:	test   rax,rax
     4ce:	jne    4ed <botlish_fn_8+0x64>
     4d4:	xor    rdx,rdx
     4d7:	mov    rax,rdx
     4da:	mov    rbx,QWORD PTR [rsp+0x10]
     4df:	mov    r14,QWORD PTR [rsp+0x18]
     4e4:	add    rsp,0x20
     4e8:	mov    rsp,rbp
     4eb:	pop    rbp
     4ec:	ret
     4ed:	mov    edx,0x1
     4f2:	sar    rax,1
     4f5:	mov    rbx,QWORD PTR [rsp+0x10]
     4fa:	mov    r14,QWORD PTR [rsp+0x18]
     4ff:	add    rsp,0x20
     503:	mov    rsp,rbp
     506:	pop    rbp
     507:	ret

0000000000000508 <botlish_entry_8: ht_probe_next<HashTable, int>>:
     508:	push   rbp
     509:	mov    rbp,rsp
     50c:	mov    rsi,QWORD PTR [rdx]
     50f:	mov    rdx,QWORD PTR [rdx+0x8]
     513:	sar    rdx,1
     516:	call   51b <botlish_entry_8+0x13>
			517: R_X86_64_PLT32	botlish_fn_8-0x4 ; ht_probe_next<HashTable, int>
     51b:	shl    rax,1
     51e:	or     rax,0x1
     522:	mov    rcx,rax
     525:	xor    rax,rax
     528:	test   rdx,rdx
     52b:	cmovne rax,rcx
     52f:	mov    rsp,rbp
     532:	pop    rbp
     533:	ret
     534:	add    BYTE PTR [rax],al
	...

0000000000000538 <botlish_fn_9: ht_find_get<HashTable, str, int>>:
     538:	push   rbp
     539:	mov    rbp,rsp
     53c:	sub    rsp,0x50
     540:	mov    QWORD PTR [rsp+0x20],rbx
     545:	mov    QWORD PTR [rsp+0x28],r12
     54a:	mov    QWORD PTR [rsp+0x30],r13
     54f:	mov    QWORD PTR [rsp+0x38],r14
     554:	mov    QWORD PTR [rsp+0x40],r15
     559:	mov    r14,rdi
     55c:	mov    QWORD PTR [rsp],rsi
     560:	mov    QWORD PTR [rsp+0x8],rdx
     565:	mov    r13,rdx
     568:	sar    rcx,1
     56b:	mov    rdx,rcx
     56e:	mov    rbx,rsi
     571:	mov    rax,QWORD PTR [rbx+0x18]
     575:	mov    rsi,QWORD PTR [rax]
     578:	mov    r12,rdx
     57b:	shl    r12,1
     57e:	mov    r15,rdx
     581:	or     r12,0x1
     585:	mov    rdx,r12
     588:	mov    rdi,r14
     58b:	call   590 <botlish_fn_9+0x58>
			58c: R_X86_64_PLT32	rt_mutarray_get-0x4
     590:	mov    QWORD PTR [rsp+0x10],r12
     595:	mov    r12,rax
     598:	mov    rdx,rax
     59b:	test   rax,rdx
     59e:	je     6d4 <botlish_fn_9+0x19c>
     5a4:	mov    rax,r12
     5a7:	test   rax,0x1
     5ad:	jne    5db <botlish_fn_9+0xa3>
     5b3:	mov    edx,0x1
     5b8:	mov    rsi,r12
     5bb:	mov    rdi,r14
     5be:	call   5c3 <botlish_fn_9+0x8b>
			5bf: R_X86_64_PLT32	rt_int_cmp-0x4
     5c3:	mov    ecx,0x2
     5c8:	test   rax,rax
     5cb:	cmove  rcx,QWORD PTR [rip+0x18d]        # 760 <botlish_fn_9+0x228>
     5d3:	mov    rax,r12
     5d6:	jmp    5ef <botlish_fn_9+0xb7>
     5db:	mov    ecx,0x2
     5e0:	mov    rax,r12
     5e3:	cmp    rax,0x1
     5e7:	cmove  rcx,QWORD PTR [rip+0x171]        # 760 <botlish_fn_9+0x228>
     5ef:	cmp    rcx,0x6
     5f3:	je     734 <botlish_fn_9+0x1fc>
     5f9:	test   rax,0x1
     5ff:	mov    r12,rax
     602:	jne    62d <botlish_fn_9+0xf5>
     608:	mov    edx,0x3
     60d:	mov    rsi,r12
     610:	mov    rdi,r14
     613:	call   618 <botlish_fn_9+0xe0>
			614: R_X86_64_PLT32	rt_int_cmp-0x4
     618:	mov    ecx,0x2
     61d:	test   rax,rax
     620:	cmove  rcx,QWORD PTR [rip+0x138]        # 760 <botlish_fn_9+0x228>
     628:	jmp    641 <botlish_fn_9+0x109>
     62d:	mov    rsi,r12
     630:	mov    ecx,0x2
     635:	cmp    rsi,0x3
     639:	cmove  rcx,QWORD PTR [rip+0x11f]        # 760 <botlish_fn_9+0x228>
     641:	cmp    rcx,0x6
     645:	je     653 <botlish_fn_9+0x11b>
     64b:	mov    r12,r13
     64e:	jmp    6bd <botlish_fn_9+0x185>
     653:	mov    rax,QWORD PTR [rbx+0x18]
     657:	mov    rsi,QWORD PTR [rax+0x8]
     65b:	mov    rdx,QWORD PTR [rsp+0x10]
     660:	mov    rdi,r14
     663:	call   668 <botlish_fn_9+0x130>
			664: R_X86_64_PLT32	rt_mutarray_get-0x4
     668:	test   rax,rax
     66b:	je     6d4 <botlish_fn_9+0x19c>
     671:	mov    r12,r13
     674:	mov    rdx,rax
     677:	and    rdx,r12
     67a:	mov    rsi,rax
     67d:	test   rdx,0x1
     684:	jne    6a3 <botlish_fn_9+0x16b>
     68a:	mov    rdx,r12
     68d:	mov    rdi,r14
     690:	call   695 <botlish_fn_9+0x15d>
			691: R_X86_64_PLT32	rt_value_eq-0x4
     695:	test   rax,rax
     698:	je     6d4 <botlish_fn_9+0x19c>
     69e:	jmp    6b3 <botlish_fn_9+0x17b>
     6a3:	mov    eax,0x2
     6a8:	cmp    rsi,r12
     6ab:	cmove  rax,QWORD PTR [rip+0xad]        # 760 <botlish_fn_9+0x228>
     6b3:	cmp    rax,0x6
     6b7:	je     70d <botlish_fn_9+0x1d5>
     6bd:	mov    rdx,r15
     6c0:	mov    rsi,rbx
     6c3:	mov    rdi,r14
     6c6:	call   6cb <botlish_fn_9+0x193>
			6c7: R_X86_64_PLT32	botlish_fn_8-0x4 ; ht_probe_next<HashTable, int>
     6cb:	test   rdx,rdx
     6ce:	jne    6f9 <botlish_fn_9+0x1c1>
     6d4:	xor    rax,rax
     6d7:	mov    rbx,QWORD PTR [rsp+0x20]
     6dc:	mov    r12,QWORD PTR [rsp+0x28]
     6e1:	mov    r13,QWORD PTR [rsp+0x30]
     6e6:	mov    r14,QWORD PTR [rsp+0x38]
     6eb:	mov    r15,QWORD PTR [rsp+0x40]
     6f0:	add    rsp,0x50
     6f4:	mov    rsp,rbp
     6f7:	pop    rbp
     6f8:	ret
     6f9:	mov    QWORD PTR [rsp],rbx
     6fd:	mov    QWORD PTR [rsp+0x8],r12
     702:	mov    rdx,rax
     705:	mov    r13,r12
     708:	jmp    571 <botlish_fn_9+0x39>
     70d:	mov    rax,QWORD PTR [rsp+0x10]
     712:	mov    rbx,QWORD PTR [rsp+0x20]
     717:	mov    r12,QWORD PTR [rsp+0x28]
     71c:	mov    r13,QWORD PTR [rsp+0x30]
     721:	mov    r14,QWORD PTR [rsp+0x38]
     726:	mov    r15,QWORD PTR [rsp+0x40]
     72b:	add    rsp,0x50
     72f:	mov    rsp,rbp
     732:	pop    rbp
     733:	ret
     734:	mov    rax,0xffffffffffffffff
     73b:	mov    rbx,QWORD PTR [rsp+0x20]
     740:	mov    r12,QWORD PTR [rsp+0x28]
     745:	mov    r13,QWORD PTR [rsp+0x30]
     74a:	mov    r14,QWORD PTR [rsp+0x38]
     74f:	mov    r15,QWORD PTR [rsp+0x40]
     754:	add    rsp,0x50
     758:	mov    rsp,rbp
     75b:	pop    rbp
     75c:	ret
     75d:	add    BYTE PTR [rax],al
     75f:	add    BYTE PTR [rsi],al
     761:	add    BYTE PTR [rax],al
     763:	add    BYTE PTR [rax],al
     765:	add    BYTE PTR [rax],al
	...

0000000000000768 <botlish_entry_9: ht_find_get<HashTable, str, int>>:
     768:	push   rbp
     769:	mov    rbp,rsp
     76c:	mov    rsi,QWORD PTR [rdx]
     76f:	mov    r8,QWORD PTR [rdx+0x8]
     773:	mov    rcx,QWORD PTR [rdx+0x10]
     777:	mov    rdx,r8
     77a:	call   77f <botlish_entry_9+0x17>
			77b: R_X86_64_PLT32	botlish_fn_9-0x4 ; ht_find_get<HashTable, str, int>
     77f:	mov    rsp,rbp
     782:	pop    rbp
     783:	ret
     784:	add    BYTE PTR [rax],al
	...

0000000000000788 <botlish_fn_10: ht_find_insert<HashTable, str, int, int>>:
     788:	push   rbp
     789:	mov    rbp,rsp
     78c:	sub    rsp,0x60
     790:	mov    QWORD PTR [rsp+0x30],rbx
     795:	mov    QWORD PTR [rsp+0x38],r12
     79a:	mov    QWORD PTR [rsp+0x40],r13
     79f:	mov    QWORD PTR [rsp+0x48],r14
     7a4:	mov    QWORD PTR [rsp+0x50],r15
     7a9:	mov    r14,rdi
     7ac:	mov    QWORD PTR [rsp],rsi
     7b0:	mov    QWORD PTR [rsp+0x8],rdx
     7b5:	mov    r15,rdx
     7b8:	mov    QWORD PTR [rsp+0x10],r8
     7bd:	sar    rcx,1
     7c0:	mov    rdx,rcx
     7c3:	mov    r12,rsi
     7c6:	mov    r13,r8
     7c9:	mov    rsi,QWORD PTR [r12+0x18]
     7ce:	mov    rsi,QWORD PTR [rsi]
     7d1:	mov    rbx,rdx
     7d4:	shl    rbx,1
     7d7:	mov    QWORD PTR [rsp+0x18],rdx
     7dc:	or     rbx,0x1
     7e0:	mov    QWORD PTR [rsp+0x10],rbx
     7e5:	mov    rdx,rbx
     7e8:	mov    rdi,r14
     7eb:	call   7f0 <botlish_fn_10+0x68>
			7ec: R_X86_64_PLT32	rt_mutarray_get-0x4
     7f0:	mov    rcx,rax
     7f3:	mov    QWORD PTR [rsp+0x20],rax
     7f8:	mov    QWORD PTR [rsp+0x28],rbx
     7fd:	test   rax,rcx
     800:	je     a38 <botlish_fn_10+0x2b0>
     806:	mov    rax,QWORD PTR [rsp+0x20]
     80b:	test   rax,0x1
     811:	jne    83e <botlish_fn_10+0xb6>
     817:	mov    edx,0x1
     81c:	mov    rsi,QWORD PTR [rsp+0x20]
     821:	mov    rdi,r14
     824:	call   829 <botlish_fn_10+0xa1>
			825: R_X86_64_PLT32	rt_int_cmp-0x4
     829:	mov    ecx,0x2
     82e:	test   rax,rax
     831:	cmove  rcx,QWORD PTR [rip+0x2f7]        # b30 <botlish_fn_10+0x3a8>
     839:	jmp    854 <botlish_fn_10+0xcc>
     83e:	mov    ecx,0x2
     843:	mov    rax,QWORD PTR [rsp+0x20]
     848:	cmp    rax,0x1
     84c:	cmove  rcx,QWORD PTR [rip+0x2dc]        # b30 <botlish_fn_10+0x3a8>
     854:	cmp    rcx,0x6
     858:	je     a8a <botlish_fn_10+0x302>
     85e:	mov    rax,QWORD PTR [rsp+0x20]
     863:	test   rax,0x1
     869:	jne    896 <botlish_fn_10+0x10e>
     86f:	mov    edx,0x3
     874:	mov    rsi,QWORD PTR [rsp+0x20]
     879:	mov    rdi,r14
     87c:	call   881 <botlish_fn_10+0xf9>
			87d: R_X86_64_PLT32	rt_int_cmp-0x4
     881:	mov    ecx,0x2
     886:	test   rax,rax
     889:	cmove  rcx,QWORD PTR [rip+0x29f]        # b30 <botlish_fn_10+0x3a8>
     891:	jmp    8ac <botlish_fn_10+0x124>
     896:	mov    ecx,0x2
     89b:	mov    rax,QWORD PTR [rsp+0x20]
     8a0:	cmp    rax,0x3
     8a4:	cmove  rcx,QWORD PTR [rip+0x284]        # b30 <botlish_fn_10+0x3a8>
     8ac:	cmp    rcx,0x6
     8b0:	je     8c3 <botlish_fn_10+0x13b>
     8b6:	mov    rax,QWORD PTR [rsp+0x20]
     8bb:	mov    rbx,r15
     8be:	jmp    933 <botlish_fn_10+0x1ab>
     8c3:	mov    rax,QWORD PTR [r12+0x18]
     8c8:	mov    rsi,QWORD PTR [rax+0x8]
     8cc:	mov    rdx,QWORD PTR [rsp+0x28]
     8d1:	mov    rdi,r14
     8d4:	call   8d9 <botlish_fn_10+0x151>
			8d5: R_X86_64_PLT32	rt_mutarray_get-0x4
     8d9:	test   rax,rax
     8dc:	je     a38 <botlish_fn_10+0x2b0>
     8e2:	mov    rbx,r15
     8e5:	mov    rcx,rax
     8e8:	and    rcx,rbx
     8eb:	mov    rsi,rax
     8ee:	test   rcx,0x1
     8f5:	jne    914 <botlish_fn_10+0x18c>
     8fb:	mov    rdx,rbx
     8fe:	mov    rdi,r14
     901:	call   906 <botlish_fn_10+0x17e>
			902: R_X86_64_PLT32	rt_value_eq-0x4
     906:	test   rax,rax
     909:	je     a38 <botlish_fn_10+0x2b0>
     90f:	jmp    924 <botlish_fn_10+0x19c>
     914:	mov    eax,0x2
     919:	cmp    rsi,rbx
     91c:	cmove  rax,QWORD PTR [rip+0x20c]        # b30 <botlish_fn_10+0x3a8>
     924:	cmp    rax,0x6
     928:	je     a80 <botlish_fn_10+0x2f8>
     92e:	mov    rax,QWORD PTR [rsp+0x20]
     933:	test   rax,0x1
     939:	mov    QWORD PTR [rsp+0x20],rax
     93e:	jne    96b <botlish_fn_10+0x1e3>
     944:	mov    edx,0x5
     949:	mov    rsi,QWORD PTR [rsp+0x20]
     94e:	mov    rdi,r14
     951:	call   956 <botlish_fn_10+0x1ce>
			952: R_X86_64_PLT32	rt_int_cmp-0x4
     956:	mov    ecx,0x2
     95b:	test   rax,rax
     95e:	cmove  rcx,QWORD PTR [rip+0x1ca]        # b30 <botlish_fn_10+0x3a8>
     966:	jmp    981 <botlish_fn_10+0x1f9>
     96b:	mov    rsi,QWORD PTR [rsp+0x20]
     970:	mov    ecx,0x2
     975:	cmp    rsi,0x5
     979:	cmove  rcx,QWORD PTR [rip+0x1af]        # b30 <botlish_fn_10+0x3a8>
     981:	cmp    rcx,0x6
     985:	je     995 <botlish_fn_10+0x20d>
     98b:	mov    rdx,QWORD PTR [rsp+0x18]
     990:	jmp    9ec <botlish_fn_10+0x264>
     995:	test   r13,0x1
     99c:	jne    9c7 <botlish_fn_10+0x23f>
     9a2:	mov    edx,0x1
     9a7:	mov    rsi,r13
     9aa:	mov    rdi,r14
     9ad:	call   9b2 <botlish_fn_10+0x22a>
			9ae: R_X86_64_PLT32	rt_int_cmp-0x4
     9b2:	mov    ecx,0x2
     9b7:	test   rax,rax
     9ba:	cmovl  rcx,QWORD PTR [rip+0x16e]        # b30 <botlish_fn_10+0x3a8>
     9c2:	jmp    9dd <botlish_fn_10+0x255>
     9c7:	mov    ecx,0x2
     9cc:	mov    rax,r13
     9cf:	mov    rdx,r13
     9d2:	test   rax,rdx
     9d5:	cmovle rcx,QWORD PTR [rip+0x153]        # b30 <botlish_fn_10+0x3a8>
     9dd:	cmp    rcx,0x6
     9e1:	je     a1f <botlish_fn_10+0x297>
     9e7:	mov    rdx,QWORD PTR [rsp+0x18]
     9ec:	mov    rsi,r12
     9ef:	mov    rdi,r14
     9f2:	call   9f7 <botlish_fn_10+0x26f>
			9f3: R_X86_64_PLT32	botlish_fn_8-0x4 ; ht_probe_next<HashTable, int>
     9f7:	mov    rcx,rax
     9fa:	test   rdx,rdx
     9fd:	je     a38 <botlish_fn_10+0x2b0>
     a03:	mov    QWORD PTR [rsp],r12
     a07:	mov    QWORD PTR [rsp+0x8],rbx
     a0c:	mov    rax,r13
     a0f:	mov    QWORD PTR [rsp+0x10],rax
     a14:	mov    rdx,rcx
     a17:	mov    r15,rbx
     a1a:	jmp    7c9 <botlish_fn_10+0x41>
     a1f:	mov    rdx,QWORD PTR [rsp+0x18]
     a24:	mov    rsi,r12
     a27:	mov    rdi,r14
     a2a:	call   a2f <botlish_fn_10+0x2a7>
			a2b: R_X86_64_PLT32	botlish_fn_8-0x4 ; ht_probe_next<HashTable, int>
     a2f:	test   rdx,rdx
     a32:	jne    a5d <botlish_fn_10+0x2d5>
     a38:	xor    rax,rax
     a3b:	mov    rbx,QWORD PTR [rsp+0x30]
     a40:	mov    r12,QWORD PTR [rsp+0x38]
     a45:	mov    r13,QWORD PTR [rsp+0x40]
     a4a:	mov    r14,QWORD PTR [rsp+0x48]
     a4f:	mov    r15,QWORD PTR [rsp+0x50]
     a54:	add    rsp,0x60
     a58:	mov    rsp,rbp
     a5b:	pop    rbp
     a5c:	ret
     a5d:	mov    QWORD PTR [rsp],r12
     a61:	mov    QWORD PTR [rsp+0x8],rbx
     a66:	mov    rsi,QWORD PTR [rsp+0x28]
     a6b:	mov    QWORD PTR [rsp+0x10],rsi
     a70:	mov    rdx,rax
     a73:	mov    r13,QWORD PTR [rsp+0x28]
     a78:	mov    r15,rbx
     a7b:	jmp    7c9 <botlish_fn_10+0x41>
     a80:	mov    rax,QWORD PTR [rsp+0x28]
     a85:	jmp    ae3 <botlish_fn_10+0x35b>
     a8a:	mov    rax,r13
     a8d:	test   rax,0x1
     a93:	jne    abe <botlish_fn_10+0x336>
     a99:	mov    edx,0x1
     a9e:	mov    rdi,r14
     aa1:	mov    rsi,r13
     aa4:	call   aa9 <botlish_fn_10+0x321>
			aa5: R_X86_64_PLT32	rt_int_cmp-0x4
     aa9:	mov    edx,0x2
     aae:	test   rax,rax
     ab1:	cmovge rdx,QWORD PTR [rip+0x77]        # b30 <botlish_fn_10+0x3a8>
     ab9:	jmp    ad4 <botlish_fn_10+0x34c>
     abe:	mov    edx,0x2
     ac3:	mov    rax,r13
     ac6:	mov    rcx,r13
     ac9:	test   rax,rcx
     acc:	cmovg  rdx,QWORD PTR [rip+0x5c]        # b30 <botlish_fn_10+0x3a8>
     ad4:	cmp    rdx,0x6
     ad8:	je     b0a <botlish_fn_10+0x382>
     ade:	mov    rax,QWORD PTR [rsp+0x28]
     ae3:	mov    rax,QWORD PTR [rsp+0x28]
     ae8:	mov    rbx,QWORD PTR [rsp+0x30]
     aed:	mov    r12,QWORD PTR [rsp+0x38]
     af2:	mov    r13,QWORD PTR [rsp+0x40]
     af7:	mov    r14,QWORD PTR [rsp+0x48]
     afc:	mov    r15,QWORD PTR [rsp+0x50]
     b01:	add    rsp,0x60
     b05:	mov    rsp,rbp
     b08:	pop    rbp
     b09:	ret
     b0a:	mov    rax,r13
     b0d:	mov    rbx,QWORD PTR [rsp+0x30]
     b12:	mov    r12,QWORD PTR [rsp+0x38]
     b17:	mov    r13,QWORD PTR [rsp+0x40]
     b1c:	mov    r14,QWORD PTR [rsp+0x48]
     b21:	mov    r15,QWORD PTR [rsp+0x50]
     b26:	add    rsp,0x60
     b2a:	mov    rsp,rbp
     b2d:	pop    rbp
     b2e:	ret
     b2f:	add    BYTE PTR [rsi],al
     b31:	add    BYTE PTR [rax],al
     b33:	add    BYTE PTR [rax],al
     b35:	add    BYTE PTR [rax],al
	...

0000000000000b38 <botlish_entry_10: ht_find_insert<HashTable, str, int, int>>:
     b38:	push   rbp
     b39:	mov    rbp,rsp
     b3c:	mov    rsi,QWORD PTR [rdx]
     b3f:	mov    r9,QWORD PTR [rdx+0x8]
     b43:	mov    rcx,QWORD PTR [rdx+0x10]
     b47:	mov    r8,QWORD PTR [rdx+0x18]
     b4b:	mov    rdx,r9
     b4e:	call   b53 <botlish_entry_10+0x1b>
			b4f: R_X86_64_PLT32	botlish_fn_10-0x4 ; ht_find_insert<HashTable, str, int, int>
     b53:	mov    rsp,rbp
     b56:	pop    rbp
     b57:	ret

0000000000000b58 <botlish_fn_11: ht_get<HashTable, str>>:
     b58:	push   rbp
     b59:	mov    rbp,rsp
     b5c:	sub    rsp,0x40
     b60:	mov    QWORD PTR [rsp+0x20],rbx
     b65:	mov    QWORD PTR [rsp+0x28],r12
     b6a:	mov    QWORD PTR [rsp+0x30],r13
     b6f:	mov    r12,rdi
     b72:	mov    QWORD PTR [rsp+0x10],0x0
     b7b:	mov    QWORD PTR [rsp],rsi
     b7f:	mov    QWORD PTR [rsp+0x8],rdx
     b84:	mov    r13,rdx
     b87:	mov    rbx,rsi
     b8a:	mov    rdx,r13
     b8d:	mov    rdi,r12
     b90:	call   b95 <botlish_fn_11+0x3d>
			b91: R_X86_64_PLT32	botlish_fn_7-0x4 ; ht_probe_start<HashTable, str>
     b95:	test   rax,rax
     b98:	je     c30 <botlish_fn_11+0xd8>
     b9e:	mov    QWORD PTR [rsp+0x10],rax
     ba3:	mov    rcx,rax
     ba6:	mov    rdx,r13
     ba9:	mov    rsi,rbx
     bac:	mov    rdi,r12
     baf:	call   bb4 <botlish_fn_11+0x5c>
			bb0: R_X86_64_PLT32	botlish_fn_9-0x4 ; ht_find_get<HashTable, str, int>
     bb4:	mov    rcx,rax
     bb7:	mov    r13,rax
     bba:	test   rax,rcx
     bbd:	je     c30 <botlish_fn_11+0xd8>
     bc3:	mov    rax,r13
     bc6:	test   rax,0x1
     bcc:	jne    bf7 <botlish_fn_11+0x9f>
     bd2:	mov    edx,0x1
     bd7:	mov    rsi,r13
     bda:	mov    rdi,r12
     bdd:	call   be2 <botlish_fn_11+0x8a>
			bde: R_X86_64_PLT32	rt_int_cmp-0x4
     be2:	mov    ecx,0x2
     be7:	test   rax,rax
     bea:	cmovl  rcx,QWORD PTR [rip+0x8e]        # c80 <botlish_fn_11+0x128>
     bf2:	jmp    c0a <botlish_fn_11+0xb2>
     bf7:	mov    ecx,0x2
     bfc:	mov    rax,r13
     bff:	test   rax,rax
     c02:	cmovle rcx,QWORD PTR [rip+0x76]        # c80 <botlish_fn_11+0x128>
     c0a:	cmp    rcx,0x6
     c0e:	je     c63 <botlish_fn_11+0x10b>
     c14:	mov    rax,QWORD PTR [rbx+0x18]
     c18:	mov    rsi,QWORD PTR [rax+0x10]
     c1c:	mov    rdx,r13
     c1f:	mov    rdi,r12
     c22:	call   c27 <botlish_fn_11+0xcf>
			c23: R_X86_64_PLT32	rt_mutarray_get-0x4
     c27:	test   rax,rax
     c2a:	jne    c4b <botlish_fn_11+0xf3>
     c30:	xor    rax,rax
     c33:	mov    rbx,QWORD PTR [rsp+0x20]
     c38:	mov    r12,QWORD PTR [rsp+0x28]
     c3d:	mov    r13,QWORD PTR [rsp+0x30]
     c42:	add    rsp,0x40
     c46:	mov    rsp,rbp
     c49:	pop    rbp
     c4a:	ret
     c4b:	mov    rbx,QWORD PTR [rsp+0x20]
     c50:	mov    r12,QWORD PTR [rsp+0x28]
     c55:	mov    r13,QWORD PTR [rsp+0x30]
     c5a:	add    rsp,0x40
     c5e:	mov    rsp,rbp
     c61:	pop    rbp
     c62:	ret
     c63:	mov    eax,0xa
     c68:	mov    rbx,QWORD PTR [rsp+0x20]
     c6d:	mov    r12,QWORD PTR [rsp+0x28]
     c72:	mov    r13,QWORD PTR [rsp+0x30]
     c77:	add    rsp,0x40
     c7b:	mov    rsp,rbp
     c7e:	pop    rbp
     c7f:	ret
     c80:	(bad)
     c81:	add    BYTE PTR [rax],al
     c83:	add    BYTE PTR [rax],al
     c85:	add    BYTE PTR [rax],al
	...

0000000000000c88 <botlish_entry_11: ht_get<HashTable, str>>:
     c88:	push   rbp
     c89:	mov    rbp,rsp
     c8c:	mov    rsi,QWORD PTR [rdx]
     c8f:	mov    rdx,QWORD PTR [rdx+0x8]
     c93:	call   c98 <botlish_entry_11+0x10>
			c94: R_X86_64_PLT32	botlish_fn_11-0x4 ; ht_get<HashTable, str>
     c98:	mov    rsp,rbp
     c9b:	pop    rbp
     c9c:	ret
     c9d:	add    BYTE PTR [rax],al
	...

0000000000000ca0 <botlish_fn_12: ht_contains<HashTable, str>>:
     ca0:	push   rbp
     ca1:	mov    rbp,rsp
     ca4:	sub    rsp,0x40
     ca8:	mov    QWORD PTR [rsp+0x20],rbx
     cad:	mov    QWORD PTR [rsp+0x28],r12
     cb2:	mov    QWORD PTR [rsp+0x30],r15
     cb7:	mov    r15,rdi
     cba:	mov    QWORD PTR [rsp+0x10],0x0
     cc3:	mov    QWORD PTR [rsp],rsi
     cc7:	mov    r12,rsi
     cca:	mov    QWORD PTR [rsp+0x8],rdx
     ccf:	mov    rbx,rdx
     cd2:	mov    rdx,rbx
     cd5:	mov    rsi,r12
     cd8:	mov    rdi,r15
     cdb:	call   ce0 <botlish_fn_12+0x40>
			cdc: R_X86_64_PLT32	botlish_fn_7-0x4 ; ht_probe_start<HashTable, str>
     ce0:	test   rax,rax
     ce3:	je     d08 <botlish_fn_12+0x68>
     ce9:	mov    QWORD PTR [rsp+0x10],rax
     cee:	mov    rcx,rax
     cf1:	mov    rdx,rbx
     cf4:	mov    rsi,r12
     cf7:	mov    rdi,r15
     cfa:	call   cff <botlish_fn_12+0x5f>
			cfb: R_X86_64_PLT32	botlish_fn_9-0x4 ; ht_find_get<HashTable, str, int>
     cff:	test   rax,rax
     d02:	jne    d23 <botlish_fn_12+0x83>
     d08:	xor    rax,rax
     d0b:	mov    rbx,QWORD PTR [rsp+0x20]
     d10:	mov    r12,QWORD PTR [rsp+0x28]
     d15:	mov    r15,QWORD PTR [rsp+0x30]
     d1a:	add    rsp,0x40
     d1e:	mov    rsp,rbp
     d21:	pop    rbp
     d22:	ret
     d23:	test   rax,0x1
     d29:	mov    rsi,rax
     d2c:	jne    d57 <botlish_fn_12+0xb7>
     d32:	mov    edx,0x1
     d37:	mov    rdi,r15
     d3a:	call   d3f <botlish_fn_12+0x9f>
			d3b: R_X86_64_PLT32	rt_int_cmp-0x4
     d3f:	mov    ecx,0x2
     d44:	test   rax,rax
     d47:	mov    rax,rcx
     d4a:	cmovge rax,QWORD PTR [rip+0x2e]        # d80 <botlish_fn_12+0xe0>
     d52:	jmp    d67 <botlish_fn_12+0xc7>
     d57:	mov    eax,0x2
     d5c:	test   rsi,rsi
     d5f:	cmovg  rax,QWORD PTR [rip+0x19]        # d80 <botlish_fn_12+0xe0>
     d67:	mov    rbx,QWORD PTR [rsp+0x20]
     d6c:	mov    r12,QWORD PTR [rsp+0x28]
     d71:	mov    r15,QWORD PTR [rsp+0x30]
     d76:	add    rsp,0x40
     d7a:	mov    rsp,rbp
     d7d:	pop    rbp
     d7e:	ret
     d7f:	add    BYTE PTR [rsi],al
     d81:	add    BYTE PTR [rax],al
     d83:	add    BYTE PTR [rax],al
     d85:	add    BYTE PTR [rax],al
	...

0000000000000d88 <botlish_entry_12: ht_contains<HashTable, str>>:
     d88:	push   rbp
     d89:	mov    rbp,rsp
     d8c:	mov    rsi,QWORD PTR [rdx]
     d8f:	mov    rdx,QWORD PTR [rdx+0x8]
     d93:	call   d98 <botlish_entry_12+0x10>
			d94: R_X86_64_PLT32	botlish_fn_12-0x4 ; ht_contains<HashTable, str>
     d98:	mov    rsp,rbp
     d9b:	pop    rbp
     d9c:	ret
     d9d:	add    BYTE PTR [rax],al
	...

0000000000000da0 <botlish_fn_13: ht_rehash_probe<mutarray, int, int>>:
     da0:	push   rbp
     da1:	mov    rbp,rsp
     da4:	sub    rsp,0x40
     da8:	mov    QWORD PTR [rsp+0x20],rbx
     dad:	mov    QWORD PTR [rsp+0x28],r12
     db2:	mov    QWORD PTR [rsp+0x30],r13
     db7:	mov    QWORD PTR [rsp+0x38],r14
     dbc:	mov    r13,rdi
     dbf:	mov    QWORD PTR [rsp],rsi
     dc3:	mov    QWORD PTR [rsp+0x8],rdx
     dc8:	mov    QWORD PTR [rsp+0x10],rcx
     dcd:	mov    r12,rcx
     dd0:	mov    rbx,rsi
     dd3:	mov    r14,rdx
     dd6:	mov    rdx,r14
     dd9:	mov    rsi,rbx
     ddc:	mov    rdi,r13
     ddf:	call   de4 <botlish_fn_13+0x44>
			de0: R_X86_64_PLT32	rt_mutarray_get-0x4
     de4:	test   rax,rax
     de7:	je     e89 <botlish_fn_13+0xe9>
     ded:	test   rax,0x1
     df3:	mov    rsi,rax
     df6:	jne    e17 <botlish_fn_13+0x77>
     dfc:	mov    edx,0x1
     e01:	mov    rdi,r13
     e04:	call   e09 <botlish_fn_13+0x69>
			e05: R_X86_64_PLT32	rt_value_eq-0x4
     e09:	test   rax,rax
     e0c:	je     e89 <botlish_fn_13+0xe9>
     e12:	jmp    e28 <botlish_fn_13+0x88>
     e17:	mov    eax,0x2
     e1c:	cmp    rsi,0x1
     e20:	cmove  rax,QWORD PTR [rip+0xb8]        # ee0 <botlish_fn_13+0x140>
     e28:	cmp    rax,0x6
     e2c:	je     ebf <botlish_fn_13+0x11f>
     e32:	mov    QWORD PTR [rsp+0x18],0x3
     e3b:	mov    rsi,r14
     e3e:	test   rsi,0x1
     e45:	je     e5d <botlish_fn_13+0xbd>
     e4b:	mov    rsi,r14
     e4e:	add    rsi,0x2
     e52:	seto   al
     e55:	test   al,al
     e57:	je     e70 <botlish_fn_13+0xd0>
     e5d:	mov    edx,0x3
     e62:	mov    rsi,r14
     e65:	mov    rdi,r13
     e68:	call   e6d <botlish_fn_13+0xcd>
			e69: R_X86_64_PLT32	rt_int_add-0x4
     e6d:	mov    rsi,rax
     e70:	mov    QWORD PTR [rsp+0x8],rsi
     e75:	mov    rdx,r12
     e78:	mov    rdi,r13
     e7b:	call   e80 <botlish_fn_13+0xe0>
			e7c: R_X86_64_PLT32	rt_int_mod-0x4
     e80:	test   rax,rax
     e83:	jne    ea9 <botlish_fn_13+0x109>
     e89:	xor    rax,rax
     e8c:	mov    rbx,QWORD PTR [rsp+0x20]
     e91:	mov    r12,QWORD PTR [rsp+0x28]
     e96:	mov    r13,QWORD PTR [rsp+0x30]
     e9b:	mov    r14,QWORD PTR [rsp+0x38]
     ea0:	add    rsp,0x40
     ea4:	mov    rsp,rbp
     ea7:	pop    rbp
     ea8:	ret
     ea9:	mov    QWORD PTR [rsp],rbx
     ead:	mov    QWORD PTR [rsp+0x8],rax
     eb2:	mov    QWORD PTR [rsp+0x10],r12
     eb7:	mov    r14,rax
     eba:	jmp    dd6 <botlish_fn_13+0x36>
     ebf:	mov    rax,r14
     ec2:	mov    rbx,QWORD PTR [rsp+0x20]
     ec7:	mov    r12,QWORD PTR [rsp+0x28]
     ecc:	mov    r13,QWORD PTR [rsp+0x30]
     ed1:	mov    r14,QWORD PTR [rsp+0x38]
     ed6:	add    rsp,0x40
     eda:	mov    rsp,rbp
     edd:	pop    rbp
     ede:	ret
     edf:	add    BYTE PTR [rsi],al
     ee1:	add    BYTE PTR [rax],al
     ee3:	add    BYTE PTR [rax],al
     ee5:	add    BYTE PTR [rax],al
	...

0000000000000ee8 <botlish_entry_13: ht_rehash_probe<mutarray, int, int>>:
     ee8:	push   rbp
     ee9:	mov    rbp,rsp
     eec:	mov    rsi,QWORD PTR [rdx]
     eef:	mov    r8,QWORD PTR [rdx+0x8]
     ef3:	mov    rcx,QWORD PTR [rdx+0x10]
     ef7:	mov    rdx,r8
     efa:	call   eff <botlish_entry_13+0x17>
			efb: R_X86_64_PLT32	botlish_fn_13-0x4 ; ht_rehash_probe<mutarray, int, int>
     eff:	mov    rsp,rbp
     f02:	pop    rbp
     f03:	ret

0000000000000f04 <botlish_fn_14: ht_rehash_insert<HashTable, int, any, any>>:
     f04:	push   rbp
     f05:	mov    rbp,rsp
     f08:	sub    rsp,0x70
     f0c:	mov    QWORD PTR [rsp+0x40],rbx
     f11:	mov    QWORD PTR [rsp+0x48],r12
     f16:	mov    QWORD PTR [rsp+0x50],r13
     f1b:	mov    QWORD PTR [rsp+0x58],r14
     f20:	mov    QWORD PTR [rsp+0x60],r15
     f25:	mov    r13,rdi
     f28:	mov    QWORD PTR [rsp],rsi
     f2c:	mov    QWORD PTR [rsp+0x8],rdx
     f31:	mov    r15,rdx
     f34:	mov    QWORD PTR [rsp+0x10],rcx
     f39:	mov    r14,rcx
     f3c:	mov    QWORD PTR [rsp+0x18],r8
     f41:	mov    r12,r8
     f44:	mov    rax,QWORD PTR [rsi+0x18]
     f48:	mov    rbx,rsi
     f4b:	mov    rsi,QWORD PTR [rax]
     f4e:	mov    QWORD PTR [rsp+0x20],rsi
     f53:	mov    QWORD PTR [rsp+0x30],rsi
     f58:	mov    rsi,r14
     f5b:	mov    rdi,r13
     f5e:	call   f63 <botlish_fn_14+0x5f>
			f5f: R_X86_64_PLT32	rt_hash-0x4
     f63:	test   rax,rax
     f66:	je     100d <botlish_fn_14+0x109>
     f6c:	mov    QWORD PTR [rsp+0x28],rax
     f71:	mov    rsi,rax
     f74:	mov    rdx,r15
     f77:	mov    rdi,r13
     f7a:	call   f7f <botlish_fn_14+0x7b>
			f7b: R_X86_64_PLT32	rt_int_mod-0x4
     f7f:	test   rax,rax
     f82:	je     100d <botlish_fn_14+0x109>
     f88:	mov    QWORD PTR [rsp+0x28],rax
     f8d:	mov    rcx,r15
     f90:	mov    rdx,rax
     f93:	mov    rsi,QWORD PTR [rsp+0x30]
     f98:	mov    rdi,r13
     f9b:	call   fa0 <botlish_fn_14+0x9c>
			f9c: R_X86_64_PLT32	botlish_fn_13-0x4 ; ht_rehash_probe<mutarray, int, int>
     fa0:	mov    rdx,rax
     fa3:	mov    r15,rax
     fa6:	test   rax,rdx
     fa9:	je     100d <botlish_fn_14+0x109>
     faf:	mov    rcx,QWORD PTR [rbx+0x18]
     fb3:	mov    rsi,QWORD PTR [rcx]
     fb6:	mov    ecx,0x3
     fbb:	mov    rdx,r15
     fbe:	mov    rdi,r13
     fc1:	call   fc6 <botlish_fn_14+0xc2>
			fc2: R_X86_64_PLT32	rt_mutarray_set-0x4
     fc6:	test   rax,rax
     fc9:	je     100d <botlish_fn_14+0x109>
     fcf:	mov    rax,QWORD PTR [rbx+0x18]
     fd3:	mov    rsi,QWORD PTR [rax+0x8]
     fd7:	mov    rcx,r14
     fda:	mov    rdx,r15
     fdd:	mov    rdi,r13
     fe0:	call   fe5 <botlish_fn_14+0xe1>
			fe1: R_X86_64_PLT32	rt_mutarray_set-0x4
     fe5:	test   rax,rax
     fe8:	je     100d <botlish_fn_14+0x109>
     fee:	mov    rax,QWORD PTR [rbx+0x18]
     ff2:	mov    rsi,QWORD PTR [rax+0x10]
     ff6:	mov    rcx,r12
     ff9:	mov    rdx,r15
     ffc:	mov    rdi,r13
     fff:	call   1004 <botlish_fn_14+0x100>
			1000: R_X86_64_PLT32	rt_mutarray_set-0x4
    1004:	test   rax,rax
    1007:	jne    1032 <botlish_fn_14+0x12e>
    100d:	xor    rax,rax
    1010:	mov    rbx,QWORD PTR [rsp+0x40]
    1015:	mov    r12,QWORD PTR [rsp+0x48]
    101a:	mov    r13,QWORD PTR [rsp+0x50]
    101f:	mov    r14,QWORD PTR [rsp+0x58]
    1024:	mov    r15,QWORD PTR [rsp+0x60]
    1029:	add    rsp,0x70
    102d:	mov    rsp,rbp
    1030:	pop    rbp
    1031:	ret
    1032:	mov    rax,rbx
    1035:	mov    rbx,QWORD PTR [rsp+0x40]
    103a:	mov    r12,QWORD PTR [rsp+0x48]
    103f:	mov    r13,QWORD PTR [rsp+0x50]
    1044:	mov    r14,QWORD PTR [rsp+0x58]
    1049:	mov    r15,QWORD PTR [rsp+0x60]
    104e:	add    rsp,0x70
    1052:	mov    rsp,rbp
    1055:	pop    rbp
    1056:	ret

0000000000001057 <botlish_entry_14: ht_rehash_insert<HashTable, int, any, any>>:
    1057:	push   rbp
    1058:	mov    rbp,rsp
    105b:	mov    rsi,QWORD PTR [rdx]
    105e:	mov    r9,QWORD PTR [rdx+0x8]
    1062:	mov    rcx,QWORD PTR [rdx+0x10]
    1066:	mov    r8,QWORD PTR [rdx+0x18]
    106a:	mov    rdx,r9
    106d:	call   1072 <botlish_entry_14+0x1b>
			106e: R_X86_64_PLT32	botlish_fn_14-0x4 ; ht_rehash_insert<HashTable, int, any, any>
    1072:	mov    rsp,rbp
    1075:	pop    rbp
    1076:	ret
	...

0000000000001078 <botlish_fn_15: ht_rehash_scan<mutarray, mutarray, mutarray, int, int, HashTable, int>>:
    1078:	push   rbp
    1079:	mov    rbp,rsp
    107c:	sub    rsp,0x90
    1083:	mov    QWORD PTR [rsp+0x60],rbx
    1088:	mov    QWORD PTR [rsp+0x68],r12
    108d:	mov    QWORD PTR [rsp+0x70],r13
    1092:	mov    QWORD PTR [rsp+0x78],r14
    1097:	mov    QWORD PTR [rsp+0x80],r15
    109f:	mov    QWORD PTR [rsp+0x38],rdi
    10a4:	mov    QWORD PTR [rsp+0x40],r9
    10a9:	mov    rdi,QWORD PTR [rbp+0x10]
    10ad:	mov    rbx,QWORD PTR [rbp+0x18]
    10b1:	mov    QWORD PTR [rsp],rsi
    10b5:	mov    QWORD PTR [rsp+0x8],rdx
    10ba:	mov    r14,rdx
    10bd:	mov    QWORD PTR [rsp+0x10],rcx
    10c2:	mov    r15,rcx
    10c5:	mov    QWORD PTR [rsp+0x18],rdi
    10ca:	mov    QWORD PTR [rsp+0x20],rbx
    10cf:	sar    r8,1
    10d2:	mov    rcx,QWORD PTR [rsp+0x40]
    10d7:	mov    r12,r8
    10da:	mov    QWORD PTR [rsp+0x48],rdi
    10df:	cmp    r12,rcx
    10e2:	mov    QWORD PTR [rsp+0x40],rcx
    10e7:	jge    124e <botlish_fn_15+0x1d6>
    10ed:	mov    rdx,r12
    10f0:	shl    rdx,1
    10f3:	or     rdx,0x1
    10f7:	mov    r13,rsi
    10fa:	mov    QWORD PTR [rsp+0x58],rdx
    10ff:	mov    rdi,QWORD PTR [rsp+0x38]
    1104:	call   1109 <botlish_fn_15+0x91>
			1105: R_X86_64_PLT32	rt_mutarray_get-0x4
    1109:	test   rax,rax
    110c:	je     11f2 <botlish_fn_15+0x17a>
    1112:	test   rax,0x1
    1118:	mov    rsi,rax
    111b:	jne    113e <botlish_fn_15+0xc6>
    1121:	mov    edx,0x3
    1126:	mov    rdi,QWORD PTR [rsp+0x38]
    112b:	call   1130 <botlish_fn_15+0xb8>
			112c: R_X86_64_PLT32	rt_value_eq-0x4
    1130:	test   rax,rax
    1133:	je     11f2 <botlish_fn_15+0x17a>
    1139:	jmp    114f <botlish_fn_15+0xd7>
    113e:	mov    eax,0x2
    1143:	cmp    rsi,0x3
    1147:	cmove  rax,QWORD PTR [rip+0x131]        # 1280 <botlish_fn_15+0x208>
    114f:	cmp    rax,0x6
    1153:	je     118a <botlish_fn_15+0x112>
    1159:	mov    QWORD PTR [rsp],r13
    115d:	mov    QWORD PTR [rsp+0x8],r14
    1162:	mov    QWORD PTR [rsp+0x10],r15
    1167:	mov    rsi,QWORD PTR [rsp+0x48]
    116c:	mov    QWORD PTR [rsp+0x18],rsi
    1171:	mov    QWORD PTR [rsp+0x20],rbx
    1176:	add    r12,0x1
    117d:	mov    rcx,QWORD PTR [rsp+0x40]
    1182:	mov    rsi,r13
    1185:	jmp    10df <botlish_fn_15+0x67>
    118a:	mov    rdx,QWORD PTR [rsp+0x58]
    118f:	mov    rsi,r14
    1192:	mov    rdi,QWORD PTR [rsp+0x38]
    1197:	call   119c <botlish_fn_15+0x124>
			1198: R_X86_64_PLT32	rt_mutarray_get-0x4
    119c:	test   rax,rax
    119f:	je     11f2 <botlish_fn_15+0x17a>
    11a5:	mov    QWORD PTR [rsp+0x28],rax
    11aa:	mov    rdx,QWORD PTR [rsp+0x58]
    11af:	mov    QWORD PTR [rsp+0x50],rax
    11b4:	mov    rsi,r15
    11b7:	mov    rdi,QWORD PTR [rsp+0x38]
    11bc:	call   11c1 <botlish_fn_15+0x149>
			11bd: R_X86_64_PLT32	rt_mutarray_get-0x4
    11c1:	test   rax,rax
    11c4:	je     11f2 <botlish_fn_15+0x17a>
    11ca:	mov    QWORD PTR [rsp+0x30],rax
    11cf:	mov    rcx,QWORD PTR [rsp+0x50]
    11d4:	mov    rsi,QWORD PTR [rsp+0x48]
    11d9:	mov    r8,rax
    11dc:	mov    rdx,rbx
    11df:	mov    rdi,QWORD PTR [rsp+0x38]
    11e4:	call   11e9 <botlish_fn_15+0x171>
			11e5: R_X86_64_PLT32	botlish_fn_14-0x4 ; ht_rehash_insert<HashTable, int, any, any>
    11e9:	test   rax,rax
    11ec:	jne    121d <botlish_fn_15+0x1a5>
    11f2:	xor    rax,rax
    11f5:	mov    rbx,QWORD PTR [rsp+0x60]
    11fa:	mov    r12,QWORD PTR [rsp+0x68]
    11ff:	mov    r13,QWORD PTR [rsp+0x70]
    1204:	mov    r14,QWORD PTR [rsp+0x78]
    1209:	mov    r15,QWORD PTR [rsp+0x80]
    1211:	add    rsp,0x90
    1218:	mov    rsp,rbp
    121b:	pop    rbp
    121c:	ret
    121d:	mov    QWORD PTR [rsp],r13
    1221:	mov    QWORD PTR [rsp+0x8],r14
    1226:	mov    QWORD PTR [rsp+0x10],r15
    122b:	mov    QWORD PTR [rsp+0x18],rax
    1230:	mov    QWORD PTR [rsp+0x20],rbx
    1235:	add    r12,0x1
    123c:	mov    rcx,QWORD PTR [rsp+0x40]
    1241:	mov    rsi,r13
    1244:	mov    QWORD PTR [rsp+0x48],rax
    1249:	jmp    10df <botlish_fn_15+0x67>
    124e:	mov    rax,QWORD PTR [rsp+0x48]
    1253:	mov    rbx,QWORD PTR [rsp+0x60]
    1258:	mov    r12,QWORD PTR [rsp+0x68]
    125d:	mov    r13,QWORD PTR [rsp+0x70]
    1262:	mov    r14,QWORD PTR [rsp+0x78]
    1267:	mov    r15,QWORD PTR [rsp+0x80]
    126f:	add    rsp,0x90
    1276:	mov    rsp,rbp
    1279:	pop    rbp
    127a:	ret
    127b:	add    BYTE PTR [rax],al
    127d:	add    BYTE PTR [rax],al
    127f:	add    BYTE PTR [rsi],al
    1281:	add    BYTE PTR [rax],al
    1283:	add    BYTE PTR [rax],al
    1285:	add    BYTE PTR [rax],al
	...

0000000000001288 <botlish_entry_15: ht_rehash_scan<mutarray, mutarray, mutarray, int, int, HashTable, int>>:
    1288:	push   rbp
    1289:	mov    rbp,rsp
    128c:	sub    rsp,0x10
    1290:	mov    rsi,QWORD PTR [rdx]
    1293:	mov    r11,QWORD PTR [rdx+0x8]
    1297:	mov    rcx,QWORD PTR [rdx+0x10]
    129b:	mov    r8,QWORD PTR [rdx+0x18]
    129f:	mov    r9,QWORD PTR [rdx+0x20]
    12a3:	mov    rax,QWORD PTR [rdx+0x28]
    12a7:	mov    rdx,QWORD PTR [rdx+0x30]
    12ab:	sar    r9,1
    12ae:	mov    QWORD PTR [rsp],rax
    12b2:	mov    QWORD PTR [rsp+0x8],rdx
    12b7:	mov    rdx,r11
    12ba:	call   12bf <botlish_entry_15+0x37>
			12bb: R_X86_64_PLT32	botlish_fn_15-0x4 ; ht_rehash_scan<mutarray, mutarray, mutarray, int, int, HashTable, int>
    12bf:	add    rsp,0x10
    12c3:	mov    rsp,rbp
    12c6:	pop    rbp
    12c7:	ret

00000000000012c8 <botlish_fn_16: ht_rehash<HashTable, int>>:
    12c8:	push   rbp
    12c9:	mov    rbp,rsp
    12cc:	sub    rsp,0xf0
    12d3:	mov    QWORD PTR [rsp+0xc0],rbx
    12db:	mov    QWORD PTR [rsp+0xc8],r12
    12e3:	mov    QWORD PTR [rsp+0xd0],r13
    12eb:	mov    QWORD PTR [rsp+0xd8],r14
    12f3:	mov    QWORD PTR [rsp+0xe0],r15
    12fb:	mov    QWORD PTR [rsp+0x90],rdi
    1303:	mov    QWORD PTR [rsp+0x20],0x0
    130c:	mov    QWORD PTR [rsp+0x28],0x0
    1315:	mov    QWORD PTR [rsp+0x30],0x0
    131e:	mov    QWORD PTR [rsp+0x38],0x0
    1327:	mov    QWORD PTR [rsp+0x40],0x0
    1330:	mov    QWORD PTR [rsp+0x48],0x0
    1339:	mov    QWORD PTR [rsp+0x50],0x0
    1342:	mov    QWORD PTR [rsp+0x10],rsi
    1347:	mov    r14,rsi
    134a:	mov    QWORD PTR [rsp+0x18],rdx
    134f:	mov    QWORD PTR [rsp+0x98],rdx
    1357:	lea    rdx,[rsp+0x58]
    135c:	mov    rsi,QWORD PTR [rsp+0x98]
    1364:	mov    rdi,QWORD PTR [rsp+0x90]
    136c:	call   1371 <botlish_fn_16+0xa9>
			136d: R_X86_64_PLT32	botlish_fn_2-0x4 ; ht_alloc<int>
    1371:	test   rax,rax
    1374:	je     14c8 <botlish_fn_16+0x200>
    137a:	mov    QWORD PTR [rsp+0x10],rax
    137f:	mov    QWORD PTR [rsp+0xb8],rax
    1387:	mov    rbx,QWORD PTR [rsp+0x58]
    138c:	mov    QWORD PTR [rsp+0x20],rbx
    1391:	mov    r12,QWORD PTR [rsp+0x60]
    1396:	mov    QWORD PTR [rsp+0x28],r12
    139b:	mov    r13,QWORD PTR [rsp+0x68]
    13a0:	mov    QWORD PTR [rsp+0x30],r13
    13a5:	mov    rsi,r14
    13a8:	mov    rdi,QWORD PTR [rsp+0x90]
    13b0:	call   13b5 <botlish_fn_16+0xed>
			13b1: R_X86_64_PLT32	botlish_fn_4-0x4 ; ht_size<HashTable>
    13b5:	test   rax,rax
    13b8:	mov    rcx,rax
    13bb:	je     14c8 <botlish_fn_16+0x200>
    13c1:	mov    edx,0x1
    13c6:	mov    rsi,r13
    13c9:	mov    rdi,QWORD PTR [rsp+0x90]
    13d1:	call   13d6 <botlish_fn_16+0x10e>
			13d2: R_X86_64_PLT32	rt_mutarray_set-0x4
    13d6:	test   rax,rax
    13d9:	je     14c8 <botlish_fn_16+0x200>
    13df:	mov    rsi,r14
    13e2:	mov    rax,QWORD PTR [rsi+0x18]
    13e6:	mov    rcx,QWORD PTR [rax]
    13e9:	mov    QWORD PTR [rsp+0x38],rcx
    13ee:	mov    QWORD PTR [rsp+0xb0],rcx
    13f6:	mov    rax,QWORD PTR [rsi+0x18]
    13fa:	mov    r15,QWORD PTR [rax+0x8]
    13fe:	mov    QWORD PTR [rsp+0x40],r15
    1403:	mov    rax,QWORD PTR [rsi+0x18]
    1407:	mov    r14,QWORD PTR [rax+0x10]
    140b:	mov    QWORD PTR [rsp+0x48],r14
    1410:	mov    r8d,0x1
    1416:	mov    QWORD PTR [rsp+0xa8],r8
    141e:	mov    QWORD PTR [rsp+0x50],0x1
    1427:	mov    rdi,QWORD PTR [rsp+0x90]
    142f:	call   1434 <botlish_fn_16+0x16c>
			1430: R_X86_64_PLT32	botlish_fn_6-0x4 ; ht_capacity<HashTable>
    1434:	mov    QWORD PTR [rsp+0xa0],rax
    143c:	lea    rcx,[rsp+0x70]
    1441:	mov    rax,QWORD PTR [rsp+0xb8]
    1449:	mov    QWORD PTR [rsp+0x70],rax
    144e:	mov    QWORD PTR [rsp+0x78],rbx
    1453:	mov    QWORD PTR [rsp+0x80],r12
    145b:	mov    QWORD PTR [rsp+0x88],r13
    1463:	xor    rsi,rsi
    1466:	mov    edx,0x4
    146b:	mov    rdi,QWORD PTR [rsp+0x90]
    1473:	call   1478 <botlish_fn_16+0x1b0>
			1474: R_X86_64_PLT32	rt_struct_new-0x4
    1478:	mov    QWORD PTR [rsp+0x10],rax
    147d:	mov    rcx,QWORD PTR [rsp+0xa0]
    1485:	mov    r9,rcx
    1488:	sar    r9,1
    148b:	mov    QWORD PTR [rsp],rax
    148f:	mov    rdx,QWORD PTR [rsp+0x98]
    1497:	mov    QWORD PTR [rsp+0x8],rdx
    149c:	mov    rcx,r14
    149f:	mov    rdx,r15
    14a2:	mov    rsi,QWORD PTR [rsp+0xb0]
    14aa:	mov    rdi,QWORD PTR [rsp+0x90]
    14b2:	mov    r8,QWORD PTR [rsp+0xa8]
    14ba:	call   14bf <botlish_fn_16+0x1f7>
			14bb: R_X86_64_PLT32	botlish_fn_15-0x4 ; ht_rehash_scan<mutarray, mutarray, mutarray, int, int, HashTable, int>
    14bf:	test   rax,rax
    14c2:	jne    14ff <botlish_fn_16+0x237>
    14c8:	xor    rax,rax
    14cb:	mov    rbx,QWORD PTR [rsp+0xc0]
    14d3:	mov    r12,QWORD PTR [rsp+0xc8]
    14db:	mov    r13,QWORD PTR [rsp+0xd0]
    14e3:	mov    r14,QWORD PTR [rsp+0xd8]
    14eb:	mov    r15,QWORD PTR [rsp+0xe0]
    14f3:	add    rsp,0xf0
    14fa:	mov    rsp,rbp
    14fd:	pop    rbp
    14fe:	ret
    14ff:	mov    rbx,QWORD PTR [rsp+0xc0]
    1507:	mov    r12,QWORD PTR [rsp+0xc8]
    150f:	mov    r13,QWORD PTR [rsp+0xd0]
    1517:	mov    r14,QWORD PTR [rsp+0xd8]
    151f:	mov    r15,QWORD PTR [rsp+0xe0]
    1527:	add    rsp,0xf0
    152e:	mov    rsp,rbp
    1531:	pop    rbp
    1532:	ret

0000000000001533 <botlish_entry_16: ht_rehash<HashTable, int>>:
    1533:	push   rbp
    1534:	mov    rbp,rsp
    1537:	mov    rsi,QWORD PTR [rdx]
    153a:	mov    rdx,QWORD PTR [rdx+0x8]
    153e:	call   1543 <botlish_entry_16+0x10>
			153f: R_X86_64_PLT32	botlish_fn_16-0x4 ; ht_rehash<HashTable, int>
    1543:	mov    rsp,rbp
    1546:	pop    rbp
    1547:	ret

0000000000001548 <botlish_fn_17: ht_should_grow<HashTable>>:
    1548:	push   rbp
    1549:	mov    rbp,rsp
    154c:	sub    rsp,0x40
    1550:	mov    QWORD PTR [rsp+0x20],rbx
    1555:	mov    QWORD PTR [rsp+0x28],r12
    155a:	mov    QWORD PTR [rsp+0x30],r13
    155f:	mov    rbx,rdi
    1562:	mov    QWORD PTR [rsp],rsi
    1566:	mov    r12,rsi
    1569:	mov    rsi,r12
    156c:	mov    rdi,rbx
    156f:	call   1574 <botlish_fn_17+0x2c>
			1570: R_X86_64_PLT32	botlish_fn_4-0x4 ; ht_size<HashTable>
    1574:	mov    rcx,rax
    1577:	mov    r13,rax
    157a:	test   rax,rcx
    157d:	je     1654 <botlish_fn_17+0x10c>
    1583:	mov    rax,r13
    1586:	mov    QWORD PTR [rsp+0x8],rax
    158b:	mov    rsi,r12
    158e:	mov    rdi,rbx
    1591:	call   1596 <botlish_fn_17+0x4e>
			1592: R_X86_64_PLT32	botlish_fn_5-0x4 ; ht_tombstones<HashTable>
    1596:	mov    rcx,rax
    1599:	test   rcx,rcx
    159c:	je     1654 <botlish_fn_17+0x10c>
    15a2:	mov    QWORD PTR [rsp+0x10],rcx
    15a7:	mov    edx,0x1
    15ac:	mov    rax,r13
    15af:	test   rax,0x1
    15b5:	jne    15d8 <botlish_fn_17+0x90>
    15bb:	xor    edx,edx
    15bd:	mov    rax,r13
    15c0:	test   rax,0x7
    15c6:	jne    15d8 <botlish_fn_17+0x90>
    15cc:	mov    rax,r13
    15cf:	movzx  rax,BYTE PTR [rax]
    15d3:	cmp    al,0x1
    15d5:	sete   dl
    15d8:	test   dl,dl
    15da:	jne    15fa <botlish_fn_17+0xb2>
    15e0:	mov    rdi,rbx
    15e3:	mov    rax,QWORD PTR [rdi+0x10]
    15e7:	mov    rcx,QWORD PTR [rax]
    15ea:	xor    rdx,rdx
    15ed:	mov    rsi,r13
    15f0:	call   15f5 <botlish_fn_17+0xad>
			15f1: R_X86_64_PLT32	rt_type_error-0x4
    15f5:	jmp    1654 <botlish_fn_17+0x10c>
    15fa:	mov    eax,0x1
    15ff:	test   rcx,0x1
    1606:	je     1614 <botlish_fn_17+0xcc>
    160c:	mov    r8,rcx
    160f:	jmp    1637 <botlish_fn_17+0xef>
    1614:	xor    eax,eax
    1616:	test   rcx,0x7
    161d:	je     162b <botlish_fn_17+0xe3>
    1623:	mov    r8,rcx
    1626:	jmp    1637 <botlish_fn_17+0xef>
    162b:	movzx  rax,BYTE PTR [rcx]
    162f:	mov    r8,rcx
    1632:	cmp    al,0x1
    1634:	sete   al
    1637:	test   al,al
    1639:	jne    166f <botlish_fn_17+0x127>
    163f:	mov    rdi,rbx
    1642:	mov    rax,QWORD PTR [rdi+0x10]
    1646:	mov    rcx,QWORD PTR [rax]
    1649:	xor    rdx,rdx
    164c:	mov    rsi,r8
    164f:	call   1654 <botlish_fn_17+0x10c>
			1650: R_X86_64_PLT32	rt_type_error-0x4
    1654:	xor    rax,rax
    1657:	mov    rbx,QWORD PTR [rsp+0x20]
    165c:	mov    r12,QWORD PTR [rsp+0x28]
    1661:	mov    r13,QWORD PTR [rsp+0x30]
    1666:	add    rsp,0x40
    166a:	mov    rsp,rbp
    166d:	pop    rbp
    166e:	ret
    166f:	mov    rcx,r8
    1672:	mov    rsi,r13
    1675:	mov    rax,rsi
    1678:	and    rax,rcx
    167b:	test   rax,0x1
    1681:	jne    1692 <botlish_fn_17+0x14a>
    1687:	mov    rdx,r8
    168a:	mov    rsi,r13
    168d:	jmp    16b0 <botlish_fn_17+0x168>
    1692:	mov    rcx,r8
    1695:	lea    rax,[rcx-0x1]
    1699:	mov    rsi,r13
    169c:	add    rsi,rax
    169f:	seto   al
    16a2:	test   al,al
    16a4:	je     16bb <botlish_fn_17+0x173>
    16aa:	mov    rdx,r8
    16ad:	mov    rsi,r13
    16b0:	mov    rdi,rbx
    16b3:	call   16b8 <botlish_fn_17+0x170>
			16b4: R_X86_64_PLT32	rt_int_add-0x4
    16b8:	mov    rsi,rax
    16bb:	mov    QWORD PTR [rsp+0x8],rsi
    16c0:	mov    QWORD PTR [rsp+0x10],0x3
    16c9:	test   rsi,0x1
    16d0:	je     16f3 <botlish_fn_17+0x1ab>
    16d6:	mov    rax,rsi
    16d9:	add    rax,0x2
    16dd:	mov    rcx,rax
    16e0:	seto   al
    16e3:	test   al,al
    16e5:	jne    16f3 <botlish_fn_17+0x1ab>
    16eb:	mov    rsi,rcx
    16ee:	jmp    1703 <botlish_fn_17+0x1bb>
    16f3:	mov    edx,0x3
    16f8:	mov    rdi,rbx
    16fb:	call   1700 <botlish_fn_17+0x1b8>
			16fc: R_X86_64_PLT32	rt_int_add-0x4
    1700:	mov    rsi,rax
    1703:	mov    QWORD PTR [rsp+0x8],rsi
    1708:	mov    edx,0x7
    170d:	mov    rdi,rdx
    1710:	mov    QWORD PTR [rsp+0x10],0x7
    1719:	test   rsi,0x1
    1720:	jne    172e <botlish_fn_17+0x1e6>
    1726:	mov    rdx,rdi
    1729:	jmp    175a <botlish_fn_17+0x212>
    172e:	mov    rax,rsi
    1731:	sar    rax,1
    1734:	imul   QWORD PTR [rip+0xf5]        # 1830 <botlish_fn_17+0x2e8>
    173b:	seto   cl
    173e:	or     rax,0x1
    1742:	test   cl,cl
    1744:	je     1752 <botlish_fn_17+0x20a>
    174a:	mov    rdx,rdi
    174d:	jmp    175a <botlish_fn_17+0x212>
    1752:	mov    rsi,rax
    1755:	jmp    1765 <botlish_fn_17+0x21d>
    175a:	mov    rdi,rbx
    175d:	call   1762 <botlish_fn_17+0x21a>
			175e: R_X86_64_PLT32	rt_int_mul-0x4
    1762:	mov    rsi,rax
    1765:	mov    QWORD PTR [rsp],rsi
    1769:	mov    r13,rsi
    176c:	mov    rsi,r12
    176f:	mov    rdi,rbx
    1772:	call   1777 <botlish_fn_17+0x22f>
			1773: R_X86_64_PLT32	botlish_fn_6-0x4 ; ht_capacity<HashTable>
    1777:	mov    QWORD PTR [rsp+0x8],rax
    177c:	mov    QWORD PTR [rsp+0x10],0x5
    1785:	test   rax,0x1
    178b:	mov    rcx,rax
    178e:	je     17bd <botlish_fn_17+0x275>
    1794:	mov    rax,rcx
    1797:	sar    rax,1
    179a:	imul   QWORD PTR [rip+0x97]        # 1838 <botlish_fn_17+0x2f0>
    17a1:	seto   sil
    17a5:	or     rax,0x1
    17a9:	test   sil,sil
    17ac:	jne    17bd <botlish_fn_17+0x275>
    17b2:	mov    rdx,rax
    17b5:	mov    rsi,r13
    17b8:	jmp    17d3 <botlish_fn_17+0x28b>
    17bd:	mov    edx,0x5
    17c2:	mov    rsi,rcx
    17c5:	mov    rdi,rbx
    17c8:	call   17cd <botlish_fn_17+0x285>
			17c9: R_X86_64_PLT32	rt_int_mul-0x4
    17cd:	mov    rdx,rax
    17d0:	mov    rsi,r13
    17d3:	mov    rdi,rsi
    17d6:	and    rdi,rdx
    17d9:	test   rdi,0x1
    17e0:	jne    1806 <botlish_fn_17+0x2be>
    17e6:	mov    rdi,rbx
    17e9:	call   17ee <botlish_fn_17+0x2a6>
			17ea: R_X86_64_PLT32	rt_int_cmp-0x4
    17ee:	mov    esi,0x2
    17f3:	test   rax,rax
    17f6:	mov    rax,rsi
    17f9:	cmovg  rax,QWORD PTR [rip+0x2f]        # 1830 <botlish_fn_17+0x2e8>
    1801:	jmp    1816 <botlish_fn_17+0x2ce>
    1806:	mov    eax,0x2
    180b:	cmp    rsi,rdx
    180e:	cmovg  rax,QWORD PTR [rip+0x1a]        # 1830 <botlish_fn_17+0x2e8>
    1816:	mov    rbx,QWORD PTR [rsp+0x20]
    181b:	mov    r12,QWORD PTR [rsp+0x28]
    1820:	mov    r13,QWORD PTR [rsp+0x30]
    1825:	add    rsp,0x40
    1829:	mov    rsp,rbp
    182c:	pop    rbp
    182d:	ret
    182e:	add    BYTE PTR [rax],al
    1830:	(bad)
    1831:	add    BYTE PTR [rax],al
    1833:	add    BYTE PTR [rax],al
    1835:	add    BYTE PTR [rax],al
    1837:	add    BYTE PTR [rax+rax*1],al
    183a:	add    BYTE PTR [rax],al
    183c:	add    BYTE PTR [rax],al
	...

0000000000001840 <botlish_entry_17: ht_should_grow<HashTable>>:
    1840:	push   rbp
    1841:	mov    rbp,rsp
    1844:	mov    rsi,QWORD PTR [rdx]
    1847:	call   184c <botlish_entry_17+0xc>
			1848: R_X86_64_PLT32	botlish_fn_17-0x4 ; ht_should_grow<HashTable>
    184c:	mov    rsp,rbp
    184f:	pop    rbp
    1850:	ret
    1851:	add    BYTE PTR [rax],al
    1853:	add    BYTE PTR [rax],al
    1855:	add    BYTE PTR [rax],al
	...

0000000000001858 <botlish_fn_18: ht_grow_or_clean<HashTable>>:
    1858:	push   rbp
    1859:	mov    rbp,rsp
    185c:	sub    rsp,0x40
    1860:	mov    QWORD PTR [rsp+0x20],rbx
    1865:	mov    QWORD PTR [rsp+0x28],r12
    186a:	mov    QWORD PTR [rsp+0x30],r13
    186f:	mov    rbx,rdi
    1872:	mov    QWORD PTR [rsp+0x10],0x0
    187b:	mov    QWORD PTR [rsp],rsi
    187f:	mov    r12,rsi
    1882:	mov    rsi,r12
    1885:	mov    rdi,rbx
    1888:	call   188d <botlish_fn_18+0x35>
			1889: R_X86_64_PLT32	botlish_fn_5-0x4 ; ht_tombstones<HashTable>
    188d:	test   rax,rax
    1890:	mov    r13,rax
    1893:	je     1a81 <botlish_fn_18+0x229>
    1899:	mov    rsi,r12
    189c:	mov    rdi,rbx
    189f:	call   18a4 <botlish_fn_18+0x4c>
			18a0: R_X86_64_PLT32	botlish_fn_4-0x4 ; ht_size<HashTable>
    18a4:	mov    r11,rax
    18a7:	test   r11,r11
    18aa:	je     1a81 <botlish_fn_18+0x229>
    18b0:	mov    ecx,0x1
    18b5:	mov    rax,r13
    18b8:	test   rax,0x1
    18be:	je     18cc <botlish_fn_18+0x74>
    18c4:	mov    r13,rax
    18c7:	jmp    18f0 <botlish_fn_18+0x98>
    18cc:	xor    ecx,ecx
    18ce:	test   rax,0x7
    18d4:	je     18e2 <botlish_fn_18+0x8a>
    18da:	mov    r13,rax
    18dd:	jmp    18f0 <botlish_fn_18+0x98>
    18e2:	movzx  rcx,BYTE PTR [rax]
    18e6:	mov    r13,rax
    18e9:	rex cmp cl,0x1
    18ed:	sete   cl
    18f0:	test   cl,cl
    18f2:	jne    1913 <botlish_fn_18+0xbb>
    18f8:	mov    rdi,rbx
    18fb:	mov    rsi,QWORD PTR [rdi+0x10]
    18ff:	mov    rcx,QWORD PTR [rsi+0x8]
    1903:	xor    rdx,rdx
    1906:	mov    rsi,r13
    1909:	call   190e <botlish_fn_18+0xb6>
			190a: R_X86_64_PLT32	rt_type_error-0x4
    190e:	jmp    1a81 <botlish_fn_18+0x229>
    1913:	mov    rsi,r13
    1916:	mov    eax,0x1
    191b:	test   r11,0x1
    1922:	je     1930 <botlish_fn_18+0xd8>
    1928:	mov    r8,r11
    192b:	jmp    1955 <botlish_fn_18+0xfd>
    1930:	xor    eax,eax
    1932:	test   r11,0x7
    1939:	je     1947 <botlish_fn_18+0xef>
    193f:	mov    r8,r11
    1942:	jmp    1955 <botlish_fn_18+0xfd>
    1947:	movzx  r10,BYTE PTR [r11]
    194b:	mov    r8,r11
    194e:	cmp    r10b,0x1
    1952:	sete   al
    1955:	test   al,al
    1957:	jne    1978 <botlish_fn_18+0x120>
    195d:	mov    rdi,rbx
    1960:	mov    rax,QWORD PTR [rdi+0x10]
    1964:	mov    rcx,QWORD PTR [rax+0x8]
    1968:	xor    rdx,rdx
    196b:	mov    rsi,r8
    196e:	call   1973 <botlish_fn_18+0x11b>
			196f: R_X86_64_PLT32	rt_type_error-0x4
    1973:	jmp    1a81 <botlish_fn_18+0x229>
    1978:	mov    r11,r8
    197b:	mov    rax,rsi
    197e:	and    rax,r11
    1981:	test   rax,0x1
    1987:	jne    19ad <botlish_fn_18+0x155>
    198d:	mov    rdx,r8
    1990:	mov    rdi,rbx
    1993:	call   1998 <botlish_fn_18+0x140>
			1994: R_X86_64_PLT32	rt_int_cmp-0x4
    1998:	mov    ecx,0x2
    199d:	test   rax,rax
    19a0:	cmovg  rcx,QWORD PTR [rip+0x110]        # 1ab8 <botlish_fn_18+0x260>
    19a8:	jmp    19c0 <botlish_fn_18+0x168>
    19ad:	mov    ecx,0x2
    19b2:	mov    r11,r8
    19b5:	cmp    rsi,r11
    19b8:	cmovg  rcx,QWORD PTR [rip+0xf8]        # 1ab8 <botlish_fn_18+0x260>
    19c0:	cmp    rcx,0x6
    19c4:	je     1a5a <botlish_fn_18+0x202>
    19ca:	mov    rsi,r12
    19cd:	mov    rdi,rbx
    19d0:	call   19d5 <botlish_fn_18+0x17d>
			19d1: R_X86_64_PLT32	botlish_fn_6-0x4 ; ht_capacity<HashTable>
    19d5:	mov    QWORD PTR [rsp+0x8],rax
    19da:	mov    QWORD PTR [rsp+0x10],0x5
    19e3:	test   rax,0x1
    19e9:	mov    rsi,rax
    19ec:	je     1a19 <botlish_fn_18+0x1c1>
    19f2:	mov    rcx,rsi
    19f5:	mov    rax,rcx
    19f8:	sar    rax,1
    19fb:	imul   QWORD PTR [rip+0xbe]        # 1ac0 <botlish_fn_18+0x268>
    1a02:	seto   cl
    1a05:	or     rax,0x1
    1a09:	test   cl,cl
    1a0b:	jne    1a19 <botlish_fn_18+0x1c1>
    1a11:	mov    rdx,rax
    1a14:	jmp    1a29 <botlish_fn_18+0x1d1>
    1a19:	mov    edx,0x5
    1a1e:	mov    rdi,rbx
    1a21:	call   1a26 <botlish_fn_18+0x1ce>
			1a22: R_X86_64_PLT32	rt_int_mul-0x4
    1a26:	mov    rdx,rax
    1a29:	mov    QWORD PTR [rsp+0x8],rdx
    1a2e:	mov    rsi,r12
    1a31:	mov    rdi,rbx
    1a34:	call   1a39 <botlish_fn_18+0x1e1>
			1a35: R_X86_64_PLT32	botlish_fn_16-0x4 ; ht_rehash<HashTable, int>
    1a39:	test   rax,rax
    1a3c:	je     1a81 <botlish_fn_18+0x229>
    1a42:	mov    rbx,QWORD PTR [rsp+0x20]
    1a47:	mov    r12,QWORD PTR [rsp+0x28]
    1a4c:	mov    r13,QWORD PTR [rsp+0x30]
    1a51:	add    rsp,0x40
    1a55:	mov    rsp,rbp
    1a58:	pop    rbp
    1a59:	ret
    1a5a:	mov    rsi,r12
    1a5d:	mov    rdi,rbx
    1a60:	call   1a65 <botlish_fn_18+0x20d>
			1a61: R_X86_64_PLT32	botlish_fn_6-0x4 ; ht_capacity<HashTable>
    1a65:	mov    QWORD PTR [rsp+0x8],rax
    1a6a:	mov    rdx,rax
    1a6d:	mov    rsi,r12
    1a70:	mov    rdi,rbx
    1a73:	call   1a78 <botlish_fn_18+0x220>
			1a74: R_X86_64_PLT32	botlish_fn_16-0x4 ; ht_rehash<HashTable, int>
    1a78:	test   rax,rax
    1a7b:	jne    1a9c <botlish_fn_18+0x244>
    1a81:	xor    rax,rax
    1a84:	mov    rbx,QWORD PTR [rsp+0x20]
    1a89:	mov    r12,QWORD PTR [rsp+0x28]
    1a8e:	mov    r13,QWORD PTR [rsp+0x30]
    1a93:	add    rsp,0x40
    1a97:	mov    rsp,rbp
    1a9a:	pop    rbp
    1a9b:	ret
    1a9c:	mov    rbx,QWORD PTR [rsp+0x20]
    1aa1:	mov    r12,QWORD PTR [rsp+0x28]
    1aa6:	mov    r13,QWORD PTR [rsp+0x30]
    1aab:	add    rsp,0x40
    1aaf:	mov    rsp,rbp
    1ab2:	pop    rbp
    1ab3:	ret
    1ab4:	add    BYTE PTR [rax],al
    1ab6:	add    BYTE PTR [rax],al
    1ab8:	(bad)
    1ab9:	add    BYTE PTR [rax],al
    1abb:	add    BYTE PTR [rax],al
    1abd:	add    BYTE PTR [rax],al
    1abf:	add    BYTE PTR [rax+rax*1],al
    1ac2:	add    BYTE PTR [rax],al
    1ac4:	add    BYTE PTR [rax],al
	...

0000000000001ac8 <botlish_entry_18: ht_grow_or_clean<HashTable>>:
    1ac8:	push   rbp
    1ac9:	mov    rbp,rsp
    1acc:	mov    rsi,QWORD PTR [rdx]
    1acf:	call   1ad4 <botlish_entry_18+0xc>
			1ad0: R_X86_64_PLT32	botlish_fn_18-0x4 ; ht_grow_or_clean<HashTable>
    1ad4:	mov    rsp,rbp
    1ad7:	pop    rbp
    1ad8:	ret
    1ad9:	add    BYTE PTR [rax],al
    1adb:	add    BYTE PTR [rax],al
    1add:	add    BYTE PTR [rax],al
	...

0000000000001ae0 <botlish_fn_19: ht_place<HashTable, int, str, str>>:
    1ae0:	push   rbp
    1ae1:	mov    rbp,rsp
    1ae4:	sub    rsp,0x70
    1ae8:	mov    QWORD PTR [rsp+0x40],rbx
    1aed:	mov    QWORD PTR [rsp+0x48],r12
    1af2:	mov    QWORD PTR [rsp+0x50],r13
    1af7:	mov    QWORD PTR [rsp+0x58],r14
    1afc:	mov    QWORD PTR [rsp+0x60],r15
    1b01:	mov    r12,rdi
    1b04:	mov    r14,r8
    1b07:	mov    r15,rdx
    1b0a:	mov    QWORD PTR [rsp+0x30],rcx
    1b0f:	mov    QWORD PTR [rsp],rsi
    1b13:	mov    r9,QWORD PTR [rsi+0x18]
    1b17:	mov    r13,rsi
    1b1a:	mov    rsi,QWORD PTR [r9]
    1b1d:	mov    rdx,r15
    1b20:	mov    rdi,r12
    1b23:	call   1b28 <botlish_fn_19+0x48>
			1b24: R_X86_64_PLT32	rt_mutarray_get-0x4
    1b28:	test   rax,rax
    1b2b:	je     1dbf <botlish_fn_19+0x2df>
    1b31:	mov    QWORD PTR [rsp+0x8],rax
    1b36:	mov    rbx,r13
    1b39:	mov    r13,rax
    1b3c:	mov    rax,QWORD PTR [rbx+0x18]
    1b40:	mov    rsi,QWORD PTR [rax]
    1b43:	mov    ecx,0x3
    1b48:	mov    rdx,r15
    1b4b:	mov    rdi,r12
    1b4e:	call   1b53 <botlish_fn_19+0x73>
			1b4f: R_X86_64_PLT32	rt_mutarray_set-0x4
    1b53:	test   rax,rax
    1b56:	je     1dbf <botlish_fn_19+0x2df>
    1b5c:	mov    rax,QWORD PTR [rbx+0x18]
    1b60:	mov    rsi,QWORD PTR [rax+0x8]
    1b64:	mov    rcx,QWORD PTR [rsp+0x30]
    1b69:	mov    rdx,r15
    1b6c:	mov    rdi,r12
    1b6f:	call   1b74 <botlish_fn_19+0x94>
			1b70: R_X86_64_PLT32	rt_mutarray_set-0x4
    1b74:	test   rax,rax
    1b77:	je     1dbf <botlish_fn_19+0x2df>
    1b7d:	mov    rax,QWORD PTR [rbx+0x18]
    1b81:	mov    rsi,QWORD PTR [rax+0x10]
    1b85:	mov    rcx,r14
    1b88:	mov    rdx,r15
    1b8b:	mov    rdi,r12
    1b8e:	call   1b93 <botlish_fn_19+0xb3>
			1b8f: R_X86_64_PLT32	rt_mutarray_set-0x4
    1b93:	test   rax,rax
    1b96:	je     1dbf <botlish_fn_19+0x2df>
    1b9c:	mov    rax,QWORD PTR [rbx+0x18]
    1ba0:	mov    rsi,QWORD PTR [rax+0x18]
    1ba4:	mov    QWORD PTR [rsp+0x10],rsi
    1ba9:	mov    r14,rsi
    1bac:	mov    QWORD PTR [rsp+0x18],0x1
    1bb5:	mov    rsi,rbx
    1bb8:	mov    rdi,r12
    1bbb:	call   1bc0 <botlish_fn_19+0xe0>
			1bbc: R_X86_64_PLT32	botlish_fn_4-0x4 ; ht_size<HashTable>
    1bc0:	test   rax,rax
    1bc3:	je     1dbf <botlish_fn_19+0x2df>
    1bc9:	mov    QWORD PTR [rsp+0x20],rax
    1bce:	mov    QWORD PTR [rsp+0x28],0x3
    1bd7:	mov    ecx,0x1
    1bdc:	test   rax,0x1
    1be2:	je     1bf0 <botlish_fn_19+0x110>
    1be8:	mov    rsi,rax
    1beb:	jmp    1c14 <botlish_fn_19+0x134>
    1bf0:	xor    ecx,ecx
    1bf2:	test   rax,0x7
    1bf8:	je     1c06 <botlish_fn_19+0x126>
    1bfe:	mov    rsi,rax
    1c01:	jmp    1c14 <botlish_fn_19+0x134>
    1c06:	movzx  rcx,BYTE PTR [rax]
    1c0a:	mov    rsi,rax
    1c0d:	rex cmp cl,0x1
    1c11:	sete   cl
    1c14:	test   cl,cl
    1c16:	jne    1c33 <botlish_fn_19+0x153>
    1c1c:	mov    rdi,r12
    1c1f:	mov    rax,QWORD PTR [rdi+0x10]
    1c23:	mov    rcx,QWORD PTR [rax]
    1c26:	xor    rdx,rdx
    1c29:	call   1c2e <botlish_fn_19+0x14e>
			1c2a: R_X86_64_PLT32	rt_type_error-0x4
    1c2e:	jmp    1dbf <botlish_fn_19+0x2df>
    1c33:	test   rsi,0x1
    1c3a:	je     1c52 <botlish_fn_19+0x172>
    1c40:	mov    rcx,rsi
    1c43:	add    rcx,0x2
    1c47:	seto   al
    1c4a:	test   al,al
    1c4c:	je     1c62 <botlish_fn_19+0x182>
    1c52:	mov    edx,0x3
    1c57:	mov    rdi,r12
    1c5a:	call   1c5f <botlish_fn_19+0x17f>
			1c5b: R_X86_64_PLT32	rt_int_add-0x4
    1c5f:	mov    rcx,rax
    1c62:	mov    edx,0x1
    1c67:	mov    rsi,r14
    1c6a:	mov    rdi,r12
    1c6d:	call   1c72 <botlish_fn_19+0x192>
			1c6e: R_X86_64_PLT32	rt_mutarray_set-0x4
    1c72:	test   rax,rax
    1c75:	je     1dbf <botlish_fn_19+0x2df>
    1c7b:	mov    rax,r13
    1c7e:	test   rax,0x1
    1c84:	jne    1caf <botlish_fn_19+0x1cf>
    1c8a:	mov    edx,0x5
    1c8f:	mov    rsi,r13
    1c92:	mov    rdi,r12
    1c95:	call   1c9a <botlish_fn_19+0x1ba>
			1c96: R_X86_64_PLT32	rt_int_cmp-0x4
    1c9a:	mov    ecx,0x2
    1c9f:	test   rax,rax
    1ca2:	cmove  rcx,QWORD PTR [rip+0x166]        # 1e10 <botlish_fn_19+0x330>
    1caa:	jmp    1cc3 <botlish_fn_19+0x1e3>
    1caf:	mov    rsi,r13
    1cb2:	mov    ecx,0x2
    1cb7:	cmp    rsi,0x5
    1cbb:	cmove  rcx,QWORD PTR [rip+0x14d]        # 1e10 <botlish_fn_19+0x330>
    1cc3:	cmp    rcx,0x6
    1cc7:	je     1cd5 <botlish_fn_19+0x1f5>
    1ccd:	mov    rax,rbx
    1cd0:	jmp    1de7 <botlish_fn_19+0x307>
    1cd5:	mov    rax,QWORD PTR [rbx+0x18]
    1cd9:	mov    rsi,QWORD PTR [rax+0x18]
    1cdd:	mov    QWORD PTR [rsp+0x8],rsi
    1ce2:	mov    r14,rsi
    1ce5:	mov    QWORD PTR [rsp+0x10],0x3
    1cee:	mov    rsi,rbx
    1cf1:	mov    rdi,r12
    1cf4:	call   1cf9 <botlish_fn_19+0x219>
			1cf5: R_X86_64_PLT32	botlish_fn_5-0x4 ; ht_tombstones<HashTable>
    1cf9:	mov    r13,rbx
    1cfc:	test   rax,rax
    1cff:	je     1dbf <botlish_fn_19+0x2df>
    1d05:	mov    QWORD PTR [rsp+0x18],rax
    1d0a:	mov    QWORD PTR [rsp+0x20],0x3
    1d13:	mov    ecx,0x1
    1d18:	test   rax,0x1
    1d1e:	je     1d2c <botlish_fn_19+0x24c>
    1d24:	mov    rsi,rax
    1d27:	jmp    1d50 <botlish_fn_19+0x270>
    1d2c:	xor    ecx,ecx
    1d2e:	test   rax,0x7
    1d34:	je     1d42 <botlish_fn_19+0x262>
    1d3a:	mov    rsi,rax
    1d3d:	jmp    1d50 <botlish_fn_19+0x270>
    1d42:	movzx  r10,BYTE PTR [rax]
    1d46:	mov    rsi,rax
    1d49:	cmp    r10b,0x1
    1d4d:	sete   cl
    1d50:	test   cl,cl
    1d52:	jne    1d70 <botlish_fn_19+0x290>
    1d58:	mov    rdi,r12
    1d5b:	mov    rax,QWORD PTR [rdi+0x10]
    1d5f:	mov    rcx,QWORD PTR [rax+0x10]
    1d63:	xor    rdx,rdx
    1d66:	call   1d6b <botlish_fn_19+0x28b>
			1d67: R_X86_64_PLT32	rt_type_error-0x4
    1d6b:	jmp    1dbf <botlish_fn_19+0x2df>
    1d70:	test   rsi,0x1
    1d77:	je     1d96 <botlish_fn_19+0x2b6>
    1d7d:	mov    rcx,rsi
    1d80:	sub    rcx,0x3
    1d84:	seto   al
    1d87:	add    rcx,0x1
    1d8e:	test   al,al
    1d90:	je     1da6 <botlish_fn_19+0x2c6>
    1d96:	mov    edx,0x3
    1d9b:	mov    rdi,r12
    1d9e:	call   1da3 <botlish_fn_19+0x2c3>
			1d9f: R_X86_64_PLT32	rt_int_sub-0x4
    1da3:	mov    rcx,rax
    1da6:	mov    edx,0x3
    1dab:	mov    rsi,r14
    1dae:	mov    rdi,r12
    1db1:	call   1db6 <botlish_fn_19+0x2d6>
			1db2: R_X86_64_PLT32	rt_mutarray_set-0x4
    1db6:	test   rax,rax
    1db9:	jne    1de4 <botlish_fn_19+0x304>
    1dbf:	xor    rax,rax
    1dc2:	mov    rbx,QWORD PTR [rsp+0x40]
    1dc7:	mov    r12,QWORD PTR [rsp+0x48]
    1dcc:	mov    r13,QWORD PTR [rsp+0x50]
    1dd1:	mov    r14,QWORD PTR [rsp+0x58]
    1dd6:	mov    r15,QWORD PTR [rsp+0x60]
    1ddb:	add    rsp,0x70
    1ddf:	mov    rsp,rbp
    1de2:	pop    rbp
    1de3:	ret
    1de4:	mov    rax,r13
    1de7:	mov    rbx,QWORD PTR [rsp+0x40]
    1dec:	mov    r12,QWORD PTR [rsp+0x48]
    1df1:	mov    r13,QWORD PTR [rsp+0x50]
    1df6:	mov    r14,QWORD PTR [rsp+0x58]
    1dfb:	mov    r15,QWORD PTR [rsp+0x60]
    1e00:	add    rsp,0x70
    1e04:	mov    rsp,rbp
    1e07:	pop    rbp
    1e08:	ret
    1e09:	add    BYTE PTR [rax],al
    1e0b:	add    BYTE PTR [rax],al
    1e0d:	add    BYTE PTR [rax],al
    1e0f:	add    BYTE PTR [rsi],al
    1e11:	add    BYTE PTR [rax],al
    1e13:	add    BYTE PTR [rax],al
    1e15:	add    BYTE PTR [rax],al
	...

0000000000001e18 <botlish_entry_19: ht_place<HashTable, int, str, str>>:
    1e18:	push   rbp
    1e19:	mov    rbp,rsp
    1e1c:	mov    rsi,QWORD PTR [rdx]
    1e1f:	mov    r9,QWORD PTR [rdx+0x8]
    1e23:	mov    rcx,QWORD PTR [rdx+0x10]
    1e27:	mov    r8,QWORD PTR [rdx+0x18]
    1e2b:	mov    rdx,r9
    1e2e:	call   1e33 <botlish_entry_19+0x1b>
			1e2f: R_X86_64_PLT32	botlish_fn_19-0x4 ; ht_place<HashTable, int, str, str>
    1e33:	mov    rsp,rbp
    1e36:	pop    rbp
    1e37:	ret

0000000000001e38 <botlish_fn_20: ht_set<HashTable, str, str>>:
    1e38:	push   rbp
    1e39:	mov    rbp,rsp
    1e3c:	sub    rsp,0x60
    1e40:	mov    QWORD PTR [rsp+0x30],rbx
    1e45:	mov    QWORD PTR [rsp+0x38],r12
    1e4a:	mov    QWORD PTR [rsp+0x40],r13
    1e4f:	mov    QWORD PTR [rsp+0x48],r14
    1e54:	mov    QWORD PTR [rsp+0x50],r15
    1e59:	mov    r12,rdi
    1e5c:	mov    QWORD PTR [rsp+0x18],0x0
    1e65:	mov    QWORD PTR [rsp+0x20],0x0
    1e6e:	mov    QWORD PTR [rsp],rsi
    1e72:	mov    r14,rsi
    1e75:	mov    QWORD PTR [rsp+0x8],rdx
    1e7a:	mov    r13,rdx
    1e7d:	mov    QWORD PTR [rsp+0x10],rcx
    1e82:	mov    rbx,rcx
    1e85:	mov    rdx,r13
    1e88:	mov    rsi,r14
    1e8b:	mov    rdi,r12
    1e8e:	call   1e93 <botlish_fn_20+0x5b>
			1e8f: R_X86_64_PLT32	botlish_fn_7-0x4 ; ht_probe_start<HashTable, str>
    1e93:	test   rax,rax
    1e96:	je     206e <botlish_fn_20+0x236>
    1e9c:	mov    QWORD PTR [rsp+0x18],rax
    1ea1:	mov    rcx,rax
    1ea4:	mov    r8,0xffffffffffffffff
    1eab:	mov    r15,r8
    1eae:	mov    QWORD PTR [rsp+0x20],0xffffffffffffffff
    1eb7:	mov    rdx,r13
    1eba:	mov    rsi,r14
    1ebd:	mov    rdi,r12
    1ec0:	call   1ec5 <botlish_fn_20+0x8d>
			1ec1: R_X86_64_PLT32	botlish_fn_10-0x4 ; ht_find_insert<HashTable, str, int, int>
    1ec5:	test   rax,rax
    1ec8:	je     206e <botlish_fn_20+0x236>
    1ece:	mov    QWORD PTR [rsp+0x18],rax
    1ed3:	mov    rsi,r14
    1ed6:	mov    QWORD PTR [rsp+0x28],rax
    1edb:	mov    rax,QWORD PTR [rsi+0x18]
    1edf:	mov    rsi,QWORD PTR [rax]
    1ee2:	mov    rdx,QWORD PTR [rsp+0x28]
    1ee7:	mov    rdi,r12
    1eea:	call   1eef <botlish_fn_20+0xb7>
			1eeb: R_X86_64_PLT32	rt_mutarray_get-0x4
    1eef:	test   rax,rax
    1ef2:	je     206e <botlish_fn_20+0x236>
    1ef8:	test   rax,0x1
    1efe:	mov    rsi,rax
    1f01:	jne    1f29 <botlish_fn_20+0xf1>
    1f07:	mov    edx,0x3
    1f0c:	mov    rdi,r12
    1f0f:	call   1f14 <botlish_fn_20+0xdc>
			1f10: R_X86_64_PLT32	rt_int_cmp-0x4
    1f14:	mov    ecx,0x2
    1f19:	test   rax,rax
    1f1c:	cmove  rcx,QWORD PTR [rip+0x194]        # 20b8 <botlish_fn_20+0x280>
    1f24:	jmp    1f3a <botlish_fn_20+0x102>
    1f29:	mov    ecx,0x2
    1f2e:	cmp    rsi,0x3
    1f32:	cmove  rcx,QWORD PTR [rip+0x17e]        # 20b8 <botlish_fn_20+0x280>
    1f3a:	cmp    rcx,0x6
    1f3e:	je     204a <botlish_fn_20+0x212>
    1f44:	mov    rsi,r14
    1f47:	mov    rdi,r12
    1f4a:	call   1f4f <botlish_fn_20+0x117>
			1f4b: R_X86_64_PLT32	botlish_fn_17-0x4 ; ht_should_grow<HashTable>
    1f4f:	test   rax,rax
    1f52:	je     206e <botlish_fn_20+0x236>
    1f58:	cmp    rax,0x6
    1f5c:	je     1fa3 <botlish_fn_20+0x16b>
    1f62:	mov    rcx,r13
    1f65:	mov    rdx,QWORD PTR [rsp+0x28]
    1f6a:	mov    rsi,r14
    1f6d:	mov    rdi,r12
    1f70:	mov    r8,rbx
    1f73:	call   1f78 <botlish_fn_20+0x140>
			1f74: R_X86_64_PLT32	botlish_fn_19-0x4 ; ht_place<HashTable, int, str, str>
    1f78:	test   rax,rax
    1f7b:	je     206e <botlish_fn_20+0x236>
    1f81:	mov    rbx,QWORD PTR [rsp+0x30]
    1f86:	mov    r12,QWORD PTR [rsp+0x38]
    1f8b:	mov    r13,QWORD PTR [rsp+0x40]
    1f90:	mov    r14,QWORD PTR [rsp+0x48]
    1f95:	mov    r15,QWORD PTR [rsp+0x50]
    1f9a:	add    rsp,0x60
    1f9e:	mov    rsp,rbp
    1fa1:	pop    rbp
    1fa2:	ret
    1fa3:	mov    rsi,r14
    1fa6:	mov    rdi,r12
    1fa9:	call   1fae <botlish_fn_20+0x176>
			1faa: R_X86_64_PLT32	botlish_fn_18-0x4 ; ht_grow_or_clean<HashTable>
    1fae:	mov    rcx,rax
    1fb1:	mov    r14,rax
    1fb4:	test   rax,rcx
    1fb7:	je     206e <botlish_fn_20+0x236>
    1fbd:	mov    rax,r14
    1fc0:	mov    QWORD PTR [rsp],rax
    1fc4:	mov    rdx,r13
    1fc7:	mov    rsi,r14
    1fca:	mov    rdi,r12
    1fcd:	call   1fd2 <botlish_fn_20+0x19a>
			1fce: R_X86_64_PLT32	botlish_fn_7-0x4 ; ht_probe_start<HashTable, str>
    1fd2:	test   rax,rax
    1fd5:	je     206e <botlish_fn_20+0x236>
    1fdb:	mov    QWORD PTR [rsp+0x18],rax
    1fe0:	mov    rcx,rax
    1fe3:	mov    QWORD PTR [rsp+0x20],0xffffffffffffffff
    1fec:	mov    r8,r15
    1fef:	mov    rdx,r13
    1ff2:	mov    rsi,r14
    1ff5:	mov    rdi,r12
    1ff8:	call   1ffd <botlish_fn_20+0x1c5>
			1ff9: R_X86_64_PLT32	botlish_fn_10-0x4 ; ht_find_insert<HashTable, str, int, int>
    1ffd:	test   rax,rax
    2000:	je     206e <botlish_fn_20+0x236>
    2006:	mov    QWORD PTR [rsp+0x18],rax
    200b:	mov    rcx,r13
    200e:	mov    rdx,rax
    2011:	mov    rsi,r14
    2014:	mov    rdi,r12
    2017:	mov    r8,rbx
    201a:	call   201f <botlish_fn_20+0x1e7>
			201b: R_X86_64_PLT32	botlish_fn_19-0x4 ; ht_place<HashTable, int, str, str>
    201f:	test   rax,rax
    2022:	je     206e <botlish_fn_20+0x236>
    2028:	mov    rbx,QWORD PTR [rsp+0x30]
    202d:	mov    r12,QWORD PTR [rsp+0x38]
    2032:	mov    r13,QWORD PTR [rsp+0x40]
    2037:	mov    r14,QWORD PTR [rsp+0x48]
    203c:	mov    r15,QWORD PTR [rsp+0x50]
    2041:	add    rsp,0x60
    2045:	mov    rsp,rbp
    2048:	pop    rbp
    2049:	ret
    204a:	mov    rdx,QWORD PTR [rsp+0x28]
    204f:	mov    rsi,r14
    2052:	mov    rax,QWORD PTR [rsi+0x18]
    2056:	mov    rsi,QWORD PTR [rax+0x10]
    205a:	mov    rcx,rbx
    205d:	mov    rdi,r12
    2060:	call   2065 <botlish_fn_20+0x22d>
			2061: R_X86_64_PLT32	rt_mutarray_set-0x4
    2065:	test   rax,rax
    2068:	jne    2093 <botlish_fn_20+0x25b>
    206e:	xor    rax,rax
    2071:	mov    rbx,QWORD PTR [rsp+0x30]
    2076:	mov    r12,QWORD PTR [rsp+0x38]
    207b:	mov    r13,QWORD PTR [rsp+0x40]
    2080:	mov    r14,QWORD PTR [rsp+0x48]
    2085:	mov    r15,QWORD PTR [rsp+0x50]
    208a:	add    rsp,0x60
    208e:	mov    rsp,rbp
    2091:	pop    rbp
    2092:	ret
    2093:	mov    rax,r14
    2096:	mov    rbx,QWORD PTR [rsp+0x30]
    209b:	mov    r12,QWORD PTR [rsp+0x38]
    20a0:	mov    r13,QWORD PTR [rsp+0x40]
    20a5:	mov    r14,QWORD PTR [rsp+0x48]
    20aa:	mov    r15,QWORD PTR [rsp+0x50]
    20af:	add    rsp,0x60
    20b3:	mov    rsp,rbp
    20b6:	pop    rbp
    20b7:	ret
    20b8:	(bad)
    20b9:	add    BYTE PTR [rax],al
    20bb:	add    BYTE PTR [rax],al
    20bd:	add    BYTE PTR [rax],al
	...

00000000000020c0 <botlish_entry_20: ht_set<HashTable, str, str>>:
    20c0:	push   rbp
    20c1:	mov    rbp,rsp
    20c4:	mov    rsi,QWORD PTR [rdx]
    20c7:	mov    r8,QWORD PTR [rdx+0x8]
    20cb:	mov    rcx,QWORD PTR [rdx+0x10]
    20cf:	mov    rdx,r8
    20d2:	call   20d7 <botlish_entry_20+0x17>
			20d3: R_X86_64_PLT32	botlish_fn_20-0x4 ; ht_set<HashTable, str, str>
    20d7:	mov    rsp,rbp
    20da:	pop    rbp
    20db:	ret
    20dc:	add    BYTE PTR [rax],al
	...

00000000000020e0 <botlish_fn_21: ht_delete<HashTable, str>>:
    20e0:	push   rbp
    20e1:	mov    rbp,rsp
    20e4:	sub    rsp,0x50
    20e8:	mov    QWORD PTR [rsp+0x30],rbx
    20ed:	mov    QWORD PTR [rsp+0x38],r12
    20f2:	mov    QWORD PTR [rsp+0x40],r13
    20f7:	mov    QWORD PTR [rsp+0x48],r14
    20fc:	mov    r13,rdi
    20ff:	mov    QWORD PTR [rsp+0x10],0x0
    2108:	mov    QWORD PTR [rsp+0x18],0x0
    2111:	mov    QWORD PTR [rsp+0x20],0x0
    211a:	mov    QWORD PTR [rsp],rsi
    211e:	mov    r12,rsi
    2121:	mov    QWORD PTR [rsp+0x8],rdx
    2126:	mov    r14,rdx
    2129:	mov    rbx,r12
    212c:	mov    rdx,r14
    212f:	mov    rsi,rbx
    2132:	mov    rdi,r13
    2135:	call   213a <botlish_fn_21+0x5a>
			2136: R_X86_64_PLT32	botlish_fn_7-0x4 ; ht_probe_start<HashTable, str>
    213a:	test   rax,rax
    213d:	je     23f1 <botlish_fn_21+0x311>
    2143:	mov    QWORD PTR [rsp+0x10],rax
    2148:	mov    rcx,rax
    214b:	mov    rdx,r14
    214e:	mov    rsi,rbx
    2151:	mov    rdi,r13
    2154:	call   2159 <botlish_fn_21+0x79>
			2155: R_X86_64_PLT32	botlish_fn_9-0x4 ; ht_find_get<HashTable, str, int>
    2159:	mov    rcx,rax
    215c:	mov    r12,rax
    215f:	test   rax,rcx
    2162:	je     23f1 <botlish_fn_21+0x311>
    2168:	mov    rax,r12
    216b:	test   rax,0x1
    2171:	jne    219c <botlish_fn_21+0xbc>
    2177:	mov    edx,0x1
    217c:	mov    rsi,r12
    217f:	mov    rdi,r13
    2182:	call   2187 <botlish_fn_21+0xa7>
			2183: R_X86_64_PLT32	rt_int_cmp-0x4
    2187:	mov    ecx,0x2
    218c:	test   rax,rax
    218f:	cmovge rcx,QWORD PTR [rip+0x2a1]        # 2438 <botlish_fn_21+0x358>
    2197:	jmp    21ac <botlish_fn_21+0xcc>
    219c:	mov    ecx,0x2
    21a1:	test   r12,r12
    21a4:	cmovg  rcx,QWORD PTR [rip+0x28c]        # 2438 <botlish_fn_21+0x358>
    21ac:	cmp    rcx,0x6
    21b0:	je     21be <botlish_fn_21+0xde>
    21b6:	mov    rax,rbx
    21b9:	jmp    2414 <botlish_fn_21+0x334>
    21be:	mov    rcx,QWORD PTR [rbx+0x18]
    21c2:	mov    rsi,QWORD PTR [rcx]
    21c5:	mov    ecx,0x5
    21ca:	mov    rdx,r12
    21cd:	mov    rdi,r13
    21d0:	call   21d5 <botlish_fn_21+0xf5>
			21d1: R_X86_64_PLT32	rt_mutarray_set-0x4
    21d5:	test   rax,rax
    21d8:	je     23f1 <botlish_fn_21+0x311>
    21de:	mov    rax,QWORD PTR [rbx+0x18]
    21e2:	mov    rsi,QWORD PTR [rax+0x8]
    21e6:	mov    ecx,0xa
    21eb:	mov    rdx,r12
    21ee:	mov    rdi,r13
    21f1:	call   21f6 <botlish_fn_21+0x116>
			21f2: R_X86_64_PLT32	rt_mutarray_set-0x4
    21f6:	test   rax,rax
    21f9:	je     23f1 <botlish_fn_21+0x311>
    21ff:	mov    rax,QWORD PTR [rbx+0x18]
    2203:	mov    rsi,QWORD PTR [rax+0x10]
    2207:	mov    ecx,0xa
    220c:	mov    rdx,r12
    220f:	mov    rdi,r13
    2212:	call   2217 <botlish_fn_21+0x137>
			2213: R_X86_64_PLT32	rt_mutarray_set-0x4
    2217:	test   rax,rax
    221a:	je     23f1 <botlish_fn_21+0x311>
    2220:	mov    rax,QWORD PTR [rbx+0x18]
    2224:	mov    rsi,QWORD PTR [rax+0x18]
    2228:	mov    QWORD PTR [rsp+0x8],rsi
    222d:	mov    r12,rsi
    2230:	mov    QWORD PTR [rsp+0x10],0x1
    2239:	mov    rsi,rbx
    223c:	mov    rdi,r13
    223f:	call   2244 <botlish_fn_21+0x164>
			2240: R_X86_64_PLT32	botlish_fn_4-0x4 ; ht_size<HashTable>
    2244:	test   rax,rax
    2247:	je     23f1 <botlish_fn_21+0x311>
    224d:	mov    QWORD PTR [rsp+0x18],rax
    2252:	mov    QWORD PTR [rsp+0x20],0x3
    225b:	mov    esi,0x1
    2260:	test   rax,0x1
    2266:	je     2274 <botlish_fn_21+0x194>
    226c:	mov    r8,rax
    226f:	jmp    2299 <botlish_fn_21+0x1b9>
    2274:	xor    esi,esi
    2276:	test   rax,0x7
    227c:	je     228a <botlish_fn_21+0x1aa>
    2282:	mov    r8,rax
    2285:	jmp    2299 <botlish_fn_21+0x1b9>
    228a:	movzx  rcx,BYTE PTR [rax]
    228e:	mov    r8,rax
    2291:	rex cmp cl,0x1
    2295:	sete   sil
    2299:	test   sil,sil
    229c:	jne    22bd <botlish_fn_21+0x1dd>
    22a2:	mov    rdi,r13
    22a5:	mov    rax,QWORD PTR [rdi+0x10]
    22a9:	mov    rcx,QWORD PTR [rax+0x10]
    22ad:	xor    rdx,rdx
    22b0:	mov    rsi,r8
    22b3:	call   22b8 <botlish_fn_21+0x1d8>
			22b4: R_X86_64_PLT32	rt_type_error-0x4
    22b8:	jmp    23f1 <botlish_fn_21+0x311>
    22bd:	mov    rsi,r8
    22c0:	test   rsi,0x1
    22c7:	je     22e6 <botlish_fn_21+0x206>
    22cd:	mov    rcx,rsi
    22d0:	sub    rcx,0x3
    22d4:	seto   al
    22d7:	add    rcx,0x1
    22de:	test   al,al
    22e0:	je     22f6 <botlish_fn_21+0x216>
    22e6:	mov    edx,0x3
    22eb:	mov    rdi,r13
    22ee:	call   22f3 <botlish_fn_21+0x213>
			22ef: R_X86_64_PLT32	rt_int_sub-0x4
    22f3:	mov    rcx,rax
    22f6:	mov    edx,0x1
    22fb:	mov    rsi,r12
    22fe:	mov    rdi,r13
    2301:	call   2306 <botlish_fn_21+0x226>
			2302: R_X86_64_PLT32	rt_mutarray_set-0x4
    2306:	test   rax,rax
    2309:	je     23f1 <botlish_fn_21+0x311>
    230f:	mov    rsi,QWORD PTR [rbx+0x18]
    2313:	mov    rsi,QWORD PTR [rsi+0x18]
    2317:	mov    QWORD PTR [rsp+0x8],rsi
    231c:	mov    r14,rsi
    231f:	mov    QWORD PTR [rsp+0x10],0x3
    2328:	mov    rsi,rbx
    232b:	mov    rdi,r13
    232e:	call   2333 <botlish_fn_21+0x253>
			232f: R_X86_64_PLT32	botlish_fn_5-0x4 ; ht_tombstones<HashTable>
    2333:	mov    r12,rbx
    2336:	test   rax,rax
    2339:	je     23f1 <botlish_fn_21+0x311>
    233f:	mov    QWORD PTR [rsp+0x18],rax
    2344:	mov    QWORD PTR [rsp+0x20],0x3
    234d:	mov    ecx,0x1
    2352:	test   rax,0x1
    2358:	je     2366 <botlish_fn_21+0x286>
    235e:	mov    rsi,rax
    2361:	jmp    238a <botlish_fn_21+0x2aa>
    2366:	xor    ecx,ecx
    2368:	test   rax,0x7
    236e:	je     237c <botlish_fn_21+0x29c>
    2374:	mov    rsi,rax
    2377:	jmp    238a <botlish_fn_21+0x2aa>
    237c:	movzx  rcx,BYTE PTR [rax]
    2380:	mov    rsi,rax
    2383:	rex cmp cl,0x1
    2387:	sete   cl
    238a:	test   cl,cl
    238c:	jne    23a9 <botlish_fn_21+0x2c9>
    2392:	mov    rdi,r13
    2395:	mov    rax,QWORD PTR [rdi+0x10]
    2399:	mov    rcx,QWORD PTR [rax]
    239c:	xor    rdx,rdx
    239f:	call   23a4 <botlish_fn_21+0x2c4>
			23a0: R_X86_64_PLT32	rt_type_error-0x4
    23a4:	jmp    23f1 <botlish_fn_21+0x311>
    23a9:	test   rsi,0x1
    23b0:	je     23c8 <botlish_fn_21+0x2e8>
    23b6:	mov    rcx,rsi
    23b9:	add    rcx,0x2
    23bd:	seto   al
    23c0:	test   al,al
    23c2:	je     23d8 <botlish_fn_21+0x2f8>
    23c8:	mov    edx,0x3
    23cd:	mov    rdi,r13
    23d0:	call   23d5 <botlish_fn_21+0x2f5>
			23d1: R_X86_64_PLT32	rt_int_add-0x4
    23d5:	mov    rcx,rax
    23d8:	mov    edx,0x3
    23dd:	mov    rsi,r14
    23e0:	mov    rdi,r13
    23e3:	call   23e8 <botlish_fn_21+0x308>
			23e4: R_X86_64_PLT32	rt_mutarray_set-0x4
    23e8:	test   rax,rax
    23eb:	jne    2411 <botlish_fn_21+0x331>
    23f1:	xor    rax,rax
    23f4:	mov    rbx,QWORD PTR [rsp+0x30]
    23f9:	mov    r12,QWORD PTR [rsp+0x38]
    23fe:	mov    r13,QWORD PTR [rsp+0x40]
    2403:	mov    r14,QWORD PTR [rsp+0x48]
    2408:	add    rsp,0x50
    240c:	mov    rsp,rbp
    240f:	pop    rbp
    2410:	ret
    2411:	mov    rax,r12
    2414:	mov    rbx,QWORD PTR [rsp+0x30]
    2419:	mov    r12,QWORD PTR [rsp+0x38]
    241e:	mov    r13,QWORD PTR [rsp+0x40]
    2423:	mov    r14,QWORD PTR [rsp+0x48]
    2428:	add    rsp,0x50
    242c:	mov    rsp,rbp
    242f:	pop    rbp
    2430:	ret
    2431:	add    BYTE PTR [rax],al
    2433:	add    BYTE PTR [rax],al
    2435:	add    BYTE PTR [rax],al
    2437:	add    BYTE PTR [rsi],al
    2439:	add    BYTE PTR [rax],al
    243b:	add    BYTE PTR [rax],al
    243d:	add    BYTE PTR [rax],al
	...

0000000000002440 <botlish_entry_21: ht_delete<HashTable, str>>:
    2440:	push   rbp
    2441:	mov    rbp,rsp
    2444:	mov    rsi,QWORD PTR [rdx]
    2447:	mov    rdx,QWORD PTR [rdx+0x8]
    244b:	call   2450 <botlish_entry_21+0x10>
			244c: R_X86_64_PLT32	botlish_fn_21-0x4 ; ht_delete<HashTable, str>
    2450:	mov    rsp,rbp
    2453:	pop    rbp
    2454:	ret
    2455:	add    BYTE PTR [rax],al
	...

0000000000002458 <botlish_fn_22: sample_checks<generic>>:
    2458:	push   rbp
    2459:	mov    rbp,rsp
    245c:	sub    rsp,0xa0
    2463:	mov    QWORD PTR [rsp+0x70],rbx
    2468:	mov    QWORD PTR [rsp+0x78],r12
    246d:	mov    QWORD PTR [rsp+0x80],r13
    2475:	mov    QWORD PTR [rsp+0x88],r14
    247d:	mov    QWORD PTR [rsp+0x90],r15
    2485:	mov    r13,rdi
    2488:	mov    QWORD PTR [rsp],0x0
    2490:	mov    QWORD PTR [rsp+0x8],0x0
    2499:	mov    QWORD PTR [rsp+0x10],0x0
    24a2:	mov    QWORD PTR [rsp+0x18],0x0
    24ab:	mov    QWORD PTR [rsp+0x20],0x0
    24b4:	mov    QWORD PTR [rsp+0x28],0x0
    24bd:	mov    rdi,r13
    24c0:	call   24c5 <botlish_fn_22+0x6d>
			24c1: R_X86_64_PLT32	botlish_fn_3-0x4 ; ht_new<generic>
    24c5:	test   rax,rax
    24c8:	je     2724 <botlish_fn_22+0x2cc>
    24ce:	mov    QWORD PTR [rsp],rax
    24d2:	mov    rsi,rax
    24d5:	mov    rdi,r13
    24d8:	mov    rax,QWORD PTR [rdi+0x10]
    24dc:	mov    rdx,QWORD PTR [rax+0x18]
    24e0:	mov    QWORD PTR [rsp+0x8],rdx
    24e5:	mov    rax,QWORD PTR [rdi+0x10]
    24e9:	mov    rcx,QWORD PTR [rax+0x20]
    24ed:	mov    QWORD PTR [rsp+0x10],rcx
    24f2:	call   24f7 <botlish_fn_22+0x9f>
			24f3: R_X86_64_PLT32	botlish_fn_20-0x4 ; ht_set<HashTable, str, str>
    24f7:	test   rax,rax
    24fa:	je     2724 <botlish_fn_22+0x2cc>
    2500:	mov    QWORD PTR [rsp],rax
    2504:	mov    rdi,r13
    2507:	mov    rsi,QWORD PTR [rdi+0x10]
    250b:	mov    rdx,QWORD PTR [rsi+0x28]
    250f:	mov    QWORD PTR [rsp+0x8],rdx
    2514:	mov    rsi,QWORD PTR [rdi+0x10]
    2518:	mov    rcx,QWORD PTR [rsi+0x30]
    251c:	mov    QWORD PTR [rsp+0x10],rcx
    2521:	mov    rsi,rax
    2524:	call   2529 <botlish_fn_22+0xd1>
			2525: R_X86_64_PLT32	botlish_fn_20-0x4 ; ht_set<HashTable, str, str>
    2529:	test   rax,rax
    252c:	je     2724 <botlish_fn_22+0x2cc>
    2532:	mov    QWORD PTR [rsp],rax
    2536:	mov    rsi,rax
    2539:	mov    rdi,r13
    253c:	mov    r11,QWORD PTR [rdi+0x10]
    2540:	mov    rdx,QWORD PTR [r11+0x18]
    2544:	mov    QWORD PTR [rsp+0x8],rdx
    2549:	mov    rax,QWORD PTR [rdi+0x10]
    254d:	mov    rcx,QWORD PTR [rax+0x38]
    2551:	mov    QWORD PTR [rsp+0x10],rcx
    2556:	call   255b <botlish_fn_22+0x103>
			2557: R_X86_64_PLT32	botlish_fn_20-0x4 ; ht_set<HashTable, str, str>
    255b:	test   rax,rax
    255e:	je     2724 <botlish_fn_22+0x2cc>
    2564:	mov    QWORD PTR [rsp],rax
    2568:	mov    rdi,r13
    256b:	mov    r14,rax
    256e:	mov    rax,QWORD PTR [rdi+0x10]
    2572:	mov    rdx,QWORD PTR [rax+0x28]
    2576:	mov    QWORD PTR [rsp+0x8],rdx
    257b:	mov    rsi,r14
    257e:	call   2583 <botlish_fn_22+0x12b>
			257f: R_X86_64_PLT32	botlish_fn_12-0x4 ; ht_contains<HashTable, str>
    2583:	test   rax,rax
    2586:	je     2724 <botlish_fn_22+0x2cc>
    258c:	mov    QWORD PTR [rsp+0x8],rax
    2591:	mov    rdi,r13
    2594:	mov    r15,rax
    2597:	mov    rax,QWORD PTR [rdi+0x10]
    259b:	mov    rdx,QWORD PTR [rax+0x28]
    259f:	mov    QWORD PTR [rsp+0x10],rdx
    25a4:	mov    rsi,r14
    25a7:	call   25ac <botlish_fn_22+0x154>
			25a8: R_X86_64_PLT32	botlish_fn_21-0x4 ; ht_delete<HashTable, str>
    25ac:	mov    rcx,rax
    25af:	mov    r14,rax
    25b2:	test   rax,rcx
    25b5:	je     2724 <botlish_fn_22+0x2cc>
    25bb:	mov    rax,r14
    25be:	mov    QWORD PTR [rsp],rax
    25c2:	mov    rdi,r13
    25c5:	mov    rax,QWORD PTR [rdi+0x10]
    25c9:	mov    rdx,QWORD PTR [rax+0x18]
    25cd:	mov    QWORD PTR [rsp+0x10],rdx
    25d2:	mov    rsi,r14
    25d5:	call   25da <botlish_fn_22+0x182>
			25d6: R_X86_64_PLT32	botlish_fn_11-0x4 ; ht_get<HashTable, str>
    25da:	test   rax,rax
    25dd:	je     2724 <botlish_fn_22+0x2cc>
    25e3:	mov    rdi,r13
    25e6:	mov    rcx,QWORD PTR [rdi+0x10]
    25ea:	mov    rdx,QWORD PTR [rcx+0x38]
    25ee:	mov    rcx,rax
    25f1:	and    rcx,rdx
    25f4:	mov    rsi,rax
    25f7:	test   rcx,0x1
    25fe:	jne    261a <botlish_fn_22+0x1c2>
    2604:	mov    rdi,r13
    2607:	call   260c <botlish_fn_22+0x1b4>
			2608: R_X86_64_PLT32	rt_value_eq-0x4
    260c:	test   rax,rax
    260f:	je     2724 <botlish_fn_22+0x2cc>
    2615:	jmp    262a <botlish_fn_22+0x1d2>
    261a:	mov    eax,0x2
    261f:	cmp    rsi,rdx
    2622:	cmove  rax,QWORD PTR [rip+0x15e]        # 2788 <botlish_fn_22+0x330>
    262a:	mov    QWORD PTR [rsp+0x10],rax
    262f:	mov    rdi,r13
    2632:	mov    QWORD PTR [rsp+0x60],rax
    2637:	mov    rax,QWORD PTR [rdi+0x10]
    263b:	mov    rdx,QWORD PTR [rax+0x28]
    263f:	mov    QWORD PTR [rsp+0x18],rdx
    2644:	mov    rsi,r14
    2647:	call   264c <botlish_fn_22+0x1f4>
			2648: R_X86_64_PLT32	botlish_fn_12-0x4 ; ht_contains<HashTable, str>
    264c:	mov    rbx,rax
    264f:	test   rbx,rbx
    2652:	je     2724 <botlish_fn_22+0x2cc>
    2658:	mov    QWORD PTR [rsp+0x18],rbx
    265d:	mov    rdi,r13
    2660:	mov    rax,QWORD PTR [rdi+0x10]
    2664:	mov    rdx,QWORD PTR [rax+0x40]
    2668:	mov    QWORD PTR [rsp+0x20],rdx
    266d:	mov    rsi,r14
    2670:	call   2675 <botlish_fn_22+0x21d>
			2671: R_X86_64_PLT32	botlish_fn_12-0x4 ; ht_contains<HashTable, str>
    2675:	mov    r12,rax
    2678:	test   r12,r12
    267b:	je     2724 <botlish_fn_22+0x2cc>
    2681:	mov    QWORD PTR [rsp+0x20],r12
    2686:	mov    rdi,r13
    2689:	mov    rax,QWORD PTR [rdi+0x10]
    268d:	mov    rdx,QWORD PTR [rax+0x40]
    2691:	mov    QWORD PTR [rsp+0x28],rdx
    2696:	mov    rsi,r14
    2699:	call   269e <botlish_fn_22+0x246>
			269a: R_X86_64_PLT32	botlish_fn_11-0x4 ; ht_get<HashTable, str>
    269e:	test   rax,rax
    26a1:	mov    rsi,rax
    26a4:	je     2724 <botlish_fn_22+0x2cc>
    26aa:	mov    edx,0xa
    26af:	mov    rdi,r13
    26b2:	call   26b7 <botlish_fn_22+0x25f>
			26b3: R_X86_64_PLT32	rt_value_eq-0x4
    26b7:	test   rax,rax
    26ba:	je     2724 <botlish_fn_22+0x2cc>
    26c0:	mov    QWORD PTR [rsp],rax
    26c4:	mov    rsi,r14
    26c7:	mov    r14,rax
    26ca:	mov    rdi,r13
    26cd:	call   26d2 <botlish_fn_22+0x27a>
			26ce: R_X86_64_PLT32	botlish_fn_4-0x4 ; ht_size<HashTable>
    26d2:	test   rax,rax
    26d5:	je     2724 <botlish_fn_22+0x2cc>
    26db:	mov    QWORD PTR [rsp+0x28],rax
    26e0:	lea    rdx,[rsp+0x30]
    26e5:	mov    r9,QWORD PTR [rsp+0x60]
    26ea:	mov    QWORD PTR [rsp+0x30],r9
    26ef:	mov    rsi,r15
    26f2:	mov    QWORD PTR [rsp+0x38],rsi
    26f7:	mov    QWORD PTR [rsp+0x40],rbx
    26fc:	mov    QWORD PTR [rsp+0x48],r12
    2701:	mov    rcx,r14
    2704:	mov    QWORD PTR [rsp+0x50],rcx
    2709:	mov    QWORD PTR [rsp+0x58],rax
    270e:	mov    esi,0x6
    2713:	mov    rdi,r13
    2716:	call   271b <botlish_fn_22+0x2c3>
			2717: R_X86_64_PLT32	rt_list_new-0x4
    271b:	test   rax,rax
    271e:	jne    2755 <botlish_fn_22+0x2fd>
    2724:	xor    rax,rax
    2727:	mov    rbx,QWORD PTR [rsp+0x70]
    272c:	mov    r12,QWORD PTR [rsp+0x78]
    2731:	mov    r13,QWORD PTR [rsp+0x80]
    2739:	mov    r14,QWORD PTR [rsp+0x88]
    2741:	mov    r15,QWORD PTR [rsp+0x90]
    2749:	add    rsp,0xa0
    2750:	mov    rsp,rbp
    2753:	pop    rbp
    2754:	ret
    2755:	mov    rbx,QWORD PTR [rsp+0x70]
    275a:	mov    r12,QWORD PTR [rsp+0x78]
    275f:	mov    r13,QWORD PTR [rsp+0x80]
    2767:	mov    r14,QWORD PTR [rsp+0x88]
    276f:	mov    r15,QWORD PTR [rsp+0x90]
    2777:	add    rsp,0xa0
    277e:	mov    rsp,rbp
    2781:	pop    rbp
    2782:	ret
    2783:	add    BYTE PTR [rax],al
    2785:	add    BYTE PTR [rax],al
    2787:	add    BYTE PTR [rsi],al
    2789:	add    BYTE PTR [rax],al
    278b:	add    BYTE PTR [rax],al
    278d:	add    BYTE PTR [rax],al
	...

0000000000002790 <botlish_entry_22: sample_checks<generic>>:
    2790:	push   rbp
    2791:	mov    rbp,rsp
    2794:	call   2799 <botlish_entry_22+0x9>
			2795: R_X86_64_PLT32	botlish_fn_22-0x4 ; sample_checks<generic>
    2799:	mov    rsp,rbp
    279c:	pop    rbp
    279d:	ret

000000000000279e <botlish_fn_23: sample<generic>>:
    279e:	push   rbp
    279f:	mov    rbp,rsp
    27a2:	sub    rsp,0x10
    27a6:	mov    QWORD PTR [rsp],r12
    27aa:	mov    r12,rdi
    27ad:	mov    rdi,r12
    27b0:	call   27b5 <botlish_fn_23+0x17>
			27b1: R_X86_64_PLT32	botlish_fn_22-0x4 ; sample_checks<generic>
    27b5:	test   rax,rax
    27b8:	jne    2801 <botlish_fn_23+0x63>
    27be:	mov    rdi,r12
    27c1:	call   27c6 <botlish_fn_23+0x28>
			27c2: R_X86_64_PLT32	rt_declared_error-0x4
    27c6:	cmp    rax,0x40000001
    27cc:	jne    27f1 <botlish_fn_23+0x53>
    27d2:	mov    rdi,r12
    27d5:	call   27da <botlish_fn_23+0x3c>
			27d6: R_X86_64_PLT32	rt_clear_declared_error-0x4
    27da:	xor    rdx,rdx
    27dd:	mov    rdi,r12
    27e0:	mov    rsi,rdx
    27e3:	call   27e8 <botlish_fn_23+0x4a>
			27e4: R_X86_64_PLT32	rt_list_new-0x4
    27e8:	test   rax,rax
    27eb:	jne    2801 <botlish_fn_23+0x63>
    27f1:	xor    rax,rax
    27f4:	mov    r12,QWORD PTR [rsp]
    27f8:	add    rsp,0x10
    27fc:	mov    rsp,rbp
    27ff:	pop    rbp
    2800:	ret
    2801:	mov    r12,QWORD PTR [rsp]
    2805:	add    rsp,0x10
    2809:	mov    rsp,rbp
    280c:	pop    rbp
    280d:	ret

000000000000280e <botlish_entry_23: sample<generic>>:
    280e:	push   rbp
    280f:	mov    rbp,rsp
    2812:	call   2817 <botlish_entry_23+0x9>
			2813: R_X86_64_PLT32	botlish_fn_23-0x4 ; sample<generic>
    2817:	mov    rsp,rbp
    281a:	pop    rbp
    281b:	ret
