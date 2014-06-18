//
//  ActionScene.h
//  AberFighter
//
//  Created by wde7 on 05/01/2011.
//  Copyright 2011 William Darius Elphick. All rights reserved.
//
/*
 The ActionLayer is where the main game takes place. It contains the main iteration loops which drive the game
 and the sprites which make up the players and targets. This class contains functionality which is common
 to both the SinglePlayerActionLayer and the MultiplayerActionLayer. 
 */

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "DirectionalChangesCalculator.h"
#import "GameState.h"
#import "Ship.h"
#import "PlayerShip.h"
#import "Projectile.h"
#import "ReusableTargetPool.h"
#import "TargetShip.h"

//Defines the y position where the player starts.
#define kPLAYER_START_POSITION	50
//Defines the update interval for the accelerometer.
#define kActionAccelerometerUpdateInterval		(1.0f/40.0f)

/*
 kMaximumSpawnRate is the highest rate at which enemies can spawn. 
 kSpawnRateModifier is used to decrease the spawn rate at the begining
 of the game. The minimum spawn rate is kMaximumSpawnRate + kSpawnRateModifier.
 */
#define kMaximumSpawnRate 0.5
#define kSpawnRateModifier 1.5

#pragma mark -
#pragma mark ActionLayer Interface Declaration

@interface ActionLayer : CCLayer {
	
	/*
	 Container for the sprites which are shown in this view. Used to improve performance 
	 because the sprites contained in a spritesheet will be drawn in 1 OpenGL call rather 
	 than once for each sprite i.e. O(1) rather than O(n).
	 */
	CCSpriteSheet *spriteSheet;
	
	/*
	 The countdown label is shown in the center of the layer when the game starts to
	 count the players in.
	 A CCBitmapFontAtlas allows labels to be updated very fast by drawing text as 
	 an image composed of subimages, representing letters, stored in a BitmapFont.
	 */
	CCBitmapFontAtlas *countdownLabel;
	
	/*
	 This is a pointer to the instance of PlayerShip which represents the local player.
	 It is used for applying input from the accelerometer to it's internal state.
	 */
	PlayerShip *localPlayer;
	
	/*
	 This is an array intended to store the PlayerShip instance of every player in the
	 game. It is used for collision detection and for drawing shields.
	 */
	NSMutableArray *playerShips;
	
	/*
	 This array stores all of the CollidableSprite instances which represent projectiles
	 in the game. Used for collision detection.
	 */
	NSMutableArray *projectiles;
	
	/*
	 This array stores all of the TargetShip instances which are currently active in
	 the ActionLayer. Used for collision detection and for drawing status indicators.
	 */
	NSMutableArray *activeTargets;
	
	/*
	 This boolean indicates if the starting countdown has finished and the game has started.
	 The player can pause the game while the countdown is occuring, so this boolean is used
	 to determine if the game state should change from kGamePaused to either kGameRunning or
	 kGameStarting when the game is resumed.
	 */
	BOOL countdownFinished;
	
	/*
	 This integer records the progress of the starting countdown.
	 */
	int countdown;
	
	/*
	 This integer records the time remaining in the current game. When this number
	 reaches 0 the game ends.
	 */
	int gameTimeRemaining;
	
	/*
	 This variable is used for spawning targets. It is used to determine if the difference
	 between the current time and the previous time when a target was spawned is greater than the 
	 spawn rate.
	 */
	double previousTimeTargetSpawned;
	
	/*
	 This variable is gameTimeRemaining/gameLength. It is used so that targets spawn more
	 often as the game progresses, with the highest spawnrate being near the end of the game.
	 */
	float gameTimeRemainingRatio;

}

#pragma mark -
#pragma mark ActionLayer Property Declaration

/*
 Property declarations for the instance variables.
 */
@property (readonly) CCSpriteSheet *spriteSheet;
@property (readonly) CCBitmapFontAtlas *countdownLabel;
@property (readonly) PlayerShip *localPlayer;
@property (nonatomic, retain) NSMutableArray *playerShips;
@property (nonatomic, retain) NSMutableArray *projectiles;
@property (nonatomic, retain) NSMutableArray *activeTargets;
@property (nonatomic, readwrite, assign) BOOL countdownFinished;
@property (nonatomic, readwrite, assign) int countdown;
@property (nonatomic, readwrite, assign) int gameTimeRemaining;
@property (nonatomic, readwrite, assign) double previousTimeTargetSpawned;
@property (nonatomic, readwrite, assign) float gameTimeRemainingRatio;

#pragma mark -
#pragma mark ActionLayer Public Method Declaration

/*
 Method which initializes and returns a PlayerShip instance based on the parameters passed to it.
 */
- (PlayerShip *)createPlayerShipWithSpriteFrameName:(NSString *)frameName position:(CGPoint)position heading:(float)heading maximumSpeed:(float)maximumSpeed;

/*
 Called by the application delegate when the game is over. Stops the scheduled methods for updating
 the game, stops accelerometer updates and clears up the CollidableSprite instances used during the game.
 Projectiles are released and activeTargets are returned to the ReusableTargetPool.
 */
- (void)clearUpGameComponents;

/*
 Creates a Projectile instance at the specified location, initiates a CCAction sequence to move the projectile to
 the destination point and adds the projectile to the layer.
 */
- (void)fireProjectileWithStartingPosition:(CGPoint)startingPosition destinationPoint:(CGPoint)destinationPoint ship:(PlayerShip *)ship;

/*
 This method is called by the UserInterfaceLayer when a fire button is pressed. It performs the calculations 
 required to find the starting position and destination point of the projectile, which are then passed to the 
 fireProjectileWithStartingPositionDestinationPointShip method.
 */
- (void)fireProjectile;

/*
 Returns a random TargetType, with large ships being less likely to appear than small ones.
 */
- (TargetType)determineSpawnedTargetType;

/*
 Sets the GameState to GameStarting or GameRunning based on the countdownFinished boolean.
 */
- (void)resumeGame;

/*
 Called when the game is ready to begin. Starts the action sequence which runs the countdown.
 */
- (void)startCountdown;

/*
 This method is used to remove a sprite which has reached the end of it's lifetime from the layer.
 */
- (void)clearUpSprite:(id)sender;

/*
 This is the loop which performs collision detection and updates the position of Ships on the layer.
 */
- (void)nextFrame:(ccTime)timeSinceLastCall;

/*
 Called by the gameLogic loop to see if it's time to spawn a new TargetShip instance.
 */
- (void)checkTargetSpawningSituation;

/*
 Called by the gameLogic loop to remove TargetShip instances which have reached the end of their lifetime.
 */
- (void)clearOffscreenTargets;

@end

