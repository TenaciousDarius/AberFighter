//
//  Projectile.m
//  AberFighter
//
//  Created by wde7 on 03/03/2011.
//  Copyright 2011 William Darius Elphick. All rights reserved.
//

#import "Projectile.h"

@implementation Projectile

@synthesize originatingPlayerID;

/*
 Initializer method. The originatingPlayerID is initially 0. 
 The id must be set before the projectile is fired.
 */
- (id)init {

	if ((self = [super init])) {
		
		originatingPlayerID = 0;
		
	}
	
	return self;
	
}

- (void)dealloc {
	
	[super dealloc];
	
}

@end
