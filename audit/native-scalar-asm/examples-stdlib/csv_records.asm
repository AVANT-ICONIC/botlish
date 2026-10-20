; source:  examples/stdlib/csv_records.bot
; backend: Cranelift (specialize=1), native::object
; object:  ELF64 x86-64, unlinked (Botlish-generated code only; runtime
;          helpers are unresolved imports, so their bodies are not present)
; format:  objdump -dr --no-show-raw-insn -M intel
; total machine code bytes: 21519  (per function: 45 89 89 89 357 436 436 436 272 272 272 81 365 309 470 932 310 758 215 480 318 489 446 70 493 114 103 105 44 255 243 692 1096 381 588 730 784 723 809 673 1304 780 107 433 259 629 515 78 78 1166 301)
;
; function symbol -> Botlish label:
;   botlish_fn_0 / botlish_entry_0 -> <program entry>
;   botlish_fn_1 / botlish_entry_1 -> geo_new<str>
;   botlish_fn_2 / botlish_entry_2 -> geo_new<List[str]>
;   botlish_fn_3 / botlish_entry_3 -> geo_new<HashTable>
;   botlish_fn_4 / botlish_entry_4 -> geo_new_capacity<int, int>
;   botlish_fn_5 / botlish_entry_5 -> geo_grow<mutarray, int, str>
;   botlish_fn_6 / botlish_entry_6 -> geo_grow<mutarray, int, List[str]>
;   botlish_fn_7 / botlish_entry_7 -> geo_grow<mutarray, int, HashTable>
;   botlish_fn_8 / botlish_entry_8 -> geo_append<mutarray, int, str>
;   botlish_fn_9 / botlish_entry_9 -> geo_append<mutarray, int, List[str]>
;   botlish_fn_10 / botlish_entry_10 -> geo_append<mutarray, int, HashTable>
;   botlish_fn_11 / botlish_entry_11 -> geo_finish<mutarray, int>
;   botlish_fn_12 / botlish_entry_12 -> peek<str, int>
;   botlish_fn_13 / botlish_entry_13 -> quote_at?<str, int>
;   botlish_fn_14 / botlish_entry_14 -> scan_unquoted<str, int, int>
;   botlish_fn_15 / botlish_entry_15 -> scan_quoted<str, int, str>
;   botlish_fn_16 / botlish_entry_16 -> scan_field<str, int>
;   botlish_fn_17 / botlish_entry_17 -> scan_record_rest<str, int, mutarray, int>
;   botlish_fn_18 / botlish_entry_18 -> scan_record<str, int>
;   botlish_fn_19 / botlish_entry_19 -> scan_records<str, int, mutarray, int>
;   botlish_fn_20 / botlish_entry_20 -> csv_parse<str>
;   botlish_fn_21 / botlish_entry_21 -> ht_alloc<int>
;   botlish_fn_22 / botlish_entry_22 -> ht_alloc<int>
;   botlish_fn_23 / botlish_entry_23 -> ht_new<generic>
;   botlish_fn_24 / botlish_entry_24 -> ht_capacity_for<int, int>
;   botlish_fn_25 / botlish_entry_25 -> ht_new_sized<int>
;   botlish_fn_26 / botlish_entry_26 -> ht_size<HashTable>
;   botlish_fn_27 / botlish_entry_27 -> ht_tombstones<HashTable>
;   botlish_fn_28 / botlish_entry_28 -> ht_capacity<HashTable>
;   botlish_fn_29 / botlish_entry_29 -> ht_probe_start<HashTable, str>
;   botlish_fn_30 / botlish_entry_30 -> ht_probe_next<HashTable, int>
;   botlish_fn_31 / botlish_entry_31 -> ht_find_get<HashTable, str, int>
;   botlish_fn_32 / botlish_entry_32 -> ht_find_insert<HashTable, str, int, int>
;   botlish_fn_33 / botlish_entry_33 -> ht_get<HashTable, str>
;   botlish_fn_34 / botlish_entry_34 -> ht_rehash_probe<mutarray, int, int>
;   botlish_fn_35 / botlish_entry_35 -> ht_rehash_insert<HashTable, int, any, any>
;   botlish_fn_36 / botlish_entry_36 -> ht_rehash_scan<mutarray, mutarray, mutarray, int, int, HashTable, int>
;   botlish_fn_37 / botlish_entry_37 -> ht_rehash<HashTable, int>
;   botlish_fn_38 / botlish_entry_38 -> ht_should_grow<HashTable>
;   botlish_fn_39 / botlish_entry_39 -> ht_grow_or_clean<HashTable>
;   botlish_fn_40 / botlish_entry_40 -> ht_place<HashTable, int, str, str>
;   botlish_fn_41 / botlish_entry_41 -> ht_set<HashTable, str, str>
;   botlish_fn_42 / botlish_entry_42 -> row_new<bool, int>
;   botlish_fn_43 / botlish_entry_43 -> row_fill<HashTable, List[str], List[str], int, int>
;   botlish_fn_44 / botlish_entry_44 -> row_table<List[str], int, List[str], bool>
;   botlish_fn_45 / botlish_entry_45 -> build_rows<List[List[str]], int, List[str], int, mutarray, int, bool>
;   botlish_fn_46 / botlish_entry_46 -> csv_records_generic<str, bool>
;   botlish_fn_47 / botlish_entry_47 -> csv_records<str>
;   botlish_fn_48 / botlish_entry_48 -> csv_records_presized<str>
;   botlish_fn_49 / botlish_entry_49 -> sample_checks<generic>
;   botlish_fn_50 / botlish_entry_50 -> sample<generic>


csv_records.asm.o:     file format elf64-x86-64


Disassembly of section .text:

0000000000000000 <botlish_fn_0: <program entry>>:
       0:	push   rbp
       1:	mov    rbp,rsp
       4:	call   9 <botlish_fn_0+0x9>
			5: R_X86_64_PLT32	botlish_fn_50-0x4 ; sample<generic>
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

000000000000002d <botlish_fn_1: geo_new<str>>:
      2d:	push   rbp
      2e:	mov    rbp,rsp
      31:	sub    rsp,0x10
      35:	mov    QWORD PTR [rsp],rsi
      39:	mov    rdx,rsi
      3c:	mov    esi,0x3
      41:	mov    QWORD PTR [rsp+0x8],0x3
      4a:	call   4f <botlish_fn_1+0x22>
			4b: R_X86_64_PLT32	rt_mutarray_create-0x4
      4f:	test   rax,rax
      52:	jne    64 <botlish_fn_1+0x37>
      58:	xor    rax,rax
      5b:	add    rsp,0x10
      5f:	mov    rsp,rbp
      62:	pop    rbp
      63:	ret
      64:	add    rsp,0x10
      68:	mov    rsp,rbp
      6b:	pop    rbp
      6c:	ret

000000000000006d <botlish_entry_1: geo_new<str>>:
      6d:	push   rbp
      6e:	mov    rbp,rsp
      71:	mov    rsi,QWORD PTR [rdx]
      74:	call   79 <botlish_entry_1+0xc>
			75: R_X86_64_PLT32	botlish_fn_1-0x4 ; geo_new<str>
      79:	mov    rsp,rbp
      7c:	pop    rbp
      7d:	ret

000000000000007e <botlish_fn_2: geo_new<List[str]>>:
      7e:	push   rbp
      7f:	mov    rbp,rsp
      82:	sub    rsp,0x10
      86:	mov    QWORD PTR [rsp],rsi
      8a:	mov    rdx,rsi
      8d:	mov    esi,0x3
      92:	mov    QWORD PTR [rsp+0x8],0x3
      9b:	call   a0 <botlish_fn_2+0x22>
			9c: R_X86_64_PLT32	rt_mutarray_create-0x4
      a0:	test   rax,rax
      a3:	jne    b5 <botlish_fn_2+0x37>
      a9:	xor    rax,rax
      ac:	add    rsp,0x10
      b0:	mov    rsp,rbp
      b3:	pop    rbp
      b4:	ret
      b5:	add    rsp,0x10
      b9:	mov    rsp,rbp
      bc:	pop    rbp
      bd:	ret

00000000000000be <botlish_entry_2: geo_new<List[str]>>:
      be:	push   rbp
      bf:	mov    rbp,rsp
      c2:	mov    rsi,QWORD PTR [rdx]
      c5:	call   ca <botlish_entry_2+0xc>
			c6: R_X86_64_PLT32	botlish_fn_2-0x4 ; geo_new<List[str]>
      ca:	mov    rsp,rbp
      cd:	pop    rbp
      ce:	ret

00000000000000cf <botlish_fn_3: geo_new<HashTable>>:
      cf:	push   rbp
      d0:	mov    rbp,rsp
      d3:	sub    rsp,0x10
      d7:	mov    QWORD PTR [rsp],rsi
      db:	mov    rdx,rsi
      de:	mov    esi,0x3
      e3:	mov    QWORD PTR [rsp+0x8],0x3
      ec:	call   f1 <botlish_fn_3+0x22>
			ed: R_X86_64_PLT32	rt_mutarray_create-0x4
      f1:	test   rax,rax
      f4:	jne    106 <botlish_fn_3+0x37>
      fa:	xor    rax,rax
      fd:	add    rsp,0x10
     101:	mov    rsp,rbp
     104:	pop    rbp
     105:	ret
     106:	add    rsp,0x10
     10a:	mov    rsp,rbp
     10d:	pop    rbp
     10e:	ret

000000000000010f <botlish_entry_3: geo_new<HashTable>>:
     10f:	push   rbp
     110:	mov    rbp,rsp
     113:	mov    rsi,QWORD PTR [rdx]
     116:	call   11b <botlish_entry_3+0xc>
			117: R_X86_64_PLT32	botlish_fn_3-0x4 ; geo_new<HashTable>
     11b:	mov    rsp,rbp
     11e:	pop    rbp
     11f:	ret

0000000000000120 <botlish_fn_4: geo_new_capacity<int, int>>:
     120:	push   rbp
     121:	mov    rbp,rsp
     124:	sub    rsp,0x40
     128:	mov    QWORD PTR [rsp+0x20],rbx
     12d:	mov    QWORD PTR [rsp+0x28],r12
     132:	mov    QWORD PTR [rsp+0x30],r13
     137:	mov    r12,rdi
     13a:	mov    QWORD PTR [rsp],rsi
     13e:	mov    QWORD PTR [rsp+0x8],rdx
     143:	mov    rbx,rdx
     146:	mov    QWORD PTR [rsp+0x10],0x5
     14f:	test   rsi,0x1
     156:	je     178 <botlish_fn_4+0x58>
     15c:	mov    rax,rsi
     15f:	sar    rax,1
     162:	imul   QWORD PTR [rip+0xdf]        # 248 <botlish_fn_4+0x128>
     169:	seto   cl
     16c:	or     rax,0x1
     170:	test   cl,cl
     172:	je     185 <botlish_fn_4+0x65>
     178:	mov    edx,0x5
     17d:	mov    rdi,r12
     180:	call   185 <botlish_fn_4+0x65>
			181: R_X86_64_PLT32	rt_int_mul-0x4
     185:	mov    rcx,rax
     188:	and    rcx,rbx
     18b:	mov    r13,rax
     18e:	test   rcx,0x1
     195:	jne    1c1 <botlish_fn_4+0xa1>
     19b:	mov    rdx,rbx
     19e:	mov    rsi,r13
     1a1:	mov    rdi,r12
     1a4:	call   1a9 <botlish_fn_4+0x89>
			1a5: R_X86_64_PLT32	rt_int_cmp-0x4
     1a9:	mov    ecx,0x2
     1ae:	test   rax,rax
     1b1:	cmovle rcx,QWORD PTR [rip+0x97]        # 250 <botlish_fn_4+0x130>
     1b9:	mov    rax,r13
     1bc:	jmp    1d4 <botlish_fn_4+0xb4>
     1c1:	mov    ecx,0x2
     1c6:	mov    rax,r13
     1c9:	cmp    rax,rbx
     1cc:	cmovle rcx,QWORD PTR [rip+0x7c]        # 250 <botlish_fn_4+0x130>
     1d4:	cmp    rcx,0x6
     1d8:	je     1f6 <botlish_fn_4+0xd6>
     1de:	mov    rbx,QWORD PTR [rsp+0x20]
     1e3:	mov    r12,QWORD PTR [rsp+0x28]
     1e8:	mov    r13,QWORD PTR [rsp+0x30]
     1ed:	add    rsp,0x40
     1f1:	mov    rsp,rbp
     1f4:	pop    rbp
     1f5:	ret
     1f6:	mov    QWORD PTR [rsp],0x3
     1fe:	test   rbx,0x1
     205:	je     21d <botlish_fn_4+0xfd>
     20b:	mov    rax,rbx
     20e:	add    rax,0x2
     212:	seto   cl
     215:	test   cl,cl
     217:	je     22d <botlish_fn_4+0x10d>
     21d:	mov    edx,0x3
     222:	mov    rsi,rbx
     225:	mov    rdi,r12
     228:	call   22d <botlish_fn_4+0x10d>
			229: R_X86_64_PLT32	rt_int_add-0x4
     22d:	mov    rbx,QWORD PTR [rsp+0x20]
     232:	mov    r12,QWORD PTR [rsp+0x28]
     237:	mov    r13,QWORD PTR [rsp+0x30]
     23c:	add    rsp,0x40
     240:	mov    rsp,rbp
     243:	pop    rbp
     244:	ret
     245:	add    BYTE PTR [rax],al
     247:	add    BYTE PTR [rax+rax*1],al
     24a:	add    BYTE PTR [rax],al
     24c:	add    BYTE PTR [rax],al
     24e:	add    BYTE PTR [rax],al
     250:	(bad)
     251:	add    BYTE PTR [rax],al
     253:	add    BYTE PTR [rax],al
     255:	add    BYTE PTR [rax],al
	...

0000000000000258 <botlish_entry_4: geo_new_capacity<int, int>>:
     258:	push   rbp
     259:	mov    rbp,rsp
     25c:	mov    rsi,QWORD PTR [rdx]
     25f:	mov    rdx,QWORD PTR [rdx+0x8]
     263:	call   268 <botlish_entry_4+0x10>
			264: R_X86_64_PLT32	botlish_fn_4-0x4 ; geo_new_capacity<int, int>
     268:	mov    rsp,rbp
     26b:	pop    rbp
     26c:	ret
     26d:	add    BYTE PTR [rax],al
	...

0000000000000270 <botlish_fn_5: geo_grow<mutarray, int, str>>:
     270:	push   rbp
     271:	mov    rbp,rsp
     274:	sub    rsp,0x50
     278:	mov    QWORD PTR [rsp+0x20],rbx
     27d:	mov    QWORD PTR [rsp+0x28],r12
     282:	mov    QWORD PTR [rsp+0x30],r13
     287:	mov    QWORD PTR [rsp+0x38],r14
     28c:	mov    QWORD PTR [rsp+0x40],r15
     291:	mov    rbx,rdx
     294:	mov    r13,rdi
     297:	mov    QWORD PTR [rsp],rsi
     29b:	mov    r12,rsi
     29e:	mov    QWORD PTR [rsp+0x8],rdx
     2a3:	mov    QWORD PTR [rsp+0x10],rcx
     2a8:	mov    r14,rcx
     2ab:	mov    rax,r12
     2ae:	mov    rsi,QWORD PTR [rax+0x8]
     2b2:	shl    rsi,1
     2b5:	mov    rax,rsi
     2b8:	or     rax,0x1
     2bc:	mov    QWORD PTR [rsp+0x18],rax
     2c1:	mov    rdx,rbx
     2c4:	mov    rcx,rdx
     2c7:	and    rcx,rax
     2ca:	test   rcx,0x1
     2d1:	jne    304 <botlish_fn_5+0x94>
     2d7:	mov    rdx,rsi
     2da:	or     rdx,0x1
     2de:	mov    r15,rsi
     2e1:	mov    rsi,rbx
     2e4:	mov    rdi,r13
     2e7:	call   2ec <botlish_fn_5+0x7c>
			2e8: R_X86_64_PLT32	rt_int_cmp-0x4
     2ec:	mov    ecx,0x2
     2f1:	test   rax,rax
     2f4:	cmovl  rcx,QWORD PTR [rip+0xec]        # 3e8 <botlish_fn_5+0x178>
     2fc:	mov    rsi,r15
     2ff:	jmp    31b <botlish_fn_5+0xab>
     304:	mov    rdx,rsi
     307:	or     rdx,0x1
     30b:	mov    ecx,0x2
     310:	cmp    rbx,rdx
     313:	cmovl  rcx,QWORD PTR [rip+0xcd]        # 3e8 <botlish_fn_5+0x178>
     31b:	cmp    rcx,0x6
     31f:	je     3c0 <botlish_fn_5+0x150>
     325:	or     rsi,0x1
     329:	mov    rdx,rbx
     32c:	mov    rdi,r13
     32f:	call   334 <botlish_fn_5+0xc4>
			330: R_X86_64_PLT32	botlish_fn_4-0x4 ; geo_new_capacity<int, int>
     334:	mov    QWORD PTR [rsp+0x18],rax
     339:	mov    rdx,r14
     33c:	mov    rsi,rax
     33f:	mov    rdi,r13
     342:	call   347 <botlish_fn_5+0xd7>
			343: R_X86_64_PLT32	rt_mutarray_create-0x4
     347:	test   rax,rax
     34a:	mov    r14,rax
     34d:	je     376 <botlish_fn_5+0x106>
     353:	mov    r8d,0x1
     359:	mov    rcx,r12
     35c:	mov    rdi,r13
     35f:	mov    r9,rbx
     362:	mov    rsi,r14
     365:	mov    rdx,r8
     368:	call   36d <botlish_fn_5+0xfd>
			369: R_X86_64_PLT32	rt_mutarray_copy-0x4
     36d:	test   rax,rax
     370:	jne    39b <botlish_fn_5+0x12b>
     376:	xor    rax,rax
     379:	mov    rbx,QWORD PTR [rsp+0x20]
     37e:	mov    r12,QWORD PTR [rsp+0x28]
     383:	mov    r13,QWORD PTR [rsp+0x30]
     388:	mov    r14,QWORD PTR [rsp+0x38]
     38d:	mov    r15,QWORD PTR [rsp+0x40]
     392:	add    rsp,0x50
     396:	mov    rsp,rbp
     399:	pop    rbp
     39a:	ret
     39b:	mov    rax,r14
     39e:	mov    rbx,QWORD PTR [rsp+0x20]
     3a3:	mov    r12,QWORD PTR [rsp+0x28]
     3a8:	mov    r13,QWORD PTR [rsp+0x30]
     3ad:	mov    r14,QWORD PTR [rsp+0x38]
     3b2:	mov    r15,QWORD PTR [rsp+0x40]
     3b7:	add    rsp,0x50
     3bb:	mov    rsp,rbp
     3be:	pop    rbp
     3bf:	ret
     3c0:	mov    rax,r12
     3c3:	mov    rbx,QWORD PTR [rsp+0x20]
     3c8:	mov    r12,QWORD PTR [rsp+0x28]
     3cd:	mov    r13,QWORD PTR [rsp+0x30]
     3d2:	mov    r14,QWORD PTR [rsp+0x38]
     3d7:	mov    r15,QWORD PTR [rsp+0x40]
     3dc:	add    rsp,0x50
     3e0:	mov    rsp,rbp
     3e3:	pop    rbp
     3e4:	ret
     3e5:	add    BYTE PTR [rax],al
     3e7:	add    BYTE PTR [rsi],al
     3e9:	add    BYTE PTR [rax],al
     3eb:	add    BYTE PTR [rax],al
     3ed:	add    BYTE PTR [rax],al
	...

00000000000003f0 <botlish_entry_5: geo_grow<mutarray, int, str>>:
     3f0:	push   rbp
     3f1:	mov    rbp,rsp
     3f4:	mov    rsi,QWORD PTR [rdx]
     3f7:	mov    r8,QWORD PTR [rdx+0x8]
     3fb:	mov    rcx,QWORD PTR [rdx+0x10]
     3ff:	mov    rdx,r8
     402:	call   407 <botlish_entry_5+0x17>
			403: R_X86_64_PLT32	botlish_fn_5-0x4 ; geo_grow<mutarray, int, str>
     407:	mov    rsp,rbp
     40a:	pop    rbp
     40b:	ret
     40c:	add    BYTE PTR [rax],al
	...

0000000000000410 <botlish_fn_6: geo_grow<mutarray, int, List[str]>>:
     410:	push   rbp
     411:	mov    rbp,rsp
     414:	sub    rsp,0x50
     418:	mov    QWORD PTR [rsp+0x20],rbx
     41d:	mov    QWORD PTR [rsp+0x28],r12
     422:	mov    QWORD PTR [rsp+0x30],r13
     427:	mov    QWORD PTR [rsp+0x38],r14
     42c:	mov    QWORD PTR [rsp+0x40],r15
     431:	mov    rbx,rdx
     434:	mov    r13,rdi
     437:	mov    QWORD PTR [rsp],rsi
     43b:	mov    r12,rsi
     43e:	mov    QWORD PTR [rsp+0x8],rdx
     443:	mov    QWORD PTR [rsp+0x10],rcx
     448:	mov    r14,rcx
     44b:	mov    rax,r12
     44e:	mov    rsi,QWORD PTR [rax+0x8]
     452:	shl    rsi,1
     455:	mov    rax,rsi
     458:	or     rax,0x1
     45c:	mov    QWORD PTR [rsp+0x18],rax
     461:	mov    rdx,rbx
     464:	mov    rcx,rdx
     467:	and    rcx,rax
     46a:	test   rcx,0x1
     471:	jne    4a4 <botlish_fn_6+0x94>
     477:	mov    rdx,rsi
     47a:	or     rdx,0x1
     47e:	mov    r15,rsi
     481:	mov    rsi,rbx
     484:	mov    rdi,r13
     487:	call   48c <botlish_fn_6+0x7c>
			488: R_X86_64_PLT32	rt_int_cmp-0x4
     48c:	mov    ecx,0x2
     491:	test   rax,rax
     494:	cmovl  rcx,QWORD PTR [rip+0xec]        # 588 <botlish_fn_6+0x178>
     49c:	mov    rsi,r15
     49f:	jmp    4bb <botlish_fn_6+0xab>
     4a4:	mov    rdx,rsi
     4a7:	or     rdx,0x1
     4ab:	mov    ecx,0x2
     4b0:	cmp    rbx,rdx
     4b3:	cmovl  rcx,QWORD PTR [rip+0xcd]        # 588 <botlish_fn_6+0x178>
     4bb:	cmp    rcx,0x6
     4bf:	je     560 <botlish_fn_6+0x150>
     4c5:	or     rsi,0x1
     4c9:	mov    rdx,rbx
     4cc:	mov    rdi,r13
     4cf:	call   4d4 <botlish_fn_6+0xc4>
			4d0: R_X86_64_PLT32	botlish_fn_4-0x4 ; geo_new_capacity<int, int>
     4d4:	mov    QWORD PTR [rsp+0x18],rax
     4d9:	mov    rdx,r14
     4dc:	mov    rsi,rax
     4df:	mov    rdi,r13
     4e2:	call   4e7 <botlish_fn_6+0xd7>
			4e3: R_X86_64_PLT32	rt_mutarray_create-0x4
     4e7:	test   rax,rax
     4ea:	mov    r14,rax
     4ed:	je     516 <botlish_fn_6+0x106>
     4f3:	mov    r8d,0x1
     4f9:	mov    rcx,r12
     4fc:	mov    rdi,r13
     4ff:	mov    r9,rbx
     502:	mov    rsi,r14
     505:	mov    rdx,r8
     508:	call   50d <botlish_fn_6+0xfd>
			509: R_X86_64_PLT32	rt_mutarray_copy-0x4
     50d:	test   rax,rax
     510:	jne    53b <botlish_fn_6+0x12b>
     516:	xor    rax,rax
     519:	mov    rbx,QWORD PTR [rsp+0x20]
     51e:	mov    r12,QWORD PTR [rsp+0x28]
     523:	mov    r13,QWORD PTR [rsp+0x30]
     528:	mov    r14,QWORD PTR [rsp+0x38]
     52d:	mov    r15,QWORD PTR [rsp+0x40]
     532:	add    rsp,0x50
     536:	mov    rsp,rbp
     539:	pop    rbp
     53a:	ret
     53b:	mov    rax,r14
     53e:	mov    rbx,QWORD PTR [rsp+0x20]
     543:	mov    r12,QWORD PTR [rsp+0x28]
     548:	mov    r13,QWORD PTR [rsp+0x30]
     54d:	mov    r14,QWORD PTR [rsp+0x38]
     552:	mov    r15,QWORD PTR [rsp+0x40]
     557:	add    rsp,0x50
     55b:	mov    rsp,rbp
     55e:	pop    rbp
     55f:	ret
     560:	mov    rax,r12
     563:	mov    rbx,QWORD PTR [rsp+0x20]
     568:	mov    r12,QWORD PTR [rsp+0x28]
     56d:	mov    r13,QWORD PTR [rsp+0x30]
     572:	mov    r14,QWORD PTR [rsp+0x38]
     577:	mov    r15,QWORD PTR [rsp+0x40]
     57c:	add    rsp,0x50
     580:	mov    rsp,rbp
     583:	pop    rbp
     584:	ret
     585:	add    BYTE PTR [rax],al
     587:	add    BYTE PTR [rsi],al
     589:	add    BYTE PTR [rax],al
     58b:	add    BYTE PTR [rax],al
     58d:	add    BYTE PTR [rax],al
	...

0000000000000590 <botlish_entry_6: geo_grow<mutarray, int, List[str]>>:
     590:	push   rbp
     591:	mov    rbp,rsp
     594:	mov    rsi,QWORD PTR [rdx]
     597:	mov    r8,QWORD PTR [rdx+0x8]
     59b:	mov    rcx,QWORD PTR [rdx+0x10]
     59f:	mov    rdx,r8
     5a2:	call   5a7 <botlish_entry_6+0x17>
			5a3: R_X86_64_PLT32	botlish_fn_6-0x4 ; geo_grow<mutarray, int, List[str]>
     5a7:	mov    rsp,rbp
     5aa:	pop    rbp
     5ab:	ret
     5ac:	add    BYTE PTR [rax],al
	...

00000000000005b0 <botlish_fn_7: geo_grow<mutarray, int, HashTable>>:
     5b0:	push   rbp
     5b1:	mov    rbp,rsp
     5b4:	sub    rsp,0x50
     5b8:	mov    QWORD PTR [rsp+0x20],rbx
     5bd:	mov    QWORD PTR [rsp+0x28],r12
     5c2:	mov    QWORD PTR [rsp+0x30],r13
     5c7:	mov    QWORD PTR [rsp+0x38],r14
     5cc:	mov    QWORD PTR [rsp+0x40],r15
     5d1:	mov    rbx,rdx
     5d4:	mov    r13,rdi
     5d7:	mov    QWORD PTR [rsp],rsi
     5db:	mov    r12,rsi
     5de:	mov    QWORD PTR [rsp+0x8],rdx
     5e3:	mov    QWORD PTR [rsp+0x10],rcx
     5e8:	mov    r14,rcx
     5eb:	mov    rax,r12
     5ee:	mov    rsi,QWORD PTR [rax+0x8]
     5f2:	shl    rsi,1
     5f5:	mov    rax,rsi
     5f8:	or     rax,0x1
     5fc:	mov    QWORD PTR [rsp+0x18],rax
     601:	mov    rdx,rbx
     604:	mov    rcx,rdx
     607:	and    rcx,rax
     60a:	test   rcx,0x1
     611:	jne    644 <botlish_fn_7+0x94>
     617:	mov    rdx,rsi
     61a:	or     rdx,0x1
     61e:	mov    r15,rsi
     621:	mov    rsi,rbx
     624:	mov    rdi,r13
     627:	call   62c <botlish_fn_7+0x7c>
			628: R_X86_64_PLT32	rt_int_cmp-0x4
     62c:	mov    ecx,0x2
     631:	test   rax,rax
     634:	cmovl  rcx,QWORD PTR [rip+0xec]        # 728 <botlish_fn_7+0x178>
     63c:	mov    rsi,r15
     63f:	jmp    65b <botlish_fn_7+0xab>
     644:	mov    rdx,rsi
     647:	or     rdx,0x1
     64b:	mov    ecx,0x2
     650:	cmp    rbx,rdx
     653:	cmovl  rcx,QWORD PTR [rip+0xcd]        # 728 <botlish_fn_7+0x178>
     65b:	cmp    rcx,0x6
     65f:	je     700 <botlish_fn_7+0x150>
     665:	or     rsi,0x1
     669:	mov    rdx,rbx
     66c:	mov    rdi,r13
     66f:	call   674 <botlish_fn_7+0xc4>
			670: R_X86_64_PLT32	botlish_fn_4-0x4 ; geo_new_capacity<int, int>
     674:	mov    QWORD PTR [rsp+0x18],rax
     679:	mov    rdx,r14
     67c:	mov    rsi,rax
     67f:	mov    rdi,r13
     682:	call   687 <botlish_fn_7+0xd7>
			683: R_X86_64_PLT32	rt_mutarray_create-0x4
     687:	test   rax,rax
     68a:	mov    r14,rax
     68d:	je     6b6 <botlish_fn_7+0x106>
     693:	mov    r8d,0x1
     699:	mov    rcx,r12
     69c:	mov    rdi,r13
     69f:	mov    r9,rbx
     6a2:	mov    rsi,r14
     6a5:	mov    rdx,r8
     6a8:	call   6ad <botlish_fn_7+0xfd>
			6a9: R_X86_64_PLT32	rt_mutarray_copy-0x4
     6ad:	test   rax,rax
     6b0:	jne    6db <botlish_fn_7+0x12b>
     6b6:	xor    rax,rax
     6b9:	mov    rbx,QWORD PTR [rsp+0x20]
     6be:	mov    r12,QWORD PTR [rsp+0x28]
     6c3:	mov    r13,QWORD PTR [rsp+0x30]
     6c8:	mov    r14,QWORD PTR [rsp+0x38]
     6cd:	mov    r15,QWORD PTR [rsp+0x40]
     6d2:	add    rsp,0x50
     6d6:	mov    rsp,rbp
     6d9:	pop    rbp
     6da:	ret
     6db:	mov    rax,r14
     6de:	mov    rbx,QWORD PTR [rsp+0x20]
     6e3:	mov    r12,QWORD PTR [rsp+0x28]
     6e8:	mov    r13,QWORD PTR [rsp+0x30]
     6ed:	mov    r14,QWORD PTR [rsp+0x38]
     6f2:	mov    r15,QWORD PTR [rsp+0x40]
     6f7:	add    rsp,0x50
     6fb:	mov    rsp,rbp
     6fe:	pop    rbp
     6ff:	ret
     700:	mov    rax,r12
     703:	mov    rbx,QWORD PTR [rsp+0x20]
     708:	mov    r12,QWORD PTR [rsp+0x28]
     70d:	mov    r13,QWORD PTR [rsp+0x30]
     712:	mov    r14,QWORD PTR [rsp+0x38]
     717:	mov    r15,QWORD PTR [rsp+0x40]
     71c:	add    rsp,0x50
     720:	mov    rsp,rbp
     723:	pop    rbp
     724:	ret
     725:	add    BYTE PTR [rax],al
     727:	add    BYTE PTR [rsi],al
     729:	add    BYTE PTR [rax],al
     72b:	add    BYTE PTR [rax],al
     72d:	add    BYTE PTR [rax],al
	...

0000000000000730 <botlish_entry_7: geo_grow<mutarray, int, HashTable>>:
     730:	push   rbp
     731:	mov    rbp,rsp
     734:	mov    rsi,QWORD PTR [rdx]
     737:	mov    r8,QWORD PTR [rdx+0x8]
     73b:	mov    rcx,QWORD PTR [rdx+0x10]
     73f:	mov    rdx,r8
     742:	call   747 <botlish_entry_7+0x17>
			743: R_X86_64_PLT32	botlish_fn_7-0x4 ; geo_grow<mutarray, int, HashTable>
     747:	mov    rsp,rbp
     74a:	pop    rbp
     74b:	ret

000000000000074c <botlish_fn_8: geo_append<mutarray, int, str>>:
     74c:	push   rbp
     74d:	mov    rbp,rsp
     750:	sub    rsp,0x40
     754:	mov    QWORD PTR [rsp+0x20],rbx
     759:	mov    QWORD PTR [rsp+0x28],r12
     75e:	mov    QWORD PTR [rsp+0x30],r13
     763:	mov    QWORD PTR [rsp+0x38],r15
     768:	mov    rbx,rdi
     76b:	mov    QWORD PTR [rsp],rsi
     76f:	mov    QWORD PTR [rsp+0x8],rdx
     774:	mov    r15,rdx
     777:	mov    QWORD PTR [rsp+0x10],rcx
     77c:	mov    r13,rcx
     77f:	mov    rcx,r13
     782:	mov    rdx,r15
     785:	mov    rdi,rbx
     788:	call   78d <botlish_fn_8+0x41>
			789: R_X86_64_PLT32	botlish_fn_5-0x4 ; geo_grow<mutarray, int, str>
     78d:	test   rax,rax
     790:	je     7ce <botlish_fn_8+0x82>
     796:	mov    rdx,r15
     799:	test   rdx,0x1
     7a0:	je     821 <botlish_fn_8+0xd5>
     7a6:	mov    rsi,QWORD PTR [rax+0x8]
     7aa:	mov    rdi,rdx
     7ad:	sar    rdi,1
     7b0:	cmp    rdi,rsi
     7b3:	jae    82f <botlish_fn_8+0xe3>
     7b9:	mov    rcx,QWORD PTR [rax+0x18]
     7bd:	mov    r12,rax
     7c0:	test   rcx,rcx
     7c3:	jne    7f6 <botlish_fn_8+0xaa>
     7c9:	jmp    83d <botlish_fn_8+0xf1>
     7ce:	xor    rax,rax
     7d1:	mov    rbx,QWORD PTR [rsp+0x20]
     7d6:	mov    r12,QWORD PTR [rsp+0x28]
     7db:	mov    r13,QWORD PTR [rsp+0x30]
     7e0:	mov    r15,QWORD PTR [rsp+0x38]
     7e5:	add    rsp,0x40
     7e9:	mov    rsp,rbp
     7ec:	pop    rbp
     7ed:	ret
     7ee:	mov    rax,r12
     7f1:	jmp    804 <botlish_fn_8+0xb8>
     7f6:	mov    rax,r12
     7f9:	mov    rcx,r13
     7fc:	mov    rdx,QWORD PTR [rax+0x10]
     800:	mov    QWORD PTR [rdx+rdi*8],rcx
     804:	mov    rbx,QWORD PTR [rsp+0x20]
     809:	mov    r12,QWORD PTR [rsp+0x28]
     80e:	mov    r13,QWORD PTR [rsp+0x30]
     813:	mov    r15,QWORD PTR [rsp+0x38]
     818:	add    rsp,0x40
     81c:	mov    rsp,rbp
     81f:	pop    rbp
     820:	ret
     821:	mov    rcx,r13
     824:	mov    rdi,rbx
     827:	mov    r12,rax
     82a:	jmp    843 <botlish_fn_8+0xf7>
     82f:	mov    rcx,r13
     832:	mov    rdi,rbx
     835:	mov    r12,rax
     838:	jmp    843 <botlish_fn_8+0xf7>
     83d:	mov    rcx,r13
     840:	mov    rdi,rbx
     843:	mov    rsi,r12
     846:	call   84b <botlish_fn_8+0xff>
			847: R_X86_64_PLT32	rt_mutarray_set-0x4
     84b:	test   rax,rax
     84e:	jne    7ee <botlish_fn_8+0xa2>
     854:	jmp    7ce <botlish_fn_8+0x82>

0000000000000859 <botlish_entry_8: geo_append<mutarray, int, str>>:
     859:	push   rbp
     85a:	mov    rbp,rsp
     85d:	mov    rsi,QWORD PTR [rdx]
     860:	mov    r8,QWORD PTR [rdx+0x8]
     864:	mov    rcx,QWORD PTR [rdx+0x10]
     868:	mov    rdx,r8
     86b:	call   870 <botlish_entry_8+0x17>
			86c: R_X86_64_PLT32	botlish_fn_8-0x4 ; geo_append<mutarray, int, str>
     870:	mov    rsp,rbp
     873:	pop    rbp
     874:	ret

