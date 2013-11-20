#import "ViewController.h"
#import "RatPoly.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
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
-(NSUInteger)supportedInterfaceOrientations
{
    // return UIInterfaceOrientationMaskLandscapeRight;
    return UIInterfaceOrientationMaskAll;
    // return UIInterfaceOrientationMaskAllButUpsideDown;
}

- (IBAction)buttonPress:(id)sender {
	NSString *oper = [[sender titleLabel] text];
	NSString *arg1 = self.polyText1.text;
	NSString *arg2 = self.polyText2.text;
	NSString *resultStr;
	
	RatPoly *poly1 = [RatPoly valueOf:arg1];
	RatPoly *poly2 = [RatPoly valueOf:arg2];
	RatPoly *resultPoly;
	if ([oper isEqual:@"+"]) {
		resultPoly = [poly1 add:poly2];
	} else if ([oper isEqual:@"-"]) {
		resultPoly = [poly1 sub:poly2];
	} else if ([oper isEqual:@"*"]) {
		resultPoly = [poly1 mul:poly2];
	} else {
		resultPoly = [poly1 div:poly2];
	}
	resultStr = [resultPoly stringValue];
	
	[self.resultDisplay setText:resultStr];
}

@end
