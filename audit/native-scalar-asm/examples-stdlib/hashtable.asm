; source:  examples/stdlib/hashtable.bot
; backend: Cranelift (specialize=1), native::object
; object:  ELF64 x86-64, unlinked (Botlish-generated code only; runtime
;          helpers are unresolved imports, so their bodies are not present)
; format:  objdump -dr --no-show-raw-insn -M intel
; total machine code bytes: 10838  (per function: 45 427 385 70 69 69 46 182 178 628 1032 341 261 388 407 616 666 801 673 920 700 925 862 147)
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
     78c:	sub    rsp,0x70
     790:	mov    QWORD PTR [rsp+0x40],rbx
     795:	mov    QWORD PTR [rsp+0x48],r12
     79a:	mov    QWORD PTR [rsp+0x50],r13
     79f:	mov    QWORD PTR [rsp+0x58],r14
     7a4:	mov    QWORD PTR [rsp+0x60],r15
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
     7d7:	mov    QWORD PTR [rsp+0x20],rdx
     7dc:	or     rbx,0x1
     7e0:	mov    QWORD PTR [rsp+0x18],rbx
     7e5:	mov    rdx,rbx
     7e8:	mov    rdi,r14
     7eb:	call   7f0 <botlish_fn_10+0x68>
			7ec: R_X86_64_PLT32	rt_mutarray_get-0x4
     7f0:	mov    rcx,rax
     7f3:	mov    QWORD PTR [rsp+0x28],rax
     7f8:	mov    QWORD PTR [rsp+0x30],rbx
     7fd:	test   rax,rcx
     800:	je     a38 <botlish_fn_10+0x2b0>
     806:	mov    rax,QWORD PTR [rsp+0x28]
     80b:	test   rax,0x1
     811:	jne    83e <botlish_fn_10+0xb6>
     817:	mov    edx,0x1
     81c:	mov    rsi,QWORD PTR [rsp+0x28]
     821:	mov    rdi,r14
     824:	call   829 <botlish_fn_10+0xa1>
			825: R_X86_64_PLT32	rt_int_cmp-0x4
     829:	mov    ecx,0x2
     82e:	test   rax,rax
     831:	cmove  rcx,QWORD PTR [rip+0x2f7]        # b30 <botlish_fn_10+0x3a8>
     839:	jmp    854 <botlish_fn_10+0xcc>
     83e:	mov    ecx,0x2
     843:	mov    rax,QWORD PTR [rsp+0x28]
     848:	cmp    rax,0x1
     84c:	cmove  rcx,QWORD PTR [rip+0x2dc]        # b30 <botlish_fn_10+0x3a8>
     854:	cmp    rcx,0x6
     858:	je     a8a <botlish_fn_10+0x302>
     85e:	mov    rax,QWORD PTR [rsp+0x28]
     863:	test   rax,0x1
     869:	jne    896 <botlish_fn_10+0x10e>
     86f:	mov    edx,0x3
     874:	mov    rsi,QWORD PTR [rsp+0x28]
     879:	mov    rdi,r14
     87c:	call   881 <botlish_fn_10+0xf9>
			87d: R_X86_64_PLT32	rt_int_cmp-0x4
     881:	mov    ecx,0x2
     886:	test   rax,rax
     889:	cmove  rcx,QWORD PTR [rip+0x29f]        # b30 <botlish_fn_10+0x3a8>
     891:	jmp    8ac <botlish_fn_10+0x124>
     896:	mov    ecx,0x2
     89b:	mov    rax,QWORD PTR [rsp+0x28]
     8a0:	cmp    rax,0x3
     8a4:	cmove  rcx,QWORD PTR [rip+0x284]        # b30 <botlish_fn_10+0x3a8>
     8ac:	cmp    rcx,0x6
     8b0:	je     8c3 <botlish_fn_10+0x13b>
     8b6:	mov    rax,QWORD PTR [rsp+0x28]
     8bb:	mov    rbx,r15
     8be:	jmp    933 <botlish_fn_10+0x1ab>
     8c3:	mov    rax,QWORD PTR [r12+0x18]
     8c8:	mov    rsi,QWORD PTR [rax+0x8]
     8cc:	mov    rdx,QWORD PTR [rsp+0x30]
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
     92e:	mov    rax,QWORD PTR [rsp+0x28]
     933:	test   rax,0x1
     939:	mov    QWORD PTR [rsp+0x28],rax
     93e:	jne    96b <botlish_fn_10+0x1e3>
     944:	mov    edx,0x5
     949:	mov    rsi,QWORD PTR [rsp+0x28]
     94e:	mov    rdi,r14
     951:	call   956 <botlish_fn_10+0x1ce>
			952: R_X86_64_PLT32	rt_int_cmp-0x4
     956:	mov    ecx,0x2
     95b:	test   rax,rax
     95e:	cmove  rcx,QWORD PTR [rip+0x1ca]        # b30 <botlish_fn_10+0x3a8>
     966:	jmp    981 <botlish_fn_10+0x1f9>
     96b:	mov    rsi,QWORD PTR [rsp+0x28]
     970:	mov    ecx,0x2
     975:	cmp    rsi,0x5
     979:	cmove  rcx,QWORD PTR [rip+0x1af]        # b30 <botlish_fn_10+0x3a8>
     981:	cmp    rcx,0x6
     985:	je     995 <botlish_fn_10+0x20d>
     98b:	mov    rdx,QWORD PTR [rsp+0x20]
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
     9e7:	mov    rdx,QWORD PTR [rsp+0x20]
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
     a1f:	mov    rdx,QWORD PTR [rsp+0x20]
     a24:	mov    rsi,r12
     a27:	mov    rdi,r14
     a2a:	call   a2f <botlish_fn_10+0x2a7>
			a2b: R_X86_64_PLT32	botlish_fn_8-0x4 ; ht_probe_next<HashTable, int>
     a2f:	test   rdx,rdx
     a32:	jne    a5d <botlish_fn_10+0x2d5>
     a38:	xor    rax,rax
     a3b:	mov    rbx,QWORD PTR [rsp+0x40]
     a40:	mov    r12,QWORD PTR [rsp+0x48]
     a45:	mov    r13,QWORD PTR [rsp+0x50]
     a4a:	mov    r14,QWORD PTR [rsp+0x58]
     a4f:	mov    r15,QWORD PTR [rsp+0x60]
     a54:	add    rsp,0x70
     a58:	mov    rsp,rbp
     a5b:	pop    rbp
     a5c:	ret
     a5d:	mov    QWORD PTR [rsp],r12
     a61:	mov    QWORD PTR [rsp+0x8],rbx
     a66:	mov    rsi,QWORD PTR [rsp+0x30]
     a6b:	mov    QWORD PTR [rsp+0x10],rsi
     a70:	mov    rdx,rax
     a73:	mov    r13,QWORD PTR [rsp+0x30]
     a78:	mov    r15,rbx
     a7b:	jmp    7c9 <botlish_fn_10+0x41>
     a80:	mov    rax,QWORD PTR [rsp+0x30]
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
     ade:	mov    rax,QWORD PTR [rsp+0x30]
     ae3:	mov    rax,QWORD PTR [rsp+0x30]
     ae8:	mov    rbx,QWORD PTR [rsp+0x40]
     aed:	mov    r12,QWORD PTR [rsp+0x48]
     af2:	mov    r13,QWORD PTR [rsp+0x50]
     af7:	mov    r14,QWORD PTR [rsp+0x58]
     afc:	mov    r15,QWORD PTR [rsp+0x60]
     b01:	add    rsp,0x70
     b05:	mov    rsp,rbp
     b08:	pop    rbp
     b09:	ret
     b0a:	mov    rax,r13
     b0d:	mov    rbx,QWORD PTR [rsp+0x40]
     b12:	mov    r12,QWORD PTR [rsp+0x48]
     b17:	mov    r13,QWORD PTR [rsp+0x50]
     b1c:	mov    r14,QWORD PTR [rsp+0x58]
     b21:	mov    r15,QWORD PTR [rsp+0x60]
     b26:	add    rsp,0x70
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
    12cc:	sub    rsp,0x100
    12d3:	mov    QWORD PTR [rsp+0xd0],rbx
    12db:	mov    QWORD PTR [rsp+0xd8],r12
    12e3:	mov    QWORD PTR [rsp+0xe0],r13
    12eb:	mov    QWORD PTR [rsp+0xe8],r14
    12f3:	mov    QWORD PTR [rsp+0xf0],r15
    12fb:	mov    QWORD PTR [rsp+0x98],rdi
    1303:	mov    QWORD PTR [rsp+0x20],0x0
    130c:	mov    QWORD PTR [rsp+0x28],0x0
    1315:	mov    QWORD PTR [rsp+0x30],0x0
    131e:	mov    QWORD PTR [rsp+0x38],0x0
    1327:	mov    QWORD PTR [rsp+0x40],0x0
    1330:	mov    QWORD PTR [rsp+0x48],0x0
    1339:	mov    QWORD PTR [rsp+0x50],0x0
    1342:	mov    QWORD PTR [rsp+0x58],0x0
    134b:	mov    QWORD PTR [rsp+0x10],rsi
    1350:	mov    r14,rsi
    1353:	mov    QWORD PTR [rsp+0x18],rdx
    1358:	mov    QWORD PTR [rsp+0xa0],rdx
    1360:	lea    rdx,[rsp+0x60]
    1365:	mov    rsi,QWORD PTR [rsp+0xa0]
    136d:	mov    rdi,QWORD PTR [rsp+0x98]
    1375:	call   137a <botlish_fn_16+0xb2>
			1376: R_X86_64_PLT32	botlish_fn_2-0x4 ; ht_alloc<int>
    137a:	test   rax,rax
    137d:	je     14d4 <botlish_fn_16+0x20c>
    1383:	mov    QWORD PTR [rsp+0x20],rax
    1388:	mov    QWORD PTR [rsp+0xc0],rax
    1390:	mov    rbx,QWORD PTR [rsp+0x60]
    1395:	mov    QWORD PTR [rsp+0x28],rbx
    139a:	mov    r12,QWORD PTR [rsp+0x68]
    139f:	mov    QWORD PTR [rsp+0x30],r12
    13a4:	mov    r13,QWORD PTR [rsp+0x70]
    13a9:	mov    QWORD PTR [rsp+0x38],r13
    13ae:	mov    rsi,r14
    13b1:	mov    rdi,QWORD PTR [rsp+0x98]
    13b9:	call   13be <botlish_fn_16+0xf6>
			13ba: R_X86_64_PLT32	botlish_fn_4-0x4 ; ht_size<HashTable>
    13be:	test   rax,rax
    13c1:	mov    rcx,rax
    13c4:	je     14d4 <botlish_fn_16+0x20c>
    13ca:	mov    edx,0x1
    13cf:	mov    rsi,r13
    13d2:	mov    rdi,QWORD PTR [rsp+0x98]
    13da:	call   13df <botlish_fn_16+0x117>
			13db: R_X86_64_PLT32	rt_mutarray_set-0x4
    13df:	test   rax,rax
    13e2:	je     14d4 <botlish_fn_16+0x20c>
    13e8:	mov    rsi,r14
    13eb:	mov    rax,QWORD PTR [rsi+0x18]
    13ef:	mov    rcx,QWORD PTR [rax]
    13f2:	mov    QWORD PTR [rsp+0x40],rcx
    13f7:	mov    QWORD PTR [rsp+0xb8],rcx
    13ff:	mov    rax,QWORD PTR [rsi+0x18]
    1403:	mov    r15,QWORD PTR [rax+0x8]
    1407:	mov    QWORD PTR [rsp+0x48],r15
    140c:	mov    rax,QWORD PTR [rsi+0x18]
    1410:	mov    r14,QWORD PTR [rax+0x10]
    1414:	mov    QWORD PTR [rsp+0x50],r14
    1419:	mov    r8d,0x1
    141f:	mov    QWORD PTR [rsp+0xb0],r8
    1427:	mov    QWORD PTR [rsp+0x58],0x1
    1430:	mov    rdi,QWORD PTR [rsp+0x98]
    1438:	call   143d <botlish_fn_16+0x175>
			1439: R_X86_64_PLT32	botlish_fn_6-0x4 ; ht_capacity<HashTable>
    143d:	mov    QWORD PTR [rsp+0xa8],rax
    1445:	lea    rcx,[rsp+0x78]
    144a:	mov    rax,QWORD PTR [rsp+0xc0]
    1452:	mov    QWORD PTR [rsp+0x78],rax
    1457:	mov    QWORD PTR [rsp+0x80],rbx
    145f:	mov    QWORD PTR [rsp+0x88],r12
    1467:	mov    QWORD PTR [rsp+0x90],r13
    146f:	xor    rsi,rsi
    1472:	mov    edx,0x4
    1477:	mov    rdi,QWORD PTR [rsp+0x98]
    147f:	call   1484 <botlish_fn_16+0x1bc>
			1480: R_X86_64_PLT32	rt_struct_new-0x4
    1484:	mov    QWORD PTR [rsp+0x10],rax
    1489:	mov    rcx,QWORD PTR [rsp+0xa8]
    1491:	mov    r9,rcx
    1494:	sar    r9,1
    1497:	mov    QWORD PTR [rsp],rax
    149b:	mov    rdx,QWORD PTR [rsp+0xa0]
    14a3:	mov    QWORD PTR [rsp+0x8],rdx
    14a8:	mov    rcx,r14
    14ab:	mov    rdx,r15
    14ae:	mov    rsi,QWORD PTR [rsp+0xb8]
    14b6:	mov    rdi,QWORD PTR [rsp+0x98]
    14be:	mov    r8,QWORD PTR [rsp+0xb0]
    14c6:	call   14cb <botlish_fn_16+0x203>
			14c7: R_X86_64_PLT32	botlish_fn_15-0x4 ; ht_rehash_scan<mutarray, mutarray, mutarray, int, int, HashTable, int>
    14cb:	test   rax,rax
    14ce:	jne    150b <botlish_fn_16+0x243>
    14d4:	xor    rax,rax
    14d7:	mov    rbx,QWORD PTR [rsp+0xd0]
    14df:	mov    r12,QWORD PTR [rsp+0xd8]
    14e7:	mov    r13,QWORD PTR [rsp+0xe0]
    14ef:	mov    r14,QWORD PTR [rsp+0xe8]
    14f7:	mov    r15,QWORD PTR [rsp+0xf0]
    14ff:	add    rsp,0x100
    1506:	mov    rsp,rbp
    1509:	pop    rbp
    150a:	ret
    150b:	mov    rbx,QWORD PTR [rsp+0xd0]
    1513:	mov    r12,QWORD PTR [rsp+0xd8]
    151b:	mov    r13,QWORD PTR [rsp+0xe0]
    1523:	mov    r14,QWORD PTR [rsp+0xe8]
    152b:	mov    r15,QWORD PTR [rsp+0xf0]
    1533:	add    rsp,0x100
    153a:	mov    rsp,rbp
    153d:	pop    rbp
    153e:	ret

