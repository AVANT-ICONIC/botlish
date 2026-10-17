; source:  examples/stdlib/csv_records.bot
; backend: Cranelift (specialize=1), native::object
; object:  ELF64 x86-64, unlinked (Botlish-generated code only; runtime
;          helpers are unresolved imports, so their bodies are not present)
; format:  objdump -dr --no-show-raw-insn -M intel
; total machine code bytes: 19616  (per function: 45 89 89 89 357 420 420 420 202 202 202 81 365 309 470 932 310 758 215 480 318 427 385 70 493 114 69 69 46 182 178 628 1032 341 388 407 616 666 809 673 928 700 107 433 259 629 515 78 78 1222 301)
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
    2304:	sub    rsp,0x70
    2308:	mov    QWORD PTR [rsp+0x40],rbx
    230d:	mov    QWORD PTR [rsp+0x48],r12
    2312:	mov    QWORD PTR [rsp+0x50],r13
    2317:	mov    QWORD PTR [rsp+0x58],r14
    231c:	mov    QWORD PTR [rsp+0x60],r15
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
    234f:	mov    QWORD PTR [rsp+0x20],rdx
    2354:	or     rbx,0x1
    2358:	mov    QWORD PTR [rsp+0x18],rbx
    235d:	mov    rdx,rbx
    2360:	mov    rdi,r14
    2363:	call   2368 <botlish_fn_32+0x68>
			2364: R_X86_64_PLT32	rt_mutarray_get-0x4
    2368:	mov    rcx,rax
    236b:	mov    QWORD PTR [rsp+0x28],rax
    2370:	mov    QWORD PTR [rsp+0x30],rbx
    2375:	test   rax,rcx
    2378:	je     25b0 <botlish_fn_32+0x2b0>
    237e:	mov    rax,QWORD PTR [rsp+0x28]
    2383:	test   rax,0x1
    2389:	jne    23b6 <botlish_fn_32+0xb6>
    238f:	mov    edx,0x1
    2394:	mov    rsi,QWORD PTR [rsp+0x28]
    2399:	mov    rdi,r14
    239c:	call   23a1 <botlish_fn_32+0xa1>
			239d: R_X86_64_PLT32	rt_int_cmp-0x4
    23a1:	mov    ecx,0x2
    23a6:	test   rax,rax
    23a9:	cmove  rcx,QWORD PTR [rip+0x2f7]        # 26a8 <botlish_fn_32+0x3a8>
    23b1:	jmp    23cc <botlish_fn_32+0xcc>
    23b6:	mov    ecx,0x2
    23bb:	mov    rax,QWORD PTR [rsp+0x28]
    23c0:	cmp    rax,0x1
    23c4:	cmove  rcx,QWORD PTR [rip+0x2dc]        # 26a8 <botlish_fn_32+0x3a8>
    23cc:	cmp    rcx,0x6
    23d0:	je     2602 <botlish_fn_32+0x302>
    23d6:	mov    rax,QWORD PTR [rsp+0x28]
    23db:	test   rax,0x1
    23e1:	jne    240e <botlish_fn_32+0x10e>
    23e7:	mov    edx,0x3
    23ec:	mov    rsi,QWORD PTR [rsp+0x28]
    23f1:	mov    rdi,r14
    23f4:	call   23f9 <botlish_fn_32+0xf9>
			23f5: R_X86_64_PLT32	rt_int_cmp-0x4
    23f9:	mov    ecx,0x2
    23fe:	test   rax,rax
    2401:	cmove  rcx,QWORD PTR [rip+0x29f]        # 26a8 <botlish_fn_32+0x3a8>
    2409:	jmp    2424 <botlish_fn_32+0x124>
    240e:	mov    ecx,0x2
    2413:	mov    rax,QWORD PTR [rsp+0x28]
    2418:	cmp    rax,0x3
    241c:	cmove  rcx,QWORD PTR [rip+0x284]        # 26a8 <botlish_fn_32+0x3a8>
    2424:	cmp    rcx,0x6
    2428:	je     243b <botlish_fn_32+0x13b>
    242e:	mov    rax,QWORD PTR [rsp+0x28]
    2433:	mov    rbx,r15
    2436:	jmp    24ab <botlish_fn_32+0x1ab>
    243b:	mov    rax,QWORD PTR [r12+0x18]
    2440:	mov    rsi,QWORD PTR [rax+0x8]
    2444:	mov    rdx,QWORD PTR [rsp+0x30]
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
    24a6:	mov    rax,QWORD PTR [rsp+0x28]
    24ab:	test   rax,0x1
    24b1:	mov    QWORD PTR [rsp+0x28],rax
    24b6:	jne    24e3 <botlish_fn_32+0x1e3>
    24bc:	mov    edx,0x5
    24c1:	mov    rsi,QWORD PTR [rsp+0x28]
    24c6:	mov    rdi,r14
    24c9:	call   24ce <botlish_fn_32+0x1ce>
			24ca: R_X86_64_PLT32	rt_int_cmp-0x4
    24ce:	mov    ecx,0x2
    24d3:	test   rax,rax
    24d6:	cmove  rcx,QWORD PTR [rip+0x1ca]        # 26a8 <botlish_fn_32+0x3a8>
    24de:	jmp    24f9 <botlish_fn_32+0x1f9>
    24e3:	mov    rsi,QWORD PTR [rsp+0x28]
    24e8:	mov    ecx,0x2
    24ed:	cmp    rsi,0x5
    24f1:	cmove  rcx,QWORD PTR [rip+0x1af]        # 26a8 <botlish_fn_32+0x3a8>
    24f9:	cmp    rcx,0x6
    24fd:	je     250d <botlish_fn_32+0x20d>
    2503:	mov    rdx,QWORD PTR [rsp+0x20]
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
    255f:	mov    rdx,QWORD PTR [rsp+0x20]
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
    2597:	mov    rdx,QWORD PTR [rsp+0x20]
    259c:	mov    rsi,r12
    259f:	mov    rdi,r14
    25a2:	call   25a7 <botlish_fn_32+0x2a7>
			25a3: R_X86_64_PLT32	botlish_fn_30-0x4 ; ht_probe_next<HashTable, int>
    25a7:	test   rdx,rdx
    25aa:	jne    25d5 <botlish_fn_32+0x2d5>
    25b0:	xor    rax,rax
    25b3:	mov    rbx,QWORD PTR [rsp+0x40]
    25b8:	mov    r12,QWORD PTR [rsp+0x48]
    25bd:	mov    r13,QWORD PTR [rsp+0x50]
    25c2:	mov    r14,QWORD PTR [rsp+0x58]
    25c7:	mov    r15,QWORD PTR [rsp+0x60]
    25cc:	add    rsp,0x70
    25d0:	mov    rsp,rbp
    25d3:	pop    rbp
    25d4:	ret
    25d5:	mov    QWORD PTR [rsp],r12
    25d9:	mov    QWORD PTR [rsp+0x8],rbx
    25de:	mov    rsi,QWORD PTR [rsp+0x30]
    25e3:	mov    QWORD PTR [rsp+0x10],rsi
    25e8:	mov    rdx,rax
    25eb:	mov    r13,QWORD PTR [rsp+0x30]
    25f0:	mov    r15,rbx
    25f3:	jmp    2341 <botlish_fn_32+0x41>
    25f8:	mov    rax,QWORD PTR [rsp+0x30]
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
    2656:	mov    rax,QWORD PTR [rsp+0x30]
    265b:	mov    rax,QWORD PTR [rsp+0x30]
    2660:	mov    rbx,QWORD PTR [rsp+0x40]
    2665:	mov    r12,QWORD PTR [rsp+0x48]
    266a:	mov    r13,QWORD PTR [rsp+0x50]
    266f:	mov    r14,QWORD PTR [rsp+0x58]
    2674:	mov    r15,QWORD PTR [rsp+0x60]
    2679:	add    rsp,0x70
    267d:	mov    rsp,rbp
    2680:	pop    rbp
    2681:	ret
    2682:	mov    rax,r13
    2685:	mov    rbx,QWORD PTR [rsp+0x40]
    268a:	mov    r12,QWORD PTR [rsp+0x48]
    268f:	mov    r13,QWORD PTR [rsp+0x50]
    2694:	mov    r14,QWORD PTR [rsp+0x58]
    2699:	mov    r15,QWORD PTR [rsp+0x60]
    269e:	add    rsp,0x70
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
    2d44:	sub    rsp,0x100
    2d4b:	mov    QWORD PTR [rsp+0xd0],rbx
    2d53:	mov    QWORD PTR [rsp+0xd8],r12
    2d5b:	mov    QWORD PTR [rsp+0xe0],r13
    2d63:	mov    QWORD PTR [rsp+0xe8],r14
    2d6b:	mov    QWORD PTR [rsp+0xf0],r15
    2d73:	mov    QWORD PTR [rsp+0x98],rdi
    2d7b:	mov    QWORD PTR [rsp+0x20],0x0
    2d84:	mov    QWORD PTR [rsp+0x28],0x0
    2d8d:	mov    QWORD PTR [rsp+0x30],0x0
    2d96:	mov    QWORD PTR [rsp+0x38],0x0
    2d9f:	mov    QWORD PTR [rsp+0x40],0x0
    2da8:	mov    QWORD PTR [rsp+0x48],0x0
    2db1:	mov    QWORD PTR [rsp+0x50],0x0
    2dba:	mov    QWORD PTR [rsp+0x58],0x0
    2dc3:	mov    QWORD PTR [rsp+0x10],rsi
    2dc8:	mov    r14,rsi
    2dcb:	mov    QWORD PTR [rsp+0x18],rdx
    2dd0:	mov    QWORD PTR [rsp+0xa0],rdx
    2dd8:	lea    rdx,[rsp+0x60]
    2ddd:	mov    rsi,QWORD PTR [rsp+0xa0]
    2de5:	mov    rdi,QWORD PTR [rsp+0x98]
    2ded:	call   2df2 <botlish_fn_37+0xb2>
			2dee: R_X86_64_PLT32	botlish_fn_22-0x4 ; ht_alloc<int>
    2df2:	test   rax,rax
    2df5:	je     2f4c <botlish_fn_37+0x20c>
    2dfb:	mov    QWORD PTR [rsp+0x20],rax
    2e00:	mov    QWORD PTR [rsp+0xc0],rax
    2e08:	mov    rbx,QWORD PTR [rsp+0x60]
    2e0d:	mov    QWORD PTR [rsp+0x28],rbx
    2e12:	mov    r12,QWORD PTR [rsp+0x68]
    2e17:	mov    QWORD PTR [rsp+0x30],r12
    2e1c:	mov    r13,QWORD PTR [rsp+0x70]
    2e21:	mov    QWORD PTR [rsp+0x38],r13
    2e26:	mov    rsi,r14
    2e29:	mov    rdi,QWORD PTR [rsp+0x98]
    2e31:	call   2e36 <botlish_fn_37+0xf6>
			2e32: R_X86_64_PLT32	botlish_fn_26-0x4 ; ht_size<HashTable>
    2e36:	test   rax,rax
    2e39:	mov    rcx,rax
    2e3c:	je     2f4c <botlish_fn_37+0x20c>
    2e42:	mov    edx,0x1
    2e47:	mov    rsi,r13
    2e4a:	mov    rdi,QWORD PTR [rsp+0x98]
    2e52:	call   2e57 <botlish_fn_37+0x117>
			2e53: R_X86_64_PLT32	rt_mutarray_set-0x4
    2e57:	test   rax,rax
    2e5a:	je     2f4c <botlish_fn_37+0x20c>
    2e60:	mov    rsi,r14
    2e63:	mov    rax,QWORD PTR [rsi+0x18]
    2e67:	mov    rcx,QWORD PTR [rax]
    2e6a:	mov    QWORD PTR [rsp+0x40],rcx
    2e6f:	mov    QWORD PTR [rsp+0xb8],rcx
    2e77:	mov    rax,QWORD PTR [rsi+0x18]
    2e7b:	mov    r15,QWORD PTR [rax+0x8]
    2e7f:	mov    QWORD PTR [rsp+0x48],r15
    2e84:	mov    rax,QWORD PTR [rsi+0x18]
    2e88:	mov    r14,QWORD PTR [rax+0x10]
    2e8c:	mov    QWORD PTR [rsp+0x50],r14
    2e91:	mov    r8d,0x1
    2e97:	mov    QWORD PTR [rsp+0xb0],r8
    2e9f:	mov    QWORD PTR [rsp+0x58],0x1
    2ea8:	mov    rdi,QWORD PTR [rsp+0x98]
    2eb0:	call   2eb5 <botlish_fn_37+0x175>
			2eb1: R_X86_64_PLT32	botlish_fn_28-0x4 ; ht_capacity<HashTable>
    2eb5:	mov    QWORD PTR [rsp+0xa8],rax
    2ebd:	lea    rcx,[rsp+0x78]
    2ec2:	mov    rax,QWORD PTR [rsp+0xc0]
    2eca:	mov    QWORD PTR [rsp+0x78],rax
    2ecf:	mov    QWORD PTR [rsp+0x80],rbx
    2ed7:	mov    QWORD PTR [rsp+0x88],r12
    2edf:	mov    QWORD PTR [rsp+0x90],r13
    2ee7:	xor    rsi,rsi
    2eea:	mov    edx,0x4
    2eef:	mov    rdi,QWORD PTR [rsp+0x98]
    2ef7:	call   2efc <botlish_fn_37+0x1bc>
			2ef8: R_X86_64_PLT32	rt_struct_new-0x4
    2efc:	mov    QWORD PTR [rsp+0x10],rax
    2f01:	mov    rcx,QWORD PTR [rsp+0xa8]
    2f09:	mov    r9,rcx
    2f0c:	sar    r9,1
    2f0f:	mov    QWORD PTR [rsp],rax
    2f13:	mov    rdx,QWORD PTR [rsp+0xa0]
    2f1b:	mov    QWORD PTR [rsp+0x8],rdx
    2f20:	mov    rcx,r14
    2f23:	mov    rdx,r15
    2f26:	mov    rsi,QWORD PTR [rsp+0xb8]
    2f2e:	mov    rdi,QWORD PTR [rsp+0x98]
    2f36:	mov    r8,QWORD PTR [rsp+0xb0]
    2f3e:	call   2f43 <botlish_fn_37+0x203>
			2f3f: R_X86_64_PLT32	botlish_fn_36-0x4 ; ht_rehash_scan<mutarray, mutarray, mutarray, int, int, HashTable, int>
    2f43:	test   rax,rax
    2f46:	jne    2f83 <botlish_fn_37+0x243>
    2f4c:	xor    rax,rax
    2f4f:	mov    rbx,QWORD PTR [rsp+0xd0]
    2f57:	mov    r12,QWORD PTR [rsp+0xd8]
    2f5f:	mov    r13,QWORD PTR [rsp+0xe0]
    2f67:	mov    r14,QWORD PTR [rsp+0xe8]
    2f6f:	mov    r15,QWORD PTR [rsp+0xf0]
    2f77:	add    rsp,0x100
    2f7e:	mov    rsp,rbp
    2f81:	pop    rbp
    2f82:	ret
    2f83:	mov    rbx,QWORD PTR [rsp+0xd0]
    2f8b:	mov    r12,QWORD PTR [rsp+0xd8]
    2f93:	mov    r13,QWORD PTR [rsp+0xe0]
    2f9b:	mov    r14,QWORD PTR [rsp+0xe8]
    2fa3:	mov    r15,QWORD PTR [rsp+0xf0]
    2fab:	add    rsp,0x100
    2fb2:	mov    rsp,rbp
    2fb5:	pop    rbp
    2fb6:	ret

