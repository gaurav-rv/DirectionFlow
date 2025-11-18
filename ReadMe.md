############
This is a game similar to existing games where you go from start to end. 
The goal of the game is to lay a path from the start point to end point by turning the tiles surrounding a path so the circuit continues.

The path is going to be tiles of size 64*64 which we are going to name as pipes.
Every pipe will have a start direction and an end direction that determines how the pipe can be used. 
A circuit is complete if we can move from the start point to the end point via the pipes rotated in a certain manner. 


What attributes will a pipe have?
1. Start Direction
2. End direction
3. State - 0 (utilized), 1 (not utilized) - Going for number here, in case I want to introduce more states
4. XPos - Relative to the grid.
5. YPos - Relative to the grid.
6. Orientation - 0, 45, 90, 180, 270  

All the animation should be handled in the pipe when we transition between states and orientation. 

The grid will be the board where the game starts. 
First we will start with an 8 by 8 pipe in haphazard manner. 

############
