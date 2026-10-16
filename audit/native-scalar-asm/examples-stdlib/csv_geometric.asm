; source:  examples/stdlib/csv_geometric.bot
; backend: Cranelift (specialize=1), native::object
; object:  ELF64 x86-64, unlinked (Botlish-generated code only; runtime
;          helpers are unresolved imports, so their bodies are not present)
; format:  objdump -dr --no-show-raw-insn -M intel
; total machine code bytes: 6330  (per function: 312 89 89 357 420 420 202 202 81 365 309 470 932 311 758 215 480 318)
;
; function symbol -> Botlish label:
;   botlish_fn_0 / botlish_entry_0 -> <program entry>
;   botlish_fn_1 / botlish_entry_1 -> geo_new<str>
;   botlish_fn_2 / botlish_entry_2 -> geo_new<List[str]>
;   botlish_fn_3 / botlish_entry_3 -> geo_new_capacity<int, int>
;   botlish_fn_4 / botlish_entry_4 -> geo_grow<mutarray, int, str>
;   botlish_fn_5 / botlish_entry_5 -> geo_grow<mutarray, int, List[str]>
;   botlish_fn_6 / botlish_entry_6 -> geo_append<mutarray, int, str>
;   botlish_fn_7 / botlish_entry_7 -> geo_append<mutarray, int, List[str]>
;   botlish_fn_8 / botlish_entry_8 -> geo_finish<mutarray, int>
;   botlish_fn_9 / botlish_entry_9 -> peek<str, int>
;   botlish_fn_10 / botlish_entry_10 -> quote_at?<str, int>
;   botlish_fn_11 / botlish_entry_11 -> scan_unquoted<str, int, int>
;   botlish_fn_12 / botlish_entry_12 -> scan_quoted<str, int, str>
;   botlish_fn_13 / botlish_entry_13 -> scan_field<str, int>
;   botlish_fn_14 / botlish_entry_14 -> scan_record_rest<str, int, mutarray, int>
;   botlish_fn_15 / botlish_entry_15 -> scan_record<str, int>
;   botlish_fn_16 / botlish_entry_16 -> scan_records<str, int, mutarray, int>
;   botlish_fn_17 / botlish_entry_17 -> csv_parse<str>


csv_geometric.asm.o:     file format elf64-x86-64


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
			1c: R_X86_64_PLT32	botlish_fn_17-0x4 ; csv_parse<str>
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

00000000000000f9 <botlish_fn_1: geo_new<str>>:
      f9:	push   rbp
      fa:	mov    rbp,rsp
      fd:	sub    rsp,0x10
     101:	mov    QWORD PTR [rsp],rsi
     105:	mov    rdx,rsi
     108:	mov    esi,0x3
     10d:	mov    QWORD PTR [rsp+0x8],0x3
     116:	call   11b <botlish_fn_1+0x22>
			117: R_X86_64_PLT32	rt_mutarray_create-0x4
     11b:	test   rax,rax
     11e:	jne    130 <botlish_fn_1+0x37>
     124:	xor    rax,rax
     127:	add    rsp,0x10
     12b:	mov    rsp,rbp
     12e:	pop    rbp
     12f:	ret
     130:	add    rsp,0x10
     134:	mov    rsp,rbp
     137:	pop    rbp
     138:	ret

0000000000000139 <botlish_entry_1: geo_new<str>>:
     139:	push   rbp
     13a:	mov    rbp,rsp
     13d:	mov    rsi,QWORD PTR [rdx]
     140:	call   145 <botlish_entry_1+0xc>
			141: R_X86_64_PLT32	botlish_fn_1-0x4 ; geo_new<str>
     145:	mov    rsp,rbp
     148:	pop    rbp
     149:	ret

000000000000014a <botlish_fn_2: geo_new<List[str]>>:
     14a:	push   rbp
     14b:	mov    rbp,rsp
     14e:	sub    rsp,0x10
     152:	mov    QWORD PTR [rsp],rsi
     156:	mov    rdx,rsi
     159:	mov    esi,0x3
     15e:	mov    QWORD PTR [rsp+0x8],0x3
     167:	call   16c <botlish_fn_2+0x22>
			168: R_X86_64_PLT32	rt_mutarray_create-0x4
     16c:	test   rax,rax
     16f:	jne    181 <botlish_fn_2+0x37>
     175:	xor    rax,rax
     178:	add    rsp,0x10
     17c:	mov    rsp,rbp
     17f:	pop    rbp
     180:	ret
     181:	add    rsp,0x10
     185:	mov    rsp,rbp
     188:	pop    rbp
     189:	ret

000000000000018a <botlish_entry_2: geo_new<List[str]>>:
     18a:	push   rbp
     18b:	mov    rbp,rsp
     18e:	mov    rsi,QWORD PTR [rdx]
     191:	call   196 <botlish_entry_2+0xc>
			192: R_X86_64_PLT32	botlish_fn_2-0x4 ; geo_new<List[str]>
     196:	mov    rsp,rbp
     199:	pop    rbp
     19a:	ret
     19b:	add    BYTE PTR [rax],al
     19d:	add    BYTE PTR [rax],al
	...

00000000000001a0 <botlish_fn_3: geo_new_capacity<int, int>>:
     1a0:	push   rbp
     1a1:	mov    rbp,rsp
     1a4:	sub    rsp,0x40
     1a8:	mov    QWORD PTR [rsp+0x20],rbx
     1ad:	mov    QWORD PTR [rsp+0x28],r12
     1b2:	mov    QWORD PTR [rsp+0x30],r13
     1b7:	mov    r12,rdi
     1ba:	mov    QWORD PTR [rsp],rsi
     1be:	mov    QWORD PTR [rsp+0x8],rdx
     1c3:	mov    rbx,rdx
     1c6:	mov    QWORD PTR [rsp+0x10],0x5
     1cf:	test   rsi,0x1
     1d6:	je     1f8 <botlish_fn_3+0x58>
     1dc:	mov    rax,rsi
     1df:	sar    rax,1
     1e2:	imul   QWORD PTR [rip+0xdf]        # 2c8 <botlish_fn_3+0x128>
     1e9:	seto   cl
     1ec:	or     rax,0x1
     1f0:	test   cl,cl
     1f2:	je     205 <botlish_fn_3+0x65>
     1f8:	mov    edx,0x5
     1fd:	mov    rdi,r12
     200:	call   205 <botlish_fn_3+0x65>
			201: R_X86_64_PLT32	rt_int_mul-0x4
     205:	mov    rcx,rax
     208:	and    rcx,rbx
     20b:	mov    r13,rax
     20e:	test   rcx,0x1
     215:	jne    241 <botlish_fn_3+0xa1>
     21b:	mov    rdx,rbx
     21e:	mov    rsi,r13
     221:	mov    rdi,r12
     224:	call   229 <botlish_fn_3+0x89>
			225: R_X86_64_PLT32	rt_int_cmp-0x4
     229:	mov    ecx,0x2
     22e:	test   rax,rax
     231:	cmovle rcx,QWORD PTR [rip+0x97]        # 2d0 <botlish_fn_3+0x130>
     239:	mov    rax,r13
     23c:	jmp    254 <botlish_fn_3+0xb4>
     241:	mov    ecx,0x2
     246:	mov    rax,r13
     249:	cmp    rax,rbx
     24c:	cmovle rcx,QWORD PTR [rip+0x7c]        # 2d0 <botlish_fn_3+0x130>
     254:	cmp    rcx,0x6
     258:	je     276 <botlish_fn_3+0xd6>
     25e:	mov    rbx,QWORD PTR [rsp+0x20]
     263:	mov    r12,QWORD PTR [rsp+0x28]
     268:	mov    r13,QWORD PTR [rsp+0x30]
     26d:	add    rsp,0x40
     271:	mov    rsp,rbp
     274:	pop    rbp
     275:	ret
     276:	mov    QWORD PTR [rsp],0x3
     27e:	test   rbx,0x1
     285:	je     29d <botlish_fn_3+0xfd>
     28b:	mov    rax,rbx
     28e:	add    rax,0x2
     292:	seto   cl
     295:	test   cl,cl
     297:	je     2ad <botlish_fn_3+0x10d>
     29d:	mov    edx,0x3
     2a2:	mov    rsi,rbx
     2a5:	mov    rdi,r12
     2a8:	call   2ad <botlish_fn_3+0x10d>
			2a9: R_X86_64_PLT32	rt_int_add-0x4
     2ad:	mov    rbx,QWORD PTR [rsp+0x20]
     2b2:	mov    r12,QWORD PTR [rsp+0x28]
     2b7:	mov    r13,QWORD PTR [rsp+0x30]
     2bc:	add    rsp,0x40
     2c0:	mov    rsp,rbp
     2c3:	pop    rbp
     2c4:	ret
     2c5:	add    BYTE PTR [rax],al
     2c7:	add    BYTE PTR [rax+rax*1],al
     2ca:	add    BYTE PTR [rax],al
     2cc:	add    BYTE PTR [rax],al
     2ce:	add    BYTE PTR [rax],al
     2d0:	(bad)
     2d1:	add    BYTE PTR [rax],al
     2d3:	add    BYTE PTR [rax],al
     2d5:	add    BYTE PTR [rax],al
	...

00000000000002d8 <botlish_entry_3: geo_new_capacity<int, int>>:
     2d8:	push   rbp
     2d9:	mov    rbp,rsp
     2dc:	mov    rsi,QWORD PTR [rdx]
     2df:	mov    rdx,QWORD PTR [rdx+0x8]
     2e3:	call   2e8 <botlish_entry_3+0x10>
			2e4: R_X86_64_PLT32	botlish_fn_3-0x4 ; geo_new_capacity<int, int>
     2e8:	mov    rsp,rbp
     2eb:	pop    rbp
     2ec:	ret
     2ed:	add    BYTE PTR [rax],al
	...

