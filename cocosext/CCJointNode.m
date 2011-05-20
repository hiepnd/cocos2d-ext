//
//  CCJointNode.m
//  ___PROJECTNAME___
//
//  Created by Ngo Duc Hiep on 3/9/11.
//  Copyright 2011 PTT Solution., JSC. All rights reserved.
//


#import "CCJointNode.h"

#if PHYSIC_ENABLED

@implementation CCJointNode
@synthesize lineWidth = _lineWidth;
@synthesize lineColor = _lineColor;
@synthesize joint = _joint;
@synthesize stretchLine = _stretchLine;
@synthesize physicContext = _physicContext;

- (id) initWithFile:(NSString *)file{
	return nil;
}

- (id) initWithJoint:(b2Joint *) joint registerPhysic:(BOOL) reg{
	self = [super init];
	_joint = joint;
	_lineColor = ccc4FFromccc3B(ccGRAY);
	_lineWidth = 2;
	_texture = nil;
	_stretchLine = YES;
	_isValid = YES;
	_physicContext = NULL;
	
	switch (joint->GetType()) {
		case e_distanceJoint:
			_baseLength = ((b2DistanceJoint *) joint)->GetLength() * PTM_RATIO;
			break;
		case e_revoluteJoint:
		{
			CGPoint o1 = MTP_POINT(joint->GetBodyA()->GetPosition());
			CGPoint o2 = MTP_POINT(joint->GetBodyB()->GetPosition());
			CGPoint anchor = MTP_POINT(joint->GetAnchorA());
			
			_baseLength = ccpDistance(o1, anchor);
			_baseLength2 = ccpDistance(o2, anchor);
			break;
		}
			
		case e_pulleyJoint:
		{
			b2PulleyJoint *j = (b2PulleyJoint *) joint;
			CGPoint anchor1 = MTP_POINT(j->GetAnchorA());
			CGPoint ground1 = MTP_POINT(j->GetGroundAnchorA());
			CGPoint anchor2 = MTP_POINT(j->GetAnchorB());
			CGPoint ground2 = MTP_POINT(j->GetGroundAnchorB());
			_baseLength = ccpDistance(anchor1, ground1);
			_baseLength2 = ccpDistance(anchor2, ground2);
			_baseLength3 = ccpDistance(ground1, ground2);
			_stretchLine = NO;
			break;
		}
			
		case e_prismaticJoint:
		{
			CGPoint anchor2 = MTP_POINT(joint->GetAnchorB());
			CGPoint pos2 = MTP_POINT(joint->GetBodyB()->GetPosition());
			CGPoint anchor1 = MTP_POINT(joint->GetAnchorA());
			CGPoint pos1 = MTP_POINT(joint->GetBodyA()->GetPosition());
			_baseLength = ccpDistance(pos1, anchor1);
			_baseLength2 = ccpDistance(pos2, anchor2);
			_baseLength3 = ccpDistance(anchor1, anchor2);
			_stretchLine = NO;	
			break;
		}
/*			
		case e_lineJoint:
		{
			CGPoint anchor2 = MTP_POINT(joint->GetAnchorB());
			CGPoint pos2 = MTP_POINT(joint->GetBodyB()->GetPosition());
			CGPoint anchor1 = MTP_POINT(joint->GetAnchorA());
			CGPoint pos1 = MTP_POINT(joint->GetBodyA()->GetPosition());
			_baseLength = ccpDistance(pos1, anchor1);
			_baseLength2 = ccpDistance(pos2, anchor2);
			_baseLength3 = ccpDistance(anchor1, anchor2);
			_stretchLine = NO;	
			break;
		}
 */
		default:
			break;
	}
	
	if(reg){
		PhysicUserData *data = [self registerPhysic:nil];
		data.entity = joint;
		data.type = PHYSIC_JOINT;
		joint->SetUserData(data);
	}
	
	return self;
}

- (id) initWithJoint:(b2Joint *) joint{
	return [[CCJointNode alloc] initWithJoint:joint registerPhysic:YES];
}

+ (id) nodeWithJoint:(b2Joint *) joint registerPhysic:(BOOL) reg{
	return [[[self alloc] initWithJoint:joint registerPhysic:reg] autorelease];
}

+ (id) nodeWithJoint:(b2Joint *) joint{
	return [[[self alloc] initWithJoint:joint] autorelease];
}

- (void) dealloc{
	if (/* _userData.entity != NULL && */_physicContext != NULL) {
		_physicContext->DestroyJoint((b2Joint *) _joint);
	}
	[_texture release];
	[_userData release];
	[super dealloc];
}