000000000000153f <botlish_entry_16: ht_rehash<HashTable, int>>:
    153f:	push   rbp
    1540:	mov    rbp,rsp
    1543:	mov    rsi,QWORD PTR [rdx]
    1546:	mov    rdx,QWORD PTR [rdx+0x8]
    154a:	call   154f <botlish_entry_16+0x10>
			154b: R_X86_64_PLT32	botlish_fn_16-0x4 ; ht_rehash<HashTable, int>
    154f:	mov    rsp,rbp
    1552:	pop    rbp
    1553:	ret
    1554:	add    BYTE PTR [rax],al
	...

0000000000001558 <botlish_fn_17: ht_should_grow<HashTable>>:
    1558:	push   rbp
    1559:	mov    rbp,rsp
    155c:	sub    rsp,0x40
    1560:	mov    QWORD PTR [rsp+0x20],rbx
    1565:	mov    QWORD PTR [rsp+0x28],r12
    156a:	mov    QWORD PTR [rsp+0x30],r13
    156f:	mov    rbx,rdi
    1572:	mov    QWORD PTR [rsp],rsi
    1576:	mov    r12,rsi
    1579:	mov    rsi,r12
    157c:	mov    rdi,rbx
    157f:	call   1584 <botlish_fn_17+0x2c>
			1580: R_X86_64_PLT32	botlish_fn_4-0x4 ; ht_size<HashTable>
    1584:	mov    rcx,rax
    1587:	mov    r13,rax
    158a:	test   rax,rcx
    158d:	je     1664 <botlish_fn_17+0x10c>
    1593:	mov    rax,r13
    1596:	mov    QWORD PTR [rsp+0x8],rax
    159b:	mov    rsi,r12
    159e:	mov    rdi,rbx
    15a1:	call   15a6 <botlish_fn_17+0x4e>
			15a2: R_X86_64_PLT32	botlish_fn_5-0x4 ; ht_tombstones<HashTable>
    15a6:	mov    rcx,rax
    15a9:	test   rcx,rcx
    15ac:	je     1664 <botlish_fn_17+0x10c>
    15b2:	mov    QWORD PTR [rsp+0x10],rcx
    15b7:	mov    edx,0x1
    15bc:	mov    rax,r13
    15bf:	test   rax,0x1
    15c5:	jne    15e8 <botlish_fn_17+0x90>
    15cb:	xor    edx,edx
    15cd:	mov    rax,r13
    15d0:	test   rax,0x7
    15d6:	jne    15e8 <botlish_fn_17+0x90>
    15dc:	mov    rax,r13
    15df:	movzx  rax,BYTE PTR [rax]
    15e3:	cmp    al,0x1
    15e5:	sete   dl
    15e8:	test   dl,dl
    15ea:	jne    160a <botlish_fn_17+0xb2>
    15f0:	mov    rdi,rbx
    15f3:	mov    rax,QWORD PTR [rdi+0x10]
    15f7:	mov    rcx,QWORD PTR [rax]
    15fa:	xor    rdx,rdx
    15fd:	mov    rsi,r13
    1600:	call   1605 <botlish_fn_17+0xad>
			1601: R_X86_64_PLT32	rt_type_error-0x4
    1605:	jmp    1664 <botlish_fn_17+0x10c>
    160a:	mov    eax,0x1
    160f:	test   rcx,0x1
    1616:	je     1624 <botlish_fn_17+0xcc>
    161c:	mov    r8,rcx
    161f:	jmp    1647 <botlish_fn_17+0xef>
    1624:	xor    eax,eax
    1626:	test   rcx,0x7
    162d:	je     163b <botlish_fn_17+0xe3>
    1633:	mov    r8,rcx
    1636:	jmp    1647 <botlish_fn_17+0xef>
    163b:	movzx  rax,BYTE PTR [rcx]
    163f:	mov    r8,rcx
    1642:	cmp    al,0x1
    1644:	sete   al
    1647:	test   al,al
    1649:	jne    167f <botlish_fn_17+0x127>
    164f:	mov    rdi,rbx
    1652:	mov    rax,QWORD PTR [rdi+0x10]
    1656:	mov    rcx,QWORD PTR [rax]
    1659:	xor    rdx,rdx
    165c:	mov    rsi,r8
    165f:	call   1664 <botlish_fn_17+0x10c>
			1660: R_X86_64_PLT32	rt_type_error-0x4
    1664:	xor    rax,rax
    1667:	mov    rbx,QWORD PTR [rsp+0x20]
    166c:	mov    r12,QWORD PTR [rsp+0x28]
    1671:	mov    r13,QWORD PTR [rsp+0x30]
    1676:	add    rsp,0x40
    167a:	mov    rsp,rbp
    167d:	pop    rbp
    167e:	ret
    167f:	mov    rcx,r8
    1682:	mov    rsi,r13
    1685:	mov    rax,rsi
    1688:	and    rax,rcx
    168b:	test   rax,0x1
    1691:	jne    16a2 <botlish_fn_17+0x14a>
    1697:	mov    rdx,r8
    169a:	mov    rsi,r13
    169d:	jmp    16c0 <botlish_fn_17+0x168>
    16a2:	mov    rcx,r8
    16a5:	lea    rax,[rcx-0x1]
    16a9:	mov    rsi,r13
    16ac:	add    rsi,rax
    16af:	seto   al
    16b2:	test   al,al
    16b4:	je     16cb <botlish_fn_17+0x173>
    16ba:	mov    rdx,r8
    16bd:	mov    rsi,r13
    16c0:	mov    rdi,rbx
    16c3:	call   16c8 <botlish_fn_17+0x170>
			16c4: R_X86_64_PLT32	rt_int_add-0x4
    16c8:	mov    rsi,rax
    16cb:	mov    QWORD PTR [rsp+0x8],rsi
    16d0:	mov    QWORD PTR [rsp+0x10],0x3
    16d9:	test   rsi,0x1
    16e0:	je     1703 <botlish_fn_17+0x1ab>
    16e6:	mov    rax,rsi
    16e9:	add    rax,0x2
    16ed:	mov    rcx,rax
    16f0:	seto   al
    16f3:	test   al,al
    16f5:	jne    1703 <botlish_fn_17+0x1ab>
    16fb:	mov    rsi,rcx
    16fe:	jmp    1713 <botlish_fn_17+0x1bb>
    1703:	mov    edx,0x3
    1708:	mov    rdi,rbx
    170b:	call   1710 <botlish_fn_17+0x1b8>
			170c: R_X86_64_PLT32	rt_int_add-0x4
    1710:	mov    rsi,rax
    1713:	mov    QWORD PTR [rsp+0x8],rsi
    1718:	mov    edx,0x7
    171d:	mov    rdi,rdx
    1720:	mov    QWORD PTR [rsp+0x10],0x7
    1729:	test   rsi,0x1
    1730:	jne    173e <botlish_fn_17+0x1e6>
    1736:	mov    rdx,rdi
    1739:	jmp    176a <botlish_fn_17+0x212>
    173e:	mov    rax,rsi
    1741:	sar    rax,1
    1744:	imul   QWORD PTR [rip+0xf5]        # 1840 <botlish_fn_17+0x2e8>
    174b:	seto   cl
    174e:	or     rax,0x1
    1752:	test   cl,cl
    1754:	je     1762 <botlish_fn_17+0x20a>
    175a:	mov    rdx,rdi
    175d:	jmp    176a <botlish_fn_17+0x212>
    1762:	mov    rsi,rax
    1765:	jmp    1775 <botlish_fn_17+0x21d>
    176a:	mov    rdi,rbx
    176d:	call   1772 <botlish_fn_17+0x21a>
			176e: R_X86_64_PLT32	rt_int_mul-0x4
    1772:	mov    rsi,rax
    1775:	mov    QWORD PTR [rsp+0x8],rsi
    177a:	mov    r13,rsi
    177d:	mov    rsi,r12
    1780:	mov    rdi,rbx
    1783:	call   1788 <botlish_fn_17+0x230>
			1784: R_X86_64_PLT32	botlish_fn_6-0x4 ; ht_capacity<HashTable>
    1788:	mov    QWORD PTR [rsp],rax
    178c:	mov    QWORD PTR [rsp+0x10],0x5
    1795:	test   rax,0x1
    179b:	mov    rcx,rax
    179e:	je     17cd <botlish_fn_17+0x275>
    17a4:	mov    rax,rcx
    17a7:	sar    rax,1
    17aa:	imul   QWORD PTR [rip+0x97]        # 1848 <botlish_fn_17+0x2f0>
    17b1:	seto   sil
    17b5:	or     rax,0x1
    17b9:	test   sil,sil
    17bc:	jne    17cd <botlish_fn_17+0x275>
    17c2:	mov    rdx,rax
    17c5:	mov    rsi,r13
    17c8:	jmp    17e3 <botlish_fn_17+0x28b>
    17cd:	mov    edx,0x5
    17d2:	mov    rsi,rcx
    17d5:	mov    rdi,rbx
    17d8:	call   17dd <botlish_fn_17+0x285>
			17d9: R_X86_64_PLT32	rt_int_mul-0x4
    17dd:	mov    rdx,rax
    17e0:	mov    rsi,r13
    17e3:	mov    rdi,rsi
    17e6:	and    rdi,rdx
    17e9:	test   rdi,0x1
    17f0:	jne    1816 <botlish_fn_17+0x2be>
    17f6:	mov    rdi,rbx
    17f9:	call   17fe <botlish_fn_17+0x2a6>
			17fa: R_X86_64_PLT32	rt_int_cmp-0x4
    17fe:	mov    esi,0x2
    1803:	test   rax,rax
    1806:	mov    rax,rsi
    1809:	cmovg  rax,QWORD PTR [rip+0x2f]        # 1840 <botlish_fn_17+0x2e8>
    1811:	jmp    1826 <botlish_fn_17+0x2ce>
    1816:	mov    eax,0x2
    181b:	cmp    rsi,rdx
    181e:	cmovg  rax,QWORD PTR [rip+0x1a]        # 1840 <botlish_fn_17+0x2e8>
    1826:	mov    rbx,QWORD PTR [rsp+0x20]
    182b:	mov    r12,QWORD PTR [rsp+0x28]
    1830:	mov    r13,QWORD PTR [rsp+0x30]
    1835:	add    rsp,0x40
    1839:	mov    rsp,rbp
    183c:	pop    rbp
    183d:	ret
    183e:	add    BYTE PTR [rax],al
    1840:	(bad)
    1841:	add    BYTE PTR [rax],al
    1843:	add    BYTE PTR [rax],al
    1845:	add    BYTE PTR [rax],al
    1847:	add    BYTE PTR [rax+rax*1],al
    184a:	add    BYTE PTR [rax],al
    184c:	add    BYTE PTR [rax],al
	...

