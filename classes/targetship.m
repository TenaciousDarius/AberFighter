//
//  TargetShip.m
//  AberFighter
//
//  Created by wde7 on 16/02/2011.
//  Copyright 2011 William Darius Elphick. All rights reserved.
//

#import "TargetShip.h"

@implementation TargetShip

/*
 Automatically generate setter and getter methods for the properties defined in the header file.
 */
@synthesize scoreAwarded;
@synthesize currentlyInUse;
@synthesize minimumLifetimeExpired;
@synthesize targetType;

/*
 Initializer method. Takes a sprite frame name as a parameter along with the target type and the other
 default values associated with that type. Creates an instance of the class, sets the default values
 for the variables and returns a reference. This method should not be called externally. It is called
 by the initTargetWithType method, which is aware of the default values for each TargetShip type.
 */
- (id)initTargetWithSpriteFrameName:(NSString *)spriteFrameName type:(TargetType)type maximumShieldStrength:(int)maxShieldStrength defaultSpeed:(float)defaultSpeed scoreAwarded:(int)score {
	
	if ((self = [super initWithSpriteFrameName:spriteFrameName])) {
		self.tag = 2;
		targetType = type;
		maximumShieldStrength = maxShieldStrength;
		self.currentShieldStrength = self.maximumShieldStrength;
		self.speed = defaultSpeed;
		scoreAwarded = score;
		self.currentlyInUse = NO;
		minimumLifetimeExpired = NO;
	}
	
	return self;
}


/*
 Public initializer method. It calls the private initializer method above with
 default values related to the TargetType passed in.
 */
- (id)initTargetWithType:(TargetType)type{

	if (type == kTargetShipSmall) {
		
		return [self initTargetWithSpriteFrameName:@"small_target.png" 
											  type:type
							 maximumShieldStrength:1 
									  defaultSpeed:100 
								      scoreAwarded:50];

	} else if (type == kTargetShipLarge) {
		
		return [self initTargetWithSpriteFrameName:@"large_target.png"
											  type:type 
							 maximumShieldStrength:5 
									  defaultSpeed:50 
									  scoreAwarded:200];
		
	}
	
	return nil;
	
}

/*
 This method should be called before a TargetShip instance is added to a layer to
 generate the initial values for heading and position.
 */
- (void)generateRandomStartingPositionAndHeading {
	
	CGSize winSize = [[CCDirector sharedDirector] winSize];
	
	/*
	 A random value between 0 and 3 determines which screen edge the initial position will be next to. 
	 */
	int randomSpawnEdge = arc4random() % 4;
	
	/*
	 The random element of the heading is 0 to 90 degrees. This is used rather than 0 to 180 degrees to
	 avoid ships which travel perpendicular to the screen edge. 
	 */
	int randomHeading = arc4random() % 91; 
	
	float xStartingPosition;
	float yStartingPosition = 0.0f;
	
	/*
	 Rather than use the width or height of the ship, the size intersecting from one corner
	 of the rectangle to the other is used. This ensures that the ship is entirely offscreen.
	 */
	float shipSize = sqrt((pow(self.contentSize.width, 2) + pow(self.contentSize.height, 2)));
	
	/*
	 Depending of which screen edge was chosen earlier, either the y or the x position will be
	 set by the switch statement below. This boolean is used later to identify whcih position 
	 still needs setting.
	 */
	BOOL xPositionDetermined = NO;
	
	float initialHeading = 0.0f;
	
	/*
	 This switch statement sets the values for initialHeading and either xStartingPosition or
	 yStartingPosition based on which screen edge was chosen earlier.
	 */
	switch (randomSpawnEdge) {
		case kLeftEdge:
			xStartingPosition = 0 - (shipSize / 2);
			initialHeading = 45.0 + randomHeading;
			xPositionDetermined = YES;
			break;
		case kUpperEdge:
			yStartingPosition = winSize.height + (shipSize / 2);
			initialHeading = 135.0 + randomHeading;
			break;
		case kRightEdge:
			xStartingPosition = winSize.width + (shipSize / 2);
			initialHeading = 360.0 - (45.0 + randomHeading);
			xPositionDetermined = YES;
			break;
		case kLowerEdge:
			yStartingPosition = 0 - (shipSize / 2);
			initialHeading = 45.0 - randomHeading;
			break;
		default:
			break;
	}
	
	/*
	 randomStartingPosition is the position along the screen edge chosen where the
	 TargetShip will be placed. It is between 1/4 and 3/4 of the way across the edge.
	 */
	int randomStartingPosition;
	
	if (xPositionDetermined == YES) {
		
		int yAxisMiddle = (int)(winSize.height / 2);
		randomStartingPosition = arc4random() % yAxisMiddle;
		yStartingPosition = (winSize.height / 4) + randomStartingPosition;
		
	} else {
		
		int xAxisMiddle = (int)(winSize.width / 2);
		randomStartingPosition = arc4random() % xAxisMiddle;
		xStartingPosition = (winSize.width / 4) + randomStartingPosition;
		
	}
	
	/*
	 The position is created from the values calculated earlier and this plus the initial heading are passed to
	 the spawnWithHeadingStartingPosition method below.
	 */
	CGPoint position = ccp(xStartingPosition, yStartingPosition);
	
	[self spawnWithHeading:initialHeading startingPosition:position];
	
}

