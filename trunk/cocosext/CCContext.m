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

#import "CCContext.h"
#import "CCComponent.h"
#import "ContextDirector.h"

#define GET_GROUP(gid) ((gid >= CC_MAX_GROUPS || gid < 0) ? nil : (NSMutableArray *) _groups[gid])
#define CLAMP(x,y,z) MIN(MAX(x,y),z)

float ff(float dt){
	return dt * dt * (3 - 2 * dt);
	//return 33 * powf(dt, 5) - 106 * powf(dt, 4) + 126 * powf(dt , 3) - 67 * powf(dt , 2)+ 15 * dt;
	//return 56 * powf(dt, 5) - 105 * powf(dt, 4) + 60 * powf(dt , 3) - 10 * powf(dt , 2);
}

float cc_return(float dt){
	return 10 * dt - 10 * dt *dt;
}


@implementation CCContextScene
@synthesize layer = _layer;

- (id) init{
	self = [super init];
	_layer = [CCLayer node];
	_layer.isTouchEnabled = NO;
	_layer.anchorPoint = ccp(0,0);
	[self addChild:_layer];
	
	return self;
}
@end

@interface CCContext(Private)
- (void) _do_clean_up_;
- (void) _do_scroll_:(ccTime) dt;
- (void) _do_clean_group_:(int) gid;
@end

@implementation CCContext(Private)

