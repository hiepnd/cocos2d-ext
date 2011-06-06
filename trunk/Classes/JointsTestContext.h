//
//  JointsTestContext.h
//  ___PROJECTNAME___
//
//  Created by Ngo Duc Hiep on 4/1/11.
//  Copyright 2011 PTT Solution., JSC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d+ext.h"
#import "TestJointsMenu.h"
#import "Global.h"
#import "ScoreManager.h"

enum GameState {
	kGameStateInvalid = 0,
	kGameStateInit		= 1 << 1,
	kGameStatePlaying	= 1 << 2,
	kGameStatePause		= 1 << 3,
	kGameStateGameOver	= 1 << 4,
};

enum Test {
	kTestDistance		= kMenuItemTestDistance,
	kTestRevolute		= kMenuItemTestRevolute,
	kTestPrismatic		= kMenuItemTestPrismatic,
	kTestPulley			= kMenuItemTestPulley,
	kTestLine			= kMenuItemTestLine,
	kTestWeld			= kMenuItemTestWeld,
	kTestOto			= kMenuItemTestOto,
};

#define kFilteringFactor			0.1

@interface JointsTestContext : CCContext <SimpleMenuDelegate>{
	TestJointsMenu *_mainMenu;
	int _gameState;
	
	ScoreManager *_scoreManager;
	
	CCComponent *root;
	b2Body *static_;
	b2MouseJoint *mouse_;
	
	CCJointNode *_jointNode;
	
	UIAccelerationValue accel[3];
	
	//Test components container
	NSMutableArray *_pop;
	
	NSString *_LBL;
	
	//OTO
	b2Body *wheel;
}

- (void) setTest:(int) test;

- (b2Body *) addBoxAt:(CGPoint) pos;
- (b2Body *) addRectAt:(CGPoint) pos;

- (int) getGameState;
- (void) pause;
- (void) resume;
@end