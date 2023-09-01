/***
These are all functions that manage all the enemies that the player will have to avoid and shoot. Functions include:
  - EnemyBullet (manages one bullet that will be shot by one enemy)
  - EnemyBullets (manages multiple bullets that will be shot by one enemy)
  - EnemyAnim (manages the animation portion of the enemy. Currently, it manages the spawning of an enemy, and staggering from a bomb)
  - Enemy (manages all the actions that an enemy will do, including movement, shooting projectile types, and spawning into the screen)
  - AIchild (creates one child AI. The AI moves left to right predictably, and shoots every second)
  - AIbasic (same as AIchild, but larger and bulkier. Shoots 1.5x as fast)
  - AIcarrier (tries to move away from the player, summoning child AI to attack the player instead)
  - AIrammer (charges towards the player, exploding on collision with player, or touching bottom edge of screen)
  - AImanager (manages all AI created, removing them based on specific criteria (eg. if their bullets are offscreen and if the enemy has no health left))

WHEN CREATING NEW AI, FOLLOW THIS CHECKLIST:
  - add the AI to AImanagers with new variables
  - add AI to Level(), as a spawning option
  - add the AI into the level that you want it to appear in
*/

/** Manages one enemy's bullet */
class EnemyBullet {
  // Position of bullet
  float x, y;
  // Speed of bullet travelled in one second
  float bulletVelocity;
  // Boundary box of the bullet
  BoundBox bounds;
  
  EnemyBullet(float x, float y, float bulletVelocity) {
    // Setting variables
    this.x = x;
    this.y = y;
    this.bulletVelocity = bulletVelocity;
    bounds = new BoundBox(false);
    bounds.newBound(x, y, 5, 10);
  }
  
  void update() {
    // Displaying bullet
    noStroke();
    fill(#FF0000);
    rect(bounds.x1, bounds.y1, bounds.x2, bounds.y2); 
    // Moves the bullet up by bulletVelocity, to mimic movement
    y += (bulletVelocity/goalFrames);
    bounds.newBound(x, y, 5, 15);
  }
}


/* Manages multiple player bullets */
class EnemyBullets {
  ArrayList<EnemyBullet> bullets = new ArrayList<EnemyBullet>();
  float bulletVelocity;
  
  EnemyBullets(float bulletVelocity) {
    this.bulletVelocity = bulletVelocity;
  }
  
  /* Adds a new bullet to the specified coordinates */
  void newBullet(float x, float y) {
    bullets.add(new EnemyBullet(x, y, bulletVelocity)); 
  }
  
  /* Updates all the bullets under the bullets list */
  void update() {
    for (int i = 0; i < bullets.size(); i++) {
      EnemyBullet crntBullet = bullets.get(i);
      crntBullet.update();
      if(crntBullet.bounds.y1 > height) { // If the current bullet is offscreen, the bullet gets deleted
        bullets.remove(i);
      }
    }
  }
}

/** Manages an enemy's animation (ie. spawning and staggering) */
class EnemyAnim {
  /* Uses displacement formula (d = ut * (1/2)at^2), acceleration formula (a = (u - v)/t), velocity formula (v = d/t), and length of line √((x₁-x₂)²+(y₁-y₂)²)
     The spawning animation consists of a ship appearing from the top of the screen, decelerating and stopping at a specific position.
     Once the ship reaches this position, it will start its normal behaviour (eg. attacking).
     The program does this by first calculating the acceleration necessary to reach the final position at rest, and also calculates the angle of the line created. 
     It then finds where the enemy should be at a specific frame, using the calculated acceleration and calculated angle to find the x and y position. 
     It does this for Δt frames. After that, all normal controls are allowed. */
  // Lets the program know if it is in the spawning animation, and if interrupting is wanted
  boolean spawning;
  // Spawn stores where the ship starts, and crnt stores the current position of the ship's animation.
  float spawnx, spawny, finalx, finaly, crntx, crnty;
  // Stores formula variables
  float a, u, deltad, d;
  int deltat;
  // Will store the current frame in the spawning animation
  int t;
  // Stores the proportionate ratio for future use
  float propRatio;
  
  boolean staggering;
  
  EnemyAnim() {
    spawning = false;
    staggering = false;
  }
  
