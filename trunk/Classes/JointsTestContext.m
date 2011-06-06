//
//  JointsTestContext.m
//  ___PROJECTNAME___
//
//  Created by Ngo Duc Hiep on 4/1/11.
//  Copyright 2011 PTT Solution., JSC. All rights reserved.
//

#import "HomeContext.h"
#import "Bomb.h"
#import "GLES-Render.h"
#import "AppDirector.h"

@implementation JointsTestContext

- (id) init{
	self = [super init];
	
	/** Toouch handler ON  */
	_isTouchEnabled = YES;
	
	/** Acceleromater ON  */
	_isAccelerometerEnabled = YES;
	
	/** Shake event ON  */
	_interestShakeEvent = YES;
	
	/** Register with interested application state change events  */
	_interestedStateChanges = kAppStateWillResignActive | kAppStateDidReceiveMemoryWarnig | kAppStateDidBecomeActive;
	
	/** Set physic debug draw  */
	//[self setDebugDraw:YES];
	
	_pop = [[NSMutableArray alloc] init];
	
	_scoreManager = [[ScoreManager alloc] initWithFile:[Utils pathForFileInDocument:APP_HIGHSCORE_FILE]];
	
	_mainMenu = [TestJointsMenu node];
	[self addChild:_mainMenu z:100];
	_mainMenu.delegate = self;
	
	//	CCSprite *bg = [CCSprite spriteWithFile:@"bg.pvr.ccz"];
	//	[bg setTextureRect:CGRectMake(0, 0, 480, 320)];
	//	
	//	bg.position = ccp(240,160);
	//	bg.tag = 1024;
	//	[self addChild:bg z:-2];
	
	
	b2FixtureDef fdef;
	fdef.friction = 1;
	fdef.restitution = .5;
	fdef.density = .2;
	
	/** Add the walls around iPhone  */
	[self addStaticEdgeFrom:CGPointMake(0, 0) to:CGPointMake(480, 0) fixtureDef:&fdef]; //Bottom
	[self addStaticEdgeFrom:CGPointMake(0, 0) to:CGPointMake(0, 320) fixtureDef:&fdef]; //left
	[self addStaticEdgeFrom:CGPointMake(480, 0) to:CGPointMake(480, 320) fixtureDef:&fdef];  //Right
	static_ = [self addStaticEdgeFrom:CGPointMake(0, 320) to:CGPointMake(480, 320) fixtureDef:&fdef];  //top
	
	//[self setTest:kTestDistance];
	[self setDebugDraw:YES flag:b2Draw::e_shapeBit|b2Draw::e_jointBit];
	
	return self;
}

- (void) onEnter{
	[super onEnter];
	_gameState = kGameStatePlaying;
	[_mainMenu showImmediately];
}

- (int) getGameState{
	return _gameState;
}

/** The MAIN GAME LOOP - step the physic world and do you funny stuffs here  */
- (void) tick:(ccTime) dt{
	if (_gameState == kGameStatePlaying) {
		//double dtt = [[NSDate date] timeIntervalSince1970];
		/** Step the world, don't forget if you use physic  */
		[self step:dt];
		//NSLog(@"End   step: %f",[[NSDate date] timeIntervalSince1970] - dtt);		
	}
	
	[super tick:dt];
}

- (void) dealloc{
	NSLog(@"OEOEO");
	[_pop makeObjectsPerformSelector:@selector(releasePhysicAndDestroy:) withObject:[NSNumber numberWithBool:NO]];
	[_pop release];
	[super dealloc];
}

#pragma mark Game controller
- (void) pause{
	if (_gameState != kGameStatePlaying) {
		return;
	}
	_gameState = kGameStatePause;
	[self freezeAllChilden];
}

- (void) resume{
	if (_gameState == kGameStatePlaying) {
		return;
	}
	_gameState = kGameStatePlaying;
	[self unFreezeAllChilden];
}