0000000000002fb7 <botlish_entry_37: ht_rehash<HashTable, int>>:
    2fb7:	push   rbp
    2fb8:	mov    rbp,rsp
    2fbb:	mov    rsi,QWORD PTR [rdx]
    2fbe:	mov    rdx,QWORD PTR [rdx+0x8]
    2fc2:	call   2fc7 <botlish_entry_37+0x10>
			2fc3: R_X86_64_PLT32	botlish_fn_37-0x4 ; ht_rehash<HashTable, int>
    2fc7:	mov    rsp,rbp
    2fca:	pop    rbp
    2fcb:	ret
    2fcc:	add    BYTE PTR [rax],al
	...

0000000000002fd0 <botlish_fn_38: ht_should_grow<HashTable>>:
    2fd0:	push   rbp
    2fd1:	mov    rbp,rsp
    2fd4:	sub    rsp,0x40
    2fd8:	mov    QWORD PTR [rsp+0x20],rbx
    2fdd:	mov    QWORD PTR [rsp+0x28],r12
    2fe2:	mov    QWORD PTR [rsp+0x30],r13
    2fe7:	mov    rbx,rdi
    2fea:	mov    QWORD PTR [rsp],rsi
    2fee:	mov    r12,rsi
    2ff1:	mov    rsi,r12
    2ff4:	mov    rdi,rbx
    2ff7:	call   2ffc <botlish_fn_38+0x2c>
			2ff8: R_X86_64_PLT32	botlish_fn_26-0x4 ; ht_size<HashTable>
    2ffc:	mov    rcx,rax
    2fff:	mov    r13,rax
    3002:	test   rax,rcx
    3005:	je     30de <botlish_fn_38+0x10e>
    300b:	mov    rax,r13
    300e:	mov    QWORD PTR [rsp+0x8],rax
    3013:	mov    rsi,r12
    3016:	mov    rdi,rbx
    3019:	call   301e <botlish_fn_38+0x4e>
			301a: R_X86_64_PLT32	botlish_fn_27-0x4 ; ht_tombstones<HashTable>
    301e:	mov    rcx,rax
    3021:	test   rcx,rcx
    3024:	je     30de <botlish_fn_38+0x10e>
    302a:	mov    QWORD PTR [rsp+0x10],rcx
    302f:	mov    edx,0x1
    3034:	mov    rax,r13
    3037:	test   rax,0x1
    303d:	jne    3060 <botlish_fn_38+0x90>
    3043:	xor    edx,edx
    3045:	mov    rax,r13
    3048:	test   rax,0x7
    304e:	jne    3060 <botlish_fn_38+0x90>
    3054:	mov    rax,r13
    3057:	movzx  rax,BYTE PTR [rax]
    305b:	cmp    al,0x1
    305d:	sete   dl
    3060:	test   dl,dl
    3062:	jne    3083 <botlish_fn_38+0xb3>
    3068:	mov    rdi,rbx
    306b:	mov    rax,QWORD PTR [rdi+0x10]
    306f:	mov    rcx,QWORD PTR [rax+0x8]
    3073:	xor    rdx,rdx
    3076:	mov    rsi,r13
    3079:	call   307e <botlish_fn_38+0xae>
			307a: R_X86_64_PLT32	rt_type_error-0x4
    307e:	jmp    30de <botlish_fn_38+0x10e>
    3083:	mov    eax,0x1
    3088:	test   rcx,0x1
    308f:	je     309d <botlish_fn_38+0xcd>
    3095:	mov    r8,rcx
    3098:	jmp    30c0 <botlish_fn_38+0xf0>
    309d:	xor    eax,eax
    309f:	test   rcx,0x7
    30a6:	je     30b4 <botlish_fn_38+0xe4>
    30ac:	mov    r8,rcx
    30af:	jmp    30c0 <botlish_fn_38+0xf0>
    30b4:	movzx  rax,BYTE PTR [rcx]
    30b8:	mov    r8,rcx
    30bb:	cmp    al,0x1
    30bd:	sete   al
    30c0:	test   al,al
    30c2:	jne    30f9 <botlish_fn_38+0x129>
    30c8:	mov    rdi,rbx
    30cb:	mov    rax,QWORD PTR [rdi+0x10]
    30cf:	mov    rcx,QWORD PTR [rax+0x8]
    30d3:	xor    rdx,rdx
    30d6:	mov    rsi,r8
    30d9:	call   30de <botlish_fn_38+0x10e>
			30da: R_X86_64_PLT32	rt_type_error-0x4
    30de:	xor    rax,rax
    30e1:	mov    rbx,QWORD PTR [rsp+0x20]
    30e6:	mov    r12,QWORD PTR [rsp+0x28]
    30eb:	mov    r13,QWORD PTR [rsp+0x30]
    30f0:	add    rsp,0x40
    30f4:	mov    rsp,rbp
    30f7:	pop    rbp
    30f8:	ret
    30f9:	mov    rcx,r8
    30fc:	mov    rsi,r13
    30ff:	mov    rax,rsi
    3102:	and    rax,rcx
    3105:	test   rax,0x1
    310b:	jne    311c <botlish_fn_38+0x14c>
    3111:	mov    rdx,r8
    3114:	mov    rsi,r13
    3117:	jmp    313a <botlish_fn_38+0x16a>
    311c:	mov    rcx,r8
    311f:	lea    rax,[rcx-0x1]
    3123:	mov    rsi,r13
    3126:	add    rsi,rax
    3129:	seto   al
    312c:	test   al,al
    312e:	je     3145 <botlish_fn_38+0x175>
    3134:	mov    rdx,r8
    3137:	mov    rsi,r13
    313a:	mov    rdi,rbx
    313d:	call   3142 <botlish_fn_38+0x172>
			313e: R_X86_64_PLT32	rt_int_add-0x4
    3142:	mov    rsi,rax
    3145:	mov    QWORD PTR [rsp+0x8],rsi
    314a:	mov    QWORD PTR [rsp+0x10],0x3
    3153:	test   rsi,0x1
    315a:	je     317d <botlish_fn_38+0x1ad>
    3160:	mov    rax,rsi
    3163:	add    rax,0x2
    3167:	mov    rcx,rax
    316a:	seto   al
    316d:	test   al,al
    316f:	jne    317d <botlish_fn_38+0x1ad>
    3175:	mov    rsi,rcx
    3178:	jmp    318d <botlish_fn_38+0x1bd>
    317d:	mov    edx,0x3
    3182:	mov    rdi,rbx
    3185:	call   318a <botlish_fn_38+0x1ba>
			3186: R_X86_64_PLT32	rt_int_add-0x4
    318a:	mov    rsi,rax
    318d:	mov    QWORD PTR [rsp+0x8],rsi
    3192:	mov    edx,0x7
    3197:	mov    rdi,rdx
    319a:	mov    QWORD PTR [rsp+0x10],0x7
    31a3:	test   rsi,0x1
    31aa:	jne    31b8 <botlish_fn_38+0x1e8>
    31b0:	mov    rdx,rdi
    31b3:	jmp    31e4 <botlish_fn_38+0x214>
    31b8:	mov    rax,rsi
    31bb:	sar    rax,1
    31be:	imul   QWORD PTR [rip+0xf3]        # 32b8 <botlish_fn_38+0x2e8>
    31c5:	seto   cl
    31c8:	or     rax,0x1
    31cc:	test   cl,cl
    31ce:	je     31dc <botlish_fn_38+0x20c>
    31d4:	mov    rdx,rdi
    31d7:	jmp    31e4 <botlish_fn_38+0x214>
    31dc:	mov    rsi,rax
    31df:	jmp    31ef <botlish_fn_38+0x21f>
    31e4:	mov    rdi,rbx
    31e7:	call   31ec <botlish_fn_38+0x21c>
			31e8: R_X86_64_PLT32	rt_int_mul-0x4
    31ec:	mov    rsi,rax
    31ef:	mov    QWORD PTR [rsp+0x8],rsi
    31f4:	mov    r13,rsi
    31f7:	mov    rsi,r12
    31fa:	mov    rdi,rbx
    31fd:	call   3202 <botlish_fn_38+0x232>
			31fe: R_X86_64_PLT32	botlish_fn_28-0x4 ; ht_capacity<HashTable>
    3202:	mov    QWORD PTR [rsp],rax
    3206:	mov    QWORD PTR [rsp+0x10],0x5
    320f:	test   rax,0x1
    3215:	mov    rcx,rax
    3218:	je     3247 <botlish_fn_38+0x277>
    321e:	mov    rax,rcx
    3221:	sar    rax,1
    3224:	imul   QWORD PTR [rip+0x95]        # 32c0 <botlish_fn_38+0x2f0>
    322b:	seto   sil
    322f:	or     rax,0x1
    3233:	test   sil,sil
    3236:	jne    3247 <botlish_fn_38+0x277>
    323c:	mov    rdx,rax
    323f:	mov    rsi,r13
    3242:	jmp    325d <botlish_fn_38+0x28d>
    3247:	mov    edx,0x5
    324c:	mov    rsi,rcx
    324f:	mov    rdi,rbx
    3252:	call   3257 <botlish_fn_38+0x287>
			3253: R_X86_64_PLT32	rt_int_mul-0x4
    3257:	mov    rdx,rax
    325a:	mov    rsi,r13
    325d:	mov    rdi,rsi
    3260:	and    rdi,rdx
    3263:	test   rdi,0x1
    326a:	jne    3290 <botlish_fn_38+0x2c0>
    3270:	mov    rdi,rbx
    3273:	call   3278 <botlish_fn_38+0x2a8>
			3274: R_X86_64_PLT32	rt_int_cmp-0x4
    3278:	mov    esi,0x2
    327d:	test   rax,rax
    3280:	mov    rax,rsi
    3283:	cmovg  rax,QWORD PTR [rip+0x2d]        # 32b8 <botlish_fn_38+0x2e8>
    328b:	jmp    32a0 <botlish_fn_38+0x2d0>
    3290:	mov    eax,0x2
    3295:	cmp    rsi,rdx
    3298:	cmovg  rax,QWORD PTR [rip+0x18]        # 32b8 <botlish_fn_38+0x2e8>
    32a0:	mov    rbx,QWORD PTR [rsp+0x20]
    32a5:	mov    r12,QWORD PTR [rsp+0x28]
    32aa:	mov    r13,QWORD PTR [rsp+0x30]
    32af:	add    rsp,0x40
    32b3:	mov    rsp,rbp
    32b6:	pop    rbp
    32b7:	ret
    32b8:	(bad)
    32b9:	add    BYTE PTR [rax],al
    32bb:	add    BYTE PTR [rax],al
    32bd:	add    BYTE PTR [rax],al
    32bf:	add    BYTE PTR [rax+rax*1],al
    32c2:	add    BYTE PTR [rax],al
    32c4:	add    BYTE PTR [rax],al
	...

00000000000032c8 <botlish_entry_38: ht_should_grow<HashTable>>:
    32c8:	push   rbp
    32c9:	mov    rbp,rsp
    32cc:	mov    rsi,QWORD PTR [rdx]
    32cf:	call   32d4 <botlish_entry_38+0xc>
			32d0: R_X86_64_PLT32	botlish_fn_38-0x4 ; ht_should_grow<HashTable>
    32d4:	mov    rsp,rbp
    32d7:	pop    rbp
    32d8:	ret
    32d9:	add    BYTE PTR [rax],al
    32db:	add    BYTE PTR [rax],al
    32dd:	add    BYTE PTR [rax],al
	...

