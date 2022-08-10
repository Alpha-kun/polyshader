/*Wrapper class for material properties*/
public class Material {

  PVector Ka; //ambient coefficients
  PVector Kd; //diffuse coefficients
  PVector Ks; //specular coefficients
  float n;//specular coefficients

  public Material(PVector Ka, PVector Kd, PVector Ks, float n) {
    this.Ka=Ka;
    this.Kd=Kd;
    this.Ks=Ks;
    this.n=n;
  }
}
