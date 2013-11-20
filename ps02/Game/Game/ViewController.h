//
//  ViewController.h
//  Game
//
//  Created by Ishaan Singal on 27/1/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController
- (IBAction)buttonPressed:(id)sender;

@property (strong, nonatomic) IBOutlet UIScrollView *gamearea;
@property (strong, nonatomic) IBOutlet UIToolbar *optionToolBar;

@end
