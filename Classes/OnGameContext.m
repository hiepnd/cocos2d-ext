//
//  OnGameContext.m
//  ___PROJECTNAME___
//
//  Created by Ngo Duc Hiep on 3/22/11.
//  Copyright 2011 PTT Solution., JSC. All rights reserved.
//

#import "OnGameContext.h"
#define kFilteringFactor			0.1

@implementation OnGameContext

- (id) init{
	self = [super init];
	_isTouchEnabled = YES;
	_interestedStateChanges = kAppStateWillResignActive;
	_isAccelerometerEnabled = YES;
	[[CCDirector sharedDirector] openGLView].multipleTouchEnabled = YES;
	
	[self addGroup:ENEMIES_GROUP];
	[self addGroup:BULLETS_GROUP];
	[self addGroup:BONUS_GROUP];
	
	_spaceshipSpeed = 8.;
	_spaceSpeedMax = 5.;
	_spaceSpeedMin = 2.;
	_bottomBoudary = -20;
	
	Class c = NSClassFromString(@"UIRotationGestureRecognizer");
	if (c) {
		UIGestureRecognizer *reg = [[c alloc] init];
		[self addGestureRecognizer:reg action:@selector(handleGesture:)];
		[reg release];
	}else {
		NSLog(@"UIGestureRecognizer not supported");
	}
	
	_mainMenu = [OnGameMenu node];
	[self addChild:_mainMenu];
	_mainMenu.delegate = self;
	[_mainMenu setScore:0];	
	
	_bg = [[Background alloc] initWithImage:@"space.png" andImage:@"space.png"];
	[self addChild:_bg];
	[_bg release];
	
	_ship = [Spaceship node];
	_ship.position = ccp(240,30);
	[self addActor:_ship];
	
	_bullets = [CCSpriteBatchNode batchNodeWithFile:@"duck+spaceship.png"];
	[self addChild:_bullets];
	
	[self addContactListenerBetweenGroup:BULLETS_GROUP 
								andGroup:ENEMIES_GROUP 
								  target:self 
								selector:@selector(bullet:duck:)];
		
	[self addContactListenerBetweenActor:_ship 
								andGroup:BONUS_GROUP 
								  target:self 
								selector:@selector(spaceship:bonus:)];
	
	[self addContactListenerBetweenActor:_ship 
								andGroup:ENEMIES_GROUP 
								  target:self 
								selector:@selector(spaceship:duck:)];
	
	_state = kBanVitPlaying;
	_controlMode = kControlJoystick;
	
	return self;
}

- (void) setControlMode:(int) mode{
	if (_controlMode == mode) {
		return;
	}
	_controlMode = mode;
	switch (mode) {
		case kControlTiting:
			[_mainMenu hideJoystick:YES];
			break;
			
		case kControlJoystick:
			[_mainMenu hideJoystick:NO];
			break;
		default:
			break;
	}
}

- (void) tick:(ccTime) dt{
	if (_state == kBanVitPlaying) {
		if (_tickCounter % 60 == 0 && CCRANDOM_0_1() > .5) {
			float x = CCRANDOM_0_1() * 480;
			float y = 340;
			[self addDuck:ccp(x,y)];
		}

		if (_controlMode == kControlJoystick) {
			_spaceSpeedRate = _mainMenu.joyStick.stickPosition.y/_mainMenu.joyStick.joystickRadius;
			_spaceSpeedRate = _spaceSpeedRate < 0 ? 0 : _spaceSpeedRate;
			_spaceshipSpeedRate = _mainMenu.joyStick.stickPosition.x/_mainMenu.joyStick.joystickRadius;
		}
		
		_ship.xSpeed = fabs(_spaceshipSpeed * _spaceshipSpeedRate);
		if (_spaceshipSpeedRate > 0) {
			[_ship turnRight];
		}
		if (_spaceshipSpeedRate < 0) {
			[_ship turnLeft];
		}
		
		float dy = _spaceSpeedMin + _spaceSpeedRate * (_spaceSpeedMax - _spaceSpeedMin);
		[self updatePosition:dy];
		[_bg move:dy];
		
		
		if (_autoFire && _tickCounter % 10 == 0) {
			[self fire];
		}
		
		[super tick:dt];
	}
}

- (void) updatePosition:(float)dy{
	NSArray *actors; 
	NSEnumerator *it;
	actors = [self getAllActors:ENEMIES_GROUP];
	it = [actors objectEnumerator];
	while (CCNode *actor = [it nextObject]) {
		actor.position = ccp(actor.position.x, actor.position.y - dy);
		if (actor.position.y < _bottomBoudary) {
			[self removeActor:actor group:ENEMIES_GROUP cleanup:YES];
		}
	}
	
	actors = [self getAllActors:BONUS_GROUP];
	it = [actors objectEnumerator];
	while (CCNode *actor = [it nextObject]) {
		actor.position = ccp(actor.position.x, actor.position.y - dy);
		if (actor.position.y < _bottomBoudary) {
			[self removeActor:actor group:BONUS_GROUP cleanup:YES];
		}
	}
}

- (void) pause{
	[self freezeAllChilden];
	[self freezeAllChildenInGroup:BULLETS_GROUP];
	[self freezeAllChildenInGroup:BONUS_GROUP];
	[self freezeAllChildenInGroup:ENEMIES_GROUP];
	[self pauseScheduler];
	_state = kBanVitPause;
} 

- (void) resume{
	[self unFreezeAllChilden];
	[self unFreezeAllChildenInGroup:BULLETS_GROUP];
	[self unFreezeAllChildenInGroup:BONUS_GROUP];
	[self unFreezeAllChildenInGroup:ENEMIES_GROUP];
	[self resumeScheduler];
	_state = kBanVitPlaying;
}

