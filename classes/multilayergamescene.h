//
//  MultilayerGameScene.h
//  AberFighter
//
//  Created by wde7 on 19/03/2011.
//  Copyright 2011 William Darius Elphick. All rights reserved.
//
/*
 MultilayerGameScene is the scene where gameplay takes place. The layer contains two sub-layers
 which represent the user interface and the AcionLayer itself. The purpose of this class is to 
 wrap the other two layer and provide a global point of reference to them. This is so that the 
 user interface can call methods in the ActionLayer to change the game as input is received.
 This assumes that there is only ever 1 instance of MultilayerGameInstance instantiated at a time.
 This design is based on an example of how to create a multi-layered scene which I read about in
 Learning iPhone and iPad cocos2D Development.
 */

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "UserInterfaceLayer.h"
#import "ActionLayer.h"

/*
 These are the tags which represent the sublayers within this layer. These are used so that the
 sublayers can be retrieved by tag during the game.
 */
typedef enum SublayerTags {
	kUILayerTag,
	kActionLayerTag
} SublayerTag;

/*
 This constant indicates the y position that all components located on the
 Heads Up Display should have.
 */
#define kHUD_Y_POSITION 10

@interface MultilayerGameScene : CCLayer {

}

/*
 The properties defined allow only the getter methods for userInterfaceLayer and 
 actionLayer to be referenced externally. This is so that external sources can't change the 
 layers which are in the scene.
 */
@property (readonly) UserInterfaceLayer* userInterfaceLayer;
@property (readonly) ActionLayer* actionLayer;

/*
 Static method which returns a CCScene reference after initializing it, initializing this layer and adding 
 it as a child to the scene. The scene instance is stored in the internal singleton which can be accessed using the 
 sharedScene method.
 */
+ (id)scene;

/*
 MultilayerGameScene is a partial singleton. Although it is instantiated like any other layer using the scene method,
 it can then be referenced for the duration of it's lifetime using the sharedScene method. It is not a full singleton 
 because it is released when it is no longer shown on the screen by cocos2D automatically to free up valuable memory.
 */
+ (MultilayerGameScene *)sharedScene;

@end
