#include "kernel/types.h"
#include "kernel/stat.h"
#include "kernel/fcntl.h"
#include "user/user.h"

int main(int argc, char *argv[])
{
    int pid;
    char *filename;
    int rv;
    int fd;

    if(argc != 3) {
        printf("invalid arguments\n");
        exit(0);
    }

    pid = atoi(argv[1]);
    filename = argv[2];

    fd = open(filename, O_CREATE | O_WRONLY);

    if(fd < 0) {
        printf("suspend cannot open %s. Exiting\n", filename);
	exit(-1);
    }

    rv = suspend(pid, fd);

    close(fd);

    if(rv < 0) {
        printf("suspend(%d, %s) failed\n", pid, filename);
	unlink(filename);
    } else {
        printf("suspend(%d, %s) success\n", pid, filename);
    }

    exit(0);
}

