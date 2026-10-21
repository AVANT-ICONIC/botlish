; source:  examples/stdlib/csv_geometric.bot
; backend: Cranelift (specialize=1), native::object
; object:  ELF64 x86-64, unlinked (Botlish-generated code only; runtime
;          helpers are unresolved imports, so their bodies are not present)
; format:  objdump -dr --no-show-raw-insn -M intel
; total machine code bytes: 6502  (per function: 312 89 89 357 436 436 272 272 81 365 309 470 932 311 758 215 480 318)
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
     311:	mov    rbx,rdx
     314:	mov    r13,rdi
     317:	mov    QWORD PTR [rsp],rsi
     31b:	mov    r12,rsi
     31e:	mov    QWORD PTR [rsp+0x8],rdx
     323:	mov    QWORD PTR [rsp+0x10],rcx
     328:	mov    r14,rcx
     32b:	mov    rax,r12
     32e:	mov    rsi,QWORD PTR [rax+0x8]
     332:	shl    rsi,1
     335:	mov    rax,rsi
     338:	or     rax,0x1
     33c:	mov    QWORD PTR [rsp+0x18],rax
     341:	mov    rdx,rbx
     344:	mov    rcx,rdx
     347:	and    rcx,rax
     34a:	test   rcx,0x1
     351:	jne    384 <botlish_fn_4+0x94>
     357:	mov    rdx,rsi
     35a:	or     rdx,0x1
     35e:	mov    r15,rsi
     361:	mov    rsi,rbx
     364:	mov    rdi,r13
     367:	call   36c <botlish_fn_4+0x7c>
			368: R_X86_64_PLT32	rt_int_cmp-0x4
     36c:	mov    ecx,0x2
     371:	test   rax,rax
     374:	cmovl  rcx,QWORD PTR [rip+0xec]        # 468 <botlish_fn_4+0x178>
     37c:	mov    rsi,r15
     37f:	jmp    39b <botlish_fn_4+0xab>
     384:	mov    rdx,rsi
     387:	or     rdx,0x1
     38b:	mov    ecx,0x2
     390:	cmp    rbx,rdx
     393:	cmovl  rcx,QWORD PTR [rip+0xcd]        # 468 <botlish_fn_4+0x178>
     39b:	cmp    rcx,0x6
     39f:	je     440 <botlish_fn_4+0x150>
     3a5:	or     rsi,0x1
     3a9:	mov    rdx,rbx
     3ac:	mov    rdi,r13
     3af:	call   3b4 <botlish_fn_4+0xc4>
			3b0: R_X86_64_PLT32	botlish_fn_3-0x4 ; geo_new_capacity<int, int>
     3b4:	mov    QWORD PTR [rsp+0x18],rax
     3b9:	mov    rdx,r14
     3bc:	mov    rsi,rax
     3bf:	mov    rdi,r13
     3c2:	call   3c7 <botlish_fn_4+0xd7>
			3c3: R_X86_64_PLT32	rt_mutarray_create-0x4
     3c7:	test   rax,rax
     3ca:	mov    r14,rax
     3cd:	je     3f6 <botlish_fn_4+0x106>
     3d3:	mov    r8d,0x1
     3d9:	mov    rcx,r12
     3dc:	mov    rdi,r13
     3df:	mov    r9,rbx
     3e2:	mov    rsi,r14
     3e5:	mov    rdx,r8
     3e8:	call   3ed <botlish_fn_4+0xfd>
			3e9: R_X86_64_PLT32	rt_mutarray_copy-0x4
     3ed:	test   rax,rax
     3f0:	jne    41b <botlish_fn_4+0x12b>
     3f6:	xor    rax,rax
     3f9:	mov    rbx,QWORD PTR [rsp+0x20]
     3fe:	mov    r12,QWORD PTR [rsp+0x28]
     403:	mov    r13,QWORD PTR [rsp+0x30]
     408:	mov    r14,QWORD PTR [rsp+0x38]
     40d:	mov    r15,QWORD PTR [rsp+0x40]
     412:	add    rsp,0x50
     416:	mov    rsp,rbp
     419:	pop    rbp
     41a:	ret
     41b:	mov    rax,r14
     41e:	mov    rbx,QWORD PTR [rsp+0x20]
     423:	mov    r12,QWORD PTR [rsp+0x28]
     428:	mov    r13,QWORD PTR [rsp+0x30]
     42d:	mov    r14,QWORD PTR [rsp+0x38]
     432:	mov    r15,QWORD PTR [rsp+0x40]
     437:	add    rsp,0x50
     43b:	mov    rsp,rbp
     43e:	pop    rbp
     43f:	ret
     440:	mov    rax,r12
     443:	mov    rbx,QWORD PTR [rsp+0x20]
     448:	mov    r12,QWORD PTR [rsp+0x28]
     44d:	mov    r13,QWORD PTR [rsp+0x30]
     452:	mov    r14,QWORD PTR [rsp+0x38]
     457:	mov    r15,QWORD PTR [rsp+0x40]
     45c:	add    rsp,0x50
     460:	mov    rsp,rbp
     463:	pop    rbp
     464:	ret
     465:	add    BYTE PTR [rax],al
     467:	add    BYTE PTR [rsi],al
     469:	add    BYTE PTR [rax],al
     46b:	add    BYTE PTR [rax],al
     46d:	add    BYTE PTR [rax],al
	...

0000000000000470 <botlish_entry_4: geo_grow<mutarray, int, str>>:
     470:	push   rbp
     471:	mov    rbp,rsp
     474:	mov    rsi,QWORD PTR [rdx]
     477:	mov    r8,QWORD PTR [rdx+0x8]
     47b:	mov    rcx,QWORD PTR [rdx+0x10]
     47f:	mov    rdx,r8
     482:	call   487 <botlish_entry_4+0x17>
			483: R_X86_64_PLT32	botlish_fn_4-0x4 ; geo_grow<mutarray, int, str>
     487:	mov    rsp,rbp
     48a:	pop    rbp
     48b:	ret
     48c:	add    BYTE PTR [rax],al
	...

0000000000000490 <botlish_fn_5: geo_grow<mutarray, int, List[str]>>:
     490:	push   rbp
     491:	mov    rbp,rsp
     494:	sub    rsp,0x50
     498:	mov    QWORD PTR [rsp+0x20],rbx
     49d:	mov    QWORD PTR [rsp+0x28],r12
     4a2:	mov    QWORD PTR [rsp+0x30],r13
     4a7:	mov    QWORD PTR [rsp+0x38],r14
     4ac:	mov    QWORD PTR [rsp+0x40],r15
     4b1:	mov    rbx,rdx
     4b4:	mov    r13,rdi
     4b7:	mov    QWORD PTR [rsp],rsi
     4bb:	mov    r12,rsi
     4be:	mov    QWORD PTR [rsp+0x8],rdx
     4c3:	mov    QWORD PTR [rsp+0x10],rcx
     4c8:	mov    r14,rcx
     4cb:	mov    rax,r12
     4ce:	mov    rsi,QWORD PTR [rax+0x8]
     4d2:	shl    rsi,1
     4d5:	mov    rax,rsi
     4d8:	or     rax,0x1
     4dc:	mov    QWORD PTR [rsp+0x18],rax
     4e1:	mov    rdx,rbx
     4e4:	mov    rcx,rdx
     4e7:	and    rcx,rax
     4ea:	test   rcx,0x1
     4f1:	jne    524 <botlish_fn_5+0x94>
     4f7:	mov    rdx,rsi
     4fa:	or     rdx,0x1
     4fe:	mov    r15,rsi
     501:	mov    rsi,rbx
     504:	mov    rdi,r13
     507:	call   50c <botlish_fn_5+0x7c>
			508: R_X86_64_PLT32	rt_int_cmp-0x4
     50c:	mov    ecx,0x2
     511:	test   rax,rax
     514:	cmovl  rcx,QWORD PTR [rip+0xec]        # 608 <botlish_fn_5+0x178>
     51c:	mov    rsi,r15
     51f:	jmp    53b <botlish_fn_5+0xab>
     524:	mov    rdx,rsi
     527:	or     rdx,0x1
     52b:	mov    ecx,0x2
     530:	cmp    rbx,rdx
     533:	cmovl  rcx,QWORD PTR [rip+0xcd]        # 608 <botlish_fn_5+0x178>
     53b:	cmp    rcx,0x6
     53f:	je     5e0 <botlish_fn_5+0x150>
     545:	or     rsi,0x1
     549:	mov    rdx,rbx
     54c:	mov    rdi,r13
     54f:	call   554 <botlish_fn_5+0xc4>
			550: R_X86_64_PLT32	botlish_fn_3-0x4 ; geo_new_capacity<int, int>
     554:	mov    QWORD PTR [rsp+0x18],rax
     559:	mov    rdx,r14
     55c:	mov    rsi,rax
     55f:	mov    rdi,r13
     562:	call   567 <botlish_fn_5+0xd7>
			563: R_X86_64_PLT32	rt_mutarray_create-0x4
     567:	test   rax,rax
     56a:	mov    r14,rax
     56d:	je     596 <botlish_fn_5+0x106>
     573:	mov    r8d,0x1
     579:	mov    rcx,r12
     57c:	mov    rdi,r13
     57f:	mov    r9,rbx
     582:	mov    rsi,r14
     585:	mov    rdx,r8
     588:	call   58d <botlish_fn_5+0xfd>
			589: R_X86_64_PLT32	rt_mutarray_copy-0x4
     58d:	test   rax,rax
     590:	jne    5bb <botlish_fn_5+0x12b>
     596:	xor    rax,rax
     599:	mov    rbx,QWORD PTR [rsp+0x20]
     59e:	mov    r12,QWORD PTR [rsp+0x28]
     5a3:	mov    r13,QWORD PTR [rsp+0x30]
     5a8:	mov    r14,QWORD PTR [rsp+0x38]
     5ad:	mov    r15,QWORD PTR [rsp+0x40]
     5b2:	add    rsp,0x50
     5b6:	mov    rsp,rbp
     5b9:	pop    rbp
     5ba:	ret
     5bb:	mov    rax,r14
     5be:	mov    rbx,QWORD PTR [rsp+0x20]
     5c3:	mov    r12,QWORD PTR [rsp+0x28]
     5c8:	mov    r13,QWORD PTR [rsp+0x30]
     5cd:	mov    r14,QWORD PTR [rsp+0x38]
     5d2:	mov    r15,QWORD PTR [rsp+0x40]
     5d7:	add    rsp,0x50
     5db:	mov    rsp,rbp
     5de:	pop    rbp
     5df:	ret
     5e0:	mov    rax,r12
     5e3:	mov    rbx,QWORD PTR [rsp+0x20]
     5e8:	mov    r12,QWORD PTR [rsp+0x28]
     5ed:	mov    r13,QWORD PTR [rsp+0x30]
     5f2:	mov    r14,QWORD PTR [rsp+0x38]
     5f7:	mov    r15,QWORD PTR [rsp+0x40]
     5fc:	add    rsp,0x50
     600:	mov    rsp,rbp
     603:	pop    rbp
     604:	ret
     605:	add    BYTE PTR [rax],al
     607:	add    BYTE PTR [rsi],al
     609:	add    BYTE PTR [rax],al
     60b:	add    BYTE PTR [rax],al
     60d:	add    BYTE PTR [rax],al
	...

