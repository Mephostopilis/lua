#include "LogSystem.h"

#include <cstdarg>

namespace Chestnut {

LogSystem::~LogSystem()
{
}

void LogSystem::info(const char *fmt, ...) {
	va_list ap;
	va_start(ap, fmt);
	char buffer[256] = { 0 };
	vsprintf(buffer, fmt, ap);
	va_end(ap);
}

void LogSystem::warning(const char *fmt, ...) {
	va_list ap;
	va_start(ap, fmt);
	char buffer[256] = { 0 };
	vsprintf(buffer, fmt, ap);
	va_end(ap);
}

void LogSystem::error(const char *fmt, ...) {
	va_list ap;
	va_start(ap, fmt);
	char buffer[256] = { 0 };
	vsprintf(buffer, fmt, ap);
	va_end(ap);

}

}