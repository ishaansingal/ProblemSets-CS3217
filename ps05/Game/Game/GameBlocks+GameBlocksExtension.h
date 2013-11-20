/* 
 The extension file of GameBlocks class, which handles the operations on the
 array of block models (Retrieval, deletion etc)
 At each index of the array the dictionary contains two keys:
 - block (the block model)
 - blockImage (the corresponding image of the model)
*/
#import "GameBlocks.h"

@interface GameBlocks (GameBlocksExtension)

- (NSArray*)makeNewGameBlock:(Blocks *)currentBlock withView:(UIImageView *)currentBlockView;
- (NSArray*)insertNewGameBlock:(Blocks *)currentBlock withView:(UIImageView *)currentBlockView;
- (NSArray*)deleteBlockFromCollection:(int)blockId;

- (NSDictionary*)getBlockDictFromArrayWithView:(UIImageView*) givenView;
- (NSDictionary*)getBlockDictFromBlockId:(int)blockId;
- (Blocks*)getBlockFromArrayWithView:(UIImageView*) givenView;

- (int)largestBlockId;

@end
