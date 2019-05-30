#ifndef DESK_CONFIG_T_H
#define DESK_CONFIG_T_H

#include <lua.hpp>
#include <cstdint>
#include <string>
#include <unordered_map>

struct data_config_t {
	int id;
	int width;
	int height;
	int lenght;
	int curormh;
};

struct data_value_t {
	data_config_t config;
};

class data_manager_t {
public:
	
	data_manager_t() {}
	~data_manager_t() {}

	void init();
	void get(lua_State *L, std::string mk, std::string k);

private:
	std::unordered_map<int, data_value_t> _data;

};

#endif // !DESK_CONFIG_T_H
