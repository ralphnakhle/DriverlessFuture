// Abstract class to contain the general behaviour of a car

abstract class Car {

  // Car position
  PVector position;

  //  change in position
  PVector velocity = new PVector(0, 0);
  // change in velocity
  PVector acceleration= new PVector(0, 0);

  // Size of the Car
  float carRadius = 6;

  // zone to check for other cars
  float safeZone;

  // variable for speed limit
  float speedLimit = 3;

  // Maximum steering force
  float steerLimit = 0.3;  

  // car color
  color carColor = color(60, 155, 216);

  // car target and origine
  PVector carDestination;

  // car Angle
  float carAngle = velocity.heading2D() + PI/2;
  float targetCarAngle = 0;
  // easing for car rotation
  float easing = 0.2;

  //a path for the car to follow
  CarPath carPath;
  int pathIndex = 1;
  // boolean to know if the car is parked
  boolean parked = false;
  // boolean to know if the car should be trashed
  boolean trashIt = false;

  // ID of the car
  int carID;


  //---------------------------------------------------------------
  // car constructo
  //---------------------------------------------------------------
  Car(int id) {
    // give starting position for the car
    position = getDestination(new PVector(0, 0));
    // get a first destination for the car
    carDestination = getDestination(position);
    // set the safezone
    safeZone = 100;
    // set the car ID
    carID = id;
  }

  // a methode to get the parking id for the car, overiden in the parking car subclass
  int getParkingId() {
    return 0 ;
  }

  //---------------------------------------------------------------
  // update methode
  //---------------------------------------------------------------
  void update() {
    velocity.add(acceleration);
    // limit the velocity to the maximum speed alowd
    velocity.limit(speedLimit);
    // add the velocity to the position
    position.add(velocity);
    // reset acceleration
    acceleration.mult(0);
  }

  //---------------------------------------------------------------
  // apply behaviors to the car
  //---------------------------------------------------------------
  void applyBehaviors(ArrayList<Car> Cars) {
    // calculate and apply the seperate force
    PVector separateForce = separate(Cars);
    applyForce(separateForce);

    // follow the path
    followPath();
  }
  //---------------------------------------------------------------
  // apply behaviors to the car alternative signatur for the city scenario
  //---------------------------------------------------------------
  void applyBehaviors(ArrayList<Car> Cars, ArrayList<Car> Amb) {
  }

  //---------------------------------------------------------------
  // apply behaviors to the car, pedestrian interaction
  //---------------------------------------------------------------
  void applyPedestrianBehaviors(Pedestrian pedestrian) {
    PVector separateForce = separateFromPedestrian(pedestrian);   
    followPath();
    applyForce(separateForce);
  }

  //---------------------------------------------------------------
  // apply force methode
  //---------------------------------------------------------------
  void applyForce(PVector force) {
    acceleration.add(force);
  }

  //---------------------------------------------------------------
  // a methode to know if a car should get trashed
  //---------------------------------------------------------------
  boolean trash() {
    if (trashIt) {
      return true;
    }
    else { 
      return false;
    }
  }

