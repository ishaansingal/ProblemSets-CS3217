//
//  DesignViewController+GameEngineSupport.m
//  Game
//
//  Created by Ishaan Singal on 27/2/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import "GameEngineSupport.h"

@interface GameEngineSupport
- (void)scrollGamearea;
- (void)setupWorld;
- (void)setupWalls;
- (void)setupGameObjects;
- (void)startEngine;
- (void)gameOver;
- (void)updateWorldObjects:(NSTimer*)timer;
- (void)updateModel:(GameModel*)thisModel WithBody:(b2Body*)thisBody;
- (void)updateScore;

- (void)objectsCollided:(GameModel*)firstObj withObject:(GameModel*)secondObj withImpulse:(CGFloat)impulse;
- (double)blockMaxHealth:(BlockType)blockType;
- (void)removeBreathCompletely;
- (void)removeBlockCompletely:(Blocks*)thisBlock;
- (void)removePigCompletely;
- (void)removeObjectFromWorld:(GameModel*)givenModel;
- (void)reduceBreathPowerInWorld;

- (void)finalGameState:(NSTimer*)timer;

- (void)addRectangleObjectToWorld:(GameModel*)givenModel;
- (void)addCircleObjectToWorld:(GameModel*)givenModel;
- (b2BodyDef)getObjectBodydef:(GameModel*)givenModel;
- (b2PolygonShape)getRectangleObjectShape:(GameModel*)givenModel;
- (b2CircleShape)getCircleObjectShape:(GameModel*)givenModel;
- (b2FixtureDef)getObjectFixture:(GameModel*)givenModel Shape:(b2Shape&)givenShape;
- (CGFloat)pixelToMeter:(CGFloat)x;

@end

@implementation GameViewController (GameEngineSupport)

//The Main method that sets up all the GameObjects for start mode, sets up the
//physics engine 'world' and starts the engine
- (void)startPlay {
    if ([self isStartModePossible]) {
        if (self.gameMode == kDesignerMode) {
            [self setupScore];
            [self.paletteArea removeFromSuperview];
        }
        [self.currentWolf setupStartMode];
        [(GameWolf*)self.currentWolf setDelegate:self];
        [self.currentPig setupStartMode];
        [self.currentBlock setupStartMode];
        [self scrollGamearea];
        [self setupWorld];
        [self setupWalls];
        [self setupGameObjects];
        [self setupGameEndPopup]; //the popup for Gameover or Good job
        [self startEngine];
    }
}

//The Main method (opposite of startplay) that dismantles the physics world and clears
//everything
- (void)endPlay {
    if (self.gameMode == kDesignerMode) {
        [self.view addSubview:self.paletteArea];
        [self.scoreLabel removeFromSuperview];
        self.scoreLabel = nil;
        [self.score removeFromSuperview];
        self.score = nil;
    }
    self.gamearea.alpha = 1;
    [self.gameEndAlertView removeFromSuperview];
    [self.lastBreathTimer invalidate];
    self.scoreLabel.text = @"0";
    if (self.wolfBreath != nil){
        [self removeBreathCompletely];
    }
    self.wolfBreath = nil;
    delete self.world;
    [self stopEngine];
}

//checks whether start is possible - both wolf and pig should be in the gamearea
- (BOOL)isStartModePossible {
    BOOL result = NO;
    if (self.currentWolf.modelObj.currentState == kInGame && self.currentPig.modelObj.currentState == kInGame) {
        result = YES;
    }
    return result;
}


//scrolls the gamearea to show the pig/wolf if the pig/wolf is outside the view
- (void)scrollGamearea {
    CGFloat pigOriginX = self.currentPig.modelObj.imageOrigin.x;
    CGFloat wolfOriginX = self.currentWolf.modelObj.imageOrigin.x;
    if (pigOriginX > kViewWidth || wolfOriginX > kViewWidth) {
        CGFloat contentOffsetX;
        contentOffsetX = (pigOriginX > kViewWidth)? pigOriginX - kViewWidth: wolfOriginX - kViewWidth;
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.8];
        self.gamearea.contentOffset = CGPointMake(pigOriginX - kViewWidth, 0);
        [UIView commitAnimations];
    }
}

