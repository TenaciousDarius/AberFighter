//
//  MultiplayerActionLayer.m
//  AberFighter
//
//  Created by wde7 on 29/03/2011.
//  Copyright 2011 William Darius Elphick. All rights reserved.
//

#import "MultiplayerActionLayer.h"
#import "MultilayerGameScene.h"
#import "UserInterfaceLayer.h"
#import "BluetoothCommsManager.h"
#import "AberFighterAppDelegate.h"


@implementation MultiplayerActionLayer

@synthesize peerPlayer;
@synthesize localActionLayerReady;
@synthesize peerActionLayerReady;
@synthesize alertView;

/*
 Used for creating a PlayerShip instance to represent the local player and peer player. Initializes the
 playerShips array and adds the local player to it.
 */
- (void)setUpPlayerShips {
	
	CGSize winSize = [CCDirector sharedDirector].winSize;
	
	CGPoint player1StartingPosition = ccp(kPLAYER_START_POSITION, 
										  ((winSize.height - (kHUD_Y_POSITION * 2)) / 2)); 
	
	CGPoint player2StartingPosition = ccp((winSize.width - kPLAYER_START_POSITION), 
										  ((winSize.height - (kHUD_Y_POSITION * 2)) / 2));
	
	PlayerShip *player1Ship = [self createPlayerShipWithSpriteFrameName:@"ship_1.png" 
															   position:player1StartingPosition 
																heading:90.0f 
														   maximumSpeed:kDefaultNetworkGameMaximumSpeed];
	player1Ship.playerID = kPlayer1;
	
	PlayerShip *player2Ship = [self createPlayerShipWithSpriteFrameName:@"ship_2.png"
															   position:player2StartingPosition 
																heading:270.0f 
														   maximumSpeed:kDefaultNetworkGameMaximumSpeed];
	player2Ship.playerID = kPlayer2;
	
	if ([BluetoothCommsManager sharedInstance].playerID == kPlayer1) {
		
		localPlayer = player1Ship;
		peerPlayer = player2Ship;
		
	} else {
		
		localPlayer = player2Ship;
		peerPlayer = player1Ship;
		
	}

	[self.spriteSheet addChild:player1Ship];
	[self.spriteSheet addChild:player2Ship];
	
	self.playerShips = [[NSMutableArray alloc] init];
	[self.playerShips addObject:player1Ship];
	[self.playerShips addObject:player2Ship];
	
}

/*
 Initializer of this layer. Creates an instance of the layer by calling the superclass init method
 and adds the required components to it.
 */
- (id)init {

	if ((self = [super init])) {
		
		//Call setUpPlayerShips to create the local and peer player.
		[self setUpPlayerShips];
		
		//Reset the readiness booleans.
		localActionLayerReady = NO;
		peerActionLayerReady = NO;
		
	}
	
	return self;
}

/*
 Called after a transition to this layer is complete. The layer is setup as an observer of the 
 BluetoothCommsManager through the NSNotificationCenter. Then if the game is starting an ActionLayerReadyPacket
 is sent to the peer device. Otherwise the game is just resumed.
 */
- (void)onEnter {

	[super onEnter];
	
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(processBluetoothNotification:) 
												 name:nil 
											   object:[BluetoothCommsManager sharedInstance]];
	
	if ([GameState sharedState].currentState == kGameStarting) {
		
		[[BluetoothCommsManager sharedInstance] sendActionLayerReadyPacket];
	
	} else if ([GameState sharedState].currentState == kGamePaused) {
		
		[self resumeGame];
		
	}
	
}

/*
 Called when a transition out of this layer is over. Removes this layer as an observer in the 
 NSNotificationCenter before it it deallocated.
 */
- (void)onExit {

	[super onExit];
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
}

/*
 Check ready state is called when a 
 */
- (void)checkReadyState {

	if (localActionLayerReady && peerActionLayerReady) {
		
		[self startCountdown];
		
	}
	
}

