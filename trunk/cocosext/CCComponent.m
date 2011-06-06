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

#import "CCComponent.h"
#import "FileContentCache.h"
#import "CCContext.h"

#if PHYSIC_ENABLED
#import "PhysicUserData.h"
#endif

#if DEBUG_INSTANCES_COUNT
static int CCCOUNT = 0;
#endif


@interface CCComponent(Private)
- (void) loadChilds;
- (CGSize) _size;
- (void) _init_safe_:(NSString *) filename;
- (id) actionForState:(NSString *) state;
@end

@implementation CCComponent(Private)
- (CGSize) _size{
	return self.textureRect.size;
}

- (void) loadChilds{
	NSArray *keys = [[_def objectForKey:@"child"] allKeys];
	for (NSString *key in keys) {
		NSDictionary *cdef = [[_def objectForKey:@"child"] objectForKey:key];
		float x = [[cdef objectForKey:@"x"] floatValue];
		float y = [[cdef objectForKey:@"y"] floatValue];
		int z = [[cdef objectForKey:@"z"] intValue];
		int tag = [[cdef objectForKey:@"tag"] intValue];
		NSString *file = [cdef objectForKey:@"extern"];
		NSString *state_ = [cdef objectForKey:@"state"];
		
		CCComponent *child;
		if ([cdef objectForKey:@"class"]) {
			Class c = NSClassFromString([cdef objectForKey:@"class"]);
			child = [[c alloc] initWithFile:file];
		}
		else {
			child = [[CCComponent alloc] initWithFile:file];
		}
	
		child.position = ccp(x,y);
		child.tag = tag;
		
		[self addComponent:child key:key z:self.zOrder + z];
		
		
		if (state_ != nil) {
			[child setState:state_];
		}
		
		[child release];
	}
}

- (void) _init_safe_:(NSString *) filename{
	CCTexture2D *texture = [[CCTextureCache sharedTextureCache] addImage: filename];
	if( texture ) {
		CGRect rect = CGRectZero;
		rect.size = texture.contentSize;
		[self setTexture:texture];
		[self setTextureRect:rect];
	}
}

- (id) actionForState:(NSString *) state_{
	NSDictionary *actionDef = [[_def objectForKey:@"states"] objectForKey:state_];
	if (actionDef == nil) {
		return nil;
	}
	if (![actionDef objectForKey:@"animation"]) {
		return [actionDef objectForKey:@"sprite"];
	}
	actionDef = [actionDef objectForKey:@"animation"];
	NSString *type = [actionDef objectForKey:@"type"]; 
	if ([type isEqualToString:@"frame"]) {
		NSMutableArray *animFrames = [[NSMutableArray alloc] init];
		int startframe		= [[actionDef objectForKey:@"startframe"] intValue];		
		int endframe		= [[actionDef objectForKey:@"endframe"] intValue];
		float duration		= [[actionDef objectForKey:@"duration"] floatValue];
		BOOL restore		= [[actionDef objectForKey:@"restore"] boolValue];
		NSString *prefix	=  [actionDef objectForKey:@"key"];
		BOOL reverse		= [[actionDef objectForKey:@"reverse"] boolValue];
		BOOL forever		= [[actionDef objectForKey:@"forever"] boolValue];
		BOOL backward = endframe < startframe;
		for(int i = startframe; backward ? i >= endframe : i <= endframe;backward ? i-- : i++){
			[animFrames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"%@%d.png", prefix,i]]];
		}
		if (reverse) {
			int i = [animFrames count] -2;
			for(;i >= 0; i--){
				id obj = [animFrames objectAtIndex:i];
				[animFrames addObject:obj];
			}
		}
		CCAnimation *animation_ = [CCAnimation animationWithFrames:animFrames delay:duration];// [CCAnimation animationWithName:@"repeat" delay:duration frames:animFrames];
		CCAnimate *animate_ = [CCAnimate actionWithAnimation:animation_ restoreOriginalFrame:restore];
		[animFrames release];
		if (forever) {
			return [CCRepeatForever actionWithAction:animate_];
		}
		
		return animate_;
	}
	
	if([type isEqual:@"rotate"]) {
		Class class_ = NSClassFromString([actionDef objectForKey:@"class"]);
		if (class_ != [CCRotateBy class] && class_ != [CCRotateTo class]) {
			return nil;
		}
		
		float duration	= [[actionDef objectForKey:@"duration"] floatValue];
		float angle		= [[actionDef objectForKey:@"angle"] floatValue];
		BOOL forever	= [[actionDef objectForKey:@"forever"] boolValue];
		
		id action_		= [class_ actionWithDuration:duration angle:angle];
		
		if (forever) {
			return [CCRepeatForever actionWithAction:action_] ;
		}
		
		return action_;	
	}
	
	if([type isEqual:@"scale"]) {
		Class class_ = NSClassFromString([actionDef objectForKey:@"class"]);
		if (class_ != [CCScaleBy class] && class_ != [CCScaleTo class]) {
			return nil;
		}
		
		float duration	= [[actionDef objectForKey:@"duration"] floatValue];
		float scaleX	= [[actionDef objectForKey:@"scalex"] floatValue];
		float scaleY	= [[actionDef objectForKey:@"scaley"] floatValue];
		float scale		= [[actionDef objectForKey:@"scale"] floatValue];
		BOOL forever	= [[actionDef objectForKey:@"forever"] boolValue];
		
		scaleX = scaleX == 0.0 ? scale : scaleX;
		scaleY = scaleY == 0.0 ? scale : scaleY;
		
		id action_		= [class_ actionWithDuration:duration scaleX:scaleX scaleY:scaleY];
		
		if (forever) {
			return [CCRepeatForever actionWithAction:action_] ;
		}
		
		return action_;
	}
	
	return nil;
}
@end

