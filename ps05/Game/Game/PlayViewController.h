/*
 PlayViewController is responsible for the functionality in the Play mode
 It is the subclass of GameViewController and many of its functions are implemented
 there.
 Itself, it handles the save functionality of loading a level & going to the
 next/previous level. It also implements Restart (reload the current level).
 It keeps the check for whether is selected level (through load) can be be played or not 
 */

#import <UIKit/UIKit.h>
#import "GameViewController.h"
#import "Constants.h"
#import "GameWolf.h"
#import "GamePig.h"
#import "GameBlocks.h"
#import "GameBreath.h"
#import "Constants.h"
#import "Utilities.h"
#import "MyContactListener.mm"
#import <QuartzCore/QuartzCore.h>
#import <Box2D/Box2D.h>
#import "GameEngineSupport.h"

@interface PlayViewController : GameViewController <ObjectModifyDelegate>

@property(strong, nonatomic) IBOutlet UIToolbar *optionToolbar;

- (IBAction)backButtonPressed:(id)sender;
- (IBAction)restartButtonPressed:(id)sender;


@end
