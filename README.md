# cs10-final-project
This project is a program that I coded for Grade 10 in high school. Using Processing 4, the program is a top-down space shooter. I made five complete levels, with each level introducing a new enemy. The game is very unbalanced.

## How to run
1. If you have not yet, [download Processing 4](https://processing.org/download).
2. Open this repo in Github Desktop.
3. In Github Desktop, view this file in File Explorer/Finder by selecting "Show in Explorer" or using the shortcut Ctrl+Shift+F.
4. Open CS10_Final_Project → CS10_Final_Project.pde.
5. Once Processing is open, click the Run button on the top left.
6. Use the mouse button to navigate the menu. I recommend to view the "How to Play" screen first, as there is no tutorial in the base game. Have fun!

## Specific details
### Main features
* Menu containing buttons "Play", "How to Play", and "Credits"
* Five levels to play through, with each level introducing a new enemy/concept
* Player has two modes of firing:
    * Primary fire shoots many low damage bullets
    * Secondary fire shoots a high damage  burst bomb after charging for some time
* "Child" and "basic" enemies that move left and right, shooting intermittently
* "Rammer" enemy that charges towards the player, exploding and doing damage on contact
* "Carrier" enemy that avoids the player, intermittently spawning "child" enemies
### Added polish
* Downward star movement creates sense of fast ship speed
* Ship integrity UI progressively becomes redder after taking more damage
* Screen very slightly shakes on taking damage
### Debug features
* Pressing the "g" key toggles godmode
* Pressing the "n" key moves to the next level