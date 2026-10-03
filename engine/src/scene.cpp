#include "rc/scene.h"
#include <algorithm>
namespace rc {
Entity* Scene::find(std::uint64_t id){auto it=index_.find(id);return it==index_.end()?nullptr:&entities_[it->second];}
std::uint64_t Scene::create(const std::string& name,std::uint64_t parent){
 if(parent && !find(parent)) parent=0;
 Entity e; e.id=next_id_++; e.name=name; e.parent=parent;
 index_[e.id]=entities_.size(); entities_.push_back(e);
 if(parent) find(parent)->children.push_back(e.id);
 return e.id;
}
void Scene::detach(std::uint64_t id){
 Entity* e=find(id); if(!e||!e->parent)return;
 Entity* p=find(e->parent); if(p){auto& c=p->children;c.erase(std::remove(c.begin(),c.end(),id),c.end());}
 e->parent=0;
}
bool Scene::would_cycle(std::uint64_t id,std::uint64_t parent) const{
 if(!parent)return false; if(id==parent)return true;
 auto it=index_.find(parent);
 while(it!=index_.end()){const Entity& e=entities_[it->second]; if(!e.parent)return false; if(e.parent==id)return true; it=index_.find(e.parent);}
 return false;
}
bool Scene::set_parent(std::uint64_t id,std::uint64_t parent){
 Entity* e=find(id); if(!e|| (parent&& !find(parent)) || would_cycle(id,parent)) return false;
 detach(id); e=find(id); e->parent=parent; if(parent)find(parent)->children.push_back(id); return true;
}
bool Scene::destroy(std::uint64_t id){
 Entity* e=find(id); if(!e)return false;
 auto children=e->children; for(auto child:children) destroy(child);
 detach(id);
 std::size_t pos=index_[id], last=entities_.size()-1;
 if(pos!=last){entities_[pos]=entities_[last];index_[entities_[pos].id]=pos;}
 entities_.pop_back();index_.erase(id);return true;
}
}