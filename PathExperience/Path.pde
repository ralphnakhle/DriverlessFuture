// Path Following
// Daniel Shiffman <http://www.shiffman.net>
// The Nature of Code

class Path {

  // A Path is an arraylist of points (PVector objects)
  ArrayList<PVector> points;
  // A path has a radius, i.e how far is it ok for the boid to wander off
  float radius;

  Path() {
    // Arbitrary radius of 20
    radius = 5;
    points = new ArrayList<PVector>();
  }

  // Add a point to the path
  void addPoint(float x, float y) {
    PVector point = new PVector(x, y);
    points.add(point);
  }

  // Draw the path
  void display() {
    // Draw thick line for radius
    stroke(175);
    strokeWeight(radius*2);
    noFill();

    for (int v = 0; v < points.size()-1; v++ ) {
      line(points.get(v).x, points.get(v).y, points.get(v+1).x, points.get(v+1).y);
    }

    // Draw thin line for center of path
    stroke(0);
    strokeWeight(1);
    noFill();
    for (int v = 0; v < points.size()-1; v++ ) {
      line(points.get(v).x, points.get(v).y, points.get(v+1).x, points.get(v+1).y);
    }

  }
}


