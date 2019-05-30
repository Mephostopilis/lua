#include "data_manager_t.h"
#include "fast-cpp-csv-parser/csv.h"
#include <cassert>

void data_manager_t::init() {
	io::CSVReader<3> in("desk.csv");
	in.read_header(io::ignore_extra_column, "vendor", "size", "speed");
	std::string vendor; int size; double speed;
	while (in.read_row(vendor, size, speed)) {
		// do stuff with the data
		data_value_t v;
		v.config.id = size;
		v.config.curormh = size;
		_data[v.config.id] = v;
	}
}

void data_manager_t::get(lua_State *L, std::string mk, std::string k) {

}