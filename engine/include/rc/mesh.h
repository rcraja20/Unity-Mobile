#pragma once
#include <cstdint>
#include <vector>
#include "rc/camera.h"
namespace rc {
struct Vertex { Vec3 position{}; Vec3 normal{0,1,0}; float uv[2]{0,0}; };
struct Mesh { std::vector<Vertex> vertices; std::vector<std::uint32_t> indices; };
}