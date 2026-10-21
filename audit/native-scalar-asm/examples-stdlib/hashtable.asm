; source:  examples/stdlib/hashtable.bot
; backend: Cranelift (specialize=1), native::object
; object:  ELF64 x86-64, unlinked (Botlish-generated code only; runtime
;          helpers are unresolved imports, so their bodies are not present)
; format:  objdump -dr --no-show-raw-insn -M intel
; total machine code bytes: 12747  (per function: 45 489 446 70 103 105 44 255 243 692 1096 381 237 588 730 784 723 801 673 1304 780 1181 830 147)
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
      83:	mov    rbx,rax
      86:	test   rax,rcx
      89:	je     122 <botlish_fn_1+0xf5>
      8f:	mov    rax,rbx
      92:	mov    QWORD PTR [rsp+0x8],rax
      97:	mov    rcx,QWORD PTR [rax+0x18]
      9b:	test   rcx,rcx
      9e:	je     19f <botlish_fn_1+0x172>
      a4:	mov    rcx,QWORD PTR [rbx+0x10]
      a8:	mov    QWORD PTR [rcx],0x1
      af:	mov    rcx,QWORD PTR [rbx+0x18]
      b3:	test   rcx,rcx
      b6:	je     1b7 <botlish_fn_1+0x18a>
      bc:	mov    rax,QWORD PTR [rbx+0x10]
      c0:	mov    QWORD PTR [rax+0x8],0x1
      c8:	mov    edx,0x1
      cd:	mov    QWORD PTR [rsp+0x10],0x1
      d6:	mov    rsi,r13
      d9:	mov    rdi,r12
      dc:	call   e1 <botlish_fn_1+0xb4>
			dd: R_X86_64_PLT32	rt_mutarray_create-0x4
      e1:	test   rax,rax
      e4:	je     122 <botlish_fn_1+0xf5>
      ea:	mov    QWORD PTR [rsp+0x10],rax
      ef:	mov    r14,rax
      f2:	mov    rsi,r13
      f5:	mov    rdi,r12
      f8:	call   fd <botlish_fn_1+0xd0>
			f9: R_X86_64_PLT32	rt_mutarray_allocate-0x4
      fd:	test   rax,rax
     100:	je     122 <botlish_fn_1+0xf5>
     106:	mov    QWORD PTR [rsp+0x18],rax
     10b:	mov    rsi,r13
     10e:	mov    r15,rax
     111:	mov    rdi,r12
     114:	call   119 <botlish_fn_1+0xec>
			115: R_X86_64_PLT32	rt_mutarray_allocate-0x4
     119:	test   rax,rax
     11c:	jne    147 <botlish_fn_1+0x11a>
     122:	xor    rax,rax
     125:	mov    rbx,QWORD PTR [rsp+0x40]
     12a:	mov    r12,QWORD PTR [rsp+0x48]
     12f:	mov    r13,QWORD PTR [rsp+0x50]
     134:	mov    r14,QWORD PTR [rsp+0x58]
     139:	mov    r15,QWORD PTR [rsp+0x60]
     13e:	add    rsp,0x70
     142:	mov    rsp,rbp
     145:	pop    rbp
     146:	ret
     147:	mov    QWORD PTR [rsp],rax
     14b:	lea    rcx,[rsp+0x20]
     150:	mov    rdx,r14
     153:	mov    QWORD PTR [rsp+0x20],rdx
     158:	mov    rdx,r15
     15b:	mov    QWORD PTR [rsp+0x28],rdx
     160:	mov    QWORD PTR [rsp+0x30],rax
     165:	mov    rax,rbx
     168:	mov    QWORD PTR [rsp+0x38],rax
     16d:	xor    rsi,rsi
     170:	mov    edx,0x4
     175:	mov    rdi,r12
     178:	call   17d <botlish_fn_1+0x150>
			179: R_X86_64_PLT32	rt_struct_new-0x4
     17d:	mov    rbx,QWORD PTR [rsp+0x40]
     182:	mov    r12,QWORD PTR [rsp+0x48]
     187:	mov    r13,QWORD PTR [rsp+0x50]
     18c:	mov    r14,QWORD PTR [rsp+0x58]
     191:	mov    r15,QWORD PTR [rsp+0x60]
     196:	add    rsp,0x70
     19a:	mov    rsp,rbp
     19d:	pop    rbp
     19e:	ret
     19f:	mov    ecx,0x1
     1a4:	mov    rsi,rbx
     1a7:	mov    rdi,r12
     1aa:	mov    rdx,rcx
     1ad:	call   1b2 <botlish_fn_1+0x185>
			1ae: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
     1b2:	jmp    af <botlish_fn_1+0x82>
     1b7:	mov    edx,0x3
     1bc:	mov    ecx,0x1
     1c1:	mov    rsi,rbx
     1c4:	mov    rdi,r12
     1c7:	call   1cc <botlish_fn_1+0x19f>
			1c8: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
     1cc:	jmp    c8 <botlish_fn_1+0x9b>

00000000000001d1 <botlish_entry_1: ht_alloc<int>>:
     1d1:	push   rbp
     1d2:	mov    rbp,rsp
     1d5:	mov    rsi,QWORD PTR [rdx]
     1d8:	call   1dd <botlish_entry_1+0xc>
			1d9: R_X86_64_PLT32	botlish_fn_1-0x4 ; ht_alloc<int>
     1dd:	mov    rsp,rbp
     1e0:	pop    rbp
     1e1:	ret

00000000000001e2 <botlish_fn_2: ht_alloc<int>>:
     1e2:	push   rbp
     1e3:	mov    rbp,rsp
     1e6:	sub    rsp,0x60
     1ea:	mov    QWORD PTR [rsp+0x30],rbx
     1ef:	mov    QWORD PTR [rsp+0x38],r12
     1f4:	mov    QWORD PTR [rsp+0x40],r13
     1f9:	mov    QWORD PTR [rsp+0x48],r14
     1fe:	mov    QWORD PTR [rsp+0x50],r15
     203:	mov    r12,rdx
     206:	mov    r14,rdi
     209:	mov    QWORD PTR [rsp+0x10],0x0
     212:	mov    QWORD PTR [rsp+0x18],0x0
     21b:	mov    QWORD PTR [rsp],rsi
     21f:	mov    r13,rsi
     222:	mov    esi,0x5
     227:	mov    QWORD PTR [rsp+0x8],0x5
     230:	mov    rdi,r14
     233:	call   238 <botlish_fn_2+0x56>
			234: R_X86_64_PLT32	rt_mutarray_allocate-0x4
     238:	mov    rcx,rax
     23b:	mov    rbx,rax
     23e:	test   rax,rcx
     241:	je     2dc <botlish_fn_2+0xfa>
     247:	mov    rax,rbx
     24a:	mov    QWORD PTR [rsp+0x8],rax
     24f:	mov    rcx,QWORD PTR [rax+0x18]
     253:	test   rcx,rcx
     256:	je     33c <botlish_fn_2+0x15a>
     25c:	mov    rcx,QWORD PTR [rbx+0x10]
     260:	mov    QWORD PTR [rcx],0x1
     267:	mov    rcx,QWORD PTR [rbx+0x18]
     26b:	test   rcx,rcx
     26e:	je     354 <botlish_fn_2+0x172>
     274:	mov    rax,QWORD PTR [rbx+0x10]
     278:	mov    QWORD PTR [rax+0x8],0x1
     280:	mov    edx,0x1
     285:	mov    QWORD PTR [rsp+0x10],0x1
     28e:	mov    rsi,r13
     291:	mov    rdi,r14
     294:	call   299 <botlish_fn_2+0xb7>
			295: R_X86_64_PLT32	rt_mutarray_create-0x4
     299:	test   rax,rax
     29c:	je     2dc <botlish_fn_2+0xfa>
     2a2:	mov    QWORD PTR [rsp+0x10],rax
     2a7:	mov    r15,rax
     2aa:	mov    rsi,r13
     2ad:	mov    rdi,r14
     2b0:	call   2b5 <botlish_fn_2+0xd3>
			2b1: R_X86_64_PLT32	rt_mutarray_allocate-0x4
     2b5:	test   rax,rax
     2b8:	je     2dc <botlish_fn_2+0xfa>
     2be:	mov    QWORD PTR [rsp+0x18],rax
     2c3:	mov    rsi,r13
     2c6:	mov    rdi,r14
     2c9:	mov    QWORD PTR [rsp+0x20],rax
     2ce:	call   2d3 <botlish_fn_2+0xf1>
			2cf: R_X86_64_PLT32	rt_mutarray_allocate-0x4
     2d3:	test   rax,rax
     2d6:	jne    301 <botlish_fn_2+0x11f>
     2dc:	xor    rax,rax
     2df:	mov    rbx,QWORD PTR [rsp+0x30]
     2e4:	mov    r12,QWORD PTR [rsp+0x38]
     2e9:	mov    r13,QWORD PTR [rsp+0x40]
     2ee:	mov    r14,QWORD PTR [rsp+0x48]
     2f3:	mov    r15,QWORD PTR [rsp+0x50]
     2f8:	add    rsp,0x60
     2fc:	mov    rsp,rbp
     2ff:	pop    rbp
     300:	ret
     301:	mov    rcx,QWORD PTR [rsp+0x20]
     306:	mov    rdx,r12
     309:	mov    QWORD PTR [rdx],rcx
     30c:	mov    QWORD PTR [rdx+0x8],rax
     310:	mov    rax,rbx
     313:	mov    QWORD PTR [rdx+0x10],rax
     317:	mov    rax,r15
     31a:	mov    rbx,QWORD PTR [rsp+0x30]
     31f:	mov    r12,QWORD PTR [rsp+0x38]
     324:	mov    r13,QWORD PTR [rsp+0x40]
     329:	mov    r14,QWORD PTR [rsp+0x48]
     32e:	mov    r15,QWORD PTR [rsp+0x50]
     333:	add    rsp,0x60
     337:	mov    rsp,rbp
     33a:	pop    rbp
     33b:	ret
     33c:	mov    ecx,0x1
     341:	mov    rsi,rbx
     344:	mov    rdi,r14
     347:	mov    rdx,rcx
     34a:	call   34f <botlish_fn_2+0x16d>
			34b: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
     34f:	jmp    267 <botlish_fn_2+0x85>
     354:	mov    edx,0x3
     359:	mov    ecx,0x1
     35e:	mov    rsi,rbx
     361:	mov    rdi,r14
     364:	call   369 <botlish_fn_2+0x187>
			365: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
     369:	jmp    280 <botlish_fn_2+0x9e>

000000000000036e <botlish_entry_2: ht_alloc<int>>:
     36e:	push   rbp
     36f:	mov    rbp,rsp
     372:	ud2

0000000000000374 <botlish_fn_3: ht_new<generic>>:
     374:	push   rbp
     375:	mov    rbp,rsp
     378:	sub    rsp,0x10
     37c:	mov    esi,0x11
     381:	mov    QWORD PTR [rsp],0x11
     389:	call   38e <botlish_fn_3+0x1a>
			38a: R_X86_64_PLT32	botlish_fn_1-0x4 ; ht_alloc<int>
     38e:	test   rax,rax
     391:	jne    3a3 <botlish_fn_3+0x2f>
     397:	xor    rax,rax
     39a:	add    rsp,0x10
     39e:	mov    rsp,rbp
     3a1:	pop    rbp
     3a2:	ret
     3a3:	add    rsp,0x10
     3a7:	mov    rsp,rbp
     3aa:	pop    rbp
     3ab:	ret

00000000000003ac <botlish_entry_3: ht_new<generic>>:
     3ac:	push   rbp
     3ad:	mov    rbp,rsp
     3b0:	call   3b5 <botlish_entry_3+0x9>
			3b1: R_X86_64_PLT32	botlish_fn_3-0x4 ; ht_new<generic>
     3b5:	mov    rsp,rbp
     3b8:	pop    rbp
     3b9:	ret

00000000000003ba <botlish_fn_4: ht_size<HashTable>>:
     3ba:	push   rbp
     3bb:	mov    rbp,rsp
     3be:	mov    rax,QWORD PTR [rsi+0x18]
     3c2:	mov    rsi,QWORD PTR [rax+0x18]
     3c6:	mov    rax,QWORD PTR [rsi+0x8]
     3ca:	test   rax,rax
     3cd:	jne    3e5 <botlish_fn_4+0x2b>
     3d3:	jmp    3f1 <botlish_fn_4+0x37>
     3d8:	xor    rax,rax
     3db:	mov    rsp,rbp
     3de:	pop    rbp
     3df:	ret
     3e0:	jmp    3ec <botlish_fn_4+0x32>
     3e5:	mov    rax,QWORD PTR [rsi+0x10]
     3e9:	mov    rax,QWORD PTR [rax]
     3ec:	mov    rsp,rbp
     3ef:	pop    rbp
     3f0:	ret
     3f1:	mov    edx,0x1
     3f6:	call   3fb <botlish_fn_4+0x41>
			3f7: R_X86_64_PLT32	rt_mutarray_get-0x4
     3fb:	test   rax,rax
     3fe:	jne    3ec <botlish_fn_4+0x32>
     404:	jmp    3d8 <botlish_fn_4+0x1e>

0000000000000409 <botlish_entry_4: ht_size<HashTable>>:
     409:	push   rbp
     40a:	mov    rbp,rsp
     40d:	mov    rsi,QWORD PTR [rdx]
     410:	call   415 <botlish_entry_4+0xc>
			411: R_X86_64_PLT32	botlish_fn_4-0x4 ; ht_size<HashTable>
     415:	mov    rsp,rbp
     418:	pop    rbp
     419:	ret

000000000000041a <botlish_fn_5: ht_tombstones<HashTable>>:
     41a:	push   rbp
     41b:	mov    rbp,rsp
     41e:	mov    rax,QWORD PTR [rsi+0x18]
     422:	mov    rsi,QWORD PTR [rax+0x18]
     426:	mov    rax,QWORD PTR [rsi+0x8]
     42a:	cmp    rax,0x1
     42e:	ja     446 <botlish_fn_5+0x2c>
     434:	jmp    453 <botlish_fn_5+0x39>
     439:	xor    rax,rax
     43c:	mov    rsp,rbp
     43f:	pop    rbp
     440:	ret
     441:	jmp    44e <botlish_fn_5+0x34>
     446:	mov    rax,QWORD PTR [rsi+0x10]
     44a:	mov    rax,QWORD PTR [rax+0x8]
     44e:	mov    rsp,rbp
     451:	pop    rbp
     452:	ret
     453:	mov    edx,0x3
     458:	call   45d <botlish_fn_5+0x43>
			459: R_X86_64_PLT32	rt_mutarray_get-0x4
     45d:	test   rax,rax
     460:	jne    44e <botlish_fn_5+0x34>
     466:	jmp    439 <botlish_fn_5+0x1f>

000000000000046b <botlish_entry_5: ht_tombstones<HashTable>>:
     46b:	push   rbp
     46c:	mov    rbp,rsp
     46f:	mov    rsi,QWORD PTR [rdx]
     472:	call   477 <botlish_entry_5+0xc>
			473: R_X86_64_PLT32	botlish_fn_5-0x4 ; ht_tombstones<HashTable>
     477:	mov    rsp,rbp
     47a:	pop    rbp
     47b:	ret

000000000000047c <botlish_fn_6: ht_capacity<HashTable>>:
     47c:	push   rbp
     47d:	mov    rbp,rsp
     480:	mov    rdi,QWORD PTR [rsi+0x18]
     484:	mov    rdi,QWORD PTR [rdi]
     487:	mov    rax,QWORD PTR [rdi+0x8]
     48b:	shl    rax,1
     48e:	or     rax,0x1
     492:	mov    rsp,rbp
     495:	pop    rbp
     496:	ret

0000000000000497 <botlish_entry_6: ht_capacity<HashTable>>:
     497:	push   rbp
     498:	mov    rbp,rsp
     49b:	mov    rsi,QWORD PTR [rdx]
     49e:	call   4a3 <botlish_entry_6+0xc>
			49f: R_X86_64_PLT32	botlish_fn_6-0x4 ; ht_capacity<HashTable>
     4a3:	mov    rsp,rbp
     4a6:	pop    rbp
     4a7:	ret

00000000000004a8 <botlish_fn_7: ht_probe_start<HashTable, str>>:
     4a8:	push   rbp
     4a9:	mov    rbp,rsp
     4ac:	sub    rsp,0x20
     4b0:	mov    QWORD PTR [rsp],rbx
     4b4:	mov    QWORD PTR [rsp+0x8],r12
     4b9:	mov    QWORD PTR [rsp+0x10],r13
     4be:	mov    rbx,rdi
     4c1:	mov    r13,rsi
     4c4:	mov    rsi,rdx
     4c7:	mov    rdi,rbx
     4ca:	call   4cf <botlish_fn_7+0x27>
			4cb: R_X86_64_PLT32	rt_hash-0x4
     4cf:	test   rax,rax
     4d2:	mov    r12,rax
     4d5:	je     4fa <botlish_fn_7+0x52>
     4db:	mov    rsi,r13
     4de:	mov    rdi,rbx
     4e1:	call   4e6 <botlish_fn_7+0x3e>
			4e2: R_X86_64_PLT32	botlish_fn_6-0x4 ; ht_capacity<HashTable>
     4e6:	sar    rax,1
     4e9:	test   rax,rax
     4ec:	mov    rcx,rax
     4ef:	jne    514 <botlish_fn_7+0x6c>
     4f5:	jmp    568 <botlish_fn_7+0xc0>
     4fa:	xor    rax,rax
     4fd:	mov    rbx,QWORD PTR [rsp]
     501:	mov    r12,QWORD PTR [rsp+0x8]
     506:	mov    r13,QWORD PTR [rsp+0x10]
     50b:	add    rsp,0x20
     50f:	mov    rsp,rbp
     512:	pop    rbp
     513:	ret
     514:	mov    rax,r12
     517:	sar    rax,1
     51a:	cqo
     51c:	cmp    rcx,0xffffffffffffffff
     520:	jne    530 <botlish_fn_7+0x88>
     526:	mov    edx,0x0
     52b:	jmp    533 <botlish_fn_7+0x8b>
     530:	idiv   rcx
     533:	mov    rax,rcx
     536:	neg    rax
     539:	cmovs  rax,rcx
     53d:	add    rax,rdx
     540:	test   rdx,rdx
     543:	cmovl  rdx,rax
     547:	shl    rdx,1
     54a:	mov    rax,rdx
     54d:	or     rax,0x1
     551:	mov    rbx,QWORD PTR [rsp]
     555:	mov    r12,QWORD PTR [rsp+0x8]
     55a:	mov    r13,QWORD PTR [rsp+0x10]
     55f:	add    rsp,0x20
     563:	mov    rsp,rbp
     566:	pop    rbp
     567:	ret
     568:	mov    edx,0x1
     56d:	mov    rax,r12
     570:	mov    rsi,rax
     573:	or     rsi,0x1
     577:	mov    rdi,rbx
     57a:	call   57f <botlish_fn_7+0xd7>
			57b: R_X86_64_PLT32	rt_int_mod-0x4
     57f:	jmp    4fa <botlish_fn_7+0x52>

0000000000000584 <botlish_entry_7: ht_probe_start<HashTable, str>>:
     584:	push   rbp
     585:	mov    rbp,rsp
     588:	mov    rsi,QWORD PTR [rdx]
     58b:	mov    rdx,QWORD PTR [rdx+0x8]
     58f:	call   594 <botlish_entry_7+0x10>
			590: R_X86_64_PLT32	botlish_fn_7-0x4 ; ht_probe_start<HashTable, str>
     594:	mov    rsp,rbp
     597:	pop    rbp
     598:	ret

0000000000000599 <botlish_fn_8: ht_probe_next<HashTable, int>>:
     599:	push   rbp
     59a:	mov    rbp,rsp
     59d:	sub    rsp,0x10
     5a1:	mov    QWORD PTR [rsp],rbx
     5a5:	mov    QWORD PTR [rsp+0x8],r12
     5aa:	mov    rbx,rdi
     5ad:	mov    r12,rdx
     5b0:	mov    rdi,rbx
     5b3:	call   5b8 <botlish_fn_8+0x1f>
			5b4: R_X86_64_PLT32	botlish_fn_6-0x4 ; ht_capacity<HashTable>
     5b8:	sar    rax,1
     5bb:	test   rax,rax
     5be:	mov    rsi,rax
     5c1:	jne    5e4 <botlish_fn_8+0x4b>
     5c7:	jmp    639 <botlish_fn_8+0xa0>
     5cc:	xor    rdx,rdx
     5cf:	mov    rax,rdx
     5d2:	mov    rbx,QWORD PTR [rsp]
     5d6:	mov    r12,QWORD PTR [rsp+0x8]
     5db:	add    rsp,0x10
     5df:	mov    rsp,rbp
     5e2:	pop    rbp
     5e3:	ret
     5e4:	mov    rax,r12
     5e7:	mov    ecx,0x1
     5ec:	add    rax,0x1
     5f3:	cqo
     5f5:	cmp    rsi,0xffffffffffffffff
     5f9:	jne    609 <botlish_fn_8+0x70>
     5ff:	mov    edx,0x0
     604:	jmp    60c <botlish_fn_8+0x73>
     609:	idiv   rsi
     60c:	mov    rax,rsi
     60f:	neg    rax
     612:	cmovs  rax,rsi
     616:	lea    rsi,[rdx+rax*1]
     61a:	test   rdx,rdx
     61d:	mov    rax,rdx
     620:	cmovl  rax,rsi
     624:	mov    rdx,rcx
     627:	mov    rbx,QWORD PTR [rsp]
     62b:	mov    r12,QWORD PTR [rsp+0x8]
     630:	add    rsp,0x10
     634:	mov    rsp,rbp
     637:	pop    rbp
     638:	ret
     639:	mov    edx,0x1
     63e:	mov    rax,r12
     641:	lea    rsi,[rax+0x1]
     645:	shl    rsi,1
     648:	or     rsi,0x1
     64c:	mov    rdi,rbx
     64f:	call   654 <botlish_fn_8+0xbb>
			650: R_X86_64_PLT32	rt_int_mod-0x4
     654:	jmp    5cc <botlish_fn_8+0x33>

