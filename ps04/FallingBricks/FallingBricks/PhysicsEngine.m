

#import "PhysicsEngine.h"

@interface PhysicsEngine ()
@property double timeStep;
@property double GMultiplier;
@property (readwrite) Vector2D *gravity;
@property (readwrite) NSArray *allMovables;
@property (readwrite) NSArray *allImmovables;
@property CMMotionManager *motionTrack;
@property NSTimer *timer;


- (NSTimer*)setTimer;
- (void)updateAccelerometerGravity;
- (void)updateGravity;
- (void)updateOrientationGravity;
- (void)updateWorldObjects: (NSTimer*)timer;
- (void)applyForceAndTorque;
- (BOOL)detectCollisionBetween:(PhysicsModel*)firstModel SecondModel:(PhysicsModel*)secondModel;
- (NSDictionary*)setMasterDictionary:(PhysicsModel*)firstModel SecondModel:(PhysicsModel*)secondModel;
- (int)getReferenceEdge:(NSDictionary*)masterDict;
- (NSDictionary*)getReferenceEdgeValues:(NSDictionary*)masterDict Ftype:(int)fType;
- (NSArray*)getIncidentPoints:(NSDictionary*)referenceEdgeDict;
- (NSArray*)getClippedPoints:(NSDictionary*)referenceEdgeDict IncidentPoints:(NSArray*)incidentPoints;
- (NSDictionary*)getcontactPoints:(NSDictionary*)referenceEdgeDict ClippedPoints:(NSArray*)clippedPoints;
- (void)applyImpulsesAtContacts:(NSArray*)contacts
                     Separation:(NSArray*)separation
                         Normal:(Vector2D*)n
                        Between:(PhysicsModel*)firstModel
                    SecondModel:(PhysicsModel*)secondModel;
- (void)computeNewPositions:(PhysicsModel*)givenModel;
- (void)detectCollisionEachOther;
- (void)applyImpulseForCircleAtContact:(Vector2D *)contact
                            Seperation:(CGFloat)seperation
                                Normal:(Vector2D*)n
                               Between:(PhysicsModel*)firstModel
                           SecondModel:(PhysicsModel*)secondModel;

@end

@implementation PhysicsEngine

//REQUIRES: a positive valid timestep
//EFFECTS: initialize the timestep, gravity multiplier
- (id)initWithTimeStep:(double)step GMultiplier:(double)gMult{
    self = [super init];
    if (self) {
        self.timeStep = step;
        self.GMultiplier = gMult;
    }
    return self;
}

//can be used in when integrating with other entities, as in this project, the engine
//itself creates the objects and allocates in the array (for simplicity purposes)
- (void)initImmovablesWithArray:(NSArray*)objectArray {
    _allImmovables = [[NSArray alloc]initWithArray:objectArray];
    return;
}


//can be used in when integrating with other entities, as in this project, the engine
//itself creates the objects and allocates in the array (for simplicity purposes)
- (void)initMovablesWithArray:(NSArray*)objectArray {
    _allMovables = [[NSArray alloc]initWithArray:objectArray];
    return;
}

//REQUIRES: self.timeStep to be a valid value ( timestep >0 and <0.2 preferrably)
//EFFECTS: starts the timer engine to trigger a loop for every timestep
- (void)startEngine {
    self.timer = [self setTimer];
    return;
}

//EFFECTS: stops the timer engine and the collision is no longer detected periodically
- (void)stopEngine {
    [self.timer invalidate];
    self.timer = nil;
}

//REQUIRES: although the program would not fail, it will cause problems if it
//doesnt have accelerometer
//EFFECTS: starts the motion detection if available
- (void)startMotionDetection {
    self.motionTrack = [[CMMotionManager alloc]init];
    if ([self.motionTrack isAccelerometerAvailable]){
        [self.motionTrack startAccelerometerUpdates];
    }
}

//REQUIRES: self.timeStep to be a valid value ( timestep >0 and <0.2 preferrably)
//EFFECTS: sets the timer in the thread created for the interval timestep
- (NSTimer*)setTimer {
    return [NSTimer scheduledTimerWithTimeInterval:self.timeStep
                                     target:self
                                   selector:@selector(updateWorldObjects:)
                                   userInfo:nil
                                    repeats:YES];
}

//creates the 4 wall objects and initializes the allImmovables array
- (void)initializeWallObjects {
    CGSize leftWallSize = CGSizeMake(20, self.view.frame.size.height);
    PhysicsModel *leftWall = [[PhysicsModel alloc]initWithMass:INFINITY
                                                          Size:leftWallSize
                                                        Center:CGPointMake(leftWallSize.width/2, leftWallSize.height/2)
                                                      Rotation:0
                                                      Friction:0
                                                   Restitution:0.05];
    
    
    CGSize topWallSize = CGSizeMake(self.view.frame.size.width, 20);
    PhysicsModel *topWall = [[PhysicsModel alloc]initWithMass:INFINITY
                                                         Size:topWallSize
                                                       Center:CGPointMake(topWallSize.width/2, topWallSize.height/2)
                                                     Rotation:0
                                                     Friction:0
                                                  Restitution:0.05];
    
    PhysicsModel *rightWall = [[PhysicsModel alloc]initWithMass:INFINITY
                                                           Size:leftWallSize
                                                         Center:CGPointMake(self.view.frame.size.width - leftWallSize.width/2,
                                                                            leftWallSize.height/2)
                                                       Rotation:0
                                                       Friction:1
                                                    Restitution:0.05];
    
    
    PhysicsModel *bottomWall = [[PhysicsModel alloc]initWithMass:INFINITY
                                                            Size:topWallSize
                                                          Center:CGPointMake(topWallSize.width/2, self.view.frame.size.height - topWallSize.height/2)
                                                        Rotation:0
                                                        Friction:1
                                                     Restitution:0.05];
    
    _allImmovables = [[NSArray alloc]initWithObjects:leftWall, topWall, rightWall, bottomWall, nil];
}


