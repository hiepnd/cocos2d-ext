//
//  ComponentPhysicData.m
//  ___PROJECTNAME___
//
//  Created by Ngo Duc Hiep on 3/16/11.
//  Copyright 2011 PTT Solution., JSC. All rights reserved.
//

#import "ComponentPhysic.h"

#if PHYSIC_ENABLED

@implementation ComponentPhysic

@synthesize component = _component;
@synthesize deltaAngle = _deltaAngle;
@synthesize model = _model;
@synthesize updatePhysic = _updatePhysic;
@synthesize offset = _offset;
@synthesize angle = _angle;
@synthesize bodyToNodeTransform = _bodyToNodeTransform;

- (id) init{
	self = [super init];
	_physics = [[NSMutableDictionary alloc] init];
	
	return self;
}

- (void) dealloc{
	[_physics release];
	[super dealloc];
}

- (void) releasePhysicAndDestroy:(BOOL) destroy{
	for (NSString *key in _physics) {
		PhysicUserData *data = [_physics objectForKey:key];
		int type = data.type;
		CCComponent *child = [self componentByKeyRecursive:data.key];
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
	if (self.component.model && self.component.model.type == PHYSIC_BODY) {
		b2Body *body = (b2Body *) self.component.model.entity;
		return MTP_POINT(body->GetWorldCenter());
	}
	
	return CGPointZero;
}

- (b2Body *) body{
	if (self.component.model && self.component.model.type == PHYSIC_BODY) {
		return (b2Body *) self.component.model.entity;
	}
	
	return NULL;
}

- (void) toDestroyed{
	[self.component.context toDestroyed:self.component];
}

- (void) toReleased{
	[self.component.context toReleased:self.component];
}

- (void) applyImpulse:(CGPoint) impulse atPoint:(CGPoint) pos{
	b2Body *body = [self body];
	if (body != NULL) {
		body->ApplyLinearImpulse(PTM_POINT(impulse), PTM_POINT(pos));
	}
}

- (void) applyImpulse:(CGPoint) impulse{
	b2Body *body = [self body];
	if (body != NULL) {
		body->ApplyLinearImpulse(PTM_POINT(impulse), body->GetWorldCenter());
	}
}

- (void) applyForce:(CGPoint) force atPoint:(CGPoint) pos{
	b2Body *body = [self body];
	if (body != NULL) {
		body->ApplyForce(PTM_POINT(force), PTM_POINT(pos));
	}
}

- (void) applyForce:(CGPoint) force{
	b2Body *body = [self body];
	if (body != NULL) {
		body->ApplyForce(PTM_POINT(force), body->GetWorldCenter());
	}
}

- (void) applyTorque:(float) torque{
	b2Body *body = [self body];
	if (body != NULL) {
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
	self.component.position = CGPointApplyAffineTransform(self.offset, [self bodyToWorldTransform]);
	self.component.rotation = -1 * CC_RADIANS_TO_DEGREES([self body]->GetAngle()) + self.deltaAngle + self.angle;
}

- (void) updateToPhysic{
	CGPoint bodyInNodeSpace = CGPointApplyAffineTransform(CGPointZero, [self bodyToNodeTransform]);
	CGPoint bodyInWorldSpace = CGPointApplyAffineTransform(bodyInNodeSpace, [self nodeToWorldTransform]);
	
	[self body]->SetTransform(PTM_POINT(bodyInWorldSpace) ,CC_DEGREES_TO_RADIANS(self.deltaAngle - self.rotation + self.angle));
}

#pragma mark  PhysicProtocol
- (PhysicUserData *) registerPhysic:(NSString *) key{
	PhysicUserData *data = [[PhysicUserData alloc] init];
	data.component = self;
	data.key = key;
	[_physics setObject:data forKey:key];
	if ([key isEqualToString:@"self"] || key == nil) {
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
	//	if (data.component.tag == 1984) {
	//		[self toReleased];
	//		[sdata.component runAction:[CCSequence actions:[CCSpawn actionOne:[CCScaleTo actionWithDuration:1 scale:.2] 
	//														   two:[CCRotateTo actionWithDuration:1 angle:3600]],
	//						 [CCCallFuncND actionWithTarget:sdata.component selector:@selector(removeFromParentAndCleanup:) data:[NSNumber numberWithBool:YES]],
	//						 nil
	//						 ]];
	//	}
}

- (void) physicBody:(PhysicUserData *) data receivedImpulse:(CGPoint) iml{
	
}
@end

#endif
