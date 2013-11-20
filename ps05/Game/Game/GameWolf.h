/*
 The subclass of GameObject that handles all the interactions with wolf
 It also implements functions for the wolf in play mode:
 - Arrow creation and rotation
 - Powerbar 
 - Breath creation
 
 It has a delegate of <ObjectModifyDelegate> protocol, used to send each time a 
 breath is created 
 */

#import <UIKit/UIKit.h>
#import "GameObject.h"
#import "ObjectModifyDelegate.h"
@interface GameWolf : GameObject
@property(weak, readonly) id<ObjectModifyDelegate> objectDelegate;
@property int numOfBreaths;

- (id)initWithWolf:(GameModel *)givenWolfObj;
  // REQUIRES: valid givenModelObj
  // EFFECTS: Construts a GameObject based on the properties of givenModelObj,
  // and initializes the imageView as a wolf, and updates it to the View

- (void)setDelegate:(id)controller;
  // REQUIRES: game in play mode & valid controller

- (void)wolfDied;
  // REQUIRES: numOfBreaths = 0 (as the wolf cannot die before that)
  // EFFECTS: sets the animation of the wolf as died
@end
