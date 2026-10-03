#pragma once
#include <cstdint>
#include <string>
#include <vector>
#include <unordered_map>
namespace rc {
enum class AssetType { Unknown, Folder, Scene, Model, Texture, Material, Audio, Animation };
struct Asset { std::uint64_t id=0; std::string path; std::string name; AssetType type=AssetType::Unknown; std::uint64_t size=0; };
class AssetDatabase {
public:
 bool add(const std::string& path,AssetType type,std::uint64_t size=0);
 bool remove(const std::string& path);
 const Asset* find(const std::string& path) const;
 std::vector<Asset> search(const std::string& query) const;
 const std::vector<Asset>& all() const{return assets_;}
private: std::vector<Asset> assets_; std::unordered_map<std::string,std::size_t> index_; std::uint64_t next_id_=1;
};
}