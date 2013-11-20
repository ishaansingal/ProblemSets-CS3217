/*
The subclass of GameObject that handles all the interactions with pig
It also implements functions for the wolf in play mode:
*/

#import "GameObject.h"

@interface GamePig : GameObject

- (id)initWithPig:(GameModel *)givenModelObj;
  // REQUIRES: valid givenModelObj
  // EFFECTS: Construts a GameObject based on the properties of givenModelObj,
  // and initializes the imageView as a pig, and updates it to the View

- (void)pigDied;
  // REQUIRES: modelObj.expired == YES
  // EFFECTS: animates the pig as die (blows it into smoke)

- (void)pigCry;
  // EFFECTS: changes the image of the wolf to wolfcry
@end
