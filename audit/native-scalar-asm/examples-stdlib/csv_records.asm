; source:  examples/stdlib/csv_records.bot
; backend: Cranelift (specialize=1), native::object
; object:  ELF64 x86-64, unlinked (Botlish-generated code only; runtime
;          helpers are unresolved imports, so their bodies are not present)
; format:  objdump -dr --no-show-raw-insn -M intel
; total machine code bytes: 19582  (per function: 45 89 89 89 357 420 420 420 202 202 202 81 365 309 470 932 310 758 215 480 318 427 385 70 493 114 69 69 46 182 228 604 984 341 388 407 616 654 809 673 928 700 107 433 259 629 515 78 78 1222 301)
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
    2002:	sub    rsp,0x30
    2006:	mov    QWORD PTR [rsp+0x20],rbx
    200b:	mov    QWORD PTR [rsp+0x28],r14
    2010:	mov    r14,rdi
    2013:	mov    QWORD PTR [rsp],rsi
    2017:	mov    rbx,rsi
    201a:	mov    QWORD PTR [rsp+0x8],rdx
    201f:	mov    QWORD PTR [rsp+0x10],0x3
    2028:	test   rdx,0x1
    202f:	jne    203d <botlish_fn_30+0x3f>
    2035:	mov    rcx,rdx
    2038:	jmp    2052 <botlish_fn_30+0x54>
    203d:	mov    rsi,rdx
    2040:	add    rsi,0x2
    2044:	mov    rcx,rdx
    2047:	seto   al
    204a:	test   al,al
    204c:	je     2065 <botlish_fn_30+0x67>
    2052:	mov    edx,0x3
    2057:	mov    rsi,rcx
    205a:	mov    rdi,r14
    205d:	call   2062 <botlish_fn_30+0x64>
			205e: R_X86_64_PLT32	rt_int_add-0x4
    2062:	mov    rsi,rax
    2065:	mov    QWORD PTR [rsp],rsi
    2069:	mov    rax,rbx
    206c:	mov    rbx,rsi
    206f:	mov    rsi,rax
    2072:	mov    rdi,r14
    2075:	call   207a <botlish_fn_30+0x7c>
			2076: R_X86_64_PLT32	botlish_fn_28-0x4 ; ht_capacity<HashTable>
    207a:	mov    QWORD PTR [rsp+0x8],rax
    207f:	mov    rdx,rax
    2082:	mov    rsi,rbx
    2085:	mov    rdi,r14
    2088:	call   208d <botlish_fn_30+0x8f>
			2089: R_X86_64_PLT32	rt_int_mod-0x4
    208d:	test   rax,rax
    2090:	jne    20ac <botlish_fn_30+0xae>
    2096:	xor    rax,rax
    2099:	mov    rbx,QWORD PTR [rsp+0x20]
    209e:	mov    r14,QWORD PTR [rsp+0x28]
    20a3:	add    rsp,0x30
    20a7:	mov    rsp,rbp
    20aa:	pop    rbp
    20ab:	ret
    20ac:	mov    rbx,QWORD PTR [rsp+0x20]
    20b1:	mov    r14,QWORD PTR [rsp+0x28]
    20b6:	add    rsp,0x30
    20ba:	mov    rsp,rbp
    20bd:	pop    rbp
    20be:	ret

00000000000020bf <botlish_entry_30: ht_probe_next<HashTable, int>>:
    20bf:	push   rbp
    20c0:	mov    rbp,rsp
    20c3:	mov    rsi,QWORD PTR [rdx]
    20c6:	mov    rdx,QWORD PTR [rdx+0x8]
    20ca:	call   20cf <botlish_entry_30+0x10>
			20cb: R_X86_64_PLT32	botlish_fn_30-0x4 ; ht_probe_next<HashTable, int>
    20cf:	mov    rsp,rbp
    20d2:	pop    rbp
    20d3:	ret
    20d4:	add    BYTE PTR [rax],al
	...

00000000000020d8 <botlish_fn_31: ht_find_get<HashTable, str, int>>:
    20d8:	push   rbp
    20d9:	mov    rbp,rsp
    20dc:	sub    rsp,0x50
    20e0:	mov    QWORD PTR [rsp+0x20],rbx
    20e5:	mov    QWORD PTR [rsp+0x28],r12
    20ea:	mov    QWORD PTR [rsp+0x30],r13
    20ef:	mov    QWORD PTR [rsp+0x38],r14
    20f4:	mov    QWORD PTR [rsp+0x40],r15
    20f9:	mov    r13,rdi
    20fc:	mov    QWORD PTR [rsp],rsi
    2100:	mov    QWORD PTR [rsp+0x8],rdx
    2105:	mov    rbx,rdx
    2108:	mov    QWORD PTR [rsp+0x10],rcx
    210d:	mov    r12,rsi
    2110:	mov    r14,rcx
    2113:	mov    rax,QWORD PTR [r12+0x18]
    2118:	mov    rsi,QWORD PTR [rax]
    211b:	mov    rdx,r14
    211e:	mov    rdi,r13
    2121:	call   2126 <botlish_fn_31+0x4e>
			2122: R_X86_64_PLT32	rt_mutarray_get-0x4
    2126:	mov    rcx,rax
    2129:	mov    r15,rax
    212c:	test   rax,rcx
    212f:	je     2259 <botlish_fn_31+0x181>
    2135:	mov    rax,r15
    2138:	test   rax,0x1
    213e:	jne    216c <botlish_fn_31+0x94>
    2144:	mov    edx,0x1
    2149:	mov    rsi,r15
    214c:	mov    rdi,r13
    214f:	call   2154 <botlish_fn_31+0x7c>
			2150: R_X86_64_PLT32	rt_int_cmp-0x4
    2154:	mov    ecx,0x2
    2159:	test   rax,rax
    215c:	cmove  rcx,QWORD PTR [rip+0x184]        # 22e8 <botlish_fn_31+0x210>
    2164:	mov    rax,r15
    2167:	jmp    2180 <botlish_fn_31+0xa8>
    216c:	mov    ecx,0x2
    2171:	mov    rax,r15
    2174:	cmp    rax,0x1
    2178:	cmove  rcx,QWORD PTR [rip+0x168]        # 22e8 <botlish_fn_31+0x210>
    2180:	cmp    rcx,0x6
    2184:	je     22b9 <botlish_fn_31+0x1e1>
    218a:	test   rax,0x1
    2190:	mov    r15,rax
    2193:	jne    21be <botlish_fn_31+0xe6>
    2199:	mov    edx,0x3
    219e:	mov    rsi,r15
    21a1:	mov    rdi,r13
    21a4:	call   21a9 <botlish_fn_31+0xd1>
			21a5: R_X86_64_PLT32	rt_int_cmp-0x4
    21a9:	mov    ecx,0x2
    21ae:	test   rax,rax
    21b1:	cmove  rcx,QWORD PTR [rip+0x12f]        # 22e8 <botlish_fn_31+0x210>
    21b9:	jmp    21d2 <botlish_fn_31+0xfa>
    21be:	mov    rsi,r15
    21c1:	mov    ecx,0x2
    21c6:	cmp    rsi,0x3
    21ca:	cmove  rcx,QWORD PTR [rip+0x116]        # 22e8 <botlish_fn_31+0x210>
    21d2:	cmp    rcx,0x6
    21d6:	jne    2242 <botlish_fn_31+0x16a>
    21dc:	mov    rax,QWORD PTR [r12+0x18]
    21e1:	mov    rsi,QWORD PTR [rax+0x8]
    21e5:	mov    rdx,r14
    21e8:	mov    rdi,r13
    21eb:	call   21f0 <botlish_fn_31+0x118>
			21ec: R_X86_64_PLT32	rt_mutarray_get-0x4
    21f0:	test   rax,rax
    21f3:	je     2259 <botlish_fn_31+0x181>
    21f9:	mov    rcx,rax
    21fc:	and    rcx,rbx
    21ff:	mov    rsi,rax
    2202:	test   rcx,0x1
    2209:	jne    2228 <botlish_fn_31+0x150>
    220f:	mov    rdx,rbx
    2212:	mov    rdi,r13
    2215:	call   221a <botlish_fn_31+0x142>
			2216: R_X86_64_PLT32	rt_value_eq-0x4
    221a:	test   rax,rax
    221d:	je     2259 <botlish_fn_31+0x181>
    2223:	jmp    2238 <botlish_fn_31+0x160>
    2228:	mov    eax,0x2
    222d:	cmp    rsi,rbx
    2230:	cmove  rax,QWORD PTR [rip+0xb0]        # 22e8 <botlish_fn_31+0x210>
    2238:	cmp    rax,0x6
    223c:	je     2294 <botlish_fn_31+0x1bc>
    2242:	mov    rdx,r14
    2245:	mov    rsi,r12
    2248:	mov    rdi,r13
    224b:	call   2250 <botlish_fn_31+0x178>
			224c: R_X86_64_PLT32	botlish_fn_30-0x4 ; ht_probe_next<HashTable, int>
    2250:	test   rax,rax
    2253:	jne    227e <botlish_fn_31+0x1a6>
    2259:	xor    rax,rax
    225c:	mov    rbx,QWORD PTR [rsp+0x20]
    2261:	mov    r12,QWORD PTR [rsp+0x28]
    2266:	mov    r13,QWORD PTR [rsp+0x30]
    226b:	mov    r14,QWORD PTR [rsp+0x38]
    2270:	mov    r15,QWORD PTR [rsp+0x40]
    2275:	add    rsp,0x50
    2279:	mov    rsp,rbp
    227c:	pop    rbp
    227d:	ret
    227e:	mov    QWORD PTR [rsp],r12
    2282:	mov    QWORD PTR [rsp+0x8],rbx
    2287:	mov    QWORD PTR [rsp+0x10],rax
    228c:	mov    r14,rax
    228f:	jmp    2113 <botlish_fn_31+0x3b>
    2294:	mov    rax,r14
    2297:	mov    rbx,QWORD PTR [rsp+0x20]
    229c:	mov    r12,QWORD PTR [rsp+0x28]
    22a1:	mov    r13,QWORD PTR [rsp+0x30]
    22a6:	mov    r14,QWORD PTR [rsp+0x38]
    22ab:	mov    r15,QWORD PTR [rsp+0x40]
    22b0:	add    rsp,0x50
    22b4:	mov    rsp,rbp
    22b7:	pop    rbp
    22b8:	ret
    22b9:	mov    rax,0xffffffffffffffff
    22c0:	mov    rbx,QWORD PTR [rsp+0x20]
    22c5:	mov    r12,QWORD PTR [rsp+0x28]
    22ca:	mov    r13,QWORD PTR [rsp+0x30]
    22cf:	mov    r14,QWORD PTR [rsp+0x38]
    22d4:	mov    r15,QWORD PTR [rsp+0x40]
    22d9:	add    rsp,0x50
    22dd:	mov    rsp,rbp
    22e0:	pop    rbp
    22e1:	ret
    22e2:	add    BYTE PTR [rax],al
    22e4:	add    BYTE PTR [rax],al
    22e6:	add    BYTE PTR [rax],al
    22e8:	(bad)
    22e9:	add    BYTE PTR [rax],al
    22eb:	add    BYTE PTR [rax],al
    22ed:	add    BYTE PTR [rax],al
	...

00000000000022f0 <botlish_entry_31: ht_find_get<HashTable, str, int>>:
    22f0:	push   rbp
    22f1:	mov    rbp,rsp
    22f4:	mov    rsi,QWORD PTR [rdx]
    22f7:	mov    r8,QWORD PTR [rdx+0x8]
    22fb:	mov    rcx,QWORD PTR [rdx+0x10]
    22ff:	mov    rdx,r8
    2302:	call   2307 <botlish_entry_31+0x17>
			2303: R_X86_64_PLT32	botlish_fn_31-0x4 ; ht_find_get<HashTable, str, int>
    2307:	mov    rsp,rbp
    230a:	pop    rbp
    230b:	ret
    230c:	add    BYTE PTR [rax],al
	...

0000000000002310 <botlish_fn_32: ht_find_insert<HashTable, str, int, int>>:
    2310:	push   rbp
    2311:	mov    rbp,rsp
    2314:	sub    rsp,0x60
    2318:	mov    QWORD PTR [rsp+0x30],rbx
    231d:	mov    QWORD PTR [rsp+0x38],r12
    2322:	mov    QWORD PTR [rsp+0x40],r13
    2327:	mov    QWORD PTR [rsp+0x48],r14
    232c:	mov    QWORD PTR [rsp+0x50],r15
    2331:	mov    r15,rdi
    2334:	mov    QWORD PTR [rsp],rsi
    2338:	mov    QWORD PTR [rsp+0x8],rdx
    233d:	mov    rbx,rdx
    2340:	mov    QWORD PTR [rsp+0x10],rcx
    2345:	mov    rax,rcx
    2348:	mov    QWORD PTR [rsp+0x18],r8
    234d:	mov    r13,rsi
    2350:	mov    QWORD PTR [rsp+0x20],r8
    2355:	mov    rcx,QWORD PTR [r13+0x18]
    2359:	mov    rsi,QWORD PTR [rcx]
    235c:	mov    r12,rax
    235f:	mov    rdx,r12
    2362:	mov    rdi,r15
    2365:	call   236a <botlish_fn_32+0x5a>
			2366: R_X86_64_PLT32	rt_mutarray_get-0x4
    236a:	mov    rcx,rax
    236d:	mov    r14,rax
    2370:	test   rax,rcx
    2373:	je     258d <botlish_fn_32+0x27d>
    2379:	mov    rax,r14
    237c:	test   rax,0x1
    2382:	jne    23ad <botlish_fn_32+0x9d>
    2388:	mov    edx,0x1
    238d:	mov    rsi,r14
    2390:	mov    rdi,r15
    2393:	call   2398 <botlish_fn_32+0x88>
			2394: R_X86_64_PLT32	rt_int_cmp-0x4
    2398:	mov    ecx,0x2
    239d:	test   rax,rax
    23a0:	cmove  rcx,QWORD PTR [rip+0x2d8]        # 2680 <botlish_fn_32+0x370>
    23a8:	jmp    23c1 <botlish_fn_32+0xb1>
    23ad:	mov    ecx,0x2
    23b2:	mov    rax,r14
    23b5:	cmp    rax,0x1
    23b9:	cmove  rcx,QWORD PTR [rip+0x2bf]        # 2680 <botlish_fn_32+0x370>
    23c1:	cmp    rcx,0x6
    23c5:	je     25d7 <botlish_fn_32+0x2c7>
    23cb:	mov    rax,r14
    23ce:	test   rax,0x1
    23d4:	jne    23ff <botlish_fn_32+0xef>
    23da:	mov    edx,0x3
    23df:	mov    rsi,r14
    23e2:	mov    rdi,r15
    23e5:	call   23ea <botlish_fn_32+0xda>
			23e6: R_X86_64_PLT32	rt_int_cmp-0x4
    23ea:	mov    ecx,0x2
    23ef:	test   rax,rax
    23f2:	cmove  rcx,QWORD PTR [rip+0x286]        # 2680 <botlish_fn_32+0x370>
    23fa:	jmp    2413 <botlish_fn_32+0x103>
    23ff:	mov    ecx,0x2
    2404:	mov    rax,r14
    2407:	cmp    rax,0x3
    240b:	cmove  rcx,QWORD PTR [rip+0x26d]        # 2680 <botlish_fn_32+0x370>
    2413:	cmp    rcx,0x6
    2417:	je     2425 <botlish_fn_32+0x115>
    241d:	mov    rax,r14
    2420:	jmp    248d <botlish_fn_32+0x17d>
    2425:	mov    rax,QWORD PTR [r13+0x18]
    2429:	mov    rsi,QWORD PTR [rax+0x8]
    242d:	mov    rdx,r12
    2430:	mov    rdi,r15
    2433:	call   2438 <botlish_fn_32+0x128>
			2434: R_X86_64_PLT32	rt_mutarray_get-0x4
    2438:	test   rax,rax
    243b:	je     258d <botlish_fn_32+0x27d>
    2441:	mov    rcx,rax
    2444:	and    rcx,rbx
    2447:	mov    rsi,rax
    244a:	test   rcx,0x1
    2451:	jne    2470 <botlish_fn_32+0x160>
    2457:	mov    rdx,rbx
    245a:	mov    rdi,r15
    245d:	call   2462 <botlish_fn_32+0x152>
			245e: R_X86_64_PLT32	rt_value_eq-0x4
    2462:	test   rax,rax
    2465:	je     258d <botlish_fn_32+0x27d>
    246b:	jmp    2480 <botlish_fn_32+0x170>
    2470:	mov    eax,0x2
    2475:	cmp    rsi,rbx
    2478:	cmove  rax,QWORD PTR [rip+0x200]        # 2680 <botlish_fn_32+0x370>
    2480:	cmp    rax,0x6
    2484:	je     25cf <botlish_fn_32+0x2bf>
    248a:	mov    rax,r14
    248d:	test   rax,0x1
    2493:	mov    r14,rax
    2496:	jne    24c1 <botlish_fn_32+0x1b1>
    249c:	mov    edx,0x5
    24a1:	mov    rsi,r14
    24a4:	mov    rdi,r15
    24a7:	call   24ac <botlish_fn_32+0x19c>
			24a8: R_X86_64_PLT32	rt_int_cmp-0x4
    24ac:	mov    ecx,0x2
    24b1:	test   rax,rax
    24b4:	cmove  rcx,QWORD PTR [rip+0x1c4]        # 2680 <botlish_fn_32+0x370>
    24bc:	jmp    24d5 <botlish_fn_32+0x1c5>
    24c1:	mov    rsi,r14
    24c4:	mov    ecx,0x2
    24c9:	cmp    rsi,0x5
    24cd:	cmove  rcx,QWORD PTR [rip+0x1ab]        # 2680 <botlish_fn_32+0x370>
    24d5:	cmp    rcx,0x6
    24d9:	je     24e7 <botlish_fn_32+0x1d7>
    24df:	mov    rdx,r12
    24e2:	jmp    2545 <botlish_fn_32+0x235>
    24e7:	mov    r14,QWORD PTR [rsp+0x20]
    24ec:	test   r14,0x1
    24f3:	jne    2523 <botlish_fn_32+0x213>
    24f9:	mov    edx,0x1
    24fe:	mov    rsi,r14
    2501:	mov    rdi,r15
    2504:	call   2509 <botlish_fn_32+0x1f9>
			2505: R_X86_64_PLT32	rt_int_cmp-0x4
    2509:	mov    ecx,0x2
    250e:	test   rax,rax
    2511:	cmovl  rcx,QWORD PTR [rip+0x167]        # 2680 <botlish_fn_32+0x370>
    2519:	mov    QWORD PTR [rsp+0x20],r14
    251e:	jmp    2538 <botlish_fn_32+0x228>
    2523:	mov    ecx,0x2
    2528:	test   r14,r14
    252b:	mov    QWORD PTR [rsp+0x20],r14
    2530:	cmovle rcx,QWORD PTR [rip+0x148]        # 2680 <botlish_fn_32+0x370>
    2538:	cmp    rcx,0x6
    253c:	je     2576 <botlish_fn_32+0x266>
    2542:	mov    rdx,r12
    2545:	mov    rsi,r13
    2548:	mov    rdi,r15
    254b:	call   2550 <botlish_fn_32+0x240>
			254c: R_X86_64_PLT32	botlish_fn_30-0x4 ; ht_probe_next<HashTable, int>
    2550:	test   rax,rax
    2553:	je     258d <botlish_fn_32+0x27d>
    2559:	mov    QWORD PTR [rsp],r13
    255d:	mov    QWORD PTR [rsp+0x8],rbx
    2562:	mov    QWORD PTR [rsp+0x10],rax
    2567:	mov    rcx,QWORD PTR [rsp+0x20]
    256c:	mov    QWORD PTR [rsp+0x18],rcx
    2571:	jmp    2355 <botlish_fn_32+0x45>
    2576:	mov    rdx,r12
    2579:	mov    rsi,r13
    257c:	mov    rdi,r15
    257f:	call   2584 <botlish_fn_32+0x274>
			2580: R_X86_64_PLT32	botlish_fn_30-0x4 ; ht_probe_next<HashTable, int>
    2584:	test   rax,rax
    2587:	jne    25b2 <botlish_fn_32+0x2a2>
    258d:	xor    rax,rax
    2590:	mov    rbx,QWORD PTR [rsp+0x30]
    2595:	mov    r12,QWORD PTR [rsp+0x38]
    259a:	mov    r13,QWORD PTR [rsp+0x40]
    259f:	mov    r14,QWORD PTR [rsp+0x48]
    25a4:	mov    r15,QWORD PTR [rsp+0x50]
    25a9:	add    rsp,0x60
    25ad:	mov    rsp,rbp
    25b0:	pop    rbp
    25b1:	ret
    25b2:	mov    QWORD PTR [rsp],r13
    25b6:	mov    QWORD PTR [rsp+0x8],rbx
    25bb:	mov    QWORD PTR [rsp+0x10],rax
    25c0:	mov    QWORD PTR [rsp+0x18],r12
    25c5:	mov    QWORD PTR [rsp+0x20],r12
    25ca:	jmp    2355 <botlish_fn_32+0x45>
    25cf:	mov    rax,r12
    25d2:	jmp    2636 <botlish_fn_32+0x326>
    25d7:	mov    rax,QWORD PTR [rsp+0x20]
    25dc:	test   rax,0x1
    25e2:	jne    260f <botlish_fn_32+0x2ff>
    25e8:	mov    edx,0x1
    25ed:	mov    rdi,r15
    25f0:	mov    rsi,QWORD PTR [rsp+0x20]
    25f5:	call   25fa <botlish_fn_32+0x2ea>
			25f6: R_X86_64_PLT32	rt_int_cmp-0x4
    25fa:	mov    ecx,0x2
    25ff:	test   rax,rax
    2602:	cmovge rcx,QWORD PTR [rip+0x76]        # 2680 <botlish_fn_32+0x370>
    260a:	jmp    2629 <botlish_fn_32+0x319>
    260f:	mov    ecx,0x2
    2614:	mov    rax,QWORD PTR [rsp+0x20]
    2619:	mov    r11,QWORD PTR [rsp+0x20]
    261e:	test   rax,r11
    2621:	cmovg  rcx,QWORD PTR [rip+0x57]        # 2680 <botlish_fn_32+0x370>
    2629:	cmp    rcx,0x6
    262d:	je     2658 <botlish_fn_32+0x348>
    2633:	mov    rax,r12
    2636:	mov    rbx,QWORD PTR [rsp+0x30]
    263b:	mov    r12,QWORD PTR [rsp+0x38]
    2640:	mov    r13,QWORD PTR [rsp+0x40]
    2645:	mov    r14,QWORD PTR [rsp+0x48]
    264a:	mov    r15,QWORD PTR [rsp+0x50]
    264f:	add    rsp,0x60
    2653:	mov    rsp,rbp
    2656:	pop    rbp
    2657:	ret
    2658:	mov    rax,QWORD PTR [rsp+0x20]
    265d:	mov    rbx,QWORD PTR [rsp+0x30]
    2662:	mov    r12,QWORD PTR [rsp+0x38]
    2667:	mov    r13,QWORD PTR [rsp+0x40]
    266c:	mov    r14,QWORD PTR [rsp+0x48]
    2671:	mov    r15,QWORD PTR [rsp+0x50]
    2676:	add    rsp,0x60
    267a:	mov    rsp,rbp
    267d:	pop    rbp
    267e:	ret
    267f:	add    BYTE PTR [rsi],al
    2681:	add    BYTE PTR [rax],al
    2683:	add    BYTE PTR [rax],al
    2685:	add    BYTE PTR [rax],al
	...