0000000000000875 <botlish_fn_9: geo_append<mutarray, int, List[str]>>:
     875:	push   rbp
     876:	mov    rbp,rsp
     879:	sub    rsp,0x40
     87d:	mov    QWORD PTR [rsp+0x20],rbx
     882:	mov    QWORD PTR [rsp+0x28],r12
     887:	mov    QWORD PTR [rsp+0x30],r13
     88c:	mov    QWORD PTR [rsp+0x38],r15
     891:	mov    rbx,rdi
     894:	mov    QWORD PTR [rsp],rsi
     898:	mov    QWORD PTR [rsp+0x8],rdx
     89d:	mov    r15,rdx
     8a0:	mov    QWORD PTR [rsp+0x10],rcx
     8a5:	mov    r13,rcx
     8a8:	mov    rcx,r13
     8ab:	mov    rdx,r15
     8ae:	mov    rdi,rbx
     8b1:	call   8b6 <botlish_fn_9+0x41>
			8b2: R_X86_64_PLT32	botlish_fn_6-0x4 ; geo_grow<mutarray, int, List[str]>
     8b6:	test   rax,rax
     8b9:	je     8f7 <botlish_fn_9+0x82>
     8bf:	mov    rdx,r15
     8c2:	test   rdx,0x1
     8c9:	je     94a <botlish_fn_9+0xd5>
     8cf:	mov    rsi,QWORD PTR [rax+0x8]
     8d3:	mov    rdi,rdx
     8d6:	sar    rdi,1
     8d9:	cmp    rdi,rsi
     8dc:	jae    958 <botlish_fn_9+0xe3>
     8e2:	mov    rcx,QWORD PTR [rax+0x18]
     8e6:	mov    r12,rax
     8e9:	test   rcx,rcx
     8ec:	jne    91f <botlish_fn_9+0xaa>
     8f2:	jmp    966 <botlish_fn_9+0xf1>
     8f7:	xor    rax,rax
     8fa:	mov    rbx,QWORD PTR [rsp+0x20]
     8ff:	mov    r12,QWORD PTR [rsp+0x28]
     904:	mov    r13,QWORD PTR [rsp+0x30]
     909:	mov    r15,QWORD PTR [rsp+0x38]
     90e:	add    rsp,0x40
     912:	mov    rsp,rbp
     915:	pop    rbp
     916:	ret
     917:	mov    rax,r12
     91a:	jmp    92d <botlish_fn_9+0xb8>
     91f:	mov    rax,r12
     922:	mov    rcx,r13
     925:	mov    rdx,QWORD PTR [rax+0x10]
     929:	mov    QWORD PTR [rdx+rdi*8],rcx
     92d:	mov    rbx,QWORD PTR [rsp+0x20]
     932:	mov    r12,QWORD PTR [rsp+0x28]
     937:	mov    r13,QWORD PTR [rsp+0x30]
     93c:	mov    r15,QWORD PTR [rsp+0x38]
     941:	add    rsp,0x40
     945:	mov    rsp,rbp
     948:	pop    rbp
     949:	ret
     94a:	mov    rcx,r13
     94d:	mov    rdi,rbx
     950:	mov    r12,rax
     953:	jmp    96c <botlish_fn_9+0xf7>
     958:	mov    rcx,r13
     95b:	mov    rdi,rbx
     95e:	mov    r12,rax
     961:	jmp    96c <botlish_fn_9+0xf7>
     966:	mov    rcx,r13
     969:	mov    rdi,rbx
     96c:	mov    rsi,r12
     96f:	call   974 <botlish_fn_9+0xff>
			970: R_X86_64_PLT32	rt_mutarray_set-0x4
     974:	test   rax,rax
     977:	jne    917 <botlish_fn_9+0xa2>
     97d:	jmp    8f7 <botlish_fn_9+0x82>

0000000000000982 <botlish_entry_9: geo_append<mutarray, int, List[str]>>:
     982:	push   rbp
     983:	mov    rbp,rsp
     986:	mov    rsi,QWORD PTR [rdx]
     989:	mov    r8,QWORD PTR [rdx+0x8]
     98d:	mov    rcx,QWORD PTR [rdx+0x10]
     991:	mov    rdx,r8
     994:	call   999 <botlish_entry_9+0x17>
			995: R_X86_64_PLT32	botlish_fn_9-0x4 ; geo_append<mutarray, int, List[str]>
     999:	mov    rsp,rbp
     99c:	pop    rbp
     99d:	ret

000000000000099e <botlish_fn_10: geo_append<mutarray, int, HashTable>>:
     99e:	push   rbp
     99f:	mov    rbp,rsp
     9a2:	sub    rsp,0x40
     9a6:	mov    QWORD PTR [rsp+0x20],rbx
     9ab:	mov    QWORD PTR [rsp+0x28],r12
     9b0:	mov    QWORD PTR [rsp+0x30],r13
     9b5:	mov    QWORD PTR [rsp+0x38],r15
     9ba:	mov    rbx,rdi
     9bd:	mov    QWORD PTR [rsp],rsi
     9c1:	mov    QWORD PTR [rsp+0x8],rdx
     9c6:	mov    r15,rdx
     9c9:	mov    QWORD PTR [rsp+0x10],rcx
     9ce:	mov    r13,rcx
     9d1:	mov    rcx,r13
     9d4:	mov    rdx,r15
     9d7:	mov    rdi,rbx
     9da:	call   9df <botlish_fn_10+0x41>
			9db: R_X86_64_PLT32	botlish_fn_7-0x4 ; geo_grow<mutarray, int, HashTable>
     9df:	test   rax,rax
     9e2:	je     a20 <botlish_fn_10+0x82>
     9e8:	mov    rdx,r15
     9eb:	test   rdx,0x1
     9f2:	je     a73 <botlish_fn_10+0xd5>
     9f8:	mov    rsi,QWORD PTR [rax+0x8]
     9fc:	mov    rdi,rdx
     9ff:	sar    rdi,1
     a02:	cmp    rdi,rsi
     a05:	jae    a81 <botlish_fn_10+0xe3>
     a0b:	mov    rcx,QWORD PTR [rax+0x18]
     a0f:	mov    r12,rax
     a12:	test   rcx,rcx
     a15:	jne    a48 <botlish_fn_10+0xaa>
     a1b:	jmp    a8f <botlish_fn_10+0xf1>
     a20:	xor    rax,rax
     a23:	mov    rbx,QWORD PTR [rsp+0x20]
     a28:	mov    r12,QWORD PTR [rsp+0x28]
     a2d:	mov    r13,QWORD PTR [rsp+0x30]
     a32:	mov    r15,QWORD PTR [rsp+0x38]
     a37:	add    rsp,0x40
     a3b:	mov    rsp,rbp
     a3e:	pop    rbp
     a3f:	ret
     a40:	mov    rax,r12
     a43:	jmp    a56 <botlish_fn_10+0xb8>
     a48:	mov    rax,r12
     a4b:	mov    rcx,r13
     a4e:	mov    rdx,QWORD PTR [rax+0x10]
     a52:	mov    QWORD PTR [rdx+rdi*8],rcx
     a56:	mov    rbx,QWORD PTR [rsp+0x20]
     a5b:	mov    r12,QWORD PTR [rsp+0x28]
     a60:	mov    r13,QWORD PTR [rsp+0x30]
     a65:	mov    r15,QWORD PTR [rsp+0x38]
     a6a:	add    rsp,0x40
     a6e:	mov    rsp,rbp
     a71:	pop    rbp
     a72:	ret
     a73:	mov    rcx,r13
     a76:	mov    rdi,rbx
     a79:	mov    r12,rax
     a7c:	jmp    a95 <botlish_fn_10+0xf7>
     a81:	mov    rcx,r13
     a84:	mov    rdi,rbx
     a87:	mov    r12,rax
     a8a:	jmp    a95 <botlish_fn_10+0xf7>
     a8f:	mov    rcx,r13
     a92:	mov    rdi,rbx
     a95:	mov    rsi,r12
     a98:	call   a9d <botlish_fn_10+0xff>
			a99: R_X86_64_PLT32	rt_mutarray_set-0x4
     a9d:	test   rax,rax
     aa0:	jne    a40 <botlish_fn_10+0xa2>
     aa6:	jmp    a20 <botlish_fn_10+0x82>

0000000000000aab <botlish_entry_10: geo_append<mutarray, int, HashTable>>:
     aab:	push   rbp
     aac:	mov    rbp,rsp
     aaf:	mov    rsi,QWORD PTR [rdx]
     ab2:	mov    r8,QWORD PTR [rdx+0x8]
     ab6:	mov    rcx,QWORD PTR [rdx+0x10]
     aba:	mov    rdx,r8
     abd:	call   ac2 <botlish_entry_10+0x17>
			abe: R_X86_64_PLT32	botlish_fn_10-0x4 ; geo_append<mutarray, int, HashTable>
     ac2:	mov    rsp,rbp
     ac5:	pop    rbp
     ac6:	ret

0000000000000ac7 <botlish_fn_11: geo_finish<mutarray, int>>:
     ac7:	push   rbp
     ac8:	mov    rbp,rsp
     acb:	sub    rsp,0x10
     acf:	mov    QWORD PTR [rsp],rsi
     ad3:	mov    QWORD PTR [rsp+0x8],rdx
     ad8:	call   add <botlish_fn_11+0x16>
			ad9: R_X86_64_PLT32	rt_mutarray_freeze-0x4
     add:	test   rax,rax
     ae0:	jne    af2 <botlish_fn_11+0x2b>
     ae6:	xor    rax,rax
     ae9:	add    rsp,0x10
     aed:	mov    rsp,rbp
     af0:	pop    rbp
     af1:	ret
     af2:	add    rsp,0x10
     af6:	mov    rsp,rbp
     af9:	pop    rbp
     afa:	ret

0000000000000afb <botlish_entry_11: geo_finish<mutarray, int>>:
     afb:	push   rbp
     afc:	mov    rbp,rsp
     aff:	mov    rsi,QWORD PTR [rdx]
     b02:	mov    rdx,QWORD PTR [rdx+0x8]
     b06:	call   b0b <botlish_entry_11+0x10>
			b07: R_X86_64_PLT32	botlish_fn_11-0x4 ; geo_finish<mutarray, int>
     b0b:	mov    rsp,rbp
     b0e:	pop    rbp
     b0f:	ret

0000000000000b10 <botlish_fn_12: peek<str, int>>:
     b10:	push   rbp
     b11:	mov    rbp,rsp
     b14:	sub    rsp,0x40
     b18:	mov    QWORD PTR [rsp+0x20],rbx
     b1d:	mov    QWORD PTR [rsp+0x28],r12
     b22:	mov    QWORD PTR [rsp+0x30],r13
     b27:	mov    rbx,rdx
     b2a:	mov    r13,rdi
     b2d:	mov    QWORD PTR [rsp],rsi
     b31:	mov    QWORD PTR [rsp+0x8],rdx
     b36:	mov    rdx,QWORD PTR [rsi+0x8]
     b3a:	mov    r12,rsi
     b3d:	shl    rdx,1
     b40:	mov    rax,rdx
     b43:	or     rax,0x1
     b47:	mov    rcx,rbx
     b4a:	and    rcx,rax
     b4d:	test   rcx,0x1
     b54:	jne    b7e <botlish_fn_12+0x6e>
     b5a:	or     rdx,0x1
     b5e:	mov    rsi,rbx
     b61:	mov    rdi,r13
     b64:	call   b69 <botlish_fn_12+0x59>
			b65: R_X86_64_PLT32	rt_int_cmp-0x4
     b69:	mov    ecx,0x2
     b6e:	test   rax,rax
     b71:	cmovge rcx,QWORD PTR [rip+0xcf]        # c48 <botlish_fn_12+0x138>
     b79:	jmp    b92 <botlish_fn_12+0x82>
     b7e:	or     rdx,0x1
     b82:	mov    ecx,0x2
     b87:	cmp    rbx,rdx
     b8a:	cmovge rcx,QWORD PTR [rip+0xb6]        # c48 <botlish_fn_12+0x138>
     b92:	cmp    rcx,0x6
     b96:	je     c26 <botlish_fn_12+0x116>
     b9c:	mov    QWORD PTR [rsp+0x10],0x3
     ba5:	test   rbx,0x1
     bac:	je     bc4 <botlish_fn_12+0xb4>
     bb2:	mov    rcx,rbx
     bb5:	add    rcx,0x2
     bb9:	seto   al
     bbc:	test   al,al
     bbe:	je     bd7 <botlish_fn_12+0xc7>
     bc4:	mov    edx,0x3
     bc9:	mov    rsi,rbx
     bcc:	mov    rdi,r13
     bcf:	call   bd4 <botlish_fn_12+0xc4>
			bd0: R_X86_64_PLT32	rt_int_add-0x4
     bd4:	mov    rcx,rax
     bd7:	mov    QWORD PTR [rsp+0x10],rcx
     bdc:	mov    rdx,rbx
     bdf:	mov    rsi,r12
     be2:	mov    rdi,r13
     be5:	call   bea <botlish_fn_12+0xda>
			be6: R_X86_64_PLT32	rt_substr-0x4
     bea:	test   rax,rax
     bed:	jne    c0e <botlish_fn_12+0xfe>
     bf3:	xor    rax,rax
     bf6:	mov    rbx,QWORD PTR [rsp+0x20]
     bfb:	mov    r12,QWORD PTR [rsp+0x28]
     c00:	mov    r13,QWORD PTR [rsp+0x30]
     c05:	add    rsp,0x40
     c09:	mov    rsp,rbp
     c0c:	pop    rbp
     c0d:	ret
     c0e:	mov    rbx,QWORD PTR [rsp+0x20]
     c13:	mov    r12,QWORD PTR [rsp+0x28]
     c18:	mov    r13,QWORD PTR [rsp+0x30]
     c1d:	add    rsp,0x40
     c21:	mov    rsp,rbp
     c24:	pop    rbp
     c25:	ret
     c26:	mov    rdi,r13
     c29:	mov    rax,QWORD PTR [rdi+0x10]
     c2d:	mov    rax,QWORD PTR [rax]
     c30:	mov    rbx,QWORD PTR [rsp+0x20]
     c35:	mov    r12,QWORD PTR [rsp+0x28]
     c3a:	mov    r13,QWORD PTR [rsp+0x30]
     c3f:	add    rsp,0x40
     c43:	mov    rsp,rbp
     c46:	pop    rbp
     c47:	ret
     c48:	(bad)
     c49:	add    BYTE PTR [rax],al
     c4b:	add    BYTE PTR [rax],al
     c4d:	add    BYTE PTR [rax],al
	...

0000000000000c50 <botlish_entry_12: peek<str, int>>:
     c50:	push   rbp
     c51:	mov    rbp,rsp
     c54:	mov    rsi,QWORD PTR [rdx]
     c57:	mov    rdx,QWORD PTR [rdx+0x8]
     c5b:	call   c60 <botlish_entry_12+0x10>
			c5c: R_X86_64_PLT32	botlish_fn_12-0x4 ; peek<str, int>
     c60:	mov    rsp,rbp
     c63:	pop    rbp
     c64:	ret
     c65:	add    BYTE PTR [rax],al
	...

0000000000000c68 <botlish_fn_13: quote_at?<str, int>>:
     c68:	push   rbp
     c69:	mov    rbp,rsp
     c6c:	sub    rsp,0x20
     c70:	mov    QWORD PTR [rsp],rbx
     c74:	mov    QWORD PTR [rsp+0x8],r12
     c79:	mov    QWORD PTR [rsp+0x10],r13
     c7e:	mov    rbx,rdx
     c81:	mov    r13,rdi
     c84:	mov    rdx,QWORD PTR [rsi+0x8]
     c88:	mov    r12,rsi
     c8b:	shl    rdx,1
     c8e:	mov    rax,rdx
     c91:	or     rax,0x1
     c95:	mov    rcx,rbx
     c98:	and    rcx,rax
     c9b:	test   rcx,0x1
     ca2:	jne    ccc <botlish_fn_13+0x64>
     ca8:	or     rdx,0x1
     cac:	mov    rsi,rbx
     caf:	mov    rdi,r13
     cb2:	call   cb7 <botlish_fn_13+0x4f>
			cb3: R_X86_64_PLT32	rt_int_cmp-0x4
     cb7:	mov    ecx,0x2
     cbc:	test   rax,rax
     cbf:	cmovl  rcx,QWORD PTR [rip+0xa1]        # d68 <botlish_fn_13+0x100>
     cc7:	jmp    ce3 <botlish_fn_13+0x7b>
     ccc:	or     rdx,0x1
     cd0:	mov    ecx,0x2
     cd5:	mov    rax,rbx
     cd8:	cmp    rax,rdx
     cdb:	cmovl  rcx,QWORD PTR [rip+0x85]        # d68 <botlish_fn_13+0x100>
     ce3:	mov    eax,0x6
     ce8:	cmp    rcx,0x6
     cec:	je     cff <botlish_fn_13+0x97>
     cf2:	mov    eax,0x2
     cf7:	mov    r12,rax
     cfa:	jmp    d4c <botlish_fn_13+0xe4>
     cff:	mov    rdi,r13
     d02:	mov    rsi,r12
     d05:	mov    r12,rax
     d08:	mov    rdx,rbx
     d0b:	call   d10 <botlish_fn_13+0xa8>
			d0c: R_X86_64_PLT32	rt_str_char_at-0x4
     d10:	test   rax,rax
     d13:	jne    d33 <botlish_fn_13+0xcb>
     d19:	xor    rax,rax
     d1c:	mov    rbx,QWORD PTR [rsp]
     d20:	mov    r12,QWORD PTR [rsp+0x8]
     d25:	mov    r13,QWORD PTR [rsp+0x10]
     d2a:	add    rsp,0x20
     d2e:	mov    rsp,rbp
     d31:	pop    rbp
     d32:	ret
     d33:	cmp    rax,0x114
     d39:	je     d49 <botlish_fn_13+0xe1>
     d3f:	mov    eax,0x2
     d44:	jmp    d4c <botlish_fn_13+0xe4>
     d49:	mov    rax,r12
     d4c:	mov    rbx,QWORD PTR [rsp]
     d50:	mov    r12,QWORD PTR [rsp+0x8]
     d55:	mov    r13,QWORD PTR [rsp+0x10]
     d5a:	add    rsp,0x20
     d5e:	mov    rsp,rbp
     d61:	pop    rbp
     d62:	ret
     d63:	add    BYTE PTR [rax],al
     d65:	add    BYTE PTR [rax],al
     d67:	add    BYTE PTR [rsi],al
     d69:	add    BYTE PTR [rax],al
     d6b:	add    BYTE PTR [rax],al
     d6d:	add    BYTE PTR [rax],al
	...

0000000000000d70 <botlish_entry_13: quote_at?<str, int>>:
     d70:	push   rbp
     d71:	mov    rbp,rsp
     d74:	mov    rsi,QWORD PTR [rdx]
     d77:	mov    rdx,QWORD PTR [rdx+0x8]
     d7b:	call   d80 <botlish_entry_13+0x10>
			d7c: R_X86_64_PLT32	botlish_fn_13-0x4 ; quote_at?<str, int>
     d80:	mov    rsp,rbp
     d83:	pop    rbp
     d84:	ret
     d85:	add    BYTE PTR [rax],al
	...

0000000000000d88 <botlish_fn_14: scan_unquoted<str, int, int>>:
     d88:	push   rbp
     d89:	mov    rbp,rsp
     d8c:	sub    rsp,0x40
     d90:	mov    QWORD PTR [rsp+0x20],rbx
     d95:	mov    QWORD PTR [rsp+0x28],r12
     d9a:	mov    QWORD PTR [rsp+0x30],r13
     d9f:	mov    QWORD PTR [rsp+0x38],r14
     da4:	mov    r13,rdi
     da7:	mov    QWORD PTR [rsp+0x18],0x0
     db0:	mov    QWORD PTR [rsp],rsi
     db4:	mov    r12,rsi
     db7:	mov    QWORD PTR [rsp+0x8],rdx
     dbc:	mov    rbx,rdx
     dbf:	mov    QWORD PTR [rsp+0x10],rcx
     dc4:	mov    rax,r12
     dc7:	mov    rsi,rcx
     dca:	mov    rdx,QWORD PTR [rax+0x8]
     dce:	mov    r12,rax
     dd1:	shl    rdx,1
     dd4:	or     rdx,0x1
     dd8:	mov    rax,rsi
     ddb:	and    rax,rdx
     dde:	mov    r14,rsi
     de1:	test   rax,0x1
     de7:	jne    e0d <botlish_fn_14+0x85>
     ded:	mov    rsi,r14
     df0:	mov    rdi,r13
     df3:	call   df8 <botlish_fn_14+0x70>
			df4: R_X86_64_PLT32	rt_int_cmp-0x4
     df8:	mov    ecx,0x2
     dfd:	test   rax,rax
     e00:	cmovl  rcx,QWORD PTR [rip+0x138]        # f40 <botlish_fn_14+0x1b8>
     e08:	jmp    e20 <botlish_fn_14+0x98>
     e0d:	mov    ecx,0x2
     e12:	mov    rsi,r14
     e15:	cmp    rsi,rdx
     e18:	cmovl  rcx,QWORD PTR [rip+0x120]        # f40 <botlish_fn_14+0x1b8>
     e20:	cmp    rcx,0x6
     e24:	je     e38 <botlish_fn_14+0xb0>
     e2a:	mov    rdx,rbx
     e2d:	mov    rsi,r12
     e30:	mov    rdi,r13
     e33:	jmp    ee3 <botlish_fn_14+0x15b>
     e38:	mov    rdx,r14
     e3b:	mov    rsi,r12
     e3e:	mov    rdi,r13
     e41:	call   e46 <botlish_fn_14+0xbe>
			e42: R_X86_64_PLT32	rt_str_char_at-0x4
     e46:	test   rax,rax
     e49:	je     efa <botlish_fn_14+0x172>
     e4f:	cmp    rax,0x164
     e55:	jne    e63 <botlish_fn_14+0xdb>
     e5b:	mov    rdx,rbx
     e5e:	jmp    edd <botlish_fn_14+0x155>
     e63:	cmp    rax,0x54
     e67:	jne    e75 <botlish_fn_14+0xed>
     e6d:	mov    rdx,rbx
     e70:	jmp    edd <botlish_fn_14+0x155>
     e75:	mov    QWORD PTR [rsp+0x18],0x3
     e7e:	mov    rsi,r14
     e81:	test   rsi,0x1
     e88:	je     eab <botlish_fn_14+0x123>
     e8e:	mov    rsi,r14
     e91:	mov    rax,rsi
     e94:	add    rax,0x2
     e98:	seto   cl
     e9b:	test   cl,cl
     e9d:	jne    eab <botlish_fn_14+0x123>
     ea3:	mov    rsi,r12
     ea6:	jmp    ebe <botlish_fn_14+0x136>
     eab:	mov    edx,0x3
     eb0:	mov    rsi,r14
     eb3:	mov    rdi,r13
     eb6:	call   ebb <botlish_fn_14+0x133>
			eb7: R_X86_64_PLT32	rt_int_add-0x4
     ebb:	mov    rsi,r12
     ebe:	mov    rsi,r12
     ec1:	mov    QWORD PTR [rsp],rsi
     ec5:	mov    rdx,rbx
     ec8:	mov    QWORD PTR [rsp+0x8],rdx
     ecd:	mov    QWORD PTR [rsp+0x10],rax
     ed2:	mov    rsi,rax
     ed5:	mov    rax,r12
     ed8:	jmp    dca <botlish_fn_14+0x42>
     edd:	mov    rsi,r12
     ee0:	mov    rdi,r13
     ee3:	mov    rsi,r12
     ee6:	mov    rdi,r13
     ee9:	mov    rcx,r14
     eec:	call   ef1 <botlish_fn_14+0x169>
			eed: R_X86_64_PLT32	rt_substr-0x4
     ef1:	test   rax,rax
     ef4:	jne    f1d <botlish_fn_14+0x195>
     efa:	xor    rdx,rdx
     efd:	mov    rax,rdx
     f00:	mov    rbx,QWORD PTR [rsp+0x20]
     f05:	mov    r12,QWORD PTR [rsp+0x28]
     f0a:	mov    r13,QWORD PTR [rsp+0x30]
     f0f:	mov    r14,QWORD PTR [rsp+0x38]
     f14:	add    rsp,0x40
     f18:	mov    rsp,rbp
     f1b:	pop    rbp
     f1c:	ret
     f1d:	mov    rdx,r14
     f20:	mov    rbx,QWORD PTR [rsp+0x20]
     f25:	mov    r12,QWORD PTR [rsp+0x28]
     f2a:	mov    r13,QWORD PTR [rsp+0x30]
     f2f:	mov    r14,QWORD PTR [rsp+0x38]
     f34:	add    rsp,0x40
     f38:	mov    rsp,rbp
     f3b:	pop    rbp
     f3c:	ret
     f3d:	add    BYTE PTR [rax],al
     f3f:	add    BYTE PTR [rsi],al
     f41:	add    BYTE PTR [rax],al
     f43:	add    BYTE PTR [rax],al
     f45:	add    BYTE PTR [rax],al
	...

0000000000000f48 <botlish_entry_14: scan_unquoted<str, int, int>>:
     f48:	push   rbp
     f49:	mov    rbp,rsp
     f4c:	ud2

0000000000000f4e <botlish_fn_15: scan_quoted<str, int, str>>:
     f4e:	push   rbp
     f4f:	mov    rbp,rsp
     f52:	sub    rsp,0xb0
     f59:	mov    QWORD PTR [rsp+0x80],rbx
     f61:	mov    QWORD PTR [rsp+0x88],r12
     f69:	mov    QWORD PTR [rsp+0x90],r13
     f71:	mov    QWORD PTR [rsp+0x98],r14
     f79:	mov    QWORD PTR [rsp+0xa0],r15
     f81:	mov    r15,rdi
     f84:	mov    QWORD PTR [rsp+0x18],0x0
     f8d:	mov    QWORD PTR [rsp+0x20],0x0
     f96:	mov    QWORD PTR [rsp],rsi
     f9a:	mov    QWORD PTR [rsp+0x8],rdx
     f9f:	mov    QWORD PTR [rsp+0x10],rcx
     fa4:	mov    r13,rcx
     fa7:	lea    r12,[rsp+0x58]
     fac:	mov    rbx,rsi
     faf:	mov    QWORD PTR [rsp+0x78],rdx
     fb4:	mov    rdx,QWORD PTR [rsp+0x78]
     fb9:	mov    rsi,rbx
     fbc:	mov    rdi,r15
     fbf:	call   fc4 <botlish_fn_15+0x76>
			fc0: R_X86_64_PLT32	botlish_fn_12-0x4 ; peek<str, int>
     fc4:	test   rax,rax
     fc7:	je     1263 <botlish_fn_15+0x315>
     fcd:	mov    QWORD PTR [rsp+0x18],rax
     fd2:	mov    r14,rax
     fd5:	mov    rdx,QWORD PTR [rsp+0x78]
     fda:	mov    rsi,rbx
     fdd:	mov    rdi,r15
     fe0:	call   fe5 <botlish_fn_15+0x97>
			fe1: R_X86_64_PLT32	botlish_fn_13-0x4 ; quote_at?<str, int>
     fe5:	test   rax,rax
     fe8:	je     1263 <botlish_fn_15+0x315>
     fee:	cmp    rax,0x6
     ff2:	je     10ab <botlish_fn_15+0x15d>
     ff8:	mov    QWORD PTR [rsp+0x20],0x3
    1001:	mov    rsi,QWORD PTR [rsp+0x78]
    1006:	test   rsi,0x1
    100d:	je     1037 <botlish_fn_15+0xe9>
    1013:	mov    rsi,QWORD PTR [rsp+0x78]
    1018:	mov    rcx,rsi
    101b:	add    rcx,0x2
    101f:	seto   dl
    1022:	test   dl,dl
    1024:	jne    1037 <botlish_fn_15+0xe9>
    102a:	mov    rsi,rcx
    102d:	mov    QWORD PTR [rsp+0x78],rcx
    1032:	jmp    1051 <botlish_fn_15+0x103>
    1037:	mov    edx,0x3
    103c:	mov    rsi,QWORD PTR [rsp+0x78]
    1041:	mov    rdi,r15
    1044:	call   1049 <botlish_fn_15+0xfb>
			1045: R_X86_64_PLT32	rt_int_add-0x4
    1049:	mov    rsi,rax
    104c:	mov    QWORD PTR [rsp+0x78],rax
    1051:	mov    QWORD PTR [rsp+0x8],rsi
    1056:	mov    QWORD PTR [rsp+0x58],0x0
    105f:	mov    QWORD PTR [rsp+0x60],r13
    1064:	mov    QWORD PTR [rsp+0x68],0x0
    106d:	mov    QWORD PTR [rsp+0x70],r14
    1072:	mov    esi,0x2
    1077:	mov    edx,0x4
    107c:	mov    rcx,r12
    107f:	mov    rdi,r15
    1082:	call   1087 <botlish_fn_15+0x139>
			1083: R_X86_64_PLT32	rt_construct-0x4
    1087:	test   rax,rax
    108a:	je     1263 <botlish_fn_15+0x315>
    1090:	mov    QWORD PTR [rsp],rbx
    1094:	mov    rsi,QWORD PTR [rsp+0x78]
    1099:	mov    QWORD PTR [rsp+0x8],rsi
    109e:	mov    QWORD PTR [rsp+0x10],rax
    10a3:	mov    r13,rax
    10a6:	jmp    fb4 <botlish_fn_15+0x66>
    10ab:	mov    QWORD PTR [rsp+0x20],0x3
    10b4:	mov    rsi,QWORD PTR [rsp+0x78]
    10b9:	test   rsi,0x1
    10c0:	je     10dd <botlish_fn_15+0x18f>
    10c6:	mov    rsi,QWORD PTR [rsp+0x78]
    10cb:	mov    rdx,rsi
    10ce:	add    rdx,0x2
    10d2:	seto   al
    10d5:	test   al,al
    10d7:	je     10f2 <botlish_fn_15+0x1a4>
    10dd:	mov    edx,0x3
    10e2:	mov    rsi,QWORD PTR [rsp+0x78]
    10e7:	mov    rdi,r15
    10ea:	call   10ef <botlish_fn_15+0x1a1>
			10eb: R_X86_64_PLT32	rt_int_add-0x4
    10ef:	mov    rdx,rax
    10f2:	mov    rsi,rbx
    10f5:	mov    rdi,r15
    10f8:	call   10fd <botlish_fn_15+0x1af>
			10f9: R_X86_64_PLT32	botlish_fn_13-0x4 ; quote_at?<str, int>
    10fd:	test   rax,rax
    1100:	je     1263 <botlish_fn_15+0x315>
    1106:	cmp    rax,0x6
    110a:	je     11c9 <botlish_fn_15+0x27b>
    1110:	xor    rsi,rsi
    1113:	lea    rcx,[rsp+0x48]
    1118:	mov    QWORD PTR [rsp+0x48],0x0
    1121:	mov    QWORD PTR [rsp+0x50],r13
    1126:	mov    edx,0x2
    112b:	mov    rdi,r15
    112e:	call   1133 <botlish_fn_15+0x1e5>
			112f: R_X86_64_PLT32	rt_construct-0x4
    1133:	test   rax,rax
    1136:	je     1263 <botlish_fn_15+0x315>
    113c:	mov    QWORD PTR [rsp],rax
    1140:	mov    r12,rax
    1143:	mov    QWORD PTR [rsp+0x10],0x3
    114c:	mov    rsi,QWORD PTR [rsp+0x78]
    1151:	test   rsi,0x1
    1158:	je     117d <botlish_fn_15+0x22f>
    115e:	mov    rsi,QWORD PTR [rsp+0x78]
    1163:	mov    rdx,rsi
    1166:	add    rdx,0x2
    116a:	seto   al
    116d:	test   al,al
    116f:	jne    117d <botlish_fn_15+0x22f>
    1175:	mov    rax,r12
    1178:	jmp    1195 <botlish_fn_15+0x247>
    117d:	mov    edx,0x3
    1182:	mov    rsi,QWORD PTR [rsp+0x78]
    1187:	mov    rdi,r15
    118a:	call   118f <botlish_fn_15+0x241>
			118b: R_X86_64_PLT32	rt_int_add-0x4
    118f:	mov    rdx,rax
    1192:	mov    rax,r12
    1195:	mov    rbx,QWORD PTR [rsp+0x80]
    119d:	mov    r12,QWORD PTR [rsp+0x88]
    11a5:	mov    r13,QWORD PTR [rsp+0x90]
    11ad:	mov    r14,QWORD PTR [rsp+0x98]
    11b5:	mov    r15,QWORD PTR [rsp+0xa0]
    11bd:	add    rsp,0xb0
    11c4:	mov    rsp,rbp
    11c7:	pop    rbp
    11c8:	ret
    11c9:	mov    QWORD PTR [rsp+0x20],0x5
    11d2:	mov    rsi,QWORD PTR [rsp+0x78]
    11d7:	test   rsi,0x1
    11de:	je     1208 <botlish_fn_15+0x2ba>
    11e4:	mov    rsi,QWORD PTR [rsp+0x78]
    11e9:	mov    rcx,rsi
    11ec:	add    rcx,0x4
    11f0:	seto   al
    11f3:	test   al,al
    11f5:	jne    1208 <botlish_fn_15+0x2ba>
    11fb:	mov    rsi,rcx
    11fe:	mov    QWORD PTR [rsp+0x78],rcx
    1203:	jmp    1222 <botlish_fn_15+0x2d4>
    1208:	mov    edx,0x5
    120d:	mov    rsi,QWORD PTR [rsp+0x78]
    1212:	mov    rdi,r15
    1215:	call   121a <botlish_fn_15+0x2cc>
			1216: R_X86_64_PLT32	rt_int_add-0x4
    121a:	mov    rsi,rax
    121d:	mov    QWORD PTR [rsp+0x78],rax
    1222:	mov    QWORD PTR [rsp+0x8],rsi
    1227:	lea    rcx,[rsp+0x28]
    122c:	mov    QWORD PTR [rsp+0x28],0x0
    1235:	mov    QWORD PTR [rsp+0x30],r13
    123a:	mov    QWORD PTR [rsp+0x38],0x0
    1243:	mov    QWORD PTR [rsp+0x40],r14
    1248:	mov    esi,0x2
    124d:	mov    edx,0x4
    1252:	mov    rdi,r15
    1255:	call   125a <botlish_fn_15+0x30c>
			1256: R_X86_64_PLT32	rt_construct-0x4
    125a:	test   rax,rax
    125d:	jne    129d <botlish_fn_15+0x34f>
    1263:	xor    rdx,rdx
    1266:	mov    rax,rdx
    1269:	mov    rbx,QWORD PTR [rsp+0x80]
    1271:	mov    r12,QWORD PTR [rsp+0x88]
    1279:	mov    r13,QWORD PTR [rsp+0x90]
    1281:	mov    r14,QWORD PTR [rsp+0x98]
    1289:	mov    r15,QWORD PTR [rsp+0xa0]
    1291:	add    rsp,0xb0
    1298:	mov    rsp,rbp
    129b:	pop    rbp
    129c:	ret
    129d:	mov    QWORD PTR [rsp],rbx
    12a1:	mov    rsi,QWORD PTR [rsp+0x78]
    12a6:	mov    QWORD PTR [rsp+0x8],rsi
    12ab:	mov    QWORD PTR [rsp+0x10],rax
    12b0:	mov    r13,rax
    12b3:	jmp    fb4 <botlish_fn_15+0x66>

00000000000012b8 <botlish_entry_15: scan_quoted<str, int, str>>:
    12b8:	push   rbp
    12b9:	mov    rbp,rsp
    12bc:	ud2

00000000000012be <botlish_fn_16: scan_field<str, int>>:
    12be:	push   rbp
    12bf:	mov    rbp,rsp
    12c2:	sub    rsp,0x40
    12c6:	mov    QWORD PTR [rsp+0x20],rbx
    12cb:	mov    QWORD PTR [rsp+0x28],r12
    12d0:	mov    QWORD PTR [rsp+0x30],r13
    12d5:	mov    r12,rdi
    12d8:	mov    r13,rdx
    12db:	mov    QWORD PTR [rsp+0x10],0x0
    12e4:	mov    QWORD PTR [rsp],rsi
    12e8:	mov    rbx,rsi
    12eb:	mov    QWORD PTR [rsp+0x8],rdx
    12f0:	mov    rdx,r13
    12f3:	mov    rsi,rbx
    12f6:	mov    rdi,r12
    12f9:	call   12fe <botlish_fn_16+0x40>
			12fa: R_X86_64_PLT32	botlish_fn_13-0x4 ; quote_at?<str, int>
    12fe:	test   rax,rax
    1301:	je     13b1 <botlish_fn_16+0xf3>
    1307:	cmp    rax,0x6
    130b:	je     1343 <botlish_fn_16+0x85>
    1311:	mov    rcx,r13
    1314:	mov    rsi,rbx
    1317:	mov    rdi,r12
    131a:	mov    rdx,rcx
    131d:	call   1322 <botlish_fn_16+0x64>
			131e: R_X86_64_PLT32	botlish_fn_14-0x4 ; scan_unquoted<str, int, int>
    1322:	test   rax,rax
    1325:	je     13b1 <botlish_fn_16+0xf3>
    132b:	mov    rbx,QWORD PTR [rsp+0x20]
    1330:	mov    r12,QWORD PTR [rsp+0x28]
    1335:	mov    r13,QWORD PTR [rsp+0x30]
    133a:	add    rsp,0x40
    133e:	mov    rsp,rbp
    1341:	pop    rbp
    1342:	ret
    1343:	mov    rcx,r13
    1346:	mov    QWORD PTR [rsp+0x10],0x3
    134f:	test   rcx,0x1
    1356:	jne    1364 <botlish_fn_16+0xa6>
    135c:	mov    r13,rcx
    135f:	jmp    1379 <botlish_fn_16+0xbb>
    1364:	mov    rdx,rcx
    1367:	add    rdx,0x2
    136b:	mov    r13,rcx
    136e:	seto   al
    1371:	test   al,al
    1373:	je     138c <botlish_fn_16+0xce>
    1379:	mov    edx,0x3
    137e:	mov    rsi,r13
    1381:	mov    rdi,r12
    1384:	call   1389 <botlish_fn_16+0xcb>
			1385: R_X86_64_PLT32	rt_int_add-0x4
    1389:	mov    rdx,rax
    138c:	mov    QWORD PTR [rsp+0x8],rdx
    1391:	mov    rdi,r12
    1394:	mov    rax,QWORD PTR [rdi+0x10]
    1398:	mov    rcx,QWORD PTR [rax]
    139b:	mov    QWORD PTR [rsp+0x10],rcx
    13a0:	mov    rsi,rbx
    13a3:	call   13a8 <botlish_fn_16+0xea>
			13a4: R_X86_64_PLT32	botlish_fn_15-0x4 ; scan_quoted<str, int, str>
    13a8:	test   rax,rax
    13ab:	jne    13cf <botlish_fn_16+0x111>
    13b1:	xor    rdx,rdx
    13b4:	mov    rax,rdx
    13b7:	mov    rbx,QWORD PTR [rsp+0x20]
    13bc:	mov    r12,QWORD PTR [rsp+0x28]
    13c1:	mov    r13,QWORD PTR [rsp+0x30]
    13c6:	add    rsp,0x40
    13ca:	mov    rsp,rbp
    13cd:	pop    rbp
    13ce:	ret
    13cf:	mov    rbx,QWORD PTR [rsp+0x20]
    13d4:	mov    r12,QWORD PTR [rsp+0x28]
    13d9:	mov    r13,QWORD PTR [rsp+0x30]
    13de:	add    rsp,0x40
    13e2:	mov    rsp,rbp
    13e5:	pop    rbp
    13e6:	ret

