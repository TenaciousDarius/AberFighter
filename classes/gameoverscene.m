//
//  GameOverScene.m
//  AberFighter
//
//  Created by wde7 on 06/04/2011.
//  Copyright 2011 William Darius Elphick. All rights reserved.
//

#import "GameOverScene.h"
#import "GameState.h"
#import "AberFighterAppDelegate.h"
#import "BluetoothCommsManager.h"

#pragma mark -
#pragma mark GameOverLayer

@implementation GameOverLayer

#pragma mark -
#pragma mark Synthesized Properties and Constants

@synthesize alertView;

NSString *const SinglePlayerDescription = @"Your final score is:";
NSString *const DrawEnding = @"This game is a draw!!";
NSString *const VictoryEnding = @"You Win!!";
NSString *const DefeatEnding = @"You Lose!!";

#pragma mark -
#pragma mark GameOverLayer Initializers

/*
 Static scene initializer.
 */
+ (id)scene {
	
	CCScene *scene = [CCScene node];
	id node = [GameOverLayer node];
	[scene addChild:node];
	
	return scene;
	
}

/*
 This method will set up the text which is shown on the results view depending on the game type 
 and in the case of multiplayer whether the player won or lost.
 */
- (void)setUpResultLabels {
	
	GameState *currentGameState = [GameState sharedState];
	CGSize winSize = [CCDirector sharedDirector].winSize;
	
	//Add a title to the Game Options window.
	static int MAIN_TITLE_TOP_MARGIN = 13;
	
	//Add a title to the view.
	CCLabel *titleLabel = [CCLabel labelWithString:@"RESULTS" fontName:@"Arial" fontSize:40];
	titleLabel.position = ccp((winSize.width / 2), 
							  winSize.height - ((titleLabel.contentSize.height/2) + MAIN_TITLE_TOP_MARGIN));
	[self addChild:titleLabel];
	
	/*
	 The description is set dependant on the situation:
	 */
	NSString *description; 

	if (currentGameState.gameType == kSinglePlayerGame) {
		
		/*
		 During singe player gameplay the "Your final score is:" message is used.
		 */
		description = SinglePlayerDescription;
		
	} else {
		
		if (currentGameState.player1Score == currentGameState.player2Score) {
			
			/*
			 In a tied multiplayer game the message is "This game is a draw".
			 */
			description = DrawEnding;
			
		} else if (currentGameState.player1Score > currentGameState.player2Score) {
			
			/*
			 The rest of these conditionals work out which player won and which lost and apply 
			 the relevant description value.
			 */
			if ([BluetoothCommsManager sharedInstance].playerID == kPlayer1) {
				
				description = VictoryEnding;
					
			} else {
			
				description = DefeatEnding;
			}
			
		} else {
			
			if ([BluetoothCommsManager sharedInstance].playerID == kPlayer1) {
				
				description = DefeatEnding;
				
			} else {
				
				description = VictoryEnding;
			}
			
		}
	}
	
	/*
	 A label is created with the relevant description and added to the layer.
	 */
	CCLabel *descriptionLabel = [CCLabel labelWithString:description fontName:@"Arial" fontSize:30];
	descriptionLabel.position = ccp((winSize.width / 2), 
									titleLabel.position.y - 
									((descriptionLabel.contentSize.height/2) + winSize.height/8));
	[self addChild:descriptionLabel];
	
	/*
	 A label is created with player 1's score and it is added to the layer.
	 */
	NSString *player1ScoreString = [NSString stringWithFormat:@"Player 1: %d points", currentGameState.player1Score];
	CCLabel *player1Score = [CCLabel labelWithString:player1ScoreString fontName:@"Arial" fontSize:30];
	player1Score.position = ccp((winSize.width / 2), 
								descriptionLabel.position.y - 
								((player1Score.contentSize.height/2) + winSize.height/8));
	[self addChild:player1Score];
	
	/*
	 If the game is multiplayer another label is created for player 2's score and added to the layer.
	 */
	if (currentGameState.gameType == kMultiplayerGame) {
		
		NSString *player2ScoreString = [NSString stringWithFormat:@"Player 2: %d points", currentGameState.player2Score];
		CCLabel *player2Score = [CCLabel labelWithString:player2ScoreString fontName:@"Arial" fontSize:30];
		player2Score.position = ccp((winSize.width / 2), 
									player1Score.position.y - 
									((player2Score.contentSize.height/2) + winSize.height/8));
		[self addChild:player2Score];
		
	}
	
}

/*
 This method creates a CCMenuItem given the names of the sprites representing it's normal and selected states
 and the method which should be called when the button is pressed.
 */
- (id)createMenuItemWithNormalFrameName:(NSString *)normalFrameName selectedFrameName:(NSString *)selectedFrameName selector:(SEL)selector {
	
	CCSprite *normalSprite = [CCSprite spriteWithSpriteFrameName:normalFrameName];
	CCSprite *selectedSprite = [CCSprite spriteWithSpriteFrameName:selectedFrameName];
	return [CCMenuItemSprite itemFromNormalSprite:normalSprite 
								   selectedSprite:selectedSprite
										   target:self
										 selector:selector];
	
}

