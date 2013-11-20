//
//  Overlaps.m
//  
//  CS3217 || Assignment 1
//  Name: Ishaan Singal (A0078549L)
//

#import <Foundation/Foundation.h>
#import <stdio.h>

// Import PERectangle here
#import "PERectangle.h"
// define structure Rectangle
// <definition for struct Rectangle here>
    struct Rectangle {
        double height, width, origin_x, origin_y;
    };
//Declaration of the testing functions
BOOL testOverlapsPart1();
BOOL testCenterOfMass();
BOOL testOriginTranslate();
BOOL testRotatedCorners();
BOOL testOverlapRectangle();
int test();

int overlaps(struct Rectangle rect1, struct Rectangle rect2) {
  // EFFECTS: returns 1 if rectangles overlap and 0 otherwise
    double originDiffX =  rect2.origin_x-rect1.origin_x;
    double originDiffY = rect2.origin_y-rect1.origin_y;
    
    int result  = 0;
    
    //origin of one rectangle is inside another (but body outisde) includes even if the 
    if (originDiffX<=0 && originDiffY<=0)
    {
        if (abs(originDiffX)<=rect2.width && abs(originDiffY)<=rect1.height)
            result = 1;
    }
    //the same case as above, just inverted for swapped rectangles
    else if (originDiffX>=0 && originDiffY>=0)
    {
        if (originDiffX<=rect1.width && originDiffY<=rect2.height)
            result = 1;
    }
    //overlapped rectangle where the origin point dont overlap (the top right is inside the rectangle
    else if (originDiffX>=0 && originDiffY<=0)
    {
        if (originDiffX<=rect1.width && abs(originDiffY)<=rect1.height)
            result = 1;
    }
    //the same case as above, just inverted for swapped rectanges
    else if (originDiffX<=0 && originDiffY>=0)
    {
        if (abs(originDiffX)<=rect2.width && originDiffY<=rect2.height)
            result = 1;
    }
    return result;
}


int main (int argc, const char * argv[]) {
	
    if (!test())
    {
        printf("Intial testcases have failed, exiting\n");
        return 0;
    }
    
	/* Problem 1 code (C only!) */
	// declare rectangle 1 and rectangle 2
    struct Rectangle rect1, rect2;
	
    // input origin for rectangle 1
    printf( "Input <x y> coordinates for the origin of the first rectangle: " );
	scanf("%le %le", &rect1.origin_x, &rect1.origin_y);
    
	// input size (width and height) for rectangle 1
    printf( "Input width and height of the first rectangle: " );
	scanf("%le %le", &rect1.width, &rect1.height);
    
	// input origin for rectangle 2
    printf( "Input <x y> coordinates for the origin of the second rectangle: " );
	scanf("%le %le", &rect2.origin_x, &rect2.origin_y);
    
	// input size (width and height) for rectangle 2
    printf( "Input width and height of the second rectangle: " );
	scanf("%le %le", &rect2.width, &rect2.height);
    
	// check if overlapping and write message
    if (overlaps(rect1, rect2))
        printf("The two rectangles are overlapping!\n");
    else
        printf("The two rectangles are not overlapping!\n");
  	
    
    
    /* Problem 2 code (Objective-C) */
	// declare rectangle 1 and rectangle 2 objects
    CGRect rectObj1, rectObj2;
    rectObj1.origin.x = rect1.origin_x;
    rectObj1.origin.y = rect1.origin_y;
    rectObj1.size.height = rect1.height;
    rectObj1.size.width = rect1.width;
    rectObj2.origin.x = rect2.origin_x;
    rectObj2.origin.y = rect2.origin_y;
    rectObj2.size.height = rect2.height;
    rectObj2.size.width = rect2.width;
    PERectangle *newRect1 = [[PERectangle alloc] initWithRect:rectObj1];
    PERectangle *newRect2 = [[PERectangle alloc] initWithRect:rectObj2];
    
	// input rotation for rectangle 1
    CGFloat rot1, rot2;
    printf( "Input rotation angle for the first rectangle: " );
	scanf("%lf",&rot1 );
	
    // input rotation for rectangle 2
    printf( "Input rotation angle for the second rectangle:" );
	scanf("%lf" , &rot2);
    
	// rotate rectangle objects
    [newRect1 rotate:rot1];
    [newRect2 rotate:rot2];
	// check if rectangle objects overlap and write message
    if ([newRect1 overlapsWithShape:newRect2])
        printf("The two rectangles are overlapping!\n");
    else
        printf("The two rectangles are not overlapping!\n");

	// clean up

    
	// exit program
	return 0;
}

