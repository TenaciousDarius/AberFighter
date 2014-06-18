//
//  MainMenu.m
//  AberFighter
//
//  Created by wde7 on 01/01/2011.
//  Copyright 2011 William Darius Elphick. All rights reserved.
//

#import "MainMenuScene.h"
#import "AberFighterAppDelegate.h"
#import "BluetoothCommsManager.h"

#pragma mark -
#pragma mark MainMenuLayer

@implementation MainMenuLayer

#pragma mark -
#pragma mark MainMenuLayer Synthesized Properties


/*
 Automatically generate the getters for these properties.
 */
@synthesize spriteSheet;
@synthesize mainMenu;

#pragma mark -
#pragma mark MainMenuLayer Initializers

/*
 Static scene initializer.
 */
+ (id)scene {
	
	CCScene *scene = [CCScene node];
	id node = [MainMenuLayer node];
	[scene addChild:node];
	
	return scene;
	
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

//This method initializes the 3 buttons shown on the scene, arranges them into a menu and adds them to the layer.
- (void)setUpMainMenu {
	
	CCMenuItem *menuItem1 = [self createMenuItemWithNormalFrameName:@"single_player_button.png" 
												  selectedFrameName:@"single_player_button_selected.png" 
														   selector:@selector(menuItemPressed:)];
	menuItem1.tag = 1;
	
	CCMenuItem *menuItem2 = [self createMenuItemWithNormalFrameName:@"multiplayer_button.png" 
												  selectedFrameName:@"multiplayer_button_selected.png" 
														   selector:@selector(menuItemPressed:)];
	menuItem2.tag = 2;
	
	CCMenuItem *menuItem3 = [self createMenuItemWithNormalFrameName:@"help_button.png" 
												  selectedFrameName:@"help_button_selected.png" 
														   selector:@selector(menuItemPressed:)];
	menuItem3.tag = 3;
	
	//The menu is located in the middle of the view.
	mainMenu = [CCMenu menuWithItems:menuItem1, menuItem2, menuItem3, nil];
	[mainMenu alignItemsVertically];
	[self addChild:mainMenu];
	
}

/*
 Initializer of this layer. Creates an instance of the layer by calling the superclass init method
 and adds the required components to it.
 */
- (id)init {
	
	if ((self = [super init])) {
		
		//Create a spritesheet based on the sprites.png texture and add it to the scene. Because this image has already been loaded 
		//into the CCTextureCache during the loading process a reference is passed to the existing texture.
		spriteSheet = [CCSpriteSheet spriteSheetWithTexture:[[CCTextureCache sharedTextureCache] addImage:@"sprites.png"]];
        [self addChild:spriteSheet];
		
		//Add the main background to the spritesheet
		CGSize winSize = [CCDirector sharedDirector].winSize;
        CCSprite *mainBackground = [CCSprite spriteWithSpriteFrameName:@"main_menu_background.png"];
        mainBackground.position = ccp(winSize.width/2, winSize.height/2);
        [spriteSheet addChild:mainBackground];
		
		// Add title to the spritesheet 
		static int MAIN_TITLE_TOP_MARGIN = 13;
		CCSprite *mainTitle = [CCSprite spriteWithSpriteFrameName:@"title.png"];
		mainTitle.position = ccp(winSize.width/2, winSize.height - mainTitle.contentSize.height/2 - MAIN_TITLE_TOP_MARGIN);
		[spriteSheet addChild:mainTitle];
		
		//Calls setUpMainMenu to create the buttons located in the scene.
		[self setUpMainMenu];
		
	}
	
	return self;
	
}

#pragma mark -
#pragma mark Menu Related Methods

/*
 Called when the Single Player Button is pressed. Calls a method in the app delegate
 to configure a single player game and show the SinglePlayerOptionsLayer.
 */
- (void)newSinglePlayerGame {
	
	/*
	 The newSinglePlayerGame method within the application delegate retrieves the GameState
	 singleton and configures it for a single player game. It then shows the SinglePlayerOptionsScene.
	 */
	AberFighterAppDelegate *delegate = (AberFighterAppDelegate *)[UIApplication sharedApplication].delegate;
	[delegate newSinglePlayerGame];
	
}

/*
 Called when the Multiplayer Button is pressed. Registers the main menu to receive notifications
 from the BluetoothCommsManager through the NSNotificationCenter.
 */
- (void)newMultiplayerGame {
	
	/*
	 NSNotificationCenter is an implementation of the Observer design pattern provided by iOS. The main menu is registered
	 to receive NSNotification instances which are posted to the NSNotificationCenter from the BluetoothCommsManager, at
	 which point the processBluetoothNotification is called.
	 */
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(processBluetoothNotification:) 
												 name:nil 
											   object:[BluetoothCommsManager sharedInstance]];
	
	/*
	 Instantiate the peer picker, which is shown on top of the Main Menu with this class as it's delegate. The peer picker
	 searches for and establishes a connection with another device then calls the peerPickerControllerdidConnectPeertoSession
	 method described later in this class.
	 */
	GKPeerPickerController *picker = [[GKPeerPickerController alloc] init];
	picker.delegate = self;
	[picker show];
	
}