0000000000000610 <botlish_entry_5: geo_grow<mutarray, int, List[str]>>:
     610:	push   rbp
     611:	mov    rbp,rsp
     614:	mov    rsi,QWORD PTR [rdx]
     617:	mov    r8,QWORD PTR [rdx+0x8]
     61b:	mov    rcx,QWORD PTR [rdx+0x10]
     61f:	mov    rdx,r8
     622:	call   627 <botlish_entry_5+0x17>
			623: R_X86_64_PLT32	botlish_fn_5-0x4 ; geo_grow<mutarray, int, List[str]>
     627:	mov    rsp,rbp
     62a:	pop    rbp
     62b:	ret

000000000000062c <botlish_fn_6: geo_append<mutarray, int, str>>:
     62c:	push   rbp
     62d:	mov    rbp,rsp
     630:	sub    rsp,0x40
     634:	mov    QWORD PTR [rsp+0x20],rbx
     639:	mov    QWORD PTR [rsp+0x28],r12
     63e:	mov    QWORD PTR [rsp+0x30],r13
     643:	mov    QWORD PTR [rsp+0x38],r15
     648:	mov    rbx,rdi
     64b:	mov    QWORD PTR [rsp],rsi
     64f:	mov    QWORD PTR [rsp+0x8],rdx
     654:	mov    r15,rdx
     657:	mov    QWORD PTR [rsp+0x10],rcx
     65c:	mov    r13,rcx
     65f:	mov    rcx,r13
     662:	mov    rdx,r15
     665:	mov    rdi,rbx
     668:	call   66d <botlish_fn_6+0x41>
			669: R_X86_64_PLT32	botlish_fn_4-0x4 ; geo_grow<mutarray, int, str>
     66d:	test   rax,rax
     670:	je     6ae <botlish_fn_6+0x82>
     676:	mov    rdx,r15
     679:	test   rdx,0x1
     680:	je     701 <botlish_fn_6+0xd5>
     686:	mov    rsi,QWORD PTR [rax+0x8]
     68a:	mov    rdi,rdx
     68d:	sar    rdi,1
     690:	cmp    rdi,rsi
     693:	jae    70f <botlish_fn_6+0xe3>
     699:	mov    rcx,QWORD PTR [rax+0x18]
     69d:	mov    r12,rax
     6a0:	test   rcx,rcx
     6a3:	jne    6d6 <botlish_fn_6+0xaa>
     6a9:	jmp    71d <botlish_fn_6+0xf1>
     6ae:	xor    rax,rax
     6b1:	mov    rbx,QWORD PTR [rsp+0x20]
     6b6:	mov    r12,QWORD PTR [rsp+0x28]
     6bb:	mov    r13,QWORD PTR [rsp+0x30]
     6c0:	mov    r15,QWORD PTR [rsp+0x38]
     6c5:	add    rsp,0x40
     6c9:	mov    rsp,rbp
     6cc:	pop    rbp
     6cd:	ret
     6ce:	mov    rax,r12
     6d1:	jmp    6e4 <botlish_fn_6+0xb8>
     6d6:	mov    rax,r12
     6d9:	mov    rcx,r13
     6dc:	mov    rdx,QWORD PTR [rax+0x10]
     6e0:	mov    QWORD PTR [rdx+rdi*8],rcx
     6e4:	mov    rbx,QWORD PTR [rsp+0x20]
     6e9:	mov    r12,QWORD PTR [rsp+0x28]
     6ee:	mov    r13,QWORD PTR [rsp+0x30]
     6f3:	mov    r15,QWORD PTR [rsp+0x38]
     6f8:	add    rsp,0x40
     6fc:	mov    rsp,rbp
     6ff:	pop    rbp
     700:	ret
     701:	mov    rcx,r13
     704:	mov    rdi,rbx
     707:	mov    r12,rax
     70a:	jmp    723 <botlish_fn_6+0xf7>
     70f:	mov    rcx,r13
     712:	mov    rdi,rbx
     715:	mov    r12,rax
     718:	jmp    723 <botlish_fn_6+0xf7>
     71d:	mov    rcx,r13
     720:	mov    rdi,rbx
     723:	mov    rsi,r12
     726:	call   72b <botlish_fn_6+0xff>
			727: R_X86_64_PLT32	rt_mutarray_set-0x4
     72b:	test   rax,rax
     72e:	jne    6ce <botlish_fn_6+0xa2>
     734:	jmp    6ae <botlish_fn_6+0x82>

0000000000000739 <botlish_entry_6: geo_append<mutarray, int, str>>:
     739:	push   rbp
     73a:	mov    rbp,rsp
     73d:	mov    rsi,QWORD PTR [rdx]
     740:	mov    r8,QWORD PTR [rdx+0x8]
     744:	mov    rcx,QWORD PTR [rdx+0x10]
     748:	mov    rdx,r8
     74b:	call   750 <botlish_entry_6+0x17>
			74c: R_X86_64_PLT32	botlish_fn_6-0x4 ; geo_append<mutarray, int, str>
     750:	mov    rsp,rbp
     753:	pop    rbp
     754:	ret

0000000000000755 <botlish_fn_7: geo_append<mutarray, int, List[str]>>:
     755:	push   rbp
     756:	mov    rbp,rsp
     759:	sub    rsp,0x40
     75d:	mov    QWORD PTR [rsp+0x20],rbx
     762:	mov    QWORD PTR [rsp+0x28],r12
     767:	mov    QWORD PTR [rsp+0x30],r13
     76c:	mov    QWORD PTR [rsp+0x38],r15
     771:	mov    rbx,rdi
     774:	mov    QWORD PTR [rsp],rsi
     778:	mov    QWORD PTR [rsp+0x8],rdx
     77d:	mov    r15,rdx
     780:	mov    QWORD PTR [rsp+0x10],rcx
     785:	mov    r13,rcx
     788:	mov    rcx,r13
     78b:	mov    rdx,r15
     78e:	mov    rdi,rbx
     791:	call   796 <botlish_fn_7+0x41>
			792: R_X86_64_PLT32	botlish_fn_5-0x4 ; geo_grow<mutarray, int, List[str]>
     796:	test   rax,rax
     799:	je     7d7 <botlish_fn_7+0x82>
     79f:	mov    rdx,r15
     7a2:	test   rdx,0x1
     7a9:	je     82a <botlish_fn_7+0xd5>
     7af:	mov    rsi,QWORD PTR [rax+0x8]
     7b3:	mov    rdi,rdx
     7b6:	sar    rdi,1
     7b9:	cmp    rdi,rsi
     7bc:	jae    838 <botlish_fn_7+0xe3>
     7c2:	mov    rcx,QWORD PTR [rax+0x18]
     7c6:	mov    r12,rax
     7c9:	test   rcx,rcx
     7cc:	jne    7ff <botlish_fn_7+0xaa>
     7d2:	jmp    846 <botlish_fn_7+0xf1>
     7d7:	xor    rax,rax
     7da:	mov    rbx,QWORD PTR [rsp+0x20]
     7df:	mov    r12,QWORD PTR [rsp+0x28]
     7e4:	mov    r13,QWORD PTR [rsp+0x30]
     7e9:	mov    r15,QWORD PTR [rsp+0x38]
     7ee:	add    rsp,0x40
     7f2:	mov    rsp,rbp
     7f5:	pop    rbp
     7f6:	ret
     7f7:	mov    rax,r12
     7fa:	jmp    80d <botlish_fn_7+0xb8>
     7ff:	mov    rax,r12
     802:	mov    rcx,r13
     805:	mov    rdx,QWORD PTR [rax+0x10]
     809:	mov    QWORD PTR [rdx+rdi*8],rcx
     80d:	mov    rbx,QWORD PTR [rsp+0x20]
     812:	mov    r12,QWORD PTR [rsp+0x28]
     817:	mov    r13,QWORD PTR [rsp+0x30]
     81c:	mov    r15,QWORD PTR [rsp+0x38]
     821:	add    rsp,0x40
     825:	mov    rsp,rbp
     828:	pop    rbp
     829:	ret
     82a:	mov    rcx,r13
     82d:	mov    rdi,rbx
     830:	mov    r12,rax
     833:	jmp    84c <botlish_fn_7+0xf7>
     838:	mov    rcx,r13
     83b:	mov    rdi,rbx
     83e:	mov    r12,rax
     841:	jmp    84c <botlish_fn_7+0xf7>
     846:	mov    rcx,r13
     849:	mov    rdi,rbx
     84c:	mov    rsi,r12
     84f:	call   854 <botlish_fn_7+0xff>
			850: R_X86_64_PLT32	rt_mutarray_set-0x4
     854:	test   rax,rax
     857:	jne    7f7 <botlish_fn_7+0xa2>
     85d:	jmp    7d7 <botlish_fn_7+0x82>

