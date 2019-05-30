#ifndef POSIX_SPINLOCK_H
#define POSIX_SPINLOCK_H

#define SPIN_INIT(q) spinlock_init(&(q)->lock);
#define SPIN_LOCK(q) spinlock_lock(&(q)->lock);
#define SPIN_UNLOCK(q) spinlock_unlock(&(q)->lock);
#define SPIN_DESTROY(q) spinlock_destroy(&(q)->lock);

#if defined(USE_CRITICAL_SECTION)
#include <Windows.h>

struct spinlock {
	CRITICAL_SECTION lock;
};

static inline void
spinlock_init(struct spinlock *lock) {
	InitializeCriticalSectionAndSpinCount(&lock->lock, 4000);
}

static inline void
spinlock_lock(struct spinlock *lock) {
	EnterCriticalSection(&lock->lock);
}

static inline int
spinlock_trylock(struct spinlock *lock) {
	return TryEnterCriticalSection(&lock->lock);
}

static inline void
spinlock_unlock(struct spinlock *lock) {
	LeaveCriticalSection(&lock->lock);
}

static inline void
spinlock_destroy(struct spinlock *lock) {
	DeleteCriticalSection(&lock->lock);
}
#else

#include "simplelock.h"

struct spinlock {
	int lock;
};

static inline void
spinlock_init(struct spinlock *lock) {
	lock->lock = 0;
}

static inline void
spinlock_lock(struct spinlock *lock) {
	spin_lock(lock);
}

static inline int
spinlock_trylock(struct spinlock *lock) {
	spin_trylock(lock);
}

static inline void
spinlock_unlock(struct spinlock *lock) {
	spin_unlock(lock);
}

static inline void
spinlock_destroy(struct spinlock *lock) {
	(void)lock;
}
#endif

#endif
