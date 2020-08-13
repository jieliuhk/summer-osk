#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"
#include "kernel/cinfo.h"

int main(int argc, char *argv[]) {
    struct cinfo ci;
    int i;
    if(cinfo(&ci) < 0) {
        printf("\nCannot Print Cinfo");
    }
    printf("CID   Name     State       Used Process\n");
    for(i = 0; i < ci.count; i++) {
        printf("%d  |   %s       |  %d    | %d \n", ci.conts[i].cid, ci.conts[i].name, ci.conts[i].state, ci.conts[i].msz);
    }
    exit(0);
}
