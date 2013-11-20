//
//  GameObject.m
//  Game
//
//  Created by Ishaan Singal on 29/1/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import "GameObject.h"

@interface GameObject ()
@property(nonatomic, readwrite) GameObjectType objectType;
@property(nonatomic, readwrite) GameModel* modelObj;

@end

@implementation GameObject

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - initializations
- (id)initWithImage:(UIImage*)objectImage ObjectType:(GameObjectType)currentObjectType {
    // REQUIRES: valid data input for the image and currentobject type
    // EFFECTS: initalizes the view and sets the currentObjecType
    self.view = [[UIImageView alloc]initWithImage:objectImage];
    _objectType = currentObjectType;
    return self;
}

- (id)initWithImage:(UIImage*)objectImage Origin:(CGPoint)origin Size:(CGSize)size ObjectType:(GameObjectType)type{
    // REQUIRES: valid data input for the all the parameters
    // EFFECTS: Construts a GameObject based on the properties, and initializes
    // the modelObj, the view, and updates it to the View
    self = [self initWithImage:objectImage ObjectType: type];
    self.modelObj = [[GameModel alloc] initWithSize:size Origin: origin State:0];
    self.view.frame = [self.modelObj dimensions];
    [self.modelObj setDelegate: self];
    [self setAllGestures];
    return self;
}

- (id)initWithImage:(UIImage*)objectImage
             Origin:(CGPoint)origin
               Size:(CGSize)size
         ObjectType:(GameObjectType)type
               Mass:(CGFloat)mass
         FrictCoeff:(CGFloat)coeffFric
          restCoeff:(CGFloat)restCoeff{
    // REQUIRES: valid data input for the all the parameters
    // EFFECTS: Construts a GameObject based on the properties, and initializes
    // the modelObj, the view, and updates it to the View

    self = [self initWithImage:objectImage Origin:origin Size:size ObjectType:type];
    if (self) {
        [self.modelObj setMass:mass Friction:coeffFric Restitution:restCoeff];
    }
    return self;
}

- (void)dealloc {
    [self.view removeFromSuperview];
    self.view = nil;
    self.modelObj = nil;
//    self.view = nil;
    return;
}

#pragma mark - Set Gestures

- (void)setAllGestures {
    // REQUIRES: view != nil
    // EFFECTS: adds all the gestures and their targets to the self.view propery
    [self setAllGesturesForUIImageView:(UIImageView*)self.view];
    return;
}

