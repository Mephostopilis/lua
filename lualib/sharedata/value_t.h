#ifndef VALUE_T_H
#define VALUE_T_H

#include <cstdint>
#include <string>

class value_t;

bool operator == (const value_t &left, const value_t & right);
bool operator != (const value_t &left, const value_t & right);
bool operator < (const value_t &left, const value_t & right);
bool operator <= (const value_t &left, const value_t & right);
bool operator > (const value_t &left, const value_t & right);
bool operator >= (const value_t &left, const value_t & right);

class value_t {
public:
	enum value_tt {
		NONE  = 0,
		DOUBLE = 1,
		FLOAT = 2,
		UINT64_T = 3,
		INT64_T = 4,
		UINT32_T = 5,
		INT32_T = 6,
		BOOL = 7,
		STRING = 8,
	};

	value_t();
	~value_t();

	bool operator == (const value_t & other);
	bool operator != (const value_t & other);
	bool operator < (const value_t & other);
	bool operator <= (const value_t & other);
	bool operator > (const value_t & other);
	bool operator >= (const value_t & other);

	friend bool operator == (const value_t &left, const value_t & right);
	friend bool operator != (const value_t &left, const value_t & right);
	friend bool operator < (const value_t &left, const value_t & right);
	friend bool operator <= (const value_t &left, const value_t & right);
	friend bool operator > (const value_t &left, const value_t & right);
	friend bool operator >= (const value_t &left, const value_t & right);

	void set_string(std::string *s);
	std::string * get_string() const;

	void set_uint32(uint32_t &ui);
	uint32_t get_uint32() const;

//private:

	union value {
		double   d;
		float    f;
		uint64_t ul;
		int64_t  l;
		uint32_t ui;
		int32_t  i;
		int      b;
		std::string *s;
	} v;
	value_tt tt;

	static value_t none;
};

#endif // !VALUE_T_H
