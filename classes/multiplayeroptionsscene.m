//
//  MultiplayerOptionsLayer.m
//  AberFighter
//
//  Created by wde7 on 23/03/2011.
//  Copyright 2011 William Darius Elphick. All rights reserved.
//

#import "MultiplayerOptionsScene.h"
#import "AberFighterAppDelegate.h"
#import "BluetoothCommsManager.h"
#import "GameState.h"

#pragma mark -
#pragma mark MultiplayerOptionsLayer

/*
 This message is shown to player 2 in place of the game length slider available to player 1.
 */
NSString *const Player2TimeMessage = @"Player 1 will select the game length. Please calibrate a comfortable playing angle and press Start Game.";

@implementation MultiplayerOptionsLayer

#pragma mark -
#pragma mark Synthesized Properties

@synthesize player1ReadyLabel;
@synthesize player2ReadyLabel;
@synthesize localPlayerReady;
@synthesize peerReady;
@synthesize alertView;

#pragma mark -
#pragma mark MultiplayerOptionsLayer Initializers

/*
 Static scene initializer.
 */
+ (id)scene {
	
	CCScene *scene = [CCScene node];
	id node = [MultiplayerOptionsLayer node];
	[scene addChild:node];
	
	return scene;
	
}

/*
 Creates two ready labels for the status of each player in the multiplayer game. Initially both are partially
 opaque and red in colour.
 */
- (void)setUpReadyLabels {

	player1ReadyLabel = [CCLabel labelWithString:@"Player 1 Ready" fontName:@"Arial" fontSize:24];
	player1ReadyLabel.color = ccc3(255, 0, 0);
	player1ReadyLabel.opacity = 180.0;
	player1ReadyLabel.position = ccp((background.position.x - (background.contentSize.width / 4.5)), 
									 (background.position.y - (background.contentSize.height / 3)));
	[self addChild:player1ReadyLabel];
	
	player2ReadyLabel = [CCLabel labelWithString:@"Player 2 Ready" fontName:@"Arial" fontSize:24];
	player2ReadyLabel.color = ccc3(255, 0, 0);
	player2ReadyLabel.opacity = 180.0;
	player2ReadyLabel.position = ccp((background.position.x + (background.contentSize.width / 4.5)), 
									 (background.position.y - (background.contentSize.height / 3)));
	[self addChild:player2ReadyLabel];
}

/*
 Initializer of this layer. Creates an instance of the layer by calling the superclass init method
 and adds the required components to it.
 */
- (id)init {
	
	if ((self = [super init])) {
		
		/*
		 The layout of the view depends on the playerID which was assigned to the player during the die roll process.
		 */
		int playerID = [BluetoothCommsManager sharedInstance].playerID;
		
		/*
		 The title at the top of the layer indicates the player number allocated to the device.
		 An image is also loaded for the PlayerShip sprite with the correct colours for the playerID.
		 */
		NSString *titleString = [NSString stringWithFormat:@"Game Options - Player %d", playerID];
		NSString *playerShipFrameName = [NSString stringWithFormat:@"ship_%d.png", playerID];
		
		if (playerID == kPlayer1) {
			/*
			 Player 1's ship points to the right as it will in the ActionLayer.
			 */
			[self setUpTitle:titleString 
				shipFrameName:playerShipFrameName 
				 shipRotation:90.0f];
			
			/*
			 Player 1 decides on the game length and therefore setUpGameLengthSlider is called to
			 place the slider on the view.
			 */
			[self setUpGameLengthSlider];
			
		} else {
			
			/*
			 Player 2's ship points to the left as it will in the ActionLayer.
			 */
			[self setUpTitle:titleString 
				shipFrameName:playerShipFrameName 
				 shipRotation:270.0f];
			
			/*
			 Player 2 is shown a message alerting them that Player 1 will select the game length.
			 */
			CCLabel *messageLabel = [CCLabel labelWithString:Player2TimeMessage 
												  dimensions:CGSizeMake(390, (SLIDER_Y_POS_MAX - SLIDER_Y_POS_MIN)) 
												   alignment:UITextAlignmentCenter 
													fontName:@"Arial" fontSize:16];
			messageLabel.position = ccp(((SLIDER_X_POS_MAX - SLIDER_X_POS_MIN)/2) + SLIDER_X_POS_MIN, 
									  ((SLIDER_Y_POS_MAX - SLIDER_Y_POS_MIN)/2) + SLIDER_Y_POS_MIN);
			[self addChild:messageLabel];
			
		}

		/*
		 Creates the buttons displayed on the layer.
		 */
		[self setUpMenu];
		
		/*
		 Creates the readiness labels displayed for each player.
		 */
		[self setUpReadyLabels];
		
	}
	
	return self;
	
}

#pragma mark -
#pragma mark Slider Methods

