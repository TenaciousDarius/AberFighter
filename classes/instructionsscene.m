//
//  InstructionsScene.m
//  AberFighter
//
//  Created by wde7 on 01/02/2011.
//  Copyright 2011 William Darius Elphick. All rights reserved.
//

#import "InstructionsScene.h"
#import "AberFighterAppDelegate.h"

@implementation InstructionsLayer

#pragma mark -
#pragma mark InstructionsLayer Synthesized Properties

@synthesize scrollLayer;
@synthesize upArrow;
@synthesize downArrow;
@synthesize isDragging;
@synthesize previousScrollYPosition;
@synthesize scrollYVelocity;
@synthesize contentHeight;

#pragma mark -
#pragma mark InstructionsLayer Initializers

+ (id)scene {
	
	CCScene *scene = [CCScene node];
	id node = [InstructionsLayer node];
	[scene addChild:node];
	
	return scene;
}

/*
 Initializer of this layer. Creates an instance of the layer by calling the superclass init method
 and adds the required components to it.
 */
- (id) init {

	if ((self = [super init])) {
		
		/*
		 Touch is enabled in this view to support scrolling.
		 */
		self.isTouchEnabled = YES;
		
		/*
		 scrollLayer contains the image conveying game instructions. I used an image rather than labels
		 and sub images because it is expandable in the future without needing to modify the code by replacing
		 instructions_view.png. 
		 */
		scrollLayer = [CCLayer node];
		/*
		 The anchorPoint property keeps the layer centered regardless of any change in size.
		 */
		scrollLayer.anchorPoint = ccp(0, 1);
		scrollLayer.position = ccp(0, 0);
		
		CGSize winSize = [[CCDirector sharedDirector] winSize];
		
		/*
		 instructions_view.png is loaded into the application. The image's height is assigned to
		 the contentHeight variable to enforce boundary checking in the scrollUpdate and ccTouchesMoved
		 methods below. The image is added to the scrollLayer because this is the component which will 
		 moved when scrolling.
		 */
        CCSprite *background = [CCSprite spriteWithFile:@"instructions_view.png"];
		contentHeight = background.contentSize.height;
        background.position = ccp(background.contentSize.width/2, -90);
        [scrollLayer addChild:background];
		
		/*
		 Add the scrollLayer to this layer.
		 */
		[self addChild:self.scrollLayer];
		
		/*
		 A cancel button is created which will allow the user to leave the InstructionsScene and return to
		 the previous screen. The button is added to the layers so that it sits on top of the scroll.
		 */
		CCSprite *normalSprite = [CCSprite spriteWithSpriteFrameName:@"cancel_button.png"];
		CCSprite *selectedSprite = [CCSprite spriteWithSpriteFrameName:@"cancel_button_selected.png"];
		CCMenuItem *menuItem1 = [CCMenuItemSprite itemFromNormalSprite:normalSprite 
														selectedSprite:selectedSprite 
																target:self 
															  selector:@selector(menuItemPressed:)];
		menuItem1.tag = 1;
		
		CCMenu *cancelButton = [CCMenu menuWithItems:menuItem1, nil];
		cancelButton.position = ccp(winSize.width / 2.0f, 
									winSize.height / 8.0f);
		[self addChild:cancelButton];
		
		/*
		 Create 2 arrows, located at the top and bottom right hand corners, which indicate when more information 
		 is available by scrolling. The same image is used for both arrows, therefore the downArrow is rotated by 
		 180 degrees to face in the opposite direction.
		 */
		upArrow = [CCSprite spriteWithSpriteFrameName:@"arrow.png"];
		upArrow.position = ccp(winSize.width - (upArrow.contentSize.width/2), 
							   winSize.height - (upArrow.contentSize.height/2));
		[self addChild:upArrow];
		
		downArrow = [CCSprite spriteWithSpriteFrameName:@"arrow.png"];;
		downArrow.position = ccp(winSize.width - (upArrow.contentSize.width/2), 
								 upArrow.contentSize.height/2);
		downArrow.rotation = 180.0f;
		[self addChild:downArrow];
		
	}
	
	return self;
	
}

