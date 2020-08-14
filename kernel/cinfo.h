struct cpinfo {
    uint            count;          // Number of running processes
    int    	    proc[16]; 	    // Processes
};

struct cdata {
    int msz;			// Max size of memory (bytes)
    int mdsk;			// Max amount of disk space (bytes)
    int mproc;			// Max amount of processes
    int udproc;			// Used processes
    int upg;			// Used pages of memory
    int udsk;			// Used disk space (blocks)
    int cid;			// Container ID
    int state;		        // State of container
    char name[16];          	// Container name
    struct cpinfo procs;		// process procs
};

struct cinfo {
    uint    count;
    struct  cdata conts[20];
};
