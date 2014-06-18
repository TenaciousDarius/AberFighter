//
//  Ship.m
//  AberFighter
//
//  Created by wde7 on 06/01/2011.
//  Copyright 2011 William Darius Elphick. All rights reserved.
//

#import "Ship.h"

@implementation Ship

/*
 Creates the getter and setter methods needed by the variables automatically based 
 on the properties defined in the header file.
 */
@synthesize maximumShieldStrength;
@synthesize currentShieldStrength;
@synthesize currentHeading;
@synthesize speed;

/*
 Decrements currentShieldStrength. Returns a boolean 
 indicating if currentShieldStrength is less than or equal to 0
 i.e. the ship is destroyed/disabled.
 */
- (BOOL)reduceShieldStrength {

	currentShieldStrength--;
	
	if (currentShieldStrength <= 0) {
		return YES;
	} else {
		return NO;
	}

}

/*
 Uses trigonometric functions to calculate the new position of the ship based on it's
 heading and the distance it needs to travel. The distance is the speed of the ship
 multiplied by the time since the position was last updated.
 */
- (CGPoint)calculateNewPositionWithHeading:(float)heading distance:(float)distance {
	
	/*
	 Uses the sine and cosine rules to calculate how far along the x and y axes the position
	 of the ship needs to be moved based on the heading and distance which was provided. A
	 cocos2D macro is used to convert the heading from degrees into radians.
	 */
	float radians = CC_DEGREES_TO_RADIANS(heading);
	float xOffset = sin(radians) * distance;
	float yOffset = cos(radians) * distance;
	
	/*
	 The following code adds the offsets calculated above to the current x and y position
	 of the ship and stores the results in temporary variables. 
	 */
	float newXPosition = self.position.x + xOffset;
	float newYPosition = self.position.y + yOffset;
	
	/*
	 A CGPoint is returned located at the new location calculated.
	 */
	return ccp(newXPosition, newYPosition);
	
}

/*
 Setter for the currentHeading variable. Ensures that the currentHeading remains between
 0 and 360 degrees.
 */
- (void) setCurrentHeading:(float)newHeading {
	
	currentHeading = newHeading;
	
	if (currentHeading < 0.0) {
		
		currentHeading = currentHeading + 360.0;
		
	} else if (currentHeading >= 360.0) {
		
		currentHeading = currentHeading - 360.0;
		
	}
	
}

- (void) dealloc {
	
	[super dealloc];
	
}

@end
