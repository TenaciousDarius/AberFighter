//
//  MultiplayerPauseMenuScene.m
//  AberFighter
//
//  Created by wde7 on 08/04/2011.
//  Copyright 2011 William Darius Elphick. All rights reserved.
//

#import "MultiplayerPauseMenuScene.h"
#import "AberFighterAppDelegate.h"
#import "BluetoothCommsManager.h"
#import "GameState.h"

#pragma mark -
#pragma mark MultiplayerPauseMenuLayer

@implementation MultiplayerPauseMenuLayer

#pragma mark -
#pragma mark Synthesized Properties

@synthesize player1ReadyLabel;
@synthesize player2ReadyLabel;
@synthesize localPlayerReady;
@synthesize peerReady;
@synthesize alertView;

#pragma mark -
#pragma mark MultiplayerPauseMenuLayer Initializers

/*
 Static scene initializer.
 */
+ (id)scene {
	
	CCScene *scene = [CCScene node];
	id node = [MultiplayerPauseMenuLayer node];
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
									 (background.position.y - (background.contentSize.height / 2.5)));
	[self addChild:player1ReadyLabel];
	
	player2ReadyLabel = [CCLabel labelWithString:@"Player 2 Ready" fontName:@"Arial" fontSize:24];
	player2ReadyLabel.color = ccc3(255, 0, 0);
	player2ReadyLabel.opacity = 180.0;
	player2ReadyLabel.position = ccp((background.position.x + (background.contentSize.width / 4.5)), 
									 (background.position.y - (background.contentSize.height / 2.5)));
	[self addChild:player2ReadyLabel];
	
}

/*
 Initializer of this layer. Creates an instance of the layer by calling the superclass init method
 and adds the required components to it.
 */
- (id)init {

	if ((self = [super init])) {
		
		/*
		 [super init] creates the background and menu buttons. setUpReadyLabels adds the status indicators 
		 needed on the multiplayer version of the pause menu. 
		 */
		[self setUpReadyLabels];
		
		/*
		 Both players are initially not ready.
		 */
		localPlayerReady = NO;
		peerReady = NO;
		
	}
	
	return self;
	
}


#pragma mark -
#pragma mark Menu Related Methods

/*
 This method is called when the Resume button is pressed. It calls the sendPeerResumedGamePacket method
 in the BluetoothCommsManager to alert the peer device that this device is ready to resume.
 */
- (void)alertPeerReadyToResume {
	
	[[BluetoothCommsManager sharedInstance] sendPeerResumedGamePacket];
	
}

/*
 Overrides the quitGamePressed method in the PauseMenuLayer. Calls the sendPeerQuitGamePacket method
 in the BluetoothCommsManager to alert the peer device that this device has quit. It then calls quitGame to
 transition to the GameOverLayer.
 */
- (void)quitGamePressed {
		
	[[BluetoothCommsManager sharedInstance] sendPeerQuitGamePacket];
	
	[self quitGame];
	
}

/*
 Called when a button is pressed on the view. Overrides the method with the same name in the PausMenuLayer.
 */
- (void)menuItemPressed:(CCMenuItem *)menuItem {
	
	if (menuItem.tag == 1) {
		
		/*
		 Resume button pressed. Render the Resume and Help buttons invisible to prevent the user from sending 
		 two resume messages or leaving the pause menu layer (without quitting). 
		 */
		[self alertPeerReadyToResume];
		
		[pauseMenuButtons getChildByTag:1].visible = NO;
		[pauseMenuButtons getChildByTag:2].visible = NO;
		
		/*
		 Update the colour of the correct player status indicator.
		 */
		if ([BluetoothCommsManager sharedInstance].playerID == kPlayer1) {
			
			self.player1ReadyLabel.opacity = 255.0;
			self.player1ReadyLabel.color = ccc3(0.0, 255.0, 0.0);
			
		} else {
			
			self.player2ReadyLabel.opacity = 255.0;
			self.player2ReadyLabel.color = ccc3(0.0, 255.0, 0.0);
			
		}
		
	} else {
		
		/*
		 If the tag in this method is not satisfied, call the superclass menuItemPressed method to try and handle 
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
 Called by the AlertView when it is dismissed with the button. Calls the abortActiveMultiplayerGame method in the
 app delegate to clear up the game session and return the user to the main menu.
 */
- (void)cancelMultiplayerGame {
	
	/*
	 Retrieve a pointer to the MainMenuLayer.
	 */
	AberFighterAppDelegate *delegate = (AberFighterAppDelegate *)[UIApplication sharedApplication].delegate;
	[delegate abortActiveMultiplayerGame];
	
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
 This method is used to identify when the game should resume.
 It makes use of the peerReady and localPlayerReady booleans. The local player readiness indicator is
 changed straight away when the Resume button is pressed. 
 peerReady is set when the relevant packets are received across the network 
 (see processBluetoothNotification method).
 */
- (void)updateReadyState {
	
	/*
	 The localPlayerID is used to identify which readyLabel represents this device and which is the peer.
	 */
	int localPlayerID = [BluetoothCommsManager sharedInstance].playerID;
	
	/*
	 Update the peer player's readiness indicator. 
	 */
	if (self.peerReady && localPlayerID == kPlayer2) {
		
		self.player1ReadyLabel.opacity = 255.0;
		self.player1ReadyLabel.color = ccc3(0.0, 255.0, 0.0);
		
	} 
	
	if (self.peerReady && localPlayerID == kPlayer1) {
		
		self.player2ReadyLabel.opacity = 255.0;
		self.player2ReadyLabel.color = ccc3(0.0, 255.0, 0.0);
		
	}
	
	/*
	 If both players are ready then call resumeGame to remove the PauseMenuLayer.
	 */
	if (self.localPlayerReady && self.peerReady) {
		
		[self resumeGame];
		
	}
	
}

/*
 Called by the NSNotificationCenter when this class is registered as an observer of the BluetoothCommsManager.
 This method reacts to the notifications posted by the BluetoothCommsManager.
 */
- (void)processBluetoothNotification:(NSNotification *)notification {
	
	if (notification.name == PeerResumedGame) {
		
		/*
		 Peer player has pressed resume on the pause menu. Set peerReady to true, send an acknowledgement
		 that the message has been received and call the updateReadyState method above.
		 */		
		peerReady = YES;
		[[BluetoothCommsManager sharedInstance] sendAcknowledgePeerResumedGamePacket];
		[self updateReadyState];
		
	} else if (notification.name == PeerResumedGameAcknowledged) {
		
		/*
		 Peer has acknowledged that the local player has resumed the game. Set localPlayerReady to true and
		 call updateReadyState.
		 */
		localPlayerReady = YES;
		[self updateReadyState];
		
	} else if (notification.name == PeerQuitGame) {
		
		/*
		 Peer has quit the game. Call quitGame to show the GameOverLayer.
		 */
		[self quitGame];
		
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
- (void)onEnter {
	
	[super onEnter];
	
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(processBluetoothNotification:) 
												 name:nil 
											   object:[BluetoothCommsManager sharedInstance]];
	
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
 Called when this class is deallocated. Sets pointers to cocos2D components to nil and 
 removes the alertView if it's showing.
 */
- (void) dealloc {
	
	player1ReadyLabel = nil;
	player2ReadyLabel = nil;
	
	if ((self.alertView != nil) && self.alertView.visible) {
		
		[self.alertView dismissWithClickedButtonIndex:-1 animated:NO];
		
	}
	
	self.alertView = nil;	
	
	[super dealloc];
	
}

@end
