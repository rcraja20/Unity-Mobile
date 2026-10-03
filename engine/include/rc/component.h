#pragma once
#include <cstdint>
#include <memory>
#include <string>
#include <unordered_map>
#include <vector>
namespace rc {
class Component { public: virtual ~Component()=default; virtual const char* type_name() const=0; bool enabled=true; };
struct MeshRendererComponent:Component { const char* type_name() const override{return "MeshRenderer";} std::string mesh; std::string material; };
struct CameraComponent:Component { const char* type_name() const override{return "Camera";} float fov=60,near_clip=0.01f,far_clip=1000; };
struct LightComponent:Component { const char* type_name() const override{return "Light";} float intensity=1; };
class ComponentStore {
public:
 template<class T> T* add(std::uint64_t entity){auto p=std::make_unique<T>();T* r=p.get();data_[entity].push_back(std::move(p));return r;}
 template<class T> T* get(std::uint64_t entity){auto it=data_.find(entity);if(it==data_.end())return nullptr;for(auto& p:it->second)if(auto* r=dynamic_cast<T*>(p.get()))return r;return nullptr;}
 bool remove_all(std::uint64_t entity){return data_.erase(entity)>0;}
private: std::unordered_map<std::uint64_t,std::vector<std::unique_ptr<Component>>> data_;
};
}