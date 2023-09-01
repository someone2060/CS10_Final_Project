/***
These are all function that are used for common use, for multiple different functions. Functions included are:
  - lineIntersects (checks if two line segments collide)
  - boxIntersects (checks if two inputted rects collide)
  - BoundBox (creates a boundary rectangle, and can be used to check for collisions)
*/

/** Used to find if an inputted line segment intersects with another inputted line segment. */
boolean lineIntersects (float line0x1, float line0y1, float line0x2, float line0y2, float line1x1, float line1y1, float line1x2, float line1y2) {
  /* 'm' variables store the slope of each line. 
     x and y stores the x position and y postion of the intersection, respectively.
     The rest of the variables will store the positions of lines. */
  float m0, m1, x, y, l0x1, l0x2, l0y1, l0y2, l1x1, l1x2, l1y1, l1y2;
  
  /* Finds slope for both lines */
  if (line0x1 == line0x2) // If dividing by zero will happen, a very big number is used instead 
    m0 = 1000000000;
  else // Uses slope formula otherwise
    m0 = (line0y1 - line0y2) / (line0x1 - line0x2);
  
  if (line1x1 == line1x2) // If dividing by zero will happen, a very big number is used instead 
    m1 = 1000000000;
  else // Uses slope formula otherwise
    m1 = (line1y1 - line1y2) / (line1x1 - line1x2);
  
  /* line0 and line1 make 2 line equations (point-slope form), which can be solved using systems of equations. In this case, x is isolated. */
  if (m0 != m1) 
    x = (m0*line0x1 - m1*line1x1 - line0y1 + line1y1) / (m0 - m1);
  // If the slopes are the same, the lines will only intersect if they are the same line. This is done through elimination with point-slope form, but x, y, and m is assumed to be equal in both equations.
  else if ( (line0y1 - line1y1) == (m0*line0x1 - m0*line1x1) ) 
    return true; 
  else return false; // Otherwise, the lines are parallel and they will never intersect
  
  /* If either line has a slope of infinity, the y values of the both lines must be compared instead of the x values. */
  if (m0 == 1000000000 || m1 == 1000000000) { // Comparing y values
    // line0 and line1 make 2 line equations in point-slope form, which can be solved using systems of equations. In this case, y is isolated.
    y = (m0*m1*(line1x1 - line0x1) + m1*line0y1 - m0*line1y1) / (m1 - m0);
    // '10y1' and 'l0y2' are the same as line0y1 and line0y2, but '10y1' <= 'l0y2.
    if (line0y1 <= line0y2) {
      l0y1 = line0y1;
      l0y2 = line0y2;
    } else {
      l0y1 = line0y2;
      l0y2 = line0y1;
    }
    // 'l1y1' and 'l1y2' are the same as line1y1 and line1y2, but 'l1y1' <= 'l1y2'.
    if (line1y1 <= line1y2) {
      l1y1 = line1y1;
      l1y2 = line1y2;
    } else {
      l1y1 = line1y2;
      l1y2 = line1y1;
    }
    // If y is in the bounds of both line segments
    if (l0y1 <= y && y <= l0y2 &&
        l1y1 <= y && y <= l1y2)
      return true;
    // If y isn't in the bounds of both line segments, the lines don't intersect
    else return false;
    
  } else { // Comparing x values
    
    // 'l0x1' and 'l0x2' are the same as line0x1 and line0x2, but 'l0x1' <= 'l0x2'.
    if (line0x1 <= line0x2) {
      l0x1 = line0x1;
      l0x2 = line0x2;
    } else {
      l0x1 = line0x2;
      l0x2 = line0x1;
    }
    // 'l1x1' and 'l1x2' are the same as line1x1 and line1x2, but 'l1x1' <= 'l1x2'.
    if (line1x1 <= line1x2) {
      l1x1 = line1x1;
      l1x2 = line1x2;
    } else {
      l1x1 = line1x2;
      l1x2 = line1x1;
    }
    // If x is in the bounds of both line segments
    if (l0x1 <= x && x <= l0x2 &&
        l1x1 <= x && x <= l1x2) 
      return true;
    // If x isn't in the bound of both line segments, the lines don't intersect
    else return false;
  }
}