//sets the gravity of the world as 10 and initializes the Box2D 'world'
- (void)setupWorld {
    b2Vec2 gravity = b2Vec2(0.0f, 10.0f);
    self.world = new b2World(gravity);
    self.contactListener = new MyContactListener(self);
    self.world->SetContactListener(self.contactListener);
}

//Sets up bottom, left and right walls in the world for collision purposes
//makes them static by giving them infinite mass
- (void)setupWalls {
    NSMutableArray *tempArray = [NSMutableArray array];
    CGSize bottomWallSize = CGSizeMake(self.gamearea.contentSize.width, 1);
    CGPoint bottomWallOrigin = CGPointMake(0, kGameareaHeight - kGroundHeight);
    GameModel *bottomWall = [[GameModel alloc]initWithSize:bottomWallSize Origin:bottomWallOrigin  Rotation:0 State:1];
    bottomWall.fritionCoeff = 1;
    bottomWall.coeffRes = 0.1;
    bottomWall.mass = INFINITY;
    [tempArray addObject:bottomWall];
    [self addRectangleObjectToWorld:bottomWall];
    
    CGSize rightWallSize = CGSizeMake(1, bottomWall.imageOrigin.y);
    CGPoint rightWallOrigin = CGPointMake(self.gamearea.contentSize.width, 0);
    GameModel *rightWall = [[GameModel alloc]initWithSize:rightWallSize Origin:rightWallOrigin  Rotation:0 State:1];
    rightWall.fritionCoeff = 1;
    rightWall.coeffRes = 0.1;
    rightWall.mass = INFINITY;
    [tempArray addObject:rightWall];
    [self addRectangleObjectToWorld:rightWall];
    
    CGSize leftWallSize = CGSizeMake(1, bottomWall.imageOrigin.y);
    CGPoint leftWallOrigin = CGPointMake(0, 0);
    GameModel *leftWall = [[GameModel alloc]initWithSize:leftWallSize Origin:leftWallOrigin  Rotation:0 State:1];
    leftWall.fritionCoeff = 1;
    leftWall.coeffRes = 0.1;
    leftWall.mass = INFINITY;
    [tempArray addObject:leftWall];
    [self addRectangleObjectToWorld:leftWall];
    
    self.allWalls = [[NSArray alloc]initWithArray:tempArray];
}

//adds the pig and the blocks bodies to the Box2d world
- (void)setupGameObjects {
    [self addRectangleObjectToWorld:self.currentPig.modelObj];
    for (NSDictionary* thisBlock in ((GameBlocks*)self.currentBlock).allBlocks) {
        Blocks* thisBlockObject = [thisBlock objectForKey:@"block"];
        if (thisBlockObject.currentState == kInGame) {
            [self addRectangleObjectToWorld:thisBlockObject];
        }
    }
}

//sets up the score image and its label
- (void)setupScore {
    UIImage *scoreImage = [UIImage imageNamed:kScoreImageName];
    self.score = [[UIImageView alloc]initWithImage:scoreImage];
    
    CGFloat bottomRightX = kViewWidth - scoreImage.size.width - 100;
    CGFloat bottomRightY = kGameareaHeight + kPaletteHeight + 50 - kGroundHeight;
    self.score.frame = CGRectMake(bottomRightX, bottomRightY, scoreImage.size.width, scoreImage.size.height);
    [self.view addSubview:self.score];
    
    CGSize scoreLabelSize = CGSizeMake(100, 25);
    CGRect scoreLabelFrame = CGRectMake(bottomRightX + scoreImage.size.width + 5, bottomRightY, scoreLabelSize.width, scoreLabelSize.height);
    self.scoreLabel = [[UILabel alloc]initWithFrame:scoreLabelFrame];
    self.scoreLabel.backgroundColor = [UIColor clearColor];
    self.scoreLabel.textColor=[UIColor whiteColor];
    [self.scoreLabel setFont:[UIFont fontWithName:@"Futura" size:30]];
    self.scoreLabel.text = @"0";
    [self.view addSubview:self.scoreLabel];
}