  /* Starts the spawning algorithm */
  void initSpawn(float startx, float starty, float endx, float endy, int moveframes) {
    spawning = true;
    this.spawnx = startx;
    this.spawny = starty;
    this.finalx = endx;
    this.finaly = endy;
    // Length of line formula
    this.deltad = sqrt(sq(spawnx-finalx) + sq(spawny-finaly));
    this.deltat = moveframes;
    // Velocity formula (multiplying by 2 because a triangle would let only let the ship move halfway to the endpoint)
    this.u = deltad*2 /deltat;
    // Acceleration formula
    this.a = (0-u) / deltat;
    this.t = 0;
  }
  
  /* Starts the staggering algorithm. Essentially the same as the spawning algorithm, but determining end location is different. */
  void initStagger(float startx, float starty, float bombx, float bomby, float movedist) {
    staggering = true;
    
    this.spawnx = startx;
    this.spawny = starty;
    // movedist is multiplied by a ratio, then added to spawnx/spawny to find the final distance after offset. Specific cases are created for bug-creating values.
    // An example of a ratio is ((bombx - startx) / (bomby - starty)).
    if (starty - bomby < 1 || starty == bomby) {
      if (bombx > startx) this.finalx = spawnx - movedist * ((bombx - startx) / (bomby - starty));
      else this.finalx = spawnx - movedist * ((startx - bombx) / (starty - bomby));
    } else {
      this.finalx = spawnx - movedist;
    }
    if (startx - bombx < 1 || startx == bombx) {
      if (bomby > starty) this.finaly = spawny - movedist * ((bomby - starty) / (bombx - startx));
      else this.finaly = spawny - movedist * ((starty - bomby) / (startx - bombx));
    } else {
      this.finaly = spawny - movedist;
    }
    // Length of line formula
    this.deltad = sqrt(sq(spawnx-finalx) + sq(spawny-finaly));
    this.deltat = int(player.explodeFrames);
    // Velocity formula (multiplying by 2 because a triangle would let only let the ship move halfway to the endpoint)
    this.u = deltad*2 /deltat;
    // Acceleration formula
    this.a = (0-u) / deltat;
    this.t = 0;
  }
  
  void update() {
    if (spawning || staggering) {
      if (t < deltat) {
        /* Uses two similar imaginary right triangles to find where the current position of the ship should be.
             Assume that line(spawnX, spawnY, x, y) is a diagonal line.
             It's possible to draw a rectangle with the same variables (ie. rect(spawnX, spawnY, x, y)).
             You can use two of the lines from rect() and the line() to create a right triangle.
             'd' can always be referred to as a point on line(spawnX, spawnY, x, y).
             Because of this, you can create a second right triangle with the coordinates (spawnX, spawnY, d-x, d-y).
             We now have all the lengths of the larger right triangle, and the hypotenuse of the smaller right triangle.
             It's now possible to calculate the ratio between the similar smaller and larger triangles, and then use that ratio to find the lengths of the other lengths.
             These other lengths correspond to the x and y amounts that are added to find the current position of the ship. */
        // Displacement formula
        d = u*t + a*sq(t)/2;
        // Finds the ratio between the total distance and current length, so that it can be applied to x and y axes
        propRatio = d/deltad;
        
        if (spawnx < finalx) // If the ship is coming from the left
          crntx = spawnx + abs((spawnx - finalx) * propRatio);
        else // If the ship is coming from the right
          crntx = spawnx - abs((finalx - spawnx) * propRatio);
        
        if (spawny < finaly) // If the ship is coming from the top
          crnty = spawny + abs((spawny - finaly) * propRatio);
        else // If the ship is coming from the bottom
          crnty = spawny - abs((spawny - finaly) * propRatio);
        t++;
      } else { // Otherwise, the enemy has finished spawning/staggering
        spawning = false;
        staggering = false;
      }
    } else if (staggering) {
      
    }
  }
}

/** Manages all the actions that an enemy ship can do. */
class Enemy {
  // Will store the position and dimensions of the ship
  float x, y, len, ht; 
  // Stores health and damage of enemy
  float hp, dmg;
  // Colour of enemy
  color colour;
  // Location of enemy
  BoundBox bounds;
  // Manages bullet related variables
  EnemyBullets bullets;
  // Manages enemy's animations
  EnemyAnim anim;
  
  // Initialization
  Enemy(float x, float y, float len, float ht, float hp, float dmg, float bulletVelocity, color colour) {
    this.x = x;
    this.y = y;
    this.len = len;
    this.ht = ht;
    this.hp = hp;
    this.dmg = dmg;
    this.colour = colour;
    bounds = new BoundBox(true);
    this.bullets = new EnemyBullets(bulletVelocity);
    
    this.anim = new EnemyAnim();
    anim.initSpawn(x + random(-100, 100), int(0 - ht/2), x, y, goalFrames*2/3);
  }
  
