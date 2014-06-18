//
//  PauseMenuScene.h
//  AberFighter
//
//  Created by wde7 on 14/02/2011.
//  Copyright 2011 William Darius Elphick. All rights reserved.
//
/*
 Pause menu shown when the game is paused from the MultilayerGameScene.
 */

#import <Foundation/Foundation.h>
#import "cocos2d.h"

/*
 The quit confirmation layer is shown when the user presses the 
 Quit Game button on the pause menu and allows the user to either 
 quit or cancel and return to the pause menu.
 */
@interface QuitConfirmationLayer : CCLayer {
	
	//Points to the background image of the view.
    CCSprite *background;
	
}

/*
 Property declarations for the instance variables. Readonly pointer due to being a cocos2D
 component.
 */
@property (readonly) CCSprite *background;

@end


@interface PauseMenuLayer : CCLayer {
	
	/*
	 Container for the sprites which are shown in this view. Used to improve performance 
	 because the sprites contained in a spritesheet will be drawn in 1 OpenGL call rather 
	 than once for each sprite i.e. O(1) rather than O(n).
	 */
	CCSpriteSheet *spriteSheet;
	
	//Points to the background image of the view.
	CCSprite *background;
	
	//Points to the menu containing the three buttons on the pause menu.
	CCMenu *pauseMenuButtons;
	
	//Shown in the PauseMenuLayer when quitting the game. See above for more information.
	QuitConfirmationLayer *quitConfirmationLayer;
}

/*
 Property declarations for the instance variables. Weak pointers are used for cocos2D components.
 This means that they are only assigned, they are not retained. This means that memory management
 is handled by cocos2D. When this layer is released it's child components are also released.
 */
@property (readonly) CCSpriteSheet *spriteSheet;
@property (readonly) CCSprite *background;
@property (readonly) CCMenu *pauseMenuButtons;
@property (readonly) QuitConfirmationLayer *quitConfirmationLayer;

/*
 Static method which returns a CCScene reference after initializing it, initializing this layer and adding 
 it as a child to the scene.
 */
+ (id)scene;

/*
 Called when the Resume button is pressed in this layer.
 */
- (void)resumeGame;

/*
 Called from the QuitConfirmationLayer when the Cancel button is pressed. Hides the confirmation,
 releases it and re-enables touch interaction on this layer.
 */
- (void)hideQuitConfirmation;

/*
 Called from the QuitConfirmationLayer when the Quit Game button is pressed. Calls hideQuitConfirmation
 above, then calls quitGame.
 */
- (void)quitGamePressed;

/*
 Notifies the App delegate to end the game.
 */
- (void)quitGame;

/*
 Called when a button is pressed in the layer. Public so that it can be overridden in the subclass.
 */
- (void)menuItemPressed:(CCMenuItem *)menuItem;

@end
