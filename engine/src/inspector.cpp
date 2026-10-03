#include "rc/inspector.h"
namespace rc {
bool Inspector::rename(Scene&s,std::uint64_t id,const std::string&n){auto e=s.find(id);if(!e)return false;e->name=n;return true;}
bool Inspector::set_position(Scene&s,std::uint64_t id,Vec3 v){auto e=s.find(id);if(!e)return false;e->transform.position=v;return true;}
bool Inspector::set_rotation(Scene&s,std::uint64_t id,Vec3 v){auto e=s.find(id);if(!e)return false;e->transform.rotation=v;return true;}
bool Inspector::set_scale(Scene&s,std::uint64_t id,Vec3 v){auto e=s.find(id);if(!e)return false;e->transform.scale=v;return true;}
bool Inspector::set_active(Scene&s,std::uint64_t id,bool a){auto e=s.find(id);if(!e)return false;e->active=a;return true;}
}