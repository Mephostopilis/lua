#ifndef STRHTABLE_H
#define STRHTABLE_H

#include <string>
#include <cstdint>

class strhtable_elem {
public:
	strhtable_elem() ;
	~strhtable_elem();

	inline std::string * get_value_ptr() const { return (std::string *)(&_value); }
	inline std::string   get_value() const { return _value; }
	void set_value(std::string &value);

	inline strhtable_elem * next() const { return _next; }
	inline void set_next(strhtable_elem *next) { _next = next; }

	bool is_free() const { return _free; }
	void set_free(bool value) { _free = value; }

	uint32_t hash() const { return _hash; }

	bool operator == (const strhtable_elem & other);
	bool operator != (const strhtable_elem & other);
	bool operator < (const strhtable_elem & other);
	bool operator <= (const strhtable_elem & other);
	bool operator > (const strhtable_elem & other);
	bool operator >= (const strhtable_elem & other);

private:

	uint32_t strhtable_elem::xhash();

	bool            _free;
	uint32_t        _hash;
	std::string     _value;
	strhtable_elem *_next;
};

class strhtable {
public:
	strhtable();
	strhtable(int cap);
	~strhtable();
	
	std::string * insert(std::string &s);

private:
	int get_free();
	void expand();

	strhtable_elem *_data;
	int             _cap;
	int             _size;
	int             _free;

};
#endif // !STRHTABLE


