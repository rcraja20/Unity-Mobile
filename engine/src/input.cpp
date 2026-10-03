#include "rc/input.h"
#include <cmath>
namespace rc {
void TouchInput::begin(int id,float x,float y){ Pointer p{id,x,y,x,y,true}; pointers_[id]=p; recalc_gesture(); }
void TouchInput::move(int id,float x,float y){ auto it=pointers_.find(id); if(it==pointers_.end()) return; it->second.prev_x=it->second.x; it->second.prev_y=it->second.y; it->second.x=x; it->second.y=y; recalc_gesture(); }
void TouchInput::end(int id,float x,float y){ move(id,x,y); pointers_.erase(id); recalc_gesture(); }
void TouchInput::recalc_gesture(){
 gestures_.pinch_delta=0; gestures_.pan_x=0; gestures_.pan_y=0; gestures_.rotation_delta=0;
 if(pointers_.size()!=2) return;
 auto a=pointers_.begin(); auto b=std::next(a);
 float dx=b->second.x-a->second.x, dy=b->second.y-a->second.y;
 float pdx=b->second.prev_x-a->second.prev_x, pdy=b->second.prev_y-a->second.prev_y;
 float d=std::sqrt(dx*dx+dy*dy), old=std::sqrt(pdx*pdx+pdy*pdy);
 gestures_.pinch_distance=d; gestures_.pinch_delta=d-old;
 gestures_.pan_x=((a->second.x-a->second.prev_x)+(b->second.x-b->second.prev_x))*0.5f;
 gestures_.pan_y=((a->second.y-a->second.prev_y)+(b->second.y-b->second.prev_y))*0.5f;
 float angle=std::atan2(dy,dx), old_angle=std::atan2(pdy,pdx); gestures_.rotation_delta=angle-old_angle;
}
}