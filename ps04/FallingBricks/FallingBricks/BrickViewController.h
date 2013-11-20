/*
 The main class that contains a PhysicsEngine object
 It first initializes the physics engine with a time step and gravity multiplier
 It then initializes the all the objects in the PhysicsEngine and loads the views
 array of both bricks and walls.
 If defines the <ModelModifyProtocol> that updates the view when the delegate is
 received
*/
#import <UIKit/UIKit.h>
#import "PhysicsModel.h"
#import "PhysicsEngine.h"
#import "ModelModifyProtocol.h"
#import <QuartzCore/QuartzCore.h>
#import "RectangleShape.h"

@interface BrickViewController : UIViewController <ModelModifyProtocol>
@property (readonly) PhysicsEngine *world;
@property (readonly) NSArray *brickViews;
@property (readonly) NSArray *wallViews;

@end