- (void) setTest:(int) test{
	//[_pop makeObjectsPerformSelector:@selector(releasePhysicAndDestroy:) withObject:[NSNumber numberWithBool:YES]];
	[_pop makeObjectsPerformSelector:@selector(removeFromParentAndCleanup:) withObject:[NSNumber numberWithBool:YES]];
	[_pop removeAllObjects];
	[_scoreManager save];
	SEL selector = nil;
	switch (test) {
		case kTestDistance:
			selector = @selector(testDistanceJoint);
			[_LBL release];
			_LBL = [@"Distance Joint Test" retain];
			
			break;
		case kTestLine:
			selector = @selector(testLineJoint);
			[_LBL release];
			_LBL = [@"Line Joint Test" retain];
			break;
		case kTestOto:
			selector = @selector(testXedap);
			[_LBL release];
			_LBL = [@"Simple Oto Test" retain];
			break;
		case kTestPrismatic:
			selector = @selector(testPrismaticJoint);
			[_LBL release];
			_LBL = [@"Prismatic Joint Test" retain];
			break;
		case kTestPulley:
			selector = @selector(testPulleyJoint);
			[_LBL release];
			_LBL = [@"Pulley Joint Test" retain];
			break;
		case kTestRevolute:
			selector = @selector(testRevoluteJoint);
			[_LBL release];
			_LBL = [@"Revolute Joint Test" retain];
			break;
		case kTestWeld:
			selector = @selector(testWeldJoint);
			[_LBL release];
			_LBL = [@"Weld Joint Test" retain];
			break;
		default:
			break;
	}
	
	[_mainMenu setTestLabel:_LBL];
	[self performSelector:selector];
	NSLog(@"%@:%d",_LBL,[_pop count]);
}

#pragma mark TestBed
- (void) testDistanceJoint{
	b2Body *body1 = [self addBoxAt:ccp(240,160)];
	b2Body *body2 = [self addBoxAt:ccp(320,160)];
	b2DistanceJointDef def;
	
	def.Initialize(body1, body2, PTM_POINT(ccp(240,160)), PTM_POINT(ccp(320,160)));
	//def.dampingRatio = 1;
	def.frequencyHz = 1;
	def.collideConnected = TRUE;
	b2DistanceJoint *joint = (b2DistanceJoint *) _physicContext->createJoint(&def);
	
	_jointNode = [CCJointNode nodeWithJoint:joint];
	_jointNode.texture = @"rope.png" ;
	_jointNode.lineWidth = 4.;
	_jointNode.physicContext = _physicContext;
	
	[self addChild:_jointNode];
	[_pop addObject:_jointNode];
}

- (void) testRevoluteJoint{
	b2Body *body1 = [self addBoxAt:ccp(240,160)];
	b2Body *body2 = [self addRectAt:ccp(320,160)];
	b2RevoluteJointDef def;
	
	def.Initialize(body1, body2, PTM_POINT(ccp(280,220)));
	def.enableLimit = YES;
	def.lowerAngle = -0.5f * b2_pi; // -90 degrees
	def.upperAngle = 0.25f * b2_pi; // 45 degrees
	
	def.enableMotor = YES;
	def.motorSpeed = 0.;
	def.maxMotorTorque = 10.;
	
	b2RevoluteJoint *joint = (b2RevoluteJoint *) _physicContext->createJoint(&def);
	_jointNode = [CCJointNode nodeWithJoint:joint];
	_jointNode.texture = @"rope.png" ;
	[self addChild:_jointNode];
	[_pop addObject:_jointNode];
}

- (void) testPrismaticJoint{
	b2Body *body1 = [self addRectAt:ccp(240,240)];
	b2Vec2 axis(1,0);
	
	b2PrismaticJointDef def;
	def.Initialize(static_,body1,PTM_POINT(ccp(240,280)),axis);
	def.enableLimit = YES;
	def.lowerTranslation = PTM_VALUE(-120);
	def.upperTranslation = PTM_VALUE(200);
	b2PrismaticJoint *joint = (b2PrismaticJoint *) _physicContext->createJoint(&def);
	_jointNode = [CCJointNode nodeWithJoint:joint];
	_jointNode.texture = @"rope.png" ;
	[self addChild:_jointNode z:-1];
	[_pop addObject:_jointNode];
	
	body1 = [self addRectAt:ccp(240,160)];
	b2Body *body2 = [self addBoxAt:ccp(240,80)];
	
	def.Initialize(body1, body2, PTM_POINT(ccp(240,120)),b2Vec2(1,0));
	def.collideConnected = YES;
	def.enableLimit = YES;
	def.lowerTranslation = PTM_VALUE(-128);
	def.upperTranslation = PTM_VALUE(128);
	joint = (b2PrismaticJoint *) _physicContext->createJoint(&def);
	_jointNode = [CCJointNode nodeWithJoint:joint];
	_jointNode.texture = @"rope.png" ;
	[self addChild:_jointNode z:-1];
	[_pop addObject:_jointNode];
}

