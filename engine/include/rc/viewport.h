#pragma once
#include "rc/camera.h"
namespace rc {
class Viewport {
public:
 void resize(int width,int height);
 void orbit_from_drag(float dx,float dy);
 void pan_from_drag(float dx,float dy);
 void zoom_from_pinch(float delta);
 void focus(Vec3 target);
 Camera& camera(){return camera_;}
private:int width_=1,height_=1;Camera camera_;
};
}