- (void) setTexture:(NSString *) texture{
	if (texture == nil) {
		[_texture release];
		_texture = nil;
		return;
	}
	
	CCTexture2D *txt = [[CCTextureCache sharedTextureCache] addImage:texture];
	
	if (txt == _texture) {
		return;
	}
	
	if (txt) {
		[_texture release];
		_texture = [txt retain];
	}else {
		[_texture release];
		_texture = nil;
	}

}

- (NSString *) texture{
	return @"Don't know";
}

- (void) draw{
	SEL selector = nil;
	switch (_joint->GetType()) {
		case e_mouseJoint:
			selector = @selector(drawMouseJoint:);
			break;
			
		case e_distanceJoint:
			if (_texture) {
				selector = @selector(drawDistanceJointWithTexture:);
			}else {
				selector = @selector(drawDistanceJoint:);
			}
			break;
			
		case e_revoluteJoint:
			if (_texture) {
				selector = @selector(drawRevoluteJointWithTexture:);
			}else {
				selector = @selector(drawRevoluteJoint:);
			}

			break;
			
		case e_pulleyJoint:
			if (_texture) {
				selector = @selector(drawPulleyJointWithTexture:);
			}else {
				selector = @selector(drawPulleyJoint:);
			}
			
			break;

		case e_prismaticJoint:
			if (_texture) {
				selector = @selector(drawPrismaticJointWithTexture:);
			}else {
				selector = @selector(drawPrismaticJoint:);
			}

			break;
			
		case e_wheelJoint:
			if (_texture) {
				selector = @selector(drawLineJointWithTexture:);
			}else {
				selector = @selector(drawLineJoint:);
			}
			
			break;
		default:
			break;
	}
	
	if (selector) {
		//[self performSelector:@selector(beforeDraw)];
		[self performSelector:selector withObject:(id)_joint];
		//[self performSelector:@selector(afterDraw)];
	}
}

- (void) setPosition:(CGPoint) pos{
	if (_joint && _joint->GetType() == e_mouseJoint) {
		((b2MouseJoint *) _joint)->SetTarget(PTM_POINT(pos));
	}
	position_ = pos;
}

- (void) beforeDraw{
	//glEnable(GL_VERTEX_ARRAY);
	//glEnable(GL_TEXTURE_COORD_ARRAY);
	//glEnable(GL_BLEND);
	//glBlendFunc(GL_SRC_COLOR, GL_ONE);
}

- (void) afterDraw{
	//glDisable(GL_TEXTURE_COORD_ARRAY);
	//glDisable(GL_VERTEX_ARRAY);
	//glDisable(GL_BLEND);
}

//TODO: RETINA & IPAD ? CONTENT_SCALE_FACTOR

#pragma mark Private methods
- (void) drawDistanceJoint:(b2DistanceJoint *) joint{
	CGPoint from = MTP_POINT(joint->GetAnchorA());
	CGPoint to = MTP_POINT(joint->GetAnchorB());
	
	[self drawLineFrom:from to:to width:_lineWidth color:_lineColor];
}

- (void) drawMouseJoint:(b2MouseJoint *) joint{
	CGPoint from = MTP_POINT(joint->GetAnchorA());
	CGPoint to = MTP_POINT(joint->GetAnchorB());
	
	[self drawLineFrom:from to:to width:_lineWidth color:_lineColor];
}

- (void) drawDistanceJointWithTexture:(b2DistanceJoint *) joint{
	CGPoint from = MTP_POINT(joint->GetAnchorA());
	CGPoint to = MTP_POINT(joint->GetAnchorB());
	[self drawLineFrom:from to:to texture:_texture baseLength:_baseLength stretch:_stretchLine];
}

- (void) drawRevoluteJoint:(b2RevoluteJoint *) joint{
	CGPoint o1 = MTP_POINT(joint->GetBodyA()->GetPosition());
	CGPoint o2 = MTP_POINT(joint->GetBodyB()->GetPosition());
	CGPoint anchor = MTP_POINT(joint->GetAnchorA());
	
	[self drawLineFrom:o1 to:anchor width:_lineWidth color:_lineColor];
	[self drawLineFrom:o2 to:anchor width:_lineWidth color:_lineColor];
}

- (void) drawRevoluteJointWithTexture:(b2RevoluteJoint *) joint{
	CGPoint o1 = MTP_POINT(joint->GetBodyA()->GetPosition());
	CGPoint o2 = MTP_POINT(joint->GetBodyB()->GetPosition());
	CGPoint anchor = MTP_POINT(joint->GetAnchorA());
		
	[self drawLineFrom:o1 to:anchor texture:_texture baseLength:_baseLength stretch:_stretchLine];
	[self drawLineFrom:anchor to:o2 texture:_texture baseLength:_baseLength2 stretch:_stretchLine];
}