0000000000000862 <botlish_entry_7: geo_append<mutarray, int, List[str]>>:
     862:	push   rbp
     863:	mov    rbp,rsp
     866:	mov    rsi,QWORD PTR [rdx]
     869:	mov    r8,QWORD PTR [rdx+0x8]
     86d:	mov    rcx,QWORD PTR [rdx+0x10]
     871:	mov    rdx,r8
     874:	call   879 <botlish_entry_7+0x17>
			875: R_X86_64_PLT32	botlish_fn_7-0x4 ; geo_append<mutarray, int, List[str]>
     879:	mov    rsp,rbp
     87c:	pop    rbp
     87d:	ret

000000000000087e <botlish_fn_8: geo_finish<mutarray, int>>:
     87e:	push   rbp
     87f:	mov    rbp,rsp
     882:	sub    rsp,0x10
     886:	mov    QWORD PTR [rsp],rsi
     88a:	mov    QWORD PTR [rsp+0x8],rdx
     88f:	call   894 <botlish_fn_8+0x16>
			890: R_X86_64_PLT32	rt_mutarray_freeze-0x4
     894:	test   rax,rax
     897:	jne    8a9 <botlish_fn_8+0x2b>
     89d:	xor    rax,rax
     8a0:	add    rsp,0x10
     8a4:	mov    rsp,rbp
     8a7:	pop    rbp
     8a8:	ret
     8a9:	add    rsp,0x10
     8ad:	mov    rsp,rbp
     8b0:	pop    rbp
     8b1:	ret

00000000000008b2 <botlish_entry_8: geo_finish<mutarray, int>>:
     8b2:	push   rbp
     8b3:	mov    rbp,rsp
     8b6:	mov    rsi,QWORD PTR [rdx]
     8b9:	mov    rdx,QWORD PTR [rdx+0x8]
     8bd:	call   8c2 <botlish_entry_8+0x10>
			8be: R_X86_64_PLT32	botlish_fn_8-0x4 ; geo_finish<mutarray, int>
     8c2:	mov    rsp,rbp
     8c5:	pop    rbp
     8c6:	ret
	...

00000000000008c8 <botlish_fn_9: peek<str, int>>:
     8c8:	push   rbp
     8c9:	mov    rbp,rsp
     8cc:	sub    rsp,0x40
     8d0:	mov    QWORD PTR [rsp+0x20],rbx
     8d5:	mov    QWORD PTR [rsp+0x28],r12
     8da:	mov    QWORD PTR [rsp+0x30],r13
     8df:	mov    rbx,rdx
     8e2:	mov    r13,rdi
     8e5:	mov    QWORD PTR [rsp],rsi
     8e9:	mov    QWORD PTR [rsp+0x8],rdx
     8ee:	mov    rdx,QWORD PTR [rsi+0x8]
     8f2:	mov    r12,rsi
     8f5:	shl    rdx,1
     8f8:	mov    rax,rdx
     8fb:	or     rax,0x1
     8ff:	mov    rcx,rbx
     902:	and    rcx,rax
     905:	test   rcx,0x1
     90c:	jne    936 <botlish_fn_9+0x6e>
     912:	or     rdx,0x1
     916:	mov    rsi,rbx
     919:	mov    rdi,r13
     91c:	call   921 <botlish_fn_9+0x59>
			91d: R_X86_64_PLT32	rt_int_cmp-0x4
     921:	mov    ecx,0x2
     926:	test   rax,rax
     929:	cmovge rcx,QWORD PTR [rip+0xd7]        # a08 <botlish_fn_9+0x140>
     931:	jmp    94a <botlish_fn_9+0x82>
     936:	or     rdx,0x1
     93a:	mov    ecx,0x2
     93f:	cmp    rbx,rdx
     942:	cmovge rcx,QWORD PTR [rip+0xbe]        # a08 <botlish_fn_9+0x140>
     94a:	cmp    rcx,0x6
     94e:	je     9de <botlish_fn_9+0x116>
     954:	mov    QWORD PTR [rsp+0x10],0x3
     95d:	test   rbx,0x1
     964:	je     97c <botlish_fn_9+0xb4>
     96a:	mov    rcx,rbx
     96d:	add    rcx,0x2
     971:	seto   al
     974:	test   al,al
     976:	je     98f <botlish_fn_9+0xc7>
     97c:	mov    edx,0x3
     981:	mov    rsi,rbx
     984:	mov    rdi,r13
     987:	call   98c <botlish_fn_9+0xc4>
			988: R_X86_64_PLT32	rt_int_add-0x4
     98c:	mov    rcx,rax
     98f:	mov    QWORD PTR [rsp+0x10],rcx
     994:	mov    rdx,rbx
     997:	mov    rsi,r12
     99a:	mov    rdi,r13
     99d:	call   9a2 <botlish_fn_9+0xda>
			99e: R_X86_64_PLT32	rt_substr-0x4
     9a2:	test   rax,rax
     9a5:	jne    9c6 <botlish_fn_9+0xfe>
     9ab:	xor    rax,rax
     9ae:	mov    rbx,QWORD PTR [rsp+0x20]
     9b3:	mov    r12,QWORD PTR [rsp+0x28]
     9b8:	mov    r13,QWORD PTR [rsp+0x30]
     9bd:	add    rsp,0x40
     9c1:	mov    rsp,rbp
     9c4:	pop    rbp
     9c5:	ret
     9c6:	mov    rbx,QWORD PTR [rsp+0x20]
     9cb:	mov    r12,QWORD PTR [rsp+0x28]
     9d0:	mov    r13,QWORD PTR [rsp+0x30]
     9d5:	add    rsp,0x40
     9d9:	mov    rsp,rbp
     9dc:	pop    rbp
     9dd:	ret
     9de:	mov    rdi,r13
     9e1:	mov    rax,QWORD PTR [rdi+0x10]
     9e5:	mov    rax,QWORD PTR [rax+0x8]
     9e9:	mov    rbx,QWORD PTR [rsp+0x20]
     9ee:	mov    r12,QWORD PTR [rsp+0x28]
     9f3:	mov    r13,QWORD PTR [rsp+0x30]
     9f8:	add    rsp,0x40
     9fc:	mov    rsp,rbp
     9ff:	pop    rbp
     a00:	ret
     a01:	add    BYTE PTR [rax],al
     a03:	add    BYTE PTR [rax],al
     a05:	add    BYTE PTR [rax],al
     a07:	add    BYTE PTR [rsi],al
     a09:	add    BYTE PTR [rax],al
     a0b:	add    BYTE PTR [rax],al
     a0d:	add    BYTE PTR [rax],al
	...

0000000000000a10 <botlish_entry_9: peek<str, int>>:
     a10:	push   rbp
     a11:	mov    rbp,rsp
     a14:	mov    rsi,QWORD PTR [rdx]
     a17:	mov    rdx,QWORD PTR [rdx+0x8]
     a1b:	call   a20 <botlish_entry_9+0x10>
			a1c: R_X86_64_PLT32	botlish_fn_9-0x4 ; peek<str, int>
     a20:	mov    rsp,rbp
     a23:	pop    rbp
     a24:	ret
     a25:	add    BYTE PTR [rax],al
	...

