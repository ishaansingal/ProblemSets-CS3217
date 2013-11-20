/*
The model class that stores the necessary information about the objects 
 The attributes arent kept as readonly as the physics engine is given the ability
 to modify
 */

#import <Foundation/Foundation.h>
#import "Vector2D.h"
#import "Matrix2D.h"
#import "ModelModifyProtocol.h"

typedef enum {kRect, kCircle} ShapeType;

@interface PhysicsModel : NSObject
@property CGFloat mass;
@property (readonly) CGFloat inertia;
@property CGSize size;
@property (readonly) CGPoint center;
@property (readonly) CGFloat rotation;
@property (readonly) Matrix2D *rotationMatrix;
@property Vector2D* velocity;
@property CGFloat angVelocity;
@property CGFloat fritionCoeff;
@property CGFloat coeffRes;
@property Vector2D* totalForce;
@property double torque;
@property ShapeType shape;
@property (weak, readonly) id<ModelModifyProtocol> modelDelegate;


//REQUIRES: Valid values for all the parameters (positive Size and mass, friction
// and coeff of restitution between 0 to 1 
- (id)initWithMass:(CGFloat)m
              Size:(CGSize)s
            Center:(CGPoint)center
          Rotation:(CGFloat)rotAngle;

- (id)initWithMass:(CGFloat)m
              Size:(CGSize)s
            Center:(CGPoint)center
          Rotation:(CGFloat)rotAngle
          Friction:(CGFloat)fric
       Restitution:(CGFloat)rest;

- (id)initWithMass:(CGFloat)m
              Size:(CGSize)s
            Center:(CGPoint)center
          Rotation:(CGFloat)rotAngle
          Velocity:(Vector2D*)v
        AngularVel:(CGFloat)angV
          Friction:(CGFloat)fric
       Restitution:(CGFloat)rest;

- (void)setDelegate:(id)sender;
- (void)center:(CGPoint)center;
- (void)rotate:(CGFloat)rotation;
@end
