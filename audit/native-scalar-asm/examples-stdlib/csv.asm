; source:  examples/stdlib/csv.bot
; backend: Cranelift (specialize=1), native::object
; object:  ELF64 x86-64, unlinked (Botlish-generated code only; runtime
;          helpers are unresolved imports, so their bodies are not present)
; format:  objdump -dr --no-show-raw-insn -M intel
; total machine code bytes: 5422  (per function: 312 365 309 470 932 311 782 870 388 516 167)
;
; function symbol -> Botlish label:
;   botlish_fn_0 / botlish_entry_0 -> <program entry>
;   botlish_fn_1 / botlish_entry_1 -> peek<str, int>
;   botlish_fn_2 / botlish_entry_2 -> quote_at?<str, int>
;   botlish_fn_3 / botlish_entry_3 -> scan_unquoted<str, int, int>
;   botlish_fn_4 / botlish_entry_4 -> scan_quoted<str, int, str>
;   botlish_fn_5 / botlish_entry_5 -> scan_field<str, int>
;   botlish_fn_6 / botlish_entry_6 -> scan_record<str, int, List[never]>
;   botlish_fn_7 / botlish_entry_7 -> scan_record<str, int, List[str]>
;   botlish_fn_8 / botlish_entry_8 -> scan_records<str, int, List[never]>
;   botlish_fn_9 / botlish_entry_9 -> scan_records<str, int, List[List[str]]>
;   botlish_fn_10 / botlish_entry_10 -> csv_parse<str>


csv.asm.o:     file format elf64-x86-64


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
			1c: R_X86_64_PLT32	botlish_fn_10-0x4 ; csv_parse<str>
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
      f9:	add    BYTE PTR [rax],al
      fb:	add    BYTE PTR [rax],al
      fd:	add    BYTE PTR [rax],al
	...

0000000000000100 <botlish_fn_1: peek<str, int>>:
     100:	push   rbp
     101:	mov    rbp,rsp
     104:	sub    rsp,0x40
     108:	mov    QWORD PTR [rsp+0x20],rbx
     10d:	mov    QWORD PTR [rsp+0x28],r12
     112:	mov    QWORD PTR [rsp+0x30],r13
     117:	mov    rbx,rdx
     11a:	mov    r13,rdi
     11d:	mov    QWORD PTR [rsp],rsi
     121:	mov    QWORD PTR [rsp+0x8],rdx
     126:	mov    rdx,QWORD PTR [rsi+0x8]
     12a:	mov    r12,rsi
     12d:	shl    rdx,1
     130:	mov    rax,rdx
     133:	or     rax,0x1
     137:	mov    rcx,rbx
     13a:	and    rcx,rax
     13d:	test   rcx,0x1
     144:	jne    16e <botlish_fn_1+0x6e>
     14a:	or     rdx,0x1
     14e:	mov    rsi,rbx
     151:	mov    rdi,r13
     154:	call   159 <botlish_fn_1+0x59>
			155: R_X86_64_PLT32	rt_int_cmp-0x4
     159:	mov    ecx,0x2
     15e:	test   rax,rax
     161:	cmovge rcx,QWORD PTR [rip+0xd7]        # 240 <botlish_fn_1+0x140>
     169:	jmp    182 <botlish_fn_1+0x82>
     16e:	or     rdx,0x1
     172:	mov    ecx,0x2
     177:	cmp    rbx,rdx
     17a:	cmovge rcx,QWORD PTR [rip+0xbe]        # 240 <botlish_fn_1+0x140>
     182:	cmp    rcx,0x6
     186:	je     216 <botlish_fn_1+0x116>
     18c:	mov    QWORD PTR [rsp+0x10],0x3
     195:	test   rbx,0x1
     19c:	je     1b4 <botlish_fn_1+0xb4>
     1a2:	mov    rcx,rbx
     1a5:	add    rcx,0x2
     1a9:	seto   al
     1ac:	test   al,al
     1ae:	je     1c7 <botlish_fn_1+0xc7>
     1b4:	mov    edx,0x3
     1b9:	mov    rsi,rbx
     1bc:	mov    rdi,r13
     1bf:	call   1c4 <botlish_fn_1+0xc4>
			1c0: R_X86_64_PLT32	rt_int_add-0x4
     1c4:	mov    rcx,rax
     1c7:	mov    QWORD PTR [rsp+0x10],rcx
     1cc:	mov    rdx,rbx
     1cf:	mov    rsi,r12
     1d2:	mov    rdi,r13
     1d5:	call   1da <botlish_fn_1+0xda>
			1d6: R_X86_64_PLT32	rt_substr-0x4
     1da:	test   rax,rax
     1dd:	jne    1fe <botlish_fn_1+0xfe>
     1e3:	xor    rax,rax
     1e6:	mov    rbx,QWORD PTR [rsp+0x20]
     1eb:	mov    r12,QWORD PTR [rsp+0x28]
     1f0:	mov    r13,QWORD PTR [rsp+0x30]
     1f5:	add    rsp,0x40
     1f9:	mov    rsp,rbp
     1fc:	pop    rbp
     1fd:	ret
     1fe:	mov    rbx,QWORD PTR [rsp+0x20]
     203:	mov    r12,QWORD PTR [rsp+0x28]
     208:	mov    r13,QWORD PTR [rsp+0x30]
     20d:	add    rsp,0x40
     211:	mov    rsp,rbp
     214:	pop    rbp
     215:	ret
     216:	mov    rdi,r13
     219:	mov    rax,QWORD PTR [rdi+0x10]
     21d:	mov    rax,QWORD PTR [rax+0x8]
     221:	mov    rbx,QWORD PTR [rsp+0x20]
     226:	mov    r12,QWORD PTR [rsp+0x28]
     22b:	mov    r13,QWORD PTR [rsp+0x30]
     230:	add    rsp,0x40
     234:	mov    rsp,rbp
     237:	pop    rbp
     238:	ret
     239:	add    BYTE PTR [rax],al
     23b:	add    BYTE PTR [rax],al
     23d:	add    BYTE PTR [rax],al
     23f:	add    BYTE PTR [rsi],al
     241:	add    BYTE PTR [rax],al
     243:	add    BYTE PTR [rax],al
     245:	add    BYTE PTR [rax],al
	...

0000000000000248 <botlish_entry_1: peek<str, int>>:
     248:	push   rbp
     249:	mov    rbp,rsp
     24c:	mov    rsi,QWORD PTR [rdx]
     24f:	mov    rdx,QWORD PTR [rdx+0x8]
     253:	call   258 <botlish_entry_1+0x10>
			254: R_X86_64_PLT32	botlish_fn_1-0x4 ; peek<str, int>
     258:	mov    rsp,rbp
     25b:	pop    rbp
     25c:	ret
     25d:	add    BYTE PTR [rax],al
	...