00000000000032e0 <botlish_fn_39: ht_grow_or_clean<HashTable>>:
    32e0:	push   rbp
    32e1:	mov    rbp,rsp
    32e4:	sub    rsp,0x40
    32e8:	mov    QWORD PTR [rsp+0x20],rbx
    32ed:	mov    QWORD PTR [rsp+0x28],r12
    32f2:	mov    QWORD PTR [rsp+0x30],r13
    32f7:	mov    rbx,rdi
    32fa:	mov    QWORD PTR [rsp+0x10],0x0
    3303:	mov    QWORD PTR [rsp],rsi
    3307:	mov    r12,rsi
    330a:	mov    rsi,r12
    330d:	mov    rdi,rbx
    3310:	call   3315 <botlish_fn_39+0x35>
			3311: R_X86_64_PLT32	botlish_fn_27-0x4 ; ht_tombstones<HashTable>
    3315:	test   rax,rax
    3318:	mov    r13,rax
    331b:	je     3509 <botlish_fn_39+0x229>
    3321:	mov    rsi,r12
    3324:	mov    rdi,rbx
    3327:	call   332c <botlish_fn_39+0x4c>
			3328: R_X86_64_PLT32	botlish_fn_26-0x4 ; ht_size<HashTable>
    332c:	mov    r11,rax
    332f:	test   r11,r11
    3332:	je     3509 <botlish_fn_39+0x229>
    3338:	mov    ecx,0x1
    333d:	mov    rax,r13
    3340:	test   rax,0x1
    3346:	je     3354 <botlish_fn_39+0x74>
    334c:	mov    r13,rax
    334f:	jmp    3378 <botlish_fn_39+0x98>
    3354:	xor    ecx,ecx
    3356:	test   rax,0x7
    335c:	je     336a <botlish_fn_39+0x8a>
    3362:	mov    r13,rax
    3365:	jmp    3378 <botlish_fn_39+0x98>
    336a:	movzx  rcx,BYTE PTR [rax]
    336e:	mov    r13,rax
    3371:	rex cmp cl,0x1
    3375:	sete   cl
    3378:	test   cl,cl
    337a:	jne    339b <botlish_fn_39+0xbb>
    3380:	mov    rdi,rbx
    3383:	mov    rsi,QWORD PTR [rdi+0x10]
    3387:	mov    rcx,QWORD PTR [rsi+0x10]
    338b:	xor    rdx,rdx
    338e:	mov    rsi,r13
    3391:	call   3396 <botlish_fn_39+0xb6>
			3392: R_X86_64_PLT32	rt_type_error-0x4
    3396:	jmp    3509 <botlish_fn_39+0x229>
    339b:	mov    rsi,r13
    339e:	mov    eax,0x1
    33a3:	test   r11,0x1
    33aa:	je     33b8 <botlish_fn_39+0xd8>
    33b0:	mov    r8,r11
    33b3:	jmp    33dd <botlish_fn_39+0xfd>
    33b8:	xor    eax,eax
    33ba:	test   r11,0x7
    33c1:	je     33cf <botlish_fn_39+0xef>
    33c7:	mov    r8,r11
    33ca:	jmp    33dd <botlish_fn_39+0xfd>
    33cf:	movzx  r10,BYTE PTR [r11]
    33d3:	mov    r8,r11
    33d6:	cmp    r10b,0x1
    33da:	sete   al
    33dd:	test   al,al
    33df:	jne    3400 <botlish_fn_39+0x120>
    33e5:	mov    rdi,rbx
    33e8:	mov    rax,QWORD PTR [rdi+0x10]
    33ec:	mov    rcx,QWORD PTR [rax+0x10]
    33f0:	xor    rdx,rdx
    33f3:	mov    rsi,r8
    33f6:	call   33fb <botlish_fn_39+0x11b>
			33f7: R_X86_64_PLT32	rt_type_error-0x4
    33fb:	jmp    3509 <botlish_fn_39+0x229>
    3400:	mov    r11,r8
    3403:	mov    rax,rsi
    3406:	and    rax,r11
    3409:	test   rax,0x1
    340f:	jne    3435 <botlish_fn_39+0x155>
    3415:	mov    rdx,r8
    3418:	mov    rdi,rbx
    341b:	call   3420 <botlish_fn_39+0x140>
			341c: R_X86_64_PLT32	rt_int_cmp-0x4
    3420:	mov    ecx,0x2
    3425:	test   rax,rax
    3428:	cmovg  rcx,QWORD PTR [rip+0x110]        # 3540 <botlish_fn_39+0x260>
    3430:	jmp    3448 <botlish_fn_39+0x168>
    3435:	mov    ecx,0x2
    343a:	mov    r11,r8
    343d:	cmp    rsi,r11
    3440:	cmovg  rcx,QWORD PTR [rip+0xf8]        # 3540 <botlish_fn_39+0x260>
    3448:	cmp    rcx,0x6
    344c:	je     34e2 <botlish_fn_39+0x202>
    3452:	mov    rsi,r12
    3455:	mov    rdi,rbx
    3458:	call   345d <botlish_fn_39+0x17d>
			3459: R_X86_64_PLT32	botlish_fn_28-0x4 ; ht_capacity<HashTable>
    345d:	mov    QWORD PTR [rsp+0x8],rax
    3462:	mov    QWORD PTR [rsp+0x10],0x5
    346b:	test   rax,0x1
    3471:	mov    rsi,rax
    3474:	je     34a1 <botlish_fn_39+0x1c1>
    347a:	mov    rcx,rsi
    347d:	mov    rax,rcx
    3480:	sar    rax,1
    3483:	imul   QWORD PTR [rip+0xbe]        # 3548 <botlish_fn_39+0x268>
    348a:	seto   cl
    348d:	or     rax,0x1
    3491:	test   cl,cl
    3493:	jne    34a1 <botlish_fn_39+0x1c1>
    3499:	mov    rdx,rax
    349c:	jmp    34b1 <botlish_fn_39+0x1d1>
    34a1:	mov    edx,0x5
    34a6:	mov    rdi,rbx
    34a9:	call   34ae <botlish_fn_39+0x1ce>
			34aa: R_X86_64_PLT32	rt_int_mul-0x4
    34ae:	mov    rdx,rax
    34b1:	mov    QWORD PTR [rsp+0x8],rdx
    34b6:	mov    rsi,r12
    34b9:	mov    rdi,rbx
    34bc:	call   34c1 <botlish_fn_39+0x1e1>
			34bd: R_X86_64_PLT32	botlish_fn_37-0x4 ; ht_rehash<HashTable, int>
    34c1:	test   rax,rax
    34c4:	je     3509 <botlish_fn_39+0x229>
    34ca:	mov    rbx,QWORD PTR [rsp+0x20]
    34cf:	mov    r12,QWORD PTR [rsp+0x28]
    34d4:	mov    r13,QWORD PTR [rsp+0x30]
    34d9:	add    rsp,0x40
    34dd:	mov    rsp,rbp
    34e0:	pop    rbp
    34e1:	ret
    34e2:	mov    rsi,r12
    34e5:	mov    rdi,rbx
    34e8:	call   34ed <botlish_fn_39+0x20d>
			34e9: R_X86_64_PLT32	botlish_fn_28-0x4 ; ht_capacity<HashTable>
    34ed:	mov    QWORD PTR [rsp+0x8],rax
    34f2:	mov    rdx,rax
    34f5:	mov    rsi,r12
    34f8:	mov    rdi,rbx
    34fb:	call   3500 <botlish_fn_39+0x220>
			34fc: R_X86_64_PLT32	botlish_fn_37-0x4 ; ht_rehash<HashTable, int>
    3500:	test   rax,rax
    3503:	jne    3524 <botlish_fn_39+0x244>
    3509:	xor    rax,rax
    350c:	mov    rbx,QWORD PTR [rsp+0x20]
    3511:	mov    r12,QWORD PTR [rsp+0x28]
    3516:	mov    r13,QWORD PTR [rsp+0x30]
    351b:	add    rsp,0x40
    351f:	mov    rsp,rbp
    3522:	pop    rbp
    3523:	ret
    3524:	mov    rbx,QWORD PTR [rsp+0x20]
    3529:	mov    r12,QWORD PTR [rsp+0x28]
    352e:	mov    r13,QWORD PTR [rsp+0x30]
    3533:	add    rsp,0x40
    3537:	mov    rsp,rbp
    353a:	pop    rbp
    353b:	ret
    353c:	add    BYTE PTR [rax],al
    353e:	add    BYTE PTR [rax],al
    3540:	(bad)
    3541:	add    BYTE PTR [rax],al
    3543:	add    BYTE PTR [rax],al
    3545:	add    BYTE PTR [rax],al
    3547:	add    BYTE PTR [rax+rax*1],al
    354a:	add    BYTE PTR [rax],al
    354c:	add    BYTE PTR [rax],al
	...

0000000000003550 <botlish_entry_39: ht_grow_or_clean<HashTable>>:
    3550:	push   rbp
    3551:	mov    rbp,rsp
    3554:	mov    rsi,QWORD PTR [rdx]
    3557:	call   355c <botlish_entry_39+0xc>
			3558: R_X86_64_PLT32	botlish_fn_39-0x4 ; ht_grow_or_clean<HashTable>
    355c:	mov    rsp,rbp
    355f:	pop    rbp
    3560:	ret
    3561:	add    BYTE PTR [rax],al
    3563:	add    BYTE PTR [rax],al
    3565:	add    BYTE PTR [rax],al
	...

