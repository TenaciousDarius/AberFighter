//
//  SinglePlayerOptionsLayer.m
//  AberFighter
//
//  Created by wde7 on 23/03/2011.
//  Copyright 2011 William Darius Elphick. All rights reserved.
//

#import "SinglePlayerOptionsScene.h"

/*
 This is the message shown on the layer informing users of the alternative control scheme which is available.
 */
NSString *const AccelerometerMessage = @"Note: Control Scheme 1 is the default. To try an alternative press 2. Press Help on Main Menu for more info.";

@implementation SinglePlayerOptionsLayer

@synthesize controlScheme1Selector;
@synthesize controlScheme2Selector;

/*
 Static scene initializer.
 */
+ (id)scene {
	
	CCScene *scene = [CCScene node];
	id node = [SinglePlayerOptionsLayer node];
	[scene addChild:node];
	
	return scene;
	
}

/*
 Initializer of this layer. Creates an instance of the layer by calling the superclass init method
 and adds the required components to it.
 */
- (id)init {
	
	if ((self = [super init])) {
		
		/*
		 Creates the single player title.
		 */
		[self setUpTitle:@"Game Options - Single Player" shipFrameName:@"ship_1.png" shipRotation:0.0f];
		
		/*
		 Create a game length slider for the player.
		 */
		[self setUpGameLengthSlider];
		
		/*
		 Creates the buttons displayed on the layer.
		 */
		[self setUpMenu];
		
		/*
		 The following set up is related to the alternative control scheme buttons and message, which are
		 only available in single player. This is to avoid having players in multiplayer with different control schemes.
		 */
		
		//Create message label and add it to the layer.
		CCLabel *messageLabel = [CCLabel labelWithString:AccelerometerMessage 
											  dimensions:CGSizeMake(275, 75) 
											   alignment:UITextAlignmentLeft 
												fontName:@"Arial" fontSize:16];
		messageLabel.position = ccp((20 + (messageLabel.contentSize.width / 2)),(background.position.y - (background.contentSize.height / 2.5)));
		[self addChild:messageLabel];
		
		/*
		 Create the 1 and 2 buttons used for selecting a control scheme. These buttons also have a disabled state
		 which is represented by the same image as the selected state. This is used to indicate which control scheme 
		 is currently selected.
		 */
		CCSprite *normalButtonSprite = [CCSprite spriteWithSpriteFrameName:@"1_button.png"];
		CCSprite *selectedButtonSprite = [CCSprite spriteWithSpriteFrameName:@"1_button_selected.png"];
		
		controlScheme1Selector = [CCMenuItemSprite itemFromNormalSprite:normalButtonSprite
														 selectedSprite:selectedButtonSprite 
														 disabledSprite:selectedButtonSprite 
																 target:self 
															   selector:@selector(menuItemPressed:)];
		controlScheme1Selector.tag = 4;
		//Control scheme 1 is the default. Therefore this button is disabled until the second button has been pressed. 
		[controlScheme1Selector setIsEnabled:NO];
		
		normalButtonSprite = [CCSprite spriteWithSpriteFrameName:@"2_button.png"];
		selectedButtonSprite = [CCSprite spriteWithSpriteFrameName:@"2_button_selected.png"];
		
		controlScheme2Selector = [CCMenuItemSprite itemFromNormalSprite:normalButtonSprite
														 selectedSprite:selectedButtonSprite 
														 disabledSprite:selectedButtonSprite 
																 target:self 
															   selector:@selector(menuItemPressed:)];
		controlScheme2Selector.tag = 5;
		
		//Create a menu with the buttons and add it to the bottom of the layer.
		CCMenu *controlSchemeMenu = [CCMenu menuWithItems:controlScheme1Selector, controlScheme2Selector, nil];
		[controlSchemeMenu alignItemsHorizontallyWithPadding:20];
		
		CGSize winSize = [CCDirector sharedDirector].winSize;
		
		controlSchemeMenu.position = ccp((winSize.width - (winSize.width / 5)), 
										 (background.position.y - (background.contentSize.height / 2.75)));
		
		[self addChild:controlSchemeMenu];
		
	}
	
	return self;
	
}

/*
 The ccTouchesBegan and ccTouchesMoved methods are called when the user is touching and dragging
 their finger across the screen. In this situation the app needs to check if the touch is around the area
 where the game length slider is located on the screen. A touch which was detected 
 is passed to the moveSlider method in the superclass which determines if this is true.
 */
- (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	[self moveSlider:[touches anyObject]];
}

- (void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	
	[self moveSlider:[touches anyObject]];
}

/*
 Called when a button on the view is pressed. Overrides the method of the same name located in the GameOptionsLayer class.
 */
- (void) menuItemPressed:(CCMenuItem *) menuItem {
	
	if (menuItem.tag == 4) {
		
		/*
		 Control scheme 1 button pressed. Set control scheme in GameState singleton and change enabled state of buttons.
		 */
		[GameState sharedState].accelerometerControlMethod = 1;
		[self.controlScheme1Selector setIsEnabled:NO];
		[self.controlScheme2Selector setIsEnabled:YES];
		
	} else if (menuItem.tag == 5) {
		
		/*
		 Control scheme 2 button pressed. Set control scheme in GameState singleton and change enabled state of buttons.
		 */
		[GameState sharedState].accelerometerControlMethod = 2;
		[self.controlScheme1Selector setIsEnabled:YES];
		[self.controlScheme2Selector setIsEnabled:NO];
		
	} else {
		
		/*
		 If none of the tags in this method are satisfied, call the superclass menuItemPressed method to try and handle 
		 the MenuItem which has been pressed.
		 */
		[super menuItemPressed:menuItem];
		
	}
	
}

- (void)dealloc {

	controlScheme1Selector = nil;
	controlScheme2Selector = nil;
	[super dealloc];
	
}

@end
