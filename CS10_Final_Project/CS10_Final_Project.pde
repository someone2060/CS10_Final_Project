/** 
i used so much time on this program (2,140 lines oh god)
this final project contains 5 levels (waves), with 4 different types of enemies. the enemies have different behaviour from each other. (see Enemy_Functions tab for more info)
TODO
  - Laser enemy
  - Upgrades
  - Managing sprite images
  - Blocking/reflecting enemy
  - Intelligent enemy? (similar to player controls, and moves/attacks in an intelligent manner)
  - Boss
toggle devmode by pressing g, and go to the next level by pressing n 
**/

/** GLOBAL VARIABLES **/
boolean devmode;
// booleans that track when a key/mouseButton has been pressed or released. Method taken from https://discourse.processing.org/t/smooth-moving-code/7126/4.
boolean keyW, keyA, keyS, keyD, keyUP, keyLEFT, keyDOWN, keyRIGHT, mouseLEFT, mouseRIGHT;

// Display related
String title = "A Space Frontier";
PFont head, body, bold;

// Wanted frameRate. Used because frameRate fluctuates, and frameRate is a float instead of int.
int goalFrames = 60;

// General classes
Shake shake;
Stars stars;
Main main;
Player player;
AImanager AImanager;
int FPS;

/* Enemy starting health & damage is proportional to player's starting bullets/sec & starting health */
float AIchildhp, AIbasichp, AIcarrierhp, AIrammerhp;
float AIchilddmg, AIbasicdmg, AIcarrierdmg, AIrammerdmg;

/* LEVEL CREATION */
// Level 1
String[] level1enemies = {"CHILD",
                          "NONE", "CHILD", "CHILD",
                          "NONE", "CHILD", "CHILD", "CHILD",
                          "NONE", "CHILD", "CHILD"};
ArrayList<FloatList> level1enemyInfo;
int[] level1frames = {1,
                      0, 1,
                      round(random(goalFrames/2 - (goalFrames/3), goalFrames/2 + (goalFrames/3))),
                      0, 1,
                      round(random(goalFrames*3/2 - (goalFrames/3), goalFrames*3/2 + (goalFrames/3))),
                      round(random(goalFrames*3/2 - (goalFrames/3), goalFrames*3/2 + (goalFrames/3))),
                      -2, 
                      round(random(goalFrames/6, goalFrames/3)),
                      round(random(goalFrames/6, goalFrames/3))};
Level level1;

// Level 2
String[] level2enemies = {"BASIC",
                          "NONE", "CHILD", "BASIC",
                          "NONE", "BASIC", "BASIC", "BASIC", "CHILD",
                          "NONE", "BASIC", "BASIC", "BASIC", "BASIC", "BASIC", "BASIC", "BASIC"};
ArrayList<FloatList> level2enemyInfo;
int[] level2frames = {1,
                      0, 1, 
                      round(random(goalFrames/6, goalFrames/3)),
                      0, 1,
                      round(random(goalFrames/6, goalFrames/3)),
                      round(random(goalFrames/6, goalFrames/3)),
                      round(random(goalFrames/6, goalFrames/3)),
                      round(random(goalFrames/6, goalFrames/3)),
                      0, 1,
                      round(random(goalFrames*4 - (goalFrames/3), goalFrames*4 + (goalFrames/3))),
                      round(random(goalFrames*4 - (goalFrames/3), goalFrames*4 + (goalFrames/3))),
                      round(random(goalFrames*4 - (goalFrames/3), goalFrames*4 + (goalFrames/3))),
                      round(random(goalFrames*4 - (goalFrames/3), goalFrames*4 + (goalFrames/3))),
                      round(random(goalFrames*4 - (goalFrames/3), goalFrames*4 + (goalFrames/3))),
                      round(random(goalFrames*4 - (goalFrames/3), goalFrames*4 + (goalFrames/3)))};
Level level2;

// Level 3
String[] level3enemies = {"RAMMER", "NONE", "NONE",
                          "RAMMER", "RAMMER", "RAMMER", 
                          "NONE", "RAMMER", "RAMMER", "RAMMER", "RAMMER", "RAMMER", "RAMMER", "RAMMER", "RAMMER",
                          "NONE", "BASIC", "NONE", "RAMMER", "BASIC", "NONE", "RAMMER", "BASIC", "NONE", "RAMMER", "BASIC", "NONE", "RAMMER", "CHILD"};
