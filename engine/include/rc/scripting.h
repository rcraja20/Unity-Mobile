#pragma once
#include <string>
#include <vector>
namespace rc { struct ScriptDiagnostic{int line=0,column=0;std::string message;bool error=true;}; class ScriptCompiler{public:bool compile(const std::string&source,std::vector<ScriptDiagnostic>&out){out.clear();if(source.empty()){out.push_back({1,1,"Script source is empty",true});return false;}return true;}}; }