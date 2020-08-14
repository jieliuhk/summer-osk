enum contstate { CUNUSED, CEMBRYO, CREADY, CRUNNING, CPAUSED};

struct cont {
    struct spinlock lock;
	
    int msz;			// Max size of memory (bytes)
    int mdsk;			// Max amount of disk space (bytes)
    int mproc;			// Max amount of processes
    int udproc;			// Used processes
    int upg;			// Used pages of memory
    int udsk;			// Used disk space (blocks)
    int uproc;			// Used processes
    int cid;			// Container ID
    int nextcpid;		// Next containerized pid
    struct inode *rootdir;	// Root directory
    enum contstate state;	// State of container
    char name[16];          	// Container name
    struct proc *ptable;	// Table of processes owned by container
    int nextproc;		// Next proc to sched
};


