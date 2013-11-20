/*
 Subclass of the Box2d abstract class b2ContactListener
 The PostSolve is called during a collision between two objects by the Box2D
 It calls the delegate method of <CollisionDelegate> protocol
 */

#import <Box2D/Box2D.h>
#import "GameModel.h"


//protocol - to notify that a collision between two objects with the respective
//impulse has been made
@protocol CollisionDelegate <NSObject>
@optional
- (void)objectsCollided:(GameModel*)firstObj withObject:(GameModel*)secondObj withImpulse:(CGFloat)impulse;
@end

class MyContactListener : public b2ContactListener {
    id<CollisionDelegate> engineDelegate;
    
public:
    MyContactListener (id<CollisionDelegate> sender) {
        engineDelegate = sender;
    }
    
    //checks if the objects are valid and impulse significant, then calls the delegate method
    void PostSolve(b2Contact* contact, const b2ContactImpulse* impulse) {
        id objectA = (__bridge id) contact->GetFixtureA()->GetBody()->GetUserData();
        id objectB = (__bridge id) contact->GetFixtureB()->GetBody()->GetUserData();
        if (objectA == NULL || objectB == NULL) {
            return;
        }
        
        if ([objectA isKindOfClass:[GameModel class]] && [objectB isKindOfClass:[GameModel class]]) {
            GameModel *firstObject = objectA;
            GameModel *secondObject = objectB;
            CGFloat newImpulse = impulse->normalImpulses[0] + impulse->normalImpulses[0];
            //only call the delegate if the impulse is signifant
            if (newImpulse > 10) {
                [engineDelegate objectsCollided:firstObject withObject:secondObject withImpulse:newImpulse];
            }
            
        }
    }
    
};