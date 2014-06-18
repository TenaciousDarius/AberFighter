//
//  TargetShip.h
//  AberFighter
//
//  Created by wde7 on 16/02/2011.
//  Copyright 2011 William Darius Elphick. All rights reserved.
//
/*
 This class extends the Ship superclass to allow the creation of multiple Target types.
 It provides an initializer requiring specification of the type of ship needed.
 It also provides methods for generating a random starting position and heading, a method
 for updating it's position each frame (in conformance with the MovingShip protocol), a 
 border checking method and methods and variables related to the class' use in a 
 ReusableTargetPool.
 */

#import <Foundation/Foundation.h>
#import "Ship.h"

/*
 Here the probability of a ship type appearing in the game should
 be specified. Small ships are more likely to spawn than large ones.
 */
#define kTargetShipLargeAppearanceProbability 20
#define kTargetShipSmallAppearanceProbability 80

/*
 This enumeration lists the TargetShip types which are available in the class.
 */
typedef enum TargetTypes {
	kTargetShipSmall,
	kTargetShipLarge	
} TargetType;

/*
 This enumeration is used in the generateRandomStartingPositionAndHeading method when
 determining which screen edge the TargetShip will spawn on. 
 */
typedef enum StartingEdges {
	kLeftEdge,
	kUpperEdge,
	kRightEdge,
	kLowerEdge
} StartingEdge;

@interface TargetShip : Ship <MovingShip> {
	
	/*
	 This is the score which will be awarded to a player when this target is destroyed.
	 Varies based on TargetType.
	 */
	int scoreAwarded;
	/*
	 This boolean is used by the ReusableTargetPool when determining whether to return
	 a reference to an instance of TargetShip. See ReusableTargetPool for more information.
	 */
	BOOL currentlyInUse;
	/*
	 TargetShips spawn offscreen and move onto the screen after a short time. The ActionLayer 
	 uses the checkIfOffscreen method below to determine when a ship has passed back off the screen
	 again so that it can be released. To differentiate between ships which have just spawned and 
	 those which have reached the other side of the screen, each target has a short minimum lifetime.
	 This boolean is initially false and is set to true after the lifetime has expired, allowing the 
	 ship to be released when it is offscreen again. 
	 */
	BOOL minimumLifetimeExpired;
	/*
	 Type of TargetShip represented by an instance.
	 */
	TargetType targetType;

}

/*
 Property declarations for the instance variables. scoreAwarded and TargetType are readonly because they should
 not be changed once the TargetShip has been initialised. minimumLifetimeExpired is readonly because it should only 
 be changed internally.
 */
@property (nonatomic,readonly) int scoreAwarded;
@property (nonatomic,readwrite,assign) BOOL currentlyInUse;
@property (nonatomic,readonly) BOOL minimumLifetimeExpired;
@property (nonatomic,readonly) TargetType targetType;

/*
 Initializer method. Given the target type it creates an instance of this class, 
 sets the default values for the type specified and returns a reference to the instance.
 */
- (id)initTargetWithType:(TargetType)type;

/*
 This method will set the position of the TargetShip to a random point just offscreen
 of one of the four screen edges and set the heading to a random heading which takes
 the ship onto the screen area.
 */
- (void)generateRandomStartingPositionAndHeading;

/*
 This method sets the initial heading and position of the TargetShip for this spawn
 and schedules a call to update the minimumLifetimeExpired variable.
 */
- (void)spawnWithHeading:(float)heading startingPosition:(CGPoint)startingPosition;

/*
 Sets the new position and rotation of the ship. Should be called each frame.
 */
- (void)updatePosition:(ccTime)timeSinceLastUpdate;

/*
 Returns a boolean indicating whether this ship is offscreen.
 */
- (BOOL)checkIfOffscreen;

/*
 Resets the default values for currentHeading, rotation, position, 
 currentShieldStrength and minimumLifetimeExpired.
 */
- (void)resetVariables;

@end
