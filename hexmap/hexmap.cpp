#include "hexmap.h"

#ifdef __cplusplus
extern "C" {
#endif

#include <plist/plist.h>
#include <stdio.h>
#include <stdlib.h>
#include <assert.h>
#include <string.h>
#include <math.h>

#ifdef __cplusplus
}
#endif

static int
bh_wp_compare(bh_wp_iterator_t l, bh_wp_iterator_t r) {
	return ((*l)->f > (*r)->f);
}

static int
bh_wp_equal(bh_wp_iterator_t l, bh_wp_iterator_t r) {
	return ((*l)->hex == (*r)->hex);
}

static void
bh_wp_free(bh_wp_iterator_t i) {
	hexmap_release_waypoint((*i)->hex->map, *i);
}


#ifdef FIXEDPT
static fix16_t fix16_half = fix16_div(fix16_one, fix16_from_int(2));
#else
#include <math.h>
static float M_PI = 3.14159265359f;
static float M_SQR3 = 1.7320508076;
#endif // !FIXEDPT

#ifndef max
#define max(a, b) ((a) > (b) ? (a) : (b))
#endif // !max
#ifndef min
#define min(a, b) ((a) > (b) ? (b) : (a))
#endif // !min

static struct CubeCoord hex_directions[NEIGHBOR_NUM] = { {1, 0, -1}, {1, -1, 0}, {0, -1, 1}, {-1, 0, 1}, {-1, 1, 0}, {0, 1, -1} };
static struct CubeCoord hex_diagonals[DIAGONAL_NUM] = { {2, -1, -1}, {1, -2, 1}, {-1, -1, 2}, {-2, 1, 1}, {-1, 2, -1}, {1, 1, -2} };

static inline struct Orientation layout_pointy() {
#ifdef FIXEDPT
	fix16_t fp3 = fix16_from_int(3);
	fix16_t fp2 = fix16_from_int(2);

	struct Orientation o;
	o.f0 = fix16_sqrt(fp3);
	o.f1 = fix16_div(fix16_sqrt(fp3), fp2);
	o.f2 = 0;
	o.f3 = fix16_div(fp3, fp2);
	o.b0 = fix16_div(fix16_sqrt(fp3), fp3);
	o.b1 = fix16_div(fix16_sub(0, fix16_one), fp3);
	o.b2 = 0;
	o.b3 = fix16_div(fp2, fp3);
	o.start_angle = fix16_half;
	return o;
#else
	struct Orientation o;
	o.f0 = sqrt(3.0f);
	o.f1 = sqrt(3.0f);
	o.f2 = 0.0f;
	o.f3 = 3.0f / 2.0f;
	o.b0 = sqrt(3.0f) / 3.0f;
	o.b1 = -1.0f / 3.0f;
	o.b2 = 0.0f;
	o.b3 = 2.0f / 3.0f;
	o.start_angle = 0.5f;
	return o;
#endif // FIXEDPT
}

static inline struct Orientation layout_flat() {
#ifdef FIXEDPT
	fix16_t FIXEDPT3 = fix16_from_int(3);
	fix16_t FIXEDPT2 = fix16_from_int(2);

	struct Orientation o;
	o.f0 = fix16_div(FIXEDPT3, FIXEDPT2);
	o.f1 = 0;
	o.f2 = fix16_div(fix16_sqrt(FIXEDPT3), FIXEDPT2);
	o.f3 = fix16_sqrt(FIXEDPT3);

	o.b0 = fix16_div(FIXEDPT2, FIXEDPT3);
	o.b1 = 0;
	o.b2 = fix16_div(fix16_neg(fix16_one), FIXEDPT3);
	o.b3 = fix16_div(fix16_sqrt(FIXEDPT3), FIXEDPT2);

	o.start_angle = 0;

	return o;
#else
	return  { 3.0 / 2.0, 0.0, sqrt(3.0) / 2.0, sqrt(3.0), 2.0 / 3.0, 0.0, -1.0 / 3.0, sqrt(3.0) / 3.0, 0.0 };
#endif // FIXEDPT
}

//static struct Orientation layout_pointy = { sqrt(3.0), sqrt(3.0) / 2.0, 0.0, 3.0 / 2.0, sqrt(3.0) / 3.0, -1.0 / 3.0, 0.0, 2.0 / 3.0, 0.5 };
//static struct Orientation layout_flat = { 3.0 / 2.0, 0.0, sqrt(3.0) / 2.0, sqrt(3.0), 2.0 / 3.0, 0.0, -1.0 / 3.0, sqrt(3.0) / 3.0, 0.0 };

