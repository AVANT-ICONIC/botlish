; source:  examples/stdlib/csv_records.bot
; backend: Cranelift (specialize=1), native::object
; object:  ELF64 x86-64, unlinked (Botlish-generated code only; runtime
;          helpers are unresolved imports, so their bodies are not present)
; format:  objdump -dr --no-show-raw-insn -M intel
; total machine code bytes: 19726  (per function: 45 89 89 89 357 420 420 420 202 202 202 81 365 309 526 932 310 758 215 480 318 427 385 70 493 114 69 69 46 182 228 636 1040 341 388 407 616 654 809 673 928 700 107 433 259 629 515 78 78 1222 301)
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
     c44:	mov    r14,rdi
     c47:	mov    QWORD PTR [rsp+0x18],0x0
     c50:	mov    QWORD PTR [rsp],rsi
     c54:	mov    r13,rsi
     c57:	mov    QWORD PTR [rsp+0x8],rdx
     c5c:	mov    rbx,rdx
     c5f:	mov    QWORD PTR [rsp+0x10],rcx
     c64:	mov    r12,rcx
     c67:	mov    rdx,QWORD PTR [rsi+0x8]
     c6b:	mov    r13,rsi
     c6e:	shl    rdx,1
     c71:	or     rdx,0x1
     c75:	mov    rax,r12
     c78:	and    rax,rdx
     c7b:	test   rax,0x1
     c81:	jne    ca7 <botlish_fn_14+0x7f>
     c87:	mov    rsi,r12
     c8a:	mov    rdi,r14
     c8d:	call   c92 <botlish_fn_14+0x6a>
			c8e: R_X86_64_PLT32	rt_int_cmp-0x4
     c92:	mov    ecx,0x2
     c97:	test   rax,rax
     c9a:	cmovl  rcx,QWORD PTR [rip+0x17e]        # e20 <botlish_fn_14+0x1f8>
     ca2:	jmp    cba <botlish_fn_14+0x92>
     ca7:	mov    ecx,0x2
     cac:	mov    rsi,r12
     caf:	cmp    rsi,rdx
     cb2:	cmovl  rcx,QWORD PTR [rip+0x166]        # e20 <botlish_fn_14+0x1f8>
     cba:	cmp    rcx,0x6
     cbe:	je     cd2 <botlish_fn_14+0xaa>
     cc4:	mov    rdx,rbx
     cc7:	mov    rsi,r13
     cca:	mov    rdi,r14
     ccd:	jmp    d5d <botlish_fn_14+0x135>
     cd2:	mov    rdx,r12
     cd5:	mov    rsi,r13
     cd8:	mov    rdi,r14
     cdb:	call   ce0 <botlish_fn_14+0xb8>
			cdc: R_X86_64_PLT32	rt_str_char_at-0x4
     ce0:	test   rax,rax
     ce3:	je     d74 <botlish_fn_14+0x14c>
     ce9:	cmp    rax,0x164
     cef:	je     cff <botlish_fn_14+0xd7>
     cf5:	mov    ecx,0x6
     cfa:	jmp    d04 <botlish_fn_14+0xdc>
     cff:	mov    ecx,0x2
     d04:	cmp    rcx,0x6
     d08:	je     d18 <botlish_fn_14+0xf0>
     d0e:	mov    eax,0x2
     d13:	jmp    d4a <botlish_fn_14+0x122>
     d18:	cmp    rax,0x54
     d1c:	je     d2c <botlish_fn_14+0x104>
     d22:	mov    eax,0x6
     d27:	jmp    d31 <botlish_fn_14+0x109>
     d2c:	mov    eax,0x2
     d31:	cmp    rax,0x6
     d35:	je     d45 <botlish_fn_14+0x11d>
     d3b:	mov    eax,0x2
     d40:	jmp    d4a <botlish_fn_14+0x122>
     d45:	mov    eax,0x6
     d4a:	cmp    rax,0x6
     d4e:	je     db7 <botlish_fn_14+0x18f>
     d54:	mov    rdx,rbx
     d57:	mov    rsi,r13
     d5a:	mov    rdi,r14
     d5d:	mov    rsi,r13
     d60:	mov    rdi,r14
     d63:	mov    rcx,r12
     d66:	call   d6b <botlish_fn_14+0x143>
			d67: R_X86_64_PLT32	rt_substr-0x4
     d6b:	test   rax,rax
     d6e:	jne    d97 <botlish_fn_14+0x16f>
     d74:	xor    rdx,rdx
     d77:	mov    rax,rdx
     d7a:	mov    rbx,QWORD PTR [rsp+0x20]
     d7f:	mov    r12,QWORD PTR [rsp+0x28]
     d84:	mov    r13,QWORD PTR [rsp+0x30]
     d89:	mov    r14,QWORD PTR [rsp+0x38]
     d8e:	add    rsp,0x40
     d92:	mov    rsp,rbp
     d95:	pop    rbp
     d96:	ret
     d97:	mov    rdx,r12
     d9a:	mov    rbx,QWORD PTR [rsp+0x20]
     d9f:	mov    r12,QWORD PTR [rsp+0x28]
     da4:	mov    r13,QWORD PTR [rsp+0x30]
     da9:	mov    r14,QWORD PTR [rsp+0x38]
     dae:	add    rsp,0x40
     db2:	mov    rsp,rbp
     db5:	pop    rbp
     db6:	ret
     db7:	mov    QWORD PTR [rsp+0x18],0x3
     dc0:	mov    rdx,r12
     dc3:	test   rdx,0x1
     dca:	je     ded <botlish_fn_14+0x1c5>
     dd0:	mov    rdx,r12
     dd3:	mov    rax,rdx
     dd6:	add    rax,0x2
     dda:	seto   cl
     ddd:	test   cl,cl
     ddf:	jne    ded <botlish_fn_14+0x1c5>
     de5:	mov    rsi,r13
     de8:	jmp    e00 <botlish_fn_14+0x1d8>
     ded:	mov    edx,0x3
     df2:	mov    rsi,r12
     df5:	mov    rdi,r14
     df8:	call   dfd <botlish_fn_14+0x1d5>
			df9: R_X86_64_PLT32	rt_int_add-0x4
     dfd:	mov    rsi,r13
     e00:	mov    rsi,r13
     e03:	mov    QWORD PTR [rsp],rsi
     e07:	mov    rdx,rbx
     e0a:	mov    QWORD PTR [rsp+0x8],rdx
     e0f:	mov    QWORD PTR [rsp+0x10],rax
     e14:	mov    r12,rax
     e17:	jmp    c67 <botlish_fn_14+0x3f>
     e1c:	add    BYTE PTR [rax],al
     e1e:	add    BYTE PTR [rax],al
     e20:	(bad)
     e21:	add    BYTE PTR [rax],al
     e23:	add    BYTE PTR [rax],al
     e25:	add    BYTE PTR [rax],al
	...

0000000000000e28 <botlish_entry_14: scan_unquoted<str, int, int>>:
     e28:	push   rbp
     e29:	mov    rbp,rsp
     e2c:	ud2

0000000000000e2e <botlish_fn_15: scan_quoted<str, int, str>>:
     e2e:	push   rbp
     e2f:	mov    rbp,rsp
     e32:	sub    rsp,0xb0
     e39:	mov    QWORD PTR [rsp+0x80],rbx
     e41:	mov    QWORD PTR [rsp+0x88],r12
     e49:	mov    QWORD PTR [rsp+0x90],r13
     e51:	mov    QWORD PTR [rsp+0x98],r14
     e59:	mov    QWORD PTR [rsp+0xa0],r15
     e61:	mov    r15,rdi
     e64:	mov    QWORD PTR [rsp+0x18],0x0
     e6d:	mov    QWORD PTR [rsp+0x20],0x0
     e76:	mov    QWORD PTR [rsp],rsi
     e7a:	mov    QWORD PTR [rsp+0x8],rdx
     e7f:	mov    QWORD PTR [rsp+0x10],rcx
     e84:	mov    r13,rcx
     e87:	lea    r12,[rsp+0x58]
     e8c:	mov    rbx,rsi
     e8f:	mov    QWORD PTR [rsp+0x78],rdx
     e94:	mov    rdx,QWORD PTR [rsp+0x78]
     e99:	mov    rsi,rbx
     e9c:	mov    rdi,r15
     e9f:	call   ea4 <botlish_fn_15+0x76>
			ea0: R_X86_64_PLT32	botlish_fn_12-0x4 ; peek<str, int>
     ea4:	test   rax,rax
     ea7:	je     1143 <botlish_fn_15+0x315>
     ead:	mov    QWORD PTR [rsp+0x18],rax
     eb2:	mov    r14,rax
     eb5:	mov    rdx,QWORD PTR [rsp+0x78]
     eba:	mov    rsi,rbx
     ebd:	mov    rdi,r15
     ec0:	call   ec5 <botlish_fn_15+0x97>
			ec1: R_X86_64_PLT32	botlish_fn_13-0x4 ; quote_at?<str, int>
     ec5:	test   rax,rax
     ec8:	je     1143 <botlish_fn_15+0x315>
     ece:	cmp    rax,0x6
     ed2:	je     f8b <botlish_fn_15+0x15d>
     ed8:	mov    QWORD PTR [rsp+0x20],0x3
     ee1:	mov    rsi,QWORD PTR [rsp+0x78]
     ee6:	test   rsi,0x1
     eed:	je     f17 <botlish_fn_15+0xe9>
     ef3:	mov    rsi,QWORD PTR [rsp+0x78]
     ef8:	mov    rcx,rsi
     efb:	add    rcx,0x2
     eff:	seto   dl
     f02:	test   dl,dl
     f04:	jne    f17 <botlish_fn_15+0xe9>
     f0a:	mov    rsi,rcx
     f0d:	mov    QWORD PTR [rsp+0x78],rcx
     f12:	jmp    f31 <botlish_fn_15+0x103>
     f17:	mov    edx,0x3
     f1c:	mov    rsi,QWORD PTR [rsp+0x78]
     f21:	mov    rdi,r15
     f24:	call   f29 <botlish_fn_15+0xfb>
			f25: R_X86_64_PLT32	rt_int_add-0x4
     f29:	mov    rsi,rax
     f2c:	mov    QWORD PTR [rsp+0x78],rax
     f31:	mov    QWORD PTR [rsp+0x8],rsi
     f36:	mov    QWORD PTR [rsp+0x58],0x0
     f3f:	mov    QWORD PTR [rsp+0x60],r13
     f44:	mov    QWORD PTR [rsp+0x68],0x0
     f4d:	mov    QWORD PTR [rsp+0x70],r14
     f52:	mov    esi,0x2
     f57:	mov    edx,0x4
     f5c:	mov    rcx,r12
     f5f:	mov    rdi,r15
     f62:	call   f67 <botlish_fn_15+0x139>
			f63: R_X86_64_PLT32	rt_construct-0x4
     f67:	test   rax,rax
     f6a:	je     1143 <botlish_fn_15+0x315>
     f70:	mov    QWORD PTR [rsp],rbx
     f74:	mov    rsi,QWORD PTR [rsp+0x78]
     f79:	mov    QWORD PTR [rsp+0x8],rsi
     f7e:	mov    QWORD PTR [rsp+0x10],rax
     f83:	mov    r13,rax
     f86:	jmp    e94 <botlish_fn_15+0x66>
     f8b:	mov    QWORD PTR [rsp+0x20],0x3
     f94:	mov    rsi,QWORD PTR [rsp+0x78]
     f99:	test   rsi,0x1
     fa0:	je     fbd <botlish_fn_15+0x18f>
     fa6:	mov    rsi,QWORD PTR [rsp+0x78]
     fab:	mov    rdx,rsi
     fae:	add    rdx,0x2
     fb2:	seto   al
     fb5:	test   al,al
     fb7:	je     fd2 <botlish_fn_15+0x1a4>
     fbd:	mov    edx,0x3
     fc2:	mov    rsi,QWORD PTR [rsp+0x78]
     fc7:	mov    rdi,r15
     fca:	call   fcf <botlish_fn_15+0x1a1>
			fcb: R_X86_64_PLT32	rt_int_add-0x4
     fcf:	mov    rdx,rax
     fd2:	mov    rsi,rbx
     fd5:	mov    rdi,r15
     fd8:	call   fdd <botlish_fn_15+0x1af>
			fd9: R_X86_64_PLT32	botlish_fn_13-0x4 ; quote_at?<str, int>
     fdd:	test   rax,rax
     fe0:	je     1143 <botlish_fn_15+0x315>
     fe6:	cmp    rax,0x6
     fea:	je     10a9 <botlish_fn_15+0x27b>
     ff0:	xor    rsi,rsi
     ff3:	lea    rcx,[rsp+0x48]
     ff8:	mov    QWORD PTR [rsp+0x48],0x0
    1001:	mov    QWORD PTR [rsp+0x50],r13
    1006:	mov    edx,0x2
    100b:	mov    rdi,r15
    100e:	call   1013 <botlish_fn_15+0x1e5>
			100f: R_X86_64_PLT32	rt_construct-0x4
    1013:	test   rax,rax
    1016:	je     1143 <botlish_fn_15+0x315>
    101c:	mov    QWORD PTR [rsp],rax
    1020:	mov    r12,rax
    1023:	mov    QWORD PTR [rsp+0x10],0x3
    102c:	mov    rsi,QWORD PTR [rsp+0x78]
    1031:	test   rsi,0x1
    1038:	je     105d <botlish_fn_15+0x22f>
    103e:	mov    rsi,QWORD PTR [rsp+0x78]
    1043:	mov    rdx,rsi
    1046:	add    rdx,0x2
    104a:	seto   al
    104d:	test   al,al
    104f:	jne    105d <botlish_fn_15+0x22f>
    1055:	mov    rax,r12
    1058:	jmp    1075 <botlish_fn_15+0x247>
    105d:	mov    edx,0x3
    1062:	mov    rsi,QWORD PTR [rsp+0x78]
    1067:	mov    rdi,r15
    106a:	call   106f <botlish_fn_15+0x241>
			106b: R_X86_64_PLT32	rt_int_add-0x4
    106f:	mov    rdx,rax
    1072:	mov    rax,r12
    1075:	mov    rbx,QWORD PTR [rsp+0x80]
    107d:	mov    r12,QWORD PTR [rsp+0x88]
    1085:	mov    r13,QWORD PTR [rsp+0x90]
    108d:	mov    r14,QWORD PTR [rsp+0x98]
    1095:	mov    r15,QWORD PTR [rsp+0xa0]
    109d:	add    rsp,0xb0
    10a4:	mov    rsp,rbp
    10a7:	pop    rbp
    10a8:	ret
    10a9:	mov    QWORD PTR [rsp+0x20],0x5
    10b2:	mov    rsi,QWORD PTR [rsp+0x78]
    10b7:	test   rsi,0x1
    10be:	je     10e8 <botlish_fn_15+0x2ba>
    10c4:	mov    rsi,QWORD PTR [rsp+0x78]
    10c9:	mov    rcx,rsi
    10cc:	add    rcx,0x4
    10d0:	seto   al
    10d3:	test   al,al
    10d5:	jne    10e8 <botlish_fn_15+0x2ba>
    10db:	mov    rsi,rcx
    10de:	mov    QWORD PTR [rsp+0x78],rcx
    10e3:	jmp    1102 <botlish_fn_15+0x2d4>
    10e8:	mov    edx,0x5
    10ed:	mov    rsi,QWORD PTR [rsp+0x78]
    10f2:	mov    rdi,r15
    10f5:	call   10fa <botlish_fn_15+0x2cc>
			10f6: R_X86_64_PLT32	rt_int_add-0x4
    10fa:	mov    rsi,rax
    10fd:	mov    QWORD PTR [rsp+0x78],rax
    1102:	mov    QWORD PTR [rsp+0x8],rsi
    1107:	lea    rcx,[rsp+0x28]
    110c:	mov    QWORD PTR [rsp+0x28],0x0
    1115:	mov    QWORD PTR [rsp+0x30],r13
    111a:	mov    QWORD PTR [rsp+0x38],0x0
    1123:	mov    QWORD PTR [rsp+0x40],r14
    1128:	mov    esi,0x2
    112d:	mov    edx,0x4
    1132:	mov    rdi,r15
    1135:	call   113a <botlish_fn_15+0x30c>
			1136: R_X86_64_PLT32	rt_construct-0x4
    113a:	test   rax,rax
    113d:	jne    117d <botlish_fn_15+0x34f>
    1143:	xor    rdx,rdx
    1146:	mov    rax,rdx
    1149:	mov    rbx,QWORD PTR [rsp+0x80]
    1151:	mov    r12,QWORD PTR [rsp+0x88]
    1159:	mov    r13,QWORD PTR [rsp+0x90]
    1161:	mov    r14,QWORD PTR [rsp+0x98]
    1169:	mov    r15,QWORD PTR [rsp+0xa0]
    1171:	add    rsp,0xb0
    1178:	mov    rsp,rbp
    117b:	pop    rbp
    117c:	ret
    117d:	mov    QWORD PTR [rsp],rbx
    1181:	mov    rsi,QWORD PTR [rsp+0x78]
    1186:	mov    QWORD PTR [rsp+0x8],rsi
    118b:	mov    QWORD PTR [rsp+0x10],rax
    1190:	mov    r13,rax
    1193:	jmp    e94 <botlish_fn_15+0x66>

0000000000001198 <botlish_entry_15: scan_quoted<str, int, str>>:
    1198:	push   rbp
    1199:	mov    rbp,rsp
    119c:	ud2

000000000000119e <botlish_fn_16: scan_field<str, int>>:
    119e:	push   rbp
    119f:	mov    rbp,rsp
    11a2:	sub    rsp,0x40
    11a6:	mov    QWORD PTR [rsp+0x20],rbx
    11ab:	mov    QWORD PTR [rsp+0x28],r12
    11b0:	mov    QWORD PTR [rsp+0x30],r13
    11b5:	mov    r12,rdi
    11b8:	mov    r13,rdx
    11bb:	mov    QWORD PTR [rsp+0x10],0x0
    11c4:	mov    QWORD PTR [rsp],rsi
    11c8:	mov    rbx,rsi
    11cb:	mov    QWORD PTR [rsp+0x8],rdx
    11d0:	mov    rdx,r13
    11d3:	mov    rsi,rbx
    11d6:	mov    rdi,r12
    11d9:	call   11de <botlish_fn_16+0x40>
			11da: R_X86_64_PLT32	botlish_fn_13-0x4 ; quote_at?<str, int>
    11de:	test   rax,rax
    11e1:	je     1291 <botlish_fn_16+0xf3>
    11e7:	cmp    rax,0x6
    11eb:	je     1223 <botlish_fn_16+0x85>
    11f1:	mov    rcx,r13
    11f4:	mov    rsi,rbx
    11f7:	mov    rdi,r12
    11fa:	mov    rdx,rcx
    11fd:	call   1202 <botlish_fn_16+0x64>
			11fe: R_X86_64_PLT32	botlish_fn_14-0x4 ; scan_unquoted<str, int, int>
    1202:	test   rax,rax
    1205:	je     1291 <botlish_fn_16+0xf3>
    120b:	mov    rbx,QWORD PTR [rsp+0x20]
    1210:	mov    r12,QWORD PTR [rsp+0x28]
    1215:	mov    r13,QWORD PTR [rsp+0x30]
    121a:	add    rsp,0x40
    121e:	mov    rsp,rbp
    1221:	pop    rbp
    1222:	ret
    1223:	mov    rcx,r13
    1226:	mov    QWORD PTR [rsp+0x10],0x3
    122f:	test   rcx,0x1
    1236:	jne    1244 <botlish_fn_16+0xa6>
    123c:	mov    r13,rcx
    123f:	jmp    1259 <botlish_fn_16+0xbb>
    1244:	mov    rdx,rcx
    1247:	add    rdx,0x2
    124b:	mov    r13,rcx
    124e:	seto   al
    1251:	test   al,al
    1253:	je     126c <botlish_fn_16+0xce>
    1259:	mov    edx,0x3
    125e:	mov    rsi,r13
    1261:	mov    rdi,r12
    1264:	call   1269 <botlish_fn_16+0xcb>
			1265: R_X86_64_PLT32	rt_int_add-0x4
    1269:	mov    rdx,rax
    126c:	mov    QWORD PTR [rsp+0x8],rdx
    1271:	mov    rdi,r12
    1274:	mov    rax,QWORD PTR [rdi+0x10]
    1278:	mov    rcx,QWORD PTR [rax]
    127b:	mov    QWORD PTR [rsp+0x10],rcx
    1280:	mov    rsi,rbx
    1283:	call   1288 <botlish_fn_16+0xea>
			1284: R_X86_64_PLT32	botlish_fn_15-0x4 ; scan_quoted<str, int, str>
    1288:	test   rax,rax
    128b:	jne    12af <botlish_fn_16+0x111>
    1291:	xor    rdx,rdx
    1294:	mov    rax,rdx
    1297:	mov    rbx,QWORD PTR [rsp+0x20]
    129c:	mov    r12,QWORD PTR [rsp+0x28]
    12a1:	mov    r13,QWORD PTR [rsp+0x30]
    12a6:	add    rsp,0x40
    12aa:	mov    rsp,rbp
    12ad:	pop    rbp
    12ae:	ret
    12af:	mov    rbx,QWORD PTR [rsp+0x20]
    12b4:	mov    r12,QWORD PTR [rsp+0x28]
    12b9:	mov    r13,QWORD PTR [rsp+0x30]
    12be:	add    rsp,0x40
    12c2:	mov    rsp,rbp
    12c5:	pop    rbp
    12c6:	ret

00000000000012c7 <botlish_entry_16: scan_field<str, int>>:
    12c7:	push   rbp
    12c8:	mov    rbp,rsp
    12cb:	ud2
    12cd:	add    BYTE PTR [rax],al
	...

00000000000012d0 <botlish_fn_17: scan_record_rest<str, int, mutarray, int>>:
    12d0:	push   rbp
    12d1:	mov    rbp,rsp
    12d4:	sub    rsp,0x60
    12d8:	mov    QWORD PTR [rsp+0x30],rbx
    12dd:	mov    QWORD PTR [rsp+0x38],r12
    12e2:	mov    QWORD PTR [rsp+0x40],r13
    12e7:	mov    QWORD PTR [rsp+0x48],r14
    12ec:	mov    QWORD PTR [rsp+0x50],r15
    12f1:	mov    r13,rdi
    12f4:	mov    QWORD PTR [rsp+0x20],0x0
    12fd:	mov    QWORD PTR [rsp],rsi
    1301:	mov    QWORD PTR [rsp+0x8],rdx
    1306:	mov    QWORD PTR [rsp+0x10],rcx
    130b:	mov    QWORD PTR [rsp+0x18],r8
    1310:	mov    rbx,rsi
    1313:	mov    r12,rdx
    1316:	mov    r14,r8
    1319:	mov    r15,rcx
    131c:	mov    rdx,QWORD PTR [rbx+0x8]
    1320:	shl    rdx,1
    1323:	or     rdx,0x1
    1327:	mov    rax,r12
    132a:	and    rax,rdx
    132d:	test   rax,0x1
    1333:	jne    1359 <botlish_fn_17+0x89>
    1339:	mov    rsi,r12
    133c:	mov    rdi,r13
    133f:	call   1344 <botlish_fn_17+0x74>
			1340: R_X86_64_PLT32	rt_int_cmp-0x4
    1344:	mov    ecx,0x2
    1349:	test   rax,rax
    134c:	cmovl  rcx,QWORD PTR [rip+0x24c]        # 15a0 <botlish_fn_17+0x2d0>
    1354:	jmp    136c <botlish_fn_17+0x9c>
    1359:	mov    ecx,0x2
    135e:	mov    rax,r12
    1361:	cmp    rax,rdx
    1364:	cmovl  rcx,QWORD PTR [rip+0x234]        # 15a0 <botlish_fn_17+0x2d0>
    136c:	cmp    rcx,0x6
    1370:	je     1384 <botlish_fn_17+0xb4>
    1376:	mov    rdx,r14
    1379:	mov    rsi,r15
    137c:	mov    rdi,r13
    137f:	jmp    13ba <botlish_fn_17+0xea>
    1384:	mov    rdx,r12
    1387:	mov    rsi,rbx
    138a:	mov    rdi,r13
    138d:	call   1392 <botlish_fn_17+0xc2>
			138e: R_X86_64_PLT32	rt_str_char_at-0x4
    1392:	test   rax,rax
    1395:	je     14fa <botlish_fn_17+0x22a>
    139b:	cmp    rax,0x164
    13a1:	je     1479 <botlish_fn_17+0x1a9>
    13a7:	cmp    rax,0x54
    13ab:	je     13f0 <botlish_fn_17+0x120>
    13b1:	mov    rdx,r14
    13b4:	mov    rsi,r15
    13b7:	mov    rdi,r13
    13ba:	mov    rdi,r13
    13bd:	call   13c2 <botlish_fn_17+0xf2>
			13be: R_X86_64_PLT32	botlish_fn_11-0x4 ; geo_finish<mutarray, int>
    13c2:	test   rax,rax
    13c5:	je     14fa <botlish_fn_17+0x22a>
    13cb:	mov    rdx,r12
    13ce:	mov    rbx,QWORD PTR [rsp+0x30]
    13d3:	mov    r12,QWORD PTR [rsp+0x38]
    13d8:	mov    r13,QWORD PTR [rsp+0x40]
    13dd:	mov    r14,QWORD PTR [rsp+0x48]
    13e2:	mov    r15,QWORD PTR [rsp+0x50]
    13e7:	add    rsp,0x60
    13eb:	mov    rsp,rbp
    13ee:	pop    rbp
    13ef:	ret
    13f0:	mov    rdx,r14
    13f3:	mov    rsi,r15
    13f6:	mov    rdi,r13
    13f9:	call   13fe <botlish_fn_17+0x12e>
			13fa: R_X86_64_PLT32	botlish_fn_11-0x4 ; geo_finish<mutarray, int>
    13fe:	test   rax,rax
    1401:	je     14fa <botlish_fn_17+0x22a>
    1407:	mov    QWORD PTR [rsp],rax
    140b:	mov    r14,rax
    140e:	mov    QWORD PTR [rsp+0x10],0x3
    1417:	mov    rdx,r12
    141a:	test   rdx,0x1
    1421:	je     1441 <botlish_fn_17+0x171>
    1427:	mov    rdx,r12
    142a:	add    rdx,0x2
    142e:	seto   al
    1431:	test   al,al
    1433:	jne    1441 <botlish_fn_17+0x171>
    1439:	mov    rax,r14
    143c:	jmp    1457 <botlish_fn_17+0x187>
    1441:	mov    edx,0x3
    1446:	mov    rsi,r12
    1449:	mov    rdi,r13
    144c:	call   1451 <botlish_fn_17+0x181>
			144d: R_X86_64_PLT32	rt_int_add-0x4
    1451:	mov    rdx,rax
    1454:	mov    rax,r14
    1457:	mov    rbx,QWORD PTR [rsp+0x30]
    145c:	mov    r12,QWORD PTR [rsp+0x38]
    1461:	mov    r13,QWORD PTR [rsp+0x40]
    1466:	mov    r14,QWORD PTR [rsp+0x48]
    146b:	mov    r15,QWORD PTR [rsp+0x50]
    1470:	add    rsp,0x60
    1474:	mov    rsp,rbp
    1477:	pop    rbp
    1478:	ret
    1479:	mov    rsi,r12
    147c:	mov    edx,0x3
    1481:	mov    r12,rdx
    1484:	mov    QWORD PTR [rsp+0x20],0x3
    148d:	test   rsi,0x1
    1494:	je     14ac <botlish_fn_17+0x1dc>
    149a:	mov    rdx,rsi
    149d:	add    rdx,0x2
    14a1:	seto   al
    14a4:	test   al,al
    14a6:	je     14ba <botlish_fn_17+0x1ea>
    14ac:	mov    rdx,r12
    14af:	mov    rdi,r13
    14b2:	call   14b7 <botlish_fn_17+0x1e7>
			14b3: R_X86_64_PLT32	rt_int_add-0x4
    14b7:	mov    rdx,rax
    14ba:	mov    QWORD PTR [rsp+0x8],rdx
    14bf:	mov    rsi,rbx
    14c2:	mov    rdi,r13
    14c5:	call   14ca <botlish_fn_17+0x1fa>
			14c6: R_X86_64_PLT32	botlish_fn_16-0x4 ; scan_field<str, int>
    14ca:	test   rax,rax
    14cd:	je     14fa <botlish_fn_17+0x22a>
    14d3:	mov    QWORD PTR [rsp+0x8],rax
    14d8:	mov    rcx,rax
    14db:	mov    QWORD PTR [rsp+0x20],rdx
    14e0:	mov    rsi,r15
    14e3:	mov    r15,rdx
    14e6:	mov    rdx,r14
    14e9:	mov    rdi,r13
    14ec:	call   14f1 <botlish_fn_17+0x221>
			14ed: R_X86_64_PLT32	botlish_fn_8-0x4 ; geo_append<mutarray, int, str>
    14f1:	test   rax,rax
    14f4:	jne    1522 <botlish_fn_17+0x252>
    14fa:	xor    rdx,rdx
    14fd:	mov    rax,rdx
    1500:	mov    rbx,QWORD PTR [rsp+0x30]
    1505:	mov    r12,QWORD PTR [rsp+0x38]
    150a:	mov    r13,QWORD PTR [rsp+0x40]
    150f:	mov    r14,QWORD PTR [rsp+0x48]
    1514:	mov    r15,QWORD PTR [rsp+0x50]
    1519:	add    rsp,0x60
    151d:	mov    rsp,rbp
    1520:	pop    rbp
    1521:	ret
    1522:	mov    QWORD PTR [rsp+0x8],rax
    1527:	mov    QWORD PTR [rsp+0x28],rax
    152c:	mov    QWORD PTR [rsp+0x10],0x3
    1535:	mov    rdx,r14
    1538:	test   rdx,0x1
    153f:	jne    1550 <botlish_fn_17+0x280>
    1545:	mov    rdx,r12
    1548:	mov    rsi,r14
    154b:	jmp    156b <botlish_fn_17+0x29b>
    1550:	mov    rdx,r14
    1553:	mov    rax,rdx
    1556:	add    rax,0x2
    155a:	seto   cl
    155d:	test   cl,cl
    155f:	je     1573 <botlish_fn_17+0x2a3>
    1565:	mov    rdx,r12
    1568:	mov    rsi,r14
    156b:	mov    rdi,r13
    156e:	call   1573 <botlish_fn_17+0x2a3>
			156f: R_X86_64_PLT32	rt_int_add-0x4
    1573:	mov    QWORD PTR [rsp],rbx
    1577:	mov    rdx,r15
    157a:	mov    QWORD PTR [rsp+0x8],rdx
    157f:	mov    rcx,QWORD PTR [rsp+0x28]
    1584:	mov    QWORD PTR [rsp+0x10],rcx
    1589:	mov    QWORD PTR [rsp+0x18],rax
    158e:	mov    r12,rdx
    1591:	mov    r14,rax
    1594:	mov    r15,rcx
    1597:	jmp    131c <botlish_fn_17+0x4c>
    159c:	add    BYTE PTR [rax],al
    159e:	add    BYTE PTR [rax],al
    15a0:	(bad)
    15a1:	add    BYTE PTR [rax],al
    15a3:	add    BYTE PTR [rax],al
    15a5:	add    BYTE PTR [rax],al
	...