//sets up the game end popup without any text
//the text and the button text is defined by won or lost
- (void)setupGameEndPopup {
    CGPoint gameoverOrigin = CGPointMake(350, 150);
    CGSize gameoverSize = CGSizeMake(300, 250);
    self.gameEndAlertView = [[UIView alloc]initWithFrame:CGRectMake(gameoverOrigin.x, gameoverOrigin.y, gameoverSize.width, gameoverSize.height)];
    self.gameEndAlertView.backgroundColor = [UIColor colorWithRed:201.0/255 green:0 blue:2.0/255 alpha:1];
    CALayer *gameoverlayer = self.gameEndAlertView.layer;
    [gameoverlayer setCornerRadius:8.0f];
    gameoverlayer.masksToBounds = YES;
    gameoverlayer.borderWidth = 5.0f;
    
    UILabel *gameoverlabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, gameoverSize.width - 20, 120)];
    gameoverlabel.backgroundColor = [UIColor clearColor];
    [gameoverlabel setFont:[UIFont fontWithName:@"Chalkduster" size:35]];
    [gameoverlabel setTransform:CGAffineTransformRotate(gameoverlabel.transform, -0.55)];
    gameoverlabel.center = CGPointMake(gameoverSize.width/2, 100);
    
    UIButton *okButton = [[UIButton alloc]initWithFrame:CGRectMake(0, gameoverSize.height - 50, gameoverSize.width, 50)];
    CALayer *okButtonLayer = okButton.layer;
    [okButtonLayer setCornerRadius:8.0f];
    okButtonLayer.masksToBounds = YES;
    okButtonLayer.borderWidth = 1.0f;
    [okButton.titleLabel setFont:[UIFont fontWithName:@"Chalkduster" size:35]];
    okButton.backgroundColor = [UIColor colorWithRed:10.0/255 green:0 blue:2.0/255 alpha:1];
    [okButton addTarget:self action:@selector(gameEndButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.gameEndAlertView addSubview:gameoverlabel];
    [self.gameEndAlertView addSubview:okButton];
    self.gameEndAlertView.hidden = YES;
    [self.view addSubview:self.gameEndAlertView];

}


//defines the GameEndPopups texts and the button text
- (void)setupGaveWonView {
    self.gameEndAlertView.backgroundColor = [UIColor colorWithRed:201.0/255 green:10.0/255 blue:2.0/255 alpha:1];

    for (UIView *thisView in self.gameEndAlertView.subviews) {
        if ([thisView isKindOfClass:[UILabel class]]) {
            UILabel *gameWonLabel = (UILabel*)thisView;
            [gameWonLabel setText:@"Good Job!!!"];
        }
        if ([thisView isKindOfClass:[UIButton class]]) {
            UIButton *gameWonButton = (UIButton*)thisView;
            NSString *buttonText = @"End";
            if (self.gameMode == kPlayMode) {
                buttonText = @"Next Level";
            }
            [gameWonButton setTitle:buttonText forState:UIControlStateNormal];
        }

    }
    self.gameEndAlertView.hidden = YES;
}

