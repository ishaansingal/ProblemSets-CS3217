/*
 GameModel stores the state of a single game object in the game.
It contains all the relevant details such as size of the object, origin, rotation
scale, its currentstate (in gamearea or in palette)
It also sends delegates to the controller whenever its state attributes are
modified (origin, rotation, scale)
*/

#import <Foundation/Foundation.h>
#import "ModelModifyDelegate.h"
#import "Constants.h"

@interface GameModel : NSObject
@property(readonly) CGSize imageSize;
@property(readonly) CGPoint imageOrigin;
@property(readonly) CGFloat rotation;
@property(readonly) CGFloat imageScale;
@property(readonly) GameObjectState currentState;
@property(readonly) CGPoint center;
@property(weak, readonly) id<ModelModifyDelegate> modelDelegate;

- (id)initWithSize:(CGSize)size Origin:(CGPoint)origin State:(int)state;
- (id)initWithSize:(CGSize)size Origin:(CGPoint)origin Rotation:(CGFloat)r State:(int)state;
- (void)setSize:(CGSize)size;
- (void)setOrigin:(CGPoint)origin;
- (void)scale:(CGFloat)scale;
- (void)rotate:(CGFloat)rotation;
- (CGRect)dimensions;
- (void)setSizeFromScale;
- (void)setGameState:(GameObjectState) state;
- (void)translateByPoint:(CGPoint)translation;
- (void)setDelegate:(id)sender;
- (id)initWithCoder:(NSCoder *)decoder;
- (void)encodeWithCoder:(NSCoder *)encoder;


@end