  /* Moves the enemy's position by xDiff and yDiff */
  void move(float xDiff, float yDiff) {
    if(!(anim.spawning || anim.staggering)) {
      bounds.newBound(x + xDiff, y + yDiff, len, ht);
      x = bounds.x1 + len/2;
      y = bounds.y1 + ht/2;
    }
  }
  
  /* Shoots a new bullet, from the ship's position */
  void shoot() {
    if(!(anim.spawning || anim.staggering) && hp > 0) {
      bullets.newBullet(x, y);
    }
  }
  
  /* If currently in the animation sequence, updates EnemyAnim class, and displays the enemy on outputted variables from EnemyAnim.
     Otherwise, update() displays the ship, updates all bullets, and checks for collisions. */
  void update() {
    if (anim.spawning) { // Ship is spawning
      anim.update();
      noStroke();
      fill(colour);
      rectMode(CENTER);
      rect(anim.crntx, anim.crnty, len, ht);
      rectMode(CORNERS);
    }
    else { // Not spawning
      if (hp > 0) { // Prevented from checking for collisions if already dead
        PlayerBullet crntBullet;
        PlayerBomb crntBomb;
        
        // Updates & displays ship. If spawning or staggering, the enemy's bounds are set to the animation's location.
        if (anim.spawning || anim.staggering) {
          anim.update();
          x = anim.crntx;
          y = anim.crnty;
        }
        bounds.newBound(x, y, len, ht);
        noStroke();
        fill(colour);
        rect(bounds.x1, bounds.y1, bounds.x2, bounds.y2);
        
        // Checking if bullet hit the ship
        for (int i = 0; i < player.bullets.bullets.size(); i++) {
          crntBullet = player.bullets.bullets.get(i);
          if (bounds.inBounds(crntBullet.bounds)) {
            if (!devmode) hp--;
            else hp = 0;
            player.bullets.bullets.remove(i);
          }
        }
        
        // Checking if bomb hit the ship
        for (int i = 0; i < player.bombs.bombs.size(); i++) {
          crntBomb = player.bombs.bombs.get(i);
          if (bounds.inBounds(crntBomb.bounds)) {
            if (crntBomb.stage == 0) {
              // abs() is so future me doesn't forget about this line of code and get frustrated
              if (!devmode) hp -= abs(player.bulletsPSec-player.bombDmg);
              else hp = 0;
              
              crntBomb.stage++; // By incrementing the bomb, the bomb function is told to start exploding
              // If bomb exploded much earlier than hitting the enemy
              if (crntBomb.y > y+50) println("Bomb exploded early: diagnostics are", x, y, i);
            } else if (crntBomb.stage == 1) {
              if (!devmode) hp -= player.bombDmg;
              else hp = 0;
              anim.initStagger(x, y, crntBomb.x, crntBomb.y, player.explodeSize/10);
            }
          }
        }
      }
      // Updates bullets, then checks if any bullets hit the player
      EnemyBullet crntBullet;
      
      bullets.update();
      for (int i = 0; i < bullets.bullets.size(); i++) {
        crntBullet = bullets.bullets.get(i);
        if (crntBullet.bounds.inBounds(player.bounds)) {
          bullets.bullets.remove(i);
          
          float floatdmg = dmg;
          float floatplayermaxhp = player.maxhp;
          float floatgoalFrames = goalFrames;
          // Intensity and duration of shaking is proportional to the damage done to the player
          shake.shake(floatdmg*(floatplayermaxhp/50) + floatplayermaxhp/20, 
                      round(floatdmg*(floatgoalFrames/50) + floatgoalFrames/15) );
          if (!devmode) player.hp -= dmg;
        }
      }
    }
  }
  
  /* Checks if the enemy is touching the left or right side of the window */
  boolean onXEdge() {
    if (len/2 >= x || x >= width - len/2) return true;
    else return false;
  }
  
  /* Checks if the enemy is touching the bottom of the window*/
  boolean onBottomEdge() {
    if (y >= height - ht/2) return true;
    else return false;
  }
}


/** Manages one child AI.
    Moves left and right, shooting every second, changing direction every time it hits the edge of the screen.
    Can also be spawned by carriers. */
class AIchild {
  Enemy enemy;
  boolean movingLeft;
  float moveSpeed;
  // Offsets the shooting with frameCount, so that all children don't shoot at the same time
  int offset;
  
