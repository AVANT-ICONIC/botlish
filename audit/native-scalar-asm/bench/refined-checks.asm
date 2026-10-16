; source:  bench/refined-checks.bot
; backend: Cranelift (specialize=1), native::object
; object:  ELF64 x86-64, unlinked (Botlish-generated code only; runtime
;          helpers are unresolved imports, so their bodies are not present)
; format:  objdump -dr --no-show-raw-insn -M intel
; total machine code bytes: 10655  (per function: 1415 217 745 74 74 74 128 128 336 154 115 216 176 176 295 344 183 564 140 60 501 757 127 103 345 219 287 1255 1079 368)
;
; function symbol -> Botlish label:
;   botlish_fn_0 / botlish_entry_0 -> <program entry>
;   botlish_fn_1 / botlish_entry_1 -> byte::from_int<int>
;   botlish_fn_2 / botlish_entry_2 -> byte::set<List[UnicodeChar]>
;   botlish_fn_3 / botlish_entry_3 -> ascii::is_digit<int>
;   botlish_fn_4 / botlish_entry_4 -> ascii::is_upper<int>
;   botlish_fn_5 / botlish_entry_5 -> ascii::is_lower<int>
;   botlish_fn_6 / botlish_entry_6 -> ascii::is_alphabetic<int>
;   botlish_fn_7 / botlish_entry_7 -> ascii::is_alphanumeric<int>
;   botlish_fn_8 / botlish_entry_8 -> web::emailish?<str>
;   botlish_fn_9 / botlish_entry_9 -> char_at<int>
;   botlish_fn_10 / botlish_entry_10 -> char_at<int>
;   botlish_fn_11 / botlish_entry_11 -> char_is?<int, any>
;   botlish_fn_12 / botlish_entry_12 -> local_char?<str>
;   botlish_fn_13 / botlish_entry_13 -> local_char?<generic>
;   botlish_fn_14 / botlish_entry_14 -> scan_while<int, block(e276)>
;   botlish_fn_15 / botlish_entry_15 -> scan_while<int, native(str::is_tcl_alpha)>
;   botlish_fn_16 / botlish_entry_16 -> tld?<int>
;   botlish_fn_17 / botlish_entry_17 -> domain?<int>
;   botlish_fn_18 / botlish_entry_18 -> web::is_unreserved<int>
;   botlish_fn_19 / botlish_entry_19 -> web::uri_query_value?<str>
;   botlish_fn_20 / botlish_entry_20 -> upper_hex?<int>
;   botlish_fn_21 / botlish_entry_21 -> valid_from?<int>
;   botlish_fn_22 / botlish_entry_22 -> web::uri_escape_text<str>
;   botlish_fn_23 / botlish_entry_23 -> high_nibble<int>
;   botlish_fn_24 / botlish_entry_24 -> hex_pair<int>
;   botlish_fn_25 / botlish_entry_25 -> pct<int>
;   botlish_fn_26 / botlish_entry_26 -> cont<int, int>
;   botlish_fn_27 / botlish_entry_27 -> esc_scalar<int>
;   botlish_fn_28 / botlish_entry_28 -> esc_from<str, int, str>
;   botlish_fn_29 / botlish_entry_29 -> check<int, int, str, str>


refined-checks.asm.o:     file format elf64-x86-64


Disassembly of section .text:

0000000000000000 <botlish_fn_0: <program entry>>:
       0:	push   rbp
       1:	mov    rbp,rsp
       4:	sub    rsp,0x1b0
       b:	mov    QWORD PTR [rsp+0x180],rbx
      13:	mov    QWORD PTR [rsp+0x188],r12
      1b:	mov    QWORD PTR [rsp+0x190],r13
      23:	mov    QWORD PTR [rsp+0x198],r14
      2b:	mov    QWORD PTR [rsp+0x1a0],r15
      33:	mov    QWORD PTR [rsp+0x28],0x0
      3c:	mov    QWORD PTR [rsp+0x30],0x0
      45:	mov    QWORD PTR [rsp+0x38],0x0
      4e:	mov    QWORD PTR [rsp+0x40],0x0
      57:	mov    QWORD PTR [rsp+0x48],0x0
      60:	mov    QWORD PTR [rsp+0x50],0x0
      69:	mov    QWORD PTR [rsp+0x58],0x0
      72:	mov    QWORD PTR [rsp+0x60],0x0
      7b:	mov    QWORD PTR [rsp+0x68],0x0
      84:	mov    QWORD PTR [rsp+0x70],0x0
      8d:	mov    QWORD PTR [rsp+0x78],0x0
      96:	mov    rax,QWORD PTR [rdi+0x10]
      9a:	mov    rax,QWORD PTR [rax]
      9d:	mov    QWORD PTR [rsp],rax
      a1:	mov    rcx,QWORD PTR [rdi+0x10]
      a5:	mov    rcx,QWORD PTR [rcx+0x8]
      a9:	mov    QWORD PTR [rsp+0x8],rcx
      ae:	mov    rdx,QWORD PTR [rdi+0x10]
      b2:	mov    r8,QWORD PTR [rdx+0x10]
      b6:	mov    QWORD PTR [rsp+0x10],r8
      bb:	mov    rdx,QWORD PTR [rdi+0x10]
      bf:	mov    rsi,QWORD PTR [rdx+0x18]
      c3:	mov    QWORD PTR [rsp+0x18],rsi
      c8:	mov    rdx,QWORD PTR [rdi+0x10]
      cc:	mov    QWORD PTR [rsp+0x158],rdi
      d4:	mov    rdi,QWORD PTR [rdx+0x20]
      d8:	mov    QWORD PTR [rsp+0x20],rdi
      dd:	lea    rdx,[rsp+0x80]
      e5:	mov    QWORD PTR [rsp+0x80],rax
      ed:	mov    QWORD PTR [rsp+0x88],rcx
      f5:	mov    QWORD PTR [rsp+0x90],r8
      fd:	mov    QWORD PTR [rsp+0x98],rsi
     105:	mov    QWORD PTR [rsp+0xa0],rdi
     10d:	mov    esi,0x5
     112:	mov    rdi,QWORD PTR [rsp+0x158]
     11a:	call   11f <botlish_fn_0+0x11f>
			11b: R_X86_64_PLT32	rt_list_new-0x4
     11f:	test   rax,rax
     122:	je     4e8 <botlish_fn_0+0x4e8>
     128:	mov    QWORD PTR [rsp],rax
     12c:	mov    rsi,rax
     12f:	mov    rdi,QWORD PTR [rsp+0x158]
     137:	call   13c <botlish_fn_0+0x13c>
			138: R_X86_64_PLT32	rt_set_from_list-0x4
     13c:	mov    rdi,QWORD PTR [rsp+0x158]
     144:	mov    rcx,QWORD PTR [rdi+0x30]
     148:	mov    QWORD PTR [rcx],rax
     14b:	mov    rax,QWORD PTR [rdi+0x10]
     14f:	mov    rcx,QWORD PTR [rax+0x28]
     153:	mov    QWORD PTR [rsp],rcx
     157:	mov    QWORD PTR [rsp+0x178],rcx
     15f:	mov    rax,QWORD PTR [rdi+0x10]
     163:	mov    rdx,QWORD PTR [rax+0x30]
     167:	mov    QWORD PTR [rsp+0x8],rdx
     16c:	mov    QWORD PTR [rsp+0x170],rdx
     174:	mov    rax,QWORD PTR [rdi+0x10]
     178:	mov    rsi,QWORD PTR [rax+0x38]
     17c:	mov    QWORD PTR [rsp+0x10],rsi
     181:	mov    QWORD PTR [rsp+0x168],rsi
     189:	mov    rax,QWORD PTR [rdi+0x10]
     18d:	mov    rdi,QWORD PTR [rax+0x40]
     191:	mov    QWORD PTR [rsp+0x18],rdi
     196:	mov    QWORD PTR [rsp+0x160],rdi
     19e:	mov    rdi,QWORD PTR [rsp+0x158]
     1a6:	mov    rax,QWORD PTR [rdi+0x10]
     1aa:	mov    rdi,QWORD PTR [rax+0x48]
     1ae:	mov    QWORD PTR [rsp+0x20],rdi
     1b3:	mov    rax,QWORD PTR [rsp+0x158]
     1bb:	mov    rax,QWORD PTR [rax+0x10]
     1bf:	mov    r8,QWORD PTR [rax+0x50]
     1c3:	mov    QWORD PTR [rsp+0x28],r8
     1c8:	mov    rax,QWORD PTR [rsp+0x158]
     1d0:	mov    rax,QWORD PTR [rax+0x10]
     1d4:	mov    r9,QWORD PTR [rax+0x58]
     1d8:	mov    QWORD PTR [rsp+0x30],r9
     1dd:	mov    rax,QWORD PTR [rsp+0x158]
     1e5:	mov    rax,QWORD PTR [rax+0x10]
     1e9:	mov    r10,QWORD PTR [rax+0x60]
     1ed:	mov    QWORD PTR [rsp+0x38],r10
     1f2:	mov    rax,QWORD PTR [rsp+0x158]
     1fa:	mov    rax,QWORD PTR [rax+0x10]
     1fe:	mov    r11,QWORD PTR [rax+0x68]
     202:	mov    QWORD PTR [rsp+0x40],r11
     207:	mov    rax,QWORD PTR [rsp+0x158]
     20f:	mov    rax,QWORD PTR [rax+0x10]
     213:	mov    rbx,QWORD PTR [rax+0x70]
     217:	mov    QWORD PTR [rsp+0x48],rbx
     21c:	mov    rax,QWORD PTR [rsp+0x158]
     224:	mov    rax,QWORD PTR [rax+0x10]
     228:	mov    r12,QWORD PTR [rax+0x78]
     22c:	mov    QWORD PTR [rsp+0x50],r12
     231:	mov    rax,QWORD PTR [rsp+0x158]
     239:	mov    rax,QWORD PTR [rax+0x10]
     23d:	mov    r13,QWORD PTR [rax+0x80]
     244:	mov    QWORD PTR [rsp+0x58],r13
     249:	mov    rax,QWORD PTR [rsp+0x158]
     251:	mov    rax,QWORD PTR [rax+0x10]
     255:	mov    r14,QWORD PTR [rax+0x88]
     25c:	mov    QWORD PTR [rsp+0x60],r14
     261:	mov    rax,QWORD PTR [rsp+0x158]
     269:	mov    rax,QWORD PTR [rax+0x10]
     26d:	mov    r15,QWORD PTR [rax+0x90]
     274:	mov    QWORD PTR [rsp+0x68],r15
     279:	mov    rax,QWORD PTR [rsp+0x158]
     281:	mov    rax,QWORD PTR [rax+0x10]
     285:	mov    rax,QWORD PTR [rax+0x98]
     28c:	mov    QWORD PTR [rsp+0x70],rax
     291:	mov    rcx,QWORD PTR [rsp+0x158]
     299:	mov    rcx,QWORD PTR [rcx+0x10]
     29d:	mov    rcx,QWORD PTR [rcx+0xa0]
     2a4:	mov    QWORD PTR [rsp+0x78],rcx
     2a9:	lea    rdx,[rsp+0xa8]
     2b1:	mov    rsi,QWORD PTR [rsp+0x178]
     2b9:	mov    QWORD PTR [rsp+0xa8],rsi
     2c1:	mov    rsi,QWORD PTR [rsp+0x170]
     2c9:	mov    QWORD PTR [rsp+0xb0],rsi
     2d1:	mov    rsi,QWORD PTR [rsp+0x168]
     2d9:	mov    QWORD PTR [rsp+0xb8],rsi
     2e1:	mov    rsi,QWORD PTR [rsp+0x160]
     2e9:	mov    QWORD PTR [rsp+0xc0],rsi
     2f1:	mov    QWORD PTR [rsp+0xc8],rdi
     2f9:	mov    QWORD PTR [rsp+0xd0],r8
     301:	mov    QWORD PTR [rsp+0xd8],r9
     309:	mov    QWORD PTR [rsp+0xe0],r10
     311:	mov    QWORD PTR [rsp+0xe8],r11
     319:	mov    QWORD PTR [rsp+0xf0],rbx
     321:	mov    QWORD PTR [rsp+0xf8],r12
     329:	mov    QWORD PTR [rsp+0x100],r13
     331:	mov    QWORD PTR [rsp+0x108],r14
     339:	mov    QWORD PTR [rsp+0x110],r15
     341:	mov    QWORD PTR [rsp+0x118],rax
     349:	mov    QWORD PTR [rsp+0x120],rcx
     351:	mov    esi,0x10
     356:	mov    rdi,QWORD PTR [rsp+0x158]
     35e:	call   363 <botlish_fn_0+0x363>
			35f: R_X86_64_PLT32	rt_list_new-0x4
     363:	test   rax,rax
     366:	je     4e8 <botlish_fn_0+0x4e8>
     36c:	mov    rdi,QWORD PTR [rsp+0x158]
     374:	mov    r10,QWORD PTR [rdi+0x30]
     378:	mov    QWORD PTR [r10+0x8],rax
     37c:	mov    QWORD PTR [rsp],0x16c
     384:	mov    QWORD PTR [rsp+0x8],0x174
     38d:	mov    QWORD PTR [rsp+0x10],0x2fc
     396:	mov    QWORD PTR [rsp+0x18],0x3f4
     39f:	lea    rdx,[rsp+0x128]
     3a7:	mov    QWORD PTR [rsp+0x128],0x16c
     3b3:	mov    QWORD PTR [rsp+0x130],0x174
     3bf:	mov    QWORD PTR [rsp+0x138],0x2fc
     3cb:	mov    QWORD PTR [rsp+0x140],0x3f4
     3d7:	mov    esi,0x4
     3dc:	call   3e1 <botlish_fn_0+0x3e1>
			3dd: R_X86_64_PLT32	rt_list_new-0x4
     3e1:	test   rax,rax
     3e4:	je     4e8 <botlish_fn_0+0x4e8>
     3ea:	mov    QWORD PTR [rsp],rax
     3ee:	mov    rsi,rax
     3f1:	mov    rdi,QWORD PTR [rsp+0x158]
     3f9:	call   3fe <botlish_fn_0+0x3fe>
			3fa: R_X86_64_PLT32	botlish_fn_2-0x4 ; byte::set<List[UnicodeChar]>
     3fe:	test   rax,rax
     401:	je     4e8 <botlish_fn_0+0x4e8>
     407:	mov    rdi,QWORD PTR [rsp+0x158]
     40f:	mov    rcx,QWORD PTR [rdi+0x30]
     413:	mov    QWORD PTR [rcx+0x10],rax
     417:	mov    esi,0xe2a0e1
     41c:	call   421 <botlish_fn_0+0x421>
			41d: R_X86_64_PLT32	botlish_fn_22-0x4 ; web::uri_escape_text<str>
     421:	test   rax,rax
     424:	je     4e8 <botlish_fn_0+0x4e8>
     42a:	mov    QWORD PTR [rsp],rax
     42e:	mov    rbx,rax
     431:	mov    edx,0x1
     436:	mov    QWORD PTR [rsp+0x8],0x1
     43f:	mov    rdi,QWORD PTR [rsp+0x158]
     447:	mov    rcx,QWORD PTR [rdi+0x10]
     44b:	mov    rcx,QWORD PTR [rcx+0xa8]
     452:	mov    QWORD PTR [rsp+0x10],rcx
     457:	mov    esi,0x190
     45c:	mov    r8,rbx
     45f:	call   464 <botlish_fn_0+0x464>
			460: R_X86_64_PLT32	botlish_fn_29-0x4 ; check<int, int, str, str>
     464:	mov    r12,rax
     467:	test   r12,r12
     46a:	je     4e8 <botlish_fn_0+0x4e8>
     470:	mov    QWORD PTR [rsp+0x8],r12
     475:	mov    edx,0x1
     47a:	mov    QWORD PTR [rsp+0x10],0x1
     483:	mov    rdi,QWORD PTR [rsp+0x158]
     48b:	mov    rax,QWORD PTR [rdi+0x10]
     48f:	mov    rcx,QWORD PTR [rax+0xb0]
     496:	mov    QWORD PTR [rsp+0x18],rcx
     49b:	mov    esi,0x190
     4a0:	mov    r8,rbx
     4a3:	call   4a8 <botlish_fn_0+0x4a8>
			4a4: R_X86_64_PLT32	botlish_fn_29-0x4 ; check<int, int, str, str>
     4a8:	test   rax,rax
     4ab:	je     4e8 <botlish_fn_0+0x4e8>
     4b1:	mov    QWORD PTR [rsp],rax
     4b5:	lea    rdx,[rsp+0x148]
     4bd:	mov    QWORD PTR [rsp+0x148],r12
     4c5:	mov    QWORD PTR [rsp+0x150],rax
     4cd:	mov    esi,0x2
     4d2:	mov    rdi,QWORD PTR [rsp+0x158]
     4da:	call   4df <botlish_fn_0+0x4df>
			4db: R_X86_64_PLT32	rt_list_new-0x4
     4df:	test   rax,rax
     4e2:	jne    51f <botlish_fn_0+0x51f>
     4e8:	xor    rax,rax
     4eb:	mov    rbx,QWORD PTR [rsp+0x180]
     4f3:	mov    r12,QWORD PTR [rsp+0x188]
     4fb:	mov    r13,QWORD PTR [rsp+0x190]
     503:	mov    r14,QWORD PTR [rsp+0x198]
     50b:	mov    r15,QWORD PTR [rsp+0x1a0]
     513:	add    rsp,0x1b0
     51a:	mov    rsp,rbp
     51d:	pop    rbp
     51e:	ret
     51f:	mov    rbx,QWORD PTR [rsp+0x180]
     527:	mov    r12,QWORD PTR [rsp+0x188]
     52f:	mov    r13,QWORD PTR [rsp+0x190]
     537:	mov    r14,QWORD PTR [rsp+0x198]
     53f:	mov    r15,QWORD PTR [rsp+0x1a0]
     547:	add    rsp,0x1b0
     54e:	mov    rsp,rbp
     551:	pop    rbp
     552:	ret

