//
//  Blocks.m
//  Game
//
//  Created by Ishaan Singal on 29/1/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import "Blocks.h"
@interface Blocks ()
@property(readwrite) BlockType blockType;
@property(readwrite) int blockId;
@property(readwrite) CGPoint imageOrigin;
@property(readwrite) CGFloat rotation;
@property(readwrite) CGFloat imageScale;
@end


@implementation Blocks

- (id)initWithSize:(CGSize)size Origin:(CGPoint)origin State:(int)state TypeOfBlock:(BlockType)givenBlockType Id:(int)blockID{
    return [[Blocks alloc]initWithSize:size Origin:origin Rotation:0 State:state TypeOfBlock: givenBlockType Id: blockID];
}

- (id)initWithSize:(CGSize)size Origin:(CGPoint)origin Rotation:(CGFloat)r State:(int)state TypeOfBlock:(BlockType)givenBlockType Id:(int)blockID {
    self = [super initWithSize:size Origin:origin Rotation:r State:state];
    if (self) {
        [self setBlockType:givenBlockType];
        _blockType = givenBlockType;
        _blockId = blockID;
    }
    return self;
}

- (void)rotate:(CGFloat)rotation {
    self.rotation = rotation;
    [self.modelDelegate didRotateBlock:self.blockId];
}

- (void)scale:(CGFloat)scale {
    [self.modelDelegate didScaleBlock:self.blockId ScaleChange:scale];
    self.imageScale = self.imageScale * scale;
}

- (void)translateByPoint:(CGPoint)translation {
    CGPoint currentOrigin = self.imageOrigin;
    currentOrigin.x += translation.x;
    currentOrigin.y +=translation.y;
    self.imageOrigin = currentOrigin;
    [self.modelDelegate didTranslateBlock:self.blockId];
}

- (void)setCurrentBlockType:(BlockType)blockType {
    _blockType = blockType;
    switch (blockType) {
        case kStraw:
            [self setMass:0.5 Friction:0.1 Restitution:0.8];
            break;
        case kWood:
            [self setMass:8 Friction:0.5 Restitution:0.5];
            break;
        case kStone:
            [self setMass:20 Friction:0.7 Restitution:0.2];
            break;
        case kIron:
            [self setMass:40 Friction:1 Restitution:0];
            break;
        default:
            break;
    }
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [super encodeWithCoder:encoder];
    [encoder encodeInt:self.blockType forKey:@"type"];
    [encoder encodeInt:self.blockId forKey:@"ID"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if (self = [super initWithCoder:decoder]) {
        _blockType = (BlockType)[decoder decodeIntForKey:@"type"];
        _blockId = [decoder decodeIntForKey:@"ID"];
    }
    return self;
}

@end