0000000000001850 <botlish_entry_17: ht_should_grow<HashTable>>:
    1850:	push   rbp
    1851:	mov    rbp,rsp
    1854:	mov    rsi,QWORD PTR [rdx]
    1857:	call   185c <botlish_entry_17+0xc>
			1858: R_X86_64_PLT32	botlish_fn_17-0x4 ; ht_should_grow<HashTable>
    185c:	mov    rsp,rbp
    185f:	pop    rbp
    1860:	ret
    1861:	add    BYTE PTR [rax],al
    1863:	add    BYTE PTR [rax],al
    1865:	add    BYTE PTR [rax],al
	...

0000000000001868 <botlish_fn_18: ht_grow_or_clean<HashTable>>:
    1868:	push   rbp
    1869:	mov    rbp,rsp
    186c:	sub    rsp,0x40
    1870:	mov    QWORD PTR [rsp+0x20],rbx
    1875:	mov    QWORD PTR [rsp+0x28],r12
    187a:	mov    QWORD PTR [rsp+0x30],r13
    187f:	mov    rbx,rdi
    1882:	mov    QWORD PTR [rsp+0x10],0x0
    188b:	mov    QWORD PTR [rsp],rsi
    188f:	mov    r12,rsi
    1892:	mov    rsi,r12
    1895:	mov    rdi,rbx
    1898:	call   189d <botlish_fn_18+0x35>
			1899: R_X86_64_PLT32	botlish_fn_5-0x4 ; ht_tombstones<HashTable>
    189d:	test   rax,rax
    18a0:	mov    r13,rax
    18a3:	je     1a91 <botlish_fn_18+0x229>
    18a9:	mov    rsi,r12
    18ac:	mov    rdi,rbx
    18af:	call   18b4 <botlish_fn_18+0x4c>
			18b0: R_X86_64_PLT32	botlish_fn_4-0x4 ; ht_size<HashTable>
    18b4:	mov    r11,rax
    18b7:	test   r11,r11
    18ba:	je     1a91 <botlish_fn_18+0x229>
    18c0:	mov    ecx,0x1
    18c5:	mov    rax,r13
    18c8:	test   rax,0x1
    18ce:	je     18dc <botlish_fn_18+0x74>
    18d4:	mov    r13,rax
    18d7:	jmp    1900 <botlish_fn_18+0x98>
    18dc:	xor    ecx,ecx
    18de:	test   rax,0x7
    18e4:	je     18f2 <botlish_fn_18+0x8a>
    18ea:	mov    r13,rax
    18ed:	jmp    1900 <botlish_fn_18+0x98>
    18f2:	movzx  rcx,BYTE PTR [rax]
    18f6:	mov    r13,rax
    18f9:	rex cmp cl,0x1
    18fd:	sete   cl
    1900:	test   cl,cl
    1902:	jne    1923 <botlish_fn_18+0xbb>
    1908:	mov    rdi,rbx
    190b:	mov    rsi,QWORD PTR [rdi+0x10]
    190f:	mov    rcx,QWORD PTR [rsi+0x8]
    1913:	xor    rdx,rdx
    1916:	mov    rsi,r13
    1919:	call   191e <botlish_fn_18+0xb6>
			191a: R_X86_64_PLT32	rt_type_error-0x4
    191e:	jmp    1a91 <botlish_fn_18+0x229>
    1923:	mov    rsi,r13
    1926:	mov    eax,0x1
    192b:	test   r11,0x1
    1932:	je     1940 <botlish_fn_18+0xd8>
    1938:	mov    r8,r11
    193b:	jmp    1965 <botlish_fn_18+0xfd>
    1940:	xor    eax,eax
    1942:	test   r11,0x7
    1949:	je     1957 <botlish_fn_18+0xef>
    194f:	mov    r8,r11
    1952:	jmp    1965 <botlish_fn_18+0xfd>
    1957:	movzx  r10,BYTE PTR [r11]
    195b:	mov    r8,r11
    195e:	cmp    r10b,0x1
    1962:	sete   al
    1965:	test   al,al
    1967:	jne    1988 <botlish_fn_18+0x120>
    196d:	mov    rdi,rbx
    1970:	mov    rax,QWORD PTR [rdi+0x10]
    1974:	mov    rcx,QWORD PTR [rax+0x8]
    1978:	xor    rdx,rdx
    197b:	mov    rsi,r8
    197e:	call   1983 <botlish_fn_18+0x11b>
			197f: R_X86_64_PLT32	rt_type_error-0x4
    1983:	jmp    1a91 <botlish_fn_18+0x229>
    1988:	mov    r11,r8
    198b:	mov    rax,rsi
    198e:	and    rax,r11
    1991:	test   rax,0x1
    1997:	jne    19bd <botlish_fn_18+0x155>
    199d:	mov    rdx,r8
    19a0:	mov    rdi,rbx
    19a3:	call   19a8 <botlish_fn_18+0x140>
			19a4: R_X86_64_PLT32	rt_int_cmp-0x4
    19a8:	mov    ecx,0x2
    19ad:	test   rax,rax
    19b0:	cmovg  rcx,QWORD PTR [rip+0x110]        # 1ac8 <botlish_fn_18+0x260>
    19b8:	jmp    19d0 <botlish_fn_18+0x168>
    19bd:	mov    ecx,0x2
    19c2:	mov    r11,r8
    19c5:	cmp    rsi,r11
    19c8:	cmovg  rcx,QWORD PTR [rip+0xf8]        # 1ac8 <botlish_fn_18+0x260>
    19d0:	cmp    rcx,0x6
    19d4:	je     1a6a <botlish_fn_18+0x202>
    19da:	mov    rsi,r12
    19dd:	mov    rdi,rbx
    19e0:	call   19e5 <botlish_fn_18+0x17d>
			19e1: R_X86_64_PLT32	botlish_fn_6-0x4 ; ht_capacity<HashTable>
    19e5:	mov    QWORD PTR [rsp+0x8],rax
    19ea:	mov    QWORD PTR [rsp+0x10],0x5
    19f3:	test   rax,0x1
    19f9:	mov    rsi,rax
    19fc:	je     1a29 <botlish_fn_18+0x1c1>
    1a02:	mov    rcx,rsi
    1a05:	mov    rax,rcx
    1a08:	sar    rax,1
    1a0b:	imul   QWORD PTR [rip+0xbe]        # 1ad0 <botlish_fn_18+0x268>
    1a12:	seto   cl
    1a15:	or     rax,0x1
    1a19:	test   cl,cl
    1a1b:	jne    1a29 <botlish_fn_18+0x1c1>
    1a21:	mov    rdx,rax
    1a24:	jmp    1a39 <botlish_fn_18+0x1d1>
    1a29:	mov    edx,0x5
    1a2e:	mov    rdi,rbx
    1a31:	call   1a36 <botlish_fn_18+0x1ce>
			1a32: R_X86_64_PLT32	rt_int_mul-0x4
    1a36:	mov    rdx,rax
    1a39:	mov    QWORD PTR [rsp+0x8],rdx
    1a3e:	mov    rsi,r12
    1a41:	mov    rdi,rbx
    1a44:	call   1a49 <botlish_fn_18+0x1e1>
			1a45: R_X86_64_PLT32	botlish_fn_16-0x4 ; ht_rehash<HashTable, int>
    1a49:	test   rax,rax
    1a4c:	je     1a91 <botlish_fn_18+0x229>
    1a52:	mov    rbx,QWORD PTR [rsp+0x20]
    1a57:	mov    r12,QWORD PTR [rsp+0x28]
    1a5c:	mov    r13,QWORD PTR [rsp+0x30]
    1a61:	add    rsp,0x40
    1a65:	mov    rsp,rbp
    1a68:	pop    rbp
    1a69:	ret
    1a6a:	mov    rsi,r12
    1a6d:	mov    rdi,rbx
    1a70:	call   1a75 <botlish_fn_18+0x20d>
			1a71: R_X86_64_PLT32	botlish_fn_6-0x4 ; ht_capacity<HashTable>
    1a75:	mov    QWORD PTR [rsp+0x8],rax
    1a7a:	mov    rdx,rax
    1a7d:	mov    rsi,r12
    1a80:	mov    rdi,rbx
    1a83:	call   1a88 <botlish_fn_18+0x220>
			1a84: R_X86_64_PLT32	botlish_fn_16-0x4 ; ht_rehash<HashTable, int>
    1a88:	test   rax,rax
    1a8b:	jne    1aac <botlish_fn_18+0x244>
    1a91:	xor    rax,rax
    1a94:	mov    rbx,QWORD PTR [rsp+0x20]
    1a99:	mov    r12,QWORD PTR [rsp+0x28]
    1a9e:	mov    r13,QWORD PTR [rsp+0x30]
    1aa3:	add    rsp,0x40
    1aa7:	mov    rsp,rbp
    1aaa:	pop    rbp
    1aab:	ret
    1aac:	mov    rbx,QWORD PTR [rsp+0x20]
    1ab1:	mov    r12,QWORD PTR [rsp+0x28]
    1ab6:	mov    r13,QWORD PTR [rsp+0x30]
    1abb:	add    rsp,0x40
    1abf:	mov    rsp,rbp
    1ac2:	pop    rbp
    1ac3:	ret
    1ac4:	add    BYTE PTR [rax],al
    1ac6:	add    BYTE PTR [rax],al
    1ac8:	(bad)
    1ac9:	add    BYTE PTR [rax],al
    1acb:	add    BYTE PTR [rax],al
    1acd:	add    BYTE PTR [rax],al
    1acf:	add    BYTE PTR [rax+rax*1],al
    1ad2:	add    BYTE PTR [rax],al
    1ad4:	add    BYTE PTR [rax],al
	...