0000000000000260 <botlish_fn_2: quote_at?<str, int>>:
     260:	push   rbp
     261:	mov    rbp,rsp
     264:	sub    rsp,0x20
     268:	mov    QWORD PTR [rsp],rbx
     26c:	mov    QWORD PTR [rsp+0x8],r12
     271:	mov    QWORD PTR [rsp+0x10],r13
     276:	mov    rbx,rdx
     279:	mov    r13,rdi
     27c:	mov    rdx,QWORD PTR [rsi+0x8]
     280:	mov    r12,rsi
     283:	shl    rdx,1
     286:	mov    rax,rdx
     289:	or     rax,0x1
     28d:	mov    rcx,rbx
     290:	and    rcx,rax
     293:	test   rcx,0x1
     29a:	jne    2c4 <botlish_fn_2+0x64>
     2a0:	or     rdx,0x1
     2a4:	mov    rsi,rbx
     2a7:	mov    rdi,r13
     2aa:	call   2af <botlish_fn_2+0x4f>
			2ab: R_X86_64_PLT32	rt_int_cmp-0x4
     2af:	mov    ecx,0x2
     2b4:	test   rax,rax
     2b7:	cmovl  rcx,QWORD PTR [rip+0xa1]        # 360 <botlish_fn_2+0x100>
     2bf:	jmp    2db <botlish_fn_2+0x7b>
     2c4:	or     rdx,0x1
     2c8:	mov    ecx,0x2
     2cd:	mov    rax,rbx
     2d0:	cmp    rax,rdx
     2d3:	cmovl  rcx,QWORD PTR [rip+0x85]        # 360 <botlish_fn_2+0x100>
     2db:	mov    eax,0x6
     2e0:	cmp    rcx,0x6
     2e4:	je     2f7 <botlish_fn_2+0x97>
     2ea:	mov    eax,0x2
     2ef:	mov    r12,rax
     2f2:	jmp    344 <botlish_fn_2+0xe4>
     2f7:	mov    rdi,r13
     2fa:	mov    rsi,r12
     2fd:	mov    r12,rax
     300:	mov    rdx,rbx
     303:	call   308 <botlish_fn_2+0xa8>
			304: R_X86_64_PLT32	rt_str_char_at-0x4
     308:	test   rax,rax
     30b:	jne    32b <botlish_fn_2+0xcb>
     311:	xor    rax,rax
     314:	mov    rbx,QWORD PTR [rsp]
     318:	mov    r12,QWORD PTR [rsp+0x8]
     31d:	mov    r13,QWORD PTR [rsp+0x10]
     322:	add    rsp,0x20
     326:	mov    rsp,rbp
     329:	pop    rbp
     32a:	ret
     32b:	cmp    rax,0x114
     331:	je     341 <botlish_fn_2+0xe1>
     337:	mov    eax,0x2
     33c:	jmp    344 <botlish_fn_2+0xe4>
     341:	mov    rax,r12
     344:	mov    rbx,QWORD PTR [rsp]
     348:	mov    r12,QWORD PTR [rsp+0x8]
     34d:	mov    r13,QWORD PTR [rsp+0x10]
     352:	add    rsp,0x20
     356:	mov    rsp,rbp
     359:	pop    rbp
     35a:	ret
     35b:	add    BYTE PTR [rax],al
     35d:	add    BYTE PTR [rax],al
     35f:	add    BYTE PTR [rsi],al
     361:	add    BYTE PTR [rax],al
     363:	add    BYTE PTR [rax],al
     365:	add    BYTE PTR [rax],al
	...

0000000000000368 <botlish_entry_2: quote_at?<str, int>>:
     368:	push   rbp
     369:	mov    rbp,rsp
     36c:	mov    rsi,QWORD PTR [rdx]
     36f:	mov    rdx,QWORD PTR [rdx+0x8]
     373:	call   378 <botlish_entry_2+0x10>
			374: R_X86_64_PLT32	botlish_fn_2-0x4 ; quote_at?<str, int>
     378:	mov    rsp,rbp
     37b:	pop    rbp
     37c:	ret
     37d:	add    BYTE PTR [rax],al
	...

0000000000000380 <botlish_fn_3: scan_unquoted<str, int, int>>:
     380:	push   rbp
     381:	mov    rbp,rsp
     384:	sub    rsp,0x40
     388:	mov    QWORD PTR [rsp+0x20],rbx
     38d:	mov    QWORD PTR [rsp+0x28],r12
     392:	mov    QWORD PTR [rsp+0x30],r13
     397:	mov    QWORD PTR [rsp+0x38],r14
     39c:	mov    r13,rdi
     39f:	mov    QWORD PTR [rsp+0x18],0x0
     3a8:	mov    QWORD PTR [rsp],rsi
     3ac:	mov    r12,rsi
     3af:	mov    QWORD PTR [rsp+0x8],rdx
     3b4:	mov    rbx,rdx
     3b7:	mov    QWORD PTR [rsp+0x10],rcx
     3bc:	mov    rax,r12
     3bf:	mov    rsi,rcx
     3c2:	mov    rdx,QWORD PTR [rax+0x8]
     3c6:	mov    r12,rax
     3c9:	shl    rdx,1
     3cc:	or     rdx,0x1
     3d0:	mov    rax,rsi
     3d3:	and    rax,rdx
     3d6:	mov    r14,rsi
     3d9:	test   rax,0x1
     3df:	jne    405 <botlish_fn_3+0x85>
     3e5:	mov    rsi,r14
     3e8:	mov    rdi,r13
     3eb:	call   3f0 <botlish_fn_3+0x70>
			3ec: R_X86_64_PLT32	rt_int_cmp-0x4
     3f0:	mov    ecx,0x2
     3f5:	test   rax,rax
     3f8:	cmovl  rcx,QWORD PTR [rip+0x138]        # 538 <botlish_fn_3+0x1b8>
     400:	jmp    418 <botlish_fn_3+0x98>
     405:	mov    ecx,0x2
     40a:	mov    rsi,r14
     40d:	cmp    rsi,rdx
     410:	cmovl  rcx,QWORD PTR [rip+0x120]        # 538 <botlish_fn_3+0x1b8>
     418:	cmp    rcx,0x6
     41c:	je     430 <botlish_fn_3+0xb0>
     422:	mov    rdx,rbx
     425:	mov    rsi,r12
     428:	mov    rdi,r13
     42b:	jmp    4db <botlish_fn_3+0x15b>
     430:	mov    rdx,r14
     433:	mov    rsi,r12
     436:	mov    rdi,r13
     439:	call   43e <botlish_fn_3+0xbe>
			43a: R_X86_64_PLT32	rt_str_char_at-0x4
     43e:	test   rax,rax
     441:	je     4f2 <botlish_fn_3+0x172>
     447:	cmp    rax,0x164
     44d:	jne    45b <botlish_fn_3+0xdb>
     453:	mov    rdx,rbx
     456:	jmp    4d5 <botlish_fn_3+0x155>
     45b:	cmp    rax,0x54
     45f:	jne    46d <botlish_fn_3+0xed>
     465:	mov    rdx,rbx
     468:	jmp    4d5 <botlish_fn_3+0x155>
     46d:	mov    QWORD PTR [rsp+0x18],0x3
     476:	mov    rsi,r14
     479:	test   rsi,0x1
     480:	je     4a3 <botlish_fn_3+0x123>
     486:	mov    rsi,r14
     489:	mov    rax,rsi
     48c:	add    rax,0x2
     490:	seto   cl
     493:	test   cl,cl
     495:	jne    4a3 <botlish_fn_3+0x123>
     49b:	mov    rsi,r12
     49e:	jmp    4b6 <botlish_fn_3+0x136>
     4a3:	mov    edx,0x3
     4a8:	mov    rsi,r14
     4ab:	mov    rdi,r13
     4ae:	call   4b3 <botlish_fn_3+0x133>
			4af: R_X86_64_PLT32	rt_int_add-0x4
     4b3:	mov    rsi,r12
     4b6:	mov    rsi,r12
     4b9:	mov    QWORD PTR [rsp],rsi
     4bd:	mov    rdx,rbx
     4c0:	mov    QWORD PTR [rsp+0x8],rdx
     4c5:	mov    QWORD PTR [rsp+0x10],rax
     4ca:	mov    rsi,rax
     4cd:	mov    rax,r12
     4d0:	jmp    3c2 <botlish_fn_3+0x42>
     4d5:	mov    rsi,r12
     4d8:	mov    rdi,r13
     4db:	mov    rsi,r12
     4de:	mov    rdi,r13
     4e1:	mov    rcx,r14
     4e4:	call   4e9 <botlish_fn_3+0x169>
			4e5: R_X86_64_PLT32	rt_substr-0x4
     4e9:	test   rax,rax
     4ec:	jne    515 <botlish_fn_3+0x195>
     4f2:	xor    rdx,rdx
     4f5:	mov    rax,rdx
     4f8:	mov    rbx,QWORD PTR [rsp+0x20]
     4fd:	mov    r12,QWORD PTR [rsp+0x28]
     502:	mov    r13,QWORD PTR [rsp+0x30]
     507:	mov    r14,QWORD PTR [rsp+0x38]
     50c:	add    rsp,0x40
     510:	mov    rsp,rbp
     513:	pop    rbp
     514:	ret
     515:	mov    rdx,r14
     518:	mov    rbx,QWORD PTR [rsp+0x20]
     51d:	mov    r12,QWORD PTR [rsp+0x28]
     522:	mov    r13,QWORD PTR [rsp+0x30]
     527:	mov    r14,QWORD PTR [rsp+0x38]
     52c:	add    rsp,0x40
     530:	mov    rsp,rbp
     533:	pop    rbp
     534:	ret
     535:	add    BYTE PTR [rax],al
     537:	add    BYTE PTR [rsi],al
     539:	add    BYTE PTR [rax],al
     53b:	add    BYTE PTR [rax],al
     53d:	add    BYTE PTR [rax],al
	...