static inline struct CubeCoord cubecoord_add(struct CubeCoord a, struct CubeCoord b) {
	return { a.q + b.q, a.r + b.r, a.s + b.s };
}

static inline struct CubeCoord cubecoord_subtract(struct CubeCoord a, struct CubeCoord b) {
	return { a.q - b.q, a.r - b.r, a.s - b.s };
}

static inline struct CubeCoord cubecoord_scale(struct CubeCoord a, int k) {
	return { a.q * k, a.r * k, a.s * k };
}

static inline struct CubeCoord cubecoord_direction(int direction) {
	return hex_directions[direction];
}

static inline struct CubeCoord cubecoord_neighbor(struct CubeCoord hex, int direction) {
	return cubecoord_add(hex, cubecoord_direction(direction));
}

static inline int cubecoord_neighbor_direction(struct CubeCoord hex) {
	for (size_t i = 0; i < NEIGHBOR_NUM; i++) {
		if (hex_directions[i].q == hex.q &&
			hex_directions[i].r == hex.r &&
			hex_directions[i].s == hex.s) {
			return i;
		}
	}
	return -1;
}

static inline struct CubeCoord cubecoord_diagonal_neighbor(struct CubeCoord hex, int direction) {
	return cubecoord_add(hex, hex_diagonals[direction]);
}

static inline int cubecoord_length(struct CubeCoord hex) {
	return (int)((abs(hex.q) + abs(hex.r) + abs(hex.s)) / 2);
}

static inline int cubecoord_distance(struct CubeCoord a, struct CubeCoord b) {
	return cubecoord_length(cubecoord_subtract(a, b));
}

static inline int cube_to_index(struct CubeCoord h, char *src, int len) {
	snprintf(src, len, "Hex[%d, %d, %d]", h.q, h.r, h.s);
	return 1;
}

static const int EVEN = 1;
static const int ODD = -1;
static inline struct OffsetCoord qoffset_from_cube(int offset, struct CubeCoord h) {
	struct OffsetCoord coord;
	coord.c = h.q;
	coord.r = h.r + (int)((h.q + offset * (h.q & 1)) / 2);
	return coord;
}

static inline struct CubeCoord qoffset_to_cube(int offset, struct OffsetCoord h) {
	struct CubeCoord coord;
	coord.q = h.c;
	coord.r = h.r - (int)((h.c + offset * (h.c & 1)) / 2);
	coord.s = -coord.q - coord.r;
	return coord;
}

static inline struct OffsetCoord roffset_from_cube(int offset, struct CubeCoord h) {
	struct OffsetCoord coord;
	coord.c = h.q + (int)((h.r + offset * (h.r & 1)) / 2);
	coord.r = h.r;
	return coord;
}

static inline struct CubeCoord roffset_to_cube(int offset, struct OffsetCoord h) {
	struct CubeCoord coord;
	coord.q = h.c - (int)((h.r + offset * (h.r & 1)) / 2);
	coord.r = h.r;
	coord.s = -coord.q - coord.r;
	return coord;
}

static inline struct CubeCoord axial_to_cube(struct AxialCoord h) {
	struct CubeCoord coord;
	coord.q = h.q;
	coord.r = h.r;
	coord.s = -h.q - h.r;
	return coord;
}

static inline struct AxialCoord cube_to_axial(struct CubeCoord h) {
	struct AxialCoord coord;
	coord.q = h.q;
	coord.r = h.r;
	return coord;
}

static inline struct CubeCoord hex_round(struct FractionalCubeCoord h) {
#ifdef FIXEDPT

	int q = (int)(fix16_to_int(h.q));
	int r = (int)(fix16_to_int(h.r));
	int s = (int)(fix16_to_int(h.s));

	fix16_t q_diff = fix16_abs(fix16_sub(fix16_to_int(q), h.q));
	fix16_t r_diff = fix16_abs(fix16_sub(fix16_to_int(r), h.r));
	fix16_t s_diff = fix16_abs(fix16_sub(fix16_to_int(s), h.s));
	if (q_diff > r_diff && q_diff > s_diff) {
		q = -r - s;
	} else
		if (r_diff > s_diff) {
			r = -q - s;
		} else {
			s = -q - r;
		}
	return { q, r, s };
#else
	int q = (int)(round(h.q));
	int r = (int)(round(h.r));
	int s = (int)(round(h.s));
	double q_diff = fabs(q - h.q);
	double r_diff = fabs(r - h.r);
	double s_diff = fabs(s - h.s);
	if (q_diff > r_diff && q_diff > s_diff) {
		q = -r - s;
	} else {
		if (r_diff > s_diff) {
			r = -q - s;
		} else {
			s = -q - r;
		}
	}
	struct CubeCoord coord = { q, r, s };
	return coord;
#endif // FIXEDPT
}