0000000000003568 <botlish_fn_40: ht_place<HashTable, int, str, str>>:
    3568:	push   rbp
    3569:	mov    rbp,rsp
    356c:	sub    rsp,0x70
    3570:	mov    QWORD PTR [rsp+0x40],rbx
    3575:	mov    QWORD PTR [rsp+0x48],r12
    357a:	mov    QWORD PTR [rsp+0x50],r13
    357f:	mov    QWORD PTR [rsp+0x58],r14
    3584:	mov    QWORD PTR [rsp+0x60],r15
    3589:	mov    r12,rdi
    358c:	mov    r14,r8
    358f:	mov    r15,rdx
    3592:	mov    QWORD PTR [rsp+0x30],rcx
    3597:	mov    QWORD PTR [rsp],rsi
    359b:	mov    r9,QWORD PTR [rsi+0x18]
    359f:	mov    r13,rsi
    35a2:	mov    rsi,QWORD PTR [r9]
    35a5:	mov    rdx,r15
    35a8:	mov    rdi,r12
    35ab:	call   35b0 <botlish_fn_40+0x48>
			35ac: R_X86_64_PLT32	rt_mutarray_get-0x4
    35b0:	test   rax,rax
    35b3:	je     3848 <botlish_fn_40+0x2e0>
    35b9:	mov    QWORD PTR [rsp+0x8],rax
    35be:	mov    rbx,r13
    35c1:	mov    r13,rax
    35c4:	mov    rax,QWORD PTR [rbx+0x18]
    35c8:	mov    rsi,QWORD PTR [rax]
    35cb:	mov    ecx,0x3
    35d0:	mov    rdx,r15
    35d3:	mov    rdi,r12
    35d6:	call   35db <botlish_fn_40+0x73>
			35d7: R_X86_64_PLT32	rt_mutarray_set-0x4
    35db:	test   rax,rax
    35de:	je     3848 <botlish_fn_40+0x2e0>
    35e4:	mov    rax,QWORD PTR [rbx+0x18]
    35e8:	mov    rsi,QWORD PTR [rax+0x8]
    35ec:	mov    rcx,QWORD PTR [rsp+0x30]
    35f1:	mov    rdx,r15
    35f4:	mov    rdi,r12
    35f7:	call   35fc <botlish_fn_40+0x94>
			35f8: R_X86_64_PLT32	rt_mutarray_set-0x4
    35fc:	test   rax,rax
    35ff:	je     3848 <botlish_fn_40+0x2e0>
    3605:	mov    rax,QWORD PTR [rbx+0x18]
    3609:	mov    rsi,QWORD PTR [rax+0x10]
    360d:	mov    rcx,r14
    3610:	mov    rdx,r15
    3613:	mov    rdi,r12
    3616:	call   361b <botlish_fn_40+0xb3>
			3617: R_X86_64_PLT32	rt_mutarray_set-0x4
    361b:	test   rax,rax
    361e:	je     3848 <botlish_fn_40+0x2e0>
    3624:	mov    rax,QWORD PTR [rbx+0x18]
    3628:	mov    rsi,QWORD PTR [rax+0x18]
    362c:	mov    QWORD PTR [rsp+0x10],rsi
    3631:	mov    r14,rsi
    3634:	mov    QWORD PTR [rsp+0x18],0x1
    363d:	mov    rsi,rbx
    3640:	mov    rdi,r12
    3643:	call   3648 <botlish_fn_40+0xe0>
			3644: R_X86_64_PLT32	botlish_fn_26-0x4 ; ht_size<HashTable>
    3648:	test   rax,rax
    364b:	je     3848 <botlish_fn_40+0x2e0>
    3651:	mov    QWORD PTR [rsp+0x20],rax
    3656:	mov    QWORD PTR [rsp+0x28],0x3
    365f:	mov    ecx,0x1
    3664:	test   rax,0x1
    366a:	je     3678 <botlish_fn_40+0x110>
    3670:	mov    rsi,rax
    3673:	jmp    369c <botlish_fn_40+0x134>
    3678:	xor    ecx,ecx
    367a:	test   rax,0x7
    3680:	je     368e <botlish_fn_40+0x126>
    3686:	mov    rsi,rax
    3689:	jmp    369c <botlish_fn_40+0x134>
    368e:	movzx  rcx,BYTE PTR [rax]
    3692:	mov    rsi,rax
    3695:	rex cmp cl,0x1
    3699:	sete   cl
    369c:	test   cl,cl
    369e:	jne    36bc <botlish_fn_40+0x154>
    36a4:	mov    rdi,r12
    36a7:	mov    rax,QWORD PTR [rdi+0x10]
    36ab:	mov    rcx,QWORD PTR [rax+0x8]
    36af:	xor    rdx,rdx
    36b2:	call   36b7 <botlish_fn_40+0x14f>
			36b3: R_X86_64_PLT32	rt_type_error-0x4
    36b7:	jmp    3848 <botlish_fn_40+0x2e0>
    36bc:	test   rsi,0x1
    36c3:	je     36db <botlish_fn_40+0x173>
    36c9:	mov    rcx,rsi
    36cc:	add    rcx,0x2
    36d0:	seto   al
    36d3:	test   al,al
    36d5:	je     36eb <botlish_fn_40+0x183>
    36db:	mov    edx,0x3
    36e0:	mov    rdi,r12
    36e3:	call   36e8 <botlish_fn_40+0x180>
			36e4: R_X86_64_PLT32	rt_int_add-0x4
    36e8:	mov    rcx,rax
    36eb:	mov    edx,0x1
    36f0:	mov    rsi,r14
    36f3:	mov    rdi,r12
    36f6:	call   36fb <botlish_fn_40+0x193>
			36f7: R_X86_64_PLT32	rt_mutarray_set-0x4
    36fb:	test   rax,rax
    36fe:	je     3848 <botlish_fn_40+0x2e0>
    3704:	mov    rax,r13
    3707:	test   rax,0x1
    370d:	jne    3738 <botlish_fn_40+0x1d0>
    3713:	mov    edx,0x5
    3718:	mov    rsi,r13
    371b:	mov    rdi,r12
    371e:	call   3723 <botlish_fn_40+0x1bb>
			371f: R_X86_64_PLT32	rt_int_cmp-0x4
    3723:	mov    ecx,0x2
    3728:	test   rax,rax
    372b:	cmove  rcx,QWORD PTR [rip+0x165]        # 3898 <botlish_fn_40+0x330>
    3733:	jmp    374c <botlish_fn_40+0x1e4>
    3738:	mov    rsi,r13
    373b:	mov    ecx,0x2
    3740:	cmp    rsi,0x5
    3744:	cmove  rcx,QWORD PTR [rip+0x14c]        # 3898 <botlish_fn_40+0x330>
    374c:	cmp    rcx,0x6
    3750:	je     375e <botlish_fn_40+0x1f6>
    3756:	mov    rax,rbx
    3759:	jmp    3870 <botlish_fn_40+0x308>
    375e:	mov    rax,QWORD PTR [rbx+0x18]
    3762:	mov    rsi,QWORD PTR [rax+0x18]
    3766:	mov    QWORD PTR [rsp+0x8],rsi
    376b:	mov    r14,rsi
    376e:	mov    QWORD PTR [rsp+0x10],0x3
    3777:	mov    rsi,rbx
    377a:	mov    rdi,r12
    377d:	call   3782 <botlish_fn_40+0x21a>
			377e: R_X86_64_PLT32	botlish_fn_27-0x4 ; ht_tombstones<HashTable>
    3782:	mov    r13,rbx
    3785:	test   rax,rax
    3788:	je     3848 <botlish_fn_40+0x2e0>
    378e:	mov    QWORD PTR [rsp+0x18],rax
    3793:	mov    QWORD PTR [rsp+0x20],0x3
    379c:	mov    ecx,0x1
    37a1:	test   rax,0x1
    37a7:	je     37b5 <botlish_fn_40+0x24d>
    37ad:	mov    rsi,rax
    37b0:	jmp    37d9 <botlish_fn_40+0x271>
    37b5:	xor    ecx,ecx
    37b7:	test   rax,0x7
    37bd:	je     37cb <botlish_fn_40+0x263>
    37c3:	mov    rsi,rax
    37c6:	jmp    37d9 <botlish_fn_40+0x271>
    37cb:	movzx  r10,BYTE PTR [rax]
    37cf:	mov    rsi,rax
    37d2:	cmp    r10b,0x1
    37d6:	sete   cl
    37d9:	test   cl,cl
    37db:	jne    37f9 <botlish_fn_40+0x291>
    37e1:	mov    rdi,r12
    37e4:	mov    rax,QWORD PTR [rdi+0x10]
    37e8:	mov    rcx,QWORD PTR [rax+0x18]
    37ec:	xor    rdx,rdx
    37ef:	call   37f4 <botlish_fn_40+0x28c>
			37f0: R_X86_64_PLT32	rt_type_error-0x4
    37f4:	jmp    3848 <botlish_fn_40+0x2e0>
    37f9:	test   rsi,0x1
    3800:	je     381f <botlish_fn_40+0x2b7>
    3806:	mov    rcx,rsi
    3809:	sub    rcx,0x3
    380d:	seto   al
    3810:	add    rcx,0x1
    3817:	test   al,al
    3819:	je     382f <botlish_fn_40+0x2c7>
    381f:	mov    edx,0x3
    3824:	mov    rdi,r12
    3827:	call   382c <botlish_fn_40+0x2c4>
			3828: R_X86_64_PLT32	rt_int_sub-0x4
    382c:	mov    rcx,rax
    382f:	mov    edx,0x3
    3834:	mov    rsi,r14
    3837:	mov    rdi,r12
    383a:	call   383f <botlish_fn_40+0x2d7>
			383b: R_X86_64_PLT32	rt_mutarray_set-0x4
    383f:	test   rax,rax
    3842:	jne    386d <botlish_fn_40+0x305>
    3848:	xor    rax,rax
    384b:	mov    rbx,QWORD PTR [rsp+0x40]
    3850:	mov    r12,QWORD PTR [rsp+0x48]
    3855:	mov    r13,QWORD PTR [rsp+0x50]
    385a:	mov    r14,QWORD PTR [rsp+0x58]
    385f:	mov    r15,QWORD PTR [rsp+0x60]
    3864:	add    rsp,0x70
    3868:	mov    rsp,rbp
    386b:	pop    rbp
    386c:	ret
    386d:	mov    rax,r13
    3870:	mov    rbx,QWORD PTR [rsp+0x40]
    3875:	mov    r12,QWORD PTR [rsp+0x48]
    387a:	mov    r13,QWORD PTR [rsp+0x50]
    387f:	mov    r14,QWORD PTR [rsp+0x58]
    3884:	mov    r15,QWORD PTR [rsp+0x60]
    3889:	add    rsp,0x70
    388d:	mov    rsp,rbp
    3890:	pop    rbp
    3891:	ret
    3892:	add    BYTE PTR [rax],al
    3894:	add    BYTE PTR [rax],al
    3896:	add    BYTE PTR [rax],al
    3898:	(bad)
    3899:	add    BYTE PTR [rax],al
    389b:	add    BYTE PTR [rax],al
    389d:	add    BYTE PTR [rax],al
	...

00000000000038a0 <botlish_entry_40: ht_place<HashTable, int, str, str>>:
    38a0:	push   rbp
    38a1:	mov    rbp,rsp
    38a4:	mov    rsi,QWORD PTR [rdx]
    38a7:	mov    r9,QWORD PTR [rdx+0x8]
    38ab:	mov    rcx,QWORD PTR [rdx+0x10]
    38af:	mov    r8,QWORD PTR [rdx+0x18]
    38b3:	mov    rdx,r9
    38b6:	call   38bb <botlish_entry_40+0x1b>
			38b7: R_X86_64_PLT32	botlish_fn_40-0x4 ; ht_place<HashTable, int, str, str>
    38bb:	mov    rsp,rbp
    38be:	pop    rbp
    38bf:	ret

00000000000038c0 <botlish_fn_41: ht_set<HashTable, str, str>>:
    38c0:	push   rbp
    38c1:	mov    rbp,rsp
    38c4:	sub    rsp,0x60
    38c8:	mov    QWORD PTR [rsp+0x30],rbx
    38cd:	mov    QWORD PTR [rsp+0x38],r12
    38d2:	mov    QWORD PTR [rsp+0x40],r13
    38d7:	mov    QWORD PTR [rsp+0x48],r14
    38dc:	mov    QWORD PTR [rsp+0x50],r15
    38e1:	mov    r12,rdi
    38e4:	mov    QWORD PTR [rsp+0x18],0x0
    38ed:	mov    QWORD PTR [rsp+0x20],0x0
    38f6:	mov    QWORD PTR [rsp],rsi
    38fa:	mov    r14,rsi
    38fd:	mov    QWORD PTR [rsp+0x8],rdx
    3902:	mov    r13,rdx
    3905:	mov    QWORD PTR [rsp+0x10],rcx
    390a:	mov    rbx,rcx
    390d:	mov    rdx,r13
    3910:	mov    rsi,r14
    3913:	mov    rdi,r12
    3916:	call   391b <botlish_fn_41+0x5b>
			3917: R_X86_64_PLT32	botlish_fn_29-0x4 ; ht_probe_start<HashTable, str>
    391b:	test   rax,rax
    391e:	je     3af6 <botlish_fn_41+0x236>
    3924:	mov    QWORD PTR [rsp+0x18],rax
    3929:	mov    rcx,rax
    392c:	mov    r8,0xffffffffffffffff
    3933:	mov    r15,r8
    3936:	mov    QWORD PTR [rsp+0x20],0xffffffffffffffff
    393f:	mov    rdx,r13
    3942:	mov    rsi,r14
    3945:	mov    rdi,r12
    3948:	call   394d <botlish_fn_41+0x8d>
			3949: R_X86_64_PLT32	botlish_fn_32-0x4 ; ht_find_insert<HashTable, str, int, int>
    394d:	test   rax,rax
    3950:	je     3af6 <botlish_fn_41+0x236>
    3956:	mov    QWORD PTR [rsp+0x18],rax
    395b:	mov    rsi,r14
    395e:	mov    QWORD PTR [rsp+0x28],rax
    3963:	mov    rax,QWORD PTR [rsi+0x18]
    3967:	mov    rsi,QWORD PTR [rax]
    396a:	mov    rdx,QWORD PTR [rsp+0x28]
    396f:	mov    rdi,r12
    3972:	call   3977 <botlish_fn_41+0xb7>
			3973: R_X86_64_PLT32	rt_mutarray_get-0x4
    3977:	test   rax,rax
    397a:	je     3af6 <botlish_fn_41+0x236>
    3980:	test   rax,0x1
    3986:	mov    rsi,rax
    3989:	jne    39b1 <botlish_fn_41+0xf1>
    398f:	mov    edx,0x3
    3994:	mov    rdi,r12
    3997:	call   399c <botlish_fn_41+0xdc>
			3998: R_X86_64_PLT32	rt_int_cmp-0x4
    399c:	mov    ecx,0x2
    39a1:	test   rax,rax
    39a4:	cmove  rcx,QWORD PTR [rip+0x194]        # 3b40 <botlish_fn_41+0x280>
    39ac:	jmp    39c2 <botlish_fn_41+0x102>
    39b1:	mov    ecx,0x2
    39b6:	cmp    rsi,0x3
    39ba:	cmove  rcx,QWORD PTR [rip+0x17e]        # 3b40 <botlish_fn_41+0x280>
    39c2:	cmp    rcx,0x6
    39c6:	je     3ad2 <botlish_fn_41+0x212>
    39cc:	mov    rsi,r14
    39cf:	mov    rdi,r12
    39d2:	call   39d7 <botlish_fn_41+0x117>
			39d3: R_X86_64_PLT32	botlish_fn_38-0x4 ; ht_should_grow<HashTable>
    39d7:	test   rax,rax
    39da:	je     3af6 <botlish_fn_41+0x236>
    39e0:	cmp    rax,0x6
    39e4:	je     3a2b <botlish_fn_41+0x16b>
    39ea:	mov    rcx,r13
    39ed:	mov    rdx,QWORD PTR [rsp+0x28]
    39f2:	mov    rsi,r14
    39f5:	mov    rdi,r12
    39f8:	mov    r8,rbx
    39fb:	call   3a00 <botlish_fn_41+0x140>
			39fc: R_X86_64_PLT32	botlish_fn_40-0x4 ; ht_place<HashTable, int, str, str>
    3a00:	test   rax,rax
    3a03:	je     3af6 <botlish_fn_41+0x236>
    3a09:	mov    rbx,QWORD PTR [rsp+0x30]
    3a0e:	mov    r12,QWORD PTR [rsp+0x38]
    3a13:	mov    r13,QWORD PTR [rsp+0x40]
    3a18:	mov    r14,QWORD PTR [rsp+0x48]
    3a1d:	mov    r15,QWORD PTR [rsp+0x50]
    3a22:	add    rsp,0x60
    3a26:	mov    rsp,rbp
    3a29:	pop    rbp
    3a2a:	ret
    3a2b:	mov    rsi,r14
    3a2e:	mov    rdi,r12
    3a31:	call   3a36 <botlish_fn_41+0x176>
			3a32: R_X86_64_PLT32	botlish_fn_39-0x4 ; ht_grow_or_clean<HashTable>
    3a36:	mov    rcx,rax
    3a39:	mov    r14,rax
    3a3c:	test   rax,rcx
    3a3f:	je     3af6 <botlish_fn_41+0x236>
    3a45:	mov    rax,r14
    3a48:	mov    QWORD PTR [rsp],rax
    3a4c:	mov    rdx,r13
    3a4f:	mov    rsi,r14
    3a52:	mov    rdi,r12
    3a55:	call   3a5a <botlish_fn_41+0x19a>
			3a56: R_X86_64_PLT32	botlish_fn_29-0x4 ; ht_probe_start<HashTable, str>
    3a5a:	test   rax,rax
    3a5d:	je     3af6 <botlish_fn_41+0x236>
    3a63:	mov    QWORD PTR [rsp+0x18],rax
    3a68:	mov    rcx,rax
    3a6b:	mov    QWORD PTR [rsp+0x20],0xffffffffffffffff
    3a74:	mov    r8,r15
    3a77:	mov    rdx,r13
    3a7a:	mov    rsi,r14
    3a7d:	mov    rdi,r12
    3a80:	call   3a85 <botlish_fn_41+0x1c5>
			3a81: R_X86_64_PLT32	botlish_fn_32-0x4 ; ht_find_insert<HashTable, str, int, int>
    3a85:	test   rax,rax
    3a88:	je     3af6 <botlish_fn_41+0x236>
    3a8e:	mov    QWORD PTR [rsp+0x18],rax
    3a93:	mov    rcx,r13
    3a96:	mov    rdx,rax
    3a99:	mov    rsi,r14
    3a9c:	mov    rdi,r12
    3a9f:	mov    r8,rbx
    3aa2:	call   3aa7 <botlish_fn_41+0x1e7>
			3aa3: R_X86_64_PLT32	botlish_fn_40-0x4 ; ht_place<HashTable, int, str, str>
    3aa7:	test   rax,rax
    3aaa:	je     3af6 <botlish_fn_41+0x236>
    3ab0:	mov    rbx,QWORD PTR [rsp+0x30]
    3ab5:	mov    r12,QWORD PTR [rsp+0x38]
    3aba:	mov    r13,QWORD PTR [rsp+0x40]
    3abf:	mov    r14,QWORD PTR [rsp+0x48]
    3ac4:	mov    r15,QWORD PTR [rsp+0x50]
    3ac9:	add    rsp,0x60
    3acd:	mov    rsp,rbp
    3ad0:	pop    rbp
    3ad1:	ret
    3ad2:	mov    rdx,QWORD PTR [rsp+0x28]
    3ad7:	mov    rsi,r14
    3ada:	mov    rax,QWORD PTR [rsi+0x18]
    3ade:	mov    rsi,QWORD PTR [rax+0x10]
    3ae2:	mov    rcx,rbx
    3ae5:	mov    rdi,r12
    3ae8:	call   3aed <botlish_fn_41+0x22d>
			3ae9: R_X86_64_PLT32	rt_mutarray_set-0x4
    3aed:	test   rax,rax
    3af0:	jne    3b1b <botlish_fn_41+0x25b>
    3af6:	xor    rax,rax
    3af9:	mov    rbx,QWORD PTR [rsp+0x30]
    3afe:	mov    r12,QWORD PTR [rsp+0x38]
    3b03:	mov    r13,QWORD PTR [rsp+0x40]
    3b08:	mov    r14,QWORD PTR [rsp+0x48]
    3b0d:	mov    r15,QWORD PTR [rsp+0x50]
    3b12:	add    rsp,0x60
    3b16:	mov    rsp,rbp
    3b19:	pop    rbp
    3b1a:	ret
    3b1b:	mov    rax,r14
    3b1e:	mov    rbx,QWORD PTR [rsp+0x30]
    3b23:	mov    r12,QWORD PTR [rsp+0x38]
    3b28:	mov    r13,QWORD PTR [rsp+0x40]
    3b2d:	mov    r14,QWORD PTR [rsp+0x48]
    3b32:	mov    r15,QWORD PTR [rsp+0x50]
    3b37:	add    rsp,0x60
    3b3b:	mov    rsp,rbp
    3b3e:	pop    rbp
    3b3f:	ret
    3b40:	(bad)
    3b41:	add    BYTE PTR [rax],al
    3b43:	add    BYTE PTR [rax],al
    3b45:	add    BYTE PTR [rax],al
	...

