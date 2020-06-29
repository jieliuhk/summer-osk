#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

int main(int argc, char *argv[])
{
    int id;
    int i;
    
    char * exec_argv[argc];
    
    for(i = 1; i < argc; i++) {
        exec_argv[i - 1] = argv[i];
    }

    id = fork();
   
    if (id == 0) {
        traceon();
        exec(argv[1], exec_argv);
        exit(0);
    } else {
        id = wait(0);
    }

    exit(0);
}
