//
//  AberFighterAppDelegate.m
//  AberFighter
//
//  Created by wde7 on 01/01/2011.
//  Copyright William Darius Elphick 2011. All rights reserved.
//

#import "AberFighterAppDelegate.h"
#import "LoadingScene.h"
#import "MainMenuScene.h"
#import "SinglePlayerOptionsScene.h"
#import "MultiplayerOptionsScene.h"
#import "MultilayerGameScene.h"
#import "PauseMenuScene.h"
#import "MultiplayerPauseMenuScene.h"
#import "InstructionsScene.h"
#import "GameOverScene.h"
#import "BluetoothCommsManager.h"
#import "GameState.h"

@implementation AberFighterAppDelegate

#pragma mark -
#pragma mark Synthesized Properties

@synthesize window;

#pragma mark -
#pragma mark Application Delegate Methods

/*
 Called when the application is ready to be displayed initially. Configures the cocos2D director and the 
 OpenGL ES view in which the app is shown. Then shows the first scene in the application.
 */
- (void) applicationDidFinishLaunching:(UIApplication*)application {
	
	//Initialise the window in which the user interface runs.
	window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	
	/*
	 Initialise a Threaded Fast CCDirector instance. The Director manages the cocos2D 
	 scenes which are shown on the screen and runs the main loop which notifies 
	 components to update. Also runs the cocos2D scheduler which is used for scheduling 
	 callbacks to methods. A Threaded fast director runs the main loop within a thread, 
	 which is faster than the Display Link director which calls it's main loop from the
	 main application thread. This causes it to conflict with user interface event which 
	 compete for use of the main loop. If the threaded fast director isn't available then
	 a Display Link director is created as an alternative.
	 */
	if(![CCDirector setDirectorType:kCCDirectorTypeThreadMainLoop] )								
		[CCDirector setDirectorType:kCCDirectorTypeDisplayLink];
	
	/*
	 Configures the director. The framerate is 60 times per second 
	 to keep up with the refresh rate of the device.
	 */
	CCDirector *director = [CCDirector sharedDirector];										
	[director setDeviceOrientation:kCCDeviceOrientationLandscapeLeft];								
	[director setDisplayFPS:YES];																
	[director setAnimationInterval:1.0/60.0];
	
	/*
	 Create an OpenGL ES view to contain the app user interface. Required by the cocos2D
	 director. Default values have been used.
	 */
	EAGLView *glView = [EAGLView viewWithFrame:[window bounds]								
								   pixelFormat:kEAGLColorFormatRGB565							
								   depthFormat:0 /* GL_DEPTH_COMPONENT24_OES */				
							preserveBackbuffer:NO];
	//Multitouch is enabled in case it is required in the future.
	[glView setMultipleTouchEnabled:YES];
	[director setOpenGLView:glView];
	
	/*
	 Adds the glView to the window. Then the makeKeyAndVisible method is called to show the window
	 and make it the main application window.
	 */
	[window addSubview:glView];																
	[window makeKeyAndVisible];
	
	// Default texture format for PNG/BMP/TIFF/JPEG/GIF images
	[CCTexture2D setDefaultAlphaPixelFormat:kTexture2DPixelFormat_RGBA8888];
	
	//Prevents the device's screen from dimming when it isn't touched for a short time.
	[[UIApplication sharedApplication] setIdleTimerDisabled:YES];
	
	//Initializes and shows the loading scene which is the first scene shown in the app. 
	[[CCDirector sharedDirector] runWithScene:[LoadingLayer scene]];
	
}

/*
 The following methods are required for handling events which are fired by iOS
 e.g. memory warnings, closing the app, pausing the app etc.
 */

/*
 Called when the app resigns active status e.g. when a text message alert is received.
 Pauses the cocos2D director which reduces the animation interval and stops actions and scheduled methods.
 */
- (void)applicationWillResignActive:(UIApplication *)application {
	
	[[CCDirector sharedDirector] pause];

}

/*
 Called when the app becomes active again. Resumes the cocos2D director in it's current state.
 */
