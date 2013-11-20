//
//  PERectangle.m
//
//  CS3217 || Assignment 1
//  Name: Ishaan Singal
//

#import "PERectangle.h"


@interface PERectangle ()
//convert the readonly to readwrite
@property (nonatomic, readwrite) CGFloat width;
@property (nonatomic, readwrite) CGFloat height;
@property (nonatomic, readwrite) CGPoint* corners;

@end

@implementation PERectangle
// OVERVIEW: This class implements a rectangle and the associated
//             operations.
- (CGPoint)center {
    // EFFECTS: returns the coordinates of the centre of mass for this
    // rectangle.
    CGPoint center;
    center.x=self.origin.x+self.width/2;
    center.y=self.origin.y-self.height/2;
    return center;
}

- (CGPoint)cornerFrom:(CornerType)corner {
    // REQUIRES: corner is a enum constant defined in PEShape.h as follows:
    //           kTopLeftCorner, kTopRightCorner, kBottomLeftCorner,
    //		   kBottomRightCorner
    // EFFECTS: returns the coordinates of the specified rotated rectangle corner after rotating
    
    CGPoint centerMass = self.center;
    CGFloat phase = 0;
    CGPoint tempRotatedCorner;
    CGPoint nonRotatedCorner;
    switch (corner) {
        case kTopLeftCorner:
            nonRotatedCorner = self.origin;
            phase += M_PI; //add the phase of 180 degress as the vector is in 2nd quadrant
            break;
        case kTopRightCorner:
            nonRotatedCorner.x = self.origin.x+self.width;
            nonRotatedCorner.y = self.origin.y;
            break;
        case kBottomRightCorner:
            nonRotatedCorner.x = self.origin.x+self.width;
            nonRotatedCorner.y = self.origin.y-self.height;
            break;
        case kBottomLeftCorner:
            nonRotatedCorner.x = self.origin.x;
            nonRotatedCorner.y = self.origin.y- self.height;
            phase += M_PI; //add the phase of 180 degress as the vector is in 3rd quadrant (trignometric rules)
            break;
        default:
            break;
    }
    
    CGFloat radiusX = nonRotatedCorner.x-centerMass.x;
    CGFloat radiusY = nonRotatedCorner.y-centerMass.y;
    CGFloat radius = sqrt((radiusX)*(radiusX) + (radiusY)*(radiusY)); //get the radius (the distance between corner and center)
    phase += atan(radiusY/radiusX);
    tempRotatedCorner.x=centerMass.x+radius*cos(M_PI*self.rotation/180+phase); //the rotated corner with relation with centre mass
    tempRotatedCorner.y=centerMass.y+radius*sin(M_PI*self.rotation/180+phase);
    
    return tempRotatedCorner;
}

- (CGPoint*)corners {
    // EFFECTS:  return an array with all the rectangle corners
    
    CGPoint *corners = (CGPoint*) malloc(4*sizeof(CGPoint));
    corners[0] = [self cornerFrom: kTopLeftCorner];
    corners[1] = [self cornerFrom: kTopRightCorner];
    corners[2] = [self cornerFrom: kBottomRightCorner];
    corners[3] = [self cornerFrom: kBottomLeftCorner];
    return corners;
}

- (id)initWithOrigin:(CGPoint)o width:(CGFloat)w height:(CGFloat)h rotation:(CGFloat)r{
    // MODIFIES: self
    // EFFECTS: initializes the state of this rectangle with origin, width,
    //          height, and rotation angle in degrees
    self = [super init];
    if (self) {
        _origin=o;
        _width=w;
        _height=h;
        _rotation=r;
    }
    return self;
}

- (id)initWithRect:(CGRect)rect {
    // MODIFIES: self
    // EFFECTS: initializes the state of this rectangle using a CGRect
    return [self initWithOrigin:rect.origin width:rect.size.width height:rect.size.height rotation:0];
}

- (void)rotate:(CGFloat)angle {
    // MODIFIES: self
    // EFFECTS: rotates this shape anti-clockwise by the specified angle
    // around the center of mass
    
    self.rotation += angle;
}

- (void)translateX:(CGFloat)dx Y:(CGFloat)dy {
    // MODIFIES: self
    // EFFECTS: translates this shape by the specified dx (along the
    //            X-axis) and dy coordinates (along the Y-axis)
    _origin.x = self.origin.x + dx;
    _origin.y = self.origin.y + dy;
    return;
}

