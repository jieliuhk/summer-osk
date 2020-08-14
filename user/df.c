#include "kernel/types.h"
#include "kernel/stat.h"
#include "kernel/riscv.h"
#include "user/user.h"

int main(int argc, char *argv[]) {
    int sz;
    sz = freesize();

    printf("\nfree disk size: %d KB (%d Blocks)\n", sz, sz / 1024);
    exit(0);
}