/*
 This method is called from the UserInterfaceLayer when it detects a touch in the lower
 corners of the screen. It performs the calculations needed to find the starting position and 
 destination point of the projectile. It sends these details across the network to the peer, 
 then calls fireProjectileWithStartingPositionDestinationPointShip to initiate the process
 of firing.
 */
- (void)fireProjectile {
	
	/*
	 If the local player's ship is currently disabled then firing weapons is not permitted.
	 It is also not permitted for projectiles to be fired when the game start countdown is taking place, 
	 which is indicated by the current game state kGameNotStarted.
	 */
	if([GameState sharedState].currentState == kGameRunning && !self.localPlayer.shipDisabled) {
		
		/*
		 The projectile is spawned at the front of the ship. The position of this is
		 calculated using the ship's radius and rotation applied to the sine and
		 cosine rules and added to the current position of the ship.
		 */
		float shipHeight = self.localPlayer.contentSize.height / 2.0f;
		float shipRotation = self.localPlayer.rotation;
		
		float xOffset = sin(CC_DEGREES_TO_RADIANS(shipRotation)) * shipHeight;
		float yOffset = cos(CC_DEGREES_TO_RADIANS(shipRotation)) * shipHeight;
		
		float projectileXPosition = self.localPlayer.position.x + xOffset;		
		float projectileYPosition = self.localPlayer.position.y + yOffset;	
		
		CGPoint startingPosition = ccp(projectileXPosition, projectileYPosition);
		
		/*
		 The vector along which the projectile will travel is indicated by the x and y offsets 
		 calculated above.
		 */
		CGPoint fireVector = ccp(xOffset, yOffset); 
		
		/*
		 The furthest distance which can be travelled across the device's screen,
		 a diagonal line from one corner to another, is calculated. This is how far the 
		 projectile will travel to ensure that it is offscreen before being removed.
		 */
		CGSize winSize = [CCDirector sharedDirector].winSize;
		float firingDistance = sqrt(pow(winSize.width, 2) + pow(winSize.height, 2));
		
		/*
		 The fire vector is normalized i.e. it's length is converted to 1.
		 */
		CGPoint normalizedFireVector = ccpNormalize(fireVector);
		
		/*
		 The destination vector of the projectile (i.e. the direction and distance by which it needs to 
		 travel in order to be offscreen) is calculated using ccpMult.
		 */
		CGPoint projectileDestinationVector = ccpMult(normalizedFireVector, firingDistance);
		
		/*
		 Send projectile details to peer player.
		 */
		[[BluetoothCommsManager sharedInstance] sendProjectileFiredDetailsWithStartingPosition:startingPosition 
																			  destinationPoint:projectileDestinationVector];
		
		[self fireProjectileWithStartingPosition:startingPosition 
								destinationPoint:projectileDestinationVector 
											ship:self.localPlayer];
		
	}
	
}

/*
 This method retrieves a TargetShip from the ReusableTargetPool, configures it with the 
 parameters specified and adds it to the layer. This is used for when spawning information
 arrives over the network.
 */
- (void)spawnTargetWithType:(TargetType)targetType heading:(float)heading startingPosition:(CGPoint)startingPosition {

	/*
	 A TargetShip instance of the specified type is requested from the ReusableTargetPool. If one is
	 available, a reference will be returned. Otherwise the pool will return nil. In this is the case no target
	 will be spawned during this iteration. 
	 */
	TargetShip *newTarget = [[ReusableTargetPool sharedInstance] acquireTargetShipWithType:targetType];
	if (newTarget != nil) {
		
		[newTarget spawnWithHeading:heading startingPosition:startingPosition];
		
		/*
		 Add the new target ship to the activeTargets list and the spritesheet. From now on it's movement
		 will be handled by calls to it's updatePosition method from the nextFrame method below.   
		 */
		[self.activeTargets addObject:newTarget];
		[self.spriteSheet addChild:newTarget];
		
		/*
		 The newTarget has been retained by adding it to both the spritesheet and the activeTargets list. 
		 Therefore this reference can be set to nil without losing the auto-release object.
		 */
		newTarget = nil;
		
	}
	
}

