//
//  ActionScene.m
//  AberFighter
//
//  Created by wde7 on 05/01/2011.
//  Copyright 2011 William Darius Elphick. All rights reserved.
//

#import "ActionLayer.h"
#import "MultilayerGameScene.h"
#import "UserInterfaceLayer.h"
#import "AberFighterAppDelegate.h"

#pragma mark -
#pragma mark ActionLayer

@implementation ActionLayer

#pragma mark -
#pragma mark ActionLayer Synthesized Properties

@synthesize spriteSheet; 
@synthesize countdownLabel;
@synthesize localPlayer;
@synthesize playerShips;
@synthesize projectiles;
@synthesize activeTargets;
@synthesize countdownFinished;
@synthesize countdown;
@synthesize gameTimeRemaining;
@synthesize previousTimeTargetSpawned;
@synthesize gameTimeRemainingRatio;

#pragma mark -
#pragma mark ActionLayer Initializers

/*
 For readability reasons the main initializer has been broken down into several 
 smaller methods called from the init method below.
 */

/*
 Creates the CCBitmapFontAtlas instances required in the layer. These are the labels which need to
 change values often.
 */
- (void)setUpLabels {
	
	CGSize winSize = [CCDirector sharedDirector].winSize;
	
	NSString *countdownLabelString = [NSString stringWithFormat:@"Ready?"];
	countdownLabel = [CCBitmapFontAtlas bitmapFontAtlasWithString:countdownLabelString fntFile:@"labels.fnt"];
	self.countdownLabel.position = ccp((winSize.width / 2), ((winSize.height - (kHUD_Y_POSITION * 2)) / 2));
	[self addChild:self.countdownLabel];
	
}

/*
 Initializer of this layer. Creates an instance of the layer by calling the superclass init method
 and adds the required components to it.
 */
- (id)init {
	
	if ((self = [super init])) {
		
		/*
		 Add a spritesheet based on the sprites.png texture and add it to the scene. Because this image 
		 has already been loaded into the CCTextureCache during the loading process a reference is passed 
		 to the existing texture.
		 */
		spriteSheet = [CCSpriteSheet spriteSheetWithTexture:[[CCTextureCache sharedTextureCache] addImage:@"sprites.png"]];
		[self addChild:self.spriteSheet z:-1];
		
		CGSize winSize = [CCDirector sharedDirector].winSize;
		
		/*
		 Add the background image to the spritesheet.
		 */
        CCSprite *background = [CCSprite spriteWithSpriteFrameName:@"starfield.png"];
        background.position = ccp(winSize.width/2, winSize.height/2);
        [spriteSheet addChild:background];
		
		/*
		 Call setUpLabels to create the countdown label.
		 */
		[self setUpLabels];
		
		/*
		 Initialize the projectiles and activeTargets arrays, which are used for collision detection.
		 They are empty when the game starts.
		 */
		self.projectiles = [[NSMutableArray alloc] init];
		self.activeTargets = [[NSMutableArray alloc] init];
		
		/*
		 Set the game time remaining to the game length selected in the GameOptionsLayer.
		 */
		self.gameTimeRemaining = [GameState sharedState].gameLength; 
		
		//Indicates whether the countdown has finished for when resuming the game after pausing.
		self.countdownFinished = NO;
		//Countdown starts from three to start the game.
		self.countdown = 3;
		//No targets have been spawned yet.
		self.previousTimeTargetSpawned = 0;
		//gameTimeRemainingRatio is initially 1 so that the game will startup with the minimum spawn rate.
		self.gameTimeRemainingRatio = 1;
		
	}
	return self;
	
}

/*
 Method which initializes and returns a PlayerShip instance based on the parameters passed to it.
 */
- (PlayerShip *)createPlayerShipWithSpriteFrameName:(NSString *)frameName position:(CGPoint)position heading:(float)heading maximumSpeed:(float)maximumSpeed {
	
	PlayerShip *newPlayerShip = [PlayerShip spriteWithSpriteFrameName:frameName];
	newPlayerShip.position = position;
	newPlayerShip.currentHeading = heading;
	newPlayerShip.rotation = heading;
	newPlayerShip.maximumSpeed = maximumSpeed;
	
	return newPlayerShip;
	
}

