//
//  GameState.m
//  AberFighter
//
//  Created by wde7 on 04/01/2011.
//  Copyright 2011 William Darius Elphick. All rights reserved.
//

#import "GameState.h"

@implementation GameState

/*
 Automatically generates the getter and setter methods for the properties defined in the header file.
 */
@synthesize gameType; 
@synthesize currentState; 
@synthesize gameLength; 
@synthesize calibratedPosition;
@synthesize accelerometerControlMethod;
@synthesize player1Score;
@synthesize player2Score;

/*
 Singleton of this class.
 */
static GameState *sharedState = nil; 

//Static Singleton accessor.
+ (GameState *)sharedState {

	if (!sharedState) {
		sharedState = [[GameState alloc] init];
	}
	
	return sharedState;
}

/*
 Initializer method. Creates an instance of this class and returns a reference to the class.
 */
- (id)init {
	
	if ((self = [super init])) {
		
		calibratedPosition = 0.0;
		[self reset];
		[self resetGameLength];
		
	}
	
	return self;
	
}

/*
 Set the game length to the default, 120 seconds.
 */
- (void)resetGameLength {
	
	self.gameLength = 120;
	
}

/*
 Resets the GameState singleton. Performed when a new game is being created.
 */
- (void)reset {
	
	self.player1Score = 0;
	self.player2Score = 0;
	self.currentState = kGameNotStarted;
	self.accelerometerControlMethod = 1;
	
}

/*
 Adds the reward specified in the parameters to the player with the specified parameter. 
 */
- (void)rewardPlayer:(int)player points:(int)points {

	if (player == 1) {
		
		self.player1Score = self.player1Score + points;
		
	} else if (player == 2) {
		
		self.player2Score = self.player2Score + points;
		
	}

}

/*
 Dealloc is only called when the application terminates, due to this class being a singleton.
 The singleton pointer is set to nil.
 */
- (void)dealloc {
	
	sharedState = nil;
	[super dealloc];
	
}

@end
