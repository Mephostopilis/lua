// -------------------------------------------------------------------------
//    @FileName         :    NFCNavigationModule.h
//    @Author           :    Bluesky
//    @Date             :    2016-06-22
//    @Module           :    NFCNavigationModule
//
// -------------------------------------------------------------------------

#ifndef NFC_NAVIGATION_MODULE_H
#define NFC_NAVIGATION_MODULE_H





class NFCNavigationHandle
{
public:
	

	

public:
	NFCNavigationHandle(){};

	virtual ~NFCNavigationHandle() 
	{
		dtFreeNavMesh(navmeshLayer.pNavmesh);
		dtFreeNavMeshQuery(navmeshLayer.pNavmeshQuery);
	};

	int FindStraightPath(const float* start, const float* end, std::vector<std::array<float, 3>> &paths)
	{
		
	}

	int FindRandomPointAroundCircle(float* centerPos, std::vector<std::array<float, 3>>& points, int32_t max_points, float maxRadius)
	{
		
	}

	int Raycast(const float* start, const float* end, std::vector<std::array<float, 3>>& hitPointVec)
	{
		
	}

	static NFCNavigationHandle* Create(std::string resPath)
	{
		
	}

	
};

#endif