0000000000003b48 <botlish_entry_41: ht_set<HashTable, str, str>>:
    3b48:	push   rbp
    3b49:	mov    rbp,rsp
    3b4c:	mov    rsi,QWORD PTR [rdx]
    3b4f:	mov    r8,QWORD PTR [rdx+0x8]
    3b53:	mov    rcx,QWORD PTR [rdx+0x10]
    3b57:	mov    rdx,r8
    3b5a:	call   3b5f <botlish_entry_41+0x17>
			3b5b: R_X86_64_PLT32	botlish_fn_41-0x4 ; ht_set<HashTable, str, str>
    3b5f:	mov    rsp,rbp
    3b62:	pop    rbp
    3b63:	ret

0000000000003b64 <botlish_fn_42: row_new<bool, int>>:
    3b64:	push   rbp
    3b65:	mov    rbp,rsp
    3b68:	sub    rsp,0x10
    3b6c:	mov    QWORD PTR [rsp],rdx
    3b70:	mov    r8,rdx
    3b73:	cmp    rsi,0x6
    3b77:	je     3b94 <botlish_fn_42+0x30>
    3b7d:	call   3b82 <botlish_fn_42+0x1e>
			3b7e: R_X86_64_PLT32	botlish_fn_23-0x4 ; ht_new<generic>
    3b82:	test   rax,rax
    3b85:	je     3ba5 <botlish_fn_42+0x41>
    3b8b:	add    rsp,0x10
    3b8f:	mov    rsp,rbp
    3b92:	pop    rbp
    3b93:	ret
    3b94:	mov    rsi,r8
    3b97:	call   3b9c <botlish_fn_42+0x38>
			3b98: R_X86_64_PLT32	botlish_fn_25-0x4 ; ht_new_sized<int>
    3b9c:	test   rax,rax
    3b9f:	jne    3bb1 <botlish_fn_42+0x4d>
    3ba5:	xor    rax,rax
    3ba8:	add    rsp,0x10
    3bac:	mov    rsp,rbp
    3baf:	pop    rbp
    3bb0:	ret
    3bb1:	add    rsp,0x10
    3bb5:	mov    rsp,rbp
    3bb8:	pop    rbp
    3bb9:	ret

0000000000003bba <botlish_entry_42: row_new<bool, int>>:
    3bba:	push   rbp
    3bbb:	mov    rbp,rsp
    3bbe:	mov    rsi,QWORD PTR [rdx]
    3bc1:	mov    rdx,QWORD PTR [rdx+0x8]
    3bc5:	call   3bca <botlish_entry_42+0x10>
			3bc6: R_X86_64_PLT32	botlish_fn_42-0x4 ; row_new<bool, int>
    3bca:	mov    rsp,rbp
    3bcd:	pop    rbp
    3bce:	ret

0000000000003bcf <botlish_fn_43: row_fill<HashTable, List[str], List[str], int, int>>:
    3bcf:	push   rbp
    3bd0:	mov    rbp,rsp
    3bd3:	sub    rsp,0x70
    3bd7:	mov    QWORD PTR [rsp+0x40],rbx
    3bdc:	mov    QWORD PTR [rsp+0x48],r12
    3be1:	mov    QWORD PTR [rsp+0x50],r13
    3be6:	mov    QWORD PTR [rsp+0x58],r14
    3beb:	mov    QWORD PTR [rsp+0x60],r15
    3bf0:	mov    r15,rdi
    3bf3:	mov    QWORD PTR [rsp],rsi
    3bf7:	mov    QWORD PTR [rsp+0x8],rdx
    3bfc:	mov    QWORD PTR [rsp+0x10],rcx
    3c01:	mov    r14,rcx
    3c04:	sar    r8,1
    3c07:	mov    rbx,r8
    3c0a:	mov    r12,r9
    3c0d:	mov    QWORD PTR [rsp+0x28],rsi
    3c12:	cmp    rbx,r12
    3c15:	jge    3d24 <botlish_fn_43+0x155>
    3c1b:	mov    r13,rdx
    3c1e:	mov    rdx,QWORD PTR [r13+0x8]
    3c22:	mov    rcx,rbx
    3c25:	shl    rcx,1
    3c28:	or     rcx,0x1
    3c2c:	sar    rcx,1
    3c2f:	cmp    rcx,rdx
    3c32:	jb     3c5e <botlish_fn_43+0x8f>
    3c38:	mov    rdx,rbx
    3c3b:	shl    rdx,1
    3c3e:	or     rdx,0x1
    3c42:	mov    rsi,r13
    3c45:	mov    rdi,r15
    3c48:	call   3c4d <botlish_fn_43+0x7e>
			3c49: R_X86_64_PLT32	rt_list_get-0x4
    3c4d:	test   rax,rax
    3c50:	je     3cdd <botlish_fn_43+0x10e>
    3c56:	mov    rdx,rax
    3c59:	jmp    3c66 <botlish_fn_43+0x97>
    3c5e:	mov    rax,QWORD PTR [r13+0x10]
    3c62:	mov    rdx,QWORD PTR [rax+rcx*8]
    3c66:	mov    QWORD PTR [rsp+0x18],rdx
    3c6b:	mov    QWORD PTR [rsp+0x30],rdx
    3c70:	mov    rax,QWORD PTR [r14+0x8]
    3c74:	mov    rcx,rbx
    3c77:	shl    rcx,1
    3c7a:	or     rcx,0x1
    3c7e:	sar    rcx,1
    3c81:	cmp    rcx,rax
    3c84:	jb     3cb5 <botlish_fn_43+0xe6>
    3c8a:	mov    rdx,rbx
    3c8d:	shl    rdx,1
    3c90:	or     rdx,0x1
    3c94:	mov    rsi,r14
    3c97:	mov    rdi,r15
    3c9a:	call   3c9f <botlish_fn_43+0xd0>
			3c9b: R_X86_64_PLT32	rt_list_get-0x4
    3c9f:	test   rax,rax
    3ca2:	je     3cdd <botlish_fn_43+0x10e>
    3ca8:	mov    rcx,rax
    3cab:	mov    rsi,QWORD PTR [rsp+0x28]
    3cb0:	jmp    3cc2 <botlish_fn_43+0xf3>
    3cb5:	mov    rax,QWORD PTR [r14+0x10]
    3cb9:	mov    rcx,QWORD PTR [rax+rcx*8]
    3cbd:	mov    rsi,QWORD PTR [rsp+0x28]
    3cc2:	mov    QWORD PTR [rsp+0x20],rcx
    3cc7:	mov    rdx,QWORD PTR [rsp+0x30]
    3ccc:	mov    rdi,r15
    3ccf:	call   3cd4 <botlish_fn_43+0x105>
			3cd0: R_X86_64_PLT32	botlish_fn_41-0x4 ; ht_set<HashTable, str, str>
    3cd4:	test   rax,rax
    3cd7:	jne    3d02 <botlish_fn_43+0x133>
    3cdd:	xor    rax,rax
    3ce0:	mov    rbx,QWORD PTR [rsp+0x40]
    3ce5:	mov    r12,QWORD PTR [rsp+0x48]
    3cea:	mov    r13,QWORD PTR [rsp+0x50]
    3cef:	mov    r14,QWORD PTR [rsp+0x58]
    3cf4:	mov    r15,QWORD PTR [rsp+0x60]
    3cf9:	add    rsp,0x70
    3cfd:	mov    rsp,rbp
    3d00:	pop    rbp
    3d01:	ret
    3d02:	mov    QWORD PTR [rsp],rax
    3d06:	mov    QWORD PTR [rsp+0x8],r13
    3d0b:	mov    QWORD PTR [rsp+0x10],r14
    3d10:	add    rbx,0x1
    3d17:	mov    rdx,r13
    3d1a:	mov    QWORD PTR [rsp+0x28],rax
    3d1f:	jmp    3c12 <botlish_fn_43+0x43>
    3d24:	mov    rax,QWORD PTR [rsp+0x28]
    3d29:	mov    rbx,QWORD PTR [rsp+0x40]
    3d2e:	mov    r12,QWORD PTR [rsp+0x48]
    3d33:	mov    r13,QWORD PTR [rsp+0x50]
    3d38:	mov    r14,QWORD PTR [rsp+0x58]
    3d3d:	mov    r15,QWORD PTR [rsp+0x60]
    3d42:	add    rsp,0x70
    3d46:	mov    rsp,rbp
    3d49:	pop    rbp
    3d4a:	ret

0000000000003d4b <botlish_entry_43: row_fill<HashTable, List[str], List[str], int, int>>:
    3d4b:	push   rbp
    3d4c:	mov    rbp,rsp
    3d4f:	mov    rsi,QWORD PTR [rdx]
    3d52:	mov    r10,QWORD PTR [rdx+0x8]
    3d56:	mov    rcx,QWORD PTR [rdx+0x10]
    3d5a:	mov    r8,QWORD PTR [rdx+0x18]
    3d5e:	mov    r9,QWORD PTR [rdx+0x20]
    3d62:	sar    r9,1
    3d65:	mov    rdx,r10
    3d68:	call   3d6d <botlish_entry_43+0x22>
			3d69: R_X86_64_PLT32	botlish_fn_43-0x4 ; row_fill<HashTable, List[str], List[str], int, int>
    3d6d:	mov    rsp,rbp
    3d70:	pop    rbp
    3d71:	ret

