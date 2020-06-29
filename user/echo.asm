
user/_echo:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "kernel/stat.h"
#include "user/user.h"

int
main(int argc, char *argv[])
{
   0:	7179                	addi	sp,sp,-48
   2:	f406                	sd	ra,40(sp)
   4:	f022                	sd	s0,32(sp)
   6:	ec26                	sd	s1,24(sp)
   8:	e84a                	sd	s2,16(sp)
   a:	e44e                	sd	s3,8(sp)
   c:	e052                	sd	s4,0(sp)
   e:	1800                	addi	s0,sp,48
  int i;

  for(i = 1; i < argc; i++){
  10:	4785                	li	a5,1
  12:	06a7d463          	bge	a5,a0,7a <main+0x7a>
  16:	00858493          	addi	s1,a1,8
  1a:	ffe5099b          	addiw	s3,a0,-2
  1e:	1982                	slli	s3,s3,0x20
  20:	0209d993          	srli	s3,s3,0x20
  24:	098e                	slli	s3,s3,0x3
  26:	05c1                	addi	a1,a1,16
  28:	99ae                	add	s3,s3,a1
    write(1, argv[i], strlen(argv[i]));
    if(i + 1 < argc){
      write(1, " ", 1);
  2a:	00000a17          	auipc	s4,0x0
  2e:	77ea0a13          	addi	s4,s4,1918 # 7a8 <malloc+0xe8>
    write(1, argv[i], strlen(argv[i]));
  32:	0004b903          	ld	s2,0(s1)
  36:	854a                	mv	a0,s2
  38:	00000097          	auipc	ra,0x0
  3c:	094080e7          	jalr	148(ra) # cc <strlen>
  40:	0005061b          	sext.w	a2,a0
  44:	85ca                	mv	a1,s2
  46:	4505                	li	a0,1
  48:	00000097          	auipc	ra,0x0
  4c:	252080e7          	jalr	594(ra) # 29a <write>
    if(i + 1 < argc){
  50:	04a1                	addi	s1,s1,8
  52:	01348a63          	beq	s1,s3,66 <main+0x66>
      write(1, " ", 1);
  56:	4605                	li	a2,1
  58:	85d2                	mv	a1,s4
  5a:	4505                	li	a0,1
  5c:	00000097          	auipc	ra,0x0
  60:	23e080e7          	jalr	574(ra) # 29a <write>
  for(i = 1; i < argc; i++){
  64:	b7f9                	j	32 <main+0x32>
    } else {
      write(1, "\n", 1);
  66:	4605                	li	a2,1
  68:	00000597          	auipc	a1,0x0
  6c:	74858593          	addi	a1,a1,1864 # 7b0 <malloc+0xf0>
  70:	4505                	li	a0,1
  72:	00000097          	auipc	ra,0x0
  76:	228080e7          	jalr	552(ra) # 29a <write>
    }
  }
  exit(0);
  7a:	4501                	li	a0,0
  7c:	00000097          	auipc	ra,0x0
  80:	1fe080e7          	jalr	510(ra) # 27a <exit>

0000000000000084 <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
  84:	1141                	addi	sp,sp,-16
  86:	e422                	sd	s0,8(sp)
  88:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  8a:	87aa                	mv	a5,a0
  8c:	0585                	addi	a1,a1,1
  8e:	0785                	addi	a5,a5,1
  90:	fff5c703          	lbu	a4,-1(a1)
  94:	fee78fa3          	sb	a4,-1(a5)
  98:	fb75                	bnez	a4,8c <strcpy+0x8>
    ;
  return os;
}
  9a:	6422                	ld	s0,8(sp)
  9c:	0141                	addi	sp,sp,16
  9e:	8082                	ret

00000000000000a0 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  a0:	1141                	addi	sp,sp,-16
  a2:	e422                	sd	s0,8(sp)
  a4:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
  a6:	00054783          	lbu	a5,0(a0)
  aa:	cb91                	beqz	a5,be <strcmp+0x1e>
  ac:	0005c703          	lbu	a4,0(a1)
  b0:	00f71763          	bne	a4,a5,be <strcmp+0x1e>
    p++, q++;
  b4:	0505                	addi	a0,a0,1
  b6:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
  b8:	00054783          	lbu	a5,0(a0)
  bc:	fbe5                	bnez	a5,ac <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
  be:	0005c503          	lbu	a0,0(a1)
}
  c2:	40a7853b          	subw	a0,a5,a0
  c6:	6422                	ld	s0,8(sp)
  c8:	0141                	addi	sp,sp,16
  ca:	8082                	ret

00000000000000cc <strlen>:

uint
strlen(const char *s)
{
  cc:	1141                	addi	sp,sp,-16
  ce:	e422                	sd	s0,8(sp)
  d0:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
  d2:	00054783          	lbu	a5,0(a0)
  d6:	cf91                	beqz	a5,f2 <strlen+0x26>
  d8:	0505                	addi	a0,a0,1
  da:	87aa                	mv	a5,a0
  dc:	4685                	li	a3,1
  de:	9e89                	subw	a3,a3,a0
  e0:	00f6853b          	addw	a0,a3,a5
  e4:	0785                	addi	a5,a5,1
  e6:	fff7c703          	lbu	a4,-1(a5)
  ea:	fb7d                	bnez	a4,e0 <strlen+0x14>
    ;
  return n;
}
  ec:	6422                	ld	s0,8(sp)
  ee:	0141                	addi	sp,sp,16
  f0:	8082                	ret
  for(n = 0; s[n]; n++)
  f2:	4501                	li	a0,0
  f4:	bfe5                	j	ec <strlen+0x20>

00000000000000f6 <memset>:

void*
memset(void *dst, int c, uint n)
{
  f6:	1141                	addi	sp,sp,-16
  f8:	e422                	sd	s0,8(sp)
  fa:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
  fc:	ce09                	beqz	a2,116 <memset+0x20>
  fe:	87aa                	mv	a5,a0
 100:	fff6071b          	addiw	a4,a2,-1
 104:	1702                	slli	a4,a4,0x20
 106:	9301                	srli	a4,a4,0x20
 108:	0705                	addi	a4,a4,1
 10a:	972a                	add	a4,a4,a0
    cdst[i] = c;
 10c:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 110:	0785                	addi	a5,a5,1
 112:	fee79de3          	bne	a5,a4,10c <memset+0x16>
  }
  return dst;
}
 116:	6422                	ld	s0,8(sp)
 118:	0141                	addi	sp,sp,16
 11a:	8082                	ret