0000000000000553 <botlish_entry_0: <program entry>>:
     553:	push   rbp
     554:	mov    rbp,rsp
     557:	call   55c <botlish_entry_0+0x9>
			558: R_X86_64_PLT32	botlish_fn_0-0x4 ; <program entry>
     55c:	mov    rsp,rbp
     55f:	pop    rbp
     560:	ret
     561:	add    BYTE PTR [rax],al
     563:	add    BYTE PTR [rax],al
     565:	add    BYTE PTR [rax],al
	...

0000000000000568 <botlish_fn_1: byte::from_int<int>>:
     568:	push   rbp
     569:	mov    rbp,rsp
     56c:	sub    rsp,0x10
     570:	mov    QWORD PTR [rsp],rbx
     574:	mov    QWORD PTR [rsp+0x8],r12
     579:	mov    r12,rdi
     57c:	test   rsi,0x1
     583:	mov    rax,rsi
     586:	jne    5b5 <botlish_fn_1+0x4d>
     58c:	mov    edx,0x1ff
     591:	mov    rbx,rax
     594:	mov    rsi,rbx
     597:	mov    rdi,r12
     59a:	call   59f <botlish_fn_1+0x37>
			59b: R_X86_64_PLT32	rt_int_cmp-0x4
     59f:	mov    r8d,0x2
     5a5:	test   rax,rax
     5a8:	cmovg  r8,QWORD PTR [rip+0x70]        # 620 <botlish_fn_1+0xb8>
     5b0:	jmp    5cd <botlish_fn_1+0x65>
     5b5:	mov    rbx,rax
     5b8:	mov    r8d,0x2
     5be:	cmp    rbx,0x1ff
     5c5:	cmovg  r8,QWORD PTR [rip+0x53]        # 620 <botlish_fn_1+0xb8>
     5cd:	cmp    r8,0x6
     5d1:	je     5ec <botlish_fn_1+0x84>
     5d7:	mov    rax,rbx
     5da:	mov    rbx,QWORD PTR [rsp]
     5de:	mov    r12,QWORD PTR [rsp+0x8]
     5e3:	add    rsp,0x10
     5e7:	mov    rsp,rbp
     5ea:	pop    rbp
     5eb:	ret
     5ec:	mov    rdi,r12
     5ef:	mov    rax,QWORD PTR [rdi+0x10]
     5f3:	mov    rdx,QWORD PTR [rax+0xb8]
     5fa:	mov    esi,0x2
     5ff:	call   604 <botlish_fn_1+0x9c>
			600: R_X86_64_PLT32	rt_fail_declared-0x4
     604:	xor    rax,rax
     607:	mov    rbx,QWORD PTR [rsp]
     60b:	mov    r12,QWORD PTR [rsp+0x8]
     610:	add    rsp,0x10
     614:	mov    rsp,rbp
     617:	pop    rbp
     618:	ret
     619:	add    BYTE PTR [rax],al
     61b:	add    BYTE PTR [rax],al
     61d:	add    BYTE PTR [rax],al
     61f:	add    BYTE PTR [rsi],al
     621:	add    BYTE PTR [rax],al
     623:	add    BYTE PTR [rax],al
     625:	add    BYTE PTR [rax],al
	...

0000000000000628 <botlish_entry_1: byte::from_int<int>>:
     628:	push   rbp
     629:	mov    rbp,rsp
     62c:	mov    rsi,QWORD PTR [rdx]
     62f:	call   634 <botlish_entry_1+0xc>
			630: R_X86_64_PLT32	botlish_fn_1-0x4 ; byte::from_int<int>
     634:	mov    rsp,rbp
     637:	pop    rbp
     638:	ret
     639:	add    BYTE PTR [rax],al
     63b:	add    BYTE PTR [rax],al
     63d:	add    BYTE PTR [rax],al
	...

0000000000000640 <botlish_fn_2: byte::set<List[UnicodeChar]>>:
     640:	push   rbp
     641:	mov    rbp,rsp
     644:	sub    rsp,0x90
     64b:	mov    QWORD PTR [rsp+0x60],rbx
     650:	mov    QWORD PTR [rsp+0x68],r12
     655:	mov    QWORD PTR [rsp+0x70],r13
     65a:	mov    QWORD PTR [rsp+0x78],r14
     65f:	mov    QWORD PTR [rsp+0x80],r15
     667:	mov    r13,rdi
     66a:	mov    QWORD PTR [rsp+0x18],0x0
     673:	mov    QWORD PTR [rsp+0x20],0x0
     67c:	mov    QWORD PTR [rsp],rsi
     680:	mov    rbx,rsi
     683:	mov    rdi,r13
     686:	call   68b <botlish_fn_2+0x4b>
			687: R_X86_64_PLT32	rt_list_len-0x4
     68b:	mov    QWORD PTR [rsp+0x8],rax
     690:	mov    r12,rax
     693:	mov    QWORD PTR [rsp+0x10],0x1
     69c:	xor    rdx,rdx
     69f:	mov    rdi,r13
     6a2:	mov    rsi,rdx
     6a5:	call   6aa <botlish_fn_2+0x6a>
			6a6: R_X86_64_PLT32	rt_list_new-0x4
     6aa:	test   rax,rax
     6ad:	je     841 <botlish_fn_2+0x201>
     6b3:	mov    QWORD PTR [rsp+0x18],rax
     6b8:	mov    QWORD PTR [rsp+0x58],rax
     6bd:	mov    esi,0x1
     6c2:	mov    r14,rsi
     6c5:	mov    rax,rsi
     6c8:	and    rax,r12
     6cb:	mov    r14,rsi
     6ce:	test   rax,0x1
     6d4:	jne    6fd <botlish_fn_2+0xbd>
     6da:	mov    rdx,r12
     6dd:	mov    rsi,r14
     6e0:	mov    rdi,r13
     6e3:	call   6e8 <botlish_fn_2+0xa8>
			6e4: R_X86_64_PLT32	rt_int_cmp-0x4
     6e8:	mov    ecx,0x2
     6ed:	test   rax,rax
     6f0:	cmovl  rcx,QWORD PTR [rip+0x1e8]        # 8e0 <botlish_fn_2+0x2a0>
     6f8:	jmp    710 <botlish_fn_2+0xd0>
     6fd:	mov    ecx,0x2
     702:	mov    rsi,r14
     705:	cmp    rsi,r12
     708:	cmovl  rcx,QWORD PTR [rip+0x1d0]        # 8e0 <botlish_fn_2+0x2a0>
     710:	cmp    rcx,0x6
     714:	je     784 <botlish_fn_2+0x144>
     71a:	lea    rcx,[rsp+0x48]
     71f:	mov    QWORD PTR [rsp+0x48],0x0
     728:	mov    rax,QWORD PTR [rsp+0x58]
     72d:	mov    QWORD PTR [rsp+0x50],rax
     732:	mov    esi,0x1
     737:	mov    edx,0x2
     73c:	mov    rdi,r13
     73f:	call   744 <botlish_fn_2+0x104>
			740: R_X86_64_PLT32	rt_construct-0x4
     744:	test   rax,rax
     747:	je     841 <botlish_fn_2+0x201>
     74d:	mov    QWORD PTR [rsp],rax
     751:	mov    rsi,rax
     754:	mov    rdi,r13
     757:	call   75c <botlish_fn_2+0x11c>
			758: R_X86_64_PLT32	rt_set_from_list-0x4
     75c:	mov    rbx,QWORD PTR [rsp+0x60]
     761:	mov    r12,QWORD PTR [rsp+0x68]
     766:	mov    r13,QWORD PTR [rsp+0x70]
     76b:	mov    r14,QWORD PTR [rsp+0x78]
     770:	mov    r15,QWORD PTR [rsp+0x80]
     778:	add    rsp,0x90
     77f:	mov    rsp,rbp
     782:	pop    rbp
     783:	ret
     784:	mov    rsi,r14
     787:	test   rsi,0x1
     78e:	je     7aa <botlish_fn_2+0x16a>
     794:	mov    r9,QWORD PTR [rbx+0x8]
     798:	mov    rsi,r14
     79b:	mov    r8,rsi
     79e:	sar    r8,1
     7a1:	cmp    r8,r9
     7a4:	jb     7c9 <botlish_fn_2+0x189>
     7aa:	mov    rdx,r14
     7ad:	mov    rsi,rbx
     7b0:	mov    rdi,r13
     7b3:	call   7b8 <botlish_fn_2+0x178>
			7b4: R_X86_64_PLT32	rt_list_get-0x4
     7b8:	test   rax,rax
     7bb:	je     841 <botlish_fn_2+0x201>
     7c1:	mov    rsi,rax
     7c4:	jmp    7d1 <botlish_fn_2+0x191>
     7c9:	mov    rax,QWORD PTR [rbx+0x10]
     7cd:	mov    rsi,QWORD PTR [rax+r8*8]
     7d1:	mov    edx,0x3
     7d6:	mov    r15,rdx
     7d9:	shr    rsi,0x3
     7dd:	shl    rsi,1
     7e0:	or     rsi,0x1
     7e4:	mov    rdi,r13
     7e7:	call   7ec <botlish_fn_2+0x1ac>
			7e8: R_X86_64_PLT32	botlish_fn_1-0x4 ; byte::from_int<int>
     7ec:	test   rax,rax
     7ef:	je     841 <botlish_fn_2+0x201>
     7f5:	mov    QWORD PTR [rsp+0x20],rax
     7fa:	lea    rcx,[rsp+0x28]
     7ff:	mov    QWORD PTR [rsp+0x28],0x0
     808:	mov    r10,QWORD PTR [rsp+0x58]
     80d:	mov    QWORD PTR [rsp+0x30],r10
     812:	mov    QWORD PTR [rsp+0x38],0x2
     81b:	mov    QWORD PTR [rsp+0x40],rax
     820:	mov    edx,0x4
     825:	mov    rsi,r15
     828:	mov    rdi,r13
     82b:	call   830 <botlish_fn_2+0x1f0>
			82c: R_X86_64_PLT32	rt_construct-0x4
     830:	mov    rcx,rax
     833:	mov    QWORD PTR [rsp+0x58],rax
     838:	test   rax,rcx
     83b:	jne    86c <botlish_fn_2+0x22c>
     841:	xor    rax,rax
     844:	mov    rbx,QWORD PTR [rsp+0x60]
     849:	mov    r12,QWORD PTR [rsp+0x68]
     84e:	mov    r13,QWORD PTR [rsp+0x70]
     853:	mov    r14,QWORD PTR [rsp+0x78]
     858:	mov    r15,QWORD PTR [rsp+0x80]
     860:	add    rsp,0x90
     867:	mov    rsp,rbp
     86a:	pop    rbp
     86b:	ret
     86c:	mov    rax,QWORD PTR [rsp+0x58]
     871:	mov    QWORD PTR [rsp+0x18],rax
     876:	mov    QWORD PTR [rsp+0x20],0x3
     87f:	mov    rsi,r14
     882:	test   rsi,0x1
     889:	jne    89a <botlish_fn_2+0x25a>
     88f:	mov    rdx,r15
     892:	mov    rsi,r14
     895:	jmp    8c5 <botlish_fn_2+0x285>
     89a:	mov    rsi,r14
     89d:	mov    rax,rsi
     8a0:	add    rax,0x2
     8a4:	seto   cl
     8a7:	test   cl,cl
     8a9:	je     8ba <botlish_fn_2+0x27a>
     8af:	mov    rdx,r15
     8b2:	mov    rsi,r14
     8b5:	jmp    8c5 <botlish_fn_2+0x285>
     8ba:	mov    rsi,rax
     8bd:	mov    r14,rax
     8c0:	jmp    8d3 <botlish_fn_2+0x293>
     8c5:	mov    rdi,r13
     8c8:	call   8cd <botlish_fn_2+0x28d>
			8c9: R_X86_64_PLT32	rt_int_add-0x4
     8cd:	mov    rsi,rax
     8d0:	mov    r14,rax
     8d3:	mov    QWORD PTR [rsp+0x10],rsi
     8d8:	mov    rsi,r14
     8db:	jmp    6c5 <botlish_fn_2+0x85>
     8e0:	(bad)
     8e1:	add    BYTE PTR [rax],al
     8e3:	add    BYTE PTR [rax],al
     8e5:	add    BYTE PTR [rax],al
	...

00000000000008e8 <botlish_entry_2: byte::set<List[UnicodeChar]>>:
     8e8:	push   rbp
     8e9:	mov    rbp,rsp
     8ec:	mov    rsi,QWORD PTR [rdx]
     8ef:	call   8f4 <botlish_entry_2+0xc>
			8f0: R_X86_64_PLT32	botlish_fn_2-0x4 ; byte::set<List[UnicodeChar]>
     8f4:	mov    rsp,rbp
     8f7:	pop    rbp
     8f8:	ret

00000000000008f9 <botlish_fn_3: ascii::is_digit<int>>:
     8f9:	push   rbp
     8fa:	mov    rbp,rsp
     8fd:	cmp    rsi,0x30
     901:	jge    911 <botlish_fn_3+0x18>
     907:	mov    eax,0x2
     90c:	jmp    92a <botlish_fn_3+0x31>
     911:	cmp    rsi,0x39
     915:	jle    925 <botlish_fn_3+0x2c>
     91b:	mov    eax,0x2
     920:	jmp    92a <botlish_fn_3+0x31>
     925:	mov    eax,0x6
     92a:	mov    rsp,rbp
     92d:	pop    rbp
     92e:	ret

000000000000092f <botlish_entry_3: ascii::is_digit<int>>:
     92f:	push   rbp
     930:	mov    rbp,rsp
     933:	mov    rsi,QWORD PTR [rdx]
     936:	sar    rsi,1
     939:	call   93e <botlish_entry_3+0xf>
			93a: R_X86_64_PLT32	botlish_fn_3-0x4 ; ascii::is_digit<int>
     93e:	mov    rsp,rbp
     941:	pop    rbp
     942:	ret

0000000000000943 <botlish_fn_4: ascii::is_upper<int>>:
     943:	push   rbp
     944:	mov    rbp,rsp
     947:	cmp    rsi,0x41
     94b:	jge    95b <botlish_fn_4+0x18>
     951:	mov    eax,0x2
     956:	jmp    974 <botlish_fn_4+0x31>
     95b:	cmp    rsi,0x5a
     95f:	jle    96f <botlish_fn_4+0x2c>
     965:	mov    eax,0x2
     96a:	jmp    974 <botlish_fn_4+0x31>
     96f:	mov    eax,0x6
     974:	mov    rsp,rbp
     977:	pop    rbp
     978:	ret

0000000000000979 <botlish_entry_4: ascii::is_upper<int>>:
     979:	push   rbp
     97a:	mov    rbp,rsp
     97d:	mov    rsi,QWORD PTR [rdx]
     980:	sar    rsi,1
     983:	call   988 <botlish_entry_4+0xf>
			984: R_X86_64_PLT32	botlish_fn_4-0x4 ; ascii::is_upper<int>
     988:	mov    rsp,rbp
     98b:	pop    rbp
     98c:	ret

000000000000098d <botlish_fn_5: ascii::is_lower<int>>:
     98d:	push   rbp
     98e:	mov    rbp,rsp
     991:	cmp    rsi,0x61
     995:	jge    9a5 <botlish_fn_5+0x18>
     99b:	mov    eax,0x2
     9a0:	jmp    9be <botlish_fn_5+0x31>
     9a5:	cmp    rsi,0x7a
     9a9:	jle    9b9 <botlish_fn_5+0x2c>
     9af:	mov    eax,0x2
     9b4:	jmp    9be <botlish_fn_5+0x31>
     9b9:	mov    eax,0x6
     9be:	mov    rsp,rbp
     9c1:	pop    rbp
     9c2:	ret

00000000000009c3 <botlish_entry_5: ascii::is_lower<int>>:
     9c3:	push   rbp
     9c4:	mov    rbp,rsp
     9c7:	mov    rsi,QWORD PTR [rdx]
     9ca:	sar    rsi,1
     9cd:	call   9d2 <botlish_entry_5+0xf>
			9ce: R_X86_64_PLT32	botlish_fn_5-0x4 ; ascii::is_lower<int>
     9d2:	mov    rsp,rbp
     9d5:	pop    rbp
     9d6:	ret

00000000000009d7 <botlish_fn_6: ascii::is_alphabetic<int>>:
     9d7:	push   rbp
     9d8:	mov    rbp,rsp
     9db:	sub    rsp,0x10
     9df:	mov    QWORD PTR [rsp],r12
     9e3:	mov    QWORD PTR [rsp+0x8],r14
     9e8:	mov    r12,rsi
     9eb:	mov    r14,rdi
     9ee:	mov    rsi,r12
     9f1:	mov    rdi,r14
     9f4:	call   9f9 <botlish_fn_6+0x22>
			9f5: R_X86_64_PLT32	botlish_fn_4-0x4 ; ascii::is_upper<int>
     9f9:	cmp    rax,0x6
     9fd:	je     a2c <botlish_fn_6+0x55>
     a03:	mov    rsi,r12
     a06:	mov    rdi,r14
     a09:	call   a0e <botlish_fn_6+0x37>
			a0a: R_X86_64_PLT32	botlish_fn_5-0x4 ; ascii::is_lower<int>
     a0e:	cmp    rax,0x6
     a12:	je     a22 <botlish_fn_6+0x4b>
     a18:	mov    eax,0x2
     a1d:	jmp    a31 <botlish_fn_6+0x5a>
     a22:	mov    eax,0x6
     a27:	jmp    a31 <botlish_fn_6+0x5a>
     a2c:	mov    eax,0x6
     a31:	mov    r12,QWORD PTR [rsp]
     a35:	mov    r14,QWORD PTR [rsp+0x8]
     a3a:	add    rsp,0x10
     a3e:	mov    rsp,rbp
     a41:	pop    rbp
     a42:	ret

