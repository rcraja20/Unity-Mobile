#pragma once
#include <cstdint>
namespace rc { struct FrameStats{float fps=0,frame_ms=0;std::uint64_t draw_calls=0,triangles=0,memory_bytes=0;}; class Profiler{public:void frame(float dt){stats_.frame_ms=dt*1000.0f;stats_.fps=dt>0?1.0f/dt:0;}const FrameStats&stats()const{return stats_;}private:FrameStats stats_;};}