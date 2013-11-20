//
//  RectangleShape.m
//  FallingBricks
//
//  Created by Ishaan Singal on 3/7/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import "RectangleShape.h"

@implementation RectangleShape

- (id)initWithModel:(NSArray*)models Color:(NSArray*) colors
{
    self = [super initWithFrame:CGRectMake (0, 0, 768, 1024)];
//    [self setCenter:model.center];
//    [self setTransform:CGAffineTransformRotate(CGAffineTransformIdentity, model.rotation)];
    self.shapeColors = [[NSArray alloc]initWithArray:colors];
    self.backgroundColor = [UIColor clearColor];
    self.models = [[NSArray alloc]initWithArray:models];
//    [self setBackgroundColor: [colors objectAtIndex:i]];
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    CGContextRef context = UIGraphicsGetCurrentContext();
    for (int i = 0; i < [self.models count]; i++) {
        CGContextSaveGState(context);
        PhysicsModel *thisModel = [self.models objectAtIndex:i];
        CGContextSetFillColorWithColor(context, ((UIColor*)[self.shapeColors objectAtIndex:i]).CGColor);
//        CGRect test = CGRectApplyAffineTransform(CGRectMake(0.0f, 0.0f, thisModel.size.width, thisModel.size.height), CGAffineTransformMakeRotation(-thisModel.rotation));
//        test = CGRectApplyAffineTransform(test, CGAffineTransformMakeTranslation(thisModel.center.x- thisModel.size.width/2, thisModel.center.y - thisModel.size.height/2));

        CGRect test = CGRectMake(thisModel.center.x - thisModel.size.width/2, thisModel.center.y - thisModel.size.height/2, thisModel.size.width, thisModel.size.height);
        CGContextRotateCTM (context,thisModel.rotation); // for 90 degree rotation

//        CGContextFillRect(context, CGRectMake(10.0, 150.0, 60.0, 120.0));     //X, Y, Width, Height
        CGContextFillRect(context, test);
        CGContextRestoreGState(context);
    }
}


@end
