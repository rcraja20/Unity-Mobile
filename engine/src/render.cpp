#include "rc/render.h"
#if defined(__ANDROID__)
#include <GLES3/gl3.h>
#endif
namespace rc {
Renderer& renderer(){static Renderer r;return r;}
bool Renderer::initialize(int w,int h){resize(w,h);return true;}
void Renderer::resize(int w,int h){width_=w>0?w:1;height_=h>0?h:1;set_viewport(0,0,width_,height_);}
void Renderer::begin_frame(Color c){
#if defined(__ANDROID__)
 glViewport(0,0,width_,height_); glEnable(GL_DEPTH_TEST); glClearColor(c.r,c.g,c.b,c.a); glClear(GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT);
#endif
}
void Renderer::end_frame(){}
void Renderer::set_viewport(int x,int y,int w,int h){
#if defined(__ANDROID__)
 glViewport(x,y,w,h);
#endif
}
void Renderer::set_camera(const Camera& camera){camera_position_=camera.position();camera_target_=camera.target();}
void Renderer::draw_grid(float,float){}
void Renderer::draw_cube(Vec3,Vec3,Vec3,bool){}
void Renderer::draw_axes(float){}
}