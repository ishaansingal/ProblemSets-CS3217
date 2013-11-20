/*
 This class contains a timer that periodically detects collision and updates the 
 center and rotation of the objects accordingly. This also modifies the gravity 
 based on the device orientation/accelerometer.
 It maintains two array: allMovables (for this project these are bricks) and
 allImmovables (for this project the walls).It performs the collision detection 
 itself on these two arrays
 */
#import <UIKit/UIKit.h>
#import <CoreMotion/CoreMotion.h>
#import "PhysicsModel.h"
@interface PhysicsEngine : UIViewController <UIAccelerometerDelegate>

@property (readonly) Vector2D* gravity;
@property (readonly) NSArray *allMovables;
@property (readonly) NSArray *allImmovables;

//REQUIRES: a positive valid timestep
//EFFECTS: initialize the timestep, gravity multiplier
- (id)initWithTimeStep:(double)timeStep GMultiplier:(double)gMult;

//can be used in when integrating with other entities, as in this project, the engine
//itself creates the objects and allocates in the array (for simplicity purposes)
- (void)initImmovablesWithArray:(NSArray*)objectArray;

//can be used in when integrating with other entities, as in this project, the engine
//itself creates the objects and allocates in the array (for simplicity purposes)
- (void)initMovablesWithArray:(NSArray*)objectArray;

//REQUIRES: self.timeStep to be a valid value ( timestep >0 and <0.2 preferrably)
//EFFECTS: starts the timer engine to trigger a loop for every timestep
- (void)startEngine;

//EFFECTS: stops the timer engine and the collision is no longer detected periodically
- (void)stopEngine;

//REQUIRES: although the program would not fail, it will cause problems if it
//doesnt have accelerometer
//EFFECTS: starts the motion detection if available
- (void)startMotionDetection;

//creates the 4 wall objects and initializes the allImmovables array
- (void)initializeBrickObjects;

//creates the bricks model objects and initializes the allBlocks array
- (void)initializeWallObjects;
@end
