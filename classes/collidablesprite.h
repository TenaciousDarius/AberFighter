//
//  CollidableSprite.h
//  AberFighter
//
//  Created by wde7 on 27/02/2011.
//  Copyright 2011 William Darius Elphick. All rights reserved.
//
/*
 Subclass of CCSprite with methods for detecting collisions between objects. All
 of the interacting sprites in the project are descended from this class.
 */

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface CollidableSprite : CCSprite {
	
	/*
	 Boolean indicating if this sprite has collided with another. Used when performing collision
	 detection to avoid making unnecessary comparisons between objects.
	 */
	BOOL hasCollided;

}

/*
 Property declarations for the instance variables.
 */
@property (nonatomic,readwrite,assign) BOOL hasCollided;

/*
 Takes a CollidableSprite as a parameter and returns a boolean indicating whether this 
 CollidableSprite is in collision with it. Updates the hasCollided boolean.
 */
- (BOOL)checkCollisionWithCollidableSprite:(CollidableSprite *)otherSprite;

@end