0000000000000540 <botlish_entry_3: scan_unquoted<str, int, int>>:
     540:	push   rbp
     541:	mov    rbp,rsp
     544:	ud2

0000000000000546 <botlish_fn_4: scan_quoted<str, int, str>>:
     546:	push   rbp
     547:	mov    rbp,rsp
     54a:	sub    rsp,0xb0
     551:	mov    QWORD PTR [rsp+0x80],rbx
     559:	mov    QWORD PTR [rsp+0x88],r12
     561:	mov    QWORD PTR [rsp+0x90],r13
     569:	mov    QWORD PTR [rsp+0x98],r14
     571:	mov    QWORD PTR [rsp+0xa0],r15
     579:	mov    r15,rdi
     57c:	mov    QWORD PTR [rsp+0x18],0x0
     585:	mov    QWORD PTR [rsp+0x20],0x0
     58e:	mov    QWORD PTR [rsp],rsi
     592:	mov    QWORD PTR [rsp+0x8],rdx
     597:	mov    QWORD PTR [rsp+0x10],rcx
     59c:	mov    r13,rcx
     59f:	lea    r12,[rsp+0x58]
     5a4:	mov    rbx,rsi
     5a7:	mov    QWORD PTR [rsp+0x78],rdx
     5ac:	mov    rdx,QWORD PTR [rsp+0x78]
     5b1:	mov    rsi,rbx
     5b4:	mov    rdi,r15
     5b7:	call   5bc <botlish_fn_4+0x76>
			5b8: R_X86_64_PLT32	botlish_fn_1-0x4 ; peek<str, int>
     5bc:	test   rax,rax
     5bf:	je     85b <botlish_fn_4+0x315>
     5c5:	mov    QWORD PTR [rsp+0x18],rax
     5ca:	mov    r14,rax
     5cd:	mov    rdx,QWORD PTR [rsp+0x78]
     5d2:	mov    rsi,rbx
     5d5:	mov    rdi,r15
     5d8:	call   5dd <botlish_fn_4+0x97>
			5d9: R_X86_64_PLT32	botlish_fn_2-0x4 ; quote_at?<str, int>
     5dd:	test   rax,rax
     5e0:	je     85b <botlish_fn_4+0x315>
     5e6:	cmp    rax,0x6
     5ea:	je     6a3 <botlish_fn_4+0x15d>
     5f0:	mov    QWORD PTR [rsp+0x20],0x3
     5f9:	mov    rsi,QWORD PTR [rsp+0x78]
     5fe:	test   rsi,0x1
     605:	je     62f <botlish_fn_4+0xe9>
     60b:	mov    rsi,QWORD PTR [rsp+0x78]
     610:	mov    rcx,rsi
     613:	add    rcx,0x2
     617:	seto   dl
     61a:	test   dl,dl
     61c:	jne    62f <botlish_fn_4+0xe9>
     622:	mov    rsi,rcx
     625:	mov    QWORD PTR [rsp+0x78],rcx
     62a:	jmp    649 <botlish_fn_4+0x103>
     62f:	mov    edx,0x3
     634:	mov    rsi,QWORD PTR [rsp+0x78]
     639:	mov    rdi,r15
     63c:	call   641 <botlish_fn_4+0xfb>
			63d: R_X86_64_PLT32	rt_int_add-0x4
     641:	mov    rsi,rax
     644:	mov    QWORD PTR [rsp+0x78],rax
     649:	mov    QWORD PTR [rsp+0x8],rsi
     64e:	mov    QWORD PTR [rsp+0x58],0x0
     657:	mov    QWORD PTR [rsp+0x60],r13
     65c:	mov    QWORD PTR [rsp+0x68],0x0
     665:	mov    QWORD PTR [rsp+0x70],r14
     66a:	mov    esi,0x2
     66f:	mov    edx,0x4
     674:	mov    rcx,r12
     677:	mov    rdi,r15
     67a:	call   67f <botlish_fn_4+0x139>
			67b: R_X86_64_PLT32	rt_construct-0x4
     67f:	test   rax,rax
     682:	je     85b <botlish_fn_4+0x315>
     688:	mov    QWORD PTR [rsp],rbx
     68c:	mov    rsi,QWORD PTR [rsp+0x78]
     691:	mov    QWORD PTR [rsp+0x8],rsi
     696:	mov    QWORD PTR [rsp+0x10],rax
     69b:	mov    r13,rax
     69e:	jmp    5ac <botlish_fn_4+0x66>
     6a3:	mov    QWORD PTR [rsp+0x20],0x3
     6ac:	mov    rsi,QWORD PTR [rsp+0x78]
     6b1:	test   rsi,0x1
     6b8:	je     6d5 <botlish_fn_4+0x18f>
     6be:	mov    rsi,QWORD PTR [rsp+0x78]
     6c3:	mov    rdx,rsi
     6c6:	add    rdx,0x2
     6ca:	seto   al
     6cd:	test   al,al
     6cf:	je     6ea <botlish_fn_4+0x1a4>
     6d5:	mov    edx,0x3
     6da:	mov    rsi,QWORD PTR [rsp+0x78]
     6df:	mov    rdi,r15
     6e2:	call   6e7 <botlish_fn_4+0x1a1>
			6e3: R_X86_64_PLT32	rt_int_add-0x4
     6e7:	mov    rdx,rax
     6ea:	mov    rsi,rbx
     6ed:	mov    rdi,r15
     6f0:	call   6f5 <botlish_fn_4+0x1af>
			6f1: R_X86_64_PLT32	botlish_fn_2-0x4 ; quote_at?<str, int>
     6f5:	test   rax,rax
     6f8:	je     85b <botlish_fn_4+0x315>
     6fe:	cmp    rax,0x6
     702:	je     7c1 <botlish_fn_4+0x27b>
     708:	xor    rsi,rsi
     70b:	lea    rcx,[rsp+0x48]
     710:	mov    QWORD PTR [rsp+0x48],0x0
     719:	mov    QWORD PTR [rsp+0x50],r13
     71e:	mov    edx,0x2
     723:	mov    rdi,r15
     726:	call   72b <botlish_fn_4+0x1e5>
			727: R_X86_64_PLT32	rt_construct-0x4
     72b:	test   rax,rax
     72e:	je     85b <botlish_fn_4+0x315>
     734:	mov    QWORD PTR [rsp],rax
     738:	mov    r12,rax
     73b:	mov    QWORD PTR [rsp+0x10],0x3
     744:	mov    rsi,QWORD PTR [rsp+0x78]
     749:	test   rsi,0x1
     750:	je     775 <botlish_fn_4+0x22f>
     756:	mov    rsi,QWORD PTR [rsp+0x78]
     75b:	mov    rdx,rsi
     75e:	add    rdx,0x2
     762:	seto   al
     765:	test   al,al
     767:	jne    775 <botlish_fn_4+0x22f>
     76d:	mov    rax,r12
     770:	jmp    78d <botlish_fn_4+0x247>
     775:	mov    edx,0x3
     77a:	mov    rsi,QWORD PTR [rsp+0x78]
     77f:	mov    rdi,r15
     782:	call   787 <botlish_fn_4+0x241>
			783: R_X86_64_PLT32	rt_int_add-0x4
     787:	mov    rdx,rax
     78a:	mov    rax,r12
     78d:	mov    rbx,QWORD PTR [rsp+0x80]
     795:	mov    r12,QWORD PTR [rsp+0x88]
     79d:	mov    r13,QWORD PTR [rsp+0x90]
     7a5:	mov    r14,QWORD PTR [rsp+0x98]
     7ad:	mov    r15,QWORD PTR [rsp+0xa0]
     7b5:	add    rsp,0xb0
     7bc:	mov    rsp,rbp
     7bf:	pop    rbp
     7c0:	ret
     7c1:	mov    QWORD PTR [rsp+0x20],0x5
     7ca:	mov    rsi,QWORD PTR [rsp+0x78]
     7cf:	test   rsi,0x1
     7d6:	je     800 <botlish_fn_4+0x2ba>
     7dc:	mov    rsi,QWORD PTR [rsp+0x78]
     7e1:	mov    rcx,rsi
     7e4:	add    rcx,0x4
     7e8:	seto   al
     7eb:	test   al,al
     7ed:	jne    800 <botlish_fn_4+0x2ba>
     7f3:	mov    rsi,rcx
     7f6:	mov    QWORD PTR [rsp+0x78],rcx
     7fb:	jmp    81a <botlish_fn_4+0x2d4>
     800:	mov    edx,0x5
     805:	mov    rsi,QWORD PTR [rsp+0x78]
     80a:	mov    rdi,r15
     80d:	call   812 <botlish_fn_4+0x2cc>
			80e: R_X86_64_PLT32	rt_int_add-0x4
     812:	mov    rsi,rax
     815:	mov    QWORD PTR [rsp+0x78],rax
     81a:	mov    QWORD PTR [rsp+0x8],rsi
     81f:	lea    rcx,[rsp+0x28]
     824:	mov    QWORD PTR [rsp+0x28],0x0
     82d:	mov    QWORD PTR [rsp+0x30],r13
     832:	mov    QWORD PTR [rsp+0x38],0x0
     83b:	mov    QWORD PTR [rsp+0x40],r14
     840:	mov    esi,0x2
     845:	mov    edx,0x4
     84a:	mov    rdi,r15
     84d:	call   852 <botlish_fn_4+0x30c>
			84e: R_X86_64_PLT32	rt_construct-0x4
     852:	test   rax,rax
     855:	jne    895 <botlish_fn_4+0x34f>
     85b:	xor    rdx,rdx
     85e:	mov    rax,rdx
     861:	mov    rbx,QWORD PTR [rsp+0x80]
     869:	mov    r12,QWORD PTR [rsp+0x88]
     871:	mov    r13,QWORD PTR [rsp+0x90]
     879:	mov    r14,QWORD PTR [rsp+0x98]
     881:	mov    r15,QWORD PTR [rsp+0xa0]
     889:	add    rsp,0xb0
     890:	mov    rsp,rbp
     893:	pop    rbp
     894:	ret
     895:	mov    QWORD PTR [rsp],rbx
     899:	mov    rsi,QWORD PTR [rsp+0x78]
     89e:	mov    QWORD PTR [rsp+0x8],rsi
     8a3:	mov    QWORD PTR [rsp+0x10],rax
     8a8:	mov    r13,rax
     8ab:	jmp    5ac <botlish_fn_4+0x66>

