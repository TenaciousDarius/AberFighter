//
//  PauseMenuScene.m
//  AberFighter
//
//  Created by wde7 on 14/02/2011.
//  Copyright 2011 William Darius Elphick. All rights reserved.
//


#import "PauseMenuScene.h"
#import "AberFighterAppDelegate.h"

#pragma mark -
#pragma mark QuitConfirmationLayer

@implementation QuitConfirmationLayer

#pragma mark -
#pragma mark QuitConfirmationLayer Synthesized Properties

@synthesize background; //Points to the background image of view. 

#pragma mark -
#pragma mark QuitConfirmationLayer Initializers

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
	
	CCMenuItem *menuItem1 = [self createMenuItemWithNormalFrameName:@"quit_button.png" 
												  selectedFrameName:@"quit_button_selected.png" 
														   selector:@selector(menuItemPressed:)];
	menuItem1.tag = 1;
	
	CCMenuItem *menuItem2 = [self createMenuItemWithNormalFrameName:@"cancel_button.png" 
												  selectedFrameName:@"cancel_button_selected.png" 
														   selector:@selector(menuItemPressed:)];
	menuItem2.tag = 2;
	
	CCMenu *quitConfirmationButtons = [CCMenu menuWithItems:menuItem1, menuItem2, nil];
	[quitConfirmationButtons alignItemsHorizontallyWithPadding:10];
	quitConfirmationButtons.position = ccp(self.background.position.x, (self.background.position.y/1.2));
	[self addChild:quitConfirmationButtons];
	
}

/*
 Initializer of this layer. Creates an instance of the layer by calling the superclass init method
 and adds the required components to it.
 */
- (id)init {
	
	if ((self = [super init])) {
		
		//Add the game options window to the background.
	    CGSize windowSize = [CCDirector sharedDirector].winSize;
        background = [CCSprite spriteWithSpriteFrameName:@"quit_confirmation_background.png"];
        background.position = ccp(windowSize.width / 2, 
								  windowSize.height / 2.4);
        [self addChild:background];
		
		//Call setUpMenu to add the menu buttons to the layer.
		[self setUpMenu];
		
		self.isTouchEnabled = YES;
		
	}
	
	return self;
	
}

#pragma mark -
#pragma mark Quit Confirmation Related Methods

//Called when a button is pressed on the pause menu. Calls other methods to perform functionality.
- (void)menuItemPressed:(CCMenuItem *)menuItem {
	
	/*
	 Retrieve a pointer to the PauseMenuLayer.
	 */
	PauseMenuLayer *parentLayer = (PauseMenuLayer *)self.parent;
	
	if (menuItem.tag == 1) {
		/*
		 Quit Game button pressed. Remove this layer by calling the hideQuitConfirmation
		 method in the PauseMenuLayer then call the quitGamePressed method in the PauseMenuLayer.
		 */
		[parentLayer hideQuitConfirmation];
		[parentLayer quitGamePressed];
		
	} else if (menuItem.tag == 2) {
		/*
		 Cancel button pressed. Remove this layer by calling the hideQuitConfirmation
		 method in the PauseMenuLayer.
		 */
		[parentLayer hideQuitConfirmation];
		
	}
	
	
}

#pragma mark -
#pragma mark QuitConfirmationLayer Superclass Overrides

/*
 Called when the layer is deallocated. Sets the weak pointers used for referencing cocos2D
 components to nil and then calls super dealloc. Releasing cocos2D components happens automatically
 when their parent CCNode is released.
 */
- (void)dealloc {

	background = nil;
	[super dealloc];
	
}

@end

#pragma mark -
#pragma mark PauseMenuLayer

@implementation PauseMenuLayer

#pragma mark -
#pragma mark PauseMenuLayer Synthesized Properties

@synthesize spriteSheet; 
@synthesize background; 
@synthesize pauseMenuButtons; 
@synthesize quitConfirmationLayer; 


#pragma mark -
#pragma mark PauseMenuLayer Initializers

