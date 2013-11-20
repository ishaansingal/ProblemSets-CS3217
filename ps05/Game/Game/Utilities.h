/*
 A utilities class that contains all the common methods used by different classes
 */

#import <Foundation/Foundation.h>

@interface Utilities : NSObject
+ (NSArray*)getAnimationImages:(NSString*)imageName ColumnNum:(int)numOfColumns RowNum:(int)numOfRows;
@end
