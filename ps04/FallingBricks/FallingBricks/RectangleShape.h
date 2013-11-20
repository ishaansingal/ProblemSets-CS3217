//
//  RectangleShape.h
//  FallingBricks
//
//  Created by Ishaan Singal on 3/7/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PhysicsModel.h"

@interface RectangleShape : UIView
@property NSArray* models;
@property NSArray* shapeColors;
- (id)initWithModel:(NSArray*)models Color:(NSArray*) colors;
@end