00000000000008b0 <botlish_entry_4: scan_quoted<str, int, str>>:
     8b0:	push   rbp
     8b1:	mov    rbp,rsp
     8b4:	ud2

00000000000008b6 <botlish_fn_5: scan_field<str, int>>:
     8b6:	push   rbp
     8b7:	mov    rbp,rsp
     8ba:	sub    rsp,0x40
     8be:	mov    QWORD PTR [rsp+0x20],rbx
     8c3:	mov    QWORD PTR [rsp+0x28],r12
     8c8:	mov    QWORD PTR [rsp+0x30],r13
     8cd:	mov    r12,rdi
     8d0:	mov    r13,rdx
     8d3:	mov    QWORD PTR [rsp+0x10],0x0
     8dc:	mov    QWORD PTR [rsp],rsi
     8e0:	mov    rbx,rsi
     8e3:	mov    QWORD PTR [rsp+0x8],rdx
     8e8:	mov    rdx,r13
     8eb:	mov    rsi,rbx
     8ee:	mov    rdi,r12
     8f1:	call   8f6 <botlish_fn_5+0x40>
			8f2: R_X86_64_PLT32	botlish_fn_2-0x4 ; quote_at?<str, int>
     8f6:	test   rax,rax
     8f9:	je     9aa <botlish_fn_5+0xf4>
     8ff:	cmp    rax,0x6
     903:	je     93b <botlish_fn_5+0x85>
     909:	mov    rcx,r13
     90c:	mov    rsi,rbx
     90f:	mov    rdi,r12
     912:	mov    rdx,rcx
     915:	call   91a <botlish_fn_5+0x64>
			916: R_X86_64_PLT32	botlish_fn_3-0x4 ; scan_unquoted<str, int, int>
     91a:	test   rax,rax
     91d:	je     9aa <botlish_fn_5+0xf4>
     923:	mov    rbx,QWORD PTR [rsp+0x20]
     928:	mov    r12,QWORD PTR [rsp+0x28]
     92d:	mov    r13,QWORD PTR [rsp+0x30]
     932:	add    rsp,0x40
     936:	mov    rsp,rbp
     939:	pop    rbp
     93a:	ret
     93b:	mov    rcx,r13
     93e:	mov    QWORD PTR [rsp+0x10],0x3
     947:	test   rcx,0x1
     94e:	jne    95c <botlish_fn_5+0xa6>
     954:	mov    r13,rcx
     957:	jmp    971 <botlish_fn_5+0xbb>
     95c:	mov    rdx,rcx
     95f:	add    rdx,0x2
     963:	mov    r13,rcx
     966:	seto   al
     969:	test   al,al
     96b:	je     984 <botlish_fn_5+0xce>
     971:	mov    edx,0x3
     976:	mov    rsi,r13
     979:	mov    rdi,r12
     97c:	call   981 <botlish_fn_5+0xcb>
			97d: R_X86_64_PLT32	rt_int_add-0x4
     981:	mov    rdx,rax
     984:	mov    QWORD PTR [rsp+0x8],rdx
     989:	mov    rdi,r12
     98c:	mov    rax,QWORD PTR [rdi+0x10]
     990:	mov    rcx,QWORD PTR [rax+0x8]
     994:	mov    QWORD PTR [rsp+0x10],rcx
     999:	mov    rsi,rbx
     99c:	call   9a1 <botlish_fn_5+0xeb>
			99d: R_X86_64_PLT32	botlish_fn_4-0x4 ; scan_quoted<str, int, str>
     9a1:	test   rax,rax
     9a4:	jne    9c8 <botlish_fn_5+0x112>
     9aa:	xor    rdx,rdx
     9ad:	mov    rax,rdx
     9b0:	mov    rbx,QWORD PTR [rsp+0x20]
     9b5:	mov    r12,QWORD PTR [rsp+0x28]
     9ba:	mov    r13,QWORD PTR [rsp+0x30]
     9bf:	add    rsp,0x40
     9c3:	mov    rsp,rbp
     9c6:	pop    rbp
     9c7:	ret
     9c8:	mov    rbx,QWORD PTR [rsp+0x20]
     9cd:	mov    r12,QWORD PTR [rsp+0x28]
     9d2:	mov    r13,QWORD PTR [rsp+0x30]
     9d7:	add    rsp,0x40
     9db:	mov    rsp,rbp
     9de:	pop    rbp
     9df:	ret

00000000000009e0 <botlish_entry_5: scan_field<str, int>>:
     9e0:	push   rbp
     9e1:	mov    rbp,rsp
     9e4:	ud2
	...