00000000000013e7 <botlish_entry_16: scan_field<str, int>>:
    13e7:	push   rbp
    13e8:	mov    rbp,rsp
    13eb:	ud2
    13ed:	add    BYTE PTR [rax],al
	...

00000000000013f0 <botlish_fn_17: scan_record_rest<str, int, mutarray, int>>:
    13f0:	push   rbp
    13f1:	mov    rbp,rsp
    13f4:	sub    rsp,0x60
    13f8:	mov    QWORD PTR [rsp+0x30],rbx
    13fd:	mov    QWORD PTR [rsp+0x38],r12
    1402:	mov    QWORD PTR [rsp+0x40],r13
    1407:	mov    QWORD PTR [rsp+0x48],r14
    140c:	mov    QWORD PTR [rsp+0x50],r15
    1411:	mov    r13,rdi
    1414:	mov    QWORD PTR [rsp+0x20],0x0
    141d:	mov    QWORD PTR [rsp],rsi
    1421:	mov    QWORD PTR [rsp+0x8],rdx
    1426:	mov    QWORD PTR [rsp+0x10],rcx
    142b:	mov    QWORD PTR [rsp+0x18],r8
    1430:	mov    rbx,rsi
    1433:	mov    r12,rdx
    1436:	mov    r14,r8
    1439:	mov    r15,rcx
    143c:	mov    rdx,QWORD PTR [rbx+0x8]
    1440:	shl    rdx,1
    1443:	or     rdx,0x1
    1447:	mov    rax,r12
    144a:	and    rax,rdx
    144d:	test   rax,0x1
    1453:	jne    1479 <botlish_fn_17+0x89>
    1459:	mov    rsi,r12
    145c:	mov    rdi,r13
    145f:	call   1464 <botlish_fn_17+0x74>
			1460: R_X86_64_PLT32	rt_int_cmp-0x4
    1464:	mov    ecx,0x2
    1469:	test   rax,rax
    146c:	cmovl  rcx,QWORD PTR [rip+0x24c]        # 16c0 <botlish_fn_17+0x2d0>
    1474:	jmp    148c <botlish_fn_17+0x9c>
    1479:	mov    ecx,0x2
    147e:	mov    rax,r12
    1481:	cmp    rax,rdx
    1484:	cmovl  rcx,QWORD PTR [rip+0x234]        # 16c0 <botlish_fn_17+0x2d0>
    148c:	cmp    rcx,0x6
    1490:	je     14a4 <botlish_fn_17+0xb4>
    1496:	mov    rdx,r14
    1499:	mov    rsi,r15
    149c:	mov    rdi,r13
    149f:	jmp    14da <botlish_fn_17+0xea>
    14a4:	mov    rdx,r12
    14a7:	mov    rsi,rbx
    14aa:	mov    rdi,r13
    14ad:	call   14b2 <botlish_fn_17+0xc2>
			14ae: R_X86_64_PLT32	rt_str_char_at-0x4
    14b2:	test   rax,rax
    14b5:	je     161a <botlish_fn_17+0x22a>
    14bb:	cmp    rax,0x164
    14c1:	je     1599 <botlish_fn_17+0x1a9>
    14c7:	cmp    rax,0x54
    14cb:	je     1510 <botlish_fn_17+0x120>
    14d1:	mov    rdx,r14
    14d4:	mov    rsi,r15
    14d7:	mov    rdi,r13
    14da:	mov    rdi,r13
    14dd:	call   14e2 <botlish_fn_17+0xf2>
			14de: R_X86_64_PLT32	botlish_fn_11-0x4 ; geo_finish<mutarray, int>
    14e2:	test   rax,rax
    14e5:	je     161a <botlish_fn_17+0x22a>
    14eb:	mov    rdx,r12
    14ee:	mov    rbx,QWORD PTR [rsp+0x30]
    14f3:	mov    r12,QWORD PTR [rsp+0x38]
    14f8:	mov    r13,QWORD PTR [rsp+0x40]
    14fd:	mov    r14,QWORD PTR [rsp+0x48]
    1502:	mov    r15,QWORD PTR [rsp+0x50]
    1507:	add    rsp,0x60
    150b:	mov    rsp,rbp
    150e:	pop    rbp
    150f:	ret
    1510:	mov    rdx,r14
    1513:	mov    rsi,r15
    1516:	mov    rdi,r13
    1519:	call   151e <botlish_fn_17+0x12e>
			151a: R_X86_64_PLT32	botlish_fn_11-0x4 ; geo_finish<mutarray, int>
    151e:	test   rax,rax
    1521:	je     161a <botlish_fn_17+0x22a>
    1527:	mov    QWORD PTR [rsp],rax
    152b:	mov    r14,rax
    152e:	mov    QWORD PTR [rsp+0x10],0x3
    1537:	mov    rdx,r12
    153a:	test   rdx,0x1
    1541:	je     1561 <botlish_fn_17+0x171>
    1547:	mov    rdx,r12
    154a:	add    rdx,0x2
    154e:	seto   al
    1551:	test   al,al
    1553:	jne    1561 <botlish_fn_17+0x171>
    1559:	mov    rax,r14
    155c:	jmp    1577 <botlish_fn_17+0x187>
    1561:	mov    edx,0x3
    1566:	mov    rsi,r12
    1569:	mov    rdi,r13
    156c:	call   1571 <botlish_fn_17+0x181>
			156d: R_X86_64_PLT32	rt_int_add-0x4
    1571:	mov    rdx,rax
    1574:	mov    rax,r14
    1577:	mov    rbx,QWORD PTR [rsp+0x30]
    157c:	mov    r12,QWORD PTR [rsp+0x38]
    1581:	mov    r13,QWORD PTR [rsp+0x40]
    1586:	mov    r14,QWORD PTR [rsp+0x48]
    158b:	mov    r15,QWORD PTR [rsp+0x50]
    1590:	add    rsp,0x60
    1594:	mov    rsp,rbp
    1597:	pop    rbp
    1598:	ret
    1599:	mov    rsi,r12
    159c:	mov    edx,0x3
    15a1:	mov    r12,rdx
    15a4:	mov    QWORD PTR [rsp+0x20],0x3
    15ad:	test   rsi,0x1
    15b4:	je     15cc <botlish_fn_17+0x1dc>
    15ba:	mov    rdx,rsi
    15bd:	add    rdx,0x2
    15c1:	seto   al
    15c4:	test   al,al
    15c6:	je     15da <botlish_fn_17+0x1ea>
    15cc:	mov    rdx,r12
    15cf:	mov    rdi,r13
    15d2:	call   15d7 <botlish_fn_17+0x1e7>
			15d3: R_X86_64_PLT32	rt_int_add-0x4
    15d7:	mov    rdx,rax
    15da:	mov    QWORD PTR [rsp+0x8],rdx
    15df:	mov    rsi,rbx
    15e2:	mov    rdi,r13
    15e5:	call   15ea <botlish_fn_17+0x1fa>
			15e6: R_X86_64_PLT32	botlish_fn_16-0x4 ; scan_field<str, int>
    15ea:	test   rax,rax
    15ed:	je     161a <botlish_fn_17+0x22a>
    15f3:	mov    QWORD PTR [rsp+0x8],rax
    15f8:	mov    rcx,rax
    15fb:	mov    QWORD PTR [rsp+0x20],rdx
    1600:	mov    rsi,r15
    1603:	mov    r15,rdx
    1606:	mov    rdx,r14
    1609:	mov    rdi,r13
    160c:	call   1611 <botlish_fn_17+0x221>
			160d: R_X86_64_PLT32	botlish_fn_8-0x4 ; geo_append<mutarray, int, str>
    1611:	test   rax,rax
    1614:	jne    1642 <botlish_fn_17+0x252>
    161a:	xor    rdx,rdx
    161d:	mov    rax,rdx
    1620:	mov    rbx,QWORD PTR [rsp+0x30]
    1625:	mov    r12,QWORD PTR [rsp+0x38]
    162a:	mov    r13,QWORD PTR [rsp+0x40]
    162f:	mov    r14,QWORD PTR [rsp+0x48]
    1634:	mov    r15,QWORD PTR [rsp+0x50]
    1639:	add    rsp,0x60
    163d:	mov    rsp,rbp
    1640:	pop    rbp
    1641:	ret
    1642:	mov    QWORD PTR [rsp+0x8],rax
    1647:	mov    QWORD PTR [rsp+0x28],rax
    164c:	mov    QWORD PTR [rsp+0x10],0x3
    1655:	mov    rdx,r14
    1658:	test   rdx,0x1
    165f:	jne    1670 <botlish_fn_17+0x280>
    1665:	mov    rdx,r12
    1668:	mov    rsi,r14
    166b:	jmp    168b <botlish_fn_17+0x29b>
    1670:	mov    rdx,r14
    1673:	mov    rax,rdx
    1676:	add    rax,0x2
    167a:	seto   cl
    167d:	test   cl,cl
    167f:	je     1693 <botlish_fn_17+0x2a3>
    1685:	mov    rdx,r12
    1688:	mov    rsi,r14
    168b:	mov    rdi,r13
    168e:	call   1693 <botlish_fn_17+0x2a3>
			168f: R_X86_64_PLT32	rt_int_add-0x4
    1693:	mov    QWORD PTR [rsp],rbx
    1697:	mov    rdx,r15
    169a:	mov    QWORD PTR [rsp+0x8],rdx
    169f:	mov    rcx,QWORD PTR [rsp+0x28]
    16a4:	mov    QWORD PTR [rsp+0x10],rcx
    16a9:	mov    QWORD PTR [rsp+0x18],rax
    16ae:	mov    r12,rdx
    16b1:	mov    r14,rax
    16b4:	mov    r15,rcx
    16b7:	jmp    143c <botlish_fn_17+0x4c>
    16bc:	add    BYTE PTR [rax],al
    16be:	add    BYTE PTR [rax],al
    16c0:	(bad)
    16c1:	add    BYTE PTR [rax],al
    16c3:	add    BYTE PTR [rax],al
    16c5:	add    BYTE PTR [rax],al
	...

00000000000016c8 <botlish_entry_17: scan_record_rest<str, int, mutarray, int>>:
    16c8:	push   rbp
    16c9:	mov    rbp,rsp
    16cc:	ud2

00000000000016ce <botlish_fn_18: scan_record<str, int>>:
    16ce:	push   rbp
    16cf:	mov    rbp,rsp
    16d2:	sub    rsp,0x40
    16d6:	mov    QWORD PTR [rsp+0x20],rbx
    16db:	mov    QWORD PTR [rsp+0x28],r12
    16e0:	mov    QWORD PTR [rsp+0x30],r14
    16e5:	mov    r14,rdi
    16e8:	mov    QWORD PTR [rsp+0x10],0x0
    16f1:	mov    QWORD PTR [rsp+0x18],0x0
    16fa:	mov    QWORD PTR [rsp],rsi
    16fe:	mov    r12,rsi
    1701:	mov    QWORD PTR [rsp+0x8],rdx
    1706:	mov    rsi,r12
    1709:	mov    rdi,r14
    170c:	call   1711 <botlish_fn_18+0x43>
			170d: R_X86_64_PLT32	botlish_fn_16-0x4 ; scan_field<str, int>
    1711:	test   rax,rax
    1714:	je     1769 <botlish_fn_18+0x9b>
    171a:	mov    QWORD PTR [rsp+0x8],rax
    171f:	mov    rsi,rax
    1722:	mov    QWORD PTR [rsp+0x10],rdx
    1727:	mov    rbx,rdx
    172a:	mov    rdi,r14
    172d:	call   1732 <botlish_fn_18+0x64>
			172e: R_X86_64_PLT32	botlish_fn_1-0x4 ; geo_new<str>
    1732:	test   rax,rax
    1735:	je     1769 <botlish_fn_18+0x9b>
    173b:	mov    QWORD PTR [rsp+0x8],rax
    1740:	mov    rcx,rax
    1743:	mov    r8d,0x3
    1749:	mov    QWORD PTR [rsp+0x18],0x3
    1752:	mov    rdx,rbx
    1755:	mov    rsi,r12
    1758:	mov    rdi,r14
    175b:	call   1760 <botlish_fn_18+0x92>
			175c: R_X86_64_PLT32	botlish_fn_17-0x4 ; scan_record_rest<str, int, mutarray, int>
    1760:	test   rax,rax
    1763:	jne    1787 <botlish_fn_18+0xb9>
    1769:	xor    rdx,rdx
    176c:	mov    rax,rdx
    176f:	mov    rbx,QWORD PTR [rsp+0x20]
    1774:	mov    r12,QWORD PTR [rsp+0x28]
    1779:	mov    r14,QWORD PTR [rsp+0x30]
    177e:	add    rsp,0x40
    1782:	mov    rsp,rbp
    1785:	pop    rbp
    1786:	ret
    1787:	mov    rbx,QWORD PTR [rsp+0x20]
    178c:	mov    r12,QWORD PTR [rsp+0x28]
    1791:	mov    r14,QWORD PTR [rsp+0x30]
    1796:	add    rsp,0x40
    179a:	mov    rsp,rbp
    179d:	pop    rbp
    179e:	ret

000000000000179f <botlish_entry_18: scan_record<str, int>>:
    179f:	push   rbp
    17a0:	mov    rbp,rsp
    17a3:	ud2
    17a5:	add    BYTE PTR [rax],al
	...

00000000000017a8 <botlish_fn_19: scan_records<str, int, mutarray, int>>:
    17a8:	push   rbp
    17a9:	mov    rbp,rsp
    17ac:	sub    rsp,0x60
    17b0:	mov    QWORD PTR [rsp+0x30],rbx
    17b5:	mov    QWORD PTR [rsp+0x38],r12
    17ba:	mov    QWORD PTR [rsp+0x40],r13
    17bf:	mov    QWORD PTR [rsp+0x48],r14
    17c4:	mov    QWORD PTR [rsp+0x50],r15
    17c9:	mov    r13,rdi
    17cc:	mov    QWORD PTR [rsp+0x20],0x0
    17d5:	mov    QWORD PTR [rsp],rsi
    17d9:	mov    QWORD PTR [rsp+0x8],rdx
    17de:	mov    rax,rdx
    17e1:	mov    QWORD PTR [rsp+0x10],rcx
    17e6:	mov    QWORD PTR [rsp+0x18],r8
    17eb:	mov    rbx,rsi
    17ee:	mov    r14,r8
    17f1:	mov    r15,rcx
    17f4:	mov    rdx,QWORD PTR [rbx+0x8]
    17f8:	shl    rdx,1
    17fb:	or     rdx,0x1
    17ff:	mov    r12,rax
    1802:	and    rax,rdx
    1805:	test   rax,0x1
    180b:	jne    1831 <botlish_fn_19+0x89>
    1811:	mov    rsi,r12
    1814:	mov    rdi,r13
    1817:	call   181c <botlish_fn_19+0x74>
			1818: R_X86_64_PLT32	rt_int_cmp-0x4
    181c:	mov    ecx,0x2
    1821:	test   rax,rax
    1824:	cmovge rcx,QWORD PTR [rip+0x12c]        # 1958 <botlish_fn_19+0x1b0>
    182c:	jmp    1841 <botlish_fn_19+0x99>
    1831:	mov    ecx,0x2
    1836:	cmp    r12,rdx
    1839:	cmovge rcx,QWORD PTR [rip+0x117]        # 1958 <botlish_fn_19+0x1b0>
    1841:	cmp    rcx,0x6
    1845:	je     18f3 <botlish_fn_19+0x14b>
    184b:	mov    rdx,r12
    184e:	mov    rsi,rbx
    1851:	mov    rdi,r13
    1854:	call   1859 <botlish_fn_19+0xb1>
			1855: R_X86_64_PLT32	botlish_fn_18-0x4 ; scan_record<str, int>
    1859:	test   rax,rax
    185c:	je     190a <botlish_fn_19+0x162>
    1862:	mov    QWORD PTR [rsp+0x8],rax
    1867:	mov    rcx,rax
    186a:	mov    QWORD PTR [rsp+0x20],rdx
    186f:	mov    rsi,r15
    1872:	mov    r12,rdx
    1875:	mov    rdx,r14
    1878:	mov    rdi,r13
    187b:	call   1880 <botlish_fn_19+0xd8>
			187c: R_X86_64_PLT32	botlish_fn_9-0x4 ; geo_append<mutarray, int, List[str]>
    1880:	test   rax,rax
    1883:	je     190a <botlish_fn_19+0x162>
    1889:	mov    QWORD PTR [rsp+0x8],rax
    188e:	mov    r15,rax
    1891:	mov    QWORD PTR [rsp+0x10],0x3
    189a:	mov    rsi,r14
    189d:	test   rsi,0x1
    18a4:	je     18bf <botlish_fn_19+0x117>
    18aa:	mov    rsi,r14
    18ad:	mov    rax,rsi
    18b0:	add    rax,0x2
    18b4:	seto   cl
    18b7:	test   cl,cl
    18b9:	je     18cf <botlish_fn_19+0x127>
    18bf:	mov    edx,0x3
    18c4:	mov    rsi,r14
    18c7:	mov    rdi,r13
    18ca:	call   18cf <botlish_fn_19+0x127>
			18cb: R_X86_64_PLT32	rt_int_add-0x4
    18cf:	mov    QWORD PTR [rsp],rbx
    18d3:	mov    rdx,r12
    18d6:	mov    QWORD PTR [rsp+0x8],rdx
    18db:	mov    rcx,r15
    18de:	mov    QWORD PTR [rsp+0x10],rcx
    18e3:	mov    QWORD PTR [rsp+0x18],rax
    18e8:	mov    r14,rax
    18eb:	mov    rax,rdx
    18ee:	jmp    17f4 <botlish_fn_19+0x4c>
    18f3:	mov    rdx,r14
    18f6:	mov    rsi,r15
    18f9:	mov    rdi,r13
    18fc:	call   1901 <botlish_fn_19+0x159>
			18fd: R_X86_64_PLT32	botlish_fn_11-0x4 ; geo_finish<mutarray, int>
    1901:	test   rax,rax
    1904:	jne    192f <botlish_fn_19+0x187>
    190a:	xor    rax,rax
    190d:	mov    rbx,QWORD PTR [rsp+0x30]
    1912:	mov    r12,QWORD PTR [rsp+0x38]
    1917:	mov    r13,QWORD PTR [rsp+0x40]
    191c:	mov    r14,QWORD PTR [rsp+0x48]
    1921:	mov    r15,QWORD PTR [rsp+0x50]
    1926:	add    rsp,0x60
    192a:	mov    rsp,rbp
    192d:	pop    rbp
    192e:	ret
    192f:	mov    rbx,QWORD PTR [rsp+0x30]
    1934:	mov    r12,QWORD PTR [rsp+0x38]
    1939:	mov    r13,QWORD PTR [rsp+0x40]
    193e:	mov    r14,QWORD PTR [rsp+0x48]
    1943:	mov    r15,QWORD PTR [rsp+0x50]
    1948:	add    rsp,0x60
    194c:	mov    rsp,rbp
    194f:	pop    rbp
    1950:	ret
    1951:	add    BYTE PTR [rax],al
    1953:	add    BYTE PTR [rax],al
    1955:	add    BYTE PTR [rax],al
    1957:	add    BYTE PTR [rsi],al
    1959:	add    BYTE PTR [rax],al
    195b:	add    BYTE PTR [rax],al
    195d:	add    BYTE PTR [rax],al
	...

0000000000001960 <botlish_entry_19: scan_records<str, int, mutarray, int>>:
    1960:	push   rbp
    1961:	mov    rbp,rsp
    1964:	mov    rsi,QWORD PTR [rdx]
    1967:	mov    r9,QWORD PTR [rdx+0x8]
    196b:	mov    rcx,QWORD PTR [rdx+0x10]
    196f:	mov    r8,QWORD PTR [rdx+0x18]
    1973:	mov    rdx,r9
    1976:	call   197b <botlish_entry_19+0x1b>
			1977: R_X86_64_PLT32	botlish_fn_19-0x4 ; scan_records<str, int, mutarray, int>
    197b:	mov    rsp,rbp
    197e:	pop    rbp
    197f:	ret

0000000000001980 <botlish_fn_20: csv_parse<str>>:
    1980:	push   rbp
    1981:	mov    rbp,rsp
    1984:	sub    rsp,0x40
    1988:	mov    QWORD PTR [rsp+0x20],rbx
    198d:	mov    QWORD PTR [rsp+0x28],r12
    1992:	mov    QWORD PTR [rsp+0x30],r13
    1997:	mov    rbx,rdi
    199a:	mov    QWORD PTR [rsp+0x8],0x0
    19a3:	mov    QWORD PTR [rsp+0x10],0x0
    19ac:	mov    QWORD PTR [rsp+0x18],0x0
    19b5:	mov    QWORD PTR [rsp],rsi
    19b9:	mov    rax,QWORD PTR [rsi+0x8]
    19bd:	mov    r12,rsi
    19c0:	shl    rax,1
    19c3:	or     rax,0x1
    19c7:	sar    rax,1
    19ca:	test   rax,rax
    19cd:	je     1a5c <botlish_fn_20+0xdc>
    19d3:	mov    edx,0x1
    19d8:	mov    QWORD PTR [rsp+0x8],0x1
    19e1:	mov    rsi,r12
    19e4:	mov    rdi,rbx
    19e7:	call   19ec <botlish_fn_20+0x6c>
			19e8: R_X86_64_PLT32	botlish_fn_18-0x4 ; scan_record<str, int>
    19ec:	test   rax,rax
    19ef:	je     1a73 <botlish_fn_20+0xf3>
    19f5:	mov    QWORD PTR [rsp+0x8],rax
    19fa:	mov    rsi,rax
    19fd:	mov    QWORD PTR [rsp+0x10],rdx
    1a02:	mov    r13,rdx
    1a05:	mov    rdi,rbx
    1a08:	call   1a0d <botlish_fn_20+0x8d>
			1a09: R_X86_64_PLT32	botlish_fn_2-0x4 ; geo_new<List[str]>
    1a0d:	test   rax,rax
    1a10:	je     1a73 <botlish_fn_20+0xf3>
    1a16:	mov    QWORD PTR [rsp+0x8],rax
    1a1b:	mov    rcx,rax
    1a1e:	mov    r8d,0x3
    1a24:	mov    QWORD PTR [rsp+0x18],0x3
    1a2d:	mov    rdx,r13
    1a30:	mov    rsi,r12
    1a33:	mov    rdi,rbx
    1a36:	call   1a3b <botlish_fn_20+0xbb>
			1a37: R_X86_64_PLT32	botlish_fn_19-0x4 ; scan_records<str, int, mutarray, int>
    1a3b:	test   rax,rax
    1a3e:	je     1a73 <botlish_fn_20+0xf3>
    1a44:	mov    rbx,QWORD PTR [rsp+0x20]
    1a49:	mov    r12,QWORD PTR [rsp+0x28]
    1a4e:	mov    r13,QWORD PTR [rsp+0x30]
    1a53:	add    rsp,0x40
    1a57:	mov    rsp,rbp
    1a5a:	pop    rbp
    1a5b:	ret
    1a5c:	xor    rdx,rdx
    1a5f:	mov    rdi,rbx
    1a62:	mov    rsi,rdx
    1a65:	call   1a6a <botlish_fn_20+0xea>
			1a66: R_X86_64_PLT32	rt_list_new-0x4
    1a6a:	test   rax,rax
    1a6d:	jne    1a8e <botlish_fn_20+0x10e>
    1a73:	xor    rax,rax
    1a76:	mov    rbx,QWORD PTR [rsp+0x20]
    1a7b:	mov    r12,QWORD PTR [rsp+0x28]
    1a80:	mov    r13,QWORD PTR [rsp+0x30]
    1a85:	add    rsp,0x40
    1a89:	mov    rsp,rbp
    1a8c:	pop    rbp
    1a8d:	ret
    1a8e:	mov    rbx,QWORD PTR [rsp+0x20]
    1a93:	mov    r12,QWORD PTR [rsp+0x28]
    1a98:	mov    r13,QWORD PTR [rsp+0x30]
    1a9d:	add    rsp,0x40
    1aa1:	mov    rsp,rbp
    1aa4:	pop    rbp
    1aa5:	ret

0000000000001aa6 <botlish_entry_20: csv_parse<str>>:
    1aa6:	push   rbp
    1aa7:	mov    rbp,rsp
    1aaa:	mov    rsi,QWORD PTR [rdx]
    1aad:	call   1ab2 <botlish_entry_20+0xc>
			1aae: R_X86_64_PLT32	botlish_fn_20-0x4 ; csv_parse<str>
    1ab2:	mov    rsp,rbp
    1ab5:	pop    rbp
    1ab6:	ret

0000000000001ab7 <botlish_fn_21: ht_alloc<int>>:
    1ab7:	push   rbp
    1ab8:	mov    rbp,rsp
    1abb:	sub    rsp,0x70
    1abf:	mov    QWORD PTR [rsp+0x40],rbx
    1ac4:	mov    QWORD PTR [rsp+0x48],r12
    1ac9:	mov    QWORD PTR [rsp+0x50],r13
    1ace:	mov    QWORD PTR [rsp+0x58],r14
    1ad3:	mov    QWORD PTR [rsp+0x60],r15
    1ad8:	mov    r12,rdi
    1adb:	mov    QWORD PTR [rsp+0x10],0x0
    1ae4:	mov    QWORD PTR [rsp+0x18],0x0
    1aed:	mov    QWORD PTR [rsp],rsi
    1af1:	mov    r13,rsi
    1af4:	mov    esi,0x5
    1af9:	mov    QWORD PTR [rsp+0x8],0x5
    1b02:	mov    rdi,r12
    1b05:	call   1b0a <botlish_fn_21+0x53>
			1b06: R_X86_64_PLT32	rt_mutarray_allocate-0x4
    1b0a:	mov    rcx,rax
    1b0d:	mov    rbx,rax
    1b10:	test   rax,rcx
    1b13:	je     1bac <botlish_fn_21+0xf5>
    1b19:	mov    rax,rbx
    1b1c:	mov    QWORD PTR [rsp+0x8],rax
    1b21:	mov    rcx,QWORD PTR [rax+0x18]
    1b25:	test   rcx,rcx
    1b28:	je     1c29 <botlish_fn_21+0x172>
    1b2e:	mov    rcx,QWORD PTR [rbx+0x10]
    1b32:	mov    QWORD PTR [rcx],0x1
    1b39:	mov    rcx,QWORD PTR [rbx+0x18]
    1b3d:	test   rcx,rcx
    1b40:	je     1c41 <botlish_fn_21+0x18a>
    1b46:	mov    rax,QWORD PTR [rbx+0x10]
    1b4a:	mov    QWORD PTR [rax+0x8],0x1
    1b52:	mov    edx,0x1
    1b57:	mov    QWORD PTR [rsp+0x10],0x1
    1b60:	mov    rsi,r13
    1b63:	mov    rdi,r12
    1b66:	call   1b6b <botlish_fn_21+0xb4>
			1b67: R_X86_64_PLT32	rt_mutarray_create-0x4
    1b6b:	test   rax,rax
    1b6e:	je     1bac <botlish_fn_21+0xf5>
    1b74:	mov    QWORD PTR [rsp+0x10],rax
    1b79:	mov    r14,rax
    1b7c:	mov    rsi,r13
    1b7f:	mov    rdi,r12
    1b82:	call   1b87 <botlish_fn_21+0xd0>
			1b83: R_X86_64_PLT32	rt_mutarray_allocate-0x4
    1b87:	test   rax,rax
    1b8a:	je     1bac <botlish_fn_21+0xf5>
    1b90:	mov    QWORD PTR [rsp+0x18],rax
    1b95:	mov    rsi,r13
    1b98:	mov    r15,rax
    1b9b:	mov    rdi,r12
    1b9e:	call   1ba3 <botlish_fn_21+0xec>
			1b9f: R_X86_64_PLT32	rt_mutarray_allocate-0x4
    1ba3:	test   rax,rax
    1ba6:	jne    1bd1 <botlish_fn_21+0x11a>
    1bac:	xor    rax,rax
    1baf:	mov    rbx,QWORD PTR [rsp+0x40]
    1bb4:	mov    r12,QWORD PTR [rsp+0x48]
    1bb9:	mov    r13,QWORD PTR [rsp+0x50]
    1bbe:	mov    r14,QWORD PTR [rsp+0x58]
    1bc3:	mov    r15,QWORD PTR [rsp+0x60]
    1bc8:	add    rsp,0x70
    1bcc:	mov    rsp,rbp
    1bcf:	pop    rbp
    1bd0:	ret
    1bd1:	mov    QWORD PTR [rsp],rax
    1bd5:	lea    rcx,[rsp+0x20]
    1bda:	mov    rdx,r14
    1bdd:	mov    QWORD PTR [rsp+0x20],rdx
    1be2:	mov    rdx,r15
    1be5:	mov    QWORD PTR [rsp+0x28],rdx
    1bea:	mov    QWORD PTR [rsp+0x30],rax
    1bef:	mov    rax,rbx
    1bf2:	mov    QWORD PTR [rsp+0x38],rax
    1bf7:	xor    rsi,rsi
    1bfa:	mov    edx,0x4
    1bff:	mov    rdi,r12
    1c02:	call   1c07 <botlish_fn_21+0x150>
			1c03: R_X86_64_PLT32	rt_struct_new-0x4
    1c07:	mov    rbx,QWORD PTR [rsp+0x40]
    1c0c:	mov    r12,QWORD PTR [rsp+0x48]
    1c11:	mov    r13,QWORD PTR [rsp+0x50]
    1c16:	mov    r14,QWORD PTR [rsp+0x58]
    1c1b:	mov    r15,QWORD PTR [rsp+0x60]
    1c20:	add    rsp,0x70
    1c24:	mov    rsp,rbp
    1c27:	pop    rbp
    1c28:	ret
    1c29:	mov    ecx,0x1
    1c2e:	mov    rsi,rbx
    1c31:	mov    rdi,r12
    1c34:	mov    rdx,rcx
    1c37:	call   1c3c <botlish_fn_21+0x185>
			1c38: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
    1c3c:	jmp    1b39 <botlish_fn_21+0x82>
    1c41:	mov    edx,0x3
    1c46:	mov    ecx,0x1
    1c4b:	mov    rsi,rbx
    1c4e:	mov    rdi,r12
    1c51:	call   1c56 <botlish_fn_21+0x19f>
			1c52: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
    1c56:	jmp    1b52 <botlish_fn_21+0x9b>

0000000000001c5b <botlish_entry_21: ht_alloc<int>>:
    1c5b:	push   rbp
    1c5c:	mov    rbp,rsp
    1c5f:	mov    rsi,QWORD PTR [rdx]
    1c62:	call   1c67 <botlish_entry_21+0xc>
			1c63: R_X86_64_PLT32	botlish_fn_21-0x4 ; ht_alloc<int>
    1c67:	mov    rsp,rbp
    1c6a:	pop    rbp
    1c6b:	ret

0000000000001c6c <botlish_fn_22: ht_alloc<int>>:
    1c6c:	push   rbp
    1c6d:	mov    rbp,rsp
    1c70:	sub    rsp,0x60
    1c74:	mov    QWORD PTR [rsp+0x30],rbx
    1c79:	mov    QWORD PTR [rsp+0x38],r12
    1c7e:	mov    QWORD PTR [rsp+0x40],r13
    1c83:	mov    QWORD PTR [rsp+0x48],r14
    1c88:	mov    QWORD PTR [rsp+0x50],r15
    1c8d:	mov    r12,rdx
    1c90:	mov    r14,rdi
    1c93:	mov    QWORD PTR [rsp+0x10],0x0
    1c9c:	mov    QWORD PTR [rsp+0x18],0x0
    1ca5:	mov    QWORD PTR [rsp],rsi
    1ca9:	mov    r13,rsi
    1cac:	mov    esi,0x5
    1cb1:	mov    QWORD PTR [rsp+0x8],0x5
    1cba:	mov    rdi,r14
    1cbd:	call   1cc2 <botlish_fn_22+0x56>
			1cbe: R_X86_64_PLT32	rt_mutarray_allocate-0x4
    1cc2:	mov    rcx,rax
    1cc5:	mov    rbx,rax
    1cc8:	test   rax,rcx
    1ccb:	je     1d66 <botlish_fn_22+0xfa>
    1cd1:	mov    rax,rbx
    1cd4:	mov    QWORD PTR [rsp+0x8],rax
    1cd9:	mov    rcx,QWORD PTR [rax+0x18]
    1cdd:	test   rcx,rcx
    1ce0:	je     1dc6 <botlish_fn_22+0x15a>
    1ce6:	mov    rcx,QWORD PTR [rbx+0x10]
    1cea:	mov    QWORD PTR [rcx],0x1
    1cf1:	mov    rcx,QWORD PTR [rbx+0x18]
    1cf5:	test   rcx,rcx
    1cf8:	je     1dde <botlish_fn_22+0x172>
    1cfe:	mov    rax,QWORD PTR [rbx+0x10]
    1d02:	mov    QWORD PTR [rax+0x8],0x1
    1d0a:	mov    edx,0x1
    1d0f:	mov    QWORD PTR [rsp+0x10],0x1
    1d18:	mov    rsi,r13
    1d1b:	mov    rdi,r14
    1d1e:	call   1d23 <botlish_fn_22+0xb7>
			1d1f: R_X86_64_PLT32	rt_mutarray_create-0x4
    1d23:	test   rax,rax
    1d26:	je     1d66 <botlish_fn_22+0xfa>
    1d2c:	mov    QWORD PTR [rsp+0x10],rax
    1d31:	mov    r15,rax
    1d34:	mov    rsi,r13
    1d37:	mov    rdi,r14
    1d3a:	call   1d3f <botlish_fn_22+0xd3>
			1d3b: R_X86_64_PLT32	rt_mutarray_allocate-0x4
    1d3f:	test   rax,rax
    1d42:	je     1d66 <botlish_fn_22+0xfa>
    1d48:	mov    QWORD PTR [rsp+0x18],rax
    1d4d:	mov    rsi,r13
    1d50:	mov    rdi,r14
    1d53:	mov    QWORD PTR [rsp+0x20],rax
    1d58:	call   1d5d <botlish_fn_22+0xf1>
			1d59: R_X86_64_PLT32	rt_mutarray_allocate-0x4
    1d5d:	test   rax,rax
    1d60:	jne    1d8b <botlish_fn_22+0x11f>
    1d66:	xor    rax,rax
    1d69:	mov    rbx,QWORD PTR [rsp+0x30]
    1d6e:	mov    r12,QWORD PTR [rsp+0x38]
    1d73:	mov    r13,QWORD PTR [rsp+0x40]
    1d78:	mov    r14,QWORD PTR [rsp+0x48]
    1d7d:	mov    r15,QWORD PTR [rsp+0x50]
    1d82:	add    rsp,0x60
    1d86:	mov    rsp,rbp
    1d89:	pop    rbp
    1d8a:	ret
    1d8b:	mov    rcx,QWORD PTR [rsp+0x20]
    1d90:	mov    rdx,r12
    1d93:	mov    QWORD PTR [rdx],rcx
    1d96:	mov    QWORD PTR [rdx+0x8],rax
    1d9a:	mov    rax,rbx
    1d9d:	mov    QWORD PTR [rdx+0x10],rax
    1da1:	mov    rax,r15
    1da4:	mov    rbx,QWORD PTR [rsp+0x30]
    1da9:	mov    r12,QWORD PTR [rsp+0x38]
    1dae:	mov    r13,QWORD PTR [rsp+0x40]
    1db3:	mov    r14,QWORD PTR [rsp+0x48]
    1db8:	mov    r15,QWORD PTR [rsp+0x50]
    1dbd:	add    rsp,0x60
    1dc1:	mov    rsp,rbp
    1dc4:	pop    rbp
    1dc5:	ret
    1dc6:	mov    ecx,0x1
    1dcb:	mov    rsi,rbx
    1dce:	mov    rdi,r14
    1dd1:	mov    rdx,rcx
    1dd4:	call   1dd9 <botlish_fn_22+0x16d>
			1dd5: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
    1dd9:	jmp    1cf1 <botlish_fn_22+0x85>
    1dde:	mov    edx,0x3
    1de3:	mov    ecx,0x1
    1de8:	mov    rsi,rbx
    1deb:	mov    rdi,r14
    1dee:	call   1df3 <botlish_fn_22+0x187>
			1def: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
    1df3:	jmp    1d0a <botlish_fn_22+0x9e>

0000000000001df8 <botlish_entry_22: ht_alloc<int>>:
    1df8:	push   rbp
    1df9:	mov    rbp,rsp
    1dfc:	ud2

