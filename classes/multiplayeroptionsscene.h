//
//  MultiplayerOptionsLayer.h
//  AberFighter
//
//  Created by wde7 on 23/03/2011.
//  Copyright 2011 William Darius Elphick. All rights reserved.
//
/*
 This class extends the GameOptionsLayer class to configure it for a multiplayer game.
 The layout presented is slightly different for players 1 and 2.
 */

#import <Foundation/Foundation.h>
#import "GameOptionsLayer.h"

@interface MultiplayerOptionsLayer : GameOptionsLayer <UIAlertViewDelegate> {
	
	/*
	 These labels are used to indicate when each player has pressed Start Game.
	 */
	CCLabel *player1ReadyLabel;
	CCLabel *player2ReadyLabel;
	
	/*
	 These booleans indicate the readiness of both players to start the game. Only 
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