0000000000000a28 <botlish_fn_10: quote_at?<str, int>>:
     a28:	push   rbp
     a29:	mov    rbp,rsp
     a2c:	sub    rsp,0x20
     a30:	mov    QWORD PTR [rsp],rbx
     a34:	mov    QWORD PTR [rsp+0x8],r12
     a39:	mov    QWORD PTR [rsp+0x10],r13
     a3e:	mov    rbx,rdx
     a41:	mov    r13,rdi
     a44:	mov    rdx,QWORD PTR [rsi+0x8]
     a48:	mov    r12,rsi
     a4b:	shl    rdx,1
     a4e:	mov    rax,rdx
     a51:	or     rax,0x1
     a55:	mov    rcx,rbx
     a58:	and    rcx,rax
     a5b:	test   rcx,0x1
     a62:	jne    a8c <botlish_fn_10+0x64>
     a68:	or     rdx,0x1
     a6c:	mov    rsi,rbx
     a6f:	mov    rdi,r13
     a72:	call   a77 <botlish_fn_10+0x4f>
			a73: R_X86_64_PLT32	rt_int_cmp-0x4
     a77:	mov    ecx,0x2
     a7c:	test   rax,rax
     a7f:	cmovl  rcx,QWORD PTR [rip+0xa1]        # b28 <botlish_fn_10+0x100>
     a87:	jmp    aa3 <botlish_fn_10+0x7b>
     a8c:	or     rdx,0x1
     a90:	mov    ecx,0x2
     a95:	mov    rax,rbx
     a98:	cmp    rax,rdx
     a9b:	cmovl  rcx,QWORD PTR [rip+0x85]        # b28 <botlish_fn_10+0x100>
     aa3:	mov    eax,0x6
     aa8:	cmp    rcx,0x6
     aac:	je     abf <botlish_fn_10+0x97>
     ab2:	mov    eax,0x2
     ab7:	mov    r12,rax
     aba:	jmp    b0c <botlish_fn_10+0xe4>
     abf:	mov    rdi,r13
     ac2:	mov    rsi,r12
     ac5:	mov    r12,rax
     ac8:	mov    rdx,rbx
     acb:	call   ad0 <botlish_fn_10+0xa8>
			acc: R_X86_64_PLT32	rt_str_char_at-0x4
     ad0:	test   rax,rax
     ad3:	jne    af3 <botlish_fn_10+0xcb>
     ad9:	xor    rax,rax
     adc:	mov    rbx,QWORD PTR [rsp]
     ae0:	mov    r12,QWORD PTR [rsp+0x8]
     ae5:	mov    r13,QWORD PTR [rsp+0x10]
     aea:	add    rsp,0x20
     aee:	mov    rsp,rbp
     af1:	pop    rbp
     af2:	ret
     af3:	cmp    rax,0x114
     af9:	je     b09 <botlish_fn_10+0xe1>
     aff:	mov    eax,0x2
     b04:	jmp    b0c <botlish_fn_10+0xe4>
     b09:	mov    rax,r12
     b0c:	mov    rbx,QWORD PTR [rsp]
     b10:	mov    r12,QWORD PTR [rsp+0x8]
     b15:	mov    r13,QWORD PTR [rsp+0x10]
     b1a:	add    rsp,0x20
     b1e:	mov    rsp,rbp
     b21:	pop    rbp
     b22:	ret
     b23:	add    BYTE PTR [rax],al
     b25:	add    BYTE PTR [rax],al
     b27:	add    BYTE PTR [rsi],al
     b29:	add    BYTE PTR [rax],al
     b2b:	add    BYTE PTR [rax],al
     b2d:	add    BYTE PTR [rax],al
	...

0000000000000b30 <botlish_entry_10: quote_at?<str, int>>:
     b30:	push   rbp
     b31:	mov    rbp,rsp
     b34:	mov    rsi,QWORD PTR [rdx]
     b37:	mov    rdx,QWORD PTR [rdx+0x8]
     b3b:	call   b40 <botlish_entry_10+0x10>
			b3c: R_X86_64_PLT32	botlish_fn_10-0x4 ; quote_at?<str, int>
     b40:	mov    rsp,rbp
     b43:	pop    rbp
     b44:	ret
     b45:	add    BYTE PTR [rax],al
	...

0000000000000b48 <botlish_fn_11: scan_unquoted<str, int, int>>:
     b48:	push   rbp
     b49:	mov    rbp,rsp
     b4c:	sub    rsp,0x40
     b50:	mov    QWORD PTR [rsp+0x20],rbx
     b55:	mov    QWORD PTR [rsp+0x28],r12
     b5a:	mov    QWORD PTR [rsp+0x30],r13
     b5f:	mov    QWORD PTR [rsp+0x38],r14
     b64:	mov    r13,rdi
     b67:	mov    QWORD PTR [rsp+0x18],0x0
     b70:	mov    QWORD PTR [rsp],rsi
     b74:	mov    r12,rsi
     b77:	mov    QWORD PTR [rsp+0x8],rdx
     b7c:	mov    rbx,rdx
     b7f:	mov    QWORD PTR [rsp+0x10],rcx
     b84:	mov    rax,r12
     b87:	mov    rsi,rcx
     b8a:	mov    rdx,QWORD PTR [rax+0x8]
     b8e:	mov    r12,rax
     b91:	shl    rdx,1
     b94:	or     rdx,0x1
     b98:	mov    rax,rsi
     b9b:	and    rax,rdx
     b9e:	mov    r14,rsi
     ba1:	test   rax,0x1
     ba7:	jne    bcd <botlish_fn_11+0x85>
     bad:	mov    rsi,r14
     bb0:	mov    rdi,r13
     bb3:	call   bb8 <botlish_fn_11+0x70>
			bb4: R_X86_64_PLT32	rt_int_cmp-0x4
     bb8:	mov    ecx,0x2
     bbd:	test   rax,rax
     bc0:	cmovl  rcx,QWORD PTR [rip+0x138]        # d00 <botlish_fn_11+0x1b8>
     bc8:	jmp    be0 <botlish_fn_11+0x98>
     bcd:	mov    ecx,0x2
     bd2:	mov    rsi,r14
     bd5:	cmp    rsi,rdx
     bd8:	cmovl  rcx,QWORD PTR [rip+0x120]        # d00 <botlish_fn_11+0x1b8>
     be0:	cmp    rcx,0x6
     be4:	je     bf8 <botlish_fn_11+0xb0>
     bea:	mov    rdx,rbx
     bed:	mov    rsi,r12
     bf0:	mov    rdi,r13
     bf3:	jmp    ca3 <botlish_fn_11+0x15b>
     bf8:	mov    rdx,r14
     bfb:	mov    rsi,r12
     bfe:	mov    rdi,r13
     c01:	call   c06 <botlish_fn_11+0xbe>
			c02: R_X86_64_PLT32	rt_str_char_at-0x4
     c06:	test   rax,rax
     c09:	je     cba <botlish_fn_11+0x172>
     c0f:	cmp    rax,0x164
     c15:	jne    c23 <botlish_fn_11+0xdb>
     c1b:	mov    rdx,rbx
     c1e:	jmp    c9d <botlish_fn_11+0x155>
     c23:	cmp    rax,0x54
     c27:	jne    c35 <botlish_fn_11+0xed>
     c2d:	mov    rdx,rbx
     c30:	jmp    c9d <botlish_fn_11+0x155>
     c35:	mov    QWORD PTR [rsp+0x18],0x3
     c3e:	mov    rsi,r14
     c41:	test   rsi,0x1
     c48:	je     c6b <botlish_fn_11+0x123>
     c4e:	mov    rsi,r14
     c51:	mov    rax,rsi
     c54:	add    rax,0x2
     c58:	seto   cl
     c5b:	test   cl,cl
     c5d:	jne    c6b <botlish_fn_11+0x123>
     c63:	mov    rsi,r12
     c66:	jmp    c7e <botlish_fn_11+0x136>
     c6b:	mov    edx,0x3
     c70:	mov    rsi,r14
     c73:	mov    rdi,r13
     c76:	call   c7b <botlish_fn_11+0x133>
			c77: R_X86_64_PLT32	rt_int_add-0x4
     c7b:	mov    rsi,r12
     c7e:	mov    rsi,r12
     c81:	mov    QWORD PTR [rsp],rsi
     c85:	mov    rdx,rbx
     c88:	mov    QWORD PTR [rsp+0x8],rdx
     c8d:	mov    QWORD PTR [rsp+0x10],rax
     c92:	mov    rsi,rax
     c95:	mov    rax,r12
     c98:	jmp    b8a <botlish_fn_11+0x42>
     c9d:	mov    rsi,r12
     ca0:	mov    rdi,r13
     ca3:	mov    rsi,r12
     ca6:	mov    rdi,r13
     ca9:	mov    rcx,r14
     cac:	call   cb1 <botlish_fn_11+0x169>
			cad: R_X86_64_PLT32	rt_substr-0x4
     cb1:	test   rax,rax
     cb4:	jne    cdd <botlish_fn_11+0x195>
     cba:	xor    rdx,rdx
     cbd:	mov    rax,rdx
     cc0:	mov    rbx,QWORD PTR [rsp+0x20]
     cc5:	mov    r12,QWORD PTR [rsp+0x28]
     cca:	mov    r13,QWORD PTR [rsp+0x30]
     ccf:	mov    r14,QWORD PTR [rsp+0x38]
     cd4:	add    rsp,0x40
     cd8:	mov    rsp,rbp
     cdb:	pop    rbp
     cdc:	ret
     cdd:	mov    rdx,r14
     ce0:	mov    rbx,QWORD PTR [rsp+0x20]
     ce5:	mov    r12,QWORD PTR [rsp+0x28]
     cea:	mov    r13,QWORD PTR [rsp+0x30]
     cef:	mov    r14,QWORD PTR [rsp+0x38]
     cf4:	add    rsp,0x40
     cf8:	mov    rsp,rbp
     cfb:	pop    rbp
     cfc:	ret
     cfd:	add    BYTE PTR [rax],al
     cff:	add    BYTE PTR [rsi],al
     d01:	add    BYTE PTR [rax],al
     d03:	add    BYTE PTR [rax],al
     d05:	add    BYTE PTR [rax],al
	...

0000000000000d08 <botlish_entry_11: scan_unquoted<str, int, int>>:
     d08:	push   rbp
     d09:	mov    rbp,rsp
     d0c:	ud2

