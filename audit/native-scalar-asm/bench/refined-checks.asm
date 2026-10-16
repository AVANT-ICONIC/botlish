; source:  bench/refined-checks.bot
; backend: Cranelift (specialize=1), native::object
; object:  ELF64 x86-64, unlinked (Botlish-generated code only; runtime
;          helpers are unresolved imports, so their bodies are not present)
; format:  objdump -dr --no-show-raw-insn -M intel
; total machine code bytes: 10319  (per function: 1415 217 745 74 74 74 128 128 336 129 88 192 176 176 295 344 183 504 140 60 421 661 127 103 345 219 287 1255 1055 368)
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
     c47:	jge    c71 <botlish_fn_9+0x4a>
     c4d:	lea    rcx,[rax+0x1]
     c51:	shl    rcx,1
     c54:	or     rcx,0x1
     c58:	mov    QWORD PTR [rsp+0x10],rcx
     c5d:	mov    rdx,rsi
     c60:	mov    rsi,r8
     c63:	call   c68 <botlish_fn_9+0x41>
			c64: R_X86_64_PLT32	rt_substr_proven-0x4
     c68:	add    rsp,0x20
     c6c:	mov    rsp,rbp
     c6f:	pop    rbp
     c70:	ret
     c71:	mov    rax,QWORD PTR [rdi+0x10]
     c75:	mov    rax,QWORD PTR [rax+0xc8]
     c7c:	add    rsp,0x20
     c80:	mov    rsp,rbp
     c83:	pop    rbp
     c84:	ret

0000000000000c85 <botlish_entry_9: char_at<int>>:
     c85:	push   rbp
     c86:	mov    rbp,rsp
     c89:	mov    rsi,QWORD PTR [rdx]
     c8c:	mov    r8,QWORD PTR [rdx+0x8]
     c90:	mov    rcx,QWORD PTR [rdx+0x10]
     c94:	mov    rdx,r8
     c97:	call   c9c <botlish_entry_9+0x17>
			c98: R_X86_64_PLT32	botlish_fn_9-0x4 ; char_at<int>
     c9c:	mov    rsp,rbp
     c9f:	pop    rbp
     ca0:	ret

0000000000000ca1 <botlish_fn_10: char_at<int>>:
     ca1:	push   rbp
     ca2:	mov    rbp,rsp
     ca5:	mov    rax,rsi
     ca8:	sar    rax,1
     cab:	sar    rdx,1
     cae:	cmp    rax,rdx
     cb1:	jge    cd4 <botlish_fn_10+0x33>
     cb7:	mov    QWORD PTR [r8],rsi
     cba:	add    rax,0x1
     cc1:	shl    rax,1
     cc4:	or     rax,0x1
     cc8:	mov    QWORD PTR [r8+0x8],rax
     ccc:	mov    rax,rcx
     ccf:	mov    rsp,rbp
     cd2:	pop    rbp
     cd3:	ret
     cd4:	mov    rax,QWORD PTR [rdi+0x10]
     cd8:	mov    rax,QWORD PTR [rax+0xc8]
     cdf:	mov    QWORD PTR [r8],0x1
     ce6:	mov    QWORD PTR [r8+0x8],0x1
     cee:	mov    rsp,rbp
     cf1:	pop    rbp
     cf2:	ret

0000000000000cf3 <botlish_entry_10: char_at<int>>:
     cf3:	push   rbp
     cf4:	mov    rbp,rsp
     cf7:	ud2
     cf9:	add    BYTE PTR [rax],al
     cfb:	add    BYTE PTR [rax],al
     cfd:	add    BYTE PTR [rax],al
	...

0000000000000d00 <botlish_fn_11: char_is?<int, any>>:
     d00:	push   rbp
     d01:	mov    rbp,rsp
     d04:	sub    rsp,0x10
     d08:	mov    QWORD PTR [rsp],rbx
     d0c:	mov    rbx,rdx
     d0f:	mov    rax,rsi
     d12:	sar    rax,1
     d15:	sar    rcx,1
     d18:	cmp    rax,rcx
     d1b:	jge    d7c <botlish_fn_11+0x7c>
     d21:	movzx  rcx,BYTE PTR [r8+0x18]
     d26:	mov    rdx,r8
     d29:	test   rcx,rcx
     d2c:	jne    d48 <botlish_fn_11+0x48>
     d32:	mov    rax,rdx
     d35:	mov    rdx,rsi
     d38:	mov    rsi,rax
     d3b:	call   d40 <botlish_fn_11+0x40>
			d3c: R_X86_64_PLT32	rt_str_char_at_proven-0x4
     d40:	mov    rcx,rax
     d43:	jmp    d5c <botlish_fn_11+0x5c>
     d48:	mov    rsi,rdx
     d4b:	movzx  rax,BYTE PTR [rsi+rax*1+0x19]
     d51:	shl    rax,0x3
     d55:	or     rax,0x4
     d59:	mov    rcx,rax
     d5c:	mov    eax,0x2
     d61:	mov    rdx,rbx
     d64:	cmp    rcx,rdx
     d67:	cmove  rax,QWORD PTR [rip+0x21]        # d90 <botlish_fn_11+0x90>
     d6f:	mov    rbx,QWORD PTR [rsp]
     d73:	add    rsp,0x10
     d77:	mov    rsp,rbp
     d7a:	pop    rbp
     d7b:	ret
     d7c:	mov    eax,0x2
     d81:	mov    rbx,QWORD PTR [rsp]
     d85:	add    rsp,0x10
     d89:	mov    rsp,rbp
     d8c:	pop    rbp
     d8d:	ret
     d8e:	add    BYTE PTR [rax],al
     d90:	(bad)
     d91:	add    BYTE PTR [rax],al
     d93:	add    BYTE PTR [rax],al
     d95:	add    BYTE PTR [rax],al
	...

0000000000000d98 <botlish_entry_11: char_is?<int, any>>:
     d98:	push   rbp
     d99:	mov    rbp,rsp
     d9c:	mov    rsi,QWORD PTR [rdx]
     d9f:	mov    r9,QWORD PTR [rdx+0x8]
     da3:	mov    rcx,QWORD PTR [rdx+0x10]
     da7:	mov    r8,QWORD PTR [rdx+0x18]
     dab:	mov    rdx,r9
     dae:	call   db3 <botlish_entry_11+0x1b>
			daf: R_X86_64_PLT32	botlish_fn_11-0x4 ; char_is?<int, any>
     db3:	mov    rsp,rbp
     db6:	pop    rbp
     db7:	ret

0000000000000db8 <botlish_fn_12: local_char?<str>>:
     db8:	push   rbp
     db9:	mov    rbp,rsp
     dbc:	sub    rsp,0x10
     dc0:	mov    QWORD PTR [rsp],rbx
     dc4:	mov    QWORD PTR [rsp+0x8],r14
     dc9:	mov    rbx,rdi
     dcc:	mov    r14,rsi
     dcf:	mov    rsi,r14
     dd2:	mov    rdi,rbx
     dd5:	call   dda <botlish_fn_12+0x22>
			dd6: R_X86_64_PLT32	rt_is_tcl_alnum-0x4
     dda:	test   rax,rax
     ddd:	jne    df8 <botlish_fn_12+0x40>
     de3:	xor    rax,rax
     de6:	mov    rbx,QWORD PTR [rsp]
     dea:	mov    r14,QWORD PTR [rsp+0x8]
     def:	add    rsp,0x10
     df3:	mov    rsp,rbp
     df6:	pop    rbp
     df7:	ret
     df8:	cmp    rax,0x6
     dfc:	je     e32 <botlish_fn_12+0x7a>
     e02:	mov    rdi,rbx
     e05:	mov    rax,QWORD PTR [rdi+0x30]
     e09:	mov    rsi,QWORD PTR [rax]
     e0c:	mov    rdx,r14
     e0f:	call   e14 <botlish_fn_12+0x5c>
			e10: R_X86_64_PLT32	rt_set_contains-0x4
     e14:	cmp    rax,0x6
     e18:	je     e28 <botlish_fn_12+0x70>
     e1e:	mov    eax,0x2
     e23:	jmp    e37 <botlish_fn_12+0x7f>
     e28:	mov    eax,0x6
     e2d:	jmp    e37 <botlish_fn_12+0x7f>
     e32:	mov    eax,0x6
     e37:	mov    rbx,QWORD PTR [rsp]
     e3b:	mov    r14,QWORD PTR [rsp+0x8]
     e40:	add    rsp,0x10
     e44:	mov    rsp,rbp
     e47:	pop    rbp
     e48:	ret

0000000000000e49 <botlish_entry_12: local_char?<str>>:
     e49:	push   rbp
     e4a:	mov    rbp,rsp
     e4d:	mov    rsi,QWORD PTR [rdx]
     e50:	call   e55 <botlish_entry_12+0xc>
			e51: R_X86_64_PLT32	botlish_fn_12-0x4 ; local_char?<str>
     e55:	mov    rsp,rbp
     e58:	pop    rbp
     e59:	ret

0000000000000e5a <botlish_fn_13: local_char?<generic>>:
     e5a:	push   rbp
     e5b:	mov    rbp,rsp
     e5e:	sub    rsp,0x10
     e62:	mov    QWORD PTR [rsp],rbx
     e66:	mov    QWORD PTR [rsp+0x8],r14
     e6b:	mov    rbx,rdi
     e6e:	mov    r14,rsi
     e71:	mov    rsi,r14
     e74:	mov    rdi,rbx
     e77:	call   e7c <botlish_fn_13+0x22>
			e78: R_X86_64_PLT32	rt_is_tcl_alnum-0x4
     e7c:	test   rax,rax
     e7f:	jne    e9a <botlish_fn_13+0x40>
     e85:	xor    rax,rax
     e88:	mov    rbx,QWORD PTR [rsp]
     e8c:	mov    r14,QWORD PTR [rsp+0x8]
     e91:	add    rsp,0x10
     e95:	mov    rsp,rbp
     e98:	pop    rbp
     e99:	ret
     e9a:	cmp    rax,0x6
     e9e:	je     ed4 <botlish_fn_13+0x7a>
     ea4:	mov    rdi,rbx
     ea7:	mov    rax,QWORD PTR [rdi+0x30]
     eab:	mov    rsi,QWORD PTR [rax]
     eae:	mov    rdx,r14
     eb1:	call   eb6 <botlish_fn_13+0x5c>
			eb2: R_X86_64_PLT32	rt_set_contains-0x4
     eb6:	cmp    rax,0x6
     eba:	je     eca <botlish_fn_13+0x70>
     ec0:	mov    eax,0x2
     ec5:	jmp    ed9 <botlish_fn_13+0x7f>
     eca:	mov    eax,0x6
     ecf:	jmp    ed9 <botlish_fn_13+0x7f>
     ed4:	mov    eax,0x6
     ed9:	mov    rbx,QWORD PTR [rsp]
     edd:	mov    r14,QWORD PTR [rsp+0x8]
     ee2:	add    rsp,0x10
     ee6:	mov    rsp,rbp
     ee9:	pop    rbp
     eea:	ret

0000000000000eeb <botlish_entry_13: local_char?<generic>>:
     eeb:	push   rbp
     eec:	mov    rbp,rsp
     eef:	mov    rsi,QWORD PTR [rdx]
     ef2:	call   ef7 <botlish_entry_13+0xc>
			ef3: R_X86_64_PLT32	botlish_fn_13-0x4 ; local_char?<generic>
     ef7:	mov    rsp,rbp
     efa:	pop    rbp
     efb:	ret

