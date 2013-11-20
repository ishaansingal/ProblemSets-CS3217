//
//  GameWolf.m
//  Game
//
//  Created by Ishaan Singal on 29/1/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import "GameWolf.h"
@interface GameWolf ()
@property(readwrite) GameModel *modelObj;
@property(readwrite) UIImageView *arrowImage;
@property(readwrite) NSTimer *timer;
@property(readwrite) UIImageView *powerBarImage;
@property(readwrite) UIImageView *powerBarBackground;
@property(readwrite) UIImageView *windSuckImage;
@property(readwrite) NSMutableArray *allHearts;
@property(readwrite) CGFloat power;
@property(readwrite) BOOL isBarIncrease;
@property(weak, readwrite) id<ObjectModifyDelegate> objectDelegate;

- (void)setupBreathHealth;
- (void)setupStartGestures;
- (void)setupArrow;
- (void)setupPowerBar;
- (void)arrowCreation:(UIGestureRecognizer*)gesture;
- (void)arrowRotate:(UIGestureRecognizer*)gesture;
- (void)powerBreath:(UIGestureRecognizer*)gesture;
- (void)wolfBlowBreath;
- (void)increasePower:(NSTimer*)timer;

@end

double arrowRotation;
@implementation GameWolf

- (id)initWithWolf:(GameModel*)givenModelObj {
    // REQUIRES: valid givenModelObj
    // EFFECTS: Construts a GameObject based on the properties of givenModelObj,
    // and initializes the imageView as a wolf, and updates it to the View
    self.modelObj = givenModelObj;
    UIImage* wolfImage = [UIImage imageNamed:kWolfImageName];
    self = [super initWithImage:wolfImage ObjectType:kGameObjectWolf];
    self.view.frame = [self.modelObj dimensions];
    [self.modelObj setDelegate: self];
    [self.view setTransform:CGAffineTransformRotate(self.view.transform, givenModelObj.rotation)];
    [self.view setTransform:CGAffineTransformScale(self.view.transform, givenModelObj.imageScale, givenModelObj.imageScale)];
    [self setAllGestures];
    return self;
}

#pragma mark - Play Mode setup
//sets up the start mode (play mode) by setting up the respective gestures
//arrow and powerbar
- (void)setupStartMode {
    [super setupStartMode];
    self.numOfBreaths = 3;
    [self setupStartGestures];
    [self setupArrow];
    [self setupPowerBar];
    [self setupBreathHealth];
}



//based on the number of breaths available, hearts are created at the bottom of the
//screen that reduce each time a breath is released
- (void)setupBreathHealth {
    //first three elements are background hearts
    self.allHearts = [NSMutableArray array];
    CGPoint bottomLeft = CGPointMake(40, kGameareaHeight + kPaletteHeight + 50 - kGroundHeight);
    for (int i = 0; i < self.numOfBreaths; i++) {
        UIImageView *thisHeart = [[UIImageView alloc]initWithImage:[UIImage imageNamed:kHeartImageName]];
        thisHeart.frame = CGRectMake(bottomLeft.x + 40 * i, bottomLeft.y, 30, 30);
        thisHeart.alpha = 0.4;
        [self.allHearts addObject:thisHeart];
        [self.view.superview.superview addSubview:thisHeart];
    }

    for (int i = 0; i < self.numOfBreaths; i++) {
        UIImageView *thisHeart = [[UIImageView alloc]initWithImage:[UIImage imageNamed:kHeartImageName]];
        thisHeart.frame = CGRectMake(bottomLeft.x + 40 * i, bottomLeft.y, 30, 30);
        [self.allHearts addObject:thisHeart];
        [self.view.superview.superview addSubview:thisHeart];
    }
    return;
}

//sets up all the start gestures :
// - tapping on the wolf creates the arrow and the powerbar
// - after the arrow and powerbar is present, longpressing the wolf relseases breath
- (void)setupStartGestures {
    //after a single tap, it creates the arrow
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(arrowCreation:)];
    [tapRecognizer setNumberOfTapsRequired:1];
    [tapRecognizer setDelegate:self];
    
    //the pressing determines the power with which the breath is launched
    UILongPressGestureRecognizer *longPressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(powerBreath:)];
    longPressRecognizer.minimumPressDuration = 0.25;
    [longPressRecognizer setDelegate:self];
    
    [tapRecognizer requireGestureRecognizerToFail:longPressRecognizer];
    [self.view addGestureRecognizer:tapRecognizer];
    [self.view addGestureRecognizer:longPressRecognizer];
}