//This method initializes the 2 buttons shown on the scene, arranges them into a menu and adds them to the layer.
- (void)setUpMenu {
	
	CGSize winSize = [CCDirector sharedDirector].winSize;
	
	CCMenuItem *menuItem1 = [self createMenuItemWithNormalFrameName:@"replay_button.png" 
												  selectedFrameName:@"replay_button_selected.png" 
														   selector:@selector(menuItemPressed:)];
	menuItem1.tag = 1;
	
	CCMenuItem *menuItem2 = [self createMenuItemWithNormalFrameName:@"main_menu_button.png" 
												  selectedFrameName:@"main_menu_button_selected.png" 
														   selector:@selector(menuItemPressed:)];
	menuItem2.tag = 2;
	
	CCMenu *menu = [CCMenu menuWithItems:menuItem1, menuItem2, nil];
	[menu alignItemsHorizontallyWithPadding:50];
	menu.position = ccp(winSize.width / 2.0f, winSize.height / 9.0f);
	[self addChild:menu];
	
}

/*
 Initializer of this layer. Creates an instance of the layer by calling the superclass init method
 and adds the required components to it.
 */
- (id)init {

	if ((self = [super init])) {
		
		//Add the main background to the scene
		CGSize winSize = [CCDirector sharedDirector].winSize;
        CCSprite *mainBackground = [CCSprite spriteWithSpriteFrameName:@"main_menu_background.png"];
        mainBackground.position = ccp(winSize.width/2, winSize.height/2);
        [self addChild:mainBackground];
		
		/*
		 Call setUpResultLabels to add the text to the layer.
		 */
		[self setUpResultLabels];
		
		/*
		 Call setUpMenu to add buttons to the layer.
		 */
		[self setUpMenu];
		
	}
	
	return self;
}

#pragma mark -
#pragma mark Menu Related Methods

/*
 Called when the AlertView is dismissed or the main menu button is pressed. 
 */
- (void)cancelMultiplayerGame {
	
	/*
	 Reset the gameLength for the next game.
	 */
	[[GameState sharedState] resetGameLength];
	
	/*
	 Clear up the bluetooth session and call the launchMainMenu method on the app delegate.
	 */
	AberFighterAppDelegate *delegate = (AberFighterAppDelegate *)[UIApplication sharedApplication].delegate;
	[[BluetoothCommsManager sharedInstance] clearUpSession];
	[delegate launchMainMenu];
	
}

//Called when a button is pressed on the menu. Calls other methods to perform functionality.
- (void) menuItemPressed:(CCMenuItem *) menuItem {
	
	/*
	 Retrieve a pointer to the app delegate.
	 */
	AberFighterAppDelegate *delegate = (AberFighterAppDelegate *)[UIApplication sharedApplication].delegate;
	
	if (menuItem.tag == 1) {
		
		/*
		 Replay button pressed.
		 */
		if ([GameState sharedState].gameType == kSinglePlayerGame) {
			/*
			 New Single Player Game
			 */
			[delegate newSinglePlayerGame];
			
		} else {
			/*
			 New Multiplayer Game.
			 */
			[delegate newMultiplayerGame];
			[delegate showGameOptionsScene];
			
		}

		
	} else if (menuItem.tag == 2) {
		/*
		 Main Menu button pressed. If it's a multiplayer game then a GameCancelledPacket should be sent across the network 
		 and the cancelMultiplayerGame method is called to clear up and show the main menu.
		 */
		if ([GameState sharedState].gameType == kMultiplayerGame) {
			
			[[BluetoothCommsManager sharedInstance] sendGameCancelledPacket];
			[self cancelMultiplayerGame];
			
		} else {
			
			/*
			 During Single Player all there is to do is call launchMainMenu.
			 */
			[delegate launchMainMenu];
			
		}

		
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
			replaceExistingAlert:YES];
	
}

#pragma mark -
#pragma mark BluetoothCommsManager Notification Processing

/*
 Called by the NSNotificationCenter when this class is registered as an observer of the BluetoothCommsManager.
 This method reacts to the notifications posted by the BluetoothCommsManager.
 */
- (void)processBluetoothNotification:(NSNotification *)notification {
	
	if (notification.name == SessionFailedWithError) {
		
		/*
		 Error with session. Show Disconnect Alert which will return the player to the main menu when dismissed.
		 */
		[self showDisconnectAlert];
		
	} else if (notification.name == PeerCancelledGame) {
		
		/*
		 Peer pressed Main Menu button. Show Cancel Alert which will return the local player to the main menu when dismissed.
		 */
		[self showCancelAlert];
		
	} else if (notification.name == PeerWasDisconnected) {
		
		/*
		 Error with session. Show Disconnect Alert which will return the player to the main menu when dismissed.
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
 Called when this class is deallocated. Removes the alertView if it's showing.
 */
- (void)dealloc {
	
	if ((self.alertView != nil) && self.alertView.visible) {
		
		[self.alertView dismissWithClickedButtonIndex:-1 animated:NO];
		
	}
	
	self.alertView = nil;
	
	[super dealloc];
	
}

@end