/** Checks if the inputted boxes intersect with each other. Uses rectMode(CORNERS). */
boolean boxIntersects(float box0x1, float box0y1, float box0x2, float box0y2, float box1x1, float box1y1, float box1x2, float box1y2) {
  // Checks if any of box0's corners are in box1
  if(box1x1 <= box0x1 && box0x1 <= box1x2 && // If box0's top left corner is in box1
     box1y1 <= box0y1 && box0y1 <= box1y2) return true; 
  if(box1x1 <= box0x2 && box0x2 <= box1x2 && // If box0's top right corner is in box1
     box1y1 <= box0y1 && box0y1 <= box1y2) return true;
  if(box1x1 <= box0x2 && box0x2 <= box1x2 && // If box0's bottom right corner is in box1
     box1y1 <= box0y2 && box0y2 <= box1y2) return true;
  if(box1x1 <= box0x1 && box0x1 <= box1x2 && // If box0's bottom left corner is in box1
     box1y1 <= box0y2 && box0y2 <= box1y2) return true;
  // Checks if any of box1's corners are in box0
  if(box0x1 <= box1x1 && box1x1 <= box0x2 && // If box1's top left corner is in box0
     box0y1 <= box1y1 && box1y1 <= box0y2) return true;
  if(box0x1 <= box1x2 && box1x2 <= box0x2 && // If box1's top right corner is in box0
     box0y1 <= box1y1 && box1y1 <= box0y2) return true;
  if(box0x1 <= box1x2 && box1x2 <= box0x2 && // If box1's bottom right corner is in box0
     box0y1 <= box1y2 && box1y2 <= box0y2) return true;
  if(box0x1 <= box1x1 && box1x1 <= box0x2 && // If box1's bottom left corner is in box0
     box0y1 <= box1y2 && box1y2 <= box0y2) return true;
  // If none of the checks work, the boundaries aren't touching
  return false;
}

/** Sets the boundary box of the selected item to the wanted x and y position, with a specified height and length. Set with a mode of CENTER. */
class BoundBox {
  /* Float variables with no prefix determine the current location of the boundary box. 
     Float variables with a 'p' prefix is the boundary box's previous location. This is because a boundary won't contact every possible pixel in the direction it is moving.
       Set to -100, so that .inBounds() will know if one of the boundaries haven't been set yet, for optimization.
     If inWindow == true, .newBound() will keep the full boundary box inside the screen. */
  float x1, x2, y1, y2, px1, px2, py1, py2 = -100;
  boolean inWindow;
  
  BoundBox(boolean inWindow) {
    this.inWindow = inWindow;
  }
  
  /* Setting new boundaries for the bullet by converting rectMode(CENTER) to rectMode(CORNERS) */
  void newBound(float xPos, float yPos, float len, float ht) {
    // Saving the 'current' boundaries as the previous boundaries
    px1 = x1;
    py1 = y1;
    px2 = x2;
    py2 = y2;
    // Setting new boundaries
    x1 = xPos - len/2;
    y1 = yPos - ht/2;
    x2 = xPos + len/2;
    y2 = yPos + ht/2;
    // Ensuring everything is in the window if wanted (see inWindow var)
    if(inWindow) {
      x1 = constrain(x1, 0, width - len);
      y1 = constrain(y1, 0, height - ht);
      x2 = constrain(x2, 0 + len, width);
      y2 = constrain(y2, 0 + ht, height);
    }
  }
  
  /* Sets all boundary variables to -100, effectively removing the boundaries. */
  void removeBound() {
    x1 = -100;
    y1 = -100;
    x2 = -100;
    y2 = -100;
    px1 = -100;
    py1 = -100;
    px2 = -100;
    py2 = -100;
  }
  
  /** This inBounds function is only used if the other bounds that's wanted to be checked is a point. An example is the mouse. */
  boolean inBounds(float x, float y) {
    return boxIntersects(x1, y1, x2, y2,
                         x, y, x, y);
  }
  