00000000000002f0 <botlish_fn_4: geo_grow<mutarray, int, str>>:
     2f0:	push   rbp
     2f1:	mov    rbp,rsp
     2f4:	sub    rsp,0x50
     2f8:	mov    QWORD PTR [rsp+0x20],rbx
     2fd:	mov    QWORD PTR [rsp+0x28],r12
     302:	mov    QWORD PTR [rsp+0x30],r13
     307:	mov    QWORD PTR [rsp+0x38],r14
     30c:	mov    QWORD PTR [rsp+0x40],r15
     311:	mov    r13,rdi
     314:	mov    QWORD PTR [rsp],rsi
     318:	mov    r12,rsi
     31b:	mov    QWORD PTR [rsp+0x8],rdx
     320:	mov    rbx,rdx
     323:	mov    QWORD PTR [rsp+0x10],rcx
     328:	mov    r14,rcx
     32b:	mov    rsi,r12
     32e:	mov    rdi,r13
     331:	call   336 <botlish_fn_4+0x46>
			332: R_X86_64_PLT32	rt_mutarray_capacity-0x4
     336:	mov    r15,rax
     339:	mov    QWORD PTR [rsp+0x18],rax
     33e:	mov    rcx,rbx
     341:	and    rcx,rax
     344:	test   rcx,0x1
     34b:	jne    377 <botlish_fn_4+0x87>
     351:	mov    rdx,r15
     354:	mov    rsi,rbx
     357:	mov    rdi,r13
     35a:	call   35f <botlish_fn_4+0x6f>
			35b: R_X86_64_PLT32	rt_int_cmp-0x4
     35f:	mov    ecx,0x2
     364:	test   rax,rax
     367:	cmovl  rcx,QWORD PTR [rip+0xe9]        # 458 <botlish_fn_4+0x168>
     36f:	mov    rax,r15
     372:	jmp    38a <botlish_fn_4+0x9a>
     377:	mov    ecx,0x2
     37c:	mov    rax,r15
     37f:	cmp    rbx,rax
     382:	cmovl  rcx,QWORD PTR [rip+0xce]        # 458 <botlish_fn_4+0x168>
     38a:	cmp    rcx,0x6
     38e:	je     42e <botlish_fn_4+0x13e>
     394:	mov    rsi,rax
     397:	mov    rdx,rbx
     39a:	mov    rdi,r13
     39d:	call   3a2 <botlish_fn_4+0xb2>
			39e: R_X86_64_PLT32	botlish_fn_3-0x4 ; geo_new_capacity<int, int>
     3a2:	mov    QWORD PTR [rsp+0x18],rax
     3a7:	mov    rdx,r14
     3aa:	mov    rsi,rax
     3ad:	mov    rdi,r13
     3b0:	call   3b5 <botlish_fn_4+0xc5>
			3b1: R_X86_64_PLT32	rt_mutarray_create-0x4
     3b5:	test   rax,rax
     3b8:	mov    r14,rax
     3bb:	je     3e4 <botlish_fn_4+0xf4>
     3c1:	mov    r8d,0x1
     3c7:	mov    rcx,r12
     3ca:	mov    rdi,r13
     3cd:	mov    r9,rbx
     3d0:	mov    rsi,r14
     3d3:	mov    rdx,r8
     3d6:	call   3db <botlish_fn_4+0xeb>
			3d7: R_X86_64_PLT32	rt_mutarray_copy-0x4
     3db:	test   rax,rax
     3de:	jne    409 <botlish_fn_4+0x119>
     3e4:	xor    rax,rax
     3e7:	mov    rbx,QWORD PTR [rsp+0x20]
     3ec:	mov    r12,QWORD PTR [rsp+0x28]
     3f1:	mov    r13,QWORD PTR [rsp+0x30]
     3f6:	mov    r14,QWORD PTR [rsp+0x38]
     3fb:	mov    r15,QWORD PTR [rsp+0x40]
     400:	add    rsp,0x50
     404:	mov    rsp,rbp
     407:	pop    rbp
     408:	ret
     409:	mov    rax,r14
     40c:	mov    rbx,QWORD PTR [rsp+0x20]
     411:	mov    r12,QWORD PTR [rsp+0x28]
     416:	mov    r13,QWORD PTR [rsp+0x30]
     41b:	mov    r14,QWORD PTR [rsp+0x38]
     420:	mov    r15,QWORD PTR [rsp+0x40]
     425:	add    rsp,0x50
     429:	mov    rsp,rbp
     42c:	pop    rbp
     42d:	ret
     42e:	mov    rax,r12
     431:	mov    rbx,QWORD PTR [rsp+0x20]
     436:	mov    r12,QWORD PTR [rsp+0x28]
     43b:	mov    r13,QWORD PTR [rsp+0x30]
     440:	mov    r14,QWORD PTR [rsp+0x38]
     445:	mov    r15,QWORD PTR [rsp+0x40]
     44a:	add    rsp,0x50
     44e:	mov    rsp,rbp
     451:	pop    rbp
     452:	ret
     453:	add    BYTE PTR [rax],al
     455:	add    BYTE PTR [rax],al
     457:	add    BYTE PTR [rsi],al
     459:	add    BYTE PTR [rax],al
     45b:	add    BYTE PTR [rax],al
     45d:	add    BYTE PTR [rax],al
	...

0000000000000460 <botlish_entry_4: geo_grow<mutarray, int, str>>:
     460:	push   rbp
     461:	mov    rbp,rsp
     464:	mov    rsi,QWORD PTR [rdx]
     467:	mov    r8,QWORD PTR [rdx+0x8]
     46b:	mov    rcx,QWORD PTR [rdx+0x10]
     46f:	mov    rdx,r8
     472:	call   477 <botlish_entry_4+0x17>
			473: R_X86_64_PLT32	botlish_fn_4-0x4 ; geo_grow<mutarray, int, str>
     477:	mov    rsp,rbp
     47a:	pop    rbp
     47b:	ret
     47c:	add    BYTE PTR [rax],al
	...

0000000000000480 <botlish_fn_5: geo_grow<mutarray, int, List[str]>>:
     480:	push   rbp
     481:	mov    rbp,rsp
     484:	sub    rsp,0x50
     488:	mov    QWORD PTR [rsp+0x20],rbx
     48d:	mov    QWORD PTR [rsp+0x28],r12
     492:	mov    QWORD PTR [rsp+0x30],r13
     497:	mov    QWORD PTR [rsp+0x38],r14
     49c:	mov    QWORD PTR [rsp+0x40],r15
     4a1:	mov    r13,rdi
     4a4:	mov    QWORD PTR [rsp],rsi
     4a8:	mov    r12,rsi
     4ab:	mov    QWORD PTR [rsp+0x8],rdx
     4b0:	mov    rbx,rdx
     4b3:	mov    QWORD PTR [rsp+0x10],rcx
     4b8:	mov    r14,rcx
     4bb:	mov    rsi,r12
     4be:	mov    rdi,r13
     4c1:	call   4c6 <botlish_fn_5+0x46>
			4c2: R_X86_64_PLT32	rt_mutarray_capacity-0x4
     4c6:	mov    r15,rax
     4c9:	mov    QWORD PTR [rsp+0x18],rax
     4ce:	mov    rcx,rbx
     4d1:	and    rcx,rax
     4d4:	test   rcx,0x1
     4db:	jne    507 <botlish_fn_5+0x87>
     4e1:	mov    rdx,r15
     4e4:	mov    rsi,rbx
     4e7:	mov    rdi,r13
     4ea:	call   4ef <botlish_fn_5+0x6f>
			4eb: R_X86_64_PLT32	rt_int_cmp-0x4
     4ef:	mov    ecx,0x2
     4f4:	test   rax,rax
     4f7:	cmovl  rcx,QWORD PTR [rip+0xe9]        # 5e8 <botlish_fn_5+0x168>
     4ff:	mov    rax,r15
     502:	jmp    51a <botlish_fn_5+0x9a>
     507:	mov    ecx,0x2
     50c:	mov    rax,r15
     50f:	cmp    rbx,rax
     512:	cmovl  rcx,QWORD PTR [rip+0xce]        # 5e8 <botlish_fn_5+0x168>
     51a:	cmp    rcx,0x6
     51e:	je     5be <botlish_fn_5+0x13e>
     524:	mov    rsi,rax
     527:	mov    rdx,rbx
     52a:	mov    rdi,r13
     52d:	call   532 <botlish_fn_5+0xb2>
			52e: R_X86_64_PLT32	botlish_fn_3-0x4 ; geo_new_capacity<int, int>
     532:	mov    QWORD PTR [rsp+0x18],rax
     537:	mov    rdx,r14
     53a:	mov    rsi,rax
     53d:	mov    rdi,r13
     540:	call   545 <botlish_fn_5+0xc5>
			541: R_X86_64_PLT32	rt_mutarray_create-0x4
     545:	test   rax,rax
     548:	mov    r14,rax
     54b:	je     574 <botlish_fn_5+0xf4>
     551:	mov    r8d,0x1
     557:	mov    rcx,r12
     55a:	mov    rdi,r13
     55d:	mov    r9,rbx
     560:	mov    rsi,r14
     563:	mov    rdx,r8
     566:	call   56b <botlish_fn_5+0xeb>
			567: R_X86_64_PLT32	rt_mutarray_copy-0x4
     56b:	test   rax,rax
     56e:	jne    599 <botlish_fn_5+0x119>
     574:	xor    rax,rax
     577:	mov    rbx,QWORD PTR [rsp+0x20]
     57c:	mov    r12,QWORD PTR [rsp+0x28]
     581:	mov    r13,QWORD PTR [rsp+0x30]
     586:	mov    r14,QWORD PTR [rsp+0x38]
     58b:	mov    r15,QWORD PTR [rsp+0x40]
     590:	add    rsp,0x50
     594:	mov    rsp,rbp
     597:	pop    rbp
     598:	ret
     599:	mov    rax,r14
     59c:	mov    rbx,QWORD PTR [rsp+0x20]
     5a1:	mov    r12,QWORD PTR [rsp+0x28]
     5a6:	mov    r13,QWORD PTR [rsp+0x30]
     5ab:	mov    r14,QWORD PTR [rsp+0x38]
     5b0:	mov    r15,QWORD PTR [rsp+0x40]
     5b5:	add    rsp,0x50
     5b9:	mov    rsp,rbp
     5bc:	pop    rbp
     5bd:	ret
     5be:	mov    rax,r12
     5c1:	mov    rbx,QWORD PTR [rsp+0x20]
     5c6:	mov    r12,QWORD PTR [rsp+0x28]
     5cb:	mov    r13,QWORD PTR [rsp+0x30]
     5d0:	mov    r14,QWORD PTR [rsp+0x38]
     5d5:	mov    r15,QWORD PTR [rsp+0x40]
     5da:	add    rsp,0x50
     5de:	mov    rsp,rbp
     5e1:	pop    rbp
     5e2:	ret
     5e3:	add    BYTE PTR [rax],al
     5e5:	add    BYTE PTR [rax],al
     5e7:	add    BYTE PTR [rsi],al
     5e9:	add    BYTE PTR [rax],al
     5eb:	add    BYTE PTR [rax],al
     5ed:	add    BYTE PTR [rax],al
	...

