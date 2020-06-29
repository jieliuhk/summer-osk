
user/_zombie:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "kernel/stat.h"
#include "user/user.h"

int
main(void)
{
   0:	1141                	addi	sp,sp,-16
   2:	e406                	sd	ra,8(sp)
   4:	e022                	sd	s0,0(sp)
   6:	0800                	addi	s0,sp,16
  if(fork() > 0)
   8:	00000097          	auipc	ra,0x0
   c:	210080e7          	jalr	528(ra) # 218 <fork>
  10:	00a04763          	bgtz	a0,1e <main+0x1e>
    sleep(5);  // Let child exit before parent.
  exit(0);
  14:	4501                	li	a0,0
  16:	00000097          	auipc	ra,0x0
  1a:	20a080e7          	jalr	522(ra) # 220 <exit>
    sleep(5);  // Let child exit before parent.
  1e:	4515                	li	a0,5
  20:	00000097          	auipc	ra,0x0
  24:	290080e7          	jalr	656(ra) # 2b0 <sleep>
  28:	b7f5                	j	14 <main+0x14>

000000000000002a <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
  2a:	1141                	addi	sp,sp,-16
  2c:	e422                	sd	s0,8(sp)
  2e:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  30:	87aa                	mv	a5,a0
  32:	0585                	addi	a1,a1,1
  34:	0785                	addi	a5,a5,1
  36:	fff5c703          	lbu	a4,-1(a1)
  3a:	fee78fa3          	sb	a4,-1(a5)
  3e:	fb75                	bnez	a4,32 <strcpy+0x8>
    ;
  return os;
}
  40:	6422                	ld	s0,8(sp)
  42:	0141                	addi	sp,sp,16
  44:	8082                	ret

0000000000000046 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  46:	1141                	addi	sp,sp,-16
  48:	e422                	sd	s0,8(sp)
  4a:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
  4c:	00054783          	lbu	a5,0(a0)
  50:	cb91                	beqz	a5,64 <strcmp+0x1e>
  52:	0005c703          	lbu	a4,0(a1)
  56:	00f71763          	bne	a4,a5,64 <strcmp+0x1e>
    p++, q++;
  5a:	0505                	addi	a0,a0,1
  5c:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
  5e:	00054783          	lbu	a5,0(a0)
  62:	fbe5                	bnez	a5,52 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
  64:	0005c503          	lbu	a0,0(a1)
}
  68:	40a7853b          	subw	a0,a5,a0
  6c:	6422                	ld	s0,8(sp)
  6e:	0141                	addi	sp,sp,16
  70:	8082                	ret

0000000000000072 <strlen>:

uint
strlen(const char *s)
{
  72:	1141                	addi	sp,sp,-16
  74:	e422                	sd	s0,8(sp)
  76:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
  78:	00054783          	lbu	a5,0(a0)
  7c:	cf91                	beqz	a5,98 <strlen+0x26>
  7e:	0505                	addi	a0,a0,1
  80:	87aa                	mv	a5,a0
  82:	4685                	li	a3,1
  84:	9e89                	subw	a3,a3,a0
  86:	00f6853b          	addw	a0,a3,a5
  8a:	0785                	addi	a5,a5,1
  8c:	fff7c703          	lbu	a4,-1(a5)
  90:	fb7d                	bnez	a4,86 <strlen+0x14>
    ;
  return n;
}
  92:	6422                	ld	s0,8(sp)
  94:	0141                	addi	sp,sp,16
  96:	8082                	ret
  for(n = 0; s[n]; n++)
  98:	4501                	li	a0,0
  9a:	bfe5                	j	92 <strlen+0x20>

000000000000009c <memset>:

void*
memset(void *dst, int c, uint n)
{
  9c:	1141                	addi	sp,sp,-16
  9e:	e422                	sd	s0,8(sp)
  a0:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
  a2:	ce09                	beqz	a2,bc <memset+0x20>
  a4:	87aa                	mv	a5,a0
  a6:	fff6071b          	addiw	a4,a2,-1
  aa:	1702                	slli	a4,a4,0x20
  ac:	9301                	srli	a4,a4,0x20
  ae:	0705                	addi	a4,a4,1
  b0:	972a                	add	a4,a4,a0
    cdst[i] = c;
  b2:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
  b6:	0785                	addi	a5,a5,1
  b8:	fee79de3          	bne	a5,a4,b2 <memset+0x16>
  }
  return dst;
}
  bc:	6422                	ld	s0,8(sp)
  be:	0141                	addi	sp,sp,16
  c0:	8082                	ret

00000000000000c2 <strchr>:

char*
strchr(const char *s, char c)
{
  c2:	1141                	addi	sp,sp,-16
  c4:	e422                	sd	s0,8(sp)
  c6:	0800                	addi	s0,sp,16
  for(; *s; s++)
  c8:	00054783          	lbu	a5,0(a0)
  cc:	cb99                	beqz	a5,e2 <strchr+0x20>
    if(*s == c)
  ce:	00f58763          	beq	a1,a5,dc <strchr+0x1a>
  for(; *s; s++)
  d2:	0505                	addi	a0,a0,1
  d4:	00054783          	lbu	a5,0(a0)
  d8:	fbfd                	bnez	a5,ce <strchr+0xc>
      return (char*)s;
  return 0;
  da:	4501                	li	a0,0
}
  dc:	6422                	ld	s0,8(sp)
  de:	0141                	addi	sp,sp,16
  e0:	8082                	ret
  return 0;
  e2:	4501                	li	a0,0
  e4:	bfe5                	j	dc <strchr+0x1a>

00000000000000e6 <gets>:

char*
gets(char *buf, int max)
{
  e6:	711d                	addi	sp,sp,-96
  e8:	ec86                	sd	ra,88(sp)
  ea:	e8a2                	sd	s0,80(sp)
  ec:	e4a6                	sd	s1,72(sp)
  ee:	e0ca                	sd	s2,64(sp)
  f0:	fc4e                	sd	s3,56(sp)
  f2:	f852                	sd	s4,48(sp)
  f4:	f456                	sd	s5,40(sp)
  f6:	f05a                	sd	s6,32(sp)
  f8:	ec5e                	sd	s7,24(sp)
  fa:	1080                	addi	s0,sp,96
  fc:	8baa                	mv	s7,a0
  fe:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 100:	892a                	mv	s2,a0
 102:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 104:	4aa9                	li	s5,10
 106:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 108:	89a6                	mv	s3,s1
 10a:	2485                	addiw	s1,s1,1
 10c:	0344d863          	bge	s1,s4,13c <gets+0x56>
    cc = read(0, &c, 1);
 110:	4605                	li	a2,1
 112:	faf40593          	addi	a1,s0,-81
 116:	4501                	li	a0,0
 118:	00000097          	auipc	ra,0x0
 11c:	120080e7          	jalr	288(ra) # 238 <read>
    if(cc < 1)
 120:	00a05e63          	blez	a0,13c <gets+0x56>
    buf[i++] = c;
 124:	faf44783          	lbu	a5,-81(s0)
 128:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 12c:	01578763          	beq	a5,s5,13a <gets+0x54>
 130:	0905                	addi	s2,s2,1
 132:	fd679be3          	bne	a5,s6,108 <gets+0x22>
  for(i=0; i+1 < max; ){
 136:	89a6                	mv	s3,s1
 138:	a011                	j	13c <gets+0x56>
 13a:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 13c:	99de                	add	s3,s3,s7
 13e:	00098023          	sb	zero,0(s3)
  return buf;
}
 142:	855e                	mv	a0,s7
 144:	60e6                	ld	ra,88(sp)
 146:	6446                	ld	s0,80(sp)
 148:	64a6                	ld	s1,72(sp)
 14a:	6906                	ld	s2,64(sp)
 14c:	79e2                	ld	s3,56(sp)
 14e:	7a42                	ld	s4,48(sp)
 150:	7aa2                	ld	s5,40(sp)
 152:	7b02                	ld	s6,32(sp)
 154:	6be2                	ld	s7,24(sp)
 156:	6125                	addi	sp,sp,96
 158:	8082                	ret

000000000000015a <stat>:

int
stat(const char *n, struct stat *st)
{
 15a:	1101                	addi	sp,sp,-32
 15c:	ec06                	sd	ra,24(sp)
 15e:	e822                	sd	s0,16(sp)
 160:	e426                	sd	s1,8(sp)
 162:	e04a                	sd	s2,0(sp)
 164:	1000                	addi	s0,sp,32
 166:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 168:	4581                	li	a1,0
 16a:	00000097          	auipc	ra,0x0
 16e:	0f6080e7          	jalr	246(ra) # 260 <open>
  if(fd < 0)
 172:	02054563          	bltz	a0,19c <stat+0x42>
 176:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 178:	85ca                	mv	a1,s2
 17a:	00000097          	auipc	ra,0x0
 17e:	0fe080e7          	jalr	254(ra) # 278 <fstat>
 182:	892a                	mv	s2,a0
  close(fd);
 184:	8526                	mv	a0,s1
 186:	00000097          	auipc	ra,0x0
 18a:	0c2080e7          	jalr	194(ra) # 248 <close>
  return r;
}
 18e:	854a                	mv	a0,s2
 190:	60e2                	ld	ra,24(sp)
 192:	6442                	ld	s0,16(sp)
 194:	64a2                	ld	s1,8(sp)
 196:	6902                	ld	s2,0(sp)
 198:	6105                	addi	sp,sp,32
 19a:	8082                	ret
    return -1;
 19c:	597d                	li	s2,-1
 19e:	bfc5                	j	18e <stat+0x34>

00000000000001a0 <atoi>:

int
atoi(const char *s)
{
 1a0:	1141                	addi	sp,sp,-16
 1a2:	e422                	sd	s0,8(sp)
 1a4:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 1a6:	00054603          	lbu	a2,0(a0)
 1aa:	fd06079b          	addiw	a5,a2,-48
 1ae:	0ff7f793          	andi	a5,a5,255
 1b2:	4725                	li	a4,9
 1b4:	02f76963          	bltu	a4,a5,1e6 <atoi+0x46>
 1b8:	86aa                	mv	a3,a0
  n = 0;
 1ba:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 1bc:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 1be:	0685                	addi	a3,a3,1
 1c0:	0025179b          	slliw	a5,a0,0x2
 1c4:	9fa9                	addw	a5,a5,a0
 1c6:	0017979b          	slliw	a5,a5,0x1
 1ca:	9fb1                	addw	a5,a5,a2
 1cc:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 1d0:	0006c603          	lbu	a2,0(a3)
 1d4:	fd06071b          	addiw	a4,a2,-48
 1d8:	0ff77713          	andi	a4,a4,255
 1dc:	fee5f1e3          	bgeu	a1,a4,1be <atoi+0x1e>
  return n;
}
 1e0:	6422                	ld	s0,8(sp)
 1e2:	0141                	addi	sp,sp,16
 1e4:	8082                	ret
  n = 0;
 1e6:	4501                	li	a0,0
 1e8:	bfe5                	j	1e0 <atoi+0x40>

00000000000001ea <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 1ea:	1141                	addi	sp,sp,-16
 1ec:	e422                	sd	s0,8(sp)
 1ee:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 1f0:	02c05163          	blez	a2,212 <memmove+0x28>
 1f4:	fff6071b          	addiw	a4,a2,-1
 1f8:	1702                	slli	a4,a4,0x20
 1fa:	9301                	srli	a4,a4,0x20
 1fc:	0705                	addi	a4,a4,1
 1fe:	972a                	add	a4,a4,a0
  dst = vdst;
 200:	87aa                	mv	a5,a0
    *dst++ = *src++;
 202:	0585                	addi	a1,a1,1
 204:	0785                	addi	a5,a5,1
 206:	fff5c683          	lbu	a3,-1(a1)
 20a:	fed78fa3          	sb	a3,-1(a5)
  while(n-- > 0)
 20e:	fee79ae3          	bne	a5,a4,202 <memmove+0x18>
  return vdst;
}
 212:	6422                	ld	s0,8(sp)
 214:	0141                	addi	sp,sp,16
 216:	8082                	ret