//create the arrow in front of the wolf mouth (but hidden until wolf tapped)
//a gesture on the arrow is implemented to rotate it for direction
- (void)setupArrow {
    UIImage *arrowImage = [UIImage imageNamed:kArrowImageName];
    self.arrowImage = [[UIImageView alloc]initWithImage:arrowImage];
    CGSize arrowSize = CGSizeMake(kDefaultArrowWidth, kDefaultArrowHeight);
    CGPoint wolfImageTopRight = self.view.frame.origin;
    wolfImageTopRight.x += (self.view.frame.size.width - arrowSize.width/2);
    wolfImageTopRight.y += 5 * self.modelObj.imageScale;
    self.arrowImage.frame = CGRectMake(wolfImageTopRight.x, wolfImageTopRight.y, arrowSize.width, arrowSize.height);
    self.arrowImage.hidden = YES;
    [self.view.superview insertSubview:self.arrowImage belowSubview:self.view];

    //using a long press as a pan gesture for arrow because it is more sensitive than pan
    //when the setMinimumPress is set to 0
    self.arrowImage.userInteractionEnabled = YES;
    UILongPressGestureRecognizer *longPressRecongizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(arrowRotate:)];
    [longPressRecongizer setMinimumPressDuration:0.0];
    [longPressRecongizer setDelegate:self];
    [self.arrowImage addGestureRecognizer:longPressRecongizer];

    arrowRotation = 0;
}

//create the powerbar (but hidden until wolf tapped) above the wolf
- (void)setupPowerBar {
    UIImage *powerBar = [UIImage imageNamed:kBreathBarImageName];
    self.powerBarBackground = [[UIImageView alloc]initWithImage:powerBar];
    self.powerBarImage = [[UIImageView alloc]initWithImage:powerBar];

    CGPoint barOrigin = self.view.frame.origin;
    barOrigin.y -= 30; //the bar to the top of the wolf
    
    self.powerBarBackground.frame = CGRectMake(barOrigin.x, barOrigin.y, self.view.frame.size.width, kDefaultBreathBarHeight);
    self.powerBarBackground.alpha = 0.3;
    self.powerBarImage.frame = CGRectMake(barOrigin.x, barOrigin.y, kDefaultBreathBarWidth, kDefaultBreathBarHeight);
    [self.view.superview addSubview:self.powerBarBackground];
    [self.view.superview addSubview:self.powerBarImage];
    self.powerBarBackground.hidden = YES;
    self.powerBarImage.hidden = YES;
}

#pragma mark - Play Gesture Delegates
//unhides the arrow & powerbar after the wolf is tapped once, and adds the gestures on it
- (void)arrowCreation:(UIGestureRecognizer*)gesture {
    if (self.arrowImage.hidden && self.numOfBreaths > 0) {
        self.arrowImage.hidden = NO;
        self.powerBarImage.hidden = NO;
        self.powerBarBackground.hidden = NO;
    }
}

//the uilongpress gesture (acts as a pan gesture) for the rotation of arrow
//change the color to red when the users finger is on the arrow
//rotate the arrow based on the rotation angle from the center to the pan location
- (void)arrowRotate:(UIGestureRecognizer*)gesture {
    CGPoint panPoint = [(UILongPressGestureRecognizer*)gesture locationInView:self.arrowImage.superview];

    if([(UILongPressGestureRecognizer*)gesture state] == UIGestureRecognizerStateBegan) {
        [self.arrowImage setImage:[UIImage imageNamed:kRedArrowImageName]];
        UIScrollView* gameareaView = (UIScrollView*)[gesture.view.superview.superview viewWithTag:1];
        [gameareaView setScrollEnabled:NO];
    }
    if([(UILongPressGestureRecognizer*)gesture state] == UIGestureRecognizerStateEnded) {
        [self.arrowImage setImage:[UIImage imageNamed:kArrowImageName]];
        UIScrollView* gameareaView = (UIScrollView*)[gesture.view.superview.superview viewWithTag:1];
        [gameareaView setScrollEnabled:YES];
    }

    if([(UILongPressGestureRecognizer*)gesture state] == UIGestureRecognizerStateChanged) {
        CGPoint arrowCenter = self.arrowImage.center;
        CGFloat angle = atan2f(panPoint.y - arrowCenter.y, panPoint.x - arrowCenter.x);
        //limit the range of angle rotation
        if (abs(arrowRotation + angle) < 1.4){
            self.arrowImage.transform = CGAffineTransformRotate(CGAffineTransformIdentity, angle);
            arrowRotation = [(NSNumber *)[self.arrowImage.layer valueForKeyPath:@"transform.rotation"] floatValue];
        }
    }
}

