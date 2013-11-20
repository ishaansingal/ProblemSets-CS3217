//
//  GamePig.m
//  Game
//
//  Created by Ishaan Singal on 29/1/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import "GamePig.h"

@interface GamePig ()
@property(readwrite) GameModel *modelObj;
@end

@implementation GamePig

- (id)initWithPig:(GameModel *)givenModelObj {
    // REQUIRES: valid givenModelObj
    // EFFECTS: Construts a GameObject based on the properties of givenModelObj,
    // and initializes the view as a pig, and updates it to the View
    self.modelObj = givenModelObj;
    UIImage* pigImage = [UIImage imageNamed:kPigImageName];
    self = [super initWithImage:pigImage ObjectType: kGameObjectPig];
    self.view.frame = [self.modelObj dimensions];
    [self.modelObj setDelegate: self];
    [self.view setTransform:CGAffineTransformRotate(self.view.transform, givenModelObj.rotation)];
    [self.view setTransform:CGAffineTransformScale(self.view.transform, givenModelObj.imageScale, givenModelObj.imageScale)];
    [self setAllGestures];
    return self;
}


- (void)translate:(UIGestureRecognizer *)gesture {
    // MODIFIES: object model (coordinates)
    // REQUIRES: game in designer mode
    // EFFECTS: the user drags around the object with one finger
    //          if the object is in the palette, it will be moved in the game area
    UIView* paletteView = [gesture.view.superview.superview viewWithTag:2];
    bool isInPalette = (self.modelObj.currentState == kInPalette)? YES: NO;
    bool hasTranslatedInGameArea = (self.modelObj.imageOrigin.y > paletteView.frame.size.height)? YES: NO;

    if ( isInPalette && hasTranslatedInGameArea) {
        UIScrollView* gameareaView = (UIScrollView*)[gesture.view.superview.superview viewWithTag:1];
        CGPoint scrollOffset = gameareaView.contentOffset ;
        [self.modelObj setSize:CGSizeMake(kDefaultPigWidth, kDefaultPigHeight)];
        //set new frame properties
        self.view.frame = [self.modelObj dimensions];
        [gameareaView addSubview:self.view];
        [self.modelObj setGameState: kInGame];
        //translate right based on the existing scroll
        [self.modelObj translateByPoint:CGPointMake(scrollOffset.x, -paletteView.frame.size.height)];
        return;
    }
    [super translate:gesture];
    
    //if after translation, the item still in palette,
    //then load it back to its original palette position
    if ([gesture state]==UIGestureRecognizerStateEnded) {
        if (self.modelObj.currentState == kInPalette) {
            [self.modelObj setOrigin:CGPointMake(kPalettePigOriginX, kPalettePigOriginY)];
            [self.modelObj translateByPoint:CGPointMake(0, 0)];
        }
    }

}

- (void)reset:(UIGestureRecognizer *)gesture {
    // MODIFIES: object model (size, rotation, scale)
    // REQUIRES: game in deisginer mode
    // EFFECTS: the object is defaulted back to the palette and its palette properties retained
    if (self.modelObj.currentState == kInGame) {
        [self.modelObj setGameState:kInPalette];
        UIView* paletteView = [gesture.view.superview.superview viewWithTag:2];
        UIScrollView* gameArea = (UIScrollView*)[gesture.view.superview.superview viewWithTag:1];
        //translate for the animations (relative for scrollview)
        [self.modelObj translateByPoint:CGPointMake(- gameArea.contentOffset.x, paletteView.frame.size.height)];
        [self.modelObj setOrigin:CGPointMake(kPalettePigOriginX, kPalettePigOriginY) ];
        [self.modelObj setSize:CGSizeMake(kPalettePigWidth, kPalettePigHeight)];
        [paletteView addSubview:self.view];
        
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.3];
        [self.modelObj scale:1];
        [self.modelObj rotate:0];
        self.view.frame = [self.modelObj dimensions];
        [UIView commitAnimations];
    }
}

- (void)pigDied {
    // REQUIRES: modelObj.expired == YES
    // EFFECTS: animates the pig as die (blows it into smoke)
    assert(self.modelObj.expired == YES);
    UIView *gamearea = self.view.superview;
    
    NSArray *pigExpiredImages = [Utilities getAnimationImages:kPigDiedSmokeImagesName ColumnNum:5 RowNum:2];
    UIImageView *currentImageView = [[UIImageView alloc]initWithImage:pigExpiredImages.lastObject];
    currentImageView.frame = self.view.frame;
    [currentImageView setAnimationDuration:2];
    [currentImageView setAnimationImages:pigExpiredImages];
    currentImageView.animationRepeatCount = 1;
    [currentImageView startAnimating];
    [gamearea addSubview:currentImageView];
    
    [self.view setHidden:YES];
}

- (void)pigCry {
    // EFFECTS: changes the image of the wolf to wolfcry
    self.view = [[UIImageView alloc] initWithImage:[UIImage imageNamed:kPigCryImageName]];
    self.view.frame = [self.modelObj dimensions];
    CGAffineTransform newTransform = CGAffineTransformScale(CGAffineTransformIdentity, self.modelObj.imageScale, self.modelObj.imageScale);
    [self.view setTransform: newTransform];
    newTransform = CGAffineTransformRotate(self.view.transform, self.modelObj.rotation);
    [self.view setTransform: newTransform];
    
}

//- (void)resetDesignerMode {
//    [self setAllGestures];
//    self.view = [[UIImageView alloc] initWithImage:[UIImage imageNamed:kPigImageName]];
//    self.view.frame = [self.modelObj dimensions];
//    [self.view setHidden:NO];
//    [super resetDesignerMode];
//
//}


- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

@end
