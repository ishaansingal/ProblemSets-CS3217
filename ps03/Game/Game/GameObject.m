//
//  GameObject.m
//  Game
//
//  Created by Ishaan Singal on 29/1/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import "GameObject.h"

@interface GameObject ()
@property(nonatomic, readwrite) UIImageView* imageView;
@property(nonatomic, readwrite) GameObjectType objectType;
@property(nonatomic, readwrite) GameModel* modelObj;

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer;
// EFFECTS: Implements the UIGesture delegate of enabling rotation and scaling simultaneously
@end

@implementation GameObject

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (id)initWithImage:objectImage ObjectType:(GameObjectType)currentObjectType {
    // REQUIRES: valid data input for the image and currentobject type
    // EFFECTS: initalizes the imageView and sets the currentObjecType
    self.imageView = [[UIImageView alloc]initWithImage:objectImage];
    _objectType = currentObjectType;
    return self;
}

- (id)initWithImage:(UIImage*)objectImage Origin:(CGPoint)origin Size:(CGSize)size ObjectType:(GameObjectType)type{
    // REQUIRES: valid data input for the all the parameters
    // EFFECTS: Construts a GameObject based on the properties, and initializes
    // the modelObj, the imageView, and updates it to the View
    self = [self initWithImage:objectImage ObjectType: type];
    self.modelObj = [[GameModel alloc] initWithSize:size Origin: origin State:0 ];
    self.imageView.frame = [self.modelObj dimensions];
    [self.modelObj setDelegate: self];
    [self setAllGestures];
    return self;
}


- (CGPoint)boundedTranslatedPoint: (CGPoint)translatedPoint {
    // REQUIRES: modelObj and imageView initialized with valid data, only called
    // when the object is in gamearea
    // EFFECTS: computes the centre of the imageView by ensuring it is within the
    // gamearea boundaries

    CGFloat leftLimit = [self.imageView.superview.superview viewWithTag:5].frame.origin.x;
    CGFloat bottomLimit = [self.imageView.superview.superview viewWithTag:5].frame.origin.y;//frame.origin;
    CGFloat rightLimit = [self.imageView.superview.superview viewWithTag:5].frame.size.width;
    CGFloat gameAreaOriginY = [self.imageView.superview.superview viewWithTag:1].frame.origin.y;
    CGFloat paletteAreaHeight = [self.imageView.superview.superview viewWithTag:2].frame.size.height;
    CGFloat topLimit = gameAreaOriginY - paletteAreaHeight;
    
    if (bottomLimit < (translatedPoint.y + self.modelObj.imageSize.height/2))
        translatedPoint.y = bottomLimit - (self.modelObj.imageSize.height/2)-1;
    if (topLimit > (translatedPoint.y)-self.modelObj.imageSize.height/2)
        translatedPoint.y = self.modelObj.imageSize.height/2 + 1;
    if (translatedPoint.x  - self.modelObj.imageSize.width/2 < leftLimit)
        translatedPoint.x = leftLimit+self.modelObj.imageSize.width/2+1;
    if ((translatedPoint.x + self.modelObj.imageSize.width/2 ) > rightLimit)
        translatedPoint.x = rightLimit - self.modelObj.imageSize.width/2-1;
    return translatedPoint;
}


