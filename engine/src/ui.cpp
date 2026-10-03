#include "rc/ui.h"
#include <algorithm>
#include <cmath>
namespace rc {
void UiSystem::set_viewport(float w,float h){ width_=w>0?w:1; height_=h>0?h:1; }
std::uint64_t UiSystem::add_node(const std::string& name, Rect rect, UiAnchor anchor){
 UiNode n; n.id=next_id_++; n.name=name; n.rect=rect; n.anchor=anchor; nodes_.push_back(n); return n.id;
}
bool UiSystem::remove_node(std::uint64_t id){ auto it=std::find_if(nodes_.begin(),nodes_.end(),[&](const UiNode& n){return n.id==id;}); if(it==nodes_.end()) return false; nodes_.erase(it); return true; }
bool UiSystem::set_visible(std::uint64_t id,bool v){ for(auto& n:nodes_) if(n.id==id){n.visible=v;return true;} return false; }
bool UiSystem::set_enabled(std::uint64_t id,bool e){ for(auto& n:nodes_) if(n.id==id){n.enabled=e;return true;} return false; }
Rect UiSystem::layout_rect(const UiNode& n) const {
 Rect r=n.rect;
 if(n.anchor==UiAnchor::TopRight) r.x=width_-n.rect.x-n.rect.w;
 else if(n.anchor==UiAnchor::BottomLeft) r.y=height_-n.rect.y-n.rect.h;
 else if(n.anchor==UiAnchor::BottomRight){r.x=width_-n.rect.x-n.rect.w;r.y=height_-n.rect.y-n.rect.h;}
 else if(n.anchor==UiAnchor::Center){r.x=(width_-n.rect.w)*0.5f+n.rect.x;r.y=(height_-n.rect.h)*0.5f+n.rect.y;}
 return r;
}
UiNode* UiSystem::hit_test(float x,float y){
 for(auto it=nodes_.rbegin();it!=nodes_.rend();++it) if(it->visible&&it->enabled&&layout_rect(*it).contains(x,y)) return &*it;
 return nullptr;
}
void UiSystem::pointer_down(int id,float x,float y){(void)id;(void)x;(void)y;}
void UiSystem::pointer_move(int id,float x,float y){(void)id;(void)x;(void)y;}
void UiSystem::pointer_up(int id,float x,float y){(void)id;(void)x;(void)y;}
}