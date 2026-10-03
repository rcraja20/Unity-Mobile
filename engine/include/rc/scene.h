#pragma once
#include <cstdint>
#include <string>
#include <vector>
#include <unordered_map>
#include "rc/camera.h"
namespace rc {
struct Transform { Vec3 position{0,0,0}; Vec3 rotation{0,0,0}; Vec3 scale{1,1,1}; };
struct Entity {
 std::uint64_t id=0,parent=0; std::string name; Transform transform; bool active=true;
 std::vector<std::uint64_t> children;
};
class Scene {
public:
 std::uint64_t create(const std::string& name,std::uint64_t parent=0);
 bool destroy(std::uint64_t id);
 bool set_parent(std::uint64_t id,std::uint64_t parent);
 Entity* find(std::uint64_t id);
 const std::vector<Entity>& entities() const{return entities_;}
private:
 bool would_cycle(std::uint64_t id,std::uint64_t parent) const;
 void detach(std::uint64_t id);
 std::vector<Entity> entities_;
 std::unordered_map<std::uint64_t,std::size_t> index_;
 std::uint64_t next_id_=1;
};
}