0000000000000218 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 218:	4885                	li	a7,1
 ecall
 21a:	00000073          	ecall
 ret
 21e:	8082                	ret

0000000000000220 <exit>:
.global exit
exit:
 li a7, SYS_exit
 220:	4889                	li	a7,2
 ecall
 222:	00000073          	ecall
 ret
 226:	8082                	ret

0000000000000228 <wait>:
.global wait
wait:
 li a7, SYS_wait
 228:	488d                	li	a7,3
 ecall
 22a:	00000073          	ecall
 ret
 22e:	8082                	ret

0000000000000230 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 230:	4891                	li	a7,4
 ecall
 232:	00000073          	ecall
 ret
 236:	8082                	ret

0000000000000238 <read>:
.global read
read:
 li a7, SYS_read
 238:	4895                	li	a7,5
 ecall
 23a:	00000073          	ecall
 ret
 23e:	8082                	ret

0000000000000240 <write>:
.global write
write:
 li a7, SYS_write
 240:	48c1                	li	a7,16
 ecall
 242:	00000073          	ecall
 ret
 246:	8082                	ret

0000000000000248 <close>:
.global close
close:
 li a7, SYS_close
 248:	48d5                	li	a7,21
 ecall
 24a:	00000073          	ecall
 ret
 24e:	8082                	ret

0000000000000250 <kill>:
.global kill
kill:
 li a7, SYS_kill
 250:	4899                	li	a7,6
 ecall
 252:	00000073          	ecall
 ret
 256:	8082                	ret

0000000000000258 <exec>:
.global exec
exec:
 li a7, SYS_exec
 258:	489d                	li	a7,7
 ecall
 25a:	00000073          	ecall
 ret
 25e:	8082                	ret

0000000000000260 <open>:
.global open
open:
 li a7, SYS_open
 260:	48bd                	li	a7,15
 ecall
 262:	00000073          	ecall
 ret
 266:	8082                	ret

0000000000000268 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 268:	48c5                	li	a7,17
 ecall
 26a:	00000073          	ecall
 ret
 26e:	8082                	ret

0000000000000270 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 270:	48c9                	li	a7,18
 ecall
 272:	00000073          	ecall
 ret
 276:	8082                	ret

0000000000000278 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 278:	48a1                	li	a7,8
 ecall
 27a:	00000073          	ecall
 ret
 27e:	8082                	ret

0000000000000280 <link>:
.global link
link:
 li a7, SYS_link
 280:	48cd                	li	a7,19
 ecall
 282:	00000073          	ecall
 ret
 286:	8082                	ret

