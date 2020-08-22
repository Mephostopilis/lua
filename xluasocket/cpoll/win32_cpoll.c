#include "../xluaconf.h"

#include "win32_cpoll.h"
#include "dict.h"
#include "util.h"
#include "zmalloc.h"
#include "../array.h"
#include "../socket_poll.h"
#include "../Win32_Interop/Win32_Error.h"
#include <assert.h>
#include <math.h>
#include <stdio.h>

#define MALLOC zmalloc
#define REALLOC zrealloc
#define FREE zfree

typedef struct fdhash {
    int idx;
    int sock;
    int fhash;
    int whash;
    WSAEVENT we;
    void* ud;
} fdhash_t;

typedef struct wev {
    int cap;
    int sz;
    int sidx;
    struct fdhash** fds;
} wev_t;

typedef struct poll {
    dict* fds;
    dict* wes;
    int sidx;
    wev_t arr;
} poll_t;

static poll_t* fd = NULL;

unsigned int dictFdsObjHash(const void* key)
{
    int* o = (int*)key;
    int ll = *o;
    char buf[32];
    int len = ll2string(buf, 32, ll);
    int hash = XXH32(buf, len, 0);

    /*int realcap = pow(2, fd->arr.cap);
  for (size_t i = 0; i < realcap; i++) {
    if (fd->arr.fds == NULL) {
      break;
    }
    fdhash_t *f = fd->arr.fds[i];
    if (f != NULL && f->sock == (*o)) {
      if (f->fhash == 0) {
        f->fhash = hash;
      }
      assert(f->fhash == hash);
    }
  }*/
    return hash;
}

unsigned int dictWesObjHash(const void* key)
{
    WSAEVENT* o = (WSAEVENT*)key;
    WSAEVENT p = (*o);
    char buf[32];
    int len = snprintf(buf, 32, "0x%p", p);
    int hash = XXH32(buf, len, 0);
    return hash;
}

int dictFdsObjKeyCompare(void* privdata, const void* key1, const void* key2)
{
    int* o1 = (int*)key1;
    int* o2 = (int*)key2;
    if ((*o1) == (*o2)) {
        return 1;
    }
    return 0;
}

int dictWesObjKeyCompare(void* privdata, const void* key1, const void* key2)
{
    WSAEVENT* o1 = (WSAEVENT*)key1;
    WSAEVENT* o2 = (WSAEVENT*)key2;
    if ((*o1) == (*o2)) {
        return 1;
    }
    return 0;
}

void dictObjectDestructor(void* privdata, void* val)
{
    DICT_NOTUSED(privdata);

    if (val == NULL)
        return; /* Values of swapped out keys as set to NULL */
    // decrRefCount(val);
}

static dictType fdsHashDictType = {
    dictFdsObjHash, /* hash function */
    NULL, /* key dup */
    NULL, /* val dup */
    dictFdsObjKeyCompare, /* key compare */
    dictObjectDestructor, /* key destructor */
    dictObjectDestructor /* val destructor */
};
static dictType wesHashDictType = {
    dictWesObjHash, /* hash function */
    NULL, /* key dup */
    NULL, /* val dup */
    dictWesObjKeyCompare, /* key compare */
    dictObjectDestructor, /* key destructor */
    dictObjectDestructor /* val destructor */
};

static int wev_add(struct fdhash* f)
{
    int realcap = pow(2, fd->arr.cap);
    if (fd->arr.fds == NULL) {
        fd->arr.fds = MALLOC(sizeof(struct fdhash*) * realcap);
        memset(fd->arr.fds, 0, sizeof(struct fdhash*) * realcap);
    }
    if (fd->arr.sz >= realcap) {
        if (fd->arr.cap > 256) {
            return -1;
        }
        fd->arr.cap++;
        realcap = pow(2, fd->arr.cap);
        int fdssz = sizeof(struct fdhash*) * realcap;
        struct fdhash** oldfds = fd->arr.fds;
        struct fdhash** newfds = REALLOC(oldfds, fdssz);
        if (newfds == NULL) {
            return -1;
        }
        fd->arr.fds = newfds;
        memset(newfds + fd->arr.sz, 0,
            (realcap - fd->arr.sz) * sizeof(struct fdhash*));
    }

    int i = fd->arr.sidx;
    int cnt = 0;
    for (; cnt < realcap; cnt++) {
        if (fd->arr.fds[i] == NULL) { // 空
            fd->arr.sidx = i + 1;
            fd->arr.sidx = fd->arr.sidx >= realcap ? 0 : fd->arr.sidx;
            fd->arr.sz++;
            fd->arr.fds[i] = f;
            fd->arr.fds[i]->idx = i;
            return i;
        }
        i = (++i >= realcap) ? 0 : i;
    }
    return -1;
}

static int wev_del(int idx)
{
    if (fd->arr.fds[idx] != NULL) {
        assert(fd->arr.fds[idx]->idx == idx);
        fd->arr.fds[idx] = NULL;
        fd->arr.sz--;
        return 1;
    }
    return 0;
}

bool ssp_invalid(int efd) { return efd == -1; }

int ssp_create()
{
    WSADATA wsadata;
    if (WSAStartup(MAKEWORD(2, 2), &wsadata) != 0) {
        return -1;
    }
    if (fd == NULL) {
        fd = MALLOC(sizeof(*fd));
        memset(fd, 0, sizeof(*fd));
        fd->fds = dictCreate(&fdsHashDictType, fd);
        fd->wes = dictCreate(&wesHashDictType, fd);
    }
    return 0;
}