#pragma mark -
#pragma mark Superclass Overrides

/*
 onEnter is called as the transition into the instructions scene begins. It sets the initial
 state of the scroll and creates actions to animate the arrows located of the view.
 */
- (void) onEnter {
	
	/*
	 A call to super onEnter is needed, otherwise the view will not receive touch input.
	 */
	[super onEnter];
	
	/*
	 Set the initial position of the scroll, which is at the top of the image.
	 */
	CGPoint scrollLayerPosition = self.scrollLayer.position;
	scrollLayerPosition.y = 0;
	self.scrollLayer.position = scrollLayerPosition;
	
	/*
	 Default values are set for isDragging, previousScrollYPosition and scrollYVelocity.
	 */
	isDragging = NO;
	self.previousScrollYPosition = scrollLayerPosition.y;
	self.scrollYVelocity = 0.0f;
	
	/*
	 The intial state of the arrows is that the upArrow is invisible while the downArrow is visible.
	 An action sequence is created for each arrow to make it bounce up and down slightly to indicate
	 that the user can scroll.
	 */
	self.upArrow.visible = NO;
	self.downArrow.visible = YES;
	
	CCSequence *upArrowAnimation = [CCSequence actions:
								  [CCMoveBy actionWithDuration:0.5f position:ccp(0, -5)], 
								  [CCMoveBy actionWithDuration:0.5f position:ccp(0, +5)], 
								  nil];
	[upArrow runAction:[CCRepeatForever actionWithAction:upArrowAnimation]];
	
	CCSequence *downArrowAnimation = [CCSequence actions:
									[CCMoveBy actionWithDuration:0.5f position:ccp(0, +5)], 
									[CCMoveBy actionWithDuration:0.5f position:ccp(0, -5)], 
									nil];
	[downArrow runAction:[CCRepeatForever actionWithAction:downArrowAnimation]];

	/*
	 The scrollUpdate method is scheduled to call periodically in order to create incertia for the 
	 scrolling functionality.
	 */
	[self schedule:@selector(updateScroll:) interval:0.01f];
	
}

/*
 onExit is called just before the layer's dealloc method is called. This stops the
 running actions on both arrows to release the related memory.
 */
- (void) onExit {

	[super onExit];
	
	[upArrow stopAllActions];
	[downArrow stopAllActions];
	
}

/*
 Called when the layer is deallocated. Sets the weak pointers used for referencing cocos2D
 components to nil and then calls super dealloc. Releasing cocos2D components happens automatically
 when their parent CCNode is released.
 */
- (void) dealloc {
	
	upArrow = nil;
	downArrow = nil;
	scrollLayer = nil;
	[super dealloc];
	
}

#pragma mark -
#pragma mark Scrolling Methods

/*
 This method checks if the scrollLayer has reached the top or bottom of the
 content it contains. If so it stops the motion and makes the appropriate
 arrow invisible. If not then both arrows are made visible and the new
 scrollLayerPosition is returned as it is.
 */
- (CGPoint)checkBoundariesWithPosition:(CGPoint)scrollLayerPosition {
	
	CGSize winSize = [[CCDirector sharedDirector] winSize];	
	
	if (scrollLayerPosition.y <= 0) {
		
		scrollLayerPosition.y = 0;
		self.upArrow.visible = NO;
		
	} else if (scrollLayerPosition.y >= (self.contentHeight - (winSize.height - 10))){
		
		scrollLayerPosition.y = self.contentHeight - (winSize.height - 10);
		self.downArrow.visible = NO;
		
	} else {
		
		self.upArrow.visible = YES;
		self.downArrow.visible = YES;
		
	}
	
	return scrollLayerPosition;
	
}
/*
 This method is called regularly by the scheduler to create inertia in the scrollLayer.
 When the user drags their finger across the screen and then releases it the scroller 
 continues to move for a short time based on the speed of the drag.
 */
