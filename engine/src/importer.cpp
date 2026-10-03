#include "rc/importer.h"
#include <algorithm>
namespace rc {
AssetType AssetImporter::detect(const std::string&p)const{auto n=p;auto dot=n.find_last_of('.');if(dot==std::string::npos)return AssetType::Unknown;std::transform(n.begin()+dot,n.end(),n.begin()+dot,[](unsigned char c){return (char)std::tolower(c);});if(n==".png"||n==".jpg"||n==".jpeg")return AssetType::Texture;if(n==".obj"||n==".gltf"||n==".glb")return AssetType::Model;if(n==".wav"||n==".ogg"||n==".mp3")return AssetType::Audio;if(n==".anim")return AssetType::Animation;return AssetType::Unknown;}
bool AssetImporter::supported(const std::string&p)const{return detect(p)!=AssetType::Unknown;}
}