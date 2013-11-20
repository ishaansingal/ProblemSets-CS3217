//
//  GameViewController.m
//  Game
//
//  Created by Ishaan Singal on 1/3/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import "GameViewController.h"

@interface GameViewController ()
- (void)loadGamearea;
- (void)loadBackgroundView;
- (void)moveCloudsInBackground:(NSTimer*)t;
- (void)loadWolfFromFile:(GameModel*) givenWolf;
- (void)loadPigFromFile:(GameModel*) givenPig;
- (void)loadBlocksFromFile:(NSArray*) givenArray;
- (void)dismissVariusAlertview;
@end

@implementation GameViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self loadGamearea];
    [self loadBackgroundView];
}


#pragma mark - load views
- (void)loadGamearea {
    self.gamearea = [[UIScrollView alloc]initWithFrame:CGRectMake(0, kPaletteHeight, kViewWidth, kGameareaHeight)];
    self.gamearea.tag = 1;
    [self.gamearea setBounces:NO];
    [self.gamearea setShowsHorizontalScrollIndicator:NO];
    [self.gamearea setShowsVerticalScrollIndicator:NO];
}

//load the background images, including the clouds and a sun
- (void)loadBackgroundView {
    //sun
    UIImageView *sun = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"sun.png"]];
    sun.frame = CGRectMake(10, 30, 100, 100);
    [self.gamearea addSubview:sun];
    //clouds
    self.cloud1 = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"cloud1.png"]];
    self.cloud2 = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"cloud2.png"]];
    self.cloud1.center = CGPointMake(200, 80);
    self.cloud2.center = CGPointMake(750, 100);
    [self.gamearea addSubview:self.cloud1];
    [self.gamearea addSubview:self.cloud2];
    
    UIImage *bgImage = [UIImage imageNamed:kBackgroundImageName];
    UIImage *groundImage = [UIImage imageNamed:kGroundImageName];
    //Place them in an UIImageView
    UIImageView *background = [[UIImageView alloc]initWithImage:bgImage];
    UIImageView *ground = [[UIImageView alloc]initWithImage:groundImage];
    background.tag = 4;
    ground.tag = 5;
    self.gamearea.tag = 1;
    
    // Get the width and height of all the images
    CGFloat backgroundWidth = bgImage.size.width;
    CGFloat backgroundHeight = bgImage.size.height;
    CGFloat groundWidth = groundImage.size.width;
    CGFloat groundHeight = groundImage.size.height;
    
    CGFloat groundY = _gamearea.frame.size.height - groundHeight;
    CGFloat backgroundY = groundY - backgroundHeight;
    
    // Set the frame properties
    background.frame = CGRectMake(0, backgroundY, backgroundWidth, backgroundHeight);
    ground.frame = CGRectMake(0, groundY, groundWidth, groundHeight);
    
    
    // Add these views as subviews of the gamearea
    [self.gamearea addSubview:background];
    [self.gamearea addSubview:ground];
    [self.gamearea bringSubviewToFront:self.cloud1];
    [self.gamearea bringSubviewToFront:self.cloud2];
    [self.gamearea bringSubviewToFront:sun];
    
    // Set the content size so that gamearea is scrollable
    CGFloat gameareaHeight = groundY + groundHeight;
    CGFloat gameareaWidth = backgroundWidth;
    [self.gamearea setContentSize:CGSizeMake(gameareaWidth, gameareaHeight)];
    [self.view addSubview:self.gamearea];
    [self.view sendSubviewToBack:self.gamearea];
    
    //move the clouds
    [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(moveCloudsInBackground:) userInfo:nil repeats:YES];
    return;
}