0000000000002688 <botlish_entry_32: ht_find_insert<HashTable, str, int, int>>:
    2688:	push   rbp
    2689:	mov    rbp,rsp
    268c:	mov    rsi,QWORD PTR [rdx]
    268f:	mov    r9,QWORD PTR [rdx+0x8]
    2693:	mov    rcx,QWORD PTR [rdx+0x10]
    2697:	mov    r8,QWORD PTR [rdx+0x18]
    269b:	mov    rdx,r9
    269e:	call   26a3 <botlish_entry_32+0x1b>
			269f: R_X86_64_PLT32	botlish_fn_32-0x4 ; ht_find_insert<HashTable, str, int, int>
    26a3:	mov    rsp,rbp
    26a6:	pop    rbp
    26a7:	ret

00000000000026a8 <botlish_fn_33: ht_get<HashTable, str>>:
    26a8:	push   rbp
    26a9:	mov    rbp,rsp
    26ac:	sub    rsp,0x40
    26b0:	mov    QWORD PTR [rsp+0x20],rbx
    26b5:	mov    QWORD PTR [rsp+0x28],r12
    26ba:	mov    QWORD PTR [rsp+0x30],r13
    26bf:	mov    r12,rdi
    26c2:	mov    QWORD PTR [rsp+0x10],0x0
    26cb:	mov    QWORD PTR [rsp],rsi
    26cf:	mov    QWORD PTR [rsp+0x8],rdx
    26d4:	mov    r13,rdx
    26d7:	mov    rbx,rsi
    26da:	mov    rdx,r13
    26dd:	mov    rdi,r12
    26e0:	call   26e5 <botlish_fn_33+0x3d>
			26e1: R_X86_64_PLT32	botlish_fn_29-0x4 ; ht_probe_start<HashTable, str>
    26e5:	test   rax,rax
    26e8:	je     2780 <botlish_fn_33+0xd8>
    26ee:	mov    QWORD PTR [rsp+0x10],rax
    26f3:	mov    rcx,rax
    26f6:	mov    rdx,r13
    26f9:	mov    rsi,rbx
    26fc:	mov    rdi,r12
    26ff:	call   2704 <botlish_fn_33+0x5c>
			2700: R_X86_64_PLT32	botlish_fn_31-0x4 ; ht_find_get<HashTable, str, int>
    2704:	mov    rcx,rax
    2707:	mov    r13,rax
    270a:	test   rax,rcx
    270d:	je     2780 <botlish_fn_33+0xd8>
    2713:	mov    rax,r13
    2716:	test   rax,0x1
    271c:	jne    2747 <botlish_fn_33+0x9f>
    2722:	mov    edx,0x1
    2727:	mov    rsi,r13
    272a:	mov    rdi,r12
    272d:	call   2732 <botlish_fn_33+0x8a>
			272e: R_X86_64_PLT32	rt_int_cmp-0x4
    2732:	mov    ecx,0x2
    2737:	test   rax,rax
    273a:	cmovl  rcx,QWORD PTR [rip+0x8e]        # 27d0 <botlish_fn_33+0x128>
    2742:	jmp    275a <botlish_fn_33+0xb2>
    2747:	mov    ecx,0x2
    274c:	mov    rax,r13
    274f:	test   rax,rax
    2752:	cmovle rcx,QWORD PTR [rip+0x76]        # 27d0 <botlish_fn_33+0x128>
    275a:	cmp    rcx,0x6
    275e:	je     27b3 <botlish_fn_33+0x10b>
    2764:	mov    rax,QWORD PTR [rbx+0x18]
    2768:	mov    rsi,QWORD PTR [rax+0x10]
    276c:	mov    rdx,r13
    276f:	mov    rdi,r12
    2772:	call   2777 <botlish_fn_33+0xcf>
			2773: R_X86_64_PLT32	rt_mutarray_get-0x4
    2777:	test   rax,rax
    277a:	jne    279b <botlish_fn_33+0xf3>
    2780:	xor    rax,rax
    2783:	mov    rbx,QWORD PTR [rsp+0x20]
    2788:	mov    r12,QWORD PTR [rsp+0x28]
    278d:	mov    r13,QWORD PTR [rsp+0x30]
    2792:	add    rsp,0x40
    2796:	mov    rsp,rbp
    2799:	pop    rbp
    279a:	ret
    279b:	mov    rbx,QWORD PTR [rsp+0x20]
    27a0:	mov    r12,QWORD PTR [rsp+0x28]
    27a5:	mov    r13,QWORD PTR [rsp+0x30]
    27aa:	add    rsp,0x40
    27ae:	mov    rsp,rbp
    27b1:	pop    rbp
    27b2:	ret
    27b3:	mov    eax,0xa
    27b8:	mov    rbx,QWORD PTR [rsp+0x20]
    27bd:	mov    r12,QWORD PTR [rsp+0x28]
    27c2:	mov    r13,QWORD PTR [rsp+0x30]
    27c7:	add    rsp,0x40
    27cb:	mov    rsp,rbp
    27ce:	pop    rbp
    27cf:	ret
    27d0:	(bad)
    27d1:	add    BYTE PTR [rax],al
    27d3:	add    BYTE PTR [rax],al
    27d5:	add    BYTE PTR [rax],al
	...

00000000000027d8 <botlish_entry_33: ht_get<HashTable, str>>:
    27d8:	push   rbp
    27d9:	mov    rbp,rsp
    27dc:	mov    rsi,QWORD PTR [rdx]
    27df:	mov    rdx,QWORD PTR [rdx+0x8]
    27e3:	call   27e8 <botlish_entry_33+0x10>
			27e4: R_X86_64_PLT32	botlish_fn_33-0x4 ; ht_get<HashTable, str>
    27e8:	mov    rsp,rbp
    27eb:	pop    rbp
    27ec:	ret
    27ed:	add    BYTE PTR [rax],al
	...

00000000000027f0 <botlish_fn_34: ht_rehash_probe<mutarray, int, int>>:
    27f0:	push   rbp
    27f1:	mov    rbp,rsp
    27f4:	sub    rsp,0x40
    27f8:	mov    QWORD PTR [rsp+0x20],rbx
    27fd:	mov    QWORD PTR [rsp+0x28],r12
    2802:	mov    QWORD PTR [rsp+0x30],r13
    2807:	mov    QWORD PTR [rsp+0x38],r14
    280c:	mov    r13,rdi
    280f:	mov    QWORD PTR [rsp],rsi
    2813:	mov    QWORD PTR [rsp+0x8],rdx
    2818:	mov    QWORD PTR [rsp+0x10],rcx
    281d:	mov    r12,rcx
    2820:	mov    rbx,rsi
    2823:	mov    r14,rdx
    2826:	mov    rdx,r14
    2829:	mov    rsi,rbx
    282c:	mov    rdi,r13
    282f:	call   2834 <botlish_fn_34+0x44>
			2830: R_X86_64_PLT32	rt_mutarray_get-0x4
    2834:	test   rax,rax
    2837:	je     28d9 <botlish_fn_34+0xe9>
    283d:	test   rax,0x1
    2843:	mov    rsi,rax
    2846:	jne    2867 <botlish_fn_34+0x77>
    284c:	mov    edx,0x1
    2851:	mov    rdi,r13
    2854:	call   2859 <botlish_fn_34+0x69>
			2855: R_X86_64_PLT32	rt_value_eq-0x4
    2859:	test   rax,rax
    285c:	je     28d9 <botlish_fn_34+0xe9>
    2862:	jmp    2878 <botlish_fn_34+0x88>
    2867:	mov    eax,0x2
    286c:	cmp    rsi,0x1
    2870:	cmove  rax,QWORD PTR [rip+0xb8]        # 2930 <botlish_fn_34+0x140>
    2878:	cmp    rax,0x6
    287c:	je     290f <botlish_fn_34+0x11f>
    2882:	mov    QWORD PTR [rsp+0x18],0x3
    288b:	mov    rsi,r14
    288e:	test   rsi,0x1
    2895:	je     28ad <botlish_fn_34+0xbd>
    289b:	mov    rsi,r14
    289e:	add    rsi,0x2
    28a2:	seto   al
    28a5:	test   al,al
    28a7:	je     28c0 <botlish_fn_34+0xd0>
    28ad:	mov    edx,0x3
    28b2:	mov    rsi,r14
    28b5:	mov    rdi,r13
    28b8:	call   28bd <botlish_fn_34+0xcd>
			28b9: R_X86_64_PLT32	rt_int_add-0x4
    28bd:	mov    rsi,rax
    28c0:	mov    QWORD PTR [rsp+0x8],rsi
    28c5:	mov    rdx,r12
    28c8:	mov    rdi,r13
    28cb:	call   28d0 <botlish_fn_34+0xe0>
			28cc: R_X86_64_PLT32	rt_int_mod-0x4
    28d0:	test   rax,rax
    28d3:	jne    28f9 <botlish_fn_34+0x109>
    28d9:	xor    rax,rax
    28dc:	mov    rbx,QWORD PTR [rsp+0x20]
    28e1:	mov    r12,QWORD PTR [rsp+0x28]
    28e6:	mov    r13,QWORD PTR [rsp+0x30]
    28eb:	mov    r14,QWORD PTR [rsp+0x38]
    28f0:	add    rsp,0x40
    28f4:	mov    rsp,rbp
    28f7:	pop    rbp
    28f8:	ret
    28f9:	mov    QWORD PTR [rsp],rbx
    28fd:	mov    QWORD PTR [rsp+0x8],rax
    2902:	mov    QWORD PTR [rsp+0x10],r12
    2907:	mov    r14,rax
    290a:	jmp    2826 <botlish_fn_34+0x36>
    290f:	mov    rax,r14
    2912:	mov    rbx,QWORD PTR [rsp+0x20]
    2917:	mov    r12,QWORD PTR [rsp+0x28]
    291c:	mov    r13,QWORD PTR [rsp+0x30]
    2921:	mov    r14,QWORD PTR [rsp+0x38]
    2926:	add    rsp,0x40
    292a:	mov    rsp,rbp
    292d:	pop    rbp
    292e:	ret
    292f:	add    BYTE PTR [rsi],al
    2931:	add    BYTE PTR [rax],al
    2933:	add    BYTE PTR [rax],al
    2935:	add    BYTE PTR [rax],al
	...

0000000000002938 <botlish_entry_34: ht_rehash_probe<mutarray, int, int>>:
    2938:	push   rbp
    2939:	mov    rbp,rsp
    293c:	mov    rsi,QWORD PTR [rdx]
    293f:	mov    r8,QWORD PTR [rdx+0x8]
    2943:	mov    rcx,QWORD PTR [rdx+0x10]
    2947:	mov    rdx,r8
    294a:	call   294f <botlish_entry_34+0x17>
			294b: R_X86_64_PLT32	botlish_fn_34-0x4 ; ht_rehash_probe<mutarray, int, int>
    294f:	mov    rsp,rbp
    2952:	pop    rbp
    2953:	ret

0000000000002954 <botlish_fn_35: ht_rehash_insert<HashTable, int, any, any>>:
    2954:	push   rbp
    2955:	mov    rbp,rsp
    2958:	sub    rsp,0x70
    295c:	mov    QWORD PTR [rsp+0x40],rbx
    2961:	mov    QWORD PTR [rsp+0x48],r12
    2966:	mov    QWORD PTR [rsp+0x50],r13
    296b:	mov    QWORD PTR [rsp+0x58],r14
    2970:	mov    QWORD PTR [rsp+0x60],r15
    2975:	mov    r13,rdi
    2978:	mov    QWORD PTR [rsp],rsi
    297c:	mov    QWORD PTR [rsp+0x8],rdx
    2981:	mov    r15,rdx
    2984:	mov    QWORD PTR [rsp+0x10],rcx
    2989:	mov    r14,rcx
    298c:	mov    QWORD PTR [rsp+0x18],r8
    2991:	mov    r12,r8
    2994:	mov    rax,QWORD PTR [rsi+0x18]
    2998:	mov    rbx,rsi
    299b:	mov    rsi,QWORD PTR [rax]
    299e:	mov    QWORD PTR [rsp+0x20],rsi
    29a3:	mov    QWORD PTR [rsp+0x30],rsi
    29a8:	mov    rsi,r14
    29ab:	mov    rdi,r13
    29ae:	call   29b3 <botlish_fn_35+0x5f>
			29af: R_X86_64_PLT32	rt_hash-0x4
    29b3:	test   rax,rax
    29b6:	je     2a5d <botlish_fn_35+0x109>
    29bc:	mov    QWORD PTR [rsp+0x28],rax
    29c1:	mov    rsi,rax
    29c4:	mov    rdx,r15
    29c7:	mov    rdi,r13
    29ca:	call   29cf <botlish_fn_35+0x7b>
			29cb: R_X86_64_PLT32	rt_int_mod-0x4
    29cf:	test   rax,rax
    29d2:	je     2a5d <botlish_fn_35+0x109>
    29d8:	mov    QWORD PTR [rsp+0x28],rax
    29dd:	mov    rcx,r15
    29e0:	mov    rdx,rax
    29e3:	mov    rsi,QWORD PTR [rsp+0x30]
    29e8:	mov    rdi,r13
    29eb:	call   29f0 <botlish_fn_35+0x9c>
			29ec: R_X86_64_PLT32	botlish_fn_34-0x4 ; ht_rehash_probe<mutarray, int, int>
    29f0:	mov    rdx,rax
    29f3:	mov    r15,rax
    29f6:	test   rax,rdx
    29f9:	je     2a5d <botlish_fn_35+0x109>
    29ff:	mov    rcx,QWORD PTR [rbx+0x18]
    2a03:	mov    rsi,QWORD PTR [rcx]
    2a06:	mov    ecx,0x3
    2a0b:	mov    rdx,r15
    2a0e:	mov    rdi,r13
    2a11:	call   2a16 <botlish_fn_35+0xc2>
			2a12: R_X86_64_PLT32	rt_mutarray_set-0x4
    2a16:	test   rax,rax
    2a19:	je     2a5d <botlish_fn_35+0x109>
    2a1f:	mov    rax,QWORD PTR [rbx+0x18]
    2a23:	mov    rsi,QWORD PTR [rax+0x8]
    2a27:	mov    rcx,r14
    2a2a:	mov    rdx,r15
    2a2d:	mov    rdi,r13
    2a30:	call   2a35 <botlish_fn_35+0xe1>
			2a31: R_X86_64_PLT32	rt_mutarray_set-0x4
    2a35:	test   rax,rax
    2a38:	je     2a5d <botlish_fn_35+0x109>
    2a3e:	mov    rax,QWORD PTR [rbx+0x18]
    2a42:	mov    rsi,QWORD PTR [rax+0x10]
    2a46:	mov    rcx,r12
    2a49:	mov    rdx,r15
    2a4c:	mov    rdi,r13
    2a4f:	call   2a54 <botlish_fn_35+0x100>
			2a50: R_X86_64_PLT32	rt_mutarray_set-0x4
    2a54:	test   rax,rax
    2a57:	jne    2a82 <botlish_fn_35+0x12e>
    2a5d:	xor    rax,rax
    2a60:	mov    rbx,QWORD PTR [rsp+0x40]
    2a65:	mov    r12,QWORD PTR [rsp+0x48]
    2a6a:	mov    r13,QWORD PTR [rsp+0x50]
    2a6f:	mov    r14,QWORD PTR [rsp+0x58]
    2a74:	mov    r15,QWORD PTR [rsp+0x60]
    2a79:	add    rsp,0x70
    2a7d:	mov    rsp,rbp
    2a80:	pop    rbp
    2a81:	ret
    2a82:	mov    rax,rbx
    2a85:	mov    rbx,QWORD PTR [rsp+0x40]
    2a8a:	mov    r12,QWORD PTR [rsp+0x48]
    2a8f:	mov    r13,QWORD PTR [rsp+0x50]
    2a94:	mov    r14,QWORD PTR [rsp+0x58]
    2a99:	mov    r15,QWORD PTR [rsp+0x60]
    2a9e:	add    rsp,0x70
    2aa2:	mov    rsp,rbp
    2aa5:	pop    rbp
    2aa6:	ret

