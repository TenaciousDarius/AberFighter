//
//  GameOptionLayer.h
//  AberFighter
//
//  Created by wde7 on 23/03/2011.
//  Copyright 2011 William Darius Elphick. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "GameState.h"

//Define the maximum and minimum values of the slider located in the GameOptionsLayer.
#define SLIDER_X_POS_MAX 360.0f
#define SLIDER_X_POS_MIN 120.0f
//Defines the range on the y axis that the slider is positioned in.
#define SLIDER_Y_POS_MAX 220.0f
#define SLIDER_Y_POS_MIN 180.0f
//Defines the update interval for the accelerometer. Not very high it is only being used for calibration.
#define kOptionsAccelerometerUpdateInterval (1.0f/20.0f)

/*
 The GameOptionsLayer class provides functionality which is common to both the SinglePlayer and Multiplayer Options layers.
 It should not be created and shown directly. Instead it's subclasses should be used, which configure and display the components
 defined in this layer as required. For this reason there is no static scene method as is seen in other layers.
 */
@interface GameOptionsLayer : CCLayer {
	
	/*
	 Container for the sprites which are shown in this view. Used to improve performance 
	 because the sprites contained in a spritesheet will be drawn in 1 OpenGL call rather 
	 than once for each sprite i.e. O(1) rather than O(n).
	 */
	CCSpriteSheet *spriteSheet;
	
	//Points to the background image of the view.
    CCSprite *background;
	
	/*
	 BitmapFontAtlas displaying the current game length. Affected by the slider.
	 A CCBitmapFontAtlas allows labels to be updated very fast by drawing text as 
	 an image composed of subimages, representing letters, stored in a BitmapFont.
	 */
	CCBitmapFontAtlas *timeLabel;
	
	//Points to the slider image used for selecting a game length.
	CCSprite *slider;
	
	/*
	 Displays the current calibrated playing angle expressed in degrees.
	 */
	CCBitmapFontAtlas *angleLabel;
	
	//Used for calibrating the accelerometer. Updated each time the accelerometer fires.
	double currentXAcceleration;
	
	//Boolean which determines whether the accelerometer should be automatically calibrated.
	BOOL calibrated;
	
	/*
	 Pointers to the Start Game and Calibrate Button, which need to be made invisible in some circumstances
	 on the MultiplayerOptionsLayer.
	 */
	CCMenuItem *startGameButton;
	CCMenuItem *calibrateButton;
}

/*
 Property declarations for the instance variables. Most of the variables are cocos2D components
 and therefore the properties are readonly pointers.
 */
@property (readonly) CCSpriteSheet *spriteSheet;
@property (readonly) CCSprite *background;
@property (readonly) CCBitmapFontAtlas *timeLabel;
@property (readonly) CCSprite *slider;
@property (readonly) CCBitmapFontAtlas *angleLabel;
@property (readonly) CCMenuItem *startGameButton;
@property (readonly) CCMenuItem *calibrateButton;
@property (nonatomic,readwrite,assign) double currentXAcceleration;
@property (nonatomic,readwrite,assign) BOOL calibrated;

/*
 Creates the title shown at the top of the layer with a ship image next to it. The intention of this 
 is that the title indicates the player ID of the local player on the device and shows the PlayerShip 
 which will represent them during the game.
 */
- (void)setUpTitle:(NSString *)titleText shipFrameName:(NSString *)spriteFrameName shipRotation:(float)shipRotation;

/*
 Creates a game length slider under the title of the view. SinglePlayerOptionsLayer shows this, as does the 
 MultiplayerOptionsLayer for Player 1. 
 */
- (void)setUpGameLengthSlider;

/*
 Set up the calibrate, start game and cancel buttons.
 */
- (void)setUpMenu;

/*
 Called by the moveSlider method. Used to update the gameLength variable in the GameState singleton and
 the timeLabel on the layer.
 */
- (void)updateGameLength:(int)newGameLength;

/*
 Called when a touch is detected on the view. Moves the game length slider if the touch was in the correct location
 and then calls updateGameLength. 
 */
- (void)moveSlider:(UITouch *)touch;

/*
 Called when the accelerometerDidAccelerate method in this class is called for the first time and when the Calibrate 
 button is pressed. Sets the calibratedPosition variable in the GameState singleton to the value in the currentXAcceleration
 variable.
 */
- (void)calibrateAccelerometer;

/*
 Called when a button is pressed in the layer. Public so that it can be overridden in the subclasses.
 */
- (void) menuItemPressed:(CCMenuItem *) menuItem;

@end

