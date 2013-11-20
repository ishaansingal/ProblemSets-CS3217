/*
 GameBreath deals with one breath in the game.
 It uses GameModel as its model and has delegates implemented to act when the model is modified
 It also creates a trace for the breath as it travels (the trace is made to stop when the 
 breath hits any other object). 
 It also scrolls the gamearea as it travels beyond the view
 
 It is always animating with the sprits provided

 */

#import <UIKit/UIKit.h>
#import "GameObject.h"
@interface GameBreath : UIViewController <ModelModifyDelegate>

@property(nonatomic, readonly) GameModel *modelObj;
@property(readonly) BOOL trace;

- (id)initWithOrigin:(CGPoint)origin Radius:(CGFloat)radius  Velocity:(Vector2D*)givenVel;
// REQUIRES: valid data input for the all the parameters
// EFFECTS: Construts a GameObject based on the properties, and initializes
// the modelObj, the imageView, and updates it to the View
// sets the shape as circle and starts animating the view

- (void)breathDied;
// EFFECTS: animates the breath to disperse in 0.7 seconds and then removes it
//          completely from its superview
//          clears the breath properties and its trace

- (void)reducePowerBy:(double)factor;
// EFFECTS: reduces the breath power by the given factor

- (void)stopTrace;
// EFFECTS: sets the trace property to NO

- (void)stopScroll;
// EFFECTS: sets the scroll property to NO

@end
