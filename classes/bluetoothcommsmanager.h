//
//  BluetoothManager.h
//  AberFighter
//
//  Created by wde7 on 21/03/2011.
//  Copyright 2011 William Darius Elphick. All rights reserved.
//
/*
 The BluetoothCommsManager is the centralised location for communicating across the bluetooth network. 
 */

#import <Foundation/Foundation.h>
#import <GameKit/GameKit.h>
#import "DirectionalChanges.h"
#import "BluetoothNotificationNames.h"

//ID of app's bluetooth session
#define kAberFighterBluetoothSessionID @"com.wde7.AberFighter.session"
//Default die roll figure
#define kDieNotRolled INT_MAX
//Network Heartbeat will run at this speed
#define kNetworkHeartbeatFrequency 0.5f

//Generate a random very large number. Used for the initial die roll.
#define generateRandomDieRoll() (arc4random() % 1000000)

#pragma mark -
#pragma mark Bluetooth PacketTypes and PlayerID Declarations

/*
 These are the packet types which are sent across the network.
 */
typedef enum PacketTypes {
	
	kPacketTypeDieRoll,
	kPacketTypeDieRollReceived,
	kPacketTypeRestartDieRoll,
	kPacketTypePeerHeartbeat,
	kPacketTypeNewGameLength,
	kPacketTypePlayerReady,
	kPacketTypeAcknowledgePlayerReady,
	kPacketTypeGameCancelled,
	kPacketTypeActionLayerReady,
	kPacketTypeAcknowledgeActionLayerReady,
	kPacketTypePeerPlayerShipDirectionalData,
	kPacketTypeTargetShipSpawned,
	kPacketTypeProjectileFired,
	kPacketTypePeerPausedGame,
	kPacketTypePeerResumedGame,
	kPacketTypeAcknowledgePeerResumedGame,
	kPacketTypePeerQuitGame
	
} PacketType;

/*
 These are the PlayerIDs which can be assigned to each deive.
 */
typedef enum PlayerIdentifiers {
	
	kPlayerUndecided,
	kPlayer1,
	kPlayer2
	
} PlayerIdentifier;

#pragma mark -
#pragma mark Bluetooth Packet Data Struct Declarations

/*
 Struct used for transferring Directional data across the network.
 */
typedef struct {
	
	float newHeading;
	float newSpeed;
	CGPoint currentPosition;
	float currentRotation;
	
} PlayerShipDirectionalInformation;

/*
 Struct used for transferring target spawn details across the network.
 */
typedef struct {
	
	int targetShipType;
	float currentHeading;
	CGPoint startingPosition;
	
} TargetShipDetails;

/*
 Struct used for transferring projectile firing details across the network.
 */
typedef struct {

	CGPoint startingPosition;
	CGPoint destinationPoint;
	
} ProjectileDetails;

#pragma mark -
#pragma mark BluetoothCommsManager Interface Declaration

@interface BluetoothCommsManager : NSObject <GKSessionDelegate> {
	
	/*
	 The currentBluetoothSession is the GKSession which represents the connection with the other peer.
	 */
	GKSession *currentBluetoothSession;
	//Array of peerIDs which have been connected to.
	NSMutableArray *peerIDs;
	//PlayerID assigned to this device.
	PlayerIdentifier playerID;
	
	/*
	 Identifier for data packets.
	 */
	int packetNumber;
	/*
	 The currentPacketNumber must be greater than the previous packet number. 
	 */
	int previousPacketNumber;
	
	/*
	 Used in the die roll procedure. localDieRoll is the die roll generated on this device,
	 peerDieRoll the value on the other.	 
	 */
	int localDieRoll;
	int peerDieRoll;
	
	/*
	 Booleans used to monitor status of die roll.
	 */
	BOOL peerDieRollReceived;
	BOOL dieRollAcknowledged;
	
	/*
	 Bools which monitor the state of layers which must be instantiated before receiving bluetooth notifications.
	 */
	BOOL localActionLayerReady;
	BOOL pauseMenuAcknowledgedPacketReceipt;
	