// This is where you should put your test cases to test that your implementation is correct. 
int test() {
  // EFFECTS: returns 1 if all test cases are successfully passed and 0 otherwise
    if (!(testOverlapsPart1()))
        return 0;
    else if (!(testCenterOfMass()))
        return 0;
    else if (!(testOriginTranslate()))
        return 0;
    else if (!(testRotatedCorners()))
        return 0;
    else if (!(testOverlapRectangle()))
        return 0;
    return 1;
}

BOOL testOverlapsPart1() {
    BOOL testResult=YES;
    struct Rectangle rect1[5], rect2[5];
    int outcome[5];
    
    //Concentric test case (one rectangle in another)
    rect1[0].origin_x=10;    rect1[0].origin_y=40;    rect1[0].width = 30;    rect1[0].height = 25;
    rect2[0].origin_x=15;    rect2[0].origin_y=20;    rect2[0].width = 7;     rect2[0].height = 14;
    outcome[0]=1;
    
    //Touching rectangles
    rect1[1].origin_x=-100;  rect1[1].origin_y=-20;   rect1[1].width = 80;    rect1[1].height = 40;
    rect2[1].origin_x=-43;   rect2[1].origin_y=72;   rect2[1].width = 54;    rect2[1].height = 100;
    outcome[1]=1;
    
    //non overlapping rectangles
    rect1[2].origin_x=-80;   rect1[2].origin_y=100;   rect1[2].width = 60;    rect1[2].height = 46;
    rect2[2].origin_x=-80;   rect2[2].origin_y=20;    rect2[2].width = 50;     rect2[2].height = 66;
    outcome[2]=0;
    
    //overlapping rectangles but origin not inside (top right corner of one rectangle inside)
    rect1[3].origin_x=-10;   rect1[3].origin_y=-10;    rect1[3].width = 30;    rect1[3].height = 25;
    rect2[3].origin_x=20;    rect2[3].origin_y=12;    rect2[3].width = 7;     rect2[3].height = 30;
    outcome[3]=1;
    
    //the origin of one rectangle inside the other (but rest of the body outside)
    rect1[4].origin_x=3;    rect1[4].origin_y=3;    rect1[4].width = 5.5;    rect1[4].height = 7.2;
    rect2[4].origin_x=5.2;   rect2[4].origin_y=-3;    rect2[4].width = 7;     rect2[4].height = 1.1;
    outcome[4]=1;
    
    for (int i =0;i <5; i++)
    {
        if (overlaps(rect1[i],rect2[i])!=outcome[i])
        {
            testResult=NO;
            break;
        }
        
    }
    return testResult;
}

BOOL testOriginTranslate(){
    PERectangle *newRect = [[PERectangle alloc] initWithOrigin:CGPointMake(-20, 30) width:50 height:80 rotation:0];
    BOOL testResult = YES;
    CGPoint expected[4];
    CGPoint outcome[4];
    //translate the rectangle in all directions and compare with expected
    [newRect translateX:10 Y:-7];   outcome[0]= newRect.origin;     expected[0] = CGPointMake(-10, 23);
    [newRect translateX:-15 Y:33];  outcome[1]= newRect.origin;     expected[1] = CGPointMake(-25, 56);
    [newRect translateX:125 Y:58];  outcome[2]= newRect.origin;     expected[2] = CGPointMake(100, 114);
    [newRect translateX:-167 Y:-85];    outcome[3]= newRect.origin;     expected[3] = CGPointMake(-67, 29);

    for (int i =0;i<4;i++)
    {
        if (!(outcome[i].x == expected[i].x && outcome[i].y && expected[i].y))
        {
            testResult=NO;
            break;
        }
    }
    
    return testResult;
}

BOOL testCenterOfMass(){
    BOOL testResult=YES;
    CGPoint origin;
    CGPoint outcome[4], expected[4];

    //different centre of masses in different quadrants
    origin = CGPointMake(-10, 5);    expected[0] = CGPointMake(0, 0);
    PERectangle *newRect = [[PERectangle alloc] initWithOrigin:origin width:20 height:10 rotation:0];
    outcome[0] = newRect.center;

    origin = CGPointMake(-70, 20);   expected[1] = CGPointMake(0, 15);
    [newRect initWithOrigin:origin width:140 height:10 rotation:0];
    outcome[1] = newRect.center;
    
    origin = CGPointMake(8, 17);    expected[2] = CGPointMake(26.5, 0);
    [newRect initWithOrigin:origin width:37 height:34 rotation:0];
    outcome[2] = newRect.center;

    origin = CGPointMake(-30, -10);     expected[3] = CGPointMake(-20, -17);
    [newRect initWithOrigin:origin width:20 height:14 rotation:0];
    outcome[3] = newRect.center;

    for (int i=0; i<4;i++){
        if (!(outcome[i].x == expected[i].x && outcome[i].y == expected[i].y))
        {
            testResult = NO;
            break;
        }
    }
    return testResult;
}

