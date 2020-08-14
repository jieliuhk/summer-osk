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

int
cp(char* dst, char* file)
{  
	char buffer[1024];
	int files[2];
	int count;
	int pathsize = strlen(dst) + strlen(file) + 2; // dst.len + '/' + src.len + \0
	char path[pathsize];

	memmove(path, dst, strlen(dst));
	memmove(path + strlen(dst), "/", 1);
	memmove(path + strlen(dst) + 1, file, strlen(file));
	memmove(path + strlen(dst) + 1 + strlen(file), "\0", 1);

	files[0] = open(file, O_RDONLY);
	if (files[0] == -1) // Check if file opened 
		return -1;
	
	files[1] = open(path, O_WRONLY | O_CREATE);
	if (files[1] == -1) { // Check if file opened (permissions problems ...) 
		printf("failed to create file |%s|\n", path);
		close(files[0]);
		return -1;
	}

	while ((count = read(files[0], buffer, sizeof(buffer))) != 0)
		write(files[1], buffer, count);

	return 1;
}

void create(char * name)
{
    if (mkdir(name) != 0) {
        printf("Error creating directory %s\n", name);
	exit(-1);
    }

    if (cp(name, "ls") != 1) 
        printf("Failed to copy ls");

    //if (cp(name, "rm") != 1) 
        //printf("Failed to copy rm");

    //if (cp(name, "mkdir") != 1)
        //printf("Failed to copy mkdir");

    if (cp(name, "ps") != 1) 
        printf("Failed to copy ps");

    if (cp(name, "sh") != 1)
        printf("Failed to copy sh");

    if (cp(name, "count") != 1) 
        printf("Failed to copy count");

    //if (cp(name, "suspend") != 1) 
        //printf("Failed to copy suspennd");

    //if (cp(name, "resume") != 1) 
        //printf("Failed to copy resume");

    //if (cp(name, "kill") != 1) 
        //printf("Failed to copy kill");

    //if (cp(name, "freesize") != 1) 
        //printf("Failed to copy freesize");
}

void start(char * name, char * vc, int maxproc, int maxmem, int maxdisk, char * prog)
{
    int fd, id;
    //char path[32];

    fd = open(vc, O_RDWR);
    ccreate(name);

    //memmove(path, "/", 1);
    //memmove(path + 1, name, strlen(name));
    //memmove(path + 1 + strlen(name), prog, strlen(prog));

    /* start new container by fork current process */
    id = fork();

    if (id == 0){
        close(0);
        close(1);
        close(2);
        dup(fd);
        dup(fd);
        dup(fd);
        cstart(name);
        exec(prog, &prog);
        exit(0);
    }

    printf("container %s started on %s\n", name, vc);
    exit(0);
}

int main(int argc, char *argv[])
{
    int maxproc,maxmem, maxdisk;

    if(argc < 3) {
        printf("invalid arguments\n");
        exit(0);
    }

    if(strncmp(argv[1],  "ccreate", 16) == 0) {
       create(argv[2]);
    } else if(strncmp(argv[1],  "cstart", 16) == 0) {
       if(argc == 4) {
           start(argv[2], argv[3], 8, 819200, 2048000, "sh");
       } else if (argc == 7) {
           maxproc = atoi(argv[4]);
           maxmem  = atoi(argv[5]); 
           maxdisk = atoi(argv[6]);
           start(argv[2], argv[3], maxproc, maxmem, maxdisk, "sh");
       } else {
           printf("invalid arguments");
       }
    } else if(strncmp(argv[1],  "cstop", 16) == 0) {
       cstop(argv[2]);
    } else {
        printf("command not found");
    }

    exit(0);
}

