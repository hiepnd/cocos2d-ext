//
//  FollowContext.m
//  ___PROJECTNAME___
//
//  Created by Ngo Duc Hiep on 3/29/11.
//  Copyright 2011 PTT Solution., JSC. All rights reserved.
//

#import "FollowContext.h"
#import "AppDirector.h"

void printbits(int v, int num){
	NSMutableString *s = [NSMutableString string];
	for (int i = 0; i < num; i++) {
		//[s appendFormat:@"%d",((1 << i) & v) ? 1 : 0];
		[s insertString:[NSString stringWithFormat:@"%d",((1 << i) & v) ? 1 : 0] atIndex:[s length] - i];
	}
	NSLog(@"%d=%@",v,s);
}


@implementation FollowContext

- (id) init{
	self = [super init];
	self.boundary = CGRectMake(0, 0, 960, 640);
	self.maxScale = 2;
	_isTouchEnabled = YES;
	_interestedStateChanges = kAppStateWillResignActive;
	
	//NSLog(@"HASH = %d %d",CP_HASH_PAIR(2,2),CP_HASH_PAIR(3,3));
	
	_mainMenu = [SimpleMenu node];
	[self addChild:_mainMenu];
	_mainMenu.delegate = self;
	
	CCMenuItem *it1 = [CCMenuItemFont itemFromString:@"Follow OFF"];
	CCMenuItem *it2 = [CCMenuItemFont itemFromString:@"Follow ON"];
	CCMenuItem *it = [CCMenuItemToggle itemWithTarget:nil selector:nil items:it1,it2,nil];
	it.tag = kSimpleMenuDynamicFollowOnOff;
	it.position = ccp(-120,100 - 56 - 28);
	[_mainMenu addDynamicItem:it];
	
	
	_mainMenu.showAnimation = [CCEaseElasticOut actionWithAction:_mainMenu.showAnimation period:.7];
	
	CCSlider *_slider = [CCSlider sliderWithTrackImage:@"slider_track.png" knobImage:@"slider_knob.png" target:self selector:@selector(scaleChanged:)];
	_slider.position = ccp(450,160);
	_slider.rotation = -90;
	_slider.height = 100;
	_slider.horizontalPadding = 50;
	_slider.trackTouchOutsideContent = YES;
	_slider.evaluateFirstTouch = NO;
	_slider.minValue = self.minScale;
	_slider.maxValue = self.maxScale;
	_slider.value = _minScale;
	[_mainMenu addChild:_slider];
	
	[self addAutoreleaseSpriteFrame:@"rbg.plist"];
	[self addAutoreleaseSpriteFrame:@"bullet.plist"];
	
	CCSprite *bg;
	bg = [CCSprite spriteWithSpriteFrameName:@"garden3.png"];
	bg.position = ccp(240,160);
	[self addChild:bg];
	
	bg = [CCSprite spriteWithSpriteFrameName:@"garden2.png"];
	bg.position = ccp(720,160);
	[self addChild:bg];
	
	bg = [CCSprite spriteWithSpriteFrameName:@"garden4.png"];
	bg.position = ccp(240,480);
	[self addChild:bg];
	
	bg = [CCSprite spriteWithSpriteFrameName:@"garden4.png"];
	bg.position = ccp(720,480);
	[self addChild:bg];
	
	b2BodyDef bd;
	b2FixtureDef fd;
	
	fd.density = 1;
	bd.angularDamping = 10;
	bd.linearDamping = 1;
	
	/** Add the walls around iPhone  */
	[self addRectangleAt:ccp(480,-50) width:960 height:100 angle:0 bodyDef:&bd fixtureDef:&fd];
	[self addRectangleAt:ccp(480,690) width:960 height:100 angle:0 bodyDef:&bd fixtureDef:&fd];
	[self addRectangleAt:ccp(-50,320) width:100 height:640 angle:0 bodyDef:&bd fixtureDef:&fd];
	_static = [self addRectangleAt:ccp(1010,320) width:100 height:640 angle:0 bodyDef:&bd fixtureDef:&fd];
	
	bd.type = b2_dynamicBody;
	
	node = [CCComponent componentWithFile:@"rope.png"];
	CGSize size = [node contentSize];
	node.scaleX = 6/16.0;
	
	float dx = 200, dy = 50;
	
	[self addActor:node];
	b1 = [self addRectangleComponent:node 
									position:ccp(dx,dy) 
									 bodyDef:&bd 
								  fixtureDef:&fd];
	
	[self follow:node];

	fd.density = .05;	
	
	b2RevoluteJointDef jd;
	jd.enableLimit = YES;
	jd.lowerAngle = -60 * M_PI/180;
	jd.upperAngle = 60 * M_PI/180;
	jd.collideConnected = true;
	
	CCComponent *sprite;
	b2Body *prebody = b1;
	for (int i = 0; i < 4; ++i) {
		sprite = [CCComponent componentWithFile:@"rope.png"];
		sprite.scaleY = .5;
		[self addActor:sprite];
		b2Body *body = [self addRectangleComponent:sprite 
										  position:ccp(dx + 15 + i * 20, dy)
										   bodyDef:&bd 
										fixtureDef:&fd];
		//def.Initialize(prebody, body, PTM_POINT(ccp(100-3-(i)*sprite.size.width,100)));
		jd.Initialize(prebody,body,PTM_POINT(ccp(dx + 5 + i * 20, dy)));
		_physicContext->createJoint(&jd);	
		
		prebody = body;
	}
	
	//bd.type = b2_kinematicBody;
	fd.density = .5;
	sprite = [CCComponent componentWithFile:@"staff9n-n.png"];
	sprite.scaleX = .5;
	//sprite.updatePhysic = YES;
	bd.fixedRotation = YES;
	sprite.tag = ACTOR_TAG_BRIDGE;
	[self addActor:sprite];
	b2Body *b = [self addRectangleComponent:sprite 
					   position:ccp(320,10) 
						bodyDef:&bd 
					 fixtureDef:&fd];
	
	
	CCJointNode *jn = [CCJointNode nodeWithJoint:[self createMouseJoint:b staticBody:_static position:ccp(320,10)]];
	[self addChild:jn];
	jn.position = ccp(320,10);
	
	[jn runAction:[CCRepeatForever actionWithAction:[CCSequence actionOne: [CCMoveBy actionWithDuration:4 position:ccp(0,600)]
																		  two: [CCMoveBy actionWithDuration:3 position:ccp(0,-600)]]]];
	
	
	sprite = [CCComponent componentWithFile:@"staff9n-n.png"];
	sprite.scaleX = .5;
	//sprite.updatePhysic = YES;
	bd.fixedRotation = YES;
	sprite.tag = ACTOR_TAG_BRIDGE;
	[self addActor:sprite];
	b = [self addRectangleComponent:sprite 
								   position:ccp(480,580) 
									bodyDef:&bd 
								 fixtureDef:&fd];
	
	
	jn = [CCJointNode nodeWithJoint:[self createMouseJoint:b staticBody:_static position:ccp(480,580)]];
	[self addChild:jn];
	jn.position = ccp(480,580);
	
	[jn runAction:[CCRepeatForever actionWithAction:[CCSequence actionOne: [CCMoveBy actionWithDuration:2 position:ccp(0,-500)]
																	  two: [CCMoveBy actionWithDuration:3 position:ccp(0,500)]]]];
	
	
	sprite = [CCComponent componentWithFile:@"staff9n-n.png"];
	sprite.scaleX = .5;
	//sprite.updatePhysic = YES;
	bd.fixedRotation = YES;
	sprite.tag = ACTOR_TAG_BRIDGE;
	[self addActor:sprite];
	b = [self addRectangleComponent:sprite 
								   position:ccp(800,50) 
									bodyDef:&bd 
								 fixtureDef:&fd];
	
	
	jn = [CCJointNode nodeWithJoint:[self createMouseJoint:b staticBody:_static position:ccp(800,50)]];
	[self addChild:jn];
	jn.position = ccp(800,50);
	
	[jn runAction:[CCRepeatForever actionWithAction:[CCSequence actionOne: [CCMoveBy actionWithDuration:3 position:ccp(0,500)]
																	  two: [CCMoveBy actionWithDuration:2 position:ccp(0,-500)]]]];
	
	
	
	_bullets = [CCSpriteBatchNode batchNodeWithFile:@"duck+spaceship.png"];
	[self addBatchNode:_bullets];
	[self addGroup:GROUP_BULLETS];
	
	[self addContactListenerBetweenGroup:CC_DEFAULT_GROUP andGroup:GROUP_BULLETS target:self selector:@selector(a:b:)];
	
	[self addContactListenerBetweenGroup:GROUP_BULLETS andGroup:GROUP_BULLETS target:self selector:@selector(a:b:)];
	
	[self setDebugDraw:YES flag:0x01 | 0x02];
	
	return self;
}

