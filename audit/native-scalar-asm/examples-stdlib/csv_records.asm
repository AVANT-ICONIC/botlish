; source:  examples/stdlib/csv_records.bot
; backend: Cranelift (specialize=1), native::object
; object:  ELF64 x86-64, unlinked (Botlish-generated code only; runtime
;          helpers are unresolved imports, so their bodies are not present)
; format:  objdump -dr --no-show-raw-insn -M intel
; total machine code bytes: 19604  (per function: 45 89 89 89 357 420 420 420 202 202 202 81 365 309 470 932 310 758 215 480 318 427 385 70 493 114 69 69 46 182 178 628 1032 341 388 407 616 654 809 673 928 700 107 433 259 629 515 78 78 1222 301)
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
     291:	mov    r13,rdi
     294:	mov    QWORD PTR [rsp],rsi
     298:	mov    r12,rsi
     29b:	mov    QWORD PTR [rsp+0x8],rdx
     2a0:	mov    rbx,rdx
     2a3:	mov    QWORD PTR [rsp+0x10],rcx
     2a8:	mov    r14,rcx
     2ab:	mov    rsi,r12
     2ae:	mov    rdi,r13
     2b1:	call   2b6 <botlish_fn_5+0x46>
			2b2: R_X86_64_PLT32	rt_mutarray_capacity-0x4
     2b6:	mov    r15,rax
     2b9:	mov    QWORD PTR [rsp+0x18],rax
     2be:	mov    rcx,rbx
     2c1:	and    rcx,rax
     2c4:	test   rcx,0x1
     2cb:	jne    2f7 <botlish_fn_5+0x87>
     2d1:	mov    rdx,r15
     2d4:	mov    rsi,rbx
     2d7:	mov    rdi,r13
     2da:	call   2df <botlish_fn_5+0x6f>
			2db: R_X86_64_PLT32	rt_int_cmp-0x4
     2df:	mov    ecx,0x2
     2e4:	test   rax,rax
     2e7:	cmovl  rcx,QWORD PTR [rip+0xe9]        # 3d8 <botlish_fn_5+0x168>
     2ef:	mov    rax,r15
     2f2:	jmp    30a <botlish_fn_5+0x9a>
     2f7:	mov    ecx,0x2
     2fc:	mov    rax,r15
     2ff:	cmp    rbx,rax
     302:	cmovl  rcx,QWORD PTR [rip+0xce]        # 3d8 <botlish_fn_5+0x168>
     30a:	cmp    rcx,0x6
     30e:	je     3ae <botlish_fn_5+0x13e>
     314:	mov    rsi,rax
     317:	mov    rdx,rbx
     31a:	mov    rdi,r13
     31d:	call   322 <botlish_fn_5+0xb2>
			31e: R_X86_64_PLT32	botlish_fn_4-0x4 ; geo_new_capacity<int, int>
     322:	mov    QWORD PTR [rsp+0x18],rax
     327:	mov    rdx,r14
     32a:	mov    rsi,rax
     32d:	mov    rdi,r13
     330:	call   335 <botlish_fn_5+0xc5>
			331: R_X86_64_PLT32	rt_mutarray_create-0x4
     335:	test   rax,rax
     338:	mov    r14,rax
     33b:	je     364 <botlish_fn_5+0xf4>
     341:	mov    r8d,0x1
     347:	mov    rcx,r12
     34a:	mov    rdi,r13
     34d:	mov    r9,rbx
     350:	mov    rsi,r14
     353:	mov    rdx,r8
     356:	call   35b <botlish_fn_5+0xeb>
			357: R_X86_64_PLT32	rt_mutarray_copy-0x4
     35b:	test   rax,rax
     35e:	jne    389 <botlish_fn_5+0x119>
     364:	xor    rax,rax
     367:	mov    rbx,QWORD PTR [rsp+0x20]
     36c:	mov    r12,QWORD PTR [rsp+0x28]
     371:	mov    r13,QWORD PTR [rsp+0x30]
     376:	mov    r14,QWORD PTR [rsp+0x38]
     37b:	mov    r15,QWORD PTR [rsp+0x40]
     380:	add    rsp,0x50
     384:	mov    rsp,rbp
     387:	pop    rbp
     388:	ret
     389:	mov    rax,r14
     38c:	mov    rbx,QWORD PTR [rsp+0x20]
     391:	mov    r12,QWORD PTR [rsp+0x28]
     396:	mov    r13,QWORD PTR [rsp+0x30]
     39b:	mov    r14,QWORD PTR [rsp+0x38]
     3a0:	mov    r15,QWORD PTR [rsp+0x40]
     3a5:	add    rsp,0x50
     3a9:	mov    rsp,rbp
     3ac:	pop    rbp
     3ad:	ret
     3ae:	mov    rax,r12
     3b1:	mov    rbx,QWORD PTR [rsp+0x20]
     3b6:	mov    r12,QWORD PTR [rsp+0x28]
     3bb:	mov    r13,QWORD PTR [rsp+0x30]
     3c0:	mov    r14,QWORD PTR [rsp+0x38]
     3c5:	mov    r15,QWORD PTR [rsp+0x40]
     3ca:	add    rsp,0x50
     3ce:	mov    rsp,rbp
     3d1:	pop    rbp
     3d2:	ret
     3d3:	add    BYTE PTR [rax],al
     3d5:	add    BYTE PTR [rax],al
     3d7:	add    BYTE PTR [rsi],al
     3d9:	add    BYTE PTR [rax],al
     3db:	add    BYTE PTR [rax],al
     3dd:	add    BYTE PTR [rax],al
	...

00000000000003e0 <botlish_entry_5: geo_grow<mutarray, int, str>>:
     3e0:	push   rbp
     3e1:	mov    rbp,rsp
     3e4:	mov    rsi,QWORD PTR [rdx]
     3e7:	mov    r8,QWORD PTR [rdx+0x8]
     3eb:	mov    rcx,QWORD PTR [rdx+0x10]
     3ef:	mov    rdx,r8
     3f2:	call   3f7 <botlish_entry_5+0x17>
			3f3: R_X86_64_PLT32	botlish_fn_5-0x4 ; geo_grow<mutarray, int, str>
     3f7:	mov    rsp,rbp
     3fa:	pop    rbp
     3fb:	ret
     3fc:	add    BYTE PTR [rax],al
	...

0000000000000400 <botlish_fn_6: geo_grow<mutarray, int, List[str]>>:
     400:	push   rbp
     401:	mov    rbp,rsp
     404:	sub    rsp,0x50
     408:	mov    QWORD PTR [rsp+0x20],rbx
     40d:	mov    QWORD PTR [rsp+0x28],r12
     412:	mov    QWORD PTR [rsp+0x30],r13
     417:	mov    QWORD PTR [rsp+0x38],r14
     41c:	mov    QWORD PTR [rsp+0x40],r15
     421:	mov    r13,rdi
     424:	mov    QWORD PTR [rsp],rsi
     428:	mov    r12,rsi
     42b:	mov    QWORD PTR [rsp+0x8],rdx
     430:	mov    rbx,rdx
     433:	mov    QWORD PTR [rsp+0x10],rcx
     438:	mov    r14,rcx
     43b:	mov    rsi,r12
     43e:	mov    rdi,r13
     441:	call   446 <botlish_fn_6+0x46>
			442: R_X86_64_PLT32	rt_mutarray_capacity-0x4
     446:	mov    r15,rax
     449:	mov    QWORD PTR [rsp+0x18],rax
     44e:	mov    rcx,rbx
     451:	and    rcx,rax
     454:	test   rcx,0x1
     45b:	jne    487 <botlish_fn_6+0x87>
     461:	mov    rdx,r15
     464:	mov    rsi,rbx
     467:	mov    rdi,r13
     46a:	call   46f <botlish_fn_6+0x6f>
			46b: R_X86_64_PLT32	rt_int_cmp-0x4
     46f:	mov    ecx,0x2
     474:	test   rax,rax
     477:	cmovl  rcx,QWORD PTR [rip+0xe9]        # 568 <botlish_fn_6+0x168>
     47f:	mov    rax,r15
     482:	jmp    49a <botlish_fn_6+0x9a>
     487:	mov    ecx,0x2
     48c:	mov    rax,r15
     48f:	cmp    rbx,rax
     492:	cmovl  rcx,QWORD PTR [rip+0xce]        # 568 <botlish_fn_6+0x168>
     49a:	cmp    rcx,0x6
     49e:	je     53e <botlish_fn_6+0x13e>
     4a4:	mov    rsi,rax
     4a7:	mov    rdx,rbx
     4aa:	mov    rdi,r13
     4ad:	call   4b2 <botlish_fn_6+0xb2>
			4ae: R_X86_64_PLT32	botlish_fn_4-0x4 ; geo_new_capacity<int, int>
     4b2:	mov    QWORD PTR [rsp+0x18],rax
     4b7:	mov    rdx,r14
     4ba:	mov    rsi,rax
     4bd:	mov    rdi,r13
     4c0:	call   4c5 <botlish_fn_6+0xc5>
			4c1: R_X86_64_PLT32	rt_mutarray_create-0x4
     4c5:	test   rax,rax
     4c8:	mov    r14,rax
     4cb:	je     4f4 <botlish_fn_6+0xf4>
     4d1:	mov    r8d,0x1
     4d7:	mov    rcx,r12
     4da:	mov    rdi,r13
     4dd:	mov    r9,rbx
     4e0:	mov    rsi,r14
     4e3:	mov    rdx,r8
     4e6:	call   4eb <botlish_fn_6+0xeb>
			4e7: R_X86_64_PLT32	rt_mutarray_copy-0x4
     4eb:	test   rax,rax
     4ee:	jne    519 <botlish_fn_6+0x119>
     4f4:	xor    rax,rax
     4f7:	mov    rbx,QWORD PTR [rsp+0x20]
     4fc:	mov    r12,QWORD PTR [rsp+0x28]
     501:	mov    r13,QWORD PTR [rsp+0x30]
     506:	mov    r14,QWORD PTR [rsp+0x38]
     50b:	mov    r15,QWORD PTR [rsp+0x40]
     510:	add    rsp,0x50
     514:	mov    rsp,rbp
     517:	pop    rbp
     518:	ret
     519:	mov    rax,r14
     51c:	mov    rbx,QWORD PTR [rsp+0x20]
     521:	mov    r12,QWORD PTR [rsp+0x28]
     526:	mov    r13,QWORD PTR [rsp+0x30]
     52b:	mov    r14,QWORD PTR [rsp+0x38]
     530:	mov    r15,QWORD PTR [rsp+0x40]
     535:	add    rsp,0x50
     539:	mov    rsp,rbp
     53c:	pop    rbp
     53d:	ret
     53e:	mov    rax,r12
     541:	mov    rbx,QWORD PTR [rsp+0x20]
     546:	mov    r12,QWORD PTR [rsp+0x28]
     54b:	mov    r13,QWORD PTR [rsp+0x30]
     550:	mov    r14,QWORD PTR [rsp+0x38]
     555:	mov    r15,QWORD PTR [rsp+0x40]
     55a:	add    rsp,0x50
     55e:	mov    rsp,rbp
     561:	pop    rbp
     562:	ret
     563:	add    BYTE PTR [rax],al
     565:	add    BYTE PTR [rax],al
     567:	add    BYTE PTR [rsi],al
     569:	add    BYTE PTR [rax],al
     56b:	add    BYTE PTR [rax],al
     56d:	add    BYTE PTR [rax],al
	...

0000000000000570 <botlish_entry_6: geo_grow<mutarray, int, List[str]>>:
     570:	push   rbp
     571:	mov    rbp,rsp
     574:	mov    rsi,QWORD PTR [rdx]
     577:	mov    r8,QWORD PTR [rdx+0x8]
     57b:	mov    rcx,QWORD PTR [rdx+0x10]
     57f:	mov    rdx,r8
     582:	call   587 <botlish_entry_6+0x17>
			583: R_X86_64_PLT32	botlish_fn_6-0x4 ; geo_grow<mutarray, int, List[str]>
     587:	mov    rsp,rbp
     58a:	pop    rbp
     58b:	ret
     58c:	add    BYTE PTR [rax],al
	...

0000000000000590 <botlish_fn_7: geo_grow<mutarray, int, HashTable>>:
     590:	push   rbp
     591:	mov    rbp,rsp
     594:	sub    rsp,0x50
     598:	mov    QWORD PTR [rsp+0x20],rbx
     59d:	mov    QWORD PTR [rsp+0x28],r12
     5a2:	mov    QWORD PTR [rsp+0x30],r13
     5a7:	mov    QWORD PTR [rsp+0x38],r14
     5ac:	mov    QWORD PTR [rsp+0x40],r15
     5b1:	mov    r13,rdi
     5b4:	mov    QWORD PTR [rsp],rsi
     5b8:	mov    r12,rsi
     5bb:	mov    QWORD PTR [rsp+0x8],rdx
     5c0:	mov    rbx,rdx
     5c3:	mov    QWORD PTR [rsp+0x10],rcx
     5c8:	mov    r14,rcx
     5cb:	mov    rsi,r12
     5ce:	mov    rdi,r13
     5d1:	call   5d6 <botlish_fn_7+0x46>
			5d2: R_X86_64_PLT32	rt_mutarray_capacity-0x4
     5d6:	mov    r15,rax
     5d9:	mov    QWORD PTR [rsp+0x18],rax
     5de:	mov    rcx,rbx
     5e1:	and    rcx,rax
     5e4:	test   rcx,0x1
     5eb:	jne    617 <botlish_fn_7+0x87>
     5f1:	mov    rdx,r15
     5f4:	mov    rsi,rbx
     5f7:	mov    rdi,r13
     5fa:	call   5ff <botlish_fn_7+0x6f>
			5fb: R_X86_64_PLT32	rt_int_cmp-0x4
     5ff:	mov    ecx,0x2
     604:	test   rax,rax
     607:	cmovl  rcx,QWORD PTR [rip+0xe9]        # 6f8 <botlish_fn_7+0x168>
     60f:	mov    rax,r15
     612:	jmp    62a <botlish_fn_7+0x9a>
     617:	mov    ecx,0x2
     61c:	mov    rax,r15
     61f:	cmp    rbx,rax
     622:	cmovl  rcx,QWORD PTR [rip+0xce]        # 6f8 <botlish_fn_7+0x168>
     62a:	cmp    rcx,0x6
     62e:	je     6ce <botlish_fn_7+0x13e>
     634:	mov    rsi,rax
     637:	mov    rdx,rbx
     63a:	mov    rdi,r13
     63d:	call   642 <botlish_fn_7+0xb2>
			63e: R_X86_64_PLT32	botlish_fn_4-0x4 ; geo_new_capacity<int, int>
     642:	mov    QWORD PTR [rsp+0x18],rax
     647:	mov    rdx,r14
     64a:	mov    rsi,rax
     64d:	mov    rdi,r13
     650:	call   655 <botlish_fn_7+0xc5>
			651: R_X86_64_PLT32	rt_mutarray_create-0x4
     655:	test   rax,rax
     658:	mov    r14,rax
     65b:	je     684 <botlish_fn_7+0xf4>
     661:	mov    r8d,0x1
     667:	mov    rcx,r12
     66a:	mov    rdi,r13
     66d:	mov    r9,rbx
     670:	mov    rsi,r14
     673:	mov    rdx,r8
     676:	call   67b <botlish_fn_7+0xeb>
			677: R_X86_64_PLT32	rt_mutarray_copy-0x4
     67b:	test   rax,rax
     67e:	jne    6a9 <botlish_fn_7+0x119>
     684:	xor    rax,rax
     687:	mov    rbx,QWORD PTR [rsp+0x20]
     68c:	mov    r12,QWORD PTR [rsp+0x28]
     691:	mov    r13,QWORD PTR [rsp+0x30]
     696:	mov    r14,QWORD PTR [rsp+0x38]
     69b:	mov    r15,QWORD PTR [rsp+0x40]
     6a0:	add    rsp,0x50
     6a4:	mov    rsp,rbp
     6a7:	pop    rbp
     6a8:	ret
     6a9:	mov    rax,r14
     6ac:	mov    rbx,QWORD PTR [rsp+0x20]
     6b1:	mov    r12,QWORD PTR [rsp+0x28]
     6b6:	mov    r13,QWORD PTR [rsp+0x30]
     6bb:	mov    r14,QWORD PTR [rsp+0x38]
     6c0:	mov    r15,QWORD PTR [rsp+0x40]
     6c5:	add    rsp,0x50
     6c9:	mov    rsp,rbp
     6cc:	pop    rbp
     6cd:	ret
     6ce:	mov    rax,r12
     6d1:	mov    rbx,QWORD PTR [rsp+0x20]
     6d6:	mov    r12,QWORD PTR [rsp+0x28]
     6db:	mov    r13,QWORD PTR [rsp+0x30]
     6e0:	mov    r14,QWORD PTR [rsp+0x38]
     6e5:	mov    r15,QWORD PTR [rsp+0x40]
     6ea:	add    rsp,0x50
     6ee:	mov    rsp,rbp
     6f1:	pop    rbp
     6f2:	ret
     6f3:	add    BYTE PTR [rax],al
     6f5:	add    BYTE PTR [rax],al
     6f7:	add    BYTE PTR [rsi],al
     6f9:	add    BYTE PTR [rax],al
     6fb:	add    BYTE PTR [rax],al
     6fd:	add    BYTE PTR [rax],al
	...

0000000000000700 <botlish_entry_7: geo_grow<mutarray, int, HashTable>>:
     700:	push   rbp
     701:	mov    rbp,rsp
     704:	mov    rsi,QWORD PTR [rdx]
     707:	mov    r8,QWORD PTR [rdx+0x8]
     70b:	mov    rcx,QWORD PTR [rdx+0x10]
     70f:	mov    rdx,r8
     712:	call   717 <botlish_entry_7+0x17>
			713: R_X86_64_PLT32	botlish_fn_7-0x4 ; geo_grow<mutarray, int, HashTable>
     717:	mov    rsp,rbp
     71a:	pop    rbp
     71b:	ret

000000000000071c <botlish_fn_8: geo_append<mutarray, int, str>>:
     71c:	push   rbp
     71d:	mov    rbp,rsp
     720:	sub    rsp,0x40
     724:	mov    QWORD PTR [rsp+0x20],rbx
     729:	mov    QWORD PTR [rsp+0x28],r12
     72e:	mov    QWORD PTR [rsp+0x30],r13
     733:	mov    QWORD PTR [rsp+0x38],r14
     738:	mov    r14,rdi
     73b:	mov    QWORD PTR [rsp],rsi
     73f:	mov    QWORD PTR [rsp+0x8],rdx
     744:	mov    r13,rdx
     747:	mov    QWORD PTR [rsp+0x10],rcx
     74c:	mov    r12,rcx
     74f:	mov    rcx,r12
     752:	mov    rdx,r13
     755:	mov    rdi,r14
     758:	call   75d <botlish_fn_8+0x41>
			759: R_X86_64_PLT32	botlish_fn_5-0x4 ; geo_grow<mutarray, int, str>
     75d:	test   rax,rax
     760:	mov    rbx,rax
     763:	je     783 <botlish_fn_8+0x67>
     769:	mov    rcx,r12
     76c:	mov    rdx,r13
     76f:	mov    rdi,r14
     772:	mov    rsi,rbx
     775:	call   77a <botlish_fn_8+0x5e>
			776: R_X86_64_PLT32	rt_mutarray_set-0x4
     77a:	test   rax,rax
     77d:	jne    7a3 <botlish_fn_8+0x87>
     783:	xor    rax,rax
     786:	mov    rbx,QWORD PTR [rsp+0x20]
     78b:	mov    r12,QWORD PTR [rsp+0x28]
     790:	mov    r13,QWORD PTR [rsp+0x30]
     795:	mov    r14,QWORD PTR [rsp+0x38]
     79a:	add    rsp,0x40
     79e:	mov    rsp,rbp
     7a1:	pop    rbp
     7a2:	ret
     7a3:	mov    rax,rbx
     7a6:	mov    rbx,QWORD PTR [rsp+0x20]
     7ab:	mov    r12,QWORD PTR [rsp+0x28]
     7b0:	mov    r13,QWORD PTR [rsp+0x30]
     7b5:	mov    r14,QWORD PTR [rsp+0x38]
     7ba:	add    rsp,0x40
     7be:	mov    rsp,rbp
     7c1:	pop    rbp
     7c2:	ret

00000000000007c3 <botlish_entry_8: geo_append<mutarray, int, str>>:
     7c3:	push   rbp
     7c4:	mov    rbp,rsp
     7c7:	mov    rsi,QWORD PTR [rdx]
     7ca:	mov    r8,QWORD PTR [rdx+0x8]
     7ce:	mov    rcx,QWORD PTR [rdx+0x10]
     7d2:	mov    rdx,r8
     7d5:	call   7da <botlish_entry_8+0x17>
			7d6: R_X86_64_PLT32	botlish_fn_8-0x4 ; geo_append<mutarray, int, str>
     7da:	mov    rsp,rbp
     7dd:	pop    rbp
     7de:	ret

00000000000007df <botlish_fn_9: geo_append<mutarray, int, List[str]>>:
     7df:	push   rbp
     7e0:	mov    rbp,rsp
     7e3:	sub    rsp,0x40
     7e7:	mov    QWORD PTR [rsp+0x20],rbx
     7ec:	mov    QWORD PTR [rsp+0x28],r12
     7f1:	mov    QWORD PTR [rsp+0x30],r13
     7f6:	mov    QWORD PTR [rsp+0x38],r14
     7fb:	mov    r14,rdi
     7fe:	mov    QWORD PTR [rsp],rsi
     802:	mov    QWORD PTR [rsp+0x8],rdx
     807:	mov    r13,rdx
     80a:	mov    QWORD PTR [rsp+0x10],rcx
     80f:	mov    r12,rcx
     812:	mov    rcx,r12
     815:	mov    rdx,r13
     818:	mov    rdi,r14
     81b:	call   820 <botlish_fn_9+0x41>
			81c: R_X86_64_PLT32	botlish_fn_6-0x4 ; geo_grow<mutarray, int, List[str]>
     820:	test   rax,rax
     823:	mov    rbx,rax
     826:	je     846 <botlish_fn_9+0x67>
     82c:	mov    rcx,r12
     82f:	mov    rdx,r13
     832:	mov    rdi,r14
     835:	mov    rsi,rbx
     838:	call   83d <botlish_fn_9+0x5e>
			839: R_X86_64_PLT32	rt_mutarray_set-0x4
     83d:	test   rax,rax
     840:	jne    866 <botlish_fn_9+0x87>
     846:	xor    rax,rax
     849:	mov    rbx,QWORD PTR [rsp+0x20]
     84e:	mov    r12,QWORD PTR [rsp+0x28]
     853:	mov    r13,QWORD PTR [rsp+0x30]
     858:	mov    r14,QWORD PTR [rsp+0x38]
     85d:	add    rsp,0x40
     861:	mov    rsp,rbp
     864:	pop    rbp
     865:	ret
     866:	mov    rax,rbx
     869:	mov    rbx,QWORD PTR [rsp+0x20]
     86e:	mov    r12,QWORD PTR [rsp+0x28]
     873:	mov    r13,QWORD PTR [rsp+0x30]
     878:	mov    r14,QWORD PTR [rsp+0x38]
     87d:	add    rsp,0x40
     881:	mov    rsp,rbp
     884:	pop    rbp
     885:	ret

0000000000000886 <botlish_entry_9: geo_append<mutarray, int, List[str]>>:
     886:	push   rbp
     887:	mov    rbp,rsp
     88a:	mov    rsi,QWORD PTR [rdx]
     88d:	mov    r8,QWORD PTR [rdx+0x8]
     891:	mov    rcx,QWORD PTR [rdx+0x10]
     895:	mov    rdx,r8
     898:	call   89d <botlish_entry_9+0x17>
			899: R_X86_64_PLT32	botlish_fn_9-0x4 ; geo_append<mutarray, int, List[str]>
     89d:	mov    rsp,rbp
     8a0:	pop    rbp
     8a1:	ret

00000000000008a2 <botlish_fn_10: geo_append<mutarray, int, HashTable>>:
     8a2:	push   rbp
     8a3:	mov    rbp,rsp
     8a6:	sub    rsp,0x40
     8aa:	mov    QWORD PTR [rsp+0x20],rbx
     8af:	mov    QWORD PTR [rsp+0x28],r12
     8b4:	mov    QWORD PTR [rsp+0x30],r13
     8b9:	mov    QWORD PTR [rsp+0x38],r14
     8be:	mov    r14,rdi
     8c1:	mov    QWORD PTR [rsp],rsi
     8c5:	mov    QWORD PTR [rsp+0x8],rdx
     8ca:	mov    r13,rdx
     8cd:	mov    QWORD PTR [rsp+0x10],rcx
     8d2:	mov    r12,rcx
     8d5:	mov    rcx,r12
     8d8:	mov    rdx,r13
     8db:	mov    rdi,r14
     8de:	call   8e3 <botlish_fn_10+0x41>
			8df: R_X86_64_PLT32	botlish_fn_7-0x4 ; geo_grow<mutarray, int, HashTable>
     8e3:	test   rax,rax
     8e6:	mov    rbx,rax
     8e9:	je     909 <botlish_fn_10+0x67>
     8ef:	mov    rcx,r12
     8f2:	mov    rdx,r13
     8f5:	mov    rdi,r14
     8f8:	mov    rsi,rbx
     8fb:	call   900 <botlish_fn_10+0x5e>
			8fc: R_X86_64_PLT32	rt_mutarray_set-0x4
     900:	test   rax,rax
     903:	jne    929 <botlish_fn_10+0x87>
     909:	xor    rax,rax
     90c:	mov    rbx,QWORD PTR [rsp+0x20]
     911:	mov    r12,QWORD PTR [rsp+0x28]
     916:	mov    r13,QWORD PTR [rsp+0x30]
     91b:	mov    r14,QWORD PTR [rsp+0x38]
     920:	add    rsp,0x40
     924:	mov    rsp,rbp
     927:	pop    rbp
     928:	ret
     929:	mov    rax,rbx
     92c:	mov    rbx,QWORD PTR [rsp+0x20]
     931:	mov    r12,QWORD PTR [rsp+0x28]
     936:	mov    r13,QWORD PTR [rsp+0x30]
     93b:	mov    r14,QWORD PTR [rsp+0x38]
     940:	add    rsp,0x40
     944:	mov    rsp,rbp
     947:	pop    rbp
     948:	ret

0000000000000949 <botlish_entry_10: geo_append<mutarray, int, HashTable>>:
     949:	push   rbp
     94a:	mov    rbp,rsp
     94d:	mov    rsi,QWORD PTR [rdx]
     950:	mov    r8,QWORD PTR [rdx+0x8]
     954:	mov    rcx,QWORD PTR [rdx+0x10]
     958:	mov    rdx,r8
     95b:	call   960 <botlish_entry_10+0x17>
			95c: R_X86_64_PLT32	botlish_fn_10-0x4 ; geo_append<mutarray, int, HashTable>
     960:	mov    rsp,rbp
     963:	pop    rbp
     964:	ret

0000000000000965 <botlish_fn_11: geo_finish<mutarray, int>>:
     965:	push   rbp
     966:	mov    rbp,rsp
     969:	sub    rsp,0x10
     96d:	mov    QWORD PTR [rsp],rsi
     971:	mov    QWORD PTR [rsp+0x8],rdx
     976:	call   97b <botlish_fn_11+0x16>
			977: R_X86_64_PLT32	rt_mutarray_freeze-0x4
     97b:	test   rax,rax
     97e:	jne    990 <botlish_fn_11+0x2b>
     984:	xor    rax,rax
     987:	add    rsp,0x10
     98b:	mov    rsp,rbp
     98e:	pop    rbp
     98f:	ret
     990:	add    rsp,0x10
     994:	mov    rsp,rbp
     997:	pop    rbp
     998:	ret

0000000000000999 <botlish_entry_11: geo_finish<mutarray, int>>:
     999:	push   rbp
     99a:	mov    rbp,rsp
     99d:	mov    rsi,QWORD PTR [rdx]
     9a0:	mov    rdx,QWORD PTR [rdx+0x8]
     9a4:	call   9a9 <botlish_entry_11+0x10>
			9a5: R_X86_64_PLT32	botlish_fn_11-0x4 ; geo_finish<mutarray, int>
     9a9:	mov    rsp,rbp
     9ac:	pop    rbp
     9ad:	ret
	...

00000000000009b0 <botlish_fn_12: peek<str, int>>:
     9b0:	push   rbp
     9b1:	mov    rbp,rsp
     9b4:	sub    rsp,0x40
     9b8:	mov    QWORD PTR [rsp+0x20],rbx
     9bd:	mov    QWORD PTR [rsp+0x28],r12
     9c2:	mov    QWORD PTR [rsp+0x30],r13
     9c7:	mov    rbx,rdx
     9ca:	mov    r13,rdi
     9cd:	mov    QWORD PTR [rsp],rsi
     9d1:	mov    QWORD PTR [rsp+0x8],rdx
     9d6:	mov    rdx,QWORD PTR [rsi+0x8]
     9da:	mov    r12,rsi
     9dd:	shl    rdx,1
     9e0:	mov    rax,rdx
     9e3:	or     rax,0x1
     9e7:	mov    rcx,rbx
     9ea:	and    rcx,rax
     9ed:	test   rcx,0x1
     9f4:	jne    a1e <botlish_fn_12+0x6e>
     9fa:	or     rdx,0x1
     9fe:	mov    rsi,rbx
     a01:	mov    rdi,r13
     a04:	call   a09 <botlish_fn_12+0x59>
			a05: R_X86_64_PLT32	rt_int_cmp-0x4
     a09:	mov    ecx,0x2
     a0e:	test   rax,rax
     a11:	cmovge rcx,QWORD PTR [rip+0xcf]        # ae8 <botlish_fn_12+0x138>
     a19:	jmp    a32 <botlish_fn_12+0x82>
     a1e:	or     rdx,0x1
     a22:	mov    ecx,0x2
     a27:	cmp    rbx,rdx
     a2a:	cmovge rcx,QWORD PTR [rip+0xb6]        # ae8 <botlish_fn_12+0x138>
     a32:	cmp    rcx,0x6
     a36:	je     ac6 <botlish_fn_12+0x116>
     a3c:	mov    QWORD PTR [rsp+0x10],0x3
     a45:	test   rbx,0x1
     a4c:	je     a64 <botlish_fn_12+0xb4>
     a52:	mov    rcx,rbx
     a55:	add    rcx,0x2
     a59:	seto   al
     a5c:	test   al,al
     a5e:	je     a77 <botlish_fn_12+0xc7>
     a64:	mov    edx,0x3
     a69:	mov    rsi,rbx
     a6c:	mov    rdi,r13
     a6f:	call   a74 <botlish_fn_12+0xc4>
			a70: R_X86_64_PLT32	rt_int_add-0x4
     a74:	mov    rcx,rax
     a77:	mov    QWORD PTR [rsp+0x10],rcx
     a7c:	mov    rdx,rbx
     a7f:	mov    rsi,r12
     a82:	mov    rdi,r13
     a85:	call   a8a <botlish_fn_12+0xda>
			a86: R_X86_64_PLT32	rt_substr-0x4
     a8a:	test   rax,rax
     a8d:	jne    aae <botlish_fn_12+0xfe>
     a93:	xor    rax,rax
     a96:	mov    rbx,QWORD PTR [rsp+0x20]
     a9b:	mov    r12,QWORD PTR [rsp+0x28]
     aa0:	mov    r13,QWORD PTR [rsp+0x30]
     aa5:	add    rsp,0x40
     aa9:	mov    rsp,rbp
     aac:	pop    rbp
     aad:	ret
     aae:	mov    rbx,QWORD PTR [rsp+0x20]
     ab3:	mov    r12,QWORD PTR [rsp+0x28]
     ab8:	mov    r13,QWORD PTR [rsp+0x30]
     abd:	add    rsp,0x40
     ac1:	mov    rsp,rbp
     ac4:	pop    rbp
     ac5:	ret
     ac6:	mov    rdi,r13
     ac9:	mov    rax,QWORD PTR [rdi+0x10]
     acd:	mov    rax,QWORD PTR [rax]
     ad0:	mov    rbx,QWORD PTR [rsp+0x20]
     ad5:	mov    r12,QWORD PTR [rsp+0x28]
     ada:	mov    r13,QWORD PTR [rsp+0x30]
     adf:	add    rsp,0x40
     ae3:	mov    rsp,rbp
     ae6:	pop    rbp
     ae7:	ret
     ae8:	(bad)
     ae9:	add    BYTE PTR [rax],al
     aeb:	add    BYTE PTR [rax],al
     aed:	add    BYTE PTR [rax],al
	...