0000000000000659 <botlish_entry_8: ht_probe_next<HashTable, int>>:
     659:	push   rbp
     65a:	mov    rbp,rsp
     65d:	mov    rsi,QWORD PTR [rdx]
     660:	mov    rdx,QWORD PTR [rdx+0x8]
     664:	sar    rdx,1
     667:	call   66c <botlish_entry_8+0x13>
			668: R_X86_64_PLT32	botlish_fn_8-0x4 ; ht_probe_next<HashTable, int>
     66c:	shl    rax,1
     66f:	or     rax,0x1
     673:	mov    rcx,rax
     676:	xor    rax,rax
     679:	test   rdx,rdx
     67c:	cmovne rax,rcx
     680:	mov    rsp,rbp
     683:	pop    rbp
     684:	ret
     685:	add    BYTE PTR [rax],al
	...

0000000000000688 <botlish_fn_9: ht_find_get<HashTable, str, int>>:
     688:	push   rbp
     689:	mov    rbp,rsp
     68c:	sub    rsp,0x30
     690:	mov    QWORD PTR [rsp],rbx
     694:	mov    QWORD PTR [rsp+0x8],r12
     699:	mov    QWORD PTR [rsp+0x10],r13
     69e:	mov    QWORD PTR [rsp+0x18],r14
     6a3:	mov    QWORD PTR [rsp+0x20],r15
     6a8:	mov    rbx,rdx
     6ab:	mov    r13,rdi
     6ae:	sar    rcx,1
     6b1:	mov    rdi,rcx
     6b4:	mov    r12,rsi
     6b7:	mov    rax,QWORD PTR [r12+0x18]
     6bc:	mov    rsi,QWORD PTR [rax]
     6bf:	mov    rcx,QWORD PTR [rsi+0x8]
     6c3:	mov    rax,rdi
     6c6:	shl    rax,1
     6c9:	or     rax,0x1
     6cd:	sar    rax,1
     6d0:	cmp    rax,rcx
     6d3:	jb     6e6 <botlish_fn_9+0x5e>
     6d9:	jmp    8ad <botlish_fn_9+0x225>
     6de:	mov    rsi,rax
     6e1:	jmp    6f1 <botlish_fn_9+0x69>
     6e6:	mov    r14,rdi
     6e9:	mov    rcx,QWORD PTR [rsi+0x10]
     6ed:	mov    rsi,QWORD PTR [rcx+rax*8]
     6f1:	test   rsi,0x1
     6f8:	mov    r15,rsi
     6fb:	jne    729 <botlish_fn_9+0xa1>
     701:	mov    edx,0x1
     706:	mov    rsi,r15
     709:	mov    rdi,r13
     70c:	call   711 <botlish_fn_9+0x89>
			70d: R_X86_64_PLT32	rt_int_cmp-0x4
     711:	mov    ecx,0x2
     716:	test   rax,rax
     719:	cmove  rcx,QWORD PTR [rip+0x1d7]        # 8f8 <botlish_fn_9+0x270>
     721:	mov    rsi,r15
     724:	jmp    73d <botlish_fn_9+0xb5>
     729:	mov    ecx,0x2
     72e:	mov    rsi,r15
     731:	cmp    rsi,0x1
     735:	cmove  rcx,QWORD PTR [rip+0x1bb]        # 8f8 <botlish_fn_9+0x270>
     73d:	cmp    rcx,0x6
     741:	je     885 <botlish_fn_9+0x1fd>
     747:	test   rsi,0x1
     74e:	jne    776 <botlish_fn_9+0xee>
     754:	mov    edx,0x3
     759:	mov    rdi,r13
     75c:	call   761 <botlish_fn_9+0xd9>
			75d: R_X86_64_PLT32	rt_int_cmp-0x4
     761:	mov    ecx,0x2
     766:	test   rax,rax
     769:	cmove  rcx,QWORD PTR [rip+0x187]        # 8f8 <botlish_fn_9+0x270>
     771:	jmp    787 <botlish_fn_9+0xff>
     776:	mov    ecx,0x2
     77b:	cmp    rsi,0x3
     77f:	cmove  rcx,QWORD PTR [rip+0x171]        # 8f8 <botlish_fn_9+0x270>
     787:	cmp    rcx,0x6
     78b:	jne    814 <botlish_fn_9+0x18c>
     791:	mov    rax,QWORD PTR [r12+0x18]
     796:	mov    rsi,QWORD PTR [rax+0x8]
     79a:	mov    rcx,QWORD PTR [rsi+0x8]
     79e:	mov    rdi,r14
     7a1:	mov    rax,rdi
     7a4:	shl    rax,1
     7a7:	or     rax,0x1
     7ab:	sar    rax,1
     7ae:	cmp    rax,rcx
     7b1:	jb     7c4 <botlish_fn_9+0x13c>
     7b7:	jmp    8d0 <botlish_fn_9+0x248>
     7bc:	mov    rsi,rax
     7bf:	jmp    7cf <botlish_fn_9+0x147>
     7c4:	mov    r14,rdi
     7c7:	mov    rcx,QWORD PTR [rsi+0x10]
     7cb:	mov    rsi,QWORD PTR [rcx+rax*8]
     7cf:	mov    rax,rsi
     7d2:	and    rax,rbx
     7d5:	test   rax,0x1
     7db:	jne    7fa <botlish_fn_9+0x172>
     7e1:	mov    rdx,rbx
     7e4:	mov    rdi,r13
     7e7:	call   7ec <botlish_fn_9+0x164>
			7e8: R_X86_64_PLT32	rt_value_eq-0x4
     7ec:	test   rax,rax
     7ef:	je     82b <botlish_fn_9+0x1a3>
     7f5:	jmp    80a <botlish_fn_9+0x182>
     7fa:	mov    eax,0x2
     7ff:	cmp    rsi,rbx
     802:	cmove  rax,QWORD PTR [rip+0xee]        # 8f8 <botlish_fn_9+0x270>
     80a:	cmp    rax,0x6
     80e:	je     857 <botlish_fn_9+0x1cf>
     814:	mov    rdx,r14
     817:	mov    rsi,r12
     81a:	mov    rdi,r13
     81d:	call   822 <botlish_fn_9+0x19a>
			81e: R_X86_64_PLT32	botlish_fn_8-0x4 ; ht_probe_next<HashTable, int>
     822:	test   rdx,rdx
     825:	jne    84f <botlish_fn_9+0x1c7>
     82b:	xor    rax,rax
     82e:	mov    rbx,QWORD PTR [rsp]
     832:	mov    r12,QWORD PTR [rsp+0x8]
     837:	mov    r13,QWORD PTR [rsp+0x10]
     83c:	mov    r14,QWORD PTR [rsp+0x18]
     841:	mov    r15,QWORD PTR [rsp+0x20]
     846:	add    rsp,0x30
     84a:	mov    rsp,rbp
     84d:	pop    rbp
     84e:	ret
     84f:	mov    rdi,rax
     852:	jmp    6b7 <botlish_fn_9+0x2f>
     857:	mov    rdx,r14
     85a:	shl    rdx,1
     85d:	mov    rax,rdx
     860:	or     rax,0x1
     864:	mov    rbx,QWORD PTR [rsp]
     868:	mov    r12,QWORD PTR [rsp+0x8]
     86d:	mov    r13,QWORD PTR [rsp+0x10]
     872:	mov    r14,QWORD PTR [rsp+0x18]
     877:	mov    r15,QWORD PTR [rsp+0x20]
     87c:	add    rsp,0x30
     880:	mov    rsp,rbp
     883:	pop    rbp
     884:	ret
     885:	mov    rax,0xffffffffffffffff
     88c:	mov    rbx,QWORD PTR [rsp]
     890:	mov    r12,QWORD PTR [rsp+0x8]
     895:	mov    r13,QWORD PTR [rsp+0x10]
     89a:	mov    r14,QWORD PTR [rsp+0x18]
     89f:	mov    r15,QWORD PTR [rsp+0x20]
     8a4:	add    rsp,0x30
     8a8:	mov    rsp,rbp
     8ab:	pop    rbp
     8ac:	ret
     8ad:	mov    rdx,rdi
     8b0:	shl    rdx,1
     8b3:	mov    r14,rdi
     8b6:	or     rdx,0x1
     8ba:	mov    rdi,r13
     8bd:	call   8c2 <botlish_fn_9+0x23a>
			8be: R_X86_64_PLT32	rt_mutarray_get-0x4
     8c2:	test   rax,rax
     8c5:	jne    6de <botlish_fn_9+0x56>
     8cb:	jmp    82b <botlish_fn_9+0x1a3>
     8d0:	mov    rdx,rdi
     8d3:	shl    rdx,1
     8d6:	mov    r14,rdi
     8d9:	or     rdx,0x1
     8dd:	mov    rdi,r13
     8e0:	call   8e5 <botlish_fn_9+0x25d>
			8e1: R_X86_64_PLT32	rt_mutarray_get-0x4
     8e5:	test   rax,rax
     8e8:	jne    7bc <botlish_fn_9+0x134>
     8ee:	jmp    82b <botlish_fn_9+0x1a3>
     8f3:	add    BYTE PTR [rax],al
     8f5:	add    BYTE PTR [rax],al
     8f7:	add    BYTE PTR [rsi],al
     8f9:	add    BYTE PTR [rax],al
     8fb:	add    BYTE PTR [rax],al
     8fd:	add    BYTE PTR [rax],al
	...

0000000000000900 <botlish_entry_9: ht_find_get<HashTable, str, int>>:
     900:	push   rbp
     901:	mov    rbp,rsp
     904:	mov    rsi,QWORD PTR [rdx]
     907:	mov    r8,QWORD PTR [rdx+0x8]
     90b:	mov    rcx,QWORD PTR [rdx+0x10]
     90f:	mov    rdx,r8
     912:	call   917 <botlish_entry_9+0x17>
			913: R_X86_64_PLT32	botlish_fn_9-0x4 ; ht_find_get<HashTable, str, int>
     917:	mov    rsp,rbp
     91a:	pop    rbp
     91b:	ret
     91c:	add    BYTE PTR [rax],al
	...

0000000000000920 <botlish_fn_10: ht_find_insert<HashTable, str, int, int>>:
     920:	push   rbp
     921:	mov    rbp,rsp
     924:	sub    rsp,0x40
     928:	mov    QWORD PTR [rsp+0x10],rbx
     92d:	mov    QWORD PTR [rsp+0x18],r12
     932:	mov    QWORD PTR [rsp+0x20],r13
     937:	mov    QWORD PTR [rsp+0x28],r14
     93c:	mov    QWORD PTR [rsp+0x30],r15
     941:	mov    r14,rdi
     944:	mov    r15,rdx
     947:	sar    rcx,1
     94a:	mov    rbx,rsi
     94d:	mov    r12,rcx
     950:	mov    r13,r8
     953:	mov    rax,QWORD PTR [rbx+0x18]
     957:	mov    rsi,QWORD PTR [rax]
     95a:	mov    rdx,QWORD PTR [rsi+0x8]
     95e:	mov    rcx,r12
     961:	shl    rcx,1
     964:	or     rcx,0x1
     968:	sar    rcx,1
     96b:	cmp    rcx,rdx
     96e:	jb     981 <botlish_fn_10+0x61>
     974:	jmp    cc1 <botlish_fn_10+0x3a1>
     979:	mov    rsi,rax
     97c:	jmp    989 <botlish_fn_10+0x69>
     981:	mov    rax,QWORD PTR [rsi+0x10]
     985:	mov    rsi,QWORD PTR [rax+rcx*8]
     989:	test   rsi,0x1
     990:	mov    QWORD PTR [rsp],rsi
     994:	jne    9c0 <botlish_fn_10+0xa0>
     99a:	mov    edx,0x1
     99f:	mov    rsi,QWORD PTR [rsp]
     9a3:	mov    rdi,r14
     9a6:	call   9ab <botlish_fn_10+0x8b>
			9a7: R_X86_64_PLT32	rt_int_cmp-0x4
     9ab:	mov    ecx,0x2
     9b0:	test   rax,rax
     9b3:	cmove  rcx,QWORD PTR [rip+0x34d]        # d08 <botlish_fn_10+0x3e8>
     9bb:	jmp    9d5 <botlish_fn_10+0xb5>
     9c0:	mov    ecx,0x2
     9c5:	mov    rsi,QWORD PTR [rsp]
     9c9:	cmp    rsi,0x1
     9cd:	cmove  rcx,QWORD PTR [rip+0x333]        # d08 <botlish_fn_10+0x3e8>
     9d5:	cmp    rcx,0x6
     9d9:	je     c15 <botlish_fn_10+0x2f5>
     9df:	mov    rsi,QWORD PTR [rsp]
     9e3:	test   rsi,0x1
     9ea:	jne    a16 <botlish_fn_10+0xf6>
     9f0:	mov    edx,0x3
     9f5:	mov    rsi,QWORD PTR [rsp]
     9f9:	mov    rdi,r14
     9fc:	call   a01 <botlish_fn_10+0xe1>
			9fd: R_X86_64_PLT32	rt_int_cmp-0x4
     a01:	mov    ecx,0x2
     a06:	test   rax,rax
     a09:	cmove  rcx,QWORD PTR [rip+0x2f7]        # d08 <botlish_fn_10+0x3e8>
     a11:	jmp    a2b <botlish_fn_10+0x10b>
     a16:	mov    ecx,0x2
     a1b:	mov    rsi,QWORD PTR [rsp]
     a1f:	cmp    rsi,0x3
     a23:	cmove  rcx,QWORD PTR [rip+0x2dd]        # d08 <botlish_fn_10+0x3e8>
     a2b:	cmp    rcx,0x6
     a2f:	je     a46 <botlish_fn_10+0x126>
     a35:	mov    QWORD PTR [rsp+0x8],r12
     a3a:	mov    r12,r15
     a3d:	mov    rsi,QWORD PTR [rsp]
     a41:	jmp    ad1 <botlish_fn_10+0x1b1>
     a46:	mov    rax,QWORD PTR [rbx+0x18]
     a4a:	mov    rsi,QWORD PTR [rax+0x8]
     a4e:	mov    rax,QWORD PTR [rsi+0x8]
     a52:	mov    rcx,r12
     a55:	shl    rcx,1
     a58:	or     rcx,0x1
     a5c:	sar    rcx,1
     a5f:	cmp    rcx,rax
     a62:	jb     a78 <botlish_fn_10+0x158>
     a68:	jmp    ce1 <botlish_fn_10+0x3c1>
     a6d:	mov    rsi,rax
     a70:	mov    r12,r15
     a73:	jmp    a88 <botlish_fn_10+0x168>
     a78:	mov    QWORD PTR [rsp+0x8],r12
     a7d:	mov    rax,QWORD PTR [rsi+0x10]
     a81:	mov    rsi,QWORD PTR [rax+rcx*8]
     a85:	mov    r12,r15
     a88:	mov    rax,rsi
     a8b:	and    rax,r12
     a8e:	test   rax,0x1
     a94:	jne    ab3 <botlish_fn_10+0x193>
     a9a:	mov    rdx,r12
     a9d:	mov    rdi,r14
     aa0:	call   aa5 <botlish_fn_10+0x185>
			aa1: R_X86_64_PLT32	rt_value_eq-0x4
     aa5:	test   rax,rax
     aa8:	je     bc0 <botlish_fn_10+0x2a0>
     aae:	jmp    ac3 <botlish_fn_10+0x1a3>
     ab3:	mov    eax,0x2
     ab8:	cmp    rsi,r12
     abb:	cmove  rax,QWORD PTR [rip+0x245]        # d08 <botlish_fn_10+0x3e8>
     ac3:	cmp    rax,0x6
     ac7:	je     c0b <botlish_fn_10+0x2eb>
     acd:	mov    rsi,QWORD PTR [rsp]
     ad1:	test   rsi,0x1
     ad8:	jne    b04 <botlish_fn_10+0x1e4>
     ade:	mov    edx,0x5
     ae3:	mov    rsi,QWORD PTR [rsp]
     ae7:	mov    rdi,r14
     aea:	call   aef <botlish_fn_10+0x1cf>
			aeb: R_X86_64_PLT32	rt_int_cmp-0x4
     aef:	mov    ecx,0x2
     af4:	test   rax,rax
     af7:	cmove  rcx,QWORD PTR [rip+0x209]        # d08 <botlish_fn_10+0x3e8>
     aff:	jmp    b19 <botlish_fn_10+0x1f9>
     b04:	mov    ecx,0x2
     b09:	mov    rsi,QWORD PTR [rsp]
     b0d:	cmp    rsi,0x5
     b11:	cmove  rcx,QWORD PTR [rip+0x1ef]        # d08 <botlish_fn_10+0x3e8>
     b19:	cmp    rcx,0x6
     b1d:	je     b2d <botlish_fn_10+0x20d>
     b23:	mov    rdx,QWORD PTR [rsp+0x8]
     b28:	jmp    b7e <botlish_fn_10+0x25e>
     b2d:	test   r13,0x1
     b34:	jne    b5f <botlish_fn_10+0x23f>
     b3a:	mov    edx,0x1
     b3f:	mov    rsi,r13
     b42:	mov    rdi,r14
     b45:	call   b4a <botlish_fn_10+0x22a>
			b46: R_X86_64_PLT32	rt_int_cmp-0x4
     b4a:	mov    ecx,0x2
     b4f:	test   rax,rax
     b52:	cmovl  rcx,QWORD PTR [rip+0x1ae]        # d08 <botlish_fn_10+0x3e8>
     b5a:	jmp    b6f <botlish_fn_10+0x24f>
     b5f:	mov    ecx,0x2
     b64:	test   r13,r13
     b67:	cmovle rcx,QWORD PTR [rip+0x199]        # d08 <botlish_fn_10+0x3e8>
     b6f:	cmp    rcx,0x6
     b73:	je     ba4 <botlish_fn_10+0x284>
     b79:	mov    rdx,QWORD PTR [rsp+0x8]
     b7e:	mov    rsi,rbx
     b81:	mov    rdi,r14
     b84:	call   b89 <botlish_fn_10+0x269>
			b85: R_X86_64_PLT32	botlish_fn_8-0x4 ; ht_probe_next<HashTable, int>
     b89:	mov    QWORD PTR [rsp+0x8],rax
     b8e:	test   rdx,rdx
     b91:	je     bc0 <botlish_fn_10+0x2a0>
     b97:	mov    r15,r12
     b9a:	mov    r12,QWORD PTR [rsp+0x8]
     b9f:	jmp    953 <botlish_fn_10+0x33>
     ba4:	mov    rdx,QWORD PTR [rsp+0x8]
     ba9:	mov    rsi,rbx
     bac:	mov    rdi,r14
     baf:	call   bb4 <botlish_fn_10+0x294>
			bb0: R_X86_64_PLT32	botlish_fn_8-0x4 ; ht_probe_next<HashTable, int>
     bb4:	mov    rcx,rax
     bb7:	test   rdx,rdx
     bba:	jne    be5 <botlish_fn_10+0x2c5>
     bc0:	xor    rax,rax
     bc3:	mov    rbx,QWORD PTR [rsp+0x10]
     bc8:	mov    r12,QWORD PTR [rsp+0x18]
     bcd:	mov    r13,QWORD PTR [rsp+0x20]
     bd2:	mov    r14,QWORD PTR [rsp+0x28]
     bd7:	mov    r15,QWORD PTR [rsp+0x30]
     bdc:	add    rsp,0x40
     be0:	mov    rsp,rbp
     be3:	pop    rbp
     be4:	ret
     be5:	mov    rax,QWORD PTR [rsp+0x8]
     bea:	shl    rax,1
     bed:	mov    QWORD PTR [rsp+0x8],rax
     bf2:	or     rax,0x1
     bf6:	mov    QWORD PTR [rsp+0x8],rax
     bfb:	mov    r15,r12
     bfe:	mov    r13,QWORD PTR [rsp+0x8]
     c03:	mov    r12,rcx
     c06:	jmp    953 <botlish_fn_10+0x33>
     c0b:	mov    rax,QWORD PTR [rsp+0x8]
     c10:	jmp    c73 <botlish_fn_10+0x353>
     c15:	mov    rax,r13
     c18:	mov    QWORD PTR [rsp+0x8],r12
     c1d:	test   rax,0x1
     c23:	jne    c4e <botlish_fn_10+0x32e>
     c29:	mov    edx,0x1
     c2e:	mov    rdi,r14
     c31:	mov    rsi,r13
     c34:	call   c39 <botlish_fn_10+0x319>
			c35: R_X86_64_PLT32	rt_int_cmp-0x4
     c39:	mov    ecx,0x2
     c3e:	test   rax,rax
     c41:	cmovge rcx,QWORD PTR [rip+0xbf]        # d08 <botlish_fn_10+0x3e8>
     c49:	jmp    c64 <botlish_fn_10+0x344>
     c4e:	mov    ecx,0x2
     c53:	mov    rax,r13
     c56:	mov    rdx,r13
     c59:	test   rax,rdx
     c5c:	cmovg  rcx,QWORD PTR [rip+0xa4]        # d08 <botlish_fn_10+0x3e8>
     c64:	cmp    rcx,0x6
     c68:	je     c9c <botlish_fn_10+0x37c>
     c6e:	mov    rax,QWORD PTR [rsp+0x8]
     c73:	shl    rax,1
     c76:	or     rax,0x1
     c7a:	mov    rbx,QWORD PTR [rsp+0x10]
     c7f:	mov    r12,QWORD PTR [rsp+0x18]
     c84:	mov    r13,QWORD PTR [rsp+0x20]
     c89:	mov    r14,QWORD PTR [rsp+0x28]
     c8e:	mov    r15,QWORD PTR [rsp+0x30]
     c93:	add    rsp,0x40
     c97:	mov    rsp,rbp
     c9a:	pop    rbp
     c9b:	ret
     c9c:	mov    rax,r13
     c9f:	mov    rbx,QWORD PTR [rsp+0x10]
     ca4:	mov    r12,QWORD PTR [rsp+0x18]
     ca9:	mov    r13,QWORD PTR [rsp+0x20]
     cae:	mov    r14,QWORD PTR [rsp+0x28]
     cb3:	mov    r15,QWORD PTR [rsp+0x30]
     cb8:	add    rsp,0x40
     cbc:	mov    rsp,rbp
     cbf:	pop    rbp
     cc0:	ret
     cc1:	mov    rdx,r12
     cc4:	shl    rdx,1
     cc7:	or     rdx,0x1
     ccb:	mov    rdi,r14
     cce:	call   cd3 <botlish_fn_10+0x3b3>
			ccf: R_X86_64_PLT32	rt_mutarray_get-0x4
     cd3:	test   rax,rax
     cd6:	jne    979 <botlish_fn_10+0x59>
     cdc:	jmp    bc0 <botlish_fn_10+0x2a0>
     ce1:	mov    rdx,r12
     ce4:	shl    rdx,1
     ce7:	mov    QWORD PTR [rsp+0x8],r12
     cec:	or     rdx,0x1
     cf0:	mov    rdi,r14
     cf3:	call   cf8 <botlish_fn_10+0x3d8>
			cf4: R_X86_64_PLT32	rt_mutarray_get-0x4
     cf8:	test   rax,rax
     cfb:	jne    a6d <botlish_fn_10+0x14d>
     d01:	jmp    bc0 <botlish_fn_10+0x2a0>
     d06:	add    BYTE PTR [rax],al
     d08:	(bad)
     d09:	add    BYTE PTR [rax],al
     d0b:	add    BYTE PTR [rax],al
     d0d:	add    BYTE PTR [rax],al
	...

