//
//  BluetoothManager.m
//  AberFighter
//
//  Created by wde7 on 21/03/2011.
//  Copyright 2011 William Darius Elphick. All rights reserved.
//

#import "BluetoothCommsManager.h"
#import "MultilayerGameScene.h"
#import "MultiplayerActionLayer.h"

#pragma mark -
#pragma mark BluetoothCommsManager
/*
 The maximum NetworkDataPacketSize is 1024 bytes.
 */
#define kNetworkDataPacketSize 1024

const float kMaximumNetworkHeartbeatInterval = 2.0f;

@implementation BluetoothCommsManager

#pragma mark -
#pragma mark BluetoothCommsManager Synthesized Properties

@synthesize currentBluetoothSession;
@synthesize peerIDs;
@synthesize playerID;
@synthesize localActionLayerReady;
@synthesize pauseMenuAcknowledgedPacketReceipt;
@synthesize networkHeartbeatGenerator;
@synthesize lastHeartbeatDate;
@synthesize attemptingNetworkReconnect;

#pragma mark -
#pragma mark BluetoothCommsManager Initializers

/*
 Singleton Instance
 */
static BluetoothCommsManager *sharedInstance = nil;

/*
 Retrieve singleton instance
 */
+ (BluetoothCommsManager *)sharedInstance {

	if (!sharedInstance) {
		
		sharedInstance = [[BluetoothCommsManager alloc] init];
		
	}
	
	return sharedInstance;
	
}

/*
 Reset Die Roll State.
 */
- (void)resetDieState {
	
	localDieRoll = kDieNotRolled;
	peerDieRoll = kDieNotRolled;
	peerDieRollReceived = NO;
	dieRollAcknowledged = NO;
	
}

/*
 The layer state indicators are used to check when the action layer and pause menu layers are available.
 */
- (void)resetLayerStateIndicators {
	
	localActionLayerReady = NO;
	pauseMenuAcknowledgedPacketReceipt = NO;
	
}

/*
 The heartbeat generator is reset when the session is cleared up.
 */
- (void)resetHeartbeatGenerator {

	if (networkHeartbeatGenerator != nil) {
		
		[networkHeartbeatGenerator invalidate];
		networkHeartbeatGenerator = nil;
		
	}
	lastHeartbeatDate = nil;
	attemptingNetworkReconnect = NO;
	
}

/*
 Initializer of this class. Creates an instance of the class by calling the superclass init method
 and adds the required components to it.
 */
- (id)init{

	if ((self = [super init])) {
		
		packetNumber = 0;
		previousPacketNumber = -1;
		playerID = kPlayerUndecided;
		[self resetDieState];
		[self resetLayerStateIndicators];
		[self resetHeartbeatGenerator];
		
		peerIDs = [[NSMutableArray alloc] init];
		
	}
	
	return self;
	
}

/*
 Create a new GKSession instance for use by the peer picker.
 */
- (GKSession *)setUpNewSession {
	
	NSAssert(currentBluetoothSession == nil, @"Trying to set up new session when one already exists");
	currentBluetoothSession = [[GKSession alloc] initWithSessionID:kAberFighterBluetoothSessionID
													   displayName:nil 
													   sessionMode:GKSessionModePeer];
	
	return currentBluetoothSession;	

}

/*
 Returns the BluetoothCommsManager to it's original state.
 */
- (void)clearUpSession {

	if (currentBluetoothSession != nil) {
		currentBluetoothSession.available = NO;
		[currentBluetoothSession disconnectFromAllPeers];
		currentBluetoothSession.delegate = nil;
		[currentBluetoothSession setDataReceiveHandler:nil withContext:nil];
		[currentBluetoothSession release];
		currentBluetoothSession = nil;
	}
	
	[peerIDs removeAllObjects];
	playerID = kPlayerUndecided;
	packetNumber = 0;
	previousPacketNumber = -1;
	
	[self resetLayerStateIndicators];
	[self resetHeartbeatGenerator];
	
}

/*
 Called when the session fails. Posts a notification on the NSNotificationCenter and resets the BluetoothCommsManager.
 */
- (void)session:(GKSession *)session didFailWithError:(NSError *)error {
	
	NSLog(@"Error: %@", [error localizedDescription]);
	
	NSDictionary *data = [NSDictionary dictionaryWithObject:error forKey:@"error"];
	
	NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
	[notificationCenter postNotificationName:SessionFailedWithError object:self userInfo:data]; 
	
	[self clearUpSession];
	
}

/*
 When the peer changes state this method is called. This checks if the Peer Disconnected, posts a notification
 and resets the BluetoothCommsManager. 
 */