/*
 This method is called from the gameLogic method when the spawnRate has been reached.
 It acquires a target of a random type from the ReusableTargetPool, configures it
 and adds it to the layer.
 */
- (void) spawnTarget {
	
	int targetShipType = [self determineSpawnedTargetType];	
	
	/*
	 A TargetShip instance of the specified type is requested from the ReusableTargetPool. If one is
	 available, a reference will be returned. Otherwise the pool will return nil. In this is the case no target
	 will be spawned during this iteration. 
	 */
	TargetShip *newTarget = [[ReusableTargetPool sharedInstance] acquireTargetShipWithType:targetShipType];
	if (newTarget != nil) {
		
		/*
		 A new target has been acquired. The generateRandomStartingPositionAndHeading method sets the initial 
		 state of the target ship.
		 */
		[newTarget generateRandomStartingPositionAndHeading];
		
		[[BluetoothCommsManager sharedInstance] sendTargetSpawnDetailsWithType:targetShipType
																currentHeading:newTarget.currentHeading
															  startingPosition:newTarget.position];
		
		/*
		 Add the new target ship to the activeTargets list and the spritesheet. From now on it's movement
		 will be handled by calls to it's updatePosition method from the nextFrame method below.   
		 */
		[self.activeTargets addObject:newTarget];
		[self.spriteSheet addChild:newTarget];
		
		/*
		 The newTarget has been retained by adding it to both the spritesheet and the activeTargets list. 
		 Therefore this reference can be set to nil without losing the auto-release object.
		 */
		newTarget = nil;
		
	}
	
}

/*
 Called by the accelerometer to update this class at regular intervals of the current acceleration values.
 */
- (void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration {
	
	/*
	 DirectionalChanges are calculated and applied in the superclass call.
	 The localPlayer's directional data is then sent across the network to update their 
	 ship on that side.
	 */
	[super accelerometer:accelerometer didAccelerate:acceleration];
	
	[[BluetoothCommsManager sharedInstance] sendLocalPlayerShipDirectionalDataWithNewHeading:localPlayer.currentHeading
																					newSpeed:localPlayer.speed
																			 currentPosition:localPlayer.position
																			 currentRotation:localPlayer.rotation];
	
}

/*
 Overrides the nextFrame method in order to perform collision detection between the localPlayer and peerPlayer.
 Once that has been done the rest of the collision detection algorithm runs as normal through a call to the superclass.
 */
- (void)nextFrame:(ccTime)timeSinceLastCall {
	
	if (!localPlayer.shipDisabled) {
		
		if (!peerPlayer.shipDisabled) {
			
			if ([localPlayer checkCollisionWithCollidableSprite:self.peerPlayer]) {
		
				[localPlayer reduceShieldStrength];
				[peerPlayer reduceShieldStrength];
				
			}
		
		}
		
	}
	
	[super nextFrame:timeSinceLastCall];

}

/*
 Called 10 times a second. Used for spawning enemies and clearing up enemies which 
 have reached the end of their lifespan.
 */
- (void)gameLogic:(ccTime)timeSinceLastCall {

	/*
	 Player 1's device acts as the server for target ship spawning.
	 */
	if ([BluetoothCommsManager sharedInstance].playerID == kPlayer1) {
		
		[self checkTargetSpawningSituation];
		
	}
	
	[self clearOffscreenTargets];
	
}

/*
 The draw method is overridden to update the score labels in the HUD for both players.
 */
- (void)draw {

	int playerID = [BluetoothCommsManager sharedInstance].playerID;
	int localScore = 0;
	int peerScore = 0;
	
	if (playerID == kPlayer1) {
		
		localScore = [GameState sharedState].player1Score;
		peerScore = [GameState sharedState].player2Score;
		
	} else {
		
		localScore = [GameState sharedState].player2Score;
		peerScore = [GameState sharedState].player1Score;
		
	}
	
	UserInterfaceLayer* uiLayer = [MultilayerGameScene sharedScene].userInterfaceLayer;
	[uiLayer updateScoreLabelsWithLocalScore:localScore peerScore:peerScore];
	
	[super draw];
	
}

/*
 Called by the AlertView when it is dismissed with the button. Calls the abortActiveMultiplayerGame method in the
 app delegate to clear up the game session and return the user to the main menu.
 */
- (void)cancelMultiplayerGame {
	
	AberFighterAppDelegate *delegate = (AberFighterAppDelegate *)[UIApplication sharedApplication].delegate;
	
	[delegate abortActiveMultiplayerGame];
	
}

/*
 Shows an alert view on top of the layer. If an alert is already showing then depending on the replaceExistingAlert boolean
 it's text and title are replaced.
 */
- (void)showAlertViewWithTitle:(NSString *)title message:(NSString *)message cancelButtonTitle:(NSString *)cancelButtonTitle replaceExistingAlert:(BOOL)replaceExistingAlert {
	
	if (self.alertView && self.alertView.visible) {
		
		if (replaceExistingAlert) {
			self.alertView.title = title;
			self.alertView.message = message;
		}
		
	} else {
		
		[[CCDirector sharedDirector] pause];
		
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
														message:message
													   delegate:self 
											  cancelButtonTitle:cancelButtonTitle 
											  otherButtonTitles:nil];
		self.alertView = alert;
		[alert show];
		[alert release];
		
	}
	
	
}