//creates the bricks model objects and initializes the allBlocks array
- (void)initializeBrickObjects {
    CGSize blueBrickSize = CGSizeMake(140, 30);
    PhysicsModel *blueBrick = [[PhysicsModel alloc]initWithMass:30
                                                           Size:blueBrickSize
                                                         Center:CGPointMake(300, 100)
                                                       Rotation:1
                                                       Friction:0.5
                                                    Restitution:0.05];
    
    CGSize greenBrickSize = CGSizeMake(200, 100);
    PhysicsModel *greenBrick = [[PhysicsModel alloc]initWithMass:50
                                                            Size:greenBrickSize
                                                          Center:CGPointMake(370, 380)
                                                        Rotation:0
                                                        Friction:0.5
                                                     Restitution:0.2];
    
    CGSize redBrickSize = CGSizeMake(40, 120);
    PhysicsModel *redBrick = [[PhysicsModel alloc]initWithMass:30
                                                          Size:redBrickSize
                                                        Center:CGPointMake(350, 220)
                                                      Rotation:0
                                                      Friction:0.5
                                                   Restitution:1];

    CGSize yellowBrickSize = CGSizeMake(65, 120);
    PhysicsModel *yellowBrick = [[PhysicsModel alloc]initWithMass:30
                                                             Size:yellowBrickSize
                                                           Center:CGPointMake(570, 380)
                                                         Rotation:0
                                                         Friction:0.5
                                                      Restitution:0.5];
    
//    CGSize grayBrickSize = CGSizeMake(35, 140);
//    PhysicsModel *grayBrick = [[PhysicsModel alloc]initWithMass:20
//                                                           Size:grayBrickSize
//                                                         Center:CGPointMake(330, 560)
//                                                       Rotation:0
//                                                       Friction:0.5
//                                                    Restitution:0.5];
    
    CGSize purpleBrickSize = CGSizeMake(140, 40);
    PhysicsModel *purpleBrick = [[PhysicsModel alloc]initWithMass:15
                                                             Size:purpleBrickSize
                                                           Center:CGPointMake(530, 280)
                                                         Rotation:0
                                                         Friction:0.5
                                                      Restitution:0.5];

    
//    CGSize radius = CGSizeMake(80, 80);
//    PhysicsModel *testCircle = [[PhysicsModel alloc]initWithMass:1
//                                                             Size:radius
//                                                           Center:CGPointMake(100, 100)
//                                                         Rotation:0
//                                                         Friction:0.5
//                                                      Restitution:0.5];
//    testCircle.shape = kCircle;
    
    _allMovables = [[NSArray alloc]initWithObjects: blueBrick, nil];//greenBrick, redBrick, yellowBrick, purpleBrick, nil];
}


//EFFECTS: the time step selector that applies the gravity and checks for collision
//MODIFIES: the object properties
- (void)updateWorldObjects: (NSTimer*)timer {
    [self performSelectorInBackground:@selector(testingTimer) withObject:nil];
}

- (void)testingTimer {
    [self updateGravity];
    [self applyForceAndTorque];
    for (int i = 0; i < 2; i++) {
        [self detectCollisionEachOther];
    }
    for (PhysicsModel *currentModel in self.allMovables) {
        [self computeNewPositions:currentModel];
    }
}

//Function that updates gravity based on the device that is being used
- (void)updateGravity {
    if ([[[UIDevice currentDevice]name] isEqualToString:@"iPad Simulator"]) {
        [self updateOrientationGravity];
    }
    else if (self.motionTrack != nil){
        [self updateAccelerometerGravity];
    }
}


//REQUIRES: device to have an accelerometer
//EFFECTS: updates the gravity based on iPad's hardware accelerometer
- (void)updateAccelerometerGravity {
    CGFloat xAcceleration = self.motionTrack.accelerometerData.acceleration.x;
    CGFloat yAcceleration = self.motionTrack.accelerometerData.acceleration.y;
    _gravity = [Vector2D vectorWith:xAcceleration * self.GMultiplier y:yAcceleration * -(self.GMultiplier)];
}

