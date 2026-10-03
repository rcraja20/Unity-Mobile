#include "rc/camera.h"
#include <algorithm>
namespace rc {
void Camera::set_viewport(float w,float h){width_=w>0?w:1;height_=h>0?h:1;rebuild_position();}
void Camera::orbit(float dx,float dy){yaw_+=dx*0.35f;pitch_=std::clamp(pitch_+dy*0.35f,-89.0f,89.0f);rebuild_position();}
void Camera::pan(float dx,float dy){float s=distance_*0.0025f;target_.x-=dx*s;target_.y+=dy*s;rebuild_position();}
void Camera::zoom(float delta){distance_=std::clamp(distance_*(1.0f-delta*0.0015f),0.25f,10000.0f);rebuild_position();}
void Camera::focus(Vec3 t){target_=t;distance_=6.0f;rebuild_position();}
void Camera::rebuild_position(){float yr=yaw_*0.0174532925f,pr=pitch_*0.0174532925f;position_.x=target_.x+distance_*std::cos(pr)*std::sin(yr);position_.y=target_.y+distance_*std::sin(pr);position_.z=target_.z+distance_*std::cos(pr)*std::cos(yr);}
}