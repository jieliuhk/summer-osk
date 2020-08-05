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
        printf("Failed to copy file");

    ccreate(name);
}

int main(int argc, char *argv[])
{
    if(argc != 3) {
        printf("invalid arguments\n");
        exit(0);
    }

    if(strncmp(argv[1],  "ccreate", 16) == 0) {
        create(argv[2]);
    } else if(strncmp(argv[1],  "cstart", 16) == 0) {
        cstart(argv[2]);
    } else {
        printf("command not found");
    }

    exit(0);
}

