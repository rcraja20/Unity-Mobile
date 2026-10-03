#pragma once
#include <cstdint>
#include <unordered_map>
namespace rc {
struct Pointer { int id=-1; float x=0,y=0,prev_x=0,prev_y=0; bool down=false; };
struct GestureState { float pinch_distance=0; float pinch_delta=0; float pan_x=0,pan_y=0; float rotation_delta=0; };
class TouchInput {
public:
 void begin(int id,float x,float y); void move(int id,float x,float y); void end(int id,float x,float y);
 const std::unordered_map<int,Pointer>& pointers() const{return pointers_;}
 const GestureState& gestures() const{return gestures_;}
 void clear_gesture_deltas(){gestures_.pinch_delta=0;gestures_.pan_x=0;gestures_.pan_y=0;gestures_.rotation_delta=0;}
private:
 void recalc_gesture();
 std::unordered_map<int,Pointer> pointers_; GestureState gestures_;
};
}