//function if not using accelerometer to update gravity based on orientation
- (void)updateOrientationGravity {
    UIDeviceOrientation test= [[UIDevice currentDevice] orientation];
    //updates the gravity at every timestep by checking the orientation
    switch (test) {
            //default config to set gravity to downwards (+y)
        case UIDeviceOrientationUnknown:
            _gravity = [Vector2D vectorWith:0 y:(self.GMultiplier)];
            break;
        case UIDeviceOrientationLandscapeLeft:
            _gravity = [Vector2D vectorWith:-(self.GMultiplier) y:0];
            break;
        case UIDeviceOrientationLandscapeRight:
            _gravity = [Vector2D vectorWith:self.GMultiplier y:0];
            break;
        case UIDeviceOrientationPortraitUpsideDown:
            _gravity = [Vector2D vectorWith:0 y:-(self.GMultiplier)];
            break;
        case UIDeviceOrientationPortrait:
            _gravity = [Vector2D vectorWith:0 y:self.GMultiplier];
            break;
        default:
            break;
    }
}

//only allow rotation when in potrait moe, and not in others
//this is for use for ipad1
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationPortrait;
}

//applies the force on all the bricks
//as the torque is not being used for this ps4, the torque calculation is not done
- (void)applyForceAndTorque {
    for (int i = 0; i < [self.allMovables count]; i ++) {
        PhysicsModel *currentModel = [self.allMovables objectAtIndex:i];
        Vector2D *acceleration = [currentModel.totalForce multiply:(1/currentModel.mass)];
        currentModel.velocity = [[[self.gravity add:acceleration] multiply:self.timeStep] add:currentModel.velocity];
    }
    return;
}

//EFFECTS: detects collision between two given Physics models and sets the velocity/angluar velocity accordingly
- (BOOL)detectCollisionBetween:(PhysicsModel*)firstModel SecondModel:(PhysicsModel*)secondModel {
    
    //sets the masterDict which contains all the essential data between firstmodel and secondmodel
    NSDictionary *masterDict = [self setMasterDictionary:firstModel SecondModel:secondModel];
    
    //get the largest negative ie.ax, ay, bx, by
    int fType = [self getReferenceEdge:masterDict];
    if (fType == -1) {
        return NO; //early return since the objects dont collide
    }

    //initalize referenceDict for n, ns, ni, Dneg, Dpos, Df, Ds ,R, h, p
    NSDictionary *referenceEdgeDict = [self getReferenceEdgeValues:masterDict Ftype:fType];
    
    //getting the two incident points
    NSArray *incidentPoints = [self getIncidentPoints:referenceEdgeDict];

    //clipping points
    NSArray *clippedPoints = [self getClippedPoints:referenceEdgeDict IncidentPoints:incidentPoints];
    //computing the contact points
    //Dictionary 'contacts' contains an array of the contacts points and a corresponding array for the separation
    NSDictionary *contacts = [self getcontactPoints:referenceEdgeDict ClippedPoints:clippedPoints];
    NSArray *contactPoints = [contacts objectForKey:@"contactPoints"];
    NSArray *separations = [contacts objectForKey:@"separations"];
    
    
    //apply impulses
    Vector2D *n = [referenceEdgeDict objectForKey:@"n"];
    for (int repeat = 0; repeat < 10; repeat++) {
        [self applyImpulsesAtContacts:contactPoints Separation:separations Normal:n Between:firstModel SecondModel:secondModel];
    }
    return YES;
}

