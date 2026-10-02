package com.rcempire.rcmobile;
import android.app.Activity; import android.opengl.GLSurfaceView; import android.os.Bundle; import android.view.MotionEvent; import android.view.Window; import android.view.WindowManager;
public final class MainActivity extends Activity {
 private GLSurfaceView view;
 private static native void nativeInit(int w,int h); private static native void nativeResize(int w,int h); private static native void nativeFrame(float dt); private static native void nativeTouch(int action,float x,float y);
 static { System.loadLibrary("rcengine"); }
 @Override protected void onCreate(Bundle b){super.onCreate(b);requestWindowFeature(Window.FEATURE_NO_TITLE);getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN,WindowManager.LayoutParams.FLAG_FULLSCREEN);
 view=new GLSurfaceView(this);view.setEGLContextClientVersion(3);view.setRenderer(new GLSurfaceView.Renderer(){long last=System.nanoTime();
 public void onSurfaceCreated(javax.microedition.khronos.egl.EGLConfig c){}
 public void onSurfaceChanged(javax.microedition.khronos.egl.EGLConfig c,int w,int h){nativeResize(w,h);nativeInit(w,h);}
 public void onDrawFrame(javax.microedition.khronos.opengles.GL10 gl){long now=System.nanoTime();float dt=(now-last)/1000000000.0f;last=now;nativeFrame(dt);}});
 view.setOnTouchListener((v,e)->{int a=e.getActionMasked();int n=(a==MotionEvent.ACTION_DOWN?0:(a==MotionEvent.ACTION_UP||a==MotionEvent.ACTION_CANCEL?1:2));nativeTouch(n,e.getX(),e.getY());return true;});setContentView(view);}
}
