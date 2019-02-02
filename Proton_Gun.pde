import processing.sound.*;
import ddf.minim.*;
import controlP5.*;
import java.util.ArrayList;

//Arrays to hold particles in world.
ArrayList<Proton> protons = new ArrayList<Proton>();
ArrayList<Electron> electrons = new ArrayList<Electron>();

//Calculation Variables
int radius; //The distance between the CENTERS of the plates.
int trueRadius; //The distance between the SIDES of the plates.
int voltage;
double elecField;
int numOfElectrons;
int numOfProtons;
boolean posNeg = true;

//Display Variables
double displayedRadius; //Radius to be shown on screen.
int powerRadius = 0; //The Power of Radius.
double particleVelocityElectron;
double particleVelocityProton;

//Aesthetic Variable
int lineSpacing = 0; //The distance between electric field lines.
int nextLineY = 0; //Where the next electric field line is to be drawn.
int arrowHeadMovement = 0; 
int camx = 0;
int camy = 0;
int camz = 0;
float rotatex = 0;
float rotatey = 0;
float rotatez = 0;

ControlP5 cp5;
Slider radiusSlider;
Slider voltageSlider;
Button instructionsButton;
Toggle multPar;
PImage instructionScreen;

//Confirmed Mode
boolean confirmed = false;
PImage rick;
PImage illuminati;
PImage smallIlluminati;
AudioPlayer player;
Minim minim; //audio context
SoundFile file;

/* Called when applet is initalized.
 * Sets up sliders, button and toggle.
 * Loads and resizes images.
 * Loads sounds.
 */
void setup() {
  size(1000, 700, P3D);
  cp5 = new ControlP5(this);
  radiusSlider = cp5.addSlider("Radius", 10, 590, 400, 825, 35, 100, 10);
  voltageSlider = cp5.addSlider("Voltage", 10, 590, 100, 825, 55, 100, 10);
  instructionsButton = new Button(cp5, "Click and hold for Instructions").setSize(150, 20).setPosition(825, 95);
  multPar = cp5.addToggle("", true) .setPosition(825, 75) .setSize(60, 10) .setMode(ControlP5.SWITCH);
  instructionScreen = loadImage ("InstructionScreen.png");
  instructionScreen.resize(width, height);
  rick = loadImage("rick.jpg");
  rick.resize(100, 100);
  illuminati = loadImage("Illuminati-Logo.png");
  illuminati.resize(200, 200);
  smallIlluminati = loadImage("Illuminati-Logo.png");
  smallIlluminati.resize(10, 10);
  minim = new Minim(this);
  player = minim.loadFile("AnotherOne.mp3");
}

/* Method is called repeatedly after setup().
 * When instruction button is pressed, only displayes the instruction screen.
 *  Otherwise run program as normal.
 */
void draw() {
  if (instructionsButton.isPressed()) instructionScreen();
  else {
    camControls();
    background(200);//Set background color
    mantainRadius();//Set restrictions on the trueRadius variable
    drawPlates();//Draw the plates, battery, wires and field lines
    getGUIInfo();
    particles();//Remove protons from the heap if they are no longer on screen
  }
}

/* Screen for instructions.
 * Hides GUI.
 * Displayes Instruction Screen image.
 * Pressing 'i' when on screen enables "Confirmed Mode". Mode adds stupid sounds when certain things happen
 * To disable "Confirmed Mode" press 'o' when on this screen.
 */
void instructionScreen() {
  background(0);
  radiusSlider.setVisible(false);
  voltageSlider.setVisible(false);
  multPar.setVisible(false);
  fill(255);
  image(instructionScreen, 0, 0); 

  if (keyPressed == true) {
    switch (key) {
    case 'i':
      if (instructionsButton.isPressed()) {
        player = minim.loadFile("Illuminati.mp3");
        if (confirmed == false) player.play(); //To prevent sound from playing multiple times.
        confirmed = true;
      } 
      break;
    case 'o': 
      confirmed = false;
      break;
    }
  }
  if (confirmed) { 
    image(illuminati, 450, 450); 
    image(rick, 500, 500); 
    image(smallIlluminati, 530, 545); 
    image(smallIlluminati, 548, 541);
  } else image(rick, 500, 500);
}

