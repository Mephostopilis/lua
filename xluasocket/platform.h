#ifndef __platform_h__
#define __platform_h__

//////////////////////////////////////////////////////////////////////////
// pre configure
//////////////////////////////////////////////////////////////////////////

// define supported target platform macro which CC uses.
#define CC_PLATFORM_UNKNOWN 0
#define CC_PLATFORM_IOS 1
#define CC_PLATFORM_ANDROID 2
#define CC_PLATFORM_WIN32 3
#define CC_PLATFORM_LINUX 5
#define CC_PLATFORM_MAC 8

// Determine target platform by compile environment macro.
#define CC_TARGET_PLATFORM CC_PLATFORM_UNKNOWN

// Apple: Mac and iOS
#if defined(__APPLE__) && !defined(ANDROID) // exclude android for binding generator.
#include <TargetConditionals.h>
#if TARGET_OS_IPHONE // TARGET_OS_IPHONE includes TARGET_OS_IOS TARGET_OS_TV and TARGET_OS_WATCH. see TargetConditionals.h
#undef CC_TARGET_PLATFORM
#define CC_TARGET_PLATFORM CC_PLATFORM_IOS
#elif TARGET_OS_MAC
#undef CC_TARGET_PLATFORM
#define CC_TARGET_PLATFORM CC_PLATFORM_MAC
#endif
#endif

// android
#if defined(ANDROID)
#undef CC_TARGET_PLATFORM
#define CC_TARGET_PLATFORM CC_PLATFORM_ANDROID
#endif

// win32
#if defined(_WIN32) && defined(_WINDOWS)
#undef CC_TARGET_PLATFORM
#define CC_TARGET_PLATFORM CC_PLATFORM_WIN32
#endif

// linux
#if defined(LINUX) && !defined(__APPLE__)
#undef CC_TARGET_PLATFORM
#define CC_TARGET_PLATFORM CC_PLATFORM_LINUX
#endif

//////////////////////////////////////////////////////////////////////////
// post configure
//////////////////////////////////////////////////////////////////////////

// check user set platform
#if !CC_TARGET_PLATFORM
#error "Cannot recognize the target platform; are you targeting an unsupported platform?"
#endif

#if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32)
#ifndef __MINGW32__
#pragma warning(disable : 4127)
#include <Winsock2.h>
#include <Windows.h>
#endif
#endif // CC_PLATFORM_WIN32

#endif