0000000000000288 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 288:	48d1                	li	a7,20
 ecall
 28a:	00000073          	ecall
 ret
 28e:	8082                	ret

0000000000000290 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 290:	48a5                	li	a7,9
 ecall
 292:	00000073          	ecall
 ret
 296:	8082                	ret

0000000000000298 <dup>:
.global dup
dup:
 li a7, SYS_dup
 298:	48a9                	li	a7,10
 ecall
 29a:	00000073          	ecall
 ret
 29e:	8082                	ret

00000000000002a0 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 2a0:	48ad                	li	a7,11
 ecall
 2a2:	00000073          	ecall
 ret
 2a6:	8082                	ret

00000000000002a8 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 2a8:	48b1                	li	a7,12
 ecall
 2aa:	00000073          	ecall
 ret
 2ae:	8082                	ret

00000000000002b0 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 2b0:	48b5                	li	a7,13
 ecall
 2b2:	00000073          	ecall
 ret
 2b6:	8082                	ret

00000000000002b8 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 2b8:	48b9                	li	a7,14
 ecall
 2ba:	00000073          	ecall
 ret
 2be:	8082                	ret

00000000000002c0 <traceon>:
.global traceon
traceon:
 li a7, SYS_traceon
 2c0:	48d9                	li	a7,22
 ecall
 2c2:	00000073          	ecall
 ret
 2c6:	8082                	ret

00000000000002c8 <ps>:
.global ps
ps:
 li a7, SYS_ps
 2c8:	48dd                	li	a7,23
 ecall
 2ca:	00000073          	ecall
 ret
 2ce:	8082                	ret

00000000000002d0 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 2d0:	1101                	addi	sp,sp,-32
 2d2:	ec06                	sd	ra,24(sp)
 2d4:	e822                	sd	s0,16(sp)
 2d6:	1000                	addi	s0,sp,32
 2d8:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 2dc:	4605                	li	a2,1
 2de:	fef40593          	addi	a1,s0,-17
 2e2:	00000097          	auipc	ra,0x0
 2e6:	f5e080e7          	jalr	-162(ra) # 240 <write>
}
 2ea:	60e2                	ld	ra,24(sp)
 2ec:	6442                	ld	s0,16(sp)
 2ee:	6105                	addi	sp,sp,32
 2f0:	8082                	ret

00000000000002f2 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 2f2:	7139                	addi	sp,sp,-64
 2f4:	fc06                	sd	ra,56(sp)
 2f6:	f822                	sd	s0,48(sp)
 2f8:	f426                	sd	s1,40(sp)
 2fa:	f04a                	sd	s2,32(sp)
 2fc:	ec4e                	sd	s3,24(sp)
 2fe:	0080                	addi	s0,sp,64
 300:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 302:	c299                	beqz	a3,308 <printint+0x16>
 304:	0805c863          	bltz	a1,394 <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 308:	2581                	sext.w	a1,a1
  neg = 0;
 30a:	4881                	li	a7,0
 30c:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 310:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 312:	2601                	sext.w	a2,a2
 314:	00000517          	auipc	a0,0x0
 318:	44450513          	addi	a0,a0,1092 # 758 <digits>
 31c:	883a                	mv	a6,a4
 31e:	2705                	addiw	a4,a4,1
 320:	02c5f7bb          	remuw	a5,a1,a2
 324:	1782                	slli	a5,a5,0x20
 326:	9381                	srli	a5,a5,0x20
 328:	97aa                	add	a5,a5,a0
 32a:	0007c783          	lbu	a5,0(a5)
 32e:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 332:	0005879b          	sext.w	a5,a1
 336:	02c5d5bb          	divuw	a1,a1,a2
 33a:	0685                	addi	a3,a3,1
 33c:	fec7f0e3          	bgeu	a5,a2,31c <printint+0x2a>
  if(neg)
 340:	00088b63          	beqz	a7,356 <printint+0x64>
    buf[i++] = '-';
 344:	fd040793          	addi	a5,s0,-48
 348:	973e                	add	a4,a4,a5
 34a:	02d00793          	li	a5,45
 34e:	fef70823          	sb	a5,-16(a4)
 352:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 356:	02e05863          	blez	a4,386 <printint+0x94>
 35a:	fc040793          	addi	a5,s0,-64
 35e:	00e78933          	add	s2,a5,a4
 362:	fff78993          	addi	s3,a5,-1
 366:	99ba                	add	s3,s3,a4
 368:	377d                	addiw	a4,a4,-1
 36a:	1702                	slli	a4,a4,0x20
 36c:	9301                	srli	a4,a4,0x20
 36e:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 372:	fff94583          	lbu	a1,-1(s2)
 376:	8526                	mv	a0,s1
 378:	00000097          	auipc	ra,0x0
 37c:	f58080e7          	jalr	-168(ra) # 2d0 <putc>
  while(--i >= 0)
 380:	197d                	addi	s2,s2,-1
 382:	ff3918e3          	bne	s2,s3,372 <printint+0x80>
}
 386:	70e2                	ld	ra,56(sp)
 388:	7442                	ld	s0,48(sp)
 38a:	74a2                	ld	s1,40(sp)
 38c:	7902                	ld	s2,32(sp)
 38e:	69e2                	ld	s3,24(sp)
 390:	6121                	addi	sp,sp,64
 392:	8082                	ret
    x = -xx;
 394:	40b005bb          	negw	a1,a1
    neg = 1;
 398:	4885                	li	a7,1
    x = -xx;
 39a:	bf8d                	j	30c <printint+0x1a>

