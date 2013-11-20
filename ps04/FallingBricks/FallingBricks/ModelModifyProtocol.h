/*
 This protocol provides the interface for didMove/didRotate used by physics model
 and defined by view controller
 */
#import <Foundation/Foundation.h>

@protocol ModelModifyProtocol <NSObject>
- (void)didMove:(id)sender;
- (void)didRotate:(id)sender;
@end