@implementation CCComponent
@synthesize context = _context;
@synthesize childs = _childs;
@synthesize invalid = _invalid;
//@synthesize batch = _batch;
//@synthesize isBatch = _isBatch;

#if PHYSIC_ENABLED
@synthesize deltaAngle = _deltaAngle;
@synthesize model = _model;
@synthesize updatePhysic = _updatePhysic;
@synthesize offset = _offset;
@synthesize angle = _angle;
@synthesize bodyToNodeTransform = _bodyToNodeTransform;
@synthesize destroyPhysicOnDealloc = _destroyPhysicOnDealloc;
#endif

#pragma mark Initialize
+ (id) componentWithFile:(NSString *) file{
	return [[[self alloc] initWithFile:file] autorelease];
}

- (id) initSafe{
	self = [super init];
#if DEBUG_INSTANCES_COUNT
	CCCOUNT ++;
	//NSLog(@"INIT : CC = %d %@",CCCOUNT,self);
#endif
	_childs= [[CCArray alloc] init];
	_childs_map = [[NSMutableDictionary alloc] init];
	_context = nil;
#if PHYSIC_ENABLED
	_physics = [[NSMutableDictionary alloc] init];
	_destroyPhysicOnDealloc = YES;
#endif
	return self;
}

- (id) initWithFile:(NSString *) file{
#if DEBUG_INSTANCES_COUNT
	CCCOUNT ++;
	//NSLog(@"INIT F: CC = %d %@",CCCOUNT,self);
#endif
	_childs= [[CCArray alloc] init];
	_childs_map = [[NSMutableDictionary alloc] init];
	
#if PHYSIC_ENABLED
	_physics = [[NSMutableDictionary alloc] init];
	_destroyPhysicOnDealloc = NO;
#endif
	
	if ([file hasSuffix:@".plist"]) {
		self = [super init];
		_def = (NSDictionary *) [[FileContentCache cache] contentInBundle:file];
		if (_def == nil) {
			return nil;
		}
		[_def retain];
		
		NSString *sprite = [_def objectForKey:@"sprite"];
		if ([[_def objectForKey:@"sheet"] length]) {
			[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:[NSString stringWithFormat:@"%@.plist",[_def objectForKey:@"sheet"]]]; 
			if ([sprite length]) {
				[self setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:sprite]] ;
			}
		}else {
			if([sprite length])
				[self _init_safe_:sprite];
		}
		
		[self loadChilds];
		
	}else{
		self = [super initWithFile:file];
	}
	
	return self;
}