/*
 moveSlider is overridden in this class because there is a need to transfer the game length across 
 the network when it is updated.
 */
- (void) moveSlider:(UITouch *)touch {
	
	/*
	 The superclass implementation of this method calculates and sets the new game length. 
	 */
	[super moveSlider:touch];
	
	/*
	 Once the game length has been updated we check that the touch is within the boundaries of the slider
	 and then the BluetoothCommsManager sendNewGameLengthPacket method is called to transfer the new game 
	 length across the network.
	 */
	CGPoint location = [touch locationInView: [touch view]];
	if ((location.x < SLIDER_Y_POS_MAX) && (location.x > SLIDER_Y_POS_MIN)) {
		[[BluetoothCommsManager sharedInstance] sendNewGameLengthPacket:[GameState sharedState].gameLength];
	}
	
}

/*
 The ccTouchesBegan and ccTouchesMoved methods are called when the user is touching and dragging
 their finger across the screen. In this situation the app needs to check if the touch is around the area
 where the game length slider is located on the screen. A touch which was detected 
 is passed to the moveSlider method which determines if this is true. This process is only available to
 player 1.
 */
- (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{

	if ([BluetoothCommsManager sharedInstance].playerID == kPlayer1 && !localPlayerReady) {
		
		[self moveSlider:[touches anyObject]];
		
	}
	
}

- (void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	
	if ([BluetoothCommsManager sharedInstance].playerID == kPlayer1 && !localPlayerReady) {
		
		[self moveSlider:[touches anyObject]];
	
	}
	
}

#pragma mark -
#pragma mark Menu Related Methods

/*
 Called when the Cancel button is pressed. Sends a packet to the other device which indicates the
 situation then clears up the game state and returns to the main menu.
 */
- (void)cancelMultiplayerGame {
	
	[[BluetoothCommsManager sharedInstance] sendGameCancelledPacket];

	/*
	 The GameState game length is reset and the bluetooth session is cleared up.
	 */
	[[GameState sharedState] resetGameLength];
	[[BluetoothCommsManager sharedInstance] clearUpSession];
	
	/*
	 Call launchMainMenu on the app delegate to replace the MultiplayerOptionsLayer with the MainMenuLayer.
	 */
	AberFighterAppDelegate *delegate = (AberFighterAppDelegate *)[UIApplication sharedApplication].delegate;
	[delegate launchMainMenu];
	
}

//Called when a button is pressed.
- (void) menuItemPressed:(CCMenuItem *) menuItem {
	
	if (menuItem.tag == 2) {
		
		/*
		 Start Game button pressed. Disable all buttons and sliders except for the Cancel button.
		 */
		self.isAccelerometerEnabled = NO;
		self.startGameButton.visible = NO;
		self.calibrateButton.visible = NO;
		self.slider.visible = NO;
		/*
		 Send a PlayerReadyPacket to the other device.
		 */
		[[BluetoothCommsManager sharedInstance] sendPlayerReadyPacket];		
		
	} else if (menuItem.tag == 3) {
		
		/*
		 Cancel button pressed. Stop accelerometer updates on this view, then call cancelMultiplayerGame to
		 update the peer and clear up the bluetooth session.
		 */
		self.isAccelerometerEnabled = NO;
		[self cancelMultiplayerGame];
		
	} else {
		
		/*
		 If none of the tags in this method are satisfied, call the superclass menuItemPressed method to try and handle 
		 the MenuItem which has been pressed.
		 */
		[super menuItemPressed:menuItem];
		
	}

	
}

#pragma mark -
#pragma mark Alert View Methods

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
	
	if (index == 0) {

		[self cancelMultiplayerGame];
		
	}
	
}

/*
 These methods display various alerts based on Bluetooth error states which can occur.
 */
- (void)showCancelAlert {
	
	[self showAlertViewWithTitle:@"Game Cancelled" 
						 message:@"Your opponent cancelled the game. You will now be returned to the main menu." 
			   cancelButtonTitle:@"OK" 
			replaceExistingAlert:YES];
	
}

- (void)showDisconnectAlert {

	[self showAlertViewWithTitle:@"Connection Error" 
						 message:@"The connection was lost. You will now be returned to the main menu." 
			   cancelButtonTitle:@"OK" 
			replaceExistingAlert:YES];
	
}

- (void)showReconnectAlert {
	
	[self showAlertViewWithTitle:@"Connection Lost" 
						 message:@"Trying to re-establish connection. Please wait or return to the main menu." 
			   cancelButtonTitle:@"Main Menu" 
			replaceExistingAlert:NO];
	
}

#pragma mark -
#pragma mark BluetoothCommsManager Notification Processing

/*
 This method is used to identify when the game should start.
 It makes use of the peerReady and localPlayerReady booleans. These are set when the relevant 
 packets are received across the network (see processBluetoothNotification method).
 */
