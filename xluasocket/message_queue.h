#ifndef message_queue_h
#define message_queue_h

#include "spinlock.h"

struct xluasocket_message {
    struct xluasocket_message* next;
    int type;
    int id;
    int ud;
    int sz;
    char* buffer;
};

struct message_queue {
    struct spinlock lock;
    struct xluasocket_message* head;
    struct xluasocket_message* tail;
};

struct message_queue* mq_create();
void mq_release(struct message_queue* q);

struct xluasocket_message*
mq_pop(struct message_queue* q);
void mq_push(struct message_queue* q, struct xluasocket_message* msg);

#endif // !message_queue_h
