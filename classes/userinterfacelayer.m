//
//  UserInterfaceLayer.m
//  AberFighter
//
//  Created by wde7 on 19/03/2011.
//  Copyright 2011 William Darius Elphick. All rights reserved.
//

#import "UserInterfaceLayer.h"
#import "AberFighterAppDelegate.h"
#import "BluetoothCommsManager.h"
#import "MultiLayerGameScene.h"
#import "ActionLayer.h"

@implementation UserInterfaceLayer

@synthesize timeLabel;
@synthesize localPlayerScoreLabel;
@synthesize peerPlayerScoreLabel;

/*
 This method creates the Pause button required for the UserInterfaceLayer, adds it to a menu and 
 places it on the layer.
 */
- (void)setUpMenu {
	
	CGSize winSize = [CCDirector sharedDirector].winSize;
	
	CCSprite *normalSprite = [CCSprite spriteWithSpriteFrameName:@"pause_button.png"];
	CCSprite *selectedSprite = [CCSprite spriteWithSpriteFrameName:@"pause_button_selected.png"];
	CCMenuItem *menuItem1 = [CCMenuItemSprite itemFromNormalSprite:normalSprite 
													selectedSprite:selectedSprite
															target:self
														  selector:@selector(menuItemPressed:)];
	menuItem1.tag = 1;
	
	CCMenu *pauseButton = [CCMenu menuWithItems:menuItem1, nil];
	pauseButton.position = ccp((winSize.width - (winSize.width / 10)), (winSize.height - kHUD_Y_POSITION));
	[self addChild:pauseButton];
	
}

/*
 Creates the CCBitmapFontAtlas instances required in the layer. These are the labels which need to
 change values often.
 */
- (void)setUpLabels {
	
	CGSize winSize = [CCDirector sharedDirector].winSize;
	
	NSString *timeLabelString = [NSString stringWithFormat:@"Time: %d\"", [GameState sharedState].gameLength];
	 timeLabel = [CCBitmapFontAtlas bitmapFontAtlasWithString:timeLabelString fntFile:@"action_labels.fnt"];
	self.timeLabel.position = ccp((winSize.width / 10), (winSize.height - kHUD_Y_POSITION));
	[self addChild:timeLabel z:1];
	
	NSString *localPlayerScoreLabelString = [NSString stringWithFormat:@"Your Score: %d", 0];
	localPlayerScoreLabel = [CCBitmapFontAtlas bitmapFontAtlasWithString:localPlayerScoreLabelString 
																	  fntFile:@"action_labels.fnt"];
	/*
	 If the game type is single player only one score label is created, otherwise two.
	 */
	if ([GameState sharedState].gameType == kSinglePlayerGame) {
		
		self.localPlayerScoreLabel.position = ccp((winSize.width / 2), (winSize.height - kHUD_Y_POSITION));
		
	} else {
		
		self.localPlayerScoreLabel.position = ccp((winSize.width / 3.2), (winSize.height - kHUD_Y_POSITION));
		
		NSString *peerPlayerScoreLabelString = [NSString stringWithFormat:@"Opponent's Score: %d", 0];
		peerPlayerScoreLabel = [CCBitmapFontAtlas bitmapFontAtlasWithString:peerPlayerScoreLabelString 
																		 fntFile:@"action_labels.fnt"];
		self.peerPlayerScoreLabel.position = ccp((winSize.width / 1.65), (winSize.height - kHUD_Y_POSITION));
		[self addChild:peerPlayerScoreLabel z:1];
		 
	}
		 
    [self addChild:localPlayerScoreLabel z:1];
	
}

/*
 Creates two sprites in the bottom corners of the screen indicating where to press to fire weapons.
 */
- (void)setUpFireButtons {
	
	CGSize winSize = [CCDirector sharedDirector].winSize;
	
	CCSprite *fireButtonLeft = [CCSprite spriteWithSpriteFrameName:@"fire_button.png"];
	fireButtonLeft.position = ccp(fireButtonLeft.contentSize.width/2, fireButtonLeft.contentSize.height/2);
	[self addChild:fireButtonLeft z:1 tag:kFireButtonLeft];
	
	CCSprite *fireButtonRight = [CCSprite spriteWithSpriteFrameName:@"fire_button.png"];
	fireButtonRight.position = ccp(winSize.width - (fireButtonRight.contentSize.width/2),
								   fireButtonRight.contentSize.height/2);
	[self addChild:fireButtonRight z:1 tag:kFireButtonRight];
	
}

/*
 Initializer of this layer. Creates an instance of the layer by calling the superclass init method
 and adds the required components to it.
 */