- (void) _do_clean_up_{
	for (NSString *name in _autoreleaseTextures) {
		[[CCTextureCache sharedTextureCache] removeTextureForKey:name];
	}
	
	for (NSString *name in _autoreleaseSpriteFrames) {
		[[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFramesFromFile:name];
	}
}

- (void) _do_clean_group_:(int) gid{
	NSMutableArray *group = GET_GROUP(gid);
	if (group) {
		NSEnumerator *it = [group objectEnumerator];
		while (CCNode *node = [it nextObject]) {
			if (node.parent == nil) {
				//CCLOG(@"Group %d: found %@",gid,node);
				[group removeObject:node];
			}
		}
	}
}

- (void) _do_scroll_:(ccTime) dt{
	if (_scrollFlag == SCROLL_FLAG_FOLLOW) {
		float scale = _layer.scale;
		CGPoint pos = ccpSub(_center, ccpMult(_followedNode.position, scale));

		switch (_followFlag) {
			case FOLLOW_FLAG_BY_X:
				[_layer setPosition:ccp(CLAMP(pos.x,_bL,_bR),_layer.position.y)];
				break;

			case FOLLOW_FLAG_BY_Y:
				[_layer setPosition:ccp(_layer.position.x,CLAMP(pos.y,_bB,_bT))];
				break;

			case FOLLOW_FLAG_BY_XY:
				[_layer setPosition:ccp(CLAMP(pos.x,_bL,_bR),CLAMP(pos.y,_bB,_bT))];
				break;
		}
	}
	
	if (_scrollFlag == SCROLL_FLAG_BOUNCE) {
		_bounceTimeEllapsed += dt ;
		if (_bounceTimeEllapsed >= _bounceTime) {
			_scrollFlag = SCROLL_FLAG_NONE;
			_bounceTimeEllapsed = _bounceTime;
		}
		
		float dx = _bounceF(_bounceTimeEllapsed / _bounceTime );
		CGPoint pos = ccp(_bounceSrc.x + _bounceDelta.x * dx, _bounceSrc.y + _bounceDelta.y * dx);
		_layer.position = pos;
		if (pos.x < _bL || pos.x > _bR || pos.y < _bB || pos.y > _bT) {
			//_scrollFlag = SCROLL_FLAG_NONE;
		}
	}
}

@end


@implementation CCContext
@synthesize interestedStateChanges = _interestedStateChanges;
@synthesize interestShakeEvent = _interestShakeEvent;
@synthesize minScale = _minScale;
@synthesize maxScale = _maxScale;

#if PHYSIC_ENABLED
@synthesize physicContext = _physicContext;
@synthesize timeStep = _timeStep;
@synthesize useFixedTimeStep = _useFixedTimeStep;
@synthesize drawDebugData = _drawDebugData;
#endif

- (id) init{
	self = [super init];
	_autoreleaseTextures = [[NSMutableSet alloc] init];
	_autoreleaseSpriteFrames = [[NSMutableSet alloc] init];
	
	self.boundary = CGRectMake(0, 0, 480, 320);
	_maxScale = 1;
	
	for (int i = 0; i < CC_MAX_GROUPS; i++) {
		_groups[i] = nil;
	}
	_groups[CC_DEFAULT_GROUP] = [[NSMutableArray alloc] init];
	_tickCounter = 0;
	_scrollFlag = SCROLL_FLAG_NONE;
	
	_contactListeners = [[NSMutableDictionary alloc] init];
	_targetedContactListeners = [[NSMutableDictionary alloc] init];
	
#if PHYSIC_ENABLED
	_physicContext = new PhysicContext();
	_toDestroyed = [[CCArray alloc] init];
	_toReleased = [[CCArray alloc] init];
	_debugDraw = NULL;
#endif

	return self;
}

-(void) draw{
#if PHYSIC_ENABLED
	if (_drawDebugData) {
		glPushMatrix();
		glDisable(GL_TEXTURE_2D);
		glDisableClientState(GL_COLOR_ARRAY);
		glDisableClientState(GL_TEXTURE_COORD_ARRAY);
		
		glTranslatef(_layer.position.x, _layer.position.y, 0);
		glScalef(_layer.scaleX, _layer.scaleY, 1);
		
		_physicContext->getWorld()->DrawDebugData();
		
		
		glEnable(GL_TEXTURE_2D);
		glEnableClientState(GL_COLOR_ARRAY);
		glEnableClientState(GL_TEXTURE_COORD_ARRAY);
		glPopMatrix();
	}
#endif
}

+ (id) context{
	return [[[self alloc] init] autorelease];
}

- (void) dealloc{
	[self _do_clean_up_];
	[_autoreleaseTextures release];
	[_autoreleaseSpriteFrames release];
	[_contactListeners release];
	[_targetedContactListeners release];
	
	for (int i = 0; i < CC_MAX_GROUPS; i++) {
		NSMutableArray *group = GET_GROUP(i);
		if (group) {
			//CCLOG(@"g[%d]=%d",i,[group count]);
			[group release];
		}
	}
	
#if PHYSIC_ENABLED
	[_toDestroyed release];
	[_toReleased release];
	
	if (_debugDraw != NULL) {
		delete _debugDraw;
	}
	delete _physicContext;
#endif
	
	[super dealloc];
}

- (void) onEnter{
	if (_isTouchEnabled) {
		[self registerWithTouchDispatcher];
	}
	if (_interestShakeEvent) {
		[AppNotification addObserver:self selector:@selector(deviceShaked) name:kAppNotificationShakeEvent object:nil];
	}
	if (_isAccelerometerEnabled) {
		[self registerWithAccelerometer];
	}
	[self registerAppStateChangeObserver];
	[self schedule:@selector(tick:)];
	
	[super onEnter];	
}

- (void) onExit{
	if(_isTouchEnabled )
		[[CCTouchDispatcher sharedDispatcher] removeDelegate:self];
	
	if(_isAccelerometerEnabled)
		[[UIAccelerometer sharedAccelerometer] setDelegate:nil];
	
	[AppNotification removeObserver:self name:kAppNotificationShakeEvent object:nil];
	
	[self unscheduleAllSelectors];
	[self unregisterAppStateChangeObserver];
	
	[super onExit];
}

- (void) tick:(ccTime) dt{
	_tickCounter = ++_tickCounter % 60;
	
	if (_scrollFlag != SCROLL_FLAG_NONE) {
		[self _do_scroll_:dt];
	}
	[self resolveContacts];
	[self _do_clean_group_: _tickCounter % CC_MAX_GROUPS];
}
#pragma mark Contact Listener
- (void) resolveContacts{
	NSEnumerator *it = [_contactListeners keyEnumerator];
	while (NSNumber *key = [it nextObject]) {
		int gg = [key longLongValue];
		[self resolveContactsBetweenGroup:_16_UPPER_BITS(gg) andGroup:_16_LOWER_BITS(gg)];
	}
	
	it = [_targetedContactListeners keyEnumerator];
	CCNode *node;
	while (NSNumber *key = [it nextObject]) {
		long long gg = [key longLongValue];
		NSInvocation *iv = [_targetedContactListeners objectForKey:key];
		[iv getArgument:&node atIndex:2];	
		[self resolveContactsBetweenNode:node group:_32_LOWER_BITS(gg)];
	}
	
}

- (void) resolveContactsBetweenGroup:(int) g1 andGroup:(int) g2{
	NSArray *gs1 = [self getAllActors:g1];
	NSArray *gs2 = [self getAllActors:g2];
	int c1 = [gs1 count];
	int c2 = [gs2 count];
	NSInvocation *invocation = [_contactListeners objectForKey:[NSNumber numberWithLongLong:SIMPLE_HASH(g1,g2)]];
	
	CCNode *n1, *n2;
	for (int i = 0; i < c1; i++) {
		n1 = [gs1 objectAtIndex:i];
		
		for (int j = (g1 != g2 ? 0 : i + 1); j < c2; j++) {
			n2 = [gs2 objectAtIndex:j];
			
			if ([n1 isCollideWithNode:n2]) {
				[invocation setArgument:&n1 atIndex:2];
				[invocation setArgument:&n2 atIndex:3];
				[invocation invoke];
			}
		}
	}
}

- (void) addContactListenerBetweenGroup:(int) g1 
							   andGroup:(int) g2 
								 target:(id) target 
							   selector:(SEL) selector{
	
	NSNumber *key = [NSNumber numberWithLongLong:SIMPLE_HASH(g1,g2)];
	NSMethodSignature *sig = [target methodSignatureForSelector:selector];
	NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:sig];
	[invocation setTarget:target];
	[invocation setSelector:selector];
	[_contactListeners setObject:invocation forKey:key];
}

- (void) removeContactListenerBetweenGroup:(int) g1 andGroup:(int) g2{
	NSNumber *key = [NSNumber numberWithLongLong:SIMPLE_HASH(g1,g2)];
	[_contactListeners removeObjectForKey:key];
}

- (void) addContactListenerBetweenActor:(CCNode *) node andGroup:(int) gid target:(id) target selector:(SEL) selector{
	NSNumber *key = [NSNumber numberWithLongLong:SIMPLE_HASH64((int)[node hash],gid)];
	NSMethodSignature *sig = [target methodSignatureForSelector:selector];
	NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:sig];
	[invocation setTarget:target];
	[invocation setSelector:selector];
	[invocation setArgument:&node atIndex:2];
	[_targetedContactListeners setObject:invocation forKey:key];
}

