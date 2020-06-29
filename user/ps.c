#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"
#include "kernel/pinfo.h"

int main(int argc, char *argv[]) {
    struct pinfo pi;
    int i;
    ps(&pi);
    printf("PID  Size    Name\n");
    for(i = 0; i < pi.count; i++) {
        printf("%d | %d | %s\n", pi.proc[i].pid, pi.proc[i].sz, pi.proc[i].name);
    }
    exit(0);
}
