//
//  PhysicUserData.h
//  Penguins Destroyer
//
//  Created by Ngo Duc Hiep on 10/7/10.
//  Copyright 2010 PTT Solution., JSC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "constant+macro.h"

#if PHYSIC_ENABLED

#import "Box2D.h"

@class PhysicUserData;

typedef struct CollisionInfo{
	b2Fixture *fA;
	b2Fixture *fB;
	PhysicUserData *uA;
	PhysicUserData *uB;
	float32 velocity;
	b2Vec2 normal;
} CollisionInfo;

@protocol PhysicProtocol
- (PhysicUserData *) registerPhysic:(NSString *) key;
- (void) unregisterPhysic:(NSString *) key destroyPhysic:(BOOL) destroy;
//- (void) releasePhysicAndDestroy:(BOOL) destroy;

/** Only valid objects may receive callbacks  */
- (BOOL) isValid;

/** Return YES if you don't want to receive @selector(physicBodyChanged)  */
- (BOOL) isUpdateIgnored;

@optional
/** Implememnt this function to update position and rotation of the component and its childs */
- (void) physicBodyChanged:(PhysicUserData *) data;

/** Used for Joint Node  */
- (void) attachedPhysicEntityDestroyed:(PhysicUserData *) data;

/** Collision processing is done here  */
- (void) physicEntity:(PhysicUserData *) sdata collideWith:(PhysicUserData *) data info:(CollisionInfo) info;

/** The component receives an impulse caused by and explosion  */
- (void) physicBody:(PhysicUserData *) data receivedImpulse:(CGPoint) iml ;

@end

@interface PhysicUserData : NSObject {
	/** The key to map to CCComponent  */
	NSString *_key;
	NSObject<PhysicProtocol> *_component;
	int _type;
	void *_entity;
}
@property(retain) NSString *key;
@property(assign) NSObject<PhysicProtocol> *component;
@property(nonatomic) int type;
@property(nonatomic, assign) void *entity;

@end

#endif