  // ----------------------------------------------------------------------
  //  Car display
  // ----------------------------------------------------------------------  
  void display() {
    // draw debuging info
    if (debug) {
      stroke(255, 60, 0, 80);
      strokeWeight(1);
      for (int v = 0; v < carPath.getSize()-1; v++ ) {
        line(carPath.points.get(v).x, carPath.points.get(v).y, carPath.points.get(v+1).x, carPath.points.get(v+1).y);
      }
    }
    // draw car
    fill(carColor);
    noStroke();
    // if the car is not moving, set a default angle,( for the parking)
    if (velocity.mag()<=0) {
      carAngle = 0;
    }
    // if the car is movint, set the angle acordint to it's velocity
    else {
      carAngle = velocity.heading() + PI/2;
    }

    // ease the rotation
    float dir = (carAngle - targetCarAngle) / TWO_PI;
    dir -= round( dir );
    dir *= TWO_PI;
    targetCarAngle += dir * easing;

    // draw the car
    pushMatrix();
    translate(position.x, position.y);
    rotate(targetCarAngle);
    beginShape();
    rectMode(CENTER);
    // check if the car is slow
    if (velocity.mag() < speedLimit/2) {
      fill(200);
    }
    else {      
      // make a blinking fill for the wheels
      fill(200);
      if (frameCount % 2== 0) {
        fill(150);
      }
    }
    // draw the wheels
    ellipse(carRadius/2.5, carRadius, carRadius/2, carRadius/2 );
    ellipse(-carRadius/2.5, carRadius, carRadius/2, carRadius/2 );
    ellipse(-carRadius/3, -carRadius/3, carRadius/2, carRadius/2 );
    ellipse(carRadius/3, -carRadius/3, carRadius/2, carRadius/2 );
    // draw the main body
    fill(carColor);
    ellipse(0, carRadius/2, carRadius*1.2, carRadius*2.5 );
    // set the tail ligth color
    if (velocity.mag() < speedLimit/2) {
      fill(255, 50, 0);
    }
    else {      
      fill(255, 150, 150);
    }
    // draw the tail light
    ellipse(-carRadius/4, carRadius*1.5, carRadius/2.5, carRadius/2.5);
    ellipse(carRadius/4, carRadius*1.5, carRadius/2.5, carRadius/2.5);
    endShape(CLOSE);
    popMatrix();
  }



  // ----------------------------------------------------------------------
  //  Go towards destination code & Path following
  // ----------------------------------------------------------------------
  // A method that calculates a steering force towards a target and following a path

  void followPath() {
    // PVector for the desired position
    PVector desired;
    // A vector pointing from the position to the first point of the path
    desired = PVector.sub(carPath.points.get(pathIndex), position); 

    // if the car is close enought to the first point  and is still in the first section
    if (desired.mag()<30 && pathIndex == 1) {  
      pathIndex = 2;  
      desired = PVector.sub(carPath.points.get(pathIndex), position);
    }
    // if the car is close to the final target of the path
    if (desired.mag()<30 && pathIndex == 2) { 
      // generate new destination, send the real end as a starting point 
      getDestination(carPath.points.get(3));
      // reset the path index to 1
      pathIndex = 1;
    }

    // Predict location 20  frames ahead
    PVector predict = velocity.get();
    predict.normalize();
    predict.mult(20);
    PVector predictLoc = PVector.add(position, predict);
    // Look at the line segment
    PVector a = carPath.points.get(pathIndex-1);
    PVector b = carPath.points.get(pathIndex);

    // Get the normal point to that line
    PVector normalPoint = getNormalPoint(predictLoc, a, b);


    // Find target point a little further ahead of normal
    PVector dir = PVector.sub(b, a);
    dir.normalize();
    dir.mult(10);  // This could be based on velocity instead of just an arbitrary 10 pixels
    PVector target = PVector.add(normalPoint, dir);

    // How far away are we from the path?
    float distance = PVector.dist(predictLoc, normalPoint);

    // seek that target
    seek(target);
  }



  // A function to get the normal point from a point (p) to a line segment (a-b)
  // This function could be optimized to make fewer new Vector objects
  PVector getNormalPoint(PVector p, PVector a, PVector b) {
    // Vector from a to p
    PVector ap = PVector.sub(p, a);
    // Vector from a to b
    PVector ab = PVector.sub(b, a);
    ab.normalize(); // Normalize the line
    // Project vector "diff" onto line by using the dot product
    ab.mult(ap.dot(ab));
    PVector normalPoint = PVector.add(a, ab);
    return normalPoint;
  }

  // used for the path following code
  void seek(PVector target) {
    PVector desired = PVector.sub(target, position);  // A vector pointing from the position to the target
    // If the magnitude of desired equals 0, skip out of here
    if (desired.mag() == 0) return;

    // Normalize desired and scale to maximum speed
    desired.normalize();
    desired.mult(speedLimit);
    // Steering = Desired minus Velocity
    PVector steer = PVector.sub(desired, velocity);
    steer.limit(steerLimit);  // Limit to maximum steering force
    applyForce(steer);
  }


