/*
 The delegate class implemented by the controllers. 
 The delegates here are sent by the Model to the controllers
 */

#import <Foundation/Foundation.h>

@protocol ModelModifyDelegate <NSObject>
@optional
- (void)didTranslate;
- (void)didRotate;
- (void)didScale:(CGFloat)ScaleChange;
- (void)didTranslateBlock:(int)Id;
- (void)didRotateBlock:(int)Id;
- (void)didScaleBlock:(int)Id ScaleChange:(CGFloat)scaleCh;
@end