0000000000000d10 <botlish_entry_10: ht_find_insert<HashTable, str, int, int>>:
     d10:	push   rbp
     d11:	mov    rbp,rsp
     d14:	mov    rsi,QWORD PTR [rdx]
     d17:	mov    r9,QWORD PTR [rdx+0x8]
     d1b:	mov    rcx,QWORD PTR [rdx+0x10]
     d1f:	mov    r8,QWORD PTR [rdx+0x18]
     d23:	mov    rdx,r9
     d26:	call   d2b <botlish_entry_10+0x1b>
			d27: R_X86_64_PLT32	botlish_fn_10-0x4 ; ht_find_insert<HashTable, str, int, int>
     d2b:	mov    rsp,rbp
     d2e:	pop    rbp
     d2f:	ret

0000000000000d30 <botlish_fn_11: ht_get<HashTable, str>>:
     d30:	push   rbp
     d31:	mov    rbp,rsp
     d34:	sub    rsp,0x20
     d38:	mov    QWORD PTR [rsp],rbx
     d3c:	mov    QWORD PTR [rsp+0x8],r12
     d41:	mov    QWORD PTR [rsp+0x10],r13
     d46:	mov    r12,rdi
     d49:	mov    r13,rdx
     d4c:	mov    rbx,rsi
     d4f:	mov    rdx,r13
     d52:	mov    rdi,r12
     d55:	call   d5a <botlish_fn_11+0x2a>
			d56: R_X86_64_PLT32	botlish_fn_7-0x4 ; ht_probe_start<HashTable, str>
     d5a:	test   rax,rax
     d5d:	mov    rcx,rax
     d60:	je     e06 <botlish_fn_11+0xd6>
     d66:	mov    rdx,r13
     d69:	mov    rsi,rbx
     d6c:	mov    rdi,r12
     d6f:	call   d74 <botlish_fn_11+0x44>
			d70: R_X86_64_PLT32	botlish_fn_9-0x4 ; ht_find_get<HashTable, str, int>
     d74:	mov    rcx,rax
     d77:	mov    r13,rax
     d7a:	test   rax,rcx
     d7d:	je     e06 <botlish_fn_11+0xd6>
     d83:	mov    rax,r13
     d86:	test   rax,0x1
     d8c:	jne    dba <botlish_fn_11+0x8a>
     d92:	mov    edx,0x1
     d97:	mov    rsi,r13
     d9a:	mov    rdi,r12
     d9d:	call   da2 <botlish_fn_11+0x72>
			d9e: R_X86_64_PLT32	rt_int_cmp-0x4
     da2:	mov    ecx,0x2
     da7:	test   rax,rax
     daa:	cmovl  rcx,QWORD PTR [rip+0xd6]        # e88 <botlish_fn_11+0x158>
     db2:	mov    rax,r13
     db5:	jmp    dcd <botlish_fn_11+0x9d>
     dba:	mov    ecx,0x2
     dbf:	mov    rax,r13
     dc2:	test   rax,rax
     dc5:	cmovle rcx,QWORD PTR [rip+0xbb]        # e88 <botlish_fn_11+0x158>
     dcd:	cmp    rcx,0x6
     dd1:	je     e44 <botlish_fn_11+0x114>
     dd7:	mov    rcx,QWORD PTR [rbx+0x18]
     ddb:	mov    rsi,QWORD PTR [rcx+0x10]
     ddf:	test   rax,0x1
     de5:	je     e60 <botlish_fn_11+0x130>
     deb:	mov    rdx,QWORD PTR [rsi+0x8]
     def:	mov    rcx,rax
     df2:	sar    rcx,1
     df5:	mov    r13,rax
     df8:	cmp    rcx,rdx
     dfb:	jb     e25 <botlish_fn_11+0xf5>
     e01:	jmp    e6b <botlish_fn_11+0x13b>
     e06:	xor    rax,rax
     e09:	mov    rbx,QWORD PTR [rsp]
     e0d:	mov    r12,QWORD PTR [rsp+0x8]
     e12:	mov    r13,QWORD PTR [rsp+0x10]
     e17:	add    rsp,0x20
     e1b:	mov    rsp,rbp
     e1e:	pop    rbp
     e1f:	ret
     e20:	jmp    e2d <botlish_fn_11+0xfd>
     e25:	mov    rax,QWORD PTR [rsi+0x10]
     e29:	mov    rax,QWORD PTR [rax+rcx*8]
     e2d:	mov    rbx,QWORD PTR [rsp]
     e31:	mov    r12,QWORD PTR [rsp+0x8]
     e36:	mov    r13,QWORD PTR [rsp+0x10]
     e3b:	add    rsp,0x20
     e3f:	mov    rsp,rbp
     e42:	pop    rbp
     e43:	ret
     e44:	mov    eax,0xa
     e49:	mov    rbx,QWORD PTR [rsp]
     e4d:	mov    r12,QWORD PTR [rsp+0x8]
     e52:	mov    r13,QWORD PTR [rsp+0x10]
     e57:	add    rsp,0x20
     e5b:	mov    rsp,rbp
     e5e:	pop    rbp
     e5f:	ret
     e60:	mov    rdx,rax
     e63:	mov    rdi,r12
     e66:	jmp    e71 <botlish_fn_11+0x141>
     e6b:	mov    rdx,r13
     e6e:	mov    rdi,r12
     e71:	mov    rdi,r12
     e74:	call   e79 <botlish_fn_11+0x149>
			e75: R_X86_64_PLT32	rt_mutarray_get-0x4
     e79:	test   rax,rax
     e7c:	jne    e2d <botlish_fn_11+0xfd>
     e82:	jmp    e06 <botlish_fn_11+0xd6>
     e87:	add    BYTE PTR [rsi],al
     e89:	add    BYTE PTR [rax],al
     e8b:	add    BYTE PTR [rax],al
     e8d:	add    BYTE PTR [rax],al
	...

0000000000000e90 <botlish_entry_11: ht_get<HashTable, str>>:
     e90:	push   rbp
     e91:	mov    rbp,rsp
     e94:	mov    rsi,QWORD PTR [rdx]
     e97:	mov    rdx,QWORD PTR [rdx+0x8]
     e9b:	call   ea0 <botlish_entry_11+0x10>
			e9c: R_X86_64_PLT32	botlish_fn_11-0x4 ; ht_get<HashTable, str>
     ea0:	mov    rsp,rbp
     ea3:	pop    rbp
     ea4:	ret
     ea5:	add    BYTE PTR [rax],al
	...

0000000000000ea8 <botlish_fn_12: ht_contains<HashTable, str>>:
     ea8:	push   rbp
     ea9:	mov    rbp,rsp
     eac:	sub    rsp,0x20
     eb0:	mov    QWORD PTR [rsp],rbx
     eb4:	mov    QWORD PTR [rsp+0x8],r12
     eb9:	mov    QWORD PTR [rsp+0x10],r15
     ebe:	mov    rbx,rdx
     ec1:	mov    r12,rsi
     ec4:	mov    r15,rdi
     ec7:	mov    rdx,rbx
     eca:	mov    rsi,r12
     ecd:	mov    rdi,r15
     ed0:	call   ed5 <botlish_fn_12+0x2d>
			ed1: R_X86_64_PLT32	botlish_fn_7-0x4 ; ht_probe_start<HashTable, str>
     ed5:	test   rax,rax
     ed8:	mov    rcx,rax
     edb:	je     ef8 <botlish_fn_12+0x50>
     ee1:	mov    rdx,rbx
     ee4:	mov    rsi,r12
     ee7:	mov    rdi,r15
     eea:	call   eef <botlish_fn_12+0x47>
			eeb: R_X86_64_PLT32	botlish_fn_9-0x4 ; ht_find_get<HashTable, str, int>
     eef:	test   rax,rax
     ef2:	jne    f12 <botlish_fn_12+0x6a>
     ef8:	xor    rax,rax
     efb:	mov    rbx,QWORD PTR [rsp]
     eff:	mov    r12,QWORD PTR [rsp+0x8]
     f04:	mov    r15,QWORD PTR [rsp+0x10]
     f09:	add    rsp,0x20
     f0d:	mov    rsp,rbp
     f10:	pop    rbp
     f11:	ret
     f12:	test   rax,0x1
     f18:	mov    rsi,rax
     f1b:	jne    f46 <botlish_fn_12+0x9e>
     f21:	mov    edx,0x1
     f26:	mov    rdi,r15
     f29:	call   f2e <botlish_fn_12+0x86>
			f2a: R_X86_64_PLT32	rt_int_cmp-0x4
     f2e:	mov    ecx,0x2
     f33:	test   rax,rax
     f36:	mov    rax,rcx
     f39:	cmovge rax,QWORD PTR [rip+0x2f]        # f70 <botlish_fn_12+0xc8>
     f41:	jmp    f56 <botlish_fn_12+0xae>
     f46:	mov    eax,0x2
     f4b:	test   rsi,rsi
     f4e:	cmovg  rax,QWORD PTR [rip+0x1a]        # f70 <botlish_fn_12+0xc8>
     f56:	mov    rbx,QWORD PTR [rsp]
     f5a:	mov    r12,QWORD PTR [rsp+0x8]
     f5f:	mov    r15,QWORD PTR [rsp+0x10]
     f64:	add    rsp,0x20
     f68:	mov    rsp,rbp
     f6b:	pop    rbp
     f6c:	ret
     f6d:	add    BYTE PTR [rax],al
     f6f:	add    BYTE PTR [rsi],al
     f71:	add    BYTE PTR [rax],al
     f73:	add    BYTE PTR [rax],al
     f75:	add    BYTE PTR [rax],al
	...

0000000000000f78 <botlish_entry_12: ht_contains<HashTable, str>>:
     f78:	push   rbp
     f79:	mov    rbp,rsp
     f7c:	mov    rsi,QWORD PTR [rdx]
     f7f:	mov    rdx,QWORD PTR [rdx+0x8]
     f83:	call   f88 <botlish_entry_12+0x10>
			f84: R_X86_64_PLT32	botlish_fn_12-0x4 ; ht_contains<HashTable, str>
     f88:	mov    rsp,rbp
     f8b:	pop    rbp
     f8c:	ret
     f8d:	add    BYTE PTR [rax],al
	...

0000000000000f90 <botlish_fn_13: ht_rehash_probe<mutarray, int, int>>:
     f90:	push   rbp
     f91:	mov    rbp,rsp
     f94:	sub    rsp,0x60
     f98:	mov    QWORD PTR [rsp+0x30],rbx
     f9d:	mov    QWORD PTR [rsp+0x38],r12
     fa2:	mov    QWORD PTR [rsp+0x40],r13
     fa7:	mov    QWORD PTR [rsp+0x48],r14
     fac:	mov    QWORD PTR [rsp+0x50],r15
     fb1:	mov    r15,rdi
     fb4:	mov    QWORD PTR [rsp],rsi
     fb8:	mov    rax,rsi
     fbb:	mov    QWORD PTR [rsp+0x8],rdx
     fc0:	mov    QWORD PTR [rsp+0x10],rcx
     fc5:	mov    r14,rcx
     fc8:	sar    r14,1
     fcb:	mov    r13,rcx
     fce:	mov    rbx,r14
     fd1:	neg    rbx
     fd4:	cmovs  rbx,r14
     fd8:	mov    rsi,rdx
     fdb:	test   rsi,0x1
     fe2:	je     1177 <botlish_fn_13+0x1e7>
     fe8:	mov    r12,rax
     feb:	mov    rcx,QWORD PTR [r12+0x8]
     ff0:	mov    rax,rsi
     ff3:	sar    rax,1
     ff6:	mov    QWORD PTR [rsp+0x20],rsi
     ffb:	cmp    rax,rcx
     ffe:	jb     1011 <botlish_fn_13+0x81>
    1004:	jmp    117f <botlish_fn_13+0x1ef>
    1009:	mov    rsi,rax
    100c:	jmp    101a <botlish_fn_13+0x8a>
    1011:	mov    rcx,QWORD PTR [r12+0x10]
    1016:	mov    rsi,QWORD PTR [rcx+rax*8]
    101a:	test   rsi,0x1
    1021:	jne    1042 <botlish_fn_13+0xb2>
    1027:	mov    edx,0x1
    102c:	mov    rdi,r15
    102f:	call   1034 <botlish_fn_13+0xa4>
			1030: R_X86_64_PLT32	rt_value_eq-0x4
    1034:	test   rax,rax
    1037:	je     1112 <botlish_fn_13+0x182>
    103d:	jmp    1053 <botlish_fn_13+0xc3>
    1042:	mov    eax,0x2
    1047:	cmp    rsi,0x1
    104b:	cmove  rax,QWORD PTR [rip+0x14d]        # 11a0 <botlish_fn_13+0x210>
    1053:	cmp    rax,0x6
    1057:	je     1150 <botlish_fn_13+0x1c0>
    105d:	mov    QWORD PTR [rsp+0x18],0x3
    1066:	mov    rsi,QWORD PTR [rsp+0x20]
    106b:	test   rsi,0x1
    1072:	je     108e <botlish_fn_13+0xfe>
    1078:	mov    rsi,QWORD PTR [rsp+0x20]
    107d:	add    rsi,0x2
    1081:	seto   dil
    1085:	test   dil,dil
    1088:	je     10a3 <botlish_fn_13+0x113>
    108e:	mov    edx,0x3
    1093:	mov    rsi,QWORD PTR [rsp+0x20]
    1098:	mov    rdi,r15
    109b:	call   10a0 <botlish_fn_13+0x110>
			109c: R_X86_64_PLT32	rt_int_add-0x4
    10a0:	mov    rsi,rax
    10a3:	mov    QWORD PTR [rsp+0x8],rsi
    10a8:	mov    r10,rsi
    10ab:	and    r10,r13
    10ae:	test   r10,0x1
    10b5:	je     10fe <botlish_fn_13+0x16e>
    10bb:	cmp    r13,0x1
    10bf:	je     10fe <botlish_fn_13+0x16e>
    10c5:	mov    rax,rsi
    10c8:	sar    rax,1
    10cb:	cqo
    10cd:	cmp    r14,0xffffffffffffffff
    10d1:	jne    10e1 <botlish_fn_13+0x151>
    10d7:	mov    edx,0x0
    10dc:	jmp    10e4 <botlish_fn_13+0x154>
    10e1:	idiv   r14
    10e4:	lea    rax,[rdx+rbx*1]
    10e8:	test   rdx,rdx
    10eb:	cmovl  rdx,rax
    10ef:	shl    rdx,1
    10f2:	or     rdx,0x1
    10f6:	mov    rax,rdx
    10f9:	jmp    1137 <botlish_fn_13+0x1a7>
    10fe:	mov    rdx,r13
    1101:	mov    rdi,r15
    1104:	call   1109 <botlish_fn_13+0x179>
			1105: R_X86_64_PLT32	rt_int_mod-0x4
    1109:	test   rax,rax
    110c:	jne    1137 <botlish_fn_13+0x1a7>
    1112:	xor    rax,rax
    1115:	mov    rbx,QWORD PTR [rsp+0x30]
    111a:	mov    r12,QWORD PTR [rsp+0x38]
    111f:	mov    r13,QWORD PTR [rsp+0x40]
    1124:	mov    r14,QWORD PTR [rsp+0x48]
    1129:	mov    r15,QWORD PTR [rsp+0x50]
    112e:	add    rsp,0x60
    1132:	mov    rsp,rbp
    1135:	pop    rbp
    1136:	ret
    1137:	mov    QWORD PTR [rsp],r12
    113b:	mov    QWORD PTR [rsp+0x8],rax
    1140:	mov    QWORD PTR [rsp+0x10],r13
    1145:	mov    rsi,rax
    1148:	mov    rax,r12
    114b:	jmp    fdb <botlish_fn_13+0x4b>
    1150:	mov    rax,QWORD PTR [rsp+0x20]
    1155:	mov    rbx,QWORD PTR [rsp+0x30]
    115a:	mov    r12,QWORD PTR [rsp+0x38]
    115f:	mov    r13,QWORD PTR [rsp+0x40]
    1164:	mov    r14,QWORD PTR [rsp+0x48]
    1169:	mov    r15,QWORD PTR [rsp+0x50]
    116e:	add    rsp,0x60
    1172:	mov    rsp,rbp
    1175:	pop    rbp
    1176:	ret
    1177:	mov    r12,rax
    117a:	mov    QWORD PTR [rsp+0x20],rsi
    117f:	mov    rdx,QWORD PTR [rsp+0x20]
    1184:	mov    rsi,r12
    1187:	mov    rdi,r15
    118a:	call   118f <botlish_fn_13+0x1ff>
			118b: R_X86_64_PLT32	rt_mutarray_get-0x4
    118f:	test   rax,rax
    1192:	jne    1009 <botlish_fn_13+0x79>
    1198:	jmp    1112 <botlish_fn_13+0x182>
    119d:	add    BYTE PTR [rax],al
    119f:	add    BYTE PTR [rsi],al
    11a1:	add    BYTE PTR [rax],al
    11a3:	add    BYTE PTR [rax],al
    11a5:	add    BYTE PTR [rax],al
	...

00000000000011a8 <botlish_entry_13: ht_rehash_probe<mutarray, int, int>>:
    11a8:	push   rbp
    11a9:	mov    rbp,rsp
    11ac:	mov    rsi,QWORD PTR [rdx]
    11af:	mov    r8,QWORD PTR [rdx+0x8]
    11b3:	mov    rcx,QWORD PTR [rdx+0x10]
    11b7:	mov    rdx,r8
    11ba:	call   11bf <botlish_entry_13+0x17>
			11bb: R_X86_64_PLT32	botlish_fn_13-0x4 ; ht_rehash_probe<mutarray, int, int>
    11bf:	mov    rsp,rbp
    11c2:	pop    rbp
    11c3:	ret