0000000000000efc <botlish_fn_14: scan_while<int, block(e276)>>:
     efc:	push   rbp
     efd:	mov    rbp,rsp
     f00:	sub    rsp,0x50
     f04:	mov    QWORD PTR [rsp+0x20],rbx
     f09:	mov    QWORD PTR [rsp+0x28],r12
     f0e:	mov    QWORD PTR [rsp+0x30],r13
     f13:	mov    QWORD PTR [rsp+0x38],r14
     f18:	mov    QWORD PTR [rsp+0x40],r15
     f1d:	mov    QWORD PTR [rsp+0x18],rdi
     f22:	mov    QWORD PTR [rsp],rcx
     f26:	mov    QWORD PTR [rsp+0x8],r8
     f2b:	mov    r15,r8
     f2e:	mov    r12,rcx
     f31:	sar    r12,1
     f34:	mov    r14,rcx
     f37:	mov    rbx,rsi
     f3a:	cmp    rbx,r12
     f3d:	jl     f68 <botlish_fn_14+0x6c>
     f43:	mov    rax,r14
     f46:	mov    rbx,QWORD PTR [rsp+0x20]
     f4b:	mov    r12,QWORD PTR [rsp+0x28]
     f50:	mov    r13,QWORD PTR [rsp+0x30]
     f55:	mov    r14,QWORD PTR [rsp+0x38]
     f5a:	mov    r15,QWORD PTR [rsp+0x40]
     f5f:	add    rsp,0x50
     f63:	mov    rsp,rbp
     f66:	pop    rbp
     f67:	ret
     f68:	mov    r13,rbx
     f6b:	shl    r13,1
     f6e:	or     r13,0x1
     f72:	mov    QWORD PTR [rsp+0x10],r13
     f77:	mov    rcx,r15
     f7a:	mov    rdx,r14
     f7d:	mov    rsi,r13
     f80:	mov    rdi,QWORD PTR [rsp+0x18]
     f85:	call   f8a <botlish_fn_14+0x8e>
			f86: R_X86_64_PLT32	botlish_fn_9-0x4 ; char_at<int>
     f8a:	mov    rsi,rax
     f8d:	mov    rdi,QWORD PTR [rsp+0x18]
     f92:	call   f97 <botlish_fn_14+0x9b>
			f93: R_X86_64_PLT32	botlish_fn_12-0x4 ; local_char?<str>
     f97:	test   rax,rax
     f9a:	jne    fc5 <botlish_fn_14+0xc9>
     fa0:	xor    rax,rax
     fa3:	mov    rbx,QWORD PTR [rsp+0x20]
     fa8:	mov    r12,QWORD PTR [rsp+0x28]
     fad:	mov    r13,QWORD PTR [rsp+0x30]
     fb2:	mov    r14,QWORD PTR [rsp+0x38]
     fb7:	mov    r15,QWORD PTR [rsp+0x40]
     fbc:	add    rsp,0x50
     fc0:	mov    rsp,rbp
     fc3:	pop    rbp
     fc4:	ret
     fc5:	cmp    rax,0x6
     fc9:	je     ff4 <botlish_fn_14+0xf8>
     fcf:	mov    rax,r13
     fd2:	mov    rbx,QWORD PTR [rsp+0x20]
     fd7:	mov    r12,QWORD PTR [rsp+0x28]
     fdc:	mov    r13,QWORD PTR [rsp+0x30]
     fe1:	mov    r14,QWORD PTR [rsp+0x38]
     fe6:	mov    r15,QWORD PTR [rsp+0x40]
     feb:	add    rsp,0x50
     fef:	mov    rsp,rbp
     ff2:	pop    rbp
     ff3:	ret
     ff4:	add    rbx,0x1
     ffb:	jmp    f3a <botlish_fn_14+0x3e>

0000000000001000 <botlish_entry_14: scan_while<int, block(e276)>>:
    1000:	push   rbp
    1001:	mov    rbp,rsp
    1004:	mov    rsi,QWORD PTR [rdx]
    1007:	mov    r9,QWORD PTR [rdx+0x8]
    100b:	mov    rcx,QWORD PTR [rdx+0x10]
    100f:	mov    r8,QWORD PTR [rdx+0x18]
    1013:	sar    rsi,1
    1016:	mov    rdx,r9
    1019:	call   101e <botlish_entry_14+0x1e>
			101a: R_X86_64_PLT32	botlish_fn_14-0x4 ; scan_while<int, block(e276)>
    101e:	mov    rsp,rbp
    1021:	pop    rbp
    1022:	ret

0000000000001023 <botlish_fn_15: scan_while<int, native(str::is_tcl_alpha)>>:
    1023:	push   rbp
    1024:	mov    rbp,rsp
    1027:	sub    rsp,0x40
    102b:	mov    QWORD PTR [rsp+0x10],rbx
    1030:	mov    QWORD PTR [rsp+0x18],r12
    1035:	mov    QWORD PTR [rsp+0x20],r13
    103a:	mov    QWORD PTR [rsp+0x28],r14
    103f:	mov    QWORD PTR [rsp+0x30],r15
    1044:	mov    rbx,r8
    1047:	mov    r13,rdi
    104a:	mov    rax,rcx
    104d:	sar    rax,1
    1050:	mov    r12,rcx
    1053:	mov    r14,rax
    1056:	mov    rax,rsi
    1059:	mov    rcx,r14
    105c:	cmp    rax,rcx
    105f:	mov    r14,rcx
    1062:	jl     1092 <botlish_fn_15+0x6f>
    1068:	mov    edx,0x1
    106d:	mov    rax,r14
    1070:	mov    rbx,QWORD PTR [rsp+0x10]
    1075:	mov    r12,QWORD PTR [rsp+0x18]
    107a:	mov    r13,QWORD PTR [rsp+0x20]
    107f:	mov    r14,QWORD PTR [rsp+0x28]
    1084:	mov    r15,QWORD PTR [rsp+0x30]
    1089:	add    rsp,0x40
    108d:	mov    rsp,rbp
    1090:	pop    rbp
    1091:	ret
    1092:	mov    rsi,rax
    1095:	shl    rsi,1
    1098:	mov    r15,rax
    109b:	or     rsi,0x1
    109f:	lea    r8,[rsp]
    10a3:	mov    rcx,rbx
    10a6:	mov    rdx,r12
    10a9:	mov    rdi,r13
    10ac:	call   10b1 <botlish_fn_15+0x8e>
			10ad: R_X86_64_PLT32	botlish_fn_10-0x4 ; char_at<int>
    10b1:	mov    rdx,QWORD PTR [rsp]
    10b5:	mov    rcx,QWORD PTR [rsp+0x8]
    10ba:	mov    rsi,rax
    10bd:	mov    rdi,r13
    10c0:	call   10c5 <botlish_fn_15+0xa2>
			10c1: R_X86_64_PLT32	rt_str_region_is_tcl_alpha-0x4
    10c5:	test   rax,rax
    10c8:	jne    10f6 <botlish_fn_15+0xd3>
    10ce:	xor    rdx,rdx
    10d1:	mov    rax,rdx
    10d4:	mov    rbx,QWORD PTR [rsp+0x10]
    10d9:	mov    r12,QWORD PTR [rsp+0x18]
    10de:	mov    r13,QWORD PTR [rsp+0x20]
    10e3:	mov    r14,QWORD PTR [rsp+0x28]
    10e8:	mov    r15,QWORD PTR [rsp+0x30]
    10ed:	add    rsp,0x40
    10f1:	mov    rsp,rbp
    10f4:	pop    rbp
    10f5:	ret
    10f6:	cmp    rax,0x6
    10fa:	je     112a <botlish_fn_15+0x107>
    1100:	mov    edx,0x1
    1105:	mov    rax,r15
    1108:	mov    rbx,QWORD PTR [rsp+0x10]
    110d:	mov    r12,QWORD PTR [rsp+0x18]
    1112:	mov    r13,QWORD PTR [rsp+0x20]
    1117:	mov    r14,QWORD PTR [rsp+0x28]
    111c:	mov    r15,QWORD PTR [rsp+0x30]
    1121:	add    rsp,0x40
    1125:	mov    rsp,rbp
    1128:	pop    rbp
    1129:	ret
    112a:	mov    rax,r15
    112d:	add    rax,0x1
    1134:	mov    rcx,r14
    1137:	jmp    105c <botlish_fn_15+0x39>

000000000000113c <botlish_entry_15: scan_while<int, native(str::is_tcl_alpha)>>:
    113c:	push   rbp
    113d:	mov    rbp,rsp
    1140:	mov    rsi,QWORD PTR [rdx]
    1143:	mov    rax,QWORD PTR [rdx+0x8]
    1147:	mov    rcx,QWORD PTR [rdx+0x10]
    114b:	mov    r8,QWORD PTR [rdx+0x18]
    114f:	sar    rsi,1
    1152:	mov    rdx,rax
    1155:	call   115a <botlish_entry_15+0x1e>
			1156: R_X86_64_PLT32	botlish_fn_15-0x4 ; scan_while<int, native(str::is_tcl_alpha)>
    115a:	shl    rax,1
    115d:	or     rax,0x1
    1161:	mov    rcx,rax
    1164:	xor    rax,rax
    1167:	test   rdx,rdx
    116a:	cmovne rax,rcx
    116e:	mov    rsp,rbp
    1171:	pop    rbp
    1172:	ret
    1173:	add    BYTE PTR [rax],al
    1175:	add    BYTE PTR [rax],al
	...

0000000000001178 <botlish_fn_16: tld?<int>>:
    1178:	push   rbp
    1179:	mov    rbp,rsp
    117c:	sub    rsp,0x10
    1180:	mov    QWORD PTR [rsp],rbx
    1184:	mov    QWORD PTR [rsp+0x8],r12
    1189:	mov    r8,rdx
    118c:	mov    rax,QWORD PTR [rdi+0x10]
    1190:	mov    rdx,QWORD PTR [rax+0xd0]
    1197:	mov    r12,r8
    119a:	mov    r8,rcx
    119d:	mov    rbx,rsi
    11a0:	mov    rcx,r12
    11a3:	call   11a8 <botlish_fn_16+0x30>
			11a4: R_X86_64_PLT32	botlish_fn_15-0x4 ; scan_while<int, native(str::is_tcl_alpha)>
    11a8:	test   rdx,rdx
    11ab:	jne    11c6 <botlish_fn_16+0x4e>
    11b1:	xor    rax,rax
    11b4:	mov    rbx,QWORD PTR [rsp]
    11b8:	mov    r12,QWORD PTR [rsp+0x8]
    11bd:	add    rsp,0x10
    11c1:	mov    rsp,rbp
    11c4:	pop    rbp
    11c5:	ret
    11c6:	sar    r12,1
    11c9:	cmp    rax,r12
    11cc:	je     11dc <botlish_fn_16+0x64>
    11d2:	mov    eax,0x2
    11d7:	jmp    11f3 <botlish_fn_16+0x7b>
    11dc:	sub    rax,rbx
    11df:	mov    rcx,rax
    11e2:	mov    eax,0x2
    11e7:	cmp    rcx,0x2
    11eb:	cmovge rax,QWORD PTR [rip+0x15]        # 1208 <botlish_fn_16+0x90>
    11f3:	mov    rbx,QWORD PTR [rsp]
    11f7:	mov    r12,QWORD PTR [rsp+0x8]
    11fc:	add    rsp,0x10
    1200:	mov    rsp,rbp
    1203:	pop    rbp
    1204:	ret
    1205:	add    BYTE PTR [rax],al
    1207:	add    BYTE PTR [rsi],al
    1209:	add    BYTE PTR [rax],al
    120b:	add    BYTE PTR [rax],al
    120d:	add    BYTE PTR [rax],al
	...

0000000000001210 <botlish_entry_16: tld?<int>>:
    1210:	push   rbp
    1211:	mov    rbp,rsp
    1214:	mov    rsi,QWORD PTR [rdx]
    1217:	mov    r8,QWORD PTR [rdx+0x8]
    121b:	mov    rcx,QWORD PTR [rdx+0x10]
    121f:	sar    rsi,1
    1222:	mov    rdx,r8
    1225:	call   122a <botlish_entry_16+0x1a>
			1226: R_X86_64_PLT32	botlish_fn_16-0x4 ; tld?<int>
    122a:	mov    rsp,rbp
    122d:	pop    rbp
    122e:	ret