/*
** @breif 此函数有问题
*/
//static inline struct FractionalCubeCoord hex_lerp(struct FractionalCubeCoord a, struct FractionalCubeCoord b, double t) {
//	return { a.q * (1 - t) + b.q * t, a.r * (1 - t) + b.r * t, a.s * (1 - t) + b.s * t };
//}


//vector<Hex> hex_linedraw(Hex a, Hex b) {
//	int N = hex_distance(a, b);
//	FractionalHex a_nudge = FractionalHex(a.q + 0.000001, a.r + 0.000001, a.s - 0.000002);
//	FractionalHex b_nudge = FractionalHex(b.q + 0.000001, b.r + 0.000001, b.s - 0.000002);
//	vector<Hex> results = {};
//	double step = 1.0 / max(N, 1);
//	for (int i = 0; i <= N; i++) {
//		results.push_back(hex_round(hex_lerp(a_nudge, b_nudge, step * i)));
//	}
//	return results;
//}

static void
hexmap_build_neighbor(struct HexMap *self) {
	struct Hex *h, *tmp;
	HASH_ITER(hh, self->hexhash, h, tmp) {
		for (size_t i = 0; i < NEIGHBOR_NUM; i++) {
			struct CubeCoord neighbor_coord = cubecoord_neighbor(h->main, i);
			struct Hex *neighbor = hexmap_find_hex_by_cube(self, neighbor_coord);
			if (neighbor != NULL) {
				h->neighbor[i] = neighbor;
			}
		}
	}
}

struct HexMap *
	hexmap_create_from_plist(const char *src, int len) {

	plist_t root = NULL;
	plist_from_xml(src, len, &root);
	if (!root) {
		printf("PList XML parsing failed\n");
		return NULL;
	}

	struct HexMap * inst = (struct HexMap *)malloc(sizeof(*inst));
	memset(inst, 0, sizeof(*inst));
	if (PLIST_IS_DICT(root)) {
		char *name = NULL;
		uint64_t width, height, shape, orient, innerRadis;
		plist_get_string_val(plist_dict_get_item(root, "name"), (char **)&name);
		plist_get_uint_val(plist_dict_get_item(root, "width"), &width);
		plist_get_uint_val(plist_dict_get_item(root, "height"), &height);
		plist_get_uint_val(plist_dict_get_item(root, "shape"), &shape);
		plist_get_uint_val(plist_dict_get_item(root, "orient"), &orient);
		plist_get_uint_val(plist_dict_get_item(root, "innerRadis"), &innerRadis);

		if (orient == 0) {
			inst->layout.orientation = layout_pointy();
		} else {
			inst->layout.orientation = layout_flat();
		}
		inst->layout.width = width;
		inst->layout.height = height;
		inst->layout.shape = (MapShape)shape;
		inst->layout.orient = (MapOrientation)orient;
		inst->layout.innerRadis = innerRadis;
		float outerRadis = innerRadis * 2.0f / sqrt(3.0f);
		inst->layout.outerRadis = outerRadis;

		plist_t grids_node = plist_dict_get_item(root, "grids");
		uint32_t size = plist_array_get_size(grids_node);
		for (size_t i = 0; i < size; i++) {
			plist_t grid_node = plist_array_get_item(grids_node, i);
			uint64_t g, r, s, state;
			plist_get_uint_val(plist_dict_get_item(grid_node, "g"), &g);
			plist_get_uint_val(plist_dict_get_item(grid_node, "r"), &r);
			plist_get_uint_val(plist_dict_get_item(grid_node, "s"), &s);
			plist_get_uint_val(plist_dict_get_item(grid_node, "state"), &state);

#ifdef FIXEDPT
#else
			double height = 0.0f;
			plist_get_real_val(plist_dict_get_item(grid_node, "height"), &height);
#endif // FIXEDPT

			struct Hex *h = hexmap_create_hex(inst);
			h->axial = { (int)g, (int)r };
			h->main = axial_to_cube(h->axial);
			h->pos = hexmap_axial_to_position(inst, h->axial);
#ifdef FIXEDPT
			//h->height = 
#else
			h->height = height;
#endif // FIXEDPT
			h->state = (HexState)state;
			cube_to_index(h->main, h->key, sizeof(h->key));
			hexmap_add_hex(inst, h);
		}
	}

	hexmap_build_neighbor(inst);
	return inst;
}