- (BOOL)detectCollisionBetweenCircle:(PhysicsModel*)circleModel SecondModel:(PhysicsModel*)rectModel {
    Vector2D *circleRadius = [Vector2D vectorWith:circleModel.size.width / 2 y:circleModel.size.height / 2];
    Vector2D *rectHalfSize = [Vector2D vectorWith:rectModel.size.width / 2 y:rectModel.size.height / 2];
    
    Vector2D *circleCenter = [Vector2D vectorWith:circleModel.center.x y:circleModel.center.y];
//    circleCenter = [circleCenter add: [circleModel.velocity multiply:self.timeStep]];
    Vector2D *rectCenter = [Vector2D vectorWith:rectModel.center.x y:rectModel.center.y];
//    rectCenter = [rectCenter add: [rectModel.velocity multiply:self.timeStep]];
    
    Vector2D *rawDistance = [circleCenter subtract:rectCenter];
    
    Vector2D *distanceInRectCoordinates = [[rectModel.rotationMatrix transpose]multiplyVector:rawDistance];
    
    if ([distanceInRectCoordinates abs].x > (circleRadius.x + rectHalfSize.x)) { return NO; }
    if ([distanceInRectCoordinates abs].y > (circleRadius.y + rectHalfSize.y)) { return NO; }
    
    
    Vector2D *contactPoint;
    CGFloat contactX, contactY;
    Vector2D *n;
    
    
    //width collision
    if ([distanceInRectCoordinates abs].x <= (rectHalfSize.x)) {
        //if circle is on the top of rectangle
        if (distanceInRectCoordinates.y >= 0) {
            contactY = rectCenter.y + rectHalfSize.y;
            n = [rectModel.rotationMatrix.col2 negate];
        }
        //cirlce on the bottom
        else {
            contactY = rectCenter.y - rectHalfSize.y;
            n = rectModel.rotationMatrix.col2;
        }
        contactX = rectCenter.x + distanceInRectCoordinates.x;
        contactPoint = [Vector2D vectorWith:contactX y:contactY];
        Vector2D *contactDiff = [contactPoint subtract:rectCenter];
        contactPoint = [rectModel.rotationMatrix multiplyVector:contactDiff];
        contactPoint = [contactPoint add:rectCenter];
        [self applyImpulseForCircleAtContact:contactPoint Seperation:[distanceInRectCoordinates length] Normal:n Between:circleModel SecondModel:rectModel];
            
        return YES;
    }
    
    
    
    //height edge collision
    if ([distanceInRectCoordinates abs].y <= (rectHalfSize.y)) {
        //if circle is on the right of rectangle
        if (distanceInRectCoordinates.x >= 0) {
            contactX = rectCenter.x + rectHalfSize.x;
            n = [rectModel.rotationMatrix.col1 negate];
        }
        //cirlce on the left
        else {
            contactX = rectCenter.x - rectHalfSize.x;
            n = rectModel.rotationMatrix.col1;
        }
        contactY = distanceInRectCoordinates.y + rectCenter.y;
        contactPoint = [Vector2D vectorWith:contactX y:contactY];
        Vector2D *contactDiff = [contactPoint subtract:rectCenter];
        contactPoint = [rectModel.rotationMatrix multiplyVector:contactDiff];
        contactPoint = [contactPoint add:rectCenter];
        [self applyImpulseForCircleAtContact:contactPoint Seperation:[distanceInRectCoordinates length] Normal:n Between:circleModel SecondModel:rectModel];
        return YES;
    }
    
    if (distanceInRectCoordinates.x >= 0) {
        contactX = rectCenter.x + rectHalfSize.x;
        n = [rectModel.rotationMatrix.col1 negate];
    }
    else {
        contactX = rectCenter.x - rectHalfSize.x;
//        n = rectModel.rotationMatrix.col1;
    }
    if (distanceInRectCoordinates.y >= 0) {
        contactY = rectCenter.y + rectHalfSize.y;
        n = [rectModel.rotationMatrix.col2 negate];
    }
    else {
        contactY = rectCenter.y - rectHalfSize.y;
        n = rectModel.rotationMatrix.col2;
    }
    contactPoint = [Vector2D vectorWith:contactX y:contactY];
    Vector2D *contactDiff = [contactPoint subtract:rectCenter];
    contactPoint = [rectModel.rotationMatrix multiplyVector:contactDiff];
    contactPoint = [contactPoint add:rectCenter];
    [self applyImpulseForCircleAtContact:contactPoint Seperation:[distanceInRectCoordinates length] Normal:n Between:circleModel SecondModel:rectModel];
    return YES;

//    CGFloat cornerDistance_sq = powf(([distanceInRectCoordinates abs].x - rectHalfSize.x),2) +
//    powf(([distanceInRectCoordinates abs].y - rectHalfSize.y),2);
//    
//    //corner collision
//    if (cornerDistance_sq <= powf(circleRadius.x,2)) {
//        if (distanceInRectCoordinates.x >= 0) {
//            contactX = rectCenter.x + rectHalfSize.x;
//            n = [rectModel.rotationMatrix.col1 negate];
//        }
//        else {
//            contactX = rectCenter.x - rectHalfSize.x;
//            n = rectModel.rotationMatrix.col1;
//        }
//        if (distanceInRectCoordinates.y >= 0) {
//            contactY = rectCenter.y + rectHalfSize.y;
//        }
//        else {
//            contactY = rectCenter.y - rectHalfSize.y;
//        }
//        contactPoint = [Vector2D vectorWith:contactX y:contactY];
//        Vector2D *contactDiff = [contactPoint subtract:rectCenter];
//        contactPoint = [rectModel.rotationMatrix multiplyVector:contactDiff];
//        contactPoint = [contactPoint add:rectCenter];
//        [self applyImpulseForCircleAtContact:contactPoint Seperation:[distanceInRectCoordinates length] Normal:n Between:circleModel SecondModel:rectModel];
//        return YES;
//    }
    return NO;
}

