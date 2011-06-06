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