- (void) updateScroll: (ccTime)timeSinceLastCall {

	/*
	 friction is used to slow down the velocity of the scroll over time so that the 
	 scrolling stops after a certain distance. The behaviour of the scroll can be changed 
	 by increasing or decreasing this number. 
	 */
	float friction = 0.95f;
	
	/*
	 isDragging indicates if the user's finger is currently touching the screen. When this
	 is true then inertia should not be used and therefore the scroll moves relative to 
	 where the user drags their finger. Otherwise the scrollYVelocity should be used to move 
	 the scroll.
	 */
	if (!self.isDragging) {
		
		/*
		 The current scrollYVector is multiplied by the friction value above at each iteration.
		 This reduces the speed of the scroll slowly from it's initial value down to 0.
		 */
		self.scrollYVelocity = scrollYVelocity * friction;
		
		/*
		 The currentScrollYVelocity is added to the current scrollLayerPosition to move the 
		 scroll layer.
		 */
		CGPoint scrollLayerPosition = self.scrollLayer.position;
		scrollLayerPosition.y = scrollLayerPosition.y + self.scrollYVelocity;
		
		/*
		 Before the new position is applied to the scrollLayer the method above, checkBoundariesWithPosition,
		 is used to ensure that the scroller never moves off the content in the scrollLayer. This method also 
		 sets the visiblity of upArrow and downArrow. 
		 */
		self.scrollLayer.position = [self checkBoundariesWithPosition:scrollLayerPosition];
		
	} else {
		
		/*
		 If the user's finger is currently dragging across the screen then no velocity should be applied
		 to the scrollLayer position as it is being updated by the position of the users finger in the
		 ccTouchesMoved method. We only need to update the scrollYVelocity so that it will be up to date
		 when the touch ends.
		 */
		self.scrollYVelocity = (scrollLayer.position.y - previousScrollYPosition) / 2;
		self.previousScrollYPosition = scrollLayer.position.y;
	} 
	
}

#pragma mark -
#pragma mark Touch Delegate Methods

/*
 Called when a finger touches the device screen. Sets isDragging to true to indicate that
 the screen is being touched.
 */
- (void)ccTouchesBegan:(NSSet *)touch withEvent:(UIEvent *)event {

	isDragging = YES;
	
}

/*
 Called when a finger is dragged across the device screen. Moves the scrollLayer relative
 to the old and new positions of the touch.
 */
- (void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {

	UITouch *touch = [touches anyObject];
	
	/*
	 The difference between the current and previous touch locations is added to the scrollLayer's
	 position to move it. The convetToGl function is used because the OpenGL axis origin is in the
	 top left hand corner of the screen whereas the touch position is measured from an origin in the bottom left
	 hand corner.
	 */
	CGPoint previousTouchLocation = [[CCDirector sharedDirector] convertToGL:[touch previousLocationInView:touch.view]];
	CGPoint currentTouchLocation = [[CCDirector sharedDirector] convertToGL:[touch locationInView:touch.view]];
	
	CGPoint scrollLayerPosition = self.scrollLayer.position;
	scrollLayerPosition.y = scrollLayerPosition.y + (currentTouchLocation.y - previousTouchLocation.y);
	
	/*
	 Similar to the scrollUpdate method, before the new position is applied to the scrollLayer
	 checkBoundariesWithPosition is used to ensure that the scroller never moves off the content in the 
	 scrollLayer. This method also sets the visiblity of upArrow and downArrow. 
	 */
	scrollLayer.position = [self checkBoundariesWithPosition:scrollLayerPosition];
	
}

/*
 Called when all digits touching the device screen are removed. Sets isDragging to false to indicate that
 the touches have finished.
 */
- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {

	isDragging = NO;
	
}

#pragma mark -
#pragma mark Menu Related Methods

//Called when the cancel button is pressed. Calls the application delegate to hide the instructions.
- (void) menuItemPressed:(CCMenuItem *) menuItem {
	
	if (menuItem.tag == 1) {
		
		AberFighterAppDelegate *delegate = (AberFighterAppDelegate *) [UIApplication sharedApplication].delegate;
		[delegate hideInstructions];
		
	} 
	
}

@end
