#define LUA_LIB

#include "DetourCommon.h"
#include "DetourNavMesh.h"
#include "DetourNavMeshBuilder.h"
#include "DetourNavMeshQuery.h"
#include "lua.hpp"
#include <array>
#include <iostream>
#include <unordered_map>

/** 安全的释放一个指针内存 */
#define SAFE_RELEASE(i) \
    if (i) {            \
        delete i;       \
        i = NULL;       \
    }

/** 安全的释放一个指针数组内存 */
#define SAFE_RELEASE_ARRAY(i) \
    if (i) {                  \
        delete[] i;           \
        i = NULL;             \
    }

// Returns a random number [0..1)
static float frand()
{
    //	return ((float)(rand() & 0xffff)/(float)0xffff);
    return (float)rand() / (float)RAND_MAX;
}

struct NavMeshSetHeader {
    int version;
    int tileCount;
    dtNavMeshParams params;
};

struct NavMeshTileHeader {
    dtTileRef tileRef;
    int dataSize;
};

struct NavmeshLayer {
    dtNavMesh* pNavmesh;
    dtNavMeshQuery* pNavmeshQuery;
};

struct pathfinding {
    NavmeshLayer navmeshLayer;
    std::string resPath;
};

static const int NAV_ERROR = -1;

static const int MAX_POLYS = 256;
static const int NAV_ERROR_NEARESTPOLY = -2;

static const long RCN_NAVMESH_VERSION = 1;
static const int INVALID_NAVMESH_POLYREF = 0;

