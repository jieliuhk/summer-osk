struct cont {
	uint msz;	// Max size of memory (bytes)
	uint mdsk;	// Max amount of disk space (bytes)
	int mproc;	// Max amount of processes
	int upg;	// Used pages of memory
	uint udsk;	// Used disk space (blocks)
	int uproc;	// Used processes
	int cid;			// Container ID
	struct inode *rootdir;		// Root directory
	enum contstate state;		// State of container
	char name[16];          	// Container name
	struct proc *ptable;		// Table of processes owned by container
	int nextproc;			// Next proc to sched
};