- (void) drawPulleyJoint:(b2PulleyJoint *) joint{
	CGPoint anchor1 = MTP_POINT(joint->GetAnchorA());
	CGPoint ground1 = MTP_POINT(joint->GetGroundAnchorA());
	CGPoint anchor2 = MTP_POINT(joint->GetAnchorB());
	CGPoint ground2 = MTP_POINT(joint->GetGroundAnchorB());
	
	[self drawLineFrom:ground1 to:anchor1 width:_lineWidth color:_lineColor];
	[self drawLineFrom:ground2 to:anchor2 width:_lineWidth color:_lineColor];
	[self drawLineFrom:ground2 to:ground1 width:_lineWidth color:_lineColor];
}

- (void) drawPulleyJointWithTexture:(b2PulleyJoint *) joint{
	CGPoint anchor1 = MTP_POINT(joint->GetAnchorA());
	CGPoint ground1 = MTP_POINT(joint->GetGroundAnchorA());
	CGPoint anchor2 = MTP_POINT(joint->GetAnchorB());
	CGPoint ground2 = MTP_POINT(joint->GetGroundAnchorB());

	[self drawLineFrom:anchor1 to:ground1 texture:_texture baseLength:_baseLength stretch:_stretchLine];
	[self drawLineFrom:anchor2 to:ground2 texture:_texture baseLength:_baseLength2 stretch:_stretchLine];
	[self drawLineFrom:ground1 to:ground2 texture:_texture baseLength:_baseLength3 stretch:_stretchLine];
}

- (void) drawPrismaticJoint:(b2PrismaticJoint *) joint{
	CGPoint anchor2 = MTP_POINT(joint->GetAnchorB());
	CGPoint pos2 = MTP_POINT(joint->GetBodyB()->GetPosition());
	
	CGPoint anchor1 = MTP_POINT(joint->GetAnchorA());
	CGPoint pos1 = MTP_POINT(joint->GetBodyA()->GetPosition());
	
	if (joint->GetBodyA()->GetType() != b2_staticBody) {
		[self drawLineFrom:pos1 to:anchor1 width:_lineWidth color:_lineColor];
	}
	[self drawLineFrom:pos2 to:anchor2 width:_lineWidth color:_lineColor];

	if (joint->IsLimitEnabled() && joint->GetBodyA()->GetType() == b2_staticBody) {
		CGPoint d = MTP_POINT(joint->GetBodyA()->GetWorldVector(joint->GetLocalAxis()));
		CGPoint upper = ccpAdd(anchor1, ccpMult(ccpNormalize(d), joint->GetUpperLimit() * PTM_RATIO));
		CGPoint lower = ccpAdd(anchor1, ccpMult(ccpNormalize(d), joint->GetLowerLimit() * PTM_RATIO));
		[self drawLineFrom:upper to:lower width:_lineWidth color:_lineColor];
	}else {
		[self drawLineFrom:anchor1 to:anchor2 width:_lineWidth color:_lineColor];
	}
}

- (void) drawPrismaticJointWithTexture:(b2PrismaticJoint *) joint{
	CGPoint anchor2 = MTP_POINT(joint->GetAnchorB());
	CGPoint pos2 = MTP_POINT(joint->GetBodyB()->GetPosition());
	
	CGPoint anchor1 = MTP_POINT(joint->GetAnchorA());
	CGPoint pos1 = MTP_POINT(joint->GetBodyA()->GetPosition());
	
	if (joint->GetBodyA()->GetType() != b2_staticBody) {
		[self drawLineFrom:pos1 to:anchor1 texture:_texture baseLength:_baseLength stretch:_stretchLine];
	}
	[self drawLineFrom:pos2 to:anchor2 texture:_texture baseLength:_baseLength2 stretch:_stretchLine];
	
	if (joint->IsLimitEnabled() && joint->GetBodyA()->GetType() == b2_staticBody) {
		CGPoint d = MTP_POINT(joint->GetBodyA()->GetWorldVector(joint->GetLocalAxis()));
		CGPoint upper = ccpAdd(anchor1, ccpMult(ccpNormalize(d), joint->GetUpperLimit() * PTM_RATIO));
		CGPoint lower = ccpAdd(anchor1, ccpMult(ccpNormalize(d), joint->GetLowerLimit() * PTM_RATIO));
		[self drawLineFrom:upper to:lower texture:_texture baseLength:ccpDistance(upper, lower) stretch:_stretchLine];
	}else {
		[self drawLineFrom:anchor1 to:anchor2 texture:_texture baseLength:_baseLength3 stretch:_stretchLine];
	}
}


