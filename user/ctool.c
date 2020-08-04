#include "kernel/types.h"
#include "kernel/stat.h"
#include "kernel/fcntl.h"
#include "user/user.h"

int strncmp(const char *p, const char *q, uint n)
{
    while(n > 0 && *p && *p == *q)
      n--, p++, q++;
    if(n == 0)
      return 0;
    return (uchar)*p - (uchar)*q;
}

int main(int argc, char *argv[])
{
    if(argc != 3) {
        printf("invalid arguments\n");
        exit(0);
    }

    if(strncmp(argv[1],  "ccreate", 16) == 0) {
        ccreate(argv[2]);
    } else if(strncmp(argv[1],  "cstart", 16) == 0) {
        cstart(argv[2]);
    } else {
        printf("command not found");
    }

    exit(0);
}