- (void)applyImpulseForCircleAtContact:(Vector2D *)contact
                            Seperation:(CGFloat)seperation
                                Normal:(Vector2D*)n
                               Between:(PhysicsModel*)firstModel
                           SecondModel:(PhysicsModel*)secondModel {
    Vector2D *t = [n crossZ:1];
    Vector2D *pa = [Vector2D vectorWith:firstModel.center.x y:firstModel.center.y];
    Vector2D *pb = [Vector2D vectorWith:secondModel.center.x y:secondModel.center.y];
    
    Vector2D *velocityA = firstModel.velocity;
    Vector2D *velocityB = secondModel.velocity;
    CGFloat angVelocityA = firstModel.angVelocity;
    CGFloat angVelocityB = secondModel.angVelocity;
    
    //normal and tangential at relative velocity
    //direction vectors from center of masses
    Vector2D *ra = [contact subtract:pa];
    Vector2D *rb = [contact subtract:pb];
    
    //temporary velocity at contact point
    Vector2D *ua = [velocityA add:[ra crossZ:-angVelocityA]];
    Vector2D *ub = [velocityB add:[rb crossZ:-angVelocityB]];
    
    Vector2D *u = [ub subtract:ua];
    
    //normal and tangential at relative velocity
    CGFloat un = [u dot:n];
    CGFloat ut = [u dot:t];
//    CGFloat currentSeparation = [[separation objectAtIndex:i]floatValue];
    //normal and tangential mass
    CGFloat mn, mt;
    CGFloat denom = 1/firstModel.mass + 1/secondModel.mass;
    denom = denom + ([ra dot:ra] - [ra dot:n]*[ra dot:n])/firstModel.inertia;
    denom = denom + ([rb dot:rb] - [rb dot:n]*[rb dot:n])/secondModel.inertia;
    mn = 1/denom;
    denom = 1/firstModel.mass + 1/secondModel.mass;
    denom = denom + ([ra dot:ra] - [ra dot:t]*[ra dot:t])/firstModel.inertia;
    denom = denom + ([rb dot:rb] - [rb dot:t]*[rb dot:t])/secondModel.inertia;
    mt = 1/denom;
    
    //normal impulse
    CGFloat coeffRes = sqrt(firstModel.coeffRes * secondModel.coeffRes);
    Vector2D* Pn;
    double bias = 5;
//    double bias = fabs((0.01 + seperation * 0.025) * 0.2 / self.timeStep);
    Pn = [n multiply:MIN(0, mn*(un*(1+coeffRes))-bias)];
    
    // and change in tangential impulse
    CGFloat dPt = mt*ut;
    CGFloat Ptmax = firstModel.fritionCoeff * secondModel.fritionCoeff * [Pn length];
    dPt = MAX(-Ptmax, MIN(dPt, Ptmax));
    Vector2D *Pt = [t multiply:dPt];
    
    firstModel.velocity = [firstModel.velocity add:[[Pn add:Pt]multiply:1/firstModel.mass]];
    secondModel.velocity = [secondModel.velocity subtract:[[Pn add:Pt]multiply:1/secondModel.mass]];
    
    firstModel.angVelocity = firstModel.angVelocity + ([[ra multiply:(1/firstModel.inertia)]cross:[Pn add:Pt]]);
    secondModel.angVelocity = secondModel.angVelocity - ([[rb multiply:(1/secondModel.inertia)] cross:[Pn add:Pt]]);
    return;
}


//sets the masterDict which contains all the essential data between firstmodel and secondmodel
//ha & hb (width/2, height/2),
//pa & pb (center of mass)
//d (distance between center of mass), da, db,
//Ra & Rb (rotation matrix), C, fa & fb (the distance between edges)
- (NSDictionary*)setMasterDictionary:(PhysicsModel*)firstModel SecondModel:(PhysicsModel*)secondModel {
    Vector2D *ha = [Vector2D vectorWith:firstModel.size.width / 2 y:firstModel.size.height / 2];
    Vector2D *hb = [Vector2D vectorWith:secondModel.size.width / 2 y:secondModel.size.height / 2];
    Vector2D *pa = [Vector2D vectorWith:firstModel.center.x y:firstModel.center.y];
    pa = [pa add: [firstModel.velocity multiply:self.timeStep]];
    Vector2D *pb = [Vector2D vectorWith:secondModel.center.x y:secondModel.center.y];
    pb = [pb add: [secondModel.velocity multiply:self.timeStep]];
    Vector2D *d = [pb subtract:pa];
    Vector2D *da = [[firstModel.rotationMatrix transpose]multiplyVector:d];
    Vector2D *db = [[secondModel.rotationMatrix transpose]multiplyVector:d];
    Matrix2D *C = [[firstModel.rotationMatrix transpose]multiply:secondModel.rotationMatrix];
    Vector2D *fa = [[[da abs]subtract:ha]subtract:[[C abs]multiplyVector:hb]];
    Vector2D *fb = [[[db abs]subtract:hb]subtract:[[[C transpose]abs]multiplyVector:ha]];
    Matrix2D *Ra = firstModel.rotationMatrix;
    Matrix2D *Rb = secondModel.rotationMatrix;
    
    NSDictionary *masterDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                ha, @"ha", hb, @"hb",
                                pa, @"pa", pb, @"pb",
                                d, @"d", da, @"da", db, @"db",
                                Ra, @"Ra", Rb, @"Rb", C, @"C",
                                fa, @"fa", fb, @"fb",
                                nil];
    return masterDict;
}

//REQUIRES: valid masterDict
//EFFECTS: gets the reference edge (preferrably the larger one and returns the type (ax, ay, bx, by)
- (int)getReferenceEdge:(NSDictionary*)masterDict {
    Vector2D *fa = [masterDict objectForKey:@"fa"];
    Vector2D *fb = [masterDict objectForKey:@"fb"];

    int referenceEdge = 0;
    if (!(fa.x < 0 && fa.y < 0 && fb.x < 0 && fb.y < 0)) {
        return -1; //early return since the bodies dont collide with each other
    }

    Vector2D *ha = [masterDict objectForKey:@"ha"];
    Vector2D *hb = [masterDict objectForKey:@"hb"];

    CGFloat fArray[4] = {fa.x, fa.y, fb.x, fb.y};
    CGFloat selectedf = fArray[0];
    for (int r = 0; r < 4; r++) {
        if (selectedf < fArray[r]) {
            selectedf = fArray[r];
            referenceEdge = r;
        }
    }    
    CGFloat deltaAx = (fArray[0] - 0.01 * (ha.x));
    CGFloat deltaAy = (fArray[1] - 0.01 * (ha.y));
    CGFloat deltaBx = (fArray[2] - 0.01 * (hb.x));
    CGFloat deltaBy = (fArray[3] - 0.01 * (hb.y));
    CGFloat deltaArray[4] = {deltaAx, deltaAy, deltaBx, deltaBy};
    
    for (int i = 0; i < 4; i++) {
        if (selectedf == fArray[i]) {
            continue;
        }
        if (deltaArray[i] > selectedf) {
            selectedf = deltaArray[i];
            referenceEdge = i;
        }
    }
    return referenceEdge;
}