static struct HexMap *
hexmap_create_hexsharp(struct HexMap *self,
	int width,
	int height) {

	int mapSize = max(width, height);

	for (int q = -mapSize; q <= mapSize; q++) {
		int r1 = max(-mapSize, -q - mapSize);
		int r2 = min(mapSize, -q + mapSize);
		for (int r = r1; r <= r2; r++) {
			struct Hex *hex = hexmap_create_hex(self);
			struct AxialCoord axial = { q, r };
			struct CubeCoord cube = axial_to_cube(axial);
			struct vector3 position = hexmap_axial_to_position(self, axial);
			hex->axial = axial;
			hex->main = cube;
			hex->pos = position;
			hex->height = 0.0f;
			hex->state = NORMAL;
			cube_to_index(hex->main, hex->key, sizeof(hex->key));
			hexmap_add_hex(self, hex);
		}
	}

	return self;
}

static struct HexMap *
hexmap_create_rectsharp(struct HexMap *self,
	int width,
	int height) {
	for (int q = 0; q < width; q++) {
		int qOff = q >> 1;
		for (int r = 0; r < height - qOff; r++) {
			struct Hex *hex = hexmap_create_hex(self);

			struct OffsetCoord offset = { q, r };
			struct CubeCoord cube = qoffset_to_cube(qOff, offset);
			struct AxialCoord axial = { cube.q, cube.r };
			struct vector3 position = hexmap_axial_to_position(self, axial);

			hex->axial = axial;
			hex->main = cube;
			hex->pos = position;
			cube_to_index(hex->main, hex->key, sizeof(hex->key));
			hexmap_add_hex(self, hex);
		}
	}
	return self;
}

struct HexMap *
	hexmap_create(MapOrientation orient,
		float innerRadis,
		MapShape shape,
		int width,
		int height) {

#ifdef FIXEDPT
	fix16_t FIXEDPT3 = fix16_from_int(3);
	fix16_t FIXEDPT2 = fix16_from_int(2);
	fix16_t innerRadisFP = fix16_from_float(innerRadis);
	fix16_t outerRadisFP = fix16_div(fix16_mul(innerRadisFP, FIXEDPT2), fix16_sqrt(FIXEDPT3));
#else
	float outerRadis = innerRadis * 2.0f / sqrt(3.0f);
#endif // FIXEDPT

	struct vector3 origin = { 0, 0, 0 };
	struct Layout l;
	if (orient == FLAT) {
		l.orientation = layout_flat();

	} else {
		l.orientation = layout_pointy();
	}
	l.origin = origin;
#ifdef FIXEDPT
	l.innerRadis = innerRadisFP;
	l.outerRadis = outerRadisFP;
#else
	l.innerRadis = innerRadis;
	l.outerRadis = outerRadis;
#endif
	l.width = width;
	l.height = height;
	l.shape = shape;
	l.orient = orient;

	struct HexMap *inst = (struct HexMap *)malloc(sizeof(*inst));
	memset(inst, 0, sizeof(*inst));
	inst->layout = l;
	inst->hexhash = NULL;
	inst->hexpool = NULL;
	inst->hexwppool = NULL;
	switch (shape) {
	case RECT:
		hexmap_create_rectsharp(inst, width, height);
		break;
	case HEX:
		hexmap_create_hexsharp(inst, width, height);
		break;
	default:
		assert(false);
		break;
	}
	hexmap_build_neighbor(inst);
	return inst;
}

void
hexmap_release(struct HexMap *self) {
	struct Hex *h, *tmp;
	HASH_ITER(hh, self->hexhash, h, tmp) {
		free(h);
	}
	LL_FOREACH_SAFE(self->hexpool, h, tmp) {
		free(h);
	}
	free(self);
}

