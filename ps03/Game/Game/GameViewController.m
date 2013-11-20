//
//  ViewController.m
//  Game
//
//  Created by Ishaan Singal on 27/1/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import "GameViewController.h"
@interface GameViewController ()
- (void)loadBackgroundView;
- (void)loadMenuToolbar;
- (void)loadSavePopup;
@end
@implementation GameViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    //Load the images into objects
    [self loadBackgroundView];
    [self loadMenuToolbar];
    [self loadPalette];
    [self loadActionPickerView];
    [self loadSavePopup];
    
}

- (void)loadBackgroundView {
    UIImage *bgImage = [UIImage imageNamed:@"background.png"];
    UIImage *groundImage = [UIImage imageNamed:@"ground.png"];
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
    
    // Set the content size so that gamearea is scrollable
    CGFloat gameareaHeight = backgroundHeight + groundHeight;
    CGFloat gameareaWidth = backgroundWidth;
    [self.gamearea setContentSize:CGSizeMake(gameareaWidth, gameareaHeight)];
    return;
}

- (void)loadMenuToolbar {
    //A toolbar at the bottom for start, save, load, reset
    CGFloat toolBarOriginY = self.gamearea.frame.origin.y + self.gamearea.frame.size.height;
    CGFloat toolBarWidth = self.gamearea.frame.size.width;
    CGFloat toolBarHeight = self.view.frame.size.height - toolBarOriginY;
    CGRect toolbarRect = CGRectMake(0, toolBarOriginY, toolBarWidth, toolBarHeight);
    [self.optionToolBar setFrame:toolbarRect];
    [self.optionToolBar setBarStyle: UIBarStyleBlack];
    self.optionToolBar.tag = 3;
    return;
}

- (void)loadPalette {
    [self loadPaletteWolf];
    [self loadPalettePig];
    [self loadPaletteBlock];
    self.paletteArea.tag = 2;
}

- (void)loadPaletteWolf {
    //create the three palette images and itialize the game blocks
    UIImage* paletteWolfImage = [UIImage imageNamed:kWolfImageName];
    //set the initial sizes of the images
    CGPoint wolfImageOrigin = CGPointMake(kPaletteWolfOriginX, kPaletteWolfOriginY);
    CGSize wolfImageSize = CGSizeMake(kPaletteWolfWidth, kPaletteWolfHeight);
    //initialize the gameobjects based on the palette info of each object
    self.currentWolf = [[GameWolf alloc]initWithImage:paletteWolfImage
                                           Origin:wolfImageOrigin
                                             Size:wolfImageSize
                                       ObjectType:kGameObjectWolf];
    //add them to the palette UIView
    [self.paletteArea addSubview:self.currentWolf.imageView];
}

- (void)loadPalettePig {
    //create the three palette images and itialize the game blocks
    UIImage* palettePigImage = [UIImage imageNamed:kPigImageName];
    //set the initial sizes of the images
    CGPoint pigImageOrigin = CGPointMake(kPalettePigOriginX, kPalettePigOriginY);
    CGSize pigImageSize = CGSizeMake(kPalettePigWidth, kPalettePigHeight);
    //initialize the gameobjects based on the palette info of each object
    self.currentPig = [[GamePig alloc]initWithImage:palettePigImage
                                         Origin:pigImageOrigin
                                           Size:pigImageSize
                                     ObjectType:kGameObjectPig];
    //add them to the palette UIView
    [self.paletteArea addSubview:self.currentPig.imageView];
}

- (void)loadPaletteBlock {
    //create the three palette images and itialize the game blocks
    UIImage* paletteStrawImage = [UIImage imageNamed:kStrawImageName];
    //set the initial sizes of the images
    CGPoint blockImageOrigin = CGPointMake(kPaletteBlockOriginX, kPaletteBlockOriginY);
    CGSize blockImageSize = CGSizeMake(kPaletteBlockWidth, kPaletteBlockHeight);
    //initialize the gameobjects based on the palette info of each object
    self.currentBlock = [[GameBlocks alloc]initWithImage:paletteStrawImage
                                              Origin:blockImageOrigin
                                                Size:blockImageSize
                                          ObjectType:kGameObjectBlock];
    //add them to the palette UIView
    [self.paletteArea addSubview:self.currentBlock.imageView];
}


- (void)loadSavePopup {
    //EFFECTS: loads the savepopup alertview, displayed only when the save button is pressed
    NSString* alertMessage = @"Please enter the name of file to be saved";
    self.savePopup = [[UIAlertView alloc] initWithTitle:alertMessage
                                                message:@""
                                               delegate:nil
                                      cancelButtonTitle:@"Save"
                                      otherButtonTitles:@"Cancel", nil];
    self.savePopup.alertViewStyle = UIAlertViewStylePlainTextInput;
    [self.savePopup setDelegate:self];
}


- (void)loadActionPickerView {
    self.fileNames = [[NSArray alloc] initWithObjects:@"no files saved", nil];
    self.actionsheet = [[UIActionSheet alloc] initWithTitle:@"\n\n\n\n\n\n\n\n\n\n\n\n\n\n"
                                                   delegate:nil cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
    
    [self.actionsheet setActionSheetStyle:UIActionSheetStyleBlackTranslucent];
    self.picker = [[UIPickerView alloc]initWithFrame:CGRectMake(10, 55, 250, 150)];
    [self.picker setDelegate: self];
    [self.picker setDataSource: self];
    self.picker.showsSelectionIndicator = YES;
    
    UIToolbar *pickerDateToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(10, 0, 250, 44)];
    pickerDateToolbar.barStyle = UIBarStyleBlackTranslucent;
    
    NSMutableArray *barItems = [[NSMutableArray alloc] init];
    UIBarButtonItem *doneBtn = [[UIBarButtonItem alloc] initWithTitle:@"Load" style:UIBarButtonItemStyleDone target:self action:@selector(dismissActionSheet:)];
    [barItems addObject:doneBtn];
    
    UIBarButtonItem *cancelBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(dismissActionSheet:)];
    [barItems addObject:cancelBtn];
    [pickerDateToolbar setItems:barItems animated:YES];
    
    [self.actionsheet addSubview:pickerDateToolbar];
    [self.actionsheet addSubview:self.picker];
}

- (NSString *)pickerView:(UIPickerView *)thePickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return [self.fileNames objectAtIndex:row];
}
- (NSInteger)pickerView:(UIPickerView *)thePickerView numberOfRowsInComponent:(NSInteger)component {
    
    return [self.fileNames count];
}
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)thePickerView {
    
    return 1;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setGamearea:nil];
    [self setOptionToolBar:nil];
    [self setPaletteArea:nil];
    [super viewDidUnload];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"StartPlay"]) {
        GameViewController *detailViewController = [segue destinationViewController];
    }
}

// Override to allow orientations other than the default portrait orientation.
// Rotation for v. 5.1.1
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

// Rotation 6.0
// Tell the system It should autorotate
- (BOOL) shouldAutorotate {
    return YES;
}

// Tell the system which initial orientation we want to have
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait;
}

// Tell the system what we support
- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAll;
}

@end
