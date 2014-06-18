//
//  MultiplayerPauseMenuScene.h
//  AberFighter
//
//  Created by wde7 on 08/04/2011.
//  Copyright 2011 William Darius Elphick. All rights reserved.
//
/*
 This class extends the PauseMenuLayer to provide functionality related to interpretting notifications
 from the BluetoothCommsManager through the NSNotificationCenter.
 */

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "PauseMenuScene.h"

@interface MultiplayerPauseMenuLayer : PauseMenuLayer {
	
	/*
	 These labels are used to indicate when each player has pressed Resume.
	 */
	CCLabel *player1ReadyLabel;
	CCLabel *player2ReadyLabel;
	 
	/*
	 These booleans indicate the readiness of both players to resume the game. Only 
	 when both of these are true will the game start.
	 */
	BOOL localPlayerReady;
	BOOL peerReady;
	
	/*
	 This is a pointer to the alertView instance which is used for describing problems
	 with the network connection to the user.
	 */
	UIAlertView *alertView;

}

/*
 Readonly pointers to readiness labels and booleans.
 Also a property which retains the alertView when it is set.
 */
@property (readonly) CCLabel *player1ReadyLabel;
@property (readonly) CCLabel *player2ReadyLabel;
@property (nonatomic,readonly) BOOL localPlayerReady;
@property (nonatomic,readonly) BOOL peerReady;
@property (nonatomic, retain) UIAlertView *alertView;

/*
 Static method which returns a CCScene reference after initializing it, initializing this layer and adding 
 it as a child to the scene.
 */
+ (id)scene;

@end
