#include "rc/assets.h"
#include <algorithm>
#include <cctype>
namespace rc {
static std::string base_name(const std::string&p){auto n=p.find_last_of("/\\");return n==std::string::npos?p:p.substr(n+1);}
bool AssetDatabase::add(const std::string& p,AssetType t,std::uint64_t s){if(index_.count(p))return false;Asset a;a.id=next_id_++;a.path=p;a.name=base_name(p);a.type=t;a.size=s;index_[p]=assets_.size();assets_.push_back(a);return true;}
bool AssetDatabase::remove(const std::string&p){auto it=index_.find(p);if(it==index_.end())return false;auto i=it->second,last=assets_.size()-1;if(i!=last){assets_[i]=assets_[last];index_[assets_[i].path]=i;}assets_.pop_back();index_.erase(it);return true;}
const Asset* AssetDatabase::find(const std::string&p)const{auto it=index_.find(p);return it==index_.end()?nullptr:&assets_[it->second];}
std::vector<Asset> AssetDatabase::search(const std::string&q)const{std::vector<Asset> out;for(const auto&a:assets_){auto n=a.name;auto x=n;auto y=q;std::transform(x.begin(),x.end(),x.begin(),[](unsigned char c){return std::tolower(c);});std::transform(y.begin(),y.end(),y.begin(),[](unsigned char c){return std::tolower(c);});if(x.find(y)!=std::string::npos||a.path.find(q)!=std::string::npos)out.push_back(a);}return out;}
}