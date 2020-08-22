﻿#ifndef SIMPLE_THREAD_H
#define SIMPLE_THREAD_H

struct thread {
    void (*func)(void*);
    void* ud;
};

struct thread_event;

static void thread_create(struct thread* threads, int n);
static void thread_join(struct thread* threads, int n);
static void thread_event_create(struct thread_event* ev);
static void thread_event_release(struct thread_event* ev);
static void thread_event_trigger(struct thread_event* ev);
static void thread_event_wait(struct thread_event* ev);

#include "platform.h"

#if (CC_TARGET_PLATFORM == CC_PLATFORM_LINUX) || (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
#include <pthread.h>

static pthread_t* pid = NULL;

static inline void*
thread_function(void* args)
{
    struct thread* t = (struct thread*)args;
    t->func(t->ud);
    return NULL;
}

static inline void
thread_init()
{
#if defined(_MSC_VER) || defined(__MINGW32__) || defined(__MINGW64__)
    InitThreadControl();
#endif
}

static inline void
thread_create(struct thread* threads, int n)
{
    pthread_t* pid = malloc(sizeof(pthread_t) * n);
    int i;
    for (i = 0; i < n; i++) {
        if (pthread_create(&pid[i], NULL, thread_function, &threads[i])) {
            return;
        }
    }
}

static inline void
thread_join(struct thread* threads, int n)
{
    int i;
    for (i = 0; i < n; i++) {
        pthread_join(pid[i], NULL);
    }
    free(pid);
    pid = NULL;
}

struct thread_event {
    pthread_cond_t cond;
    pthread_mutex_t mutex;
    int flag;
};

static inline void
thread_event_create(struct thread_event* ev)
{
    pthread_mutex_init(&ev->mutex, NULL);
    pthread_cond_init(&ev->cond, NULL);
    ev->flag = 0;
}

static inline void
thread_event_release(struct thread_event* ev)
{
    pthread_mutex_destroy(&ev->mutex);
    pthread_cond_destroy(&ev->cond);
}

static inline void
thread_event_trigger(struct thread_event* ev)
{
    pthread_mutex_lock(&ev->mutex);
    ev->flag = 1;
    pthread_mutex_unlock(&ev->mutex);
    pthread_cond_signal(&ev->cond);
}

static inline void
thread_event_wait(struct thread_event* ev)
{
    pthread_mutex_lock(&ev->mutex);

    while (!ev->flag)
        pthread_cond_wait(&ev->cond, &ev->mutex);

    ev->flag = 0;

    pthread_mutex_unlock(&ev->mutex);
}
#elif (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32)

#include <assert.h>

static HANDLE* thread_handle = NULL;

static DWORD inline WINAPI
thread_function(LPVOID lpParam)
{
    struct thread* t = (struct thread*)lpParam;
    t->func(t->ud);
    return 0;
}

static inline void
thread_create(struct thread* threads, int n)
{
    assert(thread_handle == NULL);
    int i;
    thread_handle = (HANDLE*)HeapAlloc(GetProcessHeap(), HEAP_ZERO_MEMORY, n * sizeof(HANDLE));
    for (i = 0; i < n; i++) {
        thread_handle[i] = CreateThread(NULL, 0, thread_function, (LPVOID)&threads[i], 0, NULL);
        if (thread_handle[i] == NULL) {
            HeapFree(GetProcessHeap(), 0, thread_handle);
            return;
        }
    }
}

static inline void
thread_join(struct thread* threads, int n)
{
    int i = 0;
    WaitForMultipleObjects(n, thread_handle, TRUE, INFINITE);
    for (i = 0; i < n; i++) {
        CloseHandle(thread_handle[i]);
    }
    HeapFree(GetProcessHeap(), 0, thread_handle);
    thread_handle = NULL;
}

struct thread_event {
    HANDLE event;
};

static inline void
thread_event_create(struct thread_event* ev)
{
    ev->event = CreateEvent(NULL, FALSE, FALSE, NULL);
}

static inline void
thread_event_release(struct thread_event* ev)
{
    if (ev->event) {
        CloseHandle(ev->event);
        ev->event = NULL;
    }
}

static inline void
thread_event_trigger(struct thread_event* ev)
{
    SetEvent(ev->event);
}

static inline void
thread_event_wait(struct thread_event* ev)
{
    WaitForSingleObject(ev->event, INFINITE);
}

#endif

#endif