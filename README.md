AberFighter
===========

This is the iOS game I made using the Cocos2D and Gamekit frameworks as part of my dissertation at University.

The purpose of this project was to investigate the technologies available for creating games on the iOS platform. The goal was to produce a Spacecraft Combat Game which harnessed the accelerometer as a directional input device and bluetooth to allow interactive two player gaming as well as one player functionality.
The project made use of cocos2D for iPhone, a game engine framework created in Objective-C which provides functionality for creating two dimensional games using OpenGL ES.
The app produced by the work conducted on the project is called AberFighter. It provides a single-player mode where to secure points the player has to destroy as many enemies as possible within a certain time limit. Multiple accelerometer control schemes are included in the app.
It also provides a multiplayer mode. This is similar to the single-player mode, but with the added requirement of outscoring your opponent. The bluetooth functionality was implemented, however an issue related to concurrent processing of the game state on both devices led to side effects which negatively affected the performance of the game.
