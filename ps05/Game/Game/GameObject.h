/*
 Game object contains one object of the Game model and its genereates the image in its view.
 The GameObject also contains an objectType (wolf, pig, block).
 The GameObject has implemented the delegates of the ModelModifyDelegate class.
 These delegates are sent by the Model classes, according to which GameObject 
 updates the View (UIImageView object)
 It also has the functionality to recognize all the relevant gestures of the game
 object and sets its own view with these gestures
*/

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "Utilities.h"
#import "Constants.h"
#import "ModelModifyDelegate.h"
#import "GameModel.h"

@interface GameObject : UIViewController <UIGestureRecognizerDelegate, ModelModifyDelegate>

@property(nonatomic, readonly) GameObjectType objectType;
@property(nonatomic, readonly) GameModel *modelObj;

- (id)initWithImage:(UIImage*)objectImage ObjectType:(GameObjectType)currentObjectType;
  // REQUIRES: valid data input for the image and currentobject type
  // EFFECTS: initalizes the view and sets the currentObjecType

- (id)initWithImage:(UIImage*)objectImage Origin:(CGPoint)origin Size:(CGSize)size ObjectType:(GameObjectType)type;
  // REQUIRES: valid data input for the all the parameters
  // EFFECTS: Construts a GameObject based on the properties, and initializes
  // the modelObj, the view, and updates it to the View

- (id)initWithImage:(UIImage*)objectImage
             Origin:(CGPoint)origin
               Size:(CGSize)size
         ObjectType:(GameObjectType)type
               Mass:(CGFloat)mass
         FrictCoeff:(CGFloat)coeffFric
          restCoeff:(CGFloat)restCoeff;
// REQUIRES: valid data input for the all the parameters
// EFFECTS: Construts a GameObject based on the properties, and initializes
// the modelObj, the view, and updates it to the View


- (CGPoint)boundedTranslatedPoint:(CGPoint)translatedPoint InView:(UIView*)givenView;
  // REQUIRES: modelObj and view initialized with valid data, only called
  // when the object is in gamearea
  // EFFECTS: computes the centre of the view by ensuring it is within the
  // gamearea boundaries

- (void)translate:(UIGestureRecognizer *)gesture;
  // MODIFIES: object model (coordinates)
  // REQUIRES: game in designer mode
  // EFFECTS: the user drags around the object with one finger
  //          if the object is in the palette, it will be moved in the game area

- (void)rotate:(UIGestureRecognizer *)gesture;
  // MODIFIES: object model (rotation)
  // REQUIRES: game in designer mode, object in game area
  // EFFECTS: the object is rotated with a two-finger rotation gesture

- (void)zoom:(UIGestureRecognizer *)gesture;
  // MODIFIES: object model (size)
  // REQUIRES: game in designer mode, object in game area
  // EFFECTS: the object is scaled up/down with a pinch gesture

- (void)reset:(UIGestureRecognizer *)gesture;
  // MODIFIES: object model (size, rotation, scale)
  // REQUIRES: game in deisginer mode
  // EFFECTS: the object is defaulted back to the palette
  // (implemented by the individual subclasses)


- (void)changeBlock:(UIGestureRecognizer *)gesture;
  // MODIFIES: block game model (the image)
  // REQUIRES: game in deisginer mode
  // EFFECTS: manually updates the view to display the next block
  //                (Implemented by GameBlocks)

- (void)setAllGestures;
  // REQUIRES: view != nil
  // EFFECTS: adds all the gestures and their targets to the self.view propery

- (void)setAllGesturesForUIImageView:(UIImageView*)givenImageView ;
  // REQUIRES: givenImageView != nil
  // EFFECTS: adds all the gestures and their targets to the givenImageView

- (void)addTapToChangeBlockGesture:(UIImageView*)givenImageView;
  // REQUIRES: givenImageView != nil and givenImageView is of a block
  // EFFECTS: adds the single tap to change block type gesture to the givenImageView

- (void)didTranslate;
  //REQUIRES: the center property of the modelObj to be valid
  //EFFECTS: updates the view's centre point based on the modelObjs center property

- (void)didRotate;
  //REQUIRES: the rotation property of the modelObj to be valid
  //EFFECTS: rotates the view based on the modelObjs rotation property

- (void)didScale:(CGFloat)ScaleChange;
  //REQUIRES: the scale property of the modelObj to be valid
  //EFFECTS: resizes the view based on the modelObjs scale property

- (void)removeGameObj;
  //EFFECTS: removes the view from the gameArea and nullifies it

- (void)setupStartMode;
  //REQUIRES: wolf/pig to be in the gamearea
  //EFFECTS: removes all the gestures from the object

//- (void)resetDesignerMode;
//  //EFFECTS: adds all the desgin gestures back to the object in its initial form

- (void)dealloc;

@end