  AIchild (float x, float y, boolean movingLeft) {
    this.movingLeft = movingLeft;
    this.offset = int(random(0, goalFrames + 1));
    enemy = new Enemy(x, y, 24, 16, AIchildhp, AIchilddmg, 500, #FF0000);
    moveSpeed = 200/goalFrames;
  }
  
  /* Updates the ship, through movement */
  void update() {
    if (enemy.onXEdge()) { // Reverses movingLeft if the AI is touching the edge
      if (movingLeft) movingLeft = false;
      else movingLeft = true;
    }
    
    if (movingLeft) enemy.move(0 - moveSpeed, 0);
    else enemy.move(moveSpeed, 0);
    
    if (frameCount % goalFrames == offset) enemy.shoot();
    
    enemy.update();
  }
}


/** Manages one basic AI.
    Same as child AI, but is larger and generally better. */
class AIbasic {
  Enemy enemy;
  boolean movingLeft;
  float moveSpeed;
  // Offsets the shooting with frameCount, so that all children don't shoot at the same time
  int offset;
  
  AIbasic (float x, float y, boolean movingLeft) {
    this.movingLeft = movingLeft;
    this.offset = int(random(0, goalFrames*2/3 + 1));
    enemy = new Enemy(x, y, 36, 24, AIbasichp, AIbasicdmg, 500, #FF0000);
    moveSpeed = 250/goalFrames;
  }
  
  /* Updates the ship, through movement */
  void update() {
    if (enemy.onXEdge()) { // Reverses movingLeft if the AI is touching the edge
      if (movingLeft) movingLeft = false;
      else movingLeft = true;
    }
    
    if (movingLeft) enemy.move(0 - moveSpeed, 0);
    else enemy.move(moveSpeed, 0);
    
    if (frameCount % (goalFrames*2/3) == offset) enemy.shoot();
    
    enemy.update();
  }
}


/** Manages one carrier AI.
    Moves away to a position that's far from the player. After that, spawns a child AI to a cap of 4 AI.
    If the carrier AI has no children, it spawns 2 on its next iteration. */
class AIcarrier {
  Enemy enemy;
  float moveSpeed;
  // Counts the valid frames
  int counter;
  // The current phase of the enemy
  int stage;
  // The coordinates that the carrier wants to reach
  float goalx, goaly;
  ArrayList<AIchild> children;
  AIchild crntchild;
  
  float direction;
  
