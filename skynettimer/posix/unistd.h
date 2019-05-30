#pragma once
#ifndef unistd_h
#define unistd_h

#include <time.h>
#if defined(USE_PTHREAD)
#include <sched.h>
#else
typedef int pid_t;
#endif

typedef int ssize_t;

#ifndef inline
#define inline __inline
#endif

long int random(void);
void srandom(unsigned int seed);

pid_t getpid();
int kill(pid_t pid, int exit_code);

/**********************************************************************************************/

typedef struct {
	unsigned long sig[128];
} sigset_t;

typedef int siginfo_t;
enum { SIGPIPE, SIGHUP, SA_RESTART };

struct sigaction {
	void(*sa_handler)(int);
	void(*sa_sigaction)(int, siginfo_t *, void *);
	sigset_t sa_mask;
	int sa_flags;
	void(*sa_restorer)(void);
};

void sigfillset(int *flag);
int sigaction(int signo, struct sigaction *act, struct sigaction *oact);
int sigemptyset(sigset_t *set);

/*
** daemon
*/
int daemon(int a, int b);

enum { LOCK_EX, LOCK_NB };
int flock(int fd, int flag);

/*
** sim pipe
*/
int pipe(int fd[2]);

ssize_t write(int fd, const void *buf, size_t count);
ssize_t read(int fd, void *buf, size_t count);
int close(int fd);

//__declspec(dllimport) int __stdcall gethostname(char *buffer, int len);

/*
** util function
*/
char *strsep(char **stringp, const char *delim);

const char *strwsaerror(int err);
const char *strsyserror(int err);
#endif