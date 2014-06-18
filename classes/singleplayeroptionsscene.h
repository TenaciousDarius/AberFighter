//
//  SinglePlayerOptionsLayer.h
//  AberFighter
//
//  Created by wde7 on 23/03/2011.
//  Copyright 2011 William Darius Elphick. All rights reserved.
//
/*
 This class extends the GameOptionsLayer class to configure it for a single player game.
 */

#import <Foundation/Foundation.h>
#import "GameOptionsLayer.h"

@interface SinglePlayerOptionsLayer : GameOptionsLayer {
	
	/*
	 These buttons are used for selecting an accelerometer control method.
	 Pointers are used so that they can be highlighted based on the current selection.
	 */
	CCMenuItem *controlScheme1Selector;
	CCMenuItem *controlScheme2Selector;

}

/*
 Readonly pointers to the control scheme buttons.
 */
@property (readonly) CCMenuItem *controlScheme1Selector;
@property (readonly) CCMenuItem *controlScheme2Selector;

/*
 Static method which returns a CCScene reference after initializing it, initializing this layer and adding 
 it as a child to the scene.
 */
+ (id)scene;

@end