000000000000039c <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 39c:	7119                	addi	sp,sp,-128
 39e:	fc86                	sd	ra,120(sp)
 3a0:	f8a2                	sd	s0,112(sp)
 3a2:	f4a6                	sd	s1,104(sp)
 3a4:	f0ca                	sd	s2,96(sp)
 3a6:	ecce                	sd	s3,88(sp)
 3a8:	e8d2                	sd	s4,80(sp)
 3aa:	e4d6                	sd	s5,72(sp)
 3ac:	e0da                	sd	s6,64(sp)
 3ae:	fc5e                	sd	s7,56(sp)
 3b0:	f862                	sd	s8,48(sp)
 3b2:	f466                	sd	s9,40(sp)
 3b4:	f06a                	sd	s10,32(sp)
 3b6:	ec6e                	sd	s11,24(sp)
 3b8:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 3ba:	0005c903          	lbu	s2,0(a1)
 3be:	18090f63          	beqz	s2,55c <vprintf+0x1c0>
 3c2:	8aaa                	mv	s5,a0
 3c4:	8b32                	mv	s6,a2
 3c6:	00158493          	addi	s1,a1,1
  state = 0;
 3ca:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 3cc:	02500a13          	li	s4,37
      if(c == 'd'){
 3d0:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 3d4:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 3d8:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 3dc:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 3e0:	00000b97          	auipc	s7,0x0
 3e4:	378b8b93          	addi	s7,s7,888 # 758 <digits>
 3e8:	a839                	j	406 <vprintf+0x6a>
        putc(fd, c);
 3ea:	85ca                	mv	a1,s2
 3ec:	8556                	mv	a0,s5
 3ee:	00000097          	auipc	ra,0x0
 3f2:	ee2080e7          	jalr	-286(ra) # 2d0 <putc>
 3f6:	a019                	j	3fc <vprintf+0x60>
    } else if(state == '%'){
 3f8:	01498f63          	beq	s3,s4,416 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 3fc:	0485                	addi	s1,s1,1
 3fe:	fff4c903          	lbu	s2,-1(s1)
 402:	14090d63          	beqz	s2,55c <vprintf+0x1c0>
    c = fmt[i] & 0xff;
 406:	0009079b          	sext.w	a5,s2
    if(state == 0){
 40a:	fe0997e3          	bnez	s3,3f8 <vprintf+0x5c>
      if(c == '%'){
 40e:	fd479ee3          	bne	a5,s4,3ea <vprintf+0x4e>
        state = '%';
 412:	89be                	mv	s3,a5
 414:	b7e5                	j	3fc <vprintf+0x60>
      if(c == 'd'){
 416:	05878063          	beq	a5,s8,456 <vprintf+0xba>
      } else if(c == 'l') {
 41a:	05978c63          	beq	a5,s9,472 <vprintf+0xd6>
      } else if(c == 'x') {
 41e:	07a78863          	beq	a5,s10,48e <vprintf+0xf2>
      } else if(c == 'p') {
 422:	09b78463          	beq	a5,s11,4aa <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 426:	07300713          	li	a4,115
 42a:	0ce78663          	beq	a5,a4,4f6 <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 42e:	06300713          	li	a4,99
 432:	0ee78e63          	beq	a5,a4,52e <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 436:	11478863          	beq	a5,s4,546 <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 43a:	85d2                	mv	a1,s4
 43c:	8556                	mv	a0,s5
 43e:	00000097          	auipc	ra,0x0
 442:	e92080e7          	jalr	-366(ra) # 2d0 <putc>
        putc(fd, c);
 446:	85ca                	mv	a1,s2
 448:	8556                	mv	a0,s5
 44a:	00000097          	auipc	ra,0x0
 44e:	e86080e7          	jalr	-378(ra) # 2d0 <putc>
      }
      state = 0;
 452:	4981                	li	s3,0
 454:	b765                	j	3fc <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 456:	008b0913          	addi	s2,s6,8
 45a:	4685                	li	a3,1
 45c:	4629                	li	a2,10
 45e:	000b2583          	lw	a1,0(s6)
 462:	8556                	mv	a0,s5
 464:	00000097          	auipc	ra,0x0
 468:	e8e080e7          	jalr	-370(ra) # 2f2 <printint>
 46c:	8b4a                	mv	s6,s2
      state = 0;
 46e:	4981                	li	s3,0
 470:	b771                	j	3fc <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 472:	008b0913          	addi	s2,s6,8
 476:	4681                	li	a3,0
 478:	4629                	li	a2,10
 47a:	000b2583          	lw	a1,0(s6)
 47e:	8556                	mv	a0,s5
 480:	00000097          	auipc	ra,0x0
 484:	e72080e7          	jalr	-398(ra) # 2f2 <printint>
 488:	8b4a                	mv	s6,s2
      state = 0;
 48a:	4981                	li	s3,0
 48c:	bf85                	j	3fc <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 48e:	008b0913          	addi	s2,s6,8
 492:	4681                	li	a3,0
 494:	4641                	li	a2,16
 496:	000b2583          	lw	a1,0(s6)
 49a:	8556                	mv	a0,s5
 49c:	00000097          	auipc	ra,0x0
 4a0:	e56080e7          	jalr	-426(ra) # 2f2 <printint>
 4a4:	8b4a                	mv	s6,s2
      state = 0;
 4a6:	4981                	li	s3,0
 4a8:	bf91                	j	3fc <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 4aa:	008b0793          	addi	a5,s6,8
 4ae:	f8f43423          	sd	a5,-120(s0)
 4b2:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 4b6:	03000593          	li	a1,48
 4ba:	8556                	mv	a0,s5
 4bc:	00000097          	auipc	ra,0x0
 4c0:	e14080e7          	jalr	-492(ra) # 2d0 <putc>
  putc(fd, 'x');
 4c4:	85ea                	mv	a1,s10
 4c6:	8556                	mv	a0,s5
 4c8:	00000097          	auipc	ra,0x0
 4cc:	e08080e7          	jalr	-504(ra) # 2d0 <putc>
 4d0:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 4d2:	03c9d793          	srli	a5,s3,0x3c
 4d6:	97de                	add	a5,a5,s7
 4d8:	0007c583          	lbu	a1,0(a5)
 4dc:	8556                	mv	a0,s5
 4de:	00000097          	auipc	ra,0x0
 4e2:	df2080e7          	jalr	-526(ra) # 2d0 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 4e6:	0992                	slli	s3,s3,0x4
 4e8:	397d                	addiw	s2,s2,-1
 4ea:	fe0914e3          	bnez	s2,4d2 <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 4ee:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 4f2:	4981                	li	s3,0
 4f4:	b721                	j	3fc <vprintf+0x60>
        s = va_arg(ap, char*);
 4f6:	008b0993          	addi	s3,s6,8
 4fa:	000b3903          	ld	s2,0(s6)
        if(s == 0)
 4fe:	02090163          	beqz	s2,520 <vprintf+0x184>
        while(*s != 0){
 502:	00094583          	lbu	a1,0(s2)
 506:	c9a1                	beqz	a1,556 <vprintf+0x1ba>
          putc(fd, *s);
 508:	8556                	mv	a0,s5
 50a:	00000097          	auipc	ra,0x0
 50e:	dc6080e7          	jalr	-570(ra) # 2d0 <putc>
          s++;
 512:	0905                	addi	s2,s2,1
        while(*s != 0){
 514:	00094583          	lbu	a1,0(s2)
 518:	f9e5                	bnez	a1,508 <vprintf+0x16c>
        s = va_arg(ap, char*);
 51a:	8b4e                	mv	s6,s3
      state = 0;
 51c:	4981                	li	s3,0
 51e:	bdf9                	j	3fc <vprintf+0x60>
          s = "(null)";
 520:	00000917          	auipc	s2,0x0
 524:	23090913          	addi	s2,s2,560 # 750 <malloc+0xea>
        while(*s != 0){
 528:	02800593          	li	a1,40
 52c:	bff1                	j	508 <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
 52e:	008b0913          	addi	s2,s6,8
 532:	000b4583          	lbu	a1,0(s6)
 536:	8556                	mv	a0,s5
 538:	00000097          	auipc	ra,0x0
 53c:	d98080e7          	jalr	-616(ra) # 2d0 <putc>
 540:	8b4a                	mv	s6,s2
      state = 0;
 542:	4981                	li	s3,0
 544:	bd65                	j	3fc <vprintf+0x60>
        putc(fd, c);
 546:	85d2                	mv	a1,s4
 548:	8556                	mv	a0,s5
 54a:	00000097          	auipc	ra,0x0
 54e:	d86080e7          	jalr	-634(ra) # 2d0 <putc>
      state = 0;
 552:	4981                	li	s3,0
 554:	b565                	j	3fc <vprintf+0x60>
        s = va_arg(ap, char*);
 556:	8b4e                	mv	s6,s3
      state = 0;
 558:	4981                	li	s3,0
 55a:	b54d                	j	3fc <vprintf+0x60>
    }
  }
}
 55c:	70e6                	ld	ra,120(sp)
 55e:	7446                	ld	s0,112(sp)
 560:	74a6                	ld	s1,104(sp)
 562:	7906                	ld	s2,96(sp)
 564:	69e6                	ld	s3,88(sp)
 566:	6a46                	ld	s4,80(sp)
 568:	6aa6                	ld	s5,72(sp)
 56a:	6b06                	ld	s6,64(sp)
 56c:	7be2                	ld	s7,56(sp)
 56e:	7c42                	ld	s8,48(sp)
 570:	7ca2                	ld	s9,40(sp)
 572:	7d02                	ld	s10,32(sp)
 574:	6de2                	ld	s11,24(sp)
 576:	6109                	addi	sp,sp,128
 578:	8082                	ret

000000000000057a <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 57a:	715d                	addi	sp,sp,-80
 57c:	ec06                	sd	ra,24(sp)
 57e:	e822                	sd	s0,16(sp)
 580:	1000                	addi	s0,sp,32
 582:	e010                	sd	a2,0(s0)
 584:	e414                	sd	a3,8(s0)
 586:	e818                	sd	a4,16(s0)
 588:	ec1c                	sd	a5,24(s0)
 58a:	03043023          	sd	a6,32(s0)
 58e:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 592:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 596:	8622                	mv	a2,s0
 598:	00000097          	auipc	ra,0x0
 59c:	e04080e7          	jalr	-508(ra) # 39c <vprintf>
}
 5a0:	60e2                	ld	ra,24(sp)
 5a2:	6442                	ld	s0,16(sp)
 5a4:	6161                	addi	sp,sp,80
 5a6:	8082                	ret

00000000000005a8 <printf>:

void
printf(const char *fmt, ...)
{
 5a8:	711d                	addi	sp,sp,-96
 5aa:	ec06                	sd	ra,24(sp)
 5ac:	e822                	sd	s0,16(sp)
 5ae:	1000                	addi	s0,sp,32
 5b0:	e40c                	sd	a1,8(s0)
 5b2:	e810                	sd	a2,16(s0)
 5b4:	ec14                	sd	a3,24(s0)
 5b6:	f018                	sd	a4,32(s0)
 5b8:	f41c                	sd	a5,40(s0)
 5ba:	03043823          	sd	a6,48(s0)
 5be:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 5c2:	00840613          	addi	a2,s0,8
 5c6:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 5ca:	85aa                	mv	a1,a0
 5cc:	4505                	li	a0,1
 5ce:	00000097          	auipc	ra,0x0
 5d2:	dce080e7          	jalr	-562(ra) # 39c <vprintf>
}
 5d6:	60e2                	ld	ra,24(sp)
 5d8:	6442                	ld	s0,16(sp)
 5da:	6125                	addi	sp,sp,96
 5dc:	8082                	ret

00000000000005de <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 5de:	1141                	addi	sp,sp,-16
 5e0:	e422                	sd	s0,8(sp)
 5e2:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 5e4:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 5e8:	00000797          	auipc	a5,0x0
 5ec:	1887b783          	ld	a5,392(a5) # 770 <freep>
 5f0:	a805                	j	620 <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 5f2:	4618                	lw	a4,8(a2)
 5f4:	9db9                	addw	a1,a1,a4
 5f6:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 5fa:	6398                	ld	a4,0(a5)
 5fc:	6318                	ld	a4,0(a4)
 5fe:	fee53823          	sd	a4,-16(a0)
 602:	a091                	j	646 <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 604:	ff852703          	lw	a4,-8(a0)
 608:	9e39                	addw	a2,a2,a4
 60a:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 60c:	ff053703          	ld	a4,-16(a0)
 610:	e398                	sd	a4,0(a5)
 612:	a099                	j	658 <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 614:	6398                	ld	a4,0(a5)
 616:	00e7e463          	bltu	a5,a4,61e <free+0x40>
 61a:	00e6ea63          	bltu	a3,a4,62e <free+0x50>
{
 61e:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 620:	fed7fae3          	bgeu	a5,a3,614 <free+0x36>
 624:	6398                	ld	a4,0(a5)
 626:	00e6e463          	bltu	a3,a4,62e <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 62a:	fee7eae3          	bltu	a5,a4,61e <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 62e:	ff852583          	lw	a1,-8(a0)
 632:	6390                	ld	a2,0(a5)
 634:	02059713          	slli	a4,a1,0x20
 638:	9301                	srli	a4,a4,0x20
 63a:	0712                	slli	a4,a4,0x4
 63c:	9736                	add	a4,a4,a3
 63e:	fae60ae3          	beq	a2,a4,5f2 <free+0x14>
    bp->s.ptr = p->s.ptr;
 642:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 646:	4790                	lw	a2,8(a5)
 648:	02061713          	slli	a4,a2,0x20
 64c:	9301                	srli	a4,a4,0x20
 64e:	0712                	slli	a4,a4,0x4
 650:	973e                	add	a4,a4,a5
 652:	fae689e3          	beq	a3,a4,604 <free+0x26>
  } else
    p->s.ptr = bp;
 656:	e394                	sd	a3,0(a5)
  freep = p;
 658:	00000717          	auipc	a4,0x0
 65c:	10f73c23          	sd	a5,280(a4) # 770 <freep>
}
 660:	6422                	ld	s0,8(sp)
 662:	0141                	addi	sp,sp,16
 664:	8082                	ret

0000000000000666 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 666:	7139                	addi	sp,sp,-64
 668:	fc06                	sd	ra,56(sp)
 66a:	f822                	sd	s0,48(sp)
 66c:	f426                	sd	s1,40(sp)
 66e:	f04a                	sd	s2,32(sp)
 670:	ec4e                	sd	s3,24(sp)
 672:	e852                	sd	s4,16(sp)
 674:	e456                	sd	s5,8(sp)
 676:	e05a                	sd	s6,0(sp)
 678:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 67a:	02051493          	slli	s1,a0,0x20
 67e:	9081                	srli	s1,s1,0x20
 680:	04bd                	addi	s1,s1,15
 682:	8091                	srli	s1,s1,0x4
 684:	0014899b          	addiw	s3,s1,1
 688:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 68a:	00000517          	auipc	a0,0x0
 68e:	0e653503          	ld	a0,230(a0) # 770 <freep>
 692:	c515                	beqz	a0,6be <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 694:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 696:	4798                	lw	a4,8(a5)
 698:	02977f63          	bgeu	a4,s1,6d6 <malloc+0x70>
 69c:	8a4e                	mv	s4,s3
 69e:	0009871b          	sext.w	a4,s3
 6a2:	6685                	lui	a3,0x1
 6a4:	00d77363          	bgeu	a4,a3,6aa <malloc+0x44>
 6a8:	6a05                	lui	s4,0x1
 6aa:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 6ae:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 6b2:	00000917          	auipc	s2,0x0
 6b6:	0be90913          	addi	s2,s2,190 # 770 <freep>
  if(p == (char*)-1)
 6ba:	5afd                	li	s5,-1
 6bc:	a88d                	j	72e <malloc+0xc8>
    base.s.ptr = freep = prevp = &base;
 6be:	00000797          	auipc	a5,0x0
 6c2:	0ba78793          	addi	a5,a5,186 # 778 <base>
 6c6:	00000717          	auipc	a4,0x0
 6ca:	0af73523          	sd	a5,170(a4) # 770 <freep>
 6ce:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 6d0:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 6d4:	b7e1                	j	69c <malloc+0x36>
      if(p->s.size == nunits)
 6d6:	02e48b63          	beq	s1,a4,70c <malloc+0xa6>
        p->s.size -= nunits;
 6da:	4137073b          	subw	a4,a4,s3
 6de:	c798                	sw	a4,8(a5)
        p += p->s.size;
 6e0:	1702                	slli	a4,a4,0x20
 6e2:	9301                	srli	a4,a4,0x20
 6e4:	0712                	slli	a4,a4,0x4
 6e6:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 6e8:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 6ec:	00000717          	auipc	a4,0x0
 6f0:	08a73223          	sd	a0,132(a4) # 770 <freep>
      return (void*)(p + 1);
 6f4:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 6f8:	70e2                	ld	ra,56(sp)
 6fa:	7442                	ld	s0,48(sp)
 6fc:	74a2                	ld	s1,40(sp)
 6fe:	7902                	ld	s2,32(sp)
 700:	69e2                	ld	s3,24(sp)
 702:	6a42                	ld	s4,16(sp)
 704:	6aa2                	ld	s5,8(sp)
 706:	6b02                	ld	s6,0(sp)
 708:	6121                	addi	sp,sp,64
 70a:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 70c:	6398                	ld	a4,0(a5)
 70e:	e118                	sd	a4,0(a0)
 710:	bff1                	j	6ec <malloc+0x86>
  hp->s.size = nu;
 712:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 716:	0541                	addi	a0,a0,16
 718:	00000097          	auipc	ra,0x0
 71c:	ec6080e7          	jalr	-314(ra) # 5de <free>
  return freep;
 720:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 724:	d971                	beqz	a0,6f8 <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 726:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 728:	4798                	lw	a4,8(a5)
 72a:	fa9776e3          	bgeu	a4,s1,6d6 <malloc+0x70>
    if(p == freep)
 72e:	00093703          	ld	a4,0(s2)
 732:	853e                	mv	a0,a5
 734:	fef719e3          	bne	a4,a5,726 <malloc+0xc0>
  p = sbrk(nu * sizeof(Header));
 738:	8552                	mv	a0,s4
 73a:	00000097          	auipc	ra,0x0
 73e:	b6e080e7          	jalr	-1170(ra) # 2a8 <sbrk>
  if(p == (char*)-1)
 742:	fd5518e3          	bne	a0,s5,712 <malloc+0xac>
        return 0;
 746:	4501                	li	a0,0
 748:	bf45                	j	6f8 <malloc+0x92>