- (void) testLineJoint{
	b2Body *body1 = [self addRectAt:ccp(240,240)];
	b2Vec2 axis(0,1);
	
	b2WheelJointDef def;
	def.Initialize(static_,body1,PTM_POINT(ccp(240,240)),axis);
	//def.enableLimit = YES;
	//def.lowerTranslation = PTM_VALUE(0);
	//def.upperTranslation = PTM_VALUE(128);
	b2WheelJoint *joint = (b2WheelJoint *) _physicContext->createJoint(&def);
	_jointNode = [CCJointNode nodeWithJoint:joint];
	//_jointNode.texture = @"rope.png" ;
	[self addChild:_jointNode z:1];
	[_pop addObject:_jointNode];
	
	body1 = [self addRectAt:ccp(240,160)];
	b2Body *body2 = [self addBoxAt:ccp(240,80)];
	def.Initialize(body1, body2, PTM_POINT(ccp(240,120)),b2Vec2(1,1));
	def.collideConnected = YES;
	//def.enableLimit = YES;
	//def.lowerTranslation = PTM_VALUE(-128);
	//def.upperTranslation = PTM_VALUE(128);
	//joint = (b2LineJoint *) _physicContext->createJoint(&def);
	_jointNode = [CCJointNode nodeWithJoint:joint];
	//_jointNode.texture = @"rope.png" ;
	[self addChild:_jointNode z:1];
	[_pop addObject:_jointNode];
 
}

- (void) testPulleyJoint{
	b2Body *b1 = [self addBoxAt:ccp(120,160)];
	b2Body *b2 = [self addRectAt:ccp(360,100)];
	
	b2PulleyJointDef def;
	def.Initialize(b1, b2,
				   PTM_POINT(ccp(120,280)), PTM_POINT(ccp(360,280)),
				   b1->GetWorldCenter(), b2->GetWorldCenter(),
				   1);
	
	b2PulleyJoint *joint = (b2PulleyJoint *) _physicContext->createJoint(&def);
	_jointNode = [CCJointNode nodeWithJoint:joint];
	_jointNode.texture = @"rope.png" ;
	[self addChild:_jointNode];
	[_pop addObject:_jointNode];
}

- (void) testWeldJoint{
	CCComponent *sprite;
	
	b2FixtureDef fdef;
	fdef.friction = .5;
	fdef.restitution = .5;
	
	b2BodyDef bdef;
	bdef.type = b2_dynamicBody;
	bdef.bullet = TRUE;
	fdef.density = .2;
	
	b2WeldJointDef def;
	
	b2Body *prebody = static_;
	for (int i = 0; i < 20; ++i) {
		sprite = [CCComponent componentWithFile:@"staff9n-n.png"];
		sprite.scale = .2;
		[_pop addObject:sprite];
		sprite.destroyPhysicOnDealloc = YES;
		b2Body *body = [self addRectangleComponent:sprite 
										  position:ccp(20+i*sprite.size.width,240)
										   bodyDef:&bdef 
										fixtureDef:&fdef];
		def.Initialize(prebody, body, PTM_POINT(ccp(20+i*sprite.size.width,240)));
		_physicContext->createJoint(&def);	
		
		prebody = body;
	}
	
}

- (void) testXedap{
	b2BodyDef bdef;
	bdef.type = b2_dynamicBody;
	
	b2FixtureDef fdef;
	fdef.density = .5;
	fdef.restitution = .5;
	fdef.friction = 1;
	
	
	b2Body *body = [self addRectangleAt:ccp(240,160) width:100 height:30 angle:0 bodyDef:&bdef fixtureDef:&fdef];
	b2Body *wheel1 = [self addCircleAt:ccp(190,100) radius:25 bodyDef:&bdef fixtureDef:&fdef];
	b2Body *wheel2 = [self addCircleAt:ccp(290,100) radius:25 bodyDef:&bdef fixtureDef:&fdef];
	
	fdef.density = 1;
	b2WheelJointDef jdef;
	jdef.Initialize(body, wheel1, PTM_POINT(ccp(190,100)),b2Vec2(0,1));
	jdef.collideConnected = true;
	jdef.dampingRatio = 1;
	jdef.frequencyHz = 3;
	_physicContext->createJoint(&jdef);
	
	wheel = wheel1;	
	
	jdef.Initialize(body, wheel2, PTM_POINT(ccp(290,100)),b2Vec2(0,1));
	_physicContext->createJoint(&jdef);
}

