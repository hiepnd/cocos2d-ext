//
//  ComponentPhysic.h
//  ___PROJECTNAME___
//
//  Created by Ngo Duc Hiep on 3/16/11.
//  Copyright 2011 PTT Solution., JSC. All rights reserved.
//
#import <Foundation/Foundation.h>

#if PHYSIC_ENABLED

#import "PhysicUserData.h"

@class CCComponent;

@interface ComponentPhysic : NSObject<PhysicProtocol> {
	CCComponent *_component;
	
	NSMutableDictionary *_physics;
	PhysicUserData *_model;
	float _deltaAngle;
	BOOL _updatePhysic;
	CGPoint _offset;
	float _angle; 
	CGAffineTransform _bodyToNodeTransform;
}
@property(assign) CCComponent *component;

@property(nonatomic) float deltaAngle;
@property(assign) PhysicUserData *model;

/** If YES, any modification to position & rotation of the node will change the body transform
 Use YES only with static or kinematic body
 When this property is YES, changes in body transform is not reflected body position & angle
 */
@property(nonatomic) BOOL updatePhysic;

/** Offset of the shape from body position , angle of the polygon shape  */
@property CGPoint offset;
@property float angle;

/** Use this transform to convert a point from body space to node space  */
@property CGAffineTransform bodyToNodeTransform;
@property(nonatomic) CGAffineTransform bodyToWorldTransform;

#pragma mark Methods

- (void) releasePhysicAndDestroy:(BOOL) destroy;

/** The center of mass of the attached body in GL space  */
- (CGPoint) centerOfMass;

/** The attached body if exists  */
- (b2Body *) body;

/** 
 Apply impulse to the attached body 
 @param impulse and @param pos are in GL space  
 */
- (void) applyImpulse:(CGPoint) impulse atPoint:(CGPoint) pos;

/** Apply impulse at center of mass  */
- (void) applyImpulse:(CGPoint) impulse;

/** 
 Apply force to the attached body
 @param force and @param pos are in GL space  
 */
- (void) applyForce:(CGPoint) force atPoint:(CGPoint) pos;

/** Apply force at center of mass  */
- (void) applyForce:(CGPoint) force;

/** Apply torque to the attached body  */
- (void) applyTorque:(float) torque;

/** 
 Mark the component as destroyed, it will be removed from context after the world steps  
 Use this function inside physic callbacks functions if you want to remove the component.
 Do not remove component inside physic callbacks with [self removeFromParentContext:cleanup] 
 or [context removeComponent:node]
 */
- (void) toDestroyed;

/** 
 Mark the component as released 
 The attached physic entity will be released after the world steps
 */
- (void) toReleased;

/** Update component position & rotation based on those from physic */
- (void) updateFromPhysic;

- (void) updateToPhysic;
@end

#endif