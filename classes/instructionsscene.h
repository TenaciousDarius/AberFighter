//
//  InstructionsScene.h
//  AberFighter
//
//  Created by wde7 on 01/02/2011.
//  Copyright 2011 William Darius Elphick. All rights reserved.
//
/*
 The InstructionsScene displays an image with instructions on how to play the game.
 Because the image is larger than the screen area, scrolling up and down has also been 
 implemented in this scene.
 */

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface InstructionsLayer : CCLayer {
	
	/*
	 scrollLayer is a layer added as a child to this layer. It contains an image
	 depicting the instructions of the game. It's y axis position is changed as the user drags their finger 
	 along the screen in order to create a scrolling effect.
	 */
	CCLayer *scrollLayer;
	
	/*
	 These are arrow shaped sprites located in the upper and lower right hand 
	 corners of the screen which indicate to the user that more information is
	 available through scrolling. The visibility of the arrows depends on whether the current
	 scrolling position is at the top, bottom or somewhere in the middle of the content.
	 */
	CCSprite *upArrow;
	CCSprite *downArrow;
	
	/*
	 Used to indicate during the movement update whether the user is currently dragging 
	 their finger across the screen.
	 */
	BOOL isDragging;
	
	/*
	 The previous scrolling position is used during each movement update if the user removes 
	 their finger from the screen to calculate inertia. This allows the scrolling view
	 to continue to move for a short time after the user's finger is removed.	  
	 */
	float previousScrollYPosition;
	
	/*
	 This is the current velocity of the scroll view in the direction it is scrolling.
	 */
	float scrollYVelocity;
	
	/*
	 This is the size of the image contained in the scroll layer. Used for boundary checking 
	 to ensure the scrolling stops at the top and bottom of the content.
	 */
	int contentHeight;

}

/*
 Property declarations for the instance variables. Weak pointers are used for cocos2D components.
 This means that they are only assigned, they are not retained. This means that memory management
 is handled by cocos2D. When this layer is released it's child components are also released.
 */
@property (readonly) CCLayer *scrollLayer;
@property (readonly) CCSprite *upArrow;
@property (readonly) CCSprite *downArrow;
@property (nonatomic, readonly) BOOL isDragging;
@property (nonatomic, readwrite, assign) float previousScrollYPosition;
@property (nonatomic, readwrite, assign) float scrollYVelocity;
@property (nonatomic, readonly) int contentHeight;

/*
 Static method which returns a CCScene reference after initializing it, initializing this layer and adding 
 it as a child to the scene.
 */
+(id)scene;

@end
