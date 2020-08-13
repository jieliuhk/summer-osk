// Physical memory allocator, for user processes,
// kernel stacks, page-table pages,
// and pipe buffers. Allocates whole 4096-byte pages.

#include "types.h"
#include "param.h"
#include "memlayout.h"
#include "spinlock.h"
#include "riscv.h"
#include "defs.h"
#include "proc.h"
#include "container.h"

void freerange(void *pa_start, void *pa_end);

extern char end[]; // first address after kernel.
                   // defined by kernel.ld.

int phymemfree;

struct run {
  struct run *next;
};

struct {
  struct spinlock lock;
  struct run *freelist;
} kmem;

int
kfreesize() {
  return phymemfree;
}

void
kinit()
{
  initlock(&kmem.lock, "kmem");
  phymemfree = 0;
  freerange(end, (void*)PHYSTOP);
}

void
freerange(void *pa_start, void *pa_end)
{
  char *p;
  p = (char*)PGROUNDUP((uint64)pa_start);
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    kfree(p);
}

// Free the page of physical memory pointed at by v,
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
  struct run *r;
  struct proc *p;
  struct cont *c;

  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);

  r = (struct run*)pa;

  acquire(&kmem.lock);
  r->next = kmem.freelist;
  kmem.freelist = r;
  release(&kmem.lock);
  phymemfree += PGSIZE;

  p = myproc();
  
  if(p != 0 && p->cont != 0) {
     c = p->cont;
     acquire(&c->lock);
     if((c->upg - 1) >= 0) {
       c->upg -= 1;
     }
     release(&c->lock);
  }
}

// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
  struct run *r;
  struct proc *p;
  struct cont *c;
  int maxpg;

  p = myproc();

  if(p !=0 && p->cont != 0) {
     c = p->cont;
     acquire(&c->lock);
     maxpg = (c->msz) / PGSIZE;
     if((c->upg + 1) > maxpg) {
        printf("\nNot enough memory for container %s", c->name);
        return 0;
     }
     c->upg += 1;
     release(&c->lock);
  }

  acquire(&kmem.lock);
  r = kmem.freelist;
  if(r)
    kmem.freelist = r->next;
  release(&kmem.lock);

  if(r)
    memset((char*)r, 5, PGSIZE); // fill with junki

  if(r)
    phymemfree -= PGSIZE;
  
  return (void*)r;
}
