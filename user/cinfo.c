#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"
#include "kernel/cinfo.h"

int main(int argc, char *argv[]) {
    struct cinfo ci;
    int i, j;
    if(cinfo(&ci) < 0) {
        printf("\nCannot Print Cinfo");
    }
    printf("CID   Name     State    Process(U/M)    Mem(U/M)    Disk(U/M)\n");
    for(i = 0; i < ci.count; i++) {
        printf("------------------------------------------------------------------------- \n");
        printf("%d  |   %s       |  %d     |      %d/%d    |      %d/%d   |       %d/%d \n", ci.conts[i].cid, ci.conts[i].name, ci.conts[i].state, ci.conts[i].udproc, ci.conts[i].mproc, ci.conts[i].upg * 4096, ci.conts[i].msz, ci.conts[i].udsk, ci.conts[i].mdsk);
        
        printf("Process in container: \n");
        for(j = 0; j < ci.conts[i].procs.count; j++) {
            printf("PID = %d  ", ci.conts[i].procs.proc[j]);
        }
    }
    exit(0);
}
