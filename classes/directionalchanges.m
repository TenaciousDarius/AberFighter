//
//  DirectionalChanges.m
//  AberFighter
//
//  Created by wde7 on 07/01/2011.
//  Copyright 2011 William Darius Elphick. All rights reserved.
//


#import "DirectionalChanges.h"

@implementation DirectionalChanges

/*
 Setter and getter methods for the instance variables are created by synthesize.
 */
@synthesize newHeading;
@synthesize newSpeed;

/*
 Initializer method. Creates an instance of this class, sets the default values for instance 
 variables and returns a reference to the instance.
 */
- (id)init {

	if ((self = [super init])) {
		
		newHeading = 0.0f;
		newSpeed = 0.0f;
		
	}
	return self;
	
}

- (void)dealloc {
	
	[super dealloc];
	
}

@end
