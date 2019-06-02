#define _WINSOCK_DEPRECATED_NO_WARNINGS
#define WIN32_LEAN_AND_MEAN

#if defined(_MSC_VER)

#include "Win32_Extras.h"
#include <WinSock2.h>
//#include <Windows.h>
#include <assert.h>
#if defined(_MSC_VER) || defined(_MSC_EXTENSIONS)
#define DELTA_EPOCH_IN_MICROSECS  11644473600000000Ui64
#else
#define DELTA_EPOCH_IN_MICROSECS  11644473600000000ULL
#endif

#define NANOSEC  (1000000000)
#define MICROSEC (1000000)

int usleep(useconds_t usec) {
	if (usec > 1000) {
		Sleep(usec / 1000);
		return 0;
	}
	// spin
	LARGE_INTEGER freq;
	QueryPerformanceFrequency(&freq);
	LARGE_INTEGER start, end;
	QueryPerformanceCounter(&start);
	for (;;) {
		QueryPerformanceCounter(&end);
		long long p = (start.QuadPart - end.QuadPart) * MICROSEC / freq.QuadPart;
		if (p >= usec) {
			break;
		}
	}
	return 0;
}

unsigned int sleep(unsigned int seconds) {
	Sleep(seconds * 1000);
	return 0;
}

int clock_gettime(int what, struct timespec *tp) {
	switch(what) {
	case CLOCK_MONOTONIC:
	{
		static LARGE_INTEGER freq;
		static int init = 0;
		if (init == 0) {
			init = 1;
			QueryPerformanceFrequency(&freq);
		}
		LARGE_INTEGER cur;
		QueryPerformanceCounter(&cur);
		tp->tv_sec = cur.QuadPart / freq.QuadPart; // sec
		tp->tv_nsec = cur.QuadPart % freq.QuadPart * NANOSEC / freq.QuadPart;
		return 0;
	}
	case CLOCK_REALTIME: {
		SYSTEMTIME st;
		GetLocalTime(&st);
		tp->tv_sec = time(NULL);
		tp->tv_nsec = st.wMilliseconds * 1000000;
		return 0;
	}
	case CLOCK_THREAD_CPUTIME_ID: {
		LARGE_INTEGER freq, cur;
		QueryPerformanceFrequency(&freq);
		QueryPerformanceCounter(&cur);
		tp->tv_sec = cur.QuadPart / freq.QuadPart; // sec
		tp->tv_nsec = cur.QuadPart % freq.QuadPart * NANOSEC / freq.QuadPart;
		return 0;
	}
	default:
		return -1;
	}
	return -1;
}

int gettimeofday(struct timeval *tv, struct timezone *tz) {
	FILETIME ft;
	unsigned __int64 tmpres = 0;
	static int tzflag;

	if (NULL != tv) {
		GetSystemTimeAsFileTime(&ft);

		tmpres |= ft.dwHighDateTime;
		tmpres <<= 32;
		tmpres |= ft.dwLowDateTime;

		/*converting file time to unix epoch*/
		tmpres -= DELTA_EPOCH_IN_MICROSECS;
		tmpres /= 10;  /*convert into microseconds*/
		tv->tv_sec = (long)(tmpres / 1000000UL);
		tv->tv_usec = (long)(tmpres % 1000000UL);
	}

	if (NULL != tz) {
		if (!tzflag) {
			_tzset();
			tzflag++;
		}
		tz->tz_minuteswest = _timezone / 60;
		tz->tz_dsttime = _daylight;
	}

	return 0;
}

#endif