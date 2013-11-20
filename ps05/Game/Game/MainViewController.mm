//
//  MainViewController.m
//  Game
//
//  Created by Ishaan Singal on 1/3/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import "MainViewController.h"

@interface MainViewController ()
- (void)moveCloudsInBackground:(NSTimer*)timer;
- (void)loadPresavedLevels;
- (void)setButtons;
- (void)loadBackgroundView;
- (void)loadMenuToolbar;
@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadPresavedLevels];
    [self loadBackgroundView];
    [self setButtons];

    //move the clouds
    [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(moveCloudsInBackground:) userInfo:nil repeats:YES];
}

//moves the clouds in the backgroun every 0.05 seconds
- (void)moveCloudsInBackground:(NSTimer*)timer {
    self.cloud1View.center = CGPointMake(self.cloud1View.center.x + 2, self.cloud1View.center.y);
    if (self.cloud1View.frame.origin.x  > kViewWidth) {
        self.cloud1View.center = CGPointMake(- self.cloud1View.frame.size.width / 2, self.cloud1View.center.y);
    }
    self.cloud2View.center = CGPointMake(self.cloud2View.center.x + 5, self.cloud2View.center.y);
    if (self.cloud2View.frame.origin.x > kViewWidth) {
        self.cloud2View.center = CGPointMake(- self.cloud2View.frame.size.width / 2, self.cloud2View.center.y);
    }
}

//transfers all the presaved levels from the application bundle to ipads document directory
- (void)loadPresavedLevels {
    //all presaved files are stored in the Levels folder of the appicaltion bundle
    NSString *levelDir = [[NSBundle mainBundle]bundlePath];
    levelDir = [NSString stringWithFormat:@"%@/%@", levelDir, @"Levels"];
    NSArray *allLevels = [NSBundle pathsForResourcesOfType:@"" inDirectory:levelDir ];
    
    
    for (NSString *thisLevel in allLevels) {
        //tokens.lastobject returns the name of the last object
        NSArray* documentsFolder = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask,YES);
        NSString* documentString = [documentsFolder objectAtIndex:0];
        NSArray *tokens = [thisLevel componentsSeparatedByString:@"/"];
        NSURL *thisLevelURL = [[NSURL alloc]initFileURLWithPath:thisLevel];
        documentString = [NSString stringWithFormat:@"%@/%@", documentString, tokens.lastObject];
        NSURL *destFile = [[NSURL alloc]initFileURLWithPath:documentString];
        [[NSFileManager defaultManager] copyItemAtURL:thisLevelURL toURL:destFile error:nil];
    }

}

//sets up Button views
- (void)setButtons {
    CALayer *playButtonLayer = self.playButton.layer;
    [playButtonLayer setCornerRadius:8.0f];
    playButtonLayer.masksToBounds = YES;
    playButtonLayer.borderWidth = 1.0f;
    
    CALayer *designButtonLayer = self.designButton.layer;
    [designButtonLayer setCornerRadius:8.0f];
    designButtonLayer.masksToBounds = YES;
    designButtonLayer.borderWidth = 1.0f;

}

//sets up the backgrounview
- (void)loadBackgroundView {
    //sun
    UIImageView *sun = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"sun.png"]];
    sun.frame = CGRectMake(10, 30, 100, 100);
    [self.view addSubview:sun];

    UIImage *bgImage = [UIImage imageNamed:kBackgroundImageName];
    UIImage *groundImage = [UIImage imageNamed:kGroundImageName];
    //Place them in an UIImageView
    UIImageView *background = [[UIImageView alloc]initWithImage:bgImage];
    UIImageView *ground = [[UIImageView alloc]initWithImage:groundImage];
    
    // Get the width and height of all the images
    CGFloat backgroundWidth = bgImage.size.width;
    CGFloat backgroundHeight = bgImage.size.height;
    CGFloat groundWidth = groundImage.size.width;
    CGFloat groundHeight = groundImage.size.height;
    
    CGFloat groundY = self.mainView.frame.size.height - groundHeight;
    CGFloat backgroundY = groundY - backgroundHeight;
    
    // Set the frame properties
    background.frame = CGRectMake(0, backgroundY, backgroundWidth, backgroundHeight);
    ground.frame = CGRectMake(0, groundY, groundWidth, groundHeight);
    

    // Add these views as subviews of the gamearea
    [self.mainView addSubview:background];
    [self.mainView addSubview:ground];
    [self.mainView sendSubviewToBack:background];
    [self.mainView sendSubviewToBack:ground];
    return;
}

//loads a toolbar at the bottom (without any buttons for now
- (void)loadMenuToolbar {
    //A toolbar at the bottom
    CGFloat toolBarOriginY = self.mainView.frame.origin.y + self.mainView.frame.size.height;
    CGFloat toolBarWidth = self.mainView.frame.size.width;
    CGFloat toolBarHeight = self.view.frame.size.height - toolBarOriginY;
    CGRect toolbarRect = CGRectMake(0, toolBarOriginY, toolBarWidth, toolBarHeight);
    [self.optionToolbar setFrame:toolbarRect];
    return;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - rotation for ios 5
// Override to allow orientations other than the default portrait orientation.
// Rotation for v. 5.1.1
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    if (interfaceOrientation == UIInterfaceOrientationLandscapeLeft)
        return YES;
    if (interfaceOrientation == UIInterfaceOrientationLandscapeRight)
        return YES;

    return NO;
}

// Rotation 6.0
// Tell the system It should autorotate
- (BOOL) shouldAutorotate {
    return YES;
}

//// Tell the system which initial orientation we want to have
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait;
}

// Tell the system what we support
- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAll;
}

- (void)viewDidUnload {
    [self setMainView:nil];
    [self setPlayButton:nil];
    [self setPlayButton:nil];
    [self setOptionToolbar:nil];
    [self setCloud1View:nil];
    [self setCloud2View:nil];
    [super viewDidUnload];
}

@end