00000000000005f0 <botlish_entry_5: geo_grow<mutarray, int, List[str]>>:
     5f0:	push   rbp
     5f1:	mov    rbp,rsp
     5f4:	mov    rsi,QWORD PTR [rdx]
     5f7:	mov    r8,QWORD PTR [rdx+0x8]
     5fb:	mov    rcx,QWORD PTR [rdx+0x10]
     5ff:	mov    rdx,r8
     602:	call   607 <botlish_entry_5+0x17>
			603: R_X86_64_PLT32	botlish_fn_5-0x4 ; geo_grow<mutarray, int, List[str]>
     607:	mov    rsp,rbp
     60a:	pop    rbp
     60b:	ret

000000000000060c <botlish_fn_6: geo_append<mutarray, int, str>>:
     60c:	push   rbp
     60d:	mov    rbp,rsp
     610:	sub    rsp,0x40
     614:	mov    QWORD PTR [rsp+0x20],rbx
     619:	mov    QWORD PTR [rsp+0x28],r12
     61e:	mov    QWORD PTR [rsp+0x30],r13
     623:	mov    QWORD PTR [rsp+0x38],r14
     628:	mov    r14,rdi
     62b:	mov    QWORD PTR [rsp],rsi
     62f:	mov    QWORD PTR [rsp+0x8],rdx
     634:	mov    r13,rdx
     637:	mov    QWORD PTR [rsp+0x10],rcx
     63c:	mov    r12,rcx
     63f:	mov    rcx,r12
     642:	mov    rdx,r13
     645:	mov    rdi,r14
     648:	call   64d <botlish_fn_6+0x41>
			649: R_X86_64_PLT32	botlish_fn_4-0x4 ; geo_grow<mutarray, int, str>
     64d:	test   rax,rax
     650:	mov    rbx,rax
     653:	je     673 <botlish_fn_6+0x67>
     659:	mov    rcx,r12
     65c:	mov    rdx,r13
     65f:	mov    rdi,r14
     662:	mov    rsi,rbx
     665:	call   66a <botlish_fn_6+0x5e>
			666: R_X86_64_PLT32	rt_mutarray_set-0x4
     66a:	test   rax,rax
     66d:	jne    693 <botlish_fn_6+0x87>
     673:	xor    rax,rax
     676:	mov    rbx,QWORD PTR [rsp+0x20]
     67b:	mov    r12,QWORD PTR [rsp+0x28]
     680:	mov    r13,QWORD PTR [rsp+0x30]
     685:	mov    r14,QWORD PTR [rsp+0x38]
     68a:	add    rsp,0x40
     68e:	mov    rsp,rbp
     691:	pop    rbp
     692:	ret
     693:	mov    rax,rbx
     696:	mov    rbx,QWORD PTR [rsp+0x20]
     69b:	mov    r12,QWORD PTR [rsp+0x28]
     6a0:	mov    r13,QWORD PTR [rsp+0x30]
     6a5:	mov    r14,QWORD PTR [rsp+0x38]
     6aa:	add    rsp,0x40
     6ae:	mov    rsp,rbp
     6b1:	pop    rbp
     6b2:	ret

00000000000006b3 <botlish_entry_6: geo_append<mutarray, int, str>>:
     6b3:	push   rbp
     6b4:	mov    rbp,rsp
     6b7:	mov    rsi,QWORD PTR [rdx]
     6ba:	mov    r8,QWORD PTR [rdx+0x8]
     6be:	mov    rcx,QWORD PTR [rdx+0x10]
     6c2:	mov    rdx,r8
     6c5:	call   6ca <botlish_entry_6+0x17>
			6c6: R_X86_64_PLT32	botlish_fn_6-0x4 ; geo_append<mutarray, int, str>
     6ca:	mov    rsp,rbp
     6cd:	pop    rbp
     6ce:	ret

00000000000006cf <botlish_fn_7: geo_append<mutarray, int, List[str]>>:
     6cf:	push   rbp
     6d0:	mov    rbp,rsp
     6d3:	sub    rsp,0x40
     6d7:	mov    QWORD PTR [rsp+0x20],rbx
     6dc:	mov    QWORD PTR [rsp+0x28],r12
     6e1:	mov    QWORD PTR [rsp+0x30],r13
     6e6:	mov    QWORD PTR [rsp+0x38],r14
     6eb:	mov    r14,rdi
     6ee:	mov    QWORD PTR [rsp],rsi
     6f2:	mov    QWORD PTR [rsp+0x8],rdx
     6f7:	mov    r13,rdx
     6fa:	mov    QWORD PTR [rsp+0x10],rcx
     6ff:	mov    r12,rcx
     702:	mov    rcx,r12
     705:	mov    rdx,r13
     708:	mov    rdi,r14
     70b:	call   710 <botlish_fn_7+0x41>
			70c: R_X86_64_PLT32	botlish_fn_5-0x4 ; geo_grow<mutarray, int, List[str]>
     710:	test   rax,rax
     713:	mov    rbx,rax
     716:	je     736 <botlish_fn_7+0x67>
     71c:	mov    rcx,r12
     71f:	mov    rdx,r13
     722:	mov    rdi,r14
     725:	mov    rsi,rbx
     728:	call   72d <botlish_fn_7+0x5e>
			729: R_X86_64_PLT32	rt_mutarray_set-0x4
     72d:	test   rax,rax
     730:	jne    756 <botlish_fn_7+0x87>
     736:	xor    rax,rax
     739:	mov    rbx,QWORD PTR [rsp+0x20]
     73e:	mov    r12,QWORD PTR [rsp+0x28]
     743:	mov    r13,QWORD PTR [rsp+0x30]
     748:	mov    r14,QWORD PTR [rsp+0x38]
     74d:	add    rsp,0x40
     751:	mov    rsp,rbp
     754:	pop    rbp
     755:	ret
     756:	mov    rax,rbx
     759:	mov    rbx,QWORD PTR [rsp+0x20]
     75e:	mov    r12,QWORD PTR [rsp+0x28]
     763:	mov    r13,QWORD PTR [rsp+0x30]
     768:	mov    r14,QWORD PTR [rsp+0x38]
     76d:	add    rsp,0x40
     771:	mov    rsp,rbp
     774:	pop    rbp
     775:	ret

0000000000000776 <botlish_entry_7: geo_append<mutarray, int, List[str]>>:
     776:	push   rbp
     777:	mov    rbp,rsp
     77a:	mov    rsi,QWORD PTR [rdx]
     77d:	mov    r8,QWORD PTR [rdx+0x8]
     781:	mov    rcx,QWORD PTR [rdx+0x10]
     785:	mov    rdx,r8
     788:	call   78d <botlish_entry_7+0x17>
			789: R_X86_64_PLT32	botlish_fn_7-0x4 ; geo_append<mutarray, int, List[str]>
     78d:	mov    rsp,rbp
     790:	pop    rbp
     791:	ret

0000000000000792 <botlish_fn_8: geo_finish<mutarray, int>>:
     792:	push   rbp
     793:	mov    rbp,rsp
     796:	sub    rsp,0x10
     79a:	mov    QWORD PTR [rsp],rsi
     79e:	mov    QWORD PTR [rsp+0x8],rdx
     7a3:	call   7a8 <botlish_fn_8+0x16>
			7a4: R_X86_64_PLT32	rt_mutarray_freeze-0x4
     7a8:	test   rax,rax
     7ab:	jne    7bd <botlish_fn_8+0x2b>
     7b1:	xor    rax,rax
     7b4:	add    rsp,0x10
     7b8:	mov    rsp,rbp
     7bb:	pop    rbp
     7bc:	ret
     7bd:	add    rsp,0x10
     7c1:	mov    rsp,rbp
     7c4:	pop    rbp
     7c5:	ret

00000000000007c6 <botlish_entry_8: geo_finish<mutarray, int>>:
     7c6:	push   rbp
     7c7:	mov    rbp,rsp
     7ca:	mov    rsi,QWORD PTR [rdx]
     7cd:	mov    rdx,QWORD PTR [rdx+0x8]
     7d1:	call   7d6 <botlish_entry_8+0x10>
			7d2: R_X86_64_PLT32	botlish_fn_8-0x4 ; geo_finish<mutarray, int>
     7d6:	mov    rsp,rbp
     7d9:	pop    rbp
     7da:	ret
     7db:	add    BYTE PTR [rax],al
     7dd:	add    BYTE PTR [rax],al
	...

00000000000007e0 <botlish_fn_9: peek<str, int>>:
     7e0:	push   rbp
     7e1:	mov    rbp,rsp
     7e4:	sub    rsp,0x40
     7e8:	mov    QWORD PTR [rsp+0x20],rbx
     7ed:	mov    QWORD PTR [rsp+0x28],r12
     7f2:	mov    QWORD PTR [rsp+0x30],r13
     7f7:	mov    rbx,rdx
     7fa:	mov    r13,rdi
     7fd:	mov    QWORD PTR [rsp],rsi
     801:	mov    QWORD PTR [rsp+0x8],rdx
     806:	mov    rdx,QWORD PTR [rsi+0x8]
     80a:	mov    r12,rsi
     80d:	shl    rdx,1
     810:	mov    rax,rdx
     813:	or     rax,0x1
     817:	mov    rcx,rbx
     81a:	and    rcx,rax
     81d:	test   rcx,0x1
     824:	jne    84e <botlish_fn_9+0x6e>
     82a:	or     rdx,0x1
     82e:	mov    rsi,rbx
     831:	mov    rdi,r13
     834:	call   839 <botlish_fn_9+0x59>
			835: R_X86_64_PLT32	rt_int_cmp-0x4
     839:	mov    ecx,0x2
     83e:	test   rax,rax
     841:	cmovge rcx,QWORD PTR [rip+0xd7]        # 920 <botlish_fn_9+0x140>
     849:	jmp    862 <botlish_fn_9+0x82>
     84e:	or     rdx,0x1
     852:	mov    ecx,0x2
     857:	cmp    rbx,rdx
     85a:	cmovge rcx,QWORD PTR [rip+0xbe]        # 920 <botlish_fn_9+0x140>
     862:	cmp    rcx,0x6
     866:	je     8f6 <botlish_fn_9+0x116>
     86c:	mov    QWORD PTR [rsp+0x10],0x3
     875:	test   rbx,0x1
     87c:	je     894 <botlish_fn_9+0xb4>
     882:	mov    rcx,rbx
     885:	add    rcx,0x2
     889:	seto   al
     88c:	test   al,al
     88e:	je     8a7 <botlish_fn_9+0xc7>
     894:	mov    edx,0x3
     899:	mov    rsi,rbx
     89c:	mov    rdi,r13
     89f:	call   8a4 <botlish_fn_9+0xc4>
			8a0: R_X86_64_PLT32	rt_int_add-0x4
     8a4:	mov    rcx,rax
     8a7:	mov    QWORD PTR [rsp+0x10],rcx
     8ac:	mov    rdx,rbx
     8af:	mov    rsi,r12
     8b2:	mov    rdi,r13
     8b5:	call   8ba <botlish_fn_9+0xda>
			8b6: R_X86_64_PLT32	rt_substr-0x4
     8ba:	test   rax,rax
     8bd:	jne    8de <botlish_fn_9+0xfe>
     8c3:	xor    rax,rax
     8c6:	mov    rbx,QWORD PTR [rsp+0x20]
     8cb:	mov    r12,QWORD PTR [rsp+0x28]
     8d0:	mov    r13,QWORD PTR [rsp+0x30]
     8d5:	add    rsp,0x40
     8d9:	mov    rsp,rbp
     8dc:	pop    rbp
     8dd:	ret
     8de:	mov    rbx,QWORD PTR [rsp+0x20]
     8e3:	mov    r12,QWORD PTR [rsp+0x28]
     8e8:	mov    r13,QWORD PTR [rsp+0x30]
     8ed:	add    rsp,0x40
     8f1:	mov    rsp,rbp
     8f4:	pop    rbp
     8f5:	ret
     8f6:	mov    rdi,r13
     8f9:	mov    rax,QWORD PTR [rdi+0x10]
     8fd:	mov    rax,QWORD PTR [rax+0x8]
     901:	mov    rbx,QWORD PTR [rsp+0x20]
     906:	mov    r12,QWORD PTR [rsp+0x28]
     90b:	mov    r13,QWORD PTR [rsp+0x30]
     910:	add    rsp,0x40
     914:	mov    rsp,rbp
     917:	pop    rbp
     918:	ret
     919:	add    BYTE PTR [rax],al
     91b:	add    BYTE PTR [rax],al
     91d:	add    BYTE PTR [rax],al
     91f:	add    BYTE PTR [rsi],al
     921:	add    BYTE PTR [rax],al
     923:	add    BYTE PTR [rax],al
     925:	add    BYTE PTR [rax],al
	...

