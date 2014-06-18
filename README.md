AberFighter
===========

This is the iOS game I made using the Cocos2D and Gamekit frameworks as part of my dissertation at University.

The purpose of this project was to investigate the technologies available for creating games on the iOS platform. The goal was to produce a Spacecraft Combat Game which harnessed the accelerometer as a directional input device and bluetooth to allow interactive two player gaming as well as one player functionality.

The project made use of cocos2D for iPhone, a game engine framework created in Objective-C which provides functionality for creating two dimensional games using OpenGL ES.

The app produced by the work conducted on the project was called AberFighter. It provided a single-player mode where to secure points the player has to destroy as many enemies as possible within a certain time limit. Multiple accelerometer control schemes were included in the app.

It also provided a multiplayer mode. This was similar to the single-player mode, but with the added requirement of outscoring your opponent. The bluetooth functionality was implemented, and proved a technical challenge which was overcome. The most difficult aspect was processing the game in real-time across both devices. The finished app achieved this by sharing state between both devices, although I concluded a better solution would have been to include timestamps on events shared over the bluetooth connection so that they could compensate for communication delays.  
