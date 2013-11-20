/*
 GameModel stores the state of a single game object in the game.
It contains all the relevant details such as size of the object, origin, rotation
scale, its currentstate (in gamearea or in palette) and shape (Circle, Rectangle)
 Furthermode, it has properties for play mode like mass, velocity, frciont and restitution
It also sends delegates to the controller whenever its state attributes are
modified (origin, rotation, scale)
 It has a property impulse - which determines its 'health' (the amount of collision it has)
 and expired, to know if the object has expired during collision and should be removed
*/

#import <Foundation/Foundation.h>
#import "ModelModifyDelegate.h"
#import "Constants.h"
#import "Vector2D.h"

@interface GameModel : NSObject
@property(readonly) CGSize imageSize;
@property(readonly) CGPoint imageOrigin;
@property(readonly) CGFloat rotation;
@property(readonly) CGFloat imageScale;
@property(readonly) GameObjectState currentState;
@property(readonly) CGPoint center;

@property CGFloat mass;
@property(readonly) CGFloat inertia;
@property Vector2D* velocity;
@property CGFloat angVelocity;
@property CGFloat fritionCoeff;
@property CGFloat coeffRes;
@property Vector2D* totalForce;
@property CGFloat impulse;
@property BOOL expired;

@property(weak, readonly) id<ModelModifyDelegate> modelDelegate;
@property ShapeType shape;

- (id)initWithSize:(CGSize)size Origin:(CGPoint)origin State:(int)state;
- (id)initWithSize:(CGSize)size Origin:(CGPoint)origin Rotation:(CGFloat)r State:(int)state;
- (void)setMass:(CGFloat)givenMass
       Velocity:(Vector2D *)vel
     AngularVel:(CGFloat)angVel
       Friction:(CGFloat)fricCoeff
    Restitution:(CGFloat)restCoeff;

- (void)setMass:(CGFloat)givenMass
       Friction:(CGFloat)fricCoeff
    Restitution:(CGFloat)restCoeff;

//returns the scaled size of this model (without rotation)
- (CGSize)size;

//sets the actual size )not the bounding box
- (void)setSize:(CGSize)size;

//sets the actual unrotated + unscaled origin (not the bounding box)
- (void)setOrigin:(CGPoint)origin;

//the amount of scale change
- (void)scale:(CGFloat)scale;

//the new rotation (raw from 0 and not rotation change)
- (void)rotate:(CGFloat)rotation;

//gives a rectangle with the origin and size of the model (not bounding box)
- (CGRect)dimensions;

//in palette or in gamearea
- (void)setGameState:(GameObjectState) state;

//the amount the model has translated by
- (void)translateByPoint:(CGPoint)translation;

//the delegate to inform about model modifications
- (void)setDelegate:(id)sender;

//encode and decode operations for reading/writing
- (id)initWithCoder:(NSCoder *)decoder;
- (void)encodeWithCoder:(NSCoder *)encoder;


@end