000000000000122f <botlish_fn_17: domain?<int>>:
    122f:	push   rbp
    1230:	mov    rbp,rsp
    1233:	sub    rsp,0x60
    1237:	mov    QWORD PTR [rsp+0x30],rbx
    123c:	mov    QWORD PTR [rsp+0x38],r12
    1241:	mov    QWORD PTR [rsp+0x40],r13
    1246:	mov    QWORD PTR [rsp+0x48],r14
    124b:	mov    QWORD PTR [rsp+0x50],r15
    1250:	mov    r13,rsi
    1253:	mov    r15,rcx
    1256:	mov    r14,rdx
    1259:	sar    r14,1
    125c:	mov    QWORD PTR [rsp+0x10],rdx
    1261:	mov    r12,r13
    1264:	cmp    r12,r14
    1267:	jge    13d3 <botlish_fn_17+0x1a4>
    126d:	mov    rsi,r12
    1270:	shl    rsi,1
    1273:	or     rsi,0x1
    1277:	mov    QWORD PTR [rsp+0x28],rsi
    127c:	mov    edx,0x174
    1281:	mov    rbx,rdi
    1284:	mov    rcx,QWORD PTR [rsp+0x10]
    1289:	mov    r8,r15
    128c:	call   1291 <botlish_fn_17+0x62>
			128d: R_X86_64_PLT32	botlish_fn_11-0x4 ; char_is?<int, any>
    1291:	cmp    rax,0x6
    1295:	je     131a <botlish_fn_17+0xeb>
    129b:	lea    r8,[rsp]
    129f:	mov    rsi,QWORD PTR [rsp+0x28]
    12a4:	mov    rcx,r15
    12a7:	mov    rdx,QWORD PTR [rsp+0x10]
    12ac:	mov    rdi,rbx
    12af:	call   12b4 <botlish_fn_17+0x85>
			12b0: R_X86_64_PLT32	botlish_fn_10-0x4 ; char_at<int>
    12b4:	mov    QWORD PTR [rsp+0x28],rax
    12b9:	mov    rdx,QWORD PTR [rsp]
    12bd:	mov    QWORD PTR [rsp+0x20],rdx
    12c2:	mov    rcx,QWORD PTR [rsp+0x8]
    12c7:	mov    QWORD PTR [rsp+0x18],rcx
    12cc:	mov    rsi,QWORD PTR [rsp+0x28]
    12d1:	mov    rdi,rbx
    12d4:	call   12d9 <botlish_fn_17+0xaa>
			12d5: R_X86_64_PLT32	rt_str_region_is_tcl_alnum-0x4
    12d9:	test   rax,rax
    12dc:	je     136e <botlish_fn_17+0x13f>
    12e2:	cmp    rax,0x6
    12e6:	je     139d <botlish_fn_17+0x16e>
    12ec:	mov    rax,QWORD PTR [rbx+0x10]
    12f0:	mov    r8,QWORD PTR [rax+0x20]
    12f4:	mov    rcx,QWORD PTR [rsp+0x18]
    12f9:	mov    rdx,QWORD PTR [rsp+0x20]
    12fe:	mov    rsi,QWORD PTR [rsp+0x28]
    1303:	mov    rdi,rbx
    1306:	call   130b <botlish_fn_17+0xdc>
			1307: R_X86_64_PLT32	rt_str_region_eq-0x4
    130b:	cmp    rax,0x6
    130f:	jne    13d3 <botlish_fn_17+0x1a4>
    1315:	jmp    139d <botlish_fn_17+0x16e>
    131a:	cmp    r12,r13
    131d:	je     13d3 <botlish_fn_17+0x1a4>
    1323:	mov    rsi,r12
    1326:	sub    rsi,0x1
    132a:	shl    rsi,1
    132d:	or     rsi,0x1
    1331:	mov    edx,0x174
    1336:	mov    rcx,QWORD PTR [rsp+0x10]
    133b:	mov    rdi,rbx
    133e:	mov    r8,r15
    1341:	call   1346 <botlish_fn_17+0x117>
			1342: R_X86_64_PLT32	botlish_fn_11-0x4 ; char_is?<int, any>
    1346:	cmp    rax,0x6
    134a:	je     13d3 <botlish_fn_17+0x1a4>
    1350:	lea    rsi,[r12+0x1]
    1355:	mov    rcx,r15
    1358:	mov    rdx,QWORD PTR [rsp+0x10]
    135d:	mov    rdi,rbx
    1360:	call   1365 <botlish_fn_17+0x136>
			1361: R_X86_64_PLT32	botlish_fn_16-0x4 ; tld?<int>
    1365:	test   rax,rax
    1368:	jne    1393 <botlish_fn_17+0x164>
    136e:	xor    rax,rax
    1371:	mov    rbx,QWORD PTR [rsp+0x30]
    1376:	mov    r12,QWORD PTR [rsp+0x38]
    137b:	mov    r13,QWORD PTR [rsp+0x40]
    1380:	mov    r14,QWORD PTR [rsp+0x48]
    1385:	mov    r15,QWORD PTR [rsp+0x50]
    138a:	add    rsp,0x60
    138e:	mov    rsp,rbp
    1391:	pop    rbp
    1392:	ret
    1393:	cmp    rax,0x6
    1397:	je     13ac <botlish_fn_17+0x17d>
    139d:	add    r12,0x1
    13a4:	mov    rdi,rbx
    13a7:	jmp    1264 <botlish_fn_17+0x35>
    13ac:	mov    eax,0x6
    13b1:	mov    rbx,QWORD PTR [rsp+0x30]
    13b6:	mov    r12,QWORD PTR [rsp+0x38]
    13bb:	mov    r13,QWORD PTR [rsp+0x40]
    13c0:	mov    r14,QWORD PTR [rsp+0x48]
    13c5:	mov    r15,QWORD PTR [rsp+0x50]
    13ca:	add    rsp,0x60
    13ce:	mov    rsp,rbp
    13d1:	pop    rbp
    13d2:	ret
    13d3:	mov    eax,0x2
    13d8:	mov    rbx,QWORD PTR [rsp+0x30]
    13dd:	mov    r12,QWORD PTR [rsp+0x38]
    13e2:	mov    r13,QWORD PTR [rsp+0x40]
    13e7:	mov    r14,QWORD PTR [rsp+0x48]
    13ec:	mov    r15,QWORD PTR [rsp+0x50]
    13f1:	add    rsp,0x60
    13f5:	mov    rsp,rbp
    13f8:	pop    rbp
    13f9:	ret

00000000000013fa <botlish_entry_17: domain?<int>>:
    13fa:	push   rbp
    13fb:	mov    rbp,rsp
    13fe:	mov    rsi,QWORD PTR [rdx]
    1401:	mov    r8,QWORD PTR [rdx+0x8]
    1405:	mov    rcx,QWORD PTR [rdx+0x10]
    1409:	sar    rsi,1
    140c:	mov    rdx,r8
    140f:	call   1414 <botlish_entry_17+0x1a>
			1410: R_X86_64_PLT32	botlish_fn_17-0x4 ; domain?<int>
    1414:	mov    rsp,rbp
    1417:	pop    rbp
    1418:	ret

0000000000001419 <botlish_fn_18: web::is_unreserved<int>>:
    1419:	push   rbp
    141a:	mov    rbp,rsp
    141d:	sub    rsp,0x10
    1421:	mov    QWORD PTR [rsp],rbx
    1425:	mov    QWORD PTR [rsp+0x8],r14
    142a:	mov    r14,rsi
    142d:	mov    rsi,r14
    1430:	sar    rsi,1
    1433:	mov    rbx,rdi
    1436:	call   143b <botlish_fn_18+0x22>
			1437: R_X86_64_PLT32	botlish_fn_7-0x4 ; ascii::is_alphanumeric<int>
    143b:	cmp    rax,0x6
    143f:	je     1476 <botlish_fn_18+0x5d>
    1445:	mov    rax,QWORD PTR [rbx+0x30]
    1449:	mov    rsi,QWORD PTR [rax+0x10]
    144d:	mov    rdx,r14
    1450:	mov    rdi,rbx
    1453:	call   1458 <botlish_fn_18+0x3f>
			1454: R_X86_64_PLT32	rt_set_contains-0x4
    1458:	cmp    rax,0x6
    145c:	je     146c <botlish_fn_18+0x53>
    1462:	mov    eax,0x2
    1467:	jmp    147b <botlish_fn_18+0x62>
    146c:	mov    eax,0x6
    1471:	jmp    147b <botlish_fn_18+0x62>
    1476:	mov    eax,0x6
    147b:	mov    rbx,QWORD PTR [rsp]
    147f:	mov    r14,QWORD PTR [rsp+0x8]
    1484:	add    rsp,0x10
    1488:	mov    rsp,rbp
    148b:	pop    rbp
    148c:	ret

000000000000148d <botlish_entry_18: web::is_unreserved<int>>:
    148d:	push   rbp
    148e:	mov    rbp,rsp
    1491:	mov    rsi,QWORD PTR [rdx]
    1494:	call   1499 <botlish_entry_18+0xc>
			1495: R_X86_64_PLT32	botlish_fn_18-0x4 ; web::is_unreserved<int>
    1499:	mov    rsp,rbp
    149c:	pop    rbp
    149d:	ret

000000000000149e <botlish_fn_19: web::uri_query_value?<str>>:
    149e:	push   rbp
    149f:	mov    rbp,rsp
    14a2:	sub    rsp,0x10
    14a6:	mov    QWORD PTR [rsp],rsi
    14aa:	mov    rdx,rsi
    14ad:	mov    esi,0x1
    14b2:	mov    QWORD PTR [rsp+0x8],0x1
    14bb:	call   14c0 <botlish_fn_19+0x22>
			14bc: R_X86_64_PLT32	botlish_fn_21-0x4 ; valid_from?<int>
    14c0:	add    rsp,0x10
    14c4:	mov    rsp,rbp
    14c7:	pop    rbp
    14c8:	ret

00000000000014c9 <botlish_entry_19: web::uri_query_value?<str>>:
    14c9:	push   rbp
    14ca:	mov    rbp,rsp
    14cd:	mov    rsi,QWORD PTR [rdx]
    14d0:	call   14d5 <botlish_entry_19+0xc>
			14d1: R_X86_64_PLT32	botlish_fn_19-0x4 ; web::uri_query_value?<str>
    14d5:	mov    rsp,rbp
    14d8:	pop    rbp
    14d9:	ret
    14da:	add    BYTE PTR [rax],al
    14dc:	add    BYTE PTR [rax],al
	...

