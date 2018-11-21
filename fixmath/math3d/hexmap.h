#ifndef HEXMAP_H
#define HEXMAP_H

#ifdef __cplusplus
extern "C" {
#endif

#if defined(FIXEDPT)
#define UNIT_T struct HexWaypoint *
#include "fixedptmath3d.h"
#include <base/binheap.h>
#else
#include <cstdafx.h>
#include <stdint.h>
#endif // FIXEDPT

#define MAX_PATH_NUM 20

typedef enum {
	NONE,
} MapState;

typedef enum {
	FLAT,
	POINTY,
} MapOrientation;

struct CubeCoord {
	int q;
	int r;
	int s;
};

#ifdef FIXEDPT
struct FractionalCubeCoord {
	fix16_t q; // x
	fix16_t r; // z
	fix16_t s; // y
};
#else
struct FractionalCubeCoord {
	double q; // x
	double r; // z
	double s; // y
};
#endif // FIXEDPT

struct OffsetCoord {
	int c;
	int r;
};

struct AxialCoord {
	int q;   // col
	int r;	 // row
};

struct HexMap;

struct HexAStar {
	int f;
	int g;
	int h;
	int free;
	struct Hex *hex;
	struct HexAStar *next, *prev;
};

/*
** cube coordinates
*/
struct Hex {
	struct HexMap     *map;
	struct CubeCoord   main;
	struct OffsetCoord offset;
	struct AxialCoord  axial;
	struct vector3     pos;
	float              height;
	MapState           state;
	void              *ud;

	// 双向链表构建格子，避免内存浪费，对于有很多空格的时候
	struct Hex       *neighbor[6];
	struct Hex *next, *prev;    // 内存
};

struct Hex *hex_create(struct HexMap *map_, void *ud_);
struct Hex *hex_create_axial(struct HexMap *map_, struct AxialCoord axial_, void *ud_);
struct Hex *hex_add(struct Hex *self, struct Hex *other);
struct Hex *hex_subtract(struct Hex *self, struct Hex *other);
int64_t     hex_toindex(struct Hex *self);

#ifdef FIXEDPT
struct Orientation {
	fix16_t f0;
	fix16_t f1;
	fix16_t f2;
	fix16_t f3;
	fix16_t b0;
	fix16_t b1;
	fix16_t b2;
	fix16_t b3;
	fix16_t start_angle;
};

struct Layout {
	struct Orientation orientation;
	struct vector3     origin;
	fix16_t            innerRadis;
	fix16_t            outerRadis;
};
#else
struct Orientation {
	double f0;
	double f1;
	double f2;
	double f3;
	double b0;
	double b1;
	double b2;
	double b3;
	double start_angle;
};

struct Layout {
	struct Orientation orientation;
	struct vector3     origin;
	float              innerRadis;
	float              outerRadis;
};
#endif // FIXEDPT

static int HexComp(struct Hex *lhs, struct Hex *rhs) {
	/*return left->pathState.*/
}

struct HexMapAStar {
	int pathid;
	int free;
	struct vector3   startPos;
	struct vector3   exitPos;
	struct Hex      *nextHex;
	struct Hex      *exitHex;
	binary_heap_t   *open;
	struct HexAStar *closed;
};

struct HexMap {
	struct Layout layout;
	struct HexMapAStar   pathState[MAX_PATH_NUM];

	struct Hex *hash;  // hash
	struct Hex *hexhead;  // pool
	struct HexAStar *hexshead;
};


struct HexMap * hexmap_create_from_plist(const char *src, int len);
struct HexMap * hexmap_create(MapOrientation o, float oradis);
void            hexmap_release(struct HexMap *self);

struct Hex *    hexmap_create_hex(struct HexMap *self);
void            hexmap_release_hex(struct HexMap *self, struct Hex *h);

struct HexAStar * hexmap_create_hexastar(struct HexMap *self);
void              hexmap_release_hexastar(struct HexMap *self, struct HexAStar *h);

struct Hex *    hexmap_find_hex(struct HexMap *self, struct CubeCoord coord);

struct vector3  hexmap_to_position(struct HexMap *self, struct AxialCoord coord);

struct FractionalCubeCoord hexmap_to_cubcoord(struct HexMap *self, struct vector3 p);

int             hexmap_h(struct HexMap *self, struct vector3 startPos, struct vector3 exitPos);

int             hexmap_findpath(struct HexMap *self, struct vector3 startPos, struct vector3 exitPos);

int             hexmap_findpath_update(struct HexMap *self, int pathid, struct Hex **h);

int             hexmap_findpath_clean(struct HexMap *self, int pathid);

#ifdef __cplusplus
}
#endif

#endif