00000000000015a8 <botlish_entry_17: scan_record_rest<str, int, mutarray, int>>:
    15a8:	push   rbp
    15a9:	mov    rbp,rsp
    15ac:	ud2

00000000000015ae <botlish_fn_18: scan_record<str, int>>:
    15ae:	push   rbp
    15af:	mov    rbp,rsp
    15b2:	sub    rsp,0x40
    15b6:	mov    QWORD PTR [rsp+0x20],rbx
    15bb:	mov    QWORD PTR [rsp+0x28],r12
    15c0:	mov    QWORD PTR [rsp+0x30],r14
    15c5:	mov    r14,rdi
    15c8:	mov    QWORD PTR [rsp+0x10],0x0
    15d1:	mov    QWORD PTR [rsp+0x18],0x0
    15da:	mov    QWORD PTR [rsp],rsi
    15de:	mov    r12,rsi
    15e1:	mov    QWORD PTR [rsp+0x8],rdx
    15e6:	mov    rsi,r12
    15e9:	mov    rdi,r14
    15ec:	call   15f1 <botlish_fn_18+0x43>
			15ed: R_X86_64_PLT32	botlish_fn_16-0x4 ; scan_field<str, int>
    15f1:	test   rax,rax
    15f4:	je     1649 <botlish_fn_18+0x9b>
    15fa:	mov    QWORD PTR [rsp+0x8],rax
    15ff:	mov    rsi,rax
    1602:	mov    QWORD PTR [rsp+0x10],rdx
    1607:	mov    rbx,rdx
    160a:	mov    rdi,r14
    160d:	call   1612 <botlish_fn_18+0x64>
			160e: R_X86_64_PLT32	botlish_fn_1-0x4 ; geo_new<str>
    1612:	test   rax,rax
    1615:	je     1649 <botlish_fn_18+0x9b>
    161b:	mov    QWORD PTR [rsp+0x8],rax
    1620:	mov    rcx,rax
    1623:	mov    r8d,0x3
    1629:	mov    QWORD PTR [rsp+0x18],0x3
    1632:	mov    rdx,rbx
    1635:	mov    rsi,r12
    1638:	mov    rdi,r14
    163b:	call   1640 <botlish_fn_18+0x92>
			163c: R_X86_64_PLT32	botlish_fn_17-0x4 ; scan_record_rest<str, int, mutarray, int>
    1640:	test   rax,rax
    1643:	jne    1667 <botlish_fn_18+0xb9>
    1649:	xor    rdx,rdx
    164c:	mov    rax,rdx
    164f:	mov    rbx,QWORD PTR [rsp+0x20]
    1654:	mov    r12,QWORD PTR [rsp+0x28]
    1659:	mov    r14,QWORD PTR [rsp+0x30]
    165e:	add    rsp,0x40
    1662:	mov    rsp,rbp
    1665:	pop    rbp
    1666:	ret
    1667:	mov    rbx,QWORD PTR [rsp+0x20]
    166c:	mov    r12,QWORD PTR [rsp+0x28]
    1671:	mov    r14,QWORD PTR [rsp+0x30]
    1676:	add    rsp,0x40
    167a:	mov    rsp,rbp
    167d:	pop    rbp
    167e:	ret

000000000000167f <botlish_entry_18: scan_record<str, int>>:
    167f:	push   rbp
    1680:	mov    rbp,rsp
    1683:	ud2
    1685:	add    BYTE PTR [rax],al
	...

0000000000001688 <botlish_fn_19: scan_records<str, int, mutarray, int>>:
    1688:	push   rbp
    1689:	mov    rbp,rsp
    168c:	sub    rsp,0x60
    1690:	mov    QWORD PTR [rsp+0x30],rbx
    1695:	mov    QWORD PTR [rsp+0x38],r12
    169a:	mov    QWORD PTR [rsp+0x40],r13
    169f:	mov    QWORD PTR [rsp+0x48],r14
    16a4:	mov    QWORD PTR [rsp+0x50],r15
    16a9:	mov    r13,rdi
    16ac:	mov    QWORD PTR [rsp+0x20],0x0
    16b5:	mov    QWORD PTR [rsp],rsi
    16b9:	mov    QWORD PTR [rsp+0x8],rdx
    16be:	mov    rax,rdx
    16c1:	mov    QWORD PTR [rsp+0x10],rcx
    16c6:	mov    QWORD PTR [rsp+0x18],r8
    16cb:	mov    rbx,rsi
    16ce:	mov    r14,r8
    16d1:	mov    r15,rcx
    16d4:	mov    rdx,QWORD PTR [rbx+0x8]
    16d8:	shl    rdx,1
    16db:	or     rdx,0x1
    16df:	mov    r12,rax
    16e2:	and    rax,rdx
    16e5:	test   rax,0x1
    16eb:	jne    1711 <botlish_fn_19+0x89>
    16f1:	mov    rsi,r12
    16f4:	mov    rdi,r13
    16f7:	call   16fc <botlish_fn_19+0x74>
			16f8: R_X86_64_PLT32	rt_int_cmp-0x4
    16fc:	mov    ecx,0x2
    1701:	test   rax,rax
    1704:	cmovge rcx,QWORD PTR [rip+0x12c]        # 1838 <botlish_fn_19+0x1b0>
    170c:	jmp    1721 <botlish_fn_19+0x99>
    1711:	mov    ecx,0x2
    1716:	cmp    r12,rdx
    1719:	cmovge rcx,QWORD PTR [rip+0x117]        # 1838 <botlish_fn_19+0x1b0>
    1721:	cmp    rcx,0x6
    1725:	je     17d3 <botlish_fn_19+0x14b>
    172b:	mov    rdx,r12
    172e:	mov    rsi,rbx
    1731:	mov    rdi,r13
    1734:	call   1739 <botlish_fn_19+0xb1>
			1735: R_X86_64_PLT32	botlish_fn_18-0x4 ; scan_record<str, int>
    1739:	test   rax,rax
    173c:	je     17ea <botlish_fn_19+0x162>
    1742:	mov    QWORD PTR [rsp+0x8],rax
    1747:	mov    rcx,rax
    174a:	mov    QWORD PTR [rsp+0x20],rdx
    174f:	mov    rsi,r15
    1752:	mov    r12,rdx
    1755:	mov    rdx,r14
    1758:	mov    rdi,r13
    175b:	call   1760 <botlish_fn_19+0xd8>
			175c: R_X86_64_PLT32	botlish_fn_9-0x4 ; geo_append<mutarray, int, List[str]>
    1760:	test   rax,rax
    1763:	je     17ea <botlish_fn_19+0x162>
    1769:	mov    QWORD PTR [rsp+0x8],rax
    176e:	mov    r15,rax
    1771:	mov    QWORD PTR [rsp+0x10],0x3
    177a:	mov    rsi,r14
    177d:	test   rsi,0x1
    1784:	je     179f <botlish_fn_19+0x117>
    178a:	mov    rsi,r14
    178d:	mov    rax,rsi
    1790:	add    rax,0x2
    1794:	seto   cl
    1797:	test   cl,cl
    1799:	je     17af <botlish_fn_19+0x127>
    179f:	mov    edx,0x3
    17a4:	mov    rsi,r14
    17a7:	mov    rdi,r13
    17aa:	call   17af <botlish_fn_19+0x127>
			17ab: R_X86_64_PLT32	rt_int_add-0x4
    17af:	mov    QWORD PTR [rsp],rbx
    17b3:	mov    rdx,r12
    17b6:	mov    QWORD PTR [rsp+0x8],rdx
    17bb:	mov    rcx,r15
    17be:	mov    QWORD PTR [rsp+0x10],rcx
    17c3:	mov    QWORD PTR [rsp+0x18],rax
    17c8:	mov    r14,rax
    17cb:	mov    rax,rdx
    17ce:	jmp    16d4 <botlish_fn_19+0x4c>
    17d3:	mov    rdx,r14
    17d6:	mov    rsi,r15
    17d9:	mov    rdi,r13
    17dc:	call   17e1 <botlish_fn_19+0x159>
			17dd: R_X86_64_PLT32	botlish_fn_11-0x4 ; geo_finish<mutarray, int>
    17e1:	test   rax,rax
    17e4:	jne    180f <botlish_fn_19+0x187>
    17ea:	xor    rax,rax
    17ed:	mov    rbx,QWORD PTR [rsp+0x30]
    17f2:	mov    r12,QWORD PTR [rsp+0x38]
    17f7:	mov    r13,QWORD PTR [rsp+0x40]
    17fc:	mov    r14,QWORD PTR [rsp+0x48]
    1801:	mov    r15,QWORD PTR [rsp+0x50]
    1806:	add    rsp,0x60
    180a:	mov    rsp,rbp
    180d:	pop    rbp
    180e:	ret
    180f:	mov    rbx,QWORD PTR [rsp+0x30]
    1814:	mov    r12,QWORD PTR [rsp+0x38]
    1819:	mov    r13,QWORD PTR [rsp+0x40]
    181e:	mov    r14,QWORD PTR [rsp+0x48]
    1823:	mov    r15,QWORD PTR [rsp+0x50]
    1828:	add    rsp,0x60
    182c:	mov    rsp,rbp
    182f:	pop    rbp
    1830:	ret
    1831:	add    BYTE PTR [rax],al
    1833:	add    BYTE PTR [rax],al
    1835:	add    BYTE PTR [rax],al
    1837:	add    BYTE PTR [rsi],al
    1839:	add    BYTE PTR [rax],al
    183b:	add    BYTE PTR [rax],al
    183d:	add    BYTE PTR [rax],al
	...

0000000000001840 <botlish_entry_19: scan_records<str, int, mutarray, int>>:
    1840:	push   rbp
    1841:	mov    rbp,rsp
    1844:	mov    rsi,QWORD PTR [rdx]
    1847:	mov    r9,QWORD PTR [rdx+0x8]
    184b:	mov    rcx,QWORD PTR [rdx+0x10]
    184f:	mov    r8,QWORD PTR [rdx+0x18]
    1853:	mov    rdx,r9
    1856:	call   185b <botlish_entry_19+0x1b>
			1857: R_X86_64_PLT32	botlish_fn_19-0x4 ; scan_records<str, int, mutarray, int>
    185b:	mov    rsp,rbp
    185e:	pop    rbp
    185f:	ret

0000000000001860 <botlish_fn_20: csv_parse<str>>:
    1860:	push   rbp
    1861:	mov    rbp,rsp
    1864:	sub    rsp,0x40
    1868:	mov    QWORD PTR [rsp+0x20],rbx
    186d:	mov    QWORD PTR [rsp+0x28],r12
    1872:	mov    QWORD PTR [rsp+0x30],r13
    1877:	mov    rbx,rdi
    187a:	mov    QWORD PTR [rsp+0x8],0x0
    1883:	mov    QWORD PTR [rsp+0x10],0x0
    188c:	mov    QWORD PTR [rsp+0x18],0x0
    1895:	mov    QWORD PTR [rsp],rsi
    1899:	mov    rax,QWORD PTR [rsi+0x8]
    189d:	mov    r12,rsi
    18a0:	shl    rax,1
    18a3:	or     rax,0x1
    18a7:	sar    rax,1
    18aa:	test   rax,rax
    18ad:	je     193c <botlish_fn_20+0xdc>
    18b3:	mov    edx,0x1
    18b8:	mov    QWORD PTR [rsp+0x8],0x1
    18c1:	mov    rsi,r12
    18c4:	mov    rdi,rbx
    18c7:	call   18cc <botlish_fn_20+0x6c>
			18c8: R_X86_64_PLT32	botlish_fn_18-0x4 ; scan_record<str, int>
    18cc:	test   rax,rax
    18cf:	je     1953 <botlish_fn_20+0xf3>
    18d5:	mov    QWORD PTR [rsp+0x8],rax
    18da:	mov    rsi,rax
    18dd:	mov    QWORD PTR [rsp+0x10],rdx
    18e2:	mov    r13,rdx
    18e5:	mov    rdi,rbx
    18e8:	call   18ed <botlish_fn_20+0x8d>
			18e9: R_X86_64_PLT32	botlish_fn_2-0x4 ; geo_new<List[str]>
    18ed:	test   rax,rax
    18f0:	je     1953 <botlish_fn_20+0xf3>
    18f6:	mov    QWORD PTR [rsp+0x8],rax
    18fb:	mov    rcx,rax
    18fe:	mov    r8d,0x3
    1904:	mov    QWORD PTR [rsp+0x18],0x3
    190d:	mov    rdx,r13
    1910:	mov    rsi,r12
    1913:	mov    rdi,rbx
    1916:	call   191b <botlish_fn_20+0xbb>
			1917: R_X86_64_PLT32	botlish_fn_19-0x4 ; scan_records<str, int, mutarray, int>
    191b:	test   rax,rax
    191e:	je     1953 <botlish_fn_20+0xf3>
    1924:	mov    rbx,QWORD PTR [rsp+0x20]
    1929:	mov    r12,QWORD PTR [rsp+0x28]
    192e:	mov    r13,QWORD PTR [rsp+0x30]
    1933:	add    rsp,0x40
    1937:	mov    rsp,rbp
    193a:	pop    rbp
    193b:	ret
    193c:	xor    rdx,rdx
    193f:	mov    rdi,rbx
    1942:	mov    rsi,rdx
    1945:	call   194a <botlish_fn_20+0xea>
			1946: R_X86_64_PLT32	rt_list_new-0x4
    194a:	test   rax,rax
    194d:	jne    196e <botlish_fn_20+0x10e>
    1953:	xor    rax,rax
    1956:	mov    rbx,QWORD PTR [rsp+0x20]
    195b:	mov    r12,QWORD PTR [rsp+0x28]
    1960:	mov    r13,QWORD PTR [rsp+0x30]
    1965:	add    rsp,0x40
    1969:	mov    rsp,rbp
    196c:	pop    rbp
    196d:	ret
    196e:	mov    rbx,QWORD PTR [rsp+0x20]
    1973:	mov    r12,QWORD PTR [rsp+0x28]
    1978:	mov    r13,QWORD PTR [rsp+0x30]
    197d:	add    rsp,0x40
    1981:	mov    rsp,rbp
    1984:	pop    rbp
    1985:	ret

0000000000001986 <botlish_entry_20: csv_parse<str>>:
    1986:	push   rbp
    1987:	mov    rbp,rsp
    198a:	mov    rsi,QWORD PTR [rdx]
    198d:	call   1992 <botlish_entry_20+0xc>
			198e: R_X86_64_PLT32	botlish_fn_20-0x4 ; csv_parse<str>
    1992:	mov    rsp,rbp
    1995:	pop    rbp
    1996:	ret

0000000000001997 <botlish_fn_21: ht_alloc<int>>:
    1997:	push   rbp
    1998:	mov    rbp,rsp
    199b:	sub    rsp,0x70
    199f:	mov    QWORD PTR [rsp+0x40],rbx
    19a4:	mov    QWORD PTR [rsp+0x48],r12
    19a9:	mov    QWORD PTR [rsp+0x50],r13
    19ae:	mov    QWORD PTR [rsp+0x58],r14
    19b3:	mov    QWORD PTR [rsp+0x60],r15
    19b8:	mov    r12,rdi
    19bb:	mov    QWORD PTR [rsp+0x10],0x0
    19c4:	mov    QWORD PTR [rsp+0x18],0x0
    19cd:	mov    QWORD PTR [rsp],rsi
    19d1:	mov    r13,rsi
    19d4:	mov    esi,0x5
    19d9:	mov    QWORD PTR [rsp+0x8],0x5
    19e2:	mov    rdi,r12
    19e5:	call   19ea <botlish_fn_21+0x53>
			19e6: R_X86_64_PLT32	rt_mutarray_allocate-0x4
    19ea:	mov    rcx,rax
    19ed:	mov    r14,rax
    19f0:	test   rax,rcx
    19f3:	je     1a82 <botlish_fn_21+0xeb>
    19f9:	mov    rax,r14
    19fc:	mov    QWORD PTR [rsp+0x8],rax
    1a01:	mov    ebx,0x1
    1a06:	mov    rcx,rbx
    1a09:	mov    rdx,rbx
    1a0c:	mov    rsi,r14
    1a0f:	mov    rdi,r12
    1a12:	call   1a17 <botlish_fn_21+0x80>
			1a13: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
    1a17:	mov    edx,0x3
    1a1c:	mov    rcx,rbx
    1a1f:	mov    rsi,r14
    1a22:	mov    rdi,r12
    1a25:	call   1a2a <botlish_fn_21+0x93>
			1a26: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
    1a2a:	mov    QWORD PTR [rsp+0x10],0x1
    1a33:	mov    rdx,rbx
    1a36:	mov    rsi,r13
    1a39:	mov    rdi,r12
    1a3c:	call   1a41 <botlish_fn_21+0xaa>
			1a3d: R_X86_64_PLT32	rt_mutarray_create-0x4
    1a41:	test   rax,rax
    1a44:	je     1a82 <botlish_fn_21+0xeb>
    1a4a:	mov    QWORD PTR [rsp+0x10],rax
    1a4f:	mov    rbx,rax
    1a52:	mov    rsi,r13
    1a55:	mov    rdi,r12
    1a58:	call   1a5d <botlish_fn_21+0xc6>
			1a59: R_X86_64_PLT32	rt_mutarray_allocate-0x4
    1a5d:	test   rax,rax
    1a60:	je     1a82 <botlish_fn_21+0xeb>
    1a66:	mov    QWORD PTR [rsp+0x18],rax
    1a6b:	mov    rsi,r13
    1a6e:	mov    r15,rax
    1a71:	mov    rdi,r12
    1a74:	call   1a79 <botlish_fn_21+0xe2>
			1a75: R_X86_64_PLT32	rt_mutarray_allocate-0x4
    1a79:	test   rax,rax
    1a7c:	jne    1aa7 <botlish_fn_21+0x110>
    1a82:	xor    rax,rax
    1a85:	mov    rbx,QWORD PTR [rsp+0x40]
    1a8a:	mov    r12,QWORD PTR [rsp+0x48]
    1a8f:	mov    r13,QWORD PTR [rsp+0x50]
    1a94:	mov    r14,QWORD PTR [rsp+0x58]
    1a99:	mov    r15,QWORD PTR [rsp+0x60]
    1a9e:	add    rsp,0x70
    1aa2:	mov    rsp,rbp
    1aa5:	pop    rbp
    1aa6:	ret
    1aa7:	mov    QWORD PTR [rsp],rax
    1aab:	lea    rcx,[rsp+0x20]
    1ab0:	mov    rdx,rbx
    1ab3:	mov    QWORD PTR [rsp+0x20],rdx
    1ab8:	mov    rsi,r15
    1abb:	mov    QWORD PTR [rsp+0x28],rsi
    1ac0:	mov    QWORD PTR [rsp+0x30],rax
    1ac5:	mov    rax,r14
    1ac8:	mov    QWORD PTR [rsp+0x38],rax
    1acd:	xor    rsi,rsi
    1ad0:	mov    edx,0x4
    1ad5:	mov    rdi,r12
    1ad8:	call   1add <botlish_fn_21+0x146>
			1ad9: R_X86_64_PLT32	rt_struct_new-0x4
    1add:	mov    rbx,QWORD PTR [rsp+0x40]
    1ae2:	mov    r12,QWORD PTR [rsp+0x48]
    1ae7:	mov    r13,QWORD PTR [rsp+0x50]
    1aec:	mov    r14,QWORD PTR [rsp+0x58]
    1af1:	mov    r15,QWORD PTR [rsp+0x60]
    1af6:	add    rsp,0x70
    1afa:	mov    rsp,rbp
    1afd:	pop    rbp
    1afe:	ret

0000000000001aff <botlish_entry_21: ht_alloc<int>>:
    1aff:	push   rbp
    1b00:	mov    rbp,rsp
    1b03:	mov    rsi,QWORD PTR [rdx]
    1b06:	call   1b0b <botlish_entry_21+0xc>
			1b07: R_X86_64_PLT32	botlish_fn_21-0x4 ; ht_alloc<int>
    1b0b:	mov    rsp,rbp
    1b0e:	pop    rbp
    1b0f:	ret

0000000000001b10 <botlish_fn_22: ht_alloc<int>>:
    1b10:	push   rbp
    1b11:	mov    rbp,rsp
    1b14:	sub    rsp,0x60
    1b18:	mov    QWORD PTR [rsp+0x30],rbx
    1b1d:	mov    QWORD PTR [rsp+0x38],r12
    1b22:	mov    QWORD PTR [rsp+0x40],r13
    1b27:	mov    QWORD PTR [rsp+0x48],r14
    1b2c:	mov    QWORD PTR [rsp+0x50],r15
    1b31:	mov    r13,rdi
    1b34:	mov    r15,rdx
    1b37:	mov    QWORD PTR [rsp+0x10],0x0
    1b40:	mov    QWORD PTR [rsp+0x18],0x0
    1b49:	mov    QWORD PTR [rsp],rsi
    1b4d:	mov    r12,rsi
    1b50:	mov    esi,0x5
    1b55:	mov    QWORD PTR [rsp+0x8],0x5
    1b5e:	mov    rdi,r13
    1b61:	call   1b66 <botlish_fn_22+0x56>
			1b62: R_X86_64_PLT32	rt_mutarray_allocate-0x4
    1b66:	mov    rcx,rax
    1b69:	mov    r14,rax
    1b6c:	test   rax,rcx
    1b6f:	je     1c00 <botlish_fn_22+0xf0>
    1b75:	mov    rax,r14
    1b78:	mov    QWORD PTR [rsp+0x8],rax
    1b7d:	mov    ebx,0x1
    1b82:	mov    rcx,rbx
    1b85:	mov    rdx,rbx
    1b88:	mov    rsi,r14
    1b8b:	mov    rdi,r13
    1b8e:	call   1b93 <botlish_fn_22+0x83>
			1b8f: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
    1b93:	mov    edx,0x3
    1b98:	mov    rcx,rbx
    1b9b:	mov    rsi,r14
    1b9e:	mov    rdi,r13
    1ba1:	call   1ba6 <botlish_fn_22+0x96>
			1ba2: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
    1ba6:	mov    QWORD PTR [rsp+0x10],0x1
    1baf:	mov    rdx,rbx
    1bb2:	mov    rsi,r12
    1bb5:	mov    rdi,r13
    1bb8:	call   1bbd <botlish_fn_22+0xad>
			1bb9: R_X86_64_PLT32	rt_mutarray_create-0x4
    1bbd:	test   rax,rax
    1bc0:	je     1c00 <botlish_fn_22+0xf0>
    1bc6:	mov    QWORD PTR [rsp+0x10],rax
    1bcb:	mov    rbx,rax
    1bce:	mov    rsi,r12
    1bd1:	mov    rdi,r13
    1bd4:	call   1bd9 <botlish_fn_22+0xc9>
			1bd5: R_X86_64_PLT32	rt_mutarray_allocate-0x4
    1bd9:	test   rax,rax
    1bdc:	je     1c00 <botlish_fn_22+0xf0>
    1be2:	mov    QWORD PTR [rsp+0x18],rax
    1be7:	mov    rsi,r12
    1bea:	mov    rdi,r13
    1bed:	mov    QWORD PTR [rsp+0x20],rax
    1bf2:	call   1bf7 <botlish_fn_22+0xe7>
			1bf3: R_X86_64_PLT32	rt_mutarray_allocate-0x4
    1bf7:	test   rax,rax
    1bfa:	jne    1c25 <botlish_fn_22+0x115>
    1c00:	xor    rax,rax
    1c03:	mov    rbx,QWORD PTR [rsp+0x30]
    1c08:	mov    r12,QWORD PTR [rsp+0x38]
    1c0d:	mov    r13,QWORD PTR [rsp+0x40]
    1c12:	mov    r14,QWORD PTR [rsp+0x48]
    1c17:	mov    r15,QWORD PTR [rsp+0x50]
    1c1c:	add    rsp,0x60
    1c20:	mov    rsp,rbp
    1c23:	pop    rbp
    1c24:	ret
    1c25:	mov    rcx,QWORD PTR [rsp+0x20]
    1c2a:	mov    rdx,r15
    1c2d:	mov    QWORD PTR [rdx],rcx
    1c30:	mov    QWORD PTR [rdx+0x8],rax
    1c34:	mov    rax,r14
    1c37:	mov    QWORD PTR [rdx+0x10],rax
    1c3b:	mov    rax,rbx
    1c3e:	mov    rbx,QWORD PTR [rsp+0x30]
    1c43:	mov    r12,QWORD PTR [rsp+0x38]
    1c48:	mov    r13,QWORD PTR [rsp+0x40]
    1c4d:	mov    r14,QWORD PTR [rsp+0x48]
    1c52:	mov    r15,QWORD PTR [rsp+0x50]
    1c57:	add    rsp,0x60
    1c5b:	mov    rsp,rbp
    1c5e:	pop    rbp
    1c5f:	ret

