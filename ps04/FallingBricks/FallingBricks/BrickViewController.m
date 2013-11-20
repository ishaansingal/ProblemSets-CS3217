/*
 Brick View controller is the class that contains a PhysicsEngine object and maintains 
 all the views of the bricks and the walls. It also implements the delegates of 
 the model class; when it recieves the delegate from the model class, it updates
 the view of the model object correspondingly.
 */

#import "BrickViewController.h"
#import <CoreMotion/CoreMotion.h>
@interface BrickViewController ()
@property (readwrite) PhysicsEngine *world;
@property (readwrite) NSArray *brickViews;
@property (readwrite) NSArray *wallViews;
@property (readwrite) RectangleShape *rShape;
- (void)loadWallViews;
- (void)loadBrickViews;
- (int)findIndexOfBrick:(PhysicsModel*)brick;

@end

@implementation BrickViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //modify this to change the timestep/gravity
    self.world = [[PhysicsEngine alloc]initWithTimeStep:0.0167 GMultiplier:50];
    [self.world initializeWallObjects];
    [self.world initializeBrickObjects];
    [self loadWallViews];
    [self loadBrickViews];
    //starts the timer in PhysicsEngine
    [self.world startEngine];
    //method that uses the accelerometer of the device for gravity
//    [self.world startMotionDetection];
}

//Requires: world.allImmovables != nil and [world.allImmovables count] = 4
//or else there will be no walls in the view
//after initialising the model walls, load its views on main frame
- (void)loadWallViews {
    [self.view setNeedsDisplay];
    NSMutableArray *walls = [[NSMutableArray alloc]initWithCapacity:4];
    for (int i = 0; i < [self.world.allImmovables count]; i++) {
        PhysicsModel *currentWall = [self.world.allImmovables objectAtIndex:i];
        UIView *currentWallView = [[UIView alloc]initWithFrame:CGRectMake (0, 0, currentWall.size.width, currentWall.size.height)];
        [currentWallView setCenter:currentWall.center];
        [currentWallView setBackgroundColor: [UIColor blackColor]];
        [self.view addSubview:currentWallView];
        [walls addObject:currentWallView];
    }
    _wallViews = [[NSArray alloc]initWithArray:walls];
    return;
}

//Requires: world.allMovables != nil
//or else there will be no blocks in the view
//after initialising the model bricks, load its views on main frame
- (void)loadBrickViews {
    NSArray *colors = [[NSArray alloc]initWithObjects:[UIColor blueColor],
                       [UIColor greenColor],
                       [UIColor redColor],
                       [UIColor yellowColor],
                       [UIColor grayColor],
                       [UIColor purpleColor],
                       [UIColor brownColor],
                       nil];
    
    NSMutableArray *bricks = [[NSMutableArray alloc]initWithCapacity:[self.world.allMovables count]];
    self.rShape = [[RectangleShape alloc]initWithModel:self.world.allMovables Color:colors];
    [self.view addSubview:self.rShape];
    for (int i = 0; i < [self.world.allMovables count]; i++) {
        PhysicsModel *currentBrick = [self.world.allMovables objectAtIndex:i];
        //add self as the delegate of the Model
        [currentBrick setDelegate:self];
    }
//        UIView *currentBrickView = [[UIView alloc]initWithFrame:CGRectMake (0, 0, currentBrick.size.width, currentBrick.size.height)];
//        [currentBrickView setCenter:currentBrick.center];
//        [currentBrickView setTransform:CGAffineTransformRotate(CGAffineTransformIdentity, currentBrick.rotation)];
//        [currentBrickView setBackgroundColor: [colors objectAtIndex:i]];
//        if (currentBrick.shape == kCircle) {
//            currentBrickView.layer.cornerRadius = currentBrick.size.width/2;
//        }
//        [self.view addSubview:currentBrickView];
//        [bricks addObject:currentBrickView];
//    }
//    _brickViews = [[NSArray alloc]initWithArray:bricks];
    return;
}

//Requires: The 'sender' should be present in the movables object array
//translates the object in the world
- (void)didMove:(id)sender {
    [self.rShape setNeedsDisplay];
    
//    PhysicsModel *currentBrick = (PhysicsModel*)sender;
//    int index = [self findIndexOfBrick:currentBrick];
//    UIView *currentView = [self.brickViews objectAtIndex:index];
//    [currentView setCenter:currentBrick.center];
}

//Requires: The 'sender' should be present in the movables object array
//rotates the view of the brick
- (void)didRotate:(id)sender {
        [self.rShape setNeedsDisplay];
//    PhysicsModel *currentBrick = (PhysicsModel*)sender;
//    int index = [self findIndexOfBrick:currentBrick];
//    UIView *currentView = [self.brickViews objectAtIndex:index];
//    [currentView setTransform:CGAffineTransformRotate(CGAffineTransformIdentity, currentBrick.rotation)];
}


//helper method to know which brick sent the delegate, for view matching
//if not found returns -1
- (int)findIndexOfBrick:(PhysicsModel*)brick {
    int index = -1;
    for (int i = 0; i < [self.world.allMovables count]; i++) {
        PhysicsModel *currentModel = [self.world.allMovables objectAtIndex:i];
        if (brick == currentModel) {
            index = i;
            break;
        }
    }
    return index;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
