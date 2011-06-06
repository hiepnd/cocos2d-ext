/*
 * cocos2d+ext for iPhone
 *
 * Copyright (c) 2011 - Ngo Duc Hiep
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 *
 */

#import "Ragdoll.h"

#define REG_PHYSIC(body,key)												\
	data = [self registerPhysic:[NSString stringWithFormat:@"%d",key]];		\
	data.entity = body;														\
	data.type = PHYSIC_BODY;												\
	data.component = self;													\
	body->SetUserData(data);												\
	body->SetActive(FALSE)

#define CREATE_SPRITE(name,key)														\
	name = (name == nil) ? @" " : name;												\
	if (_useSheet) {																\
		sprite = [CCSprite spriteWithSpriteFrameName:name];							\
		[_batchNode addChild:sprite];												\
	}else {																			\
		sprite = [CCSprite spriteWithFile:name];									\
	}																				\
	if (sprite && config.scaleSprite) {												\
		sprite.scale = config.scale;												\
	}																				\
	sprite.tag = key;																\
	if (sprite) {																	\
		[_segments setObject:sprite forKey:[NSString stringWithFormat:@"%d",key]];	\
	}


@implementation RagdollConfig
@synthesize  scale = _scale;
@synthesize scaleSprite = _scaleSprite;
@synthesize texture = _texture;
@synthesize frames = _frames;
@synthesize head = _head;
@synthesize torso1 = _torso1;
@synthesize torso2 = _torso2;
@synthesize torso3 = _torso3;
@synthesize upplerArmL = _upplerArmL;
@synthesize upplerArmR = _upplerArmR;
@synthesize lowerArmL = _lowerArmL;
@synthesize lowerArmR = _lowerArmR;
@synthesize upplerLegL = _upplerLegL;
@synthesize upplerLegR = _upplerLegR;
@synthesize lowerLegL = _lowerLegL;
@synthesize lowerLegR = _lowerLegR;

- (id) init{
	self = [super init];
	_scale = 1;
	_scaleSprite = YES;
	
	self.texture = @"nobita.pvr.ccz";
	self.frames = @"nobita.plist";
	
	self.head = @"head.png";
	self.upplerArmL = self.upplerArmR = @"upper_arm.png";
	self.lowerArmL = @"lower_arm_l.png";
	self.lowerArmR = @"lower_arm_r.png";
	self.upplerLegL = self.upplerLegR = @"upper_leg.png";
	self.lowerLegL = self.lowerLegR = @"lower_leg.png";
	self.torso1 = @"torse1.png";
	self.torso2 = @"torse2.png";
	self.torso3 = @"torse3.png";
	return self;
}

+ (id) config{
	return [[[self alloc] init] autorelease];
}

- (void) dealloc{
	[_texture release];
	[_head release];
	[_torso1 release];
	[_torso2 release];
	[_torso3 release];
	[_upplerArmL release];
	[_upplerArmR release];
	[_lowerArmL release];
	[_lowerArmR release];
	[_upplerLegL release];
	[_upplerLegR release];
	[_lowerLegL release];
	[_lowerLegR release];
	[super dealloc];
}
@end


@interface CCNode(BUZZY)

@end

@implementation CCNode(BUZZY)
- (void) offsetPosition:(CGPoint) offset{
	self.position = ccpAdd(self.position, offset);
}
@end

@interface Ragdoll(Private)
- (void) setupPhysic:(PhysicContext *) context;
- (void) setupPhysic:(PhysicContext *) context config:(RagdollConfig *) config;
@end

@implementation Ragdoll(Private)

- (void) setupPhysic:(PhysicContext *) context{
	[self setupPhysic:context config:[RagdollConfig config]];
}

