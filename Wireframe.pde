
class Wireframe implements Shader {

  public void shade() {
    stroke(255);

    ArrayList<PVector> points=new ArrayList<>();
    for (PVector vtx : model.vertex) {
      points.add(PVector.add(origin, convertXY(persProj(vtx)).mult(640)));
    }

    for (PVector trig : model.triangle) {
      int i=(int)trig.x, j=(int)trig.y, k=(int)trig.z;
      line(points.get(i).x, points.get(i).y, points.get(j).x, points.get(j).y);
      line(points.get(j).x, points.get(j).y, points.get(k).x, points.get(k).y);
      line(points.get(k).x, points.get(k).y, points.get(i).x, points.get(i).y);
    }
  }
}