0000000000000928 <botlish_entry_9: peek<str, int>>:
     928:	push   rbp
     929:	mov    rbp,rsp
     92c:	mov    rsi,QWORD PTR [rdx]
     92f:	mov    rdx,QWORD PTR [rdx+0x8]
     933:	call   938 <botlish_entry_9+0x10>
			934: R_X86_64_PLT32	botlish_fn_9-0x4 ; peek<str, int>
     938:	mov    rsp,rbp
     93b:	pop    rbp
     93c:	ret
     93d:	add    BYTE PTR [rax],al
	...

0000000000000940 <botlish_fn_10: quote_at?<str, int>>:
     940:	push   rbp
     941:	mov    rbp,rsp
     944:	sub    rsp,0x20
     948:	mov    QWORD PTR [rsp],rbx
     94c:	mov    QWORD PTR [rsp+0x8],r12
     951:	mov    QWORD PTR [rsp+0x10],r13
     956:	mov    rbx,rdx
     959:	mov    r13,rdi
     95c:	mov    rdx,QWORD PTR [rsi+0x8]
     960:	mov    r12,rsi
     963:	shl    rdx,1
     966:	mov    rax,rdx
     969:	or     rax,0x1
     96d:	mov    rcx,rbx
     970:	and    rcx,rax
     973:	test   rcx,0x1
     97a:	jne    9a4 <botlish_fn_10+0x64>
     980:	or     rdx,0x1
     984:	mov    rsi,rbx
     987:	mov    rdi,r13
     98a:	call   98f <botlish_fn_10+0x4f>
			98b: R_X86_64_PLT32	rt_int_cmp-0x4
     98f:	mov    ecx,0x2
     994:	test   rax,rax
     997:	cmovl  rcx,QWORD PTR [rip+0xa1]        # a40 <botlish_fn_10+0x100>
     99f:	jmp    9bb <botlish_fn_10+0x7b>
     9a4:	or     rdx,0x1
     9a8:	mov    ecx,0x2
     9ad:	mov    rax,rbx
     9b0:	cmp    rax,rdx
     9b3:	cmovl  rcx,QWORD PTR [rip+0x85]        # a40 <botlish_fn_10+0x100>
     9bb:	mov    eax,0x6
     9c0:	cmp    rcx,0x6
     9c4:	je     9d7 <botlish_fn_10+0x97>
     9ca:	mov    eax,0x2
     9cf:	mov    r12,rax
     9d2:	jmp    a24 <botlish_fn_10+0xe4>
     9d7:	mov    rdi,r13
     9da:	mov    rsi,r12
     9dd:	mov    r12,rax
     9e0:	mov    rdx,rbx
     9e3:	call   9e8 <botlish_fn_10+0xa8>
			9e4: R_X86_64_PLT32	rt_str_char_at-0x4
     9e8:	test   rax,rax
     9eb:	jne    a0b <botlish_fn_10+0xcb>
     9f1:	xor    rax,rax
     9f4:	mov    rbx,QWORD PTR [rsp]
     9f8:	mov    r12,QWORD PTR [rsp+0x8]
     9fd:	mov    r13,QWORD PTR [rsp+0x10]
     a02:	add    rsp,0x20
     a06:	mov    rsp,rbp
     a09:	pop    rbp
     a0a:	ret
     a0b:	cmp    rax,0x114
     a11:	je     a21 <botlish_fn_10+0xe1>
     a17:	mov    eax,0x2
     a1c:	jmp    a24 <botlish_fn_10+0xe4>
     a21:	mov    rax,r12
     a24:	mov    rbx,QWORD PTR [rsp]
     a28:	mov    r12,QWORD PTR [rsp+0x8]
     a2d:	mov    r13,QWORD PTR [rsp+0x10]
     a32:	add    rsp,0x20
     a36:	mov    rsp,rbp
     a39:	pop    rbp
     a3a:	ret
     a3b:	add    BYTE PTR [rax],al
     a3d:	add    BYTE PTR [rax],al
     a3f:	add    BYTE PTR [rsi],al
     a41:	add    BYTE PTR [rax],al
     a43:	add    BYTE PTR [rax],al
     a45:	add    BYTE PTR [rax],al
	...

0000000000000a48 <botlish_entry_10: quote_at?<str, int>>:
     a48:	push   rbp
     a49:	mov    rbp,rsp
     a4c:	mov    rsi,QWORD PTR [rdx]
     a4f:	mov    rdx,QWORD PTR [rdx+0x8]
     a53:	call   a58 <botlish_entry_10+0x10>
			a54: R_X86_64_PLT32	botlish_fn_10-0x4 ; quote_at?<str, int>
     a58:	mov    rsp,rbp
     a5b:	pop    rbp
     a5c:	ret
     a5d:	add    BYTE PTR [rax],al
	...

0000000000000a60 <botlish_fn_11: scan_unquoted<str, int, int>>:
     a60:	push   rbp
     a61:	mov    rbp,rsp
     a64:	sub    rsp,0x40
     a68:	mov    QWORD PTR [rsp+0x20],rbx
     a6d:	mov    QWORD PTR [rsp+0x28],r12
     a72:	mov    QWORD PTR [rsp+0x30],r13
     a77:	mov    QWORD PTR [rsp+0x38],r14
     a7c:	mov    r13,rdi
     a7f:	mov    QWORD PTR [rsp+0x18],0x0
     a88:	mov    QWORD PTR [rsp],rsi
     a8c:	mov    r12,rsi
     a8f:	mov    QWORD PTR [rsp+0x8],rdx
     a94:	mov    rbx,rdx
     a97:	mov    QWORD PTR [rsp+0x10],rcx
     a9c:	mov    rax,r12
     a9f:	mov    rsi,rcx
     aa2:	mov    rdx,QWORD PTR [rax+0x8]
     aa6:	mov    r12,rax
     aa9:	shl    rdx,1
     aac:	or     rdx,0x1
     ab0:	mov    rax,rsi
     ab3:	and    rax,rdx
     ab6:	mov    r14,rsi
     ab9:	test   rax,0x1
     abf:	jne    ae5 <botlish_fn_11+0x85>
     ac5:	mov    rsi,r14
     ac8:	mov    rdi,r13
     acb:	call   ad0 <botlish_fn_11+0x70>
			acc: R_X86_64_PLT32	rt_int_cmp-0x4
     ad0:	mov    ecx,0x2
     ad5:	test   rax,rax
     ad8:	cmovl  rcx,QWORD PTR [rip+0x138]        # c18 <botlish_fn_11+0x1b8>
     ae0:	jmp    af8 <botlish_fn_11+0x98>
     ae5:	mov    ecx,0x2
     aea:	mov    rsi,r14
     aed:	cmp    rsi,rdx
     af0:	cmovl  rcx,QWORD PTR [rip+0x120]        # c18 <botlish_fn_11+0x1b8>
     af8:	cmp    rcx,0x6
     afc:	je     b10 <botlish_fn_11+0xb0>
     b02:	mov    rdx,rbx
     b05:	mov    rsi,r12
     b08:	mov    rdi,r13
     b0b:	jmp    bbb <botlish_fn_11+0x15b>
     b10:	mov    rdx,r14
     b13:	mov    rsi,r12
     b16:	mov    rdi,r13
     b19:	call   b1e <botlish_fn_11+0xbe>
			b1a: R_X86_64_PLT32	rt_str_char_at-0x4
     b1e:	test   rax,rax
     b21:	je     bd2 <botlish_fn_11+0x172>
     b27:	cmp    rax,0x164
     b2d:	jne    b3b <botlish_fn_11+0xdb>
     b33:	mov    rdx,rbx
     b36:	jmp    bb5 <botlish_fn_11+0x155>
     b3b:	cmp    rax,0x54
     b3f:	jne    b4d <botlish_fn_11+0xed>
     b45:	mov    rdx,rbx
     b48:	jmp    bb5 <botlish_fn_11+0x155>
     b4d:	mov    QWORD PTR [rsp+0x18],0x3
     b56:	mov    rsi,r14
     b59:	test   rsi,0x1
     b60:	je     b83 <botlish_fn_11+0x123>
     b66:	mov    rsi,r14
     b69:	mov    rax,rsi
     b6c:	add    rax,0x2
     b70:	seto   cl
     b73:	test   cl,cl
     b75:	jne    b83 <botlish_fn_11+0x123>
     b7b:	mov    rsi,r12
     b7e:	jmp    b96 <botlish_fn_11+0x136>
     b83:	mov    edx,0x3
     b88:	mov    rsi,r14
     b8b:	mov    rdi,r13
     b8e:	call   b93 <botlish_fn_11+0x133>
			b8f: R_X86_64_PLT32	rt_int_add-0x4
     b93:	mov    rsi,r12
     b96:	mov    rsi,r12
     b99:	mov    QWORD PTR [rsp],rsi
     b9d:	mov    rdx,rbx
     ba0:	mov    QWORD PTR [rsp+0x8],rdx
     ba5:	mov    QWORD PTR [rsp+0x10],rax
     baa:	mov    rsi,rax
     bad:	mov    rax,r12
     bb0:	jmp    aa2 <botlish_fn_11+0x42>
     bb5:	mov    rsi,r12
     bb8:	mov    rdi,r13
     bbb:	mov    rsi,r12
     bbe:	mov    rdi,r13
     bc1:	mov    rcx,r14
     bc4:	call   bc9 <botlish_fn_11+0x169>
			bc5: R_X86_64_PLT32	rt_substr-0x4
     bc9:	test   rax,rax
     bcc:	jne    bf5 <botlish_fn_11+0x195>
     bd2:	xor    rdx,rdx
     bd5:	mov    rax,rdx
     bd8:	mov    rbx,QWORD PTR [rsp+0x20]
     bdd:	mov    r12,QWORD PTR [rsp+0x28]
     be2:	mov    r13,QWORD PTR [rsp+0x30]
     be7:	mov    r14,QWORD PTR [rsp+0x38]
     bec:	add    rsp,0x40
     bf0:	mov    rsp,rbp
     bf3:	pop    rbp
     bf4:	ret
     bf5:	mov    rdx,r14
     bf8:	mov    rbx,QWORD PTR [rsp+0x20]
     bfd:	mov    r12,QWORD PTR [rsp+0x28]
     c02:	mov    r13,QWORD PTR [rsp+0x30]
     c07:	mov    r14,QWORD PTR [rsp+0x38]
     c0c:	add    rsp,0x40
     c10:	mov    rsp,rbp
     c13:	pop    rbp
     c14:	ret
     c15:	add    BYTE PTR [rax],al
     c17:	add    BYTE PTR [rsi],al
     c19:	add    BYTE PTR [rax],al
     c1b:	add    BYTE PTR [rax],al
     c1d:	add    BYTE PTR [rax],al
	...

