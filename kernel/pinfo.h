#ifndef PINFO_INCLUDE_
#define PINFO_INCLUDE_

#define MAX_PROC 64

struct pdata {
    volatile int    pid;            // Process ID
    uint            sz;             // Size of process memory (bytes) 
    char            name[16];       // Process name (debugging)
};

struct pinfo {
    uint            count;          // Number of running processes
    struct pdata    proc[MAX_PROC]; // Processes
};

#endif