00000000000009e8 <botlish_fn_6: scan_record<str, int, List[never]>>:
     9e8:	push   rbp
     9e9:	mov    rbp,rsp
     9ec:	sub    rsp,0x80
     9f3:	mov    QWORD PTR [rsp+0x50],rbx
     9f8:	mov    QWORD PTR [rsp+0x58],r12
     9fd:	mov    QWORD PTR [rsp+0x60],r13
     a02:	mov    QWORD PTR [rsp+0x68],r14
     a07:	mov    QWORD PTR [rsp+0x70],r15
     a0c:	mov    r12,rdi
     a0f:	mov    QWORD PTR [rsp+0x18],0x0
     a18:	mov    QWORD PTR [rsp+0x20],0x0
     a21:	mov    QWORD PTR [rsp],rsi
     a25:	mov    r13,rsi
     a28:	mov    QWORD PTR [rsp+0x8],rdx
     a2d:	mov    QWORD PTR [rsp+0x10],rcx
     a32:	mov    r14,rcx
     a35:	mov    rsi,r13
     a38:	mov    rdi,r12
     a3b:	call   a40 <botlish_fn_6+0x58>
			a3c: R_X86_64_PLT32	botlish_fn_5-0x4 ; scan_field<str, int>
     a40:	mov    rbx,rdx
     a43:	test   rax,rax
     a46:	je     c77 <botlish_fn_6+0x28f>
     a4c:	mov    QWORD PTR [rsp+0x8],rax
     a51:	mov    rdx,rbx
     a54:	mov    r15,rax
     a57:	mov    QWORD PTR [rsp+0x18],rdx
     a5c:	mov    rsi,r13
     a5f:	mov    rdx,QWORD PTR [rsi+0x8]
     a63:	shl    rdx,1
     a66:	mov    rax,rdx
     a69:	or     rax,0x1
     a6d:	mov    rcx,rbx
     a70:	and    rcx,rax
     a73:	test   rcx,0x1
     a7a:	jne    aa4 <botlish_fn_6+0xbc>
     a80:	or     rdx,0x1
     a84:	mov    rsi,rbx
     a87:	mov    rdi,r12
     a8a:	call   a8f <botlish_fn_6+0xa7>
			a8b: R_X86_64_PLT32	rt_int_cmp-0x4
     a8f:	mov    ecx,0x2
     a94:	test   rax,rax
     a97:	cmovl  rcx,QWORD PTR [rip+0x229]        # cc8 <botlish_fn_6+0x2e0>
     a9f:	jmp    abb <botlish_fn_6+0xd3>
     aa4:	or     rdx,0x1
     aa8:	mov    ecx,0x2
     aad:	mov    rax,rbx
     ab0:	cmp    rax,rdx
     ab3:	cmovl  rcx,QWORD PTR [rip+0x20d]        # cc8 <botlish_fn_6+0x2e0>
     abb:	cmp    rcx,0x6
     abf:	je     ad3 <botlish_fn_6+0xeb>
     ac5:	mov    rdx,r15
     ac8:	mov    rsi,r14
     acb:	mov    rdi,r12
     ace:	jmp    b09 <botlish_fn_6+0x121>
     ad3:	mov    rdx,rbx
     ad6:	mov    rsi,r13
     ad9:	mov    rdi,r12
     adc:	call   ae1 <botlish_fn_6+0xf9>
			add: R_X86_64_PLT32	rt_str_char_at-0x4
     ae1:	test   rax,rax
     ae4:	je     c77 <botlish_fn_6+0x28f>
     aea:	cmp    rax,0x164
     af0:	je     bce <botlish_fn_6+0x1e6>
     af6:	cmp    rax,0x54
     afa:	je     b42 <botlish_fn_6+0x15a>
     b00:	mov    rdx,r15
     b03:	mov    rsi,r14
     b06:	mov    rdi,r12
     b09:	mov    rdi,r12
     b0c:	call   b11 <botlish_fn_6+0x129>
			b0d: R_X86_64_PLT32	rt_list_append-0x4
     b11:	test   rax,rax
     b14:	je     c77 <botlish_fn_6+0x28f>
     b1a:	mov    rdx,rbx
     b1d:	mov    rbx,QWORD PTR [rsp+0x50]
     b22:	mov    r12,QWORD PTR [rsp+0x58]
     b27:	mov    r13,QWORD PTR [rsp+0x60]
     b2c:	mov    r14,QWORD PTR [rsp+0x68]
     b31:	mov    r15,QWORD PTR [rsp+0x70]
     b36:	add    rsp,0x80
     b3d:	mov    rsp,rbp
     b40:	pop    rbp
     b41:	ret
     b42:	mov    rdx,r15
     b45:	mov    rsi,r14
     b48:	mov    rdi,r12
     b4b:	call   b50 <botlish_fn_6+0x168>
			b4c: R_X86_64_PLT32	rt_list_append-0x4
     b50:	test   rax,rax
     b53:	je     c77 <botlish_fn_6+0x28f>
     b59:	mov    QWORD PTR [rsp],rax
     b5d:	mov    r13,rax
     b60:	mov    QWORD PTR [rsp+0x8],0x3
     b69:	mov    rdx,rbx
     b6c:	test   rdx,0x1
     b73:	je     b93 <botlish_fn_6+0x1ab>
     b79:	mov    rdx,rbx
     b7c:	add    rdx,0x2
     b80:	seto   al
     b83:	test   al,al
     b85:	jne    b93 <botlish_fn_6+0x1ab>
     b8b:	mov    rax,r13
     b8e:	jmp    ba9 <botlish_fn_6+0x1c1>
     b93:	mov    edx,0x3
     b98:	mov    rsi,rbx
     b9b:	mov    rdi,r12
     b9e:	call   ba3 <botlish_fn_6+0x1bb>
			b9f: R_X86_64_PLT32	rt_int_add-0x4
     ba3:	mov    rdx,rax
     ba6:	mov    rax,r13
     ba9:	mov    rbx,QWORD PTR [rsp+0x50]
     bae:	mov    r12,QWORD PTR [rsp+0x58]
     bb3:	mov    r13,QWORD PTR [rsp+0x60]
     bb8:	mov    r14,QWORD PTR [rsp+0x68]
     bbd:	mov    r15,QWORD PTR [rsp+0x70]
     bc2:	add    rsp,0x80
     bc9:	mov    rsp,rbp
     bcc:	pop    rbp
     bcd:	ret
     bce:	mov    rsi,rbx
     bd1:	mov    ebx,0x3
     bd6:	mov    QWORD PTR [rsp+0x20],0x3
     bdf:	test   rsi,0x1
     be6:	je     bfe <botlish_fn_6+0x216>
     bec:	mov    rdx,rsi
     bef:	add    rdx,0x2
     bf3:	seto   al
     bf6:	test   al,al
     bf8:	je     c0c <botlish_fn_6+0x224>
     bfe:	mov    rdx,rbx
     c01:	mov    rdi,r12
     c04:	call   c09 <botlish_fn_6+0x221>
			c05: R_X86_64_PLT32	rt_int_add-0x4
     c09:	mov    rdx,rax
     c0c:	mov    QWORD PTR [rsp+0x18],rdx
     c11:	mov    QWORD PTR [rsp+0x48],rdx
     c16:	lea    rcx,[rsp+0x28]
     c1b:	mov    QWORD PTR [rsp+0x28],0x0
     c24:	mov    rsi,r14
     c27:	mov    QWORD PTR [rsp+0x30],rsi
     c2c:	mov    QWORD PTR [rsp+0x38],0x2
     c35:	mov    rdx,r15
     c38:	mov    QWORD PTR [rsp+0x40],rdx
     c3d:	mov    edx,0x4
     c42:	mov    rsi,rbx
     c45:	mov    rdi,r12
     c48:	call   c4d <botlish_fn_6+0x265>
			c49: R_X86_64_PLT32	rt_construct-0x4
     c4d:	test   rax,rax
     c50:	je     c77 <botlish_fn_6+0x28f>
     c56:	mov    QWORD PTR [rsp+0x8],rax
     c5b:	mov    rcx,rax
     c5e:	mov    rdx,QWORD PTR [rsp+0x48]
     c63:	mov    rsi,r13
     c66:	mov    rdi,r12
     c69:	call   c6e <botlish_fn_6+0x286>
			c6a: R_X86_64_PLT32	botlish_fn_7-0x4 ; scan_record<str, int, List[str]>
     c6e:	test   rax,rax
     c71:	jne    ca2 <botlish_fn_6+0x2ba>
     c77:	xor    rdx,rdx
     c7a:	mov    rax,rdx
     c7d:	mov    rbx,QWORD PTR [rsp+0x50]
     c82:	mov    r12,QWORD PTR [rsp+0x58]
     c87:	mov    r13,QWORD PTR [rsp+0x60]
     c8c:	mov    r14,QWORD PTR [rsp+0x68]
     c91:	mov    r15,QWORD PTR [rsp+0x70]
     c96:	add    rsp,0x80
     c9d:	mov    rsp,rbp
     ca0:	pop    rbp
     ca1:	ret
     ca2:	mov    rbx,QWORD PTR [rsp+0x50]
     ca7:	mov    r12,QWORD PTR [rsp+0x58]
     cac:	mov    r13,QWORD PTR [rsp+0x60]
     cb1:	mov    r14,QWORD PTR [rsp+0x68]
     cb6:	mov    r15,QWORD PTR [rsp+0x70]
     cbb:	add    rsp,0x80
     cc2:	mov    rsp,rbp
     cc5:	pop    rbp
     cc6:	ret
     cc7:	add    BYTE PTR [rsi],al
     cc9:	add    BYTE PTR [rax],al
     ccb:	add    BYTE PTR [rax],al
     ccd:	add    BYTE PTR [rax],al
	...