0000000000002aa7 <botlish_entry_35: ht_rehash_insert<HashTable, int, any, any>>:
    2aa7:	push   rbp
    2aa8:	mov    rbp,rsp
    2aab:	mov    rsi,QWORD PTR [rdx]
    2aae:	mov    r9,QWORD PTR [rdx+0x8]
    2ab2:	mov    rcx,QWORD PTR [rdx+0x10]
    2ab6:	mov    r8,QWORD PTR [rdx+0x18]
    2aba:	mov    rdx,r9
    2abd:	call   2ac2 <botlish_entry_35+0x1b>
			2abe: R_X86_64_PLT32	botlish_fn_35-0x4 ; ht_rehash_insert<HashTable, int, any, any>
    2ac2:	mov    rsp,rbp
    2ac5:	pop    rbp
    2ac6:	ret
	...

0000000000002ac8 <botlish_fn_36: ht_rehash_scan<mutarray, mutarray, mutarray, int, int, HashTable, int>>:
    2ac8:	push   rbp
    2ac9:	mov    rbp,rsp
    2acc:	sub    rsp,0x90
    2ad3:	mov    QWORD PTR [rsp+0x60],rbx
    2ad8:	mov    QWORD PTR [rsp+0x68],r12
    2add:	mov    QWORD PTR [rsp+0x70],r13
    2ae2:	mov    QWORD PTR [rsp+0x78],r14
    2ae7:	mov    QWORD PTR [rsp+0x80],r15
    2aef:	mov    QWORD PTR [rsp+0x38],rdi
    2af4:	mov    QWORD PTR [rsp+0x40],r9
    2af9:	mov    rdi,QWORD PTR [rbp+0x10]
    2afd:	mov    rbx,QWORD PTR [rbp+0x18]
    2b01:	mov    QWORD PTR [rsp],rsi
    2b05:	mov    QWORD PTR [rsp+0x8],rdx
    2b0a:	mov    r14,rdx
    2b0d:	mov    QWORD PTR [rsp+0x10],rcx
    2b12:	mov    r15,rcx
    2b15:	mov    QWORD PTR [rsp+0x18],rdi
    2b1a:	mov    QWORD PTR [rsp+0x20],rbx
    2b1f:	sar    r8,1
    2b22:	mov    rcx,QWORD PTR [rsp+0x40]
    2b27:	mov    r12,r8
    2b2a:	mov    QWORD PTR [rsp+0x48],rdi
    2b2f:	cmp    r12,rcx
    2b32:	mov    QWORD PTR [rsp+0x40],rcx
    2b37:	jge    2c9e <botlish_fn_36+0x1d6>
    2b3d:	mov    rdx,r12
    2b40:	shl    rdx,1
    2b43:	or     rdx,0x1
    2b47:	mov    r13,rsi
    2b4a:	mov    QWORD PTR [rsp+0x58],rdx
    2b4f:	mov    rdi,QWORD PTR [rsp+0x38]
    2b54:	call   2b59 <botlish_fn_36+0x91>
			2b55: R_X86_64_PLT32	rt_mutarray_get-0x4
    2b59:	test   rax,rax
    2b5c:	je     2c42 <botlish_fn_36+0x17a>
    2b62:	test   rax,0x1
    2b68:	mov    rsi,rax
    2b6b:	jne    2b8e <botlish_fn_36+0xc6>
    2b71:	mov    edx,0x3
    2b76:	mov    rdi,QWORD PTR [rsp+0x38]
    2b7b:	call   2b80 <botlish_fn_36+0xb8>
			2b7c: R_X86_64_PLT32	rt_value_eq-0x4
    2b80:	test   rax,rax
    2b83:	je     2c42 <botlish_fn_36+0x17a>
    2b89:	jmp    2b9f <botlish_fn_36+0xd7>
    2b8e:	mov    eax,0x2
    2b93:	cmp    rsi,0x3
    2b97:	cmove  rax,QWORD PTR [rip+0x131]        # 2cd0 <botlish_fn_36+0x208>
    2b9f:	cmp    rax,0x6
    2ba3:	je     2bda <botlish_fn_36+0x112>
    2ba9:	mov    QWORD PTR [rsp],r13
    2bad:	mov    QWORD PTR [rsp+0x8],r14
    2bb2:	mov    QWORD PTR [rsp+0x10],r15
    2bb7:	mov    rsi,QWORD PTR [rsp+0x48]
    2bbc:	mov    QWORD PTR [rsp+0x18],rsi
    2bc1:	mov    QWORD PTR [rsp+0x20],rbx
    2bc6:	add    r12,0x1
    2bcd:	mov    rcx,QWORD PTR [rsp+0x40]
    2bd2:	mov    rsi,r13
    2bd5:	jmp    2b2f <botlish_fn_36+0x67>
    2bda:	mov    rdx,QWORD PTR [rsp+0x58]
    2bdf:	mov    rsi,r14
    2be2:	mov    rdi,QWORD PTR [rsp+0x38]
    2be7:	call   2bec <botlish_fn_36+0x124>
			2be8: R_X86_64_PLT32	rt_mutarray_get-0x4
    2bec:	test   rax,rax
    2bef:	je     2c42 <botlish_fn_36+0x17a>
    2bf5:	mov    QWORD PTR [rsp+0x28],rax
    2bfa:	mov    rdx,QWORD PTR [rsp+0x58]
    2bff:	mov    QWORD PTR [rsp+0x50],rax
    2c04:	mov    rsi,r15
    2c07:	mov    rdi,QWORD PTR [rsp+0x38]
    2c0c:	call   2c11 <botlish_fn_36+0x149>
			2c0d: R_X86_64_PLT32	rt_mutarray_get-0x4
    2c11:	test   rax,rax
    2c14:	je     2c42 <botlish_fn_36+0x17a>
    2c1a:	mov    QWORD PTR [rsp+0x30],rax
    2c1f:	mov    rcx,QWORD PTR [rsp+0x50]
    2c24:	mov    rsi,QWORD PTR [rsp+0x48]
    2c29:	mov    r8,rax
    2c2c:	mov    rdx,rbx
    2c2f:	mov    rdi,QWORD PTR [rsp+0x38]
    2c34:	call   2c39 <botlish_fn_36+0x171>
			2c35: R_X86_64_PLT32	botlish_fn_35-0x4 ; ht_rehash_insert<HashTable, int, any, any>
    2c39:	test   rax,rax
    2c3c:	jne    2c6d <botlish_fn_36+0x1a5>
    2c42:	xor    rax,rax
    2c45:	mov    rbx,QWORD PTR [rsp+0x60]
    2c4a:	mov    r12,QWORD PTR [rsp+0x68]
    2c4f:	mov    r13,QWORD PTR [rsp+0x70]
    2c54:	mov    r14,QWORD PTR [rsp+0x78]
    2c59:	mov    r15,QWORD PTR [rsp+0x80]
    2c61:	add    rsp,0x90
    2c68:	mov    rsp,rbp
    2c6b:	pop    rbp
    2c6c:	ret
    2c6d:	mov    QWORD PTR [rsp],r13
    2c71:	mov    QWORD PTR [rsp+0x8],r14
    2c76:	mov    QWORD PTR [rsp+0x10],r15
    2c7b:	mov    QWORD PTR [rsp+0x18],rax
    2c80:	mov    QWORD PTR [rsp+0x20],rbx
    2c85:	add    r12,0x1
    2c8c:	mov    rcx,QWORD PTR [rsp+0x40]
    2c91:	mov    rsi,r13
    2c94:	mov    QWORD PTR [rsp+0x48],rax
    2c99:	jmp    2b2f <botlish_fn_36+0x67>
    2c9e:	mov    rax,QWORD PTR [rsp+0x48]
    2ca3:	mov    rbx,QWORD PTR [rsp+0x60]
    2ca8:	mov    r12,QWORD PTR [rsp+0x68]
    2cad:	mov    r13,QWORD PTR [rsp+0x70]
    2cb2:	mov    r14,QWORD PTR [rsp+0x78]
    2cb7:	mov    r15,QWORD PTR [rsp+0x80]
    2cbf:	add    rsp,0x90
    2cc6:	mov    rsp,rbp
    2cc9:	pop    rbp
    2cca:	ret
    2ccb:	add    BYTE PTR [rax],al
    2ccd:	add    BYTE PTR [rax],al
    2ccf:	add    BYTE PTR [rsi],al
    2cd1:	add    BYTE PTR [rax],al
    2cd3:	add    BYTE PTR [rax],al
    2cd5:	add    BYTE PTR [rax],al
	...

0000000000002cd8 <botlish_entry_36: ht_rehash_scan<mutarray, mutarray, mutarray, int, int, HashTable, int>>:
    2cd8:	push   rbp
    2cd9:	mov    rbp,rsp
    2cdc:	sub    rsp,0x10
    2ce0:	mov    rsi,QWORD PTR [rdx]
    2ce3:	mov    r11,QWORD PTR [rdx+0x8]
    2ce7:	mov    rcx,QWORD PTR [rdx+0x10]
    2ceb:	mov    r8,QWORD PTR [rdx+0x18]
    2cef:	mov    r9,QWORD PTR [rdx+0x20]
    2cf3:	mov    rax,QWORD PTR [rdx+0x28]
    2cf7:	mov    rdx,QWORD PTR [rdx+0x30]
    2cfb:	sar    r9,1
    2cfe:	mov    QWORD PTR [rsp],rax
    2d02:	mov    QWORD PTR [rsp+0x8],rdx
    2d07:	mov    rdx,r11
    2d0a:	call   2d0f <botlish_entry_36+0x37>
			2d0b: R_X86_64_PLT32	botlish_fn_36-0x4 ; ht_rehash_scan<mutarray, mutarray, mutarray, int, int, HashTable, int>
    2d0f:	add    rsp,0x10
    2d13:	mov    rsp,rbp
    2d16:	pop    rbp
    2d17:	ret

0000000000002d18 <botlish_fn_37: ht_rehash<HashTable, int>>:
    2d18:	push   rbp
    2d19:	mov    rbp,rsp
    2d1c:	sub    rsp,0xf0
    2d23:	mov    QWORD PTR [rsp+0xc0],rbx
    2d2b:	mov    QWORD PTR [rsp+0xc8],r12
    2d33:	mov    QWORD PTR [rsp+0xd0],r13
    2d3b:	mov    QWORD PTR [rsp+0xd8],r14
    2d43:	mov    QWORD PTR [rsp+0xe0],r15
    2d4b:	mov    QWORD PTR [rsp+0x90],rdi
    2d53:	mov    QWORD PTR [rsp+0x20],0x0
    2d5c:	mov    QWORD PTR [rsp+0x28],0x0
    2d65:	mov    QWORD PTR [rsp+0x30],0x0
    2d6e:	mov    QWORD PTR [rsp+0x38],0x0
    2d77:	mov    QWORD PTR [rsp+0x40],0x0
    2d80:	mov    QWORD PTR [rsp+0x48],0x0
    2d89:	mov    QWORD PTR [rsp+0x50],0x0
    2d92:	mov    QWORD PTR [rsp+0x10],rsi
    2d97:	mov    r14,rsi
    2d9a:	mov    QWORD PTR [rsp+0x18],rdx
    2d9f:	mov    QWORD PTR [rsp+0x98],rdx
    2da7:	lea    rdx,[rsp+0x58]
    2dac:	mov    rsi,QWORD PTR [rsp+0x98]
    2db4:	mov    rdi,QWORD PTR [rsp+0x90]
    2dbc:	call   2dc1 <botlish_fn_37+0xa9>
			2dbd: R_X86_64_PLT32	botlish_fn_22-0x4 ; ht_alloc<int>
    2dc1:	test   rax,rax
    2dc4:	je     2f18 <botlish_fn_37+0x200>
    2dca:	mov    QWORD PTR [rsp+0x10],rax
    2dcf:	mov    QWORD PTR [rsp+0xb8],rax
    2dd7:	mov    rbx,QWORD PTR [rsp+0x58]
    2ddc:	mov    QWORD PTR [rsp+0x20],rbx
    2de1:	mov    r12,QWORD PTR [rsp+0x60]
    2de6:	mov    QWORD PTR [rsp+0x28],r12
    2deb:	mov    r13,QWORD PTR [rsp+0x68]
    2df0:	mov    QWORD PTR [rsp+0x30],r13
    2df5:	mov    rsi,r14
    2df8:	mov    rdi,QWORD PTR [rsp+0x90]
    2e00:	call   2e05 <botlish_fn_37+0xed>
			2e01: R_X86_64_PLT32	botlish_fn_26-0x4 ; ht_size<HashTable>
    2e05:	test   rax,rax
    2e08:	mov    rcx,rax
    2e0b:	je     2f18 <botlish_fn_37+0x200>
    2e11:	mov    edx,0x1
    2e16:	mov    rsi,r13
    2e19:	mov    rdi,QWORD PTR [rsp+0x90]
    2e21:	call   2e26 <botlish_fn_37+0x10e>
			2e22: R_X86_64_PLT32	rt_mutarray_set-0x4
    2e26:	test   rax,rax
    2e29:	je     2f18 <botlish_fn_37+0x200>
    2e2f:	mov    rsi,r14
    2e32:	mov    rax,QWORD PTR [rsi+0x18]
    2e36:	mov    rcx,QWORD PTR [rax]
    2e39:	mov    QWORD PTR [rsp+0x38],rcx
    2e3e:	mov    QWORD PTR [rsp+0xb0],rcx
    2e46:	mov    rax,QWORD PTR [rsi+0x18]
    2e4a:	mov    r15,QWORD PTR [rax+0x8]
    2e4e:	mov    QWORD PTR [rsp+0x40],r15
    2e53:	mov    rax,QWORD PTR [rsi+0x18]
    2e57:	mov    r14,QWORD PTR [rax+0x10]
    2e5b:	mov    QWORD PTR [rsp+0x48],r14
    2e60:	mov    r8d,0x1
    2e66:	mov    QWORD PTR [rsp+0xa8],r8
    2e6e:	mov    QWORD PTR [rsp+0x50],0x1
    2e77:	mov    rdi,QWORD PTR [rsp+0x90]
    2e7f:	call   2e84 <botlish_fn_37+0x16c>
			2e80: R_X86_64_PLT32	botlish_fn_28-0x4 ; ht_capacity<HashTable>
    2e84:	mov    QWORD PTR [rsp+0xa0],rax
    2e8c:	lea    rcx,[rsp+0x70]
    2e91:	mov    rax,QWORD PTR [rsp+0xb8]
    2e99:	mov    QWORD PTR [rsp+0x70],rax
    2e9e:	mov    QWORD PTR [rsp+0x78],rbx
    2ea3:	mov    QWORD PTR [rsp+0x80],r12
    2eab:	mov    QWORD PTR [rsp+0x88],r13
    2eb3:	xor    rsi,rsi
    2eb6:	mov    edx,0x4
    2ebb:	mov    rdi,QWORD PTR [rsp+0x90]
    2ec3:	call   2ec8 <botlish_fn_37+0x1b0>
			2ec4: R_X86_64_PLT32	rt_struct_new-0x4
    2ec8:	mov    QWORD PTR [rsp+0x10],rax
    2ecd:	mov    rcx,QWORD PTR [rsp+0xa0]
    2ed5:	mov    r9,rcx
    2ed8:	sar    r9,1
    2edb:	mov    QWORD PTR [rsp],rax
    2edf:	mov    rdx,QWORD PTR [rsp+0x98]
    2ee7:	mov    QWORD PTR [rsp+0x8],rdx
    2eec:	mov    rcx,r14
    2eef:	mov    rdx,r15
    2ef2:	mov    rsi,QWORD PTR [rsp+0xb0]
    2efa:	mov    rdi,QWORD PTR [rsp+0x90]
    2f02:	mov    r8,QWORD PTR [rsp+0xa8]
    2f0a:	call   2f0f <botlish_fn_37+0x1f7>
			2f0b: R_X86_64_PLT32	botlish_fn_36-0x4 ; ht_rehash_scan<mutarray, mutarray, mutarray, int, int, HashTable, int>
    2f0f:	test   rax,rax
    2f12:	jne    2f4f <botlish_fn_37+0x237>
    2f18:	xor    rax,rax
    2f1b:	mov    rbx,QWORD PTR [rsp+0xc0]
    2f23:	mov    r12,QWORD PTR [rsp+0xc8]
    2f2b:	mov    r13,QWORD PTR [rsp+0xd0]
    2f33:	mov    r14,QWORD PTR [rsp+0xd8]
    2f3b:	mov    r15,QWORD PTR [rsp+0xe0]
    2f43:	add    rsp,0xf0
    2f4a:	mov    rsp,rbp
    2f4d:	pop    rbp
    2f4e:	ret
    2f4f:	mov    rbx,QWORD PTR [rsp+0xc0]
    2f57:	mov    r12,QWORD PTR [rsp+0xc8]
    2f5f:	mov    r13,QWORD PTR [rsp+0xd0]
    2f67:	mov    r14,QWORD PTR [rsp+0xd8]
    2f6f:	mov    r15,QWORD PTR [rsp+0xe0]
    2f77:	add    rsp,0xf0
    2f7e:	mov    rsp,rbp
    2f81:	pop    rbp
    2f82:	ret

