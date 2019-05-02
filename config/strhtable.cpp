#include "strhtable.h"
#include <cassert>

uint32_t xxhash(std::string &arg) {
	int b = 378551;
	int a = 63689;
	uint32_t hash = 0;
	for (int i = 0; i < arg.length(); i++) {
		hash = hash * a + (arg.at(i) >> i & 0xff);
		a = a * b;
	}
	return hash;
}

bool operator == (const strhtable_elem &left, const strhtable_elem &right) {
	return left._value == right._value;
}

bool operator != (const strhtable_elem &left, const strhtable_elem &right) {
	return left._value != right._value;
}

bool operator < (const strhtable_elem &left, const strhtable_elem &right) {
	return left._value < right._value;
}

bool operator <= (const strhtable_elem &left, const strhtable_elem &right) {
	return left._value <= right._value;
}

bool operator > (const strhtable_elem &left, const strhtable_elem &right) {
	return left._value > right._value;
}

bool operator >= (const strhtable_elem &left, const strhtable_elem &right) {
	return left._value >= right._value;
}

strhtable_elem::strhtable_elem()
	: _free(true)
	, _hash(0)
	, _next(nullptr) {
}

strhtable_elem::~strhtable_elem() {
}

void strhtable_elem::set_value(std::string &value) {
	_value = value;
	_hash = xhash();
}

bool strhtable_elem::operator == (const strhtable_elem & other) {
	return _value == other._value;
}

bool strhtable_elem::operator != (const strhtable_elem & other) {
	return _value != other._value;
}

bool strhtable_elem::operator < (const strhtable_elem & other) {
	return _value < other._value;
}

bool strhtable_elem::operator <= (const strhtable_elem & other) {
	return _value <= other._value;
}

bool strhtable_elem::operator > (const strhtable_elem & other) {
	return _value > other._value;
}

bool strhtable_elem:: operator >= (const strhtable_elem & other) {
	return _value >= other._value;
}

uint32_t strhtable_elem::xhash() {
	return xxhash(_value);
}

strhtable::strhtable()
	:_data(new strhtable_elem[127])
	, _cap(127)
	, _size(0)
	, _free(_cap - 1)
{
}

strhtable::strhtable(int cap) 
	:_data(new strhtable_elem[cap])
	, _cap(cap)
	, _size(0)
	, _free(_cap - 1)
{
}

strhtable::~strhtable() {
	delete[] _data;
}

std::string * strhtable::insert(std::string &key) {
	if (_size == _cap) {
		expand();
	}
	uint32_t h = xxhash(key);
	uint32_t idx = h % _cap;
	strhtable_elem *mp = &_data[idx];

	if ( !mp->is_free()) {
		if (mp->hash() % _cap == idx) {
			// 找到前一项，并查找是否已经插入
			strhtable_elem *node = NULL;
			if (mp->get_value() == key) {
				return mp->get_value_ptr();
			} else {
				node = mp;
				while (node->next()) {
					if (node->next()->get_value() == key) {
						return node->next()->get_value_ptr();
					}
					node = node->next();
				}
			}

			int free = get_free();
			strhtable_elem *p = &_data[free];
			p->set_free(false);
			p->set_next(nullptr);
			p->set_value(key);
			node->set_next(p);

			_size++;

			return p->get_value_ptr();
		} else {
			// 先找到前一项
			strhtable_elem *node = NULL;
			uint32_t oidx = mp->hash() % _cap;
			strhtable_elem *omp = &_data[oidx];
			assert(!omp->is_free());
			node = omp;
			while (node->next()) {
				if (node->next() == mp) {
					break;
				}
				node = node->next();
			}
			assert(node != NULL);
			int free = get_free();
			_data[free] = *omp;
			node->set_next(&_data[free]);

			// 存储值
			mp->set_free(false);
			mp->set_next(NULL);
			mp->set_value(key);

			_size++;

			return mp->get_value_ptr();
		}
	} else {
		mp->set_free(false);
		mp->set_next(NULL);
		mp->set_value(key);
		_size++;

		return mp->get_value_ptr();
	}
}

int strhtable::get_free() {
	while (!_data[_free].is_free()) {
		_free--;
	}
	return _free;
}

void strhtable::expand() {
	strhtable_elem *old = _data;
	int oldcap = _cap;

	strhtable_elem *tmp = new strhtable_elem[_cap * 2];
	_data = tmp;
	_cap *= 2;
	_size = 0;
	_free = _cap - 1;

	for (size_t i = 0; i < oldcap; i++) {
		strhtable_elem *ptr = &old[i];
		insert((std::string &)ptr->get_value());
	}
	delete[] old;
}