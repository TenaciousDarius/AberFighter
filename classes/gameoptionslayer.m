//
//  GameOptionLayer.m
//  AberFighter
//
//  Created by wde7 on 23/03/2011.
//  Copyright 2011 William Darius Elphick. All rights reserved.
//

#import "GameOptionsLayer.h"
#import "AberFighterAppDelegate.h"

#pragma mark -
#pragma mark GameOptionsLayer

@implementation GameOptionsLayer

#pragma mark -
#pragma mark Synthesized Properties

@synthesize spriteSheet; 
@synthesize background; 
@synthesize timeLabel;  
@synthesize slider; 
@synthesize angleLabel;
@synthesize currentXAcceleration; 
@synthesize calibrated;
@synthesize startGameButton;
@synthesize calibrateButton;

#pragma mark -
#pragma mark Initializers

/*
 Creates a title and a sprite representing the player at the top of the view.
 */
- (void)setUpTitle:(NSString *)titleText shipFrameName:(NSString *)spriteFrameName shipRotation:(float)shipRotation {

	//Add a title to the Game Options window.
	static int MAIN_TITLE_TOP_MARGIN = 35;
	
	float titleYPosition = background.position.y + 
							(background.contentSize.height/2) -
								MAIN_TITLE_TOP_MARGIN;
	 
	CCLabel *titleLabel = [CCLabel labelWithString:titleText fontName:@"Arial" fontSize:30];
	titleLabel.position = ccp(background.position.x - (background.position.x / 10), titleYPosition);
	[self addChild:titleLabel];
	
	CCSprite *playerShipSprite = [CCSprite spriteWithSpriteFrameName:spriteFrameName];
	playerShipSprite.rotation = shipRotation;
	playerShipSprite.position = ccp(titleLabel.position.x + (titleLabel.contentSize.width / 2) + 30, titleYPosition);
	[spriteSheet addChild:playerShipSprite];
	
}

/*
 Creates a slider sprite on top of a sliderBar sprite positioned on the layer.
 */