- (void) removeContactListenerBetweenActor:(int) node andGroup:(int) gid{
	NSNumber *key = [NSNumber numberWithLongLong:SIMPLE_HASH64((int)[node hash],gid)];
	[_targetedContactListeners removeObjectForKey:key];
}

- (void) resolveContactsBetweenNode:(CCNode *) node group:(int) gid{
	NSArray *actors = [self getAllActors:gid];
	NSNumber *key = [NSNumber numberWithLongLong:SIMPLE_HASH64((int)[node hash],gid)];
	NSInvocation *invocation = [_targetedContactListeners objectForKey:key];
	
	for (CCNode *actor in actors) {
		if ([actor isCollideWithNode:node]) {
			[invocation setArgument:&actor atIndex:3];
			[invocation invoke];
		}
	}
}

#pragma mark Scaling, Scrolling
- (void) setBoundary:(CGRect) boundary{
	CGSize size = [[CCDirector sharedDirector] winSize];
	_center = ccp(size.width/2,size.height/2);
	_boundary = boundary;
	_bL = -(_boundary.size.width - size.width);						//Min value of _layer.position.x
	_bR = 0;		//Max value of _layer.position.x
	_bT = 0;		//Max value of _layer.position.y
	_bB = -(_boundary.size.height - size.height);						//Min value of _layer.position.y
	
	_minScale = MAX(size.width/_boundary.size.width,size.height/_boundary.size.height);
}

- (CGRect) boundary{
	return _boundary;
}

- (void) follow:(CCNode *) node{
	//NSAssert(node.parent == _layer,@"Cannot follow object of other layer ");
	_followedNode = node;
	_followFlag = FOLLOW_FLAG_BY_XY;
	_scrollFlag = SCROLL_FLAG_FOLLOW ;
}

- (void) followByX:(CCNode *) node{
	//NSAssert(node.parent == _layer,@"Cannot follow object of other layer ");
	_followedNode = node;
	_followFlag = FOLLOW_FLAG_BY_X;
	_scrollFlag = SCROLL_FLAG_FOLLOW;
}

- (void) followByY:(CCNode *) node{
	//NSAssert(node.parent == _layer,@"Cannot follow object of other layer ");
	_followedNode = node;
	_followFlag = FOLLOW_FLAG_BY_Y;
	_scrollFlag = SCROLL_FLAG_FOLLOW;
}

- (void) unfollow{
	_followedNode = nil;
	_scrollFlag = SCROLL_FLAG_NONE;
}

- (void) scale:(float) scale{
	if (scale >= _minScale && scale <= _maxScale) {
		_layer.scale = scale;	
		
		CGSize size = [[CCDirector sharedDirector] winSize];
		_bL = -(_boundary.size.width*scale - size.width);						//Min value of _layer.position.x
		_bB = -(_boundary.size.height*scale - size.height);
	}
}

- (void) bounceTo:(CGPoint) pos duration:(float) duration withFunction:(EaseFunction) block{
	_scrollFlag = SCROLL_FLAG_BOUNCE;
	_bounceTimeEllapsed = 0;
	_bounceSrc = _layer.position;
	_bounceDelta = ccpSub(pos, _bounceSrc);
	_bounceTime = duration;
	_bounceF = block;
}

- (void) bounceBy:(CGPoint) pos duration:(float) duration withFunction:(EaseFunction) block{
	_scrollFlag = SCROLL_FLAG_BOUNCE;
	_bounceTimeEllapsed = 0;
	_bounceSrc = _layer.position;
	_bounceDelta = pos;
	_bounceTime = duration;
	_bounceF = block;
}

#pragma mark Sprite batch node
- (void) addBatchNode:(CCSpriteBatchNode *) node{
	[_layer addChild:node];
}

- (void) addActor:(CCSprite *)actor batch:(CCSpriteBatchNode *) node group:(int) gid{
	[node addChild:actor];
	NSMutableArray *groups = GET_GROUP(gid);
	[groups addObject:actor];
	if ([actor isKindOfClass:[CCComponent class]]) {
		[(CCComponent *) actor setContext:self];
	}
}

- (void) addActor:(CCSprite *)actor batch:(CCSpriteBatchNode *) node{
	[self addActor:actor batch:node group:CC_DEFAULT_GROUP];
}

#pragma mark Memory management
- (void) addAutoreleaseTexture:(NSString *) name{
	[_autoreleaseTextures addObject:name];
	[[CCTextureCache sharedTextureCache] addImage:name];
}

- (void) addAutoreleaseSpriteFrame:(NSString *) plist{
	[_autoreleaseSpriteFrames addObject:plist];
	[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:plist];
}

#pragma mark Scheduler
- (void) unscheduleAllSelectors{
	[[CCScheduler sharedScheduler] unscheduleAllSelectorsForTarget:self];
}

- (void) pauseScheduler{
	[[CCScheduler sharedScheduler] pauseTarget:self];
}

- (void) resumeScheduler{
	[[CCScheduler sharedScheduler] resumeTarget:self];
}

#pragma mark Funny
- (void) freezeAllChilden{
	[_layer.children makeObjectsPerformSelector:@selector(pauseSchedulerAndActions)];
}

- (void) unFreezeAllChilden{
	[_layer.children makeObjectsPerformSelector:@selector(resumeSchedulerAndActions)];
}

- (void) freezeAllChildenInGroup:(int) gid{
	NSArray *actors = [self getAllActors:gid];
	[actors makeObjectsPerformSelector:@selector(pauseSchedulerAndActions)];
}

- (void) unFreezeAllChildenInGroup:(int) gid{
	NSArray *actors = [self getAllActors:gid];
	[actors makeObjectsPerformSelector:@selector(resumeSchedulerAndActions)];
}

