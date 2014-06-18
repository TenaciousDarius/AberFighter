//
//  PlayerShip.h
//  AberFighter
//
//  Created by wde7 on 06/01/2011.
//  Copyright 2011 William Darius Elphick. All rights reserved.
//
/*
 Concrete implementation of Ship. PlayerShip has a few notable differences from other ships (see below).
 Conforms to the MovingShip protocol.
 */

#import <Foundation/Foundation.h>
#import "Ship.h"

//Constant which specifies how long a ship remains disabled.
#define kShipRepairTime 3.0f

//Constant which specifies how long a ship remains invincible after it is re-enabled.
#define kShipInvincibleTime 3.0f

//Constant which specifies the default maximum shield strength of the PlayerShip. 
#define kDefaultMaximumShieldStrength   5

/*
 The maximumSpeed of the ship is different during single and multiplayer games. The PlayerShip moves slower
 during multiplayer games to reduce the probability of inconsistencies appearing between the positions
 of it on both devices.
 */
#define kDefaultMaximumSpeed            100
#define kDefaultNetworkGameMaximumSpeed 50

@interface PlayerShip : Ship <MovingShip> {
	
	/*
	 PlayerShips can be disabled as they take damage. When currentShieldStrength reaches 0
	 this boolean becomes true. After a short period of time it is set to false again. 
	 */
	BOOL shipDisabled;
	
	/*
	 While disabled and for a short period afterwards the PlayerShip is invincible. During this time
	 the invincible boolean is set to true.
	 */
	BOOL invincible;
	
	/*
	 The maximumSpeed variable can be used to change the maximum distance a PlayerShip moves every frame.
	 This will be useful in the future if secondary weapons are created which can slow down your opponent or
	 give a player a speed boost.
	 */
	int maximumSpeed;
	
	/*
	 The playerID is used during collision detection. It is compared with the originatingPlayerID of Projectile 
	 instances which collide with the ship. Only projectiles fired by other players should reduce the shield 
	 strength of the PlayerShip.
	 */
	int playerID;

}

/*
 Property declarations for the instance variables. shipDisabled and invincible are readonly because they should 
 only be changed internally by the class.
 */
@property (nonatomic,readonly) BOOL shipDisabled;
@property (nonatomic,readonly) BOOL invincible;
@property (nonatomic,readwrite,assign) int maximumSpeed;
@property (nonatomic,readwrite,assign) int playerID;

/*
 Sets the new position and rotation of the ship. Should be called each frame.
 */
- (void)updatePosition:(ccTime)timeSinceLastUpdate;

/*
 This method applies the values calculated by the DirectionalChangesCalculator to the ship's
 currentHeading and speed. The values are only applied if the ship is not disabled.
 */
- (void)applyDirectionalChangesWithNewHeading:(float)newHeading newSpeed:(float)newSpeed;

@end