000000000000011c <strchr>:

char*
strchr(const char *s, char c)
{
 11c:	1141                	addi	sp,sp,-16
 11e:	e422                	sd	s0,8(sp)
 120:	0800                	addi	s0,sp,16
  for(; *s; s++)
 122:	00054783          	lbu	a5,0(a0)
 126:	cb99                	beqz	a5,13c <strchr+0x20>
    if(*s == c)
 128:	00f58763          	beq	a1,a5,136 <strchr+0x1a>
  for(; *s; s++)
 12c:	0505                	addi	a0,a0,1
 12e:	00054783          	lbu	a5,0(a0)
 132:	fbfd                	bnez	a5,128 <strchr+0xc>
      return (char*)s;
  return 0;
 134:	4501                	li	a0,0
}
 136:	6422                	ld	s0,8(sp)
 138:	0141                	addi	sp,sp,16
 13a:	8082                	ret
  return 0;
 13c:	4501                	li	a0,0
 13e:	bfe5                	j	136 <strchr+0x1a>

0000000000000140 <gets>:

char*
gets(char *buf, int max)
{
 140:	711d                	addi	sp,sp,-96
 142:	ec86                	sd	ra,88(sp)
 144:	e8a2                	sd	s0,80(sp)
 146:	e4a6                	sd	s1,72(sp)
 148:	e0ca                	sd	s2,64(sp)
 14a:	fc4e                	sd	s3,56(sp)
 14c:	f852                	sd	s4,48(sp)
 14e:	f456                	sd	s5,40(sp)
 150:	f05a                	sd	s6,32(sp)
 152:	ec5e                	sd	s7,24(sp)
 154:	1080                	addi	s0,sp,96
 156:	8baa                	mv	s7,a0
 158:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 15a:	892a                	mv	s2,a0
 15c:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 15e:	4aa9                	li	s5,10
 160:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 162:	89a6                	mv	s3,s1
 164:	2485                	addiw	s1,s1,1
 166:	0344d863          	bge	s1,s4,196 <gets+0x56>
    cc = read(0, &c, 1);
 16a:	4605                	li	a2,1
 16c:	faf40593          	addi	a1,s0,-81
 170:	4501                	li	a0,0
 172:	00000097          	auipc	ra,0x0
 176:	120080e7          	jalr	288(ra) # 292 <read>
    if(cc < 1)
 17a:	00a05e63          	blez	a0,196 <gets+0x56>
    buf[i++] = c;
 17e:	faf44783          	lbu	a5,-81(s0)
 182:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 186:	01578763          	beq	a5,s5,194 <gets+0x54>
 18a:	0905                	addi	s2,s2,1
 18c:	fd679be3          	bne	a5,s6,162 <gets+0x22>
  for(i=0; i+1 < max; ){
 190:	89a6                	mv	s3,s1
 192:	a011                	j	196 <gets+0x56>
 194:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 196:	99de                	add	s3,s3,s7
 198:	00098023          	sb	zero,0(s3)
  return buf;
}
 19c:	855e                	mv	a0,s7
 19e:	60e6                	ld	ra,88(sp)
 1a0:	6446                	ld	s0,80(sp)
 1a2:	64a6                	ld	s1,72(sp)
 1a4:	6906                	ld	s2,64(sp)
 1a6:	79e2                	ld	s3,56(sp)
 1a8:	7a42                	ld	s4,48(sp)
 1aa:	7aa2                	ld	s5,40(sp)
 1ac:	7b02                	ld	s6,32(sp)
 1ae:	6be2                	ld	s7,24(sp)
 1b0:	6125                	addi	sp,sp,96
 1b2:	8082                	ret

00000000000001b4 <stat>:

int
stat(const char *n, struct stat *st)
{
 1b4:	1101                	addi	sp,sp,-32
 1b6:	ec06                	sd	ra,24(sp)
 1b8:	e822                	sd	s0,16(sp)
 1ba:	e426                	sd	s1,8(sp)
 1bc:	e04a                	sd	s2,0(sp)
 1be:	1000                	addi	s0,sp,32
 1c0:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 1c2:	4581                	li	a1,0
 1c4:	00000097          	auipc	ra,0x0
 1c8:	0f6080e7          	jalr	246(ra) # 2ba <open>
  if(fd < 0)
 1cc:	02054563          	bltz	a0,1f6 <stat+0x42>
 1d0:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 1d2:	85ca                	mv	a1,s2
 1d4:	00000097          	auipc	ra,0x0
 1d8:	0fe080e7          	jalr	254(ra) # 2d2 <fstat>
 1dc:	892a                	mv	s2,a0
  close(fd);
 1de:	8526                	mv	a0,s1
 1e0:	00000097          	auipc	ra,0x0
 1e4:	0c2080e7          	jalr	194(ra) # 2a2 <close>
  return r;
}
 1e8:	854a                	mv	a0,s2
 1ea:	60e2                	ld	ra,24(sp)
 1ec:	6442                	ld	s0,16(sp)
 1ee:	64a2                	ld	s1,8(sp)
 1f0:	6902                	ld	s2,0(sp)
 1f2:	6105                	addi	sp,sp,32
 1f4:	8082                	ret
    return -1;
 1f6:	597d                	li	s2,-1
 1f8:	bfc5                	j	1e8 <stat+0x34>

00000000000001fa <atoi>:

int
atoi(const char *s)
{
 1fa:	1141                	addi	sp,sp,-16
 1fc:	e422                	sd	s0,8(sp)
 1fe:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 200:	00054603          	lbu	a2,0(a0)
 204:	fd06079b          	addiw	a5,a2,-48
 208:	0ff7f793          	andi	a5,a5,255
 20c:	4725                	li	a4,9
 20e:	02f76963          	bltu	a4,a5,240 <atoi+0x46>
 212:	86aa                	mv	a3,a0
  n = 0;
 214:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 216:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 218:	0685                	addi	a3,a3,1
 21a:	0025179b          	slliw	a5,a0,0x2
 21e:	9fa9                	addw	a5,a5,a0
 220:	0017979b          	slliw	a5,a5,0x1
 224:	9fb1                	addw	a5,a5,a2
 226:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 22a:	0006c603          	lbu	a2,0(a3)
 22e:	fd06071b          	addiw	a4,a2,-48
 232:	0ff77713          	andi	a4,a4,255
 236:	fee5f1e3          	bgeu	a1,a4,218 <atoi+0x1e>
  return n;
}
 23a:	6422                	ld	s0,8(sp)
 23c:	0141                	addi	sp,sp,16
 23e:	8082                	ret
  n = 0;
 240:	4501                	li	a0,0
 242:	bfe5                	j	23a <atoi+0x40>

0000000000000244 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 244:	1141                	addi	sp,sp,-16
 246:	e422                	sd	s0,8(sp)
 248:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 24a:	02c05163          	blez	a2,26c <memmove+0x28>
 24e:	fff6071b          	addiw	a4,a2,-1
 252:	1702                	slli	a4,a4,0x20
 254:	9301                	srli	a4,a4,0x20
 256:	0705                	addi	a4,a4,1
 258:	972a                	add	a4,a4,a0
  dst = vdst;
 25a:	87aa                	mv	a5,a0
    *dst++ = *src++;
 25c:	0585                	addi	a1,a1,1
 25e:	0785                	addi	a5,a5,1
 260:	fff5c683          	lbu	a3,-1(a1)
 264:	fed78fa3          	sb	a3,-1(a5)
  while(n-- > 0)
 268:	fee79ae3          	bne	a5,a4,25c <memmove+0x18>
  return vdst;
}
 26c:	6422                	ld	s0,8(sp)
 26e:	0141                	addi	sp,sp,16
 270:	8082                	ret

