/*
 DesignViewController is responsible for the functionality in the design mode
 It is the subclass of GameViewController and many of its functions are implemented
 there.
 Itself, it responsible for the palette,
 handles the save functionality (only offered in desginer),
 Starting and ending design created
 */

#import <UIKit/UIKit.h>
#import "GameViewController.h"
#import "GameWolf.h"
#import "GamePig.h"
#import "GameBlocks.h"
#import "GameBreath.h"
#import "Constants.h"
#import "Utilities.h"
#import "MyContactListener.mm"
#import <QuartzCore/QuartzCore.h>
#import <Box2D/Box2D.h>
#import "FileListViewController.h"
#import "GameEngineSupport.h"

@interface DesignViewController : GameViewController 

@property(strong, nonatomic) IBOutlet UIButton *startButton;
@property(strong, nonatomic) IBOutlet UIButton *saveButton;
@property(strong, nonatomic) IBOutlet UIButton *loadButton;
@property(strong, nonatomic) IBOutlet UIButton *resetButton;
@property(strong, nonatomic) IBOutlet UIToolbar *optionToolBar;

- (IBAction)buttonPressed:(id)sender;


- (void)save;
// REQUIRES: game in designer mode & the name doesnt conflct with preloaded level
// EFFECTS: save the gamestate in the given filename in documents directory

- (void)reset;
// MODIFIES: self (game objects)
// REQUIRES: game in designer mode
// EFFECTS: current game objects are deleted and palette contains all objects


- (void)start;
// REQUIRES: in the design made, the wolf and pig be in the gamearea
// EFFECTS: if pig & wolf are not in the gamearea, doesnt do anything, otherwise
//          enables the user to play the design he just created

- (void)end;
// REQUIRES: the game is being played (and not designed)
// EFFECTS: ends a currently active design and returns it in the state the game ended

@end
