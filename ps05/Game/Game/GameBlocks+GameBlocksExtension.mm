//
//  GameBlocks+GameBlocksExtension.m
//  Game
//
//  Created by Ishaan Singal on 2/2/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import "GameBlocks+GameBlocksExtension.h"

@implementation GameBlocks (GameBlocksExtension)

#pragma mark - modify array
- (NSArray*)makeNewGameBlock:(Blocks*)currentBlock withView:(UIImageView*)currentBlockView{
    NSDictionary *currentBlockData = [NSDictionary dictionaryWithObjectsAndKeys:
                                      currentBlock, @"block",
                                      currentBlockView, @"blockImage",
                                      nil];
    
    return [[NSArray alloc] initWithObjects:currentBlockData, nil];
}

- (NSArray*)insertNewGameBlock:(Blocks*)currentBlock withView:(UIImageView*)currentBlockView{
    NSMutableArray* existingBlocks = [[NSMutableArray alloc]initWithArray:self.allBlocks];
    NSDictionary *currentBlockData = [NSDictionary dictionaryWithObjectsAndKeys:
                                      currentBlock, @"block",
                                      currentBlockView, @"blockImage",
                                      nil];
    [existingBlocks addObject:currentBlockData];
    return [[NSArray alloc] initWithArray:existingBlocks];
}

- (NSArray*)deleteBlockFromCollection:(int)blockId {
    NSMutableArray* existingBlocks = [[NSMutableArray alloc]initWithArray:self.allBlocks];
    NSDictionary* currentBlockDict = [self getBlockDictFromBlockId:blockId];
    [existingBlocks removeObject:currentBlockDict];
    return [[NSArray alloc]initWithArray:existingBlocks];
}


#pragma mark - Get Blocks
- (NSDictionary*)getBlockDictFromArrayWithView:(UIImageView*)givenView {
    for (int i = 0; i < (int)[self.allBlocks count]; i++) {
        NSDictionary* currentBlockDict = [self.allBlocks objectAtIndex:i];
        UIImageView* viewInArray = [currentBlockDict objectForKey:@"blockImage"];
        if ([viewInArray isEqual:givenView]) {
            return [self.allBlocks objectAtIndex:i];
        }
    }
    return [self.allBlocks objectAtIndex:0];
}

- (NSDictionary*)getBlockDictFromBlockId:(int)blockId {
    for (int i = 0; i < (int)[self.allBlocks count]; i++) {
        NSDictionary* block = [self.allBlocks objectAtIndex:i];
        Blocks* currentBlock = [block objectForKey:@"block"];
        if (blockId == currentBlock.blockId) {
            return block;
        }
    }
    return [[NSDictionary alloc]init];
}

- (Blocks*)getBlockFromArrayWithView:(UIImageView*)givenView {
    NSDictionary* currentBlockDict = [self getBlockDictFromArrayWithView:givenView];
    return [currentBlockDict objectForKey:@"block"];
}


#pragma mark - BlockId
- (int)largestBlockId {
    NSDictionary* block = [self.allBlocks objectAtIndex:[self.allBlocks count]-1];
    Blocks *currentBlock = [block objectForKey:@"block"];
    return currentBlock.blockId;
}

@end
