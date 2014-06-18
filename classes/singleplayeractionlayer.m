//
//  SinglePlayerActionLayer.m
//  AberFighter
//
//  Created by wde7 on 29/03/2011.
//  Copyright 2011 William Darius Elphick. All rights reserved.
//

#import "SinglePlayerActionLayer.h"
#import "MultilayerGameScene.h"
#import "UserInterfaceLayer.h"

@implementation SinglePlayerActionLayer

/*
 Used for creating a PlayerShip instance to represent the local player. Initializes the
 playerShips array and adds the local player to it.
 */
- (void)setUpPlayerShips {
	
	CGSize winSize = [CCDirector sharedDirector].winSize;
	
	CGPoint playerPosition = ccp(winSize.width / 2, winSize.height / 4);
	
	localPlayer = [self createPlayerShipWithSpriteFrameName:@"ship_1.png" 
												   position:playerPosition 
													heading:0.0f 
											   maximumSpeed:kDefaultMaximumSpeed];
	self.localPlayer.playerID = 1;
	
	[self.spriteSheet addChild:self.localPlayer];
	
	self.playerShips = [[NSMutableArray alloc] init];
	[self.playerShips addObject:localPlayer];
	
}

/*
 Initializer of this layer. Creates an instance of the layer by calling the superclass init method
 and adds the required components to it.
 */
- (id)init {

	if ((self = [super init])) {
		
		//Call setUpPlayerShips to create the local player.
		[self setUpPlayerShips];
		
	}
	
	return self;
}

/*
 Called after a transition to this layer is complete. If the game state is GameStarting
 then this is a new game and therefore startCountdown is called to show the countdown.
 Otherwise resumeGame is called to resume functionality from the point the game was paused.
 */
- (void)onEnter {
	[super onEnter];
	
	if ([GameState sharedState].currentState == kGameStarting) {
		[self startCountdown];
	} else if ([GameState sharedState].currentState == kGamePaused) {
		[self resumeGame];
	}
	
}

/*
 draw is overidden in order to update the user interface layer. When [super draw] is called
 the PlayerShielding is drawn.
 */
- (void)draw {

	UserInterfaceLayer* uiLayer = [MultilayerGameScene sharedScene].userInterfaceLayer;
	[uiLayer updateLocalScoreLabel:[GameState sharedState].player1Score];
	
	[super draw];
	
}

- (void)dealloc {

	[super dealloc];
	
}

@end