00000000000014e0 <botlish_fn_20: upper_hex?<int>>:
    14e0:	push   rbp
    14e1:	mov    rbp,rsp
    14e4:	sub    rsp,0x20
    14e8:	mov    QWORD PTR [rsp],rbx
    14ec:	mov    QWORD PTR [rsp+0x8],r12
    14f1:	mov    QWORD PTR [rsp+0x10],r13
    14f6:	mov    r12,rdi
    14f9:	mov    r13,rdx
    14fc:	mov    rdx,r13
    14ff:	mov    rdx,QWORD PTR [rdx+0x8]
    1503:	shl    rdx,1
    1506:	mov    rax,rdx
    1509:	or     rax,0x1
    150d:	mov    rcx,rsi
    1510:	and    rcx,rax
    1513:	test   rcx,0x1
    151a:	jne    1547 <botlish_fn_20+0x67>
    1520:	or     rdx,0x1
    1524:	mov    rbx,rsi
    1527:	mov    rdi,r12
    152a:	call   152f <botlish_fn_20+0x4f>
			152b: R_X86_64_PLT32	rt_int_cmp-0x4
    152f:	mov    ecx,0x2
    1534:	test   rax,rax
    1537:	cmovge rcx,QWORD PTR [rip+0x121]        # 1660 <botlish_fn_20+0x180>
    153f:	mov    rsi,rbx
    1542:	jmp    155e <botlish_fn_20+0x7e>
    1547:	mov    rbx,rsi
    154a:	or     rdx,0x1
    154e:	mov    ecx,0x2
    1553:	cmp    rbx,rdx
    1556:	cmovge rcx,QWORD PTR [rip+0x102]        # 1660 <botlish_fn_20+0x180>
    155e:	mov    eax,0x6
    1563:	mov    rbx,rax
    1566:	cmp    rcx,0x6
    156a:	je     163e <botlish_fn_20+0x15e>
    1570:	mov    rdx,r13
    1573:	movzx  rax,BYTE PTR [rdx+0x18]
    1578:	test   rax,rax
    157b:	jne    1594 <botlish_fn_20+0xb4>
    1581:	mov    rdx,rsi
    1584:	mov    rsi,r13
    1587:	mov    rdi,r12
    158a:	call   158f <botlish_fn_20+0xaf>
			158b: R_X86_64_PLT32	rt_str_char_at_proven-0x4
    158f:	jmp    15ae <botlish_fn_20+0xce>
    1594:	mov    rdx,rsi
    1597:	mov    rsi,r13
    159a:	mov    rax,rdx
    159d:	sar    rax,1
    15a0:	movzx  rax,BYTE PTR [rsi+rax*1+0x19]
    15a6:	shl    rax,0x3
    15aa:	or     rax,0x4
    15ae:	mov    rcx,rax
    15b1:	shr    rcx,0x3
    15b5:	shl    rcx,1
    15b8:	or     rcx,0x1
    15bc:	mov    edx,0x2
    15c1:	cmp    rcx,0xff
    15c8:	cmovle rdx,QWORD PTR [rip+0x90]        # 1660 <botlish_fn_20+0x180>
    15d0:	cmp    rdx,0x6
    15d4:	je     15e7 <botlish_fn_20+0x107>
    15da:	mov    eax,0x2
    15df:	mov    rbx,rax
    15e2:	jmp    1643 <botlish_fn_20+0x163>
    15e7:	shr    rax,0x3
    15eb:	shl    rax,1
    15ee:	or     rax,0x1
    15f2:	sar    rax,1
    15f5:	mov    rdi,r12
    15f8:	mov    r13,rax
    15fb:	mov    rsi,r13
    15fe:	call   1603 <botlish_fn_20+0x123>
			15ff: R_X86_64_PLT32	botlish_fn_3-0x4 ; ascii::is_digit<int>
    1603:	cmp    rax,0x6
    1607:	jne    1615 <botlish_fn_20+0x135>
    160d:	mov    rax,rbx
    1610:	jmp    1643 <botlish_fn_20+0x163>
    1615:	mov    rax,r13
    1618:	cmp    rax,0x41
    161c:	jl     1634 <botlish_fn_20+0x154>
    1622:	cmp    rax,0x46
    1626:	jg     1634 <botlish_fn_20+0x154>
    162c:	mov    rax,rbx
    162f:	jmp    1643 <botlish_fn_20+0x163>
    1634:	mov    eax,0x2
    1639:	jmp    1643 <botlish_fn_20+0x163>
    163e:	mov    eax,0x2
    1643:	mov    rbx,QWORD PTR [rsp]
    1647:	mov    r12,QWORD PTR [rsp+0x8]
    164c:	mov    r13,QWORD PTR [rsp+0x10]
    1651:	add    rsp,0x20
    1655:	mov    rsp,rbp
    1658:	pop    rbp
    1659:	ret
    165a:	add    BYTE PTR [rax],al
    165c:	add    BYTE PTR [rax],al
    165e:	add    BYTE PTR [rax],al
    1660:	(bad)
    1661:	add    BYTE PTR [rax],al
    1663:	add    BYTE PTR [rax],al
    1665:	add    BYTE PTR [rax],al
	...

0000000000001668 <botlish_entry_20: upper_hex?<int>>:
    1668:	push   rbp
    1669:	mov    rbp,rsp
    166c:	mov    rsi,QWORD PTR [rdx]
    166f:	mov    rdx,QWORD PTR [rdx+0x8]
    1673:	call   1678 <botlish_entry_20+0x10>
			1674: R_X86_64_PLT32	botlish_fn_20-0x4 ; upper_hex?<int>
    1678:	mov    rsp,rbp
    167b:	pop    rbp
    167c:	ret
    167d:	add    BYTE PTR [rax],al
	...

0000000000001680 <botlish_fn_21: valid_from?<int>>:
    1680:	push   rbp
    1681:	mov    rbp,rsp
    1684:	sub    rsp,0x40
    1688:	mov    QWORD PTR [rsp+0x20],rbx
    168d:	mov    QWORD PTR [rsp+0x28],r12
    1692:	mov    QWORD PTR [rsp+0x30],r13
    1697:	mov    r12,rdi
    169a:	mov    QWORD PTR [rsp],rsi
    169e:	mov    r13,rsi
    16a1:	mov    QWORD PTR [rsp+0x8],rdx
    16a6:	mov    rbx,rdx
    16a9:	mov    rdx,QWORD PTR [rbx+0x8]
    16ad:	shl    rdx,1
    16b0:	or     rdx,0x1
    16b4:	mov    rsi,r13
    16b7:	mov    rax,rsi
    16ba:	and    rax,rdx
    16bd:	test   rax,0x1
    16c3:	jne    16e9 <botlish_fn_21+0x69>
    16c9:	mov    rsi,r13
    16cc:	mov    rdi,r12
    16cf:	call   16d4 <botlish_fn_21+0x54>
			16d0: R_X86_64_PLT32	rt_int_cmp-0x4
    16d4:	mov    ecx,0x2
    16d9:	test   rax,rax
    16dc:	cmovge rcx,QWORD PTR [rip+0x1f4]        # 18d8 <botlish_fn_21+0x258>
    16e4:	jmp    16fc <botlish_fn_21+0x7c>
    16e9:	mov    ecx,0x2
    16ee:	mov    rsi,r13
    16f1:	cmp    rsi,rdx
    16f4:	cmovge rcx,QWORD PTR [rip+0x1dc]        # 18d8 <botlish_fn_21+0x258>
    16fc:	cmp    rcx,0x6
    1700:	je     18b8 <botlish_fn_21+0x238>
    1706:	movzx  rdx,BYTE PTR [rbx+0x18]
    170b:	test   rdx,rdx
    170e:	jne    172a <botlish_fn_21+0xaa>
    1714:	mov    rdx,r13
    1717:	mov    rsi,rbx
    171a:	mov    rdi,r12
    171d:	call   1722 <botlish_fn_21+0xa2>
			171e: R_X86_64_PLT32	rt_str_char_at_proven-0x4
    1722:	mov    rsi,rax
    1725:	jmp    173e <botlish_fn_21+0xbe>
    172a:	mov    rsi,r13
    172d:	sar    rsi,1
    1730:	movzx  rsi,BYTE PTR [rbx+rsi*1+0x19]
    1736:	shl    rsi,0x3
    173a:	or     rsi,0x4
    173e:	cmp    rsi,0x12c
    1745:	je     17c2 <botlish_fn_21+0x142>
    174b:	mov    rdi,rsi
    174e:	shr    rdi,0x3
    1752:	shl    rdi,1
    1755:	or     rdi,0x1
    1759:	mov    ecx,0x2
    175e:	cmp    rdi,0xff
    1765:	cmovle rcx,QWORD PTR [rip+0x16b]        # 18d8 <botlish_fn_21+0x258>
    176d:	cmp    rcx,0x6
    1771:	jne    183e <botlish_fn_21+0x1be>
    1777:	shr    rsi,0x3
    177b:	shl    rsi,1
    177e:	or     rsi,0x1
    1782:	mov    rdi,r12
    1785:	call   178a <botlish_fn_21+0x10a>
			1786: R_X86_64_PLT32	botlish_fn_18-0x4 ; web::is_unreserved<int>
    178a:	cmp    rax,0x6
    178e:	jne    183e <botlish_fn_21+0x1be>
    1794:	mov    rsi,r13
    1797:	sar    rsi,1
    179a:	mov    r13,rsi
    179d:	add    rsi,0x1
    17a4:	mov    r13,rsi
    17a7:	shl    rsi,1
    17aa:	mov    r13,rsi
    17ad:	or     rsi,0x1
    17b1:	mov    r13,rsi
    17b4:	mov    QWORD PTR [rsp],rsi
    17b8:	mov    QWORD PTR [rsp+0x8],rbx
    17bd:	jmp    16a9 <botlish_fn_21+0x29>
    17c2:	mov    rsi,r13
    17c5:	mov    rax,rsi
    17c8:	sar    rax,1
    17cb:	lea    rsi,[rax+0x1]
    17cf:	shl    rsi,1
    17d2:	or     rsi,0x1
    17d6:	mov    rdx,rbx
    17d9:	mov    rdi,r12
    17dc:	call   17e1 <botlish_fn_21+0x161>
			17dd: R_X86_64_PLT32	botlish_fn_20-0x4 ; upper_hex?<int>
    17e1:	cmp    rax,0x6
    17e5:	jne    183e <botlish_fn_21+0x1be>
    17eb:	mov    QWORD PTR [rsp+0x10],0x5
    17f4:	mov    rsi,r13
    17f7:	test   rsi,0x1
    17fe:	je     1816 <botlish_fn_21+0x196>
    1804:	mov    rsi,r13
    1807:	add    rsi,0x4
    180b:	seto   al
    180e:	test   al,al
    1810:	je     1829 <botlish_fn_21+0x1a9>
    1816:	mov    edx,0x5
    181b:	mov    rsi,r13
    181e:	mov    rdi,r12
    1821:	call   1826 <botlish_fn_21+0x1a6>
			1822: R_X86_64_PLT32	rt_int_add-0x4
    1826:	mov    rsi,rax
    1829:	mov    rdx,rbx
    182c:	mov    rdi,r12
    182f:	call   1834 <botlish_fn_21+0x1b4>
			1830: R_X86_64_PLT32	botlish_fn_20-0x4 ; upper_hex?<int>
    1834:	cmp    rax,0x6
    1838:	je     185b <botlish_fn_21+0x1db>
    183e:	mov    eax,0x2
    1843:	mov    rbx,QWORD PTR [rsp+0x20]
    1848:	mov    r12,QWORD PTR [rsp+0x28]
    184d:	mov    r13,QWORD PTR [rsp+0x30]
    1852:	add    rsp,0x40
    1856:	mov    rsp,rbp
    1859:	pop    rbp
    185a:	ret
    185b:	mov    QWORD PTR [rsp+0x10],0x7
    1864:	mov    rsi,r13
    1867:	test   rsi,0x1
    186e:	je     1894 <botlish_fn_21+0x214>
    1874:	mov    rsi,r13
    1877:	mov    rcx,rsi
    187a:	add    rcx,0x6
    187e:	seto   al
    1881:	test   al,al
    1883:	jne    1894 <botlish_fn_21+0x214>
    1889:	mov    rsi,rcx
    188c:	mov    r13,rcx
    188f:	jmp    18aa <botlish_fn_21+0x22a>
    1894:	mov    edx,0x7
    1899:	mov    rsi,r13
    189c:	mov    rdi,r12
    189f:	call   18a4 <botlish_fn_21+0x224>
			18a0: R_X86_64_PLT32	rt_int_add-0x4
    18a4:	mov    rsi,rax
    18a7:	mov    r13,rax
    18aa:	mov    QWORD PTR [rsp],rsi
    18ae:	mov    QWORD PTR [rsp+0x8],rbx
    18b3:	jmp    16a9 <botlish_fn_21+0x29>
    18b8:	mov    eax,0x6
    18bd:	mov    rbx,QWORD PTR [rsp+0x20]
    18c2:	mov    r12,QWORD PTR [rsp+0x28]
    18c7:	mov    r13,QWORD PTR [rsp+0x30]
    18cc:	add    rsp,0x40
    18d0:	mov    rsp,rbp
    18d3:	pop    rbp
    18d4:	ret
    18d5:	add    BYTE PTR [rax],al
    18d7:	add    BYTE PTR [rsi],al
    18d9:	add    BYTE PTR [rax],al
    18db:	add    BYTE PTR [rax],al
    18dd:	add    BYTE PTR [rax],al
	...

