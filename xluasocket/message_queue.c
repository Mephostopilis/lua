#include "message_queue.h"
#include "xluaconf.h"
#include <assert.h>

struct message_queue* mq_create()
{
    struct message_queue* q = MALLOC(sizeof(*q));
    SPIN_INIT(q);
    q->head = NULL;
    q->tail = NULL;
    return q;
}

void mq_release(struct message_queue* q)
{
    struct xluasocket_message* msg = mq_pop(q);
    while (msg != NULL) {
        if (msg->ud > 0 && msg->buffer != NULL) {
            FREE(msg->buffer);
        }
        FREE(msg);
    }

    SPIN_DESTROY(q);
    FREE(q);
}

struct xluasocket_message*
mq_pop(struct message_queue* q)
{
    SPIN_LOCK(q);
    struct xluasocket_message* msg = NULL;
    if (q->head == q->tail && q->head != NULL) {
        msg = q->head;
        q->head = NULL;
        q->tail = NULL;
    } else if (q->head != q->tail && q->head != NULL) {
        msg = q->head;
        q->head = q->head->next;
    }
    SPIN_UNLOCK(q);
    return msg;
}

void mq_push(struct message_queue* q, struct xluasocket_message* msg)
{
    SPIN_LOCK(q);
    assert(q != NULL && msg != NULL);
    if (q->tail == NULL) {
        q->head = q->tail = msg;
    } else {
        q->tail->next = msg;
        q->tail = msg;
    }
    SPIN_UNLOCK(q);
}