0000000000001dfe <botlish_fn_23: ht_new<generic>>:
    1dfe:	push   rbp
    1dff:	mov    rbp,rsp
    1e02:	sub    rsp,0x10
    1e06:	mov    esi,0x11
    1e0b:	mov    QWORD PTR [rsp],0x11
    1e13:	call   1e18 <botlish_fn_23+0x1a>
			1e14: R_X86_64_PLT32	botlish_fn_21-0x4 ; ht_alloc<int>
    1e18:	test   rax,rax
    1e1b:	jne    1e2d <botlish_fn_23+0x2f>
    1e21:	xor    rax,rax
    1e24:	add    rsp,0x10
    1e28:	mov    rsp,rbp
    1e2b:	pop    rbp
    1e2c:	ret
    1e2d:	add    rsp,0x10
    1e31:	mov    rsp,rbp
    1e34:	pop    rbp
    1e35:	ret

0000000000001e36 <botlish_entry_23: ht_new<generic>>:
    1e36:	push   rbp
    1e37:	mov    rbp,rsp
    1e3a:	call   1e3f <botlish_entry_23+0x9>
			1e3b: R_X86_64_PLT32	botlish_fn_23-0x4 ; ht_new<generic>
    1e3f:	mov    rsp,rbp
    1e42:	pop    rbp
    1e43:	ret
    1e44:	add    BYTE PTR [rax],al
	...

0000000000001e48 <botlish_fn_24: ht_capacity_for<int, int>>:
    1e48:	push   rbp
    1e49:	mov    rbp,rsp
    1e4c:	sub    rsp,0x50
    1e50:	mov    QWORD PTR [rsp+0x20],rbx
    1e55:	mov    QWORD PTR [rsp+0x28],r12
    1e5a:	mov    QWORD PTR [rsp+0x30],r13
    1e5f:	mov    QWORD PTR [rsp+0x38],r14
    1e64:	mov    QWORD PTR [rsp+0x40],r15
    1e69:	mov    r13,rdi
    1e6c:	mov    QWORD PTR [rsp],rdx
    1e70:	mov    rbx,rsi
    1e73:	or     rbx,0x1
    1e77:	sar    rbx,1
    1e7a:	mov    r12,rsi
    1e7d:	mov    r14,rdx
    1e80:	mov    rax,r12
    1e83:	or     rax,0x1
    1e87:	mov    QWORD PTR [rsp+0x8],rax
    1e8c:	mov    QWORD PTR [rsp+0x10],0x7
    1e95:	mov    rax,rbx
    1e98:	imul   QWORD PTR [rip+0x159]        # 1ff8 <botlish_fn_24+0x1b0>
    1e9f:	seto   cl
    1ea2:	or     rax,0x1
    1ea6:	test   cl,cl
    1ea8:	jne    1eb6 <botlish_fn_24+0x6e>
    1eae:	mov    rsi,rax
    1eb1:	jmp    1ecd <botlish_fn_24+0x85>
    1eb6:	mov    rsi,r12
    1eb9:	or     rsi,0x1
    1ebd:	mov    edx,0x7
    1ec2:	mov    rdi,r13
    1ec5:	call   1eca <botlish_fn_24+0x82>
			1ec6: R_X86_64_PLT32	rt_int_mul-0x4
    1eca:	mov    rsi,rax
    1ecd:	mov    QWORD PTR [rsp+0x8],rsi
    1ed2:	mov    r15,rsi
    1ed5:	mov    QWORD PTR [rsp+0x10],0x5
    1ede:	mov    rsi,r14
    1ee1:	test   rsi,0x1
    1ee8:	je     1f18 <botlish_fn_24+0xd0>
    1eee:	mov    rsi,r14
    1ef1:	mov    rax,rsi
    1ef4:	sar    rax,1
    1ef7:	imul   QWORD PTR [rip+0x102]        # 2000 <botlish_fn_24+0x1b8>
    1efe:	seto   cl
    1f01:	or     rax,0x1
    1f05:	test   cl,cl
    1f07:	jne    1f18 <botlish_fn_24+0xd0>
    1f0d:	mov    rdx,rax
    1f10:	mov    rsi,r15
    1f13:	jmp    1f2e <botlish_fn_24+0xe6>
    1f18:	mov    edx,0x5
    1f1d:	mov    rsi,r14
    1f20:	mov    rdi,r13
    1f23:	call   1f28 <botlish_fn_24+0xe0>
			1f24: R_X86_64_PLT32	rt_int_mul-0x4
    1f28:	mov    rdx,rax
    1f2b:	mov    rsi,r15
    1f2e:	mov    rax,rsi
    1f31:	and    rax,rdx
    1f34:	test   rax,0x1
    1f3a:	jne    1f5d <botlish_fn_24+0x115>
    1f40:	mov    rdi,r13
    1f43:	call   1f48 <botlish_fn_24+0x100>
			1f44: R_X86_64_PLT32	rt_int_cmp-0x4
    1f48:	mov    ecx,0x2
    1f4d:	test   rax,rax
    1f50:	cmovle rcx,QWORD PTR [rip+0xa0]        # 1ff8 <botlish_fn_24+0x1b0>
    1f58:	jmp    1f6d <botlish_fn_24+0x125>
    1f5d:	mov    ecx,0x2
    1f62:	cmp    rsi,rdx
    1f65:	cmovle rcx,QWORD PTR [rip+0x8b]        # 1ff8 <botlish_fn_24+0x1b0>
    1f6d:	cmp    rcx,0x6
    1f71:	je     1fcd <botlish_fn_24+0x185>
    1f77:	mov    QWORD PTR [rsp+0x8],0x5
    1f80:	mov    rsi,r14
    1f83:	test   rsi,0x1
    1f8a:	je     1fb1 <botlish_fn_24+0x169>
    1f90:	mov    rsi,r14
    1f93:	mov    rax,rsi
    1f96:	sar    rax,1
    1f99:	imul   QWORD PTR [rip+0x60]        # 2000 <botlish_fn_24+0x1b8>
    1fa0:	seto   sil
    1fa4:	or     rax,0x1
    1fa8:	test   sil,sil
    1fab:	je     1fc1 <botlish_fn_24+0x179>
    1fb1:	mov    edx,0x5
    1fb6:	mov    rsi,r14
    1fb9:	mov    rdi,r13
    1fbc:	call   1fc1 <botlish_fn_24+0x179>
			1fbd: R_X86_64_PLT32	rt_int_mul-0x4
    1fc1:	mov    QWORD PTR [rsp],rax
    1fc5:	mov    r14,rax
    1fc8:	jmp    1e80 <botlish_fn_24+0x38>
    1fcd:	mov    rax,r14
    1fd0:	mov    rbx,QWORD PTR [rsp+0x20]
    1fd5:	mov    r12,QWORD PTR [rsp+0x28]
    1fda:	mov    r13,QWORD PTR [rsp+0x30]
    1fdf:	mov    r14,QWORD PTR [rsp+0x38]
    1fe4:	mov    r15,QWORD PTR [rsp+0x40]
    1fe9:	add    rsp,0x50
    1fed:	mov    rsp,rbp
    1ff0:	pop    rbp
    1ff1:	ret
    1ff2:	add    BYTE PTR [rax],al
    1ff4:	add    BYTE PTR [rax],al
    1ff6:	add    BYTE PTR [rax],al
    1ff8:	(bad)
    1ff9:	add    BYTE PTR [rax],al
    1ffb:	add    BYTE PTR [rax],al
    1ffd:	add    BYTE PTR [rax],al
    1fff:	add    BYTE PTR [rax+rax*1],al
    2002:	add    BYTE PTR [rax],al
    2004:	add    BYTE PTR [rax],al
	...

0000000000002008 <botlish_entry_24: ht_capacity_for<int, int>>:
    2008:	push   rbp
    2009:	mov    rbp,rsp
    200c:	mov    rsi,QWORD PTR [rdx]
    200f:	mov    rdx,QWORD PTR [rdx+0x8]
    2013:	call   2018 <botlish_entry_24+0x10>
			2014: R_X86_64_PLT32	botlish_fn_24-0x4 ; ht_capacity_for<int, int>
    2018:	mov    rsp,rbp
    201b:	pop    rbp
    201c:	ret

000000000000201d <botlish_fn_25: ht_new_sized<int>>:
    201d:	push   rbp
    201e:	mov    rbp,rsp
    2021:	sub    rsp,0x20
    2025:	mov    QWORD PTR [rsp+0x10],r12
    202a:	mov    r12,rdi
    202d:	mov    QWORD PTR [rsp],rsi
    2031:	mov    edx,0x11
    2036:	mov    QWORD PTR [rsp+0x8],0x11
    203f:	mov    rdi,r12
    2042:	call   2047 <botlish_fn_25+0x2a>
			2043: R_X86_64_PLT32	botlish_fn_24-0x4 ; ht_capacity_for<int, int>
    2047:	mov    QWORD PTR [rsp],rax
    204b:	mov    rsi,rax
    204e:	mov    rdi,r12
    2051:	call   2056 <botlish_fn_25+0x39>
			2052: R_X86_64_PLT32	botlish_fn_21-0x4 ; ht_alloc<int>
    2056:	test   rax,rax
    2059:	jne    2070 <botlish_fn_25+0x53>
    205f:	xor    rax,rax
    2062:	mov    r12,QWORD PTR [rsp+0x10]
    2067:	add    rsp,0x20
    206b:	mov    rsp,rbp
    206e:	pop    rbp
    206f:	ret
    2070:	mov    r12,QWORD PTR [rsp+0x10]
    2075:	add    rsp,0x20
    2079:	mov    rsp,rbp
    207c:	pop    rbp
    207d:	ret

000000000000207e <botlish_entry_25: ht_new_sized<int>>:
    207e:	push   rbp
    207f:	mov    rbp,rsp
    2082:	mov    rsi,QWORD PTR [rdx]
    2085:	call   208a <botlish_entry_25+0xc>
			2086: R_X86_64_PLT32	botlish_fn_25-0x4 ; ht_new_sized<int>
    208a:	mov    rsp,rbp
    208d:	pop    rbp
    208e:	ret

000000000000208f <botlish_fn_26: ht_size<HashTable>>:
    208f:	push   rbp
    2090:	mov    rbp,rsp
    2093:	mov    rax,QWORD PTR [rsi+0x18]
    2097:	mov    rsi,QWORD PTR [rax+0x18]
    209b:	mov    rax,QWORD PTR [rsi+0x8]
    209f:	test   rax,rax
    20a2:	jne    20ba <botlish_fn_26+0x2b>
    20a8:	jmp    20c6 <botlish_fn_26+0x37>
    20ad:	xor    rax,rax
    20b0:	mov    rsp,rbp
    20b3:	pop    rbp
    20b4:	ret
    20b5:	jmp    20c1 <botlish_fn_26+0x32>
    20ba:	mov    rax,QWORD PTR [rsi+0x10]
    20be:	mov    rax,QWORD PTR [rax]
    20c1:	mov    rsp,rbp
    20c4:	pop    rbp
    20c5:	ret
    20c6:	mov    edx,0x1
    20cb:	call   20d0 <botlish_fn_26+0x41>
			20cc: R_X86_64_PLT32	rt_mutarray_get-0x4
    20d0:	test   rax,rax
    20d3:	jne    20c1 <botlish_fn_26+0x32>
    20d9:	jmp    20ad <botlish_fn_26+0x1e>

00000000000020de <botlish_entry_26: ht_size<HashTable>>:
    20de:	push   rbp
    20df:	mov    rbp,rsp
    20e2:	mov    rsi,QWORD PTR [rdx]
    20e5:	call   20ea <botlish_entry_26+0xc>
			20e6: R_X86_64_PLT32	botlish_fn_26-0x4 ; ht_size<HashTable>
    20ea:	mov    rsp,rbp
    20ed:	pop    rbp
    20ee:	ret

00000000000020ef <botlish_fn_27: ht_tombstones<HashTable>>:
    20ef:	push   rbp
    20f0:	mov    rbp,rsp
    20f3:	mov    rax,QWORD PTR [rsi+0x18]
    20f7:	mov    rsi,QWORD PTR [rax+0x18]
    20fb:	mov    rax,QWORD PTR [rsi+0x8]
    20ff:	cmp    rax,0x1
    2103:	ja     211b <botlish_fn_27+0x2c>
    2109:	jmp    2128 <botlish_fn_27+0x39>
    210e:	xor    rax,rax
    2111:	mov    rsp,rbp
    2114:	pop    rbp
    2115:	ret
    2116:	jmp    2123 <botlish_fn_27+0x34>
    211b:	mov    rax,QWORD PTR [rsi+0x10]
    211f:	mov    rax,QWORD PTR [rax+0x8]
    2123:	mov    rsp,rbp
    2126:	pop    rbp
    2127:	ret
    2128:	mov    edx,0x3
    212d:	call   2132 <botlish_fn_27+0x43>
			212e: R_X86_64_PLT32	rt_mutarray_get-0x4
    2132:	test   rax,rax
    2135:	jne    2123 <botlish_fn_27+0x34>
    213b:	jmp    210e <botlish_fn_27+0x1f>

0000000000002140 <botlish_entry_27: ht_tombstones<HashTable>>:
    2140:	push   rbp
    2141:	mov    rbp,rsp
    2144:	mov    rsi,QWORD PTR [rdx]
    2147:	call   214c <botlish_entry_27+0xc>
			2148: R_X86_64_PLT32	botlish_fn_27-0x4 ; ht_tombstones<HashTable>
    214c:	mov    rsp,rbp
    214f:	pop    rbp
    2150:	ret

0000000000002151 <botlish_fn_28: ht_capacity<HashTable>>:
    2151:	push   rbp
    2152:	mov    rbp,rsp
    2155:	mov    rdi,QWORD PTR [rsi+0x18]
    2159:	mov    rdi,QWORD PTR [rdi]
    215c:	mov    rax,QWORD PTR [rdi+0x8]
    2160:	shl    rax,1
    2163:	or     rax,0x1
    2167:	mov    rsp,rbp
    216a:	pop    rbp
    216b:	ret

000000000000216c <botlish_entry_28: ht_capacity<HashTable>>:
    216c:	push   rbp
    216d:	mov    rbp,rsp
    2170:	mov    rsi,QWORD PTR [rdx]
    2173:	call   2178 <botlish_entry_28+0xc>
			2174: R_X86_64_PLT32	botlish_fn_28-0x4 ; ht_capacity<HashTable>
    2178:	mov    rsp,rbp
    217b:	pop    rbp
    217c:	ret

000000000000217d <botlish_fn_29: ht_probe_start<HashTable, str>>:
    217d:	push   rbp
    217e:	mov    rbp,rsp
    2181:	sub    rsp,0x20
    2185:	mov    QWORD PTR [rsp],rbx
    2189:	mov    QWORD PTR [rsp+0x8],r12
    218e:	mov    QWORD PTR [rsp+0x10],r13
    2193:	mov    rbx,rdi
    2196:	mov    r13,rsi
    2199:	mov    rsi,rdx
    219c:	mov    rdi,rbx
    219f:	call   21a4 <botlish_fn_29+0x27>
			21a0: R_X86_64_PLT32	rt_hash-0x4
    21a4:	test   rax,rax
    21a7:	mov    r12,rax
    21aa:	je     21cf <botlish_fn_29+0x52>
    21b0:	mov    rsi,r13
    21b3:	mov    rdi,rbx
    21b6:	call   21bb <botlish_fn_29+0x3e>
			21b7: R_X86_64_PLT32	botlish_fn_28-0x4 ; ht_capacity<HashTable>
    21bb:	sar    rax,1
    21be:	test   rax,rax
    21c1:	mov    rcx,rax
    21c4:	jne    21e9 <botlish_fn_29+0x6c>
    21ca:	jmp    223d <botlish_fn_29+0xc0>
    21cf:	xor    rax,rax
    21d2:	mov    rbx,QWORD PTR [rsp]
    21d6:	mov    r12,QWORD PTR [rsp+0x8]
    21db:	mov    r13,QWORD PTR [rsp+0x10]
    21e0:	add    rsp,0x20
    21e4:	mov    rsp,rbp
    21e7:	pop    rbp
    21e8:	ret
    21e9:	mov    rax,r12
    21ec:	sar    rax,1
    21ef:	cqo
    21f1:	cmp    rcx,0xffffffffffffffff
    21f5:	jne    2205 <botlish_fn_29+0x88>
    21fb:	mov    edx,0x0
    2200:	jmp    2208 <botlish_fn_29+0x8b>
    2205:	idiv   rcx
    2208:	mov    rax,rcx
    220b:	neg    rax
    220e:	cmovs  rax,rcx
    2212:	add    rax,rdx
    2215:	test   rdx,rdx
    2218:	cmovl  rdx,rax
    221c:	shl    rdx,1
    221f:	mov    rax,rdx
    2222:	or     rax,0x1
    2226:	mov    rbx,QWORD PTR [rsp]
    222a:	mov    r12,QWORD PTR [rsp+0x8]
    222f:	mov    r13,QWORD PTR [rsp+0x10]
    2234:	add    rsp,0x20
    2238:	mov    rsp,rbp
    223b:	pop    rbp
    223c:	ret
    223d:	mov    edx,0x1
    2242:	mov    rax,r12
    2245:	mov    rsi,rax
    2248:	or     rsi,0x1
    224c:	mov    rdi,rbx
    224f:	call   2254 <botlish_fn_29+0xd7>
			2250: R_X86_64_PLT32	rt_int_mod-0x4
    2254:	jmp    21cf <botlish_fn_29+0x52>

0000000000002259 <botlish_entry_29: ht_probe_start<HashTable, str>>:
    2259:	push   rbp
    225a:	mov    rbp,rsp
    225d:	mov    rsi,QWORD PTR [rdx]
    2260:	mov    rdx,QWORD PTR [rdx+0x8]
    2264:	call   2269 <botlish_entry_29+0x10>
			2265: R_X86_64_PLT32	botlish_fn_29-0x4 ; ht_probe_start<HashTable, str>
    2269:	mov    rsp,rbp
    226c:	pop    rbp
    226d:	ret

000000000000226e <botlish_fn_30: ht_probe_next<HashTable, int>>:
    226e:	push   rbp
    226f:	mov    rbp,rsp
    2272:	sub    rsp,0x10
    2276:	mov    QWORD PTR [rsp],rbx
    227a:	mov    QWORD PTR [rsp+0x8],r12
    227f:	mov    rbx,rdi
    2282:	mov    r12,rdx
    2285:	mov    rdi,rbx
    2288:	call   228d <botlish_fn_30+0x1f>
			2289: R_X86_64_PLT32	botlish_fn_28-0x4 ; ht_capacity<HashTable>
    228d:	sar    rax,1
    2290:	test   rax,rax
    2293:	mov    rsi,rax
    2296:	jne    22b9 <botlish_fn_30+0x4b>
    229c:	jmp    230e <botlish_fn_30+0xa0>
    22a1:	xor    rdx,rdx
    22a4:	mov    rax,rdx
    22a7:	mov    rbx,QWORD PTR [rsp]
    22ab:	mov    r12,QWORD PTR [rsp+0x8]
    22b0:	add    rsp,0x10
    22b4:	mov    rsp,rbp
    22b7:	pop    rbp
    22b8:	ret
    22b9:	mov    rax,r12
    22bc:	mov    ecx,0x1
    22c1:	add    rax,0x1
    22c8:	cqo
    22ca:	cmp    rsi,0xffffffffffffffff
    22ce:	jne    22de <botlish_fn_30+0x70>
    22d4:	mov    edx,0x0
    22d9:	jmp    22e1 <botlish_fn_30+0x73>
    22de:	idiv   rsi
    22e1:	mov    rax,rsi
    22e4:	neg    rax
    22e7:	cmovs  rax,rsi
    22eb:	lea    rsi,[rdx+rax*1]
    22ef:	test   rdx,rdx
    22f2:	mov    rax,rdx
    22f5:	cmovl  rax,rsi
    22f9:	mov    rdx,rcx
    22fc:	mov    rbx,QWORD PTR [rsp]
    2300:	mov    r12,QWORD PTR [rsp+0x8]
    2305:	add    rsp,0x10
    2309:	mov    rsp,rbp
    230c:	pop    rbp
    230d:	ret
    230e:	mov    edx,0x1
    2313:	mov    rax,r12
    2316:	lea    rsi,[rax+0x1]
    231a:	shl    rsi,1
    231d:	or     rsi,0x1
    2321:	mov    rdi,rbx
    2324:	call   2329 <botlish_fn_30+0xbb>
			2325: R_X86_64_PLT32	rt_int_mod-0x4
    2329:	jmp    22a1 <botlish_fn_30+0x33>

000000000000232e <botlish_entry_30: ht_probe_next<HashTable, int>>:
    232e:	push   rbp
    232f:	mov    rbp,rsp
    2332:	mov    rsi,QWORD PTR [rdx]
    2335:	mov    rdx,QWORD PTR [rdx+0x8]
    2339:	sar    rdx,1
    233c:	call   2341 <botlish_entry_30+0x13>
			233d: R_X86_64_PLT32	botlish_fn_30-0x4 ; ht_probe_next<HashTable, int>
    2341:	shl    rax,1
    2344:	or     rax,0x1
    2348:	mov    rcx,rax
    234b:	xor    rax,rax
    234e:	test   rdx,rdx
    2351:	cmovne rax,rcx
    2355:	mov    rsp,rbp
    2358:	pop    rbp
    2359:	ret
    235a:	add    BYTE PTR [rax],al
    235c:	add    BYTE PTR [rax],al
	...

0000000000002360 <botlish_fn_31: ht_find_get<HashTable, str, int>>:
    2360:	push   rbp
    2361:	mov    rbp,rsp
    2364:	sub    rsp,0x30
    2368:	mov    QWORD PTR [rsp],rbx
    236c:	mov    QWORD PTR [rsp+0x8],r12
    2371:	mov    QWORD PTR [rsp+0x10],r13
    2376:	mov    QWORD PTR [rsp+0x18],r14
    237b:	mov    QWORD PTR [rsp+0x20],r15
    2380:	mov    rbx,rdx
    2383:	mov    r13,rdi
    2386:	sar    rcx,1
    2389:	mov    rdi,rcx
    238c:	mov    r12,rsi
    238f:	mov    rax,QWORD PTR [r12+0x18]
    2394:	mov    rsi,QWORD PTR [rax]
    2397:	mov    rcx,QWORD PTR [rsi+0x8]
    239b:	mov    rax,rdi
    239e:	shl    rax,1
    23a1:	or     rax,0x1
    23a5:	sar    rax,1
    23a8:	cmp    rax,rcx
    23ab:	jb     23be <botlish_fn_31+0x5e>
    23b1:	jmp    2585 <botlish_fn_31+0x225>
    23b6:	mov    rsi,rax
    23b9:	jmp    23c9 <botlish_fn_31+0x69>
    23be:	mov    r14,rdi
    23c1:	mov    rcx,QWORD PTR [rsi+0x10]
    23c5:	mov    rsi,QWORD PTR [rcx+rax*8]
    23c9:	test   rsi,0x1
    23d0:	mov    r15,rsi
    23d3:	jne    2401 <botlish_fn_31+0xa1>
    23d9:	mov    edx,0x1
    23de:	mov    rsi,r15
    23e1:	mov    rdi,r13
    23e4:	call   23e9 <botlish_fn_31+0x89>
			23e5: R_X86_64_PLT32	rt_int_cmp-0x4
    23e9:	mov    ecx,0x2
    23ee:	test   rax,rax
    23f1:	cmove  rcx,QWORD PTR [rip+0x1d7]        # 25d0 <botlish_fn_31+0x270>
    23f9:	mov    rsi,r15
    23fc:	jmp    2415 <botlish_fn_31+0xb5>
    2401:	mov    ecx,0x2
    2406:	mov    rsi,r15
    2409:	cmp    rsi,0x1
    240d:	cmove  rcx,QWORD PTR [rip+0x1bb]        # 25d0 <botlish_fn_31+0x270>
    2415:	cmp    rcx,0x6
    2419:	je     255d <botlish_fn_31+0x1fd>
    241f:	test   rsi,0x1
    2426:	jne    244e <botlish_fn_31+0xee>
    242c:	mov    edx,0x3
    2431:	mov    rdi,r13
    2434:	call   2439 <botlish_fn_31+0xd9>
			2435: R_X86_64_PLT32	rt_int_cmp-0x4
    2439:	mov    ecx,0x2
    243e:	test   rax,rax
    2441:	cmove  rcx,QWORD PTR [rip+0x187]        # 25d0 <botlish_fn_31+0x270>
    2449:	jmp    245f <botlish_fn_31+0xff>
    244e:	mov    ecx,0x2
    2453:	cmp    rsi,0x3
    2457:	cmove  rcx,QWORD PTR [rip+0x171]        # 25d0 <botlish_fn_31+0x270>
    245f:	cmp    rcx,0x6
    2463:	jne    24ec <botlish_fn_31+0x18c>
    2469:	mov    rax,QWORD PTR [r12+0x18]
    246e:	mov    rsi,QWORD PTR [rax+0x8]
    2472:	mov    rcx,QWORD PTR [rsi+0x8]
    2476:	mov    rdi,r14
    2479:	mov    rax,rdi
    247c:	shl    rax,1
    247f:	or     rax,0x1
    2483:	sar    rax,1
    2486:	cmp    rax,rcx
    2489:	jb     249c <botlish_fn_31+0x13c>
    248f:	jmp    25a8 <botlish_fn_31+0x248>
    2494:	mov    rsi,rax
    2497:	jmp    24a7 <botlish_fn_31+0x147>
    249c:	mov    r14,rdi
    249f:	mov    rcx,QWORD PTR [rsi+0x10]
    24a3:	mov    rsi,QWORD PTR [rcx+rax*8]
    24a7:	mov    rax,rsi
    24aa:	and    rax,rbx
    24ad:	test   rax,0x1
    24b3:	jne    24d2 <botlish_fn_31+0x172>
    24b9:	mov    rdx,rbx
    24bc:	mov    rdi,r13
    24bf:	call   24c4 <botlish_fn_31+0x164>
			24c0: R_X86_64_PLT32	rt_value_eq-0x4
    24c4:	test   rax,rax
    24c7:	je     2503 <botlish_fn_31+0x1a3>
    24cd:	jmp    24e2 <botlish_fn_31+0x182>
    24d2:	mov    eax,0x2
    24d7:	cmp    rsi,rbx
    24da:	cmove  rax,QWORD PTR [rip+0xee]        # 25d0 <botlish_fn_31+0x270>
    24e2:	cmp    rax,0x6
    24e6:	je     252f <botlish_fn_31+0x1cf>
    24ec:	mov    rdx,r14
    24ef:	mov    rsi,r12
    24f2:	mov    rdi,r13
    24f5:	call   24fa <botlish_fn_31+0x19a>
			24f6: R_X86_64_PLT32	botlish_fn_30-0x4 ; ht_probe_next<HashTable, int>
    24fa:	test   rdx,rdx
    24fd:	jne    2527 <botlish_fn_31+0x1c7>
    2503:	xor    rax,rax
    2506:	mov    rbx,QWORD PTR [rsp]
    250a:	mov    r12,QWORD PTR [rsp+0x8]
    250f:	mov    r13,QWORD PTR [rsp+0x10]
    2514:	mov    r14,QWORD PTR [rsp+0x18]
    2519:	mov    r15,QWORD PTR [rsp+0x20]
    251e:	add    rsp,0x30
    2522:	mov    rsp,rbp
    2525:	pop    rbp
    2526:	ret
    2527:	mov    rdi,rax
    252a:	jmp    238f <botlish_fn_31+0x2f>
    252f:	mov    rdx,r14
    2532:	shl    rdx,1
    2535:	mov    rax,rdx
    2538:	or     rax,0x1
    253c:	mov    rbx,QWORD PTR [rsp]
    2540:	mov    r12,QWORD PTR [rsp+0x8]
    2545:	mov    r13,QWORD PTR [rsp+0x10]
    254a:	mov    r14,QWORD PTR [rsp+0x18]
    254f:	mov    r15,QWORD PTR [rsp+0x20]
    2554:	add    rsp,0x30
    2558:	mov    rsp,rbp
    255b:	pop    rbp
    255c:	ret
    255d:	mov    rax,0xffffffffffffffff
    2564:	mov    rbx,QWORD PTR [rsp]
    2568:	mov    r12,QWORD PTR [rsp+0x8]
    256d:	mov    r13,QWORD PTR [rsp+0x10]
    2572:	mov    r14,QWORD PTR [rsp+0x18]
    2577:	mov    r15,QWORD PTR [rsp+0x20]
    257c:	add    rsp,0x30
    2580:	mov    rsp,rbp
    2583:	pop    rbp
    2584:	ret
    2585:	mov    rdx,rdi
    2588:	shl    rdx,1
    258b:	mov    r14,rdi
    258e:	or     rdx,0x1
    2592:	mov    rdi,r13
    2595:	call   259a <botlish_fn_31+0x23a>
			2596: R_X86_64_PLT32	rt_mutarray_get-0x4
    259a:	test   rax,rax
    259d:	jne    23b6 <botlish_fn_31+0x56>
    25a3:	jmp    2503 <botlish_fn_31+0x1a3>
    25a8:	mov    rdx,rdi
    25ab:	shl    rdx,1
    25ae:	mov    r14,rdi
    25b1:	or     rdx,0x1
    25b5:	mov    rdi,r13
    25b8:	call   25bd <botlish_fn_31+0x25d>
			25b9: R_X86_64_PLT32	rt_mutarray_get-0x4
    25bd:	test   rax,rax
    25c0:	jne    2494 <botlish_fn_31+0x134>
    25c6:	jmp    2503 <botlish_fn_31+0x1a3>
    25cb:	add    BYTE PTR [rax],al
    25cd:	add    BYTE PTR [rax],al
    25cf:	add    BYTE PTR [rsi],al
    25d1:	add    BYTE PTR [rax],al
    25d3:	add    BYTE PTR [rax],al
    25d5:	add    BYTE PTR [rax],al
	...

00000000000025d8 <botlish_entry_31: ht_find_get<HashTable, str, int>>:
    25d8:	push   rbp
    25d9:	mov    rbp,rsp
    25dc:	mov    rsi,QWORD PTR [rdx]
    25df:	mov    r8,QWORD PTR [rdx+0x8]
    25e3:	mov    rcx,QWORD PTR [rdx+0x10]
    25e7:	mov    rdx,r8
    25ea:	call   25ef <botlish_entry_31+0x17>
			25eb: R_X86_64_PLT32	botlish_fn_31-0x4 ; ht_find_get<HashTable, str, int>
    25ef:	mov    rsp,rbp
    25f2:	pop    rbp
    25f3:	ret
    25f4:	add    BYTE PTR [rax],al
	...

00000000000025f8 <botlish_fn_32: ht_find_insert<HashTable, str, int, int>>:
    25f8:	push   rbp
    25f9:	mov    rbp,rsp
    25fc:	sub    rsp,0x40
    2600:	mov    QWORD PTR [rsp+0x10],rbx
    2605:	mov    QWORD PTR [rsp+0x18],r12
    260a:	mov    QWORD PTR [rsp+0x20],r13
    260f:	mov    QWORD PTR [rsp+0x28],r14
    2614:	mov    QWORD PTR [rsp+0x30],r15
    2619:	mov    r14,rdi
    261c:	mov    r15,rdx
    261f:	sar    rcx,1
    2622:	mov    rbx,rsi
    2625:	mov    r12,rcx
    2628:	mov    r13,r8
    262b:	mov    rax,QWORD PTR [rbx+0x18]
    262f:	mov    rsi,QWORD PTR [rax]
    2632:	mov    rdx,QWORD PTR [rsi+0x8]
    2636:	mov    rcx,r12
    2639:	shl    rcx,1
    263c:	or     rcx,0x1
    2640:	sar    rcx,1
    2643:	cmp    rcx,rdx
    2646:	jb     2659 <botlish_fn_32+0x61>
    264c:	jmp    2999 <botlish_fn_32+0x3a1>
    2651:	mov    rsi,rax
    2654:	jmp    2661 <botlish_fn_32+0x69>
    2659:	mov    rax,QWORD PTR [rsi+0x10]
    265d:	mov    rsi,QWORD PTR [rax+rcx*8]
    2661:	test   rsi,0x1
    2668:	mov    QWORD PTR [rsp],rsi
    266c:	jne    2698 <botlish_fn_32+0xa0>
    2672:	mov    edx,0x1
    2677:	mov    rsi,QWORD PTR [rsp]
    267b:	mov    rdi,r14
    267e:	call   2683 <botlish_fn_32+0x8b>
			267f: R_X86_64_PLT32	rt_int_cmp-0x4
    2683:	mov    ecx,0x2
    2688:	test   rax,rax
    268b:	cmove  rcx,QWORD PTR [rip+0x34d]        # 29e0 <botlish_fn_32+0x3e8>
    2693:	jmp    26ad <botlish_fn_32+0xb5>
    2698:	mov    ecx,0x2
    269d:	mov    rsi,QWORD PTR [rsp]
    26a1:	cmp    rsi,0x1
    26a5:	cmove  rcx,QWORD PTR [rip+0x333]        # 29e0 <botlish_fn_32+0x3e8>
    26ad:	cmp    rcx,0x6
    26b1:	je     28ed <botlish_fn_32+0x2f5>
    26b7:	mov    rsi,QWORD PTR [rsp]
    26bb:	test   rsi,0x1
    26c2:	jne    26ee <botlish_fn_32+0xf6>
    26c8:	mov    edx,0x3
    26cd:	mov    rsi,QWORD PTR [rsp]
    26d1:	mov    rdi,r14
    26d4:	call   26d9 <botlish_fn_32+0xe1>
			26d5: R_X86_64_PLT32	rt_int_cmp-0x4
    26d9:	mov    ecx,0x2
    26de:	test   rax,rax
    26e1:	cmove  rcx,QWORD PTR [rip+0x2f7]        # 29e0 <botlish_fn_32+0x3e8>
    26e9:	jmp    2703 <botlish_fn_32+0x10b>
    26ee:	mov    ecx,0x2
    26f3:	mov    rsi,QWORD PTR [rsp]
    26f7:	cmp    rsi,0x3
    26fb:	cmove  rcx,QWORD PTR [rip+0x2dd]        # 29e0 <botlish_fn_32+0x3e8>
    2703:	cmp    rcx,0x6
    2707:	je     271e <botlish_fn_32+0x126>
    270d:	mov    QWORD PTR [rsp+0x8],r12
    2712:	mov    r12,r15
    2715:	mov    rsi,QWORD PTR [rsp]
    2719:	jmp    27a9 <botlish_fn_32+0x1b1>
    271e:	mov    rax,QWORD PTR [rbx+0x18]
    2722:	mov    rsi,QWORD PTR [rax+0x8]
    2726:	mov    rax,QWORD PTR [rsi+0x8]
    272a:	mov    rcx,r12
    272d:	shl    rcx,1
    2730:	or     rcx,0x1
    2734:	sar    rcx,1
    2737:	cmp    rcx,rax
    273a:	jb     2750 <botlish_fn_32+0x158>
    2740:	jmp    29b9 <botlish_fn_32+0x3c1>
    2745:	mov    rsi,rax
    2748:	mov    r12,r15
    274b:	jmp    2760 <botlish_fn_32+0x168>
    2750:	mov    QWORD PTR [rsp+0x8],r12
    2755:	mov    rax,QWORD PTR [rsi+0x10]
    2759:	mov    rsi,QWORD PTR [rax+rcx*8]
    275d:	mov    r12,r15
    2760:	mov    rax,rsi
    2763:	and    rax,r12
    2766:	test   rax,0x1
    276c:	jne    278b <botlish_fn_32+0x193>
    2772:	mov    rdx,r12
    2775:	mov    rdi,r14
    2778:	call   277d <botlish_fn_32+0x185>
			2779: R_X86_64_PLT32	rt_value_eq-0x4
    277d:	test   rax,rax
    2780:	je     2898 <botlish_fn_32+0x2a0>
    2786:	jmp    279b <botlish_fn_32+0x1a3>
    278b:	mov    eax,0x2
    2790:	cmp    rsi,r12
    2793:	cmove  rax,QWORD PTR [rip+0x245]        # 29e0 <botlish_fn_32+0x3e8>
    279b:	cmp    rax,0x6
    279f:	je     28e3 <botlish_fn_32+0x2eb>
    27a5:	mov    rsi,QWORD PTR [rsp]
    27a9:	test   rsi,0x1
    27b0:	jne    27dc <botlish_fn_32+0x1e4>
    27b6:	mov    edx,0x5
    27bb:	mov    rsi,QWORD PTR [rsp]
    27bf:	mov    rdi,r14
    27c2:	call   27c7 <botlish_fn_32+0x1cf>
			27c3: R_X86_64_PLT32	rt_int_cmp-0x4
    27c7:	mov    ecx,0x2
    27cc:	test   rax,rax
    27cf:	cmove  rcx,QWORD PTR [rip+0x209]        # 29e0 <botlish_fn_32+0x3e8>
    27d7:	jmp    27f1 <botlish_fn_32+0x1f9>
    27dc:	mov    ecx,0x2
    27e1:	mov    rsi,QWORD PTR [rsp]
    27e5:	cmp    rsi,0x5
    27e9:	cmove  rcx,QWORD PTR [rip+0x1ef]        # 29e0 <botlish_fn_32+0x3e8>
    27f1:	cmp    rcx,0x6
    27f5:	je     2805 <botlish_fn_32+0x20d>
    27fb:	mov    rdx,QWORD PTR [rsp+0x8]
    2800:	jmp    2856 <botlish_fn_32+0x25e>
    2805:	test   r13,0x1
    280c:	jne    2837 <botlish_fn_32+0x23f>
    2812:	mov    edx,0x1
    2817:	mov    rsi,r13
    281a:	mov    rdi,r14
    281d:	call   2822 <botlish_fn_32+0x22a>
			281e: R_X86_64_PLT32	rt_int_cmp-0x4
    2822:	mov    ecx,0x2
    2827:	test   rax,rax
    282a:	cmovl  rcx,QWORD PTR [rip+0x1ae]        # 29e0 <botlish_fn_32+0x3e8>
    2832:	jmp    2847 <botlish_fn_32+0x24f>
    2837:	mov    ecx,0x2
    283c:	test   r13,r13
    283f:	cmovle rcx,QWORD PTR [rip+0x199]        # 29e0 <botlish_fn_32+0x3e8>
    2847:	cmp    rcx,0x6
    284b:	je     287c <botlish_fn_32+0x284>
    2851:	mov    rdx,QWORD PTR [rsp+0x8]
    2856:	mov    rsi,rbx
    2859:	mov    rdi,r14
    285c:	call   2861 <botlish_fn_32+0x269>
			285d: R_X86_64_PLT32	botlish_fn_30-0x4 ; ht_probe_next<HashTable, int>
    2861:	mov    QWORD PTR [rsp+0x8],rax
    2866:	test   rdx,rdx
    2869:	je     2898 <botlish_fn_32+0x2a0>
    286f:	mov    r15,r12
    2872:	mov    r12,QWORD PTR [rsp+0x8]
    2877:	jmp    262b <botlish_fn_32+0x33>
    287c:	mov    rdx,QWORD PTR [rsp+0x8]
    2881:	mov    rsi,rbx
    2884:	mov    rdi,r14
    2887:	call   288c <botlish_fn_32+0x294>
			2888: R_X86_64_PLT32	botlish_fn_30-0x4 ; ht_probe_next<HashTable, int>
    288c:	mov    rcx,rax
    288f:	test   rdx,rdx
    2892:	jne    28bd <botlish_fn_32+0x2c5>
    2898:	xor    rax,rax
    289b:	mov    rbx,QWORD PTR [rsp+0x10]
    28a0:	mov    r12,QWORD PTR [rsp+0x18]
    28a5:	mov    r13,QWORD PTR [rsp+0x20]
    28aa:	mov    r14,QWORD PTR [rsp+0x28]
    28af:	mov    r15,QWORD PTR [rsp+0x30]
    28b4:	add    rsp,0x40
    28b8:	mov    rsp,rbp
    28bb:	pop    rbp
    28bc:	ret
    28bd:	mov    rax,QWORD PTR [rsp+0x8]
    28c2:	shl    rax,1
    28c5:	mov    QWORD PTR [rsp+0x8],rax
    28ca:	or     rax,0x1
    28ce:	mov    QWORD PTR [rsp+0x8],rax
    28d3:	mov    r15,r12
    28d6:	mov    r13,QWORD PTR [rsp+0x8]
    28db:	mov    r12,rcx
    28de:	jmp    262b <botlish_fn_32+0x33>
    28e3:	mov    rax,QWORD PTR [rsp+0x8]
    28e8:	jmp    294b <botlish_fn_32+0x353>
    28ed:	mov    rax,r13
    28f0:	mov    QWORD PTR [rsp+0x8],r12
    28f5:	test   rax,0x1
    28fb:	jne    2926 <botlish_fn_32+0x32e>
    2901:	mov    edx,0x1
    2906:	mov    rdi,r14
    2909:	mov    rsi,r13
    290c:	call   2911 <botlish_fn_32+0x319>
			290d: R_X86_64_PLT32	rt_int_cmp-0x4
    2911:	mov    ecx,0x2
    2916:	test   rax,rax
    2919:	cmovge rcx,QWORD PTR [rip+0xbf]        # 29e0 <botlish_fn_32+0x3e8>
    2921:	jmp    293c <botlish_fn_32+0x344>
    2926:	mov    ecx,0x2
    292b:	mov    rax,r13
    292e:	mov    rdx,r13
    2931:	test   rax,rdx
    2934:	cmovg  rcx,QWORD PTR [rip+0xa4]        # 29e0 <botlish_fn_32+0x3e8>
    293c:	cmp    rcx,0x6
    2940:	je     2974 <botlish_fn_32+0x37c>
    2946:	mov    rax,QWORD PTR [rsp+0x8]
    294b:	shl    rax,1
    294e:	or     rax,0x1
    2952:	mov    rbx,QWORD PTR [rsp+0x10]
    2957:	mov    r12,QWORD PTR [rsp+0x18]
    295c:	mov    r13,QWORD PTR [rsp+0x20]
    2961:	mov    r14,QWORD PTR [rsp+0x28]
    2966:	mov    r15,QWORD PTR [rsp+0x30]
    296b:	add    rsp,0x40
    296f:	mov    rsp,rbp
    2972:	pop    rbp
    2973:	ret
    2974:	mov    rax,r13
    2977:	mov    rbx,QWORD PTR [rsp+0x10]
    297c:	mov    r12,QWORD PTR [rsp+0x18]
    2981:	mov    r13,QWORD PTR [rsp+0x20]
    2986:	mov    r14,QWORD PTR [rsp+0x28]
    298b:	mov    r15,QWORD PTR [rsp+0x30]
    2990:	add    rsp,0x40
    2994:	mov    rsp,rbp
    2997:	pop    rbp
    2998:	ret
    2999:	mov    rdx,r12
    299c:	shl    rdx,1
    299f:	or     rdx,0x1
    29a3:	mov    rdi,r14
    29a6:	call   29ab <botlish_fn_32+0x3b3>
			29a7: R_X86_64_PLT32	rt_mutarray_get-0x4
    29ab:	test   rax,rax
    29ae:	jne    2651 <botlish_fn_32+0x59>
    29b4:	jmp    2898 <botlish_fn_32+0x2a0>
    29b9:	mov    rdx,r12
    29bc:	shl    rdx,1
    29bf:	mov    QWORD PTR [rsp+0x8],r12
    29c4:	or     rdx,0x1
    29c8:	mov    rdi,r14
    29cb:	call   29d0 <botlish_fn_32+0x3d8>
			29cc: R_X86_64_PLT32	rt_mutarray_get-0x4
    29d0:	test   rax,rax
    29d3:	jne    2745 <botlish_fn_32+0x14d>
    29d9:	jmp    2898 <botlish_fn_32+0x2a0>
    29de:	add    BYTE PTR [rax],al
    29e0:	(bad)
    29e1:	add    BYTE PTR [rax],al
    29e3:	add    BYTE PTR [rax],al
    29e5:	add    BYTE PTR [rax],al
	...

