//
//  FollowContext.h
//  ___PROJECTNAME___
//
//  Created by Ngo Duc Hiep on 3/29/11.
//  Copyright 2011 PTT Solution., JSC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d+ext.h"
#import "SimpleMenu.h"
#import "CCSlider.h"
#import "Bullet.h"
#import "ActorTags.h"

#define GROUP_BULLETS 1

enum  {
	kSimpleMenuDynamicFollowOnOff = kSimpleMenuDynamicRestart+1,
};

@interface FollowContext : CCContext<SimpleMenuDelegate> {
	b2Body *b1, *_static;;
	CCComponent *node;
	
	SimpleMenu *_mainMenu;
	
	CCJointNode *_jointNode;
	
	CCSpriteBatchNode *_bullets;
}
 
- (void) addBullet:(CGPoint) position;
@end
