﻿#ifndef PROTOC_H
#define PROTOC_H

#include <assert.h>
#include <math.h>
#include <stdint.h>
#include <string.h>

union if32 {
    int32_t i;
    float f;
};

union if64 {
    int64_t i;
    double f;
};

static int
CheckEnd()
{
    int i = 0x12345678;
    char* c = (char*)&i;
    return (*c == 0x12); // bd
}

static int
WriteUInt8(uint8_t* ptr, int ofs, uint8_t val)
{
    ptr[ofs] = val;
    return (ofs + 1);
}

static int
WriteInt16(uint8_t* ptr, int ofs, int16_t val)
{
    if (CheckEnd()) { // bd
        ptr[ofs] = val & 0xff;
        ptr[ofs + 1] = (val << 8) & 0xff;
        return ofs + 2;
    } else {
        int len = 2;
        int i = ofs + len - 1;
        for (; i >= ofs; --i) {
            ptr[i] = (char)((val >> (len - 1 - i) * 8) & 0xff);
        }
        return (ofs + 2);
    }
}

static int
WriteInt32(uint8_t* ptr, int ofs, int32_t val)
{
    if (CheckEnd()) {
        ptr[ofs] = val & 0xff;
        ptr[ofs + 1] = val << 8 & 0xff;
        ptr[ofs + 2] = val << 16 & 0xff;
        ptr[ofs + 3] = val << 24 & 0xff;
        return ofs + 4;
    } else {
        for (size_t i = 0; i < 4; i++) {
            ptr[ofs + i] = (val >> (8 * i)) & 0xff;
        }
        return (ofs + 4);
    }
}

static int
WriteInt64(uint8_t* ptr, int ofs, int64_t val)
{
    if (CheckEnd()) {
        ptr[ofs] = val & 0xff;
        ptr[ofs + 1] = val << 8 & 0xff;
        ptr[ofs + 2] = val << 16 & 0xff;
        ptr[ofs + 3] = val << 24 & 0xff;
        ptr[ofs + 4] = val << 32 & 0xff;
        ptr[ofs + 5] = val << 40 & 0xff;
        ptr[ofs + 6] = val << 48 & 0xff;
        ptr[ofs + 7] = val << 56 & 0xff;
        return ofs + 8;
    } else {
        for (size_t i = 0; i < 8; i++) {
            ptr[ofs + i] = (val >> (8 * i)) & 0xff;
        }
        return (ofs + 8);
    }
}

static int
WriteFnt32(uint8_t* ptr, int ofs, float val)
{
    union if32 x;
    x.f = val;
    return WriteInt32(ptr, ofs, x.i);
}

static int
WriteFnt64(uint8_t* ptr, int ofs, double val)
{
    union if64 x;
    x.f = val;
    return WriteInt64(ptr, ofs, x.i);
}

static int
WriteString(uint8_t* ptr, int ofs, const char* src, int len)
{
    ofs = WriteInt32(ptr, ofs, len);
    memcpy(ptr + ofs, src, len);
    return (ofs + len);
}

static int
ReadUInt8(const uint8_t* ptr, int ofs, uint8_t* val)
{
    if (CheckEnd()) {
        *val = ptr[ofs];
        return ofs + 1;
    } else {
        int len = 1;
        uint8_t res = 0;
        for (int i = 0; i < len; i++) {
            res |= ptr[ofs + i] << (8 * i);
        }
        *val = res;
        return (ofs + len);
    }
}

static int
ReadInt16(const uint8_t* ptr, int ofs, int16_t* val)
{
    if (CheckEnd()) {
        *val = 0;
        *val |= ptr[ofs];
        *val |= ptr[ofs + 1] >> 8;
        return ofs + 2;
    } else {
        size_t len = 2;
        int16_t res = 0;
        for (size_t i = 0; i < len; i++) {
            const uint8_t* p = ptr + ofs + i;
            int16_t t = *p;
            t = (t << ((len - i - 1) * 8)) & 0xffffffff;
            res |= t;
        }
        *val = res;
        return (ofs + len);
    }
}

static int
ReadInt32(const uint8_t* ptr, int ofs, int32_t* val, int n)
{
    if (CheckEnd()) {
        *val = 0;
        *val |= ptr[ofs];
        *val |= ptr[ofs + 1] >> 8;
        *val |= ptr[ofs + 2] >> 16;
        *val |= ptr[ofs + 3] >> 24;
        return ofs + 4;
    } else {
        size_t len = 4;
        int32_t res = 0;
        for (size_t i = 0; i < len; i++) {
            res |= ptr[ofs + i] << (8 * i);
        }
        *val = res;
        return (ofs + len);
    }
}

static int
ReadInt64(const uint8_t* ptr, int ofs, int64_t* val, int n)
{
#if defined(_DEBUG)
    assert((ofs + 8) < n);
#endif
    if ((ofs + 8) < n) {
        size_t len = 8;
        int64_t res = 0;
        for (size_t i = 0; i < len; i++) {
            res |= ptr[ofs + i] << (8 * i);
        }
        *val = res;
        return (ofs + len);
    } else {
        return ofs;
    }
}

static int
ReadFnt32(const uint8_t* ptr, int ofs, float* val, int n)
{
#if defined(_DEBUG)
    assert((ofs + 8) < n);
#endif
    size_t len = 4;
    int32_t res = 0;
    for (size_t i = 0; i < len; i++) {
        res |= ptr[ofs + i] << (8 * i);
    }

    union if32 u;
    u.i = res;
    *val = u.f;
    return (ofs + len);
}

static int
ReadFnt64(const uint8_t* ptr, int ofs, double* val, int n)
{
    size_t len = 8;
    int64_t res = 0;
    for (size_t i = 0; i < len; i++) {
        res |= ptr[ofs + i] << (8 * i);
    }
    union if64 u;
    u.i = res;
    *val = u.f;
    return (ofs + len);
}

static int
ReadString(char* ptr, int ofs, char** val, size_t* size)
{
    if (CheckEnd()) {

    } else {
        /*int len = 0;
		ofs = ReadInt32(ptr, ofs, &len, n);
		int m = min(len, *size);
		memcpy(val, ptr + ofs, m);
		*size = m;
		return (ofs + len);*/
        return 0;
    }
}

#endif // !PACK_H