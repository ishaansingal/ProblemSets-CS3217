//
//  GameBlocks.h
//  Game
//
//  Created by Ishaan Singal on 29/1/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import "GameObject.h"
#import "Blocks.h"
@interface GameBlocks : GameObject

@property(readonly) NSArray* allBlocks;

- (id)initAllBlocksWithArray:(NSArray*)givenArray ;
  // REQUIRES: valid givenArray
  // EFFECTS: Initializes all the block models based on the objects in the givenArray
  // and initalizes the imageView of each block accordingly, Then sets this into the self.allBlocks
@end