0000000000001ad8 <botlish_entry_18: ht_grow_or_clean<HashTable>>:
    1ad8:	push   rbp
    1ad9:	mov    rbp,rsp
    1adc:	mov    rsi,QWORD PTR [rdx]
    1adf:	call   1ae4 <botlish_entry_18+0xc>
			1ae0: R_X86_64_PLT32	botlish_fn_18-0x4 ; ht_grow_or_clean<HashTable>
    1ae4:	mov    rsp,rbp
    1ae7:	pop    rbp
    1ae8:	ret
    1ae9:	add    BYTE PTR [rax],al
    1aeb:	add    BYTE PTR [rax],al
    1aed:	add    BYTE PTR [rax],al
	...

0000000000001af0 <botlish_fn_19: ht_place<HashTable, int, str, str>>:
    1af0:	push   rbp
    1af1:	mov    rbp,rsp
    1af4:	sub    rsp,0x70
    1af8:	mov    QWORD PTR [rsp+0x40],rbx
    1afd:	mov    QWORD PTR [rsp+0x48],r12
    1b02:	mov    QWORD PTR [rsp+0x50],r13
    1b07:	mov    QWORD PTR [rsp+0x58],r14
    1b0c:	mov    QWORD PTR [rsp+0x60],r15
    1b11:	mov    r12,rdi
    1b14:	mov    r14,r8
    1b17:	mov    r15,rdx
    1b1a:	mov    QWORD PTR [rsp+0x30],rcx
    1b1f:	mov    QWORD PTR [rsp],rsi
    1b23:	mov    r9,QWORD PTR [rsi+0x18]
    1b27:	mov    r13,rsi
    1b2a:	mov    rsi,QWORD PTR [r9]
    1b2d:	mov    rdx,r15
    1b30:	mov    rdi,r12
    1b33:	call   1b38 <botlish_fn_19+0x48>
			1b34: R_X86_64_PLT32	rt_mutarray_get-0x4
    1b38:	test   rax,rax
    1b3b:	je     1dcf <botlish_fn_19+0x2df>
    1b41:	mov    QWORD PTR [rsp+0x8],rax
    1b46:	mov    rbx,r13
    1b49:	mov    r13,rax
    1b4c:	mov    rax,QWORD PTR [rbx+0x18]
    1b50:	mov    rsi,QWORD PTR [rax]
    1b53:	mov    ecx,0x3
    1b58:	mov    rdx,r15
    1b5b:	mov    rdi,r12
    1b5e:	call   1b63 <botlish_fn_19+0x73>
			1b5f: R_X86_64_PLT32	rt_mutarray_set-0x4
    1b63:	test   rax,rax
    1b66:	je     1dcf <botlish_fn_19+0x2df>
    1b6c:	mov    rax,QWORD PTR [rbx+0x18]
    1b70:	mov    rsi,QWORD PTR [rax+0x8]
    1b74:	mov    rcx,QWORD PTR [rsp+0x30]
    1b79:	mov    rdx,r15
    1b7c:	mov    rdi,r12
    1b7f:	call   1b84 <botlish_fn_19+0x94>
			1b80: R_X86_64_PLT32	rt_mutarray_set-0x4
    1b84:	test   rax,rax
    1b87:	je     1dcf <botlish_fn_19+0x2df>
    1b8d:	mov    rax,QWORD PTR [rbx+0x18]
    1b91:	mov    rsi,QWORD PTR [rax+0x10]
    1b95:	mov    rcx,r14
    1b98:	mov    rdx,r15
    1b9b:	mov    rdi,r12
    1b9e:	call   1ba3 <botlish_fn_19+0xb3>
			1b9f: R_X86_64_PLT32	rt_mutarray_set-0x4
    1ba3:	test   rax,rax
    1ba6:	je     1dcf <botlish_fn_19+0x2df>
    1bac:	mov    rax,QWORD PTR [rbx+0x18]
    1bb0:	mov    rsi,QWORD PTR [rax+0x18]
    1bb4:	mov    QWORD PTR [rsp+0x10],rsi
    1bb9:	mov    r14,rsi
    1bbc:	mov    QWORD PTR [rsp+0x18],0x1
    1bc5:	mov    rsi,rbx
    1bc8:	mov    rdi,r12
    1bcb:	call   1bd0 <botlish_fn_19+0xe0>
			1bcc: R_X86_64_PLT32	botlish_fn_4-0x4 ; ht_size<HashTable>
    1bd0:	test   rax,rax
    1bd3:	je     1dcf <botlish_fn_19+0x2df>
    1bd9:	mov    QWORD PTR [rsp+0x20],rax
    1bde:	mov    QWORD PTR [rsp+0x28],0x3
    1be7:	mov    ecx,0x1
    1bec:	test   rax,0x1
    1bf2:	je     1c00 <botlish_fn_19+0x110>
    1bf8:	mov    rsi,rax
    1bfb:	jmp    1c24 <botlish_fn_19+0x134>
    1c00:	xor    ecx,ecx
    1c02:	test   rax,0x7
    1c08:	je     1c16 <botlish_fn_19+0x126>
    1c0e:	mov    rsi,rax
    1c11:	jmp    1c24 <botlish_fn_19+0x134>
    1c16:	movzx  rcx,BYTE PTR [rax]
    1c1a:	mov    rsi,rax
    1c1d:	rex cmp cl,0x1
    1c21:	sete   cl
    1c24:	test   cl,cl
    1c26:	jne    1c43 <botlish_fn_19+0x153>
    1c2c:	mov    rdi,r12
    1c2f:	mov    rax,QWORD PTR [rdi+0x10]
    1c33:	mov    rcx,QWORD PTR [rax]
    1c36:	xor    rdx,rdx
    1c39:	call   1c3e <botlish_fn_19+0x14e>
			1c3a: R_X86_64_PLT32	rt_type_error-0x4
    1c3e:	jmp    1dcf <botlish_fn_19+0x2df>
    1c43:	test   rsi,0x1
    1c4a:	je     1c62 <botlish_fn_19+0x172>
    1c50:	mov    rcx,rsi
    1c53:	add    rcx,0x2
    1c57:	seto   al
    1c5a:	test   al,al
    1c5c:	je     1c72 <botlish_fn_19+0x182>
    1c62:	mov    edx,0x3
    1c67:	mov    rdi,r12
    1c6a:	call   1c6f <botlish_fn_19+0x17f>
			1c6b: R_X86_64_PLT32	rt_int_add-0x4
    1c6f:	mov    rcx,rax
    1c72:	mov    edx,0x1
    1c77:	mov    rsi,r14
    1c7a:	mov    rdi,r12
    1c7d:	call   1c82 <botlish_fn_19+0x192>
			1c7e: R_X86_64_PLT32	rt_mutarray_set-0x4
    1c82:	test   rax,rax
    1c85:	je     1dcf <botlish_fn_19+0x2df>
    1c8b:	mov    rax,r13
    1c8e:	test   rax,0x1
    1c94:	jne    1cbf <botlish_fn_19+0x1cf>
    1c9a:	mov    edx,0x5
    1c9f:	mov    rsi,r13
    1ca2:	mov    rdi,r12
    1ca5:	call   1caa <botlish_fn_19+0x1ba>
			1ca6: R_X86_64_PLT32	rt_int_cmp-0x4
    1caa:	mov    ecx,0x2
    1caf:	test   rax,rax
    1cb2:	cmove  rcx,QWORD PTR [rip+0x166]        # 1e20 <botlish_fn_19+0x330>
    1cba:	jmp    1cd3 <botlish_fn_19+0x1e3>
    1cbf:	mov    rsi,r13
    1cc2:	mov    ecx,0x2
    1cc7:	cmp    rsi,0x5
    1ccb:	cmove  rcx,QWORD PTR [rip+0x14d]        # 1e20 <botlish_fn_19+0x330>
    1cd3:	cmp    rcx,0x6
    1cd7:	je     1ce5 <botlish_fn_19+0x1f5>
    1cdd:	mov    rax,rbx
    1ce0:	jmp    1df7 <botlish_fn_19+0x307>
    1ce5:	mov    rax,QWORD PTR [rbx+0x18]
    1ce9:	mov    rsi,QWORD PTR [rax+0x18]
    1ced:	mov    QWORD PTR [rsp+0x8],rsi
    1cf2:	mov    r14,rsi
    1cf5:	mov    QWORD PTR [rsp+0x10],0x3
    1cfe:	mov    rsi,rbx
    1d01:	mov    rdi,r12
    1d04:	call   1d09 <botlish_fn_19+0x219>
			1d05: R_X86_64_PLT32	botlish_fn_5-0x4 ; ht_tombstones<HashTable>
    1d09:	mov    r13,rbx
    1d0c:	test   rax,rax
    1d0f:	je     1dcf <botlish_fn_19+0x2df>
    1d15:	mov    QWORD PTR [rsp+0x18],rax
    1d1a:	mov    QWORD PTR [rsp+0x20],0x3
    1d23:	mov    ecx,0x1
    1d28:	test   rax,0x1
    1d2e:	je     1d3c <botlish_fn_19+0x24c>
    1d34:	mov    rsi,rax
    1d37:	jmp    1d60 <botlish_fn_19+0x270>
    1d3c:	xor    ecx,ecx
    1d3e:	test   rax,0x7
    1d44:	je     1d52 <botlish_fn_19+0x262>
    1d4a:	mov    rsi,rax
    1d4d:	jmp    1d60 <botlish_fn_19+0x270>
    1d52:	movzx  r10,BYTE PTR [rax]
    1d56:	mov    rsi,rax
    1d59:	cmp    r10b,0x1
    1d5d:	sete   cl
    1d60:	test   cl,cl
    1d62:	jne    1d80 <botlish_fn_19+0x290>
    1d68:	mov    rdi,r12
    1d6b:	mov    rax,QWORD PTR [rdi+0x10]
    1d6f:	mov    rcx,QWORD PTR [rax+0x10]
    1d73:	xor    rdx,rdx
    1d76:	call   1d7b <botlish_fn_19+0x28b>
			1d77: R_X86_64_PLT32	rt_type_error-0x4
    1d7b:	jmp    1dcf <botlish_fn_19+0x2df>
    1d80:	test   rsi,0x1
    1d87:	je     1da6 <botlish_fn_19+0x2b6>
    1d8d:	mov    rcx,rsi
    1d90:	sub    rcx,0x3
    1d94:	seto   al
    1d97:	add    rcx,0x1
    1d9e:	test   al,al
    1da0:	je     1db6 <botlish_fn_19+0x2c6>
    1da6:	mov    edx,0x3
    1dab:	mov    rdi,r12
    1dae:	call   1db3 <botlish_fn_19+0x2c3>
			1daf: R_X86_64_PLT32	rt_int_sub-0x4
    1db3:	mov    rcx,rax
    1db6:	mov    edx,0x3
    1dbb:	mov    rsi,r14
    1dbe:	mov    rdi,r12
    1dc1:	call   1dc6 <botlish_fn_19+0x2d6>
			1dc2: R_X86_64_PLT32	rt_mutarray_set-0x4
    1dc6:	test   rax,rax
    1dc9:	jne    1df4 <botlish_fn_19+0x304>
    1dcf:	xor    rax,rax
    1dd2:	mov    rbx,QWORD PTR [rsp+0x40]
    1dd7:	mov    r12,QWORD PTR [rsp+0x48]
    1ddc:	mov    r13,QWORD PTR [rsp+0x50]
    1de1:	mov    r14,QWORD PTR [rsp+0x58]
    1de6:	mov    r15,QWORD PTR [rsp+0x60]
    1deb:	add    rsp,0x70
    1def:	mov    rsp,rbp
    1df2:	pop    rbp
    1df3:	ret
    1df4:	mov    rax,r13
    1df7:	mov    rbx,QWORD PTR [rsp+0x40]
    1dfc:	mov    r12,QWORD PTR [rsp+0x48]
    1e01:	mov    r13,QWORD PTR [rsp+0x50]
    1e06:	mov    r14,QWORD PTR [rsp+0x58]
    1e0b:	mov    r15,QWORD PTR [rsp+0x60]
    1e10:	add    rsp,0x70
    1e14:	mov    rsp,rbp
    1e17:	pop    rbp
    1e18:	ret
    1e19:	add    BYTE PTR [rax],al
    1e1b:	add    BYTE PTR [rax],al
    1e1d:	add    BYTE PTR [rax],al
    1e1f:	add    BYTE PTR [rsi],al
    1e21:	add    BYTE PTR [rax],al
    1e23:	add    BYTE PTR [rax],al
    1e25:	add    BYTE PTR [rax],al
	...

