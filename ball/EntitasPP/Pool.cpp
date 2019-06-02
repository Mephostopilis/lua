// Copyright (c) 2016 Juan Delgado (JuDelCo)
// License: MIT License
// MIT License web page: https://opensource.org/licenses/MIT

#include "Pool.h"
#include "Entity.h"
#include "ISystem.h"
#include "ReactiveSystem.h"
#include <algorithm>

namespace Chestnut {
namespace EntitasPP {
luabridge::RefCountedPtr<Pool> Pool::Create() {
	luabridge::RefCountedPtr<Pool> ptr(new Pool());
	return ptr;
}

Pool::Pool(const unsigned int startCreationIndex) {
	mCreationIndex = startCreationIndex;
	mOnEntityReleasedCache = std::bind(&Pool::OnEntityReleased, this, std::placeholders::_1);
}

Pool::~Pool() {
	Reset();

	// TODO: Components don't get destroyed.

	if (!mRetainedEntities.empty()) {
		// Warning, some entities remain undestroyed in the pool destruction !"
	}

	while (!mReusableEntities.empty()) {
		delete mReusableEntities.top();
		mReusableEntities.pop();
	}

	for (auto &pair : mComponentPools) {
		auto componentPool = pair.second;

		while (!componentPool.empty()) {
			delete componentPool.top();
			componentPool.pop();
		}
	}
}

auto Pool::CreateEntity() -> EntityPtr {
	EntityPtr entity;

	if (mReusableEntities.size() > 0) {
		entity = EntityPtr(mReusableEntities.top());
		mReusableEntities.pop();
	} else {
		entity = EntityPtr(new Entity(&mComponentPools), [](void* entity) {
			(static_cast<Entity*>(entity)->OnEntityReleased(static_cast<Entity*>(entity)));
		});
	}

	entity->SetInstance(entity);
	entity->mIsEnabled = true;
	entity->mUuid = mCreationIndex++;

	mEntities.insert(entity);
	mEntitiesCache.clear();

	entity->OnComponentAdded += [this](EntityPtr entity, ComponentId index, IComponent* component) {
		UpdateGroupsComponentAddedOrRemoved(entity, index, component);
	};
	entity->OnComponentRemoved += [this](EntityPtr entity, ComponentId index, IComponent* component) {
		UpdateGroupsComponentAddedOrRemoved(entity, index, component);
	};
	entity->OnComponentReplaced += [this](EntityPtr entity, ComponentId index, IComponent* previousComponent, IComponent* newComponent) {
		UpdateGroupsComponentReplaced(entity, index, previousComponent, newComponent);
	};

	entity->OnEntityReleased.Clear();
	entity->OnEntityReleased += mOnEntityReleasedCache;

	OnEntityCreated(this, entity);

	return entity;
}

bool Pool::HasEntity(const EntityPtr& entity) const {
	return std::find(mEntities.begin(), mEntities.end(), std::weak_ptr<Entity>(entity)) != mEntities.end();
}

void Pool::DestroyEntity(EntityPtr entity) {
	auto removed = mEntities.erase(entity);

	if (!removed) {
		throw std::runtime_error("Error, cannot destroy entity. Pool does not contain entity.");
	}

	mEntitiesCache.clear();

	OnEntityWillBeDestroyed(this, entity);
	entity->Destroy();
	OnEntityDestroyed(this, entity);

	if (entity.use_count() == 1) {
		entity->OnEntityReleased -= mOnEntityReleasedCache;
		mReusableEntities.push(entity.get());
	} else {
		mRetainedEntities.insert(entity.get());
	}
}

void Pool::DestroyAllEntities() {
	{
		auto entitiesTemp = std::vector<EntityPtr>(mEntities.begin(), mEntities.end());

		while (!mEntities.empty()) {
			DestroyEntity(entitiesTemp.back());
			entitiesTemp.pop_back();
		}
	}

	mEntities.clear();

	if (!mRetainedEntities.empty()) {
		// Try calling Pool.ClearGroups() and SystemContainer.ClearReactiveSystems() before calling pool.DestroyAllEntities() to avoid memory leaks
		throw std::runtime_error("Error, pool detected retained entities although all entities got destroyed. Did you release all entities?");
	}
}

auto Pool::GetEntities() -> std::vector<EntityPtr> {
	if (mEntitiesCache.empty()) {
		mEntitiesCache = std::vector<EntityPtr>(mEntities.begin(), mEntities.end());
	}

	return mEntitiesCache;
}

auto Pool::GetEntities(const Matcher matcher) -> std::vector<EntityPtr> {
	return GetGroup(std::move(matcher))->GetEntities();
}

auto Pool::GetGroup(Matcher matcher) -> std::shared_ptr<Group> {
	std::shared_ptr<Group> group = nullptr;

	auto it = mGroups.find(matcher);

	if (it == mGroups.end()) {
		group = std::shared_ptr<Group>(new Group(matcher));
		group->SetInstance(group);

		auto entities = GetEntities();

		for (int i = 0, entitiesLength = entities.size(); i < entitiesLength; i++) {
			group->HandleEntitySilently(entities[i]);
		}

		mGroups[group->GetMatcher()] = group;

		for (int i = 0, indicesLength = matcher.GetIndices().size(); i < indicesLength; i++) {
			mGroupsForIndex[matcher.GetIndices()[i]].push_back(group);
		}

		OnGroupCreated(this, group);
	} else {
		group = it->second;
	}

	return group;
}

void Pool::ClearGroups() {
	for (const auto &it : mGroups) {
		it.second->RemoveAllEventHandlers();
		OnGroupCleared(this, it.second);
	}

	mGroups.clear();

	for (auto &pair : mGroupsForIndex) {
		pair.second.clear();
	}

	mGroupsForIndex.clear();
}

void Pool::ResetCreationIndex() {
	mCreationIndex = 0;
}

void Pool::ClearComponentPool(const ComponentId index) {
	while (!mComponentPools.at(index).empty()) {
		mComponentPools.at(index).pop();
	}
}

void Pool::ClearComponentPools() {
	for (const auto &pair : mComponentPools) {
		ClearComponentPool(pair.first);
	}
}

void Pool::Reset() {
	ClearGroups();
	DestroyAllEntities();
	ResetCreationIndex();
}

auto Pool::GetEntityCount() const -> unsigned int {
	return mEntities.size();
}

auto Pool::GetReusableEntitiesCount() const -> unsigned int {
	return mReusableEntities.size();
}

auto Pool::GetRetainedEntitiesCount() const -> unsigned int {
	return mRetainedEntities.size();
}

auto Pool::Test() -> void {
	printf("hello test");
}

auto Pool::CreateSystemRef(luabridge::RefCountedPtr<ISystem> system)-> luabridge::RefCountedPtr<ISystem> {
	luabridge::RefCountedPtr<ISystem> tmp = system;
	if (dynamic_cast<ISetPoolSystem*>(tmp.get()) != nullptr) {
		dynamic_cast<ISetPoolSystem*>(tmp.get())->SetPool(this);
	}
	return system;
}

auto Pool::CreateSystem(std::shared_ptr<ISystem> system) -> std::shared_ptr<ISystem> {
	if (std::dynamic_pointer_cast<ISetPoolSystem>(system) != nullptr) {
		(std::dynamic_pointer_cast<ISetPoolSystem>(system)->SetPool(this));
	}

	if (std::dynamic_pointer_cast<IReactiveSystem>(system) != nullptr) {
		return std::shared_ptr<ReactiveSystem>(new ReactiveSystem(this, std::dynamic_pointer_cast<IReactiveSystem>(system)));
	}

	if (std::dynamic_pointer_cast<IMultiReactiveSystem>(system) != nullptr) {
		return std::shared_ptr<ReactiveSystem>(new ReactiveSystem(this, std::dynamic_pointer_cast<IMultiReactiveSystem>(system)));
	}

	return system;
}

void Pool::UpdateGroupsComponentAddedOrRemoved(EntityPtr entity, ComponentId index, IComponent* component) {
	if (mGroupsForIndex.find(index) == mGroupsForIndex.end()) {
		return;
	}

	auto groups = mGroupsForIndex[index];

	if (groups.size() > 0) {
		auto events = std::vector<Group::GroupChanged*>();

		for (int i = 0, groupsCount = groups.size(); i < groupsCount; ++i) {
			events.push_back(groups[i].lock()->HandleEntity(entity));
		}

		for (int i = 0, eventsCount = events.size(); i < eventsCount; ++i) {
			(*events[i])(groups[i].lock(), entity, index, component);
		}
	}
}

void Pool::UpdateGroupsComponentReplaced(EntityPtr entity, ComponentId index, IComponent* previousComponent, IComponent* newComponent) {
	if (mGroupsForIndex.find(index) == mGroupsForIndex.end()) {
		return;
	}

	if (mGroupsForIndex[index].size() > 0) {
		for (const auto &g : mGroupsForIndex[index]) {
			g.lock()->UpdateEntity(entity, index, previousComponent, newComponent);
		}
	}
}

void Pool::OnEntityReleased(Entity* entity) {
	if (entity->mIsEnabled) {
		throw std::runtime_error("Error, cannot release entity. Entity is not destroyed yet.");
	}

	mRetainedEntities.erase(entity);
	mReusableEntities.push(entity);
}
}
}