0000000000001c60 <botlish_entry_22: ht_alloc<int>>:
    1c60:	push   rbp
    1c61:	mov    rbp,rsp
    1c64:	ud2

0000000000001c66 <botlish_fn_23: ht_new<generic>>:
    1c66:	push   rbp
    1c67:	mov    rbp,rsp
    1c6a:	sub    rsp,0x10
    1c6e:	mov    esi,0x11
    1c73:	mov    QWORD PTR [rsp],0x11
    1c7b:	call   1c80 <botlish_fn_23+0x1a>
			1c7c: R_X86_64_PLT32	botlish_fn_21-0x4 ; ht_alloc<int>
    1c80:	test   rax,rax
    1c83:	jne    1c95 <botlish_fn_23+0x2f>
    1c89:	xor    rax,rax
    1c8c:	add    rsp,0x10
    1c90:	mov    rsp,rbp
    1c93:	pop    rbp
    1c94:	ret
    1c95:	add    rsp,0x10
    1c99:	mov    rsp,rbp
    1c9c:	pop    rbp
    1c9d:	ret

0000000000001c9e <botlish_entry_23: ht_new<generic>>:
    1c9e:	push   rbp
    1c9f:	mov    rbp,rsp
    1ca2:	call   1ca7 <botlish_entry_23+0x9>
			1ca3: R_X86_64_PLT32	botlish_fn_23-0x4 ; ht_new<generic>
    1ca7:	mov    rsp,rbp
    1caa:	pop    rbp
    1cab:	ret
    1cac:	add    BYTE PTR [rax],al
	...

0000000000001cb0 <botlish_fn_24: ht_capacity_for<int, int>>:
    1cb0:	push   rbp
    1cb1:	mov    rbp,rsp
    1cb4:	sub    rsp,0x50
    1cb8:	mov    QWORD PTR [rsp+0x20],rbx
    1cbd:	mov    QWORD PTR [rsp+0x28],r12
    1cc2:	mov    QWORD PTR [rsp+0x30],r13
    1cc7:	mov    QWORD PTR [rsp+0x38],r14
    1ccc:	mov    QWORD PTR [rsp+0x40],r15
    1cd1:	mov    r13,rdi
    1cd4:	mov    QWORD PTR [rsp],rdx
    1cd8:	mov    rbx,rsi
    1cdb:	or     rbx,0x1
    1cdf:	sar    rbx,1
    1ce2:	mov    r12,rsi
    1ce5:	mov    r14,rdx
    1ce8:	mov    rax,r12
    1ceb:	or     rax,0x1
    1cef:	mov    QWORD PTR [rsp+0x8],rax
    1cf4:	mov    QWORD PTR [rsp+0x10],0x7
    1cfd:	mov    rax,rbx
    1d00:	imul   QWORD PTR [rip+0x159]        # 1e60 <botlish_fn_24+0x1b0>
    1d07:	seto   cl
    1d0a:	or     rax,0x1
    1d0e:	test   cl,cl
    1d10:	jne    1d1e <botlish_fn_24+0x6e>
    1d16:	mov    rsi,rax
    1d19:	jmp    1d35 <botlish_fn_24+0x85>
    1d1e:	mov    rsi,r12
    1d21:	or     rsi,0x1
    1d25:	mov    edx,0x7
    1d2a:	mov    rdi,r13
    1d2d:	call   1d32 <botlish_fn_24+0x82>
			1d2e: R_X86_64_PLT32	rt_int_mul-0x4
    1d32:	mov    rsi,rax
    1d35:	mov    QWORD PTR [rsp+0x8],rsi
    1d3a:	mov    r15,rsi
    1d3d:	mov    QWORD PTR [rsp+0x10],0x5
    1d46:	mov    rsi,r14
    1d49:	test   rsi,0x1
    1d50:	je     1d80 <botlish_fn_24+0xd0>
    1d56:	mov    rsi,r14
    1d59:	mov    rax,rsi
    1d5c:	sar    rax,1
    1d5f:	imul   QWORD PTR [rip+0x102]        # 1e68 <botlish_fn_24+0x1b8>
    1d66:	seto   cl
    1d69:	or     rax,0x1
    1d6d:	test   cl,cl
    1d6f:	jne    1d80 <botlish_fn_24+0xd0>
    1d75:	mov    rdx,rax
    1d78:	mov    rsi,r15
    1d7b:	jmp    1d96 <botlish_fn_24+0xe6>
    1d80:	mov    edx,0x5
    1d85:	mov    rsi,r14
    1d88:	mov    rdi,r13
    1d8b:	call   1d90 <botlish_fn_24+0xe0>
			1d8c: R_X86_64_PLT32	rt_int_mul-0x4
    1d90:	mov    rdx,rax
    1d93:	mov    rsi,r15
    1d96:	mov    rax,rsi
    1d99:	and    rax,rdx
    1d9c:	test   rax,0x1
    1da2:	jne    1dc5 <botlish_fn_24+0x115>
    1da8:	mov    rdi,r13
    1dab:	call   1db0 <botlish_fn_24+0x100>
			1dac: R_X86_64_PLT32	rt_int_cmp-0x4
    1db0:	mov    ecx,0x2
    1db5:	test   rax,rax
    1db8:	cmovle rcx,QWORD PTR [rip+0xa0]        # 1e60 <botlish_fn_24+0x1b0>
    1dc0:	jmp    1dd5 <botlish_fn_24+0x125>
    1dc5:	mov    ecx,0x2
    1dca:	cmp    rsi,rdx
    1dcd:	cmovle rcx,QWORD PTR [rip+0x8b]        # 1e60 <botlish_fn_24+0x1b0>
    1dd5:	cmp    rcx,0x6
    1dd9:	je     1e35 <botlish_fn_24+0x185>
    1ddf:	mov    QWORD PTR [rsp+0x8],0x5
    1de8:	mov    rsi,r14
    1deb:	test   rsi,0x1
    1df2:	je     1e19 <botlish_fn_24+0x169>
    1df8:	mov    rsi,r14
    1dfb:	mov    rax,rsi
    1dfe:	sar    rax,1
    1e01:	imul   QWORD PTR [rip+0x60]        # 1e68 <botlish_fn_24+0x1b8>
    1e08:	seto   sil
    1e0c:	or     rax,0x1
    1e10:	test   sil,sil
    1e13:	je     1e29 <botlish_fn_24+0x179>
    1e19:	mov    edx,0x5
    1e1e:	mov    rsi,r14
    1e21:	mov    rdi,r13
    1e24:	call   1e29 <botlish_fn_24+0x179>
			1e25: R_X86_64_PLT32	rt_int_mul-0x4
    1e29:	mov    QWORD PTR [rsp],rax
    1e2d:	mov    r14,rax
    1e30:	jmp    1ce8 <botlish_fn_24+0x38>
    1e35:	mov    rax,r14
    1e38:	mov    rbx,QWORD PTR [rsp+0x20]
    1e3d:	mov    r12,QWORD PTR [rsp+0x28]
    1e42:	mov    r13,QWORD PTR [rsp+0x30]
    1e47:	mov    r14,QWORD PTR [rsp+0x38]
    1e4c:	mov    r15,QWORD PTR [rsp+0x40]
    1e51:	add    rsp,0x50
    1e55:	mov    rsp,rbp
    1e58:	pop    rbp
    1e59:	ret
    1e5a:	add    BYTE PTR [rax],al
    1e5c:	add    BYTE PTR [rax],al
    1e5e:	add    BYTE PTR [rax],al
    1e60:	(bad)
    1e61:	add    BYTE PTR [rax],al
    1e63:	add    BYTE PTR [rax],al
    1e65:	add    BYTE PTR [rax],al
    1e67:	add    BYTE PTR [rax+rax*1],al
    1e6a:	add    BYTE PTR [rax],al
    1e6c:	add    BYTE PTR [rax],al
	...

0000000000001e70 <botlish_entry_24: ht_capacity_for<int, int>>:
    1e70:	push   rbp
    1e71:	mov    rbp,rsp
    1e74:	mov    rsi,QWORD PTR [rdx]
    1e77:	mov    rdx,QWORD PTR [rdx+0x8]
    1e7b:	call   1e80 <botlish_entry_24+0x10>
			1e7c: R_X86_64_PLT32	botlish_fn_24-0x4 ; ht_capacity_for<int, int>
    1e80:	mov    rsp,rbp
    1e83:	pop    rbp
    1e84:	ret

0000000000001e85 <botlish_fn_25: ht_new_sized<int>>:
    1e85:	push   rbp
    1e86:	mov    rbp,rsp
    1e89:	sub    rsp,0x20
    1e8d:	mov    QWORD PTR [rsp+0x10],r12
    1e92:	mov    r12,rdi
    1e95:	mov    QWORD PTR [rsp],rsi
    1e99:	mov    edx,0x11
    1e9e:	mov    QWORD PTR [rsp+0x8],0x11
    1ea7:	mov    rdi,r12
    1eaa:	call   1eaf <botlish_fn_25+0x2a>
			1eab: R_X86_64_PLT32	botlish_fn_24-0x4 ; ht_capacity_for<int, int>
    1eaf:	mov    QWORD PTR [rsp],rax
    1eb3:	mov    rsi,rax
    1eb6:	mov    rdi,r12
    1eb9:	call   1ebe <botlish_fn_25+0x39>
			1eba: R_X86_64_PLT32	botlish_fn_21-0x4 ; ht_alloc<int>
    1ebe:	test   rax,rax
    1ec1:	jne    1ed8 <botlish_fn_25+0x53>
    1ec7:	xor    rax,rax
    1eca:	mov    r12,QWORD PTR [rsp+0x10]
    1ecf:	add    rsp,0x20
    1ed3:	mov    rsp,rbp
    1ed6:	pop    rbp
    1ed7:	ret
    1ed8:	mov    r12,QWORD PTR [rsp+0x10]
    1edd:	add    rsp,0x20
    1ee1:	mov    rsp,rbp
    1ee4:	pop    rbp
    1ee5:	ret

0000000000001ee6 <botlish_entry_25: ht_new_sized<int>>:
    1ee6:	push   rbp
    1ee7:	mov    rbp,rsp
    1eea:	mov    rsi,QWORD PTR [rdx]
    1eed:	call   1ef2 <botlish_entry_25+0xc>
			1eee: R_X86_64_PLT32	botlish_fn_25-0x4 ; ht_new_sized<int>
    1ef2:	mov    rsp,rbp
    1ef5:	pop    rbp
    1ef6:	ret

0000000000001ef7 <botlish_fn_26: ht_size<HashTable>>:
    1ef7:	push   rbp
    1ef8:	mov    rbp,rsp
    1efb:	mov    r9,QWORD PTR [rsi+0x18]
    1eff:	mov    rsi,QWORD PTR [r9+0x18]
    1f03:	mov    edx,0x1
    1f08:	call   1f0d <botlish_fn_26+0x16>
			1f09: R_X86_64_PLT32	rt_mutarray_get-0x4
    1f0d:	test   rax,rax
    1f10:	jne    1f1e <botlish_fn_26+0x27>
    1f16:	xor    rax,rax
    1f19:	mov    rsp,rbp
    1f1c:	pop    rbp
    1f1d:	ret
    1f1e:	mov    rsp,rbp
    1f21:	pop    rbp
    1f22:	ret

0000000000001f23 <botlish_entry_26: ht_size<HashTable>>:
    1f23:	push   rbp
    1f24:	mov    rbp,rsp
    1f27:	mov    rsi,QWORD PTR [rdx]
    1f2a:	call   1f2f <botlish_entry_26+0xc>
			1f2b: R_X86_64_PLT32	botlish_fn_26-0x4 ; ht_size<HashTable>
    1f2f:	mov    rsp,rbp
    1f32:	pop    rbp
    1f33:	ret

0000000000001f34 <botlish_fn_27: ht_tombstones<HashTable>>:
    1f34:	push   rbp
    1f35:	mov    rbp,rsp
    1f38:	mov    r9,QWORD PTR [rsi+0x18]
    1f3c:	mov    rsi,QWORD PTR [r9+0x18]
    1f40:	mov    edx,0x3
    1f45:	call   1f4a <botlish_fn_27+0x16>
			1f46: R_X86_64_PLT32	rt_mutarray_get-0x4
    1f4a:	test   rax,rax
    1f4d:	jne    1f5b <botlish_fn_27+0x27>
    1f53:	xor    rax,rax
    1f56:	mov    rsp,rbp
    1f59:	pop    rbp
    1f5a:	ret
    1f5b:	mov    rsp,rbp
    1f5e:	pop    rbp
    1f5f:	ret

0000000000001f60 <botlish_entry_27: ht_tombstones<HashTable>>:
    1f60:	push   rbp
    1f61:	mov    rbp,rsp
    1f64:	mov    rsi,QWORD PTR [rdx]
    1f67:	call   1f6c <botlish_entry_27+0xc>
			1f68: R_X86_64_PLT32	botlish_fn_27-0x4 ; ht_tombstones<HashTable>
    1f6c:	mov    rsp,rbp
    1f6f:	pop    rbp
    1f70:	ret

0000000000001f71 <botlish_fn_28: ht_capacity<HashTable>>:
    1f71:	push   rbp
    1f72:	mov    rbp,rsp
    1f75:	mov    rsi,QWORD PTR [rsi+0x18]
    1f79:	mov    rsi,QWORD PTR [rsi]
    1f7c:	call   1f81 <botlish_fn_28+0x10>
			1f7d: R_X86_64_PLT32	rt_mutarray_capacity-0x4
    1f81:	mov    rsp,rbp
    1f84:	pop    rbp
    1f85:	ret

0000000000001f86 <botlish_entry_28: ht_capacity<HashTable>>:
    1f86:	push   rbp
    1f87:	mov    rbp,rsp
    1f8a:	mov    rsi,QWORD PTR [rdx]
    1f8d:	call   1f92 <botlish_entry_28+0xc>
			1f8e: R_X86_64_PLT32	botlish_fn_28-0x4 ; ht_capacity<HashTable>
    1f92:	mov    rsp,rbp
    1f95:	pop    rbp
    1f96:	ret

0000000000001f97 <botlish_fn_29: ht_probe_start<HashTable, str>>:
    1f97:	push   rbp
    1f98:	mov    rbp,rsp
    1f9b:	sub    rsp,0x30
    1f9f:	mov    QWORD PTR [rsp+0x10],r12
    1fa4:	mov    QWORD PTR [rsp+0x18],r13
    1fa9:	mov    QWORD PTR [rsp+0x20],r14
    1fae:	mov    r12,rdi
    1fb1:	mov    r14,rsi
    1fb4:	mov    rsi,rdx
    1fb7:	mov    rdi,r12
    1fba:	call   1fbf <botlish_fn_29+0x28>
			1fbb: R_X86_64_PLT32	rt_hash-0x4
    1fbf:	test   rax,rax
    1fc2:	je     1ff6 <botlish_fn_29+0x5f>
    1fc8:	mov    QWORD PTR [rsp],rax
    1fcc:	mov    rsi,r14
    1fcf:	mov    r13,rax
    1fd2:	mov    rdi,r12
    1fd5:	call   1fda <botlish_fn_29+0x43>
			1fd6: R_X86_64_PLT32	botlish_fn_28-0x4 ; ht_capacity<HashTable>
    1fda:	mov    QWORD PTR [rsp+0x8],rax
    1fdf:	mov    rdx,rax
    1fe2:	mov    rsi,r13
    1fe5:	mov    rdi,r12
    1fe8:	call   1fed <botlish_fn_29+0x56>
			1fe9: R_X86_64_PLT32	rt_int_mod-0x4
    1fed:	test   rax,rax
    1ff0:	jne    2011 <botlish_fn_29+0x7a>
    1ff6:	xor    rax,rax
    1ff9:	mov    r12,QWORD PTR [rsp+0x10]
    1ffe:	mov    r13,QWORD PTR [rsp+0x18]
    2003:	mov    r14,QWORD PTR [rsp+0x20]
    2008:	add    rsp,0x30
    200c:	mov    rsp,rbp
    200f:	pop    rbp
    2010:	ret
    2011:	mov    r12,QWORD PTR [rsp+0x10]
    2016:	mov    r13,QWORD PTR [rsp+0x18]
    201b:	mov    r14,QWORD PTR [rsp+0x20]
    2020:	add    rsp,0x30
    2024:	mov    rsp,rbp
    2027:	pop    rbp
    2028:	ret

0000000000002029 <botlish_entry_29: ht_probe_start<HashTable, str>>:
    2029:	push   rbp
    202a:	mov    rbp,rsp
    202d:	mov    rsi,QWORD PTR [rdx]
    2030:	mov    rdx,QWORD PTR [rdx+0x8]
    2034:	call   2039 <botlish_entry_29+0x10>
			2035: R_X86_64_PLT32	botlish_fn_29-0x4 ; ht_probe_start<HashTable, str>
    2039:	mov    rsp,rbp
    203c:	pop    rbp
    203d:	ret

000000000000203e <botlish_fn_30: ht_probe_next<HashTable, int>>:
    203e:	push   rbp
    203f:	mov    rbp,rsp
    2042:	sub    rsp,0x30
    2046:	mov    QWORD PTR [rsp+0x20],rbx
    204b:	mov    QWORD PTR [rsp+0x28],r14
    2050:	mov    r14,rdi
    2053:	mov    QWORD PTR [rsp],rsi
    2057:	mov    rbx,rsi
    205a:	mov    QWORD PTR [rsp+0x8],rdx
    205f:	mov    QWORD PTR [rsp+0x10],0x3
    2068:	test   rdx,0x1
    206f:	jne    207d <botlish_fn_30+0x3f>
    2075:	mov    rcx,rdx
    2078:	jmp    2092 <botlish_fn_30+0x54>
    207d:	mov    rsi,rdx
    2080:	add    rsi,0x2
    2084:	mov    rcx,rdx
    2087:	seto   al
    208a:	test   al,al
    208c:	je     20a5 <botlish_fn_30+0x67>
    2092:	mov    edx,0x3
    2097:	mov    rsi,rcx
    209a:	mov    rdi,r14
    209d:	call   20a2 <botlish_fn_30+0x64>
			209e: R_X86_64_PLT32	rt_int_add-0x4
    20a2:	mov    rsi,rax
    20a5:	mov    QWORD PTR [rsp],rsi
    20a9:	mov    rax,rbx
    20ac:	mov    rbx,rsi
    20af:	mov    rsi,rax
    20b2:	mov    rdi,r14
    20b5:	call   20ba <botlish_fn_30+0x7c>
			20b6: R_X86_64_PLT32	botlish_fn_28-0x4 ; ht_capacity<HashTable>
    20ba:	mov    QWORD PTR [rsp+0x8],rax
    20bf:	mov    rdx,rax
    20c2:	mov    rsi,rbx
    20c5:	mov    rdi,r14
    20c8:	call   20cd <botlish_fn_30+0x8f>
			20c9: R_X86_64_PLT32	rt_int_mod-0x4
    20cd:	test   rax,rax
    20d0:	jne    20ec <botlish_fn_30+0xae>
    20d6:	xor    rax,rax
    20d9:	mov    rbx,QWORD PTR [rsp+0x20]
    20de:	mov    r14,QWORD PTR [rsp+0x28]
    20e3:	add    rsp,0x30
    20e7:	mov    rsp,rbp
    20ea:	pop    rbp
    20eb:	ret
    20ec:	mov    rbx,QWORD PTR [rsp+0x20]
    20f1:	mov    r14,QWORD PTR [rsp+0x28]
    20f6:	add    rsp,0x30
    20fa:	mov    rsp,rbp
    20fd:	pop    rbp
    20fe:	ret

00000000000020ff <botlish_entry_30: ht_probe_next<HashTable, int>>:
    20ff:	push   rbp
    2100:	mov    rbp,rsp
    2103:	mov    rsi,QWORD PTR [rdx]
    2106:	mov    rdx,QWORD PTR [rdx+0x8]
    210a:	call   210f <botlish_entry_30+0x10>
			210b: R_X86_64_PLT32	botlish_fn_30-0x4 ; ht_probe_next<HashTable, int>
    210f:	mov    rsp,rbp
    2112:	pop    rbp
    2113:	ret
    2114:	add    BYTE PTR [rax],al
	...

0000000000002118 <botlish_fn_31: ht_find_get<HashTable, str, int>>:
    2118:	push   rbp
    2119:	mov    rbp,rsp
    211c:	sub    rsp,0x50
    2120:	mov    QWORD PTR [rsp+0x20],rbx
    2125:	mov    QWORD PTR [rsp+0x28],r12
    212a:	mov    QWORD PTR [rsp+0x30],r13
    212f:	mov    QWORD PTR [rsp+0x38],r14
    2134:	mov    QWORD PTR [rsp+0x40],r15
    2139:	mov    r13,rdi
    213c:	mov    QWORD PTR [rsp],rsi
    2140:	mov    QWORD PTR [rsp+0x8],rdx
    2145:	mov    rbx,rdx
    2148:	mov    QWORD PTR [rsp+0x10],rcx
    214d:	mov    r12,rsi
    2150:	mov    r14,rcx
    2153:	mov    rax,QWORD PTR [r12+0x18]
    2158:	mov    rsi,QWORD PTR [rax]
    215b:	mov    rdx,r14
    215e:	mov    rdi,r13
    2161:	call   2166 <botlish_fn_31+0x4e>
			2162: R_X86_64_PLT32	rt_mutarray_get-0x4
    2166:	mov    rcx,rax
    2169:	mov    r15,rax
    216c:	test   rax,rcx
    216f:	je     22bf <botlish_fn_31+0x1a7>
    2175:	mov    rax,r15
    2178:	test   rax,0x1
    217e:	jne    21ac <botlish_fn_31+0x94>
    2184:	mov    edx,0x1
    2189:	mov    rsi,r15
    218c:	mov    rdi,r13
    218f:	call   2194 <botlish_fn_31+0x7c>
			2190: R_X86_64_PLT32	rt_int_cmp-0x4
    2194:	mov    ecx,0x2
    2199:	test   rax,rax
    219c:	cmove  rcx,QWORD PTR [rip+0x1a4]        # 2348 <botlish_fn_31+0x230>
    21a4:	mov    rax,r15
    21a7:	jmp    21c0 <botlish_fn_31+0xa8>
    21ac:	mov    ecx,0x2
    21b1:	mov    rax,r15
    21b4:	cmp    rax,0x1
    21b8:	cmove  rcx,QWORD PTR [rip+0x188]        # 2348 <botlish_fn_31+0x230>
    21c0:	cmp    rcx,0x6
    21c4:	je     231f <botlish_fn_31+0x207>
    21ca:	test   rax,0x1
    21d0:	mov    r15,rax
    21d3:	jne    21fe <botlish_fn_31+0xe6>
    21d9:	mov    edx,0x3
    21de:	mov    rsi,r15
    21e1:	mov    rdi,r13
    21e4:	call   21e9 <botlish_fn_31+0xd1>
			21e5: R_X86_64_PLT32	rt_int_cmp-0x4
    21e9:	mov    ecx,0x2
    21ee:	test   rax,rax
    21f1:	cmove  rcx,QWORD PTR [rip+0x14f]        # 2348 <botlish_fn_31+0x230>
    21f9:	jmp    2212 <botlish_fn_31+0xfa>
    21fe:	mov    rsi,r15
    2201:	mov    ecx,0x2
    2206:	cmp    rsi,0x3
    220a:	cmove  rcx,QWORD PTR [rip+0x136]        # 2348 <botlish_fn_31+0x230>
    2212:	cmp    rcx,0x6
    2216:	je     2226 <botlish_fn_31+0x10e>
    221c:	mov    eax,0x2
    2221:	jmp    229e <botlish_fn_31+0x186>
    2226:	mov    rcx,QWORD PTR [r12+0x18]
    222b:	mov    rsi,QWORD PTR [rcx+0x8]
    222f:	mov    rdx,r14
    2232:	mov    rdi,r13
    2235:	call   223a <botlish_fn_31+0x122>
			2236: R_X86_64_PLT32	rt_mutarray_get-0x4
    223a:	test   rax,rax
    223d:	je     22bf <botlish_fn_31+0x1a7>
    2243:	mov    rsi,rax
    2246:	and    rsi,rbx
    2249:	test   rsi,0x1
    2250:	jne    2272 <botlish_fn_31+0x15a>
    2256:	mov    rsi,rax
    2259:	mov    rdx,rbx
    225c:	mov    rdi,r13
    225f:	call   2264 <botlish_fn_31+0x14c>
			2260: R_X86_64_PLT32	rt_value_eq-0x4
    2264:	test   rax,rax
    2267:	je     22bf <botlish_fn_31+0x1a7>
    226d:	jmp    2285 <botlish_fn_31+0x16d>
    2272:	mov    rsi,rax
    2275:	mov    eax,0x2
    227a:	cmp    rsi,rbx
    227d:	cmove  rax,QWORD PTR [rip+0xc3]        # 2348 <botlish_fn_31+0x230>
    2285:	cmp    rax,0x6
    2289:	je     2299 <botlish_fn_31+0x181>
    228f:	mov    eax,0x2
    2294:	jmp    229e <botlish_fn_31+0x186>
    2299:	mov    eax,0x6
    229e:	cmp    rax,0x6
    22a2:	je     22fa <botlish_fn_31+0x1e2>
    22a8:	mov    rdx,r14
    22ab:	mov    rsi,r12
    22ae:	mov    rdi,r13
    22b1:	call   22b6 <botlish_fn_31+0x19e>
			22b2: R_X86_64_PLT32	botlish_fn_30-0x4 ; ht_probe_next<HashTable, int>
    22b6:	test   rax,rax
    22b9:	jne    22e4 <botlish_fn_31+0x1cc>
    22bf:	xor    rax,rax
    22c2:	mov    rbx,QWORD PTR [rsp+0x20]
    22c7:	mov    r12,QWORD PTR [rsp+0x28]
    22cc:	mov    r13,QWORD PTR [rsp+0x30]
    22d1:	mov    r14,QWORD PTR [rsp+0x38]
    22d6:	mov    r15,QWORD PTR [rsp+0x40]
    22db:	add    rsp,0x50
    22df:	mov    rsp,rbp
    22e2:	pop    rbp
    22e3:	ret
    22e4:	mov    QWORD PTR [rsp],r12
    22e8:	mov    QWORD PTR [rsp+0x8],rbx
    22ed:	mov    QWORD PTR [rsp+0x10],rax
    22f2:	mov    r14,rax
    22f5:	jmp    2153 <botlish_fn_31+0x3b>
    22fa:	mov    rax,r14
    22fd:	mov    rbx,QWORD PTR [rsp+0x20]
    2302:	mov    r12,QWORD PTR [rsp+0x28]
    2307:	mov    r13,QWORD PTR [rsp+0x30]
    230c:	mov    r14,QWORD PTR [rsp+0x38]
    2311:	mov    r15,QWORD PTR [rsp+0x40]
    2316:	add    rsp,0x50
    231a:	mov    rsp,rbp
    231d:	pop    rbp
    231e:	ret
    231f:	mov    rax,0xffffffffffffffff
    2326:	mov    rbx,QWORD PTR [rsp+0x20]
    232b:	mov    r12,QWORD PTR [rsp+0x28]
    2330:	mov    r13,QWORD PTR [rsp+0x30]
    2335:	mov    r14,QWORD PTR [rsp+0x38]
    233a:	mov    r15,QWORD PTR [rsp+0x40]
    233f:	add    rsp,0x50
    2343:	mov    rsp,rbp
    2346:	pop    rbp
    2347:	ret
    2348:	(bad)
    2349:	add    BYTE PTR [rax],al
    234b:	add    BYTE PTR [rax],al
    234d:	add    BYTE PTR [rax],al
	...