0000000000000a43 <botlish_entry_6: ascii::is_alphabetic<int>>:
     a43:	push   rbp
     a44:	mov    rbp,rsp
     a47:	mov    rsi,QWORD PTR [rdx]
     a4a:	sar    rsi,1
     a4d:	call   a52 <botlish_entry_6+0xf>
			a4e: R_X86_64_PLT32	botlish_fn_6-0x4 ; ascii::is_alphabetic<int>
     a52:	mov    rsp,rbp
     a55:	pop    rbp
     a56:	ret

0000000000000a57 <botlish_fn_7: ascii::is_alphanumeric<int>>:
     a57:	push   rbp
     a58:	mov    rbp,rsp
     a5b:	sub    rsp,0x10
     a5f:	mov    QWORD PTR [rsp],r12
     a63:	mov    QWORD PTR [rsp+0x8],r14
     a68:	mov    r12,rsi
     a6b:	mov    r14,rdi
     a6e:	mov    rsi,r12
     a71:	mov    rdi,r14
     a74:	call   a79 <botlish_fn_7+0x22>
			a75: R_X86_64_PLT32	botlish_fn_6-0x4 ; ascii::is_alphabetic<int>
     a79:	cmp    rax,0x6
     a7d:	je     aac <botlish_fn_7+0x55>
     a83:	mov    rsi,r12
     a86:	mov    rdi,r14
     a89:	call   a8e <botlish_fn_7+0x37>
			a8a: R_X86_64_PLT32	botlish_fn_3-0x4 ; ascii::is_digit<int>
     a8e:	cmp    rax,0x6
     a92:	je     aa2 <botlish_fn_7+0x4b>
     a98:	mov    eax,0x2
     a9d:	jmp    ab1 <botlish_fn_7+0x5a>
     aa2:	mov    eax,0x6
     aa7:	jmp    ab1 <botlish_fn_7+0x5a>
     aac:	mov    eax,0x6
     ab1:	mov    r12,QWORD PTR [rsp]
     ab5:	mov    r14,QWORD PTR [rsp+0x8]
     aba:	add    rsp,0x10
     abe:	mov    rsp,rbp
     ac1:	pop    rbp
     ac2:	ret

0000000000000ac3 <botlish_entry_7: ascii::is_alphanumeric<int>>:
     ac3:	push   rbp
     ac4:	mov    rbp,rsp
     ac7:	mov    rsi,QWORD PTR [rdx]
     aca:	sar    rsi,1
     acd:	call   ad2 <botlish_entry_7+0xf>
			ace: R_X86_64_PLT32	botlish_fn_7-0x4 ; ascii::is_alphanumeric<int>
     ad2:	mov    rsp,rbp
     ad5:	pop    rbp
     ad6:	ret

0000000000000ad7 <botlish_fn_8: web::emailish?<str>>:
     ad7:	push   rbp
     ad8:	mov    rbp,rsp
     adb:	sub    rsp,0x40
     adf:	mov    QWORD PTR [rsp+0x20],rbx
     ae4:	mov    QWORD PTR [rsp+0x28],r12
     ae9:	mov    QWORD PTR [rsp+0x30],r13
     aee:	mov    QWORD PTR [rsp+0x38],r14
     af3:	mov    r12,rsi
     af6:	mov    QWORD PTR [rsp],rsi
     afa:	mov    rsi,r12
     afd:	mov    rdx,QWORD PTR [rsi+0x8]
     b01:	shl    rdx,1
     b04:	mov    rcx,rdx
     b07:	or     rcx,0x1
     b0b:	mov    r14,rdx
     b0e:	mov    QWORD PTR [rsp+0x8],rcx
     b13:	mov    rax,QWORD PTR [rdi+0x10]
     b17:	mov    r13,rdi
     b1a:	mov    rdx,QWORD PTR [rax+0xc0]
     b21:	mov    QWORD PTR [rsp+0x10],rdx
     b26:	xor    rsi,rsi
     b29:	mov    r8,r12
     b2c:	call   b31 <botlish_fn_8+0x5a>
			b2d: R_X86_64_PLT32	botlish_fn_14-0x4 ; scan_while<int, block(e276)>
     b31:	test   rax,rax
     b34:	je     bd9 <botlish_fn_8+0x102>
     b3a:	mov    rbx,rax
     b3d:	sar    rbx,1
     b40:	mov    rdi,rax
     b43:	test   rbx,rbx
     b46:	jle    b98 <botlish_fn_8+0xc1>
     b4c:	mov    rsi,r14
     b4f:	mov    rax,rsi
     b52:	or     rax,0x1
     b56:	sar    rax,1
     b59:	cmp    rbx,rax
     b5c:	jl     b6c <botlish_fn_8+0x95>
     b62:	mov    eax,0xa
     b67:	jmp    b98 <botlish_fn_8+0xc1>
     b6c:	mov    edx,0x204
     b71:	mov    rcx,rsi
     b74:	or     rcx,0x1
     b78:	mov    r14,rsi
     b7b:	mov    rsi,rdi
     b7e:	mov    rdi,r13
     b81:	mov    r8,r12
     b84:	call   b89 <botlish_fn_8+0xb2>
			b85: R_X86_64_PLT32	botlish_fn_11-0x4 ; char_is?<int, any>
     b89:	cmp    rax,0x6
     b8d:	je     bba <botlish_fn_8+0xe3>
     b93:	mov    eax,0xa
     b98:	mov    eax,0x2
     b9d:	mov    rbx,QWORD PTR [rsp+0x20]
     ba2:	mov    r12,QWORD PTR [rsp+0x28]
     ba7:	mov    r13,QWORD PTR [rsp+0x30]
     bac:	mov    r14,QWORD PTR [rsp+0x38]
     bb1:	add    rsp,0x40
     bb5:	mov    rsp,rbp
     bb8:	pop    rbp
     bb9:	ret
     bba:	lea    rsi,[rbx+0x1]
     bbe:	mov    rdx,r14
     bc1:	or     rdx,0x1
     bc5:	mov    rcx,r12
     bc8:	mov    rdi,r13
     bcb:	call   bd0 <botlish_fn_8+0xf9>
			bcc: R_X86_64_PLT32	botlish_fn_17-0x4 ; domain?<int>
     bd0:	test   rax,rax
     bd3:	jne    bf9 <botlish_fn_8+0x122>
     bd9:	xor    rax,rax
     bdc:	mov    rbx,QWORD PTR [rsp+0x20]
     be1:	mov    r12,QWORD PTR [rsp+0x28]
     be6:	mov    r13,QWORD PTR [rsp+0x30]
     beb:	mov    r14,QWORD PTR [rsp+0x38]
     bf0:	add    rsp,0x40
     bf4:	mov    rsp,rbp
     bf7:	pop    rbp
     bf8:	ret
     bf9:	mov    rbx,QWORD PTR [rsp+0x20]
     bfe:	mov    r12,QWORD PTR [rsp+0x28]
     c03:	mov    r13,QWORD PTR [rsp+0x30]
     c08:	mov    r14,QWORD PTR [rsp+0x38]
     c0d:	add    rsp,0x40
     c11:	mov    rsp,rbp
     c14:	pop    rbp
     c15:	ret

0000000000000c16 <botlish_entry_8: web::emailish?<str>>:
     c16:	push   rbp
     c17:	mov    rbp,rsp
     c1a:	mov    rsi,QWORD PTR [rdx]
     c1d:	call   c22 <botlish_entry_8+0xc>
			c1e: R_X86_64_PLT32	botlish_fn_8-0x4 ; web::emailish?<str>
     c22:	mov    rsp,rbp
     c25:	pop    rbp
     c26:	ret

0000000000000c27 <botlish_fn_9: char_at<int>>:
     c27:	push   rbp
     c28:	mov    rbp,rsp
     c2b:	sub    rsp,0x20
     c2f:	mov    QWORD PTR [rsp],rsi
     c33:	mov    QWORD PTR [rsp+0x8],rcx
     c38:	mov    r8,rcx
     c3b:	mov    rax,rsi
     c3e:	sar    rax,1
     c41:	sar    rdx,1
     c44:	cmp    rax,rdx
     c47:	jge    c57 <botlish_fn_9+0x30>
     c4d:	mov    ecx,0x2
     c52:	jmp    c5c <botlish_fn_9+0x35>
     c57:	mov    ecx,0x6
     c5c:	cmp    rcx,0x6
     c60:	je     c8a <botlish_fn_9+0x63>
     c66:	lea    rcx,[rax+0x1]
     c6a:	shl    rcx,1
     c6d:	or     rcx,0x1
     c71:	mov    QWORD PTR [rsp+0x10],rcx
     c76:	mov    rdx,rsi
     c79:	mov    rsi,r8
     c7c:	call   c81 <botlish_fn_9+0x5a>
			c7d: R_X86_64_PLT32	rt_substr_proven-0x4
     c81:	add    rsp,0x20
     c85:	mov    rsp,rbp
     c88:	pop    rbp
     c89:	ret
     c8a:	mov    rax,QWORD PTR [rdi+0x10]
     c8e:	mov    rax,QWORD PTR [rax+0xc8]
     c95:	add    rsp,0x20
     c99:	mov    rsp,rbp
     c9c:	pop    rbp
     c9d:	ret

0000000000000c9e <botlish_entry_9: char_at<int>>:
     c9e:	push   rbp
     c9f:	mov    rbp,rsp
     ca2:	mov    rsi,QWORD PTR [rdx]
     ca5:	mov    r8,QWORD PTR [rdx+0x8]
     ca9:	mov    rcx,QWORD PTR [rdx+0x10]
     cad:	mov    rdx,r8
     cb0:	call   cb5 <botlish_entry_9+0x17>
			cb1: R_X86_64_PLT32	botlish_fn_9-0x4 ; char_at<int>
     cb5:	mov    rsp,rbp
     cb8:	pop    rbp
     cb9:	ret

0000000000000cba <botlish_fn_10: char_at<int>>:
     cba:	push   rbp
     cbb:	mov    rbp,rsp
     cbe:	mov    rax,rsi
     cc1:	sar    rax,1
     cc4:	sar    rdx,1
     cc7:	cmp    rax,rdx
     cca:	jge    cdb <botlish_fn_10+0x21>
     cd0:	mov    r11d,0x2
     cd6:	jmp    ce1 <botlish_fn_10+0x27>
     cdb:	mov    r11d,0x6
     ce1:	cmp    r11,0x6
     ce5:	je     d08 <botlish_fn_10+0x4e>
     ceb:	mov    QWORD PTR [r8],rsi
     cee:	add    rax,0x1
     cf5:	shl    rax,1
     cf8:	or     rax,0x1
     cfc:	mov    QWORD PTR [r8+0x8],rax
     d00:	mov    rax,rcx
     d03:	mov    rsp,rbp
     d06:	pop    rbp
     d07:	ret
     d08:	mov    rax,QWORD PTR [rdi+0x10]
     d0c:	mov    rax,QWORD PTR [rax+0xc8]
     d13:	mov    QWORD PTR [r8],0x1
     d1a:	mov    QWORD PTR [r8+0x8],0x1
     d22:	mov    rsp,rbp
     d25:	pop    rbp
     d26:	ret

0000000000000d27 <botlish_entry_10: char_at<int>>:
     d27:	push   rbp
     d28:	mov    rbp,rsp
     d2b:	ud2
     d2d:	add    BYTE PTR [rax],al
	...

0000000000000d30 <botlish_fn_11: char_is?<int, any>>:
     d30:	push   rbp
     d31:	mov    rbp,rsp
     d34:	sub    rsp,0x10
     d38:	mov    QWORD PTR [rsp],rbx
     d3c:	mov    rbx,rdx
     d3f:	mov    rax,rsi
     d42:	sar    rax,1
     d45:	sar    rcx,1
     d48:	cmp    rax,rcx
     d4b:	jge    d5c <botlish_fn_11+0x2c>
     d51:	mov    r11d,0x2
     d57:	jmp    d62 <botlish_fn_11+0x32>
     d5c:	mov    r11d,0x6
     d62:	cmp    r11,0x6
     d66:	je     dc7 <botlish_fn_11+0x97>
     d6c:	movzx  rcx,BYTE PTR [r8+0x18]
     d71:	mov    rdx,r8
     d74:	test   rcx,rcx
     d77:	jne    d93 <botlish_fn_11+0x63>
     d7d:	mov    rax,rdx
     d80:	mov    rdx,rsi
     d83:	mov    rsi,rax
     d86:	call   d8b <botlish_fn_11+0x5b>
			d87: R_X86_64_PLT32	rt_str_char_at_proven-0x4
     d8b:	mov    rcx,rax
     d8e:	jmp    da7 <botlish_fn_11+0x77>
     d93:	mov    rsi,rdx
     d96:	movzx  rax,BYTE PTR [rsi+rax*1+0x19]
     d9c:	shl    rax,0x3
     da0:	or     rax,0x4
     da4:	mov    rcx,rax
     da7:	mov    eax,0x2
     dac:	mov    rdx,rbx
     daf:	cmp    rcx,rdx
     db2:	cmove  rax,QWORD PTR [rip+0x26]        # de0 <botlish_fn_11+0xb0>
     dba:	mov    rbx,QWORD PTR [rsp]
     dbe:	add    rsp,0x10
     dc2:	mov    rsp,rbp
     dc5:	pop    rbp
     dc6:	ret
     dc7:	mov    eax,0x2
     dcc:	mov    rbx,QWORD PTR [rsp]
     dd0:	add    rsp,0x10
     dd4:	mov    rsp,rbp
     dd7:	pop    rbp
     dd8:	ret
     dd9:	add    BYTE PTR [rax],al
     ddb:	add    BYTE PTR [rax],al
     ddd:	add    BYTE PTR [rax],al
     ddf:	add    BYTE PTR [rsi],al
     de1:	add    BYTE PTR [rax],al
     de3:	add    BYTE PTR [rax],al
     de5:	add    BYTE PTR [rax],al
	...

0000000000000de8 <botlish_entry_11: char_is?<int, any>>:
     de8:	push   rbp
     de9:	mov    rbp,rsp
     dec:	mov    rsi,QWORD PTR [rdx]
     def:	mov    r9,QWORD PTR [rdx+0x8]
     df3:	mov    rcx,QWORD PTR [rdx+0x10]
     df7:	mov    r8,QWORD PTR [rdx+0x18]
     dfb:	mov    rdx,r9
     dfe:	call   e03 <botlish_entry_11+0x1b>
			dff: R_X86_64_PLT32	botlish_fn_11-0x4 ; char_is?<int, any>
     e03:	mov    rsp,rbp
     e06:	pop    rbp
     e07:	ret

0000000000000e08 <botlish_fn_12: local_char?<str>>:
     e08:	push   rbp
     e09:	mov    rbp,rsp
     e0c:	sub    rsp,0x10
     e10:	mov    QWORD PTR [rsp],rbx
     e14:	mov    QWORD PTR [rsp+0x8],r14
     e19:	mov    rbx,rdi
     e1c:	mov    r14,rsi
     e1f:	mov    rsi,r14
     e22:	mov    rdi,rbx
     e25:	call   e2a <botlish_fn_12+0x22>
			e26: R_X86_64_PLT32	rt_is_tcl_alnum-0x4
     e2a:	test   rax,rax
     e2d:	jne    e48 <botlish_fn_12+0x40>
     e33:	xor    rax,rax
     e36:	mov    rbx,QWORD PTR [rsp]
     e3a:	mov    r14,QWORD PTR [rsp+0x8]
     e3f:	add    rsp,0x10
     e43:	mov    rsp,rbp
     e46:	pop    rbp
     e47:	ret
     e48:	cmp    rax,0x6
     e4c:	je     e82 <botlish_fn_12+0x7a>
     e52:	mov    rdi,rbx
     e55:	mov    rax,QWORD PTR [rdi+0x30]
     e59:	mov    rsi,QWORD PTR [rax]
     e5c:	mov    rdx,r14
     e5f:	call   e64 <botlish_fn_12+0x5c>
			e60: R_X86_64_PLT32	rt_set_contains-0x4
     e64:	cmp    rax,0x6
     e68:	je     e78 <botlish_fn_12+0x70>
     e6e:	mov    eax,0x2
     e73:	jmp    e87 <botlish_fn_12+0x7f>
     e78:	mov    eax,0x6
     e7d:	jmp    e87 <botlish_fn_12+0x7f>
     e82:	mov    eax,0x6
     e87:	mov    rbx,QWORD PTR [rsp]
     e8b:	mov    r14,QWORD PTR [rsp+0x8]
     e90:	add    rsp,0x10
     e94:	mov    rsp,rbp
     e97:	pop    rbp
     e98:	ret

0000000000000e99 <botlish_entry_12: local_char?<str>>:
     e99:	push   rbp
     e9a:	mov    rbp,rsp
     e9d:	mov    rsi,QWORD PTR [rdx]
     ea0:	call   ea5 <botlish_entry_12+0xc>
			ea1: R_X86_64_PLT32	botlish_fn_12-0x4 ; local_char?<str>
     ea5:	mov    rsp,rbp
     ea8:	pop    rbp
     ea9:	ret