00000000000029e8 <botlish_entry_32: ht_find_insert<HashTable, str, int, int>>:
    29e8:	push   rbp
    29e9:	mov    rbp,rsp
    29ec:	mov    rsi,QWORD PTR [rdx]
    29ef:	mov    r9,QWORD PTR [rdx+0x8]
    29f3:	mov    rcx,QWORD PTR [rdx+0x10]
    29f7:	mov    r8,QWORD PTR [rdx+0x18]
    29fb:	mov    rdx,r9
    29fe:	call   2a03 <botlish_entry_32+0x1b>
			29ff: R_X86_64_PLT32	botlish_fn_32-0x4 ; ht_find_insert<HashTable, str, int, int>
    2a03:	mov    rsp,rbp
    2a06:	pop    rbp
    2a07:	ret

0000000000002a08 <botlish_fn_33: ht_get<HashTable, str>>:
    2a08:	push   rbp
    2a09:	mov    rbp,rsp
    2a0c:	sub    rsp,0x20
    2a10:	mov    QWORD PTR [rsp],rbx
    2a14:	mov    QWORD PTR [rsp+0x8],r12
    2a19:	mov    QWORD PTR [rsp+0x10],r13
    2a1e:	mov    r12,rdi
    2a21:	mov    r13,rdx
    2a24:	mov    rbx,rsi
    2a27:	mov    rdx,r13
    2a2a:	mov    rdi,r12
    2a2d:	call   2a32 <botlish_fn_33+0x2a>
			2a2e: R_X86_64_PLT32	botlish_fn_29-0x4 ; ht_probe_start<HashTable, str>
    2a32:	test   rax,rax
    2a35:	mov    rcx,rax
    2a38:	je     2ade <botlish_fn_33+0xd6>
    2a3e:	mov    rdx,r13
    2a41:	mov    rsi,rbx
    2a44:	mov    rdi,r12
    2a47:	call   2a4c <botlish_fn_33+0x44>
			2a48: R_X86_64_PLT32	botlish_fn_31-0x4 ; ht_find_get<HashTable, str, int>
    2a4c:	mov    rcx,rax
    2a4f:	mov    r13,rax
    2a52:	test   rax,rcx
    2a55:	je     2ade <botlish_fn_33+0xd6>
    2a5b:	mov    rax,r13
    2a5e:	test   rax,0x1
    2a64:	jne    2a92 <botlish_fn_33+0x8a>
    2a6a:	mov    edx,0x1
    2a6f:	mov    rsi,r13
    2a72:	mov    rdi,r12
    2a75:	call   2a7a <botlish_fn_33+0x72>
			2a76: R_X86_64_PLT32	rt_int_cmp-0x4
    2a7a:	mov    ecx,0x2
    2a7f:	test   rax,rax
    2a82:	cmovl  rcx,QWORD PTR [rip+0xd6]        # 2b60 <botlish_fn_33+0x158>
    2a8a:	mov    rax,r13
    2a8d:	jmp    2aa5 <botlish_fn_33+0x9d>
    2a92:	mov    ecx,0x2
    2a97:	mov    rax,r13
    2a9a:	test   rax,rax
    2a9d:	cmovle rcx,QWORD PTR [rip+0xbb]        # 2b60 <botlish_fn_33+0x158>
    2aa5:	cmp    rcx,0x6
    2aa9:	je     2b1c <botlish_fn_33+0x114>
    2aaf:	mov    rcx,QWORD PTR [rbx+0x18]
    2ab3:	mov    rsi,QWORD PTR [rcx+0x10]
    2ab7:	test   rax,0x1
    2abd:	je     2b38 <botlish_fn_33+0x130>
    2ac3:	mov    rdx,QWORD PTR [rsi+0x8]
    2ac7:	mov    rcx,rax
    2aca:	sar    rcx,1
    2acd:	mov    r13,rax
    2ad0:	cmp    rcx,rdx
    2ad3:	jb     2afd <botlish_fn_33+0xf5>
    2ad9:	jmp    2b43 <botlish_fn_33+0x13b>
    2ade:	xor    rax,rax
    2ae1:	mov    rbx,QWORD PTR [rsp]
    2ae5:	mov    r12,QWORD PTR [rsp+0x8]
    2aea:	mov    r13,QWORD PTR [rsp+0x10]
    2aef:	add    rsp,0x20
    2af3:	mov    rsp,rbp
    2af6:	pop    rbp
    2af7:	ret
    2af8:	jmp    2b05 <botlish_fn_33+0xfd>
    2afd:	mov    rax,QWORD PTR [rsi+0x10]
    2b01:	mov    rax,QWORD PTR [rax+rcx*8]
    2b05:	mov    rbx,QWORD PTR [rsp]
    2b09:	mov    r12,QWORD PTR [rsp+0x8]
    2b0e:	mov    r13,QWORD PTR [rsp+0x10]
    2b13:	add    rsp,0x20
    2b17:	mov    rsp,rbp
    2b1a:	pop    rbp
    2b1b:	ret
    2b1c:	mov    eax,0xa
    2b21:	mov    rbx,QWORD PTR [rsp]
    2b25:	mov    r12,QWORD PTR [rsp+0x8]
    2b2a:	mov    r13,QWORD PTR [rsp+0x10]
    2b2f:	add    rsp,0x20
    2b33:	mov    rsp,rbp
    2b36:	pop    rbp
    2b37:	ret
    2b38:	mov    rdx,rax
    2b3b:	mov    rdi,r12
    2b3e:	jmp    2b49 <botlish_fn_33+0x141>
    2b43:	mov    rdx,r13
    2b46:	mov    rdi,r12
    2b49:	mov    rdi,r12
    2b4c:	call   2b51 <botlish_fn_33+0x149>
			2b4d: R_X86_64_PLT32	rt_mutarray_get-0x4
    2b51:	test   rax,rax
    2b54:	jne    2b05 <botlish_fn_33+0xfd>
    2b5a:	jmp    2ade <botlish_fn_33+0xd6>
    2b5f:	add    BYTE PTR [rsi],al
    2b61:	add    BYTE PTR [rax],al
    2b63:	add    BYTE PTR [rax],al
    2b65:	add    BYTE PTR [rax],al
	...

0000000000002b68 <botlish_entry_33: ht_get<HashTable, str>>:
    2b68:	push   rbp
    2b69:	mov    rbp,rsp
    2b6c:	mov    rsi,QWORD PTR [rdx]
    2b6f:	mov    rdx,QWORD PTR [rdx+0x8]
    2b73:	call   2b78 <botlish_entry_33+0x10>
			2b74: R_X86_64_PLT32	botlish_fn_33-0x4 ; ht_get<HashTable, str>
    2b78:	mov    rsp,rbp
    2b7b:	pop    rbp
    2b7c:	ret
    2b7d:	add    BYTE PTR [rax],al
	...

0000000000002b80 <botlish_fn_34: ht_rehash_probe<mutarray, int, int>>:
    2b80:	push   rbp
    2b81:	mov    rbp,rsp
    2b84:	sub    rsp,0x60
    2b88:	mov    QWORD PTR [rsp+0x30],rbx
    2b8d:	mov    QWORD PTR [rsp+0x38],r12
    2b92:	mov    QWORD PTR [rsp+0x40],r13
    2b97:	mov    QWORD PTR [rsp+0x48],r14
    2b9c:	mov    QWORD PTR [rsp+0x50],r15
    2ba1:	mov    r15,rdi
    2ba4:	mov    QWORD PTR [rsp],rsi
    2ba8:	mov    rax,rsi
    2bab:	mov    QWORD PTR [rsp+0x8],rdx
    2bb0:	mov    QWORD PTR [rsp+0x10],rcx
    2bb5:	mov    r14,rcx
    2bb8:	sar    r14,1
    2bbb:	mov    r13,rcx
    2bbe:	mov    rbx,r14
    2bc1:	neg    rbx
    2bc4:	cmovs  rbx,r14
    2bc8:	mov    rsi,rdx
    2bcb:	test   rsi,0x1
    2bd2:	je     2d67 <botlish_fn_34+0x1e7>
    2bd8:	mov    r12,rax
    2bdb:	mov    rcx,QWORD PTR [r12+0x8]
    2be0:	mov    rax,rsi
    2be3:	sar    rax,1
    2be6:	mov    QWORD PTR [rsp+0x20],rsi
    2beb:	cmp    rax,rcx
    2bee:	jb     2c01 <botlish_fn_34+0x81>
    2bf4:	jmp    2d6f <botlish_fn_34+0x1ef>
    2bf9:	mov    rsi,rax
    2bfc:	jmp    2c0a <botlish_fn_34+0x8a>
    2c01:	mov    rcx,QWORD PTR [r12+0x10]
    2c06:	mov    rsi,QWORD PTR [rcx+rax*8]
    2c0a:	test   rsi,0x1
    2c11:	jne    2c32 <botlish_fn_34+0xb2>
    2c17:	mov    edx,0x1
    2c1c:	mov    rdi,r15
    2c1f:	call   2c24 <botlish_fn_34+0xa4>
			2c20: R_X86_64_PLT32	rt_value_eq-0x4
    2c24:	test   rax,rax
    2c27:	je     2d02 <botlish_fn_34+0x182>
    2c2d:	jmp    2c43 <botlish_fn_34+0xc3>
    2c32:	mov    eax,0x2
    2c37:	cmp    rsi,0x1
    2c3b:	cmove  rax,QWORD PTR [rip+0x14d]        # 2d90 <botlish_fn_34+0x210>
    2c43:	cmp    rax,0x6
    2c47:	je     2d40 <botlish_fn_34+0x1c0>
    2c4d:	mov    QWORD PTR [rsp+0x18],0x3
    2c56:	mov    rsi,QWORD PTR [rsp+0x20]
    2c5b:	test   rsi,0x1
    2c62:	je     2c7e <botlish_fn_34+0xfe>
    2c68:	mov    rsi,QWORD PTR [rsp+0x20]
    2c6d:	add    rsi,0x2
    2c71:	seto   dil
    2c75:	test   dil,dil
    2c78:	je     2c93 <botlish_fn_34+0x113>
    2c7e:	mov    edx,0x3
    2c83:	mov    rsi,QWORD PTR [rsp+0x20]
    2c88:	mov    rdi,r15
    2c8b:	call   2c90 <botlish_fn_34+0x110>
			2c8c: R_X86_64_PLT32	rt_int_add-0x4
    2c90:	mov    rsi,rax
    2c93:	mov    QWORD PTR [rsp+0x8],rsi
    2c98:	mov    r10,rsi
    2c9b:	and    r10,r13
    2c9e:	test   r10,0x1
    2ca5:	je     2cee <botlish_fn_34+0x16e>
    2cab:	cmp    r13,0x1
    2caf:	je     2cee <botlish_fn_34+0x16e>
    2cb5:	mov    rax,rsi
    2cb8:	sar    rax,1
    2cbb:	cqo
    2cbd:	cmp    r14,0xffffffffffffffff
    2cc1:	jne    2cd1 <botlish_fn_34+0x151>
    2cc7:	mov    edx,0x0
    2ccc:	jmp    2cd4 <botlish_fn_34+0x154>
    2cd1:	idiv   r14
    2cd4:	lea    rax,[rdx+rbx*1]
    2cd8:	test   rdx,rdx
    2cdb:	cmovl  rdx,rax
    2cdf:	shl    rdx,1
    2ce2:	or     rdx,0x1
    2ce6:	mov    rax,rdx
    2ce9:	jmp    2d27 <botlish_fn_34+0x1a7>
    2cee:	mov    rdx,r13
    2cf1:	mov    rdi,r15
    2cf4:	call   2cf9 <botlish_fn_34+0x179>
			2cf5: R_X86_64_PLT32	rt_int_mod-0x4
    2cf9:	test   rax,rax
    2cfc:	jne    2d27 <botlish_fn_34+0x1a7>
    2d02:	xor    rax,rax
    2d05:	mov    rbx,QWORD PTR [rsp+0x30]
    2d0a:	mov    r12,QWORD PTR [rsp+0x38]
    2d0f:	mov    r13,QWORD PTR [rsp+0x40]
    2d14:	mov    r14,QWORD PTR [rsp+0x48]
    2d19:	mov    r15,QWORD PTR [rsp+0x50]
    2d1e:	add    rsp,0x60
    2d22:	mov    rsp,rbp
    2d25:	pop    rbp
    2d26:	ret
    2d27:	mov    QWORD PTR [rsp],r12
    2d2b:	mov    QWORD PTR [rsp+0x8],rax
    2d30:	mov    QWORD PTR [rsp+0x10],r13
    2d35:	mov    rsi,rax
    2d38:	mov    rax,r12
    2d3b:	jmp    2bcb <botlish_fn_34+0x4b>
    2d40:	mov    rax,QWORD PTR [rsp+0x20]
    2d45:	mov    rbx,QWORD PTR [rsp+0x30]
    2d4a:	mov    r12,QWORD PTR [rsp+0x38]
    2d4f:	mov    r13,QWORD PTR [rsp+0x40]
    2d54:	mov    r14,QWORD PTR [rsp+0x48]
    2d59:	mov    r15,QWORD PTR [rsp+0x50]
    2d5e:	add    rsp,0x60
    2d62:	mov    rsp,rbp
    2d65:	pop    rbp
    2d66:	ret
    2d67:	mov    r12,rax
    2d6a:	mov    QWORD PTR [rsp+0x20],rsi
    2d6f:	mov    rdx,QWORD PTR [rsp+0x20]
    2d74:	mov    rsi,r12
    2d77:	mov    rdi,r15
    2d7a:	call   2d7f <botlish_fn_34+0x1ff>
			2d7b: R_X86_64_PLT32	rt_mutarray_get-0x4
    2d7f:	test   rax,rax
    2d82:	jne    2bf9 <botlish_fn_34+0x79>
    2d88:	jmp    2d02 <botlish_fn_34+0x182>
    2d8d:	add    BYTE PTR [rax],al
    2d8f:	add    BYTE PTR [rsi],al
    2d91:	add    BYTE PTR [rax],al
    2d93:	add    BYTE PTR [rax],al
    2d95:	add    BYTE PTR [rax],al
	...

0000000000002d98 <botlish_entry_34: ht_rehash_probe<mutarray, int, int>>:
    2d98:	push   rbp
    2d99:	mov    rbp,rsp
    2d9c:	mov    rsi,QWORD PTR [rdx]
    2d9f:	mov    r8,QWORD PTR [rdx+0x8]
    2da3:	mov    rcx,QWORD PTR [rdx+0x10]
    2da7:	mov    rdx,r8
    2daa:	call   2daf <botlish_entry_34+0x17>
			2dab: R_X86_64_PLT32	botlish_fn_34-0x4 ; ht_rehash_probe<mutarray, int, int>
    2daf:	mov    rsp,rbp
    2db2:	pop    rbp
    2db3:	ret

0000000000002db4 <botlish_fn_35: ht_rehash_insert<HashTable, int, any, any>>:
    2db4:	push   rbp
    2db5:	mov    rbp,rsp
    2db8:	sub    rsp,0x70
    2dbc:	mov    QWORD PTR [rsp+0x40],rbx
    2dc1:	mov    QWORD PTR [rsp+0x48],r12
    2dc6:	mov    QWORD PTR [rsp+0x50],r13
    2dcb:	mov    QWORD PTR [rsp+0x58],r14
    2dd0:	mov    QWORD PTR [rsp+0x60],r15
    2dd5:	mov    r15,rdi
    2dd8:	mov    QWORD PTR [rsp],rsi
    2ddc:	mov    QWORD PTR [rsp+0x8],rdx
    2de1:	mov    r12,rdx
    2de4:	mov    QWORD PTR [rsp+0x10],rcx
    2de9:	mov    QWORD PTR [rsp+0x30],rcx
    2dee:	mov    QWORD PTR [rsp+0x18],r8
    2df3:	mov    r14,r8
    2df6:	mov    rax,QWORD PTR [rsi+0x18]
    2dfa:	mov    rbx,rsi
    2dfd:	mov    rsi,QWORD PTR [rax]
    2e00:	mov    QWORD PTR [rsp+0x20],rsi
    2e05:	mov    QWORD PTR [rsp+0x38],rsi
    2e0a:	mov    rsi,QWORD PTR [rsp+0x30]
    2e0f:	mov    rdi,r15
    2e12:	call   2e17 <botlish_fn_35+0x63>
			2e13: R_X86_64_PLT32	rt_hash-0x4
    2e17:	test   rax,rax
    2e1a:	je     2f99 <botlish_fn_35+0x1e5>
    2e20:	mov    QWORD PTR [rsp+0x28],rax
    2e25:	mov    r13,r12
    2e28:	mov    rcx,rax
    2e2b:	and    rcx,r13
    2e2e:	test   rcx,0x1
    2e35:	jne    2e43 <botlish_fn_35+0x8f>
    2e3b:	mov    rsi,rax
    2e3e:	jmp    2e9a <botlish_fn_35+0xe6>
    2e43:	cmp    r13,0x1
    2e47:	jne    2e55 <botlish_fn_35+0xa1>
    2e4d:	mov    rsi,rax
    2e50:	jmp    2e9a <botlish_fn_35+0xe6>
    2e55:	sar    rax,1
    2e58:	mov    rcx,r13
    2e5b:	sar    rcx,1
    2e5e:	cqo
    2e60:	cmp    rcx,0xffffffffffffffff
    2e64:	jne    2e74 <botlish_fn_35+0xc0>
    2e6a:	mov    edx,0x0
    2e6f:	jmp    2e77 <botlish_fn_35+0xc3>
    2e74:	idiv   rcx
    2e77:	mov    rax,rcx
    2e7a:	neg    rax
    2e7d:	cmovs  rax,rcx
    2e81:	add    rax,rdx
    2e84:	test   rdx,rdx
    2e87:	cmovl  rdx,rax
    2e8b:	shl    rdx,1
    2e8e:	or     rdx,0x1
    2e92:	mov    r12,r13
    2e95:	jmp    2eb4 <botlish_fn_35+0x100>
    2e9a:	mov    rdx,r13
    2e9d:	mov    rdi,r15
    2ea0:	call   2ea5 <botlish_fn_35+0xf1>
			2ea1: R_X86_64_PLT32	rt_int_mod-0x4
    2ea5:	mov    r12,r13
    2ea8:	test   rax,rax
    2eab:	je     2f99 <botlish_fn_35+0x1e5>
    2eb1:	mov    rdx,rax
    2eb4:	mov    QWORD PTR [rsp+0x28],rdx
    2eb9:	mov    rcx,r12
    2ebc:	mov    rsi,QWORD PTR [rsp+0x38]
    2ec1:	mov    rdi,r15
    2ec4:	call   2ec9 <botlish_fn_35+0x115>
			2ec5: R_X86_64_PLT32	botlish_fn_34-0x4 ; ht_rehash_probe<mutarray, int, int>
    2ec9:	mov    rcx,rax
    2ecc:	mov    r12,rax
    2ecf:	test   rax,rcx
    2ed2:	je     2f99 <botlish_fn_35+0x1e5>
    2ed8:	mov    r9,QWORD PTR [rbx+0x18]
    2edc:	mov    rsi,QWORD PTR [r9]
    2edf:	mov    rax,r12
    2ee2:	test   rax,0x1
    2ee8:	je     2ff6 <botlish_fn_35+0x242>
    2eee:	mov    rdx,QWORD PTR [rsi+0x8]
    2ef2:	mov    rax,r12
    2ef5:	mov    rcx,rax
    2ef8:	sar    rcx,1
    2efb:	cmp    rcx,rdx
    2efe:	jae    2ff6 <botlish_fn_35+0x242>
    2f04:	mov    rdx,QWORD PTR [rsi+0x18]
    2f08:	test   rdx,rdx
    2f0b:	je     2ff6 <botlish_fn_35+0x242>
    2f11:	mov    rax,QWORD PTR [rsi+0x10]
    2f15:	mov    QWORD PTR [rax+rcx*8],0x3
    2f1d:	mov    rax,QWORD PTR [rbx+0x18]
    2f21:	mov    rsi,QWORD PTR [rax+0x8]
    2f25:	test   r12,0x1
    2f2c:	je     3014 <botlish_fn_35+0x260>
    2f32:	mov    rdx,QWORD PTR [rsi+0x8]
    2f36:	mov    rdi,r12
    2f39:	sar    rdi,1
    2f3c:	cmp    rdi,rdx
    2f3f:	jae    301e <botlish_fn_35+0x26a>
    2f45:	mov    rcx,QWORD PTR [rsi+0x18]
    2f49:	test   rcx,rcx
    2f4c:	je     3028 <botlish_fn_35+0x274>
    2f52:	mov    rcx,QWORD PTR [rsp+0x30]
    2f57:	mov    rax,QWORD PTR [rsi+0x10]
    2f5b:	mov    QWORD PTR [rax+rdi*8],rcx
    2f5f:	mov    rax,QWORD PTR [rbx+0x18]
    2f63:	mov    rsi,QWORD PTR [rax+0x10]
    2f67:	test   r12,0x1
    2f6e:	je     3046 <botlish_fn_35+0x292>
    2f74:	mov    rdx,QWORD PTR [rsi+0x8]
    2f78:	mov    rdi,r12
    2f7b:	sar    rdi,1
    2f7e:	cmp    rdi,rdx
    2f81:	jae    3054 <botlish_fn_35+0x2a0>
    2f87:	mov    rax,QWORD PTR [rsi+0x18]
    2f8b:	test   rax,rax
    2f8e:	jne    2fc6 <botlish_fn_35+0x212>
    2f94:	jmp    3062 <botlish_fn_35+0x2ae>
    2f99:	xor    rax,rax
    2f9c:	mov    rbx,QWORD PTR [rsp+0x40]
    2fa1:	mov    r12,QWORD PTR [rsp+0x48]
    2fa6:	mov    r13,QWORD PTR [rsp+0x50]
    2fab:	mov    r14,QWORD PTR [rsp+0x58]
    2fb0:	mov    r15,QWORD PTR [rsp+0x60]
    2fb5:	add    rsp,0x70
    2fb9:	mov    rsp,rbp
    2fbc:	pop    rbp
    2fbd:	ret
    2fbe:	mov    rax,rbx
    2fc1:	jmp    2fd4 <botlish_fn_35+0x220>
    2fc6:	mov    rcx,r14
    2fc9:	mov    rax,QWORD PTR [rsi+0x10]
    2fcd:	mov    QWORD PTR [rax+rdi*8],rcx
    2fd1:	mov    rax,rbx
    2fd4:	mov    rbx,QWORD PTR [rsp+0x40]
    2fd9:	mov    r12,QWORD PTR [rsp+0x48]
    2fde:	mov    r13,QWORD PTR [rsp+0x50]
    2fe3:	mov    r14,QWORD PTR [rsp+0x58]
    2fe8:	mov    r15,QWORD PTR [rsp+0x60]
    2fed:	add    rsp,0x70
    2ff1:	mov    rsp,rbp
    2ff4:	pop    rbp
    2ff5:	ret
    2ff6:	mov    ecx,0x3
    2ffb:	mov    rdx,r12
    2ffe:	mov    rdi,r15
    3001:	call   3006 <botlish_fn_35+0x252>
			3002: R_X86_64_PLT32	rt_mutarray_set-0x4
    3006:	test   rax,rax
    3009:	jne    2f1d <botlish_fn_35+0x169>
    300f:	jmp    2f99 <botlish_fn_35+0x1e5>
    3014:	mov    rcx,QWORD PTR [rsp+0x30]
    3019:	jmp    302d <botlish_fn_35+0x279>
    301e:	mov    rcx,QWORD PTR [rsp+0x30]
    3023:	jmp    302d <botlish_fn_35+0x279>
    3028:	mov    rcx,QWORD PTR [rsp+0x30]
    302d:	mov    rdx,r12
    3030:	mov    rdi,r15
    3033:	call   3038 <botlish_fn_35+0x284>
			3034: R_X86_64_PLT32	rt_mutarray_set-0x4
    3038:	test   rax,rax
    303b:	jne    2f5f <botlish_fn_35+0x1ab>
    3041:	jmp    2f99 <botlish_fn_35+0x1e5>
    3046:	mov    rcx,r14
    3049:	mov    rdx,r12
    304c:	mov    rdi,r15
    304f:	jmp    306b <botlish_fn_35+0x2b7>
    3054:	mov    rcx,r14
    3057:	mov    rdx,r12
    305a:	mov    rdi,r15
    305d:	jmp    306b <botlish_fn_35+0x2b7>
    3062:	mov    rcx,r14
    3065:	mov    rdx,r12
    3068:	mov    rdi,r15
    306b:	mov    rdi,r15
    306e:	call   3073 <botlish_fn_35+0x2bf>
			306f: R_X86_64_PLT32	rt_mutarray_set-0x4
    3073:	test   rax,rax
    3076:	jne    2fbe <botlish_fn_35+0x20a>
    307c:	jmp    2f99 <botlish_fn_35+0x1e5>

0000000000003081 <botlish_entry_35: ht_rehash_insert<HashTable, int, any, any>>:
    3081:	push   rbp
    3082:	mov    rbp,rsp
    3085:	mov    rsi,QWORD PTR [rdx]
    3088:	mov    r9,QWORD PTR [rdx+0x8]
    308c:	mov    rcx,QWORD PTR [rdx+0x10]
    3090:	mov    r8,QWORD PTR [rdx+0x18]
    3094:	mov    rdx,r9
    3097:	call   309c <botlish_entry_35+0x1b>
			3098: R_X86_64_PLT32	botlish_fn_35-0x4 ; ht_rehash_insert<HashTable, int, any, any>
    309c:	mov    rsp,rbp
    309f:	pop    rbp
    30a0:	ret
    30a1:	add    BYTE PTR [rax],al
    30a3:	add    BYTE PTR [rax],al
    30a5:	add    BYTE PTR [rax],al
	...

00000000000030a8 <botlish_fn_36: ht_rehash_scan<mutarray, mutarray, mutarray, int, int, HashTable, int>>:
    30a8:	push   rbp
    30a9:	mov    rbp,rsp
    30ac:	sub    rsp,0x90
    30b3:	mov    QWORD PTR [rsp+0x60],rbx
    30b8:	mov    QWORD PTR [rsp+0x68],r12
    30bd:	mov    QWORD PTR [rsp+0x70],r13
    30c2:	mov    QWORD PTR [rsp+0x78],r14
    30c7:	mov    QWORD PTR [rsp+0x80],r15
    30cf:	mov    QWORD PTR [rsp+0x38],rdi
    30d4:	mov    QWORD PTR [rsp+0x40],r9
    30d9:	mov    rax,QWORD PTR [rbp+0x10]
    30dd:	mov    r12,QWORD PTR [rbp+0x18]
    30e1:	mov    QWORD PTR [rsp],rsi
    30e5:	mov    QWORD PTR [rsp+0x8],rdx
    30ea:	mov    r15,rdx
    30ed:	mov    QWORD PTR [rsp+0x10],rcx
    30f2:	mov    rbx,rcx
    30f5:	mov    QWORD PTR [rsp+0x18],rax
    30fa:	mov    QWORD PTR [rsp+0x48],rax
    30ff:	mov    QWORD PTR [rsp+0x20],r12
    3104:	sar    r8,1
    3107:	mov    rdx,QWORD PTR [rsp+0x40]
    310c:	mov    r13,r8
    310f:	cmp    r13,rdx
    3112:	mov    QWORD PTR [rsp+0x40],rdx
    3117:	jge    32b3 <botlish_fn_36+0x20b>
    311d:	mov    r14,rsi
    3120:	mov    rdx,QWORD PTR [r14+0x8]
    3124:	mov    rax,r13
    3127:	shl    rax,1
    312a:	or     rax,0x1
    312e:	sar    rax,1
    3131:	cmp    rax,rdx
    3134:	jb     3147 <botlish_fn_36+0x9f>
    313a:	jmp    32e0 <botlish_fn_36+0x238>
    313f:	mov    rsi,rax
    3142:	jmp    314f <botlish_fn_36+0xa7>
    3147:	mov    r8,QWORD PTR [r14+0x10]
    314b:	mov    rsi,QWORD PTR [r8+rax*8]
    314f:	test   rsi,0x1
    3156:	jne    3179 <botlish_fn_36+0xd1>
    315c:	mov    edx,0x3
    3161:	mov    rdi,QWORD PTR [rsp+0x38]
    3166:	call   316b <botlish_fn_36+0xc3>
			3167: R_X86_64_PLT32	rt_value_eq-0x4
    316b:	test   rax,rax
    316e:	je     3257 <botlish_fn_36+0x1af>
    3174:	jmp    318a <botlish_fn_36+0xe2>
    3179:	mov    eax,0x2
    317e:	cmp    rsi,0x3
    3182:	cmove  rax,QWORD PTR [rip+0x1c6]        # 3350 <botlish_fn_36+0x2a8>
    318a:	cmp    rax,0x6
    318e:	je     31c5 <botlish_fn_36+0x11d>
    3194:	mov    QWORD PTR [rsp],r14
    3198:	mov    QWORD PTR [rsp+0x8],r15
    319d:	mov    QWORD PTR [rsp+0x10],rbx
    31a2:	mov    rax,QWORD PTR [rsp+0x48]
    31a7:	mov    QWORD PTR [rsp+0x18],rax
    31ac:	mov    QWORD PTR [rsp+0x20],r12
    31b1:	add    r13,0x1
    31b8:	mov    rdx,QWORD PTR [rsp+0x40]
    31bd:	mov    rsi,r14
    31c0:	jmp    310f <botlish_fn_36+0x67>
    31c5:	mov    rdx,QWORD PTR [r15+0x8]
    31c9:	mov    rcx,r13
    31cc:	shl    rcx,1
    31cf:	or     rcx,0x1
    31d3:	sar    rcx,1
    31d6:	cmp    rcx,rdx
    31d9:	jb     31ec <botlish_fn_36+0x144>
    31df:	jmp    3305 <botlish_fn_36+0x25d>
    31e4:	mov    rcx,rax
    31e7:	jmp    31f4 <botlish_fn_36+0x14c>
    31ec:	mov    rax,QWORD PTR [r15+0x10]
    31f0:	mov    rcx,QWORD PTR [rax+rcx*8]
    31f4:	mov    QWORD PTR [rsp+0x28],rcx
    31f9:	mov    QWORD PTR [rsp+0x50],rcx
    31fe:	mov    rax,QWORD PTR [rbx+0x8]
    3202:	mov    rcx,r13
    3205:	shl    rcx,1
    3208:	or     rcx,0x1
    320c:	sar    rcx,1
    320f:	cmp    rcx,rax
    3212:	jb     322a <botlish_fn_36+0x182>
    3218:	jmp    332a <botlish_fn_36+0x282>
    321d:	mov    rsi,QWORD PTR [rsp+0x48]
    3222:	mov    r8,rax
    3225:	jmp    3237 <botlish_fn_36+0x18f>
    322a:	mov    rax,QWORD PTR [rbx+0x10]
    322e:	mov    r8,QWORD PTR [rax+rcx*8]
    3232:	mov    rsi,QWORD PTR [rsp+0x48]
    3237:	mov    QWORD PTR [rsp+0x30],r8
    323c:	mov    rcx,QWORD PTR [rsp+0x50]
    3241:	mov    rdx,r12
    3244:	mov    rdi,QWORD PTR [rsp+0x38]
    3249:	call   324e <botlish_fn_36+0x1a6>
			324a: R_X86_64_PLT32	botlish_fn_35-0x4 ; ht_rehash_insert<HashTable, int, any, any>
    324e:	test   rax,rax
    3251:	jne    3282 <botlish_fn_36+0x1da>
    3257:	xor    rax,rax
    325a:	mov    rbx,QWORD PTR [rsp+0x60]
    325f:	mov    r12,QWORD PTR [rsp+0x68]
    3264:	mov    r13,QWORD PTR [rsp+0x70]
    3269:	mov    r14,QWORD PTR [rsp+0x78]
    326e:	mov    r15,QWORD PTR [rsp+0x80]
    3276:	add    rsp,0x90
    327d:	mov    rsp,rbp
    3280:	pop    rbp
    3281:	ret
    3282:	mov    QWORD PTR [rsp],r14
    3286:	mov    QWORD PTR [rsp+0x8],r15
    328b:	mov    QWORD PTR [rsp+0x10],rbx
    3290:	mov    QWORD PTR [rsp+0x18],rax
    3295:	mov    QWORD PTR [rsp+0x20],r12
    329a:	add    r13,0x1
    32a1:	mov    rdx,QWORD PTR [rsp+0x40]
    32a6:	mov    rsi,r14
    32a9:	mov    QWORD PTR [rsp+0x48],rax
    32ae:	jmp    310f <botlish_fn_36+0x67>
    32b3:	mov    rax,QWORD PTR [rsp+0x48]
    32b8:	mov    rbx,QWORD PTR [rsp+0x60]
    32bd:	mov    r12,QWORD PTR [rsp+0x68]
    32c2:	mov    r13,QWORD PTR [rsp+0x70]
    32c7:	mov    r14,QWORD PTR [rsp+0x78]
    32cc:	mov    r15,QWORD PTR [rsp+0x80]
    32d4:	add    rsp,0x90
    32db:	mov    rsp,rbp
    32de:	pop    rbp
    32df:	ret
    32e0:	mov    rdx,r13
    32e3:	shl    rdx,1
    32e6:	or     rdx,0x1
    32ea:	mov    rsi,r14
    32ed:	mov    rdi,QWORD PTR [rsp+0x38]
    32f2:	call   32f7 <botlish_fn_36+0x24f>
			32f3: R_X86_64_PLT32	rt_mutarray_get-0x4
    32f7:	test   rax,rax
    32fa:	jne    313f <botlish_fn_36+0x97>
    3300:	jmp    3257 <botlish_fn_36+0x1af>
    3305:	mov    rdx,r13
    3308:	shl    rdx,1
    330b:	or     rdx,0x1
    330f:	mov    rsi,r15
    3312:	mov    rdi,QWORD PTR [rsp+0x38]
    3317:	call   331c <botlish_fn_36+0x274>
			3318: R_X86_64_PLT32	rt_mutarray_get-0x4
    331c:	test   rax,rax
    331f:	jne    31e4 <botlish_fn_36+0x13c>
    3325:	jmp    3257 <botlish_fn_36+0x1af>
    332a:	mov    rdx,r13
    332d:	shl    rdx,1
    3330:	or     rdx,0x1
    3334:	mov    rsi,rbx
    3337:	mov    rdi,QWORD PTR [rsp+0x38]
    333c:	call   3341 <botlish_fn_36+0x299>
			333d: R_X86_64_PLT32	rt_mutarray_get-0x4
    3341:	test   rax,rax
    3344:	jne    321d <botlish_fn_36+0x175>
    334a:	jmp    3257 <botlish_fn_36+0x1af>
    334f:	add    BYTE PTR [rsi],al
    3351:	add    BYTE PTR [rax],al
    3353:	add    BYTE PTR [rax],al
    3355:	add    BYTE PTR [rax],al
	...