00000000000011c4 <botlish_fn_14: ht_rehash_insert<HashTable, int, any, any>>:
    11c4:	push   rbp
    11c5:	mov    rbp,rsp
    11c8:	sub    rsp,0x70
    11cc:	mov    QWORD PTR [rsp+0x40],rbx
    11d1:	mov    QWORD PTR [rsp+0x48],r12
    11d6:	mov    QWORD PTR [rsp+0x50],r13
    11db:	mov    QWORD PTR [rsp+0x58],r14
    11e0:	mov    QWORD PTR [rsp+0x60],r15
    11e5:	mov    r15,rdi
    11e8:	mov    QWORD PTR [rsp],rsi
    11ec:	mov    QWORD PTR [rsp+0x8],rdx
    11f1:	mov    r12,rdx
    11f4:	mov    QWORD PTR [rsp+0x10],rcx
    11f9:	mov    QWORD PTR [rsp+0x30],rcx
    11fe:	mov    QWORD PTR [rsp+0x18],r8
    1203:	mov    r14,r8
    1206:	mov    rax,QWORD PTR [rsi+0x18]
    120a:	mov    rbx,rsi
    120d:	mov    rsi,QWORD PTR [rax]
    1210:	mov    QWORD PTR [rsp+0x20],rsi
    1215:	mov    QWORD PTR [rsp+0x38],rsi
    121a:	mov    rsi,QWORD PTR [rsp+0x30]
    121f:	mov    rdi,r15
    1222:	call   1227 <botlish_fn_14+0x63>
			1223: R_X86_64_PLT32	rt_hash-0x4
    1227:	test   rax,rax
    122a:	je     13a9 <botlish_fn_14+0x1e5>
    1230:	mov    QWORD PTR [rsp+0x28],rax
    1235:	mov    r13,r12
    1238:	mov    rcx,rax
    123b:	and    rcx,r13
    123e:	test   rcx,0x1
    1245:	jne    1253 <botlish_fn_14+0x8f>
    124b:	mov    rsi,rax
    124e:	jmp    12aa <botlish_fn_14+0xe6>
    1253:	cmp    r13,0x1
    1257:	jne    1265 <botlish_fn_14+0xa1>
    125d:	mov    rsi,rax
    1260:	jmp    12aa <botlish_fn_14+0xe6>
    1265:	sar    rax,1
    1268:	mov    rcx,r13
    126b:	sar    rcx,1
    126e:	cqo
    1270:	cmp    rcx,0xffffffffffffffff
    1274:	jne    1284 <botlish_fn_14+0xc0>
    127a:	mov    edx,0x0
    127f:	jmp    1287 <botlish_fn_14+0xc3>
    1284:	idiv   rcx
    1287:	mov    rax,rcx
    128a:	neg    rax
    128d:	cmovs  rax,rcx
    1291:	add    rax,rdx
    1294:	test   rdx,rdx
    1297:	cmovl  rdx,rax
    129b:	shl    rdx,1
    129e:	or     rdx,0x1
    12a2:	mov    r12,r13
    12a5:	jmp    12c4 <botlish_fn_14+0x100>
    12aa:	mov    rdx,r13
    12ad:	mov    rdi,r15
    12b0:	call   12b5 <botlish_fn_14+0xf1>
			12b1: R_X86_64_PLT32	rt_int_mod-0x4
    12b5:	mov    r12,r13
    12b8:	test   rax,rax
    12bb:	je     13a9 <botlish_fn_14+0x1e5>
    12c1:	mov    rdx,rax
    12c4:	mov    QWORD PTR [rsp+0x28],rdx
    12c9:	mov    rcx,r12
    12cc:	mov    rsi,QWORD PTR [rsp+0x38]
    12d1:	mov    rdi,r15
    12d4:	call   12d9 <botlish_fn_14+0x115>
			12d5: R_X86_64_PLT32	botlish_fn_13-0x4 ; ht_rehash_probe<mutarray, int, int>
    12d9:	mov    rcx,rax
    12dc:	mov    r12,rax
    12df:	test   rax,rcx
    12e2:	je     13a9 <botlish_fn_14+0x1e5>
    12e8:	mov    r9,QWORD PTR [rbx+0x18]
    12ec:	mov    rsi,QWORD PTR [r9]
    12ef:	mov    rax,r12
    12f2:	test   rax,0x1
    12f8:	je     1406 <botlish_fn_14+0x242>
    12fe:	mov    rdx,QWORD PTR [rsi+0x8]
    1302:	mov    rax,r12
    1305:	mov    rcx,rax
    1308:	sar    rcx,1
    130b:	cmp    rcx,rdx
    130e:	jae    1406 <botlish_fn_14+0x242>
    1314:	mov    rdx,QWORD PTR [rsi+0x18]
    1318:	test   rdx,rdx
    131b:	je     1406 <botlish_fn_14+0x242>
    1321:	mov    rax,QWORD PTR [rsi+0x10]
    1325:	mov    QWORD PTR [rax+rcx*8],0x3
    132d:	mov    rax,QWORD PTR [rbx+0x18]
    1331:	mov    rsi,QWORD PTR [rax+0x8]
    1335:	test   r12,0x1
    133c:	je     1424 <botlish_fn_14+0x260>
    1342:	mov    rdx,QWORD PTR [rsi+0x8]
    1346:	mov    rdi,r12
    1349:	sar    rdi,1
    134c:	cmp    rdi,rdx
    134f:	jae    142e <botlish_fn_14+0x26a>
    1355:	mov    rcx,QWORD PTR [rsi+0x18]
    1359:	test   rcx,rcx
    135c:	je     1438 <botlish_fn_14+0x274>
    1362:	mov    rcx,QWORD PTR [rsp+0x30]
    1367:	mov    rax,QWORD PTR [rsi+0x10]
    136b:	mov    QWORD PTR [rax+rdi*8],rcx
    136f:	mov    rax,QWORD PTR [rbx+0x18]
    1373:	mov    rsi,QWORD PTR [rax+0x10]
    1377:	test   r12,0x1
    137e:	je     1456 <botlish_fn_14+0x292>
    1384:	mov    rdx,QWORD PTR [rsi+0x8]
    1388:	mov    rdi,r12
    138b:	sar    rdi,1
    138e:	cmp    rdi,rdx
    1391:	jae    1464 <botlish_fn_14+0x2a0>
    1397:	mov    rax,QWORD PTR [rsi+0x18]
    139b:	test   rax,rax
    139e:	jne    13d6 <botlish_fn_14+0x212>
    13a4:	jmp    1472 <botlish_fn_14+0x2ae>
    13a9:	xor    rax,rax
    13ac:	mov    rbx,QWORD PTR [rsp+0x40]
    13b1:	mov    r12,QWORD PTR [rsp+0x48]
    13b6:	mov    r13,QWORD PTR [rsp+0x50]
    13bb:	mov    r14,QWORD PTR [rsp+0x58]
    13c0:	mov    r15,QWORD PTR [rsp+0x60]
    13c5:	add    rsp,0x70
    13c9:	mov    rsp,rbp
    13cc:	pop    rbp
    13cd:	ret
    13ce:	mov    rax,rbx
    13d1:	jmp    13e4 <botlish_fn_14+0x220>
    13d6:	mov    rcx,r14
    13d9:	mov    rax,QWORD PTR [rsi+0x10]
    13dd:	mov    QWORD PTR [rax+rdi*8],rcx
    13e1:	mov    rax,rbx
    13e4:	mov    rbx,QWORD PTR [rsp+0x40]
    13e9:	mov    r12,QWORD PTR [rsp+0x48]
    13ee:	mov    r13,QWORD PTR [rsp+0x50]
    13f3:	mov    r14,QWORD PTR [rsp+0x58]
    13f8:	mov    r15,QWORD PTR [rsp+0x60]
    13fd:	add    rsp,0x70
    1401:	mov    rsp,rbp
    1404:	pop    rbp
    1405:	ret
    1406:	mov    ecx,0x3
    140b:	mov    rdx,r12
    140e:	mov    rdi,r15
    1411:	call   1416 <botlish_fn_14+0x252>
			1412: R_X86_64_PLT32	rt_mutarray_set-0x4
    1416:	test   rax,rax
    1419:	jne    132d <botlish_fn_14+0x169>
    141f:	jmp    13a9 <botlish_fn_14+0x1e5>
    1424:	mov    rcx,QWORD PTR [rsp+0x30]
    1429:	jmp    143d <botlish_fn_14+0x279>
    142e:	mov    rcx,QWORD PTR [rsp+0x30]
    1433:	jmp    143d <botlish_fn_14+0x279>
    1438:	mov    rcx,QWORD PTR [rsp+0x30]
    143d:	mov    rdx,r12
    1440:	mov    rdi,r15
    1443:	call   1448 <botlish_fn_14+0x284>
			1444: R_X86_64_PLT32	rt_mutarray_set-0x4
    1448:	test   rax,rax
    144b:	jne    136f <botlish_fn_14+0x1ab>
    1451:	jmp    13a9 <botlish_fn_14+0x1e5>
    1456:	mov    rcx,r14
    1459:	mov    rdx,r12
    145c:	mov    rdi,r15
    145f:	jmp    147b <botlish_fn_14+0x2b7>
    1464:	mov    rcx,r14
    1467:	mov    rdx,r12
    146a:	mov    rdi,r15
    146d:	jmp    147b <botlish_fn_14+0x2b7>
    1472:	mov    rcx,r14
    1475:	mov    rdx,r12
    1478:	mov    rdi,r15
    147b:	mov    rdi,r15
    147e:	call   1483 <botlish_fn_14+0x2bf>
			147f: R_X86_64_PLT32	rt_mutarray_set-0x4
    1483:	test   rax,rax
    1486:	jne    13ce <botlish_fn_14+0x20a>
    148c:	jmp    13a9 <botlish_fn_14+0x1e5>

0000000000001491 <botlish_entry_14: ht_rehash_insert<HashTable, int, any, any>>:
    1491:	push   rbp
    1492:	mov    rbp,rsp
    1495:	mov    rsi,QWORD PTR [rdx]
    1498:	mov    r9,QWORD PTR [rdx+0x8]
    149c:	mov    rcx,QWORD PTR [rdx+0x10]
    14a0:	mov    r8,QWORD PTR [rdx+0x18]
    14a4:	mov    rdx,r9
    14a7:	call   14ac <botlish_entry_14+0x1b>
			14a8: R_X86_64_PLT32	botlish_fn_14-0x4 ; ht_rehash_insert<HashTable, int, any, any>
    14ac:	mov    rsp,rbp
    14af:	pop    rbp
    14b0:	ret
    14b1:	add    BYTE PTR [rax],al
    14b3:	add    BYTE PTR [rax],al
    14b5:	add    BYTE PTR [rax],al
	...

00000000000014b8 <botlish_fn_15: ht_rehash_scan<mutarray, mutarray, mutarray, int, int, HashTable, int>>:
    14b8:	push   rbp
    14b9:	mov    rbp,rsp
    14bc:	sub    rsp,0x90
    14c3:	mov    QWORD PTR [rsp+0x60],rbx
    14c8:	mov    QWORD PTR [rsp+0x68],r12
    14cd:	mov    QWORD PTR [rsp+0x70],r13
    14d2:	mov    QWORD PTR [rsp+0x78],r14
    14d7:	mov    QWORD PTR [rsp+0x80],r15
    14df:	mov    QWORD PTR [rsp+0x38],rdi
    14e4:	mov    QWORD PTR [rsp+0x40],r9
    14e9:	mov    rax,QWORD PTR [rbp+0x10]
    14ed:	mov    r12,QWORD PTR [rbp+0x18]
    14f1:	mov    QWORD PTR [rsp],rsi
    14f5:	mov    QWORD PTR [rsp+0x8],rdx
    14fa:	mov    r15,rdx
    14fd:	mov    QWORD PTR [rsp+0x10],rcx
    1502:	mov    rbx,rcx
    1505:	mov    QWORD PTR [rsp+0x18],rax
    150a:	mov    QWORD PTR [rsp+0x48],rax
    150f:	mov    QWORD PTR [rsp+0x20],r12
    1514:	sar    r8,1
    1517:	mov    rdx,QWORD PTR [rsp+0x40]
    151c:	mov    r13,r8
    151f:	cmp    r13,rdx
    1522:	mov    QWORD PTR [rsp+0x40],rdx
    1527:	jge    16c3 <botlish_fn_15+0x20b>
    152d:	mov    r14,rsi
    1530:	mov    rdx,QWORD PTR [r14+0x8]
    1534:	mov    rax,r13
    1537:	shl    rax,1
    153a:	or     rax,0x1
    153e:	sar    rax,1
    1541:	cmp    rax,rdx
    1544:	jb     1557 <botlish_fn_15+0x9f>
    154a:	jmp    16f0 <botlish_fn_15+0x238>
    154f:	mov    rsi,rax
    1552:	jmp    155f <botlish_fn_15+0xa7>
    1557:	mov    r8,QWORD PTR [r14+0x10]
    155b:	mov    rsi,QWORD PTR [r8+rax*8]
    155f:	test   rsi,0x1
    1566:	jne    1589 <botlish_fn_15+0xd1>
    156c:	mov    edx,0x3
    1571:	mov    rdi,QWORD PTR [rsp+0x38]
    1576:	call   157b <botlish_fn_15+0xc3>
			1577: R_X86_64_PLT32	rt_value_eq-0x4
    157b:	test   rax,rax
    157e:	je     1667 <botlish_fn_15+0x1af>
    1584:	jmp    159a <botlish_fn_15+0xe2>
    1589:	mov    eax,0x2
    158e:	cmp    rsi,0x3
    1592:	cmove  rax,QWORD PTR [rip+0x1c6]        # 1760 <botlish_fn_15+0x2a8>
    159a:	cmp    rax,0x6
    159e:	je     15d5 <botlish_fn_15+0x11d>
    15a4:	mov    QWORD PTR [rsp],r14
    15a8:	mov    QWORD PTR [rsp+0x8],r15
    15ad:	mov    QWORD PTR [rsp+0x10],rbx
    15b2:	mov    rax,QWORD PTR [rsp+0x48]
    15b7:	mov    QWORD PTR [rsp+0x18],rax
    15bc:	mov    QWORD PTR [rsp+0x20],r12
    15c1:	add    r13,0x1
    15c8:	mov    rdx,QWORD PTR [rsp+0x40]
    15cd:	mov    rsi,r14
    15d0:	jmp    151f <botlish_fn_15+0x67>
    15d5:	mov    rdx,QWORD PTR [r15+0x8]
    15d9:	mov    rcx,r13
    15dc:	shl    rcx,1
    15df:	or     rcx,0x1
    15e3:	sar    rcx,1
    15e6:	cmp    rcx,rdx
    15e9:	jb     15fc <botlish_fn_15+0x144>
    15ef:	jmp    1715 <botlish_fn_15+0x25d>
    15f4:	mov    rcx,rax
    15f7:	jmp    1604 <botlish_fn_15+0x14c>
    15fc:	mov    rax,QWORD PTR [r15+0x10]
    1600:	mov    rcx,QWORD PTR [rax+rcx*8]
    1604:	mov    QWORD PTR [rsp+0x28],rcx
    1609:	mov    QWORD PTR [rsp+0x50],rcx
    160e:	mov    rax,QWORD PTR [rbx+0x8]
    1612:	mov    rcx,r13
    1615:	shl    rcx,1
    1618:	or     rcx,0x1
    161c:	sar    rcx,1
    161f:	cmp    rcx,rax
    1622:	jb     163a <botlish_fn_15+0x182>
    1628:	jmp    173a <botlish_fn_15+0x282>
    162d:	mov    rsi,QWORD PTR [rsp+0x48]
    1632:	mov    r8,rax
    1635:	jmp    1647 <botlish_fn_15+0x18f>
    163a:	mov    rax,QWORD PTR [rbx+0x10]
    163e:	mov    r8,QWORD PTR [rax+rcx*8]
    1642:	mov    rsi,QWORD PTR [rsp+0x48]
    1647:	mov    QWORD PTR [rsp+0x30],r8
    164c:	mov    rcx,QWORD PTR [rsp+0x50]
    1651:	mov    rdx,r12
    1654:	mov    rdi,QWORD PTR [rsp+0x38]
    1659:	call   165e <botlish_fn_15+0x1a6>
			165a: R_X86_64_PLT32	botlish_fn_14-0x4 ; ht_rehash_insert<HashTable, int, any, any>
    165e:	test   rax,rax
    1661:	jne    1692 <botlish_fn_15+0x1da>
    1667:	xor    rax,rax
    166a:	mov    rbx,QWORD PTR [rsp+0x60]
    166f:	mov    r12,QWORD PTR [rsp+0x68]
    1674:	mov    r13,QWORD PTR [rsp+0x70]
    1679:	mov    r14,QWORD PTR [rsp+0x78]
    167e:	mov    r15,QWORD PTR [rsp+0x80]
    1686:	add    rsp,0x90
    168d:	mov    rsp,rbp
    1690:	pop    rbp
    1691:	ret
    1692:	mov    QWORD PTR [rsp],r14
    1696:	mov    QWORD PTR [rsp+0x8],r15
    169b:	mov    QWORD PTR [rsp+0x10],rbx
    16a0:	mov    QWORD PTR [rsp+0x18],rax
    16a5:	mov    QWORD PTR [rsp+0x20],r12
    16aa:	add    r13,0x1
    16b1:	mov    rdx,QWORD PTR [rsp+0x40]
    16b6:	mov    rsi,r14
    16b9:	mov    QWORD PTR [rsp+0x48],rax
    16be:	jmp    151f <botlish_fn_15+0x67>
    16c3:	mov    rax,QWORD PTR [rsp+0x48]
    16c8:	mov    rbx,QWORD PTR [rsp+0x60]
    16cd:	mov    r12,QWORD PTR [rsp+0x68]
    16d2:	mov    r13,QWORD PTR [rsp+0x70]
    16d7:	mov    r14,QWORD PTR [rsp+0x78]
    16dc:	mov    r15,QWORD PTR [rsp+0x80]
    16e4:	add    rsp,0x90
    16eb:	mov    rsp,rbp
    16ee:	pop    rbp
    16ef:	ret
    16f0:	mov    rdx,r13
    16f3:	shl    rdx,1
    16f6:	or     rdx,0x1
    16fa:	mov    rsi,r14
    16fd:	mov    rdi,QWORD PTR [rsp+0x38]
    1702:	call   1707 <botlish_fn_15+0x24f>
			1703: R_X86_64_PLT32	rt_mutarray_get-0x4
    1707:	test   rax,rax
    170a:	jne    154f <botlish_fn_15+0x97>
    1710:	jmp    1667 <botlish_fn_15+0x1af>
    1715:	mov    rdx,r13
    1718:	shl    rdx,1
    171b:	or     rdx,0x1
    171f:	mov    rsi,r15
    1722:	mov    rdi,QWORD PTR [rsp+0x38]
    1727:	call   172c <botlish_fn_15+0x274>
			1728: R_X86_64_PLT32	rt_mutarray_get-0x4
    172c:	test   rax,rax
    172f:	jne    15f4 <botlish_fn_15+0x13c>
    1735:	jmp    1667 <botlish_fn_15+0x1af>
    173a:	mov    rdx,r13
    173d:	shl    rdx,1
    1740:	or     rdx,0x1
    1744:	mov    rsi,rbx
    1747:	mov    rdi,QWORD PTR [rsp+0x38]
    174c:	call   1751 <botlish_fn_15+0x299>
			174d: R_X86_64_PLT32	rt_mutarray_get-0x4
    1751:	test   rax,rax
    1754:	jne    162d <botlish_fn_15+0x175>
    175a:	jmp    1667 <botlish_fn_15+0x1af>
    175f:	add    BYTE PTR [rsi],al
    1761:	add    BYTE PTR [rax],al
    1763:	add    BYTE PTR [rax],al
    1765:	add    BYTE PTR [rax],al
	...

0000000000001768 <botlish_entry_15: ht_rehash_scan<mutarray, mutarray, mutarray, int, int, HashTable, int>>:
    1768:	push   rbp
    1769:	mov    rbp,rsp
    176c:	sub    rsp,0x10
    1770:	mov    rsi,QWORD PTR [rdx]
    1773:	mov    r11,QWORD PTR [rdx+0x8]
    1777:	mov    rcx,QWORD PTR [rdx+0x10]
    177b:	mov    r8,QWORD PTR [rdx+0x18]
    177f:	mov    r9,QWORD PTR [rdx+0x20]
    1783:	mov    rax,QWORD PTR [rdx+0x28]
    1787:	mov    rdx,QWORD PTR [rdx+0x30]
    178b:	sar    r9,1
    178e:	mov    QWORD PTR [rsp],rax
    1792:	mov    QWORD PTR [rsp+0x8],rdx
    1797:	mov    rdx,r11
    179a:	call   179f <botlish_entry_15+0x37>
			179b: R_X86_64_PLT32	botlish_fn_15-0x4 ; ht_rehash_scan<mutarray, mutarray, mutarray, int, int, HashTable, int>
    179f:	add    rsp,0x10
    17a3:	mov    rsp,rbp
    17a6:	pop    rbp
    17a7:	ret

