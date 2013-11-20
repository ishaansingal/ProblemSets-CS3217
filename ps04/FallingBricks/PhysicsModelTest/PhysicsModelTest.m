//
//  PhysicsModelTest.m
//  PhysicsModelTest
//
//  Created by Ishaan Singal on 12/2/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import "PhysicsModelTest.h"

@implementation PhysicsModelTest

//+ (PhysicsModel*)getNewObjectWithMass:(CGFloat)m Size:(CGSize)s Center:(CGPoint)center {
//    return [[PhysicsModel alloc]initWithMass:m Size:s Center:center];
//}

PhysicsModel *defaultObject (CGFloat mass, CGSize s, CGPoint center, CGFloat rotation) {
    return [[PhysicsModel alloc]initWithMass:mass Size:s Center:center Rotation:rotation];
}


PhysicsModel *frictObject (CGFloat mass, CGSize s, CGPoint center, CGFloat rot, CGFloat frict, CGFloat coeffRest) {
    return [[PhysicsModel alloc]initWithMass:mass Size:s Center:center Rotation:rot Friction:frict Restitution:coeffRest];
}

PhysicsModel *fullObject (CGFloat mass, CGSize s, CGPoint center, CGFloat rot,
                          Vector2D* v, CGFloat angV, CGFloat fric, CGFloat rest) {
    return [[PhysicsModel alloc]initWithMass:mass
                                        Size:s
                                      Center:center
                                    Rotation:rot
                                    Velocity:v
                                  AngularVel:angV
                                    Friction:fric
                                 Restitution:rest];
}

- (void)setUp {
    [super setUp];
    // Set-up code here.
}

- (void)tearDown {
    // Tear-down code here.
    [super tearDown];
}


- (void)testDefaultCtor {
    defaultObject(10, CGSizeMake(50, 100), CGPointMake(80, 40), 1);
    defaultObject(1, CGSizeMake(-50, 100), CGPointMake(80, -40), 0);
    defaultObject(INFINITY, CGSizeMake(800, 1), CGPointMake(1, 1), -2.3);
}

- (void)testFrictCtor {
    frictObject (10, CGSizeMake(400, 400), CGPointMake(100, 100), 1, 0.8 , 0.1);
    frictObject (INFINITY, CGSizeMake(1, 1), CGPointMake(12, 12), 0.9, 0.8 , 0.1);
    frictObject (76000, CGSizeMake(34, 9999), CGPointMake(80, 200), 0.1, 0.1 , 0.2);
    //even though the value is invalid, the PhyiscsModel does not check it and would accept
    frictObject (0, CGSizeMake(30, 50), CGPointMake(800, -40), 10, 2 , 0.1);
}

- (void)testFullCtor {
    frictObject (10, CGSizeMake(400, 400), CGPointMake(100, 100), 1, 0.8 , 0.1);
    frictObject (INFINITY, CGSizeMake(1, 1), CGPointMake(12, 12), 0.9, 0.8 , 0.1);
    frictObject (76000, CGSizeMake(34, 9999), CGPointMake(80, 200), 0.1, 0.1 , 0.2);
    //even though the value is invalid, the PhyiscsModel does not check it and would accept
    frictObject (0, CGSizeMake(30, 50), CGPointMake(800, -40), 10, 2 , 0.1);
}

- (void)testInertia {
    PhysicsModel *currentModel = defaultObject(10, CGSizeMake(50, 100), CGPointMake(80, 40), 0);
    double expected = (50 * 50 + 100 * 100) * 10;
    expected = expected / 12;
    STAssertEqualsWithAccuracy(expected, currentModel.inertia, 0.001, @"", @"");

    currentModel = defaultObject(1, CGSizeMake(0.5, 1), CGPointMake(8.6, 50.94), 0.9);
    expected = (0.5 * 0.5 + 1 * 1) * 1;
    expected = expected / 12;
    STAssertEqualsWithAccuracy(expected, currentModel.inertia, 0.001, @"", @"");

    currentModel = defaultObject(INFINITY, CGSizeMake(33.9, 22.1), CGPointMake(80, 40), -0.2);
    expected = INFINITY;
    STAssertEqualsWithAccuracy(expected, currentModel.inertia, 0.001, @"", @"");

    currentModel = defaultObject(0, CGSizeMake(500, 120), CGPointMake(80, 40), 12);
    expected = 0;
    STAssertEqualsWithAccuracy(expected, currentModel.inertia, 0.001, @"", @"");
}