0000000000000d0e <botlish_fn_12: scan_quoted<str, int, str>>:
     d0e:	push   rbp
     d0f:	mov    rbp,rsp
     d12:	sub    rsp,0xb0
     d19:	mov    QWORD PTR [rsp+0x80],rbx
     d21:	mov    QWORD PTR [rsp+0x88],r12
     d29:	mov    QWORD PTR [rsp+0x90],r13
     d31:	mov    QWORD PTR [rsp+0x98],r14
     d39:	mov    QWORD PTR [rsp+0xa0],r15
     d41:	mov    r15,rdi
     d44:	mov    QWORD PTR [rsp+0x18],0x0
     d4d:	mov    QWORD PTR [rsp+0x20],0x0
     d56:	mov    QWORD PTR [rsp],rsi
     d5a:	mov    QWORD PTR [rsp+0x8],rdx
     d5f:	mov    QWORD PTR [rsp+0x10],rcx
     d64:	mov    r13,rcx
     d67:	lea    r12,[rsp+0x58]
     d6c:	mov    rbx,rsi
     d6f:	mov    QWORD PTR [rsp+0x78],rdx
     d74:	mov    rdx,QWORD PTR [rsp+0x78]
     d79:	mov    rsi,rbx
     d7c:	mov    rdi,r15
     d7f:	call   d84 <botlish_fn_12+0x76>
			d80: R_X86_64_PLT32	botlish_fn_9-0x4 ; peek<str, int>
     d84:	test   rax,rax
     d87:	je     1023 <botlish_fn_12+0x315>
     d8d:	mov    QWORD PTR [rsp+0x18],rax
     d92:	mov    r14,rax
     d95:	mov    rdx,QWORD PTR [rsp+0x78]
     d9a:	mov    rsi,rbx
     d9d:	mov    rdi,r15
     da0:	call   da5 <botlish_fn_12+0x97>
			da1: R_X86_64_PLT32	botlish_fn_10-0x4 ; quote_at?<str, int>
     da5:	test   rax,rax
     da8:	je     1023 <botlish_fn_12+0x315>
     dae:	cmp    rax,0x6
     db2:	je     e6b <botlish_fn_12+0x15d>
     db8:	mov    QWORD PTR [rsp+0x20],0x3
     dc1:	mov    rsi,QWORD PTR [rsp+0x78]
     dc6:	test   rsi,0x1
     dcd:	je     df7 <botlish_fn_12+0xe9>
     dd3:	mov    rsi,QWORD PTR [rsp+0x78]
     dd8:	mov    rcx,rsi
     ddb:	add    rcx,0x2
     ddf:	seto   dl
     de2:	test   dl,dl
     de4:	jne    df7 <botlish_fn_12+0xe9>
     dea:	mov    rsi,rcx
     ded:	mov    QWORD PTR [rsp+0x78],rcx
     df2:	jmp    e11 <botlish_fn_12+0x103>
     df7:	mov    edx,0x3
     dfc:	mov    rsi,QWORD PTR [rsp+0x78]
     e01:	mov    rdi,r15
     e04:	call   e09 <botlish_fn_12+0xfb>
			e05: R_X86_64_PLT32	rt_int_add-0x4
     e09:	mov    rsi,rax
     e0c:	mov    QWORD PTR [rsp+0x78],rax
     e11:	mov    QWORD PTR [rsp+0x8],rsi
     e16:	mov    QWORD PTR [rsp+0x58],0x0
     e1f:	mov    QWORD PTR [rsp+0x60],r13
     e24:	mov    QWORD PTR [rsp+0x68],0x0
     e2d:	mov    QWORD PTR [rsp+0x70],r14
     e32:	mov    esi,0x2
     e37:	mov    edx,0x4
     e3c:	mov    rcx,r12
     e3f:	mov    rdi,r15
     e42:	call   e47 <botlish_fn_12+0x139>
			e43: R_X86_64_PLT32	rt_construct-0x4
     e47:	test   rax,rax
     e4a:	je     1023 <botlish_fn_12+0x315>
     e50:	mov    QWORD PTR [rsp],rbx
     e54:	mov    rsi,QWORD PTR [rsp+0x78]
     e59:	mov    QWORD PTR [rsp+0x8],rsi
     e5e:	mov    QWORD PTR [rsp+0x10],rax
     e63:	mov    r13,rax
     e66:	jmp    d74 <botlish_fn_12+0x66>
     e6b:	mov    QWORD PTR [rsp+0x20],0x3
     e74:	mov    rsi,QWORD PTR [rsp+0x78]
     e79:	test   rsi,0x1
     e80:	je     e9d <botlish_fn_12+0x18f>
     e86:	mov    rsi,QWORD PTR [rsp+0x78]
     e8b:	mov    rdx,rsi
     e8e:	add    rdx,0x2
     e92:	seto   al
     e95:	test   al,al
     e97:	je     eb2 <botlish_fn_12+0x1a4>
     e9d:	mov    edx,0x3
     ea2:	mov    rsi,QWORD PTR [rsp+0x78]
     ea7:	mov    rdi,r15
     eaa:	call   eaf <botlish_fn_12+0x1a1>
			eab: R_X86_64_PLT32	rt_int_add-0x4
     eaf:	mov    rdx,rax
     eb2:	mov    rsi,rbx
     eb5:	mov    rdi,r15
     eb8:	call   ebd <botlish_fn_12+0x1af>
			eb9: R_X86_64_PLT32	botlish_fn_10-0x4 ; quote_at?<str, int>
     ebd:	test   rax,rax
     ec0:	je     1023 <botlish_fn_12+0x315>
     ec6:	cmp    rax,0x6
     eca:	je     f89 <botlish_fn_12+0x27b>
     ed0:	xor    rsi,rsi
     ed3:	lea    rcx,[rsp+0x48]
     ed8:	mov    QWORD PTR [rsp+0x48],0x0
     ee1:	mov    QWORD PTR [rsp+0x50],r13
     ee6:	mov    edx,0x2
     eeb:	mov    rdi,r15
     eee:	call   ef3 <botlish_fn_12+0x1e5>
			eef: R_X86_64_PLT32	rt_construct-0x4
     ef3:	test   rax,rax
     ef6:	je     1023 <botlish_fn_12+0x315>
     efc:	mov    QWORD PTR [rsp],rax
     f00:	mov    r12,rax
     f03:	mov    QWORD PTR [rsp+0x10],0x3
     f0c:	mov    rsi,QWORD PTR [rsp+0x78]
     f11:	test   rsi,0x1
     f18:	je     f3d <botlish_fn_12+0x22f>
     f1e:	mov    rsi,QWORD PTR [rsp+0x78]
     f23:	mov    rdx,rsi
     f26:	add    rdx,0x2
     f2a:	seto   al
     f2d:	test   al,al
     f2f:	jne    f3d <botlish_fn_12+0x22f>
     f35:	mov    rax,r12
     f38:	jmp    f55 <botlish_fn_12+0x247>
     f3d:	mov    edx,0x3
     f42:	mov    rsi,QWORD PTR [rsp+0x78]
     f47:	mov    rdi,r15
     f4a:	call   f4f <botlish_fn_12+0x241>
			f4b: R_X86_64_PLT32	rt_int_add-0x4
     f4f:	mov    rdx,rax
     f52:	mov    rax,r12
     f55:	mov    rbx,QWORD PTR [rsp+0x80]
     f5d:	mov    r12,QWORD PTR [rsp+0x88]
     f65:	mov    r13,QWORD PTR [rsp+0x90]
     f6d:	mov    r14,QWORD PTR [rsp+0x98]
     f75:	mov    r15,QWORD PTR [rsp+0xa0]
     f7d:	add    rsp,0xb0
     f84:	mov    rsp,rbp
     f87:	pop    rbp
     f88:	ret
     f89:	mov    QWORD PTR [rsp+0x20],0x5
     f92:	mov    rsi,QWORD PTR [rsp+0x78]
     f97:	test   rsi,0x1
     f9e:	je     fc8 <botlish_fn_12+0x2ba>
     fa4:	mov    rsi,QWORD PTR [rsp+0x78]
     fa9:	mov    rcx,rsi
     fac:	add    rcx,0x4
     fb0:	seto   al
     fb3:	test   al,al
     fb5:	jne    fc8 <botlish_fn_12+0x2ba>
     fbb:	mov    rsi,rcx
     fbe:	mov    QWORD PTR [rsp+0x78],rcx
     fc3:	jmp    fe2 <botlish_fn_12+0x2d4>
     fc8:	mov    edx,0x5
     fcd:	mov    rsi,QWORD PTR [rsp+0x78]
     fd2:	mov    rdi,r15
     fd5:	call   fda <botlish_fn_12+0x2cc>
			fd6: R_X86_64_PLT32	rt_int_add-0x4
     fda:	mov    rsi,rax
     fdd:	mov    QWORD PTR [rsp+0x78],rax
     fe2:	mov    QWORD PTR [rsp+0x8],rsi
     fe7:	lea    rcx,[rsp+0x28]
     fec:	mov    QWORD PTR [rsp+0x28],0x0
     ff5:	mov    QWORD PTR [rsp+0x30],r13
     ffa:	mov    QWORD PTR [rsp+0x38],0x0
    1003:	mov    QWORD PTR [rsp+0x40],r14
    1008:	mov    esi,0x2
    100d:	mov    edx,0x4
    1012:	mov    rdi,r15
    1015:	call   101a <botlish_fn_12+0x30c>
			1016: R_X86_64_PLT32	rt_construct-0x4
    101a:	test   rax,rax
    101d:	jne    105d <botlish_fn_12+0x34f>
    1023:	xor    rdx,rdx
    1026:	mov    rax,rdx
    1029:	mov    rbx,QWORD PTR [rsp+0x80]
    1031:	mov    r12,QWORD PTR [rsp+0x88]
    1039:	mov    r13,QWORD PTR [rsp+0x90]
    1041:	mov    r14,QWORD PTR [rsp+0x98]
    1049:	mov    r15,QWORD PTR [rsp+0xa0]
    1051:	add    rsp,0xb0
    1058:	mov    rsp,rbp
    105b:	pop    rbp
    105c:	ret
    105d:	mov    QWORD PTR [rsp],rbx
    1061:	mov    rsi,QWORD PTR [rsp+0x78]
    1066:	mov    QWORD PTR [rsp+0x8],rsi
    106b:	mov    QWORD PTR [rsp+0x10],rax
    1070:	mov    r13,rax
    1073:	jmp    d74 <botlish_fn_12+0x66>

0000000000001078 <botlish_entry_12: scan_quoted<str, int, str>>:
    1078:	push   rbp
    1079:	mov    rbp,rsp
    107c:	ud2