//REQUIRES: valid masterDict and fType between 0 and 3
//EFFECTS: initalize referenceDict for n, ns, ni, Dneg, Dpos, Df, Ds ,R, h, p  based on the reference edge
- (NSDictionary*)getReferenceEdgeValues:(NSDictionary*)masterDict Ftype:(int)fType{
    NSMutableDictionary *test = [[NSMutableDictionary alloc] init];
    Vector2D *da = [masterDict objectForKey:@"da"];
    Vector2D *db = [masterDict objectForKey:@"db"];
    Vector2D *pa = [masterDict objectForKey:@"pa"];
    Vector2D *pb = [masterDict objectForKey:@"pb"];
    Vector2D *ha = [masterDict objectForKey:@"ha"];
    Vector2D *hb = [masterDict objectForKey:@"hb"];
    Matrix2D *Ra = [masterDict objectForKey:@"Ra"];
    Matrix2D *Rb = [masterDict objectForKey:@"Rb"];
    Vector2D *n, *nf, *ns, *ni, *p, *h;
    CGFloat Df, Ds, Dneg, Dpos;
    Matrix2D *R;
    
    switch (fType) {
        case 0:
            if (da.x >= 0) {
                n = Ra.col1;
            }
            else {
                n = [Ra.col1 negate];
            }
            nf = n;
            ns = Ra.col2;
            Df = [pa dot:nf] + ha.x;
            Ds = [pa dot:ns];
            Dneg = ha.y - Ds;
            Dpos = ha.y + Ds;
            break;
        case 1:
            if (da.y > 0) {
                n = Ra.col2;
            }
            else {
                n = [Ra.col2 negate];
            }
            nf = n;
            ns = Ra.col1;
            Df = [pa dot:nf] + ha.y;
            Ds = [pa dot:ns];
            Dneg = ha.x - Ds;
            Dpos = ha.x + Ds;
            break;
        case 2:
            if (db.x > 0) {
                n = Rb.col1;
            }
            else {
                n = [Rb.col1 negate];
            }
            nf = [n negate];
            ns = Rb.col2;
            Df = [pb dot:nf] + hb.x;
            Ds = [pb dot:ns];
            Dneg = hb.y - Ds;
            Dpos = hb.y + Ds;
            break;
        case 3:
            if (db.y > 0) {
                n = Rb.col2;
            }
            else {
                n = [Rb.col2 negate];
            }
            nf = [n negate];
            ns = Rb.col1;
            Df = [pb dot:nf] + hb.y;
            Ds = [pb dot:ns];
            Dneg = hb.x - Ds;
            Dpos = hb.x + Ds;
            break;
        default:
            NSLog(@"Ftype not valid");
            break;
    }
    if (fType < 2) {
        ni = [[[Rb transpose]multiplyVector:nf] negate];
        p = pb;
        R = Rb;
        h = hb;
    }
    if (fType < 4 && fType > 1) {
        ni = [[[Ra transpose]multiplyVector:nf] negate];
        p = pa;
        R = Ra;
        h = ha;
    }
    [test setObject:n forKey:@"n"];
    [test setObject:nf forKey:@"nf"];
    [test setObject:ns forKey:@"ns"];
    [test setObject:[NSNumber numberWithFloat:Df] forKey:@"Df"];
    [test setObject:[NSNumber numberWithFloat:Ds] forKey:@"Ds"];
    [test setObject:[NSNumber numberWithFloat:Dneg] forKey:@"Dneg"];
    [test setObject:[NSNumber numberWithFloat:Dpos] forKey:@"Dpos"];
    [test setObject:ni forKey:@"ni"];
    [test setObject:p forKey:@"p"];
    [test setObject:R forKey:@"R"];
    [test setObject:h forKey:@"h"];
    return test;
}