0000000000002f83 <botlish_entry_37: ht_rehash<HashTable, int>>:
    2f83:	push   rbp
    2f84:	mov    rbp,rsp
    2f87:	mov    rsi,QWORD PTR [rdx]
    2f8a:	mov    rdx,QWORD PTR [rdx+0x8]
    2f8e:	call   2f93 <botlish_entry_37+0x10>
			2f8f: R_X86_64_PLT32	botlish_fn_37-0x4 ; ht_rehash<HashTable, int>
    2f93:	mov    rsp,rbp
    2f96:	pop    rbp
    2f97:	ret

0000000000002f98 <botlish_fn_38: ht_should_grow<HashTable>>:
    2f98:	push   rbp
    2f99:	mov    rbp,rsp
    2f9c:	sub    rsp,0x40
    2fa0:	mov    QWORD PTR [rsp+0x20],rbx
    2fa5:	mov    QWORD PTR [rsp+0x28],r12
    2faa:	mov    QWORD PTR [rsp+0x30],r13
    2faf:	mov    rbx,rdi
    2fb2:	mov    QWORD PTR [rsp],rsi
    2fb6:	mov    r12,rsi
    2fb9:	mov    rsi,r12
    2fbc:	mov    rdi,rbx
    2fbf:	call   2fc4 <botlish_fn_38+0x2c>
			2fc0: R_X86_64_PLT32	botlish_fn_26-0x4 ; ht_size<HashTable>
    2fc4:	mov    rcx,rax
    2fc7:	mov    r13,rax
    2fca:	test   rax,rcx
    2fcd:	je     30a6 <botlish_fn_38+0x10e>
    2fd3:	mov    rax,r13
    2fd6:	mov    QWORD PTR [rsp+0x8],rax
    2fdb:	mov    rsi,r12
    2fde:	mov    rdi,rbx
    2fe1:	call   2fe6 <botlish_fn_38+0x4e>
			2fe2: R_X86_64_PLT32	botlish_fn_27-0x4 ; ht_tombstones<HashTable>
    2fe6:	mov    rcx,rax
    2fe9:	test   rcx,rcx
    2fec:	je     30a6 <botlish_fn_38+0x10e>
    2ff2:	mov    QWORD PTR [rsp+0x10],rcx
    2ff7:	mov    edx,0x1
    2ffc:	mov    rax,r13
    2fff:	test   rax,0x1
    3005:	jne    3028 <botlish_fn_38+0x90>
    300b:	xor    edx,edx
    300d:	mov    rax,r13
    3010:	test   rax,0x7
    3016:	jne    3028 <botlish_fn_38+0x90>
    301c:	mov    rax,r13
    301f:	movzx  rax,BYTE PTR [rax]
    3023:	cmp    al,0x1
    3025:	sete   dl
    3028:	test   dl,dl
    302a:	jne    304b <botlish_fn_38+0xb3>
    3030:	mov    rdi,rbx
    3033:	mov    rax,QWORD PTR [rdi+0x10]
    3037:	mov    rcx,QWORD PTR [rax+0x8]
    303b:	xor    rdx,rdx
    303e:	mov    rsi,r13
    3041:	call   3046 <botlish_fn_38+0xae>
			3042: R_X86_64_PLT32	rt_type_error-0x4
    3046:	jmp    30a6 <botlish_fn_38+0x10e>
    304b:	mov    eax,0x1
    3050:	test   rcx,0x1
    3057:	je     3065 <botlish_fn_38+0xcd>
    305d:	mov    r8,rcx
    3060:	jmp    3088 <botlish_fn_38+0xf0>
    3065:	xor    eax,eax
    3067:	test   rcx,0x7
    306e:	je     307c <botlish_fn_38+0xe4>
    3074:	mov    r8,rcx
    3077:	jmp    3088 <botlish_fn_38+0xf0>
    307c:	movzx  rax,BYTE PTR [rcx]
    3080:	mov    r8,rcx
    3083:	cmp    al,0x1
    3085:	sete   al
    3088:	test   al,al
    308a:	jne    30c1 <botlish_fn_38+0x129>
    3090:	mov    rdi,rbx
    3093:	mov    rax,QWORD PTR [rdi+0x10]
    3097:	mov    rcx,QWORD PTR [rax+0x8]
    309b:	xor    rdx,rdx
    309e:	mov    rsi,r8
    30a1:	call   30a6 <botlish_fn_38+0x10e>
			30a2: R_X86_64_PLT32	rt_type_error-0x4
    30a6:	xor    rax,rax
    30a9:	mov    rbx,QWORD PTR [rsp+0x20]
    30ae:	mov    r12,QWORD PTR [rsp+0x28]
    30b3:	mov    r13,QWORD PTR [rsp+0x30]
    30b8:	add    rsp,0x40
    30bc:	mov    rsp,rbp
    30bf:	pop    rbp
    30c0:	ret
    30c1:	mov    rcx,r8
    30c4:	mov    rsi,r13
    30c7:	mov    rax,rsi
    30ca:	and    rax,rcx
    30cd:	test   rax,0x1
    30d3:	jne    30e4 <botlish_fn_38+0x14c>
    30d9:	mov    rdx,r8
    30dc:	mov    rsi,r13
    30df:	jmp    3102 <botlish_fn_38+0x16a>
    30e4:	mov    rcx,r8
    30e7:	lea    rax,[rcx-0x1]
    30eb:	mov    rsi,r13
    30ee:	add    rsi,rax
    30f1:	seto   al
    30f4:	test   al,al
    30f6:	je     310d <botlish_fn_38+0x175>
    30fc:	mov    rdx,r8
    30ff:	mov    rsi,r13
    3102:	mov    rdi,rbx
    3105:	call   310a <botlish_fn_38+0x172>
			3106: R_X86_64_PLT32	rt_int_add-0x4
    310a:	mov    rsi,rax
    310d:	mov    QWORD PTR [rsp+0x8],rsi
    3112:	mov    QWORD PTR [rsp+0x10],0x3
    311b:	test   rsi,0x1
    3122:	je     3145 <botlish_fn_38+0x1ad>
    3128:	mov    rax,rsi
    312b:	add    rax,0x2
    312f:	mov    rcx,rax
    3132:	seto   al
    3135:	test   al,al
    3137:	jne    3145 <botlish_fn_38+0x1ad>
    313d:	mov    rsi,rcx
    3140:	jmp    3155 <botlish_fn_38+0x1bd>
    3145:	mov    edx,0x3
    314a:	mov    rdi,rbx
    314d:	call   3152 <botlish_fn_38+0x1ba>
			314e: R_X86_64_PLT32	rt_int_add-0x4
    3152:	mov    rsi,rax
    3155:	mov    QWORD PTR [rsp+0x8],rsi
    315a:	mov    edx,0x7
    315f:	mov    rdi,rdx
    3162:	mov    QWORD PTR [rsp+0x10],0x7
    316b:	test   rsi,0x1
    3172:	jne    3180 <botlish_fn_38+0x1e8>
    3178:	mov    rdx,rdi
    317b:	jmp    31ac <botlish_fn_38+0x214>
    3180:	mov    rax,rsi
    3183:	sar    rax,1
    3186:	imul   QWORD PTR [rip+0xf3]        # 3280 <botlish_fn_38+0x2e8>
    318d:	seto   cl
    3190:	or     rax,0x1
    3194:	test   cl,cl
    3196:	je     31a4 <botlish_fn_38+0x20c>
    319c:	mov    rdx,rdi
    319f:	jmp    31ac <botlish_fn_38+0x214>
    31a4:	mov    rsi,rax
    31a7:	jmp    31b7 <botlish_fn_38+0x21f>
    31ac:	mov    rdi,rbx
    31af:	call   31b4 <botlish_fn_38+0x21c>
			31b0: R_X86_64_PLT32	rt_int_mul-0x4
    31b4:	mov    rsi,rax
    31b7:	mov    QWORD PTR [rsp],rsi
    31bb:	mov    r13,rsi
    31be:	mov    rsi,r12
    31c1:	mov    rdi,rbx
    31c4:	call   31c9 <botlish_fn_38+0x231>
			31c5: R_X86_64_PLT32	botlish_fn_28-0x4 ; ht_capacity<HashTable>
    31c9:	mov    QWORD PTR [rsp+0x8],rax
    31ce:	mov    QWORD PTR [rsp+0x10],0x5
    31d7:	test   rax,0x1
    31dd:	mov    rcx,rax
    31e0:	je     320f <botlish_fn_38+0x277>
    31e6:	mov    rax,rcx
    31e9:	sar    rax,1
    31ec:	imul   QWORD PTR [rip+0x95]        # 3288 <botlish_fn_38+0x2f0>
    31f3:	seto   sil
    31f7:	or     rax,0x1
    31fb:	test   sil,sil
    31fe:	jne    320f <botlish_fn_38+0x277>
    3204:	mov    rdx,rax
    3207:	mov    rsi,r13
    320a:	jmp    3225 <botlish_fn_38+0x28d>
    320f:	mov    edx,0x5
    3214:	mov    rsi,rcx
    3217:	mov    rdi,rbx
    321a:	call   321f <botlish_fn_38+0x287>
			321b: R_X86_64_PLT32	rt_int_mul-0x4
    321f:	mov    rdx,rax
    3222:	mov    rsi,r13
    3225:	mov    rdi,rsi
    3228:	and    rdi,rdx
    322b:	test   rdi,0x1
    3232:	jne    3258 <botlish_fn_38+0x2c0>
    3238:	mov    rdi,rbx
    323b:	call   3240 <botlish_fn_38+0x2a8>
			323c: R_X86_64_PLT32	rt_int_cmp-0x4
    3240:	mov    esi,0x2
    3245:	test   rax,rax
    3248:	mov    rax,rsi
    324b:	cmovg  rax,QWORD PTR [rip+0x2d]        # 3280 <botlish_fn_38+0x2e8>
    3253:	jmp    3268 <botlish_fn_38+0x2d0>
    3258:	mov    eax,0x2
    325d:	cmp    rsi,rdx
    3260:	cmovg  rax,QWORD PTR [rip+0x18]        # 3280 <botlish_fn_38+0x2e8>
    3268:	mov    rbx,QWORD PTR [rsp+0x20]
    326d:	mov    r12,QWORD PTR [rsp+0x28]
    3272:	mov    r13,QWORD PTR [rsp+0x30]
    3277:	add    rsp,0x40
    327b:	mov    rsp,rbp
    327e:	pop    rbp
    327f:	ret
    3280:	(bad)
    3281:	add    BYTE PTR [rax],al
    3283:	add    BYTE PTR [rax],al
    3285:	add    BYTE PTR [rax],al
    3287:	add    BYTE PTR [rax+rax*1],al
    328a:	add    BYTE PTR [rax],al
    328c:	add    BYTE PTR [rax],al
	...

0000000000003290 <botlish_entry_38: ht_should_grow<HashTable>>:
    3290:	push   rbp
    3291:	mov    rbp,rsp
    3294:	mov    rsi,QWORD PTR [rdx]
    3297:	call   329c <botlish_entry_38+0xc>
			3298: R_X86_64_PLT32	botlish_fn_38-0x4 ; ht_should_grow<HashTable>
    329c:	mov    rsp,rbp
    329f:	pop    rbp
    32a0:	ret
    32a1:	add    BYTE PTR [rax],al
    32a3:	add    BYTE PTR [rax],al
    32a5:	add    BYTE PTR [rax],al
	...

00000000000032a8 <botlish_fn_39: ht_grow_or_clean<HashTable>>:
    32a8:	push   rbp
    32a9:	mov    rbp,rsp
    32ac:	sub    rsp,0x40
    32b0:	mov    QWORD PTR [rsp+0x20],rbx
    32b5:	mov    QWORD PTR [rsp+0x28],r12
    32ba:	mov    QWORD PTR [rsp+0x30],r13
    32bf:	mov    rbx,rdi
    32c2:	mov    QWORD PTR [rsp+0x10],0x0
    32cb:	mov    QWORD PTR [rsp],rsi
    32cf:	mov    r12,rsi
    32d2:	mov    rsi,r12
    32d5:	mov    rdi,rbx
    32d8:	call   32dd <botlish_fn_39+0x35>
			32d9: R_X86_64_PLT32	botlish_fn_27-0x4 ; ht_tombstones<HashTable>
    32dd:	test   rax,rax
    32e0:	mov    r13,rax
    32e3:	je     34d1 <botlish_fn_39+0x229>
    32e9:	mov    rsi,r12
    32ec:	mov    rdi,rbx
    32ef:	call   32f4 <botlish_fn_39+0x4c>
			32f0: R_X86_64_PLT32	botlish_fn_26-0x4 ; ht_size<HashTable>
    32f4:	mov    r11,rax
    32f7:	test   r11,r11
    32fa:	je     34d1 <botlish_fn_39+0x229>
    3300:	mov    ecx,0x1
    3305:	mov    rax,r13
    3308:	test   rax,0x1
    330e:	je     331c <botlish_fn_39+0x74>
    3314:	mov    r13,rax
    3317:	jmp    3340 <botlish_fn_39+0x98>
    331c:	xor    ecx,ecx
    331e:	test   rax,0x7
    3324:	je     3332 <botlish_fn_39+0x8a>
    332a:	mov    r13,rax
    332d:	jmp    3340 <botlish_fn_39+0x98>
    3332:	movzx  rcx,BYTE PTR [rax]
    3336:	mov    r13,rax
    3339:	rex cmp cl,0x1
    333d:	sete   cl
    3340:	test   cl,cl
    3342:	jne    3363 <botlish_fn_39+0xbb>
    3348:	mov    rdi,rbx
    334b:	mov    rsi,QWORD PTR [rdi+0x10]
    334f:	mov    rcx,QWORD PTR [rsi+0x10]
    3353:	xor    rdx,rdx
    3356:	mov    rsi,r13
    3359:	call   335e <botlish_fn_39+0xb6>
			335a: R_X86_64_PLT32	rt_type_error-0x4
    335e:	jmp    34d1 <botlish_fn_39+0x229>
    3363:	mov    rsi,r13
    3366:	mov    eax,0x1
    336b:	test   r11,0x1
    3372:	je     3380 <botlish_fn_39+0xd8>
    3378:	mov    r8,r11
    337b:	jmp    33a5 <botlish_fn_39+0xfd>
    3380:	xor    eax,eax
    3382:	test   r11,0x7
    3389:	je     3397 <botlish_fn_39+0xef>
    338f:	mov    r8,r11
    3392:	jmp    33a5 <botlish_fn_39+0xfd>
    3397:	movzx  r10,BYTE PTR [r11]
    339b:	mov    r8,r11
    339e:	cmp    r10b,0x1
    33a2:	sete   al
    33a5:	test   al,al
    33a7:	jne    33c8 <botlish_fn_39+0x120>
    33ad:	mov    rdi,rbx
    33b0:	mov    rax,QWORD PTR [rdi+0x10]
    33b4:	mov    rcx,QWORD PTR [rax+0x10]
    33b8:	xor    rdx,rdx
    33bb:	mov    rsi,r8
    33be:	call   33c3 <botlish_fn_39+0x11b>
			33bf: R_X86_64_PLT32	rt_type_error-0x4
    33c3:	jmp    34d1 <botlish_fn_39+0x229>
    33c8:	mov    r11,r8
    33cb:	mov    rax,rsi
    33ce:	and    rax,r11
    33d1:	test   rax,0x1
    33d7:	jne    33fd <botlish_fn_39+0x155>
    33dd:	mov    rdx,r8
    33e0:	mov    rdi,rbx
    33e3:	call   33e8 <botlish_fn_39+0x140>
			33e4: R_X86_64_PLT32	rt_int_cmp-0x4
    33e8:	mov    ecx,0x2
    33ed:	test   rax,rax
    33f0:	cmovg  rcx,QWORD PTR [rip+0x110]        # 3508 <botlish_fn_39+0x260>
    33f8:	jmp    3410 <botlish_fn_39+0x168>
    33fd:	mov    ecx,0x2
    3402:	mov    r11,r8
    3405:	cmp    rsi,r11
    3408:	cmovg  rcx,QWORD PTR [rip+0xf8]        # 3508 <botlish_fn_39+0x260>
    3410:	cmp    rcx,0x6
    3414:	je     34aa <botlish_fn_39+0x202>
    341a:	mov    rsi,r12
    341d:	mov    rdi,rbx
    3420:	call   3425 <botlish_fn_39+0x17d>
			3421: R_X86_64_PLT32	botlish_fn_28-0x4 ; ht_capacity<HashTable>
    3425:	mov    QWORD PTR [rsp+0x8],rax
    342a:	mov    QWORD PTR [rsp+0x10],0x5
    3433:	test   rax,0x1
    3439:	mov    rsi,rax
    343c:	je     3469 <botlish_fn_39+0x1c1>
    3442:	mov    rcx,rsi
    3445:	mov    rax,rcx
    3448:	sar    rax,1
    344b:	imul   QWORD PTR [rip+0xbe]        # 3510 <botlish_fn_39+0x268>
    3452:	seto   cl
    3455:	or     rax,0x1
    3459:	test   cl,cl
    345b:	jne    3469 <botlish_fn_39+0x1c1>
    3461:	mov    rdx,rax
    3464:	jmp    3479 <botlish_fn_39+0x1d1>
    3469:	mov    edx,0x5
    346e:	mov    rdi,rbx
    3471:	call   3476 <botlish_fn_39+0x1ce>
			3472: R_X86_64_PLT32	rt_int_mul-0x4
    3476:	mov    rdx,rax
    3479:	mov    QWORD PTR [rsp+0x8],rdx
    347e:	mov    rsi,r12
    3481:	mov    rdi,rbx
    3484:	call   3489 <botlish_fn_39+0x1e1>
			3485: R_X86_64_PLT32	botlish_fn_37-0x4 ; ht_rehash<HashTable, int>
    3489:	test   rax,rax
    348c:	je     34d1 <botlish_fn_39+0x229>
    3492:	mov    rbx,QWORD PTR [rsp+0x20]
    3497:	mov    r12,QWORD PTR [rsp+0x28]
    349c:	mov    r13,QWORD PTR [rsp+0x30]
    34a1:	add    rsp,0x40
    34a5:	mov    rsp,rbp
    34a8:	pop    rbp
    34a9:	ret
    34aa:	mov    rsi,r12
    34ad:	mov    rdi,rbx
    34b0:	call   34b5 <botlish_fn_39+0x20d>
			34b1: R_X86_64_PLT32	botlish_fn_28-0x4 ; ht_capacity<HashTable>
    34b5:	mov    QWORD PTR [rsp+0x8],rax
    34ba:	mov    rdx,rax
    34bd:	mov    rsi,r12
    34c0:	mov    rdi,rbx
    34c3:	call   34c8 <botlish_fn_39+0x220>
			34c4: R_X86_64_PLT32	botlish_fn_37-0x4 ; ht_rehash<HashTable, int>
    34c8:	test   rax,rax
    34cb:	jne    34ec <botlish_fn_39+0x244>
    34d1:	xor    rax,rax
    34d4:	mov    rbx,QWORD PTR [rsp+0x20]
    34d9:	mov    r12,QWORD PTR [rsp+0x28]
    34de:	mov    r13,QWORD PTR [rsp+0x30]
    34e3:	add    rsp,0x40
    34e7:	mov    rsp,rbp
    34ea:	pop    rbp
    34eb:	ret
    34ec:	mov    rbx,QWORD PTR [rsp+0x20]
    34f1:	mov    r12,QWORD PTR [rsp+0x28]
    34f6:	mov    r13,QWORD PTR [rsp+0x30]
    34fb:	add    rsp,0x40
    34ff:	mov    rsp,rbp
    3502:	pop    rbp
    3503:	ret
    3504:	add    BYTE PTR [rax],al
    3506:	add    BYTE PTR [rax],al
    3508:	(bad)
    3509:	add    BYTE PTR [rax],al
    350b:	add    BYTE PTR [rax],al
    350d:	add    BYTE PTR [rax],al
    350f:	add    BYTE PTR [rax+rax*1],al
    3512:	add    BYTE PTR [rax],al
    3514:	add    BYTE PTR [rax],al
	...

