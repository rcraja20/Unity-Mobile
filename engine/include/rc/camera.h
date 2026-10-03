#pragma once
#include <cmath>
namespace rc {
struct Vec3 { float x=0,y=0,z=0; };
class Camera {
public:
 void set_viewport(float width,float height);
 void orbit(float dx,float dy);
 void pan(float dx,float dy);
 void zoom(float delta);
 void focus(Vec3 target);
 Vec3 position() const{return position_;}
 Vec3 target() const{return target_;}
 float distance() const{return distance_;}
 float yaw() const{return yaw_;} float pitch() const{return pitch_;}
private:
 void rebuild_position();
 Vec3 position_{0,2,6},target_{0,0,0}; float distance_=6,yaw_=0,pitch_=20; float width_=1,height_=1;
};
}