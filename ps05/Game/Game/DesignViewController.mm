//
//  ViewController.m
//  Game
//
//  Created by Ishaan Singal on 27/1/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import "DesignViewController.h"
@interface DesignViewController ()
- (void)loadPalette;
- (void)loadPaletteWolf;
- (void)loadPalettePig;
- (void)loadPaletteBlock;
- (void)setupOptiontoolbar;
- (void)loadSavePopup;
- (BOOL)saveToFile:(NSString *)fileName;

@end
@implementation DesignViewController

- (void)viewDidLoad {
     self.gameMode = kDesignerMode;
    [super viewDidLoad];
    //Load the images into gamearea
    [self loadPalette];
    [self loadSavePopup];
    [self setupOptiontoolbar];
}

- (void)viewDidUnload {
    [self setGamearea:nil];
    [self setOptionToolBar:nil];
    [self setPaletteArea:nil];
    [self setStartButton:nil];
    [self setSaveButton:nil];
    [self setLoadButton:nil];
    [self setResetButton:nil];
    [super viewDidUnload];
}

#pragma mark - Button Pressed
//checks the buttons pressed and corresponds the action
- (IBAction)buttonPressed:(id)sender {
    NSString *buttonName = [sender titleForState:UIControlStateNormal];
    if ([buttonName isEqualToString:@"Start"]) {
        [self start];
    }
    else if ([buttonName isEqualToString:@"End"]) {
        [self end];
    }
    else if ([buttonName isEqualToString:@"Save"]) {
        [self save];
    }
    else  if ([buttonName isEqualToString:@"Reset"]) {
        [self reset];
    }
    else if ([buttonName isEqualToString:@"Back"]) {
        [self dismissViewControllerAnimated: YES completion: nil];
    }
}


#pragma mark - load initial views
//loads the palette - used in designer mode
- (void)loadPalette {
    self.paletteArea = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kViewWidth, kPaletteHeight)];
    [self.view addSubview:self.paletteArea];
    self.paletteArea.backgroundColor = [UIColor colorWithRed:1 green:160.0/255 blue:145.0/255 alpha:1];
    [self loadPaletteWolf];
    [self loadPalettePig];
    [self loadPaletteBlock];
    [self.view sendSubviewToBack:self.paletteArea];
    [self.view sendSubviewToBack:self.gamearea];
    self.paletteArea.tag = 2;
}

//load the wolf in the palette
- (void)loadPaletteWolf {
    //create the three palette images and itialize the game blocks
    UIImage* paletteWolfImage = [UIImage imageNamed:kWolfImageName];
    //set the initial sizes of the images
    CGPoint wolfImageOrigin = CGPointMake(kPaletteWolfOriginX, kPaletteWolfOriginY);
    CGSize wolfImageSize = CGSizeMake(kPaletteWolfWidth, kPaletteWolfHeight);
    
    //create a background image for wolf to be seen when wolf dragged down
    UIImageView *backgroundWolfPig = [[UIImageView alloc]initWithImage:paletteWolfImage];
    backgroundWolfPig.frame = CGRectMake(wolfImageOrigin.x, wolfImageOrigin.y, wolfImageSize.width, wolfImageSize.height);
    backgroundWolfPig.alpha = 0.3;
    [self.paletteArea addSubview:backgroundWolfPig];
    
    //initialize the gameobjects based on the palette info of each object
    self.currentWolf = [[GameWolf alloc]initWithImage:paletteWolfImage
                                               Origin:wolfImageOrigin
                                                 Size:wolfImageSize
                                           ObjectType:kGameObjectWolf];
    //add them to the palette UIView
    [self.paletteArea addSubview:self.currentWolf.view];
}

//load the pig in the palette
- (void)loadPalettePig {
    //create the three palette images and itialize the game blocks
    UIImage* palettePigImage = [UIImage imageNamed:kPigImageName];
    //set the initial sizes of the images
    CGPoint pigImageOrigin = CGPointMake(kPalettePigOriginX, kPalettePigOriginY);
    CGSize pigImageSize = CGSizeMake(kPalettePigWidth, kPalettePigHeight);
    
    //create a background image for pig to be seen when pig dragged down
    UIImageView *backgroundPalettePig = [[UIImageView alloc]initWithImage:palettePigImage];
    backgroundPalettePig.frame = CGRectMake(pigImageOrigin.x, pigImageOrigin.y, pigImageSize.width, pigImageSize.height);
    backgroundPalettePig.alpha = 0.3;
    [self.paletteArea addSubview:backgroundPalettePig];
    //initialize the gameobjects based on the palette info of each object
    self.currentPig = [[GamePig alloc]initWithImage:palettePigImage
                                             Origin:pigImageOrigin
                                               Size:pigImageSize
                                         ObjectType:kGameObjectPig];
    //add them to the palette UIView
    [self.paletteArea addSubview:self.currentPig.view];
}

//load a block in the palette
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
    [self.paletteArea addSubview:[((GameBlocks*)self.currentBlock) getPaletteView]];
}