- (void) setupPhysic:(PhysicContext *) context config:(RagdollConfig *) config{
	b2CircleShape circle;
	b2PolygonShape box;
	b2BodyDef bd;
	b2FixtureDef fd;
	b2RevoluteJointDef jd;
	
	bd.type = b2_dynamicBody;
	
	PhysicUserData *data ;
	float scale = config.scale == 0.0 ? 1 : config.scale;
	CCSprite *sprite;
	
	_useSheet = NO;
	if (config.texture) {
		[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:config.frames];
		_batchNode = [[CCSpriteBatchNode batchNodeWithFile:config.texture] retain];
		_useSheet = YES;
	}
	
	fd.density = 1.0;
	fd.friction = .4;
	fd.restitution = .3;
	
	// Torso1
	box.SetAsBox(PTM_VALUE(15 * scale), PTM_VALUE(10 * scale));
	fd.shape = &box;
	fd.restitution = .1;
	bd.position.Set(PTM_VALUE(0),PTM_VALUE(-28 * scale));
	b2Body *torso1 = context->createBody(&bd);
	torso1->CreateFixture(&fd);
	
	REG_PHYSIC(torso1,rdTagTorso1);
	CREATE_SPRITE(config.torso1,rdTagTorso1);
		
	// Torso2
	box.SetAsBox(PTM_VALUE(15 * scale), PTM_VALUE(10 * scale));
	fd.shape = &box;
	fd.restitution = .1;
	bd.position.Set(PTM_VALUE(0),PTM_VALUE(-43 * scale));
	b2Body *torso2 = context->createBody(&bd);
	torso2->CreateFixture(&fd);
	
	REG_PHYSIC(torso2,rdTagTorso2);
	CREATE_SPRITE(config.torso2,rdTagTorso2);
	
	// UpperLeg
	// L
	box.SetAsBox(PTM_VALUE(7.5 * scale), PTM_VALUE(22 * scale));
	fd.shape = &box;
	bd.position.Set(PTM_VALUE(-8 * scale),PTM_VALUE(-85 * scale));
	b2Body *upperLegL = context->createBody(&bd);
	upperLegL->CreateFixture(&fd);
	
	REG_PHYSIC(upperLegL, rdTagUpperLegL);
	CREATE_SPRITE(config.upplerLegL, rdTagUpperLegL);
		
	// R
	box.SetAsBox(PTM_VALUE(7.5 * scale), PTM_VALUE(22 * scale));
	fd.shape = &box;
	bd.position.Set(PTM_VALUE(8 * scale),PTM_VALUE(-85 * scale));
	b2Body *upperLegR = context->createBody(&bd);
	upperLegR->CreateFixture(&fd);
	
	REG_PHYSIC(upperLegR, rdTagUpperLegR);
	CREATE_SPRITE(config.upplerLegR, rdTagUpperLegR);
		
	// Torso3
	box.SetAsBox(PTM_VALUE(15 * scale), PTM_VALUE(10 * scale));
	fd.shape = &box;
	fd.restitution = .1;
	bd.position.Set(PTM_VALUE(0),PTM_VALUE(-58 * scale));
	b2Body *torso3 = context->createBody(&bd);
	torso3->CreateFixture(&fd);
	
	REG_PHYSIC(torso3,rdTagTorso3);
	CREATE_SPRITE(config.torso3,rdTagTorso3);
		
	// UpperArm
	fd.density = 1.0;
	fd.friction = 0.4;
	fd.restitution = 0.1;
	// L
	box.SetAsBox(PTM_VALUE(18 * scale), PTM_VALUE(6.5 * scale));
	fd.shape = &box;
	bd.position.Set(PTM_VALUE(-30 * scale),PTM_VALUE(-20 * scale));
	b2Body *upperArmL = context->createBody(&bd);
	upperArmL->CreateFixture(&fd);
	
	REG_PHYSIC(upperArmL, rdTagUpperArmL);
	CREATE_SPRITE(config.upplerArmL, rdTagUpperArmL);
		
	// R
	box.SetAsBox(PTM_VALUE(18 * scale), PTM_VALUE(6.5 * scale));
	fd.shape = &box;
	bd.position.Set(PTM_VALUE(30 * scale),PTM_VALUE(-20 * scale));
	b2Body *upperArmR = context->createBody(&bd);
	upperArmR->CreateFixture(&fd);
	
	REG_PHYSIC(upperArmR, rdTagUpperArmR);
	CREATE_SPRITE(config.upplerArmR, rdTagUpperArmR);
		
	// LowerArm
	// L
	box.SetAsBox(PTM_VALUE(17 * scale), PTM_VALUE(6 * scale));
	fd.shape = &box;
	bd.position.Set(PTM_VALUE(-57 * scale),PTM_VALUE(-20 * scale));
	b2Body *lowerArmL = context->createBody(&bd);
	lowerArmL->CreateFixture(&fd);
	
	REG_PHYSIC(lowerArmL, rdTagLowerArmL);
	CREATE_SPRITE(config.lowerArmL, rdTagLowerArmL);
		
	// R
	box.SetAsBox(PTM_VALUE(17 * scale), PTM_VALUE(6 * scale));
	fd.shape = &box;
	bd.position.Set(PTM_VALUE(57 * scale),PTM_VALUE(-20 * scale));
	b2Body *lowerArmR = context->createBody(&bd);
	lowerArmR->CreateFixture(&fd);
	
	REG_PHYSIC(lowerArmR, rdTagLowerArmR);
	CREATE_SPRITE(config.lowerArmR, rdTagLowerArmR);
		
	// LowerLeg
	// L
	box.SetAsBox(PTM_VALUE(6 * scale), PTM_VALUE(20 * scale));
	fd.shape = &box;
	bd.position.Set(PTM_VALUE(-8 * scale),PTM_VALUE(-120 * scale));
	b2Body *lowerLegL = context->createBody(&bd);
	lowerLegL->CreateFixture(&fd);
	
	REG_PHYSIC(lowerLegL, rdTagLowerLegL);
	CREATE_SPRITE(config.lowerLegL, rdTagLowerLegL);
		
	// R
	box.SetAsBox(PTM_VALUE(6 * scale), PTM_VALUE(20 * scale));
	fd.shape = &box;
	bd.position.Set(PTM_VALUE(8 * scale),PTM_VALUE(-120 * scale));
	b2Body *lowerLegR = context->createBody(&bd);
	lowerLegR->CreateFixture(&fd);
	
	REG_PHYSIC(lowerLegR, rdTagLowerLegR);
	CREATE_SPRITE(config.lowerLegR, rdTagLowerLegR);
		
	// Head
	circle.m_radius = PTM_VALUE(12.5 * scale);
	fd.shape = &circle;
	fd.restitution = .3;
	bd.position.Set(PTM_VALUE(0), PTM_VALUE(0));
	head = context->createBody(&bd);
	head->CreateFixture(&fd);
	
	REG_PHYSIC(head,rdTagHead);
	CREATE_SPRITE(config.head,rdTagHead);
		
	jd.enableLimit = true;
	
	// Head to shoulders
	jd.lowerAngle = -40 / (180/M_PI);
	jd.upperAngle = 40 / (180/M_PI);
	//jd.Initialize(torso1, head, new b2Vec2(startX / m_physScale, (startY + 15) / m_physScale));
	jd.Initialize(torso1, head, b2Vec2(PTM_VALUE(0) , PTM_VALUE(-15 * scale)));
	context->createJoint(&jd);
	
	// Upper arm to shoulders
	// L
	jd.lowerAngle = -85 / (180/M_PI);
	jd.upperAngle = 130 / (180/M_PI);
	jd.Initialize(torso1, upperArmL, b2Vec2(PTM_VALUE(-18 * scale) , PTM_VALUE(-20 * scale) ));
	context->createJoint(&jd);
	// R
	jd.lowerAngle = -130 / (180/M_PI);
	jd.upperAngle = 85 / (180/M_PI);
	jd.Initialize(torso1, upperArmR, b2Vec2(PTM_VALUE(18 * scale), PTM_VALUE(-20 * scale)));
	context->createJoint(&jd);
	
	// Lower arm to upper arm
	// L
	jd.lowerAngle = -130 / (180/M_PI);
	jd.upperAngle = 10 / (180/M_PI);
	jd.Initialize(upperArmL, lowerArmL,  b2Vec2(PTM_VALUE(-45 * scale) , PTM_VALUE(-20 * scale) ));
	context->createJoint(&jd);
	// R
	jd.lowerAngle = -10 / (180/M_PI);
	jd.upperAngle = 130 / (180/M_PI);
	jd.Initialize(upperArmR, lowerArmR,  b2Vec2(PTM_VALUE(45 * scale) , PTM_VALUE(-20 * scale) ));
	context->createJoint(&jd);
	
	// Shoulders/stomach
	jd.lowerAngle = -15 / (180/M_PI);
	jd.upperAngle = 15 / (180/M_PI);
	jd.Initialize(torso1, torso2,  b2Vec2(PTM_VALUE(0) , PTM_VALUE(-35 * scale) ));
	context->createJoint(&jd);
	// Stomach/hips
	jd.Initialize(torso2, torso3,  b2Vec2(PTM_VALUE(0) , PTM_VALUE(-50 * scale) ));
	context->createJoint(&jd);
	
	// Torso to upper leg
	// L
	jd.lowerAngle = -25 / (180/M_PI);
	jd.upperAngle = 45 / (180/M_PI);
	jd.Initialize(torso3, upperLegL,  b2Vec2(PTM_VALUE(-8 * scale), PTM_VALUE(-72 * scale) ));
	context->createJoint(&jd);
	// R
	jd.lowerAngle = -45 / (180/M_PI);
	jd.upperAngle = 25 / (180/M_PI);
	jd.Initialize(torso3, upperLegR,  b2Vec2(PTM_VALUE(8 * scale) , PTM_VALUE(-72 * scale) ));
	context->createJoint(&jd);
	
	// Upper leg to lower leg
	// L
	jd.lowerAngle = -25 / (180/M_PI);
	jd.upperAngle = 115 / (180/M_PI);
	jd.Initialize(upperLegL, lowerLegL,  b2Vec2(PTM_VALUE(-8 * scale) , PTM_VALUE(-105 * scale)));
	context->createJoint(&jd);
	// R
	jd.lowerAngle = -115 / (180/M_PI);
	jd.upperAngle = 25 / (180/M_PI);
	jd.Initialize(upperLegR, lowerLegR,  b2Vec2(PTM_VALUE(8 * scale) , PTM_VALUE(-105 * scale) ));
	context->createJoint(&jd);
}
@end


