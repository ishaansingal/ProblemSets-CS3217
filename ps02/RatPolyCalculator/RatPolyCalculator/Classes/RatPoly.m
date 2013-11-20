#import "RatPoly.h"


@interface RatPoly()
-(BOOL) isZeroPolynomial;

@end

@implementation RatPoly

@synthesize terms;

-(NSArray* )terms {
    return [terms copy];
}

// Note that since there is no variable called "degree" in our class,the compiler won't synthesize 
// the "getter" for "degree". and we have to write our own getter
-(int)degree{ // 5 points
    // EFFECTS: returns the degree of this RatPoly object. 
    RatTerm* firstTerm;
    if ([self.terms count] == 0) {
        return 0;
    }
    else {
         firstTerm = [self.terms objectAtIndex:0];
    }
    return firstTerm.expt;
}

// Check that the representation invariant is satisfied
-(void)checkRep{ // 5 points
    if (self.terms == nil) {
        [NSException raise:@"RatPoly checkrep error" format:@"The polynomial cannot have nil terms"];
    }
    //check for zero or exp < 0
    for (int i = 0; i < ([self.terms count]);i++) {
        RatTerm* currentTerm = [self.terms objectAtIndex:i];
        if ([currentTerm isZero]) {
            [NSException raise:@"RatPoly checkrep error" format:@"None of the RatTerms' coefficient can be zero"];
        }
        if (currentTerm.expt < 0) {
            [NSException raise:@"RatPoly checkrep error" format:@"None of the RatTerms' expt can be less than zero"];
        }
    }
    int count = (int)[self.terms count];
    //check if the order is correct
    for (int i = 0; i < (count-1);i++) {
        RatTerm* firstTerm = [self.terms objectAtIndex:i];
        RatTerm* secondTerm = [self.terms objectAtIndex:i+1];
        if (firstTerm.expt <= secondTerm.expt) {
            [NSException raise:@"RatPoly checkrep error" format:@"The RatTerms are not in descending order of degree"];
        }
    }
    
}

-(id)init { // 5 points
    //EFFECTS: constructs a polynomial with zero terms, which is effectively the zero polynomial
    //           remember to call checkRep to check for representation invariant
    terms = [[NSArray alloc] init];
    [self checkRep];
    return self;
}

-(id)initWithTerm:(RatTerm*)rt{ // 5 points
    //  REQUIRES: [rt expt] >= 0
    //  EFFECTS: constructs a new polynomial equal to rt. if rt's coefficient is zero, constructs
    //             a zero polynomial remember to call checkRep to check for representation invariant
    if ([rt isZero]) {
        return[[RatPoly alloc]init];
    }
    else {
        terms = [[NSArray alloc] initWithObjects:rt, nil];
        [self checkRep];
        return self;
    }
}

-(id)initWithTerms:(NSArray*)ts{ // 5 points
    // REQUIRES: "ts" satisfies clauses given in the representation invariant
    // EFFECTS: constructs a new polynomial using "ts" as part of the representation.
    //            the method does not make a copy of "ts". remember to call checkRep to check for representation invariant
    //If only one term, then initializes using initWithTerm
    if ([ts count] == 1) {
        return [[RatPoly alloc] initWithTerm:[ts objectAtIndex:0]];
    }
    terms = [[NSArray alloc]initWithArray:ts];
    [self checkRep];
    return self;
}

-(RatTerm*)getTerm:(int)deg { // 5 points
    // REQUIRES: self != nil && ![self isNaN]
    // EFFECTS: returns the term associated with degree "deg". If no such term exists, return
    //            the zero RatTerm
    RatTerm* outputTerm = [RatTerm initZERO];
    for (RatTerm* currentTerm in self.terms) {
        if (currentTerm.expt == deg ) {
            outputTerm = currentTerm;
        }
    }
    return outputTerm;
}

-(BOOL)isNaN { // 5 points
    // REQUIRES: self != nil
    //  EFFECTS: returns YES if this RatPoly is NaN
    //             i.e. returns YES if and only if some coefficient = "NaN".
    BOOL output = NO;
    for (RatTerm* currentTerm in self.terms) {
        if ([currentTerm isNaN] ) {
            output = YES;
            break;
        }
    }
    return output;
}


-(BOOL)isZeroPolynomial { // 5 points
    // REQUIRES: self != nil
    //  EFFECTS: returns YES if this RatPoly is zero polynomial
    //             i.e. returns YES if and only if terms contains no objects.
    BOOL output = NO;
    if ([self.terms count] == 0 ) {
        output = YES;
    }
    return output;
}