BOOL testRotatedCorners(){
    BOOL testResult=YES;
    CGPoint origin;
    CGPoint expected[4];
    CGPoint* outcome;
    
    //check the case given in the sample
    origin = CGPointMake(0, 100);
    PERectangle *newRect = [[PERectangle alloc] initWithOrigin:origin width:100 height:200 rotation:0];
    [newRect rotate:90];
    outcome = [newRect corners];
    expected[0] = CGPointMake(-50, -50);     expected[1] = CGPointMake(-50, 50);      expected[2] = CGPointMake(150, 50);
    expected[3] = CGPointMake(150, -50);
    for (int j=0; j<4;j++){
        if (!((float)outcome[j].x == (float)expected[j].x && (float)outcome[j].y ==(float)expected[j].y))
        {
            testResult = NO;
            break;
        }
    }

    //rotate in the clockwise direction to confirm the functioning for a different rectangle
    origin = CGPointMake(150, 100);
    [newRect initWithOrigin:origin width:300 height:250 rotation:0];
    [newRect rotate:-90];
    outcome = newRect.corners;
    expected[0] = CGPointMake(425, 125);     expected[1] = CGPointMake(425, -175);      expected[2] = CGPointMake(175, -175);
    expected[3] = CGPointMake(175, 125);
    
    for (int j=0; j<4;j++){
        if (!((float)outcome[j].x == (float)expected[j].x && (float)outcome[j].y ==(float)expected[j].y))
        {
            testResult = NO;
            break;
        }
    }

    return testResult;
}

BOOL testOverlapRectangle(){
    BOOL result = YES;
    CGPoint origin;

    //test the case provided in the sample
    origin= CGPointMake(0, 100);
    PERectangle *rect1 = [[PERectangle alloc] initWithOrigin:origin width:100 height:200 rotation:90];
    origin = CGPointMake(150, 100);
    PERectangle *rect2 = [[PERectangle alloc] initWithOrigin:origin width:100 height:100 rotation:0];
    if (![rect1 overlapsWithShape:rect2])
        result =NO;
    
    //test touching example
    origin= CGPointMake(0, 100);
    rect1 = [[PERectangle alloc] initWithOrigin:origin width:10 height:100 rotation:180];
    origin = CGPointMake(0, 300);
    rect2 = [[PERectangle alloc] initWithOrigin:origin width:20 height:200 rotation:0];
    if (![rect1 overlapsWithShape:rect2])
        result =NO;
    //test it without overlapping now after some represenation
    [rect1 rotate:-90];
    [rect2 rotate:90];
    if ([rect1 overlapsWithShape:rect2])
        result =NO;
    
    //rotate multiple times the same rectangle to test the functionality 
    origin= CGPointMake(-15, 20);
    rect1 = [[PERectangle alloc] initWithOrigin:origin width:20 height:15 rotation:0];
    origin = CGPointMake(8, 16);
    rect2 = [[PERectangle alloc] initWithOrigin:origin width:8 height:18 rotation:90];
    if (![rect1 overlapsWithShape:rect2])
        result =NO;
    [rect1 rotate:35];
    [rect2 rotate:-75];
    if (![rect1 overlapsWithShape:rect2])
        result =NO;
    
    return result;
}

/* 

Question 2(h)
========

1.> Ask the user to enter the two diagonal opposite corner co-ordinates of the rectangle. Makes the translation easier
 PROS: Through these two coordinates, all the corresponding details can be retrieved (width height, centre). 
 CONS: Each time the rectangle is rotated this diagonal corners are changed and hence the data about the original rectangle may be lost.

2.> Ask the user to enter the centre of mass and the width and height of the rectangle. 
 PROS: This can be used to calculate all the corresponding details (the four courners including the origin. Even after rotation, the centre of mass and height width can be used to calculate the origin
 CONS: A constant reference point for the rectangle is missing and only the centre of mass can be used each time. For translation, the corners have to be recalculated.

Question 2(i): Reflection (Bonus Question)
==========================
(a) How many hours did you spend on each problem of this problem set?
Part 1 - 1hr
Part 2 - 12hrs

 
(b) In retrospect, what could you have done better to reduce the time you spent solving this problem set?

Read about objective C before hand as there were some conceptual mistakes made. Also, spent a lot of time debugging the algorithm, which could have been written more logicaly from the start
 
(c) What could the CS3217 teaching staff have done better to improve your learning experience in this problem set?

Provided a couple more day since the assignment was issued on tuesday and we collected the iPad on wednesday. Also, there were some doubts with certain aspects of the problem which everntually got solved (like the coordinate system) but delayed the coding process
*/