0000000000000cd0 <botlish_entry_6: scan_record<str, int, List[never]>>:
     cd0:	push   rbp
     cd1:	mov    rbp,rsp
     cd4:	ud2
	...

0000000000000cd8 <botlish_fn_7: scan_record<str, int, List[str]>>:
     cd8:	push   rbp
     cd9:	mov    rbp,rsp
     cdc:	sub    rsp,0xc0
     ce3:	mov    QWORD PTR [rsp+0x90],rbx
     ceb:	mov    QWORD PTR [rsp+0x98],r12
     cf3:	mov    QWORD PTR [rsp+0xa0],r13
     cfb:	mov    QWORD PTR [rsp+0xa8],r14
     d03:	mov    QWORD PTR [rsp+0xb0],r15
     d0b:	mov    r15,rdi
     d0e:	mov    QWORD PTR [rsp+0x18],0x0
     d17:	mov    QWORD PTR [rsp+0x20],0x0
     d20:	mov    QWORD PTR [rsp],rsi
     d24:	mov    QWORD PTR [rsp+0x8],rdx
     d29:	mov    QWORD PTR [rsp+0x88],rdx
     d31:	mov    QWORD PTR [rsp+0x10],rcx
     d36:	mov    r13,rcx
     d39:	mov    rbx,rsi
     d3c:	mov    rsi,rbx
     d3f:	mov    rdi,r15
     d42:	call   d47 <botlish_fn_7+0x6f>
			d43: R_X86_64_PLT32	botlish_fn_5-0x4 ; scan_field<str, int>
     d47:	mov    r12,rdx
     d4a:	test   rax,rax
     d4d:	je     fa6 <botlish_fn_7+0x2ce>
     d53:	mov    QWORD PTR [rsp+0x8],rax
     d58:	mov    rdx,r12
     d5b:	mov    r14,rax
     d5e:	mov    QWORD PTR [rsp+0x18],rdx
     d63:	mov    rdx,QWORD PTR [rbx+0x8]
     d67:	shl    rdx,1
     d6a:	or     rdx,0x1
     d6e:	mov    rax,r12
     d71:	and    rax,rdx
     d74:	test   rax,0x1
     d7a:	jne    da0 <botlish_fn_7+0xc8>
     d80:	mov    rsi,r12
     d83:	mov    rdi,r15
     d86:	call   d8b <botlish_fn_7+0xb3>
			d87: R_X86_64_PLT32	rt_int_cmp-0x4
     d8b:	mov    ecx,0x2
     d90:	test   rax,rax
     d93:	cmovl  rcx,QWORD PTR [rip+0x265]        # 1000 <botlish_fn_7+0x328>
     d9b:	jmp    db3 <botlish_fn_7+0xdb>
     da0:	mov    ecx,0x2
     da5:	mov    rax,r12
     da8:	cmp    rax,rdx
     dab:	cmovl  rcx,QWORD PTR [rip+0x24d]        # 1000 <botlish_fn_7+0x328>
     db3:	cmp    rcx,0x6
     db7:	jne    dea <botlish_fn_7+0x112>
     dbd:	mov    rdx,r12
     dc0:	mov    rsi,rbx
     dc3:	mov    rdi,r15
     dc6:	call   dcb <botlish_fn_7+0xf3>
			dc7: R_X86_64_PLT32	rt_str_char_at-0x4
     dcb:	test   rax,rax
     dce:	je     fa6 <botlish_fn_7+0x2ce>
     dd4:	cmp    rax,0x164
     dda:	je     f20 <botlish_fn_7+0x248>
     de0:	cmp    rax,0x54
     de4:	je     e60 <botlish_fn_7+0x188>
     dea:	lea    rcx,[rsp+0x68]
     def:	mov    QWORD PTR [rsp+0x68],0x0
     df8:	mov    QWORD PTR [rsp+0x70],r13
     dfd:	mov    QWORD PTR [rsp+0x78],0x2
     e06:	mov    QWORD PTR [rsp+0x80],r14
     e0e:	mov    esi,0x1
     e13:	mov    edx,0x4
     e18:	mov    rdi,r15
     e1b:	call   e20 <botlish_fn_7+0x148>
			e1c: R_X86_64_PLT32	rt_construct-0x4
     e20:	test   rax,rax
     e23:	je     fa6 <botlish_fn_7+0x2ce>
     e29:	mov    rdx,r12
     e2c:	mov    rbx,QWORD PTR [rsp+0x90]
     e34:	mov    r12,QWORD PTR [rsp+0x98]
     e3c:	mov    r13,QWORD PTR [rsp+0xa0]
     e44:	mov    r14,QWORD PTR [rsp+0xa8]
     e4c:	mov    r15,QWORD PTR [rsp+0xb0]
     e54:	add    rsp,0xc0
     e5b:	mov    rsp,rbp
     e5e:	pop    rbp
     e5f:	ret
     e60:	lea    rcx,[rsp+0x48]
     e65:	mov    QWORD PTR [rsp+0x48],0x0
     e6e:	mov    QWORD PTR [rsp+0x50],r13
     e73:	mov    QWORD PTR [rsp+0x58],0x2
     e7c:	mov    QWORD PTR [rsp+0x60],r14
     e81:	mov    esi,0x1
     e86:	mov    edx,0x4
     e8b:	mov    rdi,r15
     e8e:	call   e93 <botlish_fn_7+0x1bb>
			e8f: R_X86_64_PLT32	rt_construct-0x4
     e93:	test   rax,rax
     e96:	je     fa6 <botlish_fn_7+0x2ce>
     e9c:	mov    QWORD PTR [rsp],rax
     ea0:	mov    r13,rax
     ea3:	mov    QWORD PTR [rsp+0x8],0x3
     eac:	mov    rdx,r12
     eaf:	test   rdx,0x1
     eb6:	je     ed6 <botlish_fn_7+0x1fe>
     ebc:	mov    rdx,r12
     ebf:	add    rdx,0x2
     ec3:	seto   al
     ec6:	test   al,al
     ec8:	jne    ed6 <botlish_fn_7+0x1fe>
     ece:	mov    rax,r13
     ed1:	jmp    eec <botlish_fn_7+0x214>
     ed6:	mov    edx,0x3
     edb:	mov    rsi,r12
     ede:	mov    rdi,r15
     ee1:	call   ee6 <botlish_fn_7+0x20e>
			ee2: R_X86_64_PLT32	rt_int_add-0x4
     ee6:	mov    rdx,rax
     ee9:	mov    rax,r13
     eec:	mov    rbx,QWORD PTR [rsp+0x90]
     ef4:	mov    r12,QWORD PTR [rsp+0x98]
     efc:	mov    r13,QWORD PTR [rsp+0xa0]
     f04:	mov    r14,QWORD PTR [rsp+0xa8]
     f0c:	mov    r15,QWORD PTR [rsp+0xb0]
     f14:	add    rsp,0xc0
     f1b:	mov    rsp,rbp
     f1e:	pop    rbp
     f1f:	ret
     f20:	mov    rsi,r12
     f23:	mov    r12d,0x3
     f29:	mov    QWORD PTR [rsp+0x20],0x3
     f32:	test   rsi,0x1
     f39:	je     f51 <botlish_fn_7+0x279>
     f3f:	mov    rdx,rsi
     f42:	add    rdx,0x2
     f46:	seto   al
     f49:	test   al,al
     f4b:	je     f5f <botlish_fn_7+0x287>
     f51:	mov    rdx,r12
     f54:	mov    rdi,r15
     f57:	call   f5c <botlish_fn_7+0x284>
			f58: R_X86_64_PLT32	rt_int_add-0x4
     f5c:	mov    rdx,rax
     f5f:	mov    QWORD PTR [rsp+0x18],rdx
     f64:	mov    QWORD PTR [rsp+0x88],rdx
     f6c:	lea    rcx,[rsp+0x28]
     f71:	mov    QWORD PTR [rsp+0x28],0x0
     f7a:	mov    QWORD PTR [rsp+0x30],r13
     f7f:	mov    QWORD PTR [rsp+0x38],0x2
     f88:	mov    QWORD PTR [rsp+0x40],r14
     f8d:	mov    edx,0x4
     f92:	mov    rsi,r12
     f95:	mov    rdi,r15
     f98:	call   f9d <botlish_fn_7+0x2c5>
			f99: R_X86_64_PLT32	rt_construct-0x4
     f9d:	test   rax,rax
     fa0:	jne    fe0 <botlish_fn_7+0x308>
     fa6:	xor    rdx,rdx
     fa9:	mov    rax,rdx
     fac:	mov    rbx,QWORD PTR [rsp+0x90]
     fb4:	mov    r12,QWORD PTR [rsp+0x98]
     fbc:	mov    r13,QWORD PTR [rsp+0xa0]
     fc4:	mov    r14,QWORD PTR [rsp+0xa8]
     fcc:	mov    r15,QWORD PTR [rsp+0xb0]
     fd4:	add    rsp,0xc0
     fdb:	mov    rsp,rbp
     fde:	pop    rbp
     fdf:	ret
     fe0:	mov    QWORD PTR [rsp],rbx
     fe4:	mov    rdx,QWORD PTR [rsp+0x88]
     fec:	mov    QWORD PTR [rsp+0x8],rdx
     ff1:	mov    QWORD PTR [rsp+0x10],rax
     ff6:	mov    r13,rax
     ff9:	jmp    d3c <botlish_fn_7+0x64>
     ffe:	add    BYTE PTR [rax],al
    1000:	(bad)
    1001:	add    BYTE PTR [rax],al
    1003:	add    BYTE PTR [rax],al
    1005:	add    BYTE PTR [rax],al
	...