ArrayList<FloatList> level3enemyInfo;
int[] level3frames = {1, 0, goalFrames,
                      1, 1, 1, 
                      0,
                      round(random(goalFrames/2 - (goalFrames/3), goalFrames/2 + (goalFrames/3))),
                      round(random(goalFrames/2 - (goalFrames/3), goalFrames/2 + (goalFrames/3))),
                      round(random(goalFrames/2 - (goalFrames/3), goalFrames/2 + (goalFrames/3))),
                      round(random(goalFrames/2 - (goalFrames/3), goalFrames/2 + (goalFrames/3))),
                      round(random(goalFrames/2 - (goalFrames/3), goalFrames/2 + (goalFrames/3))),
                      round(random(goalFrames/2 - (goalFrames/3), goalFrames/2 + (goalFrames/3))),
                      round(random(goalFrames/2 - (goalFrames/3), goalFrames/2 + (goalFrames/3))),
                      round(random(goalFrames/2 - (goalFrames/3), goalFrames/2 + (goalFrames/3))),
                      0,
                      round(random(goalFrames*2 - (goalFrames/3), goalFrames*2 + (goalFrames/3))),
                      round(random(goalFrames - (goalFrames/3), goalFrames + (goalFrames/3))),
                      -3,
                      round(random(goalFrames*2 - (goalFrames/3), goalFrames*2 + (goalFrames/3))),
                      round(random(goalFrames - (goalFrames/3), goalFrames + (goalFrames/3))),
                      -3,
                      round(random(goalFrames*2 - (goalFrames/3), goalFrames*2 + (goalFrames/3))),
                      round(random(goalFrames - (goalFrames/3), goalFrames + (goalFrames/3))),
                      -3,
                      round(random(goalFrames*2 - (goalFrames/3), goalFrames*2 + (goalFrames/3))),
                      round(random(goalFrames - (goalFrames/3), goalFrames + (goalFrames/3))),
                      -3,
                      round(random(goalFrames*2 - (goalFrames/3), goalFrames*2 + (goalFrames/3)))};
Level level3;

// Level 4
String[] level4enemies = {"CARRIER",
                          "NONE", "BASIC", "CARRIER",
                          "NONE", "CARRIER", "RAMMER", "RAMMER", "RAMMER", "RAMMER", "RAMMER",
                          "NONE", "CARRIER", "CARRIER", "CARRIER", "CARRIER", "RAMMER"};
ArrayList<FloatList> level4enemyInfo;
int[] level4frames = {1, 
                      0, 1, round(random(goalFrames - (goalFrames/3), goalFrames + (goalFrames/3))),
                      0, 1,
                      round(random(goalFrames*3/2 - (goalFrames/3), goalFrames*3/2 + (goalFrames/3))),
                      round(random(goalFrames*3/2 - (goalFrames/3), goalFrames*3/2 + (goalFrames/3))),
                      round(random(goalFrames*3/2 - (goalFrames/3), goalFrames*3/2 + (goalFrames/3))),
                      round(random(goalFrames*3/2 - (goalFrames/3), goalFrames*3/2 + (goalFrames/3))),
                      round(random(goalFrames*3/2 - (goalFrames/3), goalFrames*3/2 + (goalFrames/3))),
                      0, 1,
                      round(random(goalFrames/2 - (goalFrames/3), goalFrames/2 + (goalFrames/3))),
                      round(random(goalFrames/2 - (goalFrames/3), goalFrames/2 + (goalFrames/3))),
                      round(random(goalFrames/2 - (goalFrames/3), goalFrames/2 + (goalFrames/3))),
                      round(random(goalFrames*3/2 - (goalFrames/3), goalFrames*3/2 + (goalFrames/3)))};
Level level4;

// Level 5
String[] level5enemies = {"CHILD", "BASIC", "CHILD",
                          "NONE", "CARRIER", "BASIC", "BASIC", "NONE", "BASIC", "NONE", "BASIC", "NONE", "BASIC", "NONE", "BASIC", 
                          "NONE"};
