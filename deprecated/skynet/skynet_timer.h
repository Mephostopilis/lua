﻿#ifndef SKYNET_TIMER_H
#define SKYNET_TIMER_H

#include <stdint.h>

int skynet_timeout(uintptr_t handle, int time, int session);
void skynet_updatetime(void);
uint32_t skynet_starttime(void);
uint64_t skynet_now(void);
uint64_t skynet_thread_time(void);	// for profile, in micro second

void skynet_timer_init(void);

#endif