/*
 Called when the cancel button is pressed on the alertView. Calls cancelMultiplayerGame to reset the bluetooth state.
 */
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)index {
	
	[[CCDirector sharedDirector] resume];
	
	if (index == 0) {
		
		[self cancelMultiplayerGame];
		
	}
	
}

/*
 Show alert when connection is lost.
 */
- (void)showDisconnectAlert {
	
	[self showAlertViewWithTitle:@"Connection Error" 
						 message:@"The connection was lost. You will now be returned to the main menu." 
			   cancelButtonTitle:@"OK" 
			replaceExistingAlert:YES];
	
}

- (void)processBluetoothNotification:(NSNotification *)notification {
	
	if (notification.name == PeerPausedGame) {
		
		/*
		 Peer player has paused game. Call UserInterfaceLayer to pause game.
		 */
		[[MultilayerGameScene sharedScene].userInterfaceLayer pauseGame];
		
	} else if (notification.name == PeerActionLayerReady) {
		
		/*
		 Peer's actionLayerReady. Send acknowledgement and check ready state.
		 */
		peerActionLayerReady = YES;
		[[BluetoothCommsManager sharedInstance] sendAcknowledgeActionLayerReadyPacket];
		[self checkReadyState];
		
	} else if (notification.name == ActionLayerReadyAcknowledged) {
		
		/*
		 localActionLayerReady isn't true until acknowledgement is received. Stops one
		 device from starting the game without the other.
		 */
		localActionLayerReady = YES;
		[self checkReadyState];
		
	} else if (notification.name == SessionFailedWithError) {
		
		/*
		 Error with session. Show Disconnect Alert which will return the player to the main menu when dismissed.
		 */
		[self showDisconnectAlert];
		
	} else if (notification.name == PeerWasDisconnected) {
		
		/*
		 Peer has been disconnected. Show Disconnect Alert which will return the player to the main menu when dismissed.
		 */
		[self showDisconnectAlert];
		
	} else if (notification.name == PeerLost) {
		
		/*
		 Peer connection lost. Show Reconnect alert which notifies user that they must return to the main menu.
		 */
		[self showDisconnectAlert];
		
	} 
	
}

/*
 Peer player and AlertView are dealloced when the layer is dealloced.
 */
- (void)dealloc {
	
	[peerPlayer unscheduleAllSelectors];
	peerPlayer = nil;
	
	if ((self.alertView != nil) && self.alertView.visible) {
		
		[self.alertView dismissWithClickedButtonIndex:-1 animated:NO];
		
	}
	
	self.alertView = nil;
	
	[super dealloc];
	
}

@end