- (void)setUpGameLengthSlider {
	
	/*
	 Add a slider bar image to the layer.
	 */
	CCSprite *sliderBar = [CCSprite spriteWithSpriteFrameName:@"slider_bar.png"];
	sliderBar.position = ccp(((SLIDER_X_POS_MAX - SLIDER_X_POS_MIN)/2) + SLIDER_X_POS_MIN, 
							 ((SLIDER_Y_POS_MAX - SLIDER_Y_POS_MIN)/2) + SLIDER_Y_POS_MIN);
	[spriteSheet addChild:sliderBar];
	
	/*
	 Add the slider button to the view.
	 */
	slider = [CCSprite spriteWithSpriteFrameName:@"slider.png"];
	slider.position = ccp(([GameState sharedState].gameLength * 2), 
						  ((SLIDER_Y_POS_MAX - SLIDER_Y_POS_MIN)/2) + SLIDER_Y_POS_MIN);
	[spriteSheet addChild:slider];
	
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

//This method initializes the 3 buttons shown on the scene, arranges them into menus and adds them to the layer.
- (void)setUpMenu {
	
	calibrateButton = [self createMenuItemWithNormalFrameName:@"calibrate_button.png" 
											selectedFrameName:@"calibrate_button_selected.png" 
													 selector:@selector(menuItemPressed:)];
	calibrateButton.tag = 1;
	
	CCMenu *calibrateMenu = [CCMenu menuWithItems:calibrateButton, nil];
	calibrateMenu.position = ccp(background.contentSize.width - 
								   (background.position.x / 2), (background.position.y / 1.1));
	[self addChild:calibrateMenu];
	
	startGameButton = [self createMenuItemWithNormalFrameName:@"start_game_button.png" 
											selectedFrameName:@"start_game_button_selected.png" 
													 selector:@selector(menuItemPressed:)];
	startGameButton.tag = 2;
	
	CCMenuItem *cancelButton = [self createMenuItemWithNormalFrameName:@"cancel_button.png" 
												  selectedFrameName:@"cancel_button_selected.png" 
														   selector:@selector(menuItemPressed:)];
	cancelButton.tag = 3;
	
	CCMenu *menu = [CCMenu menuWithItems:startGameButton, cancelButton, nil];
	[menu alignItemsHorizontallyWithPadding:50];
	menu.position = ccp(background.position.x, (background.position.y/1.6));
	[self addChild:menu];
	
}

/*
 Initializer of this layer. Creates an instance of the layer by calling the superclass init method
 and adds the required components to it.
 */
- (id)init {
	
	if ((self = [super init])) {
		
		/*
		 Create a spritesheet based on the sprites.png texture and add it to the scene. Because this image 
		 has already been loaded into the CCTextureCache during the loading process a reference is passed 
		 to the existing texture. If for some reason the texture has been released it will be reloaded. 
		 */
		spriteSheet = [CCSpriteSheet spriteSheetWithTexture:
							[[CCTextureCache sharedTextureCache] addImage:@"sprites.png"]];
        [self addChild:spriteSheet];
		
		CGSize winSize = [CCDirector sharedDirector].winSize;
		
		//Add the Game Options window to the background.
        background = [CCSprite spriteWithSpriteFrameName:@"sub_menu_background.png"];
        background.position = ccp(winSize.width/2, winSize.height/2);
        [spriteSheet addChild:background];
		
		// Add game length label
		CCSprite *gameLengthLabel = [CCSprite spriteWithSpriteFrameName:@"game_length.png"];
		gameLengthLabel.position = ccp((background.position.x/1.5), 
									   (background.position.y + 
										(background.position.y / 1.75)));
		[spriteSheet addChild:gameLengthLabel];
		
		/*
		 Add time label, a CCBitmapFontAtlas. The time label 
		 displays the current game length selected by the user.
		 */
		NSString *timeLabelString = [NSString stringWithFormat:@"%d Seconds", [GameState sharedState].gameLength];
		timeLabel = [CCBitmapFontAtlas bitmapFontAtlasWithString:timeLabelString fntFile:@"labels.fnt"];
		timeLabel.position = ccp((winSize.width - (background.position.x / 1.5)), 
								 (background.position.y + (background.position.y / 1.75)));
		[self addChild:timeLabel];
		
		// Add playing angle text
		CCSprite *playingAngle = [CCSprite spriteWithSpriteFrameName:@"playing_angle.png"];
	    playingAngle.position = ccp((background.position.x/2), (background.position.y / 1.1));
		[spriteSheet addChild:playingAngle];
		
		/*
		 Add playing angle label, also a CCBitmapFontAtlas. It displays the current calibrated position
		 of the accelerometer.
		 */		
		NSString *angleLabelString = [NSString stringWithFormat:@"0.0"];
		angleLabel = [CCBitmapFontAtlas bitmapFontAtlasWithString:angleLabelString fntFile:@"labels.fnt"];
		angleLabel.position = ccp((background.position.x - (background.position.x / 14)), (background.position.y / 1.1));
		[self addChild:angleLabel];
		
		/*
		 The calibrated boolean is initially set to false. When the accelerometerDidAccelerate method
		 below is called for the first time it will automatically calibrate the accelerometer and then set this
		 boolean to false.
		 */
		self.calibrated = NO;
		
		/*
		 The view receives touch delegate events for using the slider.
		 */
		self.isTouchEnabled = YES;
		/*
		 The view receives accelerometer delegate events for calibrating the acceleroemeter.
		 */
		self.isAccelerometerEnabled = YES;
		/*
		 Set how often the accelerometer should update this layer.
		 */
		[[UIAccelerometer sharedAccelerometer] setUpdateInterval:kOptionsAccelerometerUpdateInterval];
	}
	
	return self;
	
}

#pragma mark -
#pragma mark Slider Methods

//Sets the gameLength value in the GameState singleton and updates the view to reflect the change. 
- (void)updateGameLength:(int)newGameLength {
	
	[GameState sharedState].gameLength = newGameLength;
	NSString *timeLabelString = [NSString stringWithFormat:@"%d Seconds", ([GameState sharedState].gameLength)];
	[self.timeLabel setString:timeLabelString];
	
}

/*
 Moves the slider image if the user has touched an area of the screen close to the slider bar.
 Also updates the gameLength saved in the GameState singleton and reflects the change on the time
 label in this layer.
 */
- (void) moveSlider:(UITouch *)touch {
	
		
	CGPoint location = [touch locationInView: [touch view]];
	
	//If the touch was detected within 25 pixels of the slider bar, then the touch is within the slider region. 
	if ((location.x < SLIDER_Y_POS_MAX) && (location.x > SLIDER_Y_POS_MIN)) {
		
		if (location.y > SLIDER_X_POS_MAX) {
			//Slider is at maximum, therefore don't move.
			slider.position = ccp(SLIDER_X_POS_MAX, ((SLIDER_Y_POS_MAX - SLIDER_Y_POS_MIN)/2) + SLIDER_Y_POS_MIN);	
		} else if (location.y < SLIDER_X_POS_MIN) {	
			//Slider is at minimum, therefore don't move.
			slider.position = ccp(SLIDER_X_POS_MIN, ((SLIDER_Y_POS_MAX - SLIDER_Y_POS_MIN)/2) + SLIDER_Y_POS_MIN); 
		} else {
			//Move slider to the current touch location.
			slider.position = ccp(location.y, ((SLIDER_Y_POS_MAX - SLIDER_Y_POS_MIN)/2) + SLIDER_Y_POS_MIN);
		}	
	}
	
	//Updates the gameTimeRemaining variable in the GameState singleton and updates the label on the GameOptionsLayer.
	[self updateGameLength:(slider.position.x / 2)];
		
	
}

#pragma mark -
#pragma mark Accelerometer and Menu Related Methods

/*
 Called when the calibrate button is pressed (and by the accelerometerDidAccelerate method the
 first time it is called). Sets the calibrated position for the app and updates the calibrated label.
 */
- (void) calibrateAccelerometer {
	
	/*
	 Sets the calibratedPosition in the GameState singleton.
	 */
	[[GameState sharedState] setCalibratedPosition:currentXAcceleration];
	
	/*
	 The calibrated boolean is set to true to stop the accelerometerDidAccelerate method from 
	 automatically updating the calibration.
	 */
	self.calibrated = YES;
	
	/*
	 The calibrated position is expressed in degrees to the user. 0 degrees represents the device
	 being held with the screen facing directly up. Values greater than this represent the device 
	 being held with the screen facing the user and values less than this the opposite. The normal
	 range of calibrated position is from -1 to 1, therefore an angle between -90 and 90 degrees is 
	 shown to the user.
	 */
	double angle;
	if ([GameState sharedState].calibratedPosition == 0) {
		angle = [GameState sharedState].calibratedPosition * 90.0;
	} else {
		angle = -([GameState sharedState].calibratedPosition * 90.0);
	}
	
	/*
	 The angle is shown to the user to 1 decimal place.
	 */
	NSString *angleLabelString = [NSString stringWithFormat:@"%.01f", angle];
	[angleLabel setString:angleLabelString];
	
}

/*
 Used for calibrating the accelerometer. The current acceleration along the x axis is stored
 in the currentXAcceleration variable for use in the calibrateAccelerometer method above.
 */
- (void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration {
	
	self.currentXAcceleration = acceleration.x;
	
	/*
	 When the layer is initialized, calibrated == NO. Therefore the accelerometer is automatically 
	 calibrated the first time the accelerometer calls this method. See calibrateAccelerometer for
	 more information.
	 */
	if (self.calibrated == NO) {
		[self calibrateAccelerometer];
	}
	
}

//Called when a button is pressed on the layer.
- (void) menuItemPressed:(CCMenuItem *) menuItem {
	
	/*
	 Retrieve a pointer to the application delegate.
	 */
	AberFighterAppDelegate *delegate = (AberFighterAppDelegate *)[UIApplication sharedApplication].delegate;
	
	if (menuItem.tag == 1) {
		/*
		 Calibrate button pressed. Calibrate the accelerometer and update the playing angle label.
		 */
		[self calibrateAccelerometer];
		
	} else if (menuItem.tag == 2) {
		
		self.isAccelerometerEnabled = NO;
		/*
		 Start Game button pressed. Stop accelerometer updates on this view, then call the startGame method in the 
		 app delegate.
		 */
		[delegate startGame];
		
		
	} else if (menuItem.tag == 3) {
		
		/*
		 Cancel button pressed. Stop accelerometer updates on this view, then call the app delegate to show the 
		 main menu.
		 */
		self.isAccelerometerEnabled = NO;
		[delegate launchMainMenu];
		
	}
	
}

#pragma mark -
#pragma mark Superclass Overrides

/*
 Called when the the layer is shown. Sets the current state of the game to SettingGameOptions.
 */
- (void) onEnter {

	[super onEnter];
	[GameState sharedState].currentState = kGameSettingGameOptions;
	
}

/*
 Called when the layer is deallocated. Sets the weak pointers used for referencing 
 cocos2D components to nil and then calls super dealloc. Releasing cocos2D components
 happens automatically when their parent CCNode is released.
 */
- (void) dealloc {
	
	spriteSheet = nil;
    background = nil;
	timeLabel = nil;
	slider = nil;
	angleLabel = nil;
	startGameButton = nil;
	calibrateButton = nil;
	
	[super dealloc];
	
}

@end