- (void)session:(GKSession *)session peer:(NSString *)peerID didChangeState:(GKPeerConnectionState)state {
	
	if (state == GKPeerStateDisconnected) {
			
		NSDictionary *data = [NSDictionary dictionaryWithObject:peerID forKey:@"peerID"];
		
		NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
		[notificationCenter postNotificationName:PeerWasDisconnected object:self userInfo:data];
		
		[self clearUpSession];
	}
	
}

#pragma mark -
#pragma mark BluetoothCommsManager Initializers

/*
 This method implements the die roll functionality used for determining the player ID of each device.
 This method is only called after the dieRoll sent has been acknowledged and the peer die roll has been received.
 */
- (void)determinePlayerIdentifiers {
	
	NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
	NSString *notificationName;
	
	/*
	 If the localDieRoll matches the peerDieRoll then the die roll must be restarted. 
	 */
	if (localDieRoll == peerDieRoll) {
		
		playerID = kPlayerUndecided;
		[self resetDieState];
		[self sendNewDieRollPacket];
		notificationName = RestartingDieRoll;
		
	} else if (localDieRoll > peerDieRoll) {
		
		/*
		 If the localDieRoll is greater than the peerDieRoll then
		 this device is player 1.
		 */
		playerID = kPlayer1;
		notificationName = DieRollFinished;
		
	} else {
		
		/*
		 Else this device is player 2
		 */
		playerID = kPlayer2;
		notificationName = DieRollFinished;

	}
	
	/*
	 Post a notification to alert of the current die roll state. 
	 */
	[notificationCenter postNotificationName:notificationName object:self];
	[self resetDieState];
	
	if (playerID != kPlayerUndecided) {
		
		networkHeartbeatGenerator = [NSTimer scheduledTimerWithTimeInterval:kNetworkHeartbeatFrequency
																	 target:self
																   selector:@selector(networkHeartbeat:) 
																   userInfo:nil 
																	repeats:YES];
	}
	
}

/*
 When the heartbeat is received the lastHeartbeatData is updated. If the status was 
 attemptingNetworkReconnect then it is set to false.
 */
- (void)peerHeartbeatReceived {
	
	self.lastHeartbeatDate = [NSDate date];
	if (attemptingNetworkReconnect) {
		
		attemptingNetworkReconnect = NO;
		[[NSNotificationCenter defaultCenter] postNotificationName:PeerFound 
															object:self 
														  userInfo:nil];
		
	}
	
}

/*
 This method ensures that the network is behaving as expected by sending heartbeat packets across every half second which should
 be answered by the peer. It checks the difference between the current time and the last heartbeat date. If 
 this is greater than two seconds then the status changes to attemptingNetworkReconnect and a notification is 
 posted to the layers so that they can alert the user. 
 */
- (void)networkHeartbeat:(NSTimer *)timer {

	if (lastHeartbeatDate == nil) {
		
		self.lastHeartbeatDate = [NSDate date];
		
	} else if (fabs([lastHeartbeatDate timeIntervalSinceNow]) >= kMaximumNetworkHeartbeatInterval) {
		
		attemptingNetworkReconnect = YES;
		
		[[NSNotificationCenter defaultCenter] postNotificationName:PeerLost 
															object:self 
														  userInfo:nil];
		
	} else if (attemptingNetworkReconnect == YES) {
			
			attemptingNetworkReconnect = NO;
			[[NSNotificationCenter defaultCenter] postNotificationName:PeerFound 
																object:self 
															  userInfo:nil];
		
	}

	/*
	 When the app is running then the Directional data is sent often enough to compensate for the 
	 heartbeat and therefore replaces it.
	 */
	if ([GameState sharedState].currentState != kGameRunning) {
		
		[self sendPacketWithType:kPacketTypePeerHeartbeat 
					dataLocation:nil 
					  dataLength:0 
						reliable:NO];
		
	}

}

- (void)postNewGameLengthNotificationWithValue:(int)newGameLength {
	
	NSNumber *newGameLengthWrapper = [NSNumber numberWithInt:newGameLength];
	NSDictionary *dataDictionary = [NSDictionary dictionaryWithObject:newGameLengthWrapper forKey:@"newGameLength"];
	[[NSNotificationCenter defaultCenter] postNotificationName:NewGameLengthReceived 
														object:self 
													  userInfo:dataDictionary];
	
}

- (void)acknowledgePlayerReady {
	
	[[NSNotificationCenter defaultCenter] postNotificationName:PeerReadyToPlay 
														object:self 
													  userInfo:nil];
	
}

