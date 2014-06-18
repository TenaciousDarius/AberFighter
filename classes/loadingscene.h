//
//  LoadingScene.h
//  AberFighter
//
//  Created by wde7 on 03/01/2011.
//  Copyright 2011 William Darius Elphick. All rights reserved.
//
/*
 This is the first scene which is displayed when the app launches. It's purpose is to provide
 a user facing introduction while the underlying functionality (some located in AberFighterAppDelegate)
 loads the sprites required by the app from the texture sprites.png and also loads other components required
 by the app.
 */

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface LoadingLayer : CCLayer {
	
	//Points to the default image which is show in the loading scene until the sprites have been loaded successfully.
	CCSprite *defaultImage;
	
	/*
	 Container for the sprites which are shown in this view. Used to improve performance because the sprites contained
	 in a spritesheet will be drawn in 1 OpenGL call rather than once for each sprite i.e. O(1) rather than O(n).
	 */
	CCSpriteSheet *spriteSheet;
	
	//Boolean indicating if the process of extracting loading the texture is finished.
	BOOL textureLoaded;
	
	//Boolean indicating if the process of initializing components is finished.
	BOOL componentsLoaded;
	
}

/*
 Property declarations for the instance variables. Weak pointers are used for cocos2D components.
 This means that they are only assigned, they are not retained. This means that memory management
 is handled by cocos2D. When this layer is released it's child components are also released.
 */
@property (readonly) CCSprite *defaultImage;
@property (readonly) CCSpriteSheet *spriteSheet;
@property (nonatomic,readwrite,assign) BOOL textureLoaded;
@property (nonatomic,readwrite,assign) BOOL componentsLoaded;

/*
 Static method which returns a CCScene reference after initializing it, initializing this layer and adding 
 it as a child to the scene.
 */
+(id)scene;

@end




