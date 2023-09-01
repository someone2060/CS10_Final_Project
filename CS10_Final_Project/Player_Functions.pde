/***
Functions that manage everything related to the player. Functions include:
  - PlayerBullet (manages one bullet shot from the player)
  - PlayerBullets (manages all bullets that the player will shoot, removing ones that go off screen)
  - PlayerBomb (manages one bomb that explodes on impact, causing AOE)
  - PlayerBombs (manages all bombs that the player will shoot, removing ones that go off screen
  - Player (manages the player ship, and everything related to it, with action (moving, shooting) speed based on the many inputted variables)
*/

/* Manages one player bullet */
class PlayerBullet {
  // Position of bullet
  float x, y;
  // Boundary box of the bullet
  BoundBox bounds = new BoundBox(false);
  
  PlayerBullet(float x, float y) {
    // Setting variables
    this.x = x;
    this.y = y;
    bounds.newBound(x, y, 4, 16);
  }
  
  void update() {
    // Displaying bullet
    noStroke();
    fill(255);
    rect(bounds.x1, bounds.y1, bounds.x2, bounds.y2); 
    // Moves the bullet up by bulletVelocity, to mimic movement
    y -= player.bulletVelocity/goalFrames;
    bounds.newBound(x, y, 4, 16);
  }
}

/* Manages multiple player bullets */
class PlayerBullets {
  ArrayList<PlayerBullet> bullets = new ArrayList<PlayerBullet>();
  
  /* Adds a new bullet to the specified coordinates*/
  void newBullet(float x, float y) {
    bullets.add(new PlayerBullet(x, y)); 
  }
  
  /* Updates all the bullets under the bullets list */
  void update() {
    PlayerBullet crntBullet;
    for (int i = 0; i < bullets.size(); i++) {
      crntBullet = bullets.get(i);
      if(crntBullet.bounds.y2 < 0) // If the current bullet is offscreen, the bullet gets deleted
        bullets.remove(i);
      crntBullet.update();
    }
  }
}

/** Manages one player bomb */
class PlayerBomb {
  // Position of bomb
  float x, y;
  // How long bomb explodes for
  int explodeFrames;
  // Boundary box of bomb
  BoundBox bounds = new BoundBox(false);
  // Tracks what stage the bomb is currently on. 0 is traveling, 1 is exploding, and 2 is displaying after without hitbox
  int stage = 0;
  // Tracks when the frame started
  int startFrame;
  
  PlayerBomb (float x, float y, int explodeFrames) {
    this.x = x;
    this.y = y;
    this.explodeFrames = explodeFrames;
  }
  