0000000000000af0 <botlish_entry_12: peek<str, int>>:
     af0:	push   rbp
     af1:	mov    rbp,rsp
     af4:	mov    rsi,QWORD PTR [rdx]
     af7:	mov    rdx,QWORD PTR [rdx+0x8]
     afb:	call   b00 <botlish_entry_12+0x10>
			afc: R_X86_64_PLT32	botlish_fn_12-0x4 ; peek<str, int>
     b00:	mov    rsp,rbp
     b03:	pop    rbp
     b04:	ret
     b05:	add    BYTE PTR [rax],al
	...

0000000000000b08 <botlish_fn_13: quote_at?<str, int>>:
     b08:	push   rbp
     b09:	mov    rbp,rsp
     b0c:	sub    rsp,0x20
     b10:	mov    QWORD PTR [rsp],rbx
     b14:	mov    QWORD PTR [rsp+0x8],r12
     b19:	mov    QWORD PTR [rsp+0x10],r13
     b1e:	mov    rbx,rdx
     b21:	mov    r13,rdi
     b24:	mov    rdx,QWORD PTR [rsi+0x8]
     b28:	mov    r12,rsi
     b2b:	shl    rdx,1
     b2e:	mov    rax,rdx
     b31:	or     rax,0x1
     b35:	mov    rcx,rbx
     b38:	and    rcx,rax
     b3b:	test   rcx,0x1
     b42:	jne    b6c <botlish_fn_13+0x64>
     b48:	or     rdx,0x1
     b4c:	mov    rsi,rbx
     b4f:	mov    rdi,r13
     b52:	call   b57 <botlish_fn_13+0x4f>
			b53: R_X86_64_PLT32	rt_int_cmp-0x4
     b57:	mov    ecx,0x2
     b5c:	test   rax,rax
     b5f:	cmovl  rcx,QWORD PTR [rip+0xa1]        # c08 <botlish_fn_13+0x100>
     b67:	jmp    b83 <botlish_fn_13+0x7b>
     b6c:	or     rdx,0x1
     b70:	mov    ecx,0x2
     b75:	mov    rax,rbx
     b78:	cmp    rax,rdx
     b7b:	cmovl  rcx,QWORD PTR [rip+0x85]        # c08 <botlish_fn_13+0x100>
     b83:	mov    eax,0x6
     b88:	cmp    rcx,0x6
     b8c:	je     b9f <botlish_fn_13+0x97>
     b92:	mov    eax,0x2
     b97:	mov    r12,rax
     b9a:	jmp    bec <botlish_fn_13+0xe4>
     b9f:	mov    rdi,r13
     ba2:	mov    rsi,r12
     ba5:	mov    r12,rax
     ba8:	mov    rdx,rbx
     bab:	call   bb0 <botlish_fn_13+0xa8>
			bac: R_X86_64_PLT32	rt_str_char_at-0x4
     bb0:	test   rax,rax
     bb3:	jne    bd3 <botlish_fn_13+0xcb>
     bb9:	xor    rax,rax
     bbc:	mov    rbx,QWORD PTR [rsp]
     bc0:	mov    r12,QWORD PTR [rsp+0x8]
     bc5:	mov    r13,QWORD PTR [rsp+0x10]
     bca:	add    rsp,0x20
     bce:	mov    rsp,rbp
     bd1:	pop    rbp
     bd2:	ret
     bd3:	cmp    rax,0x114
     bd9:	je     be9 <botlish_fn_13+0xe1>
     bdf:	mov    eax,0x2
     be4:	jmp    bec <botlish_fn_13+0xe4>
     be9:	mov    rax,r12
     bec:	mov    rbx,QWORD PTR [rsp]
     bf0:	mov    r12,QWORD PTR [rsp+0x8]
     bf5:	mov    r13,QWORD PTR [rsp+0x10]
     bfa:	add    rsp,0x20
     bfe:	mov    rsp,rbp
     c01:	pop    rbp
     c02:	ret
     c03:	add    BYTE PTR [rax],al
     c05:	add    BYTE PTR [rax],al
     c07:	add    BYTE PTR [rsi],al
     c09:	add    BYTE PTR [rax],al
     c0b:	add    BYTE PTR [rax],al
     c0d:	add    BYTE PTR [rax],al
	...

0000000000000c10 <botlish_entry_13: quote_at?<str, int>>:
     c10:	push   rbp
     c11:	mov    rbp,rsp
     c14:	mov    rsi,QWORD PTR [rdx]
     c17:	mov    rdx,QWORD PTR [rdx+0x8]
     c1b:	call   c20 <botlish_entry_13+0x10>
			c1c: R_X86_64_PLT32	botlish_fn_13-0x4 ; quote_at?<str, int>
     c20:	mov    rsp,rbp
     c23:	pop    rbp
     c24:	ret
     c25:	add    BYTE PTR [rax],al
	...

0000000000000c28 <botlish_fn_14: scan_unquoted<str, int, int>>:
     c28:	push   rbp
     c29:	mov    rbp,rsp
     c2c:	sub    rsp,0x40
     c30:	mov    QWORD PTR [rsp+0x20],rbx
     c35:	mov    QWORD PTR [rsp+0x28],r12
     c3a:	mov    QWORD PTR [rsp+0x30],r13
     c3f:	mov    QWORD PTR [rsp+0x38],r14
     c44:	mov    r13,rdi
     c47:	mov    QWORD PTR [rsp+0x18],0x0
     c50:	mov    QWORD PTR [rsp],rsi
     c54:	mov    r12,rsi
     c57:	mov    QWORD PTR [rsp+0x8],rdx
     c5c:	mov    rbx,rdx
     c5f:	mov    QWORD PTR [rsp+0x10],rcx
     c64:	mov    rax,r12
     c67:	mov    rsi,rcx
     c6a:	mov    rdx,QWORD PTR [rax+0x8]
     c6e:	mov    r12,rax
     c71:	shl    rdx,1
     c74:	or     rdx,0x1
     c78:	mov    rax,rsi
     c7b:	and    rax,rdx
     c7e:	mov    r14,rsi
     c81:	test   rax,0x1
     c87:	jne    cad <botlish_fn_14+0x85>
     c8d:	mov    rsi,r14
     c90:	mov    rdi,r13
     c93:	call   c98 <botlish_fn_14+0x70>
			c94: R_X86_64_PLT32	rt_int_cmp-0x4
     c98:	mov    ecx,0x2
     c9d:	test   rax,rax
     ca0:	cmovl  rcx,QWORD PTR [rip+0x138]        # de0 <botlish_fn_14+0x1b8>
     ca8:	jmp    cc0 <botlish_fn_14+0x98>
     cad:	mov    ecx,0x2
     cb2:	mov    rsi,r14
     cb5:	cmp    rsi,rdx
     cb8:	cmovl  rcx,QWORD PTR [rip+0x120]        # de0 <botlish_fn_14+0x1b8>
     cc0:	cmp    rcx,0x6
     cc4:	je     cd8 <botlish_fn_14+0xb0>
     cca:	mov    rdx,rbx
     ccd:	mov    rsi,r12
     cd0:	mov    rdi,r13
     cd3:	jmp    d83 <botlish_fn_14+0x15b>
     cd8:	mov    rdx,r14
     cdb:	mov    rsi,r12
     cde:	mov    rdi,r13
     ce1:	call   ce6 <botlish_fn_14+0xbe>
			ce2: R_X86_64_PLT32	rt_str_char_at-0x4
     ce6:	test   rax,rax
     ce9:	je     d9a <botlish_fn_14+0x172>
     cef:	cmp    rax,0x164
     cf5:	jne    d03 <botlish_fn_14+0xdb>
     cfb:	mov    rdx,rbx
     cfe:	jmp    d7d <botlish_fn_14+0x155>
     d03:	cmp    rax,0x54
     d07:	jne    d15 <botlish_fn_14+0xed>
     d0d:	mov    rdx,rbx
     d10:	jmp    d7d <botlish_fn_14+0x155>
     d15:	mov    QWORD PTR [rsp+0x18],0x3
     d1e:	mov    rsi,r14
     d21:	test   rsi,0x1
     d28:	je     d4b <botlish_fn_14+0x123>
     d2e:	mov    rsi,r14
     d31:	mov    rax,rsi
     d34:	add    rax,0x2
     d38:	seto   cl
     d3b:	test   cl,cl
     d3d:	jne    d4b <botlish_fn_14+0x123>
     d43:	mov    rsi,r12
     d46:	jmp    d5e <botlish_fn_14+0x136>
     d4b:	mov    edx,0x3
     d50:	mov    rsi,r14
     d53:	mov    rdi,r13
     d56:	call   d5b <botlish_fn_14+0x133>
			d57: R_X86_64_PLT32	rt_int_add-0x4
     d5b:	mov    rsi,r12
     d5e:	mov    rsi,r12
     d61:	mov    QWORD PTR [rsp],rsi
     d65:	mov    rdx,rbx
     d68:	mov    QWORD PTR [rsp+0x8],rdx
     d6d:	mov    QWORD PTR [rsp+0x10],rax
     d72:	mov    rsi,rax
     d75:	mov    rax,r12
     d78:	jmp    c6a <botlish_fn_14+0x42>
     d7d:	mov    rsi,r12
     d80:	mov    rdi,r13
     d83:	mov    rsi,r12
     d86:	mov    rdi,r13
     d89:	mov    rcx,r14
     d8c:	call   d91 <botlish_fn_14+0x169>
			d8d: R_X86_64_PLT32	rt_substr-0x4
     d91:	test   rax,rax
     d94:	jne    dbd <botlish_fn_14+0x195>
     d9a:	xor    rdx,rdx
     d9d:	mov    rax,rdx
     da0:	mov    rbx,QWORD PTR [rsp+0x20]
     da5:	mov    r12,QWORD PTR [rsp+0x28]
     daa:	mov    r13,QWORD PTR [rsp+0x30]
     daf:	mov    r14,QWORD PTR [rsp+0x38]
     db4:	add    rsp,0x40
     db8:	mov    rsp,rbp
     dbb:	pop    rbp
     dbc:	ret
     dbd:	mov    rdx,r14
     dc0:	mov    rbx,QWORD PTR [rsp+0x20]
     dc5:	mov    r12,QWORD PTR [rsp+0x28]
     dca:	mov    r13,QWORD PTR [rsp+0x30]
     dcf:	mov    r14,QWORD PTR [rsp+0x38]
     dd4:	add    rsp,0x40
     dd8:	mov    rsp,rbp
     ddb:	pop    rbp
     ddc:	ret
     ddd:	add    BYTE PTR [rax],al
     ddf:	add    BYTE PTR [rsi],al
     de1:	add    BYTE PTR [rax],al
     de3:	add    BYTE PTR [rax],al
     de5:	add    BYTE PTR [rax],al
	...

0000000000000de8 <botlish_entry_14: scan_unquoted<str, int, int>>:
     de8:	push   rbp
     de9:	mov    rbp,rsp
     dec:	ud2

0000000000000dee <botlish_fn_15: scan_quoted<str, int, str>>:
     dee:	push   rbp
     def:	mov    rbp,rsp
     df2:	sub    rsp,0xb0
     df9:	mov    QWORD PTR [rsp+0x80],rbx
     e01:	mov    QWORD PTR [rsp+0x88],r12
     e09:	mov    QWORD PTR [rsp+0x90],r13
     e11:	mov    QWORD PTR [rsp+0x98],r14
     e19:	mov    QWORD PTR [rsp+0xa0],r15
     e21:	mov    r15,rdi
     e24:	mov    QWORD PTR [rsp+0x18],0x0
     e2d:	mov    QWORD PTR [rsp+0x20],0x0
     e36:	mov    QWORD PTR [rsp],rsi
     e3a:	mov    QWORD PTR [rsp+0x8],rdx
     e3f:	mov    QWORD PTR [rsp+0x10],rcx
     e44:	mov    r13,rcx
     e47:	lea    r12,[rsp+0x58]
     e4c:	mov    rbx,rsi
     e4f:	mov    QWORD PTR [rsp+0x78],rdx
     e54:	mov    rdx,QWORD PTR [rsp+0x78]
     e59:	mov    rsi,rbx
     e5c:	mov    rdi,r15
     e5f:	call   e64 <botlish_fn_15+0x76>
			e60: R_X86_64_PLT32	botlish_fn_12-0x4 ; peek<str, int>
     e64:	test   rax,rax
     e67:	je     1103 <botlish_fn_15+0x315>
     e6d:	mov    QWORD PTR [rsp+0x18],rax
     e72:	mov    r14,rax
     e75:	mov    rdx,QWORD PTR [rsp+0x78]
     e7a:	mov    rsi,rbx
     e7d:	mov    rdi,r15
     e80:	call   e85 <botlish_fn_15+0x97>
			e81: R_X86_64_PLT32	botlish_fn_13-0x4 ; quote_at?<str, int>
     e85:	test   rax,rax
     e88:	je     1103 <botlish_fn_15+0x315>
     e8e:	cmp    rax,0x6
     e92:	je     f4b <botlish_fn_15+0x15d>
     e98:	mov    QWORD PTR [rsp+0x20],0x3
     ea1:	mov    rsi,QWORD PTR [rsp+0x78]
     ea6:	test   rsi,0x1
     ead:	je     ed7 <botlish_fn_15+0xe9>
     eb3:	mov    rsi,QWORD PTR [rsp+0x78]
     eb8:	mov    rcx,rsi
     ebb:	add    rcx,0x2
     ebf:	seto   dl
     ec2:	test   dl,dl
     ec4:	jne    ed7 <botlish_fn_15+0xe9>
     eca:	mov    rsi,rcx
     ecd:	mov    QWORD PTR [rsp+0x78],rcx
     ed2:	jmp    ef1 <botlish_fn_15+0x103>
     ed7:	mov    edx,0x3
     edc:	mov    rsi,QWORD PTR [rsp+0x78]
     ee1:	mov    rdi,r15
     ee4:	call   ee9 <botlish_fn_15+0xfb>
			ee5: R_X86_64_PLT32	rt_int_add-0x4
     ee9:	mov    rsi,rax
     eec:	mov    QWORD PTR [rsp+0x78],rax
     ef1:	mov    QWORD PTR [rsp+0x8],rsi
     ef6:	mov    QWORD PTR [rsp+0x58],0x0
     eff:	mov    QWORD PTR [rsp+0x60],r13
     f04:	mov    QWORD PTR [rsp+0x68],0x0
     f0d:	mov    QWORD PTR [rsp+0x70],r14
     f12:	mov    esi,0x2
     f17:	mov    edx,0x4
     f1c:	mov    rcx,r12
     f1f:	mov    rdi,r15
     f22:	call   f27 <botlish_fn_15+0x139>
			f23: R_X86_64_PLT32	rt_construct-0x4
     f27:	test   rax,rax
     f2a:	je     1103 <botlish_fn_15+0x315>
     f30:	mov    QWORD PTR [rsp],rbx
     f34:	mov    rsi,QWORD PTR [rsp+0x78]
     f39:	mov    QWORD PTR [rsp+0x8],rsi
     f3e:	mov    QWORD PTR [rsp+0x10],rax
     f43:	mov    r13,rax
     f46:	jmp    e54 <botlish_fn_15+0x66>
     f4b:	mov    QWORD PTR [rsp+0x20],0x3
     f54:	mov    rsi,QWORD PTR [rsp+0x78]
     f59:	test   rsi,0x1
     f60:	je     f7d <botlish_fn_15+0x18f>
     f66:	mov    rsi,QWORD PTR [rsp+0x78]
     f6b:	mov    rdx,rsi
     f6e:	add    rdx,0x2
     f72:	seto   al
     f75:	test   al,al
     f77:	je     f92 <botlish_fn_15+0x1a4>
     f7d:	mov    edx,0x3
     f82:	mov    rsi,QWORD PTR [rsp+0x78]
     f87:	mov    rdi,r15
     f8a:	call   f8f <botlish_fn_15+0x1a1>
			f8b: R_X86_64_PLT32	rt_int_add-0x4
     f8f:	mov    rdx,rax
     f92:	mov    rsi,rbx
     f95:	mov    rdi,r15
     f98:	call   f9d <botlish_fn_15+0x1af>
			f99: R_X86_64_PLT32	botlish_fn_13-0x4 ; quote_at?<str, int>
     f9d:	test   rax,rax
     fa0:	je     1103 <botlish_fn_15+0x315>
     fa6:	cmp    rax,0x6
     faa:	je     1069 <botlish_fn_15+0x27b>
     fb0:	xor    rsi,rsi
     fb3:	lea    rcx,[rsp+0x48]
     fb8:	mov    QWORD PTR [rsp+0x48],0x0
     fc1:	mov    QWORD PTR [rsp+0x50],r13
     fc6:	mov    edx,0x2
     fcb:	mov    rdi,r15
     fce:	call   fd3 <botlish_fn_15+0x1e5>
			fcf: R_X86_64_PLT32	rt_construct-0x4
     fd3:	test   rax,rax
     fd6:	je     1103 <botlish_fn_15+0x315>
     fdc:	mov    QWORD PTR [rsp],rax
     fe0:	mov    r12,rax
     fe3:	mov    QWORD PTR [rsp+0x10],0x3
     fec:	mov    rsi,QWORD PTR [rsp+0x78]
     ff1:	test   rsi,0x1
     ff8:	je     101d <botlish_fn_15+0x22f>
     ffe:	mov    rsi,QWORD PTR [rsp+0x78]
    1003:	mov    rdx,rsi
    1006:	add    rdx,0x2
    100a:	seto   al
    100d:	test   al,al
    100f:	jne    101d <botlish_fn_15+0x22f>
    1015:	mov    rax,r12
    1018:	jmp    1035 <botlish_fn_15+0x247>
    101d:	mov    edx,0x3
    1022:	mov    rsi,QWORD PTR [rsp+0x78]
    1027:	mov    rdi,r15
    102a:	call   102f <botlish_fn_15+0x241>
			102b: R_X86_64_PLT32	rt_int_add-0x4
    102f:	mov    rdx,rax
    1032:	mov    rax,r12
    1035:	mov    rbx,QWORD PTR [rsp+0x80]
    103d:	mov    r12,QWORD PTR [rsp+0x88]
    1045:	mov    r13,QWORD PTR [rsp+0x90]
    104d:	mov    r14,QWORD PTR [rsp+0x98]
    1055:	mov    r15,QWORD PTR [rsp+0xa0]
    105d:	add    rsp,0xb0
    1064:	mov    rsp,rbp
    1067:	pop    rbp
    1068:	ret
    1069:	mov    QWORD PTR [rsp+0x20],0x5
    1072:	mov    rsi,QWORD PTR [rsp+0x78]
    1077:	test   rsi,0x1
    107e:	je     10a8 <botlish_fn_15+0x2ba>
    1084:	mov    rsi,QWORD PTR [rsp+0x78]
    1089:	mov    rcx,rsi
    108c:	add    rcx,0x4
    1090:	seto   al
    1093:	test   al,al
    1095:	jne    10a8 <botlish_fn_15+0x2ba>
    109b:	mov    rsi,rcx
    109e:	mov    QWORD PTR [rsp+0x78],rcx
    10a3:	jmp    10c2 <botlish_fn_15+0x2d4>
    10a8:	mov    edx,0x5
    10ad:	mov    rsi,QWORD PTR [rsp+0x78]
    10b2:	mov    rdi,r15
    10b5:	call   10ba <botlish_fn_15+0x2cc>
			10b6: R_X86_64_PLT32	rt_int_add-0x4
    10ba:	mov    rsi,rax
    10bd:	mov    QWORD PTR [rsp+0x78],rax
    10c2:	mov    QWORD PTR [rsp+0x8],rsi
    10c7:	lea    rcx,[rsp+0x28]
    10cc:	mov    QWORD PTR [rsp+0x28],0x0
    10d5:	mov    QWORD PTR [rsp+0x30],r13
    10da:	mov    QWORD PTR [rsp+0x38],0x0
    10e3:	mov    QWORD PTR [rsp+0x40],r14
    10e8:	mov    esi,0x2
    10ed:	mov    edx,0x4
    10f2:	mov    rdi,r15
    10f5:	call   10fa <botlish_fn_15+0x30c>
			10f6: R_X86_64_PLT32	rt_construct-0x4
    10fa:	test   rax,rax
    10fd:	jne    113d <botlish_fn_15+0x34f>
    1103:	xor    rdx,rdx
    1106:	mov    rax,rdx
    1109:	mov    rbx,QWORD PTR [rsp+0x80]
    1111:	mov    r12,QWORD PTR [rsp+0x88]
    1119:	mov    r13,QWORD PTR [rsp+0x90]
    1121:	mov    r14,QWORD PTR [rsp+0x98]
    1129:	mov    r15,QWORD PTR [rsp+0xa0]
    1131:	add    rsp,0xb0
    1138:	mov    rsp,rbp
    113b:	pop    rbp
    113c:	ret
    113d:	mov    QWORD PTR [rsp],rbx
    1141:	mov    rsi,QWORD PTR [rsp+0x78]
    1146:	mov    QWORD PTR [rsp+0x8],rsi
    114b:	mov    QWORD PTR [rsp+0x10],rax
    1150:	mov    r13,rax
    1153:	jmp    e54 <botlish_fn_15+0x66>

0000000000001158 <botlish_entry_15: scan_quoted<str, int, str>>:
    1158:	push   rbp
    1159:	mov    rbp,rsp
    115c:	ud2

000000000000115e <botlish_fn_16: scan_field<str, int>>:
    115e:	push   rbp
    115f:	mov    rbp,rsp
    1162:	sub    rsp,0x40
    1166:	mov    QWORD PTR [rsp+0x20],rbx
    116b:	mov    QWORD PTR [rsp+0x28],r12
    1170:	mov    QWORD PTR [rsp+0x30],r13
    1175:	mov    r12,rdi
    1178:	mov    r13,rdx
    117b:	mov    QWORD PTR [rsp+0x10],0x0
    1184:	mov    QWORD PTR [rsp],rsi
    1188:	mov    rbx,rsi
    118b:	mov    QWORD PTR [rsp+0x8],rdx
    1190:	mov    rdx,r13
    1193:	mov    rsi,rbx
    1196:	mov    rdi,r12
    1199:	call   119e <botlish_fn_16+0x40>
			119a: R_X86_64_PLT32	botlish_fn_13-0x4 ; quote_at?<str, int>
    119e:	test   rax,rax
    11a1:	je     1251 <botlish_fn_16+0xf3>
    11a7:	cmp    rax,0x6
    11ab:	je     11e3 <botlish_fn_16+0x85>
    11b1:	mov    rcx,r13
    11b4:	mov    rsi,rbx
    11b7:	mov    rdi,r12
    11ba:	mov    rdx,rcx
    11bd:	call   11c2 <botlish_fn_16+0x64>
			11be: R_X86_64_PLT32	botlish_fn_14-0x4 ; scan_unquoted<str, int, int>
    11c2:	test   rax,rax
    11c5:	je     1251 <botlish_fn_16+0xf3>
    11cb:	mov    rbx,QWORD PTR [rsp+0x20]
    11d0:	mov    r12,QWORD PTR [rsp+0x28]
    11d5:	mov    r13,QWORD PTR [rsp+0x30]
    11da:	add    rsp,0x40
    11de:	mov    rsp,rbp
    11e1:	pop    rbp
    11e2:	ret
    11e3:	mov    rcx,r13
    11e6:	mov    QWORD PTR [rsp+0x10],0x3
    11ef:	test   rcx,0x1
    11f6:	jne    1204 <botlish_fn_16+0xa6>
    11fc:	mov    r13,rcx
    11ff:	jmp    1219 <botlish_fn_16+0xbb>
    1204:	mov    rdx,rcx
    1207:	add    rdx,0x2
    120b:	mov    r13,rcx
    120e:	seto   al
    1211:	test   al,al
    1213:	je     122c <botlish_fn_16+0xce>
    1219:	mov    edx,0x3
    121e:	mov    rsi,r13
    1221:	mov    rdi,r12
    1224:	call   1229 <botlish_fn_16+0xcb>
			1225: R_X86_64_PLT32	rt_int_add-0x4
    1229:	mov    rdx,rax
    122c:	mov    QWORD PTR [rsp+0x8],rdx
    1231:	mov    rdi,r12
    1234:	mov    rax,QWORD PTR [rdi+0x10]
    1238:	mov    rcx,QWORD PTR [rax]
    123b:	mov    QWORD PTR [rsp+0x10],rcx
    1240:	mov    rsi,rbx
    1243:	call   1248 <botlish_fn_16+0xea>
			1244: R_X86_64_PLT32	botlish_fn_15-0x4 ; scan_quoted<str, int, str>
    1248:	test   rax,rax
    124b:	jne    126f <botlish_fn_16+0x111>
    1251:	xor    rdx,rdx
    1254:	mov    rax,rdx
    1257:	mov    rbx,QWORD PTR [rsp+0x20]
    125c:	mov    r12,QWORD PTR [rsp+0x28]
    1261:	mov    r13,QWORD PTR [rsp+0x30]
    1266:	add    rsp,0x40
    126a:	mov    rsp,rbp
    126d:	pop    rbp
    126e:	ret
    126f:	mov    rbx,QWORD PTR [rsp+0x20]
    1274:	mov    r12,QWORD PTR [rsp+0x28]
    1279:	mov    r13,QWORD PTR [rsp+0x30]
    127e:	add    rsp,0x40
    1282:	mov    rsp,rbp
    1285:	pop    rbp
    1286:	ret

0000000000001287 <botlish_entry_16: scan_field<str, int>>:
    1287:	push   rbp
    1288:	mov    rbp,rsp
    128b:	ud2
    128d:	add    BYTE PTR [rax],al
	...

0000000000001290 <botlish_fn_17: scan_record_rest<str, int, mutarray, int>>:
    1290:	push   rbp
    1291:	mov    rbp,rsp
    1294:	sub    rsp,0x60
    1298:	mov    QWORD PTR [rsp+0x30],rbx
    129d:	mov    QWORD PTR [rsp+0x38],r12
    12a2:	mov    QWORD PTR [rsp+0x40],r13
    12a7:	mov    QWORD PTR [rsp+0x48],r14
    12ac:	mov    QWORD PTR [rsp+0x50],r15
    12b1:	mov    r13,rdi
    12b4:	mov    QWORD PTR [rsp+0x20],0x0
    12bd:	mov    QWORD PTR [rsp],rsi
    12c1:	mov    QWORD PTR [rsp+0x8],rdx
    12c6:	mov    QWORD PTR [rsp+0x10],rcx
    12cb:	mov    QWORD PTR [rsp+0x18],r8
    12d0:	mov    rbx,rsi
    12d3:	mov    r12,rdx
    12d6:	mov    r14,r8
    12d9:	mov    r15,rcx
    12dc:	mov    rdx,QWORD PTR [rbx+0x8]
    12e0:	shl    rdx,1
    12e3:	or     rdx,0x1
    12e7:	mov    rax,r12
    12ea:	and    rax,rdx
    12ed:	test   rax,0x1
    12f3:	jne    1319 <botlish_fn_17+0x89>
    12f9:	mov    rsi,r12
    12fc:	mov    rdi,r13
    12ff:	call   1304 <botlish_fn_17+0x74>
			1300: R_X86_64_PLT32	rt_int_cmp-0x4
    1304:	mov    ecx,0x2
    1309:	test   rax,rax
    130c:	cmovl  rcx,QWORD PTR [rip+0x24c]        # 1560 <botlish_fn_17+0x2d0>
    1314:	jmp    132c <botlish_fn_17+0x9c>
    1319:	mov    ecx,0x2
    131e:	mov    rax,r12
    1321:	cmp    rax,rdx
    1324:	cmovl  rcx,QWORD PTR [rip+0x234]        # 1560 <botlish_fn_17+0x2d0>
    132c:	cmp    rcx,0x6
    1330:	je     1344 <botlish_fn_17+0xb4>
    1336:	mov    rdx,r14
    1339:	mov    rsi,r15
    133c:	mov    rdi,r13
    133f:	jmp    137a <botlish_fn_17+0xea>
    1344:	mov    rdx,r12
    1347:	mov    rsi,rbx
    134a:	mov    rdi,r13
    134d:	call   1352 <botlish_fn_17+0xc2>
			134e: R_X86_64_PLT32	rt_str_char_at-0x4
    1352:	test   rax,rax
    1355:	je     14ba <botlish_fn_17+0x22a>
    135b:	cmp    rax,0x164
    1361:	je     1439 <botlish_fn_17+0x1a9>
    1367:	cmp    rax,0x54
    136b:	je     13b0 <botlish_fn_17+0x120>
    1371:	mov    rdx,r14
    1374:	mov    rsi,r15
    1377:	mov    rdi,r13
    137a:	mov    rdi,r13
    137d:	call   1382 <botlish_fn_17+0xf2>
			137e: R_X86_64_PLT32	botlish_fn_11-0x4 ; geo_finish<mutarray, int>
    1382:	test   rax,rax
    1385:	je     14ba <botlish_fn_17+0x22a>
    138b:	mov    rdx,r12
    138e:	mov    rbx,QWORD PTR [rsp+0x30]
    1393:	mov    r12,QWORD PTR [rsp+0x38]
    1398:	mov    r13,QWORD PTR [rsp+0x40]
    139d:	mov    r14,QWORD PTR [rsp+0x48]
    13a2:	mov    r15,QWORD PTR [rsp+0x50]
    13a7:	add    rsp,0x60
    13ab:	mov    rsp,rbp
    13ae:	pop    rbp
    13af:	ret
    13b0:	mov    rdx,r14
    13b3:	mov    rsi,r15
    13b6:	mov    rdi,r13
    13b9:	call   13be <botlish_fn_17+0x12e>
			13ba: R_X86_64_PLT32	botlish_fn_11-0x4 ; geo_finish<mutarray, int>
    13be:	test   rax,rax
    13c1:	je     14ba <botlish_fn_17+0x22a>
    13c7:	mov    QWORD PTR [rsp],rax
    13cb:	mov    r14,rax
    13ce:	mov    QWORD PTR [rsp+0x10],0x3
    13d7:	mov    rdx,r12
    13da:	test   rdx,0x1
    13e1:	je     1401 <botlish_fn_17+0x171>
    13e7:	mov    rdx,r12
    13ea:	add    rdx,0x2
    13ee:	seto   al
    13f1:	test   al,al
    13f3:	jne    1401 <botlish_fn_17+0x171>
    13f9:	mov    rax,r14
    13fc:	jmp    1417 <botlish_fn_17+0x187>
    1401:	mov    edx,0x3
    1406:	mov    rsi,r12
    1409:	mov    rdi,r13
    140c:	call   1411 <botlish_fn_17+0x181>
			140d: R_X86_64_PLT32	rt_int_add-0x4
    1411:	mov    rdx,rax
    1414:	mov    rax,r14
    1417:	mov    rbx,QWORD PTR [rsp+0x30]
    141c:	mov    r12,QWORD PTR [rsp+0x38]
    1421:	mov    r13,QWORD PTR [rsp+0x40]
    1426:	mov    r14,QWORD PTR [rsp+0x48]
    142b:	mov    r15,QWORD PTR [rsp+0x50]
    1430:	add    rsp,0x60
    1434:	mov    rsp,rbp
    1437:	pop    rbp
    1438:	ret
    1439:	mov    rsi,r12
    143c:	mov    edx,0x3
    1441:	mov    r12,rdx
    1444:	mov    QWORD PTR [rsp+0x20],0x3
    144d:	test   rsi,0x1
    1454:	je     146c <botlish_fn_17+0x1dc>
    145a:	mov    rdx,rsi
    145d:	add    rdx,0x2
    1461:	seto   al
    1464:	test   al,al
    1466:	je     147a <botlish_fn_17+0x1ea>
    146c:	mov    rdx,r12
    146f:	mov    rdi,r13
    1472:	call   1477 <botlish_fn_17+0x1e7>
			1473: R_X86_64_PLT32	rt_int_add-0x4
    1477:	mov    rdx,rax
    147a:	mov    QWORD PTR [rsp+0x8],rdx
    147f:	mov    rsi,rbx
    1482:	mov    rdi,r13
    1485:	call   148a <botlish_fn_17+0x1fa>
			1486: R_X86_64_PLT32	botlish_fn_16-0x4 ; scan_field<str, int>
    148a:	test   rax,rax
    148d:	je     14ba <botlish_fn_17+0x22a>
    1493:	mov    QWORD PTR [rsp+0x8],rax
    1498:	mov    rcx,rax
    149b:	mov    QWORD PTR [rsp+0x20],rdx
    14a0:	mov    rsi,r15
    14a3:	mov    r15,rdx
    14a6:	mov    rdx,r14
    14a9:	mov    rdi,r13
    14ac:	call   14b1 <botlish_fn_17+0x221>
			14ad: R_X86_64_PLT32	botlish_fn_8-0x4 ; geo_append<mutarray, int, str>
    14b1:	test   rax,rax
    14b4:	jne    14e2 <botlish_fn_17+0x252>
    14ba:	xor    rdx,rdx
    14bd:	mov    rax,rdx
    14c0:	mov    rbx,QWORD PTR [rsp+0x30]
    14c5:	mov    r12,QWORD PTR [rsp+0x38]
    14ca:	mov    r13,QWORD PTR [rsp+0x40]
    14cf:	mov    r14,QWORD PTR [rsp+0x48]
    14d4:	mov    r15,QWORD PTR [rsp+0x50]
    14d9:	add    rsp,0x60
    14dd:	mov    rsp,rbp
    14e0:	pop    rbp
    14e1:	ret
    14e2:	mov    QWORD PTR [rsp+0x8],rax
    14e7:	mov    QWORD PTR [rsp+0x28],rax
    14ec:	mov    QWORD PTR [rsp+0x10],0x3
    14f5:	mov    rdx,r14
    14f8:	test   rdx,0x1
    14ff:	jne    1510 <botlish_fn_17+0x280>
    1505:	mov    rdx,r12
    1508:	mov    rsi,r14
    150b:	jmp    152b <botlish_fn_17+0x29b>
    1510:	mov    rdx,r14
    1513:	mov    rax,rdx
    1516:	add    rax,0x2
    151a:	seto   cl
    151d:	test   cl,cl
    151f:	je     1533 <botlish_fn_17+0x2a3>
    1525:	mov    rdx,r12
    1528:	mov    rsi,r14
    152b:	mov    rdi,r13
    152e:	call   1533 <botlish_fn_17+0x2a3>
			152f: R_X86_64_PLT32	rt_int_add-0x4
    1533:	mov    QWORD PTR [rsp],rbx
    1537:	mov    rdx,r15
    153a:	mov    QWORD PTR [rsp+0x8],rdx
    153f:	mov    rcx,QWORD PTR [rsp+0x28]
    1544:	mov    QWORD PTR [rsp+0x10],rcx
    1549:	mov    QWORD PTR [rsp+0x18],rax
    154e:	mov    r12,rdx
    1551:	mov    r14,rax
    1554:	mov    r15,rcx
    1557:	jmp    12dc <botlish_fn_17+0x4c>
    155c:	add    BYTE PTR [rax],al
    155e:	add    BYTE PTR [rax],al
    1560:	(bad)
    1561:	add    BYTE PTR [rax],al
    1563:	add    BYTE PTR [rax],al
    1565:	add    BYTE PTR [rax],al
	...

