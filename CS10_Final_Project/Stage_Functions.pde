/***
Functions that manage the UI of the game. Variables include:
  - Main (displays & manages all main menu related screens)
  - Level (uses a timer based/enemy based system, to determine when new enemies spawn in a level)
  - Levels (manages all levels in the game, adding transition screens in between)
  - Shake (shakes the whole screen using translate(), after .shake() is ran)
  - Star (one star that is managed by Stars to create a feel of movement)
  - Stars (manages multiple Star functions, to create a feel of movement)
*/

/** Displays the main menu of the game. */
class Main {
  // Buttons that will be clickable
  BoundBox start = new BoundBox(false), howtoplay = new BoundBox(false), about = new BoundBox(false), back = new BoundBox(false);
  float wid = 150, ht = 45;
  // Image that will serve as the title
  PImage titleImage;
  // Manages what screen the main menu is on
  String stage = "main";
  
  Main() {
    start.newBound(width/2, height*7/20, wid, ht);
    howtoplay.newBound(width/2, height*10/20, wid, ht);
    about.newBound(width/2, height*13/20, wid, ht);
  }
  
  // Displays the menu
  void update() {
    if (stage.toLowerCase() != "start") { // If the player has already started playing, nothing happens
      if (stage.toLowerCase() == "main") { // Main menu
        // Title image (temp text for now)
        noStroke();
        textAlign(CENTER, CENTER);
        fill(255);
        textFont(head);
        text(title, width/2, height*3/20);
        
        // Clickable buttons
        stroke(200);
        strokeWeight(5);
        rect(start.x1, start.y1, start.x2, start.y2);
        rect(howtoplay.x1, howtoplay.y1, howtoplay.x2, howtoplay.y2);
        rect(about.x1, about.y1, about.x2, about.y2);
        
        // Text inside buttons
        fill(50);
        textFont(bold);
        textSize(36);
        text("START", start.x1 + wid/2, start.y1 + ht/2 - ht/14);
        text("ABOUT", about.x1 + wid/2, about.y1 + ht/2 - ht/14);
        textSize(22);
        text("HOW TO PLAY", howtoplay.x1 + wid/2, howtoplay.y1 + ht/2 - ht/14);
        
      } else if (stage.toLowerCase() == "howtoplay") { // How to play screen
        // Title text
        noStroke();
        rectMode(CENTER);
        textAlign(CENTER, CENTER);
        fill(255);
        textFont(head);
        text("HOW TO PLAY", width/2, height*2/20);
        rectMode(CORNERS);
        
        // Body text
        textAlign(LEFT, TOP);
        textFont(body);
        text("Your nation has tasked you with taking a new star system from the Hariri. Even though you have been given a top of the line ship, it seems the opposing forces may be too large to handle…\n\n" +
             "  Your goal is to destroy the enemy ships, while avoiding getting hit yourself by them.\n" +
             "  Use WASD or the arrow keys to move the ship around.\n" +
             "  Hold left click to shoot fast bullets.\n" +
             "  Hold right click to fire a slow travelling, but high damage projectile. The projectile must be charged before for a while before being released.",
             25, height*4/20, width-25, height);
        
        // Back button
        stroke(200);
        strokeWeight(5);
        rect(back.x1, back.y1, back.x2, back.y2);
        
        fill(50);
        textFont(bold);
        textAlign(CENTER, CENTER);
        textSize(32);
        text("BACK", back.x1 + wid/2, back.y1 + ht/2 - ht/14);
        
      } else if (stage.toLowerCase() == "about") { // About screen
        // Title text
        noStroke();
        rectMode(CENTER);
        textAlign(CENTER, CENTER);
        fill(255);
        textFont(head);
        text("ABOUT", width/2, height*2/20);
        rectMode(CORNERS);
        
        // Body text
        textAlign(LEFT, TOP);
        textFont(body);
        text(title + " was created by Daniel L, using Processing 3.\n\n" +
             "The method for tracking key presses was found from https://discourse.processing.org/t/smooth-moving-code/7126/4.",
             25, height*4/20, width-25, height);
        
        // Back button
        stroke(200);
        strokeWeight(5);
        rect(back.x1, back.y1, back.x2, back.y2);
        
        fill(50);
        textFont(bold);
        textAlign(CENTER, CENTER);
        textSize(32);
        text("BACK", back.x1 + wid/2, back.y1 + ht/2 - ht/14);
        
      } else if (stage.toLowerCase() == "dead") { // At the end of a round (when player is dead)
        // Body text
        fill(255);
        textAlign(LEFT, TOP);
        textFont(body);
        textSize(24);
        text("You died on wave " + levels.levelcount + " :(", 25, height*4/20, width-25, height);
        
        // Back button
        stroke(200);
        strokeWeight(5);
        rect(back.x1, back.y1, back.x2, back.y2);
        
        fill(50);
        textFont(bold);
        textAlign(CENTER, CENTER);
        textSize(32);
        text(");", back.x1 + wid/2, back.y1 + ht/2 - ht/13);
        
      } else if (stage.toLowerCase() == "win") {
        // Body text
        textAlign(LEFT, TOP);
        textFont(body);
        text("You've defeated the Hariri's forces! Your nation will take it from here.\n\n" +
             "Thank you for playing!",
             25, height*4/20, width-25, height);
        
        // Back button
        stroke(200);
        strokeWeight(5);
        rect(back.x1, back.y1, back.x2, back.y2);
        
        fill(50);
        textFont(bold);
        textAlign(CENTER, CENTER);
        textSize(32);
        text("BACK", back.x1 + wid/2, back.y1 + ht/2 - ht/14);
      }
    
      if (stage != "dead") {
        // Displaying player ship (unusable, for decoration)
        noStroke();
        fill(255);
        rectMode(CENTER);
        rect(width/2, height * 9/10, player.len, player.ht);
        rectMode(CORNERS);
      }
    }
  }
  
