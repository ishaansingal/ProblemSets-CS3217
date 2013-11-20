//
//  GameBreath.m
//  Game
//
//  Created by Ishaan Singal on 24/2/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import "GameBreath.h"

@interface GameBreath ()
//@property(nonatomic, readwrite) UIImageView *imageView;
@property(nonatomic, readwrite) GameModel *modelObj;
@property(readwrite) NSMutableArray *traceImages;
@property(readwrite) BOOL trace;
@property(readwrite) BOOL scroll;

- (void)displayTrace;
- (void)clearBreathAnimation:(UIImageView*)givenView;
- (void)scrollGamearea;

@end

@implementation GameBreath

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (id)initWithOrigin:(CGPoint)origin Radius:(CGFloat)radius  Velocity:(Vector2D*)givenVel{
    // REQUIRES: valid data input for the all the parameters
    // EFFECTS: Construts a GameObject based on the properties, and initializes
    // the modelObj, the imageView, and updates it to the View
    self.traceImages = [NSMutableArray array];
    self.trace = YES;
    self.scroll = YES;
    self.modelObj = [[GameModel alloc] initWithSize:CGSizeMake(2 * radius, 2 * radius) Origin:origin State:1];
    self.modelObj.shape = kCircle;
    [self.modelObj setMass:1 Velocity:givenVel AngularVel:0 Friction:1 Restitution:0.25];
    [self.modelObj setDelegate: self];

    NSArray *breathImages = [Utilities getAnimationImages:kBreathImageName ColumnNum:4 RowNum:1];
    UIImageView *thisBreathView =[[UIImageView alloc]initWithImage:breathImages.lastObject];
    thisBreathView.frame = CGRectMake(origin.x, origin.y, self.modelObj.imageSize.width, self.modelObj.imageSize.height);
    [thisBreathView setAnimationDuration:1];
    [thisBreathView setAnimationImages:breathImages];
    [thisBreathView startAnimating];

    self.view = thisBreathView;
    return self;
}

#pragma mark - Model Delegate
- (void)didTranslate {
    if (self.trace) {
        [self displayTrace];
    }
    if (self.scroll) {
        [self scrollGamearea];
    }
    [self.view setCenter: self.modelObj.center];
    return;
}

- (void)didRotate {
    //REQUIRES: the rotation property of the modelObj to be valid
    //EFFECTS: rotates the imageView based on the modelObjs rotation property
    CGFloat currentRot = [[self.view.layer valueForKeyPath:@"transform.rotation"] floatValue];
    currentRot = self.modelObj.rotation - currentRot;
    CGAffineTransform currentTransform = self.view.transform;
    CGAffineTransform newTransform = CGAffineTransformRotate(currentTransform, currentRot);
    [self.view setTransform:newTransform];
    return;
}

#pragma mark - Trace & Scroll
- (void)displayTrace {
    NSArray *breathImages = [Utilities getAnimationImages:kBreathImageName ColumnNum:4 RowNum:1];
    //if trace already present, add a new trace at the current breath after a threshold
    //distance
    if ((int)[self.traceImages count] > 0) {
        UIImageView *lastTrace = self.traceImages.lastObject;
        Vector2D *lastTraceCenter = [Vector2D vectorWith:lastTrace.center.x y:lastTrace.center.y];
        Vector2D *breathCenter = [Vector2D vectorWith:self.view.center.x y:self.view.center.y];
        Vector2D *distance = [breathCenter subtract:lastTraceCenter];
        if ([distance length]> self.modelObj.imageSize.width/2 + 3) {
            UIImageView *test = [[UIImageView alloc]initWithImage:[breathImages objectAtIndex:0]];
            test.frame = CGRectMake(self.view.center.x, self.view.center.y, 15, 15);
            [self.traceImages addObject:test];
            [self.view.superview addSubview:test];
        }
    }
    else {
        UIImageView *test = [[UIImageView alloc]initWithImage:[breathImages objectAtIndex:0]];
        test.frame = CGRectMake(self.view.center.x, self.view.center.y, 15, 15);
        [self.traceImages addObject:test];
        [self.view.superview addSubview:test];
    }

}

//If the breath has travelled beyond the view, scroll the gamearea by that amount
- (void)scrollGamearea {
    UIScrollView *gamearea = (UIScrollView*)self.view.superview;
    CGFloat breathRightX = self.modelObj.imageOrigin.x + self.modelObj.imageSize.width;
    if (breathRightX > kViewWidth) {
        gamearea.contentOffset = CGPointMake(breathRightX - kViewWidth, 0);
    }
    if (breathRightX >= gamearea.contentSize.width && self.modelObj.imageOrigin.y <= gamearea.contentSize.height) {
        self.modelObj.expired = YES;
    }
}


- (void)stopTrace {
    // EFFECTS: sets the trace property to NO
    self.trace = NO;
}

- (void)stopScroll {
    // EFFECTS: sets the scroll property to NO
   self.scroll = NO;
}

#pragma mark - Breath Collision Effect
//animates the breath to disperse in 0.7 seconds and then remove it completely from its superview
//clears the breath properties and the trace
- (void)breathDied {
    UIScrollView *gamearea = (UIScrollView*)self.view.superview;
    NSArray *breakExpiredImages = [Utilities getAnimationImages:kBreathExpiredImagesName ColumnNum:5 RowNum:2];
    UIImageView *currentImageView = [[UIImageView alloc]initWithImage:breakExpiredImages.lastObject];
    currentImageView.center = self.view.center;
    [currentImageView setAnimationDuration:0.7];
    [currentImageView setAnimationImages:breakExpiredImages];
    currentImageView.animationRepeatCount = 1;
    [currentImageView startAnimating];
    [gamearea addSubview:currentImageView];
    
    [self.view removeFromSuperview];
    self.view = nil;
    [self setModelObj:nil];
    [self performSelector:@selector(clearBreathAnimation:) withObject:currentImageView afterDelay:0.7];
}

//helper method to remove the breath completely
//also sets the scroll contentoffset to 0 to return to the left most side
- (void)clearBreathAnimation:(UIImageView*)givenView{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5];
    ((UIScrollView*)givenView.superview).contentOffset = CGPointMake(0, 0);
    [UIView commitAnimations];

    [givenView removeFromSuperview];
}


- (void)reducePowerBy:(double)factor {
    // EFFECTS: reduces the breath power by the given factor
    Vector2D *currentVelocity = self.modelObj.velocity;
    self.modelObj.velocity = [Vector2D vectorWith:currentVelocity.x * factor y:currentVelocity.y * factor];
}

- (void)dealloc {
    self.view = nil;
    [self setModelObj:nil];
    for (UIImageView *thisTrace in self.traceImages) {
        [thisTrace removeFromSuperview];
    }
}

@end
