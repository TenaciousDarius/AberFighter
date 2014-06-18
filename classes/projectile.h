//
//  Projectile.h
//  AberFighter
//
//  Created by wde7 on 03/03/2011.
//  Copyright 2011 William Darius Elphick. All rights reserved.
//
/*
 Subclass of CollidableSprite. A Projectile instance has an integer which identifies which player fired it.
 This is so that points can be allocated to the correct player when a collision occurs.
 */

#import <Foundation/Foundation.h>
#import "CollidableSprite.h"

@interface Projectile : CollidableSprite {

	//ID of the player which fired the sprite.
	int originatingPlayerID;
	
}

/*
 Property declarations for the instance variables.
 */
@property (nonatomic,readwrite,assign) int originatingPlayerID;

@end
