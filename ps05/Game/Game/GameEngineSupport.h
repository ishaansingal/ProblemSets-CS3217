/*
 Extension of the GameViewController that integrates the Box2D engine with the
 existing model.
 It completely handles the Playing of a particular level.
 It has methods to convert the existing model into the Box2D style model
 It is responsible for the creation of breath, killing the pig and keeping the score
 It has a timer that periodically checks with the physics engine regarding any collisions
 Based on the collisions, it updates the model, that then sends a delegate to update the view
 It uses the impulse & expired property to check whether an object is to be deleted from the 
 view
 Note that if the wolf is bigger, the power of the breath is bigger
 Also, it has a ratio converter to convert the Pixel units to meters (as Box2D uses meters)
 */

#import "GameViewController.h"
#import "MyContactListener.mm"

@interface GameViewController (GameEngineSupport) <CollisionDelegate, UIAlertViewDelegate>

//sets up the score image and its label
- (void)setupScore;

//The Main method that sets up all the GameObjects for start mode, sets up the
//physics engine 'world' and starts the engine
- (void)startPlay;

//The Main method (opposite of startplay) that dismantles the physics world and clears
//everything
- (void)endPlay;

//checks whether start is possible - both wolf and pig should be in the gamearea
- (BOOL)isStartModePossible;
@end