//continuously move the clouds in the background
- (void)moveCloudsInBackground:(NSTimer*)t {
    CGFloat offset = self.gamearea.contentOffset.x;
    self.cloud1.center = CGPointMake(self.cloud1.center.x + 2, self.cloud1.center.y);
    if (self.cloud1.frame.origin.x - offset > kViewWidth) {
        self.cloud1.center = CGPointMake(offset - self.cloud1.frame.size.width / 2, self.cloud1.center.y);
    }
    self.cloud2.center = CGPointMake(self.cloud2.center.x + 5, self.cloud2.center.y);
    if (self.cloud2.frame.origin.x - offset > kViewWidth) {
        self.cloud2.center = CGPointMake(offset - self.cloud2.frame.size.width / 2, self.cloud2.center.y);
    }
}

//dummy loads implemented by subclasses
- (void)loadPaletteWolf {
    return;
}

- (void)loadPalettePig {
    return;
}

- (void)loadPaletteBlock {
    return;
}

#pragma mark - fileoperations
//the delegate sent by the load/delete popup for file operations
- (void)didMakeSelection:(id)selectionString withAction:(NSString*)action {
    if ([action isEqualToString:@"Load"]) {
        [self loadFromFile:selectionString];
    }
    else if ([action isEqualToString:@"Delete"]) {
        [self deleteFile:selectionString];
    }
    [self.popSegue.popoverController dismissPopoverAnimated:YES];
}

//returns all the files (designs) stored in the documents folder
- (NSArray*)getAllfilenames {
    NSArray* documentsFolder = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask,YES);
    NSString* documentString = [documentsFolder objectAtIndex:0];
    NSFileManager *fm = [NSFileManager defaultManager];
    NSArray *dirContents = [fm contentsOfDirectoryAtPath:documentString error:nil];
    return dirContents;
}

//based on the name of the file provided, loads the state in the view
- (void)loadFromFile:(NSString *)fileName {
    NSArray* documentsFolder = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask,YES);
    NSString* documentString = [documentsFolder objectAtIndex:0];
    NSString* fileLocation = [NSString stringWithFormat:@"%@/%@", documentString, fileName];
    NSData *data = [NSData dataWithContentsOfFile:fileLocation];
    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    id obj = [unarchiver decodeObjectForKey:@"wolfObj"];
    id obj2 = [unarchiver decodeObjectForKey:@"pigObj"];
    id obj3 = [unarchiver decodeObjectForKey:@"allBlocks"];
    [unarchiver finishDecoding];
    
    GameModel* tempwolf = (GameModel*)obj;
    GameModel* tempPig = (GameModel*)obj2;
    NSArray* tempBlocks = (NSArray*)obj3;
    
    if (tempwolf != nil) {
        [self loadWolfFromFile:tempwolf];
    }
    if (tempPig != nil) {
        [self loadPigFromFile:tempPig];
    }
    if (tempBlocks != nil) {
        [self loadBlocksFromFile: tempBlocks];
    }
}

//called by loadfromfile to load the wolf in the view
- (void)loadWolfFromFile:(GameModel*) givenWolf {
    [self.currentWolf.view removeFromSuperview];
   //only load wolf in palette if it is in designer mode
    if (givenWolf.currentState == kInPalette) {
        if (self.gameMode == kDesignerMode) {
            [self loadPaletteWolf];
        }
    }
    else {
        self.currentWolf = [[GameWolf alloc]initWithWolf:givenWolf];
        [self.gamearea addSubview:self.currentWolf.view];
    }
    return;
}

//called by loadfromfile to load the pig in the view
- (void)loadPigFromFile:(GameModel*) givenPig {
    [self.currentPig.view removeFromSuperview];
    //only load pig in palette if it is in designer mode
    if (givenPig.currentState == kInPalette) {
        if (self.gameMode == kDesignerMode) {
            [self loadPalettePig];
        }
    }
    else {
        self.currentPig = [[GamePig alloc]initWithPig:givenPig];
        [self.gamearea addSubview:self.currentPig.view];
    }
    return;
}

