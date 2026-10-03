#pragma once
#include <cstdint>
namespace rc {
struct Color { float r=0,g=0,b=0,a=1; };
class Renderer {
public:
 bool initialize(int width,int height);
 void resize(int width,int height);
 void begin_frame(Color clear={0.035f,0.045f,0.060f,1});
 void end_frame();
 void set_viewport(int x,int y,int width,int height);
 void draw_grid(float size,float spacing);
 int width() const{return width_;} int height() const{return height_;}
private:int width_=1,height_=1;
};
Renderer& renderer();
}