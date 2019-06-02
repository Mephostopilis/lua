#ifndef logsystem_h
#define logsystem_h

#include "../EntitasPP/ISystem.h"

namespace Chestnut {
class LogSystem : Chestnut::EntitasPP::ISystem
{
public:
	~LogSystem();

	void info(const char *fmt, ...);
	void warning(const char *fmt, ...);
	void error(const char *fmt, ...);

};

}
#endif // !logsystem_h

