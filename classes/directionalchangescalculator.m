//
//  DirectionalChangesCalculator.m
//  AberFighter
//
//  Created by wde7 on 07/01/2011.
//  Copyright 2011 William Darius Elphick. All rights reserved.
//


#import "DirectionalChangesCalculator.h"
#import "GameState.h"
#import "cocos2d.h"

@implementation DirectionalChangesCalculator

#pragma mark -
#pragma mark Accelerometer Control Method 1

/*
 kVelocityMultiplier is used to increase the distance travelled by the ship at each step
 because the values returned by the accelerometer are very small and therefore applying these
 directly to the ship would cause the ship to move very slowly regardless of the current orientation.
 */
#define kVelocityMultiplier							600
/*
 kAccelerationThreshold can be used to define a neutral position within which the ship stays still.
 Only when accelerometer values are greater than this threshold does the ship move. Not used currently 
 because it isn't needed but added in case of need in the future.
 */
#define kAccelerationThreshold						0
/*
 A low-pass filter is used to smooth the data being returned by the accelerometer, since the values can
 vary significantly from one delegate call to the next. By using the filter major changes in the accelerometer
 data do not skew the direction of the ship significantly unless they are consistently received over multiple
 delegate calls. This value determines the proportion of the current and previous accelerometer values which are
 used to calculate the current trend of accelerometer data.
 */
#define kAccelerometerLowPassFilter					0.05

/*
 These static variables store the acceleration values which were calculated by the low-pass filter the last time
 calculateDirectionalChangesWithAcceleration was called.
 */
static double previousXAcceleration=0; 
static double previousYAcceleration=0;

/*
 Accelerometer Control Method 1. See header file for description.
 */
+ (DirectionalChanges *)calculateDirectionalChangesWithAcceleration:(UIAcceleration *)currentAcceleration {
	
	DirectionalChanges *directionalChanges = [[DirectionalChanges alloc] init];
	
	/*
	 Calibrated position is used so that calculations on the x accelerometer axis can be treated
	 relative to the player's comfortable playing angle. 
	 */
	double calibratedPosition = [[GameState sharedState] calibratedPosition];
	
	/*
	 The following code implements a low-pass filter on the accelerometer data to smooth out the values
	 returned and ignore significant but short-term fluctuations in values. Depending on the proportion
	 specified in kAccelerometerLowPassFilter, a small amount of the new values replaces the
	 same proportion of the previous filtered values. In this way values returned by the filter are only changed 
	 when there is a consistent change in accelerometer values. 
	 */
	double xAcceleration = (currentAcceleration.x * kAccelerometerLowPassFilter) + 
							((1 - kAccelerometerLowPassFilter)*previousXAcceleration);
	double yAcceleration = (currentAcceleration.y * kAccelerometerLowPassFilter) + 
							((1 - kAccelerometerLowPassFilter)*previousYAcceleration);
	
	/*
	 The new filtered accelerometer values are stored for use in the next iteration.
	 */
	previousXAcceleration = xAcceleration;
	previousYAcceleration = yAcceleration;
	
	/*
	 The filtered acceleration values are used as the velocity the ship has along the x and y axes.
	 The reason for xAcceleration being applied to the viewYVelocity and yAcceleration to the viewXVelocity 
	 is that the axes of the accelerometer and the axes of the view are different. 
	 
	 In this game the device is held in landscape left position, with the home button to the right of the screen. 
	 In this situation, the accelerometer axes are orientated such that y increases moving right to left across 
	 the front of the device and x increases moving up the front of the device. The view's coordinate system, as 
	 dictated by OpenGL ES, is orientated such that x increases moving left to right across the front of the device 
	 and y increases moving down the front of the device.
	 
	 The calibrated position is subtracted from the xAcceleration value so that the player can play relative
	 to a comfortable playing angle.
	 
	 yAcceleration is negated because the y axes of the view and the x axis of the accelerometer increase in the opposite 
	 direction. For example to move up the screen, the x value on the accelerometer increases. However the y axis of the view
	 decreases when moving up the screen, hence the negation.
	 */
	float viewYVelocity = xAcceleration - calibratedPosition;
	float viewXVelocity = -(yAcceleration);
	
	/*
	 The kAccelerationThreshold can be used to prevent the ship from moving when the device isn't significantly
	 tilted. Not currently used, as the threshold is set to 0.
	 */
	if (fabs(viewYVelocity) > kAccelerationThreshold || fabs(viewXVelocity) > kAccelerationThreshold) {
		
		/*
		 The travelling direction of the ship can be treated as a right-angled triangle with the hypotenuse
		 representing the distance travelled and the opposite and adjacent sides representing the offset 
		 in the x and y axes to move from point a to point b. By following this model we can use triogonometric 
		 functions to determine the distance travelled and the heading of the ship.
		 
		 We know the length of the opposite and adjacent sides from the velocities calculated earlier. Therefore
		 we can use the pythagoras theorem to determine the length of the hypotenuse and therefore the distance 
		 the ship should travel during every iteration. The velocity multiplier, as described above, is used to create
		 a significant change in position over time since the values returned by the accelerometer are very small.
		 */
		float speed = kVelocityMultiplier * sqrt((pow(viewYVelocity, 2) + pow(viewXVelocity, 2)));
		
		directionalChanges.newSpeed = speed;
		
		/*
		 To determine the new heading of the ship the trigonometric tan rule is used. atan2 returns the angle in radians
		 between the adjacent and hypotenuse of the triangle, relative to a circle with the positive x axis acting as the origin.
		 Positive values indicate a rotation anti-clockwise from the origin and negative values indicate the opposite. 
		 The maximum possible values returned are Pi and -Pi (180 degrees).
		 */
		float radians = atan2(viewYVelocity, viewXVelocity);
		
		/*
		 A cocos2D macro is used to convert the radians value into degrees. 
		 */
		float degrees = CC_RADIANS_TO_DEGREES(radians);
		
		/*
		 The rotation system used by cocos2D uses a value in degrees which represents a 360 degree clockwise circle.
		 The origin, 0 degrees, is located at 12 o clock on the circle. The degrees value calculated from the atan2 function
		 is expressed relative to an origin located at 3 o clock. Therefore the 90 degree difference must be removed.
		 This is done here.
		 */
		if (degrees >= 0) {
			directionalChanges.newHeading = (90 - degrees);
		} else {
			directionalChanges.newHeading = (90 + (-degrees));
		}
		
	}	

	/*
	 The directionalChanges instance is autoreleased here to remove responsibility for deallocating it, 
	 since it is used after being returned to the ActionLayer. 
	 */
	[directionalChanges autorelease];
	
	return directionalChanges;
	
}