00000000000018e0 <botlish_entry_21: valid_from?<int>>:
    18e0:	push   rbp
    18e1:	mov    rbp,rsp
    18e4:	mov    rsi,QWORD PTR [rdx]
    18e7:	mov    rdx,QWORD PTR [rdx+0x8]
    18eb:	call   18f0 <botlish_entry_21+0x10>
			18ec: R_X86_64_PLT32	botlish_fn_21-0x4 ; valid_from?<int>
    18f0:	mov    rsp,rbp
    18f3:	pop    rbp
    18f4:	ret

00000000000018f5 <botlish_fn_22: web::uri_escape_text<str>>:
    18f5:	push   rbp
    18f6:	mov    rbp,rsp
    18f9:	sub    rsp,0x10
    18fd:	mov    edx,0x1
    1902:	mov    QWORD PTR [rsp],0x1
    190a:	mov    r10,QWORD PTR [rdi+0x10]
    190e:	mov    rcx,QWORD PTR [r10+0xc8]
    1915:	mov    QWORD PTR [rsp+0x8],rcx
    191a:	call   191f <botlish_fn_22+0x2a>
			191b: R_X86_64_PLT32	botlish_fn_28-0x4 ; esc_from<str, int, str>
    191f:	test   rax,rax
    1922:	jne    1934 <botlish_fn_22+0x3f>
    1928:	xor    rax,rax
    192b:	add    rsp,0x10
    192f:	mov    rsp,rbp
    1932:	pop    rbp
    1933:	ret
    1934:	add    rsp,0x10
    1938:	mov    rsp,rbp
    193b:	pop    rbp
    193c:	ret

000000000000193d <botlish_entry_22: web::uri_escape_text<str>>:
    193d:	push   rbp
    193e:	mov    rbp,rsp
    1941:	sub    rsp,0x10
    1945:	mov    QWORD PTR [rsp],r12
    1949:	mov    r12,rdi
    194c:	mov    rsi,QWORD PTR [rdx]
    194f:	mov    r8,QWORD PTR [rip+0x0]        # 1956 <botlish_entry_22+0x19>
			1952: R_X86_64_GOTPCREL	rt_str_to_ascii-0x4
    1956:	call   r8
    1959:	mov    rsi,rax
    195c:	mov    rdi,r12
    195f:	call   1964 <botlish_entry_22+0x27>
			1960: R_X86_64_PLT32	botlish_fn_22-0x4 ; web::uri_escape_text<str>
    1964:	mov    r12,QWORD PTR [rsp]
    1968:	add    rsp,0x10
    196c:	mov    rsp,rbp
    196f:	pop    rbp
    1970:	ret

0000000000001971 <botlish_fn_23: high_nibble<int>>:
    1971:	push   rbp
    1972:	mov    rbp,rsp
    1975:	sub    rsp,0x10
    1979:	mov    QWORD PTR [rsp],rsi
    197d:	mov    QWORD PTR [rsp+0x8],0x1e1
    1986:	test   rsi,0x1
    198d:	jne    19a2 <botlish_fn_23+0x31>
    1993:	mov    edx,0x1e1
    1998:	call   199d <botlish_fn_23+0x2c>
			1999: R_X86_64_PLT32	rt_int_and-0x4
    199d:	jmp    19ac <botlish_fn_23+0x3b>
    19a2:	and    rsi,0x1e1
    19a9:	mov    rax,rsi
    19ac:	sar    rax,0x5
    19b0:	shl    rax,1
    19b3:	or     rax,0x1
    19b7:	add    rsp,0x10
    19bb:	mov    rsp,rbp
    19be:	pop    rbp
    19bf:	ret

00000000000019c0 <botlish_entry_23: high_nibble<int>>:
    19c0:	push   rbp
    19c1:	mov    rbp,rsp
    19c4:	mov    rsi,QWORD PTR [rdx]
    19c7:	call   19cc <botlish_entry_23+0xc>
			19c8: R_X86_64_PLT32	botlish_fn_23-0x4 ; high_nibble<int>
    19cc:	mov    rsp,rbp
    19cf:	pop    rbp
    19d0:	ret

00000000000019d1 <botlish_fn_24: hex_pair<int>>:
    19d1:	push   rbp
    19d2:	mov    rbp,rsp
    19d5:	sub    rsp,0x60
    19d9:	mov    QWORD PTR [rsp+0x40],rbx
    19de:	mov    QWORD PTR [rsp+0x48],r12
    19e3:	mov    QWORD PTR [rsp+0x50],r13
    19e8:	mov    QWORD PTR [rsp+0x58],r14
    19ed:	mov    QWORD PTR [rsp+0x10],0x0
    19f6:	mov    QWORD PTR [rsp+0x18],0x0
    19ff:	mov    QWORD PTR [rsp],rsi
    1a03:	mov    r14,rsi
    1a06:	mov    rax,QWORD PTR [rdi+0x30]
    1a0a:	mov    r13,rdi
    1a0d:	mov    rbx,QWORD PTR [rax+0x8]
    1a11:	mov    QWORD PTR [rsp+0x8],rbx
    1a16:	mov    rsi,r14
    1a19:	call   1a1e <botlish_fn_24+0x4d>
			1a1a: R_X86_64_PLT32	botlish_fn_23-0x4 ; high_nibble<int>
    1a1e:	mov    rcx,QWORD PTR [rbx+0x10]
    1a22:	sar    rax,1
    1a25:	mov    r12,QWORD PTR [rcx+rax*8]
    1a29:	mov    QWORD PTR [rsp+0x8],r12
    1a2e:	mov    rdi,r13
    1a31:	mov    rax,QWORD PTR [rdi+0x30]
    1a35:	mov    rbx,QWORD PTR [rax+0x8]
    1a39:	mov    QWORD PTR [rsp+0x10],rbx
    1a3e:	mov    edx,0x21
    1a43:	mov    QWORD PTR [rsp+0x18],0x21
    1a4c:	mov    rsi,r14
    1a4f:	call   1a54 <botlish_fn_24+0x83>
			1a50: R_X86_64_PLT32	rt_int_mod-0x4
    1a54:	test   rax,rax
    1a57:	je     1aa8 <botlish_fn_24+0xd7>
    1a5d:	mov    rcx,QWORD PTR [rbx+0x10]
    1a61:	sar    rax,1
    1a64:	mov    rdx,QWORD PTR [rcx+rax*8]
    1a68:	mov    QWORD PTR [rsp],rdx
    1a6c:	lea    rcx,[rsp+0x20]
    1a71:	mov    QWORD PTR [rsp+0x20],0x0
    1a7a:	mov    QWORD PTR [rsp+0x28],r12
    1a7f:	mov    QWORD PTR [rsp+0x30],0x0
    1a88:	mov    QWORD PTR [rsp+0x38],rdx
    1a8d:	mov    esi,0x2
    1a92:	mov    edx,0x4
    1a97:	mov    rdi,r13
    1a9a:	call   1a9f <botlish_fn_24+0xce>
			1a9b: R_X86_64_PLT32	rt_construct-0x4
    1a9f:	test   rax,rax
    1aa2:	jne    1ac8 <botlish_fn_24+0xf7>
    1aa8:	xor    rax,rax
    1aab:	mov    rbx,QWORD PTR [rsp+0x40]
    1ab0:	mov    r12,QWORD PTR [rsp+0x48]
    1ab5:	mov    r13,QWORD PTR [rsp+0x50]
    1aba:	mov    r14,QWORD PTR [rsp+0x58]
    1abf:	add    rsp,0x60
    1ac3:	mov    rsp,rbp
    1ac6:	pop    rbp
    1ac7:	ret
    1ac8:	mov    rbx,QWORD PTR [rsp+0x40]
    1acd:	mov    r12,QWORD PTR [rsp+0x48]
    1ad2:	mov    r13,QWORD PTR [rsp+0x50]
    1ad7:	mov    r14,QWORD PTR [rsp+0x58]
    1adc:	add    rsp,0x60
    1ae0:	mov    rsp,rbp
    1ae3:	pop    rbp
    1ae4:	ret

0000000000001ae5 <botlish_entry_24: hex_pair<int>>:
    1ae5:	push   rbp
    1ae6:	mov    rbp,rsp
    1ae9:	sub    rsp,0x10
    1aed:	mov    QWORD PTR [rsp],r12
    1af1:	mov    r12,rdi
    1af4:	mov    rsi,QWORD PTR [rdx]
    1af7:	call   1afc <botlish_entry_24+0x17>
			1af8: R_X86_64_PLT32	botlish_fn_24-0x4 ; hex_pair<int>
    1afc:	mov    r8,QWORD PTR [rip+0x0]        # 1b03 <botlish_entry_24+0x1e>
			1aff: R_X86_64_GOTPCREL	rt_plan_materialize-0x4
    1b03:	mov    rsi,rax
    1b06:	mov    rdi,r12
    1b09:	call   r8
    1b0c:	mov    r12,QWORD PTR [rsp]
    1b10:	add    rsp,0x10
    1b14:	mov    rsp,rbp
    1b17:	pop    rbp
    1b18:	ret

0000000000001b19 <botlish_fn_25: pct<int>>:
    1b19:	push   rbp
    1b1a:	mov    rbp,rsp
    1b1d:	sub    rsp,0x40
    1b21:	mov    QWORD PTR [rsp+0x30],r12
    1b26:	mov    QWORD PTR [rsp+0x38],r13
    1b2b:	mov    QWORD PTR [rsp],rsi
    1b2f:	mov    rax,QWORD PTR [rdi+0x10]
    1b33:	mov    r12,rdi
    1b36:	mov    r13,QWORD PTR [rax+0x10]
    1b3a:	mov    QWORD PTR [rsp+0x8],r13
    1b3f:	call   1b44 <botlish_fn_25+0x2b>
			1b40: R_X86_64_PLT32	botlish_fn_24-0x4 ; hex_pair<int>
    1b44:	test   rax,rax
    1b47:	je     1b8d <botlish_fn_25+0x74>
    1b4d:	mov    QWORD PTR [rsp],rax
    1b51:	lea    rcx,[rsp+0x10]
    1b56:	mov    QWORD PTR [rsp+0x10],0x0
    1b5f:	mov    QWORD PTR [rsp+0x18],r13
    1b64:	mov    QWORD PTR [rsp+0x20],0x0
    1b6d:	mov    QWORD PTR [rsp+0x28],rax
    1b72:	mov    esi,0x2
    1b77:	mov    edx,0x4
    1b7c:	mov    rdi,r12
    1b7f:	call   1b84 <botlish_fn_25+0x6b>
			1b80: R_X86_64_PLT32	rt_construct-0x4
    1b84:	test   rax,rax
    1b87:	jne    1ba3 <botlish_fn_25+0x8a>
    1b8d:	xor    rax,rax
    1b90:	mov    r12,QWORD PTR [rsp+0x30]
    1b95:	mov    r13,QWORD PTR [rsp+0x38]
    1b9a:	add    rsp,0x40
    1b9e:	mov    rsp,rbp
    1ba1:	pop    rbp
    1ba2:	ret
    1ba3:	mov    r12,QWORD PTR [rsp+0x30]
    1ba8:	mov    r13,QWORD PTR [rsp+0x38]
    1bad:	add    rsp,0x40
    1bb1:	mov    rsp,rbp
    1bb4:	pop    rbp
    1bb5:	ret

0000000000001bb6 <botlish_entry_25: pct<int>>:
    1bb6:	push   rbp
    1bb7:	mov    rbp,rsp
    1bba:	sub    rsp,0x10
    1bbe:	mov    QWORD PTR [rsp],r12
    1bc2:	mov    r12,rdi
    1bc5:	mov    rsi,QWORD PTR [rdx]
    1bc8:	call   1bcd <botlish_entry_25+0x17>
			1bc9: R_X86_64_PLT32	botlish_fn_25-0x4 ; pct<int>
    1bcd:	mov    r8,QWORD PTR [rip+0x0]        # 1bd4 <botlish_entry_25+0x1e>
			1bd0: R_X86_64_GOTPCREL	rt_plan_materialize-0x4
    1bd4:	mov    rsi,rax
    1bd7:	mov    rdi,r12
    1bda:	call   r8
    1bdd:	mov    r12,QWORD PTR [rsp]
    1be1:	add    rsp,0x10
    1be5:	mov    rsp,rbp
    1be8:	pop    rbp
    1be9:	ret

