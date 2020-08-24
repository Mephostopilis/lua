#ifndef __rwlock_h__
#define __rwlock_h__

#include "platform.h"
#if (CC_TARGET_PLATFORM == CC_PLATFORM_LINUX) || (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)

struct rwlock {
    int write;
    int read;
};

static inline void
rwlock_init(struct rwlock* lock)
{
    lock->write = 0;
    lock->read = 0;
}

static inline void
rwlock_rlock(struct rwlock* lock)
{
    for (;;) {
        while (lock->write) {
            __sync_synchronize();
        }
        __sync_add_and_fetch(&lock->read, 1);
        if (lock->write) {
            __sync_sub_and_fetch(&lock->read, 1);
        } else {
            break;
        }
    }
}

static inline void
rwlock_wlock(struct rwlock* lock)
{
    while (__sync_lock_test_and_set(&lock->write, 1)) {
    }
    while (lock->read) {
        __sync_synchronize();
    }
}

static inline void
rwlock_wunlock(struct rwlock* lock)
{
    __sync_lock_release(&lock->write);
}

static inline void
rwlock_runlock(struct rwlock* lock)
{
    __sync_sub_and_fetch(&lock->read, 1);
}

#elif (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32)

struct rwlock {
    int write;
    int read;
};

static inline void
rwlock_init(struct rwlock* lock)
{
    lock->write = 0;
    lock->read = 0;
}

static inline void
rwlock_rlock(struct rwlock* lock)
{
    for (;;) {
        while (lock->write) {
            MemoryBarrier();
        }
        InterlockedIncrement(&lock->read);
        if (lock->write) {
            InterlockedDecrement(&lock->read);
        } else {
            break;
        }
    }
}

static inline void
rwlock_wlock(struct rwlock* lock)
{
    while (InterlockedCompareExchange(&lock->write, 1, 0)) {
    }
    while (lock->read) {
        MemoryBarrier();
    }
}

static inline void
rwlock_wunlock(struct rwlock* lock)
{
    InterlockedExchange(&lock->write, 0);
}

static inline void
rwlock_runlock(struct rwlock* lock)
{
    InterlockedDecrement(&lock->read);
}

#endif

#endif