#include "rc/engine.h"
#include <fstream>
namespace rc {
Engine& instance(){ static Engine e; return e; }
bool Engine::initialize(int w,int h){
 width_=w>0?w:1; height_=h>0?h:1; initialized_=true;
 ui_.set_viewport((float)width_,(float)height_);
 viewport_.resize(width_,height_);
 renderer().initialize(width_,height_);
 return true;
}
void Engine::resize(int w,int h){
 width_=w>0?w:1; height_=h>0?h:1;
 ui_.set_viewport((float)width_,(float)height_);
 viewport_.resize(width_,height_);
 renderer().resize(width_,height_);
}
void Engine::update(float dt){
 physics_.step(dt); particles_.update(dt); animator_.update(dt); audio_.update(dt);
 scripts_.update(dt); play_.update(dt); profiler_.frame(dt);
}
void Engine::render(){ renderer().begin_frame(); renderer().draw_grid(20.0f,1.0f); renderer().end_frame(); }
void Engine::shutdown(){ initialized_=false; objects_.clear(); }
bool Engine::create_project(const std::string& path,const ProjectSettings& s){ project_path_=path; settings_=s; objects_.clear(); next_id_=1; return save_project(); }
bool Engine::open_project(const std::string& path){ std::ifstream in(path+"/project.rcproject"); if(!in)return false; project_path_=path; std::getline(in,settings_.name); std::getline(in,settings_.package_id); in>>settings_.version_code; return true; }
bool Engine::save_project(){ if(project_path_.empty())return false; std::ofstream out(project_path_+"/project.rcproject",std::ios::trunc); if(!out)return false; out<<settings_.name<<"\n"<<settings_.package_id<<"\n"<<settings_.version_code<<"\n"; return(bool)out; }
std::uint64_t Engine::create_object(const std::string& n){ SceneObject o; o.id=next_id_++; o.name=n; objects_.push_back(o); return o.id; }
bool Engine::delete_object(std::uint64_t id){ for(auto it=objects_.begin();it!=objects_.end();++it) if(it->id==id){objects_.erase(it);return true;} return false; }
void Engine::touch_begin(int id,float x,float y){ input_.begin(id,x,y); }
void Engine::touch_move(int id,float x,float y){ input_.move(id,x,y); }
void Engine::touch_end(int id,float x,float y){ input_.end(id,x,y); }
}