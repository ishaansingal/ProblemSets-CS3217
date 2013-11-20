//
//  GameWolf.m
//  Game
//
//  Created by Ishaan Singal on 29/1/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import "GameWolf.h"
@interface GameWolf ()
@property(readwrite) GameModel* modelObj;
@end

@implementation GameWolf

- (id)initWithWolf:(GameModel*)givenModelObj {
    // REQUIRES: valid givenModelObj
    // EFFECTS: Construts a GameObject based on the properties of givenModelObj,
    // and initializes the imageView as a wolf, and updates it to the View
    self.modelObj = givenModelObj;
    UIImage* wolfImage = [UIImage imageNamed:kWolfImageName];
    self = [super initWithImage:wolfImage ObjectType: kGameObjectWolf];
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
        [self.modelObj setSize:CGSizeMake(kDefaultWolfWidth, kDefaultWolfHeight)];
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
        [UIView setAnimationDuration:0.5];
        self.imageView.transform = CGAffineTransformIdentity;
        [self.modelObj setOrigin:CGPointMake(kPaletteWolfOriginX, kPaletteWolfOriginY)];
        [self.modelObj setSize: CGSizeMake(kPaletteWolfWidth, kPaletteWolfHeight)];
        [self.modelObj scale:1];
        [self.modelObj rotate:0];
        self.imageView.frame = [self.modelObj dimensions];
        [UIView commitAnimations];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
}


@end
