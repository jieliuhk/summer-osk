#include "kernel/types.h"
#include "kernel/stat.h"
#include "kernel/fcntl.h"
#include "user/user.h"


int main(int argc, char *argv[])
{
    int id;

    if(argc != 2) {
        printf("invalid arguments\n");
        exit(0);
    }

    id = fork();

    if(id == 0) {
        resume(argv[1]);
    }

    exit(0);
}