PLAY_API void
hexmap_save_to_plist(struct HexMap *self, char **buffer, uint32_t *size, char *name) {
	assert(buffer != NULL && size > 0 && strlen(name) > 0);
	plist_t root = plist_new_dict();
	plist_dict_set_item(root, "name", plist_new_string(name));
	plist_dict_set_item(root, "width", plist_new_uint(self->layout.width));
	plist_dict_set_item(root, "height", plist_new_uint(self->layout.height));
	plist_dict_set_item(root, "shape", plist_new_uint((uint64_t)self->layout.shape));
	plist_dict_set_item(root, "orient", plist_new_uint((uint64_t)self->layout.orient));
	plist_dict_set_item(root, "innerRadis", plist_new_uint(self->layout.innerRadis));

	plist_t grids = plist_new_array();
	struct Hex *h, *tmp;
	HASH_ITER(hh, self->hexhash, h, tmp) {
		plist_t grid = plist_new_dict();
		plist_dict_set_item(grid, "g", plist_new_uint(h->main.q));
		plist_dict_set_item(grid, "r", plist_new_uint(h->main.r));
		plist_dict_set_item(grid, "s", plist_new_uint(h->main.s));
		plist_dict_set_item(grid, "height", plist_new_real(h->height));
		plist_dict_set_item(grid, "state", plist_new_uint(h->state));

		plist_array_append_item(grids, grid);
	}
	plist_dict_set_item(root, "grids", grids);
	plist_to_xml(root, buffer, size);
}

struct Hex *
	hexmap_create_hex(struct HexMap *self) {
	struct Hex *elt, *res;
	int count;
	LL_COUNT(self->hexpool, elt, count);
	if (count > 0) {
		res = self->hexpool->next;
		memset(res, 0, sizeof(*res));
		res->map = self;
		LL_DELETE(self->hexpool, self->hexpool->next);
		return res;
	}
	res = (struct Hex *)malloc(sizeof(*res));
	memset(res, 0, sizeof(*res));
	res->map = self;
	return res;
}

void
hexmap_release_hex(struct HexMap *self, struct Hex *h) {
	assert(self != NULL && h != NULL);
	LL_APPEND(self->hexpool, h);
}

struct HexWaypoint *
	hexmap_create_waypoint(struct HexMap *self) {
	struct HexWaypoint *elt, *res;
	int count;
	LL_COUNT(self->hexwppool, elt, count);
	if (count > 0) {
		res = self->hexwppool->next;
		LL_DELETE(self->hexwppool, self->hexwppool->next);
		return res;
	}
	res = (struct HexWaypoint *)malloc(sizeof(*res));
	return res;
}

void
hexmap_release_waypoint(struct HexMap *self, struct HexWaypoint *h) {
	assert(self != NULL && h != NULL);
	LL_APPEND(self->hexwppool, h);
}

struct vector3
	hexmap_cube_to_position(struct HexMap *self, struct CubeCoord coord) {
	struct AxialCoord axial = cube_to_axial(coord);
	return hexmap_axial_to_position(self, axial);
}


/*              ***
**            *     *
			***     *
		  *     ***
		  *     *
			***
*/
struct vector3
	hexmap_axial_to_position(struct HexMap *self, struct AxialCoord coord) {
	struct Orientation M = self->layout.orientation;
	struct vector3 origin = self->layout.origin;
	struct AxialCoord h = coord;

#ifdef FIXEDPT
	fix16_t x = fix16_mul(fix16_add(fix16_mul(M.f0, fix16_from_int(h.q)), fix16_mul(M.f1, fix16_from_int(h.r))), self->layout.innerRadis);
	fix16_t z = fix16_mul(fix16_add(fix16_mul(M.f2, fix16_from_int(h.q)), fix16_mul(M.f3, fix16_from_int(h.r))), self->layout.innerRadis);

	struct vector3 res;
	res.x = x;
	res.y = 0;
	res.z = z;
#else
	float x = (M.f0 * h.q + M.f1 * h.r) * self->layout.innerRadis;
	float z = (M.f2 * h.q + M.f3 * h.r) * self->layout.innerRadis;
	struct vector3 res;
	res.x = x;
	res.y = 0.0f;
	res.z = z;
#endif // FIXEDPT
	return res;
}

int
hexmap_get_pathid(struct HexMap *self) {
	int i = 0;
	for (; i < PATH_NUM; i++) {
		if (self->pathState[i].free == 0) {
			return i;
		}
	}
	return -1;
}

