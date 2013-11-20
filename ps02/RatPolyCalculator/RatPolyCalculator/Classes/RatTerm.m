#import "RatTerm.h"


@implementation RatTerm

@synthesize coeff;
@synthesize expt;

// Checks that the representation invariant holds.
-(void) checkRep{ // 5 points
    // You need to fill in the implementation of this method
    if (self.coeff == nil) {
        [NSException raise:@"RatTerm rep error" format:@"Coefficient of a RatTerm cannot be NULL"];
    }
    if ([self.coeff isEqual:[RatNum initZERO]] && (self.expt != 0)) {
        [NSException raise:@"RatTerm rep error" format:@"Exponent of RatTerm cannot be non-zero when coeff is 0"];
    }
}

-(id)initWithCoeff:(RatNum*)c Exp:(int)e{
    // REQUIRES: (c, e) is a valid RatTerm
    // EFFECTS: returns a RatTerm with coefficient c and exponent e
    
    RatNum *ZERO = [RatNum initZERO];
    // if coefficient is 0, exponent must also be 0
    // we'd like to keep the coefficient, so we must retain it
    
    if ([c isEqual:ZERO]) {
        coeff = ZERO;
        expt = 0;
    }
    else {
        coeff = c;
        expt = e;
    }
    [self checkRep];
    return self;
}

+(id)initZERO { // 5 points
    // EFFECTS: returns a zero ratterm
    return [[RatTerm alloc]initWithCoeff:[RatNum initZERO] Exp:0];
}

+(id)initNaN { // 5 points
    // EFFECTS: returns a nan ratterm
    return [[RatTerm alloc] initWithCoeff:[RatNum initNaN] Exp:0];
}

-(BOOL)isNaN { // 5 points
    // REQUIRES: self != nil
    // EFFECTS: return YES if and only if coeff is NaN
    return ([coeff isNaN]);
}

-(BOOL)isZero { // 5 points
    // REQUIRES: self != nil
    // EFFECTS: return YES if and only if coeff is zero
    return [coeff isEqual:[RatNum initZERO]];
}


// Returns the value of this RatTerm, evaluated at d.
-(double)eval:(double)d { // 5 points
    // REQUIRES: self != nil
    // EFFECTS: return the value of this polynomial when evaluated at
    //            'd'. For example, "3*x^2" evaluated at 2 is 12. if 
    //            [self isNaN] returns YES, return NaN
    if ([self isNaN]) {
        return NAN;
    }
    else {
        double result;
        result = [self.coeff doubleValue] * (pow (d, self.expt));
        return result; 
    }
}

-(RatTerm*)negate{ // 5 points
    // REQUIRES: self != nil 
    // EFFECTS: return the negated term, return NaN if the term is NaN
    //as the negate method of RatNum will return nan if the coeff is nan, we don need to explicitly check here
    return [[RatTerm alloc] initWithCoeff: [self.coeff negate] Exp:self.expt];
}



// Addition operation.
-(RatTerm*)add:(RatTerm*)arg { // 5 points
    // REQUIRES: (arg != null) && (self != nil) && ((self.expt == arg.expt) || (self.isZero() ||
    //            arg.isZero() || self.isNaN() || arg.isNaN())).
    // EFFECTS: returns a RatTerm equals to (self + arg). If either argument is NaN, then returns NaN.
    //            throws NSException if (self.expt != arg.expt) and neither argument is zero or NaN.
    RatTerm* output;
    BOOL isExptSame = (self.expt == arg.expt)? YES: NO ;
    BOOL isEitherNan = ([self isNaN] || [arg isNaN])? YES: NO;
    BOOL isEitherZero = ([self isZero] || [arg isZero])? YES: NO;
    if (!isExptSame && !isEitherNan && !isEitherZero ) {
        [NSException raise:@"Invalid addition" format:@"The exponents of the non-zero terms don't match"];
    }
    else {
        //this exponent check is made for 0 + <valid term> as the exponents would then be different
        //exponent should equal the non-zero term's expt
        int exponent = ([arg isZero])? self.expt: arg.expt;
        //since the add method of RatNum will return Nan for Nan coeff, no need to explicitly check here
        RatNum* coefficient = [self.coeff add: arg.coeff];
        output = [[RatTerm alloc] initWithCoeff: coefficient Exp: exponent];
    }
    return output;
}


// Subtraction operation.
-(RatTerm*)sub:(RatTerm*)arg { // 5 points
    // REQUIRES: (arg != nil) && (self != nil) && ((self.expt == arg.expt) || (self.isZero() ||
    //             arg.isZero() || self.isNaN() || arg.isNaN())).
    // EFFECTS: returns a RatTerm equals to (self - arg). If either argument is NaN, then returns NaN.
    //            throws NSException if (self.expt != arg.expt) and neither argument is zero or NaN.
    
    //subtraction is simply the same as addition with the second arguement negated
    return [self add: [arg negate]];
}


// Multiplication operation
-(RatTerm*)mul:(RatTerm*)arg { // 5 points
    // REQUIRES: arg != null, self != nil
    // EFFECTS: return a RatTerm equals to (self*arg). If either argument is NaN, then return NaN
    RatTerm* output;
    int exponent = self.expt + arg.expt;
    //since the mul method of RatNum will return Nan for Nan coeff, no need to explicitly check here
    RatNum* coefficient = [self.coeff mul: arg.coeff];
    output = [[RatTerm alloc] initWithCoeff: coefficient Exp: exponent];
    return output;
}


