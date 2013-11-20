/*
 GameViewController is responsible for the initial loading of the palette, 
 gamarea and the toolbar
 It contains three gameObject objects, which it initalizes at the start (in the
 palette) and then does not deal with them (unless save, load, or reset is pressed)
 It contains further UIView properties for displaying certain errors and lists
 (mainly to do with saving, loading)
 */

#import <UIKit/UIKit.h>
//@class GameObject, GameWolf;
#import "GameWolf.h"
#import "GamePig.h"
#import "GameBlocks.h"
#import "Constants.h"
#import <QuartzCore/QuartzCore.h>

@interface GameViewController : UIViewController <UIGestureRecognizerDelegate, UIAlertViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UIActionSheetDelegate>

@property(strong, nonatomic) IBOutlet UIScrollView *gamearea;
@property(strong, nonatomic) IBOutlet UIToolbar *optionToolBar;
@property(strong, nonatomic) IBOutlet UIView *paletteArea;

@property(strong, nonatomic) IBOutlet UIAlertView *savePopup;
@property(strong, nonatomic) IBOutlet UIPickerView *picker;
@property(strong, nonatomic) IBOutlet UIActionSheet *actionsheet;
@property(strong, nonatomic) NSArray *fileNames;

@property(strong, readwrite) GameObject* currentWolf;
@property(strong, readwrite) GameObject* currentPig;
@property(strong, readwrite) GameObject* currentBlock;

- (void)loadPalette;
  //EFFECTS: loads the palette and the game objects in it
- (void)loadPaletteWolf;
- (void)loadPalettePig;
- (void)loadPaletteBlock;
- (void)loadActionPickerView;
  //EFFECTS: loads the actionsheet and pickerview but only shows it when load is pressed
@end