0000000000000272 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 272:	4885                	li	a7,1
 ecall
 274:	00000073          	ecall
 ret
 278:	8082                	ret

000000000000027a <exit>:
.global exit
exit:
 li a7, SYS_exit
 27a:	4889                	li	a7,2
 ecall
 27c:	00000073          	ecall
 ret
 280:	8082                	ret

0000000000000282 <wait>:
.global wait
wait:
 li a7, SYS_wait
 282:	488d                	li	a7,3
 ecall
 284:	00000073          	ecall
 ret
 288:	8082                	ret

000000000000028a <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 28a:	4891                	li	a7,4
 ecall
 28c:	00000073          	ecall
 ret
 290:	8082                	ret

0000000000000292 <read>:
.global read
read:
 li a7, SYS_read
 292:	4895                	li	a7,5
 ecall
 294:	00000073          	ecall
 ret
 298:	8082                	ret

000000000000029a <write>:
.global write
write:
 li a7, SYS_write
 29a:	48c1                	li	a7,16
 ecall
 29c:	00000073          	ecall
 ret
 2a0:	8082                	ret

00000000000002a2 <close>:
.global close
close:
 li a7, SYS_close
 2a2:	48d5                	li	a7,21
 ecall
 2a4:	00000073          	ecall
 ret
 2a8:	8082                	ret