- (void) moveNode:(CCNode *)node byTouch:(UITouch *)touch{
	CGPoint c = [[CCDirector sharedDirector] convertToGL:[touch locationInView:touch.view]];
	CGPoint l = [[CCDirector sharedDirector] convertToGL:[touch previousLocationInView:touch.view]];
	node.position = ccpAdd(node.position, ccpSub(c, l));
}

#pragma mark Actors
- (void) addActor:(CCNode *) actor z:(int) z tag:(int) tag{
	[self addActor:actor group:CC_DEFAULT_GROUP z:z tag:tag];
}

- (void) addActor:(CCNode *) actor z:(int) z{
	[self addActor:actor z:z tag:actor.tag];
}

- (void) addActor:(CCNode *) actor{
	[self addActor:actor z:actor.zOrder tag:actor.tag];
}

- (void) removeActor:(CCNode *) actor cleanup:(BOOL) cleanup{
	[self removeActor:actor group:CC_DEFAULT_GROUP cleanup:cleanup];
}

- (void) removeActor:(CCNode *) actor{
	[self removeActor:actor cleanup:YES];
}

- (void) removeAllActorsByTag:(int) tag cleanup:(BOOL) cleanup{
	[self removeAllActorsByTag:tag group:CC_DEFAULT_GROUP cleanup:cleanup];
}

- (void) removeAllActorsByTag:(int) tag{
	[self removeAllActorsByTag:tag cleanup:YES];
}

- (void) removeActorByTag:(int) tag cleanup:(BOOL) cleanup{
	[self removeActorByTag:tag group:CC_DEFAULT_GROUP cleanup:cleanup];
}

- (void) removeActorByTag:(int) tag{
	[self removeActorByTag:tag cleanup:YES];
}

- (CCNode *) getActorByTag:(int) tag{
	return [self getActorByTag:tag group:CC_DEFAULT_GROUP];
}

- (NSArray *) allActorByTag:(int) tag{
	return [self allActorByTag:tag group:CC_DEFAULT_GROUP];
}

- (CCNode *) getActorAtPoint:(CGPoint) pos{
	return [self getActorAtPoint:pos group:CC_DEFAULT_GROUP];
}

#pragma mark Actors Group
- (void) addGroup:(int) gid{
	if (gid > 0 && gid < CC_MAX_GROUPS && GET_GROUP(gid) == nil) {
		_groups[gid] = [[NSMutableArray alloc] init];
	}
}

- (void) emptyGroup:(int) gid{
	NSMutableArray *group = GET_GROUP(gid);
	[group makeObjectsPerformSelector:@selector(removeFromParentAndCleanup:) withObject:[NSNumber numberWithBool:YES]];
	[group removeAllObjects];
}

- (int) actorCount:(int) gid{
	return [GET_GROUP(gid) count];
}

- (NSArray *) getAllActors:(int) gid{
	return GET_GROUP(gid);
}

- (void) addActor:(CCNode *) actor group:(int)gid z:(int) z tag:(int) tag{
	NSMutableArray *group = GET_GROUP(gid);
	[group addObject:actor];
	[self addChild:actor z:z tag:tag];
}

- (void) addActor:(CCNode *) actor group:(int)gid z:(int) z{
	[self addActor:actor group:gid z:z tag:actor.tag];
}

- (void) addActor:(CCNode *) actor group:(int)gid{
	[self addActor:actor group:gid z:actor.zOrder tag:actor.tag];
}

- (void) removeActor:(CCNode *) actor group:(int)gid cleanup:(BOOL) cleanup{
	NSMutableArray *group = GET_GROUP(gid);
	[group removeObject:actor];
	[actor removeFromParentAndCleanup:cleanup];
}

- (void) removeFromGroup:(int)gid actor:(CCNode *) actor{
	NSMutableArray *group = GET_GROUP(gid);
	[group removeObject:actor];
}

- (void) removeActor:(CCNode *) actor group:(int)gid{
	[self removeActor:actor group:gid cleanup:YES];
}

- (void) removeAllActorsByTag:(int) tag group:(int)gid cleanup:(BOOL) cleanup{
	NSMutableArray *group = GET_GROUP(gid);
	NSEnumerator *it = [group objectEnumerator];
	while (CCNode *actor = [it nextObject]) {
		if (actor.tag == tag) {
			[actor removeFromParentAndCleanup:cleanup];
		}
	}
}

- (void) removeAllActorsByTag:(int) tag group:(int)gid{
	[self removeAllActorsByTag:tag cleanup:YES];
}

- (void) removeActorByTag:(int) tag group:(int)gid cleanup:(BOOL) cleanup{
	NSMutableArray *group = GET_GROUP(gid);
	NSEnumerator *it = [group objectEnumerator];
	while (CCNode *actor = [it nextObject]) {
		if (actor.tag == tag) {
			[actor removeFromParentAndCleanup:cleanup];
			break;
		}
	}
}

- (void) removeActorByTag:(int) tag group:(int)gid{
	[self removeActorByTag:tag cleanup:YES];
}

- (CCNode *) getActorByTag:(int) tag group:(int)gid{
	NSMutableArray *group = GET_GROUP(gid);
	for (CCNode *actor in group) {
		if (actor.tag == tag) {
			return actor;
		}
	}
	
	return nil;
}