0000000000003358 <botlish_entry_36: ht_rehash_scan<mutarray, mutarray, mutarray, int, int, HashTable, int>>:
    3358:	push   rbp
    3359:	mov    rbp,rsp
    335c:	sub    rsp,0x10
    3360:	mov    rsi,QWORD PTR [rdx]
    3363:	mov    r11,QWORD PTR [rdx+0x8]
    3367:	mov    rcx,QWORD PTR [rdx+0x10]
    336b:	mov    r8,QWORD PTR [rdx+0x18]
    336f:	mov    r9,QWORD PTR [rdx+0x20]
    3373:	mov    rax,QWORD PTR [rdx+0x28]
    3377:	mov    rdx,QWORD PTR [rdx+0x30]
    337b:	sar    r9,1
    337e:	mov    QWORD PTR [rsp],rax
    3382:	mov    QWORD PTR [rsp+0x8],rdx
    3387:	mov    rdx,r11
    338a:	call   338f <botlish_entry_36+0x37>
			338b: R_X86_64_PLT32	botlish_fn_36-0x4 ; ht_rehash_scan<mutarray, mutarray, mutarray, int, int, HashTable, int>
    338f:	add    rsp,0x10
    3393:	mov    rsp,rbp
    3396:	pop    rbp
    3397:	ret

0000000000003398 <botlish_fn_37: ht_rehash<HashTable, int>>:
    3398:	push   rbp
    3399:	mov    rbp,rsp
    339c:	sub    rsp,0x100
    33a3:	mov    QWORD PTR [rsp+0xd0],rbx
    33ab:	mov    QWORD PTR [rsp+0xd8],r12
    33b3:	mov    QWORD PTR [rsp+0xe0],r13
    33bb:	mov    QWORD PTR [rsp+0xe8],r14
    33c3:	mov    QWORD PTR [rsp+0xf0],r15
    33cb:	mov    QWORD PTR [rsp+0x98],rdi
    33d3:	mov    QWORD PTR [rsp+0x20],0x0
    33dc:	mov    QWORD PTR [rsp+0x28],0x0
    33e5:	mov    QWORD PTR [rsp+0x30],0x0
    33ee:	mov    QWORD PTR [rsp+0x38],0x0
    33f7:	mov    QWORD PTR [rsp+0x40],0x0
    3400:	mov    QWORD PTR [rsp+0x48],0x0
    3409:	mov    QWORD PTR [rsp+0x50],0x0
    3412:	mov    QWORD PTR [rsp+0x58],0x0
    341b:	mov    QWORD PTR [rsp+0x10],rsi
    3420:	mov    rbx,rsi
    3423:	mov    QWORD PTR [rsp+0x18],rdx
    3428:	mov    QWORD PTR [rsp+0xa0],rdx
    3430:	lea    rdx,[rsp+0x60]
    3435:	mov    rsi,QWORD PTR [rsp+0xa0]
    343d:	mov    rdi,QWORD PTR [rsp+0x98]
    3445:	call   344a <botlish_fn_37+0xb2>
			3446: R_X86_64_PLT32	botlish_fn_22-0x4 ; ht_alloc<int>
    344a:	test   rax,rax
    344d:	je     35ba <botlish_fn_37+0x222>
    3453:	mov    QWORD PTR [rsp+0x20],rax
    3458:	mov    QWORD PTR [rsp+0xc0],rax
    3460:	mov    rcx,QWORD PTR [rsp+0x60]
    3465:	mov    QWORD PTR [rsp+0x28],rcx
    346a:	mov    QWORD PTR [rsp+0xb8],rcx
    3472:	mov    rcx,QWORD PTR [rsp+0x68]
    3477:	mov    QWORD PTR [rsp+0x30],rcx
    347c:	mov    QWORD PTR [rsp+0xb0],rcx
    3484:	mov    r13,QWORD PTR [rsp+0x70]
    3489:	mov    QWORD PTR [rsp+0x38],r13
    348e:	mov    rsi,rbx
    3491:	mov    rdi,QWORD PTR [rsp+0x98]
    3499:	call   349e <botlish_fn_37+0x106>
			349a: R_X86_64_PLT32	botlish_fn_26-0x4 ; ht_size<HashTable>
    349e:	test   rax,rax
    34a1:	mov    rcx,rax
    34a4:	je     35ba <botlish_fn_37+0x222>
    34aa:	mov    rax,QWORD PTR [r13+0x8]
    34ae:	test   rax,rax
    34b1:	je     3625 <botlish_fn_37+0x28d>
    34b7:	mov    rax,QWORD PTR [r13+0x18]
    34bb:	test   rax,rax
    34be:	jne    34d1 <botlish_fn_37+0x139>
    34c4:	jmp    3625 <botlish_fn_37+0x28d>
    34c9:	mov    rsi,rbx
    34cc:	jmp    34db <botlish_fn_37+0x143>
    34d1:	mov    rax,QWORD PTR [r13+0x10]
    34d5:	mov    QWORD PTR [rax],rcx
    34d8:	mov    rsi,rbx
    34db:	mov    rdx,QWORD PTR [rsi+0x18]
    34df:	mov    r14,QWORD PTR [rdx]
    34e2:	mov    QWORD PTR [rsp+0x40],r14
    34e7:	mov    rdi,QWORD PTR [rsi+0x18]
    34eb:	mov    r15,QWORD PTR [rdi+0x8]
    34ef:	mov    QWORD PTR [rsp+0x48],r15
    34f4:	mov    rdi,QWORD PTR [rsi+0x18]
    34f8:	mov    rbx,QWORD PTR [rdi+0x10]
    34fc:	mov    QWORD PTR [rsp+0x50],rbx
    3501:	mov    r12d,0x1
    3507:	mov    QWORD PTR [rsp+0x58],0x1
    3510:	mov    rdi,QWORD PTR [rsp+0x98]
    3518:	call   351d <botlish_fn_37+0x185>
			3519: R_X86_64_PLT32	botlish_fn_28-0x4 ; ht_capacity<HashTable>
    351d:	mov    QWORD PTR [rsp+0xa8],rax
    3525:	lea    rcx,[rsp+0x78]
    352a:	mov    rax,QWORD PTR [rsp+0xc0]
    3532:	mov    QWORD PTR [rsp+0x78],rax
    3537:	mov    rax,QWORD PTR [rsp+0xb8]
    353f:	mov    QWORD PTR [rsp+0x80],rax
    3547:	mov    rax,QWORD PTR [rsp+0xb0]
    354f:	mov    QWORD PTR [rsp+0x88],rax
    3557:	mov    QWORD PTR [rsp+0x90],r13
    355f:	xor    rsi,rsi
    3562:	mov    edx,0x4
    3567:	mov    rdi,QWORD PTR [rsp+0x98]
    356f:	call   3574 <botlish_fn_37+0x1dc>
			3570: R_X86_64_PLT32	rt_struct_new-0x4
    3574:	mov    QWORD PTR [rsp+0x10],rax
    3579:	mov    rcx,QWORD PTR [rsp+0xa8]
    3581:	mov    r9,rcx
    3584:	sar    r9,1
    3587:	mov    QWORD PTR [rsp],rax
    358b:	mov    rdx,QWORD PTR [rsp+0xa0]
    3593:	mov    QWORD PTR [rsp+0x8],rdx
    3598:	mov    rcx,rbx
    359b:	mov    rdx,r15
    359e:	mov    rsi,r14
    35a1:	mov    rdi,QWORD PTR [rsp+0x98]
    35a9:	mov    r8,r12
    35ac:	call   35b1 <botlish_fn_37+0x219>
			35ad: R_X86_64_PLT32	botlish_fn_36-0x4 ; ht_rehash_scan<mutarray, mutarray, mutarray, int, int, HashTable, int>
    35b1:	test   rax,rax
    35b4:	jne    35f1 <botlish_fn_37+0x259>
    35ba:	xor    rax,rax
    35bd:	mov    rbx,QWORD PTR [rsp+0xd0]
    35c5:	mov    r12,QWORD PTR [rsp+0xd8]
    35cd:	mov    r13,QWORD PTR [rsp+0xe0]
    35d5:	mov    r14,QWORD PTR [rsp+0xe8]
    35dd:	mov    r15,QWORD PTR [rsp+0xf0]
    35e5:	add    rsp,0x100
    35ec:	mov    rsp,rbp
    35ef:	pop    rbp
    35f0:	ret
    35f1:	mov    rbx,QWORD PTR [rsp+0xd0]
    35f9:	mov    r12,QWORD PTR [rsp+0xd8]
    3601:	mov    r13,QWORD PTR [rsp+0xe0]
    3609:	mov    r14,QWORD PTR [rsp+0xe8]
    3611:	mov    r15,QWORD PTR [rsp+0xf0]
    3619:	add    rsp,0x100
    3620:	mov    rsp,rbp
    3623:	pop    rbp
    3624:	ret
    3625:	mov    edx,0x1
    362a:	mov    rsi,r13
    362d:	mov    rdi,QWORD PTR [rsp+0x98]
    3635:	call   363a <botlish_fn_37+0x2a2>
			3636: R_X86_64_PLT32	rt_mutarray_set-0x4
    363a:	test   rax,rax
    363d:	jne    34c9 <botlish_fn_37+0x131>
    3643:	jmp    35ba <botlish_fn_37+0x222>

0000000000003648 <botlish_entry_37: ht_rehash<HashTable, int>>:
    3648:	push   rbp
    3649:	mov    rbp,rsp
    364c:	mov    rsi,QWORD PTR [rdx]
    364f:	mov    rdx,QWORD PTR [rdx+0x8]
    3653:	call   3658 <botlish_entry_37+0x10>
			3654: R_X86_64_PLT32	botlish_fn_37-0x4 ; ht_rehash<HashTable, int>
    3658:	mov    rsp,rbp
    365b:	pop    rbp
    365c:	ret
    365d:	add    BYTE PTR [rax],al
	...

0000000000003660 <botlish_fn_38: ht_should_grow<HashTable>>:
    3660:	push   rbp
    3661:	mov    rbp,rsp
    3664:	sub    rsp,0x40
    3668:	mov    QWORD PTR [rsp+0x20],rbx
    366d:	mov    QWORD PTR [rsp+0x28],r12
    3672:	mov    QWORD PTR [rsp+0x30],r13
    3677:	mov    rbx,rdi
    367a:	mov    QWORD PTR [rsp],rsi
    367e:	mov    r12,rsi
    3681:	mov    rsi,r12
    3684:	mov    rdi,rbx
    3687:	call   368c <botlish_fn_38+0x2c>
			3688: R_X86_64_PLT32	botlish_fn_26-0x4 ; ht_size<HashTable>
    368c:	mov    rcx,rax
    368f:	mov    r13,rax
    3692:	test   rax,rcx
    3695:	je     376e <botlish_fn_38+0x10e>
    369b:	mov    rax,r13
    369e:	mov    QWORD PTR [rsp+0x8],rax
    36a3:	mov    rsi,r12
    36a6:	mov    rdi,rbx
    36a9:	call   36ae <botlish_fn_38+0x4e>
			36aa: R_X86_64_PLT32	botlish_fn_27-0x4 ; ht_tombstones<HashTable>
    36ae:	mov    rcx,rax
    36b1:	test   rcx,rcx
    36b4:	je     376e <botlish_fn_38+0x10e>
    36ba:	mov    QWORD PTR [rsp+0x10],rcx
    36bf:	mov    edx,0x1
    36c4:	mov    rax,r13
    36c7:	test   rax,0x1
    36cd:	jne    36f0 <botlish_fn_38+0x90>
    36d3:	xor    edx,edx
    36d5:	mov    rax,r13
    36d8:	test   rax,0x7
    36de:	jne    36f0 <botlish_fn_38+0x90>
    36e4:	mov    rax,r13
    36e7:	movzx  rax,BYTE PTR [rax]
    36eb:	cmp    al,0x1
    36ed:	sete   dl
    36f0:	test   dl,dl
    36f2:	jne    3713 <botlish_fn_38+0xb3>
    36f8:	mov    rdi,rbx
    36fb:	mov    rax,QWORD PTR [rdi+0x10]
    36ff:	mov    rcx,QWORD PTR [rax+0x8]
    3703:	xor    rdx,rdx
    3706:	mov    rsi,r13
    3709:	call   370e <botlish_fn_38+0xae>
			370a: R_X86_64_PLT32	rt_type_error-0x4
    370e:	jmp    376e <botlish_fn_38+0x10e>
    3713:	mov    eax,0x1
    3718:	test   rcx,0x1
    371f:	je     372d <botlish_fn_38+0xcd>
    3725:	mov    r8,rcx
    3728:	jmp    3750 <botlish_fn_38+0xf0>
    372d:	xor    eax,eax
    372f:	test   rcx,0x7
    3736:	je     3744 <botlish_fn_38+0xe4>
    373c:	mov    r8,rcx
    373f:	jmp    3750 <botlish_fn_38+0xf0>
    3744:	movzx  rax,BYTE PTR [rcx]
    3748:	mov    r8,rcx
    374b:	cmp    al,0x1
    374d:	sete   al
    3750:	test   al,al
    3752:	jne    3789 <botlish_fn_38+0x129>
    3758:	mov    rdi,rbx
    375b:	mov    rax,QWORD PTR [rdi+0x10]
    375f:	mov    rcx,QWORD PTR [rax+0x8]
    3763:	xor    rdx,rdx
    3766:	mov    rsi,r8
    3769:	call   376e <botlish_fn_38+0x10e>
			376a: R_X86_64_PLT32	rt_type_error-0x4
    376e:	xor    rax,rax
    3771:	mov    rbx,QWORD PTR [rsp+0x20]
    3776:	mov    r12,QWORD PTR [rsp+0x28]
    377b:	mov    r13,QWORD PTR [rsp+0x30]
    3780:	add    rsp,0x40
    3784:	mov    rsp,rbp
    3787:	pop    rbp
    3788:	ret
    3789:	mov    rcx,r8
    378c:	mov    rsi,r13
    378f:	mov    rax,rsi
    3792:	and    rax,rcx
    3795:	test   rax,0x1
    379b:	jne    37ac <botlish_fn_38+0x14c>
    37a1:	mov    rdx,r8
    37a4:	mov    rsi,r13
    37a7:	jmp    37ca <botlish_fn_38+0x16a>
    37ac:	mov    rcx,r8
    37af:	lea    rax,[rcx-0x1]
    37b3:	mov    rsi,r13
    37b6:	add    rsi,rax
    37b9:	seto   al
    37bc:	test   al,al
    37be:	je     37d5 <botlish_fn_38+0x175>
    37c4:	mov    rdx,r8
    37c7:	mov    rsi,r13
    37ca:	mov    rdi,rbx
    37cd:	call   37d2 <botlish_fn_38+0x172>
			37ce: R_X86_64_PLT32	rt_int_add-0x4
    37d2:	mov    rsi,rax
    37d5:	mov    QWORD PTR [rsp+0x8],rsi
    37da:	mov    QWORD PTR [rsp+0x10],0x3
    37e3:	test   rsi,0x1
    37ea:	je     380d <botlish_fn_38+0x1ad>
    37f0:	mov    rax,rsi
    37f3:	add    rax,0x2
    37f7:	mov    rcx,rax
    37fa:	seto   al
    37fd:	test   al,al
    37ff:	jne    380d <botlish_fn_38+0x1ad>
    3805:	mov    rsi,rcx
    3808:	jmp    381d <botlish_fn_38+0x1bd>
    380d:	mov    edx,0x3
    3812:	mov    rdi,rbx
    3815:	call   381a <botlish_fn_38+0x1ba>
			3816: R_X86_64_PLT32	rt_int_add-0x4
    381a:	mov    rsi,rax
    381d:	mov    QWORD PTR [rsp+0x8],rsi
    3822:	mov    edx,0x7
    3827:	mov    rdi,rdx
    382a:	mov    QWORD PTR [rsp+0x10],0x7
    3833:	test   rsi,0x1
    383a:	jne    3848 <botlish_fn_38+0x1e8>
    3840:	mov    rdx,rdi
    3843:	jmp    3874 <botlish_fn_38+0x214>
    3848:	mov    rax,rsi
    384b:	sar    rax,1
    384e:	imul   QWORD PTR [rip+0xf3]        # 3948 <botlish_fn_38+0x2e8>
    3855:	seto   cl
    3858:	or     rax,0x1
    385c:	test   cl,cl
    385e:	je     386c <botlish_fn_38+0x20c>
    3864:	mov    rdx,rdi
    3867:	jmp    3874 <botlish_fn_38+0x214>
    386c:	mov    rsi,rax
    386f:	jmp    387f <botlish_fn_38+0x21f>
    3874:	mov    rdi,rbx
    3877:	call   387c <botlish_fn_38+0x21c>
			3878: R_X86_64_PLT32	rt_int_mul-0x4
    387c:	mov    rsi,rax
    387f:	mov    QWORD PTR [rsp+0x8],rsi
    3884:	mov    r13,rsi
    3887:	mov    rsi,r12
    388a:	mov    rdi,rbx
    388d:	call   3892 <botlish_fn_38+0x232>
			388e: R_X86_64_PLT32	botlish_fn_28-0x4 ; ht_capacity<HashTable>
    3892:	mov    QWORD PTR [rsp],rax
    3896:	mov    QWORD PTR [rsp+0x10],0x5
    389f:	test   rax,0x1
    38a5:	mov    rcx,rax
    38a8:	je     38d7 <botlish_fn_38+0x277>
    38ae:	mov    rax,rcx
    38b1:	sar    rax,1
    38b4:	imul   QWORD PTR [rip+0x95]        # 3950 <botlish_fn_38+0x2f0>
    38bb:	seto   sil
    38bf:	or     rax,0x1
    38c3:	test   sil,sil
    38c6:	jne    38d7 <botlish_fn_38+0x277>
    38cc:	mov    rdx,rax
    38cf:	mov    rsi,r13
    38d2:	jmp    38ed <botlish_fn_38+0x28d>
    38d7:	mov    edx,0x5
    38dc:	mov    rsi,rcx
    38df:	mov    rdi,rbx
    38e2:	call   38e7 <botlish_fn_38+0x287>
			38e3: R_X86_64_PLT32	rt_int_mul-0x4
    38e7:	mov    rdx,rax
    38ea:	mov    rsi,r13
    38ed:	mov    rdi,rsi
    38f0:	and    rdi,rdx
    38f3:	test   rdi,0x1
    38fa:	jne    3920 <botlish_fn_38+0x2c0>
    3900:	mov    rdi,rbx
    3903:	call   3908 <botlish_fn_38+0x2a8>
			3904: R_X86_64_PLT32	rt_int_cmp-0x4
    3908:	mov    esi,0x2
    390d:	test   rax,rax
    3910:	mov    rax,rsi
    3913:	cmovg  rax,QWORD PTR [rip+0x2d]        # 3948 <botlish_fn_38+0x2e8>
    391b:	jmp    3930 <botlish_fn_38+0x2d0>
    3920:	mov    eax,0x2
    3925:	cmp    rsi,rdx
    3928:	cmovg  rax,QWORD PTR [rip+0x18]        # 3948 <botlish_fn_38+0x2e8>
    3930:	mov    rbx,QWORD PTR [rsp+0x20]
    3935:	mov    r12,QWORD PTR [rsp+0x28]
    393a:	mov    r13,QWORD PTR [rsp+0x30]
    393f:	add    rsp,0x40
    3943:	mov    rsp,rbp
    3946:	pop    rbp
    3947:	ret
    3948:	(bad)
    3949:	add    BYTE PTR [rax],al
    394b:	add    BYTE PTR [rax],al
    394d:	add    BYTE PTR [rax],al
    394f:	add    BYTE PTR [rax+rax*1],al
    3952:	add    BYTE PTR [rax],al
    3954:	add    BYTE PTR [rax],al
	...

0000000000003958 <botlish_entry_38: ht_should_grow<HashTable>>:
    3958:	push   rbp
    3959:	mov    rbp,rsp
    395c:	mov    rsi,QWORD PTR [rdx]
    395f:	call   3964 <botlish_entry_38+0xc>
			3960: R_X86_64_PLT32	botlish_fn_38-0x4 ; ht_should_grow<HashTable>
    3964:	mov    rsp,rbp
    3967:	pop    rbp
    3968:	ret
    3969:	add    BYTE PTR [rax],al
    396b:	add    BYTE PTR [rax],al
    396d:	add    BYTE PTR [rax],al
	...

0000000000003970 <botlish_fn_39: ht_grow_or_clean<HashTable>>:
    3970:	push   rbp
    3971:	mov    rbp,rsp
    3974:	sub    rsp,0x40
    3978:	mov    QWORD PTR [rsp+0x20],rbx
    397d:	mov    QWORD PTR [rsp+0x28],r12
    3982:	mov    QWORD PTR [rsp+0x30],r13
    3987:	mov    rbx,rdi
    398a:	mov    QWORD PTR [rsp+0x10],0x0
    3993:	mov    QWORD PTR [rsp],rsi
    3997:	mov    r12,rsi
    399a:	mov    rsi,r12
    399d:	mov    rdi,rbx
    39a0:	call   39a5 <botlish_fn_39+0x35>
			39a1: R_X86_64_PLT32	botlish_fn_27-0x4 ; ht_tombstones<HashTable>
    39a5:	test   rax,rax
    39a8:	mov    r13,rax
    39ab:	je     3b99 <botlish_fn_39+0x229>
    39b1:	mov    rsi,r12
    39b4:	mov    rdi,rbx
    39b7:	call   39bc <botlish_fn_39+0x4c>
			39b8: R_X86_64_PLT32	botlish_fn_26-0x4 ; ht_size<HashTable>
    39bc:	mov    r11,rax
    39bf:	test   r11,r11
    39c2:	je     3b99 <botlish_fn_39+0x229>
    39c8:	mov    ecx,0x1
    39cd:	mov    rax,r13
    39d0:	test   rax,0x1
    39d6:	je     39e4 <botlish_fn_39+0x74>
    39dc:	mov    r13,rax
    39df:	jmp    3a08 <botlish_fn_39+0x98>
    39e4:	xor    ecx,ecx
    39e6:	test   rax,0x7
    39ec:	je     39fa <botlish_fn_39+0x8a>
    39f2:	mov    r13,rax
    39f5:	jmp    3a08 <botlish_fn_39+0x98>
    39fa:	movzx  rcx,BYTE PTR [rax]
    39fe:	mov    r13,rax
    3a01:	rex cmp cl,0x1
    3a05:	sete   cl
    3a08:	test   cl,cl
    3a0a:	jne    3a2b <botlish_fn_39+0xbb>
    3a10:	mov    rdi,rbx
    3a13:	mov    rsi,QWORD PTR [rdi+0x10]
    3a17:	mov    rcx,QWORD PTR [rsi+0x10]
    3a1b:	xor    rdx,rdx
    3a1e:	mov    rsi,r13
    3a21:	call   3a26 <botlish_fn_39+0xb6>
			3a22: R_X86_64_PLT32	rt_type_error-0x4
    3a26:	jmp    3b99 <botlish_fn_39+0x229>
    3a2b:	mov    rsi,r13
    3a2e:	mov    eax,0x1
    3a33:	test   r11,0x1
    3a3a:	je     3a48 <botlish_fn_39+0xd8>
    3a40:	mov    r8,r11
    3a43:	jmp    3a6d <botlish_fn_39+0xfd>
    3a48:	xor    eax,eax
    3a4a:	test   r11,0x7
    3a51:	je     3a5f <botlish_fn_39+0xef>
    3a57:	mov    r8,r11
    3a5a:	jmp    3a6d <botlish_fn_39+0xfd>
    3a5f:	movzx  r10,BYTE PTR [r11]
    3a63:	mov    r8,r11
    3a66:	cmp    r10b,0x1
    3a6a:	sete   al
    3a6d:	test   al,al
    3a6f:	jne    3a90 <botlish_fn_39+0x120>
    3a75:	mov    rdi,rbx
    3a78:	mov    rax,QWORD PTR [rdi+0x10]
    3a7c:	mov    rcx,QWORD PTR [rax+0x10]
    3a80:	xor    rdx,rdx
    3a83:	mov    rsi,r8
    3a86:	call   3a8b <botlish_fn_39+0x11b>
			3a87: R_X86_64_PLT32	rt_type_error-0x4
    3a8b:	jmp    3b99 <botlish_fn_39+0x229>
    3a90:	mov    r11,r8
    3a93:	mov    rax,rsi
    3a96:	and    rax,r11
    3a99:	test   rax,0x1
    3a9f:	jne    3ac5 <botlish_fn_39+0x155>
    3aa5:	mov    rdx,r8
    3aa8:	mov    rdi,rbx
    3aab:	call   3ab0 <botlish_fn_39+0x140>
			3aac: R_X86_64_PLT32	rt_int_cmp-0x4
    3ab0:	mov    ecx,0x2
    3ab5:	test   rax,rax
    3ab8:	cmovg  rcx,QWORD PTR [rip+0x110]        # 3bd0 <botlish_fn_39+0x260>
    3ac0:	jmp    3ad8 <botlish_fn_39+0x168>
    3ac5:	mov    ecx,0x2
    3aca:	mov    r11,r8
    3acd:	cmp    rsi,r11
    3ad0:	cmovg  rcx,QWORD PTR [rip+0xf8]        # 3bd0 <botlish_fn_39+0x260>
    3ad8:	cmp    rcx,0x6
    3adc:	je     3b72 <botlish_fn_39+0x202>
    3ae2:	mov    rsi,r12
    3ae5:	mov    rdi,rbx
    3ae8:	call   3aed <botlish_fn_39+0x17d>
			3ae9: R_X86_64_PLT32	botlish_fn_28-0x4 ; ht_capacity<HashTable>
    3aed:	mov    QWORD PTR [rsp+0x8],rax
    3af2:	mov    QWORD PTR [rsp+0x10],0x5
    3afb:	test   rax,0x1
    3b01:	mov    rsi,rax
    3b04:	je     3b31 <botlish_fn_39+0x1c1>
    3b0a:	mov    rcx,rsi
    3b0d:	mov    rax,rcx
    3b10:	sar    rax,1
    3b13:	imul   QWORD PTR [rip+0xbe]        # 3bd8 <botlish_fn_39+0x268>
    3b1a:	seto   cl
    3b1d:	or     rax,0x1
    3b21:	test   cl,cl
    3b23:	jne    3b31 <botlish_fn_39+0x1c1>
    3b29:	mov    rdx,rax
    3b2c:	jmp    3b41 <botlish_fn_39+0x1d1>
    3b31:	mov    edx,0x5
    3b36:	mov    rdi,rbx
    3b39:	call   3b3e <botlish_fn_39+0x1ce>
			3b3a: R_X86_64_PLT32	rt_int_mul-0x4
    3b3e:	mov    rdx,rax
    3b41:	mov    QWORD PTR [rsp+0x8],rdx
    3b46:	mov    rsi,r12
    3b49:	mov    rdi,rbx
    3b4c:	call   3b51 <botlish_fn_39+0x1e1>
			3b4d: R_X86_64_PLT32	botlish_fn_37-0x4 ; ht_rehash<HashTable, int>
    3b51:	test   rax,rax
    3b54:	je     3b99 <botlish_fn_39+0x229>
    3b5a:	mov    rbx,QWORD PTR [rsp+0x20]
    3b5f:	mov    r12,QWORD PTR [rsp+0x28]
    3b64:	mov    r13,QWORD PTR [rsp+0x30]
    3b69:	add    rsp,0x40
    3b6d:	mov    rsp,rbp
    3b70:	pop    rbp
    3b71:	ret
    3b72:	mov    rsi,r12
    3b75:	mov    rdi,rbx
    3b78:	call   3b7d <botlish_fn_39+0x20d>
			3b79: R_X86_64_PLT32	botlish_fn_28-0x4 ; ht_capacity<HashTable>
    3b7d:	mov    QWORD PTR [rsp+0x8],rax
    3b82:	mov    rdx,rax
    3b85:	mov    rsi,r12
    3b88:	mov    rdi,rbx
    3b8b:	call   3b90 <botlish_fn_39+0x220>
			3b8c: R_X86_64_PLT32	botlish_fn_37-0x4 ; ht_rehash<HashTable, int>
    3b90:	test   rax,rax
    3b93:	jne    3bb4 <botlish_fn_39+0x244>
    3b99:	xor    rax,rax
    3b9c:	mov    rbx,QWORD PTR [rsp+0x20]
    3ba1:	mov    r12,QWORD PTR [rsp+0x28]
    3ba6:	mov    r13,QWORD PTR [rsp+0x30]
    3bab:	add    rsp,0x40
    3baf:	mov    rsp,rbp
    3bb2:	pop    rbp
    3bb3:	ret
    3bb4:	mov    rbx,QWORD PTR [rsp+0x20]
    3bb9:	mov    r12,QWORD PTR [rsp+0x28]
    3bbe:	mov    r13,QWORD PTR [rsp+0x30]
    3bc3:	add    rsp,0x40
    3bc7:	mov    rsp,rbp
    3bca:	pop    rbp
    3bcb:	ret
    3bcc:	add    BYTE PTR [rax],al
    3bce:	add    BYTE PTR [rax],al
    3bd0:	(bad)
    3bd1:	add    BYTE PTR [rax],al
    3bd3:	add    BYTE PTR [rax],al
    3bd5:	add    BYTE PTR [rax],al
    3bd7:	add    BYTE PTR [rax+rax*1],al
    3bda:	add    BYTE PTR [rax],al
    3bdc:	add    BYTE PTR [rax],al
	...

0000000000003be0 <botlish_entry_39: ht_grow_or_clean<HashTable>>:
    3be0:	push   rbp
    3be1:	mov    rbp,rsp
    3be4:	mov    rsi,QWORD PTR [rdx]
    3be7:	call   3bec <botlish_entry_39+0xc>
			3be8: R_X86_64_PLT32	botlish_fn_39-0x4 ; ht_grow_or_clean<HashTable>
    3bec:	mov    rsp,rbp
    3bef:	pop    rbp
    3bf0:	ret
    3bf1:	add    BYTE PTR [rax],al
    3bf3:	add    BYTE PTR [rax],al
    3bf5:	add    BYTE PTR [rax],al
	...