0000000000003518 <botlish_entry_39: ht_grow_or_clean<HashTable>>:
    3518:	push   rbp
    3519:	mov    rbp,rsp
    351c:	mov    rsi,QWORD PTR [rdx]
    351f:	call   3524 <botlish_entry_39+0xc>
			3520: R_X86_64_PLT32	botlish_fn_39-0x4 ; ht_grow_or_clean<HashTable>
    3524:	mov    rsp,rbp
    3527:	pop    rbp
    3528:	ret
    3529:	add    BYTE PTR [rax],al
    352b:	add    BYTE PTR [rax],al
    352d:	add    BYTE PTR [rax],al
	...

0000000000003530 <botlish_fn_40: ht_place<HashTable, int, str, str>>:
    3530:	push   rbp
    3531:	mov    rbp,rsp
    3534:	sub    rsp,0x70
    3538:	mov    QWORD PTR [rsp+0x40],rbx
    353d:	mov    QWORD PTR [rsp+0x48],r12
    3542:	mov    QWORD PTR [rsp+0x50],r13
    3547:	mov    QWORD PTR [rsp+0x58],r14
    354c:	mov    QWORD PTR [rsp+0x60],r15
    3551:	mov    r12,rdi
    3554:	mov    r14,r8
    3557:	mov    r15,rdx
    355a:	mov    QWORD PTR [rsp+0x30],rcx
    355f:	mov    QWORD PTR [rsp],rsi
    3563:	mov    r9,QWORD PTR [rsi+0x18]
    3567:	mov    r13,rsi
    356a:	mov    rsi,QWORD PTR [r9]
    356d:	mov    rdx,r15
    3570:	mov    rdi,r12
    3573:	call   3578 <botlish_fn_40+0x48>
			3574: R_X86_64_PLT32	rt_mutarray_get-0x4
    3578:	test   rax,rax
    357b:	je     3810 <botlish_fn_40+0x2e0>
    3581:	mov    QWORD PTR [rsp+0x8],rax
    3586:	mov    rbx,r13
    3589:	mov    r13,rax
    358c:	mov    rax,QWORD PTR [rbx+0x18]
    3590:	mov    rsi,QWORD PTR [rax]
    3593:	mov    ecx,0x3
    3598:	mov    rdx,r15
    359b:	mov    rdi,r12
    359e:	call   35a3 <botlish_fn_40+0x73>
			359f: R_X86_64_PLT32	rt_mutarray_set-0x4
    35a3:	test   rax,rax
    35a6:	je     3810 <botlish_fn_40+0x2e0>
    35ac:	mov    rax,QWORD PTR [rbx+0x18]
    35b0:	mov    rsi,QWORD PTR [rax+0x8]
    35b4:	mov    rcx,QWORD PTR [rsp+0x30]
    35b9:	mov    rdx,r15
    35bc:	mov    rdi,r12
    35bf:	call   35c4 <botlish_fn_40+0x94>
			35c0: R_X86_64_PLT32	rt_mutarray_set-0x4
    35c4:	test   rax,rax
    35c7:	je     3810 <botlish_fn_40+0x2e0>
    35cd:	mov    rax,QWORD PTR [rbx+0x18]
    35d1:	mov    rsi,QWORD PTR [rax+0x10]
    35d5:	mov    rcx,r14
    35d8:	mov    rdx,r15
    35db:	mov    rdi,r12
    35de:	call   35e3 <botlish_fn_40+0xb3>
			35df: R_X86_64_PLT32	rt_mutarray_set-0x4
    35e3:	test   rax,rax
    35e6:	je     3810 <botlish_fn_40+0x2e0>
    35ec:	mov    rax,QWORD PTR [rbx+0x18]
    35f0:	mov    rsi,QWORD PTR [rax+0x18]
    35f4:	mov    QWORD PTR [rsp+0x10],rsi
    35f9:	mov    r14,rsi
    35fc:	mov    QWORD PTR [rsp+0x18],0x1
    3605:	mov    rsi,rbx
    3608:	mov    rdi,r12
    360b:	call   3610 <botlish_fn_40+0xe0>
			360c: R_X86_64_PLT32	botlish_fn_26-0x4 ; ht_size<HashTable>
    3610:	test   rax,rax
    3613:	je     3810 <botlish_fn_40+0x2e0>
    3619:	mov    QWORD PTR [rsp+0x20],rax
    361e:	mov    QWORD PTR [rsp+0x28],0x3
    3627:	mov    ecx,0x1
    362c:	test   rax,0x1
    3632:	je     3640 <botlish_fn_40+0x110>
    3638:	mov    rsi,rax
    363b:	jmp    3664 <botlish_fn_40+0x134>
    3640:	xor    ecx,ecx
    3642:	test   rax,0x7
    3648:	je     3656 <botlish_fn_40+0x126>
    364e:	mov    rsi,rax
    3651:	jmp    3664 <botlish_fn_40+0x134>
    3656:	movzx  rcx,BYTE PTR [rax]
    365a:	mov    rsi,rax
    365d:	rex cmp cl,0x1
    3661:	sete   cl
    3664:	test   cl,cl
    3666:	jne    3684 <botlish_fn_40+0x154>
    366c:	mov    rdi,r12
    366f:	mov    rax,QWORD PTR [rdi+0x10]
    3673:	mov    rcx,QWORD PTR [rax+0x8]
    3677:	xor    rdx,rdx
    367a:	call   367f <botlish_fn_40+0x14f>
			367b: R_X86_64_PLT32	rt_type_error-0x4
    367f:	jmp    3810 <botlish_fn_40+0x2e0>
    3684:	test   rsi,0x1
    368b:	je     36a3 <botlish_fn_40+0x173>
    3691:	mov    rcx,rsi
    3694:	add    rcx,0x2
    3698:	seto   al
    369b:	test   al,al
    369d:	je     36b3 <botlish_fn_40+0x183>
    36a3:	mov    edx,0x3
    36a8:	mov    rdi,r12
    36ab:	call   36b0 <botlish_fn_40+0x180>
			36ac: R_X86_64_PLT32	rt_int_add-0x4
    36b0:	mov    rcx,rax
    36b3:	mov    edx,0x1
    36b8:	mov    rsi,r14
    36bb:	mov    rdi,r12
    36be:	call   36c3 <botlish_fn_40+0x193>
			36bf: R_X86_64_PLT32	rt_mutarray_set-0x4
    36c3:	test   rax,rax
    36c6:	je     3810 <botlish_fn_40+0x2e0>
    36cc:	mov    rax,r13
    36cf:	test   rax,0x1
    36d5:	jne    3700 <botlish_fn_40+0x1d0>
    36db:	mov    edx,0x5
    36e0:	mov    rsi,r13
    36e3:	mov    rdi,r12
    36e6:	call   36eb <botlish_fn_40+0x1bb>
			36e7: R_X86_64_PLT32	rt_int_cmp-0x4
    36eb:	mov    ecx,0x2
    36f0:	test   rax,rax
    36f3:	cmove  rcx,QWORD PTR [rip+0x165]        # 3860 <botlish_fn_40+0x330>
    36fb:	jmp    3714 <botlish_fn_40+0x1e4>
    3700:	mov    rsi,r13
    3703:	mov    ecx,0x2
    3708:	cmp    rsi,0x5
    370c:	cmove  rcx,QWORD PTR [rip+0x14c]        # 3860 <botlish_fn_40+0x330>
    3714:	cmp    rcx,0x6
    3718:	je     3726 <botlish_fn_40+0x1f6>
    371e:	mov    rax,rbx
    3721:	jmp    3838 <botlish_fn_40+0x308>
    3726:	mov    rax,QWORD PTR [rbx+0x18]
    372a:	mov    rsi,QWORD PTR [rax+0x18]
    372e:	mov    QWORD PTR [rsp+0x8],rsi
    3733:	mov    r14,rsi
    3736:	mov    QWORD PTR [rsp+0x10],0x3
    373f:	mov    rsi,rbx
    3742:	mov    rdi,r12
    3745:	call   374a <botlish_fn_40+0x21a>
			3746: R_X86_64_PLT32	botlish_fn_27-0x4 ; ht_tombstones<HashTable>
    374a:	mov    r13,rbx
    374d:	test   rax,rax
    3750:	je     3810 <botlish_fn_40+0x2e0>
    3756:	mov    QWORD PTR [rsp+0x18],rax
    375b:	mov    QWORD PTR [rsp+0x20],0x3
    3764:	mov    ecx,0x1
    3769:	test   rax,0x1
    376f:	je     377d <botlish_fn_40+0x24d>
    3775:	mov    rsi,rax
    3778:	jmp    37a1 <botlish_fn_40+0x271>
    377d:	xor    ecx,ecx
    377f:	test   rax,0x7
    3785:	je     3793 <botlish_fn_40+0x263>
    378b:	mov    rsi,rax
    378e:	jmp    37a1 <botlish_fn_40+0x271>
    3793:	movzx  r10,BYTE PTR [rax]
    3797:	mov    rsi,rax
    379a:	cmp    r10b,0x1
    379e:	sete   cl
    37a1:	test   cl,cl
    37a3:	jne    37c1 <botlish_fn_40+0x291>
    37a9:	mov    rdi,r12
    37ac:	mov    rax,QWORD PTR [rdi+0x10]
    37b0:	mov    rcx,QWORD PTR [rax+0x18]
    37b4:	xor    rdx,rdx
    37b7:	call   37bc <botlish_fn_40+0x28c>
			37b8: R_X86_64_PLT32	rt_type_error-0x4
    37bc:	jmp    3810 <botlish_fn_40+0x2e0>
    37c1:	test   rsi,0x1
    37c8:	je     37e7 <botlish_fn_40+0x2b7>
    37ce:	mov    rcx,rsi
    37d1:	sub    rcx,0x3
    37d5:	seto   al
    37d8:	add    rcx,0x1
    37df:	test   al,al
    37e1:	je     37f7 <botlish_fn_40+0x2c7>
    37e7:	mov    edx,0x3
    37ec:	mov    rdi,r12
    37ef:	call   37f4 <botlish_fn_40+0x2c4>
			37f0: R_X86_64_PLT32	rt_int_sub-0x4
    37f4:	mov    rcx,rax
    37f7:	mov    edx,0x3
    37fc:	mov    rsi,r14
    37ff:	mov    rdi,r12
    3802:	call   3807 <botlish_fn_40+0x2d7>
			3803: R_X86_64_PLT32	rt_mutarray_set-0x4
    3807:	test   rax,rax
    380a:	jne    3835 <botlish_fn_40+0x305>
    3810:	xor    rax,rax
    3813:	mov    rbx,QWORD PTR [rsp+0x40]
    3818:	mov    r12,QWORD PTR [rsp+0x48]
    381d:	mov    r13,QWORD PTR [rsp+0x50]
    3822:	mov    r14,QWORD PTR [rsp+0x58]
    3827:	mov    r15,QWORD PTR [rsp+0x60]
    382c:	add    rsp,0x70
    3830:	mov    rsp,rbp
    3833:	pop    rbp
    3834:	ret
    3835:	mov    rax,r13
    3838:	mov    rbx,QWORD PTR [rsp+0x40]
    383d:	mov    r12,QWORD PTR [rsp+0x48]
    3842:	mov    r13,QWORD PTR [rsp+0x50]
    3847:	mov    r14,QWORD PTR [rsp+0x58]
    384c:	mov    r15,QWORD PTR [rsp+0x60]
    3851:	add    rsp,0x70
    3855:	mov    rsp,rbp
    3858:	pop    rbp
    3859:	ret
    385a:	add    BYTE PTR [rax],al
    385c:	add    BYTE PTR [rax],al
    385e:	add    BYTE PTR [rax],al
    3860:	(bad)
    3861:	add    BYTE PTR [rax],al
    3863:	add    BYTE PTR [rax],al
    3865:	add    BYTE PTR [rax],al
	...

0000000000003868 <botlish_entry_40: ht_place<HashTable, int, str, str>>:
    3868:	push   rbp
    3869:	mov    rbp,rsp
    386c:	mov    rsi,QWORD PTR [rdx]
    386f:	mov    r9,QWORD PTR [rdx+0x8]
    3873:	mov    rcx,QWORD PTR [rdx+0x10]
    3877:	mov    r8,QWORD PTR [rdx+0x18]
    387b:	mov    rdx,r9
    387e:	call   3883 <botlish_entry_40+0x1b>
			387f: R_X86_64_PLT32	botlish_fn_40-0x4 ; ht_place<HashTable, int, str, str>
    3883:	mov    rsp,rbp
    3886:	pop    rbp
    3887:	ret