//called by loadfromfile to load the blocks in the view
- (void)loadBlocksFromFile:(NSArray*) givenArray {
    [self.currentBlock.view removeFromSuperview];
    self.currentBlock = [[GameBlocks alloc]initAllBlocksWithArray:givenArray];
    for (NSDictionary* eachBlock in ((GameBlocks*)self.currentBlock).allBlocks) {
        Blocks* thisBlock = [eachBlock objectForKey:@"block"];
        UIView* thisBlockview = [eachBlock objectForKey:@"blockImage"];
        //only load block in palette if it is in designer mode
        if (thisBlock.currentState == kInPalette) {
            if (self.gameMode == kDesignerMode) {
                [self.paletteArea addSubview:thisBlockview];
            }
        }
        else {
            [self.gamearea addSubview:thisBlockview];
        }
    }
    return;
}

//delets the file given or shows an error alert if the file is a presaved level
- (void)deleteFile:(NSString*)filename {
    if ([self isFilePresavedLevel:filename]) {
        NSString *message = @"You cannot delete a presaved level.";
        [self showSorryAlertWithMessage:message];
    }
    else {
        NSArray* documentsFolder = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask,YES);
        NSString* documentString = [documentsFolder objectAtIndex:0];
        NSString* fileLocation = [NSString stringWithFormat:@"%@/%@", documentString, filename];
        NSFileManager *fm = [NSFileManager defaultManager];
        [fm removeItemAtPath:fileLocation error:nil];
    }
}

//shows an error message for 2.5 seconds with the message provided
- (void)showSorryAlertWithMessage:(NSString*)message {
    self.variousAlerts = [[UIAlertView alloc] initWithTitle:@"Oooops!!!"
                                                    message:message
                                                   delegate:nil
                                          cancelButtonTitle:nil
                                          otherButtonTitles: nil];
    [self.gamearea addSubview:self.variousAlerts];
    [self.variousAlerts show];
    [self performSelector:@selector(dismissVariusAlertview) withObject:nil afterDelay:2.5];
}

- (void)dismissVariusAlertview {
    [self.variousAlerts dismissWithClickedButtonIndex:0 animated:YES];
}

//checks whether a given file is a presaved level
//presaved files are stored in a the folder 'Levels' in application bundle
//it compares it with all the files in this folder
- (BOOL)isFilePresavedLevel:(NSString*)filename {
    NSString *levelDir = [[NSBundle mainBundle]bundlePath];
    levelDir = [NSString stringWithFormat:@"%@/%@", levelDir, @"Levels"];
    NSArray *allLevels = [NSBundle pathsForResourcesOfType:@"" inDirectory:levelDir ];
    for (NSString *thisLevel in allLevels) {
        NSArray *tokens = [thisLevel componentsSeparatedByString:@"/"];
        if ([tokens.lastObject isEqualToString:filename]) {
            return YES;
        }
    }
    return NO;
}

//the segue used when a load/delete popup is called
//determines the size of the popup based o nthe number of files
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSArray* documentsFolder = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask,YES);
    NSString* documentString = [documentsFolder objectAtIndex:0];
    NSFileManager *fm = [NSFileManager defaultManager];
    NSArray *dirContents = [fm contentsOfDirectoryAtPath:documentString error:nil];
    
    //set the delegate and details for the destination controller
    self.popSegue = (UIStoryboardPopoverSegue*)segue;
    [[segue destinationViewController] setDelegate:self];
    FileListViewController *fileViewController = [segue destinationViewController];
    [fileViewController setFiles: dirContents];
    
    
    //resize the popover based on the content in the table (more files = larger popver)
    UIPopoverController *popOverController = self.popSegue.popoverController;
    int numOfFiles = [dirContents count];
    CGFloat popOverHeight = numOfFiles * 42 + 50;
    popOverHeight = (popOverHeight > 400)? 400: popOverHeight;
    [popOverController setPopoverContentSize:CGSizeMake(200, popOverHeight)];
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

@end