	/*
	 Heartbeat related functionality. The NSTimer periodically calls the networkHeartbeat method to ensure the 
	 connection is still active.  
	 */
	NSTimer *networkHeartbeatGenerator;
	NSDate *lastHeartbeatDate;
	BOOL attemptingNetworkReconnect;
	
}

#pragma mark -
#pragma mark BluetoothCommsManager Property Declaration

@property (readonly) GKSession *currentBluetoothSession; 
@property (readonly) NSMutableArray *peerIDs;
@property (readonly) PlayerIdentifier playerID;
@property (nonatomic, readwrite, assign) BOOL localActionLayerReady;
@property (nonatomic, readwrite, assign) BOOL pauseMenuAcknowledgedPacketReceipt;
@property (nonatomic, retain) NSTimer *networkHeartbeatGenerator;
@property (nonatomic, retain) NSDate *lastHeartbeatDate;
@property (nonatomic, readwrite, assign) BOOL attemptingNetworkReconnect;

#pragma mark -
#pragma mark BluetoothCommsManager Public Methods Declaration

/*
 BluetoothCommsManager is a singleton which can be retrieved with this method. 
 */
+ (BluetoothCommsManager *)sharedInstance;

/*
 Create a new GKSession and return it for use by the peer picker.
 */
- (GKSession *)setUpNewSession;

/*
 Reset the BluetoothCommsManager.
 */
- (void)clearUpSession;

/*
 Reset the booleans indicating whether the required layers have been initiated.
 */
- (void)resetLayerStateIndicators;

/*
 Initiate a new dieRoll process.
 */
- (void)sendNewDieRollPacket;

/*
 Send a new game length from the MultiplayerOptionsLayer.
 */
- (void)sendNewGameLengthPacket:(int)gameLength;

/*
 Send PlayerReadyPacket when the user presses start game on the MultiplayerOptionsLayer.
 */
- (void)sendPlayerReadyPacket;

/*
 PlayerReady must be acknowledged to ensure that both devices are ready and aware of the situation while starting the game.
 */
- (void)sendAcknowledgePlayerReadyPacket;

/*
 Sent when the Cancel button on the MultiplayerOptionsLayer is pressed.
 */
- (void)sendGameCancelledPacket;

/*
 Once the MultilayerGameScene is finished loading this packet it sent to alert the other device. 
 */
- (void)sendActionLayerReadyPacket;

/*
 ActionLayerReady must be acknowledged to ensure that both devices start the game at the same time.
 */
- (void)sendAcknowledgeActionLayerReadyPacket;

/*
 This method sends PlayerShipDirectionalData across the network.
 */
- (void)sendLocalPlayerShipDirectionalDataWithNewHeading:(float)newHeading newSpeed:(float)newSpeed currentPosition:(CGPoint)currentPosition currentRotation:(float)currentRotation;

/*
 This method sends TargetSpawnDetails across the network.
 */
- (void)sendTargetSpawnDetailsWithType:(int)targetShipType currentHeading:(float)currentHeading startingPosition:(CGPoint)startingPosition;

/*
 This method sends ProjectileFiredDetails across the network. 
 */
- (void)sendProjectileFiredDetailsWithStartingPosition:(CGPoint)startingPosition destinationPoint:(CGPoint)destinationPoint;

/*
 Sent when the Pause button is pressed on the UserInterfaceLayer.
 */
- (void)sendPeerPausedGamePacket;

/*
 Sent when a peer presses the resume button on the MultiplayerPauseMenu.
 */
- (void)sendPeerResumedGamePacket;

/*
 The peer resumed packet must be acknowledged to ensure that both views are ready before resuming the game.
 */
- (void)sendAcknowledgePeerResumedGamePacket;

/*
 Sent from the MultiplayerPauseMenu and the GameOverLayer when the user presses the Quit Game / Main Menu buttons respectively. 
 */
- (void)sendPeerQuitGamePacket;

@end