0000000000000eaa <botlish_fn_13: local_char?<generic>>:
     eaa:	push   rbp
     eab:	mov    rbp,rsp
     eae:	sub    rsp,0x10
     eb2:	mov    QWORD PTR [rsp],rbx
     eb6:	mov    QWORD PTR [rsp+0x8],r14
     ebb:	mov    rbx,rdi
     ebe:	mov    r14,rsi
     ec1:	mov    rsi,r14
     ec4:	mov    rdi,rbx
     ec7:	call   ecc <botlish_fn_13+0x22>
			ec8: R_X86_64_PLT32	rt_is_tcl_alnum-0x4
     ecc:	test   rax,rax
     ecf:	jne    eea <botlish_fn_13+0x40>
     ed5:	xor    rax,rax
     ed8:	mov    rbx,QWORD PTR [rsp]
     edc:	mov    r14,QWORD PTR [rsp+0x8]
     ee1:	add    rsp,0x10
     ee5:	mov    rsp,rbp
     ee8:	pop    rbp
     ee9:	ret
     eea:	cmp    rax,0x6
     eee:	je     f24 <botlish_fn_13+0x7a>
     ef4:	mov    rdi,rbx
     ef7:	mov    rax,QWORD PTR [rdi+0x30]
     efb:	mov    rsi,QWORD PTR [rax]
     efe:	mov    rdx,r14
     f01:	call   f06 <botlish_fn_13+0x5c>
			f02: R_X86_64_PLT32	rt_set_contains-0x4
     f06:	cmp    rax,0x6
     f0a:	je     f1a <botlish_fn_13+0x70>
     f10:	mov    eax,0x2
     f15:	jmp    f29 <botlish_fn_13+0x7f>
     f1a:	mov    eax,0x6
     f1f:	jmp    f29 <botlish_fn_13+0x7f>
     f24:	mov    eax,0x6
     f29:	mov    rbx,QWORD PTR [rsp]
     f2d:	mov    r14,QWORD PTR [rsp+0x8]
     f32:	add    rsp,0x10
     f36:	mov    rsp,rbp
     f39:	pop    rbp
     f3a:	ret

0000000000000f3b <botlish_entry_13: local_char?<generic>>:
     f3b:	push   rbp
     f3c:	mov    rbp,rsp
     f3f:	mov    rsi,QWORD PTR [rdx]
     f42:	call   f47 <botlish_entry_13+0xc>
			f43: R_X86_64_PLT32	botlish_fn_13-0x4 ; local_char?<generic>
     f47:	mov    rsp,rbp
     f4a:	pop    rbp
     f4b:	ret

0000000000000f4c <botlish_fn_14: scan_while<int, block(e276)>>:
     f4c:	push   rbp
     f4d:	mov    rbp,rsp
     f50:	sub    rsp,0x50
     f54:	mov    QWORD PTR [rsp+0x20],rbx
     f59:	mov    QWORD PTR [rsp+0x28],r12
     f5e:	mov    QWORD PTR [rsp+0x30],r13
     f63:	mov    QWORD PTR [rsp+0x38],r14
     f68:	mov    QWORD PTR [rsp+0x40],r15
     f6d:	mov    QWORD PTR [rsp+0x18],rdi
     f72:	mov    QWORD PTR [rsp],rcx
     f76:	mov    QWORD PTR [rsp+0x8],r8
     f7b:	mov    r15,r8
     f7e:	mov    r12,rcx
     f81:	sar    r12,1
     f84:	mov    r14,rcx
     f87:	mov    rbx,rsi
     f8a:	cmp    rbx,r12
     f8d:	jl     fb8 <botlish_fn_14+0x6c>
     f93:	mov    rax,r14
     f96:	mov    rbx,QWORD PTR [rsp+0x20]
     f9b:	mov    r12,QWORD PTR [rsp+0x28]
     fa0:	mov    r13,QWORD PTR [rsp+0x30]
     fa5:	mov    r14,QWORD PTR [rsp+0x38]
     faa:	mov    r15,QWORD PTR [rsp+0x40]
     faf:	add    rsp,0x50
     fb3:	mov    rsp,rbp
     fb6:	pop    rbp
     fb7:	ret
     fb8:	mov    r13,rbx
     fbb:	shl    r13,1
     fbe:	or     r13,0x1
     fc2:	mov    QWORD PTR [rsp+0x10],r13
     fc7:	mov    rcx,r15
     fca:	mov    rdx,r14
     fcd:	mov    rsi,r13
     fd0:	mov    rdi,QWORD PTR [rsp+0x18]
     fd5:	call   fda <botlish_fn_14+0x8e>
			fd6: R_X86_64_PLT32	botlish_fn_9-0x4 ; char_at<int>
     fda:	mov    rsi,rax
     fdd:	mov    rdi,QWORD PTR [rsp+0x18]
     fe2:	call   fe7 <botlish_fn_14+0x9b>
			fe3: R_X86_64_PLT32	botlish_fn_12-0x4 ; local_char?<str>
     fe7:	test   rax,rax
     fea:	jne    1015 <botlish_fn_14+0xc9>
     ff0:	xor    rax,rax
     ff3:	mov    rbx,QWORD PTR [rsp+0x20]
     ff8:	mov    r12,QWORD PTR [rsp+0x28]
     ffd:	mov    r13,QWORD PTR [rsp+0x30]
    1002:	mov    r14,QWORD PTR [rsp+0x38]
    1007:	mov    r15,QWORD PTR [rsp+0x40]
    100c:	add    rsp,0x50
    1010:	mov    rsp,rbp
    1013:	pop    rbp
    1014:	ret
    1015:	cmp    rax,0x6
    1019:	je     1044 <botlish_fn_14+0xf8>
    101f:	mov    rax,r13
    1022:	mov    rbx,QWORD PTR [rsp+0x20]
    1027:	mov    r12,QWORD PTR [rsp+0x28]
    102c:	mov    r13,QWORD PTR [rsp+0x30]
    1031:	mov    r14,QWORD PTR [rsp+0x38]
    1036:	mov    r15,QWORD PTR [rsp+0x40]
    103b:	add    rsp,0x50
    103f:	mov    rsp,rbp
    1042:	pop    rbp
    1043:	ret
    1044:	add    rbx,0x1
    104b:	jmp    f8a <botlish_fn_14+0x3e>

0000000000001050 <botlish_entry_14: scan_while<int, block(e276)>>:
    1050:	push   rbp
    1051:	mov    rbp,rsp
    1054:	mov    rsi,QWORD PTR [rdx]
    1057:	mov    r9,QWORD PTR [rdx+0x8]
    105b:	mov    rcx,QWORD PTR [rdx+0x10]
    105f:	mov    r8,QWORD PTR [rdx+0x18]
    1063:	sar    rsi,1
    1066:	mov    rdx,r9
    1069:	call   106e <botlish_entry_14+0x1e>
			106a: R_X86_64_PLT32	botlish_fn_14-0x4 ; scan_while<int, block(e276)>
    106e:	mov    rsp,rbp
    1071:	pop    rbp
    1072:	ret

0000000000001073 <botlish_fn_15: scan_while<int, native(str::is_tcl_alpha)>>:
    1073:	push   rbp
    1074:	mov    rbp,rsp
    1077:	sub    rsp,0x40
    107b:	mov    QWORD PTR [rsp+0x10],rbx
    1080:	mov    QWORD PTR [rsp+0x18],r12
    1085:	mov    QWORD PTR [rsp+0x20],r13
    108a:	mov    QWORD PTR [rsp+0x28],r14
    108f:	mov    QWORD PTR [rsp+0x30],r15
    1094:	mov    rbx,r8
    1097:	mov    r13,rdi
    109a:	mov    rax,rcx
    109d:	sar    rax,1
    10a0:	mov    r12,rcx
    10a3:	mov    r14,rax
    10a6:	mov    rax,rsi
    10a9:	mov    rcx,r14
    10ac:	cmp    rax,rcx
    10af:	mov    r14,rcx
    10b2:	jl     10e2 <botlish_fn_15+0x6f>
    10b8:	mov    edx,0x1
    10bd:	mov    rax,r14
    10c0:	mov    rbx,QWORD PTR [rsp+0x10]
    10c5:	mov    r12,QWORD PTR [rsp+0x18]
    10ca:	mov    r13,QWORD PTR [rsp+0x20]
    10cf:	mov    r14,QWORD PTR [rsp+0x28]
    10d4:	mov    r15,QWORD PTR [rsp+0x30]
    10d9:	add    rsp,0x40
    10dd:	mov    rsp,rbp
    10e0:	pop    rbp
    10e1:	ret
    10e2:	mov    rsi,rax
    10e5:	shl    rsi,1
    10e8:	mov    r15,rax
    10eb:	or     rsi,0x1
    10ef:	lea    r8,[rsp]
    10f3:	mov    rcx,rbx
    10f6:	mov    rdx,r12
    10f9:	mov    rdi,r13
    10fc:	call   1101 <botlish_fn_15+0x8e>
			10fd: R_X86_64_PLT32	botlish_fn_10-0x4 ; char_at<int>
    1101:	mov    rdx,QWORD PTR [rsp]
    1105:	mov    rcx,QWORD PTR [rsp+0x8]
    110a:	mov    rsi,rax
    110d:	mov    rdi,r13
    1110:	call   1115 <botlish_fn_15+0xa2>
			1111: R_X86_64_PLT32	rt_str_region_is_tcl_alpha-0x4
    1115:	test   rax,rax
    1118:	jne    1146 <botlish_fn_15+0xd3>
    111e:	xor    rdx,rdx
    1121:	mov    rax,rdx
    1124:	mov    rbx,QWORD PTR [rsp+0x10]
    1129:	mov    r12,QWORD PTR [rsp+0x18]
    112e:	mov    r13,QWORD PTR [rsp+0x20]
    1133:	mov    r14,QWORD PTR [rsp+0x28]
    1138:	mov    r15,QWORD PTR [rsp+0x30]
    113d:	add    rsp,0x40
    1141:	mov    rsp,rbp
    1144:	pop    rbp
    1145:	ret
    1146:	cmp    rax,0x6
    114a:	je     117a <botlish_fn_15+0x107>
    1150:	mov    edx,0x1
    1155:	mov    rax,r15
    1158:	mov    rbx,QWORD PTR [rsp+0x10]
    115d:	mov    r12,QWORD PTR [rsp+0x18]
    1162:	mov    r13,QWORD PTR [rsp+0x20]
    1167:	mov    r14,QWORD PTR [rsp+0x28]
    116c:	mov    r15,QWORD PTR [rsp+0x30]
    1171:	add    rsp,0x40
    1175:	mov    rsp,rbp
    1178:	pop    rbp
    1179:	ret
    117a:	mov    rax,r15
    117d:	add    rax,0x1
    1184:	mov    rcx,r14
    1187:	jmp    10ac <botlish_fn_15+0x39>

000000000000118c <botlish_entry_15: scan_while<int, native(str::is_tcl_alpha)>>:
    118c:	push   rbp
    118d:	mov    rbp,rsp
    1190:	mov    rsi,QWORD PTR [rdx]
    1193:	mov    rax,QWORD PTR [rdx+0x8]
    1197:	mov    rcx,QWORD PTR [rdx+0x10]
    119b:	mov    r8,QWORD PTR [rdx+0x18]
    119f:	sar    rsi,1
    11a2:	mov    rdx,rax
    11a5:	call   11aa <botlish_entry_15+0x1e>
			11a6: R_X86_64_PLT32	botlish_fn_15-0x4 ; scan_while<int, native(str::is_tcl_alpha)>
    11aa:	shl    rax,1
    11ad:	or     rax,0x1
    11b1:	mov    rcx,rax
    11b4:	xor    rax,rax
    11b7:	test   rdx,rdx
    11ba:	cmovne rax,rcx
    11be:	mov    rsp,rbp
    11c1:	pop    rbp
    11c2:	ret
    11c3:	add    BYTE PTR [rax],al
    11c5:	add    BYTE PTR [rax],al
	...

00000000000011c8 <botlish_fn_16: tld?<int>>:
    11c8:	push   rbp
    11c9:	mov    rbp,rsp
    11cc:	sub    rsp,0x10
    11d0:	mov    QWORD PTR [rsp],rbx
    11d4:	mov    QWORD PTR [rsp+0x8],r12
    11d9:	mov    r8,rdx
    11dc:	mov    rax,QWORD PTR [rdi+0x10]
    11e0:	mov    rdx,QWORD PTR [rax+0xd0]
    11e7:	mov    r12,r8
    11ea:	mov    r8,rcx
    11ed:	mov    rbx,rsi
    11f0:	mov    rcx,r12
    11f3:	call   11f8 <botlish_fn_16+0x30>
			11f4: R_X86_64_PLT32	botlish_fn_15-0x4 ; scan_while<int, native(str::is_tcl_alpha)>
    11f8:	test   rdx,rdx
    11fb:	jne    1216 <botlish_fn_16+0x4e>
    1201:	xor    rax,rax
    1204:	mov    rbx,QWORD PTR [rsp]
    1208:	mov    r12,QWORD PTR [rsp+0x8]
    120d:	add    rsp,0x10
    1211:	mov    rsp,rbp
    1214:	pop    rbp
    1215:	ret
    1216:	sar    r12,1
    1219:	cmp    rax,r12
    121c:	je     122c <botlish_fn_16+0x64>
    1222:	mov    eax,0x2
    1227:	jmp    1243 <botlish_fn_16+0x7b>
    122c:	sub    rax,rbx
    122f:	mov    rcx,rax
    1232:	mov    eax,0x2
    1237:	cmp    rcx,0x2
    123b:	cmovge rax,QWORD PTR [rip+0x15]        # 1258 <botlish_fn_16+0x90>
    1243:	mov    rbx,QWORD PTR [rsp]
    1247:	mov    r12,QWORD PTR [rsp+0x8]
    124c:	add    rsp,0x10
    1250:	mov    rsp,rbp
    1253:	pop    rbp
    1254:	ret
    1255:	add    BYTE PTR [rax],al
    1257:	add    BYTE PTR [rsi],al
    1259:	add    BYTE PTR [rax],al
    125b:	add    BYTE PTR [rax],al
    125d:	add    BYTE PTR [rax],al
	...

0000000000001260 <botlish_entry_16: tld?<int>>:
    1260:	push   rbp
    1261:	mov    rbp,rsp
    1264:	mov    rsi,QWORD PTR [rdx]
    1267:	mov    r8,QWORD PTR [rdx+0x8]
    126b:	mov    rcx,QWORD PTR [rdx+0x10]
    126f:	sar    rsi,1
    1272:	mov    rdx,r8
    1275:	call   127a <botlish_entry_16+0x1a>
			1276: R_X86_64_PLT32	botlish_fn_16-0x4 ; tld?<int>
    127a:	mov    rsp,rbp
    127d:	pop    rbp
    127e:	ret

