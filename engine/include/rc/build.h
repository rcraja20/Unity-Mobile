#pragma once
#include <cstdint>
#include <string>
namespace rc { struct BuildSettings{std::string package_id="com.rcempire.rcmobile";std::string output_path;int min_sdk=24;int target_sdk=35;bool arm64=true;}; struct BuildReport{bool success=false;std::string message;std::uint64_t bytes=0;}; class BuildPipeline{public:BuildReport validate(const BuildSettings&s)const{return {s.arm64&&!s.package_id.empty(),"settings validated",0};}};}