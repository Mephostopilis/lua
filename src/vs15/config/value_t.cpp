#include "value_t.h"
#include <cassert>


bool operator == (const value_t &left, const value_t & right) {
	assert(left.tt == right.tt);
	if (left.tt == value_t::UINT32_T) {
		return (left.v.ui == right.v.ui);
	} else if (left.tt == value_t::STRING) {
		return ((left.v.s == right.v.s) || (*left.v.s == *right.v.s));
	}
}

bool operator != (const value_t &left, const value_t & right) {
	assert(left.tt == right.tt);
	if (left.tt == value_t::UINT32_T) {
		return (left.v.ui != right.v.ui);
	} else if (left.tt == value_t::STRING) {
		return ((left.v.s != right.v.s) || (*left.v.s == *right.v.s));
	}
}

bool operator < (const value_t &left, const value_t & right) {
	assert(left.tt == right.tt);
	if (left.tt == value_t::UINT32_T) {
		return (left.v.ui < right.v.ui);
	} else if (left.tt == value_t::STRING) {
		return ((left.v.s < right.v.s) || (*left.v.s < *right.v.s));
	}
}

bool operator <= (const value_t &left, const value_t & right) {
	assert(left.tt == right.tt);
	if (left.tt == value_t::UINT32_T) {
		return (left.v.ui <= right.v.ui);
	} else if (left.tt == value_t::STRING) {
		return ((left.v.s <= right.v.s) || (*left.v.s <= *right.v.s));
	}
}

bool operator > (const value_t &left, const value_t & right) {
	assert(left.tt == right.tt);
	if (left.tt == value_t::UINT32_T) {
		return (left.v.ui > right.v.ui);
	} else if (left.tt == value_t::STRING) {
		return ((left.v.s > right.v.s) || (*left.v.s > *right.v.s));
	}
}

bool operator >= (const value_t &left, const value_t & right) {
	assert(left.tt == right.tt);
	if (left.tt == value_t::UINT32_T) {
		return (left.v.ui >= right.v.ui);
	} else if (left.tt == value_t::STRING) {
		return ((left.v.s >= right.v.s) || (*left.v.s >= *right.v.s));
	}
}

value_t value_t::none;

value_t::value_t()
	: tt(NONE)
{
}


value_t::~value_t() {
}

bool value_t::operator == (const value_t & other) {
	if (tt == UINT32_T) {
		return v.ui == other.v.ui;
	} else if (tt == STRING) {
		return *v.s == *other.v.s;
	}
}

bool value_t::operator != (const value_t & other) {
	if (tt == UINT32_T) {
		return v.ui != other.v.ui;
	} else if (tt == STRING) {
		return *v.s != *other.v.s;
	}
}

bool value_t::operator < (const value_t & other) {
	if (tt == UINT32_T) {
		return v.ui < other.v.ui;
	} else if (tt == STRING) {
		return *v.s < *other.v.s;
	}
}

bool value_t::operator <= (const value_t & other) {
	if (tt == UINT32_T) {
		return v.ui <= other.v.ui;
	} else if (tt == STRING) {
		return *v.s <= *other.v.s;
	}
}

bool value_t::operator > (const value_t & other) {
	if (tt == UINT32_T) {
		return v.ui > other.v.ui;
	} else if (tt == STRING) {
		return *v.s > *other.v.s;
	}
}
bool value_t::operator >= (const value_t & other) {
	if (tt == UINT32_T) {
		return v.ui >= other.v.ui;
	} else if (tt == STRING) {
		return *v.s >= *other.v.s;
	}
}

void value_t::set_string(std::string *s) {
	tt = value_t::STRING;
	v.s = s;
}

std::string * value_t::get_string() const {
	assert(tt == STRING);
	return v.s;
}

void value_t::set_uint32(uint32_t &ui) {
	tt = value_tt::UINT32_T;
	v.ui = ui;
}
uint32_t value_t::get_uint32() const {
	assert(tt == value_tt::UINT32_T);
	return v.ui;
}