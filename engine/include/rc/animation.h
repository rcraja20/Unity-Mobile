#pragma once
#include <string>
#include <vector>
namespace rc {
struct Keyframe { float time=0,value=0; };
struct AnimationClip { std::string name; float length=0; std::vector<Keyframe> keys; };
class Animator { public: void play(const std::string&name){current_=name;time_=0;} void update(float dt){time_+=dt;} const std::string& current()const{return current_;} float time()const{return time_;} private: std::string current_;float time_=0; };
}