@implementation Ragdoll
- (id) initWithPhysicContext:(PhysicContext *) context{
	self = [super init];
	_segments = [[NSMutableDictionary alloc] init];
	
	_physicContext = context;
	[self setupPhysic:context];
	
	return self;
}

+ (id) ragdollWithPhysicContext:(PhysicContext *) context{
	return [[[self alloc] initWithPhysicContext:context] autorelease];
}

- (id) initWithPhysicContext:(PhysicContext *) context config:(RagdollConfig *) config{
	self = [super initSafe];
	_segments = [[NSMutableDictionary alloc] init];
	
	_physicContext = context;
	[self setupPhysic:context config:config];
	
	return self;
}

+ (id) ragdollWithPhysicContext:(PhysicContext *) context config:(RagdollConfig *) config{
	return [[[self alloc] initWithPhysicContext:context config:config] autorelease];
}

- (void) dealloc{
	[_segments release];

	NSEnumerator *itt = [_physics objectEnumerator];
	while (PhysicUserData *data = [itt nextObject]) {
		b2Body *body = (b2Body *) data.entity;
		_physicContext->destroyBody(body);
	}
	[_physics removeAllObjects];
	//[self releasePhysicAndDestroy:YES];
	[_batchNode release];
	[super dealloc];
}

- (void) onEnter{
	CCNode *node;
	if (!_useSheet) {
		NSEnumerator *it = [_segments objectEnumerator];
		while((node = [it nextObject])){
			[self.parent addChild:node];
		}

	}else {
		[self.parent addChild:_batchNode];
	}
	
	NSEnumerator *itt = [_physics objectEnumerator];
	while (PhysicUserData *data = [itt nextObject]) {
		b2Body *body = (b2Body *) data.entity;
		body->SetActive(YES);
	}
}