/* Receives values from sliders and sets them to variables.
 * Enables visibility of GUI.
 */
void getGUIInfo() {
  radius = (int)radiusSlider.getValue();
  voltage = (int)voltageSlider.getValue();
  radiusSlider.setVisible(true);
  voltageSlider.setVisible(true);
  multPar.setVisible(true);
}

/* Called whenever a mouse button is released.
 * Based on which mouse button is released does the following:
 * - Left MB: Adds (an) Electron(s)
 * - Right MB: Adds (a) Proton(s)
 * - Center MB: Inverts value of posNeg
 */
void mouseReleased(MouseEvent eMouse) {
  if (eMouse.getButton() == LEFT) { 
    if (multPar.getValue() == 1) addParticles(0);//Shoot an proton from the current mouse position
    else addParticles(2);
  }
  if (eMouse.getButton() == RIGHT) { 
    if (multPar.getValue() == 1) addParticles(1);
    else addParticles(3);
  }
  if (eMouse.getButton() == CENTER) {
    if (posNeg == true) posNeg = false;
    else posNeg = true;
  }
}

/* Everything to do with Radius.
 * Determines both trueRadius and displayedRadius.
 * Determines power of displayedRadius.
 * Sets Minimums and Maximums for trueRadius.
 *  (Slider should have this down pat, but when I tried to remove it the code would not load).
 */
void mantainRadius() {
  powerRadius = 0;
  trueRadius = radius-10;
  displayedRadius = trueRadius;
  while (displayedRadius > 10) {
    displayedRadius/=10;
    powerRadius++;
  }
  if (trueRadius < 10) trueRadius = 10; // If the trueRadius is less than 10, set it back to 10
  if (trueRadius > 600) trueRadius = 600; //Prevent trueRadius value from exceeding 600
}

/* Adds particles to the world.
 * Only adds when the cursor is in between the plates.
 * Based on the int received, adds the following:
 *  -"0": Single Electron
 *  -"1": Single Proton
 *  -"2": Multiple Electrons with random numbers.
 *  -"3": Multiple Protons with random numbers.
 */
void addParticles(int typeOfParticle) {
  if (150 < mouseX && mouseX < radius + 150) {
    switch (typeOfParticle) {
    case 0: 
      protons.add(new Proton(mouseX-camx, mouseY-camy, -camz, 0, 0, 0)); 
      break;
    case 1: 
      electrons.add(new Electron(mouseX-camx, mouseY-camy, -camz, 0, 0, 0)); 
      break;
    case 2: 
      for (int i = 0; i < 6; i++) {
        electrons.add(new Electron(mouseX-camx+(int)(random(-15, 15)), mouseY-camy+(int)(random(-15, 15)), (int)(random(-15, 15))-camz, (int)(random(-5, 5)), (int)(random(-5, 5)), (int)(random(-5, 5))));
      } 
      break;
    case 3: 
      for (int i = 0; i < 6; i++) {
        protons.add(new Proton(mouseX-camx+(int)(random(-15, 15)), mouseY-camy+(int)(random(-15, 15)), (int)(random(-15, 15))-camz, (int)(random(-5, 5)), (int)(random(-5, 5)), (int)(random(-5, 5))));
      } 
      break;
    }
    player = minim.loadFile("AnotherOne.mp3");
    if (confirmed == true) player.play();
  }
}


/* Runs particles. Calculates the E (Electric Field). 
 * Passes along trueRadius, elecField, and posNeg for particle to calculate and draw itself.
 * Checks every particle and removes them when they...
 * - Leave the "screen" (go last left plate, and acctually leaving the screen in all other directions),
 * - Possess no movement in the x and y axis or,
 * - Come close/"touch" the right plates. 
 */
