
/*
 The subclass of GameObject that handles all the interactions with blocks
 It contains an Array that contains all the Block objects
 At every element of the array, there is a Dictionary that contains the Block object 
 (key - @"block) and its corresponding view (key - @"blockImage).
 Hence, if the allBlocks array contains 3 items, there are three block objects in view
 and they can be accessed by reading the key at each index.
 Also, each block is given a blockId so that it can be identified when it sends a
 delegate to this class. The blockId is an integer number starting from 1 onwards 
 and must be unique.
 The GameModel *modelObj is used a temporary game model object, that is set based on
 block selected. This is done so that this class can use the super class' methods.
 The super class performs actions on self.modelObj and hence the 'modelObj' is set as
 the selected block.
 
 It has extension that aids in maintaining this array of blocks
 */

#import "GameObject.h"
#import "Blocks.h"
@interface GameBlocks : GameObject

@property(readonly) NSArray* allBlocks;

- (id)initAllBlocksWithArray:(NSArray*)givenArray;
  // REQUIRES: valid givenArray
  // EFFECTS: Initializes all the block models based on the objects in the givenArray
  // and initalizes the imageView of each block accordingly, Then sets this into the self.allBlocks

- (void)removeBlockWithId:(int)blockId;
  // REQUIRES: a valid blockID (should be present in the array)
  // EFFECTS: deletes the given block from the array and the view

- (UIImageView*)getPaletteView;
  // EFFECTS: returns the imageView of the block that is in the palette

@end
