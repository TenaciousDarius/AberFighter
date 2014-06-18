//
//  MultilayerGameScene.m
//  AberFighter
//
//  Created by wde7 on 19/03/2011.
//  Copyright 2011 William Darius Elphick. All rights reserved.
//

#import "MultilayerGameScene.h"
#import "GameState.h"
#import "SinglePlayerActionLayer.h"
#import "MultiplayerActionLayer.h"

@implementation MultilayerGameScene

//Singleton reference to this class.
static MultilayerGameScene* sharedScene;

/*
 Initializes the MultilayerGameScene with it's sublayers included and wraps them in a CCScene instance 
 before returning them.
 */
+ (id)scene {

	CCScene *scene = [CCScene node];
	id node = [MultilayerGameScene node];
	[scene addChild:node];
	return scene;
	
}

/*
 Static method which can be used to access the MultilayerGameScene.
 */
+ (MultilayerGameScene *)sharedScene {

	if (sharedScene != nil) {
		return sharedScene;
	}
	
	return nil;
	
}

/*
 Initializer of this layer. Creates an instance of the layer by calling the superclass init method
 and adds the required components to it.
 */
- (id)init {

	if ((self = [super init])) {
		
		/*
		 The instance created is set in sharedScene for reference later.
		 */
		sharedScene = self;
		
		/*
		 Depending on the gameType a SinglePlayerActionLayer or MultiplayerActionLayer instance 
		 is created and added to the MultilayerGameScene.
		 */
		int gameType = [GameState sharedState].gameType;
		
		ActionLayer *actionLayer;
		
		if (gameType == kSinglePlayerGame) {
			
			actionLayer = [SinglePlayerActionLayer node];
			
		} else {
			
			actionLayer = [MultiplayerActionLayer node];
			
		}
		
		[self addChild:actionLayer z:1 tag:kActionLayerTag];
		
		/*
		 An instance of UserInterfaceLayer is placed on top of the Action Layer.
		 */
		UserInterfaceLayer* userInterfaceLayer = [UserInterfaceLayer node];
		[self addChild:userInterfaceLayer z:2 tag:kUILayerTag];
		
	}
	
	return self;
	
}

/*
 Getter method for the UserInterfaceLayer instance stored in the MultilayerGameScene.
 */
- (UserInterfaceLayer *)userInterfaceLayer {

	return (UserInterfaceLayer *)[self getChildByTag:kUILayerTag];
	
}

/*
 Getter method for the ActionLayer instance stored in the MultilayerGameScene.
 */
- (ActionLayer *)actionLayer {

	return (ActionLayer *)[self getChildByTag:kActionLayerTag];
	
}

/*
 Called when the MultilayerGameScene is no longer shown by the Director. Sets the sharedScene instance to nil.
 */
- (void)dealloc {

	sharedScene = nil;
	
	[super dealloc];
	
}

@end
