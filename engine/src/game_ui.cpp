#include "rc/game_ui.h"
namespace rc{std::uint64_t GameUI::add(WidgetType t,const std::string&s,float x,float y,float w,float h){GameWidget v;v.id=next_++;v.type=t;v.text=s;v.x=x;v.y=y;v.w=w;v.h=h;widgets_.push_back(v);return v.id;}bool GameUI::remove(std::uint64_t id){for(auto i=widgets_.begin();i!=widgets_.end();++i)if(i->id==id){widgets_.erase(i);return true;}return false;}}
