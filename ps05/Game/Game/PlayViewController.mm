//
//  PlayViewController.m
//  Game
//
//  Created by Ishaan Singal on 1/3/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import "PlayViewController.h"
#import "MyContactListener.mm"
@interface PlayViewController ()
@property UIStoryboardSegue *test;
- (void)setupOptiontoolbar;
- (void)loadNextGame;
- (BOOL)isValidFile:(NSString*)fileName;

@end

@implementation PlayViewController

//after loading the gamearea, it loads all other views
- (void)viewDidLoad {
    self.gameMode = kPlayMode;
    [super viewDidLoad];
    [self setupOptiontoolbar];
    [self setupScore];
    [self loadNextGame];
    
}

//customise soom toolbar buttons
- (void)setupOptiontoolbar {
    NSArray *allButtons = self.optionToolbar.items;
    for (UIBarButtonItem *thisButton in allButtons) {
        CALayer *playButtonLayer = thisButton.customView.layer;
        [playButtonLayer setCornerRadius:8.0f];
        playButtonLayer.masksToBounds = YES;
        playButtonLayer.borderWidth = 1.0f;
    }
}

//loads the next level from the save list in document directory
//if the last file is reached, it restarts with the first level
- (void)loadNextGame {
    NSArray *allFiles = [[NSArray alloc]initWithArray:[self getAllfilenames]];
    int i = 0;
    //get the index of the currentlevel
    if (self.currentLevel != nil) {
        for (i = 0; i < (int)[allFiles count]; i++) {
            NSString *thisLevel  = [allFiles objectAtIndex:i];
            NSArray *tokens = [thisLevel componentsSeparatedByString:@"/"];
            if ([self.currentLevel isEqualToString:tokens.lastObject]) {
                break;
            }
        }
        i++;
    }
    //get the next valid level in the stored list
    NSArray *tokens = [NSArray array];
    do {
        if (i == (int)[allFiles count]) {
            i = 0;
        }
        tokens = [[allFiles objectAtIndex:i] componentsSeparatedByString:@"/"];
        i++;
    } while (![self isValidFile:tokens.lastObject]);
    self.currentLevel = tokens.lastObject;
    [self loadLevel:tokens.lastObject];
}

//as soon as restart is pressed, simply reload the same level
- (IBAction)restartButtonPressed:(id)sender {
    [self loadLevel:self.currentLevel];
}

//REQUIRES: the levelName should be valid for playing
//Effects: Loads the given level in the view
- (void)loadLevel:(NSString*)levelName {
    [self endPlay];
    [super loadFromFile:levelName];
    self.gamearea.contentOffset = CGPointMake(0, 0);
    [self startPlay];    
}

//Called after the game as ended and the user has either won/lost
//and clicked whether he wants to retry/next level
- (void)gameEndButtonPressed:(UIButton*)bt {
    NSString *buttonTitle = bt.titleLabel.text;
    if([buttonTitle isEqualToString:@"Retry"]) {
        self.gamearea.alpha = 1;
        self.gameEndAlertView.hidden = YES;
        [self loadLevel:self.currentLevel];
    }
    else if([buttonTitle isEqualToString:@"Next Level"]) {
        self.gamearea.alpha = 1;
        self.gameEndAlertView.hidden = YES;
        [self loadNextGame];
    }
}


#pragma mark - load button pressed
//the delegate implementation for the load/delete popup. it overrides the superclass
//implementation to disable loading of files that dont have both pig & wolf in gamearea
//checks if delete is posible
- (void)didMakeSelection:(id)selectionString withAction:(NSString*)action {
    //close the popup
    [self.popSegue.popoverController dismissPopoverAnimated:YES];
    if ([action isEqualToString:@"Load"]) {
        //load if the file is valid
        if ([self isValidFile:selectionString]) {
            self.currentLevel = selectionString;
            [self endPlay];
            [self loadFromFile:selectionString];
            self.gamearea.contentOffset = CGPointMake(0, 0);
            [self startPlay];
        }
        //if not valid, display a sorry alert and reopen the load
        else {
            NSString *message = @"The selected design does not have both Pig and Wolf in the GameArea";
            [self showSorryAlertWithMessage:message];
            [self performSegueWithIdentifier:@"loadPopupSegue" sender:self];
        }
    }
    else if ([action isEqualToString:@"Delete"]) {
        //if delete file in play, display a sorry alert and reopen the load/delete popup
        if ([self.currentLevel isEqualToString:selectionString]) {
            NSString *message = @"The level is currently in play!";
            [self showSorryAlertWithMessage:message];
            [self performSegueWithIdentifier:@"loadPopupSegue" sender:self];
        }
        else {
            [self deleteFile:selectionString];
        }
    }
}

//check if the file is valid by reading the data and checking if the objects are in gamearea
- (BOOL)isValidFile:(NSString*)fileName{
    BOOL result = NO;
    NSArray* documentsFolder = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask,YES);
    NSString* documentString = [documentsFolder objectAtIndex:0];
    NSString* fileLocation = [NSString stringWithFormat:@"%@/%@", documentString, fileName];
    NSData *data = [NSData dataWithContentsOfFile:fileLocation];
    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    id obj = [unarchiver decodeObjectForKey:@"wolfObj"];
    id obj2 = [unarchiver decodeObjectForKey:@"pigObj"];
    [unarchiver finishDecoding];
    
    GameModel* tempwolf = (GameModel*)obj;
    GameModel* tempPig = (GameModel*)obj2;
    if (tempwolf.currentState == kInGame && tempPig.currentState == kInGame) {
        result = YES;
    }
    return result;
}

//dismiss this screen and go back to root screen
- (IBAction)backButtonPressed:(id)sender {
    [self dismissViewControllerAnimated: YES completion: nil];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (void)viewDidUnload {
    [self setGamearea:nil];
    [self setOptionToolbar:nil];
    [super viewDidUnload];
}
@end
