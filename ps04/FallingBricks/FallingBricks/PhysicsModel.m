//
//  PhysicsModel.m
//  FallingBricks
//
//  Created by Ishaan Singal on 8/2/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.

#import "PhysicsModel.h"
@interface PhysicsModel ()
@property (readwrite) CGPoint center;
@property (readwrite) CGFloat rotation;
@property (weak, readwrite) id<ModelModifyProtocol> modelDelegate;
@end

@implementation PhysicsModel

- (id)initWithMass:(CGFloat)m
              Size:(CGSize)s
            Center:(CGPoint)center
          Rotation:(CGFloat)rotAngle {
    self = [super init];
    if (self) {
        return [self initWithMass:m Size:s Center:center Rotation:rotAngle Velocity:[Vector2D vectorWith:0 y:0]
                       AngularVel:0 Friction:0.2 Restitution:0.5];
    }
    return self;
   
}

- (id)initWithMass:(CGFloat)m
              Size:(CGSize)s
            Center:(CGPoint)center
          Rotation:(CGFloat)rotAngle
          Friction:(CGFloat)fric
       Restitution:(CGFloat)rest {
    self = [super init];
    if (self) {
        return [self initWithMass:m Size:s Center:center Rotation:rotAngle Velocity:[Vector2D vectorWith:0 y:0]
                       AngularVel:0 Friction:fric Restitution:rest];
    }
    return self;
    
}

- (id)initWithMass:(CGFloat)m
              Size:(CGSize)s
            Center:(CGPoint)center
          Rotation:(CGFloat)rotAngle
          Velocity:(Vector2D*)v
        AngularVel:(CGFloat)angV
          Friction:(CGFloat)fric
       Restitution:(CGFloat)rest {
    self = [super init];
    if (self) {
        _mass = m;
        _size = s;
        _center = center;
        _velocity = v;
        _angVelocity = angV;
        _totalForce = [Vector2D vectorWith:0 y:0];
        _fritionCoeff = fric;
        _torque = 0;//torque is not being used for this assignment
        _coeffRes = rest;
        _rotation = rotAngle;
        _shape = kRect;
    }
    return self;
}

- (CGFloat)inertia {
    //based on the formula to calculate moment of inertia
    return (self.mass *(self.size.width * self.size.width + self.size.height * self.size.height))/12;
}

- (Matrix2D*) rotationMatrix {
    return [Matrix2D initRotationMatrix:self.rotation];
}

//sends the delegate when the center is modified
- (void)center:(CGPoint)center {
    self.center = center;
    [self.modelDelegate didMove:self];
}

//sends the delegate when the object is rotated
- (void)rotate:(CGFloat)rotation {
    self.rotation = rotation;
    [self.modelDelegate didRotate:self];
}

- (void)setDelegate:(id)sender {
    self.modelDelegate = sender;
    return;
}

@end
