#pragma once
#include <cstdint>
#include <string>
#include <vector>
namespace rc {
enum class WidgetType{Panel,Button,Label,Slider,Toggle};
struct GameWidget{std::uint64_t id=0;WidgetType type=WidgetType::Panel;std::string text;float x=0,y=0,w=100,h=48;bool visible=true;};
class GameUI{public:std::uint64_t add(WidgetType,const std::string&,float,float,float,float);bool remove(std::uint64_t);const std::vector<GameWidget>& widgets()const{return widgets_;}private:std::vector<GameWidget> widgets_;std::uint64_t next_=1;};
}