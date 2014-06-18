//
//  ReusableTargetPool.h
//  AberFighter
//
//  Created by wde7 on 19/02/2011.
//  Copyright 2011 William Darius Elphick. All rights reserved.
//
/*
 This class implements the Object Pool design pattern. Targets are initialized and 
 added to the pool beforehand to avoid instantiating them while the game 
 is running. Layers can request a TargetShip of a particular type and the pool will return
 a reference as long as an appropriate target instance is available. Once the layer is 
 finished with a target it is expected to return it to the pool so that it can be re-used.
 
 ReusableTargetPool is used as a singleton.
 */

#import <Foundation/Foundation.h>
#import "TargetShip.h"

@interface ReusableTargetPool : NSObject {

}

/*
 ReusableTargetPool is a singleton. This method instantiates the singleton if this hasn't 
 been done previously and returns a reference to it.
 */
+ (ReusableTargetPool *)sharedInstance;
/*
 Returns a TargetShip instance of the specified type if one is available in the pool.
 If an appropriate target is not available then nil is returned.
 */
- (TargetShip *)acquireTargetShipWithType:(TargetType)type;
/*
 This method should be used for returning a TargetShip to the pool for re-use.
 */
- (void)releaseTargetShip:(TargetShip *)target;

@end
