//
//  Ship.h
//  AberFighter
//
//  Created by wde7 on 06/01/2011.
//  Copyright 2011 William Darius Elphick. All rights reserved.
//
/* 
 All ships in the game are subclasses of the Ship abstract class (note: Objective C has no definitive support for abstract
 classes. This class shouldn't be instantiated). Provides functionality which is required by all Ships in the game. Ship is
 an extension of CollidableSprite so that collision detection can be performed between the ship and other sprites. 
 */

#import <Foundation/Foundation.h>
#import "CollidableSprite.h"

/*
 This protocol should be conformed to by every ship in the game. Ships must implement 
 the updatePosition method, so that the nextFrame method in the ActionLayer can move the ship.
 This protocol is used because all ships must handle the update of their position internally.
 */
@protocol MovingShip

- (void) updatePosition:(ccTime)timeSinceLastUpdate;

@end


@interface Ship : CollidableSprite {
	
	/*
	 This is the maximum damage a ship can take before being destroyed/disabled.
	 */
	int maximumShieldStrength;
	/*
	 Indicates the ship's remaining shield strength.
	 */
	int currentShieldStrength;
	/*
	 currentHeading stores a value in degrees representing the ship's heading. Rotation, a cocos2D variable
	 inherited from the CCNode superclass, is used when rotating the image shown on the screen.
	 However, currentHeading is used for updating the heading when the input method fires. The rotation of the sprite
	 image should only be updated at the framerate of the game, which is the nextFrame method in the ActionLayer.
	 */
	float currentHeading;
	/*
	 Speed is used to calculate how far the sprite should move each frame.
	 */
	float speed;

}

/*
 Property declarations for the instance variables. maximumShieldStrength is read-only because it should not be updated
 once the Ship has been initialised.
 */
@property (nonatomic,readonly) int maximumShieldStrength;
@property (nonatomic,readwrite,assign) int currentShieldStrength;
@property (nonatomic,readwrite,assign) float currentHeading;
@property (nonatomic,readwrite,assign) float speed;

/*
 Default reduceShieldStrength method. Decrements currentShieldStrength. Returns a boolean 
 indicating if currentShieldStrength is less than or equal to 0.
 */
- (BOOL)reduceShieldStrength;
/*
 This method, given a heading and a distance to travel, returns the new position of the sprite.
 */
- (CGPoint)calculateNewPositionWithHeading:(float)heading distance:(float)distance;

@end