0000000000003d72 <botlish_fn_44: row_table<List[str], int, List[str], bool>>:
    3d72:	push   rbp
    3d73:	mov    rbp,rsp
    3d76:	sub    rsp,0x50
    3d7a:	mov    QWORD PTR [rsp+0x20],rbx
    3d7f:	mov    QWORD PTR [rsp+0x28],r12
    3d84:	mov    QWORD PTR [rsp+0x30],r13
    3d89:	mov    QWORD PTR [rsp+0x38],r14
    3d8e:	mov    QWORD PTR [rsp+0x40],r15
    3d93:	mov    r12,rdi
    3d96:	mov    QWORD PTR [rsp],rsi
    3d9a:	mov    r15,rsi
    3d9d:	mov    QWORD PTR [rsp+0x8],rdx
    3da2:	mov    QWORD PTR [rsp+0x10],rcx
    3da7:	mov    r13,rcx
    3daa:	mov    QWORD PTR [rsp+0x18],r8
    3daf:	mov    rsi,r8
    3db2:	mov    rdi,r12
    3db5:	call   3dba <botlish_fn_44+0x48>
			3db6: R_X86_64_PLT32	botlish_fn_42-0x4 ; row_new<bool, int>
    3dba:	test   rax,rax
    3dbd:	je     3e07 <botlish_fn_44+0x95>
    3dc3:	mov    QWORD PTR [rsp+0x8],rax
    3dc8:	mov    r14,rax
    3dcb:	mov    ebx,0x1
    3dd0:	mov    QWORD PTR [rsp+0x18],0x1
    3dd9:	mov    rsi,r13
    3ddc:	mov    rdi,r12
    3ddf:	call   3de4 <botlish_fn_44+0x72>
			3de0: R_X86_64_PLT32	rt_list_len-0x4
    3de4:	mov    r9,rax
    3de7:	sar    r9,1
    3dea:	mov    rcx,r13
    3ded:	mov    rdx,r15
    3df0:	mov    rsi,r14
    3df3:	mov    rdi,r12
    3df6:	mov    r8,rbx
    3df9:	call   3dfe <botlish_fn_44+0x8c>
			3dfa: R_X86_64_PLT32	botlish_fn_43-0x4 ; row_fill<HashTable, List[str], List[str], int, int>
    3dfe:	test   rax,rax
    3e01:	jne    3e2c <botlish_fn_44+0xba>
    3e07:	xor    rax,rax
    3e0a:	mov    rbx,QWORD PTR [rsp+0x20]
    3e0f:	mov    r12,QWORD PTR [rsp+0x28]
    3e14:	mov    r13,QWORD PTR [rsp+0x30]
    3e19:	mov    r14,QWORD PTR [rsp+0x38]
    3e1e:	mov    r15,QWORD PTR [rsp+0x40]
    3e23:	add    rsp,0x50
    3e27:	mov    rsp,rbp
    3e2a:	pop    rbp
    3e2b:	ret
    3e2c:	mov    rbx,QWORD PTR [rsp+0x20]
    3e31:	mov    r12,QWORD PTR [rsp+0x28]
    3e36:	mov    r13,QWORD PTR [rsp+0x30]
    3e3b:	mov    r14,QWORD PTR [rsp+0x38]
    3e40:	mov    r15,QWORD PTR [rsp+0x40]
    3e45:	add    rsp,0x50
    3e49:	mov    rsp,rbp
    3e4c:	pop    rbp
    3e4d:	ret

0000000000003e4e <botlish_entry_44: row_table<List[str], int, List[str], bool>>:
    3e4e:	push   rbp
    3e4f:	mov    rbp,rsp
    3e52:	mov    rsi,QWORD PTR [rdx]
    3e55:	mov    r9,QWORD PTR [rdx+0x8]
    3e59:	mov    rcx,QWORD PTR [rdx+0x10]
    3e5d:	mov    r8,QWORD PTR [rdx+0x18]
    3e61:	mov    rdx,r9
    3e64:	call   3e69 <botlish_entry_44+0x1b>
			3e65: R_X86_64_PLT32	botlish_fn_44-0x4 ; row_table<List[str], int, List[str], bool>
    3e69:	mov    rsp,rbp
    3e6c:	pop    rbp
    3e6d:	ret

0000000000003e6e <botlish_fn_45: build_rows<List[List[str]], int, List[str], int, mutarray, int, bool>>:
    3e6e:	push   rbp
    3e6f:	mov    rbp,rsp
    3e72:	sub    rsp,0x90
    3e79:	mov    QWORD PTR [rsp+0x60],rbx
    3e7e:	mov    QWORD PTR [rsp+0x68],r12
    3e83:	mov    QWORD PTR [rsp+0x70],r13
    3e88:	mov    QWORD PTR [rsp+0x78],r14
    3e8d:	mov    QWORD PTR [rsp+0x80],r15
    3e95:	mov    r13,r8
    3e98:	mov    QWORD PTR [rsp+0x38],rdi
    3e9d:	mov    rdi,QWORD PTR [rbp+0x10]
    3ea1:	mov    r15,QWORD PTR [rbp+0x18]
    3ea5:	mov    QWORD PTR [rsp+0x28],0x0
    3eae:	mov    QWORD PTR [rsp+0x30],0x0
    3eb7:	mov    QWORD PTR [rsp],rsi
    3ebb:	mov    QWORD PTR [rsp+0x8],rcx
    3ec0:	mov    r14,rcx
    3ec3:	mov    QWORD PTR [rsp+0x10],r9
    3ec8:	mov    QWORD PTR [rsp+0x18],rdi
    3ecd:	mov    QWORD PTR [rsp+0x20],r15
    3ed2:	sar    rdx,1
    3ed5:	mov    r12,rdx
    3ed8:	mov    rbx,rsi
    3edb:	mov    QWORD PTR [rsp+0x40],r9
    3ee0:	mov    QWORD PTR [rsp+0x48],rdi
    3ee5:	mov    rsi,rbx
    3ee8:	mov    rdi,QWORD PTR [rsp+0x38]
    3eed:	call   3ef2 <botlish_fn_45+0x84>
			3eee: R_X86_64_PLT32	rt_list_len-0x4
    3ef2:	sar    rax,1
    3ef5:	cmp    r12,rax
    3ef8:	jge    4023 <botlish_fn_45+0x1b5>
    3efe:	mov    rax,r13
    3f01:	or     rax,0x1
    3f05:	mov    QWORD PTR [rsp+0x28],rax
    3f0a:	mov    rcx,QWORD PTR [rbx+0x8]
    3f0e:	mov    rax,r12
    3f11:	shl    rax,1
    3f14:	or     rax,0x1
    3f18:	sar    rax,1
    3f1b:	cmp    rax,rcx
    3f1e:	jb     3f4c <botlish_fn_45+0xde>
    3f24:	mov    rdx,r12
    3f27:	shl    rdx,1
    3f2a:	or     rdx,0x1
    3f2e:	mov    rsi,rbx
    3f31:	mov    rdi,QWORD PTR [rsp+0x38]
    3f36:	call   3f3b <botlish_fn_45+0xcd>
			3f37: R_X86_64_PLT32	rt_list_get-0x4
    3f3b:	test   rax,rax
    3f3e:	je     4040 <botlish_fn_45+0x1d2>
    3f44:	mov    rcx,rax
    3f47:	jmp    3f54 <botlish_fn_45+0xe6>
    3f4c:	mov    rcx,QWORD PTR [rbx+0x10]
    3f50:	mov    rcx,QWORD PTR [rcx+rax*8]
    3f54:	mov    QWORD PTR [rsp+0x30],rcx
    3f59:	mov    rdx,r13
    3f5c:	or     rdx,0x1
    3f60:	mov    rsi,r14
    3f63:	mov    rdi,QWORD PTR [rsp+0x38]
    3f68:	mov    r8,r15
    3f6b:	call   3f70 <botlish_fn_45+0x102>
			3f6c: R_X86_64_PLT32	botlish_fn_44-0x4 ; row_table<List[str], int, List[str], bool>
    3f70:	test   rax,rax
    3f73:	je     4040 <botlish_fn_45+0x1d2>
    3f79:	mov    QWORD PTR [rsp+0x28],rax
    3f7e:	mov    rcx,rax
    3f81:	mov    rsi,QWORD PTR [rsp+0x40]
    3f86:	mov    rdx,QWORD PTR [rsp+0x48]
    3f8b:	mov    rdi,QWORD PTR [rsp+0x38]
    3f90:	call   3f95 <botlish_fn_45+0x127>
			3f91: R_X86_64_PLT32	botlish_fn_10-0x4 ; geo_append<mutarray, int, HashTable>
    3f95:	test   rax,rax
    3f98:	je     4040 <botlish_fn_45+0x1d2>
    3f9e:	mov    QWORD PTR [rsp+0x10],rax
    3fa3:	mov    QWORD PTR [rsp+0x50],rax
    3fa8:	mov    QWORD PTR [rsp+0x28],0x3
    3fb1:	mov    rsi,QWORD PTR [rsp+0x48]
    3fb6:	test   rsi,0x1
    3fbd:	je     3fdc <botlish_fn_45+0x16e>
    3fc3:	mov    rsi,QWORD PTR [rsp+0x48]
    3fc8:	mov    rax,rsi
    3fcb:	add    rax,0x2
    3fcf:	seto   r10b
    3fd3:	test   r10b,r10b
    3fd6:	je     3ff0 <botlish_fn_45+0x182>
    3fdc:	mov    edx,0x3
    3fe1:	mov    rsi,QWORD PTR [rsp+0x48]
    3fe6:	mov    rdi,QWORD PTR [rsp+0x38]
    3feb:	call   3ff0 <botlish_fn_45+0x182>
			3fec: R_X86_64_PLT32	rt_int_add-0x4
    3ff0:	mov    QWORD PTR [rsp],rbx
    3ff4:	mov    QWORD PTR [rsp+0x8],r14
    3ff9:	mov    rcx,QWORD PTR [rsp+0x50]
    3ffe:	mov    QWORD PTR [rsp+0x10],rcx
    4003:	mov    QWORD PTR [rsp+0x18],rax
    4008:	mov    QWORD PTR [rsp+0x20],r15
    400d:	add    r12,0x1
    4014:	mov    QWORD PTR [rsp+0x40],rcx
    4019:	mov    QWORD PTR [rsp+0x48],rax
    401e:	jmp    3ee5 <botlish_fn_45+0x77>
    4023:	mov    rdx,QWORD PTR [rsp+0x48]
    4028:	mov    rsi,QWORD PTR [rsp+0x40]
    402d:	mov    rdi,QWORD PTR [rsp+0x38]
    4032:	call   4037 <botlish_fn_45+0x1c9>
			4033: R_X86_64_PLT32	botlish_fn_11-0x4 ; geo_finish<mutarray, int>
    4037:	test   rax,rax
    403a:	jne    406b <botlish_fn_45+0x1fd>
    4040:	xor    rax,rax
    4043:	mov    rbx,QWORD PTR [rsp+0x60]
    4048:	mov    r12,QWORD PTR [rsp+0x68]
    404d:	mov    r13,QWORD PTR [rsp+0x70]
    4052:	mov    r14,QWORD PTR [rsp+0x78]
    4057:	mov    r15,QWORD PTR [rsp+0x80]
    405f:	add    rsp,0x90
    4066:	mov    rsp,rbp
    4069:	pop    rbp
    406a:	ret
    406b:	mov    rbx,QWORD PTR [rsp+0x60]
    4070:	mov    r12,QWORD PTR [rsp+0x68]
    4075:	mov    r13,QWORD PTR [rsp+0x70]
    407a:	mov    r14,QWORD PTR [rsp+0x78]
    407f:	mov    r15,QWORD PTR [rsp+0x80]
    4087:	add    rsp,0x90
    408e:	mov    rsp,rbp
    4091:	pop    rbp
    4092:	ret

0000000000004093 <botlish_entry_45: build_rows<List[List[str]], int, List[str], int, mutarray, int, bool>>:
    4093:	push   rbp
    4094:	mov    rbp,rsp
    4097:	sub    rsp,0x10
    409b:	mov    rsi,QWORD PTR [rdx]
    409e:	mov    r10,QWORD PTR [rdx+0x8]
    40a2:	mov    rcx,QWORD PTR [rdx+0x10]
    40a6:	mov    r8,QWORD PTR [rdx+0x18]
    40aa:	mov    r9,QWORD PTR [rdx+0x20]
    40ae:	mov    r11,QWORD PTR [rdx+0x28]
    40b2:	mov    rax,QWORD PTR [rdx+0x30]
    40b6:	mov    QWORD PTR [rsp],r11
    40ba:	mov    QWORD PTR [rsp+0x8],rax
    40bf:	mov    rdx,r10
    40c2:	call   40c7 <botlish_entry_45+0x34>
			40c3: R_X86_64_PLT32	botlish_fn_45-0x4 ; build_rows<List[List[str]], int, List[str], int, mutarray, int, bool>
    40c7:	add    rsp,0x10
    40cb:	mov    rsp,rbp
    40ce:	pop    rbp
    40cf:	ret