  AIcarrier(float x, float y) {
    enemy = new Enemy(x, y, 44, 22, AIcarrierhp, AIcarrierdmg, 0, #FF008D);
    moveSpeed = 250/goalFrames;
    counter = 0;
    stage = 0;
    children = new ArrayList<AIchild>();
  }
  
  /* Creates an AI child, giving an appearance of spawning from the carrier */
  void addAIchild() {
    children.add(new AIchild(random(enemy.x - 20, enemy.x + 20), random(enemy.y - 45, enemy.y - 35), boolean(int(random(0, 2))) ));
    crntchild = children.get(children.size() - 1);
    
    // Setting the child's spawning location to the carrier
    crntchild.enemy.anim.spawnx = enemy.x;
    crntchild.enemy.anim.spawny = enemy.y;
  }
  
  void update() {
    if (enemy.hp > 0 && !enemy.anim.spawning && !enemy.anim.staggering) {
      if (stage == 0) { // Finds a spot that is away from the player
        if (player.x > width/2) goalx = random(enemy.len, abs(player.x - player.len*2));
        else goalx = random(player.x + player.len*2, width - enemy.len);
        goaly = random(40, height/4);
        stage++;
        
      } else if (stage == 1) { // Starts moving towards the wanted spot
        // Makes the enemy ship face towards the wanted location
        direction = atan2(goaly - enemy.y, goalx - enemy.x);
        
        if (abs(direction) > PI/2 && // Left half of circle
            enemy.x + moveSpeed*cos(direction) <= goalx) { // If the moving of the enemy will pass the destination on this frame 
          enemy.x = goalx;
        } else if (abs(direction) <= PI/2 && // Right half of circle 
                   enemy.x + moveSpeed*cos(direction) >= goalx) { // If the moving of the enemy will pass the destination on this frame
          enemy.x = goalx;
        }
        if (direction < 0 && // Top half of circle
            enemy.y + moveSpeed*sin(direction) <= goaly) { // If the moving of the enemy will move to destination on this frame 
          enemy.y = goaly;
        } else if (direction >= 0 && // Bottom half of circle 
                   enemy.y + moveSpeed*sin(direction) >= goaly) { // If the moving of the enemy will pass the destination on this frame
          enemy.y = goaly;
        }
        
        if (enemy.x != goalx) enemy.move(moveSpeed * cos(direction), 0); // Moves x if x location can't be reached this frame
        if (enemy.y != goaly) enemy.move(0, moveSpeed * sin(direction) ); // Moves y if y location can't be reached this frame
        
        if (enemy.x == goalx && enemy.y == goaly) {
          stage++; // Continues to the next phase if reached goal location
        } //<>//
        
      } else if (stage == 2) { // After pausing a bit, spawns a child AI
        counter++;
        // Spawning child
        if (counter >= goalFrames*7/4) {
          counter = 0;
          stage++;
          if (children.size() == 0) {
            addAIchild();
            addAIchild();
          } else if (children.size() < 4) { // The carrier can own a maximum of 4 children
            addAIchild();
          }
        }
      } else { // stage == 3    Delays a bit before restarting phases
        counter++;
        // Waits for a bit, so the player can do damage to the carrier. Resets once the cycle has finished
        if (counter >= goalFrames/2) {
          counter = 0;
          stage = 0;
        }
      }
    }
    
    // Update carrier ship and its children
    for (int i = 0; i < children.size(); i++) { // Running through all child AI
      crntchild = children.get(i);
      if (crntchild.enemy.hp <= 0 && crntchild.enemy.bullets.bullets.size() == 0) children.remove(i);
      else crntchild.update();
    }
    enemy.update();
  }
}


/** Manages one rammer AI.
    After spawning in, the AI starts charging towards the player.
      Any contact results in damage being done to the player, and explosion animation of the rammer AI (turns yellow in alpha). */
class AIrammer {
  Enemy enemy;
  int stage;
  int frameStart;
  // Terminal arm path that the AI is on
  float direction;
  // The terminal arm that the AI has to travel to hit the player
  float playerdirection;
  // How many radians the rammer can turn by each frame, and how fast the rammer travels each second
  float rotateSpeed, moveSpeed;
  
