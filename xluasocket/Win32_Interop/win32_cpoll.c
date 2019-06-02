#include "win32_cpoll.h"
#include "../socket_poll.h"
#include "../array.h"
#include "../dict.h"
#include "../zmalloc.h"
//#include "uthash.h"
//#include "fdhash.h"
//#include "wehash.h"
#include <WinSock2.h>
#include <assert.h>
#include <stdio.h>
#include <math.h>

struct fdhash {
	int idx;
	int hash;
	int sock;
	WSAEVENT we;
	void *ud;
};

struct wev_t {
	int cap;
	int sz;
	int sidx;
	struct fdhash **fds;
};

static dictType hashDictType = {
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
};
static dict *fds = NULL;
static dict *wes = NULL;
static int sidx = 0;
static struct wev_t arr = { 0, 0, 0, NULL };

static int
wev_add(struct fdhash *f) {
	int realcap = pow(2, arr.cap);
	if (arr.sz >= realcap) {
		struct fdhash **fds = arr.fds;
		arr.cap++;
		realcap = pow(2, arr.cap);
		arr.fds = malloc(sizeof(struct fdhash *) * realcap);
		memset(arr.fds, 0, sizeof(struct fdhash *) * realcap);
		for (int i = 0; i < arr.sz; i++) {
			arr.fds[i] = fds[i];
		}
		free(fds);
	}
	if (arr.fds == NULL) {
		arr.fds = malloc(sizeof(struct fdhash *) * realcap);
		memset(arr.fds, 0, sizeof(struct fdhash *) * realcap);
	}
	int i = arr.sidx;
	for (; i < realcap; i++) {
		if (arr.fds[i] == NULL) { // 空
			arr.sidx = i + 1;
			arr.sidx = arr.sidx >= realcap ? 0 : arr.sidx;
			arr.sz++;
			arr.fds[i] = f;
			arr.fds[i]->idx = i;
			return i;
		}
	}
	return -1;
}

static int
wev_del(int idx) {
	if (arr.fds[idx] != NULL) {
		assert(arr.fds[idx]->idx == idx);
		arr.fds[idx] = NULL;
		arr.sz--;
		return 1;
	}
	return 0;
}

#define MALLOC zmalloc
#define FREE   zfree

bool
ssp_invalid(int efd) {
	return efd == -1;
}

int
ssp_create() {
	WSADATA wsadata;
	if (WSAStartup(MAKEWORD(2, 2), &wsadata) != 0) {
		return -1;
	}
	return 0;
}

void
ssp_release(int efd) {
	WSACleanup();
}

/*
** @return [1] 0 成
**             1 失败
*/
int
ssp_add(int efd, int sock, void *ud) {
	assert(efd == 0);
	struct fdhash *f = MALLOC(sizeof(*f));
	f->sock = sock;
	f->ud = ud;
	f->we = WSACreateEvent();
	WSAEventSelect(f->sock, f->we, FD_READ | FD_ACCEPT | FD_CLOSE);
	assert(dictAdd(fds, &f->sock, f) == 0);
	
	struct fdhash *f1 = dictFetchValue(fds, &sock);
	assert(f1 == f);

	int idx = wev_add(f);
	assert(idx >= 0);
	assert(idx == f->idx);

	assert(dictAdd(wes, &f->we, f) == 0);
	struct fdhash *w = dictFetchValue(wes, &sock);
	assert(w == f);

	struct fdhash *f2 = dictFetchValue(fds, &sock);
	assert(w == f2);
	return 0;
}

void
ssp_del(int efd, int sock) {
	assert(efd == 0);
	struct fdhash *f = dictFetchValue(fds, &sock);
	if (f != NULL) {
		assert(wev_del(f->idx) > 0);
		assert(dictDeleteNoFree(&fds, &f->sock) == 0);
		assert(dictDeleteNoFree(&wes, &f->we) == 0);
		
		WSAEventSelect(sock, 0, 0);
		WSACloseEvent(f->we);
		FREE(f);
	}
}

void
ssp_write(int efd, int sock, void *ud, bool enable) {
	struct fdhash *f = dictFetchValue(fds, &sock);
	if (f == NULL) {
		if (ssp_add(efd, sock, ud)) {
			return;
		}
		f = dictFetchValue(fds, &sock);
	}
	f->ud = ud;
	long netevents = FD_READ | FD_ACCEPT | FD_CLOSE | (enable ? FD_WRITE : 0);
	WSAEventSelect(f->sock, f->we, netevents);
}

int
ssp_wait(int efd, struct event *e, int max) {
	int we_sz = arr.sz > max ? max : arr.sz;
	ARRAY(WSAEVENT, es, we_sz);

	int c = 0;
	int realcap = pow(2, arr.cap);
	for (int i = sidx; c < we_sz; ) {
		if (arr.fds[i] != NULL) {
			es[c++] = arr.fds[i]->we;
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
		//if (_kbhit()) {
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
		for (int i = eindex; i < we_sz && n < max; ++i) {   // 遍历所有event
			WSAEVENT *wep = &es[i];
			struct fdhash *w = dictFetchValue(wes, wep);
			assert(w != NULL);
			struct fdhash *f = dictFetchValue(fds, &w->sock);
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
			struct event *ptr = &e[n++];
			ptr->s = f->ud;
			ptr->read = (ne.lNetworkEvents & (FD_ACCEPT | FD_READ)) != 0;
			ptr->write = (ne.lNetworkEvents & FD_WRITE) != 0;
			ptr->eof = (ne.lNetworkEvents & FD_CLOSE) != 0;
			ptr->error = ne.iErrorCode[0] > 0;
		}
	}
	return n;
}

void
ssp_nonblocking(int fd) {
	int ul = 1;
	ioctlsocket(fd, FIONBIO, &ul);
}