000000000000127f <botlish_fn_17: domain?<int>>:
    127f:	push   rbp
    1280:	mov    rbp,rsp
    1283:	sub    rsp,0x60
    1287:	mov    QWORD PTR [rsp+0x30],rbx
    128c:	mov    QWORD PTR [rsp+0x38],r12
    1291:	mov    QWORD PTR [rsp+0x40],r13
    1296:	mov    QWORD PTR [rsp+0x48],r14
    129b:	mov    QWORD PTR [rsp+0x50],r15
    12a0:	mov    r13,rsi
    12a3:	mov    r15,rcx
    12a6:	mov    r14,rdx
    12a9:	sar    r14,1
    12ac:	mov    QWORD PTR [rsp+0x10],rdx
    12b1:	mov    r12,r13
    12b4:	cmp    r12,r14
    12b7:	jge    145f <botlish_fn_17+0x1e0>
    12bd:	mov    rsi,r12
    12c0:	shl    rsi,1
    12c3:	or     rsi,0x1
    12c7:	mov    QWORD PTR [rsp+0x28],rsi
    12cc:	mov    edx,0x174
    12d1:	mov    rbx,rdi
    12d4:	mov    rcx,QWORD PTR [rsp+0x10]
    12d9:	mov    r8,r15
    12dc:	call   12e1 <botlish_fn_17+0x62>
			12dd: R_X86_64_PLT32	botlish_fn_11-0x4 ; char_is?<int, any>
    12e1:	cmp    rax,0x6
    12e5:	je     13a6 <botlish_fn_17+0x127>
    12eb:	lea    r8,[rsp]
    12ef:	mov    rsi,QWORD PTR [rsp+0x28]
    12f4:	mov    rcx,r15
    12f7:	mov    rdx,QWORD PTR [rsp+0x10]
    12fc:	mov    rdi,rbx
    12ff:	call   1304 <botlish_fn_17+0x85>
			1300: R_X86_64_PLT32	botlish_fn_10-0x4 ; char_at<int>
    1304:	mov    QWORD PTR [rsp+0x28],rax
    1309:	mov    rdx,QWORD PTR [rsp]
    130d:	mov    QWORD PTR [rsp+0x20],rdx
    1312:	mov    rcx,QWORD PTR [rsp+0x8]
    1317:	mov    QWORD PTR [rsp+0x18],rcx
    131c:	mov    rsi,QWORD PTR [rsp+0x28]
    1321:	mov    rdi,rbx
    1324:	call   1329 <botlish_fn_17+0xaa>
			1325: R_X86_64_PLT32	rt_str_region_is_tcl_alnum-0x4
    1329:	test   rax,rax
    132c:	je     13fa <botlish_fn_17+0x17b>
    1332:	cmp    rax,0x6
    1336:	je     1379 <botlish_fn_17+0xfa>
    133c:	mov    rax,QWORD PTR [rbx+0x10]
    1340:	mov    r8,QWORD PTR [rax+0x20]
    1344:	mov    rcx,QWORD PTR [rsp+0x18]
    1349:	mov    rdx,QWORD PTR [rsp+0x20]
    134e:	mov    rsi,QWORD PTR [rsp+0x28]
    1353:	mov    rdi,rbx
    1356:	call   135b <botlish_fn_17+0xdc>
			1357: R_X86_64_PLT32	rt_str_region_eq-0x4
    135b:	cmp    rax,0x6
    135f:	je     136f <botlish_fn_17+0xf0>
    1365:	mov    ecx,0x2
    136a:	jmp    137e <botlish_fn_17+0xff>
    136f:	mov    ecx,0x6
    1374:	jmp    137e <botlish_fn_17+0xff>
    1379:	mov    ecx,0x6
    137e:	cmp    rcx,0x6
    1382:	je     1392 <botlish_fn_17+0x113>
    1388:	mov    eax,0x6
    138d:	jmp    1397 <botlish_fn_17+0x118>
    1392:	mov    eax,0x2
    1397:	cmp    rax,0x6
    139b:	jne    1429 <botlish_fn_17+0x1aa>
    13a1:	jmp    145f <botlish_fn_17+0x1e0>
    13a6:	cmp    r12,r13
    13a9:	je     145f <botlish_fn_17+0x1e0>
    13af:	mov    rsi,r12
    13b2:	sub    rsi,0x1
    13b6:	shl    rsi,1
    13b9:	or     rsi,0x1
    13bd:	mov    edx,0x174
    13c2:	mov    rcx,QWORD PTR [rsp+0x10]
    13c7:	mov    rdi,rbx
    13ca:	mov    r8,r15
    13cd:	call   13d2 <botlish_fn_17+0x153>
			13ce: R_X86_64_PLT32	botlish_fn_11-0x4 ; char_is?<int, any>
    13d2:	cmp    rax,0x6
    13d6:	je     145f <botlish_fn_17+0x1e0>
    13dc:	lea    rsi,[r12+0x1]
    13e1:	mov    rcx,r15
    13e4:	mov    rdx,QWORD PTR [rsp+0x10]
    13e9:	mov    rdi,rbx
    13ec:	call   13f1 <botlish_fn_17+0x172>
			13ed: R_X86_64_PLT32	botlish_fn_16-0x4 ; tld?<int>
    13f1:	test   rax,rax
    13f4:	jne    141f <botlish_fn_17+0x1a0>
    13fa:	xor    rax,rax
    13fd:	mov    rbx,QWORD PTR [rsp+0x30]
    1402:	mov    r12,QWORD PTR [rsp+0x38]
    1407:	mov    r13,QWORD PTR [rsp+0x40]
    140c:	mov    r14,QWORD PTR [rsp+0x48]
    1411:	mov    r15,QWORD PTR [rsp+0x50]
    1416:	add    rsp,0x60
    141a:	mov    rsp,rbp
    141d:	pop    rbp
    141e:	ret
    141f:	cmp    rax,0x6
    1423:	je     1438 <botlish_fn_17+0x1b9>
    1429:	add    r12,0x1
    1430:	mov    rdi,rbx
    1433:	jmp    12b4 <botlish_fn_17+0x35>
    1438:	mov    eax,0x6
    143d:	mov    rbx,QWORD PTR [rsp+0x30]
    1442:	mov    r12,QWORD PTR [rsp+0x38]
    1447:	mov    r13,QWORD PTR [rsp+0x40]
    144c:	mov    r14,QWORD PTR [rsp+0x48]
    1451:	mov    r15,QWORD PTR [rsp+0x50]
    1456:	add    rsp,0x60
    145a:	mov    rsp,rbp
    145d:	pop    rbp
    145e:	ret
    145f:	mov    eax,0x2
    1464:	mov    rbx,QWORD PTR [rsp+0x30]
    1469:	mov    r12,QWORD PTR [rsp+0x38]
    146e:	mov    r13,QWORD PTR [rsp+0x40]
    1473:	mov    r14,QWORD PTR [rsp+0x48]
    1478:	mov    r15,QWORD PTR [rsp+0x50]
    147d:	add    rsp,0x60
    1481:	mov    rsp,rbp
    1484:	pop    rbp
    1485:	ret

0000000000001486 <botlish_entry_17: domain?<int>>:
    1486:	push   rbp
    1487:	mov    rbp,rsp
    148a:	mov    rsi,QWORD PTR [rdx]
    148d:	mov    r8,QWORD PTR [rdx+0x8]
    1491:	mov    rcx,QWORD PTR [rdx+0x10]
    1495:	sar    rsi,1
    1498:	mov    rdx,r8
    149b:	call   14a0 <botlish_entry_17+0x1a>
			149c: R_X86_64_PLT32	botlish_fn_17-0x4 ; domain?<int>
    14a0:	mov    rsp,rbp
    14a3:	pop    rbp
    14a4:	ret

00000000000014a5 <botlish_fn_18: web::is_unreserved<int>>:
    14a5:	push   rbp
    14a6:	mov    rbp,rsp
    14a9:	sub    rsp,0x10
    14ad:	mov    QWORD PTR [rsp],rbx
    14b1:	mov    QWORD PTR [rsp+0x8],r14
    14b6:	mov    r14,rsi
    14b9:	mov    rsi,r14
    14bc:	sar    rsi,1
    14bf:	mov    rbx,rdi
    14c2:	call   14c7 <botlish_fn_18+0x22>
			14c3: R_X86_64_PLT32	botlish_fn_7-0x4 ; ascii::is_alphanumeric<int>
    14c7:	cmp    rax,0x6
    14cb:	je     1502 <botlish_fn_18+0x5d>
    14d1:	mov    rax,QWORD PTR [rbx+0x30]
    14d5:	mov    rsi,QWORD PTR [rax+0x10]
    14d9:	mov    rdx,r14
    14dc:	mov    rdi,rbx
    14df:	call   14e4 <botlish_fn_18+0x3f>
			14e0: R_X86_64_PLT32	rt_set_contains-0x4
    14e4:	cmp    rax,0x6
    14e8:	je     14f8 <botlish_fn_18+0x53>
    14ee:	mov    eax,0x2
    14f3:	jmp    1507 <botlish_fn_18+0x62>
    14f8:	mov    eax,0x6
    14fd:	jmp    1507 <botlish_fn_18+0x62>
    1502:	mov    eax,0x6
    1507:	mov    rbx,QWORD PTR [rsp]
    150b:	mov    r14,QWORD PTR [rsp+0x8]
    1510:	add    rsp,0x10
    1514:	mov    rsp,rbp
    1517:	pop    rbp
    1518:	ret

0000000000001519 <botlish_entry_18: web::is_unreserved<int>>:
    1519:	push   rbp
    151a:	mov    rbp,rsp
    151d:	mov    rsi,QWORD PTR [rdx]
    1520:	call   1525 <botlish_entry_18+0xc>
			1521: R_X86_64_PLT32	botlish_fn_18-0x4 ; web::is_unreserved<int>
    1525:	mov    rsp,rbp
    1528:	pop    rbp
    1529:	ret

000000000000152a <botlish_fn_19: web::uri_query_value?<str>>:
    152a:	push   rbp
    152b:	mov    rbp,rsp
    152e:	sub    rsp,0x10
    1532:	mov    QWORD PTR [rsp],rsi
    1536:	mov    rdx,rsi
    1539:	mov    esi,0x1
    153e:	mov    QWORD PTR [rsp+0x8],0x1
    1547:	call   154c <botlish_fn_19+0x22>
			1548: R_X86_64_PLT32	botlish_fn_21-0x4 ; valid_from?<int>
    154c:	add    rsp,0x10
    1550:	mov    rsp,rbp
    1553:	pop    rbp
    1554:	ret

0000000000001555 <botlish_entry_19: web::uri_query_value?<str>>:
    1555:	push   rbp
    1556:	mov    rbp,rsp
    1559:	mov    rsi,QWORD PTR [rdx]
    155c:	call   1561 <botlish_entry_19+0xc>
			155d: R_X86_64_PLT32	botlish_fn_19-0x4 ; web::uri_query_value?<str>
    1561:	mov    rsp,rbp
    1564:	pop    rbp
    1565:	ret
	...

0000000000001568 <botlish_fn_20: upper_hex?<int>>:
    1568:	push   rbp
    1569:	mov    rbp,rsp
    156c:	sub    rsp,0x20
    1570:	mov    QWORD PTR [rsp],rbx
    1574:	mov    QWORD PTR [rsp+0x8],r12
    1579:	mov    QWORD PTR [rsp+0x10],r13
    157e:	mov    rbx,rdi
    1581:	mov    r13,rdx
    1584:	mov    rdx,r13
    1587:	mov    rdx,QWORD PTR [rdx+0x8]
    158b:	shl    rdx,1
    158e:	mov    rax,rdx
    1591:	or     rax,0x1
    1595:	mov    rcx,rsi
    1598:	and    rcx,rax
    159b:	test   rcx,0x1
    15a2:	jne    15cf <botlish_fn_20+0x67>
    15a8:	or     rdx,0x1
    15ac:	mov    r12,rsi
    15af:	mov    rdi,rbx
    15b2:	call   15b7 <botlish_fn_20+0x4f>
			15b3: R_X86_64_PLT32	rt_int_cmp-0x4
    15b7:	mov    ecx,0x2
    15bc:	test   rax,rax
    15bf:	cmovge rcx,QWORD PTR [rip+0x169]        # 1730 <botlish_fn_20+0x1c8>
    15c7:	mov    rsi,r12
    15ca:	jmp    15e6 <botlish_fn_20+0x7e>
    15cf:	mov    r12,rsi
    15d2:	or     rdx,0x1
    15d6:	mov    ecx,0x2
    15db:	cmp    r12,rdx
    15de:	cmovge rcx,QWORD PTR [rip+0x14a]        # 1730 <botlish_fn_20+0x1c8>
    15e6:	mov    eax,0x6
    15eb:	mov    r12,rax
    15ee:	cmp    rcx,0x6
    15f2:	je     1602 <botlish_fn_20+0x9a>
    15f8:	mov    eax,0x2
    15fd:	jmp    1605 <botlish_fn_20+0x9d>
    1602:	mov    rax,r12
    1605:	cmp    rax,0x6
    1609:	je     1712 <botlish_fn_20+0x1aa>
    160f:	mov    rdx,r13
    1612:	movzx  rax,BYTE PTR [rdx+0x18]
    1617:	test   rax,rax
    161a:	jne    1633 <botlish_fn_20+0xcb>
    1620:	mov    rdx,rsi
    1623:	mov    rsi,r13
    1626:	mov    rdi,rbx
    1629:	call   162e <botlish_fn_20+0xc6>
			162a: R_X86_64_PLT32	rt_str_char_at_proven-0x4
    162e:	jmp    164a <botlish_fn_20+0xe2>
    1633:	mov    rdx,rsi
    1636:	mov    rsi,r13
    1639:	sar    rdx,1
    163c:	movzx  rax,BYTE PTR [rsi+rdx*1+0x19]
    1642:	shl    rax,0x3
    1646:	or     rax,0x4
    164a:	mov    rdx,rax
    164d:	shr    rdx,0x3
    1651:	shl    rdx,1
    1654:	or     rdx,0x1
    1658:	mov    ecx,0x2
    165d:	cmp    rdx,0xff
    1664:	cmovle rcx,QWORD PTR [rip+0xc4]        # 1730 <botlish_fn_20+0x1c8>
    166c:	cmp    rcx,0x6
    1670:	je     1683 <botlish_fn_20+0x11b>
    1676:	mov    eax,0x2
    167b:	mov    r12,rax
    167e:	jmp    1717 <botlish_fn_20+0x1af>
    1683:	shr    rax,0x3
    1687:	shl    rax,1
    168a:	or     rax,0x1
    168e:	sar    rax,1
    1691:	mov    rdi,rbx
    1694:	mov    r13,rax
    1697:	mov    rsi,r13
    169a:	call   169f <botlish_fn_20+0x137>
			169b: R_X86_64_PLT32	botlish_fn_3-0x4 ; ascii::is_digit<int>
    169f:	cmp    rax,0x6
    16a3:	je     16f3 <botlish_fn_20+0x18b>
    16a9:	mov    rax,r13
    16ac:	cmp    rax,0x41
    16b0:	jge    16c0 <botlish_fn_20+0x158>
    16b6:	mov    esi,0x2
    16bb:	jmp    16d7 <botlish_fn_20+0x16f>
    16c0:	cmp    rax,0x46
    16c4:	jle    16d4 <botlish_fn_20+0x16c>
    16ca:	mov    esi,0x2
    16cf:	jmp    16d7 <botlish_fn_20+0x16f>
    16d4:	mov    rsi,r12
    16d7:	cmp    rsi,0x6
    16db:	je     16eb <botlish_fn_20+0x183>
    16e1:	mov    eax,0x2
    16e6:	jmp    16f6 <botlish_fn_20+0x18e>
    16eb:	mov    rax,r12
    16ee:	jmp    16f6 <botlish_fn_20+0x18e>
    16f3:	mov    rax,r12
    16f6:	cmp    rax,0x6
    16fa:	je     170a <botlish_fn_20+0x1a2>
    1700:	mov    eax,0x2
    1705:	jmp    1717 <botlish_fn_20+0x1af>
    170a:	mov    rax,r12
    170d:	jmp    1717 <botlish_fn_20+0x1af>
    1712:	mov    eax,0x2
    1717:	mov    rbx,QWORD PTR [rsp]
    171b:	mov    r12,QWORD PTR [rsp+0x8]
    1720:	mov    r13,QWORD PTR [rsp+0x10]
    1725:	add    rsp,0x20
    1729:	mov    rsp,rbp
    172c:	pop    rbp
    172d:	ret
    172e:	add    BYTE PTR [rax],al
    1730:	(bad)
    1731:	add    BYTE PTR [rax],al
    1733:	add    BYTE PTR [rax],al
    1735:	add    BYTE PTR [rax],al
	...

0000000000001738 <botlish_entry_20: upper_hex?<int>>:
    1738:	push   rbp
    1739:	mov    rbp,rsp
    173c:	mov    rsi,QWORD PTR [rdx]
    173f:	mov    rdx,QWORD PTR [rdx+0x8]
    1743:	call   1748 <botlish_entry_20+0x10>
			1744: R_X86_64_PLT32	botlish_fn_20-0x4 ; upper_hex?<int>
    1748:	mov    rsp,rbp
    174b:	pop    rbp
    174c:	ret
    174d:	add    BYTE PTR [rax],al
	...