0000000000000c20 <botlish_entry_11: scan_unquoted<str, int, int>>:
     c20:	push   rbp
     c21:	mov    rbp,rsp
     c24:	ud2

0000000000000c26 <botlish_fn_12: scan_quoted<str, int, str>>:
     c26:	push   rbp
     c27:	mov    rbp,rsp
     c2a:	sub    rsp,0xb0
     c31:	mov    QWORD PTR [rsp+0x80],rbx
     c39:	mov    QWORD PTR [rsp+0x88],r12
     c41:	mov    QWORD PTR [rsp+0x90],r13
     c49:	mov    QWORD PTR [rsp+0x98],r14
     c51:	mov    QWORD PTR [rsp+0xa0],r15
     c59:	mov    r15,rdi
     c5c:	mov    QWORD PTR [rsp+0x18],0x0
     c65:	mov    QWORD PTR [rsp+0x20],0x0
     c6e:	mov    QWORD PTR [rsp],rsi
     c72:	mov    QWORD PTR [rsp+0x8],rdx
     c77:	mov    QWORD PTR [rsp+0x10],rcx
     c7c:	mov    r13,rcx
     c7f:	lea    r12,[rsp+0x58]
     c84:	mov    rbx,rsi
     c87:	mov    QWORD PTR [rsp+0x78],rdx
     c8c:	mov    rdx,QWORD PTR [rsp+0x78]
     c91:	mov    rsi,rbx
     c94:	mov    rdi,r15
     c97:	call   c9c <botlish_fn_12+0x76>
			c98: R_X86_64_PLT32	botlish_fn_9-0x4 ; peek<str, int>
     c9c:	test   rax,rax
     c9f:	je     f3b <botlish_fn_12+0x315>
     ca5:	mov    QWORD PTR [rsp+0x18],rax
     caa:	mov    r14,rax
     cad:	mov    rdx,QWORD PTR [rsp+0x78]
     cb2:	mov    rsi,rbx
     cb5:	mov    rdi,r15
     cb8:	call   cbd <botlish_fn_12+0x97>
			cb9: R_X86_64_PLT32	botlish_fn_10-0x4 ; quote_at?<str, int>
     cbd:	test   rax,rax
     cc0:	je     f3b <botlish_fn_12+0x315>
     cc6:	cmp    rax,0x6
     cca:	je     d83 <botlish_fn_12+0x15d>
     cd0:	mov    QWORD PTR [rsp+0x20],0x3
     cd9:	mov    rsi,QWORD PTR [rsp+0x78]
     cde:	test   rsi,0x1
     ce5:	je     d0f <botlish_fn_12+0xe9>
     ceb:	mov    rsi,QWORD PTR [rsp+0x78]
     cf0:	mov    rcx,rsi
     cf3:	add    rcx,0x2
     cf7:	seto   dl
     cfa:	test   dl,dl
     cfc:	jne    d0f <botlish_fn_12+0xe9>
     d02:	mov    rsi,rcx
     d05:	mov    QWORD PTR [rsp+0x78],rcx
     d0a:	jmp    d29 <botlish_fn_12+0x103>
     d0f:	mov    edx,0x3
     d14:	mov    rsi,QWORD PTR [rsp+0x78]
     d19:	mov    rdi,r15
     d1c:	call   d21 <botlish_fn_12+0xfb>
			d1d: R_X86_64_PLT32	rt_int_add-0x4
     d21:	mov    rsi,rax
     d24:	mov    QWORD PTR [rsp+0x78],rax
     d29:	mov    QWORD PTR [rsp+0x8],rsi
     d2e:	mov    QWORD PTR [rsp+0x58],0x0
     d37:	mov    QWORD PTR [rsp+0x60],r13
     d3c:	mov    QWORD PTR [rsp+0x68],0x0
     d45:	mov    QWORD PTR [rsp+0x70],r14
     d4a:	mov    esi,0x2
     d4f:	mov    edx,0x4
     d54:	mov    rcx,r12
     d57:	mov    rdi,r15
     d5a:	call   d5f <botlish_fn_12+0x139>
			d5b: R_X86_64_PLT32	rt_construct-0x4
     d5f:	test   rax,rax
     d62:	je     f3b <botlish_fn_12+0x315>
     d68:	mov    QWORD PTR [rsp],rbx
     d6c:	mov    rsi,QWORD PTR [rsp+0x78]
     d71:	mov    QWORD PTR [rsp+0x8],rsi
     d76:	mov    QWORD PTR [rsp+0x10],rax
     d7b:	mov    r13,rax
     d7e:	jmp    c8c <botlish_fn_12+0x66>
     d83:	mov    QWORD PTR [rsp+0x20],0x3
     d8c:	mov    rsi,QWORD PTR [rsp+0x78]
     d91:	test   rsi,0x1
     d98:	je     db5 <botlish_fn_12+0x18f>
     d9e:	mov    rsi,QWORD PTR [rsp+0x78]
     da3:	mov    rdx,rsi
     da6:	add    rdx,0x2
     daa:	seto   al
     dad:	test   al,al
     daf:	je     dca <botlish_fn_12+0x1a4>
     db5:	mov    edx,0x3
     dba:	mov    rsi,QWORD PTR [rsp+0x78]
     dbf:	mov    rdi,r15
     dc2:	call   dc7 <botlish_fn_12+0x1a1>
			dc3: R_X86_64_PLT32	rt_int_add-0x4
     dc7:	mov    rdx,rax
     dca:	mov    rsi,rbx
     dcd:	mov    rdi,r15
     dd0:	call   dd5 <botlish_fn_12+0x1af>
			dd1: R_X86_64_PLT32	botlish_fn_10-0x4 ; quote_at?<str, int>
     dd5:	test   rax,rax
     dd8:	je     f3b <botlish_fn_12+0x315>
     dde:	cmp    rax,0x6
     de2:	je     ea1 <botlish_fn_12+0x27b>
     de8:	xor    rsi,rsi
     deb:	lea    rcx,[rsp+0x48]
     df0:	mov    QWORD PTR [rsp+0x48],0x0
     df9:	mov    QWORD PTR [rsp+0x50],r13
     dfe:	mov    edx,0x2
     e03:	mov    rdi,r15
     e06:	call   e0b <botlish_fn_12+0x1e5>
			e07: R_X86_64_PLT32	rt_construct-0x4
     e0b:	test   rax,rax
     e0e:	je     f3b <botlish_fn_12+0x315>
     e14:	mov    QWORD PTR [rsp],rax
     e18:	mov    r12,rax
     e1b:	mov    QWORD PTR [rsp+0x10],0x3
     e24:	mov    rsi,QWORD PTR [rsp+0x78]
     e29:	test   rsi,0x1
     e30:	je     e55 <botlish_fn_12+0x22f>
     e36:	mov    rsi,QWORD PTR [rsp+0x78]
     e3b:	mov    rdx,rsi
     e3e:	add    rdx,0x2
     e42:	seto   al
     e45:	test   al,al
     e47:	jne    e55 <botlish_fn_12+0x22f>
     e4d:	mov    rax,r12
     e50:	jmp    e6d <botlish_fn_12+0x247>
     e55:	mov    edx,0x3
     e5a:	mov    rsi,QWORD PTR [rsp+0x78]
     e5f:	mov    rdi,r15
     e62:	call   e67 <botlish_fn_12+0x241>
			e63: R_X86_64_PLT32	rt_int_add-0x4
     e67:	mov    rdx,rax
     e6a:	mov    rax,r12
     e6d:	mov    rbx,QWORD PTR [rsp+0x80]
     e75:	mov    r12,QWORD PTR [rsp+0x88]
     e7d:	mov    r13,QWORD PTR [rsp+0x90]
     e85:	mov    r14,QWORD PTR [rsp+0x98]
     e8d:	mov    r15,QWORD PTR [rsp+0xa0]
     e95:	add    rsp,0xb0
     e9c:	mov    rsp,rbp
     e9f:	pop    rbp
     ea0:	ret
     ea1:	mov    QWORD PTR [rsp+0x20],0x5
     eaa:	mov    rsi,QWORD PTR [rsp+0x78]
     eaf:	test   rsi,0x1
     eb6:	je     ee0 <botlish_fn_12+0x2ba>
     ebc:	mov    rsi,QWORD PTR [rsp+0x78]
     ec1:	mov    rcx,rsi
     ec4:	add    rcx,0x4
     ec8:	seto   al
     ecb:	test   al,al
     ecd:	jne    ee0 <botlish_fn_12+0x2ba>
     ed3:	mov    rsi,rcx
     ed6:	mov    QWORD PTR [rsp+0x78],rcx
     edb:	jmp    efa <botlish_fn_12+0x2d4>
     ee0:	mov    edx,0x5
     ee5:	mov    rsi,QWORD PTR [rsp+0x78]
     eea:	mov    rdi,r15
     eed:	call   ef2 <botlish_fn_12+0x2cc>
			eee: R_X86_64_PLT32	rt_int_add-0x4
     ef2:	mov    rsi,rax
     ef5:	mov    QWORD PTR [rsp+0x78],rax
     efa:	mov    QWORD PTR [rsp+0x8],rsi
     eff:	lea    rcx,[rsp+0x28]
     f04:	mov    QWORD PTR [rsp+0x28],0x0
     f0d:	mov    QWORD PTR [rsp+0x30],r13
     f12:	mov    QWORD PTR [rsp+0x38],0x0
     f1b:	mov    QWORD PTR [rsp+0x40],r14
     f20:	mov    esi,0x2
     f25:	mov    edx,0x4
     f2a:	mov    rdi,r15
     f2d:	call   f32 <botlish_fn_12+0x30c>
			f2e: R_X86_64_PLT32	rt_construct-0x4
     f32:	test   rax,rax
     f35:	jne    f75 <botlish_fn_12+0x34f>
     f3b:	xor    rdx,rdx
     f3e:	mov    rax,rdx
     f41:	mov    rbx,QWORD PTR [rsp+0x80]
     f49:	mov    r12,QWORD PTR [rsp+0x88]
     f51:	mov    r13,QWORD PTR [rsp+0x90]
     f59:	mov    r14,QWORD PTR [rsp+0x98]
     f61:	mov    r15,QWORD PTR [rsp+0xa0]
     f69:	add    rsp,0xb0
     f70:	mov    rsp,rbp
     f73:	pop    rbp
     f74:	ret
     f75:	mov    QWORD PTR [rsp],rbx
     f79:	mov    rsi,QWORD PTR [rsp+0x78]
     f7e:	mov    QWORD PTR [rsp+0x8],rsi
     f83:	mov    QWORD PTR [rsp+0x10],rax
     f88:	mov    r13,rax
     f8b:	jmp    c8c <botlish_fn_12+0x66>

