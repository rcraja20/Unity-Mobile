#pragma once
#include <string>
#include <vector>
namespace rc {
struct AudioSource { std::string clip; float volume=1,pitch=1; bool loop=false,playing=false; };
class AudioSystem { public: void update(float){} };
}