00000000000002aa <kill>:
.global kill
kill:
 li a7, SYS_kill
 2aa:	4899                	li	a7,6
 ecall
 2ac:	00000073          	ecall
 ret
 2b0:	8082                	ret

00000000000002b2 <exec>:
.global exec
exec:
 li a7, SYS_exec
 2b2:	489d                	li	a7,7
 ecall
 2b4:	00000073          	ecall
 ret
 2b8:	8082                	ret

00000000000002ba <open>:
.global open
open:
 li a7, SYS_open
 2ba:	48bd                	li	a7,15
 ecall
 2bc:	00000073          	ecall
 ret
 2c0:	8082                	ret

00000000000002c2 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 2c2:	48c5                	li	a7,17
 ecall
 2c4:	00000073          	ecall
 ret
 2c8:	8082                	ret

00000000000002ca <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 2ca:	48c9                	li	a7,18
 ecall
 2cc:	00000073          	ecall
 ret
 2d0:	8082                	ret

00000000000002d2 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 2d2:	48a1                	li	a7,8
 ecall
 2d4:	00000073          	ecall
 ret
 2d8:	8082                	ret

00000000000002da <link>:
.global link
link:
 li a7, SYS_link
 2da:	48cd                	li	a7,19
 ecall
 2dc:	00000073          	ecall
 ret
 2e0:	8082                	ret

00000000000002e2 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 2e2:	48d1                	li	a7,20
 ecall
 2e4:	00000073          	ecall
 ret
 2e8:	8082                	ret

00000000000002ea <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 2ea:	48a5                	li	a7,9
 ecall
 2ec:	00000073          	ecall
 ret
 2f0:	8082                	ret

00000000000002f2 <dup>:
.global dup
dup:
 li a7, SYS_dup
 2f2:	48a9                	li	a7,10
 ecall
 2f4:	00000073          	ecall
 ret
 2f8:	8082                	ret

00000000000002fa <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 2fa:	48ad                	li	a7,11
 ecall
 2fc:	00000073          	ecall
 ret
 300:	8082                	ret

0000000000000302 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 302:	48b1                	li	a7,12
 ecall
 304:	00000073          	ecall
 ret
 308:	8082                	ret

000000000000030a <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 30a:	48b5                	li	a7,13
 ecall
 30c:	00000073          	ecall
 ret
 310:	8082                	ret

0000000000000312 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 312:	48b9                	li	a7,14
 ecall
 314:	00000073          	ecall
 ret
 318:	8082                	ret

000000000000031a <traceon>:
.global traceon
traceon:
 li a7, SYS_traceon
 31a:	48d9                	li	a7,22
 ecall
 31c:	00000073          	ecall
 ret
 320:	8082                	ret

0000000000000322 <ps>:
.global ps
ps:
 li a7, SYS_ps
 322:	48dd                	li	a7,23
 ecall
 324:	00000073          	ecall
 ret
 328:	8082                	ret

000000000000032a <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 32a:	1101                	addi	sp,sp,-32
 32c:	ec06                	sd	ra,24(sp)
 32e:	e822                	sd	s0,16(sp)
 330:	1000                	addi	s0,sp,32
 332:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 336:	4605                	li	a2,1
 338:	fef40593          	addi	a1,s0,-17
 33c:	00000097          	auipc	ra,0x0
 340:	f5e080e7          	jalr	-162(ra) # 29a <write>
}
 344:	60e2                	ld	ra,24(sp)
 346:	6442                	ld	s0,16(sp)
 348:	6105                	addi	sp,sp,32
 34a:	8082                	ret