0000000000000f90 <botlish_entry_12: scan_quoted<str, int, str>>:
     f90:	push   rbp
     f91:	mov    rbp,rsp
     f94:	ud2

0000000000000f96 <botlish_fn_13: scan_field<str, int>>:
     f96:	push   rbp
     f97:	mov    rbp,rsp
     f9a:	sub    rsp,0x40
     f9e:	mov    QWORD PTR [rsp+0x20],rbx
     fa3:	mov    QWORD PTR [rsp+0x28],r12
     fa8:	mov    QWORD PTR [rsp+0x30],r13
     fad:	mov    r12,rdi
     fb0:	mov    r13,rdx
     fb3:	mov    QWORD PTR [rsp+0x10],0x0
     fbc:	mov    QWORD PTR [rsp],rsi
     fc0:	mov    rbx,rsi
     fc3:	mov    QWORD PTR [rsp+0x8],rdx
     fc8:	mov    rdx,r13
     fcb:	mov    rsi,rbx
     fce:	mov    rdi,r12
     fd1:	call   fd6 <botlish_fn_13+0x40>
			fd2: R_X86_64_PLT32	botlish_fn_10-0x4 ; quote_at?<str, int>
     fd6:	test   rax,rax
     fd9:	je     108a <botlish_fn_13+0xf4>
     fdf:	cmp    rax,0x6
     fe3:	je     101b <botlish_fn_13+0x85>
     fe9:	mov    rcx,r13
     fec:	mov    rsi,rbx
     fef:	mov    rdi,r12
     ff2:	mov    rdx,rcx
     ff5:	call   ffa <botlish_fn_13+0x64>
			ff6: R_X86_64_PLT32	botlish_fn_11-0x4 ; scan_unquoted<str, int, int>
     ffa:	test   rax,rax
     ffd:	je     108a <botlish_fn_13+0xf4>
    1003:	mov    rbx,QWORD PTR [rsp+0x20]
    1008:	mov    r12,QWORD PTR [rsp+0x28]
    100d:	mov    r13,QWORD PTR [rsp+0x30]
    1012:	add    rsp,0x40
    1016:	mov    rsp,rbp
    1019:	pop    rbp
    101a:	ret
    101b:	mov    rcx,r13
    101e:	mov    QWORD PTR [rsp+0x10],0x3
    1027:	test   rcx,0x1
    102e:	jne    103c <botlish_fn_13+0xa6>
    1034:	mov    r13,rcx
    1037:	jmp    1051 <botlish_fn_13+0xbb>
    103c:	mov    rdx,rcx
    103f:	add    rdx,0x2
    1043:	mov    r13,rcx
    1046:	seto   al
    1049:	test   al,al
    104b:	je     1064 <botlish_fn_13+0xce>
    1051:	mov    edx,0x3
    1056:	mov    rsi,r13
    1059:	mov    rdi,r12
    105c:	call   1061 <botlish_fn_13+0xcb>
			105d: R_X86_64_PLT32	rt_int_add-0x4
    1061:	mov    rdx,rax
    1064:	mov    QWORD PTR [rsp+0x8],rdx
    1069:	mov    rdi,r12
    106c:	mov    rax,QWORD PTR [rdi+0x10]
    1070:	mov    rcx,QWORD PTR [rax+0x8]
    1074:	mov    QWORD PTR [rsp+0x10],rcx
    1079:	mov    rsi,rbx
    107c:	call   1081 <botlish_fn_13+0xeb>
			107d: R_X86_64_PLT32	botlish_fn_12-0x4 ; scan_quoted<str, int, str>
    1081:	test   rax,rax
    1084:	jne    10a8 <botlish_fn_13+0x112>
    108a:	xor    rdx,rdx
    108d:	mov    rax,rdx
    1090:	mov    rbx,QWORD PTR [rsp+0x20]
    1095:	mov    r12,QWORD PTR [rsp+0x28]
    109a:	mov    r13,QWORD PTR [rsp+0x30]
    109f:	add    rsp,0x40
    10a3:	mov    rsp,rbp
    10a6:	pop    rbp
    10a7:	ret
    10a8:	mov    rbx,QWORD PTR [rsp+0x20]
    10ad:	mov    r12,QWORD PTR [rsp+0x28]
    10b2:	mov    r13,QWORD PTR [rsp+0x30]
    10b7:	add    rsp,0x40
    10bb:	mov    rsp,rbp
    10be:	pop    rbp
    10bf:	ret

00000000000010c0 <botlish_entry_13: scan_field<str, int>>:
    10c0:	push   rbp
    10c1:	mov    rbp,rsp
    10c4:	ud2
	...

