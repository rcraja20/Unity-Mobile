#pragma once
#include <string>
#include "rc/assets.h"
namespace rc { class AssetImporter { public: AssetType detect(const std::string&path)const; bool supported(const std::string&path)const; }; }