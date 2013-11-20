/*
 Blocks is the sublcass of GameModel, so it will inherit all the state properties
 from GameModel and will implement some methods related only to itself. 
 There are certain properties like BlockType (straw,stone etc) and blockId 
 (identity for different blocks) that is only relevant to the Blocks class 
 and not to wolf & Pig.
 Similarly, it employs its own initializers and delegates for the specific block.
 It should be noted that the delegates are similar to that of super class, but 
 it sends the blockId along the delegate too
 */

#import "GameModel.h"

@interface Blocks : GameModel

@property(readonly) BlockType blockType;
@property(readonly) int blockId;

- (id)initWithSize:(CGSize)size Origin:(CGPoint)origin State:(int)state TypeOfBlock:(BlockType)givenBlockType Id:(int)blockID;
- (id)initWithSize:(CGSize)size Origin:(CGPoint)origin Rotation:(CGFloat)r State:(int)state TypeOfBlock:(BlockType)givenBlockType Id:(int)blockID;

- (void)setCurrentBlockType:(BlockType)blockType;
- (id)initWithCoder:(NSCoder*)decoder;
- (void)encodeWithCoder:(NSCoder *)encoder;
- (void)rotate:(CGFloat)rotation;
- (void)scale:(CGFloat)scale;
- (void)translateByPoint:(CGPoint)translation;

@end