-(RatPoly*)negate { // 5 points
    // REQUIRES: self != nil 
    // EFFECTS: returns the additive inverse of this RatPoly.
    //            returns a RatPoly equal to "0 - self"; if [self isNaN], returns
    //            some r such that [r isNaN]
    
    RatPoly* finalPoly = [[RatPoly alloc]init];
    //Individually negate every term in the polynomial and add it to outcome
    for (RatTerm* eachTerm in self.terms) {
        RatPoly* eachTermAsPoly = [[RatPoly alloc]initWithTerm:[eachTerm negate]];
        finalPoly = [finalPoly add: eachTermAsPoly];
    }
    return finalPoly;
}


// Addition operation
-(RatPoly*)add:(RatPoly*)p { // 5 points
    // REQUIRES: p!=nil, self != nil
    // EFFECTS: returns a RatPoly r, such that r=self+p; if [self isNaN] or [p isNaN], returns
    //            some r such that [r isNaN]
    
    NSMutableArray*  selfTerms = [[NSMutableArray alloc] initWithArray: self.terms];
    int i = 0;
    for (RatTerm* pTerm in p.terms) {
        int count = (int)[selfTerms count];
        for (; i < count; i++) {
            RatTerm* currentTerm = [selfTerms objectAtIndex:i];
            //if given poly has same exp as existing poly, add the two
            if (pTerm.expt == currentTerm.expt) {
                if ([[currentTerm add:pTerm] isZero]) {
                    [selfTerms removeObjectAtIndex:i];
                }
                else {
                    [selfTerms replaceObjectAtIndex:i withObject:[currentTerm add:pTerm]];
                }
                break;
            }
            //if given poly's exp is between two existing polys, insert at that index
            else if (pTerm.expt > currentTerm.expt) {
                [selfTerms insertObject:pTerm atIndex: i];
                break;
            }
        }
        //if the given poly is the smallest, insert it at the end
        if (i == count) {
            [selfTerms insertObject:pTerm atIndex: i];
        }
    }
    return [[RatPoly alloc] initWithTerms:selfTerms];
}

// Subtraction operation
-(RatPoly*)sub:(RatPoly*)p { // 5 points
    // REQUIRES: p!=nil, self != nil
    // EFFECTS: returns a RatPoly r, such that r=self-p; if [self isNaN] or [p isNaN], returns
    //            some r such that [r isNaN]
    //Sutraction is addition with second term negated
    return [self add: [p negate]];
}


// Multiplication operation
-(RatPoly*)mul:(RatPoly*)p { // 5 points
    // REQUIRES: p!=nil, self != nil
    // EFFECTS: returns a RatPoly r, such that r=self*p; if [self isNaN] or [p isNaN], returns
    // some r such that [r isNaN]
    RatPoly* finalOutcome = [[RatPoly alloc] init];
    BOOL selfNanPZero = ([p isZeroPolynomial] && [self isNaN])? YES: NO;
    BOOL selfZeroPNan = ([self isZeroPolynomial] && [p isNaN])? YES: NO;
    if (selfNanPZero || selfZeroPNan ) {
        finalOutcome = [[RatPoly alloc] initWithTerm:[RatTerm initNaN]];
    }
    else {
        for (RatTerm* pTerm in p.terms) {
            //multiply all the terms of p with each self term
            for (RatTerm* curTerm in self.terms) {
                RatTerm* mulTerm = [pTerm mul: curTerm]; //the mulitplied term
                //keep adding the multiplied term to the existing polynomial
                finalOutcome = [finalOutcome add: [[RatPoly alloc] initWithTerm: mulTerm]];
            }
        }
    }
    return finalOutcome;
}