00000000000017a8 <botlish_fn_16: ht_rehash<HashTable, int>>:
    17a8:	push   rbp
    17a9:	mov    rbp,rsp
    17ac:	sub    rsp,0x100
    17b3:	mov    QWORD PTR [rsp+0xd0],rbx
    17bb:	mov    QWORD PTR [rsp+0xd8],r12
    17c3:	mov    QWORD PTR [rsp+0xe0],r13
    17cb:	mov    QWORD PTR [rsp+0xe8],r14
    17d3:	mov    QWORD PTR [rsp+0xf0],r15
    17db:	mov    QWORD PTR [rsp+0x98],rdi
    17e3:	mov    QWORD PTR [rsp+0x20],0x0
    17ec:	mov    QWORD PTR [rsp+0x28],0x0
    17f5:	mov    QWORD PTR [rsp+0x30],0x0
    17fe:	mov    QWORD PTR [rsp+0x38],0x0
    1807:	mov    QWORD PTR [rsp+0x40],0x0
    1810:	mov    QWORD PTR [rsp+0x48],0x0
    1819:	mov    QWORD PTR [rsp+0x50],0x0
    1822:	mov    QWORD PTR [rsp+0x58],0x0
    182b:	mov    QWORD PTR [rsp+0x10],rsi
    1830:	mov    rbx,rsi
    1833:	mov    QWORD PTR [rsp+0x18],rdx
    1838:	mov    QWORD PTR [rsp+0xa0],rdx
    1840:	lea    rdx,[rsp+0x60]
    1845:	mov    rsi,QWORD PTR [rsp+0xa0]
    184d:	mov    rdi,QWORD PTR [rsp+0x98]
    1855:	call   185a <botlish_fn_16+0xb2>
			1856: R_X86_64_PLT32	botlish_fn_2-0x4 ; ht_alloc<int>
    185a:	test   rax,rax
    185d:	je     19ca <botlish_fn_16+0x222>
    1863:	mov    QWORD PTR [rsp+0x20],rax
    1868:	mov    QWORD PTR [rsp+0xc0],rax
    1870:	mov    rcx,QWORD PTR [rsp+0x60]
    1875:	mov    QWORD PTR [rsp+0x28],rcx
    187a:	mov    QWORD PTR [rsp+0xb8],rcx
    1882:	mov    rcx,QWORD PTR [rsp+0x68]
    1887:	mov    QWORD PTR [rsp+0x30],rcx
    188c:	mov    QWORD PTR [rsp+0xb0],rcx
    1894:	mov    r13,QWORD PTR [rsp+0x70]
    1899:	mov    QWORD PTR [rsp+0x38],r13
    189e:	mov    rsi,rbx
    18a1:	mov    rdi,QWORD PTR [rsp+0x98]
    18a9:	call   18ae <botlish_fn_16+0x106>
			18aa: R_X86_64_PLT32	botlish_fn_4-0x4 ; ht_size<HashTable>
    18ae:	test   rax,rax
    18b1:	mov    rcx,rax
    18b4:	je     19ca <botlish_fn_16+0x222>
    18ba:	mov    rax,QWORD PTR [r13+0x8]
    18be:	test   rax,rax
    18c1:	je     1a35 <botlish_fn_16+0x28d>
    18c7:	mov    rax,QWORD PTR [r13+0x18]
    18cb:	test   rax,rax
    18ce:	jne    18e1 <botlish_fn_16+0x139>
    18d4:	jmp    1a35 <botlish_fn_16+0x28d>
    18d9:	mov    rsi,rbx
    18dc:	jmp    18eb <botlish_fn_16+0x143>
    18e1:	mov    rax,QWORD PTR [r13+0x10]
    18e5:	mov    QWORD PTR [rax],rcx
    18e8:	mov    rsi,rbx
    18eb:	mov    rdx,QWORD PTR [rsi+0x18]
    18ef:	mov    r14,QWORD PTR [rdx]
    18f2:	mov    QWORD PTR [rsp+0x40],r14
    18f7:	mov    rdi,QWORD PTR [rsi+0x18]
    18fb:	mov    r15,QWORD PTR [rdi+0x8]
    18ff:	mov    QWORD PTR [rsp+0x48],r15
    1904:	mov    rdi,QWORD PTR [rsi+0x18]
    1908:	mov    rbx,QWORD PTR [rdi+0x10]
    190c:	mov    QWORD PTR [rsp+0x50],rbx
    1911:	mov    r12d,0x1
    1917:	mov    QWORD PTR [rsp+0x58],0x1
    1920:	mov    rdi,QWORD PTR [rsp+0x98]
    1928:	call   192d <botlish_fn_16+0x185>
			1929: R_X86_64_PLT32	botlish_fn_6-0x4 ; ht_capacity<HashTable>
    192d:	mov    QWORD PTR [rsp+0xa8],rax
    1935:	lea    rcx,[rsp+0x78]
    193a:	mov    rax,QWORD PTR [rsp+0xc0]
    1942:	mov    QWORD PTR [rsp+0x78],rax
    1947:	mov    rax,QWORD PTR [rsp+0xb8]
    194f:	mov    QWORD PTR [rsp+0x80],rax
    1957:	mov    rax,QWORD PTR [rsp+0xb0]
    195f:	mov    QWORD PTR [rsp+0x88],rax
    1967:	mov    QWORD PTR [rsp+0x90],r13
    196f:	xor    rsi,rsi
    1972:	mov    edx,0x4
    1977:	mov    rdi,QWORD PTR [rsp+0x98]
    197f:	call   1984 <botlish_fn_16+0x1dc>
			1980: R_X86_64_PLT32	rt_struct_new-0x4
    1984:	mov    QWORD PTR [rsp+0x10],rax
    1989:	mov    rcx,QWORD PTR [rsp+0xa8]
    1991:	mov    r9,rcx
    1994:	sar    r9,1
    1997:	mov    QWORD PTR [rsp],rax
    199b:	mov    rdx,QWORD PTR [rsp+0xa0]
    19a3:	mov    QWORD PTR [rsp+0x8],rdx
    19a8:	mov    rcx,rbx
    19ab:	mov    rdx,r15
    19ae:	mov    rsi,r14
    19b1:	mov    rdi,QWORD PTR [rsp+0x98]
    19b9:	mov    r8,r12
    19bc:	call   19c1 <botlish_fn_16+0x219>
			19bd: R_X86_64_PLT32	botlish_fn_15-0x4 ; ht_rehash_scan<mutarray, mutarray, mutarray, int, int, HashTable, int>
    19c1:	test   rax,rax
    19c4:	jne    1a01 <botlish_fn_16+0x259>
    19ca:	xor    rax,rax
    19cd:	mov    rbx,QWORD PTR [rsp+0xd0]
    19d5:	mov    r12,QWORD PTR [rsp+0xd8]
    19dd:	mov    r13,QWORD PTR [rsp+0xe0]
    19e5:	mov    r14,QWORD PTR [rsp+0xe8]
    19ed:	mov    r15,QWORD PTR [rsp+0xf0]
    19f5:	add    rsp,0x100
    19fc:	mov    rsp,rbp
    19ff:	pop    rbp
    1a00:	ret
    1a01:	mov    rbx,QWORD PTR [rsp+0xd0]
    1a09:	mov    r12,QWORD PTR [rsp+0xd8]
    1a11:	mov    r13,QWORD PTR [rsp+0xe0]
    1a19:	mov    r14,QWORD PTR [rsp+0xe8]
    1a21:	mov    r15,QWORD PTR [rsp+0xf0]
    1a29:	add    rsp,0x100
    1a30:	mov    rsp,rbp
    1a33:	pop    rbp
    1a34:	ret
    1a35:	mov    edx,0x1
    1a3a:	mov    rsi,r13
    1a3d:	mov    rdi,QWORD PTR [rsp+0x98]
    1a45:	call   1a4a <botlish_fn_16+0x2a2>
			1a46: R_X86_64_PLT32	rt_mutarray_set-0x4
    1a4a:	test   rax,rax
    1a4d:	jne    18d9 <botlish_fn_16+0x131>
    1a53:	jmp    19ca <botlish_fn_16+0x222>

0000000000001a58 <botlish_entry_16: ht_rehash<HashTable, int>>:
    1a58:	push   rbp
    1a59:	mov    rbp,rsp
    1a5c:	mov    rsi,QWORD PTR [rdx]
    1a5f:	mov    rdx,QWORD PTR [rdx+0x8]
    1a63:	call   1a68 <botlish_entry_16+0x10>
			1a64: R_X86_64_PLT32	botlish_fn_16-0x4 ; ht_rehash<HashTable, int>
    1a68:	mov    rsp,rbp
    1a6b:	pop    rbp
    1a6c:	ret
    1a6d:	add    BYTE PTR [rax],al
	...

0000000000001a70 <botlish_fn_17: ht_should_grow<HashTable>>:
    1a70:	push   rbp
    1a71:	mov    rbp,rsp
    1a74:	sub    rsp,0x40
    1a78:	mov    QWORD PTR [rsp+0x20],rbx
    1a7d:	mov    QWORD PTR [rsp+0x28],r12
    1a82:	mov    QWORD PTR [rsp+0x30],r13
    1a87:	mov    rbx,rdi
    1a8a:	mov    QWORD PTR [rsp],rsi
    1a8e:	mov    r12,rsi
    1a91:	mov    rsi,r12
    1a94:	mov    rdi,rbx
    1a97:	call   1a9c <botlish_fn_17+0x2c>
			1a98: R_X86_64_PLT32	botlish_fn_4-0x4 ; ht_size<HashTable>
    1a9c:	mov    rcx,rax
    1a9f:	mov    r13,rax
    1aa2:	test   rax,rcx
    1aa5:	je     1b7c <botlish_fn_17+0x10c>
    1aab:	mov    rax,r13
    1aae:	mov    QWORD PTR [rsp+0x8],rax
    1ab3:	mov    rsi,r12
    1ab6:	mov    rdi,rbx
    1ab9:	call   1abe <botlish_fn_17+0x4e>
			1aba: R_X86_64_PLT32	botlish_fn_5-0x4 ; ht_tombstones<HashTable>
    1abe:	mov    rcx,rax
    1ac1:	test   rcx,rcx
    1ac4:	je     1b7c <botlish_fn_17+0x10c>
    1aca:	mov    QWORD PTR [rsp+0x10],rcx
    1acf:	mov    edx,0x1
    1ad4:	mov    rax,r13
    1ad7:	test   rax,0x1
    1add:	jne    1b00 <botlish_fn_17+0x90>
    1ae3:	xor    edx,edx
    1ae5:	mov    rax,r13
    1ae8:	test   rax,0x7
    1aee:	jne    1b00 <botlish_fn_17+0x90>
    1af4:	mov    rax,r13
    1af7:	movzx  rax,BYTE PTR [rax]
    1afb:	cmp    al,0x1
    1afd:	sete   dl
    1b00:	test   dl,dl
    1b02:	jne    1b22 <botlish_fn_17+0xb2>
    1b08:	mov    rdi,rbx
    1b0b:	mov    rax,QWORD PTR [rdi+0x10]
    1b0f:	mov    rcx,QWORD PTR [rax]
    1b12:	xor    rdx,rdx
    1b15:	mov    rsi,r13
    1b18:	call   1b1d <botlish_fn_17+0xad>
			1b19: R_X86_64_PLT32	rt_type_error-0x4
    1b1d:	jmp    1b7c <botlish_fn_17+0x10c>
    1b22:	mov    eax,0x1
    1b27:	test   rcx,0x1
    1b2e:	je     1b3c <botlish_fn_17+0xcc>
    1b34:	mov    r8,rcx
    1b37:	jmp    1b5f <botlish_fn_17+0xef>
    1b3c:	xor    eax,eax
    1b3e:	test   rcx,0x7
    1b45:	je     1b53 <botlish_fn_17+0xe3>
    1b4b:	mov    r8,rcx
    1b4e:	jmp    1b5f <botlish_fn_17+0xef>
    1b53:	movzx  rax,BYTE PTR [rcx]
    1b57:	mov    r8,rcx
    1b5a:	cmp    al,0x1
    1b5c:	sete   al
    1b5f:	test   al,al
    1b61:	jne    1b97 <botlish_fn_17+0x127>
    1b67:	mov    rdi,rbx
    1b6a:	mov    rax,QWORD PTR [rdi+0x10]
    1b6e:	mov    rcx,QWORD PTR [rax]
    1b71:	xor    rdx,rdx
    1b74:	mov    rsi,r8
    1b77:	call   1b7c <botlish_fn_17+0x10c>
			1b78: R_X86_64_PLT32	rt_type_error-0x4
    1b7c:	xor    rax,rax
    1b7f:	mov    rbx,QWORD PTR [rsp+0x20]
    1b84:	mov    r12,QWORD PTR [rsp+0x28]
    1b89:	mov    r13,QWORD PTR [rsp+0x30]
    1b8e:	add    rsp,0x40
    1b92:	mov    rsp,rbp
    1b95:	pop    rbp
    1b96:	ret
    1b97:	mov    rcx,r8
    1b9a:	mov    rsi,r13
    1b9d:	mov    rax,rsi
    1ba0:	and    rax,rcx
    1ba3:	test   rax,0x1
    1ba9:	jne    1bba <botlish_fn_17+0x14a>
    1baf:	mov    rdx,r8
    1bb2:	mov    rsi,r13
    1bb5:	jmp    1bd8 <botlish_fn_17+0x168>
    1bba:	mov    rcx,r8
    1bbd:	lea    rax,[rcx-0x1]
    1bc1:	mov    rsi,r13
    1bc4:	add    rsi,rax
    1bc7:	seto   al
    1bca:	test   al,al
    1bcc:	je     1be3 <botlish_fn_17+0x173>
    1bd2:	mov    rdx,r8
    1bd5:	mov    rsi,r13
    1bd8:	mov    rdi,rbx
    1bdb:	call   1be0 <botlish_fn_17+0x170>
			1bdc: R_X86_64_PLT32	rt_int_add-0x4
    1be0:	mov    rsi,rax
    1be3:	mov    QWORD PTR [rsp+0x8],rsi
    1be8:	mov    QWORD PTR [rsp+0x10],0x3
    1bf1:	test   rsi,0x1
    1bf8:	je     1c1b <botlish_fn_17+0x1ab>
    1bfe:	mov    rax,rsi
    1c01:	add    rax,0x2
    1c05:	mov    rcx,rax
    1c08:	seto   al
    1c0b:	test   al,al
    1c0d:	jne    1c1b <botlish_fn_17+0x1ab>
    1c13:	mov    rsi,rcx
    1c16:	jmp    1c2b <botlish_fn_17+0x1bb>
    1c1b:	mov    edx,0x3
    1c20:	mov    rdi,rbx
    1c23:	call   1c28 <botlish_fn_17+0x1b8>
			1c24: R_X86_64_PLT32	rt_int_add-0x4
    1c28:	mov    rsi,rax
    1c2b:	mov    QWORD PTR [rsp+0x8],rsi
    1c30:	mov    edx,0x7
    1c35:	mov    rdi,rdx
    1c38:	mov    QWORD PTR [rsp+0x10],0x7
    1c41:	test   rsi,0x1
    1c48:	jne    1c56 <botlish_fn_17+0x1e6>
    1c4e:	mov    rdx,rdi
    1c51:	jmp    1c82 <botlish_fn_17+0x212>
    1c56:	mov    rax,rsi
    1c59:	sar    rax,1
    1c5c:	imul   QWORD PTR [rip+0xf5]        # 1d58 <botlish_fn_17+0x2e8>
    1c63:	seto   cl
    1c66:	or     rax,0x1
    1c6a:	test   cl,cl
    1c6c:	je     1c7a <botlish_fn_17+0x20a>
    1c72:	mov    rdx,rdi
    1c75:	jmp    1c82 <botlish_fn_17+0x212>
    1c7a:	mov    rsi,rax
    1c7d:	jmp    1c8d <botlish_fn_17+0x21d>
    1c82:	mov    rdi,rbx
    1c85:	call   1c8a <botlish_fn_17+0x21a>
			1c86: R_X86_64_PLT32	rt_int_mul-0x4
    1c8a:	mov    rsi,rax
    1c8d:	mov    QWORD PTR [rsp+0x8],rsi
    1c92:	mov    r13,rsi
    1c95:	mov    rsi,r12
    1c98:	mov    rdi,rbx
    1c9b:	call   1ca0 <botlish_fn_17+0x230>
			1c9c: R_X86_64_PLT32	botlish_fn_6-0x4 ; ht_capacity<HashTable>
    1ca0:	mov    QWORD PTR [rsp],rax
    1ca4:	mov    QWORD PTR [rsp+0x10],0x5
    1cad:	test   rax,0x1
    1cb3:	mov    rcx,rax
    1cb6:	je     1ce5 <botlish_fn_17+0x275>
    1cbc:	mov    rax,rcx
    1cbf:	sar    rax,1
    1cc2:	imul   QWORD PTR [rip+0x97]        # 1d60 <botlish_fn_17+0x2f0>
    1cc9:	seto   sil
    1ccd:	or     rax,0x1
    1cd1:	test   sil,sil
    1cd4:	jne    1ce5 <botlish_fn_17+0x275>
    1cda:	mov    rdx,rax
    1cdd:	mov    rsi,r13
    1ce0:	jmp    1cfb <botlish_fn_17+0x28b>
    1ce5:	mov    edx,0x5
    1cea:	mov    rsi,rcx
    1ced:	mov    rdi,rbx
    1cf0:	call   1cf5 <botlish_fn_17+0x285>
			1cf1: R_X86_64_PLT32	rt_int_mul-0x4
    1cf5:	mov    rdx,rax
    1cf8:	mov    rsi,r13
    1cfb:	mov    rdi,rsi
    1cfe:	and    rdi,rdx
    1d01:	test   rdi,0x1
    1d08:	jne    1d2e <botlish_fn_17+0x2be>
    1d0e:	mov    rdi,rbx
    1d11:	call   1d16 <botlish_fn_17+0x2a6>
			1d12: R_X86_64_PLT32	rt_int_cmp-0x4
    1d16:	mov    esi,0x2
    1d1b:	test   rax,rax
    1d1e:	mov    rax,rsi
    1d21:	cmovg  rax,QWORD PTR [rip+0x2f]        # 1d58 <botlish_fn_17+0x2e8>
    1d29:	jmp    1d3e <botlish_fn_17+0x2ce>
    1d2e:	mov    eax,0x2
    1d33:	cmp    rsi,rdx
    1d36:	cmovg  rax,QWORD PTR [rip+0x1a]        # 1d58 <botlish_fn_17+0x2e8>
    1d3e:	mov    rbx,QWORD PTR [rsp+0x20]
    1d43:	mov    r12,QWORD PTR [rsp+0x28]
    1d48:	mov    r13,QWORD PTR [rsp+0x30]
    1d4d:	add    rsp,0x40
    1d51:	mov    rsp,rbp
    1d54:	pop    rbp
    1d55:	ret
    1d56:	add    BYTE PTR [rax],al
    1d58:	(bad)
    1d59:	add    BYTE PTR [rax],al
    1d5b:	add    BYTE PTR [rax],al
    1d5d:	add    BYTE PTR [rax],al
    1d5f:	add    BYTE PTR [rax+rax*1],al
    1d62:	add    BYTE PTR [rax],al
    1d64:	add    BYTE PTR [rax],al
	...

0000000000001d68 <botlish_entry_17: ht_should_grow<HashTable>>:
    1d68:	push   rbp
    1d69:	mov    rbp,rsp
    1d6c:	mov    rsi,QWORD PTR [rdx]
    1d6f:	call   1d74 <botlish_entry_17+0xc>
			1d70: R_X86_64_PLT32	botlish_fn_17-0x4 ; ht_should_grow<HashTable>
    1d74:	mov    rsp,rbp
    1d77:	pop    rbp
    1d78:	ret
    1d79:	add    BYTE PTR [rax],al
    1d7b:	add    BYTE PTR [rax],al
    1d7d:	add    BYTE PTR [rax],al
	...