0000000000001568 <botlish_entry_17: scan_record_rest<str, int, mutarray, int>>:
    1568:	push   rbp
    1569:	mov    rbp,rsp
    156c:	ud2

000000000000156e <botlish_fn_18: scan_record<str, int>>:
    156e:	push   rbp
    156f:	mov    rbp,rsp
    1572:	sub    rsp,0x40
    1576:	mov    QWORD PTR [rsp+0x20],rbx
    157b:	mov    QWORD PTR [rsp+0x28],r12
    1580:	mov    QWORD PTR [rsp+0x30],r14
    1585:	mov    r14,rdi
    1588:	mov    QWORD PTR [rsp+0x10],0x0
    1591:	mov    QWORD PTR [rsp+0x18],0x0
    159a:	mov    QWORD PTR [rsp],rsi
    159e:	mov    r12,rsi
    15a1:	mov    QWORD PTR [rsp+0x8],rdx
    15a6:	mov    rsi,r12
    15a9:	mov    rdi,r14
    15ac:	call   15b1 <botlish_fn_18+0x43>
			15ad: R_X86_64_PLT32	botlish_fn_16-0x4 ; scan_field<str, int>
    15b1:	test   rax,rax
    15b4:	je     1609 <botlish_fn_18+0x9b>
    15ba:	mov    QWORD PTR [rsp+0x8],rax
    15bf:	mov    rsi,rax
    15c2:	mov    QWORD PTR [rsp+0x10],rdx
    15c7:	mov    rbx,rdx
    15ca:	mov    rdi,r14
    15cd:	call   15d2 <botlish_fn_18+0x64>
			15ce: R_X86_64_PLT32	botlish_fn_1-0x4 ; geo_new<str>
    15d2:	test   rax,rax
    15d5:	je     1609 <botlish_fn_18+0x9b>
    15db:	mov    QWORD PTR [rsp+0x8],rax
    15e0:	mov    rcx,rax
    15e3:	mov    r8d,0x3
    15e9:	mov    QWORD PTR [rsp+0x18],0x3
    15f2:	mov    rdx,rbx
    15f5:	mov    rsi,r12
    15f8:	mov    rdi,r14
    15fb:	call   1600 <botlish_fn_18+0x92>
			15fc: R_X86_64_PLT32	botlish_fn_17-0x4 ; scan_record_rest<str, int, mutarray, int>
    1600:	test   rax,rax
    1603:	jne    1627 <botlish_fn_18+0xb9>
    1609:	xor    rdx,rdx
    160c:	mov    rax,rdx
    160f:	mov    rbx,QWORD PTR [rsp+0x20]
    1614:	mov    r12,QWORD PTR [rsp+0x28]
    1619:	mov    r14,QWORD PTR [rsp+0x30]
    161e:	add    rsp,0x40
    1622:	mov    rsp,rbp
    1625:	pop    rbp
    1626:	ret
    1627:	mov    rbx,QWORD PTR [rsp+0x20]
    162c:	mov    r12,QWORD PTR [rsp+0x28]
    1631:	mov    r14,QWORD PTR [rsp+0x30]
    1636:	add    rsp,0x40
    163a:	mov    rsp,rbp
    163d:	pop    rbp
    163e:	ret

000000000000163f <botlish_entry_18: scan_record<str, int>>:
    163f:	push   rbp
    1640:	mov    rbp,rsp
    1643:	ud2
    1645:	add    BYTE PTR [rax],al
	...

0000000000001648 <botlish_fn_19: scan_records<str, int, mutarray, int>>:
    1648:	push   rbp
    1649:	mov    rbp,rsp
    164c:	sub    rsp,0x60
    1650:	mov    QWORD PTR [rsp+0x30],rbx
    1655:	mov    QWORD PTR [rsp+0x38],r12
    165a:	mov    QWORD PTR [rsp+0x40],r13
    165f:	mov    QWORD PTR [rsp+0x48],r14
    1664:	mov    QWORD PTR [rsp+0x50],r15
    1669:	mov    r13,rdi
    166c:	mov    QWORD PTR [rsp+0x20],0x0
    1675:	mov    QWORD PTR [rsp],rsi
    1679:	mov    QWORD PTR [rsp+0x8],rdx
    167e:	mov    rax,rdx
    1681:	mov    QWORD PTR [rsp+0x10],rcx
    1686:	mov    QWORD PTR [rsp+0x18],r8
    168b:	mov    rbx,rsi
    168e:	mov    r14,r8
    1691:	mov    r15,rcx
    1694:	mov    rdx,QWORD PTR [rbx+0x8]
    1698:	shl    rdx,1
    169b:	or     rdx,0x1
    169f:	mov    r12,rax
    16a2:	and    rax,rdx
    16a5:	test   rax,0x1
    16ab:	jne    16d1 <botlish_fn_19+0x89>
    16b1:	mov    rsi,r12
    16b4:	mov    rdi,r13
    16b7:	call   16bc <botlish_fn_19+0x74>
			16b8: R_X86_64_PLT32	rt_int_cmp-0x4
    16bc:	mov    ecx,0x2
    16c1:	test   rax,rax
    16c4:	cmovge rcx,QWORD PTR [rip+0x12c]        # 17f8 <botlish_fn_19+0x1b0>
    16cc:	jmp    16e1 <botlish_fn_19+0x99>
    16d1:	mov    ecx,0x2
    16d6:	cmp    r12,rdx
    16d9:	cmovge rcx,QWORD PTR [rip+0x117]        # 17f8 <botlish_fn_19+0x1b0>
    16e1:	cmp    rcx,0x6
    16e5:	je     1793 <botlish_fn_19+0x14b>
    16eb:	mov    rdx,r12
    16ee:	mov    rsi,rbx
    16f1:	mov    rdi,r13
    16f4:	call   16f9 <botlish_fn_19+0xb1>
			16f5: R_X86_64_PLT32	botlish_fn_18-0x4 ; scan_record<str, int>
    16f9:	test   rax,rax
    16fc:	je     17aa <botlish_fn_19+0x162>
    1702:	mov    QWORD PTR [rsp+0x8],rax
    1707:	mov    rcx,rax
    170a:	mov    QWORD PTR [rsp+0x20],rdx
    170f:	mov    rsi,r15
    1712:	mov    r12,rdx
    1715:	mov    rdx,r14
    1718:	mov    rdi,r13
    171b:	call   1720 <botlish_fn_19+0xd8>
			171c: R_X86_64_PLT32	botlish_fn_9-0x4 ; geo_append<mutarray, int, List[str]>
    1720:	test   rax,rax
    1723:	je     17aa <botlish_fn_19+0x162>
    1729:	mov    QWORD PTR [rsp+0x8],rax
    172e:	mov    r15,rax
    1731:	mov    QWORD PTR [rsp+0x10],0x3
    173a:	mov    rsi,r14
    173d:	test   rsi,0x1
    1744:	je     175f <botlish_fn_19+0x117>
    174a:	mov    rsi,r14
    174d:	mov    rax,rsi
    1750:	add    rax,0x2
    1754:	seto   cl
    1757:	test   cl,cl
    1759:	je     176f <botlish_fn_19+0x127>
    175f:	mov    edx,0x3
    1764:	mov    rsi,r14
    1767:	mov    rdi,r13
    176a:	call   176f <botlish_fn_19+0x127>
			176b: R_X86_64_PLT32	rt_int_add-0x4
    176f:	mov    QWORD PTR [rsp],rbx
    1773:	mov    rdx,r12
    1776:	mov    QWORD PTR [rsp+0x8],rdx
    177b:	mov    rcx,r15
    177e:	mov    QWORD PTR [rsp+0x10],rcx
    1783:	mov    QWORD PTR [rsp+0x18],rax
    1788:	mov    r14,rax
    178b:	mov    rax,rdx
    178e:	jmp    1694 <botlish_fn_19+0x4c>
    1793:	mov    rdx,r14
    1796:	mov    rsi,r15
    1799:	mov    rdi,r13
    179c:	call   17a1 <botlish_fn_19+0x159>
			179d: R_X86_64_PLT32	botlish_fn_11-0x4 ; geo_finish<mutarray, int>
    17a1:	test   rax,rax
    17a4:	jne    17cf <botlish_fn_19+0x187>
    17aa:	xor    rax,rax
    17ad:	mov    rbx,QWORD PTR [rsp+0x30]
    17b2:	mov    r12,QWORD PTR [rsp+0x38]
    17b7:	mov    r13,QWORD PTR [rsp+0x40]
    17bc:	mov    r14,QWORD PTR [rsp+0x48]
    17c1:	mov    r15,QWORD PTR [rsp+0x50]
    17c6:	add    rsp,0x60
    17ca:	mov    rsp,rbp
    17cd:	pop    rbp
    17ce:	ret
    17cf:	mov    rbx,QWORD PTR [rsp+0x30]
    17d4:	mov    r12,QWORD PTR [rsp+0x38]
    17d9:	mov    r13,QWORD PTR [rsp+0x40]
    17de:	mov    r14,QWORD PTR [rsp+0x48]
    17e3:	mov    r15,QWORD PTR [rsp+0x50]
    17e8:	add    rsp,0x60
    17ec:	mov    rsp,rbp
    17ef:	pop    rbp
    17f0:	ret
    17f1:	add    BYTE PTR [rax],al
    17f3:	add    BYTE PTR [rax],al
    17f5:	add    BYTE PTR [rax],al
    17f7:	add    BYTE PTR [rsi],al
    17f9:	add    BYTE PTR [rax],al
    17fb:	add    BYTE PTR [rax],al
    17fd:	add    BYTE PTR [rax],al
	...

0000000000001800 <botlish_entry_19: scan_records<str, int, mutarray, int>>:
    1800:	push   rbp
    1801:	mov    rbp,rsp
    1804:	mov    rsi,QWORD PTR [rdx]
    1807:	mov    r9,QWORD PTR [rdx+0x8]
    180b:	mov    rcx,QWORD PTR [rdx+0x10]
    180f:	mov    r8,QWORD PTR [rdx+0x18]
    1813:	mov    rdx,r9
    1816:	call   181b <botlish_entry_19+0x1b>
			1817: R_X86_64_PLT32	botlish_fn_19-0x4 ; scan_records<str, int, mutarray, int>
    181b:	mov    rsp,rbp
    181e:	pop    rbp
    181f:	ret

0000000000001820 <botlish_fn_20: csv_parse<str>>:
    1820:	push   rbp
    1821:	mov    rbp,rsp
    1824:	sub    rsp,0x40
    1828:	mov    QWORD PTR [rsp+0x20],rbx
    182d:	mov    QWORD PTR [rsp+0x28],r12
    1832:	mov    QWORD PTR [rsp+0x30],r13
    1837:	mov    rbx,rdi
    183a:	mov    QWORD PTR [rsp+0x8],0x0
    1843:	mov    QWORD PTR [rsp+0x10],0x0
    184c:	mov    QWORD PTR [rsp+0x18],0x0
    1855:	mov    QWORD PTR [rsp],rsi
    1859:	mov    rax,QWORD PTR [rsi+0x8]
    185d:	mov    r12,rsi
    1860:	shl    rax,1
    1863:	or     rax,0x1
    1867:	sar    rax,1
    186a:	test   rax,rax
    186d:	je     18fc <botlish_fn_20+0xdc>
    1873:	mov    edx,0x1
    1878:	mov    QWORD PTR [rsp+0x8],0x1
    1881:	mov    rsi,r12
    1884:	mov    rdi,rbx
    1887:	call   188c <botlish_fn_20+0x6c>
			1888: R_X86_64_PLT32	botlish_fn_18-0x4 ; scan_record<str, int>
    188c:	test   rax,rax
    188f:	je     1913 <botlish_fn_20+0xf3>
    1895:	mov    QWORD PTR [rsp+0x8],rax
    189a:	mov    rsi,rax
    189d:	mov    QWORD PTR [rsp+0x10],rdx
    18a2:	mov    r13,rdx
    18a5:	mov    rdi,rbx
    18a8:	call   18ad <botlish_fn_20+0x8d>
			18a9: R_X86_64_PLT32	botlish_fn_2-0x4 ; geo_new<List[str]>
    18ad:	test   rax,rax
    18b0:	je     1913 <botlish_fn_20+0xf3>
    18b6:	mov    QWORD PTR [rsp+0x8],rax
    18bb:	mov    rcx,rax
    18be:	mov    r8d,0x3
    18c4:	mov    QWORD PTR [rsp+0x18],0x3
    18cd:	mov    rdx,r13
    18d0:	mov    rsi,r12
    18d3:	mov    rdi,rbx
    18d6:	call   18db <botlish_fn_20+0xbb>
			18d7: R_X86_64_PLT32	botlish_fn_19-0x4 ; scan_records<str, int, mutarray, int>
    18db:	test   rax,rax
    18de:	je     1913 <botlish_fn_20+0xf3>
    18e4:	mov    rbx,QWORD PTR [rsp+0x20]
    18e9:	mov    r12,QWORD PTR [rsp+0x28]
    18ee:	mov    r13,QWORD PTR [rsp+0x30]
    18f3:	add    rsp,0x40
    18f7:	mov    rsp,rbp
    18fa:	pop    rbp
    18fb:	ret
    18fc:	xor    rdx,rdx
    18ff:	mov    rdi,rbx
    1902:	mov    rsi,rdx
    1905:	call   190a <botlish_fn_20+0xea>
			1906: R_X86_64_PLT32	rt_list_new-0x4
    190a:	test   rax,rax
    190d:	jne    192e <botlish_fn_20+0x10e>
    1913:	xor    rax,rax
    1916:	mov    rbx,QWORD PTR [rsp+0x20]
    191b:	mov    r12,QWORD PTR [rsp+0x28]
    1920:	mov    r13,QWORD PTR [rsp+0x30]
    1925:	add    rsp,0x40
    1929:	mov    rsp,rbp
    192c:	pop    rbp
    192d:	ret
    192e:	mov    rbx,QWORD PTR [rsp+0x20]
    1933:	mov    r12,QWORD PTR [rsp+0x28]
    1938:	mov    r13,QWORD PTR [rsp+0x30]
    193d:	add    rsp,0x40
    1941:	mov    rsp,rbp
    1944:	pop    rbp
    1945:	ret

0000000000001946 <botlish_entry_20: csv_parse<str>>:
    1946:	push   rbp
    1947:	mov    rbp,rsp
    194a:	mov    rsi,QWORD PTR [rdx]
    194d:	call   1952 <botlish_entry_20+0xc>
			194e: R_X86_64_PLT32	botlish_fn_20-0x4 ; csv_parse<str>
    1952:	mov    rsp,rbp
    1955:	pop    rbp
    1956:	ret

0000000000001957 <botlish_fn_21: ht_alloc<int>>:
    1957:	push   rbp
    1958:	mov    rbp,rsp
    195b:	sub    rsp,0x70
    195f:	mov    QWORD PTR [rsp+0x40],rbx
    1964:	mov    QWORD PTR [rsp+0x48],r12
    1969:	mov    QWORD PTR [rsp+0x50],r13
    196e:	mov    QWORD PTR [rsp+0x58],r14
    1973:	mov    QWORD PTR [rsp+0x60],r15
    1978:	mov    r12,rdi
    197b:	mov    QWORD PTR [rsp+0x10],0x0
    1984:	mov    QWORD PTR [rsp+0x18],0x0
    198d:	mov    QWORD PTR [rsp],rsi
    1991:	mov    r13,rsi
    1994:	mov    esi,0x5
    1999:	mov    QWORD PTR [rsp+0x8],0x5
    19a2:	mov    rdi,r12
    19a5:	call   19aa <botlish_fn_21+0x53>
			19a6: R_X86_64_PLT32	rt_mutarray_allocate-0x4
    19aa:	mov    rcx,rax
    19ad:	mov    r14,rax
    19b0:	test   rax,rcx
    19b3:	je     1a42 <botlish_fn_21+0xeb>
    19b9:	mov    rax,r14
    19bc:	mov    QWORD PTR [rsp+0x8],rax
    19c1:	mov    ebx,0x1
    19c6:	mov    rcx,rbx
    19c9:	mov    rdx,rbx
    19cc:	mov    rsi,r14
    19cf:	mov    rdi,r12
    19d2:	call   19d7 <botlish_fn_21+0x80>
			19d3: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
    19d7:	mov    edx,0x3
    19dc:	mov    rcx,rbx
    19df:	mov    rsi,r14
    19e2:	mov    rdi,r12
    19e5:	call   19ea <botlish_fn_21+0x93>
			19e6: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
    19ea:	mov    QWORD PTR [rsp+0x10],0x1
    19f3:	mov    rdx,rbx
    19f6:	mov    rsi,r13
    19f9:	mov    rdi,r12
    19fc:	call   1a01 <botlish_fn_21+0xaa>
			19fd: R_X86_64_PLT32	rt_mutarray_create-0x4
    1a01:	test   rax,rax
    1a04:	je     1a42 <botlish_fn_21+0xeb>
    1a0a:	mov    QWORD PTR [rsp+0x10],rax
    1a0f:	mov    rbx,rax
    1a12:	mov    rsi,r13
    1a15:	mov    rdi,r12
    1a18:	call   1a1d <botlish_fn_21+0xc6>
			1a19: R_X86_64_PLT32	rt_mutarray_allocate-0x4
    1a1d:	test   rax,rax
    1a20:	je     1a42 <botlish_fn_21+0xeb>
    1a26:	mov    QWORD PTR [rsp+0x18],rax
    1a2b:	mov    rsi,r13
    1a2e:	mov    r15,rax
    1a31:	mov    rdi,r12
    1a34:	call   1a39 <botlish_fn_21+0xe2>
			1a35: R_X86_64_PLT32	rt_mutarray_allocate-0x4
    1a39:	test   rax,rax
    1a3c:	jne    1a67 <botlish_fn_21+0x110>
    1a42:	xor    rax,rax
    1a45:	mov    rbx,QWORD PTR [rsp+0x40]
    1a4a:	mov    r12,QWORD PTR [rsp+0x48]
    1a4f:	mov    r13,QWORD PTR [rsp+0x50]
    1a54:	mov    r14,QWORD PTR [rsp+0x58]
    1a59:	mov    r15,QWORD PTR [rsp+0x60]
    1a5e:	add    rsp,0x70
    1a62:	mov    rsp,rbp
    1a65:	pop    rbp
    1a66:	ret
    1a67:	mov    QWORD PTR [rsp],rax
    1a6b:	lea    rcx,[rsp+0x20]
    1a70:	mov    rdx,rbx
    1a73:	mov    QWORD PTR [rsp+0x20],rdx
    1a78:	mov    rsi,r15
    1a7b:	mov    QWORD PTR [rsp+0x28],rsi
    1a80:	mov    QWORD PTR [rsp+0x30],rax
    1a85:	mov    rax,r14
    1a88:	mov    QWORD PTR [rsp+0x38],rax
    1a8d:	xor    rsi,rsi
    1a90:	mov    edx,0x4
    1a95:	mov    rdi,r12
    1a98:	call   1a9d <botlish_fn_21+0x146>
			1a99: R_X86_64_PLT32	rt_struct_new-0x4
    1a9d:	mov    rbx,QWORD PTR [rsp+0x40]
    1aa2:	mov    r12,QWORD PTR [rsp+0x48]
    1aa7:	mov    r13,QWORD PTR [rsp+0x50]
    1aac:	mov    r14,QWORD PTR [rsp+0x58]
    1ab1:	mov    r15,QWORD PTR [rsp+0x60]
    1ab6:	add    rsp,0x70
    1aba:	mov    rsp,rbp
    1abd:	pop    rbp
    1abe:	ret

0000000000001abf <botlish_entry_21: ht_alloc<int>>:
    1abf:	push   rbp
    1ac0:	mov    rbp,rsp
    1ac3:	mov    rsi,QWORD PTR [rdx]
    1ac6:	call   1acb <botlish_entry_21+0xc>
			1ac7: R_X86_64_PLT32	botlish_fn_21-0x4 ; ht_alloc<int>
    1acb:	mov    rsp,rbp
    1ace:	pop    rbp
    1acf:	ret

0000000000001ad0 <botlish_fn_22: ht_alloc<int>>:
    1ad0:	push   rbp
    1ad1:	mov    rbp,rsp
    1ad4:	sub    rsp,0x60
    1ad8:	mov    QWORD PTR [rsp+0x30],rbx
    1add:	mov    QWORD PTR [rsp+0x38],r12
    1ae2:	mov    QWORD PTR [rsp+0x40],r13
    1ae7:	mov    QWORD PTR [rsp+0x48],r14
    1aec:	mov    QWORD PTR [rsp+0x50],r15
    1af1:	mov    r13,rdi
    1af4:	mov    r15,rdx
    1af7:	mov    QWORD PTR [rsp+0x10],0x0
    1b00:	mov    QWORD PTR [rsp+0x18],0x0
    1b09:	mov    QWORD PTR [rsp],rsi
    1b0d:	mov    r12,rsi
    1b10:	mov    esi,0x5
    1b15:	mov    QWORD PTR [rsp+0x8],0x5
    1b1e:	mov    rdi,r13
    1b21:	call   1b26 <botlish_fn_22+0x56>
			1b22: R_X86_64_PLT32	rt_mutarray_allocate-0x4
    1b26:	mov    rcx,rax
    1b29:	mov    r14,rax
    1b2c:	test   rax,rcx
    1b2f:	je     1bc0 <botlish_fn_22+0xf0>
    1b35:	mov    rax,r14
    1b38:	mov    QWORD PTR [rsp+0x8],rax
    1b3d:	mov    ebx,0x1
    1b42:	mov    rcx,rbx
    1b45:	mov    rdx,rbx
    1b48:	mov    rsi,r14
    1b4b:	mov    rdi,r13
    1b4e:	call   1b53 <botlish_fn_22+0x83>
			1b4f: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
    1b53:	mov    edx,0x3
    1b58:	mov    rcx,rbx
    1b5b:	mov    rsi,r14
    1b5e:	mov    rdi,r13
    1b61:	call   1b66 <botlish_fn_22+0x96>
			1b62: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
    1b66:	mov    QWORD PTR [rsp+0x10],0x1
    1b6f:	mov    rdx,rbx
    1b72:	mov    rsi,r12
    1b75:	mov    rdi,r13
    1b78:	call   1b7d <botlish_fn_22+0xad>
			1b79: R_X86_64_PLT32	rt_mutarray_create-0x4
    1b7d:	test   rax,rax
    1b80:	je     1bc0 <botlish_fn_22+0xf0>
    1b86:	mov    QWORD PTR [rsp+0x10],rax
    1b8b:	mov    rbx,rax
    1b8e:	mov    rsi,r12
    1b91:	mov    rdi,r13
    1b94:	call   1b99 <botlish_fn_22+0xc9>
			1b95: R_X86_64_PLT32	rt_mutarray_allocate-0x4
    1b99:	test   rax,rax
    1b9c:	je     1bc0 <botlish_fn_22+0xf0>
    1ba2:	mov    QWORD PTR [rsp+0x18],rax
    1ba7:	mov    rsi,r12
    1baa:	mov    rdi,r13
    1bad:	mov    QWORD PTR [rsp+0x20],rax
    1bb2:	call   1bb7 <botlish_fn_22+0xe7>
			1bb3: R_X86_64_PLT32	rt_mutarray_allocate-0x4
    1bb7:	test   rax,rax
    1bba:	jne    1be5 <botlish_fn_22+0x115>
    1bc0:	xor    rax,rax
    1bc3:	mov    rbx,QWORD PTR [rsp+0x30]
    1bc8:	mov    r12,QWORD PTR [rsp+0x38]
    1bcd:	mov    r13,QWORD PTR [rsp+0x40]
    1bd2:	mov    r14,QWORD PTR [rsp+0x48]
    1bd7:	mov    r15,QWORD PTR [rsp+0x50]
    1bdc:	add    rsp,0x60
    1be0:	mov    rsp,rbp
    1be3:	pop    rbp
    1be4:	ret
    1be5:	mov    rcx,QWORD PTR [rsp+0x20]
    1bea:	mov    rdx,r15
    1bed:	mov    QWORD PTR [rdx],rcx
    1bf0:	mov    QWORD PTR [rdx+0x8],rax
    1bf4:	mov    rax,r14
    1bf7:	mov    QWORD PTR [rdx+0x10],rax
    1bfb:	mov    rax,rbx
    1bfe:	mov    rbx,QWORD PTR [rsp+0x30]
    1c03:	mov    r12,QWORD PTR [rsp+0x38]
    1c08:	mov    r13,QWORD PTR [rsp+0x40]
    1c0d:	mov    r14,QWORD PTR [rsp+0x48]
    1c12:	mov    r15,QWORD PTR [rsp+0x50]
    1c17:	add    rsp,0x60
    1c1b:	mov    rsp,rbp
    1c1e:	pop    rbp
    1c1f:	ret

0000000000001c20 <botlish_entry_22: ht_alloc<int>>:
    1c20:	push   rbp
    1c21:	mov    rbp,rsp
    1c24:	ud2

0000000000001c26 <botlish_fn_23: ht_new<generic>>:
    1c26:	push   rbp
    1c27:	mov    rbp,rsp
    1c2a:	sub    rsp,0x10
    1c2e:	mov    esi,0x11
    1c33:	mov    QWORD PTR [rsp],0x11
    1c3b:	call   1c40 <botlish_fn_23+0x1a>
			1c3c: R_X86_64_PLT32	botlish_fn_21-0x4 ; ht_alloc<int>
    1c40:	test   rax,rax
    1c43:	jne    1c55 <botlish_fn_23+0x2f>
    1c49:	xor    rax,rax
    1c4c:	add    rsp,0x10
    1c50:	mov    rsp,rbp
    1c53:	pop    rbp
    1c54:	ret
    1c55:	add    rsp,0x10
    1c59:	mov    rsp,rbp
    1c5c:	pop    rbp
    1c5d:	ret

0000000000001c5e <botlish_entry_23: ht_new<generic>>:
    1c5e:	push   rbp
    1c5f:	mov    rbp,rsp
    1c62:	call   1c67 <botlish_entry_23+0x9>
			1c63: R_X86_64_PLT32	botlish_fn_23-0x4 ; ht_new<generic>
    1c67:	mov    rsp,rbp
    1c6a:	pop    rbp
    1c6b:	ret
    1c6c:	add    BYTE PTR [rax],al
	...

0000000000001c70 <botlish_fn_24: ht_capacity_for<int, int>>:
    1c70:	push   rbp
    1c71:	mov    rbp,rsp
    1c74:	sub    rsp,0x50
    1c78:	mov    QWORD PTR [rsp+0x20],rbx
    1c7d:	mov    QWORD PTR [rsp+0x28],r12
    1c82:	mov    QWORD PTR [rsp+0x30],r13
    1c87:	mov    QWORD PTR [rsp+0x38],r14
    1c8c:	mov    QWORD PTR [rsp+0x40],r15
    1c91:	mov    r13,rdi
    1c94:	mov    QWORD PTR [rsp],rdx
    1c98:	mov    rbx,rsi
    1c9b:	or     rbx,0x1
    1c9f:	sar    rbx,1
    1ca2:	mov    r12,rsi
    1ca5:	mov    r14,rdx
    1ca8:	mov    rax,r12
    1cab:	or     rax,0x1
    1caf:	mov    QWORD PTR [rsp+0x8],rax
    1cb4:	mov    QWORD PTR [rsp+0x10],0x7
    1cbd:	mov    rax,rbx
    1cc0:	imul   QWORD PTR [rip+0x159]        # 1e20 <botlish_fn_24+0x1b0>
    1cc7:	seto   cl
    1cca:	or     rax,0x1
    1cce:	test   cl,cl
    1cd0:	jne    1cde <botlish_fn_24+0x6e>
    1cd6:	mov    rsi,rax
    1cd9:	jmp    1cf5 <botlish_fn_24+0x85>
    1cde:	mov    rsi,r12
    1ce1:	or     rsi,0x1
    1ce5:	mov    edx,0x7
    1cea:	mov    rdi,r13
    1ced:	call   1cf2 <botlish_fn_24+0x82>
			1cee: R_X86_64_PLT32	rt_int_mul-0x4
    1cf2:	mov    rsi,rax
    1cf5:	mov    QWORD PTR [rsp+0x8],rsi
    1cfa:	mov    r15,rsi
    1cfd:	mov    QWORD PTR [rsp+0x10],0x5
    1d06:	mov    rsi,r14
    1d09:	test   rsi,0x1
    1d10:	je     1d40 <botlish_fn_24+0xd0>
    1d16:	mov    rsi,r14
    1d19:	mov    rax,rsi
    1d1c:	sar    rax,1
    1d1f:	imul   QWORD PTR [rip+0x102]        # 1e28 <botlish_fn_24+0x1b8>
    1d26:	seto   cl
    1d29:	or     rax,0x1
    1d2d:	test   cl,cl
    1d2f:	jne    1d40 <botlish_fn_24+0xd0>
    1d35:	mov    rdx,rax
    1d38:	mov    rsi,r15
    1d3b:	jmp    1d56 <botlish_fn_24+0xe6>
    1d40:	mov    edx,0x5
    1d45:	mov    rsi,r14
    1d48:	mov    rdi,r13
    1d4b:	call   1d50 <botlish_fn_24+0xe0>
			1d4c: R_X86_64_PLT32	rt_int_mul-0x4
    1d50:	mov    rdx,rax
    1d53:	mov    rsi,r15
    1d56:	mov    rax,rsi
    1d59:	and    rax,rdx
    1d5c:	test   rax,0x1
    1d62:	jne    1d85 <botlish_fn_24+0x115>
    1d68:	mov    rdi,r13
    1d6b:	call   1d70 <botlish_fn_24+0x100>
			1d6c: R_X86_64_PLT32	rt_int_cmp-0x4
    1d70:	mov    ecx,0x2
    1d75:	test   rax,rax
    1d78:	cmovle rcx,QWORD PTR [rip+0xa0]        # 1e20 <botlish_fn_24+0x1b0>
    1d80:	jmp    1d95 <botlish_fn_24+0x125>
    1d85:	mov    ecx,0x2
    1d8a:	cmp    rsi,rdx
    1d8d:	cmovle rcx,QWORD PTR [rip+0x8b]        # 1e20 <botlish_fn_24+0x1b0>
    1d95:	cmp    rcx,0x6
    1d99:	je     1df5 <botlish_fn_24+0x185>
    1d9f:	mov    QWORD PTR [rsp+0x8],0x5
    1da8:	mov    rsi,r14
    1dab:	test   rsi,0x1
    1db2:	je     1dd9 <botlish_fn_24+0x169>
    1db8:	mov    rsi,r14
    1dbb:	mov    rax,rsi
    1dbe:	sar    rax,1
    1dc1:	imul   QWORD PTR [rip+0x60]        # 1e28 <botlish_fn_24+0x1b8>
    1dc8:	seto   sil
    1dcc:	or     rax,0x1
    1dd0:	test   sil,sil
    1dd3:	je     1de9 <botlish_fn_24+0x179>
    1dd9:	mov    edx,0x5
    1dde:	mov    rsi,r14
    1de1:	mov    rdi,r13
    1de4:	call   1de9 <botlish_fn_24+0x179>
			1de5: R_X86_64_PLT32	rt_int_mul-0x4
    1de9:	mov    QWORD PTR [rsp],rax
    1ded:	mov    r14,rax
    1df0:	jmp    1ca8 <botlish_fn_24+0x38>
    1df5:	mov    rax,r14
    1df8:	mov    rbx,QWORD PTR [rsp+0x20]
    1dfd:	mov    r12,QWORD PTR [rsp+0x28]
    1e02:	mov    r13,QWORD PTR [rsp+0x30]
    1e07:	mov    r14,QWORD PTR [rsp+0x38]
    1e0c:	mov    r15,QWORD PTR [rsp+0x40]
    1e11:	add    rsp,0x50
    1e15:	mov    rsp,rbp
    1e18:	pop    rbp
    1e19:	ret
    1e1a:	add    BYTE PTR [rax],al
    1e1c:	add    BYTE PTR [rax],al
    1e1e:	add    BYTE PTR [rax],al
    1e20:	(bad)
    1e21:	add    BYTE PTR [rax],al
    1e23:	add    BYTE PTR [rax],al
    1e25:	add    BYTE PTR [rax],al
    1e27:	add    BYTE PTR [rax+rax*1],al
    1e2a:	add    BYTE PTR [rax],al
    1e2c:	add    BYTE PTR [rax],al
	...