0000000000002350 <botlish_entry_31: ht_find_get<HashTable, str, int>>:
    2350:	push   rbp
    2351:	mov    rbp,rsp
    2354:	mov    rsi,QWORD PTR [rdx]
    2357:	mov    r8,QWORD PTR [rdx+0x8]
    235b:	mov    rcx,QWORD PTR [rdx+0x10]
    235f:	mov    rdx,r8
    2362:	call   2367 <botlish_entry_31+0x17>
			2363: R_X86_64_PLT32	botlish_fn_31-0x4 ; ht_find_get<HashTable, str, int>
    2367:	mov    rsp,rbp
    236a:	pop    rbp
    236b:	ret
    236c:	add    BYTE PTR [rax],al
	...

0000000000002370 <botlish_fn_32: ht_find_insert<HashTable, str, int, int>>:
    2370:	push   rbp
    2371:	mov    rbp,rsp
    2374:	sub    rsp,0x60
    2378:	mov    QWORD PTR [rsp+0x30],rbx
    237d:	mov    QWORD PTR [rsp+0x38],r12
    2382:	mov    QWORD PTR [rsp+0x40],r13
    2387:	mov    QWORD PTR [rsp+0x48],r14
    238c:	mov    QWORD PTR [rsp+0x50],r15
    2391:	mov    r15,rdi
    2394:	mov    QWORD PTR [rsp],rsi
    2398:	mov    QWORD PTR [rsp+0x8],rdx
    239d:	mov    r12,rdx
    23a0:	mov    QWORD PTR [rsp+0x10],rcx
    23a5:	mov    QWORD PTR [rsp+0x18],r8
    23aa:	mov    rbx,rsi
    23ad:	mov    r14,rcx
    23b0:	mov    QWORD PTR [rsp+0x20],r8
    23b5:	mov    r10,QWORD PTR [rbx+0x18]
    23b9:	mov    rsi,QWORD PTR [r10]
    23bc:	mov    rdx,r14
    23bf:	mov    rdi,r15
    23c2:	call   23c7 <botlish_fn_32+0x57>
			23c3: R_X86_64_PLT32	rt_mutarray_get-0x4
    23c7:	mov    rcx,rax
    23ca:	mov    r13,rax
    23cd:	test   rax,rcx
    23d0:	je     2620 <botlish_fn_32+0x2b0>
    23d6:	mov    rax,r13
    23d9:	test   rax,0x1
    23df:	jne    240a <botlish_fn_32+0x9a>
    23e5:	mov    edx,0x1
    23ea:	mov    rsi,r13
    23ed:	mov    rdi,r15
    23f0:	call   23f5 <botlish_fn_32+0x85>
			23f1: R_X86_64_PLT32	rt_int_cmp-0x4
    23f5:	mov    ecx,0x2
    23fa:	test   rax,rax
    23fd:	cmove  rcx,QWORD PTR [rip+0x313]        # 2718 <botlish_fn_32+0x3a8>
    2405:	jmp    241e <botlish_fn_32+0xae>
    240a:	mov    ecx,0x2
    240f:	mov    rax,r13
    2412:	cmp    rax,0x1
    2416:	cmove  rcx,QWORD PTR [rip+0x2fa]        # 2718 <botlish_fn_32+0x3a8>
    241e:	cmp    rcx,0x6
    2422:	je     2670 <botlish_fn_32+0x300>
    2428:	mov    rax,r13
    242b:	test   rax,0x1
    2431:	jne    245c <botlish_fn_32+0xec>
    2437:	mov    edx,0x3
    243c:	mov    rsi,r13
    243f:	mov    rdi,r15
    2442:	call   2447 <botlish_fn_32+0xd7>
			2443: R_X86_64_PLT32	rt_int_cmp-0x4
    2447:	mov    ecx,0x2
    244c:	test   rax,rax
    244f:	cmove  rcx,QWORD PTR [rip+0x2c1]        # 2718 <botlish_fn_32+0x3a8>
    2457:	jmp    2470 <botlish_fn_32+0x100>
    245c:	mov    ecx,0x2
    2461:	mov    rax,r13
    2464:	cmp    rax,0x3
    2468:	cmove  rcx,QWORD PTR [rip+0x2a8]        # 2718 <botlish_fn_32+0x3a8>
    2470:	cmp    rcx,0x6
    2474:	je     2484 <botlish_fn_32+0x114>
    247a:	mov    eax,0x2
    247f:	jmp    24f8 <botlish_fn_32+0x188>
    2484:	mov    rax,QWORD PTR [rbx+0x18]
    2488:	mov    rsi,QWORD PTR [rax+0x8]
    248c:	mov    rdx,r14
    248f:	mov    rdi,r15
    2492:	call   2497 <botlish_fn_32+0x127>
			2493: R_X86_64_PLT32	rt_mutarray_get-0x4
    2497:	test   rax,rax
    249a:	je     2620 <botlish_fn_32+0x2b0>
    24a0:	mov    rcx,rax
    24a3:	and    rcx,r12
    24a6:	mov    rsi,rax
    24a9:	test   rcx,0x1
    24b0:	jne    24cf <botlish_fn_32+0x15f>
    24b6:	mov    rdx,r12
    24b9:	mov    rdi,r15
    24bc:	call   24c1 <botlish_fn_32+0x151>
			24bd: R_X86_64_PLT32	rt_value_eq-0x4
    24c1:	test   rax,rax
    24c4:	je     2620 <botlish_fn_32+0x2b0>
    24ca:	jmp    24df <botlish_fn_32+0x16f>
    24cf:	mov    eax,0x2
    24d4:	cmp    rsi,r12
    24d7:	cmove  rax,QWORD PTR [rip+0x239]        # 2718 <botlish_fn_32+0x3a8>
    24df:	cmp    rax,0x6
    24e3:	je     24f3 <botlish_fn_32+0x183>
    24e9:	mov    eax,0x2
    24ee:	jmp    24f8 <botlish_fn_32+0x188>
    24f3:	mov    eax,0x6
    24f8:	cmp    rax,0x6
    24fc:	je     2668 <botlish_fn_32+0x2f8>
    2502:	mov    rax,r13
    2505:	test   rax,0x1
    250b:	jne    2536 <botlish_fn_32+0x1c6>
    2511:	mov    edx,0x5
    2516:	mov    rsi,r13
    2519:	mov    rdi,r15
    251c:	call   2521 <botlish_fn_32+0x1b1>
			251d: R_X86_64_PLT32	rt_int_cmp-0x4
    2521:	mov    ecx,0x2
    2526:	test   rax,rax
    2529:	cmove  rcx,QWORD PTR [rip+0x1e7]        # 2718 <botlish_fn_32+0x3a8>
    2531:	jmp    254a <botlish_fn_32+0x1da>
    2536:	mov    rsi,r13
    2539:	mov    ecx,0x2
    253e:	cmp    rsi,0x5
    2542:	cmove  rcx,QWORD PTR [rip+0x1ce]        # 2718 <botlish_fn_32+0x3a8>
    254a:	cmp    rcx,0x6
    254e:	je     255e <botlish_fn_32+0x1ee>
    2554:	mov    eax,0x2
    2559:	jmp    25c8 <botlish_fn_32+0x258>
    255e:	mov    r13,QWORD PTR [rsp+0x20]
    2563:	test   r13,0x1
    256a:	jne    259a <botlish_fn_32+0x22a>
    2570:	mov    edx,0x1
    2575:	mov    rsi,r13
    2578:	mov    rdi,r15
    257b:	call   2580 <botlish_fn_32+0x210>
			257c: R_X86_64_PLT32	rt_int_cmp-0x4
    2580:	mov    ecx,0x2
    2585:	test   rax,rax
    2588:	cmovl  rcx,QWORD PTR [rip+0x188]        # 2718 <botlish_fn_32+0x3a8>
    2590:	mov    QWORD PTR [rsp+0x20],r13
    2595:	jmp    25af <botlish_fn_32+0x23f>
    259a:	mov    ecx,0x2
    259f:	test   r13,r13
    25a2:	mov    QWORD PTR [rsp+0x20],r13
    25a7:	cmovle rcx,QWORD PTR [rip+0x169]        # 2718 <botlish_fn_32+0x3a8>
    25af:	cmp    rcx,0x6
    25b3:	je     25c3 <botlish_fn_32+0x253>
    25b9:	mov    eax,0x2
    25be:	jmp    25c8 <botlish_fn_32+0x258>
    25c3:	mov    eax,0x6
    25c8:	cmp    rax,0x6
    25cc:	je     2609 <botlish_fn_32+0x299>
    25d2:	mov    rdx,r14
    25d5:	mov    rsi,rbx
    25d8:	mov    rdi,r15
    25db:	call   25e0 <botlish_fn_32+0x270>
			25dc: R_X86_64_PLT32	botlish_fn_30-0x4 ; ht_probe_next<HashTable, int>
    25e0:	test   rax,rax
    25e3:	je     2620 <botlish_fn_32+0x2b0>
    25e9:	mov    QWORD PTR [rsp],rbx
    25ed:	mov    QWORD PTR [rsp+0x8],r12
    25f2:	mov    QWORD PTR [rsp+0x10],rax
    25f7:	mov    r10,QWORD PTR [rsp+0x20]
    25fc:	mov    QWORD PTR [rsp+0x18],r10
    2601:	mov    r14,rax
    2604:	jmp    23b5 <botlish_fn_32+0x45>
    2609:	mov    rdx,r14
    260c:	mov    rsi,rbx
    260f:	mov    rdi,r15
    2612:	call   2617 <botlish_fn_32+0x2a7>
			2613: R_X86_64_PLT32	botlish_fn_30-0x4 ; ht_probe_next<HashTable, int>
    2617:	test   rax,rax
    261a:	jne    2645 <botlish_fn_32+0x2d5>
    2620:	xor    rax,rax
    2623:	mov    rbx,QWORD PTR [rsp+0x30]
    2628:	mov    r12,QWORD PTR [rsp+0x38]
    262d:	mov    r13,QWORD PTR [rsp+0x40]
    2632:	mov    r14,QWORD PTR [rsp+0x48]
    2637:	mov    r15,QWORD PTR [rsp+0x50]
    263c:	add    rsp,0x60
    2640:	mov    rsp,rbp
    2643:	pop    rbp
    2644:	ret
    2645:	mov    QWORD PTR [rsp],rbx
    2649:	mov    QWORD PTR [rsp+0x8],r12
    264e:	mov    QWORD PTR [rsp+0x10],rax
    2653:	mov    rdx,r14
    2656:	mov    QWORD PTR [rsp+0x18],rdx
    265b:	mov    QWORD PTR [rsp+0x20],r14
    2660:	mov    r14,rax
    2663:	jmp    23b5 <botlish_fn_32+0x45>
    2668:	mov    rax,r14
    266b:	jmp    26cf <botlish_fn_32+0x35f>
    2670:	mov    rax,QWORD PTR [rsp+0x20]
    2675:	test   rax,0x1
    267b:	jne    26a8 <botlish_fn_32+0x338>
    2681:	mov    edx,0x1
    2686:	mov    rdi,r15
    2689:	mov    rsi,QWORD PTR [rsp+0x20]
    268e:	call   2693 <botlish_fn_32+0x323>
			268f: R_X86_64_PLT32	rt_int_cmp-0x4
    2693:	mov    ecx,0x2
    2698:	test   rax,rax
    269b:	cmovge rcx,QWORD PTR [rip+0x75]        # 2718 <botlish_fn_32+0x3a8>
    26a3:	jmp    26c2 <botlish_fn_32+0x352>
    26a8:	mov    ecx,0x2
    26ad:	mov    rax,QWORD PTR [rsp+0x20]
    26b2:	mov    rdx,QWORD PTR [rsp+0x20]
    26b7:	test   rax,rdx
    26ba:	cmovg  rcx,QWORD PTR [rip+0x56]        # 2718 <botlish_fn_32+0x3a8>
    26c2:	cmp    rcx,0x6
    26c6:	je     26f1 <botlish_fn_32+0x381>
    26cc:	mov    rax,r14
    26cf:	mov    rbx,QWORD PTR [rsp+0x30]
    26d4:	mov    r12,QWORD PTR [rsp+0x38]
    26d9:	mov    r13,QWORD PTR [rsp+0x40]
    26de:	mov    r14,QWORD PTR [rsp+0x48]
    26e3:	mov    r15,QWORD PTR [rsp+0x50]
    26e8:	add    rsp,0x60
    26ec:	mov    rsp,rbp
    26ef:	pop    rbp
    26f0:	ret
    26f1:	mov    rax,QWORD PTR [rsp+0x20]
    26f6:	mov    rbx,QWORD PTR [rsp+0x30]
    26fb:	mov    r12,QWORD PTR [rsp+0x38]
    2700:	mov    r13,QWORD PTR [rsp+0x40]
    2705:	mov    r14,QWORD PTR [rsp+0x48]
    270a:	mov    r15,QWORD PTR [rsp+0x50]
    270f:	add    rsp,0x60
    2713:	mov    rsp,rbp
    2716:	pop    rbp
    2717:	ret
    2718:	(bad)
    2719:	add    BYTE PTR [rax],al
    271b:	add    BYTE PTR [rax],al
    271d:	add    BYTE PTR [rax],al
	...

0000000000002720 <botlish_entry_32: ht_find_insert<HashTable, str, int, int>>:
    2720:	push   rbp
    2721:	mov    rbp,rsp
    2724:	mov    rsi,QWORD PTR [rdx]
    2727:	mov    r9,QWORD PTR [rdx+0x8]
    272b:	mov    rcx,QWORD PTR [rdx+0x10]
    272f:	mov    r8,QWORD PTR [rdx+0x18]
    2733:	mov    rdx,r9
    2736:	call   273b <botlish_entry_32+0x1b>
			2737: R_X86_64_PLT32	botlish_fn_32-0x4 ; ht_find_insert<HashTable, str, int, int>
    273b:	mov    rsp,rbp
    273e:	pop    rbp
    273f:	ret

0000000000002740 <botlish_fn_33: ht_get<HashTable, str>>:
    2740:	push   rbp
    2741:	mov    rbp,rsp
    2744:	sub    rsp,0x40
    2748:	mov    QWORD PTR [rsp+0x20],rbx
    274d:	mov    QWORD PTR [rsp+0x28],r12
    2752:	mov    QWORD PTR [rsp+0x30],r13
    2757:	mov    r12,rdi
    275a:	mov    QWORD PTR [rsp+0x10],0x0
    2763:	mov    QWORD PTR [rsp],rsi
    2767:	mov    QWORD PTR [rsp+0x8],rdx
    276c:	mov    r13,rdx
    276f:	mov    rbx,rsi
    2772:	mov    rdx,r13
    2775:	mov    rdi,r12
    2778:	call   277d <botlish_fn_33+0x3d>
			2779: R_X86_64_PLT32	botlish_fn_29-0x4 ; ht_probe_start<HashTable, str>
    277d:	test   rax,rax
    2780:	je     2818 <botlish_fn_33+0xd8>
    2786:	mov    QWORD PTR [rsp+0x10],rax
    278b:	mov    rcx,rax
    278e:	mov    rdx,r13
    2791:	mov    rsi,rbx
    2794:	mov    rdi,r12
    2797:	call   279c <botlish_fn_33+0x5c>
			2798: R_X86_64_PLT32	botlish_fn_31-0x4 ; ht_find_get<HashTable, str, int>
    279c:	mov    rcx,rax
    279f:	mov    r13,rax
    27a2:	test   rax,rcx
    27a5:	je     2818 <botlish_fn_33+0xd8>
    27ab:	mov    rax,r13
    27ae:	test   rax,0x1
    27b4:	jne    27df <botlish_fn_33+0x9f>
    27ba:	mov    edx,0x1
    27bf:	mov    rsi,r13
    27c2:	mov    rdi,r12
    27c5:	call   27ca <botlish_fn_33+0x8a>
			27c6: R_X86_64_PLT32	rt_int_cmp-0x4
    27ca:	mov    ecx,0x2
    27cf:	test   rax,rax
    27d2:	cmovl  rcx,QWORD PTR [rip+0x8e]        # 2868 <botlish_fn_33+0x128>
    27da:	jmp    27f2 <botlish_fn_33+0xb2>
    27df:	mov    ecx,0x2
    27e4:	mov    rax,r13
    27e7:	test   rax,rax
    27ea:	cmovle rcx,QWORD PTR [rip+0x76]        # 2868 <botlish_fn_33+0x128>
    27f2:	cmp    rcx,0x6
    27f6:	je     284b <botlish_fn_33+0x10b>
    27fc:	mov    rax,QWORD PTR [rbx+0x18]
    2800:	mov    rsi,QWORD PTR [rax+0x10]
    2804:	mov    rdx,r13
    2807:	mov    rdi,r12
    280a:	call   280f <botlish_fn_33+0xcf>
			280b: R_X86_64_PLT32	rt_mutarray_get-0x4
    280f:	test   rax,rax
    2812:	jne    2833 <botlish_fn_33+0xf3>
    2818:	xor    rax,rax
    281b:	mov    rbx,QWORD PTR [rsp+0x20]
    2820:	mov    r12,QWORD PTR [rsp+0x28]
    2825:	mov    r13,QWORD PTR [rsp+0x30]
    282a:	add    rsp,0x40
    282e:	mov    rsp,rbp
    2831:	pop    rbp
    2832:	ret
    2833:	mov    rbx,QWORD PTR [rsp+0x20]
    2838:	mov    r12,QWORD PTR [rsp+0x28]
    283d:	mov    r13,QWORD PTR [rsp+0x30]
    2842:	add    rsp,0x40
    2846:	mov    rsp,rbp
    2849:	pop    rbp
    284a:	ret
    284b:	mov    eax,0xa
    2850:	mov    rbx,QWORD PTR [rsp+0x20]
    2855:	mov    r12,QWORD PTR [rsp+0x28]
    285a:	mov    r13,QWORD PTR [rsp+0x30]
    285f:	add    rsp,0x40
    2863:	mov    rsp,rbp
    2866:	pop    rbp
    2867:	ret
    2868:	(bad)
    2869:	add    BYTE PTR [rax],al
    286b:	add    BYTE PTR [rax],al
    286d:	add    BYTE PTR [rax],al
	...

0000000000002870 <botlish_entry_33: ht_get<HashTable, str>>:
    2870:	push   rbp
    2871:	mov    rbp,rsp
    2874:	mov    rsi,QWORD PTR [rdx]
    2877:	mov    rdx,QWORD PTR [rdx+0x8]
    287b:	call   2880 <botlish_entry_33+0x10>
			287c: R_X86_64_PLT32	botlish_fn_33-0x4 ; ht_get<HashTable, str>
    2880:	mov    rsp,rbp
    2883:	pop    rbp
    2884:	ret
    2885:	add    BYTE PTR [rax],al
	...

0000000000002888 <botlish_fn_34: ht_rehash_probe<mutarray, int, int>>:
    2888:	push   rbp
    2889:	mov    rbp,rsp
    288c:	sub    rsp,0x40
    2890:	mov    QWORD PTR [rsp+0x20],rbx
    2895:	mov    QWORD PTR [rsp+0x28],r12
    289a:	mov    QWORD PTR [rsp+0x30],r13
    289f:	mov    QWORD PTR [rsp+0x38],r14
    28a4:	mov    r13,rdi
    28a7:	mov    QWORD PTR [rsp],rsi
    28ab:	mov    QWORD PTR [rsp+0x8],rdx
    28b0:	mov    QWORD PTR [rsp+0x10],rcx
    28b5:	mov    r12,rcx
    28b8:	mov    rbx,rsi
    28bb:	mov    r14,rdx
    28be:	mov    rdx,r14
    28c1:	mov    rsi,rbx
    28c4:	mov    rdi,r13
    28c7:	call   28cc <botlish_fn_34+0x44>
			28c8: R_X86_64_PLT32	rt_mutarray_get-0x4
    28cc:	test   rax,rax
    28cf:	je     2971 <botlish_fn_34+0xe9>
    28d5:	test   rax,0x1
    28db:	mov    rsi,rax
    28de:	jne    28ff <botlish_fn_34+0x77>
    28e4:	mov    edx,0x1
    28e9:	mov    rdi,r13
    28ec:	call   28f1 <botlish_fn_34+0x69>
			28ed: R_X86_64_PLT32	rt_value_eq-0x4
    28f1:	test   rax,rax
    28f4:	je     2971 <botlish_fn_34+0xe9>
    28fa:	jmp    2910 <botlish_fn_34+0x88>
    28ff:	mov    eax,0x2
    2904:	cmp    rsi,0x1
    2908:	cmove  rax,QWORD PTR [rip+0xb8]        # 29c8 <botlish_fn_34+0x140>
    2910:	cmp    rax,0x6
    2914:	je     29a7 <botlish_fn_34+0x11f>
    291a:	mov    QWORD PTR [rsp+0x18],0x3
    2923:	mov    rsi,r14
    2926:	test   rsi,0x1
    292d:	je     2945 <botlish_fn_34+0xbd>
    2933:	mov    rsi,r14
    2936:	add    rsi,0x2
    293a:	seto   al
    293d:	test   al,al
    293f:	je     2958 <botlish_fn_34+0xd0>
    2945:	mov    edx,0x3
    294a:	mov    rsi,r14
    294d:	mov    rdi,r13
    2950:	call   2955 <botlish_fn_34+0xcd>
			2951: R_X86_64_PLT32	rt_int_add-0x4
    2955:	mov    rsi,rax
    2958:	mov    QWORD PTR [rsp+0x8],rsi
    295d:	mov    rdx,r12
    2960:	mov    rdi,r13
    2963:	call   2968 <botlish_fn_34+0xe0>
			2964: R_X86_64_PLT32	rt_int_mod-0x4
    2968:	test   rax,rax
    296b:	jne    2991 <botlish_fn_34+0x109>
    2971:	xor    rax,rax
    2974:	mov    rbx,QWORD PTR [rsp+0x20]
    2979:	mov    r12,QWORD PTR [rsp+0x28]
    297e:	mov    r13,QWORD PTR [rsp+0x30]
    2983:	mov    r14,QWORD PTR [rsp+0x38]
    2988:	add    rsp,0x40
    298c:	mov    rsp,rbp
    298f:	pop    rbp
    2990:	ret
    2991:	mov    QWORD PTR [rsp],rbx
    2995:	mov    QWORD PTR [rsp+0x8],rax
    299a:	mov    QWORD PTR [rsp+0x10],r12
    299f:	mov    r14,rax
    29a2:	jmp    28be <botlish_fn_34+0x36>
    29a7:	mov    rax,r14
    29aa:	mov    rbx,QWORD PTR [rsp+0x20]
    29af:	mov    r12,QWORD PTR [rsp+0x28]
    29b4:	mov    r13,QWORD PTR [rsp+0x30]
    29b9:	mov    r14,QWORD PTR [rsp+0x38]
    29be:	add    rsp,0x40
    29c2:	mov    rsp,rbp
    29c5:	pop    rbp
    29c6:	ret
    29c7:	add    BYTE PTR [rsi],al
    29c9:	add    BYTE PTR [rax],al
    29cb:	add    BYTE PTR [rax],al
    29cd:	add    BYTE PTR [rax],al
	...

00000000000029d0 <botlish_entry_34: ht_rehash_probe<mutarray, int, int>>:
    29d0:	push   rbp
    29d1:	mov    rbp,rsp
    29d4:	mov    rsi,QWORD PTR [rdx]
    29d7:	mov    r8,QWORD PTR [rdx+0x8]
    29db:	mov    rcx,QWORD PTR [rdx+0x10]
    29df:	mov    rdx,r8
    29e2:	call   29e7 <botlish_entry_34+0x17>
			29e3: R_X86_64_PLT32	botlish_fn_34-0x4 ; ht_rehash_probe<mutarray, int, int>
    29e7:	mov    rsp,rbp
    29ea:	pop    rbp
    29eb:	ret

00000000000029ec <botlish_fn_35: ht_rehash_insert<HashTable, int, any, any>>:
    29ec:	push   rbp
    29ed:	mov    rbp,rsp
    29f0:	sub    rsp,0x70
    29f4:	mov    QWORD PTR [rsp+0x40],rbx
    29f9:	mov    QWORD PTR [rsp+0x48],r12
    29fe:	mov    QWORD PTR [rsp+0x50],r13
    2a03:	mov    QWORD PTR [rsp+0x58],r14
    2a08:	mov    QWORD PTR [rsp+0x60],r15
    2a0d:	mov    r13,rdi
    2a10:	mov    QWORD PTR [rsp],rsi
    2a14:	mov    QWORD PTR [rsp+0x8],rdx
    2a19:	mov    r15,rdx
    2a1c:	mov    QWORD PTR [rsp+0x10],rcx
    2a21:	mov    r14,rcx
    2a24:	mov    QWORD PTR [rsp+0x18],r8
    2a29:	mov    r12,r8
    2a2c:	mov    rax,QWORD PTR [rsi+0x18]
    2a30:	mov    rbx,rsi
    2a33:	mov    rsi,QWORD PTR [rax]
    2a36:	mov    QWORD PTR [rsp+0x20],rsi
    2a3b:	mov    QWORD PTR [rsp+0x30],rsi
    2a40:	mov    rsi,r14
    2a43:	mov    rdi,r13
    2a46:	call   2a4b <botlish_fn_35+0x5f>
			2a47: R_X86_64_PLT32	rt_hash-0x4
    2a4b:	test   rax,rax
    2a4e:	je     2af5 <botlish_fn_35+0x109>
    2a54:	mov    QWORD PTR [rsp+0x28],rax
    2a59:	mov    rsi,rax
    2a5c:	mov    rdx,r15
    2a5f:	mov    rdi,r13
    2a62:	call   2a67 <botlish_fn_35+0x7b>
			2a63: R_X86_64_PLT32	rt_int_mod-0x4
    2a67:	test   rax,rax
    2a6a:	je     2af5 <botlish_fn_35+0x109>
    2a70:	mov    QWORD PTR [rsp+0x28],rax
    2a75:	mov    rcx,r15
    2a78:	mov    rdx,rax
    2a7b:	mov    rsi,QWORD PTR [rsp+0x30]
    2a80:	mov    rdi,r13
    2a83:	call   2a88 <botlish_fn_35+0x9c>
			2a84: R_X86_64_PLT32	botlish_fn_34-0x4 ; ht_rehash_probe<mutarray, int, int>
    2a88:	mov    rdx,rax
    2a8b:	mov    r15,rax
    2a8e:	test   rax,rdx
    2a91:	je     2af5 <botlish_fn_35+0x109>
    2a97:	mov    rcx,QWORD PTR [rbx+0x18]
    2a9b:	mov    rsi,QWORD PTR [rcx]
    2a9e:	mov    ecx,0x3
    2aa3:	mov    rdx,r15
    2aa6:	mov    rdi,r13
    2aa9:	call   2aae <botlish_fn_35+0xc2>
			2aaa: R_X86_64_PLT32	rt_mutarray_set-0x4
    2aae:	test   rax,rax
    2ab1:	je     2af5 <botlish_fn_35+0x109>
    2ab7:	mov    rax,QWORD PTR [rbx+0x18]
    2abb:	mov    rsi,QWORD PTR [rax+0x8]
    2abf:	mov    rcx,r14
    2ac2:	mov    rdx,r15
    2ac5:	mov    rdi,r13
    2ac8:	call   2acd <botlish_fn_35+0xe1>
			2ac9: R_X86_64_PLT32	rt_mutarray_set-0x4
    2acd:	test   rax,rax
    2ad0:	je     2af5 <botlish_fn_35+0x109>
    2ad6:	mov    rax,QWORD PTR [rbx+0x18]
    2ada:	mov    rsi,QWORD PTR [rax+0x10]
    2ade:	mov    rcx,r12
    2ae1:	mov    rdx,r15
    2ae4:	mov    rdi,r13
    2ae7:	call   2aec <botlish_fn_35+0x100>
			2ae8: R_X86_64_PLT32	rt_mutarray_set-0x4
    2aec:	test   rax,rax
    2aef:	jne    2b1a <botlish_fn_35+0x12e>
    2af5:	xor    rax,rax
    2af8:	mov    rbx,QWORD PTR [rsp+0x40]
    2afd:	mov    r12,QWORD PTR [rsp+0x48]
    2b02:	mov    r13,QWORD PTR [rsp+0x50]
    2b07:	mov    r14,QWORD PTR [rsp+0x58]
    2b0c:	mov    r15,QWORD PTR [rsp+0x60]
    2b11:	add    rsp,0x70
    2b15:	mov    rsp,rbp
    2b18:	pop    rbp
    2b19:	ret
    2b1a:	mov    rax,rbx
    2b1d:	mov    rbx,QWORD PTR [rsp+0x40]
    2b22:	mov    r12,QWORD PTR [rsp+0x48]
    2b27:	mov    r13,QWORD PTR [rsp+0x50]
    2b2c:	mov    r14,QWORD PTR [rsp+0x58]
    2b31:	mov    r15,QWORD PTR [rsp+0x60]
    2b36:	add    rsp,0x70
    2b3a:	mov    rsp,rbp
    2b3d:	pop    rbp
    2b3e:	ret