0000000000003888 <botlish_fn_41: ht_set<HashTable, str, str>>:
    3888:	push   rbp
    3889:	mov    rbp,rsp
    388c:	sub    rsp,0x60
    3890:	mov    QWORD PTR [rsp+0x30],rbx
    3895:	mov    QWORD PTR [rsp+0x38],r12
    389a:	mov    QWORD PTR [rsp+0x40],r13
    389f:	mov    QWORD PTR [rsp+0x48],r14
    38a4:	mov    QWORD PTR [rsp+0x50],r15
    38a9:	mov    r12,rdi
    38ac:	mov    QWORD PTR [rsp+0x18],0x0
    38b5:	mov    QWORD PTR [rsp+0x20],0x0
    38be:	mov    QWORD PTR [rsp],rsi
    38c2:	mov    r14,rsi
    38c5:	mov    QWORD PTR [rsp+0x8],rdx
    38ca:	mov    r13,rdx
    38cd:	mov    QWORD PTR [rsp+0x10],rcx
    38d2:	mov    rbx,rcx
    38d5:	mov    rdx,r13
    38d8:	mov    rsi,r14
    38db:	mov    rdi,r12
    38de:	call   38e3 <botlish_fn_41+0x5b>
			38df: R_X86_64_PLT32	botlish_fn_29-0x4 ; ht_probe_start<HashTable, str>
    38e3:	test   rax,rax
    38e6:	je     3abe <botlish_fn_41+0x236>
    38ec:	mov    QWORD PTR [rsp+0x18],rax
    38f1:	mov    rcx,rax
    38f4:	mov    r8,0xffffffffffffffff
    38fb:	mov    r15,r8
    38fe:	mov    QWORD PTR [rsp+0x20],0xffffffffffffffff
    3907:	mov    rdx,r13
    390a:	mov    rsi,r14
    390d:	mov    rdi,r12
    3910:	call   3915 <botlish_fn_41+0x8d>
			3911: R_X86_64_PLT32	botlish_fn_32-0x4 ; ht_find_insert<HashTable, str, int, int>
    3915:	test   rax,rax
    3918:	je     3abe <botlish_fn_41+0x236>
    391e:	mov    QWORD PTR [rsp+0x18],rax
    3923:	mov    rsi,r14
    3926:	mov    QWORD PTR [rsp+0x28],rax
    392b:	mov    rax,QWORD PTR [rsi+0x18]
    392f:	mov    rsi,QWORD PTR [rax]
    3932:	mov    rdx,QWORD PTR [rsp+0x28]
    3937:	mov    rdi,r12
    393a:	call   393f <botlish_fn_41+0xb7>
			393b: R_X86_64_PLT32	rt_mutarray_get-0x4
    393f:	test   rax,rax
    3942:	je     3abe <botlish_fn_41+0x236>
    3948:	test   rax,0x1
    394e:	mov    rsi,rax
    3951:	jne    3979 <botlish_fn_41+0xf1>
    3957:	mov    edx,0x3
    395c:	mov    rdi,r12
    395f:	call   3964 <botlish_fn_41+0xdc>
			3960: R_X86_64_PLT32	rt_int_cmp-0x4
    3964:	mov    ecx,0x2
    3969:	test   rax,rax
    396c:	cmove  rcx,QWORD PTR [rip+0x194]        # 3b08 <botlish_fn_41+0x280>
    3974:	jmp    398a <botlish_fn_41+0x102>
    3979:	mov    ecx,0x2
    397e:	cmp    rsi,0x3
    3982:	cmove  rcx,QWORD PTR [rip+0x17e]        # 3b08 <botlish_fn_41+0x280>
    398a:	cmp    rcx,0x6
    398e:	je     3a9a <botlish_fn_41+0x212>
    3994:	mov    rsi,r14
    3997:	mov    rdi,r12
    399a:	call   399f <botlish_fn_41+0x117>
			399b: R_X86_64_PLT32	botlish_fn_38-0x4 ; ht_should_grow<HashTable>
    399f:	test   rax,rax
    39a2:	je     3abe <botlish_fn_41+0x236>
    39a8:	cmp    rax,0x6
    39ac:	je     39f3 <botlish_fn_41+0x16b>
    39b2:	mov    rcx,r13
    39b5:	mov    rdx,QWORD PTR [rsp+0x28]
    39ba:	mov    rsi,r14
    39bd:	mov    rdi,r12
    39c0:	mov    r8,rbx
    39c3:	call   39c8 <botlish_fn_41+0x140>
			39c4: R_X86_64_PLT32	botlish_fn_40-0x4 ; ht_place<HashTable, int, str, str>
    39c8:	test   rax,rax
    39cb:	je     3abe <botlish_fn_41+0x236>
    39d1:	mov    rbx,QWORD PTR [rsp+0x30]
    39d6:	mov    r12,QWORD PTR [rsp+0x38]
    39db:	mov    r13,QWORD PTR [rsp+0x40]
    39e0:	mov    r14,QWORD PTR [rsp+0x48]
    39e5:	mov    r15,QWORD PTR [rsp+0x50]
    39ea:	add    rsp,0x60
    39ee:	mov    rsp,rbp
    39f1:	pop    rbp
    39f2:	ret
    39f3:	mov    rsi,r14
    39f6:	mov    rdi,r12
    39f9:	call   39fe <botlish_fn_41+0x176>
			39fa: R_X86_64_PLT32	botlish_fn_39-0x4 ; ht_grow_or_clean<HashTable>
    39fe:	mov    rcx,rax
    3a01:	mov    r14,rax
    3a04:	test   rax,rcx
    3a07:	je     3abe <botlish_fn_41+0x236>
    3a0d:	mov    rax,r14
    3a10:	mov    QWORD PTR [rsp],rax
    3a14:	mov    rdx,r13
    3a17:	mov    rsi,r14
    3a1a:	mov    rdi,r12
    3a1d:	call   3a22 <botlish_fn_41+0x19a>
			3a1e: R_X86_64_PLT32	botlish_fn_29-0x4 ; ht_probe_start<HashTable, str>
    3a22:	test   rax,rax
    3a25:	je     3abe <botlish_fn_41+0x236>
    3a2b:	mov    QWORD PTR [rsp+0x18],rax
    3a30:	mov    rcx,rax
    3a33:	mov    QWORD PTR [rsp+0x20],0xffffffffffffffff
    3a3c:	mov    r8,r15
    3a3f:	mov    rdx,r13
    3a42:	mov    rsi,r14
    3a45:	mov    rdi,r12
    3a48:	call   3a4d <botlish_fn_41+0x1c5>
			3a49: R_X86_64_PLT32	botlish_fn_32-0x4 ; ht_find_insert<HashTable, str, int, int>
    3a4d:	test   rax,rax
    3a50:	je     3abe <botlish_fn_41+0x236>
    3a56:	mov    QWORD PTR [rsp+0x18],rax
    3a5b:	mov    rcx,r13
    3a5e:	mov    rdx,rax
    3a61:	mov    rsi,r14
    3a64:	mov    rdi,r12
    3a67:	mov    r8,rbx
    3a6a:	call   3a6f <botlish_fn_41+0x1e7>
			3a6b: R_X86_64_PLT32	botlish_fn_40-0x4 ; ht_place<HashTable, int, str, str>
    3a6f:	test   rax,rax
    3a72:	je     3abe <botlish_fn_41+0x236>
    3a78:	mov    rbx,QWORD PTR [rsp+0x30]
    3a7d:	mov    r12,QWORD PTR [rsp+0x38]
    3a82:	mov    r13,QWORD PTR [rsp+0x40]
    3a87:	mov    r14,QWORD PTR [rsp+0x48]
    3a8c:	mov    r15,QWORD PTR [rsp+0x50]
    3a91:	add    rsp,0x60
    3a95:	mov    rsp,rbp
    3a98:	pop    rbp
    3a99:	ret
    3a9a:	mov    rdx,QWORD PTR [rsp+0x28]
    3a9f:	mov    rsi,r14
    3aa2:	mov    rax,QWORD PTR [rsi+0x18]
    3aa6:	mov    rsi,QWORD PTR [rax+0x10]
    3aaa:	mov    rcx,rbx
    3aad:	mov    rdi,r12
    3ab0:	call   3ab5 <botlish_fn_41+0x22d>
			3ab1: R_X86_64_PLT32	rt_mutarray_set-0x4
    3ab5:	test   rax,rax
    3ab8:	jne    3ae3 <botlish_fn_41+0x25b>
    3abe:	xor    rax,rax
    3ac1:	mov    rbx,QWORD PTR [rsp+0x30]
    3ac6:	mov    r12,QWORD PTR [rsp+0x38]
    3acb:	mov    r13,QWORD PTR [rsp+0x40]
    3ad0:	mov    r14,QWORD PTR [rsp+0x48]
    3ad5:	mov    r15,QWORD PTR [rsp+0x50]
    3ada:	add    rsp,0x60
    3ade:	mov    rsp,rbp
    3ae1:	pop    rbp
    3ae2:	ret
    3ae3:	mov    rax,r14
    3ae6:	mov    rbx,QWORD PTR [rsp+0x30]
    3aeb:	mov    r12,QWORD PTR [rsp+0x38]
    3af0:	mov    r13,QWORD PTR [rsp+0x40]
    3af5:	mov    r14,QWORD PTR [rsp+0x48]
    3afa:	mov    r15,QWORD PTR [rsp+0x50]
    3aff:	add    rsp,0x60
    3b03:	mov    rsp,rbp
    3b06:	pop    rbp
    3b07:	ret
    3b08:	(bad)
    3b09:	add    BYTE PTR [rax],al
    3b0b:	add    BYTE PTR [rax],al
    3b0d:	add    BYTE PTR [rax],al
	...

0000000000003b10 <botlish_entry_41: ht_set<HashTable, str, str>>:
    3b10:	push   rbp
    3b11:	mov    rbp,rsp
    3b14:	mov    rsi,QWORD PTR [rdx]
    3b17:	mov    r8,QWORD PTR [rdx+0x8]
    3b1b:	mov    rcx,QWORD PTR [rdx+0x10]
    3b1f:	mov    rdx,r8
    3b22:	call   3b27 <botlish_entry_41+0x17>
			3b23: R_X86_64_PLT32	botlish_fn_41-0x4 ; ht_set<HashTable, str, str>
    3b27:	mov    rsp,rbp
    3b2a:	pop    rbp
    3b2b:	ret

0000000000003b2c <botlish_fn_42: row_new<bool, int>>:
    3b2c:	push   rbp
    3b2d:	mov    rbp,rsp
    3b30:	sub    rsp,0x10
    3b34:	mov    QWORD PTR [rsp],rdx
    3b38:	mov    r8,rdx
    3b3b:	cmp    rsi,0x6
    3b3f:	je     3b5c <botlish_fn_42+0x30>
    3b45:	call   3b4a <botlish_fn_42+0x1e>
			3b46: R_X86_64_PLT32	botlish_fn_23-0x4 ; ht_new<generic>
    3b4a:	test   rax,rax
    3b4d:	je     3b6d <botlish_fn_42+0x41>
    3b53:	add    rsp,0x10
    3b57:	mov    rsp,rbp
    3b5a:	pop    rbp
    3b5b:	ret
    3b5c:	mov    rsi,r8
    3b5f:	call   3b64 <botlish_fn_42+0x38>
			3b60: R_X86_64_PLT32	botlish_fn_25-0x4 ; ht_new_sized<int>
    3b64:	test   rax,rax
    3b67:	jne    3b79 <botlish_fn_42+0x4d>
    3b6d:	xor    rax,rax
    3b70:	add    rsp,0x10
    3b74:	mov    rsp,rbp
    3b77:	pop    rbp
    3b78:	ret
    3b79:	add    rsp,0x10
    3b7d:	mov    rsp,rbp
    3b80:	pop    rbp
    3b81:	ret

0000000000003b82 <botlish_entry_42: row_new<bool, int>>:
    3b82:	push   rbp
    3b83:	mov    rbp,rsp
    3b86:	mov    rsi,QWORD PTR [rdx]
    3b89:	mov    rdx,QWORD PTR [rdx+0x8]
    3b8d:	call   3b92 <botlish_entry_42+0x10>
			3b8e: R_X86_64_PLT32	botlish_fn_42-0x4 ; row_new<bool, int>
    3b92:	mov    rsp,rbp
    3b95:	pop    rbp
    3b96:	ret

0000000000003b97 <botlish_fn_43: row_fill<HashTable, List[str], List[str], int, int>>:
    3b97:	push   rbp
    3b98:	mov    rbp,rsp
    3b9b:	sub    rsp,0x70
    3b9f:	mov    QWORD PTR [rsp+0x40],rbx
    3ba4:	mov    QWORD PTR [rsp+0x48],r12
    3ba9:	mov    QWORD PTR [rsp+0x50],r13
    3bae:	mov    QWORD PTR [rsp+0x58],r14
    3bb3:	mov    QWORD PTR [rsp+0x60],r15
    3bb8:	mov    r15,rdi
    3bbb:	mov    QWORD PTR [rsp],rsi
    3bbf:	mov    QWORD PTR [rsp+0x8],rdx
    3bc4:	mov    QWORD PTR [rsp+0x10],rcx
    3bc9:	mov    r14,rcx
    3bcc:	sar    r8,1
    3bcf:	mov    rbx,r8
    3bd2:	mov    r12,r9
    3bd5:	mov    QWORD PTR [rsp+0x28],rsi
    3bda:	cmp    rbx,r12
    3bdd:	jge    3cec <botlish_fn_43+0x155>
    3be3:	mov    r13,rdx
    3be6:	mov    rdx,QWORD PTR [r13+0x8]
    3bea:	mov    rcx,rbx
    3bed:	shl    rcx,1
    3bf0:	or     rcx,0x1
    3bf4:	sar    rcx,1
    3bf7:	cmp    rcx,rdx
    3bfa:	jb     3c26 <botlish_fn_43+0x8f>
    3c00:	mov    rdx,rbx
    3c03:	shl    rdx,1
    3c06:	or     rdx,0x1
    3c0a:	mov    rsi,r13
    3c0d:	mov    rdi,r15
    3c10:	call   3c15 <botlish_fn_43+0x7e>
			3c11: R_X86_64_PLT32	rt_list_get-0x4
    3c15:	test   rax,rax
    3c18:	je     3ca5 <botlish_fn_43+0x10e>
    3c1e:	mov    rdx,rax
    3c21:	jmp    3c2e <botlish_fn_43+0x97>
    3c26:	mov    rax,QWORD PTR [r13+0x10]
    3c2a:	mov    rdx,QWORD PTR [rax+rcx*8]
    3c2e:	mov    QWORD PTR [rsp+0x18],rdx
    3c33:	mov    QWORD PTR [rsp+0x30],rdx
    3c38:	mov    rax,QWORD PTR [r14+0x8]
    3c3c:	mov    rcx,rbx
    3c3f:	shl    rcx,1
    3c42:	or     rcx,0x1
    3c46:	sar    rcx,1
    3c49:	cmp    rcx,rax
    3c4c:	jb     3c7d <botlish_fn_43+0xe6>
    3c52:	mov    rdx,rbx
    3c55:	shl    rdx,1
    3c58:	or     rdx,0x1
    3c5c:	mov    rsi,r14
    3c5f:	mov    rdi,r15
    3c62:	call   3c67 <botlish_fn_43+0xd0>
			3c63: R_X86_64_PLT32	rt_list_get-0x4
    3c67:	test   rax,rax
    3c6a:	je     3ca5 <botlish_fn_43+0x10e>
    3c70:	mov    rcx,rax
    3c73:	mov    rsi,QWORD PTR [rsp+0x28]
    3c78:	jmp    3c8a <botlish_fn_43+0xf3>
    3c7d:	mov    rax,QWORD PTR [r14+0x10]
    3c81:	mov    rcx,QWORD PTR [rax+rcx*8]
    3c85:	mov    rsi,QWORD PTR [rsp+0x28]
    3c8a:	mov    QWORD PTR [rsp+0x20],rcx
    3c8f:	mov    rdx,QWORD PTR [rsp+0x30]
    3c94:	mov    rdi,r15
    3c97:	call   3c9c <botlish_fn_43+0x105>
			3c98: R_X86_64_PLT32	botlish_fn_41-0x4 ; ht_set<HashTable, str, str>
    3c9c:	test   rax,rax
    3c9f:	jne    3cca <botlish_fn_43+0x133>
    3ca5:	xor    rax,rax
    3ca8:	mov    rbx,QWORD PTR [rsp+0x40]
    3cad:	mov    r12,QWORD PTR [rsp+0x48]
    3cb2:	mov    r13,QWORD PTR [rsp+0x50]
    3cb7:	mov    r14,QWORD PTR [rsp+0x58]
    3cbc:	mov    r15,QWORD PTR [rsp+0x60]
    3cc1:	add    rsp,0x70
    3cc5:	mov    rsp,rbp
    3cc8:	pop    rbp
    3cc9:	ret
    3cca:	mov    QWORD PTR [rsp],rax
    3cce:	mov    QWORD PTR [rsp+0x8],r13
    3cd3:	mov    QWORD PTR [rsp+0x10],r14
    3cd8:	add    rbx,0x1
    3cdf:	mov    rdx,r13
    3ce2:	mov    QWORD PTR [rsp+0x28],rax
    3ce7:	jmp    3bda <botlish_fn_43+0x43>
    3cec:	mov    rax,QWORD PTR [rsp+0x28]
    3cf1:	mov    rbx,QWORD PTR [rsp+0x40]
    3cf6:	mov    r12,QWORD PTR [rsp+0x48]
    3cfb:	mov    r13,QWORD PTR [rsp+0x50]
    3d00:	mov    r14,QWORD PTR [rsp+0x58]
    3d05:	mov    r15,QWORD PTR [rsp+0x60]
    3d0a:	add    rsp,0x70
    3d0e:	mov    rsp,rbp
    3d11:	pop    rbp
    3d12:	ret

0000000000003d13 <botlish_entry_43: row_fill<HashTable, List[str], List[str], int, int>>:
    3d13:	push   rbp
    3d14:	mov    rbp,rsp
    3d17:	mov    rsi,QWORD PTR [rdx]
    3d1a:	mov    r10,QWORD PTR [rdx+0x8]
    3d1e:	mov    rcx,QWORD PTR [rdx+0x10]
    3d22:	mov    r8,QWORD PTR [rdx+0x18]
    3d26:	mov    r9,QWORD PTR [rdx+0x20]
    3d2a:	sar    r9,1
    3d2d:	mov    rdx,r10
    3d30:	call   3d35 <botlish_entry_43+0x22>
			3d31: R_X86_64_PLT32	botlish_fn_43-0x4 ; row_fill<HashTable, List[str], List[str], int, int>
    3d35:	mov    rsp,rbp
    3d38:	pop    rbp
    3d39:	ret

0000000000003d3a <botlish_fn_44: row_table<List[str], int, List[str], bool>>:
    3d3a:	push   rbp
    3d3b:	mov    rbp,rsp
    3d3e:	sub    rsp,0x50
    3d42:	mov    QWORD PTR [rsp+0x20],rbx
    3d47:	mov    QWORD PTR [rsp+0x28],r12
    3d4c:	mov    QWORD PTR [rsp+0x30],r13
    3d51:	mov    QWORD PTR [rsp+0x38],r14
    3d56:	mov    QWORD PTR [rsp+0x40],r15
    3d5b:	mov    r12,rdi
    3d5e:	mov    QWORD PTR [rsp],rsi
    3d62:	mov    r15,rsi
    3d65:	mov    QWORD PTR [rsp+0x8],rdx
    3d6a:	mov    QWORD PTR [rsp+0x10],rcx
    3d6f:	mov    r13,rcx
    3d72:	mov    QWORD PTR [rsp+0x18],r8
    3d77:	mov    rsi,r8
    3d7a:	mov    rdi,r12
    3d7d:	call   3d82 <botlish_fn_44+0x48>
			3d7e: R_X86_64_PLT32	botlish_fn_42-0x4 ; row_new<bool, int>
    3d82:	test   rax,rax
    3d85:	je     3dcf <botlish_fn_44+0x95>
    3d8b:	mov    QWORD PTR [rsp+0x8],rax
    3d90:	mov    r14,rax
    3d93:	mov    ebx,0x1
    3d98:	mov    QWORD PTR [rsp+0x18],0x1
    3da1:	mov    rsi,r13
    3da4:	mov    rdi,r12
    3da7:	call   3dac <botlish_fn_44+0x72>
			3da8: R_X86_64_PLT32	rt_list_len-0x4
    3dac:	mov    r9,rax
    3daf:	sar    r9,1
    3db2:	mov    rcx,r13
    3db5:	mov    rdx,r15
    3db8:	mov    rsi,r14
    3dbb:	mov    rdi,r12
    3dbe:	mov    r8,rbx
    3dc1:	call   3dc6 <botlish_fn_44+0x8c>
			3dc2: R_X86_64_PLT32	botlish_fn_43-0x4 ; row_fill<HashTable, List[str], List[str], int, int>
    3dc6:	test   rax,rax
    3dc9:	jne    3df4 <botlish_fn_44+0xba>
    3dcf:	xor    rax,rax
    3dd2:	mov    rbx,QWORD PTR [rsp+0x20]
    3dd7:	mov    r12,QWORD PTR [rsp+0x28]
    3ddc:	mov    r13,QWORD PTR [rsp+0x30]
    3de1:	mov    r14,QWORD PTR [rsp+0x38]
    3de6:	mov    r15,QWORD PTR [rsp+0x40]
    3deb:	add    rsp,0x50
    3def:	mov    rsp,rbp
    3df2:	pop    rbp
    3df3:	ret
    3df4:	mov    rbx,QWORD PTR [rsp+0x20]
    3df9:	mov    r12,QWORD PTR [rsp+0x28]
    3dfe:	mov    r13,QWORD PTR [rsp+0x30]
    3e03:	mov    r14,QWORD PTR [rsp+0x38]
    3e08:	mov    r15,QWORD PTR [rsp+0x40]
    3e0d:	add    rsp,0x50
    3e11:	mov    rsp,rbp
    3e14:	pop    rbp
    3e15:	ret

0000000000003e16 <botlish_entry_44: row_table<List[str], int, List[str], bool>>:
    3e16:	push   rbp
    3e17:	mov    rbp,rsp
    3e1a:	mov    rsi,QWORD PTR [rdx]
    3e1d:	mov    r9,QWORD PTR [rdx+0x8]
    3e21:	mov    rcx,QWORD PTR [rdx+0x10]
    3e25:	mov    r8,QWORD PTR [rdx+0x18]
    3e29:	mov    rdx,r9
    3e2c:	call   3e31 <botlish_entry_44+0x1b>
			3e2d: R_X86_64_PLT32	botlish_fn_44-0x4 ; row_table<List[str], int, List[str], bool>
    3e31:	mov    rsp,rbp
    3e34:	pop    rbp
    3e35:	ret