- (void) a:(CCNode *) n1 b:(CCNode *) n2{
	if ([n1 isKindOfClass:[Bullet class]]) {
		((Bullet *)n1).invalid = YES;
		[(Bullet *)n1 explode];
		[self removeFromGroup:GROUP_BULLETS actor:n1];
	}
	
	if ([n2 isKindOfClass:[Bullet class]]) {
		((Bullet *)n2).invalid = YES;
		[(Bullet *)n2 explode];
		[self removeFromGroup:GROUP_BULLETS actor:n2];
	}
}

- (void) addBullet:(CGPoint) position{
	position = ccpSub(position, ccp(50,50));
	Bullet *bullet = [Bullet node];
	bullet.tag = ACTOR_TAG_BULLET;
	b2BodyDef bd;
	b2FixtureDef fd;
	bd.type = b2_dynamicBody;
	bd.bullet = true;
	fd.density = 1;
	fd.restitution = .5;
	fd.friction = .5;
	bullet.deltaAngle = -[CCNode degree:position];
	
	[self addActor:bullet batch:_bullets group:GROUP_BULLETS];
	//[self addActor:bullet group:GROUP_BULLETS];
	
	[self addCircleComponent:bullet position:ccp(10,10) radius:6 bodyDef:&bd fixtureDef:&fd];
	
	[bullet applyForce:ccpMult(position, .5)];
}