0000000000001bea <botlish_fn_26: cont<int, int>>:
    1bea:	push   rbp
    1beb:	mov    rbp,rsp
    1bee:	sub    rsp,0x30
    1bf2:	mov    QWORD PTR [rsp+0x20],rbx
    1bf7:	mov    rbx,rdi
    1bfa:	mov    QWORD PTR [rsp],rsi
    1bfe:	mov    QWORD PTR [rsp+0x8],rdx
    1c03:	mov    QWORD PTR [rsp+0x10],0x101
    1c0c:	mov    rdi,rbx
    1c0f:	call   1c14 <botlish_fn_26+0x2a>
			1c10: R_X86_64_PLT32	rt_int_shr-0x4
    1c14:	test   rax,rax
    1c17:	je     1c9a <botlish_fn_26+0xb0>
    1c1d:	mov    QWORD PTR [rsp],rax
    1c21:	mov    QWORD PTR [rsp+0x8],0x7f
    1c2a:	test   rax,0x1
    1c30:	mov    rsi,rax
    1c33:	jne    1c4e <botlish_fn_26+0x64>
    1c39:	mov    edx,0x7f
    1c3e:	mov    rdi,rbx
    1c41:	call   1c46 <botlish_fn_26+0x5c>
			1c42: R_X86_64_PLT32	rt_int_and-0x4
    1c46:	mov    rdx,rax
    1c49:	jmp    1c55 <botlish_fn_26+0x6b>
    1c4e:	mov    rdx,rsi
    1c51:	and    rdx,0x7f
    1c55:	mov    QWORD PTR [rsp],rdx
    1c59:	test   rdx,0x1
    1c60:	jne    1c7b <botlish_fn_26+0x91>
    1c66:	mov    esi,0x101
    1c6b:	mov    rdi,rbx
    1c6e:	call   1c73 <botlish_fn_26+0x89>
			1c6f: R_X86_64_PLT32	rt_int_or-0x4
    1c73:	mov    rsi,rax
    1c76:	jmp    1c85 <botlish_fn_26+0x9b>
    1c7b:	or     rdx,0x101
    1c82:	mov    rsi,rdx
    1c85:	mov    QWORD PTR [rsp],rsi
    1c89:	mov    rdi,rbx
    1c8c:	call   1c91 <botlish_fn_26+0xa7>
			1c8d: R_X86_64_PLT32	botlish_fn_25-0x4 ; pct<int>
    1c91:	test   rax,rax
    1c94:	jne    1cab <botlish_fn_26+0xc1>
    1c9a:	xor    rax,rax
    1c9d:	mov    rbx,QWORD PTR [rsp+0x20]
    1ca2:	add    rsp,0x30
    1ca6:	mov    rsp,rbp
    1ca9:	pop    rbp
    1caa:	ret
    1cab:	mov    rbx,QWORD PTR [rsp+0x20]
    1cb0:	add    rsp,0x30
    1cb4:	mov    rsp,rbp
    1cb7:	pop    rbp
    1cb8:	ret

0000000000001cb9 <botlish_entry_26: cont<int, int>>:
    1cb9:	push   rbp
    1cba:	mov    rbp,rsp
    1cbd:	sub    rsp,0x10
    1cc1:	mov    QWORD PTR [rsp],r12
    1cc5:	mov    r12,rdi
    1cc8:	mov    rsi,QWORD PTR [rdx]
    1ccb:	mov    rdx,QWORD PTR [rdx+0x8]
    1ccf:	call   1cd4 <botlish_entry_26+0x1b>
			1cd0: R_X86_64_PLT32	botlish_fn_26-0x4 ; cont<int, int>
    1cd4:	mov    r8,QWORD PTR [rip+0x0]        # 1cdb <botlish_entry_26+0x22>
			1cd7: R_X86_64_GOTPCREL	rt_plan_materialize-0x4
    1cdb:	mov    rsi,rax
    1cde:	mov    rdi,r12
    1ce1:	call   r8
    1ce4:	mov    r12,QWORD PTR [rsp]
    1ce8:	add    rsp,0x10
    1cec:	mov    rsp,rbp
    1cef:	pop    rbp
    1cf0:	ret
    1cf1:	add    BYTE PTR [rax],al
    1cf3:	add    BYTE PTR [rax],al
    1cf5:	add    BYTE PTR [rax],al
	...

0000000000001cf8 <botlish_fn_27: esc_scalar<int>>:
    1cf8:	push   rbp
    1cf9:	mov    rbp,rsp
    1cfc:	sub    rsp,0xf0
    1d03:	mov    QWORD PTR [rsp+0xc0],rbx
    1d0b:	mov    QWORD PTR [rsp+0xc8],r12
    1d13:	mov    QWORD PTR [rsp+0xd0],r13
    1d1b:	mov    QWORD PTR [rsp+0xd8],r14
    1d23:	mov    QWORD PTR [rsp+0xe0],r15
    1d2b:	mov    rbx,rdi
    1d2e:	mov    QWORD PTR [rsp+0x18],0x0
    1d37:	mov    QWORD PTR [rsp+0x20],0x0
    1d40:	mov    QWORD PTR [rsp],rsi
    1d44:	test   rsi,0x1
    1d4b:	mov    r12,rsi
    1d4e:	jne    1d7a <botlish_fn_27+0x82>
    1d54:	mov    edx,0x1001
    1d59:	mov    rsi,r12
    1d5c:	mov    rdi,rbx
    1d5f:	call   1d64 <botlish_fn_27+0x6c>
			1d60: R_X86_64_PLT32	rt_int_cmp-0x4
    1d64:	mov    r11d,0x2
    1d6a:	test   rax,rax
    1d6d:	cmovl  r11,QWORD PTR [rip+0x3fb]        # 2170 <botlish_fn_27+0x478>
    1d75:	jmp    1d92 <botlish_fn_27+0x9a>
    1d7a:	mov    r11d,0x2
    1d80:	mov    rsi,r12
    1d83:	cmp    rsi,0x1001
    1d8a:	cmovl  r11,QWORD PTR [rip+0x3de]        # 2170 <botlish_fn_27+0x478>
    1d92:	mov    edx,0x6
    1d97:	mov    r13,rdx
    1d9a:	cmp    r11,0x6
    1d9e:	je     2058 <botlish_fn_27+0x360>
    1da4:	mov    rsi,r12
    1da7:	test   rsi,0x1
    1dae:	jne    1dd9 <botlish_fn_27+0xe1>
    1db4:	mov    edx,0x20001
    1db9:	mov    rsi,r12
    1dbc:	mov    rdi,rbx
    1dbf:	call   1dc4 <botlish_fn_27+0xcc>
			1dc0: R_X86_64_PLT32	rt_int_cmp-0x4
    1dc4:	mov    ecx,0x2
    1dc9:	test   rax,rax
    1dcc:	cmovl  rcx,QWORD PTR [rip+0x39c]        # 2170 <botlish_fn_27+0x478>
    1dd4:	jmp    1df0 <botlish_fn_27+0xf8>
    1dd9:	mov    ecx,0x2
    1dde:	mov    rsi,r12
    1de1:	cmp    rsi,0x20001
    1de8:	cmovl  rcx,QWORD PTR [rip+0x380]        # 2170 <botlish_fn_27+0x478>
    1df0:	cmp    rcx,0x6
    1df4:	je     1f6b <botlish_fn_27+0x273>
    1dfa:	mov    QWORD PTR [rsp+0x8],0x1e1
    1e03:	mov    edx,0x25
    1e08:	mov    QWORD PTR [rsp+0x10],0x25
    1e11:	mov    rsi,r12
    1e14:	mov    rdi,rbx
    1e17:	call   1e1c <botlish_fn_27+0x124>
			1e18: R_X86_64_PLT32	rt_int_shr-0x4
    1e1c:	test   rax,rax
    1e1f:	je     2101 <botlish_fn_27+0x409>
    1e25:	mov    QWORD PTR [rsp+0x10],rax
    1e2a:	test   rax,0x1
    1e30:	mov    rdx,rax
    1e33:	jne    1e4e <botlish_fn_27+0x156>
    1e39:	mov    esi,0x1e1
    1e3e:	mov    rdi,rbx
    1e41:	call   1e46 <botlish_fn_27+0x14e>
			1e42: R_X86_64_PLT32	rt_int_or-0x4
    1e46:	mov    rsi,rax
    1e49:	jmp    1e58 <botlish_fn_27+0x160>
    1e4e:	mov    rsi,rdx
    1e51:	or     rsi,0x1e1
    1e58:	mov    QWORD PTR [rsp+0x8],rsi
    1e5d:	mov    rdi,rbx
    1e60:	call   1e65 <botlish_fn_27+0x16d>
			1e61: R_X86_64_PLT32	botlish_fn_25-0x4 ; pct<int>
    1e65:	test   rax,rax
    1e68:	je     2101 <botlish_fn_27+0x409>
    1e6e:	mov    QWORD PTR [rsp+0x8],rax
    1e73:	mov    r13,rax
    1e76:	mov    edx,0x19
    1e7b:	mov    QWORD PTR [rsp+0x10],0x19
    1e84:	mov    rsi,r12
    1e87:	mov    rdi,rbx
    1e8a:	call   1e8f <botlish_fn_27+0x197>
			1e8b: R_X86_64_PLT32	botlish_fn_26-0x4 ; cont<int, int>
    1e8f:	test   rax,rax
    1e92:	je     2101 <botlish_fn_27+0x409>
    1e98:	mov    QWORD PTR [rsp+0x10],rax
    1e9d:	mov    r14,rax
    1ea0:	mov    edx,0xd
    1ea5:	mov    QWORD PTR [rsp+0x18],0xd
    1eae:	mov    rsi,r12
    1eb1:	mov    rdi,rbx
    1eb4:	call   1eb9 <botlish_fn_27+0x1c1>
			1eb5: R_X86_64_PLT32	botlish_fn_26-0x4 ; cont<int, int>
    1eb9:	test   rax,rax
    1ebc:	je     2101 <botlish_fn_27+0x409>
    1ec2:	mov    QWORD PTR [rsp+0x18],rax
    1ec7:	mov    r15,rax
    1eca:	mov    edx,0x1
    1ecf:	mov    QWORD PTR [rsp+0x20],0x1
    1ed8:	mov    rsi,r12
    1edb:	mov    rdi,rbx
    1ede:	call   1ee3 <botlish_fn_27+0x1eb>
			1edf: R_X86_64_PLT32	botlish_fn_26-0x4 ; cont<int, int>
    1ee3:	test   rax,rax
    1ee6:	je     2101 <botlish_fn_27+0x409>
    1eec:	mov    QWORD PTR [rsp],rax
    1ef0:	lea    rcx,[rsp+0x78]
    1ef5:	mov    QWORD PTR [rsp+0x78],0x0
    1efe:	mov    rdx,r13
    1f01:	mov    QWORD PTR [rsp+0x80],rdx
    1f09:	mov    QWORD PTR [rsp+0x88],0x0
    1f15:	mov    rdx,r14
    1f18:	mov    QWORD PTR [rsp+0x90],rdx
    1f20:	mov    QWORD PTR [rsp+0x98],0x0
    1f2c:	mov    rdx,r15
    1f2f:	mov    QWORD PTR [rsp+0xa0],rdx
    1f37:	mov    QWORD PTR [rsp+0xa8],0x0
    1f43:	mov    QWORD PTR [rsp+0xb0],rax
    1f4b:	mov    esi,0x2
    1f50:	mov    edx,0x8
    1f55:	mov    rdi,rbx
    1f58:	call   1f5d <botlish_fn_27+0x265>
			1f59: R_X86_64_PLT32	rt_construct-0x4
    1f5d:	test   rax,rax
    1f60:	je     2101 <botlish_fn_27+0x409>
    1f66:	jmp    2138 <botlish_fn_27+0x440>
    1f6b:	mov    QWORD PTR [rsp+0x8],0x1c1
    1f74:	mov    edx,0xd
    1f79:	mov    rsi,r12
    1f7c:	mov    r14,rdx
    1f7f:	sar    rsi,0xd
    1f83:	shl    rsi,1
    1f86:	mov    rax,rsi
    1f89:	or     rax,0x1
    1f8d:	mov    QWORD PTR [rsp+0x10],rax
    1f92:	or     rsi,0x1c1
    1f99:	mov    QWORD PTR [rsp+0x8],rsi
    1f9e:	mov    rdi,rbx
    1fa1:	call   1fa6 <botlish_fn_27+0x2ae>
			1fa2: R_X86_64_PLT32	botlish_fn_25-0x4 ; pct<int>
    1fa6:	test   rax,rax
    1fa9:	je     2101 <botlish_fn_27+0x409>
    1faf:	mov    QWORD PTR [rsp+0x8],rax
    1fb4:	mov    r15,rax
    1fb7:	mov    QWORD PTR [rsp+0x10],0xd
    1fc0:	mov    rdx,r14
    1fc3:	mov    rsi,r12
    1fc6:	mov    rdi,rbx
    1fc9:	call   1fce <botlish_fn_27+0x2d6>
			1fca: R_X86_64_PLT32	botlish_fn_26-0x4 ; cont<int, int>
    1fce:	test   rax,rax
    1fd1:	je     2101 <botlish_fn_27+0x409>
    1fd7:	mov    QWORD PTR [rsp+0x10],rax
    1fdc:	mov    r14,rax
    1fdf:	mov    edx,0x1
    1fe4:	mov    QWORD PTR [rsp+0x18],0x1
    1fed:	mov    rsi,r12
    1ff0:	mov    rdi,rbx
    1ff3:	call   1ff8 <botlish_fn_27+0x300>
			1ff4: R_X86_64_PLT32	botlish_fn_26-0x4 ; cont<int, int>
    1ff8:	test   rax,rax
    1ffb:	je     2101 <botlish_fn_27+0x409>
    2001:	mov    QWORD PTR [rsp],rax
    2005:	lea    rcx,[rsp+0x48]
    200a:	mov    QWORD PTR [rsp+0x48],0x0
    2013:	mov    rdx,r15
    2016:	mov    QWORD PTR [rsp+0x50],rdx
    201b:	mov    QWORD PTR [rsp+0x58],0x0
    2024:	mov    rdx,r14
    2027:	mov    QWORD PTR [rsp+0x60],rdx
    202c:	mov    QWORD PTR [rsp+0x68],0x0
    2035:	mov    QWORD PTR [rsp+0x70],rax
    203a:	mov    esi,0x2
    203f:	mov    rdx,r13
    2042:	mov    rdi,rbx
    2045:	call   204a <botlish_fn_27+0x352>
			2046: R_X86_64_PLT32	rt_construct-0x4
    204a:	test   rax,rax
    204d:	je     2101 <botlish_fn_27+0x409>
    2053:	jmp    2138 <botlish_fn_27+0x440>
    2058:	mov    QWORD PTR [rsp+0x8],0x181
    2061:	mov    rsi,r12
    2064:	sar    rsi,0x7
    2068:	shl    rsi,1
    206b:	mov    rax,rsi
    206e:	or     rax,0x1
    2072:	mov    QWORD PTR [rsp+0x10],rax
    2077:	or     rsi,0x181
    207e:	mov    QWORD PTR [rsp+0x8],rsi
    2083:	mov    rdi,rbx
    2086:	call   208b <botlish_fn_27+0x393>
			2087: R_X86_64_PLT32	botlish_fn_25-0x4 ; pct<int>
    208b:	test   rax,rax
    208e:	je     2101 <botlish_fn_27+0x409>
    2094:	mov    QWORD PTR [rsp+0x8],rax
    2099:	mov    r13,rax
    209c:	mov    edx,0x1
    20a1:	mov    QWORD PTR [rsp+0x10],0x1
    20aa:	mov    rsi,r12
    20ad:	mov    rdi,rbx
    20b0:	call   20b5 <botlish_fn_27+0x3bd>
			20b1: R_X86_64_PLT32	botlish_fn_26-0x4 ; cont<int, int>
    20b5:	test   rax,rax
    20b8:	je     2101 <botlish_fn_27+0x409>
    20be:	mov    QWORD PTR [rsp],rax
    20c2:	lea    rcx,[rsp+0x28]
    20c7:	mov    QWORD PTR [rsp+0x28],0x0
    20d0:	mov    rdx,r13
    20d3:	mov    QWORD PTR [rsp+0x30],rdx
    20d8:	mov    QWORD PTR [rsp+0x38],0x0
    20e1:	mov    QWORD PTR [rsp+0x40],rax
    20e6:	mov    esi,0x2
    20eb:	mov    edx,0x4
    20f0:	mov    rdi,rbx
    20f3:	call   20f8 <botlish_fn_27+0x400>
			20f4: R_X86_64_PLT32	rt_construct-0x4
    20f8:	test   rax,rax
    20fb:	jne    2138 <botlish_fn_27+0x440>
    2101:	xor    rax,rax
    2104:	mov    rbx,QWORD PTR [rsp+0xc0]
    210c:	mov    r12,QWORD PTR [rsp+0xc8]
    2114:	mov    r13,QWORD PTR [rsp+0xd0]
    211c:	mov    r14,QWORD PTR [rsp+0xd8]
    2124:	mov    r15,QWORD PTR [rsp+0xe0]
    212c:	add    rsp,0xf0
    2133:	mov    rsp,rbp
    2136:	pop    rbp
    2137:	ret
    2138:	mov    rbx,QWORD PTR [rsp+0xc0]
    2140:	mov    r12,QWORD PTR [rsp+0xc8]
    2148:	mov    r13,QWORD PTR [rsp+0xd0]
    2150:	mov    r14,QWORD PTR [rsp+0xd8]
    2158:	mov    r15,QWORD PTR [rsp+0xe0]
    2160:	add    rsp,0xf0
    2167:	mov    rsp,rbp
    216a:	pop    rbp
    216b:	ret
    216c:	add    BYTE PTR [rax],al
    216e:	add    BYTE PTR [rax],al
    2170:	(bad)
    2171:	add    BYTE PTR [rax],al
    2173:	add    BYTE PTR [rax],al
    2175:	add    BYTE PTR [rax],al
	...