static int
lalloc(lua_State* L)
{
    size_t l;
    const char* respath = luaL_checklstring(L, 1, &l);
    struct pathfinding* nav = (struct pathfinding*)lua_newuserdata(L, sizeof(struct pathfinding));

    FILE* fp = fopen(resPath.c_str(), "rb");
    if (!fp) {
        printf("NFCNavigationHandle::create: open({%s}) is error!\n", resPath.c_str());
        return NULL;
    }

    printf("NFCNavigationHandle::create: ({%s}), layer={%d}\n", resPath.c_str(), 0);

    bool safeStorage = true;
    int pos = 0;
    int size = sizeof(NavMeshSetHeader);

    fseek(fp, 0, SEEK_END);
    size_t flen = ftell(fp);
    fseek(fp, 0, SEEK_SET);

    uint8_t* data = new uint8_t[flen];
    if (data == NULL) {
        printf("NFCNavigationHandle::create: open({%s}), memory(size={%d}) error!\n", resPath.c_str(), (int)flen);

        fclose(fp);
        SAFE_RELEASE_ARRAY(data);
        return NULL;
    }

    size_t readsize = fread(data, 1, flen, fp);
    if (readsize != flen) {
        printf("NFCNavigationHandle::create: open({%s}), read(size={%d} != {%d}) error!\n", resPath.c_str(), (int)readsize, (int)flen);

        fclose(fp);
        SAFE_RELEASE_ARRAY(data);
        return NULL;
    }

    if (readsize < sizeof(NavMeshSetHeader)) {
        printf("NFCNavigationHandle::create: open({%s}), NavMeshSetHeader is error!\n", resPath.c_str());

        fclose(fp);
        SAFE_RELEASE_ARRAY(data);
        return NULL;
    }

    NavMeshSetHeader header;
    memcpy(&header, data, size);

    pos += size;

    if (header.version != NFCNavigationHandle::RCN_NAVMESH_VERSION) {
        printf("NFCNavigationHandle::create: navmesh version({%d}) is not match({%d})!\n", header.version, ((int)NFCNavigationHandle::RCN_NAVMESH_VERSION));

        fclose(fp);
        SAFE_RELEASE_ARRAY(data);
        return NULL;
    }

    dtNavMesh* mesh = dtAllocNavMesh();
    if (!mesh) {
        printf("NavMeshHandle::create: dtAllocNavMesh is failed!\n");
        fclose(fp);
        SAFE_RELEASE_ARRAY(data);
        return NULL;
    }

    dtStatus status = mesh->init(&header.params);
    if (dtStatusFailed(status)) {
        printf("NFCNavigationHandle::create: mesh init is error({%d})!\n", status);
        fclose(fp);
        SAFE_RELEASE_ARRAY(data);
        return NULL;
    }

    // Read tiles.
    bool success = true;
    for (int i = 0; i < header.tileCount; ++i) {
        NavMeshTileHeader tileHeader;
        size = sizeof(NavMeshTileHeader);
        memcpy(&tileHeader, &data[pos], size);
        pos += size;

        size = tileHeader.dataSize;
        if (!tileHeader.tileRef || !tileHeader.dataSize) {
            success = false;
            status = DT_FAILURE + DT_INVALID_PARAM;
            break;
        }

        unsigned char* tileData = (unsigned char*)dtAlloc(size, DT_ALLOC_PERM);
        if (!tileData) {
            success = false;
            status = DT_FAILURE + DT_OUT_OF_MEMORY;
            break;
        }
        memcpy(tileData, &data[pos], size);
        pos += size;

        status = mesh->addTile(tileData, size, (safeStorage ? DT_TILE_FREE_DATA : 0), tileHeader.tileRef, 0);

        if (dtStatusFailed(status)) {
            success = false;
            break;
        }
    }

    fclose(fp);
    SAFE_RELEASE_ARRAY(data);

    if (!success) {
        printf("NavMeshHandle::create:  error({%d})!\n", status);
        dtFreeNavMesh(mesh);
        return NULL;
    }

    NFCNavigationHandle* pNavMeshHandle = new NFCNavigationHandle();
    dtNavMeshQuery* pMavmeshQuery = new dtNavMeshQuery();

    pMavmeshQuery->init(mesh, 1024);
    pNavMeshHandle->resPath = resPath;
    pNavMeshHandle->navmeshLayer.pNavmeshQuery = pMavmeshQuery;
    pNavMeshHandle->navmeshLayer.pNavmesh = mesh;

    uint32_t tileCount = 0;
    uint32_t nodeCount = 0;
    uint32_t polyCount = 0;
    uint32_t vertCount = 0;
    uint32_t triCount = 0;
    uint32_t triVertCount = 0;
    uint32_t dataSize = 0;

    const dtNavMesh* navmesh = mesh;
    for (int i = 0; i < navmesh->getMaxTiles(); ++i) {
        const dtMeshTile* tile = navmesh->getTile(i);
        if (!tile || !tile->header)
            continue;

        tileCount++;
        nodeCount += tile->header->bvNodeCount;
        polyCount += tile->header->polyCount;
        vertCount += tile->header->vertCount;
        triCount += tile->header->detailTriCount;
        triVertCount += tile->header->detailVertCount;
        dataSize += tile->dataSize;
    }

    printf("\t==> resPath: {%s}\n", resPath.c_str());
    printf("\t==> tiles loaded: {%d}\n", tileCount);
    printf("\t==> BVTree nodes: {%d}\n", nodeCount);
    printf("\t==> {%d} polygons ({%d} vertices)\n", polyCount, vertCount);
    printf("\t==> {%d} triangles ({%d} vertices)\n", triCount, triVertCount);
    printf("\t==> {%f:.2f} MB of data (not including pointers)\n", (((float)dataSize / sizeof(unsigned char)) / 1048576));
    printf("\t==> ----------------------------------------\n");

    return pNavMeshHandle;

    lua_pushvalue(L, lua_upvalueindex(1));
    lua_setmetatable(L, -1);
    return 1;
}