+ (id)scene {
	
	CCScene *scene = [CCScene node];
	id node = [PauseMenuLayer node];
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

/*
 This method initializes the 3 buttons shown on the layer using the createMenuItem method above, 
 arranges them into a menu and adds them to the layer.
 */
- (void)setUpMenu {
	
	CCMenuItem *menuItem1 = [self createMenuItemWithNormalFrameName:@"resume_button.png" 
												  selectedFrameName:@"resume_button_selected.png" 
														   selector:@selector(menuItemPressed:)];
	menuItem1.tag = 1;
	
	CCMenuItem *menuItem2 = [self createMenuItemWithNormalFrameName:@"help_button.png" 
												  selectedFrameName:@"help_button_selected.png" 
														   selector:@selector(menuItemPressed:)];
	menuItem2.tag = 2;
	
	CCMenuItem *menuItem3 = [self createMenuItemWithNormalFrameName:@"quit_button.png" 
												  selectedFrameName:@"quit_button_selected.png" 
														   selector:@selector(menuItemPressed:)];
	menuItem3.tag = 3;
	
	pauseMenuButtons = [CCMenu menuWithItems:menuItem1, menuItem2, menuItem3, nil];
	[pauseMenuButtons alignItemsVerticallyWithPadding:5];
	pauseMenuButtons.position = ccp(self.background.position.x, (self.background.position.y));
	[self addChild:pauseMenuButtons];
	
}

/*
 Initializer of this layer. Creates an instance of the layer by calling the superclass init method
 and adds the required components to it.
 */
- (id)init {
	
	if ((self = [super init])) {
		
		/*
		 Create a spritesheet based on the sprites.png texture and add it to the scene. Because this image has already been loaded 
		 into the CCTextureCache during the loading process a reference is passed to the existing texture.
		 */
		spriteSheet = [CCSpriteSheet spriteSheetWithTexture:[[CCTextureCache sharedTextureCache] addImage:@"sprites.png"]];
        [self addChild:spriteSheet];
		
		//Add the pause window to the background. Uses the same frame image as the GameOptionsLayer.
		CGSize windowSize = [CCDirector sharedDirector].winSize;
        background = [CCSprite spriteWithSpriteFrameName:@"sub_menu_background.png"];
        background.position = ccp(windowSize.width/2, windowSize.height/2);
        [spriteSheet addChild:background];
		
		// Add title to scene
		static int MAIN_TITLE_TOP_MARGIN = 13;
		CGSize pauseWindowSize = background.contentSize;
		CCSprite *pauseMenuTitle = [CCSprite spriteWithSpriteFrameName:@"pause_menu.png"];
		pauseMenuTitle.position = ccp(background.position.x, (background.position.y + 
															  ((pauseWindowSize.height/2) - 
															   (pauseMenuTitle.contentSize.height/2)) - 
															  MAIN_TITLE_TOP_MARGIN));
		[spriteSheet addChild:pauseMenuTitle];
		
		//Call setUpMenu to add the menu buttons to the layer.
		[self setUpMenu];
		
		self.isTouchEnabled = YES;
		
	}
	
	return self;
	
}

#pragma mark -
#pragma mark PauseMenuLayer Superclass Overrides

/*
 Called when the layer is deallocated. Sets the weak pointers used for referencing cocos2D
 components to nil and then calls super dealloc. Releasing cocos2D components happens automatically
 when their parent CCNode is released.
 */
- (void)dealloc {
	
	spriteSheet = nil;
	background = nil;
	pauseMenuButtons = nil;
	quitConfirmationLayer = nil;
	[super dealloc];
	
}

#pragma mark -
#pragma mark Pause Menu Related Methods

/*
 Called when the Quit Game button is pressed. Disables touches on the Pause Menu and shows the
 QuitConfirmationLayer.
 */
- (void)showQuitConfirmation {
	
	[self.pauseMenuButtons setIsTouchEnabled:NO]; 
	[self setIsTouchEnabled:NO];
	quitConfirmationLayer = [QuitConfirmationLayer node];
	[self addChild:quitConfirmationLayer];
	
}

/*
 Called by the QuitConfirmationLayer when the Cancel button is pressed to hide the QuitConfirmationLayer
 and re-enable touch on the Pause Menu layer.
 */
- (void)hideQuitConfirmation {
	
	[self removeChild:quitConfirmationLayer cleanup:YES];
	quitConfirmationLayer = nil;
	[self.pauseMenuButtons setIsTouchEnabled:YES];
	[self setIsTouchEnabled:YES];
	
}

- (void)resumeGame {
	
	/*
	 Resume button pressed. Call the app delegate to resume the game by removing the PauseMenuLayer.
	 */
	AberFighterAppDelegate *delegate = (AberFighterAppDelegate *) [UIApplication sharedApplication].delegate;
	[delegate hidePauseMenu];
	
}

/*
 Called from the QuitConfirmationLayer when the Quit Game button is pressed. Calls hideQuitConfirmation
 above then notifies the App delegate to end the game.
 */
- (void)quitGame {
	
	AberFighterAppDelegate *delegate = (AberFighterAppDelegate *) [UIApplication sharedApplication].delegate;
	[delegate quitGame];
	
}

/*
 Called from the QuitConfirmationLayer when the Quit Game button is pressed.
 */
- (void)quitGamePressed {
	
	[self quitGame];
	
}

//Called when a button is pressed on the pause menu. Calls other methods to perform functionality.
- (void)menuItemPressed:(CCMenuItem *)menuItem {
	
	if (menuItem.tag == 1) {
		
		/*
		 Resume button pressed, call resumeGame to hide the pause menu layer.
		 */
		[self resumeGame];
		
	} else if (menuItem.tag == 2) {
		
		/*
		 Help button pressed. Call the app delegate to show the instructions layer.
		 */
		AberFighterAppDelegate *delegate = (AberFighterAppDelegate *) [UIApplication sharedApplication].delegate;
		[delegate showInstructions]; 
		
	} else if (menuItem.tag == 3) {
		
		/*
		 Quit button pressed.
		 */
		[self showQuitConfirmation];
		
	}
	
}

@end