- (void)playerReadyAcknowledgementReceived {

	[[NSNotificationCenter defaultCenter] postNotificationName:LocalPlayerReadyAcknowledged 
														object:self 
													  userInfo:nil];
	
}

- (void)postGameCancelledNotification {
	
	[[NSNotificationCenter defaultCenter] postNotificationName:PeerCancelledGame 
														object:self 
													  userInfo:nil];
	
}

- (void) actionLayerStatusCheck:(NSTimer *)timer {

	if (localActionLayerReady) {
		
		[timer invalidate];
		[[NSNotificationCenter defaultCenter] postNotificationName:PeerActionLayerReady 
															object:self 
														  userInfo:nil];
		
	}
	
}

- (void)acknowledgeActionLayerReady {
	
	if (localActionLayerReady) {
		
		[[NSNotificationCenter defaultCenter] postNotificationName:PeerActionLayerReady 
															object:self 
														  userInfo:nil];
	
	} else {
		
		[NSTimer scheduledTimerWithTimeInterval:1.0/10.0 
										 target:self
									   selector:@selector(actionLayerStatusCheck:) 
									   userInfo:nil 
										repeats:YES];
		
	}

					
}

- (void)actionLayerReadyAcknowledgementReceived {
	
	[[NSNotificationCenter defaultCenter] postNotificationName:ActionLayerReadyAcknowledged 
														object:self 
													  userInfo:nil];
	
}

/*
 The peer directional data is applied directly to the peerPlayer in the MultiplayerActionLayer
 using the reference available in the MultilayerGameScene. This avoids the overhead involved in
 sending data through the notification system. This is the same for TargetShipDetails and Projectile Details.
 */
- (void)processPeerPlayerDirectionalDataReceived:(void *)directionalData {
	
	self.lastHeartbeatDate = [NSDate date];
	
	PlayerShipDirectionalInformation *directionalInformation = (PlayerShipDirectionalInformation *)directionalData;
	
	MultiplayerActionLayer *actionLayer = (MultiplayerActionLayer *)[MultilayerGameScene sharedScene].actionLayer;
	
	[actionLayer.peerPlayer applyDirectionalChangesWithNewHeading:directionalInformation->newHeading
														 newSpeed:directionalInformation->newSpeed];
	actionLayer.peerPlayer.position = directionalInformation -> currentPosition;
	actionLayer.peerPlayer.rotation = directionalInformation -> currentRotation;
	
}

- (void)processTargetShipDetailsReceived:(void *)targetShipDetails {
	
	TargetShipDetails *targetData = (TargetShipDetails *)targetShipDetails;
	
	MultiplayerActionLayer *actionLayer = (MultiplayerActionLayer *)[MultilayerGameScene sharedScene].actionLayer;
	
	[actionLayer spawnTargetWithType:targetData -> targetShipType 
							 heading:targetData -> currentHeading 
					startingPosition:targetData -> startingPosition];

}

- (void)processProjectileDetailsReceived:(void *)projectileDetails {
	
	ProjectileDetails *projectileData = (ProjectileDetails *)projectileDetails;
	
	MultiplayerActionLayer *actionLayer = (MultiplayerActionLayer *)[MultilayerGameScene sharedScene].actionLayer;
	
	[actionLayer fireProjectileWithStartingPosition:projectileData->startingPosition 
								   destinationPoint:projectileData->destinationPoint
											   ship:actionLayer.peerPlayer];
	
}

- (void)postPeerPausedGameNotification {
	
	[[NSNotificationCenter defaultCenter] postNotificationName:PeerPausedGame 
														object:self 
													  userInfo:nil];
	
}

- (void)postPeerResumedGameNotification:(NSTimer *)timer {
	
	if (pauseMenuAcknowledgedPacketReceipt) {
		
		[timer invalidate];
		
	} else {
		
		[[NSNotificationCenter defaultCenter] postNotificationName:PeerResumedGame 
															object:self 
														  userInfo:nil];		
		
	}
	
}

- (void)schedulePeerResumedGameNotificationTimer {
	
	pauseMenuAcknowledgedPacketReceipt = NO;
	
	[NSTimer scheduledTimerWithTimeInterval:1.0/10.0 
									 target:self
								   selector:@selector(postPeerResumedGameNotification:) 
								   userInfo:nil 
									repeats:YES];
	
}

- (void)postPeerResumedGameAcknowledgedNotification {

	[[NSNotificationCenter defaultCenter] postNotificationName:PeerResumedGameAcknowledged 
														object:self 
													  userInfo:nil];
	
}

