//
//  GameBlocks.m
//  Game
//
//  Created by Ishaan Singal on 29/1/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import "GameBlocks.h"
#import "GameBlocks+GameBlocksExtension.h"
@interface GameBlocks ()
@property(readwrite) GameModel* modelObj;
@property(readwrite) NSArray* allBlocks;
@property(nonatomic, readwrite) GameObjectType objectType;

- (NSString*)getBlockImageNameFromType:(BlockType)blockType;
//EFFECTS: returns the imagename based on the blockType
- (void)changeBlock:(UIGestureRecognizer *)gesture;
//EFFECTS: the gesture recognizer for single tap, changes the image of the
// selected block according to the round robin
- (BlockType)getRoundRobinBlock:(Blocks*)currentBlock;
//EFFECTS: implements the round robin of the blocks
- (void)setModelObjFromImageView:(UIView*)givenView;
//EFFECTS: sets the imageView and modelObj property of the GameObj from the givenView
- (NSDictionary*)getModelObjAndImageViewFromId:(int)blockId;
//EFFECTS: sets the imageView and modelObj property of the GameObj from the blockId

@end

@implementation GameBlocks

#pragma mark - Initializations
- (id)initWithImage:(UIImage*)objectImage Origin:(CGPoint)origin Size:(CGSize)size ObjectType:(GameObjectType)type{
    // REQUIRES: valid data input for the all the parameters
    // EFFECTS: Construts a GameObject based on the properties, and initializes
    // the modelObj, the imageView, and updates it to the View
    UIImageView *currentBlockView = [[UIImageView alloc]initWithImage:objectImage];
    self.objectType = type;
    self.modelObj = [[Blocks alloc] initWithSize:size Origin:origin State:0 TypeOfBlock:kStraw Id:0];
    currentBlockView.frame = [self.modelObj dimensions];
    [super setAllGesturesForUIImageView:currentBlockView];
    [self.modelObj setDelegate:self];
    _allBlocks = [self makeNewGameBlock:(Blocks*)self.modelObj withView:currentBlockView];
    return self;
}

- (id)initWithImage:(UIImage*)objectImage
             Origin:(CGPoint)origin
               Size:(CGSize)size
         ObjectType:(GameObjectType)type
               Mass:(CGFloat)mass
         FrictCoeff:(CGFloat)coeffFric
          restCoeff:(CGFloat)restCoeff{
    self = [self initWithImage:objectImage Origin:origin Size:size ObjectType:type];
    [self.modelObj setMass:mass Friction:coeffFric Restitution:restCoeff];
    return self;    
}


- (id)initAllBlocksWithArray:(NSArray*)givenArray {
    // REQUIRES: valid givenArray
    // EFFECTS: Initializes all the block models based on the objects in the givenArray
    // and initalizes the imageView of each block accordingly, Then sets this into the self.allBlocks
    
    self.objectType = kGameObjectBlock;
    //Add all the elements decoded from archiver and add in the allBlocks property
    for (NSDictionary* eachBlock in givenArray) {
        Blocks* currentBlock = [eachBlock objectForKey:@"block" ];
        NSString* thisBlockImage = [self getBlockImageNameFromType:currentBlock.blockType];
        UIImage* blockImage = [UIImage imageNamed:thisBlockImage];
        UIImageView *thisBlockView = [[UIImageView alloc]initWithImage:blockImage];
        thisBlockView.frame = [currentBlock dimensions];
        [super setAllGesturesForUIImageView:thisBlockView];
        [currentBlock setDelegate: self];
        _allBlocks = [self insertNewGameBlock:currentBlock withView:thisBlockView];
    }
    
    //Took into account the scaling and rotation of each object
    for (int i = 0;i < (int)[_allBlocks count];i++) {
        NSDictionary* eachBlock = [_allBlocks objectAtIndex:i];
        self.modelObj = [eachBlock objectForKey:@"block"];
        UIImageView *currentImageView = [eachBlock objectForKey:@"blockImage"];
        [currentImageView setTransform:CGAffineTransformRotate(currentImageView.transform, self.modelObj.rotation)];
        [currentImageView setTransform:CGAffineTransformScale(currentImageView.transform, self.modelObj.imageScale, self.modelObj.imageScale)];
    }
    return self;
}

#pragma mark - Gesture Delegates
- (void)changeBlock:(UIGestureRecognizer *)gesture {
    //EFFECTS: the gesture recognizer for single tap, changes the image of the
    // selected block according to the round robin
    [self setModelObjFromImageView:gesture.view];
    Blocks *currentBlock = (Blocks*)self.modelObj;
    [currentBlock setCurrentBlockType:[self getRoundRobinBlock:currentBlock]];
    NSString* imageName = [self getBlockImageNameFromType:currentBlock.blockType];
    [(UIImageView*)gesture.view setImage:[UIImage imageNamed:imageName]];
}

