#pragma once
#ifndef timeutils_h
#define timeutils_h
#if defined(_MSC_VER)

#include <time.h>
//#include <Windows.h>

typedef unsigned int useconds_t;

/*
** @return 0 on success, -1 on error
*/
int usleep(useconds_t usec);
unsigned int sleep(unsigned int seconds);

enum { CLOCK_REALTIME, CLOCK_MONOTONIC, CLOCK_PROCESS_CPUTIME_ID, CLOCK_THREAD_CPUTIME_ID };
int clock_gettime(int what, struct timespec *tp);

//struct timeval {
//	long    tv_sec;         /* seconds */
//	long    tv_usec;        /* and microseconds */
//};

struct timezone {
	int  tz_minuteswest; /* minutes W of Greenwich */
	int  tz_dsttime;     /* type of dst correction */
};
//
//int gettimeofday(struct timeval *tv, struct timezone *tz);

#endif
#endif