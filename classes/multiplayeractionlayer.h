//
//  MultiplayerActionLayer.h
//  AberFighter
//
//  Created by wde7 on 29/03/2011.
//  Copyright 2011 William Darius Elphick. All rights reserved.
//
/*
 The MultiplayerActionLayer configures the functionality available in the ActionLayer for a multiplayer game.
 */

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "ActionLayer.h"

@interface MultiplayerActionLayer : ActionLayer <UIAlertViewDelegate> {
	
	/*
	 This is a pointer to the instance of PlayerShip which represents the peer player.
	 It is used for applying directional data received over the network to it's state.
	 */
	PlayerShip *peerPlayer;
	
	/*
	 These booleans indicate the readiness of both ActionLayers to start the game. Only 
	 when both of these are true will the game start.
	 */
	BOOL localActionLayerReady;
	BOOL peerActionLayerReady;

	/*
	 This is a pointer to the alertView instance which is used for describing problems
	 with the network connection to the user.
	 */
	UIAlertView *alertView;
	
}

/*
 Readonly pointers to readiness booleans and PlayerShip peer player.
 Also a property which retains the alertView when it is set.
 */
@property (readonly) PlayerShip *peerPlayer;
@property (nonatomic,readonly) BOOL localActionLayerReady;
@property (nonatomic,readonly) BOOL peerActionLayerReady;
@property (nonatomic, retain) UIAlertView *alertView;

/*
 This method retrieves a TargetShip from the ReusableTargetPool, configures it with the 
 parameters specified and adds it to the layer.
 */
- (void)spawnTargetWithType:(TargetType)targetType heading:(float)heading startingPosition:(CGPoint)startingPosition;

@end