//EFFECTS: returns the incident points based on the reference edge chosen
- (NSArray*)getIncidentPoints:(NSDictionary*)referenceEdgeDict {
    Vector2D *v1, *v2;
    Vector2D *ni = [referenceEdgeDict objectForKey:@"ni"];
    Matrix2D *R = [referenceEdgeDict objectForKey:@"R"];
    Vector2D *p = [referenceEdgeDict objectForKey:@"p"];
    Vector2D *h = [referenceEdgeDict objectForKey:@"h"];
    if ([ni abs].x > [ni abs].y) {
        if (ni.x > 0) {
            v1 = [[R multiplyVector:[Vector2D vectorWith:h.x y:-(h.y)]] add:p];
            v2 = [[R multiplyVector:[Vector2D vectorWith:h.x y:h.y]] add:p];
        }
        else if (ni.x <= 0) {
            v1 = [[R multiplyVector:[Vector2D vectorWith:-(h.x) y:h.y]] add:p];
            v2 = [[R multiplyVector:[Vector2D vectorWith:-(h.x) y:-(h.y)]] add:p];
        }
    }
    else if ([ni abs].x <= [ni abs].y) {
        if (ni.y > 0) {
            v1 = [[R multiplyVector:[Vector2D vectorWith:h.x y:h.y]] add:p];
            v2 = [[R multiplyVector:[Vector2D vectorWith:-(h.x) y:h.y]] add:p];
        }
        else if (ni.y <= 0) {
            v1 = [[R multiplyVector:[Vector2D vectorWith:-(h.x) y:-(h.y)]] add:p];
            v2 = [[R multiplyVector:[Vector2D vectorWith:h.x y:-(h.y)]] add:p];
        }
    }
    return [[NSArray alloc]initWithObjects:v1, v2, nil];
}

//EFFECTS: clips the incident points based on the reference edge
//assumes that collision is taking place
- (NSArray*)getClippedPoints:(NSDictionary*)referenceEdgeDict IncidentPoints:(NSArray*)incidentPoints {
    
    CGFloat dist1, dist2;
    Vector2D *v1 = [incidentPoints objectAtIndex:0];
    Vector2D *v2 = [incidentPoints objectAtIndex:1];
    Vector2D *v1AfterClipping, *v2AfterClipping;
    Vector2D *ns = [referenceEdgeDict objectForKey:@"ns"];
    CGFloat Dneg = [[referenceEdgeDict objectForKey:@"Dneg"]floatValue];
    CGFloat Dpos = [[referenceEdgeDict objectForKey:@"Dpos"]floatValue];
    
    for (int i = 0; i < 2; i++) {
        //first clip
        if (i == 0) {
            dist1 = ([[ns negate] dot:v1]) - Dneg;
            dist2 = ([[ns negate] dot:v2]) - Dneg;
        }
        //second clip
        else {
            dist1 = [ns dot:v1] - Dpos;
            dist2 = [ns dot:v2] - Dpos;
        }
        //if both distances are positive, return nil array as they dont collide
        if (dist1 > 0 && dist2 > 0) {
            return [[NSArray alloc]init];
        }
        else if (dist1 <= 0 && dist2 <= 0) {
            v1AfterClipping = [Vector2D vectorWith:v1.x y:v1.y];
            v2AfterClipping = [Vector2D vectorWith:v2.x y:v2.y];
        }
        else if (dist1 < 0 && dist2 >= 0) {
            v1AfterClipping = [Vector2D vectorWith:v1.x y:v1.y];
            v2AfterClipping = [[[v2 subtract:v1]multiply:(dist1/(dist1 - dist2))]add:v1];
        }
        else if (dist1 >= 0 && dist2 < 0) {
            v1AfterClipping = [Vector2D vectorWith:v2.x y:v2.y];
            v2AfterClipping = [[[v2 subtract:v1]multiply:(dist1/(dist1 - dist2))]add:v1];
        }
        v1 = [Vector2D vectorWith:v1AfterClipping.x y:v1AfterClipping.y];
        v2 = [Vector2D vectorWith:v2AfterClipping.x y:v2AfterClipping.y];
    }
    return [[NSArray alloc]initWithObjects:v1, v2, nil];
}

//EFFECTS: computes the contact point points based on the clipped points provided
- (NSDictionary*)getcontactPoints:(NSDictionary*)referenceEdgeDict ClippedPoints:(NSArray*)clippedPoints{
    NSMutableArray *contacts = [NSMutableArray arrayWithCapacity:2];
    NSMutableArray *separations = [NSMutableArray arrayWithCapacity:2];
    Vector2D *nf = [referenceEdgeDict objectForKey:@"nf"];
    CGFloat Df = [[referenceEdgeDict objectForKey:@"Df"]floatValue];
    
    CGFloat separation1 = [nf dot:[clippedPoints objectAtIndex:0]] - Df;
    //contact point only valid if the separation is negative
    if (separation1 < 0) {
        Vector2D *currentContactPoint = [[clippedPoints objectAtIndex:0] subtract:[nf multiply:separation1]];
        [contacts addObject:currentContactPoint];
        NSNumber *currentSeparation = [[NSNumber alloc]initWithFloat:separation1];
        [separations addObject:currentSeparation];
    }
    //check the other contact point if its valid
    CGFloat separation2 = [nf dot:[clippedPoints objectAtIndex:1]] - Df;
    if (separation2 < 0) {
        Vector2D *currentContactPoint = [[clippedPoints objectAtIndex:1] subtract:[nf multiply:separation2]];
        [contacts addObject:currentContactPoint];
        NSNumber *currentSeparation = [[NSNumber alloc]initWithFloat:separation2];
        [separations addObject:currentSeparation];
    }
    return [NSDictionary dictionaryWithObjectsAndKeys:contacts, @"contactPoints",
            separations, @"separations", nil];
}