0000000000001e30 <botlish_entry_24: ht_capacity_for<int, int>>:
    1e30:	push   rbp
    1e31:	mov    rbp,rsp
    1e34:	mov    rsi,QWORD PTR [rdx]
    1e37:	mov    rdx,QWORD PTR [rdx+0x8]
    1e3b:	call   1e40 <botlish_entry_24+0x10>
			1e3c: R_X86_64_PLT32	botlish_fn_24-0x4 ; ht_capacity_for<int, int>
    1e40:	mov    rsp,rbp
    1e43:	pop    rbp
    1e44:	ret

0000000000001e45 <botlish_fn_25: ht_new_sized<int>>:
    1e45:	push   rbp
    1e46:	mov    rbp,rsp
    1e49:	sub    rsp,0x20
    1e4d:	mov    QWORD PTR [rsp+0x10],r12
    1e52:	mov    r12,rdi
    1e55:	mov    QWORD PTR [rsp],rsi
    1e59:	mov    edx,0x11
    1e5e:	mov    QWORD PTR [rsp+0x8],0x11
    1e67:	mov    rdi,r12
    1e6a:	call   1e6f <botlish_fn_25+0x2a>
			1e6b: R_X86_64_PLT32	botlish_fn_24-0x4 ; ht_capacity_for<int, int>
    1e6f:	mov    QWORD PTR [rsp],rax
    1e73:	mov    rsi,rax
    1e76:	mov    rdi,r12
    1e79:	call   1e7e <botlish_fn_25+0x39>
			1e7a: R_X86_64_PLT32	botlish_fn_21-0x4 ; ht_alloc<int>
    1e7e:	test   rax,rax
    1e81:	jne    1e98 <botlish_fn_25+0x53>
    1e87:	xor    rax,rax
    1e8a:	mov    r12,QWORD PTR [rsp+0x10]
    1e8f:	add    rsp,0x20
    1e93:	mov    rsp,rbp
    1e96:	pop    rbp
    1e97:	ret
    1e98:	mov    r12,QWORD PTR [rsp+0x10]
    1e9d:	add    rsp,0x20
    1ea1:	mov    rsp,rbp
    1ea4:	pop    rbp
    1ea5:	ret

0000000000001ea6 <botlish_entry_25: ht_new_sized<int>>:
    1ea6:	push   rbp
    1ea7:	mov    rbp,rsp
    1eaa:	mov    rsi,QWORD PTR [rdx]
    1ead:	call   1eb2 <botlish_entry_25+0xc>
			1eae: R_X86_64_PLT32	botlish_fn_25-0x4 ; ht_new_sized<int>
    1eb2:	mov    rsp,rbp
    1eb5:	pop    rbp
    1eb6:	ret

0000000000001eb7 <botlish_fn_26: ht_size<HashTable>>:
    1eb7:	push   rbp
    1eb8:	mov    rbp,rsp
    1ebb:	mov    r9,QWORD PTR [rsi+0x18]
    1ebf:	mov    rsi,QWORD PTR [r9+0x18]
    1ec3:	mov    edx,0x1
    1ec8:	call   1ecd <botlish_fn_26+0x16>
			1ec9: R_X86_64_PLT32	rt_mutarray_get-0x4
    1ecd:	test   rax,rax
    1ed0:	jne    1ede <botlish_fn_26+0x27>
    1ed6:	xor    rax,rax
    1ed9:	mov    rsp,rbp
    1edc:	pop    rbp
    1edd:	ret
    1ede:	mov    rsp,rbp
    1ee1:	pop    rbp
    1ee2:	ret

0000000000001ee3 <botlish_entry_26: ht_size<HashTable>>:
    1ee3:	push   rbp
    1ee4:	mov    rbp,rsp
    1ee7:	mov    rsi,QWORD PTR [rdx]
    1eea:	call   1eef <botlish_entry_26+0xc>
			1eeb: R_X86_64_PLT32	botlish_fn_26-0x4 ; ht_size<HashTable>
    1eef:	mov    rsp,rbp
    1ef2:	pop    rbp
    1ef3:	ret

0000000000001ef4 <botlish_fn_27: ht_tombstones<HashTable>>:
    1ef4:	push   rbp
    1ef5:	mov    rbp,rsp
    1ef8:	mov    r9,QWORD PTR [rsi+0x18]
    1efc:	mov    rsi,QWORD PTR [r9+0x18]
    1f00:	mov    edx,0x3
    1f05:	call   1f0a <botlish_fn_27+0x16>
			1f06: R_X86_64_PLT32	rt_mutarray_get-0x4
    1f0a:	test   rax,rax
    1f0d:	jne    1f1b <botlish_fn_27+0x27>
    1f13:	xor    rax,rax
    1f16:	mov    rsp,rbp
    1f19:	pop    rbp
    1f1a:	ret
    1f1b:	mov    rsp,rbp
    1f1e:	pop    rbp
    1f1f:	ret

0000000000001f20 <botlish_entry_27: ht_tombstones<HashTable>>:
    1f20:	push   rbp
    1f21:	mov    rbp,rsp
    1f24:	mov    rsi,QWORD PTR [rdx]
    1f27:	call   1f2c <botlish_entry_27+0xc>
			1f28: R_X86_64_PLT32	botlish_fn_27-0x4 ; ht_tombstones<HashTable>
    1f2c:	mov    rsp,rbp
    1f2f:	pop    rbp
    1f30:	ret

0000000000001f31 <botlish_fn_28: ht_capacity<HashTable>>:
    1f31:	push   rbp
    1f32:	mov    rbp,rsp
    1f35:	mov    rsi,QWORD PTR [rsi+0x18]
    1f39:	mov    rsi,QWORD PTR [rsi]
    1f3c:	call   1f41 <botlish_fn_28+0x10>
			1f3d: R_X86_64_PLT32	rt_mutarray_capacity-0x4
    1f41:	mov    rsp,rbp
    1f44:	pop    rbp
    1f45:	ret

0000000000001f46 <botlish_entry_28: ht_capacity<HashTable>>:
    1f46:	push   rbp
    1f47:	mov    rbp,rsp
    1f4a:	mov    rsi,QWORD PTR [rdx]
    1f4d:	call   1f52 <botlish_entry_28+0xc>
			1f4e: R_X86_64_PLT32	botlish_fn_28-0x4 ; ht_capacity<HashTable>
    1f52:	mov    rsp,rbp
    1f55:	pop    rbp
    1f56:	ret

0000000000001f57 <botlish_fn_29: ht_probe_start<HashTable, str>>:
    1f57:	push   rbp
    1f58:	mov    rbp,rsp
    1f5b:	sub    rsp,0x30
    1f5f:	mov    QWORD PTR [rsp+0x10],r12
    1f64:	mov    QWORD PTR [rsp+0x18],r13
    1f69:	mov    QWORD PTR [rsp+0x20],r14
    1f6e:	mov    r12,rdi
    1f71:	mov    r14,rsi
    1f74:	mov    rsi,rdx
    1f77:	mov    rdi,r12
    1f7a:	call   1f7f <botlish_fn_29+0x28>
			1f7b: R_X86_64_PLT32	rt_hash-0x4
    1f7f:	test   rax,rax
    1f82:	je     1fb6 <botlish_fn_29+0x5f>
    1f88:	mov    QWORD PTR [rsp],rax
    1f8c:	mov    rsi,r14
    1f8f:	mov    r13,rax
    1f92:	mov    rdi,r12
    1f95:	call   1f9a <botlish_fn_29+0x43>
			1f96: R_X86_64_PLT32	botlish_fn_28-0x4 ; ht_capacity<HashTable>
    1f9a:	mov    QWORD PTR [rsp+0x8],rax
    1f9f:	mov    rdx,rax
    1fa2:	mov    rsi,r13
    1fa5:	mov    rdi,r12
    1fa8:	call   1fad <botlish_fn_29+0x56>
			1fa9: R_X86_64_PLT32	rt_int_mod-0x4
    1fad:	test   rax,rax
    1fb0:	jne    1fd1 <botlish_fn_29+0x7a>
    1fb6:	xor    rax,rax
    1fb9:	mov    r12,QWORD PTR [rsp+0x10]
    1fbe:	mov    r13,QWORD PTR [rsp+0x18]
    1fc3:	mov    r14,QWORD PTR [rsp+0x20]
    1fc8:	add    rsp,0x30
    1fcc:	mov    rsp,rbp
    1fcf:	pop    rbp
    1fd0:	ret
    1fd1:	mov    r12,QWORD PTR [rsp+0x10]
    1fd6:	mov    r13,QWORD PTR [rsp+0x18]
    1fdb:	mov    r14,QWORD PTR [rsp+0x20]
    1fe0:	add    rsp,0x30
    1fe4:	mov    rsp,rbp
    1fe7:	pop    rbp
    1fe8:	ret

0000000000001fe9 <botlish_entry_29: ht_probe_start<HashTable, str>>:
    1fe9:	push   rbp
    1fea:	mov    rbp,rsp
    1fed:	mov    rsi,QWORD PTR [rdx]
    1ff0:	mov    rdx,QWORD PTR [rdx+0x8]
    1ff4:	call   1ff9 <botlish_entry_29+0x10>
			1ff5: R_X86_64_PLT32	botlish_fn_29-0x4 ; ht_probe_start<HashTable, str>
    1ff9:	mov    rsp,rbp
    1ffc:	pop    rbp
    1ffd:	ret

0000000000001ffe <botlish_fn_30: ht_probe_next<HashTable, int>>:
    1ffe:	push   rbp
    1fff:	mov    rbp,rsp
    2002:	sub    rsp,0x20
    2006:	mov    QWORD PTR [rsp+0x10],rbx
    200b:	mov    QWORD PTR [rsp+0x18],r14
    2010:	mov    r14,rdi
    2013:	lea    r11,[rdx+0x1]
    2017:	shl    r11,1
    201a:	or     r11,0x1
    201e:	mov    QWORD PTR [rsp],r11
    2022:	mov    rbx,r11
    2025:	mov    rdi,r14
    2028:	call   202d <botlish_fn_30+0x2f>
			2029: R_X86_64_PLT32	botlish_fn_28-0x4 ; ht_capacity<HashTable>
    202d:	mov    QWORD PTR [rsp+0x8],rax
    2032:	mov    rdx,rax
    2035:	mov    rsi,rbx
    2038:	mov    rdi,r14
    203b:	call   2040 <botlish_fn_30+0x42>
			203c: R_X86_64_PLT32	rt_int_mod-0x4
    2040:	test   rax,rax
    2043:	jne    2062 <botlish_fn_30+0x64>
    2049:	xor    rdx,rdx
    204c:	mov    rax,rdx
    204f:	mov    rbx,QWORD PTR [rsp+0x10]
    2054:	mov    r14,QWORD PTR [rsp+0x18]
    2059:	add    rsp,0x20
    205d:	mov    rsp,rbp
    2060:	pop    rbp
    2061:	ret
    2062:	mov    edx,0x1
    2067:	sar    rax,1
    206a:	mov    rbx,QWORD PTR [rsp+0x10]
    206f:	mov    r14,QWORD PTR [rsp+0x18]
    2074:	add    rsp,0x20
    2078:	mov    rsp,rbp
    207b:	pop    rbp
    207c:	ret

000000000000207d <botlish_entry_30: ht_probe_next<HashTable, int>>:
    207d:	push   rbp
    207e:	mov    rbp,rsp
    2081:	mov    rsi,QWORD PTR [rdx]
    2084:	mov    rdx,QWORD PTR [rdx+0x8]
    2088:	sar    rdx,1
    208b:	call   2090 <botlish_entry_30+0x13>
			208c: R_X86_64_PLT32	botlish_fn_30-0x4 ; ht_probe_next<HashTable, int>
    2090:	shl    rax,1
    2093:	or     rax,0x1
    2097:	mov    rcx,rax
    209a:	xor    rax,rax
    209d:	test   rdx,rdx
    20a0:	cmovne rax,rcx
    20a4:	mov    rsp,rbp
    20a7:	pop    rbp
    20a8:	ret
    20a9:	add    BYTE PTR [rax],al
    20ab:	add    BYTE PTR [rax],al
    20ad:	add    BYTE PTR [rax],al
	...

00000000000020b0 <botlish_fn_31: ht_find_get<HashTable, str, int>>:
    20b0:	push   rbp
    20b1:	mov    rbp,rsp
    20b4:	sub    rsp,0x50
    20b8:	mov    QWORD PTR [rsp+0x20],rbx
    20bd:	mov    QWORD PTR [rsp+0x28],r12
    20c2:	mov    QWORD PTR [rsp+0x30],r13
    20c7:	mov    QWORD PTR [rsp+0x38],r14
    20cc:	mov    QWORD PTR [rsp+0x40],r15
    20d1:	mov    r14,rdi
    20d4:	mov    QWORD PTR [rsp],rsi
    20d8:	mov    QWORD PTR [rsp+0x8],rdx
    20dd:	mov    r13,rdx
    20e0:	sar    rcx,1
    20e3:	mov    rdx,rcx
    20e6:	mov    rbx,rsi
    20e9:	mov    rax,QWORD PTR [rbx+0x18]
    20ed:	mov    rsi,QWORD PTR [rax]
    20f0:	mov    r12,rdx
    20f3:	shl    r12,1
    20f6:	mov    r15,rdx
    20f9:	or     r12,0x1
    20fd:	mov    rdx,r12
    2100:	mov    rdi,r14
    2103:	call   2108 <botlish_fn_31+0x58>
			2104: R_X86_64_PLT32	rt_mutarray_get-0x4
    2108:	mov    QWORD PTR [rsp+0x10],r12
    210d:	mov    r12,rax
    2110:	mov    rdx,rax
    2113:	test   rax,rdx
    2116:	je     224c <botlish_fn_31+0x19c>
    211c:	mov    rax,r12
    211f:	test   rax,0x1
    2125:	jne    2153 <botlish_fn_31+0xa3>
    212b:	mov    edx,0x1
    2130:	mov    rsi,r12
    2133:	mov    rdi,r14
    2136:	call   213b <botlish_fn_31+0x8b>
			2137: R_X86_64_PLT32	rt_int_cmp-0x4
    213b:	mov    ecx,0x2
    2140:	test   rax,rax
    2143:	cmove  rcx,QWORD PTR [rip+0x18d]        # 22d8 <botlish_fn_31+0x228>
    214b:	mov    rax,r12
    214e:	jmp    2167 <botlish_fn_31+0xb7>
    2153:	mov    ecx,0x2
    2158:	mov    rax,r12
    215b:	cmp    rax,0x1
    215f:	cmove  rcx,QWORD PTR [rip+0x171]        # 22d8 <botlish_fn_31+0x228>
    2167:	cmp    rcx,0x6
    216b:	je     22ac <botlish_fn_31+0x1fc>
    2171:	test   rax,0x1
    2177:	mov    r12,rax
    217a:	jne    21a5 <botlish_fn_31+0xf5>
    2180:	mov    edx,0x3
    2185:	mov    rsi,r12
    2188:	mov    rdi,r14
    218b:	call   2190 <botlish_fn_31+0xe0>
			218c: R_X86_64_PLT32	rt_int_cmp-0x4
    2190:	mov    ecx,0x2
    2195:	test   rax,rax
    2198:	cmove  rcx,QWORD PTR [rip+0x138]        # 22d8 <botlish_fn_31+0x228>
    21a0:	jmp    21b9 <botlish_fn_31+0x109>
    21a5:	mov    rsi,r12
    21a8:	mov    ecx,0x2
    21ad:	cmp    rsi,0x3
    21b1:	cmove  rcx,QWORD PTR [rip+0x11f]        # 22d8 <botlish_fn_31+0x228>
    21b9:	cmp    rcx,0x6
    21bd:	je     21cb <botlish_fn_31+0x11b>
    21c3:	mov    r12,r13
    21c6:	jmp    2235 <botlish_fn_31+0x185>
    21cb:	mov    rax,QWORD PTR [rbx+0x18]
    21cf:	mov    rsi,QWORD PTR [rax+0x8]
    21d3:	mov    rdx,QWORD PTR [rsp+0x10]
    21d8:	mov    rdi,r14
    21db:	call   21e0 <botlish_fn_31+0x130>
			21dc: R_X86_64_PLT32	rt_mutarray_get-0x4
    21e0:	test   rax,rax
    21e3:	je     224c <botlish_fn_31+0x19c>
    21e9:	mov    r12,r13
    21ec:	mov    rdx,rax
    21ef:	and    rdx,r12
    21f2:	mov    rsi,rax
    21f5:	test   rdx,0x1
    21fc:	jne    221b <botlish_fn_31+0x16b>
    2202:	mov    rdx,r12
    2205:	mov    rdi,r14
    2208:	call   220d <botlish_fn_31+0x15d>
			2209: R_X86_64_PLT32	rt_value_eq-0x4
    220d:	test   rax,rax
    2210:	je     224c <botlish_fn_31+0x19c>
    2216:	jmp    222b <botlish_fn_31+0x17b>
    221b:	mov    eax,0x2
    2220:	cmp    rsi,r12
    2223:	cmove  rax,QWORD PTR [rip+0xad]        # 22d8 <botlish_fn_31+0x228>
    222b:	cmp    rax,0x6
    222f:	je     2285 <botlish_fn_31+0x1d5>
    2235:	mov    rdx,r15
    2238:	mov    rsi,rbx
    223b:	mov    rdi,r14
    223e:	call   2243 <botlish_fn_31+0x193>
			223f: R_X86_64_PLT32	botlish_fn_30-0x4 ; ht_probe_next<HashTable, int>
    2243:	test   rdx,rdx
    2246:	jne    2271 <botlish_fn_31+0x1c1>
    224c:	xor    rax,rax
    224f:	mov    rbx,QWORD PTR [rsp+0x20]
    2254:	mov    r12,QWORD PTR [rsp+0x28]
    2259:	mov    r13,QWORD PTR [rsp+0x30]
    225e:	mov    r14,QWORD PTR [rsp+0x38]
    2263:	mov    r15,QWORD PTR [rsp+0x40]
    2268:	add    rsp,0x50
    226c:	mov    rsp,rbp
    226f:	pop    rbp
    2270:	ret
    2271:	mov    QWORD PTR [rsp],rbx
    2275:	mov    QWORD PTR [rsp+0x8],r12
    227a:	mov    rdx,rax
    227d:	mov    r13,r12
    2280:	jmp    20e9 <botlish_fn_31+0x39>
    2285:	mov    rax,QWORD PTR [rsp+0x10]
    228a:	mov    rbx,QWORD PTR [rsp+0x20]
    228f:	mov    r12,QWORD PTR [rsp+0x28]
    2294:	mov    r13,QWORD PTR [rsp+0x30]
    2299:	mov    r14,QWORD PTR [rsp+0x38]
    229e:	mov    r15,QWORD PTR [rsp+0x40]
    22a3:	add    rsp,0x50
    22a7:	mov    rsp,rbp
    22aa:	pop    rbp
    22ab:	ret
    22ac:	mov    rax,0xffffffffffffffff
    22b3:	mov    rbx,QWORD PTR [rsp+0x20]
    22b8:	mov    r12,QWORD PTR [rsp+0x28]
    22bd:	mov    r13,QWORD PTR [rsp+0x30]
    22c2:	mov    r14,QWORD PTR [rsp+0x38]
    22c7:	mov    r15,QWORD PTR [rsp+0x40]
    22cc:	add    rsp,0x50
    22d0:	mov    rsp,rbp
    22d3:	pop    rbp
    22d4:	ret
    22d5:	add    BYTE PTR [rax],al
    22d7:	add    BYTE PTR [rsi],al
    22d9:	add    BYTE PTR [rax],al
    22db:	add    BYTE PTR [rax],al
    22dd:	add    BYTE PTR [rax],al
	...

00000000000022e0 <botlish_entry_31: ht_find_get<HashTable, str, int>>:
    22e0:	push   rbp
    22e1:	mov    rbp,rsp
    22e4:	mov    rsi,QWORD PTR [rdx]
    22e7:	mov    r8,QWORD PTR [rdx+0x8]
    22eb:	mov    rcx,QWORD PTR [rdx+0x10]
    22ef:	mov    rdx,r8
    22f2:	call   22f7 <botlish_entry_31+0x17>
			22f3: R_X86_64_PLT32	botlish_fn_31-0x4 ; ht_find_get<HashTable, str, int>
    22f7:	mov    rsp,rbp
    22fa:	pop    rbp
    22fb:	ret
    22fc:	add    BYTE PTR [rax],al
	...

0000000000002300 <botlish_fn_32: ht_find_insert<HashTable, str, int, int>>:
    2300:	push   rbp
    2301:	mov    rbp,rsp
    2304:	sub    rsp,0x60
    2308:	mov    QWORD PTR [rsp+0x30],rbx
    230d:	mov    QWORD PTR [rsp+0x38],r12
    2312:	mov    QWORD PTR [rsp+0x40],r13
    2317:	mov    QWORD PTR [rsp+0x48],r14
    231c:	mov    QWORD PTR [rsp+0x50],r15
    2321:	mov    r14,rdi
    2324:	mov    QWORD PTR [rsp],rsi
    2328:	mov    QWORD PTR [rsp+0x8],rdx
    232d:	mov    r15,rdx
    2330:	mov    QWORD PTR [rsp+0x10],r8
    2335:	sar    rcx,1
    2338:	mov    rdx,rcx
    233b:	mov    r12,rsi
    233e:	mov    r13,r8
    2341:	mov    rsi,QWORD PTR [r12+0x18]
    2346:	mov    rsi,QWORD PTR [rsi]
    2349:	mov    rbx,rdx
    234c:	shl    rbx,1
    234f:	mov    QWORD PTR [rsp+0x18],rdx
    2354:	or     rbx,0x1
    2358:	mov    QWORD PTR [rsp+0x10],rbx
    235d:	mov    rdx,rbx
    2360:	mov    rdi,r14
    2363:	call   2368 <botlish_fn_32+0x68>
			2364: R_X86_64_PLT32	rt_mutarray_get-0x4
    2368:	mov    rcx,rax
    236b:	mov    QWORD PTR [rsp+0x20],rax
    2370:	mov    QWORD PTR [rsp+0x28],rbx
    2375:	test   rax,rcx
    2378:	je     25b0 <botlish_fn_32+0x2b0>
    237e:	mov    rax,QWORD PTR [rsp+0x20]
    2383:	test   rax,0x1
    2389:	jne    23b6 <botlish_fn_32+0xb6>
    238f:	mov    edx,0x1
    2394:	mov    rsi,QWORD PTR [rsp+0x20]
    2399:	mov    rdi,r14
    239c:	call   23a1 <botlish_fn_32+0xa1>
			239d: R_X86_64_PLT32	rt_int_cmp-0x4
    23a1:	mov    ecx,0x2
    23a6:	test   rax,rax
    23a9:	cmove  rcx,QWORD PTR [rip+0x2f7]        # 26a8 <botlish_fn_32+0x3a8>
    23b1:	jmp    23cc <botlish_fn_32+0xcc>
    23b6:	mov    ecx,0x2
    23bb:	mov    rax,QWORD PTR [rsp+0x20]
    23c0:	cmp    rax,0x1
    23c4:	cmove  rcx,QWORD PTR [rip+0x2dc]        # 26a8 <botlish_fn_32+0x3a8>
    23cc:	cmp    rcx,0x6
    23d0:	je     2602 <botlish_fn_32+0x302>
    23d6:	mov    rax,QWORD PTR [rsp+0x20]
    23db:	test   rax,0x1
    23e1:	jne    240e <botlish_fn_32+0x10e>
    23e7:	mov    edx,0x3
    23ec:	mov    rsi,QWORD PTR [rsp+0x20]
    23f1:	mov    rdi,r14
    23f4:	call   23f9 <botlish_fn_32+0xf9>
			23f5: R_X86_64_PLT32	rt_int_cmp-0x4
    23f9:	mov    ecx,0x2
    23fe:	test   rax,rax
    2401:	cmove  rcx,QWORD PTR [rip+0x29f]        # 26a8 <botlish_fn_32+0x3a8>
    2409:	jmp    2424 <botlish_fn_32+0x124>
    240e:	mov    ecx,0x2
    2413:	mov    rax,QWORD PTR [rsp+0x20]
    2418:	cmp    rax,0x3
    241c:	cmove  rcx,QWORD PTR [rip+0x284]        # 26a8 <botlish_fn_32+0x3a8>
    2424:	cmp    rcx,0x6
    2428:	je     243b <botlish_fn_32+0x13b>
    242e:	mov    rax,QWORD PTR [rsp+0x20]
    2433:	mov    rbx,r15
    2436:	jmp    24ab <botlish_fn_32+0x1ab>
    243b:	mov    rax,QWORD PTR [r12+0x18]
    2440:	mov    rsi,QWORD PTR [rax+0x8]
    2444:	mov    rdx,QWORD PTR [rsp+0x28]
    2449:	mov    rdi,r14
    244c:	call   2451 <botlish_fn_32+0x151>
			244d: R_X86_64_PLT32	rt_mutarray_get-0x4
    2451:	test   rax,rax
    2454:	je     25b0 <botlish_fn_32+0x2b0>
    245a:	mov    rbx,r15
    245d:	mov    rcx,rax
    2460:	and    rcx,rbx
    2463:	mov    rsi,rax
    2466:	test   rcx,0x1
    246d:	jne    248c <botlish_fn_32+0x18c>
    2473:	mov    rdx,rbx
    2476:	mov    rdi,r14
    2479:	call   247e <botlish_fn_32+0x17e>
			247a: R_X86_64_PLT32	rt_value_eq-0x4
    247e:	test   rax,rax
    2481:	je     25b0 <botlish_fn_32+0x2b0>
    2487:	jmp    249c <botlish_fn_32+0x19c>
    248c:	mov    eax,0x2
    2491:	cmp    rsi,rbx
    2494:	cmove  rax,QWORD PTR [rip+0x20c]        # 26a8 <botlish_fn_32+0x3a8>
    249c:	cmp    rax,0x6
    24a0:	je     25f8 <botlish_fn_32+0x2f8>
    24a6:	mov    rax,QWORD PTR [rsp+0x20]
    24ab:	test   rax,0x1
    24b1:	mov    QWORD PTR [rsp+0x20],rax
    24b6:	jne    24e3 <botlish_fn_32+0x1e3>
    24bc:	mov    edx,0x5
    24c1:	mov    rsi,QWORD PTR [rsp+0x20]
    24c6:	mov    rdi,r14
    24c9:	call   24ce <botlish_fn_32+0x1ce>
			24ca: R_X86_64_PLT32	rt_int_cmp-0x4
    24ce:	mov    ecx,0x2
    24d3:	test   rax,rax
    24d6:	cmove  rcx,QWORD PTR [rip+0x1ca]        # 26a8 <botlish_fn_32+0x3a8>
    24de:	jmp    24f9 <botlish_fn_32+0x1f9>
    24e3:	mov    rsi,QWORD PTR [rsp+0x20]
    24e8:	mov    ecx,0x2
    24ed:	cmp    rsi,0x5
    24f1:	cmove  rcx,QWORD PTR [rip+0x1af]        # 26a8 <botlish_fn_32+0x3a8>
    24f9:	cmp    rcx,0x6
    24fd:	je     250d <botlish_fn_32+0x20d>
    2503:	mov    rdx,QWORD PTR [rsp+0x18]
    2508:	jmp    2564 <botlish_fn_32+0x264>
    250d:	test   r13,0x1
    2514:	jne    253f <botlish_fn_32+0x23f>
    251a:	mov    edx,0x1
    251f:	mov    rsi,r13
    2522:	mov    rdi,r14
    2525:	call   252a <botlish_fn_32+0x22a>
			2526: R_X86_64_PLT32	rt_int_cmp-0x4
    252a:	mov    ecx,0x2
    252f:	test   rax,rax
    2532:	cmovl  rcx,QWORD PTR [rip+0x16e]        # 26a8 <botlish_fn_32+0x3a8>
    253a:	jmp    2555 <botlish_fn_32+0x255>
    253f:	mov    ecx,0x2
    2544:	mov    rax,r13
    2547:	mov    rdx,r13
    254a:	test   rax,rdx
    254d:	cmovle rcx,QWORD PTR [rip+0x153]        # 26a8 <botlish_fn_32+0x3a8>
    2555:	cmp    rcx,0x6
    2559:	je     2597 <botlish_fn_32+0x297>
    255f:	mov    rdx,QWORD PTR [rsp+0x18]
    2564:	mov    rsi,r12
    2567:	mov    rdi,r14
    256a:	call   256f <botlish_fn_32+0x26f>
			256b: R_X86_64_PLT32	botlish_fn_30-0x4 ; ht_probe_next<HashTable, int>
    256f:	mov    rcx,rax
    2572:	test   rdx,rdx
    2575:	je     25b0 <botlish_fn_32+0x2b0>
    257b:	mov    QWORD PTR [rsp],r12
    257f:	mov    QWORD PTR [rsp+0x8],rbx
    2584:	mov    rax,r13
    2587:	mov    QWORD PTR [rsp+0x10],rax
    258c:	mov    rdx,rcx
    258f:	mov    r15,rbx
    2592:	jmp    2341 <botlish_fn_32+0x41>
    2597:	mov    rdx,QWORD PTR [rsp+0x18]
    259c:	mov    rsi,r12
    259f:	mov    rdi,r14
    25a2:	call   25a7 <botlish_fn_32+0x2a7>
			25a3: R_X86_64_PLT32	botlish_fn_30-0x4 ; ht_probe_next<HashTable, int>
    25a7:	test   rdx,rdx
    25aa:	jne    25d5 <botlish_fn_32+0x2d5>
    25b0:	xor    rax,rax
    25b3:	mov    rbx,QWORD PTR [rsp+0x30]
    25b8:	mov    r12,QWORD PTR [rsp+0x38]
    25bd:	mov    r13,QWORD PTR [rsp+0x40]
    25c2:	mov    r14,QWORD PTR [rsp+0x48]
    25c7:	mov    r15,QWORD PTR [rsp+0x50]
    25cc:	add    rsp,0x60
    25d0:	mov    rsp,rbp
    25d3:	pop    rbp
    25d4:	ret
    25d5:	mov    QWORD PTR [rsp],r12
    25d9:	mov    QWORD PTR [rsp+0x8],rbx
    25de:	mov    rsi,QWORD PTR [rsp+0x28]
    25e3:	mov    QWORD PTR [rsp+0x10],rsi
    25e8:	mov    rdx,rax
    25eb:	mov    r13,QWORD PTR [rsp+0x28]
    25f0:	mov    r15,rbx
    25f3:	jmp    2341 <botlish_fn_32+0x41>
    25f8:	mov    rax,QWORD PTR [rsp+0x28]
    25fd:	jmp    265b <botlish_fn_32+0x35b>
    2602:	mov    rax,r13
    2605:	test   rax,0x1
    260b:	jne    2636 <botlish_fn_32+0x336>
    2611:	mov    edx,0x1
    2616:	mov    rdi,r14
    2619:	mov    rsi,r13
    261c:	call   2621 <botlish_fn_32+0x321>
			261d: R_X86_64_PLT32	rt_int_cmp-0x4
    2621:	mov    edx,0x2
    2626:	test   rax,rax
    2629:	cmovge rdx,QWORD PTR [rip+0x77]        # 26a8 <botlish_fn_32+0x3a8>
    2631:	jmp    264c <botlish_fn_32+0x34c>
    2636:	mov    edx,0x2
    263b:	mov    rax,r13
    263e:	mov    rcx,r13
    2641:	test   rax,rcx
    2644:	cmovg  rdx,QWORD PTR [rip+0x5c]        # 26a8 <botlish_fn_32+0x3a8>
    264c:	cmp    rdx,0x6
    2650:	je     2682 <botlish_fn_32+0x382>
    2656:	mov    rax,QWORD PTR [rsp+0x28]
    265b:	mov    rax,QWORD PTR [rsp+0x28]
    2660:	mov    rbx,QWORD PTR [rsp+0x30]
    2665:	mov    r12,QWORD PTR [rsp+0x38]
    266a:	mov    r13,QWORD PTR [rsp+0x40]
    266f:	mov    r14,QWORD PTR [rsp+0x48]
    2674:	mov    r15,QWORD PTR [rsp+0x50]
    2679:	add    rsp,0x60
    267d:	mov    rsp,rbp
    2680:	pop    rbp
    2681:	ret
    2682:	mov    rax,r13
    2685:	mov    rbx,QWORD PTR [rsp+0x30]
    268a:	mov    r12,QWORD PTR [rsp+0x38]
    268f:	mov    r13,QWORD PTR [rsp+0x40]
    2694:	mov    r14,QWORD PTR [rsp+0x48]
    2699:	mov    r15,QWORD PTR [rsp+0x50]
    269e:	add    rsp,0x60
    26a2:	mov    rsp,rbp
    26a5:	pop    rbp
    26a6:	ret
    26a7:	add    BYTE PTR [rsi],al
    26a9:	add    BYTE PTR [rax],al
    26ab:	add    BYTE PTR [rax],al
    26ad:	add    BYTE PTR [rax],al
	...