- (void)setAllGesturesForUIImageView:(UIImageView*)givenImageView {
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

#pragma mark - Gesture delegates
- (void)translate:(UIGestureRecognizer *)gesture {
    // MODIFIES: object model (coordinates)
    // REQUIRES: game in designer mode
    // EFFECTS: the user drags around the object with one finger
    //          if the object is in the palette, it will be moved in the game area
    CGPoint translationDelta =  [(UIPanGestureRecognizer*)gesture translationInView:gesture.view.superview ];
        
    if([(UIPanGestureRecognizer*)gesture state] == UIGestureRecognizerStateBegan) {
        UIScrollView* gameareaView = (UIScrollView*)[gesture.view.superview.superview viewWithTag:1];
        [gameareaView setScrollEnabled:NO];
    }
    if([(UIPanGestureRecognizer*)gesture state] == UIGestureRecognizerStateEnded) {
        UIScrollView* gameareaView = (UIScrollView*)[gesture.view.superview.superview viewWithTag:1];
        [gameareaView setScrollEnabled:YES];
    }
    
    if([(UIPanGestureRecognizer*)gesture state] == UIGestureRecognizerStateChanged) {
        CGPoint centerAfterTranslation  = CGPointMake(self.modelObj.center.x+translationDelta.x, self.modelObj.center.y+translationDelta.y);
        centerAfterTranslation = [self boundedTranslatedPoint:centerAfterTranslation InView:gesture.view];
        CGPoint netTranslation = CGPointMake(centerAfterTranslation.x - self.modelObj.center.x, centerAfterTranslation.y - self.modelObj.center.y);

        [self.modelObj translateByPoint:netTranslation];
    }
    [((UIPanGestureRecognizer*)gesture) setTranslation:CGPointMake(0, 0) inView:gesture.view.superview];
}

- (CGPoint)boundedTranslatedPoint:(CGPoint)translatedPoint InView:(UIView*)givenView {
    // REQUIRES: modelObj and view initialized with valid data, only called
    // when the object is in gamearea
    // EFFECTS: computes the centre of the view by ensuring it is within the
    // gamearea boundaries
    
    CGFloat leftLimit = 0;
    CGFloat bottomLimit = kGameareaHeight - kGroundHeight;
    CGFloat rightLimit = kGameareaWidth;
    CGFloat topLimit = 0;
    
    if (bottomLimit < (translatedPoint.y + givenView.frame.size.height/2))
        translatedPoint.y = bottomLimit - (givenView.frame.size.height/2)-1;
    if (topLimit > (translatedPoint.y)-givenView.frame.size.height/2)
        translatedPoint.y = givenView.frame.size.height/2 + 1;
    if (translatedPoint.x  - givenView.frame.size.width/2 < leftLimit)
        translatedPoint.x = leftLimit+givenView.frame.size.width/2+1;
    if ((translatedPoint.x + givenView.frame.size.width/2 ) > rightLimit)
        translatedPoint.x = rightLimit - givenView.frame.size.width/2-1;
    return translatedPoint;
}

- (void)rotate:(UIGestureRecognizer *)gesture {
    // MODIFIES: object model (rotation)
    // REQUIRES: game in designer mode, object in game area
    // EFFECTS: the object is rotated with a two-finger rotation gesture

    if([(UIRotationGestureRecognizer*)gesture state] == UIGestureRecognizerStateChanged) {
        [self.modelObj rotate: (self.modelObj.rotation + ((UIRotationGestureRecognizer*)gesture).rotation)];
    }
    [((UIRotationGestureRecognizer*)gesture) setRotation: 0];
}

- (void)zoom:(UIGestureRecognizer *)gesture {
    // MODIFIES: object model (size)
    // REQUIRES: game in designer mode, object in game area
    // EFFECTS: the object is scaled up/down with a pinch gesture
    if ( [(UIPinchGestureRecognizer*)gesture state] == UIGestureRecognizerStateChanged) {
        CGFloat currentScale = self.modelObj.imageScale;
        CGFloat newScale = [(UIPinchGestureRecognizer*)gesture scale];
        newScale = ((newScale * currentScale) > kScaleMax)? kScaleMax / currentScale: newScale;
        newScale = ((newScale * currentScale) > kScaleMin)? newScale: kScaleMin / currentScale;
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
    // EFFECTS: manually updates the view to display the next block
    //                (Implemented by GameBlocks)
    return;
}


#pragma mark - Model Delegates
- (void)didTranslate {
    //REQUIRES: the center property of the modelObj to be valid
    //EFFECTS: updates the view's centre point based on the modelObjs center property
    [self.view setCenter: self.modelObj.center];
    return;
}

- (void)didRotate {
    //REQUIRES: the rotation property of the modelObj to be valid
    //EFFECTS: rotates the view based on the modelObjs rotation property
    CGFloat currentRot = [[self.view.layer valueForKeyPath:@"transform.rotation"] floatValue];
    currentRot = self.modelObj.rotation - currentRot;
    CGAffineTransform currentTransform = self.view.transform;
    CGAffineTransform newTransform = CGAffineTransformRotate(currentTransform, currentRot);
    [self.view setTransform:newTransform];
    return;
}

- (void)didScale:(CGFloat)ScaleChange {
    //REQUIRES: the scale property of the modelObj to be valid
    //EFFECTS: resizes the view based on the scalechange sent
    CGAffineTransform newTransform = CGAffineTransformScale(self.view.transform, ScaleChange, ScaleChange);
    [self.view setTransform: newTransform];
    return;
}

#pragma mark - Play & Designer Helpers
- (void)setupStartMode {
    //REQUIRES: wolf/pig to be in the gamearea
    //EFFECTS: removes all the gestures from the object
    for (UIGestureRecognizer *recognizer in self.view.gestureRecognizers) {
        [self.view removeGestureRecognizer:recognizer];
    }
    return;
}

//- (void)resetDesignerMode {
//    //EFFECTS: adds all the desgin gestures back to the object in its initial form
//    self.modelObj.impulse = 0;
//    self.modelObj.expired = NO;
//    [self.modelObj rotate:self.modelObj.rotation];
//    CGAffineTransform newTransform = CGAffineTransformScale(self.view.transform, self.modelObj.imageScale, self.modelObj.imageScale);
//    [self.view setTransform: newTransform];
//    [self setAllGestures];
//}

- (void)removeGameObj {
    //REQUIRES: view != null
    //EFFECTS: removes the view from the gameArea and nullifies it
    [self.view removeFromSuperview];
    self.view = nil;
    self.modelObj = nil;
    return;
}


@end
