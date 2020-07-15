#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

int main(int argc, char *argv[])
{
    int i = 0;

    while (1) {
        printf("i = %d\n", i);
        sleep(30);
        i = i + 1;
    }

    exit(0);
}
