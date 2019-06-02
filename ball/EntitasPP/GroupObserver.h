// Copyright (c) 2016 Juan Delgado (JuDelCo)
// License: MIT License
// MIT License web page: https://opensource.org/licenses/MIT

#pragma once

#include "ComponentTypeId.h"
#include "Entity.h"
#include "GroupEventType.h"
#include <vector>
#include <unordered_set>
#include <functional>

namespace Chestnut {
namespace EntitasPP
{

class Group;
class GroupObserver
{
public:
	GroupObserver(::std::shared_ptr<Group> group, const GroupEventType eventType);
	GroupObserver(::std::vector<::std::shared_ptr<Group>> groups, ::std::vector<GroupEventType> eventTypes);
	~GroupObserver();

	void Activate();
	void Deactivate();
	auto GetCollectedEntities()->::std::unordered_set<EntityPtr>;
	void ClearCollectedEntities();

private:
	void AddEntity(::std::shared_ptr<Group> group, EntityPtr entity, ComponentId index, IComponent* component);

	::std::unordered_set<EntityPtr> mCollectedEntities;
	::std::vector<::std::shared_ptr<Group>> mGroups;
	::std::vector<GroupEventType> mEventTypes;
	::std::function<void(::std::shared_ptr<Group>, EntityPtr, ComponentId, IComponent*)> mAddEntityCache;
};

}
}