#pragma once
#include <cstdint>
#include <vector>
namespace rc { struct Texture { int width=0,height=0,channels=0; bool srgb=true; std::vector<std::uint8_t> pixels; }; }