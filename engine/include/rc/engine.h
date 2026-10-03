#pragma once
#include <cstdint>
#include <string>
#include <vector>\n#include <memory>\n#include "rc/ui.h"\n#include "rc/input.h"
#include "rc/render.h"
#include "rc/viewport.h"
#include "rc/scene.h"
#include "rc/inspector.h"
#include "rc/component.h"
#include "rc/assets.h"
#include "rc/material.h"
#include "rc/physics.h"
#include "rc/audio.h"
#include "rc/particles.h"
#include "rc/animation.h"
#include "rc/game_ui.h"
#include "rc/script.h"
#include "rc/play.h"
#include "rc/build.h"
#include "rc/profiler.h"
namespace rc {
struct ProjectSettings { std::string name="RC Project"; std::string package_id="com.rcempire.rcmobile"; int version_code=1; };
struct SceneObject { std::uint64_t id=0; std::string name; float position[3]{0,0,0}; float rotation[3]{0,0,0}; float scale[3]{1,1,1}; };
class Engine {
public:
 bool initialize(int width,int height); void resize(int width,int height); void update(float dt); void render(); void shutdown();
 bool create_project(const std::string& path,const ProjectSettings& settings); bool open_project(const std::string& path); bool save_project();
 const ProjectSettings& project_settings() const{return settings_;}
 std::uint64_t create_object(const std::string& name); bool delete_object(std::uint64_t id); std::vector<SceneObject>& objects(){return objects_;}
 void touch_begin(int pointer_id,float x,float y); void touch_move(int pointer_id,float x,float y); void touch_end(int pointer_id,float x,float y);
private: ProjectSettings settings_;\n UiSystem ui_;
 Scene scene_;
 Inspector inspector_;\nTouchInput input_;
 Viewport viewport_; std::vector<SceneObject> objects_; std::string project_path_; std::uint64_t next_id_=1; int width_=1,height_=1; bool initialized_=false;
};
Engine& instance();
}