#pragma mark -
#pragma mark Game State Methods

/*
 Called when the countdown is over. Starts the iteration loops which drive the game.
 */
- (void)startGame {	
	
	//Sets the game state to running.
	[GameState sharedState].currentState = kGameRunning;
	
	//countdownFinished is now true so that the game will resume in the running state.
	self.countdownFinished = YES;
	
	/*
	 Begins the loops which drive the game, nextFrame, gameLogic and timer. nextFrame is called 60 times a second
	 along with the framerate while gameLogic only needs to be called ten times a second. Timer is called once a second.
	 */
	[self schedule:@selector(nextFrame:)];
	[self schedule:@selector(gameLogic:) interval:0.1f];
	[self schedule:@selector(timer:) interval:1.0f];
	
}

/*
 Called when the gameTimeRemaining reaches 0 or the Quit Game confirmation button is pressed.
 Calls the gameOver method in the ApplicationDelegate to show the next view.
 */
- (void)endGame {
	
	AberFighterAppDelegate *delegate = (AberFighterAppDelegate *) [UIApplication sharedApplication].delegate;
	[delegate gameOver];
	
}

#pragma mark -
#pragma mark Countdown Methods

/*
 This method updates the countdown label with a new string and begins an action sequence to make the label fade out then
 call the updateCountdown method.
 */
- (void)displayCountdown:(NSString *)countdownLabelString {
	
	[self.countdownLabel setString:countdownLabelString];
	self.countdownLabel.opacity = 100;
	
	id actionFade = [CCFadeOut actionWithDuration:0.9f];
	id actionFadeDone = [CCCallFuncN actionWithTarget:self 
											 selector:@selector(updateCountdown:)];
	[self.countdownLabel runAction:[CCSequence actions:actionFade, actionFadeDone, nil]];
	
}

/*
 Called by ccActions when they have finished fading out the countdown label.
 */
- (void)updateCountdown:(id)sender {
	
	/*
	 While countdown is greater than 0 the countdown label's value is the current value of the countdown.
	 The displayCountdown method above is called with the string created as a parameter and then countdown
	 is decremented.
	 */
	if (self.countdown > 0) {
		
		NSString *countdownLabelString = [NSString stringWithFormat:@"%d", countdown];
		[self displayCountdown:countdownLabelString];
		self.countdown--;
		
	} else if (self.countdown == 0) {
		
		/*
		 When countdown reaches 0 the last message, GO is displayed using the same method as above.
		 Countdown is decremented here so that on the next call to this method the countdownLabel will
		 be removed from the view. startGame is called to begin the main game iterators.
		 */
		NSString *countdownLabelString = [NSString stringWithFormat:@"GO!"];
		[self displayCountdown:countdownLabelString];
		self.countdown--;
		[self startGame];
		
	} else {
		
		/*
		 Countdown is less than 0, therefore the countdown is over and the countdownLabel is removed from
		 the layer.
		 */
		[self removeChild:countdownLabel cleanup:YES];
		countdownLabel = nil;
		
	}

	
}

/*
 Sets the GameState to GameStarting or GameRunning based on the countdownFinished boolean.
 */
- (void)resumeGame {
	
	if (self.countdownFinished == YES){
		
		//Set the current game state to running 
		[GameState sharedState].currentState = kGameRunning;
		
	} else {
		
		[GameState sharedState].currentState = kGameStarting;
		
	}
	
}

/*
 Called when the game is ready to begin. Starts the action sequence which runs the countdown.
 */
- (void)startCountdown {
	
	/*
	 This view uses accelerometer interaction. This boolean indicates
	 that the layer should receive accelerometer delegate method calls. The accelerometer is
	 activated at this point, three seconds before the sprite can actually move, so that the low-pass filter
	 in the DirectionalChangesCalculator can stabilise using values returned by the accelerometer.
	 */
	self.isAccelerometerEnabled = YES;
	[[UIAccelerometer sharedAccelerometer] setUpdateInterval:kActionAccelerometerUpdateInterval];
	
	/*
	 Create action sequence to fade out countdown label and call updateCountdown.
	 */
	id actionFade = [CCFadeOut actionWithDuration:2.5f];
	id actionFadeDone = [CCCallFuncN actionWithTarget:self 
											 selector:@selector(updateCountdown:)];
	[countdownLabel runAction:[CCSequence actions:actionFade, actionFadeDone, nil]];
	
}