- (void)applicationDidBecomeActive:(UIApplication *)application {
	
	[[CCDirector sharedDirector] resume];

}

/*
 Called when a memory warning is received from the system. This is when the amount of memory allocated 
 by the app exceeds what is allowed. Calls the cocos2D texture cache to remove any textures which aren't being used 
 currently to free up memory.
 */
- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
	[[CCTextureCache sharedTextureCache] removeUnusedTextures];
}

/*
 iOS version 4 allows multitasking by placing the application in the background. The properties of this application 
 have been configured to terminate the app when the application enters the background. This is because the Game does not
 have information currently which needs to be persisted.
 */
-(void) applicationDidEnterBackground:(UIApplication*)application {
	[[CCDirector sharedDirector] stopAnimation];
}

-(void) applicationWillEnterForeground:(UIApplication*)application {
	[[CCDirector sharedDirector] startAnimation];
}

/*
 When the application is terminating the end method is called on the cocos2D director. This stops animation
 and releases the currently running scene.
 */
- (void)applicationWillTerminate:(UIApplication *)application {
	[[CCDirector sharedDirector] end];
}

/*
 Called to keep the director in sync with the clock of the application by setting it to
 0 when a significant time has passed.
 */
- (void)applicationSignificantTimeChange:(UIApplication *)application {
	[[CCDirector sharedDirector] setNextDeltaTimeZero:YES];
}

#pragma mark -
#pragma mark Custom Public Methods

/*
 Called asynchronously from the LoadingLayer. This method initialises the shared OpenGL context, the GameState 
 singleton and the ReusableTargetPool singleton. 
 */
- (void)loadInitialComponents {
	
	// Create a shared opengl context so any textures we load can be shared with the
    // main content (it isn't possible to access textures from multiple threads without
	// doing this).
    EAGLContext *k_context = [[[EAGLContext alloc]
                               initWithAPI:kEAGLRenderingAPIOpenGLES1
                               sharegroup:[[[[CCDirector sharedDirector] openGLView] context] sharegroup]] autorelease];    
    [EAGLContext setCurrentContext:k_context];
	
	[GameState sharedState];
	[ReusableTargetPool sharedInstance];
	
}

/*
 Makes the main menu the active scene.
 */
- (void)launchMainMenu {
	
	//Reset the game state.
	[[GameState sharedState] reset];
	/*
	 A CCFadeDownTransition animates the transition from the current scene to the main menu.  
	 */
	[[CCDirector sharedDirector] replaceScene:
	 [CCFadeDownTransition transitionWithDuration:0.5 
											scene:[MainMenuLayer scene]]];
	
}

/*
 Called from the main menu to configure a single player game and show the SinglePlayerOptionsLayer. 
 */
- (void)newSinglePlayerGame {
	
	GameState *gameState = [GameState sharedState];
	[gameState reset];
	gameState.gameType = kSinglePlayerGame;
	
	[self showGameOptionsScene];
	
}

/*
 Called from the main menu to configure a multiplayer game.
 */
- (void)newMultiplayerGame {
	
	GameState *gameState = [GameState sharedState];
	[gameState reset];
	[gameState resetGameLength];
	gameState.gameType = kMultiplayerGame;
	gameState.currentState = kGameDeterminingPlayerIDs;
	
	[[BluetoothCommsManager sharedInstance] resetLayerStateIndicators];
	
}

/*
 Called from the GameOptions layer, this creates a new MultilayerGameScene and
 sets up a transition to it.
 */
- (void)startGame {
	
	[GameState sharedState].currentState = kGameStarting; 
	[[CCDirector sharedDirector] replaceScene:
	 [CCFadeTransition transitionWithDuration:0.5 
										scene:[MultilayerGameScene scene]]];

}

/*
 Called when a player quits the game or the timer in the ActionLayer reaches 0. The clearUpComponents method 
 in the ActionLayer releases the sprites which have been instantiated and stops the selectors used in the layer.
 */
- (void)gameOver {
	
	[GameState sharedState].currentState = kGameOver;
	
	ActionLayer *actionLayer = [MultilayerGameScene sharedScene].actionLayer;
	[actionLayer clearUpGameComponents];
	actionLayer = nil;
	
	[self showGameOverScene];
	
}

