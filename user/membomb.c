#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

#define KB 1024
#define ALLOCMB 50
#define ALLOCSIZE (ALLOCMB * KB)

int
main(int argc, char *argv[])
{
  int totalmb = 0;
  char *p;

  printf("membomb: started\n");
  while(1) {
    p = (char *) malloc(ALLOCSIZE);
    if (p == 0) {
      printf("membomb: malloc() failed, exiting\n");
      exit(0);
    }    
    totalmb += ALLOCMB;

    printf("membomb: total memory allocated: %d MB\n", totalmb);
  }

  exit(0);
}
