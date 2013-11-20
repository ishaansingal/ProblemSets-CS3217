//
//  RatPolyTests.m
//  RatPolyTests
//
//  Created by Ishaan Singal on 24/1/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import "RatPolyTests.h"

@implementation RatPolyTests

RatNum* num(int i) {
	return [[RatNum alloc] initWithInteger:i];
}

RatNum* num2(int i, int j) {
	return [[RatNum alloc] initWithNumer:i Denom:j];
}

RatTerm* term(int coeff, int expt) {
	return [[RatTerm alloc] initWithCoeff:num(coeff) Exp:expt];
}

RatTerm* term3(int numer, int denom, int expt) {
	return [[RatTerm alloc] initWithCoeff:num2(numer, denom) Exp:expt];
}

RatPoly* zeroPoly() {
    return [[RatPoly alloc] init];
}

RatPoly* poly1(RatTerm* term1) {
    return [[RatPoly alloc] initWithTerm:term1];
}

RatPoly* polyMult(NSArray* arrayTerms) {
    return [[RatPoly alloc] initWithTerms:arrayTerms];
}

- (void)setUp
{
    nanNum = [num(1) div:num(0)];
    nanTerm = [[RatTerm alloc] initWithCoeff:nanNum Exp:3];
    // Set-up code here.
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

-(void)testPass {
	STAssertTrue(1==1, @"", @"");
}

-(void) testCtor {
    zeroPoly();
    poly1(term(2, 3));
    poly1(term3(3, 2, 1));
    poly1(term(0, 0));
    poly1(term3(17, 11, 4));
    polyMult([NSArray arrayWithObjects: term3(4,3,7), term(8, 4), term3(19,2,3), term(3,1), nil]);
    polyMult([NSArray arrayWithObjects: term3(2,1,4), term(5,3), term3(7,6,2), term(3,1), term(5, 0), nil]);
}

-(void)testCtorNaN {
	poly1(term3(3, 0, 0));
    polyMult([NSArray arrayWithObjects: term3(4,3,7), term(8, 4), term3(19,0,0), nil]);
}

-(void)testIsNaN {
    STAssertTrue([poly1 (nanTerm) isNaN], @"", @"");
    STAssertTrue([poly1(term3(3, 0, 0)) isNaN],@"", @"");
    STAssertTrue([poly1(term3(0, 0, 8)) isNaN],@"", @"");
    STAssertTrue([polyMult([NSArray arrayWithObjects: term3(4,3,7), term(8, 4), term3(19,0,0), nil]) isNaN], @"", @"");
    STAssertFalse([poly1(term3(4, 2, 0))isNaN], @"", @"");
    STAssertFalse([poly1(term3(4, 2, 8))isNaN], @"", @"");
    STAssertFalse([polyMult([NSArray arrayWithObjects: term3(4,3,7), term(8, 4), term3(19,2,0), nil]) isNaN], @"", @"");

}

-(void)testDegree {
    STAssertTrue([poly1 (nanTerm) degree] ==3, @"", @"");
    STAssertTrue([zeroPoly() degree] == 0, @"", @"");
    STAssertTrue([poly1(term(2,3)) degree] == 3, @"", @"");
    STAssertTrue([poly1(term(3,1)) degree] == 1, @"", @"");
    STAssertTrue([poly1(term(0,0)) degree] == 0, @"", @"");
    STAssertTrue([poly1(term3(17, 11, 4)) degree] == 4, @"", @"");
    STAssertTrue([polyMult([NSArray arrayWithObjects: term3(4,3,7), term(8, 4), term3(19,2,3), term(3,1), nil]) degree] == 7, @"", @"");
    STAssertTrue([polyMult([NSArray arrayWithObjects: term3(2,1,4), term(5,3), term3(7,6,2), term(3,1), term(5, 0), nil]) degree] == 4, @"", @"");
    
    STAssertFalse([polyMult([NSArray arrayWithObjects: term3(5,1,3), term(5,2), term3(1,6,1), term(12, 0), nil]) degree] == 2, @"", @"");
}

-(void)testGetTerm {
    STAssertEqualObjects([poly1(term(2,3)) getTerm:3], term(2,3), @"", @"");
    STAssertEqualObjects([poly1(term3(7,3,1)) getTerm:1], term3(7,3,1), @"", @"");
    STAssertEqualObjects([poly1(term3(7,3,1)) getTerm:3], term(0,0), @"", @"");
    STAssertEqualObjects([polyMult([NSArray arrayWithObjects: term3(4,3,7), term(8, 4), term3(19,2,3), term(3,1), nil]) getTerm:4], term(8,4), @"", @"");
    STAssertEqualObjects([polyMult([NSArray arrayWithObjects: term3(4,3,7), term(8, 4), term3(19,2,3), term(3,1), nil]) getTerm:3], term3(19,2,3), @"", @"");
    STAssertEqualObjects([polyMult([NSArray arrayWithObjects: term3(4,3,7), term(8, 4), term3(19,2,3), term(3,1), nil]) getTerm:5], term(0,0), @"", @"");

}

-(void)testEval {
    STAssertEqualsWithAccuracy(0.0, [poly1(term(0,0)) eval:5.0], 0.0000001, @"", @"");
    STAssertEqualsWithAccuracy(0.0, [poly1(term3(0,3,3)) eval:1.2], 0.0000001, @"", @"");
    STAssertEqualsWithAccuracy(0.576, [poly1(term3(1,3,3)) eval:1.2], 0.0000001, @"", @"");
    STAssertEqualsWithAccuracy(-1822.5, [poly1(term3(-5,6,7)) eval:3], 0.0000001, @"", @"");
}

-(void)testEquals {
    RatPoly* polynom1, *polynom2;
	STAssertTrue([poly1(term(4,3)) isEqual: poly1(term(4,3))], @"", @"");
    polynom1 = polyMult([NSArray arrayWithObjects: term3(2,1,4), term(5,3), term3(7,6,2), term(3,1), term3(15,3, 0), nil]);
    polynom2 = polyMult([NSArray arrayWithObjects: term3(4,2,4), term(5,3), term3(21,18,2), term(3,1), term(5, 0), nil]);
	STAssertTrue([polynom1 isEqual: polynom2], @"", @"");
	polynom1 = polyMult([NSArray arrayWithObjects: term3(5,1,3), term(5,2), term3(1,3,1), term(4, 0), nil]);
    polynom2 = polyMult([NSArray arrayWithObjects: term3(10,2,3), term(5,2), term3(2,6,1), term3(12,3, 0), nil]);
	STAssertTrue([polynom1 isEqual: polynom2], @"", @"");
	STAssertFalse([poly1(term(4,3)) isEqual: poly1(term(3,4))], @"", @"");;
}


-(void)testValueOf:(NSString*)actual :(RatPoly*)target {
	STAssertTrue([target isEqual: [RatPoly valueOf:actual]], @"", @"");
}

-(void)testValueOfOneTerm {
    [self testValueOf:@"NaN" :poly1(term3(1,0,0))];
    [self testValueOf:@"x" :poly1(term(1,1))];
    [self testValueOf:@"-x" :poly1(term(-1,1))];
    [self testValueOf:@"0" :poly1(term(0,0))];
    [self testValueOf:@"4" :poly1(term(4,0))];
    [self testValueOf:@"-3/7" :poly1(term3(-3,7,0))];
    [self testValueOf:@"3*x" :poly1(term(3,1))];
    [self testValueOf:@"3*x^1" :poly1(term(3,1))];
    [self testValueOf:@"3*x^2" :poly1(term(3,2))];
    [self testValueOf:@"-3/2*x" :poly1(term3(-3,2,1))];
    [self testValueOf:@"-3/2*x^7" :poly1(term3(-3,2,7))];
}

-(void)testValueOfMultipleTerms {
    [self testValueOf:@"3*x^2+NaN" :polyMult([NSArray arrayWithObjects :term(3,2), term3(1,0,1), nil]) ];
    [self testValueOf:@"3*x^2+3" :polyMult([NSArray arrayWithObjects :term(3,2), term(3,0), nil]) ];
    [self testValueOf:@"-6/8*x^7+4*x^5-x^3+9" :polyMult([NSArray arrayWithObjects :term3(-3,4,7), term(4,5), term(-1,3), term(9,0), nil]) ];
}

-(void)testToString:(NSString*)target :(RatPoly*)actual {
	STAssertTrue([target isEqual: [actual stringValue]], @"", @"");
}

-(void)testToStringOneTerm {
    [self testToString:@"NaN" :poly1(term3(1,0,0))];
    [self testToString:@"x" :poly1(term(1,1))];
    [self testToString:@"-x" :poly1(term(-1,1))];
    [self testToString:@"0" :poly1(term(0,0))];
    [self testToString:@"4" :poly1(term(4,0))];
    [self testToString:@"-3/7" :poly1(term3(-3,7,0))];
    [self testToString:@"3*x" :poly1(term(3,1))];
    [self testToString:@"3*x^2" :poly1(term(3,2))];
    [self testToString:@"-3/2*x" :poly1(term3(-3,2,1))];
    [self testToString:@"-3/2*x^7" :poly1(term3(-3,2,7))];
}


-(void)testToStringMultipleTerms {
    [self testToString:@"NaN" :polyMult([NSArray arrayWithObjects :term(3,2), term3(1,0,0), nil]) ];
    [self testToString:@"3*x^2+3" :polyMult([NSArray arrayWithObjects :term(3,2), term(3,0), nil]) ];
    [self testToString:@"-3/4*x^7+4*x^5-x^3+9" :polyMult([NSArray arrayWithObjects :term3(-6,8,7), term(4,5), term(-1,3), term(9,0), nil])];
}

-(void)testNegate {
    STAssertEqualObjects(poly1(term(2,7)), [poly1(term(-2,7)) negate], @"", @"");
    STAssertEqualObjects(poly1(term(2,0)), [poly1(term(-2,0)) negate], @"", @"");
    STAssertEqualObjects(polyMult([NSArray arrayWithObjects:term3(3,7, 3), term(-2,1), term(-8,0), nil]), [polyMult([NSArray arrayWithObjects:term3(-3,7, 3), term(2,1), term(8,0), nil]) negate], @"", @"");
}

-(void)testAdd {
    RatPoly* expected;
    RatPoly* polynom1, *polynom2;
    expected = poly1(term3(1,4,2));
    polynom1 = poly1(term3(1,12,2));
    polynom2 = poly1(term3(2,12,2));
    STAssertEqualObjects(expected, [polynom1 add: polynom2], @"", @"");
    
    expected = polyMult([NSArray arrayWithObjects :term(3, 2), term(2, 1), term(3, 0), nil]);
    polynom1 = polyMult([NSArray arrayWithObjects :term(3, 2), term(3, 0), nil]);
    polynom2 = poly1(term(2, 1));
    STAssertEqualObjects(expected, [polynom1 add: polynom2], @"", @"");
    
    expected = polyMult([NSArray arrayWithObjects :term(3, 2), term3(5, 2, 1), term(4, 0), nil]);
    polynom1 = polyMult([NSArray arrayWithObjects :term(3, 2), term3(1,2,1), term(3, 0), nil]);
    polynom2 = polyMult([NSArray arrayWithObjects:term(2, 1), term(1, 0), nil]);
    STAssertEqualObjects(expected, [polynom1 add: polynom2], @"", @"");
    
    expected = polyMult([NSArray arrayWithObjects :term(3, 4), term(2, 3), term(1, 2), term3(1, 2, 1), term(3, 0), nil]);
    polynom1 = polyMult([NSArray arrayWithObjects :term(3, 4), term3(1,2,1), term(3, 0), nil]);
    polynom2 = polyMult([NSArray arrayWithObjects:term(2, 3), term(1, 2), nil]);
    STAssertEqualObjects(expected, [polynom1 add: polynom2], @"", @"");
    
    
    expected = polyMult([NSArray arrayWithObjects :term(3, 2), term(-1, 1), nil]);
    polynom1 = polyMult([NSArray arrayWithObjects :term(3, 2), term(2, 1), nil]);
    polynom2 = poly1(term(-3, 1));
    STAssertEqualObjects(expected, [polynom1 add: polynom2], @"", @"");
    
    expected = polyMult([NSArray arrayWithObjects :term(3, 2), nil]);
    polynom1 = polyMult([NSArray arrayWithObjects :term(3, 2), term(2, 1), nil]);
    polynom2 = poly1(term(-2, 1));
    STAssertEqualObjects(expected, [polynom1 add: polynom2], @"", @"");
    

    expected = polyMult([NSArray arrayWithObjects :term(2, 0), nil]);
    polynom1 = polyMult([NSArray arrayWithObjects :term(3, 2), term(2, 0), nil]) ;
    polynom2 = poly1(term(-3, 2));
    STAssertEqualObjects(expected, [polynom1 add: polynom2], @"", @"");
}

-(void)testSub {
    RatPoly* expected;
    RatPoly* polynom1, *polynom2;
    expected = poly1(term3(-1,12,2));
    polynom1 = poly1(term3(1,12,2));
    polynom2 = poly1(term3(2,12,2));
    STAssertEqualObjects(expected, [polynom1 sub: polynom2], @"", @"");

    expected = polyMult([NSArray arrayWithObjects :term(-3, 2), term(2, 1), term(-3, 0), nil]);
    polynom1 = poly1(term(2, 1));
    polynom2 = polyMult([NSArray arrayWithObjects :term(3, 2), term(3, 0), nil]);
    STAssertEqualObjects(expected, [polynom1 sub: polynom2], @"", @"");

    expected = polyMult([NSArray arrayWithObjects :term(3, 2), term3(-3, 2, 1), term(2, 0), nil]);
    polynom1 = polyMult([NSArray arrayWithObjects :term(3, 2), term3(1,2,1), term(3, 0), nil]);
    polynom2 = polyMult([NSArray arrayWithObjects:term(2, 1), term(1, 0), nil]);
    STAssertEqualObjects(expected, [polynom1 sub: polynom2], @"", @"");
    
    expected = polyMult([NSArray arrayWithObjects :term(3, 4), term(-2, 3), term(-1, 2), term3(1, 2, 1), term(3, 0), nil]);
    polynom1 = polyMult([NSArray arrayWithObjects :term(3, 4), term3(1,2,1), term(3, 0), nil]);
    polynom2 = polyMult([NSArray arrayWithObjects:term(2, 3), term(1, 2), nil]);
    STAssertEqualObjects(expected, [polynom1 sub: polynom2], @"", @"");

    expected = polyMult([NSArray arrayWithObjects :term(3, 4), term(-2, 3), term(-1, 2), term3(1, 2, 1), term(3, 0), nil]);
    polynom1 = polyMult([NSArray arrayWithObjects :term(3, 4), term3(1,2,1), term(3, 0), nil]);
    polynom2 = polyMult([NSArray arrayWithObjects:term(2, 3), term(1, 2), nil]);
    STAssertEqualObjects(expected, [polynom1 sub: polynom2], @"", @"");
}

-(void)testMul {
    RatPoly* expected;
    RatPoly* polynom1, *polynom2;
    
    expected = polyMult([NSArray arrayWithObjects :term(3, 5), term(-6, 3), term(6, 2), nil]);
    polynom1 = polyMult([NSArray arrayWithObjects :term(1, 3), term(-2, 1), term(2, 0), nil]);
    polynom2 = poly1(term3(3, 1, 2));
    STAssertEqualObjects(expected, [polynom1 mul: polynom2], @"", @"");

    expected = polyMult([NSArray arrayWithObjects :term(-2, 3), term(4, 1), term(-4, 0), nil]);
    polynom1 = polyMult([NSArray arrayWithObjects :term(1, 3), term(-2, 1), term(2, 0), nil]);
    polynom2 = poly1(term3(-2, 1, 0));
    STAssertEqualObjects(expected, [polynom1 mul: polynom2], @"", @"");
    
    expected = polyMult([NSArray arrayWithObjects :term(9, 4), term(-4, 0), nil]);
    polynom1 = polyMult([NSArray arrayWithObjects :term(3, 2), term(2, 0), nil]);
    polynom2 = polyMult([NSArray arrayWithObjects :term(3, 2), term(-2, 0), nil]);
    STAssertEqualObjects(expected, [polynom1 mul: polynom2], @"", @"");

}

-(void)testDiv {
    RatPoly* expected;
    RatPoly* polynom1, *polynom2;
    expected = poly1(term3(1, 3, 1));
    polynom1 = polyMult([NSArray arrayWithObjects :term(1, 3), term(-2, 1), term(2, 0), nil]);
    polynom2 = poly1(term3(3, 1, 2));
    STAssertEqualObjects(expected, [polynom1 div: polynom2], @"", @"");

    expected = zeroPoly();
    polynom1 = polyMult([NSArray arrayWithObjects :term(1, 2), term(2, 1), term(15, 0), nil]);
    polynom2 = poly1(term(2, 3));
    STAssertEqualObjects(expected, [polynom1 div: polynom2], @"", @"");

    expected = polyMult([NSArray arrayWithObjects:term(1, 2), term(-1, 1), term(2, 0), nil]);
    polynom1 = polyMult([NSArray arrayWithObjects :term(1, 3), term(1, 1), term(-1, 0), nil]);
    polynom2 = polyMult([NSArray arrayWithObjects:term(1, 1), term(1, 0), nil]);
    STAssertEqualObjects(expected, [polynom1 div: polynom2], @"", @"");

    
}

-(void)testOperationsOnNaN {
    STAssertEqualObjects(poly1(nanTerm), [poly1(nanTerm) add:poly1(term(3, 4))], @"", @"");
    STAssertEqualObjects(poly1(nanTerm), [poly1(term(3, 4)) add:poly1(nanTerm)], @"", @"");
    STAssertEqualObjects(poly1(nanTerm), [polyMult([NSArray arrayWithObjects :term(3,2), term3(1,0,0), nil]) add:poly1(term(3, 4))], @"", @"");
    STAssertEqualObjects(poly1(nanTerm), [poly1(term(3, 4)) add: polyMult([NSArray arrayWithObjects :term(3,2), term3(1,0,0), nil])] , @"", @"");

    
    STAssertEqualObjects(poly1(nanTerm), [poly1(nanTerm) sub:poly1(term(3, 4))], @"", @"");
    STAssertEqualObjects(poly1(nanTerm), [poly1(term(3, 4)) sub:poly1(nanTerm)], @"", @"");
    STAssertEqualObjects(poly1(nanTerm), [polyMult([NSArray arrayWithObjects :term(3,2), term3(1,0,0), nil]) sub:poly1(term(3, 4))], @"", @"");
    STAssertEqualObjects(poly1(nanTerm), [poly1(term(3, 4)) sub: polyMult([NSArray arrayWithObjects :term(3,2), term3(1,0,0), nil])] , @"", @"");
    

    STAssertEqualObjects(poly1(nanTerm), [poly1(nanTerm) mul:poly1(term(3, 4))], @"", @"");
    STAssertEqualObjects(poly1(nanTerm), [poly1(term(3, 4)) mul:poly1(nanTerm)], @"", @"");
    STAssertEqualObjects(poly1(nanTerm), [polyMult([NSArray arrayWithObjects :term(3,2), term3(1,0,0), nil]) mul:poly1(term(3, 4))], @"", @"");
    STAssertEqualObjects(poly1(nanTerm), [polyMult([NSArray arrayWithObjects :term(3,2), term3(1,1,0), nil]) mul: poly1(nanTerm)], @"", @"");
    STAssertEqualObjects(poly1(nanTerm), [poly1(term(3, 4)) mul: polyMult([NSArray arrayWithObjects :term(3,2), term3(1,0,0), nil])] , @"", @"");


    STAssertEqualObjects(poly1(nanTerm), [poly1(nanTerm) div:poly1(term(3, 4))], @"", @"");
    STAssertEqualObjects(poly1(nanTerm), [poly1(term(3, 4)) div:poly1(nanTerm)], @"", @"");
    STAssertEqualObjects(poly1(nanTerm), [polyMult([NSArray arrayWithObjects :term(3,2), term3(1,0,0), nil]) div:poly1(term(3, 4))], @"", @"");
    STAssertEqualObjects(poly1(nanTerm), [poly1(term(3, 4)) div: polyMult([NSArray arrayWithObjects :term(3,2), term3(1,0,0), nil])] , @"", @"");

    STAssertEqualObjects(poly1(nanTerm), [polyMult([NSArray arrayWithObjects:term3(-3, 7, 3), term(2, 1), term3(1, 0, 0), nil]) negate], @"", @"");
    STAssertEqualObjects(poly1(nanTerm), [poly1(nanTerm) negate], @"", @"");
    STAssertEqualObjects(poly1(nanTerm), [poly1(nanTerm) add:poly1(nanTerm)], @"", @"");
    STAssertEqualObjects(poly1(nanTerm), [poly1(nanTerm) sub:poly1(nanTerm)], @"", @"");
    STAssertEqualObjects(poly1(nanTerm), [poly1(nanTerm) mul:poly1(nanTerm)], @"", @"");
    STAssertEqualObjects(poly1(nanTerm), [poly1(nanTerm) div:poly1(nanTerm)], @"", @"");
    STAssertEqualObjects(poly1(nanTerm), [poly1(term(3,2)) div:zeroPoly()], @"", @"");
    STAssertEqualObjects(poly1(nanTerm), [poly1(nanTerm) div:zeroPoly()], @"", @"");
    STAssertEqualObjects(poly1(nanTerm), [zeroPoly() div:zeroPoly()], @"", @"");
    STAssertEqualObjects(poly1(nanTerm), [poly1(nanTerm) add:zeroPoly()], @"", @"");
    STAssertEqualObjects(poly1(nanTerm), [poly1(nanTerm) sub:zeroPoly()], @"", @"");
    STAssertEqualObjects(poly1(nanTerm), [poly1(nanTerm) mul:zeroPoly()], @"", @"");
    STAssertEqualObjects(poly1(nanTerm), [zeroPoly() div:poly1(nanTerm)], @"", @"");



}

-(void)testOperationsOnZero {
    RatPoly* p = poly1(term3(3, 4, 2));
    STAssertEqualObjects(p, [zeroPoly() add:p], @"", @"");
    STAssertEqualObjects(p, [p add:zeroPoly()], @"", @"");
    STAssertEqualObjects(poly1(term3(-3, 4, 2)), [zeroPoly() sub:p], @"", @"");
    STAssertEqualObjects(p, [p sub:zeroPoly()], @"", @"");
    STAssertEqualObjects(zeroPoly(), [zeroPoly() mul:p], @"", @"");
    STAssertEqualObjects(zeroPoly(), [p mul:zeroPoly()], @"", @"");
    STAssertEqualObjects(zeroPoly(), [zeroPoly() div:p], @"", @"");
    STAssertEqualObjects(poly1(nanTerm), [p div:zeroPoly()], @"", @"");
    STAssertEqualObjects(zeroPoly(), [zeroPoly() negate], @"", @"");
   
    STAssertEqualObjects(zeroPoly(), [zeroPoly() add:zeroPoly()], @"", @"");
    STAssertEqualObjects(zeroPoly(), [zeroPoly() sub:zeroPoly()], @"", @"");
    STAssertEqualObjects(zeroPoly(), [zeroPoly() mul:zeroPoly()], @"", @"");

}

@end