0000000000001d80 <botlish_fn_18: ht_grow_or_clean<HashTable>>:
    1d80:	push   rbp
    1d81:	mov    rbp,rsp
    1d84:	sub    rsp,0x40
    1d88:	mov    QWORD PTR [rsp+0x20],rbx
    1d8d:	mov    QWORD PTR [rsp+0x28],r12
    1d92:	mov    QWORD PTR [rsp+0x30],r13
    1d97:	mov    rbx,rdi
    1d9a:	mov    QWORD PTR [rsp+0x10],0x0
    1da3:	mov    QWORD PTR [rsp],rsi
    1da7:	mov    r12,rsi
    1daa:	mov    rsi,r12
    1dad:	mov    rdi,rbx
    1db0:	call   1db5 <botlish_fn_18+0x35>
			1db1: R_X86_64_PLT32	botlish_fn_5-0x4 ; ht_tombstones<HashTable>
    1db5:	test   rax,rax
    1db8:	mov    r13,rax
    1dbb:	je     1fa9 <botlish_fn_18+0x229>
    1dc1:	mov    rsi,r12
    1dc4:	mov    rdi,rbx
    1dc7:	call   1dcc <botlish_fn_18+0x4c>
			1dc8: R_X86_64_PLT32	botlish_fn_4-0x4 ; ht_size<HashTable>
    1dcc:	mov    r11,rax
    1dcf:	test   r11,r11
    1dd2:	je     1fa9 <botlish_fn_18+0x229>
    1dd8:	mov    ecx,0x1
    1ddd:	mov    rax,r13
    1de0:	test   rax,0x1
    1de6:	je     1df4 <botlish_fn_18+0x74>
    1dec:	mov    r13,rax
    1def:	jmp    1e18 <botlish_fn_18+0x98>
    1df4:	xor    ecx,ecx
    1df6:	test   rax,0x7
    1dfc:	je     1e0a <botlish_fn_18+0x8a>
    1e02:	mov    r13,rax
    1e05:	jmp    1e18 <botlish_fn_18+0x98>
    1e0a:	movzx  rcx,BYTE PTR [rax]
    1e0e:	mov    r13,rax
    1e11:	rex cmp cl,0x1
    1e15:	sete   cl
    1e18:	test   cl,cl
    1e1a:	jne    1e3b <botlish_fn_18+0xbb>
    1e20:	mov    rdi,rbx
    1e23:	mov    rsi,QWORD PTR [rdi+0x10]
    1e27:	mov    rcx,QWORD PTR [rsi+0x8]
    1e2b:	xor    rdx,rdx
    1e2e:	mov    rsi,r13
    1e31:	call   1e36 <botlish_fn_18+0xb6>
			1e32: R_X86_64_PLT32	rt_type_error-0x4
    1e36:	jmp    1fa9 <botlish_fn_18+0x229>
    1e3b:	mov    rsi,r13
    1e3e:	mov    eax,0x1
    1e43:	test   r11,0x1
    1e4a:	je     1e58 <botlish_fn_18+0xd8>
    1e50:	mov    r8,r11
    1e53:	jmp    1e7d <botlish_fn_18+0xfd>
    1e58:	xor    eax,eax
    1e5a:	test   r11,0x7
    1e61:	je     1e6f <botlish_fn_18+0xef>
    1e67:	mov    r8,r11
    1e6a:	jmp    1e7d <botlish_fn_18+0xfd>
    1e6f:	movzx  r10,BYTE PTR [r11]
    1e73:	mov    r8,r11
    1e76:	cmp    r10b,0x1
    1e7a:	sete   al
    1e7d:	test   al,al
    1e7f:	jne    1ea0 <botlish_fn_18+0x120>
    1e85:	mov    rdi,rbx
    1e88:	mov    rax,QWORD PTR [rdi+0x10]
    1e8c:	mov    rcx,QWORD PTR [rax+0x8]
    1e90:	xor    rdx,rdx
    1e93:	mov    rsi,r8
    1e96:	call   1e9b <botlish_fn_18+0x11b>
			1e97: R_X86_64_PLT32	rt_type_error-0x4
    1e9b:	jmp    1fa9 <botlish_fn_18+0x229>
    1ea0:	mov    r11,r8
    1ea3:	mov    rax,rsi
    1ea6:	and    rax,r11
    1ea9:	test   rax,0x1
    1eaf:	jne    1ed5 <botlish_fn_18+0x155>
    1eb5:	mov    rdx,r8
    1eb8:	mov    rdi,rbx
    1ebb:	call   1ec0 <botlish_fn_18+0x140>
			1ebc: R_X86_64_PLT32	rt_int_cmp-0x4
    1ec0:	mov    ecx,0x2
    1ec5:	test   rax,rax
    1ec8:	cmovg  rcx,QWORD PTR [rip+0x110]        # 1fe0 <botlish_fn_18+0x260>
    1ed0:	jmp    1ee8 <botlish_fn_18+0x168>
    1ed5:	mov    ecx,0x2
    1eda:	mov    r11,r8
    1edd:	cmp    rsi,r11
    1ee0:	cmovg  rcx,QWORD PTR [rip+0xf8]        # 1fe0 <botlish_fn_18+0x260>
    1ee8:	cmp    rcx,0x6
    1eec:	je     1f82 <botlish_fn_18+0x202>
    1ef2:	mov    rsi,r12
    1ef5:	mov    rdi,rbx
    1ef8:	call   1efd <botlish_fn_18+0x17d>
			1ef9: R_X86_64_PLT32	botlish_fn_6-0x4 ; ht_capacity<HashTable>
    1efd:	mov    QWORD PTR [rsp+0x8],rax
    1f02:	mov    QWORD PTR [rsp+0x10],0x5
    1f0b:	test   rax,0x1
    1f11:	mov    rsi,rax
    1f14:	je     1f41 <botlish_fn_18+0x1c1>
    1f1a:	mov    rcx,rsi
    1f1d:	mov    rax,rcx
    1f20:	sar    rax,1
    1f23:	imul   QWORD PTR [rip+0xbe]        # 1fe8 <botlish_fn_18+0x268>
    1f2a:	seto   cl
    1f2d:	or     rax,0x1
    1f31:	test   cl,cl
    1f33:	jne    1f41 <botlish_fn_18+0x1c1>
    1f39:	mov    rdx,rax
    1f3c:	jmp    1f51 <botlish_fn_18+0x1d1>
    1f41:	mov    edx,0x5
    1f46:	mov    rdi,rbx
    1f49:	call   1f4e <botlish_fn_18+0x1ce>
			1f4a: R_X86_64_PLT32	rt_int_mul-0x4
    1f4e:	mov    rdx,rax
    1f51:	mov    QWORD PTR [rsp+0x8],rdx
    1f56:	mov    rsi,r12
    1f59:	mov    rdi,rbx
    1f5c:	call   1f61 <botlish_fn_18+0x1e1>
			1f5d: R_X86_64_PLT32	botlish_fn_16-0x4 ; ht_rehash<HashTable, int>
    1f61:	test   rax,rax
    1f64:	je     1fa9 <botlish_fn_18+0x229>
    1f6a:	mov    rbx,QWORD PTR [rsp+0x20]
    1f6f:	mov    r12,QWORD PTR [rsp+0x28]
    1f74:	mov    r13,QWORD PTR [rsp+0x30]
    1f79:	add    rsp,0x40
    1f7d:	mov    rsp,rbp
    1f80:	pop    rbp
    1f81:	ret
    1f82:	mov    rsi,r12
    1f85:	mov    rdi,rbx
    1f88:	call   1f8d <botlish_fn_18+0x20d>
			1f89: R_X86_64_PLT32	botlish_fn_6-0x4 ; ht_capacity<HashTable>
    1f8d:	mov    QWORD PTR [rsp+0x8],rax
    1f92:	mov    rdx,rax
    1f95:	mov    rsi,r12
    1f98:	mov    rdi,rbx
    1f9b:	call   1fa0 <botlish_fn_18+0x220>
			1f9c: R_X86_64_PLT32	botlish_fn_16-0x4 ; ht_rehash<HashTable, int>
    1fa0:	test   rax,rax
    1fa3:	jne    1fc4 <botlish_fn_18+0x244>
    1fa9:	xor    rax,rax
    1fac:	mov    rbx,QWORD PTR [rsp+0x20]
    1fb1:	mov    r12,QWORD PTR [rsp+0x28]
    1fb6:	mov    r13,QWORD PTR [rsp+0x30]
    1fbb:	add    rsp,0x40
    1fbf:	mov    rsp,rbp
    1fc2:	pop    rbp
    1fc3:	ret
    1fc4:	mov    rbx,QWORD PTR [rsp+0x20]
    1fc9:	mov    r12,QWORD PTR [rsp+0x28]
    1fce:	mov    r13,QWORD PTR [rsp+0x30]
    1fd3:	add    rsp,0x40
    1fd7:	mov    rsp,rbp
    1fda:	pop    rbp
    1fdb:	ret
    1fdc:	add    BYTE PTR [rax],al
    1fde:	add    BYTE PTR [rax],al
    1fe0:	(bad)
    1fe1:	add    BYTE PTR [rax],al
    1fe3:	add    BYTE PTR [rax],al
    1fe5:	add    BYTE PTR [rax],al
    1fe7:	add    BYTE PTR [rax+rax*1],al
    1fea:	add    BYTE PTR [rax],al
    1fec:	add    BYTE PTR [rax],al
	...

0000000000001ff0 <botlish_entry_18: ht_grow_or_clean<HashTable>>:
    1ff0:	push   rbp
    1ff1:	mov    rbp,rsp
    1ff4:	mov    rsi,QWORD PTR [rdx]
    1ff7:	call   1ffc <botlish_entry_18+0xc>
			1ff8: R_X86_64_PLT32	botlish_fn_18-0x4 ; ht_grow_or_clean<HashTable>
    1ffc:	mov    rsp,rbp
    1fff:	pop    rbp
    2000:	ret
    2001:	add    BYTE PTR [rax],al
    2003:	add    BYTE PTR [rax],al
    2005:	add    BYTE PTR [rax],al
	...

0000000000002008 <botlish_fn_19: ht_place<HashTable, int, str, str>>:
    2008:	push   rbp
    2009:	mov    rbp,rsp
    200c:	sub    rsp,0x70
    2010:	mov    QWORD PTR [rsp+0x40],rbx
    2015:	mov    QWORD PTR [rsp+0x48],r12
    201a:	mov    QWORD PTR [rsp+0x50],r13
    201f:	mov    QWORD PTR [rsp+0x58],r14
    2024:	mov    QWORD PTR [rsp+0x60],r15
    2029:	mov    r12,rdi
    202c:	mov    r14,r8
    202f:	mov    QWORD PTR [rsp+0x30],rcx
    2034:	mov    QWORD PTR [rsp],rsi
    2038:	mov    rax,QWORD PTR [rsi+0x18]
    203c:	mov    rbx,rsi
    203f:	mov    rsi,QWORD PTR [rax]
    2042:	test   rdx,0x1
    2049:	je     23ee <botlish_fn_19+0x3e6>
    204f:	mov    rcx,QWORD PTR [rsi+0x8]
    2053:	mov    rax,rdx
    2056:	sar    rax,1
    2059:	mov    r15,rdx
    205c:	cmp    rax,rcx
    205f:	jb     2072 <botlish_fn_19+0x6a>
    2065:	jmp    23f1 <botlish_fn_19+0x3e9>
    206a:	mov    rsi,rax
    206d:	jmp    207a <botlish_fn_19+0x72>
    2072:	mov    rcx,QWORD PTR [rsi+0x10]
    2076:	mov    rsi,QWORD PTR [rcx+rax*8]
    207a:	mov    QWORD PTR [rsp+0x8],rsi
    207f:	mov    r13,rsi
    2082:	mov    rax,QWORD PTR [rbx+0x18]
    2086:	mov    rsi,QWORD PTR [rax]
    2089:	mov    rdx,r15
    208c:	test   rdx,0x1
    2093:	je     240a <botlish_fn_19+0x402>
    2099:	mov    rcx,QWORD PTR [rsi+0x8]
    209d:	mov    rdx,r15
    20a0:	mov    rax,rdx
    20a3:	sar    rax,1
    20a6:	cmp    rax,rcx
    20a9:	jae    240a <botlish_fn_19+0x402>
    20af:	mov    rcx,QWORD PTR [rsi+0x18]
    20b3:	test   rcx,rcx
    20b6:	je     240a <botlish_fn_19+0x402>
    20bc:	mov    rcx,QWORD PTR [rsi+0x10]
    20c0:	mov    QWORD PTR [rcx+rax*8],0x3
    20c8:	mov    rax,QWORD PTR [rbx+0x18]
    20cc:	mov    rsi,QWORD PTR [rax+0x8]
    20d0:	mov    rdx,r15
    20d3:	test   rdx,0x1
    20da:	je     2428 <botlish_fn_19+0x420>
    20e0:	mov    rcx,QWORD PTR [rsi+0x8]
    20e4:	mov    rdx,r15
    20e7:	mov    rax,rdx
    20ea:	sar    rax,1
    20ed:	cmp    rax,rcx
    20f0:	jae    2432 <botlish_fn_19+0x42a>
    20f6:	mov    rcx,QWORD PTR [rsi+0x18]
    20fa:	test   rcx,rcx
    20fd:	je     243c <botlish_fn_19+0x434>
    2103:	mov    rcx,QWORD PTR [rsp+0x30]
    2108:	mov    r8,QWORD PTR [rsi+0x10]
    210c:	mov    QWORD PTR [r8+rax*8],rcx
    2110:	mov    r10,QWORD PTR [rbx+0x18]
    2114:	mov    rsi,QWORD PTR [r10+0x10]
    2118:	mov    rdx,r15
    211b:	test   rdx,0x1
    2122:	je     245a <botlish_fn_19+0x452>
    2128:	mov    rcx,QWORD PTR [rsi+0x8]
    212c:	mov    rdx,r15
    212f:	mov    rax,rdx
    2132:	sar    rax,1
    2135:	cmp    rax,rcx
    2138:	jae    2465 <botlish_fn_19+0x45d>
    213e:	mov    rcx,QWORD PTR [rsi+0x18]
    2142:	test   rcx,rcx
    2145:	je     2470 <botlish_fn_19+0x468>
    214b:	mov    rcx,r14
    214e:	mov    rdx,QWORD PTR [rsi+0x10]
    2152:	mov    QWORD PTR [rdx+rax*8],rcx
    2156:	mov    rax,QWORD PTR [rbx+0x18]
    215a:	mov    rsi,QWORD PTR [rax+0x18]
    215e:	mov    QWORD PTR [rsp+0x10],rsi
    2163:	mov    r15,rsi
    2166:	mov    QWORD PTR [rsp+0x18],0x1
    216f:	mov    rsi,rbx
    2172:	mov    rdi,r12
    2175:	call   217a <botlish_fn_19+0x172>
			2176: R_X86_64_PLT32	botlish_fn_4-0x4 ; ht_size<HashTable>
    217a:	test   rax,rax
    217d:	je     2397 <botlish_fn_19+0x38f>
    2183:	mov    QWORD PTR [rsp+0x20],rax
    2188:	mov    edx,0x3
    218d:	mov    r14,rdx
    2190:	mov    QWORD PTR [rsp+0x28],0x3
    2199:	mov    ecx,0x1
    219e:	test   rax,0x1
    21a4:	je     21b2 <botlish_fn_19+0x1aa>
    21aa:	mov    rsi,rax
    21ad:	jmp    21d6 <botlish_fn_19+0x1ce>
    21b2:	xor    ecx,ecx
    21b4:	test   rax,0x7
    21ba:	je     21c8 <botlish_fn_19+0x1c0>
    21c0:	mov    rsi,rax
    21c3:	jmp    21d6 <botlish_fn_19+0x1ce>
    21c8:	movzx  rcx,BYTE PTR [rax]
    21cc:	mov    rsi,rax
    21cf:	rex cmp cl,0x1
    21d3:	sete   cl
    21d6:	test   cl,cl
    21d8:	jne    21f5 <botlish_fn_19+0x1ed>
    21de:	mov    rdi,r12
    21e1:	mov    rax,QWORD PTR [rdi+0x10]
    21e5:	mov    rcx,QWORD PTR [rax]
    21e8:	xor    rdx,rdx
    21eb:	call   21f0 <botlish_fn_19+0x1e8>
			21ec: R_X86_64_PLT32	rt_type_error-0x4
    21f0:	jmp    2397 <botlish_fn_19+0x38f>
    21f5:	test   rsi,0x1
    21fc:	je     2214 <botlish_fn_19+0x20c>
    2202:	mov    rcx,rsi
    2205:	add    rcx,0x2
    2209:	seto   al
    220c:	test   al,al
    220e:	je     2222 <botlish_fn_19+0x21a>
    2214:	mov    rdx,r14
    2217:	mov    rdi,r12
    221a:	call   221f <botlish_fn_19+0x217>
			221b: R_X86_64_PLT32	rt_int_add-0x4
    221f:	mov    rcx,rax
    2222:	mov    rsi,r15
    2225:	mov    rax,QWORD PTR [rsi+0x8]
    2229:	test   rax,rax
    222c:	je     248f <botlish_fn_19+0x487>
    2232:	mov    rax,QWORD PTR [rsi+0x18]
    2236:	test   rax,rax
    2239:	jne    224c <botlish_fn_19+0x244>
    223f:	jmp    248f <botlish_fn_19+0x487>
    2244:	mov    rsi,r13
    2247:	jmp    2256 <botlish_fn_19+0x24e>
    224c:	mov    rax,QWORD PTR [rsi+0x10]
    2250:	mov    QWORD PTR [rax],rcx
    2253:	mov    rsi,r13
    2256:	test   rsi,0x1
    225d:	jne    2285 <botlish_fn_19+0x27d>
    2263:	mov    edx,0x5
    2268:	mov    rdi,r12
    226b:	call   2270 <botlish_fn_19+0x268>
			226c: R_X86_64_PLT32	rt_int_cmp-0x4
    2270:	mov    ecx,0x2
    2275:	test   rax,rax
    2278:	cmove  rcx,QWORD PTR [rip+0x258]        # 24d8 <botlish_fn_19+0x4d0>
    2280:	jmp    2296 <botlish_fn_19+0x28e>
    2285:	mov    ecx,0x2
    228a:	cmp    rsi,0x5
    228e:	cmove  rcx,QWORD PTR [rip+0x242]        # 24d8 <botlish_fn_19+0x4d0>
    2296:	cmp    rcx,0x6
    229a:	je     22a8 <botlish_fn_19+0x2a0>
    22a0:	mov    rax,rbx
    22a3:	jmp    23cc <botlish_fn_19+0x3c4>
    22a8:	mov    r10,QWORD PTR [rbx+0x18]
    22ac:	mov    rsi,QWORD PTR [r10+0x18]
    22b0:	mov    QWORD PTR [rsp+0x8],rsi
    22b5:	mov    r13,rsi
    22b8:	mov    QWORD PTR [rsp+0x10],0x3
    22c1:	mov    rsi,rbx
    22c4:	mov    rdi,r12
    22c7:	call   22cc <botlish_fn_19+0x2c4>
			22c8: R_X86_64_PLT32	botlish_fn_5-0x4 ; ht_tombstones<HashTable>
    22cc:	test   rax,rax
    22cf:	je     2397 <botlish_fn_19+0x38f>
    22d5:	mov    QWORD PTR [rsp+0x18],rax
    22da:	mov    QWORD PTR [rsp+0x20],0x3
    22e3:	mov    ecx,0x1
    22e8:	test   rax,0x1
    22ee:	je     22fc <botlish_fn_19+0x2f4>
    22f4:	mov    rsi,rax
    22f7:	jmp    2320 <botlish_fn_19+0x318>
    22fc:	xor    ecx,ecx
    22fe:	test   rax,0x7
    2304:	je     2312 <botlish_fn_19+0x30a>
    230a:	mov    rsi,rax
    230d:	jmp    2320 <botlish_fn_19+0x318>
    2312:	movzx  rcx,BYTE PTR [rax]
    2316:	mov    rsi,rax
    2319:	rex cmp cl,0x1
    231d:	sete   cl
    2320:	test   cl,cl
    2322:	jne    2340 <botlish_fn_19+0x338>
    2328:	mov    rdi,r12
    232b:	mov    rax,QWORD PTR [rdi+0x10]
    232f:	mov    rcx,QWORD PTR [rax+0x10]
    2333:	xor    rdx,rdx
    2336:	call   233b <botlish_fn_19+0x333>
			2337: R_X86_64_PLT32	rt_type_error-0x4
    233b:	jmp    2397 <botlish_fn_19+0x38f>
    2340:	test   rsi,0x1
    2347:	je     2366 <botlish_fn_19+0x35e>
    234d:	mov    rcx,rsi
    2350:	sub    rcx,0x3
    2354:	seto   al
    2357:	add    rcx,0x1
    235e:	test   al,al
    2360:	je     2374 <botlish_fn_19+0x36c>
    2366:	mov    rdx,r14
    2369:	mov    rdi,r12
    236c:	call   2371 <botlish_fn_19+0x369>
			236d: R_X86_64_PLT32	rt_int_sub-0x4
    2371:	mov    rcx,rax
    2374:	mov    rsi,r13
    2377:	mov    rax,QWORD PTR [rsi+0x8]
    237b:	cmp    rax,0x1
    237f:	jbe    24aa <botlish_fn_19+0x4a2>
    2385:	mov    rax,QWORD PTR [rsi+0x18]
    2389:	test   rax,rax
    238c:	jne    23c1 <botlish_fn_19+0x3b9>
    2392:	jmp    24b5 <botlish_fn_19+0x4ad>
    2397:	xor    rax,rax
    239a:	mov    rbx,QWORD PTR [rsp+0x40]
    239f:	mov    r12,QWORD PTR [rsp+0x48]
    23a4:	mov    r13,QWORD PTR [rsp+0x50]
    23a9:	mov    r14,QWORD PTR [rsp+0x58]
    23ae:	mov    r15,QWORD PTR [rsp+0x60]
    23b3:	add    rsp,0x70
    23b7:	mov    rsp,rbp
    23ba:	pop    rbp
    23bb:	ret
    23bc:	jmp    23c9 <botlish_fn_19+0x3c1>
    23c1:	mov    rax,QWORD PTR [rsi+0x10]
    23c5:	mov    QWORD PTR [rax+0x8],rcx
    23c9:	mov    rax,rbx
    23cc:	mov    rbx,QWORD PTR [rsp+0x40]
    23d1:	mov    r12,QWORD PTR [rsp+0x48]
    23d6:	mov    r13,QWORD PTR [rsp+0x50]
    23db:	mov    r14,QWORD PTR [rsp+0x58]
    23e0:	mov    r15,QWORD PTR [rsp+0x60]
    23e5:	add    rsp,0x70
    23e9:	mov    rsp,rbp
    23ec:	pop    rbp
    23ed:	ret
    23ee:	mov    r15,rdx
    23f1:	mov    rdx,r15
    23f4:	mov    rdi,r12
    23f7:	call   23fc <botlish_fn_19+0x3f4>
			23f8: R_X86_64_PLT32	rt_mutarray_get-0x4
    23fc:	test   rax,rax
    23ff:	jne    206a <botlish_fn_19+0x62>
    2405:	jmp    2397 <botlish_fn_19+0x38f>
    240a:	mov    ecx,0x3
    240f:	mov    rdx,r15
    2412:	mov    rdi,r12
    2415:	call   241a <botlish_fn_19+0x412>
			2416: R_X86_64_PLT32	rt_mutarray_set-0x4
    241a:	test   rax,rax
    241d:	jne    20c8 <botlish_fn_19+0xc0>
    2423:	jmp    2397 <botlish_fn_19+0x38f>
    2428:	mov    rcx,QWORD PTR [rsp+0x30]
    242d:	jmp    2441 <botlish_fn_19+0x439>
    2432:	mov    rcx,QWORD PTR [rsp+0x30]
    2437:	jmp    2441 <botlish_fn_19+0x439>
    243c:	mov    rcx,QWORD PTR [rsp+0x30]
    2441:	mov    rdx,r15
    2444:	mov    rdi,r12
    2447:	call   244c <botlish_fn_19+0x444>
			2448: R_X86_64_PLT32	rt_mutarray_set-0x4
    244c:	test   rax,rax
    244f:	jne    2110 <botlish_fn_19+0x108>
    2455:	jmp    2397 <botlish_fn_19+0x38f>
    245a:	mov    rcx,r14
    245d:	mov    rdx,r15
    2460:	jmp    2476 <botlish_fn_19+0x46e>
    2465:	mov    rcx,r14
    2468:	mov    rdx,r15
    246b:	jmp    2476 <botlish_fn_19+0x46e>
    2470:	mov    rcx,r14
    2473:	mov    rdx,r15
    2476:	mov    rdx,r15
    2479:	mov    rdi,r12
    247c:	call   2481 <botlish_fn_19+0x479>
			247d: R_X86_64_PLT32	rt_mutarray_set-0x4
    2481:	test   rax,rax
    2484:	jne    2156 <botlish_fn_19+0x14e>
    248a:	jmp    2397 <botlish_fn_19+0x38f>
    248f:	mov    edx,0x1
    2494:	mov    rdi,r12
    2497:	call   249c <botlish_fn_19+0x494>
			2498: R_X86_64_PLT32	rt_mutarray_set-0x4
    249c:	test   rax,rax
    249f:	jne    2244 <botlish_fn_19+0x23c>
    24a5:	jmp    2397 <botlish_fn_19+0x38f>
    24aa:	mov    rdx,r14
    24ad:	mov    rdi,r12
    24b0:	jmp    24bb <botlish_fn_19+0x4b3>
    24b5:	mov    rdx,r14
    24b8:	mov    rdi,r12
    24bb:	mov    rdx,r14
    24be:	mov    rdi,r12
    24c1:	call   24c6 <botlish_fn_19+0x4be>
			24c2: R_X86_64_PLT32	rt_mutarray_set-0x4
    24c6:	test   rax,rax
    24c9:	jne    23c9 <botlish_fn_19+0x3c1>
    24cf:	jmp    2397 <botlish_fn_19+0x38f>
    24d4:	add    BYTE PTR [rax],al
    24d6:	add    BYTE PTR [rax],al
    24d8:	(bad)
    24d9:	add    BYTE PTR [rax],al
    24db:	add    BYTE PTR [rax],al
    24dd:	add    BYTE PTR [rax],al
	...

