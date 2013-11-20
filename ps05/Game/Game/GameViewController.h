/*
 Parent class of the view controllers - PlayViewController and DesignViewController
 It implements the common functions in the subview controllers
 It loads the background views, and keeps the wolf,pig and blocks of the game
 It also implements the functionality Load and Delete - common to both subclasses.
 Its extension GameEngineSupport has all the functions for Playing a game
 
 */

#import <UIKit/UIKit.h>
#import "GameWolf.h"
#import "GamePig.h"
#import "GameBlocks.h"
#import "GameBreath.h"
#import "Constants.h"
#import "Utilities.h"
#import <QuartzCore/QuartzCore.h>
#import <Box2D/Box2D.h>
#import "FileListViewController.h"
@interface GameViewController : UIViewController <TableSelectorDelegate>

@property(strong, nonatomic) IBOutlet UIView *paletteArea;
@property(strong, nonatomic) IBOutlet UIScrollView *gamearea;

@property(strong, readwrite) GameObject* currentWolf;
@property(strong, readwrite) GameObject* currentPig;
@property(strong, readwrite) GameObject* currentBlock;
@property(strong, readwrite) GameBreath *wolfBreath;

@property(strong, nonatomic) IBOutlet UIAlertView *savePopup;
@property UIAlertView *variousAlerts;
@property UIView *gameEndAlertView;

@property NSString *currentLevel;
@property(nonatomic) GameMode gameMode;
@property (strong, nonatomic) UIStoryboardPopoverSegue* popSegue;

@property(strong, readwrite) NSTimer *engineTimer;
@property(strong, readwrite) NSTimer *lastBreathTimer;
@property b2ContactListener *contactListener;
@property b2World *world;
@property NSArray *allWalls;
@property UIImageView *score;
@property UIImageView *pigHealth;
@property UILabel *scoreLabel;
@property UIImageView *cloud1;
@property UIImageView *cloud2;

- (void)loadFromFile:(NSString *)fileName;
// MODIFIES: self (game objects)
// EFFECTS: game objects are loaded

- (void)loadPaletteWolf;

- (void)loadPalettePig;

- (void)loadPaletteBlock;

- (void)deleteFile:(NSString*)filename;

- (BOOL)isFilePresavedLevel:(NSString*)filename;

- (void)showSorryAlertWithMessage:(NSString*)message;

- (NSArray*)getAllfilenames;
@end