0000000000001e28 <botlish_entry_19: ht_place<HashTable, int, str, str>>:
    1e28:	push   rbp
    1e29:	mov    rbp,rsp
    1e2c:	mov    rsi,QWORD PTR [rdx]
    1e2f:	mov    r9,QWORD PTR [rdx+0x8]
    1e33:	mov    rcx,QWORD PTR [rdx+0x10]
    1e37:	mov    r8,QWORD PTR [rdx+0x18]
    1e3b:	mov    rdx,r9
    1e3e:	call   1e43 <botlish_entry_19+0x1b>
			1e3f: R_X86_64_PLT32	botlish_fn_19-0x4 ; ht_place<HashTable, int, str, str>
    1e43:	mov    rsp,rbp
    1e46:	pop    rbp
    1e47:	ret

0000000000001e48 <botlish_fn_20: ht_set<HashTable, str, str>>:
    1e48:	push   rbp
    1e49:	mov    rbp,rsp
    1e4c:	sub    rsp,0x60
    1e50:	mov    QWORD PTR [rsp+0x30],rbx
    1e55:	mov    QWORD PTR [rsp+0x38],r12
    1e5a:	mov    QWORD PTR [rsp+0x40],r13
    1e5f:	mov    QWORD PTR [rsp+0x48],r14
    1e64:	mov    QWORD PTR [rsp+0x50],r15
    1e69:	mov    r12,rdi
    1e6c:	mov    QWORD PTR [rsp+0x18],0x0
    1e75:	mov    QWORD PTR [rsp+0x20],0x0
    1e7e:	mov    QWORD PTR [rsp],rsi
    1e82:	mov    r14,rsi
    1e85:	mov    QWORD PTR [rsp+0x8],rdx
    1e8a:	mov    r13,rdx
    1e8d:	mov    QWORD PTR [rsp+0x10],rcx
    1e92:	mov    rbx,rcx
    1e95:	mov    rdx,r13
    1e98:	mov    rsi,r14
    1e9b:	mov    rdi,r12
    1e9e:	call   1ea3 <botlish_fn_20+0x5b>
			1e9f: R_X86_64_PLT32	botlish_fn_7-0x4 ; ht_probe_start<HashTable, str>
    1ea3:	test   rax,rax
    1ea6:	je     207e <botlish_fn_20+0x236>
    1eac:	mov    QWORD PTR [rsp+0x18],rax
    1eb1:	mov    rcx,rax
    1eb4:	mov    r8,0xffffffffffffffff
    1ebb:	mov    r15,r8
    1ebe:	mov    QWORD PTR [rsp+0x20],0xffffffffffffffff
    1ec7:	mov    rdx,r13
    1eca:	mov    rsi,r14
    1ecd:	mov    rdi,r12
    1ed0:	call   1ed5 <botlish_fn_20+0x8d>
			1ed1: R_X86_64_PLT32	botlish_fn_10-0x4 ; ht_find_insert<HashTable, str, int, int>
    1ed5:	test   rax,rax
    1ed8:	je     207e <botlish_fn_20+0x236>
    1ede:	mov    QWORD PTR [rsp+0x18],rax
    1ee3:	mov    rsi,r14
    1ee6:	mov    QWORD PTR [rsp+0x28],rax
    1eeb:	mov    rax,QWORD PTR [rsi+0x18]
    1eef:	mov    rsi,QWORD PTR [rax]
    1ef2:	mov    rdx,QWORD PTR [rsp+0x28]
    1ef7:	mov    rdi,r12
    1efa:	call   1eff <botlish_fn_20+0xb7>
			1efb: R_X86_64_PLT32	rt_mutarray_get-0x4
    1eff:	test   rax,rax
    1f02:	je     207e <botlish_fn_20+0x236>
    1f08:	test   rax,0x1
    1f0e:	mov    rsi,rax
    1f11:	jne    1f39 <botlish_fn_20+0xf1>
    1f17:	mov    edx,0x3
    1f1c:	mov    rdi,r12
    1f1f:	call   1f24 <botlish_fn_20+0xdc>
			1f20: R_X86_64_PLT32	rt_int_cmp-0x4
    1f24:	mov    ecx,0x2
    1f29:	test   rax,rax
    1f2c:	cmove  rcx,QWORD PTR [rip+0x194]        # 20c8 <botlish_fn_20+0x280>
    1f34:	jmp    1f4a <botlish_fn_20+0x102>
    1f39:	mov    ecx,0x2
    1f3e:	cmp    rsi,0x3
    1f42:	cmove  rcx,QWORD PTR [rip+0x17e]        # 20c8 <botlish_fn_20+0x280>
    1f4a:	cmp    rcx,0x6
    1f4e:	je     205a <botlish_fn_20+0x212>
    1f54:	mov    rsi,r14
    1f57:	mov    rdi,r12
    1f5a:	call   1f5f <botlish_fn_20+0x117>
			1f5b: R_X86_64_PLT32	botlish_fn_17-0x4 ; ht_should_grow<HashTable>
    1f5f:	test   rax,rax
    1f62:	je     207e <botlish_fn_20+0x236>
    1f68:	cmp    rax,0x6
    1f6c:	je     1fb3 <botlish_fn_20+0x16b>
    1f72:	mov    rcx,r13
    1f75:	mov    rdx,QWORD PTR [rsp+0x28]
    1f7a:	mov    rsi,r14
    1f7d:	mov    rdi,r12
    1f80:	mov    r8,rbx
    1f83:	call   1f88 <botlish_fn_20+0x140>
			1f84: R_X86_64_PLT32	botlish_fn_19-0x4 ; ht_place<HashTable, int, str, str>
    1f88:	test   rax,rax
    1f8b:	je     207e <botlish_fn_20+0x236>
    1f91:	mov    rbx,QWORD PTR [rsp+0x30]
    1f96:	mov    r12,QWORD PTR [rsp+0x38]
    1f9b:	mov    r13,QWORD PTR [rsp+0x40]
    1fa0:	mov    r14,QWORD PTR [rsp+0x48]
    1fa5:	mov    r15,QWORD PTR [rsp+0x50]
    1faa:	add    rsp,0x60
    1fae:	mov    rsp,rbp
    1fb1:	pop    rbp
    1fb2:	ret
    1fb3:	mov    rsi,r14
    1fb6:	mov    rdi,r12
    1fb9:	call   1fbe <botlish_fn_20+0x176>
			1fba: R_X86_64_PLT32	botlish_fn_18-0x4 ; ht_grow_or_clean<HashTable>
    1fbe:	mov    rcx,rax
    1fc1:	mov    r14,rax
    1fc4:	test   rax,rcx
    1fc7:	je     207e <botlish_fn_20+0x236>
    1fcd:	mov    rax,r14
    1fd0:	mov    QWORD PTR [rsp],rax
    1fd4:	mov    rdx,r13
    1fd7:	mov    rsi,r14
    1fda:	mov    rdi,r12
    1fdd:	call   1fe2 <botlish_fn_20+0x19a>
			1fde: R_X86_64_PLT32	botlish_fn_7-0x4 ; ht_probe_start<HashTable, str>
    1fe2:	test   rax,rax
    1fe5:	je     207e <botlish_fn_20+0x236>
    1feb:	mov    QWORD PTR [rsp+0x18],rax
    1ff0:	mov    rcx,rax
    1ff3:	mov    QWORD PTR [rsp+0x20],0xffffffffffffffff
    1ffc:	mov    r8,r15
    1fff:	mov    rdx,r13
    2002:	mov    rsi,r14
    2005:	mov    rdi,r12
    2008:	call   200d <botlish_fn_20+0x1c5>
			2009: R_X86_64_PLT32	botlish_fn_10-0x4 ; ht_find_insert<HashTable, str, int, int>
    200d:	test   rax,rax
    2010:	je     207e <botlish_fn_20+0x236>
    2016:	mov    QWORD PTR [rsp+0x18],rax
    201b:	mov    rcx,r13
    201e:	mov    rdx,rax
    2021:	mov    rsi,r14
    2024:	mov    rdi,r12
    2027:	mov    r8,rbx
    202a:	call   202f <botlish_fn_20+0x1e7>
			202b: R_X86_64_PLT32	botlish_fn_19-0x4 ; ht_place<HashTable, int, str, str>
    202f:	test   rax,rax
    2032:	je     207e <botlish_fn_20+0x236>
    2038:	mov    rbx,QWORD PTR [rsp+0x30]
    203d:	mov    r12,QWORD PTR [rsp+0x38]
    2042:	mov    r13,QWORD PTR [rsp+0x40]
    2047:	mov    r14,QWORD PTR [rsp+0x48]
    204c:	mov    r15,QWORD PTR [rsp+0x50]
    2051:	add    rsp,0x60
    2055:	mov    rsp,rbp
    2058:	pop    rbp
    2059:	ret
    205a:	mov    rdx,QWORD PTR [rsp+0x28]
    205f:	mov    rsi,r14
    2062:	mov    rax,QWORD PTR [rsi+0x18]
    2066:	mov    rsi,QWORD PTR [rax+0x10]
    206a:	mov    rcx,rbx
    206d:	mov    rdi,r12
    2070:	call   2075 <botlish_fn_20+0x22d>
			2071: R_X86_64_PLT32	rt_mutarray_set-0x4
    2075:	test   rax,rax
    2078:	jne    20a3 <botlish_fn_20+0x25b>
    207e:	xor    rax,rax
    2081:	mov    rbx,QWORD PTR [rsp+0x30]
    2086:	mov    r12,QWORD PTR [rsp+0x38]
    208b:	mov    r13,QWORD PTR [rsp+0x40]
    2090:	mov    r14,QWORD PTR [rsp+0x48]
    2095:	mov    r15,QWORD PTR [rsp+0x50]
    209a:	add    rsp,0x60
    209e:	mov    rsp,rbp
    20a1:	pop    rbp
    20a2:	ret
    20a3:	mov    rax,r14
    20a6:	mov    rbx,QWORD PTR [rsp+0x30]
    20ab:	mov    r12,QWORD PTR [rsp+0x38]
    20b0:	mov    r13,QWORD PTR [rsp+0x40]
    20b5:	mov    r14,QWORD PTR [rsp+0x48]
    20ba:	mov    r15,QWORD PTR [rsp+0x50]
    20bf:	add    rsp,0x60
    20c3:	mov    rsp,rbp
    20c6:	pop    rbp
    20c7:	ret
    20c8:	(bad)
    20c9:	add    BYTE PTR [rax],al
    20cb:	add    BYTE PTR [rax],al
    20cd:	add    BYTE PTR [rax],al
	...