00000000000024e0 <botlish_entry_19: ht_place<HashTable, int, str, str>>:
    24e0:	push   rbp
    24e1:	mov    rbp,rsp
    24e4:	mov    rsi,QWORD PTR [rdx]
    24e7:	mov    r9,QWORD PTR [rdx+0x8]
    24eb:	mov    rcx,QWORD PTR [rdx+0x10]
    24ef:	mov    r8,QWORD PTR [rdx+0x18]
    24f3:	mov    rdx,r9
    24f6:	call   24fb <botlish_entry_19+0x1b>
			24f7: R_X86_64_PLT32	botlish_fn_19-0x4 ; ht_place<HashTable, int, str, str>
    24fb:	mov    rsp,rbp
    24fe:	pop    rbp
    24ff:	ret

0000000000002500 <botlish_fn_20: ht_set<HashTable, str, str>>:
    2500:	push   rbp
    2501:	mov    rbp,rsp
    2504:	sub    rsp,0x60
    2508:	mov    QWORD PTR [rsp+0x30],rbx
    250d:	mov    QWORD PTR [rsp+0x38],r12
    2512:	mov    QWORD PTR [rsp+0x40],r13
    2517:	mov    QWORD PTR [rsp+0x48],r14
    251c:	mov    QWORD PTR [rsp+0x50],r15
    2521:	mov    r12,rdi
    2524:	mov    r14,rdx
    2527:	mov    QWORD PTR [rsp],rsi
    252b:	mov    r13,rsi
    252e:	mov    QWORD PTR [rsp+0x8],rdx
    2533:	mov    QWORD PTR [rsp+0x10],rcx
    2538:	mov    rbx,rcx
    253b:	mov    rdx,r14
    253e:	mov    rsi,r13
    2541:	mov    rdi,r12
    2544:	call   2549 <botlish_fn_20+0x49>
			2545: R_X86_64_PLT32	botlish_fn_7-0x4 ; ht_probe_start<HashTable, str>
    2549:	test   rax,rax
    254c:	mov    rcx,rax
    254f:	je     2740 <botlish_fn_20+0x240>
    2555:	mov    r8,0xffffffffffffffff
    255c:	mov    QWORD PTR [rsp+0x20],r8
    2561:	mov    rdx,r14
    2564:	mov    rsi,r13
    2567:	mov    rdi,r12
    256a:	call   256f <botlish_fn_20+0x6f>
			256b: R_X86_64_PLT32	botlish_fn_10-0x4 ; ht_find_insert<HashTable, str, int, int>
    256f:	test   rax,rax
    2572:	je     2740 <botlish_fn_20+0x240>
    2578:	mov    QWORD PTR [rsp+0x18],rax
    257d:	mov    rsi,r13
    2580:	mov    rcx,QWORD PTR [rsi+0x18]
    2584:	mov    rsi,QWORD PTR [rcx]
    2587:	test   rax,0x1
    258d:	je     279d <botlish_fn_20+0x29d>
    2593:	mov    rdx,QWORD PTR [rsi+0x8]
    2597:	mov    rcx,rax
    259a:	sar    rcx,1
    259d:	mov    r15,rax
    25a0:	cmp    rcx,rdx
    25a3:	jb     25b6 <botlish_fn_20+0xb6>
    25a9:	jmp    27a0 <botlish_fn_20+0x2a0>
    25ae:	mov    rsi,rax
    25b1:	jmp    25be <botlish_fn_20+0xbe>
    25b6:	mov    rax,QWORD PTR [rsi+0x10]
    25ba:	mov    rsi,QWORD PTR [rax+rcx*8]
    25be:	test   rsi,0x1
    25c5:	jne    25ed <botlish_fn_20+0xed>
    25cb:	mov    edx,0x3
    25d0:	mov    rdi,r12
    25d3:	call   25d8 <botlish_fn_20+0xd8>
			25d4: R_X86_64_PLT32	rt_int_cmp-0x4
    25d8:	mov    ecx,0x2
    25dd:	test   rax,rax
    25e0:	cmove  rcx,QWORD PTR [rip+0x208]        # 27f0 <botlish_fn_20+0x2f0>
    25e8:	jmp    25fe <botlish_fn_20+0xfe>
    25ed:	mov    ecx,0x2
    25f2:	cmp    rsi,0x3
    25f6:	cmove  rcx,QWORD PTR [rip+0x1f2]        # 27f0 <botlish_fn_20+0x2f0>
    25fe:	cmp    rcx,0x6
    2602:	je     2700 <botlish_fn_20+0x200>
    2608:	mov    rsi,r13
    260b:	mov    rdi,r12
    260e:	call   2613 <botlish_fn_20+0x113>
			260f: R_X86_64_PLT32	botlish_fn_17-0x4 ; ht_should_grow<HashTable>
    2613:	test   rax,rax
    2616:	je     2740 <botlish_fn_20+0x240>
    261c:	cmp    rax,0x6
    2620:	je     2665 <botlish_fn_20+0x165>
    2626:	mov    rcx,r14
    2629:	mov    rdx,r15
    262c:	mov    rsi,r13
    262f:	mov    rdi,r12
    2632:	mov    r8,rbx
    2635:	call   263a <botlish_fn_20+0x13a>
			2636: R_X86_64_PLT32	botlish_fn_19-0x4 ; ht_place<HashTable, int, str, str>
    263a:	test   rax,rax
    263d:	je     2740 <botlish_fn_20+0x240>
    2643:	mov    rbx,QWORD PTR [rsp+0x30]
    2648:	mov    r12,QWORD PTR [rsp+0x38]
    264d:	mov    r13,QWORD PTR [rsp+0x40]
    2652:	mov    r14,QWORD PTR [rsp+0x48]
    2657:	mov    r15,QWORD PTR [rsp+0x50]
    265c:	add    rsp,0x60
    2660:	mov    rsp,rbp
    2663:	pop    rbp
    2664:	ret
    2665:	mov    rsi,r13
    2668:	mov    rdi,r12
    266b:	call   2670 <botlish_fn_20+0x170>
			266c: R_X86_64_PLT32	botlish_fn_18-0x4 ; ht_grow_or_clean<HashTable>
    2670:	mov    r11,rax
    2673:	mov    r13,rax
    2676:	test   rax,r11
    2679:	je     2740 <botlish_fn_20+0x240>
    267f:	mov    rax,r13
    2682:	mov    QWORD PTR [rsp],rax
    2686:	mov    rdx,r14
    2689:	mov    rsi,r13
    268c:	mov    rdi,r12
    268f:	call   2694 <botlish_fn_20+0x194>
			2690: R_X86_64_PLT32	botlish_fn_7-0x4 ; ht_probe_start<HashTable, str>
    2694:	test   rax,rax
    2697:	mov    rcx,rax
    269a:	je     2740 <botlish_fn_20+0x240>
    26a0:	mov    r8,QWORD PTR [rsp+0x20]
    26a5:	mov    rdx,r14
    26a8:	mov    rsi,r13
    26ab:	mov    rdi,r12
    26ae:	call   26b3 <botlish_fn_20+0x1b3>
			26af: R_X86_64_PLT32	botlish_fn_10-0x4 ; ht_find_insert<HashTable, str, int, int>
    26b3:	test   rax,rax
    26b6:	je     2740 <botlish_fn_20+0x240>
    26bc:	mov    QWORD PTR [rsp+0x18],rax
    26c1:	mov    rcx,r14
    26c4:	mov    rdx,rax
    26c7:	mov    rsi,r13
    26ca:	mov    rdi,r12
    26cd:	mov    r8,rbx
    26d0:	call   26d5 <botlish_fn_20+0x1d5>
			26d1: R_X86_64_PLT32	botlish_fn_19-0x4 ; ht_place<HashTable, int, str, str>
    26d5:	test   rax,rax
    26d8:	je     2740 <botlish_fn_20+0x240>
    26de:	mov    rbx,QWORD PTR [rsp+0x30]
    26e3:	mov    r12,QWORD PTR [rsp+0x38]
    26e8:	mov    r13,QWORD PTR [rsp+0x40]
    26ed:	mov    r14,QWORD PTR [rsp+0x48]
    26f2:	mov    r15,QWORD PTR [rsp+0x50]
    26f7:	add    rsp,0x60
    26fb:	mov    rsp,rbp
    26fe:	pop    rbp
    26ff:	ret
    2700:	mov    rdx,r15
    2703:	mov    rsi,r13
    2706:	mov    rax,QWORD PTR [rsi+0x18]
    270a:	mov    rsi,QWORD PTR [rax+0x10]
    270e:	test   rdx,0x1
    2715:	je     27b9 <botlish_fn_20+0x2b9>
    271b:	mov    rcx,QWORD PTR [rsi+0x8]
    271f:	mov    rax,rdx
    2722:	sar    rax,1
    2725:	cmp    rax,rcx
    2728:	jae    27c4 <botlish_fn_20+0x2c4>
    272e:	mov    rcx,QWORD PTR [rsi+0x18]
    2732:	test   rcx,rcx
    2735:	jne    276d <botlish_fn_20+0x26d>
    273b:	jmp    27cf <botlish_fn_20+0x2cf>
    2740:	xor    rax,rax
    2743:	mov    rbx,QWORD PTR [rsp+0x30]
    2748:	mov    r12,QWORD PTR [rsp+0x38]
    274d:	mov    r13,QWORD PTR [rsp+0x40]
    2752:	mov    r14,QWORD PTR [rsp+0x48]
    2757:	mov    r15,QWORD PTR [rsp+0x50]
    275c:	add    rsp,0x60
    2760:	mov    rsp,rbp
    2763:	pop    rbp
    2764:	ret
    2765:	mov    rax,r13
    2768:	jmp    277b <botlish_fn_20+0x27b>
    276d:	mov    rcx,rbx
    2770:	mov    rdx,QWORD PTR [rsi+0x10]
    2774:	mov    QWORD PTR [rdx+rax*8],rcx
    2778:	mov    rax,r13
    277b:	mov    rbx,QWORD PTR [rsp+0x30]
    2780:	mov    r12,QWORD PTR [rsp+0x38]
    2785:	mov    r13,QWORD PTR [rsp+0x40]
    278a:	mov    r14,QWORD PTR [rsp+0x48]
    278f:	mov    r15,QWORD PTR [rsp+0x50]
    2794:	add    rsp,0x60
    2798:	mov    rsp,rbp
    279b:	pop    rbp
    279c:	ret
    279d:	mov    r15,rax
    27a0:	mov    rdx,r15
    27a3:	mov    rdi,r12
    27a6:	call   27ab <botlish_fn_20+0x2ab>
			27a7: R_X86_64_PLT32	rt_mutarray_get-0x4
    27ab:	test   rax,rax
    27ae:	jne    25ae <botlish_fn_20+0xae>
    27b4:	jmp    2740 <botlish_fn_20+0x240>
    27b9:	mov    rcx,rbx
    27bc:	mov    rdi,r12
    27bf:	jmp    27d5 <botlish_fn_20+0x2d5>
    27c4:	mov    rcx,rbx
    27c7:	mov    rdi,r12
    27ca:	jmp    27d5 <botlish_fn_20+0x2d5>
    27cf:	mov    rcx,rbx
    27d2:	mov    rdi,r12
    27d5:	mov    rdi,r12
    27d8:	call   27dd <botlish_fn_20+0x2dd>
			27d9: R_X86_64_PLT32	rt_mutarray_set-0x4
    27dd:	test   rax,rax
    27e0:	jne    2765 <botlish_fn_20+0x265>
    27e6:	jmp    2740 <botlish_fn_20+0x240>
    27eb:	add    BYTE PTR [rax],al
    27ed:	add    BYTE PTR [rax],al
    27ef:	add    BYTE PTR [rsi],al
    27f1:	add    BYTE PTR [rax],al
    27f3:	add    BYTE PTR [rax],al
    27f5:	add    BYTE PTR [rax],al
	...

00000000000027f8 <botlish_entry_20: ht_set<HashTable, str, str>>:
    27f8:	push   rbp
    27f9:	mov    rbp,rsp
    27fc:	mov    rsi,QWORD PTR [rdx]
    27ff:	mov    r8,QWORD PTR [rdx+0x8]
    2803:	mov    rcx,QWORD PTR [rdx+0x10]
    2807:	mov    rdx,r8
    280a:	call   280f <botlish_entry_20+0x17>
			280b: R_X86_64_PLT32	botlish_fn_20-0x4 ; ht_set<HashTable, str, str>
    280f:	mov    rsp,rbp
    2812:	pop    rbp
    2813:	ret
    2814:	add    BYTE PTR [rax],al
	...

0000000000002818 <botlish_fn_21: ht_delete<HashTable, str>>:
    2818:	push   rbp
    2819:	mov    rbp,rsp
    281c:	sub    rsp,0x50
    2820:	mov    QWORD PTR [rsp+0x30],rbx
    2825:	mov    QWORD PTR [rsp+0x38],r12
    282a:	mov    QWORD PTR [rsp+0x40],r13
    282f:	mov    QWORD PTR [rsp+0x48],r14
    2834:	mov    r12,rdx
    2837:	mov    r13,rdi
    283a:	mov    QWORD PTR [rsp],rsi
    283e:	mov    rbx,rsi
    2841:	mov    rdx,r12
    2844:	mov    rsi,rbx
    2847:	mov    rdi,r13
    284a:	call   284f <botlish_fn_21+0x37>
			284b: R_X86_64_PLT32	botlish_fn_7-0x4 ; ht_probe_start<HashTable, str>
    284f:	test   rax,rax
    2852:	mov    rcx,rax
    2855:	je     2b6f <botlish_fn_21+0x357>
    285b:	mov    rdx,r12
    285e:	mov    rsi,rbx
    2861:	mov    rdi,r13
    2864:	call   2869 <botlish_fn_21+0x51>
			2865: R_X86_64_PLT32	botlish_fn_9-0x4 ; ht_find_get<HashTable, str, int>
    2869:	mov    rcx,rax
    286c:	mov    r12,rax
    286f:	test   rax,rcx
    2872:	je     2b6f <botlish_fn_21+0x357>
    2878:	mov    rax,r12
    287b:	test   rax,0x1
    2881:	jne    28ac <botlish_fn_21+0x94>
    2887:	mov    edx,0x1
    288c:	mov    rsi,r12
    288f:	mov    rdi,r13
    2892:	call   2897 <botlish_fn_21+0x7f>
			2893: R_X86_64_PLT32	rt_int_cmp-0x4
    2897:	mov    ecx,0x2
    289c:	test   rax,rax
    289f:	cmovge rcx,QWORD PTR [rip+0x3b9]        # 2c60 <botlish_fn_21+0x448>
    28a7:	jmp    28bc <botlish_fn_21+0xa4>
    28ac:	mov    ecx,0x2
    28b1:	test   r12,r12
    28b4:	cmovg  rcx,QWORD PTR [rip+0x3a4]        # 2c60 <botlish_fn_21+0x448>
    28bc:	cmp    rcx,0x6
    28c0:	je     28ce <botlish_fn_21+0xb6>
    28c6:	mov    rax,rbx
    28c9:	jmp    2b9f <botlish_fn_21+0x387>
    28ce:	mov    rcx,QWORD PTR [rbx+0x18]
    28d2:	mov    rsi,QWORD PTR [rcx]
    28d5:	test   r12,0x1
    28dc:	je     2bbc <botlish_fn_21+0x3a4>
    28e2:	mov    rdx,QWORD PTR [rsi+0x8]
    28e6:	mov    rcx,r12
    28e9:	sar    rcx,1
    28ec:	cmp    rcx,rdx
    28ef:	jae    2bbc <botlish_fn_21+0x3a4>
    28f5:	mov    rdx,QWORD PTR [rsi+0x18]
    28f9:	test   rdx,rdx
    28fc:	je     2bbc <botlish_fn_21+0x3a4>
    2902:	mov    rax,QWORD PTR [rsi+0x10]
    2906:	mov    QWORD PTR [rax+rcx*8],0x5
    290e:	mov    rax,QWORD PTR [rbx+0x18]
    2912:	mov    rsi,QWORD PTR [rax+0x8]
    2916:	test   r12,0x1
    291d:	je     2bda <botlish_fn_21+0x3c2>
    2923:	mov    rdx,QWORD PTR [rsi+0x8]
    2927:	mov    rcx,r12
    292a:	sar    rcx,1
    292d:	cmp    rcx,rdx
    2930:	jae    2bda <botlish_fn_21+0x3c2>
    2936:	mov    rax,QWORD PTR [rsi+0x18]
    293a:	test   rax,rax
    293d:	je     2bda <botlish_fn_21+0x3c2>
    2943:	mov    rsi,QWORD PTR [rsi+0x10]
    2947:	mov    QWORD PTR [rsi+rcx*8],0xa
    294f:	mov    rsi,QWORD PTR [rbx+0x18]
    2953:	mov    rsi,QWORD PTR [rsi+0x10]
    2957:	test   r12,0x1
    295e:	je     2bf8 <botlish_fn_21+0x3e0>
    2964:	mov    r10,QWORD PTR [rsi+0x8]
    2968:	mov    r9,r12
    296b:	sar    r9,1
    296e:	cmp    r9,r10
    2971:	jae    2bf8 <botlish_fn_21+0x3e0>
    2977:	mov    rax,QWORD PTR [rsi+0x18]
    297b:	test   rax,rax
    297e:	je     2bf8 <botlish_fn_21+0x3e0>
    2984:	mov    rax,QWORD PTR [rsi+0x10]
    2988:	mov    QWORD PTR [rax+r9*8],0xa
    2990:	mov    rax,QWORD PTR [rbx+0x18]
    2994:	mov    rsi,QWORD PTR [rax+0x18]
    2998:	mov    QWORD PTR [rsp+0x8],rsi
    299d:	mov    r14,rsi
    29a0:	mov    QWORD PTR [rsp+0x10],0x1
    29a9:	mov    rsi,rbx
    29ac:	mov    rdi,r13
    29af:	call   29b4 <botlish_fn_21+0x19c>
			29b0: R_X86_64_PLT32	botlish_fn_4-0x4 ; ht_size<HashTable>
    29b4:	test   rax,rax
    29b7:	je     2b6f <botlish_fn_21+0x357>
    29bd:	mov    QWORD PTR [rsp+0x18],rax
    29c2:	mov    edx,0x3
    29c7:	mov    r12,rdx
    29ca:	mov    QWORD PTR [rsp+0x20],0x3
    29d3:	mov    ecx,0x1
    29d8:	test   rax,0x1
    29de:	je     29ec <botlish_fn_21+0x1d4>
    29e4:	mov    rsi,rax
    29e7:	jmp    2a10 <botlish_fn_21+0x1f8>
    29ec:	xor    ecx,ecx
    29ee:	test   rax,0x7
    29f4:	je     2a02 <botlish_fn_21+0x1ea>
    29fa:	mov    rsi,rax
    29fd:	jmp    2a10 <botlish_fn_21+0x1f8>
    2a02:	movzx  rcx,BYTE PTR [rax]
    2a06:	mov    rsi,rax
    2a09:	rex cmp cl,0x1
    2a0d:	sete   cl
    2a10:	test   cl,cl
    2a12:	jne    2a30 <botlish_fn_21+0x218>
    2a18:	mov    rdi,r13
    2a1b:	mov    rax,QWORD PTR [rdi+0x10]
    2a1f:	mov    rcx,QWORD PTR [rax+0x10]
    2a23:	xor    rdx,rdx
    2a26:	call   2a2b <botlish_fn_21+0x213>
			2a27: R_X86_64_PLT32	rt_type_error-0x4
    2a2b:	jmp    2b6f <botlish_fn_21+0x357>
    2a30:	test   rsi,0x1
    2a37:	je     2a56 <botlish_fn_21+0x23e>
    2a3d:	mov    rcx,rsi
    2a40:	sub    rcx,0x3
    2a44:	seto   al
    2a47:	add    rcx,0x1
    2a4e:	test   al,al
    2a50:	je     2a64 <botlish_fn_21+0x24c>
    2a56:	mov    rdx,r12
    2a59:	mov    rdi,r13
    2a5c:	call   2a61 <botlish_fn_21+0x249>
			2a5d: R_X86_64_PLT32	rt_int_sub-0x4
    2a61:	mov    rcx,rax
    2a64:	mov    rsi,r14
    2a67:	mov    rax,QWORD PTR [rsi+0x8]
    2a6b:	test   rax,rax
    2a6e:	je     2c16 <botlish_fn_21+0x3fe>
    2a74:	mov    rax,QWORD PTR [rsi+0x18]
    2a78:	test   rax,rax
    2a7b:	je     2c16 <botlish_fn_21+0x3fe>
    2a81:	mov    rax,QWORD PTR [rsi+0x10]
    2a85:	mov    QWORD PTR [rax],rcx
    2a88:	mov    rax,QWORD PTR [rbx+0x18]
    2a8c:	mov    rsi,QWORD PTR [rax+0x18]
    2a90:	mov    QWORD PTR [rsp+0x8],rsi
    2a95:	mov    r14,rsi
    2a98:	mov    QWORD PTR [rsp+0x10],0x3
    2aa1:	mov    rsi,rbx
    2aa4:	mov    rdi,r13
    2aa7:	call   2aac <botlish_fn_21+0x294>
			2aa8: R_X86_64_PLT32	botlish_fn_5-0x4 ; ht_tombstones<HashTable>
    2aac:	test   rax,rax
    2aaf:	je     2b6f <botlish_fn_21+0x357>
    2ab5:	mov    QWORD PTR [rsp+0x18],rax
    2aba:	mov    QWORD PTR [rsp+0x20],0x3
    2ac3:	mov    ecx,0x1
    2ac8:	test   rax,0x1
    2ace:	je     2adc <botlish_fn_21+0x2c4>
    2ad4:	mov    rsi,rax
    2ad7:	jmp    2b00 <botlish_fn_21+0x2e8>
    2adc:	xor    ecx,ecx
    2ade:	test   rax,0x7
    2ae4:	je     2af2 <botlish_fn_21+0x2da>
    2aea:	mov    rsi,rax
    2aed:	jmp    2b00 <botlish_fn_21+0x2e8>
    2af2:	movzx  r10,BYTE PTR [rax]
    2af6:	mov    rsi,rax
    2af9:	cmp    r10b,0x1
    2afd:	sete   cl
    2b00:	test   cl,cl
    2b02:	jne    2b1f <botlish_fn_21+0x307>
    2b08:	mov    rdi,r13
    2b0b:	mov    rax,QWORD PTR [rdi+0x10]
    2b0f:	mov    rcx,QWORD PTR [rax]
    2b12:	xor    rdx,rdx
    2b15:	call   2b1a <botlish_fn_21+0x302>
			2b16: R_X86_64_PLT32	rt_type_error-0x4
    2b1a:	jmp    2b6f <botlish_fn_21+0x357>
    2b1f:	test   rsi,0x1
    2b26:	je     2b3e <botlish_fn_21+0x326>
    2b2c:	mov    rcx,rsi
    2b2f:	add    rcx,0x2
    2b33:	seto   al
    2b36:	test   al,al
    2b38:	je     2b4c <botlish_fn_21+0x334>
    2b3e:	mov    rdx,r12
    2b41:	mov    rdi,r13
    2b44:	call   2b49 <botlish_fn_21+0x331>
			2b45: R_X86_64_PLT32	rt_int_add-0x4
    2b49:	mov    rcx,rax
    2b4c:	mov    rsi,r14
    2b4f:	mov    rax,QWORD PTR [rsi+0x8]
    2b53:	cmp    rax,0x1
    2b57:	jbe    2c31 <botlish_fn_21+0x419>
    2b5d:	mov    rax,QWORD PTR [rsi+0x18]
    2b61:	test   rax,rax
    2b64:	jne    2b94 <botlish_fn_21+0x37c>
    2b6a:	jmp    2c3c <botlish_fn_21+0x424>
    2b6f:	xor    rax,rax
    2b72:	mov    rbx,QWORD PTR [rsp+0x30]
    2b77:	mov    r12,QWORD PTR [rsp+0x38]
    2b7c:	mov    r13,QWORD PTR [rsp+0x40]
    2b81:	mov    r14,QWORD PTR [rsp+0x48]
    2b86:	add    rsp,0x50
    2b8a:	mov    rsp,rbp
    2b8d:	pop    rbp
    2b8e:	ret
    2b8f:	jmp    2b9c <botlish_fn_21+0x384>
    2b94:	mov    rax,QWORD PTR [rsi+0x10]
    2b98:	mov    QWORD PTR [rax+0x8],rcx
    2b9c:	mov    rax,rbx
    2b9f:	mov    rbx,QWORD PTR [rsp+0x30]
    2ba4:	mov    r12,QWORD PTR [rsp+0x38]
    2ba9:	mov    r13,QWORD PTR [rsp+0x40]
    2bae:	mov    r14,QWORD PTR [rsp+0x48]
    2bb3:	add    rsp,0x50
    2bb7:	mov    rsp,rbp
    2bba:	pop    rbp
    2bbb:	ret
    2bbc:	mov    ecx,0x5
    2bc1:	mov    rdx,r12
    2bc4:	mov    rdi,r13
    2bc7:	call   2bcc <botlish_fn_21+0x3b4>
			2bc8: R_X86_64_PLT32	rt_mutarray_set-0x4
    2bcc:	test   rax,rax
    2bcf:	jne    290e <botlish_fn_21+0xf6>
    2bd5:	jmp    2b6f <botlish_fn_21+0x357>
    2bda:	mov    ecx,0xa
    2bdf:	mov    rdx,r12
    2be2:	mov    rdi,r13
    2be5:	call   2bea <botlish_fn_21+0x3d2>
			2be6: R_X86_64_PLT32	rt_mutarray_set-0x4
    2bea:	test   rax,rax
    2bed:	jne    294f <botlish_fn_21+0x137>
    2bf3:	jmp    2b6f <botlish_fn_21+0x357>
    2bf8:	mov    ecx,0xa
    2bfd:	mov    rdx,r12
    2c00:	mov    rdi,r13
    2c03:	call   2c08 <botlish_fn_21+0x3f0>
			2c04: R_X86_64_PLT32	rt_mutarray_set-0x4
    2c08:	test   rax,rax
    2c0b:	jne    2990 <botlish_fn_21+0x178>
    2c11:	jmp    2b6f <botlish_fn_21+0x357>
    2c16:	mov    edx,0x1
    2c1b:	mov    rdi,r13
    2c1e:	call   2c23 <botlish_fn_21+0x40b>
			2c1f: R_X86_64_PLT32	rt_mutarray_set-0x4
    2c23:	test   rax,rax
    2c26:	jne    2a88 <botlish_fn_21+0x270>
    2c2c:	jmp    2b6f <botlish_fn_21+0x357>
    2c31:	mov    rdx,r12
    2c34:	mov    rdi,r13
    2c37:	jmp    2c42 <botlish_fn_21+0x42a>
    2c3c:	mov    rdx,r12
    2c3f:	mov    rdi,r13
    2c42:	mov    rdx,r12
    2c45:	mov    rdi,r13
    2c48:	call   2c4d <botlish_fn_21+0x435>
			2c49: R_X86_64_PLT32	rt_mutarray_set-0x4
    2c4d:	test   rax,rax
    2c50:	jne    2b9c <botlish_fn_21+0x384>
    2c56:	jmp    2b6f <botlish_fn_21+0x357>
    2c5b:	add    BYTE PTR [rax],al
    2c5d:	add    BYTE PTR [rax],al
    2c5f:	add    BYTE PTR [rsi],al
    2c61:	add    BYTE PTR [rax],al
    2c63:	add    BYTE PTR [rax],al
    2c65:	add    BYTE PTR [rax],al
	...