//defines the GameEndPopups texts and the button text
- (void)setupGaveoverView {
    self.gameEndAlertView.backgroundColor = [UIColor colorWithRed:201.0/255 green:10.0/255 blue:2.0/255 alpha:1];
    
    for (UIView *thisView in self.gameEndAlertView.subviews) {
        if ([thisView isKindOfClass:[UILabel class]]) {
            UILabel *gameWonLabel = (UILabel*)thisView;
            [gameWonLabel setText:@"Game Over!!!"];
        }
        if ([thisView isKindOfClass:[UIButton class]]) {
            UIButton *gameWonButton = (UIButton*)thisView;
            NSString *buttonText = @"End";
            if (self.gameMode == kPlayMode) {
                buttonText = @"Retry";
            }
            [gameWonButton setTitle:buttonText forState:UIControlStateNormal];
        }
    }
    self.gameEndAlertView.hidden = YES;
}

//starts the engine that periodically checks of collision at a rate of kTimeStep (0.016)
- (void)startEngine {
    self.engineTimer = [NSTimer scheduledTimerWithTimeInterval:kTimeStep
                                                  target:self
                                                selector:@selector(updateWorldObjects:)
                                                userInfo:nil
                                                 repeats:YES];
}

//stops the engine by stopping the timer that checks for collision
- (void)stopEngine {
    [self.engineTimer invalidate];
}

//displays the gameover alertview
- (void)gameOver {
    [self stopEngine];
    self.gamearea.alpha = 0.5;
    [self setupGaveoverView];
    self.gameEndAlertView.hidden = NO;
}

- (void)gameWon {
    [self stopEngine];
    self.gamearea.alpha = 0.5;
    [self setupGaveWonView];
    self.gameEndAlertView.hidden = NO;
}


//function called at every timestep that checks for collision and removes expired objects
- (void)updateWorldObjects:(NSTimer*)timer {
    self.world->Step(kTimeStep, 8, 6);
    b2Body *worldBodies = self.world->GetBodyList();
    for (int i = 0; i < self.world->GetBodyCount(); i++) {
        GameModel *thisModel = (__bridge GameModel*)worldBodies->GetUserData();
        if (worldBodies->GetType() == b2_staticBody) {
            continue;
        }
        if ([thisModel expired]) {
            if ([thisModel isEqual:self.wolfBreath.modelObj]) {
                [self removeBreathCompletely];
            }
            else if ([thisModel isEqual:self.currentPig.modelObj]) {
                [self removePigCompletely];
                [self performSelector:@selector(gameWon) withObject:nil afterDelay:2];
            }
            else if ([thisModel isKindOfClass:[Blocks class]]) {
                [self removeBlockCompletely:(Blocks*)thisModel];
            }
            continue;
        }
        //only update dynamic bodies
        if (worldBodies->GetType() == b2_dynamicBody) {
            [self updateModel:(__bridge GameModel*)worldBodies->GetUserData() WithBody:worldBodies];
        }
        worldBodies = worldBodies->GetNext();
    }
}

//Updates the model properties at every timestep which then updates views
- (void)updateModel:(GameModel*)thisModel WithBody:(b2Body*)thisBody{
    CGFloat newTranslationX = (kPixelToMeterRatio * thisBody->GetPosition().x) - thisModel.center.x;
    CGFloat newTranslationY = (kPixelToMeterRatio * thisBody->GetPosition().y) - thisModel.center.y;
    CGPoint newTranslation = CGPointMake(newTranslationX, newTranslationY);
    [thisModel translateByPoint:newTranslation];
    [thisModel rotate:thisBody->GetAngle()];
}

//Updates the score at every timestep based on the pigs health
//if the pig has expired, the breaths left also get added to the score
//no points for killing a block
- (void)updateScore {
    int pigHealth = self.currentPig.modelObj.impulse;
    self.scoreLabel.text = [NSString stringWithFormat:@"%i", pigHealth];
    if (self.currentPig.modelObj.expired) {
        int newScore = pigHealth + ((GameWolf*)self.currentWolf).numOfBreaths * 300;
        self.scoreLabel.text = [NSString stringWithFormat:@"%i", newScore];
    }
}