- (void) fire{
	CGPoint position = ccp(_ship.position.x,_ship.position.y + 30);
	Bullet *bullet = [Bullet node];
	bullet.position = position;
	bullet.rotation = -90;
	[self addActor:bullet batch:_bullets group:BULLETS_GROUP];
	[bullet runAction:[CCMoveTo actionWithDuration:.8 position:ccp(position.x,350)] target:self selector:@selector(removeBullet:)];
}

- (void) removeBullet:(Bullet *) bullet{
	[self removeActor:bullet group:BULLETS_GROUP];
}
#pragma mark Collision
- (void) bullet:(Bullet *) n1 duck:(Duck *) n2{
	if (CCRANDOM_0_1() > .5) {
		[self addBonus:n2.position];
	} 
	[n1 explode];
	[n2 die];
	[self removeFromGroup:BULLETS_GROUP actor:n1];
	[self removeFromGroup:ENEMIES_GROUP actor:n2];
	[self setScore:_score + 50];
}

- (void) spaceship:(Spaceship *) ship duck:(Duck *) duck{
	
}

- (void) spaceship:(Spaceship *) ship bonus:(CCNode *) bonus{
	[self setScore:_score + 10];
	[self removeActor:bonus group:BONUS_GROUP];
}

- (void) addDuck:(CGPoint) position{
	Duck *duck = [Duck node];
	duck.position = position;
	[self addActor:duck batch:_bullets group:ENEMIES_GROUP];
}

- (void) addBonus:(CGPoint) position{
	CCSprite *bonus = [CCSprite spriteWithSpriteFrameName:@"dui-ga.png"];
	bonus.position = position;
	bonus.rotation = CCRANDOM_0_1() * 360;
	[self addActor:bonus batch:_bullets group:BONUS_GROUP];
	[bonus runAction:[CCRotateBy actionWithDuration:2 angle:720]];
}

- (void) setScore:(int) score{
	_score = score ;
	[_mainMenu setScore:score];
}

- (void) applicationWillResignActive:(NSNotification *)notification{
	[self pause];
	[_mainMenu showImmediately];
}

#pragma mark OnGameMenuDelegate
- (void) simpleMenuWillShow:(SimpleMenu *)menu{
	[self pause];
}

- (void) simpleMenuDidHide:(SimpleMenu *)menu{
	[self resume];
}

- (void) simpleMenu:(OnGameMenu *)menu didActivateItemTag:(int)tag{
	switch (tag) {
		case kSimpleMenuDynamicHome:
			[[CCDirector sharedDirector] homeContext];
			break;
			
		case kSimpleMenuDynamicResume:
			[menu hide];
			break;
			
		case kSimpleMenuDynamicRestart:
			[[CCDirector sharedDirector] simpleGameContext];
			break;
			
		case kSimpleMenuDynamicAutoFire:
		{
			CCMenuItemToggle *item = (CCMenuItemToggle *) [menu dynamicMenuItemBytag:kSimpleMenuDynamicAutoFire];
			_autoFire = [item selectedIndex];
			[menu hide];
			break;
		}
			
		case kSimpleMenuDynamicControlMode:
		{
			CCMenuItemToggle *item = (CCMenuItemToggle *) [menu dynamicMenuItemBytag:kSimpleMenuDynamicControlMode];
			if ([item selectedIndex] == 1) {
				[self setControlMode:kControlTiting];
			}else {
				[self setControlMode:kControlJoystick];
			}

			[menu hide];
			break;
		}
		default:
			break;
	}
}

#pragma mark ACC
- (void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration{
	if (_controlMode == kControlTiting) {
		accel[0] = acceleration.x * kFilteringFactor + accel[0] * (1.0 - kFilteringFactor);
		accel[1] = acceleration.y * kFilteringFactor + accel[1] * (1.0 - kFilteringFactor);
		accel[2] = acceleration.z * kFilteringFactor + accel[2] * (1.0 - kFilteringFactor);
		
		//NSLog(@"B:(%.4f,%.4f,%.4f)",acceleration.x,acceleration.y,acceleration.z);
		//NSLog(@"F:(%.4f,%.4f,%.4f)",accel[0],CC_RADIANS_TO_DEGREES(acos(accel[1])),accel[2]);
		
		float angle = [[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationLandscapeLeft ? -90 : 90;
		CGPoint v = ccpRotateByAngle(ccp(accel[0], accel[1]), ccp(0,0), CC_DEGREES_TO_RADIANS(angle));
		
		v.x = v.x > .25 ? .25 : v.x;
		v.x = v.x < -.25 ? -.25 : v.x;
		_spaceshipSpeedRate = - 1 + (v.x + .25) * 4;
		_spaceshipSpeedRate = fabs(_spaceshipSpeedRate) < .07 ? 0 : _spaceshipSpeedRate;
		_spaceSpeedRate = fabs(-(accel[2] + 0.4) / 0.6);
	}
}

#pragma mark Touches
- (void) ccTouchesBegan:(NSSet *) touches withEvent:(UIEvent *)event{
	if (_state == kBanVitPlaying && !_autoFire) {
		[self fire];
	}
}

- (void) ccTouchesMoved:(NSSet *) touches withEvent:(UIEvent *) event{
	
}

- (void) ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
	
}

#pragma mark Guesture Recognizer
- (void)handleGesture:(UIRotationGestureRecognizer *)gestureRecognizer{
	
}
@end