00000000000026b0 <botlish_entry_32: ht_find_insert<HashTable, str, int, int>>:
    26b0:	push   rbp
    26b1:	mov    rbp,rsp
    26b4:	mov    rsi,QWORD PTR [rdx]
    26b7:	mov    r9,QWORD PTR [rdx+0x8]
    26bb:	mov    rcx,QWORD PTR [rdx+0x10]
    26bf:	mov    r8,QWORD PTR [rdx+0x18]
    26c3:	mov    rdx,r9
    26c6:	call   26cb <botlish_entry_32+0x1b>
			26c7: R_X86_64_PLT32	botlish_fn_32-0x4 ; ht_find_insert<HashTable, str, int, int>
    26cb:	mov    rsp,rbp
    26ce:	pop    rbp
    26cf:	ret

00000000000026d0 <botlish_fn_33: ht_get<HashTable, str>>:
    26d0:	push   rbp
    26d1:	mov    rbp,rsp
    26d4:	sub    rsp,0x40
    26d8:	mov    QWORD PTR [rsp+0x20],rbx
    26dd:	mov    QWORD PTR [rsp+0x28],r12
    26e2:	mov    QWORD PTR [rsp+0x30],r13
    26e7:	mov    r12,rdi
    26ea:	mov    QWORD PTR [rsp+0x10],0x0
    26f3:	mov    QWORD PTR [rsp],rsi
    26f7:	mov    QWORD PTR [rsp+0x8],rdx
    26fc:	mov    r13,rdx
    26ff:	mov    rbx,rsi
    2702:	mov    rdx,r13
    2705:	mov    rdi,r12
    2708:	call   270d <botlish_fn_33+0x3d>
			2709: R_X86_64_PLT32	botlish_fn_29-0x4 ; ht_probe_start<HashTable, str>
    270d:	test   rax,rax
    2710:	je     27a8 <botlish_fn_33+0xd8>
    2716:	mov    QWORD PTR [rsp+0x10],rax
    271b:	mov    rcx,rax
    271e:	mov    rdx,r13
    2721:	mov    rsi,rbx
    2724:	mov    rdi,r12
    2727:	call   272c <botlish_fn_33+0x5c>
			2728: R_X86_64_PLT32	botlish_fn_31-0x4 ; ht_find_get<HashTable, str, int>
    272c:	mov    rcx,rax
    272f:	mov    r13,rax
    2732:	test   rax,rcx
    2735:	je     27a8 <botlish_fn_33+0xd8>
    273b:	mov    rax,r13
    273e:	test   rax,0x1
    2744:	jne    276f <botlish_fn_33+0x9f>
    274a:	mov    edx,0x1
    274f:	mov    rsi,r13
    2752:	mov    rdi,r12
    2755:	call   275a <botlish_fn_33+0x8a>
			2756: R_X86_64_PLT32	rt_int_cmp-0x4
    275a:	mov    ecx,0x2
    275f:	test   rax,rax
    2762:	cmovl  rcx,QWORD PTR [rip+0x8e]        # 27f8 <botlish_fn_33+0x128>
    276a:	jmp    2782 <botlish_fn_33+0xb2>
    276f:	mov    ecx,0x2
    2774:	mov    rax,r13
    2777:	test   rax,rax
    277a:	cmovle rcx,QWORD PTR [rip+0x76]        # 27f8 <botlish_fn_33+0x128>
    2782:	cmp    rcx,0x6
    2786:	je     27db <botlish_fn_33+0x10b>
    278c:	mov    rax,QWORD PTR [rbx+0x18]
    2790:	mov    rsi,QWORD PTR [rax+0x10]
    2794:	mov    rdx,r13
    2797:	mov    rdi,r12
    279a:	call   279f <botlish_fn_33+0xcf>
			279b: R_X86_64_PLT32	rt_mutarray_get-0x4
    279f:	test   rax,rax
    27a2:	jne    27c3 <botlish_fn_33+0xf3>
    27a8:	xor    rax,rax
    27ab:	mov    rbx,QWORD PTR [rsp+0x20]
    27b0:	mov    r12,QWORD PTR [rsp+0x28]
    27b5:	mov    r13,QWORD PTR [rsp+0x30]
    27ba:	add    rsp,0x40
    27be:	mov    rsp,rbp
    27c1:	pop    rbp
    27c2:	ret
    27c3:	mov    rbx,QWORD PTR [rsp+0x20]
    27c8:	mov    r12,QWORD PTR [rsp+0x28]
    27cd:	mov    r13,QWORD PTR [rsp+0x30]
    27d2:	add    rsp,0x40
    27d6:	mov    rsp,rbp
    27d9:	pop    rbp
    27da:	ret
    27db:	mov    eax,0xa
    27e0:	mov    rbx,QWORD PTR [rsp+0x20]
    27e5:	mov    r12,QWORD PTR [rsp+0x28]
    27ea:	mov    r13,QWORD PTR [rsp+0x30]
    27ef:	add    rsp,0x40
    27f3:	mov    rsp,rbp
    27f6:	pop    rbp
    27f7:	ret
    27f8:	(bad)
    27f9:	add    BYTE PTR [rax],al
    27fb:	add    BYTE PTR [rax],al
    27fd:	add    BYTE PTR [rax],al
	...

0000000000002800 <botlish_entry_33: ht_get<HashTable, str>>:
    2800:	push   rbp
    2801:	mov    rbp,rsp
    2804:	mov    rsi,QWORD PTR [rdx]
    2807:	mov    rdx,QWORD PTR [rdx+0x8]
    280b:	call   2810 <botlish_entry_33+0x10>
			280c: R_X86_64_PLT32	botlish_fn_33-0x4 ; ht_get<HashTable, str>
    2810:	mov    rsp,rbp
    2813:	pop    rbp
    2814:	ret
    2815:	add    BYTE PTR [rax],al
	...

0000000000002818 <botlish_fn_34: ht_rehash_probe<mutarray, int, int>>:
    2818:	push   rbp
    2819:	mov    rbp,rsp
    281c:	sub    rsp,0x40
    2820:	mov    QWORD PTR [rsp+0x20],rbx
    2825:	mov    QWORD PTR [rsp+0x28],r12
    282a:	mov    QWORD PTR [rsp+0x30],r13
    282f:	mov    QWORD PTR [rsp+0x38],r14
    2834:	mov    r13,rdi
    2837:	mov    QWORD PTR [rsp],rsi
    283b:	mov    QWORD PTR [rsp+0x8],rdx
    2840:	mov    QWORD PTR [rsp+0x10],rcx
    2845:	mov    r12,rcx
    2848:	mov    rbx,rsi
    284b:	mov    r14,rdx
    284e:	mov    rdx,r14
    2851:	mov    rsi,rbx
    2854:	mov    rdi,r13
    2857:	call   285c <botlish_fn_34+0x44>
			2858: R_X86_64_PLT32	rt_mutarray_get-0x4
    285c:	test   rax,rax
    285f:	je     2901 <botlish_fn_34+0xe9>
    2865:	test   rax,0x1
    286b:	mov    rsi,rax
    286e:	jne    288f <botlish_fn_34+0x77>
    2874:	mov    edx,0x1
    2879:	mov    rdi,r13
    287c:	call   2881 <botlish_fn_34+0x69>
			287d: R_X86_64_PLT32	rt_value_eq-0x4
    2881:	test   rax,rax
    2884:	je     2901 <botlish_fn_34+0xe9>
    288a:	jmp    28a0 <botlish_fn_34+0x88>
    288f:	mov    eax,0x2
    2894:	cmp    rsi,0x1
    2898:	cmove  rax,QWORD PTR [rip+0xb8]        # 2958 <botlish_fn_34+0x140>
    28a0:	cmp    rax,0x6
    28a4:	je     2937 <botlish_fn_34+0x11f>
    28aa:	mov    QWORD PTR [rsp+0x18],0x3
    28b3:	mov    rsi,r14
    28b6:	test   rsi,0x1
    28bd:	je     28d5 <botlish_fn_34+0xbd>
    28c3:	mov    rsi,r14
    28c6:	add    rsi,0x2
    28ca:	seto   al
    28cd:	test   al,al
    28cf:	je     28e8 <botlish_fn_34+0xd0>
    28d5:	mov    edx,0x3
    28da:	mov    rsi,r14
    28dd:	mov    rdi,r13
    28e0:	call   28e5 <botlish_fn_34+0xcd>
			28e1: R_X86_64_PLT32	rt_int_add-0x4
    28e5:	mov    rsi,rax
    28e8:	mov    QWORD PTR [rsp+0x8],rsi
    28ed:	mov    rdx,r12
    28f0:	mov    rdi,r13
    28f3:	call   28f8 <botlish_fn_34+0xe0>
			28f4: R_X86_64_PLT32	rt_int_mod-0x4
    28f8:	test   rax,rax
    28fb:	jne    2921 <botlish_fn_34+0x109>
    2901:	xor    rax,rax
    2904:	mov    rbx,QWORD PTR [rsp+0x20]
    2909:	mov    r12,QWORD PTR [rsp+0x28]
    290e:	mov    r13,QWORD PTR [rsp+0x30]
    2913:	mov    r14,QWORD PTR [rsp+0x38]
    2918:	add    rsp,0x40
    291c:	mov    rsp,rbp
    291f:	pop    rbp
    2920:	ret
    2921:	mov    QWORD PTR [rsp],rbx
    2925:	mov    QWORD PTR [rsp+0x8],rax
    292a:	mov    QWORD PTR [rsp+0x10],r12
    292f:	mov    r14,rax
    2932:	jmp    284e <botlish_fn_34+0x36>
    2937:	mov    rax,r14
    293a:	mov    rbx,QWORD PTR [rsp+0x20]
    293f:	mov    r12,QWORD PTR [rsp+0x28]
    2944:	mov    r13,QWORD PTR [rsp+0x30]
    2949:	mov    r14,QWORD PTR [rsp+0x38]
    294e:	add    rsp,0x40
    2952:	mov    rsp,rbp
    2955:	pop    rbp
    2956:	ret
    2957:	add    BYTE PTR [rsi],al
    2959:	add    BYTE PTR [rax],al
    295b:	add    BYTE PTR [rax],al
    295d:	add    BYTE PTR [rax],al
	...

0000000000002960 <botlish_entry_34: ht_rehash_probe<mutarray, int, int>>:
    2960:	push   rbp
    2961:	mov    rbp,rsp
    2964:	mov    rsi,QWORD PTR [rdx]
    2967:	mov    r8,QWORD PTR [rdx+0x8]
    296b:	mov    rcx,QWORD PTR [rdx+0x10]
    296f:	mov    rdx,r8
    2972:	call   2977 <botlish_entry_34+0x17>
			2973: R_X86_64_PLT32	botlish_fn_34-0x4 ; ht_rehash_probe<mutarray, int, int>
    2977:	mov    rsp,rbp
    297a:	pop    rbp
    297b:	ret

000000000000297c <botlish_fn_35: ht_rehash_insert<HashTable, int, any, any>>:
    297c:	push   rbp
    297d:	mov    rbp,rsp
    2980:	sub    rsp,0x70
    2984:	mov    QWORD PTR [rsp+0x40],rbx
    2989:	mov    QWORD PTR [rsp+0x48],r12
    298e:	mov    QWORD PTR [rsp+0x50],r13
    2993:	mov    QWORD PTR [rsp+0x58],r14
    2998:	mov    QWORD PTR [rsp+0x60],r15
    299d:	mov    r13,rdi
    29a0:	mov    QWORD PTR [rsp],rsi
    29a4:	mov    QWORD PTR [rsp+0x8],rdx
    29a9:	mov    r15,rdx
    29ac:	mov    QWORD PTR [rsp+0x10],rcx
    29b1:	mov    r14,rcx
    29b4:	mov    QWORD PTR [rsp+0x18],r8
    29b9:	mov    r12,r8
    29bc:	mov    rax,QWORD PTR [rsi+0x18]
    29c0:	mov    rbx,rsi
    29c3:	mov    rsi,QWORD PTR [rax]
    29c6:	mov    QWORD PTR [rsp+0x20],rsi
    29cb:	mov    QWORD PTR [rsp+0x30],rsi
    29d0:	mov    rsi,r14
    29d3:	mov    rdi,r13
    29d6:	call   29db <botlish_fn_35+0x5f>
			29d7: R_X86_64_PLT32	rt_hash-0x4
    29db:	test   rax,rax
    29de:	je     2a85 <botlish_fn_35+0x109>
    29e4:	mov    QWORD PTR [rsp+0x28],rax
    29e9:	mov    rsi,rax
    29ec:	mov    rdx,r15
    29ef:	mov    rdi,r13
    29f2:	call   29f7 <botlish_fn_35+0x7b>
			29f3: R_X86_64_PLT32	rt_int_mod-0x4
    29f7:	test   rax,rax
    29fa:	je     2a85 <botlish_fn_35+0x109>
    2a00:	mov    QWORD PTR [rsp+0x28],rax
    2a05:	mov    rcx,r15
    2a08:	mov    rdx,rax
    2a0b:	mov    rsi,QWORD PTR [rsp+0x30]
    2a10:	mov    rdi,r13
    2a13:	call   2a18 <botlish_fn_35+0x9c>
			2a14: R_X86_64_PLT32	botlish_fn_34-0x4 ; ht_rehash_probe<mutarray, int, int>
    2a18:	mov    rdx,rax
    2a1b:	mov    r15,rax
    2a1e:	test   rax,rdx
    2a21:	je     2a85 <botlish_fn_35+0x109>
    2a27:	mov    rcx,QWORD PTR [rbx+0x18]
    2a2b:	mov    rsi,QWORD PTR [rcx]
    2a2e:	mov    ecx,0x3
    2a33:	mov    rdx,r15
    2a36:	mov    rdi,r13
    2a39:	call   2a3e <botlish_fn_35+0xc2>
			2a3a: R_X86_64_PLT32	rt_mutarray_set-0x4
    2a3e:	test   rax,rax
    2a41:	je     2a85 <botlish_fn_35+0x109>
    2a47:	mov    rax,QWORD PTR [rbx+0x18]
    2a4b:	mov    rsi,QWORD PTR [rax+0x8]
    2a4f:	mov    rcx,r14
    2a52:	mov    rdx,r15
    2a55:	mov    rdi,r13
    2a58:	call   2a5d <botlish_fn_35+0xe1>
			2a59: R_X86_64_PLT32	rt_mutarray_set-0x4
    2a5d:	test   rax,rax
    2a60:	je     2a85 <botlish_fn_35+0x109>
    2a66:	mov    rax,QWORD PTR [rbx+0x18]
    2a6a:	mov    rsi,QWORD PTR [rax+0x10]
    2a6e:	mov    rcx,r12
    2a71:	mov    rdx,r15
    2a74:	mov    rdi,r13
    2a77:	call   2a7c <botlish_fn_35+0x100>
			2a78: R_X86_64_PLT32	rt_mutarray_set-0x4
    2a7c:	test   rax,rax
    2a7f:	jne    2aaa <botlish_fn_35+0x12e>
    2a85:	xor    rax,rax
    2a88:	mov    rbx,QWORD PTR [rsp+0x40]
    2a8d:	mov    r12,QWORD PTR [rsp+0x48]
    2a92:	mov    r13,QWORD PTR [rsp+0x50]
    2a97:	mov    r14,QWORD PTR [rsp+0x58]
    2a9c:	mov    r15,QWORD PTR [rsp+0x60]
    2aa1:	add    rsp,0x70
    2aa5:	mov    rsp,rbp
    2aa8:	pop    rbp
    2aa9:	ret
    2aaa:	mov    rax,rbx
    2aad:	mov    rbx,QWORD PTR [rsp+0x40]
    2ab2:	mov    r12,QWORD PTR [rsp+0x48]
    2ab7:	mov    r13,QWORD PTR [rsp+0x50]
    2abc:	mov    r14,QWORD PTR [rsp+0x58]
    2ac1:	mov    r15,QWORD PTR [rsp+0x60]
    2ac6:	add    rsp,0x70
    2aca:	mov    rsp,rbp
    2acd:	pop    rbp
    2ace:	ret

0000000000002acf <botlish_entry_35: ht_rehash_insert<HashTable, int, any, any>>:
    2acf:	push   rbp
    2ad0:	mov    rbp,rsp
    2ad3:	mov    rsi,QWORD PTR [rdx]
    2ad6:	mov    r9,QWORD PTR [rdx+0x8]
    2ada:	mov    rcx,QWORD PTR [rdx+0x10]
    2ade:	mov    r8,QWORD PTR [rdx+0x18]
    2ae2:	mov    rdx,r9
    2ae5:	call   2aea <botlish_entry_35+0x1b>
			2ae6: R_X86_64_PLT32	botlish_fn_35-0x4 ; ht_rehash_insert<HashTable, int, any, any>
    2aea:	mov    rsp,rbp
    2aed:	pop    rbp
    2aee:	ret
	...

0000000000002af0 <botlish_fn_36: ht_rehash_scan<mutarray, mutarray, mutarray, int, int, HashTable, int>>:
    2af0:	push   rbp
    2af1:	mov    rbp,rsp
    2af4:	sub    rsp,0x90
    2afb:	mov    QWORD PTR [rsp+0x60],rbx
    2b00:	mov    QWORD PTR [rsp+0x68],r12
    2b05:	mov    QWORD PTR [rsp+0x70],r13
    2b0a:	mov    QWORD PTR [rsp+0x78],r14
    2b0f:	mov    QWORD PTR [rsp+0x80],r15
    2b17:	mov    QWORD PTR [rsp+0x38],rdi
    2b1c:	mov    QWORD PTR [rsp+0x40],r9
    2b21:	mov    rdi,QWORD PTR [rbp+0x10]
    2b25:	mov    rbx,QWORD PTR [rbp+0x18]
    2b29:	mov    QWORD PTR [rsp],rsi
    2b2d:	mov    QWORD PTR [rsp+0x8],rdx
    2b32:	mov    r14,rdx
    2b35:	mov    QWORD PTR [rsp+0x10],rcx
    2b3a:	mov    r15,rcx
    2b3d:	mov    QWORD PTR [rsp+0x18],rdi
    2b42:	mov    QWORD PTR [rsp+0x20],rbx
    2b47:	sar    r8,1
    2b4a:	mov    rcx,QWORD PTR [rsp+0x40]
    2b4f:	mov    r12,r8
    2b52:	mov    QWORD PTR [rsp+0x48],rdi
    2b57:	cmp    r12,rcx
    2b5a:	mov    QWORD PTR [rsp+0x40],rcx
    2b5f:	jge    2cc6 <botlish_fn_36+0x1d6>
    2b65:	mov    rdx,r12
    2b68:	shl    rdx,1
    2b6b:	or     rdx,0x1
    2b6f:	mov    r13,rsi
    2b72:	mov    QWORD PTR [rsp+0x58],rdx
    2b77:	mov    rdi,QWORD PTR [rsp+0x38]
    2b7c:	call   2b81 <botlish_fn_36+0x91>
			2b7d: R_X86_64_PLT32	rt_mutarray_get-0x4
    2b81:	test   rax,rax
    2b84:	je     2c6a <botlish_fn_36+0x17a>
    2b8a:	test   rax,0x1
    2b90:	mov    rsi,rax
    2b93:	jne    2bb6 <botlish_fn_36+0xc6>
    2b99:	mov    edx,0x3
    2b9e:	mov    rdi,QWORD PTR [rsp+0x38]
    2ba3:	call   2ba8 <botlish_fn_36+0xb8>
			2ba4: R_X86_64_PLT32	rt_value_eq-0x4
    2ba8:	test   rax,rax
    2bab:	je     2c6a <botlish_fn_36+0x17a>
    2bb1:	jmp    2bc7 <botlish_fn_36+0xd7>
    2bb6:	mov    eax,0x2
    2bbb:	cmp    rsi,0x3
    2bbf:	cmove  rax,QWORD PTR [rip+0x131]        # 2cf8 <botlish_fn_36+0x208>
    2bc7:	cmp    rax,0x6
    2bcb:	je     2c02 <botlish_fn_36+0x112>
    2bd1:	mov    QWORD PTR [rsp],r13
    2bd5:	mov    QWORD PTR [rsp+0x8],r14
    2bda:	mov    QWORD PTR [rsp+0x10],r15
    2bdf:	mov    rsi,QWORD PTR [rsp+0x48]
    2be4:	mov    QWORD PTR [rsp+0x18],rsi
    2be9:	mov    QWORD PTR [rsp+0x20],rbx
    2bee:	add    r12,0x1
    2bf5:	mov    rcx,QWORD PTR [rsp+0x40]
    2bfa:	mov    rsi,r13
    2bfd:	jmp    2b57 <botlish_fn_36+0x67>
    2c02:	mov    rdx,QWORD PTR [rsp+0x58]
    2c07:	mov    rsi,r14
    2c0a:	mov    rdi,QWORD PTR [rsp+0x38]
    2c0f:	call   2c14 <botlish_fn_36+0x124>
			2c10: R_X86_64_PLT32	rt_mutarray_get-0x4
    2c14:	test   rax,rax
    2c17:	je     2c6a <botlish_fn_36+0x17a>
    2c1d:	mov    QWORD PTR [rsp+0x28],rax
    2c22:	mov    rdx,QWORD PTR [rsp+0x58]
    2c27:	mov    QWORD PTR [rsp+0x50],rax
    2c2c:	mov    rsi,r15
    2c2f:	mov    rdi,QWORD PTR [rsp+0x38]
    2c34:	call   2c39 <botlish_fn_36+0x149>
			2c35: R_X86_64_PLT32	rt_mutarray_get-0x4
    2c39:	test   rax,rax
    2c3c:	je     2c6a <botlish_fn_36+0x17a>
    2c42:	mov    QWORD PTR [rsp+0x30],rax
    2c47:	mov    rcx,QWORD PTR [rsp+0x50]
    2c4c:	mov    rsi,QWORD PTR [rsp+0x48]
    2c51:	mov    r8,rax
    2c54:	mov    rdx,rbx
    2c57:	mov    rdi,QWORD PTR [rsp+0x38]
    2c5c:	call   2c61 <botlish_fn_36+0x171>
			2c5d: R_X86_64_PLT32	botlish_fn_35-0x4 ; ht_rehash_insert<HashTable, int, any, any>
    2c61:	test   rax,rax
    2c64:	jne    2c95 <botlish_fn_36+0x1a5>
    2c6a:	xor    rax,rax
    2c6d:	mov    rbx,QWORD PTR [rsp+0x60]
    2c72:	mov    r12,QWORD PTR [rsp+0x68]
    2c77:	mov    r13,QWORD PTR [rsp+0x70]
    2c7c:	mov    r14,QWORD PTR [rsp+0x78]
    2c81:	mov    r15,QWORD PTR [rsp+0x80]
    2c89:	add    rsp,0x90
    2c90:	mov    rsp,rbp
    2c93:	pop    rbp
    2c94:	ret
    2c95:	mov    QWORD PTR [rsp],r13
    2c99:	mov    QWORD PTR [rsp+0x8],r14
    2c9e:	mov    QWORD PTR [rsp+0x10],r15
    2ca3:	mov    QWORD PTR [rsp+0x18],rax
    2ca8:	mov    QWORD PTR [rsp+0x20],rbx
    2cad:	add    r12,0x1
    2cb4:	mov    rcx,QWORD PTR [rsp+0x40]
    2cb9:	mov    rsi,r13
    2cbc:	mov    QWORD PTR [rsp+0x48],rax
    2cc1:	jmp    2b57 <botlish_fn_36+0x67>
    2cc6:	mov    rax,QWORD PTR [rsp+0x48]
    2ccb:	mov    rbx,QWORD PTR [rsp+0x60]
    2cd0:	mov    r12,QWORD PTR [rsp+0x68]
    2cd5:	mov    r13,QWORD PTR [rsp+0x70]
    2cda:	mov    r14,QWORD PTR [rsp+0x78]
    2cdf:	mov    r15,QWORD PTR [rsp+0x80]
    2ce7:	add    rsp,0x90
    2cee:	mov    rsp,rbp
    2cf1:	pop    rbp
    2cf2:	ret
    2cf3:	add    BYTE PTR [rax],al
    2cf5:	add    BYTE PTR [rax],al
    2cf7:	add    BYTE PTR [rsi],al
    2cf9:	add    BYTE PTR [rax],al
    2cfb:	add    BYTE PTR [rax],al
    2cfd:	add    BYTE PTR [rax],al
	...

0000000000002d00 <botlish_entry_36: ht_rehash_scan<mutarray, mutarray, mutarray, int, int, HashTable, int>>:
    2d00:	push   rbp
    2d01:	mov    rbp,rsp
    2d04:	sub    rsp,0x10
    2d08:	mov    rsi,QWORD PTR [rdx]
    2d0b:	mov    r11,QWORD PTR [rdx+0x8]
    2d0f:	mov    rcx,QWORD PTR [rdx+0x10]
    2d13:	mov    r8,QWORD PTR [rdx+0x18]
    2d17:	mov    r9,QWORD PTR [rdx+0x20]
    2d1b:	mov    rax,QWORD PTR [rdx+0x28]
    2d1f:	mov    rdx,QWORD PTR [rdx+0x30]
    2d23:	sar    r9,1
    2d26:	mov    QWORD PTR [rsp],rax
    2d2a:	mov    QWORD PTR [rsp+0x8],rdx
    2d2f:	mov    rdx,r11
    2d32:	call   2d37 <botlish_entry_36+0x37>
			2d33: R_X86_64_PLT32	botlish_fn_36-0x4 ; ht_rehash_scan<mutarray, mutarray, mutarray, int, int, HashTable, int>
    2d37:	add    rsp,0x10
    2d3b:	mov    rsp,rbp
    2d3e:	pop    rbp
    2d3f:	ret