- (NSArray *) allActorByTag:(int) tag group:(int)gid{
	NSMutableArray *array = [NSMutableArray array];
	NSMutableArray *group = GET_GROUP(gid);
	for (CCNode *actor in group) {
		if (actor.tag == tag) {
			[array addObject:actor];
		}
	}
	
	return array;
}

- (CCNode *) getActorAtPoint:(CGPoint) pos group:(int)gid{
	NSMutableArray *group = GET_GROUP(gid);
	for (CCNode *actor in group) {
		if ([actor containsPoint:pos]) {
			return actor;
		}
	}
	
	return nil;
}

#pragma mark Manage Children - Layer port
- (void) addChild:(CCNode *)node z:(int) z tag:(int) tag{
	if ([node isKindOfClass:[CCLayer class]]) {
		[super addChild:node z:z tag:tag];
	}  else{
		[self->_layer addChild:node z:z tag:tag];
	}
	
	if ([node isKindOfClass:[CCComponent class]]) {
		[(CCComponent *) node setContext:self];
	}
}

- (void) removeChild:(CCNode *)node cleanup:(BOOL)cleanup{
	if ([node isKindOfClass:[CCLayer class]]) {
		[super removeChild:node cleanup:NO];
	} else  {
		if ([node isKindOfClass:[CCSpriteBatchNode class]]) {
			[node removeAllChildrenWithCleanup:NO];
		}
		[_layer removeChild:node cleanup:cleanup];
	}
}

- (void) removeChild:(CCNode *)node{
	[self removeChild:node cleanup:NO];
}

- (CCNode *) getChildByTag:(int) tag{
	return [_layer getChildByTag:tag];
}

- (void) removeChildByTag:(int)tag cleanup:(BOOL)cleanup{
	[_layer removeChildByTag:tag cleanup:cleanup];
}


#pragma mark Query components
- (NSArray *) allChildsByTag:(int) tag{
	NSMutableArray *nodes = [NSMutableArray array];
	CCNode *node;
	CCARRAY_FOREACH(_layer.children, node){
		if (node.tag == tag) {
			[nodes addObject:node];
		}
	}
	return nodes;
}

- (CCNode *) getChildAtPoint:(CGPoint) pos{
	CCNode *node;
	CCARRAY_FOREACH(_layer.children, node){
		if ([node containsPoint:pos]) {
			return node;
		}
	}
	return nil;
}

- (CCLayer *) getLayerByTag:(int) tag{
	return (CCLayer *)[self getChildByTag:tag];
}
#pragma mark App state change
- (void) registerAppStateChangeObserver{
	NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
	if (_interestedStateChanges & kAppStateWillResignActive) {
		[center addObserver: self
				   selector: @selector(applicationWillResignActive:)
					   name: UIApplicationWillResignActiveNotification
					 object:nil];
	} 
	
	if (_interestedStateChanges & kAppStateWillEnterForeGround) {
		[center addObserver:self 
				   selector:@selector(applicationWillEnterForeground:) 
					   name:UIApplicationWillEnterForegroundNotification
					 object:nil];
	}
	
	if (_interestedStateChanges & kAppStateWillterminate) {
		[center addObserver:self 
				   selector:@selector(applicationWillTerminate:) 
					   name:UIApplicationWillTerminateNotification 
					 object:nil];
	}
	
	if (_interestedStateChanges & kAppStateDidBecomeActive) {
		[center addObserver:self 
				   selector:@selector(applicationDidBecomeActive:) 
					   name:UIApplicationDidBecomeActiveNotification
					 object:nil];
	}
	if (_interestedStateChanges & kAppStateDidEnterBackground) {
		[center addObserver:self 
				   selector:@selector(applicationDidEnterBackground:) 
					   name:UIApplicationDidEnterBackgroundNotification
					 object:nil];
	}
	
	if (_interestedStateChanges & kAppStateDidReceiveMemoryWarnig) {
		[center addObserver:self 
				   selector:@selector(applicationDidReceiveMemoryWarning:) 
					   name:UIApplicationDidReceiveMemoryWarningNotification
					 object:nil];
	}
	
}

- (void) unregisterAppStateChangeObserver{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) deviceShaked{
	
}

- (void) applicationWillResignActive:(NSNotification *) notification{}
- (void) applicationDidBecomeActive:(NSNotification *) notification{}
- (void) applicationDidReceiveMemoryWarning:(NSNotification *) notification{}
- (void) applicationDidEnterBackground:(NSNotification *) notification{}
- (void) applicationWillEnterForeground:(NSNotification *) notification{}
- (void) applicationWillTerminate:(NSNotification *) notification{}

#pragma mark Layer - Touch and Accelerometer related

- (void) registerWithTouchDispatcher
{
	[[CCTouchDispatcher sharedDispatcher] addStandardDelegate:self priority:0];
}

- (void) registerWithAccelerometer{
	[[UIAccelerometer sharedAccelerometer] setDelegate:self];
}

-(BOOL) isAccelerometerEnabled
{
	return _isAccelerometerEnabled;
}

-(void) setIsAccelerometerEnabled:(BOOL)enabled
{
	if( enabled != _isAccelerometerEnabled ) {
		_isAccelerometerEnabled = enabled;
		if( enabled )
			[[UIAccelerometer sharedAccelerometer] setDelegate:self];
		else
			[[UIAccelerometer sharedAccelerometer] setDelegate:nil];
	}
}

-(BOOL) isTouchEnabled
{
	return _isTouchEnabled;
}

