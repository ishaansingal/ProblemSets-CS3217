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
@property(readwrite) UIImageView* imageView;
@property(nonatomic, readwrite) GameObjectType objectType;

- (NSString*)getBlockImageNameFromType:(BlockType)blockType;
//EFFECTS: returns the imagename based on the blockType
- (void)changeBlock:(UIGestureRecognizer *)gesture;
//EFFECTS: the gesture recognizer for single tap, changes the image of the
// selected block according to the round robin
- (BlockType)getRoundRobinBlock:(Blocks*)currentBlock;
//EFFECTS: implements the round robin of the blocks
- (void)setModelObjAndImageView:(UIImageView*)givenView;
//EFFECTS: sets the imageView and modelObj property of the GameObj from the givenView
- (void)setModelObjAndImageViewFromId:(int)blockId;
//EFFECTS: sets the imageView and modelObj property of the GameObj from the blockId

@end

@implementation GameBlocks

- (id)initWithImage:(UIImage*)objectImage Origin:(CGPoint)origin Size:(CGSize)size ObjectType:(GameObjectType)type{
    // REQUIRES: valid data input for the all the parameters
    // EFFECTS: Construts a GameObject based on the properties, and initializes
    // the modelObj, the imageView, and updates it to the View
    self = [super initWithImage:objectImage ObjectType: type];
    self.modelObj = [[Blocks alloc] initWithSize:size Origin: origin State:0 TypeOfBlock: kStraw Id:0];
    self.imageView.frame = [self.modelObj dimensions];
    [super setAllGestures];
    [self.modelObj setDelegate:self];
    _allBlocks = [self makeNewGameBlock:(Blocks*)self.modelObj withView:self.imageView];
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
        self.imageView = [[UIImageView alloc]initWithImage:blockImage];
        if (currentBlock.currentState == kInGame) {
            self.imageView.frame = CGRectMake(0, 0, kDefaultBlockWidth, kDefaultBlockHeight);
        }
        else {
            self.imageView.frame = CGRectMake(0, 0, kPaletteBlockWidth, kPaletteBlockHeight);
        }
        [self.imageView setCenter:currentBlock.center];
        [super setAllGestures];
        [currentBlock setDelegate: self];
        _allBlocks = [self insertNewGameBlock:currentBlock withView:self.imageView];
    }
    
    //Took into account the scaling and rotation of each object
    for (int i = 0;i < (int)[_allBlocks count];i++) {
        NSDictionary* eachBlock = [_allBlocks objectAtIndex:i];
        self.modelObj = [eachBlock objectForKey:@"block"];
        [self.modelObj rotate:self.modelObj.rotation];
        [self.modelObj scale:self.modelObj.imageScale];
    }
    return self;
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

- (void)changeBlock:(UIGestureRecognizer *)gesture {
    //EFFECTS: the gesture recognizer for single tap, changes the image of the
    // selected block according to the round robin
    [self setModelObjAndImageView:(UIImageView*)gesture.view];
    Blocks *currentBlock = (Blocks*)self.modelObj;
    [currentBlock setCurrentBlockType:[self getRoundRobinBlock:currentBlock]];
    NSString* imageName = [self getBlockImageNameFromType:currentBlock.blockType];
    self.imageView.image = [UIImage imageNamed:imageName];
}

- (BlockType)getRoundRobinBlock:(Blocks*)currentBlock {
    //EFFECTS: implements the round robin of the blocks
    BlockType currentBlockType = currentBlock.blockType;
    currentBlockType = (currentBlockType)%4+1;
    return currentBlockType;
}