  AIrammer(float x, float y) {
    stage = 0;
    frameStart = frameCount;
    enemy = new Enemy(x, y, 20, 32, AIrammerhp, AIrammerdmg, 0, #FF9900);
    enemy.bounds.inWindow = false;
    
    rotateSpeed = (PI/3)/goalFrames;
    moveSpeed = 600/goalFrames;
  }
  
  void update() {
    if (enemy.anim.spawning) {
      if (atan2(player.y - enemy.y, player.x - enemy.x) > 0) direction = atan2(player.y - enemy.y, player.x - enemy.x);
      else direction = atan2(player.y - enemy.y, player.x - enemy.x) + TWO_PI;
      
    } else if (stage == 0) {
      if (enemy.bounds.inBounds(player.bounds)) { // If the rammer collided with the player, the player takes damage and the explosion animation happens
        enemy.hp = 0;
        stage++;
        frameStart = frameCount;
        if (!devmode) player.hp -= enemy.dmg;
        // Shakes the screen proportional to damage
        float floatdmg = enemy.dmg;
        float floatplayermaxhp = player.maxhp;
        float floatgoalFrames = goalFrames;
        // Intensity and duration of shaking is proportional to the damage done to the player
        shake.shake(floatdmg*(floatplayermaxhp/50) + floatplayermaxhp/20, 
                    round(floatdmg*(floatgoalFrames/50) + floatgoalFrames/15) );
      } else if (enemy.onBottomEdge() || enemy.hp <= 0) { // If the rammer hit the bottom of the map or has been destroyed by the player, only the explosion animation happens
        enemy.hp = 0;
        stage++;
        frameStart = frameCount;
      } else if (enemy.x < 0 - enemy.len || enemy.x > width + enemy.len) { // If the rammer has gone off the left or right side of the screen
        stage = 2;
      } else { // Otherwise, the rammer continues moving towards the player, turning if not on course of collision. Details below
        /* Determines the angle that the ship is currently travelling in.
           Because Processing 3 uses values from -PI to PI, all angles need to be made positive, then checked for the transition from 0 -> 2PI & vice versa.*/
        // Turning playerdirection into a positve value 
        if (atan2(player.y - enemy.y, player.x - enemy.x) > 0) playerdirection = atan2(player.y - enemy.y, player.x - enemy.x);
        else playerdirection = atan2(player.y - enemy.y, player.x - enemy.x) + TWO_PI;
        
        if (playerdirection < PI/2 && 
            direction > PI*3/2) { // If the rammer is wanting to move clockwise on the right side
          direction = constrain(playerdirection + TWO_PI,
                                direction - rotateSpeed, direction + rotateSpeed);
          if (direction > PI) direction = direction - TWO_PI;
          
        } else if (playerdirection > PI*3/2 &&
                   direction < PI/2) { // If the rammer is wanting to move counter-clockwise on the right side
          direction = constrain(playerdirection - TWO_PI,
                                direction - rotateSpeed, direction + rotateSpeed);
          if (direction < -1*PI) direction = direction + TWO_PI;
          
        } else {
          direction = constrain(playerdirection, direction - rotateSpeed, direction + rotateSpeed);
        }
        
        // If direction is negative, it's made positive
        direction += (direction < 0) ? TWO_PI : 0;
        
        // Moves the enemy based on its terminal arm
        enemy.move(moveSpeed * cos(direction), moveSpeed * sin(direction) );
      }
    } else { // stage == 1
      if (frameCount - frameStart < goalFrames/2) { // Displays the explosion animation of the rammer AI
        rectMode(CENTER);
        noStroke();
        fill(#FFFF00);
        rect(enemy.x, enemy.y, enemy.len + 10, enemy.ht + 10);
        rectMode(CORNERS);
      } else { // Ends the current stage otherwise, so that the rammer AI can be removed
        stage++;
      }
    }
    
    enemy.update();
  }
}


/** Manages all AI. */
class AImanager {
  ArrayList<AIchild> AIchilds = new ArrayList<AIchild>();
  AIchild AIchildCrnt;
  ArrayList<AIbasic> AIbasics = new ArrayList<AIbasic>();
  AIbasic AIbasicCrnt;
  ArrayList<AIcarrier> AIcarriers = new ArrayList<AIcarrier>();
  AIcarrier AIcarrierCrnt;
  ArrayList<AIrammer> AIrammers = new ArrayList<AIrammer>();
  AIrammer AIrammerCrnt;
  
  /* Creates a new child AI at the specified location */
  void newAIchild(float x, float y, boolean movingLeft) {
    AIchilds.add(new AIchild(x, y, movingLeft));
  }
  
  /* Creates a new basic AI at the specified loaction */
  void newAIbasic(float x, float y, boolean movingLeft) {
    AIbasics.add(new AIbasic(x, y, movingLeft));
  }
  
  /* Creates a new carrier AI at the specified loaction */
  void newAIcarrier(float x, float y) {
    AIcarriers.add(new AIcarrier(x, y));
  }
  
  /* Creates a new rammer AI at the specified location */
  void newAIrammer(float x, float y) {
    AIrammers.add(new AIrammer(x, y));
  }
  
  /* Updates all AI */
  void update() {
    for (int i = 0; i < AIchilds.size(); i++) { // Running through all child AI
      AIchildCrnt = AIchilds.get(i);
      if (AIchildCrnt.enemy.hp <= 0 && AIchildCrnt.enemy.bullets.bullets.size() == 0) AIchilds.remove(i);
      else AIchildCrnt.update();
    }
    for (int i = 0; i < AIbasics.size(); i++) { // Running through all basic AI
      AIbasicCrnt = AIbasics.get(i);
      if (AIbasicCrnt.enemy.hp <= 0 && AIbasicCrnt.enemy.bullets.bullets.size() == 0) AIbasics.remove(i);
      else AIbasicCrnt.update();
    }
    for (int i = 0; i < AIcarriers.size(); i++) { // Running through all child AI
      AIcarrierCrnt = AIcarriers.get(i);
      if (AIcarrierCrnt.enemy.hp <= 0 && AIcarrierCrnt.children.size() == 0) AIcarriers.remove(i);
      else AIcarrierCrnt.update();
    }
    for (int i = 0; i < AIrammers.size(); i++) { // Running through all rammer AI
      AIrammerCrnt = AIrammers.get(i);
      if (AIrammerCrnt.stage > 1) AIrammers.remove(i);
      else AIrammerCrnt.update();
    }
  }
  
  /* Returns the number of ships that AImanager is managing */
  int enemyNum() {
    return AIchilds.size() + AIbasics.size() + AIcarriers.size() + AIrammers.size();
  }
}