00000000000010c8 <botlish_fn_14: scan_record_rest<str, int, mutarray, int>>:
    10c8:	push   rbp
    10c9:	mov    rbp,rsp
    10cc:	sub    rsp,0x60
    10d0:	mov    QWORD PTR [rsp+0x30],rbx
    10d5:	mov    QWORD PTR [rsp+0x38],r12
    10da:	mov    QWORD PTR [rsp+0x40],r13
    10df:	mov    QWORD PTR [rsp+0x48],r14
    10e4:	mov    QWORD PTR [rsp+0x50],r15
    10e9:	mov    r13,rdi
    10ec:	mov    QWORD PTR [rsp+0x20],0x0
    10f5:	mov    QWORD PTR [rsp],rsi
    10f9:	mov    QWORD PTR [rsp+0x8],rdx
    10fe:	mov    QWORD PTR [rsp+0x10],rcx
    1103:	mov    QWORD PTR [rsp+0x18],r8
    1108:	mov    rbx,rsi
    110b:	mov    r12,rdx
    110e:	mov    r14,r8
    1111:	mov    r15,rcx
    1114:	mov    rdx,QWORD PTR [rbx+0x8]
    1118:	shl    rdx,1
    111b:	or     rdx,0x1
    111f:	mov    rax,r12
    1122:	and    rax,rdx
    1125:	test   rax,0x1
    112b:	jne    1151 <botlish_fn_14+0x89>
    1131:	mov    rsi,r12
    1134:	mov    rdi,r13
    1137:	call   113c <botlish_fn_14+0x74>
			1138: R_X86_64_PLT32	rt_int_cmp-0x4
    113c:	mov    ecx,0x2
    1141:	test   rax,rax
    1144:	cmovl  rcx,QWORD PTR [rip+0x24c]        # 1398 <botlish_fn_14+0x2d0>
    114c:	jmp    1164 <botlish_fn_14+0x9c>
    1151:	mov    ecx,0x2
    1156:	mov    rax,r12
    1159:	cmp    rax,rdx
    115c:	cmovl  rcx,QWORD PTR [rip+0x234]        # 1398 <botlish_fn_14+0x2d0>
    1164:	cmp    rcx,0x6
    1168:	je     117c <botlish_fn_14+0xb4>
    116e:	mov    rdx,r14
    1171:	mov    rsi,r15
    1174:	mov    rdi,r13
    1177:	jmp    11b2 <botlish_fn_14+0xea>
    117c:	mov    rdx,r12
    117f:	mov    rsi,rbx
    1182:	mov    rdi,r13
    1185:	call   118a <botlish_fn_14+0xc2>
			1186: R_X86_64_PLT32	rt_str_char_at-0x4
    118a:	test   rax,rax
    118d:	je     12f2 <botlish_fn_14+0x22a>
    1193:	cmp    rax,0x164
    1199:	je     1271 <botlish_fn_14+0x1a9>
    119f:	cmp    rax,0x54
    11a3:	je     11e8 <botlish_fn_14+0x120>
    11a9:	mov    rdx,r14
    11ac:	mov    rsi,r15
    11af:	mov    rdi,r13
    11b2:	mov    rdi,r13
    11b5:	call   11ba <botlish_fn_14+0xf2>
			11b6: R_X86_64_PLT32	botlish_fn_8-0x4 ; geo_finish<mutarray, int>
    11ba:	test   rax,rax
    11bd:	je     12f2 <botlish_fn_14+0x22a>
    11c3:	mov    rdx,r12
    11c6:	mov    rbx,QWORD PTR [rsp+0x30]
    11cb:	mov    r12,QWORD PTR [rsp+0x38]
    11d0:	mov    r13,QWORD PTR [rsp+0x40]
    11d5:	mov    r14,QWORD PTR [rsp+0x48]
    11da:	mov    r15,QWORD PTR [rsp+0x50]
    11df:	add    rsp,0x60
    11e3:	mov    rsp,rbp
    11e6:	pop    rbp
    11e7:	ret
    11e8:	mov    rdx,r14
    11eb:	mov    rsi,r15
    11ee:	mov    rdi,r13
    11f1:	call   11f6 <botlish_fn_14+0x12e>
			11f2: R_X86_64_PLT32	botlish_fn_8-0x4 ; geo_finish<mutarray, int>
    11f6:	test   rax,rax
    11f9:	je     12f2 <botlish_fn_14+0x22a>
    11ff:	mov    QWORD PTR [rsp],rax
    1203:	mov    r14,rax
    1206:	mov    QWORD PTR [rsp+0x10],0x3
    120f:	mov    rdx,r12
    1212:	test   rdx,0x1
    1219:	je     1239 <botlish_fn_14+0x171>
    121f:	mov    rdx,r12
    1222:	add    rdx,0x2
    1226:	seto   al
    1229:	test   al,al
    122b:	jne    1239 <botlish_fn_14+0x171>
    1231:	mov    rax,r14
    1234:	jmp    124f <botlish_fn_14+0x187>
    1239:	mov    edx,0x3
    123e:	mov    rsi,r12
    1241:	mov    rdi,r13
    1244:	call   1249 <botlish_fn_14+0x181>
			1245: R_X86_64_PLT32	rt_int_add-0x4
    1249:	mov    rdx,rax
    124c:	mov    rax,r14
    124f:	mov    rbx,QWORD PTR [rsp+0x30]
    1254:	mov    r12,QWORD PTR [rsp+0x38]
    1259:	mov    r13,QWORD PTR [rsp+0x40]
    125e:	mov    r14,QWORD PTR [rsp+0x48]
    1263:	mov    r15,QWORD PTR [rsp+0x50]
    1268:	add    rsp,0x60
    126c:	mov    rsp,rbp
    126f:	pop    rbp
    1270:	ret
    1271:	mov    rsi,r12
    1274:	mov    edx,0x3
    1279:	mov    r12,rdx
    127c:	mov    QWORD PTR [rsp+0x20],0x3
    1285:	test   rsi,0x1
    128c:	je     12a4 <botlish_fn_14+0x1dc>
    1292:	mov    rdx,rsi
    1295:	add    rdx,0x2
    1299:	seto   al
    129c:	test   al,al
    129e:	je     12b2 <botlish_fn_14+0x1ea>
    12a4:	mov    rdx,r12
    12a7:	mov    rdi,r13
    12aa:	call   12af <botlish_fn_14+0x1e7>
			12ab: R_X86_64_PLT32	rt_int_add-0x4
    12af:	mov    rdx,rax
    12b2:	mov    QWORD PTR [rsp+0x8],rdx
    12b7:	mov    rsi,rbx
    12ba:	mov    rdi,r13
    12bd:	call   12c2 <botlish_fn_14+0x1fa>
			12be: R_X86_64_PLT32	botlish_fn_13-0x4 ; scan_field<str, int>
    12c2:	test   rax,rax
    12c5:	je     12f2 <botlish_fn_14+0x22a>
    12cb:	mov    QWORD PTR [rsp+0x8],rax
    12d0:	mov    rcx,rax
    12d3:	mov    QWORD PTR [rsp+0x20],rdx
    12d8:	mov    rsi,r15
    12db:	mov    r15,rdx
    12de:	mov    rdx,r14
    12e1:	mov    rdi,r13
    12e4:	call   12e9 <botlish_fn_14+0x221>
			12e5: R_X86_64_PLT32	botlish_fn_6-0x4 ; geo_append<mutarray, int, str>
    12e9:	test   rax,rax
    12ec:	jne    131a <botlish_fn_14+0x252>
    12f2:	xor    rdx,rdx
    12f5:	mov    rax,rdx
    12f8:	mov    rbx,QWORD PTR [rsp+0x30]
    12fd:	mov    r12,QWORD PTR [rsp+0x38]
    1302:	mov    r13,QWORD PTR [rsp+0x40]
    1307:	mov    r14,QWORD PTR [rsp+0x48]
    130c:	mov    r15,QWORD PTR [rsp+0x50]
    1311:	add    rsp,0x60
    1315:	mov    rsp,rbp
    1318:	pop    rbp
    1319:	ret
    131a:	mov    QWORD PTR [rsp+0x8],rax
    131f:	mov    QWORD PTR [rsp+0x28],rax
    1324:	mov    QWORD PTR [rsp+0x10],0x3
    132d:	mov    rdx,r14
    1330:	test   rdx,0x1
    1337:	jne    1348 <botlish_fn_14+0x280>
    133d:	mov    rdx,r12
    1340:	mov    rsi,r14
    1343:	jmp    1363 <botlish_fn_14+0x29b>
    1348:	mov    rdx,r14
    134b:	mov    rax,rdx
    134e:	add    rax,0x2
    1352:	seto   cl
    1355:	test   cl,cl
    1357:	je     136b <botlish_fn_14+0x2a3>
    135d:	mov    rdx,r12
    1360:	mov    rsi,r14
    1363:	mov    rdi,r13
    1366:	call   136b <botlish_fn_14+0x2a3>
			1367: R_X86_64_PLT32	rt_int_add-0x4
    136b:	mov    QWORD PTR [rsp],rbx
    136f:	mov    rdx,r15
    1372:	mov    QWORD PTR [rsp+0x8],rdx
    1377:	mov    rcx,QWORD PTR [rsp+0x28]
    137c:	mov    QWORD PTR [rsp+0x10],rcx
    1381:	mov    QWORD PTR [rsp+0x18],rax
    1386:	mov    r12,rdx
    1389:	mov    r14,rax
    138c:	mov    r15,rcx
    138f:	jmp    1114 <botlish_fn_14+0x4c>
    1394:	add    BYTE PTR [rax],al
    1396:	add    BYTE PTR [rax],al
    1398:	(bad)
    1399:	add    BYTE PTR [rax],al
    139b:	add    BYTE PTR [rax],al
    139d:	add    BYTE PTR [rax],al
	...

00000000000013a0 <botlish_entry_14: scan_record_rest<str, int, mutarray, int>>:
    13a0:	push   rbp
    13a1:	mov    rbp,rsp
    13a4:	ud2

00000000000013a6 <botlish_fn_15: scan_record<str, int>>:
    13a6:	push   rbp
    13a7:	mov    rbp,rsp
    13aa:	sub    rsp,0x40
    13ae:	mov    QWORD PTR [rsp+0x20],rbx
    13b3:	mov    QWORD PTR [rsp+0x28],r12
    13b8:	mov    QWORD PTR [rsp+0x30],r14
    13bd:	mov    r14,rdi
    13c0:	mov    QWORD PTR [rsp+0x10],0x0
    13c9:	mov    QWORD PTR [rsp+0x18],0x0
    13d2:	mov    QWORD PTR [rsp],rsi
    13d6:	mov    r12,rsi
    13d9:	mov    QWORD PTR [rsp+0x8],rdx
    13de:	mov    rsi,r12
    13e1:	mov    rdi,r14
    13e4:	call   13e9 <botlish_fn_15+0x43>
			13e5: R_X86_64_PLT32	botlish_fn_13-0x4 ; scan_field<str, int>
    13e9:	test   rax,rax
    13ec:	je     1441 <botlish_fn_15+0x9b>
    13f2:	mov    QWORD PTR [rsp+0x8],rax
    13f7:	mov    rsi,rax
    13fa:	mov    QWORD PTR [rsp+0x10],rdx
    13ff:	mov    rbx,rdx
    1402:	mov    rdi,r14
    1405:	call   140a <botlish_fn_15+0x64>
			1406: R_X86_64_PLT32	botlish_fn_1-0x4 ; geo_new<str>
    140a:	test   rax,rax
    140d:	je     1441 <botlish_fn_15+0x9b>
    1413:	mov    QWORD PTR [rsp+0x8],rax
    1418:	mov    rcx,rax
    141b:	mov    r8d,0x3
    1421:	mov    QWORD PTR [rsp+0x18],0x3
    142a:	mov    rdx,rbx
    142d:	mov    rsi,r12
    1430:	mov    rdi,r14
    1433:	call   1438 <botlish_fn_15+0x92>
			1434: R_X86_64_PLT32	botlish_fn_14-0x4 ; scan_record_rest<str, int, mutarray, int>
    1438:	test   rax,rax
    143b:	jne    145f <botlish_fn_15+0xb9>
    1441:	xor    rdx,rdx
    1444:	mov    rax,rdx
    1447:	mov    rbx,QWORD PTR [rsp+0x20]
    144c:	mov    r12,QWORD PTR [rsp+0x28]
    1451:	mov    r14,QWORD PTR [rsp+0x30]
    1456:	add    rsp,0x40
    145a:	mov    rsp,rbp
    145d:	pop    rbp
    145e:	ret
    145f:	mov    rbx,QWORD PTR [rsp+0x20]
    1464:	mov    r12,QWORD PTR [rsp+0x28]
    1469:	mov    r14,QWORD PTR [rsp+0x30]
    146e:	add    rsp,0x40
    1472:	mov    rsp,rbp
    1475:	pop    rbp
    1476:	ret

0000000000001477 <botlish_entry_15: scan_record<str, int>>:
    1477:	push   rbp
    1478:	mov    rbp,rsp
    147b:	ud2
    147d:	add    BYTE PTR [rax],al
	...