//the long press gesture delegate: hides the arrow and creates a breath when the
//long press is released
- (void)powerBreath:(UIGestureRecognizer*)gesture {
    //if no arrow, early return
    if (self.arrowImage.hidden) {
        return;
    }
    if ([(UILongPressGestureRecognizer*)gesture state] == UIGestureRecognizerStateBegan) {
        self.isBarIncrease = YES;
        self.timer = [NSTimer scheduledTimerWithTimeInterval:0.02 target:self selector:@selector(increasePower:) userInfo:nil repeats:YES];
    }
    if ([(UILongPressGestureRecognizer*)gesture state] == UIGestureRecognizerStateEnded) {
        if (self.arrowImage.hidden == NO) {
            [self.timer invalidate];
            //animate the wolf to blow a breath
            UIImageView *currentImageView = (UIImageView*)self.view;
            [currentImageView setAnimationDuration:1.5];
            [currentImageView setAnimationImages:[Utilities getAnimationImages:kWolfBlowImagesName ColumnNum:5 RowNum:3]] ;
            currentImageView.animationRepeatCount = 1;
            [currentImageView startAnimating];
            
            //wind suck images in front of the wolf
            NSArray *windSuckImages = [Utilities getAnimationImages:kWolfSuckImagesName ColumnNum:4 RowNum:2];
            self.windSuckImage = [[UIImageView alloc]initWithImage:[windSuckImages objectAtIndex:0]];
            self.windSuckImage.frame = CGRectMake(self.view.frame.origin.x + self.view.frame.size.width + 5, self.view.frame.origin.y + 5, 100, 100);
            [self.windSuckImage setAnimationDuration:0.8];
            [self.windSuckImage setAnimationImages:windSuckImages];
            self.windSuckImage.animationRepeatCount = 1;
            [self.view.superview addSubview:self.windSuckImage];
            [self.windSuckImage startAnimating];
           
            //send a selector after the animation is completed to release the breath
            [self performSelector:@selector(wolfBlowBreath) withObject:nil afterDelay:1.5];
        }
    }
}

#pragma mark - handle breath & power
//reduces a heart (number of breaths and sends a delegate method that a breath is created
//with the appropriate veloctiy and location
//it also sends a delegate method breathfinished if it is the last method
- (void)wolfBlowBreath {
    [self.arrowImage setHidden:YES];
    [self.powerBarBackground setHidden:YES];
    [self.powerBarImage setHidden:YES];
    
    [self.windSuckImage removeFromSuperview];
    self.windSuckImage = nil;
    
    UIImageView *thisHeart = [self.allHearts objectAtIndex:self.numOfBreaths + 2];
    [self.allHearts removeLastObject];
    [thisHeart removeFromSuperview];
    self.numOfBreaths--;
    
    CGFloat velX = cosf(arrowRotation) * self.power * kPowerMultiplier;
    CGFloat velY = sinf(arrowRotation) * self.power * kPowerMultiplier;
    Vector2D *vel = [Vector2D vectorWith:velX y:velY];
    CGPoint wolfImageTopRight = self.view.frame.origin;
    CGPoint breathOrigin = CGPointMake(wolfImageTopRight.x + self.view.frame.size.width, wolfImageTopRight.y - 5);
    [self.objectDelegate breathReleasedWithVelocity:vel AtPosition:breathOrigin];
    if (self.numOfBreaths == 0) {
        [self.objectDelegate breathFinished];
    }
}

//increases/decreases the powerbars width by 2 at every timestep
//based on the width of the powerbar, the power of the wind is set
//if the wolf is bigger, the power of the breath is bigger
- (void)increasePower:(NSTimer*)timer {
    CGFloat powerBarWidth = self.powerBarImage.frame.size.width;
    //as soon as the max height reached, limit the level to max-height
    if (self.isBarIncrease) {
        powerBarWidth += 2;
        if (powerBarWidth > self.view.frame.size.width) {
            powerBarWidth = self.view.frame.size.width;
            self.isBarIncrease = NO;
        }
    }
    else {
        powerBarWidth -= 2;
        if (powerBarWidth < 0) {
            powerBarWidth = 0;
            self.isBarIncrease = YES;
        }
    }
    //only modifiy the size and not the origin
    self.powerBarImage.frame = CGRectMake(self.powerBarImage.frame.origin.x, self.powerBarImage.frame.origin.y, powerBarWidth, 20);
    self.power = powerBarWidth/ self.modelObj.imageSize.width;
}