0000000000002d40 <botlish_fn_37: ht_rehash<HashTable, int>>:
    2d40:	push   rbp
    2d41:	mov    rbp,rsp
    2d44:	sub    rsp,0xf0
    2d4b:	mov    QWORD PTR [rsp+0xc0],rbx
    2d53:	mov    QWORD PTR [rsp+0xc8],r12
    2d5b:	mov    QWORD PTR [rsp+0xd0],r13
    2d63:	mov    QWORD PTR [rsp+0xd8],r14
    2d6b:	mov    QWORD PTR [rsp+0xe0],r15
    2d73:	mov    QWORD PTR [rsp+0x90],rdi
    2d7b:	mov    QWORD PTR [rsp+0x20],0x0
    2d84:	mov    QWORD PTR [rsp+0x28],0x0
    2d8d:	mov    QWORD PTR [rsp+0x30],0x0
    2d96:	mov    QWORD PTR [rsp+0x38],0x0
    2d9f:	mov    QWORD PTR [rsp+0x40],0x0
    2da8:	mov    QWORD PTR [rsp+0x48],0x0
    2db1:	mov    QWORD PTR [rsp+0x50],0x0
    2dba:	mov    QWORD PTR [rsp+0x10],rsi
    2dbf:	mov    r14,rsi
    2dc2:	mov    QWORD PTR [rsp+0x18],rdx
    2dc7:	mov    QWORD PTR [rsp+0x98],rdx
    2dcf:	lea    rdx,[rsp+0x58]
    2dd4:	mov    rsi,QWORD PTR [rsp+0x98]
    2ddc:	mov    rdi,QWORD PTR [rsp+0x90]
    2de4:	call   2de9 <botlish_fn_37+0xa9>
			2de5: R_X86_64_PLT32	botlish_fn_22-0x4 ; ht_alloc<int>
    2de9:	test   rax,rax
    2dec:	je     2f40 <botlish_fn_37+0x200>
    2df2:	mov    QWORD PTR [rsp+0x10],rax
    2df7:	mov    QWORD PTR [rsp+0xb8],rax
    2dff:	mov    rbx,QWORD PTR [rsp+0x58]
    2e04:	mov    QWORD PTR [rsp+0x20],rbx
    2e09:	mov    r12,QWORD PTR [rsp+0x60]
    2e0e:	mov    QWORD PTR [rsp+0x28],r12
    2e13:	mov    r13,QWORD PTR [rsp+0x68]
    2e18:	mov    QWORD PTR [rsp+0x30],r13
    2e1d:	mov    rsi,r14
    2e20:	mov    rdi,QWORD PTR [rsp+0x90]
    2e28:	call   2e2d <botlish_fn_37+0xed>
			2e29: R_X86_64_PLT32	botlish_fn_26-0x4 ; ht_size<HashTable>
    2e2d:	test   rax,rax
    2e30:	mov    rcx,rax
    2e33:	je     2f40 <botlish_fn_37+0x200>
    2e39:	mov    edx,0x1
    2e3e:	mov    rsi,r13
    2e41:	mov    rdi,QWORD PTR [rsp+0x90]
    2e49:	call   2e4e <botlish_fn_37+0x10e>
			2e4a: R_X86_64_PLT32	rt_mutarray_set-0x4
    2e4e:	test   rax,rax
    2e51:	je     2f40 <botlish_fn_37+0x200>
    2e57:	mov    rsi,r14
    2e5a:	mov    rax,QWORD PTR [rsi+0x18]
    2e5e:	mov    rcx,QWORD PTR [rax]
    2e61:	mov    QWORD PTR [rsp+0x38],rcx
    2e66:	mov    QWORD PTR [rsp+0xb0],rcx
    2e6e:	mov    rax,QWORD PTR [rsi+0x18]
    2e72:	mov    r15,QWORD PTR [rax+0x8]
    2e76:	mov    QWORD PTR [rsp+0x40],r15
    2e7b:	mov    rax,QWORD PTR [rsi+0x18]
    2e7f:	mov    r14,QWORD PTR [rax+0x10]
    2e83:	mov    QWORD PTR [rsp+0x48],r14
    2e88:	mov    r8d,0x1
    2e8e:	mov    QWORD PTR [rsp+0xa8],r8
    2e96:	mov    QWORD PTR [rsp+0x50],0x1
    2e9f:	mov    rdi,QWORD PTR [rsp+0x90]
    2ea7:	call   2eac <botlish_fn_37+0x16c>
			2ea8: R_X86_64_PLT32	botlish_fn_28-0x4 ; ht_capacity<HashTable>
    2eac:	mov    QWORD PTR [rsp+0xa0],rax
    2eb4:	lea    rcx,[rsp+0x70]
    2eb9:	mov    rax,QWORD PTR [rsp+0xb8]
    2ec1:	mov    QWORD PTR [rsp+0x70],rax
    2ec6:	mov    QWORD PTR [rsp+0x78],rbx
    2ecb:	mov    QWORD PTR [rsp+0x80],r12
    2ed3:	mov    QWORD PTR [rsp+0x88],r13
    2edb:	xor    rsi,rsi
    2ede:	mov    edx,0x4
    2ee3:	mov    rdi,QWORD PTR [rsp+0x90]
    2eeb:	call   2ef0 <botlish_fn_37+0x1b0>
			2eec: R_X86_64_PLT32	rt_struct_new-0x4
    2ef0:	mov    QWORD PTR [rsp+0x10],rax
    2ef5:	mov    rcx,QWORD PTR [rsp+0xa0]
    2efd:	mov    r9,rcx
    2f00:	sar    r9,1
    2f03:	mov    QWORD PTR [rsp],rax
    2f07:	mov    rdx,QWORD PTR [rsp+0x98]
    2f0f:	mov    QWORD PTR [rsp+0x8],rdx
    2f14:	mov    rcx,r14
    2f17:	mov    rdx,r15
    2f1a:	mov    rsi,QWORD PTR [rsp+0xb0]
    2f22:	mov    rdi,QWORD PTR [rsp+0x90]
    2f2a:	mov    r8,QWORD PTR [rsp+0xa8]
    2f32:	call   2f37 <botlish_fn_37+0x1f7>
			2f33: R_X86_64_PLT32	botlish_fn_36-0x4 ; ht_rehash_scan<mutarray, mutarray, mutarray, int, int, HashTable, int>
    2f37:	test   rax,rax
    2f3a:	jne    2f77 <botlish_fn_37+0x237>
    2f40:	xor    rax,rax
    2f43:	mov    rbx,QWORD PTR [rsp+0xc0]
    2f4b:	mov    r12,QWORD PTR [rsp+0xc8]
    2f53:	mov    r13,QWORD PTR [rsp+0xd0]
    2f5b:	mov    r14,QWORD PTR [rsp+0xd8]
    2f63:	mov    r15,QWORD PTR [rsp+0xe0]
    2f6b:	add    rsp,0xf0
    2f72:	mov    rsp,rbp
    2f75:	pop    rbp
    2f76:	ret
    2f77:	mov    rbx,QWORD PTR [rsp+0xc0]
    2f7f:	mov    r12,QWORD PTR [rsp+0xc8]
    2f87:	mov    r13,QWORD PTR [rsp+0xd0]
    2f8f:	mov    r14,QWORD PTR [rsp+0xd8]
    2f97:	mov    r15,QWORD PTR [rsp+0xe0]
    2f9f:	add    rsp,0xf0
    2fa6:	mov    rsp,rbp
    2fa9:	pop    rbp
    2faa:	ret

0000000000002fab <botlish_entry_37: ht_rehash<HashTable, int>>:
    2fab:	push   rbp
    2fac:	mov    rbp,rsp
    2faf:	mov    rsi,QWORD PTR [rdx]
    2fb2:	mov    rdx,QWORD PTR [rdx+0x8]
    2fb6:	call   2fbb <botlish_entry_37+0x10>
			2fb7: R_X86_64_PLT32	botlish_fn_37-0x4 ; ht_rehash<HashTable, int>
    2fbb:	mov    rsp,rbp
    2fbe:	pop    rbp
    2fbf:	ret

0000000000002fc0 <botlish_fn_38: ht_should_grow<HashTable>>:
    2fc0:	push   rbp
    2fc1:	mov    rbp,rsp
    2fc4:	sub    rsp,0x40
    2fc8:	mov    QWORD PTR [rsp+0x20],rbx
    2fcd:	mov    QWORD PTR [rsp+0x28],r12
    2fd2:	mov    QWORD PTR [rsp+0x30],r13
    2fd7:	mov    rbx,rdi
    2fda:	mov    QWORD PTR [rsp],rsi
    2fde:	mov    r12,rsi
    2fe1:	mov    rsi,r12
    2fe4:	mov    rdi,rbx
    2fe7:	call   2fec <botlish_fn_38+0x2c>
			2fe8: R_X86_64_PLT32	botlish_fn_26-0x4 ; ht_size<HashTable>
    2fec:	mov    rcx,rax
    2fef:	mov    r13,rax
    2ff2:	test   rax,rcx
    2ff5:	je     30ce <botlish_fn_38+0x10e>
    2ffb:	mov    rax,r13
    2ffe:	mov    QWORD PTR [rsp+0x8],rax
    3003:	mov    rsi,r12
    3006:	mov    rdi,rbx
    3009:	call   300e <botlish_fn_38+0x4e>
			300a: R_X86_64_PLT32	botlish_fn_27-0x4 ; ht_tombstones<HashTable>
    300e:	mov    rcx,rax
    3011:	test   rcx,rcx
    3014:	je     30ce <botlish_fn_38+0x10e>
    301a:	mov    QWORD PTR [rsp+0x10],rcx
    301f:	mov    edx,0x1
    3024:	mov    rax,r13
    3027:	test   rax,0x1
    302d:	jne    3050 <botlish_fn_38+0x90>
    3033:	xor    edx,edx
    3035:	mov    rax,r13
    3038:	test   rax,0x7
    303e:	jne    3050 <botlish_fn_38+0x90>
    3044:	mov    rax,r13
    3047:	movzx  rax,BYTE PTR [rax]
    304b:	cmp    al,0x1
    304d:	sete   dl
    3050:	test   dl,dl
    3052:	jne    3073 <botlish_fn_38+0xb3>
    3058:	mov    rdi,rbx
    305b:	mov    rax,QWORD PTR [rdi+0x10]
    305f:	mov    rcx,QWORD PTR [rax+0x8]
    3063:	xor    rdx,rdx
    3066:	mov    rsi,r13
    3069:	call   306e <botlish_fn_38+0xae>
			306a: R_X86_64_PLT32	rt_type_error-0x4
    306e:	jmp    30ce <botlish_fn_38+0x10e>
    3073:	mov    eax,0x1
    3078:	test   rcx,0x1
    307f:	je     308d <botlish_fn_38+0xcd>
    3085:	mov    r8,rcx
    3088:	jmp    30b0 <botlish_fn_38+0xf0>
    308d:	xor    eax,eax
    308f:	test   rcx,0x7
    3096:	je     30a4 <botlish_fn_38+0xe4>
    309c:	mov    r8,rcx
    309f:	jmp    30b0 <botlish_fn_38+0xf0>
    30a4:	movzx  rax,BYTE PTR [rcx]
    30a8:	mov    r8,rcx
    30ab:	cmp    al,0x1
    30ad:	sete   al
    30b0:	test   al,al
    30b2:	jne    30e9 <botlish_fn_38+0x129>
    30b8:	mov    rdi,rbx
    30bb:	mov    rax,QWORD PTR [rdi+0x10]
    30bf:	mov    rcx,QWORD PTR [rax+0x8]
    30c3:	xor    rdx,rdx
    30c6:	mov    rsi,r8
    30c9:	call   30ce <botlish_fn_38+0x10e>
			30ca: R_X86_64_PLT32	rt_type_error-0x4
    30ce:	xor    rax,rax
    30d1:	mov    rbx,QWORD PTR [rsp+0x20]
    30d6:	mov    r12,QWORD PTR [rsp+0x28]
    30db:	mov    r13,QWORD PTR [rsp+0x30]
    30e0:	add    rsp,0x40
    30e4:	mov    rsp,rbp
    30e7:	pop    rbp
    30e8:	ret
    30e9:	mov    rcx,r8
    30ec:	mov    rsi,r13
    30ef:	mov    rax,rsi
    30f2:	and    rax,rcx
    30f5:	test   rax,0x1
    30fb:	jne    310c <botlish_fn_38+0x14c>
    3101:	mov    rdx,r8
    3104:	mov    rsi,r13
    3107:	jmp    312a <botlish_fn_38+0x16a>
    310c:	mov    rcx,r8
    310f:	lea    rax,[rcx-0x1]
    3113:	mov    rsi,r13
    3116:	add    rsi,rax
    3119:	seto   al
    311c:	test   al,al
    311e:	je     3135 <botlish_fn_38+0x175>
    3124:	mov    rdx,r8
    3127:	mov    rsi,r13
    312a:	mov    rdi,rbx
    312d:	call   3132 <botlish_fn_38+0x172>
			312e: R_X86_64_PLT32	rt_int_add-0x4
    3132:	mov    rsi,rax
    3135:	mov    QWORD PTR [rsp+0x8],rsi
    313a:	mov    QWORD PTR [rsp+0x10],0x3
    3143:	test   rsi,0x1
    314a:	je     316d <botlish_fn_38+0x1ad>
    3150:	mov    rax,rsi
    3153:	add    rax,0x2
    3157:	mov    rcx,rax
    315a:	seto   al
    315d:	test   al,al
    315f:	jne    316d <botlish_fn_38+0x1ad>
    3165:	mov    rsi,rcx
    3168:	jmp    317d <botlish_fn_38+0x1bd>
    316d:	mov    edx,0x3
    3172:	mov    rdi,rbx
    3175:	call   317a <botlish_fn_38+0x1ba>
			3176: R_X86_64_PLT32	rt_int_add-0x4
    317a:	mov    rsi,rax
    317d:	mov    QWORD PTR [rsp+0x8],rsi
    3182:	mov    edx,0x7
    3187:	mov    rdi,rdx
    318a:	mov    QWORD PTR [rsp+0x10],0x7
    3193:	test   rsi,0x1
    319a:	jne    31a8 <botlish_fn_38+0x1e8>
    31a0:	mov    rdx,rdi
    31a3:	jmp    31d4 <botlish_fn_38+0x214>
    31a8:	mov    rax,rsi
    31ab:	sar    rax,1
    31ae:	imul   QWORD PTR [rip+0xf3]        # 32a8 <botlish_fn_38+0x2e8>
    31b5:	seto   cl
    31b8:	or     rax,0x1
    31bc:	test   cl,cl
    31be:	je     31cc <botlish_fn_38+0x20c>
    31c4:	mov    rdx,rdi
    31c7:	jmp    31d4 <botlish_fn_38+0x214>
    31cc:	mov    rsi,rax
    31cf:	jmp    31df <botlish_fn_38+0x21f>
    31d4:	mov    rdi,rbx
    31d7:	call   31dc <botlish_fn_38+0x21c>
			31d8: R_X86_64_PLT32	rt_int_mul-0x4
    31dc:	mov    rsi,rax
    31df:	mov    QWORD PTR [rsp],rsi
    31e3:	mov    r13,rsi
    31e6:	mov    rsi,r12
    31e9:	mov    rdi,rbx
    31ec:	call   31f1 <botlish_fn_38+0x231>
			31ed: R_X86_64_PLT32	botlish_fn_28-0x4 ; ht_capacity<HashTable>
    31f1:	mov    QWORD PTR [rsp+0x8],rax
    31f6:	mov    QWORD PTR [rsp+0x10],0x5
    31ff:	test   rax,0x1
    3205:	mov    rcx,rax
    3208:	je     3237 <botlish_fn_38+0x277>
    320e:	mov    rax,rcx
    3211:	sar    rax,1
    3214:	imul   QWORD PTR [rip+0x95]        # 32b0 <botlish_fn_38+0x2f0>
    321b:	seto   sil
    321f:	or     rax,0x1
    3223:	test   sil,sil
    3226:	jne    3237 <botlish_fn_38+0x277>
    322c:	mov    rdx,rax
    322f:	mov    rsi,r13
    3232:	jmp    324d <botlish_fn_38+0x28d>
    3237:	mov    edx,0x5
    323c:	mov    rsi,rcx
    323f:	mov    rdi,rbx
    3242:	call   3247 <botlish_fn_38+0x287>
			3243: R_X86_64_PLT32	rt_int_mul-0x4
    3247:	mov    rdx,rax
    324a:	mov    rsi,r13
    324d:	mov    rdi,rsi
    3250:	and    rdi,rdx
    3253:	test   rdi,0x1
    325a:	jne    3280 <botlish_fn_38+0x2c0>
    3260:	mov    rdi,rbx
    3263:	call   3268 <botlish_fn_38+0x2a8>
			3264: R_X86_64_PLT32	rt_int_cmp-0x4
    3268:	mov    esi,0x2
    326d:	test   rax,rax
    3270:	mov    rax,rsi
    3273:	cmovg  rax,QWORD PTR [rip+0x2d]        # 32a8 <botlish_fn_38+0x2e8>
    327b:	jmp    3290 <botlish_fn_38+0x2d0>
    3280:	mov    eax,0x2
    3285:	cmp    rsi,rdx
    3288:	cmovg  rax,QWORD PTR [rip+0x18]        # 32a8 <botlish_fn_38+0x2e8>
    3290:	mov    rbx,QWORD PTR [rsp+0x20]
    3295:	mov    r12,QWORD PTR [rsp+0x28]
    329a:	mov    r13,QWORD PTR [rsp+0x30]
    329f:	add    rsp,0x40
    32a3:	mov    rsp,rbp
    32a6:	pop    rbp
    32a7:	ret
    32a8:	(bad)
    32a9:	add    BYTE PTR [rax],al
    32ab:	add    BYTE PTR [rax],al
    32ad:	add    BYTE PTR [rax],al
    32af:	add    BYTE PTR [rax+rax*1],al
    32b2:	add    BYTE PTR [rax],al
    32b4:	add    BYTE PTR [rax],al
	...

00000000000032b8 <botlish_entry_38: ht_should_grow<HashTable>>:
    32b8:	push   rbp
    32b9:	mov    rbp,rsp
    32bc:	mov    rsi,QWORD PTR [rdx]
    32bf:	call   32c4 <botlish_entry_38+0xc>
			32c0: R_X86_64_PLT32	botlish_fn_38-0x4 ; ht_should_grow<HashTable>
    32c4:	mov    rsp,rbp
    32c7:	pop    rbp
    32c8:	ret
    32c9:	add    BYTE PTR [rax],al
    32cb:	add    BYTE PTR [rax],al
    32cd:	add    BYTE PTR [rax],al
	...

00000000000032d0 <botlish_fn_39: ht_grow_or_clean<HashTable>>:
    32d0:	push   rbp
    32d1:	mov    rbp,rsp
    32d4:	sub    rsp,0x40
    32d8:	mov    QWORD PTR [rsp+0x20],rbx
    32dd:	mov    QWORD PTR [rsp+0x28],r12
    32e2:	mov    QWORD PTR [rsp+0x30],r13
    32e7:	mov    rbx,rdi
    32ea:	mov    QWORD PTR [rsp+0x10],0x0
    32f3:	mov    QWORD PTR [rsp],rsi
    32f7:	mov    r12,rsi
    32fa:	mov    rsi,r12
    32fd:	mov    rdi,rbx
    3300:	call   3305 <botlish_fn_39+0x35>
			3301: R_X86_64_PLT32	botlish_fn_27-0x4 ; ht_tombstones<HashTable>
    3305:	test   rax,rax
    3308:	mov    r13,rax
    330b:	je     34f9 <botlish_fn_39+0x229>
    3311:	mov    rsi,r12
    3314:	mov    rdi,rbx
    3317:	call   331c <botlish_fn_39+0x4c>
			3318: R_X86_64_PLT32	botlish_fn_26-0x4 ; ht_size<HashTable>
    331c:	mov    r11,rax
    331f:	test   r11,r11
    3322:	je     34f9 <botlish_fn_39+0x229>
    3328:	mov    ecx,0x1
    332d:	mov    rax,r13
    3330:	test   rax,0x1
    3336:	je     3344 <botlish_fn_39+0x74>
    333c:	mov    r13,rax
    333f:	jmp    3368 <botlish_fn_39+0x98>
    3344:	xor    ecx,ecx
    3346:	test   rax,0x7
    334c:	je     335a <botlish_fn_39+0x8a>
    3352:	mov    r13,rax
    3355:	jmp    3368 <botlish_fn_39+0x98>
    335a:	movzx  rcx,BYTE PTR [rax]
    335e:	mov    r13,rax
    3361:	rex cmp cl,0x1
    3365:	sete   cl
    3368:	test   cl,cl
    336a:	jne    338b <botlish_fn_39+0xbb>
    3370:	mov    rdi,rbx
    3373:	mov    rsi,QWORD PTR [rdi+0x10]
    3377:	mov    rcx,QWORD PTR [rsi+0x10]
    337b:	xor    rdx,rdx
    337e:	mov    rsi,r13
    3381:	call   3386 <botlish_fn_39+0xb6>
			3382: R_X86_64_PLT32	rt_type_error-0x4
    3386:	jmp    34f9 <botlish_fn_39+0x229>
    338b:	mov    rsi,r13
    338e:	mov    eax,0x1
    3393:	test   r11,0x1
    339a:	je     33a8 <botlish_fn_39+0xd8>
    33a0:	mov    r8,r11
    33a3:	jmp    33cd <botlish_fn_39+0xfd>
    33a8:	xor    eax,eax
    33aa:	test   r11,0x7
    33b1:	je     33bf <botlish_fn_39+0xef>
    33b7:	mov    r8,r11
    33ba:	jmp    33cd <botlish_fn_39+0xfd>
    33bf:	movzx  r10,BYTE PTR [r11]
    33c3:	mov    r8,r11
    33c6:	cmp    r10b,0x1
    33ca:	sete   al
    33cd:	test   al,al
    33cf:	jne    33f0 <botlish_fn_39+0x120>
    33d5:	mov    rdi,rbx
    33d8:	mov    rax,QWORD PTR [rdi+0x10]
    33dc:	mov    rcx,QWORD PTR [rax+0x10]
    33e0:	xor    rdx,rdx
    33e3:	mov    rsi,r8
    33e6:	call   33eb <botlish_fn_39+0x11b>
			33e7: R_X86_64_PLT32	rt_type_error-0x4
    33eb:	jmp    34f9 <botlish_fn_39+0x229>
    33f0:	mov    r11,r8
    33f3:	mov    rax,rsi
    33f6:	and    rax,r11
    33f9:	test   rax,0x1
    33ff:	jne    3425 <botlish_fn_39+0x155>
    3405:	mov    rdx,r8
    3408:	mov    rdi,rbx
    340b:	call   3410 <botlish_fn_39+0x140>
			340c: R_X86_64_PLT32	rt_int_cmp-0x4
    3410:	mov    ecx,0x2
    3415:	test   rax,rax
    3418:	cmovg  rcx,QWORD PTR [rip+0x110]        # 3530 <botlish_fn_39+0x260>
    3420:	jmp    3438 <botlish_fn_39+0x168>
    3425:	mov    ecx,0x2
    342a:	mov    r11,r8
    342d:	cmp    rsi,r11
    3430:	cmovg  rcx,QWORD PTR [rip+0xf8]        # 3530 <botlish_fn_39+0x260>
    3438:	cmp    rcx,0x6
    343c:	je     34d2 <botlish_fn_39+0x202>
    3442:	mov    rsi,r12
    3445:	mov    rdi,rbx
    3448:	call   344d <botlish_fn_39+0x17d>
			3449: R_X86_64_PLT32	botlish_fn_28-0x4 ; ht_capacity<HashTable>
    344d:	mov    QWORD PTR [rsp+0x8],rax
    3452:	mov    QWORD PTR [rsp+0x10],0x5
    345b:	test   rax,0x1
    3461:	mov    rsi,rax
    3464:	je     3491 <botlish_fn_39+0x1c1>
    346a:	mov    rcx,rsi
    346d:	mov    rax,rcx
    3470:	sar    rax,1
    3473:	imul   QWORD PTR [rip+0xbe]        # 3538 <botlish_fn_39+0x268>
    347a:	seto   cl
    347d:	or     rax,0x1
    3481:	test   cl,cl
    3483:	jne    3491 <botlish_fn_39+0x1c1>
    3489:	mov    rdx,rax
    348c:	jmp    34a1 <botlish_fn_39+0x1d1>
    3491:	mov    edx,0x5
    3496:	mov    rdi,rbx
    3499:	call   349e <botlish_fn_39+0x1ce>
			349a: R_X86_64_PLT32	rt_int_mul-0x4
    349e:	mov    rdx,rax
    34a1:	mov    QWORD PTR [rsp+0x8],rdx
    34a6:	mov    rsi,r12
    34a9:	mov    rdi,rbx
    34ac:	call   34b1 <botlish_fn_39+0x1e1>
			34ad: R_X86_64_PLT32	botlish_fn_37-0x4 ; ht_rehash<HashTable, int>
    34b1:	test   rax,rax
    34b4:	je     34f9 <botlish_fn_39+0x229>
    34ba:	mov    rbx,QWORD PTR [rsp+0x20]
    34bf:	mov    r12,QWORD PTR [rsp+0x28]
    34c4:	mov    r13,QWORD PTR [rsp+0x30]
    34c9:	add    rsp,0x40
    34cd:	mov    rsp,rbp
    34d0:	pop    rbp
    34d1:	ret
    34d2:	mov    rsi,r12
    34d5:	mov    rdi,rbx
    34d8:	call   34dd <botlish_fn_39+0x20d>
			34d9: R_X86_64_PLT32	botlish_fn_28-0x4 ; ht_capacity<HashTable>
    34dd:	mov    QWORD PTR [rsp+0x8],rax
    34e2:	mov    rdx,rax
    34e5:	mov    rsi,r12
    34e8:	mov    rdi,rbx
    34eb:	call   34f0 <botlish_fn_39+0x220>
			34ec: R_X86_64_PLT32	botlish_fn_37-0x4 ; ht_rehash<HashTable, int>
    34f0:	test   rax,rax
    34f3:	jne    3514 <botlish_fn_39+0x244>
    34f9:	xor    rax,rax
    34fc:	mov    rbx,QWORD PTR [rsp+0x20]
    3501:	mov    r12,QWORD PTR [rsp+0x28]
    3506:	mov    r13,QWORD PTR [rsp+0x30]
    350b:	add    rsp,0x40
    350f:	mov    rsp,rbp
    3512:	pop    rbp
    3513:	ret
    3514:	mov    rbx,QWORD PTR [rsp+0x20]
    3519:	mov    r12,QWORD PTR [rsp+0x28]
    351e:	mov    r13,QWORD PTR [rsp+0x30]
    3523:	add    rsp,0x40
    3527:	mov    rsp,rbp
    352a:	pop    rbp
    352b:	ret
    352c:	add    BYTE PTR [rax],al
    352e:	add    BYTE PTR [rax],al
    3530:	(bad)
    3531:	add    BYTE PTR [rax],al
    3533:	add    BYTE PTR [rax],al
    3535:	add    BYTE PTR [rax],al
    3537:	add    BYTE PTR [rax+rax*1],al
    353a:	add    BYTE PTR [rax],al
    353c:	add    BYTE PTR [rax],al
	...

0000000000003540 <botlish_entry_39: ht_grow_or_clean<HashTable>>:
    3540:	push   rbp
    3541:	mov    rbp,rsp
    3544:	mov    rsi,QWORD PTR [rdx]
    3547:	call   354c <botlish_entry_39+0xc>
			3548: R_X86_64_PLT32	botlish_fn_39-0x4 ; ht_grow_or_clean<HashTable>
    354c:	mov    rsp,rbp
    354f:	pop    rbp
    3550:	ret
    3551:	add    BYTE PTR [rax],al
    3553:	add    BYTE PTR [rax],al
    3555:	add    BYTE PTR [rax],al
	...

0000000000003558 <botlish_fn_40: ht_place<HashTable, int, str, str>>:
    3558:	push   rbp
    3559:	mov    rbp,rsp
    355c:	sub    rsp,0x70
    3560:	mov    QWORD PTR [rsp+0x40],rbx
    3565:	mov    QWORD PTR [rsp+0x48],r12
    356a:	mov    QWORD PTR [rsp+0x50],r13
    356f:	mov    QWORD PTR [rsp+0x58],r14
    3574:	mov    QWORD PTR [rsp+0x60],r15
    3579:	mov    r12,rdi
    357c:	mov    r14,r8
    357f:	mov    r15,rdx
    3582:	mov    QWORD PTR [rsp+0x30],rcx
    3587:	mov    QWORD PTR [rsp],rsi
    358b:	mov    r9,QWORD PTR [rsi+0x18]
    358f:	mov    r13,rsi
    3592:	mov    rsi,QWORD PTR [r9]
    3595:	mov    rdx,r15
    3598:	mov    rdi,r12
    359b:	call   35a0 <botlish_fn_40+0x48>
			359c: R_X86_64_PLT32	rt_mutarray_get-0x4
    35a0:	test   rax,rax
    35a3:	je     3838 <botlish_fn_40+0x2e0>
    35a9:	mov    QWORD PTR [rsp+0x8],rax
    35ae:	mov    rbx,r13
    35b1:	mov    r13,rax
    35b4:	mov    rax,QWORD PTR [rbx+0x18]
    35b8:	mov    rsi,QWORD PTR [rax]
    35bb:	mov    ecx,0x3
    35c0:	mov    rdx,r15
    35c3:	mov    rdi,r12
    35c6:	call   35cb <botlish_fn_40+0x73>
			35c7: R_X86_64_PLT32	rt_mutarray_set-0x4
    35cb:	test   rax,rax
    35ce:	je     3838 <botlish_fn_40+0x2e0>
    35d4:	mov    rax,QWORD PTR [rbx+0x18]
    35d8:	mov    rsi,QWORD PTR [rax+0x8]
    35dc:	mov    rcx,QWORD PTR [rsp+0x30]
    35e1:	mov    rdx,r15
    35e4:	mov    rdi,r12
    35e7:	call   35ec <botlish_fn_40+0x94>
			35e8: R_X86_64_PLT32	rt_mutarray_set-0x4
    35ec:	test   rax,rax
    35ef:	je     3838 <botlish_fn_40+0x2e0>
    35f5:	mov    rax,QWORD PTR [rbx+0x18]
    35f9:	mov    rsi,QWORD PTR [rax+0x10]
    35fd:	mov    rcx,r14
    3600:	mov    rdx,r15
    3603:	mov    rdi,r12
    3606:	call   360b <botlish_fn_40+0xb3>
			3607: R_X86_64_PLT32	rt_mutarray_set-0x4
    360b:	test   rax,rax
    360e:	je     3838 <botlish_fn_40+0x2e0>
    3614:	mov    rax,QWORD PTR [rbx+0x18]
    3618:	mov    rsi,QWORD PTR [rax+0x18]
    361c:	mov    QWORD PTR [rsp+0x10],rsi
    3621:	mov    r14,rsi
    3624:	mov    QWORD PTR [rsp+0x18],0x1
    362d:	mov    rsi,rbx
    3630:	mov    rdi,r12
    3633:	call   3638 <botlish_fn_40+0xe0>
			3634: R_X86_64_PLT32	botlish_fn_26-0x4 ; ht_size<HashTable>
    3638:	test   rax,rax
    363b:	je     3838 <botlish_fn_40+0x2e0>
    3641:	mov    QWORD PTR [rsp+0x20],rax
    3646:	mov    QWORD PTR [rsp+0x28],0x3
    364f:	mov    ecx,0x1
    3654:	test   rax,0x1
    365a:	je     3668 <botlish_fn_40+0x110>
    3660:	mov    rsi,rax
    3663:	jmp    368c <botlish_fn_40+0x134>
    3668:	xor    ecx,ecx
    366a:	test   rax,0x7
    3670:	je     367e <botlish_fn_40+0x126>
    3676:	mov    rsi,rax
    3679:	jmp    368c <botlish_fn_40+0x134>
    367e:	movzx  rcx,BYTE PTR [rax]
    3682:	mov    rsi,rax
    3685:	rex cmp cl,0x1
    3689:	sete   cl
    368c:	test   cl,cl
    368e:	jne    36ac <botlish_fn_40+0x154>
    3694:	mov    rdi,r12
    3697:	mov    rax,QWORD PTR [rdi+0x10]
    369b:	mov    rcx,QWORD PTR [rax+0x8]
    369f:	xor    rdx,rdx
    36a2:	call   36a7 <botlish_fn_40+0x14f>
			36a3: R_X86_64_PLT32	rt_type_error-0x4
    36a7:	jmp    3838 <botlish_fn_40+0x2e0>
    36ac:	test   rsi,0x1
    36b3:	je     36cb <botlish_fn_40+0x173>
    36b9:	mov    rcx,rsi
    36bc:	add    rcx,0x2
    36c0:	seto   al
    36c3:	test   al,al
    36c5:	je     36db <botlish_fn_40+0x183>
    36cb:	mov    edx,0x3
    36d0:	mov    rdi,r12
    36d3:	call   36d8 <botlish_fn_40+0x180>
			36d4: R_X86_64_PLT32	rt_int_add-0x4
    36d8:	mov    rcx,rax
    36db:	mov    edx,0x1
    36e0:	mov    rsi,r14
    36e3:	mov    rdi,r12
    36e6:	call   36eb <botlish_fn_40+0x193>
			36e7: R_X86_64_PLT32	rt_mutarray_set-0x4
    36eb:	test   rax,rax
    36ee:	je     3838 <botlish_fn_40+0x2e0>
    36f4:	mov    rax,r13
    36f7:	test   rax,0x1
    36fd:	jne    3728 <botlish_fn_40+0x1d0>
    3703:	mov    edx,0x5
    3708:	mov    rsi,r13
    370b:	mov    rdi,r12
    370e:	call   3713 <botlish_fn_40+0x1bb>
			370f: R_X86_64_PLT32	rt_int_cmp-0x4
    3713:	mov    ecx,0x2
    3718:	test   rax,rax
    371b:	cmove  rcx,QWORD PTR [rip+0x165]        # 3888 <botlish_fn_40+0x330>
    3723:	jmp    373c <botlish_fn_40+0x1e4>
    3728:	mov    rsi,r13
    372b:	mov    ecx,0x2
    3730:	cmp    rsi,0x5
    3734:	cmove  rcx,QWORD PTR [rip+0x14c]        # 3888 <botlish_fn_40+0x330>
    373c:	cmp    rcx,0x6
    3740:	je     374e <botlish_fn_40+0x1f6>
    3746:	mov    rax,rbx
    3749:	jmp    3860 <botlish_fn_40+0x308>
    374e:	mov    rax,QWORD PTR [rbx+0x18]
    3752:	mov    rsi,QWORD PTR [rax+0x18]
    3756:	mov    QWORD PTR [rsp+0x8],rsi
    375b:	mov    r14,rsi
    375e:	mov    QWORD PTR [rsp+0x10],0x3
    3767:	mov    rsi,rbx
    376a:	mov    rdi,r12
    376d:	call   3772 <botlish_fn_40+0x21a>
			376e: R_X86_64_PLT32	botlish_fn_27-0x4 ; ht_tombstones<HashTable>
    3772:	mov    r13,rbx
    3775:	test   rax,rax
    3778:	je     3838 <botlish_fn_40+0x2e0>
    377e:	mov    QWORD PTR [rsp+0x18],rax
    3783:	mov    QWORD PTR [rsp+0x20],0x3
    378c:	mov    ecx,0x1
    3791:	test   rax,0x1
    3797:	je     37a5 <botlish_fn_40+0x24d>
    379d:	mov    rsi,rax
    37a0:	jmp    37c9 <botlish_fn_40+0x271>
    37a5:	xor    ecx,ecx
    37a7:	test   rax,0x7
    37ad:	je     37bb <botlish_fn_40+0x263>
    37b3:	mov    rsi,rax
    37b6:	jmp    37c9 <botlish_fn_40+0x271>
    37bb:	movzx  r10,BYTE PTR [rax]
    37bf:	mov    rsi,rax
    37c2:	cmp    r10b,0x1
    37c6:	sete   cl
    37c9:	test   cl,cl
    37cb:	jne    37e9 <botlish_fn_40+0x291>
    37d1:	mov    rdi,r12
    37d4:	mov    rax,QWORD PTR [rdi+0x10]
    37d8:	mov    rcx,QWORD PTR [rax+0x18]
    37dc:	xor    rdx,rdx
    37df:	call   37e4 <botlish_fn_40+0x28c>
			37e0: R_X86_64_PLT32	rt_type_error-0x4
    37e4:	jmp    3838 <botlish_fn_40+0x2e0>
    37e9:	test   rsi,0x1
    37f0:	je     380f <botlish_fn_40+0x2b7>
    37f6:	mov    rcx,rsi
    37f9:	sub    rcx,0x3
    37fd:	seto   al
    3800:	add    rcx,0x1
    3807:	test   al,al
    3809:	je     381f <botlish_fn_40+0x2c7>
    380f:	mov    edx,0x3
    3814:	mov    rdi,r12
    3817:	call   381c <botlish_fn_40+0x2c4>
			3818: R_X86_64_PLT32	rt_int_sub-0x4
    381c:	mov    rcx,rax
    381f:	mov    edx,0x3
    3824:	mov    rsi,r14
    3827:	mov    rdi,r12
    382a:	call   382f <botlish_fn_40+0x2d7>
			382b: R_X86_64_PLT32	rt_mutarray_set-0x4
    382f:	test   rax,rax
    3832:	jne    385d <botlish_fn_40+0x305>
    3838:	xor    rax,rax
    383b:	mov    rbx,QWORD PTR [rsp+0x40]
    3840:	mov    r12,QWORD PTR [rsp+0x48]
    3845:	mov    r13,QWORD PTR [rsp+0x50]
    384a:	mov    r14,QWORD PTR [rsp+0x58]
    384f:	mov    r15,QWORD PTR [rsp+0x60]
    3854:	add    rsp,0x70
    3858:	mov    rsp,rbp
    385b:	pop    rbp
    385c:	ret
    385d:	mov    rax,r13
    3860:	mov    rbx,QWORD PTR [rsp+0x40]
    3865:	mov    r12,QWORD PTR [rsp+0x48]
    386a:	mov    r13,QWORD PTR [rsp+0x50]
    386f:	mov    r14,QWORD PTR [rsp+0x58]
    3874:	mov    r15,QWORD PTR [rsp+0x60]
    3879:	add    rsp,0x70
    387d:	mov    rsp,rbp
    3880:	pop    rbp
    3881:	ret
    3882:	add    BYTE PTR [rax],al
    3884:	add    BYTE PTR [rax],al
    3886:	add    BYTE PTR [rax],al
    3888:	(bad)
    3889:	add    BYTE PTR [rax],al
    388b:	add    BYTE PTR [rax],al
    388d:	add    BYTE PTR [rax],al
	...

