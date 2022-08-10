import java.util.StringTokenizer;
import java.util.Arrays;

//Scene description
Model model;
Material material;
ArrayList<PointLight> lights;
PVector Ia;

void setup() {
  size(640, 640);
  shader = new FlatShader();
  noStroke();
  updateS();
  try {
    loadScene("D:\\Rice\\spring2022\\COMP360\\lab4-1\\Lab4\\files\\default.txt");
  }
  catch(IOException e) {
    println("Default scene corrupted");
  }
  println("setup completed");
}

String path = null;

void fileSelected(File selection) {
  if (selection == null) {
    println("Window was closed or the user hit cancel.");
  } else {
    path = selection.getAbsolutePath();
  }
}


float phi = PI/2-0.25, theta = 0.0;
PVector Q, n, E, u, v;

//perpective projection
PVector persProj(PVector P) {
  float s1 = PVector.sub(E, Q).dot(n);
  float s2 = PVector.sub(Q, P).dot(n);
  float s3 = PVector.sub(E, P).dot(n);
  return PVector.add(PVector.mult(P, s1), PVector.mult(E, s2)).div(s3);
}

PVector convertXY(PVector P) {
  return new PVector(P.dot(u), P.dot(v));
}

float depth(PVector P){
  return n.dot(PVector.sub(Q,P));
}

//entry-wise product between two vectors
PVector hadamard(PVector a, PVector b){
  return new PVector(a.x*b.x, a.y*b.y, a.z*b.z);
}

//compute the barycentric coordinate of P w.r.t. A,B,C
PVector getBarycentric(PVector P, PVector A, PVector B, PVector C) {
  PVector u = PVector.sub(B, A), v = PVector.sub(C, A);
  float cross = u.x * v.y - v.x * u.y;
  float s = 1.0 / (cross) * (A.y * C.x - A.x * C.y + (C.y - A.y) * P.x + (A.x - C.x) * P.y);
  float t = 1.0 / (cross) * (A.x * B.y - A.y * B.x + (A.y - B.y) * P.x + (B.x - A.x) * P.y);
  return new PVector(1 - s - t, s, t);
}

boolean isin(PVector P, PVector A, PVector B, PVector C) {
  PVector bary = getBarycentric(P, A, B, C);
  return bary.x>=0 && bary.y>=0 && bary.z>=0;
}

//update the viewing plane and its spanning unit vectors
void updateS() {
  Q = new PVector(sin(phi)*cos(theta), sin(phi)*sin(theta), cos(phi));
  n = new PVector(sin(phi)*cos(theta), sin(phi)*sin(theta), cos(phi));
  E = PVector.mult(Q, 3);
  u = new PVector(-sin(phi)*sin(theta), sin(phi)*cos(theta), 0.0);
  v = new PVector(cos(phi)*cos(theta), cos(phi)*sin(theta), -sin(phi));
  u.normalize();
  v.normalize();
}

void keyPressed() {
  if (key == CODED) {
    if (keyCode == UP) phi = max(phi-0.01, 0.01);
    if (keyCode == DOWN) phi = min(phi+0.01, PI-0.01);
    if (keyCode == LEFT) theta -= 0.01;
    if (keyCode == RIGHT) theta += 0.01;
    updateS();
  } else {
    if (key=='l') {
      selectInput("Select a file to process:", "fileSelected");
    }
    if (key=='w') {
      shader = new Wireframe();
    }
    if (key=='f') {
      shader = new FlatShader();
    }
    if (key=='g') {
      shader = new Gouraud();
    }
    if (key=='p') {
      shader = new Phong();
    }
    println("pressed:"+key);
  }
}

PVector origin = new PVector(320, 320, 320);

Shader shader;

void draw() {
  background(120);
  if (model==null || shader==null) return;
  
  shader.shade();

  if(path!=null){
    try {
      loadScene(path);
    }
    catch(IOException e) {
      println("file corrupted");
    }
    path = null;
  }
  
  //theta+=0.02;
  //updateS();
  //if (theta>PI) noLoop();
  //saveFrame("wire\\wire-####.png");
}


PVector parsePVector(String line) {
  StringTokenizer st = new StringTokenizer(line);
  float a = Float.parseFloat(st.nextToken());
  float b = Float.parseFloat(st.nextToken());
  float c = Float.parseFloat(st.nextToken());
  return new PVector(a, b, c);
}

void loadScene(String filename) throws IOException {
  println("loading scene");
  BufferedReader reader = createReader(filename);
  println("----reader ready");
  int n;

  //new material
  PVector Ka = parsePVector(reader.readLine());
  PVector Kd = parsePVector(reader.readLine());
  PVector Ks = parsePVector(reader.readLine());
  material = new Material(Ka, Kd, Ks, Float.parseFloat(reader.readLine()));
  println("----material read");

  //Ia
  Ia = parsePVector(reader.readLine());
  println("----ambient read");
  //number of light sources
  n = Integer.parseInt(reader.readLine());

  //add all light sources
  lights=new ArrayList<>();
  for (int i=0; i<n; i++) {
    PVector pos = parsePVector(reader.readLine());
    PVector Ip = parsePVector(reader.readLine());
    lights.add(new PointLight(pos, Ip));
  }
  println("----lighting read");

  //number of vertices
  n = Integer.parseInt(reader.readLine());
  ArrayList<PVector> vertex=new ArrayList<>();
  for (int i=0; i<n; i++) {
    vertex.add(parsePVector(reader.readLine()));
  }
  println("----vertices read");

  //number of triangles
  n = Integer.parseInt(reader.readLine());
  ArrayList<PVector> triangle = new ArrayList<>();
  for (int i=0; i<n; i++) {
    triangle.add(parsePVector(reader.readLine()));
  }
  println("----triangles read");

  model = new Model(vertex, triangle);

  println("Scene loaded successfully");
}
