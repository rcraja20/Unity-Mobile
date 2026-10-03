#pragma once
#include <cstdint>
#include <vector>
#include "rc/camera.h"
namespace rc {
struct Particle { Vec3 position{},velocity{}; float age=0,life=1; };
class ParticleSystem { public: void emit(const Particle&p){particles_.push_back(p);} void update(float dt){for(auto&p:particles_){p.age+=dt;p.position.x+=p.velocity.x*dt;p.position.y+=p.velocity.y*dt;p.position.z+=p.velocity.z*dt;}} const std::vector<Particle>& particles()const{return particles_;} private: std::vector<Particle> particles_; };
}