- (void) testOto{
	b2BodyDef bdef;
	b2FixtureDef fdef;
	fdef.density = 1;
	fdef.restitution = .5;
	fdef.friction = .5;
	
	CCComponent *sprite = [CCComponent componentWithFile:@"blocks.png"];
	//sprite.scale = .25;
	bdef.type = b2_dynamicBody;
	b2Body *body = [self addRectangleComponent:sprite 
									  position:ccp(240,160) 
										offset:CGPointZero 
										 angle:90 
										  size:sprite.size 
									   bodyDef:&bdef 
									fixtureDef:&fdef];
	[_pop addObject:sprite];
	sprite.destroyPhysicOnDealloc = YES;
	
	sprite = [CCComponent componentWithFile:@"rock1-1.png"];
	sprite.destroyPhysicOnDealloc = YES;
	sprite.scale = .5;
	b2Body *wheel = [self addCircleComponent:sprite 
									position:ccp(200,120) 
									 bodyDef:&bdef 
								  fixtureDef:&fdef];
	[_pop addObject:sprite];
	b2RevoluteJointDef jdef;
	jdef.Initialize(body,wheel,wheel->GetWorldCenter());
	_physicContext->createJoint(&jdef);
	
	
	sprite = [CCComponent componentWithFile:@"rock1-1.png"];	
	sprite.destroyPhysicOnDealloc = YES;
	sprite.scale = .5;
	bdef.angularVelocity = 10;
	bdef.fixedRotation = 1;
	[_pop addObject:sprite];
	wheel = [self addCircleComponent:sprite 
							position:ccp(280,120)
							 bodyDef:&bdef
						  fixtureDef:&fdef];
	
	jdef.Initialize(body,wheel,wheel->GetWorldCenter());
	_physicContext->createJoint(&jdef);
}

- (b2Body *) addBoxAt:(CGPoint) pos{
	CCComponent *sprite = [CCComponent componentWithFile:@"rock1-1.png"];
	[_pop addObject:sprite];
	sprite.destroyPhysicOnDealloc = YES;
	
	float scale = CCRANDOM_0_1() ;
	sprite.scale = scale < .4 ? .4 : scale;
	
	b2FixtureDef fdef;
	fdef.friction = .5;
	fdef.restitution = .5;
	
	b2BodyDef bdef;
	bdef.type = b2_dynamicBody;
	bdef.bullet = TRUE;
	bdef.angle = CC_DEGREES_TO_RADIANS(CCRANDOM_0_1() * 360);
	fdef.density = 1.0;
	
	
	[self addChild:sprite z:1];
	
	return [self addCircleComponent:sprite 
						   position:pos 
							bodyDef:&bdef 
						 fixtureDef:&fdef];
}

- (void) toggleBackground{
	CCNode *bg = [self getChildByTag:1024];
	bg.visible = !bg.visible;
}

- (b2Body *) addRectAt:(CGPoint) pos{
	CCComponent *sprite = [CCComponent componentWithFile:@"blocks.png"];
	sprite.destroyPhysicOnDealloc = YES;
	[_pop addObject:sprite];
	
	float scale = CCRANDOM_0_1() ;
	sprite.scale = scale < .4 ? .4 : scale;
	
	b2FixtureDef fdef;
	fdef.friction = .5;
	fdef.restitution = .5;
	
	b2BodyDef bdef;
	bdef.type = b2_dynamicBody;
	bdef.bullet = TRUE;
	bdef.angle = CC_DEGREES_TO_RADIANS(CCRANDOM_0_1() * 360);
	fdef.density = 1.0;
	
	return [self addRectangleComponent:sprite 
							  position:pos 
								offset:ccp(0,0) 
								 angle:0 
								  size:sprite.size 
							   bodyDef:&bdef 
							fixtureDef:&fdef];
}

