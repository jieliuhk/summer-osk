#include "types.h"
#include "param.h"
#include "memlayout.h"
#include "riscv.h"
#include "spinlock.h"
#include "container.h"
#include "defs.h"
#include "stat.h"
#include "proc.h"

struct {
	struct spinlock lock;
	struct cont cont[NCONT];
} ctable;

int nextcid = 1;

// Look in the container table for an CUNUSED cont.
// If found, change state to CEMBRYO
// Otherwise return 0.
static struct cont*
alloccont(void)
{
	struct cont *c;

	acquire(&ctable.lock);

	for(c = ctable.cont; c < &ctable.cont[NCONT]; c++)
		if(c->state == CUNUSED)
		  goto found;

	release(&ctable.lock);
	return 0;

found:
	c->state = CEMBRYO;
	c->cid = nextcid++;
	c->nextcpid = 2;

	release(&ctable.lock);

	return c;
}

int
alloccpid(struct cont *cont) {
  int cpid;
  
  acquire(&cont->lock);
  cpid = cont->nextcpid;
  cont->nextcpid = cont->nextcpid + 1;
  release(&cont->lock);

  return cpid;
}

struct cont*
mycont() {
    struct cont *c;

    for(c = ctable.cont; c < &ctable.cont[NCONT]; c++)
        if(c->state == CUNUSED) {
	    return c;
	}

    return 0;
}

struct cont*
cid2cont(int cid)
{
    struct cont* c;
    int i;

    for (i = 0; i < NCONT; i++) {
        c = &ctable.cont[i];
    if (c->cid == cid && c->state != CUNUSED)
        return c;
    }
    return 0;
}

struct cont*
name2cont(char* name)
{
    struct cont* c;
    int i;

    for (i = 0; i < NCONT; i++) {
        c = &ctable.cont[i];
        if (strncmp(name, c->name, strlen(name)) == 0 && c->state != CUNUSED) {
            return c;
        }
    }
    return 0;
}

// Creates a container with the maximum procs, mem, and disk size
int 
ccreate(char* name, int mproc, uint64 msz, uint64 mdsk)
{
    struct cont *nc;
    struct inode* rootdir;

    // Check if container name already exists
    if (name2cont(name))
        return -1;

    // Check if wanted resources surpass available
    // TODO: Change with maxmem(), maxdsk()
    if (mproc > NPROC || msz > MAX_CONT_MEM || mdsk > MAX_CONT_DSK)
        return -1;

    // Allocate container.
    if ((nc = alloccont()) == 0)
        return -1;

    //set container root
    if ((rootdir = namei(name)) == 0) {
        nc->state = CUNUSED;
        return -1;
    }

    acquire(&ctable.lock);
    nc->mproc = mproc;
    nc->msz = msz;
    nc->mdsk = mdsk;
    nc->rootdir = idup(rootdir);
    strncpy(nc->name, name, 16);
    nc->state = CREADY;
    release(&ctable.lock);

    return 1;  
}

// Sets a container to be scheduled
int
cstart(char* name) 
{
    struct proc *p;
    struct cont *c;
    p = myproc();

    if((c = name2cont(name)) == 0) {
        printf("container %s not found", name); 
    }

    p->cwd = idup(c->rootdir);
    p->cont = c;

    return 0;
}