#pragma mark -
#pragma mark Accelerometer Control Method 2

/*
 These values are used in the calculateDirectionalChangesWithAcceleration method to
 determine the threshold above which acceleration values affect the ship's speed and
 heading.
 */
#define kAccelerationThresholdForVelocityChange		0.2
#define kAccelerationThresholdForHeadingChange		0.2

/*
 Accelerometer Control Method 2. See header file for description.
 */
+ (DirectionalChanges *)calculateDirectionalChangesWithAcceleration:(UIAcceleration *)currentAcceleration heading:(float)currentHeading speed:(float)currentSpeed{
 
	 DirectionalChanges *directionalChanges = [[DirectionalChanges alloc] init];
 
	 /*
	  calibratedPosition is the x-axis origin which represents the player's preferred playing 
	  angle. The current x acceleration must be significantly different from this in order to
	  affect the speedChange variable.
	  */
	 double calibratedPosition = [GameState sharedState].calibratedPosition;
	 
	 /*
	  The velocity change is the absolute difference between the calibratedPosition
	  and the current acceleration along the x-axis. If this value is greater than a threshold
	  then the speed of the ship is changed.
	  */
	 float velocityChange = fabs(calibratedPosition - currentAcceleration.x);
	 
	 if (velocityChange > kAccelerationThresholdForVelocityChange) {
 
		 /*
		  When current x-axis acceleration is greater than the calibrated position,
		  the device has been tilted forward and therefore the ship should accelerate.
		  Otherwise the device has been tipped backwards and the ship should
		  decelerate.
		  */
		 if (currentAcceleration.x > calibratedPosition) {
	 
			 directionalChanges.newSpeed = currentSpeed + (velocityChange + 1);
	 
		 } else {
	 
			 directionalChanges.newSpeed = currentSpeed - (velocityChange + 1);
	 
		 }
	 
	 } else {
		 
		 directionalChanges.newSpeed = currentSpeed;
		 
	 }
 
	 /*
	  If the acceleration along the y-axis is above a threshold
	  then the acceleration is used as the change in heading of the ship.
	  */
	 if ((currentAcceleration.y < -(kAccelerationThresholdForHeadingChange)) 
		 || (currentAcceleration.y > kAccelerationThresholdForHeadingChange)) {
	 
		 /*
		  Acceleration value is negated because positive values in y-axis acceleration indicate
		  that the top of the device is pointing towards the floor. When the device is held in
		  landscape left orientation (i.e. with the home button on the right side) this would 
		  indicate that the device has been turned anti-clockwise if following a steering wheel paradigm.
		  The heading of the ship is measured in degrees clockwise. Therefore when the acceleration 
		  is positive and there is a need to turn clockwise the heading needs to decrease, hence the negation.
		  The acceleration is multiplied by 10 to produce a useful turning speed.
		  */
		 float turningVelocity = -(currentAcceleration.y) * 10.0f;
		 
		 if (turningVelocity < -4.0) {
			 
			 turningVelocity = -4.0;
			 
		 } else if (turningVelocity > 4.0) {
			 
			 turningVelocity = 4.0;
			 
		 }
		 
		 directionalChanges.newHeading = currentHeading + turningVelocity;		
	 
	} else {
		
		directionalChanges.newHeading = currentHeading;
		
	}

	/*
	 The directionalChanges instance is autoreleased here to remove responsibility for deallocing it, 
	 since it is used after being returned to the ActionLayer. 
	 */
	[directionalChanges autorelease];
	 
	return directionalChanges;
 
}

@end