// Division operation (truncating).
-(RatPoly*)div:(RatPoly*)p{ // 5 points
    // REQUIRES: p != null, self != nil
    // EFFECTS: return a RatPoly, q, such that q = "this / p"; if p = 0 or [self isNaN]
    //           or [p isNaN], returns some q such that [q isNaN]
    //
    // Division of polynomials is defined as follows: Given two polynomials u
    // and v, with v != "0", we can divide u by v to obtain a quotient
    // polynomial q and a remainder polynomial r satisfying the condition u = "q *
    // v + r", where the degree of r is strictly less than the degree of v, the
    // degree of q is no greater than the degree of u, and r and q have no
    // negative exponents.
    // 
    // For the purposes of this class, the operation "u / v" returns q as
    // defined above.
    //
    // The following are examples of div's behavior: "x^3-2*x+3" / "3*x^2" =
    // "1/3*x" (with r = "-2*x+3"). "x^2+2*x+15 / 2*x^3" = "0" (with r =
    // "x^2+2*x+15"). "x^3+x-1 / x+1 = x^2-x+2 (with r = "-3").
    //
    // Note that this truncating behavior is similar to the behavior of integer
    // division on computers.
   
    RatPoly* quotient = [[RatPoly alloc] init];
    RatPoly* remainder = [[RatPoly alloc]initWithTerms:self.terms];
    if ([p isZeroPolynomial] || [p isNaN] || [self isNaN]) {
        RatTerm* nanTerm = [RatTerm initNaN];
        quotient = [[RatPoly alloc] initWithTerm:nanTerm];
    }
    else {
        //As explained in the pseudo code, the same logic is used here
        while (!([remainder isZeroPolynomial]) && (remainder.degree >= p.degree)) {
            RatTerm* highestDegreeDiv = [remainder.terms objectAtIndex:0];
            highestDegreeDiv = [highestDegreeDiv div:[p.terms objectAtIndex:0]];
            RatPoly* currentDivisor = [[RatPoly alloc] initWithTerm:highestDegreeDiv];
            quotient = [quotient add:currentDivisor];
            remainder = [remainder sub:[currentDivisor mul:p]];
        }
    }
    return quotient;
}

-(double)eval:(double)d { // 5 points
    // REQUIRES: self != nil
    // EFFECTS: returns the value of this RatPoly, evaluated at d
    //            for example, "x+2" evaluated at 3 is 5, and "x^2-x" evaluated at 3 is 6.
    //            if [self isNaN], return NaN
    double evalResult = 0;
    if ([self isNaN]) {
        return NAN;
    }
    //add the evaluation of each inidividual term
    for (RatTerm* currTerm in self.terms) {
        evalResult += [currTerm eval:d];
    }
    return evalResult;
}


// Returns a string representation of this RatPoly.
-(NSString*)stringValue { // 5 points
    // REQUIRES: self != nil
    // EFFECTS:
    // return A String representation of the expression represented by this,
    // with the terms sorted in order of degree from highest to lowest.
    //
    // There is no whitespace in the returned string.
    //        
    // If the polynomial is itself zero, the returned string will just
    // be "0".
    //         
    // If this.isNaN(), then the returned string will be just "NaN"
    //         
    // The string for a non-zero, non-NaN poly is in the form
    // "(-)T(+|-)T(+|-)...", where "(-)" refers to a possible minus
    // sign, if needed, and "(+|-)" refer to either a plus or minus
    // sign, as needed. For each term, T takes the form "C*x^E" or "C*x"
    // where C > 0, UNLESS: (1) the exponent E is zero, in which case T
    // takes the form "C", or (2) the coefficient C is one, in which
    // case T takes the form "x^E" or "x". In cases were both (1) and
    // (2) apply, (1) is used.
    //        
    // Valid example outputs include "x^17-3/2*x^2+1", "-x+1", "-1/2",
    // and "0".
    NSString* result = [NSString string];
    if ([self isZeroPolynomial]) {
        result = @"0";
    }
    else if ([self isNaN]) {
        result = @"NaN";
    }
    else {
        for (RatTerm* eachTerm in self.terms) {
            NSString* termString = [eachTerm stringValue];
            if ([eachTerm.coeff isPositive]) {
                result = [result stringByAppendingString:@"+"];
            }
            result = [result stringByAppendingString:termString];
        }
        //trim the '+' at the start if present
        NSCharacterSet* plusChar = [NSCharacterSet characterSetWithCharactersInString:@"+"];
        result = [result stringByTrimmingCharactersInSet: plusChar];
    }
    return result;

}


// Builds a new RatPoly, given a descriptive String.
+(RatPoly*)valueOf:(NSString*)str { // 5 points
    // REQUIRES : 'str' is an instance of a string with no spaces that
    //              expresses a poly in the form defined in the stringValue method.
    //              Valid inputs include "0", "x-10", and "x^3-2*x^2+5/3*x+3", and "NaN".
    // EFFECTS : return a RatPoly p such that [p stringValue] = str
    // EFFECTS: returns a RatTerm t such that [t stringValue] = str

    NSMutableArray* obj = [NSMutableArray array];
    NSString* newStr = [str stringByReplacingOccurrencesOfString:@"-" withString:@"+-"];
    NSArray *tokens = [newStr componentsSeparatedByString:@"+"];
    for (NSString* eachterm in tokens) {
        //if not an empty token then add it to the poly
        if (![eachterm isEqualToString:@""]) {
            [obj addObject:[RatTerm valueOf:eachterm]];
        }
    }
    return [[RatPoly alloc]initWithTerms:obj];
}