  // Checks if the mouse has clicked one of the buttons. Ran in mouseClicked(). 
  void checkClicked() {
    if (start.inBounds(mouseX, mouseY)) {
      noCursor();
      start.removeBound();
      howtoplay.removeBound();
      about.removeBound();
      back.removeBound();
      stage = "start";
    } else if (howtoplay.inBounds(mouseX, mouseY)) {
      start.removeBound();
      howtoplay.removeBound();
      about.removeBound();
      back.newBound(width/2, height*15/20, wid, ht);
      stage = "howtoplay";
    } else if (about.inBounds(mouseX, mouseY)) {
      start.removeBound();
      howtoplay.removeBound();
      about.removeBound();
      back.newBound(width/2, height*15/20, wid, ht);
      stage = "about";
    } else if (back.inBounds(mouseX, mouseY)) {
      start.newBound(width/2, height*7/20, wid, ht);
      howtoplay.newBound(width/2, height*10/20, wid, ht);
      about.newBound(width/2, height*13/20, wid, ht);
      back.removeBound();
      stage = "main";
    }
  }
}


/** Manages when enemies spawn, and where they spawn to */
class Level {
  /* 'enemyType' determines the type of ship that's shown.
       See the .spawnEnemy() function to see what enemy types are valid.
     'enemyValues' determines the enemy's specific behaviours.
       If left blank, the ship is spawned with generic behaviour. (See .spawnEnemy() to find what ther generic behaviour is.)
     'frames' determines when a ship is shown.
       Use positive numbers to determine when the next ship will be shown from the starting of the level. (eg. 60 shows the enemy 60 frames after initialization)
       Use negative numbers to display the enemy in queue when a set number of enemies are on screen. (eg. -2 shows the enemy when 2 enemies or less are on screen) 
       Zero makes a ship appear when there are no ships on screen.
       Negative numbers in queue pauses the frameCount timer, which allows for timed releases of ships.
     Each item in enemyType corresponds to each item in frames. */
  String[] enemyType;
  ArrayList<FloatList> enemyValues;
  int[] frames;
  // How many enemies there are in total
  int enemyCount;
  // Stores what frame the level starts on, and what frame the level is currently on, respectively
  int startFrame;
  
  Level (String[] enemyType, ArrayList<FloatList> enemyValues, int[] frames) {
    this.enemyType = enemyType;
    this.enemyValues = enemyValues;
    this.frames = frames;
    startFrame = 0;
    
    enemyCount = constrain(constrain(enemyType.length, 
                                     0, frames.length), 
                           0, enemyValues.size());
  }
  
