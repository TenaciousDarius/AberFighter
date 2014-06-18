//
//  GameState.h
//  AberFighter
//
//  Created by wde7 on 04/01/2011.
//  Copyright 2011 William Darius Elphick. All rights reserved.
//
/*
 Singleton class containing data about the app's state for use in the various scenes.
 Also represents a global point of reference for variables which are required by multiple scenes.
 */

#import <Foundation/Foundation.h>

/*
 Enumeration which can take the values kSinglePlayerGame and kMultiplayerGame. Used for identifying
 the game type when in various scenes.
 */
typedef enum GameTypes {
	
	kSinglePlayerGame,
	kMultiplayerGame
	
} GameType;

/*
 Enumeration which can take several values which indicate the game's current state.
 */
typedef enum States {
	
	kGameNotStarted,
	kGameDeterminingPlayerIDs,
	kGameSettingGameOptions,
	kGameStarting,
	kGameRunning,
	kGamePaused,
	kGameOver
	
} State;

@interface GameState : NSObject {
	
	/*
	 Indicates whether the game is single or multiplayer.
	 */
	GameType gameType;
	/*
	 Indicates the current state of the game e.g. running, paused etc.
	 */
	State currentState;
	/*
	 This int holds the game length chosen by the user in the GameOptionsLayer.
	 */
	int gameLength;
	/*
	 Calibrated x position for the Accelerometer input. Located here so that it can be used in 
	 both the GameOptionsLayer and the ActionLayer.
	 */
	double calibratedPosition;
	/*
	 Identifies the accelerometer control method which should be used in the ActionLayer. Control scheme
	 1 is the default. Control scheme 2 is only available in single player. 
	 */
	int accelerometerControlMethod;
	
	/*
	 Current score of players 1 and 2. Located here so that the information can be used in the MultilayerGameScene 
	 and the GameOverLayer.	 
	 */
	int player1Score;
	int player2Score;

}

/*
 Property declarations for the instance variables.
 */
@property (nonatomic,readwrite,assign) GameType gameType;
@property (nonatomic,readwrite,assign) State currentState;
@property (nonatomic,readwrite,assign) int gameLength;
@property (nonatomic,readwrite,assign) int accelerometerControlMethod;
@property (nonatomic,readwrite,assign) double calibratedPosition;
@property (nonatomic,readwrite,assign) int player1Score;
@property (nonatomic,readwrite,assign) int player2Score;

/*
 GameState is a singleton. This method instantiates the singleton if this hasn't 
 been done previously and returns a reference to it.
 */
+ (GameState *)sharedState;

/*
 Reset the game state to it's initial configuration. The scores of both players are set to 0.
 The initial GameState is GameNotStarted. The accelerometer control method is set to 1 by default.
 The gameLength is not reset because the SinglePlayerOptionsLayer remembers the length of previous games.
 */
- (void)reset;

/*
 The game length is not reset with the rest of the state because users want the GameOptionsLayer to
 remember the length of the previous game. It is reset during multiplayer games to ensure consistency
 between both devices. 
 */
- (void)resetGameLength;

/*
 This method adds the points specified to the correct player score variable.
 */
- (void)rewardPlayer:(int)player points:(int)points;

@end