#pragma mark -
#pragma mark Sprite Creation and Removal Methods

/*
 This method is called from various locations in this class to remove a sprite from the layer.
 */
- (void)clearUpSprite:(id)sender {
	
	CollidableSprite *sprite = (CollidableSprite *)sender;
	
	/*
	 The sprite which was passed to the method is removed from the spritesheet. The cleanup parameter
	 specifies whether all actions associated with the sprite should be stopped and released, which is
	 true in this case.
	 */
	[self.spriteSheet removeChild:sprite cleanup:YES];
	
	/*
	 All schedulers and actions on the sprite are stopped.
	 */
	[sprite unscheduleAllSelectors];
	[sprite stopAllActions];
	
	if (sprite.tag == 1) {
		
		/*
		 The tag 1 identifies a projectile sprite. Therefore the projectile is removed from the
		 projectiles list.
		 */
		[self.projectiles removeObject:sprite];
		
	} else if (sprite.tag == 2) {
		
		/*
		 The tag 2 identifies a TargetShip sprite. Therefore the sprite reference is cast to a 
		 TargetShip reference, then it is removed from the active targets list and the 
		 ReusableTargetPool is informed to make the TargetShip available once more.
		 */
		TargetShip *targetShip = (TargetShip *)sprite;
		[self.activeTargets removeObject:targetShip];
		[[ReusableTargetPool sharedInstance] releaseTargetShip:targetShip];
		
	}
	
}

/*
 Creates a Projectile instance at the specified location, initiates a CCAction sequence to move the projectile to
 the destination point and adds the projectile to the layer.
 */
- (void)fireProjectileWithStartingPosition:(CGPoint)startingPosition destinationPoint:(CGPoint)destinationPoint ship:(PlayerShip *)ship {
	
	/*
	 A new Projectile is instantiated with the projectile image.
	 */
	Projectile *newProjectile = [Projectile spriteWithSpriteFrameName:@"projectile.png"];
	
	/*
	 The tag assigned to projectiles is 1 to differentiate it from a TargetShip or other objects.
	 */
	newProjectile.tag = 1;
	//originatingPlayerID is used during collision detection to ensure that a player isn't
	//damaged by their own projectiles.
	newProjectile.originatingPlayerID = ship.playerID; 
	newProjectile.rotation = ship.rotation;
	
	/*
	 The speed of the projectile is represented by the time it will take the projectile
	 to travel from it's starting location the distance calculated above (speed = distance / time).
	 */
	ccTime projectileSpeed = 1.0f;
	
	/*
	 An action sequence is initiated on the new projectile which will move it along the 
	 projectileDestinationVector in the time denoted by projectileSpeed, then call clearUpSprite
	 to remove the projectile when it is finished.
	 */
	[newProjectile runAction:[CCSequence actions:
							  [CCMoveBy actionWithDuration:projectileSpeed position:destinationPoint],
							  [CCCallFuncN actionWithTarget:self selector:@selector(clearUpSprite:)],
							  nil]];
	
	/*
	 The initial position of the projectile is now set because all calculation 
	 and configuration is complete.
	 */
	newProjectile.position = startingPosition;
	
	/*
	 The new projectile is added to the spritesheet for display and the projectiles
	 array for use in collision detection.
	 */
	[self.spriteSheet addChild:newProjectile]; 
	[self.projectiles addObject:newProjectile];
	
	/*
	 The new projectile is retained by the spritesheet and the projectiles array,
	 therefore the pointer in this method can be set to nil.
	 */
	newProjectile = nil;
	
}

/*
 This method is called from the UserInterfaceLayer when it detects a touch in the lower
 corners of the screen. It performs the calculations needed to find the starting position and 
 destination point of the projectile. It then calls fireProjectileWithStartingPositionDestinationPointShip to 
 initiate the process.
 */