- (void)translate:(UIGestureRecognizer *)gesture {
    // MODIFIES: object model (coordinates)
    // REQUIRES: game in designer mode
    // EFFECTS: the user drags around the object with one finger
    //          if the object is in the palette, it will be moved in the game area
    [self setModelObjFromImageView:(UIImageView*)gesture.view];

    if ([gesture state]==UIGestureRecognizerStateBegan) {
        //if the object is in the palette, create another block right underneath it
        if (self.modelObj.currentState == kInPalette) {
            Blocks* newBlock = [[Blocks alloc] initWithSize:CGSizeMake(kPaletteBlockWidth, kPaletteBlockHeight)
                                                     Origin:CGPointMake(kPaletteBlockOriginX, kPaletteBlockOriginY)
                                                      State:0
                                                TypeOfBlock:kStraw
                                                         Id:[self largestBlockId]+1];
            
            UIImage* paletteStrawImage = [UIImage imageNamed:kStrawImageName];
            UIImageView* newBlockImageView = [[UIImageView alloc]initWithImage:paletteStrawImage];
            newBlockImageView.frame = [newBlock dimensions];
            UIView* paletteArea = gesture.view.superview;
            [paletteArea addSubview:newBlockImageView];
            [super setAllGesturesForUIImageView:newBlockImageView];
            [newBlock setDelegate: self];
            _allBlocks = [self insertNewGameBlock:newBlock withView:newBlockImageView];
        }
    }    
    bool isInPalette = (self.modelObj.currentState == kInPalette)? YES: NO;
    bool hasTranslatedInGameArea = (self.modelObj.imageOrigin.y > kPaletteHeight)? YES: NO;
    //if the block has just transitioned in the gamearea, add it in the gamearea
    //and set its size
    if (isInPalette && hasTranslatedInGameArea) {
        //drag the existing block from the palette to the game area and replace it with another fresh block
        [self.modelObj setGameState:kInGame];        
        [self.modelObj setSize:CGSizeMake(kDefaultBlockWidth, kDefaultBlockHeight)];
        gesture.view.frame = [self.modelObj dimensions];
        UIScrollView* gameareaView = (UIScrollView*)[gesture.view.superview.superview viewWithTag:1];
        CGPoint scrollOffset = gameareaView.contentOffset ;
        [gameareaView addSubview:gesture.view];
        [self.modelObj translateByPoint:CGPointMake(scrollOffset.x, -kPaletteHeight)];

        return;
    }
    [super translate:gesture];
    
    //if the block is still in the palette, delete it (As another block is not placed underneath it
    if ([gesture state]==UIGestureRecognizerStateEnded) {
        if (self.modelObj.currentState == kInPalette) {
            [gesture.view removeFromSuperview];
            _allBlocks = [self deleteBlockFromCollection:((Blocks*)self.modelObj).blockId];
        }
    }
}

- (void)rotate:(UIGestureRecognizer *)gesture {
    // MODIFIES: object model (rotation)
    // REQUIRES: game in designer mode, object in game area
    // EFFECTS: the object is rotated with a two-finger rotation gesture
    [self setModelObjFromImageView:(UIImageView*)gesture.view];
    [super rotate:gesture];
    
}


- (void)zoom:(UIGestureRecognizer *)gesture {
    // MODIFIES: object model (size)
    // REQUIRES: game in designer mode, object in game area
    // EFFECTS: the object is scaled up/down with a pinch gesture
    [self setModelObjFromImageView:(UIImageView*)gesture.view];
    [super zoom:gesture];
}


- (void)reset:(UIGestureRecognizer *)gesture {
    // EFFECTS: deletes the block and its view
    [self setModelObjFromImageView:(UIImageView*)gesture.view];
    
    if (self.modelObj.currentState == kInGame) {
        [gesture.view removeFromSuperview];
        _allBlocks = [self deleteBlockFromCollection:((Blocks*)self.modelObj).blockId];
    }
}

#pragma mark - Model Delegates
- (void)didTranslateBlock:(int)blockId {
    //REQUIRES: the center property of the modelObj to be valid
    //EFFECTS: updates the imageView's centre point based on the modelObjs center property
    NSDictionary *currentBlock = [self getModelObjAndImageViewFromId:blockId];
    UIImageView *currentBlockImageView = [currentBlock objectForKey:@"blockImage"];
    Blocks *currentBlockModel = [currentBlock objectForKey:@"block"];
    [currentBlockImageView setCenter: currentBlockModel.center];
    return;
}

- (void)didRotateBlock:(int)blockId {
    //REQUIRES: the rotation property of the modelObj to be valid
    //EFFECTS: rotates the imageView based on the modelObjs rotation property
    NSDictionary *currentBlock = [self getModelObjAndImageViewFromId:blockId];
    UIImageView *currentBlockImageView = [currentBlock objectForKey:@"blockImage"];
    Blocks *currentBlockModel = [currentBlock objectForKey:@"block"];

    CGFloat currentRot = [[currentBlockImageView.layer valueForKeyPath:@"transform.rotation"] floatValue];
    currentRot = currentBlockModel.rotation - currentRot;
    CGAffineTransform currentTransform = currentBlockImageView.transform;
    CGAffineTransform newTransform = CGAffineTransformRotate(currentTransform, currentRot);
    [currentBlockImageView setTransform:newTransform];
    
    return;
}

