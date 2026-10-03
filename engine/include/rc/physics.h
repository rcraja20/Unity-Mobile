#pragma once
#include "rc/camera.h"
#include <cstdint>
#include <vector>
namespace rc {
enum class ColliderType { Box, Sphere, Capsule };
struct Collider { std::uint64_t entity=0; ColliderType type=ColliderType::Box; Vec3 center{}; Vec3 size{1,1,1}; bool trigger=false; };
struct RigidBody { std::uint64_t entity=0; float mass=1,linear_drag=0,gravity_scale=1; bool kinematic=false; Vec3 velocity{}; };
class PhysicsWorld {
public:
 std::uint64_t add_collider(const Collider& c); std::uint64_t add_body(const RigidBody& b);
 void step(float dt);
 const std::vector<Collider>& colliders()const{return colliders_;}
 const std::vector<RigidBody>& bodies()const{return bodies_;}
private: std::vector<Collider> colliders_; std::vector<RigidBody> bodies_; std::uint64_t next_id_=1;
};
}