0000000000002b3f <botlish_entry_35: ht_rehash_insert<HashTable, int, any, any>>:
    2b3f:	push   rbp
    2b40:	mov    rbp,rsp
    2b43:	mov    rsi,QWORD PTR [rdx]
    2b46:	mov    r9,QWORD PTR [rdx+0x8]
    2b4a:	mov    rcx,QWORD PTR [rdx+0x10]
    2b4e:	mov    r8,QWORD PTR [rdx+0x18]
    2b52:	mov    rdx,r9
    2b55:	call   2b5a <botlish_entry_35+0x1b>
			2b56: R_X86_64_PLT32	botlish_fn_35-0x4 ; ht_rehash_insert<HashTable, int, any, any>
    2b5a:	mov    rsp,rbp
    2b5d:	pop    rbp
    2b5e:	ret
	...

0000000000002b60 <botlish_fn_36: ht_rehash_scan<mutarray, mutarray, mutarray, int, int, HashTable, int>>:
    2b60:	push   rbp
    2b61:	mov    rbp,rsp
    2b64:	sub    rsp,0x90
    2b6b:	mov    QWORD PTR [rsp+0x60],rbx
    2b70:	mov    QWORD PTR [rsp+0x68],r12
    2b75:	mov    QWORD PTR [rsp+0x70],r13
    2b7a:	mov    QWORD PTR [rsp+0x78],r14
    2b7f:	mov    QWORD PTR [rsp+0x80],r15
    2b87:	mov    QWORD PTR [rsp+0x38],rdi
    2b8c:	mov    QWORD PTR [rsp+0x40],r9
    2b91:	mov    rdi,QWORD PTR [rbp+0x10]
    2b95:	mov    rbx,QWORD PTR [rbp+0x18]
    2b99:	mov    QWORD PTR [rsp],rsi
    2b9d:	mov    QWORD PTR [rsp+0x8],rdx
    2ba2:	mov    r14,rdx
    2ba5:	mov    QWORD PTR [rsp+0x10],rcx
    2baa:	mov    r15,rcx
    2bad:	mov    QWORD PTR [rsp+0x18],rdi
    2bb2:	mov    QWORD PTR [rsp+0x20],rbx
    2bb7:	sar    r8,1
    2bba:	mov    rcx,QWORD PTR [rsp+0x40]
    2bbf:	mov    r12,r8
    2bc2:	mov    QWORD PTR [rsp+0x48],rdi
    2bc7:	cmp    r12,rcx
    2bca:	mov    QWORD PTR [rsp+0x40],rcx
    2bcf:	jge    2d36 <botlish_fn_36+0x1d6>
    2bd5:	mov    rdx,r12
    2bd8:	shl    rdx,1
    2bdb:	or     rdx,0x1
    2bdf:	mov    r13,rsi
    2be2:	mov    QWORD PTR [rsp+0x58],rdx
    2be7:	mov    rdi,QWORD PTR [rsp+0x38]
    2bec:	call   2bf1 <botlish_fn_36+0x91>
			2bed: R_X86_64_PLT32	rt_mutarray_get-0x4
    2bf1:	test   rax,rax
    2bf4:	je     2cda <botlish_fn_36+0x17a>
    2bfa:	test   rax,0x1
    2c00:	mov    rsi,rax
    2c03:	jne    2c26 <botlish_fn_36+0xc6>
    2c09:	mov    edx,0x3
    2c0e:	mov    rdi,QWORD PTR [rsp+0x38]
    2c13:	call   2c18 <botlish_fn_36+0xb8>
			2c14: R_X86_64_PLT32	rt_value_eq-0x4
    2c18:	test   rax,rax
    2c1b:	je     2cda <botlish_fn_36+0x17a>
    2c21:	jmp    2c37 <botlish_fn_36+0xd7>
    2c26:	mov    eax,0x2
    2c2b:	cmp    rsi,0x3
    2c2f:	cmove  rax,QWORD PTR [rip+0x131]        # 2d68 <botlish_fn_36+0x208>
    2c37:	cmp    rax,0x6
    2c3b:	je     2c72 <botlish_fn_36+0x112>
    2c41:	mov    QWORD PTR [rsp],r13
    2c45:	mov    QWORD PTR [rsp+0x8],r14
    2c4a:	mov    QWORD PTR [rsp+0x10],r15
    2c4f:	mov    rsi,QWORD PTR [rsp+0x48]
    2c54:	mov    QWORD PTR [rsp+0x18],rsi
    2c59:	mov    QWORD PTR [rsp+0x20],rbx
    2c5e:	add    r12,0x1
    2c65:	mov    rcx,QWORD PTR [rsp+0x40]
    2c6a:	mov    rsi,r13
    2c6d:	jmp    2bc7 <botlish_fn_36+0x67>
    2c72:	mov    rdx,QWORD PTR [rsp+0x58]
    2c77:	mov    rsi,r14
    2c7a:	mov    rdi,QWORD PTR [rsp+0x38]
    2c7f:	call   2c84 <botlish_fn_36+0x124>
			2c80: R_X86_64_PLT32	rt_mutarray_get-0x4
    2c84:	test   rax,rax
    2c87:	je     2cda <botlish_fn_36+0x17a>
    2c8d:	mov    QWORD PTR [rsp+0x28],rax
    2c92:	mov    rdx,QWORD PTR [rsp+0x58]
    2c97:	mov    QWORD PTR [rsp+0x50],rax
    2c9c:	mov    rsi,r15
    2c9f:	mov    rdi,QWORD PTR [rsp+0x38]
    2ca4:	call   2ca9 <botlish_fn_36+0x149>
			2ca5: R_X86_64_PLT32	rt_mutarray_get-0x4
    2ca9:	test   rax,rax
    2cac:	je     2cda <botlish_fn_36+0x17a>
    2cb2:	mov    QWORD PTR [rsp+0x30],rax
    2cb7:	mov    rcx,QWORD PTR [rsp+0x50]
    2cbc:	mov    rsi,QWORD PTR [rsp+0x48]
    2cc1:	mov    r8,rax
    2cc4:	mov    rdx,rbx
    2cc7:	mov    rdi,QWORD PTR [rsp+0x38]
    2ccc:	call   2cd1 <botlish_fn_36+0x171>
			2ccd: R_X86_64_PLT32	botlish_fn_35-0x4 ; ht_rehash_insert<HashTable, int, any, any>
    2cd1:	test   rax,rax
    2cd4:	jne    2d05 <botlish_fn_36+0x1a5>
    2cda:	xor    rax,rax
    2cdd:	mov    rbx,QWORD PTR [rsp+0x60]
    2ce2:	mov    r12,QWORD PTR [rsp+0x68]
    2ce7:	mov    r13,QWORD PTR [rsp+0x70]
    2cec:	mov    r14,QWORD PTR [rsp+0x78]
    2cf1:	mov    r15,QWORD PTR [rsp+0x80]
    2cf9:	add    rsp,0x90
    2d00:	mov    rsp,rbp
    2d03:	pop    rbp
    2d04:	ret
    2d05:	mov    QWORD PTR [rsp],r13
    2d09:	mov    QWORD PTR [rsp+0x8],r14
    2d0e:	mov    QWORD PTR [rsp+0x10],r15
    2d13:	mov    QWORD PTR [rsp+0x18],rax
    2d18:	mov    QWORD PTR [rsp+0x20],rbx
    2d1d:	add    r12,0x1
    2d24:	mov    rcx,QWORD PTR [rsp+0x40]
    2d29:	mov    rsi,r13
    2d2c:	mov    QWORD PTR [rsp+0x48],rax
    2d31:	jmp    2bc7 <botlish_fn_36+0x67>
    2d36:	mov    rax,QWORD PTR [rsp+0x48]
    2d3b:	mov    rbx,QWORD PTR [rsp+0x60]
    2d40:	mov    r12,QWORD PTR [rsp+0x68]
    2d45:	mov    r13,QWORD PTR [rsp+0x70]
    2d4a:	mov    r14,QWORD PTR [rsp+0x78]
    2d4f:	mov    r15,QWORD PTR [rsp+0x80]
    2d57:	add    rsp,0x90
    2d5e:	mov    rsp,rbp
    2d61:	pop    rbp
    2d62:	ret
    2d63:	add    BYTE PTR [rax],al
    2d65:	add    BYTE PTR [rax],al
    2d67:	add    BYTE PTR [rsi],al
    2d69:	add    BYTE PTR [rax],al
    2d6b:	add    BYTE PTR [rax],al
    2d6d:	add    BYTE PTR [rax],al
	...

0000000000002d70 <botlish_entry_36: ht_rehash_scan<mutarray, mutarray, mutarray, int, int, HashTable, int>>:
    2d70:	push   rbp
    2d71:	mov    rbp,rsp
    2d74:	sub    rsp,0x10
    2d78:	mov    rsi,QWORD PTR [rdx]
    2d7b:	mov    r11,QWORD PTR [rdx+0x8]
    2d7f:	mov    rcx,QWORD PTR [rdx+0x10]
    2d83:	mov    r8,QWORD PTR [rdx+0x18]
    2d87:	mov    r9,QWORD PTR [rdx+0x20]
    2d8b:	mov    rax,QWORD PTR [rdx+0x28]
    2d8f:	mov    rdx,QWORD PTR [rdx+0x30]
    2d93:	sar    r9,1
    2d96:	mov    QWORD PTR [rsp],rax
    2d9a:	mov    QWORD PTR [rsp+0x8],rdx
    2d9f:	mov    rdx,r11
    2da2:	call   2da7 <botlish_entry_36+0x37>
			2da3: R_X86_64_PLT32	botlish_fn_36-0x4 ; ht_rehash_scan<mutarray, mutarray, mutarray, int, int, HashTable, int>
    2da7:	add    rsp,0x10
    2dab:	mov    rsp,rbp
    2dae:	pop    rbp
    2daf:	ret

0000000000002db0 <botlish_fn_37: ht_rehash<HashTable, int>>:
    2db0:	push   rbp
    2db1:	mov    rbp,rsp
    2db4:	sub    rsp,0xf0
    2dbb:	mov    QWORD PTR [rsp+0xc0],rbx
    2dc3:	mov    QWORD PTR [rsp+0xc8],r12
    2dcb:	mov    QWORD PTR [rsp+0xd0],r13
    2dd3:	mov    QWORD PTR [rsp+0xd8],r14
    2ddb:	mov    QWORD PTR [rsp+0xe0],r15
    2de3:	mov    QWORD PTR [rsp+0x90],rdi
    2deb:	mov    QWORD PTR [rsp+0x20],0x0
    2df4:	mov    QWORD PTR [rsp+0x28],0x0
    2dfd:	mov    QWORD PTR [rsp+0x30],0x0
    2e06:	mov    QWORD PTR [rsp+0x38],0x0
    2e0f:	mov    QWORD PTR [rsp+0x40],0x0
    2e18:	mov    QWORD PTR [rsp+0x48],0x0
    2e21:	mov    QWORD PTR [rsp+0x50],0x0
    2e2a:	mov    QWORD PTR [rsp+0x10],rsi
    2e2f:	mov    r14,rsi
    2e32:	mov    QWORD PTR [rsp+0x18],rdx
    2e37:	mov    QWORD PTR [rsp+0x98],rdx
    2e3f:	lea    rdx,[rsp+0x58]
    2e44:	mov    rsi,QWORD PTR [rsp+0x98]
    2e4c:	mov    rdi,QWORD PTR [rsp+0x90]
    2e54:	call   2e59 <botlish_fn_37+0xa9>
			2e55: R_X86_64_PLT32	botlish_fn_22-0x4 ; ht_alloc<int>
    2e59:	test   rax,rax
    2e5c:	je     2fb0 <botlish_fn_37+0x200>
    2e62:	mov    QWORD PTR [rsp+0x10],rax
    2e67:	mov    QWORD PTR [rsp+0xb8],rax
    2e6f:	mov    rbx,QWORD PTR [rsp+0x58]
    2e74:	mov    QWORD PTR [rsp+0x20],rbx
    2e79:	mov    r12,QWORD PTR [rsp+0x60]
    2e7e:	mov    QWORD PTR [rsp+0x28],r12
    2e83:	mov    r13,QWORD PTR [rsp+0x68]
    2e88:	mov    QWORD PTR [rsp+0x30],r13
    2e8d:	mov    rsi,r14
    2e90:	mov    rdi,QWORD PTR [rsp+0x90]
    2e98:	call   2e9d <botlish_fn_37+0xed>
			2e99: R_X86_64_PLT32	botlish_fn_26-0x4 ; ht_size<HashTable>
    2e9d:	test   rax,rax
    2ea0:	mov    rcx,rax
    2ea3:	je     2fb0 <botlish_fn_37+0x200>
    2ea9:	mov    edx,0x1
    2eae:	mov    rsi,r13
    2eb1:	mov    rdi,QWORD PTR [rsp+0x90]
    2eb9:	call   2ebe <botlish_fn_37+0x10e>
			2eba: R_X86_64_PLT32	rt_mutarray_set-0x4
    2ebe:	test   rax,rax
    2ec1:	je     2fb0 <botlish_fn_37+0x200>
    2ec7:	mov    rsi,r14
    2eca:	mov    rax,QWORD PTR [rsi+0x18]
    2ece:	mov    rcx,QWORD PTR [rax]
    2ed1:	mov    QWORD PTR [rsp+0x38],rcx
    2ed6:	mov    QWORD PTR [rsp+0xb0],rcx
    2ede:	mov    rax,QWORD PTR [rsi+0x18]
    2ee2:	mov    r15,QWORD PTR [rax+0x8]
    2ee6:	mov    QWORD PTR [rsp+0x40],r15
    2eeb:	mov    rax,QWORD PTR [rsi+0x18]
    2eef:	mov    r14,QWORD PTR [rax+0x10]
    2ef3:	mov    QWORD PTR [rsp+0x48],r14
    2ef8:	mov    r8d,0x1
    2efe:	mov    QWORD PTR [rsp+0xa8],r8
    2f06:	mov    QWORD PTR [rsp+0x50],0x1
    2f0f:	mov    rdi,QWORD PTR [rsp+0x90]
    2f17:	call   2f1c <botlish_fn_37+0x16c>
			2f18: R_X86_64_PLT32	botlish_fn_28-0x4 ; ht_capacity<HashTable>
    2f1c:	mov    QWORD PTR [rsp+0xa0],rax
    2f24:	lea    rcx,[rsp+0x70]
    2f29:	mov    rax,QWORD PTR [rsp+0xb8]
    2f31:	mov    QWORD PTR [rsp+0x70],rax
    2f36:	mov    QWORD PTR [rsp+0x78],rbx
    2f3b:	mov    QWORD PTR [rsp+0x80],r12
    2f43:	mov    QWORD PTR [rsp+0x88],r13
    2f4b:	xor    rsi,rsi
    2f4e:	mov    edx,0x4
    2f53:	mov    rdi,QWORD PTR [rsp+0x90]
    2f5b:	call   2f60 <botlish_fn_37+0x1b0>
			2f5c: R_X86_64_PLT32	rt_struct_new-0x4
    2f60:	mov    QWORD PTR [rsp+0x10],rax
    2f65:	mov    rcx,QWORD PTR [rsp+0xa0]
    2f6d:	mov    r9,rcx
    2f70:	sar    r9,1
    2f73:	mov    QWORD PTR [rsp],rax
    2f77:	mov    rdx,QWORD PTR [rsp+0x98]
    2f7f:	mov    QWORD PTR [rsp+0x8],rdx
    2f84:	mov    rcx,r14
    2f87:	mov    rdx,r15
    2f8a:	mov    rsi,QWORD PTR [rsp+0xb0]
    2f92:	mov    rdi,QWORD PTR [rsp+0x90]
    2f9a:	mov    r8,QWORD PTR [rsp+0xa8]
    2fa2:	call   2fa7 <botlish_fn_37+0x1f7>
			2fa3: R_X86_64_PLT32	botlish_fn_36-0x4 ; ht_rehash_scan<mutarray, mutarray, mutarray, int, int, HashTable, int>
    2fa7:	test   rax,rax
    2faa:	jne    2fe7 <botlish_fn_37+0x237>
    2fb0:	xor    rax,rax
    2fb3:	mov    rbx,QWORD PTR [rsp+0xc0]
    2fbb:	mov    r12,QWORD PTR [rsp+0xc8]
    2fc3:	mov    r13,QWORD PTR [rsp+0xd0]
    2fcb:	mov    r14,QWORD PTR [rsp+0xd8]
    2fd3:	mov    r15,QWORD PTR [rsp+0xe0]
    2fdb:	add    rsp,0xf0
    2fe2:	mov    rsp,rbp
    2fe5:	pop    rbp
    2fe6:	ret
    2fe7:	mov    rbx,QWORD PTR [rsp+0xc0]
    2fef:	mov    r12,QWORD PTR [rsp+0xc8]
    2ff7:	mov    r13,QWORD PTR [rsp+0xd0]
    2fff:	mov    r14,QWORD PTR [rsp+0xd8]
    3007:	mov    r15,QWORD PTR [rsp+0xe0]
    300f:	add    rsp,0xf0
    3016:	mov    rsp,rbp
    3019:	pop    rbp
    301a:	ret

000000000000301b <botlish_entry_37: ht_rehash<HashTable, int>>:
    301b:	push   rbp
    301c:	mov    rbp,rsp
    301f:	mov    rsi,QWORD PTR [rdx]
    3022:	mov    rdx,QWORD PTR [rdx+0x8]
    3026:	call   302b <botlish_entry_37+0x10>
			3027: R_X86_64_PLT32	botlish_fn_37-0x4 ; ht_rehash<HashTable, int>
    302b:	mov    rsp,rbp
    302e:	pop    rbp
    302f:	ret

0000000000003030 <botlish_fn_38: ht_should_grow<HashTable>>:
    3030:	push   rbp
    3031:	mov    rbp,rsp
    3034:	sub    rsp,0x40
    3038:	mov    QWORD PTR [rsp+0x20],rbx
    303d:	mov    QWORD PTR [rsp+0x28],r12
    3042:	mov    QWORD PTR [rsp+0x30],r13
    3047:	mov    rbx,rdi
    304a:	mov    QWORD PTR [rsp],rsi
    304e:	mov    r12,rsi
    3051:	mov    rsi,r12
    3054:	mov    rdi,rbx
    3057:	call   305c <botlish_fn_38+0x2c>
			3058: R_X86_64_PLT32	botlish_fn_26-0x4 ; ht_size<HashTable>
    305c:	mov    rcx,rax
    305f:	mov    r13,rax
    3062:	test   rax,rcx
    3065:	je     313e <botlish_fn_38+0x10e>
    306b:	mov    rax,r13
    306e:	mov    QWORD PTR [rsp+0x8],rax
    3073:	mov    rsi,r12
    3076:	mov    rdi,rbx
    3079:	call   307e <botlish_fn_38+0x4e>
			307a: R_X86_64_PLT32	botlish_fn_27-0x4 ; ht_tombstones<HashTable>
    307e:	mov    rcx,rax
    3081:	test   rcx,rcx
    3084:	je     313e <botlish_fn_38+0x10e>
    308a:	mov    QWORD PTR [rsp+0x10],rcx
    308f:	mov    edx,0x1
    3094:	mov    rax,r13
    3097:	test   rax,0x1
    309d:	jne    30c0 <botlish_fn_38+0x90>
    30a3:	xor    edx,edx
    30a5:	mov    rax,r13
    30a8:	test   rax,0x7
    30ae:	jne    30c0 <botlish_fn_38+0x90>
    30b4:	mov    rax,r13
    30b7:	movzx  rax,BYTE PTR [rax]
    30bb:	cmp    al,0x1
    30bd:	sete   dl
    30c0:	test   dl,dl
    30c2:	jne    30e3 <botlish_fn_38+0xb3>
    30c8:	mov    rdi,rbx
    30cb:	mov    rax,QWORD PTR [rdi+0x10]
    30cf:	mov    rcx,QWORD PTR [rax+0x8]
    30d3:	xor    rdx,rdx
    30d6:	mov    rsi,r13
    30d9:	call   30de <botlish_fn_38+0xae>
			30da: R_X86_64_PLT32	rt_type_error-0x4
    30de:	jmp    313e <botlish_fn_38+0x10e>
    30e3:	mov    eax,0x1
    30e8:	test   rcx,0x1
    30ef:	je     30fd <botlish_fn_38+0xcd>
    30f5:	mov    r8,rcx
    30f8:	jmp    3120 <botlish_fn_38+0xf0>
    30fd:	xor    eax,eax
    30ff:	test   rcx,0x7
    3106:	je     3114 <botlish_fn_38+0xe4>
    310c:	mov    r8,rcx
    310f:	jmp    3120 <botlish_fn_38+0xf0>
    3114:	movzx  rax,BYTE PTR [rcx]
    3118:	mov    r8,rcx
    311b:	cmp    al,0x1
    311d:	sete   al
    3120:	test   al,al
    3122:	jne    3159 <botlish_fn_38+0x129>
    3128:	mov    rdi,rbx
    312b:	mov    rax,QWORD PTR [rdi+0x10]
    312f:	mov    rcx,QWORD PTR [rax+0x8]
    3133:	xor    rdx,rdx
    3136:	mov    rsi,r8
    3139:	call   313e <botlish_fn_38+0x10e>
			313a: R_X86_64_PLT32	rt_type_error-0x4
    313e:	xor    rax,rax
    3141:	mov    rbx,QWORD PTR [rsp+0x20]
    3146:	mov    r12,QWORD PTR [rsp+0x28]
    314b:	mov    r13,QWORD PTR [rsp+0x30]
    3150:	add    rsp,0x40
    3154:	mov    rsp,rbp
    3157:	pop    rbp
    3158:	ret
    3159:	mov    rcx,r8
    315c:	mov    rsi,r13
    315f:	mov    rax,rsi
    3162:	and    rax,rcx
    3165:	test   rax,0x1
    316b:	jne    317c <botlish_fn_38+0x14c>
    3171:	mov    rdx,r8
    3174:	mov    rsi,r13
    3177:	jmp    319a <botlish_fn_38+0x16a>
    317c:	mov    rcx,r8
    317f:	lea    rax,[rcx-0x1]
    3183:	mov    rsi,r13
    3186:	add    rsi,rax
    3189:	seto   al
    318c:	test   al,al
    318e:	je     31a5 <botlish_fn_38+0x175>
    3194:	mov    rdx,r8
    3197:	mov    rsi,r13
    319a:	mov    rdi,rbx
    319d:	call   31a2 <botlish_fn_38+0x172>
			319e: R_X86_64_PLT32	rt_int_add-0x4
    31a2:	mov    rsi,rax
    31a5:	mov    QWORD PTR [rsp+0x8],rsi
    31aa:	mov    QWORD PTR [rsp+0x10],0x3
    31b3:	test   rsi,0x1
    31ba:	je     31dd <botlish_fn_38+0x1ad>
    31c0:	mov    rax,rsi
    31c3:	add    rax,0x2
    31c7:	mov    rcx,rax
    31ca:	seto   al
    31cd:	test   al,al
    31cf:	jne    31dd <botlish_fn_38+0x1ad>
    31d5:	mov    rsi,rcx
    31d8:	jmp    31ed <botlish_fn_38+0x1bd>
    31dd:	mov    edx,0x3
    31e2:	mov    rdi,rbx
    31e5:	call   31ea <botlish_fn_38+0x1ba>
			31e6: R_X86_64_PLT32	rt_int_add-0x4
    31ea:	mov    rsi,rax
    31ed:	mov    QWORD PTR [rsp+0x8],rsi
    31f2:	mov    edx,0x7
    31f7:	mov    rdi,rdx
    31fa:	mov    QWORD PTR [rsp+0x10],0x7
    3203:	test   rsi,0x1
    320a:	jne    3218 <botlish_fn_38+0x1e8>
    3210:	mov    rdx,rdi
    3213:	jmp    3244 <botlish_fn_38+0x214>
    3218:	mov    rax,rsi
    321b:	sar    rax,1
    321e:	imul   QWORD PTR [rip+0xf3]        # 3318 <botlish_fn_38+0x2e8>
    3225:	seto   cl
    3228:	or     rax,0x1
    322c:	test   cl,cl
    322e:	je     323c <botlish_fn_38+0x20c>
    3234:	mov    rdx,rdi
    3237:	jmp    3244 <botlish_fn_38+0x214>
    323c:	mov    rsi,rax
    323f:	jmp    324f <botlish_fn_38+0x21f>
    3244:	mov    rdi,rbx
    3247:	call   324c <botlish_fn_38+0x21c>
			3248: R_X86_64_PLT32	rt_int_mul-0x4
    324c:	mov    rsi,rax
    324f:	mov    QWORD PTR [rsp],rsi
    3253:	mov    r13,rsi
    3256:	mov    rsi,r12
    3259:	mov    rdi,rbx
    325c:	call   3261 <botlish_fn_38+0x231>
			325d: R_X86_64_PLT32	botlish_fn_28-0x4 ; ht_capacity<HashTable>
    3261:	mov    QWORD PTR [rsp+0x8],rax
    3266:	mov    QWORD PTR [rsp+0x10],0x5
    326f:	test   rax,0x1
    3275:	mov    rcx,rax
    3278:	je     32a7 <botlish_fn_38+0x277>
    327e:	mov    rax,rcx
    3281:	sar    rax,1
    3284:	imul   QWORD PTR [rip+0x95]        # 3320 <botlish_fn_38+0x2f0>
    328b:	seto   sil
    328f:	or     rax,0x1
    3293:	test   sil,sil
    3296:	jne    32a7 <botlish_fn_38+0x277>
    329c:	mov    rdx,rax
    329f:	mov    rsi,r13
    32a2:	jmp    32bd <botlish_fn_38+0x28d>
    32a7:	mov    edx,0x5
    32ac:	mov    rsi,rcx
    32af:	mov    rdi,rbx
    32b2:	call   32b7 <botlish_fn_38+0x287>
			32b3: R_X86_64_PLT32	rt_int_mul-0x4
    32b7:	mov    rdx,rax
    32ba:	mov    rsi,r13
    32bd:	mov    rdi,rsi
    32c0:	and    rdi,rdx
    32c3:	test   rdi,0x1
    32ca:	jne    32f0 <botlish_fn_38+0x2c0>
    32d0:	mov    rdi,rbx
    32d3:	call   32d8 <botlish_fn_38+0x2a8>
			32d4: R_X86_64_PLT32	rt_int_cmp-0x4
    32d8:	mov    esi,0x2
    32dd:	test   rax,rax
    32e0:	mov    rax,rsi
    32e3:	cmovg  rax,QWORD PTR [rip+0x2d]        # 3318 <botlish_fn_38+0x2e8>
    32eb:	jmp    3300 <botlish_fn_38+0x2d0>
    32f0:	mov    eax,0x2
    32f5:	cmp    rsi,rdx
    32f8:	cmovg  rax,QWORD PTR [rip+0x18]        # 3318 <botlish_fn_38+0x2e8>
    3300:	mov    rbx,QWORD PTR [rsp+0x20]
    3305:	mov    r12,QWORD PTR [rsp+0x28]
    330a:	mov    r13,QWORD PTR [rsp+0x30]
    330f:	add    rsp,0x40
    3313:	mov    rsp,rbp
    3316:	pop    rbp
    3317:	ret
    3318:	(bad)
    3319:	add    BYTE PTR [rax],al
    331b:	add    BYTE PTR [rax],al
    331d:	add    BYTE PTR [rax],al
    331f:	add    BYTE PTR [rax+rax*1],al
    3322:	add    BYTE PTR [rax],al
    3324:	add    BYTE PTR [rax],al
	...

