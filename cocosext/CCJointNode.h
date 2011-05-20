//
//  CCJointNode.h
//  ___PROJECTNAME___
//
//  Created by Ngo Duc Hiep on 3/9/11.
//  Copyright 2011 PTT Solution., JSC. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "CCNode+Ext.h"
#import "constant+macro.h"
#import "CCComponent.h"

#if PHYSIC_ENABLED

#import "Box2D.h"
#import "PhysicUserData.h"
#import "PhysicContext.h"

@interface CCJointNode : CCNode<PhysicProtocol> {
	b2Joint *_joint;
	
	float _baseLength;
	float _baseLength2;
	float _baseLength3;
	
	float _lineWidth;
	ccColor4F _lineColor;
	
	//If the _texture is not nil, will draw with texture
	CCTexture2D *_texture;
	
	BOOL _stretchLine;
	
	//Physic
	BOOL _isValid;
	PhysicUserData *_userData;
	PhysicContext *_physicContext;
}
@property float lineWidth;
@property BOOL stretchLine;
@property ccColor4F lineColor;
@property (retain) NSString *texture;
@property (readonly) b2Joint *joint;
@property (assign) PhysicContext *physicContext;

- (id) initWithJoint:(b2Joint *) joint registerPhysic:(BOOL) reg;
- (id) initWithJoint:(b2Joint *) joint;
+ (id) nodeWithJoint:(b2Joint *) joint registerPhysic:(BOOL) reg;
+ (id) nodeWithJoint:(b2Joint *) joint;

- (void) drawDistanceJoint:(b2DistanceJoint *) joint;
- (void) drawDistanceJointWithTexture:(b2DistanceJoint *) joint ;

- (void) drawRevoluteJoint:(b2RevoluteJoint *) joint;
- (void) drawRevoluteJointWithTexture:(b2RevoluteJoint *) joint ;

- (void) drawPulleyJoint:(b2PulleyJoint *) joint;
- (void) drawPulleyJointWithTexture:(b2PulleyJoint *) joint ;

- (void) drawPrismaticJoint:(b2PrismaticJoint *) joint;
- (void) drawPrismaticJointWithTexture:(b2PrismaticJoint *) joint ;
/*
- (void) drawLineJoint:(b2LineJoint *) joint;
- (void) drawLineJointWithTexture:(b2LineJoint *) joint ;
 */
@end

#endif