  /* Changes the bomb, depending on what stage it's on */
  void update() {
    if (stage == 0) {
      // Moves the bomb up by bombVelocity, to mimic movement
      y -= player.bombVelocity/goalFrames;
      bounds.newBound(x, y, 12, 12);
      // Displaying bomb
      noStroke();
      fill(#00FFFF);
      rect(bounds.x1, bounds.y1, bounds.x2, bounds.y2); 
      startFrame = frameCount;
    } else if (stage == 1) {
      bounds.newBound(x, y, player.explodeSize, player.explodeSize);
      // Displaying bomb
      noStroke();
      fill(#00FFFF);
      rect(bounds.x1, bounds.y1, bounds.x2, bounds.y2);
      fill(#0000FF);
      rect(bounds.px1, bounds.py1, bounds.px2, bounds.py2);
      // Displays the bomb for one frame, so that enemies can have one frame to recieve the bomb's status
      if (1 < frameCount - startFrame) {
        stage++;
        startFrame = frameCount;
      }
    } else if (stage >= 2) {
      bounds.newBound(x, y, player.explodeSize, player.explodeSize);
      // Displaying
      noStroke();
      fill(#00FFFF);
      rect(bounds.x1, bounds.y1, bounds.x2, bounds.y2);
      if (explodeFrames <= frameCount - startFrame)
        stage = -1;
    }
  }
}

/** Manages multiple player bombs */
class PlayerBombs {
  ArrayList<PlayerBomb> bombs = new ArrayList<PlayerBomb>();
  
  void newBomb(float x, float y, int explodeFrames) {
    bombs.add(new PlayerBomb(x, y, explodeFrames));
  }
  
  void update() {
    PlayerBomb crntBomb;
    for (int i = 0; i < bombs.size(); i++) {
      crntBomb = bombs.get(i);
      if (crntBomb.stage < 0 || crntBomb.y < 0) // If the bomb has passed all of its stages or has exited the screen, the item becomes removed
        bombs.remove(i);
      else
        crntBomb.update();
    }
  }
}

/** Manages everything related to the player's ship */
class Player {
  // How many pixels the ship can travel in one second
  float speed;
  // Position and diameters of the ship
  float x, y, len, ht;
  // Manages health of ship
  float maxhp, hp;
  // Manages the position of the player's hurtbox
  BoundBox bounds = new BoundBox(true);
  // Manages the player's bullets
  PlayerBullets bullets = new PlayerBullets();
  // Player's bullet pixels/sec, and rate of fire/sec.
  float bulletVelocity, bulletsPSec;
  // Sees the most recent time that a bullet has been shot
  int frameBulletShot = 0;
  PlayerBombs bombs = new PlayerBombs();
  // Player's bomb damage, shooting time, size of explosion, frames to charge a bomb, and frames that a bomb lasts for.
  float bombDmg, bombVelocity, explodeSize;
  int chargeFrames, explodeFrames;
  
  // debug variable
  int counter = 0;
  
  /* Initialization */
  Player(float x, float y, float len, float ht, float hp, float speed, 
         float bulletVelocity, int bulletsPSec, 
         float bombDmg, float bombVelocity, int chargeFrames, int explodeFrames, float explodeSize) {
    this.x = x;
    this.y = y;
    this.len = len;
    this.ht = ht;
    this.maxhp = hp;
    this.hp = hp;
    this.speed = speed;
    this.bulletVelocity = bulletVelocity;
    this.bulletsPSec = bulletsPSec;
    this.bombDmg = bombDmg;
    this.bombVelocity = bombVelocity;
    this.chargeFrames = chargeFrames;
    this.explodeFrames = explodeFrames;
    this.explodeSize = explodeSize;
    this.bounds.newBound(x, y, len, ht);
  }
  
  /* Recieves three PImages, and displays an image based on frameCount on the inputted coordinates.
     At these settings, the animation is displayed at 12 FPS.
     UNUSED RIGHT NOW */
  void displayImage(PImage img1, PImage img2, PImage img3, float x1, float y1, float x2, float y2) {
    if ((frameCount / (goalFrames/12)) % 3 == 0) image(img1, x1, y1, x2, y2);
    else if ((frameCount / (goalFrames/12)) % 3 == 1) image(img2, x1, y1, x2, y2);
    else if ((frameCount / (goalFrames/12)) % 3 == 2) image(img3, x1, y1, x2, y2);
    else println("Error in .displayImage()");
  }
  
  /* Updates the player's position and shooting state, then checks the status of the ship and draws accordingly. */
  void update() {
    if (hp > 0) {
      // If any movement key has been pressed
      if(keyW || keyA || keyS || keyD || keyUP || keyLEFT || keyDOWN || keyRIGHT) { 
        bounds.newBound(x - ((speed/goalFrames)*int(keyA || keyLEFT)) // Moves the ship left by speed if 'a' or left arrow has been pressed
                          + ((speed/goalFrames)*int(keyD || keyRIGHT)), // Moves the ship right by speed if 'd' or right arrow has been pressed
                                 
                        y - ((speed/goalFrames)*int(keyW || keyUP)) // Moves the ship left by speed if 'w' or up arrow has been pressed
                          + ((speed/goalFrames)*int(keyS || keyDOWN)), // Moves the ship left by speed if 's' or down arrow has been pressed
                        len, ht);
        // Setting ship's location based on bounds
        x = bounds.x1 + (len/2);
        y = bounds.y1 + (ht/2);
      } else { // Sets the bounds to the same dimensions otherwise
        bounds.newBound(x, y, len, ht);
      }
      // When left mouse button has been pressed, and when a timing window is met (to prevent too many bullets a second)
      if (mouseLEFT &&
          frameCount - frameBulletShot >= goalFrames/bulletsPSec) { // Creates a new bullet if the criteria are met 
        frameBulletShot = frameCount;
        bullets.newBullet(x, y);
      } else if (mouseRIGHT &&
                 frameCount - frameBulletShot >= chargeFrames) { // Creates a new bomb if the criteria are met
        frameBulletShot = frameCount;
        bombs.newBomb(x, y, explodeFrames);
      }
      
      // Displays the player's health at the bottom right as a percentage (int)
      textFont(bold);
      textAlign(LEFT, BOTTOM);
      textSize(24);
      fill(255, 255 * (hp/maxhp), 255 * (hp/maxhp) );
      if (!devmode) text("Ship Integrity: " + round(hp/maxhp * 100) + "%", 0, height);
      else text("Ship Integrity: indestructible", 0, height);
      
      // Updates all bullets and bombs from the player
      bullets.update();
      bombs.update();
      
      // Displaying ship
      noStroke();
      fill(255);
      rect(bounds.x1, bounds.y1, bounds.x2, bounds.y2);
      
      // Displaying bar below ship that displays how much charging is needed to fire the next bomb
      fill(#00FFFF);
      if (frameCount - frameBulletShot < goalFrames/bulletsPSec) {} // If frameCount is in the range of a bullet being shot
      else if (frameCount - frameBulletShot < chargeFrames) { // When the ship hasn't finished charging yet
        rect(bounds.x1, bounds.y2 + 5,
             (bounds.x2 - bounds.x1) * ((frameCount-frameBulletShot) / float(chargeFrames)) + bounds.x1, bounds.y2 + 15);
      } else { // When the ship has finished charging
        rect(bounds.x1, bounds.y2 + 5,
             bounds.x2, bounds.y2 + 15);
      }
    } else { // If the player has died
      main.back.newBound(width/2, height*15/20, main.wid, main.ht);
      main.stage = "dead";
      reset();
    }
  }
}
