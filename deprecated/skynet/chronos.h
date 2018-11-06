/**
The MIT License (MIT)

Copyright (c) ldrumm 2014

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/

#ifndef chronos_h
#define chronos_h

#if defined(__APPLE__) && defined(__MACH__)
#include <mach/mach_time.h>
#ifdef CHRONOS_USE_COREAUDIO
#include <CoreAudio/HostTime.h>
#endif
#elif defined(_WIN32)
#define WIN32_LEAN_AND_MEAN
#include <windows.h>
#elif defined(__unix__) || defined(__linux__) && !defined(__APPLE__)
#include <unistd.h>
#if defined (_POSIX_TIMERS) && _POSIX_TIMERS > 0
#ifdef _POSIX_MONOTONIC_CLOCK
#define HAVE_CLOCK_GETTIME
#include <time.h>
#else
#warning "A nanosecond resolution monotonic clock is not available;"
#warning "falling back to microsecond gettimeofday()"
#include <sys/time.h>
#endif
#endif
#endif

void clock_gettime_mono(struct timespec *ti);

#endif
