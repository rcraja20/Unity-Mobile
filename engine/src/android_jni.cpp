#include "rc/engine.h"
#include <jni.h>
extern "C" JNIEXPORT void JNICALL Java_com_rcempire_rcmobile_MainActivity_nativeInit(JNIEnv*,jobject,jint w,jint h){rc::instance().initialize(w,h);}
extern "C" JNIEXPORT void JNICALL Java_com_rcempire_rcmobile_MainActivity_nativeResize(JNIEnv*,jobject,jint w,jint h){rc::instance().resize(w,h);}
extern "C" JNIEXPORT void JNICALL Java_com_rcempire_rcmobile_MainActivity_nativeFrame(JNIEnv*,jobject,jfloat dt){rc::instance().update(dt);rc::instance().render();}
extern "C" JNIEXPORT void JNICALL Java_com_rcempire_rcmobile_MainActivity_nativeTouch(JNIEnv*,jobject,jint action,jfloat x,jfloat y){if(action==0)rc::instance().touch_begin(x,y);else if(action==1)rc::instance().touch_end(x,y);else rc::instance().touch_move(x,y);}