000000000000107e <botlish_fn_13: scan_field<str, int>>:
    107e:	push   rbp
    107f:	mov    rbp,rsp
    1082:	sub    rsp,0x40
    1086:	mov    QWORD PTR [rsp+0x20],rbx
    108b:	mov    QWORD PTR [rsp+0x28],r12
    1090:	mov    QWORD PTR [rsp+0x30],r13
    1095:	mov    r12,rdi
    1098:	mov    r13,rdx
    109b:	mov    QWORD PTR [rsp+0x10],0x0
    10a4:	mov    QWORD PTR [rsp],rsi
    10a8:	mov    rbx,rsi
    10ab:	mov    QWORD PTR [rsp+0x8],rdx
    10b0:	mov    rdx,r13
    10b3:	mov    rsi,rbx
    10b6:	mov    rdi,r12
    10b9:	call   10be <botlish_fn_13+0x40>
			10ba: R_X86_64_PLT32	botlish_fn_10-0x4 ; quote_at?<str, int>
    10be:	test   rax,rax
    10c1:	je     1172 <botlish_fn_13+0xf4>
    10c7:	cmp    rax,0x6
    10cb:	je     1103 <botlish_fn_13+0x85>
    10d1:	mov    rcx,r13
    10d4:	mov    rsi,rbx
    10d7:	mov    rdi,r12
    10da:	mov    rdx,rcx
    10dd:	call   10e2 <botlish_fn_13+0x64>
			10de: R_X86_64_PLT32	botlish_fn_11-0x4 ; scan_unquoted<str, int, int>
    10e2:	test   rax,rax
    10e5:	je     1172 <botlish_fn_13+0xf4>
    10eb:	mov    rbx,QWORD PTR [rsp+0x20]
    10f0:	mov    r12,QWORD PTR [rsp+0x28]
    10f5:	mov    r13,QWORD PTR [rsp+0x30]
    10fa:	add    rsp,0x40
    10fe:	mov    rsp,rbp
    1101:	pop    rbp
    1102:	ret
    1103:	mov    rcx,r13
    1106:	mov    QWORD PTR [rsp+0x10],0x3
    110f:	test   rcx,0x1
    1116:	jne    1124 <botlish_fn_13+0xa6>
    111c:	mov    r13,rcx
    111f:	jmp    1139 <botlish_fn_13+0xbb>
    1124:	mov    rdx,rcx
    1127:	add    rdx,0x2
    112b:	mov    r13,rcx
    112e:	seto   al
    1131:	test   al,al
    1133:	je     114c <botlish_fn_13+0xce>
    1139:	mov    edx,0x3
    113e:	mov    rsi,r13
    1141:	mov    rdi,r12
    1144:	call   1149 <botlish_fn_13+0xcb>
			1145: R_X86_64_PLT32	rt_int_add-0x4
    1149:	mov    rdx,rax
    114c:	mov    QWORD PTR [rsp+0x8],rdx
    1151:	mov    rdi,r12
    1154:	mov    rax,QWORD PTR [rdi+0x10]
    1158:	mov    rcx,QWORD PTR [rax+0x8]
    115c:	mov    QWORD PTR [rsp+0x10],rcx
    1161:	mov    rsi,rbx
    1164:	call   1169 <botlish_fn_13+0xeb>
			1165: R_X86_64_PLT32	botlish_fn_12-0x4 ; scan_quoted<str, int, str>
    1169:	test   rax,rax
    116c:	jne    1190 <botlish_fn_13+0x112>
    1172:	xor    rdx,rdx
    1175:	mov    rax,rdx
    1178:	mov    rbx,QWORD PTR [rsp+0x20]
    117d:	mov    r12,QWORD PTR [rsp+0x28]
    1182:	mov    r13,QWORD PTR [rsp+0x30]
    1187:	add    rsp,0x40
    118b:	mov    rsp,rbp
    118e:	pop    rbp
    118f:	ret
    1190:	mov    rbx,QWORD PTR [rsp+0x20]
    1195:	mov    r12,QWORD PTR [rsp+0x28]
    119a:	mov    r13,QWORD PTR [rsp+0x30]
    119f:	add    rsp,0x40
    11a3:	mov    rsp,rbp
    11a6:	pop    rbp
    11a7:	ret

00000000000011a8 <botlish_entry_13: scan_field<str, int>>:
    11a8:	push   rbp
    11a9:	mov    rbp,rsp
    11ac:	ud2
	...

00000000000011b0 <botlish_fn_14: scan_record_rest<str, int, mutarray, int>>:
    11b0:	push   rbp
    11b1:	mov    rbp,rsp
    11b4:	sub    rsp,0x60
    11b8:	mov    QWORD PTR [rsp+0x30],rbx
    11bd:	mov    QWORD PTR [rsp+0x38],r12
    11c2:	mov    QWORD PTR [rsp+0x40],r13
    11c7:	mov    QWORD PTR [rsp+0x48],r14
    11cc:	mov    QWORD PTR [rsp+0x50],r15
    11d1:	mov    r13,rdi
    11d4:	mov    QWORD PTR [rsp+0x20],0x0
    11dd:	mov    QWORD PTR [rsp],rsi
    11e1:	mov    QWORD PTR [rsp+0x8],rdx
    11e6:	mov    QWORD PTR [rsp+0x10],rcx
    11eb:	mov    QWORD PTR [rsp+0x18],r8
    11f0:	mov    rbx,rsi
    11f3:	mov    r12,rdx
    11f6:	mov    r14,r8
    11f9:	mov    r15,rcx
    11fc:	mov    rdx,QWORD PTR [rbx+0x8]
    1200:	shl    rdx,1
    1203:	or     rdx,0x1
    1207:	mov    rax,r12
    120a:	and    rax,rdx
    120d:	test   rax,0x1
    1213:	jne    1239 <botlish_fn_14+0x89>
    1219:	mov    rsi,r12
    121c:	mov    rdi,r13
    121f:	call   1224 <botlish_fn_14+0x74>
			1220: R_X86_64_PLT32	rt_int_cmp-0x4
    1224:	mov    ecx,0x2
    1229:	test   rax,rax
    122c:	cmovl  rcx,QWORD PTR [rip+0x24c]        # 1480 <botlish_fn_14+0x2d0>
    1234:	jmp    124c <botlish_fn_14+0x9c>
    1239:	mov    ecx,0x2
    123e:	mov    rax,r12
    1241:	cmp    rax,rdx
    1244:	cmovl  rcx,QWORD PTR [rip+0x234]        # 1480 <botlish_fn_14+0x2d0>
    124c:	cmp    rcx,0x6
    1250:	je     1264 <botlish_fn_14+0xb4>
    1256:	mov    rdx,r14
    1259:	mov    rsi,r15
    125c:	mov    rdi,r13
    125f:	jmp    129a <botlish_fn_14+0xea>
    1264:	mov    rdx,r12
    1267:	mov    rsi,rbx
    126a:	mov    rdi,r13
    126d:	call   1272 <botlish_fn_14+0xc2>
			126e: R_X86_64_PLT32	rt_str_char_at-0x4
    1272:	test   rax,rax
    1275:	je     13da <botlish_fn_14+0x22a>
    127b:	cmp    rax,0x164
    1281:	je     1359 <botlish_fn_14+0x1a9>
    1287:	cmp    rax,0x54
    128b:	je     12d0 <botlish_fn_14+0x120>
    1291:	mov    rdx,r14
    1294:	mov    rsi,r15
    1297:	mov    rdi,r13
    129a:	mov    rdi,r13
    129d:	call   12a2 <botlish_fn_14+0xf2>
			129e: R_X86_64_PLT32	botlish_fn_8-0x4 ; geo_finish<mutarray, int>
    12a2:	test   rax,rax
    12a5:	je     13da <botlish_fn_14+0x22a>
    12ab:	mov    rdx,r12
    12ae:	mov    rbx,QWORD PTR [rsp+0x30]
    12b3:	mov    r12,QWORD PTR [rsp+0x38]
    12b8:	mov    r13,QWORD PTR [rsp+0x40]
    12bd:	mov    r14,QWORD PTR [rsp+0x48]
    12c2:	mov    r15,QWORD PTR [rsp+0x50]
    12c7:	add    rsp,0x60
    12cb:	mov    rsp,rbp
    12ce:	pop    rbp
    12cf:	ret
    12d0:	mov    rdx,r14
    12d3:	mov    rsi,r15
    12d6:	mov    rdi,r13
    12d9:	call   12de <botlish_fn_14+0x12e>
			12da: R_X86_64_PLT32	botlish_fn_8-0x4 ; geo_finish<mutarray, int>
    12de:	test   rax,rax
    12e1:	je     13da <botlish_fn_14+0x22a>
    12e7:	mov    QWORD PTR [rsp],rax
    12eb:	mov    r14,rax
    12ee:	mov    QWORD PTR [rsp+0x10],0x3
    12f7:	mov    rdx,r12
    12fa:	test   rdx,0x1
    1301:	je     1321 <botlish_fn_14+0x171>
    1307:	mov    rdx,r12
    130a:	add    rdx,0x2
    130e:	seto   al
    1311:	test   al,al
    1313:	jne    1321 <botlish_fn_14+0x171>
    1319:	mov    rax,r14
    131c:	jmp    1337 <botlish_fn_14+0x187>
    1321:	mov    edx,0x3
    1326:	mov    rsi,r12
    1329:	mov    rdi,r13
    132c:	call   1331 <botlish_fn_14+0x181>
			132d: R_X86_64_PLT32	rt_int_add-0x4
    1331:	mov    rdx,rax
    1334:	mov    rax,r14
    1337:	mov    rbx,QWORD PTR [rsp+0x30]
    133c:	mov    r12,QWORD PTR [rsp+0x38]
    1341:	mov    r13,QWORD PTR [rsp+0x40]
    1346:	mov    r14,QWORD PTR [rsp+0x48]
    134b:	mov    r15,QWORD PTR [rsp+0x50]
    1350:	add    rsp,0x60
    1354:	mov    rsp,rbp
    1357:	pop    rbp
    1358:	ret
    1359:	mov    rsi,r12
    135c:	mov    edx,0x3
    1361:	mov    r12,rdx
    1364:	mov    QWORD PTR [rsp+0x20],0x3
    136d:	test   rsi,0x1
    1374:	je     138c <botlish_fn_14+0x1dc>
    137a:	mov    rdx,rsi
    137d:	add    rdx,0x2
    1381:	seto   al
    1384:	test   al,al
    1386:	je     139a <botlish_fn_14+0x1ea>
    138c:	mov    rdx,r12
    138f:	mov    rdi,r13
    1392:	call   1397 <botlish_fn_14+0x1e7>
			1393: R_X86_64_PLT32	rt_int_add-0x4
    1397:	mov    rdx,rax
    139a:	mov    QWORD PTR [rsp+0x8],rdx
    139f:	mov    rsi,rbx
    13a2:	mov    rdi,r13
    13a5:	call   13aa <botlish_fn_14+0x1fa>
			13a6: R_X86_64_PLT32	botlish_fn_13-0x4 ; scan_field<str, int>
    13aa:	test   rax,rax
    13ad:	je     13da <botlish_fn_14+0x22a>
    13b3:	mov    QWORD PTR [rsp+0x8],rax
    13b8:	mov    rcx,rax
    13bb:	mov    QWORD PTR [rsp+0x20],rdx
    13c0:	mov    rsi,r15
    13c3:	mov    r15,rdx
    13c6:	mov    rdx,r14
    13c9:	mov    rdi,r13
    13cc:	call   13d1 <botlish_fn_14+0x221>
			13cd: R_X86_64_PLT32	botlish_fn_6-0x4 ; geo_append<mutarray, int, str>
    13d1:	test   rax,rax
    13d4:	jne    1402 <botlish_fn_14+0x252>
    13da:	xor    rdx,rdx
    13dd:	mov    rax,rdx
    13e0:	mov    rbx,QWORD PTR [rsp+0x30]
    13e5:	mov    r12,QWORD PTR [rsp+0x38]
    13ea:	mov    r13,QWORD PTR [rsp+0x40]
    13ef:	mov    r14,QWORD PTR [rsp+0x48]
    13f4:	mov    r15,QWORD PTR [rsp+0x50]
    13f9:	add    rsp,0x60
    13fd:	mov    rsp,rbp
    1400:	pop    rbp
    1401:	ret
    1402:	mov    QWORD PTR [rsp+0x8],rax
    1407:	mov    QWORD PTR [rsp+0x28],rax
    140c:	mov    QWORD PTR [rsp+0x10],0x3
    1415:	mov    rdx,r14
    1418:	test   rdx,0x1
    141f:	jne    1430 <botlish_fn_14+0x280>
    1425:	mov    rdx,r12
    1428:	mov    rsi,r14
    142b:	jmp    144b <botlish_fn_14+0x29b>
    1430:	mov    rdx,r14
    1433:	mov    rax,rdx
    1436:	add    rax,0x2
    143a:	seto   cl
    143d:	test   cl,cl
    143f:	je     1453 <botlish_fn_14+0x2a3>
    1445:	mov    rdx,r12
    1448:	mov    rsi,r14
    144b:	mov    rdi,r13
    144e:	call   1453 <botlish_fn_14+0x2a3>
			144f: R_X86_64_PLT32	rt_int_add-0x4
    1453:	mov    QWORD PTR [rsp],rbx
    1457:	mov    rdx,r15
    145a:	mov    QWORD PTR [rsp+0x8],rdx
    145f:	mov    rcx,QWORD PTR [rsp+0x28]
    1464:	mov    QWORD PTR [rsp+0x10],rcx
    1469:	mov    QWORD PTR [rsp+0x18],rax
    146e:	mov    r12,rdx
    1471:	mov    r14,rax
    1474:	mov    r15,rcx
    1477:	jmp    11fc <botlish_fn_14+0x4c>
    147c:	add    BYTE PTR [rax],al
    147e:	add    BYTE PTR [rax],al
    1480:	(bad)
    1481:	add    BYTE PTR [rax],al
    1483:	add    BYTE PTR [rax],al
    1485:	add    BYTE PTR [rax],al
	...