0000000000003890 <botlish_entry_40: ht_place<HashTable, int, str, str>>:
    3890:	push   rbp
    3891:	mov    rbp,rsp
    3894:	mov    rsi,QWORD PTR [rdx]
    3897:	mov    r9,QWORD PTR [rdx+0x8]
    389b:	mov    rcx,QWORD PTR [rdx+0x10]
    389f:	mov    r8,QWORD PTR [rdx+0x18]
    38a3:	mov    rdx,r9
    38a6:	call   38ab <botlish_entry_40+0x1b>
			38a7: R_X86_64_PLT32	botlish_fn_40-0x4 ; ht_place<HashTable, int, str, str>
    38ab:	mov    rsp,rbp
    38ae:	pop    rbp
    38af:	ret

00000000000038b0 <botlish_fn_41: ht_set<HashTable, str, str>>:
    38b0:	push   rbp
    38b1:	mov    rbp,rsp
    38b4:	sub    rsp,0x60
    38b8:	mov    QWORD PTR [rsp+0x30],rbx
    38bd:	mov    QWORD PTR [rsp+0x38],r12
    38c2:	mov    QWORD PTR [rsp+0x40],r13
    38c7:	mov    QWORD PTR [rsp+0x48],r14
    38cc:	mov    QWORD PTR [rsp+0x50],r15
    38d1:	mov    r12,rdi
    38d4:	mov    QWORD PTR [rsp+0x18],0x0
    38dd:	mov    QWORD PTR [rsp+0x20],0x0
    38e6:	mov    QWORD PTR [rsp],rsi
    38ea:	mov    r14,rsi
    38ed:	mov    QWORD PTR [rsp+0x8],rdx
    38f2:	mov    r13,rdx
    38f5:	mov    QWORD PTR [rsp+0x10],rcx
    38fa:	mov    rbx,rcx
    38fd:	mov    rdx,r13
    3900:	mov    rsi,r14
    3903:	mov    rdi,r12
    3906:	call   390b <botlish_fn_41+0x5b>
			3907: R_X86_64_PLT32	botlish_fn_29-0x4 ; ht_probe_start<HashTable, str>
    390b:	test   rax,rax
    390e:	je     3ae6 <botlish_fn_41+0x236>
    3914:	mov    QWORD PTR [rsp+0x18],rax
    3919:	mov    rcx,rax
    391c:	mov    r8,0xffffffffffffffff
    3923:	mov    r15,r8
    3926:	mov    QWORD PTR [rsp+0x20],0xffffffffffffffff
    392f:	mov    rdx,r13
    3932:	mov    rsi,r14
    3935:	mov    rdi,r12
    3938:	call   393d <botlish_fn_41+0x8d>
			3939: R_X86_64_PLT32	botlish_fn_32-0x4 ; ht_find_insert<HashTable, str, int, int>
    393d:	test   rax,rax
    3940:	je     3ae6 <botlish_fn_41+0x236>
    3946:	mov    QWORD PTR [rsp+0x18],rax
    394b:	mov    rsi,r14
    394e:	mov    QWORD PTR [rsp+0x28],rax
    3953:	mov    rax,QWORD PTR [rsi+0x18]
    3957:	mov    rsi,QWORD PTR [rax]
    395a:	mov    rdx,QWORD PTR [rsp+0x28]
    395f:	mov    rdi,r12
    3962:	call   3967 <botlish_fn_41+0xb7>
			3963: R_X86_64_PLT32	rt_mutarray_get-0x4
    3967:	test   rax,rax
    396a:	je     3ae6 <botlish_fn_41+0x236>
    3970:	test   rax,0x1
    3976:	mov    rsi,rax
    3979:	jne    39a1 <botlish_fn_41+0xf1>
    397f:	mov    edx,0x3
    3984:	mov    rdi,r12
    3987:	call   398c <botlish_fn_41+0xdc>
			3988: R_X86_64_PLT32	rt_int_cmp-0x4
    398c:	mov    ecx,0x2
    3991:	test   rax,rax
    3994:	cmove  rcx,QWORD PTR [rip+0x194]        # 3b30 <botlish_fn_41+0x280>
    399c:	jmp    39b2 <botlish_fn_41+0x102>
    39a1:	mov    ecx,0x2
    39a6:	cmp    rsi,0x3
    39aa:	cmove  rcx,QWORD PTR [rip+0x17e]        # 3b30 <botlish_fn_41+0x280>
    39b2:	cmp    rcx,0x6
    39b6:	je     3ac2 <botlish_fn_41+0x212>
    39bc:	mov    rsi,r14
    39bf:	mov    rdi,r12
    39c2:	call   39c7 <botlish_fn_41+0x117>
			39c3: R_X86_64_PLT32	botlish_fn_38-0x4 ; ht_should_grow<HashTable>
    39c7:	test   rax,rax
    39ca:	je     3ae6 <botlish_fn_41+0x236>
    39d0:	cmp    rax,0x6
    39d4:	je     3a1b <botlish_fn_41+0x16b>
    39da:	mov    rcx,r13
    39dd:	mov    rdx,QWORD PTR [rsp+0x28]
    39e2:	mov    rsi,r14
    39e5:	mov    rdi,r12
    39e8:	mov    r8,rbx
    39eb:	call   39f0 <botlish_fn_41+0x140>
			39ec: R_X86_64_PLT32	botlish_fn_40-0x4 ; ht_place<HashTable, int, str, str>
    39f0:	test   rax,rax
    39f3:	je     3ae6 <botlish_fn_41+0x236>
    39f9:	mov    rbx,QWORD PTR [rsp+0x30]
    39fe:	mov    r12,QWORD PTR [rsp+0x38]
    3a03:	mov    r13,QWORD PTR [rsp+0x40]
    3a08:	mov    r14,QWORD PTR [rsp+0x48]
    3a0d:	mov    r15,QWORD PTR [rsp+0x50]
    3a12:	add    rsp,0x60
    3a16:	mov    rsp,rbp
    3a19:	pop    rbp
    3a1a:	ret
    3a1b:	mov    rsi,r14
    3a1e:	mov    rdi,r12
    3a21:	call   3a26 <botlish_fn_41+0x176>
			3a22: R_X86_64_PLT32	botlish_fn_39-0x4 ; ht_grow_or_clean<HashTable>
    3a26:	mov    rcx,rax
    3a29:	mov    r14,rax
    3a2c:	test   rax,rcx
    3a2f:	je     3ae6 <botlish_fn_41+0x236>
    3a35:	mov    rax,r14
    3a38:	mov    QWORD PTR [rsp],rax
    3a3c:	mov    rdx,r13
    3a3f:	mov    rsi,r14
    3a42:	mov    rdi,r12
    3a45:	call   3a4a <botlish_fn_41+0x19a>
			3a46: R_X86_64_PLT32	botlish_fn_29-0x4 ; ht_probe_start<HashTable, str>
    3a4a:	test   rax,rax
    3a4d:	je     3ae6 <botlish_fn_41+0x236>
    3a53:	mov    QWORD PTR [rsp+0x18],rax
    3a58:	mov    rcx,rax
    3a5b:	mov    QWORD PTR [rsp+0x20],0xffffffffffffffff
    3a64:	mov    r8,r15
    3a67:	mov    rdx,r13
    3a6a:	mov    rsi,r14
    3a6d:	mov    rdi,r12
    3a70:	call   3a75 <botlish_fn_41+0x1c5>
			3a71: R_X86_64_PLT32	botlish_fn_32-0x4 ; ht_find_insert<HashTable, str, int, int>
    3a75:	test   rax,rax
    3a78:	je     3ae6 <botlish_fn_41+0x236>
    3a7e:	mov    QWORD PTR [rsp+0x18],rax
    3a83:	mov    rcx,r13
    3a86:	mov    rdx,rax
    3a89:	mov    rsi,r14
    3a8c:	mov    rdi,r12
    3a8f:	mov    r8,rbx
    3a92:	call   3a97 <botlish_fn_41+0x1e7>
			3a93: R_X86_64_PLT32	botlish_fn_40-0x4 ; ht_place<HashTable, int, str, str>
    3a97:	test   rax,rax
    3a9a:	je     3ae6 <botlish_fn_41+0x236>
    3aa0:	mov    rbx,QWORD PTR [rsp+0x30]
    3aa5:	mov    r12,QWORD PTR [rsp+0x38]
    3aaa:	mov    r13,QWORD PTR [rsp+0x40]
    3aaf:	mov    r14,QWORD PTR [rsp+0x48]
    3ab4:	mov    r15,QWORD PTR [rsp+0x50]
    3ab9:	add    rsp,0x60
    3abd:	mov    rsp,rbp
    3ac0:	pop    rbp
    3ac1:	ret
    3ac2:	mov    rdx,QWORD PTR [rsp+0x28]
    3ac7:	mov    rsi,r14
    3aca:	mov    rax,QWORD PTR [rsi+0x18]
    3ace:	mov    rsi,QWORD PTR [rax+0x10]
    3ad2:	mov    rcx,rbx
    3ad5:	mov    rdi,r12
    3ad8:	call   3add <botlish_fn_41+0x22d>
			3ad9: R_X86_64_PLT32	rt_mutarray_set-0x4
    3add:	test   rax,rax
    3ae0:	jne    3b0b <botlish_fn_41+0x25b>
    3ae6:	xor    rax,rax
    3ae9:	mov    rbx,QWORD PTR [rsp+0x30]
    3aee:	mov    r12,QWORD PTR [rsp+0x38]
    3af3:	mov    r13,QWORD PTR [rsp+0x40]
    3af8:	mov    r14,QWORD PTR [rsp+0x48]
    3afd:	mov    r15,QWORD PTR [rsp+0x50]
    3b02:	add    rsp,0x60
    3b06:	mov    rsp,rbp
    3b09:	pop    rbp
    3b0a:	ret
    3b0b:	mov    rax,r14
    3b0e:	mov    rbx,QWORD PTR [rsp+0x30]
    3b13:	mov    r12,QWORD PTR [rsp+0x38]
    3b18:	mov    r13,QWORD PTR [rsp+0x40]
    3b1d:	mov    r14,QWORD PTR [rsp+0x48]
    3b22:	mov    r15,QWORD PTR [rsp+0x50]
    3b27:	add    rsp,0x60
    3b2b:	mov    rsp,rbp
    3b2e:	pop    rbp
    3b2f:	ret
    3b30:	(bad)
    3b31:	add    BYTE PTR [rax],al
    3b33:	add    BYTE PTR [rax],al
    3b35:	add    BYTE PTR [rax],al
	...

0000000000003b38 <botlish_entry_41: ht_set<HashTable, str, str>>:
    3b38:	push   rbp
    3b39:	mov    rbp,rsp
    3b3c:	mov    rsi,QWORD PTR [rdx]
    3b3f:	mov    r8,QWORD PTR [rdx+0x8]
    3b43:	mov    rcx,QWORD PTR [rdx+0x10]
    3b47:	mov    rdx,r8
    3b4a:	call   3b4f <botlish_entry_41+0x17>
			3b4b: R_X86_64_PLT32	botlish_fn_41-0x4 ; ht_set<HashTable, str, str>
    3b4f:	mov    rsp,rbp
    3b52:	pop    rbp
    3b53:	ret

0000000000003b54 <botlish_fn_42: row_new<bool, int>>:
    3b54:	push   rbp
    3b55:	mov    rbp,rsp
    3b58:	sub    rsp,0x10
    3b5c:	mov    QWORD PTR [rsp],rdx
    3b60:	mov    r8,rdx
    3b63:	cmp    rsi,0x6
    3b67:	je     3b84 <botlish_fn_42+0x30>
    3b6d:	call   3b72 <botlish_fn_42+0x1e>
			3b6e: R_X86_64_PLT32	botlish_fn_23-0x4 ; ht_new<generic>
    3b72:	test   rax,rax
    3b75:	je     3b95 <botlish_fn_42+0x41>
    3b7b:	add    rsp,0x10
    3b7f:	mov    rsp,rbp
    3b82:	pop    rbp
    3b83:	ret
    3b84:	mov    rsi,r8
    3b87:	call   3b8c <botlish_fn_42+0x38>
			3b88: R_X86_64_PLT32	botlish_fn_25-0x4 ; ht_new_sized<int>
    3b8c:	test   rax,rax
    3b8f:	jne    3ba1 <botlish_fn_42+0x4d>
    3b95:	xor    rax,rax
    3b98:	add    rsp,0x10
    3b9c:	mov    rsp,rbp
    3b9f:	pop    rbp
    3ba0:	ret
    3ba1:	add    rsp,0x10
    3ba5:	mov    rsp,rbp
    3ba8:	pop    rbp
    3ba9:	ret

0000000000003baa <botlish_entry_42: row_new<bool, int>>:
    3baa:	push   rbp
    3bab:	mov    rbp,rsp
    3bae:	mov    rsi,QWORD PTR [rdx]
    3bb1:	mov    rdx,QWORD PTR [rdx+0x8]
    3bb5:	call   3bba <botlish_entry_42+0x10>
			3bb6: R_X86_64_PLT32	botlish_fn_42-0x4 ; row_new<bool, int>
    3bba:	mov    rsp,rbp
    3bbd:	pop    rbp
    3bbe:	ret

0000000000003bbf <botlish_fn_43: row_fill<HashTable, List[str], List[str], int, int>>:
    3bbf:	push   rbp
    3bc0:	mov    rbp,rsp
    3bc3:	sub    rsp,0x70
    3bc7:	mov    QWORD PTR [rsp+0x40],rbx
    3bcc:	mov    QWORD PTR [rsp+0x48],r12
    3bd1:	mov    QWORD PTR [rsp+0x50],r13
    3bd6:	mov    QWORD PTR [rsp+0x58],r14
    3bdb:	mov    QWORD PTR [rsp+0x60],r15
    3be0:	mov    r15,rdi
    3be3:	mov    QWORD PTR [rsp],rsi
    3be7:	mov    QWORD PTR [rsp+0x8],rdx
    3bec:	mov    QWORD PTR [rsp+0x10],rcx
    3bf1:	mov    r14,rcx
    3bf4:	sar    r8,1
    3bf7:	mov    rbx,r8
    3bfa:	mov    r12,r9
    3bfd:	mov    QWORD PTR [rsp+0x28],rsi
    3c02:	cmp    rbx,r12
    3c05:	jge    3d14 <botlish_fn_43+0x155>
    3c0b:	mov    r13,rdx
    3c0e:	mov    rdx,QWORD PTR [r13+0x8]
    3c12:	mov    rcx,rbx
    3c15:	shl    rcx,1
    3c18:	or     rcx,0x1
    3c1c:	sar    rcx,1
    3c1f:	cmp    rcx,rdx
    3c22:	jb     3c4e <botlish_fn_43+0x8f>
    3c28:	mov    rdx,rbx
    3c2b:	shl    rdx,1
    3c2e:	or     rdx,0x1
    3c32:	mov    rsi,r13
    3c35:	mov    rdi,r15
    3c38:	call   3c3d <botlish_fn_43+0x7e>
			3c39: R_X86_64_PLT32	rt_list_get-0x4
    3c3d:	test   rax,rax
    3c40:	je     3ccd <botlish_fn_43+0x10e>
    3c46:	mov    rdx,rax
    3c49:	jmp    3c56 <botlish_fn_43+0x97>
    3c4e:	mov    rax,QWORD PTR [r13+0x10]
    3c52:	mov    rdx,QWORD PTR [rax+rcx*8]
    3c56:	mov    QWORD PTR [rsp+0x18],rdx
    3c5b:	mov    QWORD PTR [rsp+0x30],rdx
    3c60:	mov    rax,QWORD PTR [r14+0x8]
    3c64:	mov    rcx,rbx
    3c67:	shl    rcx,1
    3c6a:	or     rcx,0x1
    3c6e:	sar    rcx,1
    3c71:	cmp    rcx,rax
    3c74:	jb     3ca5 <botlish_fn_43+0xe6>
    3c7a:	mov    rdx,rbx
    3c7d:	shl    rdx,1
    3c80:	or     rdx,0x1
    3c84:	mov    rsi,r14
    3c87:	mov    rdi,r15
    3c8a:	call   3c8f <botlish_fn_43+0xd0>
			3c8b: R_X86_64_PLT32	rt_list_get-0x4
    3c8f:	test   rax,rax
    3c92:	je     3ccd <botlish_fn_43+0x10e>
    3c98:	mov    rcx,rax
    3c9b:	mov    rsi,QWORD PTR [rsp+0x28]
    3ca0:	jmp    3cb2 <botlish_fn_43+0xf3>
    3ca5:	mov    rax,QWORD PTR [r14+0x10]
    3ca9:	mov    rcx,QWORD PTR [rax+rcx*8]
    3cad:	mov    rsi,QWORD PTR [rsp+0x28]
    3cb2:	mov    QWORD PTR [rsp+0x20],rcx
    3cb7:	mov    rdx,QWORD PTR [rsp+0x30]
    3cbc:	mov    rdi,r15
    3cbf:	call   3cc4 <botlish_fn_43+0x105>
			3cc0: R_X86_64_PLT32	botlish_fn_41-0x4 ; ht_set<HashTable, str, str>
    3cc4:	test   rax,rax
    3cc7:	jne    3cf2 <botlish_fn_43+0x133>
    3ccd:	xor    rax,rax
    3cd0:	mov    rbx,QWORD PTR [rsp+0x40]
    3cd5:	mov    r12,QWORD PTR [rsp+0x48]
    3cda:	mov    r13,QWORD PTR [rsp+0x50]
    3cdf:	mov    r14,QWORD PTR [rsp+0x58]
    3ce4:	mov    r15,QWORD PTR [rsp+0x60]
    3ce9:	add    rsp,0x70
    3ced:	mov    rsp,rbp
    3cf0:	pop    rbp
    3cf1:	ret
    3cf2:	mov    QWORD PTR [rsp],rax
    3cf6:	mov    QWORD PTR [rsp+0x8],r13
    3cfb:	mov    QWORD PTR [rsp+0x10],r14
    3d00:	add    rbx,0x1
    3d07:	mov    rdx,r13
    3d0a:	mov    QWORD PTR [rsp+0x28],rax
    3d0f:	jmp    3c02 <botlish_fn_43+0x43>
    3d14:	mov    rax,QWORD PTR [rsp+0x28]
    3d19:	mov    rbx,QWORD PTR [rsp+0x40]
    3d1e:	mov    r12,QWORD PTR [rsp+0x48]
    3d23:	mov    r13,QWORD PTR [rsp+0x50]
    3d28:	mov    r14,QWORD PTR [rsp+0x58]
    3d2d:	mov    r15,QWORD PTR [rsp+0x60]
    3d32:	add    rsp,0x70
    3d36:	mov    rsp,rbp
    3d39:	pop    rbp
    3d3a:	ret

0000000000003d3b <botlish_entry_43: row_fill<HashTable, List[str], List[str], int, int>>:
    3d3b:	push   rbp
    3d3c:	mov    rbp,rsp
    3d3f:	mov    rsi,QWORD PTR [rdx]
    3d42:	mov    r10,QWORD PTR [rdx+0x8]
    3d46:	mov    rcx,QWORD PTR [rdx+0x10]
    3d4a:	mov    r8,QWORD PTR [rdx+0x18]
    3d4e:	mov    r9,QWORD PTR [rdx+0x20]
    3d52:	sar    r9,1
    3d55:	mov    rdx,r10
    3d58:	call   3d5d <botlish_entry_43+0x22>
			3d59: R_X86_64_PLT32	botlish_fn_43-0x4 ; row_fill<HashTable, List[str], List[str], int, int>
    3d5d:	mov    rsp,rbp
    3d60:	pop    rbp
    3d61:	ret

0000000000003d62 <botlish_fn_44: row_table<List[str], int, List[str], bool>>:
    3d62:	push   rbp
    3d63:	mov    rbp,rsp
    3d66:	sub    rsp,0x50
    3d6a:	mov    QWORD PTR [rsp+0x20],rbx
    3d6f:	mov    QWORD PTR [rsp+0x28],r12
    3d74:	mov    QWORD PTR [rsp+0x30],r13
    3d79:	mov    QWORD PTR [rsp+0x38],r14
    3d7e:	mov    QWORD PTR [rsp+0x40],r15
    3d83:	mov    r12,rdi
    3d86:	mov    QWORD PTR [rsp],rsi
    3d8a:	mov    r15,rsi
    3d8d:	mov    QWORD PTR [rsp+0x8],rdx
    3d92:	mov    QWORD PTR [rsp+0x10],rcx
    3d97:	mov    r13,rcx
    3d9a:	mov    QWORD PTR [rsp+0x18],r8
    3d9f:	mov    rsi,r8
    3da2:	mov    rdi,r12
    3da5:	call   3daa <botlish_fn_44+0x48>
			3da6: R_X86_64_PLT32	botlish_fn_42-0x4 ; row_new<bool, int>
    3daa:	test   rax,rax
    3dad:	je     3df7 <botlish_fn_44+0x95>
    3db3:	mov    QWORD PTR [rsp+0x8],rax
    3db8:	mov    r14,rax
    3dbb:	mov    ebx,0x1
    3dc0:	mov    QWORD PTR [rsp+0x18],0x1
    3dc9:	mov    rsi,r13
    3dcc:	mov    rdi,r12
    3dcf:	call   3dd4 <botlish_fn_44+0x72>
			3dd0: R_X86_64_PLT32	rt_list_len-0x4
    3dd4:	mov    r9,rax
    3dd7:	sar    r9,1
    3dda:	mov    rcx,r13
    3ddd:	mov    rdx,r15
    3de0:	mov    rsi,r14
    3de3:	mov    rdi,r12
    3de6:	mov    r8,rbx
    3de9:	call   3dee <botlish_fn_44+0x8c>
			3dea: R_X86_64_PLT32	botlish_fn_43-0x4 ; row_fill<HashTable, List[str], List[str], int, int>
    3dee:	test   rax,rax
    3df1:	jne    3e1c <botlish_fn_44+0xba>
    3df7:	xor    rax,rax
    3dfa:	mov    rbx,QWORD PTR [rsp+0x20]
    3dff:	mov    r12,QWORD PTR [rsp+0x28]
    3e04:	mov    r13,QWORD PTR [rsp+0x30]
    3e09:	mov    r14,QWORD PTR [rsp+0x38]
    3e0e:	mov    r15,QWORD PTR [rsp+0x40]
    3e13:	add    rsp,0x50
    3e17:	mov    rsp,rbp
    3e1a:	pop    rbp
    3e1b:	ret
    3e1c:	mov    rbx,QWORD PTR [rsp+0x20]
    3e21:	mov    r12,QWORD PTR [rsp+0x28]
    3e26:	mov    r13,QWORD PTR [rsp+0x30]
    3e2b:	mov    r14,QWORD PTR [rsp+0x38]
    3e30:	mov    r15,QWORD PTR [rsp+0x40]
    3e35:	add    rsp,0x50
    3e39:	mov    rsp,rbp
    3e3c:	pop    rbp
    3e3d:	ret

0000000000003e3e <botlish_entry_44: row_table<List[str], int, List[str], bool>>:
    3e3e:	push   rbp
    3e3f:	mov    rbp,rsp
    3e42:	mov    rsi,QWORD PTR [rdx]
    3e45:	mov    r9,QWORD PTR [rdx+0x8]
    3e49:	mov    rcx,QWORD PTR [rdx+0x10]
    3e4d:	mov    r8,QWORD PTR [rdx+0x18]
    3e51:	mov    rdx,r9
    3e54:	call   3e59 <botlish_entry_44+0x1b>
			3e55: R_X86_64_PLT32	botlish_fn_44-0x4 ; row_table<List[str], int, List[str], bool>
    3e59:	mov    rsp,rbp
    3e5c:	pop    rbp
    3e5d:	ret

0000000000003e5e <botlish_fn_45: build_rows<List[List[str]], int, List[str], int, mutarray, int, bool>>:
    3e5e:	push   rbp
    3e5f:	mov    rbp,rsp
    3e62:	sub    rsp,0x90
    3e69:	mov    QWORD PTR [rsp+0x60],rbx
    3e6e:	mov    QWORD PTR [rsp+0x68],r12
    3e73:	mov    QWORD PTR [rsp+0x70],r13
    3e78:	mov    QWORD PTR [rsp+0x78],r14
    3e7d:	mov    QWORD PTR [rsp+0x80],r15
    3e85:	mov    r13,r8
    3e88:	mov    QWORD PTR [rsp+0x38],rdi
    3e8d:	mov    rdi,QWORD PTR [rbp+0x10]
    3e91:	mov    r15,QWORD PTR [rbp+0x18]
    3e95:	mov    QWORD PTR [rsp+0x28],0x0
    3e9e:	mov    QWORD PTR [rsp+0x30],0x0
    3ea7:	mov    QWORD PTR [rsp],rsi
    3eab:	mov    QWORD PTR [rsp+0x8],rcx
    3eb0:	mov    r14,rcx
    3eb3:	mov    QWORD PTR [rsp+0x10],r9
    3eb8:	mov    QWORD PTR [rsp+0x18],rdi
    3ebd:	mov    QWORD PTR [rsp+0x20],r15
    3ec2:	sar    rdx,1
    3ec5:	mov    r12,rdx
    3ec8:	mov    rbx,rsi
    3ecb:	mov    QWORD PTR [rsp+0x40],r9
    3ed0:	mov    QWORD PTR [rsp+0x48],rdi
    3ed5:	mov    rsi,rbx
    3ed8:	mov    rdi,QWORD PTR [rsp+0x38]
    3edd:	call   3ee2 <botlish_fn_45+0x84>
			3ede: R_X86_64_PLT32	rt_list_len-0x4
    3ee2:	sar    rax,1
    3ee5:	cmp    r12,rax
    3ee8:	jge    4013 <botlish_fn_45+0x1b5>
    3eee:	mov    rax,r13
    3ef1:	or     rax,0x1
    3ef5:	mov    QWORD PTR [rsp+0x28],rax
    3efa:	mov    rcx,QWORD PTR [rbx+0x8]
    3efe:	mov    rax,r12
    3f01:	shl    rax,1
    3f04:	or     rax,0x1
    3f08:	sar    rax,1
    3f0b:	cmp    rax,rcx
    3f0e:	jb     3f3c <botlish_fn_45+0xde>
    3f14:	mov    rdx,r12
    3f17:	shl    rdx,1
    3f1a:	or     rdx,0x1
    3f1e:	mov    rsi,rbx
    3f21:	mov    rdi,QWORD PTR [rsp+0x38]
    3f26:	call   3f2b <botlish_fn_45+0xcd>
			3f27: R_X86_64_PLT32	rt_list_get-0x4
    3f2b:	test   rax,rax
    3f2e:	je     4030 <botlish_fn_45+0x1d2>
    3f34:	mov    rcx,rax
    3f37:	jmp    3f44 <botlish_fn_45+0xe6>
    3f3c:	mov    rcx,QWORD PTR [rbx+0x10]
    3f40:	mov    rcx,QWORD PTR [rcx+rax*8]
    3f44:	mov    QWORD PTR [rsp+0x30],rcx
    3f49:	mov    rdx,r13
    3f4c:	or     rdx,0x1
    3f50:	mov    rsi,r14
    3f53:	mov    rdi,QWORD PTR [rsp+0x38]
    3f58:	mov    r8,r15
    3f5b:	call   3f60 <botlish_fn_45+0x102>
			3f5c: R_X86_64_PLT32	botlish_fn_44-0x4 ; row_table<List[str], int, List[str], bool>
    3f60:	test   rax,rax
    3f63:	je     4030 <botlish_fn_45+0x1d2>
    3f69:	mov    QWORD PTR [rsp+0x28],rax
    3f6e:	mov    rcx,rax
    3f71:	mov    rsi,QWORD PTR [rsp+0x40]
    3f76:	mov    rdx,QWORD PTR [rsp+0x48]
    3f7b:	mov    rdi,QWORD PTR [rsp+0x38]
    3f80:	call   3f85 <botlish_fn_45+0x127>
			3f81: R_X86_64_PLT32	botlish_fn_10-0x4 ; geo_append<mutarray, int, HashTable>
    3f85:	test   rax,rax
    3f88:	je     4030 <botlish_fn_45+0x1d2>
    3f8e:	mov    QWORD PTR [rsp+0x10],rax
    3f93:	mov    QWORD PTR [rsp+0x50],rax
    3f98:	mov    QWORD PTR [rsp+0x28],0x3
    3fa1:	mov    rsi,QWORD PTR [rsp+0x48]
    3fa6:	test   rsi,0x1
    3fad:	je     3fcc <botlish_fn_45+0x16e>
    3fb3:	mov    rsi,QWORD PTR [rsp+0x48]
    3fb8:	mov    rax,rsi
    3fbb:	add    rax,0x2
    3fbf:	seto   r10b
    3fc3:	test   r10b,r10b
    3fc6:	je     3fe0 <botlish_fn_45+0x182>
    3fcc:	mov    edx,0x3
    3fd1:	mov    rsi,QWORD PTR [rsp+0x48]
    3fd6:	mov    rdi,QWORD PTR [rsp+0x38]
    3fdb:	call   3fe0 <botlish_fn_45+0x182>
			3fdc: R_X86_64_PLT32	rt_int_add-0x4
    3fe0:	mov    QWORD PTR [rsp],rbx
    3fe4:	mov    QWORD PTR [rsp+0x8],r14
    3fe9:	mov    rcx,QWORD PTR [rsp+0x50]
    3fee:	mov    QWORD PTR [rsp+0x10],rcx
    3ff3:	mov    QWORD PTR [rsp+0x18],rax
    3ff8:	mov    QWORD PTR [rsp+0x20],r15
    3ffd:	add    r12,0x1
    4004:	mov    QWORD PTR [rsp+0x40],rcx
    4009:	mov    QWORD PTR [rsp+0x48],rax
    400e:	jmp    3ed5 <botlish_fn_45+0x77>
    4013:	mov    rdx,QWORD PTR [rsp+0x48]
    4018:	mov    rsi,QWORD PTR [rsp+0x40]
    401d:	mov    rdi,QWORD PTR [rsp+0x38]
    4022:	call   4027 <botlish_fn_45+0x1c9>
			4023: R_X86_64_PLT32	botlish_fn_11-0x4 ; geo_finish<mutarray, int>
    4027:	test   rax,rax
    402a:	jne    405b <botlish_fn_45+0x1fd>
    4030:	xor    rax,rax
    4033:	mov    rbx,QWORD PTR [rsp+0x60]
    4038:	mov    r12,QWORD PTR [rsp+0x68]
    403d:	mov    r13,QWORD PTR [rsp+0x70]
    4042:	mov    r14,QWORD PTR [rsp+0x78]
    4047:	mov    r15,QWORD PTR [rsp+0x80]
    404f:	add    rsp,0x90
    4056:	mov    rsp,rbp
    4059:	pop    rbp
    405a:	ret
    405b:	mov    rbx,QWORD PTR [rsp+0x60]
    4060:	mov    r12,QWORD PTR [rsp+0x68]
    4065:	mov    r13,QWORD PTR [rsp+0x70]
    406a:	mov    r14,QWORD PTR [rsp+0x78]
    406f:	mov    r15,QWORD PTR [rsp+0x80]
    4077:	add    rsp,0x90
    407e:	mov    rsp,rbp
    4081:	pop    rbp
    4082:	ret

