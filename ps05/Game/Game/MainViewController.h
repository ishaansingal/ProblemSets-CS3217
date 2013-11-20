/*
 The Main Screen that shows when the application launches.
 It has two buttons play & design that launch the respective viewcontrollers
 
 */

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "Constants.h"

@interface MainViewController : UIViewController
@property (strong, nonatomic) IBOutlet UIView *mainView;
@property (strong, nonatomic) IBOutlet UIButton *playButton;
@property (strong, nonatomic) IBOutlet UIButton *designButton;
@property (strong, nonatomic) IBOutlet UIToolbar *optionToolbar;
@property (strong, nonatomic) IBOutlet UIImageView *cloud1View;
@property (strong, nonatomic) IBOutlet UIImageView *cloud2View;

@end
