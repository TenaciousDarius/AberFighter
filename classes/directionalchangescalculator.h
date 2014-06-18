//
//  DirectionalChangesCalculator.h
//  AberFighter
//
//  Created by wde7 on 07/01/2011.
//  Copyright 2011 William Darius Elphick. All rights reserved.
//
/*
 Static class which contains methods designed to receive data from 
 various input methods and calculate the appropriate DirectionalChanges 
 for the PlayerShip. Acts as a level of indirection between the PlayerShip 
 class and the chosen input method. Because PlayerShip uses the variables contained in the
 DirectionalChanges instance to apply a new heading and speed, a new view can be created which 
 implements a different input method (e.g. a touch interface for turning left 
 and right) and a corresponding method can be implemented in this class to 
 interpret the data received. 
 
 Two methods have been implemented which interpret accelerometer data in different ways
 to produce different control models. This acts as a proof of concept for the multiple
 input method requirement.
 */

#import <Foundation/Foundation.h>
#import "DirectionalChanges.h"

@interface DirectionalChangesCalculator : NSObject {

}

/*
 Static method used for interpreting input from the accelerometer to create a DirectionalChanges 
 class of values which need applying to the PlayerShip. This method interprets accelerometer data
 in a way which produces player movement similar to moving a ball across a surface i.e. the ship 
 travels in the direction the device is tilted. The further the device is tilted, the faster the ship moves.
 This is the default control model.
 */
+ (DirectionalChanges *)calculateDirectionalChangesWithAcceleration:(UIAcceleration *)currentAcceleration;

/*
 Static method used for interpreting input from the accelerometer to create a DirectionalChanges 
 class of values which need applying to the PlayerShip. This method interprets accelerometer data
 differently, leading to a joystick-like control model. The speed of the ship is controlled by tilting
 the device forward and backward along the the x-axis. Heading is controlled by tilting the device along
 the y-axis - tilting the left side of the screen causes the ship to turn anti-clockwise and vice-versa.
 This is an alternative control model.
 */
+ (DirectionalChanges *)calculateDirectionalChangesWithAcceleration:(UIAcceleration *)currentAcceleration heading:(float)currentHeading speed:(float)currentSpeed;

@end