- (void)translate:(UIGestureRecognizer *)gesture {
    // MODIFIES: object model (coordinates)
    // REQUIRES: game in designer mode
    // EFFECTS: the user drags around the object with one finger
    //          if the object is in the palette, it will be moved in the game area
    CGPoint translatedPoint =  [(UIPanGestureRecognizer*)gesture translationInView:self.imageView.superview ];
    if([(UIPanGestureRecognizer*)gesture state] == UIGestureRecognizerStateBegan) {
        UIScrollView* gameareaView = (UIScrollView*)[gesture.view.superview.superview viewWithTag:1];
        [gameareaView setScrollEnabled:NO];
    }
    if([(UIPanGestureRecognizer*)gesture state] == UIGestureRecognizerStateEnded) {
        UIScrollView* gameareaView = (UIScrollView*)[gesture.view.superview.superview viewWithTag:1];
        [gameareaView setScrollEnabled:YES];
    }
    
    if([(UIPanGestureRecognizer*)gesture state] == UIGestureRecognizerStateChanged) {
        CGPoint centerAfterTranslation  = CGPointMake(self.modelObj.center.x+translatedPoint.x, self.modelObj.center.y+translatedPoint.y);
        centerAfterTranslation = [self boundedTranslatedPoint:centerAfterTranslation];
        CGPoint netTranslation = CGPointMake(centerAfterTranslation.x - self.modelObj.center.x, centerAfterTranslation.y - self.modelObj.center.y);
        [self.modelObj translateByPoint:netTranslation];
    }
    [((UIPanGestureRecognizer*)gesture) setTranslation:CGPointMake(0, 0) inView:self.imageView.superview];
}

- (void)rotate:(UIGestureRecognizer *)gesture {
    // MODIFIES: object model (rotation)
    // REQUIRES: game in designer mode, object in game area
    // EFFECTS: the object is rotated with a two-finger rotation gesture

    if([(UIRotationGestureRecognizer*)gesture state] == UIGestureRecognizerStateEnded) {
        [self.modelObj setOrigin:self.imageView.frame.origin];
        [self.modelObj setSize:self.imageView.frame.size];
    }
    if([(UIRotationGestureRecognizer*)gesture state] == UIGestureRecognizerStateChanged) {
        [self.modelObj rotate: (self.modelObj.rotation + ((UIRotationGestureRecognizer*)gesture).rotation)];
    }
    [((UIRotationGestureRecognizer*)gesture) setRotation: 0];
}

- (void)zoom:(UIGestureRecognizer *)gesture {
    // MODIFIES: object model (size)
    // REQUIRES: game in designer mode, object in game area
    // EFFECTS: the object is scaled up/down with a pinch gesture
    if([(UIPinchGestureRecognizer*)gesture state] == UIGestureRecognizerStateEnded) {
        [self.modelObj setOrigin:self.imageView.frame.origin];
        [self.modelObj setSize:self.imageView.frame.size];
    }
    if ( [(UIPinchGestureRecognizer*)gesture state] == UIGestureRecognizerStateChanged) {
        CGFloat currentScale = [[(UIPinchGestureRecognizer*)gesture.view.layer valueForKeyPath:@"transform.scale"] floatValue];
        CGFloat newScale = [(UIPinchGestureRecognizer*)gesture scale];
        newScale = ((newScale * currentScale)> kScaleMax)? kScaleMax: newScale * currentScale;
        newScale = ((newScale)> kScaleMin)? newScale: kScaleMin;
        [self.modelObj scale:newScale];
    }
    [(UIPinchGestureRecognizer*)gesture setScale:1];
}

- (void)reset:(UIGestureRecognizer *)gesture {
    // MODIFIES: object model (size, rotation, scale)
    // REQUIRES: game in deisginer mode
    // EFFECTS: the object is defaulted back to the palette
    // (implemented by the individual subclasses)
    return;
}

- (void)changeBlock:(UIGestureRecognizer *)gesture {
    // MODIFIES: block game model (the image)
    // REQUIRES: game in deisginer mode
    // EFFECTS: manually updates the imageview to display the next block
    //                (Implemented by GameBlocks)
    return;
}

- (void)setAllGestures {
    // REQUIRES: imageView != nil
    // EFFECTS: adds all the gestures and their targets to the self.imageView propery
    [self setAllGesturesForUIImageView:self.imageView];
    return;
}