0000000000003328 <botlish_entry_38: ht_should_grow<HashTable>>:
    3328:	push   rbp
    3329:	mov    rbp,rsp
    332c:	mov    rsi,QWORD PTR [rdx]
    332f:	call   3334 <botlish_entry_38+0xc>
			3330: R_X86_64_PLT32	botlish_fn_38-0x4 ; ht_should_grow<HashTable>
    3334:	mov    rsp,rbp
    3337:	pop    rbp
    3338:	ret
    3339:	add    BYTE PTR [rax],al
    333b:	add    BYTE PTR [rax],al
    333d:	add    BYTE PTR [rax],al
	...

0000000000003340 <botlish_fn_39: ht_grow_or_clean<HashTable>>:
    3340:	push   rbp
    3341:	mov    rbp,rsp
    3344:	sub    rsp,0x40
    3348:	mov    QWORD PTR [rsp+0x20],rbx
    334d:	mov    QWORD PTR [rsp+0x28],r12
    3352:	mov    QWORD PTR [rsp+0x30],r13
    3357:	mov    rbx,rdi
    335a:	mov    QWORD PTR [rsp+0x10],0x0
    3363:	mov    QWORD PTR [rsp],rsi
    3367:	mov    r12,rsi
    336a:	mov    rsi,r12
    336d:	mov    rdi,rbx
    3370:	call   3375 <botlish_fn_39+0x35>
			3371: R_X86_64_PLT32	botlish_fn_27-0x4 ; ht_tombstones<HashTable>
    3375:	test   rax,rax
    3378:	mov    r13,rax
    337b:	je     3569 <botlish_fn_39+0x229>
    3381:	mov    rsi,r12
    3384:	mov    rdi,rbx
    3387:	call   338c <botlish_fn_39+0x4c>
			3388: R_X86_64_PLT32	botlish_fn_26-0x4 ; ht_size<HashTable>
    338c:	mov    r11,rax
    338f:	test   r11,r11
    3392:	je     3569 <botlish_fn_39+0x229>
    3398:	mov    ecx,0x1
    339d:	mov    rax,r13
    33a0:	test   rax,0x1
    33a6:	je     33b4 <botlish_fn_39+0x74>
    33ac:	mov    r13,rax
    33af:	jmp    33d8 <botlish_fn_39+0x98>
    33b4:	xor    ecx,ecx
    33b6:	test   rax,0x7
    33bc:	je     33ca <botlish_fn_39+0x8a>
    33c2:	mov    r13,rax
    33c5:	jmp    33d8 <botlish_fn_39+0x98>
    33ca:	movzx  rcx,BYTE PTR [rax]
    33ce:	mov    r13,rax
    33d1:	rex cmp cl,0x1
    33d5:	sete   cl
    33d8:	test   cl,cl
    33da:	jne    33fb <botlish_fn_39+0xbb>
    33e0:	mov    rdi,rbx
    33e3:	mov    rsi,QWORD PTR [rdi+0x10]
    33e7:	mov    rcx,QWORD PTR [rsi+0x10]
    33eb:	xor    rdx,rdx
    33ee:	mov    rsi,r13
    33f1:	call   33f6 <botlish_fn_39+0xb6>
			33f2: R_X86_64_PLT32	rt_type_error-0x4
    33f6:	jmp    3569 <botlish_fn_39+0x229>
    33fb:	mov    rsi,r13
    33fe:	mov    eax,0x1
    3403:	test   r11,0x1
    340a:	je     3418 <botlish_fn_39+0xd8>
    3410:	mov    r8,r11
    3413:	jmp    343d <botlish_fn_39+0xfd>
    3418:	xor    eax,eax
    341a:	test   r11,0x7
    3421:	je     342f <botlish_fn_39+0xef>
    3427:	mov    r8,r11
    342a:	jmp    343d <botlish_fn_39+0xfd>
    342f:	movzx  r10,BYTE PTR [r11]
    3433:	mov    r8,r11
    3436:	cmp    r10b,0x1
    343a:	sete   al
    343d:	test   al,al
    343f:	jne    3460 <botlish_fn_39+0x120>
    3445:	mov    rdi,rbx
    3448:	mov    rax,QWORD PTR [rdi+0x10]
    344c:	mov    rcx,QWORD PTR [rax+0x10]
    3450:	xor    rdx,rdx
    3453:	mov    rsi,r8
    3456:	call   345b <botlish_fn_39+0x11b>
			3457: R_X86_64_PLT32	rt_type_error-0x4
    345b:	jmp    3569 <botlish_fn_39+0x229>
    3460:	mov    r11,r8
    3463:	mov    rax,rsi
    3466:	and    rax,r11
    3469:	test   rax,0x1
    346f:	jne    3495 <botlish_fn_39+0x155>
    3475:	mov    rdx,r8
    3478:	mov    rdi,rbx
    347b:	call   3480 <botlish_fn_39+0x140>
			347c: R_X86_64_PLT32	rt_int_cmp-0x4
    3480:	mov    ecx,0x2
    3485:	test   rax,rax
    3488:	cmovg  rcx,QWORD PTR [rip+0x110]        # 35a0 <botlish_fn_39+0x260>
    3490:	jmp    34a8 <botlish_fn_39+0x168>
    3495:	mov    ecx,0x2
    349a:	mov    r11,r8
    349d:	cmp    rsi,r11
    34a0:	cmovg  rcx,QWORD PTR [rip+0xf8]        # 35a0 <botlish_fn_39+0x260>
    34a8:	cmp    rcx,0x6
    34ac:	je     3542 <botlish_fn_39+0x202>
    34b2:	mov    rsi,r12
    34b5:	mov    rdi,rbx
    34b8:	call   34bd <botlish_fn_39+0x17d>
			34b9: R_X86_64_PLT32	botlish_fn_28-0x4 ; ht_capacity<HashTable>
    34bd:	mov    QWORD PTR [rsp+0x8],rax
    34c2:	mov    QWORD PTR [rsp+0x10],0x5
    34cb:	test   rax,0x1
    34d1:	mov    rsi,rax
    34d4:	je     3501 <botlish_fn_39+0x1c1>
    34da:	mov    rcx,rsi
    34dd:	mov    rax,rcx
    34e0:	sar    rax,1
    34e3:	imul   QWORD PTR [rip+0xbe]        # 35a8 <botlish_fn_39+0x268>
    34ea:	seto   cl
    34ed:	or     rax,0x1
    34f1:	test   cl,cl
    34f3:	jne    3501 <botlish_fn_39+0x1c1>
    34f9:	mov    rdx,rax
    34fc:	jmp    3511 <botlish_fn_39+0x1d1>
    3501:	mov    edx,0x5
    3506:	mov    rdi,rbx
    3509:	call   350e <botlish_fn_39+0x1ce>
			350a: R_X86_64_PLT32	rt_int_mul-0x4
    350e:	mov    rdx,rax
    3511:	mov    QWORD PTR [rsp+0x8],rdx
    3516:	mov    rsi,r12
    3519:	mov    rdi,rbx
    351c:	call   3521 <botlish_fn_39+0x1e1>
			351d: R_X86_64_PLT32	botlish_fn_37-0x4 ; ht_rehash<HashTable, int>
    3521:	test   rax,rax
    3524:	je     3569 <botlish_fn_39+0x229>
    352a:	mov    rbx,QWORD PTR [rsp+0x20]
    352f:	mov    r12,QWORD PTR [rsp+0x28]
    3534:	mov    r13,QWORD PTR [rsp+0x30]
    3539:	add    rsp,0x40
    353d:	mov    rsp,rbp
    3540:	pop    rbp
    3541:	ret
    3542:	mov    rsi,r12
    3545:	mov    rdi,rbx
    3548:	call   354d <botlish_fn_39+0x20d>
			3549: R_X86_64_PLT32	botlish_fn_28-0x4 ; ht_capacity<HashTable>
    354d:	mov    QWORD PTR [rsp+0x8],rax
    3552:	mov    rdx,rax
    3555:	mov    rsi,r12
    3558:	mov    rdi,rbx
    355b:	call   3560 <botlish_fn_39+0x220>
			355c: R_X86_64_PLT32	botlish_fn_37-0x4 ; ht_rehash<HashTable, int>
    3560:	test   rax,rax
    3563:	jne    3584 <botlish_fn_39+0x244>
    3569:	xor    rax,rax
    356c:	mov    rbx,QWORD PTR [rsp+0x20]
    3571:	mov    r12,QWORD PTR [rsp+0x28]
    3576:	mov    r13,QWORD PTR [rsp+0x30]
    357b:	add    rsp,0x40
    357f:	mov    rsp,rbp
    3582:	pop    rbp
    3583:	ret
    3584:	mov    rbx,QWORD PTR [rsp+0x20]
    3589:	mov    r12,QWORD PTR [rsp+0x28]
    358e:	mov    r13,QWORD PTR [rsp+0x30]
    3593:	add    rsp,0x40
    3597:	mov    rsp,rbp
    359a:	pop    rbp
    359b:	ret
    359c:	add    BYTE PTR [rax],al
    359e:	add    BYTE PTR [rax],al
    35a0:	(bad)
    35a1:	add    BYTE PTR [rax],al
    35a3:	add    BYTE PTR [rax],al
    35a5:	add    BYTE PTR [rax],al
    35a7:	add    BYTE PTR [rax+rax*1],al
    35aa:	add    BYTE PTR [rax],al
    35ac:	add    BYTE PTR [rax],al
	...

00000000000035b0 <botlish_entry_39: ht_grow_or_clean<HashTable>>:
    35b0:	push   rbp
    35b1:	mov    rbp,rsp
    35b4:	mov    rsi,QWORD PTR [rdx]
    35b7:	call   35bc <botlish_entry_39+0xc>
			35b8: R_X86_64_PLT32	botlish_fn_39-0x4 ; ht_grow_or_clean<HashTable>
    35bc:	mov    rsp,rbp
    35bf:	pop    rbp
    35c0:	ret
    35c1:	add    BYTE PTR [rax],al
    35c3:	add    BYTE PTR [rax],al
    35c5:	add    BYTE PTR [rax],al
	...

00000000000035c8 <botlish_fn_40: ht_place<HashTable, int, str, str>>:
    35c8:	push   rbp
    35c9:	mov    rbp,rsp
    35cc:	sub    rsp,0x70
    35d0:	mov    QWORD PTR [rsp+0x40],rbx
    35d5:	mov    QWORD PTR [rsp+0x48],r12
    35da:	mov    QWORD PTR [rsp+0x50],r13
    35df:	mov    QWORD PTR [rsp+0x58],r14
    35e4:	mov    QWORD PTR [rsp+0x60],r15
    35e9:	mov    r12,rdi
    35ec:	mov    r14,r8
    35ef:	mov    r15,rdx
    35f2:	mov    QWORD PTR [rsp+0x30],rcx
    35f7:	mov    QWORD PTR [rsp],rsi
    35fb:	mov    r9,QWORD PTR [rsi+0x18]
    35ff:	mov    r13,rsi
    3602:	mov    rsi,QWORD PTR [r9]
    3605:	mov    rdx,r15
    3608:	mov    rdi,r12
    360b:	call   3610 <botlish_fn_40+0x48>
			360c: R_X86_64_PLT32	rt_mutarray_get-0x4
    3610:	test   rax,rax
    3613:	je     38a8 <botlish_fn_40+0x2e0>
    3619:	mov    QWORD PTR [rsp+0x8],rax
    361e:	mov    rbx,r13
    3621:	mov    r13,rax
    3624:	mov    rax,QWORD PTR [rbx+0x18]
    3628:	mov    rsi,QWORD PTR [rax]
    362b:	mov    ecx,0x3
    3630:	mov    rdx,r15
    3633:	mov    rdi,r12
    3636:	call   363b <botlish_fn_40+0x73>
			3637: R_X86_64_PLT32	rt_mutarray_set-0x4
    363b:	test   rax,rax
    363e:	je     38a8 <botlish_fn_40+0x2e0>
    3644:	mov    rax,QWORD PTR [rbx+0x18]
    3648:	mov    rsi,QWORD PTR [rax+0x8]
    364c:	mov    rcx,QWORD PTR [rsp+0x30]
    3651:	mov    rdx,r15
    3654:	mov    rdi,r12
    3657:	call   365c <botlish_fn_40+0x94>
			3658: R_X86_64_PLT32	rt_mutarray_set-0x4
    365c:	test   rax,rax
    365f:	je     38a8 <botlish_fn_40+0x2e0>
    3665:	mov    rax,QWORD PTR [rbx+0x18]
    3669:	mov    rsi,QWORD PTR [rax+0x10]
    366d:	mov    rcx,r14
    3670:	mov    rdx,r15
    3673:	mov    rdi,r12
    3676:	call   367b <botlish_fn_40+0xb3>
			3677: R_X86_64_PLT32	rt_mutarray_set-0x4
    367b:	test   rax,rax
    367e:	je     38a8 <botlish_fn_40+0x2e0>
    3684:	mov    rax,QWORD PTR [rbx+0x18]
    3688:	mov    rsi,QWORD PTR [rax+0x18]
    368c:	mov    QWORD PTR [rsp+0x10],rsi
    3691:	mov    r14,rsi
    3694:	mov    QWORD PTR [rsp+0x18],0x1
    369d:	mov    rsi,rbx
    36a0:	mov    rdi,r12
    36a3:	call   36a8 <botlish_fn_40+0xe0>
			36a4: R_X86_64_PLT32	botlish_fn_26-0x4 ; ht_size<HashTable>
    36a8:	test   rax,rax
    36ab:	je     38a8 <botlish_fn_40+0x2e0>
    36b1:	mov    QWORD PTR [rsp+0x20],rax
    36b6:	mov    QWORD PTR [rsp+0x28],0x3
    36bf:	mov    ecx,0x1
    36c4:	test   rax,0x1
    36ca:	je     36d8 <botlish_fn_40+0x110>
    36d0:	mov    rsi,rax
    36d3:	jmp    36fc <botlish_fn_40+0x134>
    36d8:	xor    ecx,ecx
    36da:	test   rax,0x7
    36e0:	je     36ee <botlish_fn_40+0x126>
    36e6:	mov    rsi,rax
    36e9:	jmp    36fc <botlish_fn_40+0x134>
    36ee:	movzx  rcx,BYTE PTR [rax]
    36f2:	mov    rsi,rax
    36f5:	rex cmp cl,0x1
    36f9:	sete   cl
    36fc:	test   cl,cl
    36fe:	jne    371c <botlish_fn_40+0x154>
    3704:	mov    rdi,r12
    3707:	mov    rax,QWORD PTR [rdi+0x10]
    370b:	mov    rcx,QWORD PTR [rax+0x8]
    370f:	xor    rdx,rdx
    3712:	call   3717 <botlish_fn_40+0x14f>
			3713: R_X86_64_PLT32	rt_type_error-0x4
    3717:	jmp    38a8 <botlish_fn_40+0x2e0>
    371c:	test   rsi,0x1
    3723:	je     373b <botlish_fn_40+0x173>
    3729:	mov    rcx,rsi
    372c:	add    rcx,0x2
    3730:	seto   al
    3733:	test   al,al
    3735:	je     374b <botlish_fn_40+0x183>
    373b:	mov    edx,0x3
    3740:	mov    rdi,r12
    3743:	call   3748 <botlish_fn_40+0x180>
			3744: R_X86_64_PLT32	rt_int_add-0x4
    3748:	mov    rcx,rax
    374b:	mov    edx,0x1
    3750:	mov    rsi,r14
    3753:	mov    rdi,r12
    3756:	call   375b <botlish_fn_40+0x193>
			3757: R_X86_64_PLT32	rt_mutarray_set-0x4
    375b:	test   rax,rax
    375e:	je     38a8 <botlish_fn_40+0x2e0>
    3764:	mov    rax,r13
    3767:	test   rax,0x1
    376d:	jne    3798 <botlish_fn_40+0x1d0>
    3773:	mov    edx,0x5
    3778:	mov    rsi,r13
    377b:	mov    rdi,r12
    377e:	call   3783 <botlish_fn_40+0x1bb>
			377f: R_X86_64_PLT32	rt_int_cmp-0x4
    3783:	mov    ecx,0x2
    3788:	test   rax,rax
    378b:	cmove  rcx,QWORD PTR [rip+0x165]        # 38f8 <botlish_fn_40+0x330>
    3793:	jmp    37ac <botlish_fn_40+0x1e4>
    3798:	mov    rsi,r13
    379b:	mov    ecx,0x2
    37a0:	cmp    rsi,0x5
    37a4:	cmove  rcx,QWORD PTR [rip+0x14c]        # 38f8 <botlish_fn_40+0x330>
    37ac:	cmp    rcx,0x6
    37b0:	je     37be <botlish_fn_40+0x1f6>
    37b6:	mov    rax,rbx
    37b9:	jmp    38d0 <botlish_fn_40+0x308>
    37be:	mov    rax,QWORD PTR [rbx+0x18]
    37c2:	mov    rsi,QWORD PTR [rax+0x18]
    37c6:	mov    QWORD PTR [rsp+0x8],rsi
    37cb:	mov    r14,rsi
    37ce:	mov    QWORD PTR [rsp+0x10],0x3
    37d7:	mov    rsi,rbx
    37da:	mov    rdi,r12
    37dd:	call   37e2 <botlish_fn_40+0x21a>
			37de: R_X86_64_PLT32	botlish_fn_27-0x4 ; ht_tombstones<HashTable>
    37e2:	mov    r13,rbx
    37e5:	test   rax,rax
    37e8:	je     38a8 <botlish_fn_40+0x2e0>
    37ee:	mov    QWORD PTR [rsp+0x18],rax
    37f3:	mov    QWORD PTR [rsp+0x20],0x3
    37fc:	mov    ecx,0x1
    3801:	test   rax,0x1
    3807:	je     3815 <botlish_fn_40+0x24d>
    380d:	mov    rsi,rax
    3810:	jmp    3839 <botlish_fn_40+0x271>
    3815:	xor    ecx,ecx
    3817:	test   rax,0x7
    381d:	je     382b <botlish_fn_40+0x263>
    3823:	mov    rsi,rax
    3826:	jmp    3839 <botlish_fn_40+0x271>
    382b:	movzx  r10,BYTE PTR [rax]
    382f:	mov    rsi,rax
    3832:	cmp    r10b,0x1
    3836:	sete   cl
    3839:	test   cl,cl
    383b:	jne    3859 <botlish_fn_40+0x291>
    3841:	mov    rdi,r12
    3844:	mov    rax,QWORD PTR [rdi+0x10]
    3848:	mov    rcx,QWORD PTR [rax+0x18]
    384c:	xor    rdx,rdx
    384f:	call   3854 <botlish_fn_40+0x28c>
			3850: R_X86_64_PLT32	rt_type_error-0x4
    3854:	jmp    38a8 <botlish_fn_40+0x2e0>
    3859:	test   rsi,0x1
    3860:	je     387f <botlish_fn_40+0x2b7>
    3866:	mov    rcx,rsi
    3869:	sub    rcx,0x3
    386d:	seto   al
    3870:	add    rcx,0x1
    3877:	test   al,al
    3879:	je     388f <botlish_fn_40+0x2c7>
    387f:	mov    edx,0x3
    3884:	mov    rdi,r12
    3887:	call   388c <botlish_fn_40+0x2c4>
			3888: R_X86_64_PLT32	rt_int_sub-0x4
    388c:	mov    rcx,rax
    388f:	mov    edx,0x3
    3894:	mov    rsi,r14
    3897:	mov    rdi,r12
    389a:	call   389f <botlish_fn_40+0x2d7>
			389b: R_X86_64_PLT32	rt_mutarray_set-0x4
    389f:	test   rax,rax
    38a2:	jne    38cd <botlish_fn_40+0x305>
    38a8:	xor    rax,rax
    38ab:	mov    rbx,QWORD PTR [rsp+0x40]
    38b0:	mov    r12,QWORD PTR [rsp+0x48]
    38b5:	mov    r13,QWORD PTR [rsp+0x50]
    38ba:	mov    r14,QWORD PTR [rsp+0x58]
    38bf:	mov    r15,QWORD PTR [rsp+0x60]
    38c4:	add    rsp,0x70
    38c8:	mov    rsp,rbp
    38cb:	pop    rbp
    38cc:	ret
    38cd:	mov    rax,r13
    38d0:	mov    rbx,QWORD PTR [rsp+0x40]
    38d5:	mov    r12,QWORD PTR [rsp+0x48]
    38da:	mov    r13,QWORD PTR [rsp+0x50]
    38df:	mov    r14,QWORD PTR [rsp+0x58]
    38e4:	mov    r15,QWORD PTR [rsp+0x60]
    38e9:	add    rsp,0x70
    38ed:	mov    rsp,rbp
    38f0:	pop    rbp
    38f1:	ret
    38f2:	add    BYTE PTR [rax],al
    38f4:	add    BYTE PTR [rax],al
    38f6:	add    BYTE PTR [rax],al
    38f8:	(bad)
    38f9:	add    BYTE PTR [rax],al
    38fb:	add    BYTE PTR [rax],al
    38fd:	add    BYTE PTR [rax],al
	...

0000000000003900 <botlish_entry_40: ht_place<HashTable, int, str, str>>:
    3900:	push   rbp
    3901:	mov    rbp,rsp
    3904:	mov    rsi,QWORD PTR [rdx]
    3907:	mov    r9,QWORD PTR [rdx+0x8]
    390b:	mov    rcx,QWORD PTR [rdx+0x10]
    390f:	mov    r8,QWORD PTR [rdx+0x18]
    3913:	mov    rdx,r9
    3916:	call   391b <botlish_entry_40+0x1b>
			3917: R_X86_64_PLT32	botlish_fn_40-0x4 ; ht_place<HashTable, int, str, str>
    391b:	mov    rsp,rbp
    391e:	pop    rbp
    391f:	ret

0000000000003920 <botlish_fn_41: ht_set<HashTable, str, str>>:
    3920:	push   rbp
    3921:	mov    rbp,rsp
    3924:	sub    rsp,0x60
    3928:	mov    QWORD PTR [rsp+0x30],rbx
    392d:	mov    QWORD PTR [rsp+0x38],r12
    3932:	mov    QWORD PTR [rsp+0x40],r13
    3937:	mov    QWORD PTR [rsp+0x48],r14
    393c:	mov    QWORD PTR [rsp+0x50],r15
    3941:	mov    r12,rdi
    3944:	mov    QWORD PTR [rsp+0x18],0x0
    394d:	mov    QWORD PTR [rsp+0x20],0x0
    3956:	mov    QWORD PTR [rsp],rsi
    395a:	mov    r14,rsi
    395d:	mov    QWORD PTR [rsp+0x8],rdx
    3962:	mov    r13,rdx
    3965:	mov    QWORD PTR [rsp+0x10],rcx
    396a:	mov    rbx,rcx
    396d:	mov    rdx,r13
    3970:	mov    rsi,r14
    3973:	mov    rdi,r12
    3976:	call   397b <botlish_fn_41+0x5b>
			3977: R_X86_64_PLT32	botlish_fn_29-0x4 ; ht_probe_start<HashTable, str>
    397b:	test   rax,rax
    397e:	je     3b56 <botlish_fn_41+0x236>
    3984:	mov    QWORD PTR [rsp+0x18],rax
    3989:	mov    rcx,rax
    398c:	mov    r8,0xffffffffffffffff
    3993:	mov    r15,r8
    3996:	mov    QWORD PTR [rsp+0x20],0xffffffffffffffff
    399f:	mov    rdx,r13
    39a2:	mov    rsi,r14
    39a5:	mov    rdi,r12
    39a8:	call   39ad <botlish_fn_41+0x8d>
			39a9: R_X86_64_PLT32	botlish_fn_32-0x4 ; ht_find_insert<HashTable, str, int, int>
    39ad:	test   rax,rax
    39b0:	je     3b56 <botlish_fn_41+0x236>
    39b6:	mov    QWORD PTR [rsp+0x18],rax
    39bb:	mov    rsi,r14
    39be:	mov    QWORD PTR [rsp+0x28],rax
    39c3:	mov    rax,QWORD PTR [rsi+0x18]
    39c7:	mov    rsi,QWORD PTR [rax]
    39ca:	mov    rdx,QWORD PTR [rsp+0x28]
    39cf:	mov    rdi,r12
    39d2:	call   39d7 <botlish_fn_41+0xb7>
			39d3: R_X86_64_PLT32	rt_mutarray_get-0x4
    39d7:	test   rax,rax
    39da:	je     3b56 <botlish_fn_41+0x236>
    39e0:	test   rax,0x1
    39e6:	mov    rsi,rax
    39e9:	jne    3a11 <botlish_fn_41+0xf1>
    39ef:	mov    edx,0x3
    39f4:	mov    rdi,r12
    39f7:	call   39fc <botlish_fn_41+0xdc>
			39f8: R_X86_64_PLT32	rt_int_cmp-0x4
    39fc:	mov    ecx,0x2
    3a01:	test   rax,rax
    3a04:	cmove  rcx,QWORD PTR [rip+0x194]        # 3ba0 <botlish_fn_41+0x280>
    3a0c:	jmp    3a22 <botlish_fn_41+0x102>
    3a11:	mov    ecx,0x2
    3a16:	cmp    rsi,0x3
    3a1a:	cmove  rcx,QWORD PTR [rip+0x17e]        # 3ba0 <botlish_fn_41+0x280>
    3a22:	cmp    rcx,0x6
    3a26:	je     3b32 <botlish_fn_41+0x212>
    3a2c:	mov    rsi,r14
    3a2f:	mov    rdi,r12
    3a32:	call   3a37 <botlish_fn_41+0x117>
			3a33: R_X86_64_PLT32	botlish_fn_38-0x4 ; ht_should_grow<HashTable>
    3a37:	test   rax,rax
    3a3a:	je     3b56 <botlish_fn_41+0x236>
    3a40:	cmp    rax,0x6
    3a44:	je     3a8b <botlish_fn_41+0x16b>
    3a4a:	mov    rcx,r13
    3a4d:	mov    rdx,QWORD PTR [rsp+0x28]
    3a52:	mov    rsi,r14
    3a55:	mov    rdi,r12
    3a58:	mov    r8,rbx
    3a5b:	call   3a60 <botlish_fn_41+0x140>
			3a5c: R_X86_64_PLT32	botlish_fn_40-0x4 ; ht_place<HashTable, int, str, str>
    3a60:	test   rax,rax
    3a63:	je     3b56 <botlish_fn_41+0x236>
    3a69:	mov    rbx,QWORD PTR [rsp+0x30]
    3a6e:	mov    r12,QWORD PTR [rsp+0x38]
    3a73:	mov    r13,QWORD PTR [rsp+0x40]
    3a78:	mov    r14,QWORD PTR [rsp+0x48]
    3a7d:	mov    r15,QWORD PTR [rsp+0x50]
    3a82:	add    rsp,0x60
    3a86:	mov    rsp,rbp
    3a89:	pop    rbp
    3a8a:	ret
    3a8b:	mov    rsi,r14
    3a8e:	mov    rdi,r12
    3a91:	call   3a96 <botlish_fn_41+0x176>
			3a92: R_X86_64_PLT32	botlish_fn_39-0x4 ; ht_grow_or_clean<HashTable>
    3a96:	mov    rcx,rax
    3a99:	mov    r14,rax
    3a9c:	test   rax,rcx
    3a9f:	je     3b56 <botlish_fn_41+0x236>
    3aa5:	mov    rax,r14
    3aa8:	mov    QWORD PTR [rsp],rax
    3aac:	mov    rdx,r13
    3aaf:	mov    rsi,r14
    3ab2:	mov    rdi,r12
    3ab5:	call   3aba <botlish_fn_41+0x19a>
			3ab6: R_X86_64_PLT32	botlish_fn_29-0x4 ; ht_probe_start<HashTable, str>
    3aba:	test   rax,rax
    3abd:	je     3b56 <botlish_fn_41+0x236>
    3ac3:	mov    QWORD PTR [rsp+0x18],rax
    3ac8:	mov    rcx,rax
    3acb:	mov    QWORD PTR [rsp+0x20],0xffffffffffffffff
    3ad4:	mov    r8,r15
    3ad7:	mov    rdx,r13
    3ada:	mov    rsi,r14
    3add:	mov    rdi,r12
    3ae0:	call   3ae5 <botlish_fn_41+0x1c5>
			3ae1: R_X86_64_PLT32	botlish_fn_32-0x4 ; ht_find_insert<HashTable, str, int, int>
    3ae5:	test   rax,rax
    3ae8:	je     3b56 <botlish_fn_41+0x236>
    3aee:	mov    QWORD PTR [rsp+0x18],rax
    3af3:	mov    rcx,r13
    3af6:	mov    rdx,rax
    3af9:	mov    rsi,r14
    3afc:	mov    rdi,r12
    3aff:	mov    r8,rbx
    3b02:	call   3b07 <botlish_fn_41+0x1e7>
			3b03: R_X86_64_PLT32	botlish_fn_40-0x4 ; ht_place<HashTable, int, str, str>
    3b07:	test   rax,rax
    3b0a:	je     3b56 <botlish_fn_41+0x236>
    3b10:	mov    rbx,QWORD PTR [rsp+0x30]
    3b15:	mov    r12,QWORD PTR [rsp+0x38]
    3b1a:	mov    r13,QWORD PTR [rsp+0x40]
    3b1f:	mov    r14,QWORD PTR [rsp+0x48]
    3b24:	mov    r15,QWORD PTR [rsp+0x50]
    3b29:	add    rsp,0x60
    3b2d:	mov    rsp,rbp
    3b30:	pop    rbp
    3b31:	ret
    3b32:	mov    rdx,QWORD PTR [rsp+0x28]
    3b37:	mov    rsi,r14
    3b3a:	mov    rax,QWORD PTR [rsi+0x18]
    3b3e:	mov    rsi,QWORD PTR [rax+0x10]
    3b42:	mov    rcx,rbx
    3b45:	mov    rdi,r12
    3b48:	call   3b4d <botlish_fn_41+0x22d>
			3b49: R_X86_64_PLT32	rt_mutarray_set-0x4
    3b4d:	test   rax,rax
    3b50:	jne    3b7b <botlish_fn_41+0x25b>
    3b56:	xor    rax,rax
    3b59:	mov    rbx,QWORD PTR [rsp+0x30]
    3b5e:	mov    r12,QWORD PTR [rsp+0x38]
    3b63:	mov    r13,QWORD PTR [rsp+0x40]
    3b68:	mov    r14,QWORD PTR [rsp+0x48]
    3b6d:	mov    r15,QWORD PTR [rsp+0x50]
    3b72:	add    rsp,0x60
    3b76:	mov    rsp,rbp
    3b79:	pop    rbp
    3b7a:	ret
    3b7b:	mov    rax,r14
    3b7e:	mov    rbx,QWORD PTR [rsp+0x30]
    3b83:	mov    r12,QWORD PTR [rsp+0x38]
    3b88:	mov    r13,QWORD PTR [rsp+0x40]
    3b8d:	mov    r14,QWORD PTR [rsp+0x48]
    3b92:	mov    r15,QWORD PTR [rsp+0x50]
    3b97:	add    rsp,0x60
    3b9b:	mov    rsp,rbp
    3b9e:	pop    rbp
    3b9f:	ret
    3ba0:	(bad)
    3ba1:	add    BYTE PTR [rax],al
    3ba3:	add    BYTE PTR [rax],al
    3ba5:	add    BYTE PTR [rax],al
	...