ArrayList<FloatList> level5enemyInfo;
int[] level5frames = {1, round(random(goalFrames/2 - (goalFrames/3), goalFrames/2 + (goalFrames/3))),
                      round(random(goalFrames/2 - (goalFrames/3), goalFrames/2 + (goalFrames/3))),
                      0, 1,
                      round(random(goalFrames*3/2 - (goalFrames/3), goalFrames*3/2 + (goalFrames/3))),
                      round(random(goalFrames*3/2 - (goalFrames/3), goalFrames*3/2 + (goalFrames/3))),
                      -2, round(random(goalFrames*3/2 - (goalFrames/3), goalFrames*3/2 + (goalFrames/3))),
                      -2, round(random(goalFrames*3/2 - (goalFrames/3), goalFrames*3/2 + (goalFrames/3))),
                      -2, round(random(goalFrames*3/2 - (goalFrames/3), goalFrames*3/2 + (goalFrames/3))),
                      -2, round(random(goalFrames*3/2 - (goalFrames/3), goalFrames*3/2 + (goalFrames/3))),
                      -2, round(random(goalFrames*3/2 - (goalFrames/3), goalFrames*3/2 + (goalFrames/3))),
                      -2, round(random(goalFrames*3/2 - (goalFrames/3), goalFrames*3/2 + (goalFrames/3))),
                      -1};
Level level5;

// Level x
String[] levelxenemies;
ArrayList<FloatList> levelxenemyInfo;
int[] levelxframes;
Level levelx;

Levels levels;


/** PROGRAM SETUP **/
void setup() {
  devmode = false;
  // Window setup
  size(480, 700);
  rectMode(CORNERS);
  imageMode(CORNERS);
  noStroke();
  // Font setup
  head = createFont("Eras Bold ITC", 40);
  body = createFont("Franklin Gothic Book", 18);
  bold = createFont("Franklin Gothic Demi", 18);
  // Frames setup
  frameRate(goalFrames);
  FPS = int(frameRate);
  // Classes setup
  shake = new Shake();
  stars = new Stars(1400, 2000, 5, 3);
  main = new Main();
  reset();
  // Enemy health & damage setup
  AIchildhp = player.bulletsPSec/2;
  AIbasichp = player.bulletsPSec*3/2;
  AIcarrierhp = player.bulletsPSec*3;
  AIrammerhp = player.bulletsPSec/5;
  AIchilddmg = 1;
  AIbasicdmg = 1;
  AIcarrierdmg = 0;
  AIrammerdmg = player.hp/10;
}


/** Resets every game-related class, so it can be used in the next iteration */
void reset() {
  cursor(ARROW);
  
  player = new Player(width/2, height * 9/10, 
                      40, 24,
                      40, 300, 
                      height*3/2, 16,
                      8, height*3/4, goalFrames, goalFrames/5, 150);
  AImanager = new AImanager();
  
  // Level setup
  level1enemyInfo = new ArrayList<FloatList>();
  for (int i = 0; i < level1enemies.length; i++) {
    level1enemyInfo.add(new FloatList());
  }
  level1 = new Level(level1enemies, level1enemyInfo, level1frames);
  
  level2enemyInfo = new ArrayList<FloatList>();
  for (int i = 0; i < level2enemies.length; i++) {
    level2enemyInfo.add(new FloatList());
  }
  level2 = new Level(level2enemies, level2enemyInfo, level2frames);
  
  level3enemyInfo = new ArrayList<FloatList>();
  for (int i = 0; i < level3enemies.length; i++) {
    level3enemyInfo.add(new FloatList());
  }
  level3 = new Level(level3enemies, level3enemyInfo, level3frames);
  
  level4enemyInfo = new ArrayList<FloatList>();
  for (int i = 0; i < level4enemies.length; i++) {
    level4enemyInfo.add(new FloatList());
  }
  level4 = new Level(level4enemies, level4enemyInfo, level4frames);
  
  level5enemyInfo = new ArrayList<FloatList>();
  for (int i = 0; i < level5enemies.length; i++) {
    level5enemyInfo.add(new FloatList());
  }
  level5 = new Level(level5enemies, level5enemyInfo, level5frames);
  
  levels = new Levels();
  levels.addLvl(level1);
  levels.addLvl(level2);
  levels.addLvl(level3);
  levels.addLvl(level4);
  levels.addLvl(level5);
  
  // DEBUG
  //levels.levelcount = 3;
}


