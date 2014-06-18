//
//  DirectionalChanges.h
//  AberFighter
//
//  Created by wde7 on 07/01/2011.
//  Copyright 2011 William Darius Elphick. All rights reserved.
//
/*
 Data class containing information about transformations which need to be applied to
 the PlayerShip's heading and speed based on data from the chosen 
 input method. See PlayerShip and DirectionalChangesCalculator for more information. 
 */

#import <Foundation/Foundation.h>

@interface DirectionalChanges : NSObject {
	
	//New heading which should be applied to the ship's current heading.
	float newHeading;
	//New speed which should be applied to the ship's speed.
	float newSpeed;

}

/*
 Property declarations for the instance variables.
 */
@property (nonatomic,readwrite,assign) float newHeading;
@property (nonatomic,readwrite,assign) float newSpeed;

@end