0000000000001480 <botlish_fn_16: scan_records<str, int, mutarray, int>>:
    1480:	push   rbp
    1481:	mov    rbp,rsp
    1484:	sub    rsp,0x60
    1488:	mov    QWORD PTR [rsp+0x30],rbx
    148d:	mov    QWORD PTR [rsp+0x38],r12
    1492:	mov    QWORD PTR [rsp+0x40],r13
    1497:	mov    QWORD PTR [rsp+0x48],r14
    149c:	mov    QWORD PTR [rsp+0x50],r15
    14a1:	mov    r13,rdi
    14a4:	mov    QWORD PTR [rsp+0x20],0x0
    14ad:	mov    QWORD PTR [rsp],rsi
    14b1:	mov    QWORD PTR [rsp+0x8],rdx
    14b6:	mov    rax,rdx
    14b9:	mov    QWORD PTR [rsp+0x10],rcx
    14be:	mov    QWORD PTR [rsp+0x18],r8
    14c3:	mov    rbx,rsi
    14c6:	mov    r14,r8
    14c9:	mov    r15,rcx
    14cc:	mov    rdx,QWORD PTR [rbx+0x8]
    14d0:	shl    rdx,1
    14d3:	or     rdx,0x1
    14d7:	mov    r12,rax
    14da:	and    rax,rdx
    14dd:	test   rax,0x1
    14e3:	jne    1509 <botlish_fn_16+0x89>
    14e9:	mov    rsi,r12
    14ec:	mov    rdi,r13
    14ef:	call   14f4 <botlish_fn_16+0x74>
			14f0: R_X86_64_PLT32	rt_int_cmp-0x4
    14f4:	mov    ecx,0x2
    14f9:	test   rax,rax
    14fc:	cmovge rcx,QWORD PTR [rip+0x12c]        # 1630 <botlish_fn_16+0x1b0>
    1504:	jmp    1519 <botlish_fn_16+0x99>
    1509:	mov    ecx,0x2
    150e:	cmp    r12,rdx
    1511:	cmovge rcx,QWORD PTR [rip+0x117]        # 1630 <botlish_fn_16+0x1b0>
    1519:	cmp    rcx,0x6
    151d:	je     15cb <botlish_fn_16+0x14b>
    1523:	mov    rdx,r12
    1526:	mov    rsi,rbx
    1529:	mov    rdi,r13
    152c:	call   1531 <botlish_fn_16+0xb1>
			152d: R_X86_64_PLT32	botlish_fn_15-0x4 ; scan_record<str, int>
    1531:	test   rax,rax
    1534:	je     15e2 <botlish_fn_16+0x162>
    153a:	mov    QWORD PTR [rsp+0x8],rax
    153f:	mov    rcx,rax
    1542:	mov    QWORD PTR [rsp+0x20],rdx
    1547:	mov    rsi,r15
    154a:	mov    r12,rdx
    154d:	mov    rdx,r14
    1550:	mov    rdi,r13
    1553:	call   1558 <botlish_fn_16+0xd8>
			1554: R_X86_64_PLT32	botlish_fn_7-0x4 ; geo_append<mutarray, int, List[str]>
    1558:	test   rax,rax
    155b:	je     15e2 <botlish_fn_16+0x162>
    1561:	mov    QWORD PTR [rsp+0x8],rax
    1566:	mov    r15,rax
    1569:	mov    QWORD PTR [rsp+0x10],0x3
    1572:	mov    rsi,r14
    1575:	test   rsi,0x1
    157c:	je     1597 <botlish_fn_16+0x117>
    1582:	mov    rsi,r14
    1585:	mov    rax,rsi
    1588:	add    rax,0x2
    158c:	seto   cl
    158f:	test   cl,cl
    1591:	je     15a7 <botlish_fn_16+0x127>
    1597:	mov    edx,0x3
    159c:	mov    rsi,r14
    159f:	mov    rdi,r13
    15a2:	call   15a7 <botlish_fn_16+0x127>
			15a3: R_X86_64_PLT32	rt_int_add-0x4
    15a7:	mov    QWORD PTR [rsp],rbx
    15ab:	mov    rdx,r12
    15ae:	mov    QWORD PTR [rsp+0x8],rdx
    15b3:	mov    rcx,r15
    15b6:	mov    QWORD PTR [rsp+0x10],rcx
    15bb:	mov    QWORD PTR [rsp+0x18],rax
    15c0:	mov    r14,rax
    15c3:	mov    rax,rdx
    15c6:	jmp    14cc <botlish_fn_16+0x4c>
    15cb:	mov    rdx,r14
    15ce:	mov    rsi,r15
    15d1:	mov    rdi,r13
    15d4:	call   15d9 <botlish_fn_16+0x159>
			15d5: R_X86_64_PLT32	botlish_fn_8-0x4 ; geo_finish<mutarray, int>
    15d9:	test   rax,rax
    15dc:	jne    1607 <botlish_fn_16+0x187>
    15e2:	xor    rax,rax
    15e5:	mov    rbx,QWORD PTR [rsp+0x30]
    15ea:	mov    r12,QWORD PTR [rsp+0x38]
    15ef:	mov    r13,QWORD PTR [rsp+0x40]
    15f4:	mov    r14,QWORD PTR [rsp+0x48]
    15f9:	mov    r15,QWORD PTR [rsp+0x50]
    15fe:	add    rsp,0x60
    1602:	mov    rsp,rbp
    1605:	pop    rbp
    1606:	ret
    1607:	mov    rbx,QWORD PTR [rsp+0x30]
    160c:	mov    r12,QWORD PTR [rsp+0x38]
    1611:	mov    r13,QWORD PTR [rsp+0x40]
    1616:	mov    r14,QWORD PTR [rsp+0x48]
    161b:	mov    r15,QWORD PTR [rsp+0x50]
    1620:	add    rsp,0x60
    1624:	mov    rsp,rbp
    1627:	pop    rbp
    1628:	ret
    1629:	add    BYTE PTR [rax],al
    162b:	add    BYTE PTR [rax],al
    162d:	add    BYTE PTR [rax],al
    162f:	add    BYTE PTR [rsi],al
    1631:	add    BYTE PTR [rax],al
    1633:	add    BYTE PTR [rax],al
    1635:	add    BYTE PTR [rax],al
	...

0000000000001638 <botlish_entry_16: scan_records<str, int, mutarray, int>>:
    1638:	push   rbp
    1639:	mov    rbp,rsp
    163c:	mov    rsi,QWORD PTR [rdx]
    163f:	mov    r9,QWORD PTR [rdx+0x8]
    1643:	mov    rcx,QWORD PTR [rdx+0x10]
    1647:	mov    r8,QWORD PTR [rdx+0x18]
    164b:	mov    rdx,r9
    164e:	call   1653 <botlish_entry_16+0x1b>
			164f: R_X86_64_PLT32	botlish_fn_16-0x4 ; scan_records<str, int, mutarray, int>
    1653:	mov    rsp,rbp
    1656:	pop    rbp
    1657:	ret

0000000000001658 <botlish_fn_17: csv_parse<str>>:
    1658:	push   rbp
    1659:	mov    rbp,rsp
    165c:	sub    rsp,0x40
    1660:	mov    QWORD PTR [rsp+0x20],rbx
    1665:	mov    QWORD PTR [rsp+0x28],r12
    166a:	mov    QWORD PTR [rsp+0x30],r13
    166f:	mov    rbx,rdi
    1672:	mov    QWORD PTR [rsp+0x8],0x0
    167b:	mov    QWORD PTR [rsp+0x10],0x0
    1684:	mov    QWORD PTR [rsp+0x18],0x0
    168d:	mov    QWORD PTR [rsp],rsi
    1691:	mov    rax,QWORD PTR [rsi+0x8]
    1695:	mov    r12,rsi
    1698:	shl    rax,1
    169b:	or     rax,0x1
    169f:	sar    rax,1
    16a2:	test   rax,rax
    16a5:	je     1734 <botlish_fn_17+0xdc>
    16ab:	mov    edx,0x1
    16b0:	mov    QWORD PTR [rsp+0x8],0x1
    16b9:	mov    rsi,r12
    16bc:	mov    rdi,rbx
    16bf:	call   16c4 <botlish_fn_17+0x6c>
			16c0: R_X86_64_PLT32	botlish_fn_15-0x4 ; scan_record<str, int>
    16c4:	test   rax,rax
    16c7:	je     174b <botlish_fn_17+0xf3>
    16cd:	mov    QWORD PTR [rsp+0x8],rax
    16d2:	mov    rsi,rax
    16d5:	mov    QWORD PTR [rsp+0x10],rdx
    16da:	mov    r13,rdx
    16dd:	mov    rdi,rbx
    16e0:	call   16e5 <botlish_fn_17+0x8d>
			16e1: R_X86_64_PLT32	botlish_fn_2-0x4 ; geo_new<List[str]>
    16e5:	test   rax,rax
    16e8:	je     174b <botlish_fn_17+0xf3>
    16ee:	mov    QWORD PTR [rsp+0x8],rax
    16f3:	mov    rcx,rax
    16f6:	mov    r8d,0x3
    16fc:	mov    QWORD PTR [rsp+0x18],0x3
    1705:	mov    rdx,r13
    1708:	mov    rsi,r12
    170b:	mov    rdi,rbx
    170e:	call   1713 <botlish_fn_17+0xbb>
			170f: R_X86_64_PLT32	botlish_fn_16-0x4 ; scan_records<str, int, mutarray, int>
    1713:	test   rax,rax
    1716:	je     174b <botlish_fn_17+0xf3>
    171c:	mov    rbx,QWORD PTR [rsp+0x20]
    1721:	mov    r12,QWORD PTR [rsp+0x28]
    1726:	mov    r13,QWORD PTR [rsp+0x30]
    172b:	add    rsp,0x40
    172f:	mov    rsp,rbp
    1732:	pop    rbp
    1733:	ret
    1734:	xor    rdx,rdx
    1737:	mov    rdi,rbx
    173a:	mov    rsi,rdx
    173d:	call   1742 <botlish_fn_17+0xea>
			173e: R_X86_64_PLT32	rt_list_new-0x4
    1742:	test   rax,rax
    1745:	jne    1766 <botlish_fn_17+0x10e>
    174b:	xor    rax,rax
    174e:	mov    rbx,QWORD PTR [rsp+0x20]
    1753:	mov    r12,QWORD PTR [rsp+0x28]
    1758:	mov    r13,QWORD PTR [rsp+0x30]
    175d:	add    rsp,0x40
    1761:	mov    rsp,rbp
    1764:	pop    rbp
    1765:	ret
    1766:	mov    rbx,QWORD PTR [rsp+0x20]
    176b:	mov    r12,QWORD PTR [rsp+0x28]
    1770:	mov    r13,QWORD PTR [rsp+0x30]
    1775:	add    rsp,0x40
    1779:	mov    rsp,rbp
    177c:	pop    rbp
    177d:	ret

000000000000177e <botlish_entry_17: csv_parse<str>>:
    177e:	push   rbp
    177f:	mov    rbp,rsp
    1782:	mov    rsi,QWORD PTR [rdx]
    1785:	call   178a <botlish_entry_17+0xc>
			1786: R_X86_64_PLT32	botlish_fn_17-0x4 ; csv_parse<str>
    178a:	mov    rsp,rbp
    178d:	pop    rbp
    178e:	ret