#pragma mark - handle collision
//the delegate implementation for <CollisionDelegate>
//it recieves the impulse and the two objects of collision and acts on them accordingly
- (void)objectsCollided:(GameModel*)firstObj withObject:(GameModel*)secondObj withImpulse:(CGFloat)impulse {
    BOOL isOneObjectWall = (firstObj.mass == INFINITY || secondObj.mass == INFINITY);
    CGFloat newImpulse = impulse;
    
    BOOL isOneObjectBreath = [firstObj isEqual:self.wolfBreath.modelObj] || [secondObj isEqual:self.wolfBreath.modelObj];
    BOOL isOneObjectPig = [firstObj isEqual:self.currentPig.modelObj] || [secondObj isEqual:self.currentPig.modelObj];
    BOOL isOneObjectBlock = [firstObj isKindOfClass:[Blocks class]] || [secondObj isKindOfClass:[Blocks class]];
    Blocks* thisBlock;
    if (isOneObjectBlock && ((GameWolf*)self.currentWolf).numOfBreaths < 3) {
        thisBlock = ([firstObj isKindOfClass:[Blocks class]])? (Blocks*)firstObj: (Blocks*)secondObj;
        thisBlock.impulse += newImpulse/thisBlock.mass;
        //if the impulse is greater than max impulse, expire the pig
        if (thisBlock.impulse > [self blockMaxHealth:thisBlock.blockType]) {
            thisBlock.expired = YES;
        }
    }

    //dont act on collisions between breath and wall
    if (isOneObjectBreath && !isOneObjectWall) {
        [self.wolfBreath stopTrace];
        //if one block is straw, expire the block and reduce breath power by 2
        if (isOneObjectBlock && thisBlock.blockType == kStraw) {
            thisBlock.expired = YES;
            [self.wolfBreath reducePowerBy:0.5];
            [self reduceBreathPowerInWorld];
        }
        //or expire the breath completely from the world on sufficient impulse
        else {
            GameModel *thisBreath = ([firstObj isEqual:self.wolfBreath.modelObj])? (GameModel*)firstObj: (GameModel*)secondObj;
            thisBreath.impulse +=newImpulse/thisBreath.mass;
            if (thisBreath.impulse > 0) {
                thisBreath.expired = YES;
            }
        }
    }
    //dont act on pig collisions if no breath is released
    if (isOneObjectPig && ((GameWolf*)self.currentWolf).numOfBreaths < 3) {
        GameModel *thisPig = ([firstObj isEqual:self.currentPig.modelObj])? (GameModel*)firstObj: (GameModel*)secondObj;
        //if the impulse just cross the cry threshold, change the image
        if (thisPig.impulse < kPigCryHealth && thisPig.impulse + newImpulse/thisPig.mass > kPigCryHealth) {
            [(GamePig*)self.currentPig pigCry];
        }
        thisPig.impulse += newImpulse/thisPig.mass;
        //if the impulse is greater than max impulse, expire the pig
        if (thisPig.impulse > kPigMaxHealth) {
            thisPig.expired = YES;
        }
        [self updateScore];
    }
}

//get the max health of a particular block, user for expiring it
- (double)blockMaxHealth:(BlockType)blockType {
    double maxBlockHealth = 0;
    switch (blockType) {
        case kStraw:
            maxBlockHealth = kStrawMaxHealth;
            break;
        case kWood:
            maxBlockHealth = kWoodMaxHealth;
            break;
        case kStone:
            maxBlockHealth = kStoneMaxHealth;
            break;
        case kIron:
            maxBlockHealth = kIronMaxHealth;
            break;
        default:
            break;
    }
    return maxBlockHealth;
}

#pragma mark - edit gamearea objects
//removes the breath completely both from the world and from our gamearea
//the function call "breathDied" is responsible for the animation of the breath
- (void)removeBreathCompletely {
    //remove andy selectors previously sent to expire this breath
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(removeBreathCompletely) object:nil];
    [self removeObjectFromWorld:self.wolfBreath.modelObj];
    [self.wolfBreath breathDied];
}