- (CCContext *) context{
	if (_context != nil) {
		return _context;
	}
	
	if ([self.parent isKindOfClass:[CCComponent class]]) {
		return [(CCComponent *)self.parent context];
	}
	
	return nil;
}

//- (void) draw{
//	[super draw];
//	CGRect s = [self rect];
//	CGPoint vertices[4]={
//		ccp(s.origin.x,s.origin.y),ccp(s.origin.x,s.size.height+s.origin.y),
//		ccp(s.size.width+s.origin.x,s.size.height+s.origin.y),ccp(s.size.width+s.origin.x,s.origin.y),
//	};
//	ccDrawPoly(vertices, 4, YES);
//	
//}

#pragma mark Overwrite CCNode
- (void) onExit{
	[super onExit];
}

- (void) setPosition:(CGPoint) pos{
	[super setPosition:pos];
#if PHYSIC_ENABLED
	if (self.updatePhysic) {
		[self updateToPhysic];
	}
#endif
}

- (void) setRotation:(float) r{
	[super setRotation:r];
#if PHYSIC_ENABLED
	if (self.updatePhysic) {
		[self updateToPhysic];
	}
#endif
}

#pragma mark Manage child components 
- (void) addComponent:(CCComponent *) child z:(int) z{
	[_childs addObject:child];
	child.context = self.context;
	
	[super addChild:child z:z];
}

- (void) addComponent:(CCComponent *) child{
	[self addComponent:child z:child.zOrder];
}

- (void) removeComponent:(CCComponent *) child{
	NSString *key ;
	BOOL found = FALSE;
	for (key in [_childs_map allKeys]) {
		if ([_childs_map objectForKey:key] == child) {
			found = TRUE;
			break;
		}
	}
	if (found) {
		[_childs_map removeObjectForKey:key];
	}
	
	[self removeChild:child cleanup:YES];
	
	[_childs removeObject:child];
}

- (void) addComponent:(CCComponent *) child key:(NSString *) key z:(int)z{
	if ([_childs_map objectForKey:key] != nil) {
		CCLOG(@"Key exists");
		return;
	}
	[self addComponent:child z:z];
	[_childs_map setObject:child forKey:key];
	
}

- (void) addComponent:(CCComponent *) child key:(NSString *) key{
	[self addComponent:child key:key z:child.zOrder];
}


- (void) removeComponentByKey:(NSString *) key{
	if ([_childs_map objectForKey:key] == nil) {
		return;
	}
	[self removeComponent:[_childs_map objectForKey:key]];
}

#pragma mark State control 
/** State control 
 Change state: change the image frame or play animation on the sprite
 Once state is set, the stateObject is nilled when the state did change or when 
 you interupt the state
 */

- (NSString *) state{
	return _state;
}

- (void) setState:(NSString *) state_{
	[self stopCurrentState];
	id todo = [self actionForState:state_];
	if ([todo isKindOfClass:[CCAction class]]) {
		[(CCNode *)todo setTag:COMPONENT_STATE_ACTION_TAG];
		[self runAction:todo];
	} else if (todo) {
		[self setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:todo]];
	}
	
	[_state autorelease];
	_state = [state_ retain];
}

- (void) setState:(NSString *)state_ 
		  context:(NSString *) context 
		   target:(id) target
		 selector:(SEL) selector{
	
	[self stopCurrentState];
	id todo = [self actionForState:state_];
	if ([todo isKindOfClass:[CCFiniteTimeAction class]]) {
		todo = [CCSequence actionOne:(CCFiniteTimeAction *)todo 
								 two:[CCCallFuncND actionWithTarget:target 
														   selector:selector 
															   data:context]
				];
		[(CCNode *)todo setTag:COMPONENT_STATE_ACTION_TAG];
		[self runAction:todo];
	}else if ([todo isKindOfClass:[CCAction class]]) {
		[(CCNode *)todo setTag:COMPONENT_STATE_ACTION_TAG];
		[self runAction:todo];
	} else if (todo) {
		[self setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:todo]];
	}
	
	[_state autorelease];
	_state = [state_ retain];
}

