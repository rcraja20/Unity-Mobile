#pragma once
#include <string>
#include <vector>
namespace rc {
struct ScriptAsset{std::string path;std::string language="rcscript";std::string source;};
class ScriptRuntime{public:bool load(const ScriptAsset&s){script_=s;return !s.source.empty()||!s.path.empty();}void update(float dt){time_+=dt;}float time()const{return time_;}private:ScriptAsset script_;float time_=0;};
}