00000000000020d0 <botlish_entry_20: ht_set<HashTable, str, str>>:
    20d0:	push   rbp
    20d1:	mov    rbp,rsp
    20d4:	mov    rsi,QWORD PTR [rdx]
    20d7:	mov    r8,QWORD PTR [rdx+0x8]
    20db:	mov    rcx,QWORD PTR [rdx+0x10]
    20df:	mov    rdx,r8
    20e2:	call   20e7 <botlish_entry_20+0x17>
			20e3: R_X86_64_PLT32	botlish_fn_20-0x4 ; ht_set<HashTable, str, str>
    20e7:	mov    rsp,rbp
    20ea:	pop    rbp
    20eb:	ret
    20ec:	add    BYTE PTR [rax],al
	...

00000000000020f0 <botlish_fn_21: ht_delete<HashTable, str>>:
    20f0:	push   rbp
    20f1:	mov    rbp,rsp
    20f4:	sub    rsp,0x50
    20f8:	mov    QWORD PTR [rsp+0x30],rbx
    20fd:	mov    QWORD PTR [rsp+0x38],r12
    2102:	mov    QWORD PTR [rsp+0x40],r13
    2107:	mov    QWORD PTR [rsp+0x48],r14
    210c:	mov    r13,rdi
    210f:	mov    QWORD PTR [rsp+0x10],0x0
    2118:	mov    QWORD PTR [rsp+0x18],0x0
    2121:	mov    QWORD PTR [rsp+0x20],0x0
    212a:	mov    QWORD PTR [rsp],rsi
    212e:	mov    r12,rsi
    2131:	mov    QWORD PTR [rsp+0x8],rdx
    2136:	mov    r14,rdx
    2139:	mov    rbx,r12
    213c:	mov    rdx,r14
    213f:	mov    rsi,rbx
    2142:	mov    rdi,r13
    2145:	call   214a <botlish_fn_21+0x5a>
			2146: R_X86_64_PLT32	botlish_fn_7-0x4 ; ht_probe_start<HashTable, str>
    214a:	test   rax,rax
    214d:	je     2401 <botlish_fn_21+0x311>
    2153:	mov    QWORD PTR [rsp+0x10],rax
    2158:	mov    rcx,rax
    215b:	mov    rdx,r14
    215e:	mov    rsi,rbx
    2161:	mov    rdi,r13
    2164:	call   2169 <botlish_fn_21+0x79>
			2165: R_X86_64_PLT32	botlish_fn_9-0x4 ; ht_find_get<HashTable, str, int>
    2169:	mov    rcx,rax
    216c:	mov    r12,rax
    216f:	test   rax,rcx
    2172:	je     2401 <botlish_fn_21+0x311>
    2178:	mov    rax,r12
    217b:	test   rax,0x1
    2181:	jne    21ac <botlish_fn_21+0xbc>
    2187:	mov    edx,0x1
    218c:	mov    rsi,r12
    218f:	mov    rdi,r13
    2192:	call   2197 <botlish_fn_21+0xa7>
			2193: R_X86_64_PLT32	rt_int_cmp-0x4
    2197:	mov    ecx,0x2
    219c:	test   rax,rax
    219f:	cmovge rcx,QWORD PTR [rip+0x2a1]        # 2448 <botlish_fn_21+0x358>
    21a7:	jmp    21bc <botlish_fn_21+0xcc>
    21ac:	mov    ecx,0x2
    21b1:	test   r12,r12
    21b4:	cmovg  rcx,QWORD PTR [rip+0x28c]        # 2448 <botlish_fn_21+0x358>
    21bc:	cmp    rcx,0x6
    21c0:	je     21ce <botlish_fn_21+0xde>
    21c6:	mov    rax,rbx
    21c9:	jmp    2424 <botlish_fn_21+0x334>
    21ce:	mov    rcx,QWORD PTR [rbx+0x18]
    21d2:	mov    rsi,QWORD PTR [rcx]
    21d5:	mov    ecx,0x5
    21da:	mov    rdx,r12
    21dd:	mov    rdi,r13
    21e0:	call   21e5 <botlish_fn_21+0xf5>
			21e1: R_X86_64_PLT32	rt_mutarray_set-0x4
    21e5:	test   rax,rax
    21e8:	je     2401 <botlish_fn_21+0x311>
    21ee:	mov    rax,QWORD PTR [rbx+0x18]
    21f2:	mov    rsi,QWORD PTR [rax+0x8]
    21f6:	mov    ecx,0xa
    21fb:	mov    rdx,r12
    21fe:	mov    rdi,r13
    2201:	call   2206 <botlish_fn_21+0x116>
			2202: R_X86_64_PLT32	rt_mutarray_set-0x4
    2206:	test   rax,rax
    2209:	je     2401 <botlish_fn_21+0x311>
    220f:	mov    rax,QWORD PTR [rbx+0x18]
    2213:	mov    rsi,QWORD PTR [rax+0x10]
    2217:	mov    ecx,0xa
    221c:	mov    rdx,r12
    221f:	mov    rdi,r13
    2222:	call   2227 <botlish_fn_21+0x137>
			2223: R_X86_64_PLT32	rt_mutarray_set-0x4
    2227:	test   rax,rax
    222a:	je     2401 <botlish_fn_21+0x311>
    2230:	mov    rax,QWORD PTR [rbx+0x18]
    2234:	mov    rsi,QWORD PTR [rax+0x18]
    2238:	mov    QWORD PTR [rsp+0x8],rsi
    223d:	mov    r12,rsi
    2240:	mov    QWORD PTR [rsp+0x10],0x1
    2249:	mov    rsi,rbx
    224c:	mov    rdi,r13
    224f:	call   2254 <botlish_fn_21+0x164>
			2250: R_X86_64_PLT32	botlish_fn_4-0x4 ; ht_size<HashTable>
    2254:	test   rax,rax
    2257:	je     2401 <botlish_fn_21+0x311>
    225d:	mov    QWORD PTR [rsp+0x18],rax
    2262:	mov    QWORD PTR [rsp+0x20],0x3
    226b:	mov    esi,0x1
    2270:	test   rax,0x1
    2276:	je     2284 <botlish_fn_21+0x194>
    227c:	mov    r8,rax
    227f:	jmp    22a9 <botlish_fn_21+0x1b9>
    2284:	xor    esi,esi
    2286:	test   rax,0x7
    228c:	je     229a <botlish_fn_21+0x1aa>
    2292:	mov    r8,rax
    2295:	jmp    22a9 <botlish_fn_21+0x1b9>
    229a:	movzx  rcx,BYTE PTR [rax]
    229e:	mov    r8,rax
    22a1:	rex cmp cl,0x1
    22a5:	sete   sil
    22a9:	test   sil,sil
    22ac:	jne    22cd <botlish_fn_21+0x1dd>
    22b2:	mov    rdi,r13
    22b5:	mov    rax,QWORD PTR [rdi+0x10]
    22b9:	mov    rcx,QWORD PTR [rax+0x10]
    22bd:	xor    rdx,rdx
    22c0:	mov    rsi,r8
    22c3:	call   22c8 <botlish_fn_21+0x1d8>
			22c4: R_X86_64_PLT32	rt_type_error-0x4
    22c8:	jmp    2401 <botlish_fn_21+0x311>
    22cd:	mov    rsi,r8
    22d0:	test   rsi,0x1
    22d7:	je     22f6 <botlish_fn_21+0x206>
    22dd:	mov    rcx,rsi
    22e0:	sub    rcx,0x3
    22e4:	seto   al
    22e7:	add    rcx,0x1
    22ee:	test   al,al
    22f0:	je     2306 <botlish_fn_21+0x216>
    22f6:	mov    edx,0x3
    22fb:	mov    rdi,r13
    22fe:	call   2303 <botlish_fn_21+0x213>
			22ff: R_X86_64_PLT32	rt_int_sub-0x4
    2303:	mov    rcx,rax
    2306:	mov    edx,0x1
    230b:	mov    rsi,r12
    230e:	mov    rdi,r13
    2311:	call   2316 <botlish_fn_21+0x226>
			2312: R_X86_64_PLT32	rt_mutarray_set-0x4
    2316:	test   rax,rax
    2319:	je     2401 <botlish_fn_21+0x311>
    231f:	mov    rsi,QWORD PTR [rbx+0x18]
    2323:	mov    rsi,QWORD PTR [rsi+0x18]
    2327:	mov    QWORD PTR [rsp+0x8],rsi
    232c:	mov    r14,rsi
    232f:	mov    QWORD PTR [rsp+0x10],0x3
    2338:	mov    rsi,rbx
    233b:	mov    rdi,r13
    233e:	call   2343 <botlish_fn_21+0x253>
			233f: R_X86_64_PLT32	botlish_fn_5-0x4 ; ht_tombstones<HashTable>
    2343:	mov    r12,rbx
    2346:	test   rax,rax
    2349:	je     2401 <botlish_fn_21+0x311>
    234f:	mov    QWORD PTR [rsp+0x18],rax
    2354:	mov    QWORD PTR [rsp+0x20],0x3
    235d:	mov    ecx,0x1
    2362:	test   rax,0x1
    2368:	je     2376 <botlish_fn_21+0x286>
    236e:	mov    rsi,rax
    2371:	jmp    239a <botlish_fn_21+0x2aa>
    2376:	xor    ecx,ecx
    2378:	test   rax,0x7
    237e:	je     238c <botlish_fn_21+0x29c>
    2384:	mov    rsi,rax
    2387:	jmp    239a <botlish_fn_21+0x2aa>
    238c:	movzx  rcx,BYTE PTR [rax]
    2390:	mov    rsi,rax
    2393:	rex cmp cl,0x1
    2397:	sete   cl
    239a:	test   cl,cl
    239c:	jne    23b9 <botlish_fn_21+0x2c9>
    23a2:	mov    rdi,r13
    23a5:	mov    rax,QWORD PTR [rdi+0x10]
    23a9:	mov    rcx,QWORD PTR [rax]
    23ac:	xor    rdx,rdx
    23af:	call   23b4 <botlish_fn_21+0x2c4>
			23b0: R_X86_64_PLT32	rt_type_error-0x4
    23b4:	jmp    2401 <botlish_fn_21+0x311>
    23b9:	test   rsi,0x1
    23c0:	je     23d8 <botlish_fn_21+0x2e8>
    23c6:	mov    rcx,rsi
    23c9:	add    rcx,0x2
    23cd:	seto   al
    23d0:	test   al,al
    23d2:	je     23e8 <botlish_fn_21+0x2f8>
    23d8:	mov    edx,0x3
    23dd:	mov    rdi,r13
    23e0:	call   23e5 <botlish_fn_21+0x2f5>
			23e1: R_X86_64_PLT32	rt_int_add-0x4
    23e5:	mov    rcx,rax
    23e8:	mov    edx,0x3
    23ed:	mov    rsi,r14
    23f0:	mov    rdi,r13
    23f3:	call   23f8 <botlish_fn_21+0x308>
			23f4: R_X86_64_PLT32	rt_mutarray_set-0x4
    23f8:	test   rax,rax
    23fb:	jne    2421 <botlish_fn_21+0x331>
    2401:	xor    rax,rax
    2404:	mov    rbx,QWORD PTR [rsp+0x30]
    2409:	mov    r12,QWORD PTR [rsp+0x38]
    240e:	mov    r13,QWORD PTR [rsp+0x40]
    2413:	mov    r14,QWORD PTR [rsp+0x48]
    2418:	add    rsp,0x50
    241c:	mov    rsp,rbp
    241f:	pop    rbp
    2420:	ret
    2421:	mov    rax,r12
    2424:	mov    rbx,QWORD PTR [rsp+0x30]
    2429:	mov    r12,QWORD PTR [rsp+0x38]
    242e:	mov    r13,QWORD PTR [rsp+0x40]
    2433:	mov    r14,QWORD PTR [rsp+0x48]
    2438:	add    rsp,0x50
    243c:	mov    rsp,rbp
    243f:	pop    rbp
    2440:	ret
    2441:	add    BYTE PTR [rax],al
    2443:	add    BYTE PTR [rax],al
    2445:	add    BYTE PTR [rax],al
    2447:	add    BYTE PTR [rsi],al
    2449:	add    BYTE PTR [rax],al
    244b:	add    BYTE PTR [rax],al
    244d:	add    BYTE PTR [rax],al
	...

