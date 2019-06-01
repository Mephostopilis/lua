#define _WINSOCK_DEPRECATED_NO_WARNINGS
#define WIN32_LEAN_AND_MEAN

#include "unistd.h"
#include <Windows.h>
#include <WinSock2.h>
#include <signal.h>
#include <conio.h>
#include <assert.h>
#include <stdio.h>
#include <stdlib.h>


long int random(void) {
	return rand();
}

void srandom(unsigned int seed) {
	srand(seed);
}

pid_t getpid() {
	return PtrToInt(GetCurrentProcess());
}

int kill(pid_t pid, int exit_code) {
	return TerminateProcess( (HANDLE)IntToPtr(pid), exit_code);
}

void sigfillset(int *flag) {
	// Not implemented
}

int sigaction(int signo, struct sigaction *act, struct sigaction *oact) {
	// Not implemented
	//__asm int 3;
	switch (signo) {
	case SIGPIPE:
	{

	}
		break;
	case SIGHUP:
	{
		signal(SIGABRT, act->sa_handler);
	}
	break;
	default:
		break;
	}
	return 0;
}

int sigemptyset(sigset_t *set) {
	return 0;
}

int daemon(int a, int b) {
	// Not implemented
#if defined(_WIN32) && !defined(_WIN64)
	__asm int 3;
#else
#endif // 
	return 0;
}

int flock(int fd, int flag) {
	// Not implemented
	//__asm int 3;
}

static int sendfd = -1;
static int recvfd = -1;
static int writebytes = 0;
static int readbytes = 0;

static void
socket_keepalive(int fd) {
	int keepalive = 1;
	int ret = setsockopt(fd, SOL_SOCKET, SO_KEEPALIVE, (void *)&keepalive , sizeof(keepalive));  
	assert(ret != SOCKET_ERROR);
}

int 
pipe(int fd[2]) {
	int listen_fd = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
	struct sockaddr_in sin;
	sin.sin_family = AF_INET;
	sin.sin_addr.S_un.S_addr = inet_addr("127.0.0.1");

	// use random port(range from 60000 to 60999) to simulate pipe()
	srand(time(NULL));
	for(;;) {
		int port = 60000 + rand() % 1000;
		sin.sin_port = htons(port);
		if(!bind(listen_fd, (struct sockaddr*)&sin, sizeof(sin)))
			break;
	}

	listen(listen_fd, 5);
	socket_keepalive(listen_fd);
	fprintf(stderr, "Windows sim pipe() listen at %s:%d\n", inet_ntoa(sin.sin_addr), ntohs(sin.sin_port));

	sendfd = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
	if(connect(sendfd, (struct sockaddr*)&sin, sizeof(sin)) == SOCKET_ERROR) {
		closesocket(listen_fd);
		return -1;
	}

    struct sockaddr_in addr;
	int addrlen = sizeof(addr);
	recvfd = accept(listen_fd, (struct sockaddr*)&addr, &addrlen);
	
	socket_keepalive(recvfd);
	socket_keepalive(sendfd);
	fd[0] = recvfd;
	fd[1] = sendfd;
	writebytes = readbytes = 0;

	return 0;
}

ssize_t write(int fd, const void *buf, size_t count) {
	if (fd == sendfd) {
		int err = send(fd, buf, count, 0);
		if (err == SOCKET_ERROR) {
			return -1;
		}
		//fprintf(stderr, "write sendfd %d bytes\n", err);
		writebytes += err;
		while (writebytes != InterlockedAdd(&readbytes, 0)) {}
		//fprintf(stderr, "writebytes = %d bytes, radbytes = %d\n", writebytes, readbytes);
		InterlockedAdd(&readbytes, -writebytes);
		writebytes = 0;
		return err;
	} else {
		int err = send(fd, buf, count, 0);
		if (err == SOCKET_ERROR) {
			return -1;
		}
		return err;
	}
}

ssize_t read(int fd, void *buf, size_t count) {

	// read console input
	if(fd == 0) {
		char *ptr = buf;
		while(ptr - (char *) buf < count) {
			if(!_kbhit())
				break;
			char ch = _getch();
			*ptr++ = ch;
			_putch(ch);
			if(ch == '\r') {
				if(ptr - (char *) buf >= count)
					break;
				*ptr++ = '\n';
				_putch('\n');
			}
		}
		return ptr - (char *) buf;
	} else if (fd == recvfd) {
		int nbytes = recv(fd, buf, count, 0);
		if (nbytes == SOCKET_ERROR) {
			return -1;
		}
		InterlockedAdd(&readbytes, nbytes);
		//fprintf(stderr, "read recvfd %d bytes\n", err);
		return nbytes;
	} else {
		int nbytes = recv(fd, buf, count, 0);
		if (nbytes == SOCKET_ERROR) {
			return -1;
		}
		return nbytes;
	}
}

int close(int fd) {
	shutdown(fd, SD_BOTH);
	return closesocket(fd);
}

char *strsep(char **stringp, const char *delim)
{
    char *s;
    const char *spanp;
    int c, sc;
    char *tok;
    if ((s = *stringp)== NULL)
        return (NULL);
    for (tok = s;;) {
        c = *s++;
        spanp = delim;
        do {
            if ((sc =*spanp++) == c) {
                if (c == 0)
                    s = NULL;
                else
                    s[-1] = 0;
                *stringp = s;
                return (tok);
            }
        } while (sc != 0);
    }
    /* NOTREACHED */
}

static char strwsaerrbuffer[128] = { 0 };
static char strsyserrbuffer[128] = { 0 };

const char *strwsaerror(int err) {
	memset(strwsaerrbuffer, 0, 128);
	if (FormatMessage(FORMAT_MESSAGE_IGNORE_INSERTS | FORMAT_MESSAGE_FROM_SYSTEM,
					  NULL,
					  err,
					  0,
					  strwsaerrbuffer,
					  sizeof(strwsaerrbuffer) / sizeof(char),
					  NULL)) {
		return strwsaerrbuffer;
	} else {
		snprintf(strwsaerrbuffer, 128, "Format message failed with 0x%x\n", err);
		return strwsaerrbuffer;
	}
}

const char *strsyserror(int err) {
	memset(strsyserrbuffer, 0, 128);
	if (FormatMessage(FORMAT_MESSAGE_IGNORE_INSERTS | FORMAT_MESSAGE_FROM_SYSTEM,
					  NULL,
					  err,
					  0,
					  strwsaerrbuffer,
					  sizeof(strwsaerrbuffer) / sizeof(char),
					  NULL)) {
		return strwsaerrbuffer;
	} else {
		snprintf(strwsaerrbuffer, 128, "Format message failed with 0x%x\n", err);
		return strwsaerrbuffer;
	}
}