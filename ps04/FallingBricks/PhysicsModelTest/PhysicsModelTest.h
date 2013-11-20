//
//  PhysicsModelTest.h
//  PhysicsModelTest
//
//  Created by Ishaan Singal on 12/2/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "PhysicsModel.h"

@interface PhysicsModelTest : SenTestCase <ModelModifyProtocol> {
    PhysicsModel *expectedDel;
}

@end
