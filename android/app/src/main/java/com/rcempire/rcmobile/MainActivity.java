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
 private GLSurfaceView view;
 private TextView status;
 private static native void nativeInit(int w,int h);
 private static native void nativeResize(int w,int h);
 private static native void nativeFrame(float dt);
 private static native void nativeTouch(int action,int pointerId,float x,float y);
 private static native long nativeCreateObject(String name);
 private static native boolean nativeDeleteSelected();
 private static native boolean nativePlay(boolean playing);
 private static native boolean nativePauseToggle();
 private static native boolean nativeSave();
 private static native String nativeStatus();
 private static native boolean nativeCreateProject(String path);
 private static native String nativeObjects();
 private static native boolean nativeSelectObject(long id);
 private static native long nativeSelectedObject();
 static { System.loadLibrary("rcengine"); }

 private Button button(String text) {
  Button b=new Button(this); b.setText(text); b.setAllCaps(false); return b;
 }

 @Override protected void onCreate(Bundle b) {
  super.onCreate(b);
  requestWindowFeature(Window.FEATURE_NO_TITLE);
  getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN,WindowManager.LayoutParams.FLAG_FULLSCREEN);

  FrameLayout root=new FrameLayout(this);
  view=new GLSurfaceView(this);
  view.setEGLContextClientVersion(3);
  view.setRenderer(new GLSurfaceView.Renderer() {
   long last=System.nanoTime();
   public void onSurfaceCreated(javax.microedition.khronos.opengles.GL10 gl,javax.microedition.khronos.egl.EGLConfig c) {}
   public void onSurfaceChanged(javax.microedition.khronos.opengles.GL10 gl,int w,int h) { nativeResize(w,h); nativeInit(w,h); }
   public void onDrawFrame(javax.microedition.khronos.opengles.GL10 gl) {
    long now=System.nanoTime();
    float dt=(now-last)/1000000000.0f;
    last=now;
    nativeFrame(dt);
    runOnUiThread(()->{ if(status!=null) status.setText(nativeStatus()); });
   }
  });
  view.setOnTouchListener((v,e)->{
   int a=e.getActionMasked(), i=e.getActionIndex();
   int n=(a==MotionEvent.ACTION_DOWN||a==MotionEvent.ACTION_POINTER_DOWN)?0:
         (a==MotionEvent.ACTION_UP||a==MotionEvent.ACTION_POINTER_UP||a==MotionEvent.ACTION_CANCEL)?1:2;
   nativeTouch(n,e.getPointerId(i),e.getX(i),e.getY(i));
   return true;
  });
  root.addView(view,new FrameLayout.LayoutParams(-1,-1));

  nativeCreateProject(getFilesDir().getAbsolutePath());

  LinearLayout top=new LinearLayout(this);
  top.setOrientation(LinearLayout.HORIZONTAL);
  top.setGravity(Gravity.CENTER_VERTICAL);
  top.setPadding(8,4,8,4);
  top.setBackgroundColor(Color.argb(225,18,22,29));
  status=new TextView(this);
  status.setTextColor(Color.WHITE);
  status.setTextSize(13);
  status.setText("Unity Mobile | Editor");
  top.addView(status,new LinearLayout.LayoutParams(0,48,1));

  LinearLayout left=new LinearLayout(this);
  left.setOrientation(LinearLayout.VERTICAL);
  left.setPadding(6,62,6,6);
  left.setBackgroundColor(Color.argb(205,12,15,20));
  TextView lh=new TextView(this);
  lh.setText("HIERARCHY");
  lh.setTextColor(Color.WHITE);
  lh.setTextSize(12);
  left.addView(lh);
  LinearLayout hierarchyRows=new LinearLayout(this);
  hierarchyRows.setOrientation(LinearLayout.VERTICAL);
  left.addView(hierarchyRows);

  LinearLayout right=new LinearLayout(this);
  right.setOrientation(LinearLayout.VERTICAL);
  right.setPadding(8,62,8,8);
  right.setBackgroundColor(Color.argb(205,12,15,20));
  TextView inspector=new TextView(this);
  inspector.setTextColor(Color.WHITE);
  inspector.setTextSize(12);
  right.addView(inspector);

  final Runnable[] refresh=new Runnable[1];
  refresh[0]=()->{
   hierarchyRows.removeAllViews();
   inspector.setText("INSPECTOR\\n\\nNo object selected.");
   String data=nativeObjects();
   for(String line:data.split("\\n")){
    if(line.isEmpty()) continue;
    String[] q=line.split("\\|",-1);
    if(q.length<12) continue;
    Button row=button((q[0].equals(String.valueOf(nativeSelectedObject()))?"▶ ":"")+q[1]);
    row.setGravity(Gravity.LEFT);
    row.setOnClickListener(v->{ nativeSelectObject(Long.parseLong(q[0])); refresh[0].run(); });
    hierarchyRows.addView(row);
    if(q[0].equals(String.valueOf(nativeSelectedObject()))) {
     inspector.setText("INSPECTOR\\n\\n"+q[1]+"\\n\\nTransform\\nPosition: "+q[2]+", "+q[3]+", "+q[4]+
       "\\nRotation: "+q[5]+", "+q[6]+", "+q[7]+"\\nScale: "+q[8]+", "+q[9]+", "+q[10]+
       "\\n\\nComponents\\nMesh Renderer\\nCamera\\nLight"+
       "\\n\\nRC Empire Support\\nsupport.rcempire@gmail.com"+
       "\\n\\nBusiness\\nrcempire.official@gmail.com");
    }
   }
  };

  Button add=button("+ Cube");
  add.setOnClickListener(x->{nativeCreateObject("Cube");refresh[0].run();});
  top.addView(add);
  Button del=button("Delete");
  del.setOnClickListener(x->{nativeDeleteSelected();refresh[0].run();});
  top.addView(del);
  Button play=button("Play");
  play.setOnClickListener(x->{nativePlay(true);});
  top.addView(play);
  Button pause=button("Pause");
  pause.setOnClickListener(x->{nativePauseToggle();});
  top.addView(pause);
  Button save=button("Save");
  save.setOnClickListener(x->{nativeSave();refresh[0].run();});
  top.addView(save);

  root.addView(top,new FrameLayout.LayoutParams(-1,56,Gravity.TOP));
  root.addView(left,new FrameLayout.LayoutParams(190,-1,Gravity.LEFT));
  root.addView(right,new FrameLayout.LayoutParams(210,-1,Gravity.RIGHT));
  refresh[0].run();
  setContentView(root);
 }
}