-(void) setIsTouchEnabled:(BOOL)enabled
{
	if( _isTouchEnabled != enabled ) {
		_isTouchEnabled = enabled;
		if( enabled )
			[self registerWithTouchDispatcher];
		else
			[[CCTouchDispatcher sharedDispatcher] removeDelegate:self];
	}
}

#pragma mark Touch Helper
- (CGPoint) pointForTouches:(NSSet *) touches{
	return [self pointForTouch:[touches anyObject]];
}

- (CGPoint) pointForTouch:(UITouch *) touch{
	return [self->_layer convertToNodeSpace:[[CCDirector sharedDirector] convertToGL:[touch locationInView:touch.view]]];
}

- (CGPoint) previousPointForTouches:(NSSet *) touches{
	return [self previousPointForTouch:[touches anyObject]];
}

- (CGPoint) previousPointForTouch:(UITouch *) touch{
	return [self->_layer convertToNodeSpace:[[CCDirector sharedDirector] convertToGL:[touch previousLocationInView:touch.view]]];
}

#pragma mark Gesture Recognizer
- (void) addGestureRecognizer:(UIGestureRecognizer *) recognizer action:(SEL) selector{
	UIViewController *vc = [[Global appDelegate] rootViewController];
	[recognizer addTarget:self action:selector];
	[vc.view addGestureRecognizer:recognizer];
}

- (void) removeGestureRecognizer:(UIGestureRecognizer *) recognizer{
	UIViewController *vc = [[Global appDelegate] rootViewController];
	[vc.view removeGestureRecognizer:recognizer];	
}

#pragma mark Physic
#if PHYSIC_ENABLED
- (void) step:(ccTime) dt{
	if (_useFixedTimeStep) {
		_physicContext->step(_timeStep);
	}else {
		_physicContext->step(dt);
	}
	
	//Remove components marked as destroyed
	CCComponent *node;
	CCARRAY_FOREACH(_toDestroyed, node){
		[node removeFromParentAndCleanup:YES];
	}
	[_toDestroyed removeAllObjects];
	
	//Remove physic from components
	CCARRAY_FOREACH(_toReleased, node){
		[node releasePhysicAndDestroy:YES];
	}
	[_toReleased removeAllObjects];
}

- (void) setDebugDraw:(BOOL) onOrOff flag:(int) flags{
	if (onOrOff) {
		_drawDebugData = YES;
		if (_debugDraw == NULL) {
			_debugDraw = new GLESDebugDraw(PTM_RATIO);
		}
		_debugDraw->SetFlags(flags);
		_physicContext->getWorld()->SetDebugDraw(_debugDraw);		
	}else {
		_drawDebugData = NO;
	}	
}

- (void) toDestroyed:(CCComponent *) node{
	[_toDestroyed addObject:node];
}

- (void) toReleased:(CCComponent *) node{
	[_toReleased addObject:node];
}

- (b2MouseJoint *) createMouseJoint:(b2Body *) body staticBody:(b2Body *) staticBody position:(CGPoint) position{
	b2MouseJointDef def;
	def.bodyA = staticBody;
	def.bodyB = body;
	def.dampingRatio = 1.0;
	def.target = PTM_POINT(position);
	//def.frequencyHz = 1./30;
	def.maxForce = 1000.0f * def.bodyB->GetMass();
	return  (b2MouseJoint *) _physicContext->createJoint(&def);
}

- (CCComponent *) queryComponentAtPoint:(CGPoint) position{
	b2Vec2 p = PTM_POINT(position);
	b2Fixture *fixture = _physicContext->query(p);
	if (fixture != NULL) {
		PhysicUserData *data = nil;
		if (fixture->GetUserData() != NULL) {
			data = (PhysicUserData *) fixture->GetUserData();
		}else if (fixture->GetBody()->GetUserData() != NULL) {
			data = (PhysicUserData *) fixture->GetBody()->GetUserData();
		}
		
		if (data) {
			if ([data.key isEqualToString:@"self"]) {
				return (CCComponent *)data.component;
			}
			return [(CCComponent *)data.component componentByKeyRecursive:data.key];
		}
		
		return nil;
	}
	return nil;
}

- (b2Body *) queryBodyAtPoint:(CGPoint) position{
	b2Vec2 p = PTM_POINT(position);
	b2Fixture *fixture = _physicContext->query(p);
	if (fixture != NULL) {
		return fixture->GetBody();
	}
	return NULL;
}

- (CCComponent *) queryComponentAtTouch:(UITouch *) touch{
	return [self queryComponentAtPoint:UIToGL([touch locationInView:touch.view])];
}

// Create physic
- (b2Body *) addCircleAt:(CGPoint) pos 
				  radius:(float) radius 
				 bodyDef:(b2BodyDef *) bdef 
			  fixtureDef:(b2FixtureDef *) fdef{
	bdef->position = PTM_POINT(pos);
	b2CircleShape shape;
	shape.m_radius = PTM_VALUE(radius);
	fdef->shape = &shape;
	b2Body *body = _physicContext->createBody(bdef);
	body->CreateFixture(fdef);
	
	return body;
}

- (b2Body *) addRectangleAt:(CGPoint) pos 
					  width:(float) width 
					 height:(float) height 
					  angle:(float) angle
					bodyDef:(b2BodyDef *) bdef 
				 fixtureDef:(b2FixtureDef *) fdef{
	bdef->position = PTM_POINT(pos);
	b2PolygonShape shape;
	shape.SetAsBox(PTM_VALUE(width/2), PTM_VALUE(height/2), b2Vec2(0,0), CC_DEGREES_TO_RADIANS(angle));
	fdef->shape = &shape;
	b2Body *body = _physicContext->createBody(bdef);
	body->CreateFixture(fdef);
	
	return body;
}

