#include "kernel/types.h"
#include "kernel/stat.h"
#include "kernel/riscv.h"
#include "user/user.h"

int main(int argc, char *argv[]) {
    int sz;
    sz = freesize();

    printf("\nfree memory size: %d KB (%d Pages)\n", sz / 1024, sz / PGSIZE);
    exit(0);
}
