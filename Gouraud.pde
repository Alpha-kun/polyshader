
class Gouraud implements Shader {

  float[] depth;//depth buffer

  public Gouraud() {
    depth = new float[height*width];
  }

  public void shade() {
    //initialize depth buffer to +infinity
    Arrays.fill(depth, Float.POSITIVE_INFINITY);

    //viewing vector
    PVector V = PVector.div(E, E.mag());

    //projects all 3d vertex to screen
    //compute depth for all vertex
    PVector[] points = new PVector[model.Nv];
    float[] d = new float[model.Nv];
    for (int i=0; i<model.Nv; i++) {
      points[i] = PVector.add(origin, convertXY(persProj(model.vertex.get(i))).mult(640));
      d[i] = depth(model.vertex.get(i));
    }

    //compute normal at each vertex
    PVector[] vertexN = new PVector[model.Nv];
    for (int i=0; i<model.Nv; i++) vertexN[i] = new PVector(0, 0, 0);
    for (PVector trig : model.triangle) {
      //get indices of the vertices
      int i=(int)trig.x, j=(int)trig.y, k=(int)trig.z;
      //compute face normal
      PVector N = PVector.sub(model.vertex.get(j), model.vertex.get(i)).cross(PVector.sub(model.vertex.get(k), model.vertex.get(i)));
      N.normalize();
      vertexN[i].add(N);
      vertexN[j].add(N);
      vertexN[k].add(N);
    }
    for (int i=0; i<model.Nv; i++) vertexN[i].normalize();

    //compute color at each vertex
    PVector[] vertexC = new PVector[model.Nv];
    for (int i=0; i<model.Nv; i++) {
      //compute ambient
      PVector Itot = hadamard(Ia, material.Ka);
      //compute each point light contribution
      for (PointLight pl : lights) {
        PVector L = PVector.div(pl.pos, pl.pos.mag());
        PVector R = PVector.sub(PVector.mult(vertexN[i], 2*vertexN[i].dot(L)), L);
        PVector Id = hadamard(material.Kd, pl.Ip).mult(max(L.dot(vertexN[i]), 0));
        PVector Is = hadamard(material.Ks, pl.Ip).mult(pow(max(R.dot(V), 0), material.n));
        Itot.add(PVector.add(Id, Is));
      }
      vertexC[i]=Itot;
    }

    loadPixels();
    //draw all triangles
    for (PVector trig : model.triangle) {
      //get indices of the vertices
      int i=(int)trig.x, j=(int)trig.y, k=(int)trig.z;
      //color c = color(255, 255, 255);

      int minx = floor(min(points[i].x, points[j].x, points[k].x));
      int maxx = ceil(max(points[i].x, points[j].x, points[k].x));
      int miny = floor(min(points[i].y, points[j].y, points[k].y));
      int maxy = ceil(max(points[i].y, points[j].y, points[k].y));

      //for each pixel in the smallest retangle
      for (int y = max(miny, 0); y<min(maxy, height); y++) {
        for (int x = max(minx, 0); x<min(maxx, width); x++) {
          PVector D = new PVector(x, y);
          PVector bary = getBarycentric(D, points[i], points[j], points[k]);
          if (bary.x<0 || bary.y<0 || bary.z<0) continue;
          float dD = bary.x*d[i] + bary.y*d[j] + bary.z*d[k];
          if (dD<depth[y*width+x]) {
            depth[y*width+x] = dD;
            PVector linc = PVector.mult(vertexC[i], bary.x).add(PVector.mult(vertexC[j], bary.y)).add(PVector.mult(vertexC[k], bary.z));
            color c = color(min(linc.x, 1.0)*255, min(linc.y, 1.0)*255, min(linc.z, 1.0)*255);
            pixels[y*width+x] = c;
          }
        }
      }
    }
    updatePixels();
  }
}
