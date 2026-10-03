#include "rc/viewport.h"
namespace rc {
void Viewport::resize(int w,int h){width_=w>0?w:1;height_=h>0?h:1;camera_.set_viewport((float)width_,(float)height_);}
void Viewport::orbit_from_drag(float dx,float dy){camera_.orbit(dx,dy);}
void Viewport::pan_from_drag(float dx,float dy){camera_.pan(dx,dy);}
void Viewport::zoom_from_pinch(float delta){camera_.zoom(delta);}
void Viewport::focus(Vec3 target){camera_.focus(target);}
}