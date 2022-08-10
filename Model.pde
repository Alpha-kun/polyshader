/*Wrapper class for model*/
public class Model {

  int Nv, Nt; //number of vertices and triangles
  ArrayList<PVector> vertex; //list of vertices
  ArrayList<PVector> triangle; //list of triangles (triples of indices)

  public Model(ArrayList<PVector> vertex, ArrayList<PVector> triangle) {
    this.Nv=vertex.size();
    this.Nt=triangle.size();
    this.vertex=vertex;
    this.triangle=triangle;
  }
}