- (void) drawLineJoint:(b2WheelJoint *) joint{
	CGPoint anchor2 = MTP_POINT(joint->GetAnchorB());
	CGPoint pos2 = MTP_POINT(joint->GetBodyB()->GetPosition());
	
	CGPoint anchor1 = MTP_POINT(joint->GetAnchorA());
	CGPoint pos1 = MTP_POINT(joint->GetBodyA()->GetPosition());
	
	if (joint->GetBodyA()->GetType() != b2_staticBody) {
		[self drawLineFrom:pos1 to:anchor1 width:_lineWidth color:_lineColor];
	}
	[self drawLineFrom:pos2 to:anchor2 width:_lineWidth color:_lineColor];
/*	
	if (joint->IsLimitEnabled() && joint->GetBodyA()->GetType() == b2_staticBody) {
		CGPoint d = MTP_POINT(joint->GetBodyA()->GetWorldVector(joint->GetLocalAxis()));
		CGPoint upper = ccpAdd(anchor1, ccpMult(ccpNormalize(d), joint->GetUpperLimit() * PTM_RATIO));
		CGPoint lower = ccpAdd(anchor1, ccpMult(ccpNormalize(d), joint->GetLowerLimit() * PTM_RATIO));
		[self drawLineFrom:upper to:lower width:_lineWidth color:_lineColor];
	}else {
		[self drawLineFrom:anchor1 to:anchor2 width:_lineWidth color:_lineColor];
	}
 */
}


- (void) drawLineJointWithTexture:(b2WheelJoint *) joint{
	CGPoint anchor2 = MTP_POINT(joint->GetAnchorB());
	CGPoint pos2 = MTP_POINT(joint->GetBodyB()->GetPosition());
	
	CGPoint anchor1 = MTP_POINT(joint->GetAnchorA());
	CGPoint pos1 = MTP_POINT(joint->GetBodyA()->GetPosition());
	
	if (joint->GetBodyA()->GetType() != b2_staticBody) {
		[self drawLineFrom:pos1 to:anchor1 texture:_texture baseLength:_baseLength stretch:_stretchLine];
	}
	[self drawLineFrom:pos2 to:anchor2 texture:_texture baseLength:_baseLength2 stretch:_stretchLine];
	/*
	if (joint->IsLimitEnabled() && joint->GetBodyA()->GetType() == b2_staticBody) {
		CGPoint d = MTP_POINT(joint->GetBodyA()->GetWorldVector(joint->GetLocalAxis()));
		CGPoint upper = ccpAdd(anchor1, ccpMult(ccpNormalize(d), joint->GetUpperLimit() * PTM_RATIO));
		CGPoint lower = ccpAdd(anchor1, ccpMult(ccpNormalize(d), joint->GetLowerLimit() * PTM_RATIO));
		[self drawLineFrom:upper to:lower texture:_texture baseLength:ccpDistance(upper, lower) stretch:_stretchLine];
	}else {
		[self drawLineFrom:anchor1 to:anchor2 texture:_texture baseLength:_baseLength3 stretch:_stretchLine];
	}
	 */
}


#pragma mark PhysicProtocol
- (PhysicUserData *) registerPhysic:(NSString *) key{
	if (_userData != nil) {
		return nil;
	}
	
	_userData = [[PhysicUserData alloc] init];
	_userData.type = PHYSIC_JOINT;
	_userData.component = self;
	_userData.key = nil;
	
	return _userData;
}

- (void) unregisterPhysic:(NSString *) key destroyPhysic:(BOOL) destroy{
	b2Joint *joint = (b2Joint *) _userData.entity;
	joint->SetUserData(NULL);
	[_userData release];
	_userData = nil;
	if (destroy) {
		
	}
}

- (void) releasePhysicAndDestroy:(BOOL) destroy{
	b2Joint *joint = (b2Joint *) _userData.entity;
	joint->SetUserData(NULL);
	if (destroy) {
		
	}
}

- (BOOL) isValid{
	return _isValid;	
}

- (BOOL) isUpdateIgnored{
	return YES;
}

- (void) attachedPhysicEntityDestroyed:(PhysicUserData *) data{
	[self unregisterPhysic:@"self" destroyPhysic:NO];
	_joint = NULL;
}
@end

#endif