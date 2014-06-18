//
//  BluetoothNotificationNames.h
//  AberFighter
//
//  Created by wde7 on 22/03/2011.
//  Copyright 2011 William Darius Elphick. All rights reserved.
//
/*
 The purpose of this file is to contain constant pointers to the textual names for each notification
 type which is posted to the NSNotificationCenter by the BluetoothCommsManager. This is so that all
 multiplayer layers can refer to these constants rather than using string literals when checking notification
 names. This reduces the probability of errors due to misspelling notification names.
 
 The string literals referred to by these pointers are in the BluetoothNotificationNames.m file.
 */

#import <Foundation/Foundation.h>

extern NSString *const SessionFailedWithError;
extern NSString *const PeerWasDisconnected;
extern NSString *const PeerLost;
extern NSString *const PeerFound;
extern NSString *const RestartingDieRoll;
extern NSString *const DieRollFinished;
extern NSString *const NewGameLengthReceived;
extern NSString *const PeerReadyToPlay;
extern NSString *const LocalPlayerReadyAcknowledged;
extern NSString *const PeerCancelledGame;
extern NSString *const PeerActionLayerReady;
extern NSString *const ActionLayerReadyAcknowledged;
extern NSString *const PeerDirectionalDataReceived;
extern NSString *const TargetShipSpawned;
extern NSString *const ProjectileFired;
extern NSString *const PeerPausedGame;
extern NSString *const PeerResumedGame;
extern NSString *const PeerResumedGameAcknowledged;
extern NSString *const PeerQuitGame;