- (void) setStateForever:(NSString *) state{
	id todo = [self actionForState:state];
	if ([todo isKindOfClass:[CCRepeatForever class]]) {
		[(CCNode *)todo setTag:COMPONENT_STATE_ACTION_TAG];
		[self runAction:todo];
	} else if ([todo isKindOfClass:[CCFiniteTimeAction class]]) {
		todo = [CCRepeatForever actionWithAction:todo];
		[(CCNode *)todo setTag:COMPONENT_STATE_ACTION_TAG];
		[self runAction:todo];
	}
	
	[_state autorelease];
	_state = [state retain];
}

- (void) spawnStates:(NSString *) state1, ...{
	va_list params;
	va_start(params,state1);
	
	CCFiniteTimeAction *now;
	CCFiniteTimeAction *prev = [self actionForState:state1];
	
	NSString *str;
	while(state1) {
		str = va_arg(params,NSString*);
		
		if (str) {
			now = [self actionForState:str];
			if ([now isKindOfClass:[CCFiniteTimeAction class]]) {
				prev = [CCSpawn actionOne: prev two: now];
			}
		}else {
			break;
		}
	}
	va_end(params);
	
	prev.tag = COMPONENT_STATE_ACTION_TAG;
	[self runAction:prev];
}

- (void) spawnInContext:(NSString *) context target:(id) target selector:(SEL) selector states:(NSString *) state1, ...{
	va_list params;
	va_start(params,state1);
	
	CCFiniteTimeAction *now;
	CCFiniteTimeAction *prev = [self actionForState:state1];
	
	NSString *str;
	while(state1) {
		str = va_arg(params,NSString*);
		
		if (str) {
			now = [self actionForState:str];
			if ([now isKindOfClass:[CCFiniteTimeAction class]]) {
				prev = [CCSpawn actionOne: prev two: now];
			}
		}else {
			break;
		}
	}
	va_end(params);
	
	if (target && selector) {
		prev = [CCSequence actionOne:prev 
								 two:[CCCallFuncND actionWithTarget:target 
														   selector:selector 
															   data:context]];
	}
	
	prev.tag = COMPONENT_STATE_ACTION_TAG;
	[self runAction:prev];
}

- (void) stopCurrentState{
	[self stopActionByTag:COMPONENT_STATE_ACTION_TAG];
}

- (BOOL) isStateRunning{
	if ([self getActionByTag:COMPONENT_STATE_ACTION_TAG]) {
		return YES;
	}
	
	return NO;
}

#pragma mark Query childs
- (CCComponent *) componentByKey:(NSString *) key{
	return [_childs_map objectForKey:key];
}

- (CCComponent *) componentByKeyRecursive:(NSString *) key{
	if ([_childs_map objectForKey:key] != nil) {
		return [_childs_map objectForKey:key];
	}
	CCComponent *node;
	CCARRAY_FOREACH(_childs, node){
		CCComponent *child = [node componentByKey:key];
		if (child != nil) {
			return child;
		}
	}
	
	return nil;
}

- (CCComponent *) child:(NSString *) key{
	return [self componentByKey:key];
}

- (CCComponent *) componentByTag:(int) tag{
	CCComponent *node = nil;
	CCARRAY_FOREACH(_childs, node){
		if (node.tag == tag) {
			break;
		}
	}
	return node;
}

- (NSArray *) componentsByTag:(int) tag{
	NSMutableArray *nodes = [NSMutableArray array];
	CCNode *node;
	CCARRAY_FOREACH(_childs, node){
		if (node.tag == tag) {
			[nodes addObject:node];
		}
	}
	return nodes;
}

/** @pos: global location */
- (CCComponent *) componentAtPoint:(CGPoint) pos{
	CCComponent *node;
	CCARRAY_FOREACH(_childs,node){
		if ([node containsPoint:pos]) {
			return node;
		}
	}
	return nil;
}

#pragma mark Query location & geometry
-(CGPoint) absolutePosition{
	CGPoint ret = self.position;
	CCNode *cn = self;
	
	while (cn.parent != nil) {
		cn = cn.parent;
		ret = ccpAdd( ret,  cn.position );
	}
	return ret;
}