  // ----------------------------------------------------------------------
  //  Interaction with other cars
  // ----------------------------------------------------------------------
  // Separation
  // Method checks for nearby vehicles and steers away
  PVector separate (ArrayList<Car> cars) {
    // angle to check for other cars
    float safeAngle = PI/6;
    PVector sForce = new PVector(0, 0);


    // For every car in the system, check if it's too close
    for (Car other : cars) {
      // get the distance between the two cars
      float distance = PVector.dist(position, other.position);
      // If the distance is greater than the safe zone
      if (carID != other.carID && (distance < safeZone)) {
        // Calculate vector pointing away from neighbor
        PVector diff = PVector.sub(position, other.position);

        // get the main angle
        float mainCarAngle = velocity.heading()+PI;
        float otherCarAngle = diff.heading();
        float multiplier;
        // convert car angle 
        mainCarAngle = map(mainCarAngle, -PI, PI, 0, TWO_PI);
        otherCarAngle = map(otherCarAngle, -PI, PI, 0, TWO_PI);

        diff.normalize();
        diff.div(8);

        // check if the other car is in front of this car
        if (otherCarAngle < mainCarAngle+safeAngle &&  otherCarAngle > mainCarAngle-safeAngle) {
          multiplier = 100/distance;
          constrain(multiplier, 0, 15);
          diff.mult(multiplier);

          // graphical debuging
          if (debug) {
            fill(100, 30);
            noStroke();
            arc(position.x, position.y, safeZone*2, safeZone*2, mainCarAngle-safeAngle, mainCarAngle+safeAngle, PIE);
          }
        }
        sForce = diff.get();
        // if the seperate force is bigger than the velocity, meaning the car will u-turn
        if (sForce.mag() > velocity.mag()) {
          sForce = velocity.get();
          // set the seperate force to - velocity
          sForce.mult(-1);
        }
      }
    }
    // return  the seperate force
    return sForce;
  }


  // ----------------------------------------------------------------------
  //  Interaction with Pedestrian
  // ----------------------------------------------------------------------
  // Separation
  // Method checks for nearby vehicles and steers away
  boolean findTargetCarfromPedestrian(Pedestrian p) {
    safeZone = 10;
    float safeAngle = PI/6;
    PVector sForce = new PVector(0, 0);
    float distance = PVector.dist(position, p.location);

    if (distance < safeZone) {

      p.setPickedUp(true, velocity);
      velocity.mult(0);
      return true;
    }
    return false;
  }

  // seperate from pedestrian methode
  PVector separateFromPedestrian (Pedestrian pedestrian) {
    PVector sForce = new PVector(0, 0);
    PVector diff = PVector.sub(position, pedestrian.location);

    if (pedestrian.location == position) {
    }
    return sForce;
  }





  //---------------------------------------------------------------
  // method to create random origine and destinations for the accident, will be overiden
  //---------------------------------------------------------------

  void applyAccidentBehaviors(PVector Accident) {
  } 


  //---------------------------------------------------------------
  // method to create random origine and destinations for the cars, will be overiden
  //---------------------------------------------------------------

  abstract PVector getDestination( PVector lastDestination); 

  void getDestination( PVector lastDestination, PVector finalDestination) {
  }

  //----------------------------------------------------------------------
  // method to set car speed limit - so it can be accessed from the Car System then the Gui - 
  //----------------------------------------------------------------------

  void setCarSpeedLimit(float incomingCarSpeedLimit)
  {
    speedLimit = incomingCarSpeedLimit;
  }

  //----------------------------------------------------------------------
  // method to set car steering limit - so it can be accessed from the Car System then the Gui
  //----------------------------------------------------------------------

  void setCarSteerLimit(float incomingCarSteerLimit)
  {
    steerLimit = incomingCarSteerLimit;
  }
}