/*
 This method sets the initial starting position, heading and rotation of the ship and schedules a callback to
 update the minimum lifetime expired boolean after 2 seconds, which is enough time for the ship to travel onto 
 the screen.
 */
- (void)spawnWithHeading:(float)heading startingPosition:(CGPoint)startingPosition {
	
	/*
	 The new position and rotation are applied to the ship.
	 */
	self.position = startingPosition;
	self.currentHeading = heading;
	self.rotation = heading;
	
	/*
	 The updateMinimumLifeTimeExpired method is scheduled to run after a short time which 
	 guarentees that the TargetShip is now on-screen.
	 */
	[self schedule:@selector(updateMinimumLifetimeExpired:) interval:2.0f];
}

/*
 Called by the scheduler a short period after a TargetShip starts moving. Sets
 minimumLifetimeExpired to true, meaning it is now ok to release the ship when
 it is offscreen.
 */
- (void)updateMinimumLifetimeExpired:(ccTime)timeSinceLastUpdate {
	
	//Prevent this method from being called again.
	[self unschedule:@selector(updateMinimumLifetimeExpired:)];
	minimumLifetimeExpired = YES;
	
}

/*
 Uses the calculateNewPositionWithHeading method in the Ship superclass to find the new position of the ship. 
 timeSinceLastUpdate is applied to the speed to get distance because the framerate is not guaranteed to be constant
 and therefore this helps to smooth the motion of the ship. Rotation is then set to current heading so that 
 the image rotates to point in the right direction.
 
 At the moment no A.I. has been applied to the different target ships, they mearly travel in a straight line at a 
 constant speed. However if A.I. was to be introduced in the future to change the heading and the speed of the
 ship, say in response to the player's current position, then extra functionality could be added in this method.
 The Strategy design pattern would fit well, since it would be possible to set the behaviour of the target ship during
 initialisation and then call a method on the Behaviour class which returns the changes to currentHeading and speed 
 before updating the position and rotation.
 */
- (void)updatePosition:(ccTime)timeSinceLastUpdate {

	self.position = [super calculateNewPositionWithHeading:currentHeading 
												  distance:(speed * timeSinceLastUpdate)];
	self.rotation = currentHeading;
	
}

/*
 Returns a boolean indicating whether the TargetShip is offscreen.
 */
- (BOOL)checkIfOffscreen {
	
	CGSize winSize = [[CCDirector sharedDirector] winSize];
	
	float shipSize = sqrt((pow(self.contentSize.width, 2) + pow(self.contentSize.height, 2))) / 2;
	
	CGPoint currentPosition = self.position;
	
	if ((currentPosition.x < (0 - shipSize)) ||
		(currentPosition.x > (winSize.width + shipSize)) ||
		(currentPosition.y < (0 - shipSize)) ||
		(currentPosition.y > (winSize.height + shipSize))) {
		return YES;
	} 
	
	return NO;
	
}

/*
 Resets the default values for currentHeading, rotation, position, 
 currentShieldStrength and minimumLifetimeExpired. All method callbacks which
 have been scheduled are also removed.
 */
- (void)resetVariables {

	[self unscheduleAllSelectors];
	self.currentHeading = 0.0f;
	self.rotation = currentHeading;
	self.position = ccp(-50, -50);
	self.currentShieldStrength = maximumShieldStrength;
	minimumLifetimeExpired = NO;
	
}

@end