- (CGSize) size{
	CGSize size = self.textureRect.size;
	return CGSizeMake(size.width * self.scaleX, size.height * self.scaleY);
}
/*
- (CGRect) rect{
	return CGRectMake(-self.contentSize.width/2, -self.contentSize.height/2, self.contentSize.width, self.contentSize.height);
}
*/
- (CGRect) bound{
	CGSize size = [self size];
	//anchorPoint = {.5,.5}, without scale awareness
	return CGRectMake(self.position.x - size.width/2, self.position.y - size.height/2, size.width, size.height);
}

#pragma mark NSKeyValueCoding
- (id) valueForUndefinedKey:(NSString *)key{
	return nil;
}

- (void) setValue:(id)value forUndefinedKey:(NSString *)key{

}

- (void) bindData:(NSDictionary *) data{
	if (data) {
		[self setValuesForKeysWithDictionary:data];
	}
}

#pragma mark Dealloc
- (void) dealloc{
#if DEBUG_INSTANCES_COUNT
	CCCOUNT --;
	NSLog(@"DEALLOC: CCC = %d - %@",CCCOUNT,self);
#endif
	
#if PHYSIC_ENABLED
	[self releasePhysicAndDestroy:_destroyPhysicOnDealloc];
	[_physics release];
#endif

	[_childs_map release];
	[_def release];
	[_state release];
	[_childs release];
	[super dealloc];
}

#pragma mark Physics
#if PHYSIC_ENABLED
- (void) releasePhysicAndDestroy:(BOOL) destroy{
	for (NSString *key in _physics) {
		PhysicUserData *data = [_physics objectForKey:key];
		int type = data.type;
		CCComponent *child;
		if ([data.key isEqualToString:@"self"]) {
			child = self;
		}else
			child = [self componentByKeyRecursive:data.key];
		child.model = nil;
		
		switch (type) {
			case PHYSIC_BODY:
				((b2Body *)data.entity)->SetUserData(NULL);
				if (destroy) {
					self.context.physicContext->destroyBody((b2Body *) data.entity);
				}
				break;
				
			case PHYSIC_JOINT:
				((b2Joint *)data.entity)->SetUserData(NULL);
				if (destroy) {
					b2Body *body = ((b2Fixture *) data.entity)->GetBody();
					body->DestroyFixture((b2Fixture *) data.entity);
				}
				break;
				
			case PHYSIC_FIXTURE:
				((b2Fixture *)data.entity)->SetUserData(NULL);
				if (destroy) {
					self.context.physicContext->DestroyJoint((b2Joint *) data.entity);
				}
				break;
				
			default:
				break;
		}
	}
	[_physics removeAllObjects];
}

- (CGPoint) centerOfMass{
	if (self.model && self.model.type == PHYSIC_BODY) {
		b2Body *body = (b2Body *) self.model.entity;
		return MTP_POINT(body->GetWorldCenter());
	}
	
	return CGPointZero;
}

- (b2Body *) body{
	if (self.model && self.model.type == PHYSIC_BODY) {
		return (b2Body *) self.model.entity;
	}
	
	return NULL;
}

- (void) toDestroyed{
	[self.context toDestroyed:self];
}

- (void) toReleased{
	[self.context toReleased:self];
}

- (void) applyImpulse:(CGPoint) impulse atPoint:(CGPoint) pos{
	if (self.model && self.model.type == PHYSIC_BODY) {
		b2Body *body = (b2Body *) self.model.entity;
		body->ApplyLinearImpulse(PTM_POINT(impulse), PTM_POINT(pos));
	}
}

- (void) applyImpulse:(CGPoint) impulse{
	if (self.model && self.model.type == PHYSIC_BODY) {
		b2Body *body = (b2Body *) self.model.entity;
		body->ApplyLinearImpulse(PTM_POINT(impulse), body->GetWorldCenter());
	}
}

- (void) applyForce:(CGPoint) force atPoint:(CGPoint) pos{
	if (self.model && self.model.type == PHYSIC_BODY) {
		b2Body *body = (b2Body *) self.model.entity;
		body->ApplyForce(b2Vec2(force.x,force.y), PTM_POINT(pos));
	}
}

- (void) applyForce:(CGPoint) force{
	if (self.model && self.model.type == PHYSIC_BODY) {
		b2Body *body = (b2Body *) self.model.entity;
		body->ApplyForce(b2Vec2(force.x,force.y), body->GetWorldCenter());
	}
}