- (void)setAllGesturesForUIImageView:(UIImageView *)givenImageView {
    // REQUIRES: givenImageView != nil
    // EFFECTS: adds all the gestures and their targets to the givenImageView
    givenImageView.userInteractionEnabled = YES;
    UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(translate:)];
    [panRecognizer setMinimumNumberOfTouches:1];
    [panRecognizer setMaximumNumberOfTouches:1];
    [panRecognizer setDelegate:self];
    [givenImageView addGestureRecognizer:panRecognizer];
    
    UIRotationGestureRecognizer *rotRecognizer = [[UIRotationGestureRecognizer alloc]initWithTarget:self action:@selector(rotate:)];
    [rotRecognizer setDelegate:self];
    [givenImageView addGestureRecognizer:rotRecognizer];
    
    UIPinchGestureRecognizer *pinchRecognizer = [[UIPinchGestureRecognizer alloc]initWithTarget:self action:@selector(zoom:)];
    [pinchRecognizer setDelegate:self];
    [givenImageView addGestureRecognizer:pinchRecognizer];
    
    UITapGestureRecognizer *doubleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(reset:)];
    [doubleTapRecognizer setNumberOfTapsRequired:2];
    [doubleTapRecognizer setDelegate:self];
    [givenImageView addGestureRecognizer:doubleTapRecognizer];
    
    if (self.objectType == kGameObjectBlock) {
        [self addTapToChangeBlockGesture:givenImageView];
    }
    return;
}

- (void)addTapToChangeBlockGesture:(UIImageView*)givenImageView {
    // REQUIRES: givenImageView != nil and givenImageView is of a block
    // EFFECTS: adds the single tap to change block type gesture to the givenImageView
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(changeBlock:)];
    [tapRecognizer setNumberOfTapsRequired:1];
    
    NSArray* gestures =[[NSArray alloc] initWithArray:givenImageView.gestureRecognizers];
    UITapGestureRecognizer* doubleTapGesture;
    for (UIGestureRecognizer* gesture in gestures) {
        if ([gesture isKindOfClass: [UITapGestureRecognizer class]])
            doubleTapGesture = (UITapGestureRecognizer*)gesture;
    }
    [tapRecognizer requireGestureRecognizerToFail:doubleTapGesture];
    [tapRecognizer setDelegate:self];
    [givenImageView addGestureRecognizer:tapRecognizer];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    // EFFECTS: Implements the UIGesture delegate of enabling rotation and scaling simultaneously
    return YES;
}

- (void)didTranslate {
    //REQUIRES: the center property of the modelObj to be valid
    //EFFECTS: updates the imageView's centre point based on the modelObjs center property
    [self.imageView setCenter: self.modelObj.center];
    return;
}

- (void)didRotate {
    //REQUIRES: the rotation property of the modelObj to be valid
    //EFFECTS: rotates the imageView based on the modelObjs rotation property
    CGFloat currentRot = [[self.imageView.layer valueForKeyPath:@"transform.rotation"] floatValue];
    currentRot = self.modelObj.rotation - currentRot;
    CGAffineTransform currentTransform = self.imageView.transform;
    CGAffineTransform newTransform = CGAffineTransformRotate(currentTransform, currentRot);
    [self.imageView setTransform:newTransform];
    return;
}

- (void)didScale {
    //REQUIRES: the scale property of the modelObj to be valid
    //EFFECTS: resizes the imageView based on the modelObjs scale property
    CGFloat currentScale = [[self.imageView.layer valueForKeyPath:@"transform.scale"] floatValue];
    currentScale = self.modelObj.imageScale / currentScale;
    CGAffineTransform transform = CGAffineTransformScale(self.imageView.transform, currentScale, currentScale);
    self.imageView.transform = transform;
    return;
}

- (void)removeGameObj {
    //REQUIRES: imageView != null
    //EFFECTS: removes the imageView from the gameArea and nullifies it
    [self.imageView removeFromSuperview];
    self.imageView = nil;
    self.modelObj = nil;
    return;
}

@end
