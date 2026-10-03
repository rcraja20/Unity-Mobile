#pragma once
#include <cstdint>
#include <string>
namespace rc { struct Diagnostics{std::uint64_t frames=0;std::uint64_t crashes=0;std::uint64_t warnings=0;std::string last_error;}; class DiagnosticLog{public:void warning(){++d_.warnings;}void error(const std::string&s){d_.last_error=s;}const Diagnostics&data()const{return d_;}private:Diagnostics d_;}; }