- (id)init {
	
	if ((self = [super init])) {
		
		/*
		 This view uses touch interaction. This boolean indicates
		 that the layer should receive touch method calls.
		 */
		self.isTouchEnabled = YES;
		
		CGSize winSize = [CCDirector sharedDirector].winSize;
		
		/*
		 Add the HUD (Heads Up Display) to the layer.
		 */
		CCSprite *hud = [CCSprite spriteWithSpriteFrameName:@"hud.png"];
        hud.position = ccp(winSize.width/2, winSize.height - kHUD_Y_POSITION);
        [self addChild:hud z:0];
		
		/*
		 Call the setUpMenu method above to create any buttons required in the view.
		 */
		[self setUpMenu];
		
		/*
		 Call the setUpLabels method above to initialize the required CCBitmapFontAtlas instances
		 and place them in the layer.
		 */
		[self setUpLabels];
		
		/*
		 Call the setUpFireButtons method above to create two opaque squares in the two lower 
		 corners of the screen showing the areas of the screen to press to fire weapons.
		 */
		[self setUpFireButtons];
		
	}
	return self;
	
}

/*
 Called when a button is pressed on the view. Calls other methods for functionality.
 */
- (void)menuItemPressed:(CCMenuItem *) menuItem {
	
	if (menuItem.tag == 1) {
		//Pause button pressed. Call pauseGame.
		[self pauseGame];
		
	}
}

/*
 Used to specify that this view should swallow touch events to stop them propagating to the ActionLayer.
 */
- (void)registerWithTouchDispatcher {
	[[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:-1 swallowsTouches:YES];
}

/*
 This method is called when the device screen is touched. It checks if the touch
 detected is in one of the bottom corners of the screen and if so calls
 fireProjectile to create a projectile travelling in the direction of the ship.
 */
- (BOOL) ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {

	CGPoint location = [touch locationInView:[touch view]];
	location = [[CCDirector sharedDirector] convertToGL:location];
	
	CCNode *leftFireButton = [self getChildByTag:kFireButtonLeft];
	CCNode *rightFireButton = [self getChildByTag:kFireButtonRight];
	
	if (CGRectContainsPoint([leftFireButton boundingBox], location) ||
		CGRectContainsPoint([rightFireButton boundingBox], location)) {
		
		/*
		 When one of the boxes is touched the ActionLayer is retrieved from the
		 MultilayerGameScene and the fireProjectile method is called.
		 */
		ActionLayer *actionLayer = [MultilayerGameScene sharedScene].actionLayer;
		[actionLayer fireProjectile];
		
		return YES;
		
	}	
	
	return NO;
	
}

- (void)updateTimeLabel:(int)currentTime {
	
	/*
	 Update the time label located at the top of the ActionLayer.
	 */
	NSString *timeLabelString = [NSString stringWithFormat:@"Time: %d\"", currentTime];
	[self.timeLabel setString:timeLabelString];
	
}

/*
 Update the local and peer player score labels.
 */
- (void)updateScoreLabelsWithLocalScore:(int)localScore peerScore:(int)peerScore {
	
	/*
	 localPlayerScoreLabel exists in all cases, whereas the peerPlayerScoreLabel is only available
	 in multiplayer games. Therefore it's existence must be checked before updating.
	 */
	[self updateLocalScoreLabel:localScore];
	
	if (self.peerPlayerScoreLabel != nil) {
		
		NSString *peerPlayerScoreLabelString = [NSString stringWithFormat:@"Opponent's Score: %d", peerScore];
		[self.peerPlayerScoreLabel setString:peerPlayerScoreLabelString];
	}
	
}

/*
 Update the localPlayerScoreLabel using the value set in the parameter.
 */
- (void)updateLocalScoreLabel:(int)currentScore {
	
	NSString *localPlayerScoreLabelString = [NSString stringWithFormat:@"Your Score: %d", currentScore];
	[self.localPlayerScoreLabel setString:localPlayerScoreLabelString];
	
}

/*
 Called when the Pause button is pressed. Stops the game loops and shows the pause menu.
 */
- (void)pauseGame {
	
	/*
	 During multiplayer games the other device must be notified when the game is paused.
	 */
	if ([GameState sharedState].gameType == kMultiplayerGame) {
		
		[[BluetoothCommsManager sharedInstance] sendPeerPausedGamePacket];
		
	}
	
	//Sets the current game state to kGamePaused. 
	[GameState sharedState].currentState = kGamePaused;
	
	/*
	 Call the showPauseMenu method on the app delegate to lay the pause menu on top of the MultilayerGameScene.
	 */
	AberFighterAppDelegate *delegate = (AberFighterAppDelegate *) [UIApplication sharedApplication].delegate;
	[delegate showPauseMenu];
	
}

/*
 Called when the layer is deallocated. Sets the weak pointers used for referencing cocos2D
 components to nil and then calls super dealloc. Releasing cocos2D components happens automatically
 when their parent CCNode is released. 
 */
- (void)dealloc {
	
	timeLabel = nil;
	localPlayerScoreLabel = nil;
	peerPlayerScoreLabel = nil;
	
	[super dealloc];
	
}


@end
