//
//  ReusableTargetPool.m
//  AberFighter
//
//  Created by wde7 on 19/02/2011.
//  Copyright 2011 William Darius Elphick. All rights reserved.
//

#import "ReusableTargetPool.h"

@implementation ReusableTargetPool

/*
 The reusableTargetShips array stores the TargetShip instances which are in the pool.
 */
NSMutableArray *reusableTargetShips;
/*
 Singleton of this class.
 */
static ReusableTargetPool *sharedReusableTargetPool = nil; 

//Static Singleton accessor.
+ (ReusableTargetPool *)sharedInstance {
	
	if (!sharedReusableTargetPool) {
		sharedReusableTargetPool = [[ReusableTargetPool alloc] init];
	}
	
	return sharedReusableTargetPool;
	
}

/*
 Initializer method. Creates an instance of this class, populates the Object Pool by instantiating
 TargetShip objects and returns a reference to the class.
 */
- (id)init {
	
	if ((self = [super init])) {
		
		/*
		 The initial size of the Object Pool. 20 TargetShips is sufficient because in the
		 current application the action is confined to the size of the screen. 
		 */
		int initialPoolSize = 20;
		
		/*
		 Create and retain an array to store the TargetShip instances. 
		 */
		reusableTargetShips = [[[NSMutableArray alloc] initWithCapacity:initialPoolSize] retain];
		
		/*
		 Currently the ratio of small target ships to large target ships is 3/1. This can be changed
		 to add new ships to the pool on initialization in the future.
		 */
		float shipTypeRatio = initialPoolSize / 4;
		
		TargetShip *newTargetShip = nil;
		
		/*
		 Create the required amount of TargetShips of type small.
		 */
		for (int i = 0; i < (shipTypeRatio * 3); i++) {
			
			newTargetShip = [[TargetShip alloc] initTargetWithType:kTargetShipSmall];
			[reusableTargetShips addObject:newTargetShip];
			[newTargetShip release];
			
		}
		
		/*
		 Create the required amount of TargetShips of type large.
		 */
		for (int i = 0; i < shipTypeRatio; i++) {
			
			newTargetShip = [[TargetShip alloc] initTargetWithType:kTargetShipLarge];
			[reusableTargetShips addObject:newTargetShip];
			[newTargetShip release];
			
		}
		
	}
	
	return self;
	
}

/*
 Returns a reference to a TargetShip of the specified type. Will return nil if no 
 suitable TargetShip instances are available.
 */
- (TargetShip *)acquireTargetShipWithType:(TargetType)type {
	
	TargetShip *instance;
	
	/*
	 Access to the reusableTargetShips array (i.e. the object pool) is synchronized to
	 ensure that only one thread can access it at a time. This avoids data inconsistency 
	 in the situation that TargetShip instances are requested in this method while
	 simultaneously being released in the releaseTargetShip method by another thread.	 
	 */
	@synchronized (reusableTargetShips) {
		/*
		 Enumerate over the object pool. If an instance of the required type is found which is
		 not in use (indicated by the currentlyInUse variable in the TargetShip class), mark it
		 as in use and return a reference to it.
		 */
		NSEnumerator *enumerator = [reusableTargetShips objectEnumerator];
		while ((instance = (TargetShip *)[enumerator nextObject])) {
			
			if ((instance.targetType == type) && (!instance.currentlyInUse)) {
				instance.currentlyInUse = YES;
				return instance;
			}
			
		}
	}
	
	/*
	 If the method reaches this point, no TargetShip was found. Therefore return nil.
	 */
	return nil;
	
}

/*
 Finds the TargetShip instance referred to in the parameter in the object pool, resets
 it's variables and marks it as available.
 */
- (void)releaseTargetShip:(TargetShip *)target {
	
	TargetShip *instance;
	
	/*
	 Access to the reusableTargetShips array (i.e. the object pool) is synchronized to
	 ensure that only one thread can access it at a time.	 
	 */
	@synchronized (reusableTargetShips) {
		
		/*
		 Enumerate over the object pool. When the TargetShip instance referred to in the 
		 parameter is found, call the TargetShip resetVariables method which restores the 
		 initial state of the target and then set currentlyInUse to false, which makes the 
		 instance available to the acquireTargetShipWithType method. 
		 */
		NSEnumerator *enumerator = [reusableTargetShips objectEnumerator];
		while ((instance = (TargetShip *)[enumerator nextObject])) {
			if ([instance isEqual:target]) {
			
				[instance resetVariables];
				instance.currentlyInUse = NO;
				
			}
			
		}
	}
	
}

/*
 The dealloc method is only called when the application is terminated. It calls release on the reusableTargetShips array
 which recursively calls release on the TargetShip instances within it.
 */
- (void)dealloc {
	
	[reusableTargetShips release];
	reusableTargetShips = nil;
	sharedReusableTargetPool = nil;
	[super dealloc];
	
}

@end