- (void)testRotationMatrix {
    PhysicsModel *currentModel = defaultObject(10, CGSizeMake(50, 100), CGPointMake(80, 40), 0);
    Matrix2D *expected = [Matrix2D initRotationMatrix:0];
    STAssertEquals(expected.col1.x, currentModel.rotationMatrix.col1.x, @"", @"");
    STAssertEquals(expected.col1.y, currentModel.rotationMatrix.col1.y, @"", @"");
    STAssertEquals(expected.col2.x, currentModel.rotationMatrix.col2.x, @"", @"");
    STAssertEquals(expected.col2.y, currentModel.rotationMatrix.col2.y, @"", @"");

    currentModel = defaultObject(INFINITY, CGSizeMake(19, 11), CGPointMake(80, 40), 1.8);
    expected = [Matrix2D initRotationMatrix:1.8];
    STAssertEquals(expected.col1.x, currentModel.rotationMatrix.col1.x, @"", @"");
    STAssertEquals(expected.col1.y, currentModel.rotationMatrix.col1.y, @"", @"");
    STAssertEquals(expected.col2.x, currentModel.rotationMatrix.col2.x, @"", @"");
    STAssertEquals(expected.col2.y, currentModel.rotationMatrix.col2.y, @"", @"");

    currentModel = defaultObject(1194, CGSizeMake(19, 11), CGPointMake(80, 40), 3.14);
    expected = [Matrix2D initRotationMatrix:3.14];
    STAssertEquals(expected.col1.x, currentModel.rotationMatrix.col1.x, @"", @"");
    STAssertEquals(expected.col1.y, currentModel.rotationMatrix.col1.y, @"", @"");
    STAssertEquals(expected.col2.x, currentModel.rotationMatrix.col2.x, @"", @"");
    STAssertEquals(expected.col2.y, currentModel.rotationMatrix.col2.y, @"", @"");
    
    currentModel = defaultObject(0, CGSizeMake(500, 430.2), CGPointMake(-1.2, 940), -0.9);
    expected = [Matrix2D initRotationMatrix:-0.9];
    STAssertEquals(expected.col1.x, currentModel.rotationMatrix.col1.x, @"", @"");
    STAssertEquals(expected.col1.y, currentModel.rotationMatrix.col1.y, @"", @"");
    STAssertEquals(expected.col2.x, currentModel.rotationMatrix.col2.x, @"", @"");
    STAssertEquals(expected.col2.y, currentModel.rotationMatrix.col2.y, @"", @"");
}

- (void)testDelegate {
    PhysicsModel *currentModel = defaultObject(10, CGSizeMake(50, 100), CGPointMake(80, 40), 0);
    [currentModel setDelegate:self];
    expectedDel = defaultObject(10, CGSizeMake(50, 100), CGPointMake(60, 52), 1.5);
    [currentModel center:CGPointMake(60, 52)];
    [currentModel rotate:1.5];

    PhysicsModel *nextModel = defaultObject(INFINITY, CGSizeMake(50, 100), CGPointMake(80, 40), 0);
    [nextModel setDelegate:self];
    expectedDel = defaultObject(INFINITY, CGSizeMake(50, 100), CGPointMake(900, 12), -5);
    [nextModel center:CGPointMake(900, 12)];
    [nextModel rotate:-5];
}

//translates the object in the world
- (void)didMove:(id)sender {
    PhysicsModel *currentBrick = (PhysicsModel*)sender;
    STAssertTrue(CGPointEqualToPoint(currentBrick.center, expectedDel.center), @"", @"");
    STAssertTrue(CGSizeEqualToSize(currentBrick.size, expectedDel.size), @"", @"");
    STAssertTrue(currentBrick.mass == expectedDel.mass, @"", @"");
}

//rotates the view of the brick
- (void)didRotate:(id)sender {
    PhysicsModel *currentBrick = (PhysicsModel*)sender;
    STAssertTrue(CGPointEqualToPoint(currentBrick.center, expectedDel.center), @"", @"");
    STAssertTrue(CGSizeEqualToSize(currentBrick.size, expectedDel.size), @"", @"");
    STAssertTrue(currentBrick.mass == expectedDel.mass, @"", @"");
    STAssertTrue(currentBrick.rotation == expectedDel.rotation, @"", @"");
}


@end
