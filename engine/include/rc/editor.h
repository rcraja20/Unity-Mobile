#pragma once
#include <cstdint>
#include "rc/gizmos.h"
namespace rc { class EditorSelection { public:void select(std::uint64_t id){id_=id;}void clear(){id_=0;}std::uint64_t id()const{return id_;}private:std::uint64_t id_=0;}; }