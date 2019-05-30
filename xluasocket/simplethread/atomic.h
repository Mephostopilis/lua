#ifndef atomicwin_h
#define atomicwin_h

#include <Windows.h>
#include <stdbool.h>

#if 1
#include <stdint.h>

static inline bool ATOM_CAS(volatile int32_t *ptr, int32_t oval, int32_t nval) {
	InterlockedCompareExchange(ptr, nval, oval);
	return (*ptr == nval);
}

static inline bool ATOM_CAS_POINTER(volatile void **ptr, void *oval, void *nval) {
	InterlockedCompareExchangePointer(ptr, nval, oval);
	return (*ptr == nval);
}

#define ATOM_INC(ptr)    InterlockedIncrement(ptr)
#define ATOM_INC16(ptr)  InterlockedIncrement16(ptr)
#define ATOM_FINC(ptr)   InterlockedExchangeAdd(ptr, 1)
//#define ATOM_FINC16(ptr) InterlockedExchangeAdd16(ptr, 1)
#define ATOM_DEC(ptr)    InterlockedDecrement(ptr)
#define ATOM_DEC16(ptr)  InterlockedDecrement16(ptr)
//#define ATOM_FDEC(ptr) InterlockedExchangeAdd(ptr, -1)

#define ATOM_ADD(ptr,n)  InterlockedAdd(ptr, n)
#define ATOM_SUB(ptr,n)  InterlockedAdd(ptr, -n)
#define ATOM_AND(ptr,n)  InterlockedAnd(ptr, n)

//#define __sync_add_and_fetch(ptr, value) InterlockedAdd(ptr, n);
//#define __sync_sub_and_fetch(ptr, value) InterlockedAdd(ptr, -n);
#else
static inline bool __sync_bool_compare_and_swap(int* ptr, int oval, int nval) {
	if (oval == InterlockedCompareExchange(ptr, nval, oval))
		return 1;
	return 0;
}

static inline int __sync_add_and_fetch(int* ptr, int n) {
	InterlockedAdd(ptr, n);
	return *ptr;
}

static inline int __sync_sub_and_fetch(int* ptr, int n) {
	InterlockedAdd(ptr, -n);
	return *ptr;
}

static inline int __sync_and_and_fetch(int* ptr, int n) {
	InterlockedAnd(ptr, n);
	return *ptr;
}

#define ATOM_CAS(ptr, oval, nval) __sync_bool_compare_and_swap(ptr, oval, nval)
#define ATOM_CAS_POINTER(ptr, oval, nval) __sync_bool_compare_and_swap(ptr, oval, nval)
// #define ATOM_FINC(ptr) __sync_fetch_and_add(ptr, 1)
// #define ATOM_FDEC(ptr) __sync_fetch_and_sub(ptr, 1)

#define ATOM_INC(ptr) __sync_add_and_fetch(ptr, 1)
#define ATOM_DEC(ptr) __sync_sub_and_fetch(ptr, 1)
#define ATOM_ADD(ptr,n) __sync_add_and_fetch(ptr, n)
#define ATOM_SUB(ptr,n) __sync_sub_and_fetch(ptr, n)

#define ATOM_AND(ptr,n) __sync_and_and_fetch(ptr, n)
#endif

#endif // !atomicwin_H