0000000000002178 <botlish_entry_27: esc_scalar<int>>:
    2178:	push   rbp
    2179:	mov    rbp,rsp
    217c:	sub    rsp,0x10
    2180:	mov    QWORD PTR [rsp],r12
    2184:	mov    r12,rdi
    2187:	mov    rsi,QWORD PTR [rdx]
    218a:	call   218f <botlish_entry_27+0x17>
			218b: R_X86_64_PLT32	botlish_fn_27-0x4 ; esc_scalar<int>
    218f:	mov    r8,QWORD PTR [rip+0x0]        # 2196 <botlish_entry_27+0x1e>
			2192: R_X86_64_GOTPCREL	rt_plan_materialize-0x4
    2196:	mov    rsi,rax
    2199:	mov    rdi,r12
    219c:	call   r8
    219f:	mov    r12,QWORD PTR [rsp]
    21a3:	add    rsp,0x10
    21a7:	mov    rsp,rbp
    21aa:	pop    rbp
    21ab:	ret
    21ac:	add    BYTE PTR [rax],al
	...

00000000000021b0 <botlish_fn_28: esc_from<str, int, str>>:
    21b0:	push   rbp
    21b1:	mov    rbp,rsp
    21b4:	sub    rsp,0x100
    21bb:	mov    QWORD PTR [rsp+0xd0],rbx
    21c3:	mov    QWORD PTR [rsp+0xd8],r12
    21cb:	mov    QWORD PTR [rsp+0xe0],r13
    21d3:	mov    QWORD PTR [rsp+0xe8],r14
    21db:	mov    QWORD PTR [rsp+0xf0],r15
    21e3:	mov    QWORD PTR [rsp+0xa0],rdi
    21eb:	mov    QWORD PTR [rsp+0x8],0x0
    21f4:	mov    QWORD PTR [rsp+0x10],0x0
    21fd:	mov    QWORD PTR [rsp+0x18],0x0
    2206:	mov    QWORD PTR [rsp],rcx
    220a:	mov    QWORD PTR [rsp+0xb0],rcx
    2212:	sar    rdx,1
    2215:	mov    rdi,rdx
    2218:	mov    r14d,0x47
    221e:	mov    rcx,0xffffffffffffffff
    2225:	bsr    rax,rsi
    2229:	mov    QWORD PTR [rsp+0xa8],rsi
    2231:	cmove  rax,rcx
    2235:	mov    edx,0x3f
    223a:	sub    rdx,rax
    223d:	sub    r14,rdx
    2240:	shr    r14,0x3
    2244:	lea    r12,[rsp+0x80]
    224c:	mov    QWORD PTR [rsp+0xc8],r12
    2254:	lea    r13,[rsp+0x50]
    2259:	mov    QWORD PTR [rsp+0xc0],r13
    2261:	lea    rax,[rsp+0x30]
    2266:	mov    QWORD PTR [rsp+0xb8],rax
    226e:	mov    r15,rdi
    2271:	cmp    r15,r14
    2274:	jge    24bb <botlish_fn_28+0x30b>
    227a:	mov    rsi,QWORD PTR [rsp+0xa8]
    2282:	mov    rdi,QWORD PTR [rsp+0xa0]
    228a:	call   228f <botlish_fn_28+0xdf>
			228b: R_X86_64_PLT32	rt_ascii_to_str-0x4
    228f:	mov    QWORD PTR [rsp+0x8],rax
    2294:	mov    rbx,r15
    2297:	shl    rbx,1
    229a:	or     rbx,0x1
    229e:	mov    QWORD PTR [rsp+0x10],rbx
    22a3:	movzx  rsi,BYTE PTR [rax+0x18]
    22a8:	mov    r13,rax
    22ab:	test   rsi,rsi
    22ae:	jne    22cf <botlish_fn_28+0x11f>
    22b4:	mov    rdx,rbx
    22b7:	mov    rsi,r13
    22ba:	mov    rdi,QWORD PTR [rsp+0xa0]
    22c2:	call   22c7 <botlish_fn_28+0x117>
			22c3: R_X86_64_PLT32	rt_str_char_at_proven-0x4
    22c7:	mov    rsi,rax
    22ca:	jmp    22e3 <botlish_fn_28+0x133>
    22cf:	mov    rdi,rbx
    22d2:	sar    rdi,1
    22d5:	movzx  rsi,BYTE PTR [r13+rdi*1+0x19]
    22db:	shl    rsi,0x3
    22df:	or     rsi,0x4
    22e3:	shr    rsi,0x3
    22e7:	shl    rsi,1
    22ea:	or     rsi,0x1
    22ee:	mov    QWORD PTR [rsp+0x8],rsi
    22f3:	mov    ecx,0x2
    22f8:	cmp    rsi,0xff
    22ff:	mov    r12,rsi
    2302:	cmovg  rcx,QWORD PTR [rip+0x256]        # 2560 <botlish_fn_28+0x3b0>
    230a:	cmp    rcx,0x6
    230e:	je     2439 <botlish_fn_28+0x289>
    2314:	mov    rsi,r12
    2317:	mov    rdi,QWORD PTR [rsp+0xa0]
    231f:	call   2324 <botlish_fn_28+0x174>
			2320: R_X86_64_PLT32	botlish_fn_18-0x4 ; web::is_unreserved<int>
    2324:	cmp    rax,0x6
    2328:	je     23bc <botlish_fn_28+0x20c>
    232e:	mov    rsi,r12
    2331:	mov    rdi,QWORD PTR [rsp+0xa0]
    2339:	call   233e <botlish_fn_28+0x18e>
			233a: R_X86_64_PLT32	botlish_fn_25-0x4 ; pct<int>
    233e:	test   rax,rax
    2341:	je     24f4 <botlish_fn_28+0x344>
    2347:	mov    QWORD PTR [rsp+0x8],rax
    234c:	mov    QWORD PTR [rsp+0x80],0x0
    2358:	mov    r12,QWORD PTR [rsp+0xb0]
    2360:	mov    QWORD PTR [rsp+0x88],r12
    2368:	mov    QWORD PTR [rsp+0x90],0x0
    2374:	mov    QWORD PTR [rsp+0x98],rax
    237c:	mov    esi,0x2
    2381:	mov    edx,0x4
    2386:	mov    rcx,QWORD PTR [rsp+0xc8]
    238e:	mov    rdi,QWORD PTR [rsp+0xa0]
    2396:	call   239b <botlish_fn_28+0x1eb>
			2397: R_X86_64_PLT32	rt_construct-0x4
    239b:	test   rax,rax
    239e:	je     24f4 <botlish_fn_28+0x344>
    23a4:	mov    QWORD PTR [rsp],rax
    23a8:	add    r15,0x1
    23af:	mov    QWORD PTR [rsp+0xb0],rax
    23b7:	jmp    2271 <botlish_fn_28+0xc1>
    23bc:	mov    r12,QWORD PTR [rsp+0xb0]
    23c4:	add    r15,0x1
    23cb:	mov    rcx,r15
    23ce:	shl    rcx,1
    23d1:	or     rcx,0x1
    23d5:	mov    QWORD PTR [rsp+0x18],rcx
    23da:	mov    QWORD PTR [rsp+0x50],0x0
    23e3:	mov    QWORD PTR [rsp+0x58],r12
    23e8:	mov    QWORD PTR [rsp+0x60],0x1
    23f1:	mov    QWORD PTR [rsp+0x68],r13
    23f6:	mov    QWORD PTR [rsp+0x70],rbx
    23fb:	mov    QWORD PTR [rsp+0x78],rcx
    2400:	mov    esi,0x2
    2405:	mov    edx,0x6
    240a:	mov    rcx,QWORD PTR [rsp+0xc0]
    2412:	mov    rdi,QWORD PTR [rsp+0xa0]
    241a:	call   241f <botlish_fn_28+0x26f>
			241b: R_X86_64_PLT32	rt_construct-0x4
    241f:	test   rax,rax
    2422:	je     24f4 <botlish_fn_28+0x344>
    2428:	mov    QWORD PTR [rsp],rax
    242c:	mov    QWORD PTR [rsp+0xb0],rax
    2434:	jmp    2271 <botlish_fn_28+0xc1>
    2439:	mov    rsi,r12
    243c:	mov    r12,QWORD PTR [rsp+0xb0]
    2444:	mov    rdi,QWORD PTR [rsp+0xa0]
    244c:	call   2451 <botlish_fn_28+0x2a1>
			244d: R_X86_64_PLT32	botlish_fn_27-0x4 ; esc_scalar<int>
    2451:	test   rax,rax
    2454:	je     24f4 <botlish_fn_28+0x344>
    245a:	mov    QWORD PTR [rsp+0x8],rax
    245f:	mov    QWORD PTR [rsp+0x30],0x0
    2468:	mov    QWORD PTR [rsp+0x38],r12
    246d:	mov    QWORD PTR [rsp+0x40],0x0
    2476:	mov    QWORD PTR [rsp+0x48],rax
    247b:	mov    esi,0x2
    2480:	mov    edx,0x4
    2485:	mov    rcx,QWORD PTR [rsp+0xb8]
    248d:	mov    rdi,QWORD PTR [rsp+0xa0]
    2495:	call   249a <botlish_fn_28+0x2ea>
			2496: R_X86_64_PLT32	rt_construct-0x4
    249a:	test   rax,rax
    249d:	je     24f4 <botlish_fn_28+0x344>
    24a3:	mov    QWORD PTR [rsp],rax
    24a7:	add    r15,0x1
    24ae:	mov    QWORD PTR [rsp+0xb0],rax
    24b6:	jmp    2271 <botlish_fn_28+0xc1>
    24bb:	mov    r12,QWORD PTR [rsp+0xb0]
    24c3:	xor    rsi,rsi
    24c6:	lea    rcx,[rsp+0x20]
    24cb:	mov    QWORD PTR [rsp+0x20],0x0
    24d4:	mov    QWORD PTR [rsp+0x28],r12
    24d9:	mov    edx,0x2
    24de:	mov    rdi,QWORD PTR [rsp+0xa0]
    24e6:	call   24eb <botlish_fn_28+0x33b>
			24e7: R_X86_64_PLT32	rt_construct-0x4
    24eb:	test   rax,rax
    24ee:	jne    252b <botlish_fn_28+0x37b>
    24f4:	xor    rax,rax
    24f7:	mov    rbx,QWORD PTR [rsp+0xd0]
    24ff:	mov    r12,QWORD PTR [rsp+0xd8]
    2507:	mov    r13,QWORD PTR [rsp+0xe0]
    250f:	mov    r14,QWORD PTR [rsp+0xe8]
    2517:	mov    r15,QWORD PTR [rsp+0xf0]
    251f:	add    rsp,0x100
    2526:	mov    rsp,rbp
    2529:	pop    rbp
    252a:	ret
    252b:	mov    rbx,QWORD PTR [rsp+0xd0]
    2533:	mov    r12,QWORD PTR [rsp+0xd8]
    253b:	mov    r13,QWORD PTR [rsp+0xe0]
    2543:	mov    r14,QWORD PTR [rsp+0xe8]
    254b:	mov    r15,QWORD PTR [rsp+0xf0]
    2553:	add    rsp,0x100
    255a:	mov    rsp,rbp
    255d:	pop    rbp
    255e:	ret
    255f:	add    BYTE PTR [rsi],al
    2561:	add    BYTE PTR [rax],al
    2563:	add    BYTE PTR [rax],al
    2565:	add    BYTE PTR [rax],al
	...