/*
 Transitions from the current scene into a new instance of the GameOverLayer wrapped in a scene instance. 
 */
- (void)showGameOverScene {
	
	[[CCDirector sharedDirector] replaceScene:
	 [CCFadeTransition transitionWithDuration:0.5 
										scene:[GameOverLayer scene] 
									withColor:ccWHITE]]; 
	
}

/*
 Replaces the currently showing scene in the cocos director with an instance of either the 
 SinglePlayerOptionsLayer or the MultiplayerOptionsLayer, depending on the gameType in the 
 GameState singleton, wrapped in a CCScene instance.
 */
- (void)showGameOptionsScene {
	
	int gameType = [GameState sharedState].gameType;
	
	CCScene *gameOptionsScene;
	
	if (gameType == kSinglePlayerGame) {
		
		gameOptionsScene = [SinglePlayerOptionsLayer scene];
		
	} else {
		
		gameOptionsScene = [MultiplayerOptionsLayer scene];
		
	}
	
	[[CCDirector sharedDirector] replaceScene:
	 [CCFadeUpTransition transitionWithDuration:0.5 scene:gameOptionsScene]];;
	
}

/*
 Creates either a PauseMenuLayer or MultiplayerPauseMenuLayer scene instance based on the game type
 and pushes it on top of the current scene in the Director stack. Selectors and actions on the layer 
 beneath are automatically paused while the layer is showing.
 */
- (void)showPauseMenu {
	
	CCScene *pauseMenuScene;
	if ([GameState sharedState].gameType == kSinglePlayerGame) {
		
		pauseMenuScene = [PauseMenuLayer scene];
		
	} else {
		
		pauseMenuScene = [MultiplayerPauseMenuLayer scene];
		
	}

	[[CCDirector sharedDirector] pushScene:pauseMenuScene];
	
}

/*
 Removes the PauseMenuLayer from the CCDirector stack. This functionality allows the layer
 to be shown on top of the MultilayerGameScene so that every action and selector on that layer
 is paused automatically and will automatically resume when the pause menu is removed.
 */
- (void)hidePauseMenu {

	[[CCDirector sharedDirector] popScene];
	
}

/*
 Called when a quit has been confirmed from the PauseMenu. Hides the pauseMenu and calls the gameOver method.
 */
- (void)quitGame {

	[self hidePauseMenu];
	[self gameOver];
	
}

/*
 Uses a transition to lay the instructions layer on top of the current scene.
 */
- (void)showInstructions {
	
	[[CCDirector sharedDirector] pushScene:
	 [CCPageTurnTransition transitionWithDuration:0.5 
											scene:[InstructionsLayer scene] 
										backwards:YES]];
	
}

/*
 Removes the InstructionsLayer from the CCDirector stack. This functionality allows the InstructionsLayer
 to be shown from multiple locations in the app without having to remember where it is, because the previous 
 scene is still available on the stack. popScene doesn't support transitions.
 */
- (void)hideInstructions {
	
	[[CCDirector sharedDirector] popScene];
	
}

/*
 Called from the ActionLayer when the bluetooth connection has been lost. Because the game
 will have fallen out of sync significantly in this situation the bluetooth module doesn't
 attempt to recover the connection and instead calls this method to clear up the connection and game
 and show the main menu.
 */
- (void)abortActiveMultiplayerGame {
	
	[[BluetoothCommsManager sharedInstance] clearUpSession];
	
	if ([GameState sharedState].currentState == kGamePaused) {
		
		[self hidePauseMenu];
		
	}
	
	ActionLayer *actionLayer = [MultilayerGameScene sharedScene].actionLayer;
	[actionLayer clearUpGameComponents];
	actionLayer = nil;
	
	[self launchMainMenu];
	
}

#pragma mark -
#pragma mark Superclass Override Methods

/*
 Releases the UIWindow in which the application is running.
 */
- (void)dealloc {
	
	[window release];
	[super dealloc];
	
}

@end