0000000000003bf8 <botlish_fn_40: ht_place<HashTable, int, str, str>>:
    3bf8:	push   rbp
    3bf9:	mov    rbp,rsp
    3bfc:	sub    rsp,0x70
    3c00:	mov    QWORD PTR [rsp+0x40],rbx
    3c05:	mov    QWORD PTR [rsp+0x48],r12
    3c0a:	mov    QWORD PTR [rsp+0x50],r13
    3c0f:	mov    QWORD PTR [rsp+0x58],r14
    3c14:	mov    QWORD PTR [rsp+0x60],r15
    3c19:	mov    r12,rdi
    3c1c:	mov    r14,r8
    3c1f:	mov    QWORD PTR [rsp+0x30],rcx
    3c24:	mov    QWORD PTR [rsp],rsi
    3c28:	mov    rax,QWORD PTR [rsi+0x18]
    3c2c:	mov    rbx,rsi
    3c2f:	mov    rsi,QWORD PTR [rax]
    3c32:	test   rdx,0x1
    3c39:	je     3fdf <botlish_fn_40+0x3e7>
    3c3f:	mov    rcx,QWORD PTR [rsi+0x8]
    3c43:	mov    rax,rdx
    3c46:	sar    rax,1
    3c49:	mov    r15,rdx
    3c4c:	cmp    rax,rcx
    3c4f:	jb     3c62 <botlish_fn_40+0x6a>
    3c55:	jmp    3fe2 <botlish_fn_40+0x3ea>
    3c5a:	mov    rsi,rax
    3c5d:	jmp    3c6a <botlish_fn_40+0x72>
    3c62:	mov    rcx,QWORD PTR [rsi+0x10]
    3c66:	mov    rsi,QWORD PTR [rcx+rax*8]
    3c6a:	mov    QWORD PTR [rsp+0x8],rsi
    3c6f:	mov    r13,rsi
    3c72:	mov    rax,QWORD PTR [rbx+0x18]
    3c76:	mov    rsi,QWORD PTR [rax]
    3c79:	mov    rdx,r15
    3c7c:	test   rdx,0x1
    3c83:	je     3ffb <botlish_fn_40+0x403>
    3c89:	mov    rcx,QWORD PTR [rsi+0x8]
    3c8d:	mov    rdx,r15
    3c90:	mov    rax,rdx
    3c93:	sar    rax,1
    3c96:	cmp    rax,rcx
    3c99:	jae    3ffb <botlish_fn_40+0x403>
    3c9f:	mov    rcx,QWORD PTR [rsi+0x18]
    3ca3:	test   rcx,rcx
    3ca6:	je     3ffb <botlish_fn_40+0x403>
    3cac:	mov    rcx,QWORD PTR [rsi+0x10]
    3cb0:	mov    QWORD PTR [rcx+rax*8],0x3
    3cb8:	mov    rax,QWORD PTR [rbx+0x18]
    3cbc:	mov    rsi,QWORD PTR [rax+0x8]
    3cc0:	mov    rdx,r15
    3cc3:	test   rdx,0x1
    3cca:	je     4019 <botlish_fn_40+0x421>
    3cd0:	mov    rcx,QWORD PTR [rsi+0x8]
    3cd4:	mov    rdx,r15
    3cd7:	mov    rax,rdx
    3cda:	sar    rax,1
    3cdd:	cmp    rax,rcx
    3ce0:	jae    4023 <botlish_fn_40+0x42b>
    3ce6:	mov    rcx,QWORD PTR [rsi+0x18]
    3cea:	test   rcx,rcx
    3ced:	je     402d <botlish_fn_40+0x435>
    3cf3:	mov    rcx,QWORD PTR [rsp+0x30]
    3cf8:	mov    r8,QWORD PTR [rsi+0x10]
    3cfc:	mov    QWORD PTR [r8+rax*8],rcx
    3d00:	mov    r10,QWORD PTR [rbx+0x18]
    3d04:	mov    rsi,QWORD PTR [r10+0x10]
    3d08:	mov    rdx,r15
    3d0b:	test   rdx,0x1
    3d12:	je     404b <botlish_fn_40+0x453>
    3d18:	mov    rcx,QWORD PTR [rsi+0x8]
    3d1c:	mov    rdx,r15
    3d1f:	mov    rax,rdx
    3d22:	sar    rax,1
    3d25:	cmp    rax,rcx
    3d28:	jae    4056 <botlish_fn_40+0x45e>
    3d2e:	mov    rcx,QWORD PTR [rsi+0x18]
    3d32:	test   rcx,rcx
    3d35:	je     4061 <botlish_fn_40+0x469>
    3d3b:	mov    rcx,r14
    3d3e:	mov    rdx,QWORD PTR [rsi+0x10]
    3d42:	mov    QWORD PTR [rdx+rax*8],rcx
    3d46:	mov    rax,QWORD PTR [rbx+0x18]
    3d4a:	mov    rsi,QWORD PTR [rax+0x18]
    3d4e:	mov    QWORD PTR [rsp+0x10],rsi
    3d53:	mov    r15,rsi
    3d56:	mov    QWORD PTR [rsp+0x18],0x1
    3d5f:	mov    rsi,rbx
    3d62:	mov    rdi,r12
    3d65:	call   3d6a <botlish_fn_40+0x172>
			3d66: R_X86_64_PLT32	botlish_fn_26-0x4 ; ht_size<HashTable>
    3d6a:	test   rax,rax
    3d6d:	je     3f88 <botlish_fn_40+0x390>
    3d73:	mov    QWORD PTR [rsp+0x20],rax
    3d78:	mov    edx,0x3
    3d7d:	mov    r14,rdx
    3d80:	mov    QWORD PTR [rsp+0x28],0x3
    3d89:	mov    ecx,0x1
    3d8e:	test   rax,0x1
    3d94:	je     3da2 <botlish_fn_40+0x1aa>
    3d9a:	mov    rsi,rax
    3d9d:	jmp    3dc6 <botlish_fn_40+0x1ce>
    3da2:	xor    ecx,ecx
    3da4:	test   rax,0x7
    3daa:	je     3db8 <botlish_fn_40+0x1c0>
    3db0:	mov    rsi,rax
    3db3:	jmp    3dc6 <botlish_fn_40+0x1ce>
    3db8:	movzx  rcx,BYTE PTR [rax]
    3dbc:	mov    rsi,rax
    3dbf:	rex cmp cl,0x1
    3dc3:	sete   cl
    3dc6:	test   cl,cl
    3dc8:	jne    3de6 <botlish_fn_40+0x1ee>
    3dce:	mov    rdi,r12
    3dd1:	mov    rax,QWORD PTR [rdi+0x10]
    3dd5:	mov    rcx,QWORD PTR [rax+0x8]
    3dd9:	xor    rdx,rdx
    3ddc:	call   3de1 <botlish_fn_40+0x1e9>
			3ddd: R_X86_64_PLT32	rt_type_error-0x4
    3de1:	jmp    3f88 <botlish_fn_40+0x390>
    3de6:	test   rsi,0x1
    3ded:	je     3e05 <botlish_fn_40+0x20d>
    3df3:	mov    rcx,rsi
    3df6:	add    rcx,0x2
    3dfa:	seto   al
    3dfd:	test   al,al
    3dff:	je     3e13 <botlish_fn_40+0x21b>
    3e05:	mov    rdx,r14
    3e08:	mov    rdi,r12
    3e0b:	call   3e10 <botlish_fn_40+0x218>
			3e0c: R_X86_64_PLT32	rt_int_add-0x4
    3e10:	mov    rcx,rax
    3e13:	mov    rsi,r15
    3e16:	mov    rax,QWORD PTR [rsi+0x8]
    3e1a:	test   rax,rax
    3e1d:	je     4080 <botlish_fn_40+0x488>
    3e23:	mov    rax,QWORD PTR [rsi+0x18]
    3e27:	test   rax,rax
    3e2a:	jne    3e3d <botlish_fn_40+0x245>
    3e30:	jmp    4080 <botlish_fn_40+0x488>
    3e35:	mov    rsi,r13
    3e38:	jmp    3e47 <botlish_fn_40+0x24f>
    3e3d:	mov    rax,QWORD PTR [rsi+0x10]
    3e41:	mov    QWORD PTR [rax],rcx
    3e44:	mov    rsi,r13
    3e47:	test   rsi,0x1
    3e4e:	jne    3e76 <botlish_fn_40+0x27e>
    3e54:	mov    edx,0x5
    3e59:	mov    rdi,r12
    3e5c:	call   3e61 <botlish_fn_40+0x269>
			3e5d: R_X86_64_PLT32	rt_int_cmp-0x4
    3e61:	mov    ecx,0x2
    3e66:	test   rax,rax
    3e69:	cmove  rcx,QWORD PTR [rip+0x257]        # 40c8 <botlish_fn_40+0x4d0>
    3e71:	jmp    3e87 <botlish_fn_40+0x28f>
    3e76:	mov    ecx,0x2
    3e7b:	cmp    rsi,0x5
    3e7f:	cmove  rcx,QWORD PTR [rip+0x241]        # 40c8 <botlish_fn_40+0x4d0>
    3e87:	cmp    rcx,0x6
    3e8b:	je     3e99 <botlish_fn_40+0x2a1>
    3e91:	mov    rax,rbx
    3e94:	jmp    3fbd <botlish_fn_40+0x3c5>
    3e99:	mov    r10,QWORD PTR [rbx+0x18]
    3e9d:	mov    rsi,QWORD PTR [r10+0x18]
    3ea1:	mov    QWORD PTR [rsp+0x8],rsi
    3ea6:	mov    r13,rsi
    3ea9:	mov    QWORD PTR [rsp+0x10],0x3
    3eb2:	mov    rsi,rbx
    3eb5:	mov    rdi,r12
    3eb8:	call   3ebd <botlish_fn_40+0x2c5>
			3eb9: R_X86_64_PLT32	botlish_fn_27-0x4 ; ht_tombstones<HashTable>
    3ebd:	test   rax,rax
    3ec0:	je     3f88 <botlish_fn_40+0x390>
    3ec6:	mov    QWORD PTR [rsp+0x18],rax
    3ecb:	mov    QWORD PTR [rsp+0x20],0x3
    3ed4:	mov    ecx,0x1
    3ed9:	test   rax,0x1
    3edf:	je     3eed <botlish_fn_40+0x2f5>
    3ee5:	mov    rsi,rax
    3ee8:	jmp    3f11 <botlish_fn_40+0x319>
    3eed:	xor    ecx,ecx
    3eef:	test   rax,0x7
    3ef5:	je     3f03 <botlish_fn_40+0x30b>
    3efb:	mov    rsi,rax
    3efe:	jmp    3f11 <botlish_fn_40+0x319>
    3f03:	movzx  rcx,BYTE PTR [rax]
    3f07:	mov    rsi,rax
    3f0a:	rex cmp cl,0x1
    3f0e:	sete   cl
    3f11:	test   cl,cl
    3f13:	jne    3f31 <botlish_fn_40+0x339>
    3f19:	mov    rdi,r12
    3f1c:	mov    rax,QWORD PTR [rdi+0x10]
    3f20:	mov    rcx,QWORD PTR [rax+0x18]
    3f24:	xor    rdx,rdx
    3f27:	call   3f2c <botlish_fn_40+0x334>
			3f28: R_X86_64_PLT32	rt_type_error-0x4
    3f2c:	jmp    3f88 <botlish_fn_40+0x390>
    3f31:	test   rsi,0x1
    3f38:	je     3f57 <botlish_fn_40+0x35f>
    3f3e:	mov    rcx,rsi
    3f41:	sub    rcx,0x3
    3f45:	seto   al
    3f48:	add    rcx,0x1
    3f4f:	test   al,al
    3f51:	je     3f65 <botlish_fn_40+0x36d>
    3f57:	mov    rdx,r14
    3f5a:	mov    rdi,r12
    3f5d:	call   3f62 <botlish_fn_40+0x36a>
			3f5e: R_X86_64_PLT32	rt_int_sub-0x4
    3f62:	mov    rcx,rax
    3f65:	mov    rsi,r13
    3f68:	mov    rax,QWORD PTR [rsi+0x8]
    3f6c:	cmp    rax,0x1
    3f70:	jbe    409b <botlish_fn_40+0x4a3>
    3f76:	mov    rax,QWORD PTR [rsi+0x18]
    3f7a:	test   rax,rax
    3f7d:	jne    3fb2 <botlish_fn_40+0x3ba>
    3f83:	jmp    40a6 <botlish_fn_40+0x4ae>
    3f88:	xor    rax,rax
    3f8b:	mov    rbx,QWORD PTR [rsp+0x40]
    3f90:	mov    r12,QWORD PTR [rsp+0x48]
    3f95:	mov    r13,QWORD PTR [rsp+0x50]
    3f9a:	mov    r14,QWORD PTR [rsp+0x58]
    3f9f:	mov    r15,QWORD PTR [rsp+0x60]
    3fa4:	add    rsp,0x70
    3fa8:	mov    rsp,rbp
    3fab:	pop    rbp
    3fac:	ret
    3fad:	jmp    3fba <botlish_fn_40+0x3c2>
    3fb2:	mov    rax,QWORD PTR [rsi+0x10]
    3fb6:	mov    QWORD PTR [rax+0x8],rcx
    3fba:	mov    rax,rbx
    3fbd:	mov    rbx,QWORD PTR [rsp+0x40]
    3fc2:	mov    r12,QWORD PTR [rsp+0x48]
    3fc7:	mov    r13,QWORD PTR [rsp+0x50]
    3fcc:	mov    r14,QWORD PTR [rsp+0x58]
    3fd1:	mov    r15,QWORD PTR [rsp+0x60]
    3fd6:	add    rsp,0x70
    3fda:	mov    rsp,rbp
    3fdd:	pop    rbp
    3fde:	ret
    3fdf:	mov    r15,rdx
    3fe2:	mov    rdx,r15
    3fe5:	mov    rdi,r12
    3fe8:	call   3fed <botlish_fn_40+0x3f5>
			3fe9: R_X86_64_PLT32	rt_mutarray_get-0x4
    3fed:	test   rax,rax
    3ff0:	jne    3c5a <botlish_fn_40+0x62>
    3ff6:	jmp    3f88 <botlish_fn_40+0x390>
    3ffb:	mov    ecx,0x3
    4000:	mov    rdx,r15
    4003:	mov    rdi,r12
    4006:	call   400b <botlish_fn_40+0x413>
			4007: R_X86_64_PLT32	rt_mutarray_set-0x4
    400b:	test   rax,rax
    400e:	jne    3cb8 <botlish_fn_40+0xc0>
    4014:	jmp    3f88 <botlish_fn_40+0x390>
    4019:	mov    rcx,QWORD PTR [rsp+0x30]
    401e:	jmp    4032 <botlish_fn_40+0x43a>
    4023:	mov    rcx,QWORD PTR [rsp+0x30]
    4028:	jmp    4032 <botlish_fn_40+0x43a>
    402d:	mov    rcx,QWORD PTR [rsp+0x30]
    4032:	mov    rdx,r15
    4035:	mov    rdi,r12
    4038:	call   403d <botlish_fn_40+0x445>
			4039: R_X86_64_PLT32	rt_mutarray_set-0x4
    403d:	test   rax,rax
    4040:	jne    3d00 <botlish_fn_40+0x108>
    4046:	jmp    3f88 <botlish_fn_40+0x390>
    404b:	mov    rcx,r14
    404e:	mov    rdx,r15
    4051:	jmp    4067 <botlish_fn_40+0x46f>
    4056:	mov    rcx,r14
    4059:	mov    rdx,r15
    405c:	jmp    4067 <botlish_fn_40+0x46f>
    4061:	mov    rcx,r14
    4064:	mov    rdx,r15
    4067:	mov    rdx,r15
    406a:	mov    rdi,r12
    406d:	call   4072 <botlish_fn_40+0x47a>
			406e: R_X86_64_PLT32	rt_mutarray_set-0x4
    4072:	test   rax,rax
    4075:	jne    3d46 <botlish_fn_40+0x14e>
    407b:	jmp    3f88 <botlish_fn_40+0x390>
    4080:	mov    edx,0x1
    4085:	mov    rdi,r12
    4088:	call   408d <botlish_fn_40+0x495>
			4089: R_X86_64_PLT32	rt_mutarray_set-0x4
    408d:	test   rax,rax
    4090:	jne    3e35 <botlish_fn_40+0x23d>
    4096:	jmp    3f88 <botlish_fn_40+0x390>
    409b:	mov    rdx,r14
    409e:	mov    rdi,r12
    40a1:	jmp    40ac <botlish_fn_40+0x4b4>
    40a6:	mov    rdx,r14
    40a9:	mov    rdi,r12
    40ac:	mov    rdx,r14
    40af:	mov    rdi,r12
    40b2:	call   40b7 <botlish_fn_40+0x4bf>
			40b3: R_X86_64_PLT32	rt_mutarray_set-0x4
    40b7:	test   rax,rax
    40ba:	jne    3fba <botlish_fn_40+0x3c2>
    40c0:	jmp    3f88 <botlish_fn_40+0x390>
    40c5:	add    BYTE PTR [rax],al
    40c7:	add    BYTE PTR [rsi],al
    40c9:	add    BYTE PTR [rax],al
    40cb:	add    BYTE PTR [rax],al
    40cd:	add    BYTE PTR [rax],al
	...

00000000000040d0 <botlish_entry_40: ht_place<HashTable, int, str, str>>:
    40d0:	push   rbp
    40d1:	mov    rbp,rsp
    40d4:	mov    rsi,QWORD PTR [rdx]
    40d7:	mov    r9,QWORD PTR [rdx+0x8]
    40db:	mov    rcx,QWORD PTR [rdx+0x10]
    40df:	mov    r8,QWORD PTR [rdx+0x18]
    40e3:	mov    rdx,r9
    40e6:	call   40eb <botlish_entry_40+0x1b>
			40e7: R_X86_64_PLT32	botlish_fn_40-0x4 ; ht_place<HashTable, int, str, str>
    40eb:	mov    rsp,rbp
    40ee:	pop    rbp
    40ef:	ret

00000000000040f0 <botlish_fn_41: ht_set<HashTable, str, str>>:
    40f0:	push   rbp
    40f1:	mov    rbp,rsp
    40f4:	sub    rsp,0x60
    40f8:	mov    QWORD PTR [rsp+0x30],rbx
    40fd:	mov    QWORD PTR [rsp+0x38],r12
    4102:	mov    QWORD PTR [rsp+0x40],r13
    4107:	mov    QWORD PTR [rsp+0x48],r14
    410c:	mov    QWORD PTR [rsp+0x50],r15
    4111:	mov    r12,rdi
    4114:	mov    r14,rdx
    4117:	mov    QWORD PTR [rsp],rsi
    411b:	mov    r13,rsi
    411e:	mov    QWORD PTR [rsp+0x8],rdx
    4123:	mov    QWORD PTR [rsp+0x10],rcx
    4128:	mov    rbx,rcx
    412b:	mov    rdx,r14
    412e:	mov    rsi,r13
    4131:	mov    rdi,r12
    4134:	call   4139 <botlish_fn_41+0x49>
			4135: R_X86_64_PLT32	botlish_fn_29-0x4 ; ht_probe_start<HashTable, str>
    4139:	test   rax,rax
    413c:	mov    rcx,rax
    413f:	je     4330 <botlish_fn_41+0x240>
    4145:	mov    r8,0xffffffffffffffff
    414c:	mov    QWORD PTR [rsp+0x20],r8
    4151:	mov    rdx,r14
    4154:	mov    rsi,r13
    4157:	mov    rdi,r12
    415a:	call   415f <botlish_fn_41+0x6f>
			415b: R_X86_64_PLT32	botlish_fn_32-0x4 ; ht_find_insert<HashTable, str, int, int>
    415f:	test   rax,rax
    4162:	je     4330 <botlish_fn_41+0x240>
    4168:	mov    QWORD PTR [rsp+0x18],rax
    416d:	mov    rsi,r13
    4170:	mov    rcx,QWORD PTR [rsi+0x18]
    4174:	mov    rsi,QWORD PTR [rcx]
    4177:	test   rax,0x1
    417d:	je     438d <botlish_fn_41+0x29d>
    4183:	mov    rdx,QWORD PTR [rsi+0x8]
    4187:	mov    rcx,rax
    418a:	sar    rcx,1
    418d:	mov    r15,rax
    4190:	cmp    rcx,rdx
    4193:	jb     41a6 <botlish_fn_41+0xb6>
    4199:	jmp    4390 <botlish_fn_41+0x2a0>
    419e:	mov    rsi,rax
    41a1:	jmp    41ae <botlish_fn_41+0xbe>
    41a6:	mov    rax,QWORD PTR [rsi+0x10]
    41aa:	mov    rsi,QWORD PTR [rax+rcx*8]
    41ae:	test   rsi,0x1
    41b5:	jne    41dd <botlish_fn_41+0xed>
    41bb:	mov    edx,0x3
    41c0:	mov    rdi,r12
    41c3:	call   41c8 <botlish_fn_41+0xd8>
			41c4: R_X86_64_PLT32	rt_int_cmp-0x4
    41c8:	mov    ecx,0x2
    41cd:	test   rax,rax
    41d0:	cmove  rcx,QWORD PTR [rip+0x208]        # 43e0 <botlish_fn_41+0x2f0>
    41d8:	jmp    41ee <botlish_fn_41+0xfe>
    41dd:	mov    ecx,0x2
    41e2:	cmp    rsi,0x3
    41e6:	cmove  rcx,QWORD PTR [rip+0x1f2]        # 43e0 <botlish_fn_41+0x2f0>
    41ee:	cmp    rcx,0x6
    41f2:	je     42f0 <botlish_fn_41+0x200>
    41f8:	mov    rsi,r13
    41fb:	mov    rdi,r12
    41fe:	call   4203 <botlish_fn_41+0x113>
			41ff: R_X86_64_PLT32	botlish_fn_38-0x4 ; ht_should_grow<HashTable>
    4203:	test   rax,rax
    4206:	je     4330 <botlish_fn_41+0x240>
    420c:	cmp    rax,0x6
    4210:	je     4255 <botlish_fn_41+0x165>
    4216:	mov    rcx,r14
    4219:	mov    rdx,r15
    421c:	mov    rsi,r13
    421f:	mov    rdi,r12
    4222:	mov    r8,rbx
    4225:	call   422a <botlish_fn_41+0x13a>
			4226: R_X86_64_PLT32	botlish_fn_40-0x4 ; ht_place<HashTable, int, str, str>
    422a:	test   rax,rax
    422d:	je     4330 <botlish_fn_41+0x240>
    4233:	mov    rbx,QWORD PTR [rsp+0x30]
    4238:	mov    r12,QWORD PTR [rsp+0x38]
    423d:	mov    r13,QWORD PTR [rsp+0x40]
    4242:	mov    r14,QWORD PTR [rsp+0x48]
    4247:	mov    r15,QWORD PTR [rsp+0x50]
    424c:	add    rsp,0x60
    4250:	mov    rsp,rbp
    4253:	pop    rbp
    4254:	ret
    4255:	mov    rsi,r13
    4258:	mov    rdi,r12
    425b:	call   4260 <botlish_fn_41+0x170>
			425c: R_X86_64_PLT32	botlish_fn_39-0x4 ; ht_grow_or_clean<HashTable>
    4260:	mov    r11,rax
    4263:	mov    r13,rax
    4266:	test   rax,r11
    4269:	je     4330 <botlish_fn_41+0x240>
    426f:	mov    rax,r13
    4272:	mov    QWORD PTR [rsp],rax
    4276:	mov    rdx,r14
    4279:	mov    rsi,r13
    427c:	mov    rdi,r12
    427f:	call   4284 <botlish_fn_41+0x194>
			4280: R_X86_64_PLT32	botlish_fn_29-0x4 ; ht_probe_start<HashTable, str>
    4284:	test   rax,rax
    4287:	mov    rcx,rax
    428a:	je     4330 <botlish_fn_41+0x240>
    4290:	mov    r8,QWORD PTR [rsp+0x20]
    4295:	mov    rdx,r14
    4298:	mov    rsi,r13
    429b:	mov    rdi,r12
    429e:	call   42a3 <botlish_fn_41+0x1b3>
			429f: R_X86_64_PLT32	botlish_fn_32-0x4 ; ht_find_insert<HashTable, str, int, int>
    42a3:	test   rax,rax
    42a6:	je     4330 <botlish_fn_41+0x240>
    42ac:	mov    QWORD PTR [rsp+0x18],rax
    42b1:	mov    rcx,r14
    42b4:	mov    rdx,rax
    42b7:	mov    rsi,r13
    42ba:	mov    rdi,r12
    42bd:	mov    r8,rbx
    42c0:	call   42c5 <botlish_fn_41+0x1d5>
			42c1: R_X86_64_PLT32	botlish_fn_40-0x4 ; ht_place<HashTable, int, str, str>
    42c5:	test   rax,rax
    42c8:	je     4330 <botlish_fn_41+0x240>
    42ce:	mov    rbx,QWORD PTR [rsp+0x30]
    42d3:	mov    r12,QWORD PTR [rsp+0x38]
    42d8:	mov    r13,QWORD PTR [rsp+0x40]
    42dd:	mov    r14,QWORD PTR [rsp+0x48]
    42e2:	mov    r15,QWORD PTR [rsp+0x50]
    42e7:	add    rsp,0x60
    42eb:	mov    rsp,rbp
    42ee:	pop    rbp
    42ef:	ret
    42f0:	mov    rdx,r15
    42f3:	mov    rsi,r13
    42f6:	mov    rax,QWORD PTR [rsi+0x18]
    42fa:	mov    rsi,QWORD PTR [rax+0x10]
    42fe:	test   rdx,0x1
    4305:	je     43a9 <botlish_fn_41+0x2b9>
    430b:	mov    rcx,QWORD PTR [rsi+0x8]
    430f:	mov    rax,rdx
    4312:	sar    rax,1
    4315:	cmp    rax,rcx
    4318:	jae    43b4 <botlish_fn_41+0x2c4>
    431e:	mov    rcx,QWORD PTR [rsi+0x18]
    4322:	test   rcx,rcx
    4325:	jne    435d <botlish_fn_41+0x26d>
    432b:	jmp    43bf <botlish_fn_41+0x2cf>
    4330:	xor    rax,rax
    4333:	mov    rbx,QWORD PTR [rsp+0x30]
    4338:	mov    r12,QWORD PTR [rsp+0x38]
    433d:	mov    r13,QWORD PTR [rsp+0x40]
    4342:	mov    r14,QWORD PTR [rsp+0x48]
    4347:	mov    r15,QWORD PTR [rsp+0x50]
    434c:	add    rsp,0x60
    4350:	mov    rsp,rbp
    4353:	pop    rbp
    4354:	ret
    4355:	mov    rax,r13
    4358:	jmp    436b <botlish_fn_41+0x27b>
    435d:	mov    rcx,rbx
    4360:	mov    rdx,QWORD PTR [rsi+0x10]
    4364:	mov    QWORD PTR [rdx+rax*8],rcx
    4368:	mov    rax,r13
    436b:	mov    rbx,QWORD PTR [rsp+0x30]
    4370:	mov    r12,QWORD PTR [rsp+0x38]
    4375:	mov    r13,QWORD PTR [rsp+0x40]
    437a:	mov    r14,QWORD PTR [rsp+0x48]
    437f:	mov    r15,QWORD PTR [rsp+0x50]
    4384:	add    rsp,0x60
    4388:	mov    rsp,rbp
    438b:	pop    rbp
    438c:	ret
    438d:	mov    r15,rax
    4390:	mov    rdx,r15
    4393:	mov    rdi,r12
    4396:	call   439b <botlish_fn_41+0x2ab>
			4397: R_X86_64_PLT32	rt_mutarray_get-0x4
    439b:	test   rax,rax
    439e:	jne    419e <botlish_fn_41+0xae>
    43a4:	jmp    4330 <botlish_fn_41+0x240>
    43a9:	mov    rcx,rbx
    43ac:	mov    rdi,r12
    43af:	jmp    43c5 <botlish_fn_41+0x2d5>
    43b4:	mov    rcx,rbx
    43b7:	mov    rdi,r12
    43ba:	jmp    43c5 <botlish_fn_41+0x2d5>
    43bf:	mov    rcx,rbx
    43c2:	mov    rdi,r12
    43c5:	mov    rdi,r12
    43c8:	call   43cd <botlish_fn_41+0x2dd>
			43c9: R_X86_64_PLT32	rt_mutarray_set-0x4
    43cd:	test   rax,rax
    43d0:	jne    4355 <botlish_fn_41+0x265>
    43d6:	jmp    4330 <botlish_fn_41+0x240>
    43db:	add    BYTE PTR [rax],al
    43dd:	add    BYTE PTR [rax],al
    43df:	add    BYTE PTR [rsi],al
    43e1:	add    BYTE PTR [rax],al
    43e3:	add    BYTE PTR [rax],al
    43e5:	add    BYTE PTR [rax],al
	...

00000000000043e8 <botlish_entry_41: ht_set<HashTable, str, str>>:
    43e8:	push   rbp
    43e9:	mov    rbp,rsp
    43ec:	mov    rsi,QWORD PTR [rdx]
    43ef:	mov    r8,QWORD PTR [rdx+0x8]
    43f3:	mov    rcx,QWORD PTR [rdx+0x10]
    43f7:	mov    rdx,r8
    43fa:	call   43ff <botlish_entry_41+0x17>
			43fb: R_X86_64_PLT32	botlish_fn_41-0x4 ; ht_set<HashTable, str, str>
    43ff:	mov    rsp,rbp
    4402:	pop    rbp
    4403:	ret

0000000000004404 <botlish_fn_42: row_new<bool, int>>:
    4404:	push   rbp
    4405:	mov    rbp,rsp
    4408:	sub    rsp,0x10
    440c:	mov    QWORD PTR [rsp],rdx
    4410:	mov    r8,rdx
    4413:	cmp    rsi,0x6
    4417:	je     4434 <botlish_fn_42+0x30>
    441d:	call   4422 <botlish_fn_42+0x1e>
			441e: R_X86_64_PLT32	botlish_fn_23-0x4 ; ht_new<generic>
    4422:	test   rax,rax
    4425:	je     4445 <botlish_fn_42+0x41>
    442b:	add    rsp,0x10
    442f:	mov    rsp,rbp
    4432:	pop    rbp
    4433:	ret
    4434:	mov    rsi,r8
    4437:	call   443c <botlish_fn_42+0x38>
			4438: R_X86_64_PLT32	botlish_fn_25-0x4 ; ht_new_sized<int>
    443c:	test   rax,rax
    443f:	jne    4451 <botlish_fn_42+0x4d>
    4445:	xor    rax,rax
    4448:	add    rsp,0x10
    444c:	mov    rsp,rbp
    444f:	pop    rbp
    4450:	ret
    4451:	add    rsp,0x10
    4455:	mov    rsp,rbp
    4458:	pop    rbp
    4459:	ret

000000000000445a <botlish_entry_42: row_new<bool, int>>:
    445a:	push   rbp
    445b:	mov    rbp,rsp
    445e:	mov    rsi,QWORD PTR [rdx]
    4461:	mov    rdx,QWORD PTR [rdx+0x8]
    4465:	call   446a <botlish_entry_42+0x10>
			4466: R_X86_64_PLT32	botlish_fn_42-0x4 ; row_new<bool, int>
    446a:	mov    rsp,rbp
    446d:	pop    rbp
    446e:	ret

000000000000446f <botlish_fn_43: row_fill<HashTable, List[str], List[str], int, int>>:
    446f:	push   rbp
    4470:	mov    rbp,rsp
    4473:	sub    rsp,0x70
    4477:	mov    QWORD PTR [rsp+0x40],rbx
    447c:	mov    QWORD PTR [rsp+0x48],r12
    4481:	mov    QWORD PTR [rsp+0x50],r13
    4486:	mov    QWORD PTR [rsp+0x58],r14
    448b:	mov    QWORD PTR [rsp+0x60],r15
    4490:	mov    r15,rdi
    4493:	mov    QWORD PTR [rsp],rsi
    4497:	mov    QWORD PTR [rsp+0x8],rdx
    449c:	mov    QWORD PTR [rsp+0x10],rcx
    44a1:	mov    r14,rcx
    44a4:	sar    r8,1
    44a7:	mov    rbx,r8
    44aa:	mov    r12,r9
    44ad:	mov    QWORD PTR [rsp+0x28],rsi
    44b2:	cmp    rbx,r12
    44b5:	jge    45c4 <botlish_fn_43+0x155>
    44bb:	mov    r13,rdx
    44be:	mov    rdx,QWORD PTR [r13+0x8]
    44c2:	mov    rcx,rbx
    44c5:	shl    rcx,1
    44c8:	or     rcx,0x1
    44cc:	sar    rcx,1
    44cf:	cmp    rcx,rdx
    44d2:	jb     44fe <botlish_fn_43+0x8f>
    44d8:	mov    rdx,rbx
    44db:	shl    rdx,1
    44de:	or     rdx,0x1
    44e2:	mov    rsi,r13
    44e5:	mov    rdi,r15
    44e8:	call   44ed <botlish_fn_43+0x7e>
			44e9: R_X86_64_PLT32	rt_list_get-0x4
    44ed:	test   rax,rax
    44f0:	je     457d <botlish_fn_43+0x10e>
    44f6:	mov    rdx,rax
    44f9:	jmp    4506 <botlish_fn_43+0x97>
    44fe:	mov    rax,QWORD PTR [r13+0x10]
    4502:	mov    rdx,QWORD PTR [rax+rcx*8]
    4506:	mov    QWORD PTR [rsp+0x18],rdx
    450b:	mov    QWORD PTR [rsp+0x30],rdx
    4510:	mov    rax,QWORD PTR [r14+0x8]
    4514:	mov    rcx,rbx
    4517:	shl    rcx,1
    451a:	or     rcx,0x1
    451e:	sar    rcx,1
    4521:	cmp    rcx,rax
    4524:	jb     4555 <botlish_fn_43+0xe6>
    452a:	mov    rdx,rbx
    452d:	shl    rdx,1
    4530:	or     rdx,0x1
    4534:	mov    rsi,r14
    4537:	mov    rdi,r15
    453a:	call   453f <botlish_fn_43+0xd0>
			453b: R_X86_64_PLT32	rt_list_get-0x4
    453f:	test   rax,rax
    4542:	je     457d <botlish_fn_43+0x10e>
    4548:	mov    rcx,rax
    454b:	mov    rsi,QWORD PTR [rsp+0x28]
    4550:	jmp    4562 <botlish_fn_43+0xf3>
    4555:	mov    rax,QWORD PTR [r14+0x10]
    4559:	mov    rcx,QWORD PTR [rax+rcx*8]
    455d:	mov    rsi,QWORD PTR [rsp+0x28]
    4562:	mov    QWORD PTR [rsp+0x20],rcx
    4567:	mov    rdx,QWORD PTR [rsp+0x30]
    456c:	mov    rdi,r15
    456f:	call   4574 <botlish_fn_43+0x105>
			4570: R_X86_64_PLT32	botlish_fn_41-0x4 ; ht_set<HashTable, str, str>
    4574:	test   rax,rax
    4577:	jne    45a2 <botlish_fn_43+0x133>
    457d:	xor    rax,rax
    4580:	mov    rbx,QWORD PTR [rsp+0x40]
    4585:	mov    r12,QWORD PTR [rsp+0x48]
    458a:	mov    r13,QWORD PTR [rsp+0x50]
    458f:	mov    r14,QWORD PTR [rsp+0x58]
    4594:	mov    r15,QWORD PTR [rsp+0x60]
    4599:	add    rsp,0x70
    459d:	mov    rsp,rbp
    45a0:	pop    rbp
    45a1:	ret
    45a2:	mov    QWORD PTR [rsp],rax
    45a6:	mov    QWORD PTR [rsp+0x8],r13
    45ab:	mov    QWORD PTR [rsp+0x10],r14
    45b0:	add    rbx,0x1
    45b7:	mov    rdx,r13
    45ba:	mov    QWORD PTR [rsp+0x28],rax
    45bf:	jmp    44b2 <botlish_fn_43+0x43>
    45c4:	mov    rax,QWORD PTR [rsp+0x28]
    45c9:	mov    rbx,QWORD PTR [rsp+0x40]
    45ce:	mov    r12,QWORD PTR [rsp+0x48]
    45d3:	mov    r13,QWORD PTR [rsp+0x50]
    45d8:	mov    r14,QWORD PTR [rsp+0x58]
    45dd:	mov    r15,QWORD PTR [rsp+0x60]
    45e2:	add    rsp,0x70
    45e6:	mov    rsp,rbp
    45e9:	pop    rbp
    45ea:	ret

00000000000045eb <botlish_entry_43: row_fill<HashTable, List[str], List[str], int, int>>:
    45eb:	push   rbp
    45ec:	mov    rbp,rsp
    45ef:	mov    rsi,QWORD PTR [rdx]
    45f2:	mov    r10,QWORD PTR [rdx+0x8]
    45f6:	mov    rcx,QWORD PTR [rdx+0x10]
    45fa:	mov    r8,QWORD PTR [rdx+0x18]
    45fe:	mov    r9,QWORD PTR [rdx+0x20]
    4602:	sar    r9,1
    4605:	mov    rdx,r10
    4608:	call   460d <botlish_entry_43+0x22>
			4609: R_X86_64_PLT32	botlish_fn_43-0x4 ; row_fill<HashTable, List[str], List[str], int, int>
    460d:	mov    rsp,rbp
    4610:	pop    rbp
    4611:	ret

0000000000004612 <botlish_fn_44: row_table<List[str], int, List[str], bool>>:
    4612:	push   rbp
    4613:	mov    rbp,rsp
    4616:	sub    rsp,0x50
    461a:	mov    QWORD PTR [rsp+0x20],rbx
    461f:	mov    QWORD PTR [rsp+0x28],r12
    4624:	mov    QWORD PTR [rsp+0x30],r13
    4629:	mov    QWORD PTR [rsp+0x38],r14
    462e:	mov    QWORD PTR [rsp+0x40],r15
    4633:	mov    r12,rdi
    4636:	mov    QWORD PTR [rsp],rsi
    463a:	mov    r15,rsi
    463d:	mov    QWORD PTR [rsp+0x8],rdx
    4642:	mov    QWORD PTR [rsp+0x10],rcx
    4647:	mov    r13,rcx
    464a:	mov    QWORD PTR [rsp+0x18],r8
    464f:	mov    rsi,r8
    4652:	mov    rdi,r12
    4655:	call   465a <botlish_fn_44+0x48>
			4656: R_X86_64_PLT32	botlish_fn_42-0x4 ; row_new<bool, int>
    465a:	test   rax,rax
    465d:	je     46a7 <botlish_fn_44+0x95>
    4663:	mov    QWORD PTR [rsp+0x8],rax
    4668:	mov    r14,rax
    466b:	mov    ebx,0x1
    4670:	mov    QWORD PTR [rsp+0x18],0x1
    4679:	mov    rsi,r13
    467c:	mov    rdi,r12
    467f:	call   4684 <botlish_fn_44+0x72>
			4680: R_X86_64_PLT32	rt_list_len-0x4
    4684:	mov    r9,rax
    4687:	sar    r9,1
    468a:	mov    rcx,r13
    468d:	mov    rdx,r15
    4690:	mov    rsi,r14
    4693:	mov    rdi,r12
    4696:	mov    r8,rbx
    4699:	call   469e <botlish_fn_44+0x8c>
			469a: R_X86_64_PLT32	botlish_fn_43-0x4 ; row_fill<HashTable, List[str], List[str], int, int>
    469e:	test   rax,rax
    46a1:	jne    46cc <botlish_fn_44+0xba>
    46a7:	xor    rax,rax
    46aa:	mov    rbx,QWORD PTR [rsp+0x20]
    46af:	mov    r12,QWORD PTR [rsp+0x28]
    46b4:	mov    r13,QWORD PTR [rsp+0x30]
    46b9:	mov    r14,QWORD PTR [rsp+0x38]
    46be:	mov    r15,QWORD PTR [rsp+0x40]
    46c3:	add    rsp,0x50
    46c7:	mov    rsp,rbp
    46ca:	pop    rbp
    46cb:	ret
    46cc:	mov    rbx,QWORD PTR [rsp+0x20]
    46d1:	mov    r12,QWORD PTR [rsp+0x28]
    46d6:	mov    r13,QWORD PTR [rsp+0x30]
    46db:	mov    r14,QWORD PTR [rsp+0x38]
    46e0:	mov    r15,QWORD PTR [rsp+0x40]
    46e5:	add    rsp,0x50
    46e9:	mov    rsp,rbp
    46ec:	pop    rbp
    46ed:	ret

00000000000046ee <botlish_entry_44: row_table<List[str], int, List[str], bool>>:
    46ee:	push   rbp
    46ef:	mov    rbp,rsp
    46f2:	mov    rsi,QWORD PTR [rdx]
    46f5:	mov    r9,QWORD PTR [rdx+0x8]
    46f9:	mov    rcx,QWORD PTR [rdx+0x10]
    46fd:	mov    r8,QWORD PTR [rdx+0x18]
    4701:	mov    rdx,r9
    4704:	call   4709 <botlish_entry_44+0x1b>
			4705: R_X86_64_PLT32	botlish_fn_44-0x4 ; row_table<List[str], int, List[str], bool>
    4709:	mov    rsp,rbp
    470c:	pop    rbp
    470d:	ret