- (b2Body *) addStaticEdgeFrom:(CGPoint) from 
							to:(CGPoint) to 
					fixtureDef:(b2FixtureDef *) fdef{
	b2BodyDef bdef;
	b2PolygonShape shape;
	CGPoint center = ccpMult(ccpAdd(from, to), 0.5);
	float w = ccpDistance(from, to);
	float h = 5.;
	float angle = [CCNode degree:ccpSub(to, from)];
	angle = CC_DEGREES_TO_RADIANS(angle);
	
	shape.SetAsBox(PTM_VALUE(w/2), PTM_VALUE(h/2), PTM_POINT(center), angle);
	
	fdef->shape = &shape;
	b2Body *body = _physicContext->createBody(&bdef);
	body->CreateFixture(fdef);
	
	return body;
}


- (b2Fixture *) addCircleTo:(b2Body *) body 
				   position:(CGPoint) pos 
					 radius:(float) radius 
				 fixtureDef:(b2FixtureDef *) fdef{
	b2CircleShape shape;
	shape.m_p = PTM_POINT(pos);
	shape.m_radius = PTM_VALUE(radius);
	fdef->shape = &shape;
	
	return body->CreateFixture(fdef);
}

- (b2Fixture *) addRectangleTo:(b2Body *) body 
					  position:(CGPoint) pos 
						 width:(float) width 
						height:(float) height
						 angle:(float) angle
					fixtureDef:(b2FixtureDef *) fdef{
	b2PolygonShape shape;
	shape.SetAsBox(PTM_VALUE(width/2), PTM_VALUE(height/2), PTM_POINT(pos), CC_DEGREES_TO_RADIANS(angle));
	fdef->shape = &shape;
	
	return body->CreateFixture(fdef);
}

- (b2Fixture *) addEdgeTo:(b2Body *) body 
					 from:(CGPoint) from 
					   to:(CGPoint) to 
			   fixtureDef:(b2FixtureDef *) fdef{
/*
	b2PolygonShape shape;
	shape.SetAsEdge(PTM_POINT(from), PTM_POINT(to));
	fdef->shape = &shape;
	
	return body->CreateFixture(fdef);
 */
}

- (b2Fixture *) addPolyTo:(b2Body *) body 
					 poly:(b2PolygonShape *) shape 
			   fixtureDef:(b2FixtureDef *) fdef{
	fdef->shape = shape;
	
	return body->CreateFixture(fdef);
}


// Create physic and bind to component
- (b2Body *) addCircleComponent:(CCComponent *) node 
					   position:(CGPoint) pos /* Position of the body */
						 offset:(CGPoint) offset /* Offset of the circle from body position */
						 radius:(float) radius 
						bodyDef:(b2BodyDef *) bdef 
					 fixtureDef:(b2FixtureDef *) fdef{
	NSAssert(node != nil, @"The node must not be nill");
	
	bdef->position = PTM_POINT(pos);
	b2CircleShape shape;
	shape.m_radius = PTM_VALUE(radius);
	shape.m_p = PTM_POINT(offset);
	fdef->shape = &shape;
	b2Body *body = _physicContext->createBody(bdef, node);
	body->CreateFixture(fdef);
	
	CGAffineTransform t = CGAffineTransformIdentity;
	t = CGAffineTransformScale(t, 1/node.scale, 1/node.scale);
	t = CGAffineTransformTranslate(t, -offset.x, -offset.y);
	
	node.bodyToNodeTransform = t;
	
	node.offset = offset;
	node.angle = 0;
	
	BOOL tmp = node.updatePhysic;
	node.updatePhysic = NO;
	[node updateFromPhysic];
	node.updatePhysic = tmp;

	if (node.parent == nil) {
		[self addActor:node];
	}
		
	return body;
}

- (b2Body *) addCircleComponent:(CCComponent *) node 
				   position:(CGPoint) pos 
					 radius:(float) radius 
					bodyDef:(b2BodyDef *) bdef 
				 fixtureDef:(b2FixtureDef *) fdef{
	
	return [self addCircleComponent:node 
						   position:pos 
							 offset:CGPointZero 
							 radius:radius 
							bodyDef:bdef 
						 fixtureDef:fdef];
}

- (b2Body *) addCircleComponent:(CCComponent *) node 
				   position:(CGPoint) pos 
					bodyDef:(b2BodyDef *) bdef 
				 fixtureDef:(b2FixtureDef *) fdef{
	
	float radius = (node.size.width + node.size.height) / 4;
	return [self addCircleComponent:node 
						   position:pos 
							 radius:radius 
							bodyDef:bdef 
						 fixtureDef:fdef];
}

- (b2Body *) addRectangleComponent:(CCComponent *) node 
						  position:(CGPoint) position 
							offset:(CGPoint) offset 
							 angle:(float) angle 
							  size:(CGSize) size 
						   bodyDef:(b2BodyDef *) bdef 
						fixtureDef:(b2FixtureDef *) fdef{
	
	NSAssert(node != nil, @"The node must not be nill");
	
	bdef->position = PTM_POINT(position);
	bdef->angle = 0;
	
	b2PolygonShape shape;
	shape.SetAsBox(PTM_VALUE(size.width/2), PTM_VALUE(size.height/2), PTM_POINT(offset) , CC_DEGREES_TO_RADIANS(-angle));
	fdef->shape = &shape;
	
	b2Body *body = _physicContext->createBody(bdef,node);
	body->CreateFixture(fdef);
	
	node.offset = offset;
	node.angle = angle;
	
	CGAffineTransform t = CGAffineTransformIdentity;
	t = CGAffineTransformScale(t, 1/node.scaleX, 1/node.scaleY);
	t = CGAffineTransformRotate(t, CC_DEGREES_TO_RADIANS(angle));
	t = CGAffineTransformTranslate(t, -offset.x, -offset.y);
	
	node.bodyToNodeTransform = t;
	
	if (node.parent == nil) {
		[self addActor:node];
	}
	
	BOOL tmp = node.updatePhysic;
	node.updatePhysic = NO;
	[node updateFromPhysic];
	node.updatePhysic = tmp;
		
	return body;
}

