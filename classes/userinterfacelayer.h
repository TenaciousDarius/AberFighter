//
//  UserInterfaceLayer.h
//  AberFighter
//
//  Created by wde7 on 19/03/2011.
//  Copyright 2011 William Darius Elphick. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

/*
 Used to identify the fire buttons located on the left and right sides of the screen. 
 */
typedef enum FireButtonTags {
	kFireButtonLeft,
	kFireButtonRight
} FireButtonTag; 

@interface UserInterfaceLayer : CCLayer {
	
	/*
	 The timeLabel displays the game time remaining in the round.
	 */
	CCBitmapFontAtlas *timeLabel;
	
	/*
	 These are the variables used for showing the current scores in the game on the HUD.
	 */
	CCBitmapFontAtlas *localPlayerScoreLabel;
	CCBitmapFontAtlas *peerPlayerScoreLabel;

}

/*
 Read-only properties for all labels because they are cocos2D components which need to be autoreleased and
 should not be changed externally.
 */
@property (readonly) CCBitmapFontAtlas *timeLabel;
@property (readonly) CCBitmapFontAtlas *localPlayerScoreLabel;
@property (readonly) CCBitmapFontAtlas *peerPlayerScoreLabel;

/*
 Called when the Pause button is pressed on the UI. In the case of a multiplayer game a
 PeerPausedGame packet is sent to the other device. The current game state is changed to 
 Paused and the app delegate is called to place the Pause Menu on top of the MultilayerGameScene. 
 */
- (void)pauseGame;

/*
 Called by the timer method of the ActionLayer. Updates the value shown in the timeLabel. 
 */
- (void)updateTimeLabel:(int)currentTime;

/*
 Used by the single player for updating player 1's score. 
 */
- (void)updateLocalScoreLabel:(int)currentScore;

/*
 Used by the MultiplayerActionLayer to apply values to both labels.
 */
- (void)updateScoreLabelsWithLocalScore:(int)localScore peerScore:(int)peerScore;

@end