static int
lFindStraightPath(lua_State* L)
{
    struct pathfinding* nav = (struct pathfinding*)lua_touserdata(L, 1);
    lua_Number start_x = luaL_checknumber(L, 2);
    lua_Number start_y = luaL_checknumber(L, 3);
    lua_Number start_z = luaL_checknumber(L, 4);
    lua_Number end_x = luaL_checknumber(L, 5);
    lua_Number end_y = luaL_checknumber(L, 6);
    lua_Number end_z = luaL_checknumber(L, 7);

    float start[3];
    start[0] = start_x;
    start[1] = start_y;
    start[2] = start_z;

    float end[3];
    end[0] = end_x;
    end[1] = end_y;
    end[2] = end_z;

    std::vector<std::array<float, 3>> paths;
    int pos = nav->handle->FindStraightPath(start, end, paths);

    dtNavMeshQuery* navmeshQuery = navmeshLayer.pNavmeshQuery;

    float spos[3];
    spos[0] = start[0];
    spos[1] = start[1];
    spos[2] = start[2];

    float epos[3];
    epos[0] = end[0];
    epos[1] = end[0];
    epos[2] = end[0];

    dtQueryFilter filter;
    filter.setIncludeFlags(0xffff);
    filter.setExcludeFlags(0);

    const float extents[3] = {2.f, 4.f, 2.f};

    dtPolyRef startRef = INVALID_NAVMESH_POLYREF;
    dtPolyRef endRef = INVALID_NAVMESH_POLYREF;

    float startNearestPt[3];
    float endNearestPt[3];
    navmeshQuery->findNearestPoly(spos, extents, &filter, &startRef, startNearestPt);
    navmeshQuery->findNearestPoly(epos, extents, &filter, &endRef, endNearestPt);

    if (!startRef || !endRef) {
        //debuf_msg("NavMeshHandle::findStraightPath({%s}): Could not find any nearby poly's ({%d}, {%d})\n", resPath.c_str(), startRef, endRef);
        return NAV_ERROR_NEARESTPOLY;
    }

    dtPolyRef polys[MAX_POLYS];
    int npolys;
    float straightPath[MAX_POLYS * 3];
    unsigned char straightPathFlags[MAX_POLYS];
    dtPolyRef straightPathPolys[MAX_POLYS];
    int nstraightPath;
    int pos = 0;

    navmeshQuery->findPath(startRef, endRef, startNearestPt, endNearestPt, &filter, polys, &npolys, MAX_POLYS);
    nstraightPath = 0;

    if (npolys) {
        float epos1[3];
        dtVcopy(epos1, endNearestPt);

        if (polys[npolys - 1] != endRef)
            navmeshQuery->closestPointOnPoly(polys[npolys - 1], endNearestPt, epos1, 0);

        navmeshQuery->findStraightPath(startNearestPt, endNearestPt, polys, npolys, straightPath, straightPathFlags, straightPathPolys, &nstraightPath, MAX_POLYS);

        std::array<float, 3> currpos;
        for (int i = 0; i < nstraightPath * 3;) {
            currpos[0] = straightPath[i++];
            currpos[1] = straightPath[i++];
            currpos[2] = straightPath[i++];
            paths.push_back(currpos);
            pos++;
        }
    }


    return pos;
    if (pos > 0) {
        lua_pushinteger(L, pos);
        return 1;
    }
    return 0;
}

static int
lFindRandomPointAroundCircle(lua_State* L /*, const float* centerPos, std::vector<float[3]>& points, int32_t max_points, float maxRadius*/)
{
    struct pathfinding* nav = (struct pathfinding*)lua_touserdata(L, 1);
    lua_Number start_x = luaL_checknumber(L, 1);
    lua_Number start_y = luaL_checknumber(L, 2);
    lua_Number start_z = luaL_checknumber(L, 3);

    dtNavMeshQuery* navmeshQuery = navmeshLayer.pNavmeshQuery;

    dtQueryFilter filter;
    filter.setIncludeFlags(0xffff);
    filter.setExcludeFlags(0);

    if (maxRadius <= 0.0001f) {
        std::array<float, 3> currpos;

        for (int i = 0; i < max_points; i++) {
            float pt[3];
            dtPolyRef ref;
            dtStatus status = navmeshQuery->findRandomPoint(&filter, frand, &ref, pt);
            if (dtStatusSucceed(status)) {
                currpos[0] = pt[0];
                currpos[1] = pt[1];
                currpos[2] = pt[2];

                points.push_back(currpos);
            }
        }

        return (int)points.size();
    }

    const float extents[3] = {2.f, 4.f, 2.f};

    dtPolyRef startRef = INVALID_NAVMESH_POLYREF;

    float spos[3];
    spos[0] = centerPos[0];
    spos[1] = centerPos[1];
    spos[2] = centerPos[2];

    float startNearestPt[3];
    navmeshQuery->findNearestPoly(spos, extents, &filter, &startRef, startNearestPt);

    if (!startRef) {
        //debuf_msg("NavMeshHandle::findRandomPointAroundCircle({%s}): Could not find any nearby poly's ({%d})\n", resPath, startRef);
        return NAV_ERROR_NEARESTPOLY;
    }

    std::array<float, 3> currpos;
    bool done = false;
    int itry = 0;

    while (itry++ < 3 && points.size() == 0) {
        max_points -= (int)points.size();

        for (int i = 0; i < max_points; i++) {
            float pt[3];
            dtPolyRef ref;
            dtStatus status = navmeshQuery->findRandomPointAroundCircle(startRef, spos, maxRadius, &filter, frand, &ref, pt);

            if (dtStatusSucceed(status)) {
                done = true;
                currpos[0] = (pt[0]);
                currpos[1] = (pt[1]);
                currpos[2] = (pt[2]);

                float v[3];
                dtVsub(centerPos, currpos.data(), v);
                float dist_len = dtVlen(v);
                if (dist_len > maxRadius)
                    continue;

                points.push_back(currpos);
            }
        }

        if (!done)
            break;
    }

    return (int)points.size();
    return 0;
}

