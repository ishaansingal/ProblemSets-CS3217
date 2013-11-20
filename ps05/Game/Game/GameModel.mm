//
//  GameModel.m
//  Game
//
//  Created by Ishaan Singal on 3/2/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import "GameModel.h"

@interface GameModel ()
@property(readwrite) CGSize imageSize;
@property(readwrite) CGPoint imageOrigin;
@property(readwrite) CGFloat rotation;
@property(readwrite) CGFloat imageScale;
@property(readwrite) GameObjectState currentState;
@property(weak, readwrite) id<ModelModifyDelegate> modelDelegate;

@end

@implementation GameModel

- (id)initWithSize:(CGSize)size Origin:(CGPoint)origin State:(int)state{
    return [[GameModel alloc]initWithSize:size Origin:origin Rotation:0 State:state];
}

- (id)initWithSize:(CGSize)size Origin:(CGPoint)origin Rotation:(CGFloat)r State:(int)state {
    self = [super init];
    if (self) {
        _imageSize = size;
        _imageOrigin = origin;
        _rotation = r;
        _imageScale = 1;
        if (state == 0) {
            _currentState = kInPalette;
        }
        else if (state == 1) {
            _currentState = kInGame;
        }
        _shape = kRect;
        _velocity = [Vector2D vectorWith:0 y:0];
        _angVelocity = 0;
        _fritionCoeff = 0.1;
        _coeffRes = 0.2;
        _mass = 10;
        _totalForce = [Vector2D vectorWith:0 y:0];
        _impulse = 0;
        _expired = NO;
    }
    return self;
}

- (void)setMass:(CGFloat)givenMass
       Friction:(CGFloat)fricCoeff
    Restitution:(CGFloat)restCoeff {
    [self setMass:givenMass Velocity:self.velocity AngularVel:self.angVelocity Friction:fricCoeff Restitution:restCoeff];
}

- (void)setMass:(CGFloat)givenMass
       Velocity:(Vector2D *)vel
     AngularVel:(CGFloat)angVel
       Friction:(CGFloat)fricCoeff
    Restitution:(CGFloat)restCoeff {
    self.mass = givenMass;
    self.velocity = vel;
    self.angVelocity = angVel;
    self.fritionCoeff = fricCoeff;
    self.coeffRes = restCoeff;
}

- (CGFloat)inertia {
    //based on the formula to calculate moment of inertia
    return (self.mass *(self.size.width * self.size.width + self.size.height * self.size.height))/12;
}


- (CGPoint)center {
    // EFFECTS: returns the coordinates of the centre of mass for this
    // rectangle.
    CGPoint center;
    center.x=self.imageOrigin.x+self.imageSize.width/2;
    center.y=self.imageOrigin.y+self.imageSize.height/2;
    return center;
}

- (CGSize)size {
    return CGSizeMake(self.imageSize.width * self.imageScale, self.imageSize.height * self.imageScale);
}

- (void)setSize:(CGSize)size {
    self.imageSize = size;
}

- (void)setOrigin:(CGPoint)origin {
    self.imageOrigin = origin;
}

- (void)scale:(CGFloat)scale {
    //send the change in scale to the delegate method
    [self.modelDelegate didScale:scale];
    self.imageScale = scale * self.imageScale;
}

- (void)rotate:(CGFloat)rotation {
    self.rotation = rotation;
    [self.modelDelegate didRotate];
    
}

- (CGRect)dimensions {
    CGRect result;
    result.origin = self.imageOrigin;
    result.size = self.imageSize;
    return result;
}

- (void)setGameState:(GameObjectState)state {
    self.currentState = state;
    return;
}

- (void)translateByPoint:(CGPoint)translation {
    CGPoint currentOrigin = self.imageOrigin;
    currentOrigin.x += translation.x;
    currentOrigin.y +=translation.y;
    self.imageOrigin = currentOrigin;
    [self.modelDelegate didTranslate];
    
}

- (void)setDelegate:(id)controller {
    _modelDelegate = controller;
}
- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeCGPoint:self.imageOrigin forKey:@"origin"];
    [encoder encodeCGSize:self.imageSize forKey:@"size"];
    [encoder encodeFloat:self.imageScale forKey:@"scale"];
    [encoder encodeFloat:self.rotation forKey:@"rotation"];
    [encoder encodeInt:self.currentState forKey:@"state"];
    [encoder encodeFloat:self.mass forKey:@"mass"];
    [encoder encodeFloat:self.fritionCoeff forKey:@"friction"];
    [encoder encodeFloat:self.coeffRes forKey:@"restitution"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if (self = [super init]) {
        _imageOrigin = [decoder decodeCGPointForKey:@"origin"];
        _imageSize = [decoder decodeCGSizeForKey:@"size"];
        _imageScale = [decoder decodeFloatForKey:@"scale"];
        _rotation = [decoder decodeFloatForKey:@"rotation"];
        _currentState = (GameObjectState)[decoder decodeIntForKey:@"state"];
        _mass = [decoder decodeFloatForKey:@"mass"];
        _fritionCoeff = [decoder decodeFloatForKey:@"friction"];
        _coeffRes = [decoder decodeFloatForKey:@"restitution"];
    }
    return self;
}

@end