void ssp_release(int efd)
{
    if (fd != NULL) {
        dictRelease(fd->wes);
        dictRelease(fd->fds);
        FREE(fd);
        fd = NULL;
    }
    WSACleanup();
}

/*
** @return [1] 0 成
**             1 失败
*/
int ssp_add(int efd, int sock, void* ud)
{
    assert(efd == 0);
    struct fdhash* f = MALLOC(sizeof(*f));
    memset(f, 0, sizeof(*f));
    f->sock = sock;
    f->ud = ud;
    f->we = WSACreateEvent();
    WSAEventSelect(f->sock, f->we, FD_READ | FD_ACCEPT | FD_CLOSE);
    assert(dictAdd(fd->fds, &f->sock, f) == 0);

    struct fdhash* f1 = dictFetchValue(fd->fds, &sock);
    assert(f1 == f);

    int idx = wev_add(f);
    assert(idx >= 0);
    assert(idx == f->idx);
    assert(fd->arr.fds[idx] == f);

    assert(dictAdd(fd->wes, &f->we, f) == 0);
    struct fdhash* w = dictFetchValue(fd->wes, &f->we);
    assert(w == f);

    WSAEVENT e = w->we;
    struct fdhash* w1 = dictFetchValue(fd->wes, &e);
    assert(w == w1);

    struct fdhash* f2 = dictFetchValue(fd->fds, &sock);
    assert(w == f2);
    return 0;
}

void ssp_del(int efd, int sock)
{
    assert(efd == 0);
    struct fdhash* f = dictFetchValue(fd->fds, &sock);
    if (f != NULL) {
        assert(wev_del(f->idx) == 1);
        assert(dictDeleteNoFree(fd->fds, &f->sock) == 0);
        assert(dictDeleteNoFree(fd->wes, &f->we) == 0);

        WSAEventSelect(sock, 0, 0);
        WSACloseEvent(f->we);
        FREE(f);
    }
}

void ssp_write(int efd, int sock, void* ud, bool enable)
{
    struct fdhash* f = dictFetchValue(fd->fds, &sock);
    if (f == NULL) {
        if (ssp_add(efd, sock, ud)) {
            return;
        }
        f = dictFetchValue(fd->fds, &sock);
    }
    f->ud = ud;
    long netevents = FD_READ | FD_ACCEPT | FD_CLOSE | (enable ? FD_WRITE : 0);
    WSAEventSelect(f->sock, f->we, netevents);
}

int ssp_wait(int efd, struct event* e, int max)
{
    int we_sz = fd->arr.sz > max ? max : fd->arr.sz;
    ARRAY(WSAEVENT, es, we_sz);

    int c = 0;
    int realcap = pow(2, fd->arr.cap);
    for (int i = fd->sidx; c < we_sz;) {
        if (fd->arr.fds[i] != NULL) {
            es[c++] = fd->arr.fds[i]->we;
        }
        i++;
        if (i >= realcap) {
            i = 0;
        }
    }

    DWORD index = 0;
    for (;;) {
        index = WSAWaitForMultipleEvents(we_sz, es, FALSE, 5, FALSE);
        if (index == WSA_WAIT_IO_COMPLETION)
            break;
        if (index == WSA_WAIT_FAILED)
            break;
        if (index != WSA_WAIT_TIMEOUT)
            break;
        // if (_kbhit()) {
        //	// console input handle
        //	cpoll_event& ev = events[num_ready++];
        //	ev.data.ptr = NULL;
        //	ev.events = FD_READ;
        //	for (int i = 0; i < cpi.size(); i++) {
        //		if (cpi[i].fd == 0) {
        //			ev.data.ptr = cpi[i].event.data.ptr;
        //			break;
        //		}
        //	}
        //	// if console service not startup, ignore this
        //	if (ev.data.ptr == NULL) {
        //		num_ready--;
        //		continue;
        //	}
        //	break;
        //}
    }
    if (index == WSA_WAIT_FAILED) {
        return -1; // error
    }
    int n = 0;
    if (index != WSA_WAIT_TIMEOUT) {
        int eindex = index - WSA_WAIT_EVENT_0;
        for (int i = eindex; i < we_sz && n < max; ++i) { // 遍历所有event
            struct fdhash* w = dictFetchValue(fd->wes, &es[i]);
            assert(w != NULL);
            struct fdhash* f = dictFetchValue(fd->fds, &w->sock);
            assert(w == f);

            WSANETWORKEVENTS ne;
            if (WSAEnumNetworkEvents(f->sock, f->we, &ne) == SOCKET_ERROR) {
                // ignore stdin handle
                if (f->sock == 0)
                    continue;
                if (n > 0)
                    break;
                return -1; // error?
            }
            struct event* ptr = &e[n++];
            ptr->s = f->ud;
            ptr->read = (ne.lNetworkEvents & (FD_ACCEPT | FD_READ)) != 0;
            ptr->write = (ne.lNetworkEvents & FD_WRITE) != 0;
            ptr->eof = (ne.lNetworkEvents & FD_CLOSE) != 0;
            ptr->error = ne.iErrorCode[0] > 0;
        }
    }
    return n;
}

void ssp_nonblocking(int fd)
{
    int ul = 1;
    if (ioctlsocket(fd, FIONBIO, &ul) == SOCKET_ERROR) {
        fprintf(stderr, "ioctlsocket failed: %s", wsa_strerror(WSAGetLastError()));
    }
}