  /** Checks if this boundary box is in box2's boundary. Also includes the previous location of each boundary box. 
      'this' method is used for clarity. */
  boolean inBounds(BoundBox box2) {
    // Will store the large boundary of each box. Stored as {x1, y1, x2, y2} to be used in comparisons
    FloatList thisGenBound = new FloatList(), box2GenBound = new FloatList();
    
    // When the boundaries for both boxes haven't been set yet
    if (this.x1 == -100 || box2.x1 == -100) return false;
    
    // Setting the general boundaries of each box
    if (this.px1 == -100) { // If the previous boundaries of a boundBox haven't been set yet, the current boundaries will be the default
      thisGenBound.append(this.x1);
      thisGenBound.append(this.y1);
      thisGenBound.append(this.x2);
      thisGenBound.append(this.y2);
    } else {
      if (this.x1 <= this.px1) thisGenBound.append(this.x1); // Adding the leftmost x variable
      else thisGenBound.append(this.px1); 
      if (this.y1 <= this.py1) thisGenBound.append(this.y1); // Adding the topmost y variable
      else thisGenBound.append(this.py1);
      if (this.x2 >= this.px2) thisGenBound.append(this.x2); // Adding the rightmost x variable
      else thisGenBound.append(this.px2);
      if (this.y2 >= this.py2) thisGenBound.append(this.y2); // Adding the bottommost y variable
      else thisGenBound.append(this.py2);
    }
    
    if (this.px1 == -100) { // If the previous boundaries of a boundBox haven't been set yet, the current boundaries will be the default
      box2GenBound.append(box2.x1);
      box2GenBound.append(box2.y1);
      box2GenBound.append(box2.x2);
      box2GenBound.append(box2.y2);
    } else {
      if (box2.x1 <= box2.px1) box2GenBound.append(box2.x1); // Adding the leftmost x variable
      else box2GenBound.append(box2.px1);
      if (box2.y1 <= box2.py1) box2GenBound.append(box2.y1); // Adding the topmost y variable
      else box2GenBound.append(box2.py1);
      if (box2.x2 >= box2.px2) box2GenBound.append(box2.x2); // Adding the rightmost x variable
      else box2GenBound.append(box2.px2);
      if (box2.y2 >= box2.py2) box2GenBound.append(box2.y2); // Adding the bottommost y variable
      else box2GenBound.append(box2.py2);
    }
    
    /* If the general boundaries of each hitbox aren't inside each other 
         (previous hitbox AND current hitbox for both hitboxes, made into a sqaure) 
         there is no way for the hitboxes to collide */
    if (!boxIntersects(thisGenBound.get(0), thisGenBound.get(1), thisGenBound.get(2), thisGenBound.get(3),  // If the general boundaries don't intersect
                       box2GenBound.get(0), box2GenBound.get(1), box2GenBound.get(2), box2GenBound.get(3)) ) 
      return false;
    
    // If current hitboxes collide with each other
    if (boxIntersects(this.x1, this.y1, this.x2, this.y2, 
                      box2.x1, box2.y1, box2.x2, box2.y2)) 
      return true;    
    
    // If box2 doesn't have previous hitboxes, there is no need to compare anything that involves box2's previous bounds
    if (box2.px1 != -100) {
      // If this hitbox's current bounds and box2's previous hitbox collide
      if (boxIntersects(this.x1, this.y1, this.x2, this.y2, 
                        box2.px1, box2.py1, box2.px2, box2.py2)) 
        return true;
    }
    
    // If this hitbox doesn't have previous hitboxes, there is no need to compare anything that involves this hitbox's previous bounds
    if (this.px1 != -100) {
      // If this hitbox's previous bounds and box2's current hitbox collide
      if (boxIntersects(this.px1, this.py1, this.px2, this.py2,
                        box2.x1, box2.y1, box2.x2, box2.y2))
        return true;
    }
    
    /* Assume that you have a previous hitbox, and a current hitbox.
       The corners can be described as the type of hitbox (current/previous), and where the corner is (top/bottom left/right).
       A corner line is a line that can be drawn when you draw a line from a previous hitbox corner to the same current hitbox corner. 
         (For example, a line from the previous top right hitbox, to the current top right hitbox.)
       These are the lines referred to in the below code. */
    
    /* Runs when both boundaries have previous hitboxes */
    if (this.px1 != -100 && box2.px1 != -100 && 
       !(this.x1 == this.px1 && this.x2 == this.px2 &&
         this.y1 == this.py1 && this.y2 == this.py2) &&
       !(box2.x1 == box2.px1 && box2.x2 == box2.px2 &&
         box2.y1 == box2.py1 && box2.y2 == box2.py2)) {
      // Comparing top left corner line with all other lines from box2
      if (lineIntersects(this.px1, this.py1, this.x1, this.y1,
                         box2.px2, box2.py1, box2.x2, box2.y1))
        return true;
      if (lineIntersects(this.px1, this.py1, this.x1, this.y1,
                         box2.px2, box2.py2, box2.x2, box2.y2))
        return true;
      if (lineIntersects(this.px1, this.py1, this.x1, this.y1,
                         box2.px1, box2.py2, box2.x1, box2.y2))
        return true;
      
      // Comparing top right corner line with all other lines from box2
      if (lineIntersects(this.px2, this.py1, this.x2, this.y1,
                         box2.px1, box2.py1, box2.x1, box2.y1))
        return true;
      if (lineIntersects(this.px2, this.py1, this.x2, this.y1,
                         box2.px2, box2.py2, box2.x2, box2.y2))
        return true;
      if (lineIntersects(this.px2, this.py1, this.x2, this.y1,
                         box2.px1, box2.py2, box2.x1, box2.y2))
        return true;
        
      // Comparing bottom right corner line with all other lines from box2
      if (lineIntersects(this.px2, this.py2, this.x2, this.y2,
                         box2.px1, box2.py1, box2.x1, box2.y1))
        return true;
      if (lineIntersects(this.px2, this.py2, this.x2, this.y2,
                         box2.px2, box2.py1, box2.x2, box2.y1))
        return true;
      if (lineIntersects(this.px2, this.py2, this.x2, this.y2,
                         box2.px1, box2.py2, box2.x1, box2.y2))
        return true;
      
      // Comparing bottom left corner line with all other lines from box2
      if (lineIntersects(this.px1, this.py2, this.x1, this.y2,
                         box2.px1, box2.py1, box2.x1, box2.y1))
        return true;
      if (lineIntersects(this.px1, this.py2, this.x1, this.y2,
                         box2.px2, box2.py1, box2.x2, box2.y1))
        return true;
      if (lineIntersects(this.px1, this.py2, this.x1, this.y2,
                         box2.px2, box2.py2, box2.x2, box2.y2))
        return true;
    }
    /* Runs when this hitbox has previous boundaries, but box2 doesn't. 
       Turns box2's current hitbox into four lines, instead of a square. 
       From there, lineIntersects() is used to find if box2's current hitbox hits. */
    else if (this.px1 != -100 && box2.px1 == -100 &&
             !(this.x1 == this.px1 && this.x2 == this.px2 &&
               this.y1 == this.py1 && this.y2 == this.py2)) {
      // Comparing top line of box2 with other lines from this hitbox
      if (lineIntersects(box2.x1, box2.y1, box2.x2, box2.y1,
                         this.x2, this.y2, this.px2, this.py2))
        return true;
      if (lineIntersects(box2.x1, box2.y1, box2.x2, box2.y1,
                         this.x1, this.y2, this.px1, this.py2))
        return true;
      // Comparing right line of box2 with other lines from this hitbox
      if (lineIntersects(box2.x2, box2.y1, box2.x2, box2.y2,
                         this.x1, this.y1, this.px1, this.py1))
        return true;
      if (lineIntersects(box2.x2, box2.y1, box2.x2, box2.y2,
                         this.x2, this.y1, this.px2, this.py1))
        return true;
      // Comparing bottom line of box2 with other lines from this hitbox
      if (lineIntersects(box2.x2, box2.y2, box2.x1, box2.y2,
                         this.x2, this.y2, this.px2, this.py2))
        return true;
      if (lineIntersects(box2.x2, box2.y2, box2.x1, box2.y2,
                         this.x1, this.y2, this.px1, this.py2))
        return true;
      // Comparing left line of box2 with other lines from this hitbox
      if (lineIntersects(box2.x1, box2.y2, box2.x1, box2.y1,
                         this.x1, this.y1, this.px1, this.py1))
        return true;
      if (lineIntersects(box2.x1, box2.y2, box2.x1, box2.y1,
                         this.x2, this.y1, this.px2, this.py1))
        return true;
    }
    
    /* Runs when box2 has previous hitboxes, but this hitbox doesn't.
       Process is the same, but this hitbox is turned into four lines instead of box2. */
    else if (this.px1 == -100 && box2.px1 != -100 &&
             !(box2.x1 == box2.px1 && box2.x2 == box2.px2 &&
               box2.y1 == box2.py1 && box2.y2 == box2.py2)) {
      // Comparing top line of this hitbox with other lines from box2's hitbox
      if (lineIntersects(this.x1, this.y1, this.x2, this.y1,
                         box2.x2, box2.y2, box2.px2, box2.py2))
        return true;
      if (lineIntersects(this.x1, this.y1, this.x2, this.y1,
                         box2.x1, box2.y2, box2.px1, box2.py2))
        return true;
      // Comparing right line of this hitbox with other lines from box2's hitbox
      if (lineIntersects(this.x2, this.y1, this.x2, this.y2,
                         box2.x1, box2.y1, box2.px1, box2.py1))
        return true;
      if (lineIntersects(this.x2, this.y1, this.x2, this.y2,
                         box2.x2, box2.y1, box2.px2, box2.py1))
        return true;
      // Comparing bottom line of this hitbox with other lines from box2's hitbox
      if (lineIntersects(this.x2, this.y2, this.x1, this.y2,
                         box2.x2, box2.y2, box2.px2, box2.py2))
        return true;
      if (lineIntersects(this.x2, this.y2, this.x1, this.y2,
                         box2.x1, box2.y2, box2.px1, box2.py2))
        return true;
      // Comparing left line of this hitbox with other lines from box2's hitbox
      if (lineIntersects(this.x1, this.y2, this.x1, this.y1,
                         box2.x1, box2.y1, box2.px1, box2.py1))
        return true;
      if (lineIntersects(this.x1, this.y2, this.x1, this.y1,
                         box2.x2, box2.y1, box2.px2, box2.py1))
        return true;
    }
    
    return false; // If no conditions are filled, the boxes don't collide
  }
}