- (void)fireProjectile {
	
	/*
	 If the local player's ship is currently disabled then firing weapons is not permitted.
	 It is also not permitted for projectiles to be fired when the game start countdown is taking place, 
	 which is indicated by the current game state kGameStarting.
	 */
	if([GameState sharedState].currentState == kGameRunning && !self.localPlayer.shipDisabled) {
		
		/*
		 The projectile is spawned at the front of the ship. The position of this is
		 calculated using the ship's radius and rotation applied to the sine and
		 cosine rules and added to the current position of the ship.
		 */
		float shipHeight = self.localPlayer.contentSize.height / 2.0f;
		float shipRotation = self.localPlayer.rotation;
		
		float xOffset = sin(CC_DEGREES_TO_RADIANS(shipRotation)) * shipHeight;
		float yOffset = cos(CC_DEGREES_TO_RADIANS(shipRotation)) * shipHeight;
		
		float projectileXPosition = self.localPlayer.position.x + xOffset;		
		float projectileYPosition = self.localPlayer.position.y + yOffset;	
		
		CGPoint startingPosition = ccp(projectileXPosition, projectileYPosition);
		
		/*
		 The vector along which the projectile will travel is indicated by the x and y offsets 
		 calculated above.
		 */
		CGPoint fireVector = ccp(xOffset, yOffset); 
		
		/*
		 The furthest distance which can be travelled across the device's screen,
		 a diagonal line from one corner to another, is calculated. This is how far the 
		 projectile will travel to ensure that it is offscreen before being removed.
		 */
		CGSize winSize = [CCDirector sharedDirector].winSize;
		float firingDistance = sqrt(pow(winSize.width, 2) + pow(winSize.height, 2));
		
		/*
		 The fire vector is normalized i.e. it's length is converted to 1.
		 */
		CGPoint normalizedFireVector = ccpNormalize(fireVector);
		
		/*
		 The destination vector of the projectile (i.e. the direction and distance by which it needs to 
		 travel in order to be offscreen) is calculated using ccpMult.
		 */
		CGPoint projectileDestinationVector = ccpMult(normalizedFireVector, firingDistance);
		
		/*
		 The values calculated are passed to the fireProjectileWithStartingPositionDestinationPointShip.
		 */
		[self fireProjectileWithStartingPosition:startingPosition 
								destinationPoint:projectileDestinationVector 
											ship:self.localPlayer];
		
	}
	
}

/*
 Returns a random TargetType, with large ships being less likely to appear than small ones.
 */
- (TargetType)determineSpawnedTargetType {
	
	/*
	 The probability of each target ship type appearing is added together to get the total probability.
	 */
	int totalProbability = kTargetShipLargeAppearanceProbability + 
	kTargetShipSmallAppearanceProbability;
	/*
	 A random number between 0 and the totalProbability is generated. Each TargetShip type has a probability
	 of appearing associated with it. The if statement below determines which ship type will be spawned.  
	 */
	int randomTargetTypeSpawnFactor = arc4random() % totalProbability;
	int targetShipType;
	
	/*
	 If the number generated is less than the probability of a Large Ship Appearing, then the target type to 
	 be spawned is the large type. Otherwise the small target ship type will be spawned.
	 */
	if (randomTargetTypeSpawnFactor < kTargetShipLargeAppearanceProbability) {
		
		targetShipType = kTargetShipLarge;
		
	} else {
		
		targetShipType = kTargetShipSmall;
		
	}
	
	return targetShipType;
	
}

/*
 This method is called from the gameLogic method when the spawnRate has been reached.
 It acquires a target of a random type from the ReusableTargetPool, configures it
 and adds it to the layer.
 */
