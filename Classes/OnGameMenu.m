//
//  OnGameMenu.m
//  ___PROJECTNAME___
//
//  Created by Ngo Duc Hiep on 3/16/11.
//  Copyright 2011 PTT Solution., JSC. All rights reserved.
//

#import "OnGameMenu.h"


@implementation OnGameMenu
@synthesize joyStick = _joyStick;
@synthesize rightButton = _rightButton;

- (id) init{
	self = [super init];
	isTouchEnabled_ = NO;
	
	[CCMenuItemFont setFontSize:18];
	CCMenuItem *item,*item1,*item2;
	[CCMenuItemFont setFontSize:25];
	
	item1 = [CCMenuItemFont itemFromString:@"Auto fire ON"];
	item2 = [CCMenuItemFont itemFromString:@"Auto fire OFF"];
	item = [CCMenuItemToggle itemWithTarget:self selector:@selector(menuItemActivate:) items:item1,item2,nil];
	item.tag = kSimpleMenuDynamicAutoFire;
	item.position = ccp(-120,100 - 56 - 28);
	[_menu addChild:item];
	
	item1 = [CCMenuItemFont itemFromString:@"Titing Control"];
	item2 = [CCMenuItemFont itemFromString:@"Joystick Control"];
	item = [CCMenuItemToggle itemWithTarget:self selector:@selector(menuItemActivate:) items:item1,item2,nil];
	item.tag = kSimpleMenuDynamicControlMode;
	item.position = ccp(-120,100 - 56 - 56);
	[_menu addChild:item];
	
//	
//	//Right
//	item = [CCMenuItemFont itemFromString:@"Right" target:self selector:@selector(menuItemActivate:)];
//	item.tag = kMenuItemMoveRight;
//	item.position = ccp(210,-140);
//	[_staticMenu addChild:item];
//	
//	//Jump
//	item = [CCMenuItemFont itemFromString:@"Jump" target:self selector:@selector(menuItemActivate:)];
//	item.tag = kMenuItemJump;
//	item.position = ccp(170,-140);
//	[_staticMenu addChild:item];
		
	[CCMenuItemFont setFontSize:22];
	
	_score = [CCLabelTTF labelWithString:@"Score" fontName:@"Marker Felt" fontSize:20];
	_score.position = ccp(30,300);
	[self addChild:_score];
	
	SneakyJoystickSkinnedBase *leftJoy = [[[SneakyJoystickSkinnedBase alloc] init] autorelease];
	leftJoy.position = ccp(64,64);
	leftJoy.backgroundSprite = [ColoredCircleSprite circleWithColor:ccc4(255, 0, 0, 128) radius:32];
	leftJoy.thumbSprite = [ColoredCircleSprite circleWithColor:ccc4(0, 0, 255, 200) radius:16];
	leftJoy.joystick = [[SneakyJoystick alloc] initWithRect:CGRectMake(0,0,128,128)];
	_joyStick = leftJoy.joystick;
	[self addChild:leftJoy];
	leftJoy.tag = 1024;
	
//	SneakyButtonSkinnedBase *rightBut = [[[SneakyButtonSkinnedBase alloc] init] autorelease];
//	rightBut.position = ccp(448,32);
//	rightBut.defaultSprite = [ColoredCircleSprite circleWithColor:ccc4(255, 255, 255, 128) radius:32];
//	rightBut.activatedSprite = [ColoredCircleSprite circleWithColor:ccc4(255, 255, 255, 255) radius:32];
//	rightBut.pressSprite = [ColoredCircleSprite circleWithColor:ccc4(255, 0, 0, 255) radius:32];
//	rightBut.button = [[SneakyButton alloc] initWithRect:CGRectMake(0, 0, 64, 64)];
//	_rightButton = [rightBut.button retain];
//	//rightButton.isToggleable = YES;
//	[self addChild:rightBut];
	
	return self;
}

- (void) hideJoystick:(BOOL) yesorno{
	[[self getChildByTag:1024] setVisible:!yesorno];
	if (!yesorno) {
		[[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:_joyStick priority:1 swallowsTouches:YES];
	}else {
		[[CCTouchDispatcher sharedDispatcher] removeDelegate:_joyStick];
	}

}

- (void) setScore:(int) score{
	[_score setString:[NSString stringWithFormat:@"%d",score]];
}
@end
