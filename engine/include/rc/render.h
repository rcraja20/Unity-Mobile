#pragma once
#include <cstdint>
#include "rc/camera.h"
namespace rc {
struct Color { float r=0,g=0,b=0,a=1; };
class Renderer {
public:
 bool initialize(int width,int height);
 void resize(int width,int height);
 void begin_frame(Color clear={0.035f,0.045f,0.060f,1});
 void end_frame();
 void set_viewport(int x,int y,int width,int height);
 void set_camera(const Camera& camera);
 void draw_grid(float size,float spacing);
 void draw_cube(Vec3 position,Vec3 rotation,Vec3 scale,bool selected=false);
 void draw_axes(float length=2.0f);
 int width() const{return width_;} int height() const{return height_;}
 std::uint64_t draw_calls() const{return draw_calls_;}
 std::uint64_t triangles() const{return triangles_;}
private:
 bool ensure_program();
 int width_=1,height_=1;
 unsigned int program_=0,vbo_=0,ibo_=0,grid_vbo_=0;
 int u_mvp_=-1,u_color_=-1;
 float view_[16]{},proj_[16]{};
 Vec3 camera_position_{0,2,6},camera_target_{0,0,0};
 std::uint64_t draw_calls_=0,triangles_=0;
};
Renderer& renderer();
}