// Equality test
-(BOOL)isEqual:(id)obj { // 5 points
    // REQUIRES: self != nil
    // EFFECTS: returns YES if and only if "obj" is an instance of a RatPoly, which represents
    //            the same rational polynomial as self. All NaN polynomials are considered equal
    BOOL outcome = NO;
    if([obj isKindOfClass:[RatPoly class]]) {
		RatPoly *rp = (RatPoly*)obj;
        BOOL sameDegree = (self.degree == rp.degree)? YES: NO;
        BOOL sameNumTerms = ([self.terms count] == [rp.terms count])? YES: NO;
        BOOL bothNaN = ([self isNaN] && [rp isNaN])? YES: NO;
        BOOL bothZero = ([self isZeroPolynomial] && [rp isZeroPolynomial])? YES: NO;
		if (bothNaN || bothZero) { //if Nan, return immediately
			outcome = YES;
        }
        else if (sameDegree && sameNumTerms) {
            int count = (int)[self.terms count];
            for (int i = 0; i < count ;i++) {
                RatTerm* obj1 = [self.terms objectAtIndex:i];
                RatTerm* obj2 = [rp.terms objectAtIndex:i];
                //compare all the items and then proceed to return
                if ([obj1 isEqual:obj2]) {
                    outcome = YES;
                }
                // break as soon as even one non-matching item is found
                else {
                    outcome = NO;
                    break;
                }
            }
        }
    }
    return outcome;
}


@end

