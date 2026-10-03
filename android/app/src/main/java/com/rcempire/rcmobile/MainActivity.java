package com.rcempire.rcmobile;
import android.app.Activity;
import android.graphics.Color;
import android.os.Bundle;
import android.view.Gravity;
import android.view.MotionEvent;
import android.view.Window;
import android.view.WindowManager;
import android.widget.Button;
import android.widget.FrameLayout;
import android.widget.LinearLayout;
import android.widget.TextView;
import android.opengl.GLSurfaceView;

public final class MainActivity extends Activity {
 private GLSurfaceView view; private TextView status;
 private static native void nativeInit(int w,int h); private static native void nativeResize(int w,int h);
 private static native void nativeFrame(float dt); private static native void nativeTouch(int action,int pointerId,float x,float y);
 private static native long nativeCreateObject(String name); private static native boolean nativeDeleteSelected();
 private static native boolean nativePlay(boolean playing); private static native boolean nativePauseToggle();
 private static native boolean nativeSave(); private static native String nativeStatus();
 static { System.loadLibrary("rcengine"); }

 private Button button(String text){Button b=new Button(this);b.setText(text);b.setAllCaps(false);return b;}
 @Override protected void onCreate(Bundle b){super.onCreate(b);requestWindowFeature(Window.FEATURE_NO_TITLE);getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN,WindowManager.LayoutParams.FLAG_FULLSCREEN);
  FrameLayout root=new FrameLayout(this);view=new GLSurfaceView(this);view.setEGLContextClientVersion(3);view.setRenderer(new GLSurfaceView.Renderer(){long last=System.nanoTime();
   public void onSurfaceCreated(javax.microedition.khronos.opengles.GL10 gl,javax.microedition.khronos.egl.EGLConfig c){}
   public void onSurfaceChanged(javax.microedition.khronos.opengles.GL10 gl,int w,int h){nativeResize(w,h);nativeInit(w,h);}
   public void onDrawFrame(javax.microedition.khronos.opengles.GL10 gl){long now=System.nanoTime();float dt=(now-last)/1000000000.0f;last=now;nativeFrame(dt);runOnUiThread(()->{if(status!=null)status.setText(nativeStatus());});}});
  view.setOnTouchListener((v,e)->{int a=e.getActionMasked(),i=e.getActionIndex();int n=(a==MotionEvent.ACTION_DOWN||a==MotionEvent.ACTION_POINTER_DOWN?0:(a==MotionEvent.ACTION_UP||a==MotionEvent.ACTION_POINTER_UP||a==MotionEvent.ACTION_CANCEL?1:2));nativeTouch(n,e.getPointerId(i),e.getX(i),e.getY(i));return true;});
  root.addView(view,new FrameLayout.LayoutParams(-1,-1));
  LinearLayout top=new LinearLayout(this);top.setOrientation(LinearLayout.HORIZONTAL);top.setGravity(Gravity.CENTER_VERTICAL);top.setPadding(8,4,8,4);top.setBackgroundColor(Color.argb(225,18,22,29));
  status=new TextView(this);status.setTextColor(Color.WHITE);status.setTextSize(13);status.setText("Unity Mobile | Editor");top.addView(status,new LinearLayout.LayoutParams(0,48,1));
  Button add=button("+ Cube");add.setOnClickListener(x->{nativeCreateObject("Cube");});top.addView(add);
  Button del=button("Delete");del.setOnClickListener(x->{nativeDeleteSelected();});top.addView(del);
  Button play=button("Play");play.setOnClickListener(x->{nativePlay(true);});top.addView(play);
  Button pause=button("Pause");pause.setOnClickListener(x->{nativePauseToggle();});top.addView(pause);
  Button save=button("Save");save.setOnClickListener(x->{nativeSave();});top.addView(save);
  FrameLayout.LayoutParams tp=new FrameLayout.LayoutParams(-1,56,Gravity.TOP);root.addView(top,tp);
  LinearLayout left=new LinearLayout(this);left.setOrientation(LinearLayout.VERTICAL);left.setPadding(6,62,6,6);left.setBackgroundColor(Color.argb(205,12,15,20));
  TextView h=new TextView(this);h.setText("HIERARCHY");h.setTextColor(Color.WHITE);h.setTextSize(12);left.addView(h);
  TextView items=new TextView(this);items.setText("Main Camera\nCube\nDirectional Light\n+ new objects");items.setTextColor(Color.LTGRAY);items.setTextSize(13);left.addView(items);
  FrameLayout.LayoutParams lp=new FrameLayout.LayoutParams(190,-1,Gravity.LEFT);root.addView(left,lp);
  LinearLayout right=new LinearLayout(this);right.setOrientation(LinearLayout.VERTICAL);right.setPadding(8,62,8,8);right.setBackgroundColor(Color.argb(205,12,15,20));
  TextView ih=new TextView(this);ih.setText("INSPECTOR\n\nTransform\nPosition\nRotation\nScale\n\nComponents\nMesh Renderer\nCamera\nLight\n\nRC Empire Support\nsupport.rcempire@gmail.com\n\nBusiness\nrcempire.official@gmail.com");ih.setTextColor(Color.WHITE);ih.setTextSize(12);right.addView(ih);
  FrameLayout.LayoutParams rp=new FrameLayout.LayoutParams(210,-1,Gravity.RIGHT);root.addView(right,rp);
  setContentView(root);
 }
}