00000000000040d0 <botlish_fn_46: csv_records_generic<str, bool>>:
    40d0:	push   rbp
    40d1:	mov    rbp,rsp
    40d4:	sub    rsp,0x80
    40db:	mov    QWORD PTR [rsp+0x50],rbx
    40e0:	mov    QWORD PTR [rsp+0x58],r12
    40e5:	mov    QWORD PTR [rsp+0x60],r13
    40ea:	mov    QWORD PTR [rsp+0x68],r14
    40ef:	mov    QWORD PTR [rsp+0x70],r15
    40f4:	mov    r12,rdi
    40f7:	mov    QWORD PTR [rsp+0x20],0x0
    4100:	mov    QWORD PTR [rsp+0x28],0x0
    4109:	mov    QWORD PTR [rsp+0x30],0x0
    4112:	mov    QWORD PTR [rsp+0x38],0x0
    411b:	mov    QWORD PTR [rsp+0x40],0x0
    4124:	mov    QWORD PTR [rsp+0x10],rsi
    4129:	mov    QWORD PTR [rsp+0x18],rdx
    412e:	mov    r13,rdx
    4131:	mov    rdi,r12
    4134:	call   4139 <botlish_fn_46+0x69>
			4135: R_X86_64_PLT32	botlish_fn_20-0x4 ; csv_parse<str>
    4139:	mov    rcx,rax
    413c:	mov    r14,rax
    413f:	test   rax,rcx
    4142:	je     425c <botlish_fn_46+0x18c>
    4148:	mov    rax,r14
    414b:	mov    QWORD PTR [rsp+0x10],rax
    4150:	mov    rsi,r14
    4153:	mov    rdi,r12
    4156:	call   415b <botlish_fn_46+0x8b>
			4157: R_X86_64_PLT32	rt_list_len-0x4
    415b:	sar    rax,1
    415e:	cmp    rax,0x1
    4162:	jle    4245 <botlish_fn_46+0x175>
    4168:	mov    rax,r14
    416b:	mov    rax,QWORD PTR [rax+0x10]
    416f:	mov    rbx,QWORD PTR [rax]
    4172:	mov    QWORD PTR [rsp+0x20],rbx
    4177:	mov    rsi,rbx
    417a:	mov    rdi,r12
    417d:	call   4182 <botlish_fn_46+0xb2>
			417e: R_X86_64_PLT32	rt_list_len-0x4
    4182:	mov    r15,rbx
    4185:	mov    QWORD PTR [rsp+0x28],rax
    418a:	mov    QWORD PTR [rsp+0x48],rax
    418f:	mov    rax,r14
    4192:	mov    rcx,QWORD PTR [rax+0x10]
    4196:	mov    rcx,QWORD PTR [rcx+0x8]
    419a:	mov    QWORD PTR [rsp+0x30],rcx
    419f:	mov    rbx,r13
    41a2:	mov    rdx,QWORD PTR [rsp+0x48]
    41a7:	mov    rsi,r15
    41aa:	mov    rdi,r12
    41ad:	mov    r8,rbx
    41b0:	call   41b5 <botlish_fn_46+0xe5>
			41b1: R_X86_64_PLT32	botlish_fn_44-0x4 ; row_table<List[str], int, List[str], bool>
    41b5:	test   rax,rax
    41b8:	je     425c <botlish_fn_46+0x18c>
    41be:	mov    QWORD PTR [rsp+0x30],rax
    41c3:	mov    rsi,rax
    41c6:	mov    QWORD PTR [rsp+0x38],0x5
    41cf:	mov    rdi,r12
    41d2:	call   41d7 <botlish_fn_46+0x107>
			41d3: R_X86_64_PLT32	botlish_fn_3-0x4 ; geo_new<HashTable>
    41d7:	test   rax,rax
    41da:	je     425c <botlish_fn_46+0x18c>
    41e0:	mov    QWORD PTR [rsp+0x30],rax
    41e5:	mov    r9,rax
    41e8:	mov    eax,0x3
    41ed:	mov    QWORD PTR [rsp+0x40],0x3
    41f6:	mov    edx,0x5
    41fb:	mov    QWORD PTR [rsp],rax
    41ff:	mov    QWORD PTR [rsp+0x8],rbx
    4204:	mov    rcx,r15
    4207:	mov    rsi,r14
    420a:	mov    rdi,r12
    420d:	mov    r8,QWORD PTR [rsp+0x48]
    4212:	call   4217 <botlish_fn_46+0x147>
			4213: R_X86_64_PLT32	botlish_fn_45-0x4 ; build_rows<List[List[str]], int, List[str], int, mutarray, int, bool>
    4217:	test   rax,rax
    421a:	je     425c <botlish_fn_46+0x18c>
    4220:	mov    rbx,QWORD PTR [rsp+0x50]
    4225:	mov    r12,QWORD PTR [rsp+0x58]
    422a:	mov    r13,QWORD PTR [rsp+0x60]
    422f:	mov    r14,QWORD PTR [rsp+0x68]
    4234:	mov    r15,QWORD PTR [rsp+0x70]
    4239:	add    rsp,0x80
    4240:	mov    rsp,rbp
    4243:	pop    rbp
    4244:	ret
    4245:	xor    rdx,rdx
    4248:	mov    rdi,r12
    424b:	mov    rsi,rdx
    424e:	call   4253 <botlish_fn_46+0x183>
			424f: R_X86_64_PLT32	rt_list_new-0x4
    4253:	test   rax,rax
    4256:	jne    4284 <botlish_fn_46+0x1b4>
    425c:	xor    rax,rax
    425f:	mov    rbx,QWORD PTR [rsp+0x50]
    4264:	mov    r12,QWORD PTR [rsp+0x58]
    4269:	mov    r13,QWORD PTR [rsp+0x60]
    426e:	mov    r14,QWORD PTR [rsp+0x68]
    4273:	mov    r15,QWORD PTR [rsp+0x70]
    4278:	add    rsp,0x80
    427f:	mov    rsp,rbp
    4282:	pop    rbp
    4283:	ret
    4284:	mov    rbx,QWORD PTR [rsp+0x50]
    4289:	mov    r12,QWORD PTR [rsp+0x58]
    428e:	mov    r13,QWORD PTR [rsp+0x60]
    4293:	mov    r14,QWORD PTR [rsp+0x68]
    4298:	mov    r15,QWORD PTR [rsp+0x70]
    429d:	add    rsp,0x80
    42a4:	mov    rsp,rbp
    42a7:	pop    rbp
    42a8:	ret

00000000000042a9 <botlish_entry_46: csv_records_generic<str, bool>>:
    42a9:	push   rbp
    42aa:	mov    rbp,rsp
    42ad:	mov    rsi,QWORD PTR [rdx]
    42b0:	mov    rdx,QWORD PTR [rdx+0x8]
    42b4:	call   42b9 <botlish_entry_46+0x10>
			42b5: R_X86_64_PLT32	botlish_fn_46-0x4 ; csv_records_generic<str, bool>
    42b9:	mov    rsp,rbp
    42bc:	pop    rbp
    42bd:	ret

00000000000042be <botlish_fn_47: csv_records<str>>:
    42be:	push   rbp
    42bf:	mov    rbp,rsp
    42c2:	sub    rsp,0x10
    42c6:	mov    QWORD PTR [rsp],rsi
    42ca:	mov    edx,0x2
    42cf:	mov    QWORD PTR [rsp+0x8],0x2
    42d8:	call   42dd <botlish_fn_47+0x1f>
			42d9: R_X86_64_PLT32	botlish_fn_46-0x4 ; csv_records_generic<str, bool>
    42dd:	test   rax,rax
    42e0:	jne    42f2 <botlish_fn_47+0x34>
    42e6:	xor    rax,rax
    42e9:	add    rsp,0x10
    42ed:	mov    rsp,rbp
    42f0:	pop    rbp
    42f1:	ret
    42f2:	add    rsp,0x10
    42f6:	mov    rsp,rbp
    42f9:	pop    rbp
    42fa:	ret

00000000000042fb <botlish_entry_47: csv_records<str>>:
    42fb:	push   rbp
    42fc:	mov    rbp,rsp
    42ff:	mov    rsi,QWORD PTR [rdx]
    4302:	call   4307 <botlish_entry_47+0xc>
			4303: R_X86_64_PLT32	botlish_fn_47-0x4 ; csv_records<str>
    4307:	mov    rsp,rbp
    430a:	pop    rbp
    430b:	ret

000000000000430c <botlish_fn_48: csv_records_presized<str>>:
    430c:	push   rbp
    430d:	mov    rbp,rsp
    4310:	sub    rsp,0x10
    4314:	mov    QWORD PTR [rsp],rsi
    4318:	mov    edx,0x6
    431d:	mov    QWORD PTR [rsp+0x8],0x6
    4326:	call   432b <botlish_fn_48+0x1f>
			4327: R_X86_64_PLT32	botlish_fn_46-0x4 ; csv_records_generic<str, bool>
    432b:	test   rax,rax
    432e:	jne    4340 <botlish_fn_48+0x34>
    4334:	xor    rax,rax
    4337:	add    rsp,0x10
    433b:	mov    rsp,rbp
    433e:	pop    rbp
    433f:	ret
    4340:	add    rsp,0x10
    4344:	mov    rsp,rbp
    4347:	pop    rbp
    4348:	ret

0000000000004349 <botlish_entry_48: csv_records_presized<str>>:
    4349:	push   rbp
    434a:	mov    rbp,rsp
    434d:	mov    rsi,QWORD PTR [rdx]
    4350:	call   4355 <botlish_entry_48+0xc>
			4351: R_X86_64_PLT32	botlish_fn_48-0x4 ; csv_records_presized<str>
    4355:	mov    rsp,rbp
    4358:	pop    rbp
    4359:	ret
    435a:	add    BYTE PTR [rax],al
    435c:	add    BYTE PTR [rax],al
	...

