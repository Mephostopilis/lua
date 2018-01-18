#ifndef CSV_H
#define CSV_H

#include "strhtable.h"
#include "value_t.h"

#include <fstream>
#include <map>
#include <list>
#include <string>
#include <vector>
#include <array>
#include <iostream>
#include <sstream>
#include <cassert>
#include <exception>
#include <cstdint>
#include <cstdbool>
#include <cstdlib>
#include <cmath>
#include <cctype>

template<typename MKT, int MK, typename R>
class csv {
public:

	csv(strhtable *strt);
	csv(strhtable *strt, std::string filename, int headline, int typeline, int dataline);
	~csv();

	bool load(std::string filename, int headline, int typeline, int dataline);

	const value_t & search(MKT id, std::string key) {
		if (_rows.find(id) != _rows.end()) {
			std::map<uint32_t, value_t> *row = _rows.at(id);
			uint32_t col = _head[key];
			return row->at(col);
		} else {
			return value_t::none;
		}
	}

	// gen
	void flush(std::string path);

	const std::string & get_tname() const { return _tname; }

private:
	void constructor(strhtable *strt, std::string filename, int headline, int typeline, int dataline) {
		_strt = strt;
		_filename = filename;
		_headline = headline;
		_typeline = typeline;
		_dataline = dataline;

		_types["string"] = value_t::STRING;
		_types["uint32_t"] = value_t::UINT32_T;

		_rtypes[value_t::STRING] = "string";
		_rtypes[value_t::UINT32_T] = "uint32_t";
		if (filename.length() > 0 && _headline != 0 && _typeline != 0 && _dataline != 0) {
			load(_filename, _headline, _typeline, _dataline);
		}
	}

	bool is_integer(std::string str);
	bool is_float(std::string str);

	void push_word(std::map<uint32_t, value_t>* row, int line, int col, std::string &word);
	void push_row(std::map<uint32_t, value_t>* row, int line);

	std::map<uint32_t, value_t> * create_row() {
		return new std::map<uint32_t, value_t>();
	}

	// memory
	R          *_data;
	int         _size;
	int         _cap;
	int         _free;

	strhtable *_strt;

	// read file.
	std::string                     _filename;
	std::fstream                    _fd;

	std::string                     _tname;
	int                             _headline;
	int                             _typeline;
	int                             _dataline;
	std::map<std::string, uint32_t>			 _head;
	std::map<uint32_t, value_t::value_tt>    _type;
	std::vector<std::map<uint32_t, value_t> *>        _table;
	std::map<MKT, std::map<uint32_t, value_t> *>      _rows;

	std::map<std::string, value_t::value_tt>    _types;
	std::map<value_t::value_tt, std::string>    _rtypes;
};

template<typename MKT, int MK, typename R>
csv<MKT, MK, R>::csv(strhtable *strt)
	:this()
	_data(NULL)
	, _size(0)
	, _cap(0)
	, _free(0)
	, _strt(strt)
	, _filename()
	, _fd()
	, _headline(0)
	, _typeline(0)
	, _dataline(0)
	, _head()
	, _type()
	, _table()
	, _rows() {
	constructor(strt, _filename, _headline, _typeline, _dataline);
}

template<typename MKT, int MK, typename R>
csv<MKT, MK, R>::csv(strhtable *strt, std::string filename, int headline, int typeline, int dataline)
	: _data(NULL)
	, _size(0)
	, _cap(0)
	, _free(0)
	, _strt(strt)
	, _filename(filename)
	, _fd()
	, _headline(headline)
	, _typeline(typeline)
	, _dataline(dataline)
	, _head()
	, _type()
	, _table()
	, _rows() {
	constructor(strt, _filename, _headline, _typeline, _dataline);
}

template<typename MKT, int MK, typename R>
csv<MKT, MK, R>::~csv() {
	for (auto iter = _table.begin(); iter != _table.end(); iter++) {
		delete *iter;
	}
	_table.clear();
	_rows.clear();
}

template<typename MKT, int MK, typename R>
bool csv<MKT, MK, R>::load(std::string filename, int headline, int typeline, int dataline) {
	_filename = filename;
	_headline = headline;
	_typeline = typeline;
	_dataline = dataline;

	_fd.open(filename, std::ios::in | std::ios::binary);
	if (!_fd.is_open()) {
		_fd.clear();
		_fd.close();
		return false;
	}

	std::map<uint32_t, value_t> *row = create_row();
	std::string word;

	int col = 1;
	int line = 1;
	while (!_fd.eof()) {
		uint8_t s = _fd.get();
		if (s == 0xef) {
		} else if (s == 0x0d) { // /r
			push_word(row, line, col, word);
			word.clear();
			col++;

			// 判断下一个字符
			s = _fd.get();
			if (s == 0x0a) { // /n
			} else {
				word.push_back(s);
			}

			push_row(row, line);
			row = create_row();

			line++;
			col = 1;
		} else if (s == 0x0a) {  // /n
			push_word(row, line, col, word);
			word.clear();
			col++;

			push_row(row, line);
			row = create_row();

			line++;
			col = 1;
		} else if (s == ',') {
			push_word(row, line, col, word);
			word.clear();
			col++;
		} else {
			word.push_back(s);
		}
	}
	_fd.close();
	return true;
}

template<typename MKT, int MK, typename R>
bool csv<MKT, MK, R>::is_integer(std::string str) {
	bool res = false;
	if (str.length() <= 0) {
		return res;
	}
	for (auto iter = str.begin(); iter != str.end(); iter++) {
		if (*iter <= 57 && *iter >= 48) {
		} else {
			return res;
		}
	}
	res = true;
	return res;
}