- (BOOL)overlapsWithShape:(id<PEShape>)shape {
    // EFFECTS: returns YES if this shape overlaps with specified shape.
    
    if ([shape class] == [PERectangle class]) {
        return [self overlapsWithRect:(PERectangle *)shape];
    }
    
    return NO;
}

-(CGFloat) scalarProductAxis:(CGPoint)axis Corner:(CGPoint)corner{
    //returns the scalar product of the axis and the corner
    CGFloat scalarProduct;
    CGFloat axisMag = sqrt(axis.x*axis.x) + (axis.y*axis.y);
    scalarProduct = (corner.x*axis.x + corner.y*axis.y)/axisMag;
    return scalarProduct;
}

- (BOOL)overlapsWithRect:(PERectangle*)rect {
    // EFFECTS: returns YES if this shape overlaps with specified shape.
    // <add missing code here>
    BOOL result = YES;
    CGPoint* selfCorners = self.corners;
    CGPoint* rectCorners = rect.corners;
    CGPoint axis[4];
    
    //calculates the four axis relative to each of the two rectangles
    for (int i = 0; i<4;i++)
    {
        //two axis from the first rectangle
        if (i<2) {
            axis[i].x= selfCorners[i].x-selfCorners[i+1].x;
            axis[i].y= selfCorners[i].y-selfCorners[i+1].y;
        }
        else{
            axis[i].x= rectCorners[i-2].x-rectCorners[i-1].x;
            axis[i].y= rectCorners[i-2].y-rectCorners[i-1].y;
        }
    }
    
    //run the whole loop for each axis
    for (int i=0; i<4;i++)
    {
        CGFloat* selfProjectedScalar = (CGFloat*) malloc(4*sizeof(CGFloat));
        CGFloat* rect2ProjectedScalar = (CGFloat*) malloc(4*sizeof(CGFloat));
        //calculate the projection of each corner with the current axis
        for (int j =0; j<4;j++)
        {
            selfProjectedScalar[j] = [self scalarProductAxis:axis[i] Corner:selfCorners[j]];
            rect2ProjectedScalar[j] = [self scalarProductAxis:axis[i] Corner:rectCorners[j]];
        }
        //calculate the max and min projections of each rectangle with the given axis
        CGFloat minScalarSelf = [self minValInArray:selfProjectedScalar Size:4];
        CGFloat maxScalarSelf = [self maxValInArray:selfProjectedScalar Size:4];
        
        CGFloat minScalarRect2 = [self minValInArray:rect2ProjectedScalar Size:4];
        CGFloat maxScalarRect2 = [self maxValInArray:rect2ProjectedScalar Size:4];
        
        //if a gap is found between the projections of the two rectangles, they straightaway dont overlap
        if (maxScalarRect2<minScalarSelf || maxScalarSelf< minScalarRect2)
        {
            result= NO;
            break;
        }
    }
    return result;
}

- (CGFloat)minValInArray:(CGFloat*)arr Size:(int)arrSize{
    //returns the min value in the array
    
    CGFloat minVal = arr[0];
    for (int i =1;i<arrSize;i++)
    {
        CGFloat curVal = arr[i];
        if (curVal< minVal)
            minVal = curVal;
    }
    return minVal;
}

- (CGFloat)maxValInArray:(CGFloat*)arr Size:(int)arrSize{
    //returns the max value in the array
    CGFloat maxVal = arr[0];
    for (int i =1;i<arrSize;i++)
    {
        CGFloat curVal = arr[i];
        if (curVal> maxVal)
            maxVal = curVal;
    }
    return maxVal;
}

- (CGRect)boundingBox {
    // EFFECTS: returns the bounding box of this shape.
    CGPoint newOrigin; //the origin the minX and maxY value of the bounded box
    CGFloat newWidth, newHeight; //
    CGFloat Xarr[4], Yarr[4];
    CGPoint* currentCorners = self.corners;
    for (int i =0;i<4;i++)
    {
        Xarr[i]=currentCorners[i].x;
        Yarr[i]=currentCorners[i].y;
    }
    newOrigin.x= [self minValInArray:Xarr Size:4];
    newOrigin.y= [self maxValInArray:Yarr Size:4];
    newWidth = [self maxValInArray:Xarr Size:4] - newOrigin.x;
    newHeight = newOrigin.y - [self minValInArray:Yarr Size:4];
    // optional implementation (not graded)
    return CGRectMake(newOrigin.x, newOrigin.y, newWidth, newHeight);
}

@end