0000000000002450 <botlish_entry_21: ht_delete<HashTable, str>>:
    2450:	push   rbp
    2451:	mov    rbp,rsp
    2454:	mov    rsi,QWORD PTR [rdx]
    2457:	mov    rdx,QWORD PTR [rdx+0x8]
    245b:	call   2460 <botlish_entry_21+0x10>
			245c: R_X86_64_PLT32	botlish_fn_21-0x4 ; ht_delete<HashTable, str>
    2460:	mov    rsp,rbp
    2463:	pop    rbp
    2464:	ret
    2465:	add    BYTE PTR [rax],al
	...

0000000000002468 <botlish_fn_22: sample_checks<generic>>:
    2468:	push   rbp
    2469:	mov    rbp,rsp
    246c:	sub    rsp,0xa0
    2473:	mov    QWORD PTR [rsp+0x70],rbx
    2478:	mov    QWORD PTR [rsp+0x78],r12
    247d:	mov    QWORD PTR [rsp+0x80],r13
    2485:	mov    QWORD PTR [rsp+0x88],r14
    248d:	mov    QWORD PTR [rsp+0x90],r15
    2495:	mov    r13,rdi
    2498:	mov    QWORD PTR [rsp],0x0
    24a0:	mov    QWORD PTR [rsp+0x8],0x0
    24a9:	mov    QWORD PTR [rsp+0x10],0x0
    24b2:	mov    QWORD PTR [rsp+0x18],0x0
    24bb:	mov    QWORD PTR [rsp+0x20],0x0
    24c4:	mov    QWORD PTR [rsp+0x28],0x0
    24cd:	mov    rdi,r13
    24d0:	call   24d5 <botlish_fn_22+0x6d>
			24d1: R_X86_64_PLT32	botlish_fn_3-0x4 ; ht_new<generic>
    24d5:	test   rax,rax
    24d8:	je     2734 <botlish_fn_22+0x2cc>
    24de:	mov    QWORD PTR [rsp],rax
    24e2:	mov    rsi,rax
    24e5:	mov    rdi,r13
    24e8:	mov    rax,QWORD PTR [rdi+0x10]
    24ec:	mov    rdx,QWORD PTR [rax+0x18]
    24f0:	mov    QWORD PTR [rsp+0x8],rdx
    24f5:	mov    rax,QWORD PTR [rdi+0x10]
    24f9:	mov    rcx,QWORD PTR [rax+0x20]
    24fd:	mov    QWORD PTR [rsp+0x10],rcx
    2502:	call   2507 <botlish_fn_22+0x9f>
			2503: R_X86_64_PLT32	botlish_fn_20-0x4 ; ht_set<HashTable, str, str>
    2507:	test   rax,rax
    250a:	je     2734 <botlish_fn_22+0x2cc>
    2510:	mov    QWORD PTR [rsp],rax
    2514:	mov    rdi,r13
    2517:	mov    rsi,QWORD PTR [rdi+0x10]
    251b:	mov    rdx,QWORD PTR [rsi+0x28]
    251f:	mov    QWORD PTR [rsp+0x8],rdx
    2524:	mov    rsi,QWORD PTR [rdi+0x10]
    2528:	mov    rcx,QWORD PTR [rsi+0x30]
    252c:	mov    QWORD PTR [rsp+0x10],rcx
    2531:	mov    rsi,rax
    2534:	call   2539 <botlish_fn_22+0xd1>
			2535: R_X86_64_PLT32	botlish_fn_20-0x4 ; ht_set<HashTable, str, str>
    2539:	test   rax,rax
    253c:	je     2734 <botlish_fn_22+0x2cc>
    2542:	mov    QWORD PTR [rsp],rax
    2546:	mov    rsi,rax
    2549:	mov    rdi,r13
    254c:	mov    r11,QWORD PTR [rdi+0x10]
    2550:	mov    rdx,QWORD PTR [r11+0x18]
    2554:	mov    QWORD PTR [rsp+0x8],rdx
    2559:	mov    rax,QWORD PTR [rdi+0x10]
    255d:	mov    rcx,QWORD PTR [rax+0x38]
    2561:	mov    QWORD PTR [rsp+0x10],rcx
    2566:	call   256b <botlish_fn_22+0x103>
			2567: R_X86_64_PLT32	botlish_fn_20-0x4 ; ht_set<HashTable, str, str>
    256b:	test   rax,rax
    256e:	je     2734 <botlish_fn_22+0x2cc>
    2574:	mov    QWORD PTR [rsp],rax
    2578:	mov    rdi,r13
    257b:	mov    r14,rax
    257e:	mov    rax,QWORD PTR [rdi+0x10]
    2582:	mov    rdx,QWORD PTR [rax+0x28]
    2586:	mov    QWORD PTR [rsp+0x8],rdx
    258b:	mov    rsi,r14
    258e:	call   2593 <botlish_fn_22+0x12b>
			258f: R_X86_64_PLT32	botlish_fn_12-0x4 ; ht_contains<HashTable, str>
    2593:	test   rax,rax
    2596:	je     2734 <botlish_fn_22+0x2cc>
    259c:	mov    QWORD PTR [rsp+0x8],rax
    25a1:	mov    rdi,r13
    25a4:	mov    r15,rax
    25a7:	mov    rax,QWORD PTR [rdi+0x10]
    25ab:	mov    rdx,QWORD PTR [rax+0x28]
    25af:	mov    QWORD PTR [rsp+0x10],rdx
    25b4:	mov    rsi,r14
    25b7:	call   25bc <botlish_fn_22+0x154>
			25b8: R_X86_64_PLT32	botlish_fn_21-0x4 ; ht_delete<HashTable, str>
    25bc:	mov    rcx,rax
    25bf:	mov    r14,rax
    25c2:	test   rax,rcx
    25c5:	je     2734 <botlish_fn_22+0x2cc>
    25cb:	mov    rax,r14
    25ce:	mov    QWORD PTR [rsp],rax
    25d2:	mov    rdi,r13
    25d5:	mov    rax,QWORD PTR [rdi+0x10]
    25d9:	mov    rdx,QWORD PTR [rax+0x18]
    25dd:	mov    QWORD PTR [rsp+0x10],rdx
    25e2:	mov    rsi,r14
    25e5:	call   25ea <botlish_fn_22+0x182>
			25e6: R_X86_64_PLT32	botlish_fn_11-0x4 ; ht_get<HashTable, str>
    25ea:	test   rax,rax
    25ed:	je     2734 <botlish_fn_22+0x2cc>
    25f3:	mov    rdi,r13
    25f6:	mov    rcx,QWORD PTR [rdi+0x10]
    25fa:	mov    rdx,QWORD PTR [rcx+0x38]
    25fe:	mov    rcx,rax
    2601:	and    rcx,rdx
    2604:	mov    rsi,rax
    2607:	test   rcx,0x1
    260e:	jne    262a <botlish_fn_22+0x1c2>
    2614:	mov    rdi,r13
    2617:	call   261c <botlish_fn_22+0x1b4>
			2618: R_X86_64_PLT32	rt_value_eq-0x4
    261c:	test   rax,rax
    261f:	je     2734 <botlish_fn_22+0x2cc>
    2625:	jmp    263a <botlish_fn_22+0x1d2>
    262a:	mov    eax,0x2
    262f:	cmp    rsi,rdx
    2632:	cmove  rax,QWORD PTR [rip+0x15e]        # 2798 <botlish_fn_22+0x330>
    263a:	mov    QWORD PTR [rsp+0x10],rax
    263f:	mov    rdi,r13
    2642:	mov    QWORD PTR [rsp+0x60],rax
    2647:	mov    rax,QWORD PTR [rdi+0x10]
    264b:	mov    rdx,QWORD PTR [rax+0x28]
    264f:	mov    QWORD PTR [rsp+0x18],rdx
    2654:	mov    rsi,r14
    2657:	call   265c <botlish_fn_22+0x1f4>
			2658: R_X86_64_PLT32	botlish_fn_12-0x4 ; ht_contains<HashTable, str>
    265c:	mov    rbx,rax
    265f:	test   rbx,rbx
    2662:	je     2734 <botlish_fn_22+0x2cc>
    2668:	mov    QWORD PTR [rsp+0x18],rbx
    266d:	mov    rdi,r13
    2670:	mov    rax,QWORD PTR [rdi+0x10]
    2674:	mov    rdx,QWORD PTR [rax+0x40]
    2678:	mov    QWORD PTR [rsp+0x20],rdx
    267d:	mov    rsi,r14
    2680:	call   2685 <botlish_fn_22+0x21d>
			2681: R_X86_64_PLT32	botlish_fn_12-0x4 ; ht_contains<HashTable, str>
    2685:	mov    r12,rax
    2688:	test   r12,r12
    268b:	je     2734 <botlish_fn_22+0x2cc>
    2691:	mov    QWORD PTR [rsp+0x20],r12
    2696:	mov    rdi,r13
    2699:	mov    rax,QWORD PTR [rdi+0x10]
    269d:	mov    rdx,QWORD PTR [rax+0x40]
    26a1:	mov    QWORD PTR [rsp+0x28],rdx
    26a6:	mov    rsi,r14
    26a9:	call   26ae <botlish_fn_22+0x246>
			26aa: R_X86_64_PLT32	botlish_fn_11-0x4 ; ht_get<HashTable, str>
    26ae:	test   rax,rax
    26b1:	mov    rsi,rax
    26b4:	je     2734 <botlish_fn_22+0x2cc>
    26ba:	mov    edx,0xa
    26bf:	mov    rdi,r13
    26c2:	call   26c7 <botlish_fn_22+0x25f>
			26c3: R_X86_64_PLT32	rt_value_eq-0x4
    26c7:	test   rax,rax
    26ca:	je     2734 <botlish_fn_22+0x2cc>
    26d0:	mov    QWORD PTR [rsp+0x28],rax
    26d5:	mov    rsi,r14
    26d8:	mov    r14,rax
    26db:	mov    rdi,r13
    26de:	call   26e3 <botlish_fn_22+0x27b>
			26df: R_X86_64_PLT32	botlish_fn_4-0x4 ; ht_size<HashTable>
    26e3:	test   rax,rax
    26e6:	je     2734 <botlish_fn_22+0x2cc>
    26ec:	mov    QWORD PTR [rsp],rax
    26f0:	lea    rdx,[rsp+0x30]
    26f5:	mov    r9,QWORD PTR [rsp+0x60]
    26fa:	mov    QWORD PTR [rsp+0x30],r9
    26ff:	mov    rsi,r15
    2702:	mov    QWORD PTR [rsp+0x38],rsi
    2707:	mov    QWORD PTR [rsp+0x40],rbx
    270c:	mov    QWORD PTR [rsp+0x48],r12
    2711:	mov    rcx,r14
    2714:	mov    QWORD PTR [rsp+0x50],rcx
    2719:	mov    QWORD PTR [rsp+0x58],rax
    271e:	mov    esi,0x6
    2723:	mov    rdi,r13
    2726:	call   272b <botlish_fn_22+0x2c3>
			2727: R_X86_64_PLT32	rt_list_new-0x4
    272b:	test   rax,rax
    272e:	jne    2765 <botlish_fn_22+0x2fd>
    2734:	xor    rax,rax
    2737:	mov    rbx,QWORD PTR [rsp+0x70]
    273c:	mov    r12,QWORD PTR [rsp+0x78]
    2741:	mov    r13,QWORD PTR [rsp+0x80]
    2749:	mov    r14,QWORD PTR [rsp+0x88]
    2751:	mov    r15,QWORD PTR [rsp+0x90]
    2759:	add    rsp,0xa0
    2760:	mov    rsp,rbp
    2763:	pop    rbp
    2764:	ret
    2765:	mov    rbx,QWORD PTR [rsp+0x70]
    276a:	mov    r12,QWORD PTR [rsp+0x78]
    276f:	mov    r13,QWORD PTR [rsp+0x80]
    2777:	mov    r14,QWORD PTR [rsp+0x88]
    277f:	mov    r15,QWORD PTR [rsp+0x90]
    2787:	add    rsp,0xa0
    278e:	mov    rsp,rbp
    2791:	pop    rbp
    2792:	ret
    2793:	add    BYTE PTR [rax],al
    2795:	add    BYTE PTR [rax],al
    2797:	add    BYTE PTR [rsi],al
    2799:	add    BYTE PTR [rax],al
    279b:	add    BYTE PTR [rax],al
    279d:	add    BYTE PTR [rax],al
	...