0000000000003ba8 <botlish_entry_41: ht_set<HashTable, str, str>>:
    3ba8:	push   rbp
    3ba9:	mov    rbp,rsp
    3bac:	mov    rsi,QWORD PTR [rdx]
    3baf:	mov    r8,QWORD PTR [rdx+0x8]
    3bb3:	mov    rcx,QWORD PTR [rdx+0x10]
    3bb7:	mov    rdx,r8
    3bba:	call   3bbf <botlish_entry_41+0x17>
			3bbb: R_X86_64_PLT32	botlish_fn_41-0x4 ; ht_set<HashTable, str, str>
    3bbf:	mov    rsp,rbp
    3bc2:	pop    rbp
    3bc3:	ret

0000000000003bc4 <botlish_fn_42: row_new<bool, int>>:
    3bc4:	push   rbp
    3bc5:	mov    rbp,rsp
    3bc8:	sub    rsp,0x10
    3bcc:	mov    QWORD PTR [rsp],rdx
    3bd0:	mov    r8,rdx
    3bd3:	cmp    rsi,0x6
    3bd7:	je     3bf4 <botlish_fn_42+0x30>
    3bdd:	call   3be2 <botlish_fn_42+0x1e>
			3bde: R_X86_64_PLT32	botlish_fn_23-0x4 ; ht_new<generic>
    3be2:	test   rax,rax
    3be5:	je     3c05 <botlish_fn_42+0x41>
    3beb:	add    rsp,0x10
    3bef:	mov    rsp,rbp
    3bf2:	pop    rbp
    3bf3:	ret
    3bf4:	mov    rsi,r8
    3bf7:	call   3bfc <botlish_fn_42+0x38>
			3bf8: R_X86_64_PLT32	botlish_fn_25-0x4 ; ht_new_sized<int>
    3bfc:	test   rax,rax
    3bff:	jne    3c11 <botlish_fn_42+0x4d>
    3c05:	xor    rax,rax
    3c08:	add    rsp,0x10
    3c0c:	mov    rsp,rbp
    3c0f:	pop    rbp
    3c10:	ret
    3c11:	add    rsp,0x10
    3c15:	mov    rsp,rbp
    3c18:	pop    rbp
    3c19:	ret

0000000000003c1a <botlish_entry_42: row_new<bool, int>>:
    3c1a:	push   rbp
    3c1b:	mov    rbp,rsp
    3c1e:	mov    rsi,QWORD PTR [rdx]
    3c21:	mov    rdx,QWORD PTR [rdx+0x8]
    3c25:	call   3c2a <botlish_entry_42+0x10>
			3c26: R_X86_64_PLT32	botlish_fn_42-0x4 ; row_new<bool, int>
    3c2a:	mov    rsp,rbp
    3c2d:	pop    rbp
    3c2e:	ret

0000000000003c2f <botlish_fn_43: row_fill<HashTable, List[str], List[str], int, int>>:
    3c2f:	push   rbp
    3c30:	mov    rbp,rsp
    3c33:	sub    rsp,0x70
    3c37:	mov    QWORD PTR [rsp+0x40],rbx
    3c3c:	mov    QWORD PTR [rsp+0x48],r12
    3c41:	mov    QWORD PTR [rsp+0x50],r13
    3c46:	mov    QWORD PTR [rsp+0x58],r14
    3c4b:	mov    QWORD PTR [rsp+0x60],r15
    3c50:	mov    r15,rdi
    3c53:	mov    QWORD PTR [rsp],rsi
    3c57:	mov    QWORD PTR [rsp+0x8],rdx
    3c5c:	mov    QWORD PTR [rsp+0x10],rcx
    3c61:	mov    r14,rcx
    3c64:	sar    r8,1
    3c67:	mov    rbx,r8
    3c6a:	mov    r12,r9
    3c6d:	mov    QWORD PTR [rsp+0x28],rsi
    3c72:	cmp    rbx,r12
    3c75:	jge    3d84 <botlish_fn_43+0x155>
    3c7b:	mov    r13,rdx
    3c7e:	mov    rdx,QWORD PTR [r13+0x8]
    3c82:	mov    rcx,rbx
    3c85:	shl    rcx,1
    3c88:	or     rcx,0x1
    3c8c:	sar    rcx,1
    3c8f:	cmp    rcx,rdx
    3c92:	jb     3cbe <botlish_fn_43+0x8f>
    3c98:	mov    rdx,rbx
    3c9b:	shl    rdx,1
    3c9e:	or     rdx,0x1
    3ca2:	mov    rsi,r13
    3ca5:	mov    rdi,r15
    3ca8:	call   3cad <botlish_fn_43+0x7e>
			3ca9: R_X86_64_PLT32	rt_list_get-0x4
    3cad:	test   rax,rax
    3cb0:	je     3d3d <botlish_fn_43+0x10e>
    3cb6:	mov    rdx,rax
    3cb9:	jmp    3cc6 <botlish_fn_43+0x97>
    3cbe:	mov    rax,QWORD PTR [r13+0x10]
    3cc2:	mov    rdx,QWORD PTR [rax+rcx*8]
    3cc6:	mov    QWORD PTR [rsp+0x18],rdx
    3ccb:	mov    QWORD PTR [rsp+0x30],rdx
    3cd0:	mov    rax,QWORD PTR [r14+0x8]
    3cd4:	mov    rcx,rbx
    3cd7:	shl    rcx,1
    3cda:	or     rcx,0x1
    3cde:	sar    rcx,1
    3ce1:	cmp    rcx,rax
    3ce4:	jb     3d15 <botlish_fn_43+0xe6>
    3cea:	mov    rdx,rbx
    3ced:	shl    rdx,1
    3cf0:	or     rdx,0x1
    3cf4:	mov    rsi,r14
    3cf7:	mov    rdi,r15
    3cfa:	call   3cff <botlish_fn_43+0xd0>
			3cfb: R_X86_64_PLT32	rt_list_get-0x4
    3cff:	test   rax,rax
    3d02:	je     3d3d <botlish_fn_43+0x10e>
    3d08:	mov    rcx,rax
    3d0b:	mov    rsi,QWORD PTR [rsp+0x28]
    3d10:	jmp    3d22 <botlish_fn_43+0xf3>
    3d15:	mov    rax,QWORD PTR [r14+0x10]
    3d19:	mov    rcx,QWORD PTR [rax+rcx*8]
    3d1d:	mov    rsi,QWORD PTR [rsp+0x28]
    3d22:	mov    QWORD PTR [rsp+0x20],rcx
    3d27:	mov    rdx,QWORD PTR [rsp+0x30]
    3d2c:	mov    rdi,r15
    3d2f:	call   3d34 <botlish_fn_43+0x105>
			3d30: R_X86_64_PLT32	botlish_fn_41-0x4 ; ht_set<HashTable, str, str>
    3d34:	test   rax,rax
    3d37:	jne    3d62 <botlish_fn_43+0x133>
    3d3d:	xor    rax,rax
    3d40:	mov    rbx,QWORD PTR [rsp+0x40]
    3d45:	mov    r12,QWORD PTR [rsp+0x48]
    3d4a:	mov    r13,QWORD PTR [rsp+0x50]
    3d4f:	mov    r14,QWORD PTR [rsp+0x58]
    3d54:	mov    r15,QWORD PTR [rsp+0x60]
    3d59:	add    rsp,0x70
    3d5d:	mov    rsp,rbp
    3d60:	pop    rbp
    3d61:	ret
    3d62:	mov    QWORD PTR [rsp],rax
    3d66:	mov    QWORD PTR [rsp+0x8],r13
    3d6b:	mov    QWORD PTR [rsp+0x10],r14
    3d70:	add    rbx,0x1
    3d77:	mov    rdx,r13
    3d7a:	mov    QWORD PTR [rsp+0x28],rax
    3d7f:	jmp    3c72 <botlish_fn_43+0x43>
    3d84:	mov    rax,QWORD PTR [rsp+0x28]
    3d89:	mov    rbx,QWORD PTR [rsp+0x40]
    3d8e:	mov    r12,QWORD PTR [rsp+0x48]
    3d93:	mov    r13,QWORD PTR [rsp+0x50]
    3d98:	mov    r14,QWORD PTR [rsp+0x58]
    3d9d:	mov    r15,QWORD PTR [rsp+0x60]
    3da2:	add    rsp,0x70
    3da6:	mov    rsp,rbp
    3da9:	pop    rbp
    3daa:	ret

0000000000003dab <botlish_entry_43: row_fill<HashTable, List[str], List[str], int, int>>:
    3dab:	push   rbp
    3dac:	mov    rbp,rsp
    3daf:	mov    rsi,QWORD PTR [rdx]
    3db2:	mov    r10,QWORD PTR [rdx+0x8]
    3db6:	mov    rcx,QWORD PTR [rdx+0x10]
    3dba:	mov    r8,QWORD PTR [rdx+0x18]
    3dbe:	mov    r9,QWORD PTR [rdx+0x20]
    3dc2:	sar    r9,1
    3dc5:	mov    rdx,r10
    3dc8:	call   3dcd <botlish_entry_43+0x22>
			3dc9: R_X86_64_PLT32	botlish_fn_43-0x4 ; row_fill<HashTable, List[str], List[str], int, int>
    3dcd:	mov    rsp,rbp
    3dd0:	pop    rbp
    3dd1:	ret

0000000000003dd2 <botlish_fn_44: row_table<List[str], int, List[str], bool>>:
    3dd2:	push   rbp
    3dd3:	mov    rbp,rsp
    3dd6:	sub    rsp,0x50
    3dda:	mov    QWORD PTR [rsp+0x20],rbx
    3ddf:	mov    QWORD PTR [rsp+0x28],r12
    3de4:	mov    QWORD PTR [rsp+0x30],r13
    3de9:	mov    QWORD PTR [rsp+0x38],r14
    3dee:	mov    QWORD PTR [rsp+0x40],r15
    3df3:	mov    r12,rdi
    3df6:	mov    QWORD PTR [rsp],rsi
    3dfa:	mov    r15,rsi
    3dfd:	mov    QWORD PTR [rsp+0x8],rdx
    3e02:	mov    QWORD PTR [rsp+0x10],rcx
    3e07:	mov    r13,rcx
    3e0a:	mov    QWORD PTR [rsp+0x18],r8
    3e0f:	mov    rsi,r8
    3e12:	mov    rdi,r12
    3e15:	call   3e1a <botlish_fn_44+0x48>
			3e16: R_X86_64_PLT32	botlish_fn_42-0x4 ; row_new<bool, int>
    3e1a:	test   rax,rax
    3e1d:	je     3e67 <botlish_fn_44+0x95>
    3e23:	mov    QWORD PTR [rsp+0x8],rax
    3e28:	mov    r14,rax
    3e2b:	mov    ebx,0x1
    3e30:	mov    QWORD PTR [rsp+0x18],0x1
    3e39:	mov    rsi,r13
    3e3c:	mov    rdi,r12
    3e3f:	call   3e44 <botlish_fn_44+0x72>
			3e40: R_X86_64_PLT32	rt_list_len-0x4
    3e44:	mov    r9,rax
    3e47:	sar    r9,1
    3e4a:	mov    rcx,r13
    3e4d:	mov    rdx,r15
    3e50:	mov    rsi,r14
    3e53:	mov    rdi,r12
    3e56:	mov    r8,rbx
    3e59:	call   3e5e <botlish_fn_44+0x8c>
			3e5a: R_X86_64_PLT32	botlish_fn_43-0x4 ; row_fill<HashTable, List[str], List[str], int, int>
    3e5e:	test   rax,rax
    3e61:	jne    3e8c <botlish_fn_44+0xba>
    3e67:	xor    rax,rax
    3e6a:	mov    rbx,QWORD PTR [rsp+0x20]
    3e6f:	mov    r12,QWORD PTR [rsp+0x28]
    3e74:	mov    r13,QWORD PTR [rsp+0x30]
    3e79:	mov    r14,QWORD PTR [rsp+0x38]
    3e7e:	mov    r15,QWORD PTR [rsp+0x40]
    3e83:	add    rsp,0x50
    3e87:	mov    rsp,rbp
    3e8a:	pop    rbp
    3e8b:	ret
    3e8c:	mov    rbx,QWORD PTR [rsp+0x20]
    3e91:	mov    r12,QWORD PTR [rsp+0x28]
    3e96:	mov    r13,QWORD PTR [rsp+0x30]
    3e9b:	mov    r14,QWORD PTR [rsp+0x38]
    3ea0:	mov    r15,QWORD PTR [rsp+0x40]
    3ea5:	add    rsp,0x50
    3ea9:	mov    rsp,rbp
    3eac:	pop    rbp
    3ead:	ret

0000000000003eae <botlish_entry_44: row_table<List[str], int, List[str], bool>>:
    3eae:	push   rbp
    3eaf:	mov    rbp,rsp
    3eb2:	mov    rsi,QWORD PTR [rdx]
    3eb5:	mov    r9,QWORD PTR [rdx+0x8]
    3eb9:	mov    rcx,QWORD PTR [rdx+0x10]
    3ebd:	mov    r8,QWORD PTR [rdx+0x18]
    3ec1:	mov    rdx,r9
    3ec4:	call   3ec9 <botlish_entry_44+0x1b>
			3ec5: R_X86_64_PLT32	botlish_fn_44-0x4 ; row_table<List[str], int, List[str], bool>
    3ec9:	mov    rsp,rbp
    3ecc:	pop    rbp
    3ecd:	ret

0000000000003ece <botlish_fn_45: build_rows<List[List[str]], int, List[str], int, mutarray, int, bool>>:
    3ece:	push   rbp
    3ecf:	mov    rbp,rsp
    3ed2:	sub    rsp,0x90
    3ed9:	mov    QWORD PTR [rsp+0x60],rbx
    3ede:	mov    QWORD PTR [rsp+0x68],r12
    3ee3:	mov    QWORD PTR [rsp+0x70],r13
    3ee8:	mov    QWORD PTR [rsp+0x78],r14
    3eed:	mov    QWORD PTR [rsp+0x80],r15
    3ef5:	mov    r13,r8
    3ef8:	mov    QWORD PTR [rsp+0x38],rdi
    3efd:	mov    rdi,QWORD PTR [rbp+0x10]
    3f01:	mov    r15,QWORD PTR [rbp+0x18]
    3f05:	mov    QWORD PTR [rsp+0x28],0x0
    3f0e:	mov    QWORD PTR [rsp+0x30],0x0
    3f17:	mov    QWORD PTR [rsp],rsi
    3f1b:	mov    QWORD PTR [rsp+0x8],rcx
    3f20:	mov    r14,rcx
    3f23:	mov    QWORD PTR [rsp+0x10],r9
    3f28:	mov    QWORD PTR [rsp+0x18],rdi
    3f2d:	mov    QWORD PTR [rsp+0x20],r15
    3f32:	sar    rdx,1
    3f35:	mov    r12,rdx
    3f38:	mov    rbx,rsi
    3f3b:	mov    QWORD PTR [rsp+0x40],r9
    3f40:	mov    QWORD PTR [rsp+0x48],rdi
    3f45:	mov    rsi,rbx
    3f48:	mov    rdi,QWORD PTR [rsp+0x38]
    3f4d:	call   3f52 <botlish_fn_45+0x84>
			3f4e: R_X86_64_PLT32	rt_list_len-0x4
    3f52:	sar    rax,1
    3f55:	cmp    r12,rax
    3f58:	jge    4083 <botlish_fn_45+0x1b5>
    3f5e:	mov    rax,r13
    3f61:	or     rax,0x1
    3f65:	mov    QWORD PTR [rsp+0x28],rax
    3f6a:	mov    rcx,QWORD PTR [rbx+0x8]
    3f6e:	mov    rax,r12
    3f71:	shl    rax,1
    3f74:	or     rax,0x1
    3f78:	sar    rax,1
    3f7b:	cmp    rax,rcx
    3f7e:	jb     3fac <botlish_fn_45+0xde>
    3f84:	mov    rdx,r12
    3f87:	shl    rdx,1
    3f8a:	or     rdx,0x1
    3f8e:	mov    rsi,rbx
    3f91:	mov    rdi,QWORD PTR [rsp+0x38]
    3f96:	call   3f9b <botlish_fn_45+0xcd>
			3f97: R_X86_64_PLT32	rt_list_get-0x4
    3f9b:	test   rax,rax
    3f9e:	je     40a0 <botlish_fn_45+0x1d2>
    3fa4:	mov    rcx,rax
    3fa7:	jmp    3fb4 <botlish_fn_45+0xe6>
    3fac:	mov    rcx,QWORD PTR [rbx+0x10]
    3fb0:	mov    rcx,QWORD PTR [rcx+rax*8]
    3fb4:	mov    QWORD PTR [rsp+0x30],rcx
    3fb9:	mov    rdx,r13
    3fbc:	or     rdx,0x1
    3fc0:	mov    rsi,r14
    3fc3:	mov    rdi,QWORD PTR [rsp+0x38]
    3fc8:	mov    r8,r15
    3fcb:	call   3fd0 <botlish_fn_45+0x102>
			3fcc: R_X86_64_PLT32	botlish_fn_44-0x4 ; row_table<List[str], int, List[str], bool>
    3fd0:	test   rax,rax
    3fd3:	je     40a0 <botlish_fn_45+0x1d2>
    3fd9:	mov    QWORD PTR [rsp+0x28],rax
    3fde:	mov    rcx,rax
    3fe1:	mov    rsi,QWORD PTR [rsp+0x40]
    3fe6:	mov    rdx,QWORD PTR [rsp+0x48]
    3feb:	mov    rdi,QWORD PTR [rsp+0x38]
    3ff0:	call   3ff5 <botlish_fn_45+0x127>
			3ff1: R_X86_64_PLT32	botlish_fn_10-0x4 ; geo_append<mutarray, int, HashTable>
    3ff5:	test   rax,rax
    3ff8:	je     40a0 <botlish_fn_45+0x1d2>
    3ffe:	mov    QWORD PTR [rsp+0x10],rax
    4003:	mov    QWORD PTR [rsp+0x50],rax
    4008:	mov    QWORD PTR [rsp+0x28],0x3
    4011:	mov    rsi,QWORD PTR [rsp+0x48]
    4016:	test   rsi,0x1
    401d:	je     403c <botlish_fn_45+0x16e>
    4023:	mov    rsi,QWORD PTR [rsp+0x48]
    4028:	mov    rax,rsi
    402b:	add    rax,0x2
    402f:	seto   r10b
    4033:	test   r10b,r10b
    4036:	je     4050 <botlish_fn_45+0x182>
    403c:	mov    edx,0x3
    4041:	mov    rsi,QWORD PTR [rsp+0x48]
    4046:	mov    rdi,QWORD PTR [rsp+0x38]
    404b:	call   4050 <botlish_fn_45+0x182>
			404c: R_X86_64_PLT32	rt_int_add-0x4
    4050:	mov    QWORD PTR [rsp],rbx
    4054:	mov    QWORD PTR [rsp+0x8],r14
    4059:	mov    rcx,QWORD PTR [rsp+0x50]
    405e:	mov    QWORD PTR [rsp+0x10],rcx
    4063:	mov    QWORD PTR [rsp+0x18],rax
    4068:	mov    QWORD PTR [rsp+0x20],r15
    406d:	add    r12,0x1
    4074:	mov    QWORD PTR [rsp+0x40],rcx
    4079:	mov    QWORD PTR [rsp+0x48],rax
    407e:	jmp    3f45 <botlish_fn_45+0x77>
    4083:	mov    rdx,QWORD PTR [rsp+0x48]
    4088:	mov    rsi,QWORD PTR [rsp+0x40]
    408d:	mov    rdi,QWORD PTR [rsp+0x38]
    4092:	call   4097 <botlish_fn_45+0x1c9>
			4093: R_X86_64_PLT32	botlish_fn_11-0x4 ; geo_finish<mutarray, int>
    4097:	test   rax,rax
    409a:	jne    40cb <botlish_fn_45+0x1fd>
    40a0:	xor    rax,rax
    40a3:	mov    rbx,QWORD PTR [rsp+0x60]
    40a8:	mov    r12,QWORD PTR [rsp+0x68]
    40ad:	mov    r13,QWORD PTR [rsp+0x70]
    40b2:	mov    r14,QWORD PTR [rsp+0x78]
    40b7:	mov    r15,QWORD PTR [rsp+0x80]
    40bf:	add    rsp,0x90
    40c6:	mov    rsp,rbp
    40c9:	pop    rbp
    40ca:	ret
    40cb:	mov    rbx,QWORD PTR [rsp+0x60]
    40d0:	mov    r12,QWORD PTR [rsp+0x68]
    40d5:	mov    r13,QWORD PTR [rsp+0x70]
    40da:	mov    r14,QWORD PTR [rsp+0x78]
    40df:	mov    r15,QWORD PTR [rsp+0x80]
    40e7:	add    rsp,0x90
    40ee:	mov    rsp,rbp
    40f1:	pop    rbp
    40f2:	ret

00000000000040f3 <botlish_entry_45: build_rows<List[List[str]], int, List[str], int, mutarray, int, bool>>:
    40f3:	push   rbp
    40f4:	mov    rbp,rsp
    40f7:	sub    rsp,0x10
    40fb:	mov    rsi,QWORD PTR [rdx]
    40fe:	mov    r10,QWORD PTR [rdx+0x8]
    4102:	mov    rcx,QWORD PTR [rdx+0x10]
    4106:	mov    r8,QWORD PTR [rdx+0x18]
    410a:	mov    r9,QWORD PTR [rdx+0x20]
    410e:	mov    r11,QWORD PTR [rdx+0x28]
    4112:	mov    rax,QWORD PTR [rdx+0x30]
    4116:	mov    QWORD PTR [rsp],r11
    411a:	mov    QWORD PTR [rsp+0x8],rax
    411f:	mov    rdx,r10
    4122:	call   4127 <botlish_entry_45+0x34>
			4123: R_X86_64_PLT32	botlish_fn_45-0x4 ; build_rows<List[List[str]], int, List[str], int, mutarray, int, bool>
    4127:	add    rsp,0x10
    412b:	mov    rsp,rbp
    412e:	pop    rbp
    412f:	ret