//REQUIRES: seperation & contact points should be synchroniesd and size should be 1 or 2
//EFFECTS: applies the impules at the contact points and computes the new velocity
- (void)applyImpulsesAtContacts:(NSArray*)contacts
                     Separation:(NSArray*)separation
                         Normal:(Vector2D*)n
                        Between:(PhysicsModel*)firstModel
                    SecondModel:(PhysicsModel*)secondModel {
    Vector2D *t = [n crossZ:1];
    Vector2D *pa = [Vector2D vectorWith:firstModel.center.x y:firstModel.center.y];
    Vector2D *pb = [Vector2D vectorWith:secondModel.center.x y:secondModel.center.y];
    
    Vector2D *velocityA = firstModel.velocity;
    Vector2D *velocityB = secondModel.velocity;
    CGFloat angVelocityA = firstModel.angVelocity;
    CGFloat angVelocityB = secondModel.angVelocity;
    
    for (int i = 0; i < [contacts count]; i++) {
        //normal and tangential at relative velocity
        //direction vectors from center of masses
        Vector2D *ra = [[contacts objectAtIndex:i] subtract:pa];
        Vector2D *rb = [[contacts objectAtIndex:i] subtract:pb];
        
        //temporary velocity at contact point
        Vector2D *ua = [velocityA add:[ra crossZ:-angVelocityA]];
        Vector2D *ub = [velocityB add:[rb crossZ:-angVelocityB]];

        Vector2D *u = [ub subtract:ua];
    
        //normal and tangential at relative velocity
        CGFloat un = [u dot:n];
        CGFloat ut = [u dot:t];
        CGFloat currentSeparation = [[separation objectAtIndex:i]floatValue];
        //normal and tangential mass
        CGFloat mn, mt;
        CGFloat denom = 1/firstModel.mass + 1/secondModel.mass;
        denom = denom + ([ra dot:ra] - [ra dot:n]*[ra dot:n])/firstModel.inertia;
        denom = denom + ([rb dot:rb] - [rb dot:n]*[rb dot:n])/secondModel.inertia;
        mn = 1/denom;
        denom = 1/firstModel.mass + 1/secondModel.mass;
        denom = denom + ([ra dot:ra] - [ra dot:t]*[ra dot:t])/firstModel.inertia;
        denom = denom + ([rb dot:rb] - [rb dot:t]*[rb dot:t])/secondModel.inertia;
        mt = 1/denom;
        
        //normal impulse
        CGFloat coeffRes = sqrt(firstModel.coeffRes * secondModel.coeffRes);
        Vector2D* Pn;
        double bias = fabs((0.01 + currentSeparation) * 0.2 / self.timeStep);
        Pn = [n multiply:MIN(0, mn*(un*(1+coeffRes))-bias)];
        
        // and change in tangential impulse
        CGFloat dPt = mt*ut;
        CGFloat Ptmax = firstModel.fritionCoeff * secondModel.fritionCoeff * [Pn length];
        dPt = MAX(-Ptmax, MIN(dPt, Ptmax));
        Vector2D *Pt = [t multiply:dPt];
    
        firstModel.velocity = [firstModel.velocity add:[[Pn add:Pt]multiply:1/firstModel.mass]];
        secondModel.velocity = [secondModel.velocity subtract:[[Pn add:Pt]multiply:1/secondModel.mass]];
        
        firstModel.angVelocity = firstModel.angVelocity + ([[ra multiply:(1/firstModel.inertia)]cross:[Pn add:Pt]]);
        secondModel.angVelocity = secondModel.angVelocity - ([[rb multiply:(1/secondModel.inertia)] cross:[Pn add:Pt]]);
    }
    return;
}

//EFFECTS: computes the new poisting based on its velocity and rotation based on
//its angular velocity of the given object
- (void)computeNewPositions:(PhysicsModel*)givenModel {
    Vector2D *currentP = [Vector2D vectorWith:givenModel.center.x y:givenModel.center.y];
    currentP = [currentP add: [givenModel.velocity multiply:self.timeStep]];
    [givenModel center: CGPointMake(currentP.x, currentP.y)];
    [givenModel rotate: (givenModel.rotation + self.timeStep * givenModel.angVelocity)];
}

//EFFECTS: detects collision between all the objects (movables and immovables)
- (void)detectCollisionEachOther {
    for (int i = 0; i < [self.allMovables count]; i++) {
        PhysicsModel *firstModel = [self.allMovables objectAtIndex:i];
        //checks the collision with other bricks in the world
        for (int j = i+1; j < [self.allMovables count]; j++) {
            PhysicsModel *secondModel = [self.allMovables objectAtIndex:j];
            if (firstModel.shape == kCircle || secondModel.shape == kCircle) {
                if (firstModel.shape == kCircle) {
                    [self detectCollisionBetweenCircle:firstModel SecondModel:secondModel];
                }
                else {
                    [self detectCollisionBetweenCircle:secondModel SecondModel:firstModel];
                }
            }
            else {
                [self detectCollisionBetween:firstModel SecondModel:secondModel];
            }
        }
        //checks collision of the firstmodel with all the walls
        for (PhysicsModel *currentImmovable in self.allImmovables) {
            if (firstModel.shape == kCircle) {
                    [self detectCollisionBetweenCircle:firstModel SecondModel:currentImmovable];
            }
            else {
                [self detectCollisionBetween:firstModel SecondModel:currentImmovable];
            }
        }
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
