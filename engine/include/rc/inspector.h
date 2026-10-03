#pragma once
#include <cstdint>
#include <string>
#include "rc/scene.h"
#include "rc/component.h"
namespace rc {
class Inspector {
public:
 bool rename(Scene& scene,std::uint64_t id,const std::string& name);
 bool set_position(Scene& scene,std::uint64_t id,Vec3 v);
 bool set_rotation(Scene& scene,std::uint64_t id,Vec3 v);
 bool set_scale(Scene& scene,std::uint64_t id,Vec3 v);
 bool set_active(Scene& scene,std::uint64_t id,bool active);
 template<class T> T* add_component(ComponentStore& store,std::uint64_t id){return store.add<T>(id);}
};
}