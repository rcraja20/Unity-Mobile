#pragma once
#include <cstdint>
#include <string>
#include <vector>
#include "rc/ui.h"
#include "rc/input.h"
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
#include "rc/mesh.h"
#include "rc/texture.h"
#include "rc/importer.h"
#include "rc/gizmos.h"
#include "rc/editor.h"
#include "rc/collision.h"
#include "rc/scripting.h"
#include "rc/android_build.h"
#include "rc/runtime.h"
#include "rc/diagnostics.h"
#include "rc/package.h"
namespace rc {
struct ProjectSettings { std::string name="Unity Mobile Project"; std::string package_id="com.rcempire.unitymobile"; int version_code=1; };
struct SceneObject { std::uint64_t id=0; std::string name; float position[3]{0,0,0}; float rotation[3]{0,0,0}; float scale[3]{1,1,1}; bool active=true; };
class Engine {
public:
 bool initialize(int width,int height);
 void resize(int width,int height);
 void update(float dt);
 void render();
 void shutdown();
 bool create_project(const std::string& path,const ProjectSettings& settings);
 bool open_project(const std::string& path);
 bool save_project();
 const ProjectSettings& project_settings() const{return settings_;}
 std::uint64_t create_object(const std::string& name);
 bool delete_object(std::uint64_t id);
 bool select_object(std::uint64_t id);
 std::uint64_t selected_object() const{return selected_id_;}
 const SceneObject* object(std::uint64_t id) const;
 bool set_playing(bool playing);
 bool toggle_pause();
 bool is_playing() const{return play_.playing();}
 std::string status_text() const;
 std::vector<SceneObject>& objects(){return objects_;}
 void touch_begin(int pointer_id,float x,float y);
 void touch_move(int pointer_id,float x,float y);
 void touch_end(int pointer_id,float x,float y);
private:
 ProjectSettings settings_;
 UiSystem ui_;
 Scene scene_;
 Inspector inspector_;
 TouchInput input_;
 Viewport viewport_;
 PhysicsWorld physics_;
 CollisionWorld collision_;
 ComponentStore components_;
 ParticleSystem particles_;
 Animator animator_;
 AudioSystem audio_;
 ScriptRuntime scripts_;
 PlaySession play_;
 RuntimeState runtime_;
 Profiler profiler_;
 std::vector<SceneObject> objects_;
 std::string project_path_;
 std::uint64_t next_id_=1,selected_id_=0;
 int width_=1,height_=1;
 bool initialized_=false;
};
Engine& instance();
}
