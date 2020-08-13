struct cdata {
    int msz;			// Max size of memory (bytes)
    int mdsk;			// Max amount of disk space (bytes)
    int mproc;			// Max amount of processes
    int udproc;			// Used processes
    int upg;			// Used pages of memory
    int udsk;			// Used disk space (blocks)
    int uproc;			// Used processes
    int cid;			// Container ID
    int nextcpid;		// Next containerized pid
    int state;		        // State of container
    char name[16];          	// Container name
    int nextproc;		// Next proc to sched
};

struct cinfo {
    uint    count;
    struct  cdata conts[20];
};
