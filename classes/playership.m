//
//  PlayerShip.m
//  AberFighter
//
//  Created by wde7 on 06/01/2011.
//  Copyright 2011 William Darius Elphick. All rights reserved.
//

#import "PlayerShip.h"
#import "MultilayerGameScene.h"

@implementation PlayerShip

/*
 Create getter and setter methods automatically based on the properties defined in the header file.
 */
@synthesize shipDisabled;
@synthesize invincible;
@synthesize maximumSpeed;
@synthesize playerID;

/*
 Initializer method. Creates a default PlayerShip instance which has no position or rotation set.
 This is because the parent layer decides where the ship is initially. The default playerID is 0. 
 This is also updated by the parent layer.
 */
- (id)init {
	
	if ((self = [super init])) {
		maximumShieldStrength = kDefaultMaximumShieldStrength;
		self.currentShieldStrength = self.maximumShieldStrength;
		self.maximumSpeed = kDefaultMaximumSpeed;
		self.speed = 0.0f;
		shipDisabled = NO;
		invincible = NO;
		self.playerID = 0;
	}
	
	return self;
	
}

/*
 Called from reduceShieldStrength when currentShieldStrength reaches 0. Sets shipDisabled and invincible to true 
 and stops the ship. Then schedules to re-activate the ship after a short period of time. 
 */
- (void)disableShip {
	
	[self stopAllActions];
	shipDisabled = YES;
	invincible = YES;
	self.speed = 0.0f;	
	[self schedule:@selector(reactivateShip:) interval:kShipRepairTime];
	
}

/*
 Called by the scheduler a short period of time after the ship has been disabled. Re-activates the ship.
 */
- (void)reactivateShip:(ccTime)timeSinceLastCall {
	
	//Stops this method from being called recursively.
	[self unschedule:@selector(reactivateShip:)];
	
	//Recharges the shields of the player. The PlayerShip is still invincible at this stage.
	self.currentShieldStrength = maximumShieldStrength;
	
	//Reactivate the ship's ability to move and fire. 
	shipDisabled = NO;
	
	/*
	 Invincibility continues for a short time after the ship has been reactivated. 
	 A method is scheduled to end invincibility after this time. 
	 */
	[self schedule:@selector(endInvincibility:) interval:kShipInvincibleTime];
	
}

/*
 Called by the scheduler a short period of time after the ship has been reactivated. Sets the invincible
 variable back to false.
 */
- (void)endInvincibility:(ccTime)timeSinceLastCall {

	//Stops this method from being called recursively.
	[self unschedule:@selector(endInvincibility:)];
	
	//Make the ship vulnerable to damage again.
	invincible = NO;
	
}

/*
 Overrides the default reduceShieldStrength method located in the Ship class. In addition to reducing the
 current shield strength and returning true or false it also calls disableShip when currentShieldStrength
 reaches 0.
 */
- (BOOL)reduceShieldStrength {

	/*
	 Shield strength is not decremented if the ship is invincible.
	 */
	if (!self.invincible) {
		
		self.currentShieldStrength--;
		
		if (self.currentShieldStrength <= 0) {
			[self disableShip];
			return YES;
		} else {
			return NO;
		}
		
	} else {
		
		return NO;
		
	}
	
}

/*
 This method extends the functionality of the method with the same name in the Ship superclass. 
 It takes border checking into account to ensure the player isn't able to fly offscreen.
 */
- (CGPoint)calculateNewPositionWithHeading:(float)heading distance:(float)distance {
	
	/*
	 Use the method located in the superclass to retrieve the newPosition of the ship. 
	 */
	CGPoint newPosition = [super calculateNewPositionWithHeading:heading distance:distance];
	
	/*
	 Use the window size attained from the director to ensure that the ship
	 doesn't pass off the screen edge. If the ship is touching the edge it is prevented from going 
	 any further. 
	 */
	CGSize winSize = [[CCDirector sharedDirector] winSize];
	
	/*
	 Because the position of the ship represents the middle of the image we need to divide the image's
	 size by two to find the distance from the position point to the edge of the ship.
	 */
	float shipHeight = self.contentSize.height / 2.0f;
	float shipWidth = self.contentSize.width / 2.0f;
	
	if(newPosition.x > (winSize.width - shipWidth)) {
		
		newPosition.x = winSize.width - shipWidth; 
		
	} else if (newPosition.x < (0 + shipWidth)) {
		
		newPosition.x = 0 + shipWidth;
		
	}
	
	/*
	 The HUD takes up a small position of the top of the screen.
	 Therefore the public constant kHUD_Y_POSITION available in
	 the MultilayerGameScene class is used to work out the upper boundary.
	 */
	float hudYPosition = winSize.height - (kHUD_Y_POSITION * 2);
	
	if(newPosition.y > (hudYPosition - shipHeight)) {
		
		newPosition.y = (hudYPosition - shipHeight); 
		
	} else if (newPosition.y < (0 + shipHeight)) {
		
		newPosition.y = 0 + shipHeight;
		
	}
	
	/*
	 A CGPoint is returned located at the new location calculated.
	 */
	return newPosition;
	
}

/*
 Uses the calculateNewPositionWithHeading method above to find the new position of the ship. currentHeading and
 speed are updated by the applyDirectionalChanges method below which is called seperately by the control method used.
 timeSinceLastUpdate is applied to the speed to get distance because the framerate is not guaranteed to be constant
 and therefore this helps to smooth the motion of the ship. Rotation is then set to current heading so that 
 the image rotates to point in the right direction.
 */
- (void) updatePosition:(ccTime)timeSinceLastUpdate {
	
	/*
	 Position and rotation are only updated if the ship is not disabled.
	 */
	if (!self.shipDisabled) {
		self.position = [self calculateNewPositionWithHeading:currentHeading 
													 distance:(speed * timeSinceLastUpdate)];
		self.rotation = currentHeading;
	}
	
}

/*
 Called to apply DirectionalChanges received from the input method and calculated by a
 static method within the DirectionalChangesCalculator class to the ship.
 */
- (void) applyDirectionalChangesWithNewHeading:(float)newHeading newSpeed:(float)newSpeed  {
	
	/*
	 This block of code applies heading and speed changes to the ship. These values are only applied if the 
	 ship is not disabled.
	 */
	if (!self.shipDisabled) {	
		[self setSpeed:newSpeed];
		[self setCurrentHeading:newHeading];
	}
	
}

/*
 Setter for the speed variable. Ensures that speed can't be less than 0 or more than the maximum speed of the ship.
 */
- (void) setSpeed:(float)newSpeed {
	
	speed = newSpeed;
	
	if (speed < 0) {
		
		speed = 0;		
		
	} else if (speed > maximumSpeed) {
		
		speed = maximumSpeed;
		
	}
	
}

- (void) dealloc {

	[super dealloc];
	
}

@end
