#pragma once
#include <string>
namespace rc {
struct Material {
 std::string name="Material";
 std::string shader="standard";
 std::string albedo_texture;
 float metallic=0,roughness=0.5f;
 float color[4]{1,1,1,1};
};
struct ModelAsset { std::string path; std::uint32_t mesh_count=0; };
struct TextureAsset { std::string path; int width=0,height=0,channels=0; bool srgb=true; };
}