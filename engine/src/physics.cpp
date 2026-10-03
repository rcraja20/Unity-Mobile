#include "rc/physics.h"
namespace rc {
std::uint64_t PhysicsWorld::add_collider(const Collider& c){colliders_.push_back(c);return next_id_++;}
std::uint64_t PhysicsWorld::add_body(const RigidBody& b){bodies_.push_back(b);return next_id_++;}
void PhysicsWorld::step(float dt){for(auto&b:bodies_)if(!b.kinematic){b.velocity.y-=9.81f*b.gravity_scale*dt;}}
}