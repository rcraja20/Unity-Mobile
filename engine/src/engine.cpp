#include "rc/engine.h"
#include <fstream>\n#include "rc/ui.h"\n#include "rc/input.h"
#if defined(__ANDROID__)
#include <GLES3/gl3.h>
#endif
namespace rc {
Engine& instance(){ static Engine e; return e; }
bool Engine::initialize(int w,int h){
 width_=w>0?w:1; height_=h>0?h:1; initialized_=true;\n ui_.set_viewport((float)width_,(float)height_);
 viewport_.resize(width_,height_);
 renderer().resize(width_,height_);
#if defined(__ANDROID__)
 renderer().set_viewport(0,0,width_,height_);
#endif
 return true;
}
void Engine::resize(int w,int h){
 width_=w>0?w:1; height_=h>0?h:1;
#if defined(__ANDROID__)
 glViewport(0,0,width_,height_);
#endif
}
void Engine::update(float dt){physics_.step(dt);particles_.update(dt);animator_.update(dt);audio_.update(dt);}
void Engine::render(){ renderer().begin_frame(); renderer().end_frame(); }
void Engine::shutdown(){ initialized_=false; objects_.clear(); }
bool Engine::create_project(const std::string& path,const ProjectSettings& s){ project_path_=path; settings_=s; objects_.clear(); next_id_=1; return save_project(); }
bool Engine::open_project(const std::string& path){ std::ifstream in(path+"/project.rcproject"); if(!in)return false; project_path_=path; std::getline(in,settings_.name); std::getline(in,settings_.package_id); in>>settings_.version_code; return true; }
bool Engine::save_project(){ if(project_path_.empty())return false; std::ofstream out(project_path_+"/project.rcproject",std::ios::trunc); if(!out)return false; out<<settings_.name<<"\n"<<settings_.package_id<<"\n"<<settings_.version_code<<"\n"; return(bool)out; }
std::uint64_t Engine::create_object(const std::string& n){ SceneObject o; o.id=next_id_++; o.name=n; objects_.push_back(o); return o.id; }
bool Engine::delete_object(std::uint64_t id){ for(auto it=objects_.begin();it!=objects_.end();++it) if(it->id==id){objects_.erase(it);return true;} return false; }
void Engine::touch_begin(float x,float y){(void)x;(void)y;}
void Engine::touch_move(float x,float y){(void)x;(void)y;}
void Engine::touch_end(float x,float y){(void)x;(void)y;}
}