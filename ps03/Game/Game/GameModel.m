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
    }
    return self;
}


- (CGPoint)center {
    // EFFECTS: returns the coordinates of the centre of mass for this
    // rectangle.
    CGPoint center;
    center.x=self.imageOrigin.x+self.imageSize.width/2;
    center.y=self.imageOrigin.y+self.imageSize.height/2;
    return center;
}

- (void)setSize:(CGSize)size {
    self.imageSize = size;
}

- (void)setOrigin:(CGPoint)origin {
    self.imageOrigin = origin;
}

- (void)scale:(CGFloat)scale {
    self.imageScale = scale;
    [self.modelDelegate didScale];
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
- (void)setSizeFromScale {
    CGFloat width = self.imageSize.width * self.imageScale;
    CGFloat height = self.imageSize.height * self.imageScale;
    self.imageSize = CGSizeMake(width, height);
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
}

- (id)initWithCoder:(NSCoder *)decoder {
    if (self = [super init]) {
        _imageOrigin = [decoder decodeCGPointForKey:@"origin"];
        _imageSize = [decoder decodeCGSizeForKey:@"size"];
        _imageScale = [decoder decodeFloatForKey:@"scale"];
        _rotation = [decoder decodeFloatForKey:@"rotation"];
        _currentState = [decoder decodeIntForKey:@"state"];
    }
    return self;
}

@end