//set up the buttons in the option toolbar
- (void)setupOptiontoolbar {
    NSArray *allButtons = self.optionToolBar.items;
    for (UIBarButtonItem *thisButton in allButtons) {
        CALayer *playButtonLayer = thisButton.customView.layer;
        [playButtonLayer setCornerRadius:8.0f];
        playButtonLayer.masksToBounds = YES;
        playButtonLayer.borderWidth = 1.0f;
    }
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

#pragma mark - rest
- (void)reset {
    // MODIFIES: self (game objects)
    // REQUIRES: game in designer mode
    // EFFECTS: current game objects are deleted and palette contains all objects
    
    [self.currentWolf removeGameObj];
    [self.currentPig removeGameObj];
    [self.currentBlock removeGameObj];
    for (UIImageView *thisView in self.paletteArea.subviews) {
        [thisView removeFromSuperview];
    }
    [self loadPaletteWolf];
    [self loadPalettePig];
    [self loadPaletteBlock];
}

#pragma mark - Start/End Design Play
//play the level created in designer
//the design is stored as a temporary name "tempdesigntest" and will be deleted
//when the user gets back to desgin phase
- (void)start {
    //disable save/load/reset in this particular play mode and show end
    //rename the start button as "End" to end this state
    if ([self isStartModePossible]) {
        [self saveToFile:@"tempdesigntest"];
        [self.startButton setTitle:@"End" forState:UIControlStateNormal];
        [self.saveButton setHidden:YES];
        [self.loadButton setHidden:YES];
        [self.resetButton setHidden:YES];
        [self startPlay];
    }
    //if designed game cannot be played show an error message
    else {
        NSString *message = @"Both the pig and the wolf need to be in the Game area";
        [self showSorryAlertWithMessage:message];
    }
}

//end the level being played in designer mode
//the design stored as "tempdesigntest" is loaded and the file itself deleted
- (void)end {
    //show all the buttons, and rename the "End" buton as "Start"
    [self.startButton setTitle:@"Start" forState:UIControlStateNormal];
    [self.saveButton setHidden:NO];
    [self.loadButton setHidden:NO];
    [self.resetButton setHidden:NO];
    [self endPlay];

    [self loadFromFile:@"tempdesigntest"];
    [self deleteFile:@"tempdesigntest"];
}


- (void)gameEndButtonPressed:(UIButton*)bt {
    NSString *buttonTitle = bt.titleLabel.text;
    if([buttonTitle isEqualToString:@"End"]) {
        self.gamearea.alpha = 1;
        self.gameEndAlertView.hidden = YES;
        [self end];
    }
}

#pragma mark - Save designer
- (void)save {
    // REQUIRES: game in designer mode
    // EFFECTS: game objects are saved
    self.savePopup.title = @"Please enter the name of file to be saved";
    [self.savePopup show];
}

//handles the alertview delegates
//handlge the alertview to save the file & click OK for the gameover state
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    //check if this alertview is the savePopup
    NSString *buttonTitle=[alertView buttonTitleAtIndex:buttonIndex];
    if (alertView == self.savePopup) {
        if([buttonTitle isEqualToString:@"Save"]) {
            NSString* inputFileName = [[alertView textFieldAtIndex:0] text];
            //if the input name is a presaved level, the user cannot enter that level
            if ([self isFilePresavedLevel:inputFileName]) {
                self.savePopup.title = @"Name entered is a presaved level. Please enter another name";
                [self.savePopup performSelector:@selector(show) withObject:nil afterDelay:0.5];
            }
            //otherwise save that file
            else {
                BOOL isFileSaved = [self saveToFile: inputFileName];
                [alertView textFieldAtIndex:0].text = nil;
                (isFileSaved)? [self showSaveSuccessAlert]: [self showSaveFailureAlert];
            }
        }
    }
}

//shows the success message when a file is succesfully saved
- (void)showSaveSuccessAlert {
    NSString* alertMessage = @"File successfully saved!";
    UIAlertView* saveconfirm = [[UIAlertView alloc] initWithTitle:nil
                                                          message:alertMessage
                                                         delegate:nil
                                                cancelButtonTitle:@"OK"
                                                otherButtonTitles:nil];
    [saveconfirm show];
}

//shows the failure message when a file is succesfully saved
- (void)showSaveFailureAlert {
    NSString* alertMessage = @"Sorry, the file could not be saved! Please try again!";
    UIAlertView* errorSave = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:alertMessage
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
    [errorSave show];
}

//handles the file operations on the given filename
//saves the filename given in the document directory
- (BOOL)saveToFile:(NSString *)fileName {
    NSMutableData *data = [NSMutableData data];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    [archiver encodeObject:self.currentWolf.modelObj forKey:@"wolfObj"];
    [archiver encodeObject:self.currentPig.modelObj forKey:@"pigObj"];
    [archiver encodeObject:((GameBlocks*)self.currentBlock).allBlocks forKey:@"allBlocks"];
    [archiver finishEncoding];
    NSArray* documentsFolder = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask,YES);
    NSString* documentString = [documentsFolder objectAtIndex:0];
    NSString* fileLocation = [NSString stringWithFormat:@"%@/%@", documentString, fileName];
    BOOL result = [data writeToFile: fileLocation atomically:YES];
    return result;
}


@end