- (void)didScaleBlock:(int)blockId ScaleChange:(CGFloat)scaleCh{
    //REQUIRES: the scale property of the modelObj to be valid
    //EFFECTS: resizes the imageView based on the modelObjs scale property
    NSDictionary *currentBlock = [self getModelObjAndImageViewFromId:blockId];
    UIImageView *currentBlockImageView = [currentBlock objectForKey:@"blockImage"];
    CGAffineTransform newTransform = CGAffineTransformScale(currentBlockImageView.transform, scaleCh, scaleCh);
    [currentBlockImageView setTransform: newTransform];
}

#pragma mark - Helper for Block Array
- (UIImageView*)getPaletteView {
    // EFFECTS: returns the imageView of the block that is in the palette
    NSDictionary* eachBlock = self.allBlocks.lastObject;
    UIImageView *currentImageView = [eachBlock objectForKey:@"blockImage"];
    return currentImageView;
}

- (NSString*)getBlockImageNameFromType:(BlockType)blockType {
    //EFFECTS: returns the imagename based on the blockType
    NSString* imageName;
    switch (blockType) {
        case kStone:
            imageName = kStoneImageName;
            break;
        case kWood:
            imageName = kWoodImageName;
            break;
        case kIron:
            imageName = kIronImageName;
            break;
        default:
            imageName = kStrawImageName;
            break;
    }
    return imageName;
}


- (BlockType)getRoundRobinBlock:(Blocks*)currentBlock {
    //EFFECTS: implements the round robin of the blocks
    BlockType currentBlockType = currentBlock.blockType;
    currentBlockType = (BlockType)((currentBlockType)%4+1);
    return currentBlockType;
}

- (void)setModelObjFromImageView:(UIImageView*)givenView {
    //EFFECTS: sets the imageView and modelObj property of the GameObj from the givenView
    self.modelObj = [self getBlockFromArrayWithView:givenView];
    return;
}

- (NSDictionary*)getModelObjAndImageViewFromId:(int)blockId {
    //EFFECTS: sets the imageView and modelObj property of the GameObj from the blockId
    NSDictionary* selectedBlock = [self getBlockDictFromBlockId:blockId];
    self.modelObj = [selectedBlock objectForKey:@"block"];
    return selectedBlock;
}

- (void)removeBlockWithId:(int)blockId {
    // REQUIRES: a valid blockID (should be present in the array)
    // EFFECTS: deletes the given block from the array and the view
    NSDictionary *currentBlock = [self getBlockDictFromBlockId:blockId];
    UIImageView *currentModelImageView = [currentBlock objectForKey:@"blockImage"];
    [currentModelImageView removeFromSuperview];
    _allBlocks = [self deleteBlockFromCollection:blockId];
}

#pragma mark - PlayMode & DesignerMode
- (void)setupStartMode {
    //EFFECTS: disables all the gestures on the blocks
    for (NSDictionary *eachBlock in self.allBlocks) {
        UIImageView *thisBlockImage = [eachBlock objectForKey:@"blockImage"];
        for (UIGestureRecognizer *recognizer in thisBlockImage.gestureRecognizers) {
            [thisBlockImage removeGestureRecognizer:recognizer];
        }
    }
    return;
}

//- (void)resetDesignerMode {
//    //EFFECTS: re-adds all the gestures on the blocks
//    for (NSDictionary *eachBlock in self.allBlocks) {
//        self.modelObj = [eachBlock objectForKey:@"block"];
//        UIImageView *thisBlockImage = [eachBlock objectForKey:@"blockImage"];
//        self.modelObj.impulse = 0;
//        self.modelObj.expired = NO;
//        [self.modelObj rotate:self.modelObj.rotation];
//        CGAffineTransform newTransform = CGAffineTransformScale(self.view.transform, self.modelObj.imageScale, self.modelObj.imageScale);
//        [self.view setTransform: newTransform];
//        [self setAllGesturesForUIImageView:thisBlockImage];
//    }
//}

- (void)removeGameObj {
    //EFFECTS: removes all the blocks from the view (and the array)
    int count = (int)[self.allBlocks count];
    for (int i = 0; i < count; i++) {
        NSDictionary* block = [self.allBlocks objectAtIndex:i];
        self.modelObj = [block objectForKey:@"block"];
        UIImageView *currentModelImageView = [block objectForKey:@"blockImage"];
        [currentModelImageView removeFromSuperview];
        _allBlocks = [self deleteBlockFromCollection:((Blocks*)self.modelObj).blockId];
        i--;
        count--;
    }
}

- (void)dealloc {
    for (NSDictionary *eachBlock in self.allBlocks) {
        UIImageView *thisBlockImage = [eachBlock objectForKey:@"blockImage"];
        [thisBlockImage removeFromSuperview];
    }
    return;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
