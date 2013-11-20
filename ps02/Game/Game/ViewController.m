//
//  ViewController.m
//  Game
//
//  Created by Ishaan Singal on 27/1/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    //Load the images into objects
    
    UIImage *bgImage = [UIImage imageNamed:@"background.png"];
    UIImage *groundImage = [UIImage imageNamed:@"ground.png"];
    //Place them in an UIImageView
    UIImageView *background = [[UIImageView alloc]initWithImage:bgImage];
    UIImageView *ground = [[UIImageView alloc]initWithImage:groundImage];
    

    
    // Get the width and height of the two images
    CGFloat backgroundWidth = bgImage.size.width;
    CGFloat backgroundHeight = bgImage.size.height;
    CGFloat groundWidth = groundImage.size.width;
    CGFloat groundHeight = groundImage.size.height;
    
    // Compute the y position for the two UIImageView
    CGFloat groundY = _gamearea.frame.size.height - groundHeight;
    CGFloat backgroundY = groundY - backgroundHeight;
    
    // Set the frame properties
    background.frame = CGRectMake(0, backgroundY, backgroundWidth, backgroundHeight);
    ground.frame = CGRectMake(0, groundY, groundWidth, groundHeight);
    
    // Add these views as subviews of the gamearea
    [_gamearea addSubview:background];
    [_gamearea addSubview:ground];

    // Set the content size so that gamearea is scrollable
    CGFloat gameareaHeight = backgroundHeight + groundHeight;
    CGFloat gameareaWidth = backgroundWidth;
    [_gamearea setContentSize:CGSizeMake(gameareaWidth, gameareaHeight)];

    CGRect toolbarRect = CGRectMake(0,_gamearea.frame.origin.y + _gamearea.frame.size.height, _gamearea.frame.size.width, 60);
    [_optionToolBar setFrame:toolbarRect];
    [_optionToolBar setBarStyle: UIBarStyleBlackOpaque];
    
    CGRect myViewRect = CGRectMake(0, 0, _gamearea.frame.size.width, 73);
    UIImageView *imageHolder = [[UIImageView alloc] initWithFrame:myViewRect];
    UIImage *buttonBackground = [UIImage imageNamed:@"objectsBackground.jpg"];
    imageHolder.image = buttonBackground;
    [self.view addSubview:imageHolder];
    
    [self.view sendSubviewToBack: imageHolder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setGamearea:nil];
    [self setOptionToolBar:nil];
    [super viewDidUnload];
}
- (IBAction)buttonPressed:(id)sender {
    UIColor *newColor;
    UIButton *button = (UIButton*)sender;
    if ([button titleColorForState:UIControlStateNormal] == [UIColor blackColor]) {
        newColor = [UIColor lightGrayColor];
    }
    else {
        newColor = [UIColor blackColor];
    }
    [button setTitleColor:newColor forState:UIControlStateNormal];

}
@end