000000000000034c <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 34c:	7139                	addi	sp,sp,-64
 34e:	fc06                	sd	ra,56(sp)
 350:	f822                	sd	s0,48(sp)
 352:	f426                	sd	s1,40(sp)
 354:	f04a                	sd	s2,32(sp)
 356:	ec4e                	sd	s3,24(sp)
 358:	0080                	addi	s0,sp,64
 35a:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 35c:	c299                	beqz	a3,362 <printint+0x16>
 35e:	0805c863          	bltz	a1,3ee <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 362:	2581                	sext.w	a1,a1
  neg = 0;
 364:	4881                	li	a7,0
 366:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 36a:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 36c:	2601                	sext.w	a2,a2
 36e:	00000517          	auipc	a0,0x0
 372:	45250513          	addi	a0,a0,1106 # 7c0 <digits>
 376:	883a                	mv	a6,a4
 378:	2705                	addiw	a4,a4,1
 37a:	02c5f7bb          	remuw	a5,a1,a2
 37e:	1782                	slli	a5,a5,0x20
 380:	9381                	srli	a5,a5,0x20
 382:	97aa                	add	a5,a5,a0
 384:	0007c783          	lbu	a5,0(a5)
 388:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 38c:	0005879b          	sext.w	a5,a1
 390:	02c5d5bb          	divuw	a1,a1,a2
 394:	0685                	addi	a3,a3,1
 396:	fec7f0e3          	bgeu	a5,a2,376 <printint+0x2a>
  if(neg)
 39a:	00088b63          	beqz	a7,3b0 <printint+0x64>
    buf[i++] = '-';
 39e:	fd040793          	addi	a5,s0,-48
 3a2:	973e                	add	a4,a4,a5
 3a4:	02d00793          	li	a5,45
 3a8:	fef70823          	sb	a5,-16(a4)
 3ac:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 3b0:	02e05863          	blez	a4,3e0 <printint+0x94>
 3b4:	fc040793          	addi	a5,s0,-64
 3b8:	00e78933          	add	s2,a5,a4
 3bc:	fff78993          	addi	s3,a5,-1
 3c0:	99ba                	add	s3,s3,a4
 3c2:	377d                	addiw	a4,a4,-1
 3c4:	1702                	slli	a4,a4,0x20
 3c6:	9301                	srli	a4,a4,0x20
 3c8:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 3cc:	fff94583          	lbu	a1,-1(s2)
 3d0:	8526                	mv	a0,s1
 3d2:	00000097          	auipc	ra,0x0
 3d6:	f58080e7          	jalr	-168(ra) # 32a <putc>
  while(--i >= 0)
 3da:	197d                	addi	s2,s2,-1
 3dc:	ff3918e3          	bne	s2,s3,3cc <printint+0x80>
}
 3e0:	70e2                	ld	ra,56(sp)
 3e2:	7442                	ld	s0,48(sp)
 3e4:	74a2                	ld	s1,40(sp)
 3e6:	7902                	ld	s2,32(sp)
 3e8:	69e2                	ld	s3,24(sp)
 3ea:	6121                	addi	sp,sp,64
 3ec:	8082                	ret
    x = -xx;
 3ee:	40b005bb          	negw	a1,a1
    neg = 1;
 3f2:	4885                	li	a7,1
    x = -xx;
 3f4:	bf8d                	j	366 <printint+0x1a>