//removes the block completely both from the world and from our gamearea
- (void)removeBlockCompletely:(Blocks*)thisBlock {
    [self removeObjectFromWorld:thisBlock];
    [(GameBlocks*)self.currentBlock removeBlockWithId:thisBlock.blockId];
}

//removes the pig completely both from the world and from our gamearea
//the function call "pigDied" is responsible for the animation of the breath
- (void)removePigCompletely {
    [self removeObjectFromWorld:self.currentPig.modelObj];
    [(GamePig*)self.currentPig pigDied];
}

//helper method to remove a particular model from the world
//it loops through all the bodies, checks for the user data, and deletes the matching one
- (void)removeObjectFromWorld:(GameModel*)givenModel {
    b2Body *allBodies = self.world->GetBodyList();
    for (int i = 0; i < self.world->GetBodyCount(); i++) {
        if ([(__bridge GameModel*)allBodies->GetUserData() isEqual:givenModel]) {
            self.world->DestroyBody(allBodies);
            break;
        }
        allBodies = allBodies->GetNext();
    }
}

//used when the breath collides with a Straw block, so as to reduce its power (velocity) by half
- (void)reduceBreathPowerInWorld {
    b2Body *allBodies = self.world->GetBodyList();
    for (int i = 0; i < self.world->GetBodyCount(); i++) {
        GameModel *thisModel = (__bridge GameModel*)allBodies->GetUserData();
        if ([thisModel isEqual:self.wolfBreath.modelObj]) {
            allBodies->SetLinearVelocity(b2Vec2(self.wolfBreath.modelObj.velocity.x, self.wolfBreath.modelObj.velocity.y));
        }
        allBodies = allBodies->GetNext();
    }
}

#pragma mark - delegate for breath creation
//the delegate implementation for the creation of breath (sent by GameWolf)
//removes any existing breath thats present in the game
- (void)breathReleasedWithVelocity:(Vector2D*)vel AtPosition:(CGPoint)origin{
    if (self.wolfBreath.view != nil) {
        [self removeBreathCompletely];
    }
    self.wolfBreath = [[GameBreath alloc]initWithOrigin:origin Radius:kBreathRadius Velocity:vel];
    [self.gamearea addSubview:self.wolfBreath.view];
    //add the breath as a circle to the physics engine
    [self addCircleObjectToWorld:self.wolfBreath.modelObj];
    //expire the breath after 4.5 seconds automatically
    [self performSelector:@selector(removeBreathCompletely) withObject:nil afterDelay:4.5];
}

//implements the delegate sent by the wolf that the breath has finished
//has a timer that checks whether the game is over after last state or game is won
- (void)breathFinished {
    self.lastBreathTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(finalGameState:) userInfo:nil repeats:YES];
}

//the selector that is called after the last breath is released to check for game state
//if the pig expires, the game is won
//if the pig hasnt expired but is interacting with other objects, wait until it finishes
//if everything is stationary, the breath has expired, and the pig is alive, GaveOver
- (void)finalGameState:(NSTimer*)timer {
    if (![self.currentPig.modelObj expired] && self.wolfBreath.modelObj == nil) {
        //check if all bodies are at rest
        b2Body *worldBodies = self.world->GetBodyList();
        for (int i = 0; i < self.world->GetBodyCount(); i++) {
            if (worldBodies->GetType() == b2_staticBody) {
                continue;
            }
            if (worldBodies->IsAwake()) {
                return;
            }
            worldBodies = worldBodies->GetNext();
        }
        //if all bodies are at rest, kill the wolf and show pop gameover
        [timer invalidate];
        [(GameWolf*)self.currentWolf wolfDied];
        [self gameOver];
    }
}