0000000000003e36 <botlish_fn_45: build_rows<List[List[str]], int, List[str], int, mutarray, int, bool>>:
    3e36:	push   rbp
    3e37:	mov    rbp,rsp
    3e3a:	sub    rsp,0x90
    3e41:	mov    QWORD PTR [rsp+0x60],rbx
    3e46:	mov    QWORD PTR [rsp+0x68],r12
    3e4b:	mov    QWORD PTR [rsp+0x70],r13
    3e50:	mov    QWORD PTR [rsp+0x78],r14
    3e55:	mov    QWORD PTR [rsp+0x80],r15
    3e5d:	mov    r13,r8
    3e60:	mov    QWORD PTR [rsp+0x38],rdi
    3e65:	mov    rdi,QWORD PTR [rbp+0x10]
    3e69:	mov    r15,QWORD PTR [rbp+0x18]
    3e6d:	mov    QWORD PTR [rsp+0x28],0x0
    3e76:	mov    QWORD PTR [rsp+0x30],0x0
    3e7f:	mov    QWORD PTR [rsp],rsi
    3e83:	mov    QWORD PTR [rsp+0x8],rcx
    3e88:	mov    r14,rcx
    3e8b:	mov    QWORD PTR [rsp+0x10],r9
    3e90:	mov    QWORD PTR [rsp+0x18],rdi
    3e95:	mov    QWORD PTR [rsp+0x20],r15
    3e9a:	sar    rdx,1
    3e9d:	mov    r12,rdx
    3ea0:	mov    rbx,rsi
    3ea3:	mov    QWORD PTR [rsp+0x40],r9
    3ea8:	mov    QWORD PTR [rsp+0x48],rdi
    3ead:	mov    rsi,rbx
    3eb0:	mov    rdi,QWORD PTR [rsp+0x38]
    3eb5:	call   3eba <botlish_fn_45+0x84>
			3eb6: R_X86_64_PLT32	rt_list_len-0x4
    3eba:	sar    rax,1
    3ebd:	cmp    r12,rax
    3ec0:	jge    3feb <botlish_fn_45+0x1b5>
    3ec6:	mov    rax,r13
    3ec9:	or     rax,0x1
    3ecd:	mov    QWORD PTR [rsp+0x28],rax
    3ed2:	mov    rcx,QWORD PTR [rbx+0x8]
    3ed6:	mov    rax,r12
    3ed9:	shl    rax,1
    3edc:	or     rax,0x1
    3ee0:	sar    rax,1
    3ee3:	cmp    rax,rcx
    3ee6:	jb     3f14 <botlish_fn_45+0xde>
    3eec:	mov    rdx,r12
    3eef:	shl    rdx,1
    3ef2:	or     rdx,0x1
    3ef6:	mov    rsi,rbx
    3ef9:	mov    rdi,QWORD PTR [rsp+0x38]
    3efe:	call   3f03 <botlish_fn_45+0xcd>
			3eff: R_X86_64_PLT32	rt_list_get-0x4
    3f03:	test   rax,rax
    3f06:	je     4008 <botlish_fn_45+0x1d2>
    3f0c:	mov    rcx,rax
    3f0f:	jmp    3f1c <botlish_fn_45+0xe6>
    3f14:	mov    rcx,QWORD PTR [rbx+0x10]
    3f18:	mov    rcx,QWORD PTR [rcx+rax*8]
    3f1c:	mov    QWORD PTR [rsp+0x30],rcx
    3f21:	mov    rdx,r13
    3f24:	or     rdx,0x1
    3f28:	mov    rsi,r14
    3f2b:	mov    rdi,QWORD PTR [rsp+0x38]
    3f30:	mov    r8,r15
    3f33:	call   3f38 <botlish_fn_45+0x102>
			3f34: R_X86_64_PLT32	botlish_fn_44-0x4 ; row_table<List[str], int, List[str], bool>
    3f38:	test   rax,rax
    3f3b:	je     4008 <botlish_fn_45+0x1d2>
    3f41:	mov    QWORD PTR [rsp+0x28],rax
    3f46:	mov    rcx,rax
    3f49:	mov    rsi,QWORD PTR [rsp+0x40]
    3f4e:	mov    rdx,QWORD PTR [rsp+0x48]
    3f53:	mov    rdi,QWORD PTR [rsp+0x38]
    3f58:	call   3f5d <botlish_fn_45+0x127>
			3f59: R_X86_64_PLT32	botlish_fn_10-0x4 ; geo_append<mutarray, int, HashTable>
    3f5d:	test   rax,rax
    3f60:	je     4008 <botlish_fn_45+0x1d2>
    3f66:	mov    QWORD PTR [rsp+0x10],rax
    3f6b:	mov    QWORD PTR [rsp+0x50],rax
    3f70:	mov    QWORD PTR [rsp+0x28],0x3
    3f79:	mov    rsi,QWORD PTR [rsp+0x48]
    3f7e:	test   rsi,0x1
    3f85:	je     3fa4 <botlish_fn_45+0x16e>
    3f8b:	mov    rsi,QWORD PTR [rsp+0x48]
    3f90:	mov    rax,rsi
    3f93:	add    rax,0x2
    3f97:	seto   r10b
    3f9b:	test   r10b,r10b
    3f9e:	je     3fb8 <botlish_fn_45+0x182>
    3fa4:	mov    edx,0x3
    3fa9:	mov    rsi,QWORD PTR [rsp+0x48]
    3fae:	mov    rdi,QWORD PTR [rsp+0x38]
    3fb3:	call   3fb8 <botlish_fn_45+0x182>
			3fb4: R_X86_64_PLT32	rt_int_add-0x4
    3fb8:	mov    QWORD PTR [rsp],rbx
    3fbc:	mov    QWORD PTR [rsp+0x8],r14
    3fc1:	mov    rcx,QWORD PTR [rsp+0x50]
    3fc6:	mov    QWORD PTR [rsp+0x10],rcx
    3fcb:	mov    QWORD PTR [rsp+0x18],rax
    3fd0:	mov    QWORD PTR [rsp+0x20],r15
    3fd5:	add    r12,0x1
    3fdc:	mov    QWORD PTR [rsp+0x40],rcx
    3fe1:	mov    QWORD PTR [rsp+0x48],rax
    3fe6:	jmp    3ead <botlish_fn_45+0x77>
    3feb:	mov    rdx,QWORD PTR [rsp+0x48]
    3ff0:	mov    rsi,QWORD PTR [rsp+0x40]
    3ff5:	mov    rdi,QWORD PTR [rsp+0x38]
    3ffa:	call   3fff <botlish_fn_45+0x1c9>
			3ffb: R_X86_64_PLT32	botlish_fn_11-0x4 ; geo_finish<mutarray, int>
    3fff:	test   rax,rax
    4002:	jne    4033 <botlish_fn_45+0x1fd>
    4008:	xor    rax,rax
    400b:	mov    rbx,QWORD PTR [rsp+0x60]
    4010:	mov    r12,QWORD PTR [rsp+0x68]
    4015:	mov    r13,QWORD PTR [rsp+0x70]
    401a:	mov    r14,QWORD PTR [rsp+0x78]
    401f:	mov    r15,QWORD PTR [rsp+0x80]
    4027:	add    rsp,0x90
    402e:	mov    rsp,rbp
    4031:	pop    rbp
    4032:	ret
    4033:	mov    rbx,QWORD PTR [rsp+0x60]
    4038:	mov    r12,QWORD PTR [rsp+0x68]
    403d:	mov    r13,QWORD PTR [rsp+0x70]
    4042:	mov    r14,QWORD PTR [rsp+0x78]
    4047:	mov    r15,QWORD PTR [rsp+0x80]
    404f:	add    rsp,0x90
    4056:	mov    rsp,rbp
    4059:	pop    rbp
    405a:	ret

000000000000405b <botlish_entry_45: build_rows<List[List[str]], int, List[str], int, mutarray, int, bool>>:
    405b:	push   rbp
    405c:	mov    rbp,rsp
    405f:	sub    rsp,0x10
    4063:	mov    rsi,QWORD PTR [rdx]
    4066:	mov    r10,QWORD PTR [rdx+0x8]
    406a:	mov    rcx,QWORD PTR [rdx+0x10]
    406e:	mov    r8,QWORD PTR [rdx+0x18]
    4072:	mov    r9,QWORD PTR [rdx+0x20]
    4076:	mov    r11,QWORD PTR [rdx+0x28]
    407a:	mov    rax,QWORD PTR [rdx+0x30]
    407e:	mov    QWORD PTR [rsp],r11
    4082:	mov    QWORD PTR [rsp+0x8],rax
    4087:	mov    rdx,r10
    408a:	call   408f <botlish_entry_45+0x34>
			408b: R_X86_64_PLT32	botlish_fn_45-0x4 ; build_rows<List[List[str]], int, List[str], int, mutarray, int, bool>
    408f:	add    rsp,0x10
    4093:	mov    rsp,rbp
    4096:	pop    rbp
    4097:	ret

0000000000004098 <botlish_fn_46: csv_records_generic<str, bool>>:
    4098:	push   rbp
    4099:	mov    rbp,rsp
    409c:	sub    rsp,0x80
    40a3:	mov    QWORD PTR [rsp+0x50],rbx
    40a8:	mov    QWORD PTR [rsp+0x58],r12
    40ad:	mov    QWORD PTR [rsp+0x60],r13
    40b2:	mov    QWORD PTR [rsp+0x68],r14
    40b7:	mov    QWORD PTR [rsp+0x70],r15
    40bc:	mov    r12,rdi
    40bf:	mov    QWORD PTR [rsp+0x20],0x0
    40c8:	mov    QWORD PTR [rsp+0x28],0x0
    40d1:	mov    QWORD PTR [rsp+0x30],0x0
    40da:	mov    QWORD PTR [rsp+0x38],0x0
    40e3:	mov    QWORD PTR [rsp+0x40],0x0
    40ec:	mov    QWORD PTR [rsp+0x10],rsi
    40f1:	mov    QWORD PTR [rsp+0x18],rdx
    40f6:	mov    r13,rdx
    40f9:	mov    rdi,r12
    40fc:	call   4101 <botlish_fn_46+0x69>
			40fd: R_X86_64_PLT32	botlish_fn_20-0x4 ; csv_parse<str>
    4101:	mov    rcx,rax
    4104:	mov    r14,rax
    4107:	test   rax,rcx
    410a:	je     4224 <botlish_fn_46+0x18c>
    4110:	mov    rax,r14
    4113:	mov    QWORD PTR [rsp+0x10],rax
    4118:	mov    rsi,r14
    411b:	mov    rdi,r12
    411e:	call   4123 <botlish_fn_46+0x8b>
			411f: R_X86_64_PLT32	rt_list_len-0x4
    4123:	sar    rax,1
    4126:	cmp    rax,0x1
    412a:	jle    420d <botlish_fn_46+0x175>
    4130:	mov    rax,r14
    4133:	mov    rax,QWORD PTR [rax+0x10]
    4137:	mov    rbx,QWORD PTR [rax]
    413a:	mov    QWORD PTR [rsp+0x20],rbx
    413f:	mov    rsi,rbx
    4142:	mov    rdi,r12
    4145:	call   414a <botlish_fn_46+0xb2>
			4146: R_X86_64_PLT32	rt_list_len-0x4
    414a:	mov    r15,rbx
    414d:	mov    QWORD PTR [rsp+0x28],rax
    4152:	mov    QWORD PTR [rsp+0x48],rax
    4157:	mov    rax,r14
    415a:	mov    rcx,QWORD PTR [rax+0x10]
    415e:	mov    rcx,QWORD PTR [rcx+0x8]
    4162:	mov    QWORD PTR [rsp+0x30],rcx
    4167:	mov    rbx,r13
    416a:	mov    rdx,QWORD PTR [rsp+0x48]
    416f:	mov    rsi,r15
    4172:	mov    rdi,r12
    4175:	mov    r8,rbx
    4178:	call   417d <botlish_fn_46+0xe5>
			4179: R_X86_64_PLT32	botlish_fn_44-0x4 ; row_table<List[str], int, List[str], bool>
    417d:	test   rax,rax
    4180:	je     4224 <botlish_fn_46+0x18c>
    4186:	mov    QWORD PTR [rsp+0x30],rax
    418b:	mov    rsi,rax
    418e:	mov    QWORD PTR [rsp+0x38],0x5
    4197:	mov    rdi,r12
    419a:	call   419f <botlish_fn_46+0x107>
			419b: R_X86_64_PLT32	botlish_fn_3-0x4 ; geo_new<HashTable>
    419f:	test   rax,rax
    41a2:	je     4224 <botlish_fn_46+0x18c>
    41a8:	mov    QWORD PTR [rsp+0x30],rax
    41ad:	mov    r9,rax
    41b0:	mov    eax,0x3
    41b5:	mov    QWORD PTR [rsp+0x40],0x3
    41be:	mov    edx,0x5
    41c3:	mov    QWORD PTR [rsp],rax
    41c7:	mov    QWORD PTR [rsp+0x8],rbx
    41cc:	mov    rcx,r15
    41cf:	mov    rsi,r14
    41d2:	mov    rdi,r12
    41d5:	mov    r8,QWORD PTR [rsp+0x48]
    41da:	call   41df <botlish_fn_46+0x147>
			41db: R_X86_64_PLT32	botlish_fn_45-0x4 ; build_rows<List[List[str]], int, List[str], int, mutarray, int, bool>
    41df:	test   rax,rax
    41e2:	je     4224 <botlish_fn_46+0x18c>
    41e8:	mov    rbx,QWORD PTR [rsp+0x50]
    41ed:	mov    r12,QWORD PTR [rsp+0x58]
    41f2:	mov    r13,QWORD PTR [rsp+0x60]
    41f7:	mov    r14,QWORD PTR [rsp+0x68]
    41fc:	mov    r15,QWORD PTR [rsp+0x70]
    4201:	add    rsp,0x80
    4208:	mov    rsp,rbp
    420b:	pop    rbp
    420c:	ret
    420d:	xor    rdx,rdx
    4210:	mov    rdi,r12
    4213:	mov    rsi,rdx
    4216:	call   421b <botlish_fn_46+0x183>
			4217: R_X86_64_PLT32	rt_list_new-0x4
    421b:	test   rax,rax
    421e:	jne    424c <botlish_fn_46+0x1b4>
    4224:	xor    rax,rax
    4227:	mov    rbx,QWORD PTR [rsp+0x50]
    422c:	mov    r12,QWORD PTR [rsp+0x58]
    4231:	mov    r13,QWORD PTR [rsp+0x60]
    4236:	mov    r14,QWORD PTR [rsp+0x68]
    423b:	mov    r15,QWORD PTR [rsp+0x70]
    4240:	add    rsp,0x80
    4247:	mov    rsp,rbp
    424a:	pop    rbp
    424b:	ret
    424c:	mov    rbx,QWORD PTR [rsp+0x50]
    4251:	mov    r12,QWORD PTR [rsp+0x58]
    4256:	mov    r13,QWORD PTR [rsp+0x60]
    425b:	mov    r14,QWORD PTR [rsp+0x68]
    4260:	mov    r15,QWORD PTR [rsp+0x70]
    4265:	add    rsp,0x80
    426c:	mov    rsp,rbp
    426f:	pop    rbp
    4270:	ret

0000000000004271 <botlish_entry_46: csv_records_generic<str, bool>>:
    4271:	push   rbp
    4272:	mov    rbp,rsp
    4275:	mov    rsi,QWORD PTR [rdx]
    4278:	mov    rdx,QWORD PTR [rdx+0x8]
    427c:	call   4281 <botlish_entry_46+0x10>
			427d: R_X86_64_PLT32	botlish_fn_46-0x4 ; csv_records_generic<str, bool>
    4281:	mov    rsp,rbp
    4284:	pop    rbp
    4285:	ret

0000000000004286 <botlish_fn_47: csv_records<str>>:
    4286:	push   rbp
    4287:	mov    rbp,rsp
    428a:	sub    rsp,0x10
    428e:	mov    QWORD PTR [rsp],rsi
    4292:	mov    edx,0x2
    4297:	mov    QWORD PTR [rsp+0x8],0x2
    42a0:	call   42a5 <botlish_fn_47+0x1f>
			42a1: R_X86_64_PLT32	botlish_fn_46-0x4 ; csv_records_generic<str, bool>
    42a5:	test   rax,rax
    42a8:	jne    42ba <botlish_fn_47+0x34>
    42ae:	xor    rax,rax
    42b1:	add    rsp,0x10
    42b5:	mov    rsp,rbp
    42b8:	pop    rbp
    42b9:	ret
    42ba:	add    rsp,0x10
    42be:	mov    rsp,rbp
    42c1:	pop    rbp
    42c2:	ret

00000000000042c3 <botlish_entry_47: csv_records<str>>:
    42c3:	push   rbp
    42c4:	mov    rbp,rsp
    42c7:	mov    rsi,QWORD PTR [rdx]
    42ca:	call   42cf <botlish_entry_47+0xc>
			42cb: R_X86_64_PLT32	botlish_fn_47-0x4 ; csv_records<str>
    42cf:	mov    rsp,rbp
    42d2:	pop    rbp
    42d3:	ret

00000000000042d4 <botlish_fn_48: csv_records_presized<str>>:
    42d4:	push   rbp
    42d5:	mov    rbp,rsp
    42d8:	sub    rsp,0x10
    42dc:	mov    QWORD PTR [rsp],rsi
    42e0:	mov    edx,0x6
    42e5:	mov    QWORD PTR [rsp+0x8],0x6
    42ee:	call   42f3 <botlish_fn_48+0x1f>
			42ef: R_X86_64_PLT32	botlish_fn_46-0x4 ; csv_records_generic<str, bool>
    42f3:	test   rax,rax
    42f6:	jne    4308 <botlish_fn_48+0x34>
    42fc:	xor    rax,rax
    42ff:	add    rsp,0x10
    4303:	mov    rsp,rbp
    4306:	pop    rbp
    4307:	ret
    4308:	add    rsp,0x10
    430c:	mov    rsp,rbp
    430f:	pop    rbp
    4310:	ret

0000000000004311 <botlish_entry_48: csv_records_presized<str>>:
    4311:	push   rbp
    4312:	mov    rbp,rsp
    4315:	mov    rsi,QWORD PTR [rdx]
    4318:	call   431d <botlish_entry_48+0xc>
			4319: R_X86_64_PLT32	botlish_fn_48-0x4 ; csv_records_presized<str>
    431d:	mov    rsp,rbp
    4320:	pop    rbp
    4321:	ret
    4322:	add    BYTE PTR [rax],al
    4324:	add    BYTE PTR [rax],al
	...

