class Particle { //extends electron
  int parCharge;
  int parMass;
  PVector par_pos = new PVector(0, 0, 0);//The displacement from (0,0)
  PVector par_acc = new PVector(0, 0, 0);//Acceleration of particle
  PVector par_vel = new PVector(0, 0, 0);//Velocity of particle
  PVector elefield = new PVector(0, 0, 0);
  float par_mass;//mass(normalized value)
  float par_charge;//charge(normalized value)
  float par_velocity;//velocity(not vector)
  float electricField;
  
  //Init with an x and y position
  Particle(int _x, int _y, int _z, int _velx, int _vely, int _velz){
    par_pos.x = _x;
    par_pos.y = _y;
    par_pos.z = _z;
    par_vel.x = _velx;
    par_vel.y = _vely;
    par_vel.z = _velz;
  }
  
  /* Draws the Particle.
   * 0 = Electron
   * 1 = Proton
   */
  void drawParticle(int typeOfParticle){
    pushMatrix();
    translate(par_pos.x, par_pos.y, par_pos.z);
    noStroke();
    switch (typeOfParticle){
      case 0: fill(0,0,225);  sphere(2);  break;
      case 1: fill(255,0,0);  sphere(5);  break;
    }
    popMatrix();
  }
  
  //Calculate the velocity using the radius and voltage of the plates, then add it to the particle
  void calculations(float _radius, double _elecField, boolean _posNegX, int _parCharge, int _parMass){
    elefield.x = (float) _elecField;
    if(_radius+150 > par_pos.x){
      if (_posNegX == false) elefield.x *= -1;
      elefield.mult(_parCharge);
      par_acc = elefield;
      par_acc.div(_parMass);
      par_vel.add(par_acc);
    }
    par_pos.add(par_vel);
  }
  
  //Calculate the stringth of the electric field
  double calcElecField(double _volts1, double _radius1) {
  double elecfield = _volts1 / _radius1;
  System.out.println(elecfield);
  return elecfield;
  }
  
  //Calculate the velocity of the particle
  double calcVelocity(double elecfield, double radius1, double charge, double mass) {
  double vel;
  vel = Math.sqrt(((2 * charge * elecfield * radius1) / mass));
  return vel;
  }
  
  //Get x pos
  public int getPar_x(){
    return (int) par_pos.x;
  }
  
  //get y pos
  public int getPar_y(){
    return (int) par_pos.y;
  }
  
  public int getPar_Velx(){
    return (int) par_vel.x; 
  }
  
  public int getPar_Vely(){
    return (int) par_vel.y;
  }
}