- (void)spawnTarget {
	
	int targetShipType = [self determineSpawnedTargetType];	
	
	/*
	 A TargetShip instance of the specified type is requested from the ReusableTargetPool. If one is
	 available, a reference will be returned. Otherwise the pool will return nil. In this is the case no target
	 will be spawned during this iteration. 
	 */
	TargetShip *newTarget = [[ReusableTargetPool sharedInstance] acquireTargetShipWithType:targetShipType];
	if (newTarget != nil) {
		
		/*
		 A new target has been acquired. The generateRandomStartingPositionAndHeading method sets the initial 
		 state of the target ship.
		 */
		[newTarget generateRandomStartingPositionAndHeading];
		
		/*
		 Add the new target ship to the activeTargets list and the spritesheet. From now on it's movement
		 will be handled by calls to it's updatePosition method from the nextFrame method below.   
		 */
		[self.activeTargets addObject:newTarget];
		[self.spriteSheet addChild:newTarget];
		
		/*
		 The newTarget has been retained by adding it to both the spritesheet and the activeTargets list. 
		 Therefore this reference can be set to nil without losing the auto-release object.
		 */
		newTarget = nil;
		
	}
	
}

/*
 This method is called when a TargetShip is destroyed. It creates a label which indicates the points awarded
 for destroying the Target and adds it to the layer in the position the TargetShip instance used to occupy.
 */
- (void)showRewardLabelWithValue:(int)reward position:(CGPoint)position {

	/*
	 Create a red label which shows the score in the parameters.
	 */
	NSString *rewardLabelString = [NSString stringWithFormat:@"+%d", reward];
	
	CCLabel *rewardLabel = [CCLabel labelWithString:rewardLabelString fontName:@"Arial" fontSize:20];
	rewardLabel.color = ccc3(255, 0, 0);
	rewardLabel.position = position;
	
	/*
	 2 actions are run simultaneously on the label. The first causes the label to move upwards slightly. 
	 The second causes the label to fade out then call the removeRewardLabelWithId method. 
	 */
	CCAction *moveAction = [CCMoveBy actionWithDuration:1.0f position:ccp(0, +20)];
	CCAction *fadeAction = [CCSequence actions:
							 [CCFadeOut actionWithDuration:1.0f],
							 [CCCallFuncN actionWithTarget:self selector:@selector(removeRewardLabelWithId:)],
							 nil];
	[rewardLabel runAction:moveAction];
	[rewardLabel runAction:fadeAction];
	[self addChild:rewardLabel z:1];
	
}

/*
 Removes and label from the view and releases it.
 */
- (void)removeRewardLabelWithId:(id)sender {
	
	CCLabel *label = (CCLabel *)sender;
	[self removeChild:label cleanup:YES];
	
}


#pragma mark -
#pragma mark End Of Game Clearup Methods 

/*
 Called at the end of the game to stop the main game iterators and remove the TargetShip and
 Projectile instances currently on the layer.
 */
- (void)clearUpGameComponents {
	
	/*
	 Unschedule the main game iterators.
	 */
	[self unscheduleAllSelectors];
	
	/*
	 Stop all possible actions on the countdownLabel. This was causing a memory leak at one point because the 
	 action layer was still being referenced by this.
	 */
	[countdownLabel stopAllActions];
	
	/*
	 Remove the reference to this layer as the accelerometer delegate.
	 */
	if (self.isAccelerometerEnabled && [[UIAccelerometer sharedAccelerometer] delegate] == self) {
		self.isAccelerometerEnabled = NO;
	}
	
	/*
	 Call clearUpSprite on all projectiles to release them.
	 */
	while ([self.projectiles count] > 0) {
		
		[self clearUpSprite:[self.projectiles objectAtIndex:0]];
		
	}
	
	/*
	 Call clearUpSprite on all active targets to release them back to
	 the ReusableTargetPool.
	 */
	while ([self.activeTargets count] > 0) {
		
		[self clearUpSprite:[self.activeTargets objectAtIndex:0]];
		
	}
	
}

#pragma mark -
#pragma mark Menu, Accelerometer and Touch Delegate Methods
/*
 Called by the accelerometer to update this class at regular intervals of the current acceleration values.
 */