0000000000002c68 <botlish_entry_21: ht_delete<HashTable, str>>:
    2c68:	push   rbp
    2c69:	mov    rbp,rsp
    2c6c:	mov    rsi,QWORD PTR [rdx]
    2c6f:	mov    rdx,QWORD PTR [rdx+0x8]
    2c73:	call   2c78 <botlish_entry_21+0x10>
			2c74: R_X86_64_PLT32	botlish_fn_21-0x4 ; ht_delete<HashTable, str>
    2c78:	mov    rsp,rbp
    2c7b:	pop    rbp
    2c7c:	ret
    2c7d:	add    BYTE PTR [rax],al
	...

0000000000002c80 <botlish_fn_22: sample_checks<generic>>:
    2c80:	push   rbp
    2c81:	mov    rbp,rsp
    2c84:	sub    rsp,0xa0
    2c8b:	mov    QWORD PTR [rsp+0x70],rbx
    2c90:	mov    QWORD PTR [rsp+0x78],r12
    2c95:	mov    QWORD PTR [rsp+0x80],r13
    2c9d:	mov    QWORD PTR [rsp+0x88],r14
    2ca5:	mov    QWORD PTR [rsp+0x90],r15
    2cad:	mov    r13,rdi
    2cb0:	mov    QWORD PTR [rsp],0x0
    2cb8:	mov    QWORD PTR [rsp+0x8],0x0
    2cc1:	mov    QWORD PTR [rsp+0x10],0x0
    2cca:	mov    QWORD PTR [rsp+0x18],0x0
    2cd3:	mov    QWORD PTR [rsp+0x20],0x0
    2cdc:	mov    QWORD PTR [rsp+0x28],0x0
    2ce5:	mov    rdi,r13
    2ce8:	call   2ced <botlish_fn_22+0x6d>
			2ce9: R_X86_64_PLT32	botlish_fn_3-0x4 ; ht_new<generic>
    2ced:	test   rax,rax
    2cf0:	je     2f2c <botlish_fn_22+0x2ac>
    2cf6:	mov    QWORD PTR [rsp],rax
    2cfa:	mov    rsi,rax
    2cfd:	mov    rdi,r13
    2d00:	mov    rax,QWORD PTR [rdi+0x10]
    2d04:	mov    rdx,QWORD PTR [rax+0x18]
    2d08:	mov    QWORD PTR [rsp+0x8],rdx
    2d0d:	mov    rax,QWORD PTR [rdi+0x10]
    2d11:	mov    rcx,QWORD PTR [rax+0x20]
    2d15:	mov    QWORD PTR [rsp+0x10],rcx
    2d1a:	call   2d1f <botlish_fn_22+0x9f>
			2d1b: R_X86_64_PLT32	botlish_fn_20-0x4 ; ht_set<HashTable, str, str>
    2d1f:	test   rax,rax
    2d22:	je     2f2c <botlish_fn_22+0x2ac>
    2d28:	mov    QWORD PTR [rsp],rax
    2d2c:	mov    rdi,r13
    2d2f:	mov    rsi,QWORD PTR [rdi+0x10]
    2d33:	mov    rdx,QWORD PTR [rsi+0x28]
    2d37:	mov    QWORD PTR [rsp+0x8],rdx
    2d3c:	mov    rsi,QWORD PTR [rdi+0x10]
    2d40:	mov    rcx,QWORD PTR [rsi+0x30]
    2d44:	mov    QWORD PTR [rsp+0x10],rcx
    2d49:	mov    rsi,rax
    2d4c:	call   2d51 <botlish_fn_22+0xd1>
			2d4d: R_X86_64_PLT32	botlish_fn_20-0x4 ; ht_set<HashTable, str, str>
    2d51:	test   rax,rax
    2d54:	je     2f2c <botlish_fn_22+0x2ac>
    2d5a:	mov    QWORD PTR [rsp],rax
    2d5e:	mov    rsi,rax
    2d61:	mov    rdi,r13
    2d64:	mov    r11,QWORD PTR [rdi+0x10]
    2d68:	mov    rdx,QWORD PTR [r11+0x18]
    2d6c:	mov    QWORD PTR [rsp+0x8],rdx
    2d71:	mov    rax,QWORD PTR [rdi+0x10]
    2d75:	mov    rcx,QWORD PTR [rax+0x38]
    2d79:	mov    QWORD PTR [rsp+0x10],rcx
    2d7e:	call   2d83 <botlish_fn_22+0x103>
			2d7f: R_X86_64_PLT32	botlish_fn_20-0x4 ; ht_set<HashTable, str, str>
    2d83:	test   rax,rax
    2d86:	je     2f2c <botlish_fn_22+0x2ac>
    2d8c:	mov    QWORD PTR [rsp],rax
    2d90:	mov    rbx,rax
    2d93:	mov    rdi,r13
    2d96:	mov    rax,QWORD PTR [rdi+0x10]
    2d9a:	mov    rdx,QWORD PTR [rax+0x28]
    2d9e:	mov    rsi,rbx
    2da1:	call   2da6 <botlish_fn_22+0x126>
			2da2: R_X86_64_PLT32	botlish_fn_12-0x4 ; ht_contains<HashTable, str>
    2da6:	test   rax,rax
    2da9:	je     2f2c <botlish_fn_22+0x2ac>
    2daf:	mov    QWORD PTR [rsp+0x8],rax
    2db4:	mov    rdi,r13
    2db7:	mov    r15,rax
    2dba:	mov    rax,QWORD PTR [rdi+0x10]
    2dbe:	mov    rdx,QWORD PTR [rax+0x28]
    2dc2:	mov    QWORD PTR [rsp+0x10],rdx
    2dc7:	mov    rsi,rbx
    2dca:	call   2dcf <botlish_fn_22+0x14f>
			2dcb: R_X86_64_PLT32	botlish_fn_21-0x4 ; ht_delete<HashTable, str>
    2dcf:	mov    rcx,rax
    2dd2:	mov    r14,rax
    2dd5:	test   rax,rcx
    2dd8:	je     2f2c <botlish_fn_22+0x2ac>
    2dde:	mov    rdi,r13
    2de1:	mov    rax,QWORD PTR [rdi+0x10]
    2de5:	mov    rdx,QWORD PTR [rax+0x18]
    2de9:	mov    rsi,r14
    2dec:	call   2df1 <botlish_fn_22+0x171>
			2ded: R_X86_64_PLT32	botlish_fn_11-0x4 ; ht_get<HashTable, str>
    2df1:	test   rax,rax
    2df4:	je     2f2c <botlish_fn_22+0x2ac>
    2dfa:	mov    rdi,r13
    2dfd:	mov    rcx,QWORD PTR [rdi+0x10]
    2e01:	mov    rdx,QWORD PTR [rcx+0x38]
    2e05:	mov    rcx,rax
    2e08:	and    rcx,rdx
    2e0b:	mov    rsi,rax
    2e0e:	test   rcx,0x1
    2e15:	jne    2e31 <botlish_fn_22+0x1b1>
    2e1b:	mov    rdi,r13
    2e1e:	call   2e23 <botlish_fn_22+0x1a3>
			2e1f: R_X86_64_PLT32	rt_value_eq-0x4
    2e23:	test   rax,rax
    2e26:	je     2f2c <botlish_fn_22+0x2ac>
    2e2c:	jmp    2e41 <botlish_fn_22+0x1c1>
    2e31:	mov    eax,0x2
    2e36:	cmp    rsi,rdx
    2e39:	cmove  rax,QWORD PTR [rip+0x14f]        # 2f90 <botlish_fn_22+0x310>
    2e41:	mov    QWORD PTR [rsp],rax
    2e45:	mov    rdi,r13
    2e48:	mov    QWORD PTR [rsp+0x60],rax
    2e4d:	mov    rax,QWORD PTR [rdi+0x10]
    2e51:	mov    rdx,QWORD PTR [rax+0x28]
    2e55:	mov    rsi,r14
    2e58:	call   2e5d <botlish_fn_22+0x1dd>
			2e59: R_X86_64_PLT32	botlish_fn_12-0x4 ; ht_contains<HashTable, str>
    2e5d:	mov    rbx,rax
    2e60:	test   rbx,rbx
    2e63:	je     2f2c <botlish_fn_22+0x2ac>
    2e69:	mov    QWORD PTR [rsp+0x10],rbx
    2e6e:	mov    rdi,r13
    2e71:	mov    rax,QWORD PTR [rdi+0x10]
    2e75:	mov    rdx,QWORD PTR [rax+0x40]
    2e79:	mov    rsi,r14
    2e7c:	call   2e81 <botlish_fn_22+0x201>
			2e7d: R_X86_64_PLT32	botlish_fn_12-0x4 ; ht_contains<HashTable, str>
    2e81:	mov    r12,rax
    2e84:	test   r12,r12
    2e87:	je     2f2c <botlish_fn_22+0x2ac>
    2e8d:	mov    QWORD PTR [rsp+0x18],r12
    2e92:	mov    rdi,r13
    2e95:	mov    rax,QWORD PTR [rdi+0x10]
    2e99:	mov    rdx,QWORD PTR [rax+0x40]
    2e9d:	mov    rsi,r14
    2ea0:	call   2ea5 <botlish_fn_22+0x225>
			2ea1: R_X86_64_PLT32	botlish_fn_11-0x4 ; ht_get<HashTable, str>
    2ea5:	test   rax,rax
    2ea8:	mov    rsi,rax
    2eab:	je     2f2c <botlish_fn_22+0x2ac>
    2eb1:	mov    edx,0xa
    2eb6:	mov    rdi,r13
    2eb9:	call   2ebe <botlish_fn_22+0x23e>
			2eba: R_X86_64_PLT32	rt_value_eq-0x4
    2ebe:	test   rax,rax
    2ec1:	je     2f2c <botlish_fn_22+0x2ac>
    2ec7:	mov    QWORD PTR [rsp+0x20],rax
    2ecc:	mov    rsi,r14
    2ecf:	mov    r14,rax
    2ed2:	mov    rdi,r13
    2ed5:	call   2eda <botlish_fn_22+0x25a>
			2ed6: R_X86_64_PLT32	botlish_fn_4-0x4 ; ht_size<HashTable>
    2eda:	test   rax,rax
    2edd:	je     2f2c <botlish_fn_22+0x2ac>
    2ee3:	mov    QWORD PTR [rsp+0x28],rax
    2ee8:	lea    rdx,[rsp+0x30]
    2eed:	mov    rcx,QWORD PTR [rsp+0x60]
    2ef2:	mov    QWORD PTR [rsp+0x30],rcx
    2ef7:	mov    rcx,r15
    2efa:	mov    QWORD PTR [rsp+0x38],rcx
    2eff:	mov    QWORD PTR [rsp+0x40],rbx
    2f04:	mov    QWORD PTR [rsp+0x48],r12
    2f09:	mov    rcx,r14
    2f0c:	mov    QWORD PTR [rsp+0x50],rcx
    2f11:	mov    QWORD PTR [rsp+0x58],rax
    2f16:	mov    esi,0x6
    2f1b:	mov    rdi,r13
    2f1e:	call   2f23 <botlish_fn_22+0x2a3>
			2f1f: R_X86_64_PLT32	rt_list_new-0x4
    2f23:	test   rax,rax
    2f26:	jne    2f5d <botlish_fn_22+0x2dd>
    2f2c:	xor    rax,rax
    2f2f:	mov    rbx,QWORD PTR [rsp+0x70]
    2f34:	mov    r12,QWORD PTR [rsp+0x78]
    2f39:	mov    r13,QWORD PTR [rsp+0x80]
    2f41:	mov    r14,QWORD PTR [rsp+0x88]
    2f49:	mov    r15,QWORD PTR [rsp+0x90]
    2f51:	add    rsp,0xa0
    2f58:	mov    rsp,rbp
    2f5b:	pop    rbp
    2f5c:	ret
    2f5d:	mov    rbx,QWORD PTR [rsp+0x70]
    2f62:	mov    r12,QWORD PTR [rsp+0x78]
    2f67:	mov    r13,QWORD PTR [rsp+0x80]
    2f6f:	mov    r14,QWORD PTR [rsp+0x88]
    2f77:	mov    r15,QWORD PTR [rsp+0x90]
    2f7f:	add    rsp,0xa0
    2f86:	mov    rsp,rbp
    2f89:	pop    rbp
    2f8a:	ret
    2f8b:	add    BYTE PTR [rax],al
    2f8d:	add    BYTE PTR [rax],al
    2f8f:	add    BYTE PTR [rsi],al
    2f91:	add    BYTE PTR [rax],al
    2f93:	add    BYTE PTR [rax],al
    2f95:	add    BYTE PTR [rax],al
	...

0000000000002f98 <botlish_entry_22: sample_checks<generic>>:
    2f98:	push   rbp
    2f99:	mov    rbp,rsp
    2f9c:	call   2fa1 <botlish_entry_22+0x9>
			2f9d: R_X86_64_PLT32	botlish_fn_22-0x4 ; sample_checks<generic>
    2fa1:	mov    rsp,rbp
    2fa4:	pop    rbp
    2fa5:	ret

0000000000002fa6 <botlish_fn_23: sample<generic>>:
    2fa6:	push   rbp
    2fa7:	mov    rbp,rsp
    2faa:	sub    rsp,0x10
    2fae:	mov    QWORD PTR [rsp],r12
    2fb2:	mov    r12,rdi
    2fb5:	mov    rdi,r12
    2fb8:	call   2fbd <botlish_fn_23+0x17>
			2fb9: R_X86_64_PLT32	botlish_fn_22-0x4 ; sample_checks<generic>
    2fbd:	test   rax,rax
    2fc0:	jne    3009 <botlish_fn_23+0x63>
    2fc6:	mov    rdi,r12
    2fc9:	call   2fce <botlish_fn_23+0x28>
			2fca: R_X86_64_PLT32	rt_declared_error-0x4
    2fce:	cmp    rax,0x40000001
    2fd4:	jne    2ff9 <botlish_fn_23+0x53>
    2fda:	mov    rdi,r12
    2fdd:	call   2fe2 <botlish_fn_23+0x3c>
			2fde: R_X86_64_PLT32	rt_clear_declared_error-0x4
    2fe2:	xor    rdx,rdx
    2fe5:	mov    rdi,r12
    2fe8:	mov    rsi,rdx
    2feb:	call   2ff0 <botlish_fn_23+0x4a>
			2fec: R_X86_64_PLT32	rt_list_new-0x4
    2ff0:	test   rax,rax
    2ff3:	jne    3009 <botlish_fn_23+0x63>
    2ff9:	xor    rax,rax
    2ffc:	mov    r12,QWORD PTR [rsp]
    3000:	add    rsp,0x10
    3004:	mov    rsp,rbp
    3007:	pop    rbp
    3008:	ret
    3009:	mov    r12,QWORD PTR [rsp]
    300d:	add    rsp,0x10
    3011:	mov    rsp,rbp
    3014:	pop    rbp
    3015:	ret

0000000000003016 <botlish_entry_23: sample<generic>>:
    3016:	push   rbp
    3017:	mov    rbp,rsp
    301a:	call   301f <botlish_entry_23+0x9>
			301b: R_X86_64_PLT32	botlish_fn_23-0x4 ; sample<generic>
    301f:	mov    rsp,rbp
    3022:	pop    rbp
    3023:	ret
