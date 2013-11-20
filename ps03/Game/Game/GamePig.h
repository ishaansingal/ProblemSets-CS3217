//
//  GamePig.h
//  Game
//
//  Created by Ishaan Singal on 29/1/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import "GameObject.h"
#import "Pig.h"
@interface GamePig : GameObject

- (id)initWithPig:(GameModel *)givenModelObj;
  // REQUIRES: valid givenModelObj
  // EFFECTS: Construts a GameObject based on the properties of givenModelObj,
  // and initializes the imageView as a pig, and updates it to the View

@end
