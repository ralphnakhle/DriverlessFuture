

// ----------------------------------------------------------------------
// GLOBAL VARIABLES
// ----------------------------------------------------------------------

CarSystem systemOfCars;

// A path object (series of connected points)
CityBg cityBg ;

HighwayBg highwayBg;

GUI gui ;

// Using this variable to toggle between drawing the lines or not
boolean debug = false;
int gridSize = 1;
int cityGridSize = 180;
char scenario;

// ----------------------------------------------------------------------
//  FUNCTIONS
// ----------------------------------------------------------------------
void setup() {
  size(900, 700);
  scenario = 'C';
  //initialize Gui 
  gui = new GUI();

  cityBg = new CityBg(20, cityGridSize);
  highwayBg = new HighwayBg(40);

  // Call a function to generate new Path object


  systemOfCars = new CarSystem(scenario);
  systemOfCars.init();
}


// ----------------------------------------------------------------------
//  DRAW FUNCTION
// ----------------------------------------------------------------------

void draw() {

  // draw the background
  background(0, 10, 10);

  // display the right background
  switch(scenario) {
  case 'C': 
    // Display the road
    cityBg.display();

    break;

  case 'P': 
    // println("Scenario : P");  
    break;

  case 'H': 
    // Display the road
    highwayBg.display();
    break;

  case 'S': 
    // println("Scenario : S"); 
    break;

  default:             
    break;
  }


  // run the car system
  systemOfCars.run();

  //display Gui
  gui.display();
  gui.activateToggle();
}


// press space bar to able and disable collision and target lines.
public void keyPressed() {
  if (key == ' ') {
    debug = !debug;
  }
}

void mouseClicked() {  
  gui.mouseClicked();
  int controlMargin = width-width/10+10;

  if (mouseX >= controlMargin && mouseX <= controlMargin+50 && mouseY >= 50 && mouseY <= 340) {

    systemOfCars = new CarSystem(scenario);
    systemOfCars.init();
  }
}

