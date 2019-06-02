#ifndef HEXMAP_H
#define HEXMAP_H

#ifdef __cplusplus
extern "C" {
#endif

#include "bh_wp.h"
#include "uthash.h"
#include "../math3d.h"

#define NEIGHBOR_NUM (6)
#define DIAGONAL_NUM (6)
#define PATH_NUM     (128)
#define KEY_LEN      (32)

typedef enum {
	RECT,
	HEX,
	PARRALL,
	TRI,
} MapShape;

typedef enum {
	POINTY,
	FLAT,
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
#endif // fix16_t

struct OffsetCoord {
	int c;
	int r;
};

struct AxialCoord {
	int q;   // col
	int r;	 // row
};

typedef enum {
	NORMAL = 0,
	BLOCK,
	TREE,
} HexState;

/*
** cube coordinates
*/
struct HexMap;
struct Hex {
	struct HexMap     *map;

	// index
	struct CubeCoord   main;
	struct OffsetCoord offset;
	struct AxialCoord  axial;
	struct vector3     pos;

	// state
#ifdef FIXEDPT
	fix16_t            height;
#else
	float              height;
#endif // FIXEDPT
	HexState           state;
	void              *ud;

	// hash
	char               key[KEY_LEN];
	UT_hash_handle     hh;

	// 双向链表构建格子，避免内存浪费，对于有很多空格的时候
	struct Hex        *neighbor[NEIGHBOR_NUM];
	struct Hex *next, *prev;    // 内存
};

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
	int                width;
	int                height;
	MapShape           shape;
	MapOrientation     orient;
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
	int                width;
	int                height;
	MapShape           shape;
	MapOrientation     orient;
};
#endif // fix16_t

struct HexWaypoint {
	int f;
	int g;
	int h;
	int free;
	struct Hex *hex;
	struct HexWaypoint *next, *prev;
};

struct HexWaypointHead {
	int pathid;
	int free;
	struct vector3   startPos;
	struct vector3   exitPos;
	struct Hex      *nextHex;
	struct Hex      *exitHex;
	bh_wp_t          open;
	struct HexWaypoint *closed;
};

struct HexMap {
	struct Layout layout;
	struct HexWaypointHead   pathState[PATH_NUM];

	struct Hex *hexhash;     // hash head
	struct Hex *hexpool;     // pool
	struct HexWaypoint *hexwppool;
	void  *ud;
};

struct HexMap *
hexmap_create_from_plist(const char *src, int len);

 struct HexMap *
hexmap_create(MapOrientation o, 
		float innerRadis,
		MapShape shape,
		int width, 
		int height);

void
hexmap_release(struct HexMap *self);

void
hexmap_save_to_plist(struct HexMap *self, char **buffer, uint32_t *size, char *name);

 struct Hex *
hexmap_create_hex(struct HexMap *self);

 void
hexmap_release_hex(struct HexMap *self, struct Hex *hex);

 struct HexWaypoint *
hexmap_create_waypoint(struct HexMap *self);

 void
hexmap_release_waypoint(struct HexMap *self, struct HexWaypoint *waypoint);

 struct vector3
hexmap_cube_to_position(struct HexMap *self, struct CubeCoord coord);

 struct vector3
hexmap_axial_to_position(struct HexMap *self, struct AxialCoord coord);

 struct FractionalCubeCoord
hexmap_position_to_fcubecoord(struct HexMap *self, struct vector3 position);

 int
hexmap_findpath(struct HexMap *self, struct vector3 startPos, struct vector3 exitPos);

 int
hexmap_findpath_update(struct HexMap *self, int pathid, struct Hex **out);

 int
hexmap_findpath_clean(struct HexMap *self, int pathid);

 struct Hex *
hexmap_find_hex(struct HexMap *self, const char *key);

 void
hexmap_add_hex(struct HexMap *self, struct Hex *h);

 void
hexmap_remove_hex(struct HexMap *self, struct Hex *h);

 int
hexmap_hex_count(struct HexMap *self);

typedef void(*hexmap_foreach_cb)(struct Hex *);

 void
hexmap_foreach(struct HexMap *self, hexmap_foreach_cb cb);

 struct Hex *
hexmap_find_hex_by_position(struct HexMap *self, struct vector3 position);

 struct Hex *
hexmap_find_hex_by_cube(struct HexMap *self, struct CubeCoord coord);

 struct Hex *
hexmap_find_hex_by_axial(struct HexMap *self, struct AxialCoord coord);

 struct Hex *
hexmap_find_hex_by_offset(struct HexMap *self, struct OffsetCoord coord);

#ifdef __cplusplus
}
#endif

#endif