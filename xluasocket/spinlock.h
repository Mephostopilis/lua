#ifndef __spinlock_h__
#define __spinlock_h__

#define SPIN_INIT(q) spinlock_init(&(q)->lock);
#define SPIN_LOCK(q) spinlock_lock(&(q)->lock);
#define SPIN_UNLOCK(q) spinlock_unlock(&(q)->lock);
#define SPIN_DESTROY(q) spinlock_destroy(&(q)->lock);

#include "platform.h"
#if (CC_TARGET_PLATFORM == CC_PLATFORM_LINUX) || (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)

struct spinlock {
    int lock;
};

static inline void
spinlock_init(struct spinlock* lock)
{
    lock->lock = 0;
}

static inline void
spinlock_lock(struct spinlock* lock)
{
    while (__sync_lock_test_and_set(&lock->lock, 1)) {
    }
}

static inline int
spinlock_trylock(struct spinlock* lock)
{
    return __sync_lock_test_and_set(&lock->lock, 1) == 0;
}

static inline void
spinlock_unlock(struct spinlock* lock)
{
    __sync_lock_release(&lock->lock);
}

static inline void
spinlock_destroy(struct spinlock* lock)
{
    (void)lock;
}

#elif (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32)

struct spinlock {
    CRITICAL_SECTION lock;
};

static inline void
spinlock_init(struct spinlock* lock)
{
    InitializeCriticalSectionAndSpinCount(&lock->lock, 4000);
}

static inline void
spinlock_lock(struct spinlock* lock)
{
    EnterCriticalSection(&lock->lock);
}

static inline int
spinlock_trylock(struct spinlock* lock)
{
    return TryEnterCriticalSection(&lock->lock);
}

static inline void
spinlock_unlock(struct spinlock* lock)
{
    LeaveCriticalSection(&lock->lock);
}

static inline void
spinlock_destroy(struct spinlock* lock)
{
    DeleteCriticalSection(&lock->lock);
}

#endif

#endif