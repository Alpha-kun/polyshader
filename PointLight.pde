/*Wrapper class for point light source*/
public class PointLight {

  PVector pos;//light position
  PVector Ip;// RGB intensity

  public PointLight(PVector pos, PVector Ip) {
    this.pos=pos;
    this.Ip=Ip;
  }
}
