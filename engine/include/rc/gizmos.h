#pragma once
#include "rc/camera.h"
namespace rc { enum class GizmoMode{Move,Rotate,Scale}; struct GizmoState{GizmoMode mode=GizmoMode::Move;bool active=false;}; class TransformGizmo{public:void set_mode(GizmoMode m){state_.mode=m;}void begin(){state_.active=true;}void end(){state_.active=false;}const GizmoState&state()const{return state_;}private:GizmoState state_;}; }