0000000000004360 <botlish_fn_49: sample_checks<generic>>:
    4360:	push   rbp
    4361:	mov    rbp,rsp
    4364:	sub    rsp,0xc0
    436b:	mov    QWORD PTR [rsp+0x90],rbx
    4373:	mov    QWORD PTR [rsp+0x98],r12
    437b:	mov    QWORD PTR [rsp+0xa0],r13
    4383:	mov    QWORD PTR [rsp+0xa8],r14
    438b:	mov    QWORD PTR [rsp+0xb0],r15
    4393:	mov    QWORD PTR [rsp+0x8],0x0
    439c:	mov    QWORD PTR [rsp+0x10],0x0
    43a5:	mov    QWORD PTR [rsp+0x18],0x0
    43ae:	mov    QWORD PTR [rsp+0x20],0x0
    43b7:	mov    QWORD PTR [rsp+0x28],0x0
    43c0:	mov    QWORD PTR [rsp+0x30],0x0
    43c9:	mov    QWORD PTR [rsp+0x38],0x0
    43d2:	mov    rax,QWORD PTR [rdi+0x10]
    43d6:	mov    r13,rdi
    43d9:	mov    rsi,QWORD PTR [rax+0x20]
    43dd:	mov    QWORD PTR [rsp],rsi
    43e1:	call   43e6 <botlish_fn_49+0x86>
			43e2: R_X86_64_PLT32	botlish_fn_47-0x4 ; csv_records<str>
    43e6:	mov    rsi,rax
    43e9:	mov    r12,rax
    43ec:	test   rax,rsi
    43ef:	je     4775 <botlish_fn_49+0x415>
    43f5:	mov    rax,r12
    43f8:	mov    QWORD PTR [rsp],rax
    43fc:	mov    rdi,r13
    43ff:	mov    rax,QWORD PTR [rdi+0x10]
    4403:	mov    rsi,QWORD PTR [rax+0x20]
    4407:	mov    QWORD PTR [rsp+0x8],rsi
    440c:	call   4411 <botlish_fn_49+0xb1>
			440d: R_X86_64_PLT32	botlish_fn_48-0x4 ; csv_records_presized<str>
    4411:	mov    rbx,rax
    4414:	test   rbx,rbx
    4417:	je     4775 <botlish_fn_49+0x415>
    441d:	mov    rax,r12
    4420:	mov    rax,QWORD PTR [rax+0x8]
    4424:	test   rax,rax
    4427:	jne    444e <botlish_fn_49+0xee>
    442d:	mov    edx,0x1
    4432:	mov    rsi,r12
    4435:	mov    rdi,r13
    4438:	call   443d <botlish_fn_49+0xdd>
			4439: R_X86_64_PLT32	rt_list_get-0x4
    443d:	test   rax,rax
    4440:	je     4775 <botlish_fn_49+0x415>
    4446:	mov    rsi,rax
    4449:	jmp    4456 <botlish_fn_49+0xf6>
    444e:	mov    rax,QWORD PTR [r12+0x10]
    4453:	mov    rsi,QWORD PTR [rax]
    4456:	mov    QWORD PTR [rsp+0x8],rsi
    445b:	mov    r15,rsi
    445e:	mov    rax,QWORD PTR [r12+0x8]
    4463:	cmp    rax,0x1
    4467:	ja     448e <botlish_fn_49+0x12e>
    446d:	mov    edx,0x3
    4472:	mov    rsi,r12
    4475:	mov    rdi,r13
    4478:	call   447d <botlish_fn_49+0x11d>
			4479: R_X86_64_PLT32	rt_list_get-0x4
    447d:	test   rax,rax
    4480:	je     4775 <botlish_fn_49+0x415>
    4486:	mov    rsi,rax
    4489:	jmp    4497 <botlish_fn_49+0x137>
    448e:	mov    rax,QWORD PTR [r12+0x10]
    4493:	mov    rsi,QWORD PTR [rax+0x8]
    4497:	mov    QWORD PTR [rsp+0x10],rsi
    449c:	mov    r14,rsi
    449f:	mov    rax,QWORD PTR [rbx+0x8]
    44a3:	mov    rsi,rbx
    44a6:	test   rax,rax
    44a9:	jne    44cd <botlish_fn_49+0x16d>
    44af:	mov    edx,0x1
    44b4:	mov    rdi,r13
    44b7:	call   44bc <botlish_fn_49+0x15c>
			44b8: R_X86_64_PLT32	rt_list_get-0x4
    44bc:	test   rax,rax
    44bf:	je     4775 <botlish_fn_49+0x415>
    44c5:	mov    rsi,rax
    44c8:	jmp    44d4 <botlish_fn_49+0x174>
    44cd:	mov    rax,QWORD PTR [rsi+0x10]
    44d1:	mov    rsi,QWORD PTR [rax]
    44d4:	mov    QWORD PTR [rsp+0x18],rsi
    44d9:	mov    rdi,r13
    44dc:	mov    QWORD PTR [rsp+0x78],rsi
    44e1:	mov    rax,QWORD PTR [rdi+0x10]
    44e5:	mov    rdx,QWORD PTR [rax+0x28]
    44e9:	mov    QWORD PTR [rsp+0x20],rdx
    44ee:	mov    rsi,r15
    44f1:	call   44f6 <botlish_fn_49+0x196>
			44f2: R_X86_64_PLT32	botlish_fn_33-0x4 ; ht_get<HashTable, str>
    44f6:	test   rax,rax
    44f9:	je     4775 <botlish_fn_49+0x415>
    44ff:	mov    QWORD PTR [rsp+0x20],rax
    4504:	mov    rbx,rax
    4507:	mov    rdi,r13
    450a:	mov    rax,QWORD PTR [rdi+0x10]
    450e:	mov    rdx,QWORD PTR [rax+0x28]
    4512:	mov    QWORD PTR [rsp+0x28],rdx
    4517:	mov    rsi,QWORD PTR [rsp+0x78]
    451c:	call   4521 <botlish_fn_49+0x1c1>
			451d: R_X86_64_PLT32	botlish_fn_33-0x4 ; ht_get<HashTable, str>
    4521:	test   rax,rax
    4524:	je     4775 <botlish_fn_49+0x415>
    452a:	mov    rcx,rbx
    452d:	mov    rdx,rcx
    4530:	and    rdx,rax
    4533:	test   rdx,0x1
    453a:	jne    455c <botlish_fn_49+0x1fc>
    4540:	mov    rdx,rax
    4543:	mov    rsi,rbx
    4546:	mov    rdi,r13
    4549:	call   454e <botlish_fn_49+0x1ee>
			454a: R_X86_64_PLT32	rt_value_eq-0x4
    454e:	test   rax,rax
    4551:	je     4775 <botlish_fn_49+0x415>
    4557:	jmp    4572 <botlish_fn_49+0x212>
    455c:	mov    rdx,rax
    455f:	mov    rsi,rbx
    4562:	mov    eax,0x2
    4567:	cmp    rsi,rdx
    456a:	cmove  rax,QWORD PTR [rip+0x26e]        # 47e0 <botlish_fn_49+0x480>
    4572:	mov    ebx,0x6
    4577:	cmp    rax,0x6
    457b:	je     4597 <botlish_fn_49+0x237>
    4581:	mov    ebx,0x2
    4586:	mov    QWORD PTR [rsp+0x18],0x2
    458f:	mov    rsi,r12
    4592:	jmp    4637 <botlish_fn_49+0x2d7>
    4597:	mov    rsi,r15
    459a:	mov    rdi,r13
    459d:	call   45a2 <botlish_fn_49+0x242>
			459e: R_X86_64_PLT32	botlish_fn_26-0x4 ; ht_size<HashTable>
    45a2:	test   rax,rax
    45a5:	mov    QWORD PTR [rsp+0x88],rax
    45ad:	je     4775 <botlish_fn_49+0x415>
    45b3:	mov    rsi,QWORD PTR [rsp+0x78]
    45b8:	mov    rdi,r13
    45bb:	call   45c0 <botlish_fn_49+0x260>
			45bc: R_X86_64_PLT32	botlish_fn_26-0x4 ; ht_size<HashTable>
    45c0:	test   rax,rax
    45c3:	je     4775 <botlish_fn_49+0x415>
    45c9:	mov    rcx,QWORD PTR [rsp+0x88]
    45d1:	mov    rdx,rcx
    45d4:	and    rdx,rax
    45d7:	test   rdx,0x1
    45de:	jne    4605 <botlish_fn_49+0x2a5>
    45e4:	mov    rdx,rax
    45e7:	mov    rsi,QWORD PTR [rsp+0x88]
    45ef:	mov    rdi,r13
    45f2:	call   45f7 <botlish_fn_49+0x297>
			45f3: R_X86_64_PLT32	rt_value_eq-0x4
    45f7:	test   rax,rax
    45fa:	je     4775 <botlish_fn_49+0x415>
    4600:	jmp    4620 <botlish_fn_49+0x2c0>
    4605:	mov    rdx,rax
    4608:	mov    rsi,QWORD PTR [rsp+0x88]
    4610:	mov    eax,0x2
    4615:	cmp    rsi,rdx
    4618:	cmove  rax,QWORD PTR [rip+0x1c0]        # 47e0 <botlish_fn_49+0x480>
    4620:	cmp    rax,0x6
    4624:	je     462f <botlish_fn_49+0x2cf>
    462a:	mov    ebx,0x2
    462f:	mov    QWORD PTR [rsp+0x18],rbx
    4634:	mov    rsi,r12
    4637:	mov    rdi,r13
    463a:	call   463f <botlish_fn_49+0x2df>
			463b: R_X86_64_PLT32	rt_list_len-0x4
    463f:	mov    QWORD PTR [rsp],rax
    4643:	mov    rdi,r13
    4646:	mov    r12,rax
    4649:	mov    rax,QWORD PTR [rdi+0x10]
    464d:	mov    rdx,QWORD PTR [rax+0x28]
    4651:	mov    QWORD PTR [rsp+0x20],rdx
    4656:	mov    rsi,r15
    4659:	call   465e <botlish_fn_49+0x2fe>
			465a: R_X86_64_PLT32	botlish_fn_33-0x4 ; ht_get<HashTable, str>
    465e:	test   rax,rax
    4661:	je     4775 <botlish_fn_49+0x415>
    4667:	mov    QWORD PTR [rsp+0x20],rax
    466c:	mov    rdi,r13
    466f:	mov    QWORD PTR [rsp+0x88],rax
    4677:	mov    rax,QWORD PTR [rdi+0x10]
    467b:	mov    rdx,QWORD PTR [rax+0x30]
    467f:	mov    QWORD PTR [rsp+0x28],rdx
    4684:	mov    rsi,r15
    4687:	call   468c <botlish_fn_49+0x32c>
			4688: R_X86_64_PLT32	botlish_fn_33-0x4 ; ht_get<HashTable, str>
    468c:	test   rax,rax
    468f:	je     4775 <botlish_fn_49+0x415>
    4695:	mov    QWORD PTR [rsp+0x28],rax
    469a:	mov    rdi,r13
    469d:	mov    QWORD PTR [rsp+0x80],rax
    46a5:	mov    rax,QWORD PTR [rdi+0x10]
    46a9:	mov    rdx,QWORD PTR [rax+0x38]
    46ad:	mov    QWORD PTR [rsp+0x30],rdx
    46b2:	mov    rsi,r15
    46b5:	call   46ba <botlish_fn_49+0x35a>
			46b6: R_X86_64_PLT32	botlish_fn_33-0x4 ; ht_get<HashTable, str>
    46ba:	test   rax,rax
    46bd:	je     4775 <botlish_fn_49+0x415>
    46c3:	mov    QWORD PTR [rsp+0x8],rax
    46c8:	mov    rdi,r13
    46cb:	mov    r15,rax
    46ce:	mov    rax,QWORD PTR [rdi+0x10]
    46d2:	mov    rdx,QWORD PTR [rax+0x28]
    46d6:	mov    QWORD PTR [rsp+0x30],rdx
    46db:	mov    rsi,r14
    46de:	call   46e3 <botlish_fn_49+0x383>
			46df: R_X86_64_PLT32	botlish_fn_33-0x4 ; ht_get<HashTable, str>
    46e3:	test   rax,rax
    46e6:	je     4775 <botlish_fn_49+0x415>
    46ec:	mov    QWORD PTR [rsp+0x30],rax
    46f1:	mov    rdi,r13
    46f4:	mov    QWORD PTR [rsp+0x78],rax
    46f9:	mov    rax,QWORD PTR [rdi+0x10]
    46fd:	mov    rdx,QWORD PTR [rax+0x38]
    4701:	mov    QWORD PTR [rsp+0x38],rdx
    4706:	mov    rsi,r14
    4709:	call   470e <botlish_fn_49+0x3ae>
			470a: R_X86_64_PLT32	botlish_fn_33-0x4 ; ht_get<HashTable, str>
    470e:	test   rax,rax
    4711:	je     4775 <botlish_fn_49+0x415>
    4717:	mov    QWORD PTR [rsp+0x10],rax
    471c:	lea    rdx,[rsp+0x40]
    4721:	mov    r9,r12
    4724:	mov    QWORD PTR [rsp+0x40],r9
    4729:	mov    rcx,QWORD PTR [rsp+0x88]
    4731:	mov    QWORD PTR [rsp+0x48],rcx
    4736:	mov    rcx,QWORD PTR [rsp+0x80]
    473e:	mov    QWORD PTR [rsp+0x50],rcx
    4743:	mov    rcx,r15
    4746:	mov    QWORD PTR [rsp+0x58],rcx
    474b:	mov    rcx,QWORD PTR [rsp+0x78]
    4750:	mov    QWORD PTR [rsp+0x60],rcx
    4755:	mov    QWORD PTR [rsp+0x68],rax
    475a:	mov    QWORD PTR [rsp+0x70],rbx
    475f:	mov    esi,0x7
    4764:	mov    rdi,r13
    4767:	call   476c <botlish_fn_49+0x40c>
			4768: R_X86_64_PLT32	rt_list_new-0x4
    476c:	test   rax,rax
    476f:	jne    47ac <botlish_fn_49+0x44c>
    4775:	xor    rax,rax
    4778:	mov    rbx,QWORD PTR [rsp+0x90]
    4780:	mov    r12,QWORD PTR [rsp+0x98]
    4788:	mov    r13,QWORD PTR [rsp+0xa0]
    4790:	mov    r14,QWORD PTR [rsp+0xa8]
    4798:	mov    r15,QWORD PTR [rsp+0xb0]
    47a0:	add    rsp,0xc0
    47a7:	mov    rsp,rbp
    47aa:	pop    rbp
    47ab:	ret
    47ac:	mov    rbx,QWORD PTR [rsp+0x90]
    47b4:	mov    r12,QWORD PTR [rsp+0x98]
    47bc:	mov    r13,QWORD PTR [rsp+0xa0]
    47c4:	mov    r14,QWORD PTR [rsp+0xa8]
    47cc:	mov    r15,QWORD PTR [rsp+0xb0]
    47d4:	add    rsp,0xc0
    47db:	mov    rsp,rbp
    47de:	pop    rbp
    47df:	ret
    47e0:	(bad)
    47e1:	add    BYTE PTR [rax],al
    47e3:	add    BYTE PTR [rax],al
    47e5:	add    BYTE PTR [rax],al
	...

00000000000047e8 <botlish_entry_49: sample_checks<generic>>:
    47e8:	push   rbp
    47e9:	mov    rbp,rsp
    47ec:	call   47f1 <botlish_entry_49+0x9>
			47ed: R_X86_64_PLT32	botlish_fn_49-0x4 ; sample_checks<generic>
    47f1:	mov    rsp,rbp
    47f4:	pop    rbp
    47f5:	ret

00000000000047f6 <botlish_fn_50: sample<generic>>:
    47f6:	push   rbp
    47f7:	mov    rbp,rsp
    47fa:	sub    rsp,0x10
    47fe:	mov    QWORD PTR [rsp],rbx
    4802:	mov    rbx,rdi
    4805:	mov    rdi,rbx
    4808:	call   480d <botlish_fn_50+0x17>
			4809: R_X86_64_PLT32	botlish_fn_49-0x4 ; sample_checks<generic>
    480d:	test   rax,rax
    4810:	jne    48c9 <botlish_fn_50+0xd3>
    4816:	mov    rdi,rbx
    4819:	call   481e <botlish_fn_50+0x28>
			481a: R_X86_64_PLT32	rt_declared_error-0x4
    481e:	cmp    rax,0x40000001
    4824:	je     489a <botlish_fn_50+0xa4>
    482a:	mov    rdi,rbx
    482d:	call   4832 <botlish_fn_50+0x3c>
			482e: R_X86_64_PLT32	rt_declared_error-0x4
    4832:	cmp    rax,0x40000002
    4838:	je     4876 <botlish_fn_50+0x80>
    483e:	mov    rdi,rbx
    4841:	call   4846 <botlish_fn_50+0x50>
			4842: R_X86_64_PLT32	rt_declared_error-0x4
    4846:	cmp    rax,0x40000003
    484c:	jne    48b9 <botlish_fn_50+0xc3>
    4852:	mov    rdi,rbx
    4855:	call   485a <botlish_fn_50+0x64>
			4856: R_X86_64_PLT32	rt_clear_declared_error-0x4
    485a:	xor    rdx,rdx
    485d:	mov    rdi,rbx
    4860:	mov    rsi,rdx
    4863:	call   4868 <botlish_fn_50+0x72>
			4864: R_X86_64_PLT32	rt_list_new-0x4
    4868:	test   rax,rax
    486b:	je     48b9 <botlish_fn_50+0xc3>
    4871:	jmp    48c9 <botlish_fn_50+0xd3>
    4876:	mov    rdi,rbx
    4879:	call   487e <botlish_fn_50+0x88>
			487a: R_X86_64_PLT32	rt_clear_declared_error-0x4
    487e:	xor    rdx,rdx
    4881:	mov    rdi,rbx
    4884:	mov    rsi,rdx
    4887:	call   488c <botlish_fn_50+0x96>
			4888: R_X86_64_PLT32	rt_list_new-0x4
    488c:	test   rax,rax
    488f:	je     48b9 <botlish_fn_50+0xc3>
    4895:	jmp    48c9 <botlish_fn_50+0xd3>
    489a:	mov    rdi,rbx
    489d:	call   48a2 <botlish_fn_50+0xac>
			489e: R_X86_64_PLT32	rt_clear_declared_error-0x4
    48a2:	xor    rdx,rdx
    48a5:	mov    rdi,rbx
    48a8:	mov    rsi,rdx
    48ab:	call   48b0 <botlish_fn_50+0xba>
			48ac: R_X86_64_PLT32	rt_list_new-0x4
    48b0:	test   rax,rax
    48b3:	jne    48c9 <botlish_fn_50+0xd3>
    48b9:	xor    rax,rax
    48bc:	mov    rbx,QWORD PTR [rsp]
    48c0:	add    rsp,0x10
    48c4:	mov    rsp,rbp
    48c7:	pop    rbp
    48c8:	ret
    48c9:	mov    rbx,QWORD PTR [rsp]
    48cd:	add    rsp,0x10
    48d1:	mov    rsp,rbp
    48d4:	pop    rbp
    48d5:	ret

00000000000048d6 <botlish_entry_50: sample<generic>>:
    48d6:	push   rbp
    48d7:	mov    rbp,rsp
    48da:	call   48df <botlish_entry_50+0x9>
			48db: R_X86_64_PLT32	botlish_fn_50-0x4 ; sample<generic>
    48df:	mov    rsp,rbp
    48e2:	pop    rbp
    48e3:	ret
