/* 
 The extension file of GameBlocks class, which handles the operations on the
 array of block models (Retrieval, deletion etc)
*/
#import "GameBlocks.h"

@interface GameBlocks (GameBlocksExtension)

- (NSArray*)makeNewGameBlock:(Blocks *)currentBlock withView:(UIImageView *)currentBlockView;
- (NSArray*)insertNewGameBlock:(Blocks *)currentBlock withView:(UIImageView *)currentBlockView;

- (NSDictionary*)getBlockDictFromArrayWithView:(UIImageView*) givenView;
- (NSDictionary*)getBlockDictFromBlockId:(int)blockId;
- (Blocks*)getBlockFromArrayWithView:(UIImageView*) givenView;

- (NSArray*)deleteBlockFromCollection:(int)blockId;
- (int)largestBlockId;

@end