0000000000001488 <botlish_entry_14: scan_record_rest<str, int, mutarray, int>>:
    1488:	push   rbp
    1489:	mov    rbp,rsp
    148c:	ud2

000000000000148e <botlish_fn_15: scan_record<str, int>>:
    148e:	push   rbp
    148f:	mov    rbp,rsp
    1492:	sub    rsp,0x40
    1496:	mov    QWORD PTR [rsp+0x20],rbx
    149b:	mov    QWORD PTR [rsp+0x28],r12
    14a0:	mov    QWORD PTR [rsp+0x30],r14
    14a5:	mov    r14,rdi
    14a8:	mov    QWORD PTR [rsp+0x10],0x0
    14b1:	mov    QWORD PTR [rsp+0x18],0x0
    14ba:	mov    QWORD PTR [rsp],rsi
    14be:	mov    r12,rsi
    14c1:	mov    QWORD PTR [rsp+0x8],rdx
    14c6:	mov    rsi,r12
    14c9:	mov    rdi,r14
    14cc:	call   14d1 <botlish_fn_15+0x43>
			14cd: R_X86_64_PLT32	botlish_fn_13-0x4 ; scan_field<str, int>
    14d1:	test   rax,rax
    14d4:	je     1529 <botlish_fn_15+0x9b>
    14da:	mov    QWORD PTR [rsp+0x8],rax
    14df:	mov    rsi,rax
    14e2:	mov    QWORD PTR [rsp+0x10],rdx
    14e7:	mov    rbx,rdx
    14ea:	mov    rdi,r14
    14ed:	call   14f2 <botlish_fn_15+0x64>
			14ee: R_X86_64_PLT32	botlish_fn_1-0x4 ; geo_new<str>
    14f2:	test   rax,rax
    14f5:	je     1529 <botlish_fn_15+0x9b>
    14fb:	mov    QWORD PTR [rsp+0x8],rax
    1500:	mov    rcx,rax
    1503:	mov    r8d,0x3
    1509:	mov    QWORD PTR [rsp+0x18],0x3
    1512:	mov    rdx,rbx
    1515:	mov    rsi,r12
    1518:	mov    rdi,r14
    151b:	call   1520 <botlish_fn_15+0x92>
			151c: R_X86_64_PLT32	botlish_fn_14-0x4 ; scan_record_rest<str, int, mutarray, int>
    1520:	test   rax,rax
    1523:	jne    1547 <botlish_fn_15+0xb9>
    1529:	xor    rdx,rdx
    152c:	mov    rax,rdx
    152f:	mov    rbx,QWORD PTR [rsp+0x20]
    1534:	mov    r12,QWORD PTR [rsp+0x28]
    1539:	mov    r14,QWORD PTR [rsp+0x30]
    153e:	add    rsp,0x40
    1542:	mov    rsp,rbp
    1545:	pop    rbp
    1546:	ret
    1547:	mov    rbx,QWORD PTR [rsp+0x20]
    154c:	mov    r12,QWORD PTR [rsp+0x28]
    1551:	mov    r14,QWORD PTR [rsp+0x30]
    1556:	add    rsp,0x40
    155a:	mov    rsp,rbp
    155d:	pop    rbp
    155e:	ret

000000000000155f <botlish_entry_15: scan_record<str, int>>:
    155f:	push   rbp
    1560:	mov    rbp,rsp
    1563:	ud2
    1565:	add    BYTE PTR [rax],al
	...