/** PROGRAM LOOP **/
void draw() {
  background(0);
  
  shake.update();
  stars.update();
  main.update();
  if (main.stage.toLowerCase() == "start") {
    // DEBUG //<>//
    //println(levels.levels.get(0).enemyCount, AImanager.AIchilds.size(), AImanager.AIbasics.size(), AImanager.AIcarriers.size(), AImanager.AIrammers.size());
    player.update();
    AImanager.update();
    levels.update();
    // Custom code for level 5 (final level). Spawns a rammer every 3 seconds, if enemyCount still has enemies in queue
    if (levels.levelcount == 5 && frameCount % (goalFrames*3) == 0 && levels.levels.get(0).enemyCount > 0) {
      levels.levels.get(0).enemyCount++;
      levels.levels.get(0).enemyType = reverse(append(reverse(levels.levels.get(0).enemyType), 
                                                      "RAMMER"));
      levels.levels.get(0).enemyValues.add(0, new FloatList());
      levels.levels.get(0).frames = reverse(append(reverse(levels.levels.get(0).frames),
                                                           1));
    }
    // Quick code to prevent random bug
    if (levels.levelcount == 5 && levels.levels.get(0).enemyCount == 0 && AImanager.AIrammers.size() > 0) AImanager.AIrammers = new ArrayList<AIrammer>();
    
    // Red colouring is added to everything if screen is shaking (which comes from taking damage)
    fill(255, 0, 0, shake.tintvalue);
    noStroke();
    rect(0, 0, width, height);
  }
  
  // Every second, updates FPS (FPS ∈ I). Every frame, displays FPS at the bottom right
  if (frameCount % 60 == 0) FPS = round(frameRate);
  noStroke();
  fill(255);
  textFont(body);
  textSize(12);
  textAlign(RIGHT, BOTTOM);
  text(FPS + " FPS", width, height);
}


void mouseClicked() {
  // Checks if anything has been clicked in the Main class
  if (main.stage != "start") main.checkClicked();
}

/** KEY/MOUSE PRESS/RELEASE MECHANISM. Method taken from https://discourse.processing.org/t/smooth-moving-code/7126/4. **/
/** Tracks when a key is pressed */
void keyPressed() {
  if (key == CODED) {
    switch (keyCode) {
      case (UP):
        keyUP = true;
        break;
      case (LEFT):
        keyLEFT = true;
        break;
      case (DOWN):
        keyDOWN = true;
        break;
      case (RIGHT):
        keyRIGHT = true;
        break;
    }
  } else {
    switch (key) {
      case ('w'):
      case ('W'):
        keyW = true;
        break;
      case ('a'):
      case ('A'):
        keyA = true;
        break;
      case ('s'):
      case ('S'):
        keyS = true;
        break;
      case ('d'):
      case ('D'):
        keyD = true;
        break;
      case ('g'):
      case ('G'):
        // Toggles devmode
        devmode = devmode == true ? false : true;
        if (devmode) println("Developer mode: ON");
        else println("Developer mode: OFF");
        break;
      case ('n'):
      case ('N'):
        levels.levels.get(0).enemyCount = 0;
        AImanager = new AImanager();
        break;
    }
  }
}

/** Tracks when a key is released */
void keyReleased() {
  if (key == CODED) {
    switch (keyCode) {
      case (UP):
        keyUP = false;
        break;
      case (LEFT):
        keyLEFT = false;
        break;
      case (DOWN):
        keyDOWN = false;
        break;
      case (RIGHT):
        keyRIGHT = false;
        break;
    }
  } else {
    switch (key) {
      case ('w'):
      case ('W'):
        keyW = false;
        break;
      case ('a'):
      case ('A'):
        keyA = false;
        break;
      case ('s'):
      case ('S'):
        keyS = false;
        break;
      case ('d'):
      case ('D'):
        keyD = false;
        break;
    }
  }
}

/** Tracks when a mouseButton is pressed */
void mousePressed() {
  switch (mouseButton) {
    case (LEFT):
      mouseLEFT = true;
      break;
    case (RIGHT):
      mouseRIGHT = true;
      break;
  }
}

/** Tracks when a mouseButton is released */
void mouseReleased() {
  switch (mouseButton) {
    case (LEFT):
      mouseLEFT = false;
      break;
    case (RIGHT):
      mouseRIGHT = false;
      break;
  }
}
