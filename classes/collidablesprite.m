//
//  CollidableSprite.m
//  AberFighter
//
//  Created by wde7 on 27/02/2011.
//  Copyright 2011 William Darius Elphick. All rights reserved.
//

#import "CollidableSprite.h"

@implementation CollidableSprite

/*
 Automatically creates getter and setter methods for the hasCollided property.
 */
@synthesize hasCollided;

/*
 Initializer method. Creates an instance of this class, sets the default values for instance 
 variables and returns a reference to the instance. hasCollided is initially false.
 */
- (id)init {
	
	if ((self = [super init])) {
		self.hasCollided = NO;	
	}
	
	return self;
	
}

/*
 Implements a bounding circle collision detection algorithm and returns
 a boolean indicating whether the sprites have collided or not.
 */
- (BOOL)checkCollisionWithCollidableSprite:(CollidableSprite *)otherSprite {
	
	/*
	 Reset hasCollided before performing the comparison.
	 */
	self.hasCollided = NO;
	
	/*
	 The following code implements a bounding circle collision detection algorithm.
	 It assumes that both sprites are roughly circular in shape i.e. the width is approximately equal
	 to the height. The minimumIntersectionDistance is the sum of the radii of the two bounding circles.
	 If the distance between the centers of both sprites is less than the sum of the two radii, then
	 the sprites are in collision. Distance between centers is calculated using the pythagoras theorem.
	 */
	float minimumIntersectionDistance = (otherSprite.contentSize.width / 2) + (self.contentSize.width / 2);
	float distanceBetweenSprites = sqrt((pow((self.position.x - otherSprite.position.x), 2) 
										 + pow((self.position.y - otherSprite.position.y), 2)));
	
	if (minimumIntersectionDistance > distanceBetweenSprites) {
		
		/*
		 When a collision has occured hasCollided is set to true. This is so that when performing collision detection 
		 between projectiles and other sprites, a projectile which has collided will not be checked against another 
		 sprite before being removed.
		 */
		self.hasCollided = YES;
		
	}
	
	return self.hasCollided;
	
}

- (void)dealloc {
	
	[super dealloc];
	
}

@end
