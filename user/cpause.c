#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"
#include "kernel/pinfo.h"
#include "kernel/fcntl.h"

int main(int argc, char *argv[]) {
    struct pinfo pinfo;
    char filename[16], id[1], *name;
    int rv;
    int fd;
    int i;

    if(argc != 2) {
        printf("invalid arguments\n");
        exit(-1);
    }

    name = argv[1];

    if(cpause(name, &pinfo) < 0) {
        printf("pause %d fail\n", name);
        exit(-1);
    }

    printf("count: %d \n", pinfo.count);

    for(i = 0, id[0] = '1'; i < pinfo.count; i++) {
        memmove(filename, "/", 1);
        memmove(filename + 1, name, strlen(name));
        memmove(filename + 1 + strlen(name), "/p", 2);
        memmove(filename + 3 + strlen(name), id, 1);

        id[0] += 1;

        printf("filename: %s \n", filename);

        fd = open(filename, O_CREATE | O_WRONLY);

        if(fd < 0) {
            printf("suspend cannot open %s. Exiting\n", filename);
	    exit(-1);
        }

        rv = suspend(pinfo.proc[i].pid, fd);

        close(fd);

        if(rv < 0) {
            printf("suspend(%d, %s) failed\n", pinfo.proc[i].pid, filename);
	    unlink(filename);
        } else {
            printf("suspend(%d, %s) success\n", pinfo.proc[i].pid, filename);
        }
    }
    
    exit(0);
}