- (void)postPeerQuitGameNotification {
	
	[[NSNotificationCenter defaultCenter] postNotificationName:PeerQuitGame 
														object:self 
													  userInfo:nil];
	
}

/*
 This method extracts data from the NSData instance received over the network.
 */
- (void)receiveData:(NSData *)data fromPeer:(NSString *)peerID 
		  inSession:(GKSession *)session context:(void *)context {
	
	/*
	 The bytes are extracted from the NSData instance to create an unsigned char array.
	 */
	unsigned char *packetData = (unsigned char *)[data bytes];
	
	/*
	 It is then possible to extract information from the array identifying the packet number and the 
	 packet type.
	 */
	int *arrayPointer = (int *)&packetData[0];
	
	int currentPacketNumber = arrayPointer[0];
	
	if (currentPacketNumber < previousPacketNumber) {
		return;
	}
	
	previousPacketNumber = currentPacketNumber;
	
	int packetType = arrayPointer[1];
	
	/*
	 This switch statement calls the correct handler method to interpret the packet type received.
	 */
	switch (packetType) {
			
		case kPacketTypePeerPlayerShipDirectionalData: {
			
			[self processPeerPlayerDirectionalDataReceived:&packetData[8]];
			
		}
		break;
			
		case kPacketTypeProjectileFired: {
			
			[self processProjectileDetailsReceived:&packetData[8]];
			
		}
		break;
			
		case kPacketTypeTargetShipSpawned: {
			
			[self processTargetShipDetailsReceived:&packetData[8]];
		
		}
		break;
			
		case kPacketTypePeerHeartbeat: {
			
			[self peerHeartbeatReceived];
			
		}
		break;
		
		case kPacketTypeDieRoll: {
			peerDieRoll = arrayPointer[2];
			peerDieRollReceived = YES;
			[self sendPacketWithType:kPacketTypeDieRollReceived dataLocation:&peerDieRoll 
						  dataLength:sizeof(peerDieRoll) reliable:YES];
		}
		break;
			
		case kPacketTypeDieRollReceived: {
			int acknowledgedDieRoll = arrayPointer[2];
			dieRollAcknowledged = YES;
		}
		break;
			
		case kPacketTypePeerPausedGame: {
			
			[self postPeerPausedGameNotification];
		}
		break;
		
		case kPacketTypePeerResumedGame: {
			
			[self schedulePeerResumedGameNotificationTimer];
		}
		break;
			
		case kPacketTypeAcknowledgePeerResumedGame: {
			
			[self postPeerResumedGameAcknowledgedNotification];
		}
		break;
			
		case kPacketTypePeerQuitGame: {
			
			[self postPeerQuitGameNotification];
		}
		break;
			
		case kPacketTypeNewGameLength: {
			
			[self postNewGameLengthNotificationWithValue:arrayPointer[2]];
		}
		break;
			
		case kPacketTypePlayerReady: {
			
			[self acknowledgePlayerReady];
		}
		break;
			
		case kPacketTypeAcknowledgePlayerReady: {
			
			[self playerReadyAcknowledgementReceived];
		}
		break;

		case kPacketTypeGameCancelled: {
			
			[self postGameCancelledNotification];
		}
		break;
			
		case kPacketTypeActionLayerReady: {
			
			[self acknowledgeActionLayerReady];
		}
		break;
			
		case kPacketTypeAcknowledgeActionLayerReady: {
			
			[self actionLayerReadyAcknowledgementReceived];
		}
		break;

		default:
			break;
	}	
	
	if (peerDieRollReceived && dieRollAcknowledged) {
		
		[self determinePlayerIdentifiers];
		
	}
	
}

#pragma mark -
#pragma mark Private Packet Sending Method

/*
 The sendPacketWithTypeDataLocationDataLengthReliable method is private to the is class and 
 called from the public send methods below.
 */
- (void)sendPacketWithType:(int)packetType dataLocation:(void *)data dataLength:(int)length reliable:(BOOL)sendReliably {
	
	/*
	 An unsigned char array of the required size is created to store the bytes which need to be transferred across the network.
	 */
	static unsigned char networkPacket[kNetworkDataPacketSize];
	
	/*
	 The header contains the packet number and the packet type.
	 */
	const unsigned int headerSize = 2 * sizeof(int);
	
	
	if (length < (kNetworkDataPacketSize - headerSize)) {
		
		packetNumber++;
		
		int *arrayPointer = (int *)&networkPacket[0];
		arrayPointer[0] = packetNumber;
		arrayPointer[1] = packetType;
		
		/*
		 The memory at by the data pointer is copied into the network packet array. 
		 */
		if (data != nil) {
			memcpy(&networkPacket[headerSize], data, length);
		}
		
		/*
		 The bytes in the array are wrapped in an NSData object for transfer over the network.
		 */
		NSData *packetData = [NSData dataWithBytes:networkPacket length:(length + 8)];
		
		if (sendReliably) {
			[currentBluetoothSession sendData:packetData toPeers:peerIDs 
								 withDataMode:GKSendDataReliable error:nil];
		} else {
			[currentBluetoothSession sendData:packetData toPeers:peerIDs 
								 withDataMode:GKSendDataUnreliable error:nil];
		}
		
	}
	
}