static int
lRaycast(lua_State* L)
{
    struct pathfinding* nav = (struct pathfinding*)lua_touserdata(L, 1);
    lua_Number start_x = luaL_checknumber(L, 2);
    lua_Number start_y = luaL_checknumber(L, 3);
    lua_Number start_z = luaL_checknumber(L, 4);
    lua_Number end_x = luaL_checknumber(L, 5);
    lua_Number end_y = luaL_checknumber(L, 6);
    lua_Number end_z = luaL_checknumber(L, 7);

    float start[3];
    start[0] = start_x;
    start[1] = start_y;
    start[2] = start_z;

    float end[3];
    end[0] = end_x;
    end[1] = end_y;
    end[2] = end_z;

    std::vector<std::array<float, 3>> hitPointVec;
    int res = nav->handle->Raycast(start, end, hitPointVec);

    dtNavMeshQuery* navmeshQuery = navmeshLayer.pNavmeshQuery;

    std::array<float, 3> hitPoint;

    float spos[3];
    spos[0] = start[0];
    spos[1] = start[1];
    spos[2] = start[2];

    float epos[3];
    epos[0] = end[0];
    epos[1] = end[1];
    epos[2] = end[2];

    dtQueryFilter filter;
    filter.setIncludeFlags(0xffff);
    filter.setExcludeFlags(0);

    const float extents[3] = {2.f, 4.f, 2.f};

    dtPolyRef startRef = INVALID_NAVMESH_POLYREF;

    float nearestPt[3];
    navmeshQuery->findNearestPoly(spos, extents, &filter, &startRef, nearestPt);

    if (!startRef) {
        return NAV_ERROR_NEARESTPOLY;
    }

    float t = 0;
    float hitNormal[3];
    memset(hitNormal, 0, sizeof(hitNormal));

    dtPolyRef polys[MAX_POLYS];
    int npolys;

    navmeshQuery->raycast(startRef, spos, epos, &filter, &t, hitNormal, polys, &npolys, MAX_POLYS);

    if (t > 1) {
        // no hit
        return NAV_ERROR;
    } else {
        // Hit
        hitPoint[0] = spos[0] + (epos[0] - spos[0]) * t;
        hitPoint[1] = spos[1] + (epos[1] - spos[1]) * t;
        hitPoint[2] = spos[2] + (epos[2] - spos[2]) * t;
        if (npolys) {
            float h = 0;
            navmeshQuery->getPolyHeight(polys[npolys - 1], hitPoint.data(), &h);
            hitPoint[1] = h;
        }
    }

    hitPointVec.push_back(hitPoint);
    return 1;

    lua_pushinteger(L, res);
    lua_newtable(L);
    for (size_t i = 0; i < hitPointVec.size(); i++) {
        lua_newtable(L);
        lua_pushinteger(L, hitPointVec[i][0]);
        lua_setfield(L, -2, "x");
        lua_pushinteger(L, hitPointVec[i][1]);
        lua_setfield(L, -2, "y");
        lua_pushinteger(L, hitPointVec[i][2]);
        lua_setfield(L, -2, "z");
    }
    return 2;
}

extern "C" {
LUAMOD_API int luaopen_recastnavigation(lua_State* L);
}

LUAMOD_API int
luaopen_recastnavigation(lua_State* L)
{
    luaL_checkversion(L);
    luaL_Reg metatable[] = {
        {"FindStraightPath", lFindStraightPath},
        {"FindRandomPointAroundCircle", lFindRandomPointAroundCircle},
        {"Raycast", lRaycast},
        {NULL, NULL},
    };
    luaL_newlib(L, metatable);
    lua_pushcclosure(L, lalloc, 1);

    return 1;
}