- (void)translate:(UIGestureRecognizer *)gesture {
    // MODIFIES: object model (coordinates)
    // REQUIRES: game in designer mode
    // EFFECTS: the user drags around the object with one finger
    //          if the object is in the palette, it will be moved in the game area
    UIPanGestureRecognizer* panGesture = (UIPanGestureRecognizer*)gesture;
    CGPoint translatedPoint = [panGesture translationInView: panGesture.view.superview.superview];
    [self setModelObjAndImageView:(UIImageView*)gesture.view];
    
    if (self.modelObj.currentState == kInPalette) {
        //drag the existing block from the palette to the game area and replace it with another fresh block
        Blocks* newBlock = [[Blocks alloc] initWithSize:CGSizeMake(kPaletteBlockWidth, kPaletteBlockHeight)
                                                 Origin:CGPointMake(kPaletteBlockOriginX, kPaletteBlockOriginY)
                                                  State:0
                                            TypeOfBlock:kStraw
                                                     Id:[self largestBlockId]+1];
        
        UIImage* paletteStrawImage = [UIImage imageNamed:kStrawImageName];
        UIImageView* newBlockImageView = [[UIImageView alloc]initWithImage:paletteStrawImage];
        newBlockImageView.frame = [newBlock dimensions];
        UIView* paletteArea = panGesture.view.superview;
        [paletteArea addSubview:newBlockImageView];
        [super setAllGesturesForUIImageView:newBlockImageView];
        [newBlock setDelegate: self];
        _allBlocks = [self insertNewGameBlock:newBlock withView:newBlockImageView];
        
        [self.modelObj setSize:CGSizeMake(kDefaultBlockWidth, kDefaultBlockHeight)];
        CGPoint newOrigin;
        newOrigin.x = translatedPoint.x + self.modelObj.imageOrigin.x;
        newOrigin.y = translatedPoint.y + self.modelObj.imageOrigin.y;
        [self.modelObj setOrigin:CGPointMake(newOrigin.x, newOrigin.y)];
        self.imageView.frame = [self.modelObj dimensions];
        UIView* gameArea = [panGesture.view.superview.superview viewWithTag:1];
        [gameArea addSubview:self.imageView];
        [self.modelObj setGameState:kInGame];
        return;
    }
    [super translate:gesture];
}

- (void)rotate:(UIGestureRecognizer *)gesture {
    // MODIFIES: object model (rotation)
    // REQUIRES: game in designer mode, object in game area
    // EFFECTS: the object is rotated with a two-finger rotation gesture
    [self setModelObjAndImageView:(UIImageView*)gesture.view];
    [super rotate:gesture];
    
}


- (void)zoom:(UIGestureRecognizer *)gesture {
    // MODIFIES: object model (size)
    // REQUIRES: game in designer mode, object in game area
    // EFFECTS: the object is scaled up/down with a pinch gesture
    [self setModelObjAndImageView:(UIImageView*)gesture.view];
    [super zoom:gesture];
}


- (void)reset:(UIGestureRecognizer *)gesture {
    [self setModelObjAndImageView:(UIImageView*)gesture.view];
    
    if (self.modelObj.currentState == kInGame) {
        [self.imageView removeFromSuperview];
        _allBlocks = [self deleteBlockFromCollection:((Blocks*)self.modelObj).blockId];
    }
}

- (void)removeGameObj {
    int count = (int)[self.allBlocks count];
    for (int i = 0; i < count; i++) {
        NSDictionary* block = [self.allBlocks objectAtIndex:i];
        self.modelObj = [block objectForKey:@"block"];
        self.imageView = [block objectForKey:@"blockImage"];
        [self.imageView removeFromSuperview];
        _allBlocks = [self deleteBlockFromCollection:((Blocks*)self.modelObj).blockId];
        i--;
        count--;
    }
}

- (void)didTranslateBlock:(int)blockId {
    //REQUIRES: the center property of the modelObj to be valid
    //EFFECTS: updates the imageView's centre point based on the modelObjs center property
    [self setModelObjAndImageViewFromId:blockId];
    [super didTranslate];
    return;
}

- (void)didRotateBlock:(int)blockId {
    //REQUIRES: the rotation property of the modelObj to be valid
    //EFFECTS: rotates the imageView based on the modelObjs rotation property
    [self setModelObjAndImageViewFromId:blockId];
    [super didRotate];
    
    return;
}

- (void)didScaleBlock:(int)blockId {
    //REQUIRES: the scale property of the modelObj to be valid
    //EFFECTS: resizes the imageView based on the modelObjs scale property
    [self setModelObjAndImageViewFromId:blockId];
    [super didScale];
}

- (void)setModelObjAndImageView:(UIImageView*)givenView {
    //EFFECTS: sets the imageView and modelObj property of the GameObj from the givenView
    self.imageView = givenView;
    self.modelObj = [self getBlockFromArrayWithView:self.imageView];
    return;
}

- (void)setModelObjAndImageViewFromId:(int)blockId {
    //EFFECTS: sets the imageView and modelObj property of the GameObj from the blockId
    NSDictionary* selectedBlock = [self getBlockDictFromBlockId:blockId];
    self.modelObj = (Blocks*)[selectedBlock objectForKey:@"block"];
    self.imageView = (UIImageView*)[selectedBlock objectForKey:@"blockImage"];
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
