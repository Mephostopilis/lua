package.path = "./lualib/?.lua;./sproto/?.lua;" .. package.path
package.cpath = "./luaclib/?.dll;" .. package.cpath
require "physx"

local staticFriction = 0.5
local dynamicFriction = 0.5
local restitution = 0.6

lphysx.Common.initialize()

local defaultMaterial = lphysx.Common.createMaterial(staticFriction, dynamicFriction, restitution)

function createStack(t, size, halfExtent)
	local shape = lphysx.Common.createShapeBox(PxBoxGeometry(halfExtent, halfExtent, halfExtent), defaultMaterial)
	for(PxU32 i=0; i<size;i++)
	{
		for(PxU32 j=0;j<size-i;j++)
		{
			local localTm = { p =  { x = PxReal(j*2) - PxReal(size-i), y = PxReal(i*2+1), z = 0) * halfExtent);
			local body = lphysx.Common.createDynamicBox(t.transform(localTm));
			body->attachShape(*shape);
			PxRigidBodyExt::updateMassAndInertia(*body, 10.0f);
			gScene->addActor(*body);
		}
	}
	shape->release();
end

local scene = lphysx.Common.createScene({x = 0.0, y = -9.81, z = 0.0})
local t = {nx = 0, ny = 1, nz = 0, d = 0}
local groundPlane = lphysx.Common.createPlane(t, staticFriction, dynamicFriction, restitution)
groundPlane:release()
lphysx.Common.releaseScene(scene)
lphysx.Common.cleanup()
