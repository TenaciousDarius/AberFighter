//
//  LoadingScene.m
//  AberFighter
//
//  Created by wde7 on 03/01/2011.
//  Copyright 2011 William Darius Elphick. All rights reserved.
//

#import "LoadingScene.h"
#import "AberFighterAppDelegate.h"

@implementation LoadingLayer

#pragma mark -
#pragma mark Synthesized Properties

/*
 Creates getters and setters based on the properties defined in the header file.
 */
@synthesize defaultImage; 
@synthesize spriteSheet; 
@synthesize textureLoaded; 
@synthesize componentsLoaded; 

#pragma mark -
#pragma mark Initializers

+ (id)scene {

	CCScene *scene = [CCScene node];
	id node = [LoadingLayer node];
	[scene addChild:node];
	
	return scene;
}

/*
 Initializer of this layer. Creates an instance of the layer by calling the superclass init method
 and adds the required components to it.
 */
- (id)init {

	if ((self = [super init])) {
		self.textureLoaded = NO;
		self.componentsLoaded = NO;
		
		//Shows a default loading image until loading the sprites from the texture is finished.
		CGSize winSize = [CCDirector sharedDirector].winSize;
        defaultImage = [CCSprite spriteWithFile:@"DefaultLandscape.png"];
        defaultImage.position = ccp(winSize.width/2, winSize.height/2);
        [self addChild:defaultImage]; 
		
		/* 
		 Loads and caches the sprites.png image to reduce allocation of memory while the app is running. 
		 When finished the spritesLoaded method within this class is called.
		 */
        [[CCTextureCache sharedTextureCache] addImageAsync:@"sprites.png" target:self selector:@selector(spritesLoaded:)];
		
		// Schedule a periodic method to check the status of loading.
        [self schedule: @selector(checkStatusOfLoad:)];
	}
	
	return self;
}

#pragma mark -
#pragma mark Resource Loading Methods

/*
 This method is called periodically by the scheduler to check if the loading processes performed in this scene have completed,
 which is indicated by the textureLoaded and componentsLoaded boolean variables. When this has occured the application delegate is 
 notified to show the main menu scene.
 */
- (void)checkStatusOfLoad:(ccTime)timeSinceLastCall {
	
	if (textureLoaded && componentsLoaded) {
		
		[self unschedule:@selector(checkStatusOfLoad:)];
	    AberFighterAppDelegate *delegate = (AberFighterAppDelegate *) [UIApplication sharedApplication].delegate;
		[delegate launchMainMenu];
		
	}
}

/* 
 This method is called after the CCTextureCache has finished loading sprites.png. It is then 
 possible to extract the sprites from the texture in order to initialize the scenes required.
 */
-(void) spritesLoaded: (CCTexture2D*) texture {
	
	// Remove the default image which was placed in the background.
    [self removeChild:defaultImage cleanup:YES];
    defaultImage = nil;
    
    /* 
	 Store the information contained in sprites.plist (which specifies the coordinates and dimensions 
	 of the subimages contained within sprites.png which is now available through texture, the pointer 
	 passed into this method).
	 */
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"sprites.plist"];
    
    // Creates a spritesheet using texture. This allows all of the sprites in this texture to be drawn with one OpenGl call.
    spriteSheet = [CCSpriteSheet spriteSheetWithTexture:texture];
    [self addChild:spriteSheet];
    
    // Add main background to scene
    CGSize windowSize = [CCDirector sharedDirector].winSize;
    CCSprite *mainBackground = [CCSprite spriteWithSpriteFrameName:@"main_menu_background.png"];
    mainBackground.position = ccp(windowSize.width/2, windowSize.height/2);
    [spriteSheet addChild:mainBackground];
	
	// Add title to scene
    static int MAIN_TITLE_TOP_MARGIN = 13;
    CCSprite *mainTitle = [CCSprite spriteWithSpriteFrameName:@"title.png"];
    mainTitle.position = ccp(windowSize.width/2, windowSize.height - mainTitle.contentSize.height/2 - MAIN_TITLE_TOP_MARGIN);
    [spriteSheet addChild:mainTitle];
	
    // Add "Loading..." to scene
    static int LOADING_BOTTOM_MARGIN = 78;
    CCSprite *loading = [CCSprite spriteWithSpriteFrameName:@"loading.png"];
    loading.position = ccp(windowSize.width/2, loading.contentSize.height/2 + LOADING_BOTTOM_MARGIN);
    [spriteSheet addChild:loading];
    
    // Perform a little animation on the "loading" text so users know something is happening.
    [loading runAction:[CCRepeatForever actionWithAction:
							[CCSequence actions:
								[CCFadeOut actionWithDuration:1.0f],
								[CCFadeIn actionWithDuration:1.0f],
								nil
							 ]
						]
	 ];
    
    self.textureLoaded = YES;
	
    // Create an operation to load the components so that it runs as an asynchronous operation.
    NSInvocationOperation* sceneLoadOperation = [[[NSInvocationOperation alloc] initWithTarget:self 
																					  selector:@selector(loadInitialComponents:) 
																						object:nil] autorelease];
    NSOperationQueue *operationQueue = [[[NSOperationQueue alloc] init] autorelease]; 
    [operationQueue addOperation:sceneLoadOperation];
    
}

/*
 Calls the loadInitialComponents method in the app delegate to initialize the components needed. 
 */
- (void)loadInitialComponents:(NSObject *)data {
    
    AberFighterAppDelegate *delegate = (AberFighterAppDelegate *) [UIApplication sharedApplication].delegate;
    [delegate loadInitialComponents];
    self.componentsLoaded = YES;
	
}

/*
 Called when the layer is deallocated. Sets the weak pointers used for referencing cocos2D
 components to nil and then calls super dealloc. Releasing cocos2D components happens automatically
 when their parent CCNode is released.
 */
- (void)dealloc {

	defaultImage = nil;
	spriteSheet = nil;
	[super dealloc];
	
}

@end