0000000000001008 <botlish_entry_7: scan_record<str, int, List[str]>>:
    1008:	push   rbp
    1009:	mov    rbp,rsp
    100c:	ud2

000000000000100e <botlish_fn_8: scan_records<str, int, List[never]>>:
    100e:	push   rbp
    100f:	mov    rbp,rsp
    1012:	sub    rsp,0x60
    1016:	mov    QWORD PTR [rsp+0x40],rbx
    101b:	mov    QWORD PTR [rsp+0x48],r12
    1020:	mov    QWORD PTR [rsp+0x50],r13
    1025:	mov    QWORD PTR [rsp+0x58],r14
    102a:	mov    r12,rdi
    102d:	mov    QWORD PTR [rsp+0x18],0x0
    1036:	mov    QWORD PTR [rsp],rsi
    103a:	mov    QWORD PTR [rsp+0x8],rdx
    103f:	mov    QWORD PTR [rsp+0x10],rcx
    1044:	mov    r13,rcx
    1047:	mov    rax,QWORD PTR [rsi+0x8]
    104b:	mov    rbx,rsi
    104e:	mov    rcx,rdx
    1051:	sar    rcx,1
    1054:	mov    r14,rdx
    1057:	shl    rax,1
    105a:	or     rax,0x1
    105e:	sar    rax,1
    1061:	cmp    rcx,rax
    1064:	jge    1148 <botlish_fn_8+0x13a>
    106a:	xor    rdx,rdx
    106d:	mov    rdi,r12
    1070:	mov    rsi,rdx
    1073:	call   1078 <botlish_fn_8+0x6a>
			1074: R_X86_64_PLT32	rt_list_new-0x4
    1078:	test   rax,rax
    107b:	je     110b <botlish_fn_8+0xfd>
    1081:	mov    QWORD PTR [rsp+0x18],rax
    1086:	mov    rcx,rax
    1089:	mov    rdx,r14
    108c:	mov    rsi,rbx
    108f:	mov    rdi,r12
    1092:	call   1097 <botlish_fn_8+0x89>
			1093: R_X86_64_PLT32	botlish_fn_6-0x4 ; scan_record<str, int, List[never]>
    1097:	test   rax,rax
    109a:	je     110b <botlish_fn_8+0xfd>
    10a0:	mov    QWORD PTR [rsp+0x8],rax
    10a5:	mov    QWORD PTR [rsp+0x18],rdx
    10aa:	mov    r14,rdx
    10ad:	lea    rcx,[rsp+0x20]
    10b2:	mov    QWORD PTR [rsp+0x20],0x0
    10bb:	mov    rdx,r13
    10be:	mov    QWORD PTR [rsp+0x28],rdx
    10c3:	mov    QWORD PTR [rsp+0x30],0x2
    10cc:	mov    QWORD PTR [rsp+0x38],rax
    10d1:	mov    esi,0x3
    10d6:	mov    edx,0x4
    10db:	mov    rdi,r12
    10de:	call   10e3 <botlish_fn_8+0xd5>
			10df: R_X86_64_PLT32	rt_construct-0x4
    10e3:	test   rax,rax
    10e6:	je     110b <botlish_fn_8+0xfd>
    10ec:	mov    QWORD PTR [rsp+0x8],rax
    10f1:	mov    rcx,rax
    10f4:	mov    rdx,r14
    10f7:	mov    rsi,rbx
    10fa:	mov    rdi,r12
    10fd:	call   1102 <botlish_fn_8+0xf4>
			10fe: R_X86_64_PLT32	botlish_fn_9-0x4 ; scan_records<str, int, List[List[str]]>
    1102:	test   rax,rax
    1105:	jne    112b <botlish_fn_8+0x11d>
    110b:	xor    rax,rax
    110e:	mov    rbx,QWORD PTR [rsp+0x40]
    1113:	mov    r12,QWORD PTR [rsp+0x48]
    1118:	mov    r13,QWORD PTR [rsp+0x50]
    111d:	mov    r14,QWORD PTR [rsp+0x58]
    1122:	add    rsp,0x60
    1126:	mov    rsp,rbp
    1129:	pop    rbp
    112a:	ret
    112b:	mov    rbx,QWORD PTR [rsp+0x40]
    1130:	mov    r12,QWORD PTR [rsp+0x48]
    1135:	mov    r13,QWORD PTR [rsp+0x50]
    113a:	mov    r14,QWORD PTR [rsp+0x58]
    113f:	add    rsp,0x60
    1143:	mov    rsp,rbp
    1146:	pop    rbp
    1147:	ret
    1148:	mov    rax,r13
    114b:	mov    rbx,QWORD PTR [rsp+0x40]
    1150:	mov    r12,QWORD PTR [rsp+0x48]
    1155:	mov    r13,QWORD PTR [rsp+0x50]
    115a:	mov    r14,QWORD PTR [rsp+0x58]
    115f:	add    rsp,0x60
    1163:	mov    rsp,rbp
    1166:	pop    rbp
    1167:	ret

0000000000001168 <botlish_entry_8: scan_records<str, int, List[never]>>:
    1168:	push   rbp
    1169:	mov    rbp,rsp
    116c:	mov    rsi,QWORD PTR [rdx]
    116f:	mov    r8,QWORD PTR [rdx+0x8]
    1173:	mov    rcx,QWORD PTR [rdx+0x10]
    1177:	mov    rdx,r8
    117a:	call   117f <botlish_entry_8+0x17>
			117b: R_X86_64_PLT32	botlish_fn_8-0x4 ; scan_records<str, int, List[never]>
    117f:	mov    rsp,rbp
    1182:	pop    rbp
    1183:	ret
    1184:	add    BYTE PTR [rax],al
	...

