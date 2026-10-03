#pragma once
#include <cstdint>
#include <functional>
#include <string>
#include <vector>
namespace rc {
struct Rect { float x=0,y=0,w=0,h=0; bool contains(float px,float py) const { return px>=x && py>=y && px<=x+w && py<=y+h; } };
enum class UiAnchor { TopLeft, TopRight, BottomLeft, BottomRight, Center };
struct UiNode {
 std::uint64_t id=0; std::string name; Rect rect; UiAnchor anchor=UiAnchor::TopLeft;
 bool visible=true, enabled=true; std::vector<std::uint64_t> children;
};
class UiSystem {
public:
 void set_viewport(float width,float height);
 std::uint64_t add_node(const std::string& name, Rect rect, UiAnchor anchor=UiAnchor::TopLeft);
 bool remove_node(std::uint64_t id);
 bool set_visible(std::uint64_t id,bool visible);
 bool set_enabled(std::uint64_t id,bool enabled);
 UiNode* hit_test(float x,float y);
 void pointer_down(int pointer_id,float x,float y);
 void pointer_move(int pointer_id,float x,float y);
 void pointer_up(int pointer_id,float x,float y);
 const std::vector<UiNode>& nodes() const { return nodes_; }
private:
 Rect layout_rect(const UiNode& n) const;
 std::vector<UiNode> nodes_; float width_=1,height_=1; std::uint64_t next_id_=1;
};
}