0000000000001750 <botlish_fn_21: valid_from?<int>>:
    1750:	push   rbp
    1751:	mov    rbp,rsp
    1754:	sub    rsp,0x40
    1758:	mov    QWORD PTR [rsp+0x20],r12
    175d:	mov    QWORD PTR [rsp+0x28],r13
    1762:	mov    QWORD PTR [rsp+0x30],r14
    1767:	mov    r13,rdi
    176a:	mov    QWORD PTR [rsp],rsi
    176e:	mov    r14,rsi
    1771:	mov    QWORD PTR [rsp+0x8],rdx
    1776:	mov    r12,rdx
    1779:	mov    rdx,QWORD PTR [r12+0x8]
    177e:	shl    rdx,1
    1781:	or     rdx,0x1
    1785:	mov    rsi,r14
    1788:	mov    rdi,rsi
    178b:	and    rdi,rdx
    178e:	test   rdi,0x1
    1795:	jne    17bb <botlish_fn_21+0x6b>
    179b:	mov    rsi,r14
    179e:	mov    rdi,r13
    17a1:	call   17a6 <botlish_fn_21+0x56>
			17a2: R_X86_64_PLT32	rt_int_cmp-0x4
    17a6:	mov    ecx,0x2
    17ab:	test   rax,rax
    17ae:	cmovge rcx,QWORD PTR [rip+0x252]        # 1a08 <botlish_fn_21+0x2b8>
    17b6:	jmp    17ce <botlish_fn_21+0x7e>
    17bb:	mov    ecx,0x2
    17c0:	mov    rsi,r14
    17c3:	cmp    rsi,rdx
    17c6:	cmovge rcx,QWORD PTR [rip+0x23a]        # 1a08 <botlish_fn_21+0x2b8>
    17ce:	cmp    rcx,0x6
    17d2:	je     17e2 <botlish_fn_21+0x92>
    17d8:	mov    ecx,0x2
    17dd:	jmp    17e7 <botlish_fn_21+0x97>
    17e2:	mov    ecx,0x6
    17e7:	cmp    rcx,0x6
    17eb:	je     19e9 <botlish_fn_21+0x299>
    17f1:	movzx  rax,BYTE PTR [r12+0x18]
    17f7:	test   rax,rax
    17fa:	jne    1816 <botlish_fn_21+0xc6>
    1800:	mov    rdx,r14
    1803:	mov    rsi,r12
    1806:	mov    rdi,r13
    1809:	call   180e <botlish_fn_21+0xbe>
			180a: R_X86_64_PLT32	rt_str_char_at_proven-0x4
    180e:	mov    rsi,rax
    1811:	jmp    182d <botlish_fn_21+0xdd>
    1816:	mov    rsi,r14
    1819:	mov    rax,rsi
    181c:	sar    rax,1
    181f:	movzx  rsi,BYTE PTR [r12+rax*1+0x19]
    1825:	shl    rsi,0x3
    1829:	or     rsi,0x4
    182d:	cmp    rsi,0x12c
    1834:	je     18d4 <botlish_fn_21+0x184>
    183a:	mov    rcx,rsi
    183d:	shr    rcx,0x3
    1841:	shl    rcx,1
    1844:	or     rcx,0x1
    1848:	mov    edx,0x2
    184d:	cmp    rcx,0xff
    1854:	cmovle rdx,QWORD PTR [rip+0x1ac]        # 1a08 <botlish_fn_21+0x2b8>
    185c:	cmp    rdx,0x6
    1860:	je     1870 <botlish_fn_21+0x120>
    1866:	mov    ecx,0x2
    186b:	jmp    189c <botlish_fn_21+0x14c>
    1870:	shr    rsi,0x3
    1874:	shl    rsi,1
    1877:	or     rsi,0x1
    187b:	mov    rdi,r13
    187e:	call   1883 <botlish_fn_21+0x133>
			187f: R_X86_64_PLT32	botlish_fn_18-0x4 ; web::is_unreserved<int>
    1883:	cmp    rax,0x6
    1887:	je     1897 <botlish_fn_21+0x147>
    188d:	mov    ecx,0x2
    1892:	jmp    189c <botlish_fn_21+0x14c>
    1897:	mov    ecx,0x6
    189c:	cmp    rcx,0x6
    18a0:	jne    1973 <botlish_fn_21+0x223>
    18a6:	mov    rsi,r14
    18a9:	sar    rsi,1
    18ac:	mov    r14,rsi
    18af:	add    rsi,0x1
    18b6:	mov    r14,rsi
    18b9:	shl    rsi,1
    18bc:	mov    r14,rsi
    18bf:	or     rsi,0x1
    18c3:	mov    r14,rsi
    18c6:	mov    QWORD PTR [rsp],rsi
    18ca:	mov    QWORD PTR [rsp+0x8],r12
    18cf:	jmp    1779 <botlish_fn_21+0x29>
    18d4:	mov    rsi,r14
    18d7:	mov    rax,rsi
    18da:	sar    rax,1
    18dd:	lea    rsi,[rax+0x1]
    18e1:	shl    rsi,1
    18e4:	or     rsi,0x1
    18e8:	mov    rdx,r12
    18eb:	mov    rdi,r13
    18ee:	call   18f3 <botlish_fn_21+0x1a3>
			18ef: R_X86_64_PLT32	botlish_fn_20-0x4 ; upper_hex?<int>
    18f3:	cmp    rax,0x6
    18f7:	je     1907 <botlish_fn_21+0x1b7>
    18fd:	mov    ecx,0x2
    1902:	jmp    1969 <botlish_fn_21+0x219>
    1907:	mov    QWORD PTR [rsp+0x10],0x5
    1910:	mov    rsi,r14
    1913:	test   rsi,0x1
    191a:	je     1932 <botlish_fn_21+0x1e2>
    1920:	mov    rsi,r14
    1923:	add    rsi,0x4
    1927:	seto   al
    192a:	test   al,al
    192c:	je     1945 <botlish_fn_21+0x1f5>
    1932:	mov    edx,0x5
    1937:	mov    rsi,r14
    193a:	mov    rdi,r13
    193d:	call   1942 <botlish_fn_21+0x1f2>
			193e: R_X86_64_PLT32	rt_int_add-0x4
    1942:	mov    rsi,rax
    1945:	mov    rdx,r12
    1948:	mov    rdi,r13
    194b:	call   1950 <botlish_fn_21+0x200>
			194c: R_X86_64_PLT32	botlish_fn_20-0x4 ; upper_hex?<int>
    1950:	cmp    rax,0x6
    1954:	je     1964 <botlish_fn_21+0x214>
    195a:	mov    ecx,0x2
    195f:	jmp    1969 <botlish_fn_21+0x219>
    1964:	mov    ecx,0x6
    1969:	cmp    rcx,0x6
    196d:	je     1990 <botlish_fn_21+0x240>
    1973:	mov    eax,0x2
    1978:	mov    r12,QWORD PTR [rsp+0x20]
    197d:	mov    r13,QWORD PTR [rsp+0x28]
    1982:	mov    r14,QWORD PTR [rsp+0x30]
    1987:	add    rsp,0x40
    198b:	mov    rsp,rbp
    198e:	pop    rbp
    198f:	ret
    1990:	mov    QWORD PTR [rsp+0x10],0x7
    1999:	mov    rsi,r14
    199c:	test   rsi,0x1
    19a3:	je     19c5 <botlish_fn_21+0x275>
    19a9:	mov    rsi,r14
    19ac:	add    rsi,0x6
    19b0:	seto   dil
    19b4:	test   dil,dil
    19b7:	jne    19c5 <botlish_fn_21+0x275>
    19bd:	mov    r14,rsi
    19c0:	jmp    19db <botlish_fn_21+0x28b>
    19c5:	mov    edx,0x7
    19ca:	mov    rsi,r14
    19cd:	mov    rdi,r13
    19d0:	call   19d5 <botlish_fn_21+0x285>
			19d1: R_X86_64_PLT32	rt_int_add-0x4
    19d5:	mov    rsi,rax
    19d8:	mov    r14,rax
    19db:	mov    QWORD PTR [rsp],rsi
    19df:	mov    QWORD PTR [rsp+0x8],r12
    19e4:	jmp    1779 <botlish_fn_21+0x29>
    19e9:	mov    eax,0x6
    19ee:	mov    r12,QWORD PTR [rsp+0x20]
    19f3:	mov    r13,QWORD PTR [rsp+0x28]
    19f8:	mov    r14,QWORD PTR [rsp+0x30]
    19fd:	add    rsp,0x40
    1a01:	mov    rsp,rbp
    1a04:	pop    rbp
    1a05:	ret
    1a06:	add    BYTE PTR [rax],al
    1a08:	(bad)
    1a09:	add    BYTE PTR [rax],al
    1a0b:	add    BYTE PTR [rax],al
    1a0d:	add    BYTE PTR [rax],al
	...

0000000000001a10 <botlish_entry_21: valid_from?<int>>:
    1a10:	push   rbp
    1a11:	mov    rbp,rsp
    1a14:	mov    rsi,QWORD PTR [rdx]
    1a17:	mov    rdx,QWORD PTR [rdx+0x8]
    1a1b:	call   1a20 <botlish_entry_21+0x10>
			1a1c: R_X86_64_PLT32	botlish_fn_21-0x4 ; valid_from?<int>
    1a20:	mov    rsp,rbp
    1a23:	pop    rbp
    1a24:	ret

0000000000001a25 <botlish_fn_22: web::uri_escape_text<str>>:
    1a25:	push   rbp
    1a26:	mov    rbp,rsp
    1a29:	sub    rsp,0x10
    1a2d:	mov    edx,0x1
    1a32:	mov    QWORD PTR [rsp],0x1
    1a3a:	mov    r10,QWORD PTR [rdi+0x10]
    1a3e:	mov    rcx,QWORD PTR [r10+0xc8]
    1a45:	mov    QWORD PTR [rsp+0x8],rcx
    1a4a:	call   1a4f <botlish_fn_22+0x2a>
			1a4b: R_X86_64_PLT32	botlish_fn_28-0x4 ; esc_from<str, int, str>
    1a4f:	test   rax,rax
    1a52:	jne    1a64 <botlish_fn_22+0x3f>
    1a58:	xor    rax,rax
    1a5b:	add    rsp,0x10
    1a5f:	mov    rsp,rbp
    1a62:	pop    rbp
    1a63:	ret
    1a64:	add    rsp,0x10
    1a68:	mov    rsp,rbp
    1a6b:	pop    rbp
    1a6c:	ret

0000000000001a6d <botlish_entry_22: web::uri_escape_text<str>>:
    1a6d:	push   rbp
    1a6e:	mov    rbp,rsp
    1a71:	sub    rsp,0x10
    1a75:	mov    QWORD PTR [rsp],r12
    1a79:	mov    r12,rdi
    1a7c:	mov    rsi,QWORD PTR [rdx]
    1a7f:	mov    r8,QWORD PTR [rip+0x0]        # 1a86 <botlish_entry_22+0x19>
			1a82: R_X86_64_GOTPCREL	rt_str_to_ascii-0x4
    1a86:	call   r8
    1a89:	mov    rsi,rax
    1a8c:	mov    rdi,r12
    1a8f:	call   1a94 <botlish_entry_22+0x27>
			1a90: R_X86_64_PLT32	botlish_fn_22-0x4 ; web::uri_escape_text<str>
    1a94:	mov    r12,QWORD PTR [rsp]
    1a98:	add    rsp,0x10
    1a9c:	mov    rsp,rbp
    1a9f:	pop    rbp
    1aa0:	ret

0000000000001aa1 <botlish_fn_23: high_nibble<int>>:
    1aa1:	push   rbp
    1aa2:	mov    rbp,rsp
    1aa5:	sub    rsp,0x10
    1aa9:	mov    QWORD PTR [rsp],rsi
    1aad:	mov    QWORD PTR [rsp+0x8],0x1e1
    1ab6:	test   rsi,0x1
    1abd:	jne    1ad2 <botlish_fn_23+0x31>
    1ac3:	mov    edx,0x1e1
    1ac8:	call   1acd <botlish_fn_23+0x2c>
			1ac9: R_X86_64_PLT32	rt_int_and-0x4
    1acd:	jmp    1adc <botlish_fn_23+0x3b>
    1ad2:	and    rsi,0x1e1
    1ad9:	mov    rax,rsi
    1adc:	sar    rax,0x5
    1ae0:	shl    rax,1
    1ae3:	or     rax,0x1
    1ae7:	add    rsp,0x10
    1aeb:	mov    rsp,rbp
    1aee:	pop    rbp
    1aef:	ret

0000000000001af0 <botlish_entry_23: high_nibble<int>>:
    1af0:	push   rbp
    1af1:	mov    rbp,rsp
    1af4:	mov    rsi,QWORD PTR [rdx]
    1af7:	call   1afc <botlish_entry_23+0xc>
			1af8: R_X86_64_PLT32	botlish_fn_23-0x4 ; high_nibble<int>
    1afc:	mov    rsp,rbp
    1aff:	pop    rbp
    1b00:	ret

0000000000001b01 <botlish_fn_24: hex_pair<int>>:
    1b01:	push   rbp
    1b02:	mov    rbp,rsp
    1b05:	sub    rsp,0x60
    1b09:	mov    QWORD PTR [rsp+0x40],rbx
    1b0e:	mov    QWORD PTR [rsp+0x48],r12
    1b13:	mov    QWORD PTR [rsp+0x50],r13
    1b18:	mov    QWORD PTR [rsp+0x58],r14
    1b1d:	mov    QWORD PTR [rsp+0x10],0x0
    1b26:	mov    QWORD PTR [rsp+0x18],0x0
    1b2f:	mov    QWORD PTR [rsp],rsi
    1b33:	mov    r14,rsi
    1b36:	mov    rax,QWORD PTR [rdi+0x30]
    1b3a:	mov    r13,rdi
    1b3d:	mov    rbx,QWORD PTR [rax+0x8]
    1b41:	mov    QWORD PTR [rsp+0x8],rbx
    1b46:	mov    rsi,r14
    1b49:	call   1b4e <botlish_fn_24+0x4d>
			1b4a: R_X86_64_PLT32	botlish_fn_23-0x4 ; high_nibble<int>
    1b4e:	mov    rcx,QWORD PTR [rbx+0x10]
    1b52:	sar    rax,1
    1b55:	mov    r12,QWORD PTR [rcx+rax*8]
    1b59:	mov    QWORD PTR [rsp+0x8],r12
    1b5e:	mov    rdi,r13
    1b61:	mov    rax,QWORD PTR [rdi+0x30]
    1b65:	mov    rbx,QWORD PTR [rax+0x8]
    1b69:	mov    QWORD PTR [rsp+0x10],rbx
    1b6e:	mov    edx,0x21
    1b73:	mov    QWORD PTR [rsp+0x18],0x21
    1b7c:	mov    rsi,r14
    1b7f:	call   1b84 <botlish_fn_24+0x83>
			1b80: R_X86_64_PLT32	rt_int_mod-0x4
    1b84:	test   rax,rax
    1b87:	je     1bd8 <botlish_fn_24+0xd7>
    1b8d:	mov    rcx,QWORD PTR [rbx+0x10]
    1b91:	sar    rax,1
    1b94:	mov    rdx,QWORD PTR [rcx+rax*8]
    1b98:	mov    QWORD PTR [rsp],rdx
    1b9c:	lea    rcx,[rsp+0x20]
    1ba1:	mov    QWORD PTR [rsp+0x20],0x0
    1baa:	mov    QWORD PTR [rsp+0x28],r12
    1baf:	mov    QWORD PTR [rsp+0x30],0x0
    1bb8:	mov    QWORD PTR [rsp+0x38],rdx
    1bbd:	mov    esi,0x2
    1bc2:	mov    edx,0x4
    1bc7:	mov    rdi,r13
    1bca:	call   1bcf <botlish_fn_24+0xce>
			1bcb: R_X86_64_PLT32	rt_construct-0x4
    1bcf:	test   rax,rax
    1bd2:	jne    1bf8 <botlish_fn_24+0xf7>
    1bd8:	xor    rax,rax
    1bdb:	mov    rbx,QWORD PTR [rsp+0x40]
    1be0:	mov    r12,QWORD PTR [rsp+0x48]
    1be5:	mov    r13,QWORD PTR [rsp+0x50]
    1bea:	mov    r14,QWORD PTR [rsp+0x58]
    1bef:	add    rsp,0x60
    1bf3:	mov    rsp,rbp
    1bf6:	pop    rbp
    1bf7:	ret
    1bf8:	mov    rbx,QWORD PTR [rsp+0x40]
    1bfd:	mov    r12,QWORD PTR [rsp+0x48]
    1c02:	mov    r13,QWORD PTR [rsp+0x50]
    1c07:	mov    r14,QWORD PTR [rsp+0x58]
    1c0c:	add    rsp,0x60
    1c10:	mov    rsp,rbp
    1c13:	pop    rbp
    1c14:	ret

0000000000001c15 <botlish_entry_24: hex_pair<int>>:
    1c15:	push   rbp
    1c16:	mov    rbp,rsp
    1c19:	sub    rsp,0x10
    1c1d:	mov    QWORD PTR [rsp],r12
    1c21:	mov    r12,rdi
    1c24:	mov    rsi,QWORD PTR [rdx]
    1c27:	call   1c2c <botlish_entry_24+0x17>
			1c28: R_X86_64_PLT32	botlish_fn_24-0x4 ; hex_pair<int>
    1c2c:	mov    r8,QWORD PTR [rip+0x0]        # 1c33 <botlish_entry_24+0x1e>
			1c2f: R_X86_64_GOTPCREL	rt_plan_materialize-0x4
    1c33:	mov    rsi,rax
    1c36:	mov    rdi,r12
    1c39:	call   r8
    1c3c:	mov    r12,QWORD PTR [rsp]
    1c40:	add    rsp,0x10
    1c44:	mov    rsp,rbp
    1c47:	pop    rbp
    1c48:	ret

0000000000001c49 <botlish_fn_25: pct<int>>:
    1c49:	push   rbp
    1c4a:	mov    rbp,rsp
    1c4d:	sub    rsp,0x40
    1c51:	mov    QWORD PTR [rsp+0x30],r12
    1c56:	mov    QWORD PTR [rsp+0x38],r13
    1c5b:	mov    QWORD PTR [rsp],rsi
    1c5f:	mov    rax,QWORD PTR [rdi+0x10]
    1c63:	mov    r12,rdi
    1c66:	mov    r13,QWORD PTR [rax+0x10]
    1c6a:	mov    QWORD PTR [rsp+0x8],r13
    1c6f:	call   1c74 <botlish_fn_25+0x2b>
			1c70: R_X86_64_PLT32	botlish_fn_24-0x4 ; hex_pair<int>
    1c74:	test   rax,rax
    1c77:	je     1cbd <botlish_fn_25+0x74>
    1c7d:	mov    QWORD PTR [rsp],rax
    1c81:	lea    rcx,[rsp+0x10]
    1c86:	mov    QWORD PTR [rsp+0x10],0x0
    1c8f:	mov    QWORD PTR [rsp+0x18],r13
    1c94:	mov    QWORD PTR [rsp+0x20],0x0
    1c9d:	mov    QWORD PTR [rsp+0x28],rax
    1ca2:	mov    esi,0x2
    1ca7:	mov    edx,0x4
    1cac:	mov    rdi,r12
    1caf:	call   1cb4 <botlish_fn_25+0x6b>
			1cb0: R_X86_64_PLT32	rt_construct-0x4
    1cb4:	test   rax,rax
    1cb7:	jne    1cd3 <botlish_fn_25+0x8a>
    1cbd:	xor    rax,rax
    1cc0:	mov    r12,QWORD PTR [rsp+0x30]
    1cc5:	mov    r13,QWORD PTR [rsp+0x38]
    1cca:	add    rsp,0x40
    1cce:	mov    rsp,rbp
    1cd1:	pop    rbp
    1cd2:	ret
    1cd3:	mov    r12,QWORD PTR [rsp+0x30]
    1cd8:	mov    r13,QWORD PTR [rsp+0x38]
    1cdd:	add    rsp,0x40
    1ce1:	mov    rsp,rbp
    1ce4:	pop    rbp
    1ce5:	ret

0000000000001ce6 <botlish_entry_25: pct<int>>:
    1ce6:	push   rbp
    1ce7:	mov    rbp,rsp
    1cea:	sub    rsp,0x10
    1cee:	mov    QWORD PTR [rsp],r12
    1cf2:	mov    r12,rdi
    1cf5:	mov    rsi,QWORD PTR [rdx]
    1cf8:	call   1cfd <botlish_entry_25+0x17>
			1cf9: R_X86_64_PLT32	botlish_fn_25-0x4 ; pct<int>
    1cfd:	mov    r8,QWORD PTR [rip+0x0]        # 1d04 <botlish_entry_25+0x1e>
			1d00: R_X86_64_GOTPCREL	rt_plan_materialize-0x4
    1d04:	mov    rsi,rax
    1d07:	mov    rdi,r12
    1d0a:	call   r8
    1d0d:	mov    r12,QWORD PTR [rsp]
    1d11:	add    rsp,0x10
    1d15:	mov    rsp,rbp
    1d18:	pop    rbp
    1d19:	ret

