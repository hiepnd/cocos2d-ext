//
//  OnGameContext.h
//  ___PROJECTNAME___
//
//  Created by Ngo Duc Hiep on 3/22/11.
//  Copyright 2011 PTT Solution., JSC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d+ext.h"
#import "AppDirector.h"
#import "Global.h"
#import "OnGameMenu.h"
#import "Spaceship.h"
#import "Bullet.h"
#import "Duck.h"
#import "Background.h"

enum  {
	HERO_TAG = 1 << 0,
	HERO_TAG_MON = HERO_TAG | 1 << 1,
	HERO_TAG_DAD = HERO_TAG | 1 << 2,
	HERO_TAG_SON = HERO_TAG | 1 << 3,
	TAG_BB,
};

#define BULLETS_GROUP	1
#define ENEMIES_GROUP	2
#define BONUS_GROUP		3

enum  {
	kBanVitInvalid,
	kBanVitPlaying,
	kBanVitPause,
	kBanVitOverPass,
	kBanVitOverFail,
};

enum  {
	kControlJoystick = 1,
	kControlTiting,
};

@interface OnGameContext : CCContext<SimpleMenuDelegate> {
	OnGameMenu *_mainMenu;
	Spaceship *_ship;
	Background *_bg;
	
	int _state;
	CCSpriteBatchNode *_bullets;
	
	int _score;
	float _spaceshipSpeed;//max saceship speed
	float _spaceshipSpeedRate;//-1 to 1
	
	float _spaceSpeedMin;
	float _spaceSpeedMax;
	float _spaceSpeedRate;//0 to 1
	float _bottomBoudary;
	
	int _controlMode;
	UIAccelerationValue accel[3];
	
	BOOL _autoFire;
}
- (void) setControlMode:(int) mode;
- (void) updatePosition:(float)dy;
- (void) pause;
- (void) resume;
- (void) fire;
- (void) setScore:(int) score;
- (void) addDuck:(CGPoint) position;
- (void) addBonus:(CGPoint) position;
@end
