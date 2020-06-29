
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	0000a117          	auipc	sp,0xa
    80000004:	80010113          	addi	sp,sp,-2048 # 80009800 <stack0>
    80000008:	6505                	lui	a0,0x1
    8000000a:	f14025f3          	csrr	a1,mhartid
    8000000e:	0585                	addi	a1,a1,1
    80000010:	02b50533          	mul	a0,a0,a1
    80000014:	912a                	add	sp,sp,a0
    80000016:	070000ef          	jal	ra,80000086 <start>

000000008000001a <junk>:
    8000001a:	a001                	j	8000001a <junk>

000000008000001c <timerinit>:
// which arrive at timervec in kernelvec.S,
// which turns them into software interrupts for
// devintr() in trap.c.
void
timerinit()
{
    8000001c:	1141                	addi	sp,sp,-16
    8000001e:	e422                	sd	s0,8(sp)
    80000020:	0800                	addi	s0,sp,16
// which hart (core) is this?
static inline uint64
r_mhartid()
{
  uint64 x;
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    80000022:	f14027f3          	csrr	a5,mhartid
  // each CPU has a separate source of timer interrupts.
  int id = r_mhartid();

  // ask the CLINT for a timer interrupt.
  int interval = 1000000; // cycles; about 1/10th second in qemu.
  *(uint64*)CLINT_MTIMECMP(id) = *(uint64*)CLINT_MTIME + interval;
    80000026:	0037969b          	slliw	a3,a5,0x3
    8000002a:	02004737          	lui	a4,0x2004
    8000002e:	96ba                	add	a3,a3,a4
    80000030:	0200c737          	lui	a4,0x200c
    80000034:	ff873603          	ld	a2,-8(a4) # 200bff8 <_entry-0x7dff4008>
    80000038:	000f4737          	lui	a4,0xf4
    8000003c:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    80000040:	963a                	add	a2,a2,a4
    80000042:	e290                	sd	a2,0(a3)

  // prepare information in scratch[] for timervec.
  // scratch[0..3] : space for timervec to save registers.
  // scratch[4] : address of CLINT MTIMECMP register.
  // scratch[5] : desired interval (in cycles) between timer interrupts.
  uint64 *scratch = &mscratch0[32 * id];
    80000044:	0057979b          	slliw	a5,a5,0x5
    80000048:	078e                	slli	a5,a5,0x3
    8000004a:	00009617          	auipc	a2,0x9
    8000004e:	fb660613          	addi	a2,a2,-74 # 80009000 <mscratch0>
    80000052:	97b2                	add	a5,a5,a2
  scratch[4] = CLINT_MTIMECMP(id);
    80000054:	f394                	sd	a3,32(a5)
  scratch[5] = interval;
    80000056:	f798                	sd	a4,40(a5)
}

static inline void 
w_mscratch(uint64 x)
{
  asm volatile("csrw mscratch, %0" : : "r" (x));
    80000058:	34079073          	csrw	mscratch,a5
  asm volatile("csrw mtvec, %0" : : "r" (x));
    8000005c:	00006797          	auipc	a5,0x6
    80000060:	ae478793          	addi	a5,a5,-1308 # 80005b40 <timervec>
    80000064:	30579073          	csrw	mtvec,a5
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    80000068:	300027f3          	csrr	a5,mstatus

  // set the machine-mode trap handler.
  w_mtvec((uint64)timervec);

  // enable machine-mode interrupts.
  w_mstatus(r_mstatus() | MSTATUS_MIE);
    8000006c:	0087e793          	ori	a5,a5,8
  asm volatile("csrw mstatus, %0" : : "r" (x));
    80000070:	30079073          	csrw	mstatus,a5
  asm volatile("csrr %0, mie" : "=r" (x) );
    80000074:	304027f3          	csrr	a5,mie

  // enable machine-mode timer interrupts.
  w_mie(r_mie() | MIE_MTIE);
    80000078:	0807e793          	ori	a5,a5,128
  asm volatile("csrw mie, %0" : : "r" (x));
    8000007c:	30479073          	csrw	mie,a5
}
    80000080:	6422                	ld	s0,8(sp)
    80000082:	0141                	addi	sp,sp,16
    80000084:	8082                	ret

0000000080000086 <start>:
{
    80000086:	1141                	addi	sp,sp,-16
    80000088:	e406                	sd	ra,8(sp)
    8000008a:	e022                	sd	s0,0(sp)
    8000008c:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    8000008e:	300027f3          	csrr	a5,mstatus
  x &= ~MSTATUS_MPP_MASK;
    80000092:	7779                	lui	a4,0xffffe
    80000094:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffd87e3>
    80000098:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    8000009a:	6705                	lui	a4,0x1
    8000009c:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    800000a0:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    800000a2:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    800000a6:	00001797          	auipc	a5,0x1
    800000aa:	c7a78793          	addi	a5,a5,-902 # 80000d20 <main>
    800000ae:	34179073          	csrw	mepc,a5
  asm volatile("csrw satp, %0" : : "r" (x));
    800000b2:	4781                	li	a5,0
    800000b4:	18079073          	csrw	satp,a5
  asm volatile("csrw medeleg, %0" : : "r" (x));
    800000b8:	67c1                	lui	a5,0x10
    800000ba:	17fd                	addi	a5,a5,-1
    800000bc:	30279073          	csrw	medeleg,a5
  asm volatile("csrw mideleg, %0" : : "r" (x));
    800000c0:	30379073          	csrw	mideleg,a5
  timerinit();
    800000c4:	00000097          	auipc	ra,0x0
    800000c8:	f58080e7          	jalr	-168(ra) # 8000001c <timerinit>
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    800000cc:	f14027f3          	csrr	a5,mhartid
  w_tp(id);
    800000d0:	2781                	sext.w	a5,a5
}

static inline void 
w_tp(uint64 x)
{
  asm volatile("mv tp, %0" : : "r" (x));
    800000d2:	823e                	mv	tp,a5
  asm volatile("mret");
    800000d4:	30200073          	mret
}
    800000d8:	60a2                	ld	ra,8(sp)
    800000da:	6402                	ld	s0,0(sp)
    800000dc:	0141                	addi	sp,sp,16
    800000de:	8082                	ret

00000000800000e0 <consoleread>:
// user_dist indicates whether dst is a user
// or kernel address.
//
int
consoleread(int user_dst, uint64 dst, int n)
{
    800000e0:	7119                	addi	sp,sp,-128
    800000e2:	fc86                	sd	ra,120(sp)
    800000e4:	f8a2                	sd	s0,112(sp)
    800000e6:	f4a6                	sd	s1,104(sp)
    800000e8:	f0ca                	sd	s2,96(sp)
    800000ea:	ecce                	sd	s3,88(sp)
    800000ec:	e8d2                	sd	s4,80(sp)
    800000ee:	e4d6                	sd	s5,72(sp)
    800000f0:	e0da                	sd	s6,64(sp)
    800000f2:	fc5e                	sd	s7,56(sp)
    800000f4:	f862                	sd	s8,48(sp)
    800000f6:	f466                	sd	s9,40(sp)
    800000f8:	f06a                	sd	s10,32(sp)
    800000fa:	ec6e                	sd	s11,24(sp)
    800000fc:	0100                	addi	s0,sp,128
    800000fe:	8b2a                	mv	s6,a0
    80000100:	8aae                	mv	s5,a1
    80000102:	8a32                	mv	s4,a2
  uint target;
  int c;
  char cbuf;

  target = n;
    80000104:	00060b9b          	sext.w	s7,a2
  acquire(&cons.lock);
    80000108:	00011517          	auipc	a0,0x11
    8000010c:	6f850513          	addi	a0,a0,1784 # 80011800 <cons>
    80000110:	00001097          	auipc	ra,0x1
    80000114:	9c2080e7          	jalr	-1598(ra) # 80000ad2 <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    80000118:	00011497          	auipc	s1,0x11
    8000011c:	6e848493          	addi	s1,s1,1768 # 80011800 <cons>
      if(myproc()->killed){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    80000120:	89a6                	mv	s3,s1
    80000122:	00011917          	auipc	s2,0x11
    80000126:	77690913          	addi	s2,s2,1910 # 80011898 <cons+0x98>
    }

    c = cons.buf[cons.r++ % INPUT_BUF];

    if(c == C('D')){  // end-of-file
    8000012a:	4c91                	li	s9,4
      break;
    }

    // copy the input byte to the user-space buffer.
    cbuf = c;
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    8000012c:	5d7d                	li	s10,-1
      break;

    dst++;
    --n;

    if(c == '\n'){
    8000012e:	4da9                	li	s11,10
  while(n > 0){
    80000130:	07405863          	blez	s4,800001a0 <consoleread+0xc0>
    while(cons.r == cons.w){
    80000134:	0984a783          	lw	a5,152(s1)
    80000138:	09c4a703          	lw	a4,156(s1)
    8000013c:	02f71463          	bne	a4,a5,80000164 <consoleread+0x84>
      if(myproc()->killed){
    80000140:	00001097          	auipc	ra,0x1
    80000144:	704080e7          	jalr	1796(ra) # 80001844 <myproc>
    80000148:	591c                	lw	a5,48(a0)
    8000014a:	e7b5                	bnez	a5,800001b6 <consoleread+0xd6>
      sleep(&cons.r, &cons.lock);
    8000014c:	85ce                	mv	a1,s3
    8000014e:	854a                	mv	a0,s2
    80000150:	00002097          	auipc	ra,0x2
    80000154:	e9a080e7          	jalr	-358(ra) # 80001fea <sleep>
    while(cons.r == cons.w){
    80000158:	0984a783          	lw	a5,152(s1)
    8000015c:	09c4a703          	lw	a4,156(s1)
    80000160:	fef700e3          	beq	a4,a5,80000140 <consoleread+0x60>
    c = cons.buf[cons.r++ % INPUT_BUF];
    80000164:	0017871b          	addiw	a4,a5,1
    80000168:	08e4ac23          	sw	a4,152(s1)
    8000016c:	07f7f713          	andi	a4,a5,127
    80000170:	9726                	add	a4,a4,s1
    80000172:	01874703          	lbu	a4,24(a4)
    80000176:	00070c1b          	sext.w	s8,a4
    if(c == C('D')){  // end-of-file
    8000017a:	079c0663          	beq	s8,s9,800001e6 <consoleread+0x106>
    cbuf = c;
    8000017e:	f8e407a3          	sb	a4,-113(s0)
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    80000182:	4685                	li	a3,1
    80000184:	f8f40613          	addi	a2,s0,-113
    80000188:	85d6                	mv	a1,s5
    8000018a:	855a                	mv	a0,s6
    8000018c:	00002097          	auipc	ra,0x2
    80000190:	0c0080e7          	jalr	192(ra) # 8000224c <either_copyout>
    80000194:	01a50663          	beq	a0,s10,800001a0 <consoleread+0xc0>
    dst++;
    80000198:	0a85                	addi	s5,s5,1
    --n;
    8000019a:	3a7d                	addiw	s4,s4,-1
    if(c == '\n'){
    8000019c:	f9bc1ae3          	bne	s8,s11,80000130 <consoleread+0x50>
      // a whole line has arrived, return to
      // the user-level read().
      break;
    }
  }
  release(&cons.lock);
    800001a0:	00011517          	auipc	a0,0x11
    800001a4:	66050513          	addi	a0,a0,1632 # 80011800 <cons>
    800001a8:	00001097          	auipc	ra,0x1
    800001ac:	97e080e7          	jalr	-1666(ra) # 80000b26 <release>

  return target - n;
    800001b0:	414b853b          	subw	a0,s7,s4
    800001b4:	a811                	j	800001c8 <consoleread+0xe8>
        release(&cons.lock);
    800001b6:	00011517          	auipc	a0,0x11
    800001ba:	64a50513          	addi	a0,a0,1610 # 80011800 <cons>
    800001be:	00001097          	auipc	ra,0x1
    800001c2:	968080e7          	jalr	-1688(ra) # 80000b26 <release>
        return -1;
    800001c6:	557d                	li	a0,-1
}
    800001c8:	70e6                	ld	ra,120(sp)
    800001ca:	7446                	ld	s0,112(sp)
    800001cc:	74a6                	ld	s1,104(sp)
    800001ce:	7906                	ld	s2,96(sp)
    800001d0:	69e6                	ld	s3,88(sp)
    800001d2:	6a46                	ld	s4,80(sp)
    800001d4:	6aa6                	ld	s5,72(sp)
    800001d6:	6b06                	ld	s6,64(sp)
    800001d8:	7be2                	ld	s7,56(sp)
    800001da:	7c42                	ld	s8,48(sp)
    800001dc:	7ca2                	ld	s9,40(sp)
    800001de:	7d02                	ld	s10,32(sp)
    800001e0:	6de2                	ld	s11,24(sp)
    800001e2:	6109                	addi	sp,sp,128
    800001e4:	8082                	ret
      if(n < target){
    800001e6:	000a071b          	sext.w	a4,s4
    800001ea:	fb777be3          	bgeu	a4,s7,800001a0 <consoleread+0xc0>
        cons.r--;
    800001ee:	00011717          	auipc	a4,0x11
    800001f2:	6af72523          	sw	a5,1706(a4) # 80011898 <cons+0x98>
    800001f6:	b76d                	j	800001a0 <consoleread+0xc0>

00000000800001f8 <consputc>:
  if(panicked){
    800001f8:	00026797          	auipc	a5,0x26
    800001fc:	e087a783          	lw	a5,-504(a5) # 80026000 <panicked>
    80000200:	c391                	beqz	a5,80000204 <consputc+0xc>
    for(;;)
    80000202:	a001                	j	80000202 <consputc+0xa>
{
    80000204:	1141                	addi	sp,sp,-16
    80000206:	e406                	sd	ra,8(sp)
    80000208:	e022                	sd	s0,0(sp)
    8000020a:	0800                	addi	s0,sp,16
  if(c == BACKSPACE){
    8000020c:	10000793          	li	a5,256
    80000210:	00f50a63          	beq	a0,a5,80000224 <consputc+0x2c>
    uartputc(c);
    80000214:	00000097          	auipc	ra,0x0
    80000218:	5d2080e7          	jalr	1490(ra) # 800007e6 <uartputc>
}
    8000021c:	60a2                	ld	ra,8(sp)
    8000021e:	6402                	ld	s0,0(sp)
    80000220:	0141                	addi	sp,sp,16
    80000222:	8082                	ret
    uartputc('\b'); uartputc(' '); uartputc('\b');
    80000224:	4521                	li	a0,8
    80000226:	00000097          	auipc	ra,0x0
    8000022a:	5c0080e7          	jalr	1472(ra) # 800007e6 <uartputc>
    8000022e:	02000513          	li	a0,32
    80000232:	00000097          	auipc	ra,0x0
    80000236:	5b4080e7          	jalr	1460(ra) # 800007e6 <uartputc>
    8000023a:	4521                	li	a0,8
    8000023c:	00000097          	auipc	ra,0x0
    80000240:	5aa080e7          	jalr	1450(ra) # 800007e6 <uartputc>
    80000244:	bfe1                	j	8000021c <consputc+0x24>

0000000080000246 <consolewrite>:
{
    80000246:	715d                	addi	sp,sp,-80
    80000248:	e486                	sd	ra,72(sp)
    8000024a:	e0a2                	sd	s0,64(sp)
    8000024c:	fc26                	sd	s1,56(sp)
    8000024e:	f84a                	sd	s2,48(sp)
    80000250:	f44e                	sd	s3,40(sp)
    80000252:	f052                	sd	s4,32(sp)
    80000254:	ec56                	sd	s5,24(sp)
    80000256:	0880                	addi	s0,sp,80
    80000258:	89aa                	mv	s3,a0
    8000025a:	84ae                	mv	s1,a1
    8000025c:	8ab2                	mv	s5,a2
  acquire(&cons.lock);
    8000025e:	00011517          	auipc	a0,0x11
    80000262:	5a250513          	addi	a0,a0,1442 # 80011800 <cons>
    80000266:	00001097          	auipc	ra,0x1
    8000026a:	86c080e7          	jalr	-1940(ra) # 80000ad2 <acquire>
  for(i = 0; i < n; i++){
    8000026e:	03505e63          	blez	s5,800002aa <consolewrite+0x64>
    80000272:	00148913          	addi	s2,s1,1
    80000276:	fffa879b          	addiw	a5,s5,-1
    8000027a:	1782                	slli	a5,a5,0x20
    8000027c:	9381                	srli	a5,a5,0x20
    8000027e:	993e                	add	s2,s2,a5
    if(either_copyin(&c, user_src, src+i, 1) == -1)
    80000280:	5a7d                	li	s4,-1
    80000282:	4685                	li	a3,1
    80000284:	8626                	mv	a2,s1
    80000286:	85ce                	mv	a1,s3
    80000288:	fbf40513          	addi	a0,s0,-65
    8000028c:	00002097          	auipc	ra,0x2
    80000290:	016080e7          	jalr	22(ra) # 800022a2 <either_copyin>
    80000294:	01450b63          	beq	a0,s4,800002aa <consolewrite+0x64>
    consputc(c);
    80000298:	fbf44503          	lbu	a0,-65(s0)
    8000029c:	00000097          	auipc	ra,0x0
    800002a0:	f5c080e7          	jalr	-164(ra) # 800001f8 <consputc>
  for(i = 0; i < n; i++){
    800002a4:	0485                	addi	s1,s1,1
    800002a6:	fd249ee3          	bne	s1,s2,80000282 <consolewrite+0x3c>
  release(&cons.lock);
    800002aa:	00011517          	auipc	a0,0x11
    800002ae:	55650513          	addi	a0,a0,1366 # 80011800 <cons>
    800002b2:	00001097          	auipc	ra,0x1
    800002b6:	874080e7          	jalr	-1932(ra) # 80000b26 <release>
}
    800002ba:	8556                	mv	a0,s5
    800002bc:	60a6                	ld	ra,72(sp)
    800002be:	6406                	ld	s0,64(sp)
    800002c0:	74e2                	ld	s1,56(sp)
    800002c2:	7942                	ld	s2,48(sp)
    800002c4:	79a2                	ld	s3,40(sp)
    800002c6:	7a02                	ld	s4,32(sp)
    800002c8:	6ae2                	ld	s5,24(sp)
    800002ca:	6161                	addi	sp,sp,80
    800002cc:	8082                	ret

00000000800002ce <consoleintr>:
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void
consoleintr(int c)
{
    800002ce:	1101                	addi	sp,sp,-32
    800002d0:	ec06                	sd	ra,24(sp)
    800002d2:	e822                	sd	s0,16(sp)
    800002d4:	e426                	sd	s1,8(sp)
    800002d6:	e04a                	sd	s2,0(sp)
    800002d8:	1000                	addi	s0,sp,32
    800002da:	84aa                	mv	s1,a0
  acquire(&cons.lock);
    800002dc:	00011517          	auipc	a0,0x11
    800002e0:	52450513          	addi	a0,a0,1316 # 80011800 <cons>
    800002e4:	00000097          	auipc	ra,0x0
    800002e8:	7ee080e7          	jalr	2030(ra) # 80000ad2 <acquire>

  switch(c){
    800002ec:	47d5                	li	a5,21
    800002ee:	0af48663          	beq	s1,a5,8000039a <consoleintr+0xcc>
    800002f2:	0297ca63          	blt	a5,s1,80000326 <consoleintr+0x58>
    800002f6:	47a1                	li	a5,8
    800002f8:	0ef48763          	beq	s1,a5,800003e6 <consoleintr+0x118>
    800002fc:	47c1                	li	a5,16
    800002fe:	10f49a63          	bne	s1,a5,80000412 <consoleintr+0x144>
  case C('P'):  // Print process list.
    procdump();
    80000302:	00002097          	auipc	ra,0x2
    80000306:	ff6080e7          	jalr	-10(ra) # 800022f8 <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    8000030a:	00011517          	auipc	a0,0x11
    8000030e:	4f650513          	addi	a0,a0,1270 # 80011800 <cons>
    80000312:	00001097          	auipc	ra,0x1
    80000316:	814080e7          	jalr	-2028(ra) # 80000b26 <release>
}
    8000031a:	60e2                	ld	ra,24(sp)
    8000031c:	6442                	ld	s0,16(sp)
    8000031e:	64a2                	ld	s1,8(sp)
    80000320:	6902                	ld	s2,0(sp)
    80000322:	6105                	addi	sp,sp,32
    80000324:	8082                	ret
  switch(c){
    80000326:	07f00793          	li	a5,127
    8000032a:	0af48e63          	beq	s1,a5,800003e6 <consoleintr+0x118>
    if(c != 0 && cons.e-cons.r < INPUT_BUF){
    8000032e:	00011717          	auipc	a4,0x11
    80000332:	4d270713          	addi	a4,a4,1234 # 80011800 <cons>
    80000336:	0a072783          	lw	a5,160(a4)
    8000033a:	09872703          	lw	a4,152(a4)
    8000033e:	9f99                	subw	a5,a5,a4
    80000340:	07f00713          	li	a4,127
    80000344:	fcf763e3          	bltu	a4,a5,8000030a <consoleintr+0x3c>
      c = (c == '\r') ? '\n' : c;
    80000348:	47b5                	li	a5,13
    8000034a:	0cf48763          	beq	s1,a5,80000418 <consoleintr+0x14a>
      consputc(c);
    8000034e:	8526                	mv	a0,s1
    80000350:	00000097          	auipc	ra,0x0
    80000354:	ea8080e7          	jalr	-344(ra) # 800001f8 <consputc>
      cons.buf[cons.e++ % INPUT_BUF] = c;
    80000358:	00011797          	auipc	a5,0x11
    8000035c:	4a878793          	addi	a5,a5,1192 # 80011800 <cons>
    80000360:	0a07a703          	lw	a4,160(a5)
    80000364:	0017069b          	addiw	a3,a4,1
    80000368:	0006861b          	sext.w	a2,a3
    8000036c:	0ad7a023          	sw	a3,160(a5)
    80000370:	07f77713          	andi	a4,a4,127
    80000374:	97ba                	add	a5,a5,a4
    80000376:	00978c23          	sb	s1,24(a5)
      if(c == '\n' || c == C('D') || cons.e == cons.r+INPUT_BUF){
    8000037a:	47a9                	li	a5,10
    8000037c:	0cf48563          	beq	s1,a5,80000446 <consoleintr+0x178>
    80000380:	4791                	li	a5,4
    80000382:	0cf48263          	beq	s1,a5,80000446 <consoleintr+0x178>
    80000386:	00011797          	auipc	a5,0x11
    8000038a:	5127a783          	lw	a5,1298(a5) # 80011898 <cons+0x98>
    8000038e:	0807879b          	addiw	a5,a5,128
    80000392:	f6f61ce3          	bne	a2,a5,8000030a <consoleintr+0x3c>
      cons.buf[cons.e++ % INPUT_BUF] = c;
    80000396:	863e                	mv	a2,a5
    80000398:	a07d                	j	80000446 <consoleintr+0x178>
    while(cons.e != cons.w &&
    8000039a:	00011717          	auipc	a4,0x11
    8000039e:	46670713          	addi	a4,a4,1126 # 80011800 <cons>
    800003a2:	0a072783          	lw	a5,160(a4)
    800003a6:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF] != '\n'){
    800003aa:	00011497          	auipc	s1,0x11
    800003ae:	45648493          	addi	s1,s1,1110 # 80011800 <cons>
    while(cons.e != cons.w &&
    800003b2:	4929                	li	s2,10
    800003b4:	f4f70be3          	beq	a4,a5,8000030a <consoleintr+0x3c>
          cons.buf[(cons.e-1) % INPUT_BUF] != '\n'){
    800003b8:	37fd                	addiw	a5,a5,-1
    800003ba:	07f7f713          	andi	a4,a5,127
    800003be:	9726                	add	a4,a4,s1
    while(cons.e != cons.w &&
    800003c0:	01874703          	lbu	a4,24(a4)
    800003c4:	f52703e3          	beq	a4,s2,8000030a <consoleintr+0x3c>
      cons.e--;
    800003c8:	0af4a023          	sw	a5,160(s1)
      consputc(BACKSPACE);
    800003cc:	10000513          	li	a0,256
    800003d0:	00000097          	auipc	ra,0x0
    800003d4:	e28080e7          	jalr	-472(ra) # 800001f8 <consputc>
    while(cons.e != cons.w &&
    800003d8:	0a04a783          	lw	a5,160(s1)
    800003dc:	09c4a703          	lw	a4,156(s1)
    800003e0:	fcf71ce3          	bne	a4,a5,800003b8 <consoleintr+0xea>
    800003e4:	b71d                	j	8000030a <consoleintr+0x3c>
    if(cons.e != cons.w){
    800003e6:	00011717          	auipc	a4,0x11
    800003ea:	41a70713          	addi	a4,a4,1050 # 80011800 <cons>
    800003ee:	0a072783          	lw	a5,160(a4)
    800003f2:	09c72703          	lw	a4,156(a4)
    800003f6:	f0f70ae3          	beq	a4,a5,8000030a <consoleintr+0x3c>
      cons.e--;
    800003fa:	37fd                	addiw	a5,a5,-1
    800003fc:	00011717          	auipc	a4,0x11
    80000400:	4af72223          	sw	a5,1188(a4) # 800118a0 <cons+0xa0>
      consputc(BACKSPACE);
    80000404:	10000513          	li	a0,256
    80000408:	00000097          	auipc	ra,0x0
    8000040c:	df0080e7          	jalr	-528(ra) # 800001f8 <consputc>
    80000410:	bded                	j	8000030a <consoleintr+0x3c>
    if(c != 0 && cons.e-cons.r < INPUT_BUF){
    80000412:	ee048ce3          	beqz	s1,8000030a <consoleintr+0x3c>
    80000416:	bf21                	j	8000032e <consoleintr+0x60>
      consputc(c);
    80000418:	4529                	li	a0,10
    8000041a:	00000097          	auipc	ra,0x0
    8000041e:	dde080e7          	jalr	-546(ra) # 800001f8 <consputc>
      cons.buf[cons.e++ % INPUT_BUF] = c;
    80000422:	00011797          	auipc	a5,0x11
    80000426:	3de78793          	addi	a5,a5,990 # 80011800 <cons>
    8000042a:	0a07a703          	lw	a4,160(a5)
    8000042e:	0017069b          	addiw	a3,a4,1
    80000432:	0006861b          	sext.w	a2,a3
    80000436:	0ad7a023          	sw	a3,160(a5)
    8000043a:	07f77713          	andi	a4,a4,127
    8000043e:	97ba                	add	a5,a5,a4
    80000440:	4729                	li	a4,10
    80000442:	00e78c23          	sb	a4,24(a5)
        cons.w = cons.e;
    80000446:	00011797          	auipc	a5,0x11
    8000044a:	44c7ab23          	sw	a2,1110(a5) # 8001189c <cons+0x9c>
        wakeup(&cons.r);
    8000044e:	00011517          	auipc	a0,0x11
    80000452:	44a50513          	addi	a0,a0,1098 # 80011898 <cons+0x98>
    80000456:	00002097          	auipc	ra,0x2
    8000045a:	d1a080e7          	jalr	-742(ra) # 80002170 <wakeup>
    8000045e:	b575                	j	8000030a <consoleintr+0x3c>

0000000080000460 <consoleinit>:

void
consoleinit(void)
{
    80000460:	1141                	addi	sp,sp,-16
    80000462:	e406                	sd	ra,8(sp)
    80000464:	e022                	sd	s0,0(sp)
    80000466:	0800                	addi	s0,sp,16
  initlock(&cons.lock, "cons");
    80000468:	00007597          	auipc	a1,0x7
    8000046c:	cb058593          	addi	a1,a1,-848 # 80007118 <userret+0x88>
    80000470:	00011517          	auipc	a0,0x11
    80000474:	39050513          	addi	a0,a0,912 # 80011800 <cons>
    80000478:	00000097          	auipc	ra,0x0
    8000047c:	548080e7          	jalr	1352(ra) # 800009c0 <initlock>

  uartinit();
    80000480:	00000097          	auipc	ra,0x0
    80000484:	330080e7          	jalr	816(ra) # 800007b0 <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    80000488:	00021797          	auipc	a5,0x21
    8000048c:	7b878793          	addi	a5,a5,1976 # 80021c40 <devsw>
    80000490:	00000717          	auipc	a4,0x0
    80000494:	c5070713          	addi	a4,a4,-944 # 800000e0 <consoleread>
    80000498:	eb98                	sd	a4,16(a5)
  devsw[CONSOLE].write = consolewrite;
    8000049a:	00000717          	auipc	a4,0x0
    8000049e:	dac70713          	addi	a4,a4,-596 # 80000246 <consolewrite>
    800004a2:	ef98                	sd	a4,24(a5)
}
    800004a4:	60a2                	ld	ra,8(sp)
    800004a6:	6402                	ld	s0,0(sp)
    800004a8:	0141                	addi	sp,sp,16
    800004aa:	8082                	ret

00000000800004ac <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(int xx, int base, int sign)
{
    800004ac:	7179                	addi	sp,sp,-48
    800004ae:	f406                	sd	ra,40(sp)
    800004b0:	f022                	sd	s0,32(sp)
    800004b2:	ec26                	sd	s1,24(sp)
    800004b4:	e84a                	sd	s2,16(sp)
    800004b6:	1800                	addi	s0,sp,48
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
    800004b8:	c219                	beqz	a2,800004be <printint+0x12>
    800004ba:	08054663          	bltz	a0,80000546 <printint+0x9a>
    x = -xx;
  else
    x = xx;
    800004be:	2501                	sext.w	a0,a0
    800004c0:	4881                	li	a7,0
    800004c2:	fd040693          	addi	a3,s0,-48

  i = 0;
    800004c6:	4701                	li	a4,0
  do {
    buf[i++] = digits[x % base];
    800004c8:	2581                	sext.w	a1,a1
    800004ca:	00007617          	auipc	a2,0x7
    800004ce:	3ae60613          	addi	a2,a2,942 # 80007878 <digits>
    800004d2:	883a                	mv	a6,a4
    800004d4:	2705                	addiw	a4,a4,1
    800004d6:	02b577bb          	remuw	a5,a0,a1
    800004da:	1782                	slli	a5,a5,0x20
    800004dc:	9381                	srli	a5,a5,0x20
    800004de:	97b2                	add	a5,a5,a2
    800004e0:	0007c783          	lbu	a5,0(a5)
    800004e4:	00f68023          	sb	a5,0(a3)
  } while((x /= base) != 0);
    800004e8:	0005079b          	sext.w	a5,a0
    800004ec:	02b5553b          	divuw	a0,a0,a1
    800004f0:	0685                	addi	a3,a3,1
    800004f2:	feb7f0e3          	bgeu	a5,a1,800004d2 <printint+0x26>

  if(sign)
    800004f6:	00088b63          	beqz	a7,8000050c <printint+0x60>
    buf[i++] = '-';
    800004fa:	fe040793          	addi	a5,s0,-32
    800004fe:	973e                	add	a4,a4,a5
    80000500:	02d00793          	li	a5,45
    80000504:	fef70823          	sb	a5,-16(a4)
    80000508:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
    8000050c:	02e05763          	blez	a4,8000053a <printint+0x8e>
    80000510:	fd040793          	addi	a5,s0,-48
    80000514:	00e784b3          	add	s1,a5,a4
    80000518:	fff78913          	addi	s2,a5,-1
    8000051c:	993a                	add	s2,s2,a4
    8000051e:	377d                	addiw	a4,a4,-1
    80000520:	1702                	slli	a4,a4,0x20
    80000522:	9301                	srli	a4,a4,0x20
    80000524:	40e90933          	sub	s2,s2,a4
    consputc(buf[i]);
    80000528:	fff4c503          	lbu	a0,-1(s1)
    8000052c:	00000097          	auipc	ra,0x0
    80000530:	ccc080e7          	jalr	-820(ra) # 800001f8 <consputc>
  while(--i >= 0)
    80000534:	14fd                	addi	s1,s1,-1
    80000536:	ff2499e3          	bne	s1,s2,80000528 <printint+0x7c>
}
    8000053a:	70a2                	ld	ra,40(sp)
    8000053c:	7402                	ld	s0,32(sp)
    8000053e:	64e2                	ld	s1,24(sp)
    80000540:	6942                	ld	s2,16(sp)
    80000542:	6145                	addi	sp,sp,48
    80000544:	8082                	ret
    x = -xx;
    80000546:	40a0053b          	negw	a0,a0
  if(sign && (sign = xx < 0))
    8000054a:	4885                	li	a7,1
    x = -xx;
    8000054c:	bf9d                	j	800004c2 <printint+0x16>

000000008000054e <panic>:
    release(&pr.lock);
}

void
panic(char *s)
{
    8000054e:	1101                	addi	sp,sp,-32
    80000550:	ec06                	sd	ra,24(sp)
    80000552:	e822                	sd	s0,16(sp)
    80000554:	e426                	sd	s1,8(sp)
    80000556:	1000                	addi	s0,sp,32
    80000558:	84aa                	mv	s1,a0
  pr.locking = 0;
    8000055a:	00011797          	auipc	a5,0x11
    8000055e:	3607a323          	sw	zero,870(a5) # 800118c0 <pr+0x18>
  printf("panic: ");
    80000562:	00007517          	auipc	a0,0x7
    80000566:	bbe50513          	addi	a0,a0,-1090 # 80007120 <userret+0x90>
    8000056a:	00000097          	auipc	ra,0x0
    8000056e:	02e080e7          	jalr	46(ra) # 80000598 <printf>
  printf(s);
    80000572:	8526                	mv	a0,s1
    80000574:	00000097          	auipc	ra,0x0
    80000578:	024080e7          	jalr	36(ra) # 80000598 <printf>
  printf("\n");
    8000057c:	00007517          	auipc	a0,0x7
    80000580:	c3450513          	addi	a0,a0,-972 # 800071b0 <userret+0x120>
    80000584:	00000097          	auipc	ra,0x0
    80000588:	014080e7          	jalr	20(ra) # 80000598 <printf>
  panicked = 1; // freeze other CPUs
    8000058c:	4785                	li	a5,1
    8000058e:	00026717          	auipc	a4,0x26
    80000592:	a6f72923          	sw	a5,-1422(a4) # 80026000 <panicked>
  for(;;)
    80000596:	a001                	j	80000596 <panic+0x48>

0000000080000598 <printf>:
{
    80000598:	7131                	addi	sp,sp,-192
    8000059a:	fc86                	sd	ra,120(sp)
    8000059c:	f8a2                	sd	s0,112(sp)
    8000059e:	f4a6                	sd	s1,104(sp)
    800005a0:	f0ca                	sd	s2,96(sp)
    800005a2:	ecce                	sd	s3,88(sp)
    800005a4:	e8d2                	sd	s4,80(sp)
    800005a6:	e4d6                	sd	s5,72(sp)
    800005a8:	e0da                	sd	s6,64(sp)
    800005aa:	fc5e                	sd	s7,56(sp)
    800005ac:	f862                	sd	s8,48(sp)
    800005ae:	f466                	sd	s9,40(sp)
    800005b0:	f06a                	sd	s10,32(sp)
    800005b2:	ec6e                	sd	s11,24(sp)
    800005b4:	0100                	addi	s0,sp,128
    800005b6:	8a2a                	mv	s4,a0
    800005b8:	e40c                	sd	a1,8(s0)
    800005ba:	e810                	sd	a2,16(s0)
    800005bc:	ec14                	sd	a3,24(s0)
    800005be:	f018                	sd	a4,32(s0)
    800005c0:	f41c                	sd	a5,40(s0)
    800005c2:	03043823          	sd	a6,48(s0)
    800005c6:	03143c23          	sd	a7,56(s0)
  locking = pr.locking;
    800005ca:	00011d97          	auipc	s11,0x11
    800005ce:	2f6dad83          	lw	s11,758(s11) # 800118c0 <pr+0x18>
  if(locking)
    800005d2:	020d9b63          	bnez	s11,80000608 <printf+0x70>
  if (fmt == 0)
    800005d6:	040a0263          	beqz	s4,8000061a <printf+0x82>
  va_start(ap, fmt);
    800005da:	00840793          	addi	a5,s0,8
    800005de:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    800005e2:	000a4503          	lbu	a0,0(s4)
    800005e6:	16050263          	beqz	a0,8000074a <printf+0x1b2>
    800005ea:	4481                	li	s1,0
    if(c != '%'){
    800005ec:	02500a93          	li	s5,37
    switch(c){
    800005f0:	07000b13          	li	s6,112
  consputc('x');
    800005f4:	4d41                	li	s10,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800005f6:	00007b97          	auipc	s7,0x7
    800005fa:	282b8b93          	addi	s7,s7,642 # 80007878 <digits>
    switch(c){
    800005fe:	07300c93          	li	s9,115
    80000602:	06400c13          	li	s8,100
    80000606:	a82d                	j	80000640 <printf+0xa8>
    acquire(&pr.lock);
    80000608:	00011517          	auipc	a0,0x11
    8000060c:	2a050513          	addi	a0,a0,672 # 800118a8 <pr>
    80000610:	00000097          	auipc	ra,0x0
    80000614:	4c2080e7          	jalr	1218(ra) # 80000ad2 <acquire>
    80000618:	bf7d                	j	800005d6 <printf+0x3e>
    panic("null fmt");
    8000061a:	00007517          	auipc	a0,0x7
    8000061e:	b1650513          	addi	a0,a0,-1258 # 80007130 <userret+0xa0>
    80000622:	00000097          	auipc	ra,0x0
    80000626:	f2c080e7          	jalr	-212(ra) # 8000054e <panic>
      consputc(c);
    8000062a:	00000097          	auipc	ra,0x0
    8000062e:	bce080e7          	jalr	-1074(ra) # 800001f8 <consputc>
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    80000632:	2485                	addiw	s1,s1,1
    80000634:	009a07b3          	add	a5,s4,s1
    80000638:	0007c503          	lbu	a0,0(a5)
    8000063c:	10050763          	beqz	a0,8000074a <printf+0x1b2>
    if(c != '%'){
    80000640:	ff5515e3          	bne	a0,s5,8000062a <printf+0x92>
    c = fmt[++i] & 0xff;
    80000644:	2485                	addiw	s1,s1,1
    80000646:	009a07b3          	add	a5,s4,s1
    8000064a:	0007c783          	lbu	a5,0(a5)
    8000064e:	0007891b          	sext.w	s2,a5
    if(c == 0)
    80000652:	cfe5                	beqz	a5,8000074a <printf+0x1b2>
    switch(c){
    80000654:	05678a63          	beq	a5,s6,800006a8 <printf+0x110>
    80000658:	02fb7663          	bgeu	s6,a5,80000684 <printf+0xec>
    8000065c:	09978963          	beq	a5,s9,800006ee <printf+0x156>
    80000660:	07800713          	li	a4,120
    80000664:	0ce79863          	bne	a5,a4,80000734 <printf+0x19c>
      printint(va_arg(ap, int), 16, 1);
    80000668:	f8843783          	ld	a5,-120(s0)
    8000066c:	00878713          	addi	a4,a5,8
    80000670:	f8e43423          	sd	a4,-120(s0)
    80000674:	4605                	li	a2,1
    80000676:	85ea                	mv	a1,s10
    80000678:	4388                	lw	a0,0(a5)
    8000067a:	00000097          	auipc	ra,0x0
    8000067e:	e32080e7          	jalr	-462(ra) # 800004ac <printint>
      break;
    80000682:	bf45                	j	80000632 <printf+0x9a>
    switch(c){
    80000684:	0b578263          	beq	a5,s5,80000728 <printf+0x190>
    80000688:	0b879663          	bne	a5,s8,80000734 <printf+0x19c>
      printint(va_arg(ap, int), 10, 1);
    8000068c:	f8843783          	ld	a5,-120(s0)
    80000690:	00878713          	addi	a4,a5,8
    80000694:	f8e43423          	sd	a4,-120(s0)
    80000698:	4605                	li	a2,1
    8000069a:	45a9                	li	a1,10
    8000069c:	4388                	lw	a0,0(a5)
    8000069e:	00000097          	auipc	ra,0x0
    800006a2:	e0e080e7          	jalr	-498(ra) # 800004ac <printint>
      break;
    800006a6:	b771                	j	80000632 <printf+0x9a>
      printptr(va_arg(ap, uint64));
    800006a8:	f8843783          	ld	a5,-120(s0)
    800006ac:	00878713          	addi	a4,a5,8
    800006b0:	f8e43423          	sd	a4,-120(s0)
    800006b4:	0007b983          	ld	s3,0(a5)
  consputc('0');
    800006b8:	03000513          	li	a0,48
    800006bc:	00000097          	auipc	ra,0x0
    800006c0:	b3c080e7          	jalr	-1220(ra) # 800001f8 <consputc>
  consputc('x');
    800006c4:	07800513          	li	a0,120
    800006c8:	00000097          	auipc	ra,0x0
    800006cc:	b30080e7          	jalr	-1232(ra) # 800001f8 <consputc>
    800006d0:	896a                	mv	s2,s10
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800006d2:	03c9d793          	srli	a5,s3,0x3c
    800006d6:	97de                	add	a5,a5,s7
    800006d8:	0007c503          	lbu	a0,0(a5)
    800006dc:	00000097          	auipc	ra,0x0
    800006e0:	b1c080e7          	jalr	-1252(ra) # 800001f8 <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    800006e4:	0992                	slli	s3,s3,0x4
    800006e6:	397d                	addiw	s2,s2,-1
    800006e8:	fe0915e3          	bnez	s2,800006d2 <printf+0x13a>
    800006ec:	b799                	j	80000632 <printf+0x9a>
      if((s = va_arg(ap, char*)) == 0)
    800006ee:	f8843783          	ld	a5,-120(s0)
    800006f2:	00878713          	addi	a4,a5,8
    800006f6:	f8e43423          	sd	a4,-120(s0)
    800006fa:	0007b903          	ld	s2,0(a5)
    800006fe:	00090e63          	beqz	s2,8000071a <printf+0x182>
      for(; *s; s++)
    80000702:	00094503          	lbu	a0,0(s2)
    80000706:	d515                	beqz	a0,80000632 <printf+0x9a>
        consputc(*s);
    80000708:	00000097          	auipc	ra,0x0
    8000070c:	af0080e7          	jalr	-1296(ra) # 800001f8 <consputc>
      for(; *s; s++)
    80000710:	0905                	addi	s2,s2,1
    80000712:	00094503          	lbu	a0,0(s2)
    80000716:	f96d                	bnez	a0,80000708 <printf+0x170>
    80000718:	bf29                	j	80000632 <printf+0x9a>
        s = "(null)";
    8000071a:	00007917          	auipc	s2,0x7
    8000071e:	a0e90913          	addi	s2,s2,-1522 # 80007128 <userret+0x98>
      for(; *s; s++)
    80000722:	02800513          	li	a0,40
    80000726:	b7cd                	j	80000708 <printf+0x170>
      consputc('%');
    80000728:	8556                	mv	a0,s5
    8000072a:	00000097          	auipc	ra,0x0
    8000072e:	ace080e7          	jalr	-1330(ra) # 800001f8 <consputc>
      break;
    80000732:	b701                	j	80000632 <printf+0x9a>
      consputc('%');
    80000734:	8556                	mv	a0,s5
    80000736:	00000097          	auipc	ra,0x0
    8000073a:	ac2080e7          	jalr	-1342(ra) # 800001f8 <consputc>
      consputc(c);
    8000073e:	854a                	mv	a0,s2
    80000740:	00000097          	auipc	ra,0x0
    80000744:	ab8080e7          	jalr	-1352(ra) # 800001f8 <consputc>
      break;
    80000748:	b5ed                	j	80000632 <printf+0x9a>
  if(locking)
    8000074a:	020d9163          	bnez	s11,8000076c <printf+0x1d4>
}
    8000074e:	70e6                	ld	ra,120(sp)
    80000750:	7446                	ld	s0,112(sp)
    80000752:	74a6                	ld	s1,104(sp)
    80000754:	7906                	ld	s2,96(sp)
    80000756:	69e6                	ld	s3,88(sp)
    80000758:	6a46                	ld	s4,80(sp)
    8000075a:	6aa6                	ld	s5,72(sp)
    8000075c:	6b06                	ld	s6,64(sp)
    8000075e:	7be2                	ld	s7,56(sp)
    80000760:	7c42                	ld	s8,48(sp)
    80000762:	7ca2                	ld	s9,40(sp)
    80000764:	7d02                	ld	s10,32(sp)
    80000766:	6de2                	ld	s11,24(sp)
    80000768:	6129                	addi	sp,sp,192
    8000076a:	8082                	ret
    release(&pr.lock);
    8000076c:	00011517          	auipc	a0,0x11
    80000770:	13c50513          	addi	a0,a0,316 # 800118a8 <pr>
    80000774:	00000097          	auipc	ra,0x0
    80000778:	3b2080e7          	jalr	946(ra) # 80000b26 <release>
}
    8000077c:	bfc9                	j	8000074e <printf+0x1b6>

000000008000077e <printfinit>:
    ;
}

void
printfinit(void)
{
    8000077e:	1101                	addi	sp,sp,-32
    80000780:	ec06                	sd	ra,24(sp)
    80000782:	e822                	sd	s0,16(sp)
    80000784:	e426                	sd	s1,8(sp)
    80000786:	1000                	addi	s0,sp,32
  initlock(&pr.lock, "pr");
    80000788:	00011497          	auipc	s1,0x11
    8000078c:	12048493          	addi	s1,s1,288 # 800118a8 <pr>
    80000790:	00007597          	auipc	a1,0x7
    80000794:	9b058593          	addi	a1,a1,-1616 # 80007140 <userret+0xb0>
    80000798:	8526                	mv	a0,s1
    8000079a:	00000097          	auipc	ra,0x0
    8000079e:	226080e7          	jalr	550(ra) # 800009c0 <initlock>
  pr.locking = 1;
    800007a2:	4785                	li	a5,1
    800007a4:	cc9c                	sw	a5,24(s1)
}
    800007a6:	60e2                	ld	ra,24(sp)
    800007a8:	6442                	ld	s0,16(sp)
    800007aa:	64a2                	ld	s1,8(sp)
    800007ac:	6105                	addi	sp,sp,32
    800007ae:	8082                	ret

00000000800007b0 <uartinit>:
#define ReadReg(reg) (*(Reg(reg)))
#define WriteReg(reg, v) (*(Reg(reg)) = (v))

void
uartinit(void)
{
    800007b0:	1141                	addi	sp,sp,-16
    800007b2:	e422                	sd	s0,8(sp)
    800007b4:	0800                	addi	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    800007b6:	100007b7          	lui	a5,0x10000
    800007ba:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, 0x80);
    800007be:	f8000713          	li	a4,-128
    800007c2:	00e781a3          	sb	a4,3(a5)

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    800007c6:	470d                	li	a4,3
    800007c8:	00e78023          	sb	a4,0(a5)

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    800007cc:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, 0x03);
    800007d0:	00e781a3          	sb	a4,3(a5)

  // reset and enable FIFOs.
  WriteReg(FCR, 0x07);
    800007d4:	471d                	li	a4,7
    800007d6:	00e78123          	sb	a4,2(a5)

  // enable receive interrupts.
  WriteReg(IER, 0x01);
    800007da:	4705                	li	a4,1
    800007dc:	00e780a3          	sb	a4,1(a5)
}
    800007e0:	6422                	ld	s0,8(sp)
    800007e2:	0141                	addi	sp,sp,16
    800007e4:	8082                	ret

00000000800007e6 <uartputc>:

// write one output character to the UART.
void
uartputc(int c)
{
    800007e6:	1141                	addi	sp,sp,-16
    800007e8:	e422                	sd	s0,8(sp)
    800007ea:	0800                	addi	s0,sp,16
  // wait for Transmit Holding Empty to be set in LSR.
  while((ReadReg(LSR) & (1 << 5)) == 0)
    800007ec:	10000737          	lui	a4,0x10000
    800007f0:	00574783          	lbu	a5,5(a4) # 10000005 <_entry-0x6ffffffb>
    800007f4:	0ff7f793          	andi	a5,a5,255
    800007f8:	0207f793          	andi	a5,a5,32
    800007fc:	dbf5                	beqz	a5,800007f0 <uartputc+0xa>
    ;
  WriteReg(THR, c);
    800007fe:	0ff57513          	andi	a0,a0,255
    80000802:	100007b7          	lui	a5,0x10000
    80000806:	00a78023          	sb	a0,0(a5) # 10000000 <_entry-0x70000000>
}
    8000080a:	6422                	ld	s0,8(sp)
    8000080c:	0141                	addi	sp,sp,16
    8000080e:	8082                	ret

0000000080000810 <uartgetc>:

// read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
    80000810:	1141                	addi	sp,sp,-16
    80000812:	e422                	sd	s0,8(sp)
    80000814:	0800                	addi	s0,sp,16
  if(ReadReg(LSR) & 0x01){
    80000816:	100007b7          	lui	a5,0x10000
    8000081a:	0057c783          	lbu	a5,5(a5) # 10000005 <_entry-0x6ffffffb>
    8000081e:	8b85                	andi	a5,a5,1
    80000820:	cb91                	beqz	a5,80000834 <uartgetc+0x24>
    // input data is ready.
    return ReadReg(RHR);
    80000822:	100007b7          	lui	a5,0x10000
    80000826:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
    8000082a:	0ff57513          	andi	a0,a0,255
  } else {
    return -1;
  }
}
    8000082e:	6422                	ld	s0,8(sp)
    80000830:	0141                	addi	sp,sp,16
    80000832:	8082                	ret
    return -1;
    80000834:	557d                	li	a0,-1
    80000836:	bfe5                	j	8000082e <uartgetc+0x1e>

0000000080000838 <uartintr>:

// trap.c calls here when the uart interrupts.
void
uartintr(void)
{
    80000838:	1101                	addi	sp,sp,-32
    8000083a:	ec06                	sd	ra,24(sp)
    8000083c:	e822                	sd	s0,16(sp)
    8000083e:	e426                	sd	s1,8(sp)
    80000840:	1000                	addi	s0,sp,32
  while(1){
    int c = uartgetc();
    if(c == -1)
    80000842:	54fd                	li	s1,-1
    int c = uartgetc();
    80000844:	00000097          	auipc	ra,0x0
    80000848:	fcc080e7          	jalr	-52(ra) # 80000810 <uartgetc>
    if(c == -1)
    8000084c:	00950763          	beq	a0,s1,8000085a <uartintr+0x22>
      break;
    consoleintr(c);
    80000850:	00000097          	auipc	ra,0x0
    80000854:	a7e080e7          	jalr	-1410(ra) # 800002ce <consoleintr>
  while(1){
    80000858:	b7f5                	j	80000844 <uartintr+0xc>
  }
}
    8000085a:	60e2                	ld	ra,24(sp)
    8000085c:	6442                	ld	s0,16(sp)
    8000085e:	64a2                	ld	s1,8(sp)
    80000860:	6105                	addi	sp,sp,32
    80000862:	8082                	ret

0000000080000864 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
    80000864:	1101                	addi	sp,sp,-32
    80000866:	ec06                	sd	ra,24(sp)
    80000868:	e822                	sd	s0,16(sp)
    8000086a:	e426                	sd	s1,8(sp)
    8000086c:	e04a                	sd	s2,0(sp)
    8000086e:	1000                	addi	s0,sp,32
  struct run *r;

  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    80000870:	03451793          	slli	a5,a0,0x34
    80000874:	ebb9                	bnez	a5,800008ca <kfree+0x66>
    80000876:	84aa                	mv	s1,a0
    80000878:	00025797          	auipc	a5,0x25
    8000087c:	7a478793          	addi	a5,a5,1956 # 8002601c <end>
    80000880:	04f56563          	bltu	a0,a5,800008ca <kfree+0x66>
    80000884:	47c5                	li	a5,17
    80000886:	07ee                	slli	a5,a5,0x1b
    80000888:	04f57163          	bgeu	a0,a5,800008ca <kfree+0x66>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);
    8000088c:	6605                	lui	a2,0x1
    8000088e:	4585                	li	a1,1
    80000890:	00000097          	auipc	ra,0x0
    80000894:	2de080e7          	jalr	734(ra) # 80000b6e <memset>

  r = (struct run*)pa;

  acquire(&kmem.lock);
    80000898:	00011917          	auipc	s2,0x11
    8000089c:	03090913          	addi	s2,s2,48 # 800118c8 <kmem>
    800008a0:	854a                	mv	a0,s2
    800008a2:	00000097          	auipc	ra,0x0
    800008a6:	230080e7          	jalr	560(ra) # 80000ad2 <acquire>
  r->next = kmem.freelist;
    800008aa:	01893783          	ld	a5,24(s2)
    800008ae:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    800008b0:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    800008b4:	854a                	mv	a0,s2
    800008b6:	00000097          	auipc	ra,0x0
    800008ba:	270080e7          	jalr	624(ra) # 80000b26 <release>
}
    800008be:	60e2                	ld	ra,24(sp)
    800008c0:	6442                	ld	s0,16(sp)
    800008c2:	64a2                	ld	s1,8(sp)
    800008c4:	6902                	ld	s2,0(sp)
    800008c6:	6105                	addi	sp,sp,32
    800008c8:	8082                	ret
    panic("kfree");
    800008ca:	00007517          	auipc	a0,0x7
    800008ce:	87e50513          	addi	a0,a0,-1922 # 80007148 <userret+0xb8>
    800008d2:	00000097          	auipc	ra,0x0
    800008d6:	c7c080e7          	jalr	-900(ra) # 8000054e <panic>

00000000800008da <freerange>:
{
    800008da:	7179                	addi	sp,sp,-48
    800008dc:	f406                	sd	ra,40(sp)
    800008de:	f022                	sd	s0,32(sp)
    800008e0:	ec26                	sd	s1,24(sp)
    800008e2:	e84a                	sd	s2,16(sp)
    800008e4:	e44e                	sd	s3,8(sp)
    800008e6:	e052                	sd	s4,0(sp)
    800008e8:	1800                	addi	s0,sp,48
  p = (char*)PGROUNDUP((uint64)pa_start);
    800008ea:	6785                	lui	a5,0x1
    800008ec:	fff78493          	addi	s1,a5,-1 # fff <_entry-0x7ffff001>
    800008f0:	94aa                	add	s1,s1,a0
    800008f2:	757d                	lui	a0,0xfffff
    800008f4:	8ce9                	and	s1,s1,a0
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    800008f6:	94be                	add	s1,s1,a5
    800008f8:	0095ee63          	bltu	a1,s1,80000914 <freerange+0x3a>
    800008fc:	892e                	mv	s2,a1
    kfree(p);
    800008fe:	7a7d                	lui	s4,0xfffff
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000900:	6985                	lui	s3,0x1
    kfree(p);
    80000902:	01448533          	add	a0,s1,s4
    80000906:	00000097          	auipc	ra,0x0
    8000090a:	f5e080e7          	jalr	-162(ra) # 80000864 <kfree>
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    8000090e:	94ce                	add	s1,s1,s3
    80000910:	fe9979e3          	bgeu	s2,s1,80000902 <freerange+0x28>
}
    80000914:	70a2                	ld	ra,40(sp)
    80000916:	7402                	ld	s0,32(sp)
    80000918:	64e2                	ld	s1,24(sp)
    8000091a:	6942                	ld	s2,16(sp)
    8000091c:	69a2                	ld	s3,8(sp)
    8000091e:	6a02                	ld	s4,0(sp)
    80000920:	6145                	addi	sp,sp,48
    80000922:	8082                	ret

0000000080000924 <kinit>:
{
    80000924:	1141                	addi	sp,sp,-16
    80000926:	e406                	sd	ra,8(sp)
    80000928:	e022                	sd	s0,0(sp)
    8000092a:	0800                	addi	s0,sp,16
  initlock(&kmem.lock, "kmem");
    8000092c:	00007597          	auipc	a1,0x7
    80000930:	82458593          	addi	a1,a1,-2012 # 80007150 <userret+0xc0>
    80000934:	00011517          	auipc	a0,0x11
    80000938:	f9450513          	addi	a0,a0,-108 # 800118c8 <kmem>
    8000093c:	00000097          	auipc	ra,0x0
    80000940:	084080e7          	jalr	132(ra) # 800009c0 <initlock>
  freerange(end, (void*)PHYSTOP);
    80000944:	45c5                	li	a1,17
    80000946:	05ee                	slli	a1,a1,0x1b
    80000948:	00025517          	auipc	a0,0x25
    8000094c:	6d450513          	addi	a0,a0,1748 # 8002601c <end>
    80000950:	00000097          	auipc	ra,0x0
    80000954:	f8a080e7          	jalr	-118(ra) # 800008da <freerange>
}
    80000958:	60a2                	ld	ra,8(sp)
    8000095a:	6402                	ld	s0,0(sp)
    8000095c:	0141                	addi	sp,sp,16
    8000095e:	8082                	ret

0000000080000960 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80000960:	1101                	addi	sp,sp,-32
    80000962:	ec06                	sd	ra,24(sp)
    80000964:	e822                	sd	s0,16(sp)
    80000966:	e426                	sd	s1,8(sp)
    80000968:	1000                	addi	s0,sp,32
  struct run *r;

  acquire(&kmem.lock);
    8000096a:	00011497          	auipc	s1,0x11
    8000096e:	f5e48493          	addi	s1,s1,-162 # 800118c8 <kmem>
    80000972:	8526                	mv	a0,s1
    80000974:	00000097          	auipc	ra,0x0
    80000978:	15e080e7          	jalr	350(ra) # 80000ad2 <acquire>
  r = kmem.freelist;
    8000097c:	6c84                	ld	s1,24(s1)
  if(r)
    8000097e:	c885                	beqz	s1,800009ae <kalloc+0x4e>
    kmem.freelist = r->next;
    80000980:	609c                	ld	a5,0(s1)
    80000982:	00011517          	auipc	a0,0x11
    80000986:	f4650513          	addi	a0,a0,-186 # 800118c8 <kmem>
    8000098a:	ed1c                	sd	a5,24(a0)
  release(&kmem.lock);
    8000098c:	00000097          	auipc	ra,0x0
    80000990:	19a080e7          	jalr	410(ra) # 80000b26 <release>

  if(r)
    memset((char*)r, 5, PGSIZE); // fill with junk
    80000994:	6605                	lui	a2,0x1
    80000996:	4595                	li	a1,5
    80000998:	8526                	mv	a0,s1
    8000099a:	00000097          	auipc	ra,0x0
    8000099e:	1d4080e7          	jalr	468(ra) # 80000b6e <memset>
  return (void*)r;
}
    800009a2:	8526                	mv	a0,s1
    800009a4:	60e2                	ld	ra,24(sp)
    800009a6:	6442                	ld	s0,16(sp)
    800009a8:	64a2                	ld	s1,8(sp)
    800009aa:	6105                	addi	sp,sp,32
    800009ac:	8082                	ret
  release(&kmem.lock);
    800009ae:	00011517          	auipc	a0,0x11
    800009b2:	f1a50513          	addi	a0,a0,-230 # 800118c8 <kmem>
    800009b6:	00000097          	auipc	ra,0x0
    800009ba:	170080e7          	jalr	368(ra) # 80000b26 <release>
  if(r)
    800009be:	b7d5                	j	800009a2 <kalloc+0x42>

00000000800009c0 <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    800009c0:	1141                	addi	sp,sp,-16
    800009c2:	e422                	sd	s0,8(sp)
    800009c4:	0800                	addi	s0,sp,16
  lk->name = name;
    800009c6:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    800009c8:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    800009cc:	00053823          	sd	zero,16(a0)
}
    800009d0:	6422                	ld	s0,8(sp)
    800009d2:	0141                	addi	sp,sp,16
    800009d4:	8082                	ret

00000000800009d6 <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    800009d6:	1101                	addi	sp,sp,-32
    800009d8:	ec06                	sd	ra,24(sp)
    800009da:	e822                	sd	s0,16(sp)
    800009dc:	e426                	sd	s1,8(sp)
    800009de:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800009e0:	100024f3          	csrr	s1,sstatus
    800009e4:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    800009e8:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800009ea:	10079073          	csrw	sstatus,a5
  int old = intr_get();

  intr_off();
  if(mycpu()->noff == 0)
    800009ee:	00001097          	auipc	ra,0x1
    800009f2:	e3a080e7          	jalr	-454(ra) # 80001828 <mycpu>
    800009f6:	5d3c                	lw	a5,120(a0)
    800009f8:	cf89                	beqz	a5,80000a12 <push_off+0x3c>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    800009fa:	00001097          	auipc	ra,0x1
    800009fe:	e2e080e7          	jalr	-466(ra) # 80001828 <mycpu>
    80000a02:	5d3c                	lw	a5,120(a0)
    80000a04:	2785                	addiw	a5,a5,1
    80000a06:	dd3c                	sw	a5,120(a0)
}
    80000a08:	60e2                	ld	ra,24(sp)
    80000a0a:	6442                	ld	s0,16(sp)
    80000a0c:	64a2                	ld	s1,8(sp)
    80000a0e:	6105                	addi	sp,sp,32
    80000a10:	8082                	ret
    mycpu()->intena = old;
    80000a12:	00001097          	auipc	ra,0x1
    80000a16:	e16080e7          	jalr	-490(ra) # 80001828 <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80000a1a:	8085                	srli	s1,s1,0x1
    80000a1c:	8885                	andi	s1,s1,1
    80000a1e:	dd64                	sw	s1,124(a0)
    80000a20:	bfe9                	j	800009fa <push_off+0x24>

0000000080000a22 <pop_off>:

void
pop_off(void)
{
    80000a22:	1141                	addi	sp,sp,-16
    80000a24:	e406                	sd	ra,8(sp)
    80000a26:	e022                	sd	s0,0(sp)
    80000a28:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80000a2a:	00001097          	auipc	ra,0x1
    80000a2e:	dfe080e7          	jalr	-514(ra) # 80001828 <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000a32:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000a36:	8b89                	andi	a5,a5,2
  if(intr_get())
    80000a38:	ef8d                	bnez	a5,80000a72 <pop_off+0x50>
    panic("pop_off - interruptible");
  c->noff -= 1;
    80000a3a:	5d3c                	lw	a5,120(a0)
    80000a3c:	37fd                	addiw	a5,a5,-1
    80000a3e:	0007871b          	sext.w	a4,a5
    80000a42:	dd3c                	sw	a5,120(a0)
  if(c->noff < 0)
    80000a44:	02079693          	slli	a3,a5,0x20
    80000a48:	0206cd63          	bltz	a3,80000a82 <pop_off+0x60>
    panic("pop_off");
  if(c->noff == 0 && c->intena)
    80000a4c:	ef19                	bnez	a4,80000a6a <pop_off+0x48>
    80000a4e:	5d7c                	lw	a5,124(a0)
    80000a50:	cf89                	beqz	a5,80000a6a <pop_off+0x48>
  asm volatile("csrr %0, sie" : "=r" (x) );
    80000a52:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE);
    80000a56:	2227e793          	ori	a5,a5,546
  asm volatile("csrw sie, %0" : : "r" (x));
    80000a5a:	10479073          	csrw	sie,a5
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000a5e:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000a62:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000a66:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000a6a:	60a2                	ld	ra,8(sp)
    80000a6c:	6402                	ld	s0,0(sp)
    80000a6e:	0141                	addi	sp,sp,16
    80000a70:	8082                	ret
    panic("pop_off - interruptible");
    80000a72:	00006517          	auipc	a0,0x6
    80000a76:	6e650513          	addi	a0,a0,1766 # 80007158 <userret+0xc8>
    80000a7a:	00000097          	auipc	ra,0x0
    80000a7e:	ad4080e7          	jalr	-1324(ra) # 8000054e <panic>
    panic("pop_off");
    80000a82:	00006517          	auipc	a0,0x6
    80000a86:	6ee50513          	addi	a0,a0,1774 # 80007170 <userret+0xe0>
    80000a8a:	00000097          	auipc	ra,0x0
    80000a8e:	ac4080e7          	jalr	-1340(ra) # 8000054e <panic>

0000000080000a92 <holding>:
{
    80000a92:	1101                	addi	sp,sp,-32
    80000a94:	ec06                	sd	ra,24(sp)
    80000a96:	e822                	sd	s0,16(sp)
    80000a98:	e426                	sd	s1,8(sp)
    80000a9a:	1000                	addi	s0,sp,32
    80000a9c:	84aa                	mv	s1,a0
  push_off();
    80000a9e:	00000097          	auipc	ra,0x0
    80000aa2:	f38080e7          	jalr	-200(ra) # 800009d6 <push_off>
  r = (lk->locked && lk->cpu == mycpu());
    80000aa6:	409c                	lw	a5,0(s1)
    80000aa8:	ef81                	bnez	a5,80000ac0 <holding+0x2e>
    80000aaa:	4481                	li	s1,0
  pop_off();
    80000aac:	00000097          	auipc	ra,0x0
    80000ab0:	f76080e7          	jalr	-138(ra) # 80000a22 <pop_off>
}
    80000ab4:	8526                	mv	a0,s1
    80000ab6:	60e2                	ld	ra,24(sp)
    80000ab8:	6442                	ld	s0,16(sp)
    80000aba:	64a2                	ld	s1,8(sp)
    80000abc:	6105                	addi	sp,sp,32
    80000abe:	8082                	ret
  r = (lk->locked && lk->cpu == mycpu());
    80000ac0:	6884                	ld	s1,16(s1)
    80000ac2:	00001097          	auipc	ra,0x1
    80000ac6:	d66080e7          	jalr	-666(ra) # 80001828 <mycpu>
    80000aca:	8c89                	sub	s1,s1,a0
    80000acc:	0014b493          	seqz	s1,s1
    80000ad0:	bff1                	j	80000aac <holding+0x1a>

0000000080000ad2 <acquire>:
{
    80000ad2:	1101                	addi	sp,sp,-32
    80000ad4:	ec06                	sd	ra,24(sp)
    80000ad6:	e822                	sd	s0,16(sp)
    80000ad8:	e426                	sd	s1,8(sp)
    80000ada:	1000                	addi	s0,sp,32
    80000adc:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000ade:	00000097          	auipc	ra,0x0
    80000ae2:	ef8080e7          	jalr	-264(ra) # 800009d6 <push_off>
  if(holding(lk))
    80000ae6:	8526                	mv	a0,s1
    80000ae8:	00000097          	auipc	ra,0x0
    80000aec:	faa080e7          	jalr	-86(ra) # 80000a92 <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000af0:	4705                	li	a4,1
  if(holding(lk))
    80000af2:	e115                	bnez	a0,80000b16 <acquire+0x44>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000af4:	87ba                	mv	a5,a4
    80000af6:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000afa:	2781                	sext.w	a5,a5
    80000afc:	ffe5                	bnez	a5,80000af4 <acquire+0x22>
  __sync_synchronize();
    80000afe:	0ff0000f          	fence
  lk->cpu = mycpu();
    80000b02:	00001097          	auipc	ra,0x1
    80000b06:	d26080e7          	jalr	-730(ra) # 80001828 <mycpu>
    80000b0a:	e888                	sd	a0,16(s1)
}
    80000b0c:	60e2                	ld	ra,24(sp)
    80000b0e:	6442                	ld	s0,16(sp)
    80000b10:	64a2                	ld	s1,8(sp)
    80000b12:	6105                	addi	sp,sp,32
    80000b14:	8082                	ret
    panic("acquire");
    80000b16:	00006517          	auipc	a0,0x6
    80000b1a:	66250513          	addi	a0,a0,1634 # 80007178 <userret+0xe8>
    80000b1e:	00000097          	auipc	ra,0x0
    80000b22:	a30080e7          	jalr	-1488(ra) # 8000054e <panic>

0000000080000b26 <release>:
{
    80000b26:	1101                	addi	sp,sp,-32
    80000b28:	ec06                	sd	ra,24(sp)
    80000b2a:	e822                	sd	s0,16(sp)
    80000b2c:	e426                	sd	s1,8(sp)
    80000b2e:	1000                	addi	s0,sp,32
    80000b30:	84aa                	mv	s1,a0
  if(!holding(lk))
    80000b32:	00000097          	auipc	ra,0x0
    80000b36:	f60080e7          	jalr	-160(ra) # 80000a92 <holding>
    80000b3a:	c115                	beqz	a0,80000b5e <release+0x38>
  lk->cpu = 0;
    80000b3c:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80000b40:	0ff0000f          	fence
  __sync_lock_release(&lk->locked);
    80000b44:	0f50000f          	fence	iorw,ow
    80000b48:	0804a02f          	amoswap.w	zero,zero,(s1)
  pop_off();
    80000b4c:	00000097          	auipc	ra,0x0
    80000b50:	ed6080e7          	jalr	-298(ra) # 80000a22 <pop_off>
}
    80000b54:	60e2                	ld	ra,24(sp)
    80000b56:	6442                	ld	s0,16(sp)
    80000b58:	64a2                	ld	s1,8(sp)
    80000b5a:	6105                	addi	sp,sp,32
    80000b5c:	8082                	ret
    panic("release");
    80000b5e:	00006517          	auipc	a0,0x6
    80000b62:	62250513          	addi	a0,a0,1570 # 80007180 <userret+0xf0>
    80000b66:	00000097          	auipc	ra,0x0
    80000b6a:	9e8080e7          	jalr	-1560(ra) # 8000054e <panic>

0000000080000b6e <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    80000b6e:	1141                	addi	sp,sp,-16
    80000b70:	e422                	sd	s0,8(sp)
    80000b72:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80000b74:	ce09                	beqz	a2,80000b8e <memset+0x20>
    80000b76:	87aa                	mv	a5,a0
    80000b78:	fff6071b          	addiw	a4,a2,-1
    80000b7c:	1702                	slli	a4,a4,0x20
    80000b7e:	9301                	srli	a4,a4,0x20
    80000b80:	0705                	addi	a4,a4,1
    80000b82:	972a                	add	a4,a4,a0
    cdst[i] = c;
    80000b84:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    80000b88:	0785                	addi	a5,a5,1
    80000b8a:	fee79de3          	bne	a5,a4,80000b84 <memset+0x16>
  }
  return dst;
}
    80000b8e:	6422                	ld	s0,8(sp)
    80000b90:	0141                	addi	sp,sp,16
    80000b92:	8082                	ret

0000000080000b94 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000b94:	1141                	addi	sp,sp,-16
    80000b96:	e422                	sd	s0,8(sp)
    80000b98:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    80000b9a:	ca05                	beqz	a2,80000bca <memcmp+0x36>
    80000b9c:	fff6069b          	addiw	a3,a2,-1
    80000ba0:	1682                	slli	a3,a3,0x20
    80000ba2:	9281                	srli	a3,a3,0x20
    80000ba4:	0685                	addi	a3,a3,1
    80000ba6:	96aa                	add	a3,a3,a0
    if(*s1 != *s2)
    80000ba8:	00054783          	lbu	a5,0(a0)
    80000bac:	0005c703          	lbu	a4,0(a1)
    80000bb0:	00e79863          	bne	a5,a4,80000bc0 <memcmp+0x2c>
      return *s1 - *s2;
    s1++, s2++;
    80000bb4:	0505                	addi	a0,a0,1
    80000bb6:	0585                	addi	a1,a1,1
  while(n-- > 0){
    80000bb8:	fed518e3          	bne	a0,a3,80000ba8 <memcmp+0x14>
  }

  return 0;
    80000bbc:	4501                	li	a0,0
    80000bbe:	a019                	j	80000bc4 <memcmp+0x30>
      return *s1 - *s2;
    80000bc0:	40e7853b          	subw	a0,a5,a4
}
    80000bc4:	6422                	ld	s0,8(sp)
    80000bc6:	0141                	addi	sp,sp,16
    80000bc8:	8082                	ret
  return 0;
    80000bca:	4501                	li	a0,0
    80000bcc:	bfe5                	j	80000bc4 <memcmp+0x30>

0000000080000bce <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80000bce:	1141                	addi	sp,sp,-16
    80000bd0:	e422                	sd	s0,8(sp)
    80000bd2:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
    80000bd4:	00a5f963          	bgeu	a1,a0,80000be6 <memmove+0x18>
    80000bd8:	02061713          	slli	a4,a2,0x20
    80000bdc:	9301                	srli	a4,a4,0x20
    80000bde:	00e587b3          	add	a5,a1,a4
    80000be2:	02f56563          	bltu	a0,a5,80000c0c <memmove+0x3e>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    80000be6:	fff6069b          	addiw	a3,a2,-1
    80000bea:	ce11                	beqz	a2,80000c06 <memmove+0x38>
    80000bec:	1682                	slli	a3,a3,0x20
    80000bee:	9281                	srli	a3,a3,0x20
    80000bf0:	0685                	addi	a3,a3,1
    80000bf2:	96ae                	add	a3,a3,a1
    80000bf4:	87aa                	mv	a5,a0
      *d++ = *s++;
    80000bf6:	0585                	addi	a1,a1,1
    80000bf8:	0785                	addi	a5,a5,1
    80000bfa:	fff5c703          	lbu	a4,-1(a1)
    80000bfe:	fee78fa3          	sb	a4,-1(a5)
    while(n-- > 0)
    80000c02:	fed59ae3          	bne	a1,a3,80000bf6 <memmove+0x28>

  return dst;
}
    80000c06:	6422                	ld	s0,8(sp)
    80000c08:	0141                	addi	sp,sp,16
    80000c0a:	8082                	ret
    d += n;
    80000c0c:	972a                	add	a4,a4,a0
    while(n-- > 0)
    80000c0e:	fff6069b          	addiw	a3,a2,-1
    80000c12:	da75                	beqz	a2,80000c06 <memmove+0x38>
    80000c14:	02069613          	slli	a2,a3,0x20
    80000c18:	9201                	srli	a2,a2,0x20
    80000c1a:	fff64613          	not	a2,a2
    80000c1e:	963e                	add	a2,a2,a5
      *--d = *--s;
    80000c20:	17fd                	addi	a5,a5,-1
    80000c22:	177d                	addi	a4,a4,-1
    80000c24:	0007c683          	lbu	a3,0(a5)
    80000c28:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
    80000c2c:	fec79ae3          	bne	a5,a2,80000c20 <memmove+0x52>
    80000c30:	bfd9                	j	80000c06 <memmove+0x38>

0000000080000c32 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80000c32:	1141                	addi	sp,sp,-16
    80000c34:	e406                	sd	ra,8(sp)
    80000c36:	e022                	sd	s0,0(sp)
    80000c38:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000c3a:	00000097          	auipc	ra,0x0
    80000c3e:	f94080e7          	jalr	-108(ra) # 80000bce <memmove>
}
    80000c42:	60a2                	ld	ra,8(sp)
    80000c44:	6402                	ld	s0,0(sp)
    80000c46:	0141                	addi	sp,sp,16
    80000c48:	8082                	ret

0000000080000c4a <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000c4a:	1141                	addi	sp,sp,-16
    80000c4c:	e422                	sd	s0,8(sp)
    80000c4e:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000c50:	ce11                	beqz	a2,80000c6c <strncmp+0x22>
    80000c52:	00054783          	lbu	a5,0(a0)
    80000c56:	cf89                	beqz	a5,80000c70 <strncmp+0x26>
    80000c58:	0005c703          	lbu	a4,0(a1)
    80000c5c:	00f71a63          	bne	a4,a5,80000c70 <strncmp+0x26>
    n--, p++, q++;
    80000c60:	367d                	addiw	a2,a2,-1
    80000c62:	0505                	addi	a0,a0,1
    80000c64:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    80000c66:	f675                	bnez	a2,80000c52 <strncmp+0x8>
  if(n == 0)
    return 0;
    80000c68:	4501                	li	a0,0
    80000c6a:	a809                	j	80000c7c <strncmp+0x32>
    80000c6c:	4501                	li	a0,0
    80000c6e:	a039                	j	80000c7c <strncmp+0x32>
  if(n == 0)
    80000c70:	ca09                	beqz	a2,80000c82 <strncmp+0x38>
  return (uchar)*p - (uchar)*q;
    80000c72:	00054503          	lbu	a0,0(a0)
    80000c76:	0005c783          	lbu	a5,0(a1)
    80000c7a:	9d1d                	subw	a0,a0,a5
}
    80000c7c:	6422                	ld	s0,8(sp)
    80000c7e:	0141                	addi	sp,sp,16
    80000c80:	8082                	ret
    return 0;
    80000c82:	4501                	li	a0,0
    80000c84:	bfe5                	j	80000c7c <strncmp+0x32>

0000000080000c86 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    80000c86:	1141                	addi	sp,sp,-16
    80000c88:	e422                	sd	s0,8(sp)
    80000c8a:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    80000c8c:	872a                	mv	a4,a0
    80000c8e:	8832                	mv	a6,a2
    80000c90:	367d                	addiw	a2,a2,-1
    80000c92:	01005963          	blez	a6,80000ca4 <strncpy+0x1e>
    80000c96:	0705                	addi	a4,a4,1
    80000c98:	0005c783          	lbu	a5,0(a1)
    80000c9c:	fef70fa3          	sb	a5,-1(a4)
    80000ca0:	0585                	addi	a1,a1,1
    80000ca2:	f7f5                	bnez	a5,80000c8e <strncpy+0x8>
    ;
  while(n-- > 0)
    80000ca4:	00c05d63          	blez	a2,80000cbe <strncpy+0x38>
    80000ca8:	86ba                	mv	a3,a4
    *s++ = 0;
    80000caa:	0685                	addi	a3,a3,1
    80000cac:	fe068fa3          	sb	zero,-1(a3)
  while(n-- > 0)
    80000cb0:	fff6c793          	not	a5,a3
    80000cb4:	9fb9                	addw	a5,a5,a4
    80000cb6:	010787bb          	addw	a5,a5,a6
    80000cba:	fef048e3          	bgtz	a5,80000caa <strncpy+0x24>
  return os;
}
    80000cbe:	6422                	ld	s0,8(sp)
    80000cc0:	0141                	addi	sp,sp,16
    80000cc2:	8082                	ret

0000000080000cc4 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    80000cc4:	1141                	addi	sp,sp,-16
    80000cc6:	e422                	sd	s0,8(sp)
    80000cc8:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    80000cca:	02c05363          	blez	a2,80000cf0 <safestrcpy+0x2c>
    80000cce:	fff6069b          	addiw	a3,a2,-1
    80000cd2:	1682                	slli	a3,a3,0x20
    80000cd4:	9281                	srli	a3,a3,0x20
    80000cd6:	96ae                	add	a3,a3,a1
    80000cd8:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    80000cda:	00d58963          	beq	a1,a3,80000cec <safestrcpy+0x28>
    80000cde:	0585                	addi	a1,a1,1
    80000ce0:	0785                	addi	a5,a5,1
    80000ce2:	fff5c703          	lbu	a4,-1(a1)
    80000ce6:	fee78fa3          	sb	a4,-1(a5)
    80000cea:	fb65                	bnez	a4,80000cda <safestrcpy+0x16>
    ;
  *s = 0;
    80000cec:	00078023          	sb	zero,0(a5)
  return os;
}
    80000cf0:	6422                	ld	s0,8(sp)
    80000cf2:	0141                	addi	sp,sp,16
    80000cf4:	8082                	ret

0000000080000cf6 <strlen>:

int
strlen(const char *s)
{
    80000cf6:	1141                	addi	sp,sp,-16
    80000cf8:	e422                	sd	s0,8(sp)
    80000cfa:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80000cfc:	00054783          	lbu	a5,0(a0)
    80000d00:	cf91                	beqz	a5,80000d1c <strlen+0x26>
    80000d02:	0505                	addi	a0,a0,1
    80000d04:	87aa                	mv	a5,a0
    80000d06:	4685                	li	a3,1
    80000d08:	9e89                	subw	a3,a3,a0
    80000d0a:	00f6853b          	addw	a0,a3,a5
    80000d0e:	0785                	addi	a5,a5,1
    80000d10:	fff7c703          	lbu	a4,-1(a5)
    80000d14:	fb7d                	bnez	a4,80000d0a <strlen+0x14>
    ;
  return n;
}
    80000d16:	6422                	ld	s0,8(sp)
    80000d18:	0141                	addi	sp,sp,16
    80000d1a:	8082                	ret
  for(n = 0; s[n]; n++)
    80000d1c:	4501                	li	a0,0
    80000d1e:	bfe5                	j	80000d16 <strlen+0x20>

0000000080000d20 <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80000d20:	1141                	addi	sp,sp,-16
    80000d22:	e406                	sd	ra,8(sp)
    80000d24:	e022                	sd	s0,0(sp)
    80000d26:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    80000d28:	00001097          	auipc	ra,0x1
    80000d2c:	af0080e7          	jalr	-1296(ra) # 80001818 <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000d30:	00025717          	auipc	a4,0x25
    80000d34:	2d470713          	addi	a4,a4,724 # 80026004 <started>
  if(cpuid() == 0){
    80000d38:	c139                	beqz	a0,80000d7e <main+0x5e>
    while(started == 0)
    80000d3a:	431c                	lw	a5,0(a4)
    80000d3c:	2781                	sext.w	a5,a5
    80000d3e:	dff5                	beqz	a5,80000d3a <main+0x1a>
      ;
    __sync_synchronize();
    80000d40:	0ff0000f          	fence
    printf("hart %d starting\n", cpuid());
    80000d44:	00001097          	auipc	ra,0x1
    80000d48:	ad4080e7          	jalr	-1324(ra) # 80001818 <cpuid>
    80000d4c:	85aa                	mv	a1,a0
    80000d4e:	00006517          	auipc	a0,0x6
    80000d52:	45250513          	addi	a0,a0,1106 # 800071a0 <userret+0x110>
    80000d56:	00000097          	auipc	ra,0x0
    80000d5a:	842080e7          	jalr	-1982(ra) # 80000598 <printf>
    kvminithart();    // turn on paging
    80000d5e:	00000097          	auipc	ra,0x0
    80000d62:	1e8080e7          	jalr	488(ra) # 80000f46 <kvminithart>
    trapinithart();   // install kernel trap vector
    80000d66:	00001097          	auipc	ra,0x1
    80000d6a:	774080e7          	jalr	1908(ra) # 800024da <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000d6e:	00005097          	auipc	ra,0x5
    80000d72:	e12080e7          	jalr	-494(ra) # 80005b80 <plicinithart>
  }

  scheduler();        
    80000d76:	00001097          	auipc	ra,0x1
    80000d7a:	fac080e7          	jalr	-84(ra) # 80001d22 <scheduler>
    consoleinit();
    80000d7e:	fffff097          	auipc	ra,0xfffff
    80000d82:	6e2080e7          	jalr	1762(ra) # 80000460 <consoleinit>
    printfinit();
    80000d86:	00000097          	auipc	ra,0x0
    80000d8a:	9f8080e7          	jalr	-1544(ra) # 8000077e <printfinit>
    printf("\n");
    80000d8e:	00006517          	auipc	a0,0x6
    80000d92:	42250513          	addi	a0,a0,1058 # 800071b0 <userret+0x120>
    80000d96:	00000097          	auipc	ra,0x0
    80000d9a:	802080e7          	jalr	-2046(ra) # 80000598 <printf>
    printf("xv6 kernel is booting\n");
    80000d9e:	00006517          	auipc	a0,0x6
    80000da2:	3ea50513          	addi	a0,a0,1002 # 80007188 <userret+0xf8>
    80000da6:	fffff097          	auipc	ra,0xfffff
    80000daa:	7f2080e7          	jalr	2034(ra) # 80000598 <printf>
    printf("\n");
    80000dae:	00006517          	auipc	a0,0x6
    80000db2:	40250513          	addi	a0,a0,1026 # 800071b0 <userret+0x120>
    80000db6:	fffff097          	auipc	ra,0xfffff
    80000dba:	7e2080e7          	jalr	2018(ra) # 80000598 <printf>
    kinit();         // physical page allocator
    80000dbe:	00000097          	auipc	ra,0x0
    80000dc2:	b66080e7          	jalr	-1178(ra) # 80000924 <kinit>
    kvminit();       // create kernel page table
    80000dc6:	00000097          	auipc	ra,0x0
    80000dca:	30a080e7          	jalr	778(ra) # 800010d0 <kvminit>
    kvminithart();   // turn on paging
    80000dce:	00000097          	auipc	ra,0x0
    80000dd2:	178080e7          	jalr	376(ra) # 80000f46 <kvminithart>
    procinit();      // process table
    80000dd6:	00001097          	auipc	ra,0x1
    80000dda:	972080e7          	jalr	-1678(ra) # 80001748 <procinit>
    trapinit();      // trap vectors
    80000dde:	00001097          	auipc	ra,0x1
    80000de2:	6d4080e7          	jalr	1748(ra) # 800024b2 <trapinit>
    trapinithart();  // install kernel trap vector
    80000de6:	00001097          	auipc	ra,0x1
    80000dea:	6f4080e7          	jalr	1780(ra) # 800024da <trapinithart>
    plicinit();      // set up interrupt controller
    80000dee:	00005097          	auipc	ra,0x5
    80000df2:	d7c080e7          	jalr	-644(ra) # 80005b6a <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000df6:	00005097          	auipc	ra,0x5
    80000dfa:	d8a080e7          	jalr	-630(ra) # 80005b80 <plicinithart>
    binit();         // buffer cache
    80000dfe:	00002097          	auipc	ra,0x2
    80000e02:	ebc080e7          	jalr	-324(ra) # 80002cba <binit>
    iinit();         // inode cache
    80000e06:	00002097          	auipc	ra,0x2
    80000e0a:	54c080e7          	jalr	1356(ra) # 80003352 <iinit>
    fileinit();      // file table
    80000e0e:	00003097          	auipc	ra,0x3
    80000e12:	4c0080e7          	jalr	1216(ra) # 800042ce <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000e16:	00005097          	auipc	ra,0x5
    80000e1a:	e84080e7          	jalr	-380(ra) # 80005c9a <virtio_disk_init>
    userinit();      // first user process
    80000e1e:	00001097          	auipc	ra,0x1
    80000e22:	c9e080e7          	jalr	-866(ra) # 80001abc <userinit>
    __sync_synchronize();
    80000e26:	0ff0000f          	fence
    started = 1;
    80000e2a:	4785                	li	a5,1
    80000e2c:	00025717          	auipc	a4,0x25
    80000e30:	1cf72c23          	sw	a5,472(a4) # 80026004 <started>
    80000e34:	b789                	j	80000d76 <main+0x56>

0000000080000e36 <walk>:
//   21..39 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..12 -- 12 bits of byte offset within the page.
static pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    80000e36:	7139                	addi	sp,sp,-64
    80000e38:	fc06                	sd	ra,56(sp)
    80000e3a:	f822                	sd	s0,48(sp)
    80000e3c:	f426                	sd	s1,40(sp)
    80000e3e:	f04a                	sd	s2,32(sp)
    80000e40:	ec4e                	sd	s3,24(sp)
    80000e42:	e852                	sd	s4,16(sp)
    80000e44:	e456                	sd	s5,8(sp)
    80000e46:	e05a                	sd	s6,0(sp)
    80000e48:	0080                	addi	s0,sp,64
    80000e4a:	84aa                	mv	s1,a0
    80000e4c:	89ae                	mv	s3,a1
    80000e4e:	8ab2                	mv	s5,a2
  if(va >= MAXVA)
    80000e50:	57fd                	li	a5,-1
    80000e52:	83e9                	srli	a5,a5,0x1a
    80000e54:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    80000e56:	4b31                	li	s6,12
  if(va >= MAXVA)
    80000e58:	04b7f263          	bgeu	a5,a1,80000e9c <walk+0x66>
    panic("walk");
    80000e5c:	00006517          	auipc	a0,0x6
    80000e60:	35c50513          	addi	a0,a0,860 # 800071b8 <userret+0x128>
    80000e64:	fffff097          	auipc	ra,0xfffff
    80000e68:	6ea080e7          	jalr	1770(ra) # 8000054e <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    80000e6c:	060a8663          	beqz	s5,80000ed8 <walk+0xa2>
    80000e70:	00000097          	auipc	ra,0x0
    80000e74:	af0080e7          	jalr	-1296(ra) # 80000960 <kalloc>
    80000e78:	84aa                	mv	s1,a0
    80000e7a:	c529                	beqz	a0,80000ec4 <walk+0x8e>
        return 0;
      memset(pagetable, 0, PGSIZE);
    80000e7c:	6605                	lui	a2,0x1
    80000e7e:	4581                	li	a1,0
    80000e80:	00000097          	auipc	ra,0x0
    80000e84:	cee080e7          	jalr	-786(ra) # 80000b6e <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    80000e88:	00c4d793          	srli	a5,s1,0xc
    80000e8c:	07aa                	slli	a5,a5,0xa
    80000e8e:	0017e793          	ori	a5,a5,1
    80000e92:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    80000e96:	3a5d                	addiw	s4,s4,-9
    80000e98:	036a0063          	beq	s4,s6,80000eb8 <walk+0x82>
    pte_t *pte = &pagetable[PX(level, va)];
    80000e9c:	0149d933          	srl	s2,s3,s4
    80000ea0:	1ff97913          	andi	s2,s2,511
    80000ea4:	090e                	slli	s2,s2,0x3
    80000ea6:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    80000ea8:	00093483          	ld	s1,0(s2)
    80000eac:	0014f793          	andi	a5,s1,1
    80000eb0:	dfd5                	beqz	a5,80000e6c <walk+0x36>
      pagetable = (pagetable_t)PTE2PA(*pte);
    80000eb2:	80a9                	srli	s1,s1,0xa
    80000eb4:	04b2                	slli	s1,s1,0xc
    80000eb6:	b7c5                	j	80000e96 <walk+0x60>
    }
  }
  return &pagetable[PX(0, va)];
    80000eb8:	00c9d513          	srli	a0,s3,0xc
    80000ebc:	1ff57513          	andi	a0,a0,511
    80000ec0:	050e                	slli	a0,a0,0x3
    80000ec2:	9526                	add	a0,a0,s1
}
    80000ec4:	70e2                	ld	ra,56(sp)
    80000ec6:	7442                	ld	s0,48(sp)
    80000ec8:	74a2                	ld	s1,40(sp)
    80000eca:	7902                	ld	s2,32(sp)
    80000ecc:	69e2                	ld	s3,24(sp)
    80000ece:	6a42                	ld	s4,16(sp)
    80000ed0:	6aa2                	ld	s5,8(sp)
    80000ed2:	6b02                	ld	s6,0(sp)
    80000ed4:	6121                	addi	sp,sp,64
    80000ed6:	8082                	ret
        return 0;
    80000ed8:	4501                	li	a0,0
    80000eda:	b7ed                	j	80000ec4 <walk+0x8e>

0000000080000edc <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
static void
freewalk(pagetable_t pagetable)
{
    80000edc:	7179                	addi	sp,sp,-48
    80000ede:	f406                	sd	ra,40(sp)
    80000ee0:	f022                	sd	s0,32(sp)
    80000ee2:	ec26                	sd	s1,24(sp)
    80000ee4:	e84a                	sd	s2,16(sp)
    80000ee6:	e44e                	sd	s3,8(sp)
    80000ee8:	e052                	sd	s4,0(sp)
    80000eea:	1800                	addi	s0,sp,48
    80000eec:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    80000eee:	84aa                	mv	s1,a0
    80000ef0:	6905                	lui	s2,0x1
    80000ef2:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    80000ef4:	4985                	li	s3,1
    80000ef6:	a821                	j	80000f0e <freewalk+0x32>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    80000ef8:	8129                	srli	a0,a0,0xa
      freewalk((pagetable_t)child);
    80000efa:	0532                	slli	a0,a0,0xc
    80000efc:	00000097          	auipc	ra,0x0
    80000f00:	fe0080e7          	jalr	-32(ra) # 80000edc <freewalk>
      pagetable[i] = 0;
    80000f04:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    80000f08:	04a1                	addi	s1,s1,8
    80000f0a:	03248163          	beq	s1,s2,80000f2c <freewalk+0x50>
    pte_t pte = pagetable[i];
    80000f0e:	6088                	ld	a0,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    80000f10:	00f57793          	andi	a5,a0,15
    80000f14:	ff3782e3          	beq	a5,s3,80000ef8 <freewalk+0x1c>
    } else if(pte & PTE_V){
    80000f18:	8905                	andi	a0,a0,1
    80000f1a:	d57d                	beqz	a0,80000f08 <freewalk+0x2c>
      panic("freewalk: leaf");
    80000f1c:	00006517          	auipc	a0,0x6
    80000f20:	2a450513          	addi	a0,a0,676 # 800071c0 <userret+0x130>
    80000f24:	fffff097          	auipc	ra,0xfffff
    80000f28:	62a080e7          	jalr	1578(ra) # 8000054e <panic>
    }
  }
  kfree((void*)pagetable);
    80000f2c:	8552                	mv	a0,s4
    80000f2e:	00000097          	auipc	ra,0x0
    80000f32:	936080e7          	jalr	-1738(ra) # 80000864 <kfree>
}
    80000f36:	70a2                	ld	ra,40(sp)
    80000f38:	7402                	ld	s0,32(sp)
    80000f3a:	64e2                	ld	s1,24(sp)
    80000f3c:	6942                	ld	s2,16(sp)
    80000f3e:	69a2                	ld	s3,8(sp)
    80000f40:	6a02                	ld	s4,0(sp)
    80000f42:	6145                	addi	sp,sp,48
    80000f44:	8082                	ret

0000000080000f46 <kvminithart>:
{
    80000f46:	1141                	addi	sp,sp,-16
    80000f48:	e422                	sd	s0,8(sp)
    80000f4a:	0800                	addi	s0,sp,16
  w_satp(MAKE_SATP(kernel_pagetable));
    80000f4c:	00025797          	auipc	a5,0x25
    80000f50:	0bc7b783          	ld	a5,188(a5) # 80026008 <kernel_pagetable>
    80000f54:	83b1                	srli	a5,a5,0xc
    80000f56:	577d                	li	a4,-1
    80000f58:	177e                	slli	a4,a4,0x3f
    80000f5a:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    80000f5c:	18079073          	csrw	satp,a5
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    80000f60:	12000073          	sfence.vma
}
    80000f64:	6422                	ld	s0,8(sp)
    80000f66:	0141                	addi	sp,sp,16
    80000f68:	8082                	ret

0000000080000f6a <walkaddr>:
  if(va >= MAXVA)
    80000f6a:	57fd                	li	a5,-1
    80000f6c:	83e9                	srli	a5,a5,0x1a
    80000f6e:	00b7f463          	bgeu	a5,a1,80000f76 <walkaddr+0xc>
    return 0;
    80000f72:	4501                	li	a0,0
}
    80000f74:	8082                	ret
{
    80000f76:	1141                	addi	sp,sp,-16
    80000f78:	e406                	sd	ra,8(sp)
    80000f7a:	e022                	sd	s0,0(sp)
    80000f7c:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    80000f7e:	4601                	li	a2,0
    80000f80:	00000097          	auipc	ra,0x0
    80000f84:	eb6080e7          	jalr	-330(ra) # 80000e36 <walk>
  if(pte == 0)
    80000f88:	c105                	beqz	a0,80000fa8 <walkaddr+0x3e>
  if((*pte & PTE_V) == 0)
    80000f8a:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    80000f8c:	0117f693          	andi	a3,a5,17
    80000f90:	4745                	li	a4,17
    return 0;
    80000f92:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    80000f94:	00e68663          	beq	a3,a4,80000fa0 <walkaddr+0x36>
}
    80000f98:	60a2                	ld	ra,8(sp)
    80000f9a:	6402                	ld	s0,0(sp)
    80000f9c:	0141                	addi	sp,sp,16
    80000f9e:	8082                	ret
  pa = PTE2PA(*pte);
    80000fa0:	00a7d513          	srli	a0,a5,0xa
    80000fa4:	0532                	slli	a0,a0,0xc
  return pa;
    80000fa6:	bfcd                	j	80000f98 <walkaddr+0x2e>
    return 0;
    80000fa8:	4501                	li	a0,0
    80000faa:	b7fd                	j	80000f98 <walkaddr+0x2e>

0000000080000fac <kvmpa>:
{
    80000fac:	1101                	addi	sp,sp,-32
    80000fae:	ec06                	sd	ra,24(sp)
    80000fb0:	e822                	sd	s0,16(sp)
    80000fb2:	e426                	sd	s1,8(sp)
    80000fb4:	1000                	addi	s0,sp,32
    80000fb6:	85aa                	mv	a1,a0
  uint64 off = va % PGSIZE;
    80000fb8:	1552                	slli	a0,a0,0x34
    80000fba:	03455493          	srli	s1,a0,0x34
  pte = walk(kernel_pagetable, va, 0);
    80000fbe:	4601                	li	a2,0
    80000fc0:	00025517          	auipc	a0,0x25
    80000fc4:	04853503          	ld	a0,72(a0) # 80026008 <kernel_pagetable>
    80000fc8:	00000097          	auipc	ra,0x0
    80000fcc:	e6e080e7          	jalr	-402(ra) # 80000e36 <walk>
  if(pte == 0)
    80000fd0:	cd09                	beqz	a0,80000fea <kvmpa+0x3e>
  if((*pte & PTE_V) == 0)
    80000fd2:	6108                	ld	a0,0(a0)
    80000fd4:	00157793          	andi	a5,a0,1
    80000fd8:	c38d                	beqz	a5,80000ffa <kvmpa+0x4e>
  pa = PTE2PA(*pte);
    80000fda:	8129                	srli	a0,a0,0xa
    80000fdc:	0532                	slli	a0,a0,0xc
}
    80000fde:	9526                	add	a0,a0,s1
    80000fe0:	60e2                	ld	ra,24(sp)
    80000fe2:	6442                	ld	s0,16(sp)
    80000fe4:	64a2                	ld	s1,8(sp)
    80000fe6:	6105                	addi	sp,sp,32
    80000fe8:	8082                	ret
    panic("kvmpa");
    80000fea:	00006517          	auipc	a0,0x6
    80000fee:	1e650513          	addi	a0,a0,486 # 800071d0 <userret+0x140>
    80000ff2:	fffff097          	auipc	ra,0xfffff
    80000ff6:	55c080e7          	jalr	1372(ra) # 8000054e <panic>
    panic("kvmpa");
    80000ffa:	00006517          	auipc	a0,0x6
    80000ffe:	1d650513          	addi	a0,a0,470 # 800071d0 <userret+0x140>
    80001002:	fffff097          	auipc	ra,0xfffff
    80001006:	54c080e7          	jalr	1356(ra) # 8000054e <panic>

000000008000100a <mappages>:
{
    8000100a:	715d                	addi	sp,sp,-80
    8000100c:	e486                	sd	ra,72(sp)
    8000100e:	e0a2                	sd	s0,64(sp)
    80001010:	fc26                	sd	s1,56(sp)
    80001012:	f84a                	sd	s2,48(sp)
    80001014:	f44e                	sd	s3,40(sp)
    80001016:	f052                	sd	s4,32(sp)
    80001018:	ec56                	sd	s5,24(sp)
    8000101a:	e85a                	sd	s6,16(sp)
    8000101c:	e45e                	sd	s7,8(sp)
    8000101e:	0880                	addi	s0,sp,80
    80001020:	8aaa                	mv	s5,a0
    80001022:	8b3a                	mv	s6,a4
  a = PGROUNDDOWN(va);
    80001024:	777d                	lui	a4,0xfffff
    80001026:	00e5f7b3          	and	a5,a1,a4
  last = PGROUNDDOWN(va + size - 1);
    8000102a:	167d                	addi	a2,a2,-1
    8000102c:	00b609b3          	add	s3,a2,a1
    80001030:	00e9f9b3          	and	s3,s3,a4
  a = PGROUNDDOWN(va);
    80001034:	893e                	mv	s2,a5
    80001036:	40f68a33          	sub	s4,a3,a5
    a += PGSIZE;
    8000103a:	6b85                	lui	s7,0x1
    8000103c:	012a04b3          	add	s1,s4,s2
    if((pte = walk(pagetable, a, 1)) == 0)
    80001040:	4605                	li	a2,1
    80001042:	85ca                	mv	a1,s2
    80001044:	8556                	mv	a0,s5
    80001046:	00000097          	auipc	ra,0x0
    8000104a:	df0080e7          	jalr	-528(ra) # 80000e36 <walk>
    8000104e:	c51d                	beqz	a0,8000107c <mappages+0x72>
    if(*pte & PTE_V)
    80001050:	611c                	ld	a5,0(a0)
    80001052:	8b85                	andi	a5,a5,1
    80001054:	ef81                	bnez	a5,8000106c <mappages+0x62>
    *pte = PA2PTE(pa) | perm | PTE_V;
    80001056:	80b1                	srli	s1,s1,0xc
    80001058:	04aa                	slli	s1,s1,0xa
    8000105a:	0164e4b3          	or	s1,s1,s6
    8000105e:	0014e493          	ori	s1,s1,1
    80001062:	e104                	sd	s1,0(a0)
    if(a == last)
    80001064:	03390863          	beq	s2,s3,80001094 <mappages+0x8a>
    a += PGSIZE;
    80001068:	995e                	add	s2,s2,s7
    if((pte = walk(pagetable, a, 1)) == 0)
    8000106a:	bfc9                	j	8000103c <mappages+0x32>
      panic("remap");
    8000106c:	00006517          	auipc	a0,0x6
    80001070:	16c50513          	addi	a0,a0,364 # 800071d8 <userret+0x148>
    80001074:	fffff097          	auipc	ra,0xfffff
    80001078:	4da080e7          	jalr	1242(ra) # 8000054e <panic>
      return -1;
    8000107c:	557d                	li	a0,-1
}
    8000107e:	60a6                	ld	ra,72(sp)
    80001080:	6406                	ld	s0,64(sp)
    80001082:	74e2                	ld	s1,56(sp)
    80001084:	7942                	ld	s2,48(sp)
    80001086:	79a2                	ld	s3,40(sp)
    80001088:	7a02                	ld	s4,32(sp)
    8000108a:	6ae2                	ld	s5,24(sp)
    8000108c:	6b42                	ld	s6,16(sp)
    8000108e:	6ba2                	ld	s7,8(sp)
    80001090:	6161                	addi	sp,sp,80
    80001092:	8082                	ret
  return 0;
    80001094:	4501                	li	a0,0
    80001096:	b7e5                	j	8000107e <mappages+0x74>

0000000080001098 <kvmmap>:
{
    80001098:	1141                	addi	sp,sp,-16
    8000109a:	e406                	sd	ra,8(sp)
    8000109c:	e022                	sd	s0,0(sp)
    8000109e:	0800                	addi	s0,sp,16
    800010a0:	8736                	mv	a4,a3
  if(mappages(kernel_pagetable, va, sz, pa, perm) != 0)
    800010a2:	86ae                	mv	a3,a1
    800010a4:	85aa                	mv	a1,a0
    800010a6:	00025517          	auipc	a0,0x25
    800010aa:	f6253503          	ld	a0,-158(a0) # 80026008 <kernel_pagetable>
    800010ae:	00000097          	auipc	ra,0x0
    800010b2:	f5c080e7          	jalr	-164(ra) # 8000100a <mappages>
    800010b6:	e509                	bnez	a0,800010c0 <kvmmap+0x28>
}
    800010b8:	60a2                	ld	ra,8(sp)
    800010ba:	6402                	ld	s0,0(sp)
    800010bc:	0141                	addi	sp,sp,16
    800010be:	8082                	ret
    panic("kvmmap");
    800010c0:	00006517          	auipc	a0,0x6
    800010c4:	12050513          	addi	a0,a0,288 # 800071e0 <userret+0x150>
    800010c8:	fffff097          	auipc	ra,0xfffff
    800010cc:	486080e7          	jalr	1158(ra) # 8000054e <panic>

00000000800010d0 <kvminit>:
{
    800010d0:	1101                	addi	sp,sp,-32
    800010d2:	ec06                	sd	ra,24(sp)
    800010d4:	e822                	sd	s0,16(sp)
    800010d6:	e426                	sd	s1,8(sp)
    800010d8:	1000                	addi	s0,sp,32
  kernel_pagetable = (pagetable_t) kalloc();
    800010da:	00000097          	auipc	ra,0x0
    800010de:	886080e7          	jalr	-1914(ra) # 80000960 <kalloc>
    800010e2:	00025797          	auipc	a5,0x25
    800010e6:	f2a7b323          	sd	a0,-218(a5) # 80026008 <kernel_pagetable>
  memset(kernel_pagetable, 0, PGSIZE);
    800010ea:	6605                	lui	a2,0x1
    800010ec:	4581                	li	a1,0
    800010ee:	00000097          	auipc	ra,0x0
    800010f2:	a80080e7          	jalr	-1408(ra) # 80000b6e <memset>
  kvmmap(UART0, UART0, PGSIZE, PTE_R | PTE_W);
    800010f6:	4699                	li	a3,6
    800010f8:	6605                	lui	a2,0x1
    800010fa:	100005b7          	lui	a1,0x10000
    800010fe:	10000537          	lui	a0,0x10000
    80001102:	00000097          	auipc	ra,0x0
    80001106:	f96080e7          	jalr	-106(ra) # 80001098 <kvmmap>
  kvmmap(VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    8000110a:	4699                	li	a3,6
    8000110c:	6605                	lui	a2,0x1
    8000110e:	100015b7          	lui	a1,0x10001
    80001112:	10001537          	lui	a0,0x10001
    80001116:	00000097          	auipc	ra,0x0
    8000111a:	f82080e7          	jalr	-126(ra) # 80001098 <kvmmap>
  kvmmap(CLINT, CLINT, 0x10000, PTE_R | PTE_W);
    8000111e:	4699                	li	a3,6
    80001120:	6641                	lui	a2,0x10
    80001122:	020005b7          	lui	a1,0x2000
    80001126:	02000537          	lui	a0,0x2000
    8000112a:	00000097          	auipc	ra,0x0
    8000112e:	f6e080e7          	jalr	-146(ra) # 80001098 <kvmmap>
  kvmmap(PLIC, PLIC, 0x400000, PTE_R | PTE_W);
    80001132:	4699                	li	a3,6
    80001134:	00400637          	lui	a2,0x400
    80001138:	0c0005b7          	lui	a1,0xc000
    8000113c:	0c000537          	lui	a0,0xc000
    80001140:	00000097          	auipc	ra,0x0
    80001144:	f58080e7          	jalr	-168(ra) # 80001098 <kvmmap>
  kvmmap(KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    80001148:	00007497          	auipc	s1,0x7
    8000114c:	eb848493          	addi	s1,s1,-328 # 80008000 <initcode>
    80001150:	46a9                	li	a3,10
    80001152:	80007617          	auipc	a2,0x80007
    80001156:	eae60613          	addi	a2,a2,-338 # 8000 <_entry-0x7fff8000>
    8000115a:	4585                	li	a1,1
    8000115c:	05fe                	slli	a1,a1,0x1f
    8000115e:	852e                	mv	a0,a1
    80001160:	00000097          	auipc	ra,0x0
    80001164:	f38080e7          	jalr	-200(ra) # 80001098 <kvmmap>
  kvmmap((uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    80001168:	4699                	li	a3,6
    8000116a:	4645                	li	a2,17
    8000116c:	066e                	slli	a2,a2,0x1b
    8000116e:	8e05                	sub	a2,a2,s1
    80001170:	85a6                	mv	a1,s1
    80001172:	8526                	mv	a0,s1
    80001174:	00000097          	auipc	ra,0x0
    80001178:	f24080e7          	jalr	-220(ra) # 80001098 <kvmmap>
  kvmmap(TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    8000117c:	46a9                	li	a3,10
    8000117e:	6605                	lui	a2,0x1
    80001180:	00006597          	auipc	a1,0x6
    80001184:	e8058593          	addi	a1,a1,-384 # 80007000 <trampoline>
    80001188:	04000537          	lui	a0,0x4000
    8000118c:	157d                	addi	a0,a0,-1
    8000118e:	0532                	slli	a0,a0,0xc
    80001190:	00000097          	auipc	ra,0x0
    80001194:	f08080e7          	jalr	-248(ra) # 80001098 <kvmmap>
}
    80001198:	60e2                	ld	ra,24(sp)
    8000119a:	6442                	ld	s0,16(sp)
    8000119c:	64a2                	ld	s1,8(sp)
    8000119e:	6105                	addi	sp,sp,32
    800011a0:	8082                	ret

00000000800011a2 <uvmunmap>:
{
    800011a2:	715d                	addi	sp,sp,-80
    800011a4:	e486                	sd	ra,72(sp)
    800011a6:	e0a2                	sd	s0,64(sp)
    800011a8:	fc26                	sd	s1,56(sp)
    800011aa:	f84a                	sd	s2,48(sp)
    800011ac:	f44e                	sd	s3,40(sp)
    800011ae:	f052                	sd	s4,32(sp)
    800011b0:	ec56                	sd	s5,24(sp)
    800011b2:	e85a                	sd	s6,16(sp)
    800011b4:	e45e                	sd	s7,8(sp)
    800011b6:	0880                	addi	s0,sp,80
    800011b8:	8a2a                	mv	s4,a0
    800011ba:	8ab6                	mv	s5,a3
  a = PGROUNDDOWN(va);
    800011bc:	77fd                	lui	a5,0xfffff
    800011be:	00f5f933          	and	s2,a1,a5
  last = PGROUNDDOWN(va + size - 1);
    800011c2:	167d                	addi	a2,a2,-1
    800011c4:	00b609b3          	add	s3,a2,a1
    800011c8:	00f9f9b3          	and	s3,s3,a5
    if(PTE_FLAGS(*pte) == PTE_V)
    800011cc:	4b05                	li	s6,1
    a += PGSIZE;
    800011ce:	6b85                	lui	s7,0x1
    800011d0:	a8b1                	j	8000122c <uvmunmap+0x8a>
      panic("uvmunmap: walk");
    800011d2:	00006517          	auipc	a0,0x6
    800011d6:	01650513          	addi	a0,a0,22 # 800071e8 <userret+0x158>
    800011da:	fffff097          	auipc	ra,0xfffff
    800011de:	374080e7          	jalr	884(ra) # 8000054e <panic>
      printf("va=%p pte=%p\n", a, *pte);
    800011e2:	862a                	mv	a2,a0
    800011e4:	85ca                	mv	a1,s2
    800011e6:	00006517          	auipc	a0,0x6
    800011ea:	01250513          	addi	a0,a0,18 # 800071f8 <userret+0x168>
    800011ee:	fffff097          	auipc	ra,0xfffff
    800011f2:	3aa080e7          	jalr	938(ra) # 80000598 <printf>
      panic("uvmunmap: not mapped");
    800011f6:	00006517          	auipc	a0,0x6
    800011fa:	01250513          	addi	a0,a0,18 # 80007208 <userret+0x178>
    800011fe:	fffff097          	auipc	ra,0xfffff
    80001202:	350080e7          	jalr	848(ra) # 8000054e <panic>
      panic("uvmunmap: not a leaf");
    80001206:	00006517          	auipc	a0,0x6
    8000120a:	01a50513          	addi	a0,a0,26 # 80007220 <userret+0x190>
    8000120e:	fffff097          	auipc	ra,0xfffff
    80001212:	340080e7          	jalr	832(ra) # 8000054e <panic>
      pa = PTE2PA(*pte);
    80001216:	8129                	srli	a0,a0,0xa
      kfree((void*)pa);
    80001218:	0532                	slli	a0,a0,0xc
    8000121a:	fffff097          	auipc	ra,0xfffff
    8000121e:	64a080e7          	jalr	1610(ra) # 80000864 <kfree>
    *pte = 0;
    80001222:	0004b023          	sd	zero,0(s1)
    if(a == last)
    80001226:	03390763          	beq	s2,s3,80001254 <uvmunmap+0xb2>
    a += PGSIZE;
    8000122a:	995e                	add	s2,s2,s7
    if((pte = walk(pagetable, a, 0)) == 0)
    8000122c:	4601                	li	a2,0
    8000122e:	85ca                	mv	a1,s2
    80001230:	8552                	mv	a0,s4
    80001232:	00000097          	auipc	ra,0x0
    80001236:	c04080e7          	jalr	-1020(ra) # 80000e36 <walk>
    8000123a:	84aa                	mv	s1,a0
    8000123c:	d959                	beqz	a0,800011d2 <uvmunmap+0x30>
    if((*pte & PTE_V) == 0){
    8000123e:	6108                	ld	a0,0(a0)
    80001240:	00157793          	andi	a5,a0,1
    80001244:	dfd9                	beqz	a5,800011e2 <uvmunmap+0x40>
    if(PTE_FLAGS(*pte) == PTE_V)
    80001246:	3ff57793          	andi	a5,a0,1023
    8000124a:	fb678ee3          	beq	a5,s6,80001206 <uvmunmap+0x64>
    if(do_free){
    8000124e:	fc0a8ae3          	beqz	s5,80001222 <uvmunmap+0x80>
    80001252:	b7d1                	j	80001216 <uvmunmap+0x74>
}
    80001254:	60a6                	ld	ra,72(sp)
    80001256:	6406                	ld	s0,64(sp)
    80001258:	74e2                	ld	s1,56(sp)
    8000125a:	7942                	ld	s2,48(sp)
    8000125c:	79a2                	ld	s3,40(sp)
    8000125e:	7a02                	ld	s4,32(sp)
    80001260:	6ae2                	ld	s5,24(sp)
    80001262:	6b42                	ld	s6,16(sp)
    80001264:	6ba2                	ld	s7,8(sp)
    80001266:	6161                	addi	sp,sp,80
    80001268:	8082                	ret

000000008000126a <uvmcreate>:
{
    8000126a:	1101                	addi	sp,sp,-32
    8000126c:	ec06                	sd	ra,24(sp)
    8000126e:	e822                	sd	s0,16(sp)
    80001270:	e426                	sd	s1,8(sp)
    80001272:	1000                	addi	s0,sp,32
  pagetable = (pagetable_t) kalloc();
    80001274:	fffff097          	auipc	ra,0xfffff
    80001278:	6ec080e7          	jalr	1772(ra) # 80000960 <kalloc>
  if(pagetable == 0)
    8000127c:	cd11                	beqz	a0,80001298 <uvmcreate+0x2e>
    8000127e:	84aa                	mv	s1,a0
  memset(pagetable, 0, PGSIZE);
    80001280:	6605                	lui	a2,0x1
    80001282:	4581                	li	a1,0
    80001284:	00000097          	auipc	ra,0x0
    80001288:	8ea080e7          	jalr	-1814(ra) # 80000b6e <memset>
}
    8000128c:	8526                	mv	a0,s1
    8000128e:	60e2                	ld	ra,24(sp)
    80001290:	6442                	ld	s0,16(sp)
    80001292:	64a2                	ld	s1,8(sp)
    80001294:	6105                	addi	sp,sp,32
    80001296:	8082                	ret
    panic("uvmcreate: out of memory");
    80001298:	00006517          	auipc	a0,0x6
    8000129c:	fa050513          	addi	a0,a0,-96 # 80007238 <userret+0x1a8>
    800012a0:	fffff097          	auipc	ra,0xfffff
    800012a4:	2ae080e7          	jalr	686(ra) # 8000054e <panic>

00000000800012a8 <uvminit>:
{
    800012a8:	7179                	addi	sp,sp,-48
    800012aa:	f406                	sd	ra,40(sp)
    800012ac:	f022                	sd	s0,32(sp)
    800012ae:	ec26                	sd	s1,24(sp)
    800012b0:	e84a                	sd	s2,16(sp)
    800012b2:	e44e                	sd	s3,8(sp)
    800012b4:	e052                	sd	s4,0(sp)
    800012b6:	1800                	addi	s0,sp,48
  if(sz >= PGSIZE)
    800012b8:	6785                	lui	a5,0x1
    800012ba:	04f67863          	bgeu	a2,a5,8000130a <uvminit+0x62>
    800012be:	8a2a                	mv	s4,a0
    800012c0:	89ae                	mv	s3,a1
    800012c2:	84b2                	mv	s1,a2
  mem = kalloc();
    800012c4:	fffff097          	auipc	ra,0xfffff
    800012c8:	69c080e7          	jalr	1692(ra) # 80000960 <kalloc>
    800012cc:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    800012ce:	6605                	lui	a2,0x1
    800012d0:	4581                	li	a1,0
    800012d2:	00000097          	auipc	ra,0x0
    800012d6:	89c080e7          	jalr	-1892(ra) # 80000b6e <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    800012da:	4779                	li	a4,30
    800012dc:	86ca                	mv	a3,s2
    800012de:	6605                	lui	a2,0x1
    800012e0:	4581                	li	a1,0
    800012e2:	8552                	mv	a0,s4
    800012e4:	00000097          	auipc	ra,0x0
    800012e8:	d26080e7          	jalr	-730(ra) # 8000100a <mappages>
  memmove(mem, src, sz);
    800012ec:	8626                	mv	a2,s1
    800012ee:	85ce                	mv	a1,s3
    800012f0:	854a                	mv	a0,s2
    800012f2:	00000097          	auipc	ra,0x0
    800012f6:	8dc080e7          	jalr	-1828(ra) # 80000bce <memmove>
}
    800012fa:	70a2                	ld	ra,40(sp)
    800012fc:	7402                	ld	s0,32(sp)
    800012fe:	64e2                	ld	s1,24(sp)
    80001300:	6942                	ld	s2,16(sp)
    80001302:	69a2                	ld	s3,8(sp)
    80001304:	6a02                	ld	s4,0(sp)
    80001306:	6145                	addi	sp,sp,48
    80001308:	8082                	ret
    panic("inituvm: more than a page");
    8000130a:	00006517          	auipc	a0,0x6
    8000130e:	f4e50513          	addi	a0,a0,-178 # 80007258 <userret+0x1c8>
    80001312:	fffff097          	auipc	ra,0xfffff
    80001316:	23c080e7          	jalr	572(ra) # 8000054e <panic>

000000008000131a <uvmdealloc>:
{
    8000131a:	1101                	addi	sp,sp,-32
    8000131c:	ec06                	sd	ra,24(sp)
    8000131e:	e822                	sd	s0,16(sp)
    80001320:	e426                	sd	s1,8(sp)
    80001322:	1000                	addi	s0,sp,32
    return oldsz;
    80001324:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    80001326:	00b67d63          	bgeu	a2,a1,80001340 <uvmdealloc+0x26>
    8000132a:	84b2                	mv	s1,a2
  uint64 newup = PGROUNDUP(newsz);
    8000132c:	6785                	lui	a5,0x1
    8000132e:	17fd                	addi	a5,a5,-1
    80001330:	00f60733          	add	a4,a2,a5
    80001334:	76fd                	lui	a3,0xfffff
    80001336:	8f75                	and	a4,a4,a3
  if(newup < PGROUNDUP(oldsz))
    80001338:	97ae                	add	a5,a5,a1
    8000133a:	8ff5                	and	a5,a5,a3
    8000133c:	00f76863          	bltu	a4,a5,8000134c <uvmdealloc+0x32>
}
    80001340:	8526                	mv	a0,s1
    80001342:	60e2                	ld	ra,24(sp)
    80001344:	6442                	ld	s0,16(sp)
    80001346:	64a2                	ld	s1,8(sp)
    80001348:	6105                	addi	sp,sp,32
    8000134a:	8082                	ret
    uvmunmap(pagetable, newup, oldsz - newup, 1);
    8000134c:	4685                	li	a3,1
    8000134e:	40e58633          	sub	a2,a1,a4
    80001352:	85ba                	mv	a1,a4
    80001354:	00000097          	auipc	ra,0x0
    80001358:	e4e080e7          	jalr	-434(ra) # 800011a2 <uvmunmap>
    8000135c:	b7d5                	j	80001340 <uvmdealloc+0x26>

000000008000135e <uvmalloc>:
  if(newsz < oldsz)
    8000135e:	0ab66163          	bltu	a2,a1,80001400 <uvmalloc+0xa2>
{
    80001362:	7139                	addi	sp,sp,-64
    80001364:	fc06                	sd	ra,56(sp)
    80001366:	f822                	sd	s0,48(sp)
    80001368:	f426                	sd	s1,40(sp)
    8000136a:	f04a                	sd	s2,32(sp)
    8000136c:	ec4e                	sd	s3,24(sp)
    8000136e:	e852                	sd	s4,16(sp)
    80001370:	e456                	sd	s5,8(sp)
    80001372:	0080                	addi	s0,sp,64
    80001374:	8aaa                	mv	s5,a0
    80001376:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    80001378:	6985                	lui	s3,0x1
    8000137a:	19fd                	addi	s3,s3,-1
    8000137c:	95ce                	add	a1,a1,s3
    8000137e:	79fd                	lui	s3,0xfffff
    80001380:	0135f9b3          	and	s3,a1,s3
  for(; a < newsz; a += PGSIZE){
    80001384:	08c9f063          	bgeu	s3,a2,80001404 <uvmalloc+0xa6>
  a = oldsz;
    80001388:	894e                	mv	s2,s3
    mem = kalloc();
    8000138a:	fffff097          	auipc	ra,0xfffff
    8000138e:	5d6080e7          	jalr	1494(ra) # 80000960 <kalloc>
    80001392:	84aa                	mv	s1,a0
    if(mem == 0){
    80001394:	c51d                	beqz	a0,800013c2 <uvmalloc+0x64>
    memset(mem, 0, PGSIZE);
    80001396:	6605                	lui	a2,0x1
    80001398:	4581                	li	a1,0
    8000139a:	fffff097          	auipc	ra,0xfffff
    8000139e:	7d4080e7          	jalr	2004(ra) # 80000b6e <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_W|PTE_X|PTE_R|PTE_U) != 0){
    800013a2:	4779                	li	a4,30
    800013a4:	86a6                	mv	a3,s1
    800013a6:	6605                	lui	a2,0x1
    800013a8:	85ca                	mv	a1,s2
    800013aa:	8556                	mv	a0,s5
    800013ac:	00000097          	auipc	ra,0x0
    800013b0:	c5e080e7          	jalr	-930(ra) # 8000100a <mappages>
    800013b4:	e905                	bnez	a0,800013e4 <uvmalloc+0x86>
  for(; a < newsz; a += PGSIZE){
    800013b6:	6785                	lui	a5,0x1
    800013b8:	993e                	add	s2,s2,a5
    800013ba:	fd4968e3          	bltu	s2,s4,8000138a <uvmalloc+0x2c>
  return newsz;
    800013be:	8552                	mv	a0,s4
    800013c0:	a809                	j	800013d2 <uvmalloc+0x74>
      uvmdealloc(pagetable, a, oldsz);
    800013c2:	864e                	mv	a2,s3
    800013c4:	85ca                	mv	a1,s2
    800013c6:	8556                	mv	a0,s5
    800013c8:	00000097          	auipc	ra,0x0
    800013cc:	f52080e7          	jalr	-174(ra) # 8000131a <uvmdealloc>
      return 0;
    800013d0:	4501                	li	a0,0
}
    800013d2:	70e2                	ld	ra,56(sp)
    800013d4:	7442                	ld	s0,48(sp)
    800013d6:	74a2                	ld	s1,40(sp)
    800013d8:	7902                	ld	s2,32(sp)
    800013da:	69e2                	ld	s3,24(sp)
    800013dc:	6a42                	ld	s4,16(sp)
    800013de:	6aa2                	ld	s5,8(sp)
    800013e0:	6121                	addi	sp,sp,64
    800013e2:	8082                	ret
      kfree(mem);
    800013e4:	8526                	mv	a0,s1
    800013e6:	fffff097          	auipc	ra,0xfffff
    800013ea:	47e080e7          	jalr	1150(ra) # 80000864 <kfree>
      uvmdealloc(pagetable, a, oldsz);
    800013ee:	864e                	mv	a2,s3
    800013f0:	85ca                	mv	a1,s2
    800013f2:	8556                	mv	a0,s5
    800013f4:	00000097          	auipc	ra,0x0
    800013f8:	f26080e7          	jalr	-218(ra) # 8000131a <uvmdealloc>
      return 0;
    800013fc:	4501                	li	a0,0
    800013fe:	bfd1                	j	800013d2 <uvmalloc+0x74>
    return oldsz;
    80001400:	852e                	mv	a0,a1
}
    80001402:	8082                	ret
  return newsz;
    80001404:	8532                	mv	a0,a2
    80001406:	b7f1                	j	800013d2 <uvmalloc+0x74>

0000000080001408 <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    80001408:	1101                	addi	sp,sp,-32
    8000140a:	ec06                	sd	ra,24(sp)
    8000140c:	e822                	sd	s0,16(sp)
    8000140e:	e426                	sd	s1,8(sp)
    80001410:	1000                	addi	s0,sp,32
    80001412:	84aa                	mv	s1,a0
    80001414:	862e                	mv	a2,a1
  uvmunmap(pagetable, 0, sz, 1);
    80001416:	4685                	li	a3,1
    80001418:	4581                	li	a1,0
    8000141a:	00000097          	auipc	ra,0x0
    8000141e:	d88080e7          	jalr	-632(ra) # 800011a2 <uvmunmap>
  freewalk(pagetable);
    80001422:	8526                	mv	a0,s1
    80001424:	00000097          	auipc	ra,0x0
    80001428:	ab8080e7          	jalr	-1352(ra) # 80000edc <freewalk>
}
    8000142c:	60e2                	ld	ra,24(sp)
    8000142e:	6442                	ld	s0,16(sp)
    80001430:	64a2                	ld	s1,8(sp)
    80001432:	6105                	addi	sp,sp,32
    80001434:	8082                	ret

0000000080001436 <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    80001436:	c671                	beqz	a2,80001502 <uvmcopy+0xcc>
{
    80001438:	715d                	addi	sp,sp,-80
    8000143a:	e486                	sd	ra,72(sp)
    8000143c:	e0a2                	sd	s0,64(sp)
    8000143e:	fc26                	sd	s1,56(sp)
    80001440:	f84a                	sd	s2,48(sp)
    80001442:	f44e                	sd	s3,40(sp)
    80001444:	f052                	sd	s4,32(sp)
    80001446:	ec56                	sd	s5,24(sp)
    80001448:	e85a                	sd	s6,16(sp)
    8000144a:	e45e                	sd	s7,8(sp)
    8000144c:	0880                	addi	s0,sp,80
    8000144e:	8b2a                	mv	s6,a0
    80001450:	8aae                	mv	s5,a1
    80001452:	8a32                	mv	s4,a2
  for(i = 0; i < sz; i += PGSIZE){
    80001454:	4981                	li	s3,0
    if((pte = walk(old, i, 0)) == 0)
    80001456:	4601                	li	a2,0
    80001458:	85ce                	mv	a1,s3
    8000145a:	855a                	mv	a0,s6
    8000145c:	00000097          	auipc	ra,0x0
    80001460:	9da080e7          	jalr	-1574(ra) # 80000e36 <walk>
    80001464:	c531                	beqz	a0,800014b0 <uvmcopy+0x7a>
      panic("uvmcopy: pte should exist");
    if((*pte & PTE_V) == 0)
    80001466:	6118                	ld	a4,0(a0)
    80001468:	00177793          	andi	a5,a4,1
    8000146c:	cbb1                	beqz	a5,800014c0 <uvmcopy+0x8a>
      panic("uvmcopy: page not present");
    pa = PTE2PA(*pte);
    8000146e:	00a75593          	srli	a1,a4,0xa
    80001472:	00c59b93          	slli	s7,a1,0xc
    flags = PTE_FLAGS(*pte);
    80001476:	3ff77493          	andi	s1,a4,1023
    if((mem = kalloc()) == 0)
    8000147a:	fffff097          	auipc	ra,0xfffff
    8000147e:	4e6080e7          	jalr	1254(ra) # 80000960 <kalloc>
    80001482:	892a                	mv	s2,a0
    80001484:	c939                	beqz	a0,800014da <uvmcopy+0xa4>
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    80001486:	6605                	lui	a2,0x1
    80001488:	85de                	mv	a1,s7
    8000148a:	fffff097          	auipc	ra,0xfffff
    8000148e:	744080e7          	jalr	1860(ra) # 80000bce <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    80001492:	8726                	mv	a4,s1
    80001494:	86ca                	mv	a3,s2
    80001496:	6605                	lui	a2,0x1
    80001498:	85ce                	mv	a1,s3
    8000149a:	8556                	mv	a0,s5
    8000149c:	00000097          	auipc	ra,0x0
    800014a0:	b6e080e7          	jalr	-1170(ra) # 8000100a <mappages>
    800014a4:	e515                	bnez	a0,800014d0 <uvmcopy+0x9a>
  for(i = 0; i < sz; i += PGSIZE){
    800014a6:	6785                	lui	a5,0x1
    800014a8:	99be                	add	s3,s3,a5
    800014aa:	fb49e6e3          	bltu	s3,s4,80001456 <uvmcopy+0x20>
    800014ae:	a83d                	j	800014ec <uvmcopy+0xb6>
      panic("uvmcopy: pte should exist");
    800014b0:	00006517          	auipc	a0,0x6
    800014b4:	dc850513          	addi	a0,a0,-568 # 80007278 <userret+0x1e8>
    800014b8:	fffff097          	auipc	ra,0xfffff
    800014bc:	096080e7          	jalr	150(ra) # 8000054e <panic>
      panic("uvmcopy: page not present");
    800014c0:	00006517          	auipc	a0,0x6
    800014c4:	dd850513          	addi	a0,a0,-552 # 80007298 <userret+0x208>
    800014c8:	fffff097          	auipc	ra,0xfffff
    800014cc:	086080e7          	jalr	134(ra) # 8000054e <panic>
      kfree(mem);
    800014d0:	854a                	mv	a0,s2
    800014d2:	fffff097          	auipc	ra,0xfffff
    800014d6:	392080e7          	jalr	914(ra) # 80000864 <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i, 1);
    800014da:	4685                	li	a3,1
    800014dc:	864e                	mv	a2,s3
    800014de:	4581                	li	a1,0
    800014e0:	8556                	mv	a0,s5
    800014e2:	00000097          	auipc	ra,0x0
    800014e6:	cc0080e7          	jalr	-832(ra) # 800011a2 <uvmunmap>
  return -1;
    800014ea:	557d                	li	a0,-1
}
    800014ec:	60a6                	ld	ra,72(sp)
    800014ee:	6406                	ld	s0,64(sp)
    800014f0:	74e2                	ld	s1,56(sp)
    800014f2:	7942                	ld	s2,48(sp)
    800014f4:	79a2                	ld	s3,40(sp)
    800014f6:	7a02                	ld	s4,32(sp)
    800014f8:	6ae2                	ld	s5,24(sp)
    800014fa:	6b42                	ld	s6,16(sp)
    800014fc:	6ba2                	ld	s7,8(sp)
    800014fe:	6161                	addi	sp,sp,80
    80001500:	8082                	ret
  return 0;
    80001502:	4501                	li	a0,0
}
    80001504:	8082                	ret

0000000080001506 <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    80001506:	1141                	addi	sp,sp,-16
    80001508:	e406                	sd	ra,8(sp)
    8000150a:	e022                	sd	s0,0(sp)
    8000150c:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    8000150e:	4601                	li	a2,0
    80001510:	00000097          	auipc	ra,0x0
    80001514:	926080e7          	jalr	-1754(ra) # 80000e36 <walk>
  if(pte == 0)
    80001518:	c901                	beqz	a0,80001528 <uvmclear+0x22>
    panic("uvmclear");
  *pte &= ~PTE_U;
    8000151a:	611c                	ld	a5,0(a0)
    8000151c:	9bbd                	andi	a5,a5,-17
    8000151e:	e11c                	sd	a5,0(a0)
}
    80001520:	60a2                	ld	ra,8(sp)
    80001522:	6402                	ld	s0,0(sp)
    80001524:	0141                	addi	sp,sp,16
    80001526:	8082                	ret
    panic("uvmclear");
    80001528:	00006517          	auipc	a0,0x6
    8000152c:	d9050513          	addi	a0,a0,-624 # 800072b8 <userret+0x228>
    80001530:	fffff097          	auipc	ra,0xfffff
    80001534:	01e080e7          	jalr	30(ra) # 8000054e <panic>

0000000080001538 <copyout>:
int
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    80001538:	c6bd                	beqz	a3,800015a6 <copyout+0x6e>
{
    8000153a:	715d                	addi	sp,sp,-80
    8000153c:	e486                	sd	ra,72(sp)
    8000153e:	e0a2                	sd	s0,64(sp)
    80001540:	fc26                	sd	s1,56(sp)
    80001542:	f84a                	sd	s2,48(sp)
    80001544:	f44e                	sd	s3,40(sp)
    80001546:	f052                	sd	s4,32(sp)
    80001548:	ec56                	sd	s5,24(sp)
    8000154a:	e85a                	sd	s6,16(sp)
    8000154c:	e45e                	sd	s7,8(sp)
    8000154e:	e062                	sd	s8,0(sp)
    80001550:	0880                	addi	s0,sp,80
    80001552:	8b2a                	mv	s6,a0
    80001554:	8c2e                	mv	s8,a1
    80001556:	8a32                	mv	s4,a2
    80001558:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(dstva);
    8000155a:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (dstva - va0);
    8000155c:	6a85                	lui	s5,0x1
    8000155e:	a015                	j	80001582 <copyout+0x4a>
    if(n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    80001560:	9562                	add	a0,a0,s8
    80001562:	0004861b          	sext.w	a2,s1
    80001566:	85d2                	mv	a1,s4
    80001568:	41250533          	sub	a0,a0,s2
    8000156c:	fffff097          	auipc	ra,0xfffff
    80001570:	662080e7          	jalr	1634(ra) # 80000bce <memmove>

    len -= n;
    80001574:	409989b3          	sub	s3,s3,s1
    src += n;
    80001578:	9a26                	add	s4,s4,s1
    dstva = va0 + PGSIZE;
    8000157a:	01590c33          	add	s8,s2,s5
  while(len > 0){
    8000157e:	02098263          	beqz	s3,800015a2 <copyout+0x6a>
    va0 = PGROUNDDOWN(dstva);
    80001582:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    80001586:	85ca                	mv	a1,s2
    80001588:	855a                	mv	a0,s6
    8000158a:	00000097          	auipc	ra,0x0
    8000158e:	9e0080e7          	jalr	-1568(ra) # 80000f6a <walkaddr>
    if(pa0 == 0)
    80001592:	cd01                	beqz	a0,800015aa <copyout+0x72>
    n = PGSIZE - (dstva - va0);
    80001594:	418904b3          	sub	s1,s2,s8
    80001598:	94d6                	add	s1,s1,s5
    if(n > len)
    8000159a:	fc99f3e3          	bgeu	s3,s1,80001560 <copyout+0x28>
    8000159e:	84ce                	mv	s1,s3
    800015a0:	b7c1                	j	80001560 <copyout+0x28>
  }
  return 0;
    800015a2:	4501                	li	a0,0
    800015a4:	a021                	j	800015ac <copyout+0x74>
    800015a6:	4501                	li	a0,0
}
    800015a8:	8082                	ret
      return -1;
    800015aa:	557d                	li	a0,-1
}
    800015ac:	60a6                	ld	ra,72(sp)
    800015ae:	6406                	ld	s0,64(sp)
    800015b0:	74e2                	ld	s1,56(sp)
    800015b2:	7942                	ld	s2,48(sp)
    800015b4:	79a2                	ld	s3,40(sp)
    800015b6:	7a02                	ld	s4,32(sp)
    800015b8:	6ae2                	ld	s5,24(sp)
    800015ba:	6b42                	ld	s6,16(sp)
    800015bc:	6ba2                	ld	s7,8(sp)
    800015be:	6c02                	ld	s8,0(sp)
    800015c0:	6161                	addi	sp,sp,80
    800015c2:	8082                	ret

00000000800015c4 <copyin>:
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    800015c4:	c6bd                	beqz	a3,80001632 <copyin+0x6e>
{
    800015c6:	715d                	addi	sp,sp,-80
    800015c8:	e486                	sd	ra,72(sp)
    800015ca:	e0a2                	sd	s0,64(sp)
    800015cc:	fc26                	sd	s1,56(sp)
    800015ce:	f84a                	sd	s2,48(sp)
    800015d0:	f44e                	sd	s3,40(sp)
    800015d2:	f052                	sd	s4,32(sp)
    800015d4:	ec56                	sd	s5,24(sp)
    800015d6:	e85a                	sd	s6,16(sp)
    800015d8:	e45e                	sd	s7,8(sp)
    800015da:	e062                	sd	s8,0(sp)
    800015dc:	0880                	addi	s0,sp,80
    800015de:	8b2a                	mv	s6,a0
    800015e0:	8a2e                	mv	s4,a1
    800015e2:	8c32                	mv	s8,a2
    800015e4:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    800015e6:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    800015e8:	6a85                	lui	s5,0x1
    800015ea:	a015                	j	8000160e <copyin+0x4a>
    if(n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    800015ec:	9562                	add	a0,a0,s8
    800015ee:	0004861b          	sext.w	a2,s1
    800015f2:	412505b3          	sub	a1,a0,s2
    800015f6:	8552                	mv	a0,s4
    800015f8:	fffff097          	auipc	ra,0xfffff
    800015fc:	5d6080e7          	jalr	1494(ra) # 80000bce <memmove>

    len -= n;
    80001600:	409989b3          	sub	s3,s3,s1
    dst += n;
    80001604:	9a26                	add	s4,s4,s1
    srcva = va0 + PGSIZE;
    80001606:	01590c33          	add	s8,s2,s5
  while(len > 0){
    8000160a:	02098263          	beqz	s3,8000162e <copyin+0x6a>
    va0 = PGROUNDDOWN(srcva);
    8000160e:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    80001612:	85ca                	mv	a1,s2
    80001614:	855a                	mv	a0,s6
    80001616:	00000097          	auipc	ra,0x0
    8000161a:	954080e7          	jalr	-1708(ra) # 80000f6a <walkaddr>
    if(pa0 == 0)
    8000161e:	cd01                	beqz	a0,80001636 <copyin+0x72>
    n = PGSIZE - (srcva - va0);
    80001620:	418904b3          	sub	s1,s2,s8
    80001624:	94d6                	add	s1,s1,s5
    if(n > len)
    80001626:	fc99f3e3          	bgeu	s3,s1,800015ec <copyin+0x28>
    8000162a:	84ce                	mv	s1,s3
    8000162c:	b7c1                	j	800015ec <copyin+0x28>
  }
  return 0;
    8000162e:	4501                	li	a0,0
    80001630:	a021                	j	80001638 <copyin+0x74>
    80001632:	4501                	li	a0,0
}
    80001634:	8082                	ret
      return -1;
    80001636:	557d                	li	a0,-1
}
    80001638:	60a6                	ld	ra,72(sp)
    8000163a:	6406                	ld	s0,64(sp)
    8000163c:	74e2                	ld	s1,56(sp)
    8000163e:	7942                	ld	s2,48(sp)
    80001640:	79a2                	ld	s3,40(sp)
    80001642:	7a02                	ld	s4,32(sp)
    80001644:	6ae2                	ld	s5,24(sp)
    80001646:	6b42                	ld	s6,16(sp)
    80001648:	6ba2                	ld	s7,8(sp)
    8000164a:	6c02                	ld	s8,0(sp)
    8000164c:	6161                	addi	sp,sp,80
    8000164e:	8082                	ret

0000000080001650 <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    80001650:	c6c5                	beqz	a3,800016f8 <copyinstr+0xa8>
{
    80001652:	715d                	addi	sp,sp,-80
    80001654:	e486                	sd	ra,72(sp)
    80001656:	e0a2                	sd	s0,64(sp)
    80001658:	fc26                	sd	s1,56(sp)
    8000165a:	f84a                	sd	s2,48(sp)
    8000165c:	f44e                	sd	s3,40(sp)
    8000165e:	f052                	sd	s4,32(sp)
    80001660:	ec56                	sd	s5,24(sp)
    80001662:	e85a                	sd	s6,16(sp)
    80001664:	e45e                	sd	s7,8(sp)
    80001666:	0880                	addi	s0,sp,80
    80001668:	8a2a                	mv	s4,a0
    8000166a:	8b2e                	mv	s6,a1
    8000166c:	8bb2                	mv	s7,a2
    8000166e:	84b6                	mv	s1,a3
    va0 = PGROUNDDOWN(srcva);
    80001670:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80001672:	6985                	lui	s3,0x1
    80001674:	a035                	j	800016a0 <copyinstr+0x50>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    80001676:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    8000167a:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    8000167c:	0017b793          	seqz	a5,a5
    80001680:	40f00533          	neg	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    80001684:	60a6                	ld	ra,72(sp)
    80001686:	6406                	ld	s0,64(sp)
    80001688:	74e2                	ld	s1,56(sp)
    8000168a:	7942                	ld	s2,48(sp)
    8000168c:	79a2                	ld	s3,40(sp)
    8000168e:	7a02                	ld	s4,32(sp)
    80001690:	6ae2                	ld	s5,24(sp)
    80001692:	6b42                	ld	s6,16(sp)
    80001694:	6ba2                	ld	s7,8(sp)
    80001696:	6161                	addi	sp,sp,80
    80001698:	8082                	ret
    srcva = va0 + PGSIZE;
    8000169a:	01390bb3          	add	s7,s2,s3
  while(got_null == 0 && max > 0){
    8000169e:	c8a9                	beqz	s1,800016f0 <copyinstr+0xa0>
    va0 = PGROUNDDOWN(srcva);
    800016a0:	015bf933          	and	s2,s7,s5
    pa0 = walkaddr(pagetable, va0);
    800016a4:	85ca                	mv	a1,s2
    800016a6:	8552                	mv	a0,s4
    800016a8:	00000097          	auipc	ra,0x0
    800016ac:	8c2080e7          	jalr	-1854(ra) # 80000f6a <walkaddr>
    if(pa0 == 0)
    800016b0:	c131                	beqz	a0,800016f4 <copyinstr+0xa4>
    n = PGSIZE - (srcva - va0);
    800016b2:	41790833          	sub	a6,s2,s7
    800016b6:	984e                	add	a6,a6,s3
    if(n > max)
    800016b8:	0104f363          	bgeu	s1,a6,800016be <copyinstr+0x6e>
    800016bc:	8826                	mv	a6,s1
    char *p = (char *) (pa0 + (srcva - va0));
    800016be:	955e                	add	a0,a0,s7
    800016c0:	41250533          	sub	a0,a0,s2
    while(n > 0){
    800016c4:	fc080be3          	beqz	a6,8000169a <copyinstr+0x4a>
    800016c8:	985a                	add	a6,a6,s6
    800016ca:	87da                	mv	a5,s6
      if(*p == '\0'){
    800016cc:	41650633          	sub	a2,a0,s6
    800016d0:	14fd                	addi	s1,s1,-1
    800016d2:	9b26                	add	s6,s6,s1
    800016d4:	00f60733          	add	a4,a2,a5
    800016d8:	00074703          	lbu	a4,0(a4) # fffffffffffff000 <end+0xffffffff7ffd8fe4>
    800016dc:	df49                	beqz	a4,80001676 <copyinstr+0x26>
        *dst = *p;
    800016de:	00e78023          	sb	a4,0(a5)
      --max;
    800016e2:	40fb04b3          	sub	s1,s6,a5
      dst++;
    800016e6:	0785                	addi	a5,a5,1
    while(n > 0){
    800016e8:	ff0796e3          	bne	a5,a6,800016d4 <copyinstr+0x84>
      dst++;
    800016ec:	8b42                	mv	s6,a6
    800016ee:	b775                	j	8000169a <copyinstr+0x4a>
    800016f0:	4781                	li	a5,0
    800016f2:	b769                	j	8000167c <copyinstr+0x2c>
      return -1;
    800016f4:	557d                	li	a0,-1
    800016f6:	b779                	j	80001684 <copyinstr+0x34>
  int got_null = 0;
    800016f8:	4781                	li	a5,0
  if(got_null){
    800016fa:	0017b793          	seqz	a5,a5
    800016fe:	40f00533          	neg	a0,a5
}
    80001702:	8082                	ret

0000000080001704 <wakeup1>:

// Wake up p if it is sleeping in wait(); used by exit().
// Caller must hold p->lock.
static void
wakeup1(struct proc *p)
{
    80001704:	1101                	addi	sp,sp,-32
    80001706:	ec06                	sd	ra,24(sp)
    80001708:	e822                	sd	s0,16(sp)
    8000170a:	e426                	sd	s1,8(sp)
    8000170c:	1000                	addi	s0,sp,32
    8000170e:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    80001710:	fffff097          	auipc	ra,0xfffff
    80001714:	382080e7          	jalr	898(ra) # 80000a92 <holding>
    80001718:	c909                	beqz	a0,8000172a <wakeup1+0x26>
    panic("wakeup1");
  if(p->chan == p && p->state == SLEEPING) {
    8000171a:	749c                	ld	a5,40(s1)
    8000171c:	00978f63          	beq	a5,s1,8000173a <wakeup1+0x36>
    p->state = RUNNABLE;
  }
}
    80001720:	60e2                	ld	ra,24(sp)
    80001722:	6442                	ld	s0,16(sp)
    80001724:	64a2                	ld	s1,8(sp)
    80001726:	6105                	addi	sp,sp,32
    80001728:	8082                	ret
    panic("wakeup1");
    8000172a:	00006517          	auipc	a0,0x6
    8000172e:	b9e50513          	addi	a0,a0,-1122 # 800072c8 <userret+0x238>
    80001732:	fffff097          	auipc	ra,0xfffff
    80001736:	e1c080e7          	jalr	-484(ra) # 8000054e <panic>
  if(p->chan == p && p->state == SLEEPING) {
    8000173a:	4c98                	lw	a4,24(s1)
    8000173c:	4785                	li	a5,1
    8000173e:	fef711e3          	bne	a4,a5,80001720 <wakeup1+0x1c>
    p->state = RUNNABLE;
    80001742:	4789                	li	a5,2
    80001744:	cc9c                	sw	a5,24(s1)
}
    80001746:	bfe9                	j	80001720 <wakeup1+0x1c>

0000000080001748 <procinit>:
{
    80001748:	715d                	addi	sp,sp,-80
    8000174a:	e486                	sd	ra,72(sp)
    8000174c:	e0a2                	sd	s0,64(sp)
    8000174e:	fc26                	sd	s1,56(sp)
    80001750:	f84a                	sd	s2,48(sp)
    80001752:	f44e                	sd	s3,40(sp)
    80001754:	f052                	sd	s4,32(sp)
    80001756:	ec56                	sd	s5,24(sp)
    80001758:	e85a                	sd	s6,16(sp)
    8000175a:	e45e                	sd	s7,8(sp)
    8000175c:	0880                	addi	s0,sp,80
  initlock(&pid_lock, "nextpid");
    8000175e:	00006597          	auipc	a1,0x6
    80001762:	b7258593          	addi	a1,a1,-1166 # 800072d0 <userret+0x240>
    80001766:	00010517          	auipc	a0,0x10
    8000176a:	18250513          	addi	a0,a0,386 # 800118e8 <pid_lock>
    8000176e:	fffff097          	auipc	ra,0xfffff
    80001772:	252080e7          	jalr	594(ra) # 800009c0 <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001776:	00010917          	auipc	s2,0x10
    8000177a:	58a90913          	addi	s2,s2,1418 # 80011d00 <proc>
      initlock(&p->lock, "proc");
    8000177e:	00006b97          	auipc	s7,0x6
    80001782:	b5ab8b93          	addi	s7,s7,-1190 # 800072d8 <userret+0x248>
      uint64 va = KSTACK((int) (p - proc));
    80001786:	8b4a                	mv	s6,s2
    80001788:	00006a97          	auipc	s5,0x6
    8000178c:	208a8a93          	addi	s5,s5,520 # 80007990 <syscalls+0xc0>
    80001790:	040009b7          	lui	s3,0x4000
    80001794:	19fd                	addi	s3,s3,-1
    80001796:	09b2                	slli	s3,s3,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80001798:	00016a17          	auipc	s4,0x16
    8000179c:	168a0a13          	addi	s4,s4,360 # 80017900 <tickslock>
      initlock(&p->lock, "proc");
    800017a0:	85de                	mv	a1,s7
    800017a2:	854a                	mv	a0,s2
    800017a4:	fffff097          	auipc	ra,0xfffff
    800017a8:	21c080e7          	jalr	540(ra) # 800009c0 <initlock>
      char *pa = kalloc();
    800017ac:	fffff097          	auipc	ra,0xfffff
    800017b0:	1b4080e7          	jalr	436(ra) # 80000960 <kalloc>
    800017b4:	85aa                	mv	a1,a0
      if(pa == 0)
    800017b6:	c929                	beqz	a0,80001808 <procinit+0xc0>
      uint64 va = KSTACK((int) (p - proc));
    800017b8:	416904b3          	sub	s1,s2,s6
    800017bc:	8491                	srai	s1,s1,0x4
    800017be:	000ab783          	ld	a5,0(s5)
    800017c2:	02f484b3          	mul	s1,s1,a5
    800017c6:	2485                	addiw	s1,s1,1
    800017c8:	00d4949b          	slliw	s1,s1,0xd
    800017cc:	409984b3          	sub	s1,s3,s1
      kvmmap(va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    800017d0:	4699                	li	a3,6
    800017d2:	6605                	lui	a2,0x1
    800017d4:	8526                	mv	a0,s1
    800017d6:	00000097          	auipc	ra,0x0
    800017da:	8c2080e7          	jalr	-1854(ra) # 80001098 <kvmmap>
      p->kstack = va;
    800017de:	04993023          	sd	s1,64(s2)
  for(p = proc; p < &proc[NPROC]; p++) {
    800017e2:	17090913          	addi	s2,s2,368
    800017e6:	fb491de3          	bne	s2,s4,800017a0 <procinit+0x58>
  kvminithart();
    800017ea:	fffff097          	auipc	ra,0xfffff
    800017ee:	75c080e7          	jalr	1884(ra) # 80000f46 <kvminithart>
}
    800017f2:	60a6                	ld	ra,72(sp)
    800017f4:	6406                	ld	s0,64(sp)
    800017f6:	74e2                	ld	s1,56(sp)
    800017f8:	7942                	ld	s2,48(sp)
    800017fa:	79a2                	ld	s3,40(sp)
    800017fc:	7a02                	ld	s4,32(sp)
    800017fe:	6ae2                	ld	s5,24(sp)
    80001800:	6b42                	ld	s6,16(sp)
    80001802:	6ba2                	ld	s7,8(sp)
    80001804:	6161                	addi	sp,sp,80
    80001806:	8082                	ret
        panic("kalloc");
    80001808:	00006517          	auipc	a0,0x6
    8000180c:	ad850513          	addi	a0,a0,-1320 # 800072e0 <userret+0x250>
    80001810:	fffff097          	auipc	ra,0xfffff
    80001814:	d3e080e7          	jalr	-706(ra) # 8000054e <panic>

0000000080001818 <cpuid>:
{
    80001818:	1141                	addi	sp,sp,-16
    8000181a:	e422                	sd	s0,8(sp)
    8000181c:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    8000181e:	8512                	mv	a0,tp
}
    80001820:	2501                	sext.w	a0,a0
    80001822:	6422                	ld	s0,8(sp)
    80001824:	0141                	addi	sp,sp,16
    80001826:	8082                	ret

0000000080001828 <mycpu>:
mycpu(void) {
    80001828:	1141                	addi	sp,sp,-16
    8000182a:	e422                	sd	s0,8(sp)
    8000182c:	0800                	addi	s0,sp,16
    8000182e:	8792                	mv	a5,tp
  struct cpu *c = &cpus[id];
    80001830:	2781                	sext.w	a5,a5
    80001832:	079e                	slli	a5,a5,0x7
}
    80001834:	00010517          	auipc	a0,0x10
    80001838:	0cc50513          	addi	a0,a0,204 # 80011900 <cpus>
    8000183c:	953e                	add	a0,a0,a5
    8000183e:	6422                	ld	s0,8(sp)
    80001840:	0141                	addi	sp,sp,16
    80001842:	8082                	ret

0000000080001844 <myproc>:
myproc(void) {
    80001844:	1101                	addi	sp,sp,-32
    80001846:	ec06                	sd	ra,24(sp)
    80001848:	e822                	sd	s0,16(sp)
    8000184a:	e426                	sd	s1,8(sp)
    8000184c:	1000                	addi	s0,sp,32
  push_off();
    8000184e:	fffff097          	auipc	ra,0xfffff
    80001852:	188080e7          	jalr	392(ra) # 800009d6 <push_off>
    80001856:	8792                	mv	a5,tp
  struct proc *p = c->proc;
    80001858:	2781                	sext.w	a5,a5
    8000185a:	079e                	slli	a5,a5,0x7
    8000185c:	00010717          	auipc	a4,0x10
    80001860:	08c70713          	addi	a4,a4,140 # 800118e8 <pid_lock>
    80001864:	97ba                	add	a5,a5,a4
    80001866:	6f84                	ld	s1,24(a5)
  pop_off();
    80001868:	fffff097          	auipc	ra,0xfffff
    8000186c:	1ba080e7          	jalr	442(ra) # 80000a22 <pop_off>
}
    80001870:	8526                	mv	a0,s1
    80001872:	60e2                	ld	ra,24(sp)
    80001874:	6442                	ld	s0,16(sp)
    80001876:	64a2                	ld	s1,8(sp)
    80001878:	6105                	addi	sp,sp,32
    8000187a:	8082                	ret

000000008000187c <forkret>:
{
    8000187c:	1141                	addi	sp,sp,-16
    8000187e:	e406                	sd	ra,8(sp)
    80001880:	e022                	sd	s0,0(sp)
    80001882:	0800                	addi	s0,sp,16
  release(&myproc()->lock);
    80001884:	00000097          	auipc	ra,0x0
    80001888:	fc0080e7          	jalr	-64(ra) # 80001844 <myproc>
    8000188c:	fffff097          	auipc	ra,0xfffff
    80001890:	29a080e7          	jalr	666(ra) # 80000b26 <release>
  if (first) {
    80001894:	00006797          	auipc	a5,0x6
    80001898:	7a07a783          	lw	a5,1952(a5) # 80008034 <first.1665>
    8000189c:	eb89                	bnez	a5,800018ae <forkret+0x32>
  usertrapret();
    8000189e:	00001097          	auipc	ra,0x1
    800018a2:	c54080e7          	jalr	-940(ra) # 800024f2 <usertrapret>
}
    800018a6:	60a2                	ld	ra,8(sp)
    800018a8:	6402                	ld	s0,0(sp)
    800018aa:	0141                	addi	sp,sp,16
    800018ac:	8082                	ret
    first = 0;
    800018ae:	00006797          	auipc	a5,0x6
    800018b2:	7807a323          	sw	zero,1926(a5) # 80008034 <first.1665>
    fsinit(ROOTDEV);
    800018b6:	4505                	li	a0,1
    800018b8:	00002097          	auipc	ra,0x2
    800018bc:	a1a080e7          	jalr	-1510(ra) # 800032d2 <fsinit>
    800018c0:	bff9                	j	8000189e <forkret+0x22>

00000000800018c2 <allocpid>:
allocpid() {
    800018c2:	1101                	addi	sp,sp,-32
    800018c4:	ec06                	sd	ra,24(sp)
    800018c6:	e822                	sd	s0,16(sp)
    800018c8:	e426                	sd	s1,8(sp)
    800018ca:	e04a                	sd	s2,0(sp)
    800018cc:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    800018ce:	00010917          	auipc	s2,0x10
    800018d2:	01a90913          	addi	s2,s2,26 # 800118e8 <pid_lock>
    800018d6:	854a                	mv	a0,s2
    800018d8:	fffff097          	auipc	ra,0xfffff
    800018dc:	1fa080e7          	jalr	506(ra) # 80000ad2 <acquire>
  pid = nextpid;
    800018e0:	00006797          	auipc	a5,0x6
    800018e4:	75878793          	addi	a5,a5,1880 # 80008038 <nextpid>
    800018e8:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    800018ea:	0014871b          	addiw	a4,s1,1
    800018ee:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    800018f0:	854a                	mv	a0,s2
    800018f2:	fffff097          	auipc	ra,0xfffff
    800018f6:	234080e7          	jalr	564(ra) # 80000b26 <release>
}
    800018fa:	8526                	mv	a0,s1
    800018fc:	60e2                	ld	ra,24(sp)
    800018fe:	6442                	ld	s0,16(sp)
    80001900:	64a2                	ld	s1,8(sp)
    80001902:	6902                	ld	s2,0(sp)
    80001904:	6105                	addi	sp,sp,32
    80001906:	8082                	ret

0000000080001908 <proc_pagetable>:
{
    80001908:	1101                	addi	sp,sp,-32
    8000190a:	ec06                	sd	ra,24(sp)
    8000190c:	e822                	sd	s0,16(sp)
    8000190e:	e426                	sd	s1,8(sp)
    80001910:	e04a                	sd	s2,0(sp)
    80001912:	1000                	addi	s0,sp,32
    80001914:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001916:	00000097          	auipc	ra,0x0
    8000191a:	954080e7          	jalr	-1708(ra) # 8000126a <uvmcreate>
    8000191e:	84aa                	mv	s1,a0
  mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001920:	4729                	li	a4,10
    80001922:	00005697          	auipc	a3,0x5
    80001926:	6de68693          	addi	a3,a3,1758 # 80007000 <trampoline>
    8000192a:	6605                	lui	a2,0x1
    8000192c:	040005b7          	lui	a1,0x4000
    80001930:	15fd                	addi	a1,a1,-1
    80001932:	05b2                	slli	a1,a1,0xc
    80001934:	fffff097          	auipc	ra,0xfffff
    80001938:	6d6080e7          	jalr	1750(ra) # 8000100a <mappages>
  mappages(pagetable, TRAPFRAME, PGSIZE,
    8000193c:	4719                	li	a4,6
    8000193e:	05893683          	ld	a3,88(s2)
    80001942:	6605                	lui	a2,0x1
    80001944:	020005b7          	lui	a1,0x2000
    80001948:	15fd                	addi	a1,a1,-1
    8000194a:	05b6                	slli	a1,a1,0xd
    8000194c:	8526                	mv	a0,s1
    8000194e:	fffff097          	auipc	ra,0xfffff
    80001952:	6bc080e7          	jalr	1724(ra) # 8000100a <mappages>
}
    80001956:	8526                	mv	a0,s1
    80001958:	60e2                	ld	ra,24(sp)
    8000195a:	6442                	ld	s0,16(sp)
    8000195c:	64a2                	ld	s1,8(sp)
    8000195e:	6902                	ld	s2,0(sp)
    80001960:	6105                	addi	sp,sp,32
    80001962:	8082                	ret

0000000080001964 <allocproc>:
{
    80001964:	1101                	addi	sp,sp,-32
    80001966:	ec06                	sd	ra,24(sp)
    80001968:	e822                	sd	s0,16(sp)
    8000196a:	e426                	sd	s1,8(sp)
    8000196c:	e04a                	sd	s2,0(sp)
    8000196e:	1000                	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    80001970:	00010497          	auipc	s1,0x10
    80001974:	39048493          	addi	s1,s1,912 # 80011d00 <proc>
    80001978:	00016917          	auipc	s2,0x16
    8000197c:	f8890913          	addi	s2,s2,-120 # 80017900 <tickslock>
    acquire(&p->lock);
    80001980:	8526                	mv	a0,s1
    80001982:	fffff097          	auipc	ra,0xfffff
    80001986:	150080e7          	jalr	336(ra) # 80000ad2 <acquire>
    if(p->state == UNUSED) {
    8000198a:	4c9c                	lw	a5,24(s1)
    8000198c:	cf81                	beqz	a5,800019a4 <allocproc+0x40>
      release(&p->lock);
    8000198e:	8526                	mv	a0,s1
    80001990:	fffff097          	auipc	ra,0xfffff
    80001994:	196080e7          	jalr	406(ra) # 80000b26 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001998:	17048493          	addi	s1,s1,368
    8000199c:	ff2492e3          	bne	s1,s2,80001980 <allocproc+0x1c>
  return 0;
    800019a0:	4481                	li	s1,0
    800019a2:	a0b9                	j	800019f0 <allocproc+0x8c>
  p->pid = allocpid();
    800019a4:	00000097          	auipc	ra,0x0
    800019a8:	f1e080e7          	jalr	-226(ra) # 800018c2 <allocpid>
    800019ac:	dc88                	sw	a0,56(s1)
  if((p->tf = (struct trapframe *)kalloc()) == 0){
    800019ae:	fffff097          	auipc	ra,0xfffff
    800019b2:	fb2080e7          	jalr	-78(ra) # 80000960 <kalloc>
    800019b6:	892a                	mv	s2,a0
    800019b8:	eca8                	sd	a0,88(s1)
    800019ba:	c131                	beqz	a0,800019fe <allocproc+0x9a>
  p->pagetable = proc_pagetable(p);
    800019bc:	8526                	mv	a0,s1
    800019be:	00000097          	auipc	ra,0x0
    800019c2:	f4a080e7          	jalr	-182(ra) # 80001908 <proc_pagetable>
    800019c6:	e8a8                	sd	a0,80(s1)
  memset(&p->context, 0, sizeof p->context);
    800019c8:	07000613          	li	a2,112
    800019cc:	4581                	li	a1,0
    800019ce:	06048513          	addi	a0,s1,96
    800019d2:	fffff097          	auipc	ra,0xfffff
    800019d6:	19c080e7          	jalr	412(ra) # 80000b6e <memset>
  p->context.ra = (uint64)forkret;
    800019da:	00000797          	auipc	a5,0x0
    800019de:	ea278793          	addi	a5,a5,-350 # 8000187c <forkret>
    800019e2:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    800019e4:	60bc                	ld	a5,64(s1)
    800019e6:	6705                	lui	a4,0x1
    800019e8:	97ba                	add	a5,a5,a4
    800019ea:	f4bc                	sd	a5,104(s1)
  p->tracing = 0;
    800019ec:	1604a423          	sw	zero,360(s1)
}
    800019f0:	8526                	mv	a0,s1
    800019f2:	60e2                	ld	ra,24(sp)
    800019f4:	6442                	ld	s0,16(sp)
    800019f6:	64a2                	ld	s1,8(sp)
    800019f8:	6902                	ld	s2,0(sp)
    800019fa:	6105                	addi	sp,sp,32
    800019fc:	8082                	ret
    release(&p->lock);
    800019fe:	8526                	mv	a0,s1
    80001a00:	fffff097          	auipc	ra,0xfffff
    80001a04:	126080e7          	jalr	294(ra) # 80000b26 <release>
    return 0;
    80001a08:	84ca                	mv	s1,s2
    80001a0a:	b7dd                	j	800019f0 <allocproc+0x8c>

0000000080001a0c <proc_freepagetable>:
{
    80001a0c:	1101                	addi	sp,sp,-32
    80001a0e:	ec06                	sd	ra,24(sp)
    80001a10:	e822                	sd	s0,16(sp)
    80001a12:	e426                	sd	s1,8(sp)
    80001a14:	e04a                	sd	s2,0(sp)
    80001a16:	1000                	addi	s0,sp,32
    80001a18:	84aa                	mv	s1,a0
    80001a1a:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, PGSIZE, 0);
    80001a1c:	4681                	li	a3,0
    80001a1e:	6605                	lui	a2,0x1
    80001a20:	040005b7          	lui	a1,0x4000
    80001a24:	15fd                	addi	a1,a1,-1
    80001a26:	05b2                	slli	a1,a1,0xc
    80001a28:	fffff097          	auipc	ra,0xfffff
    80001a2c:	77a080e7          	jalr	1914(ra) # 800011a2 <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, PGSIZE, 0);
    80001a30:	4681                	li	a3,0
    80001a32:	6605                	lui	a2,0x1
    80001a34:	020005b7          	lui	a1,0x2000
    80001a38:	15fd                	addi	a1,a1,-1
    80001a3a:	05b6                	slli	a1,a1,0xd
    80001a3c:	8526                	mv	a0,s1
    80001a3e:	fffff097          	auipc	ra,0xfffff
    80001a42:	764080e7          	jalr	1892(ra) # 800011a2 <uvmunmap>
  if(sz > 0)
    80001a46:	00091863          	bnez	s2,80001a56 <proc_freepagetable+0x4a>
}
    80001a4a:	60e2                	ld	ra,24(sp)
    80001a4c:	6442                	ld	s0,16(sp)
    80001a4e:	64a2                	ld	s1,8(sp)
    80001a50:	6902                	ld	s2,0(sp)
    80001a52:	6105                	addi	sp,sp,32
    80001a54:	8082                	ret
    uvmfree(pagetable, sz);
    80001a56:	85ca                	mv	a1,s2
    80001a58:	8526                	mv	a0,s1
    80001a5a:	00000097          	auipc	ra,0x0
    80001a5e:	9ae080e7          	jalr	-1618(ra) # 80001408 <uvmfree>
}
    80001a62:	b7e5                	j	80001a4a <proc_freepagetable+0x3e>

0000000080001a64 <freeproc>:
{
    80001a64:	1101                	addi	sp,sp,-32
    80001a66:	ec06                	sd	ra,24(sp)
    80001a68:	e822                	sd	s0,16(sp)
    80001a6a:	e426                	sd	s1,8(sp)
    80001a6c:	1000                	addi	s0,sp,32
    80001a6e:	84aa                	mv	s1,a0
  if(p->tf)
    80001a70:	6d28                	ld	a0,88(a0)
    80001a72:	c509                	beqz	a0,80001a7c <freeproc+0x18>
    kfree((void*)p->tf);
    80001a74:	fffff097          	auipc	ra,0xfffff
    80001a78:	df0080e7          	jalr	-528(ra) # 80000864 <kfree>
  p->tf = 0;
    80001a7c:	0404bc23          	sd	zero,88(s1)
  if(p->pagetable)
    80001a80:	68a8                	ld	a0,80(s1)
    80001a82:	c511                	beqz	a0,80001a8e <freeproc+0x2a>
    proc_freepagetable(p->pagetable, p->sz);
    80001a84:	64ac                	ld	a1,72(s1)
    80001a86:	00000097          	auipc	ra,0x0
    80001a8a:	f86080e7          	jalr	-122(ra) # 80001a0c <proc_freepagetable>
  p->pagetable = 0;
    80001a8e:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80001a92:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80001a96:	0204ac23          	sw	zero,56(s1)
  p->parent = 0;
    80001a9a:	0204b023          	sd	zero,32(s1)
  p->name[0] = 0;
    80001a9e:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80001aa2:	0204b423          	sd	zero,40(s1)
  p->killed = 0;
    80001aa6:	0204a823          	sw	zero,48(s1)
  p->xstate = 0;
    80001aaa:	0204aa23          	sw	zero,52(s1)
  p->state = UNUSED;
    80001aae:	0004ac23          	sw	zero,24(s1)
}
    80001ab2:	60e2                	ld	ra,24(sp)
    80001ab4:	6442                	ld	s0,16(sp)
    80001ab6:	64a2                	ld	s1,8(sp)
    80001ab8:	6105                	addi	sp,sp,32
    80001aba:	8082                	ret

0000000080001abc <userinit>:
{
    80001abc:	1101                	addi	sp,sp,-32
    80001abe:	ec06                	sd	ra,24(sp)
    80001ac0:	e822                	sd	s0,16(sp)
    80001ac2:	e426                	sd	s1,8(sp)
    80001ac4:	1000                	addi	s0,sp,32
  p = allocproc();
    80001ac6:	00000097          	auipc	ra,0x0
    80001aca:	e9e080e7          	jalr	-354(ra) # 80001964 <allocproc>
    80001ace:	84aa                	mv	s1,a0
  initproc = p;
    80001ad0:	00024797          	auipc	a5,0x24
    80001ad4:	54a7b023          	sd	a0,1344(a5) # 80026010 <initproc>
  uvminit(p->pagetable, initcode, sizeof(initcode));
    80001ad8:	03300613          	li	a2,51
    80001adc:	00006597          	auipc	a1,0x6
    80001ae0:	52458593          	addi	a1,a1,1316 # 80008000 <initcode>
    80001ae4:	6928                	ld	a0,80(a0)
    80001ae6:	fffff097          	auipc	ra,0xfffff
    80001aea:	7c2080e7          	jalr	1986(ra) # 800012a8 <uvminit>
  p->sz = PGSIZE;
    80001aee:	6785                	lui	a5,0x1
    80001af0:	e4bc                	sd	a5,72(s1)
  p->tf->epc = 0;      // user program counter
    80001af2:	6cb8                	ld	a4,88(s1)
    80001af4:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->tf->sp = PGSIZE;  // user stack pointer
    80001af8:	6cb8                	ld	a4,88(s1)
    80001afa:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80001afc:	4641                	li	a2,16
    80001afe:	00005597          	auipc	a1,0x5
    80001b02:	7ea58593          	addi	a1,a1,2026 # 800072e8 <userret+0x258>
    80001b06:	15848513          	addi	a0,s1,344
    80001b0a:	fffff097          	auipc	ra,0xfffff
    80001b0e:	1ba080e7          	jalr	442(ra) # 80000cc4 <safestrcpy>
  p->cwd = namei("/");
    80001b12:	00005517          	auipc	a0,0x5
    80001b16:	7e650513          	addi	a0,a0,2022 # 800072f8 <userret+0x268>
    80001b1a:	00002097          	auipc	ra,0x2
    80001b1e:	1ba080e7          	jalr	442(ra) # 80003cd4 <namei>
    80001b22:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001b26:	4789                	li	a5,2
    80001b28:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001b2a:	8526                	mv	a0,s1
    80001b2c:	fffff097          	auipc	ra,0xfffff
    80001b30:	ffa080e7          	jalr	-6(ra) # 80000b26 <release>
}
    80001b34:	60e2                	ld	ra,24(sp)
    80001b36:	6442                	ld	s0,16(sp)
    80001b38:	64a2                	ld	s1,8(sp)
    80001b3a:	6105                	addi	sp,sp,32
    80001b3c:	8082                	ret

0000000080001b3e <growproc>:
{
    80001b3e:	1101                	addi	sp,sp,-32
    80001b40:	ec06                	sd	ra,24(sp)
    80001b42:	e822                	sd	s0,16(sp)
    80001b44:	e426                	sd	s1,8(sp)
    80001b46:	e04a                	sd	s2,0(sp)
    80001b48:	1000                	addi	s0,sp,32
    80001b4a:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80001b4c:	00000097          	auipc	ra,0x0
    80001b50:	cf8080e7          	jalr	-776(ra) # 80001844 <myproc>
    80001b54:	892a                	mv	s2,a0
  sz = p->sz;
    80001b56:	652c                	ld	a1,72(a0)
    80001b58:	0005861b          	sext.w	a2,a1
  if(n > 0){
    80001b5c:	00904f63          	bgtz	s1,80001b7a <growproc+0x3c>
  } else if(n < 0){
    80001b60:	0204cc63          	bltz	s1,80001b98 <growproc+0x5a>
  p->sz = sz;
    80001b64:	1602                	slli	a2,a2,0x20
    80001b66:	9201                	srli	a2,a2,0x20
    80001b68:	04c93423          	sd	a2,72(s2)
  return 0;
    80001b6c:	4501                	li	a0,0
}
    80001b6e:	60e2                	ld	ra,24(sp)
    80001b70:	6442                	ld	s0,16(sp)
    80001b72:	64a2                	ld	s1,8(sp)
    80001b74:	6902                	ld	s2,0(sp)
    80001b76:	6105                	addi	sp,sp,32
    80001b78:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n)) == 0) {
    80001b7a:	9e25                	addw	a2,a2,s1
    80001b7c:	1602                	slli	a2,a2,0x20
    80001b7e:	9201                	srli	a2,a2,0x20
    80001b80:	1582                	slli	a1,a1,0x20
    80001b82:	9181                	srli	a1,a1,0x20
    80001b84:	6928                	ld	a0,80(a0)
    80001b86:	fffff097          	auipc	ra,0xfffff
    80001b8a:	7d8080e7          	jalr	2008(ra) # 8000135e <uvmalloc>
    80001b8e:	0005061b          	sext.w	a2,a0
    80001b92:	fa69                	bnez	a2,80001b64 <growproc+0x26>
      return -1;
    80001b94:	557d                	li	a0,-1
    80001b96:	bfe1                	j	80001b6e <growproc+0x30>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001b98:	9e25                	addw	a2,a2,s1
    80001b9a:	1602                	slli	a2,a2,0x20
    80001b9c:	9201                	srli	a2,a2,0x20
    80001b9e:	1582                	slli	a1,a1,0x20
    80001ba0:	9181                	srli	a1,a1,0x20
    80001ba2:	6928                	ld	a0,80(a0)
    80001ba4:	fffff097          	auipc	ra,0xfffff
    80001ba8:	776080e7          	jalr	1910(ra) # 8000131a <uvmdealloc>
    80001bac:	0005061b          	sext.w	a2,a0
    80001bb0:	bf55                	j	80001b64 <growproc+0x26>

0000000080001bb2 <fork>:
{
    80001bb2:	7179                	addi	sp,sp,-48
    80001bb4:	f406                	sd	ra,40(sp)
    80001bb6:	f022                	sd	s0,32(sp)
    80001bb8:	ec26                	sd	s1,24(sp)
    80001bba:	e84a                	sd	s2,16(sp)
    80001bbc:	e44e                	sd	s3,8(sp)
    80001bbe:	e052                	sd	s4,0(sp)
    80001bc0:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80001bc2:	00000097          	auipc	ra,0x0
    80001bc6:	c82080e7          	jalr	-894(ra) # 80001844 <myproc>
    80001bca:	892a                	mv	s2,a0
  if((np = allocproc()) == 0){
    80001bcc:	00000097          	auipc	ra,0x0
    80001bd0:	d98080e7          	jalr	-616(ra) # 80001964 <allocproc>
    80001bd4:	c175                	beqz	a0,80001cb8 <fork+0x106>
    80001bd6:	89aa                	mv	s3,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80001bd8:	04893603          	ld	a2,72(s2)
    80001bdc:	692c                	ld	a1,80(a0)
    80001bde:	05093503          	ld	a0,80(s2)
    80001be2:	00000097          	auipc	ra,0x0
    80001be6:	854080e7          	jalr	-1964(ra) # 80001436 <uvmcopy>
    80001bea:	04054863          	bltz	a0,80001c3a <fork+0x88>
  np->sz = p->sz;
    80001bee:	04893783          	ld	a5,72(s2)
    80001bf2:	04f9b423          	sd	a5,72(s3) # 4000048 <_entry-0x7bffffb8>
  np->parent = p;
    80001bf6:	0329b023          	sd	s2,32(s3)
  *(np->tf) = *(p->tf);
    80001bfa:	05893683          	ld	a3,88(s2)
    80001bfe:	87b6                	mv	a5,a3
    80001c00:	0589b703          	ld	a4,88(s3)
    80001c04:	12068693          	addi	a3,a3,288
    80001c08:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    80001c0c:	6788                	ld	a0,8(a5)
    80001c0e:	6b8c                	ld	a1,16(a5)
    80001c10:	6f90                	ld	a2,24(a5)
    80001c12:	01073023          	sd	a6,0(a4)
    80001c16:	e708                	sd	a0,8(a4)
    80001c18:	eb0c                	sd	a1,16(a4)
    80001c1a:	ef10                	sd	a2,24(a4)
    80001c1c:	02078793          	addi	a5,a5,32
    80001c20:	02070713          	addi	a4,a4,32
    80001c24:	fed792e3          	bne	a5,a3,80001c08 <fork+0x56>
  np->tf->a0 = 0;
    80001c28:	0589b783          	ld	a5,88(s3)
    80001c2c:	0607b823          	sd	zero,112(a5)
    80001c30:	0d000493          	li	s1,208
  for(i = 0; i < NOFILE; i++)
    80001c34:	15000a13          	li	s4,336
    80001c38:	a03d                	j	80001c66 <fork+0xb4>
    freeproc(np);
    80001c3a:	854e                	mv	a0,s3
    80001c3c:	00000097          	auipc	ra,0x0
    80001c40:	e28080e7          	jalr	-472(ra) # 80001a64 <freeproc>
    release(&np->lock);
    80001c44:	854e                	mv	a0,s3
    80001c46:	fffff097          	auipc	ra,0xfffff
    80001c4a:	ee0080e7          	jalr	-288(ra) # 80000b26 <release>
    return -1;
    80001c4e:	54fd                	li	s1,-1
    80001c50:	a899                	j	80001ca6 <fork+0xf4>
      np->ofile[i] = filedup(p->ofile[i]);
    80001c52:	00002097          	auipc	ra,0x2
    80001c56:	70e080e7          	jalr	1806(ra) # 80004360 <filedup>
    80001c5a:	009987b3          	add	a5,s3,s1
    80001c5e:	e388                	sd	a0,0(a5)
  for(i = 0; i < NOFILE; i++)
    80001c60:	04a1                	addi	s1,s1,8
    80001c62:	01448763          	beq	s1,s4,80001c70 <fork+0xbe>
    if(p->ofile[i])
    80001c66:	009907b3          	add	a5,s2,s1
    80001c6a:	6388                	ld	a0,0(a5)
    80001c6c:	f17d                	bnez	a0,80001c52 <fork+0xa0>
    80001c6e:	bfcd                	j	80001c60 <fork+0xae>
  np->cwd = idup(p->cwd);
    80001c70:	15093503          	ld	a0,336(s2)
    80001c74:	00002097          	auipc	ra,0x2
    80001c78:	898080e7          	jalr	-1896(ra) # 8000350c <idup>
    80001c7c:	14a9b823          	sd	a0,336(s3)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001c80:	4641                	li	a2,16
    80001c82:	15890593          	addi	a1,s2,344
    80001c86:	15898513          	addi	a0,s3,344
    80001c8a:	fffff097          	auipc	ra,0xfffff
    80001c8e:	03a080e7          	jalr	58(ra) # 80000cc4 <safestrcpy>
  pid = np->pid;
    80001c92:	0389a483          	lw	s1,56(s3)
  np->state = RUNNABLE;
    80001c96:	4789                	li	a5,2
    80001c98:	00f9ac23          	sw	a5,24(s3)
  release(&np->lock);
    80001c9c:	854e                	mv	a0,s3
    80001c9e:	fffff097          	auipc	ra,0xfffff
    80001ca2:	e88080e7          	jalr	-376(ra) # 80000b26 <release>
}
    80001ca6:	8526                	mv	a0,s1
    80001ca8:	70a2                	ld	ra,40(sp)
    80001caa:	7402                	ld	s0,32(sp)
    80001cac:	64e2                	ld	s1,24(sp)
    80001cae:	6942                	ld	s2,16(sp)
    80001cb0:	69a2                	ld	s3,8(sp)
    80001cb2:	6a02                	ld	s4,0(sp)
    80001cb4:	6145                	addi	sp,sp,48
    80001cb6:	8082                	ret
    return -1;
    80001cb8:	54fd                	li	s1,-1
    80001cba:	b7f5                	j	80001ca6 <fork+0xf4>

0000000080001cbc <reparent>:
{
    80001cbc:	7179                	addi	sp,sp,-48
    80001cbe:	f406                	sd	ra,40(sp)
    80001cc0:	f022                	sd	s0,32(sp)
    80001cc2:	ec26                	sd	s1,24(sp)
    80001cc4:	e84a                	sd	s2,16(sp)
    80001cc6:	e44e                	sd	s3,8(sp)
    80001cc8:	e052                	sd	s4,0(sp)
    80001cca:	1800                	addi	s0,sp,48
    80001ccc:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80001cce:	00010497          	auipc	s1,0x10
    80001cd2:	03248493          	addi	s1,s1,50 # 80011d00 <proc>
      pp->parent = initproc;
    80001cd6:	00024a17          	auipc	s4,0x24
    80001cda:	33aa0a13          	addi	s4,s4,826 # 80026010 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80001cde:	00016997          	auipc	s3,0x16
    80001ce2:	c2298993          	addi	s3,s3,-990 # 80017900 <tickslock>
    80001ce6:	a029                	j	80001cf0 <reparent+0x34>
    80001ce8:	17048493          	addi	s1,s1,368
    80001cec:	03348363          	beq	s1,s3,80001d12 <reparent+0x56>
    if(pp->parent == p){
    80001cf0:	709c                	ld	a5,32(s1)
    80001cf2:	ff279be3          	bne	a5,s2,80001ce8 <reparent+0x2c>
      acquire(&pp->lock);
    80001cf6:	8526                	mv	a0,s1
    80001cf8:	fffff097          	auipc	ra,0xfffff
    80001cfc:	dda080e7          	jalr	-550(ra) # 80000ad2 <acquire>
      pp->parent = initproc;
    80001d00:	000a3783          	ld	a5,0(s4)
    80001d04:	f09c                	sd	a5,32(s1)
      release(&pp->lock);
    80001d06:	8526                	mv	a0,s1
    80001d08:	fffff097          	auipc	ra,0xfffff
    80001d0c:	e1e080e7          	jalr	-482(ra) # 80000b26 <release>
    80001d10:	bfe1                	j	80001ce8 <reparent+0x2c>
}
    80001d12:	70a2                	ld	ra,40(sp)
    80001d14:	7402                	ld	s0,32(sp)
    80001d16:	64e2                	ld	s1,24(sp)
    80001d18:	6942                	ld	s2,16(sp)
    80001d1a:	69a2                	ld	s3,8(sp)
    80001d1c:	6a02                	ld	s4,0(sp)
    80001d1e:	6145                	addi	sp,sp,48
    80001d20:	8082                	ret

0000000080001d22 <scheduler>:
{
    80001d22:	7139                	addi	sp,sp,-64
    80001d24:	fc06                	sd	ra,56(sp)
    80001d26:	f822                	sd	s0,48(sp)
    80001d28:	f426                	sd	s1,40(sp)
    80001d2a:	f04a                	sd	s2,32(sp)
    80001d2c:	ec4e                	sd	s3,24(sp)
    80001d2e:	e852                	sd	s4,16(sp)
    80001d30:	e456                	sd	s5,8(sp)
    80001d32:	e05a                	sd	s6,0(sp)
    80001d34:	0080                	addi	s0,sp,64
    80001d36:	8792                	mv	a5,tp
  int id = r_tp();
    80001d38:	2781                	sext.w	a5,a5
  c->proc = 0;
    80001d3a:	00779a93          	slli	s5,a5,0x7
    80001d3e:	00010717          	auipc	a4,0x10
    80001d42:	baa70713          	addi	a4,a4,-1110 # 800118e8 <pid_lock>
    80001d46:	9756                	add	a4,a4,s5
    80001d48:	00073c23          	sd	zero,24(a4)
        swtch(&c->scheduler, &p->context);
    80001d4c:	00010717          	auipc	a4,0x10
    80001d50:	bbc70713          	addi	a4,a4,-1092 # 80011908 <cpus+0x8>
    80001d54:	9aba                	add	s5,s5,a4
      if(p->state == RUNNABLE) {
    80001d56:	4989                	li	s3,2
        p->state = RUNNING;
    80001d58:	4b0d                	li	s6,3
        c->proc = p;
    80001d5a:	079e                	slli	a5,a5,0x7
    80001d5c:	00010a17          	auipc	s4,0x10
    80001d60:	b8ca0a13          	addi	s4,s4,-1140 # 800118e8 <pid_lock>
    80001d64:	9a3e                	add	s4,s4,a5
    for(p = proc; p < &proc[NPROC]; p++) {
    80001d66:	00016917          	auipc	s2,0x16
    80001d6a:	b9a90913          	addi	s2,s2,-1126 # 80017900 <tickslock>
  asm volatile("csrr %0, sie" : "=r" (x) );
    80001d6e:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE);
    80001d72:	2227e793          	ori	a5,a5,546
  asm volatile("csrw sie, %0" : : "r" (x));
    80001d76:	10479073          	csrw	sie,a5
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001d7a:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001d7e:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001d82:	10079073          	csrw	sstatus,a5
    80001d86:	00010497          	auipc	s1,0x10
    80001d8a:	f7a48493          	addi	s1,s1,-134 # 80011d00 <proc>
    80001d8e:	a03d                	j	80001dbc <scheduler+0x9a>
        p->state = RUNNING;
    80001d90:	0164ac23          	sw	s6,24(s1)
        c->proc = p;
    80001d94:	009a3c23          	sd	s1,24(s4)
        swtch(&c->scheduler, &p->context);
    80001d98:	06048593          	addi	a1,s1,96
    80001d9c:	8556                	mv	a0,s5
    80001d9e:	00000097          	auipc	ra,0x0
    80001da2:	6aa080e7          	jalr	1706(ra) # 80002448 <swtch>
        c->proc = 0;
    80001da6:	000a3c23          	sd	zero,24(s4)
      release(&p->lock);
    80001daa:	8526                	mv	a0,s1
    80001dac:	fffff097          	auipc	ra,0xfffff
    80001db0:	d7a080e7          	jalr	-646(ra) # 80000b26 <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    80001db4:	17048493          	addi	s1,s1,368
    80001db8:	fb248be3          	beq	s1,s2,80001d6e <scheduler+0x4c>
      acquire(&p->lock);
    80001dbc:	8526                	mv	a0,s1
    80001dbe:	fffff097          	auipc	ra,0xfffff
    80001dc2:	d14080e7          	jalr	-748(ra) # 80000ad2 <acquire>
      if(p->state == RUNNABLE) {
    80001dc6:	4c9c                	lw	a5,24(s1)
    80001dc8:	ff3791e3          	bne	a5,s3,80001daa <scheduler+0x88>
    80001dcc:	b7d1                	j	80001d90 <scheduler+0x6e>

0000000080001dce <sched>:
{
    80001dce:	7179                	addi	sp,sp,-48
    80001dd0:	f406                	sd	ra,40(sp)
    80001dd2:	f022                	sd	s0,32(sp)
    80001dd4:	ec26                	sd	s1,24(sp)
    80001dd6:	e84a                	sd	s2,16(sp)
    80001dd8:	e44e                	sd	s3,8(sp)
    80001dda:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80001ddc:	00000097          	auipc	ra,0x0
    80001de0:	a68080e7          	jalr	-1432(ra) # 80001844 <myproc>
    80001de4:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    80001de6:	fffff097          	auipc	ra,0xfffff
    80001dea:	cac080e7          	jalr	-852(ra) # 80000a92 <holding>
    80001dee:	c93d                	beqz	a0,80001e64 <sched+0x96>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001df0:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    80001df2:	2781                	sext.w	a5,a5
    80001df4:	079e                	slli	a5,a5,0x7
    80001df6:	00010717          	auipc	a4,0x10
    80001dfa:	af270713          	addi	a4,a4,-1294 # 800118e8 <pid_lock>
    80001dfe:	97ba                	add	a5,a5,a4
    80001e00:	0907a703          	lw	a4,144(a5)
    80001e04:	4785                	li	a5,1
    80001e06:	06f71763          	bne	a4,a5,80001e74 <sched+0xa6>
  if(p->state == RUNNING)
    80001e0a:	4c98                	lw	a4,24(s1)
    80001e0c:	478d                	li	a5,3
    80001e0e:	06f70b63          	beq	a4,a5,80001e84 <sched+0xb6>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001e12:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80001e16:	8b89                	andi	a5,a5,2
  if(intr_get())
    80001e18:	efb5                	bnez	a5,80001e94 <sched+0xc6>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001e1a:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80001e1c:	00010917          	auipc	s2,0x10
    80001e20:	acc90913          	addi	s2,s2,-1332 # 800118e8 <pid_lock>
    80001e24:	2781                	sext.w	a5,a5
    80001e26:	079e                	slli	a5,a5,0x7
    80001e28:	97ca                	add	a5,a5,s2
    80001e2a:	0947a983          	lw	s3,148(a5)
    80001e2e:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->scheduler);
    80001e30:	2781                	sext.w	a5,a5
    80001e32:	079e                	slli	a5,a5,0x7
    80001e34:	00010597          	auipc	a1,0x10
    80001e38:	ad458593          	addi	a1,a1,-1324 # 80011908 <cpus+0x8>
    80001e3c:	95be                	add	a1,a1,a5
    80001e3e:	06048513          	addi	a0,s1,96
    80001e42:	00000097          	auipc	ra,0x0
    80001e46:	606080e7          	jalr	1542(ra) # 80002448 <swtch>
    80001e4a:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80001e4c:	2781                	sext.w	a5,a5
    80001e4e:	079e                	slli	a5,a5,0x7
    80001e50:	97ca                	add	a5,a5,s2
    80001e52:	0937aa23          	sw	s3,148(a5)
}
    80001e56:	70a2                	ld	ra,40(sp)
    80001e58:	7402                	ld	s0,32(sp)
    80001e5a:	64e2                	ld	s1,24(sp)
    80001e5c:	6942                	ld	s2,16(sp)
    80001e5e:	69a2                	ld	s3,8(sp)
    80001e60:	6145                	addi	sp,sp,48
    80001e62:	8082                	ret
    panic("sched p->lock");
    80001e64:	00005517          	auipc	a0,0x5
    80001e68:	49c50513          	addi	a0,a0,1180 # 80007300 <userret+0x270>
    80001e6c:	ffffe097          	auipc	ra,0xffffe
    80001e70:	6e2080e7          	jalr	1762(ra) # 8000054e <panic>
    panic("sched locks");
    80001e74:	00005517          	auipc	a0,0x5
    80001e78:	49c50513          	addi	a0,a0,1180 # 80007310 <userret+0x280>
    80001e7c:	ffffe097          	auipc	ra,0xffffe
    80001e80:	6d2080e7          	jalr	1746(ra) # 8000054e <panic>
    panic("sched running");
    80001e84:	00005517          	auipc	a0,0x5
    80001e88:	49c50513          	addi	a0,a0,1180 # 80007320 <userret+0x290>
    80001e8c:	ffffe097          	auipc	ra,0xffffe
    80001e90:	6c2080e7          	jalr	1730(ra) # 8000054e <panic>
    panic("sched interruptible");
    80001e94:	00005517          	auipc	a0,0x5
    80001e98:	49c50513          	addi	a0,a0,1180 # 80007330 <userret+0x2a0>
    80001e9c:	ffffe097          	auipc	ra,0xffffe
    80001ea0:	6b2080e7          	jalr	1714(ra) # 8000054e <panic>

0000000080001ea4 <exit>:
{
    80001ea4:	7179                	addi	sp,sp,-48
    80001ea6:	f406                	sd	ra,40(sp)
    80001ea8:	f022                	sd	s0,32(sp)
    80001eaa:	ec26                	sd	s1,24(sp)
    80001eac:	e84a                	sd	s2,16(sp)
    80001eae:	e44e                	sd	s3,8(sp)
    80001eb0:	e052                	sd	s4,0(sp)
    80001eb2:	1800                	addi	s0,sp,48
    80001eb4:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    80001eb6:	00000097          	auipc	ra,0x0
    80001eba:	98e080e7          	jalr	-1650(ra) # 80001844 <myproc>
    80001ebe:	89aa                	mv	s3,a0
  if(p == initproc)
    80001ec0:	00024797          	auipc	a5,0x24
    80001ec4:	1507b783          	ld	a5,336(a5) # 80026010 <initproc>
    80001ec8:	0d050493          	addi	s1,a0,208
    80001ecc:	15050913          	addi	s2,a0,336
    80001ed0:	02a79363          	bne	a5,a0,80001ef6 <exit+0x52>
    panic("init exiting");
    80001ed4:	00005517          	auipc	a0,0x5
    80001ed8:	47450513          	addi	a0,a0,1140 # 80007348 <userret+0x2b8>
    80001edc:	ffffe097          	auipc	ra,0xffffe
    80001ee0:	672080e7          	jalr	1650(ra) # 8000054e <panic>
      fileclose(f);
    80001ee4:	00002097          	auipc	ra,0x2
    80001ee8:	4ce080e7          	jalr	1230(ra) # 800043b2 <fileclose>
      p->ofile[fd] = 0;
    80001eec:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    80001ef0:	04a1                	addi	s1,s1,8
    80001ef2:	01248563          	beq	s1,s2,80001efc <exit+0x58>
    if(p->ofile[fd]){
    80001ef6:	6088                	ld	a0,0(s1)
    80001ef8:	f575                	bnez	a0,80001ee4 <exit+0x40>
    80001efa:	bfdd                	j	80001ef0 <exit+0x4c>
  begin_op();
    80001efc:	00002097          	auipc	ra,0x2
    80001f00:	fe4080e7          	jalr	-28(ra) # 80003ee0 <begin_op>
  iput(p->cwd);
    80001f04:	1509b503          	ld	a0,336(s3)
    80001f08:	00001097          	auipc	ra,0x1
    80001f0c:	750080e7          	jalr	1872(ra) # 80003658 <iput>
  end_op();
    80001f10:	00002097          	auipc	ra,0x2
    80001f14:	050080e7          	jalr	80(ra) # 80003f60 <end_op>
  p->cwd = 0;
    80001f18:	1409b823          	sd	zero,336(s3)
  acquire(&initproc->lock);
    80001f1c:	00024497          	auipc	s1,0x24
    80001f20:	0f448493          	addi	s1,s1,244 # 80026010 <initproc>
    80001f24:	6088                	ld	a0,0(s1)
    80001f26:	fffff097          	auipc	ra,0xfffff
    80001f2a:	bac080e7          	jalr	-1108(ra) # 80000ad2 <acquire>
  wakeup1(initproc);
    80001f2e:	6088                	ld	a0,0(s1)
    80001f30:	fffff097          	auipc	ra,0xfffff
    80001f34:	7d4080e7          	jalr	2004(ra) # 80001704 <wakeup1>
  release(&initproc->lock);
    80001f38:	6088                	ld	a0,0(s1)
    80001f3a:	fffff097          	auipc	ra,0xfffff
    80001f3e:	bec080e7          	jalr	-1044(ra) # 80000b26 <release>
  acquire(&p->lock);
    80001f42:	854e                	mv	a0,s3
    80001f44:	fffff097          	auipc	ra,0xfffff
    80001f48:	b8e080e7          	jalr	-1138(ra) # 80000ad2 <acquire>
  struct proc *original_parent = p->parent;
    80001f4c:	0209b483          	ld	s1,32(s3)
  release(&p->lock);
    80001f50:	854e                	mv	a0,s3
    80001f52:	fffff097          	auipc	ra,0xfffff
    80001f56:	bd4080e7          	jalr	-1068(ra) # 80000b26 <release>
  acquire(&original_parent->lock);
    80001f5a:	8526                	mv	a0,s1
    80001f5c:	fffff097          	auipc	ra,0xfffff
    80001f60:	b76080e7          	jalr	-1162(ra) # 80000ad2 <acquire>
  acquire(&p->lock);
    80001f64:	854e                	mv	a0,s3
    80001f66:	fffff097          	auipc	ra,0xfffff
    80001f6a:	b6c080e7          	jalr	-1172(ra) # 80000ad2 <acquire>
  reparent(p);
    80001f6e:	854e                	mv	a0,s3
    80001f70:	00000097          	auipc	ra,0x0
    80001f74:	d4c080e7          	jalr	-692(ra) # 80001cbc <reparent>
  wakeup1(original_parent);
    80001f78:	8526                	mv	a0,s1
    80001f7a:	fffff097          	auipc	ra,0xfffff
    80001f7e:	78a080e7          	jalr	1930(ra) # 80001704 <wakeup1>
  p->xstate = status;
    80001f82:	0349aa23          	sw	s4,52(s3)
  p->state = ZOMBIE;
    80001f86:	4791                	li	a5,4
    80001f88:	00f9ac23          	sw	a5,24(s3)
  release(&original_parent->lock);
    80001f8c:	8526                	mv	a0,s1
    80001f8e:	fffff097          	auipc	ra,0xfffff
    80001f92:	b98080e7          	jalr	-1128(ra) # 80000b26 <release>
  sched();
    80001f96:	00000097          	auipc	ra,0x0
    80001f9a:	e38080e7          	jalr	-456(ra) # 80001dce <sched>
  panic("zombie exit");
    80001f9e:	00005517          	auipc	a0,0x5
    80001fa2:	3ba50513          	addi	a0,a0,954 # 80007358 <userret+0x2c8>
    80001fa6:	ffffe097          	auipc	ra,0xffffe
    80001faa:	5a8080e7          	jalr	1448(ra) # 8000054e <panic>

0000000080001fae <yield>:
{
    80001fae:	1101                	addi	sp,sp,-32
    80001fb0:	ec06                	sd	ra,24(sp)
    80001fb2:	e822                	sd	s0,16(sp)
    80001fb4:	e426                	sd	s1,8(sp)
    80001fb6:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80001fb8:	00000097          	auipc	ra,0x0
    80001fbc:	88c080e7          	jalr	-1908(ra) # 80001844 <myproc>
    80001fc0:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80001fc2:	fffff097          	auipc	ra,0xfffff
    80001fc6:	b10080e7          	jalr	-1264(ra) # 80000ad2 <acquire>
  p->state = RUNNABLE;
    80001fca:	4789                	li	a5,2
    80001fcc:	cc9c                	sw	a5,24(s1)
  sched();
    80001fce:	00000097          	auipc	ra,0x0
    80001fd2:	e00080e7          	jalr	-512(ra) # 80001dce <sched>
  release(&p->lock);
    80001fd6:	8526                	mv	a0,s1
    80001fd8:	fffff097          	auipc	ra,0xfffff
    80001fdc:	b4e080e7          	jalr	-1202(ra) # 80000b26 <release>
}
    80001fe0:	60e2                	ld	ra,24(sp)
    80001fe2:	6442                	ld	s0,16(sp)
    80001fe4:	64a2                	ld	s1,8(sp)
    80001fe6:	6105                	addi	sp,sp,32
    80001fe8:	8082                	ret

0000000080001fea <sleep>:
{
    80001fea:	7179                	addi	sp,sp,-48
    80001fec:	f406                	sd	ra,40(sp)
    80001fee:	f022                	sd	s0,32(sp)
    80001ff0:	ec26                	sd	s1,24(sp)
    80001ff2:	e84a                	sd	s2,16(sp)
    80001ff4:	e44e                	sd	s3,8(sp)
    80001ff6:	1800                	addi	s0,sp,48
    80001ff8:	89aa                	mv	s3,a0
    80001ffa:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80001ffc:	00000097          	auipc	ra,0x0
    80002000:	848080e7          	jalr	-1976(ra) # 80001844 <myproc>
    80002004:	84aa                	mv	s1,a0
  if(lk != &p->lock){  //DOC: sleeplock0
    80002006:	05250663          	beq	a0,s2,80002052 <sleep+0x68>
    acquire(&p->lock);  //DOC: sleeplock1
    8000200a:	fffff097          	auipc	ra,0xfffff
    8000200e:	ac8080e7          	jalr	-1336(ra) # 80000ad2 <acquire>
    release(lk);
    80002012:	854a                	mv	a0,s2
    80002014:	fffff097          	auipc	ra,0xfffff
    80002018:	b12080e7          	jalr	-1262(ra) # 80000b26 <release>
  p->chan = chan;
    8000201c:	0334b423          	sd	s3,40(s1)
  p->state = SLEEPING;
    80002020:	4785                	li	a5,1
    80002022:	cc9c                	sw	a5,24(s1)
  sched();
    80002024:	00000097          	auipc	ra,0x0
    80002028:	daa080e7          	jalr	-598(ra) # 80001dce <sched>
  p->chan = 0;
    8000202c:	0204b423          	sd	zero,40(s1)
    release(&p->lock);
    80002030:	8526                	mv	a0,s1
    80002032:	fffff097          	auipc	ra,0xfffff
    80002036:	af4080e7          	jalr	-1292(ra) # 80000b26 <release>
    acquire(lk);
    8000203a:	854a                	mv	a0,s2
    8000203c:	fffff097          	auipc	ra,0xfffff
    80002040:	a96080e7          	jalr	-1386(ra) # 80000ad2 <acquire>
}
    80002044:	70a2                	ld	ra,40(sp)
    80002046:	7402                	ld	s0,32(sp)
    80002048:	64e2                	ld	s1,24(sp)
    8000204a:	6942                	ld	s2,16(sp)
    8000204c:	69a2                	ld	s3,8(sp)
    8000204e:	6145                	addi	sp,sp,48
    80002050:	8082                	ret
  p->chan = chan;
    80002052:	03353423          	sd	s3,40(a0)
  p->state = SLEEPING;
    80002056:	4785                	li	a5,1
    80002058:	cd1c                	sw	a5,24(a0)
  sched();
    8000205a:	00000097          	auipc	ra,0x0
    8000205e:	d74080e7          	jalr	-652(ra) # 80001dce <sched>
  p->chan = 0;
    80002062:	0204b423          	sd	zero,40(s1)
  if(lk != &p->lock){
    80002066:	bff9                	j	80002044 <sleep+0x5a>

0000000080002068 <wait>:
{
    80002068:	715d                	addi	sp,sp,-80
    8000206a:	e486                	sd	ra,72(sp)
    8000206c:	e0a2                	sd	s0,64(sp)
    8000206e:	fc26                	sd	s1,56(sp)
    80002070:	f84a                	sd	s2,48(sp)
    80002072:	f44e                	sd	s3,40(sp)
    80002074:	f052                	sd	s4,32(sp)
    80002076:	ec56                	sd	s5,24(sp)
    80002078:	e85a                	sd	s6,16(sp)
    8000207a:	e45e                	sd	s7,8(sp)
    8000207c:	e062                	sd	s8,0(sp)
    8000207e:	0880                	addi	s0,sp,80
    80002080:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    80002082:	fffff097          	auipc	ra,0xfffff
    80002086:	7c2080e7          	jalr	1986(ra) # 80001844 <myproc>
    8000208a:	892a                	mv	s2,a0
  acquire(&p->lock);
    8000208c:	8c2a                	mv	s8,a0
    8000208e:	fffff097          	auipc	ra,0xfffff
    80002092:	a44080e7          	jalr	-1468(ra) # 80000ad2 <acquire>
    havekids = 0;
    80002096:	4b81                	li	s7,0
        if(np->state == ZOMBIE){
    80002098:	4a11                	li	s4,4
    for(np = proc; np < &proc[NPROC]; np++){
    8000209a:	00016997          	auipc	s3,0x16
    8000209e:	86698993          	addi	s3,s3,-1946 # 80017900 <tickslock>
        havekids = 1;
    800020a2:	4a85                	li	s5,1
    havekids = 0;
    800020a4:	875e                	mv	a4,s7
    for(np = proc; np < &proc[NPROC]; np++){
    800020a6:	00010497          	auipc	s1,0x10
    800020aa:	c5a48493          	addi	s1,s1,-934 # 80011d00 <proc>
    800020ae:	a08d                	j	80002110 <wait+0xa8>
          pid = np->pid;
    800020b0:	0384a983          	lw	s3,56(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&np->xstate,
    800020b4:	000b0e63          	beqz	s6,800020d0 <wait+0x68>
    800020b8:	4691                	li	a3,4
    800020ba:	03448613          	addi	a2,s1,52
    800020be:	85da                	mv	a1,s6
    800020c0:	05093503          	ld	a0,80(s2)
    800020c4:	fffff097          	auipc	ra,0xfffff
    800020c8:	474080e7          	jalr	1140(ra) # 80001538 <copyout>
    800020cc:	02054263          	bltz	a0,800020f0 <wait+0x88>
          freeproc(np);
    800020d0:	8526                	mv	a0,s1
    800020d2:	00000097          	auipc	ra,0x0
    800020d6:	992080e7          	jalr	-1646(ra) # 80001a64 <freeproc>
          release(&np->lock);
    800020da:	8526                	mv	a0,s1
    800020dc:	fffff097          	auipc	ra,0xfffff
    800020e0:	a4a080e7          	jalr	-1462(ra) # 80000b26 <release>
          release(&p->lock);
    800020e4:	854a                	mv	a0,s2
    800020e6:	fffff097          	auipc	ra,0xfffff
    800020ea:	a40080e7          	jalr	-1472(ra) # 80000b26 <release>
          return pid;
    800020ee:	a8a9                	j	80002148 <wait+0xe0>
            release(&np->lock);
    800020f0:	8526                	mv	a0,s1
    800020f2:	fffff097          	auipc	ra,0xfffff
    800020f6:	a34080e7          	jalr	-1484(ra) # 80000b26 <release>
            release(&p->lock);
    800020fa:	854a                	mv	a0,s2
    800020fc:	fffff097          	auipc	ra,0xfffff
    80002100:	a2a080e7          	jalr	-1494(ra) # 80000b26 <release>
            return -1;
    80002104:	59fd                	li	s3,-1
    80002106:	a089                	j	80002148 <wait+0xe0>
    for(np = proc; np < &proc[NPROC]; np++){
    80002108:	17048493          	addi	s1,s1,368
    8000210c:	03348463          	beq	s1,s3,80002134 <wait+0xcc>
      if(np->parent == p){
    80002110:	709c                	ld	a5,32(s1)
    80002112:	ff279be3          	bne	a5,s2,80002108 <wait+0xa0>
        acquire(&np->lock);
    80002116:	8526                	mv	a0,s1
    80002118:	fffff097          	auipc	ra,0xfffff
    8000211c:	9ba080e7          	jalr	-1606(ra) # 80000ad2 <acquire>
        if(np->state == ZOMBIE){
    80002120:	4c9c                	lw	a5,24(s1)
    80002122:	f94787e3          	beq	a5,s4,800020b0 <wait+0x48>
        release(&np->lock);
    80002126:	8526                	mv	a0,s1
    80002128:	fffff097          	auipc	ra,0xfffff
    8000212c:	9fe080e7          	jalr	-1538(ra) # 80000b26 <release>
        havekids = 1;
    80002130:	8756                	mv	a4,s5
    80002132:	bfd9                	j	80002108 <wait+0xa0>
    if(!havekids || p->killed){
    80002134:	c701                	beqz	a4,8000213c <wait+0xd4>
    80002136:	03092783          	lw	a5,48(s2)
    8000213a:	c785                	beqz	a5,80002162 <wait+0xfa>
      release(&p->lock);
    8000213c:	854a                	mv	a0,s2
    8000213e:	fffff097          	auipc	ra,0xfffff
    80002142:	9e8080e7          	jalr	-1560(ra) # 80000b26 <release>
      return -1;
    80002146:	59fd                	li	s3,-1
}
    80002148:	854e                	mv	a0,s3
    8000214a:	60a6                	ld	ra,72(sp)
    8000214c:	6406                	ld	s0,64(sp)
    8000214e:	74e2                	ld	s1,56(sp)
    80002150:	7942                	ld	s2,48(sp)
    80002152:	79a2                	ld	s3,40(sp)
    80002154:	7a02                	ld	s4,32(sp)
    80002156:	6ae2                	ld	s5,24(sp)
    80002158:	6b42                	ld	s6,16(sp)
    8000215a:	6ba2                	ld	s7,8(sp)
    8000215c:	6c02                	ld	s8,0(sp)
    8000215e:	6161                	addi	sp,sp,80
    80002160:	8082                	ret
    sleep(p, &p->lock);  //DOC: wait-sleep
    80002162:	85e2                	mv	a1,s8
    80002164:	854a                	mv	a0,s2
    80002166:	00000097          	auipc	ra,0x0
    8000216a:	e84080e7          	jalr	-380(ra) # 80001fea <sleep>
    havekids = 0;
    8000216e:	bf1d                	j	800020a4 <wait+0x3c>

0000000080002170 <wakeup>:
{
    80002170:	7139                	addi	sp,sp,-64
    80002172:	fc06                	sd	ra,56(sp)
    80002174:	f822                	sd	s0,48(sp)
    80002176:	f426                	sd	s1,40(sp)
    80002178:	f04a                	sd	s2,32(sp)
    8000217a:	ec4e                	sd	s3,24(sp)
    8000217c:	e852                	sd	s4,16(sp)
    8000217e:	e456                	sd	s5,8(sp)
    80002180:	0080                	addi	s0,sp,64
    80002182:	8a2a                	mv	s4,a0
  for(p = proc; p < &proc[NPROC]; p++) {
    80002184:	00010497          	auipc	s1,0x10
    80002188:	b7c48493          	addi	s1,s1,-1156 # 80011d00 <proc>
    if(p->state == SLEEPING && p->chan == chan) {
    8000218c:	4985                	li	s3,1
      p->state = RUNNABLE;
    8000218e:	4a89                	li	s5,2
  for(p = proc; p < &proc[NPROC]; p++) {
    80002190:	00015917          	auipc	s2,0x15
    80002194:	77090913          	addi	s2,s2,1904 # 80017900 <tickslock>
    80002198:	a821                	j	800021b0 <wakeup+0x40>
      p->state = RUNNABLE;
    8000219a:	0154ac23          	sw	s5,24(s1)
    release(&p->lock);
    8000219e:	8526                	mv	a0,s1
    800021a0:	fffff097          	auipc	ra,0xfffff
    800021a4:	986080e7          	jalr	-1658(ra) # 80000b26 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    800021a8:	17048493          	addi	s1,s1,368
    800021ac:	01248e63          	beq	s1,s2,800021c8 <wakeup+0x58>
    acquire(&p->lock);
    800021b0:	8526                	mv	a0,s1
    800021b2:	fffff097          	auipc	ra,0xfffff
    800021b6:	920080e7          	jalr	-1760(ra) # 80000ad2 <acquire>
    if(p->state == SLEEPING && p->chan == chan) {
    800021ba:	4c9c                	lw	a5,24(s1)
    800021bc:	ff3791e3          	bne	a5,s3,8000219e <wakeup+0x2e>
    800021c0:	749c                	ld	a5,40(s1)
    800021c2:	fd479ee3          	bne	a5,s4,8000219e <wakeup+0x2e>
    800021c6:	bfd1                	j	8000219a <wakeup+0x2a>
}
    800021c8:	70e2                	ld	ra,56(sp)
    800021ca:	7442                	ld	s0,48(sp)
    800021cc:	74a2                	ld	s1,40(sp)
    800021ce:	7902                	ld	s2,32(sp)
    800021d0:	69e2                	ld	s3,24(sp)
    800021d2:	6a42                	ld	s4,16(sp)
    800021d4:	6aa2                	ld	s5,8(sp)
    800021d6:	6121                	addi	sp,sp,64
    800021d8:	8082                	ret

00000000800021da <kill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
    800021da:	7179                	addi	sp,sp,-48
    800021dc:	f406                	sd	ra,40(sp)
    800021de:	f022                	sd	s0,32(sp)
    800021e0:	ec26                	sd	s1,24(sp)
    800021e2:	e84a                	sd	s2,16(sp)
    800021e4:	e44e                	sd	s3,8(sp)
    800021e6:	1800                	addi	s0,sp,48
    800021e8:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    800021ea:	00010497          	auipc	s1,0x10
    800021ee:	b1648493          	addi	s1,s1,-1258 # 80011d00 <proc>
    800021f2:	00015997          	auipc	s3,0x15
    800021f6:	70e98993          	addi	s3,s3,1806 # 80017900 <tickslock>
    acquire(&p->lock);
    800021fa:	8526                	mv	a0,s1
    800021fc:	fffff097          	auipc	ra,0xfffff
    80002200:	8d6080e7          	jalr	-1834(ra) # 80000ad2 <acquire>
    if(p->pid == pid){
    80002204:	5c9c                	lw	a5,56(s1)
    80002206:	01278d63          	beq	a5,s2,80002220 <kill+0x46>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    8000220a:	8526                	mv	a0,s1
    8000220c:	fffff097          	auipc	ra,0xfffff
    80002210:	91a080e7          	jalr	-1766(ra) # 80000b26 <release>
  for(p = proc; p < &proc[NPROC]; p++){
    80002214:	17048493          	addi	s1,s1,368
    80002218:	ff3491e3          	bne	s1,s3,800021fa <kill+0x20>
  }
  return -1;
    8000221c:	557d                	li	a0,-1
    8000221e:	a829                	j	80002238 <kill+0x5e>
      p->killed = 1;
    80002220:	4785                	li	a5,1
    80002222:	d89c                	sw	a5,48(s1)
      if(p->state == SLEEPING){
    80002224:	4c98                	lw	a4,24(s1)
    80002226:	4785                	li	a5,1
    80002228:	00f70f63          	beq	a4,a5,80002246 <kill+0x6c>
      release(&p->lock);
    8000222c:	8526                	mv	a0,s1
    8000222e:	fffff097          	auipc	ra,0xfffff
    80002232:	8f8080e7          	jalr	-1800(ra) # 80000b26 <release>
      return 0;
    80002236:	4501                	li	a0,0
}
    80002238:	70a2                	ld	ra,40(sp)
    8000223a:	7402                	ld	s0,32(sp)
    8000223c:	64e2                	ld	s1,24(sp)
    8000223e:	6942                	ld	s2,16(sp)
    80002240:	69a2                	ld	s3,8(sp)
    80002242:	6145                	addi	sp,sp,48
    80002244:	8082                	ret
        p->state = RUNNABLE;
    80002246:	4789                	li	a5,2
    80002248:	cc9c                	sw	a5,24(s1)
    8000224a:	b7cd                	j	8000222c <kill+0x52>

000000008000224c <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    8000224c:	7179                	addi	sp,sp,-48
    8000224e:	f406                	sd	ra,40(sp)
    80002250:	f022                	sd	s0,32(sp)
    80002252:	ec26                	sd	s1,24(sp)
    80002254:	e84a                	sd	s2,16(sp)
    80002256:	e44e                	sd	s3,8(sp)
    80002258:	e052                	sd	s4,0(sp)
    8000225a:	1800                	addi	s0,sp,48
    8000225c:	84aa                	mv	s1,a0
    8000225e:	892e                	mv	s2,a1
    80002260:	89b2                	mv	s3,a2
    80002262:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002264:	fffff097          	auipc	ra,0xfffff
    80002268:	5e0080e7          	jalr	1504(ra) # 80001844 <myproc>
  if(user_dst){
    8000226c:	c08d                	beqz	s1,8000228e <either_copyout+0x42>
    return copyout(p->pagetable, dst, src, len);
    8000226e:	86d2                	mv	a3,s4
    80002270:	864e                	mv	a2,s3
    80002272:	85ca                	mv	a1,s2
    80002274:	6928                	ld	a0,80(a0)
    80002276:	fffff097          	auipc	ra,0xfffff
    8000227a:	2c2080e7          	jalr	706(ra) # 80001538 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    8000227e:	70a2                	ld	ra,40(sp)
    80002280:	7402                	ld	s0,32(sp)
    80002282:	64e2                	ld	s1,24(sp)
    80002284:	6942                	ld	s2,16(sp)
    80002286:	69a2                	ld	s3,8(sp)
    80002288:	6a02                	ld	s4,0(sp)
    8000228a:	6145                	addi	sp,sp,48
    8000228c:	8082                	ret
    memmove((char *)dst, src, len);
    8000228e:	000a061b          	sext.w	a2,s4
    80002292:	85ce                	mv	a1,s3
    80002294:	854a                	mv	a0,s2
    80002296:	fffff097          	auipc	ra,0xfffff
    8000229a:	938080e7          	jalr	-1736(ra) # 80000bce <memmove>
    return 0;
    8000229e:	8526                	mv	a0,s1
    800022a0:	bff9                	j	8000227e <either_copyout+0x32>

00000000800022a2 <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    800022a2:	7179                	addi	sp,sp,-48
    800022a4:	f406                	sd	ra,40(sp)
    800022a6:	f022                	sd	s0,32(sp)
    800022a8:	ec26                	sd	s1,24(sp)
    800022aa:	e84a                	sd	s2,16(sp)
    800022ac:	e44e                	sd	s3,8(sp)
    800022ae:	e052                	sd	s4,0(sp)
    800022b0:	1800                	addi	s0,sp,48
    800022b2:	892a                	mv	s2,a0
    800022b4:	84ae                	mv	s1,a1
    800022b6:	89b2                	mv	s3,a2
    800022b8:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800022ba:	fffff097          	auipc	ra,0xfffff
    800022be:	58a080e7          	jalr	1418(ra) # 80001844 <myproc>
  if(user_src){
    800022c2:	c08d                	beqz	s1,800022e4 <either_copyin+0x42>
    return copyin(p->pagetable, dst, src, len);
    800022c4:	86d2                	mv	a3,s4
    800022c6:	864e                	mv	a2,s3
    800022c8:	85ca                	mv	a1,s2
    800022ca:	6928                	ld	a0,80(a0)
    800022cc:	fffff097          	auipc	ra,0xfffff
    800022d0:	2f8080e7          	jalr	760(ra) # 800015c4 <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    800022d4:	70a2                	ld	ra,40(sp)
    800022d6:	7402                	ld	s0,32(sp)
    800022d8:	64e2                	ld	s1,24(sp)
    800022da:	6942                	ld	s2,16(sp)
    800022dc:	69a2                	ld	s3,8(sp)
    800022de:	6a02                	ld	s4,0(sp)
    800022e0:	6145                	addi	sp,sp,48
    800022e2:	8082                	ret
    memmove(dst, (char*)src, len);
    800022e4:	000a061b          	sext.w	a2,s4
    800022e8:	85ce                	mv	a1,s3
    800022ea:	854a                	mv	a0,s2
    800022ec:	fffff097          	auipc	ra,0xfffff
    800022f0:	8e2080e7          	jalr	-1822(ra) # 80000bce <memmove>
    return 0;
    800022f4:	8526                	mv	a0,s1
    800022f6:	bff9                	j	800022d4 <either_copyin+0x32>

00000000800022f8 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    800022f8:	715d                	addi	sp,sp,-80
    800022fa:	e486                	sd	ra,72(sp)
    800022fc:	e0a2                	sd	s0,64(sp)
    800022fe:	fc26                	sd	s1,56(sp)
    80002300:	f84a                	sd	s2,48(sp)
    80002302:	f44e                	sd	s3,40(sp)
    80002304:	f052                	sd	s4,32(sp)
    80002306:	ec56                	sd	s5,24(sp)
    80002308:	e85a                	sd	s6,16(sp)
    8000230a:	e45e                	sd	s7,8(sp)
    8000230c:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    8000230e:	00005517          	auipc	a0,0x5
    80002312:	ea250513          	addi	a0,a0,-350 # 800071b0 <userret+0x120>
    80002316:	ffffe097          	auipc	ra,0xffffe
    8000231a:	282080e7          	jalr	642(ra) # 80000598 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    8000231e:	00010497          	auipc	s1,0x10
    80002322:	b3a48493          	addi	s1,s1,-1222 # 80011e58 <proc+0x158>
    80002326:	00015917          	auipc	s2,0x15
    8000232a:	73290913          	addi	s2,s2,1842 # 80017a58 <bcache+0x140>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000232e:	4b11                	li	s6,4
      state = states[p->state];
    else
      state = "???";
    80002330:	00005997          	auipc	s3,0x5
    80002334:	03898993          	addi	s3,s3,56 # 80007368 <userret+0x2d8>
    printf("%d %s %s", p->pid, state, p->name);
    80002338:	00005a97          	auipc	s5,0x5
    8000233c:	038a8a93          	addi	s5,s5,56 # 80007370 <userret+0x2e0>
    printf("\n");
    80002340:	00005a17          	auipc	s4,0x5
    80002344:	e70a0a13          	addi	s4,s4,-400 # 800071b0 <userret+0x120>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002348:	00005b97          	auipc	s7,0x5
    8000234c:	548b8b93          	addi	s7,s7,1352 # 80007890 <states.1705>
    80002350:	a00d                	j	80002372 <procdump+0x7a>
    printf("%d %s %s", p->pid, state, p->name);
    80002352:	ee06a583          	lw	a1,-288(a3)
    80002356:	8556                	mv	a0,s5
    80002358:	ffffe097          	auipc	ra,0xffffe
    8000235c:	240080e7          	jalr	576(ra) # 80000598 <printf>
    printf("\n");
    80002360:	8552                	mv	a0,s4
    80002362:	ffffe097          	auipc	ra,0xffffe
    80002366:	236080e7          	jalr	566(ra) # 80000598 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    8000236a:	17048493          	addi	s1,s1,368
    8000236e:	03248163          	beq	s1,s2,80002390 <procdump+0x98>
    if(p->state == UNUSED)
    80002372:	86a6                	mv	a3,s1
    80002374:	ec04a783          	lw	a5,-320(s1)
    80002378:	dbed                	beqz	a5,8000236a <procdump+0x72>
      state = "???";
    8000237a:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000237c:	fcfb6be3          	bltu	s6,a5,80002352 <procdump+0x5a>
    80002380:	1782                	slli	a5,a5,0x20
    80002382:	9381                	srli	a5,a5,0x20
    80002384:	078e                	slli	a5,a5,0x3
    80002386:	97de                	add	a5,a5,s7
    80002388:	6390                	ld	a2,0(a5)
    8000238a:	f661                	bnez	a2,80002352 <procdump+0x5a>
      state = "???";
    8000238c:	864e                	mv	a2,s3
    8000238e:	b7d1                	j	80002352 <procdump+0x5a>
  }
}
    80002390:	60a6                	ld	ra,72(sp)
    80002392:	6406                	ld	s0,64(sp)
    80002394:	74e2                	ld	s1,56(sp)
    80002396:	7942                	ld	s2,48(sp)
    80002398:	79a2                	ld	s3,40(sp)
    8000239a:	7a02                	ld	s4,32(sp)
    8000239c:	6ae2                	ld	s5,24(sp)
    8000239e:	6b42                	ld	s6,16(sp)
    800023a0:	6ba2                	ld	s7,8(sp)
    800023a2:	6161                	addi	sp,sp,80
    800023a4:	8082                	ret

00000000800023a6 <traceon>:

//Turn on trace mode
void traceon (void)
{
    800023a6:	1141                	addi	sp,sp,-16
    800023a8:	e406                	sd	ra,8(sp)
    800023aa:	e022                	sd	s0,0(sp)
    800023ac:	0800                	addi	s0,sp,16
   myproc()->tracing = 1;
    800023ae:	fffff097          	auipc	ra,0xfffff
    800023b2:	496080e7          	jalr	1174(ra) # 80001844 <myproc>
    800023b6:	4785                	li	a5,1
    800023b8:	16f52423          	sw	a5,360(a0)
}
    800023bc:	60a2                	ld	ra,8(sp)
    800023be:	6402                	ld	s0,0(sp)
    800023c0:	0141                	addi	sp,sp,16
    800023c2:	8082                	ret

00000000800023c4 <kps>:

//ps kernal code
void kps (struct pinfo *pi)
{
    800023c4:	7179                	addi	sp,sp,-48
    800023c6:	f406                	sd	ra,40(sp)
    800023c8:	f022                	sd	s0,32(sp)
    800023ca:	ec26                	sd	s1,24(sp)
    800023cc:	e84a                	sd	s2,16(sp)
    800023ce:	e44e                	sd	s3,8(sp)
    800023d0:	e052                	sd	s4,0(sp)
    800023d2:	1800                	addi	s0,sp,48
    800023d4:	8a2a                	mv	s4,a0
    struct proc *p;
    int i = 0;
    800023d6:	4901                	li	s2,0

    for(p = proc; p < &proc[NPROC]; p++) {
    800023d8:	00010497          	auipc	s1,0x10
    800023dc:	92848493          	addi	s1,s1,-1752 # 80011d00 <proc>
    800023e0:	00015997          	auipc	s3,0x15
    800023e4:	52098993          	addi	s3,s3,1312 # 80017900 <tickslock>
    800023e8:	a835                	j	80002424 <kps+0x60>
        acquire(&p->lock);
        
	if(p->state != UNUSED) {
            pi->proc[i].pid = p->pid;
    800023ea:	5c98                	lw	a4,56(s1)
    800023ec:	00191513          	slli	a0,s2,0x1
    800023f0:	954a                	add	a0,a0,s2
    800023f2:	050e                	slli	a0,a0,0x3
    800023f4:	00aa07b3          	add	a5,s4,a0
    800023f8:	c3d8                	sw	a4,4(a5)
            pi->proc[i].sz = p->sz;
    800023fa:	64b8                	ld	a4,72(s1)
    800023fc:	c798                	sw	a4,8(a5)
            safestrcpy(pi->proc[i].name, p->name, 16);
    800023fe:	0531                	addi	a0,a0,12
    80002400:	4641                	li	a2,16
    80002402:	15848593          	addi	a1,s1,344
    80002406:	9552                	add	a0,a0,s4
    80002408:	fffff097          	auipc	ra,0xfffff
    8000240c:	8bc080e7          	jalr	-1860(ra) # 80000cc4 <safestrcpy>
            i++;
    80002410:	2905                	addiw	s2,s2,1
        }

        release(&p->lock);
    80002412:	8526                	mv	a0,s1
    80002414:	ffffe097          	auipc	ra,0xffffe
    80002418:	712080e7          	jalr	1810(ra) # 80000b26 <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    8000241c:	17048493          	addi	s1,s1,368
    80002420:	01348a63          	beq	s1,s3,80002434 <kps+0x70>
        acquire(&p->lock);
    80002424:	8526                	mv	a0,s1
    80002426:	ffffe097          	auipc	ra,0xffffe
    8000242a:	6ac080e7          	jalr	1708(ra) # 80000ad2 <acquire>
	if(p->state != UNUSED) {
    8000242e:	4c9c                	lw	a5,24(s1)
    80002430:	d3ed                	beqz	a5,80002412 <kps+0x4e>
    80002432:	bf65                	j	800023ea <kps+0x26>
    }

    pi->count = i;
    80002434:	012a2023          	sw	s2,0(s4)
}
    80002438:	70a2                	ld	ra,40(sp)
    8000243a:	7402                	ld	s0,32(sp)
    8000243c:	64e2                	ld	s1,24(sp)
    8000243e:	6942                	ld	s2,16(sp)
    80002440:	69a2                	ld	s3,8(sp)
    80002442:	6a02                	ld	s4,0(sp)
    80002444:	6145                	addi	sp,sp,48
    80002446:	8082                	ret

0000000080002448 <swtch>:
    80002448:	00153023          	sd	ra,0(a0)
    8000244c:	00253423          	sd	sp,8(a0)
    80002450:	e900                	sd	s0,16(a0)
    80002452:	ed04                	sd	s1,24(a0)
    80002454:	03253023          	sd	s2,32(a0)
    80002458:	03353423          	sd	s3,40(a0)
    8000245c:	03453823          	sd	s4,48(a0)
    80002460:	03553c23          	sd	s5,56(a0)
    80002464:	05653023          	sd	s6,64(a0)
    80002468:	05753423          	sd	s7,72(a0)
    8000246c:	05853823          	sd	s8,80(a0)
    80002470:	05953c23          	sd	s9,88(a0)
    80002474:	07a53023          	sd	s10,96(a0)
    80002478:	07b53423          	sd	s11,104(a0)
    8000247c:	0005b083          	ld	ra,0(a1)
    80002480:	0085b103          	ld	sp,8(a1)
    80002484:	6980                	ld	s0,16(a1)
    80002486:	6d84                	ld	s1,24(a1)
    80002488:	0205b903          	ld	s2,32(a1)
    8000248c:	0285b983          	ld	s3,40(a1)
    80002490:	0305ba03          	ld	s4,48(a1)
    80002494:	0385ba83          	ld	s5,56(a1)
    80002498:	0405bb03          	ld	s6,64(a1)
    8000249c:	0485bb83          	ld	s7,72(a1)
    800024a0:	0505bc03          	ld	s8,80(a1)
    800024a4:	0585bc83          	ld	s9,88(a1)
    800024a8:	0605bd03          	ld	s10,96(a1)
    800024ac:	0685bd83          	ld	s11,104(a1)
    800024b0:	8082                	ret

00000000800024b2 <trapinit>:

extern int devintr();

void
trapinit(void)
{
    800024b2:	1141                	addi	sp,sp,-16
    800024b4:	e406                	sd	ra,8(sp)
    800024b6:	e022                	sd	s0,0(sp)
    800024b8:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    800024ba:	00005597          	auipc	a1,0x5
    800024be:	eee58593          	addi	a1,a1,-274 # 800073a8 <userret+0x318>
    800024c2:	00015517          	auipc	a0,0x15
    800024c6:	43e50513          	addi	a0,a0,1086 # 80017900 <tickslock>
    800024ca:	ffffe097          	auipc	ra,0xffffe
    800024ce:	4f6080e7          	jalr	1270(ra) # 800009c0 <initlock>
}
    800024d2:	60a2                	ld	ra,8(sp)
    800024d4:	6402                	ld	s0,0(sp)
    800024d6:	0141                	addi	sp,sp,16
    800024d8:	8082                	ret

00000000800024da <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    800024da:	1141                	addi	sp,sp,-16
    800024dc:	e422                	sd	s0,8(sp)
    800024de:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    800024e0:	00003797          	auipc	a5,0x3
    800024e4:	5d078793          	addi	a5,a5,1488 # 80005ab0 <kernelvec>
    800024e8:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    800024ec:	6422                	ld	s0,8(sp)
    800024ee:	0141                	addi	sp,sp,16
    800024f0:	8082                	ret

00000000800024f2 <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    800024f2:	1141                	addi	sp,sp,-16
    800024f4:	e406                	sd	ra,8(sp)
    800024f6:	e022                	sd	s0,0(sp)
    800024f8:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    800024fa:	fffff097          	auipc	ra,0xfffff
    800024fe:	34a080e7          	jalr	842(ra) # 80001844 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002502:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80002506:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002508:	10079073          	csrw	sstatus,a5
  // turn off interrupts, since we're switching
  // now from kerneltrap() to usertrap().
  intr_off();

  // send syscalls, interrupts, and exceptions to trampoline.S
  w_stvec(TRAMPOLINE + (uservec - trampoline));
    8000250c:	00005617          	auipc	a2,0x5
    80002510:	af460613          	addi	a2,a2,-1292 # 80007000 <trampoline>
    80002514:	00005697          	auipc	a3,0x5
    80002518:	aec68693          	addi	a3,a3,-1300 # 80007000 <trampoline>
    8000251c:	8e91                	sub	a3,a3,a2
    8000251e:	040007b7          	lui	a5,0x4000
    80002522:	17fd                	addi	a5,a5,-1
    80002524:	07b2                	slli	a5,a5,0xc
    80002526:	96be                	add	a3,a3,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002528:	10569073          	csrw	stvec,a3

  // set up trapframe values that uservec will need when
  // the process next re-enters the kernel.
  p->tf->kernel_satp = r_satp();         // kernel page table
    8000252c:	6d38                	ld	a4,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    8000252e:	180026f3          	csrr	a3,satp
    80002532:	e314                	sd	a3,0(a4)
  p->tf->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80002534:	6d38                	ld	a4,88(a0)
    80002536:	6134                	ld	a3,64(a0)
    80002538:	6585                	lui	a1,0x1
    8000253a:	96ae                	add	a3,a3,a1
    8000253c:	e714                	sd	a3,8(a4)
  p->tf->kernel_trap = (uint64)usertrap;
    8000253e:	6d38                	ld	a4,88(a0)
    80002540:	00000697          	auipc	a3,0x0
    80002544:	12268693          	addi	a3,a3,290 # 80002662 <usertrap>
    80002548:	eb14                	sd	a3,16(a4)
  p->tf->kernel_hartid = r_tp();         // hartid for cpuid()
    8000254a:	6d38                	ld	a4,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    8000254c:	8692                	mv	a3,tp
    8000254e:	f314                	sd	a3,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002550:	100026f3          	csrr	a3,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80002554:	eff6f693          	andi	a3,a3,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80002558:	0206e693          	ori	a3,a3,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000255c:	10069073          	csrw	sstatus,a3
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->tf->epc);
    80002560:	6d38                	ld	a4,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002562:	6f18                	ld	a4,24(a4)
    80002564:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    80002568:	692c                	ld	a1,80(a0)
    8000256a:	81b1                	srli	a1,a1,0xc

  // jump to trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 fn = TRAMPOLINE + (userret - trampoline);
    8000256c:	00005717          	auipc	a4,0x5
    80002570:	b2470713          	addi	a4,a4,-1244 # 80007090 <userret>
    80002574:	8f11                	sub	a4,a4,a2
    80002576:	97ba                	add	a5,a5,a4
  ((void (*)(uint64,uint64))fn)(TRAPFRAME, satp);
    80002578:	577d                	li	a4,-1
    8000257a:	177e                	slli	a4,a4,0x3f
    8000257c:	8dd9                	or	a1,a1,a4
    8000257e:	02000537          	lui	a0,0x2000
    80002582:	157d                	addi	a0,a0,-1
    80002584:	0536                	slli	a0,a0,0xd
    80002586:	9782                	jalr	a5
}
    80002588:	60a2                	ld	ra,8(sp)
    8000258a:	6402                	ld	s0,0(sp)
    8000258c:	0141                	addi	sp,sp,16
    8000258e:	8082                	ret

0000000080002590 <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    80002590:	1101                	addi	sp,sp,-32
    80002592:	ec06                	sd	ra,24(sp)
    80002594:	e822                	sd	s0,16(sp)
    80002596:	e426                	sd	s1,8(sp)
    80002598:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    8000259a:	00015497          	auipc	s1,0x15
    8000259e:	36648493          	addi	s1,s1,870 # 80017900 <tickslock>
    800025a2:	8526                	mv	a0,s1
    800025a4:	ffffe097          	auipc	ra,0xffffe
    800025a8:	52e080e7          	jalr	1326(ra) # 80000ad2 <acquire>
  ticks++;
    800025ac:	00024517          	auipc	a0,0x24
    800025b0:	a6c50513          	addi	a0,a0,-1428 # 80026018 <ticks>
    800025b4:	411c                	lw	a5,0(a0)
    800025b6:	2785                	addiw	a5,a5,1
    800025b8:	c11c                	sw	a5,0(a0)
  wakeup(&ticks);
    800025ba:	00000097          	auipc	ra,0x0
    800025be:	bb6080e7          	jalr	-1098(ra) # 80002170 <wakeup>
  release(&tickslock);
    800025c2:	8526                	mv	a0,s1
    800025c4:	ffffe097          	auipc	ra,0xffffe
    800025c8:	562080e7          	jalr	1378(ra) # 80000b26 <release>
}
    800025cc:	60e2                	ld	ra,24(sp)
    800025ce:	6442                	ld	s0,16(sp)
    800025d0:	64a2                	ld	s1,8(sp)
    800025d2:	6105                	addi	sp,sp,32
    800025d4:	8082                	ret

00000000800025d6 <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    800025d6:	1101                	addi	sp,sp,-32
    800025d8:	ec06                	sd	ra,24(sp)
    800025da:	e822                	sd	s0,16(sp)
    800025dc:	e426                	sd	s1,8(sp)
    800025de:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    800025e0:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if((scause & 0x8000000000000000L) &&
    800025e4:	00074d63          	bltz	a4,800025fe <devintr+0x28>
      virtio_disk_intr();
    }

    plic_complete(irq);
    return 1;
  } else if(scause == 0x8000000000000001L){
    800025e8:	57fd                	li	a5,-1
    800025ea:	17fe                	slli	a5,a5,0x3f
    800025ec:	0785                	addi	a5,a5,1
    // the SSIP bit in sip.
    w_sip(r_sip() & ~2);

    return 2;
  } else {
    return 0;
    800025ee:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    800025f0:	04f70863          	beq	a4,a5,80002640 <devintr+0x6a>
  }
}
    800025f4:	60e2                	ld	ra,24(sp)
    800025f6:	6442                	ld	s0,16(sp)
    800025f8:	64a2                	ld	s1,8(sp)
    800025fa:	6105                	addi	sp,sp,32
    800025fc:	8082                	ret
     (scause & 0xff) == 9){
    800025fe:	0ff77793          	andi	a5,a4,255
  if((scause & 0x8000000000000000L) &&
    80002602:	46a5                	li	a3,9
    80002604:	fed792e3          	bne	a5,a3,800025e8 <devintr+0x12>
    int irq = plic_claim();
    80002608:	00003097          	auipc	ra,0x3
    8000260c:	5c2080e7          	jalr	1474(ra) # 80005bca <plic_claim>
    80002610:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    80002612:	47a9                	li	a5,10
    80002614:	00f50c63          	beq	a0,a5,8000262c <devintr+0x56>
    } else if(irq == VIRTIO0_IRQ){
    80002618:	4785                	li	a5,1
    8000261a:	00f50e63          	beq	a0,a5,80002636 <devintr+0x60>
    plic_complete(irq);
    8000261e:	8526                	mv	a0,s1
    80002620:	00003097          	auipc	ra,0x3
    80002624:	5ce080e7          	jalr	1486(ra) # 80005bee <plic_complete>
    return 1;
    80002628:	4505                	li	a0,1
    8000262a:	b7e9                	j	800025f4 <devintr+0x1e>
      uartintr();
    8000262c:	ffffe097          	auipc	ra,0xffffe
    80002630:	20c080e7          	jalr	524(ra) # 80000838 <uartintr>
    80002634:	b7ed                	j	8000261e <devintr+0x48>
      virtio_disk_intr();
    80002636:	00004097          	auipc	ra,0x4
    8000263a:	a52080e7          	jalr	-1454(ra) # 80006088 <virtio_disk_intr>
    8000263e:	b7c5                	j	8000261e <devintr+0x48>
    if(cpuid() == 0){
    80002640:	fffff097          	auipc	ra,0xfffff
    80002644:	1d8080e7          	jalr	472(ra) # 80001818 <cpuid>
    80002648:	c901                	beqz	a0,80002658 <devintr+0x82>
  asm volatile("csrr %0, sip" : "=r" (x) );
    8000264a:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    8000264e:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    80002650:	14479073          	csrw	sip,a5
    return 2;
    80002654:	4509                	li	a0,2
    80002656:	bf79                	j	800025f4 <devintr+0x1e>
      clockintr();
    80002658:	00000097          	auipc	ra,0x0
    8000265c:	f38080e7          	jalr	-200(ra) # 80002590 <clockintr>
    80002660:	b7ed                	j	8000264a <devintr+0x74>

0000000080002662 <usertrap>:
{
    80002662:	1101                	addi	sp,sp,-32
    80002664:	ec06                	sd	ra,24(sp)
    80002666:	e822                	sd	s0,16(sp)
    80002668:	e426                	sd	s1,8(sp)
    8000266a:	e04a                	sd	s2,0(sp)
    8000266c:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000266e:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80002672:	1007f793          	andi	a5,a5,256
    80002676:	e7bd                	bnez	a5,800026e4 <usertrap+0x82>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002678:	00003797          	auipc	a5,0x3
    8000267c:	43878793          	addi	a5,a5,1080 # 80005ab0 <kernelvec>
    80002680:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002684:	fffff097          	auipc	ra,0xfffff
    80002688:	1c0080e7          	jalr	448(ra) # 80001844 <myproc>
    8000268c:	84aa                	mv	s1,a0
  p->tf->epc = r_sepc();
    8000268e:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002690:	14102773          	csrr	a4,sepc
    80002694:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002696:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    8000269a:	47a1                	li	a5,8
    8000269c:	06f71263          	bne	a4,a5,80002700 <usertrap+0x9e>
    if(p->killed)
    800026a0:	591c                	lw	a5,48(a0)
    800026a2:	eba9                	bnez	a5,800026f4 <usertrap+0x92>
    p->tf->epc += 4;
    800026a4:	6cb8                	ld	a4,88(s1)
    800026a6:	6f1c                	ld	a5,24(a4)
    800026a8:	0791                	addi	a5,a5,4
    800026aa:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sie" : "=r" (x) );
    800026ac:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE);
    800026b0:	2227e793          	ori	a5,a5,546
  asm volatile("csrw sie, %0" : : "r" (x));
    800026b4:	10479073          	csrw	sie,a5
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800026b8:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    800026bc:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800026c0:	10079073          	csrw	sstatus,a5
    syscall();
    800026c4:	00000097          	auipc	ra,0x0
    800026c8:	2e0080e7          	jalr	736(ra) # 800029a4 <syscall>
  if(p->killed)
    800026cc:	589c                	lw	a5,48(s1)
    800026ce:	ebc1                	bnez	a5,8000275e <usertrap+0xfc>
  usertrapret();
    800026d0:	00000097          	auipc	ra,0x0
    800026d4:	e22080e7          	jalr	-478(ra) # 800024f2 <usertrapret>
}
    800026d8:	60e2                	ld	ra,24(sp)
    800026da:	6442                	ld	s0,16(sp)
    800026dc:	64a2                	ld	s1,8(sp)
    800026de:	6902                	ld	s2,0(sp)
    800026e0:	6105                	addi	sp,sp,32
    800026e2:	8082                	ret
    panic("usertrap: not from user mode");
    800026e4:	00005517          	auipc	a0,0x5
    800026e8:	ccc50513          	addi	a0,a0,-820 # 800073b0 <userret+0x320>
    800026ec:	ffffe097          	auipc	ra,0xffffe
    800026f0:	e62080e7          	jalr	-414(ra) # 8000054e <panic>
      exit(-1);
    800026f4:	557d                	li	a0,-1
    800026f6:	fffff097          	auipc	ra,0xfffff
    800026fa:	7ae080e7          	jalr	1966(ra) # 80001ea4 <exit>
    800026fe:	b75d                	j	800026a4 <usertrap+0x42>
  } else if((which_dev = devintr()) != 0){
    80002700:	00000097          	auipc	ra,0x0
    80002704:	ed6080e7          	jalr	-298(ra) # 800025d6 <devintr>
    80002708:	892a                	mv	s2,a0
    8000270a:	c501                	beqz	a0,80002712 <usertrap+0xb0>
  if(p->killed)
    8000270c:	589c                	lw	a5,48(s1)
    8000270e:	c3a1                	beqz	a5,8000274e <usertrap+0xec>
    80002710:	a815                	j	80002744 <usertrap+0xe2>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002712:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    80002716:	5c90                	lw	a2,56(s1)
    80002718:	00005517          	auipc	a0,0x5
    8000271c:	cb850513          	addi	a0,a0,-840 # 800073d0 <userret+0x340>
    80002720:	ffffe097          	auipc	ra,0xffffe
    80002724:	e78080e7          	jalr	-392(ra) # 80000598 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002728:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    8000272c:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002730:	00005517          	auipc	a0,0x5
    80002734:	cd050513          	addi	a0,a0,-816 # 80007400 <userret+0x370>
    80002738:	ffffe097          	auipc	ra,0xffffe
    8000273c:	e60080e7          	jalr	-416(ra) # 80000598 <printf>
    p->killed = 1;
    80002740:	4785                	li	a5,1
    80002742:	d89c                	sw	a5,48(s1)
    exit(-1);
    80002744:	557d                	li	a0,-1
    80002746:	fffff097          	auipc	ra,0xfffff
    8000274a:	75e080e7          	jalr	1886(ra) # 80001ea4 <exit>
  if(which_dev == 2)
    8000274e:	4789                	li	a5,2
    80002750:	f8f910e3          	bne	s2,a5,800026d0 <usertrap+0x6e>
    yield();
    80002754:	00000097          	auipc	ra,0x0
    80002758:	85a080e7          	jalr	-1958(ra) # 80001fae <yield>
    8000275c:	bf95                	j	800026d0 <usertrap+0x6e>
  int which_dev = 0;
    8000275e:	4901                	li	s2,0
    80002760:	b7d5                	j	80002744 <usertrap+0xe2>

0000000080002762 <kerneltrap>:
{
    80002762:	7179                	addi	sp,sp,-48
    80002764:	f406                	sd	ra,40(sp)
    80002766:	f022                	sd	s0,32(sp)
    80002768:	ec26                	sd	s1,24(sp)
    8000276a:	e84a                	sd	s2,16(sp)
    8000276c:	e44e                	sd	s3,8(sp)
    8000276e:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002770:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002774:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002778:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    8000277c:	1004f793          	andi	a5,s1,256
    80002780:	cb85                	beqz	a5,800027b0 <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002782:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002786:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80002788:	ef85                	bnez	a5,800027c0 <kerneltrap+0x5e>
  if((which_dev = devintr()) == 0){
    8000278a:	00000097          	auipc	ra,0x0
    8000278e:	e4c080e7          	jalr	-436(ra) # 800025d6 <devintr>
    80002792:	cd1d                	beqz	a0,800027d0 <kerneltrap+0x6e>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002794:	4789                	li	a5,2
    80002796:	06f50a63          	beq	a0,a5,8000280a <kerneltrap+0xa8>
  asm volatile("csrw sepc, %0" : : "r" (x));
    8000279a:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000279e:	10049073          	csrw	sstatus,s1
}
    800027a2:	70a2                	ld	ra,40(sp)
    800027a4:	7402                	ld	s0,32(sp)
    800027a6:	64e2                	ld	s1,24(sp)
    800027a8:	6942                	ld	s2,16(sp)
    800027aa:	69a2                	ld	s3,8(sp)
    800027ac:	6145                	addi	sp,sp,48
    800027ae:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    800027b0:	00005517          	auipc	a0,0x5
    800027b4:	c7050513          	addi	a0,a0,-912 # 80007420 <userret+0x390>
    800027b8:	ffffe097          	auipc	ra,0xffffe
    800027bc:	d96080e7          	jalr	-618(ra) # 8000054e <panic>
    panic("kerneltrap: interrupts enabled");
    800027c0:	00005517          	auipc	a0,0x5
    800027c4:	c8850513          	addi	a0,a0,-888 # 80007448 <userret+0x3b8>
    800027c8:	ffffe097          	auipc	ra,0xffffe
    800027cc:	d86080e7          	jalr	-634(ra) # 8000054e <panic>
    printf("scause %p\n", scause);
    800027d0:	85ce                	mv	a1,s3
    800027d2:	00005517          	auipc	a0,0x5
    800027d6:	c9650513          	addi	a0,a0,-874 # 80007468 <userret+0x3d8>
    800027da:	ffffe097          	auipc	ra,0xffffe
    800027de:	dbe080e7          	jalr	-578(ra) # 80000598 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800027e2:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    800027e6:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    800027ea:	00005517          	auipc	a0,0x5
    800027ee:	c8e50513          	addi	a0,a0,-882 # 80007478 <userret+0x3e8>
    800027f2:	ffffe097          	auipc	ra,0xffffe
    800027f6:	da6080e7          	jalr	-602(ra) # 80000598 <printf>
    panic("kerneltrap");
    800027fa:	00005517          	auipc	a0,0x5
    800027fe:	c9650513          	addi	a0,a0,-874 # 80007490 <userret+0x400>
    80002802:	ffffe097          	auipc	ra,0xffffe
    80002806:	d4c080e7          	jalr	-692(ra) # 8000054e <panic>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    8000280a:	fffff097          	auipc	ra,0xfffff
    8000280e:	03a080e7          	jalr	58(ra) # 80001844 <myproc>
    80002812:	d541                	beqz	a0,8000279a <kerneltrap+0x38>
    80002814:	fffff097          	auipc	ra,0xfffff
    80002818:	030080e7          	jalr	48(ra) # 80001844 <myproc>
    8000281c:	4d18                	lw	a4,24(a0)
    8000281e:	478d                	li	a5,3
    80002820:	f6f71de3          	bne	a4,a5,8000279a <kerneltrap+0x38>
    yield();
    80002824:	fffff097          	auipc	ra,0xfffff
    80002828:	78a080e7          	jalr	1930(ra) # 80001fae <yield>
    8000282c:	b7bd                	j	8000279a <kerneltrap+0x38>

000000008000282e <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    8000282e:	1101                	addi	sp,sp,-32
    80002830:	ec06                	sd	ra,24(sp)
    80002832:	e822                	sd	s0,16(sp)
    80002834:	e426                	sd	s1,8(sp)
    80002836:	1000                	addi	s0,sp,32
    80002838:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    8000283a:	fffff097          	auipc	ra,0xfffff
    8000283e:	00a080e7          	jalr	10(ra) # 80001844 <myproc>
  switch (n) {
    80002842:	4795                	li	a5,5
    80002844:	0497e163          	bltu	a5,s1,80002886 <argraw+0x58>
    80002848:	048a                	slli	s1,s1,0x2
    8000284a:	00005717          	auipc	a4,0x5
    8000284e:	06e70713          	addi	a4,a4,110 # 800078b8 <states.1705+0x28>
    80002852:	94ba                	add	s1,s1,a4
    80002854:	409c                	lw	a5,0(s1)
    80002856:	97ba                	add	a5,a5,a4
    80002858:	8782                	jr	a5
  case 0:
    return p->tf->a0;
    8000285a:	6d3c                	ld	a5,88(a0)
    8000285c:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->tf->a5;
  }
  panic("argraw");
  return -1;
}
    8000285e:	60e2                	ld	ra,24(sp)
    80002860:	6442                	ld	s0,16(sp)
    80002862:	64a2                	ld	s1,8(sp)
    80002864:	6105                	addi	sp,sp,32
    80002866:	8082                	ret
    return p->tf->a1;
    80002868:	6d3c                	ld	a5,88(a0)
    8000286a:	7fa8                	ld	a0,120(a5)
    8000286c:	bfcd                	j	8000285e <argraw+0x30>
    return p->tf->a2;
    8000286e:	6d3c                	ld	a5,88(a0)
    80002870:	63c8                	ld	a0,128(a5)
    80002872:	b7f5                	j	8000285e <argraw+0x30>
    return p->tf->a3;
    80002874:	6d3c                	ld	a5,88(a0)
    80002876:	67c8                	ld	a0,136(a5)
    80002878:	b7dd                	j	8000285e <argraw+0x30>
    return p->tf->a4;
    8000287a:	6d3c                	ld	a5,88(a0)
    8000287c:	6bc8                	ld	a0,144(a5)
    8000287e:	b7c5                	j	8000285e <argraw+0x30>
    return p->tf->a5;
    80002880:	6d3c                	ld	a5,88(a0)
    80002882:	6fc8                	ld	a0,152(a5)
    80002884:	bfe9                	j	8000285e <argraw+0x30>
  panic("argraw");
    80002886:	00005517          	auipc	a0,0x5
    8000288a:	c1a50513          	addi	a0,a0,-998 # 800074a0 <userret+0x410>
    8000288e:	ffffe097          	auipc	ra,0xffffe
    80002892:	cc0080e7          	jalr	-832(ra) # 8000054e <panic>

0000000080002896 <fetchaddr>:
{
    80002896:	1101                	addi	sp,sp,-32
    80002898:	ec06                	sd	ra,24(sp)
    8000289a:	e822                	sd	s0,16(sp)
    8000289c:	e426                	sd	s1,8(sp)
    8000289e:	e04a                	sd	s2,0(sp)
    800028a0:	1000                	addi	s0,sp,32
    800028a2:	84aa                	mv	s1,a0
    800028a4:	892e                	mv	s2,a1
  struct proc *p = myproc();
    800028a6:	fffff097          	auipc	ra,0xfffff
    800028aa:	f9e080e7          	jalr	-98(ra) # 80001844 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz)
    800028ae:	653c                	ld	a5,72(a0)
    800028b0:	02f4f863          	bgeu	s1,a5,800028e0 <fetchaddr+0x4a>
    800028b4:	00848713          	addi	a4,s1,8
    800028b8:	02e7e663          	bltu	a5,a4,800028e4 <fetchaddr+0x4e>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    800028bc:	46a1                	li	a3,8
    800028be:	8626                	mv	a2,s1
    800028c0:	85ca                	mv	a1,s2
    800028c2:	6928                	ld	a0,80(a0)
    800028c4:	fffff097          	auipc	ra,0xfffff
    800028c8:	d00080e7          	jalr	-768(ra) # 800015c4 <copyin>
    800028cc:	00a03533          	snez	a0,a0
    800028d0:	40a00533          	neg	a0,a0
}
    800028d4:	60e2                	ld	ra,24(sp)
    800028d6:	6442                	ld	s0,16(sp)
    800028d8:	64a2                	ld	s1,8(sp)
    800028da:	6902                	ld	s2,0(sp)
    800028dc:	6105                	addi	sp,sp,32
    800028de:	8082                	ret
    return -1;
    800028e0:	557d                	li	a0,-1
    800028e2:	bfcd                	j	800028d4 <fetchaddr+0x3e>
    800028e4:	557d                	li	a0,-1
    800028e6:	b7fd                	j	800028d4 <fetchaddr+0x3e>

00000000800028e8 <fetchstr>:
{
    800028e8:	7179                	addi	sp,sp,-48
    800028ea:	f406                	sd	ra,40(sp)
    800028ec:	f022                	sd	s0,32(sp)
    800028ee:	ec26                	sd	s1,24(sp)
    800028f0:	e84a                	sd	s2,16(sp)
    800028f2:	e44e                	sd	s3,8(sp)
    800028f4:	1800                	addi	s0,sp,48
    800028f6:	892a                	mv	s2,a0
    800028f8:	84ae                	mv	s1,a1
    800028fa:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    800028fc:	fffff097          	auipc	ra,0xfffff
    80002900:	f48080e7          	jalr	-184(ra) # 80001844 <myproc>
  int err = copyinstr(p->pagetable, buf, addr, max);
    80002904:	86ce                	mv	a3,s3
    80002906:	864a                	mv	a2,s2
    80002908:	85a6                	mv	a1,s1
    8000290a:	6928                	ld	a0,80(a0)
    8000290c:	fffff097          	auipc	ra,0xfffff
    80002910:	d44080e7          	jalr	-700(ra) # 80001650 <copyinstr>
  if(err < 0)
    80002914:	00054763          	bltz	a0,80002922 <fetchstr+0x3a>
  return strlen(buf);
    80002918:	8526                	mv	a0,s1
    8000291a:	ffffe097          	auipc	ra,0xffffe
    8000291e:	3dc080e7          	jalr	988(ra) # 80000cf6 <strlen>
}
    80002922:	70a2                	ld	ra,40(sp)
    80002924:	7402                	ld	s0,32(sp)
    80002926:	64e2                	ld	s1,24(sp)
    80002928:	6942                	ld	s2,16(sp)
    8000292a:	69a2                	ld	s3,8(sp)
    8000292c:	6145                	addi	sp,sp,48
    8000292e:	8082                	ret

0000000080002930 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
    80002930:	1101                	addi	sp,sp,-32
    80002932:	ec06                	sd	ra,24(sp)
    80002934:	e822                	sd	s0,16(sp)
    80002936:	e426                	sd	s1,8(sp)
    80002938:	1000                	addi	s0,sp,32
    8000293a:	84ae                	mv	s1,a1
  *ip = argraw(n);
    8000293c:	00000097          	auipc	ra,0x0
    80002940:	ef2080e7          	jalr	-270(ra) # 8000282e <argraw>
    80002944:	c088                	sw	a0,0(s1)
  return 0;
}
    80002946:	4501                	li	a0,0
    80002948:	60e2                	ld	ra,24(sp)
    8000294a:	6442                	ld	s0,16(sp)
    8000294c:	64a2                	ld	s1,8(sp)
    8000294e:	6105                	addi	sp,sp,32
    80002950:	8082                	ret

0000000080002952 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
int
argaddr(int n, uint64 *ip)
{
    80002952:	1101                	addi	sp,sp,-32
    80002954:	ec06                	sd	ra,24(sp)
    80002956:	e822                	sd	s0,16(sp)
    80002958:	e426                	sd	s1,8(sp)
    8000295a:	1000                	addi	s0,sp,32
    8000295c:	84ae                	mv	s1,a1
  *ip = argraw(n);
    8000295e:	00000097          	auipc	ra,0x0
    80002962:	ed0080e7          	jalr	-304(ra) # 8000282e <argraw>
    80002966:	e088                	sd	a0,0(s1)
  return 0;
}
    80002968:	4501                	li	a0,0
    8000296a:	60e2                	ld	ra,24(sp)
    8000296c:	6442                	ld	s0,16(sp)
    8000296e:	64a2                	ld	s1,8(sp)
    80002970:	6105                	addi	sp,sp,32
    80002972:	8082                	ret

0000000080002974 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002974:	1101                	addi	sp,sp,-32
    80002976:	ec06                	sd	ra,24(sp)
    80002978:	e822                	sd	s0,16(sp)
    8000297a:	e426                	sd	s1,8(sp)
    8000297c:	e04a                	sd	s2,0(sp)
    8000297e:	1000                	addi	s0,sp,32
    80002980:	84ae                	mv	s1,a1
    80002982:	8932                	mv	s2,a2
  *ip = argraw(n);
    80002984:	00000097          	auipc	ra,0x0
    80002988:	eaa080e7          	jalr	-342(ra) # 8000282e <argraw>
  uint64 addr;
  if(argaddr(n, &addr) < 0)
    return -1;
  return fetchstr(addr, buf, max);
    8000298c:	864a                	mv	a2,s2
    8000298e:	85a6                	mv	a1,s1
    80002990:	00000097          	auipc	ra,0x0
    80002994:	f58080e7          	jalr	-168(ra) # 800028e8 <fetchstr>
}
    80002998:	60e2                	ld	ra,24(sp)
    8000299a:	6442                	ld	s0,16(sp)
    8000299c:	64a2                	ld	s1,8(sp)
    8000299e:	6902                	ld	s2,0(sp)
    800029a0:	6105                	addi	sp,sp,32
    800029a2:	8082                	ret

00000000800029a4 <syscall>:
[SYS_ps]      sys_ps,
};

void
syscall(void)
{
    800029a4:	1101                	addi	sp,sp,-32
    800029a6:	ec06                	sd	ra,24(sp)
    800029a8:	e822                	sd	s0,16(sp)
    800029aa:	e426                	sd	s1,8(sp)
    800029ac:	e04a                	sd	s2,0(sp)
    800029ae:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    800029b0:	fffff097          	auipc	ra,0xfffff
    800029b4:	e94080e7          	jalr	-364(ra) # 80001844 <myproc>
    800029b8:	84aa                	mv	s1,a0

  num = p->tf->a7;
    800029ba:	05853903          	ld	s2,88(a0)
    800029be:	0a893783          	ld	a5,168(s2)
    800029c2:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    800029c6:	37fd                	addiw	a5,a5,-1
    800029c8:	4759                	li	a4,22
    800029ca:	00f76f63          	bltu	a4,a5,800029e8 <syscall+0x44>
    800029ce:	00369713          	slli	a4,a3,0x3
    800029d2:	00005797          	auipc	a5,0x5
    800029d6:	efe78793          	addi	a5,a5,-258 # 800078d0 <syscalls>
    800029da:	97ba                	add	a5,a5,a4
    800029dc:	639c                	ld	a5,0(a5)
    800029de:	c789                	beqz	a5,800029e8 <syscall+0x44>
    p->tf->a0 = syscalls[num]();
    800029e0:	9782                	jalr	a5
    800029e2:	06a93823          	sd	a0,112(s2)
    800029e6:	a839                	j	80002a04 <syscall+0x60>
  } else {
    printf("%d %s: unknown sys call %d\n",
    800029e8:	15848613          	addi	a2,s1,344
    800029ec:	5c8c                	lw	a1,56(s1)
    800029ee:	00005517          	auipc	a0,0x5
    800029f2:	aba50513          	addi	a0,a0,-1350 # 800074a8 <userret+0x418>
    800029f6:	ffffe097          	auipc	ra,0xffffe
    800029fa:	ba2080e7          	jalr	-1118(ra) # 80000598 <printf>
            p->pid, p->name, num);
    p->tf->a0 = -1;
    800029fe:	6cbc                	ld	a5,88(s1)
    80002a00:	577d                	li	a4,-1
    80002a02:	fbb8                	sd	a4,112(a5)
  }
}
    80002a04:	60e2                	ld	ra,24(sp)
    80002a06:	6442                	ld	s0,16(sp)
    80002a08:	64a2                	ld	s1,8(sp)
    80002a0a:	6902                	ld	s2,0(sp)
    80002a0c:	6105                	addi	sp,sp,32
    80002a0e:	8082                	ret

0000000080002a10 <sys_exit>:
#include "proc.h"
#include "pinfo.h"

uint64
sys_exit(void)
{
    80002a10:	1101                	addi	sp,sp,-32
    80002a12:	ec06                	sd	ra,24(sp)
    80002a14:	e822                	sd	s0,16(sp)
    80002a16:	1000                	addi	s0,sp,32
  int n;
  if(argint(0, &n) < 0)
    80002a18:	fec40593          	addi	a1,s0,-20
    80002a1c:	4501                	li	a0,0
    80002a1e:	00000097          	auipc	ra,0x0
    80002a22:	f12080e7          	jalr	-238(ra) # 80002930 <argint>
    return -1;
    80002a26:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    80002a28:	00054963          	bltz	a0,80002a3a <sys_exit+0x2a>
  exit(n);
    80002a2c:	fec42503          	lw	a0,-20(s0)
    80002a30:	fffff097          	auipc	ra,0xfffff
    80002a34:	474080e7          	jalr	1140(ra) # 80001ea4 <exit>
  return 0;  // not reached
    80002a38:	4781                	li	a5,0
}
    80002a3a:	853e                	mv	a0,a5
    80002a3c:	60e2                	ld	ra,24(sp)
    80002a3e:	6442                	ld	s0,16(sp)
    80002a40:	6105                	addi	sp,sp,32
    80002a42:	8082                	ret

0000000080002a44 <sys_getpid>:

uint64
sys_getpid(void)
{
    80002a44:	1141                	addi	sp,sp,-16
    80002a46:	e406                	sd	ra,8(sp)
    80002a48:	e022                	sd	s0,0(sp)
    80002a4a:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80002a4c:	fffff097          	auipc	ra,0xfffff
    80002a50:	df8080e7          	jalr	-520(ra) # 80001844 <myproc>
}
    80002a54:	5d08                	lw	a0,56(a0)
    80002a56:	60a2                	ld	ra,8(sp)
    80002a58:	6402                	ld	s0,0(sp)
    80002a5a:	0141                	addi	sp,sp,16
    80002a5c:	8082                	ret

0000000080002a5e <sys_fork>:

uint64
sys_fork(void)
{
    80002a5e:	1141                	addi	sp,sp,-16
    80002a60:	e406                	sd	ra,8(sp)
    80002a62:	e022                	sd	s0,0(sp)
    80002a64:	0800                	addi	s0,sp,16
  return fork();
    80002a66:	fffff097          	auipc	ra,0xfffff
    80002a6a:	14c080e7          	jalr	332(ra) # 80001bb2 <fork>
}
    80002a6e:	60a2                	ld	ra,8(sp)
    80002a70:	6402                	ld	s0,0(sp)
    80002a72:	0141                	addi	sp,sp,16
    80002a74:	8082                	ret

0000000080002a76 <sys_wait>:

uint64
sys_wait(void)
{
    80002a76:	1101                	addi	sp,sp,-32
    80002a78:	ec06                	sd	ra,24(sp)
    80002a7a:	e822                	sd	s0,16(sp)
    80002a7c:	1000                	addi	s0,sp,32
  uint64 p;
  if(argaddr(0, &p) < 0)
    80002a7e:	fe840593          	addi	a1,s0,-24
    80002a82:	4501                	li	a0,0
    80002a84:	00000097          	auipc	ra,0x0
    80002a88:	ece080e7          	jalr	-306(ra) # 80002952 <argaddr>
    80002a8c:	87aa                	mv	a5,a0
    return -1;
    80002a8e:	557d                	li	a0,-1
  if(argaddr(0, &p) < 0)
    80002a90:	0007c863          	bltz	a5,80002aa0 <sys_wait+0x2a>
  return wait(p);
    80002a94:	fe843503          	ld	a0,-24(s0)
    80002a98:	fffff097          	auipc	ra,0xfffff
    80002a9c:	5d0080e7          	jalr	1488(ra) # 80002068 <wait>
}
    80002aa0:	60e2                	ld	ra,24(sp)
    80002aa2:	6442                	ld	s0,16(sp)
    80002aa4:	6105                	addi	sp,sp,32
    80002aa6:	8082                	ret

0000000080002aa8 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002aa8:	7179                	addi	sp,sp,-48
    80002aaa:	f406                	sd	ra,40(sp)
    80002aac:	f022                	sd	s0,32(sp)
    80002aae:	ec26                	sd	s1,24(sp)
    80002ab0:	1800                	addi	s0,sp,48
  int addr;
  int n;

  if(argint(0, &n) < 0)
    80002ab2:	fdc40593          	addi	a1,s0,-36
    80002ab6:	4501                	li	a0,0
    80002ab8:	00000097          	auipc	ra,0x0
    80002abc:	e78080e7          	jalr	-392(ra) # 80002930 <argint>
    80002ac0:	87aa                	mv	a5,a0
    return -1;
    80002ac2:	557d                	li	a0,-1
  if(argint(0, &n) < 0)
    80002ac4:	0207c063          	bltz	a5,80002ae4 <sys_sbrk+0x3c>
  addr = myproc()->sz;
    80002ac8:	fffff097          	auipc	ra,0xfffff
    80002acc:	d7c080e7          	jalr	-644(ra) # 80001844 <myproc>
    80002ad0:	4524                	lw	s1,72(a0)
  if(growproc(n) < 0)
    80002ad2:	fdc42503          	lw	a0,-36(s0)
    80002ad6:	fffff097          	auipc	ra,0xfffff
    80002ada:	068080e7          	jalr	104(ra) # 80001b3e <growproc>
    80002ade:	00054863          	bltz	a0,80002aee <sys_sbrk+0x46>
    return -1;
  return addr;
    80002ae2:	8526                	mv	a0,s1
}
    80002ae4:	70a2                	ld	ra,40(sp)
    80002ae6:	7402                	ld	s0,32(sp)
    80002ae8:	64e2                	ld	s1,24(sp)
    80002aea:	6145                	addi	sp,sp,48
    80002aec:	8082                	ret
    return -1;
    80002aee:	557d                	li	a0,-1
    80002af0:	bfd5                	j	80002ae4 <sys_sbrk+0x3c>

0000000080002af2 <sys_sleep>:

uint64
sys_sleep(void)
{
    80002af2:	7139                	addi	sp,sp,-64
    80002af4:	fc06                	sd	ra,56(sp)
    80002af6:	f822                	sd	s0,48(sp)
    80002af8:	f426                	sd	s1,40(sp)
    80002afa:	f04a                	sd	s2,32(sp)
    80002afc:	ec4e                	sd	s3,24(sp)
    80002afe:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
    80002b00:	fcc40593          	addi	a1,s0,-52
    80002b04:	4501                	li	a0,0
    80002b06:	00000097          	auipc	ra,0x0
    80002b0a:	e2a080e7          	jalr	-470(ra) # 80002930 <argint>
    return -1;
    80002b0e:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    80002b10:	06054563          	bltz	a0,80002b7a <sys_sleep+0x88>
  acquire(&tickslock);
    80002b14:	00015517          	auipc	a0,0x15
    80002b18:	dec50513          	addi	a0,a0,-532 # 80017900 <tickslock>
    80002b1c:	ffffe097          	auipc	ra,0xffffe
    80002b20:	fb6080e7          	jalr	-74(ra) # 80000ad2 <acquire>
  ticks0 = ticks;
    80002b24:	00023917          	auipc	s2,0x23
    80002b28:	4f492903          	lw	s2,1268(s2) # 80026018 <ticks>
  while(ticks - ticks0 < n){
    80002b2c:	fcc42783          	lw	a5,-52(s0)
    80002b30:	cf85                	beqz	a5,80002b68 <sys_sleep+0x76>
    if(myproc()->killed){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80002b32:	00015997          	auipc	s3,0x15
    80002b36:	dce98993          	addi	s3,s3,-562 # 80017900 <tickslock>
    80002b3a:	00023497          	auipc	s1,0x23
    80002b3e:	4de48493          	addi	s1,s1,1246 # 80026018 <ticks>
    if(myproc()->killed){
    80002b42:	fffff097          	auipc	ra,0xfffff
    80002b46:	d02080e7          	jalr	-766(ra) # 80001844 <myproc>
    80002b4a:	591c                	lw	a5,48(a0)
    80002b4c:	ef9d                	bnez	a5,80002b8a <sys_sleep+0x98>
    sleep(&ticks, &tickslock);
    80002b4e:	85ce                	mv	a1,s3
    80002b50:	8526                	mv	a0,s1
    80002b52:	fffff097          	auipc	ra,0xfffff
    80002b56:	498080e7          	jalr	1176(ra) # 80001fea <sleep>
  while(ticks - ticks0 < n){
    80002b5a:	409c                	lw	a5,0(s1)
    80002b5c:	412787bb          	subw	a5,a5,s2
    80002b60:	fcc42703          	lw	a4,-52(s0)
    80002b64:	fce7efe3          	bltu	a5,a4,80002b42 <sys_sleep+0x50>
  }
  release(&tickslock);
    80002b68:	00015517          	auipc	a0,0x15
    80002b6c:	d9850513          	addi	a0,a0,-616 # 80017900 <tickslock>
    80002b70:	ffffe097          	auipc	ra,0xffffe
    80002b74:	fb6080e7          	jalr	-74(ra) # 80000b26 <release>
  return 0;
    80002b78:	4781                	li	a5,0
}
    80002b7a:	853e                	mv	a0,a5
    80002b7c:	70e2                	ld	ra,56(sp)
    80002b7e:	7442                	ld	s0,48(sp)
    80002b80:	74a2                	ld	s1,40(sp)
    80002b82:	7902                	ld	s2,32(sp)
    80002b84:	69e2                	ld	s3,24(sp)
    80002b86:	6121                	addi	sp,sp,64
    80002b88:	8082                	ret
      release(&tickslock);
    80002b8a:	00015517          	auipc	a0,0x15
    80002b8e:	d7650513          	addi	a0,a0,-650 # 80017900 <tickslock>
    80002b92:	ffffe097          	auipc	ra,0xffffe
    80002b96:	f94080e7          	jalr	-108(ra) # 80000b26 <release>
      return -1;
    80002b9a:	57fd                	li	a5,-1
    80002b9c:	bff9                	j	80002b7a <sys_sleep+0x88>

0000000080002b9e <sys_kill>:

uint64
sys_kill(void)
{
    80002b9e:	1101                	addi	sp,sp,-32
    80002ba0:	ec06                	sd	ra,24(sp)
    80002ba2:	e822                	sd	s0,16(sp)
    80002ba4:	1000                	addi	s0,sp,32
  int pid;

  if(argint(0, &pid) < 0)
    80002ba6:	fec40593          	addi	a1,s0,-20
    80002baa:	4501                	li	a0,0
    80002bac:	00000097          	auipc	ra,0x0
    80002bb0:	d84080e7          	jalr	-636(ra) # 80002930 <argint>
    80002bb4:	87aa                	mv	a5,a0
    return -1;
    80002bb6:	557d                	li	a0,-1
  if(argint(0, &pid) < 0)
    80002bb8:	0007c863          	bltz	a5,80002bc8 <sys_kill+0x2a>
  return kill(pid);
    80002bbc:	fec42503          	lw	a0,-20(s0)
    80002bc0:	fffff097          	auipc	ra,0xfffff
    80002bc4:	61a080e7          	jalr	1562(ra) # 800021da <kill>
}
    80002bc8:	60e2                	ld	ra,24(sp)
    80002bca:	6442                	ld	s0,16(sp)
    80002bcc:	6105                	addi	sp,sp,32
    80002bce:	8082                	ret

0000000080002bd0 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80002bd0:	1101                	addi	sp,sp,-32
    80002bd2:	ec06                	sd	ra,24(sp)
    80002bd4:	e822                	sd	s0,16(sp)
    80002bd6:	e426                	sd	s1,8(sp)
    80002bd8:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80002bda:	00015517          	auipc	a0,0x15
    80002bde:	d2650513          	addi	a0,a0,-730 # 80017900 <tickslock>
    80002be2:	ffffe097          	auipc	ra,0xffffe
    80002be6:	ef0080e7          	jalr	-272(ra) # 80000ad2 <acquire>
  xticks = ticks;
    80002bea:	00023497          	auipc	s1,0x23
    80002bee:	42e4a483          	lw	s1,1070(s1) # 80026018 <ticks>
  release(&tickslock);
    80002bf2:	00015517          	auipc	a0,0x15
    80002bf6:	d0e50513          	addi	a0,a0,-754 # 80017900 <tickslock>
    80002bfa:	ffffe097          	auipc	ra,0xffffe
    80002bfe:	f2c080e7          	jalr	-212(ra) # 80000b26 <release>
  return xticks;
}
    80002c02:	02049513          	slli	a0,s1,0x20
    80002c06:	9101                	srli	a0,a0,0x20
    80002c08:	60e2                	ld	ra,24(sp)
    80002c0a:	6442                	ld	s0,16(sp)
    80002c0c:	64a2                	ld	s1,8(sp)
    80002c0e:	6105                	addi	sp,sp,32
    80002c10:	8082                	ret

0000000080002c12 <sys_traceon>:

uint64
sys_traceon(void)
{
    80002c12:	1141                	addi	sp,sp,-16
    80002c14:	e406                	sd	ra,8(sp)
    80002c16:	e022                	sd	s0,0(sp)
    80002c18:	0800                	addi	s0,sp,16
    traceon();
    80002c1a:	fffff097          	auipc	ra,0xfffff
    80002c1e:	78c080e7          	jalr	1932(ra) # 800023a6 <traceon>
    return 0;
}
    80002c22:	4501                	li	a0,0
    80002c24:	60a2                	ld	ra,8(sp)
    80002c26:	6402                	ld	s0,0(sp)
    80002c28:	0141                	addi	sp,sp,16
    80002c2a:	8082                	ret

0000000080002c2c <sys_ps>:

uint64
sys_ps(void)
{
    80002c2c:	1101                	addi	sp,sp,-32
    80002c2e:	ec06                	sd	ra,24(sp)
    80002c30:	e822                	sd	s0,16(sp)
    80002c32:	1000                	addi	s0,sp,32
    struct pinfo *pi;

    if(myproc()->tracing) {
    80002c34:	fffff097          	auipc	ra,0xfffff
    80002c38:	c10080e7          	jalr	-1008(ra) # 80001844 <myproc>
    80002c3c:	16852783          	lw	a5,360(a0)
    80002c40:	efb9                	bnez	a5,80002c9e <sys_ps+0x72>
        printf("[%d]ps", myproc()->pid);
    }

    printf("before get addr");
    80002c42:	00005517          	auipc	a0,0x5
    80002c46:	88e50513          	addi	a0,a0,-1906 # 800074d0 <userret+0x440>
    80002c4a:	ffffe097          	auipc	ra,0xffffe
    80002c4e:	94e080e7          	jalr	-1714(ra) # 80000598 <printf>
    if(argaddr(0, (void*)&pi) < 0) {
    80002c52:	fe840593          	addi	a1,s0,-24
    80002c56:	4501                	li	a0,0
    80002c58:	00000097          	auipc	ra,0x0
    80002c5c:	cfa080e7          	jalr	-774(ra) # 80002952 <argaddr>
	return -1;
    80002c60:	57fd                	li	a5,-1
    if(argaddr(0, (void*)&pi) < 0) {
    80002c62:	02054963          	bltz	a0,80002c94 <sys_ps+0x68>
    }

    printf("before kps");
    80002c66:	00005517          	auipc	a0,0x5
    80002c6a:	87a50513          	addi	a0,a0,-1926 # 800074e0 <userret+0x450>
    80002c6e:	ffffe097          	auipc	ra,0xffffe
    80002c72:	92a080e7          	jalr	-1750(ra) # 80000598 <printf>
    kps(pi);
    80002c76:	fe843503          	ld	a0,-24(s0)
    80002c7a:	fffff097          	auipc	ra,0xfffff
    80002c7e:	74a080e7          	jalr	1866(ra) # 800023c4 <kps>
    printf("after kps");
    80002c82:	00005517          	auipc	a0,0x5
    80002c86:	86e50513          	addi	a0,a0,-1938 # 800074f0 <userret+0x460>
    80002c8a:	ffffe097          	auipc	ra,0xffffe
    80002c8e:	90e080e7          	jalr	-1778(ra) # 80000598 <printf>
    return 0;
    80002c92:	4781                	li	a5,0
}
    80002c94:	853e                	mv	a0,a5
    80002c96:	60e2                	ld	ra,24(sp)
    80002c98:	6442                	ld	s0,16(sp)
    80002c9a:	6105                	addi	sp,sp,32
    80002c9c:	8082                	ret
        printf("[%d]ps", myproc()->pid);
    80002c9e:	fffff097          	auipc	ra,0xfffff
    80002ca2:	ba6080e7          	jalr	-1114(ra) # 80001844 <myproc>
    80002ca6:	5d0c                	lw	a1,56(a0)
    80002ca8:	00005517          	auipc	a0,0x5
    80002cac:	82050513          	addi	a0,a0,-2016 # 800074c8 <userret+0x438>
    80002cb0:	ffffe097          	auipc	ra,0xffffe
    80002cb4:	8e8080e7          	jalr	-1816(ra) # 80000598 <printf>
    80002cb8:	b769                	j	80002c42 <sys_ps+0x16>

0000000080002cba <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80002cba:	7179                	addi	sp,sp,-48
    80002cbc:	f406                	sd	ra,40(sp)
    80002cbe:	f022                	sd	s0,32(sp)
    80002cc0:	ec26                	sd	s1,24(sp)
    80002cc2:	e84a                	sd	s2,16(sp)
    80002cc4:	e44e                	sd	s3,8(sp)
    80002cc6:	e052                	sd	s4,0(sp)
    80002cc8:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80002cca:	00005597          	auipc	a1,0x5
    80002cce:	83658593          	addi	a1,a1,-1994 # 80007500 <userret+0x470>
    80002cd2:	00015517          	auipc	a0,0x15
    80002cd6:	c4650513          	addi	a0,a0,-954 # 80017918 <bcache>
    80002cda:	ffffe097          	auipc	ra,0xffffe
    80002cde:	ce6080e7          	jalr	-794(ra) # 800009c0 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80002ce2:	0001d797          	auipc	a5,0x1d
    80002ce6:	c3678793          	addi	a5,a5,-970 # 8001f918 <bcache+0x8000>
    80002cea:	0001d717          	auipc	a4,0x1d
    80002cee:	f8670713          	addi	a4,a4,-122 # 8001fc70 <bcache+0x8358>
    80002cf2:	3ae7b023          	sd	a4,928(a5)
  bcache.head.next = &bcache.head;
    80002cf6:	3ae7b423          	sd	a4,936(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002cfa:	00015497          	auipc	s1,0x15
    80002cfe:	c3648493          	addi	s1,s1,-970 # 80017930 <bcache+0x18>
    b->next = bcache.head.next;
    80002d02:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80002d04:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80002d06:	00005a17          	auipc	s4,0x5
    80002d0a:	802a0a13          	addi	s4,s4,-2046 # 80007508 <userret+0x478>
    b->next = bcache.head.next;
    80002d0e:	3a893783          	ld	a5,936(s2)
    80002d12:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80002d14:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80002d18:	85d2                	mv	a1,s4
    80002d1a:	01048513          	addi	a0,s1,16
    80002d1e:	00001097          	auipc	ra,0x1
    80002d22:	486080e7          	jalr	1158(ra) # 800041a4 <initsleeplock>
    bcache.head.next->prev = b;
    80002d26:	3a893783          	ld	a5,936(s2)
    80002d2a:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80002d2c:	3a993423          	sd	s1,936(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002d30:	46048493          	addi	s1,s1,1120
    80002d34:	fd349de3          	bne	s1,s3,80002d0e <binit+0x54>
  }
}
    80002d38:	70a2                	ld	ra,40(sp)
    80002d3a:	7402                	ld	s0,32(sp)
    80002d3c:	64e2                	ld	s1,24(sp)
    80002d3e:	6942                	ld	s2,16(sp)
    80002d40:	69a2                	ld	s3,8(sp)
    80002d42:	6a02                	ld	s4,0(sp)
    80002d44:	6145                	addi	sp,sp,48
    80002d46:	8082                	ret

0000000080002d48 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80002d48:	7179                	addi	sp,sp,-48
    80002d4a:	f406                	sd	ra,40(sp)
    80002d4c:	f022                	sd	s0,32(sp)
    80002d4e:	ec26                	sd	s1,24(sp)
    80002d50:	e84a                	sd	s2,16(sp)
    80002d52:	e44e                	sd	s3,8(sp)
    80002d54:	1800                	addi	s0,sp,48
    80002d56:	89aa                	mv	s3,a0
    80002d58:	892e                	mv	s2,a1
  acquire(&bcache.lock);
    80002d5a:	00015517          	auipc	a0,0x15
    80002d5e:	bbe50513          	addi	a0,a0,-1090 # 80017918 <bcache>
    80002d62:	ffffe097          	auipc	ra,0xffffe
    80002d66:	d70080e7          	jalr	-656(ra) # 80000ad2 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80002d6a:	0001d497          	auipc	s1,0x1d
    80002d6e:	f564b483          	ld	s1,-170(s1) # 8001fcc0 <bcache+0x83a8>
    80002d72:	0001d797          	auipc	a5,0x1d
    80002d76:	efe78793          	addi	a5,a5,-258 # 8001fc70 <bcache+0x8358>
    80002d7a:	02f48f63          	beq	s1,a5,80002db8 <bread+0x70>
    80002d7e:	873e                	mv	a4,a5
    80002d80:	a021                	j	80002d88 <bread+0x40>
    80002d82:	68a4                	ld	s1,80(s1)
    80002d84:	02e48a63          	beq	s1,a4,80002db8 <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    80002d88:	449c                	lw	a5,8(s1)
    80002d8a:	ff379ce3          	bne	a5,s3,80002d82 <bread+0x3a>
    80002d8e:	44dc                	lw	a5,12(s1)
    80002d90:	ff2799e3          	bne	a5,s2,80002d82 <bread+0x3a>
      b->refcnt++;
    80002d94:	40bc                	lw	a5,64(s1)
    80002d96:	2785                	addiw	a5,a5,1
    80002d98:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002d9a:	00015517          	auipc	a0,0x15
    80002d9e:	b7e50513          	addi	a0,a0,-1154 # 80017918 <bcache>
    80002da2:	ffffe097          	auipc	ra,0xffffe
    80002da6:	d84080e7          	jalr	-636(ra) # 80000b26 <release>
      acquiresleep(&b->lock);
    80002daa:	01048513          	addi	a0,s1,16
    80002dae:	00001097          	auipc	ra,0x1
    80002db2:	430080e7          	jalr	1072(ra) # 800041de <acquiresleep>
      return b;
    80002db6:	a8b9                	j	80002e14 <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002db8:	0001d497          	auipc	s1,0x1d
    80002dbc:	f004b483          	ld	s1,-256(s1) # 8001fcb8 <bcache+0x83a0>
    80002dc0:	0001d797          	auipc	a5,0x1d
    80002dc4:	eb078793          	addi	a5,a5,-336 # 8001fc70 <bcache+0x8358>
    80002dc8:	00f48863          	beq	s1,a5,80002dd8 <bread+0x90>
    80002dcc:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80002dce:	40bc                	lw	a5,64(s1)
    80002dd0:	cf81                	beqz	a5,80002de8 <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002dd2:	64a4                	ld	s1,72(s1)
    80002dd4:	fee49de3          	bne	s1,a4,80002dce <bread+0x86>
  panic("bget: no buffers");
    80002dd8:	00004517          	auipc	a0,0x4
    80002ddc:	73850513          	addi	a0,a0,1848 # 80007510 <userret+0x480>
    80002de0:	ffffd097          	auipc	ra,0xffffd
    80002de4:	76e080e7          	jalr	1902(ra) # 8000054e <panic>
      b->dev = dev;
    80002de8:	0134a423          	sw	s3,8(s1)
      b->blockno = blockno;
    80002dec:	0124a623          	sw	s2,12(s1)
      b->valid = 0;
    80002df0:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80002df4:	4785                	li	a5,1
    80002df6:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002df8:	00015517          	auipc	a0,0x15
    80002dfc:	b2050513          	addi	a0,a0,-1248 # 80017918 <bcache>
    80002e00:	ffffe097          	auipc	ra,0xffffe
    80002e04:	d26080e7          	jalr	-730(ra) # 80000b26 <release>
      acquiresleep(&b->lock);
    80002e08:	01048513          	addi	a0,s1,16
    80002e0c:	00001097          	auipc	ra,0x1
    80002e10:	3d2080e7          	jalr	978(ra) # 800041de <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80002e14:	409c                	lw	a5,0(s1)
    80002e16:	cb89                	beqz	a5,80002e28 <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80002e18:	8526                	mv	a0,s1
    80002e1a:	70a2                	ld	ra,40(sp)
    80002e1c:	7402                	ld	s0,32(sp)
    80002e1e:	64e2                	ld	s1,24(sp)
    80002e20:	6942                	ld	s2,16(sp)
    80002e22:	69a2                	ld	s3,8(sp)
    80002e24:	6145                	addi	sp,sp,48
    80002e26:	8082                	ret
    virtio_disk_rw(b, 0);
    80002e28:	4581                	li	a1,0
    80002e2a:	8526                	mv	a0,s1
    80002e2c:	00003097          	auipc	ra,0x3
    80002e30:	fb2080e7          	jalr	-78(ra) # 80005dde <virtio_disk_rw>
    b->valid = 1;
    80002e34:	4785                	li	a5,1
    80002e36:	c09c                	sw	a5,0(s1)
  return b;
    80002e38:	b7c5                	j	80002e18 <bread+0xd0>

0000000080002e3a <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    80002e3a:	1101                	addi	sp,sp,-32
    80002e3c:	ec06                	sd	ra,24(sp)
    80002e3e:	e822                	sd	s0,16(sp)
    80002e40:	e426                	sd	s1,8(sp)
    80002e42:	1000                	addi	s0,sp,32
    80002e44:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80002e46:	0541                	addi	a0,a0,16
    80002e48:	00001097          	auipc	ra,0x1
    80002e4c:	430080e7          	jalr	1072(ra) # 80004278 <holdingsleep>
    80002e50:	cd01                	beqz	a0,80002e68 <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80002e52:	4585                	li	a1,1
    80002e54:	8526                	mv	a0,s1
    80002e56:	00003097          	auipc	ra,0x3
    80002e5a:	f88080e7          	jalr	-120(ra) # 80005dde <virtio_disk_rw>
}
    80002e5e:	60e2                	ld	ra,24(sp)
    80002e60:	6442                	ld	s0,16(sp)
    80002e62:	64a2                	ld	s1,8(sp)
    80002e64:	6105                	addi	sp,sp,32
    80002e66:	8082                	ret
    panic("bwrite");
    80002e68:	00004517          	auipc	a0,0x4
    80002e6c:	6c050513          	addi	a0,a0,1728 # 80007528 <userret+0x498>
    80002e70:	ffffd097          	auipc	ra,0xffffd
    80002e74:	6de080e7          	jalr	1758(ra) # 8000054e <panic>

0000000080002e78 <brelse>:

// Release a locked buffer.
// Move to the head of the MRU list.
void
brelse(struct buf *b)
{
    80002e78:	1101                	addi	sp,sp,-32
    80002e7a:	ec06                	sd	ra,24(sp)
    80002e7c:	e822                	sd	s0,16(sp)
    80002e7e:	e426                	sd	s1,8(sp)
    80002e80:	e04a                	sd	s2,0(sp)
    80002e82:	1000                	addi	s0,sp,32
    80002e84:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80002e86:	01050913          	addi	s2,a0,16
    80002e8a:	854a                	mv	a0,s2
    80002e8c:	00001097          	auipc	ra,0x1
    80002e90:	3ec080e7          	jalr	1004(ra) # 80004278 <holdingsleep>
    80002e94:	c92d                	beqz	a0,80002f06 <brelse+0x8e>
    panic("brelse");

  releasesleep(&b->lock);
    80002e96:	854a                	mv	a0,s2
    80002e98:	00001097          	auipc	ra,0x1
    80002e9c:	39c080e7          	jalr	924(ra) # 80004234 <releasesleep>

  acquire(&bcache.lock);
    80002ea0:	00015517          	auipc	a0,0x15
    80002ea4:	a7850513          	addi	a0,a0,-1416 # 80017918 <bcache>
    80002ea8:	ffffe097          	auipc	ra,0xffffe
    80002eac:	c2a080e7          	jalr	-982(ra) # 80000ad2 <acquire>
  b->refcnt--;
    80002eb0:	40bc                	lw	a5,64(s1)
    80002eb2:	37fd                	addiw	a5,a5,-1
    80002eb4:	0007871b          	sext.w	a4,a5
    80002eb8:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80002eba:	eb05                	bnez	a4,80002eea <brelse+0x72>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80002ebc:	68bc                	ld	a5,80(s1)
    80002ebe:	64b8                	ld	a4,72(s1)
    80002ec0:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    80002ec2:	64bc                	ld	a5,72(s1)
    80002ec4:	68b8                	ld	a4,80(s1)
    80002ec6:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80002ec8:	0001d797          	auipc	a5,0x1d
    80002ecc:	a5078793          	addi	a5,a5,-1456 # 8001f918 <bcache+0x8000>
    80002ed0:	3a87b703          	ld	a4,936(a5)
    80002ed4:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80002ed6:	0001d717          	auipc	a4,0x1d
    80002eda:	d9a70713          	addi	a4,a4,-614 # 8001fc70 <bcache+0x8358>
    80002ede:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80002ee0:	3a87b703          	ld	a4,936(a5)
    80002ee4:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80002ee6:	3a97b423          	sd	s1,936(a5)
  }
  
  release(&bcache.lock);
    80002eea:	00015517          	auipc	a0,0x15
    80002eee:	a2e50513          	addi	a0,a0,-1490 # 80017918 <bcache>
    80002ef2:	ffffe097          	auipc	ra,0xffffe
    80002ef6:	c34080e7          	jalr	-972(ra) # 80000b26 <release>
}
    80002efa:	60e2                	ld	ra,24(sp)
    80002efc:	6442                	ld	s0,16(sp)
    80002efe:	64a2                	ld	s1,8(sp)
    80002f00:	6902                	ld	s2,0(sp)
    80002f02:	6105                	addi	sp,sp,32
    80002f04:	8082                	ret
    panic("brelse");
    80002f06:	00004517          	auipc	a0,0x4
    80002f0a:	62a50513          	addi	a0,a0,1578 # 80007530 <userret+0x4a0>
    80002f0e:	ffffd097          	auipc	ra,0xffffd
    80002f12:	640080e7          	jalr	1600(ra) # 8000054e <panic>

0000000080002f16 <bpin>:

void
bpin(struct buf *b) {
    80002f16:	1101                	addi	sp,sp,-32
    80002f18:	ec06                	sd	ra,24(sp)
    80002f1a:	e822                	sd	s0,16(sp)
    80002f1c:	e426                	sd	s1,8(sp)
    80002f1e:	1000                	addi	s0,sp,32
    80002f20:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80002f22:	00015517          	auipc	a0,0x15
    80002f26:	9f650513          	addi	a0,a0,-1546 # 80017918 <bcache>
    80002f2a:	ffffe097          	auipc	ra,0xffffe
    80002f2e:	ba8080e7          	jalr	-1112(ra) # 80000ad2 <acquire>
  b->refcnt++;
    80002f32:	40bc                	lw	a5,64(s1)
    80002f34:	2785                	addiw	a5,a5,1
    80002f36:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80002f38:	00015517          	auipc	a0,0x15
    80002f3c:	9e050513          	addi	a0,a0,-1568 # 80017918 <bcache>
    80002f40:	ffffe097          	auipc	ra,0xffffe
    80002f44:	be6080e7          	jalr	-1050(ra) # 80000b26 <release>
}
    80002f48:	60e2                	ld	ra,24(sp)
    80002f4a:	6442                	ld	s0,16(sp)
    80002f4c:	64a2                	ld	s1,8(sp)
    80002f4e:	6105                	addi	sp,sp,32
    80002f50:	8082                	ret

0000000080002f52 <bunpin>:

void
bunpin(struct buf *b) {
    80002f52:	1101                	addi	sp,sp,-32
    80002f54:	ec06                	sd	ra,24(sp)
    80002f56:	e822                	sd	s0,16(sp)
    80002f58:	e426                	sd	s1,8(sp)
    80002f5a:	1000                	addi	s0,sp,32
    80002f5c:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80002f5e:	00015517          	auipc	a0,0x15
    80002f62:	9ba50513          	addi	a0,a0,-1606 # 80017918 <bcache>
    80002f66:	ffffe097          	auipc	ra,0xffffe
    80002f6a:	b6c080e7          	jalr	-1172(ra) # 80000ad2 <acquire>
  b->refcnt--;
    80002f6e:	40bc                	lw	a5,64(s1)
    80002f70:	37fd                	addiw	a5,a5,-1
    80002f72:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80002f74:	00015517          	auipc	a0,0x15
    80002f78:	9a450513          	addi	a0,a0,-1628 # 80017918 <bcache>
    80002f7c:	ffffe097          	auipc	ra,0xffffe
    80002f80:	baa080e7          	jalr	-1110(ra) # 80000b26 <release>
}
    80002f84:	60e2                	ld	ra,24(sp)
    80002f86:	6442                	ld	s0,16(sp)
    80002f88:	64a2                	ld	s1,8(sp)
    80002f8a:	6105                	addi	sp,sp,32
    80002f8c:	8082                	ret

0000000080002f8e <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80002f8e:	1101                	addi	sp,sp,-32
    80002f90:	ec06                	sd	ra,24(sp)
    80002f92:	e822                	sd	s0,16(sp)
    80002f94:	e426                	sd	s1,8(sp)
    80002f96:	e04a                	sd	s2,0(sp)
    80002f98:	1000                	addi	s0,sp,32
    80002f9a:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80002f9c:	00d5d59b          	srliw	a1,a1,0xd
    80002fa0:	0001d797          	auipc	a5,0x1d
    80002fa4:	14c7a783          	lw	a5,332(a5) # 800200ec <sb+0x1c>
    80002fa8:	9dbd                	addw	a1,a1,a5
    80002faa:	00000097          	auipc	ra,0x0
    80002fae:	d9e080e7          	jalr	-610(ra) # 80002d48 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80002fb2:	0074f713          	andi	a4,s1,7
    80002fb6:	4785                	li	a5,1
    80002fb8:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    80002fbc:	14ce                	slli	s1,s1,0x33
    80002fbe:	90d9                	srli	s1,s1,0x36
    80002fc0:	00950733          	add	a4,a0,s1
    80002fc4:	06074703          	lbu	a4,96(a4)
    80002fc8:	00e7f6b3          	and	a3,a5,a4
    80002fcc:	c69d                	beqz	a3,80002ffa <bfree+0x6c>
    80002fce:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    80002fd0:	94aa                	add	s1,s1,a0
    80002fd2:	fff7c793          	not	a5,a5
    80002fd6:	8ff9                	and	a5,a5,a4
    80002fd8:	06f48023          	sb	a5,96(s1)
  log_write(bp);
    80002fdc:	00001097          	auipc	ra,0x1
    80002fe0:	0da080e7          	jalr	218(ra) # 800040b6 <log_write>
  brelse(bp);
    80002fe4:	854a                	mv	a0,s2
    80002fe6:	00000097          	auipc	ra,0x0
    80002fea:	e92080e7          	jalr	-366(ra) # 80002e78 <brelse>
}
    80002fee:	60e2                	ld	ra,24(sp)
    80002ff0:	6442                	ld	s0,16(sp)
    80002ff2:	64a2                	ld	s1,8(sp)
    80002ff4:	6902                	ld	s2,0(sp)
    80002ff6:	6105                	addi	sp,sp,32
    80002ff8:	8082                	ret
    panic("freeing free block");
    80002ffa:	00004517          	auipc	a0,0x4
    80002ffe:	53e50513          	addi	a0,a0,1342 # 80007538 <userret+0x4a8>
    80003002:	ffffd097          	auipc	ra,0xffffd
    80003006:	54c080e7          	jalr	1356(ra) # 8000054e <panic>

000000008000300a <balloc>:
{
    8000300a:	711d                	addi	sp,sp,-96
    8000300c:	ec86                	sd	ra,88(sp)
    8000300e:	e8a2                	sd	s0,80(sp)
    80003010:	e4a6                	sd	s1,72(sp)
    80003012:	e0ca                	sd	s2,64(sp)
    80003014:	fc4e                	sd	s3,56(sp)
    80003016:	f852                	sd	s4,48(sp)
    80003018:	f456                	sd	s5,40(sp)
    8000301a:	f05a                	sd	s6,32(sp)
    8000301c:	ec5e                	sd	s7,24(sp)
    8000301e:	e862                	sd	s8,16(sp)
    80003020:	e466                	sd	s9,8(sp)
    80003022:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    80003024:	0001d797          	auipc	a5,0x1d
    80003028:	0b07a783          	lw	a5,176(a5) # 800200d4 <sb+0x4>
    8000302c:	cbd1                	beqz	a5,800030c0 <balloc+0xb6>
    8000302e:	8baa                	mv	s7,a0
    80003030:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80003032:	0001db17          	auipc	s6,0x1d
    80003036:	09eb0b13          	addi	s6,s6,158 # 800200d0 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000303a:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    8000303c:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000303e:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    80003040:	6c89                	lui	s9,0x2
    80003042:	a831                	j	8000305e <balloc+0x54>
    brelse(bp);
    80003044:	854a                	mv	a0,s2
    80003046:	00000097          	auipc	ra,0x0
    8000304a:	e32080e7          	jalr	-462(ra) # 80002e78 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    8000304e:	015c87bb          	addw	a5,s9,s5
    80003052:	00078a9b          	sext.w	s5,a5
    80003056:	004b2703          	lw	a4,4(s6)
    8000305a:	06eaf363          	bgeu	s5,a4,800030c0 <balloc+0xb6>
    bp = bread(dev, BBLOCK(b, sb));
    8000305e:	41fad79b          	sraiw	a5,s5,0x1f
    80003062:	0137d79b          	srliw	a5,a5,0x13
    80003066:	015787bb          	addw	a5,a5,s5
    8000306a:	40d7d79b          	sraiw	a5,a5,0xd
    8000306e:	01cb2583          	lw	a1,28(s6)
    80003072:	9dbd                	addw	a1,a1,a5
    80003074:	855e                	mv	a0,s7
    80003076:	00000097          	auipc	ra,0x0
    8000307a:	cd2080e7          	jalr	-814(ra) # 80002d48 <bread>
    8000307e:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003080:	004b2503          	lw	a0,4(s6)
    80003084:	000a849b          	sext.w	s1,s5
    80003088:	8662                	mv	a2,s8
    8000308a:	faa4fde3          	bgeu	s1,a0,80003044 <balloc+0x3a>
      m = 1 << (bi % 8);
    8000308e:	41f6579b          	sraiw	a5,a2,0x1f
    80003092:	01d7d69b          	srliw	a3,a5,0x1d
    80003096:	00c6873b          	addw	a4,a3,a2
    8000309a:	00777793          	andi	a5,a4,7
    8000309e:	9f95                	subw	a5,a5,a3
    800030a0:	00f997bb          	sllw	a5,s3,a5
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    800030a4:	4037571b          	sraiw	a4,a4,0x3
    800030a8:	00e906b3          	add	a3,s2,a4
    800030ac:	0606c683          	lbu	a3,96(a3)
    800030b0:	00d7f5b3          	and	a1,a5,a3
    800030b4:	cd91                	beqz	a1,800030d0 <balloc+0xc6>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800030b6:	2605                	addiw	a2,a2,1
    800030b8:	2485                	addiw	s1,s1,1
    800030ba:	fd4618e3          	bne	a2,s4,8000308a <balloc+0x80>
    800030be:	b759                	j	80003044 <balloc+0x3a>
  panic("balloc: out of blocks");
    800030c0:	00004517          	auipc	a0,0x4
    800030c4:	49050513          	addi	a0,a0,1168 # 80007550 <userret+0x4c0>
    800030c8:	ffffd097          	auipc	ra,0xffffd
    800030cc:	486080e7          	jalr	1158(ra) # 8000054e <panic>
        bp->data[bi/8] |= m;  // Mark block in use.
    800030d0:	974a                	add	a4,a4,s2
    800030d2:	8fd5                	or	a5,a5,a3
    800030d4:	06f70023          	sb	a5,96(a4)
        log_write(bp);
    800030d8:	854a                	mv	a0,s2
    800030da:	00001097          	auipc	ra,0x1
    800030de:	fdc080e7          	jalr	-36(ra) # 800040b6 <log_write>
        brelse(bp);
    800030e2:	854a                	mv	a0,s2
    800030e4:	00000097          	auipc	ra,0x0
    800030e8:	d94080e7          	jalr	-620(ra) # 80002e78 <brelse>
  bp = bread(dev, bno);
    800030ec:	85a6                	mv	a1,s1
    800030ee:	855e                	mv	a0,s7
    800030f0:	00000097          	auipc	ra,0x0
    800030f4:	c58080e7          	jalr	-936(ra) # 80002d48 <bread>
    800030f8:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    800030fa:	40000613          	li	a2,1024
    800030fe:	4581                	li	a1,0
    80003100:	06050513          	addi	a0,a0,96
    80003104:	ffffe097          	auipc	ra,0xffffe
    80003108:	a6a080e7          	jalr	-1430(ra) # 80000b6e <memset>
  log_write(bp);
    8000310c:	854a                	mv	a0,s2
    8000310e:	00001097          	auipc	ra,0x1
    80003112:	fa8080e7          	jalr	-88(ra) # 800040b6 <log_write>
  brelse(bp);
    80003116:	854a                	mv	a0,s2
    80003118:	00000097          	auipc	ra,0x0
    8000311c:	d60080e7          	jalr	-672(ra) # 80002e78 <brelse>
}
    80003120:	8526                	mv	a0,s1
    80003122:	60e6                	ld	ra,88(sp)
    80003124:	6446                	ld	s0,80(sp)
    80003126:	64a6                	ld	s1,72(sp)
    80003128:	6906                	ld	s2,64(sp)
    8000312a:	79e2                	ld	s3,56(sp)
    8000312c:	7a42                	ld	s4,48(sp)
    8000312e:	7aa2                	ld	s5,40(sp)
    80003130:	7b02                	ld	s6,32(sp)
    80003132:	6be2                	ld	s7,24(sp)
    80003134:	6c42                	ld	s8,16(sp)
    80003136:	6ca2                	ld	s9,8(sp)
    80003138:	6125                	addi	sp,sp,96
    8000313a:	8082                	ret

000000008000313c <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
    8000313c:	7179                	addi	sp,sp,-48
    8000313e:	f406                	sd	ra,40(sp)
    80003140:	f022                	sd	s0,32(sp)
    80003142:	ec26                	sd	s1,24(sp)
    80003144:	e84a                	sd	s2,16(sp)
    80003146:	e44e                	sd	s3,8(sp)
    80003148:	e052                	sd	s4,0(sp)
    8000314a:	1800                	addi	s0,sp,48
    8000314c:	892a                	mv	s2,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    8000314e:	47ad                	li	a5,11
    80003150:	04b7fe63          	bgeu	a5,a1,800031ac <bmap+0x70>
    if((addr = ip->addrs[bn]) == 0)
      ip->addrs[bn] = addr = balloc(ip->dev);
    return addr;
  }
  bn -= NDIRECT;
    80003154:	ff45849b          	addiw	s1,a1,-12
    80003158:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    8000315c:	0ff00793          	li	a5,255
    80003160:	0ae7e363          	bltu	a5,a4,80003206 <bmap+0xca>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
    80003164:	08052583          	lw	a1,128(a0)
    80003168:	c5ad                	beqz	a1,800031d2 <bmap+0x96>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    bp = bread(ip->dev, addr);
    8000316a:	00092503          	lw	a0,0(s2)
    8000316e:	00000097          	auipc	ra,0x0
    80003172:	bda080e7          	jalr	-1062(ra) # 80002d48 <bread>
    80003176:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80003178:	06050793          	addi	a5,a0,96
    if((addr = a[bn]) == 0){
    8000317c:	02049593          	slli	a1,s1,0x20
    80003180:	9181                	srli	a1,a1,0x20
    80003182:	058a                	slli	a1,a1,0x2
    80003184:	00b784b3          	add	s1,a5,a1
    80003188:	0004a983          	lw	s3,0(s1)
    8000318c:	04098d63          	beqz	s3,800031e6 <bmap+0xaa>
      a[bn] = addr = balloc(ip->dev);
      log_write(bp);
    }
    brelse(bp);
    80003190:	8552                	mv	a0,s4
    80003192:	00000097          	auipc	ra,0x0
    80003196:	ce6080e7          	jalr	-794(ra) # 80002e78 <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    8000319a:	854e                	mv	a0,s3
    8000319c:	70a2                	ld	ra,40(sp)
    8000319e:	7402                	ld	s0,32(sp)
    800031a0:	64e2                	ld	s1,24(sp)
    800031a2:	6942                	ld	s2,16(sp)
    800031a4:	69a2                	ld	s3,8(sp)
    800031a6:	6a02                	ld	s4,0(sp)
    800031a8:	6145                	addi	sp,sp,48
    800031aa:	8082                	ret
    if((addr = ip->addrs[bn]) == 0)
    800031ac:	02059493          	slli	s1,a1,0x20
    800031b0:	9081                	srli	s1,s1,0x20
    800031b2:	048a                	slli	s1,s1,0x2
    800031b4:	94aa                	add	s1,s1,a0
    800031b6:	0504a983          	lw	s3,80(s1)
    800031ba:	fe0990e3          	bnez	s3,8000319a <bmap+0x5e>
      ip->addrs[bn] = addr = balloc(ip->dev);
    800031be:	4108                	lw	a0,0(a0)
    800031c0:	00000097          	auipc	ra,0x0
    800031c4:	e4a080e7          	jalr	-438(ra) # 8000300a <balloc>
    800031c8:	0005099b          	sext.w	s3,a0
    800031cc:	0534a823          	sw	s3,80(s1)
    800031d0:	b7e9                	j	8000319a <bmap+0x5e>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    800031d2:	4108                	lw	a0,0(a0)
    800031d4:	00000097          	auipc	ra,0x0
    800031d8:	e36080e7          	jalr	-458(ra) # 8000300a <balloc>
    800031dc:	0005059b          	sext.w	a1,a0
    800031e0:	08b92023          	sw	a1,128(s2)
    800031e4:	b759                	j	8000316a <bmap+0x2e>
      a[bn] = addr = balloc(ip->dev);
    800031e6:	00092503          	lw	a0,0(s2)
    800031ea:	00000097          	auipc	ra,0x0
    800031ee:	e20080e7          	jalr	-480(ra) # 8000300a <balloc>
    800031f2:	0005099b          	sext.w	s3,a0
    800031f6:	0134a023          	sw	s3,0(s1)
      log_write(bp);
    800031fa:	8552                	mv	a0,s4
    800031fc:	00001097          	auipc	ra,0x1
    80003200:	eba080e7          	jalr	-326(ra) # 800040b6 <log_write>
    80003204:	b771                	j	80003190 <bmap+0x54>
  panic("bmap: out of range");
    80003206:	00004517          	auipc	a0,0x4
    8000320a:	36250513          	addi	a0,a0,866 # 80007568 <userret+0x4d8>
    8000320e:	ffffd097          	auipc	ra,0xffffd
    80003212:	340080e7          	jalr	832(ra) # 8000054e <panic>

0000000080003216 <iget>:
{
    80003216:	7179                	addi	sp,sp,-48
    80003218:	f406                	sd	ra,40(sp)
    8000321a:	f022                	sd	s0,32(sp)
    8000321c:	ec26                	sd	s1,24(sp)
    8000321e:	e84a                	sd	s2,16(sp)
    80003220:	e44e                	sd	s3,8(sp)
    80003222:	e052                	sd	s4,0(sp)
    80003224:	1800                	addi	s0,sp,48
    80003226:	89aa                	mv	s3,a0
    80003228:	8a2e                	mv	s4,a1
  acquire(&icache.lock);
    8000322a:	0001d517          	auipc	a0,0x1d
    8000322e:	ec650513          	addi	a0,a0,-314 # 800200f0 <icache>
    80003232:	ffffe097          	auipc	ra,0xffffe
    80003236:	8a0080e7          	jalr	-1888(ra) # 80000ad2 <acquire>
  empty = 0;
    8000323a:	4901                	li	s2,0
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
    8000323c:	0001d497          	auipc	s1,0x1d
    80003240:	ecc48493          	addi	s1,s1,-308 # 80020108 <icache+0x18>
    80003244:	0001f697          	auipc	a3,0x1f
    80003248:	95468693          	addi	a3,a3,-1708 # 80021b98 <log>
    8000324c:	a039                	j	8000325a <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    8000324e:	02090b63          	beqz	s2,80003284 <iget+0x6e>
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
    80003252:	08848493          	addi	s1,s1,136
    80003256:	02d48a63          	beq	s1,a3,8000328a <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    8000325a:	449c                	lw	a5,8(s1)
    8000325c:	fef059e3          	blez	a5,8000324e <iget+0x38>
    80003260:	4098                	lw	a4,0(s1)
    80003262:	ff3716e3          	bne	a4,s3,8000324e <iget+0x38>
    80003266:	40d8                	lw	a4,4(s1)
    80003268:	ff4713e3          	bne	a4,s4,8000324e <iget+0x38>
      ip->ref++;
    8000326c:	2785                	addiw	a5,a5,1
    8000326e:	c49c                	sw	a5,8(s1)
      release(&icache.lock);
    80003270:	0001d517          	auipc	a0,0x1d
    80003274:	e8050513          	addi	a0,a0,-384 # 800200f0 <icache>
    80003278:	ffffe097          	auipc	ra,0xffffe
    8000327c:	8ae080e7          	jalr	-1874(ra) # 80000b26 <release>
      return ip;
    80003280:	8926                	mv	s2,s1
    80003282:	a03d                	j	800032b0 <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003284:	f7f9                	bnez	a5,80003252 <iget+0x3c>
    80003286:	8926                	mv	s2,s1
    80003288:	b7e9                	j	80003252 <iget+0x3c>
  if(empty == 0)
    8000328a:	02090c63          	beqz	s2,800032c2 <iget+0xac>
  ip->dev = dev;
    8000328e:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    80003292:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    80003296:	4785                	li	a5,1
    80003298:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    8000329c:	04092023          	sw	zero,64(s2)
  release(&icache.lock);
    800032a0:	0001d517          	auipc	a0,0x1d
    800032a4:	e5050513          	addi	a0,a0,-432 # 800200f0 <icache>
    800032a8:	ffffe097          	auipc	ra,0xffffe
    800032ac:	87e080e7          	jalr	-1922(ra) # 80000b26 <release>
}
    800032b0:	854a                	mv	a0,s2
    800032b2:	70a2                	ld	ra,40(sp)
    800032b4:	7402                	ld	s0,32(sp)
    800032b6:	64e2                	ld	s1,24(sp)
    800032b8:	6942                	ld	s2,16(sp)
    800032ba:	69a2                	ld	s3,8(sp)
    800032bc:	6a02                	ld	s4,0(sp)
    800032be:	6145                	addi	sp,sp,48
    800032c0:	8082                	ret
    panic("iget: no inodes");
    800032c2:	00004517          	auipc	a0,0x4
    800032c6:	2be50513          	addi	a0,a0,702 # 80007580 <userret+0x4f0>
    800032ca:	ffffd097          	auipc	ra,0xffffd
    800032ce:	284080e7          	jalr	644(ra) # 8000054e <panic>

00000000800032d2 <fsinit>:
fsinit(int dev) {
    800032d2:	7179                	addi	sp,sp,-48
    800032d4:	f406                	sd	ra,40(sp)
    800032d6:	f022                	sd	s0,32(sp)
    800032d8:	ec26                	sd	s1,24(sp)
    800032da:	e84a                	sd	s2,16(sp)
    800032dc:	e44e                	sd	s3,8(sp)
    800032de:	1800                	addi	s0,sp,48
    800032e0:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    800032e2:	4585                	li	a1,1
    800032e4:	00000097          	auipc	ra,0x0
    800032e8:	a64080e7          	jalr	-1436(ra) # 80002d48 <bread>
    800032ec:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    800032ee:	0001d997          	auipc	s3,0x1d
    800032f2:	de298993          	addi	s3,s3,-542 # 800200d0 <sb>
    800032f6:	02000613          	li	a2,32
    800032fa:	06050593          	addi	a1,a0,96
    800032fe:	854e                	mv	a0,s3
    80003300:	ffffe097          	auipc	ra,0xffffe
    80003304:	8ce080e7          	jalr	-1842(ra) # 80000bce <memmove>
  brelse(bp);
    80003308:	8526                	mv	a0,s1
    8000330a:	00000097          	auipc	ra,0x0
    8000330e:	b6e080e7          	jalr	-1170(ra) # 80002e78 <brelse>
  if(sb.magic != FSMAGIC)
    80003312:	0009a703          	lw	a4,0(s3)
    80003316:	102037b7          	lui	a5,0x10203
    8000331a:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    8000331e:	02f71263          	bne	a4,a5,80003342 <fsinit+0x70>
  initlog(dev, &sb);
    80003322:	0001d597          	auipc	a1,0x1d
    80003326:	dae58593          	addi	a1,a1,-594 # 800200d0 <sb>
    8000332a:	854a                	mv	a0,s2
    8000332c:	00001097          	auipc	ra,0x1
    80003330:	b12080e7          	jalr	-1262(ra) # 80003e3e <initlog>
}
    80003334:	70a2                	ld	ra,40(sp)
    80003336:	7402                	ld	s0,32(sp)
    80003338:	64e2                	ld	s1,24(sp)
    8000333a:	6942                	ld	s2,16(sp)
    8000333c:	69a2                	ld	s3,8(sp)
    8000333e:	6145                	addi	sp,sp,48
    80003340:	8082                	ret
    panic("invalid file system");
    80003342:	00004517          	auipc	a0,0x4
    80003346:	24e50513          	addi	a0,a0,590 # 80007590 <userret+0x500>
    8000334a:	ffffd097          	auipc	ra,0xffffd
    8000334e:	204080e7          	jalr	516(ra) # 8000054e <panic>

0000000080003352 <iinit>:
{
    80003352:	7179                	addi	sp,sp,-48
    80003354:	f406                	sd	ra,40(sp)
    80003356:	f022                	sd	s0,32(sp)
    80003358:	ec26                	sd	s1,24(sp)
    8000335a:	e84a                	sd	s2,16(sp)
    8000335c:	e44e                	sd	s3,8(sp)
    8000335e:	1800                	addi	s0,sp,48
  initlock(&icache.lock, "icache");
    80003360:	00004597          	auipc	a1,0x4
    80003364:	24858593          	addi	a1,a1,584 # 800075a8 <userret+0x518>
    80003368:	0001d517          	auipc	a0,0x1d
    8000336c:	d8850513          	addi	a0,a0,-632 # 800200f0 <icache>
    80003370:	ffffd097          	auipc	ra,0xffffd
    80003374:	650080e7          	jalr	1616(ra) # 800009c0 <initlock>
  for(i = 0; i < NINODE; i++) {
    80003378:	0001d497          	auipc	s1,0x1d
    8000337c:	da048493          	addi	s1,s1,-608 # 80020118 <icache+0x28>
    80003380:	0001f997          	auipc	s3,0x1f
    80003384:	82898993          	addi	s3,s3,-2008 # 80021ba8 <log+0x10>
    initsleeplock(&icache.inode[i].lock, "inode");
    80003388:	00004917          	auipc	s2,0x4
    8000338c:	22890913          	addi	s2,s2,552 # 800075b0 <userret+0x520>
    80003390:	85ca                	mv	a1,s2
    80003392:	8526                	mv	a0,s1
    80003394:	00001097          	auipc	ra,0x1
    80003398:	e10080e7          	jalr	-496(ra) # 800041a4 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    8000339c:	08848493          	addi	s1,s1,136
    800033a0:	ff3498e3          	bne	s1,s3,80003390 <iinit+0x3e>
}
    800033a4:	70a2                	ld	ra,40(sp)
    800033a6:	7402                	ld	s0,32(sp)
    800033a8:	64e2                	ld	s1,24(sp)
    800033aa:	6942                	ld	s2,16(sp)
    800033ac:	69a2                	ld	s3,8(sp)
    800033ae:	6145                	addi	sp,sp,48
    800033b0:	8082                	ret

00000000800033b2 <ialloc>:
{
    800033b2:	715d                	addi	sp,sp,-80
    800033b4:	e486                	sd	ra,72(sp)
    800033b6:	e0a2                	sd	s0,64(sp)
    800033b8:	fc26                	sd	s1,56(sp)
    800033ba:	f84a                	sd	s2,48(sp)
    800033bc:	f44e                	sd	s3,40(sp)
    800033be:	f052                	sd	s4,32(sp)
    800033c0:	ec56                	sd	s5,24(sp)
    800033c2:	e85a                	sd	s6,16(sp)
    800033c4:	e45e                	sd	s7,8(sp)
    800033c6:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    800033c8:	0001d717          	auipc	a4,0x1d
    800033cc:	d1472703          	lw	a4,-748(a4) # 800200dc <sb+0xc>
    800033d0:	4785                	li	a5,1
    800033d2:	04e7fa63          	bgeu	a5,a4,80003426 <ialloc+0x74>
    800033d6:	8aaa                	mv	s5,a0
    800033d8:	8bae                	mv	s7,a1
    800033da:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    800033dc:	0001da17          	auipc	s4,0x1d
    800033e0:	cf4a0a13          	addi	s4,s4,-780 # 800200d0 <sb>
    800033e4:	00048b1b          	sext.w	s6,s1
    800033e8:	0044d593          	srli	a1,s1,0x4
    800033ec:	018a2783          	lw	a5,24(s4)
    800033f0:	9dbd                	addw	a1,a1,a5
    800033f2:	8556                	mv	a0,s5
    800033f4:	00000097          	auipc	ra,0x0
    800033f8:	954080e7          	jalr	-1708(ra) # 80002d48 <bread>
    800033fc:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    800033fe:	06050993          	addi	s3,a0,96
    80003402:	00f4f793          	andi	a5,s1,15
    80003406:	079a                	slli	a5,a5,0x6
    80003408:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    8000340a:	00099783          	lh	a5,0(s3)
    8000340e:	c785                	beqz	a5,80003436 <ialloc+0x84>
    brelse(bp);
    80003410:	00000097          	auipc	ra,0x0
    80003414:	a68080e7          	jalr	-1432(ra) # 80002e78 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    80003418:	0485                	addi	s1,s1,1
    8000341a:	00ca2703          	lw	a4,12(s4)
    8000341e:	0004879b          	sext.w	a5,s1
    80003422:	fce7e1e3          	bltu	a5,a4,800033e4 <ialloc+0x32>
  panic("ialloc: no inodes");
    80003426:	00004517          	auipc	a0,0x4
    8000342a:	19250513          	addi	a0,a0,402 # 800075b8 <userret+0x528>
    8000342e:	ffffd097          	auipc	ra,0xffffd
    80003432:	120080e7          	jalr	288(ra) # 8000054e <panic>
      memset(dip, 0, sizeof(*dip));
    80003436:	04000613          	li	a2,64
    8000343a:	4581                	li	a1,0
    8000343c:	854e                	mv	a0,s3
    8000343e:	ffffd097          	auipc	ra,0xffffd
    80003442:	730080e7          	jalr	1840(ra) # 80000b6e <memset>
      dip->type = type;
    80003446:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    8000344a:	854a                	mv	a0,s2
    8000344c:	00001097          	auipc	ra,0x1
    80003450:	c6a080e7          	jalr	-918(ra) # 800040b6 <log_write>
      brelse(bp);
    80003454:	854a                	mv	a0,s2
    80003456:	00000097          	auipc	ra,0x0
    8000345a:	a22080e7          	jalr	-1502(ra) # 80002e78 <brelse>
      return iget(dev, inum);
    8000345e:	85da                	mv	a1,s6
    80003460:	8556                	mv	a0,s5
    80003462:	00000097          	auipc	ra,0x0
    80003466:	db4080e7          	jalr	-588(ra) # 80003216 <iget>
}
    8000346a:	60a6                	ld	ra,72(sp)
    8000346c:	6406                	ld	s0,64(sp)
    8000346e:	74e2                	ld	s1,56(sp)
    80003470:	7942                	ld	s2,48(sp)
    80003472:	79a2                	ld	s3,40(sp)
    80003474:	7a02                	ld	s4,32(sp)
    80003476:	6ae2                	ld	s5,24(sp)
    80003478:	6b42                	ld	s6,16(sp)
    8000347a:	6ba2                	ld	s7,8(sp)
    8000347c:	6161                	addi	sp,sp,80
    8000347e:	8082                	ret

0000000080003480 <iupdate>:
{
    80003480:	1101                	addi	sp,sp,-32
    80003482:	ec06                	sd	ra,24(sp)
    80003484:	e822                	sd	s0,16(sp)
    80003486:	e426                	sd	s1,8(sp)
    80003488:	e04a                	sd	s2,0(sp)
    8000348a:	1000                	addi	s0,sp,32
    8000348c:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    8000348e:	415c                	lw	a5,4(a0)
    80003490:	0047d79b          	srliw	a5,a5,0x4
    80003494:	0001d597          	auipc	a1,0x1d
    80003498:	c545a583          	lw	a1,-940(a1) # 800200e8 <sb+0x18>
    8000349c:	9dbd                	addw	a1,a1,a5
    8000349e:	4108                	lw	a0,0(a0)
    800034a0:	00000097          	auipc	ra,0x0
    800034a4:	8a8080e7          	jalr	-1880(ra) # 80002d48 <bread>
    800034a8:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    800034aa:	06050793          	addi	a5,a0,96
    800034ae:	40c8                	lw	a0,4(s1)
    800034b0:	893d                	andi	a0,a0,15
    800034b2:	051a                	slli	a0,a0,0x6
    800034b4:	953e                	add	a0,a0,a5
  dip->type = ip->type;
    800034b6:	04449703          	lh	a4,68(s1)
    800034ba:	00e51023          	sh	a4,0(a0)
  dip->major = ip->major;
    800034be:	04649703          	lh	a4,70(s1)
    800034c2:	00e51123          	sh	a4,2(a0)
  dip->minor = ip->minor;
    800034c6:	04849703          	lh	a4,72(s1)
    800034ca:	00e51223          	sh	a4,4(a0)
  dip->nlink = ip->nlink;
    800034ce:	04a49703          	lh	a4,74(s1)
    800034d2:	00e51323          	sh	a4,6(a0)
  dip->size = ip->size;
    800034d6:	44f8                	lw	a4,76(s1)
    800034d8:	c518                	sw	a4,8(a0)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    800034da:	03400613          	li	a2,52
    800034de:	05048593          	addi	a1,s1,80
    800034e2:	0531                	addi	a0,a0,12
    800034e4:	ffffd097          	auipc	ra,0xffffd
    800034e8:	6ea080e7          	jalr	1770(ra) # 80000bce <memmove>
  log_write(bp);
    800034ec:	854a                	mv	a0,s2
    800034ee:	00001097          	auipc	ra,0x1
    800034f2:	bc8080e7          	jalr	-1080(ra) # 800040b6 <log_write>
  brelse(bp);
    800034f6:	854a                	mv	a0,s2
    800034f8:	00000097          	auipc	ra,0x0
    800034fc:	980080e7          	jalr	-1664(ra) # 80002e78 <brelse>
}
    80003500:	60e2                	ld	ra,24(sp)
    80003502:	6442                	ld	s0,16(sp)
    80003504:	64a2                	ld	s1,8(sp)
    80003506:	6902                	ld	s2,0(sp)
    80003508:	6105                	addi	sp,sp,32
    8000350a:	8082                	ret

000000008000350c <idup>:
{
    8000350c:	1101                	addi	sp,sp,-32
    8000350e:	ec06                	sd	ra,24(sp)
    80003510:	e822                	sd	s0,16(sp)
    80003512:	e426                	sd	s1,8(sp)
    80003514:	1000                	addi	s0,sp,32
    80003516:	84aa                	mv	s1,a0
  acquire(&icache.lock);
    80003518:	0001d517          	auipc	a0,0x1d
    8000351c:	bd850513          	addi	a0,a0,-1064 # 800200f0 <icache>
    80003520:	ffffd097          	auipc	ra,0xffffd
    80003524:	5b2080e7          	jalr	1458(ra) # 80000ad2 <acquire>
  ip->ref++;
    80003528:	449c                	lw	a5,8(s1)
    8000352a:	2785                	addiw	a5,a5,1
    8000352c:	c49c                	sw	a5,8(s1)
  release(&icache.lock);
    8000352e:	0001d517          	auipc	a0,0x1d
    80003532:	bc250513          	addi	a0,a0,-1086 # 800200f0 <icache>
    80003536:	ffffd097          	auipc	ra,0xffffd
    8000353a:	5f0080e7          	jalr	1520(ra) # 80000b26 <release>
}
    8000353e:	8526                	mv	a0,s1
    80003540:	60e2                	ld	ra,24(sp)
    80003542:	6442                	ld	s0,16(sp)
    80003544:	64a2                	ld	s1,8(sp)
    80003546:	6105                	addi	sp,sp,32
    80003548:	8082                	ret

000000008000354a <ilock>:
{
    8000354a:	1101                	addi	sp,sp,-32
    8000354c:	ec06                	sd	ra,24(sp)
    8000354e:	e822                	sd	s0,16(sp)
    80003550:	e426                	sd	s1,8(sp)
    80003552:	e04a                	sd	s2,0(sp)
    80003554:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80003556:	c115                	beqz	a0,8000357a <ilock+0x30>
    80003558:	84aa                	mv	s1,a0
    8000355a:	451c                	lw	a5,8(a0)
    8000355c:	00f05f63          	blez	a5,8000357a <ilock+0x30>
  acquiresleep(&ip->lock);
    80003560:	0541                	addi	a0,a0,16
    80003562:	00001097          	auipc	ra,0x1
    80003566:	c7c080e7          	jalr	-900(ra) # 800041de <acquiresleep>
  if(ip->valid == 0){
    8000356a:	40bc                	lw	a5,64(s1)
    8000356c:	cf99                	beqz	a5,8000358a <ilock+0x40>
}
    8000356e:	60e2                	ld	ra,24(sp)
    80003570:	6442                	ld	s0,16(sp)
    80003572:	64a2                	ld	s1,8(sp)
    80003574:	6902                	ld	s2,0(sp)
    80003576:	6105                	addi	sp,sp,32
    80003578:	8082                	ret
    panic("ilock");
    8000357a:	00004517          	auipc	a0,0x4
    8000357e:	05650513          	addi	a0,a0,86 # 800075d0 <userret+0x540>
    80003582:	ffffd097          	auipc	ra,0xffffd
    80003586:	fcc080e7          	jalr	-52(ra) # 8000054e <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    8000358a:	40dc                	lw	a5,4(s1)
    8000358c:	0047d79b          	srliw	a5,a5,0x4
    80003590:	0001d597          	auipc	a1,0x1d
    80003594:	b585a583          	lw	a1,-1192(a1) # 800200e8 <sb+0x18>
    80003598:	9dbd                	addw	a1,a1,a5
    8000359a:	4088                	lw	a0,0(s1)
    8000359c:	fffff097          	auipc	ra,0xfffff
    800035a0:	7ac080e7          	jalr	1964(ra) # 80002d48 <bread>
    800035a4:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    800035a6:	06050593          	addi	a1,a0,96
    800035aa:	40dc                	lw	a5,4(s1)
    800035ac:	8bbd                	andi	a5,a5,15
    800035ae:	079a                	slli	a5,a5,0x6
    800035b0:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    800035b2:	00059783          	lh	a5,0(a1)
    800035b6:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    800035ba:	00259783          	lh	a5,2(a1)
    800035be:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    800035c2:	00459783          	lh	a5,4(a1)
    800035c6:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    800035ca:	00659783          	lh	a5,6(a1)
    800035ce:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    800035d2:	459c                	lw	a5,8(a1)
    800035d4:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    800035d6:	03400613          	li	a2,52
    800035da:	05b1                	addi	a1,a1,12
    800035dc:	05048513          	addi	a0,s1,80
    800035e0:	ffffd097          	auipc	ra,0xffffd
    800035e4:	5ee080e7          	jalr	1518(ra) # 80000bce <memmove>
    brelse(bp);
    800035e8:	854a                	mv	a0,s2
    800035ea:	00000097          	auipc	ra,0x0
    800035ee:	88e080e7          	jalr	-1906(ra) # 80002e78 <brelse>
    ip->valid = 1;
    800035f2:	4785                	li	a5,1
    800035f4:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    800035f6:	04449783          	lh	a5,68(s1)
    800035fa:	fbb5                	bnez	a5,8000356e <ilock+0x24>
      panic("ilock: no type");
    800035fc:	00004517          	auipc	a0,0x4
    80003600:	fdc50513          	addi	a0,a0,-36 # 800075d8 <userret+0x548>
    80003604:	ffffd097          	auipc	ra,0xffffd
    80003608:	f4a080e7          	jalr	-182(ra) # 8000054e <panic>

000000008000360c <iunlock>:
{
    8000360c:	1101                	addi	sp,sp,-32
    8000360e:	ec06                	sd	ra,24(sp)
    80003610:	e822                	sd	s0,16(sp)
    80003612:	e426                	sd	s1,8(sp)
    80003614:	e04a                	sd	s2,0(sp)
    80003616:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003618:	c905                	beqz	a0,80003648 <iunlock+0x3c>
    8000361a:	84aa                	mv	s1,a0
    8000361c:	01050913          	addi	s2,a0,16
    80003620:	854a                	mv	a0,s2
    80003622:	00001097          	auipc	ra,0x1
    80003626:	c56080e7          	jalr	-938(ra) # 80004278 <holdingsleep>
    8000362a:	cd19                	beqz	a0,80003648 <iunlock+0x3c>
    8000362c:	449c                	lw	a5,8(s1)
    8000362e:	00f05d63          	blez	a5,80003648 <iunlock+0x3c>
  releasesleep(&ip->lock);
    80003632:	854a                	mv	a0,s2
    80003634:	00001097          	auipc	ra,0x1
    80003638:	c00080e7          	jalr	-1024(ra) # 80004234 <releasesleep>
}
    8000363c:	60e2                	ld	ra,24(sp)
    8000363e:	6442                	ld	s0,16(sp)
    80003640:	64a2                	ld	s1,8(sp)
    80003642:	6902                	ld	s2,0(sp)
    80003644:	6105                	addi	sp,sp,32
    80003646:	8082                	ret
    panic("iunlock");
    80003648:	00004517          	auipc	a0,0x4
    8000364c:	fa050513          	addi	a0,a0,-96 # 800075e8 <userret+0x558>
    80003650:	ffffd097          	auipc	ra,0xffffd
    80003654:	efe080e7          	jalr	-258(ra) # 8000054e <panic>

0000000080003658 <iput>:
{
    80003658:	7139                	addi	sp,sp,-64
    8000365a:	fc06                	sd	ra,56(sp)
    8000365c:	f822                	sd	s0,48(sp)
    8000365e:	f426                	sd	s1,40(sp)
    80003660:	f04a                	sd	s2,32(sp)
    80003662:	ec4e                	sd	s3,24(sp)
    80003664:	e852                	sd	s4,16(sp)
    80003666:	e456                	sd	s5,8(sp)
    80003668:	0080                	addi	s0,sp,64
    8000366a:	84aa                	mv	s1,a0
  acquire(&icache.lock);
    8000366c:	0001d517          	auipc	a0,0x1d
    80003670:	a8450513          	addi	a0,a0,-1404 # 800200f0 <icache>
    80003674:	ffffd097          	auipc	ra,0xffffd
    80003678:	45e080e7          	jalr	1118(ra) # 80000ad2 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    8000367c:	4498                	lw	a4,8(s1)
    8000367e:	4785                	li	a5,1
    80003680:	02f70663          	beq	a4,a5,800036ac <iput+0x54>
  ip->ref--;
    80003684:	449c                	lw	a5,8(s1)
    80003686:	37fd                	addiw	a5,a5,-1
    80003688:	c49c                	sw	a5,8(s1)
  release(&icache.lock);
    8000368a:	0001d517          	auipc	a0,0x1d
    8000368e:	a6650513          	addi	a0,a0,-1434 # 800200f0 <icache>
    80003692:	ffffd097          	auipc	ra,0xffffd
    80003696:	494080e7          	jalr	1172(ra) # 80000b26 <release>
}
    8000369a:	70e2                	ld	ra,56(sp)
    8000369c:	7442                	ld	s0,48(sp)
    8000369e:	74a2                	ld	s1,40(sp)
    800036a0:	7902                	ld	s2,32(sp)
    800036a2:	69e2                	ld	s3,24(sp)
    800036a4:	6a42                	ld	s4,16(sp)
    800036a6:	6aa2                	ld	s5,8(sp)
    800036a8:	6121                	addi	sp,sp,64
    800036aa:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    800036ac:	40bc                	lw	a5,64(s1)
    800036ae:	dbf9                	beqz	a5,80003684 <iput+0x2c>
    800036b0:	04a49783          	lh	a5,74(s1)
    800036b4:	fbe1                	bnez	a5,80003684 <iput+0x2c>
    acquiresleep(&ip->lock);
    800036b6:	01048a13          	addi	s4,s1,16
    800036ba:	8552                	mv	a0,s4
    800036bc:	00001097          	auipc	ra,0x1
    800036c0:	b22080e7          	jalr	-1246(ra) # 800041de <acquiresleep>
    release(&icache.lock);
    800036c4:	0001d517          	auipc	a0,0x1d
    800036c8:	a2c50513          	addi	a0,a0,-1492 # 800200f0 <icache>
    800036cc:	ffffd097          	auipc	ra,0xffffd
    800036d0:	45a080e7          	jalr	1114(ra) # 80000b26 <release>
{
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    800036d4:	05048913          	addi	s2,s1,80
    800036d8:	08048993          	addi	s3,s1,128
    800036dc:	a819                	j	800036f2 <iput+0x9a>
    if(ip->addrs[i]){
      bfree(ip->dev, ip->addrs[i]);
    800036de:	4088                	lw	a0,0(s1)
    800036e0:	00000097          	auipc	ra,0x0
    800036e4:	8ae080e7          	jalr	-1874(ra) # 80002f8e <bfree>
      ip->addrs[i] = 0;
    800036e8:	00092023          	sw	zero,0(s2)
  for(i = 0; i < NDIRECT; i++){
    800036ec:	0911                	addi	s2,s2,4
    800036ee:	01390663          	beq	s2,s3,800036fa <iput+0xa2>
    if(ip->addrs[i]){
    800036f2:	00092583          	lw	a1,0(s2)
    800036f6:	d9fd                	beqz	a1,800036ec <iput+0x94>
    800036f8:	b7dd                	j	800036de <iput+0x86>
    }
  }

  if(ip->addrs[NDIRECT]){
    800036fa:	0804a583          	lw	a1,128(s1)
    800036fe:	ed9d                	bnez	a1,8000373c <iput+0xe4>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80003700:	0404a623          	sw	zero,76(s1)
  iupdate(ip);
    80003704:	8526                	mv	a0,s1
    80003706:	00000097          	auipc	ra,0x0
    8000370a:	d7a080e7          	jalr	-646(ra) # 80003480 <iupdate>
    ip->type = 0;
    8000370e:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80003712:	8526                	mv	a0,s1
    80003714:	00000097          	auipc	ra,0x0
    80003718:	d6c080e7          	jalr	-660(ra) # 80003480 <iupdate>
    ip->valid = 0;
    8000371c:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80003720:	8552                	mv	a0,s4
    80003722:	00001097          	auipc	ra,0x1
    80003726:	b12080e7          	jalr	-1262(ra) # 80004234 <releasesleep>
    acquire(&icache.lock);
    8000372a:	0001d517          	auipc	a0,0x1d
    8000372e:	9c650513          	addi	a0,a0,-1594 # 800200f0 <icache>
    80003732:	ffffd097          	auipc	ra,0xffffd
    80003736:	3a0080e7          	jalr	928(ra) # 80000ad2 <acquire>
    8000373a:	b7a9                	j	80003684 <iput+0x2c>
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    8000373c:	4088                	lw	a0,0(s1)
    8000373e:	fffff097          	auipc	ra,0xfffff
    80003742:	60a080e7          	jalr	1546(ra) # 80002d48 <bread>
    80003746:	8aaa                	mv	s5,a0
    for(j = 0; j < NINDIRECT; j++){
    80003748:	06050913          	addi	s2,a0,96
    8000374c:	46050993          	addi	s3,a0,1120
    80003750:	a809                	j	80003762 <iput+0x10a>
        bfree(ip->dev, a[j]);
    80003752:	4088                	lw	a0,0(s1)
    80003754:	00000097          	auipc	ra,0x0
    80003758:	83a080e7          	jalr	-1990(ra) # 80002f8e <bfree>
    for(j = 0; j < NINDIRECT; j++){
    8000375c:	0911                	addi	s2,s2,4
    8000375e:	01390663          	beq	s2,s3,8000376a <iput+0x112>
      if(a[j])
    80003762:	00092583          	lw	a1,0(s2)
    80003766:	d9fd                	beqz	a1,8000375c <iput+0x104>
    80003768:	b7ed                	j	80003752 <iput+0xfa>
    brelse(bp);
    8000376a:	8556                	mv	a0,s5
    8000376c:	fffff097          	auipc	ra,0xfffff
    80003770:	70c080e7          	jalr	1804(ra) # 80002e78 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003774:	0804a583          	lw	a1,128(s1)
    80003778:	4088                	lw	a0,0(s1)
    8000377a:	00000097          	auipc	ra,0x0
    8000377e:	814080e7          	jalr	-2028(ra) # 80002f8e <bfree>
    ip->addrs[NDIRECT] = 0;
    80003782:	0804a023          	sw	zero,128(s1)
    80003786:	bfad                	j	80003700 <iput+0xa8>

0000000080003788 <iunlockput>:
{
    80003788:	1101                	addi	sp,sp,-32
    8000378a:	ec06                	sd	ra,24(sp)
    8000378c:	e822                	sd	s0,16(sp)
    8000378e:	e426                	sd	s1,8(sp)
    80003790:	1000                	addi	s0,sp,32
    80003792:	84aa                	mv	s1,a0
  iunlock(ip);
    80003794:	00000097          	auipc	ra,0x0
    80003798:	e78080e7          	jalr	-392(ra) # 8000360c <iunlock>
  iput(ip);
    8000379c:	8526                	mv	a0,s1
    8000379e:	00000097          	auipc	ra,0x0
    800037a2:	eba080e7          	jalr	-326(ra) # 80003658 <iput>
}
    800037a6:	60e2                	ld	ra,24(sp)
    800037a8:	6442                	ld	s0,16(sp)
    800037aa:	64a2                	ld	s1,8(sp)
    800037ac:	6105                	addi	sp,sp,32
    800037ae:	8082                	ret

00000000800037b0 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    800037b0:	1141                	addi	sp,sp,-16
    800037b2:	e422                	sd	s0,8(sp)
    800037b4:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    800037b6:	411c                	lw	a5,0(a0)
    800037b8:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    800037ba:	415c                	lw	a5,4(a0)
    800037bc:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    800037be:	04451783          	lh	a5,68(a0)
    800037c2:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    800037c6:	04a51783          	lh	a5,74(a0)
    800037ca:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    800037ce:	04c56783          	lwu	a5,76(a0)
    800037d2:	e99c                	sd	a5,16(a1)
}
    800037d4:	6422                	ld	s0,8(sp)
    800037d6:	0141                	addi	sp,sp,16
    800037d8:	8082                	ret

00000000800037da <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    800037da:	457c                	lw	a5,76(a0)
    800037dc:	0ed7e563          	bltu	a5,a3,800038c6 <readi+0xec>
{
    800037e0:	7159                	addi	sp,sp,-112
    800037e2:	f486                	sd	ra,104(sp)
    800037e4:	f0a2                	sd	s0,96(sp)
    800037e6:	eca6                	sd	s1,88(sp)
    800037e8:	e8ca                	sd	s2,80(sp)
    800037ea:	e4ce                	sd	s3,72(sp)
    800037ec:	e0d2                	sd	s4,64(sp)
    800037ee:	fc56                	sd	s5,56(sp)
    800037f0:	f85a                	sd	s6,48(sp)
    800037f2:	f45e                	sd	s7,40(sp)
    800037f4:	f062                	sd	s8,32(sp)
    800037f6:	ec66                	sd	s9,24(sp)
    800037f8:	e86a                	sd	s10,16(sp)
    800037fa:	e46e                	sd	s11,8(sp)
    800037fc:	1880                	addi	s0,sp,112
    800037fe:	8baa                	mv	s7,a0
    80003800:	8c2e                	mv	s8,a1
    80003802:	8ab2                	mv	s5,a2
    80003804:	8936                	mv	s2,a3
    80003806:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003808:	9f35                	addw	a4,a4,a3
    8000380a:	0cd76063          	bltu	a4,a3,800038ca <readi+0xf0>
    return -1;
  if(off + n > ip->size)
    8000380e:	00e7f463          	bgeu	a5,a4,80003816 <readi+0x3c>
    n = ip->size - off;
    80003812:	40d78b3b          	subw	s6,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003816:	080b0763          	beqz	s6,800038a4 <readi+0xca>
    8000381a:	4a01                	li	s4,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    8000381c:	40000d13          	li	s10,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003820:	5cfd                	li	s9,-1
    80003822:	a82d                	j	8000385c <readi+0x82>
    80003824:	02099d93          	slli	s11,s3,0x20
    80003828:	020ddd93          	srli	s11,s11,0x20
    8000382c:	06048613          	addi	a2,s1,96
    80003830:	86ee                	mv	a3,s11
    80003832:	963a                	add	a2,a2,a4
    80003834:	85d6                	mv	a1,s5
    80003836:	8562                	mv	a0,s8
    80003838:	fffff097          	auipc	ra,0xfffff
    8000383c:	a14080e7          	jalr	-1516(ra) # 8000224c <either_copyout>
    80003840:	05950d63          	beq	a0,s9,8000389a <readi+0xc0>
      brelse(bp);
      break;
    }
    brelse(bp);
    80003844:	8526                	mv	a0,s1
    80003846:	fffff097          	auipc	ra,0xfffff
    8000384a:	632080e7          	jalr	1586(ra) # 80002e78 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    8000384e:	01498a3b          	addw	s4,s3,s4
    80003852:	0129893b          	addw	s2,s3,s2
    80003856:	9aee                	add	s5,s5,s11
    80003858:	056a7663          	bgeu	s4,s6,800038a4 <readi+0xca>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    8000385c:	000ba483          	lw	s1,0(s7)
    80003860:	00a9559b          	srliw	a1,s2,0xa
    80003864:	855e                	mv	a0,s7
    80003866:	00000097          	auipc	ra,0x0
    8000386a:	8d6080e7          	jalr	-1834(ra) # 8000313c <bmap>
    8000386e:	0005059b          	sext.w	a1,a0
    80003872:	8526                	mv	a0,s1
    80003874:	fffff097          	auipc	ra,0xfffff
    80003878:	4d4080e7          	jalr	1236(ra) # 80002d48 <bread>
    8000387c:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    8000387e:	3ff97713          	andi	a4,s2,1023
    80003882:	40ed07bb          	subw	a5,s10,a4
    80003886:	414b06bb          	subw	a3,s6,s4
    8000388a:	89be                	mv	s3,a5
    8000388c:	2781                	sext.w	a5,a5
    8000388e:	0006861b          	sext.w	a2,a3
    80003892:	f8f679e3          	bgeu	a2,a5,80003824 <readi+0x4a>
    80003896:	89b6                	mv	s3,a3
    80003898:	b771                	j	80003824 <readi+0x4a>
      brelse(bp);
    8000389a:	8526                	mv	a0,s1
    8000389c:	fffff097          	auipc	ra,0xfffff
    800038a0:	5dc080e7          	jalr	1500(ra) # 80002e78 <brelse>
  }
  return n;
    800038a4:	000b051b          	sext.w	a0,s6
}
    800038a8:	70a6                	ld	ra,104(sp)
    800038aa:	7406                	ld	s0,96(sp)
    800038ac:	64e6                	ld	s1,88(sp)
    800038ae:	6946                	ld	s2,80(sp)
    800038b0:	69a6                	ld	s3,72(sp)
    800038b2:	6a06                	ld	s4,64(sp)
    800038b4:	7ae2                	ld	s5,56(sp)
    800038b6:	7b42                	ld	s6,48(sp)
    800038b8:	7ba2                	ld	s7,40(sp)
    800038ba:	7c02                	ld	s8,32(sp)
    800038bc:	6ce2                	ld	s9,24(sp)
    800038be:	6d42                	ld	s10,16(sp)
    800038c0:	6da2                	ld	s11,8(sp)
    800038c2:	6165                	addi	sp,sp,112
    800038c4:	8082                	ret
    return -1;
    800038c6:	557d                	li	a0,-1
}
    800038c8:	8082                	ret
    return -1;
    800038ca:	557d                	li	a0,-1
    800038cc:	bff1                	j	800038a8 <readi+0xce>

00000000800038ce <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    800038ce:	457c                	lw	a5,76(a0)
    800038d0:	10d7e663          	bltu	a5,a3,800039dc <writei+0x10e>
{
    800038d4:	7159                	addi	sp,sp,-112
    800038d6:	f486                	sd	ra,104(sp)
    800038d8:	f0a2                	sd	s0,96(sp)
    800038da:	eca6                	sd	s1,88(sp)
    800038dc:	e8ca                	sd	s2,80(sp)
    800038de:	e4ce                	sd	s3,72(sp)
    800038e0:	e0d2                	sd	s4,64(sp)
    800038e2:	fc56                	sd	s5,56(sp)
    800038e4:	f85a                	sd	s6,48(sp)
    800038e6:	f45e                	sd	s7,40(sp)
    800038e8:	f062                	sd	s8,32(sp)
    800038ea:	ec66                	sd	s9,24(sp)
    800038ec:	e86a                	sd	s10,16(sp)
    800038ee:	e46e                	sd	s11,8(sp)
    800038f0:	1880                	addi	s0,sp,112
    800038f2:	8baa                	mv	s7,a0
    800038f4:	8c2e                	mv	s8,a1
    800038f6:	8ab2                	mv	s5,a2
    800038f8:	8936                	mv	s2,a3
    800038fa:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    800038fc:	00e687bb          	addw	a5,a3,a4
    80003900:	0ed7e063          	bltu	a5,a3,800039e0 <writei+0x112>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003904:	00043737          	lui	a4,0x43
    80003908:	0cf76e63          	bltu	a4,a5,800039e4 <writei+0x116>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    8000390c:	0a0b0763          	beqz	s6,800039ba <writei+0xec>
    80003910:	4a01                	li	s4,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    80003912:	40000d13          	li	s10,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003916:	5cfd                	li	s9,-1
    80003918:	a091                	j	8000395c <writei+0x8e>
    8000391a:	02099d93          	slli	s11,s3,0x20
    8000391e:	020ddd93          	srli	s11,s11,0x20
    80003922:	06048513          	addi	a0,s1,96
    80003926:	86ee                	mv	a3,s11
    80003928:	8656                	mv	a2,s5
    8000392a:	85e2                	mv	a1,s8
    8000392c:	953a                	add	a0,a0,a4
    8000392e:	fffff097          	auipc	ra,0xfffff
    80003932:	974080e7          	jalr	-1676(ra) # 800022a2 <either_copyin>
    80003936:	07950263          	beq	a0,s9,8000399a <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    8000393a:	8526                	mv	a0,s1
    8000393c:	00000097          	auipc	ra,0x0
    80003940:	77a080e7          	jalr	1914(ra) # 800040b6 <log_write>
    brelse(bp);
    80003944:	8526                	mv	a0,s1
    80003946:	fffff097          	auipc	ra,0xfffff
    8000394a:	532080e7          	jalr	1330(ra) # 80002e78 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    8000394e:	01498a3b          	addw	s4,s3,s4
    80003952:	0129893b          	addw	s2,s3,s2
    80003956:	9aee                	add	s5,s5,s11
    80003958:	056a7663          	bgeu	s4,s6,800039a4 <writei+0xd6>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    8000395c:	000ba483          	lw	s1,0(s7)
    80003960:	00a9559b          	srliw	a1,s2,0xa
    80003964:	855e                	mv	a0,s7
    80003966:	fffff097          	auipc	ra,0xfffff
    8000396a:	7d6080e7          	jalr	2006(ra) # 8000313c <bmap>
    8000396e:	0005059b          	sext.w	a1,a0
    80003972:	8526                	mv	a0,s1
    80003974:	fffff097          	auipc	ra,0xfffff
    80003978:	3d4080e7          	jalr	980(ra) # 80002d48 <bread>
    8000397c:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    8000397e:	3ff97713          	andi	a4,s2,1023
    80003982:	40ed07bb          	subw	a5,s10,a4
    80003986:	414b06bb          	subw	a3,s6,s4
    8000398a:	89be                	mv	s3,a5
    8000398c:	2781                	sext.w	a5,a5
    8000398e:	0006861b          	sext.w	a2,a3
    80003992:	f8f674e3          	bgeu	a2,a5,8000391a <writei+0x4c>
    80003996:	89b6                	mv	s3,a3
    80003998:	b749                	j	8000391a <writei+0x4c>
      brelse(bp);
    8000399a:	8526                	mv	a0,s1
    8000399c:	fffff097          	auipc	ra,0xfffff
    800039a0:	4dc080e7          	jalr	1244(ra) # 80002e78 <brelse>
  }

  if(n > 0){
    if(off > ip->size)
    800039a4:	04cba783          	lw	a5,76(s7)
    800039a8:	0127f463          	bgeu	a5,s2,800039b0 <writei+0xe2>
      ip->size = off;
    800039ac:	052ba623          	sw	s2,76(s7)
    // write the i-node back to disk even if the size didn't change
    // because the loop above might have called bmap() and added a new
    // block to ip->addrs[].
    iupdate(ip);
    800039b0:	855e                	mv	a0,s7
    800039b2:	00000097          	auipc	ra,0x0
    800039b6:	ace080e7          	jalr	-1330(ra) # 80003480 <iupdate>
  }

  return n;
    800039ba:	000b051b          	sext.w	a0,s6
}
    800039be:	70a6                	ld	ra,104(sp)
    800039c0:	7406                	ld	s0,96(sp)
    800039c2:	64e6                	ld	s1,88(sp)
    800039c4:	6946                	ld	s2,80(sp)
    800039c6:	69a6                	ld	s3,72(sp)
    800039c8:	6a06                	ld	s4,64(sp)
    800039ca:	7ae2                	ld	s5,56(sp)
    800039cc:	7b42                	ld	s6,48(sp)
    800039ce:	7ba2                	ld	s7,40(sp)
    800039d0:	7c02                	ld	s8,32(sp)
    800039d2:	6ce2                	ld	s9,24(sp)
    800039d4:	6d42                	ld	s10,16(sp)
    800039d6:	6da2                	ld	s11,8(sp)
    800039d8:	6165                	addi	sp,sp,112
    800039da:	8082                	ret
    return -1;
    800039dc:	557d                	li	a0,-1
}
    800039de:	8082                	ret
    return -1;
    800039e0:	557d                	li	a0,-1
    800039e2:	bff1                	j	800039be <writei+0xf0>
    return -1;
    800039e4:	557d                	li	a0,-1
    800039e6:	bfe1                	j	800039be <writei+0xf0>

00000000800039e8 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    800039e8:	1141                	addi	sp,sp,-16
    800039ea:	e406                	sd	ra,8(sp)
    800039ec:	e022                	sd	s0,0(sp)
    800039ee:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    800039f0:	4639                	li	a2,14
    800039f2:	ffffd097          	auipc	ra,0xffffd
    800039f6:	258080e7          	jalr	600(ra) # 80000c4a <strncmp>
}
    800039fa:	60a2                	ld	ra,8(sp)
    800039fc:	6402                	ld	s0,0(sp)
    800039fe:	0141                	addi	sp,sp,16
    80003a00:	8082                	ret

0000000080003a02 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003a02:	7139                	addi	sp,sp,-64
    80003a04:	fc06                	sd	ra,56(sp)
    80003a06:	f822                	sd	s0,48(sp)
    80003a08:	f426                	sd	s1,40(sp)
    80003a0a:	f04a                	sd	s2,32(sp)
    80003a0c:	ec4e                	sd	s3,24(sp)
    80003a0e:	e852                	sd	s4,16(sp)
    80003a10:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80003a12:	04451703          	lh	a4,68(a0)
    80003a16:	4785                	li	a5,1
    80003a18:	00f71a63          	bne	a4,a5,80003a2c <dirlookup+0x2a>
    80003a1c:	892a                	mv	s2,a0
    80003a1e:	89ae                	mv	s3,a1
    80003a20:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80003a22:	457c                	lw	a5,76(a0)
    80003a24:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80003a26:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003a28:	e79d                	bnez	a5,80003a56 <dirlookup+0x54>
    80003a2a:	a8a5                	j	80003aa2 <dirlookup+0xa0>
    panic("dirlookup not DIR");
    80003a2c:	00004517          	auipc	a0,0x4
    80003a30:	bc450513          	addi	a0,a0,-1084 # 800075f0 <userret+0x560>
    80003a34:	ffffd097          	auipc	ra,0xffffd
    80003a38:	b1a080e7          	jalr	-1254(ra) # 8000054e <panic>
      panic("dirlookup read");
    80003a3c:	00004517          	auipc	a0,0x4
    80003a40:	bcc50513          	addi	a0,a0,-1076 # 80007608 <userret+0x578>
    80003a44:	ffffd097          	auipc	ra,0xffffd
    80003a48:	b0a080e7          	jalr	-1270(ra) # 8000054e <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003a4c:	24c1                	addiw	s1,s1,16
    80003a4e:	04c92783          	lw	a5,76(s2)
    80003a52:	04f4f763          	bgeu	s1,a5,80003aa0 <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003a56:	4741                	li	a4,16
    80003a58:	86a6                	mv	a3,s1
    80003a5a:	fc040613          	addi	a2,s0,-64
    80003a5e:	4581                	li	a1,0
    80003a60:	854a                	mv	a0,s2
    80003a62:	00000097          	auipc	ra,0x0
    80003a66:	d78080e7          	jalr	-648(ra) # 800037da <readi>
    80003a6a:	47c1                	li	a5,16
    80003a6c:	fcf518e3          	bne	a0,a5,80003a3c <dirlookup+0x3a>
    if(de.inum == 0)
    80003a70:	fc045783          	lhu	a5,-64(s0)
    80003a74:	dfe1                	beqz	a5,80003a4c <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    80003a76:	fc240593          	addi	a1,s0,-62
    80003a7a:	854e                	mv	a0,s3
    80003a7c:	00000097          	auipc	ra,0x0
    80003a80:	f6c080e7          	jalr	-148(ra) # 800039e8 <namecmp>
    80003a84:	f561                	bnez	a0,80003a4c <dirlookup+0x4a>
      if(poff)
    80003a86:	000a0463          	beqz	s4,80003a8e <dirlookup+0x8c>
        *poff = off;
    80003a8a:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80003a8e:	fc045583          	lhu	a1,-64(s0)
    80003a92:	00092503          	lw	a0,0(s2)
    80003a96:	fffff097          	auipc	ra,0xfffff
    80003a9a:	780080e7          	jalr	1920(ra) # 80003216 <iget>
    80003a9e:	a011                	j	80003aa2 <dirlookup+0xa0>
  return 0;
    80003aa0:	4501                	li	a0,0
}
    80003aa2:	70e2                	ld	ra,56(sp)
    80003aa4:	7442                	ld	s0,48(sp)
    80003aa6:	74a2                	ld	s1,40(sp)
    80003aa8:	7902                	ld	s2,32(sp)
    80003aaa:	69e2                	ld	s3,24(sp)
    80003aac:	6a42                	ld	s4,16(sp)
    80003aae:	6121                	addi	sp,sp,64
    80003ab0:	8082                	ret

0000000080003ab2 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80003ab2:	711d                	addi	sp,sp,-96
    80003ab4:	ec86                	sd	ra,88(sp)
    80003ab6:	e8a2                	sd	s0,80(sp)
    80003ab8:	e4a6                	sd	s1,72(sp)
    80003aba:	e0ca                	sd	s2,64(sp)
    80003abc:	fc4e                	sd	s3,56(sp)
    80003abe:	f852                	sd	s4,48(sp)
    80003ac0:	f456                	sd	s5,40(sp)
    80003ac2:	f05a                	sd	s6,32(sp)
    80003ac4:	ec5e                	sd	s7,24(sp)
    80003ac6:	e862                	sd	s8,16(sp)
    80003ac8:	e466                	sd	s9,8(sp)
    80003aca:	1080                	addi	s0,sp,96
    80003acc:	84aa                	mv	s1,a0
    80003ace:	8b2e                	mv	s6,a1
    80003ad0:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    80003ad2:	00054703          	lbu	a4,0(a0)
    80003ad6:	02f00793          	li	a5,47
    80003ada:	02f70363          	beq	a4,a5,80003b00 <namex+0x4e>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80003ade:	ffffe097          	auipc	ra,0xffffe
    80003ae2:	d66080e7          	jalr	-666(ra) # 80001844 <myproc>
    80003ae6:	15053503          	ld	a0,336(a0)
    80003aea:	00000097          	auipc	ra,0x0
    80003aee:	a22080e7          	jalr	-1502(ra) # 8000350c <idup>
    80003af2:	89aa                	mv	s3,a0
  while(*path == '/')
    80003af4:	02f00913          	li	s2,47
  len = path - s;
    80003af8:	4b81                	li	s7,0
  if(len >= DIRSIZ)
    80003afa:	4cb5                	li	s9,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80003afc:	4c05                	li	s8,1
    80003afe:	a865                	j	80003bb6 <namex+0x104>
    ip = iget(ROOTDEV, ROOTINO);
    80003b00:	4585                	li	a1,1
    80003b02:	4505                	li	a0,1
    80003b04:	fffff097          	auipc	ra,0xfffff
    80003b08:	712080e7          	jalr	1810(ra) # 80003216 <iget>
    80003b0c:	89aa                	mv	s3,a0
    80003b0e:	b7dd                	j	80003af4 <namex+0x42>
      iunlockput(ip);
    80003b10:	854e                	mv	a0,s3
    80003b12:	00000097          	auipc	ra,0x0
    80003b16:	c76080e7          	jalr	-906(ra) # 80003788 <iunlockput>
      return 0;
    80003b1a:	4981                	li	s3,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80003b1c:	854e                	mv	a0,s3
    80003b1e:	60e6                	ld	ra,88(sp)
    80003b20:	6446                	ld	s0,80(sp)
    80003b22:	64a6                	ld	s1,72(sp)
    80003b24:	6906                	ld	s2,64(sp)
    80003b26:	79e2                	ld	s3,56(sp)
    80003b28:	7a42                	ld	s4,48(sp)
    80003b2a:	7aa2                	ld	s5,40(sp)
    80003b2c:	7b02                	ld	s6,32(sp)
    80003b2e:	6be2                	ld	s7,24(sp)
    80003b30:	6c42                	ld	s8,16(sp)
    80003b32:	6ca2                	ld	s9,8(sp)
    80003b34:	6125                	addi	sp,sp,96
    80003b36:	8082                	ret
      iunlock(ip);
    80003b38:	854e                	mv	a0,s3
    80003b3a:	00000097          	auipc	ra,0x0
    80003b3e:	ad2080e7          	jalr	-1326(ra) # 8000360c <iunlock>
      return ip;
    80003b42:	bfe9                	j	80003b1c <namex+0x6a>
      iunlockput(ip);
    80003b44:	854e                	mv	a0,s3
    80003b46:	00000097          	auipc	ra,0x0
    80003b4a:	c42080e7          	jalr	-958(ra) # 80003788 <iunlockput>
      return 0;
    80003b4e:	89d2                	mv	s3,s4
    80003b50:	b7f1                	j	80003b1c <namex+0x6a>
  len = path - s;
    80003b52:	40b48633          	sub	a2,s1,a1
    80003b56:	00060a1b          	sext.w	s4,a2
  if(len >= DIRSIZ)
    80003b5a:	094cd463          	bge	s9,s4,80003be2 <namex+0x130>
    memmove(name, s, DIRSIZ);
    80003b5e:	4639                	li	a2,14
    80003b60:	8556                	mv	a0,s5
    80003b62:	ffffd097          	auipc	ra,0xffffd
    80003b66:	06c080e7          	jalr	108(ra) # 80000bce <memmove>
  while(*path == '/')
    80003b6a:	0004c783          	lbu	a5,0(s1)
    80003b6e:	01279763          	bne	a5,s2,80003b7c <namex+0xca>
    path++;
    80003b72:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003b74:	0004c783          	lbu	a5,0(s1)
    80003b78:	ff278de3          	beq	a5,s2,80003b72 <namex+0xc0>
    ilock(ip);
    80003b7c:	854e                	mv	a0,s3
    80003b7e:	00000097          	auipc	ra,0x0
    80003b82:	9cc080e7          	jalr	-1588(ra) # 8000354a <ilock>
    if(ip->type != T_DIR){
    80003b86:	04499783          	lh	a5,68(s3)
    80003b8a:	f98793e3          	bne	a5,s8,80003b10 <namex+0x5e>
    if(nameiparent && *path == '\0'){
    80003b8e:	000b0563          	beqz	s6,80003b98 <namex+0xe6>
    80003b92:	0004c783          	lbu	a5,0(s1)
    80003b96:	d3cd                	beqz	a5,80003b38 <namex+0x86>
    if((next = dirlookup(ip, name, 0)) == 0){
    80003b98:	865e                	mv	a2,s7
    80003b9a:	85d6                	mv	a1,s5
    80003b9c:	854e                	mv	a0,s3
    80003b9e:	00000097          	auipc	ra,0x0
    80003ba2:	e64080e7          	jalr	-412(ra) # 80003a02 <dirlookup>
    80003ba6:	8a2a                	mv	s4,a0
    80003ba8:	dd51                	beqz	a0,80003b44 <namex+0x92>
    iunlockput(ip);
    80003baa:	854e                	mv	a0,s3
    80003bac:	00000097          	auipc	ra,0x0
    80003bb0:	bdc080e7          	jalr	-1060(ra) # 80003788 <iunlockput>
    ip = next;
    80003bb4:	89d2                	mv	s3,s4
  while(*path == '/')
    80003bb6:	0004c783          	lbu	a5,0(s1)
    80003bba:	05279763          	bne	a5,s2,80003c08 <namex+0x156>
    path++;
    80003bbe:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003bc0:	0004c783          	lbu	a5,0(s1)
    80003bc4:	ff278de3          	beq	a5,s2,80003bbe <namex+0x10c>
  if(*path == 0)
    80003bc8:	c79d                	beqz	a5,80003bf6 <namex+0x144>
    path++;
    80003bca:	85a6                	mv	a1,s1
  len = path - s;
    80003bcc:	8a5e                	mv	s4,s7
    80003bce:	865e                	mv	a2,s7
  while(*path != '/' && *path != 0)
    80003bd0:	01278963          	beq	a5,s2,80003be2 <namex+0x130>
    80003bd4:	dfbd                	beqz	a5,80003b52 <namex+0xa0>
    path++;
    80003bd6:	0485                	addi	s1,s1,1
  while(*path != '/' && *path != 0)
    80003bd8:	0004c783          	lbu	a5,0(s1)
    80003bdc:	ff279ce3          	bne	a5,s2,80003bd4 <namex+0x122>
    80003be0:	bf8d                	j	80003b52 <namex+0xa0>
    memmove(name, s, len);
    80003be2:	2601                	sext.w	a2,a2
    80003be4:	8556                	mv	a0,s5
    80003be6:	ffffd097          	auipc	ra,0xffffd
    80003bea:	fe8080e7          	jalr	-24(ra) # 80000bce <memmove>
    name[len] = 0;
    80003bee:	9a56                	add	s4,s4,s5
    80003bf0:	000a0023          	sb	zero,0(s4)
    80003bf4:	bf9d                	j	80003b6a <namex+0xb8>
  if(nameiparent){
    80003bf6:	f20b03e3          	beqz	s6,80003b1c <namex+0x6a>
    iput(ip);
    80003bfa:	854e                	mv	a0,s3
    80003bfc:	00000097          	auipc	ra,0x0
    80003c00:	a5c080e7          	jalr	-1444(ra) # 80003658 <iput>
    return 0;
    80003c04:	4981                	li	s3,0
    80003c06:	bf19                	j	80003b1c <namex+0x6a>
  if(*path == 0)
    80003c08:	d7fd                	beqz	a5,80003bf6 <namex+0x144>
  while(*path != '/' && *path != 0)
    80003c0a:	0004c783          	lbu	a5,0(s1)
    80003c0e:	85a6                	mv	a1,s1
    80003c10:	b7d1                	j	80003bd4 <namex+0x122>

0000000080003c12 <dirlink>:
{
    80003c12:	7139                	addi	sp,sp,-64
    80003c14:	fc06                	sd	ra,56(sp)
    80003c16:	f822                	sd	s0,48(sp)
    80003c18:	f426                	sd	s1,40(sp)
    80003c1a:	f04a                	sd	s2,32(sp)
    80003c1c:	ec4e                	sd	s3,24(sp)
    80003c1e:	e852                	sd	s4,16(sp)
    80003c20:	0080                	addi	s0,sp,64
    80003c22:	892a                	mv	s2,a0
    80003c24:	8a2e                	mv	s4,a1
    80003c26:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80003c28:	4601                	li	a2,0
    80003c2a:	00000097          	auipc	ra,0x0
    80003c2e:	dd8080e7          	jalr	-552(ra) # 80003a02 <dirlookup>
    80003c32:	e93d                	bnez	a0,80003ca8 <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003c34:	04c92483          	lw	s1,76(s2)
    80003c38:	c49d                	beqz	s1,80003c66 <dirlink+0x54>
    80003c3a:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003c3c:	4741                	li	a4,16
    80003c3e:	86a6                	mv	a3,s1
    80003c40:	fc040613          	addi	a2,s0,-64
    80003c44:	4581                	li	a1,0
    80003c46:	854a                	mv	a0,s2
    80003c48:	00000097          	auipc	ra,0x0
    80003c4c:	b92080e7          	jalr	-1134(ra) # 800037da <readi>
    80003c50:	47c1                	li	a5,16
    80003c52:	06f51163          	bne	a0,a5,80003cb4 <dirlink+0xa2>
    if(de.inum == 0)
    80003c56:	fc045783          	lhu	a5,-64(s0)
    80003c5a:	c791                	beqz	a5,80003c66 <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003c5c:	24c1                	addiw	s1,s1,16
    80003c5e:	04c92783          	lw	a5,76(s2)
    80003c62:	fcf4ede3          	bltu	s1,a5,80003c3c <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    80003c66:	4639                	li	a2,14
    80003c68:	85d2                	mv	a1,s4
    80003c6a:	fc240513          	addi	a0,s0,-62
    80003c6e:	ffffd097          	auipc	ra,0xffffd
    80003c72:	018080e7          	jalr	24(ra) # 80000c86 <strncpy>
  de.inum = inum;
    80003c76:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003c7a:	4741                	li	a4,16
    80003c7c:	86a6                	mv	a3,s1
    80003c7e:	fc040613          	addi	a2,s0,-64
    80003c82:	4581                	li	a1,0
    80003c84:	854a                	mv	a0,s2
    80003c86:	00000097          	auipc	ra,0x0
    80003c8a:	c48080e7          	jalr	-952(ra) # 800038ce <writei>
    80003c8e:	872a                	mv	a4,a0
    80003c90:	47c1                	li	a5,16
  return 0;
    80003c92:	4501                	li	a0,0
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003c94:	02f71863          	bne	a4,a5,80003cc4 <dirlink+0xb2>
}
    80003c98:	70e2                	ld	ra,56(sp)
    80003c9a:	7442                	ld	s0,48(sp)
    80003c9c:	74a2                	ld	s1,40(sp)
    80003c9e:	7902                	ld	s2,32(sp)
    80003ca0:	69e2                	ld	s3,24(sp)
    80003ca2:	6a42                	ld	s4,16(sp)
    80003ca4:	6121                	addi	sp,sp,64
    80003ca6:	8082                	ret
    iput(ip);
    80003ca8:	00000097          	auipc	ra,0x0
    80003cac:	9b0080e7          	jalr	-1616(ra) # 80003658 <iput>
    return -1;
    80003cb0:	557d                	li	a0,-1
    80003cb2:	b7dd                	j	80003c98 <dirlink+0x86>
      panic("dirlink read");
    80003cb4:	00004517          	auipc	a0,0x4
    80003cb8:	96450513          	addi	a0,a0,-1692 # 80007618 <userret+0x588>
    80003cbc:	ffffd097          	auipc	ra,0xffffd
    80003cc0:	892080e7          	jalr	-1902(ra) # 8000054e <panic>
    panic("dirlink");
    80003cc4:	00004517          	auipc	a0,0x4
    80003cc8:	a7450513          	addi	a0,a0,-1420 # 80007738 <userret+0x6a8>
    80003ccc:	ffffd097          	auipc	ra,0xffffd
    80003cd0:	882080e7          	jalr	-1918(ra) # 8000054e <panic>

0000000080003cd4 <namei>:

struct inode*
namei(char *path)
{
    80003cd4:	1101                	addi	sp,sp,-32
    80003cd6:	ec06                	sd	ra,24(sp)
    80003cd8:	e822                	sd	s0,16(sp)
    80003cda:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80003cdc:	fe040613          	addi	a2,s0,-32
    80003ce0:	4581                	li	a1,0
    80003ce2:	00000097          	auipc	ra,0x0
    80003ce6:	dd0080e7          	jalr	-560(ra) # 80003ab2 <namex>
}
    80003cea:	60e2                	ld	ra,24(sp)
    80003cec:	6442                	ld	s0,16(sp)
    80003cee:	6105                	addi	sp,sp,32
    80003cf0:	8082                	ret

0000000080003cf2 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80003cf2:	1141                	addi	sp,sp,-16
    80003cf4:	e406                	sd	ra,8(sp)
    80003cf6:	e022                	sd	s0,0(sp)
    80003cf8:	0800                	addi	s0,sp,16
    80003cfa:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80003cfc:	4585                	li	a1,1
    80003cfe:	00000097          	auipc	ra,0x0
    80003d02:	db4080e7          	jalr	-588(ra) # 80003ab2 <namex>
}
    80003d06:	60a2                	ld	ra,8(sp)
    80003d08:	6402                	ld	s0,0(sp)
    80003d0a:	0141                	addi	sp,sp,16
    80003d0c:	8082                	ret

0000000080003d0e <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80003d0e:	1101                	addi	sp,sp,-32
    80003d10:	ec06                	sd	ra,24(sp)
    80003d12:	e822                	sd	s0,16(sp)
    80003d14:	e426                	sd	s1,8(sp)
    80003d16:	e04a                	sd	s2,0(sp)
    80003d18:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80003d1a:	0001e917          	auipc	s2,0x1e
    80003d1e:	e7e90913          	addi	s2,s2,-386 # 80021b98 <log>
    80003d22:	01892583          	lw	a1,24(s2)
    80003d26:	02892503          	lw	a0,40(s2)
    80003d2a:	fffff097          	auipc	ra,0xfffff
    80003d2e:	01e080e7          	jalr	30(ra) # 80002d48 <bread>
    80003d32:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80003d34:	02c92683          	lw	a3,44(s2)
    80003d38:	d134                	sw	a3,96(a0)
  for (i = 0; i < log.lh.n; i++) {
    80003d3a:	02d05763          	blez	a3,80003d68 <write_head+0x5a>
    80003d3e:	0001e797          	auipc	a5,0x1e
    80003d42:	e8a78793          	addi	a5,a5,-374 # 80021bc8 <log+0x30>
    80003d46:	06450713          	addi	a4,a0,100
    80003d4a:	36fd                	addiw	a3,a3,-1
    80003d4c:	1682                	slli	a3,a3,0x20
    80003d4e:	9281                	srli	a3,a3,0x20
    80003d50:	068a                	slli	a3,a3,0x2
    80003d52:	0001e617          	auipc	a2,0x1e
    80003d56:	e7a60613          	addi	a2,a2,-390 # 80021bcc <log+0x34>
    80003d5a:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    80003d5c:	4390                	lw	a2,0(a5)
    80003d5e:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80003d60:	0791                	addi	a5,a5,4
    80003d62:	0711                	addi	a4,a4,4
    80003d64:	fed79ce3          	bne	a5,a3,80003d5c <write_head+0x4e>
  }
  bwrite(buf);
    80003d68:	8526                	mv	a0,s1
    80003d6a:	fffff097          	auipc	ra,0xfffff
    80003d6e:	0d0080e7          	jalr	208(ra) # 80002e3a <bwrite>
  brelse(buf);
    80003d72:	8526                	mv	a0,s1
    80003d74:	fffff097          	auipc	ra,0xfffff
    80003d78:	104080e7          	jalr	260(ra) # 80002e78 <brelse>
}
    80003d7c:	60e2                	ld	ra,24(sp)
    80003d7e:	6442                	ld	s0,16(sp)
    80003d80:	64a2                	ld	s1,8(sp)
    80003d82:	6902                	ld	s2,0(sp)
    80003d84:	6105                	addi	sp,sp,32
    80003d86:	8082                	ret

0000000080003d88 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80003d88:	0001e797          	auipc	a5,0x1e
    80003d8c:	e3c7a783          	lw	a5,-452(a5) # 80021bc4 <log+0x2c>
    80003d90:	0af05663          	blez	a5,80003e3c <install_trans+0xb4>
{
    80003d94:	7139                	addi	sp,sp,-64
    80003d96:	fc06                	sd	ra,56(sp)
    80003d98:	f822                	sd	s0,48(sp)
    80003d9a:	f426                	sd	s1,40(sp)
    80003d9c:	f04a                	sd	s2,32(sp)
    80003d9e:	ec4e                	sd	s3,24(sp)
    80003da0:	e852                	sd	s4,16(sp)
    80003da2:	e456                	sd	s5,8(sp)
    80003da4:	0080                	addi	s0,sp,64
    80003da6:	0001ea97          	auipc	s5,0x1e
    80003daa:	e22a8a93          	addi	s5,s5,-478 # 80021bc8 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003dae:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003db0:	0001e997          	auipc	s3,0x1e
    80003db4:	de898993          	addi	s3,s3,-536 # 80021b98 <log>
    80003db8:	0189a583          	lw	a1,24(s3)
    80003dbc:	014585bb          	addw	a1,a1,s4
    80003dc0:	2585                	addiw	a1,a1,1
    80003dc2:	0289a503          	lw	a0,40(s3)
    80003dc6:	fffff097          	auipc	ra,0xfffff
    80003dca:	f82080e7          	jalr	-126(ra) # 80002d48 <bread>
    80003dce:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80003dd0:	000aa583          	lw	a1,0(s5)
    80003dd4:	0289a503          	lw	a0,40(s3)
    80003dd8:	fffff097          	auipc	ra,0xfffff
    80003ddc:	f70080e7          	jalr	-144(ra) # 80002d48 <bread>
    80003de0:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80003de2:	40000613          	li	a2,1024
    80003de6:	06090593          	addi	a1,s2,96
    80003dea:	06050513          	addi	a0,a0,96
    80003dee:	ffffd097          	auipc	ra,0xffffd
    80003df2:	de0080e7          	jalr	-544(ra) # 80000bce <memmove>
    bwrite(dbuf);  // write dst to disk
    80003df6:	8526                	mv	a0,s1
    80003df8:	fffff097          	auipc	ra,0xfffff
    80003dfc:	042080e7          	jalr	66(ra) # 80002e3a <bwrite>
    bunpin(dbuf);
    80003e00:	8526                	mv	a0,s1
    80003e02:	fffff097          	auipc	ra,0xfffff
    80003e06:	150080e7          	jalr	336(ra) # 80002f52 <bunpin>
    brelse(lbuf);
    80003e0a:	854a                	mv	a0,s2
    80003e0c:	fffff097          	auipc	ra,0xfffff
    80003e10:	06c080e7          	jalr	108(ra) # 80002e78 <brelse>
    brelse(dbuf);
    80003e14:	8526                	mv	a0,s1
    80003e16:	fffff097          	auipc	ra,0xfffff
    80003e1a:	062080e7          	jalr	98(ra) # 80002e78 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003e1e:	2a05                	addiw	s4,s4,1
    80003e20:	0a91                	addi	s5,s5,4
    80003e22:	02c9a783          	lw	a5,44(s3)
    80003e26:	f8fa49e3          	blt	s4,a5,80003db8 <install_trans+0x30>
}
    80003e2a:	70e2                	ld	ra,56(sp)
    80003e2c:	7442                	ld	s0,48(sp)
    80003e2e:	74a2                	ld	s1,40(sp)
    80003e30:	7902                	ld	s2,32(sp)
    80003e32:	69e2                	ld	s3,24(sp)
    80003e34:	6a42                	ld	s4,16(sp)
    80003e36:	6aa2                	ld	s5,8(sp)
    80003e38:	6121                	addi	sp,sp,64
    80003e3a:	8082                	ret
    80003e3c:	8082                	ret

0000000080003e3e <initlog>:
{
    80003e3e:	7179                	addi	sp,sp,-48
    80003e40:	f406                	sd	ra,40(sp)
    80003e42:	f022                	sd	s0,32(sp)
    80003e44:	ec26                	sd	s1,24(sp)
    80003e46:	e84a                	sd	s2,16(sp)
    80003e48:	e44e                	sd	s3,8(sp)
    80003e4a:	1800                	addi	s0,sp,48
    80003e4c:	892a                	mv	s2,a0
    80003e4e:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80003e50:	0001e497          	auipc	s1,0x1e
    80003e54:	d4848493          	addi	s1,s1,-696 # 80021b98 <log>
    80003e58:	00003597          	auipc	a1,0x3
    80003e5c:	7d058593          	addi	a1,a1,2000 # 80007628 <userret+0x598>
    80003e60:	8526                	mv	a0,s1
    80003e62:	ffffd097          	auipc	ra,0xffffd
    80003e66:	b5e080e7          	jalr	-1186(ra) # 800009c0 <initlock>
  log.start = sb->logstart;
    80003e6a:	0149a583          	lw	a1,20(s3)
    80003e6e:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    80003e70:	0109a783          	lw	a5,16(s3)
    80003e74:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    80003e76:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    80003e7a:	854a                	mv	a0,s2
    80003e7c:	fffff097          	auipc	ra,0xfffff
    80003e80:	ecc080e7          	jalr	-308(ra) # 80002d48 <bread>
  log.lh.n = lh->n;
    80003e84:	513c                	lw	a5,96(a0)
    80003e86:	d4dc                	sw	a5,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    80003e88:	02f05563          	blez	a5,80003eb2 <initlog+0x74>
    80003e8c:	06450713          	addi	a4,a0,100
    80003e90:	0001e697          	auipc	a3,0x1e
    80003e94:	d3868693          	addi	a3,a3,-712 # 80021bc8 <log+0x30>
    80003e98:	37fd                	addiw	a5,a5,-1
    80003e9a:	1782                	slli	a5,a5,0x20
    80003e9c:	9381                	srli	a5,a5,0x20
    80003e9e:	078a                	slli	a5,a5,0x2
    80003ea0:	06850613          	addi	a2,a0,104
    80003ea4:	97b2                	add	a5,a5,a2
    log.lh.block[i] = lh->block[i];
    80003ea6:	4310                	lw	a2,0(a4)
    80003ea8:	c290                	sw	a2,0(a3)
  for (i = 0; i < log.lh.n; i++) {
    80003eaa:	0711                	addi	a4,a4,4
    80003eac:	0691                	addi	a3,a3,4
    80003eae:	fef71ce3          	bne	a4,a5,80003ea6 <initlog+0x68>
  brelse(buf);
    80003eb2:	fffff097          	auipc	ra,0xfffff
    80003eb6:	fc6080e7          	jalr	-58(ra) # 80002e78 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(); // if committed, copy from log to disk
    80003eba:	00000097          	auipc	ra,0x0
    80003ebe:	ece080e7          	jalr	-306(ra) # 80003d88 <install_trans>
  log.lh.n = 0;
    80003ec2:	0001e797          	auipc	a5,0x1e
    80003ec6:	d007a123          	sw	zero,-766(a5) # 80021bc4 <log+0x2c>
  write_head(); // clear the log
    80003eca:	00000097          	auipc	ra,0x0
    80003ece:	e44080e7          	jalr	-444(ra) # 80003d0e <write_head>
}
    80003ed2:	70a2                	ld	ra,40(sp)
    80003ed4:	7402                	ld	s0,32(sp)
    80003ed6:	64e2                	ld	s1,24(sp)
    80003ed8:	6942                	ld	s2,16(sp)
    80003eda:	69a2                	ld	s3,8(sp)
    80003edc:	6145                	addi	sp,sp,48
    80003ede:	8082                	ret

0000000080003ee0 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80003ee0:	1101                	addi	sp,sp,-32
    80003ee2:	ec06                	sd	ra,24(sp)
    80003ee4:	e822                	sd	s0,16(sp)
    80003ee6:	e426                	sd	s1,8(sp)
    80003ee8:	e04a                	sd	s2,0(sp)
    80003eea:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80003eec:	0001e517          	auipc	a0,0x1e
    80003ef0:	cac50513          	addi	a0,a0,-852 # 80021b98 <log>
    80003ef4:	ffffd097          	auipc	ra,0xffffd
    80003ef8:	bde080e7          	jalr	-1058(ra) # 80000ad2 <acquire>
  while(1){
    if(log.committing){
    80003efc:	0001e497          	auipc	s1,0x1e
    80003f00:	c9c48493          	addi	s1,s1,-868 # 80021b98 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80003f04:	4979                	li	s2,30
    80003f06:	a039                	j	80003f14 <begin_op+0x34>
      sleep(&log, &log.lock);
    80003f08:	85a6                	mv	a1,s1
    80003f0a:	8526                	mv	a0,s1
    80003f0c:	ffffe097          	auipc	ra,0xffffe
    80003f10:	0de080e7          	jalr	222(ra) # 80001fea <sleep>
    if(log.committing){
    80003f14:	50dc                	lw	a5,36(s1)
    80003f16:	fbed                	bnez	a5,80003f08 <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80003f18:	509c                	lw	a5,32(s1)
    80003f1a:	0017871b          	addiw	a4,a5,1
    80003f1e:	0007069b          	sext.w	a3,a4
    80003f22:	0027179b          	slliw	a5,a4,0x2
    80003f26:	9fb9                	addw	a5,a5,a4
    80003f28:	0017979b          	slliw	a5,a5,0x1
    80003f2c:	54d8                	lw	a4,44(s1)
    80003f2e:	9fb9                	addw	a5,a5,a4
    80003f30:	00f95963          	bge	s2,a5,80003f42 <begin_op+0x62>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    80003f34:	85a6                	mv	a1,s1
    80003f36:	8526                	mv	a0,s1
    80003f38:	ffffe097          	auipc	ra,0xffffe
    80003f3c:	0b2080e7          	jalr	178(ra) # 80001fea <sleep>
    80003f40:	bfd1                	j	80003f14 <begin_op+0x34>
    } else {
      log.outstanding += 1;
    80003f42:	0001e517          	auipc	a0,0x1e
    80003f46:	c5650513          	addi	a0,a0,-938 # 80021b98 <log>
    80003f4a:	d114                	sw	a3,32(a0)
      release(&log.lock);
    80003f4c:	ffffd097          	auipc	ra,0xffffd
    80003f50:	bda080e7          	jalr	-1062(ra) # 80000b26 <release>
      break;
    }
  }
}
    80003f54:	60e2                	ld	ra,24(sp)
    80003f56:	6442                	ld	s0,16(sp)
    80003f58:	64a2                	ld	s1,8(sp)
    80003f5a:	6902                	ld	s2,0(sp)
    80003f5c:	6105                	addi	sp,sp,32
    80003f5e:	8082                	ret

0000000080003f60 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    80003f60:	7139                	addi	sp,sp,-64
    80003f62:	fc06                	sd	ra,56(sp)
    80003f64:	f822                	sd	s0,48(sp)
    80003f66:	f426                	sd	s1,40(sp)
    80003f68:	f04a                	sd	s2,32(sp)
    80003f6a:	ec4e                	sd	s3,24(sp)
    80003f6c:	e852                	sd	s4,16(sp)
    80003f6e:	e456                	sd	s5,8(sp)
    80003f70:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    80003f72:	0001e497          	auipc	s1,0x1e
    80003f76:	c2648493          	addi	s1,s1,-986 # 80021b98 <log>
    80003f7a:	8526                	mv	a0,s1
    80003f7c:	ffffd097          	auipc	ra,0xffffd
    80003f80:	b56080e7          	jalr	-1194(ra) # 80000ad2 <acquire>
  log.outstanding -= 1;
    80003f84:	509c                	lw	a5,32(s1)
    80003f86:	37fd                	addiw	a5,a5,-1
    80003f88:	0007891b          	sext.w	s2,a5
    80003f8c:	d09c                	sw	a5,32(s1)
  if(log.committing)
    80003f8e:	50dc                	lw	a5,36(s1)
    80003f90:	efb9                	bnez	a5,80003fee <end_op+0x8e>
    panic("log.committing");
  if(log.outstanding == 0){
    80003f92:	06091663          	bnez	s2,80003ffe <end_op+0x9e>
    do_commit = 1;
    log.committing = 1;
    80003f96:	0001e497          	auipc	s1,0x1e
    80003f9a:	c0248493          	addi	s1,s1,-1022 # 80021b98 <log>
    80003f9e:	4785                	li	a5,1
    80003fa0:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80003fa2:	8526                	mv	a0,s1
    80003fa4:	ffffd097          	auipc	ra,0xffffd
    80003fa8:	b82080e7          	jalr	-1150(ra) # 80000b26 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80003fac:	54dc                	lw	a5,44(s1)
    80003fae:	06f04763          	bgtz	a5,8000401c <end_op+0xbc>
    acquire(&log.lock);
    80003fb2:	0001e497          	auipc	s1,0x1e
    80003fb6:	be648493          	addi	s1,s1,-1050 # 80021b98 <log>
    80003fba:	8526                	mv	a0,s1
    80003fbc:	ffffd097          	auipc	ra,0xffffd
    80003fc0:	b16080e7          	jalr	-1258(ra) # 80000ad2 <acquire>
    log.committing = 0;
    80003fc4:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    80003fc8:	8526                	mv	a0,s1
    80003fca:	ffffe097          	auipc	ra,0xffffe
    80003fce:	1a6080e7          	jalr	422(ra) # 80002170 <wakeup>
    release(&log.lock);
    80003fd2:	8526                	mv	a0,s1
    80003fd4:	ffffd097          	auipc	ra,0xffffd
    80003fd8:	b52080e7          	jalr	-1198(ra) # 80000b26 <release>
}
    80003fdc:	70e2                	ld	ra,56(sp)
    80003fde:	7442                	ld	s0,48(sp)
    80003fe0:	74a2                	ld	s1,40(sp)
    80003fe2:	7902                	ld	s2,32(sp)
    80003fe4:	69e2                	ld	s3,24(sp)
    80003fe6:	6a42                	ld	s4,16(sp)
    80003fe8:	6aa2                	ld	s5,8(sp)
    80003fea:	6121                	addi	sp,sp,64
    80003fec:	8082                	ret
    panic("log.committing");
    80003fee:	00003517          	auipc	a0,0x3
    80003ff2:	64250513          	addi	a0,a0,1602 # 80007630 <userret+0x5a0>
    80003ff6:	ffffc097          	auipc	ra,0xffffc
    80003ffa:	558080e7          	jalr	1368(ra) # 8000054e <panic>
    wakeup(&log);
    80003ffe:	0001e497          	auipc	s1,0x1e
    80004002:	b9a48493          	addi	s1,s1,-1126 # 80021b98 <log>
    80004006:	8526                	mv	a0,s1
    80004008:	ffffe097          	auipc	ra,0xffffe
    8000400c:	168080e7          	jalr	360(ra) # 80002170 <wakeup>
  release(&log.lock);
    80004010:	8526                	mv	a0,s1
    80004012:	ffffd097          	auipc	ra,0xffffd
    80004016:	b14080e7          	jalr	-1260(ra) # 80000b26 <release>
  if(do_commit){
    8000401a:	b7c9                	j	80003fdc <end_op+0x7c>
  for (tail = 0; tail < log.lh.n; tail++) {
    8000401c:	0001ea97          	auipc	s5,0x1e
    80004020:	baca8a93          	addi	s5,s5,-1108 # 80021bc8 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    80004024:	0001ea17          	auipc	s4,0x1e
    80004028:	b74a0a13          	addi	s4,s4,-1164 # 80021b98 <log>
    8000402c:	018a2583          	lw	a1,24(s4)
    80004030:	012585bb          	addw	a1,a1,s2
    80004034:	2585                	addiw	a1,a1,1
    80004036:	028a2503          	lw	a0,40(s4)
    8000403a:	fffff097          	auipc	ra,0xfffff
    8000403e:	d0e080e7          	jalr	-754(ra) # 80002d48 <bread>
    80004042:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80004044:	000aa583          	lw	a1,0(s5)
    80004048:	028a2503          	lw	a0,40(s4)
    8000404c:	fffff097          	auipc	ra,0xfffff
    80004050:	cfc080e7          	jalr	-772(ra) # 80002d48 <bread>
    80004054:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80004056:	40000613          	li	a2,1024
    8000405a:	06050593          	addi	a1,a0,96
    8000405e:	06048513          	addi	a0,s1,96
    80004062:	ffffd097          	auipc	ra,0xffffd
    80004066:	b6c080e7          	jalr	-1172(ra) # 80000bce <memmove>
    bwrite(to);  // write the log
    8000406a:	8526                	mv	a0,s1
    8000406c:	fffff097          	auipc	ra,0xfffff
    80004070:	dce080e7          	jalr	-562(ra) # 80002e3a <bwrite>
    brelse(from);
    80004074:	854e                	mv	a0,s3
    80004076:	fffff097          	auipc	ra,0xfffff
    8000407a:	e02080e7          	jalr	-510(ra) # 80002e78 <brelse>
    brelse(to);
    8000407e:	8526                	mv	a0,s1
    80004080:	fffff097          	auipc	ra,0xfffff
    80004084:	df8080e7          	jalr	-520(ra) # 80002e78 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004088:	2905                	addiw	s2,s2,1
    8000408a:	0a91                	addi	s5,s5,4
    8000408c:	02ca2783          	lw	a5,44(s4)
    80004090:	f8f94ee3          	blt	s2,a5,8000402c <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    80004094:	00000097          	auipc	ra,0x0
    80004098:	c7a080e7          	jalr	-902(ra) # 80003d0e <write_head>
    install_trans(); // Now install writes to home locations
    8000409c:	00000097          	auipc	ra,0x0
    800040a0:	cec080e7          	jalr	-788(ra) # 80003d88 <install_trans>
    log.lh.n = 0;
    800040a4:	0001e797          	auipc	a5,0x1e
    800040a8:	b207a023          	sw	zero,-1248(a5) # 80021bc4 <log+0x2c>
    write_head();    // Erase the transaction from the log
    800040ac:	00000097          	auipc	ra,0x0
    800040b0:	c62080e7          	jalr	-926(ra) # 80003d0e <write_head>
    800040b4:	bdfd                	j	80003fb2 <end_op+0x52>

00000000800040b6 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    800040b6:	1101                	addi	sp,sp,-32
    800040b8:	ec06                	sd	ra,24(sp)
    800040ba:	e822                	sd	s0,16(sp)
    800040bc:	e426                	sd	s1,8(sp)
    800040be:	e04a                	sd	s2,0(sp)
    800040c0:	1000                	addi	s0,sp,32
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    800040c2:	0001e717          	auipc	a4,0x1e
    800040c6:	b0272703          	lw	a4,-1278(a4) # 80021bc4 <log+0x2c>
    800040ca:	47f5                	li	a5,29
    800040cc:	08e7c063          	blt	a5,a4,8000414c <log_write+0x96>
    800040d0:	84aa                	mv	s1,a0
    800040d2:	0001e797          	auipc	a5,0x1e
    800040d6:	ae27a783          	lw	a5,-1310(a5) # 80021bb4 <log+0x1c>
    800040da:	37fd                	addiw	a5,a5,-1
    800040dc:	06f75863          	bge	a4,a5,8000414c <log_write+0x96>
    panic("too big a transaction");
  if (log.outstanding < 1)
    800040e0:	0001e797          	auipc	a5,0x1e
    800040e4:	ad87a783          	lw	a5,-1320(a5) # 80021bb8 <log+0x20>
    800040e8:	06f05a63          	blez	a5,8000415c <log_write+0xa6>
    panic("log_write outside of trans");

  acquire(&log.lock);
    800040ec:	0001e917          	auipc	s2,0x1e
    800040f0:	aac90913          	addi	s2,s2,-1364 # 80021b98 <log>
    800040f4:	854a                	mv	a0,s2
    800040f6:	ffffd097          	auipc	ra,0xffffd
    800040fa:	9dc080e7          	jalr	-1572(ra) # 80000ad2 <acquire>
  for (i = 0; i < log.lh.n; i++) {
    800040fe:	02c92603          	lw	a2,44(s2)
    80004102:	06c05563          	blez	a2,8000416c <log_write+0xb6>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
    80004106:	44cc                	lw	a1,12(s1)
    80004108:	0001e717          	auipc	a4,0x1e
    8000410c:	ac070713          	addi	a4,a4,-1344 # 80021bc8 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    80004110:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorbtion
    80004112:	4314                	lw	a3,0(a4)
    80004114:	04b68d63          	beq	a3,a1,8000416e <log_write+0xb8>
  for (i = 0; i < log.lh.n; i++) {
    80004118:	2785                	addiw	a5,a5,1
    8000411a:	0711                	addi	a4,a4,4
    8000411c:	fec79be3          	bne	a5,a2,80004112 <log_write+0x5c>
      break;
  }
  log.lh.block[i] = b->blockno;
    80004120:	0621                	addi	a2,a2,8
    80004122:	060a                	slli	a2,a2,0x2
    80004124:	0001e797          	auipc	a5,0x1e
    80004128:	a7478793          	addi	a5,a5,-1420 # 80021b98 <log>
    8000412c:	963e                	add	a2,a2,a5
    8000412e:	44dc                	lw	a5,12(s1)
    80004130:	ca1c                	sw	a5,16(a2)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    80004132:	8526                	mv	a0,s1
    80004134:	fffff097          	auipc	ra,0xfffff
    80004138:	de2080e7          	jalr	-542(ra) # 80002f16 <bpin>
    log.lh.n++;
    8000413c:	0001e717          	auipc	a4,0x1e
    80004140:	a5c70713          	addi	a4,a4,-1444 # 80021b98 <log>
    80004144:	575c                	lw	a5,44(a4)
    80004146:	2785                	addiw	a5,a5,1
    80004148:	d75c                	sw	a5,44(a4)
    8000414a:	a83d                	j	80004188 <log_write+0xd2>
    panic("too big a transaction");
    8000414c:	00003517          	auipc	a0,0x3
    80004150:	4f450513          	addi	a0,a0,1268 # 80007640 <userret+0x5b0>
    80004154:	ffffc097          	auipc	ra,0xffffc
    80004158:	3fa080e7          	jalr	1018(ra) # 8000054e <panic>
    panic("log_write outside of trans");
    8000415c:	00003517          	auipc	a0,0x3
    80004160:	4fc50513          	addi	a0,a0,1276 # 80007658 <userret+0x5c8>
    80004164:	ffffc097          	auipc	ra,0xffffc
    80004168:	3ea080e7          	jalr	1002(ra) # 8000054e <panic>
  for (i = 0; i < log.lh.n; i++) {
    8000416c:	4781                	li	a5,0
  log.lh.block[i] = b->blockno;
    8000416e:	00878713          	addi	a4,a5,8
    80004172:	00271693          	slli	a3,a4,0x2
    80004176:	0001e717          	auipc	a4,0x1e
    8000417a:	a2270713          	addi	a4,a4,-1502 # 80021b98 <log>
    8000417e:	9736                	add	a4,a4,a3
    80004180:	44d4                	lw	a3,12(s1)
    80004182:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    80004184:	faf607e3          	beq	a2,a5,80004132 <log_write+0x7c>
  }
  release(&log.lock);
    80004188:	0001e517          	auipc	a0,0x1e
    8000418c:	a1050513          	addi	a0,a0,-1520 # 80021b98 <log>
    80004190:	ffffd097          	auipc	ra,0xffffd
    80004194:	996080e7          	jalr	-1642(ra) # 80000b26 <release>
}
    80004198:	60e2                	ld	ra,24(sp)
    8000419a:	6442                	ld	s0,16(sp)
    8000419c:	64a2                	ld	s1,8(sp)
    8000419e:	6902                	ld	s2,0(sp)
    800041a0:	6105                	addi	sp,sp,32
    800041a2:	8082                	ret

00000000800041a4 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    800041a4:	1101                	addi	sp,sp,-32
    800041a6:	ec06                	sd	ra,24(sp)
    800041a8:	e822                	sd	s0,16(sp)
    800041aa:	e426                	sd	s1,8(sp)
    800041ac:	e04a                	sd	s2,0(sp)
    800041ae:	1000                	addi	s0,sp,32
    800041b0:	84aa                	mv	s1,a0
    800041b2:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    800041b4:	00003597          	auipc	a1,0x3
    800041b8:	4c458593          	addi	a1,a1,1220 # 80007678 <userret+0x5e8>
    800041bc:	0521                	addi	a0,a0,8
    800041be:	ffffd097          	auipc	ra,0xffffd
    800041c2:	802080e7          	jalr	-2046(ra) # 800009c0 <initlock>
  lk->name = name;
    800041c6:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    800041ca:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800041ce:	0204a423          	sw	zero,40(s1)
}
    800041d2:	60e2                	ld	ra,24(sp)
    800041d4:	6442                	ld	s0,16(sp)
    800041d6:	64a2                	ld	s1,8(sp)
    800041d8:	6902                	ld	s2,0(sp)
    800041da:	6105                	addi	sp,sp,32
    800041dc:	8082                	ret

00000000800041de <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    800041de:	1101                	addi	sp,sp,-32
    800041e0:	ec06                	sd	ra,24(sp)
    800041e2:	e822                	sd	s0,16(sp)
    800041e4:	e426                	sd	s1,8(sp)
    800041e6:	e04a                	sd	s2,0(sp)
    800041e8:	1000                	addi	s0,sp,32
    800041ea:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800041ec:	00850913          	addi	s2,a0,8
    800041f0:	854a                	mv	a0,s2
    800041f2:	ffffd097          	auipc	ra,0xffffd
    800041f6:	8e0080e7          	jalr	-1824(ra) # 80000ad2 <acquire>
  while (lk->locked) {
    800041fa:	409c                	lw	a5,0(s1)
    800041fc:	cb89                	beqz	a5,8000420e <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    800041fe:	85ca                	mv	a1,s2
    80004200:	8526                	mv	a0,s1
    80004202:	ffffe097          	auipc	ra,0xffffe
    80004206:	de8080e7          	jalr	-536(ra) # 80001fea <sleep>
  while (lk->locked) {
    8000420a:	409c                	lw	a5,0(s1)
    8000420c:	fbed                	bnez	a5,800041fe <acquiresleep+0x20>
  }
  lk->locked = 1;
    8000420e:	4785                	li	a5,1
    80004210:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80004212:	ffffd097          	auipc	ra,0xffffd
    80004216:	632080e7          	jalr	1586(ra) # 80001844 <myproc>
    8000421a:	5d1c                	lw	a5,56(a0)
    8000421c:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    8000421e:	854a                	mv	a0,s2
    80004220:	ffffd097          	auipc	ra,0xffffd
    80004224:	906080e7          	jalr	-1786(ra) # 80000b26 <release>
}
    80004228:	60e2                	ld	ra,24(sp)
    8000422a:	6442                	ld	s0,16(sp)
    8000422c:	64a2                	ld	s1,8(sp)
    8000422e:	6902                	ld	s2,0(sp)
    80004230:	6105                	addi	sp,sp,32
    80004232:	8082                	ret

0000000080004234 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80004234:	1101                	addi	sp,sp,-32
    80004236:	ec06                	sd	ra,24(sp)
    80004238:	e822                	sd	s0,16(sp)
    8000423a:	e426                	sd	s1,8(sp)
    8000423c:	e04a                	sd	s2,0(sp)
    8000423e:	1000                	addi	s0,sp,32
    80004240:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004242:	00850913          	addi	s2,a0,8
    80004246:	854a                	mv	a0,s2
    80004248:	ffffd097          	auipc	ra,0xffffd
    8000424c:	88a080e7          	jalr	-1910(ra) # 80000ad2 <acquire>
  lk->locked = 0;
    80004250:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004254:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80004258:	8526                	mv	a0,s1
    8000425a:	ffffe097          	auipc	ra,0xffffe
    8000425e:	f16080e7          	jalr	-234(ra) # 80002170 <wakeup>
  release(&lk->lk);
    80004262:	854a                	mv	a0,s2
    80004264:	ffffd097          	auipc	ra,0xffffd
    80004268:	8c2080e7          	jalr	-1854(ra) # 80000b26 <release>
}
    8000426c:	60e2                	ld	ra,24(sp)
    8000426e:	6442                	ld	s0,16(sp)
    80004270:	64a2                	ld	s1,8(sp)
    80004272:	6902                	ld	s2,0(sp)
    80004274:	6105                	addi	sp,sp,32
    80004276:	8082                	ret

0000000080004278 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80004278:	7179                	addi	sp,sp,-48
    8000427a:	f406                	sd	ra,40(sp)
    8000427c:	f022                	sd	s0,32(sp)
    8000427e:	ec26                	sd	s1,24(sp)
    80004280:	e84a                	sd	s2,16(sp)
    80004282:	e44e                	sd	s3,8(sp)
    80004284:	1800                	addi	s0,sp,48
    80004286:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80004288:	00850913          	addi	s2,a0,8
    8000428c:	854a                	mv	a0,s2
    8000428e:	ffffd097          	auipc	ra,0xffffd
    80004292:	844080e7          	jalr	-1980(ra) # 80000ad2 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80004296:	409c                	lw	a5,0(s1)
    80004298:	ef99                	bnez	a5,800042b6 <holdingsleep+0x3e>
    8000429a:	4481                	li	s1,0
  release(&lk->lk);
    8000429c:	854a                	mv	a0,s2
    8000429e:	ffffd097          	auipc	ra,0xffffd
    800042a2:	888080e7          	jalr	-1912(ra) # 80000b26 <release>
  return r;
}
    800042a6:	8526                	mv	a0,s1
    800042a8:	70a2                	ld	ra,40(sp)
    800042aa:	7402                	ld	s0,32(sp)
    800042ac:	64e2                	ld	s1,24(sp)
    800042ae:	6942                	ld	s2,16(sp)
    800042b0:	69a2                	ld	s3,8(sp)
    800042b2:	6145                	addi	sp,sp,48
    800042b4:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    800042b6:	0284a983          	lw	s3,40(s1)
    800042ba:	ffffd097          	auipc	ra,0xffffd
    800042be:	58a080e7          	jalr	1418(ra) # 80001844 <myproc>
    800042c2:	5d04                	lw	s1,56(a0)
    800042c4:	413484b3          	sub	s1,s1,s3
    800042c8:	0014b493          	seqz	s1,s1
    800042cc:	bfc1                	j	8000429c <holdingsleep+0x24>

00000000800042ce <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    800042ce:	1141                	addi	sp,sp,-16
    800042d0:	e406                	sd	ra,8(sp)
    800042d2:	e022                	sd	s0,0(sp)
    800042d4:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    800042d6:	00003597          	auipc	a1,0x3
    800042da:	3b258593          	addi	a1,a1,946 # 80007688 <userret+0x5f8>
    800042de:	0001e517          	auipc	a0,0x1e
    800042e2:	a0250513          	addi	a0,a0,-1534 # 80021ce0 <ftable>
    800042e6:	ffffc097          	auipc	ra,0xffffc
    800042ea:	6da080e7          	jalr	1754(ra) # 800009c0 <initlock>
}
    800042ee:	60a2                	ld	ra,8(sp)
    800042f0:	6402                	ld	s0,0(sp)
    800042f2:	0141                	addi	sp,sp,16
    800042f4:	8082                	ret

00000000800042f6 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    800042f6:	1101                	addi	sp,sp,-32
    800042f8:	ec06                	sd	ra,24(sp)
    800042fa:	e822                	sd	s0,16(sp)
    800042fc:	e426                	sd	s1,8(sp)
    800042fe:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80004300:	0001e517          	auipc	a0,0x1e
    80004304:	9e050513          	addi	a0,a0,-1568 # 80021ce0 <ftable>
    80004308:	ffffc097          	auipc	ra,0xffffc
    8000430c:	7ca080e7          	jalr	1994(ra) # 80000ad2 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004310:	0001e497          	auipc	s1,0x1e
    80004314:	9e848493          	addi	s1,s1,-1560 # 80021cf8 <ftable+0x18>
    80004318:	0001f717          	auipc	a4,0x1f
    8000431c:	98070713          	addi	a4,a4,-1664 # 80022c98 <ftable+0xfb8>
    if(f->ref == 0){
    80004320:	40dc                	lw	a5,4(s1)
    80004322:	cf99                	beqz	a5,80004340 <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004324:	02848493          	addi	s1,s1,40
    80004328:	fee49ce3          	bne	s1,a4,80004320 <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    8000432c:	0001e517          	auipc	a0,0x1e
    80004330:	9b450513          	addi	a0,a0,-1612 # 80021ce0 <ftable>
    80004334:	ffffc097          	auipc	ra,0xffffc
    80004338:	7f2080e7          	jalr	2034(ra) # 80000b26 <release>
  return 0;
    8000433c:	4481                	li	s1,0
    8000433e:	a819                	j	80004354 <filealloc+0x5e>
      f->ref = 1;
    80004340:	4785                	li	a5,1
    80004342:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80004344:	0001e517          	auipc	a0,0x1e
    80004348:	99c50513          	addi	a0,a0,-1636 # 80021ce0 <ftable>
    8000434c:	ffffc097          	auipc	ra,0xffffc
    80004350:	7da080e7          	jalr	2010(ra) # 80000b26 <release>
}
    80004354:	8526                	mv	a0,s1
    80004356:	60e2                	ld	ra,24(sp)
    80004358:	6442                	ld	s0,16(sp)
    8000435a:	64a2                	ld	s1,8(sp)
    8000435c:	6105                	addi	sp,sp,32
    8000435e:	8082                	ret

0000000080004360 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80004360:	1101                	addi	sp,sp,-32
    80004362:	ec06                	sd	ra,24(sp)
    80004364:	e822                	sd	s0,16(sp)
    80004366:	e426                	sd	s1,8(sp)
    80004368:	1000                	addi	s0,sp,32
    8000436a:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    8000436c:	0001e517          	auipc	a0,0x1e
    80004370:	97450513          	addi	a0,a0,-1676 # 80021ce0 <ftable>
    80004374:	ffffc097          	auipc	ra,0xffffc
    80004378:	75e080e7          	jalr	1886(ra) # 80000ad2 <acquire>
  if(f->ref < 1)
    8000437c:	40dc                	lw	a5,4(s1)
    8000437e:	02f05263          	blez	a5,800043a2 <filedup+0x42>
    panic("filedup");
  f->ref++;
    80004382:	2785                	addiw	a5,a5,1
    80004384:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80004386:	0001e517          	auipc	a0,0x1e
    8000438a:	95a50513          	addi	a0,a0,-1702 # 80021ce0 <ftable>
    8000438e:	ffffc097          	auipc	ra,0xffffc
    80004392:	798080e7          	jalr	1944(ra) # 80000b26 <release>
  return f;
}
    80004396:	8526                	mv	a0,s1
    80004398:	60e2                	ld	ra,24(sp)
    8000439a:	6442                	ld	s0,16(sp)
    8000439c:	64a2                	ld	s1,8(sp)
    8000439e:	6105                	addi	sp,sp,32
    800043a0:	8082                	ret
    panic("filedup");
    800043a2:	00003517          	auipc	a0,0x3
    800043a6:	2ee50513          	addi	a0,a0,750 # 80007690 <userret+0x600>
    800043aa:	ffffc097          	auipc	ra,0xffffc
    800043ae:	1a4080e7          	jalr	420(ra) # 8000054e <panic>

00000000800043b2 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    800043b2:	7139                	addi	sp,sp,-64
    800043b4:	fc06                	sd	ra,56(sp)
    800043b6:	f822                	sd	s0,48(sp)
    800043b8:	f426                	sd	s1,40(sp)
    800043ba:	f04a                	sd	s2,32(sp)
    800043bc:	ec4e                	sd	s3,24(sp)
    800043be:	e852                	sd	s4,16(sp)
    800043c0:	e456                	sd	s5,8(sp)
    800043c2:	0080                	addi	s0,sp,64
    800043c4:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    800043c6:	0001e517          	auipc	a0,0x1e
    800043ca:	91a50513          	addi	a0,a0,-1766 # 80021ce0 <ftable>
    800043ce:	ffffc097          	auipc	ra,0xffffc
    800043d2:	704080e7          	jalr	1796(ra) # 80000ad2 <acquire>
  if(f->ref < 1)
    800043d6:	40dc                	lw	a5,4(s1)
    800043d8:	06f05163          	blez	a5,8000443a <fileclose+0x88>
    panic("fileclose");
  if(--f->ref > 0){
    800043dc:	37fd                	addiw	a5,a5,-1
    800043de:	0007871b          	sext.w	a4,a5
    800043e2:	c0dc                	sw	a5,4(s1)
    800043e4:	06e04363          	bgtz	a4,8000444a <fileclose+0x98>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    800043e8:	0004a903          	lw	s2,0(s1)
    800043ec:	0094ca83          	lbu	s5,9(s1)
    800043f0:	0104ba03          	ld	s4,16(s1)
    800043f4:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    800043f8:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    800043fc:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80004400:	0001e517          	auipc	a0,0x1e
    80004404:	8e050513          	addi	a0,a0,-1824 # 80021ce0 <ftable>
    80004408:	ffffc097          	auipc	ra,0xffffc
    8000440c:	71e080e7          	jalr	1822(ra) # 80000b26 <release>

  if(ff.type == FD_PIPE){
    80004410:	4785                	li	a5,1
    80004412:	04f90d63          	beq	s2,a5,8000446c <fileclose+0xba>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80004416:	3979                	addiw	s2,s2,-2
    80004418:	4785                	li	a5,1
    8000441a:	0527e063          	bltu	a5,s2,8000445a <fileclose+0xa8>
    begin_op();
    8000441e:	00000097          	auipc	ra,0x0
    80004422:	ac2080e7          	jalr	-1342(ra) # 80003ee0 <begin_op>
    iput(ff.ip);
    80004426:	854e                	mv	a0,s3
    80004428:	fffff097          	auipc	ra,0xfffff
    8000442c:	230080e7          	jalr	560(ra) # 80003658 <iput>
    end_op();
    80004430:	00000097          	auipc	ra,0x0
    80004434:	b30080e7          	jalr	-1232(ra) # 80003f60 <end_op>
    80004438:	a00d                	j	8000445a <fileclose+0xa8>
    panic("fileclose");
    8000443a:	00003517          	auipc	a0,0x3
    8000443e:	25e50513          	addi	a0,a0,606 # 80007698 <userret+0x608>
    80004442:	ffffc097          	auipc	ra,0xffffc
    80004446:	10c080e7          	jalr	268(ra) # 8000054e <panic>
    release(&ftable.lock);
    8000444a:	0001e517          	auipc	a0,0x1e
    8000444e:	89650513          	addi	a0,a0,-1898 # 80021ce0 <ftable>
    80004452:	ffffc097          	auipc	ra,0xffffc
    80004456:	6d4080e7          	jalr	1748(ra) # 80000b26 <release>
  }
}
    8000445a:	70e2                	ld	ra,56(sp)
    8000445c:	7442                	ld	s0,48(sp)
    8000445e:	74a2                	ld	s1,40(sp)
    80004460:	7902                	ld	s2,32(sp)
    80004462:	69e2                	ld	s3,24(sp)
    80004464:	6a42                	ld	s4,16(sp)
    80004466:	6aa2                	ld	s5,8(sp)
    80004468:	6121                	addi	sp,sp,64
    8000446a:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    8000446c:	85d6                	mv	a1,s5
    8000446e:	8552                	mv	a0,s4
    80004470:	00000097          	auipc	ra,0x0
    80004474:	372080e7          	jalr	882(ra) # 800047e2 <pipeclose>
    80004478:	b7cd                	j	8000445a <fileclose+0xa8>

000000008000447a <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    8000447a:	715d                	addi	sp,sp,-80
    8000447c:	e486                	sd	ra,72(sp)
    8000447e:	e0a2                	sd	s0,64(sp)
    80004480:	fc26                	sd	s1,56(sp)
    80004482:	f84a                	sd	s2,48(sp)
    80004484:	f44e                	sd	s3,40(sp)
    80004486:	0880                	addi	s0,sp,80
    80004488:	84aa                	mv	s1,a0
    8000448a:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    8000448c:	ffffd097          	auipc	ra,0xffffd
    80004490:	3b8080e7          	jalr	952(ra) # 80001844 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80004494:	409c                	lw	a5,0(s1)
    80004496:	37f9                	addiw	a5,a5,-2
    80004498:	4705                	li	a4,1
    8000449a:	04f76763          	bltu	a4,a5,800044e8 <filestat+0x6e>
    8000449e:	892a                	mv	s2,a0
    ilock(f->ip);
    800044a0:	6c88                	ld	a0,24(s1)
    800044a2:	fffff097          	auipc	ra,0xfffff
    800044a6:	0a8080e7          	jalr	168(ra) # 8000354a <ilock>
    stati(f->ip, &st);
    800044aa:	fb840593          	addi	a1,s0,-72
    800044ae:	6c88                	ld	a0,24(s1)
    800044b0:	fffff097          	auipc	ra,0xfffff
    800044b4:	300080e7          	jalr	768(ra) # 800037b0 <stati>
    iunlock(f->ip);
    800044b8:	6c88                	ld	a0,24(s1)
    800044ba:	fffff097          	auipc	ra,0xfffff
    800044be:	152080e7          	jalr	338(ra) # 8000360c <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    800044c2:	46e1                	li	a3,24
    800044c4:	fb840613          	addi	a2,s0,-72
    800044c8:	85ce                	mv	a1,s3
    800044ca:	05093503          	ld	a0,80(s2)
    800044ce:	ffffd097          	auipc	ra,0xffffd
    800044d2:	06a080e7          	jalr	106(ra) # 80001538 <copyout>
    800044d6:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    800044da:	60a6                	ld	ra,72(sp)
    800044dc:	6406                	ld	s0,64(sp)
    800044de:	74e2                	ld	s1,56(sp)
    800044e0:	7942                	ld	s2,48(sp)
    800044e2:	79a2                	ld	s3,40(sp)
    800044e4:	6161                	addi	sp,sp,80
    800044e6:	8082                	ret
  return -1;
    800044e8:	557d                	li	a0,-1
    800044ea:	bfc5                	j	800044da <filestat+0x60>

00000000800044ec <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    800044ec:	7179                	addi	sp,sp,-48
    800044ee:	f406                	sd	ra,40(sp)
    800044f0:	f022                	sd	s0,32(sp)
    800044f2:	ec26                	sd	s1,24(sp)
    800044f4:	e84a                	sd	s2,16(sp)
    800044f6:	e44e                	sd	s3,8(sp)
    800044f8:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    800044fa:	00854783          	lbu	a5,8(a0)
    800044fe:	c3d5                	beqz	a5,800045a2 <fileread+0xb6>
    80004500:	84aa                	mv	s1,a0
    80004502:	89ae                	mv	s3,a1
    80004504:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    80004506:	411c                	lw	a5,0(a0)
    80004508:	4705                	li	a4,1
    8000450a:	04e78963          	beq	a5,a4,8000455c <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    8000450e:	470d                	li	a4,3
    80004510:	04e78d63          	beq	a5,a4,8000456a <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80004514:	4709                	li	a4,2
    80004516:	06e79e63          	bne	a5,a4,80004592 <fileread+0xa6>
    ilock(f->ip);
    8000451a:	6d08                	ld	a0,24(a0)
    8000451c:	fffff097          	auipc	ra,0xfffff
    80004520:	02e080e7          	jalr	46(ra) # 8000354a <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80004524:	874a                	mv	a4,s2
    80004526:	5094                	lw	a3,32(s1)
    80004528:	864e                	mv	a2,s3
    8000452a:	4585                	li	a1,1
    8000452c:	6c88                	ld	a0,24(s1)
    8000452e:	fffff097          	auipc	ra,0xfffff
    80004532:	2ac080e7          	jalr	684(ra) # 800037da <readi>
    80004536:	892a                	mv	s2,a0
    80004538:	00a05563          	blez	a0,80004542 <fileread+0x56>
      f->off += r;
    8000453c:	509c                	lw	a5,32(s1)
    8000453e:	9fa9                	addw	a5,a5,a0
    80004540:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80004542:	6c88                	ld	a0,24(s1)
    80004544:	fffff097          	auipc	ra,0xfffff
    80004548:	0c8080e7          	jalr	200(ra) # 8000360c <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    8000454c:	854a                	mv	a0,s2
    8000454e:	70a2                	ld	ra,40(sp)
    80004550:	7402                	ld	s0,32(sp)
    80004552:	64e2                	ld	s1,24(sp)
    80004554:	6942                	ld	s2,16(sp)
    80004556:	69a2                	ld	s3,8(sp)
    80004558:	6145                	addi	sp,sp,48
    8000455a:	8082                	ret
    r = piperead(f->pipe, addr, n);
    8000455c:	6908                	ld	a0,16(a0)
    8000455e:	00000097          	auipc	ra,0x0
    80004562:	408080e7          	jalr	1032(ra) # 80004966 <piperead>
    80004566:	892a                	mv	s2,a0
    80004568:	b7d5                	j	8000454c <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    8000456a:	02451783          	lh	a5,36(a0)
    8000456e:	03079693          	slli	a3,a5,0x30
    80004572:	92c1                	srli	a3,a3,0x30
    80004574:	4725                	li	a4,9
    80004576:	02d76863          	bltu	a4,a3,800045a6 <fileread+0xba>
    8000457a:	0792                	slli	a5,a5,0x4
    8000457c:	0001d717          	auipc	a4,0x1d
    80004580:	6c470713          	addi	a4,a4,1732 # 80021c40 <devsw>
    80004584:	97ba                	add	a5,a5,a4
    80004586:	639c                	ld	a5,0(a5)
    80004588:	c38d                	beqz	a5,800045aa <fileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    8000458a:	4505                	li	a0,1
    8000458c:	9782                	jalr	a5
    8000458e:	892a                	mv	s2,a0
    80004590:	bf75                	j	8000454c <fileread+0x60>
    panic("fileread");
    80004592:	00003517          	auipc	a0,0x3
    80004596:	11650513          	addi	a0,a0,278 # 800076a8 <userret+0x618>
    8000459a:	ffffc097          	auipc	ra,0xffffc
    8000459e:	fb4080e7          	jalr	-76(ra) # 8000054e <panic>
    return -1;
    800045a2:	597d                	li	s2,-1
    800045a4:	b765                	j	8000454c <fileread+0x60>
      return -1;
    800045a6:	597d                	li	s2,-1
    800045a8:	b755                	j	8000454c <fileread+0x60>
    800045aa:	597d                	li	s2,-1
    800045ac:	b745                	j	8000454c <fileread+0x60>

00000000800045ae <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if(f->writable == 0)
    800045ae:	00954783          	lbu	a5,9(a0)
    800045b2:	14078563          	beqz	a5,800046fc <filewrite+0x14e>
{
    800045b6:	715d                	addi	sp,sp,-80
    800045b8:	e486                	sd	ra,72(sp)
    800045ba:	e0a2                	sd	s0,64(sp)
    800045bc:	fc26                	sd	s1,56(sp)
    800045be:	f84a                	sd	s2,48(sp)
    800045c0:	f44e                	sd	s3,40(sp)
    800045c2:	f052                	sd	s4,32(sp)
    800045c4:	ec56                	sd	s5,24(sp)
    800045c6:	e85a                	sd	s6,16(sp)
    800045c8:	e45e                	sd	s7,8(sp)
    800045ca:	e062                	sd	s8,0(sp)
    800045cc:	0880                	addi	s0,sp,80
    800045ce:	892a                	mv	s2,a0
    800045d0:	8aae                	mv	s5,a1
    800045d2:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    800045d4:	411c                	lw	a5,0(a0)
    800045d6:	4705                	li	a4,1
    800045d8:	02e78263          	beq	a5,a4,800045fc <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    800045dc:	470d                	li	a4,3
    800045de:	02e78563          	beq	a5,a4,80004608 <filewrite+0x5a>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    800045e2:	4709                	li	a4,2
    800045e4:	10e79463          	bne	a5,a4,800046ec <filewrite+0x13e>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    800045e8:	0ec05e63          	blez	a2,800046e4 <filewrite+0x136>
    int i = 0;
    800045ec:	4981                	li	s3,0
    800045ee:	6b05                	lui	s6,0x1
    800045f0:	c00b0b13          	addi	s6,s6,-1024 # c00 <_entry-0x7ffff400>
    800045f4:	6b85                	lui	s7,0x1
    800045f6:	c00b8b9b          	addiw	s7,s7,-1024
    800045fa:	a851                	j	8000468e <filewrite+0xe0>
    ret = pipewrite(f->pipe, addr, n);
    800045fc:	6908                	ld	a0,16(a0)
    800045fe:	00000097          	auipc	ra,0x0
    80004602:	254080e7          	jalr	596(ra) # 80004852 <pipewrite>
    80004606:	a85d                	j	800046bc <filewrite+0x10e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80004608:	02451783          	lh	a5,36(a0)
    8000460c:	03079693          	slli	a3,a5,0x30
    80004610:	92c1                	srli	a3,a3,0x30
    80004612:	4725                	li	a4,9
    80004614:	0ed76663          	bltu	a4,a3,80004700 <filewrite+0x152>
    80004618:	0792                	slli	a5,a5,0x4
    8000461a:	0001d717          	auipc	a4,0x1d
    8000461e:	62670713          	addi	a4,a4,1574 # 80021c40 <devsw>
    80004622:	97ba                	add	a5,a5,a4
    80004624:	679c                	ld	a5,8(a5)
    80004626:	cff9                	beqz	a5,80004704 <filewrite+0x156>
    ret = devsw[f->major].write(1, addr, n);
    80004628:	4505                	li	a0,1
    8000462a:	9782                	jalr	a5
    8000462c:	a841                	j	800046bc <filewrite+0x10e>
    8000462e:	00048c1b          	sext.w	s8,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    80004632:	00000097          	auipc	ra,0x0
    80004636:	8ae080e7          	jalr	-1874(ra) # 80003ee0 <begin_op>
      ilock(f->ip);
    8000463a:	01893503          	ld	a0,24(s2)
    8000463e:	fffff097          	auipc	ra,0xfffff
    80004642:	f0c080e7          	jalr	-244(ra) # 8000354a <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004646:	8762                	mv	a4,s8
    80004648:	02092683          	lw	a3,32(s2)
    8000464c:	01598633          	add	a2,s3,s5
    80004650:	4585                	li	a1,1
    80004652:	01893503          	ld	a0,24(s2)
    80004656:	fffff097          	auipc	ra,0xfffff
    8000465a:	278080e7          	jalr	632(ra) # 800038ce <writei>
    8000465e:	84aa                	mv	s1,a0
    80004660:	02a05f63          	blez	a0,8000469e <filewrite+0xf0>
        f->off += r;
    80004664:	02092783          	lw	a5,32(s2)
    80004668:	9fa9                	addw	a5,a5,a0
    8000466a:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    8000466e:	01893503          	ld	a0,24(s2)
    80004672:	fffff097          	auipc	ra,0xfffff
    80004676:	f9a080e7          	jalr	-102(ra) # 8000360c <iunlock>
      end_op();
    8000467a:	00000097          	auipc	ra,0x0
    8000467e:	8e6080e7          	jalr	-1818(ra) # 80003f60 <end_op>

      if(r < 0)
        break;
      if(r != n1)
    80004682:	049c1963          	bne	s8,s1,800046d4 <filewrite+0x126>
        panic("short filewrite");
      i += r;
    80004686:	013489bb          	addw	s3,s1,s3
    while(i < n){
    8000468a:	0349d663          	bge	s3,s4,800046b6 <filewrite+0x108>
      int n1 = n - i;
    8000468e:	413a07bb          	subw	a5,s4,s3
      if(n1 > max)
    80004692:	84be                	mv	s1,a5
    80004694:	2781                	sext.w	a5,a5
    80004696:	f8fb5ce3          	bge	s6,a5,8000462e <filewrite+0x80>
    8000469a:	84de                	mv	s1,s7
    8000469c:	bf49                	j	8000462e <filewrite+0x80>
      iunlock(f->ip);
    8000469e:	01893503          	ld	a0,24(s2)
    800046a2:	fffff097          	auipc	ra,0xfffff
    800046a6:	f6a080e7          	jalr	-150(ra) # 8000360c <iunlock>
      end_op();
    800046aa:	00000097          	auipc	ra,0x0
    800046ae:	8b6080e7          	jalr	-1866(ra) # 80003f60 <end_op>
      if(r < 0)
    800046b2:	fc04d8e3          	bgez	s1,80004682 <filewrite+0xd4>
    }
    ret = (i == n ? n : -1);
    800046b6:	8552                	mv	a0,s4
    800046b8:	033a1863          	bne	s4,s3,800046e8 <filewrite+0x13a>
  } else {
    panic("filewrite");
  }

  return ret;
}
    800046bc:	60a6                	ld	ra,72(sp)
    800046be:	6406                	ld	s0,64(sp)
    800046c0:	74e2                	ld	s1,56(sp)
    800046c2:	7942                	ld	s2,48(sp)
    800046c4:	79a2                	ld	s3,40(sp)
    800046c6:	7a02                	ld	s4,32(sp)
    800046c8:	6ae2                	ld	s5,24(sp)
    800046ca:	6b42                	ld	s6,16(sp)
    800046cc:	6ba2                	ld	s7,8(sp)
    800046ce:	6c02                	ld	s8,0(sp)
    800046d0:	6161                	addi	sp,sp,80
    800046d2:	8082                	ret
        panic("short filewrite");
    800046d4:	00003517          	auipc	a0,0x3
    800046d8:	fe450513          	addi	a0,a0,-28 # 800076b8 <userret+0x628>
    800046dc:	ffffc097          	auipc	ra,0xffffc
    800046e0:	e72080e7          	jalr	-398(ra) # 8000054e <panic>
    int i = 0;
    800046e4:	4981                	li	s3,0
    800046e6:	bfc1                	j	800046b6 <filewrite+0x108>
    ret = (i == n ? n : -1);
    800046e8:	557d                	li	a0,-1
    800046ea:	bfc9                	j	800046bc <filewrite+0x10e>
    panic("filewrite");
    800046ec:	00003517          	auipc	a0,0x3
    800046f0:	fdc50513          	addi	a0,a0,-36 # 800076c8 <userret+0x638>
    800046f4:	ffffc097          	auipc	ra,0xffffc
    800046f8:	e5a080e7          	jalr	-422(ra) # 8000054e <panic>
    return -1;
    800046fc:	557d                	li	a0,-1
}
    800046fe:	8082                	ret
      return -1;
    80004700:	557d                	li	a0,-1
    80004702:	bf6d                	j	800046bc <filewrite+0x10e>
    80004704:	557d                	li	a0,-1
    80004706:	bf5d                	j	800046bc <filewrite+0x10e>

0000000080004708 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80004708:	7179                	addi	sp,sp,-48
    8000470a:	f406                	sd	ra,40(sp)
    8000470c:	f022                	sd	s0,32(sp)
    8000470e:	ec26                	sd	s1,24(sp)
    80004710:	e84a                	sd	s2,16(sp)
    80004712:	e44e                	sd	s3,8(sp)
    80004714:	e052                	sd	s4,0(sp)
    80004716:	1800                	addi	s0,sp,48
    80004718:	84aa                	mv	s1,a0
    8000471a:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    8000471c:	0005b023          	sd	zero,0(a1)
    80004720:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004724:	00000097          	auipc	ra,0x0
    80004728:	bd2080e7          	jalr	-1070(ra) # 800042f6 <filealloc>
    8000472c:	e088                	sd	a0,0(s1)
    8000472e:	c551                	beqz	a0,800047ba <pipealloc+0xb2>
    80004730:	00000097          	auipc	ra,0x0
    80004734:	bc6080e7          	jalr	-1082(ra) # 800042f6 <filealloc>
    80004738:	00aa3023          	sd	a0,0(s4)
    8000473c:	c92d                	beqz	a0,800047ae <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    8000473e:	ffffc097          	auipc	ra,0xffffc
    80004742:	222080e7          	jalr	546(ra) # 80000960 <kalloc>
    80004746:	892a                	mv	s2,a0
    80004748:	c125                	beqz	a0,800047a8 <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    8000474a:	4985                	li	s3,1
    8000474c:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80004750:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80004754:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80004758:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    8000475c:	00003597          	auipc	a1,0x3
    80004760:	f7c58593          	addi	a1,a1,-132 # 800076d8 <userret+0x648>
    80004764:	ffffc097          	auipc	ra,0xffffc
    80004768:	25c080e7          	jalr	604(ra) # 800009c0 <initlock>
  (*f0)->type = FD_PIPE;
    8000476c:	609c                	ld	a5,0(s1)
    8000476e:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80004772:	609c                	ld	a5,0(s1)
    80004774:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80004778:	609c                	ld	a5,0(s1)
    8000477a:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    8000477e:	609c                	ld	a5,0(s1)
    80004780:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80004784:	000a3783          	ld	a5,0(s4)
    80004788:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    8000478c:	000a3783          	ld	a5,0(s4)
    80004790:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80004794:	000a3783          	ld	a5,0(s4)
    80004798:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    8000479c:	000a3783          	ld	a5,0(s4)
    800047a0:	0127b823          	sd	s2,16(a5)
  return 0;
    800047a4:	4501                	li	a0,0
    800047a6:	a025                	j	800047ce <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    800047a8:	6088                	ld	a0,0(s1)
    800047aa:	e501                	bnez	a0,800047b2 <pipealloc+0xaa>
    800047ac:	a039                	j	800047ba <pipealloc+0xb2>
    800047ae:	6088                	ld	a0,0(s1)
    800047b0:	c51d                	beqz	a0,800047de <pipealloc+0xd6>
    fileclose(*f0);
    800047b2:	00000097          	auipc	ra,0x0
    800047b6:	c00080e7          	jalr	-1024(ra) # 800043b2 <fileclose>
  if(*f1)
    800047ba:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    800047be:	557d                	li	a0,-1
  if(*f1)
    800047c0:	c799                	beqz	a5,800047ce <pipealloc+0xc6>
    fileclose(*f1);
    800047c2:	853e                	mv	a0,a5
    800047c4:	00000097          	auipc	ra,0x0
    800047c8:	bee080e7          	jalr	-1042(ra) # 800043b2 <fileclose>
  return -1;
    800047cc:	557d                	li	a0,-1
}
    800047ce:	70a2                	ld	ra,40(sp)
    800047d0:	7402                	ld	s0,32(sp)
    800047d2:	64e2                	ld	s1,24(sp)
    800047d4:	6942                	ld	s2,16(sp)
    800047d6:	69a2                	ld	s3,8(sp)
    800047d8:	6a02                	ld	s4,0(sp)
    800047da:	6145                	addi	sp,sp,48
    800047dc:	8082                	ret
  return -1;
    800047de:	557d                	li	a0,-1
    800047e0:	b7fd                	j	800047ce <pipealloc+0xc6>

00000000800047e2 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    800047e2:	1101                	addi	sp,sp,-32
    800047e4:	ec06                	sd	ra,24(sp)
    800047e6:	e822                	sd	s0,16(sp)
    800047e8:	e426                	sd	s1,8(sp)
    800047ea:	e04a                	sd	s2,0(sp)
    800047ec:	1000                	addi	s0,sp,32
    800047ee:	84aa                	mv	s1,a0
    800047f0:	892e                	mv	s2,a1
  acquire(&pi->lock);
    800047f2:	ffffc097          	auipc	ra,0xffffc
    800047f6:	2e0080e7          	jalr	736(ra) # 80000ad2 <acquire>
  if(writable){
    800047fa:	02090d63          	beqz	s2,80004834 <pipeclose+0x52>
    pi->writeopen = 0;
    800047fe:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80004802:	21848513          	addi	a0,s1,536
    80004806:	ffffe097          	auipc	ra,0xffffe
    8000480a:	96a080e7          	jalr	-1686(ra) # 80002170 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    8000480e:	2204b783          	ld	a5,544(s1)
    80004812:	eb95                	bnez	a5,80004846 <pipeclose+0x64>
    release(&pi->lock);
    80004814:	8526                	mv	a0,s1
    80004816:	ffffc097          	auipc	ra,0xffffc
    8000481a:	310080e7          	jalr	784(ra) # 80000b26 <release>
    kfree((char*)pi);
    8000481e:	8526                	mv	a0,s1
    80004820:	ffffc097          	auipc	ra,0xffffc
    80004824:	044080e7          	jalr	68(ra) # 80000864 <kfree>
  } else
    release(&pi->lock);
}
    80004828:	60e2                	ld	ra,24(sp)
    8000482a:	6442                	ld	s0,16(sp)
    8000482c:	64a2                	ld	s1,8(sp)
    8000482e:	6902                	ld	s2,0(sp)
    80004830:	6105                	addi	sp,sp,32
    80004832:	8082                	ret
    pi->readopen = 0;
    80004834:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80004838:	21c48513          	addi	a0,s1,540
    8000483c:	ffffe097          	auipc	ra,0xffffe
    80004840:	934080e7          	jalr	-1740(ra) # 80002170 <wakeup>
    80004844:	b7e9                	j	8000480e <pipeclose+0x2c>
    release(&pi->lock);
    80004846:	8526                	mv	a0,s1
    80004848:	ffffc097          	auipc	ra,0xffffc
    8000484c:	2de080e7          	jalr	734(ra) # 80000b26 <release>
}
    80004850:	bfe1                	j	80004828 <pipeclose+0x46>

0000000080004852 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004852:	7159                	addi	sp,sp,-112
    80004854:	f486                	sd	ra,104(sp)
    80004856:	f0a2                	sd	s0,96(sp)
    80004858:	eca6                	sd	s1,88(sp)
    8000485a:	e8ca                	sd	s2,80(sp)
    8000485c:	e4ce                	sd	s3,72(sp)
    8000485e:	e0d2                	sd	s4,64(sp)
    80004860:	fc56                	sd	s5,56(sp)
    80004862:	f85a                	sd	s6,48(sp)
    80004864:	f45e                	sd	s7,40(sp)
    80004866:	f062                	sd	s8,32(sp)
    80004868:	ec66                	sd	s9,24(sp)
    8000486a:	1880                	addi	s0,sp,112
    8000486c:	84aa                	mv	s1,a0
    8000486e:	8b2e                	mv	s6,a1
    80004870:	8ab2                	mv	s5,a2
  int i;
  char ch;
  struct proc *pr = myproc();
    80004872:	ffffd097          	auipc	ra,0xffffd
    80004876:	fd2080e7          	jalr	-46(ra) # 80001844 <myproc>
    8000487a:	8c2a                	mv	s8,a0

  acquire(&pi->lock);
    8000487c:	8526                	mv	a0,s1
    8000487e:	ffffc097          	auipc	ra,0xffffc
    80004882:	254080e7          	jalr	596(ra) # 80000ad2 <acquire>
  for(i = 0; i < n; i++){
    80004886:	0b505063          	blez	s5,80004926 <pipewrite+0xd4>
    8000488a:	8926                	mv	s2,s1
    8000488c:	fffa8b9b          	addiw	s7,s5,-1
    80004890:	1b82                	slli	s7,s7,0x20
    80004892:	020bdb93          	srli	s7,s7,0x20
    80004896:	001b0793          	addi	a5,s6,1
    8000489a:	9bbe                	add	s7,s7,a5
    while(pi->nwrite == pi->nread + PIPESIZE){  //DOC: pipewrite-full
      if(pi->readopen == 0 || myproc()->killed){
        release(&pi->lock);
        return -1;
      }
      wakeup(&pi->nread);
    8000489c:	21848a13          	addi	s4,s1,536
      sleep(&pi->nwrite, &pi->lock);
    800048a0:	21c48993          	addi	s3,s1,540
    }
    if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    800048a4:	5cfd                	li	s9,-1
    while(pi->nwrite == pi->nread + PIPESIZE){  //DOC: pipewrite-full
    800048a6:	2184a783          	lw	a5,536(s1)
    800048aa:	21c4a703          	lw	a4,540(s1)
    800048ae:	2007879b          	addiw	a5,a5,512
    800048b2:	02f71e63          	bne	a4,a5,800048ee <pipewrite+0x9c>
      if(pi->readopen == 0 || myproc()->killed){
    800048b6:	2204a783          	lw	a5,544(s1)
    800048ba:	c3d9                	beqz	a5,80004940 <pipewrite+0xee>
    800048bc:	ffffd097          	auipc	ra,0xffffd
    800048c0:	f88080e7          	jalr	-120(ra) # 80001844 <myproc>
    800048c4:	591c                	lw	a5,48(a0)
    800048c6:	efad                	bnez	a5,80004940 <pipewrite+0xee>
      wakeup(&pi->nread);
    800048c8:	8552                	mv	a0,s4
    800048ca:	ffffe097          	auipc	ra,0xffffe
    800048ce:	8a6080e7          	jalr	-1882(ra) # 80002170 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    800048d2:	85ca                	mv	a1,s2
    800048d4:	854e                	mv	a0,s3
    800048d6:	ffffd097          	auipc	ra,0xffffd
    800048da:	714080e7          	jalr	1812(ra) # 80001fea <sleep>
    while(pi->nwrite == pi->nread + PIPESIZE){  //DOC: pipewrite-full
    800048de:	2184a783          	lw	a5,536(s1)
    800048e2:	21c4a703          	lw	a4,540(s1)
    800048e6:	2007879b          	addiw	a5,a5,512
    800048ea:	fcf706e3          	beq	a4,a5,800048b6 <pipewrite+0x64>
    if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    800048ee:	4685                	li	a3,1
    800048f0:	865a                	mv	a2,s6
    800048f2:	f9f40593          	addi	a1,s0,-97
    800048f6:	050c3503          	ld	a0,80(s8)
    800048fa:	ffffd097          	auipc	ra,0xffffd
    800048fe:	cca080e7          	jalr	-822(ra) # 800015c4 <copyin>
    80004902:	03950263          	beq	a0,s9,80004926 <pipewrite+0xd4>
      break;
    pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004906:	21c4a783          	lw	a5,540(s1)
    8000490a:	0017871b          	addiw	a4,a5,1
    8000490e:	20e4ae23          	sw	a4,540(s1)
    80004912:	1ff7f793          	andi	a5,a5,511
    80004916:	97a6                	add	a5,a5,s1
    80004918:	f9f44703          	lbu	a4,-97(s0)
    8000491c:	00e78c23          	sb	a4,24(a5)
  for(i = 0; i < n; i++){
    80004920:	0b05                	addi	s6,s6,1
    80004922:	f97b12e3          	bne	s6,s7,800048a6 <pipewrite+0x54>
  }
  wakeup(&pi->nread);
    80004926:	21848513          	addi	a0,s1,536
    8000492a:	ffffe097          	auipc	ra,0xffffe
    8000492e:	846080e7          	jalr	-1978(ra) # 80002170 <wakeup>
  release(&pi->lock);
    80004932:	8526                	mv	a0,s1
    80004934:	ffffc097          	auipc	ra,0xffffc
    80004938:	1f2080e7          	jalr	498(ra) # 80000b26 <release>
  return n;
    8000493c:	8556                	mv	a0,s5
    8000493e:	a039                	j	8000494c <pipewrite+0xfa>
        release(&pi->lock);
    80004940:	8526                	mv	a0,s1
    80004942:	ffffc097          	auipc	ra,0xffffc
    80004946:	1e4080e7          	jalr	484(ra) # 80000b26 <release>
        return -1;
    8000494a:	557d                	li	a0,-1
}
    8000494c:	70a6                	ld	ra,104(sp)
    8000494e:	7406                	ld	s0,96(sp)
    80004950:	64e6                	ld	s1,88(sp)
    80004952:	6946                	ld	s2,80(sp)
    80004954:	69a6                	ld	s3,72(sp)
    80004956:	6a06                	ld	s4,64(sp)
    80004958:	7ae2                	ld	s5,56(sp)
    8000495a:	7b42                	ld	s6,48(sp)
    8000495c:	7ba2                	ld	s7,40(sp)
    8000495e:	7c02                	ld	s8,32(sp)
    80004960:	6ce2                	ld	s9,24(sp)
    80004962:	6165                	addi	sp,sp,112
    80004964:	8082                	ret

0000000080004966 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80004966:	715d                	addi	sp,sp,-80
    80004968:	e486                	sd	ra,72(sp)
    8000496a:	e0a2                	sd	s0,64(sp)
    8000496c:	fc26                	sd	s1,56(sp)
    8000496e:	f84a                	sd	s2,48(sp)
    80004970:	f44e                	sd	s3,40(sp)
    80004972:	f052                	sd	s4,32(sp)
    80004974:	ec56                	sd	s5,24(sp)
    80004976:	e85a                	sd	s6,16(sp)
    80004978:	0880                	addi	s0,sp,80
    8000497a:	84aa                	mv	s1,a0
    8000497c:	892e                	mv	s2,a1
    8000497e:	8a32                	mv	s4,a2
  int i;
  struct proc *pr = myproc();
    80004980:	ffffd097          	auipc	ra,0xffffd
    80004984:	ec4080e7          	jalr	-316(ra) # 80001844 <myproc>
    80004988:	8aaa                	mv	s5,a0
  char ch;

  acquire(&pi->lock);
    8000498a:	8b26                	mv	s6,s1
    8000498c:	8526                	mv	a0,s1
    8000498e:	ffffc097          	auipc	ra,0xffffc
    80004992:	144080e7          	jalr	324(ra) # 80000ad2 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004996:	2184a703          	lw	a4,536(s1)
    8000499a:	21c4a783          	lw	a5,540(s1)
    if(myproc()->killed){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    8000499e:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    800049a2:	02f71763          	bne	a4,a5,800049d0 <piperead+0x6a>
    800049a6:	2244a783          	lw	a5,548(s1)
    800049aa:	c39d                	beqz	a5,800049d0 <piperead+0x6a>
    if(myproc()->killed){
    800049ac:	ffffd097          	auipc	ra,0xffffd
    800049b0:	e98080e7          	jalr	-360(ra) # 80001844 <myproc>
    800049b4:	591c                	lw	a5,48(a0)
    800049b6:	ebc1                	bnez	a5,80004a46 <piperead+0xe0>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    800049b8:	85da                	mv	a1,s6
    800049ba:	854e                	mv	a0,s3
    800049bc:	ffffd097          	auipc	ra,0xffffd
    800049c0:	62e080e7          	jalr	1582(ra) # 80001fea <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    800049c4:	2184a703          	lw	a4,536(s1)
    800049c8:	21c4a783          	lw	a5,540(s1)
    800049cc:	fcf70de3          	beq	a4,a5,800049a6 <piperead+0x40>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    800049d0:	09405263          	blez	s4,80004a54 <piperead+0xee>
    800049d4:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    800049d6:	5b7d                	li	s6,-1
    if(pi->nread == pi->nwrite)
    800049d8:	2184a783          	lw	a5,536(s1)
    800049dc:	21c4a703          	lw	a4,540(s1)
    800049e0:	02f70d63          	beq	a4,a5,80004a1a <piperead+0xb4>
    ch = pi->data[pi->nread++ % PIPESIZE];
    800049e4:	0017871b          	addiw	a4,a5,1
    800049e8:	20e4ac23          	sw	a4,536(s1)
    800049ec:	1ff7f793          	andi	a5,a5,511
    800049f0:	97a6                	add	a5,a5,s1
    800049f2:	0187c783          	lbu	a5,24(a5)
    800049f6:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    800049fa:	4685                	li	a3,1
    800049fc:	fbf40613          	addi	a2,s0,-65
    80004a00:	85ca                	mv	a1,s2
    80004a02:	050ab503          	ld	a0,80(s5)
    80004a06:	ffffd097          	auipc	ra,0xffffd
    80004a0a:	b32080e7          	jalr	-1230(ra) # 80001538 <copyout>
    80004a0e:	01650663          	beq	a0,s6,80004a1a <piperead+0xb4>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004a12:	2985                	addiw	s3,s3,1
    80004a14:	0905                	addi	s2,s2,1
    80004a16:	fd3a11e3          	bne	s4,s3,800049d8 <piperead+0x72>
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80004a1a:	21c48513          	addi	a0,s1,540
    80004a1e:	ffffd097          	auipc	ra,0xffffd
    80004a22:	752080e7          	jalr	1874(ra) # 80002170 <wakeup>
  release(&pi->lock);
    80004a26:	8526                	mv	a0,s1
    80004a28:	ffffc097          	auipc	ra,0xffffc
    80004a2c:	0fe080e7          	jalr	254(ra) # 80000b26 <release>
  return i;
}
    80004a30:	854e                	mv	a0,s3
    80004a32:	60a6                	ld	ra,72(sp)
    80004a34:	6406                	ld	s0,64(sp)
    80004a36:	74e2                	ld	s1,56(sp)
    80004a38:	7942                	ld	s2,48(sp)
    80004a3a:	79a2                	ld	s3,40(sp)
    80004a3c:	7a02                	ld	s4,32(sp)
    80004a3e:	6ae2                	ld	s5,24(sp)
    80004a40:	6b42                	ld	s6,16(sp)
    80004a42:	6161                	addi	sp,sp,80
    80004a44:	8082                	ret
      release(&pi->lock);
    80004a46:	8526                	mv	a0,s1
    80004a48:	ffffc097          	auipc	ra,0xffffc
    80004a4c:	0de080e7          	jalr	222(ra) # 80000b26 <release>
      return -1;
    80004a50:	59fd                	li	s3,-1
    80004a52:	bff9                	j	80004a30 <piperead+0xca>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004a54:	4981                	li	s3,0
    80004a56:	b7d1                	j	80004a1a <piperead+0xb4>

0000000080004a58 <exec>:

static int loadseg(pde_t *pgdir, uint64 addr, struct inode *ip, uint offset, uint sz);

int
exec(char *path, char **argv)
{
    80004a58:	df010113          	addi	sp,sp,-528
    80004a5c:	20113423          	sd	ra,520(sp)
    80004a60:	20813023          	sd	s0,512(sp)
    80004a64:	ffa6                	sd	s1,504(sp)
    80004a66:	fbca                	sd	s2,496(sp)
    80004a68:	f7ce                	sd	s3,488(sp)
    80004a6a:	f3d2                	sd	s4,480(sp)
    80004a6c:	efd6                	sd	s5,472(sp)
    80004a6e:	ebda                	sd	s6,464(sp)
    80004a70:	e7de                	sd	s7,456(sp)
    80004a72:	e3e2                	sd	s8,448(sp)
    80004a74:	ff66                	sd	s9,440(sp)
    80004a76:	fb6a                	sd	s10,432(sp)
    80004a78:	f76e                	sd	s11,424(sp)
    80004a7a:	0c00                	addi	s0,sp,528
    80004a7c:	84aa                	mv	s1,a0
    80004a7e:	dea43c23          	sd	a0,-520(s0)
    80004a82:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz, sp, ustack[MAXARG+1], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80004a86:	ffffd097          	auipc	ra,0xffffd
    80004a8a:	dbe080e7          	jalr	-578(ra) # 80001844 <myproc>
    80004a8e:	892a                	mv	s2,a0

  begin_op();
    80004a90:	fffff097          	auipc	ra,0xfffff
    80004a94:	450080e7          	jalr	1104(ra) # 80003ee0 <begin_op>

  if((ip = namei(path)) == 0){
    80004a98:	8526                	mv	a0,s1
    80004a9a:	fffff097          	auipc	ra,0xfffff
    80004a9e:	23a080e7          	jalr	570(ra) # 80003cd4 <namei>
    80004aa2:	c92d                	beqz	a0,80004b14 <exec+0xbc>
    80004aa4:	84aa                	mv	s1,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80004aa6:	fffff097          	auipc	ra,0xfffff
    80004aaa:	aa4080e7          	jalr	-1372(ra) # 8000354a <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80004aae:	04000713          	li	a4,64
    80004ab2:	4681                	li	a3,0
    80004ab4:	e4840613          	addi	a2,s0,-440
    80004ab8:	4581                	li	a1,0
    80004aba:	8526                	mv	a0,s1
    80004abc:	fffff097          	auipc	ra,0xfffff
    80004ac0:	d1e080e7          	jalr	-738(ra) # 800037da <readi>
    80004ac4:	04000793          	li	a5,64
    80004ac8:	00f51a63          	bne	a0,a5,80004adc <exec+0x84>
    goto bad;
  if(elf.magic != ELF_MAGIC)
    80004acc:	e4842703          	lw	a4,-440(s0)
    80004ad0:	464c47b7          	lui	a5,0x464c4
    80004ad4:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80004ad8:	04f70463          	beq	a4,a5,80004b20 <exec+0xc8>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80004adc:	8526                	mv	a0,s1
    80004ade:	fffff097          	auipc	ra,0xfffff
    80004ae2:	caa080e7          	jalr	-854(ra) # 80003788 <iunlockput>
    end_op();
    80004ae6:	fffff097          	auipc	ra,0xfffff
    80004aea:	47a080e7          	jalr	1146(ra) # 80003f60 <end_op>
  }
  return -1;
    80004aee:	557d                	li	a0,-1
}
    80004af0:	20813083          	ld	ra,520(sp)
    80004af4:	20013403          	ld	s0,512(sp)
    80004af8:	74fe                	ld	s1,504(sp)
    80004afa:	795e                	ld	s2,496(sp)
    80004afc:	79be                	ld	s3,488(sp)
    80004afe:	7a1e                	ld	s4,480(sp)
    80004b00:	6afe                	ld	s5,472(sp)
    80004b02:	6b5e                	ld	s6,464(sp)
    80004b04:	6bbe                	ld	s7,456(sp)
    80004b06:	6c1e                	ld	s8,448(sp)
    80004b08:	7cfa                	ld	s9,440(sp)
    80004b0a:	7d5a                	ld	s10,432(sp)
    80004b0c:	7dba                	ld	s11,424(sp)
    80004b0e:	21010113          	addi	sp,sp,528
    80004b12:	8082                	ret
    end_op();
    80004b14:	fffff097          	auipc	ra,0xfffff
    80004b18:	44c080e7          	jalr	1100(ra) # 80003f60 <end_op>
    return -1;
    80004b1c:	557d                	li	a0,-1
    80004b1e:	bfc9                	j	80004af0 <exec+0x98>
  if((pagetable = proc_pagetable(p)) == 0)
    80004b20:	854a                	mv	a0,s2
    80004b22:	ffffd097          	auipc	ra,0xffffd
    80004b26:	de6080e7          	jalr	-538(ra) # 80001908 <proc_pagetable>
    80004b2a:	8c2a                	mv	s8,a0
    80004b2c:	d945                	beqz	a0,80004adc <exec+0x84>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004b2e:	e6842983          	lw	s3,-408(s0)
    80004b32:	e8045783          	lhu	a5,-384(s0)
    80004b36:	c7fd                	beqz	a5,80004c24 <exec+0x1cc>
  sz = 0;
    80004b38:	e0043423          	sd	zero,-504(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004b3c:	4b81                	li	s7,0
    if(ph.vaddr % PGSIZE != 0)
    80004b3e:	6b05                	lui	s6,0x1
    80004b40:	fffb0793          	addi	a5,s6,-1 # fff <_entry-0x7ffff001>
    80004b44:	def43823          	sd	a5,-528(s0)
    80004b48:	a0a5                	j	80004bb0 <exec+0x158>
    panic("loadseg: va must be page aligned");

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    80004b4a:	00003517          	auipc	a0,0x3
    80004b4e:	b9650513          	addi	a0,a0,-1130 # 800076e0 <userret+0x650>
    80004b52:	ffffc097          	auipc	ra,0xffffc
    80004b56:	9fc080e7          	jalr	-1540(ra) # 8000054e <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80004b5a:	8756                	mv	a4,s5
    80004b5c:	012d86bb          	addw	a3,s11,s2
    80004b60:	4581                	li	a1,0
    80004b62:	8526                	mv	a0,s1
    80004b64:	fffff097          	auipc	ra,0xfffff
    80004b68:	c76080e7          	jalr	-906(ra) # 800037da <readi>
    80004b6c:	2501                	sext.w	a0,a0
    80004b6e:	10aa9163          	bne	s5,a0,80004c70 <exec+0x218>
  for(i = 0; i < sz; i += PGSIZE){
    80004b72:	6785                	lui	a5,0x1
    80004b74:	0127893b          	addw	s2,a5,s2
    80004b78:	77fd                	lui	a5,0xfffff
    80004b7a:	01478a3b          	addw	s4,a5,s4
    80004b7e:	03997263          	bgeu	s2,s9,80004ba2 <exec+0x14a>
    pa = walkaddr(pagetable, va + i);
    80004b82:	02091593          	slli	a1,s2,0x20
    80004b86:	9181                	srli	a1,a1,0x20
    80004b88:	95ea                	add	a1,a1,s10
    80004b8a:	8562                	mv	a0,s8
    80004b8c:	ffffc097          	auipc	ra,0xffffc
    80004b90:	3de080e7          	jalr	990(ra) # 80000f6a <walkaddr>
    80004b94:	862a                	mv	a2,a0
    if(pa == 0)
    80004b96:	d955                	beqz	a0,80004b4a <exec+0xf2>
      n = PGSIZE;
    80004b98:	8ada                	mv	s5,s6
    if(sz - i < PGSIZE)
    80004b9a:	fd6a70e3          	bgeu	s4,s6,80004b5a <exec+0x102>
      n = sz - i;
    80004b9e:	8ad2                	mv	s5,s4
    80004ba0:	bf6d                	j	80004b5a <exec+0x102>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004ba2:	2b85                	addiw	s7,s7,1
    80004ba4:	0389899b          	addiw	s3,s3,56
    80004ba8:	e8045783          	lhu	a5,-384(s0)
    80004bac:	06fbde63          	bge	s7,a5,80004c28 <exec+0x1d0>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80004bb0:	2981                	sext.w	s3,s3
    80004bb2:	03800713          	li	a4,56
    80004bb6:	86ce                	mv	a3,s3
    80004bb8:	e1040613          	addi	a2,s0,-496
    80004bbc:	4581                	li	a1,0
    80004bbe:	8526                	mv	a0,s1
    80004bc0:	fffff097          	auipc	ra,0xfffff
    80004bc4:	c1a080e7          	jalr	-998(ra) # 800037da <readi>
    80004bc8:	03800793          	li	a5,56
    80004bcc:	0af51263          	bne	a0,a5,80004c70 <exec+0x218>
    if(ph.type != ELF_PROG_LOAD)
    80004bd0:	e1042783          	lw	a5,-496(s0)
    80004bd4:	4705                	li	a4,1
    80004bd6:	fce796e3          	bne	a5,a4,80004ba2 <exec+0x14a>
    if(ph.memsz < ph.filesz)
    80004bda:	e3843603          	ld	a2,-456(s0)
    80004bde:	e3043783          	ld	a5,-464(s0)
    80004be2:	08f66763          	bltu	a2,a5,80004c70 <exec+0x218>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80004be6:	e2043783          	ld	a5,-480(s0)
    80004bea:	963e                	add	a2,a2,a5
    80004bec:	08f66263          	bltu	a2,a5,80004c70 <exec+0x218>
    if((sz = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    80004bf0:	e0843583          	ld	a1,-504(s0)
    80004bf4:	8562                	mv	a0,s8
    80004bf6:	ffffc097          	auipc	ra,0xffffc
    80004bfa:	768080e7          	jalr	1896(ra) # 8000135e <uvmalloc>
    80004bfe:	e0a43423          	sd	a0,-504(s0)
    80004c02:	c53d                	beqz	a0,80004c70 <exec+0x218>
    if(ph.vaddr % PGSIZE != 0)
    80004c04:	e2043d03          	ld	s10,-480(s0)
    80004c08:	df043783          	ld	a5,-528(s0)
    80004c0c:	00fd77b3          	and	a5,s10,a5
    80004c10:	e3a5                	bnez	a5,80004c70 <exec+0x218>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80004c12:	e1842d83          	lw	s11,-488(s0)
    80004c16:	e3042c83          	lw	s9,-464(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80004c1a:	f80c84e3          	beqz	s9,80004ba2 <exec+0x14a>
    80004c1e:	8a66                	mv	s4,s9
    80004c20:	4901                	li	s2,0
    80004c22:	b785                	j	80004b82 <exec+0x12a>
  sz = 0;
    80004c24:	e0043423          	sd	zero,-504(s0)
  iunlockput(ip);
    80004c28:	8526                	mv	a0,s1
    80004c2a:	fffff097          	auipc	ra,0xfffff
    80004c2e:	b5e080e7          	jalr	-1186(ra) # 80003788 <iunlockput>
  end_op();
    80004c32:	fffff097          	auipc	ra,0xfffff
    80004c36:	32e080e7          	jalr	814(ra) # 80003f60 <end_op>
  p = myproc();
    80004c3a:	ffffd097          	auipc	ra,0xffffd
    80004c3e:	c0a080e7          	jalr	-1014(ra) # 80001844 <myproc>
    80004c42:	8baa                	mv	s7,a0
  uint64 oldsz = p->sz;
    80004c44:	04853d03          	ld	s10,72(a0)
  sz = PGROUNDUP(sz);
    80004c48:	6585                	lui	a1,0x1
    80004c4a:	15fd                	addi	a1,a1,-1
    80004c4c:	e0843783          	ld	a5,-504(s0)
    80004c50:	00b78b33          	add	s6,a5,a1
    80004c54:	75fd                	lui	a1,0xfffff
    80004c56:	00bb75b3          	and	a1,s6,a1
  if((sz = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    80004c5a:	6609                	lui	a2,0x2
    80004c5c:	962e                	add	a2,a2,a1
    80004c5e:	8562                	mv	a0,s8
    80004c60:	ffffc097          	auipc	ra,0xffffc
    80004c64:	6fe080e7          	jalr	1790(ra) # 8000135e <uvmalloc>
    80004c68:	e0a43423          	sd	a0,-504(s0)
  ip = 0;
    80004c6c:	4481                	li	s1,0
  if((sz = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    80004c6e:	ed01                	bnez	a0,80004c86 <exec+0x22e>
    proc_freepagetable(pagetable, sz);
    80004c70:	e0843583          	ld	a1,-504(s0)
    80004c74:	8562                	mv	a0,s8
    80004c76:	ffffd097          	auipc	ra,0xffffd
    80004c7a:	d96080e7          	jalr	-618(ra) # 80001a0c <proc_freepagetable>
  if(ip){
    80004c7e:	e4049fe3          	bnez	s1,80004adc <exec+0x84>
  return -1;
    80004c82:	557d                	li	a0,-1
    80004c84:	b5b5                	j	80004af0 <exec+0x98>
  uvmclear(pagetable, sz-2*PGSIZE);
    80004c86:	75f9                	lui	a1,0xffffe
    80004c88:	84aa                	mv	s1,a0
    80004c8a:	95aa                	add	a1,a1,a0
    80004c8c:	8562                	mv	a0,s8
    80004c8e:	ffffd097          	auipc	ra,0xffffd
    80004c92:	878080e7          	jalr	-1928(ra) # 80001506 <uvmclear>
  stackbase = sp - PGSIZE;
    80004c96:	7afd                	lui	s5,0xfffff
    80004c98:	9aa6                	add	s5,s5,s1
  for(argc = 0; argv[argc]; argc++) {
    80004c9a:	e0043783          	ld	a5,-512(s0)
    80004c9e:	6388                	ld	a0,0(a5)
    80004ca0:	c135                	beqz	a0,80004d04 <exec+0x2ac>
    80004ca2:	e8840993          	addi	s3,s0,-376
    80004ca6:	f8840c93          	addi	s9,s0,-120
    80004caa:	4901                	li	s2,0
    sp -= strlen(argv[argc]) + 1;
    80004cac:	ffffc097          	auipc	ra,0xffffc
    80004cb0:	04a080e7          	jalr	74(ra) # 80000cf6 <strlen>
    80004cb4:	2505                	addiw	a0,a0,1
    80004cb6:	8c89                	sub	s1,s1,a0
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80004cb8:	98c1                	andi	s1,s1,-16
    if(sp < stackbase)
    80004cba:	0f54ea63          	bltu	s1,s5,80004dae <exec+0x356>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80004cbe:	e0043b03          	ld	s6,-512(s0)
    80004cc2:	000b3a03          	ld	s4,0(s6)
    80004cc6:	8552                	mv	a0,s4
    80004cc8:	ffffc097          	auipc	ra,0xffffc
    80004ccc:	02e080e7          	jalr	46(ra) # 80000cf6 <strlen>
    80004cd0:	0015069b          	addiw	a3,a0,1
    80004cd4:	8652                	mv	a2,s4
    80004cd6:	85a6                	mv	a1,s1
    80004cd8:	8562                	mv	a0,s8
    80004cda:	ffffd097          	auipc	ra,0xffffd
    80004cde:	85e080e7          	jalr	-1954(ra) # 80001538 <copyout>
    80004ce2:	0c054863          	bltz	a0,80004db2 <exec+0x35a>
    ustack[argc] = sp;
    80004ce6:	0099b023          	sd	s1,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    80004cea:	0905                	addi	s2,s2,1
    80004cec:	008b0793          	addi	a5,s6,8
    80004cf0:	e0f43023          	sd	a5,-512(s0)
    80004cf4:	008b3503          	ld	a0,8(s6)
    80004cf8:	c909                	beqz	a0,80004d0a <exec+0x2b2>
    if(argc >= MAXARG)
    80004cfa:	09a1                	addi	s3,s3,8
    80004cfc:	fb3c98e3          	bne	s9,s3,80004cac <exec+0x254>
  ip = 0;
    80004d00:	4481                	li	s1,0
    80004d02:	b7bd                	j	80004c70 <exec+0x218>
  sp = sz;
    80004d04:	e0843483          	ld	s1,-504(s0)
  for(argc = 0; argv[argc]; argc++) {
    80004d08:	4901                	li	s2,0
  ustack[argc] = 0;
    80004d0a:	00391793          	slli	a5,s2,0x3
    80004d0e:	f9040713          	addi	a4,s0,-112
    80004d12:	97ba                	add	a5,a5,a4
    80004d14:	ee07bc23          	sd	zero,-264(a5) # ffffffffffffeef8 <end+0xffffffff7ffd8edc>
  sp -= (argc+1) * sizeof(uint64);
    80004d18:	00190693          	addi	a3,s2,1
    80004d1c:	068e                	slli	a3,a3,0x3
    80004d1e:	8c95                	sub	s1,s1,a3
  sp -= sp % 16;
    80004d20:	ff04f993          	andi	s3,s1,-16
  ip = 0;
    80004d24:	4481                	li	s1,0
  if(sp < stackbase)
    80004d26:	f559e5e3          	bltu	s3,s5,80004c70 <exec+0x218>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80004d2a:	e8840613          	addi	a2,s0,-376
    80004d2e:	85ce                	mv	a1,s3
    80004d30:	8562                	mv	a0,s8
    80004d32:	ffffd097          	auipc	ra,0xffffd
    80004d36:	806080e7          	jalr	-2042(ra) # 80001538 <copyout>
    80004d3a:	06054e63          	bltz	a0,80004db6 <exec+0x35e>
  p->tf->a1 = sp;
    80004d3e:	058bb783          	ld	a5,88(s7) # 1058 <_entry-0x7fffefa8>
    80004d42:	0737bc23          	sd	s3,120(a5)
  for(last=s=path; *s; s++)
    80004d46:	df843783          	ld	a5,-520(s0)
    80004d4a:	0007c703          	lbu	a4,0(a5)
    80004d4e:	cf11                	beqz	a4,80004d6a <exec+0x312>
    80004d50:	0785                	addi	a5,a5,1
    if(*s == '/')
    80004d52:	02f00693          	li	a3,47
    80004d56:	a029                	j	80004d60 <exec+0x308>
  for(last=s=path; *s; s++)
    80004d58:	0785                	addi	a5,a5,1
    80004d5a:	fff7c703          	lbu	a4,-1(a5)
    80004d5e:	c711                	beqz	a4,80004d6a <exec+0x312>
    if(*s == '/')
    80004d60:	fed71ce3          	bne	a4,a3,80004d58 <exec+0x300>
      last = s+1;
    80004d64:	def43c23          	sd	a5,-520(s0)
    80004d68:	bfc5                	j	80004d58 <exec+0x300>
  safestrcpy(p->name, last, sizeof(p->name));
    80004d6a:	4641                	li	a2,16
    80004d6c:	df843583          	ld	a1,-520(s0)
    80004d70:	158b8513          	addi	a0,s7,344
    80004d74:	ffffc097          	auipc	ra,0xffffc
    80004d78:	f50080e7          	jalr	-176(ra) # 80000cc4 <safestrcpy>
  oldpagetable = p->pagetable;
    80004d7c:	050bb503          	ld	a0,80(s7)
  p->pagetable = pagetable;
    80004d80:	058bb823          	sd	s8,80(s7)
  p->sz = sz;
    80004d84:	e0843783          	ld	a5,-504(s0)
    80004d88:	04fbb423          	sd	a5,72(s7)
  p->tf->epc = elf.entry;  // initial program counter = main
    80004d8c:	058bb783          	ld	a5,88(s7)
    80004d90:	e6043703          	ld	a4,-416(s0)
    80004d94:	ef98                	sd	a4,24(a5)
  p->tf->sp = sp; // initial stack pointer
    80004d96:	058bb783          	ld	a5,88(s7)
    80004d9a:	0337b823          	sd	s3,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80004d9e:	85ea                	mv	a1,s10
    80004da0:	ffffd097          	auipc	ra,0xffffd
    80004da4:	c6c080e7          	jalr	-916(ra) # 80001a0c <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80004da8:	0009051b          	sext.w	a0,s2
    80004dac:	b391                	j	80004af0 <exec+0x98>
  ip = 0;
    80004dae:	4481                	li	s1,0
    80004db0:	b5c1                	j	80004c70 <exec+0x218>
    80004db2:	4481                	li	s1,0
    80004db4:	bd75                	j	80004c70 <exec+0x218>
    80004db6:	4481                	li	s1,0
    80004db8:	bd65                	j	80004c70 <exec+0x218>

0000000080004dba <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80004dba:	7179                	addi	sp,sp,-48
    80004dbc:	f406                	sd	ra,40(sp)
    80004dbe:	f022                	sd	s0,32(sp)
    80004dc0:	ec26                	sd	s1,24(sp)
    80004dc2:	e84a                	sd	s2,16(sp)
    80004dc4:	1800                	addi	s0,sp,48
    80004dc6:	892e                	mv	s2,a1
    80004dc8:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
    80004dca:	fdc40593          	addi	a1,s0,-36
    80004dce:	ffffe097          	auipc	ra,0xffffe
    80004dd2:	b62080e7          	jalr	-1182(ra) # 80002930 <argint>
    80004dd6:	04054063          	bltz	a0,80004e16 <argfd+0x5c>
    return -1;
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80004dda:	fdc42703          	lw	a4,-36(s0)
    80004dde:	47bd                	li	a5,15
    80004de0:	02e7ed63          	bltu	a5,a4,80004e1a <argfd+0x60>
    80004de4:	ffffd097          	auipc	ra,0xffffd
    80004de8:	a60080e7          	jalr	-1440(ra) # 80001844 <myproc>
    80004dec:	fdc42703          	lw	a4,-36(s0)
    80004df0:	01a70793          	addi	a5,a4,26
    80004df4:	078e                	slli	a5,a5,0x3
    80004df6:	953e                	add	a0,a0,a5
    80004df8:	611c                	ld	a5,0(a0)
    80004dfa:	c395                	beqz	a5,80004e1e <argfd+0x64>
    return -1;
  if(pfd)
    80004dfc:	00090463          	beqz	s2,80004e04 <argfd+0x4a>
    *pfd = fd;
    80004e00:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80004e04:	4501                	li	a0,0
  if(pf)
    80004e06:	c091                	beqz	s1,80004e0a <argfd+0x50>
    *pf = f;
    80004e08:	e09c                	sd	a5,0(s1)
}
    80004e0a:	70a2                	ld	ra,40(sp)
    80004e0c:	7402                	ld	s0,32(sp)
    80004e0e:	64e2                	ld	s1,24(sp)
    80004e10:	6942                	ld	s2,16(sp)
    80004e12:	6145                	addi	sp,sp,48
    80004e14:	8082                	ret
    return -1;
    80004e16:	557d                	li	a0,-1
    80004e18:	bfcd                	j	80004e0a <argfd+0x50>
    return -1;
    80004e1a:	557d                	li	a0,-1
    80004e1c:	b7fd                	j	80004e0a <argfd+0x50>
    80004e1e:	557d                	li	a0,-1
    80004e20:	b7ed                	j	80004e0a <argfd+0x50>

0000000080004e22 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80004e22:	1101                	addi	sp,sp,-32
    80004e24:	ec06                	sd	ra,24(sp)
    80004e26:	e822                	sd	s0,16(sp)
    80004e28:	e426                	sd	s1,8(sp)
    80004e2a:	1000                	addi	s0,sp,32
    80004e2c:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80004e2e:	ffffd097          	auipc	ra,0xffffd
    80004e32:	a16080e7          	jalr	-1514(ra) # 80001844 <myproc>
    80004e36:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80004e38:	0d050793          	addi	a5,a0,208
    80004e3c:	4501                	li	a0,0
    80004e3e:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    80004e40:	6398                	ld	a4,0(a5)
    80004e42:	cb19                	beqz	a4,80004e58 <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    80004e44:	2505                	addiw	a0,a0,1
    80004e46:	07a1                	addi	a5,a5,8
    80004e48:	fed51ce3          	bne	a0,a3,80004e40 <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80004e4c:	557d                	li	a0,-1
}
    80004e4e:	60e2                	ld	ra,24(sp)
    80004e50:	6442                	ld	s0,16(sp)
    80004e52:	64a2                	ld	s1,8(sp)
    80004e54:	6105                	addi	sp,sp,32
    80004e56:	8082                	ret
      p->ofile[fd] = f;
    80004e58:	01a50793          	addi	a5,a0,26
    80004e5c:	078e                	slli	a5,a5,0x3
    80004e5e:	963e                	add	a2,a2,a5
    80004e60:	e204                	sd	s1,0(a2)
      return fd;
    80004e62:	b7f5                	j	80004e4e <fdalloc+0x2c>

0000000080004e64 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    80004e64:	715d                	addi	sp,sp,-80
    80004e66:	e486                	sd	ra,72(sp)
    80004e68:	e0a2                	sd	s0,64(sp)
    80004e6a:	fc26                	sd	s1,56(sp)
    80004e6c:	f84a                	sd	s2,48(sp)
    80004e6e:	f44e                	sd	s3,40(sp)
    80004e70:	f052                	sd	s4,32(sp)
    80004e72:	ec56                	sd	s5,24(sp)
    80004e74:	0880                	addi	s0,sp,80
    80004e76:	89ae                	mv	s3,a1
    80004e78:	8ab2                	mv	s5,a2
    80004e7a:	8a36                	mv	s4,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80004e7c:	fb040593          	addi	a1,s0,-80
    80004e80:	fffff097          	auipc	ra,0xfffff
    80004e84:	e72080e7          	jalr	-398(ra) # 80003cf2 <nameiparent>
    80004e88:	892a                	mv	s2,a0
    80004e8a:	12050f63          	beqz	a0,80004fc8 <create+0x164>
    return 0;

  ilock(dp);
    80004e8e:	ffffe097          	auipc	ra,0xffffe
    80004e92:	6bc080e7          	jalr	1724(ra) # 8000354a <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80004e96:	4601                	li	a2,0
    80004e98:	fb040593          	addi	a1,s0,-80
    80004e9c:	854a                	mv	a0,s2
    80004e9e:	fffff097          	auipc	ra,0xfffff
    80004ea2:	b64080e7          	jalr	-1180(ra) # 80003a02 <dirlookup>
    80004ea6:	84aa                	mv	s1,a0
    80004ea8:	c921                	beqz	a0,80004ef8 <create+0x94>
    iunlockput(dp);
    80004eaa:	854a                	mv	a0,s2
    80004eac:	fffff097          	auipc	ra,0xfffff
    80004eb0:	8dc080e7          	jalr	-1828(ra) # 80003788 <iunlockput>
    ilock(ip);
    80004eb4:	8526                	mv	a0,s1
    80004eb6:	ffffe097          	auipc	ra,0xffffe
    80004eba:	694080e7          	jalr	1684(ra) # 8000354a <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80004ebe:	2981                	sext.w	s3,s3
    80004ec0:	4789                	li	a5,2
    80004ec2:	02f99463          	bne	s3,a5,80004eea <create+0x86>
    80004ec6:	0444d783          	lhu	a5,68(s1)
    80004eca:	37f9                	addiw	a5,a5,-2
    80004ecc:	17c2                	slli	a5,a5,0x30
    80004ece:	93c1                	srli	a5,a5,0x30
    80004ed0:	4705                	li	a4,1
    80004ed2:	00f76c63          	bltu	a4,a5,80004eea <create+0x86>
    panic("create: dirlink");

  iunlockput(dp);

  return ip;
}
    80004ed6:	8526                	mv	a0,s1
    80004ed8:	60a6                	ld	ra,72(sp)
    80004eda:	6406                	ld	s0,64(sp)
    80004edc:	74e2                	ld	s1,56(sp)
    80004ede:	7942                	ld	s2,48(sp)
    80004ee0:	79a2                	ld	s3,40(sp)
    80004ee2:	7a02                	ld	s4,32(sp)
    80004ee4:	6ae2                	ld	s5,24(sp)
    80004ee6:	6161                	addi	sp,sp,80
    80004ee8:	8082                	ret
    iunlockput(ip);
    80004eea:	8526                	mv	a0,s1
    80004eec:	fffff097          	auipc	ra,0xfffff
    80004ef0:	89c080e7          	jalr	-1892(ra) # 80003788 <iunlockput>
    return 0;
    80004ef4:	4481                	li	s1,0
    80004ef6:	b7c5                	j	80004ed6 <create+0x72>
  if((ip = ialloc(dp->dev, type)) == 0)
    80004ef8:	85ce                	mv	a1,s3
    80004efa:	00092503          	lw	a0,0(s2)
    80004efe:	ffffe097          	auipc	ra,0xffffe
    80004f02:	4b4080e7          	jalr	1204(ra) # 800033b2 <ialloc>
    80004f06:	84aa                	mv	s1,a0
    80004f08:	c529                	beqz	a0,80004f52 <create+0xee>
  ilock(ip);
    80004f0a:	ffffe097          	auipc	ra,0xffffe
    80004f0e:	640080e7          	jalr	1600(ra) # 8000354a <ilock>
  ip->major = major;
    80004f12:	05549323          	sh	s5,70(s1)
  ip->minor = minor;
    80004f16:	05449423          	sh	s4,72(s1)
  ip->nlink = 1;
    80004f1a:	4785                	li	a5,1
    80004f1c:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80004f20:	8526                	mv	a0,s1
    80004f22:	ffffe097          	auipc	ra,0xffffe
    80004f26:	55e080e7          	jalr	1374(ra) # 80003480 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    80004f2a:	2981                	sext.w	s3,s3
    80004f2c:	4785                	li	a5,1
    80004f2e:	02f98a63          	beq	s3,a5,80004f62 <create+0xfe>
  if(dirlink(dp, name, ip->inum) < 0)
    80004f32:	40d0                	lw	a2,4(s1)
    80004f34:	fb040593          	addi	a1,s0,-80
    80004f38:	854a                	mv	a0,s2
    80004f3a:	fffff097          	auipc	ra,0xfffff
    80004f3e:	cd8080e7          	jalr	-808(ra) # 80003c12 <dirlink>
    80004f42:	06054b63          	bltz	a0,80004fb8 <create+0x154>
  iunlockput(dp);
    80004f46:	854a                	mv	a0,s2
    80004f48:	fffff097          	auipc	ra,0xfffff
    80004f4c:	840080e7          	jalr	-1984(ra) # 80003788 <iunlockput>
  return ip;
    80004f50:	b759                	j	80004ed6 <create+0x72>
    panic("create: ialloc");
    80004f52:	00002517          	auipc	a0,0x2
    80004f56:	7ae50513          	addi	a0,a0,1966 # 80007700 <userret+0x670>
    80004f5a:	ffffb097          	auipc	ra,0xffffb
    80004f5e:	5f4080e7          	jalr	1524(ra) # 8000054e <panic>
    dp->nlink++;  // for ".."
    80004f62:	04a95783          	lhu	a5,74(s2)
    80004f66:	2785                	addiw	a5,a5,1
    80004f68:	04f91523          	sh	a5,74(s2)
    iupdate(dp);
    80004f6c:	854a                	mv	a0,s2
    80004f6e:	ffffe097          	auipc	ra,0xffffe
    80004f72:	512080e7          	jalr	1298(ra) # 80003480 <iupdate>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80004f76:	40d0                	lw	a2,4(s1)
    80004f78:	00002597          	auipc	a1,0x2
    80004f7c:	79858593          	addi	a1,a1,1944 # 80007710 <userret+0x680>
    80004f80:	8526                	mv	a0,s1
    80004f82:	fffff097          	auipc	ra,0xfffff
    80004f86:	c90080e7          	jalr	-880(ra) # 80003c12 <dirlink>
    80004f8a:	00054f63          	bltz	a0,80004fa8 <create+0x144>
    80004f8e:	00492603          	lw	a2,4(s2)
    80004f92:	00002597          	auipc	a1,0x2
    80004f96:	78658593          	addi	a1,a1,1926 # 80007718 <userret+0x688>
    80004f9a:	8526                	mv	a0,s1
    80004f9c:	fffff097          	auipc	ra,0xfffff
    80004fa0:	c76080e7          	jalr	-906(ra) # 80003c12 <dirlink>
    80004fa4:	f80557e3          	bgez	a0,80004f32 <create+0xce>
      panic("create dots");
    80004fa8:	00002517          	auipc	a0,0x2
    80004fac:	77850513          	addi	a0,a0,1912 # 80007720 <userret+0x690>
    80004fb0:	ffffb097          	auipc	ra,0xffffb
    80004fb4:	59e080e7          	jalr	1438(ra) # 8000054e <panic>
    panic("create: dirlink");
    80004fb8:	00002517          	auipc	a0,0x2
    80004fbc:	77850513          	addi	a0,a0,1912 # 80007730 <userret+0x6a0>
    80004fc0:	ffffb097          	auipc	ra,0xffffb
    80004fc4:	58e080e7          	jalr	1422(ra) # 8000054e <panic>
    return 0;
    80004fc8:	84aa                	mv	s1,a0
    80004fca:	b731                	j	80004ed6 <create+0x72>

0000000080004fcc <sys_dup>:
{
    80004fcc:	7179                	addi	sp,sp,-48
    80004fce:	f406                	sd	ra,40(sp)
    80004fd0:	f022                	sd	s0,32(sp)
    80004fd2:	ec26                	sd	s1,24(sp)
    80004fd4:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    80004fd6:	fd840613          	addi	a2,s0,-40
    80004fda:	4581                	li	a1,0
    80004fdc:	4501                	li	a0,0
    80004fde:	00000097          	auipc	ra,0x0
    80004fe2:	ddc080e7          	jalr	-548(ra) # 80004dba <argfd>
    return -1;
    80004fe6:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80004fe8:	02054363          	bltz	a0,8000500e <sys_dup+0x42>
  if((fd=fdalloc(f)) < 0)
    80004fec:	fd843503          	ld	a0,-40(s0)
    80004ff0:	00000097          	auipc	ra,0x0
    80004ff4:	e32080e7          	jalr	-462(ra) # 80004e22 <fdalloc>
    80004ff8:	84aa                	mv	s1,a0
    return -1;
    80004ffa:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    80004ffc:	00054963          	bltz	a0,8000500e <sys_dup+0x42>
  filedup(f);
    80005000:	fd843503          	ld	a0,-40(s0)
    80005004:	fffff097          	auipc	ra,0xfffff
    80005008:	35c080e7          	jalr	860(ra) # 80004360 <filedup>
  return fd;
    8000500c:	87a6                	mv	a5,s1
}
    8000500e:	853e                	mv	a0,a5
    80005010:	70a2                	ld	ra,40(sp)
    80005012:	7402                	ld	s0,32(sp)
    80005014:	64e2                	ld	s1,24(sp)
    80005016:	6145                	addi	sp,sp,48
    80005018:	8082                	ret

000000008000501a <sys_read>:
{
    8000501a:	7179                	addi	sp,sp,-48
    8000501c:	f406                	sd	ra,40(sp)
    8000501e:	f022                	sd	s0,32(sp)
    80005020:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005022:	fe840613          	addi	a2,s0,-24
    80005026:	4581                	li	a1,0
    80005028:	4501                	li	a0,0
    8000502a:	00000097          	auipc	ra,0x0
    8000502e:	d90080e7          	jalr	-624(ra) # 80004dba <argfd>
    return -1;
    80005032:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005034:	04054163          	bltz	a0,80005076 <sys_read+0x5c>
    80005038:	fe440593          	addi	a1,s0,-28
    8000503c:	4509                	li	a0,2
    8000503e:	ffffe097          	auipc	ra,0xffffe
    80005042:	8f2080e7          	jalr	-1806(ra) # 80002930 <argint>
    return -1;
    80005046:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005048:	02054763          	bltz	a0,80005076 <sys_read+0x5c>
    8000504c:	fd840593          	addi	a1,s0,-40
    80005050:	4505                	li	a0,1
    80005052:	ffffe097          	auipc	ra,0xffffe
    80005056:	900080e7          	jalr	-1792(ra) # 80002952 <argaddr>
    return -1;
    8000505a:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8000505c:	00054d63          	bltz	a0,80005076 <sys_read+0x5c>
  return fileread(f, p, n);
    80005060:	fe442603          	lw	a2,-28(s0)
    80005064:	fd843583          	ld	a1,-40(s0)
    80005068:	fe843503          	ld	a0,-24(s0)
    8000506c:	fffff097          	auipc	ra,0xfffff
    80005070:	480080e7          	jalr	1152(ra) # 800044ec <fileread>
    80005074:	87aa                	mv	a5,a0
}
    80005076:	853e                	mv	a0,a5
    80005078:	70a2                	ld	ra,40(sp)
    8000507a:	7402                	ld	s0,32(sp)
    8000507c:	6145                	addi	sp,sp,48
    8000507e:	8082                	ret

0000000080005080 <sys_write>:
{
    80005080:	711d                	addi	sp,sp,-96
    80005082:	ec86                	sd	ra,88(sp)
    80005084:	e8a2                	sd	s0,80(sp)
    80005086:	e4a6                	sd	s1,72(sp)
    80005088:	e0ca                	sd	s2,64(sp)
    8000508a:	fc4e                	sd	s3,56(sp)
    8000508c:	f852                	sd	s4,48(sp)
    8000508e:	f456                	sd	s5,40(sp)
    80005090:	1080                	addi	s0,sp,96
  struct proc *proc = myproc();
    80005092:	ffffc097          	auipc	ra,0xffffc
    80005096:	7b2080e7          	jalr	1970(ra) # 80001844 <myproc>
    8000509a:	84aa                	mv	s1,a0
  char instr[n];
    8000509c:	fb442783          	lw	a5,-76(s0)
    800050a0:	07bd                	addi	a5,a5,15
    800050a2:	9bc1                	andi	a5,a5,-16
    800050a4:	40f10133          	sub	sp,sp,a5
  if(argfd(0, &fd, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800050a8:	fb840613          	addi	a2,s0,-72
    800050ac:	fb040593          	addi	a1,s0,-80
    800050b0:	4501                	li	a0,0
    800050b2:	00000097          	auipc	ra,0x0
    800050b6:	d08080e7          	jalr	-760(ra) # 80004dba <argfd>
    return -1;
    800050ba:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800050bc:	04054463          	bltz	a0,80005104 <sys_write+0x84>
    800050c0:	890a                	mv	s2,sp
    800050c2:	fb440593          	addi	a1,s0,-76
    800050c6:	4509                	li	a0,2
    800050c8:	ffffe097          	auipc	ra,0xffffe
    800050cc:	868080e7          	jalr	-1944(ra) # 80002930 <argint>
    return -1;
    800050d0:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800050d2:	02054963          	bltz	a0,80005104 <sys_write+0x84>
    800050d6:	fa840593          	addi	a1,s0,-88
    800050da:	4505                	li	a0,1
    800050dc:	ffffe097          	auipc	ra,0xffffe
    800050e0:	876080e7          	jalr	-1930(ra) # 80002952 <argaddr>
    800050e4:	0c054763          	bltz	a0,800051b2 <sys_write+0x132>
  if(proc->tracing) {
    800050e8:	1684a783          	lw	a5,360(s1)
    800050ec:	eb85                	bnez	a5,8000511c <sys_write+0x9c>
  return filewrite(f, p, n);
    800050ee:	fb442603          	lw	a2,-76(s0)
    800050f2:	fa843583          	ld	a1,-88(s0)
    800050f6:	fb843503          	ld	a0,-72(s0)
    800050fa:	fffff097          	auipc	ra,0xfffff
    800050fe:	4b4080e7          	jalr	1204(ra) # 800045ae <filewrite>
    80005102:	87aa                	mv	a5,a0
}
    80005104:	853e                	mv	a0,a5
    80005106:	fa040113          	addi	sp,s0,-96
    8000510a:	60e6                	ld	ra,88(sp)
    8000510c:	6446                	ld	s0,80(sp)
    8000510e:	64a6                	ld	s1,72(sp)
    80005110:	6906                	ld	s2,64(sp)
    80005112:	79e2                	ld	s3,56(sp)
    80005114:	7a42                	ld	s4,48(sp)
    80005116:	7aa2                	ld	s5,40(sp)
    80005118:	6125                	addi	sp,sp,96
    8000511a:	8082                	ret
      fetchstr(p, instr, n);
    8000511c:	fb442603          	lw	a2,-76(s0)
    80005120:	85ca                	mv	a1,s2
    80005122:	fa843503          	ld	a0,-88(s0)
    80005126:	ffffd097          	auipc	ra,0xffffd
    8000512a:	7c2080e7          	jalr	1986(ra) # 800028e8 <fetchstr>
      printf("\n[%d]sys_write(%d, ", proc->pid, fd);
    8000512e:	fb042603          	lw	a2,-80(s0)
    80005132:	5c8c                	lw	a1,56(s1)
    80005134:	00002517          	auipc	a0,0x2
    80005138:	60c50513          	addi	a0,a0,1548 # 80007740 <userret+0x6b0>
    8000513c:	ffffb097          	auipc	ra,0xffffb
    80005140:	45c080e7          	jalr	1116(ra) # 80000598 <printf>
      cprintfn(instr, n);
    80005144:	fb442783          	lw	a5,-76(s0)
    for (i = 0; i < n; i++) {
    80005148:	04f05a63          	blez	a5,8000519c <sys_write+0x11c>
    8000514c:	84ca                	mv	s1,s2
    8000514e:	37fd                	addiw	a5,a5,-1
    80005150:	1782                	slli	a5,a5,0x20
    80005152:	9381                	srli	a5,a5,0x20
    80005154:	0785                	addi	a5,a5,1
    80005156:	993e                	add	s2,s2,a5
    if (c == '\n') {
    80005158:	49a9                	li	s3,10
        printf("%s", buf);
    8000515a:	00002a17          	auipc	s4,0x2
    8000515e:	606a0a13          	addi	s4,s4,1542 # 80007760 <userret+0x6d0>
        printf("\\n");
    80005162:	00002a97          	auipc	s5,0x2
    80005166:	5f6a8a93          	addi	s5,s5,1526 # 80007758 <userret+0x6c8>
    8000516a:	a839                	j	80005188 <sys_write+0x108>
        buf[0] = c;
    8000516c:	faf40023          	sb	a5,-96(s0)
        buf[1] = '\0';
    80005170:	fa0400a3          	sb	zero,-95(s0)
        printf("%s", buf);
    80005174:	fa040593          	addi	a1,s0,-96
    80005178:	8552                	mv	a0,s4
    8000517a:	ffffb097          	auipc	ra,0xffffb
    8000517e:	41e080e7          	jalr	1054(ra) # 80000598 <printf>
    for (i = 0; i < n; i++) {
    80005182:	0485                	addi	s1,s1,1
    80005184:	01248c63          	beq	s1,s2,8000519c <sys_write+0x11c>
        cputc_encoded(s[i]);
    80005188:	0004c783          	lbu	a5,0(s1)
    if (c == '\n') {
    8000518c:	ff3790e3          	bne	a5,s3,8000516c <sys_write+0xec>
        printf("\\n");
    80005190:	8556                	mv	a0,s5
    80005192:	ffffb097          	auipc	ra,0xffffb
    80005196:	406080e7          	jalr	1030(ra) # 80000598 <printf>
    8000519a:	b7e5                	j	80005182 <sys_write+0x102>
      printf(", %d)", n);
    8000519c:	fb442583          	lw	a1,-76(s0)
    800051a0:	00002517          	auipc	a0,0x2
    800051a4:	5c850513          	addi	a0,a0,1480 # 80007768 <userret+0x6d8>
    800051a8:	ffffb097          	auipc	ra,0xffffb
    800051ac:	3f0080e7          	jalr	1008(ra) # 80000598 <printf>
    800051b0:	bf3d                	j	800050ee <sys_write+0x6e>
    return -1;
    800051b2:	57fd                	li	a5,-1
    800051b4:	bf81                	j	80005104 <sys_write+0x84>

00000000800051b6 <sys_close>:
{
    800051b6:	1101                	addi	sp,sp,-32
    800051b8:	ec06                	sd	ra,24(sp)
    800051ba:	e822                	sd	s0,16(sp)
    800051bc:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    800051be:	fe040613          	addi	a2,s0,-32
    800051c2:	fec40593          	addi	a1,s0,-20
    800051c6:	4501                	li	a0,0
    800051c8:	00000097          	auipc	ra,0x0
    800051cc:	bf2080e7          	jalr	-1038(ra) # 80004dba <argfd>
    return -1;
    800051d0:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    800051d2:	02054463          	bltz	a0,800051fa <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    800051d6:	ffffc097          	auipc	ra,0xffffc
    800051da:	66e080e7          	jalr	1646(ra) # 80001844 <myproc>
    800051de:	fec42783          	lw	a5,-20(s0)
    800051e2:	07e9                	addi	a5,a5,26
    800051e4:	078e                	slli	a5,a5,0x3
    800051e6:	97aa                	add	a5,a5,a0
    800051e8:	0007b023          	sd	zero,0(a5)
  fileclose(f);
    800051ec:	fe043503          	ld	a0,-32(s0)
    800051f0:	fffff097          	auipc	ra,0xfffff
    800051f4:	1c2080e7          	jalr	450(ra) # 800043b2 <fileclose>
  return 0;
    800051f8:	4781                	li	a5,0
}
    800051fa:	853e                	mv	a0,a5
    800051fc:	60e2                	ld	ra,24(sp)
    800051fe:	6442                	ld	s0,16(sp)
    80005200:	6105                	addi	sp,sp,32
    80005202:	8082                	ret

0000000080005204 <sys_fstat>:
{
    80005204:	1101                	addi	sp,sp,-32
    80005206:	ec06                	sd	ra,24(sp)
    80005208:	e822                	sd	s0,16(sp)
    8000520a:	1000                	addi	s0,sp,32
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    8000520c:	fe840613          	addi	a2,s0,-24
    80005210:	4581                	li	a1,0
    80005212:	4501                	li	a0,0
    80005214:	00000097          	auipc	ra,0x0
    80005218:	ba6080e7          	jalr	-1114(ra) # 80004dba <argfd>
    return -1;
    8000521c:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    8000521e:	02054563          	bltz	a0,80005248 <sys_fstat+0x44>
    80005222:	fe040593          	addi	a1,s0,-32
    80005226:	4505                	li	a0,1
    80005228:	ffffd097          	auipc	ra,0xffffd
    8000522c:	72a080e7          	jalr	1834(ra) # 80002952 <argaddr>
    return -1;
    80005230:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    80005232:	00054b63          	bltz	a0,80005248 <sys_fstat+0x44>
  return filestat(f, st);
    80005236:	fe043583          	ld	a1,-32(s0)
    8000523a:	fe843503          	ld	a0,-24(s0)
    8000523e:	fffff097          	auipc	ra,0xfffff
    80005242:	23c080e7          	jalr	572(ra) # 8000447a <filestat>
    80005246:	87aa                	mv	a5,a0
}
    80005248:	853e                	mv	a0,a5
    8000524a:	60e2                	ld	ra,24(sp)
    8000524c:	6442                	ld	s0,16(sp)
    8000524e:	6105                	addi	sp,sp,32
    80005250:	8082                	ret

0000000080005252 <sys_link>:
{
    80005252:	7169                	addi	sp,sp,-304
    80005254:	f606                	sd	ra,296(sp)
    80005256:	f222                	sd	s0,288(sp)
    80005258:	ee26                	sd	s1,280(sp)
    8000525a:	ea4a                	sd	s2,272(sp)
    8000525c:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000525e:	08000613          	li	a2,128
    80005262:	ed040593          	addi	a1,s0,-304
    80005266:	4501                	li	a0,0
    80005268:	ffffd097          	auipc	ra,0xffffd
    8000526c:	70c080e7          	jalr	1804(ra) # 80002974 <argstr>
    return -1;
    80005270:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005272:	10054e63          	bltz	a0,8000538e <sys_link+0x13c>
    80005276:	08000613          	li	a2,128
    8000527a:	f5040593          	addi	a1,s0,-176
    8000527e:	4505                	li	a0,1
    80005280:	ffffd097          	auipc	ra,0xffffd
    80005284:	6f4080e7          	jalr	1780(ra) # 80002974 <argstr>
    return -1;
    80005288:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000528a:	10054263          	bltz	a0,8000538e <sys_link+0x13c>
  begin_op();
    8000528e:	fffff097          	auipc	ra,0xfffff
    80005292:	c52080e7          	jalr	-942(ra) # 80003ee0 <begin_op>
  if((ip = namei(old)) == 0){
    80005296:	ed040513          	addi	a0,s0,-304
    8000529a:	fffff097          	auipc	ra,0xfffff
    8000529e:	a3a080e7          	jalr	-1478(ra) # 80003cd4 <namei>
    800052a2:	84aa                	mv	s1,a0
    800052a4:	c551                	beqz	a0,80005330 <sys_link+0xde>
  ilock(ip);
    800052a6:	ffffe097          	auipc	ra,0xffffe
    800052aa:	2a4080e7          	jalr	676(ra) # 8000354a <ilock>
  if(ip->type == T_DIR){
    800052ae:	04449703          	lh	a4,68(s1)
    800052b2:	4785                	li	a5,1
    800052b4:	08f70463          	beq	a4,a5,8000533c <sys_link+0xea>
  ip->nlink++;
    800052b8:	04a4d783          	lhu	a5,74(s1)
    800052bc:	2785                	addiw	a5,a5,1
    800052be:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800052c2:	8526                	mv	a0,s1
    800052c4:	ffffe097          	auipc	ra,0xffffe
    800052c8:	1bc080e7          	jalr	444(ra) # 80003480 <iupdate>
  iunlock(ip);
    800052cc:	8526                	mv	a0,s1
    800052ce:	ffffe097          	auipc	ra,0xffffe
    800052d2:	33e080e7          	jalr	830(ra) # 8000360c <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    800052d6:	fd040593          	addi	a1,s0,-48
    800052da:	f5040513          	addi	a0,s0,-176
    800052de:	fffff097          	auipc	ra,0xfffff
    800052e2:	a14080e7          	jalr	-1516(ra) # 80003cf2 <nameiparent>
    800052e6:	892a                	mv	s2,a0
    800052e8:	c935                	beqz	a0,8000535c <sys_link+0x10a>
  ilock(dp);
    800052ea:	ffffe097          	auipc	ra,0xffffe
    800052ee:	260080e7          	jalr	608(ra) # 8000354a <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    800052f2:	00092703          	lw	a4,0(s2)
    800052f6:	409c                	lw	a5,0(s1)
    800052f8:	04f71d63          	bne	a4,a5,80005352 <sys_link+0x100>
    800052fc:	40d0                	lw	a2,4(s1)
    800052fe:	fd040593          	addi	a1,s0,-48
    80005302:	854a                	mv	a0,s2
    80005304:	fffff097          	auipc	ra,0xfffff
    80005308:	90e080e7          	jalr	-1778(ra) # 80003c12 <dirlink>
    8000530c:	04054363          	bltz	a0,80005352 <sys_link+0x100>
  iunlockput(dp);
    80005310:	854a                	mv	a0,s2
    80005312:	ffffe097          	auipc	ra,0xffffe
    80005316:	476080e7          	jalr	1142(ra) # 80003788 <iunlockput>
  iput(ip);
    8000531a:	8526                	mv	a0,s1
    8000531c:	ffffe097          	auipc	ra,0xffffe
    80005320:	33c080e7          	jalr	828(ra) # 80003658 <iput>
  end_op();
    80005324:	fffff097          	auipc	ra,0xfffff
    80005328:	c3c080e7          	jalr	-964(ra) # 80003f60 <end_op>
  return 0;
    8000532c:	4781                	li	a5,0
    8000532e:	a085                	j	8000538e <sys_link+0x13c>
    end_op();
    80005330:	fffff097          	auipc	ra,0xfffff
    80005334:	c30080e7          	jalr	-976(ra) # 80003f60 <end_op>
    return -1;
    80005338:	57fd                	li	a5,-1
    8000533a:	a891                	j	8000538e <sys_link+0x13c>
    iunlockput(ip);
    8000533c:	8526                	mv	a0,s1
    8000533e:	ffffe097          	auipc	ra,0xffffe
    80005342:	44a080e7          	jalr	1098(ra) # 80003788 <iunlockput>
    end_op();
    80005346:	fffff097          	auipc	ra,0xfffff
    8000534a:	c1a080e7          	jalr	-998(ra) # 80003f60 <end_op>
    return -1;
    8000534e:	57fd                	li	a5,-1
    80005350:	a83d                	j	8000538e <sys_link+0x13c>
    iunlockput(dp);
    80005352:	854a                	mv	a0,s2
    80005354:	ffffe097          	auipc	ra,0xffffe
    80005358:	434080e7          	jalr	1076(ra) # 80003788 <iunlockput>
  ilock(ip);
    8000535c:	8526                	mv	a0,s1
    8000535e:	ffffe097          	auipc	ra,0xffffe
    80005362:	1ec080e7          	jalr	492(ra) # 8000354a <ilock>
  ip->nlink--;
    80005366:	04a4d783          	lhu	a5,74(s1)
    8000536a:	37fd                	addiw	a5,a5,-1
    8000536c:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005370:	8526                	mv	a0,s1
    80005372:	ffffe097          	auipc	ra,0xffffe
    80005376:	10e080e7          	jalr	270(ra) # 80003480 <iupdate>
  iunlockput(ip);
    8000537a:	8526                	mv	a0,s1
    8000537c:	ffffe097          	auipc	ra,0xffffe
    80005380:	40c080e7          	jalr	1036(ra) # 80003788 <iunlockput>
  end_op();
    80005384:	fffff097          	auipc	ra,0xfffff
    80005388:	bdc080e7          	jalr	-1060(ra) # 80003f60 <end_op>
  return -1;
    8000538c:	57fd                	li	a5,-1
}
    8000538e:	853e                	mv	a0,a5
    80005390:	70b2                	ld	ra,296(sp)
    80005392:	7412                	ld	s0,288(sp)
    80005394:	64f2                	ld	s1,280(sp)
    80005396:	6952                	ld	s2,272(sp)
    80005398:	6155                	addi	sp,sp,304
    8000539a:	8082                	ret

000000008000539c <sys_unlink>:
{
    8000539c:	7151                	addi	sp,sp,-240
    8000539e:	f586                	sd	ra,232(sp)
    800053a0:	f1a2                	sd	s0,224(sp)
    800053a2:	eda6                	sd	s1,216(sp)
    800053a4:	e9ca                	sd	s2,208(sp)
    800053a6:	e5ce                	sd	s3,200(sp)
    800053a8:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    800053aa:	08000613          	li	a2,128
    800053ae:	f3040593          	addi	a1,s0,-208
    800053b2:	4501                	li	a0,0
    800053b4:	ffffd097          	auipc	ra,0xffffd
    800053b8:	5c0080e7          	jalr	1472(ra) # 80002974 <argstr>
    800053bc:	18054163          	bltz	a0,8000553e <sys_unlink+0x1a2>
  begin_op();
    800053c0:	fffff097          	auipc	ra,0xfffff
    800053c4:	b20080e7          	jalr	-1248(ra) # 80003ee0 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    800053c8:	fb040593          	addi	a1,s0,-80
    800053cc:	f3040513          	addi	a0,s0,-208
    800053d0:	fffff097          	auipc	ra,0xfffff
    800053d4:	922080e7          	jalr	-1758(ra) # 80003cf2 <nameiparent>
    800053d8:	84aa                	mv	s1,a0
    800053da:	c979                	beqz	a0,800054b0 <sys_unlink+0x114>
  ilock(dp);
    800053dc:	ffffe097          	auipc	ra,0xffffe
    800053e0:	16e080e7          	jalr	366(ra) # 8000354a <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    800053e4:	00002597          	auipc	a1,0x2
    800053e8:	32c58593          	addi	a1,a1,812 # 80007710 <userret+0x680>
    800053ec:	fb040513          	addi	a0,s0,-80
    800053f0:	ffffe097          	auipc	ra,0xffffe
    800053f4:	5f8080e7          	jalr	1528(ra) # 800039e8 <namecmp>
    800053f8:	14050a63          	beqz	a0,8000554c <sys_unlink+0x1b0>
    800053fc:	00002597          	auipc	a1,0x2
    80005400:	31c58593          	addi	a1,a1,796 # 80007718 <userret+0x688>
    80005404:	fb040513          	addi	a0,s0,-80
    80005408:	ffffe097          	auipc	ra,0xffffe
    8000540c:	5e0080e7          	jalr	1504(ra) # 800039e8 <namecmp>
    80005410:	12050e63          	beqz	a0,8000554c <sys_unlink+0x1b0>
  if((ip = dirlookup(dp, name, &off)) == 0)
    80005414:	f2c40613          	addi	a2,s0,-212
    80005418:	fb040593          	addi	a1,s0,-80
    8000541c:	8526                	mv	a0,s1
    8000541e:	ffffe097          	auipc	ra,0xffffe
    80005422:	5e4080e7          	jalr	1508(ra) # 80003a02 <dirlookup>
    80005426:	892a                	mv	s2,a0
    80005428:	12050263          	beqz	a0,8000554c <sys_unlink+0x1b0>
  ilock(ip);
    8000542c:	ffffe097          	auipc	ra,0xffffe
    80005430:	11e080e7          	jalr	286(ra) # 8000354a <ilock>
  if(ip->nlink < 1)
    80005434:	04a91783          	lh	a5,74(s2)
    80005438:	08f05263          	blez	a5,800054bc <sys_unlink+0x120>
  if(ip->type == T_DIR && !isdirempty(ip)){
    8000543c:	04491703          	lh	a4,68(s2)
    80005440:	4785                	li	a5,1
    80005442:	08f70563          	beq	a4,a5,800054cc <sys_unlink+0x130>
  memset(&de, 0, sizeof(de));
    80005446:	4641                	li	a2,16
    80005448:	4581                	li	a1,0
    8000544a:	fc040513          	addi	a0,s0,-64
    8000544e:	ffffb097          	auipc	ra,0xffffb
    80005452:	720080e7          	jalr	1824(ra) # 80000b6e <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005456:	4741                	li	a4,16
    80005458:	f2c42683          	lw	a3,-212(s0)
    8000545c:	fc040613          	addi	a2,s0,-64
    80005460:	4581                	li	a1,0
    80005462:	8526                	mv	a0,s1
    80005464:	ffffe097          	auipc	ra,0xffffe
    80005468:	46a080e7          	jalr	1130(ra) # 800038ce <writei>
    8000546c:	47c1                	li	a5,16
    8000546e:	0af51563          	bne	a0,a5,80005518 <sys_unlink+0x17c>
  if(ip->type == T_DIR){
    80005472:	04491703          	lh	a4,68(s2)
    80005476:	4785                	li	a5,1
    80005478:	0af70863          	beq	a4,a5,80005528 <sys_unlink+0x18c>
  iunlockput(dp);
    8000547c:	8526                	mv	a0,s1
    8000547e:	ffffe097          	auipc	ra,0xffffe
    80005482:	30a080e7          	jalr	778(ra) # 80003788 <iunlockput>
  ip->nlink--;
    80005486:	04a95783          	lhu	a5,74(s2)
    8000548a:	37fd                	addiw	a5,a5,-1
    8000548c:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80005490:	854a                	mv	a0,s2
    80005492:	ffffe097          	auipc	ra,0xffffe
    80005496:	fee080e7          	jalr	-18(ra) # 80003480 <iupdate>
  iunlockput(ip);
    8000549a:	854a                	mv	a0,s2
    8000549c:	ffffe097          	auipc	ra,0xffffe
    800054a0:	2ec080e7          	jalr	748(ra) # 80003788 <iunlockput>
  end_op();
    800054a4:	fffff097          	auipc	ra,0xfffff
    800054a8:	abc080e7          	jalr	-1348(ra) # 80003f60 <end_op>
  return 0;
    800054ac:	4501                	li	a0,0
    800054ae:	a84d                	j	80005560 <sys_unlink+0x1c4>
    end_op();
    800054b0:	fffff097          	auipc	ra,0xfffff
    800054b4:	ab0080e7          	jalr	-1360(ra) # 80003f60 <end_op>
    return -1;
    800054b8:	557d                	li	a0,-1
    800054ba:	a05d                	j	80005560 <sys_unlink+0x1c4>
    panic("unlink: nlink < 1");
    800054bc:	00002517          	auipc	a0,0x2
    800054c0:	2b450513          	addi	a0,a0,692 # 80007770 <userret+0x6e0>
    800054c4:	ffffb097          	auipc	ra,0xffffb
    800054c8:	08a080e7          	jalr	138(ra) # 8000054e <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    800054cc:	04c92703          	lw	a4,76(s2)
    800054d0:	02000793          	li	a5,32
    800054d4:	f6e7f9e3          	bgeu	a5,a4,80005446 <sys_unlink+0xaa>
    800054d8:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800054dc:	4741                	li	a4,16
    800054de:	86ce                	mv	a3,s3
    800054e0:	f1840613          	addi	a2,s0,-232
    800054e4:	4581                	li	a1,0
    800054e6:	854a                	mv	a0,s2
    800054e8:	ffffe097          	auipc	ra,0xffffe
    800054ec:	2f2080e7          	jalr	754(ra) # 800037da <readi>
    800054f0:	47c1                	li	a5,16
    800054f2:	00f51b63          	bne	a0,a5,80005508 <sys_unlink+0x16c>
    if(de.inum != 0)
    800054f6:	f1845783          	lhu	a5,-232(s0)
    800054fa:	e7a1                	bnez	a5,80005542 <sys_unlink+0x1a6>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    800054fc:	29c1                	addiw	s3,s3,16
    800054fe:	04c92783          	lw	a5,76(s2)
    80005502:	fcf9ede3          	bltu	s3,a5,800054dc <sys_unlink+0x140>
    80005506:	b781                	j	80005446 <sys_unlink+0xaa>
      panic("isdirempty: readi");
    80005508:	00002517          	auipc	a0,0x2
    8000550c:	28050513          	addi	a0,a0,640 # 80007788 <userret+0x6f8>
    80005510:	ffffb097          	auipc	ra,0xffffb
    80005514:	03e080e7          	jalr	62(ra) # 8000054e <panic>
    panic("unlink: writei");
    80005518:	00002517          	auipc	a0,0x2
    8000551c:	28850513          	addi	a0,a0,648 # 800077a0 <userret+0x710>
    80005520:	ffffb097          	auipc	ra,0xffffb
    80005524:	02e080e7          	jalr	46(ra) # 8000054e <panic>
    dp->nlink--;
    80005528:	04a4d783          	lhu	a5,74(s1)
    8000552c:	37fd                	addiw	a5,a5,-1
    8000552e:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005532:	8526                	mv	a0,s1
    80005534:	ffffe097          	auipc	ra,0xffffe
    80005538:	f4c080e7          	jalr	-180(ra) # 80003480 <iupdate>
    8000553c:	b781                	j	8000547c <sys_unlink+0xe0>
    return -1;
    8000553e:	557d                	li	a0,-1
    80005540:	a005                	j	80005560 <sys_unlink+0x1c4>
    iunlockput(ip);
    80005542:	854a                	mv	a0,s2
    80005544:	ffffe097          	auipc	ra,0xffffe
    80005548:	244080e7          	jalr	580(ra) # 80003788 <iunlockput>
  iunlockput(dp);
    8000554c:	8526                	mv	a0,s1
    8000554e:	ffffe097          	auipc	ra,0xffffe
    80005552:	23a080e7          	jalr	570(ra) # 80003788 <iunlockput>
  end_op();
    80005556:	fffff097          	auipc	ra,0xfffff
    8000555a:	a0a080e7          	jalr	-1526(ra) # 80003f60 <end_op>
  return -1;
    8000555e:	557d                	li	a0,-1
}
    80005560:	70ae                	ld	ra,232(sp)
    80005562:	740e                	ld	s0,224(sp)
    80005564:	64ee                	ld	s1,216(sp)
    80005566:	694e                	ld	s2,208(sp)
    80005568:	69ae                	ld	s3,200(sp)
    8000556a:	616d                	addi	sp,sp,240
    8000556c:	8082                	ret

000000008000556e <sys_open>:

uint64
sys_open(void)
{
    8000556e:	7131                	addi	sp,sp,-192
    80005570:	fd06                	sd	ra,184(sp)
    80005572:	f922                	sd	s0,176(sp)
    80005574:	f526                	sd	s1,168(sp)
    80005576:	f14a                	sd	s2,160(sp)
    80005578:	ed4e                	sd	s3,152(sp)
    8000557a:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    8000557c:	08000613          	li	a2,128
    80005580:	f5040593          	addi	a1,s0,-176
    80005584:	4501                	li	a0,0
    80005586:	ffffd097          	auipc	ra,0xffffd
    8000558a:	3ee080e7          	jalr	1006(ra) # 80002974 <argstr>
    return -1;
    8000558e:	54fd                	li	s1,-1
  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    80005590:	0a054763          	bltz	a0,8000563e <sys_open+0xd0>
    80005594:	f4c40593          	addi	a1,s0,-180
    80005598:	4505                	li	a0,1
    8000559a:	ffffd097          	auipc	ra,0xffffd
    8000559e:	396080e7          	jalr	918(ra) # 80002930 <argint>
    800055a2:	08054e63          	bltz	a0,8000563e <sys_open+0xd0>

  begin_op();
    800055a6:	fffff097          	auipc	ra,0xfffff
    800055aa:	93a080e7          	jalr	-1734(ra) # 80003ee0 <begin_op>

  if(omode & O_CREATE){
    800055ae:	f4c42783          	lw	a5,-180(s0)
    800055b2:	2007f793          	andi	a5,a5,512
    800055b6:	c3cd                	beqz	a5,80005658 <sys_open+0xea>
    ip = create(path, T_FILE, 0, 0);
    800055b8:	4681                	li	a3,0
    800055ba:	4601                	li	a2,0
    800055bc:	4589                	li	a1,2
    800055be:	f5040513          	addi	a0,s0,-176
    800055c2:	00000097          	auipc	ra,0x0
    800055c6:	8a2080e7          	jalr	-1886(ra) # 80004e64 <create>
    800055ca:	892a                	mv	s2,a0
    if(ip == 0){
    800055cc:	c149                	beqz	a0,8000564e <sys_open+0xe0>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    800055ce:	04491703          	lh	a4,68(s2)
    800055d2:	478d                	li	a5,3
    800055d4:	00f71763          	bne	a4,a5,800055e2 <sys_open+0x74>
    800055d8:	04695703          	lhu	a4,70(s2)
    800055dc:	47a5                	li	a5,9
    800055de:	0ce7e263          	bltu	a5,a4,800056a2 <sys_open+0x134>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    800055e2:	fffff097          	auipc	ra,0xfffff
    800055e6:	d14080e7          	jalr	-748(ra) # 800042f6 <filealloc>
    800055ea:	89aa                	mv	s3,a0
    800055ec:	c175                	beqz	a0,800056d0 <sys_open+0x162>
    800055ee:	00000097          	auipc	ra,0x0
    800055f2:	834080e7          	jalr	-1996(ra) # 80004e22 <fdalloc>
    800055f6:	84aa                	mv	s1,a0
    800055f8:	0c054763          	bltz	a0,800056c6 <sys_open+0x158>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    800055fc:	04491703          	lh	a4,68(s2)
    80005600:	478d                	li	a5,3
    80005602:	0af70b63          	beq	a4,a5,800056b8 <sys_open+0x14a>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80005606:	4789                	li	a5,2
    80005608:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    8000560c:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    80005610:	0129bc23          	sd	s2,24(s3)
  f->readable = !(omode & O_WRONLY);
    80005614:	f4c42783          	lw	a5,-180(s0)
    80005618:	0017c713          	xori	a4,a5,1
    8000561c:	8b05                	andi	a4,a4,1
    8000561e:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80005622:	8b8d                	andi	a5,a5,3
    80005624:	00f037b3          	snez	a5,a5
    80005628:	00f984a3          	sb	a5,9(s3)

  iunlock(ip);
    8000562c:	854a                	mv	a0,s2
    8000562e:	ffffe097          	auipc	ra,0xffffe
    80005632:	fde080e7          	jalr	-34(ra) # 8000360c <iunlock>
  end_op();
    80005636:	fffff097          	auipc	ra,0xfffff
    8000563a:	92a080e7          	jalr	-1750(ra) # 80003f60 <end_op>

  return fd;
}
    8000563e:	8526                	mv	a0,s1
    80005640:	70ea                	ld	ra,184(sp)
    80005642:	744a                	ld	s0,176(sp)
    80005644:	74aa                	ld	s1,168(sp)
    80005646:	790a                	ld	s2,160(sp)
    80005648:	69ea                	ld	s3,152(sp)
    8000564a:	6129                	addi	sp,sp,192
    8000564c:	8082                	ret
      end_op();
    8000564e:	fffff097          	auipc	ra,0xfffff
    80005652:	912080e7          	jalr	-1774(ra) # 80003f60 <end_op>
      return -1;
    80005656:	b7e5                	j	8000563e <sys_open+0xd0>
    if((ip = namei(path)) == 0){
    80005658:	f5040513          	addi	a0,s0,-176
    8000565c:	ffffe097          	auipc	ra,0xffffe
    80005660:	678080e7          	jalr	1656(ra) # 80003cd4 <namei>
    80005664:	892a                	mv	s2,a0
    80005666:	c905                	beqz	a0,80005696 <sys_open+0x128>
    ilock(ip);
    80005668:	ffffe097          	auipc	ra,0xffffe
    8000566c:	ee2080e7          	jalr	-286(ra) # 8000354a <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80005670:	04491703          	lh	a4,68(s2)
    80005674:	4785                	li	a5,1
    80005676:	f4f71ce3          	bne	a4,a5,800055ce <sys_open+0x60>
    8000567a:	f4c42783          	lw	a5,-180(s0)
    8000567e:	d3b5                	beqz	a5,800055e2 <sys_open+0x74>
      iunlockput(ip);
    80005680:	854a                	mv	a0,s2
    80005682:	ffffe097          	auipc	ra,0xffffe
    80005686:	106080e7          	jalr	262(ra) # 80003788 <iunlockput>
      end_op();
    8000568a:	fffff097          	auipc	ra,0xfffff
    8000568e:	8d6080e7          	jalr	-1834(ra) # 80003f60 <end_op>
      return -1;
    80005692:	54fd                	li	s1,-1
    80005694:	b76d                	j	8000563e <sys_open+0xd0>
      end_op();
    80005696:	fffff097          	auipc	ra,0xfffff
    8000569a:	8ca080e7          	jalr	-1846(ra) # 80003f60 <end_op>
      return -1;
    8000569e:	54fd                	li	s1,-1
    800056a0:	bf79                	j	8000563e <sys_open+0xd0>
    iunlockput(ip);
    800056a2:	854a                	mv	a0,s2
    800056a4:	ffffe097          	auipc	ra,0xffffe
    800056a8:	0e4080e7          	jalr	228(ra) # 80003788 <iunlockput>
    end_op();
    800056ac:	fffff097          	auipc	ra,0xfffff
    800056b0:	8b4080e7          	jalr	-1868(ra) # 80003f60 <end_op>
    return -1;
    800056b4:	54fd                	li	s1,-1
    800056b6:	b761                	j	8000563e <sys_open+0xd0>
    f->type = FD_DEVICE;
    800056b8:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    800056bc:	04691783          	lh	a5,70(s2)
    800056c0:	02f99223          	sh	a5,36(s3)
    800056c4:	b7b1                	j	80005610 <sys_open+0xa2>
      fileclose(f);
    800056c6:	854e                	mv	a0,s3
    800056c8:	fffff097          	auipc	ra,0xfffff
    800056cc:	cea080e7          	jalr	-790(ra) # 800043b2 <fileclose>
    iunlockput(ip);
    800056d0:	854a                	mv	a0,s2
    800056d2:	ffffe097          	auipc	ra,0xffffe
    800056d6:	0b6080e7          	jalr	182(ra) # 80003788 <iunlockput>
    end_op();
    800056da:	fffff097          	auipc	ra,0xfffff
    800056de:	886080e7          	jalr	-1914(ra) # 80003f60 <end_op>
    return -1;
    800056e2:	54fd                	li	s1,-1
    800056e4:	bfa9                	j	8000563e <sys_open+0xd0>

00000000800056e6 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    800056e6:	7175                	addi	sp,sp,-144
    800056e8:	e506                	sd	ra,136(sp)
    800056ea:	e122                	sd	s0,128(sp)
    800056ec:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    800056ee:	ffffe097          	auipc	ra,0xffffe
    800056f2:	7f2080e7          	jalr	2034(ra) # 80003ee0 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    800056f6:	08000613          	li	a2,128
    800056fa:	f7040593          	addi	a1,s0,-144
    800056fe:	4501                	li	a0,0
    80005700:	ffffd097          	auipc	ra,0xffffd
    80005704:	274080e7          	jalr	628(ra) # 80002974 <argstr>
    80005708:	02054963          	bltz	a0,8000573a <sys_mkdir+0x54>
    8000570c:	4681                	li	a3,0
    8000570e:	4601                	li	a2,0
    80005710:	4585                	li	a1,1
    80005712:	f7040513          	addi	a0,s0,-144
    80005716:	fffff097          	auipc	ra,0xfffff
    8000571a:	74e080e7          	jalr	1870(ra) # 80004e64 <create>
    8000571e:	cd11                	beqz	a0,8000573a <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005720:	ffffe097          	auipc	ra,0xffffe
    80005724:	068080e7          	jalr	104(ra) # 80003788 <iunlockput>
  end_op();
    80005728:	fffff097          	auipc	ra,0xfffff
    8000572c:	838080e7          	jalr	-1992(ra) # 80003f60 <end_op>
  return 0;
    80005730:	4501                	li	a0,0
}
    80005732:	60aa                	ld	ra,136(sp)
    80005734:	640a                	ld	s0,128(sp)
    80005736:	6149                	addi	sp,sp,144
    80005738:	8082                	ret
    end_op();
    8000573a:	fffff097          	auipc	ra,0xfffff
    8000573e:	826080e7          	jalr	-2010(ra) # 80003f60 <end_op>
    return -1;
    80005742:	557d                	li	a0,-1
    80005744:	b7fd                	j	80005732 <sys_mkdir+0x4c>

0000000080005746 <sys_mknod>:

uint64
sys_mknod(void)
{
    80005746:	7135                	addi	sp,sp,-160
    80005748:	ed06                	sd	ra,152(sp)
    8000574a:	e922                	sd	s0,144(sp)
    8000574c:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    8000574e:	ffffe097          	auipc	ra,0xffffe
    80005752:	792080e7          	jalr	1938(ra) # 80003ee0 <begin_op>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005756:	08000613          	li	a2,128
    8000575a:	f7040593          	addi	a1,s0,-144
    8000575e:	4501                	li	a0,0
    80005760:	ffffd097          	auipc	ra,0xffffd
    80005764:	214080e7          	jalr	532(ra) # 80002974 <argstr>
    80005768:	04054a63          	bltz	a0,800057bc <sys_mknod+0x76>
     argint(1, &major) < 0 ||
    8000576c:	f6c40593          	addi	a1,s0,-148
    80005770:	4505                	li	a0,1
    80005772:	ffffd097          	auipc	ra,0xffffd
    80005776:	1be080e7          	jalr	446(ra) # 80002930 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    8000577a:	04054163          	bltz	a0,800057bc <sys_mknod+0x76>
     argint(2, &minor) < 0 ||
    8000577e:	f6840593          	addi	a1,s0,-152
    80005782:	4509                	li	a0,2
    80005784:	ffffd097          	auipc	ra,0xffffd
    80005788:	1ac080e7          	jalr	428(ra) # 80002930 <argint>
     argint(1, &major) < 0 ||
    8000578c:	02054863          	bltz	a0,800057bc <sys_mknod+0x76>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80005790:	f6841683          	lh	a3,-152(s0)
    80005794:	f6c41603          	lh	a2,-148(s0)
    80005798:	458d                	li	a1,3
    8000579a:	f7040513          	addi	a0,s0,-144
    8000579e:	fffff097          	auipc	ra,0xfffff
    800057a2:	6c6080e7          	jalr	1734(ra) # 80004e64 <create>
     argint(2, &minor) < 0 ||
    800057a6:	c919                	beqz	a0,800057bc <sys_mknod+0x76>
    end_op();
    return -1;
  }
  iunlockput(ip);
    800057a8:	ffffe097          	auipc	ra,0xffffe
    800057ac:	fe0080e7          	jalr	-32(ra) # 80003788 <iunlockput>
  end_op();
    800057b0:	ffffe097          	auipc	ra,0xffffe
    800057b4:	7b0080e7          	jalr	1968(ra) # 80003f60 <end_op>
  return 0;
    800057b8:	4501                	li	a0,0
    800057ba:	a031                	j	800057c6 <sys_mknod+0x80>
    end_op();
    800057bc:	ffffe097          	auipc	ra,0xffffe
    800057c0:	7a4080e7          	jalr	1956(ra) # 80003f60 <end_op>
    return -1;
    800057c4:	557d                	li	a0,-1
}
    800057c6:	60ea                	ld	ra,152(sp)
    800057c8:	644a                	ld	s0,144(sp)
    800057ca:	610d                	addi	sp,sp,160
    800057cc:	8082                	ret

00000000800057ce <sys_chdir>:

uint64
sys_chdir(void)
{
    800057ce:	7135                	addi	sp,sp,-160
    800057d0:	ed06                	sd	ra,152(sp)
    800057d2:	e922                	sd	s0,144(sp)
    800057d4:	e526                	sd	s1,136(sp)
    800057d6:	e14a                	sd	s2,128(sp)
    800057d8:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    800057da:	ffffc097          	auipc	ra,0xffffc
    800057de:	06a080e7          	jalr	106(ra) # 80001844 <myproc>
    800057e2:	892a                	mv	s2,a0
  
  begin_op();
    800057e4:	ffffe097          	auipc	ra,0xffffe
    800057e8:	6fc080e7          	jalr	1788(ra) # 80003ee0 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    800057ec:	08000613          	li	a2,128
    800057f0:	f6040593          	addi	a1,s0,-160
    800057f4:	4501                	li	a0,0
    800057f6:	ffffd097          	auipc	ra,0xffffd
    800057fa:	17e080e7          	jalr	382(ra) # 80002974 <argstr>
    800057fe:	04054b63          	bltz	a0,80005854 <sys_chdir+0x86>
    80005802:	f6040513          	addi	a0,s0,-160
    80005806:	ffffe097          	auipc	ra,0xffffe
    8000580a:	4ce080e7          	jalr	1230(ra) # 80003cd4 <namei>
    8000580e:	84aa                	mv	s1,a0
    80005810:	c131                	beqz	a0,80005854 <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    80005812:	ffffe097          	auipc	ra,0xffffe
    80005816:	d38080e7          	jalr	-712(ra) # 8000354a <ilock>
  if(ip->type != T_DIR){
    8000581a:	04449703          	lh	a4,68(s1)
    8000581e:	4785                	li	a5,1
    80005820:	04f71063          	bne	a4,a5,80005860 <sys_chdir+0x92>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80005824:	8526                	mv	a0,s1
    80005826:	ffffe097          	auipc	ra,0xffffe
    8000582a:	de6080e7          	jalr	-538(ra) # 8000360c <iunlock>
  iput(p->cwd);
    8000582e:	15093503          	ld	a0,336(s2)
    80005832:	ffffe097          	auipc	ra,0xffffe
    80005836:	e26080e7          	jalr	-474(ra) # 80003658 <iput>
  end_op();
    8000583a:	ffffe097          	auipc	ra,0xffffe
    8000583e:	726080e7          	jalr	1830(ra) # 80003f60 <end_op>
  p->cwd = ip;
    80005842:	14993823          	sd	s1,336(s2)
  return 0;
    80005846:	4501                	li	a0,0
}
    80005848:	60ea                	ld	ra,152(sp)
    8000584a:	644a                	ld	s0,144(sp)
    8000584c:	64aa                	ld	s1,136(sp)
    8000584e:	690a                	ld	s2,128(sp)
    80005850:	610d                	addi	sp,sp,160
    80005852:	8082                	ret
    end_op();
    80005854:	ffffe097          	auipc	ra,0xffffe
    80005858:	70c080e7          	jalr	1804(ra) # 80003f60 <end_op>
    return -1;
    8000585c:	557d                	li	a0,-1
    8000585e:	b7ed                	j	80005848 <sys_chdir+0x7a>
    iunlockput(ip);
    80005860:	8526                	mv	a0,s1
    80005862:	ffffe097          	auipc	ra,0xffffe
    80005866:	f26080e7          	jalr	-218(ra) # 80003788 <iunlockput>
    end_op();
    8000586a:	ffffe097          	auipc	ra,0xffffe
    8000586e:	6f6080e7          	jalr	1782(ra) # 80003f60 <end_op>
    return -1;
    80005872:	557d                	li	a0,-1
    80005874:	bfd1                	j	80005848 <sys_chdir+0x7a>

0000000080005876 <sys_exec>:

uint64
sys_exec(void)
{
    80005876:	7145                	addi	sp,sp,-464
    80005878:	e786                	sd	ra,456(sp)
    8000587a:	e3a2                	sd	s0,448(sp)
    8000587c:	ff26                	sd	s1,440(sp)
    8000587e:	fb4a                	sd	s2,432(sp)
    80005880:	f74e                	sd	s3,424(sp)
    80005882:	f352                	sd	s4,416(sp)
    80005884:	ef56                	sd	s5,408(sp)
    80005886:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    80005888:	08000613          	li	a2,128
    8000588c:	f4040593          	addi	a1,s0,-192
    80005890:	4501                	li	a0,0
    80005892:	ffffd097          	auipc	ra,0xffffd
    80005896:	0e2080e7          	jalr	226(ra) # 80002974 <argstr>
    8000589a:	0e054663          	bltz	a0,80005986 <sys_exec+0x110>
    8000589e:	e3840593          	addi	a1,s0,-456
    800058a2:	4505                	li	a0,1
    800058a4:	ffffd097          	auipc	ra,0xffffd
    800058a8:	0ae080e7          	jalr	174(ra) # 80002952 <argaddr>
    800058ac:	0e054763          	bltz	a0,8000599a <sys_exec+0x124>
    return -1;
  }
  memset(argv, 0, sizeof(argv));
    800058b0:	10000613          	li	a2,256
    800058b4:	4581                	li	a1,0
    800058b6:	e4040513          	addi	a0,s0,-448
    800058ba:	ffffb097          	auipc	ra,0xffffb
    800058be:	2b4080e7          	jalr	692(ra) # 80000b6e <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    800058c2:	e4040913          	addi	s2,s0,-448
  memset(argv, 0, sizeof(argv));
    800058c6:	89ca                	mv	s3,s2
    800058c8:	4481                	li	s1,0
    if(i >= NELEM(argv)){
    800058ca:	02000a13          	li	s4,32
    800058ce:	00048a9b          	sext.w	s5,s1
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    800058d2:	00349513          	slli	a0,s1,0x3
    800058d6:	e3040593          	addi	a1,s0,-464
    800058da:	e3843783          	ld	a5,-456(s0)
    800058de:	953e                	add	a0,a0,a5
    800058e0:	ffffd097          	auipc	ra,0xffffd
    800058e4:	fb6080e7          	jalr	-74(ra) # 80002896 <fetchaddr>
    800058e8:	02054a63          	bltz	a0,8000591c <sys_exec+0xa6>
      goto bad;
    }
    if(uarg == 0){
    800058ec:	e3043783          	ld	a5,-464(s0)
    800058f0:	c7a1                	beqz	a5,80005938 <sys_exec+0xc2>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    800058f2:	ffffb097          	auipc	ra,0xffffb
    800058f6:	06e080e7          	jalr	110(ra) # 80000960 <kalloc>
    800058fa:	85aa                	mv	a1,a0
    800058fc:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80005900:	c92d                	beqz	a0,80005972 <sys_exec+0xfc>
      panic("sys_exec kalloc");
    if(fetchstr(uarg, argv[i], PGSIZE) < 0){
    80005902:	6605                	lui	a2,0x1
    80005904:	e3043503          	ld	a0,-464(s0)
    80005908:	ffffd097          	auipc	ra,0xffffd
    8000590c:	fe0080e7          	jalr	-32(ra) # 800028e8 <fetchstr>
    80005910:	00054663          	bltz	a0,8000591c <sys_exec+0xa6>
    if(i >= NELEM(argv)){
    80005914:	0485                	addi	s1,s1,1
    80005916:	09a1                	addi	s3,s3,8
    80005918:	fb449be3          	bne	s1,s4,800058ce <sys_exec+0x58>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    8000591c:	10090493          	addi	s1,s2,256
    80005920:	00093503          	ld	a0,0(s2)
    80005924:	cd39                	beqz	a0,80005982 <sys_exec+0x10c>
    kfree(argv[i]);
    80005926:	ffffb097          	auipc	ra,0xffffb
    8000592a:	f3e080e7          	jalr	-194(ra) # 80000864 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    8000592e:	0921                	addi	s2,s2,8
    80005930:	fe9918e3          	bne	s2,s1,80005920 <sys_exec+0xaa>
  return -1;
    80005934:	557d                	li	a0,-1
    80005936:	a889                	j	80005988 <sys_exec+0x112>
      argv[i] = 0;
    80005938:	0a8e                	slli	s5,s5,0x3
    8000593a:	fc040793          	addi	a5,s0,-64
    8000593e:	9abe                	add	s5,s5,a5
    80005940:	e80ab023          	sd	zero,-384(s5)
  int ret = exec(path, argv);
    80005944:	e4040593          	addi	a1,s0,-448
    80005948:	f4040513          	addi	a0,s0,-192
    8000594c:	fffff097          	auipc	ra,0xfffff
    80005950:	10c080e7          	jalr	268(ra) # 80004a58 <exec>
    80005954:	84aa                	mv	s1,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005956:	10090993          	addi	s3,s2,256
    8000595a:	00093503          	ld	a0,0(s2)
    8000595e:	c901                	beqz	a0,8000596e <sys_exec+0xf8>
    kfree(argv[i]);
    80005960:	ffffb097          	auipc	ra,0xffffb
    80005964:	f04080e7          	jalr	-252(ra) # 80000864 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005968:	0921                	addi	s2,s2,8
    8000596a:	ff3918e3          	bne	s2,s3,8000595a <sys_exec+0xe4>
  return ret;
    8000596e:	8526                	mv	a0,s1
    80005970:	a821                	j	80005988 <sys_exec+0x112>
      panic("sys_exec kalloc");
    80005972:	00002517          	auipc	a0,0x2
    80005976:	e3e50513          	addi	a0,a0,-450 # 800077b0 <userret+0x720>
    8000597a:	ffffb097          	auipc	ra,0xffffb
    8000597e:	bd4080e7          	jalr	-1068(ra) # 8000054e <panic>
  return -1;
    80005982:	557d                	li	a0,-1
    80005984:	a011                	j	80005988 <sys_exec+0x112>
    return -1;
    80005986:	557d                	li	a0,-1
}
    80005988:	60be                	ld	ra,456(sp)
    8000598a:	641e                	ld	s0,448(sp)
    8000598c:	74fa                	ld	s1,440(sp)
    8000598e:	795a                	ld	s2,432(sp)
    80005990:	79ba                	ld	s3,424(sp)
    80005992:	7a1a                	ld	s4,416(sp)
    80005994:	6afa                	ld	s5,408(sp)
    80005996:	6179                	addi	sp,sp,464
    80005998:	8082                	ret
    return -1;
    8000599a:	557d                	li	a0,-1
    8000599c:	b7f5                	j	80005988 <sys_exec+0x112>

000000008000599e <sys_pipe>:

uint64
sys_pipe(void)
{
    8000599e:	7139                	addi	sp,sp,-64
    800059a0:	fc06                	sd	ra,56(sp)
    800059a2:	f822                	sd	s0,48(sp)
    800059a4:	f426                	sd	s1,40(sp)
    800059a6:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    800059a8:	ffffc097          	auipc	ra,0xffffc
    800059ac:	e9c080e7          	jalr	-356(ra) # 80001844 <myproc>
    800059b0:	84aa                	mv	s1,a0

  if(argaddr(0, &fdarray) < 0)
    800059b2:	fd840593          	addi	a1,s0,-40
    800059b6:	4501                	li	a0,0
    800059b8:	ffffd097          	auipc	ra,0xffffd
    800059bc:	f9a080e7          	jalr	-102(ra) # 80002952 <argaddr>
    return -1;
    800059c0:	57fd                	li	a5,-1
  if(argaddr(0, &fdarray) < 0)
    800059c2:	0e054063          	bltz	a0,80005aa2 <sys_pipe+0x104>
  if(pipealloc(&rf, &wf) < 0)
    800059c6:	fc840593          	addi	a1,s0,-56
    800059ca:	fd040513          	addi	a0,s0,-48
    800059ce:	fffff097          	auipc	ra,0xfffff
    800059d2:	d3a080e7          	jalr	-710(ra) # 80004708 <pipealloc>
    return -1;
    800059d6:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    800059d8:	0c054563          	bltz	a0,80005aa2 <sys_pipe+0x104>
  fd0 = -1;
    800059dc:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    800059e0:	fd043503          	ld	a0,-48(s0)
    800059e4:	fffff097          	auipc	ra,0xfffff
    800059e8:	43e080e7          	jalr	1086(ra) # 80004e22 <fdalloc>
    800059ec:	fca42223          	sw	a0,-60(s0)
    800059f0:	08054c63          	bltz	a0,80005a88 <sys_pipe+0xea>
    800059f4:	fc843503          	ld	a0,-56(s0)
    800059f8:	fffff097          	auipc	ra,0xfffff
    800059fc:	42a080e7          	jalr	1066(ra) # 80004e22 <fdalloc>
    80005a00:	fca42023          	sw	a0,-64(s0)
    80005a04:	06054863          	bltz	a0,80005a74 <sys_pipe+0xd6>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005a08:	4691                	li	a3,4
    80005a0a:	fc440613          	addi	a2,s0,-60
    80005a0e:	fd843583          	ld	a1,-40(s0)
    80005a12:	68a8                	ld	a0,80(s1)
    80005a14:	ffffc097          	auipc	ra,0xffffc
    80005a18:	b24080e7          	jalr	-1244(ra) # 80001538 <copyout>
    80005a1c:	02054063          	bltz	a0,80005a3c <sys_pipe+0x9e>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80005a20:	4691                	li	a3,4
    80005a22:	fc040613          	addi	a2,s0,-64
    80005a26:	fd843583          	ld	a1,-40(s0)
    80005a2a:	0591                	addi	a1,a1,4
    80005a2c:	68a8                	ld	a0,80(s1)
    80005a2e:	ffffc097          	auipc	ra,0xffffc
    80005a32:	b0a080e7          	jalr	-1270(ra) # 80001538 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80005a36:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005a38:	06055563          	bgez	a0,80005aa2 <sys_pipe+0x104>
    p->ofile[fd0] = 0;
    80005a3c:	fc442783          	lw	a5,-60(s0)
    80005a40:	07e9                	addi	a5,a5,26
    80005a42:	078e                	slli	a5,a5,0x3
    80005a44:	97a6                	add	a5,a5,s1
    80005a46:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80005a4a:	fc042503          	lw	a0,-64(s0)
    80005a4e:	0569                	addi	a0,a0,26
    80005a50:	050e                	slli	a0,a0,0x3
    80005a52:	9526                	add	a0,a0,s1
    80005a54:	00053023          	sd	zero,0(a0)
    fileclose(rf);
    80005a58:	fd043503          	ld	a0,-48(s0)
    80005a5c:	fffff097          	auipc	ra,0xfffff
    80005a60:	956080e7          	jalr	-1706(ra) # 800043b2 <fileclose>
    fileclose(wf);
    80005a64:	fc843503          	ld	a0,-56(s0)
    80005a68:	fffff097          	auipc	ra,0xfffff
    80005a6c:	94a080e7          	jalr	-1718(ra) # 800043b2 <fileclose>
    return -1;
    80005a70:	57fd                	li	a5,-1
    80005a72:	a805                	j	80005aa2 <sys_pipe+0x104>
    if(fd0 >= 0)
    80005a74:	fc442783          	lw	a5,-60(s0)
    80005a78:	0007c863          	bltz	a5,80005a88 <sys_pipe+0xea>
      p->ofile[fd0] = 0;
    80005a7c:	01a78513          	addi	a0,a5,26
    80005a80:	050e                	slli	a0,a0,0x3
    80005a82:	9526                	add	a0,a0,s1
    80005a84:	00053023          	sd	zero,0(a0)
    fileclose(rf);
    80005a88:	fd043503          	ld	a0,-48(s0)
    80005a8c:	fffff097          	auipc	ra,0xfffff
    80005a90:	926080e7          	jalr	-1754(ra) # 800043b2 <fileclose>
    fileclose(wf);
    80005a94:	fc843503          	ld	a0,-56(s0)
    80005a98:	fffff097          	auipc	ra,0xfffff
    80005a9c:	91a080e7          	jalr	-1766(ra) # 800043b2 <fileclose>
    return -1;
    80005aa0:	57fd                	li	a5,-1
}
    80005aa2:	853e                	mv	a0,a5
    80005aa4:	70e2                	ld	ra,56(sp)
    80005aa6:	7442                	ld	s0,48(sp)
    80005aa8:	74a2                	ld	s1,40(sp)
    80005aaa:	6121                	addi	sp,sp,64
    80005aac:	8082                	ret
	...

0000000080005ab0 <kernelvec>:
    80005ab0:	7111                	addi	sp,sp,-256
    80005ab2:	e006                	sd	ra,0(sp)
    80005ab4:	e40a                	sd	sp,8(sp)
    80005ab6:	e80e                	sd	gp,16(sp)
    80005ab8:	ec12                	sd	tp,24(sp)
    80005aba:	f016                	sd	t0,32(sp)
    80005abc:	f41a                	sd	t1,40(sp)
    80005abe:	f81e                	sd	t2,48(sp)
    80005ac0:	fc22                	sd	s0,56(sp)
    80005ac2:	e0a6                	sd	s1,64(sp)
    80005ac4:	e4aa                	sd	a0,72(sp)
    80005ac6:	e8ae                	sd	a1,80(sp)
    80005ac8:	ecb2                	sd	a2,88(sp)
    80005aca:	f0b6                	sd	a3,96(sp)
    80005acc:	f4ba                	sd	a4,104(sp)
    80005ace:	f8be                	sd	a5,112(sp)
    80005ad0:	fcc2                	sd	a6,120(sp)
    80005ad2:	e146                	sd	a7,128(sp)
    80005ad4:	e54a                	sd	s2,136(sp)
    80005ad6:	e94e                	sd	s3,144(sp)
    80005ad8:	ed52                	sd	s4,152(sp)
    80005ada:	f156                	sd	s5,160(sp)
    80005adc:	f55a                	sd	s6,168(sp)
    80005ade:	f95e                	sd	s7,176(sp)
    80005ae0:	fd62                	sd	s8,184(sp)
    80005ae2:	e1e6                	sd	s9,192(sp)
    80005ae4:	e5ea                	sd	s10,200(sp)
    80005ae6:	e9ee                	sd	s11,208(sp)
    80005ae8:	edf2                	sd	t3,216(sp)
    80005aea:	f1f6                	sd	t4,224(sp)
    80005aec:	f5fa                	sd	t5,232(sp)
    80005aee:	f9fe                	sd	t6,240(sp)
    80005af0:	c73fc0ef          	jal	ra,80002762 <kerneltrap>
    80005af4:	6082                	ld	ra,0(sp)
    80005af6:	6122                	ld	sp,8(sp)
    80005af8:	61c2                	ld	gp,16(sp)
    80005afa:	7282                	ld	t0,32(sp)
    80005afc:	7322                	ld	t1,40(sp)
    80005afe:	73c2                	ld	t2,48(sp)
    80005b00:	7462                	ld	s0,56(sp)
    80005b02:	6486                	ld	s1,64(sp)
    80005b04:	6526                	ld	a0,72(sp)
    80005b06:	65c6                	ld	a1,80(sp)
    80005b08:	6666                	ld	a2,88(sp)
    80005b0a:	7686                	ld	a3,96(sp)
    80005b0c:	7726                	ld	a4,104(sp)
    80005b0e:	77c6                	ld	a5,112(sp)
    80005b10:	7866                	ld	a6,120(sp)
    80005b12:	688a                	ld	a7,128(sp)
    80005b14:	692a                	ld	s2,136(sp)
    80005b16:	69ca                	ld	s3,144(sp)
    80005b18:	6a6a                	ld	s4,152(sp)
    80005b1a:	7a8a                	ld	s5,160(sp)
    80005b1c:	7b2a                	ld	s6,168(sp)
    80005b1e:	7bca                	ld	s7,176(sp)
    80005b20:	7c6a                	ld	s8,184(sp)
    80005b22:	6c8e                	ld	s9,192(sp)
    80005b24:	6d2e                	ld	s10,200(sp)
    80005b26:	6dce                	ld	s11,208(sp)
    80005b28:	6e6e                	ld	t3,216(sp)
    80005b2a:	7e8e                	ld	t4,224(sp)
    80005b2c:	7f2e                	ld	t5,232(sp)
    80005b2e:	7fce                	ld	t6,240(sp)
    80005b30:	6111                	addi	sp,sp,256
    80005b32:	10200073          	sret
    80005b36:	00000013          	nop
    80005b3a:	00000013          	nop
    80005b3e:	0001                	nop

0000000080005b40 <timervec>:
    80005b40:	34051573          	csrrw	a0,mscratch,a0
    80005b44:	e10c                	sd	a1,0(a0)
    80005b46:	e510                	sd	a2,8(a0)
    80005b48:	e914                	sd	a3,16(a0)
    80005b4a:	710c                	ld	a1,32(a0)
    80005b4c:	7510                	ld	a2,40(a0)
    80005b4e:	6194                	ld	a3,0(a1)
    80005b50:	96b2                	add	a3,a3,a2
    80005b52:	e194                	sd	a3,0(a1)
    80005b54:	4589                	li	a1,2
    80005b56:	14459073          	csrw	sip,a1
    80005b5a:	6914                	ld	a3,16(a0)
    80005b5c:	6510                	ld	a2,8(a0)
    80005b5e:	610c                	ld	a1,0(a0)
    80005b60:	34051573          	csrrw	a0,mscratch,a0
    80005b64:	30200073          	mret
	...

0000000080005b6a <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    80005b6a:	1141                	addi	sp,sp,-16
    80005b6c:	e422                	sd	s0,8(sp)
    80005b6e:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80005b70:	0c0007b7          	lui	a5,0xc000
    80005b74:	4705                	li	a4,1
    80005b76:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80005b78:	c3d8                	sw	a4,4(a5)
}
    80005b7a:	6422                	ld	s0,8(sp)
    80005b7c:	0141                	addi	sp,sp,16
    80005b7e:	8082                	ret

0000000080005b80 <plicinithart>:

void
plicinithart(void)
{
    80005b80:	1141                	addi	sp,sp,-16
    80005b82:	e406                	sd	ra,8(sp)
    80005b84:	e022                	sd	s0,0(sp)
    80005b86:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005b88:	ffffc097          	auipc	ra,0xffffc
    80005b8c:	c90080e7          	jalr	-880(ra) # 80001818 <cpuid>
  
  // set uart's enable bit for this hart's S-mode. 
  *(uint32*)PLIC_SENABLE(hart)= (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80005b90:	0085171b          	slliw	a4,a0,0x8
    80005b94:	0c0027b7          	lui	a5,0xc002
    80005b98:	97ba                	add	a5,a5,a4
    80005b9a:	40200713          	li	a4,1026
    80005b9e:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80005ba2:	00d5151b          	slliw	a0,a0,0xd
    80005ba6:	0c2017b7          	lui	a5,0xc201
    80005baa:	953e                	add	a0,a0,a5
    80005bac:	00052023          	sw	zero,0(a0)
}
    80005bb0:	60a2                	ld	ra,8(sp)
    80005bb2:	6402                	ld	s0,0(sp)
    80005bb4:	0141                	addi	sp,sp,16
    80005bb6:	8082                	ret

0000000080005bb8 <plic_pending>:

// return a bitmap of which IRQs are waiting
// to be served.
uint64
plic_pending(void)
{
    80005bb8:	1141                	addi	sp,sp,-16
    80005bba:	e422                	sd	s0,8(sp)
    80005bbc:	0800                	addi	s0,sp,16
  //mask = *(uint32*)(PLIC + 0x1000);
  //mask |= (uint64)*(uint32*)(PLIC + 0x1004) << 32;
  mask = *(uint64*)PLIC_PENDING;

  return mask;
}
    80005bbe:	0c0017b7          	lui	a5,0xc001
    80005bc2:	6388                	ld	a0,0(a5)
    80005bc4:	6422                	ld	s0,8(sp)
    80005bc6:	0141                	addi	sp,sp,16
    80005bc8:	8082                	ret

0000000080005bca <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80005bca:	1141                	addi	sp,sp,-16
    80005bcc:	e406                	sd	ra,8(sp)
    80005bce:	e022                	sd	s0,0(sp)
    80005bd0:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005bd2:	ffffc097          	auipc	ra,0xffffc
    80005bd6:	c46080e7          	jalr	-954(ra) # 80001818 <cpuid>
  //int irq = *(uint32*)(PLIC + 0x201004);
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80005bda:	00d5179b          	slliw	a5,a0,0xd
    80005bde:	0c201537          	lui	a0,0xc201
    80005be2:	953e                	add	a0,a0,a5
  return irq;
}
    80005be4:	4148                	lw	a0,4(a0)
    80005be6:	60a2                	ld	ra,8(sp)
    80005be8:	6402                	ld	s0,0(sp)
    80005bea:	0141                	addi	sp,sp,16
    80005bec:	8082                	ret

0000000080005bee <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    80005bee:	1101                	addi	sp,sp,-32
    80005bf0:	ec06                	sd	ra,24(sp)
    80005bf2:	e822                	sd	s0,16(sp)
    80005bf4:	e426                	sd	s1,8(sp)
    80005bf6:	1000                	addi	s0,sp,32
    80005bf8:	84aa                	mv	s1,a0
  int hart = cpuid();
    80005bfa:	ffffc097          	auipc	ra,0xffffc
    80005bfe:	c1e080e7          	jalr	-994(ra) # 80001818 <cpuid>
  //*(uint32*)(PLIC + 0x201004) = irq;
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80005c02:	00d5151b          	slliw	a0,a0,0xd
    80005c06:	0c2017b7          	lui	a5,0xc201
    80005c0a:	97aa                	add	a5,a5,a0
    80005c0c:	c3c4                	sw	s1,4(a5)
}
    80005c0e:	60e2                	ld	ra,24(sp)
    80005c10:	6442                	ld	s0,16(sp)
    80005c12:	64a2                	ld	s1,8(sp)
    80005c14:	6105                	addi	sp,sp,32
    80005c16:	8082                	ret

0000000080005c18 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80005c18:	1141                	addi	sp,sp,-16
    80005c1a:	e406                	sd	ra,8(sp)
    80005c1c:	e022                	sd	s0,0(sp)
    80005c1e:	0800                	addi	s0,sp,16
  if(i >= NUM)
    80005c20:	479d                	li	a5,7
    80005c22:	04a7cc63          	blt	a5,a0,80005c7a <free_desc+0x62>
    panic("virtio_disk_intr 1");
  if(disk.free[i])
    80005c26:	0001d797          	auipc	a5,0x1d
    80005c2a:	3da78793          	addi	a5,a5,986 # 80023000 <disk>
    80005c2e:	00a78733          	add	a4,a5,a0
    80005c32:	6789                	lui	a5,0x2
    80005c34:	97ba                	add	a5,a5,a4
    80005c36:	0187c783          	lbu	a5,24(a5) # 2018 <_entry-0x7fffdfe8>
    80005c3a:	eba1                	bnez	a5,80005c8a <free_desc+0x72>
    panic("virtio_disk_intr 2");
  disk.desc[i].addr = 0;
    80005c3c:	00451713          	slli	a4,a0,0x4
    80005c40:	0001f797          	auipc	a5,0x1f
    80005c44:	3c07b783          	ld	a5,960(a5) # 80025000 <disk+0x2000>
    80005c48:	97ba                	add	a5,a5,a4
    80005c4a:	0007b023          	sd	zero,0(a5)
  disk.free[i] = 1;
    80005c4e:	0001d797          	auipc	a5,0x1d
    80005c52:	3b278793          	addi	a5,a5,946 # 80023000 <disk>
    80005c56:	97aa                	add	a5,a5,a0
    80005c58:	6509                	lui	a0,0x2
    80005c5a:	953e                	add	a0,a0,a5
    80005c5c:	4785                	li	a5,1
    80005c5e:	00f50c23          	sb	a5,24(a0) # 2018 <_entry-0x7fffdfe8>
  wakeup(&disk.free[0]);
    80005c62:	0001f517          	auipc	a0,0x1f
    80005c66:	3b650513          	addi	a0,a0,950 # 80025018 <disk+0x2018>
    80005c6a:	ffffc097          	auipc	ra,0xffffc
    80005c6e:	506080e7          	jalr	1286(ra) # 80002170 <wakeup>
}
    80005c72:	60a2                	ld	ra,8(sp)
    80005c74:	6402                	ld	s0,0(sp)
    80005c76:	0141                	addi	sp,sp,16
    80005c78:	8082                	ret
    panic("virtio_disk_intr 1");
    80005c7a:	00002517          	auipc	a0,0x2
    80005c7e:	b4650513          	addi	a0,a0,-1210 # 800077c0 <userret+0x730>
    80005c82:	ffffb097          	auipc	ra,0xffffb
    80005c86:	8cc080e7          	jalr	-1844(ra) # 8000054e <panic>
    panic("virtio_disk_intr 2");
    80005c8a:	00002517          	auipc	a0,0x2
    80005c8e:	b4e50513          	addi	a0,a0,-1202 # 800077d8 <userret+0x748>
    80005c92:	ffffb097          	auipc	ra,0xffffb
    80005c96:	8bc080e7          	jalr	-1860(ra) # 8000054e <panic>

0000000080005c9a <virtio_disk_init>:
{
    80005c9a:	1101                	addi	sp,sp,-32
    80005c9c:	ec06                	sd	ra,24(sp)
    80005c9e:	e822                	sd	s0,16(sp)
    80005ca0:	e426                	sd	s1,8(sp)
    80005ca2:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80005ca4:	00002597          	auipc	a1,0x2
    80005ca8:	b4c58593          	addi	a1,a1,-1204 # 800077f0 <userret+0x760>
    80005cac:	0001f517          	auipc	a0,0x1f
    80005cb0:	3fc50513          	addi	a0,a0,1020 # 800250a8 <disk+0x20a8>
    80005cb4:	ffffb097          	auipc	ra,0xffffb
    80005cb8:	d0c080e7          	jalr	-756(ra) # 800009c0 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005cbc:	100017b7          	lui	a5,0x10001
    80005cc0:	4398                	lw	a4,0(a5)
    80005cc2:	2701                	sext.w	a4,a4
    80005cc4:	747277b7          	lui	a5,0x74727
    80005cc8:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80005ccc:	0ef71163          	bne	a4,a5,80005dae <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_VERSION) != 1 ||
    80005cd0:	100017b7          	lui	a5,0x10001
    80005cd4:	43dc                	lw	a5,4(a5)
    80005cd6:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005cd8:	4705                	li	a4,1
    80005cda:	0ce79a63          	bne	a5,a4,80005dae <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005cde:	100017b7          	lui	a5,0x10001
    80005ce2:	479c                	lw	a5,8(a5)
    80005ce4:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 1 ||
    80005ce6:	4709                	li	a4,2
    80005ce8:	0ce79363          	bne	a5,a4,80005dae <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    80005cec:	100017b7          	lui	a5,0x10001
    80005cf0:	47d8                	lw	a4,12(a5)
    80005cf2:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005cf4:	554d47b7          	lui	a5,0x554d4
    80005cf8:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    80005cfc:	0af71963          	bne	a4,a5,80005dae <virtio_disk_init+0x114>
  *R(VIRTIO_MMIO_STATUS) = status;
    80005d00:	100017b7          	lui	a5,0x10001
    80005d04:	4705                	li	a4,1
    80005d06:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005d08:	470d                	li	a4,3
    80005d0a:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    80005d0c:	4b94                	lw	a3,16(a5)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    80005d0e:	c7ffe737          	lui	a4,0xc7ffe
    80005d12:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fd8743>
    80005d16:	8f75                	and	a4,a4,a3
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80005d18:	2701                	sext.w	a4,a4
    80005d1a:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005d1c:	472d                	li	a4,11
    80005d1e:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005d20:	473d                	li	a4,15
    80005d22:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_GUEST_PAGE_SIZE) = PGSIZE;
    80005d24:	6705                	lui	a4,0x1
    80005d26:	d798                	sw	a4,40(a5)
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80005d28:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80005d2c:	5bdc                	lw	a5,52(a5)
    80005d2e:	2781                	sext.w	a5,a5
  if(max == 0)
    80005d30:	c7d9                	beqz	a5,80005dbe <virtio_disk_init+0x124>
  if(max < NUM)
    80005d32:	471d                	li	a4,7
    80005d34:	08f77d63          	bgeu	a4,a5,80005dce <virtio_disk_init+0x134>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80005d38:	100014b7          	lui	s1,0x10001
    80005d3c:	47a1                	li	a5,8
    80005d3e:	dc9c                	sw	a5,56(s1)
  memset(disk.pages, 0, sizeof(disk.pages));
    80005d40:	6609                	lui	a2,0x2
    80005d42:	4581                	li	a1,0
    80005d44:	0001d517          	auipc	a0,0x1d
    80005d48:	2bc50513          	addi	a0,a0,700 # 80023000 <disk>
    80005d4c:	ffffb097          	auipc	ra,0xffffb
    80005d50:	e22080e7          	jalr	-478(ra) # 80000b6e <memset>
  *R(VIRTIO_MMIO_QUEUE_PFN) = ((uint64)disk.pages) >> PGSHIFT;
    80005d54:	0001d717          	auipc	a4,0x1d
    80005d58:	2ac70713          	addi	a4,a4,684 # 80023000 <disk>
    80005d5c:	00c75793          	srli	a5,a4,0xc
    80005d60:	2781                	sext.w	a5,a5
    80005d62:	c0bc                	sw	a5,64(s1)
  disk.desc = (struct VRingDesc *) disk.pages;
    80005d64:	0001f797          	auipc	a5,0x1f
    80005d68:	29c78793          	addi	a5,a5,668 # 80025000 <disk+0x2000>
    80005d6c:	e398                	sd	a4,0(a5)
  disk.avail = (uint16*)(((char*)disk.desc) + NUM*sizeof(struct VRingDesc));
    80005d6e:	0001d717          	auipc	a4,0x1d
    80005d72:	31270713          	addi	a4,a4,786 # 80023080 <disk+0x80>
    80005d76:	e798                	sd	a4,8(a5)
  disk.used = (struct UsedArea *) (disk.pages + PGSIZE);
    80005d78:	0001e717          	auipc	a4,0x1e
    80005d7c:	28870713          	addi	a4,a4,648 # 80024000 <disk+0x1000>
    80005d80:	eb98                	sd	a4,16(a5)
    disk.free[i] = 1;
    80005d82:	4705                	li	a4,1
    80005d84:	00e78c23          	sb	a4,24(a5)
    80005d88:	00e78ca3          	sb	a4,25(a5)
    80005d8c:	00e78d23          	sb	a4,26(a5)
    80005d90:	00e78da3          	sb	a4,27(a5)
    80005d94:	00e78e23          	sb	a4,28(a5)
    80005d98:	00e78ea3          	sb	a4,29(a5)
    80005d9c:	00e78f23          	sb	a4,30(a5)
    80005da0:	00e78fa3          	sb	a4,31(a5)
}
    80005da4:	60e2                	ld	ra,24(sp)
    80005da6:	6442                	ld	s0,16(sp)
    80005da8:	64a2                	ld	s1,8(sp)
    80005daa:	6105                	addi	sp,sp,32
    80005dac:	8082                	ret
    panic("could not find virtio disk");
    80005dae:	00002517          	auipc	a0,0x2
    80005db2:	a5250513          	addi	a0,a0,-1454 # 80007800 <userret+0x770>
    80005db6:	ffffa097          	auipc	ra,0xffffa
    80005dba:	798080e7          	jalr	1944(ra) # 8000054e <panic>
    panic("virtio disk has no queue 0");
    80005dbe:	00002517          	auipc	a0,0x2
    80005dc2:	a6250513          	addi	a0,a0,-1438 # 80007820 <userret+0x790>
    80005dc6:	ffffa097          	auipc	ra,0xffffa
    80005dca:	788080e7          	jalr	1928(ra) # 8000054e <panic>
    panic("virtio disk max queue too short");
    80005dce:	00002517          	auipc	a0,0x2
    80005dd2:	a7250513          	addi	a0,a0,-1422 # 80007840 <userret+0x7b0>
    80005dd6:	ffffa097          	auipc	ra,0xffffa
    80005dda:	778080e7          	jalr	1912(ra) # 8000054e <panic>

0000000080005dde <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80005dde:	7119                	addi	sp,sp,-128
    80005de0:	fc86                	sd	ra,120(sp)
    80005de2:	f8a2                	sd	s0,112(sp)
    80005de4:	f4a6                	sd	s1,104(sp)
    80005de6:	f0ca                	sd	s2,96(sp)
    80005de8:	ecce                	sd	s3,88(sp)
    80005dea:	e8d2                	sd	s4,80(sp)
    80005dec:	e4d6                	sd	s5,72(sp)
    80005dee:	e0da                	sd	s6,64(sp)
    80005df0:	fc5e                	sd	s7,56(sp)
    80005df2:	f862                	sd	s8,48(sp)
    80005df4:	f466                	sd	s9,40(sp)
    80005df6:	f06a                	sd	s10,32(sp)
    80005df8:	0100                	addi	s0,sp,128
    80005dfa:	892a                	mv	s2,a0
    80005dfc:	8d2e                	mv	s10,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80005dfe:	00c52c83          	lw	s9,12(a0)
    80005e02:	001c9c9b          	slliw	s9,s9,0x1
    80005e06:	1c82                	slli	s9,s9,0x20
    80005e08:	020cdc93          	srli	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    80005e0c:	0001f517          	auipc	a0,0x1f
    80005e10:	29c50513          	addi	a0,a0,668 # 800250a8 <disk+0x20a8>
    80005e14:	ffffb097          	auipc	ra,0xffffb
    80005e18:	cbe080e7          	jalr	-834(ra) # 80000ad2 <acquire>
  for(int i = 0; i < 3; i++){
    80005e1c:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    80005e1e:	4c21                	li	s8,8
      disk.free[i] = 0;
    80005e20:	0001db97          	auipc	s7,0x1d
    80005e24:	1e0b8b93          	addi	s7,s7,480 # 80023000 <disk>
    80005e28:	6b09                	lui	s6,0x2
  for(int i = 0; i < 3; i++){
    80005e2a:	4a8d                	li	s5,3
  for(int i = 0; i < NUM; i++){
    80005e2c:	8a4e                	mv	s4,s3
    80005e2e:	a051                	j	80005eb2 <virtio_disk_rw+0xd4>
      disk.free[i] = 0;
    80005e30:	00fb86b3          	add	a3,s7,a5
    80005e34:	96da                	add	a3,a3,s6
    80005e36:	00068c23          	sb	zero,24(a3)
    idx[i] = alloc_desc();
    80005e3a:	c21c                	sw	a5,0(a2)
    if(idx[i] < 0){
    80005e3c:	0207c563          	bltz	a5,80005e66 <virtio_disk_rw+0x88>
  for(int i = 0; i < 3; i++){
    80005e40:	2485                	addiw	s1,s1,1
    80005e42:	0711                	addi	a4,a4,4
    80005e44:	23548d63          	beq	s1,s5,8000607e <virtio_disk_rw+0x2a0>
    idx[i] = alloc_desc();
    80005e48:	863a                	mv	a2,a4
  for(int i = 0; i < NUM; i++){
    80005e4a:	0001f697          	auipc	a3,0x1f
    80005e4e:	1ce68693          	addi	a3,a3,462 # 80025018 <disk+0x2018>
    80005e52:	87d2                	mv	a5,s4
    if(disk.free[i]){
    80005e54:	0006c583          	lbu	a1,0(a3)
    80005e58:	fde1                	bnez	a1,80005e30 <virtio_disk_rw+0x52>
  for(int i = 0; i < NUM; i++){
    80005e5a:	2785                	addiw	a5,a5,1
    80005e5c:	0685                	addi	a3,a3,1
    80005e5e:	ff879be3          	bne	a5,s8,80005e54 <virtio_disk_rw+0x76>
    idx[i] = alloc_desc();
    80005e62:	57fd                	li	a5,-1
    80005e64:	c21c                	sw	a5,0(a2)
      for(int j = 0; j < i; j++)
    80005e66:	02905a63          	blez	s1,80005e9a <virtio_disk_rw+0xbc>
        free_desc(idx[j]);
    80005e6a:	f9042503          	lw	a0,-112(s0)
    80005e6e:	00000097          	auipc	ra,0x0
    80005e72:	daa080e7          	jalr	-598(ra) # 80005c18 <free_desc>
      for(int j = 0; j < i; j++)
    80005e76:	4785                	li	a5,1
    80005e78:	0297d163          	bge	a5,s1,80005e9a <virtio_disk_rw+0xbc>
        free_desc(idx[j]);
    80005e7c:	f9442503          	lw	a0,-108(s0)
    80005e80:	00000097          	auipc	ra,0x0
    80005e84:	d98080e7          	jalr	-616(ra) # 80005c18 <free_desc>
      for(int j = 0; j < i; j++)
    80005e88:	4789                	li	a5,2
    80005e8a:	0097d863          	bge	a5,s1,80005e9a <virtio_disk_rw+0xbc>
        free_desc(idx[j]);
    80005e8e:	f9842503          	lw	a0,-104(s0)
    80005e92:	00000097          	auipc	ra,0x0
    80005e96:	d86080e7          	jalr	-634(ra) # 80005c18 <free_desc>
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80005e9a:	0001f597          	auipc	a1,0x1f
    80005e9e:	20e58593          	addi	a1,a1,526 # 800250a8 <disk+0x20a8>
    80005ea2:	0001f517          	auipc	a0,0x1f
    80005ea6:	17650513          	addi	a0,a0,374 # 80025018 <disk+0x2018>
    80005eaa:	ffffc097          	auipc	ra,0xffffc
    80005eae:	140080e7          	jalr	320(ra) # 80001fea <sleep>
  for(int i = 0; i < 3; i++){
    80005eb2:	f9040713          	addi	a4,s0,-112
    80005eb6:	84ce                	mv	s1,s3
    80005eb8:	bf41                	j	80005e48 <virtio_disk_rw+0x6a>
    uint32 reserved;
    uint64 sector;
  } buf0;

  if(write)
    buf0.type = VIRTIO_BLK_T_OUT; // write the disk
    80005eba:	4785                	li	a5,1
    80005ebc:	f8f42023          	sw	a5,-128(s0)
  else
    buf0.type = VIRTIO_BLK_T_IN; // read the disk
  buf0.reserved = 0;
    80005ec0:	f8042223          	sw	zero,-124(s0)
  buf0.sector = sector;
    80005ec4:	f9943423          	sd	s9,-120(s0)

  // buf0 is on a kernel stack, which is not direct mapped,
  // thus the call to kvmpa().
  disk.desc[idx[0]].addr = (uint64) kvmpa((uint64) &buf0);
    80005ec8:	f9042983          	lw	s3,-112(s0)
    80005ecc:	00499493          	slli	s1,s3,0x4
    80005ed0:	0001fa17          	auipc	s4,0x1f
    80005ed4:	130a0a13          	addi	s4,s4,304 # 80025000 <disk+0x2000>
    80005ed8:	000a3a83          	ld	s5,0(s4)
    80005edc:	9aa6                	add	s5,s5,s1
    80005ede:	f8040513          	addi	a0,s0,-128
    80005ee2:	ffffb097          	auipc	ra,0xffffb
    80005ee6:	0ca080e7          	jalr	202(ra) # 80000fac <kvmpa>
    80005eea:	00aab023          	sd	a0,0(s5)
  disk.desc[idx[0]].len = sizeof(buf0);
    80005eee:	000a3783          	ld	a5,0(s4)
    80005ef2:	97a6                	add	a5,a5,s1
    80005ef4:	4741                	li	a4,16
    80005ef6:	c798                	sw	a4,8(a5)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80005ef8:	000a3783          	ld	a5,0(s4)
    80005efc:	97a6                	add	a5,a5,s1
    80005efe:	4705                	li	a4,1
    80005f00:	00e79623          	sh	a4,12(a5)
  disk.desc[idx[0]].next = idx[1];
    80005f04:	f9442703          	lw	a4,-108(s0)
    80005f08:	000a3783          	ld	a5,0(s4)
    80005f0c:	97a6                	add	a5,a5,s1
    80005f0e:	00e79723          	sh	a4,14(a5)

  disk.desc[idx[1]].addr = (uint64) b->data;
    80005f12:	0712                	slli	a4,a4,0x4
    80005f14:	000a3783          	ld	a5,0(s4)
    80005f18:	97ba                	add	a5,a5,a4
    80005f1a:	06090693          	addi	a3,s2,96
    80005f1e:	e394                	sd	a3,0(a5)
  disk.desc[idx[1]].len = BSIZE;
    80005f20:	000a3783          	ld	a5,0(s4)
    80005f24:	97ba                	add	a5,a5,a4
    80005f26:	40000693          	li	a3,1024
    80005f2a:	c794                	sw	a3,8(a5)
  if(write)
    80005f2c:	100d0a63          	beqz	s10,80006040 <virtio_disk_rw+0x262>
    disk.desc[idx[1]].flags = 0; // device reads b->data
    80005f30:	0001f797          	auipc	a5,0x1f
    80005f34:	0d07b783          	ld	a5,208(a5) # 80025000 <disk+0x2000>
    80005f38:	97ba                	add	a5,a5,a4
    80005f3a:	00079623          	sh	zero,12(a5)
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    80005f3e:	0001d517          	auipc	a0,0x1d
    80005f42:	0c250513          	addi	a0,a0,194 # 80023000 <disk>
    80005f46:	0001f797          	auipc	a5,0x1f
    80005f4a:	0ba78793          	addi	a5,a5,186 # 80025000 <disk+0x2000>
    80005f4e:	6394                	ld	a3,0(a5)
    80005f50:	96ba                	add	a3,a3,a4
    80005f52:	00c6d603          	lhu	a2,12(a3)
    80005f56:	00166613          	ori	a2,a2,1
    80005f5a:	00c69623          	sh	a2,12(a3)
  disk.desc[idx[1]].next = idx[2];
    80005f5e:	f9842683          	lw	a3,-104(s0)
    80005f62:	6390                	ld	a2,0(a5)
    80005f64:	9732                	add	a4,a4,a2
    80005f66:	00d71723          	sh	a3,14(a4)

  disk.info[idx[0]].status = 0;
    80005f6a:	20098613          	addi	a2,s3,512
    80005f6e:	0612                	slli	a2,a2,0x4
    80005f70:	962a                	add	a2,a2,a0
    80005f72:	02060823          	sb	zero,48(a2) # 2030 <_entry-0x7fffdfd0>
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    80005f76:	00469713          	slli	a4,a3,0x4
    80005f7a:	6394                	ld	a3,0(a5)
    80005f7c:	96ba                	add	a3,a3,a4
    80005f7e:	6589                	lui	a1,0x2
    80005f80:	03058593          	addi	a1,a1,48 # 2030 <_entry-0x7fffdfd0>
    80005f84:	94ae                	add	s1,s1,a1
    80005f86:	94aa                	add	s1,s1,a0
    80005f88:	e284                	sd	s1,0(a3)
  disk.desc[idx[2]].len = 1;
    80005f8a:	6394                	ld	a3,0(a5)
    80005f8c:	96ba                	add	a3,a3,a4
    80005f8e:	4585                	li	a1,1
    80005f90:	c68c                	sw	a1,8(a3)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80005f92:	6394                	ld	a3,0(a5)
    80005f94:	96ba                	add	a3,a3,a4
    80005f96:	4509                	li	a0,2
    80005f98:	00a69623          	sh	a0,12(a3)
  disk.desc[idx[2]].next = 0;
    80005f9c:	6394                	ld	a3,0(a5)
    80005f9e:	9736                	add	a4,a4,a3
    80005fa0:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    80005fa4:	00b92223          	sw	a1,4(s2)
  disk.info[idx[0]].b = b;
    80005fa8:	03263423          	sd	s2,40(a2)

  // avail[0] is flags
  // avail[1] tells the device how far to look in avail[2...].
  // avail[2...] are desc[] indices the device should process.
  // we only tell device the first index in our chain of descriptors.
  disk.avail[2 + (disk.avail[1] % NUM)] = idx[0];
    80005fac:	6794                	ld	a3,8(a5)
    80005fae:	0026d703          	lhu	a4,2(a3)
    80005fb2:	8b1d                	andi	a4,a4,7
    80005fb4:	2709                	addiw	a4,a4,2
    80005fb6:	0706                	slli	a4,a4,0x1
    80005fb8:	9736                	add	a4,a4,a3
    80005fba:	01371023          	sh	s3,0(a4)
  __sync_synchronize();
    80005fbe:	0ff0000f          	fence
  disk.avail[1] = disk.avail[1] + 1;
    80005fc2:	6798                	ld	a4,8(a5)
    80005fc4:	00275783          	lhu	a5,2(a4)
    80005fc8:	2785                	addiw	a5,a5,1
    80005fca:	00f71123          	sh	a5,2(a4)

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80005fce:	100017b7          	lui	a5,0x10001
    80005fd2:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80005fd6:	00492703          	lw	a4,4(s2)
    80005fda:	4785                	li	a5,1
    80005fdc:	02f71163          	bne	a4,a5,80005ffe <virtio_disk_rw+0x220>
    sleep(b, &disk.vdisk_lock);
    80005fe0:	0001f997          	auipc	s3,0x1f
    80005fe4:	0c898993          	addi	s3,s3,200 # 800250a8 <disk+0x20a8>
  while(b->disk == 1) {
    80005fe8:	4485                	li	s1,1
    sleep(b, &disk.vdisk_lock);
    80005fea:	85ce                	mv	a1,s3
    80005fec:	854a                	mv	a0,s2
    80005fee:	ffffc097          	auipc	ra,0xffffc
    80005ff2:	ffc080e7          	jalr	-4(ra) # 80001fea <sleep>
  while(b->disk == 1) {
    80005ff6:	00492783          	lw	a5,4(s2)
    80005ffa:	fe9788e3          	beq	a5,s1,80005fea <virtio_disk_rw+0x20c>
  }

  disk.info[idx[0]].b = 0;
    80005ffe:	f9042483          	lw	s1,-112(s0)
    80006002:	20048793          	addi	a5,s1,512 # 10001200 <_entry-0x6fffee00>
    80006006:	00479713          	slli	a4,a5,0x4
    8000600a:	0001d797          	auipc	a5,0x1d
    8000600e:	ff678793          	addi	a5,a5,-10 # 80023000 <disk>
    80006012:	97ba                	add	a5,a5,a4
    80006014:	0207b423          	sd	zero,40(a5)
    if(disk.desc[i].flags & VRING_DESC_F_NEXT)
    80006018:	0001f917          	auipc	s2,0x1f
    8000601c:	fe890913          	addi	s2,s2,-24 # 80025000 <disk+0x2000>
    free_desc(i);
    80006020:	8526                	mv	a0,s1
    80006022:	00000097          	auipc	ra,0x0
    80006026:	bf6080e7          	jalr	-1034(ra) # 80005c18 <free_desc>
    if(disk.desc[i].flags & VRING_DESC_F_NEXT)
    8000602a:	0492                	slli	s1,s1,0x4
    8000602c:	00093783          	ld	a5,0(s2)
    80006030:	94be                	add	s1,s1,a5
    80006032:	00c4d783          	lhu	a5,12(s1)
    80006036:	8b85                	andi	a5,a5,1
    80006038:	cf89                	beqz	a5,80006052 <virtio_disk_rw+0x274>
      i = disk.desc[i].next;
    8000603a:	00e4d483          	lhu	s1,14(s1)
    free_desc(i);
    8000603e:	b7cd                	j	80006020 <virtio_disk_rw+0x242>
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
    80006040:	0001f797          	auipc	a5,0x1f
    80006044:	fc07b783          	ld	a5,-64(a5) # 80025000 <disk+0x2000>
    80006048:	97ba                	add	a5,a5,a4
    8000604a:	4689                	li	a3,2
    8000604c:	00d79623          	sh	a3,12(a5)
    80006050:	b5fd                	j	80005f3e <virtio_disk_rw+0x160>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    80006052:	0001f517          	auipc	a0,0x1f
    80006056:	05650513          	addi	a0,a0,86 # 800250a8 <disk+0x20a8>
    8000605a:	ffffb097          	auipc	ra,0xffffb
    8000605e:	acc080e7          	jalr	-1332(ra) # 80000b26 <release>
}
    80006062:	70e6                	ld	ra,120(sp)
    80006064:	7446                	ld	s0,112(sp)
    80006066:	74a6                	ld	s1,104(sp)
    80006068:	7906                	ld	s2,96(sp)
    8000606a:	69e6                	ld	s3,88(sp)
    8000606c:	6a46                	ld	s4,80(sp)
    8000606e:	6aa6                	ld	s5,72(sp)
    80006070:	6b06                	ld	s6,64(sp)
    80006072:	7be2                	ld	s7,56(sp)
    80006074:	7c42                	ld	s8,48(sp)
    80006076:	7ca2                	ld	s9,40(sp)
    80006078:	7d02                	ld	s10,32(sp)
    8000607a:	6109                	addi	sp,sp,128
    8000607c:	8082                	ret
  if(write)
    8000607e:	e20d1ee3          	bnez	s10,80005eba <virtio_disk_rw+0xdc>
    buf0.type = VIRTIO_BLK_T_IN; // read the disk
    80006082:	f8042023          	sw	zero,-128(s0)
    80006086:	bd2d                	j	80005ec0 <virtio_disk_rw+0xe2>

0000000080006088 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80006088:	1101                	addi	sp,sp,-32
    8000608a:	ec06                	sd	ra,24(sp)
    8000608c:	e822                	sd	s0,16(sp)
    8000608e:	e426                	sd	s1,8(sp)
    80006090:	e04a                	sd	s2,0(sp)
    80006092:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    80006094:	0001f517          	auipc	a0,0x1f
    80006098:	01450513          	addi	a0,a0,20 # 800250a8 <disk+0x20a8>
    8000609c:	ffffb097          	auipc	ra,0xffffb
    800060a0:	a36080e7          	jalr	-1482(ra) # 80000ad2 <acquire>

  while((disk.used_idx % NUM) != (disk.used->id % NUM)){
    800060a4:	0001f717          	auipc	a4,0x1f
    800060a8:	f5c70713          	addi	a4,a4,-164 # 80025000 <disk+0x2000>
    800060ac:	02075783          	lhu	a5,32(a4)
    800060b0:	6b18                	ld	a4,16(a4)
    800060b2:	00275683          	lhu	a3,2(a4)
    800060b6:	8ebd                	xor	a3,a3,a5
    800060b8:	8a9d                	andi	a3,a3,7
    800060ba:	cab9                	beqz	a3,80006110 <virtio_disk_intr+0x88>
    int id = disk.used->elems[disk.used_idx].id;

    if(disk.info[id].status != 0)
    800060bc:	0001d917          	auipc	s2,0x1d
    800060c0:	f4490913          	addi	s2,s2,-188 # 80023000 <disk>
      panic("virtio_disk_intr status");
    
    disk.info[id].b->disk = 0;   // disk is done with buf
    wakeup(disk.info[id].b);

    disk.used_idx = (disk.used_idx + 1) % NUM;
    800060c4:	0001f497          	auipc	s1,0x1f
    800060c8:	f3c48493          	addi	s1,s1,-196 # 80025000 <disk+0x2000>
    int id = disk.used->elems[disk.used_idx].id;
    800060cc:	078e                	slli	a5,a5,0x3
    800060ce:	97ba                	add	a5,a5,a4
    800060d0:	43dc                	lw	a5,4(a5)
    if(disk.info[id].status != 0)
    800060d2:	20078713          	addi	a4,a5,512
    800060d6:	0712                	slli	a4,a4,0x4
    800060d8:	974a                	add	a4,a4,s2
    800060da:	03074703          	lbu	a4,48(a4)
    800060de:	e739                	bnez	a4,8000612c <virtio_disk_intr+0xa4>
    disk.info[id].b->disk = 0;   // disk is done with buf
    800060e0:	20078793          	addi	a5,a5,512
    800060e4:	0792                	slli	a5,a5,0x4
    800060e6:	97ca                	add	a5,a5,s2
    800060e8:	7798                	ld	a4,40(a5)
    800060ea:	00072223          	sw	zero,4(a4)
    wakeup(disk.info[id].b);
    800060ee:	7788                	ld	a0,40(a5)
    800060f0:	ffffc097          	auipc	ra,0xffffc
    800060f4:	080080e7          	jalr	128(ra) # 80002170 <wakeup>
    disk.used_idx = (disk.used_idx + 1) % NUM;
    800060f8:	0204d783          	lhu	a5,32(s1)
    800060fc:	2785                	addiw	a5,a5,1
    800060fe:	8b9d                	andi	a5,a5,7
    80006100:	02f49023          	sh	a5,32(s1)
  while((disk.used_idx % NUM) != (disk.used->id % NUM)){
    80006104:	6898                	ld	a4,16(s1)
    80006106:	00275683          	lhu	a3,2(a4)
    8000610a:	8a9d                	andi	a3,a3,7
    8000610c:	fcf690e3          	bne	a3,a5,800060cc <virtio_disk_intr+0x44>
  }

  release(&disk.vdisk_lock);
    80006110:	0001f517          	auipc	a0,0x1f
    80006114:	f9850513          	addi	a0,a0,-104 # 800250a8 <disk+0x20a8>
    80006118:	ffffb097          	auipc	ra,0xffffb
    8000611c:	a0e080e7          	jalr	-1522(ra) # 80000b26 <release>
}
    80006120:	60e2                	ld	ra,24(sp)
    80006122:	6442                	ld	s0,16(sp)
    80006124:	64a2                	ld	s1,8(sp)
    80006126:	6902                	ld	s2,0(sp)
    80006128:	6105                	addi	sp,sp,32
    8000612a:	8082                	ret
      panic("virtio_disk_intr status");
    8000612c:	00001517          	auipc	a0,0x1
    80006130:	73450513          	addi	a0,a0,1844 # 80007860 <userret+0x7d0>
    80006134:	ffffa097          	auipc	ra,0xffffa
    80006138:	41a080e7          	jalr	1050(ra) # 8000054e <panic>
	...

0000000080007000 <trampoline>:
    80007000:	14051573          	csrrw	a0,sscratch,a0
    80007004:	02153423          	sd	ra,40(a0)
    80007008:	02253823          	sd	sp,48(a0)
    8000700c:	02353c23          	sd	gp,56(a0)
    80007010:	04453023          	sd	tp,64(a0)
    80007014:	04553423          	sd	t0,72(a0)
    80007018:	04653823          	sd	t1,80(a0)
    8000701c:	04753c23          	sd	t2,88(a0)
    80007020:	f120                	sd	s0,96(a0)
    80007022:	f524                	sd	s1,104(a0)
    80007024:	fd2c                	sd	a1,120(a0)
    80007026:	e150                	sd	a2,128(a0)
    80007028:	e554                	sd	a3,136(a0)
    8000702a:	e958                	sd	a4,144(a0)
    8000702c:	ed5c                	sd	a5,152(a0)
    8000702e:	0b053023          	sd	a6,160(a0)
    80007032:	0b153423          	sd	a7,168(a0)
    80007036:	0b253823          	sd	s2,176(a0)
    8000703a:	0b353c23          	sd	s3,184(a0)
    8000703e:	0d453023          	sd	s4,192(a0)
    80007042:	0d553423          	sd	s5,200(a0)
    80007046:	0d653823          	sd	s6,208(a0)
    8000704a:	0d753c23          	sd	s7,216(a0)
    8000704e:	0f853023          	sd	s8,224(a0)
    80007052:	0f953423          	sd	s9,232(a0)
    80007056:	0fa53823          	sd	s10,240(a0)
    8000705a:	0fb53c23          	sd	s11,248(a0)
    8000705e:	11c53023          	sd	t3,256(a0)
    80007062:	11d53423          	sd	t4,264(a0)
    80007066:	11e53823          	sd	t5,272(a0)
    8000706a:	11f53c23          	sd	t6,280(a0)
    8000706e:	140022f3          	csrr	t0,sscratch
    80007072:	06553823          	sd	t0,112(a0)
    80007076:	00853103          	ld	sp,8(a0)
    8000707a:	02053203          	ld	tp,32(a0)
    8000707e:	01053283          	ld	t0,16(a0)
    80007082:	00053303          	ld	t1,0(a0)
    80007086:	18031073          	csrw	satp,t1
    8000708a:	12000073          	sfence.vma
    8000708e:	8282                	jr	t0

0000000080007090 <userret>:
    80007090:	18059073          	csrw	satp,a1
    80007094:	12000073          	sfence.vma
    80007098:	07053283          	ld	t0,112(a0)
    8000709c:	14029073          	csrw	sscratch,t0
    800070a0:	02853083          	ld	ra,40(a0)
    800070a4:	03053103          	ld	sp,48(a0)
    800070a8:	03853183          	ld	gp,56(a0)
    800070ac:	04053203          	ld	tp,64(a0)
    800070b0:	04853283          	ld	t0,72(a0)
    800070b4:	05053303          	ld	t1,80(a0)
    800070b8:	05853383          	ld	t2,88(a0)
    800070bc:	7120                	ld	s0,96(a0)
    800070be:	7524                	ld	s1,104(a0)
    800070c0:	7d2c                	ld	a1,120(a0)
    800070c2:	6150                	ld	a2,128(a0)
    800070c4:	6554                	ld	a3,136(a0)
    800070c6:	6958                	ld	a4,144(a0)
    800070c8:	6d5c                	ld	a5,152(a0)
    800070ca:	0a053803          	ld	a6,160(a0)
    800070ce:	0a853883          	ld	a7,168(a0)
    800070d2:	0b053903          	ld	s2,176(a0)
    800070d6:	0b853983          	ld	s3,184(a0)
    800070da:	0c053a03          	ld	s4,192(a0)
    800070de:	0c853a83          	ld	s5,200(a0)
    800070e2:	0d053b03          	ld	s6,208(a0)
    800070e6:	0d853b83          	ld	s7,216(a0)
    800070ea:	0e053c03          	ld	s8,224(a0)
    800070ee:	0e853c83          	ld	s9,232(a0)
    800070f2:	0f053d03          	ld	s10,240(a0)
    800070f6:	0f853d83          	ld	s11,248(a0)
    800070fa:	10053e03          	ld	t3,256(a0)
    800070fe:	10853e83          	ld	t4,264(a0)
    80007102:	11053f03          	ld	t5,272(a0)
    80007106:	11853f83          	ld	t6,280(a0)
    8000710a:	14051573          	csrrw	a0,sscratch,a0
    8000710e:	10200073          	sret
