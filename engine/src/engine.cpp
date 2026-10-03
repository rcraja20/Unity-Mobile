#include "rc/engine.h"
#include <fstream>
#include <sstream>
#include <algorithm>
#include <cmath>
namespace rc {
Engine& instance(){static Engine e;return e;}
bool Engine::initialize(int w,int h){
 width_=w>0?w:1;height_=h>0?h:1;initialized_=true;
 ui_.set_viewport((float)width_,(float)height_);viewport_.resize(width_,height_);renderer().initialize(width_,height_);
 if(objects_.empty()){create_object("Main Camera");create_object("Cube");create_object("Directional Light");objects_[0].position[1]=1.5f;objects_[0].position[2]=4.0f;objects_[1].position[1]=0.75f;objects_[2].position[1]=3.0f;selected_id_=objects_[1].id;}
 return true;
}
void Engine::resize(int w,int h){width_=w>0?w:1;height_=h>0?h:1;ui_.set_viewport((float)width_,(float)height_);viewport_.resize(width_,height_);renderer().resize(width_,height_);}
void Engine::update(float dt){float d=std::min(dt,0.05f);physics_.step(d);collision_.step(physics_,d);particles_.update(d);animator_.update(d);audio_.update(d);scripts_.update(d);play_.update(d);profiler_.frame(d);}
void Engine::render(){renderer().set_camera(viewport_.camera());renderer().begin_frame();renderer().draw_grid(20,1);renderer().draw_axes(2);for(const auto&o:objects_)if(o.active)renderer().draw_cube({o.position[0],o.position[1],o.position[2]},{o.rotation[0],o.rotation[1],o.rotation[2]},{o.scale[0],o.scale[1],o.scale[2]},o.id==selected_id_);renderer().end_frame();}
void Engine::shutdown(){initialized_=false;objects_.clear();selected_id_=0;}
bool Engine::create_project(const std::string& path,const ProjectSettings&s){project_path_=path;settings_=s;objects_.clear();next_id_=1;selected_id_=0;return save_project();}
bool Engine::open_project(const std::string&path){std::ifstream in(path+"/project.rcproject");if(!in)return false;project_path_=path;std::getline(in,settings_.name);std::getline(in,settings_.package_id);in>>settings_.version_code;std::string line;std::getline(in,line);objects_.clear();while(std::getline(in,line)){std::istringstream ss(line);SceneObject o;ss>>o.id>>o.name>>o.position[0]>>o.position[1]>>o.position[2]>>o.rotation[0]>>o.rotation[1]>>o.rotation[2]>>o.scale[0]>>o.scale[1]>>o.scale[2]>>o.active;if(ss){objects_.push_back(o);next_id_=std::max(next_id_,o.id+1);}}if(objects_.empty())create_object("GameObject");selected_id_=objects_.front().id;return true;}
bool Engine::save_project(){if(project_path_.empty())return false;std::ofstream out(project_path_+"/project.rcproject",std::ios::trunc);if(!out)return false;out<<settings_.name<<"\n"<<settings_.package_id<<"\n"<<settings_.version_code<<"\n";for(const auto&o:objects_)out<<o.id<<" "<<o.name<<" "<<o.position[0]<<" "<<o.position[1]<<" "<<o.position[2]<<" "<<o.rotation[0]<<" "<<o.rotation[1]<<" "<<o.rotation[2]<<" "<<o.scale[0]<<" "<<o.scale[1]<<" "<<o.scale[2]<<" "<<o.active<<"\n";return(bool)out;}
std::uint64_t Engine::create_object(const std::string&n){SceneObject o;o.id=next_id_++;o.name=n.empty()?"GameObject":n;objects_.push_back(o);selected_id_=o.id;return o.id;}
bool Engine::delete_object(std::uint64_t id){auto it=std::find_if(objects_.begin(),objects_.end(),[&](const SceneObject&o){return o.id==id;});if(it==objects_.end())return false;objects_.erase(it);if(selected_id_==id)selected_id_=objects_.empty()?0:objects_.back().id;return true;}
bool Engine::select_object(std::uint64_t id){for(const auto&o:objects_)if(o.id==id){selected_id_=id;return true;}return false;}
bool Engine::set_playing(bool playing){if(playing){play_.start();runtime_.start();}else{play_.stop();runtime_.stop();}return true;}
bool Engine::toggle_pause(){if(!play_.playing())return false;if(play_.paused())play_.resume();else play_.pause();return true;}
std::string Engine::status_text()const{std::ostringstream s;s<<"Unity Mobile | "<<objects_.size()<<" objects | "<<(play_.playing()?(play_.paused()?"PAUSED":"PLAYING"):"EDITOR")<<" | "<<int(profiler_.stats().fps)<<" FPS";return s.str();}
void Engine::touch_begin(int id,float x,float y){input_.begin(id,x,y);ui_.pointer_down(id,x,y);}
void Engine::touch_move(int id,float x,float y){input_.move(id,x,y);const auto&g=input_.gestures();if(input_.pointers().size()==1)viewport_.orbit_from_drag(g.pan_x,g.pan_y);else if(input_.pointers().size()==2){viewport_.pan_from_drag(g.pan_x,g.pan_y);viewport_.zoom_from_pinch(g.pinch_delta);}ui_.pointer_move(id,x,y);}
void Engine::touch_end(int id,float x,float y){bool tap=input_.pointers().size()==1;input_.end(id,x,y);if(tap&&!objects_.empty()){auto it=std::find_if(objects_.begin(),objects_.end(),[&](const SceneObject&o){return o.id==selected_id_;});size_t i=it==objects_.end()?0:size_t(it-objects_.begin());selected_id_=objects_[(i+1)%objects_.size()].id;}ui_.pointer_up(id,x,y);input_.clear_gesture_deltas();}
}