000000000000470e <botlish_fn_45: build_rows<List[List[str]], int, List[str], int, mutarray, int, bool>>:
    470e:	push   rbp
    470f:	mov    rbp,rsp
    4712:	sub    rsp,0x90
    4719:	mov    QWORD PTR [rsp+0x60],rbx
    471e:	mov    QWORD PTR [rsp+0x68],r12
    4723:	mov    QWORD PTR [rsp+0x70],r13
    4728:	mov    QWORD PTR [rsp+0x78],r14
    472d:	mov    QWORD PTR [rsp+0x80],r15
    4735:	mov    r13,r8
    4738:	mov    QWORD PTR [rsp+0x38],rdi
    473d:	mov    rdi,QWORD PTR [rbp+0x10]
    4741:	mov    r15,QWORD PTR [rbp+0x18]
    4745:	mov    QWORD PTR [rsp+0x28],0x0
    474e:	mov    QWORD PTR [rsp+0x30],0x0
    4757:	mov    QWORD PTR [rsp],rsi
    475b:	mov    QWORD PTR [rsp+0x8],rcx
    4760:	mov    r14,rcx
    4763:	mov    QWORD PTR [rsp+0x10],r9
    4768:	mov    QWORD PTR [rsp+0x18],rdi
    476d:	mov    QWORD PTR [rsp+0x20],r15
    4772:	sar    rdx,1
    4775:	mov    r12,rdx
    4778:	mov    rbx,rsi
    477b:	mov    QWORD PTR [rsp+0x40],r9
    4780:	mov    QWORD PTR [rsp+0x48],rdi
    4785:	mov    rsi,rbx
    4788:	mov    rdi,QWORD PTR [rsp+0x38]
    478d:	call   4792 <botlish_fn_45+0x84>
			478e: R_X86_64_PLT32	rt_list_len-0x4
    4792:	sar    rax,1
    4795:	cmp    r12,rax
    4798:	jge    48c3 <botlish_fn_45+0x1b5>
    479e:	mov    rax,r13
    47a1:	or     rax,0x1
    47a5:	mov    QWORD PTR [rsp+0x28],rax
    47aa:	mov    rcx,QWORD PTR [rbx+0x8]
    47ae:	mov    rax,r12
    47b1:	shl    rax,1
    47b4:	or     rax,0x1
    47b8:	sar    rax,1
    47bb:	cmp    rax,rcx
    47be:	jb     47ec <botlish_fn_45+0xde>
    47c4:	mov    rdx,r12
    47c7:	shl    rdx,1
    47ca:	or     rdx,0x1
    47ce:	mov    rsi,rbx
    47d1:	mov    rdi,QWORD PTR [rsp+0x38]
    47d6:	call   47db <botlish_fn_45+0xcd>
			47d7: R_X86_64_PLT32	rt_list_get-0x4
    47db:	test   rax,rax
    47de:	je     48e0 <botlish_fn_45+0x1d2>
    47e4:	mov    rcx,rax
    47e7:	jmp    47f4 <botlish_fn_45+0xe6>
    47ec:	mov    rcx,QWORD PTR [rbx+0x10]
    47f0:	mov    rcx,QWORD PTR [rcx+rax*8]
    47f4:	mov    QWORD PTR [rsp+0x30],rcx
    47f9:	mov    rdx,r13
    47fc:	or     rdx,0x1
    4800:	mov    rsi,r14
    4803:	mov    rdi,QWORD PTR [rsp+0x38]
    4808:	mov    r8,r15
    480b:	call   4810 <botlish_fn_45+0x102>
			480c: R_X86_64_PLT32	botlish_fn_44-0x4 ; row_table<List[str], int, List[str], bool>
    4810:	test   rax,rax
    4813:	je     48e0 <botlish_fn_45+0x1d2>
    4819:	mov    QWORD PTR [rsp+0x28],rax
    481e:	mov    rcx,rax
    4821:	mov    rsi,QWORD PTR [rsp+0x40]
    4826:	mov    rdx,QWORD PTR [rsp+0x48]
    482b:	mov    rdi,QWORD PTR [rsp+0x38]
    4830:	call   4835 <botlish_fn_45+0x127>
			4831: R_X86_64_PLT32	botlish_fn_10-0x4 ; geo_append<mutarray, int, HashTable>
    4835:	test   rax,rax
    4838:	je     48e0 <botlish_fn_45+0x1d2>
    483e:	mov    QWORD PTR [rsp+0x10],rax
    4843:	mov    QWORD PTR [rsp+0x50],rax
    4848:	mov    QWORD PTR [rsp+0x28],0x3
    4851:	mov    rsi,QWORD PTR [rsp+0x48]
    4856:	test   rsi,0x1
    485d:	je     487c <botlish_fn_45+0x16e>
    4863:	mov    rsi,QWORD PTR [rsp+0x48]
    4868:	mov    rax,rsi
    486b:	add    rax,0x2
    486f:	seto   r10b
    4873:	test   r10b,r10b
    4876:	je     4890 <botlish_fn_45+0x182>
    487c:	mov    edx,0x3
    4881:	mov    rsi,QWORD PTR [rsp+0x48]
    4886:	mov    rdi,QWORD PTR [rsp+0x38]
    488b:	call   4890 <botlish_fn_45+0x182>
			488c: R_X86_64_PLT32	rt_int_add-0x4
    4890:	mov    QWORD PTR [rsp],rbx
    4894:	mov    QWORD PTR [rsp+0x8],r14
    4899:	mov    rcx,QWORD PTR [rsp+0x50]
    489e:	mov    QWORD PTR [rsp+0x10],rcx
    48a3:	mov    QWORD PTR [rsp+0x18],rax
    48a8:	mov    QWORD PTR [rsp+0x20],r15
    48ad:	add    r12,0x1
    48b4:	mov    QWORD PTR [rsp+0x40],rcx
    48b9:	mov    QWORD PTR [rsp+0x48],rax
    48be:	jmp    4785 <botlish_fn_45+0x77>
    48c3:	mov    rdx,QWORD PTR [rsp+0x48]
    48c8:	mov    rsi,QWORD PTR [rsp+0x40]
    48cd:	mov    rdi,QWORD PTR [rsp+0x38]
    48d2:	call   48d7 <botlish_fn_45+0x1c9>
			48d3: R_X86_64_PLT32	botlish_fn_11-0x4 ; geo_finish<mutarray, int>
    48d7:	test   rax,rax
    48da:	jne    490b <botlish_fn_45+0x1fd>
    48e0:	xor    rax,rax
    48e3:	mov    rbx,QWORD PTR [rsp+0x60]
    48e8:	mov    r12,QWORD PTR [rsp+0x68]
    48ed:	mov    r13,QWORD PTR [rsp+0x70]
    48f2:	mov    r14,QWORD PTR [rsp+0x78]
    48f7:	mov    r15,QWORD PTR [rsp+0x80]
    48ff:	add    rsp,0x90
    4906:	mov    rsp,rbp
    4909:	pop    rbp
    490a:	ret
    490b:	mov    rbx,QWORD PTR [rsp+0x60]
    4910:	mov    r12,QWORD PTR [rsp+0x68]
    4915:	mov    r13,QWORD PTR [rsp+0x70]
    491a:	mov    r14,QWORD PTR [rsp+0x78]
    491f:	mov    r15,QWORD PTR [rsp+0x80]
    4927:	add    rsp,0x90
    492e:	mov    rsp,rbp
    4931:	pop    rbp
    4932:	ret

0000000000004933 <botlish_entry_45: build_rows<List[List[str]], int, List[str], int, mutarray, int, bool>>:
    4933:	push   rbp
    4934:	mov    rbp,rsp
    4937:	sub    rsp,0x10
    493b:	mov    rsi,QWORD PTR [rdx]
    493e:	mov    r10,QWORD PTR [rdx+0x8]
    4942:	mov    rcx,QWORD PTR [rdx+0x10]
    4946:	mov    r8,QWORD PTR [rdx+0x18]
    494a:	mov    r9,QWORD PTR [rdx+0x20]
    494e:	mov    r11,QWORD PTR [rdx+0x28]
    4952:	mov    rax,QWORD PTR [rdx+0x30]
    4956:	mov    QWORD PTR [rsp],r11
    495a:	mov    QWORD PTR [rsp+0x8],rax
    495f:	mov    rdx,r10
    4962:	call   4967 <botlish_entry_45+0x34>
			4963: R_X86_64_PLT32	botlish_fn_45-0x4 ; build_rows<List[List[str]], int, List[str], int, mutarray, int, bool>
    4967:	add    rsp,0x10
    496b:	mov    rsp,rbp
    496e:	pop    rbp
    496f:	ret

0000000000004970 <botlish_fn_46: csv_records_generic<str, bool>>:
    4970:	push   rbp
    4971:	mov    rbp,rsp
    4974:	sub    rsp,0x80
    497b:	mov    QWORD PTR [rsp+0x50],rbx
    4980:	mov    QWORD PTR [rsp+0x58],r12
    4985:	mov    QWORD PTR [rsp+0x60],r13
    498a:	mov    QWORD PTR [rsp+0x68],r14
    498f:	mov    QWORD PTR [rsp+0x70],r15
    4994:	mov    r12,rdi
    4997:	mov    QWORD PTR [rsp+0x20],0x0
    49a0:	mov    QWORD PTR [rsp+0x28],0x0
    49a9:	mov    QWORD PTR [rsp+0x30],0x0
    49b2:	mov    QWORD PTR [rsp+0x38],0x0
    49bb:	mov    QWORD PTR [rsp+0x40],0x0
    49c4:	mov    QWORD PTR [rsp+0x10],rsi
    49c9:	mov    QWORD PTR [rsp+0x18],rdx
    49ce:	mov    r13,rdx
    49d1:	mov    rdi,r12
    49d4:	call   49d9 <botlish_fn_46+0x69>
			49d5: R_X86_64_PLT32	botlish_fn_20-0x4 ; csv_parse<str>
    49d9:	mov    rcx,rax
    49dc:	mov    r14,rax
    49df:	test   rax,rcx
    49e2:	je     4afc <botlish_fn_46+0x18c>
    49e8:	mov    rax,r14
    49eb:	mov    QWORD PTR [rsp+0x10],rax
    49f0:	mov    rsi,r14
    49f3:	mov    rdi,r12
    49f6:	call   49fb <botlish_fn_46+0x8b>
			49f7: R_X86_64_PLT32	rt_list_len-0x4
    49fb:	sar    rax,1
    49fe:	cmp    rax,0x1
    4a02:	jle    4ae5 <botlish_fn_46+0x175>
    4a08:	mov    rax,r14
    4a0b:	mov    rax,QWORD PTR [rax+0x10]
    4a0f:	mov    rbx,QWORD PTR [rax]
    4a12:	mov    QWORD PTR [rsp+0x20],rbx
    4a17:	mov    rsi,rbx
    4a1a:	mov    rdi,r12
    4a1d:	call   4a22 <botlish_fn_46+0xb2>
			4a1e: R_X86_64_PLT32	rt_list_len-0x4
    4a22:	mov    r15,rbx
    4a25:	mov    QWORD PTR [rsp+0x28],rax
    4a2a:	mov    QWORD PTR [rsp+0x48],rax
    4a2f:	mov    rax,r14
    4a32:	mov    rcx,QWORD PTR [rax+0x10]
    4a36:	mov    rcx,QWORD PTR [rcx+0x8]
    4a3a:	mov    QWORD PTR [rsp+0x30],rcx
    4a3f:	mov    rbx,r13
    4a42:	mov    rdx,QWORD PTR [rsp+0x48]
    4a47:	mov    rsi,r15
    4a4a:	mov    rdi,r12
    4a4d:	mov    r8,rbx
    4a50:	call   4a55 <botlish_fn_46+0xe5>
			4a51: R_X86_64_PLT32	botlish_fn_44-0x4 ; row_table<List[str], int, List[str], bool>
    4a55:	test   rax,rax
    4a58:	je     4afc <botlish_fn_46+0x18c>
    4a5e:	mov    QWORD PTR [rsp+0x30],rax
    4a63:	mov    rsi,rax
    4a66:	mov    QWORD PTR [rsp+0x38],0x5
    4a6f:	mov    rdi,r12
    4a72:	call   4a77 <botlish_fn_46+0x107>
			4a73: R_X86_64_PLT32	botlish_fn_3-0x4 ; geo_new<HashTable>
    4a77:	test   rax,rax
    4a7a:	je     4afc <botlish_fn_46+0x18c>
    4a80:	mov    QWORD PTR [rsp+0x30],rax
    4a85:	mov    r9,rax
    4a88:	mov    eax,0x3
    4a8d:	mov    QWORD PTR [rsp+0x40],0x3
    4a96:	mov    edx,0x5
    4a9b:	mov    QWORD PTR [rsp],rax
    4a9f:	mov    QWORD PTR [rsp+0x8],rbx
    4aa4:	mov    rcx,r15
    4aa7:	mov    rsi,r14
    4aaa:	mov    rdi,r12
    4aad:	mov    r8,QWORD PTR [rsp+0x48]
    4ab2:	call   4ab7 <botlish_fn_46+0x147>
			4ab3: R_X86_64_PLT32	botlish_fn_45-0x4 ; build_rows<List[List[str]], int, List[str], int, mutarray, int, bool>
    4ab7:	test   rax,rax
    4aba:	je     4afc <botlish_fn_46+0x18c>
    4ac0:	mov    rbx,QWORD PTR [rsp+0x50]
    4ac5:	mov    r12,QWORD PTR [rsp+0x58]
    4aca:	mov    r13,QWORD PTR [rsp+0x60]
    4acf:	mov    r14,QWORD PTR [rsp+0x68]
    4ad4:	mov    r15,QWORD PTR [rsp+0x70]
    4ad9:	add    rsp,0x80
    4ae0:	mov    rsp,rbp
    4ae3:	pop    rbp
    4ae4:	ret
    4ae5:	xor    rdx,rdx
    4ae8:	mov    rdi,r12
    4aeb:	mov    rsi,rdx
    4aee:	call   4af3 <botlish_fn_46+0x183>
			4aef: R_X86_64_PLT32	rt_list_new-0x4
    4af3:	test   rax,rax
    4af6:	jne    4b24 <botlish_fn_46+0x1b4>
    4afc:	xor    rax,rax
    4aff:	mov    rbx,QWORD PTR [rsp+0x50]
    4b04:	mov    r12,QWORD PTR [rsp+0x58]
    4b09:	mov    r13,QWORD PTR [rsp+0x60]
    4b0e:	mov    r14,QWORD PTR [rsp+0x68]
    4b13:	mov    r15,QWORD PTR [rsp+0x70]
    4b18:	add    rsp,0x80
    4b1f:	mov    rsp,rbp
    4b22:	pop    rbp
    4b23:	ret
    4b24:	mov    rbx,QWORD PTR [rsp+0x50]
    4b29:	mov    r12,QWORD PTR [rsp+0x58]
    4b2e:	mov    r13,QWORD PTR [rsp+0x60]
    4b33:	mov    r14,QWORD PTR [rsp+0x68]
    4b38:	mov    r15,QWORD PTR [rsp+0x70]
    4b3d:	add    rsp,0x80
    4b44:	mov    rsp,rbp
    4b47:	pop    rbp
    4b48:	ret

0000000000004b49 <botlish_entry_46: csv_records_generic<str, bool>>:
    4b49:	push   rbp
    4b4a:	mov    rbp,rsp
    4b4d:	mov    rsi,QWORD PTR [rdx]
    4b50:	mov    rdx,QWORD PTR [rdx+0x8]
    4b54:	call   4b59 <botlish_entry_46+0x10>
			4b55: R_X86_64_PLT32	botlish_fn_46-0x4 ; csv_records_generic<str, bool>
    4b59:	mov    rsp,rbp
    4b5c:	pop    rbp
    4b5d:	ret

0000000000004b5e <botlish_fn_47: csv_records<str>>:
    4b5e:	push   rbp
    4b5f:	mov    rbp,rsp
    4b62:	sub    rsp,0x10
    4b66:	mov    QWORD PTR [rsp],rsi
    4b6a:	mov    edx,0x2
    4b6f:	mov    QWORD PTR [rsp+0x8],0x2
    4b78:	call   4b7d <botlish_fn_47+0x1f>
			4b79: R_X86_64_PLT32	botlish_fn_46-0x4 ; csv_records_generic<str, bool>
    4b7d:	test   rax,rax
    4b80:	jne    4b92 <botlish_fn_47+0x34>
    4b86:	xor    rax,rax
    4b89:	add    rsp,0x10
    4b8d:	mov    rsp,rbp
    4b90:	pop    rbp
    4b91:	ret
    4b92:	add    rsp,0x10
    4b96:	mov    rsp,rbp
    4b99:	pop    rbp
    4b9a:	ret

0000000000004b9b <botlish_entry_47: csv_records<str>>:
    4b9b:	push   rbp
    4b9c:	mov    rbp,rsp
    4b9f:	mov    rsi,QWORD PTR [rdx]
    4ba2:	call   4ba7 <botlish_entry_47+0xc>
			4ba3: R_X86_64_PLT32	botlish_fn_47-0x4 ; csv_records<str>
    4ba7:	mov    rsp,rbp
    4baa:	pop    rbp
    4bab:	ret

0000000000004bac <botlish_fn_48: csv_records_presized<str>>:
    4bac:	push   rbp
    4bad:	mov    rbp,rsp
    4bb0:	sub    rsp,0x10
    4bb4:	mov    QWORD PTR [rsp],rsi
    4bb8:	mov    edx,0x6
    4bbd:	mov    QWORD PTR [rsp+0x8],0x6
    4bc6:	call   4bcb <botlish_fn_48+0x1f>
			4bc7: R_X86_64_PLT32	botlish_fn_46-0x4 ; csv_records_generic<str, bool>
    4bcb:	test   rax,rax
    4bce:	jne    4be0 <botlish_fn_48+0x34>
    4bd4:	xor    rax,rax
    4bd7:	add    rsp,0x10
    4bdb:	mov    rsp,rbp
    4bde:	pop    rbp
    4bdf:	ret
    4be0:	add    rsp,0x10
    4be4:	mov    rsp,rbp
    4be7:	pop    rbp
    4be8:	ret

0000000000004be9 <botlish_entry_48: csv_records_presized<str>>:
    4be9:	push   rbp
    4bea:	mov    rbp,rsp
    4bed:	mov    rsi,QWORD PTR [rdx]
    4bf0:	call   4bf5 <botlish_entry_48+0xc>
			4bf1: R_X86_64_PLT32	botlish_fn_48-0x4 ; csv_records_presized<str>
    4bf5:	mov    rsp,rbp
    4bf8:	pop    rbp
    4bf9:	ret
    4bfa:	add    BYTE PTR [rax],al
    4bfc:	add    BYTE PTR [rax],al
	...

0000000000004c00 <botlish_fn_49: sample_checks<generic>>:
    4c00:	push   rbp
    4c01:	mov    rbp,rsp
    4c04:	sub    rsp,0xc0
    4c0b:	mov    QWORD PTR [rsp+0x90],rbx
    4c13:	mov    QWORD PTR [rsp+0x98],r12
    4c1b:	mov    QWORD PTR [rsp+0xa0],r13
    4c23:	mov    QWORD PTR [rsp+0xa8],r14
    4c2b:	mov    QWORD PTR [rsp+0xb0],r15
    4c33:	mov    QWORD PTR [rsp+0x8],0x0
    4c3c:	mov    QWORD PTR [rsp+0x10],0x0
    4c45:	mov    QWORD PTR [rsp+0x18],0x0
    4c4e:	mov    QWORD PTR [rsp+0x20],0x0
    4c57:	mov    QWORD PTR [rsp+0x28],0x0
    4c60:	mov    QWORD PTR [rsp+0x30],0x0
    4c69:	mov    rax,QWORD PTR [rdi+0x10]
    4c6d:	mov    r13,rdi
    4c70:	mov    rsi,QWORD PTR [rax+0x20]
    4c74:	mov    QWORD PTR [rsp],rsi
    4c78:	call   4c7d <botlish_fn_49+0x7d>
			4c79: R_X86_64_PLT32	botlish_fn_47-0x4 ; csv_records<str>
    4c7d:	mov    rsi,rax
    4c80:	mov    r12,rax
    4c83:	test   rax,rsi
    4c86:	je     4fd1 <botlish_fn_49+0x3d1>
    4c8c:	mov    rax,r12
    4c8f:	mov    QWORD PTR [rsp],rax
    4c93:	mov    rdi,r13
    4c96:	mov    rax,QWORD PTR [rdi+0x10]
    4c9a:	mov    rsi,QWORD PTR [rax+0x20]
    4c9e:	mov    QWORD PTR [rsp+0x8],rsi
    4ca3:	call   4ca8 <botlish_fn_49+0xa8>
			4ca4: R_X86_64_PLT32	botlish_fn_48-0x4 ; csv_records_presized<str>
    4ca8:	mov    rbx,rax
    4cab:	test   rbx,rbx
    4cae:	je     4fd1 <botlish_fn_49+0x3d1>
    4cb4:	mov    rax,r12
    4cb7:	mov    rax,QWORD PTR [rax+0x8]
    4cbb:	test   rax,rax
    4cbe:	jne    4ce5 <botlish_fn_49+0xe5>
    4cc4:	mov    edx,0x1
    4cc9:	mov    rsi,r12
    4ccc:	mov    rdi,r13
    4ccf:	call   4cd4 <botlish_fn_49+0xd4>
			4cd0: R_X86_64_PLT32	rt_list_get-0x4
    4cd4:	test   rax,rax
    4cd7:	je     4fd1 <botlish_fn_49+0x3d1>
    4cdd:	mov    r14,rax
    4ce0:	jmp    4cf0 <botlish_fn_49+0xf0>
    4ce5:	mov    rax,QWORD PTR [r12+0x10]
    4cea:	mov    rsi,QWORD PTR [rax]
    4ced:	mov    r14,rsi
    4cf0:	mov    rax,QWORD PTR [r12+0x8]
    4cf5:	cmp    rax,0x1
    4cf9:	ja     4d20 <botlish_fn_49+0x120>
    4cff:	mov    edx,0x3
    4d04:	mov    rsi,r12
    4d07:	mov    rdi,r13
    4d0a:	call   4d0f <botlish_fn_49+0x10f>
			4d0b: R_X86_64_PLT32	rt_list_get-0x4
    4d0f:	test   rax,rax
    4d12:	je     4fd1 <botlish_fn_49+0x3d1>
    4d18:	mov    r15,rax
    4d1b:	jmp    4d2c <botlish_fn_49+0x12c>
    4d20:	mov    rax,QWORD PTR [r12+0x10]
    4d25:	mov    rsi,QWORD PTR [rax+0x8]
    4d29:	mov    r15,rsi
    4d2c:	mov    rax,QWORD PTR [rbx+0x8]
    4d30:	mov    rsi,rbx
    4d33:	test   rax,rax
    4d36:	jne    4d5f <botlish_fn_49+0x15f>
    4d3c:	mov    edx,0x1
    4d41:	mov    rdi,r13
    4d44:	call   4d49 <botlish_fn_49+0x149>
			4d45: R_X86_64_PLT32	rt_list_get-0x4
    4d49:	test   rax,rax
    4d4c:	je     4fd1 <botlish_fn_49+0x3d1>
    4d52:	mov    rdi,r13
    4d55:	mov    QWORD PTR [rsp+0x70],rax
    4d5a:	jmp    4d6e <botlish_fn_49+0x16e>
    4d5f:	mov    rax,QWORD PTR [rsi+0x10]
    4d63:	mov    rsi,QWORD PTR [rax]
    4d66:	mov    QWORD PTR [rsp+0x70],rsi
    4d6b:	mov    rdi,r13
    4d6e:	mov    rdi,r13
    4d71:	mov    rax,QWORD PTR [rdi+0x10]
    4d75:	mov    rdx,QWORD PTR [rax+0x28]
    4d79:	mov    rsi,r14
    4d7c:	call   4d81 <botlish_fn_49+0x181>
			4d7d: R_X86_64_PLT32	botlish_fn_33-0x4 ; ht_get<HashTable, str>
    4d81:	test   rax,rax
    4d84:	mov    rbx,rax
    4d87:	je     4fd1 <botlish_fn_49+0x3d1>
    4d8d:	mov    rdi,r13
    4d90:	mov    rax,QWORD PTR [rdi+0x10]
    4d94:	mov    rdx,QWORD PTR [rax+0x28]
    4d98:	mov    rsi,QWORD PTR [rsp+0x70]
    4d9d:	call   4da2 <botlish_fn_49+0x1a2>
			4d9e: R_X86_64_PLT32	botlish_fn_33-0x4 ; ht_get<HashTable, str>
    4da2:	test   rax,rax
    4da5:	je     4fd1 <botlish_fn_49+0x3d1>
    4dab:	mov    rsi,rbx
    4dae:	mov    rcx,rsi
    4db1:	and    rcx,rax
    4db4:	mov    rdx,rax
    4db7:	test   rcx,0x1
    4dbe:	jne    4ddd <botlish_fn_49+0x1dd>
    4dc4:	mov    rsi,rbx
    4dc7:	mov    rdi,r13
    4dca:	call   4dcf <botlish_fn_49+0x1cf>
			4dcb: R_X86_64_PLT32	rt_value_eq-0x4
    4dcf:	test   rax,rax
    4dd2:	je     4fd1 <botlish_fn_49+0x3d1>
    4dd8:	jmp    4df0 <botlish_fn_49+0x1f0>
    4ddd:	mov    rsi,rbx
    4de0:	mov    eax,0x2
    4de5:	cmp    rsi,rdx
    4de8:	cmove  rax,QWORD PTR [rip+0x250]        # 5040 <botlish_fn_49+0x440>
    4df0:	mov    ebx,0x6
    4df5:	cmp    rax,0x6
    4df9:	je     4e15 <botlish_fn_49+0x215>
    4dff:	mov    ebx,0x2
    4e04:	mov    QWORD PTR [rsp+0x8],0x2
    4e0d:	mov    rsi,r12
    4e10:	jmp    4eb2 <botlish_fn_49+0x2b2>
    4e15:	mov    rsi,r14
    4e18:	mov    rdi,r13
    4e1b:	call   4e20 <botlish_fn_49+0x220>
			4e1c: R_X86_64_PLT32	botlish_fn_26-0x4 ; ht_size<HashTable>
    4e20:	test   rax,rax
    4e23:	mov    QWORD PTR [rsp+0x80],rax
    4e2b:	je     4fd1 <botlish_fn_49+0x3d1>
    4e31:	mov    rsi,QWORD PTR [rsp+0x70]
    4e36:	mov    rdi,r13
    4e39:	call   4e3e <botlish_fn_49+0x23e>
			4e3a: R_X86_64_PLT32	botlish_fn_26-0x4 ; ht_size<HashTable>
    4e3e:	test   rax,rax
    4e41:	je     4fd1 <botlish_fn_49+0x3d1>
    4e47:	mov    rcx,QWORD PTR [rsp+0x80]
    4e4f:	mov    r8,rcx
    4e52:	and    r8,rax
    4e55:	mov    rdx,rax
    4e58:	test   r8,0x1
    4e5f:	jne    4e83 <botlish_fn_49+0x283>
    4e65:	mov    rsi,QWORD PTR [rsp+0x80]
    4e6d:	mov    rdi,r13
    4e70:	call   4e75 <botlish_fn_49+0x275>
			4e71: R_X86_64_PLT32	rt_value_eq-0x4
    4e75:	test   rax,rax
    4e78:	je     4fd1 <botlish_fn_49+0x3d1>
    4e7e:	jmp    4e9b <botlish_fn_49+0x29b>
    4e83:	mov    rsi,QWORD PTR [rsp+0x80]
    4e8b:	mov    eax,0x2
    4e90:	cmp    rsi,rdx
    4e93:	cmove  rax,QWORD PTR [rip+0x1a5]        # 5040 <botlish_fn_49+0x440>
    4e9b:	cmp    rax,0x6
    4e9f:	je     4eaa <botlish_fn_49+0x2aa>
    4ea5:	mov    ebx,0x2
    4eaa:	mov    QWORD PTR [rsp+0x8],rbx
    4eaf:	mov    rsi,r12
    4eb2:	mov    rdi,r13
    4eb5:	call   4eba <botlish_fn_49+0x2ba>
			4eb6: R_X86_64_PLT32	rt_list_len-0x4
    4eba:	mov    QWORD PTR [rsp],rax
    4ebe:	mov    rdi,r13
    4ec1:	mov    r12,rax
    4ec4:	mov    rax,QWORD PTR [rdi+0x10]
    4ec8:	mov    rdx,QWORD PTR [rax+0x28]
    4ecc:	mov    rsi,r14
    4ecf:	call   4ed4 <botlish_fn_49+0x2d4>
			4ed0: R_X86_64_PLT32	botlish_fn_33-0x4 ; ht_get<HashTable, str>
    4ed4:	test   rax,rax
    4ed7:	je     4fd1 <botlish_fn_49+0x3d1>
    4edd:	mov    QWORD PTR [rsp+0x10],rax
    4ee2:	mov    rdi,r13
    4ee5:	mov    QWORD PTR [rsp+0x80],rax
    4eed:	mov    rax,QWORD PTR [rdi+0x10]
    4ef1:	mov    rdx,QWORD PTR [rax+0x30]
    4ef5:	mov    rsi,r14
    4ef8:	call   4efd <botlish_fn_49+0x2fd>
			4ef9: R_X86_64_PLT32	botlish_fn_33-0x4 ; ht_get<HashTable, str>
    4efd:	test   rax,rax
    4f00:	je     4fd1 <botlish_fn_49+0x3d1>
    4f06:	mov    QWORD PTR [rsp+0x18],rax
    4f0b:	mov    rdi,r13
    4f0e:	mov    QWORD PTR [rsp+0x78],rax
    4f13:	mov    rax,QWORD PTR [rdi+0x10]
    4f17:	mov    rdx,QWORD PTR [rax+0x38]
    4f1b:	mov    rsi,r14
    4f1e:	call   4f23 <botlish_fn_49+0x323>
			4f1f: R_X86_64_PLT32	botlish_fn_33-0x4 ; ht_get<HashTable, str>
    4f23:	test   rax,rax
    4f26:	je     4fd1 <botlish_fn_49+0x3d1>
    4f2c:	mov    QWORD PTR [rsp+0x20],rax
    4f31:	mov    rdi,r13
    4f34:	mov    r14,rax
    4f37:	mov    rax,QWORD PTR [rdi+0x10]
    4f3b:	mov    rdx,QWORD PTR [rax+0x28]
    4f3f:	mov    rsi,r15
    4f42:	call   4f47 <botlish_fn_49+0x347>
			4f43: R_X86_64_PLT32	botlish_fn_33-0x4 ; ht_get<HashTable, str>
    4f47:	test   rax,rax
    4f4a:	je     4fd1 <botlish_fn_49+0x3d1>
    4f50:	mov    QWORD PTR [rsp+0x28],rax
    4f55:	mov    rdi,r13
    4f58:	mov    QWORD PTR [rsp+0x70],rax
    4f5d:	mov    rax,QWORD PTR [rdi+0x10]
    4f61:	mov    rdx,QWORD PTR [rax+0x38]
    4f65:	mov    rsi,r15
    4f68:	call   4f6d <botlish_fn_49+0x36d>
			4f69: R_X86_64_PLT32	botlish_fn_33-0x4 ; ht_get<HashTable, str>
    4f6d:	test   rax,rax
    4f70:	je     4fd1 <botlish_fn_49+0x3d1>
    4f76:	mov    QWORD PTR [rsp+0x30],rax
    4f7b:	lea    rdx,[rsp+0x38]
    4f80:	mov    rcx,r12
    4f83:	mov    QWORD PTR [rsp+0x38],rcx
    4f88:	mov    rsi,QWORD PTR [rsp+0x80]
    4f90:	mov    QWORD PTR [rsp+0x40],rsi
    4f95:	mov    rdi,QWORD PTR [rsp+0x78]
    4f9a:	mov    QWORD PTR [rsp+0x48],rdi
    4f9f:	mov    r10,r14
    4fa2:	mov    QWORD PTR [rsp+0x50],r10
    4fa7:	mov    rcx,QWORD PTR [rsp+0x70]
    4fac:	mov    QWORD PTR [rsp+0x58],rcx
    4fb1:	mov    QWORD PTR [rsp+0x60],rax
    4fb6:	mov    QWORD PTR [rsp+0x68],rbx
    4fbb:	mov    esi,0x7
    4fc0:	mov    rdi,r13
    4fc3:	call   4fc8 <botlish_fn_49+0x3c8>
			4fc4: R_X86_64_PLT32	rt_list_new-0x4
    4fc8:	test   rax,rax
    4fcb:	jne    5008 <botlish_fn_49+0x408>
    4fd1:	xor    rax,rax
    4fd4:	mov    rbx,QWORD PTR [rsp+0x90]
    4fdc:	mov    r12,QWORD PTR [rsp+0x98]
    4fe4:	mov    r13,QWORD PTR [rsp+0xa0]
    4fec:	mov    r14,QWORD PTR [rsp+0xa8]
    4ff4:	mov    r15,QWORD PTR [rsp+0xb0]
    4ffc:	add    rsp,0xc0
    5003:	mov    rsp,rbp
    5006:	pop    rbp
    5007:	ret
    5008:	mov    rbx,QWORD PTR [rsp+0x90]
    5010:	mov    r12,QWORD PTR [rsp+0x98]
    5018:	mov    r13,QWORD PTR [rsp+0xa0]
    5020:	mov    r14,QWORD PTR [rsp+0xa8]
    5028:	mov    r15,QWORD PTR [rsp+0xb0]
    5030:	add    rsp,0xc0
    5037:	mov    rsp,rbp
    503a:	pop    rbp
    503b:	ret
    503c:	add    BYTE PTR [rax],al
    503e:	add    BYTE PTR [rax],al
    5040:	(bad)
    5041:	add    BYTE PTR [rax],al
    5043:	add    BYTE PTR [rax],al
    5045:	add    BYTE PTR [rax],al
	...

0000000000005048 <botlish_entry_49: sample_checks<generic>>:
    5048:	push   rbp
    5049:	mov    rbp,rsp
    504c:	call   5051 <botlish_entry_49+0x9>
			504d: R_X86_64_PLT32	botlish_fn_49-0x4 ; sample_checks<generic>
    5051:	mov    rsp,rbp
    5054:	pop    rbp
    5055:	ret

0000000000005056 <botlish_fn_50: sample<generic>>:
    5056:	push   rbp
    5057:	mov    rbp,rsp
    505a:	sub    rsp,0x10
    505e:	mov    QWORD PTR [rsp],rbx
    5062:	mov    rbx,rdi
    5065:	mov    rdi,rbx
    5068:	call   506d <botlish_fn_50+0x17>
			5069: R_X86_64_PLT32	botlish_fn_49-0x4 ; sample_checks<generic>
    506d:	test   rax,rax
    5070:	jne    5129 <botlish_fn_50+0xd3>
    5076:	mov    rdi,rbx
    5079:	call   507e <botlish_fn_50+0x28>
			507a: R_X86_64_PLT32	rt_declared_error-0x4
    507e:	cmp    rax,0x40000001
    5084:	je     50fa <botlish_fn_50+0xa4>
    508a:	mov    rdi,rbx
    508d:	call   5092 <botlish_fn_50+0x3c>
			508e: R_X86_64_PLT32	rt_declared_error-0x4
    5092:	cmp    rax,0x40000002
    5098:	je     50d6 <botlish_fn_50+0x80>
    509e:	mov    rdi,rbx
    50a1:	call   50a6 <botlish_fn_50+0x50>
			50a2: R_X86_64_PLT32	rt_declared_error-0x4
    50a6:	cmp    rax,0x40000003
    50ac:	jne    5119 <botlish_fn_50+0xc3>
    50b2:	mov    rdi,rbx
    50b5:	call   50ba <botlish_fn_50+0x64>
			50b6: R_X86_64_PLT32	rt_clear_declared_error-0x4
    50ba:	xor    rdx,rdx
    50bd:	mov    rdi,rbx
    50c0:	mov    rsi,rdx
    50c3:	call   50c8 <botlish_fn_50+0x72>
			50c4: R_X86_64_PLT32	rt_list_new-0x4
    50c8:	test   rax,rax
    50cb:	je     5119 <botlish_fn_50+0xc3>
    50d1:	jmp    5129 <botlish_fn_50+0xd3>
    50d6:	mov    rdi,rbx
    50d9:	call   50de <botlish_fn_50+0x88>
			50da: R_X86_64_PLT32	rt_clear_declared_error-0x4
    50de:	xor    rdx,rdx
    50e1:	mov    rdi,rbx
    50e4:	mov    rsi,rdx
    50e7:	call   50ec <botlish_fn_50+0x96>
			50e8: R_X86_64_PLT32	rt_list_new-0x4
    50ec:	test   rax,rax
    50ef:	je     5119 <botlish_fn_50+0xc3>
    50f5:	jmp    5129 <botlish_fn_50+0xd3>
    50fa:	mov    rdi,rbx
    50fd:	call   5102 <botlish_fn_50+0xac>
			50fe: R_X86_64_PLT32	rt_clear_declared_error-0x4
    5102:	xor    rdx,rdx
    5105:	mov    rdi,rbx
    5108:	mov    rsi,rdx
    510b:	call   5110 <botlish_fn_50+0xba>
			510c: R_X86_64_PLT32	rt_list_new-0x4
    5110:	test   rax,rax
    5113:	jne    5129 <botlish_fn_50+0xd3>
    5119:	xor    rax,rax
    511c:	mov    rbx,QWORD PTR [rsp]
    5120:	add    rsp,0x10
    5124:	mov    rsp,rbp
    5127:	pop    rbp
    5128:	ret
    5129:	mov    rbx,QWORD PTR [rsp]
    512d:	add    rsp,0x10
    5131:	mov    rsp,rbp
    5134:	pop    rbp
    5135:	ret

0000000000005136 <botlish_entry_50: sample<generic>>:
    5136:	push   rbp
    5137:	mov    rbp,rsp
    513a:	call   513f <botlish_entry_50+0x9>
			513b: R_X86_64_PLT32	botlish_fn_50-0x4 ; sample<generic>
    513f:	mov    rsp,rbp
    5142:	pop    rbp
    5143:	ret