- (void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration {
	
	DirectionalChanges *directionalChanges;
	
	/*
	 Depending on the accelerometerControlMethod variable in the GameState, either the default or alternative control
	 scheme method is used to produce DirectionalChanges for the ship.
	 */
	if ([GameState sharedState].accelerometerControlMethod == 1) {
	
		directionalChanges = [DirectionalChangesCalculator calculateDirectionalChangesWithAcceleration:acceleration];
		
	} else {
	
		directionalChanges = [DirectionalChangesCalculator calculateDirectionalChangesWithAcceleration:acceleration
																							   heading:localPlayer.currentHeading
																								 speed:localPlayer.speed];
		
	}
	/*
	 If the game isn't running then directional changes shouldn't be applied to the ship. 
	 */
	if ([GameState sharedState].currentState == kGameRunning) {
	
		/*
		 Calls the applyDirectionalChanges method of the local PlayerShip class to apply changes to heading and speed.
		 */
		[self.localPlayer applyDirectionalChangesWithNewHeading:directionalChanges.newHeading 
													   newSpeed:directionalChanges.newSpeed];
		
	}

	directionalChanges = nil;
	
}

#pragma mark -
#pragma mark Main Game Iterators and Logic

/*
 Called 60 times a second (the framerate) to update the state of the entities in the game 
 and perform collision detection. 
 */
- (void)nextFrame:(ccTime)timeSinceLastCall {
	
	BOOL collisionDetected;
	BOOL targetDestroyed;
	
	/*
	 Sprites which need to be removed are added to this array so that they can be removed at the 
	 end of the collision detection algorithm.
	 */
	NSMutableArray *spritesToClearUp = [[NSMutableArray alloc] init];
	
	/*
	 Firstly all PlayerShip instances are compared with projectile instances to discover collisions.
	 */
	for(PlayerShip *currentPlayer in self.playerShips) {
		/*
		 Ships which are disabled can't be collided with.
		 */
		if (!currentPlayer.shipDisabled) {
			/*
			 This method, located in the PlayerShip class, updates the position and rotation of the ship.
			 */
			[currentPlayer updatePosition:timeSinceLastCall];
			
			for (Projectile *currentProjectile in self.projectiles) {
				
				/*
				 The checkCollisionWithCollidableSprite method returns a boolean indicating if the 
				 PlayerShip is in collision with the current projectile.
				 */
				collisionDetected = [currentProjectile checkCollisionWithCollidableSprite:currentPlayer]; 
				
				/*
				 Only projectiles fired by another player should damage the ship. 
				 */
				if (collisionDetected && (currentProjectile.originatingPlayerID != currentPlayer.playerID)) {
					
					[spritesToClearUp addObject:currentProjectile];
					[currentPlayer reduceShieldStrength];
					[[GameState sharedState] rewardPlayer:currentProjectile.originatingPlayerID
												   points:50];
					
				}
				
			}
		
		}
		
	}
	
	/*
	 Next all TargetShip instances are updated and then compared with all projectiles.
	 */
	for (TargetShip *currentTarget in self.activeTargets) {
		
		//TargetDestroyed is used to ensure that a destroyed target is not compared against any other sprites.
		targetDestroyed = NO;
		
		//Update the position of the target.
		[currentTarget updatePosition:timeSinceLastCall];
		
		/*
		 If the currentTarget is offscreen then no collision detection is performed.
		 */
		if ([currentTarget checkIfOffscreen]) 
			continue;
		
		for (Projectile *currentProjectile in self.projectiles) {
			
			/*
			 If a projectile has already collided with an object earlier in the algorithm then it can't 
			 be compared again.
			 */
			if (currentProjectile.hasCollided)
				continue;
			
			collisionDetected = [currentProjectile checkCollisionWithCollidableSprite:currentTarget];
			
			/*
			 If a collision is detected then the projectile is added to the sprites which need clearing up and 
			 the TargetShip's shields are decremented. If the target is destroyed then it is also added to the 
			 sprites to clear up and the correct player is rewarded.
			 */
			if (collisionDetected) {
				
				[spritesToClearUp addObject:currentProjectile];
				
				targetDestroyed = [currentTarget reduceShieldStrength];
				
				if (targetDestroyed) {
					
					[[GameState sharedState] rewardPlayer:currentProjectile.originatingPlayerID
												   points:currentTarget.scoreAwarded];
					[self showRewardLabelWithValue:currentTarget.scoreAwarded 
										  position:currentTarget.position];
					[spritesToClearUp addObject:currentTarget];
					break;
					
				}
				
			}
				
		}
		
		/*
		 If the target has been destroyed then it is not compared with any PlayerShips.
		 */
		if (targetDestroyed)
			continue;
		
		/*
		 Compare all PlayerShips against TargetShips for collisions. Disabled PlayerShips 
		 arent compared.
		 */
		for(PlayerShip *currentPlayer in self.playerShips) {
			
			if (!currentPlayer.shipDisabled) {
				
				collisionDetected = [currentTarget checkCollisionWithCollidableSprite:currentPlayer];
				
				if (collisionDetected) {
					
					[currentPlayer reduceShieldStrength];
					
					targetDestroyed = [currentTarget reduceShieldStrength];
					
					if (targetDestroyed) {
						
						[[GameState sharedState] rewardPlayer:currentPlayer.playerID
													   points:currentTarget.scoreAwarded];
						[self showRewardLabelWithValue:currentTarget.scoreAwarded 
											  position:currentTarget.position];
						[spritesToClearUp addObject:currentTarget];
						break;
						
					}
					
				}
			
			}
			
		}
		
	}
	
	/*
	 Clear up any ships or projectiles which were destroyed during this iteration.
	 */
	for (CollidableSprite *currentSprite in spritesToClearUp) {
	
		[self clearUpSprite:currentSprite];
		
	}
	
	[spritesToClearUp release];
	
}

- (void)checkTargetSpawningSituation {
	
	double now = [[NSDate date] timeIntervalSince1970];
	
	/*
	 The spawn rate increases as the game time remaining decreases. This is because
	 gameTimeRemainingRatio = gameTimeRemaining / game length, which will decrease from 1 to
	 0 over the course of the game. Therefore initially spawnRate = kMaximumSpawnRate + (1(kSpawnRateModifier)),
	 and towards the end of the game spawnRate = kMaximumSpawnRate + (0(kSpawnRateModifier)).
	 */
	double spawnRate =  kMaximumSpawnRate + (self.gameTimeRemainingRatio * kSpawnRateModifier);
	
	/*
	 At the start of the game or when the difference between now and the previous time a target was spawned
	 is greater than the spawn rate, then spawnTarget is called to add a new target to the game and the previous
	 time a target was spawned is updated.
	 */
	if (self.previousTimeTargetSpawned == 0 || (now - self.previousTimeTargetSpawned) >= spawnRate) {
		[self spawnTarget];
		self.previousTimeTargetSpawned = now;
	}
	
}

- (void)clearOffscreenTargets {
	
	/*
	 We iterate over the active targets and determine if any need to be cleared up. This is indicated 
	 by the minimumLifetimeExpired boolean being set to true and the current target's checkIfOffscreen method
	 returning true. In this case the clearUpSprite method is called to remove the target from the layer and 
	 return it to the ReusableTargetPool.
	 */
	for(int i = 0; i < [self.activeTargets count]; i++) {
		
		TargetShip *targetShip = [self.activeTargets objectAtIndex:i];
		
		if (targetShip.minimumLifetimeExpired && [targetShip checkIfOffscreen]) {
			
			[self clearUpSprite:targetShip];
			
		}
		
	}
	
}

/*
 Called 10 times a second. Used for spawning enemies and clearing up enemies which 
 have reached the end of their lifespan.
 */
- (void)gameLogic:(ccTime)timeSinceLastCall {
	
	[self checkTargetSpawningSituation];
	
	[self clearOffscreenTargets];
	
	
}

/*
 The timer method is called every second to update the time remaining in the game.
 It also determines if the game is over and if not updates the gameTimeRemainingRatio 
 to increase the spawn rate in the gameLogic loop.
 */
- (void)timer:(ccTime)timeSinceLastCall {
	
	self.gameTimeRemaining--;
	
	UserInterfaceLayer* uiLayer = [MultilayerGameScene sharedScene].userInterfaceLayer;
	[uiLayer updateTimeLabel:self.gameTimeRemaining];
		
	/*
	 Once the time remaining reaches 0 call endGame to finish the game.
	 */
	if (self.gameTimeRemaining <= 0) {
		
		[self endGame];
		
	} else {
		
		/*
		 Update the game time remaining ratio for use in the gameLogic method. 
		 */
		self.gameTimeRemainingRatio = (float)self.gameTimeRemaining / (float)[GameState sharedState].gameLength;
		
	}

		
}

#pragma mark -
#pragma mark ActionLayer Superclass Overrides

/*
 Called every frame to draw game components contained in the layer. It is overidden to draw the 
 player shields and the target status indicators.
 */
- (void)draw {
	
	/*
	 Draw a circle representing a shield on top of every player. The color of the shield is
	 relative to the current shield strength of the player compared to their maximum shield 
	 strength.
	 */
	for (PlayerShip *currentPlayer in self.playerShips) {
		
		/*
		 If the player's ship is disabled then there's no need to draw a shield around them.
		 */
		if (!currentPlayer.shipDisabled) {
			
			/*
			 The shield is circular and encompasses the entire area of the ship. Therefore it's
			 radius is half the size of the ship and it's centered in the middle of the image.
			 */
			float shieldRadius = currentPlayer.contentSize.height / 2;
			CGPoint shieldLocation = currentPlayer.position;
			
			/*
			 If the ship is invincible then a special Gold shield is frawn over them.
			 */
			if (currentPlayer.invincible) {
				
				glColor4f(0.83f, 0.69f, 0.22f, 0.0f);
				
			} else {
				
				/*
				 Shield strength is the ratio of the currentShieldStrength compared to the maximum
				 shield strength. This is the amount of the positive color (in this case blue) which
				 is contained in the shield colour. The amount of negative shield color (in this case red)
				 is 1 - the ratio.
				 */
				float shieldStrength = (float)currentPlayer.currentShieldStrength / (float)currentPlayer.maximumShieldStrength;
				float blueProportion = shieldStrength;
				float redProportion = (1.0f - shieldStrength);
				
				/*
				 The circle is drawn over the player using the colour, size and position values calculated above
				 and the rotation of the ship is used. 
				 */
				glColor4f(redProportion, 0.0f, blueProportion, 0.0f);
				
			}
			glLineWidth(2);
			ccDrawCircle(shieldLocation, shieldRadius, currentPlayer.rotation, 12, NO);
		}
	}
	
	/*
	 Draw a small circle representing a status indicator on top of every active target. 
	 As with players, the color of the indicator is relative to the current shield strength
	 of the target compared to it's maximum shield strength.
	 */
	for (TargetShip *currentTarget in self.activeTargets) {
		
		/*
		 The indicator is circular and small, not covering the entire target ship. Therefore it's
		 radius is 1/12 the size of the ship and it's centered in the middle of the image.
		 */
		float shieldRadius = currentTarget.contentSize.height / 12;
		CGPoint shieldLocation = currentTarget.position;
		
		/*
		 Once again, shield strength is the ratio of the currentShieldStrength compared to the maximum
		 shield strength. The positive colour in this case is green and the negative color, 1 - the ratio,
		 is once again red.
		 */
		float shieldStrength = (float)currentTarget.currentShieldStrength / (float)currentTarget.maximumShieldStrength;
		float greenProportion = shieldStrength;
		float redProportion = (1.0f - shieldStrength);
		
		/*
		 The circle is drawn on top of the target using the colour, size and position values calculated above
		 and the rotation of the ship. 
		 */
		glLineWidth(2);
		glColor4f(redProportion, greenProportion, 0.0f, 0.0f);
		ccDrawCircle(shieldLocation, shieldRadius, 0, 12, NO);
		
	}
	
	/*
	 The superclass draw method renders the sprites located in the layer.
	 */
	[super draw];
	
}

/*
 Called when the layer is deallocated. Sets the weak pointers used for referencing cocos2D
 components to nil and then calls super dealloc. Releasing cocos2D components happens automatically
 when their parent CCNode is released. It also releases the sprite arrays used in the layer for
 containing PlayerShip, TargetShip and Projectile instances.
 */
- (void)dealloc {
	
	spriteSheet = nil;
	countdownLabel = nil;
	[localPlayer unscheduleAllSelectors];
	localPlayer = nil;
	[playerShips release];
	self.playerShips = nil;
	[projectiles release];
	self.projectiles = nil;
	[activeTargets release];
	self.activeTargets = nil;
	
	[super dealloc];
	
}

@end
