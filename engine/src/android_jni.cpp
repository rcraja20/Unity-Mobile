#include "rc/engine.h"
#include <jni.h>
#include <string>
static std::string jstring_to_string(JNIEnv* e,jstring s){if(!s)return{};const char*p=e->GetStringUTFChars(s,nullptr);std::string out=p?p:"";e->ReleaseStringUTFChars(s,p);return out;}
extern "C" JNIEXPORT void JNICALL Java_com_rcempire_rcmobile_MainActivity_nativeInit(JNIEnv*,jobject,jint w,jint h){rc::instance().initialize(w,h);}
extern "C" JNIEXPORT void JNICALL Java_com_rcempire_rcmobile_MainActivity_nativeResize(JNIEnv*,jobject,jint w,jint h){rc::instance().resize(w,h);}
extern "C" JNIEXPORT void JNICALL Java_com_rcempire_rcmobile_MainActivity_nativeFrame(JNIEnv*,jobject,jfloat dt){rc::instance().update(dt);rc::instance().render();}
extern "C" JNIEXPORT void JNICALL Java_com_rcempire_rcmobile_MainActivity_nativeTouch(JNIEnv*,jobject,jint action,jint pointerId,jfloat x,jfloat y){if(action==0)rc::instance().touch_begin(pointerId,x,y);else if(action==1)rc::instance().touch_end(pointerId,x,y);else rc::instance().touch_move(pointerId,x,y);}
extern "C" JNIEXPORT jlong JNICALL Java_com_rcempire_rcmobile_MainActivity_nativeCreateObject(JNIEnv*e,jobject,jstring n){return(jlong)rc::instance().create_object(jstring_to_string(e,n));}
extern "C" JNIEXPORT jboolean JNICALL Java_com_rcempire_rcmobile_MainActivity_nativeDeleteSelected(JNIEnv*,jobject){auto id=rc::instance().selected_object();return id&&rc::instance().delete_object(id);}
extern "C" JNIEXPORT jboolean JNICALL Java_com_rcempire_rcmobile_MainActivity_nativePlay(JNIEnv*,jobject,jboolean p){return rc::instance().set_playing(p);}
extern "C" JNIEXPORT jboolean JNICALL Java_com_rcempire_rcmobile_MainActivity_nativePauseToggle(JNIEnv*,jobject){return rc::instance().toggle_pause();}
extern "C" JNIEXPORT jboolean JNICALL Java_com_rcempire_rcmobile_MainActivity_nativeSave(JNIEnv*,jobject){return rc::instance().save_project();}
extern "C" JNIEXPORT jstring JNICALL Java_com_rcempire_rcmobile_MainActivity_nativeStatus(JNIEnv*e,jobject){return e->NewStringUTF(rc::instance().status_text().c_str());}

extern "C" JNIEXPORT jboolean JNICALL Java_com_rcempire_rcmobile_MainActivity_nativeCreateProject(JNIEnv*e,jobject,jstring path){
 rc::ProjectSettings s; return rc::instance().create_project(jstring_to_string(e,path),s);
}
extern "C" JNIEXPORT jstring JNICALL Java_com_rcempire_rcmobile_MainActivity_nativeObjects(JNIEnv*e,jobject){
 std::string out;
 for(const auto&o:rc::instance().objects()){
  out+=std::to_string(o.id)+"|"+o.name+"|"+std::to_string(o.position[0])+"|"+std::to_string(o.position[1])+"|"+std::to_string(o.position[2])+"|"+std::to_string(o.rotation[0])+"|"+std::to_string(o.rotation[1])+"|"+std::to_string(o.rotation[2])+"|"+std::to_string(o.scale[0])+"|"+std::to_string(o.scale[1])+"|"+std::to_string(o.scale[2])+"|"+(o.active?"1":"0")+"\n";
 }
 return e->NewStringUTF(out.c_str());
}
extern "C" JNIEXPORT jboolean JNICALL Java_com_rcempire_rcmobile_MainActivity_nativeSelectObject(JNIEnv*,jobject,jlong id){
 return rc::instance().select_object((std::uint64_t)id);
}

extern "C" JNIEXPORT jlong JNICALL Java_com_rcempire_rcmobile_MainActivity_nativeSelectedObject(JNIEnv*,jobject){
 return (jlong)rc::instance().selected_object();
}