0000000000002568 <botlish_entry_28: esc_from<str, int, str>>:
    2568:	push   rbp
    2569:	mov    rbp,rsp
    256c:	sub    rsp,0x10
    2570:	mov    QWORD PTR [rsp],r12
    2574:	mov    QWORD PTR [rsp+0x8],r13
    2579:	mov    r12,rdi
    257c:	mov    rsi,QWORD PTR [rdx]
    257f:	mov    r13,rdx
    2582:	mov    r8,QWORD PTR [rip+0x0]        # 2589 <botlish_entry_28+0x21>
			2585: R_X86_64_GOTPCREL	rt_str_to_ascii-0x4
    2589:	call   r8
    258c:	mov    rcx,r13
    258f:	mov    rdx,QWORD PTR [rcx+0x8]
    2593:	mov    rcx,QWORD PTR [rcx+0x10]
    2597:	mov    rsi,rax
    259a:	mov    rdi,r12
    259d:	call   25a2 <botlish_entry_28+0x3a>
			259e: R_X86_64_PLT32	botlish_fn_28-0x4 ; esc_from<str, int, str>
    25a2:	mov    r12,QWORD PTR [rsp]
    25a6:	mov    r13,QWORD PTR [rsp+0x8]
    25ab:	add    rsp,0x10
    25af:	mov    rsp,rbp
    25b2:	pop    rbp
    25b3:	ret

00000000000025b4 <botlish_fn_29: check<int, int, str, str>>:
    25b4:	push   rbp
    25b5:	mov    rbp,rsp
    25b8:	sub    rsp,0x50
    25bc:	mov    QWORD PTR [rsp+0x20],rbx
    25c1:	mov    QWORD PTR [rsp+0x28],r12
    25c6:	mov    QWORD PTR [rsp+0x30],r13
    25cb:	mov    QWORD PTR [rsp+0x38],r14
    25d0:	mov    QWORD PTR [rsp+0x40],r15
    25d5:	mov    r14,rdi
    25d8:	mov    QWORD PTR [rsp+0x18],0x0
    25e1:	mov    QWORD PTR [rsp],rdx
    25e5:	mov    QWORD PTR [rsp+0x8],rcx
    25ea:	mov    QWORD PTR [rsp+0x10],r8
    25ef:	mov    r12,r8
    25f2:	mov    r13,rsi
    25f5:	mov    r15,rdx
    25f8:	test   r13,r13
    25fb:	jle    26d5 <botlish_fn_29+0x121>
    2601:	mov    rbx,rcx
    2604:	mov    rsi,rbx
    2607:	mov    rdi,r14
    260a:	call   260f <botlish_fn_29+0x5b>
			260b: R_X86_64_PLT32	botlish_fn_8-0x4 ; web::emailish?<str>
    260f:	test   rax,rax
    2612:	jne    263d <botlish_fn_29+0x89>
    2618:	xor    rax,rax
    261b:	mov    rbx,QWORD PTR [rsp+0x20]
    2620:	mov    r12,QWORD PTR [rsp+0x28]
    2625:	mov    r13,QWORD PTR [rsp+0x30]
    262a:	mov    r14,QWORD PTR [rsp+0x38]
    262f:	mov    r15,QWORD PTR [rsp+0x40]
    2634:	add    rsp,0x50
    2638:	mov    rsp,rbp
    263b:	pop    rbp
    263c:	ret
    263d:	cmp    rax,0x6
    2641:	je     265d <botlish_fn_29+0xa9>
    2647:	mov    edx,0x1
    264c:	mov    QWORD PTR [rsp+0x18],0x1
    2655:	mov    rsi,r15
    2658:	jmp    2689 <botlish_fn_29+0xd5>
    265d:	mov    rsi,r12
    2660:	mov    rdi,r14
    2663:	call   2668 <botlish_fn_29+0xb4>
			2664: R_X86_64_PLT32	botlish_fn_19-0x4 ; web::uri_query_value?<str>
    2668:	cmp    rax,0x6
    266c:	je     267c <botlish_fn_29+0xc8>
    2672:	mov    edx,0x1
    2677:	jmp    2681 <botlish_fn_29+0xcd>
    267c:	mov    edx,0x3
    2681:	mov    QWORD PTR [rsp+0x18],rdx
    2686:	mov    rsi,r15
    2689:	mov    rax,rsi
    268c:	and    rax,rdx
    268f:	test   rax,0x1
    2695:	je     26b0 <botlish_fn_29+0xfc>
    269b:	lea    rcx,[rdx-0x1]
    269f:	mov    rax,rsi
    26a2:	add    rax,rcx
    26a5:	seto   cl
    26a8:	test   cl,cl
    26aa:	je     26b8 <botlish_fn_29+0x104>
    26b0:	mov    rdi,r14
    26b3:	call   26b8 <botlish_fn_29+0x104>
			26b4: R_X86_64_PLT32	rt_int_add-0x4
    26b8:	mov    QWORD PTR [rsp],rax
    26bc:	mov    QWORD PTR [rsp+0x8],rbx
    26c1:	mov    QWORD PTR [rsp+0x10],r12
    26c6:	sub    r13,0x1
    26ca:	mov    rcx,rbx
    26cd:	mov    r15,rax
    26d0:	jmp    25f8 <botlish_fn_29+0x44>
    26d5:	mov    rax,r15
    26d8:	mov    rbx,QWORD PTR [rsp+0x20]
    26dd:	mov    r12,QWORD PTR [rsp+0x28]
    26e2:	mov    r13,QWORD PTR [rsp+0x30]
    26e7:	mov    r14,QWORD PTR [rsp+0x38]
    26ec:	mov    r15,QWORD PTR [rsp+0x40]
    26f1:	add    rsp,0x50
    26f5:	mov    rsp,rbp
    26f8:	pop    rbp
    26f9:	ret

00000000000026fa <botlish_entry_29: check<int, int, str, str>>:
    26fa:	push   rbp
    26fb:	mov    rbp,rsp
    26fe:	mov    rsi,QWORD PTR [rdx]
    2701:	mov    r9,QWORD PTR [rdx+0x8]
    2705:	mov    rcx,QWORD PTR [rdx+0x10]
    2709:	mov    r8,QWORD PTR [rdx+0x18]
    270d:	sar    rsi,1
    2710:	mov    rdx,r9
    2713:	call   2718 <botlish_entry_29+0x1e>
			2714: R_X86_64_PLT32	botlish_fn_29-0x4 ; check<int, int, str, str>
    2718:	mov    rsp,rbp
    271b:	pop    rbp
    271c:	ret