/*
** -        -
** | f0, f1 |    * | q |  = | x |
** | f2, f3 |      | r |    | y |
** -        -
** 求逆矩阵
** | q | = | f0, f1 |-1 * | x |
** | r |   | f2, f3 |     | y |
*/
struct FractionalCubeCoord
	hexmap_position_to_fcubecoord(struct HexMap *self, struct vector3 p) {
	struct Orientation M = self->layout.orientation;
	struct vector3 origin = self->layout.origin;

#ifdef FIXEDPT
	struct vector3 pt;
	pt.x = fix16_div(fix16_sub(p.x, origin.x), self->layout.innerRadis);
	pt.z = fix16_div(fix16_sub(p.z, origin.z), self->layout.innerRadis);

	fix16_t q = fix16_add(fix16_mul(M.b0, pt.x), fix16_mul(M.b1, pt.z));
	fix16_t r = fix16_add(fix16_mul(M.b2, pt.x), fix16_mul(M.b3, pt.z));

	struct FractionalCubeCoord coord;
	coord.q = q;
	coord.r = r;
	coord.s = fix16_sub(fix16_neg(q), r);
	return coord;

#else
	struct vector3 pt;
	pt.x = (p.x - origin.x) / self->layout.innerRadis;
	pt.z = (p.z - origin.z) / self->layout.innerRadis;
	double q = M.b0 * pt.x + M.b1 * pt.z;
	double r = M.b2 * pt.x + M.b3 * pt.z;
	struct FractionalCubeCoord coord = { q, r, -q - r };
	return coord;
#endif // FIXEDPT

}

static int
hexmap_h(struct HexMap *self, struct vector3 startPos, struct vector3 exitPos) {
#ifdef FIXEDPT
	return fix16_add(fix16_abs(fix16_sub(exitPos.x, startPos.x)), fix16_abs(fix16_sub(exitPos.z, startPos.z)));
#else
	return fabs(exitPos.x - startPos.x) + fabs(exitPos.z - startPos.z);
#endif // FIXEDPT
}

static int
hexastar_compare(void *lhs, void *rhs) {
	return (((struct HexWaypoint *)(lhs))->f < ((struct HexWaypoint *)(rhs))->f);
}

static int
hexastar_equal(struct HexWaypoint * lhs, struct HexWaypoint * rhs) {

	if (((struct HexWaypoint *)lhs)->hex == ((struct HexWaypoint *)rhs)->hex && ((struct HexWaypoint *)lhs)->hex != NULL) {
		return 0;
	}
	return 1;
}

int
hexmap_findpath(struct HexMap *self, struct vector3 startPos, struct vector3 exitPos) {

	int pathid = hexmap_get_pathid(self);
	self->pathState[pathid].free = 1;
	self->pathState[pathid].pathid = pathid;
	self->pathState[pathid].startPos = startPos;
	self->pathState[pathid].exitPos = exitPos;
	struct CubeCoord coord = hex_round(hexmap_position_to_fcubecoord(self, exitPos));
	self->pathState[pathid].exitHex = hexmap_find_hex_by_cube(self, coord);
	self->pathState[pathid].open = bh_wp_new(bh_wp_compare, bh_wp_free);
	self->pathState[pathid].closed = NULL;

	struct HexWaypoint *tmp = hexmap_create_waypoint(self);
	tmp->g = 0;
	tmp->h = hexmap_h(self, startPos, exitPos);
	tmp->f = tmp->g + tmp->h;

	coord = hex_round(hexmap_position_to_fcubecoord(self, startPos));
	tmp->hex = hexmap_find_hex_by_cube(self, coord);

	LL_APPEND(self->pathState[pathid].closed, tmp);

	return pathid;
}

static void hexastar_visit_free(void *h) {
	struct HexWaypoint *ptr = (struct HexWaypoint *)(h);
	if (ptr) {
		hexmap_release_waypoint(ptr->hex->map, ptr);
	}
}