/* 
 
 Question 1(a)
 ========
 
 r = p - q:
    set r = p by making a term-by-term copy of all terms in p to r
    foreach term tq in q :
        if any term tr in r has the same degree as tq,
            then replace tr in r with the difference of tr and tq
        else insert negate of tq into r as a new term
 
 or
 
 if add function is implemented, then here, the subtraction was basically addition with second term negated
 
 Question 1(b)
 ========
 
 r = p * q:
    if p or q is NaN
        insert NaN term in r and return
    else foreach term tp in p :
        foreach term tq in q:
            multiply tp with every term tq in q and add it in r
 
 
 Question 1(c)
 ========
 
 q = n / d:
    set q (quotient) as zero polynomial and r (remainder) as n
    while r contains a term and highest degree of r is greater than highest degree of d
        compute the division of highest degree of r with highest degree of d
        set q as this division plus q (q = q + divisor)
        set remainder as remainder minus the product of d and divisor (r = r - (divisor*d))
 the q left at the end is the quotient
 
 Question 2(a)
 ========
 
 If self is null, then performing computations on it can be very unreliable. No matter what operation is being performed on it, self will only return nil (0)
 If the check for arg == NaN is not made in div, then it would actually compute a value to be 0, as the logic is:
    [[RatNum alloc] initWithNumer:self.numer*arg.denom Denom:self.denom*arg.numer]
    So for say 3/2 div 1/0, the result would be (3*0)/(2*1) = 0/2 = 0, where it should be NaN
    where arg.denom = 0 and arg.numer = 1, returning a RatNum 0/self.denom, instead of NaN
 However, in mul and add, the computation logic preserves the denom as 0, and hence there is no need for a check for NaN
 
 
 Question 2(b)
 ========
 
 ValueOf is a class method as it is usually needed externally to return a RatNum with a String, which is used as a coeffecient in all rational terms. If a RatNum has to be declared each time when a coeffeicient is assigned to a RatTerm, it would lead wastage of some memory temporarily. Hence this inturn comes of extensive use while defining a polynomial, as in each instance of the RatTerm, we dont want to create a RatNum coefficient with some random value and then modify it (as self should be immutable)
 The purpose that valueOf solves can also be done with an initializer here. A RatNum can be initialized with a valid string of ratTerm and the contructor would assign the values internally
    + (RatNum* )initWithString: (NSString* str)
 
 
 Question 2(c)
 ========
 
 InitWithNumber would have to be changed to remove the part where it calls GCD and divides the Num and Denom with it.
 The CheckRep would no longer check for simplest form of the RatNum
 The stringValue function would have to be modified to now calculate the lowest form of the RatNum by using the GCD function. However, this does reduce certain amount of efficiency, as earlier, the RatNum was already in reduced form but now needs to be called each time to print the reduced value.
 Also, the isEqual function would have to first bring them in the lowest form and then check whether the num and denom of both the given RatNum are equal
 Hence,the need for GCD function is still present, and now needs to be called in two functions (isEqual and stringValue) to give the correct representations. Earlier, it was only used in the constructor initWithNumber which ensured every RatNum object is in the lowest form. This reduces the overall code clarity, as the objects would not be stored in the lowest form and would be temporarily converted each time isEqual is called.
 In terms of execution efficiency, now the GCD function might not be called so often, and will only be used to check for equal objects or while retrieving the stringvalue. Hence the initializing of each RatNum object becomes more straight-forward, but can lead to inefficiency in stringValue.
 
 Question 2(d)
 ========
 
 CheckRep was only added at the end of the initializing constructors:
    initWithNumber and initWithInteger
 Since a ratNum object can only be assigned by called the initializer, the initializers check if a valid object a created (After creating the object). There is no need to check the object in other functions like add, sub etc as the added object is eventually created by using the constructors. Since the RatNum properties are read-only, the other functions can't modify its properties.
 
 
 Question 3(a)
 ========
 
 CheckRep was added at the end of the initializing constructors: 
    initWithCoefficient 
 All the other initializers use this initializer to assign an object. As the only way to assign the properties of the immutable RatTerm object is through the constructors, every object created goes through checkrep (to check whether the created object is valid). As it is the case with RatNum, the RatTerm properties cannot be modified externally as the properties are read-only.
 
 Question 3(b)
 ========
 
 First, the checkrep would have to be changed to no longer throw an exception if the exponent is not 0 when the coeff is zero.
 The initWithCoeff: will have to be changed as it currently implicitly assigns the exponent to 0 (when the coeff = 0), where now it should just assign the zero coeff's exponent as the arguement e.
 The isEqual function would now have to be modified for zero objects. It checks whether the coeff and expt of both the objects are same. Now, if the terms are zero, their exponents can be different and hence it should only compare the coeff when they are zero
     For ex, currently the logic is [self.coeff isEqual: rt.coeff] && (self.expt == rt.expt);
     Now, only the coeffs should be checked for zero terms

 According to the current implementation of isZero, it just checks for the coeff and hence doesn't need to be changed. Consequently, the stringVal does not need to be modified as it calls the isZero function to return "0" NSString
 
 Overall, there are not many changes that would have to be made to accommodate the new representation variant as the isZero is still the same and hence the implementation of functions like add, sub dont have to be modified. This doesn't reduce any code complexity or create any complexity. A further check needs to be made in isEqual to check for zero objects.
 In terms of code clarity, keeping the exponent of zero terms 0, maintains a standard and ensures that all zero RatTerms would be exactly the same.
 
 Question 3(c)
 ========
 
 First, the checkrep would have to be changed to throw an exception if the exponent is not 0 when the coeff is NaN.
 The initWithCoeff: will have to be changed as it currently only checks for zero coeff and assigns exponent as 0. Now, it should do the same of NaN coefficients, explicitly assigning their exponents as 0.
 The add (& sub), mul and div would still not have to be changed, as when they call the initializer to assign a RatTerm with Nan coefficient, the initializer would itself assign the exponent as 0.
 In isEqual, now that the exponents of all Nan terms will be zero, it wont have to explicitly check for Nan coefficients and return YES. The existing log of [self.coeff isEqual: rt.coeff] && (self.expt == rt.expt) can be used
 Hence, there is not much change invloved to implement this, and the overall efficiency might not be improved to a great extent. However, the code-clarity would improve as it would maintain a standard for all Nan terms, as their exponent would be zero
 
 
 Question 3(d)
 ========
 
 I would prefer to keep (A) as the representation variant, as intuitively, a 0 coefficient term should not have an 'X' term. It maintains overall code clarity, as mathematically, all 0 objects should be the same. Accoding to current implementation of mul and div, if the 0 RatTerm had a non-zero exponent, the exponent might change during mul and div operations, which should not happen.
    Although the initializer and checkrep would have smaller code complexity if such a condition is removed, a check would still need to be added in isEqual nonetheless.
 
 Question 5: Reflection (Bonus Question)
 ==========================
 (a) How many hours did you spend on each problem of this problem set?
 
 UI: 30mins
 Problem 1: 1.5hrs
 Problem 2: 1 hr
 Problem 3: 4hrs
 Problem 4: 8hrs (including unit test)
 
 
 (b) In retrospect, what could you have done better to reduce the time you spent solving this problem set?
 
 Certain new concepts were used here, like immutable objects and ther immutable properties.  Rather than directly trying to solve and fill up the code, I should have first read a bit of theory/concepts which would have made my debugging easier. 
 
 (c) What could the CS3217 teaching staff have done better to improve your learning experience in this problem set?
 
 There were certain concepts taught in lecture on Friday which turned out to be quite useful for this assignment. I made some changes accordingly. Also, after recieving the feedback for PS01 on thursday, I made changes to ps02 code. If I already knew these things before hand, it could've saved some time. However, these are minor things, and overall this assignment went without much confusion.
 
 */