- (void)updateReadyState {
	
	/*
	 The localPlayerID is used to identify which readyLabel represents this device and which is the peer.
	 */
	int localPlayerID = [BluetoothCommsManager sharedInstance].playerID;
	
	/*
	 Player 1 Ready is green if the localPlayer is ready and is player 1 or 
	 the peer player is ready and they're player 1.
	 */
	if ((self.localPlayerReady && localPlayerID == kPlayer1) ||
		(self.peerReady && localPlayerID == kPlayer2)) {
		
		player1ReadyLabel.opacity = 255.0;
		player1ReadyLabel.color = ccc3(0.0, 255.0, 0.0);
		
	} 
	
	/*
	 Player 2 Ready is green if the localPlayer is ready and is player 2 or 
	 the peer player is ready and they're player 2.
	 */
	if ((self.localPlayerReady && localPlayerID == kPlayer2) ||
		(self.peerReady && localPlayerID == kPlayer1)) {
		
		player2ReadyLabel.opacity = 255.0;
		player2ReadyLabel.color = ccc3(0.0, 255.0, 0.0);
		
	}
	
	/*
	 If both players are ready to start the game then the app delegate startGame method is 
	 called to transition into the MultilayerGameScene..
	 */
	if (self.localPlayerReady && self.peerReady) {
		
		AberFighterAppDelegate *delegate = (AberFighterAppDelegate *)[UIApplication sharedApplication].delegate;
		[delegate startGame];
		
	}
	
}

/*
 Called by the NSNotificationCenter when this class is registered as an observer of the BluetoothCommsManager.
 This method reacts to the notifications posted by the BluetoothCommsManager.
 */
- (void)processBluetoothNotification:(NSNotification *)notification {

	if (notification.name == NewGameLengthReceived) {
		
		/*
		 New game length received over the network. Calls updateGameLength with the values transferred.
		 */
		NSNumber *newGameLength = (NSNumber *)[notification.userInfo objectForKey:@"newGameLength"];
		[self updateGameLength:[newGameLength intValue]];
		
	} else if (notification.name == PeerReadyToPlay) {
		
		/*
		 Peer ready to player packet received. Set peerReady to true and call sendAcknowledgePlayerReadyPacket 
		 on the comms manager. 
		 */
		peerReady = YES;
		[[BluetoothCommsManager sharedInstance] sendAcknowledgePlayerReadyPacket];
		/*
		 Call updateReadyState which checks if both players have said they're ready and been acknowledged, in which case 
		 the game starts.
		 */
		[self updateReadyState];
		 
	} else if (notification.name == LocalPlayerReadyAcknowledged) {
		
		/*
		 Acknowledgement received that local player is ready to play. Set localPlayerReady to true and
		 call updateReadyState to check if both players are ready.
		 */
		localPlayerReady = YES;
		[self updateReadyState];
		
	} else if (notification.name == PeerCancelledGame) {
		
		/*
		 Peer pressed Cancel button. Show Cancel Alert which will return the local player to the main menu when dismissed.
		 */
		[self showCancelAlert];
		
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
		 Peer connection lost. Show Reconnect alert which notifies user that the devices are attempting to re-connect. They
		 can dimiss the alert to return to the main menu or wait for reconnection.
		 */
		[self showReconnectAlert];
		
	} else if (notification.name == PeerFound) {
		
		/*
		 Peer has been reconnected with other device. Dismiss the UIAlertView.
		 */
		[self.alertView dismissWithClickedButtonIndex:-1 animated:YES];
		
	}
}

#pragma mark -
#pragma mark Superclass Overrides

/*
 Called when the layer is shown. Adds the layer as an observer of the BluetoothCommsManager in the
 NSNotificationCenter.
 */
- (void) onEnter{
	
	[super onEnter];
	
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(processBluetoothNotification:) 
												 name:nil 
											   object:[BluetoothCommsManager sharedInstance]];
	
	/*
	 Reset player readiness state.
	 */
	localPlayerReady = NO;
	peerReady = NO;
	
	/*
	 Reset ActionLayer readiness indicator in the comms manager.
	 */
	[BluetoothCommsManager sharedInstance].localActionLayerReady = NO; 
	
}

/*
 Called when a transition out of this layer is over. Removes this layer as an observer in the 
 NSNotificationCenter before it it deallocated.
 */
- (void) onExit{
	
	[super onExit];
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	
}

/*
 Called when this class is deallocated. Sets pointers to cocos2D components to nil and 
 removes the alertView if it's showing.
 */
- (void)dealloc {

	player1ReadyLabel = nil;
	player2ReadyLabel = nil;
	
	if ((self.alertView != nil) && self.alertView.visible) {
		
		[self.alertView dismissWithClickedButtonIndex:-1 animated:NO];
		
	}
	
	self.alertView = nil;
	
	[super dealloc];
	
}

@end
