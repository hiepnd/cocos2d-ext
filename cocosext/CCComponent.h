//
//  CCComponent.h
//  Penguins Destroyer
//
//  Created by Ngo Duc Hiep on 10/4/10.
//  Copyright 2010 PTT Solution., JSC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "cocos2d.h"
#import "CCNode+Ext.h"
#import "constant+macro.h"

#if PHYSIC_ENABLED
#import "Box2D.h"
#include "PhysicContext.h"
#endif

@class CCContext;

#define COMPONENT_STATE_ACTION_TAG 1984

@interface CCComponent : CCSprite
#if PHYSIC_ENABLED
<PhysicProtocol>
#endif
{
	NSString *_state;
	//CCAction *_currentAction;
	
	NSDictionary *_def;
	
	CCArray *_childs;
	NSMutableDictionary *_childs_map;
	
	CCContext *_context;
	
	/** Support batch component  */
//	BOOL _isBatch;
//	BOOL _isChildOfBatch;
//	CCSpriteBatchNode *_batch;
	
#if PHYSIC_ENABLED	
	/** Physics  */
	NSMutableDictionary *_physics;
	PhysicUserData *_model;
	float _deltaAngle;
	BOOL _updatePhysic;
	
	CGPoint _offset;
	float _angle; 
	BOOL _destroyPhysicOnDealloc;
	
	CGAffineTransform _bodyToNodeTransform;
#endif //of #if PHYSIC_ENABLED
	
	/** Model data  */
	BOOL _invalid;
	
}
@property(nonatomic, retain) NSString *state;
@property(assign) CCContext *context;
@property(readonly) CCArray *childs;
@property(readonly) CGSize size;
@property(nonatomic) BOOL invalid;
//@property(readonly) CCSpriteBatchNode *batch;
//@property(readonly) BOOL isBatch;

#if PHYSIC_ENABLED
@property(nonatomic) float deltaAngle;
@property(assign) PhysicUserData *model;
@property BOOL destroyPhysicOnDealloc;

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
@property(readonly) CGAffineTransform bodyToWorldTransform;
#endif //of #if PHYSIC_ENABLED

- (id) initSafe;

+ (id) componentWithFile:(NSString *) file;
- (id) initWithFile:(NSString *) file;

//+ (id) batchComponentWithFile:(NSString *) file;
//- (id) initAsBatchWithFile:(NSString *) file;


/** Manage child components  */
- (void) addComponent:(CCComponent *) child z:(int) z;
- (void) addComponent:(CCComponent *) child;
- (void) removeComponent:(CCComponent *) child;
- (void) addComponent:(CCComponent *) child key:(NSString *) key z:(int)z;
- (void) addComponent:(CCComponent *) child key:(NSString *) key;
- (void) removeComponentByKey:(NSString *) key;

/** Query child components  */
- (CCComponent *) componentByKey:(NSString *) key;
- (CCComponent *) componentByKeyRecursive:(NSString *) key;
- (CCComponent *) child:(NSString *) key;
- (CCComponent *) componentByTag:(int) tag;
- (NSArray *) componentsByTag:(int) tag;
- (CCComponent *) componentAtPoint:(CGPoint) pos;

/** State control  */
- (void) setState:(NSString *)state;
- (void) setState:(NSString *)state context:(NSString *) context target:(id) target selector:(SEL) selector;
- (void) setStateForever:(NSString *) state;
- (void) spawnStates:(NSString *) state1, ... NS_REQUIRES_NIL_TERMINATION;
- (void) spawnInContext:(NSString *) context target:(id) target selector:(SEL) selector states:(NSString *) state1, ... NS_REQUIRES_NIL_TERMINATION;

- (BOOL) isStateRunning;
- (void) stopCurrentState;

/** The selector (if not nill) must take one parameter ex. @selector(didRunActionInContext:). 
 The parameter passed is the context */

/** Query location & geometry  */
- (CGPoint) absolutePosition;
- (CGSize) size;
- (CGRect) bound;

- (void) bindData:(NSDictionary *) data;
#pragma mark  Class Methods

#pragma mark Physics
#if PHYSIC_ENABLED
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

#endif
@end