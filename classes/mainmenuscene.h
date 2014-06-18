//
//  MainMenu.h
//  AberFighter
//
//  Created by wde7 on 01/01/2011.
//  Copyright 2011 William Darius Elphick. All rights reserved.
//
/*
 This is the Main Menu Scene. It displays a number of menus which provide access 
 to the other functionality available in the game. It conforms to the 
 GKPeerPickerControllerDelegate and UIAlertViewDelegate protocols for bluetooth functionality.
 */

#import <Foundation/Foundation.h>
#import <GameKit/GameKit.h>
#import "cocos2d.h"

@interface MainMenuLayer : CCLayer <GKPeerPickerControllerDelegate, UIAlertViewDelegate> {
	
	/*
	 Container for the sprites which are shown in this view. Used to improve performance 
	 because the sprites contained in a spritesheet will be drawn in 1 OpenGL call rather 
	 than once for each sprite i.e. O(1) rather than O(n).
	 */
	CCSpriteSheet *spriteSheet;
	
	/*
	 This menu contains the three buttons Single Player, Multiplayer and Help. It is located
	 in the center of the layer.
	 */
	CCMenu *mainMenu;
	
}

/*
 Property declarations for the instance variables. Both are readonly because they reference cocos2D components.
 */
@property (readonly) CCSpriteSheet *spriteSheet;
@property (readonly) CCMenu *mainMenu;

/*
 Static method which returns a CCScene reference after initializing it, initializing this layer and adding 
 it as a child to the scene.
 */
+ (id)scene;

@end