00000000000003f6 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 3f6:	7119                	addi	sp,sp,-128
 3f8:	fc86                	sd	ra,120(sp)
 3fa:	f8a2                	sd	s0,112(sp)
 3fc:	f4a6                	sd	s1,104(sp)
 3fe:	f0ca                	sd	s2,96(sp)
 400:	ecce                	sd	s3,88(sp)
 402:	e8d2                	sd	s4,80(sp)
 404:	e4d6                	sd	s5,72(sp)
 406:	e0da                	sd	s6,64(sp)
 408:	fc5e                	sd	s7,56(sp)
 40a:	f862                	sd	s8,48(sp)
 40c:	f466                	sd	s9,40(sp)
 40e:	f06a                	sd	s10,32(sp)
 410:	ec6e                	sd	s11,24(sp)
 412:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 414:	0005c903          	lbu	s2,0(a1)
 418:	18090f63          	beqz	s2,5b6 <vprintf+0x1c0>
 41c:	8aaa                	mv	s5,a0
 41e:	8b32                	mv	s6,a2
 420:	00158493          	addi	s1,a1,1
  state = 0;
 424:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 426:	02500a13          	li	s4,37
      if(c == 'd'){
 42a:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 42e:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 432:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 436:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 43a:	00000b97          	auipc	s7,0x0
 43e:	386b8b93          	addi	s7,s7,902 # 7c0 <digits>
 442:	a839                	j	460 <vprintf+0x6a>
        putc(fd, c);
 444:	85ca                	mv	a1,s2
 446:	8556                	mv	a0,s5
 448:	00000097          	auipc	ra,0x0
 44c:	ee2080e7          	jalr	-286(ra) # 32a <putc>
 450:	a019                	j	456 <vprintf+0x60>
    } else if(state == '%'){
 452:	01498f63          	beq	s3,s4,470 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 456:	0485                	addi	s1,s1,1
 458:	fff4c903          	lbu	s2,-1(s1)
 45c:	14090d63          	beqz	s2,5b6 <vprintf+0x1c0>
    c = fmt[i] & 0xff;
 460:	0009079b          	sext.w	a5,s2
    if(state == 0){
 464:	fe0997e3          	bnez	s3,452 <vprintf+0x5c>
      if(c == '%'){
 468:	fd479ee3          	bne	a5,s4,444 <vprintf+0x4e>
        state = '%';
 46c:	89be                	mv	s3,a5
 46e:	b7e5                	j	456 <vprintf+0x60>
      if(c == 'd'){
 470:	05878063          	beq	a5,s8,4b0 <vprintf+0xba>
      } else if(c == 'l') {
 474:	05978c63          	beq	a5,s9,4cc <vprintf+0xd6>
      } else if(c == 'x') {
 478:	07a78863          	beq	a5,s10,4e8 <vprintf+0xf2>
      } else if(c == 'p') {
 47c:	09b78463          	beq	a5,s11,504 <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 480:	07300713          	li	a4,115
 484:	0ce78663          	beq	a5,a4,550 <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 488:	06300713          	li	a4,99
 48c:	0ee78e63          	beq	a5,a4,588 <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 490:	11478863          	beq	a5,s4,5a0 <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 494:	85d2                	mv	a1,s4
 496:	8556                	mv	a0,s5
 498:	00000097          	auipc	ra,0x0
 49c:	e92080e7          	jalr	-366(ra) # 32a <putc>
        putc(fd, c);
 4a0:	85ca                	mv	a1,s2
 4a2:	8556                	mv	a0,s5
 4a4:	00000097          	auipc	ra,0x0
 4a8:	e86080e7          	jalr	-378(ra) # 32a <putc>
      }
      state = 0;
 4ac:	4981                	li	s3,0
 4ae:	b765                	j	456 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 4b0:	008b0913          	addi	s2,s6,8
 4b4:	4685                	li	a3,1
 4b6:	4629                	li	a2,10
 4b8:	000b2583          	lw	a1,0(s6)
 4bc:	8556                	mv	a0,s5
 4be:	00000097          	auipc	ra,0x0
 4c2:	e8e080e7          	jalr	-370(ra) # 34c <printint>
 4c6:	8b4a                	mv	s6,s2
      state = 0;
 4c8:	4981                	li	s3,0
 4ca:	b771                	j	456 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 4cc:	008b0913          	addi	s2,s6,8
 4d0:	4681                	li	a3,0
 4d2:	4629                	li	a2,10
 4d4:	000b2583          	lw	a1,0(s6)
 4d8:	8556                	mv	a0,s5
 4da:	00000097          	auipc	ra,0x0
 4de:	e72080e7          	jalr	-398(ra) # 34c <printint>
 4e2:	8b4a                	mv	s6,s2
      state = 0;
 4e4:	4981                	li	s3,0
 4e6:	bf85                	j	456 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 4e8:	008b0913          	addi	s2,s6,8
 4ec:	4681                	li	a3,0
 4ee:	4641                	li	a2,16
 4f0:	000b2583          	lw	a1,0(s6)
 4f4:	8556                	mv	a0,s5
 4f6:	00000097          	auipc	ra,0x0
 4fa:	e56080e7          	jalr	-426(ra) # 34c <printint>
 4fe:	8b4a                	mv	s6,s2
      state = 0;
 500:	4981                	li	s3,0
 502:	bf91                	j	456 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 504:	008b0793          	addi	a5,s6,8
 508:	f8f43423          	sd	a5,-120(s0)
 50c:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 510:	03000593          	li	a1,48
 514:	8556                	mv	a0,s5
 516:	00000097          	auipc	ra,0x0
 51a:	e14080e7          	jalr	-492(ra) # 32a <putc>
  putc(fd, 'x');
 51e:	85ea                	mv	a1,s10
 520:	8556                	mv	a0,s5
 522:	00000097          	auipc	ra,0x0
 526:	e08080e7          	jalr	-504(ra) # 32a <putc>
 52a:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 52c:	03c9d793          	srli	a5,s3,0x3c
 530:	97de                	add	a5,a5,s7
 532:	0007c583          	lbu	a1,0(a5)
 536:	8556                	mv	a0,s5
 538:	00000097          	auipc	ra,0x0
 53c:	df2080e7          	jalr	-526(ra) # 32a <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 540:	0992                	slli	s3,s3,0x4
 542:	397d                	addiw	s2,s2,-1
 544:	fe0914e3          	bnez	s2,52c <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 548:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 54c:	4981                	li	s3,0
 54e:	b721                	j	456 <vprintf+0x60>
        s = va_arg(ap, char*);
 550:	008b0993          	addi	s3,s6,8
 554:	000b3903          	ld	s2,0(s6)
        if(s == 0)
 558:	02090163          	beqz	s2,57a <vprintf+0x184>
        while(*s != 0){
 55c:	00094583          	lbu	a1,0(s2)
 560:	c9a1                	beqz	a1,5b0 <vprintf+0x1ba>
          putc(fd, *s);
 562:	8556                	mv	a0,s5
 564:	00000097          	auipc	ra,0x0
 568:	dc6080e7          	jalr	-570(ra) # 32a <putc>
          s++;
 56c:	0905                	addi	s2,s2,1
        while(*s != 0){
 56e:	00094583          	lbu	a1,0(s2)
 572:	f9e5                	bnez	a1,562 <vprintf+0x16c>
        s = va_arg(ap, char*);
 574:	8b4e                	mv	s6,s3
      state = 0;
 576:	4981                	li	s3,0
 578:	bdf9                	j	456 <vprintf+0x60>
          s = "(null)";
 57a:	00000917          	auipc	s2,0x0
 57e:	23e90913          	addi	s2,s2,574 # 7b8 <malloc+0xf8>
        while(*s != 0){
 582:	02800593          	li	a1,40
 586:	bff1                	j	562 <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
 588:	008b0913          	addi	s2,s6,8
 58c:	000b4583          	lbu	a1,0(s6)
 590:	8556                	mv	a0,s5
 592:	00000097          	auipc	ra,0x0
 596:	d98080e7          	jalr	-616(ra) # 32a <putc>
 59a:	8b4a                	mv	s6,s2
      state = 0;
 59c:	4981                	li	s3,0
 59e:	bd65                	j	456 <vprintf+0x60>
        putc(fd, c);
 5a0:	85d2                	mv	a1,s4
 5a2:	8556                	mv	a0,s5
 5a4:	00000097          	auipc	ra,0x0
 5a8:	d86080e7          	jalr	-634(ra) # 32a <putc>
      state = 0;
 5ac:	4981                	li	s3,0
 5ae:	b565                	j	456 <vprintf+0x60>
        s = va_arg(ap, char*);
 5b0:	8b4e                	mv	s6,s3
      state = 0;
 5b2:	4981                	li	s3,0
 5b4:	b54d                	j	456 <vprintf+0x60>
    }
  }
}
 5b6:	70e6                	ld	ra,120(sp)
 5b8:	7446                	ld	s0,112(sp)
 5ba:	74a6                	ld	s1,104(sp)
 5bc:	7906                	ld	s2,96(sp)
 5be:	69e6                	ld	s3,88(sp)
 5c0:	6a46                	ld	s4,80(sp)
 5c2:	6aa6                	ld	s5,72(sp)
 5c4:	6b06                	ld	s6,64(sp)
 5c6:	7be2                	ld	s7,56(sp)
 5c8:	7c42                	ld	s8,48(sp)
 5ca:	7ca2                	ld	s9,40(sp)
 5cc:	7d02                	ld	s10,32(sp)
 5ce:	6de2                	ld	s11,24(sp)
 5d0:	6109                	addi	sp,sp,128
 5d2:	8082                	ret

00000000000005d4 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 5d4:	715d                	addi	sp,sp,-80
 5d6:	ec06                	sd	ra,24(sp)
 5d8:	e822                	sd	s0,16(sp)
 5da:	1000                	addi	s0,sp,32
 5dc:	e010                	sd	a2,0(s0)
 5de:	e414                	sd	a3,8(s0)
 5e0:	e818                	sd	a4,16(s0)
 5e2:	ec1c                	sd	a5,24(s0)
 5e4:	03043023          	sd	a6,32(s0)
 5e8:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 5ec:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 5f0:	8622                	mv	a2,s0
 5f2:	00000097          	auipc	ra,0x0
 5f6:	e04080e7          	jalr	-508(ra) # 3f6 <vprintf>
}
 5fa:	60e2                	ld	ra,24(sp)
 5fc:	6442                	ld	s0,16(sp)
 5fe:	6161                	addi	sp,sp,80
 600:	8082                	ret

0000000000000602 <printf>:

void
printf(const char *fmt, ...)
{
 602:	711d                	addi	sp,sp,-96
 604:	ec06                	sd	ra,24(sp)
 606:	e822                	sd	s0,16(sp)
 608:	1000                	addi	s0,sp,32
 60a:	e40c                	sd	a1,8(s0)
 60c:	e810                	sd	a2,16(s0)
 60e:	ec14                	sd	a3,24(s0)
 610:	f018                	sd	a4,32(s0)
 612:	f41c                	sd	a5,40(s0)
 614:	03043823          	sd	a6,48(s0)
 618:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 61c:	00840613          	addi	a2,s0,8
 620:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 624:	85aa                	mv	a1,a0
 626:	4505                	li	a0,1
 628:	00000097          	auipc	ra,0x0
 62c:	dce080e7          	jalr	-562(ra) # 3f6 <vprintf>
}
 630:	60e2                	ld	ra,24(sp)
 632:	6442                	ld	s0,16(sp)
 634:	6125                	addi	sp,sp,96
 636:	8082                	ret

0000000000000638 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 638:	1141                	addi	sp,sp,-16
 63a:	e422                	sd	s0,8(sp)
 63c:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 63e:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 642:	00000797          	auipc	a5,0x0
 646:	1967b783          	ld	a5,406(a5) # 7d8 <freep>
 64a:	a805                	j	67a <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 64c:	4618                	lw	a4,8(a2)
 64e:	9db9                	addw	a1,a1,a4
 650:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 654:	6398                	ld	a4,0(a5)
 656:	6318                	ld	a4,0(a4)
 658:	fee53823          	sd	a4,-16(a0)
 65c:	a091                	j	6a0 <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 65e:	ff852703          	lw	a4,-8(a0)
 662:	9e39                	addw	a2,a2,a4
 664:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 666:	ff053703          	ld	a4,-16(a0)
 66a:	e398                	sd	a4,0(a5)
 66c:	a099                	j	6b2 <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 66e:	6398                	ld	a4,0(a5)
 670:	00e7e463          	bltu	a5,a4,678 <free+0x40>
 674:	00e6ea63          	bltu	a3,a4,688 <free+0x50>
{
 678:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 67a:	fed7fae3          	bgeu	a5,a3,66e <free+0x36>
 67e:	6398                	ld	a4,0(a5)
 680:	00e6e463          	bltu	a3,a4,688 <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 684:	fee7eae3          	bltu	a5,a4,678 <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 688:	ff852583          	lw	a1,-8(a0)
 68c:	6390                	ld	a2,0(a5)
 68e:	02059713          	slli	a4,a1,0x20
 692:	9301                	srli	a4,a4,0x20
 694:	0712                	slli	a4,a4,0x4
 696:	9736                	add	a4,a4,a3
 698:	fae60ae3          	beq	a2,a4,64c <free+0x14>
    bp->s.ptr = p->s.ptr;
 69c:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 6a0:	4790                	lw	a2,8(a5)
 6a2:	02061713          	slli	a4,a2,0x20
 6a6:	9301                	srli	a4,a4,0x20
 6a8:	0712                	slli	a4,a4,0x4
 6aa:	973e                	add	a4,a4,a5
 6ac:	fae689e3          	beq	a3,a4,65e <free+0x26>
  } else
    p->s.ptr = bp;
 6b0:	e394                	sd	a3,0(a5)
  freep = p;
 6b2:	00000717          	auipc	a4,0x0
 6b6:	12f73323          	sd	a5,294(a4) # 7d8 <freep>
}
 6ba:	6422                	ld	s0,8(sp)
 6bc:	0141                	addi	sp,sp,16
 6be:	8082                	ret

00000000000006c0 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 6c0:	7139                	addi	sp,sp,-64
 6c2:	fc06                	sd	ra,56(sp)
 6c4:	f822                	sd	s0,48(sp)
 6c6:	f426                	sd	s1,40(sp)
 6c8:	f04a                	sd	s2,32(sp)
 6ca:	ec4e                	sd	s3,24(sp)
 6cc:	e852                	sd	s4,16(sp)
 6ce:	e456                	sd	s5,8(sp)
 6d0:	e05a                	sd	s6,0(sp)
 6d2:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 6d4:	02051493          	slli	s1,a0,0x20
 6d8:	9081                	srli	s1,s1,0x20
 6da:	04bd                	addi	s1,s1,15
 6dc:	8091                	srli	s1,s1,0x4
 6de:	0014899b          	addiw	s3,s1,1
 6e2:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 6e4:	00000517          	auipc	a0,0x0
 6e8:	0f453503          	ld	a0,244(a0) # 7d8 <freep>
 6ec:	c515                	beqz	a0,718 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 6ee:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 6f0:	4798                	lw	a4,8(a5)
 6f2:	02977f63          	bgeu	a4,s1,730 <malloc+0x70>
 6f6:	8a4e                	mv	s4,s3
 6f8:	0009871b          	sext.w	a4,s3
 6fc:	6685                	lui	a3,0x1
 6fe:	00d77363          	bgeu	a4,a3,704 <malloc+0x44>
 702:	6a05                	lui	s4,0x1
 704:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 708:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 70c:	00000917          	auipc	s2,0x0
 710:	0cc90913          	addi	s2,s2,204 # 7d8 <freep>
  if(p == (char*)-1)
 714:	5afd                	li	s5,-1
 716:	a88d                	j	788 <malloc+0xc8>
    base.s.ptr = freep = prevp = &base;
 718:	00000797          	auipc	a5,0x0
 71c:	0c878793          	addi	a5,a5,200 # 7e0 <base>
 720:	00000717          	auipc	a4,0x0
 724:	0af73c23          	sd	a5,184(a4) # 7d8 <freep>
 728:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 72a:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 72e:	b7e1                	j	6f6 <malloc+0x36>
      if(p->s.size == nunits)
 730:	02e48b63          	beq	s1,a4,766 <malloc+0xa6>
        p->s.size -= nunits;
 734:	4137073b          	subw	a4,a4,s3
 738:	c798                	sw	a4,8(a5)
        p += p->s.size;
 73a:	1702                	slli	a4,a4,0x20
 73c:	9301                	srli	a4,a4,0x20
 73e:	0712                	slli	a4,a4,0x4
 740:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 742:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 746:	00000717          	auipc	a4,0x0
 74a:	08a73923          	sd	a0,146(a4) # 7d8 <freep>
      return (void*)(p + 1);
 74e:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 752:	70e2                	ld	ra,56(sp)
 754:	7442                	ld	s0,48(sp)
 756:	74a2                	ld	s1,40(sp)
 758:	7902                	ld	s2,32(sp)
 75a:	69e2                	ld	s3,24(sp)
 75c:	6a42                	ld	s4,16(sp)
 75e:	6aa2                	ld	s5,8(sp)
 760:	6b02                	ld	s6,0(sp)
 762:	6121                	addi	sp,sp,64
 764:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 766:	6398                	ld	a4,0(a5)
 768:	e118                	sd	a4,0(a0)
 76a:	bff1                	j	746 <malloc+0x86>
  hp->s.size = nu;
 76c:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 770:	0541                	addi	a0,a0,16
 772:	00000097          	auipc	ra,0x0
 776:	ec6080e7          	jalr	-314(ra) # 638 <free>
  return freep;
 77a:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 77e:	d971                	beqz	a0,752 <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 780:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 782:	4798                	lw	a4,8(a5)
 784:	fa9776e3          	bgeu	a4,s1,730 <malloc+0x70>
    if(p == freep)
 788:	00093703          	ld	a4,0(s2)
 78c:	853e                	mv	a0,a5
 78e:	fef719e3          	bne	a4,a5,780 <malloc+0xc0>
  p = sbrk(nu * sizeof(Header));
 792:	8552                	mv	a0,s4
 794:	00000097          	auipc	ra,0x0
 798:	b6e080e7          	jalr	-1170(ra) # 302 <sbrk>
  if(p == (char*)-1)
 79c:	fd5518e3          	bne	a0,s5,76c <malloc+0xac>
        return 0;
 7a0:	4501                	li	a0,0
 7a2:	bf45                	j	752 <malloc+0x92>