- (void) onExit{
	CCNode *node;
	if (!_useSheet) {
		NSEnumerator *it = [_segments objectEnumerator];
		while((node = [it nextObject])){
			[node removeFromParentAndCleanup:YES];
		}

	}else {
		[_batchNode removeFromParentAndCleanup:YES];
	}

	NSEnumerator *itt = [_physics objectEnumerator];
	while (PhysicUserData *data = [itt nextObject]) {
		b2Body *body = (b2Body *) data.entity;
		body->SetActive(NO);
	}
}

- (CGPoint) position{
	return MTP_POINT(head->GetPosition());
}

- (void) setPosition:(CGPoint)pos {
	CGPoint pp = self.position;
	pp = ccpSub(pos, pp); //Offset
	
	NSEnumerator *it = [_physics objectEnumerator];
	while (PhysicUserData *data = [it nextObject]) {
		b2Body *body = (b2Body *) data.entity;
		b2Vec2 newpos = body->GetPosition() + b2Vec2(PTM_VALUE(pp.x),PTM_VALUE(pp.y));
		body->SetTransform(newpos,body->GetAngle());
	}
}

- (b2Body *) getSegment:(int) tag{
	PhysicUserData *data = [_physics objectForKey:[NSString stringWithFormat:@"%d",tag]];
	return (b2Body *) data.entity;
}

#pragma mark PhysicContext
- (void) physicBodyChanged:(PhysicUserData *)data {
	CCNode *node;
	b2Body *body = (b2Body *) data.entity;
	node = [_segments objectForKey:data.key];
	
	node.position = MTP_POINT(ccp(body->GetWorldCenter().x,body->GetWorldCenter().y));// CGPointApplyAffineTransform(self.offset, [self bodyToWorldTransform]);
	node.rotation = -1 * CC_RADIANS_TO_DEGREES(body->GetAngle()) ;
}
@end