#pragma mark -
#pragma mark Public Packet Sending Methods

- (void)sendNewDieRollPacket {
	
	localDieRoll = generateRandomDieRoll();
	[self sendPacketWithType:kPacketTypeDieRoll dataLocation:&localDieRoll 
				  dataLength:sizeof(localDieRoll) reliable:YES];
	
}

- (void)sendNewGameLengthPacket:(int)gameLength {

	[self sendPacketWithType:kPacketTypeNewGameLength dataLocation:&gameLength
				  dataLength:sizeof(gameLength) reliable:YES];
	
}

- (void)sendPlayerReadyPacket {

	[self sendPacketWithType:kPacketTypePlayerReady dataLocation:nil 
				  dataLength:0 reliable:YES];
	
}

- (void)sendAcknowledgePlayerReadyPacket {
		
	[self sendPacketWithType:kPacketTypeAcknowledgePlayerReady
				dataLocation:nil
				  dataLength:0
					reliable:YES];
	
}

- (void)sendGameCancelledPacket {

	[self sendPacketWithType:kPacketTypeGameCancelled
				dataLocation:nil
				  dataLength:0 
					reliable:YES];
	
}

- (void)sendActionLayerReadyPacket {

	localActionLayerReady = YES;
	
	[self sendPacketWithType:kPacketTypeActionLayerReady
				dataLocation:nil
				  dataLength:0 
					reliable:YES];
	
}

- (void)sendAcknowledgeActionLayerReadyPacket {

	[self sendPacketWithType:kPacketTypeAcknowledgeActionLayerReady
				dataLocation:nil
				  dataLength:0
					reliable:YES];
	
}

- (void)sendLocalPlayerShipDirectionalDataWithNewHeading:(float)newHeading newSpeed:(float)newSpeed currentPosition:(CGPoint)currentPosition currentRotation:(float)currentRotation {
	
	PlayerShipDirectionalInformation directionalInformation = {newHeading, 
															   newSpeed, 
														       currentPosition, 
														       currentRotation};
	
	[self sendPacketWithType:kPacketTypePeerPlayerShipDirectionalData
				dataLocation:&directionalInformation
				  dataLength:sizeof(PlayerShipDirectionalInformation)
					reliable:NO];
	
}

- (void)sendTargetSpawnDetailsWithType:(int)targetShipType currentHeading:(float)currentHeading startingPosition:(CGPoint)startingPosition {

	TargetShipDetails targetShipDetails = {targetShipType, currentHeading, startingPosition};
	
	[self sendPacketWithType:kPacketTypeTargetShipSpawned
				dataLocation:&targetShipDetails
				  dataLength:sizeof(targetShipDetails)
					reliable:NO];
}

- (void)sendProjectileFiredDetailsWithStartingPosition:(CGPoint)startingPosition destinationPoint:(CGPoint)destinationPoint {

	ProjectileDetails projectileDetails = {startingPosition, destinationPoint};
	
	[self sendPacketWithType:kPacketTypeProjectileFired
				dataLocation:&projectileDetails 
				  dataLength:sizeof(projectileDetails) 
					reliable:NO];
	
}

- (void)sendPeerPausedGamePacket {

	[self sendPacketWithType:kPacketTypePeerPausedGame
				dataLocation:nil
				  dataLength:0 
					reliable:YES];
	
}

- (void)sendPeerResumedGamePacket {

	[self sendPacketWithType:kPacketTypePeerResumedGame
				dataLocation:nil
				  dataLength:0 
					reliable:YES];
	
}

- (void)sendAcknowledgePeerResumedGamePacket {
	
	pauseMenuAcknowledgedPacketReceipt = YES;
	
	[self sendPacketWithType:kPacketTypeAcknowledgePeerResumedGame
				dataLocation:nil
				  dataLength:0
					reliable:YES];
	
}

- (void)sendPeerQuitGamePacket {

	[self sendPacketWithType:kPacketTypePeerQuitGame
				dataLocation:nil 
				  dataLength:0
					reliable:YES];
	
}

@end