0000000000001d1a <botlish_fn_26: cont<int, int>>:
    1d1a:	push   rbp
    1d1b:	mov    rbp,rsp
    1d1e:	sub    rsp,0x30
    1d22:	mov    QWORD PTR [rsp+0x20],rbx
    1d27:	mov    rbx,rdi
    1d2a:	mov    QWORD PTR [rsp],rsi
    1d2e:	mov    QWORD PTR [rsp+0x8],rdx
    1d33:	mov    QWORD PTR [rsp+0x10],0x101
    1d3c:	mov    rdi,rbx
    1d3f:	call   1d44 <botlish_fn_26+0x2a>
			1d40: R_X86_64_PLT32	rt_int_shr-0x4
    1d44:	test   rax,rax
    1d47:	je     1dca <botlish_fn_26+0xb0>
    1d4d:	mov    QWORD PTR [rsp],rax
    1d51:	mov    QWORD PTR [rsp+0x8],0x7f
    1d5a:	test   rax,0x1
    1d60:	mov    rsi,rax
    1d63:	jne    1d7e <botlish_fn_26+0x64>
    1d69:	mov    edx,0x7f
    1d6e:	mov    rdi,rbx
    1d71:	call   1d76 <botlish_fn_26+0x5c>
			1d72: R_X86_64_PLT32	rt_int_and-0x4
    1d76:	mov    rdx,rax
    1d79:	jmp    1d85 <botlish_fn_26+0x6b>
    1d7e:	mov    rdx,rsi
    1d81:	and    rdx,0x7f
    1d85:	mov    QWORD PTR [rsp],rdx
    1d89:	test   rdx,0x1
    1d90:	jne    1dab <botlish_fn_26+0x91>
    1d96:	mov    esi,0x101
    1d9b:	mov    rdi,rbx
    1d9e:	call   1da3 <botlish_fn_26+0x89>
			1d9f: R_X86_64_PLT32	rt_int_or-0x4
    1da3:	mov    rsi,rax
    1da6:	jmp    1db5 <botlish_fn_26+0x9b>
    1dab:	or     rdx,0x101
    1db2:	mov    rsi,rdx
    1db5:	mov    QWORD PTR [rsp],rsi
    1db9:	mov    rdi,rbx
    1dbc:	call   1dc1 <botlish_fn_26+0xa7>
			1dbd: R_X86_64_PLT32	botlish_fn_25-0x4 ; pct<int>
    1dc1:	test   rax,rax
    1dc4:	jne    1ddb <botlish_fn_26+0xc1>
    1dca:	xor    rax,rax
    1dcd:	mov    rbx,QWORD PTR [rsp+0x20]
    1dd2:	add    rsp,0x30
    1dd6:	mov    rsp,rbp
    1dd9:	pop    rbp
    1dda:	ret
    1ddb:	mov    rbx,QWORD PTR [rsp+0x20]
    1de0:	add    rsp,0x30
    1de4:	mov    rsp,rbp
    1de7:	pop    rbp
    1de8:	ret

0000000000001de9 <botlish_entry_26: cont<int, int>>:
    1de9:	push   rbp
    1dea:	mov    rbp,rsp
    1ded:	sub    rsp,0x10
    1df1:	mov    QWORD PTR [rsp],r12
    1df5:	mov    r12,rdi
    1df8:	mov    rsi,QWORD PTR [rdx]
    1dfb:	mov    rdx,QWORD PTR [rdx+0x8]
    1dff:	call   1e04 <botlish_entry_26+0x1b>
			1e00: R_X86_64_PLT32	botlish_fn_26-0x4 ; cont<int, int>
    1e04:	mov    r8,QWORD PTR [rip+0x0]        # 1e0b <botlish_entry_26+0x22>
			1e07: R_X86_64_GOTPCREL	rt_plan_materialize-0x4
    1e0b:	mov    rsi,rax
    1e0e:	mov    rdi,r12
    1e11:	call   r8
    1e14:	mov    r12,QWORD PTR [rsp]
    1e18:	add    rsp,0x10
    1e1c:	mov    rsp,rbp
    1e1f:	pop    rbp
    1e20:	ret
    1e21:	add    BYTE PTR [rax],al
    1e23:	add    BYTE PTR [rax],al
    1e25:	add    BYTE PTR [rax],al
	...

0000000000001e28 <botlish_fn_27: esc_scalar<int>>:
    1e28:	push   rbp
    1e29:	mov    rbp,rsp
    1e2c:	sub    rsp,0xf0
    1e33:	mov    QWORD PTR [rsp+0xc0],rbx
    1e3b:	mov    QWORD PTR [rsp+0xc8],r12
    1e43:	mov    QWORD PTR [rsp+0xd0],r13
    1e4b:	mov    QWORD PTR [rsp+0xd8],r14
    1e53:	mov    QWORD PTR [rsp+0xe0],r15
    1e5b:	mov    rbx,rdi
    1e5e:	mov    QWORD PTR [rsp+0x18],0x0
    1e67:	mov    QWORD PTR [rsp+0x20],0x0
    1e70:	mov    QWORD PTR [rsp],rsi
    1e74:	test   rsi,0x1
    1e7b:	mov    r12,rsi
    1e7e:	jne    1eaa <botlish_fn_27+0x82>
    1e84:	mov    edx,0x1001
    1e89:	mov    rsi,r12
    1e8c:	mov    rdi,rbx
    1e8f:	call   1e94 <botlish_fn_27+0x6c>
			1e90: R_X86_64_PLT32	rt_int_cmp-0x4
    1e94:	mov    r11d,0x2
    1e9a:	test   rax,rax
    1e9d:	cmovl  r11,QWORD PTR [rip+0x3fb]        # 22a0 <botlish_fn_27+0x478>
    1ea5:	jmp    1ec2 <botlish_fn_27+0x9a>
    1eaa:	mov    r11d,0x2
    1eb0:	mov    rsi,r12
    1eb3:	cmp    rsi,0x1001
    1eba:	cmovl  r11,QWORD PTR [rip+0x3de]        # 22a0 <botlish_fn_27+0x478>
    1ec2:	mov    edx,0x6
    1ec7:	mov    r13,rdx
    1eca:	cmp    r11,0x6
    1ece:	je     2188 <botlish_fn_27+0x360>
    1ed4:	mov    rsi,r12
    1ed7:	test   rsi,0x1
    1ede:	jne    1f09 <botlish_fn_27+0xe1>
    1ee4:	mov    edx,0x20001
    1ee9:	mov    rsi,r12
    1eec:	mov    rdi,rbx
    1eef:	call   1ef4 <botlish_fn_27+0xcc>
			1ef0: R_X86_64_PLT32	rt_int_cmp-0x4
    1ef4:	mov    ecx,0x2
    1ef9:	test   rax,rax
    1efc:	cmovl  rcx,QWORD PTR [rip+0x39c]        # 22a0 <botlish_fn_27+0x478>
    1f04:	jmp    1f20 <botlish_fn_27+0xf8>
    1f09:	mov    ecx,0x2
    1f0e:	mov    rsi,r12
    1f11:	cmp    rsi,0x20001
    1f18:	cmovl  rcx,QWORD PTR [rip+0x380]        # 22a0 <botlish_fn_27+0x478>
    1f20:	cmp    rcx,0x6
    1f24:	je     209b <botlish_fn_27+0x273>
    1f2a:	mov    QWORD PTR [rsp+0x8],0x1e1
    1f33:	mov    edx,0x25
    1f38:	mov    QWORD PTR [rsp+0x10],0x25
    1f41:	mov    rsi,r12
    1f44:	mov    rdi,rbx
    1f47:	call   1f4c <botlish_fn_27+0x124>
			1f48: R_X86_64_PLT32	rt_int_shr-0x4
    1f4c:	test   rax,rax
    1f4f:	je     2231 <botlish_fn_27+0x409>
    1f55:	mov    QWORD PTR [rsp+0x10],rax
    1f5a:	test   rax,0x1
    1f60:	mov    rdx,rax
    1f63:	jne    1f7e <botlish_fn_27+0x156>
    1f69:	mov    esi,0x1e1
    1f6e:	mov    rdi,rbx
    1f71:	call   1f76 <botlish_fn_27+0x14e>
			1f72: R_X86_64_PLT32	rt_int_or-0x4
    1f76:	mov    rsi,rax
    1f79:	jmp    1f88 <botlish_fn_27+0x160>
    1f7e:	mov    rsi,rdx
    1f81:	or     rsi,0x1e1
    1f88:	mov    QWORD PTR [rsp+0x8],rsi
    1f8d:	mov    rdi,rbx
    1f90:	call   1f95 <botlish_fn_27+0x16d>
			1f91: R_X86_64_PLT32	botlish_fn_25-0x4 ; pct<int>
    1f95:	test   rax,rax
    1f98:	je     2231 <botlish_fn_27+0x409>
    1f9e:	mov    QWORD PTR [rsp+0x8],rax
    1fa3:	mov    r13,rax
    1fa6:	mov    edx,0x19
    1fab:	mov    QWORD PTR [rsp+0x10],0x19
    1fb4:	mov    rsi,r12
    1fb7:	mov    rdi,rbx
    1fba:	call   1fbf <botlish_fn_27+0x197>
			1fbb: R_X86_64_PLT32	botlish_fn_26-0x4 ; cont<int, int>
    1fbf:	test   rax,rax
    1fc2:	je     2231 <botlish_fn_27+0x409>
    1fc8:	mov    QWORD PTR [rsp+0x10],rax
    1fcd:	mov    r14,rax
    1fd0:	mov    edx,0xd
    1fd5:	mov    QWORD PTR [rsp+0x18],0xd
    1fde:	mov    rsi,r12
    1fe1:	mov    rdi,rbx
    1fe4:	call   1fe9 <botlish_fn_27+0x1c1>
			1fe5: R_X86_64_PLT32	botlish_fn_26-0x4 ; cont<int, int>
    1fe9:	test   rax,rax
    1fec:	je     2231 <botlish_fn_27+0x409>
    1ff2:	mov    QWORD PTR [rsp+0x18],rax
    1ff7:	mov    r15,rax
    1ffa:	mov    edx,0x1
    1fff:	mov    QWORD PTR [rsp+0x20],0x1
    2008:	mov    rsi,r12
    200b:	mov    rdi,rbx
    200e:	call   2013 <botlish_fn_27+0x1eb>
			200f: R_X86_64_PLT32	botlish_fn_26-0x4 ; cont<int, int>
    2013:	test   rax,rax
    2016:	je     2231 <botlish_fn_27+0x409>
    201c:	mov    QWORD PTR [rsp],rax
    2020:	lea    rcx,[rsp+0x78]
    2025:	mov    QWORD PTR [rsp+0x78],0x0
    202e:	mov    rdx,r13
    2031:	mov    QWORD PTR [rsp+0x80],rdx
    2039:	mov    QWORD PTR [rsp+0x88],0x0
    2045:	mov    rdx,r14
    2048:	mov    QWORD PTR [rsp+0x90],rdx
    2050:	mov    QWORD PTR [rsp+0x98],0x0
    205c:	mov    rdx,r15
    205f:	mov    QWORD PTR [rsp+0xa0],rdx
    2067:	mov    QWORD PTR [rsp+0xa8],0x0
    2073:	mov    QWORD PTR [rsp+0xb0],rax
    207b:	mov    esi,0x2
    2080:	mov    edx,0x8
    2085:	mov    rdi,rbx
    2088:	call   208d <botlish_fn_27+0x265>
			2089: R_X86_64_PLT32	rt_construct-0x4
    208d:	test   rax,rax
    2090:	je     2231 <botlish_fn_27+0x409>
    2096:	jmp    2268 <botlish_fn_27+0x440>
    209b:	mov    QWORD PTR [rsp+0x8],0x1c1
    20a4:	mov    edx,0xd
    20a9:	mov    rsi,r12
    20ac:	mov    r14,rdx
    20af:	sar    rsi,0xd
    20b3:	shl    rsi,1
    20b6:	mov    rax,rsi
    20b9:	or     rax,0x1
    20bd:	mov    QWORD PTR [rsp+0x10],rax
    20c2:	or     rsi,0x1c1
    20c9:	mov    QWORD PTR [rsp+0x8],rsi
    20ce:	mov    rdi,rbx
    20d1:	call   20d6 <botlish_fn_27+0x2ae>
			20d2: R_X86_64_PLT32	botlish_fn_25-0x4 ; pct<int>
    20d6:	test   rax,rax
    20d9:	je     2231 <botlish_fn_27+0x409>
    20df:	mov    QWORD PTR [rsp+0x8],rax
    20e4:	mov    r15,rax
    20e7:	mov    QWORD PTR [rsp+0x10],0xd
    20f0:	mov    rdx,r14
    20f3:	mov    rsi,r12
    20f6:	mov    rdi,rbx
    20f9:	call   20fe <botlish_fn_27+0x2d6>
			20fa: R_X86_64_PLT32	botlish_fn_26-0x4 ; cont<int, int>
    20fe:	test   rax,rax
    2101:	je     2231 <botlish_fn_27+0x409>
    2107:	mov    QWORD PTR [rsp+0x10],rax
    210c:	mov    r14,rax
    210f:	mov    edx,0x1
    2114:	mov    QWORD PTR [rsp+0x18],0x1
    211d:	mov    rsi,r12
    2120:	mov    rdi,rbx
    2123:	call   2128 <botlish_fn_27+0x300>
			2124: R_X86_64_PLT32	botlish_fn_26-0x4 ; cont<int, int>
    2128:	test   rax,rax
    212b:	je     2231 <botlish_fn_27+0x409>
    2131:	mov    QWORD PTR [rsp],rax
    2135:	lea    rcx,[rsp+0x48]
    213a:	mov    QWORD PTR [rsp+0x48],0x0
    2143:	mov    rdx,r15
    2146:	mov    QWORD PTR [rsp+0x50],rdx
    214b:	mov    QWORD PTR [rsp+0x58],0x0
    2154:	mov    rdx,r14
    2157:	mov    QWORD PTR [rsp+0x60],rdx
    215c:	mov    QWORD PTR [rsp+0x68],0x0
    2165:	mov    QWORD PTR [rsp+0x70],rax
    216a:	mov    esi,0x2
    216f:	mov    rdx,r13
    2172:	mov    rdi,rbx
    2175:	call   217a <botlish_fn_27+0x352>
			2176: R_X86_64_PLT32	rt_construct-0x4
    217a:	test   rax,rax
    217d:	je     2231 <botlish_fn_27+0x409>
    2183:	jmp    2268 <botlish_fn_27+0x440>
    2188:	mov    QWORD PTR [rsp+0x8],0x181
    2191:	mov    rsi,r12
    2194:	sar    rsi,0x7
    2198:	shl    rsi,1
    219b:	mov    rax,rsi
    219e:	or     rax,0x1
    21a2:	mov    QWORD PTR [rsp+0x10],rax
    21a7:	or     rsi,0x181
    21ae:	mov    QWORD PTR [rsp+0x8],rsi
    21b3:	mov    rdi,rbx
    21b6:	call   21bb <botlish_fn_27+0x393>
			21b7: R_X86_64_PLT32	botlish_fn_25-0x4 ; pct<int>
    21bb:	test   rax,rax
    21be:	je     2231 <botlish_fn_27+0x409>
    21c4:	mov    QWORD PTR [rsp+0x8],rax
    21c9:	mov    r13,rax
    21cc:	mov    edx,0x1
    21d1:	mov    QWORD PTR [rsp+0x10],0x1
    21da:	mov    rsi,r12
    21dd:	mov    rdi,rbx
    21e0:	call   21e5 <botlish_fn_27+0x3bd>
			21e1: R_X86_64_PLT32	botlish_fn_26-0x4 ; cont<int, int>
    21e5:	test   rax,rax
    21e8:	je     2231 <botlish_fn_27+0x409>
    21ee:	mov    QWORD PTR [rsp],rax
    21f2:	lea    rcx,[rsp+0x28]
    21f7:	mov    QWORD PTR [rsp+0x28],0x0
    2200:	mov    rdx,r13
    2203:	mov    QWORD PTR [rsp+0x30],rdx
    2208:	mov    QWORD PTR [rsp+0x38],0x0
    2211:	mov    QWORD PTR [rsp+0x40],rax
    2216:	mov    esi,0x2
    221b:	mov    edx,0x4
    2220:	mov    rdi,rbx
    2223:	call   2228 <botlish_fn_27+0x400>
			2224: R_X86_64_PLT32	rt_construct-0x4
    2228:	test   rax,rax
    222b:	jne    2268 <botlish_fn_27+0x440>
    2231:	xor    rax,rax
    2234:	mov    rbx,QWORD PTR [rsp+0xc0]
    223c:	mov    r12,QWORD PTR [rsp+0xc8]
    2244:	mov    r13,QWORD PTR [rsp+0xd0]
    224c:	mov    r14,QWORD PTR [rsp+0xd8]
    2254:	mov    r15,QWORD PTR [rsp+0xe0]
    225c:	add    rsp,0xf0
    2263:	mov    rsp,rbp
    2266:	pop    rbp
    2267:	ret
    2268:	mov    rbx,QWORD PTR [rsp+0xc0]
    2270:	mov    r12,QWORD PTR [rsp+0xc8]
    2278:	mov    r13,QWORD PTR [rsp+0xd0]
    2280:	mov    r14,QWORD PTR [rsp+0xd8]
    2288:	mov    r15,QWORD PTR [rsp+0xe0]
    2290:	add    rsp,0xf0
    2297:	mov    rsp,rbp
    229a:	pop    rbp
    229b:	ret
    229c:	add    BYTE PTR [rax],al
    229e:	add    BYTE PTR [rax],al
    22a0:	(bad)
    22a1:	add    BYTE PTR [rax],al
    22a3:	add    BYTE PTR [rax],al
    22a5:	add    BYTE PTR [rax],al
	...

