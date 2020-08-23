#ifndef __atomic_h__
#define __atomic_h__

#include "platform.h"

#if (CC_TARGET_PLATFORM == CC_PLATFORM_LINUX) || (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
#define ATOM_CAS(ptr, oval, nval) __sync_bool_compare_and_swap(ptr, oval, nval)
#define ATOM_CAS_POINTER(ptr, oval, nval) __sync_bool_compare_and_swap(ptr, oval, nval)
#define ATOM_INC(ptr) __sync_add_and_fetch(ptr, 1)
#define ATOM_FINC(ptr) __sync_fetch_and_add(ptr, 1)
#define ATOM_DEC(ptr) __sync_sub_and_fetch(ptr, 1)
#define ATOM_FDEC(ptr) __sync_fetch_and_sub(ptr, 1)
#define ATOM_ADD(ptr, n) __sync_add_and_fetch(ptr, n)
#define ATOM_SUB(ptr, n) __sync_sub_and_fetch(ptr, n)
#define ATOM_AND(ptr, n) __sync_and_and_fetch(ptr, n)
#define ATOM_SYNC() __sync_synchronize()
#elif (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32)
#define ATOM_CAS(ptr, oval, nval) (oval == InterlockedCompareExchange((LONG volatile*)ptr, nval, oval))
#define ATOM_CAS_POINTER(ptr, oval, nval) (oval = InterlockedCompareExchangePointer((PVOID volatile*)ptr, nval, oval))
#define ATOM_INC(ptr) InterlockedIncrement((LONG volatile*)ptr)
#define ATOM_INC16(ptr) InterlockedIncrement16(ptr)
#define ATOM_FINC(ptr) InterlockedExchangeAdd(ptr, 1)
#define ATOM_DEC(ptr) InterlockedDecrement(ptr)
#define ATOM_DEC16(ptr) InterlockedDecrement16(ptr)
#define ATOM_FDEC(ptr) InterlockedExchangeAdd(ptr, -1)
#define ATOM_ADD(ptr, n) InterlockedAdd(ptr, n)
#define ATOM_SUB(ptr, n) InterlockedAdd(ptr, -n)
#define ATOM_AND(ptr, n) InterlockedAnd(ptr, n)
#define ATOM_SYNC() MemoryBarrier()
#endif // _MSC_VER

#endif
