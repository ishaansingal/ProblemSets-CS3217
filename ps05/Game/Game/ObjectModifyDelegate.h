//
//  ObjectModifyDelegate.h
//  Game
//
//  Created by Ishaan Singal on 26/2/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Vector2d.h"

@protocol ObjectModifyDelegate <NSObject>
@optional
- (void)breathReleasedWithVelocity:(Vector2D*)vel AtPosition:(CGPoint)origin;
- (void)breathFinished;
@end