#pragma mark - create world body
//function that adds a rectangle body to the Box2d world based on its model
//the user data of this 'Body' is set the GameModel in our project
//it uses helper functions that are described in detail below
- (void)addRectangleObjectToWorld:(GameModel*)givenModel {
    b2BodyDef givenModelBodyDef = [self getObjectBodydef:givenModel];
    b2PolygonShape givenModelShape = [self getRectangleObjectShape:givenModel];
    b2FixtureDef givenModelShapeDef = [self getObjectFixture:givenModel Shape:givenModelShape];
    b2Body *givenModelBody = self.world->CreateBody(&givenModelBodyDef);
    givenModelBody->CreateFixture(&givenModelShapeDef);
    //set the userdata of this body, the same as the givenmodel
    givenModelBody->SetUserData((__bridge void*) givenModel);
}

//function that adds a circular body to the Box2d world based on its model
//the user data of this 'Body' is set the GameModel in our project
//it uses helper functions that are described in detail below
- (void)addCircleObjectToWorld:(GameModel*)givenModel {
    b2BodyDef givenModelBodyDef = [self getObjectBodydef:givenModel];
    b2CircleShape givenModelShape = [self getCircleObjectShape:givenModel];
    b2FixtureDef givenModelShapeDef = [self getObjectFixture:givenModel Shape:givenModelShape];
    b2Body *givenModelBody = self.world->CreateBody(&givenModelBodyDef);
    givenModelBody->CreateFixture(&givenModelShapeDef);
    //set the userdata of this body, the same as the givenmodel
    givenModelBody->SetUserData((__bridge void*) givenModel);
}

//creates a body definition for the given model
//the body is allowed to sleep, where it wont be checked for collisions with other
//rested objects, when it is at rest
//walls are set as static bodies (wont move) and others as dynamic
//the position, angle and velocity of the model is set here
- (b2BodyDef)getObjectBodydef:(GameModel*)givenModel {
    b2BodyDef givenBodyDef;
    givenBodyDef.allowSleep = true;
    givenBodyDef.awake = true;
    givenBodyDef.linearVelocity.Set(givenModel.velocity.x, givenModel.velocity.y);
    givenBodyDef.position.Set([self pixelToMeter:givenModel.center.x], [self pixelToMeter:givenModel.center.y]);
    if (givenModel.mass == INFINITY) {
        givenBodyDef.type = b2_staticBody;
    }
    else {
        givenBodyDef.type = b2_dynamicBody;
    }
    givenBodyDef.angle = givenModel.rotation;
    return givenBodyDef;
}

//this function defines the shape of a given model, here it is defined as rectangle
//with the size of the given model
- (b2PolygonShape)getRectangleObjectShape:(GameModel*)givenModel {
    b2PolygonShape givenObjectShape;
    givenObjectShape.SetAsBox([self pixelToMeter:givenModel.size.width]/2, [self pixelToMeter:givenModel.size.height]/2);
    return givenObjectShape;
}

//this function defines the shape of a given model, here it is defined as circle
//with the size of the given model
//THIS IS ONLY USED FOR BREATH AT THE MOMENT
- (b2CircleShape)getCircleObjectShape:(GameModel*)givenModel {
    b2CircleShape givenObjectShape;
    givenObjectShape.m_radius = [self pixelToMeter:givenModel.size.width]/2;
    return givenObjectShape;
}

//this function creates the fixture for the given shape by defining its friction,
//restitution and density
- (b2FixtureDef)getObjectFixture:(GameModel*)givenModel Shape:(b2Shape&)givenShape {
    b2FixtureDef givenModelShapeDef;
    givenModelShapeDef.shape = &givenShape;
    givenModelShapeDef.friction = givenModel.fritionCoeff;
    givenModelShapeDef.restitution = givenModel.coeffRes;
    givenModelShapeDef.density = givenModel.mass;
    return givenModelShapeDef;
}

//Based on the value of kPixelToMeterRatio, converts the pixels to meters used by Box2d
- (CGFloat)pixelToMeter:(CGFloat)x {
    return x / kPixelToMeterRatio;
}

@end