0000000000001568 <botlish_fn_16: scan_records<str, int, mutarray, int>>:
    1568:	push   rbp
    1569:	mov    rbp,rsp
    156c:	sub    rsp,0x60
    1570:	mov    QWORD PTR [rsp+0x30],rbx
    1575:	mov    QWORD PTR [rsp+0x38],r12
    157a:	mov    QWORD PTR [rsp+0x40],r13
    157f:	mov    QWORD PTR [rsp+0x48],r14
    1584:	mov    QWORD PTR [rsp+0x50],r15
    1589:	mov    r13,rdi
    158c:	mov    QWORD PTR [rsp+0x20],0x0
    1595:	mov    QWORD PTR [rsp],rsi
    1599:	mov    QWORD PTR [rsp+0x8],rdx
    159e:	mov    rax,rdx
    15a1:	mov    QWORD PTR [rsp+0x10],rcx
    15a6:	mov    QWORD PTR [rsp+0x18],r8
    15ab:	mov    rbx,rsi
    15ae:	mov    r14,r8
    15b1:	mov    r15,rcx
    15b4:	mov    rdx,QWORD PTR [rbx+0x8]
    15b8:	shl    rdx,1
    15bb:	or     rdx,0x1
    15bf:	mov    r12,rax
    15c2:	and    rax,rdx
    15c5:	test   rax,0x1
    15cb:	jne    15f1 <botlish_fn_16+0x89>
    15d1:	mov    rsi,r12
    15d4:	mov    rdi,r13
    15d7:	call   15dc <botlish_fn_16+0x74>
			15d8: R_X86_64_PLT32	rt_int_cmp-0x4
    15dc:	mov    ecx,0x2
    15e1:	test   rax,rax
    15e4:	cmovge rcx,QWORD PTR [rip+0x12c]        # 1718 <botlish_fn_16+0x1b0>
    15ec:	jmp    1601 <botlish_fn_16+0x99>
    15f1:	mov    ecx,0x2
    15f6:	cmp    r12,rdx
    15f9:	cmovge rcx,QWORD PTR [rip+0x117]        # 1718 <botlish_fn_16+0x1b0>
    1601:	cmp    rcx,0x6
    1605:	je     16b3 <botlish_fn_16+0x14b>
    160b:	mov    rdx,r12
    160e:	mov    rsi,rbx
    1611:	mov    rdi,r13
    1614:	call   1619 <botlish_fn_16+0xb1>
			1615: R_X86_64_PLT32	botlish_fn_15-0x4 ; scan_record<str, int>
    1619:	test   rax,rax
    161c:	je     16ca <botlish_fn_16+0x162>
    1622:	mov    QWORD PTR [rsp+0x8],rax
    1627:	mov    rcx,rax
    162a:	mov    QWORD PTR [rsp+0x20],rdx
    162f:	mov    rsi,r15
    1632:	mov    r12,rdx
    1635:	mov    rdx,r14
    1638:	mov    rdi,r13
    163b:	call   1640 <botlish_fn_16+0xd8>
			163c: R_X86_64_PLT32	botlish_fn_7-0x4 ; geo_append<mutarray, int, List[str]>
    1640:	test   rax,rax
    1643:	je     16ca <botlish_fn_16+0x162>
    1649:	mov    QWORD PTR [rsp+0x8],rax
    164e:	mov    r15,rax
    1651:	mov    QWORD PTR [rsp+0x10],0x3
    165a:	mov    rsi,r14
    165d:	test   rsi,0x1
    1664:	je     167f <botlish_fn_16+0x117>
    166a:	mov    rsi,r14
    166d:	mov    rax,rsi
    1670:	add    rax,0x2
    1674:	seto   cl
    1677:	test   cl,cl
    1679:	je     168f <botlish_fn_16+0x127>
    167f:	mov    edx,0x3
    1684:	mov    rsi,r14
    1687:	mov    rdi,r13
    168a:	call   168f <botlish_fn_16+0x127>
			168b: R_X86_64_PLT32	rt_int_add-0x4
    168f:	mov    QWORD PTR [rsp],rbx
    1693:	mov    rdx,r12
    1696:	mov    QWORD PTR [rsp+0x8],rdx
    169b:	mov    rcx,r15
    169e:	mov    QWORD PTR [rsp+0x10],rcx
    16a3:	mov    QWORD PTR [rsp+0x18],rax
    16a8:	mov    r14,rax
    16ab:	mov    rax,rdx
    16ae:	jmp    15b4 <botlish_fn_16+0x4c>
    16b3:	mov    rdx,r14
    16b6:	mov    rsi,r15
    16b9:	mov    rdi,r13
    16bc:	call   16c1 <botlish_fn_16+0x159>
			16bd: R_X86_64_PLT32	botlish_fn_8-0x4 ; geo_finish<mutarray, int>
    16c1:	test   rax,rax
    16c4:	jne    16ef <botlish_fn_16+0x187>
    16ca:	xor    rax,rax
    16cd:	mov    rbx,QWORD PTR [rsp+0x30]
    16d2:	mov    r12,QWORD PTR [rsp+0x38]
    16d7:	mov    r13,QWORD PTR [rsp+0x40]
    16dc:	mov    r14,QWORD PTR [rsp+0x48]
    16e1:	mov    r15,QWORD PTR [rsp+0x50]
    16e6:	add    rsp,0x60
    16ea:	mov    rsp,rbp
    16ed:	pop    rbp
    16ee:	ret
    16ef:	mov    rbx,QWORD PTR [rsp+0x30]
    16f4:	mov    r12,QWORD PTR [rsp+0x38]
    16f9:	mov    r13,QWORD PTR [rsp+0x40]
    16fe:	mov    r14,QWORD PTR [rsp+0x48]
    1703:	mov    r15,QWORD PTR [rsp+0x50]
    1708:	add    rsp,0x60
    170c:	mov    rsp,rbp
    170f:	pop    rbp
    1710:	ret
    1711:	add    BYTE PTR [rax],al
    1713:	add    BYTE PTR [rax],al
    1715:	add    BYTE PTR [rax],al
    1717:	add    BYTE PTR [rsi],al
    1719:	add    BYTE PTR [rax],al
    171b:	add    BYTE PTR [rax],al
    171d:	add    BYTE PTR [rax],al
	...

0000000000001720 <botlish_entry_16: scan_records<str, int, mutarray, int>>:
    1720:	push   rbp
    1721:	mov    rbp,rsp
    1724:	mov    rsi,QWORD PTR [rdx]
    1727:	mov    r9,QWORD PTR [rdx+0x8]
    172b:	mov    rcx,QWORD PTR [rdx+0x10]
    172f:	mov    r8,QWORD PTR [rdx+0x18]
    1733:	mov    rdx,r9
    1736:	call   173b <botlish_entry_16+0x1b>
			1737: R_X86_64_PLT32	botlish_fn_16-0x4 ; scan_records<str, int, mutarray, int>
    173b:	mov    rsp,rbp
    173e:	pop    rbp
    173f:	ret

0000000000001740 <botlish_fn_17: csv_parse<str>>:
    1740:	push   rbp
    1741:	mov    rbp,rsp
    1744:	sub    rsp,0x40
    1748:	mov    QWORD PTR [rsp+0x20],rbx
    174d:	mov    QWORD PTR [rsp+0x28],r12
    1752:	mov    QWORD PTR [rsp+0x30],r13
    1757:	mov    rbx,rdi
    175a:	mov    QWORD PTR [rsp+0x8],0x0
    1763:	mov    QWORD PTR [rsp+0x10],0x0
    176c:	mov    QWORD PTR [rsp+0x18],0x0
    1775:	mov    QWORD PTR [rsp],rsi
    1779:	mov    rax,QWORD PTR [rsi+0x8]
    177d:	mov    r12,rsi
    1780:	shl    rax,1
    1783:	or     rax,0x1
    1787:	sar    rax,1
    178a:	test   rax,rax
    178d:	je     181c <botlish_fn_17+0xdc>
    1793:	mov    edx,0x1
    1798:	mov    QWORD PTR [rsp+0x8],0x1
    17a1:	mov    rsi,r12
    17a4:	mov    rdi,rbx
    17a7:	call   17ac <botlish_fn_17+0x6c>
			17a8: R_X86_64_PLT32	botlish_fn_15-0x4 ; scan_record<str, int>
    17ac:	test   rax,rax
    17af:	je     1833 <botlish_fn_17+0xf3>
    17b5:	mov    QWORD PTR [rsp+0x8],rax
    17ba:	mov    rsi,rax
    17bd:	mov    QWORD PTR [rsp+0x10],rdx
    17c2:	mov    r13,rdx
    17c5:	mov    rdi,rbx
    17c8:	call   17cd <botlish_fn_17+0x8d>
			17c9: R_X86_64_PLT32	botlish_fn_2-0x4 ; geo_new<List[str]>
    17cd:	test   rax,rax
    17d0:	je     1833 <botlish_fn_17+0xf3>
    17d6:	mov    QWORD PTR [rsp+0x8],rax
    17db:	mov    rcx,rax
    17de:	mov    r8d,0x3
    17e4:	mov    QWORD PTR [rsp+0x18],0x3
    17ed:	mov    rdx,r13
    17f0:	mov    rsi,r12
    17f3:	mov    rdi,rbx
    17f6:	call   17fb <botlish_fn_17+0xbb>
			17f7: R_X86_64_PLT32	botlish_fn_16-0x4 ; scan_records<str, int, mutarray, int>
    17fb:	test   rax,rax
    17fe:	je     1833 <botlish_fn_17+0xf3>
    1804:	mov    rbx,QWORD PTR [rsp+0x20]
    1809:	mov    r12,QWORD PTR [rsp+0x28]
    180e:	mov    r13,QWORD PTR [rsp+0x30]
    1813:	add    rsp,0x40
    1817:	mov    rsp,rbp
    181a:	pop    rbp
    181b:	ret
    181c:	xor    rdx,rdx
    181f:	mov    rdi,rbx
    1822:	mov    rsi,rdx
    1825:	call   182a <botlish_fn_17+0xea>
			1826: R_X86_64_PLT32	rt_list_new-0x4
    182a:	test   rax,rax
    182d:	jne    184e <botlish_fn_17+0x10e>
    1833:	xor    rax,rax
    1836:	mov    rbx,QWORD PTR [rsp+0x20]
    183b:	mov    r12,QWORD PTR [rsp+0x28]
    1840:	mov    r13,QWORD PTR [rsp+0x30]
    1845:	add    rsp,0x40
    1849:	mov    rsp,rbp
    184c:	pop    rbp
    184d:	ret
    184e:	mov    rbx,QWORD PTR [rsp+0x20]
    1853:	mov    r12,QWORD PTR [rsp+0x28]
    1858:	mov    r13,QWORD PTR [rsp+0x30]
    185d:	add    rsp,0x40
    1861:	mov    rsp,rbp
    1864:	pop    rbp
    1865:	ret

0000000000001866 <botlish_entry_17: csv_parse<str>>:
    1866:	push   rbp
    1867:	mov    rbp,rsp
    186a:	mov    rsi,QWORD PTR [rdx]
    186d:	call   1872 <botlish_entry_17+0xc>
			186e: R_X86_64_PLT32	botlish_fn_17-0x4 ; csv_parse<str>
    1872:	mov    rsp,rbp
    1875:	pop    rbp
    1876:	ret