0000000000004328 <botlish_fn_49: sample_checks<generic>>:
    4328:	push   rbp
    4329:	mov    rbp,rsp
    432c:	sub    rsp,0xc0
    4333:	mov    QWORD PTR [rsp+0x90],rbx
    433b:	mov    QWORD PTR [rsp+0x98],r12
    4343:	mov    QWORD PTR [rsp+0xa0],r13
    434b:	mov    QWORD PTR [rsp+0xa8],r14
    4353:	mov    QWORD PTR [rsp+0xb0],r15
    435b:	mov    QWORD PTR [rsp+0x8],0x0
    4364:	mov    QWORD PTR [rsp+0x10],0x0
    436d:	mov    QWORD PTR [rsp+0x18],0x0
    4376:	mov    QWORD PTR [rsp+0x20],0x0
    437f:	mov    QWORD PTR [rsp+0x28],0x0
    4388:	mov    QWORD PTR [rsp+0x30],0x0
    4391:	mov    QWORD PTR [rsp+0x38],0x0
    439a:	mov    rax,QWORD PTR [rdi+0x10]
    439e:	mov    r13,rdi
    43a1:	mov    rsi,QWORD PTR [rax+0x20]
    43a5:	mov    QWORD PTR [rsp],rsi
    43a9:	call   43ae <botlish_fn_49+0x86>
			43aa: R_X86_64_PLT32	botlish_fn_47-0x4 ; csv_records<str>
    43ae:	mov    rsi,rax
    43b1:	mov    r12,rax
    43b4:	test   rax,rsi
    43b7:	je     473c <botlish_fn_49+0x414>
    43bd:	mov    rax,r12
    43c0:	mov    QWORD PTR [rsp],rax
    43c4:	mov    rdi,r13
    43c7:	mov    rax,QWORD PTR [rdi+0x10]
    43cb:	mov    rsi,QWORD PTR [rax+0x20]
    43cf:	mov    QWORD PTR [rsp+0x8],rsi
    43d4:	call   43d9 <botlish_fn_49+0xb1>
			43d5: R_X86_64_PLT32	botlish_fn_48-0x4 ; csv_records_presized<str>
    43d9:	mov    rbx,rax
    43dc:	test   rbx,rbx
    43df:	je     473c <botlish_fn_49+0x414>
    43e5:	mov    rax,r12
    43e8:	mov    rax,QWORD PTR [rax+0x8]
    43ec:	test   rax,rax
    43ef:	jne    4416 <botlish_fn_49+0xee>
    43f5:	mov    edx,0x1
    43fa:	mov    rsi,r12
    43fd:	mov    rdi,r13
    4400:	call   4405 <botlish_fn_49+0xdd>
			4401: R_X86_64_PLT32	rt_list_get-0x4
    4405:	test   rax,rax
    4408:	je     473c <botlish_fn_49+0x414>
    440e:	mov    rsi,rax
    4411:	jmp    441e <botlish_fn_49+0xf6>
    4416:	mov    rax,QWORD PTR [r12+0x10]
    441b:	mov    rsi,QWORD PTR [rax]
    441e:	mov    QWORD PTR [rsp+0x8],rsi
    4423:	mov    r15,rsi
    4426:	mov    rax,QWORD PTR [r12+0x8]
    442b:	cmp    rax,0x1
    442f:	ja     4456 <botlish_fn_49+0x12e>
    4435:	mov    edx,0x3
    443a:	mov    rsi,r12
    443d:	mov    rdi,r13
    4440:	call   4445 <botlish_fn_49+0x11d>
			4441: R_X86_64_PLT32	rt_list_get-0x4
    4445:	test   rax,rax
    4448:	je     473c <botlish_fn_49+0x414>
    444e:	mov    rsi,rax
    4451:	jmp    445f <botlish_fn_49+0x137>
    4456:	mov    rax,QWORD PTR [r12+0x10]
    445b:	mov    rsi,QWORD PTR [rax+0x8]
    445f:	mov    QWORD PTR [rsp+0x10],rsi
    4464:	mov    r14,rsi
    4467:	mov    rax,QWORD PTR [rbx+0x8]
    446b:	mov    rsi,rbx
    446e:	test   rax,rax
    4471:	jne    4495 <botlish_fn_49+0x16d>
    4477:	mov    edx,0x1
    447c:	mov    rdi,r13
    447f:	call   4484 <botlish_fn_49+0x15c>
			4480: R_X86_64_PLT32	rt_list_get-0x4
    4484:	test   rax,rax
    4487:	je     473c <botlish_fn_49+0x414>
    448d:	mov    rsi,rax
    4490:	jmp    449c <botlish_fn_49+0x174>
    4495:	mov    rax,QWORD PTR [rsi+0x10]
    4499:	mov    rsi,QWORD PTR [rax]
    449c:	mov    QWORD PTR [rsp+0x18],rsi
    44a1:	mov    rdi,r13
    44a4:	mov    QWORD PTR [rsp+0x78],rsi
    44a9:	mov    rax,QWORD PTR [rdi+0x10]
    44ad:	mov    rdx,QWORD PTR [rax+0x28]
    44b1:	mov    QWORD PTR [rsp+0x20],rdx
    44b6:	mov    rsi,r15
    44b9:	call   44be <botlish_fn_49+0x196>
			44ba: R_X86_64_PLT32	botlish_fn_33-0x4 ; ht_get<HashTable, str>
    44be:	test   rax,rax
    44c1:	je     473c <botlish_fn_49+0x414>
    44c7:	mov    QWORD PTR [rsp+0x20],rax
    44cc:	mov    rbx,rax
    44cf:	mov    rdi,r13
    44d2:	mov    rax,QWORD PTR [rdi+0x10]
    44d6:	mov    rdx,QWORD PTR [rax+0x28]
    44da:	mov    QWORD PTR [rsp+0x28],rdx
    44df:	mov    rsi,QWORD PTR [rsp+0x78]
    44e4:	call   44e9 <botlish_fn_49+0x1c1>
			44e5: R_X86_64_PLT32	botlish_fn_33-0x4 ; ht_get<HashTable, str>
    44e9:	test   rax,rax
    44ec:	je     473c <botlish_fn_49+0x414>
    44f2:	mov    rcx,rbx
    44f5:	mov    rdx,rcx
    44f8:	and    rdx,rax
    44fb:	test   rdx,0x1
    4502:	jne    4524 <botlish_fn_49+0x1fc>
    4508:	mov    rdx,rax
    450b:	mov    rsi,rbx
    450e:	mov    rdi,r13
    4511:	call   4516 <botlish_fn_49+0x1ee>
			4512: R_X86_64_PLT32	rt_value_eq-0x4
    4516:	test   rax,rax
    4519:	je     473c <botlish_fn_49+0x414>
    451f:	jmp    453a <botlish_fn_49+0x212>
    4524:	mov    rdx,rax
    4527:	mov    rsi,rbx
    452a:	mov    eax,0x2
    452f:	cmp    rsi,rdx
    4532:	cmove  rax,QWORD PTR [rip+0x26e]        # 47a8 <botlish_fn_49+0x480>
    453a:	mov    ebx,0x6
    453f:	cmp    rax,0x6
    4543:	je     455e <botlish_fn_49+0x236>
    4549:	mov    ebx,0x2
    454e:	mov    QWORD PTR [rsp],0x2
    4556:	mov    rsi,r12
    4559:	jmp    45fd <botlish_fn_49+0x2d5>
    455e:	mov    rsi,r15
    4561:	mov    rdi,r13
    4564:	call   4569 <botlish_fn_49+0x241>
			4565: R_X86_64_PLT32	botlish_fn_26-0x4 ; ht_size<HashTable>
    4569:	test   rax,rax
    456c:	mov    QWORD PTR [rsp+0x88],rax
    4574:	je     473c <botlish_fn_49+0x414>
    457a:	mov    rsi,QWORD PTR [rsp+0x78]
    457f:	mov    rdi,r13
    4582:	call   4587 <botlish_fn_49+0x25f>
			4583: R_X86_64_PLT32	botlish_fn_26-0x4 ; ht_size<HashTable>
    4587:	test   rax,rax
    458a:	je     473c <botlish_fn_49+0x414>
    4590:	mov    rcx,QWORD PTR [rsp+0x88]
    4598:	mov    rdx,rcx
    459b:	and    rdx,rax
    459e:	test   rdx,0x1
    45a5:	jne    45cc <botlish_fn_49+0x2a4>
    45ab:	mov    rdx,rax
    45ae:	mov    rsi,QWORD PTR [rsp+0x88]
    45b6:	mov    rdi,r13
    45b9:	call   45be <botlish_fn_49+0x296>
			45ba: R_X86_64_PLT32	rt_value_eq-0x4
    45be:	test   rax,rax
    45c1:	je     473c <botlish_fn_49+0x414>
    45c7:	jmp    45e7 <botlish_fn_49+0x2bf>
    45cc:	mov    rdx,rax
    45cf:	mov    rsi,QWORD PTR [rsp+0x88]
    45d7:	mov    eax,0x2
    45dc:	cmp    rsi,rdx
    45df:	cmove  rax,QWORD PTR [rip+0x1c1]        # 47a8 <botlish_fn_49+0x480>
    45e7:	cmp    rax,0x6
    45eb:	je     45f6 <botlish_fn_49+0x2ce>
    45f1:	mov    ebx,0x2
    45f6:	mov    QWORD PTR [rsp],rbx
    45fa:	mov    rsi,r12
    45fd:	mov    rdi,r13
    4600:	call   4605 <botlish_fn_49+0x2dd>
			4601: R_X86_64_PLT32	rt_list_len-0x4
    4605:	mov    QWORD PTR [rsp+0x18],rax
    460a:	mov    rdi,r13
    460d:	mov    r12,rax
    4610:	mov    rax,QWORD PTR [rdi+0x10]
    4614:	mov    rdx,QWORD PTR [rax+0x28]
    4618:	mov    QWORD PTR [rsp+0x20],rdx
    461d:	mov    rsi,r15
    4620:	call   4625 <botlish_fn_49+0x2fd>
			4621: R_X86_64_PLT32	botlish_fn_33-0x4 ; ht_get<HashTable, str>
    4625:	test   rax,rax
    4628:	je     473c <botlish_fn_49+0x414>
    462e:	mov    QWORD PTR [rsp+0x20],rax
    4633:	mov    rdi,r13
    4636:	mov    QWORD PTR [rsp+0x88],rax
    463e:	mov    rax,QWORD PTR [rdi+0x10]
    4642:	mov    rdx,QWORD PTR [rax+0x30]
    4646:	mov    QWORD PTR [rsp+0x28],rdx
    464b:	mov    rsi,r15
    464e:	call   4653 <botlish_fn_49+0x32b>
			464f: R_X86_64_PLT32	botlish_fn_33-0x4 ; ht_get<HashTable, str>
    4653:	test   rax,rax
    4656:	je     473c <botlish_fn_49+0x414>
    465c:	mov    QWORD PTR [rsp+0x28],rax
    4661:	mov    rdi,r13
    4664:	mov    QWORD PTR [rsp+0x80],rax
    466c:	mov    rax,QWORD PTR [rdi+0x10]
    4670:	mov    rdx,QWORD PTR [rax+0x38]
    4674:	mov    QWORD PTR [rsp+0x30],rdx
    4679:	mov    rsi,r15
    467c:	call   4681 <botlish_fn_49+0x359>
			467d: R_X86_64_PLT32	botlish_fn_33-0x4 ; ht_get<HashTable, str>
    4681:	test   rax,rax
    4684:	je     473c <botlish_fn_49+0x414>
    468a:	mov    QWORD PTR [rsp+0x8],rax
    468f:	mov    rdi,r13
    4692:	mov    r15,rax
    4695:	mov    rax,QWORD PTR [rdi+0x10]
    4699:	mov    rdx,QWORD PTR [rax+0x28]
    469d:	mov    QWORD PTR [rsp+0x30],rdx
    46a2:	mov    rsi,r14
    46a5:	call   46aa <botlish_fn_49+0x382>
			46a6: R_X86_64_PLT32	botlish_fn_33-0x4 ; ht_get<HashTable, str>
    46aa:	test   rax,rax
    46ad:	je     473c <botlish_fn_49+0x414>
    46b3:	mov    QWORD PTR [rsp+0x30],rax
    46b8:	mov    rdi,r13
    46bb:	mov    QWORD PTR [rsp+0x78],rax
    46c0:	mov    rax,QWORD PTR [rdi+0x10]
    46c4:	mov    rdx,QWORD PTR [rax+0x38]
    46c8:	mov    QWORD PTR [rsp+0x38],rdx
    46cd:	mov    rsi,r14
    46d0:	call   46d5 <botlish_fn_49+0x3ad>
			46d1: R_X86_64_PLT32	botlish_fn_33-0x4 ; ht_get<HashTable, str>
    46d5:	test   rax,rax
    46d8:	je     473c <botlish_fn_49+0x414>
    46de:	mov    QWORD PTR [rsp+0x10],rax
    46e3:	lea    rdx,[rsp+0x40]
    46e8:	mov    r9,r12
    46eb:	mov    QWORD PTR [rsp+0x40],r9
    46f0:	mov    rcx,QWORD PTR [rsp+0x88]
    46f8:	mov    QWORD PTR [rsp+0x48],rcx
    46fd:	mov    rcx,QWORD PTR [rsp+0x80]
    4705:	mov    QWORD PTR [rsp+0x50],rcx
    470a:	mov    rcx,r15
    470d:	mov    QWORD PTR [rsp+0x58],rcx
    4712:	mov    rcx,QWORD PTR [rsp+0x78]
    4717:	mov    QWORD PTR [rsp+0x60],rcx
    471c:	mov    QWORD PTR [rsp+0x68],rax
    4721:	mov    QWORD PTR [rsp+0x70],rbx
    4726:	mov    esi,0x7
    472b:	mov    rdi,r13
    472e:	call   4733 <botlish_fn_49+0x40b>
			472f: R_X86_64_PLT32	rt_list_new-0x4
    4733:	test   rax,rax
    4736:	jne    4773 <botlish_fn_49+0x44b>
    473c:	xor    rax,rax
    473f:	mov    rbx,QWORD PTR [rsp+0x90]
    4747:	mov    r12,QWORD PTR [rsp+0x98]
    474f:	mov    r13,QWORD PTR [rsp+0xa0]
    4757:	mov    r14,QWORD PTR [rsp+0xa8]
    475f:	mov    r15,QWORD PTR [rsp+0xb0]
    4767:	add    rsp,0xc0
    476e:	mov    rsp,rbp
    4771:	pop    rbp
    4772:	ret
    4773:	mov    rbx,QWORD PTR [rsp+0x90]
    477b:	mov    r12,QWORD PTR [rsp+0x98]
    4783:	mov    r13,QWORD PTR [rsp+0xa0]
    478b:	mov    r14,QWORD PTR [rsp+0xa8]
    4793:	mov    r15,QWORD PTR [rsp+0xb0]
    479b:	add    rsp,0xc0
    47a2:	mov    rsp,rbp
    47a5:	pop    rbp
    47a6:	ret
    47a7:	add    BYTE PTR [rsi],al
    47a9:	add    BYTE PTR [rax],al
    47ab:	add    BYTE PTR [rax],al
    47ad:	add    BYTE PTR [rax],al
	...

00000000000047b0 <botlish_entry_49: sample_checks<generic>>:
    47b0:	push   rbp
    47b1:	mov    rbp,rsp
    47b4:	call   47b9 <botlish_entry_49+0x9>
			47b5: R_X86_64_PLT32	botlish_fn_49-0x4 ; sample_checks<generic>
    47b9:	mov    rsp,rbp
    47bc:	pop    rbp
    47bd:	ret

00000000000047be <botlish_fn_50: sample<generic>>:
    47be:	push   rbp
    47bf:	mov    rbp,rsp
    47c2:	sub    rsp,0x10
    47c6:	mov    QWORD PTR [rsp],rbx
    47ca:	mov    rbx,rdi
    47cd:	mov    rdi,rbx
    47d0:	call   47d5 <botlish_fn_50+0x17>
			47d1: R_X86_64_PLT32	botlish_fn_49-0x4 ; sample_checks<generic>
    47d5:	test   rax,rax
    47d8:	jne    4891 <botlish_fn_50+0xd3>
    47de:	mov    rdi,rbx
    47e1:	call   47e6 <botlish_fn_50+0x28>
			47e2: R_X86_64_PLT32	rt_declared_error-0x4
    47e6:	cmp    rax,0x40000001
    47ec:	je     4862 <botlish_fn_50+0xa4>
    47f2:	mov    rdi,rbx
    47f5:	call   47fa <botlish_fn_50+0x3c>
			47f6: R_X86_64_PLT32	rt_declared_error-0x4
    47fa:	cmp    rax,0x40000002
    4800:	je     483e <botlish_fn_50+0x80>
    4806:	mov    rdi,rbx
    4809:	call   480e <botlish_fn_50+0x50>
			480a: R_X86_64_PLT32	rt_declared_error-0x4
    480e:	cmp    rax,0x40000003
    4814:	jne    4881 <botlish_fn_50+0xc3>
    481a:	mov    rdi,rbx
    481d:	call   4822 <botlish_fn_50+0x64>
			481e: R_X86_64_PLT32	rt_clear_declared_error-0x4
    4822:	xor    rdx,rdx
    4825:	mov    rdi,rbx
    4828:	mov    rsi,rdx
    482b:	call   4830 <botlish_fn_50+0x72>
			482c: R_X86_64_PLT32	rt_list_new-0x4
    4830:	test   rax,rax
    4833:	je     4881 <botlish_fn_50+0xc3>
    4839:	jmp    4891 <botlish_fn_50+0xd3>
    483e:	mov    rdi,rbx
    4841:	call   4846 <botlish_fn_50+0x88>
			4842: R_X86_64_PLT32	rt_clear_declared_error-0x4
    4846:	xor    rdx,rdx
    4849:	mov    rdi,rbx
    484c:	mov    rsi,rdx
    484f:	call   4854 <botlish_fn_50+0x96>
			4850: R_X86_64_PLT32	rt_list_new-0x4
    4854:	test   rax,rax
    4857:	je     4881 <botlish_fn_50+0xc3>
    485d:	jmp    4891 <botlish_fn_50+0xd3>
    4862:	mov    rdi,rbx
    4865:	call   486a <botlish_fn_50+0xac>
			4866: R_X86_64_PLT32	rt_clear_declared_error-0x4
    486a:	xor    rdx,rdx
    486d:	mov    rdi,rbx
    4870:	mov    rsi,rdx
    4873:	call   4878 <botlish_fn_50+0xba>
			4874: R_X86_64_PLT32	rt_list_new-0x4
    4878:	test   rax,rax
    487b:	jne    4891 <botlish_fn_50+0xd3>
    4881:	xor    rax,rax
    4884:	mov    rbx,QWORD PTR [rsp]
    4888:	add    rsp,0x10
    488c:	mov    rsp,rbp
    488f:	pop    rbp
    4890:	ret
    4891:	mov    rbx,QWORD PTR [rsp]
    4895:	add    rsp,0x10
    4899:	mov    rsp,rbp
    489c:	pop    rbp
    489d:	ret

000000000000489e <botlish_entry_50: sample<generic>>:
    489e:	push   rbp
    489f:	mov    rbp,rsp
    48a2:	call   48a7 <botlish_entry_50+0x9>
			48a3: R_X86_64_PLT32	botlish_fn_50-0x4 ; sample<generic>
    48a7:	mov    rsp,rbp
    48aa:	pop    rbp
    48ab:	ret