0000000000004130 <botlish_fn_46: csv_records_generic<str, bool>>:
    4130:	push   rbp
    4131:	mov    rbp,rsp
    4134:	sub    rsp,0x80
    413b:	mov    QWORD PTR [rsp+0x50],rbx
    4140:	mov    QWORD PTR [rsp+0x58],r12
    4145:	mov    QWORD PTR [rsp+0x60],r13
    414a:	mov    QWORD PTR [rsp+0x68],r14
    414f:	mov    QWORD PTR [rsp+0x70],r15
    4154:	mov    r12,rdi
    4157:	mov    QWORD PTR [rsp+0x20],0x0
    4160:	mov    QWORD PTR [rsp+0x28],0x0
    4169:	mov    QWORD PTR [rsp+0x30],0x0
    4172:	mov    QWORD PTR [rsp+0x38],0x0
    417b:	mov    QWORD PTR [rsp+0x40],0x0
    4184:	mov    QWORD PTR [rsp+0x10],rsi
    4189:	mov    QWORD PTR [rsp+0x18],rdx
    418e:	mov    r13,rdx
    4191:	mov    rdi,r12
    4194:	call   4199 <botlish_fn_46+0x69>
			4195: R_X86_64_PLT32	botlish_fn_20-0x4 ; csv_parse<str>
    4199:	mov    rcx,rax
    419c:	mov    r14,rax
    419f:	test   rax,rcx
    41a2:	je     42bc <botlish_fn_46+0x18c>
    41a8:	mov    rax,r14
    41ab:	mov    QWORD PTR [rsp+0x10],rax
    41b0:	mov    rsi,r14
    41b3:	mov    rdi,r12
    41b6:	call   41bb <botlish_fn_46+0x8b>
			41b7: R_X86_64_PLT32	rt_list_len-0x4
    41bb:	sar    rax,1
    41be:	cmp    rax,0x1
    41c2:	jle    42a5 <botlish_fn_46+0x175>
    41c8:	mov    rax,r14
    41cb:	mov    rax,QWORD PTR [rax+0x10]
    41cf:	mov    rbx,QWORD PTR [rax]
    41d2:	mov    QWORD PTR [rsp+0x20],rbx
    41d7:	mov    rsi,rbx
    41da:	mov    rdi,r12
    41dd:	call   41e2 <botlish_fn_46+0xb2>
			41de: R_X86_64_PLT32	rt_list_len-0x4
    41e2:	mov    r15,rbx
    41e5:	mov    QWORD PTR [rsp+0x28],rax
    41ea:	mov    QWORD PTR [rsp+0x48],rax
    41ef:	mov    rax,r14
    41f2:	mov    rcx,QWORD PTR [rax+0x10]
    41f6:	mov    rcx,QWORD PTR [rcx+0x8]
    41fa:	mov    QWORD PTR [rsp+0x30],rcx
    41ff:	mov    rbx,r13
    4202:	mov    rdx,QWORD PTR [rsp+0x48]
    4207:	mov    rsi,r15
    420a:	mov    rdi,r12
    420d:	mov    r8,rbx
    4210:	call   4215 <botlish_fn_46+0xe5>
			4211: R_X86_64_PLT32	botlish_fn_44-0x4 ; row_table<List[str], int, List[str], bool>
    4215:	test   rax,rax
    4218:	je     42bc <botlish_fn_46+0x18c>
    421e:	mov    QWORD PTR [rsp+0x30],rax
    4223:	mov    rsi,rax
    4226:	mov    QWORD PTR [rsp+0x38],0x5
    422f:	mov    rdi,r12
    4232:	call   4237 <botlish_fn_46+0x107>
			4233: R_X86_64_PLT32	botlish_fn_3-0x4 ; geo_new<HashTable>
    4237:	test   rax,rax
    423a:	je     42bc <botlish_fn_46+0x18c>
    4240:	mov    QWORD PTR [rsp+0x30],rax
    4245:	mov    r9,rax
    4248:	mov    eax,0x3
    424d:	mov    QWORD PTR [rsp+0x40],0x3
    4256:	mov    edx,0x5
    425b:	mov    QWORD PTR [rsp],rax
    425f:	mov    QWORD PTR [rsp+0x8],rbx
    4264:	mov    rcx,r15
    4267:	mov    rsi,r14
    426a:	mov    rdi,r12
    426d:	mov    r8,QWORD PTR [rsp+0x48]
    4272:	call   4277 <botlish_fn_46+0x147>
			4273: R_X86_64_PLT32	botlish_fn_45-0x4 ; build_rows<List[List[str]], int, List[str], int, mutarray, int, bool>
    4277:	test   rax,rax
    427a:	je     42bc <botlish_fn_46+0x18c>
    4280:	mov    rbx,QWORD PTR [rsp+0x50]
    4285:	mov    r12,QWORD PTR [rsp+0x58]
    428a:	mov    r13,QWORD PTR [rsp+0x60]
    428f:	mov    r14,QWORD PTR [rsp+0x68]
    4294:	mov    r15,QWORD PTR [rsp+0x70]
    4299:	add    rsp,0x80
    42a0:	mov    rsp,rbp
    42a3:	pop    rbp
    42a4:	ret
    42a5:	xor    rdx,rdx
    42a8:	mov    rdi,r12
    42ab:	mov    rsi,rdx
    42ae:	call   42b3 <botlish_fn_46+0x183>
			42af: R_X86_64_PLT32	rt_list_new-0x4
    42b3:	test   rax,rax
    42b6:	jne    42e4 <botlish_fn_46+0x1b4>
    42bc:	xor    rax,rax
    42bf:	mov    rbx,QWORD PTR [rsp+0x50]
    42c4:	mov    r12,QWORD PTR [rsp+0x58]
    42c9:	mov    r13,QWORD PTR [rsp+0x60]
    42ce:	mov    r14,QWORD PTR [rsp+0x68]
    42d3:	mov    r15,QWORD PTR [rsp+0x70]
    42d8:	add    rsp,0x80
    42df:	mov    rsp,rbp
    42e2:	pop    rbp
    42e3:	ret
    42e4:	mov    rbx,QWORD PTR [rsp+0x50]
    42e9:	mov    r12,QWORD PTR [rsp+0x58]
    42ee:	mov    r13,QWORD PTR [rsp+0x60]
    42f3:	mov    r14,QWORD PTR [rsp+0x68]
    42f8:	mov    r15,QWORD PTR [rsp+0x70]
    42fd:	add    rsp,0x80
    4304:	mov    rsp,rbp
    4307:	pop    rbp
    4308:	ret

0000000000004309 <botlish_entry_46: csv_records_generic<str, bool>>:
    4309:	push   rbp
    430a:	mov    rbp,rsp
    430d:	mov    rsi,QWORD PTR [rdx]
    4310:	mov    rdx,QWORD PTR [rdx+0x8]
    4314:	call   4319 <botlish_entry_46+0x10>
			4315: R_X86_64_PLT32	botlish_fn_46-0x4 ; csv_records_generic<str, bool>
    4319:	mov    rsp,rbp
    431c:	pop    rbp
    431d:	ret

000000000000431e <botlish_fn_47: csv_records<str>>:
    431e:	push   rbp
    431f:	mov    rbp,rsp
    4322:	sub    rsp,0x10
    4326:	mov    QWORD PTR [rsp],rsi
    432a:	mov    edx,0x2
    432f:	mov    QWORD PTR [rsp+0x8],0x2
    4338:	call   433d <botlish_fn_47+0x1f>
			4339: R_X86_64_PLT32	botlish_fn_46-0x4 ; csv_records_generic<str, bool>
    433d:	test   rax,rax
    4340:	jne    4352 <botlish_fn_47+0x34>
    4346:	xor    rax,rax
    4349:	add    rsp,0x10
    434d:	mov    rsp,rbp
    4350:	pop    rbp
    4351:	ret
    4352:	add    rsp,0x10
    4356:	mov    rsp,rbp
    4359:	pop    rbp
    435a:	ret

000000000000435b <botlish_entry_47: csv_records<str>>:
    435b:	push   rbp
    435c:	mov    rbp,rsp
    435f:	mov    rsi,QWORD PTR [rdx]
    4362:	call   4367 <botlish_entry_47+0xc>
			4363: R_X86_64_PLT32	botlish_fn_47-0x4 ; csv_records<str>
    4367:	mov    rsp,rbp
    436a:	pop    rbp
    436b:	ret

000000000000436c <botlish_fn_48: csv_records_presized<str>>:
    436c:	push   rbp
    436d:	mov    rbp,rsp
    4370:	sub    rsp,0x10
    4374:	mov    QWORD PTR [rsp],rsi
    4378:	mov    edx,0x6
    437d:	mov    QWORD PTR [rsp+0x8],0x6
    4386:	call   438b <botlish_fn_48+0x1f>
			4387: R_X86_64_PLT32	botlish_fn_46-0x4 ; csv_records_generic<str, bool>
    438b:	test   rax,rax
    438e:	jne    43a0 <botlish_fn_48+0x34>
    4394:	xor    rax,rax
    4397:	add    rsp,0x10
    439b:	mov    rsp,rbp
    439e:	pop    rbp
    439f:	ret
    43a0:	add    rsp,0x10
    43a4:	mov    rsp,rbp
    43a7:	pop    rbp
    43a8:	ret

00000000000043a9 <botlish_entry_48: csv_records_presized<str>>:
    43a9:	push   rbp
    43aa:	mov    rbp,rsp
    43ad:	mov    rsi,QWORD PTR [rdx]
    43b0:	call   43b5 <botlish_entry_48+0xc>
			43b1: R_X86_64_PLT32	botlish_fn_48-0x4 ; csv_records_presized<str>
    43b5:	mov    rsp,rbp
    43b8:	pop    rbp
    43b9:	ret
    43ba:	add    BYTE PTR [rax],al
    43bc:	add    BYTE PTR [rax],al
	...

00000000000043c0 <botlish_fn_49: sample_checks<generic>>:
    43c0:	push   rbp
    43c1:	mov    rbp,rsp
    43c4:	sub    rsp,0xc0
    43cb:	mov    QWORD PTR [rsp+0x90],rbx
    43d3:	mov    QWORD PTR [rsp+0x98],r12
    43db:	mov    QWORD PTR [rsp+0xa0],r13
    43e3:	mov    QWORD PTR [rsp+0xa8],r14
    43eb:	mov    QWORD PTR [rsp+0xb0],r15
    43f3:	mov    QWORD PTR [rsp+0x8],0x0
    43fc:	mov    QWORD PTR [rsp+0x10],0x0
    4405:	mov    QWORD PTR [rsp+0x18],0x0
    440e:	mov    QWORD PTR [rsp+0x20],0x0
    4417:	mov    QWORD PTR [rsp+0x28],0x0
    4420:	mov    QWORD PTR [rsp+0x30],0x0
    4429:	mov    QWORD PTR [rsp+0x38],0x0
    4432:	mov    rax,QWORD PTR [rdi+0x10]
    4436:	mov    r13,rdi
    4439:	mov    rsi,QWORD PTR [rax+0x20]
    443d:	mov    QWORD PTR [rsp],rsi
    4441:	call   4446 <botlish_fn_49+0x86>
			4442: R_X86_64_PLT32	botlish_fn_47-0x4 ; csv_records<str>
    4446:	mov    rsi,rax
    4449:	mov    r12,rax
    444c:	test   rax,rsi
    444f:	je     47d4 <botlish_fn_49+0x414>
    4455:	mov    rax,r12
    4458:	mov    QWORD PTR [rsp],rax
    445c:	mov    rdi,r13
    445f:	mov    rax,QWORD PTR [rdi+0x10]
    4463:	mov    rsi,QWORD PTR [rax+0x20]
    4467:	mov    QWORD PTR [rsp+0x8],rsi
    446c:	call   4471 <botlish_fn_49+0xb1>
			446d: R_X86_64_PLT32	botlish_fn_48-0x4 ; csv_records_presized<str>
    4471:	mov    rbx,rax
    4474:	test   rbx,rbx
    4477:	je     47d4 <botlish_fn_49+0x414>
    447d:	mov    rax,r12
    4480:	mov    rax,QWORD PTR [rax+0x8]
    4484:	test   rax,rax
    4487:	jne    44ae <botlish_fn_49+0xee>
    448d:	mov    edx,0x1
    4492:	mov    rsi,r12
    4495:	mov    rdi,r13
    4498:	call   449d <botlish_fn_49+0xdd>
			4499: R_X86_64_PLT32	rt_list_get-0x4
    449d:	test   rax,rax
    44a0:	je     47d4 <botlish_fn_49+0x414>
    44a6:	mov    rsi,rax
    44a9:	jmp    44b6 <botlish_fn_49+0xf6>
    44ae:	mov    rax,QWORD PTR [r12+0x10]
    44b3:	mov    rsi,QWORD PTR [rax]
    44b6:	mov    QWORD PTR [rsp+0x8],rsi
    44bb:	mov    r15,rsi
    44be:	mov    rax,QWORD PTR [r12+0x8]
    44c3:	cmp    rax,0x1
    44c7:	ja     44ee <botlish_fn_49+0x12e>
    44cd:	mov    edx,0x3
    44d2:	mov    rsi,r12
    44d5:	mov    rdi,r13
    44d8:	call   44dd <botlish_fn_49+0x11d>
			44d9: R_X86_64_PLT32	rt_list_get-0x4
    44dd:	test   rax,rax
    44e0:	je     47d4 <botlish_fn_49+0x414>
    44e6:	mov    rsi,rax
    44e9:	jmp    44f7 <botlish_fn_49+0x137>
    44ee:	mov    rax,QWORD PTR [r12+0x10]
    44f3:	mov    rsi,QWORD PTR [rax+0x8]
    44f7:	mov    QWORD PTR [rsp+0x10],rsi
    44fc:	mov    r14,rsi
    44ff:	mov    rax,QWORD PTR [rbx+0x8]
    4503:	mov    rsi,rbx
    4506:	test   rax,rax
    4509:	jne    452d <botlish_fn_49+0x16d>
    450f:	mov    edx,0x1
    4514:	mov    rdi,r13
    4517:	call   451c <botlish_fn_49+0x15c>
			4518: R_X86_64_PLT32	rt_list_get-0x4
    451c:	test   rax,rax
    451f:	je     47d4 <botlish_fn_49+0x414>
    4525:	mov    rsi,rax
    4528:	jmp    4534 <botlish_fn_49+0x174>
    452d:	mov    rax,QWORD PTR [rsi+0x10]
    4531:	mov    rsi,QWORD PTR [rax]
    4534:	mov    QWORD PTR [rsp+0x18],rsi
    4539:	mov    rdi,r13
    453c:	mov    QWORD PTR [rsp+0x78],rsi
    4541:	mov    rax,QWORD PTR [rdi+0x10]
    4545:	mov    rdx,QWORD PTR [rax+0x28]
    4549:	mov    QWORD PTR [rsp+0x20],rdx
    454e:	mov    rsi,r15
    4551:	call   4556 <botlish_fn_49+0x196>
			4552: R_X86_64_PLT32	botlish_fn_33-0x4 ; ht_get<HashTable, str>
    4556:	test   rax,rax
    4559:	je     47d4 <botlish_fn_49+0x414>
    455f:	mov    QWORD PTR [rsp+0x20],rax
    4564:	mov    rbx,rax
    4567:	mov    rdi,r13
    456a:	mov    rax,QWORD PTR [rdi+0x10]
    456e:	mov    rdx,QWORD PTR [rax+0x28]
    4572:	mov    QWORD PTR [rsp+0x28],rdx
    4577:	mov    rsi,QWORD PTR [rsp+0x78]
    457c:	call   4581 <botlish_fn_49+0x1c1>
			457d: R_X86_64_PLT32	botlish_fn_33-0x4 ; ht_get<HashTable, str>
    4581:	test   rax,rax
    4584:	je     47d4 <botlish_fn_49+0x414>
    458a:	mov    rcx,rbx
    458d:	mov    rdx,rcx
    4590:	and    rdx,rax
    4593:	test   rdx,0x1
    459a:	jne    45bc <botlish_fn_49+0x1fc>
    45a0:	mov    rdx,rax
    45a3:	mov    rsi,rbx
    45a6:	mov    rdi,r13
    45a9:	call   45ae <botlish_fn_49+0x1ee>
			45aa: R_X86_64_PLT32	rt_value_eq-0x4
    45ae:	test   rax,rax
    45b1:	je     47d4 <botlish_fn_49+0x414>
    45b7:	jmp    45d2 <botlish_fn_49+0x212>
    45bc:	mov    rdx,rax
    45bf:	mov    rsi,rbx
    45c2:	mov    eax,0x2
    45c7:	cmp    rsi,rdx
    45ca:	cmove  rax,QWORD PTR [rip+0x26e]        # 4840 <botlish_fn_49+0x480>
    45d2:	mov    ebx,0x6
    45d7:	cmp    rax,0x6
    45db:	je     45f6 <botlish_fn_49+0x236>
    45e1:	mov    ebx,0x2
    45e6:	mov    QWORD PTR [rsp],0x2
    45ee:	mov    rsi,r12
    45f1:	jmp    4695 <botlish_fn_49+0x2d5>
    45f6:	mov    rsi,r15
    45f9:	mov    rdi,r13
    45fc:	call   4601 <botlish_fn_49+0x241>
			45fd: R_X86_64_PLT32	botlish_fn_26-0x4 ; ht_size<HashTable>
    4601:	test   rax,rax
    4604:	mov    QWORD PTR [rsp+0x88],rax
    460c:	je     47d4 <botlish_fn_49+0x414>
    4612:	mov    rsi,QWORD PTR [rsp+0x78]
    4617:	mov    rdi,r13
    461a:	call   461f <botlish_fn_49+0x25f>
			461b: R_X86_64_PLT32	botlish_fn_26-0x4 ; ht_size<HashTable>
    461f:	test   rax,rax
    4622:	je     47d4 <botlish_fn_49+0x414>
    4628:	mov    rcx,QWORD PTR [rsp+0x88]
    4630:	mov    rdx,rcx
    4633:	and    rdx,rax
    4636:	test   rdx,0x1
    463d:	jne    4664 <botlish_fn_49+0x2a4>
    4643:	mov    rdx,rax
    4646:	mov    rsi,QWORD PTR [rsp+0x88]
    464e:	mov    rdi,r13
    4651:	call   4656 <botlish_fn_49+0x296>
			4652: R_X86_64_PLT32	rt_value_eq-0x4
    4656:	test   rax,rax
    4659:	je     47d4 <botlish_fn_49+0x414>
    465f:	jmp    467f <botlish_fn_49+0x2bf>
    4664:	mov    rdx,rax
    4667:	mov    rsi,QWORD PTR [rsp+0x88]
    466f:	mov    eax,0x2
    4674:	cmp    rsi,rdx
    4677:	cmove  rax,QWORD PTR [rip+0x1c1]        # 4840 <botlish_fn_49+0x480>
    467f:	cmp    rax,0x6
    4683:	je     468e <botlish_fn_49+0x2ce>
    4689:	mov    ebx,0x2
    468e:	mov    QWORD PTR [rsp],rbx
    4692:	mov    rsi,r12
    4695:	mov    rdi,r13
    4698:	call   469d <botlish_fn_49+0x2dd>
			4699: R_X86_64_PLT32	rt_list_len-0x4
    469d:	mov    QWORD PTR [rsp+0x18],rax
    46a2:	mov    rdi,r13
    46a5:	mov    r12,rax
    46a8:	mov    rax,QWORD PTR [rdi+0x10]
    46ac:	mov    rdx,QWORD PTR [rax+0x28]
    46b0:	mov    QWORD PTR [rsp+0x20],rdx
    46b5:	mov    rsi,r15
    46b8:	call   46bd <botlish_fn_49+0x2fd>
			46b9: R_X86_64_PLT32	botlish_fn_33-0x4 ; ht_get<HashTable, str>
    46bd:	test   rax,rax
    46c0:	je     47d4 <botlish_fn_49+0x414>
    46c6:	mov    QWORD PTR [rsp+0x20],rax
    46cb:	mov    rdi,r13
    46ce:	mov    QWORD PTR [rsp+0x88],rax
    46d6:	mov    rax,QWORD PTR [rdi+0x10]
    46da:	mov    rdx,QWORD PTR [rax+0x30]
    46de:	mov    QWORD PTR [rsp+0x28],rdx
    46e3:	mov    rsi,r15
    46e6:	call   46eb <botlish_fn_49+0x32b>
			46e7: R_X86_64_PLT32	botlish_fn_33-0x4 ; ht_get<HashTable, str>
    46eb:	test   rax,rax
    46ee:	je     47d4 <botlish_fn_49+0x414>
    46f4:	mov    QWORD PTR [rsp+0x28],rax
    46f9:	mov    rdi,r13
    46fc:	mov    QWORD PTR [rsp+0x80],rax
    4704:	mov    rax,QWORD PTR [rdi+0x10]
    4708:	mov    rdx,QWORD PTR [rax+0x38]
    470c:	mov    QWORD PTR [rsp+0x30],rdx
    4711:	mov    rsi,r15
    4714:	call   4719 <botlish_fn_49+0x359>
			4715: R_X86_64_PLT32	botlish_fn_33-0x4 ; ht_get<HashTable, str>
    4719:	test   rax,rax
    471c:	je     47d4 <botlish_fn_49+0x414>
    4722:	mov    QWORD PTR [rsp+0x8],rax
    4727:	mov    rdi,r13
    472a:	mov    r15,rax
    472d:	mov    rax,QWORD PTR [rdi+0x10]
    4731:	mov    rdx,QWORD PTR [rax+0x28]
    4735:	mov    QWORD PTR [rsp+0x30],rdx
    473a:	mov    rsi,r14
    473d:	call   4742 <botlish_fn_49+0x382>
			473e: R_X86_64_PLT32	botlish_fn_33-0x4 ; ht_get<HashTable, str>
    4742:	test   rax,rax
    4745:	je     47d4 <botlish_fn_49+0x414>
    474b:	mov    QWORD PTR [rsp+0x30],rax
    4750:	mov    rdi,r13
    4753:	mov    QWORD PTR [rsp+0x78],rax
    4758:	mov    rax,QWORD PTR [rdi+0x10]
    475c:	mov    rdx,QWORD PTR [rax+0x38]
    4760:	mov    QWORD PTR [rsp+0x38],rdx
    4765:	mov    rsi,r14
    4768:	call   476d <botlish_fn_49+0x3ad>
			4769: R_X86_64_PLT32	botlish_fn_33-0x4 ; ht_get<HashTable, str>
    476d:	test   rax,rax
    4770:	je     47d4 <botlish_fn_49+0x414>
    4776:	mov    QWORD PTR [rsp+0x10],rax
    477b:	lea    rdx,[rsp+0x40]
    4780:	mov    r9,r12
    4783:	mov    QWORD PTR [rsp+0x40],r9
    4788:	mov    rcx,QWORD PTR [rsp+0x88]
    4790:	mov    QWORD PTR [rsp+0x48],rcx
    4795:	mov    rcx,QWORD PTR [rsp+0x80]
    479d:	mov    QWORD PTR [rsp+0x50],rcx
    47a2:	mov    rcx,r15
    47a5:	mov    QWORD PTR [rsp+0x58],rcx
    47aa:	mov    rcx,QWORD PTR [rsp+0x78]
    47af:	mov    QWORD PTR [rsp+0x60],rcx
    47b4:	mov    QWORD PTR [rsp+0x68],rax
    47b9:	mov    QWORD PTR [rsp+0x70],rbx
    47be:	mov    esi,0x7
    47c3:	mov    rdi,r13
    47c6:	call   47cb <botlish_fn_49+0x40b>
			47c7: R_X86_64_PLT32	rt_list_new-0x4
    47cb:	test   rax,rax
    47ce:	jne    480b <botlish_fn_49+0x44b>
    47d4:	xor    rax,rax
    47d7:	mov    rbx,QWORD PTR [rsp+0x90]
    47df:	mov    r12,QWORD PTR [rsp+0x98]
    47e7:	mov    r13,QWORD PTR [rsp+0xa0]
    47ef:	mov    r14,QWORD PTR [rsp+0xa8]
    47f7:	mov    r15,QWORD PTR [rsp+0xb0]
    47ff:	add    rsp,0xc0
    4806:	mov    rsp,rbp
    4809:	pop    rbp
    480a:	ret
    480b:	mov    rbx,QWORD PTR [rsp+0x90]
    4813:	mov    r12,QWORD PTR [rsp+0x98]
    481b:	mov    r13,QWORD PTR [rsp+0xa0]
    4823:	mov    r14,QWORD PTR [rsp+0xa8]
    482b:	mov    r15,QWORD PTR [rsp+0xb0]
    4833:	add    rsp,0xc0
    483a:	mov    rsp,rbp
    483d:	pop    rbp
    483e:	ret
    483f:	add    BYTE PTR [rsi],al
    4841:	add    BYTE PTR [rax],al
    4843:	add    BYTE PTR [rax],al
    4845:	add    BYTE PTR [rax],al
	...

0000000000004848 <botlish_entry_49: sample_checks<generic>>:
    4848:	push   rbp
    4849:	mov    rbp,rsp
    484c:	call   4851 <botlish_entry_49+0x9>
			484d: R_X86_64_PLT32	botlish_fn_49-0x4 ; sample_checks<generic>
    4851:	mov    rsp,rbp
    4854:	pop    rbp
    4855:	ret

0000000000004856 <botlish_fn_50: sample<generic>>:
    4856:	push   rbp
    4857:	mov    rbp,rsp
    485a:	sub    rsp,0x10
    485e:	mov    QWORD PTR [rsp],rbx
    4862:	mov    rbx,rdi
    4865:	mov    rdi,rbx
    4868:	call   486d <botlish_fn_50+0x17>
			4869: R_X86_64_PLT32	botlish_fn_49-0x4 ; sample_checks<generic>
    486d:	test   rax,rax
    4870:	jne    4929 <botlish_fn_50+0xd3>
    4876:	mov    rdi,rbx
    4879:	call   487e <botlish_fn_50+0x28>
			487a: R_X86_64_PLT32	rt_declared_error-0x4
    487e:	cmp    rax,0x40000001
    4884:	je     48fa <botlish_fn_50+0xa4>
    488a:	mov    rdi,rbx
    488d:	call   4892 <botlish_fn_50+0x3c>
			488e: R_X86_64_PLT32	rt_declared_error-0x4
    4892:	cmp    rax,0x40000002
    4898:	je     48d6 <botlish_fn_50+0x80>
    489e:	mov    rdi,rbx
    48a1:	call   48a6 <botlish_fn_50+0x50>
			48a2: R_X86_64_PLT32	rt_declared_error-0x4
    48a6:	cmp    rax,0x40000003
    48ac:	jne    4919 <botlish_fn_50+0xc3>
    48b2:	mov    rdi,rbx
    48b5:	call   48ba <botlish_fn_50+0x64>
			48b6: R_X86_64_PLT32	rt_clear_declared_error-0x4
    48ba:	xor    rdx,rdx
    48bd:	mov    rdi,rbx
    48c0:	mov    rsi,rdx
    48c3:	call   48c8 <botlish_fn_50+0x72>
			48c4: R_X86_64_PLT32	rt_list_new-0x4
    48c8:	test   rax,rax
    48cb:	je     4919 <botlish_fn_50+0xc3>
    48d1:	jmp    4929 <botlish_fn_50+0xd3>
    48d6:	mov    rdi,rbx
    48d9:	call   48de <botlish_fn_50+0x88>
			48da: R_X86_64_PLT32	rt_clear_declared_error-0x4
    48de:	xor    rdx,rdx
    48e1:	mov    rdi,rbx
    48e4:	mov    rsi,rdx
    48e7:	call   48ec <botlish_fn_50+0x96>
			48e8: R_X86_64_PLT32	rt_list_new-0x4
    48ec:	test   rax,rax
    48ef:	je     4919 <botlish_fn_50+0xc3>
    48f5:	jmp    4929 <botlish_fn_50+0xd3>
    48fa:	mov    rdi,rbx
    48fd:	call   4902 <botlish_fn_50+0xac>
			48fe: R_X86_64_PLT32	rt_clear_declared_error-0x4
    4902:	xor    rdx,rdx
    4905:	mov    rdi,rbx
    4908:	mov    rsi,rdx
    490b:	call   4910 <botlish_fn_50+0xba>
			490c: R_X86_64_PLT32	rt_list_new-0x4
    4910:	test   rax,rax
    4913:	jne    4929 <botlish_fn_50+0xd3>
    4919:	xor    rax,rax
    491c:	mov    rbx,QWORD PTR [rsp]
    4920:	add    rsp,0x10
    4924:	mov    rsp,rbp
    4927:	pop    rbp
    4928:	ret
    4929:	mov    rbx,QWORD PTR [rsp]
    492d:	add    rsp,0x10
    4931:	mov    rsp,rbp
    4934:	pop    rbp
    4935:	ret

0000000000004936 <botlish_entry_50: sample<generic>>:
    4936:	push   rbp
    4937:	mov    rbp,rsp
    493a:	call   493f <botlish_entry_50+0x9>
			493b: R_X86_64_PLT32	botlish_fn_50-0x4 ; sample<generic>
    493f:	mov    rsp,rbp
    4942:	pop    rbp
    4943:	ret
