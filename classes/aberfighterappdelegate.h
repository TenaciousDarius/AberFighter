//
//  AberFighterAppDelegate.h
//  AberFighter
//
//  Created by wde7 on 01/01/2011.
//  Copyright William Darius Elphick 2011. All rights reserved.
//
/*
 This application delegate acts as the central control for the app.
 Routing between scenes takes place in this singleton.
 */

#import <UIKit/UIKit.h>
#import "cocos2d.h"

@interface AberFighterAppDelegate : NSObject <UIApplicationDelegate> {
	/*
	 This is the window in which the user interface is shown.
	 */
	UIWindow *window;	
}

/*
 Property declaration for the interface window.
 */
@property (nonatomic, retain) UIWindow *window;

/*
 This method is called asynchronously from the loading scene to load components which are required by the 
 rest of the application.
 */
- (void)loadInitialComponents;

/*
 Resets the GameState and then replaces the currently showing scene in the cocos Director with a new
 instance of the MainMenuLayer wrapped in a CCScene instance.
 */
- (void)launchMainMenu;

/*
 Configures the GameState to support a single player game then calls showGameOptionsScene.
 */
- (void)newSinglePlayerGame;

/*
 Configures the GameState to support a multiplayer game.
 */
- (void)newMultiplayerGame;

/*
 Changes the current game state to GameStarting and replaces the current scene in the cocos Director
 with a new instance of the MultilayerGameScene.
 */
- (void)startGame;

/*
 Sets the Game State to finished, notifies the ActionLayer to clear up the used
 game components then calls showGameOverScene.
 */
- (void)gameOver;

/*
 Replaces the currently showing scene in the cocos Director with a new instance of the GameOverLayer
 wrapped in a CCScene instance.
 */
- (void)showGameOverScene;

/*
 Replaces the currently showing scene in the cocos director with an instance of either the 
 SinglePlayerOptionsLayer or the MultiplayerOptionsLayer, depending on the gameType in the 
 GameState singleton, wrapped in a CCScene instance.
 */
- (void)showGameOptionsScene;

/*
 Creates an instance of either the PauseMenuLayer or the MultiplayerPauseMenuLayer, depending 
 on the gameType in the GameState singleton, wrapped in a CCScene instance. Pushes the scene onto
 the cocos Director stack so that it shows above the currently showing scene.
 */
- (void)showPauseMenu;

/*
 Pops the PauseMenu scene off the cocos Director's scene stack. The scene next
 on the stack resumes and is shown.
 */
- (void)hidePauseMenu;

/*
 Hides the pause menu using the method above and then calls the gameOver method.
 */
- (void)quitGame;

/*
 Creates an instance of InstructionsLayer wrapped in a CCScene instance. Pushes the scene onto
 the cocos Director stack so that it shows above the currently showing scene.
 */
- (void)showInstructions;

/*
 Pops the Instructions scene off the cocos Director's scene stack. The scene next
 on the stack resumes and is shown.
 */
- (void)hideInstructions;

/*
 Called when the bluetooth connection is lost while in the MultilayerGameScene. Notifies the BluetoothCommsManager
 to clear up the session and the ActionLayer to clear up it's components then calls launchMainMenu.
 */
- (void)abortActiveMultiplayerGame;

@end
