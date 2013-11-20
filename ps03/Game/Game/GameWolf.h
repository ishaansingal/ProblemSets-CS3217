//
//  GameWolf.h
//  Game
//
//  Created by Ishaan Singal on 29/1/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GameObject.h"
@interface GameWolf : GameObject

- (id)initWithWolf:(GameModel *)givenWolfObj;
  // REQUIRES: valid givenModelObj
  // EFFECTS: Construts a GameObject based on the properties of givenModelObj,
  // and initializes the imageView as a wolf, and updates it to the View

@end