void particles() {
  elecField = (double) voltage / trueRadius;
  numOfElectrons = 0;
  numOfProtons = 0;
  for (Proton p : protons) { //Runs for as many Proton objects there are in the p array.
    numOfProtons++;
    p.run(trueRadius, elecField, posNeg);
    if (p.getPar_x() > width || p.getPar_x() < 150 || p.getPar_y() > height || p.getPar_y() < 0   ||   (p.getPar_Velx() == 0 && p.getPar_Vely() == 0 && p.getPar_x() > radius+150)   ||   (radius+140 <= p.getPar_x() && p.getPar_x() <= radius+160) && (10+(height/2) <= p.getPar_y() || p.getPar_y() <= -10+(height/2))) {
      if (confirmed == true) { player = minim.loadFile("Lion.mp3"); player.play(); }
      protons.remove(p); //Deletes the Proton object.
      break;
    } 
    particleVelocityProton = p.par_vel.mag();
  }
  for (Electron e : electrons) { //Runs for as many Electron objects there are in the e array.
    numOfElectrons++;
    e.run(trueRadius, elecField, posNeg);
    if (e.getPar_x() > width || e.getPar_x() < 150 || e.getPar_y() > height || e.getPar_y() < 0    ||    (e.getPar_Velx() == 0 && e.getPar_Vely() == 0 && e.getPar_x() > radius+150)   ||   (radius+140 <= e.getPar_x() && e.getPar_x() <= radius+160) && (10+(height/2) <= e.getPar_y() || e.getPar_y() <= -10+(height/2))) {
      if (confirmed == true) { player = minim.loadFile("Lion.mp3"); player.play(); }
      electrons.remove(e); //Deletes the Electron object.
      break;
    } 
    particleVelocityElectron = e.par_vel.mag();
  }
}