00000000000022a8 <botlish_entry_27: esc_scalar<int>>:
    22a8:	push   rbp
    22a9:	mov    rbp,rsp
    22ac:	sub    rsp,0x10
    22b0:	mov    QWORD PTR [rsp],r12
    22b4:	mov    r12,rdi
    22b7:	mov    rsi,QWORD PTR [rdx]
    22ba:	call   22bf <botlish_entry_27+0x17>
			22bb: R_X86_64_PLT32	botlish_fn_27-0x4 ; esc_scalar<int>
    22bf:	mov    r8,QWORD PTR [rip+0x0]        # 22c6 <botlish_entry_27+0x1e>
			22c2: R_X86_64_GOTPCREL	rt_plan_materialize-0x4
    22c6:	mov    rsi,rax
    22c9:	mov    rdi,r12
    22cc:	call   r8
    22cf:	mov    r12,QWORD PTR [rsp]
    22d3:	add    rsp,0x10
    22d7:	mov    rsp,rbp
    22da:	pop    rbp
    22db:	ret
    22dc:	add    BYTE PTR [rax],al
	...

00000000000022e0 <botlish_fn_28: esc_from<str, int, str>>:
    22e0:	push   rbp
    22e1:	mov    rbp,rsp
    22e4:	sub    rsp,0x100
    22eb:	mov    QWORD PTR [rsp+0xd0],rbx
    22f3:	mov    QWORD PTR [rsp+0xd8],r12
    22fb:	mov    QWORD PTR [rsp+0xe0],r13
    2303:	mov    QWORD PTR [rsp+0xe8],r14
    230b:	mov    QWORD PTR [rsp+0xf0],r15
    2313:	mov    QWORD PTR [rsp+0xa0],rdi
    231b:	mov    QWORD PTR [rsp+0x8],0x0
    2324:	mov    QWORD PTR [rsp+0x10],0x0
    232d:	mov    QWORD PTR [rsp+0x18],0x0
    2336:	mov    QWORD PTR [rsp],rcx
    233a:	mov    QWORD PTR [rsp+0xb0],rcx
    2342:	sar    rdx,1
    2345:	mov    rdi,rdx
    2348:	mov    r15d,0x47
    234e:	mov    rax,0xffffffffffffffff
    2355:	bsr    rcx,rsi
    2359:	mov    QWORD PTR [rsp+0xa8],rsi
    2361:	cmove  rcx,rax
    2365:	mov    esi,0x3f
    236a:	sub    rsi,rcx
    236d:	sub    r15,rsi
    2370:	shr    r15,0x3
    2374:	lea    r12,[rsp+0x80]
    237c:	mov    QWORD PTR [rsp+0xc8],r12
    2384:	lea    r13,[rsp+0x50]
    2389:	mov    QWORD PTR [rsp+0xc0],r13
    2391:	lea    rdx,[rsp+0x30]
    2396:	mov    QWORD PTR [rsp+0xb8],rdx
    239e:	mov    r14,rdi
    23a1:	cmp    r14,r15
    23a4:	jge    23b4 <botlish_fn_28+0xd4>
    23aa:	mov    eax,0x2
    23af:	jmp    23b9 <botlish_fn_28+0xd9>
    23b4:	mov    eax,0x6
    23b9:	cmp    rax,0x6
    23bd:	je     2604 <botlish_fn_28+0x324>
    23c3:	mov    rsi,QWORD PTR [rsp+0xa8]
    23cb:	mov    rdi,QWORD PTR [rsp+0xa0]
    23d3:	call   23d8 <botlish_fn_28+0xf8>
			23d4: R_X86_64_PLT32	rt_ascii_to_str-0x4
    23d8:	mov    QWORD PTR [rsp+0x8],rax
    23dd:	mov    rbx,r14
    23e0:	shl    rbx,1
    23e3:	or     rbx,0x1
    23e7:	mov    QWORD PTR [rsp+0x10],rbx
    23ec:	movzx  r11,BYTE PTR [rax+0x18]
    23f1:	mov    r13,rax
    23f4:	test   r11,r11
    23f7:	jne    2418 <botlish_fn_28+0x138>
    23fd:	mov    rdx,rbx
    2400:	mov    rsi,r13
    2403:	mov    rdi,QWORD PTR [rsp+0xa0]
    240b:	call   2410 <botlish_fn_28+0x130>
			240c: R_X86_64_PLT32	rt_str_char_at_proven-0x4
    2410:	mov    rsi,rax
    2413:	jmp    242c <botlish_fn_28+0x14c>
    2418:	mov    rcx,rbx
    241b:	sar    rcx,1
    241e:	movzx  rsi,BYTE PTR [r13+rcx*1+0x19]
    2424:	shl    rsi,0x3
    2428:	or     rsi,0x4
    242c:	shr    rsi,0x3
    2430:	shl    rsi,1
    2433:	or     rsi,0x1
    2437:	mov    QWORD PTR [rsp+0x8],rsi
    243c:	mov    ecx,0x2
    2441:	cmp    rsi,0xff
    2448:	mov    r12,rsi
    244b:	cmovg  rcx,QWORD PTR [rip+0x255]        # 26a8 <botlish_fn_28+0x3c8>
    2453:	cmp    rcx,0x6
    2457:	je     2582 <botlish_fn_28+0x2a2>
    245d:	mov    rsi,r12
    2460:	mov    rdi,QWORD PTR [rsp+0xa0]
    2468:	call   246d <botlish_fn_28+0x18d>
			2469: R_X86_64_PLT32	botlish_fn_18-0x4 ; web::is_unreserved<int>
    246d:	cmp    rax,0x6
    2471:	je     2505 <botlish_fn_28+0x225>
    2477:	mov    rsi,r12
    247a:	mov    rdi,QWORD PTR [rsp+0xa0]
    2482:	call   2487 <botlish_fn_28+0x1a7>
			2483: R_X86_64_PLT32	botlish_fn_25-0x4 ; pct<int>
    2487:	test   rax,rax
    248a:	je     263d <botlish_fn_28+0x35d>
    2490:	mov    QWORD PTR [rsp+0x8],rax
    2495:	mov    QWORD PTR [rsp+0x80],0x0
    24a1:	mov    r12,QWORD PTR [rsp+0xb0]
    24a9:	mov    QWORD PTR [rsp+0x88],r12
    24b1:	mov    QWORD PTR [rsp+0x90],0x0
    24bd:	mov    QWORD PTR [rsp+0x98],rax
    24c5:	mov    esi,0x2
    24ca:	mov    edx,0x4
    24cf:	mov    rcx,QWORD PTR [rsp+0xc8]
    24d7:	mov    rdi,QWORD PTR [rsp+0xa0]
    24df:	call   24e4 <botlish_fn_28+0x204>
			24e0: R_X86_64_PLT32	rt_construct-0x4
    24e4:	test   rax,rax
    24e7:	je     263d <botlish_fn_28+0x35d>
    24ed:	mov    QWORD PTR [rsp],rax
    24f1:	add    r14,0x1
    24f8:	mov    QWORD PTR [rsp+0xb0],rax
    2500:	jmp    23a1 <botlish_fn_28+0xc1>
    2505:	mov    r12,QWORD PTR [rsp+0xb0]
    250d:	add    r14,0x1
    2514:	mov    rcx,r14
    2517:	shl    rcx,1
    251a:	or     rcx,0x1
    251e:	mov    QWORD PTR [rsp+0x18],rcx
    2523:	mov    QWORD PTR [rsp+0x50],0x0
    252c:	mov    QWORD PTR [rsp+0x58],r12
    2531:	mov    QWORD PTR [rsp+0x60],0x1
    253a:	mov    QWORD PTR [rsp+0x68],r13
    253f:	mov    QWORD PTR [rsp+0x70],rbx
    2544:	mov    QWORD PTR [rsp+0x78],rcx
    2549:	mov    esi,0x2
    254e:	mov    edx,0x6
    2553:	mov    rcx,QWORD PTR [rsp+0xc0]
    255b:	mov    rdi,QWORD PTR [rsp+0xa0]
    2563:	call   2568 <botlish_fn_28+0x288>
			2564: R_X86_64_PLT32	rt_construct-0x4
    2568:	test   rax,rax
    256b:	je     263d <botlish_fn_28+0x35d>
    2571:	mov    QWORD PTR [rsp],rax
    2575:	mov    QWORD PTR [rsp+0xb0],rax
    257d:	jmp    23a1 <botlish_fn_28+0xc1>
    2582:	mov    rsi,r12
    2585:	mov    r12,QWORD PTR [rsp+0xb0]
    258d:	mov    rdi,QWORD PTR [rsp+0xa0]
    2595:	call   259a <botlish_fn_28+0x2ba>
			2596: R_X86_64_PLT32	botlish_fn_27-0x4 ; esc_scalar<int>
    259a:	test   rax,rax
    259d:	je     263d <botlish_fn_28+0x35d>
    25a3:	mov    QWORD PTR [rsp+0x8],rax
    25a8:	mov    QWORD PTR [rsp+0x30],0x0
    25b1:	mov    QWORD PTR [rsp+0x38],r12
    25b6:	mov    QWORD PTR [rsp+0x40],0x0
    25bf:	mov    QWORD PTR [rsp+0x48],rax
    25c4:	mov    esi,0x2
    25c9:	mov    edx,0x4
    25ce:	mov    rcx,QWORD PTR [rsp+0xb8]
    25d6:	mov    rdi,QWORD PTR [rsp+0xa0]
    25de:	call   25e3 <botlish_fn_28+0x303>
			25df: R_X86_64_PLT32	rt_construct-0x4
    25e3:	test   rax,rax
    25e6:	je     263d <botlish_fn_28+0x35d>
    25ec:	mov    QWORD PTR [rsp],rax
    25f0:	add    r14,0x1
    25f7:	mov    QWORD PTR [rsp+0xb0],rax
    25ff:	jmp    23a1 <botlish_fn_28+0xc1>
    2604:	mov    r12,QWORD PTR [rsp+0xb0]
    260c:	xor    rsi,rsi
    260f:	lea    rcx,[rsp+0x20]
    2614:	mov    QWORD PTR [rsp+0x20],0x0
    261d:	mov    QWORD PTR [rsp+0x28],r12
    2622:	mov    edx,0x2
    2627:	mov    rdi,QWORD PTR [rsp+0xa0]
    262f:	call   2634 <botlish_fn_28+0x354>
			2630: R_X86_64_PLT32	rt_construct-0x4
    2634:	test   rax,rax
    2637:	jne    2674 <botlish_fn_28+0x394>
    263d:	xor    rax,rax
    2640:	mov    rbx,QWORD PTR [rsp+0xd0]
    2648:	mov    r12,QWORD PTR [rsp+0xd8]
    2650:	mov    r13,QWORD PTR [rsp+0xe0]
    2658:	mov    r14,QWORD PTR [rsp+0xe8]
    2660:	mov    r15,QWORD PTR [rsp+0xf0]
    2668:	add    rsp,0x100
    266f:	mov    rsp,rbp
    2672:	pop    rbp
    2673:	ret
    2674:	mov    rbx,QWORD PTR [rsp+0xd0]
    267c:	mov    r12,QWORD PTR [rsp+0xd8]
    2684:	mov    r13,QWORD PTR [rsp+0xe0]
    268c:	mov    r14,QWORD PTR [rsp+0xe8]
    2694:	mov    r15,QWORD PTR [rsp+0xf0]
    269c:	add    rsp,0x100
    26a3:	mov    rsp,rbp
    26a6:	pop    rbp
    26a7:	ret
    26a8:	(bad)
    26a9:	add    BYTE PTR [rax],al
    26ab:	add    BYTE PTR [rax],al
    26ad:	add    BYTE PTR [rax],al
	...

00000000000026b0 <botlish_entry_28: esc_from<str, int, str>>:
    26b0:	push   rbp
    26b1:	mov    rbp,rsp
    26b4:	sub    rsp,0x10
    26b8:	mov    QWORD PTR [rsp],r12
    26bc:	mov    QWORD PTR [rsp+0x8],r13
    26c1:	mov    r12,rdi
    26c4:	mov    rsi,QWORD PTR [rdx]
    26c7:	mov    r13,rdx
    26ca:	mov    r8,QWORD PTR [rip+0x0]        # 26d1 <botlish_entry_28+0x21>
			26cd: R_X86_64_GOTPCREL	rt_str_to_ascii-0x4
    26d1:	call   r8
    26d4:	mov    rcx,r13
    26d7:	mov    rdx,QWORD PTR [rcx+0x8]
    26db:	mov    rcx,QWORD PTR [rcx+0x10]
    26df:	mov    rsi,rax
    26e2:	mov    rdi,r12
    26e5:	call   26ea <botlish_entry_28+0x3a>
			26e6: R_X86_64_PLT32	botlish_fn_28-0x4 ; esc_from<str, int, str>
    26ea:	mov    r12,QWORD PTR [rsp]
    26ee:	mov    r13,QWORD PTR [rsp+0x8]
    26f3:	add    rsp,0x10
    26f7:	mov    rsp,rbp
    26fa:	pop    rbp
    26fb:	ret

00000000000026fc <botlish_fn_29: check<int, int, str, str>>:
    26fc:	push   rbp
    26fd:	mov    rbp,rsp
    2700:	sub    rsp,0x50
    2704:	mov    QWORD PTR [rsp+0x20],rbx
    2709:	mov    QWORD PTR [rsp+0x28],r12
    270e:	mov    QWORD PTR [rsp+0x30],r13
    2713:	mov    QWORD PTR [rsp+0x38],r14
    2718:	mov    QWORD PTR [rsp+0x40],r15
    271d:	mov    r14,rdi
    2720:	mov    QWORD PTR [rsp+0x18],0x0
    2729:	mov    QWORD PTR [rsp],rdx
    272d:	mov    QWORD PTR [rsp+0x8],rcx
    2732:	mov    QWORD PTR [rsp+0x10],r8
    2737:	mov    r12,r8
    273a:	mov    r13,rsi
    273d:	mov    r15,rdx
    2740:	test   r13,r13
    2743:	jle    281d <botlish_fn_29+0x121>
    2749:	mov    rbx,rcx
    274c:	mov    rsi,rbx
    274f:	mov    rdi,r14
    2752:	call   2757 <botlish_fn_29+0x5b>
			2753: R_X86_64_PLT32	botlish_fn_8-0x4 ; web::emailish?<str>
    2757:	test   rax,rax
    275a:	jne    2785 <botlish_fn_29+0x89>
    2760:	xor    rax,rax
    2763:	mov    rbx,QWORD PTR [rsp+0x20]
    2768:	mov    r12,QWORD PTR [rsp+0x28]
    276d:	mov    r13,QWORD PTR [rsp+0x30]
    2772:	mov    r14,QWORD PTR [rsp+0x38]
    2777:	mov    r15,QWORD PTR [rsp+0x40]
    277c:	add    rsp,0x50
    2780:	mov    rsp,rbp
    2783:	pop    rbp
    2784:	ret
    2785:	cmp    rax,0x6
    2789:	je     27a5 <botlish_fn_29+0xa9>
    278f:	mov    edx,0x1
    2794:	mov    QWORD PTR [rsp+0x18],0x1
    279d:	mov    rsi,r15
    27a0:	jmp    27d1 <botlish_fn_29+0xd5>
    27a5:	mov    rsi,r12
    27a8:	mov    rdi,r14
    27ab:	call   27b0 <botlish_fn_29+0xb4>
			27ac: R_X86_64_PLT32	botlish_fn_19-0x4 ; web::uri_query_value?<str>
    27b0:	cmp    rax,0x6
    27b4:	je     27c4 <botlish_fn_29+0xc8>
    27ba:	mov    edx,0x1
    27bf:	jmp    27c9 <botlish_fn_29+0xcd>
    27c4:	mov    edx,0x3
    27c9:	mov    QWORD PTR [rsp+0x18],rdx
    27ce:	mov    rsi,r15
    27d1:	mov    rax,rsi
    27d4:	and    rax,rdx
    27d7:	test   rax,0x1
    27dd:	je     27f8 <botlish_fn_29+0xfc>
    27e3:	lea    rcx,[rdx-0x1]
    27e7:	mov    rax,rsi
    27ea:	add    rax,rcx
    27ed:	seto   cl
    27f0:	test   cl,cl
    27f2:	je     2800 <botlish_fn_29+0x104>
    27f8:	mov    rdi,r14
    27fb:	call   2800 <botlish_fn_29+0x104>
			27fc: R_X86_64_PLT32	rt_int_add-0x4
    2800:	mov    QWORD PTR [rsp],rax
    2804:	mov    QWORD PTR [rsp+0x8],rbx
    2809:	mov    QWORD PTR [rsp+0x10],r12
    280e:	sub    r13,0x1
    2812:	mov    rcx,rbx
    2815:	mov    r15,rax
    2818:	jmp    2740 <botlish_fn_29+0x44>
    281d:	mov    rax,r15
    2820:	mov    rbx,QWORD PTR [rsp+0x20]
    2825:	mov    r12,QWORD PTR [rsp+0x28]
    282a:	mov    r13,QWORD PTR [rsp+0x30]
    282f:	mov    r14,QWORD PTR [rsp+0x38]
    2834:	mov    r15,QWORD PTR [rsp+0x40]
    2839:	add    rsp,0x50
    283d:	mov    rsp,rbp
    2840:	pop    rbp
    2841:	ret

0000000000002842 <botlish_entry_29: check<int, int, str, str>>:
    2842:	push   rbp
    2843:	mov    rbp,rsp
    2846:	mov    rsi,QWORD PTR [rdx]
    2849:	mov    r9,QWORD PTR [rdx+0x8]
    284d:	mov    rcx,QWORD PTR [rdx+0x10]
    2851:	mov    r8,QWORD PTR [rdx+0x18]
    2855:	sar    rsi,1
    2858:	mov    rdx,r9
    285b:	call   2860 <botlish_entry_29+0x1e>
			285c: R_X86_64_PLT32	botlish_fn_29-0x4 ; check<int, int, str, str>
    2860:	mov    rsp,rbp
    2863:	pop    rbp
    2864:	ret
