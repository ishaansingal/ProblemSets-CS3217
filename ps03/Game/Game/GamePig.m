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
    // and initializes the imageView as a pig, and updates it to the View
    self.modelObj = givenModelObj;
    UIImage* pigImage = [UIImage imageNamed:kPigImageName];
    self = [super initWithImage:pigImage ObjectType: kGameObjectPig];
    self.imageView.frame = CGRectMake(0, 0, kDefaultPigWidth, kDefaultPigHeight);
    [self.imageView setCenter:self.modelObj.center];
    [self.modelObj setDelegate: self];
    [self.modelObj rotate:givenModelObj.rotation];
    [self.modelObj scale:givenModelObj.imageScale];
    [self setAllGestures];
    return self;
}


- (void)translate:(UIGestureRecognizer *)gesture {
    // MODIFIES: object model (coordinates)
    // REQUIRES: game in designer mode
    // EFFECTS: the user drags around the object with one finger
    //          if the object is in the palette, it will be moved in the game area
    CGPoint translatedPoint =  [(UIPanGestureRecognizer*)gesture translationInView:self.imageView.superview ];
    if (self.modelObj.currentState == kInPalette) {
        [self.modelObj setSize:CGSizeMake(kDefaultPigWidth, kDefaultPigHeight)];
        CGPoint newOrigin;
        newOrigin.x = translatedPoint.x + self.modelObj.imageOrigin.x;
        newOrigin.y = translatedPoint.y + self.modelObj.imageOrigin.y;
        [self.modelObj setOrigin:CGPointMake(newOrigin.x, newOrigin.y)];
        self.imageView.frame = [self.modelObj dimensions];
        UIView* originalView = [gesture.view.superview.superview viewWithTag:1];
        [originalView addSubview:self.imageView];
        [self.modelObj setGameState: kInGame];
        return;
    }
    [super translate:gesture];
}

- (void)reset:(UIGestureRecognizer *)gesture {
    // MODIFIES: object model (size, rotation, scale)
    // REQUIRES: game in deisginer mode
    // EFFECTS: the object is defaulted back to the palette and its palette properties retained
    if (self.modelObj.currentState == kInGame) {
        [self.modelObj setGameState:kInPalette];
        UIView* paletteView = [gesture.view.superview.superview viewWithTag:2];
        [paletteView addSubview:self.imageView];
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.3];
        self.imageView.transform = CGAffineTransformIdentity;
        [self.modelObj setOrigin:CGPointMake(kPalettePigOriginX, kPalettePigOriginY) ];
        [self.modelObj setSize:CGSizeMake(kPalettePigWidth, kPalettePigHeight)];
        [self.modelObj scale:1];
        [self.modelObj rotate:0];
        self.imageView.frame = [self.modelObj dimensions];
        [UIView commitAnimations];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

@end