  /* Used by .update() to find what type of ship is sent.
     The function sends the ship that corresponds to enemyType[0], then deletes enemyType[0] and frames[0] to move onto the next item. */
  void spawnEnemy() {
    try {
      if (enemyType[0].toUpperCase() == "CHILD") { // Spawns a child AI
        if (enemyValues.get(0).size() == 0) { // If there are no specified values
          AImanager.newAIchild(random(0, width), random(40, height/2), boolean(int(random(0, 2))));
        } else { // If there are specified values
          AImanager.newAIchild(enemyValues.get(0).get(0), enemyValues.get(0).get(1), boolean(int(enemyValues.get(0).get(2))) );
        }
      
      } else if (enemyType[0].toUpperCase() == "BASIC") { // Spawns a basic AI
        if (enemyValues.get(0).size() == 0) { // If there are no specified values
          AImanager.newAIbasic(random(0, width), random(40, height/2), boolean(int(random(0, 2))));
        } else { // If there are specified values
          AImanager.newAIbasic(enemyValues.get(0).get(0), enemyValues.get(0).get(1), boolean(int(enemyValues.get(0).get(2))) );
        }
      
      } else if (enemyType[0].toUpperCase() == "CARRIER") { // Spawns a carrier AI
        if (enemyValues.get(0).size() == 0) {
          AImanager.newAIcarrier(random(0, width), random(40, height/4));
        } else { // If there are specified values
          AImanager.newAIcarrier(enemyValues.get(0).get(0), enemyValues.get(0).get(1));
        }
      
      } else if (enemyType[0].toUpperCase() == "RAMMER") { // Spawns a rammer AI
        if (enemyValues.get(0).size() == 0) {
          AImanager.newAIrammer(random(0, width), random(40, height/3));
        } else { // If there are specified values
          AImanager.newAIrammer(enemyValues.get(0).get(0), enemyValues.get(0).get(1));
        }
      
      } else if (enemyType[0].toUpperCase() == "CLEAR") { // Clears all enemies from AImanager, to prevent bugs
        for(int i = 0; i < 10; i++) {
          println('a');
        }
        AImanager.AIchilds = new ArrayList<AIchild>();
        AImanager.AIbasics = new ArrayList<AIbasic>();
        AImanager.AIcarriers = new ArrayList<AIcarrier>();
        AImanager.AIrammers = new ArrayList<AIrammer>();
      }
      else {} // Assumes that the position is a placeholder
      
      enemyType = subset(enemyType, 1);
      enemyValues.remove(0);
      frames = subset(frames, 1);
    // At seemingly random times, enemyCount is too large for other arrays (enemyType, enemyValues, frames). I don't want to debug it, so this code is here to remedy it.
    } catch (Throwable e) {
      e.printStackTrace();
    }
    
    enemyCount--;
  }
  
  /* Updates the level, checking when a ship should be released. */
  void update() {
    if (enemyCount > 0) { // When there still are enemies in queue
    
      if (frames[0] > 0) { // If the next enemy is timing based
        if (frames[0] < frameCount - startFrame) {
          spawnEnemy();
          startFrame = frameCount;
        }
      }
      else if (abs(frames[0]) >= AImanager.enemyNum()) { // If the next enemy is ship count based
        spawnEnemy();
      }
    }
  }
}


class Levels {
  ArrayList<Level> levels;
  int levelcount;
  int stage, frameStart;
  
  Levels() {
    levels = new ArrayList<Level>();
    levelcount = 1;
    stage = 0;
  }
  
  void addLvl(Level level) {
    levels.add(level);
  }
  
