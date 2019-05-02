#ifndef DESK_CONFIG_T_H
#define DESK_CONFIG_T_H

#include <lua.hpp>
#include <cstdint>
#include <string>
#include <unordered_map>

struct desk_config_t {
	int id;
	int width;
	int height;
	int lenght;
	int curormh;
};

struct desk_value_t {
	desk_config_t config;
};

class desk_manager_t {
public:
	
	desk_manager_t() {}
	~desk_manager_t() {}

	void init();
	void get(lua_State *L, std::string mk, std::string k);

private:
	std::unordered_map<int, desk_value_t> _data;

};

#endif // !DESK_CONFIG_T_H