00000000000027a0 <botlish_entry_22: sample_checks<generic>>:
    27a0:	push   rbp
    27a1:	mov    rbp,rsp
    27a4:	call   27a9 <botlish_entry_22+0x9>
			27a5: R_X86_64_PLT32	botlish_fn_22-0x4 ; sample_checks<generic>
    27a9:	mov    rsp,rbp
    27ac:	pop    rbp
    27ad:	ret

00000000000027ae <botlish_fn_23: sample<generic>>:
    27ae:	push   rbp
    27af:	mov    rbp,rsp
    27b2:	sub    rsp,0x10
    27b6:	mov    QWORD PTR [rsp],r12
    27ba:	mov    r12,rdi
    27bd:	mov    rdi,r12
    27c0:	call   27c5 <botlish_fn_23+0x17>
			27c1: R_X86_64_PLT32	botlish_fn_22-0x4 ; sample_checks<generic>
    27c5:	test   rax,rax
    27c8:	jne    2811 <botlish_fn_23+0x63>
    27ce:	mov    rdi,r12
    27d1:	call   27d6 <botlish_fn_23+0x28>
			27d2: R_X86_64_PLT32	rt_declared_error-0x4
    27d6:	cmp    rax,0x40000001
    27dc:	jne    2801 <botlish_fn_23+0x53>
    27e2:	mov    rdi,r12
    27e5:	call   27ea <botlish_fn_23+0x3c>
			27e6: R_X86_64_PLT32	rt_clear_declared_error-0x4
    27ea:	xor    rdx,rdx
    27ed:	mov    rdi,r12
    27f0:	mov    rsi,rdx
    27f3:	call   27f8 <botlish_fn_23+0x4a>
			27f4: R_X86_64_PLT32	rt_list_new-0x4
    27f8:	test   rax,rax
    27fb:	jne    2811 <botlish_fn_23+0x63>
    2801:	xor    rax,rax
    2804:	mov    r12,QWORD PTR [rsp]
    2808:	add    rsp,0x10
    280c:	mov    rsp,rbp
    280f:	pop    rbp
    2810:	ret
    2811:	mov    r12,QWORD PTR [rsp]
    2815:	add    rsp,0x10
    2819:	mov    rsp,rbp
    281c:	pop    rbp
    281d:	ret

000000000000281e <botlish_entry_23: sample<generic>>:
    281e:	push   rbp
    281f:	mov    rbp,rsp
    2822:	call   2827 <botlish_entry_23+0x9>
			2823: R_X86_64_PLT32	botlish_fn_23-0x4 ; sample<generic>
    2827:	mov    rsp,rbp
    282a:	pop    rbp
    282b:	ret