#pragma mark Touches
- (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
	if (mouse_ != NULL || _gameState != kGameStatePlaying) {
		return;
	}
	
	CGPoint pos = [self pointForTouches:touches];
	
	[self pointForTouches:touches];
	//CCComponent *node = [self queryComponentAtPoint:pos];
	b2Body *body = [self queryBodyAtPoint:pos];
	
	if (body) {
		b2MouseJointDef def;
		def.bodyA = static_;
		def.bodyB = body;
		def.target = PTM_POINT(pos);
		def.dampingRatio = 1.0;
		//def.frequencyHz = 1./30;
		def.maxForce = 1000.0f * def.bodyB->GetMass();
		mouse_ = (b2MouseJoint *) _physicContext->createJoint(&def);
		[_scoreManager insertScore:((CCRANDOM_0_1() + 1) * 200) name:@"Hiepnd" category:_LBL];
		//[_scoreManager save];
		//[_scoreManager validateValueScoresForCategory:@"Common"];
	}else {
		//[self addBoxAt:pos];	
		//b2Vec2 v = PTM_POINT(pos);
		//_physicContext->explosion(v,10,10000);
		//Bomb *bomb = [Bomb node];
		//bomb.position = pos;
		//[self addActor:bomb];
		if ([_LBL isEqualToString:@"Simple Oto Test"]) {
			
			if (pos.x < 240) {
				wheel->ApplyTorque(500);
			}else {
				wheel->ApplyTorque(-500);
			}

		}
	}
	
}

- (void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
	if (_gameState != kGameStatePlaying) {
		return;
	}
	
	if (mouse_ != NULL) {
		UITouch *touch = [touches anyObject];
		CGPoint pos = [touch locationInView:touch.view];
		pos = UIToGL(pos);
		mouse_->SetTarget(PTM_POINT(pos));
	}
}

- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
	if (_gameState != kGameStatePlaying) {
		return;
	}
	
	if (mouse_ != NULL) {
		_physicContext->DestroyJoint(mouse_);
		mouse_ = NULL;		
	}
}

#pragma mark When iPhone is shaked
- (void) deviceShaked{
	if (_gameState == kGameStatePlaying) {
		[self pause];
		[_mainMenu showImmediately];
	}
}

#pragma mark ACC
- (void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration{
	//Simple low pass filter
	accel[0] = acceleration.x * kFilteringFactor + accel[0] * (1.0 - kFilteringFactor);
	accel[1] = acceleration.y * kFilteringFactor + accel[1] * (1.0 - kFilteringFactor);
	accel[2] = acceleration.z * kFilteringFactor + accel[2] * (1.0 - kFilteringFactor);
	
	
	float angle = [[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationLandscapeLeft ? -90 : 90;
	CGPoint v = ccpRotateByAngle(ccp(accel[0], accel[1]), ccp(0,0), CC_DEGREES_TO_RADIANS(angle));
	
	_physicContext->setGravity(b2Vec2(v.x * 10,v.y * 10));
}

#pragma mark App state
- (void) applicationWillResignActive:(NSNotification *) notification{
	if (_gameState == kGameStatePlaying) {
		[_mainMenu showImmediately];
		[self pause];
	}
}

- (void) applicationDidReceiveMemoryWarning:(NSNotification *) notification{
}

- (void) applicationDidBecomeActive:(NSNotification *) notification{
}

#pragma mark OnGameMenuDelegate
- (void) simpleMenuDidShow:(SimpleMenu *) menu{
	
}

- (void) simpleMenuDidHide:(SimpleMenu *) menu{
	[self resume];
}

- (void) simpleMenuWillShow:(SimpleMenu *) menu{
	[self pause];
}

- (void) simpleMenuWillHide:(SimpleMenu *) menu{
	
}

- (void) simpleMenu:(SimpleMenu *) menu didActivateItemTag:(int) tag{
	switch (tag) {
		case kSimpleMenuDynamicResume:
			[menu hide];
			break;
			
		case kSimpleMenuDynamicRestart:
			menu.delegate = nil;
			[[CCDirector sharedDirector] jointContext];
			break;
			
//		case kMenuItemToggleBackground:
//			[self performSelector:@selector(toggleBackground)];		
//			break;
			
		case kSimpleMenuDynamicHome:
			menu.delegate = nil;
			[[CCDirector sharedDirector] homeContext];
			break;
		default:
			if (tag > kMenuItemTestDoNotUse) {
				[self setTest:tag];
				[menu hide];
			}
			break;
	}	
}
@end