- (void) applyTorque:(float) torque{
	if (self.model && self.model.type == PHYSIC_BODY) {
		b2Body *body = (b2Body *) self.model.entity;
		body->ApplyTorque(torque);
	}
}

- (CGAffineTransform) bodyToWorldTransform{
	b2Body *body = [self body];
	CGPoint p = MTP_POINT(body->GetPosition());
	CGAffineTransform t1 = CGAffineTransformMakeTranslation(p.x, p.y);
	CGAffineTransform t2 = CGAffineTransformMakeRotation(body->GetAngle());
	
	//The order of transform DOES make sense
	return CGAffineTransformConcat(t2, t1);
}

- (void) updateFromPhysic{
	self.position = CGPointApplyAffineTransform(self.offset, [self bodyToWorldTransform]);
	self.rotation = -1 * CC_RADIANS_TO_DEGREES([self body]->GetAngle()) + self.deltaAngle + self.angle;
}

- (void) updateToPhysic{
	CGPoint bodyInNodeSpace = CGPointApplyAffineTransform(CGPointZero, [self bodyToNodeTransform]);
	CGPoint bodyInWorldSpace = CGPointApplyAffineTransform(bodyInNodeSpace, [self nodeToWorldTransform]);
	
	[self body]->SetTransform(PTM_POINT(bodyInWorldSpace) ,CC_DEGREES_TO_RADIANS(self.deltaAngle - self.rotation + self.angle));
}

#pragma mark  PhysicProtocol
- (PhysicUserData *) registerPhysic:(NSString *) key{
	if (key == nil) {
		key = @"self";
	}
	
	PhysicUserData *data = [[PhysicUserData alloc] init];
	data.component = self;
	data.key = key;
	[_physics setObject:data forKey:key];
	
	if ([key isEqualToString:@"self"]) {
		self.model = data;
	}else {
		CCComponent *child = [self componentByKeyRecursive:data.key];
		child.model = data;	
	}
	
	return [data autorelease];
}

- (void) unregisterPhysic:(NSString *) key destroyPhysic:(BOOL) destroy{
	if (key == nil) {
		key = @"self";
	}
	PhysicUserData *data = [_physics objectForKey:key];
	CCComponent *child = [self componentByKeyRecursive:data.key];
	child.model = nil;
	if (data) {
		switch (data.type) {
			case PHYSIC_BODY:
				((b2Body *) data.entity)->SetUserData(NULL);
				if (destroy) {
					self.context.physicContext->destroyBody((b2Body *) data.entity);
				}
				break;
				
			case PHYSIC_FIXTURE:
				((b2Fixture *) data.entity)->SetUserData(NULL);	
				if (destroy) {
					b2Body *body = ((b2Fixture *) data.entity)->GetBody();
					body->DestroyFixture((b2Fixture *) data.entity);
				}
				break;
				
			case PHYSIC_JOINT:
				((b2Joint *) data.entity)->SetUserData(NULL);
				if (destroy) {
					self.context.physicContext->DestroyJoint((b2Joint *) data.entity);
				}
				break;
			default:
				break;
		}
	}
	
	[_physics removeObjectForKey:key];
}

- (BOOL) isValid{
	return !_invalid;
}

- (BOOL) isUpdateIgnored{
	return _updatePhysic;
}

- (void) physicBodyChanged:(PhysicUserData *) data{
	CCComponent *node = nil;
	if (data.key == nil || [data.key isEqualToString:@"self"]) {
		node = self;
	}else {
		node = [self componentByKeyRecursive:data.key];
	}
	
	if (node) {
		[node updateFromPhysic];
	}
}

- (void) attachedPhysicEntityDestroyed:(PhysicEntity) entity data:(PhysicUserData *) data{
	
}

- (void) physicEntity:(PhysicUserData *) sdata collideWith:(PhysicUserData *) data info:(CollisionInfo) info{

}

- (void) physicBody:(PhysicUserData *) data receivedImpulse:(CGPoint) iml{
	
}

#endif //of #if PHYSIC_ENABLED

#pragma mark Util functions

@end