#pragma mark - Designer Gesture Delegates
- (void)translate:(UIGestureRecognizer *)gesture {
    // MODIFIES: object model (coordinates)
    // REQUIRES: game in designer mode
    // EFFECTS: the user drags around the object with one finger
    //          if the object is in the palette, it will be moved in the game area
    
    
    UIView* paletteView = [gesture.view.superview.superview viewWithTag:2];
    bool isInPalette = (self.modelObj.currentState == kInPalette)? YES: NO;
    bool hasTranslatedInGameArea = (self.modelObj.imageOrigin.y > paletteView.frame.size.height)? YES: NO;
    if (isInPalette && hasTranslatedInGameArea) {
        UIScrollView* gameareaView = (UIScrollView*)[gesture.view.superview.superview viewWithTag:1];
        CGPoint scrollOffset = gameareaView.contentOffset ;
        [self.modelObj setSize:CGSizeMake(kDefaultWolfWidth, kDefaultWolfHeight)];
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
            [self.modelObj setOrigin:CGPointMake(kPaletteWolfOriginX, kPaletteWolfOriginY)];
            [self.modelObj translateByPoint:CGPointMake(0, 0)];
        }
    }

    return;

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
        //set the palette size and origin
        [self.modelObj setOrigin:CGPointMake(kPaletteWolfOriginX, kPaletteWolfOriginY)];
        [self.modelObj setSize: CGSizeMake(kPaletteWolfWidth, kPaletteWolfHeight)]; 
        [paletteView addSubview:self.view];
        
        //animate the translation back to palette and change in size
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.3];
        [self.modelObj scale:1];
        [self.modelObj rotate:0];
        self.view.frame = [self.modelObj dimensions];
        [UIView commitAnimations];
    }
}

#pragma mark - Play & Deisgner helper
//the animation related to the wolf dying
- (void)wolfDied {
    assert(self.numOfBreaths == 0);
    NSArray *wolfDieImages = [Utilities getAnimationImages:kWolfDieImagesName ColumnNum:4 RowNum:4];
    UIImageView *currentImageView = (UIImageView*)self.view;
    [currentImageView setImage: wolfDieImages.lastObject];
    [currentImageView setAnimationDuration:2];
    [currentImageView setAnimationImages: wolfDieImages];
    currentImageView.animationRepeatCount = 1;
    [currentImageView startAnimating];
    return;
}

////resets designer mode by enabling all the designer gestures and removing all the
////start elements such as arrow and powerbar
//- (void)resetDesignerMode {
//    for (UIGestureRecognizer *thisGesture in self.view.gestureRecognizers) {
//        [self.view removeGestureRecognizer:thisGesture];
//    }
//    for (UIImageView *thisHeart in self.allHearts) {
//        [thisHeart removeFromSuperview];
//    }
//    self.allHearts = [NSArray array];
//    [self.powerBarBackground removeFromSuperview];
//    self.powerBarBackground = nil;
//    [self.powerBarImage removeFromSuperview];
//    self.powerBarImage = nil;
//    [self.arrowImage removeFromSuperview];
//    self.arrowImage = nil;
//    [self.windSuckImage removeFromSuperview];
//    self.windSuckImage = nil;
//    [self.timer invalidate];
//    self.view = [[UIImageView alloc] initWithImage:[UIImage imageNamed:kWolfImageName]];
//    [self.view setHidden:NO];
//    [super resetDesignerMode];
//}

- (void)removeGameObj {
    [super removeGameObj];
    [self.powerBarBackground removeFromSuperview];
    [self.powerBarImage removeFromSuperview];
    [self.arrowImage removeFromSuperview];    
}

- (void)setDelegate:(id)controller {
    _objectDelegate = controller;
}

- (void)dealloc {
    [self.powerBarBackground removeFromSuperview];
    self.powerBarBackground = nil;
    [self.powerBarImage removeFromSuperview];
    self.powerBarImage = nil;
    [self.arrowImage removeFromSuperview];
    self.arrowImage = nil;
    [self.windSuckImage removeFromSuperview];
    self.windSuckImage = nil;
    [self.timer invalidate];
    for (UIImageView *thisHeart in self.allHearts) {
        [thisHeart removeFromSuperview];
    }
    self.allHearts = [NSArray array];
    [self.view removeFromSuperview];
}



- (void)viewDidLoad {
    [super viewDidLoad];
}


@end