0000000000001188 <botlish_fn_9: scan_records<str, int, List[List[str]]>>:
    1188:	push   rbp
    1189:	mov    rbp,rsp
    118c:	sub    rsp,0x80
    1193:	mov    QWORD PTR [rsp+0x50],rbx
    1198:	mov    QWORD PTR [rsp+0x58],r12
    119d:	mov    QWORD PTR [rsp+0x60],r13
    11a2:	mov    QWORD PTR [rsp+0x68],r14
    11a7:	mov    QWORD PTR [rsp+0x70],r15
    11ac:	mov    r14,rdi
    11af:	mov    QWORD PTR [rsp+0x18],0x0
    11b8:	mov    QWORD PTR [rsp],rsi
    11bc:	mov    QWORD PTR [rsp+0x8],rdx
    11c1:	mov    r13,rdx
    11c4:	mov    QWORD PTR [rsp+0x10],rcx
    11c9:	mov    r15,rcx
    11cc:	lea    r12,[rsp+0x30]
    11d1:	mov    rbx,rsi
    11d4:	mov    rdx,QWORD PTR [rbx+0x8]
    11d8:	shl    rdx,1
    11db:	or     rdx,0x1
    11df:	mov    rax,r13
    11e2:	and    rax,rdx
    11e5:	test   rax,0x1
    11eb:	jne    1211 <botlish_fn_9+0x89>
    11f1:	mov    rsi,r13
    11f4:	mov    rdi,r14
    11f7:	call   11fc <botlish_fn_9+0x74>
			11f8: R_X86_64_PLT32	rt_int_cmp-0x4
    11fc:	mov    ecx,0x2
    1201:	test   rax,rax
    1204:	cmovge rcx,QWORD PTR [rip+0x13c]        # 1348 <botlish_fn_9+0x1c0>
    120c:	jmp    1224 <botlish_fn_9+0x9c>
    1211:	mov    ecx,0x2
    1216:	mov    rax,r13
    1219:	cmp    rax,rdx
    121c:	cmovge rcx,QWORD PTR [rip+0x124]        # 1348 <botlish_fn_9+0x1c0>
    1224:	cmp    rcx,0x6
    1228:	je     12c7 <botlish_fn_9+0x13f>
    122e:	xor    rdx,rdx
    1231:	mov    rdi,r14
    1234:	mov    rsi,rdx
    1237:	call   123c <botlish_fn_9+0xb4>
			1238: R_X86_64_PLT32	rt_list_new-0x4
    123c:	test   rax,rax
    123f:	je     12f8 <botlish_fn_9+0x170>
    1245:	mov    QWORD PTR [rsp+0x18],rax
    124a:	mov    rcx,rax
    124d:	mov    rdx,r13
    1250:	mov    rsi,rbx
    1253:	mov    rdi,r14
    1256:	call   125b <botlish_fn_9+0xd3>
			1257: R_X86_64_PLT32	botlish_fn_6-0x4 ; scan_record<str, int, List[never]>
    125b:	test   rax,rax
    125e:	je     12f8 <botlish_fn_9+0x170>
    1264:	mov    QWORD PTR [rsp+0x8],rax
    1269:	mov    QWORD PTR [rsp+0x18],rdx
    126e:	mov    r13,rdx
    1271:	mov    QWORD PTR [rsp+0x30],0x0
    127a:	mov    rdx,r15
    127d:	mov    QWORD PTR [rsp+0x38],rdx
    1282:	mov    QWORD PTR [rsp+0x40],0x2
    128b:	mov    QWORD PTR [rsp+0x48],rax
    1290:	mov    esi,0x3
    1295:	mov    edx,0x4
    129a:	mov    rcx,r12
    129d:	mov    rdi,r14
    12a0:	call   12a5 <botlish_fn_9+0x11d>
			12a1: R_X86_64_PLT32	rt_construct-0x4
    12a5:	test   rax,rax
    12a8:	je     12f8 <botlish_fn_9+0x170>
    12ae:	mov    QWORD PTR [rsp],rbx
    12b2:	mov    rdx,r13
    12b5:	mov    QWORD PTR [rsp+0x8],rdx
    12ba:	mov    QWORD PTR [rsp+0x10],rax
    12bf:	mov    r15,rax
    12c2:	jmp    11d4 <botlish_fn_9+0x4c>
    12c7:	mov    rdx,r15
    12ca:	lea    rcx,[rsp+0x20]
    12cf:	mov    QWORD PTR [rsp+0x20],0x0
    12d8:	mov    QWORD PTR [rsp+0x28],rdx
    12dd:	mov    esi,0x1
    12e2:	mov    edx,0x2
    12e7:	mov    rdi,r14
    12ea:	call   12ef <botlish_fn_9+0x167>
			12eb: R_X86_64_PLT32	rt_construct-0x4
    12ef:	test   rax,rax
    12f2:	jne    1320 <botlish_fn_9+0x198>
    12f8:	xor    rax,rax
    12fb:	mov    rbx,QWORD PTR [rsp+0x50]
    1300:	mov    r12,QWORD PTR [rsp+0x58]
    1305:	mov    r13,QWORD PTR [rsp+0x60]
    130a:	mov    r14,QWORD PTR [rsp+0x68]
    130f:	mov    r15,QWORD PTR [rsp+0x70]
    1314:	add    rsp,0x80
    131b:	mov    rsp,rbp
    131e:	pop    rbp
    131f:	ret
    1320:	mov    rbx,QWORD PTR [rsp+0x50]
    1325:	mov    r12,QWORD PTR [rsp+0x58]
    132a:	mov    r13,QWORD PTR [rsp+0x60]
    132f:	mov    r14,QWORD PTR [rsp+0x68]
    1334:	mov    r15,QWORD PTR [rsp+0x70]
    1339:	add    rsp,0x80
    1340:	mov    rsp,rbp
    1343:	pop    rbp
    1344:	ret
    1345:	add    BYTE PTR [rax],al
    1347:	add    BYTE PTR [rsi],al
    1349:	add    BYTE PTR [rax],al
    134b:	add    BYTE PTR [rax],al
    134d:	add    BYTE PTR [rax],al
	...

0000000000001350 <botlish_entry_9: scan_records<str, int, List[List[str]]>>:
    1350:	push   rbp
    1351:	mov    rbp,rsp
    1354:	mov    rsi,QWORD PTR [rdx]
    1357:	mov    r8,QWORD PTR [rdx+0x8]
    135b:	mov    rcx,QWORD PTR [rdx+0x10]
    135f:	mov    rdx,r8
    1362:	call   1367 <botlish_entry_9+0x17>
			1363: R_X86_64_PLT32	botlish_fn_9-0x4 ; scan_records<str, int, List[List[str]]>
    1367:	mov    rsp,rbp
    136a:	pop    rbp
    136b:	ret

000000000000136c <botlish_fn_10: csv_parse<str>>:
    136c:	push   rbp
    136d:	mov    rbp,rsp
    1370:	sub    rsp,0x30
    1374:	mov    QWORD PTR [rsp+0x20],r12
    1379:	mov    QWORD PTR [rsp+0x28],r13
    137e:	mov    r13,rdi
    1381:	mov    QWORD PTR [rsp+0x10],0x0
    138a:	mov    QWORD PTR [rsp],rsi
    138e:	mov    r12,rsi
    1391:	mov    QWORD PTR [rsp+0x8],0x1
    139a:	xor    rdx,rdx
    139d:	mov    rdi,r13
    13a0:	mov    rsi,rdx
    13a3:	call   13a8 <botlish_fn_10+0x3c>
			13a4: R_X86_64_PLT32	rt_list_new-0x4
    13a8:	test   rax,rax
    13ab:	je     13d2 <botlish_fn_10+0x66>
    13b1:	mov    QWORD PTR [rsp+0x10],rax
    13b6:	mov    rcx,rax
    13b9:	mov    edx,0x1
    13be:	mov    rsi,r12
    13c1:	mov    rdi,r13
    13c4:	call   13c9 <botlish_fn_10+0x5d>
			13c5: R_X86_64_PLT32	botlish_fn_8-0x4 ; scan_records<str, int, List[never]>
    13c9:	test   rax,rax
    13cc:	jne    13e8 <botlish_fn_10+0x7c>
    13d2:	xor    rax,rax
    13d5:	mov    r12,QWORD PTR [rsp+0x20]
    13da:	mov    r13,QWORD PTR [rsp+0x28]
    13df:	add    rsp,0x30
    13e3:	mov    rsp,rbp
    13e6:	pop    rbp
    13e7:	ret
    13e8:	mov    r12,QWORD PTR [rsp+0x20]
    13ed:	mov    r13,QWORD PTR [rsp+0x28]
    13f2:	add    rsp,0x30
    13f6:	mov    rsp,rbp
    13f9:	pop    rbp
    13fa:	ret

00000000000013fb <botlish_entry_10: csv_parse<str>>:
    13fb:	push   rbp
    13fc:	mov    rbp,rsp
    13ff:	mov    rsi,QWORD PTR [rdx]
    1402:	call   1407 <botlish_entry_10+0xc>
			1403: R_X86_64_PLT32	botlish_fn_10-0x4 ; csv_parse<str>
    1407:	mov    rsp,rbp
    140a:	pop    rbp
    140b:	ret