- (void) onEnter{
	//[self scale:_minScale];
	[super onEnter];
}

- (void) onExit{
	NSArray *bullets = [self getAllActors:GROUP_BULLETS];
	[bullets makeObjectsPerformSelector:@selector(removeFromParentAndCleanup:) withObject:[NSNumber numberWithBool:YES]];
	[super onExit];
}

- (void) tick:(ccTime)dt{
	[self step:dt];
	
	[super tick:dt];
}

- (void) scaleChanged:(CCSlider *) slider{
	[self scale:slider.value];
}

- (void) ccTouchesBegan:(NSSet *) touches withEvent:(UIEvent *) event{
//	UITouch *touch = [touches anyObject];
//	CGPoint p1 = [[CCDirector sharedDirector] convertToGL:[touch locationInView:touch.view]];
//	CGPoint p2 = [[CCDirector sharedDirector] convertToGL:ccp(240,160)];
//	
//	[self bounceBy:ccpSub(p2, p1) duration:1 withFunction:ff];
	
	
	
	
	CGPoint pos = [self pointForTouches:touches];
	
	[self addBullet:pos];
	
	pos = ccpMult(ccpSub(pos, node.position), .3);

	b2Joint *joint = [self createMouseJoint:b1 staticBody:_static position:node.position];
	_jointNode = [CCJointNode nodeWithJoint:joint];
	_jointNode.position = node.position;
	[self addChild:_jointNode];
	_jointNode.physicContext = _physicContext;
	[_jointNode runAction:[CCSequence actionOne:[CCMoveBy actionWithDuration:.1 position:pos] 
									   two:[CCCallFuncND actionWithTarget:_jointNode selector:@selector(removeFromParentAndCleanup:) data:[NSNumber numberWithBool:YES]]]];
}

- (void) ccTouchesMoved:(NSSet *) touches withEvent:(UIEvent *) event{
	if (_jointNode) {
		//_jointNode.position = [self pointForTouches:touches];
	}
}

- (void) ccTouchesEnded:(NSSet *) touches withEvent:(UIEvent *) event{
	//[_jointNode removeFromParentAndCleanup:NO];
	//_jointNode = nil;
}

- (void) applicationWillResignActive:(NSNotification *)notification{
	if (_mainMenu.isShown) {
		return;
	}

	[self freezeAllChilden];
	[self pauseScheduler];
	[_mainMenu showImmediately];
}

#pragma mark OnGameMenuDelegate
- (void) simpleMenuDidShow:(SimpleMenu *) menu{
	
}

- (void) simpleMenuDidHide:(SimpleMenu *) menu{
	[self unFreezeAllChilden];
	[self resumeScheduler];
}

- (void) simpleMenuWillShow:(SimpleMenu *) menu{
	[self freezeAllChilden];
	[self pauseScheduler];
}

- (void) simpleMenuWillHide:(SimpleMenu *) menu{
	
}

- (void) simpleMenu:(SimpleMenu *) menu didActivateItemTag:(int) tag{
	switch (tag) {
		case kSimpleMenuDynamicHome:
			[[CCDirector sharedDirector] homeContext];
			break;
			
		case kSimpleMenuDynamicRestart:
			menu.delegate = nil;
			[[CCDirector sharedDirector] followContext];
			break;
			
		case kSimpleMenuDynamicResume:
			[menu hide];
			break;	
			
		case kSimpleMenuDynamicFollowOnOff:
			CCMenuItemToggle *item = (CCMenuItemToggle *) [menu dynamicMenuItemBytag:kSimpleMenuDynamicFollowOnOff];
			if(item.selectedIndex == 1)
				[self unfollow];
			else 
				[self follow:node];	
			
			[menu hide];
			break;

	}	
}

@end
