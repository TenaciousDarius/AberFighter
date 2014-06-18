//
//  GameOverScene.h
//  AberFighter
//
//  Created by wde7 on 06/04/2011.
//  Copyright 2011 William Darius Elphick. All rights reserved.
//
/*
 The GameOverLayer is shown when the game timer has reached 0 or the user has quit the game.
 It shows the results of the most recent game round. The layout of the content depends on the game type
 and during multiplayer which player you are.
 */

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface GameOverLayer : CCLayer <UIAlertViewDelegate> {
	
	/*
	 This is a pointer to the alertView instance which is used for describing problems
	 with the network connection to the user.
	 */
	UIAlertView *alertView;
	
}

/*
 A property which retains the alertView when it is set.
 */
@property (nonatomic, retain) UIAlertView *alertView;

/*
 Static method which returns a CCScene reference after initializing it, initializing this layer and adding 
 it as a child to the scene.
 */
+(id)scene;

@end