// Division operation
-(RatTerm*)div:(RatTerm*)arg { // 5 points
    // REQUIRES: arg != null, self != nil
    // EFFECTS: return a RatTerm equals to (self/arg). If either argument is NaN, then return NaN
    RatTerm* output;
    int exponent = self.expt - arg.expt;
    //since the div method of RatNum will return Nan for Nan objects, no need to explicitly check here
    RatNum* coefficient = [self.coeff div: arg.coeff];
    output = [[RatTerm alloc] initWithCoeff: coefficient Exp: exponent];
    return output;
}


// Returns a string representation of this RatTerm.
-(NSString*)stringValue { // 5 points
    //  REQUIRES: self != nil
    // EFFECTS: return A String representation of the expression represented by this.
    //           There is no whitespace in the returned string.
    //           If the term is itself zero, the returned string will just be "0".
    //           If this.isNaN(), then the returned string will be just "NaN"
    //		    
    //          The string for a non-zero, non-NaN RatTerm is in the form "C*x^E" where C
    //          is a valid string representation of a RatNum (see {@link ps1.RatNum}'s
    //          toString method) and E is an integer. UNLESS: (1) the exponent E is zero,
    //          in which case T takes the form "C" (2) the exponent E is one, in which
    //          case T takes the form "C*x" (3) the coefficient C is one, in which case T
    //          takes the form "x^E" or "x" (if E is one) or "1" (if E is zero).
    // 
    //          Valid example outputs include "3/2*x^2", "-1/2", "0", and "NaN".
    RatNum *intOne = [[RatNum alloc] initWithInteger:1];
    RatNum *minusOne = [intOne negate];
    NSString* result = [NSString string];
    
    if ([self isNaN]) {
        result = @"NaN";
    }
    else if ([self isZero]) {
        result = @"0";
    }
    else  if (self.expt == 0) {
        result = [self.coeff stringValue]; 
    }
    else {
        NSString* coefficient = [NSString string];
        NSString* exponent = [NSString string];
        if ([self.coeff isEqual: minusOne] || [self.coeff isEqual: intOne]) {
            coefficient = ([self.coeff isNegative])? @"-": @"";
        }
        else {
            coefficient = [NSString stringWithFormat:@"%@*", [self.coeff stringValue]];
        }
        //if exponent = 1, leave it as it is; dont want to apphend anything to x
        if (self.expt != 1) {
            exponent = [NSString stringWithFormat:@"^%d", self.expt];
        }
        result = [NSString stringWithFormat:@"%@x%@", coefficient, exponent];
    }
    return result;
}

// Build a new RatTerm, given a descriptive string.
+(RatTerm*)valueOf:(NSString*)str { // 5 points
    // REQUIRES: that self != nil and "str" is an instance of
    //             NSString with no spaces that expresses
    //             RatTerm in the form defined in the stringValue method.
    //             Valid inputs include "0", "x", "-5/3*x^3", and "NaN"
    // EFFECTS: returns a RatTerm t such that [t stringValue] = str
    RatTerm* result = [RatTerm initZERO];
    if ([str isEqual:@"NaN"]) {
		result = [RatTerm initNaN];
	}
    else {
        RatNum* intOne = [[RatNum alloc]initWithInteger:1];
        NSArray *tokens = [str componentsSeparatedByCharactersInSet:
                        [NSCharacterSet characterSetWithCharactersInString:@"*^"]];
        BOOL containsX = ([str rangeOfString:@"x"].length != 0)? YES: NO;
        BOOL containsCoeff = ([str rangeOfString:@"*"].length != 0)? YES: NO;
        BOOL containsExp = ([str rangeOfString:@"^"].length != 0)? YES: NO;
        BOOL isCoeffNegative = ([[str substringWithRange:NSMakeRange(0,1)] isEqualToString:@"-"])? YES: NO;
        //by default, a term x/-x is initialized (coeff 1/-1 and exp 1)
        RatNum* coefficient = (isCoeffNegative)? [intOne negate]: intOne;
        int exponent = 1;
        
        if (containsCoeff) {
            coefficient = [RatNum valueOf:[tokens objectAtIndex:0]];
        }
        //if exp entered, then take it from the tokens, or leave it at exp = 1
        if (containsExp) {
            int expIndex = (containsCoeff)? 2: 1;
            exponent = [[tokens objectAtIndex:expIndex] intValue];
        }
        //if doesnt contain x, then the str must just be the coeff with exponent as 0
        if (!containsX) {
            exponent = 0;
            coefficient = [RatNum valueOf:str];
        }
        result = [[RatTerm alloc] initWithCoeff: coefficient Exp:exponent];
    }
    return result;

}

//  Equality test,
-(BOOL)isEqual:(id)obj { // 5 points
    // REQUIRES: self != nil
    // EFFECTS: returns YES if "obj" is an instance of RatTerm, which represents
    //            the same RatTerm as self.
    BOOL result = NO;
    if([obj isKindOfClass:[RatTerm class]]) {
		RatTerm *rt = (RatTerm*)obj;
		if ([self isNaN] && [rt isNaN]) {
			result = YES;
		}
        else {
			result = [self.coeff isEqual: rt.coeff] && (self.expt == rt.expt);
		}
	}
    return result;
}

@end