//Called when a button is pressed on the main menu. Calls other methods to perform functionality.
- (void) menuItemPressed:(CCMenuItem *) menuItem {
	
	if (menuItem.tag == 1) {
		
		/*
		 Single Player button pressed. Call newSinglePlayerGame to initialize a single player game 
		 and show the GameOptionsLayer.
		 */
		[self newSinglePlayerGame];
		
	} else if (menuItem.tag == 2) {
		
		/*
		 Multiplayer game pressed. Call newMultiplayerGame to initialize a multiplayer game and show the peer picker.
		 */
		[self newMultiplayerGame];
	
	} else if (menuItem.tag == 3) {
	
		/*
		 Help button pressed. Call the showInstructions method within the application delegate
		 to transition into a scene containing the InstructionsLayer.
		 */
		AberFighterAppDelegate *delegate = (AberFighterAppDelegate *) [UIApplication sharedApplication].delegate;
		[delegate showInstructions]; 
		
	}
	
}

#pragma mark -
#pragma mark MainMenuLayer Superclass Overrides

/*
 Called when this layer is displayed. Removes any unused textures from the CCTextureCache in order to reduce the
 risk of memory warnings.
 */
- (void)onEnter {

	[super onEnter];
	[[CCTextureCache sharedTextureCache] removeUnusedTextures];
	
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
 Called when the layer is deallocated. Sets the weak pointers used for referencing 
 cocos2D components to nil and then calls super dealloc. Releasing cocos2D components 
 happens automatically when their parent CCNode is released.
 */
- (void) dealloc {
	
	spriteSheet = nil;
	mainMenu = nil;
	
	[super dealloc];
	
}

#pragma mark -
#pragma mark GameKit Delegate Methods

/*
 Called when the peer picker is cancelled. Releases the picker, notifies the 
 BluetoothCommsManager to clear up the session and removes the main menu layer
 as an observer on the NSNotificationCenter.
 */
- (void)peerPickerControllerDidCancel:(GKPeerPickerController *)picker {

	picker.delegate = nil;
	[picker release];
	
	[[BluetoothCommsManager sharedInstance] clearUpSession];
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
}

/*
 When the peer picker is establishing a connection it requests a GKSession instance
 which must be created by the developer. This method requests that the BluetoothCommsManager 
 set up a new session so that it can be passed to the picker.
 */
- (GKSession *)peerPickerController:(GKPeerPickerController *)picker 
		   sessionForConnectionType:(GKPeerPickerConnectionType)type {
	
	GKSession *session = [[BluetoothCommsManager sharedInstance] setUpNewSession];
	return session;
	
}

/*
 This method is called by the peer picker when it has successfully created a connection to another peer.
 The session is represented by the GKSession instance which is passed in as a parameter. This method
 configures the BluetoothCommsManager using the information received, configures a multiplayer game by
 calling the app delegate and initiates the die roll process for determining player IDs.
 */
- (void)peerPickerController:(GKPeerPickerController *)picker 
			  didConnectPeer:(NSString *)peerID 
				   toSession:(GKSession *)session {
	
	BluetoothCommsManager *manager = [BluetoothCommsManager sharedInstance];

	/*
	 Add the ID of the peer connected to the BluetoothCommsManager's list so that it can send information to them.
	 */
	[manager.peerIDs addObject:peerID]; 
	
	/*
	 The BluetoothCommsManager is set as the delegate and data receive handler of the session in order to receive data 
	 packets sent to the device across the network.
	 */
	session.delegate = manager;
	[session setDataReceiveHandler:manager withContext:NULL];
	
	/*
	 The peer picker is removed from view and released.
	 */
	[picker dismiss];
	picker.delegate = nil;
	[picker release];
	
	/*
	 The newMultiplayerGame method in the app delegate configures the GameState singleton for a multiplayer game.
	 */
	AberFighterAppDelegate *delegate = (AberFighterAppDelegate *)[UIApplication sharedApplication].delegate;
	[delegate newMultiplayerGame];
	
	
	/*
	 The sendNewDieRollPacket method in the BluetoothCommsManager begins the process for determining the player ID 
	 of each device. When this process is finished a DieRollFinished notification is received in the processBluetoothNotification 
	 method of this layer. 
	 */
	[[BluetoothCommsManager sharedInstance] sendNewDieRollPacket];
	
}

/*
 Displays a UIAlertView on top of the layer with the specified title and message.
 */
- (void)showAlertViewWithTitle:(NSString *)title message:(NSString *)message {

	 UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
													 message:message
													delegate:self 
										   cancelButtonTitle:@"OK" 
										   otherButtonTitles:nil];
	 [alert show];
	 [alert release];
	
}
	 
/*
 Called by the NSNotificationCenter when this class is registered as an observer of the BluetoothCommsManager.
 This method reacts to the notifications posted by the BluetoothCommsManager.
 */
- (void)processBluetoothNotification:(NSNotification *)notification {
	 
	/*
	 A SessionFailedWithError notification is a fatal occurence for the bluetooth connection.
	 An alert is shown to the user explaining the situation and then the main menu is removed as an observer.
	 The same goes for the PeerWasDisconnected notification.
	 */
	 if(notification.name == SessionFailedWithError) {
		 
		 [self showAlertViewWithTitle:@"Connection Error" 
							  message:@"Failed to establish a connection."];
		 [[NSNotificationCenter defaultCenter] removeObserver:self];
		 
	 } else if(notification.name == PeerWasDisconnected) {
		 
		 [self showAlertViewWithTitle:@"Connection Error" 
							  message:@"The connection has been lost."];
		 [[NSNotificationCenter defaultCenter] removeObserver:self];
		 
	 } else if(notification.name == DieRollFinished) {
		 
		 /*
		  This notification indicates that the die roll process is now complete and the device has a playerID. 
		  Therefore the showGameOptionsScene method is called to show the MultiplayerGameOptionsLayer.
		  */
		 AberFighterAppDelegate *delegate = (AberFighterAppDelegate *)[UIApplication sharedApplication].delegate;
		 [delegate showGameOptionsScene];
		 
	 }
	
}

@end

