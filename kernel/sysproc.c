#include "types.h"
#include "riscv.h"
#include "defs.h"
#include "date.h"
#include "param.h"
#include "memlayout.h"
#include "spinlock.h"
#include "proc.h"
#include "pinfo.h"

uint64
sys_exit(void)
{
  int n;
  if(argint(0, &n) < 0)
    return -1;

  if(myproc()->tracing) {
    printf("\n[%d]sys_exit(%d)", myproc()->pid, n);
  }

  exit(n);
  return 0;  // not reached
}

uint64
sys_getpid(void)
{
  if(myproc()->tracing) {
    printf("\n[%d]sys_getpid()", myproc()->pid);
  }

  return myproc()->pid;
}

uint64
sys_fork(void)
{
  if(myproc()->tracing) {
    printf("\n[%d]sys_fork()", myproc()->pid);
  }
  return fork();
}

uint64
sys_wait(void)
{
  uint64 p;
  if(argaddr(0, &p) < 0)
    return -1;

  if(myproc()->tracing) {
    printf("\n[%d]sys_wait(%d)", myproc()->pid, p);
  }

  return wait(p);
}

uint64
sys_sbrk(void)
{
  int addr;
  int n;

  if(argint(0, &n) < 0)
    return -1;

  if(myproc()->tracing) {
    printf("\n[%d]sys_sbrk(%d)", myproc()->pid, n);
  }

  addr = myproc()->sz;
  if(growproc(n) < 0)
    return -1;
  return addr;
}

uint64
sys_sleep(void)
{
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
    return -1;

  if(myproc()->tracing) {
    printf("\n[%d]sys_sleep(%d)", myproc()->pid, n);
  }

  acquire(&tickslock);
  ticks0 = ticks;
  while(ticks - ticks0 < n){
    if(myproc()->killed){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
  }
  release(&tickslock);
  return 0;
}

uint64
sys_kill(void)
{
  int pid;

  if(argint(0, &pid) < 0)
    return -1;

  if(myproc()->tracing){
    printf("\n[%d]sys_kill(%d)", myproc()->pid, pid);
  }

  return kill(pid);
}

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
  uint xticks;

  if(myproc()->tracing) {
    printf("\n[%d]sys_uptime()", myproc()->pid);
  }

  acquire(&tickslock);
  xticks = ticks;
  release(&tickslock);
  return xticks;
}

uint64
sys_traceon(void)
{
    traceon();
    return 0;
}

uint64
sys_ps(void)
{
    struct pinfo *pi;

    if(myproc()->tracing) {
        printf("[%d]ps", myproc()->pid);
    }

    printf("before get addr");
    if(argaddr(0, (void*)&pi) < 0) {
	return -1;
    }

    printf("before kps");
    kps(pi);
    printf("after kps");
    return 0;
}
