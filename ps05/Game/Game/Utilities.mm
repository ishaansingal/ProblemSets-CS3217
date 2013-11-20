#import "Utilities.h"
@implementation Utilities
+ (NSArray*)getAnimationImages:(NSString*)imageName ColumnNum:(int)numOfColumns RowNum:(int)numOfRows  {
    UIImage *wolfsImage = [UIImage imageNamed:imageName];
    CGSize imageSize = wolfsImage.size;
    CGFloat widthEachImage = imageSize.width/numOfColumns;
    CGFloat heightEachImage = imageSize.height/numOfRows;
    NSMutableArray *allImages = [NSMutableArray array];
    CGImageRef imageRef = [[UIImage imageNamed:imageName]CGImage];
    
    for (int i = 0; i < numOfRows * numOfColumns; i++) {
        CGFloat originX = widthEachImage * (i % numOfColumns);
        CGFloat originY = heightEachImage * (i / numOfColumns);
        
        CGRect currentImageBox = CGRectMake(originX, originY, widthEachImage, heightEachImage);
        
        UIImage *currentFrame = [UIImage imageWithCGImage:
                                 CGImageCreateWithImageInRect(imageRef,  currentImageBox)];
        
        [allImages addObject:currentFrame];
    }
    return allImages;
}

@end