int
hexmap_findpath_update(struct HexMap *self, int pathid, struct Hex **h) {
	int i = 0;
	for (; i < PATH_NUM; ++i) {
		struct HexWaypointHead *path = &self->pathState[i];
		if (path->free == 1) // 占用
		{
			if (bh_wp_size(&path->open) > 0) {
				bh_wp_iterator_t top = NULL;
				bh_wp_peek(&path->open, &top);
				LL_APPEND(path->closed, *top);

				assert((*top) != NULL);
				struct HexWaypoint *elt, etmp;
				int j = 0;
				for (; j < 6; j++) {
					if ((*top)->hex->neighbor[i] == NULL) continue;

					etmp.hex = (*top)->hex->neighbor[i];

					LL_SEARCH(path->closed, elt, &etmp, hexastar_equal);
					if (elt) // found
					{
						continue;
					}

					bh_wp_iterator_t ret = NULL;
					bh_wp_value_t bhetmp = &etmp;
					bh_wp_search(&path->open, &ret, &bhetmp, bh_wp_equal);
					if (ret != NULL) {
						continue;
					}

					struct HexWaypoint *tmp = hexmap_create_waypoint(self);
					int cost = hexmap_h(self, (*top)->hex->pos, (*top)->hex->neighbor[i]->pos);
					tmp->g = (*top)->g + cost;
					tmp->h = hexmap_h(self, (*top)->hex->neighbor[i]->pos, self->pathState[pathid].exitPos);
					tmp->f = tmp->g + tmp->h;

					bh_wp_push(&path->open, &tmp);
				}
				path->nextHex = (*top)->hex;
			}
		}
	}
	return 0;
}

int
hexmap_findpath_clean(struct HexMap *self, int pathid) {
	struct HexWaypointHead *path = &self->pathState[pathid];

	bh_wp_destroy_free(&path->open, bh_wp_free);

	struct HexWaypoint *elt, *tmp, etmp;
	LL_FOREACH_SAFE(path->closed, elt, tmp) {
		hexmap_release_waypoint(self, elt);
	}

	return 0;
}

struct Hex *
	hexmap_find_hex(struct HexMap *self, const char *key) {
	struct Hex *res = NULL;
	HASH_FIND_STR(self->hexhash, key, res);
	return res;
}

void
hexmap_add_hex(struct HexMap *self, struct Hex *h) {
	assert(h != NULL);
	struct Hex *res = NULL;
	HASH_FIND_STR(self->hexhash, h->key, res);
	if (res == NULL) {
		HASH_ADD_STR(self->hexhash, key, h);
	}
}

void
hexmap_remove_hex(struct HexMap *self, struct Hex *hex) {
	for (size_t i = 0; i < NEIGHBOR_NUM; i++) {
		struct CubeCoord dst = cubecoord_neighbor(hex->main, i);
		struct Hex *h = hexmap_find_hex_by_cube(self, dst);
		if (h != NULL) {
			struct CubeCoord diff = cubecoord_subtract(hex->main, h->main);
			int direction = cubecoord_neighbor_direction(diff);
			assert(direction != -1);
			h->neighbor[direction] = NULL;
		}
	}

	HASH_DEL(self->hexhash, hex);
	hexmap_release_hex(self, hex);
}

int
hexmap_hex_count(struct HexMap *self) {
	return HASH_COUNT(self->hexhash);
}

void
hexmap_foreach(struct HexMap *self, hexmap_foreach_cb cb) {
	struct Hex *h, *tmp;
	HASH_ITER(hh, self->hexhash, h, tmp) {
		cb(h);
	}
}

struct Hex *
	hexmap_find_hex_by_position(struct HexMap *self, struct vector3 position) {
	struct FractionalCubeCoord cube = hexmap_position_to_fcubecoord(self, position);
	struct CubeCoord coord = hex_round(cube);
	char key[KEY_LEN] = { 0 };
	cube_to_index(coord, key, KEY_LEN);
	return hexmap_find_hex(self, key);
}

struct Hex *
	hexmap_find_hex_by_cube(struct HexMap *self, struct CubeCoord coord) {
	char key[KEY_LEN] = { 0 };
	cube_to_index(coord, key, KEY_LEN);
	return hexmap_find_hex(self, key);
}

struct Hex *
	hexmap_find_hex_by_axial(struct HexMap *self, struct AxialCoord coord) {
	struct CubeCoord cube = axial_to_cube(coord);
	char key[KEY_LEN] = { 0 };
	cube_to_index(cube, key, KEY_LEN);
	return hexmap_find_hex(self, key);
}

struct Hex *
	hexmap_find_hex_by_offset(struct HexMap *self, struct OffsetCoord coord) {
	struct CubeCoord cube = qoffset_to_cube(EVEN, coord);
	char key[KEY_LEN] = { 0 };
	cube_to_index(cube, key, KEY_LEN);
	return hexmap_find_hex(self, key);
}