  void update() {
    if (levels.get(0).enemyCount == 0 && AImanager.enemyNum() == 0) {
      if (levels.size() == 1) { // All levels have been beaten, and the game will now show the win screen
        switch(stage) {
          case(0): // Setting frameStart
            frameStart = frameCount;
            stage++;
            break;
            
          case(1): // Delaying a bit before showing win screen
            if (frameCount - frameStart >= goalFrames*2) { // 2 sec delay
              main.back.newBound(width/2, height*15/20, main.wid, main.ht);
              main.stage = "win";
              reset();
            }
            break;
        }
      } else { // The current level has been beaten, animates a line of text before proceeding to the next level
        switch(stage) {
          case(0): // Setting frameStart
            frameStart = frameCount;
            stage++;
            break;
            
          case(1): // Delaying before displaying level win text
            if (frameCount - frameStart >= goalFrames/2) { // 1/2 sec delay
              frameStart = frameCount;
              stage++;
            }
            break;
            
          case(2): // Displaying line 1 of win text
            textAlign(CENTER, TOP);
            textFont(bold);
            textSize(24);
            fill(225);
            text("Wave " + levelcount + " complete!",
                 width/2, height*2/7);
            if (frameCount - frameStart >= goalFrames) { // 1 sec delay
              player.hp = player.maxhp;
              frameStart = frameCount;
              stage++;
            }
            break;
            
          case(3): // Displaying all level win text
            textAlign(CENTER, TOP);
            textFont(bold);
            textSize(24);
            fill(225);
            text("Wave " + levelcount + " complete!\n" + 
                 "Health restored. Prepare for more enemies!",
                 width/2, height*2/7);
            if (frameCount - frameStart >= goalFrames*5/2) { // 2.5 sec delay
              frameStart = frameCount;
              stage++;
            }
            break;
          
          case(4): // Delays a bit before proceeding to next level, and resetting all vars
            if (frameCount - frameStart >= goalFrames) { // 1 sec delay
              stage = 0;
              levelcount++;
              levels.remove(0);
            }
            break;
        }
      }
    } else {
      levels.get(0).update();
    }
  }
}


/** Shakes the screen using translate(). */
class Shake {
  float intensity;
  int frameDuration, frameStart;
  // Used to find the direction that the screen shakes in
  float randx;
  // Tints the red value, based on intensity
  float tintvalue;
  
  Shake() {
    intensity = 0;
    frameDuration = 0;
    frameStart = frameCount;
    tintvalue = 0;
  }
  
  void shake(float intensity, int frameDuration) {
    if (frameCount - frameStart > frameDuration) { // If the previous shaking animation has already happened
      this.intensity = intensity;
      this.frameDuration = frameDuration;
    } else { // Otherwise, the current animation intensity & duration is added onto the current intensity & duration
      this.intensity += intensity/2;
      this.frameDuration = frameDuration + (frameCount - frameStart);
    }
    this.frameStart = frameCount;  
  }
  
  void update() {
    tintvalue = 0;
    if (frameCount - frameStart <= frameDuration) {
      randx = random(0, intensity);
      
      /* This code can be broken into two parts for each coordinate. 
         The first section (-1*int(random(0, 2))) determines the direction of translation. It either equals 1 (negative coefficient), or 0 (positive coefficient).
         The second section (randx, OR intensity - randx) uses a variable randx. It moves the x amount by a random amount, to be replaced for by the y coordinate. */
      translate( (-1*int(random(0, 2))) * randx,
                 (-1*int(random(0, 2))) * (intensity - randx) );
      // Controls transparency of red colouring for everything
      tintvalue = (intensity*4/3) * (float(frameDuration) / (frameCount-frameStart));
    }
  }
}


/* Manages one star */
class Star {
  float x, y, speed, size;
  
  Star(float x, float y, float speed, float size) {
    this.x = x;
    this.y = y;
    this.speed = speed;
    this.size = size;
  }
  
  void update() {
    // Displaying star
    strokeWeight(size);
    stroke(255);
    point(x, y);
    // Moving the star
    y += speed/goalFrames;
  }
}

/* Creates a moving starry background */
class Stars {
  ArrayList<Star> stars = new ArrayList();
  float minspeed, maxspeed, amount, size;
  
  Stars(float minspeed, float maxspeed, float amount, float size) {
    this.minspeed = minspeed;
    this.maxspeed = maxspeed;
    this.amount = amount;
    this.size = size;
    for(int i = 0; i < amount; i++) { 
      // Creates a star that goes to a random place in the screen
      stars.add(new Star(random(0, width), random(0, height), 
                         random(minspeed, maxspeed), size));
    }
  }
  
  void update() {
    // Updates all stars
    Star crnt;
    for(int i = 0; i < stars.size(); i++) {
      crnt = stars.get(i);
      if (crnt.y > height) {
        crnt.x = random(0, width);
        crnt.y = 0;
      }
      crnt.update();
    }
  }
}