template<typename MKT, int MK, typename R>
bool csv<MKT, MK, R>::is_float(std::string str) {
	return true;
}

template<typename MKT, int MK, typename R>
void csv<MKT, MK, R>::flush(std::string path) {
	std::string word;
	std::istringstream iss(path);

	while (!iss.eof()) {
		char c = iss.get();
		if (c == ':') {
			word.clear();
		} else if (c == '/') {
			word.clear();
		} else if (c == '\\') {
			c = iss.get();
			if (c == '\\') {
			} else {
				word.push_back(c);
			}
		} else if (c == -1) {
			int t = 3;
		} else {
			word.push_back(c);
		}
	}

	std::string filename = word;
	std::ofstream ofs(path + ".h", std::ios::out);


	if (!ofs.is_open()) {
		ofs.clear();
		ofs.close();
		return;
	}

	ofs << "#ifndef" << " ";
	for (auto iter = filename.begin(); iter != filename.end(); iter++) {
		uint8_t c = std::toupper(*iter);
		ofs << c;
	}
	ofs << "_H" << std::endl;

	ofs << "#define" << " ";
	for (auto iter = filename.begin(); iter != filename.end(); iter++) {
		uint8_t c = std::toupper(*iter);
		ofs << c;
	}
	ofs << "_H" << std::endl;
	ofs << std::endl;
	ofs << "#include <cstdint>" << std::endl;
	ofs << "#include <string>" << std::endl;
	ofs << std::endl;
	ofs << "class " << " " << filename << " {" << std::endl;
	ofs << "public:" << std::endl;
	ofs << '\t' << filename << "();" << std::endl;
	ofs << '\t' << "~" << filename << "();" << std::endl;
	ofs << '\t' << "uint32_t mk() const;" << std::endl;
	ofs << '\t' << "void fill_field(int col, std::string &word);" << std::endl;
	ofs << std::endl;
	for (auto iter = _head.begin(); iter != _head.end(); iter++) {
		ofs << '\t' << _rtypes[_type[iter->first]] << ' ' << _head[iter->first] << ";" << std::endl;
	}
	ofs << "};" << std::endl;
	ofs << "#endif" << std::endl;

	ofs.flush();
	ofs.close();
	ofs.clear();
	ofs.open(path + ".cpp", std::ios::out);

	ofs << "#include \"stdafx.h\"" << std::endl;
	ofs << "#include \"gemstone.h\"" << std::endl;
	ofs << std::endl;
	ofs << "#include <cstdlib>" << std::endl;
	ofs << std::endl;
	ofs << filename << "::" << filename << "()" << " " << "{}" << std::endl;
	ofs << filename << "::" << "~" << filename << "()" << " " << "{}" << std::endl;
	ofs << _rtypes[_type[MK]] << " " << filename << "::" << "mk() const {" << std::endl;
	ofs << "\t" << "return " << _head[MK] << ";" << std::endl;
	ofs << "};" << std::endl;

	ofs << "void " << filename << "::fill_field(int col, std::string &word) {" << std::endl;

	ofs << "\t" << "if (col == 0) {" << std::endl;
	ofs << "}" << std::endl;
	for (auto iter = _head.begin(); iter != _head.end(); iter++) {
		ofs << "else if (col == " << iter->first << ") {" << std::endl;
		if (_type[iter->first] == dtype::UINT32_T) {
			ofs << "\t\t" << iter->second << " = std::atoi(word.data());" << std::endl;
		} else {
			ofs << "\t\t" << iter->second << " = word;" << std::endl;
		}
		ofs << "\t}" << std::endl;
	}
	ofs << "}" << std::endl;
	ofs.flush();
	ofs.close();

}

template<typename MKT, int MK, typename R>
void csv<MKT, MK, R>::push_word(std::map<uint32_t, value_t> *row, int line, int col, std::string &word) {
	if (line == _headline) {
		value_t v;
		std::string *s = _strt->insert(word);
		v.set_string(s);
		row->emplace(std::make_pair(col, v));

		if (_head.find(word) != _head.end()) {
			assert(false);
		} else {
			_head.emplace(std::make_pair(word, col));
		}
	} else if (line == _typeline) {
		value_t v;
		std::string *s = _strt->insert(word);
		v.set_string(s);
		row->emplace(std::make_pair(col, v));
		
		if (_types.find(word) != _types.end()) {
			_type[col] = _types[word];
		} else {
			throw std::exception("no exit type.");
		}
	} else if (line >= _dataline) {
		value_t v;
		if (_type[col] == value_t::UINT32_T) {
			assert(is_integer(word));
			uint32_t ui = std::atoi(word.data());
			v.set_uint32(ui);
		} else if (_type[col] == value_t::STRING) {
			std::string *s = _strt->insert(word);
			v.set_string(s);
		} else {
			assert(false);
		}
		row->emplace(std::make_pair(col, v));
	} else {
		// 这里一般是注释
		value_t v;
		std::string *s = _strt->insert(word);
		v.set_string(s);
		row->emplace(std::make_pair(col, v));
	}
}

template<typename MKT, int MK, typename R>
void csv<MKT, MK, R>::push_row(std::map<uint32_t, value_t> *row, int line) {
	_table.push_back(row);

	// 索引
	if (line >= _dataline) {
		int idx = MK;
		if (auto iter = row->find(idx) != row->end()) {
			_rows[iter->second] = row;
			//iter->second;
			/*value_t *v = &(iter->second);
			_rows[v] = row;*/
		}
	}
}

#endif // !CSV_H