- (b2Body *) addRectangleComponent:(CCComponent *) node 
						  position:(CGPoint) pos 
							offset:(CGPoint) offset 
							  size:(CGSize) size 
						   bodyDef:(b2BodyDef *) bdef 
						fixtureDef:(b2FixtureDef *) fdef{
	
	return [self addRectangleComponent: node 
							  position: pos 
								offset: offset 
								 angle: 0 
								  size: size 
							   bodyDef: bdef 
							fixtureDef: fdef];
}

- (b2Body *) addRectangleComponent:(CCComponent *) node 
					  position:(CGPoint) pos 
						  size:(CGSize) size 
					   bodyDef:(b2BodyDef *) bdef 
					fixtureDef:(b2FixtureDef *) fdef{
	
	return [self addRectangleComponent:node 
							  position:pos 
								offset:CGPointZero 
								 angle: 0
								  size:size 
							   bodyDef:bdef 
							fixtureDef:fdef];
}

- (b2Body *) addRectangleComponent:(CCComponent *) node 
					  position:(CGPoint) pos 
					   bodyDef:(b2BodyDef *) bdef 
					fixtureDef:(b2FixtureDef *) fdef{
	
	return [self addRectangleComponent:node 
							  position:pos 
								offset:CGPointZero 
								 angle: 0
								  size:node.size 
							   bodyDef:bdef 
							fixtureDef:fdef];
}

- (b2Fixture *) addCircleComponent:(CCComponent *) node 
						  toParent:(CCComponent *) parent 
						  position:(CGPoint) pos 
							radius:(float) radius 
						fixtureDef:(b2FixtureDef *) fdef
					registerPhysic:(BOOL) reg{
	
	NSAssert([parent body] != NULL && node != nil,@"Assertion fails");

	b2CircleShape shape;
	shape.m_radius = PTM_VALUE(radius);
	shape.m_p = PTM_POINT(pos);
	fdef->shape = &shape;
	
	node.position = CGPointApplyAffineTransform(pos, parent.bodyToNodeTransform);
	node.rotation = node.deltaAngle;
	
	node.scale = node.scale / parent.scale;
	
	[parent addComponent:node key:[node description]];
	
	b2Fixture *fixture = [parent body]->CreateFixture(fdef);
	
	if (reg) {
		_physicContext->setUserData(fixture, PHYSIC_FIXTURE, node,[node description]);
	}
	
	return fixture;
}

- (b2Fixture *) addCircleComponent:(CCComponent *) node 
						  toParent:(CCComponent *) parent 
						  position:(CGPoint) pos 
						fixtureDef:(b2FixtureDef *) fdef 
					registerPhysic:(BOOL) reg{
	
	float radius = (node.size.width + node.size.height) / 4;
	return [self addCircleComponent:node 
						   toParent:parent 
						   position:pos 
							 radius:radius 
						 fixtureDef:fdef 
					 registerPhysic:reg];
}

- (b2Fixture *) addRectangleComponent:(CCComponent *) node 
							 toParent:(CCComponent *) parent 
							 position:(CGPoint) pos 
								 size:(CGSize) size 
								angle:(float) angle 
						   fixtureDef:(b2FixtureDef *) fdef 
					   registerPhysic:(BOOL) reg{
	
	NSAssert([parent body] != NULL,@"");
	NSAssert(node != nil && node.parent == nil,@"");
	
	b2PolygonShape shape; 
	shape.SetAsBox(PTM_VALUE(size.width/2), PTM_VALUE(size.height/2), PTM_POINT(pos), CC_DEGREES_TO_RADIANS(-angle));
	fdef->shape = &shape;
	
	node.rotation = angle + node.deltaAngle - parent.rotation;
	node.position = CGPointApplyAffineTransform(pos, parent.bodyToNodeTransform);
	
	node.scale = node.scale / parent.scale;
	
	[parent addComponent:node key:[node description]];
	
	node.bodyToNodeTransform = CGAffineTransformConcat(parent.bodyToNodeTransform, [node parentToNodeTransform]);
	
	b2Fixture *fixture = [parent body]->CreateFixture(fdef);
	
	if (reg) {
		_physicContext->setUserData(fixture, PHYSIC_FIXTURE, node,[node description]);
	}
	
	return fixture;
}

- (b2Fixture *) addRectangleComponent:(CCComponent *) node 
							 toParent:(CCComponent *) parent 
							 position:(CGPoint) pos 
								angle:(float) angle 
						   fixtureDef:(b2FixtureDef *) fdef 
					   registerPhysic:(BOOL) reg{
	
	return [self addRectangleComponent:node 
							  toParent:parent 
							  position:pos 
								  size:node.size
								 angle:angle 
							fixtureDef:fdef 
						registerPhysic:reg];
}

#endif //of PHYSIC_ENABLED
@end