0000000000004083 <botlish_entry_45: build_rows<List[List[str]], int, List[str], int, mutarray, int, bool>>:
    4083:	push   rbp
    4084:	mov    rbp,rsp
    4087:	sub    rsp,0x10
    408b:	mov    rsi,QWORD PTR [rdx]
    408e:	mov    r10,QWORD PTR [rdx+0x8]
    4092:	mov    rcx,QWORD PTR [rdx+0x10]
    4096:	mov    r8,QWORD PTR [rdx+0x18]
    409a:	mov    r9,QWORD PTR [rdx+0x20]
    409e:	mov    r11,QWORD PTR [rdx+0x28]
    40a2:	mov    rax,QWORD PTR [rdx+0x30]
    40a6:	mov    QWORD PTR [rsp],r11
    40aa:	mov    QWORD PTR [rsp+0x8],rax
    40af:	mov    rdx,r10
    40b2:	call   40b7 <botlish_entry_45+0x34>
			40b3: R_X86_64_PLT32	botlish_fn_45-0x4 ; build_rows<List[List[str]], int, List[str], int, mutarray, int, bool>
    40b7:	add    rsp,0x10
    40bb:	mov    rsp,rbp
    40be:	pop    rbp
    40bf:	ret

00000000000040c0 <botlish_fn_46: csv_records_generic<str, bool>>:
    40c0:	push   rbp
    40c1:	mov    rbp,rsp
    40c4:	sub    rsp,0x80
    40cb:	mov    QWORD PTR [rsp+0x50],rbx
    40d0:	mov    QWORD PTR [rsp+0x58],r12
    40d5:	mov    QWORD PTR [rsp+0x60],r13
    40da:	mov    QWORD PTR [rsp+0x68],r14
    40df:	mov    QWORD PTR [rsp+0x70],r15
    40e4:	mov    r12,rdi
    40e7:	mov    QWORD PTR [rsp+0x20],0x0
    40f0:	mov    QWORD PTR [rsp+0x28],0x0
    40f9:	mov    QWORD PTR [rsp+0x30],0x0
    4102:	mov    QWORD PTR [rsp+0x38],0x0
    410b:	mov    QWORD PTR [rsp+0x40],0x0
    4114:	mov    QWORD PTR [rsp+0x10],rsi
    4119:	mov    QWORD PTR [rsp+0x18],rdx
    411e:	mov    r13,rdx
    4121:	mov    rdi,r12
    4124:	call   4129 <botlish_fn_46+0x69>
			4125: R_X86_64_PLT32	botlish_fn_20-0x4 ; csv_parse<str>
    4129:	mov    rcx,rax
    412c:	mov    r14,rax
    412f:	test   rax,rcx
    4132:	je     424c <botlish_fn_46+0x18c>
    4138:	mov    rax,r14
    413b:	mov    QWORD PTR [rsp+0x10],rax
    4140:	mov    rsi,r14
    4143:	mov    rdi,r12
    4146:	call   414b <botlish_fn_46+0x8b>
			4147: R_X86_64_PLT32	rt_list_len-0x4
    414b:	sar    rax,1
    414e:	cmp    rax,0x1
    4152:	jle    4235 <botlish_fn_46+0x175>
    4158:	mov    rax,r14
    415b:	mov    rax,QWORD PTR [rax+0x10]
    415f:	mov    rbx,QWORD PTR [rax]
    4162:	mov    QWORD PTR [rsp+0x20],rbx
    4167:	mov    rsi,rbx
    416a:	mov    rdi,r12
    416d:	call   4172 <botlish_fn_46+0xb2>
			416e: R_X86_64_PLT32	rt_list_len-0x4
    4172:	mov    r15,rbx
    4175:	mov    QWORD PTR [rsp+0x28],rax
    417a:	mov    QWORD PTR [rsp+0x48],rax
    417f:	mov    rax,r14
    4182:	mov    rcx,QWORD PTR [rax+0x10]
    4186:	mov    rcx,QWORD PTR [rcx+0x8]
    418a:	mov    QWORD PTR [rsp+0x30],rcx
    418f:	mov    rbx,r13
    4192:	mov    rdx,QWORD PTR [rsp+0x48]
    4197:	mov    rsi,r15
    419a:	mov    rdi,r12
    419d:	mov    r8,rbx
    41a0:	call   41a5 <botlish_fn_46+0xe5>
			41a1: R_X86_64_PLT32	botlish_fn_44-0x4 ; row_table<List[str], int, List[str], bool>
    41a5:	test   rax,rax
    41a8:	je     424c <botlish_fn_46+0x18c>
    41ae:	mov    QWORD PTR [rsp+0x30],rax
    41b3:	mov    rsi,rax
    41b6:	mov    QWORD PTR [rsp+0x38],0x5
    41bf:	mov    rdi,r12
    41c2:	call   41c7 <botlish_fn_46+0x107>
			41c3: R_X86_64_PLT32	botlish_fn_3-0x4 ; geo_new<HashTable>
    41c7:	test   rax,rax
    41ca:	je     424c <botlish_fn_46+0x18c>
    41d0:	mov    QWORD PTR [rsp+0x30],rax
    41d5:	mov    r9,rax
    41d8:	mov    eax,0x3
    41dd:	mov    QWORD PTR [rsp+0x40],0x3
    41e6:	mov    edx,0x5
    41eb:	mov    QWORD PTR [rsp],rax
    41ef:	mov    QWORD PTR [rsp+0x8],rbx
    41f4:	mov    rcx,r15
    41f7:	mov    rsi,r14
    41fa:	mov    rdi,r12
    41fd:	mov    r8,QWORD PTR [rsp+0x48]
    4202:	call   4207 <botlish_fn_46+0x147>
			4203: R_X86_64_PLT32	botlish_fn_45-0x4 ; build_rows<List[List[str]], int, List[str], int, mutarray, int, bool>
    4207:	test   rax,rax
    420a:	je     424c <botlish_fn_46+0x18c>
    4210:	mov    rbx,QWORD PTR [rsp+0x50]
    4215:	mov    r12,QWORD PTR [rsp+0x58]
    421a:	mov    r13,QWORD PTR [rsp+0x60]
    421f:	mov    r14,QWORD PTR [rsp+0x68]
    4224:	mov    r15,QWORD PTR [rsp+0x70]
    4229:	add    rsp,0x80
    4230:	mov    rsp,rbp
    4233:	pop    rbp
    4234:	ret
    4235:	xor    rdx,rdx
    4238:	mov    rdi,r12
    423b:	mov    rsi,rdx
    423e:	call   4243 <botlish_fn_46+0x183>
			423f: R_X86_64_PLT32	rt_list_new-0x4
    4243:	test   rax,rax
    4246:	jne    4274 <botlish_fn_46+0x1b4>
    424c:	xor    rax,rax
    424f:	mov    rbx,QWORD PTR [rsp+0x50]
    4254:	mov    r12,QWORD PTR [rsp+0x58]
    4259:	mov    r13,QWORD PTR [rsp+0x60]
    425e:	mov    r14,QWORD PTR [rsp+0x68]
    4263:	mov    r15,QWORD PTR [rsp+0x70]
    4268:	add    rsp,0x80
    426f:	mov    rsp,rbp
    4272:	pop    rbp
    4273:	ret
    4274:	mov    rbx,QWORD PTR [rsp+0x50]
    4279:	mov    r12,QWORD PTR [rsp+0x58]
    427e:	mov    r13,QWORD PTR [rsp+0x60]
    4283:	mov    r14,QWORD PTR [rsp+0x68]
    4288:	mov    r15,QWORD PTR [rsp+0x70]
    428d:	add    rsp,0x80
    4294:	mov    rsp,rbp
    4297:	pop    rbp
    4298:	ret

0000000000004299 <botlish_entry_46: csv_records_generic<str, bool>>:
    4299:	push   rbp
    429a:	mov    rbp,rsp
    429d:	mov    rsi,QWORD PTR [rdx]
    42a0:	mov    rdx,QWORD PTR [rdx+0x8]
    42a4:	call   42a9 <botlish_entry_46+0x10>
			42a5: R_X86_64_PLT32	botlish_fn_46-0x4 ; csv_records_generic<str, bool>
    42a9:	mov    rsp,rbp
    42ac:	pop    rbp
    42ad:	ret

00000000000042ae <botlish_fn_47: csv_records<str>>:
    42ae:	push   rbp
    42af:	mov    rbp,rsp
    42b2:	sub    rsp,0x10
    42b6:	mov    QWORD PTR [rsp],rsi
    42ba:	mov    edx,0x2
    42bf:	mov    QWORD PTR [rsp+0x8],0x2
    42c8:	call   42cd <botlish_fn_47+0x1f>
			42c9: R_X86_64_PLT32	botlish_fn_46-0x4 ; csv_records_generic<str, bool>
    42cd:	test   rax,rax
    42d0:	jne    42e2 <botlish_fn_47+0x34>
    42d6:	xor    rax,rax
    42d9:	add    rsp,0x10
    42dd:	mov    rsp,rbp
    42e0:	pop    rbp
    42e1:	ret
    42e2:	add    rsp,0x10
    42e6:	mov    rsp,rbp
    42e9:	pop    rbp
    42ea:	ret

00000000000042eb <botlish_entry_47: csv_records<str>>:
    42eb:	push   rbp
    42ec:	mov    rbp,rsp
    42ef:	mov    rsi,QWORD PTR [rdx]
    42f2:	call   42f7 <botlish_entry_47+0xc>
			42f3: R_X86_64_PLT32	botlish_fn_47-0x4 ; csv_records<str>
    42f7:	mov    rsp,rbp
    42fa:	pop    rbp
    42fb:	ret

00000000000042fc <botlish_fn_48: csv_records_presized<str>>:
    42fc:	push   rbp
    42fd:	mov    rbp,rsp
    4300:	sub    rsp,0x10
    4304:	mov    QWORD PTR [rsp],rsi
    4308:	mov    edx,0x6
    430d:	mov    QWORD PTR [rsp+0x8],0x6
    4316:	call   431b <botlish_fn_48+0x1f>
			4317: R_X86_64_PLT32	botlish_fn_46-0x4 ; csv_records_generic<str, bool>
    431b:	test   rax,rax
    431e:	jne    4330 <botlish_fn_48+0x34>
    4324:	xor    rax,rax
    4327:	add    rsp,0x10
    432b:	mov    rsp,rbp
    432e:	pop    rbp
    432f:	ret
    4330:	add    rsp,0x10
    4334:	mov    rsp,rbp
    4337:	pop    rbp
    4338:	ret

0000000000004339 <botlish_entry_48: csv_records_presized<str>>:
    4339:	push   rbp
    433a:	mov    rbp,rsp
    433d:	mov    rsi,QWORD PTR [rdx]
    4340:	call   4345 <botlish_entry_48+0xc>
			4341: R_X86_64_PLT32	botlish_fn_48-0x4 ; csv_records_presized<str>
    4345:	mov    rsp,rbp
    4348:	pop    rbp
    4349:	ret
    434a:	add    BYTE PTR [rax],al
    434c:	add    BYTE PTR [rax],al
	...

0000000000004350 <botlish_fn_49: sample_checks<generic>>:
    4350:	push   rbp
    4351:	mov    rbp,rsp
    4354:	sub    rsp,0xc0
    435b:	mov    QWORD PTR [rsp+0x90],rbx
    4363:	mov    QWORD PTR [rsp+0x98],r12
    436b:	mov    QWORD PTR [rsp+0xa0],r13
    4373:	mov    QWORD PTR [rsp+0xa8],r14
    437b:	mov    QWORD PTR [rsp+0xb0],r15
    4383:	mov    QWORD PTR [rsp+0x8],0x0
    438c:	mov    QWORD PTR [rsp+0x10],0x0
    4395:	mov    QWORD PTR [rsp+0x18],0x0
    439e:	mov    QWORD PTR [rsp+0x20],0x0
    43a7:	mov    QWORD PTR [rsp+0x28],0x0
    43b0:	mov    QWORD PTR [rsp+0x30],0x0
    43b9:	mov    QWORD PTR [rsp+0x38],0x0
    43c2:	mov    rax,QWORD PTR [rdi+0x10]
    43c6:	mov    r13,rdi
    43c9:	mov    rsi,QWORD PTR [rax+0x20]
    43cd:	mov    QWORD PTR [rsp],rsi
    43d1:	call   43d6 <botlish_fn_49+0x86>
			43d2: R_X86_64_PLT32	botlish_fn_47-0x4 ; csv_records<str>
    43d6:	mov    rsi,rax
    43d9:	mov    r12,rax
    43dc:	test   rax,rsi
    43df:	je     4764 <botlish_fn_49+0x414>
    43e5:	mov    rax,r12
    43e8:	mov    QWORD PTR [rsp],rax
    43ec:	mov    rdi,r13
    43ef:	mov    rax,QWORD PTR [rdi+0x10]
    43f3:	mov    rsi,QWORD PTR [rax+0x20]
    43f7:	mov    QWORD PTR [rsp+0x8],rsi
    43fc:	call   4401 <botlish_fn_49+0xb1>
			43fd: R_X86_64_PLT32	botlish_fn_48-0x4 ; csv_records_presized<str>
    4401:	mov    rbx,rax
    4404:	test   rbx,rbx
    4407:	je     4764 <botlish_fn_49+0x414>
    440d:	mov    rax,r12
    4410:	mov    rax,QWORD PTR [rax+0x8]
    4414:	test   rax,rax
    4417:	jne    443e <botlish_fn_49+0xee>
    441d:	mov    edx,0x1
    4422:	mov    rsi,r12
    4425:	mov    rdi,r13
    4428:	call   442d <botlish_fn_49+0xdd>
			4429: R_X86_64_PLT32	rt_list_get-0x4
    442d:	test   rax,rax
    4430:	je     4764 <botlish_fn_49+0x414>
    4436:	mov    rsi,rax
    4439:	jmp    4446 <botlish_fn_49+0xf6>
    443e:	mov    rax,QWORD PTR [r12+0x10]
    4443:	mov    rsi,QWORD PTR [rax]
    4446:	mov    QWORD PTR [rsp+0x8],rsi
    444b:	mov    r15,rsi
    444e:	mov    rax,QWORD PTR [r12+0x8]
    4453:	cmp    rax,0x1
    4457:	ja     447e <botlish_fn_49+0x12e>
    445d:	mov    edx,0x3
    4462:	mov    rsi,r12
    4465:	mov    rdi,r13
    4468:	call   446d <botlish_fn_49+0x11d>
			4469: R_X86_64_PLT32	rt_list_get-0x4
    446d:	test   rax,rax
    4470:	je     4764 <botlish_fn_49+0x414>
    4476:	mov    rsi,rax
    4479:	jmp    4487 <botlish_fn_49+0x137>
    447e:	mov    rax,QWORD PTR [r12+0x10]
    4483:	mov    rsi,QWORD PTR [rax+0x8]
    4487:	mov    QWORD PTR [rsp+0x10],rsi
    448c:	mov    r14,rsi
    448f:	mov    rax,QWORD PTR [rbx+0x8]
    4493:	mov    rsi,rbx
    4496:	test   rax,rax
    4499:	jne    44bd <botlish_fn_49+0x16d>
    449f:	mov    edx,0x1
    44a4:	mov    rdi,r13
    44a7:	call   44ac <botlish_fn_49+0x15c>
			44a8: R_X86_64_PLT32	rt_list_get-0x4
    44ac:	test   rax,rax
    44af:	je     4764 <botlish_fn_49+0x414>
    44b5:	mov    rsi,rax
    44b8:	jmp    44c4 <botlish_fn_49+0x174>
    44bd:	mov    rax,QWORD PTR [rsi+0x10]
    44c1:	mov    rsi,QWORD PTR [rax]
    44c4:	mov    QWORD PTR [rsp+0x18],rsi
    44c9:	mov    rdi,r13
    44cc:	mov    QWORD PTR [rsp+0x78],rsi
    44d1:	mov    rax,QWORD PTR [rdi+0x10]
    44d5:	mov    rdx,QWORD PTR [rax+0x28]
    44d9:	mov    QWORD PTR [rsp+0x20],rdx
    44de:	mov    rsi,r15
    44e1:	call   44e6 <botlish_fn_49+0x196>
			44e2: R_X86_64_PLT32	botlish_fn_33-0x4 ; ht_get<HashTable, str>
    44e6:	test   rax,rax
    44e9:	je     4764 <botlish_fn_49+0x414>
    44ef:	mov    QWORD PTR [rsp+0x20],rax
    44f4:	mov    rbx,rax
    44f7:	mov    rdi,r13
    44fa:	mov    rax,QWORD PTR [rdi+0x10]
    44fe:	mov    rdx,QWORD PTR [rax+0x28]
    4502:	mov    QWORD PTR [rsp+0x28],rdx
    4507:	mov    rsi,QWORD PTR [rsp+0x78]
    450c:	call   4511 <botlish_fn_49+0x1c1>
			450d: R_X86_64_PLT32	botlish_fn_33-0x4 ; ht_get<HashTable, str>
    4511:	test   rax,rax
    4514:	je     4764 <botlish_fn_49+0x414>
    451a:	mov    rcx,rbx
    451d:	mov    rdx,rcx
    4520:	and    rdx,rax
    4523:	test   rdx,0x1
    452a:	jne    454c <botlish_fn_49+0x1fc>
    4530:	mov    rdx,rax
    4533:	mov    rsi,rbx
    4536:	mov    rdi,r13
    4539:	call   453e <botlish_fn_49+0x1ee>
			453a: R_X86_64_PLT32	rt_value_eq-0x4
    453e:	test   rax,rax
    4541:	je     4764 <botlish_fn_49+0x414>
    4547:	jmp    4562 <botlish_fn_49+0x212>
    454c:	mov    rdx,rax
    454f:	mov    rsi,rbx
    4552:	mov    eax,0x2
    4557:	cmp    rsi,rdx
    455a:	cmove  rax,QWORD PTR [rip+0x26e]        # 47d0 <botlish_fn_49+0x480>
    4562:	mov    ebx,0x6
    4567:	cmp    rax,0x6
    456b:	je     4586 <botlish_fn_49+0x236>
    4571:	mov    ebx,0x2
    4576:	mov    QWORD PTR [rsp],0x2
    457e:	mov    rsi,r12
    4581:	jmp    4625 <botlish_fn_49+0x2d5>
    4586:	mov    rsi,r15
    4589:	mov    rdi,r13
    458c:	call   4591 <botlish_fn_49+0x241>
			458d: R_X86_64_PLT32	botlish_fn_26-0x4 ; ht_size<HashTable>
    4591:	test   rax,rax
    4594:	mov    QWORD PTR [rsp+0x88],rax
    459c:	je     4764 <botlish_fn_49+0x414>
    45a2:	mov    rsi,QWORD PTR [rsp+0x78]
    45a7:	mov    rdi,r13
    45aa:	call   45af <botlish_fn_49+0x25f>
			45ab: R_X86_64_PLT32	botlish_fn_26-0x4 ; ht_size<HashTable>
    45af:	test   rax,rax
    45b2:	je     4764 <botlish_fn_49+0x414>
    45b8:	mov    rcx,QWORD PTR [rsp+0x88]
    45c0:	mov    rdx,rcx
    45c3:	and    rdx,rax
    45c6:	test   rdx,0x1
    45cd:	jne    45f4 <botlish_fn_49+0x2a4>
    45d3:	mov    rdx,rax
    45d6:	mov    rsi,QWORD PTR [rsp+0x88]
    45de:	mov    rdi,r13
    45e1:	call   45e6 <botlish_fn_49+0x296>
			45e2: R_X86_64_PLT32	rt_value_eq-0x4
    45e6:	test   rax,rax
    45e9:	je     4764 <botlish_fn_49+0x414>
    45ef:	jmp    460f <botlish_fn_49+0x2bf>
    45f4:	mov    rdx,rax
    45f7:	mov    rsi,QWORD PTR [rsp+0x88]
    45ff:	mov    eax,0x2
    4604:	cmp    rsi,rdx
    4607:	cmove  rax,QWORD PTR [rip+0x1c1]        # 47d0 <botlish_fn_49+0x480>
    460f:	cmp    rax,0x6
    4613:	je     461e <botlish_fn_49+0x2ce>
    4619:	mov    ebx,0x2
    461e:	mov    QWORD PTR [rsp],rbx
    4622:	mov    rsi,r12
    4625:	mov    rdi,r13
    4628:	call   462d <botlish_fn_49+0x2dd>
			4629: R_X86_64_PLT32	rt_list_len-0x4
    462d:	mov    QWORD PTR [rsp+0x18],rax
    4632:	mov    rdi,r13
    4635:	mov    r12,rax
    4638:	mov    rax,QWORD PTR [rdi+0x10]
    463c:	mov    rdx,QWORD PTR [rax+0x28]
    4640:	mov    QWORD PTR [rsp+0x20],rdx
    4645:	mov    rsi,r15
    4648:	call   464d <botlish_fn_49+0x2fd>
			4649: R_X86_64_PLT32	botlish_fn_33-0x4 ; ht_get<HashTable, str>
    464d:	test   rax,rax
    4650:	je     4764 <botlish_fn_49+0x414>
    4656:	mov    QWORD PTR [rsp+0x20],rax
    465b:	mov    rdi,r13
    465e:	mov    QWORD PTR [rsp+0x88],rax
    4666:	mov    rax,QWORD PTR [rdi+0x10]
    466a:	mov    rdx,QWORD PTR [rax+0x30]
    466e:	mov    QWORD PTR [rsp+0x28],rdx
    4673:	mov    rsi,r15
    4676:	call   467b <botlish_fn_49+0x32b>
			4677: R_X86_64_PLT32	botlish_fn_33-0x4 ; ht_get<HashTable, str>
    467b:	test   rax,rax
    467e:	je     4764 <botlish_fn_49+0x414>
    4684:	mov    QWORD PTR [rsp+0x28],rax
    4689:	mov    rdi,r13
    468c:	mov    QWORD PTR [rsp+0x80],rax
    4694:	mov    rax,QWORD PTR [rdi+0x10]
    4698:	mov    rdx,QWORD PTR [rax+0x38]
    469c:	mov    QWORD PTR [rsp+0x30],rdx
    46a1:	mov    rsi,r15
    46a4:	call   46a9 <botlish_fn_49+0x359>
			46a5: R_X86_64_PLT32	botlish_fn_33-0x4 ; ht_get<HashTable, str>
    46a9:	test   rax,rax
    46ac:	je     4764 <botlish_fn_49+0x414>
    46b2:	mov    QWORD PTR [rsp+0x8],rax
    46b7:	mov    rdi,r13
    46ba:	mov    r15,rax
    46bd:	mov    rax,QWORD PTR [rdi+0x10]
    46c1:	mov    rdx,QWORD PTR [rax+0x28]
    46c5:	mov    QWORD PTR [rsp+0x30],rdx
    46ca:	mov    rsi,r14
    46cd:	call   46d2 <botlish_fn_49+0x382>
			46ce: R_X86_64_PLT32	botlish_fn_33-0x4 ; ht_get<HashTable, str>
    46d2:	test   rax,rax
    46d5:	je     4764 <botlish_fn_49+0x414>
    46db:	mov    QWORD PTR [rsp+0x30],rax
    46e0:	mov    rdi,r13
    46e3:	mov    QWORD PTR [rsp+0x78],rax
    46e8:	mov    rax,QWORD PTR [rdi+0x10]
    46ec:	mov    rdx,QWORD PTR [rax+0x38]
    46f0:	mov    QWORD PTR [rsp+0x38],rdx
    46f5:	mov    rsi,r14
    46f8:	call   46fd <botlish_fn_49+0x3ad>
			46f9: R_X86_64_PLT32	botlish_fn_33-0x4 ; ht_get<HashTable, str>
    46fd:	test   rax,rax
    4700:	je     4764 <botlish_fn_49+0x414>
    4706:	mov    QWORD PTR [rsp+0x10],rax
    470b:	lea    rdx,[rsp+0x40]
    4710:	mov    r9,r12
    4713:	mov    QWORD PTR [rsp+0x40],r9
    4718:	mov    rcx,QWORD PTR [rsp+0x88]
    4720:	mov    QWORD PTR [rsp+0x48],rcx
    4725:	mov    rcx,QWORD PTR [rsp+0x80]
    472d:	mov    QWORD PTR [rsp+0x50],rcx
    4732:	mov    rcx,r15
    4735:	mov    QWORD PTR [rsp+0x58],rcx
    473a:	mov    rcx,QWORD PTR [rsp+0x78]
    473f:	mov    QWORD PTR [rsp+0x60],rcx
    4744:	mov    QWORD PTR [rsp+0x68],rax
    4749:	mov    QWORD PTR [rsp+0x70],rbx
    474e:	mov    esi,0x7
    4753:	mov    rdi,r13
    4756:	call   475b <botlish_fn_49+0x40b>
			4757: R_X86_64_PLT32	rt_list_new-0x4
    475b:	test   rax,rax
    475e:	jne    479b <botlish_fn_49+0x44b>
    4764:	xor    rax,rax
    4767:	mov    rbx,QWORD PTR [rsp+0x90]
    476f:	mov    r12,QWORD PTR [rsp+0x98]
    4777:	mov    r13,QWORD PTR [rsp+0xa0]
    477f:	mov    r14,QWORD PTR [rsp+0xa8]
    4787:	mov    r15,QWORD PTR [rsp+0xb0]
    478f:	add    rsp,0xc0
    4796:	mov    rsp,rbp
    4799:	pop    rbp
    479a:	ret
    479b:	mov    rbx,QWORD PTR [rsp+0x90]
    47a3:	mov    r12,QWORD PTR [rsp+0x98]
    47ab:	mov    r13,QWORD PTR [rsp+0xa0]
    47b3:	mov    r14,QWORD PTR [rsp+0xa8]
    47bb:	mov    r15,QWORD PTR [rsp+0xb0]
    47c3:	add    rsp,0xc0
    47ca:	mov    rsp,rbp
    47cd:	pop    rbp
    47ce:	ret
    47cf:	add    BYTE PTR [rsi],al
    47d1:	add    BYTE PTR [rax],al
    47d3:	add    BYTE PTR [rax],al
    47d5:	add    BYTE PTR [rax],al
	...

00000000000047d8 <botlish_entry_49: sample_checks<generic>>:
    47d8:	push   rbp
    47d9:	mov    rbp,rsp
    47dc:	call   47e1 <botlish_entry_49+0x9>
			47dd: R_X86_64_PLT32	botlish_fn_49-0x4 ; sample_checks<generic>
    47e1:	mov    rsp,rbp
    47e4:	pop    rbp
    47e5:	ret

00000000000047e6 <botlish_fn_50: sample<generic>>:
    47e6:	push   rbp
    47e7:	mov    rbp,rsp
    47ea:	sub    rsp,0x10
    47ee:	mov    QWORD PTR [rsp],rbx
    47f2:	mov    rbx,rdi
    47f5:	mov    rdi,rbx
    47f8:	call   47fd <botlish_fn_50+0x17>
			47f9: R_X86_64_PLT32	botlish_fn_49-0x4 ; sample_checks<generic>
    47fd:	test   rax,rax
    4800:	jne    48b9 <botlish_fn_50+0xd3>
    4806:	mov    rdi,rbx
    4809:	call   480e <botlish_fn_50+0x28>
			480a: R_X86_64_PLT32	rt_declared_error-0x4
    480e:	cmp    rax,0x40000001
    4814:	je     488a <botlish_fn_50+0xa4>
    481a:	mov    rdi,rbx
    481d:	call   4822 <botlish_fn_50+0x3c>
			481e: R_X86_64_PLT32	rt_declared_error-0x4
    4822:	cmp    rax,0x40000002
    4828:	je     4866 <botlish_fn_50+0x80>
    482e:	mov    rdi,rbx
    4831:	call   4836 <botlish_fn_50+0x50>
			4832: R_X86_64_PLT32	rt_declared_error-0x4
    4836:	cmp    rax,0x40000003
    483c:	jne    48a9 <botlish_fn_50+0xc3>
    4842:	mov    rdi,rbx
    4845:	call   484a <botlish_fn_50+0x64>
			4846: R_X86_64_PLT32	rt_clear_declared_error-0x4
    484a:	xor    rdx,rdx
    484d:	mov    rdi,rbx
    4850:	mov    rsi,rdx
    4853:	call   4858 <botlish_fn_50+0x72>
			4854: R_X86_64_PLT32	rt_list_new-0x4
    4858:	test   rax,rax
    485b:	je     48a9 <botlish_fn_50+0xc3>
    4861:	jmp    48b9 <botlish_fn_50+0xd3>
    4866:	mov    rdi,rbx
    4869:	call   486e <botlish_fn_50+0x88>
			486a: R_X86_64_PLT32	rt_clear_declared_error-0x4
    486e:	xor    rdx,rdx
    4871:	mov    rdi,rbx
    4874:	mov    rsi,rdx
    4877:	call   487c <botlish_fn_50+0x96>
			4878: R_X86_64_PLT32	rt_list_new-0x4
    487c:	test   rax,rax
    487f:	je     48a9 <botlish_fn_50+0xc3>
    4885:	jmp    48b9 <botlish_fn_50+0xd3>
    488a:	mov    rdi,rbx
    488d:	call   4892 <botlish_fn_50+0xac>
			488e: R_X86_64_PLT32	rt_clear_declared_error-0x4
    4892:	xor    rdx,rdx
    4895:	mov    rdi,rbx
    4898:	mov    rsi,rdx
    489b:	call   48a0 <botlish_fn_50+0xba>
			489c: R_X86_64_PLT32	rt_list_new-0x4
    48a0:	test   rax,rax
    48a3:	jne    48b9 <botlish_fn_50+0xd3>
    48a9:	xor    rax,rax
    48ac:	mov    rbx,QWORD PTR [rsp]
    48b0:	add    rsp,0x10
    48b4:	mov    rsp,rbp
    48b7:	pop    rbp
    48b8:	ret
    48b9:	mov    rbx,QWORD PTR [rsp]
    48bd:	add    rsp,0x10
    48c1:	mov    rsp,rbp
    48c4:	pop    rbp
    48c5:	ret

00000000000048c6 <botlish_entry_50: sample<generic>>:
    48c6:	push   rbp
    48c7:	mov    rbp,rsp
    48ca:	call   48cf <botlish_entry_50+0x9>
			48cb: R_X86_64_PLT32	botlish_fn_50-0x4 ; sample<generic>
    48cf:	mov    rsp,rbp
    48d2:	pop    rbp
    48d3:	ret