void drawPlates() {
  //Draw Left Plates (Positive) 
  translate(150, height/2);
  strokeWeight(1);
  stroke(0);
  if (posNeg) fill(215, 20, 20);
  else fill(20, 20, 215);
  box(10, 500, -200); 

  //Battery
  fill(200);
  rect(-148, -50, 70, 100); //Box
  rect(-138, -60, 20, 10); //Left Pin
  rect(-108, -60, 20, 10); //Right Pin

  //Wires to left plate
  strokeWeight(6);
  if (posNeg) stroke(215, 20, 20);
  else stroke(20, 20, 215);
  line(-98, -60, -98, -250); 
  line(-98, -250, 0, -250);

  //Wires to right plate
  if (posNeg) stroke(20, 20, 215);
  else stroke(215, 20, 20);
  line(-128, -60, -128, -300); 
  line(-128, -300, trueRadius, -300);
  line(trueRadius, -300, trueRadius, -250);

  //Wires that connect plates
  stroke(225, 165, 0, 200);
  line(-5, 250, trueRadius + 5, 250); //Connects left & bottom-right plates.
  translate(0, 0, -100);
  if (posNeg) stroke(20, 20, 215);
  else stroke(215, 20, 20);
  line(trueRadius, 20, trueRadius, -20); //Connects both right plates together.
  translate(0, 0, 100);
  fill(255, 0, 255);

  //Battery Text
  textSize(16);
  text("Voltage: " + voltage + "V", -145, -25, 65, 50);
  strokeWeight(1);
  stroke(0);

  textSize(12);
  if (multPar.getValue() == 1) text("Single Particle", 730, -265);
  else text("Multiple Particles", 730, -265);

  //Displays of Velocities and Electric Field
  if (numOfElectrons == 0) particleVelocityElectron = 0;
  if (numOfProtons == 0) particleVelocityProton = 0;
  textSize(16);
  fill(0, 0, 255);
  if (numOfElectrons > 1) text("Electron Velocity: N/A", 635, -210);
  else text("Electron Velocity: " + String.format("%.2f", particleVelocityElectron) + " m/s", 635, -210);
  fill(255, 0, 0);
  if (numOfProtons > 1) text("Proton Velocity: N/A", 635, -180);
  else text("Proton Velocity: " + String.format("%.2f", particleVelocityProton) + " m/s", 635, -180);
  fill(0, 0, 0);
  text("Electric Field: " + String.format("%.2f", elecField) + " N/C", 635, -150);

  //Right Plate
  translate(trueRadius, 0);
  if (posNeg) fill(20, 20, 215);
  else fill(215, 20, 20);
  translate(0, -128);
  box(10, 245, -200); //Upper Right Plate
  translate(0, 256);
  box(10, 245, -200); //Lower Right Plate 
  translate(0, -128);

  //Length Labels
  stroke(0);
  strokeWeight(12);
  line(-trueRadius + 5, 300, -5, 300); //Line representing length.
  fill(0);
  textSize(16);
  text("Radius: " + (String.format("%.2f", displayedRadius)) + "  * 10^" + powerRadius + " m", -trueRadius, 325); //Text displaying length
  strokeWeight(1);
  fill(255);

  //Field Lines
  translate (0, 0, -180);
  strokeWeight(3);
  stroke(50);
  lineSpacing = (int) (1 / ((((double) voltage)/((double)trueRadius)) / 20));
  nextLineY = lineSpacing;

  for (int i = 0; i < 3; i++) {
    translate (0, 0, 90);
    while (nextLineY < 250) {
      if (posNeg) {
        //Lines Below.
        line(0, nextLineY, -trueRadius, nextLineY);
        line(arrowHeadMovement, nextLineY, arrowHeadMovement -15, nextLineY - 5); //Left line of arrow head.
        line(arrowHeadMovement, nextLineY, arrowHeadMovement -15, nextLineY + 5); //Right line of arrow head.
        //Lines Above.
        line(0, -nextLineY, -trueRadius, -nextLineY);
        line(arrowHeadMovement, -nextLineY, arrowHeadMovement -15, -nextLineY - 5); //Left line of arrow head.
        line(arrowHeadMovement, -nextLineY, arrowHeadMovement -15, -nextLineY + 5); //Right line of arrow head.
        nextLineY += lineSpacing;
      } else {
        //Lines Below.
        line(0, nextLineY, -trueRadius, nextLineY);
        line(arrowHeadMovement, nextLineY, arrowHeadMovement +15, nextLineY - 5); //Left line of arrow head.
        line(arrowHeadMovement, nextLineY, arrowHeadMovement +15, nextLineY + 5); //Right line of arrow head.
        //Lines Above.
        line(0, -nextLineY, -trueRadius, -nextLineY);
        line(arrowHeadMovement, -nextLineY, arrowHeadMovement +15, -nextLineY - 5); //Left line of arrow head.
        line(arrowHeadMovement, -nextLineY, arrowHeadMovement +15, -nextLineY + 5); //Right line of arrow head.
        nextLineY += lineSpacing;
      }
    }
    nextLineY = lineSpacing;
  }

  if (arrowHeadMovement >= 0 || -trueRadius > arrowHeadMovement) {
    if (posNeg) arrowHeadMovement = -trueRadius + 20;  
    else arrowHeadMovement = -20;
  }
  if (posNeg) arrowHeadMovement+=2;
  else arrowHeadMovement-=2;

  translate(-(150+radius), -350, -90);
}

/* Camera Controls
 * Based on keys pressed, changes values of variables. 
 * Translates world based on variables (as all translations and rotations reset when the draw loop is called again) to create the illusion of a camera.
 */
void camControls() {
  if (keyPressed == true) {
    switch (key) {
    case '1': 
      rotatex += 0.2;
      break;
    case '2': 
      rotatex -= 0.2;
      break;
    case '3': 
      rotatey += 0.2;
      break;
    case '4': 
      rotatey -= 0.2;
      break;
    case '5': 
      rotatez += 0.2;
      break;
    case '6': 
      rotatez -= 0.2;
      break;
    }
    switch (keyCode) { //Arrow Keys
    case UP: 
      camy += 10;
      break;
    case DOWN: 
      camy -= 10;
      break;
    case LEFT:  
      camx += 10;
      break;
    case RIGHT: 
      camx -= 10;
      break;
    }
  }
  translate(camx, camy, camz);
  rotateX(rotatex);
  rotateY(rotatey);
  rotateZ(rotatez);
}

/* Gets input from mouseWheel and changes variable accordingly to create illusion of zooming.
 * Inspired by a certain Lord Emporer and his pupil.
 */
void mouseWheel(MouseEvent event) {
  int e = event.getCount();
  switch (e) {
  case -1: 
    camz += 10;
    break;
  case 1: 
    camz -= 10;
    break;
  }
}
